proc main args {
set w [mainw]
zoom_init
select_init
line_init
polygon_init
text_init
rectangle_init
oval_init
arc_init
set w $w.canvas
select_start $w
bind Classy::Canvas <Enter> [list focus $w]
bind Classy::Canvas <Enter> [list focus $w]
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
	Classy::DynaTool $window.maintool  \
		-width 179 \
		-type MainTool \
		-height 21
	grid $window.maintool -row 0 -column 0 -columnspan 2 -sticky new
	Classy::Canvas $window.canvas \
		-papersize A4 \
		-height 50 \
		-relief sunken \
		-scrollregion {0 0 595p 842p} \
		-width 50
	grid $window.canvas -row 1 -column 0 -sticky nesw
	scrollbar $window.scrollbar1
	
	scrollbar $window.scrollv
	grid $window.scrollv -row 1 -column 1 -sticky nesw
	scrollbar $window.scrollh \
		-orient horizontal
	grid $window.scrollh -row 2 -column 0 -sticky nesw
	grid columnconfigure $window 0 -weight 1
	grid rowconfigure $window 1 -weight 1

	# End windows
	# Parse this
	$window configure \
		-destroycommand "exit" \
		-title [tk appname]
	$window.maintool configure \
		-cmdw [varsubst window {$window.canvas}]
	$window.canvas configure \
		-xscrollcommand "$window.scrollh set" \
		-yscrollcommand "$window.scrollv set"
	$window.scrollv configure \
		-command "$window.canvas yview"
	$window.scrollh configure \
		-command "$window.canvas xview"
	Classy::DynaMenu attachmainmenu MainMenu $window.canvas
	return $window
}

proc configwindow args {# ClassyTcl generated Toplevel
	if [regexp {^\.} $args] {
		set window [lshift args]
	} else {
		set window .configwindow
	}
	Classy::parseopt $args opt {-startw {} {}}
	# Create windows
	Classy::Toplevel $window  \
		-keepgeometry all
	button $window.font \
		-command {$current(w) itemconfigure _sel -font [Classy::getfont]} \
		-text {Select font}
	grid $window.font -row 6 -column 0 -sticky nesw
	Classy::NumEntry $window.x \
		-label X \
		-textvariable current(px) \
		-width 4
	grid $window.x -row 0 -column 0 -sticky nesw
	Classy::NumEntry $window.y \
		-label Y \
		-textvariable current(py) \
		-width 4
	grid $window.y -row 1 -column 0 -sticky nesw
	button $window.outline \
		-command {$current(w) itemconfigure _sel -outline [Classy::getcolor]} \
		-text {Outline color}
	grid $window.outline -row 4 -column 0 -sticky nesw
	button $window.fill \
		-command {$current(w) itemconfigure _sel -fill [Classy::getcolor]} \
		-text {Fill color}
	grid $window.fill -row 5 -column 0 -sticky nesw
	frame $window.arrow  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $window.arrow -row 8 -column 0 -sticky nesw
	radiobutton $window.arrow.but \
		-indicatoron 0 \
		-value but \
		-variable current(-capstyle)
	grid $window.arrow.but -row 0 -column 6 -sticky nesw
	radiobutton $window.arrow.round \
		-indicatoron 0 \
		-value round \
		-variable current(-capstyle)
	grid $window.arrow.round -row 0 -column 5 -sticky nesw
	radiobutton $window.arrow.projecting \
		-indicatoron 0 \
		-value projecting \
		-variable current(-capstyle)
	grid $window.arrow.projecting -row 0 -column 4 -sticky nesw
	radiobutton $window.arrow.both \
		-indicatoron 0 \
		-value both \
		-variable current(-arrow)
	grid $window.arrow.both -row 0 -column 3 -sticky nesw
	label $window.arrow.label1
	grid $window.arrow.label1 -row 0 -column 7 -sticky nesw
	Classy::NumEntry $window.arrow.l \
		-label L \
		-labelwidth 2 \
		-textvariable current(arrow_l) \
		-width 4
	grid $window.arrow.l -row 1 -column 0 -columnspan 8 -sticky nesw
	Classy::NumEntry $window.arrow.w \
		-label W \
		-labelwidth 2 \
		-textvariable current(arrow_w) \
		-width 4
	grid $window.arrow.w -row 2 -column 0 -columnspan 8 -sticky nesw
	Classy::NumEntry $window.arrow.sl \
		-label SL \
		-labelwidth 2 \
		-textvariable current(arrow_sl) \
		-width 4
	grid $window.arrow.sl -row 3 -column 0 -columnspan 8 -sticky nesw
	radiobutton $window.arrow.last \
		-indicatoron 0 \
		-value last \
		-variable current(-arrow)
	grid $window.arrow.last -row 0 -column 2 -sticky nesw
	radiobutton $window.arrow.first \
		-indicatoron 0 \
		-value first \
		-variable current(-arrow)
	grid $window.arrow.first -row 0 -column 1 -sticky nesw
	radiobutton $window.arrow.none \
		-indicatoron 0 \
		-value none \
		-variable current(-arrow)
	grid $window.arrow.none -row 0 -column 0 -sticky nesw
	grid columnconfigure $window.arrow 7 -weight 1
	Classy::NumEntry $window.numentry1 \
		-command {$current(w) itemconfigure _sel -width} \
		-label Width \
		-labelwidth 5 \
		-textvariable current(-width) \
		-width 4
	grid $window.numentry1 -row 2 -column 0 -sticky nesw
	Classy::Entry $window.entry1 \
		-command {$current(w) itemconfigure _sel -text} \
		-labelwidth 5 \
		-label Text \
		-textvariable current(-text) \
		-width 4
	grid $window.entry1 -row 3 -column 0 -sticky nesw
	frame $window.line  \
		-borderwidth 0 \
		-height 10 \
		-width 10
	grid $window.line -row 7 -column 0 -sticky nesw
	radiobutton $window.line.radiobutton1 \
		-command {$current(w) itemconfigure _sel -smooth $current(-smooth)} \
		-indicatoron 0 \
		-text Smooth \
		-value 1 \
		-variable current(-smooth)
	grid $window.line.radiobutton1 -row 0 -column 0 -sticky nesw
	radiobutton $window.line.nosmooth \
		-command {$current(w) itemconfigure _sel -smooth $current(-smooth)} \
		-indicatoron 0 \
		-text Straight \
		-value 0 \
		-variable current(-smooth)
	grid $window.line.nosmooth -row 0 -column 1 -sticky nesw
	grid columnconfigure $window.line 2 -weight 1
	Classy::Selector $window.selector1 \
		-command {$current(w) itemconfigure _sel -tags $current(-tags)} \
		-label Tags \
		-type text \
		-variable current(-tags)
	grid $window.selector1 -row 9 -column 0 -sticky nesw
	grid columnconfigure $window 0 -weight 1
	grid rowconfigure $window 9 -weight 1

	# End windows
	# Parse this
	$window configure \
		-destroycommand 
	$window.x configure \
		-command [varsubst window {update_x $window}]
	$window.y configure \
		-command [varsubst window {update_y $window}]
	$window.arrow.but configure \
		-command [varsubst window {line_cap $window}] \
		-image [Classy::geticon end_but]
	$window.arrow.round configure \
		-command [varsubst window {line_cap $window}] \
		-image [Classy::geticon end_round]
	$window.arrow.projecting configure \
		-command [varsubst window {line_cap $window}] \
		-image [Classy::geticon end_projecting]
	$window.arrow.both configure \
		-command [varsubst window {line_cap $window}] \
		-image [Classy::geticon arrow_both]
	$window.arrow.l configure \
		-command [varsubst window {invoke {} {line_cap $window}}]
	$window.arrow.w configure \
		-command [varsubst window {invoke {} {line_cap $window}}]
	$window.arrow.sl configure \
		-command [varsubst window {invoke {} {line_cap $window}}]
	$window.arrow.last configure \
		-command [varsubst window {line_cap $window}] \
		-image [Classy::geticon arrow_right]
	$window.arrow.first configure \
		-command [varsubst window {line_cap $window}] \
		-image [Classy::geticon arrow_left]
	$window.arrow.none configure \
		-command [varsubst window {line_cap $window}] \
		-image [Classy::geticon arrow_none]
# ClassyTcl Finalise
set ::current(w) $opt(-startw)
	return $window
	return $window
}

proc zoomdialog args {# ClassyTcl generated Dialog
	if [regexp {^\.} $args] {
		set window [lshift args]
	} else {
		set window .zoomdialog
	}
	Classy::parseopt $args opt {}
	# Create windows
	Classy::Dialog $window  \
		-destroycommand {destroy .try.dedit.work} \
		-keepgeometry all
	Classy::NumEntry $window.options.numentry1 \
		-command {zoom $current(w)} \
		-label Zoom \
		-textvariable current(zoom) \
		-width 4
	grid $window.options.numentry1 -row 0 -column 0 -columnspan 3 -sticky nesw
	radiobutton $window.options.radiobutton1 \
		-command {zoom $current(w) 100} \
		-text {100 %} \
		-value 100 \
		-variable current(zoom)
	grid $window.options.radiobutton1 -row 1 -column 0 -sticky nesw
	radiobutton $window.options.radiobutton2 \
		-command {zoom $current(w) 200} \
		-text {200 %} \
		-value 200 \
		-variable current(zoom)
	grid $window.options.radiobutton2 -row 2 -column 0 -sticky nesw
	radiobutton $window.options.radiobutton3 \
		-command {zoom $current(w) 400} \
		-text {400 %} \
		-value 400 \
		-variable current(zoom)
	grid $window.options.radiobutton3 -row 3 -column 0 -sticky nesw
	radiobutton $window.options.radiobutton5 \
		-command {zoom $current(w) 75} \
		-text {75 %} \
		-value 75 \
		-variable current(zoom)
	grid $window.options.radiobutton5 -row 1 -column 1 -sticky nesw
	radiobutton $window.options.radiobutton6 \
		-command {zoom $current(w) 50} \
		-text {50 %} \
		-value 50 \
		-variable current(zoom)
	grid $window.options.radiobutton6 -row 2 -column 1 -sticky nesw
	radiobutton $window.options.radiobutton7 \
		-command {zoom $current(w) 25} \
		-text {25 %} \
		-value 25 \
		-variable current(zoom)
	grid $window.options.radiobutton7 -row 3 -column 1 -sticky nesw
	grid columnconfigure $window.options 2 -weight 1

	# End windows
	# Parse this
	$window persistent set 
	return $window
}








