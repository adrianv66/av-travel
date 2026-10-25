# AV-Travel

Trip journal for travel.amvhome.net, built with Jekyll on GitHub Pages.

## One-time setup

1. On your **personal** GitHub account, create a new public repo (e.g. `av-travel`) and push this folder to it.
2. Repo **Settings → Pages**: Source = "Deploy from a branch", branch = `main`, folder = `/ (root)`.
3. Same page, **Custom domain**: enter `travel.amvhome.net` and save.
4. In **GoDaddy → DNS** for amvhome.net, add one record (leave the email records alone):
   - Type: `CNAME`, Name: `travel`, Value: `<your-github-username>.github.io`
5. Once the certificate is issued, tick **Enforce HTTPS** on the Pages settings page.

## Polarsteps map

In Polarsteps, open your public trip, choose the embed option, and copy the `src="..."` URL from the code.
Paste it into `polarsteps_embed_url` in `_config.yml`. Leave it blank to hide the map.

## Adding a day

Create a file in `_posts` named `YYYY-MM-DD-short-title.md` (copy the sample day). In the front matter:

- `title`, `place` — shown at the top of the page
- `stops` — each with `name`, `lat`, `lng`, and optional `time` and `note`. They're numbered on the map in order, joined by a dashed line.

Easiest way to get coordinates: right-click a spot in Google Maps and click the numbers at the top of the menu to copy them.

## Posting days late

`future: false` in `_config.yml` means a post dated in the future won't appear until that date. You can push a few days ahead
and they'll go live on their own, but **only when the site rebuilds** (on your next push), so a quick push each day is enough.

Note: the repo is public, so anything you commit (including future-dated days) can be read on GitHub before it shows on the site.

## Previewing locally (optional)

Needs Ruby: `gem install bundler jekyll`, then `jekyll serve --future` and open http://localhost:4000.
