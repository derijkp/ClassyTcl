#Functions

proc printdialog args {# ClassyTcl generated Dialog
	if [regexp {^\.} $args] {
		set window [lshift args]
	} else {
		set window .printdialog
	}
	Classy::parseopt $args opt {-printcommand {} {} -savecommand {} {} -papersize {} {}}
	# Create windows
	Classy::Dialog $window  \
		-destroycommand {destroy .b.dedit.work} \
		-title Print
	Classy::Entry $window.options.entry1 \
		-label label \
		-width 4
	
	Classy::Entry $window.options.entry2 \
		-label label \
		-width 4
	
	Classy::Entry $window.options.entry3 \
		-label label \
		-width 4
	
	entry $window.options.entry4 \
		-width 4
	
	button $window.options.button1 \
		-text {Select file}
	grid $window.options.button1 -row 4 -column 1 -sticky nesw
	Classy::Entry $window.options.file \
		-label File \
		-default Classy::print_file \
		-textvariable ::Classy::print(file) \
		-width 4
	grid $window.options.file -row 4 -column 0 -sticky nesw
	frame $window.options.paper  \
		-borderwidth 0 \
		-height 10 \
		-width 10
	grid $window.options.paper -row 1 -column 0 -columnspan 2 -sticky nesw
	label $window.options.paper.label1 \
		-text Papersize
	grid $window.options.paper.label1 -row 0 -column 0 -sticky nesw
	Classy::Entry $window.options.paper.width \
		-labelwidth 5 \
		-label Width \
		-default Classy::print_width \
		-textvariable ::Classy::print(width) \
		-width 6
	grid $window.options.paper.width -row 0 -column 2 -sticky nesw
	Classy::Entry $window.options.paper.height \
		-labelwidth 5 \
		-label Height \
		-default Classy::print_height \
		-textvariable ::Classy::print(height) \
		-width 6
	grid $window.options.paper.height -row 1 -column 2 -sticky nesw
	Classy::OptionMenu $window.options.paper.select  \
		-text A4
	grid $window.options.paper.select -row 0 -column 1 -sticky nesw
	$window.options.paper.select set A4
	radiobutton $window.options.paper.radiobutton1 \
		-anchor w \
		-text Portrait \
		-value 1 \
		-variable ::Classy::print(portrait)
	grid $window.options.paper.radiobutton1 -row 1 -column 0 -sticky nesw
	radiobutton $window.options.paper.radiobutton2 \
		-anchor w \
		-text Landscape \
		-value 0 \
		-variable ::Classy::print(portrait)
	grid $window.options.paper.radiobutton2 -row 1 -column 1 -sticky nesw
	Classy::OptionBox $window.options.paper.cmode  \
		-label Colormode \
		-relief flat
	grid $window.options.paper.cmode -row 2 -column 0 -columnspan 3 -sticky nesw
	$window.options.paper.cmode add color Color
	$window.options.paper.cmode add gray Gray
	$window.options.paper.cmode add mono Mono
	$window.options.paper.cmode set mono
	grid columnconfigure $window.options.paper 2 -weight 1
	grid rowconfigure $window.options.paper 2 -weight 1
	Classy::Entry $window.options.printcommand \
		-label {Print command} \
		-default Classy::print_command \
		-textvariable ::Classy::print(command) \
		-width 4
	grid $window.options.printcommand -row 3 -column 0 -columnspan 2 -sticky nesw
	frame $window.options.frame1  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	
	frame $window.options.offset  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $window.options.offset -row 2 -column 0 -columnspan 2 -sticky nesw
	Classy::NumEntry $window.options.offset.scale \
		-textvariable ::Classy::print(scale) \
		-width 3
	grid $window.options.offset.scale -row 1 -column 0 -sticky nesw
	Classy::NumEntry $window.options.offset.x \
		-label {X offset} \
		-textvariable ::Classy::print(xoffset) \
		-width 3
	grid $window.options.offset.x -row 0 -column 1 -sticky nesw
	Classy::NumEntry $window.options.offset.y \
		-label {Y offset} \
		-textvariable ::Classy::print(yoffset) \
		-width 3
	grid $window.options.offset.y -row 1 -column 1 -sticky nesw
	checkbutton $window.options.offset.autoscale \
		-text {Auto scale} \
		-variable ::Classy::print(autoscale)
	grid $window.options.offset.autoscale -row 0 -column 0 -sticky nesw
	grid columnconfigure $window.options.offset 0 -weight 1
	grid columnconfigure $window.options.offset 1 -weight 1
	grid columnconfigure $window.options 0 -weight 1

	# End windows
	# Parse this
	$window.options.button1 configure \
		-command [varsubst window {$window.options.file set [Classy::selectfile]}]
	$window.options.paper.width configure \
		-command [varsubst window {invoke {} {
$window.options.paper.select set User
upvar #0 ::Classy::print print
if {$print(autoscale)&&("$print(psize)" != "")} {
	set printw [winfo fpixels $window $print(width)]
	set paperw [winfo fpixels $window [lindex $print(psize) 0]]
	set print(scale) [expr {100.0*$printw/$paperw}]
	set printw [winfo fpixels $window $print(height)]
	set paperw [winfo fpixels $window [lindex $print(psize) 1]]
	set hs [expr {100.0*$printw/$paperw}]
	if {$hs<$print(scale)} {set print(scale) $hs}
}
}}]
	$window.options.paper.height configure \
		-command [varsubst window {invoke {} {
$window.options.paper.select set User
upvar #0 ::Classy::print print
if {$print(autoscale)&&("$print(psize)" != "")} {
	set printw [winfo fpixels $window $print(width)]
	set paperw [winfo fpixels $window [lindex $print(psize) 0]]
	set print(scale) [expr {100.0*$printw/$paperw}]
	set printw [winfo fpixels $window $print(height)]
	set paperw [winfo fpixels $window [lindex $print(psize) 1]]
	set hs [expr {100.0*$printw/$paperw}]
	if {$hs<$print(scale)} {set print(scale) $hs}
}
}}]
	$window.options.paper.select configure \
		-command [varsubst window {invoke {window} {
set size [$window.options.paper.select get]
set ::Classy::print(size) $size
set papersize [structlget [option get $window paperSizes PaperSizes] $size]
$window.options.paper.width nocmdset [lindex $papersize 0]
$window.options.paper.height nocmdset [lindex $papersize 1]
upvar #0 ::Classy::print print
if {$print(autoscale)&&("$print(psize)" != "")} {
	set printw [winfo fpixels $window $print(width)]
	set paperw [winfo fpixels $window [lindex $print(psize) 0]]
	set print(scale) [expr {100.0*$printw/$paperw}]
	set printw [winfo fpixels $window $print(height)]
	set paperw [winfo fpixels $window [lindex $print(psize) 1]]
	set hs [expr {100.0*$printw/$paperw}]
	if {$hs<$print(scale)} {set print(scale) $hs}
}
} $window}] \
		-list [lunmerge [option get $window paperSizes PaperSizes]]
	$window.options.offset.autoscale configure \
		-background [Classy::realcolor DarkBackground] \
		-command [varsubst window {invoke {} {
upvar #0 ::Classy::print print
if {$print(autoscale)&&("$print(psize)" != "")} {
	set printw [winfo fpixels $window $print(width)]
	set paperw [winfo fpixels $window [lindex $print(psize) 0]]
	set print(scale) [expr {100.0*$printw/$paperw}]
	set printw [winfo fpixels $window $print(height)]
	set paperw [winfo fpixels $window [lindex $print(psize) 1]]
	set hs [expr {100.0*$printw/$paperw}]
	if {$hs<$print(scale)} {set print(scale) $hs}
}
}}]
	$window add b1 Print "$opt(-printcommand) ::Classy::print" default
	$window add b2 Save "$opt(-savecommand) ::Classy::print"
	$window add help Help {Classy::help classy_print}
# ClassyTcl Finalise
upvar #0 Classy::print print
set print(psize) $opt(-papersize)
foreach {type def} {
	width 595p
	height 842p
	portrait 1
	size A4
	command lpr
	file print.ps
	scale 100
	xoffset 0
	yoffset 0
	autoscale 1
} {
	if {![info exists print($type)]||("$print($type)" == "")} {
		set print($type) [Classy::Default get app print_$type $def]
	}
}
$window.options.paper.select set $print(size)
if {$print(autoscale)&&("$opt(-papersize)" != "")} {
	set printw [winfo fpixels $window $print(width)]
	set paperw [winfo fpixels $window [lindex $opt(-papersize) 0]]
	set print(scale) [expr {100.0*$printw/$paperw}]
	set printw [winfo fpixels $window $print(height)]
	set paperw [winfo fpixels $window [lindex $opt(-papersize) 1]]
	set hs [expr {100.0*$printw/$paperw}]
	if {$hs<$print(scale)} {set print(scale) $hs}
}
	return $window
}



















