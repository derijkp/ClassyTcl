source testapp.tcl
Classy::Builder .builder

set file /home/peter/dev/ClassyTcl/tests/testapp/lib/interface/mainw.tcl
set function mainw
set type toplevel

set object .builder
$object _creatededit $object.dedit

$object.dedit open $file



source tools.tcl

set file temp.descr
set file ../conf/conf.descr
Classy::config_edit $file

Classy::config_edit_getdef {}

Classy::config_edit_pos {Menus ClassyTcl}
Classy::config_edit_pos {Menus ClassyTcl Help}
Classy::config_edit_pos {Menus ClassyTcl {}}

Classy::config_dialog

Classy::config_dialog {Colors {Basic colors} Foreground}

set pos {Menus ClassyTcl {}}
