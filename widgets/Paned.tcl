#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::Paned
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Paned {} {}
proc Paned {} {}
}
catch {Classy::Paned destroy}

option add *Classy::Paned.cursor sb_h_double_arrow widgetDefault
option add *Classy::Paned.width 3 widgetDefault
option add *Classy::Paned.background [option get . foreground Foreground] widgetDefault
option add *Classy::Paned.relief raised widgetDefault
option add *Classy::Paned.highlightThickness 0 widgetDefault

bind Classy::Paned <<Action>> {%W start %X %Y}
bind Classy::Paned <<Action-Motion>> {%W drag %X %Y}

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
Classy::Paned addoption -orient {orient Orient vertical}
Classy::Paned addoption -window {window Window {}}
Classy::Paned addoption -command {command Command {}}
Classy::Paned addoption -minsize {minsize MinSize 0}
Classy::Paned addoption -maxsize {maxsize MaxSize {}}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Paned method start {x y} {
	private $object data options
	set window $options(-window)
	set orient $options(-orient)
	if {"[winfo manager $window]"!="grid"} {error  "$window not managed by grid"}
	set info [grid info $window]
	regexp -- {-in ([^ ]*)} $info temp data(master)
	if {"$orient"=="vertical"} {
		$window configure -width 0
		regexp -- {-column ([^ ]*)} $info temp data(gridpos)
		set data(pos) $x
		set data(size) [winfo width $window]
		grid columnconfigure $data(master) $data(gridpos) -minsize $data(size)
	} else {
		$window configure -height 0
		regexp -- {-row ([^ ]*)} $info temp data(gridpos)
		set data(pos) $y
		set data(size) [winfo height $window]
		grid rowconfigure $data(master) $data(gridpos) -minsize $data(size)
	}
}

Classy::Paned method drag {x y} {
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
