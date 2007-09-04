#!/bin/sh
# the next line restarts using wish \
exec tclsh "$0" "$@"

source tools.tcl
lappend auto_path autoload_test

catch {Test destroy}
set temp [Test new]





# - 4240
# 2416 4952
Class subclass Test
time {
for {set i 0} {$i < 10000} {incr i} {
	Test new
}
}

test class {changeclass} {
	clean
	Class subclass Test
	Test subclass STest
	Test method amethod {} {
		return Test
	}
	STest method amethod {} {
		return STest
	}
	set object [Test new]
	set result [$object amethod]
	$object changeclass STest
	lappend result [$object amethod]
} {Test STest}

# quick install
rm -rf /home/peter/build/tca/Linux-i686/exts/Class1.0.1/
/home/peter/dev/ClassyTcl/build/install.tcl /home/peter/build/tca/Linux-i686/exts

# full compile and install linux
cd /home/peter/dev/ClassyTcl/Linux-i686
make distclean
../configure --prefix=/home/peter/tcl/dirtcl
make
rm -rf /home/peter/build/tca/Linux-i686/exts/Class1.0.1/
/home/peter/dev/ClassyTcl/build/install.tcl /home/peter/build/tca/Linux-i686/exts

# full cross-compile and install windows
cd /home/peter/dev/ClassyTcl/windows-intel
make distclean
cross-bconfigure.sh --prefix=/home/peter/tcl/win-dirtcl
cross-make.sh
rm -rf /home/peter/build/tca/Windows-intel/exts/Class1.0.1/
wine /home/peter/build/tca/Windows-intel/tclsh84.exe /home/peter/dev/ClassyTcl/build/install.tcl /home/peter/build/tca/Windows-intel/exts

