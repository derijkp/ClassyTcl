#ClassyTcl tool configuration file

Classy::configtool Classy::Editor {Editor toolbar} {
	action save "Save" {%W save}
	action open "Open" {eval %W load [Classy::selectfile -title Open -selectmode persistent]}
	action undo "Undo" {%W undo}
	action redo "redo" {%W redo}
	separator
	action print "Print" {%W insert insert "Print: %W"}
	action open "Open next" {%W next}
}
Classy::configtool Classy::Help {Help toolbar} {
	action reload "Reload" {%W reload}
	action back "Back" {%W back}
	action forward "Forward" {%W forward}
	action edit "Edit" {%W edit}
	widget Classy::findhelp "Find" 
	radio Word "Find word" {-variable ::Classy::helpfind -value word}
	radio File "Find file" {-variable ::Classy::helpfind -value file}
	radio Infile "Find in file" {-variable ::Classy::helpfind -value grep}
}

Classy::configtool Classy::Builder {toolbar used in the ClassyTcl Builder} {
	action newfile "New file" {%W new file}
	action newdialog "New Dialog" {%W new dialog}
	action newtoplevel "New Toplevel" {%W new toplevel}
	action newfunction "New function" {%W new function}
	action save "Save" {%W save}
	separator
	action copy "Copy" {%W copy}
	action cut "Cut" {%W cut}
	action paste "Paste" {%W paste}
	separator
}

Classy::configtool Classy::WindowBuilder {toolbar used in the ClassyTcl WindowBuilder} {
	action cut "Delete" {%W delete}
	separator
	action edit "Edit" {%W edit}
	action test "Test" {%W restore}
	action recreate "Recreate Dialog" {%W recreate}
	separator
	action close "Close" {destroy %W}
}

