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
		-combopreset {echo print.ps} \
		-label File \
		-combo 10 \
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
		-label Width \
		-labelwidth 5 \
		-combo 10 \
		-width 6
	grid $object.options.paper.width -row 1 -column 0 -columnspan 3 -sticky nesw
	Classy::Entry $object.options.paper.height \
		-label Height \
		-labelwidth 5 \
		-combo 10 \
		-width 6
	grid $object.options.paper.height -row 2 -column 0 -columnspan 3 -sticky nesw
	Classy::OptionMenu $object.options.paper.select \
		-text A4
	grid $object.options.paper.select -row 0 -column 2 -sticky nesw
	$object.options.paper.select set A4
	checkbutton $object.options.paper.autoscale1 \
		-text {Auto scale}
	grid $object.options.paper.autoscale1 -row 3 -column 0 -sticky nesw
	Classy::NumEntry $object.options.paper.scale1 \
		-state disabled \
		-width 3
	grid $object.options.paper.scale1 -row 3 -column 1 -sticky nesw
	button $object.options.paper.button1 \
		-text {Advanced scaling}
	grid $object.options.paper.button1 -row 3 -column 2 -sticky nesw
	grid columnconfigure $object.options.paper 1 -weight 1
	Classy::Entry $object.options.printcommand \
		-combopreset {echo {lpr}} \
		-label {Print command} \
		-combo 10 \
		-width 4
	grid $object.options.printcommand -row 2 -column 0 -columnspan 3 -sticky nesw
	frame $object.options.frame1  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	
	frame $object.options.opts  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $object.options.opts -row 1 -column 0 -columnspan 3 -sticky nesw
	Classy::OptionBox $object.options.opts.orientation  \
		-label Orientation \
		-orient vertical \
		-bd 0 \
		-borderwidth 0
	grid $object.options.opts.orientation -row 0 -column 0 -sticky new
	$object.options.opts.orientation add 1 Portrait
	$object.options.opts.orientation add 0 Landscape
	$object.options.opts.orientation set 1
	Classy::OptionBox $object.options.opts.cmode1  \
		-label Colormode \
		-orient vertical \
		-relief flat
	grid $object.options.opts.cmode1 -row 0 -column 1 -sticky nesw
	$object.options.opts.cmode1 add color Color
	$object.options.opts.cmode1 add gray Gray
	$object.options.opts.cmode1 add mono Mono
	$object.options.opts.cmode1 set mono
	grid columnconfigure $object.options.opts 0 -weight 1
	grid columnconfigure $object.options.opts 1 -weight 1
	grid columnconfigure $object.options 1 -weight 1

	if {"$args" == "___Classy::Builder__create"} {return $object}
# ClassyTcl Initialise
$object _initvalues
	# Parse this
	$object.options.button1 configure \
		-command [varsubst object {$object.options.file set [Classy::selectfile]}]
	$object.options.file configure \
		-textvariable [privatevar $object options(-file)]
	$object.options.paper.width configure \
		-command [varsubst object {invoke {} {
			$object.options.paper.select set User
		}}] \
		-textvariable [privatevar $object options(-printwidth)]
	$object.options.paper.height configure \
		-command [varsubst object {invoke {} {
			$object.options.paper.select set User
		}}] \
		-textvariable [privatevar $object options(-printheight)]
	$object.options.paper.select configure \
		-command [varsubst object {
			$object configure -printsize
		}] \
		-list [list_unmerge [option get $object paperSizes PaperSizes]]
	$object.options.paper.autoscale1 configure \
		-background [Classy::realcolor darkBackground] \
		-command [varsubst object {invoke {value} {
			$object autoscale
		}}] \
		-variable [privatevar $object options(-autoscale)]
	$object.options.paper.scale1 configure \
		-textvariable [privatevar $object options(-scale)]
	$object.options.paper.button1 configure \
		-command [varsubst object {Classy_printscalingdialog $object.scaling -printdialog $object}]
	$object.options.printcommand configure \
		-textvariable [privatevar $object options(-printcommand)]
	$object.options.opts.orientation configure \
		-command [varsubst object {$object configure -portrait}] \
		-variable [privatevar $object options(-portrait)]
	$object.options.opts.cmode1 configure \
		-variable [privatevar $object options(-colormode)]
	$object add print Print [list $object print] default
	$object add save {Save to file} [list $object save]
	$object persistent set save
	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
# ClassyTcl Finalise
	$object _finalise $args
	return $object
}

Classy_printdialog addoption -printcommand {printCommand PrintCommand lpr} {
}

Classy_printdialog addoption -printsize {papersize Papersize A4} {
	private $object options
	if [string_equal $value User] {
		set page [list $options(-printwidth) $options(-printheight)]
	} else {
		set page [Classy::getpapersize $value]
	}
	set options(-printsize) $value
	if $options(-portrait) {
		set options(-printwidth) [lindex $page 0]
		set options(-printheight) [lindex $page 1]
	} else {
		set options(-printwidth) [lindex $page 1]
		set options(-printheight) [lindex $page 0]
	}
	$object.options.paper.select nocmdset $value
	Classy::todo $object autoscale
}

Classy_printdialog addoption -portrait {portrait Portrait 1} {
	private $object options
	set printw [winfo fpixels $object $options(-printwidth)]
	set printh [winfo fpixels $object $options(-printheight)]
	if {$printw < $printh} {
		if ![true $value] {$object switchorient}
	} else {
		if [true $value] {$object switchorient}
	}
	Classy::todo $object autoscale
}

Classy_printdialog addoption -command {command Command {}} {}

Classy_printdialog addoption -savecommand {savecommand Savecommand {}} {}

Classy_printdialog addoption -papersize {paperSize PaperSize A4} {
	private $object options
	set page [Classy::getpapersize $value]
	set options(-paperwidth) [lindex $page 0]
	set options(-paperheight) [lindex $page 1]
	Classy::todo $object autoscale
}

Classy_printdialog addoption -autoscale {autoscale Autoscale 1} {}

Classy_printdialog addoption -scale {scale Scale 100} {}

Classy_printdialog addoption -colormode {colormode Colormode mono} {}

Classy_printdialog addoption -scaledxy {scaledxy Scaledxy 1} {}

Classy_printdialog addoption -file {file File print.ps} {}

Classy_printdialog addoption -paperx {paperX PaperX 0} {}

Classy_printdialog addoption -papery {paperY PaperY 0} {}

Classy_printdialog addoption -printx {printX PrintX 0} {}

Classy_printdialog addoption -printy {printY PrintY 0} {}

Classy_printdialog addoption -selection {selection Selection 0} {}

Classy_printdialog addoption -pageanchor {pageanchor Pageanchor nw} {}

Classy_printdialog method autoscale {} {
	private $object options
	set printw [winfo fpixels $object $options(-printwidth)]
	set printh [winfo fpixels $object $options(-printheight)]
	if {$printw < $printh} {
		set options(-portrait) 1
	} else {
		set options(-portrait) 0
	}
	if $options(-autoscale) {
		set printw [winfo fpixels $object $options(-printwidth)]
		set paperw [winfo fpixels $object $options(-paperwidth)]
		set options(-scale) [expr {100.0*$printw/$paperw}]
		set printw [winfo fpixels $object $options(-printheight)]
		set paperw [winfo fpixels $object $options(-paperheight)]
		set hs [expr {100.0*$printw/$paperw}]
		if {$hs<$options(-scale)} {set options(-scale) $hs}
		catch {$object.options.paper.scale1 configure -state disabled}
		catch {$object.scaling.options.scale1 configure	-state disabled}
	} else {
		catch {$object.scaling.options.scale1 configure	-state normal}
		$object.options.paper.scale1 configure -state normal
	}
	$object _keepvalues
	$object.options.paper.select nocmdset $options(-printsize)
}

Classy_printdialog method paperselect {} {
	private $object options
	set size [$object.options.paper.select get]
	set ::Classy::print(size) $size
	if [string_equal $size User] {
		set papersize [list $options(-printwidth) $options(-printheight)]
	} else {
		set papersize [structlist_get [option get $object paperSizes PaperSizes] $size]
	}
	$object.options.paper.width nocmdset [lindex $papersize 0]
	$object.options.paper.height nocmdset [lindex $papersize 1]
	Classy::todo $object autoscale
}

Classy_printdialog method _initvalues {} {
	private $object options
	$object.options.paper.select nocmdset A4
	set options(-paperwidth) 595p
	set options(-paperheight) 842p
	set options(-printwidth) 595p
	set options(-printheight) 842p
	catch {array set options [Classy::Default get app Classy::print_keep]}
}

Classy_printdialog method _finalise {arg} {
	private $object options
	if [catch {structlist_get $arg -printsize} psize] {set psize A4}
	$object.options.paper.select nocmdset $psize
}

Classy_printdialog method _keepvalues {} {
	private $object options
	Classy::Default set app Classy::print_keep [array get options]
}

Classy_printdialog method switchorient {} {
	private $object options
	set temp $options(-printwidth)
	set options(-printwidth) $options(-printheight)
	set options(-printheight) $temp
}

Classy_printdialog method _printoptions {} {
	private $object options
	set list {}
	foreach option {
		-printwidth -printheight -portrait
		-paperx -papery -printx -printy -paperwidth -paperheight 
		-autoscale -scaledxy -pageanchor -scale
		-colormode -printcommand -file -selection
	} {
		lappend list $option $options($option)
	}
	return $list
}

Classy_printdialog method print {} {
	private $object options
	eval $options(-command) [$object _printoptions]
}

Classy_printdialog method save {} {
	private $object options
	eval $options(-command) -tofile 1 [$object _printoptions]
}
