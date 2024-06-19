rm -rf dotfiles
cp -r tocopy dotfiles
chown --recursive 1000:1000 dotfiles
dotfiles/make.sh docker
