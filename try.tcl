source tools.tcl
set object .try
Classy_printdialog .try -command {invoke {} {puts $args}}

$object.options.paper.select configure -value
.try configure -printsize A4
.try configure -portrait 0

set d .classy__.printdialog
test Classy::Canvas {print dialog} {
	classyclean
	Classy::Canvas .try
	.try configure -papersize A4
	pack .try -fill both -expand yes
	set id [.try create text 10 10 -text "A"]
	.try create text 50 50 -text "B" -font {times 14 bold}
	.try create line 20 10 60 50 -width 4
	.try itemconfigure $id -text
	.try configure -papersize A5-l
	.try print
	manualtest
} {}

Classy::Builder .builder
.builder configure -dir /home/peter/dev/ClassyTcl/dialogs

set file /home/peter/dev/ClassyTcl/tests/testapp/lib/interface/mainw.tcl
set function mainw
set type toplevel
set object .builder
$object _creatededit $object.dedit
$object.dedit open $file

set pos {Menus Application MainMenu}
set key MainMenu
set descr {description of menu}

source tools.tcl

set file temp.descr
set file ../conf/conf.descr
Classy::config_edit $file

Classy::config_edit_getdef {}

Classy::config_edit_pos {Menus ClassyTcl}
Classy::config_edit_pos {Menus ClassyTcl Help}
Classy::config_edit_pos {Menus ClassyTcl {}}

Classy::config_dialog
Classy::config_gotokey menu,Classy_Editor
set key menu,Classy_Editor

Classy::config_dialog {Colors {Basic colors} Foreground}

set pos {Menus ClassyTcl {}}
