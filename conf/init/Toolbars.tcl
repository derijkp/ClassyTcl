#ClassyTcl tool configuration file

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
	action newtoplevel "New Toplevel" {%W new toplevel}
	action newdialog "New Dialog" {%W new dialog}
	action newframe "New Frame" {%W new frame}
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
	action save "Save" {%W save}
	action test "Test" {%W test}
	action recreate "Recreate Dialog" {%W recreate}
	separator
	action close "Close" {destroy %W}
}

Classy::configtool Classy::WindowBuilder_icons {Tk widget toolbar used in the ClassyTcl WindowBuilder} {
	label Tk "Tk Widgets"
	action Builder/frame Frame {%W add frame}
	action Builder/entry Entry {%W add entry}
	action Builder/label Label {%W add label}
	action Builder/button Button {%W add button}
	action Builder/checkbutton {Check button} {%W add checkbutton}
	action Builder/radiobutton {Radio button} {%W add radiobutton}
	action Builder/message Message {%W add message}
	action Builder/vscroll "Vertical Scrollbar" {%W add scrollbar -orient vertical}
	action Builder/hscroll "Horizontal Scrollbar" {%W add scrollbar -orient horizontal}
	action Builder/listbox Listbox {%W add listbox}
	action Builder/text Text {%W add text}
	action Builder/canvas Canvas {%W add canvas}
	action Builder/scale Scale {%W add scale}
	label Classy "ClassyTcl widgets"
	action Builder/classy__dynamenu {menu} {%W add Classy::DynaMenu}
	action Builder/classy__entry {ClassyTcl Entry} {%W add Classy::Entry}
	action Builder/classy__numentry {ClassyTcl Numerical Entry} {%W add Classy::NumEntry}
	action Builder/classy__text {ClassyTcl Text} {%W add Classy::Text}
	action Builder/classy__canvas {ClassyTcl Canvas} {%W add Classy::Canvas}
	action Builder/classy__notebook {Notebook with tabs} {%W add Classy::NoteBook}
	action Builder/classy__optionbox {ClassyTcl OptionBox} {%W add Classy::OptionBox}
	action Builder/classy__optionmenu {ClassyTcl OptionMenu} {%W add Classy::OptionMenu}
	action Builder/classy__paned {Paned} {%W add Classy::Paned}
	action Builder/classy__progress {Progress bar} {%W add Classy::Progress}
	action Builder/classy__scrolledframe {Scrolled frame} {%W add Classy::ScrolledFrame}
	action Builder/classy__table {Table} {%W add Classy::Table}
	action Builder/classy__fold {Fold} {%W add Classy::Fold}
	action Builder/classy__fontselect {Font select} {%W add button -text "Select font" -command {set font [Classy::getfont]}}
	action Builder/classy__colorselect {Color select} {%W add button -text "Select color" -command {set color [Classy::getcolor]}}
	action Builder/classy__treewidget {Tree widget} {%W add Classy::TreeWidget}
	action Builder/classy__browser {Browser} {%W add Classy::Browser}
}

