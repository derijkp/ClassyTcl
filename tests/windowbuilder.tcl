#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

set object .wbuilder
catch {Classy::WindowBuilder destroy}
Classy::WindowBuilder .wbuilder
.wbuilder open lib/dialogs/t2.tcl
.wbuilder save lib/dialogs/t1.tcl
.wbuilder save lib/dialogs/t2.tcl
