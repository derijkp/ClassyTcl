#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" "$@"

package require pkgtools
package require Extral

set srcdir [file dir [pkgtools::startdir]]
putsvars srcdir
exit
cd $srcdir

# settings
# --------

# make docs
# ---------
file mkdir $srcdir/docs/cmds
Extral::makedoc [glob -nocomplain $srcdir/lib/*.tcl] $srcdir/docs/cmds
file rename -force $srcdir/docs/cmds/Class.html $srcdir/docs/Class.html
file delete force $srcdir/docs/cmds

# standard
# --------
pkgtools::makedoc



