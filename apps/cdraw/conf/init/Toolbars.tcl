#Application tool configuration file

Classy::configtool MainTool {Application main toolbar} {	action open "Open" {fileload %W}
	action save "Save" {filesave %W}
	action print "Print" {%W print}
	action undo "Undo" {%W undo}
	action redo "redo" {%W redo}
	separator
	action copy "Copy" {%W copy _sel}
	action cut "Cut" {%W cut _sel}
	action paste "Paste" {%W paste}
	separator
	tool selecttool "Select"
	tool rotatetool "Rotate"
	tool zoomtool "Set zoom"
	tool texttool "Text"
	tool linetool "Line"
	tool polytool "Polygon"
	tool recttool "Rectangle"
	tool ovaltool "Oval"
	tool arctool "Arc"
	separator
	action raiseobj "Raise objects" {raise_objects %W _sel}
	action lowerobj "Lower objects" {lower_objects %W _sel}




}








