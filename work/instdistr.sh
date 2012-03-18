#!/bin/sh

/home/peter/dev/ClassyTcl/build/version.tcl

# $Format: "export version=$ProjectMajorVersion$.$ProjectMinorVersion$.$ProjectPatchLevel$"$
export version=1.0.2

# sources
cd /home/peter/dev/ClassyTcl
rs ~/dev/ClassyTcl ~/net/prog-classytcl/
rm -rf ~/net/prog-classytcl/ClassyTcl/work
cd ~/net/prog-classytcl
tar cvzf ClassyTcl-$version.src.tar.gz ClassyTcl

# linux
cd /home/peter/build/tca/Linux-i686/exts/
tar cvzf ~/net/prog-classytcl/ClassyTcl-$version-Linux-i686.tar.gz Class$version pkgtools0.9.0

cd /home/peter/build/tca/Linux-x86_64/exts/
tar cvzf ~/net/prog-classytcl/ClassyTcl-$version-Linux-x86_64.tar.gz Class$version pkgtools0.9.0

# windows
cd /home/peter/build/tca/Windows-intel/exts/
rm ~/net/prog-classytcl/ClassyTcl-$version-Windows-intel.zip
zip -r ~/net/prog-classytcl/ClassyTcl-$version-Windows-intel.zip Class$version pkgtools0.9.0

# docs to net
rs /home/peter/dev/ClassyTcl/help/* ~/net/www-classytcl/htdocs/doc/

cd /home/peter/dev/ClassyTcl

echo "
# to upload
ssh -t derijkp,classytcl@shell.sourceforge.net create
rsync -v -e ssh ~/net/prog-classytcl/ClassyTcl-$version-* derijkp,classytcl@frs.sourceforge.net:/home/frs/project/c/cl/classytcl
"
