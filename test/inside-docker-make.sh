git="$( which git )"
sudo "${git}" clone tocopy dotfiles
sudo chown --recursive 1000:1000 dotfiles
rm .bashrc .profile
dotfiles/make.sh docker
