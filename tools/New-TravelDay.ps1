#Requires -Version 5.1
<#
.SYNOPSIS
    Creates a new day post for the AV-Travel site (travel.amvhome.net).

.DESCRIPTION
    Builds <trip>\_posts\YYYY-MM-DD-day-NN-<slug>.md with front matter filled in.
    The trip is picked from the _trips folder (the one whose dates cover -Date,
    or the only trip if there's just one), and the day number is worked out
    from that trip's start date. Stops can be
    entered interactively: paste coordinates straight from Google Maps
    (right-click a spot, click the numbers, e.g. "41.8902, 12.4922").

    Works in Windows PowerShell 5.1 and PowerShell 7.

.PARAMETER Title
    Short title for the day, e.g. "Colosseum and the Forum".

.PARAMETER Place
    Where you were, e.g. "Rome". Shown next to the date.

.PARAMETER Date
    The day being written up. Defaults to today.

.PARAMETER Trip
    The trip's file name in _trips without .md, e.g. mediterranean-2027.
    Only needed if more than one trip could match the date.

.PARAMETER NoStops
    Skip the stop prompts and add stops by hand later.

.PARAMETER Publish
    Commit and push the new post straight away (git add, commit, push).

.PARAMETER NoEdit
    Don't open the new file in an editor afterwards.

.EXAMPLE
    .\tools\New-TravelDay.ps1 -Title "Colosseum and the Forum" -Place Rome

.EXAMPLE
    .\tools\New-TravelDay.ps1 "Acropolis" Athens -Date 2027-05-03 -Publish

.EXAMPLE
    .\tools\New-TravelDay.ps1 "Shibuya" Tokyo -Trip japan-2028 -Date 2028-03-02
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [string]$Title,

    [Parameter(Position = 1)]
    [string]$Place,

    [datetime]$Date = (Get-Date).Date,

    [string]$Trip,

    [switch]$NoStops,

    [switch]$Publish,

    [switch]$NoEdit
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Repo root is the folder above this script's tools folder.
$repoRoot = Split-Path -Parent $PSScriptRoot
$tripsDir = Join-Path $repoRoot '_trips'
if (-not (Test-Path $tripsDir)) {
    throw "Can't find the _trips folder at '$tripsDir'. Is the script in the repo's tools folder?"
}

# --- Read the trips ----------------------------------------------------------
function Get-FrontMatterDate {
    param([string]$Text, [string]$Key)
    $m = [regex]::Match($Text, "(?m)^${Key}:\s*['""]?(\d{4}-\d{2}-\d{2})")
    if ($m.Success) { [datetime]::ParseExact($m.Groups[1].Value, 'yyyy-MM-dd', [Globalization.CultureInfo]::InvariantCulture) }
}

$trips = @(Get-ChildItem -Path $tripsDir -Filter *.md | ForEach-Object {
    $text = [IO.File]::ReadAllText($_.FullName)
    $titleMatch = [regex]::Match($text, '(?m)^title:\s*["'']?(.+?)["'']?\s*$')
    [pscustomobject]@{
        Name  = $_.BaseName
        Title = $(if ($titleMatch.Success) { $titleMatch.Groups[1].Value } else { $_.BaseName })
        Start = Get-FrontMatterDate $text 'start'
        End   = Get-FrontMatterDate $text 'end'
    }
})
if ($trips.Count -eq 0) { throw "No trips in '$tripsDir'. Create one first (copy mediterranean-2027.md)." }

if ($Trip) {
    $tripInfo = $trips | Where-Object Name -eq $Trip | Select-Object -First 1
    if (-not $tripInfo) { throw "No trip called '$Trip'. Trips: $(($trips.Name) -join ', ')" }
}
else {
    $covering = @($trips | Where-Object { $_.Start -and $_.End -and $Date -ge $_.Start -and $Date -le $_.End })
    if ($covering.Count -eq 1) { $tripInfo = $covering[0] }
    elseif ($trips.Count -eq 1) { $tripInfo = $trips[0] }
    else { throw "Couldn't tell which trip $($Date.ToString('d MMM yyyy')) belongs to. Use -Trip with one of: $(($trips.Name) -join ', ')" }
}
if (-not $tripInfo.Start) { throw "Trip '$($tripInfo.Name)' has no start: date in its _trips file." }

$postsDir = Join-Path (Join-Path $repoRoot $tripInfo.Name) '_posts'
if (-not (Test-Path $postsDir)) { New-Item -ItemType Directory -Path $postsDir | Out-Null }

function ConvertTo-YamlString {
    param([string]$Value)
    # Double-quoted YAML string: escape backslashes and quotes.
    '"' + ($Value -replace '\\', '\\' -replace '"', '\"') + '"'
}

function ConvertTo-Slug {
    param([string]$Value)
    # Strip accents (Trastevere, Plaça, Akrópoli...) then keep a-z, 0-9 and hyphens.
    $normalised = $Value.Normalize([Text.NormalizationForm]::FormD)
    $plain = -join ($normalised.ToCharArray() | Where-Object {
        [Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne [Globalization.UnicodeCategory]::NonSpacingMark
    })
    $slug = ($plain.ToLowerInvariant() -replace '[^a-z0-9]+', '-').Trim('-')
    if (-not $slug) { $slug = 'day' }
    $slug
}

# --- Work out the day number -------------------------------------------------
$dayNumber = ($Date.Date - $tripInfo.Start.Date).Days + 1
if ($dayNumber -lt 1) {
    Write-Warning "That date is before $($tripInfo.Title) starts ($($tripInfo.Start.ToString('d MMM yyyy'))). Using day 0 for now; use -Date for a trip day."
    $dayNumber = 0
}
$dayLabel  = '{0:D2}' -f $dayNumber
$fullTitle = "Day ${dayNumber}: $Title"
$fileName  = '{0:yyyy-MM-dd}-day-{1}-{2}.md' -f $Date, $dayLabel, (ConvertTo-Slug $Title)
$filePath  = Join-Path $postsDir $fileName

if (Test-Path $filePath) {
    throw "A post already exists at '$filePath'."
}

# --- Collect stops -----------------------------------------------------------
$stops = New-Object System.Collections.Generic.List[object]

if (-not $NoStops) {
    Write-Host ''
    Write-Host 'Add the stops for the day, in order. Leave the name blank to finish.' -ForegroundColor Cyan
    Write-Host 'Coordinates: right-click the spot in Google Maps and click the numbers to copy them.' -ForegroundColor DarkGray

    $n = 1
    while ($true) {
        Write-Host ''
        $name = Read-Host "Stop $n name"
        if ([string]::IsNullOrWhiteSpace($name)) { break }

        $lat = $null; $lng = $null
        while ($null -eq $lat) {
            $coords = Read-Host '  Coordinates (lat, lng)'
            $m = [regex]::Match($coords, '^\s*(-?\d+(?:\.\d+)?)\s*[,;\s]\s*(-?\d+(?:\.\d+)?)\s*$')
            if ($m.Success) {
                $la = [double]::Parse($m.Groups[1].Value, [Globalization.CultureInfo]::InvariantCulture)
                $lo = [double]::Parse($m.Groups[2].Value, [Globalization.CultureInfo]::InvariantCulture)
                if ($la -ge -90 -and $la -le 90 -and $lo -ge -180 -and $lo -le 180) {
                    $lat = $la; $lng = $lo
                    continue
                }
            }
            Write-Host '  That doesn''t look like coordinates. Example: 41.8902, 12.4922' -ForegroundColor Yellow
        }

        $time = Read-Host '  Time (optional, e.g. 9:00 AM)'
        $note = Read-Host '  Note (optional)'

        $stops.Add([pscustomobject]@{
            Name = $name.Trim()
            Lat  = $lat
            Lng  = $lng
            Time = $time.Trim()
            Note = $note.Trim()
        })
        $n++
    }
}

# --- Build the file ----------------------------------------------------------
$inv = [Globalization.CultureInfo]::InvariantCulture
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine('---')
[void]$sb.AppendLine('layout: day')
[void]$sb.AppendLine("title: $(ConvertTo-YamlString $fullTitle)")
[void]$sb.AppendLine("day: $dayNumber")
if ($Place) { [void]$sb.AppendLine("place: $(ConvertTo-YamlString $Place)") }

if ($stops.Count -gt 0) {
    [void]$sb.AppendLine('stops:')
    foreach ($s in $stops) {
        [void]$sb.AppendLine("  - name: $(ConvertTo-YamlString $s.Name)")
        if ($s.Time) { [void]$sb.AppendLine("    time: $(ConvertTo-YamlString $s.Time)") }
        [void]$sb.AppendLine('    lat: ' + $s.Lat.ToString('0.######', $inv))
        [void]$sb.AppendLine('    lng: ' + $s.Lng.ToString('0.######', $inv))
        if ($s.Note) { [void]$sb.AppendLine("    note: $(ConvertTo-YamlString $s.Note)") }
    }
}
else {
    [void]$sb.AppendLine('# stops:')
    [void]$sb.AppendLine('#   - name: "Somewhere"')
    [void]$sb.AppendLine('#     time: "9:00 AM"')
    [void]$sb.AppendLine('#     lat: 41.8902')
    [void]$sb.AppendLine('#     lng: 12.4922')
}

[void]$sb.AppendLine('---')
[void]$sb.AppendLine('')
[void]$sb.AppendLine('Write about the day here.')
[void]$sb.AppendLine('')
[void]$sb.AppendLine("<!-- Photos: put them in images/$($tripInfo.Name)/ and add a line like this: ![Caption](/images/$($tripInfo.Name)/day-$dayLabel-photo.jpg) -->")

# UTF-8 without BOM, LF line endings (Jekyll is happiest with these, and 5.1's -Encoding UTF8 adds a BOM).
$content = $sb.ToString() -replace "`r`n", "`n"
[IO.File]::WriteAllText($filePath, $content, (New-Object System.Text.UTF8Encoding($false)))

Write-Host ''
Write-Host "Created $($tripInfo.Name)\_posts\$fileName" -ForegroundColor Green
Write-Host "  $fullTitle$(if ($Place) { " · $Place" }), $($stops.Count) stop(s)"

# --- Open for editing ----------------------------------------------------------
if (-not $NoEdit) {
    if (Get-Command code -ErrorAction SilentlyContinue) {
        & code $filePath
    }
    else {
        Start-Process notepad.exe -ArgumentList "`"$filePath`""
    }
}

# --- Publish -------------------------------------------------------------------
if ($Publish) {
    if (-not $NoEdit) {
        Read-Host 'Finish writing, save the file, then press Enter to publish'
    }
    Push-Location $repoRoot
    try {
        git add -- "$($tripInfo.Name)/_posts/$fileName"
        if ($LASTEXITCODE -ne 0) { throw 'git add failed.' }
        git commit -m "Add $fullTitle"
        if ($LASTEXITCODE -ne 0) { throw 'git commit failed.' }
        git push
        if ($LASTEXITCODE -ne 0) { throw 'git push failed. The commit is saved locally; run git push again when you have a connection.' }
        Write-Host 'Published. The site updates in about a minute.' -ForegroundColor Green
    }
    finally {
        Pop-Location
    }
}
else {
    Write-Host 'When you''re ready: git add . ; git commit -m "Add day" ; git push' -ForegroundColor DarkGray
}
