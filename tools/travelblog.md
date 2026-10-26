# Updating AV-Travel: a guide for Mich

Oct 26, 2026 · @Adrian

## How the site works

Everything you see on [travel.amvhome.net](https://travel.amvhome.net) comes from text files kept on GitHub, at [github.com/adrianv66/av-travel](https://github.com/adrianv66/av-travel). You change a file in your web browser, click **Commit changes**, and the website updates itself about a minute later. Nothing you do can break the live site for long: every change is saved, and Adrian can undo any of them.

The site has three kinds of page:

| Page | What it is | Where its file lives on GitHub |
| --- | --- | --- |
| Trip | One page per holiday, with the route map and the list of days | `_trips` folder, e.g. `_trips/vietnam-2026.md` |
| Day | One page per day of a trip, with that day's map, stops, your words and photos | A folder named after the trip, then `_posts`, e.g. `vietnam-2026/_posts/` |
| Blog post | Anything that isn't a single day: tips, packing lists, reviews | `blog/_posts/` |

Photos live in the `images` folder, in a folder per trip, e.g. `images/vietnam-2026/`.

The trips already on the site are `vietnam-2026`, `rhine-paris-2025`, `osaka-2025`, `hawaii-2025`, `north-pacific-2024` (Tokyo and Alaska), `europe-2022` and `mediterranean-2027`.

## Getting set up (once)

This takes about five minutes and only needs doing once.

1. Go to [github.com/signup](https://github.com/signup) and create a free account with your email address. Pick any username.
2. Tell Adrian your username. He adds you to the site under Settings → Collaborators.
3. Look out for an email from GitHub titled something like "invited you to collaborate on adrianv66/av-travel". Click **View invitation**, then **Accept invitation**.
4. Bookmark [github.com/adrianv66/av-travel](https://github.com/adrianv66/av-travel). That's your starting point every time.

You can do all of this on a laptop or iPad. A phone works too, but the screen is small for writing; the GitHub website on a laptop is easiest.

## Writing up a day

Every day already has its page, map and stops; you add the story.

1. Open [github.com/adrianv66/av-travel](https://github.com/adrianv66/av-travel) and click the trip's folder, e.g. **vietnam-2026**, then **\_posts**.
2. Click the day's file. The names start with the date and day number, e.g. `2026-04-10-day-21-angkor-wat.md`.
3. Click the **pencil icon** at the top right of the file ("Edit this file").
4. You'll see a block of settings between two `---` lines at the top. Leave that block alone for now (the last section explains the safe bits to change).
5. Under the second `---` there's a grey line starting `<!-- Write about the day here`. That's a hidden reminder; delete it or leave it, it never shows on the site.
6. Type your write-up below it. Leave an empty line between paragraphs.
7. Click the **Preview** tab at the top of the editor to see how it looks.
8. Click the green **Commit changes…** button, then **Commit changes** again in the box that pops up. You don't need to change the message.
9. Wait about a minute, then open the day on the site. From [travel.amvhome.net](https://travel.amvhome.net), click the trip, then the day.

If the page hasn't changed, press **Ctrl+F5** (or pull down to refresh on the iPad); the browser sometimes shows the old copy.

## Adding photos

Photos go in two steps: upload the photo, then add one line to the day where you want it to appear.

**Before you upload, get each photo ready:**

- **Make it JPG, not HEIC.** iPhones save photos as HEIC, which web browsers can't show. Emailing or AirDropping a photo to the laptop usually turns it into JPG; or on the iPhone set Settings → Camera → Formats → **Most Compatible** before the trip.
- **Make it smaller.** Aim for about 1600 pixels wide and under 1 MB, so pages load on slow hotel Wi-Fi. On Windows, open the photo in the Photos app, click **…** → **Resize image** and pick the medium size. GitHub refuses anything over 25 MB.
- **Give it a simple name**: lowercase, hyphens instead of spaces, e.g. `angkor-sunrise.jpg`.

**The first time for a trip, make its photo folder:**

1. On the main repo page, click **Add file** → **Create new file**.
2. In the name box, type `images/vietnam-2026/readme.txt`. Each `/` you type turns into a folder.
3. Type anything in the big box (e.g. "Vietnam photos") and click **Commit changes** twice.

**Uploading:**

1. Open the **images** folder, then the trip's folder.
2. Click **Add file** → **Upload files** and drag the photos in. Several at once is fine.
3. Click **Commit changes**.

**Showing a photo on a day:** edit the day (as above) and add a line like this where the photo should go, with an empty line above and below:

```markdown
![Sunrise over Angkor Wat](/images/vietnam-2026/angkor-sunrise.jpg)
```

The words in the square brackets are the caption for people who can't see the image. The name in brackets must match the photo's file name exactly, capitals included.

## Other things you can change

**A trip's introduction.** Open `_trips`, then the trip's file (e.g. `vietnam-2026.md`), click the pencil, and rewrite the paragraph under the second `---`. It shows at the top of the trip page.

**A trip's cover photo.** Upload the photo to the trip's images folder, then in the same trip file change the `cover:` line to its name, keeping the quotes:

```markdown
cover: "/images/vietnam-2026/cover.jpg"
```

It appears on the trip's card on the front page. Wide photos (landscape) look best.

**A stop's name or note.** In the day's settings block, each stop looks like this:

```markdown
  - name: "Angkor Wat with a guide"
    time: "4:15 AM"
    lat: 13.4125
    lng: 103.867
    note: "Until about 6:00 PM"
```

You can change the words inside the quotes after `name:`, `time:` and `note:`. Keep the quotes and the spaces at the start of each line exactly as they are. Leave `lat:` and `lng:` (the map position) to Adrian.

**A blog post.** Open the `blog` folder, then `_posts`, and click **Add file** → **Create new file**. Name it with the date first, e.g. `2026-11-02-what-we-packed.md`, and start it with these three lines, then your post underneath:

```markdown
---
title: "What we packed for five weeks"
---
```

A post dated in the future stays hidden on the site until that date.

**A missing day.** Some days have no page because TripIt had nothing for them. Ask Adrian to add it; it takes him a minute.

## Cheat sheet

| To get | Type |
| --- | --- |
| A new paragraph | An empty line between paragraphs |
| **Bold** | `**Bold**` |
| *Italics* | `*Italics*` |
| A heading inside a day | `## Dinner on the river` on its own line |
| A bullet list | Each line starting with ` -  ` |
| A link | `[Our hotel](https://example.com)` |
| A photo | `![Caption](/images/trip-folder/photo-name.jpg)` |

**Please don't touch** files outside the trip, `_trips`, `blog` and `images` folders (`_config.yml`, `_layouts`, `assets`, `tools`, `CNAME`). They run the website itself.

**If something goes wrong:**

- **The page didn't change.** Wait another minute and press Ctrl+F5.
- **A day disappeared or the site looks broken.** Usually a missing quote or `---` in the settings block. Tell Adrian which file you edited; he can see exactly what changed and put it back.
- **A photo shows as a broken image.** Check the file name in the photo line matches the upload exactly, capitals and `.jpg` included, and that it's JPG, not HEIC.
