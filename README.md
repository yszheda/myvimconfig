# Myvimconfig

The common vim configuration that I used.
It is mainly used under Linux, but it also works fine for windows gvim.

##Usage##

#Install#
```bash
git clone https://github.com/yszheda/myvimconfig.git ~/.vim
ln -s ~/.vim/vimrc ~/.vimrc
cd ~/.vim
git submodule init
git submodule update
```

#Update All the Plugins#
```bash
git submodule foreach git pull origin master
```

#Delete Plugin#
```bash
git rm bundle/<plugin-name>
```
