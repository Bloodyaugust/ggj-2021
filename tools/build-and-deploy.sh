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
godot --export "Linux/X11" build/linux/ggj-2021.x86_64 -v
echo "EXPORTING FOR OSX"
echo "-----------------------------"
godot --export "Mac OSX" build/osx/ggj-2021.dmg -v
echo "EXPORTING FOR WINDOZE"
echo "-----------------------------"
godot --export-debug "Windows Desktop" build/win/ggj-2021.exe -v
echo "-----------------------------"

echo "CHANGING FILETYPE AND CHMOD EXECUTABLE FOR OSX"
echo "-----------------------------"
cd build/osx/
mv ggj-2021.dmg ggj-2021-osx-alpha.zip
unzip ggj-2021-osx-alpha.zip
rm ggj-2021-osx-alpha.zip
chmod +x ggj-2021.app/Contents/MacOS/ggj-2021
zip -r ggj-2021-osx-alpha.zip ggj-2021.app
rm -rf ggj-2021.app
cd ../../

ls -al
ls -al build/
ls -al build/linux/
ls -al build/osx/
ls -al build/win/

echo "ZIPPING FOR WINDOZE"
echo "-----------------------------"
cd build/win/
zip -r ggj-2021-win-alpha.zip ggj-2021.exe ggj-2021.pck
rm -r ggj-2021.exe ggj-2021.pck
cd ../../

echo "ZIPPING FOR LINUX"
echo "-----------------------------"
cd build/linux/
zip -r ggj-2021-linux-alpha.zip ggj-2021.x86_64 ggj-2021.pck
rm -r ggj-2021.x86_64 ggj-2021.pck
cd ../../

echo "Logging in to Butler"
echo "-----------------------------"
butler login

echo "Pushing builds with Butler"
echo "-----------------------------"
butler push build/linux/ synsugarstudio/ggj-2021:linux-alpha
butler push build/osx/ synsugarstudio/ggj-2021:osx-alpha
butler push build/win/ synsugarstudio/ggj-2021:win-alpha

# echo "Deploying server"
# echo "-----------------------------"
# cd server/
# yarn install
# yarn pm2 deploy ecosystem.config.js production
