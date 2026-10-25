#Requires -Version 5.1
<#
.SYNOPSIS
    Creates a new blog post for the AV-Travel site (travel.amvhome.net).

.DESCRIPTION
    Builds blog\_posts\YYYY-MM-DD-<slug>.md with front matter filled in and
    opens it for writing. Use the blog for anything that isn't a single trip
    day: planning notes, packing lists, reviews, city tips.

    Works in Windows PowerShell 5.1 and PowerShell 7.

.PARAMETER Title
    The post title, e.g. "What we packed for five weeks".

.PARAMETER Summary
    One line shown under the title in the post lists. Optional.

.PARAMETER Date
    Publish date. Defaults to today. A future date keeps the post hidden until then.

.PARAMETER Publish
    Commit and push the new post straight away (git add, commit, push).

.PARAMETER NoEdit
    Don't open the new file in an editor afterwards.

.EXAMPLE
    .\tools\New-BlogPost.ps1 "What we packed for five weeks" -Summary "Carry-on only, mostly."
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [string]$Title,

    [Parameter(Position = 1)]
    [string]$Summary,

    [datetime]$Date = (Get-Date).Date,

    [switch]$Publish,

    [switch]$NoEdit
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $repoRoot '_config.yml'))) {
    throw "Can't find _config.yml in '$repoRoot'. Is the script in the repo's tools folder?"
}
$postsDir = Join-Path (Join-Path $repoRoot 'blog') '_posts'
if (-not (Test-Path $postsDir)) { New-Item -ItemType Directory -Path $postsDir | Out-Null }

function ConvertTo-YamlString {
    param([string]$Value)
    '"' + ($Value -replace '\\', '\\' -replace '"', '\"') + '"'
}

function ConvertTo-Slug {
    param([string]$Value)
    $normalised = $Value.Normalize([Text.NormalizationForm]::FormD)
    $plain = -join ($normalised.ToCharArray() | Where-Object {
        [Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne [Globalization.UnicodeCategory]::NonSpacingMark
    })
    $slug = ($plain.ToLowerInvariant() -replace '[^a-z0-9]+', '-').Trim('-')
    if (-not $slug) { $slug = 'post' }
    $slug
}

$fileName = '{0:yyyy-MM-dd}-{1}.md' -f $Date, (ConvertTo-Slug $Title)
$filePath = Join-Path $postsDir $fileName
if (Test-Path $filePath) { throw "A post already exists at '$filePath'." }

$lines = @(
    '---'
    "title: $(ConvertTo-YamlString $Title)"
)
if ($Summary) { $lines += "summary: $(ConvertTo-YamlString $Summary)" }
$lines += @(
    '---'
    ''
    'Write your post here.'
    ''
    '<!-- Photos: put them in images/blog/ and add a line like this: ![Caption](/images/blog/photo.jpg) -->'
    ''
)

# UTF-8 without BOM, LF line endings.
[IO.File]::WriteAllText($filePath, ($lines -join "`n"), (New-Object System.Text.UTF8Encoding($false)))

Write-Host ''
Write-Host "Created blog\_posts\$fileName" -ForegroundColor Green
if ($Date -gt (Get-Date)) {
    Write-Host "  Dated $($Date.ToString('d MMM yyyy')), so it stays hidden on the site until then." -ForegroundColor DarkGray
}

if (-not $NoEdit) {
    if (Get-Command code -ErrorAction SilentlyContinue) { & code $filePath }
    else { Start-Process notepad.exe -ArgumentList "`"$filePath`"" }
}

if ($Publish) {
    if (-not $NoEdit) { Read-Host 'Finish writing, save the file, then press Enter to publish' }
    Push-Location $repoRoot
    try {
        git add -- "blog/_posts/$fileName"
        if ($LASTEXITCODE -ne 0) { throw 'git add failed.' }
        git commit -m "Add blog post: $Title"
        if ($LASTEXITCODE -ne 0) { throw 'git commit failed.' }
        git push
        if ($LASTEXITCODE -ne 0) { throw 'git push failed. The commit is saved locally; run git push again when you have a connection.' }
        Write-Host 'Published. The site updates in about a minute.' -ForegroundColor Green
    }
    finally { Pop-Location }
}
else {
    Write-Host 'When you''re ready: git add . ; git commit -m "Add post" ; git push' -ForegroundColor DarkGray
}
