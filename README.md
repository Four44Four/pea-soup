# Purpose
 - Experimental game to integrate with system 1 AI models

# How to run with custom terminal (on Linux)
 - `PEA_SOUP_TERMINAL="<path-to-terminal-emulator-or-name-of-terminal-emulator>" ./<pea-soup-appimage-name>.AppImage`

# How to run (development)
 - `sbcl --script start.lisp`

# Lint syntax errors
 - `sbcl --script lint.lisp`

# Build
## Linux
 - Production:
    - `./build-scripts/linux.sh`
 - Test build cmd:
```bash
sbcl --eval '(require :asdf)' \
     --eval '(load "~/quicklisp/setup.lisp")' \
     --eval '(push (uiop:getcwd) asdf:*central-registry*)' \
     --eval '(ql:quickload :pea-soup)' \
     --eval '(sb-ext:save-lisp-and-die "pea-soup" :toplevel (function pea-soup:main) :executable t)'
```

# External dependencies (package these when distributing binaries later)
 - `sdl2`
    - On Linux: Use a packaging build Docker container with `libsdl2`
    - On Windows: Use a specific binary from https://github.com/libsdl-org/SDL/releases
 - `sdl2_mixer`
    - On Linux: Use a packaging build Docker container with `libSDL2_mixer`
    - On Windows: Use a specific binary from https://github.com/libsdl-org/SDL_mixer/releases
 - `ncurses`
     - On Linux: Use a packaging build Docker container with `libncursesw`
     - On Windows: Use [Project Pluto's `PDCursesMod`](https://www.projectpluto.com/win32a.htm)
