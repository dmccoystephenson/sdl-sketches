#!/usr/bin/env bash
# Builds the three sketches for the browser into web/build/: index.html (the page that
# switches between them) plus <sketch>.html, <sketch>.js and <sketch>.wasm for each.
# Needs Emscripten's em++ on PATH (source emsdk_env.sh first) and the submodules checked
# out (git submodule update --init).
#
# The sketches are compiled exactly as they are in their own repositories: web/frame.h is
# force-included so that every SDL_RenderPresent also waits for the browser's next
# animation frame, which -sASYNCIFY makes possible inside the sketches' own while loops.
# No pthreads, so the pages need no cross-origin isolation.
set -euo pipefail
cd "$(dirname "$0")/.."

# Both prerequisites are checked before the old output is removed, so a run that cannot
# build says what is missing and leaves the last build in place.
if ! command -v em++ > /dev/null; then
  echo "web/build.sh: em++ not found; install the Emscripten SDK and source emsdk_env.sh first" >&2
  exit 1
fi
while read -r _ submodule; do
  if [ ! -e "$submodule/.git" ]; then
    echo "web/build.sh: $submodule is not checked out; run git submodule update --init first" >&2
    exit 1
  fi
done < <(git config --file .gitmodules --get-regexp '\.path$')

out=web/build
rm -rf "$out"
mkdir -p "$out"

# build <slug> <title> <width> <height> <source> [extra em++ flags...]
build() {
  local slug=$1 title=$2 width=$3 height=$4 source=$5
  shift 5
  local shell
  shell=$(mktemp --suffix=.html)
  sed -e "s|@SLUG@|$slug|g" -e "s|@TITLE@|$title|g" \
      -e "s|@WIDTH@|$width|g" -e "s|@HEIGHT@|$height|g" web/shell.html > "$shell"
  em++ -O2 -include web/frame.h "$source" \
    -sUSE_SDL=2 -sASYNCIFY -sALLOW_MEMORY_GROWTH "$@" \
    --shell-file "$shell" \
    -o "$out/$slug.html"
  rm -f "$shell"
}

build controllable-rectangle "Controllable Rectangle" 1000 700 \
  sketches/controllable-rectangle/controllableRectangle.cpp
build rectangle-changing-size "Rectangle Changing Size" 640 480 \
  sketches/rectangle-changing-size/rectangle_changing_size.cpp
# bouncingCube.cpp initializes SDL_image (for PNG) although it loads no image
build bouncing-rectangle "Bouncing Rectangle" 640 480 \
  sketches/bouncing-rectangle/bouncingCube.cpp \
  -sUSE_SDL_IMAGE=2 -sSDL2_IMAGE_FORMATS='["png"]'

cp web/index.html "$out/index.html"

echo "Built $out:"
ls -l "$out"
