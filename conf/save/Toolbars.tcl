## {Show Editor Toolbar} {Do you want ClassyTcl Editor to have toolbars} {select 0 1}
option add *Classy::Editor.ShowTool 1 widgetDefault
## {Editor Toolbar} {Editor toolbar} tool
option add *Classy::Editor*Toolbar {
	action floppy "Save" {%W save}
	action open "Open" {eval %W load [Classy::selectfile -title Open -selectmode persistent]}
	action undo "Undo" {%W undo}
	action redo "redo" {%W redo}
	separator
	action print "Print" {%W insert insert "Print: %W"}
	action open "Open next" {%W next}
} widgetDefault

## {Show Help Toolbar} {Do you want ClassyTcl Help ro have toolbars} {select 0 1}
option add *Classy::Help.ShowTool 1 widgetDefault
## {Help Toolbar} {Help toolbar} tool
option add *Classy::Help*Toolbar {
	action open "Edit" {%W edit}
	action undo "Undo" {%W back}
	action redo "redo" {%W forward}
} widgetDefault
