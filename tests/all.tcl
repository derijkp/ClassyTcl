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
alltest entry.tcl
alltest numentry.tcl
alltest notebook.tcl
alltest dynamenu.tcl
alltest dynatool.tcl
alltest default.tcl
alltest dialog.tcl
alltest color.tcl
alltest table.tcl
alltest text.tcl
alltest canvas.tcl
alltest balloon.tcl
alltest browser.tcl
alltest chart.tcl
alltest cmd.tcl
alltest config.tcl
alltest editor.tcl
alltest tree.tcl
alltest varia.tcl
alltest html.tcl
