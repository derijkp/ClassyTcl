proc main args {
set w [mainw .mainw]
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
focus $w
}

Classy::Toplevel subclass mainw
mainw method init args {
	super init
	# Create windows
	Classy::DynaTool $object.maintool  \
		-width 179 \
		-type MainTool \
		-height 42
	grid $object.maintool -row 0 -column 0 -columnspan 2 -sticky new
	Classy::Canvas $object.canvas \
		-papersize A4 \
		-height 50 \
		-relief sunken \
		-scrollregion {0 0 595p 842p} \
		-width 50
	grid $object.canvas -row 1 -column 0 -sticky nesw
	scrollbar $object.scrollbar1
	
	scrollbar $object.scrollv
	grid $object.scrollv -row 1 -column 1 -sticky nesw
	scrollbar $object.scrollh \
		-orient horizontal
	grid $object.scrollh -row 2 -column 0 -sticky nesw
	grid columnconfigure $object 0 -weight 1
	grid rowconfigure $object 1 -weight 1

	# End windows
	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object configure \
		-destroycommand [varsubst object {destroy $object
exit}] \
		-title [tk appname]
	$object.maintool configure \
		-cmdw [varsubst object {$object.canvas}]
	$object.canvas configure \
		-xscrollcommand "$object.scrollh set" \
		-yscrollcommand "$object.scrollv set"
	$object.scrollv configure \
		-command "$object.canvas yview"
	$object.scrollh configure \
		-command "$object.canvas xview"
	Classy::DynaMenu attachmainmenu MainMenu $object.canvas
	return $object

	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}}

Classy::Toplevel subclass configwindow
configwindow method init args {
	super init
	# Create windows
	button $object.font \
		-command {$current(w) itemconfigure _sel -font [Classy::getfont]} \
		-text {Select font}
	grid $object.font -row 6 -column 0 -sticky nesw
	Classy::NumEntry $object.x \
		-label X \
		-textvariable current(px) \
		-width 4
	grid $object.x -row 0 -column 0 -sticky nesw
	Classy::NumEntry $object.y \
		-label Y \
		-textvariable current(py) \
		-width 4
	grid $object.y -row 1 -column 0 -sticky nesw
	button $object.outline \
		-command {$current(w) itemconfigure _sel -outline [Classy::getcolor]} \
		-text {Outline color}
	grid $object.outline -row 4 -column 0 -sticky nesw
	button $object.fill \
		-command {$current(w) itemconfigure _sel -fill [Classy::getcolor]} \
		-text {Fill color}
	grid $object.fill -row 5 -column 0 -sticky nesw
	frame $object.arrow  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $object.arrow -row 8 -column 0 -sticky nesw
	radiobutton $object.arrow.but \
		-indicatoron 0 \
		-value but \
		-variable current(-capstyle)
	grid $object.arrow.but -row 0 -column 6 -sticky nesw
	radiobutton $object.arrow.round \
		-indicatoron 0 \
		-value round \
		-variable current(-capstyle)
	grid $object.arrow.round -row 0 -column 5 -sticky nesw
	radiobutton $object.arrow.projecting \
		-indicatoron 0 \
		-value projecting \
		-variable current(-capstyle)
	grid $object.arrow.projecting -row 0 -column 4 -sticky nesw
	radiobutton $object.arrow.both \
		-indicatoron 0 \
		-value both \
		-variable current(-arrow)
	grid $object.arrow.both -row 0 -column 3 -sticky nesw
	label $object.arrow.label1
	grid $object.arrow.label1 -row 0 -column 7 -sticky nesw
	Classy::NumEntry $object.arrow.l \
		-label L \
		-labelwidth 2 \
		-textvariable current(arrow_l) \
		-width 4
	grid $object.arrow.l -row 1 -column 0 -columnspan 8 -sticky nesw
	Classy::NumEntry $object.arrow.w \
		-label W \
		-labelwidth 2 \
		-textvariable current(arrow_w) \
		-width 4
	grid $object.arrow.w -row 2 -column 0 -columnspan 8 -sticky nesw
	Classy::NumEntry $object.arrow.sl \
		-label SL \
		-labelwidth 2 \
		-textvariable current(arrow_sl) \
		-width 4
	grid $object.arrow.sl -row 3 -column 0 -columnspan 8 -sticky nesw
	radiobutton $object.arrow.last \
		-indicatoron 0 \
		-value last \
		-variable current(-arrow)
	grid $object.arrow.last -row 0 -column 2 -sticky nesw
	radiobutton $object.arrow.first \
		-indicatoron 0 \
		-value first \
		-variable current(-arrow)
	grid $object.arrow.first -row 0 -column 1 -sticky nesw
	radiobutton $object.arrow.none \
		-indicatoron 0 \
		-value none \
		-variable current(-arrow)
	grid $object.arrow.none -row 0 -column 0 -sticky nesw
	grid columnconfigure $object.arrow 7 -weight 1
	Classy::NumEntry $object.numentry1 \
		-command {$current(w) itemconfigure _sel -width} \
		-label Width \
		-labelwidth 5 \
		-textvariable current(-width) \
		-width 4
	grid $object.numentry1 -row 2 -column 0 -sticky nesw
	Classy::Entry $object.entry1 \
		-command {$current(w) itemconfigure _sel -text} \
		-labelwidth 5 \
		-label Text \
		-textvariable current(-text) \
		-width 4
	grid $object.entry1 -row 3 -column 0 -sticky nesw
	frame $object.line  \
		-borderwidth 0 \
		-height 10 \
		-width 10
	grid $object.line -row 7 -column 0 -sticky nesw
	radiobutton $object.line.radiobutton1 \
		-command {$current(w) itemconfigure _sel -smooth $current(-smooth)} \
		-indicatoron 0 \
		-text Smooth \
		-value 1 \
		-variable current(-smooth)
	grid $object.line.radiobutton1 -row 0 -column 0 -sticky nesw
	radiobutton $object.line.nosmooth \
		-command {$current(w) itemconfigure _sel -smooth $current(-smooth)} \
		-indicatoron 0 \
		-text Straight \
		-value 0 \
		-variable current(-smooth)
	grid $object.line.nosmooth -row 0 -column 1 -sticky nesw
	grid columnconfigure $object.line 2 -weight 1
	Classy::Selector $object.selector1 \
		-command {$current(w) itemconfigure _sel -tags $current(-tags)} \
		-label Tags \
		-type text \
		-variable current(-tags)
	grid $object.selector1 -row 9 -column 0 -sticky nesw
	grid columnconfigure $object 0 -weight 1
	grid rowconfigure $object 9 -weight 1

	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object.x configure \
		-command [varsubst object {update_x $object}]
	$object.y configure \
		-command [varsubst object {update_y $object}]
	$object.arrow.but configure \
		-command [varsubst object {line_cap $object}] \
		-image [Classy::geticon end_but]
	$object.arrow.round configure \
		-command [varsubst object {line_cap $object}] \
		-image [Classy::geticon end_round]
	$object.arrow.projecting configure \
		-command [varsubst object {line_cap $object}] \
		-image [Classy::geticon end_projecting]
	$object.arrow.both configure \
		-command [varsubst object {line_cap $object}] \
		-image [Classy::geticon arrow_both]
	$object.arrow.l configure \
		-command [varsubst object {invoke {} {line_cap $object}}]
	$object.arrow.w configure \
		-command [varsubst object {invoke {} {line_cap $object}}]
	$object.arrow.sl configure \
		-command [varsubst object {invoke {} {line_cap $object}}]
	$object.arrow.last configure \
		-command [varsubst object {line_cap $object}] \
		-image [Classy::geticon arrow_right]
	$object.arrow.first configure \
		-command [varsubst object {line_cap $object}] \
		-image [Classy::geticon arrow_left]
	$object.arrow.none configure \
		-command [varsubst object {line_cap $object}] \
		-image [Classy::geticon arrow_none]
	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
	return $object
}

configwindow addoption -startw {startw Startw {}} {set ::current(w) $value}

Classy::Dialog subclass zoomdialog
zoomdialog method init args {
	super init
	# Create windows
	Classy::NumEntry $object.options.numentry1 \
		-command {zoom $current(w)} \
		-label Zoom \
		-textvariable current(zoom) \
		-width 4
	grid $object.options.numentry1 -row 0 -column 0 -columnspan 3 -sticky nesw
	radiobutton $object.options.radiobutton1 \
		-command {zoom $current(w) 100} \
		-text {100 %} \
		-value 100 \
		-variable current(zoom)
	grid $object.options.radiobutton1 -row 1 -column 0 -sticky nesw
	radiobutton $object.options.radiobutton2 \
		-command {zoom $current(w) 200} \
		-text {200 %} \
		-value 200 \
		-variable current(zoom)
	grid $object.options.radiobutton2 -row 2 -column 0 -sticky nesw
	radiobutton $object.options.radiobutton3 \
		-command {zoom $current(w) 400} \
		-text {400 %} \
		-value 400 \
		-variable current(zoom)
	grid $object.options.radiobutton3 -row 3 -column 0 -sticky nesw
	radiobutton $object.options.radiobutton5 \
		-command {zoom $current(w) 75} \
		-text {75 %} \
		-value 75 \
		-variable current(zoom)
	grid $object.options.radiobutton5 -row 1 -column 1 -sticky nesw
	radiobutton $object.options.radiobutton6 \
		-command {zoom $current(w) 50} \
		-text {50 %} \
		-value 50 \
		-variable current(zoom)
	grid $object.options.radiobutton6 -row 2 -column 1 -sticky nesw
	radiobutton $object.options.radiobutton7 \
		-command {zoom $current(w) 25} \
		-text {25 %} \
		-value 25 \
		-variable current(zoom)
	grid $object.options.radiobutton7 -row 3 -column 1 -sticky nesw
	grid columnconfigure $object.options 2 -weight 1

	# End windows
	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object persistent set 
	return $object

	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}}

