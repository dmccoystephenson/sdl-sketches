# SDL Sketches

[![Play in your browser](https://img.shields.io/badge/Play-in%20your%20browser-2ea44f)](https://danielstephenson.dev/play/sdl-sketches)

Three small programs written by Daniel Stephenson in C++ with [SDL2](https://www.libsdl.org) in January 2020, built for the browser with [Emscripten](https://emscripten.org) and served together as one site.

| Sketch | Source repository | What it does |
| --- | --- | --- |
| Controllable Rectangle | [dmccoystephenson/Controllable-Rectangle](https://github.com/dmccoystephenson/Controllable-Rectangle) | Move a square with the arrow keys, diagonals included. |
| Rectangle Changing Size | [dmccoystephenson/Rectangle-Changing-Size](https://github.com/dmccoystephenson/Rectangle-Changing-Size) | Grow the square with the up arrow and shrink it with the down arrow. |
| Bouncing Rectangle | [dmccoystephenson/Bouncing-Rectangle-Using-SDL](https://github.com/dmccoystephenson/Bouncing-Rectangle-Using-SDL) | A square bounces around the window, changing colour at the edges. |

The sketches themselves live in their own repositories; this repository vendors each one as a git submodule under `sketches/`, pinned to a commit, and holds only the browser build around them.

## Play in your browser
- https://sdl-sketches.play.danielstephenson.dev
- more games: https://danielstephenson.dev/play

The first page lists the three sketches, and each sketch's page links to the other two. On a keyboard the arrow keys work as in the desktop programs. On a phone or tablet, on-screen buttons appear under the sketch: an eight-way pad for Controllable Rectangle (the corners move diagonally) and Grow / Shrink buttons for Rectangle Changing Size; hold one to keep going, or tap it for a short step. Bouncing Rectangle needs no input.

## Building
Install and activate the [Emscripten SDK](https://emscripten.org/docs/getting_started/downloads.html) (the workflow uses 6.0.10), then:

```
git submodule update --init
web/build.sh
python3 -m http.server 8000 --directory web/build
```

and open http://localhost:8000. `web/build.sh` writes `index.html` (a copy of `web/index.html`) and `<sketch>.html`, `<sketch>.js` and `<sketch>.wasm` for each sketch to `web/build/`, which is not committed. Each sketch page is made from `web/shell.html`.

The sketches are compiled unchanged. Each one runs its own `while (running)` loop, which would never give control back to the browser, so `web/build.sh` builds with `-sASYNCIFY` and force-includes `web/frame.h`, which makes every `SDL_RenderPresent` call also wait for the browser's next animation frame. A sketch therefore draws once per display refresh, as it does on the desktop with a vsynced renderer. Bouncing Rectangle also waits 10 ms per frame (its own `SDL_Delay(10)`), so it moves a little slower than an unsynced desktop window.

## Continuous integration
`.github/workflows/browser.yml` builds the site on every pull request and every push to `main` and checks that every page, script and module was produced, that each sketch page has its placeholders filled in, its canvas, its script and the play link, and that `index.html` links to it. On a manual run (`workflow_dispatch`), or on a push to `main` once the repository variable `ARCADE_ENABLED` is `true`, it deploys `web/build/` to [arcade](https://github.com/Stephenson-Software/arcade) with [arcade-deploy](https://github.com/Stephenson-Software/arcade-deploy) as slug `sdl-sketches`, version `<version.txt>+g<short commit>`; the upload token is the `ARCADE_TOKEN` secret.

## License
The browser build in this repository is licensed under the Stephenson Software Non-Commercial License (Stephenson-NC); see [LICENSE](LICENSE). The sketches are in their own repositories.
