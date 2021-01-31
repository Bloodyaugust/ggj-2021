#!/bin/bash

# set -e

source ~/.bashrc

which butler

echo "Checking application versions..."
echo "-----------------------------"
cat ~/.local/share/godot/templates/3.2.stable/version.txt
godot --version
butler -V
echo "-----------------------------"

mkdir build/
mkdir build/linux/
mkdir build/osx/
mkdir build/win/

echo "EXPORTING FOR LINUX"
echo "-----------------------------"
godot --export "Linux/X11" build/linux/sm4rt.x86_64 -v
echo "EXPORTING FOR OSX"
echo "-----------------------------"
godot --export "Mac OSX" build/osx/sm4rt.dmg -v
echo "EXPORTING FOR WINDOZE"
echo "-----------------------------"
godot --export-debug "Windows Desktop" build/win/sm4rt.exe -v
echo "-----------------------------"

echo "CHANGING FILETYPE AND CHMOD EXECUTABLE FOR OSX"
echo "-----------------------------"
cd build/osx/
mv sm4rt.dmg sm4rt-osx-alpha.zip
unzip sm4rt-osx-alpha.zip
rm sm4rt-osx-alpha.zip
chmod +x sm4rt.app/Contents/MacOS/sm4rt
zip -r sm4rt-osx-alpha.zip sm4rt.app
rm -rf sm4rt.app
cd ../../

ls -al
ls -al build/
ls -al build/linux/
ls -al build/osx/
ls -al build/win/

echo "ZIPPING FOR WINDOZE"
echo "-----------------------------"
cd build/win/
zip -r sm4rt-win-alpha.zip sm4rt.exe sm4rt.pck
rm -r sm4rt.exe sm4rt.pck
cd ../../

echo "ZIPPING FOR LINUX"
echo "-----------------------------"
cd build/linux/
zip -r sm4rt-linux-alpha.zip sm4rt.x86_64 sm4rt.pck
rm -r sm4rt.x86_64 sm4rt.pck
cd ../../

echo "Logging in to Butler"
echo "-----------------------------"
butler login

echo "Pushing builds with Butler"
echo "-----------------------------"
butler push build/linux/ synsugarstudio/sm4rt:linux-alpha
butler push build/osx/ synsugarstudio/sm4rt:osx-alpha
butler push build/win/ synsugarstudio/sm4rt:win-alpha

# echo "Deploying server"
# echo "-----------------------------"
# cd server/
# yarn install
# yarn pm2 deploy ecosystem.config.js production
