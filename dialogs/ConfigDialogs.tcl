#Functions

proc Classy::config args {# ClassyTcl generated Toplevel
	if [regexp {^\.} $args] {
		set window [lshift args]
	} else {
		set window .classy__.config
	}
	Classy::parseopt $args opt {}
	# Create windows
	Classy::Toplevel $window  \
		-resize {200 100}
	Classy::TreeWidget $window.browse \
		-width 140 \
		-height 50
	grid $window.browse -row 0 -column 0 -sticky nesw
	Classy::MultiFrame $window.frame  \
		-bd 2 \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $window.frame -row 0 -column 2 -sticky nesw
	Classy::Paned $window.paned
	grid $window.paned -row 0 -column 1 -sticky nesw
	grid columnconfigure $window 2 -weight 1
	grid rowconfigure $window 0 -weight 1

	# End windows
	# Parse this
	$window configure \
		-destroycommand [list destroy $window]
	$window.browse configure \
		-endnodecommand [varsubst window {invoke node {Classy::Config open $window.browse $node}}] \
		-opencommand [varsubst window {invoke node {Classy::Config browse $window.browse $node}}]
	$window.paned configure \
		-window [varsubst window {$window.browse}]
# ClassyTcl Finalise
$window.browse addnode {} appuser -text "Application user"
$window.browse addnode {} appdef -text "Application default"
$window.browse addnode {} user -text "ClassyTcl user"
$window.browse addnode {} def -text "ClassyTcl default"
Classy::Config browse $window.browse appuser
set child [lindex [$window.browse children appuser] 0]
Classy::Config browse $window.browse $child
set child [lindex [$window.browse children $child] 0]
Classy::Config open $window.browse $child
$window configure -resize [list [winfo reqwidth $window] [winfo reqheight $window]]
	return $window
}

proc Classy::config_saveas args {# ClassyTcl generated Dialog
	if [regexp {^\.} $args] {
		set window [lshift args]
	} else {
		set window .classy__.config_saveas
	}
	Classy::parseopt $args opt {-variable {} ::Classy::tempa -level {} appuser}
	# Create windows
	Classy::Dialog $window  \
		-title {Save as}
	Classy::OptionBox $window.options.level  \
		-label Level \
		-orient vertical
	grid $window.options.level -row 0 -column 0 -sticky nesw
	$window.options.level add appuser {Application user}
	$window.options.level add appdef {Application default}
	$window.options.level add user {ClassyTcl user}
	$window.options.level add def {ClassyTcl default}
	$window.options.level set appuser
	Classy::Entry $window.options.named \
		-label Named \
		-orient vertical \
		-width 4
	grid $window.options.named -row 1 -column 0 -sticky new
	grid columnconfigure $window.options 0 -weight 1

# ClassyTcl Initialise
set var $opt(-variable)
	# Parse this
	$window add b1 Go [varsubst {var window} {
	Classy::Config saveas $var \
		[$window.options.level get] \
		[$window.options.named get]
}] default
# ClassyTcl Finalise
$window.options.level set $opt(-level)
}

proc Classy::config_tool args {# ClassyTcl generated Frame
	if [regexp {^\.} $args] {
		set window [lshift args]
	} else {
		set window .classy__.config_tool_frame
	}
	Classy::parseopt $args opt {-level {} {} -name {} {}}
	# Create windows
	frame $window \
		-class Classy::Topframe  \
		-cursor hand2
	button $window.button1 \
		-text button
	grid $window.button1 -row 1 -column 2 -sticky nesw
	button $window.edit \
		-text Editor
	grid $window.edit -row 1 -column 2 -sticky nesw
	label $window.title
	grid $window.title -row 1 -column 1 -sticky nesw
	Classy::ScrolledText $window.value  \
		-height 5 \
		-width 10
	grid $window.value -row 2 -column 0 -columnspan 3 -sticky nesw
	Classy::OptionMenu $window.level  \
		-list {
	{Application user}
	{Application default}
	{ClassyTcl user}
	{ClassyTcl default}
} \
		-text {Application user}
	grid $window.level -row 1 -column 0 -sticky nesw
	$window.level set {Application user}
	Classy::DynaTool $window.tool  \
		-width 286 \
		-type Classy::Config \
		-height 37
	grid $window.tool -row 0 -column 0 -columnspan 3 -sticky nesw
	grid columnconfigure $window 1 -weight 1
	grid rowconfigure $window 2 -weight 1

	# End windows
# ClassyTcl Initialise
set name $opt(-name)
set level $opt(-level)
set var $window
if {"$level" == ""} {
	set level appuser
}
::Classy::Config load Toolbars $level $name $var
upvar #0 $var data
set name $data(name)
set data(window) $window
putsvars window name var
	# Parse this
	$window.edit configure \
		-command [varsubst window {set w [edit]
$w.editor configure -savecommand {invoke {} {}}
$w.editor link $window.value}]
	$window.title configure \
		-text "$data(help)"
	$window.value configure \
		-changedcommand [list set ::[set var](changed) 1]
	bind $window.value <<Save>> [varsubst window {Classy::Config save [$window.tool cmdw]}]
	bind $window.value <<Close>> [varsubst window {invoke w {
set w [$window.tool cmdw]
global $w
if [info exists ${w}(close)] {eval [set ${w}(close)]}
}
break}]
	$window.level configure \
		-command [list Classy::Config changelevel $var $window]
	$window.tool configure \
		-cmdw [varsubst window {$window}]
# ClassyTcl Finalise
$window.value set $data(c)
set list {
	{Application user}
	{Application default}
	{ClassyTcl user}
	{ClassyTcl default}
}
if [catch {structlget {
	appuser {Application user}
	appdef {Application default}
	user {ClassyTcl user}
	def {ClassyTcl default}
} $level} nlevel] {
	lappend list $level
} else {
	set level $nlevel
}
$window.level configure -list $list
$window.level set $level
$window.value textchanged 0
set data(changed) 0
	return $window
}

proc Classy::config_menu args {# ClassyTcl generated Frame
	if [regexp {^\.} $args] {
		set window [lshift args]
	} else {
		set window .classy__.config_menu_frame
	}
	Classy::parseopt $args opt {-level {} {} -name {} {}}
	# Create windows
	frame $window \
		-class Classy::Topframe  \
		-cursor hand2
	button $window.button1 \
		-text button
	grid $window.button1 -row 1 -column 2 -sticky nesw
	button $window.edit \
		-text Editor
	grid $window.edit -row 1 -column 2 -sticky nesw
	label $window.title
	grid $window.title -row 1 -column 1 -sticky nesw
	Classy::ScrolledText $window.value  \
		-height 5 \
		-width 10
	grid $window.value -row 2 -column 0 -columnspan 3 -sticky nesw
	Classy::OptionMenu $window.level  \
		-list {
	{Application user}
	{Application default}
	{ClassyTcl user}
	{ClassyTcl default}
} \
		-text {Application user}
	grid $window.level -row 1 -column 0 -sticky nesw
	$window.level set {Application user}
	Classy::DynaTool $window.tool  \
		-width 286 \
		-type Classy::Config \
		-height 37
	grid $window.tool -row 0 -column 0 -columnspan 3 -sticky nesw
	grid columnconfigure $window 1 -weight 1
	grid rowconfigure $window 2 -weight 1

	# End windows
# ClassyTcl Initialise
set name $opt(-name)
set level $opt(-level)
set var $window
if {"$level" == ""} {
	set level appuser
}
::Classy::Config load Menus $level $name $var
upvar #0 $var data
set data(window) $window
set name $data(name)
putsvars window name var
	# Parse this
	$window.edit configure \
		-command [varsubst window {set w [edit]
$w.editor configure -savecommand {invoke {} {}}
$w.editor link $window.value}]
	$window.title configure \
		-text "$data(help)"
	$window.value configure \
		-changedcommand [list set ::[set var](changed) 1]
	$window.value set {}
	bind $window.value <<Close>> [varsubst window {invoke w {
set w [$window.tool cmdw]
global $w
if [info exists ${w}(close)] {eval [set ${w}(close)]}
}
break}]
	bind $window.value <<Save>> [varsubst window {Classy::Config save [$window.tool cmdw]}]
	$window.level configure \
		-command [list Classy::Config changelevel $var $window]
	$window.tool configure \
		-cmdw [varsubst window {$window}]
# ClassyTcl Finalise
$window.value set $data(c)
set list {
	{Application user}
	{Application default}
	{ClassyTcl user}
	{ClassyTcl default}
}
if [catch {structlget {
	appuser {Application user}
	appdef {Application default}
	user {ClassyTcl user}
	def {ClassyTcl default}
} $level} nlevel] {
	lappend list $level
} else {
	set level $nlevel
}
$window.level configure -list $list
$window.level set $level
$window.value textchanged 0
set data(changed) 0
	return $window
}

proc Classy::config_frame args {# ClassyTcl generated Frame
	if [regexp {^\.} $args] {
		set window [lshift args]
	} else {
		set window .classy__.config_frame
	}
	Classy::parseopt $args opt {-level {} {} -name {} {} -type {Colors Fonts Misc Keys Mouse} Colors}
	# Create windows
	frame $window \
		-class Classy::Topframe  \
		-cursor hand2
	Classy::Paned $window.paned1
	grid $window.paned1 -row 2 -column 1 -sticky nesw
	Classy::ListBox $window.list  \
		-exportselection 0 \
		-height 4 \
		-takefocus 1 \
		-width 15
	grid $window.list -row 2 -column 0 -sticky nesw
	frame $window.frame  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $window.frame -row 2 -column 2 -sticky nesw
	label $window.frame.name \
		-text {Entry background}
	grid $window.frame.name -row 0 -column 0 -sticky nesw
	checkbutton $window.frame.comment \
		-text {Use default instead} \
		-variable comment
	grid $window.frame.comment -row 1 -column 0 -sticky nesw
	Classy::Selector $window.frame.select \
		-label {Entry background} \
		-orient vertical \
		-type color
	grid $window.frame.select -row 2 -column 0 -sticky nesw
	Classy::Message $window.frame.help \
		-text {Entry background color} \
		-width 256
	grid $window.frame.help -row 3 -column 0 -sticky nesw
	Classy::Fold $window.frame.advanced  \
		-title Advanced \
		-bd 2 \
		-borderwidth 2 \
		-relief groove
	grid $window.frame.advanced -row 5 -column 0 -sticky nesw
		Classy::Entry $window.frame.advanced.content.text \
		-label Text \
		-width 4
	grid $window.frame.advanced.content.text -row 1 -column 0 -sticky nesw
	Classy::Entry $window.frame.advanced.content.pattern \
		-label Pattern \
		-width 4
	grid $window.frame.advanced.content.pattern -row 2 -column 0 -sticky nesw
	Classy::Entry $window.frame.advanced.content.descr \
		-label Description \
		-width 4
	grid $window.frame.advanced.content.descr -row 3 -column 0 -sticky nesw
	Classy::Selector $window.frame.advanced.content.type \
		-orient vertical \
		-type {select line int text color font key mouse anchor justify bool orient relief select}
	grid $window.frame.advanced.content.type -row 4 -column 0 -sticky nesw
	frame $window.frame.advanced.content.buttons  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $window.frame.advanced.content.buttons -row 0 -column 0 -sticky nsw
	button $window.frame.advanced.content.buttons.change \
		-text Change
	grid $window.frame.advanced.content.buttons.change -row 1 -column 0 -sticky nesw
	button $window.frame.advanced.content.buttons.pasted1 \
		-text Add
	grid $window.frame.advanced.content.buttons.pasted1 -row 1 -column 1 -sticky nesw
	button $window.frame.advanced.content.buttons.pasted2 \
		-text Remove
	grid $window.frame.advanced.content.buttons.pasted2 -row 1 -column 2 -sticky nesw
	button $window.frame.advanced.content.buttons.up \
		-text Up
	grid $window.frame.advanced.content.buttons.up -row 1 -column 3 -sticky nesw
	button $window.frame.advanced.content.buttons.down \
		-text Down
	grid $window.frame.advanced.content.buttons.down -row 1 -column 4 -sticky nesw
		grid columnconfigure $window.frame.advanced.content 0 -weight 1
	grid columnconfigure $window.frame.advanced.content 1 -weight 1

	grid columnconfigure $window.frame 0 -weight 1
	grid rowconfigure $window.frame 2 -weight 1
	frame $window.top  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $window.top -row 1 -column 0 -columnspan 3 -sticky nesw
	label $window.top.title \
		-text {Widget Colors}
	grid $window.top.title -row 0 -column 1 -sticky nesw
	Classy::OptionMenu $window.top.level  \
		-list {
	{Application user}
	{Application default}
	{ClassyTcl user}
	{ClassyTcl default}
} \
		-text {Application user}
	grid $window.top.level -row 0 -column 0 -sticky nesw
	$window.top.level set {Application user}
	grid columnconfigure $window.top 1 -weight 1
	grid columnconfigure $window.top 2 -weight 1
	Classy::DynaTool $window.tool  \
		-width 286 \
		-type Classy::Config \
		-height 21
	grid $window.tool -row 0 -column 0 -columnspan 3 -sticky nesw
	grid columnconfigure $window 2 -weight 1
	grid rowconfigure $window 2 -weight 1

	# End windows
# ClassyTcl Initialise
set name $opt(-name)
set level $opt(-level)
set var $window
if {"$level" == ""} {
	set level appuser
}
::Classy::Config load $opt(-type) $level $name $var
set name [set ::${var}(name)]
putsvars window name var
$window.frame.advanced.content.text set Option
$window.frame.advanced.content.pattern set *option
$window.frame.advanced.content.descr set description
$window.frame.advanced.content.type set line
	# Parse this
	$window.paned1 configure \
		-window [varsubst window {$window.list}]
	$window.list configure \
		-content [set ::${var}(names)] \
		-browsecommand [list Classy::Config browselist $var $window]
	$window.frame.comment configure \
		-command [list set [set var](changed) 1]
	$window.frame.select configure \
		-command [list invoke {} [list set [set var](changed) 1]]
	$window.frame.advanced.content.buttons.change configure \
		-command [list Classy::Config change $var $window]
	$window.frame.advanced.content.buttons.pasted1 configure \
		-command [list Classy::Config add $var $window]
	$window.frame.advanced.content.buttons.pasted2 configure \
		-command [list Classy::Config remove $var $window]
	$window.frame.advanced.content.buttons.up configure \
		-command [list Classy::Config move up $var $window]
	$window.frame.advanced.content.buttons.down configure \
		-command [list Classy::Config move down $var $window]
	$window.top.level configure \
		-command [list Classy::Config changelevel $var $window]
	$window.tool configure \
		-cmdw [varsubst window {$window}]
# ClassyTcl Finalise
$window.top.title configure -text $name
$window.list activate 0
$window.list selection set 0

set list {
	{Application user}
	{Application default}
	{ClassyTcl user}
	{ClassyTcl default}
}
if [catch {structlget {
	appuser {Application user}
	appdef {Application default}
	user {ClassyTcl user}
	def {ClassyTcl default}
} $level} nlevel] {
	lappend list $level
} else {
	set level $nlevel
}
$window.top.level configure -list $list
$window.top.level set $level
	return $window
}


