#!/bin/bash

mkdir ~/.vim/bundle
cd ~/.vim/bundle/
git clone https://github.com/tpope/vim-pathogen.git
git clone https://github.com/airblade/vim-gitgutter.git
git clone https://github.com/plasticboy/vim-markdown.git
git clone http://git.devnull.li/ikiwiki-syntax.git
cd -

