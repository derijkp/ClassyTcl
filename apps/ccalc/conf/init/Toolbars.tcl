#Application tool configuration file

Classy::configtool MainTool {Application main toolbar} {
	action open "Open" {error "cannot load \"[Classy::selectfile -title Open -selectmode persistent]\" yet"}
	action save "Save" {error "saving not implemented yet"}
	action print "Print" {error "print not implemented yet"}
	action undo "Undo" {error "undo not implemented yet"}
	action redo "redo" {error "redo not implemented yet"}
	separator
	action copy "Copy" {error "copy not implemented yet"}
	action cut "Cut" {error "cut not implemented yet"}
	action paste "Paste" {error "paste not implemented yet"}
	separator



}


