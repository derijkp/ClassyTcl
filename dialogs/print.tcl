#Functions

proc Classy::printdialog args {# ClassyTcl generated Dialog
	if [regexp {^\.} $args] {
		set window [list_shift args]
	} else {
		set window .printdialog
	}
	Classy::parseopt $args opt {-papersize {} {} -getdata {} {}}
	# Create windows
	Classy::Dialog $window  \
		-help classy_print \
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
	grid $window.options.button1 -row 3 -column 2 -sticky nesw
	Classy::Entry $window.options.file \
		-label File \
		-default Classy::print_file \
		-textvariable ::Classy::print(file) \
		-width 4
	grid $window.options.file -row 3 -column 0 -columnspan 2 -sticky nesw
	frame $window.options.paper  \
		-borderwidth 0 \
		-height 10 \
		-width 10
	grid $window.options.paper -row 0 -column 0 -columnspan 3 -sticky nesw
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
	Classy::OptionMenu $window.options.paper.select 
	grid $window.options.paper.select -row 0 -column 1 -sticky nesw
	$window.options.paper.select set {}
	Classy::OptionBox $window.options.paper.cmode  \
		-label Colormode \
		-variable ::Classy::print(colormode) \
		-relief flat
	grid $window.options.paper.cmode -row 3 -column 0 -columnspan 3 -sticky nesw
	$window.options.paper.cmode add color Color
	$window.options.paper.cmode add gray Gray
	$window.options.paper.cmode add mono Mono
	$window.options.paper.cmode set color
	checkbutton $window.options.paper.autoscale1 \
		-text {Auto scale} \
		-variable ::Classy::print(autoscale)
	grid $window.options.paper.autoscale1 -row 1 -column 0 -sticky nesw
	Classy::NumEntry $window.options.paper.scale1 \
		-textvariable ::Classy::print(scale) \
		-width 3
	grid $window.options.paper.scale1 -row 1 -column 1 -sticky nesw
	Classy::OptionBox $window.options.paper.optionbox1  \
		-label Orientation \
		-variable ::Classy::print(portrait) \
		-bd 0 \
		-borderwidth 0
	grid $window.options.paper.optionbox1 -row 2 -column 0 -columnspan 3 -sticky nesw
	$window.options.paper.optionbox1 add 1 Portrait
	$window.options.paper.optionbox1 add 0 Landscape
	$window.options.paper.optionbox1 set 1
	grid columnconfigure $window.options.paper 2 -weight 1
	grid rowconfigure $window.options.paper 3 -weight 1
	Classy::Entry $window.options.printcommand \
		-label {Print command} \
		-default Classy::print_command \
		-textvariable ::Classy::print(command) \
		-width 4
	grid $window.options.printcommand -row 2 -column 0 -columnspan 3 -sticky nesw
	frame $window.options.frame1  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	
	frame $window.options.advanced  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $window.options.advanced -row 1 -column 0 -columnspan 3 -sticky nesw
	Classy::Entry $window.options.advanced.pagey \
		-label {Page Y} \
		-textvariable ::Classy::print(pagey) \
		-width 4
	grid $window.options.advanced.pagey -row 3 -column 1 -sticky nesw
	Classy::Entry $window.options.advanced.pagex \
		-label {Page X} \
		-textvariable ::Classy::print(pagex) \
		-width 4
	grid $window.options.advanced.pagex -row 2 -column 1 -sticky nesw
	Classy::Entry $window.options.advanced.x \
		-label X \
		-textvariable ::Classy::print(x) \
		-width 4
	grid $window.options.advanced.x -row 2 -column 0 -sticky nesw
	Classy::Entry $window.options.advanced.y \
		-label Y \
		-textvariable ::Classy::print(y) \
		-width 4
	grid $window.options.advanced.y -row 3 -column 0 -sticky nesw
	checkbutton $window.options.advanced.scaledxy \
		-text {Scaled XY} \
		-variable ::Classy::print(scaledxy)
	grid $window.options.advanced.scaledxy -row 1 -column 0 -sticky nesw
	frame $window.options.advanced.anchor  \
		-borderwidth 0 \
		-height 10 \
		-width 10
	grid $window.options.advanced.anchor -row 1 -column 1 -sticky nesw
	radiobutton $window.options.advanced.anchor.anchornw \
		-indicatoron 0 \
		-text Topleft \
		-value nw \
		-variable ::Classy::print(pageanchor)
	grid $window.options.advanced.anchor.anchornw -row 0 -column 0 -sticky nesw
	radiobutton $window.options.advanced.anchor.anchorc \
		-indicatoron 0 \
		-text Center \
		-value center \
		-variable ::Classy::print(pageanchor)
	grid $window.options.advanced.anchor.anchorc -row 0 -column 1 -sticky nesw
	radiobutton $window.options.advanced.anchor.anchorse \
		-indicatoron 0 \
		-text BottomRight \
		-value se \
		-variable ::Classy::print(pageanchor)
	grid $window.options.advanced.anchor.anchorse -row 0 -column 2 -sticky nesw
	grid columnconfigure $window.options.advanced 0 -weight 1
	grid columnconfigure $window.options.advanced 1 -weight 1
	grid columnconfigure $window.options 1 -weight 1

	# End windows
	# Parse this
	$window.options.button1 configure \
		-command [varsubst window {$window.options.file set [Classy::selectfile]}]
	$window.options.paper.width configure \
		-command [varsubst window {invoke {} {
$window.options.paper.select set User
Classy::print_autoscale $window
}}]
	$window.options.paper.height configure \
		-command [varsubst window {invoke {} {
$window.options.paper.select set User
Classy::print_autoscale $window
}}]
	$window.options.paper.select configure \
		-command [varsubst window {invoke {window} {
set size [$window.options.paper.select get]
set ::Classy::print(size) $size
set papersize [structlget [option get $window paperSizes PaperSizes] $size]
$window.options.paper.width nocmdset [lindex $papersize 0]
$window.options.paper.height nocmdset [lindex $papersize 1]
Classy::print_autoscale $window
} $window}] \
		-list [list_unmerge [option get $window paperSizes PaperSizes]]
	$window.options.paper.autoscale1 configure \
		-background [Classy::realcolor darkBackground] \
		-command [varsubst window {invoke {} {
upvar #0 ::Classy::print print
Classy::print_autoscale $window
}}]
	$window add print Print [list invoke {} {
upvar ::Classy::print print
set f [open "| $print(command)" w]
puts $f [eval $print(getdata) ::Classy::print]
close $f
}] default
	$window add save Save [list invoke {} {
upvar ::Classy::print print
set f [open $print(file) w]
puts $f [eval $print(getdata) ::Classy::print]
close $f
}]
	$window persistent set save
# ClassyTcl Finalise
upvar #0 ::Classy::print print
set print(psize) $opt(-papersize)
foreach {type def} {
	width 595p
	height 842p
	portrait 1
	size A4
	colormode mono
	autoscale 1
	command lpr
	file print.ps
	scale 100
	scaledxy 1
	x 0
	y 0
	pagex 0
	pagey 0
	pageanchor nw
} {
	if {![info exists print($type)]||("$print($type)" == "")} {
		set print($type) [Classy::Default get app print_$type $def]
	}
}
set print(getdata) $opt(-getdata)
$window.options.paper.select set $print(size)
if {"$opt(-papersize)" != ""} {
	set print(pwidth) [lindex $opt(-papersize) 0]
	set print(pheight) [lindex $opt(-papersize) 1]
	set print(pportrait) [lindex $opt(-papersize) 2]
	if {"$print(pportrait)" == ""} {
		if {$print(pwidth)>$print(pheight)} {
			set print(portrait) 0
		} else {
			set print(portrait) 1
		}
	} elseif [regexp {^l|^L|^0} $p] {
		set print(portrait) 0
	} else {
		set print(portrait) 1
	}
	if $print(autoscale) {
		set printw [winfo fpixels $window $print(width)]
		set paperw [winfo fpixels $window $print(pwidth)]
		set print(scale) [expr {100.0*$printw/$paperw}]
		set printw [winfo fpixels $window $print(height)]
		set paperw [winfo fpixels $window $print(pheight)]
		set hs [expr {100.0*$printw/$paperw}]
		if {$hs<$print(scale)} {set print(scale) $hs}
	}
}
	return $window
	return $window
	return $window
}

proc Classy::print_autoscale {window} {
	upvar #0 ::Classy::print print
	if {$print(autoscale)&&("$print(psize)" != "")} {
		set printw [winfo fpixels $window $print(width)]
		set printh [winfo fpixels $window $print(height)]
		if !$print(portrait) {
			set temp $printw
			set printw $printh
			set printh $temp
		}
		set paperw [winfo fpixels $window [lindex $print(psize) 0]]
		set print(scale) [expr {100.0*$printw/$paperw}]
		set paperh [winfo fpixels $window [lindex $print(psize) 1]]
		set hs [expr {100.0*$printh/$paperh}]
		if {$hs<$print(scale)} {set print(scale) $hs}
	}
}





