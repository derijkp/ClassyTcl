#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"

source tools.tcl

proc alltest file {
	global currenttest
	set currenttest $file
	puts "-----------------------------------------------------"
	puts "Test file $file"
	puts "-----------------------------------------------------"
	uplevel #0 source $file
}

alltest class.tcl
alltest widget.tcl
alltest balloon.tcl
alltest browser.tcl
alltest canvas.tcl
alltest chart.tcl
alltest cmd.tcl
alltest color.tcl
alltest config.tcl
alltest default.tcl
alltest dialog.tcl
alltest dragdrop.tcl
alltest dynamenu.tcl
alltest dynatool.tcl
alltest editor.tcl
alltest entry.tcl
alltest html.tcl
alltest notebook.tcl
alltest numentry.tcl
alltest selector.tcl
alltest table.tcl
alltest text.tcl
alltest toplevel.tcl
alltest tree.tcl
alltest treewidget.tcl
alltest varia.tcl
