#!/bin/bash

set -e

APPIMAGE_BASENAME="pea-soup-linux-x86_64.AppImage"
QL_LOCAL_PROJECT_PATH="/root/quicklisp/local-projects"
ALACRITTY_VER="v0.16.0"

mkdir -p "$QL_LOCAL_PROJECT_PATH"
cp -r /workspace/. "$QL_LOCAL_PROJECT_PATH/pea-soup"

echo 'Building executable...'
sbcl --eval '(require :asdf)' \
     --eval '(ql:quickload :pea-soup)' \
     --eval '(sb-ext:save-lisp-and-die "/tmp/pea-soup" :toplevel (function pea-soup:main) :executable t :compression t)'

echo 'Creating AppDir...'
mkdir -p /tmp/AppDir/usr/bin \
         /tmp/AppDir/usr/lib \
         /tmp/AppDir/resources
cp /tmp/pea-soup /tmp/AppDir/usr/bin
if [ -d /workspace/resources ]; then
  cp -r /workspace/resources/* /tmp/AppDir/resources;
fi
if [ -f /workspace/pea-soup.png ]; then
  cp /workspace/pea-soup.png /tmp/AppDir/;
else \
  touch /tmp/AppDir/pea-soup.png;
fi
# copy the shared libraries' binaries
cp /usr/lib/x86_64-linux-gnu/libSDL2-2.0.so.0 /tmp/AppDir/usr/lib/libSDL2.so
cp /usr/lib/x86_64-linux-gnu/libSDL2_mixer-2.0.so.0 /tmp/AppDir/usr/lib/libSDL2_mixer.so
cp /lib/x86_64-linux-gnu/libncursesw.so.6 /tmp/AppDir/usr/lib/libncursesw.so


echo "Compiling Alacritty $ALACRITTY_VER..."
apt-get update && apt-get install -y \
    cmake \
    pkg-config \
    libfreetype6-dev \
    libfontconfig1-dev \
    libxcb-xfixes0-dev \
    libxkbcommon-dev \
    python3
echo 'Installing Rust toolchain...'
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"
mkdir -p /tmp/alacritty-src
cd /tmp/alacritty-src
git clone --depth 1 --branch "$ALACRITTY_VER" https://github.com/alacritty/alacritty.git .
cargo build --release
cp target/release/alacritty /tmp/AppDir/usr/bin/


echo 'Creating entrypoint files...'
cat << 'EOF' > /tmp/AppDir/AppRun
#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"
export LD_LIBRARY_PATH="$HERE/usr/lib:$LD_LIBRARY_PATH"
TERMINAL_EXEC="${PEA_SOUP_TERMINAL:-$HERE/usr/bin/alacritty}"
exec "$TERMINAL_EXEC" -e "$HERE/usr/bin/pea-soup"
EOF

chmod +x /tmp/AppDir/AppRun
cat << 'EOF' > /tmp/AppDir/pea-soup.desktop
[Desktop Entry]
Name=Pea Soup
Exec=pea-soup
Icon=pea-soup
Type=Application
Categories=Game;
Comment=Unfortunate lab accident resulted in this...
EOF

echo 'Generating final AppImage...'
mkdir -p /workspace/dist
ARCH=x86_64 /usr/local/bin/appimagetool-no-fuse /tmp/AppDir "/workspace/dist/$APPIMAGE_BASENAME"

echo 'Finished creating AppImage.'
