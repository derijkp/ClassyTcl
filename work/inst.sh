#!/bin/sh

# $Format: "export version=$ProjectMajorVersion$.$ProjectMinorVersion$.$ProjectPatchLevel$"$
export version=1.0.2

# full compile and install linux
cd /home/peter/dev/ClassyTcl/Linux-i686
make distclean
../configure --prefix=/home/peter/tcl/dirtcl
make
rm -rf /home/peter/build/tca/Linux-i686/exts/Class$version/
/home/peter/dev/ClassyTcl/build/install.tcl /home/peter/build/tca/Linux-i686/exts

# full cross-compile and install windows
cd /home/peter/dev/ClassyTcl/windows-intel
make distclean
cross-bconfigure.sh --prefix=/home/peter/tcl/win-dirtcl
cross-make.sh
rm -rf /home/peter/build/tca/Windows-intel/exts/Class$version/
wine /home/peter/build/tca/Windows-intel/tclsh84.exe /home/peter/dev/ClassyTcl/build/install.tcl /home/peter/build/tca/Windows-intel/exts

/home/peter/dev/ClassyTcl/build/version.tcl
