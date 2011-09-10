#!/bin/bash -x
# setup-ec2.sh
cd $HOME
command -v git || sudo yum -y install git
[ -e dotfiles ] || git clone https://secelis@github.com/secelis/dotfiles.git
[ -e sussex-thesis ] || git clone https://secelis@github.com/secelis/sussex-thesis.git
[ -e alps ] || git clone https://secelis@github.com/secelis/alps.git

command -v gcc    || sudo yum -y install gcc-c++
command -v make   || sudo yum -y install make
command -v emacs  || sudo yum -y install emacs
command -v patch  || sudo yum -y install patch
command -v screen || sudo yum -y install screen

pushd dotfiles/ && git submodule update --init && ./relink -f install; popd
pushd alps/ && ./configure && make && sudo make install; popd
pushd sussex-thesis/src && make; popd
