#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"

source tools.tcl

set object .wbuilder
catch {Classy::WindowBuilder destroy}
Classy::WindowBuilder .wbuilder
.wbuilder open lib/dialogs/tdialog.tcl
#.wbuilder open lib/dialogs/settingsdialog.tcl
#.wbuilder open lib/dialogs/t2.tcl
#.wbuilder save lib/dialogs/t1.tcl
#.wbuilder save lib/dialogs/t2.tcl

set dst .wbuilder.work.actions.b2
