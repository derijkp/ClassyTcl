Classy::Dialog subclass Classy_printdialog
Classy_printdialog method init args {
	super init
	# Create windows
	Classy::Entry $object.options.entry1 \
		-label label \
		-width 4
	
	Classy::Entry $object.options.entry2 \
		-label label \
		-width 4
	
	Classy::Entry $object.options.entry3 \
		-label label \
		-width 4
	
	entry $object.options.entry4 \
		-width 4
	
	button $object.options.button1 \
		-text {Select file}
	grid $object.options.button1 -row 3 -column 2 -sticky nesw
	Classy::Entry $object.options.file \
		-label File \
		-default Classy::print_file \
		-width 4
	grid $object.options.file -row 3 -column 0 -columnspan 2 -sticky nesw
	frame $object.options.paper  \
		-borderwidth 0 \
		-height 10 \
		-width 10
	grid $object.options.paper -row 0 -column 0 -columnspan 3 -sticky nesw
	label $object.options.paper.label1 \
		-text Papersize
	grid $object.options.paper.label1 -row 0 -column 0 -sticky nesw
	Classy::Entry $object.options.paper.width \
		-labelwidth 5 \
		-label Width \
		-default Classy::print_width \
		-width 6
	grid $object.options.paper.width -row 0 -column 2 -sticky nesw
	Classy::Entry $object.options.paper.height \
		-labelwidth 5 \
		-label Height \
		-default Classy::print_height \
		-width 6
	grid $object.options.paper.height -row 1 -column 2 -sticky nesw
	Classy::OptionMenu $object.options.paper.select  \
		-text A4\
		-textvariable {}
	grid $object.options.paper.select -row 0 -column 1 -sticky nesw
	$object.options.paper.select set A4
	Classy::OptionBox $object.options.paper.cmode  \
		-label Colormode \
		-relief flat
	grid $object.options.paper.cmode -row 3 -column 0 -columnspan 3 -sticky nesw
	$object.options.paper.cmode add color Color
	$object.options.paper.cmode add gray Gray
	$object.options.paper.cmode add mono Mono
	$object.options.paper.cmode set {}
	checkbutton $object.options.paper.autoscale1 \
		-text {Auto scale}
	grid $object.options.paper.autoscale1 -row 1 -column 0 -sticky nesw
	Classy::NumEntry $object.options.paper.scale1 \
		-state disabled \
		-width 3
	grid $object.options.paper.scale1 -row 1 -column 1 -sticky nesw
	Classy::OptionBox $object.options.paper.optionbox1  \
		-label Orientation \
		-bd 0 \
		-borderwidth 0
	grid $object.options.paper.optionbox1 -row 2 -column 0 -columnspan 3 -sticky nesw
	$object.options.paper.optionbox1 add 1 Portrait
	$object.options.paper.optionbox1 add 0 Landscape
	$object.options.paper.optionbox1 set {}
	grid columnconfigure $object.options.paper 2 -weight 1
	grid rowconfigure $object.options.paper 3 -weight 1
	Classy::Entry $object.options.printcommand \
		-label {Print command} \
		-default Classy::print_command \
		-width 4
	grid $object.options.printcommand -row 2 -column 0 -columnspan 3 -sticky nesw
	frame $object.options.frame1  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	
	frame $object.options.advanced  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $object.options.advanced -row 1 -column 0 -columnspan 3 -sticky nesw
	Classy::Entry $object.options.advanced.pagey \
		-label {Page Y} \
		-width 4
	grid $object.options.advanced.pagey -row 3 -column 1 -sticky nesw
	Classy::Entry $object.options.advanced.pagex \
		-label {Page X} \
		-width 4
	grid $object.options.advanced.pagex -row 2 -column 1 -sticky nesw
	Classy::Entry $object.options.advanced.x \
		-label X \
		-width 4
	grid $object.options.advanced.x -row 2 -column 0 -sticky nesw
	Classy::Entry $object.options.advanced.y \
		-label Y \
		-width 4
	grid $object.options.advanced.y -row 3 -column 0 -sticky nesw
	checkbutton $object.options.advanced.scaledxy \
		-text {Scaled XY}
	grid $object.options.advanced.scaledxy -row 1 -column 0 -sticky nesw
	frame $object.options.advanced.anchor  \
		-borderwidth 0 \
		-height 10 \
		-width 10
	grid $object.options.advanced.anchor -row 1 -column 1 -sticky nesw
	radiobutton $object.options.advanced.anchor.anchornw \
		-indicatoron 0 \
		-text Topleft \
		-value nw
	grid $object.options.advanced.anchor.anchornw -row 0 -column 0 -sticky nesw
	radiobutton $object.options.advanced.anchor.anchorc \
		-indicatoron 0 \
		-text Center \
		-value center
	grid $object.options.advanced.anchor.anchorc -row 0 -column 1 -sticky nesw
	radiobutton $object.options.advanced.anchor.anchorse \
		-indicatoron 0 \
		-text BottomRight \
		-value se
	grid $object.options.advanced.anchor.anchorse -row 0 -column 2 -sticky nesw
	grid columnconfigure $object.options.advanced 0 -weight 1
	grid columnconfigure $object.options.advanced 1 -weight 1
	grid columnconfigure $object.options 1 -weight 1

	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object.options.button1 configure \
		-command [varsubst object {$object.options.file set [Classy::selectfile]}]
	$object.options.file configure \
		-textvariable [privatevar $object options(-file)]
	$object.options.paper.width configure \
		-command [varsubst object {invoke {} {
$object.options.paper.select set User
}}] \
		-textvariable [privatevar $object options(-width)]
	$object.options.paper.height configure \
		-command [varsubst object {invoke {} {
$object.options.paper.select set User
}}] \
		-textvariable [privatevar $object options(-height)]
	$object.options.paper.select configure \
		-command [varsubst object {invoke {window} {
set size [$object.options.paper.select get]
set ::Classy::print(size) $size
set papersize [structlget [option get $object paperSizes PaperSizes] $size]
$object.options.paper.width nocmdset [lindex $papersize 0]
$object.options.paper.height nocmdset [lindex $papersize 1]
} $object}] \
		-list [list_unmerge [option get $object paperSizes PaperSizes]]
	$object.options.paper.cmode configure \
		-variable [privatevar $object options(-colormode)]
	$object.options.paper.autoscale1 configure \
		-background [Classy::realcolor darkBackground] \
		-command [varsubst object {invoke {value} {
private $object options
if $options(-autoscale) {
	$object.options.paper.scale1 configure -state disabled
} else {
	$object.options.paper.scale1 configure -state normal
}
}}] \
		-variable [privatevar $object options(-autoscale)]
	$object.options.paper.scale1 configure \
		-textvariable [privatevar $object options(-scale)]
	$object.options.paper.optionbox1 configure \
		-variable [privatevar $object options(-portrait)]
	$object.options.printcommand configure \
		-textvariable [privatevar $object options(-printcommand)]
	$object.options.advanced.pagey configure \
		-textvariable [privatevar $object options(-pagey)]
	$object.options.advanced.pagex configure \
		-textvariable [privatevar $object options(-pagex)]
	$object.options.advanced.x configure \
		-textvariable [privatevar $object options(-x)]
	$object.options.advanced.y configure \
		-textvariable [privatevar $object options(-y)]
	$object.options.advanced.scaledxy configure \
		-variable [privatevar $object options(-scaledxy)]
	$object.options.advanced.anchor.anchornw configure \
		-variable [privatevar $object options(-pageanchor)]
	$object.options.advanced.anchor.anchorc configure \
		-variable [privatevar $object options(-pageanchor)]
	$object.options.advanced.anchor.anchorse configure \
		-variable [privatevar $object options(-pageanchor)]
	$object add print Print [list $object print] default
	$object add save Save [list $object save]
	$object persistent set save
	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
# ClassyTcl Finalise
upvar #0 ::Classy::print print
set print(psize) A4
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
$object.options.paper.select set $print(size)
	return $object
}

Classy_printdialog addoption -printcommand {printCommand PrintCommand lpr} {
}

Classy_printdialog addoption -papersize {papersize Papersize A4} {
	upvar #0 ::Classy::print print
	set print(psize) $value
	set print(pwidth) [lindex $value 0]
	set print(pheight) [lindex $value 1]
	set print(pportrait) [lindex $value 2]
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
		set printw [winfo fpixels $object $print(width)]
		set paperw [winfo fpixels $object $print(pwidth)]
		set print(scale) [expr {100.0*$printw/$paperw}]
		set printw [winfo fpixels $object $print(height)]
		set paperw [winfo fpixels $object $print(pheight)]
		set hs [expr {100.0*$printw/$paperw}]
		if {$hs<$print(scale)} {set print(scale) $hs}
	}
}

Classy_printdialog addoption -command {command Command {}} {}

Classy_printdialog addoption -savecommand {savecommand Savecommand {}} {}

Classy_printdialog addoption -width {width Width 595p} {}

Classy_printdialog addoption -height {height Height 842p} {}

Classy_printdialog addoption -autoscale {autoscale Autoscale 1} {}

Classy_printdialog addoption -scale {scale Scale 100} {}

Classy_printdialog addoption -portrait {portrait Portrait 1} {}

Classy_printdialog addoption -colormode {colormode Colormode mono} {}

Classy_printdialog addoption -scaledxy {scaledxy Scaledxy 1} {}

Classy_printdialog addoption -file {file File print.ps} {}

Classy_printdialog addoption -x {x X 0} {}

Classy_printdialog addoption -y {y Y 0} {}

Classy_printdialog addoption -pagex {pagex Pagex 0} {}

Classy_printdialog addoption -pagey {pagey Pagey 0} {}

Classy_printdialog addoption -pageanchor {pageanchor Pageanchor nw} {}

Classy_printdialog method print {} {private $object options
eval $options(-command) [array get options]}

Classy_printdialog method save {} {private $object options
eval $options(-command) -tofile 1 [array get options]}