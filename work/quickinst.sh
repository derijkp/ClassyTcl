#!/bin/sh

# $Format: "export version=$ProjectMajorVersion$.$ProjectMinorVersion$.$ProjectPatchLevel$"$
export version=1.0.2

# quick install
#!/bin/sh

# $Format: "export version=$ProjectMajorVersion$.$ProjectMinorVersion$.$ProjectPatchLevel$"$
export version=1.0.2

# quick install linux
cd /home/peter/dev/ClassyTcl/Linux-i686
rm -rf /home/peter/build/tca/Linux-i686/exts/Class$version/
/home/peter/dev/ClassyTcl/build/install.tcl /home/peter/build/tca/Linux-i686/exts

# quick install windows
cd /home/peter/dev/ClassyTcl/windows-intel
rm -rf /home/peter/build/tca/Windows-intel/exts/Class$version/
wine /home/peter/build/tca/Windows-intel/tclsh84.exe /home/peter/dev/ClassyTcl/build/install.tcl /home/peter/build/tca/Windows-intel/exts

/home/peter/dev/ClassyTcl/build/version.tcl
