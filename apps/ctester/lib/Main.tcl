proc main args {
source [file join $::class::dir widgets WindowBuilderTypes.tcl]
mainw .mainw
}

Classy::Toplevel subclass mainw
mainw method init args {
	super init
	# Create windows
	frame $object.test  \
		-borderwidth 2 \
		-height 80 \
		-relief groove \
		-width 10
	grid $object.test -row 0 -column 1 -sticky nesw
	Classy::Paned $object.paned2 \
		-orient vertical
	grid $object.paned2 -row 2 -column 0 -columnspan 2 -sticky nesw
	Classy::CmdWidget $object.cmd \
		-prompt {[file tail [pwd]] % } \
		-height 8 \
		-width 40
	grid $object.cmd -row 3 -column 1 -sticky nesw
	frame $object.frame  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $object.frame -row 0 -column 0 -rowspan 2 -sticky nesw
	Classy::ListBox $object.frame.widgets  \
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
	grid $object.frame.widgets -row 0 -column 0 -columnspan 5 -sticky nesw
	Classy::ListBox $object.frame.options  \
		-exportselection 0 \
		-height 4 \
		-width 10
	grid $object.frame.options -row 3 -column 0 -columnspan 5 -sticky nesw
	checkbutton $object.frame.vscroll \
		-indicatoron 0 \
		-text button \
		-variable grid(vscroll)
	grid $object.frame.vscroll -row 2 -column 2 -sticky nesw
	checkbutton $object.frame.hscroll \
		-indicatoron 0 \
		-text button \
		-variable grid(hscroll)
	grid $object.frame.hscroll -row 2 -column 3 -sticky nesw
	checkbutton $object.frame.hresize \
		-indicatoron 0 \
		-text hor \
		-variable grid(hor)
	grid $object.frame.hresize -row 2 -column 1 -sticky nesw
	checkbutton $object.frame.vresize \
		-indicatoron 0 \
		-text vert \
		-variable grid(vert)
	grid $object.frame.vresize -row 2 -column 0 -sticky nesw
	Classy::Entry $object.frame.entry1 \
		-label Other \
		-width 4
	grid $object.frame.entry1 -row 1 -column 0 -columnspan 5 -sticky nesw
	grid columnconfigure $object.frame 4 -weight 1
	grid rowconfigure $object.frame 0 -weight 1
	grid rowconfigure $object.frame 3 -weight 1
	Classy::Selector $object.optionvalue \
		-label Attribute \
		-type line
	grid $object.optionvalue -row 1 -column 1 -sticky nesw
	Classy::ListBox $object.cmds  \
		-height 4 \
		-width 10
	grid $object.cmds -row 3 -column 0 -sticky nesw
	grid columnconfigure $object 1 -weight 1
	grid rowconfigure $object 0 -weight 1

	# End windows
	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object configure \
		-destroycommand "exit" \
		-title [tk appname]
	$object.paned2 configure \
		-window [varsubst object {$object.cmd}]
	$object.frame.widgets configure \
		-browsecommand [varsubst object {drawwidget $object}]
	$object.frame.options configure \
		-browsecommand [varsubst object {selectoption $object}]
	$object.frame.vscroll configure \
		-command [varsubst object catch\ \{\n\t\$object.test.widget\ configure\ \\\n\t\t-xscrollcommand\ \{\}\n\tdestroy\ \$object.test.vscroll\n\}\nif\ \$grid(vscroll)\ \{\n\tscrollbar\ \$object.test.vscroll\ -orient\ vertical\ \\\n\t\t-command\ \[list\ \$object.test.widget\ yview\]\n\t\$object.test.widget\ configure\ \\\n\t\t-yscrollcommand\ \[list\ \$object.test.vscroll\ set\]\n\tgrid\ \$object.test.vscroll\ -row\ 0\ -column\ 1\ -sticky\ ns\n\}] \
		-image [Classy::geticon Builder/vscroll]
	$object.frame.hscroll configure \
		-command [varsubst object catch\ \{\n\t\$object.test.widget\ configure\ \\\n\t\t-xscrollcommand\ \{\}\n\tdestroy\ \$object.test.hscroll\n\}\nif\ \$grid(hscroll)\ \{\n\tscrollbar\ \$object.test.hscroll\ -orient\ horizontal\ \\\n\t\t-command\ \[list\ \$object.test.widget\ xview\]\n\t\$object.test.widget\ configure\ \\\n\t\t-xscrollcommand\ \[list\ \$object.test.hscroll\ set\]\n\tgrid\ \$object.test.hscroll\ -row\ 1\ -column\ 0\ -sticky\ we\n\}] \
		-image [Classy::geticon Builder/hscroll]
	$object.frame.hresize configure \
		-command [varsubst object {set sticky nw
if $grid(hor) {append sticky e}
if $grid(vert) {append sticky s}
grid $object.test.widget -row 0 -column 0 -sticky $sticky}] \
		-image [Classy::geticon orient_horizontal]
	$object.frame.vresize configure \
		-command [varsubst object {set sticky nw
if $grid(hor) {append sticky e}
if $grid(vert) {append sticky s}
grid $object.test.widget -row 0 -column 0 -sticky $sticky}] \
		-image [Classy::geticon orient_vertical]
	$object.frame.entry1 configure \
		-command [varsubst object {drawwidget $object}]
	$object.optionvalue configure \
		-command [varsubst object {invoke value {
	$object.test.widget configure [$object.frame.options get] $value
}}]
	$object.cmds configure \
		-browsecommand [varsubst object {invoke value {
	$object.cmd insert end "\$w $value"
	focus $object.cmd
}}]
	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
# ClassyTcl Finalise
set ::grid(hor) 1
set ::grid(vert) 1
	return $object
	return $object
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

