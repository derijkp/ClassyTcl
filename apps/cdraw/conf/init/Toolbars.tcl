#Application tool configuration file

Classy::configtool MainTool {Application main toolbar} {
	action open "Open" {load}
	action save "Save" {save}
	action print "Print" {error "print not implemented yet"}
	action undo "Undo" {%W undo}
	action redo "redo" {%W redo}
	separator
	action copy "Copy" {error "copy not implemented yet"}
	action cut "Cut" {error "cut not implemented yet"}
	action paste "Paste" {error "paste not implemented yet"}
	separator





}






