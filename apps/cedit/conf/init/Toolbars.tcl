#Application tool configuration file

Classy::configtool Classy::Editor {Editor toolbar} {
	nodisplay
	action save "Save" {%W save}
	action open "Open" {eval %W load [Classy::selectfile -title Open -selectmode persistent]}
	action undo "Undo" {%W undo}
	action redo "redo" {%W redo}
	separator
	action print "Print" {%W insert insert "Print: %W"}
	action open "Open next" {%W next}
}

