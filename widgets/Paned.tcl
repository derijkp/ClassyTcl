#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::Paned
# ----------------------------------------------------------------------
#doc Paned title {
#Paned
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# creates a paned widget, which can be used to control the size
# of other widgets in a grid
#}
#doc {Paned options} h2 {
#	Paned specific options
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Paned {} {}
proc Paned {} {}
}

option add *Classy::Paned.cursor sb_h_double_arrow widgetDefault
option add *Classy::Paned.width 3 widgetDefault
option add *Classy::Paned.background [option get . foreground Foreground] widgetDefault
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
	super

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

#doc {Paned options -orient} option {-orient orient Orient} descr {
#}
Classy::Paned addoption -orient {orient Orient vertical}

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
	set info [grid info $window]
	regexp -- {-in ([^ ]*)} $info temp data(master)
	if {"$orient"=="vertical"} {
		regexp -- {-column ([^ ]*)} $info temp data(gridpos)
		set data(pos) $x
		set data(size) [winfo width $window]
		grid columnconfigure $data(master) $data(gridpos) -minsize $data(size)
	} else {
		regexp -- {-row ([^ ]*)} $info temp data(gridpos)
		set data(pos) $y
		set data(size) [winfo height $window]
		grid rowconfigure $data(master) $data(gridpos) -minsize $data(size)
	}
}

Classy::Paned method _drag {x y} {
	private $object data options
	if {"$options(-orient)"=="vertical"} {
		set size [expr $data(size)+$x-$data(pos)]
		if {("$options(-maxsize)" != "")&&($size > $options(-maxsize))} {
			set size $options(-maxsize)
		}
		if {$size < $options(-minsize)} {
			set size $options(-minsize)
		}
		grid columnconfigure $data(master) $data(gridpos) -minsize $size
	} else {
		set size [expr $data(size)+$y-$data(pos)]
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
