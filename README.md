# Purpose
 - Experimental game to integrate with system 1 AI models

# How to run
 - `sbcl --script start.lisp`

# Lint syntax errors
 - `sbcl --script lint.lisp`

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

# Note to self
 - Maybe we need to plan for making a default dynamic library search paths
    - NCurses example:
```bash
sbcl --eval '(require :asdf)' \
     --eval '(asdf:load-system :my-ncurses-app)' \
     --eval '(sb-ext:save-lisp-and-die "my_app" :executable t :toplevel '"'"'my-app:main)'
```
```lisp
;; Let CFFI look for the platform-appropriate dynamic file at runtime
(cffi:define-foreign-library ncurses
  (:windows "libncursesw.dll")
  (:unix (:or "libncursesw.so.6" "libncursesw.so.5")))

(cffi:use-foreign-library ncurses)
```
