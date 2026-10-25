# AV-Travel

Trips and travel blog at https://travel.amvhome.net, built with Jekyll on GitHub Pages (repo `adrianv66/av-travel`).

## How it's laid out

| What | Where it lives | Address on the site |
|---|---|---|
| Front page (trips + latest blog posts) | `index.html` | `/` |
| A trip | `_trips/<trip>.md` | `/<trip>/` |
| A day of a trip | `<trip>/_posts/YYYY-MM-DD-day-NN-title.md` | `/<trip>/day-NN-title/` |
| A blog post | `blog/_posts/YYYY-MM-DD-title.md` | `/blog/title/` |
| Photos | `images/<trip>/` or `images/blog/` | `/images/...` |

## Adding a trip

Copy `_trips/mediterranean-2027.md` to a new name, e.g. `_trips/japan-2028.md`, and change the title, `start`, `end`
and `summary`. The file name becomes the trip's address. Its days go in a folder with the same name: `japan-2028/_posts/`
(the day script creates it for you).

Optional in the trip file:
- `cover:` a photo for the card on the front page, e.g. `/images/japan-2028/cover.jpg`
- `polarsteps_embed_url:` the `src` URL from Polarsteps' embed code. If it's blank, the trip page draws its own route map
  from the stops in each day.

## Adding a day

```powershell
.\tools\New-TravelDay.ps1 "Colosseum and the Forum" Rome
```

It picks the trip whose dates cover the day (or the only trip), works out the day number, asks for the stops,
and opens the file. Options: `-Date 2027-05-03`, `-Trip japan-2028`, `-NoStops`, `-Publish` (commit and push for you).

Coordinates: right-click a spot in Google Maps and click the numbers at the top of the menu to copy them.

## Adding a blog post

```powershell
.\tools\New-BlogPost.ps1 "What we packed for five weeks" -Summary "Carry-on only, mostly."
```

Same `-Date`, `-Publish` and `-NoEdit` options.

## Posting days late

`future: false` in `_config.yml` hides anything dated in the future until that date. The site only rebuilds when you push,
so a post dated ahead goes live on the first push on or after its date.

The repo is public, so anything you commit can be read on GitHub before it shows on the site.

## Photos

Resize to about 1600px wide before adding them; full-size phone photos make pages slow on hotel Wi-Fi.

## First-time setup on a new laptop

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
git clone https://github.com/adrianv66/av-travel.git
```
