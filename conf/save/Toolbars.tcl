## Editor {Editor toolbar} tool
option add *Classy::Editor*Toolbar {
	action floppy "Save" {%W save}
	action open "Open" {%W open}
	action undo "Undo" {%W undo}
	action redo "redo" {%W redo}
	separator
	action print "Print" {%W insert insert "Print: %W"}
	action open "Open next" {%W next}
} widgetDefault