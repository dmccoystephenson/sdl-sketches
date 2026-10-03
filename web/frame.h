// Force-included into every sketch by web/build.sh (em++ -include web/frame.h); the
// sketches themselves are built unchanged from their own repositories.
//
// Each sketch runs its own `while (running)` loop, which would never hand control back to
// the browser. Built with -sASYNCIFY, a sketch can pause mid-loop instead: every
// SDL_RenderPresent here also waits for the browser's next animation frame, so a sketch
// draws once per display refresh, as it does on the desktop with a vsynced renderer.
#pragma once

#include <SDL.h>
#include <emscripten.h>

EM_ASYNC_JS(void, sketchWaitForNextFrame, (), {
	await new Promise(function (resolve) { requestAnimationFrame(resolve); });
});

static inline void sketchRenderPresent(SDL_Renderer* renderer) {
	SDL_RenderPresent(renderer);
	sketchWaitForNextFrame();
}

// Defined after SDL.h has been included, so SDL's own declaration is untouched and the
// sketch's later `#include <SDL.h>` is a no-op; only the sketch's calls are redirected.
#define SDL_RenderPresent(renderer) sketchRenderPresent(renderer)
