#!/bin/bash

if [ ! `id -un` = 'root' ]; then
  printf "You need to run this as root.\n"
  exit 1
fi

# if [ ! -f /etc/slackware-version ]; then
#   printf "This is intended for slackware.\n"
#   exit 1
# fi

updatedb &

useradd -d /home/blharris -m -g users -G audio,cdrom,floppy,plugdev,video,power,netdev,lp,scanner,wheel -s /bin/bash blharris
chfn -f 'Bryan Harris' blharris
passwd blharris
chmod 711 /home/blharris

cp -a vimrc /home/blharris/.vimrc
cp -a vim /home/blharris/.vim
cp gitconfig /home/blharris/.gitconfig
cp bash_profile /home/blharris/.bash_profile
cp Xresources /home/blharris/.Xresources
chown -R blharris: /home/blharris
ln -s .bash_profile /home/blharris/.bashrc

cp -a vimrc ~/.vimrc
cp -a vim ~/.vim
cp gitconfig ~/.gitconfig
cp bash_profile ~/.bash_profile
cp Xresources ~/.Xresources
chown -R root: /root
ln -s .bash_profile /root/.bashrc

wait
