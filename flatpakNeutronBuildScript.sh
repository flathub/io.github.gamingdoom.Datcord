#!/bin/bash

mozbuild=~/.mozbuild
export PATH="$PATH:$mozbuild/git-cinnabar"
rootDir=$PWD

if [ ! -d $mozbuild ]; then
  mkdir $mozbuild
fi

if [ ! -d mozilla-unified ]; then
  mkdir mozilla-unified
  curl https://hg.mozilla.org/mozilla-central/raw-file/default/python/mozboot/bin/bootstrap.py -O
  python3 bootstrap.py --vcs=git --no-interactive --application-choice=browser_artifact_mode
fi

if [ ! -d $mozbuild/git-cinnabar ]; then
  git clone https://github.com/glandium/git-cinnabar.git $mozbuild/git-cinnabar
  cd $mozbuild/git-cinnabar
  make
  cd $rootDir
fi	

cd mozilla-unified
cp -r ../src/changed/* .
cp ../src/mozconfig.linux mozconfig
patch -N -p1 < ../src/mozilla_dirsFromLibreWolf.patch

./mach configure --without-wasm-sandboxed-libraries
./mach build
./mach package

cd ..
