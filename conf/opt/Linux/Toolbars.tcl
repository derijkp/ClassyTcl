## {Show Editor Toolbar} {Do you want ClassyTcl Editor to have toolbars}
option add *Classy::Editor.ShowTool 1 widgetDefault
## {Editor Toolbar} {Editor toolbar} tool
option add *Classy::Editor.Toolbar {
	action floppy "Save" {%W save}
	action open "Open" {eval %W load [Classy::selectfile -title Open -selectmode persistent]}
	action undo "Undo" {%W undo}
	action redo "redo" {%W redo}
	separator
	action print "Print" {%W insert insert "Print: %W"}
	action open "Open next" {%W next}
} widgetDefault
## {Show Help Toolbar} {Do you want ClassyTcl Help ro have toolbars}
option add *Classy::Help.ShowTool 1 widgetDefault
## {Help Toolbar} {Help toolbar} tool
option add *Classy::Help.Toolbar {
	action reload "Reload" {%W reload}
	action back "Back" {%W back}
	action forward "Forward" {%W forward}
	action edit "Edit" {%W edit}
	widget Classy::findhelp "Find" 
	radio Word "Find word" {-variable ::Classy::helpfind -value word}
	radio File "Find file" {-variable ::Classy::helpfind -value file}
	radio Infile "Find in file" {-variable ::Classy::helpfind -value grep}
} widgetDefault

