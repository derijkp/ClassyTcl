#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::Paned
# ----------------------------------------------------------------------
#doc Paned title {
#Paned
#} index {
# New widgets
#} shortdescr {
# control the size of another widget
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# creates a paned widget, which can be used to control the size
# of other widgets in a grid
#}
#doc {Paned options} h2 {
#	Paned specific options
#}
# These will be added to tclIndex by Classy::auto_mkindex
#auto_index Paned

option add *Classy::Paned.hcursor sb_h_double_arrow widgetDefault
option add *Classy::Paned.vcursor sb_v_double_arrow widgetDefault
option add *Classy::Paned.width 3 widgetDefault
option add *Classy::Paned.height 3 widgetDefault
catch {option add *Classy::Paned.background [Classy::realcolor Foreground] widgetDefault}
option add *Classy::Paned.relief raised widgetDefault
option add *Classy::Paned.highlightThickness 0 widgetDefault

bind Classy::Paned <<Action>> {%W _start %X %Y}
bind Classy::Paned <<Action-Motion>> {%W _drag %X %Y}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Paned
Classy::export Paned {}

Classy::Paned classmethod init {args} {
	# REM Create object
	# -----------------
	super init

	# REM Configure initial arguments
	# -------------------------------
	$object configure -cursor [option get $object hcursor HCursor]
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

#doc {Paned options -orient} option {-orient orient Orient} descr {
#}
Classy::Paned addoption -orient {orient Orient horizontal} {
	if {"$value" == "vertical"} {
		$object configure -cursor [option get $object vcursor VCursor]
	} else {
		$object configure -cursor [option get $object hcursor HCursor]
	}
}

#doc {Paned options -window} option {-window window Window} descr {
#}
Classy::Paned addoption -window {window Window {}}

#doc {Paned options -command} option {-command command Command} descr {
#}
Classy::Paned addoption -command {command Command {}}

#doc {Paned options -minsize} option {-minsize minsize MinSize} descr {
#}
Classy::Paned addoption -minsize {minsize MinSize 0}

#doc {Paned options -maxsize} option {-maxsize maxsize MaxSize} descr {
#}
Classy::Paned addoption -maxsize {maxsize MaxSize {}}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Paned method _start {x y} {
	private $object data options
	set window $options(-window)
	set orient $options(-orient)
	if {"[winfo manager $window]"!="grid"} {error  "$window not managed by grid"}
	set temp [grid info $object]
	array set info [grid info $window]
	set data(master) $info(-in)
	if {"$orient"=="horizontal"} {
		set data(gridpos) $info(-column)
		if {[structlget $temp -column] < $info(-column)} {
			set data(rev) 1
		} else {
			set data(rev) 0
		}
		set data(pos) $x
		set data(size) [winfo width $window]
		grid columnconfigure $data(master) $data(gridpos) -minsize $data(size)
	} else {
		set data(gridpos) $info(-row)
		if {[structlget $temp -row] < $info(-row)} {
			set data(rev) 1
		} else {
			set data(rev) 0
		}
		set data(pos) $y
		set data(size) [winfo height $window]
		grid rowconfigure $data(master) $data(gridpos) -minsize $data(size)
	}
}

Classy::Paned method _drag {x y} {
	private $object data options
	if {"$options(-orient)"=="horizontal"} {
		if !$data(rev) {
			set size [expr $data(size)+$x-$data(pos)]
		} else {
			set size [expr $data(size)-$x+$data(pos)]
		}
		if {("$options(-maxsize)" != "")&&($size > $options(-maxsize))} {
			set size $options(-maxsize)
		}
		if {$size < $options(-minsize)} {
			set size $options(-minsize)
		}
		grid columnconfigure $data(master) $data(gridpos) -minsize $size
	} else {
		if !$data(rev) {
			set size [expr $data(size)+$y-$data(pos)]
		} else {
			set size [expr $data(size)-$y+$data(pos)]
		}
		if {("$options(-maxsize)" != "")&&($size > $options(-maxsize))} {
			set size $options(-maxsize)
		}
		if {$size < $options(-minsize)} {
			set size $options(-minsize)
		}
		grid rowconfigure $data(master) $data(gridpos) -minsize $size
	}
	set command [getprivate $object options(-command)]
	if {"$command"!=""} {eval $command}
}

