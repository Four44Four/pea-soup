# Purpose
 - Experimental game to integrate with system 1 AI models

# How to run with custom terminal (on Linux)
 - `PEA_SOUP_TERMINAL="<path-to-terminal-emulator-or-name-of-terminal-emulator>" ./<pea-soup-appimage-name>.AppImage`

# How to run (development)
 - `sbcl --script start.lisp`

# Lint syntax errors
 - `sbcl --script lint.lisp`

# Build
 - Artifacts will go in `./dist/`
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
## Windows
 - `./build-scripts/windows.sh`
