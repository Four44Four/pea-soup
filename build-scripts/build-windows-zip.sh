#!/bin/bash

set -e

ZIP_BASENAME="pea-soup-windows-x64.zip"
PDCURSES_VER="3.9"
SDL2_VER="2.32.2"
SDL2_MIXER_VER="2.8.2"
ALACRITTY_VER="v0.16.0"

mkdir -p "$WINEPREFIX/drive_c/quicklisp/local-projects/pea-soup"
cp -r /workspace/* "$WINEPREFIX/drive_c/quicklisp/local-projects/pea-soup/"
mkdir -p /tmp/dist_win/libs/



# echo "Building PDCurses library..."
# curl -Lo /tmp/pdcurses.tar.gz "https://github.com/wmcbrine/PDCurses/archive/refs/tags/$PDCURSES_VER.tar.gz"
# tar -xvf /tmp/pdcurses.tar.gz -C /tmp/
# cd "/tmp/PDCurses-$PDCURSES_VER/wincon"
# CFLAGS="-DPDC_RGB" make -f Makefile CC=x86_64-w64-mingw32-gcc LINK=x86_64-w64-mingw32-gcc AR=x86_64-w64-mingw32-ar WINDRES=x86_64-w64-mingw32-windres WIDE=Y DLL=Y
# cp pdcurses.dll /tmp/dist_win/libs/pdcurses.dll
# mkdir -p /tmp/pdcurses-include/ncursesw
# cp "/tmp/PDCurses-$PDCURSES_VER/curses.h" /tmp/pdcurses-include/ncursesw/ncurses.h
# cp "/tmp/PDCurses-$PDCURSES_VER/curses.h" /tmp/pdcurses-include/curses.h
# cp "/tmp/PDCurses-$PDCURSES_VER/curses.h" /tmp/pdcurses-include/pdcurses.h
# export C_INCLUDE_PATH="/tmp/pdcurses-include"

# cp /opt/libncursesw6.dll /tmp/dist_win/libs/libncursesw6.dll
# cp /opt/mingw_win/mingw64/bin/libgcc_s_*.dll /tmp/dist_win/libs/  2>/dev/null || true
# cp /opt/mingw_win/mingw64/bin/libwinpthread-*.dll /tmp/dist_win/libs/  2>/dev/null || true

# mkdir -p /tmp/dist_win/resources/terminfo/61/ /tmp/dist_win/resources/terminfo/78/
# cp /opt/terminfo/alacritty /tmp/dist_win/resources/terminfo/61/
# cp /opt/terminfo/xterm-256color /tmp/dist_win/resources/terminfo/78/

cp /opt/libpdcurses.so /tmp/dist_win/libs/libpdcurses.dll

echo "Downloading other dependencies (SDL2, SDL2 Mixer, Alacritty)"
curl -Lo /tmp/sdl2.zip "https://github.com/libsdl-org/SDL/releases/download/release-$SDL2_VER/SDL2-$SDL2_VER-win32-x64.zip"
unzip -q /tmp/sdl2.zip -d /tmp/sdl2_ext
cp /tmp/sdl2_ext/SDL2.dll /tmp/dist_win/libs

curl -Lo /tmp/sdl2_mixer.zip "https://github.com/libsdl-org/SDL_mixer/releases/download/release-$SDL2_MIXER_VER/SDL2_mixer-$SDL2_MIXER_VER-win32-x64.zip"
unzip -q /tmp/sdl2_mixer.zip -d /tmp/sdl2_mixer_ext
cp /tmp/sdl2_mixer_ext/SDL2_mixer.dll /tmp/dist_win/libs/

curl -Lo /tmp/dist_win/alacritty.exe "https://github.com/alacritty/alacritty/releases/download/$ALACRITTY_VER/Alacritty-$ALACRITTY_VER-portable.exe"


export WINEPATH="Z:\\tmp\\dist_win\\libs;Z:\\opt\\mingw_win\\mingw64\\bin"

# IMPORTANT: must apply the icon BEFORE lisp image dumping and compressing (it will corrupt the executable if edited post-compression)
echo "Applying app icon..."
if [ -f /workspace/resources/pea-soup.ico ]; then
  wine /opt/rcedit.exe "$WINEPREFIX/drive_c/Program Files/Steel Bank Common Lisp/sbcl.exe" --set-icon "Z:\\workspace\\resources\\pea-soup.ico"
  wine /opt/rcedit.exe "Z:\\tmp\\dist_win\\alacritty.exe" --set-icon "Z:\\workspace\\resources\\pea-soup.ico"
else
  echo "Error: pea-soup.ico not found"
fi

echo "Building executable..."
wine "C:\\Program Files\\Steel Bank Common Lisp\\sbcl.exe" \
  --core "C:\\Program Files\\Steel Bank Common Lisp\\sbcl.core" \
  --load "C:\\quicklisp\\setup.lisp" \
  --eval '(require :asdf)' \
  --eval '(pushnew :pdcurses *features*)' \
  --eval '(pushnew :windows *features*)' \
  --eval '(ql:quickload :cffi-grovel)' \
  --eval '(setf cffi-grovel::*cc* "gcc.exe")' \
  --eval '(setf cffi-grovel::*cc-flags* (append cffi-grovel::*cc-flags* (list "-IZ:\\opt\\pdcursesmod-include")))' \
  --eval '(ql:quickload :pea-soup)' \
  --eval '(sb-ext:save-lisp-and-die "C:\\pea-soup.exe" :toplevel (function pea-soup:main) :executable t :compression t)' \
  --quit

echo "Creating ZIP package..."
mkdir -p /tmp/dist_win/libs /tmp/dist_win/resources
cp "$WINEPREFIX/drive_c/pea-soup.exe" /tmp/dist_win/

if [ -d /workspace/resources ]; then
  cp -r /workspace/resources/* /tmp/dist_win/resources/;
fi
if [ -f /workspace/pea-soup.png ]; then
  cp /workspace/pea-soup.png /tmp/dist_win/;
else
  touch /tmp/dist_win/pea-soup.png;
fi

echo "Creating launcher stub..."
cat << 'EOF' > /tmp/launcher.c
#include <windows.h>
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
  char oldPath[4096];
  GetEnvironmentVariableA("PATH", oldPath, sizeof(oldPath));
  char newPath[8192];
  wsprintfA(newPath, "libs;.;%s", oldPath);
  SetEnvironmentVariableA("PATH", newPath);
  SetEnvironmentVariableA("PDC_VT", "RGB UNDERLINE BLINK DIM STANDOUT");
  STARTUPINFOA si;
  PROCESS_INFORMATION pi;
  ZeroMemory(&si, sizeof(si));
  si.cb = sizeof(si);
  ZeroMemory(&pi, sizeof(pi));
  char cmd[] = "alacritty.exe -e pea-soup.exe";
  if (CreateProcessA(NULL, cmd, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi)) {
      CloseHandle(pi.hProcess);
      CloseHandle(pi.hThread);
  }
  return 0;
}
EOF
x86_64-w64-mingw32-gcc /tmp/launcher.c -o /tmp/dist_win/PeaSoupLauncher.exe -mwindows
if [ -f /workspace/resources/pea-soup.ico ]; then
  wine /opt/rcedit.exe "Z:\\tmp\\dist_win\\PeaSoupLauncher.exe" --set-icon "Z:\\workspace\\resources\\pea-soup.ico"
fi

echo "Finising up creating ZIP package..."
mkdir -p /workspace/dist
cd /tmp/dist_win
zip -r /workspace/dist/$ZIP_BASENAME ./

echo "Finished creating ZIP package for Windows"
