proc main args {
source [file join $::class::dir widgets WindowBuilderTypes.tcl]
mainw
}


proc mainw args {# ClassyTcl generated Toplevel
	if [regexp {^\.} $args] {
		set window [lshift args]
	} else {
		set window .mainw
	}
	Classy::parseopt $args opt {}
	# Create windows
	Classy::Toplevel $window 
	frame $window.test  \
		-borderwidth 2 \
		-height 80 \
		-relief groove \
		-width 10
	grid $window.test -row 0 -column 1 -sticky nesw
	Classy::Paned $window.paned2 \
		-orient vertical
	grid $window.paned2 -row 2 -column 0 -columnspan 2 -sticky nesw
	Classy::CmdWidget $window.cmd \
		-prompt {[file tail [pwd]] % } \
		-height 8 \
		-width 40
	grid $window.cmd -row 3 -column 1 -sticky nesw
	frame $window.frame  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $window.frame -row 0 -column 0 -rowspan 2 -sticky nesw
	Classy::ListBox $window.frame.widgets  \
		-content {frame
entry
button
checkbutton
radiobutton
label
message
scrollbar
listbox
text
canvas
scale
Classy::Entry
Classy::NumEntry
Classy::Message
Classy::ListBox
Classy::Text
Classy::ScrolledText
Classy::Canvas
Classy::NoteBook
Classy::OptionBox
Classy::OptionMenu
Classy::Paned
Classy::Progress
Classy::ScrolledFrame
Classy::Table
Classy::Fold
Classy::Selector
Classy::TreeWidget
Classy::Browser
Classy::CmdWidget
Classy::DynaTool} \
		-exportselection 0 \
		-height 5 \
		-width 17
	grid $window.frame.widgets -row 0 -column 0 -columnspan 5 -sticky nesw
	Classy::ListBox $window.frame.options  \
		-exportselection 0 \
		-height 4 \
		-width 10
	grid $window.frame.options -row 3 -column 0 -columnspan 5 -sticky nesw
	checkbutton $window.frame.vscroll \
		-indicatoron 0 \
		-text button \
		-variable grid(vscroll)
	grid $window.frame.vscroll -row 2 -column 2 -sticky nesw
	checkbutton $window.frame.hscroll \
		-indicatoron 0 \
		-text button \
		-variable grid(hscroll)
	grid $window.frame.hscroll -row 2 -column 3 -sticky nesw
	checkbutton $window.frame.hresize \
		-indicatoron 0 \
		-text hor \
		-variable grid(hor)
	grid $window.frame.hresize -row 2 -column 1 -sticky nesw
	checkbutton $window.frame.vresize \
		-indicatoron 0 \
		-text vert \
		-variable grid(vert)
	grid $window.frame.vresize -row 2 -column 0 -sticky nesw
	Classy::Entry $window.frame.entry1 \
		-label Other \
		-width 4
	grid $window.frame.entry1 -row 1 -column 0 -columnspan 5 -sticky nesw
	grid columnconfigure $window.frame 4 -weight 1
	grid rowconfigure $window.frame 0 -weight 1
	grid rowconfigure $window.frame 3 -weight 1
	Classy::Selector $window.optionvalue \
		-label Attribute \
		-type line
	grid $window.optionvalue -row 1 -column 1 -sticky nesw
	Classy::ListBox $window.cmds  \
		-height 4 \
		-width 10
	grid $window.cmds -row 3 -column 0 -sticky nesw
	grid columnconfigure $window 1 -weight 1
	grid rowconfigure $window 0 -weight 1

	# End windows
	# Parse this
	$window configure \
		-destroycommand "exit" \
		-title [tk appname]
	$window.paned2 configure \
		-window [varsubst window {$window.cmd}]
	$window.frame.widgets configure \
		-browsecommand [varsubst window {drawwidget $window}]
	$window.frame.options configure \
		-browsecommand [varsubst window {selectoption $window}]
	$window.frame.vscroll configure \
		-command [varsubst window catch\ \{\n\t\$window.test.widget\ configure\ \\\n\t\t-xscrollcommand\ \{\}\n\tdestroy\ \$window.test.vscroll\n\}\nif\ \$grid(vscroll)\ \{\n\tscrollbar\ \$window.test.vscroll\ -orient\ vertical\ \\\n\t\t-command\ \[list\ \$window.test.widget\ yview\]\n\t\$window.test.widget\ configure\ \\\n\t\t-yscrollcommand\ \[list\ \$window.test.vscroll\ set\]\n\tgrid\ \$window.test.vscroll\ -row\ 0\ -column\ 1\ -sticky\ ns\n\}] \
		-image [Classy::geticon Builder/vscroll]
	$window.frame.hscroll configure \
		-command [varsubst window catch\ \{\n\t\$window.test.widget\ configure\ \\\n\t\t-xscrollcommand\ \{\}\n\tdestroy\ \$window.test.hscroll\n\}\nif\ \$grid(hscroll)\ \{\n\tscrollbar\ \$window.test.hscroll\ -orient\ horizontal\ \\\n\t\t-command\ \[list\ \$window.test.widget\ xview\]\n\t\$window.test.widget\ configure\ \\\n\t\t-xscrollcommand\ \[list\ \$window.test.hscroll\ set\]\n\tgrid\ \$window.test.hscroll\ -row\ 1\ -column\ 0\ -sticky\ we\n\}] \
		-image [Classy::geticon Builder/hscroll]
	$window.frame.hresize configure \
		-command [varsubst window {set sticky nw
if $grid(hor) {append sticky e}
if $grid(vert) {append sticky s}
grid $window.test.widget -row 0 -column 0 -sticky $sticky}] \
		-image [Classy::geticon orient_horizontal]
	$window.frame.vresize configure \
		-command [varsubst window {set sticky nw
if $grid(hor) {append sticky e}
if $grid(vert) {append sticky s}
grid $window.test.widget -row 0 -column 0 -sticky $sticky}] \
		-image [Classy::geticon orient_vertical]
	$window.frame.entry1 configure \
		-command [varsubst window {drawwidget $window}]
	$window.optionvalue configure \
		-command [varsubst window {invoke value {
	$window.test.widget configure [$window.frame.options get] $value
}}]
	$window.cmds configure \
		-browsecommand [varsubst window {invoke value {
	$window.cmd insert end "\$w $value"
	focus $window.cmd
}}]
# ClassyTcl Finalise
set ::grid(hor) 1
set ::grid(vert) 1
	return $window
	return $window
}









proc drawwidget {window type} {
global grid
catch {destroy $window.test.widget}
$type $window.test.widget
set sticky nw
if $grid(hor) {append sticky e}
if $grid(vert) {append sticky s}
grid $window.test.widget -row 0 -column 0 -sticky $sticky
grid columnconfigure $window.test 0 -weight 1
grid rowconfigure $window.test 0 -weight 1

set list ""
foreach conf [$window.test.widget configure] {
	lappend list [lindex $conf 0]
}

$window.frame.options configure -content $list

catch {destroy $window.test.vscroll}
catch {destroy $window.test.hscroll}
if $grid(vscroll) {
	scrollbar $window.test.vscroll -orient vertical \
		-command [list $window.test.widget yview]
	$window.test.widget configure \
		-yscrollcommand [list $window.test.vscroll set]
	grid $window.test.vscroll -row 0 -column 1 -sticky ns
}

if $grid(hscroll) {
	scrollbar $window.test.hscroll -orient horizontal \
		-command [list $window.test.widget xview]
	$window.test.widget configure \
		-xscrollcommand [list $window.test.hscroll set]
	grid $window.test.hscroll -row 1 -column 0 -sticky we
}

catch {$window.test.widget {}} result
regsub {,? or ([^,]*)$} $result {, \1} result
regexp {^(bad|ambiguous) option "": must be (.*)$} $result temp t f l
set list [lremove [split $f ", "] {}]
lappend list $l
$window.cmds configure -content $list

set ::w $window.test.widget

}
















proc selectoption {window value} {
set option [$window.frame.options get]
$window.optionvalue configure -label $option
if [info exists ::Classy::WindowBuilder::options($option)] {
	$window.optionvalue configure -type [lindex $::Classy::WindowBuilder::options($option) end]
} else {
	$window.optionvalue configure -type line
}
$window.optionvalue set [$window.test.widget cget $option]
}




























