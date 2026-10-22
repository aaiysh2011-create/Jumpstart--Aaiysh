# Signal Drift

A 2D platformer built in Godot for Hack Club Jumpstart. You're a small robot in a corrupted digital world: collect data fragments, stomp ground enemies, dodge flying chasers and spikes, and reach the beacon at the end without running out of health.

## Controls
- A / D or Left / Right Arrow: move
- Space / W / Up Arrow: jump (hold for higher, tap for a short hop)
- Jump again in mid-air: double jump

## Features
- Responsive movement (acceleration, coyote time, jump buffering, variable jump height, double jump)
- Health, damage knockback, invincibility frames, death and respawn
- Ground patrol enemies (stomp them), flying chasers, instant-kill spikes and pits
- Score and health HUD, win screen at the end of the level

## Run it
Open `project.godot` in Godot 4.3 or newer and press Play (F5).

## Export for the web (itch.io)
1. Project -> Export -> Add... -> Web.
2. Turn **Thread Support off** (so it works on itch without extra headers).
3. Export to a folder, naming the file `index.html`.
4. Zip the *contents* of that folder so `index.html` is at the top of the zip.
5. On itch: upload the zip, tick "This file will be played in the browser", viewport 1152x648.

Made as part of [Hack Club Jumpstart](https://jams.hackclub.com/jam/godot-platformer).
