#!/bin/bash

if test $# -ne 2; then
  echo "Usage: $0 branch folder"
  echo "Example: $0 master dev"
  exit 0
fi

rep='/tmp/update_docs_bottle.git'
dst="/var/www/bottle/docs/$2"
branch=$1

test -d $rep || git clone git://github.com/defnull/bottle.git $rep
cd $rep
git fetch origin
git checkout -b temp "origin/$branch"
git clean -d -x -f

test -f docs/index.rst && cd docs || cd apidoc
make html && make latex
cd ../build/docs

cd latex
make all-pdf > /dev/null
cd ..

cp latex/Bottle.pdf bottle-docs.pdf
tar -czf bottle-docs.tar.gz html
tar -cjf bottle-docs.tar.bz2 html
zip -q -r -9 bottle-docs.zip html
cp bottle-docs.* html

rsync -vrc html/ $dst

cd $rep
git checkout master
git branch -D temp
git clean -d -x -f

