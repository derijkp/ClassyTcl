#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# WindowBuilder
# ----------------------------------------------------------------------
#doc WindowBuilder title {
#WindowBuilder
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
#}
#doc {WindowBuilder options} h2 {
#	WindowBuilder specific options
#}
#doc {WindowBuilder command} h2 {
#	WindowBuilder specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::WindowBuilder {} {}
proc WindowBuilder {} {}
}

source [file join $::class::dir widgets WindowBuilderTypes.tcl]
# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::WindowBuilder
Classy::export WindowBuilder {}

Classy::WindowBuilder classmethod init {args} {
	super toplevel
	wm protocol $object WM_DELETE_WINDOW [list catch [list $object destroy]]
	private $object current options
	set current(w) ""
	set w [Classy::window $object]
	Classy::DynaMenu makemenu Classy::WindowBuilder .classy__.windowBuildermenu $object Classy::WindowBuilderMenu
	bindtags $object [list $object Classy::WindowBuilder all]
	$w configure -menu .classy__.windowBuildermenu
	frame $object.toolhold
		Classy::DynaTool maketool Classy::WindowBuilder $object.tool $object
		if [catch {structlget $args -icons}] {lappend args -icons {}}
		Classy::DynaTool define Classy::WindowBuilder_$object {separator}
		Classy::DynaTool maketool Classy::WindowBuilder_$object $object.icons $object
		Classy::OptionMenu $object.children -list {Select {Select parent}} \
			-command "$object select \[$object.children get\]"
		$object.children set Select
		Classy::Entry $object.current -label "Current window" -width 15 \
			-command "$object rename \[$object.current get\]"
		grid $object.tool -in $object.toolhold -row 0 -column 0 -sticky ew
		grid $object.children -in $object.toolhold -row 0 -column 1 -sticky nsew
		grid $object.current -in $object.toolhold -row 0 -column 2 -sticky nsew
	Classy::NoteBook $object.book
	$object.book configure -width 100 -height 100
	$object.book propagate off
	frame $object.edit
	$object.book manage Special $object.edit -sticky nwse -command [list $object drawedit]
	$object _createattributes $object.attr
	$object.book manage Attributes $object.attr -sticky nwse -command [list $object attribute rebuild]
	$object _createbindings $object.bindings
	$object.book manage Bindings $object.bindings -sticky nwse -command [list $object bindings rebuild]
	$object _creategeometry $object.geom
	$object.book manage Geometry $object.geom -sticky nwse
	$object drawcode $object.code
	$object.book manage Code $object.code -sticky nwse
	$object.book select Special
	frame $object.fcode
	Classy::Text $object.fcode.text -wrap none -width 10 -height 10 -state disabled -cursor X_cursor \
		-xscrollcommand [list $object.fcode.hscroll set] -yscrollcommand [list $object.fcode.vscroll set]
	scrollbar $object.fcode.vscroll -orient vertical -command [list $object.fcode.text yview]
	scrollbar $object.fcode.hscroll -orient horizontal -command [list $object.fcode.text xview]
	grid $object.fcode.text $object.fcode.vscroll -sticky nwse
	grid $object.fcode.hscroll -sticky we
	grid columnconfigure $object.fcode 0 -weight 1
	grid rowconfigure $object.fcode 0 -weight 1
	$object.book manage "Final Code" $object.fcode -sticky nwse -command [list $object finalcode]
	$object _createfastgeometry $object.fastgeom

	grid $object.toolhold -row 0 -column 0 -columnspan 2 -sticky ew
	grid $object.icons -row 1 -column 0 -columnspan 2 -sticky ew
	grid $object.fastgeom -row 2 -column 0 -sticky nsew
	grid $object.book -row 2 -column 1 -sticky nsew
	grid rowconfigure $object 2 -weight 1	
	grid columnconfigure $object 1 -weight 1	
	bind Classy::WindowBuilder_$object <<Action>> [list $object select %W]

	# REM Initialise options and variables
	# ------------------------------------

	# REM Create bindings
	# --------------------
	bind Classy::WindowBuilder_$object <<Action>> [list $object select %W]
	bind Classy::WindowBuilder_$object <<Configure>> [list $object _drawselectedw]

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	update idletasks
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::WindowBuilder addoption -icons {icons Icons {}} {
	private $object options
	if {"$value" == ""} {
		set options(-icons) {
			Tk {
				Builder/frame frame Frame
				Builder/button button Button
				Builder/entry	entry Entry
				Builder/label label Label
				Builder/listbox listbox Listbox
				Builder/checkbutton checkbutton "Check button"
				Builder/radiobutton radiobutton "Radio button" 
				Builder/message message "Message"
				Builder/scroll scrollbar "Scrollbar"
				Builder/scale scale Scale
				Builder/text text "Text"
				Builder/canvas canvas Canvas
			}
			Classy {
				Builder/entry Classy::Entry "ClassyTcl Entry"
				Builder/entry Classy::NumEntry "ClassyTcl Numerical Entry"
				optionbox Classy::OptionBox "ClassyTcl OptionBox"
				optionmenu Classy::OptionMenu "ClassyTcl OptionMenu"
				Builder/text Classy::Text "ClassyTcl Text"
				Builder/canvas Classy::Canvas "ClassyTcl Canvas"
			}
		}
		set value $options(-icons)
	}
	$object icons [lindex $value 0]
}

# ------------------------------------------------------------------
#  destroy
# ------------------------------------------------------------------

#doc {WindowBuilder command destroy} cmd {
#pathname destroy 
#} descr {
#}
Classy::WindowBuilder method destroy {} {
	Classy::DynaTool delete Classy::WindowWindowBuilder_$object
	bind Classy::WindowBuilder_$object <<Action>> {}
	$object.tree destroy
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------
Classy::WindowBuilder method _inconsw {group w} {
	private $object options
	Classy::OptionMenu $w -list [lunmerge $options(-icons)]
	$w set $group
	$w configure -command "$object icons \[$w get\]"
}

Classy::WindowBuilder method icons {group} {
	private $object options
	set data "widget \{$object _inconsw [list $group]\} \{Select icons\}\n"
	foreach {icon type descr} [structlget $options(-icons) $group] {
		append data "action [list $icon] [list $descr] \{%W add $type\}\n"
	}
	Classy::DynaTool define Classy::WindowBuilder_$object $data
}

proc Classy::WindowBuilder_add {w} {
	Classy::Entry $w
	set p [winfo parent $w]
	$w configure -command [varsubst {w p} {
		[DynaTool cmdw $p] add [$w get]
	}]

}

Classy::WindowBuilder method select {w} {
	private $object current prev data
	set window $data(base)
	switch -glob -- $w {
		{} {
			catch {unset current}
			$object _drawselectedw {}
			return
		}
		"Select parent" {
			set w [winfo parent $current(w)]
		}
		"Select" {
			return
		}
		{$window*} {
			eval set w $w
		}
	}
	$object _drawselectedw $w
	if {[string first $data(base) $w] != 0} return
	catch {unset current}
	if [info exists data(redir,$w)] {set w $data(redir,$w)}
	set current(w) $w
	$object geometryset rebuild
	switch [$object.book get] {
		Attributes {$object attribute rebuild}
		Bindings {$object bindings rebuild}
		Special {$object drawedit}
	}
	$object.current nocmdset [$object outw $w]
	$object.children configure -list [concat {Select {Select parent}} [winfo children $w]]
	$object.children set Select
	focus $w
}

Classy::WindowBuilder method _drawselectedw {args} {
	private $object current data
	if {"$args" == ""} {
		if ![info exists current(w)] return
		set selw $current(w)
	} else {
		set selw [lindex $args 0]
	}
	set w $object.work
	if ![winfo exists $w.classy__nw] {
		foreach name {nw n ne e se s sw w} {
			catch {frame $w.classy__$name -width 6 -height 6 -background black}
		}
	}
	if {"$selw" == ""} {
		foreach name {nw n ne e se s sw w} {
			catch {place forget $w.classy__$name}
		}
	} else {
		set x [expr {[winfo rootx $selw] - [winfo rootx $object.work]}]
		set y [expr {[winfo rooty $selw] - [winfo rooty $object.work]}]
		set wi [winfo width $selw]
		set he [winfo height $selw]
		place $w.classy__nw -x [expr {$x-3}] -y [expr {$y-3}]
		place $w.classy__n -x [expr {$x+$wi/2-3}] -y [expr {$y-3}]
		place $w.classy__ne -x [expr {$x+$wi-3}] -y [expr {$y-3}]
		place $w.classy__e -x [expr {$x+$wi-3}] -y [expr {$y+$he/2-3}]
		place $w.classy__se -x [expr {$x+$wi-3}] -y [expr {$y+$he-3}]
		place $w.classy__s -x [expr {$x+$wi/2-3}] -y [expr {$y+$he-3}]
		place $w.classy__sw -x [expr {$x-3}] -y [expr {$y+$he-3}]
		place $w.classy__w -x [expr {$x-3}] -y [expr {$y+$he/2-3}]
		foreach name {nw n ne e se s sw w} {
			catch {raise $w.classy__$name}
		}
	}
}

Classy::WindowBuilder method add {type args} {
	private $object current currentgrid
	set w [$object newoption]
	switch $type {
		entry {
			entry $w -textvariable ::Classy::value($w)
		}
		text {
			text $w -width 20 -height 10
		}
		label {
			label $w -text label
		}
		checkbutton - radiobutton - button {
			$type $w -text button
		}
		default {
			$type $w 
		}
	}
	if {"$args" != ""} {eval $w configure $args}
	if ![info exists currentgrid(-column)] {
		set currentgrid(-column) 0
	}
	set p [winfo parent $w]
	set row [$object newpos $p $currentgrid(-column)]
	grid $w -sticky nwse -column $currentgrid(-column) -row $row
	$object startedit $w
	$object select $w
}

Classy::WindowBuilder method newpos {p col} {
	set row -1
	foreach slave [grid slaves $p -column $col] {
		set temp [structlget [grid info $slave] -row]
		if {$temp > $row} {set row $temp}
	}
	incr row
	return $row
}

Classy::WindowBuilder method newoption {} {
	private $object current
	switch [$object itemclass $current(w)] {
		Toplevel - Frame {
			set parent $current(w)
		}
		default {
			set parent [winfo parent $current(w)]
		}
	}
	switch [winfo class $parent] {
		Frame {}
		Toplevel {}
		default {error "Adding child windows to to parent window \"$parent\" is not possible"}
	}
	set num 1
	while {[winfo exists $parent.o$num]} {
		incr num
	}
	return $parent.o$num
}

Classy::WindowBuilder method _dialogoption {option def limit} {
	private $object data
	if ![regexp ^- $option] {set option "-$option"}
	laddnew data(options) $option
	set data(options,$option,def) $def
	set data(options,$option,limit) $limit
}

Classy::WindowBuilder method drawcode {w} {
	private $object
	frame $w 
	button $w.newopt -text "New Option" -command [varsubst {object w} {
		catch {destroy $w.temp}
		Classy::InputBox $w.temp -title "New Option" -title "New Option" -command {
			$object _dialogoption [$w.temp get] {} {}
			$w.chooseopt configure -list [getprivate $object data(options)]
			$w.chooseopt set [$w.temp get]
		}
	}]
	button $w.delete -text "Delete" -command [varsubst {object w} {
		if {"[$w.chooseopt get]" == "window"} {error "Cannot remove window option"}
		setprivate $object data(options) [lremove [getprivate $object data(options)] [$w.chooseopt get]]
		$w.chooseopt configure -list [getprivate $object data(options)]
		$w.chooseopt set window
		$w.chooseopt command
	}]
	Classy::OptionMenu $w.chooseopt -command [varsubst {object w} {
		$w.default configure -textvariable [privatevar $object data(options,[$w.chooseopt get],def)]
		$w.limit configure -textvariable [privatevar $object data(options,[$w.chooseopt get],limit)]
	}]
	Classy::Entry $w.default -label "Default value"
	Classy::Entry $w.limit -label "Limit to"
	$w.chooseopt set window
	grid $w.newopt $w.delete $w.chooseopt $w.default $w.limit -sticky we
	label $w.initlabel -text "Initialisation code"
	grid $w.initlabel - - - - -sticky we
	frame $w.icode
	Classy::Text $w.icode.text -wrap none -width 10 -height 10 \
		-xscrollcommand [list $w.icode.hscroll set] -yscrollcommand [list $w.icode.vscroll set]
	scrollbar $w.icode.vscroll -orient vertical -command [list $w.icode.text yview]
	scrollbar $w.icode.hscroll -orient horizontal -command [list $w.icode.text xview]
	grid $w.icode.text $w.icode.vscroll -sticky nwse
	grid $w.icode.hscroll -sticky we
	grid columnconfigure $w.icode 0 -weight 1
	grid rowconfigure $w.icode 0 -weight 1
	grid $w.icode - - - - -sticky nwse
	grid columnconfigure $w 3 -weight 1
	grid columnconfigure $w 4 -weight 1
	grid rowconfigure $w 2 -weight 1
}

Classy::WindowBuilder method close {} {
	private $object data current
	Classy::Default set geom $object [wm geometry $object]
	if [info exists data(base)] {
		if ![Classy::yorn "Are you sure you want to abort the current editing session"] {
			return 1
		}
	}
	if [winfo exists $object.work] {
		Classy::Default set geom $object.work.keep [wm geometry $object.work]
		destroy $object.work
		catch {Classy::Default unset geom $object.work}
	}
	catch {unset current}
	catch {unset data}
	wm withdraw $object
	return 0
}

Classy::WindowBuilder method new {type function file} {
	global auto_index
	if [file isdir $file] {return -code error "please select a file instead of a directory"}
	set f [open $file a]
	switch $type {
		dialog {
			puts $f "\nproc $function args \{# ClassyTcl generated Dialog"
			puts $f "\tif \[regexp \{^\\.\} \$args] \{"
			puts $f "\t\tset window \[lpop args\]"
			puts $f "\t\} else \{"
			puts $f "\t\tset window .$function"
			puts $f "\t\}"
			puts $f "\tClassy::parseopt \$args opt {}"
			puts $f "\t# Create windows"
			puts $f "\tClassy::Dialog \$window"
			puts $f "\t#Initialisation code"			
			puts $f "\}"
		}
		toplevel {
			puts $f "\nproc $function args \{# ClassyTcl generated Toplevel"
			puts $f "\tif \[regexp \{^\\.\} \$args] \{"
			puts $f "\t\tset window \[lpop args\]"
			puts $f "\t\} else \{"
			puts $f "\t\tset window .$function"
			puts $f "\t\}"
			puts $f "\tClassy::parseopt \$args opt {}"
			puts $f "\t# Create windows"
			puts $f "\ttoplevel \$window"
			puts $f "\t#Initialisation code"			
			puts $f "\}"
		}
	}
	close $f
}

Classy::WindowBuilder method open {file function} {
	global auto_index
	private $object data
	catch {destroy $object.work}
	catch {unset current}
	catch {unset data}
	set code [Classy::loadfunction $file $function]
	set data(function) $function
	set data(file) $file
	set data(code) $code
	switch -regexp -- $code {
		{# ClassyTcl generated Dialog}  {
			uplevel #0 $code
			set data(type) dialog
			::$function $object.work
			$object parsecode $data(code)
			set data(base) $object.work
			$object edit
		}
		{# ClassyTcl generated Toplevel}  {
			uplevel #0 $code
			set data(type) toplevel
			::$function $object.work
			$object parsecode $data(code)
			set data(base) $object.work
			$object edit
		}
		default {
			error "unknown type"
		}
	}
	update idletasks
	set geom [split [Classy::Default get geom $object.work.keep] "x+"]
	if {[llength $geom] == 4} {
		wm geometry $object.work +[lindex $geom 2]+[lindex $geom 3]
	}
}

Classy::WindowBuilder method parsecode {code} {
	private $object data
	set window $object.work
	set list [Extral::splitcomplete $code]
	foreach line $list {
		if [regexp {;#f (.+)$} $line temp options] {
			eval set w [lindex $line 1]
			foreach {option value} $options {
				set data(opt$option,$w) $value
			}
		} elseif [regexp {^#ClassyTcl init$} $line] break
	}
	$object.code.icode.text delete 1.0 end
	set init ""
	regexp "\n#ClassyTcl init\n(.+)\n\}\n" $code temp init
	$object.code.icode.text insert end $init
	set data(options) window
	regexp "\t\tset window (\\.\[^\n\]+)" $code temp data(options,window,def)
	regexp "Classy::parseopt \\\$args opt (\[^\n\]+)" $code temp options
	if [info exists options] {
		foreach {option limit def} [lindex $options 0] {
			lappend data(options) $option
			set data(options,$option,limit) $limit
			set data(options,$option,def) $def
		}
	}
	$object.code.chooseopt configure -list $data(options)
	$object.code.chooseopt set window
}

Classy::WindowBuilder method edit {} {
	private $object current data
	$object startedit $data(base)
}

Classy::WindowBuilder method restore {{base {}}} {
	private $object current data
	set data(code) [$object code]
	if {"$base" == ""} {
		set base $data(base)
	}
	$object select {}
	$object stopedit $base
}

Classy::WindowBuilder method test {} {
	private $object current data
	set data(code) [$object code]
	uplevel #0 $data(code)
	$data(function)
}

Classy::WindowBuilder method code {{function {}}} {
	private $object current data
	catch {set keep $current(w)}
	$object select {}
	set base $data(base)
	if {"$function" == ""} {
		set function $data(function)
	}
	if {"$data(type)" == "dialog"} {
		set body "proc $function args \{# ClassyTcl generated Dialog\n"
	} else {
		set body "proc $function args \{# ClassyTcl generated Toplevel\n"
	}
	append body "\tif \[regexp \{^\\.\} \$args] \{\n"
	append body "\t\tset window \[lpop args\]\n"
	append body "\t\} else \{\n"
	append body "\t\tset window $data(options,window,def)\n"
	append body "\t\}\n"
	set list ""
	foreach option [lremove $data(options) window] {
		lappend list $option $data(options,$option,limit) $data(options,$option,def)
	}
	append body "\tClassy::parseopt \$args opt [list $list]\n"
	append body "\t# Create windows\n"
	append body [$object generate $base]
	set init [string trimright [$object.code.icode.text get 1.0 end]]
	if {"$init" != ""} {
		append body "\n#ClassyTcl init\n"
		append body $init
		append body "\n"
	}
	append body "\}"
	catch {$object select $keep}
	return $body
}

Classy::WindowBuilder method getoptions {base} {
	private $object data
	set result ""
	set rem ""
	foreach line [$base configure] {
		if {[llength $line] != 5} continue
		set option [lindex $line 0]
		if {"$option" == "-class"} continue
		if [info exists data(opt$option,$base)] {
			append result " $option $data(opt$option,$base)"
			lappend rem $option $data(opt$option,$base)
		} else {
			set def [lindex $line 3]
			set real [lindex $line 4]
			if {"$def" != "$real"} {
				if {"[option get $base [lindex $line 1] [lindex $line 2]]" != "$real"} {
					append result " $option [list $real]"
				}
			}
		}
	}
	if {"$rem" != ""} {
		append result " ;#f $rem"
	}
	return $result
}

Classy::WindowBuilder method gridwconf {base} {
	array set ginfo [grid info $base]
	set parent [winfo parent $base]
	set options [list -row $ginfo(-row) -column $ginfo(-column)]
	if {"$ginfo(-in)" != "$parent"} {
		append options " -in [$object outw $ginfo(-in)]"
	}
	foreach {option def} {-columnspan 1 -rowspan 1 -ipadx 0 -ipady 0 -padx 0 -pady 0 -sticky {}} {
		if {"$ginfo($option)" != "$def"} {
			append options " $option $ginfo($option)"
		}
	}
	return "grid [$object outw $base] $options"
}

Classy::WindowBuilder method gridconf {base} {
	set body ""
	set col [grid size $base]
	set row [lpop col]
	set outw [$object outw $base]
	for {set i 0} {$i<$col} {incr i} {
		set options ""
		foreach {opt value} [grid columnconfigure $base $i] {
			if {$value != 0} {lappend options $opt $value}
		}
		if {"$options" != ""} {
			append body "\tgrid columnconfigure $outw $i $options\n"
		}
	}
	for {set i 0} {$i<$row} {incr i} {
		set options ""
		foreach {opt value} [grid rowconfigure $base $i] {
			if {$value != 0} {lappend options $opt $value}
		}
		if {"$options" != ""} {
			append body "\tgrid rowconfigure $outw $i $options\n"
		}
	}
	return $body
}

Classy::WindowBuilder method current {args} {
	private $object current
	if {"$args" == ""} {
		return $current(w)
	} else {
		eval eval $current(w) $args
	}
}

Classy::WindowBuilder method drawedit {} {
	private $object current
	eval destroy [winfo children $object.edit]
	Classy::cleargrid $object.edit
	if {"$current(w)" == ""} return
	set type [$object itemclass $current(w)]
	if {"[info commands ::Classy::WindowBuilder::edit_$type]" != ""} {
		::Classy::WindowBuilder::edit_$type $object $object.edit
	} else {
		label $object.edit.gen -text "no special functions available"
		grid $object.edit.gen -sticky we
		label $object.edit.unknown -text "for type \"$type\""
		grid $object.edit.unknown -sticky we
		grid rowconfigure $object.edit 100 -weight 1
	}
}

Classy::WindowBuilder method startedit {list} {
	private $object data
	foreach base $list {
		set type [$object itemclass $base]
		if {"[info commands ::Classy::WindowBuilder::start_$type]" != ""} {
			::Classy::WindowBuilder::start_$type $object $base
		} else {
			if ![info exists data(bind,$base)] {
				set data(bind,$base) [bindtags $base]
			}
			bindtags $base Classy::WindowBuilder_$object
		}
	}
}

Classy::WindowBuilder method stopedit {list} {
	private $object data current
	foreach base $list {
		set type [$object itemclass $base]
		if {"[info commands ::Classy::WindowBuilder::stop_$type]" != ""} {
			::Classy::WindowBuilder::stop_$type $object $base
		} elseif [info exists data(bind,$base)] {
			bindtags $base $data(bind,$base)
			unset data(bind,$base)
		}
	}
}

Classy::WindowBuilder method delete {{list {}}} {
	private $object data current
	$object finalcode
	if {"$list" == ""} {set list $current(w)}
	set p [winfo parent [lindex $list end]]
	foreach base $list {
		set type [$object itemclass $base]
		if {"[info commands ::Classy::WindowBuilder::delete_$type]" != ""} {
			::Classy::WindowBuilder::delete_$type $object $base
		} else {
			if [info exists data(bind,$base)] {unset data(bind,$base)}
			destroy $base
		}
	}
	$object select $p
}

Classy::WindowBuilder method outw {base} {
	private $object data
	return [replace $base [list $data(base) {$window}]]
}

Classy::WindowBuilder method generate {list} {
	set body {}
	foreach base $list {
		set type [$object itemclass $base]
		if {"[info commands ::Classy::WindowBuilder::generate_$type]" != ""} {
			append body [::Classy::WindowBuilder::generate_$type $object $base]
		} else {
			set cmd [string tolower $type]
			set outw [$object outw $base]
			append body "\t$cmd $outw[$object getoptions $base]\n"
			append body "\t[$object gridwconf $base]\n"
			foreach event [bind $base] {
				if [info exists data(ev$event,$base)] {
					set binding $data(ev$event,$base)
				} else {
					set binding [list [bind $base $event]]
				}
				append body "\tbind $outw $event $binding\n"
			}
		}
	}
	return $body	
}

Classy::WindowBuilder method itemclass {w} {
	private $object data
	if [info exists data(class,$w)] {
		return $data(class,$w)
	} else {
		return [winfo class $w]
	}
}

Classy::WindowBuilder method finalcode {} {
	private $object data
	if [winfo exists $data(base)] {
		set data(code) [$object code]
	}
	$object.fcode.text configure -state normal
	$object.fcode.text delete 1.0 end
	$object.fcode.text insert end $data(code)
	$object.fcode.text configure -state disabled
}

Classy::WindowBuilder method recreate {} {
	private $object data
	if [winfo exists $data(base)] {
		if ![catch {set code [$object code]}] {
			set data(code) $code
		}
	}
	uplevel #0 $data(code)
	$object parsecode $data(code)
	catch {destroy $data(base)}
	$data(function) $data(base)
	$object edit
}

Classy::WindowBuilder method cut {} {
	global auto_index
	private $object data options browse
	set file $browse(file)
	if {"$browse(type)" == "file"} {
		set browse(clipbf) $file
		set browse(clipb) [readfile $file]
		clipboard clear
		clipboard append [readfile $file]
		file rename -force $file $file~
		$object.tree deletenode $file
		return $file
	} elseif {"$browse(type)" == "function"} {
		set result ""
		set work ""
		set function $browse(name)
		foreach line [split [readfile $file] "\n"] {
			append work "$line\n"
			if [info complete $work] {
				if ![string match "proc $function *" $work] {
					append result $work
				} else {
					set browse(clipbf) {}
					set browse(clipb) $work
					clipboard clear
					clipboard append $work
				}
				set work ""
			}
		}
		file copy -force $file $file~
		writefile $file $result
		catch {auto_mkindex [file dirname $file] *.tcl}
		catch {unset auto_index($function)}
		$object _drawselect {}
		$object.tree deletenode [list $file $function]
		return $function
	}
}

Classy::WindowBuilder method copy {} {
	global auto_index
	private $object data options browse
	set file $browse(file)
	if {"$browse(type)" == "file"} {
		set browse(clipbf) $file
		set browse(clipb) [readfile $file]
		clipboard clear
		clipboard append $browse(clipb)
		return $file
	} elseif {"$browse(type)" == "function"} {
		set browse(clipb) {}
		set result ""
		set work ""
		set function $browse(name)
		foreach line [split [readfile $file] "\n"] {
			append work "$line\n"
			if [info complete $work] {
				if ![string match "proc $function *" $work] {
					append result $work
				} else {
					set browse(clipbf) {}
					set browse(clipb) $work
					clipboard clear
					clipboard append $work
				}
				set work ""
			}
		}
		return $function
	}
}

Classy::WindowBuilder method paste {} {
	global auto_index
	private $object data options browse
	set file $browse(file)
	if [file isdir $file] {
		if {"$browse(clipbf)" == ""} {
			set file [file join $file clipboard.tcl]
		} else {
			set file [file join $file [file tail $browse(clipbf)]]
		}
	}
	set f [open $file a]
	puts $f $browse(clipb)
	close $f
	$object browse $browse(file)
	$object browse $browse(file)
}

Classy::WindowBuilder method save {} {
	global auto_index
	private $object data
	set file $data(file)
	switch $data(type) {
		dialog - toplevel {
			set function $data(function)
			set code [$object code]
			uplevel #0 $code
			if ![info complete $code] {
				error "error: generated code not complete (contains unmatched braces, parentheses, ...)"
			}
			set result ""
			set work ""
			set done 0
			foreach line [split [readfile $file] "\n"] {
				append work "$line\n"
				if [info complete $work] {
					if [string match "proc $function args *" $work] {
						append result "$code\n"
						set done 1
					} else {
						append result $work
					}
					set work ""
				}
			}
			if !$done {
				append result "$code\n"
			}
			file copy -force $file $file~
			writefile $file $result
			catch {auto_mkindex [file dirname $file] *.tcl}
			set auto_index($function) [list source $file]
			set result $function
		}
		function {	
			file copy -force $file $file~
			$object.feditor save
			uplevel #0 source $data(file)
			catch {auto_mkindex [file dirname $file] *.tcl}
			set result $file
		}
	}
	return $result
}

Classy::WindowBuilder method gridremovecolumn {p col} {
	set slaves [grid slaves $p -column $col]
	if {"$slaves" != ""} {error "cannot remove column $col: it is not empty"}
	set colsize [grid size $p]
	set rowsize [lpop colsize]
	incr col
	for {set i $col} {$i<$colsize} {incr i} {
		set to [expr {$i-1}]
		foreach slave [grid slaves $p -column $i] {
			set info [grid info $slave]
			grid $slave -column $to
		}
		eval grid columnconfigure $p $to [grid columnconfigure $p $i]
	}
	grid columnconfigure $p $i -weight 0 -pad 0 -minsize 0
}

Classy::WindowBuilder method gridremoverow {p row} {
	set slaves [grid slaves $p -row $row]
	if {"$slaves" != ""} {error "cannot remove row $row: it is not empty"}
	set colsize [grid size $p]
	set rowsize [lpop colsize]
	incr row
	for {set i $row} {$i<$rowsize} {incr i} {
		set to [expr {$i-1}]
		foreach slave [grid slaves $p -row $i] {
			set info [grid info $slave]
			grid $slave -row $to
		}
		eval grid rowconfigure $p $to [grid rowconfigure $p $i]
	}
	grid rowconfigure $p $i -weight 0 -pad 0 -minsize 0
}

Classy::WindowBuilder method gridinsertcolumn {p col} {
	set colsize [grid size $p]
	set rowsize [lpop colsize]
	set i $colsize
	incr i -1
	for {} {$i>=$col} {incr i -1} {
		set to [expr {$i+1}]
		foreach slave [grid slaves $p -column $i] {
			set info [grid info $slave]
			grid $slave -column $to -row [structlget $info -row]
		}
		eval grid columnconfigure $p $to [grid columnconfigure $p $i]
	}
	grid columnconfigure $p $col -weight 0 -pad 0 -minsize 0
}

Classy::WindowBuilder method gridinsertrow {p row} {
	set colsize [grid size $p]
	set rowsize [lpop colsize]
	set i $rowsize
	incr i -1
	for {} {$i>=$row} {incr i -1} {
		set to [expr {$i+1}]
		foreach slave [grid slaves $p -row $i] {
			set info [grid info $slave]
			grid $slave -column [structlget $info -column] -row $to
		}
		eval grid rowconfigure $p $to [grid rowconfigure $p $i]
	}
	grid rowconfigure $p $row -weight 0 -pad 0 -minsize 0
}

Classy::WindowBuilder method gridmovecol {p row from to} {
	foreach slave [grid slaves $p] {
		set info [grid info $slave]
		set slaves([structlget $info -row],[structlget $info -column]) $slave
	}
	if {"[$object.fastgeom.sel get]" == "Move window"} {
		if ![info exists slaves($row,$from)] return
		set colsize [grid size $p]
		set rowsize [lpop colsize]
		set w $slaves($row,$from)
		unset slaves($row,$from)
		if {$to < 0} {
			if {"[array names slaves *,$from]" == ""} return
			$object gridinsertcolumn $p 0
			grid $w -column 0 -row $row
		} elseif ![info exists slaves($row,$to)] {
			grid $w -column $to -row $row
		} else {
			set pos $row
			while ([info exists slaves($pos,$to)]) {
				grid configure $slaves($pos,$to) -row [expr {$pos+1}]
				incr pos
			}
			grid $w -column $to -row $row
		}
		if {"[grid slaves $p -column $from]" == ""} {
			$object gridremovecolumn $p $from
		}
	} else {
		if {$from == $to} return
		if {$from < $to} {incr to} else {incr from}
		$object gridinsertcolumn $p $to
		foreach slave [grid slaves $p -column $from] {
			set info [grid info $slave]
			grid $slave -row [structlget $info -row] -column $to
		}
		eval grid columnconfigure $p $to [grid columnconfigure $p $from]
		$object gridremovecolumn $p $from
	}
}

proc gi {} {
	private .try.dedit currentgrid
	set p .try.dedit.work.options
	foreach slave [grid slaves $p] {
		set info [grid info $slave]
		puts "grid $slave -row [structlget $info -row] -column [structlget $info -column]"
	}	
	puts "set from $currentgrid(-row)"
	puts "set col $currentgrid(-column)"
}

Classy::WindowBuilder method gridmoverow {p col from to} {
	foreach slave [grid slaves $p] {
		set info [grid info $slave]
		set slaves([structlget $info -row],[structlget $info -column]) $slave
	}
	if {"[$object.fastgeom.sel get]" == "Move window"} {
		if ![info exists slaves($from,$col)] return
		set colsize [grid size $p]
		set rowsize [lpop colsize]
		set w $slaves($from,$col)
		unset slaves($from,$col)
		if {$to < 0} {
			if {"[array names slaves $from,*]" == ""} return
			$object gridinsertrow $p 0
			grid $w -column $col -row 0
		} elseif ![info exists slaves($to,$col)] {
			grid $w -column $col -row $to
		} elseif {$from>$to} {
			set pos $to
			while ([info exists slaves($pos,$col)]) {
				if {$pos == $from} break
				grid configure $slaves($pos,$col) -row [expr {$pos+1}] -column $col
				incr pos
			}
			grid $w -column $col -row $to
		} else {
			set pos $to
			while ([info exists slaves($pos,$col)]) {
				if {$pos == $from} break
				grid configure $slaves($pos,$col) -row [expr {$pos-1}] -column $col
				incr pos -1
			}
			grid $w -column $col -row $to
		}
		if {"[grid slaves $p -row $from]" == ""} {
			$object gridremoverow $p $from
		}
	} else {
		if {$from == $to} return
		if {$from < $to} {incr to} else {incr from}
		$object gridinsertrow $p $to
		foreach slave [grid slaves $p -row $from] {
			set info [grid info $slave]
			grid $slave -row $to -column [structlget $info -column]
		}
		eval grid rowconfigure $p $to [grid rowconfigure $p $from]
		$object gridremoverow $p $from
	}
}

Classy::WindowBuilder method gridremove {p col row} {
	if [info exists slave($row)] {
		set w $slave($row)	
		grid forget $w
	} else {
		set w ""
	}
	foreach slave [grid slaves $p -column $col] {
		set slave([structlget [grid info $slave] -row]) $slave
	}
	set pos $row
	while ([info exists slave($pos)]) {
		grid configure $slave($pos) -row [expr {$pos+1}]
		incr pos
	}
	return $w
}

Classy::WindowBuilder method gridinsert {p col row} {
	foreach slave [grid slaves $p -column $col] {
		set slave([structlget [grid info $slave] -row]) $slave
	}
	set pos $row
	while ([info exists slave($pos)]) {
		grid configure $slave($pos) -row [expr {$pos+1}]
		incr pos
	}
}

Classy::WindowBuilder method geometryset {type {value {}}} {
	private $object current currentgrid
	if {"$type" != "rebuild"} {
		if ![info exists currentgrid(-in)] {
			return -code error "Not managed by grid"
		}
		set p $currentgrid(-in)
	}
	switch -- $type {
		up {
			$object gridmoverow $p $currentgrid(-column) $currentgrid(-row) [expr {$currentgrid(-row)-1}]
		}
		down {
			$object gridmoverow $p $currentgrid(-column) $currentgrid(-row) [expr {$currentgrid(-row)+1}]
		}
		left {
			$object gridmovecol $p $currentgrid(-row) $currentgrid(-column) [expr {$currentgrid(-column)-1}]
		}
		right {
			$object gridmovecol $p $currentgrid(-row) $currentgrid(-column) [expr {$currentgrid(-column)+1}]
		}
		columnweight {
			grid columnconfigure $p $currentgrid(-column) -weight $value
		}
		rowweight {
			grid rowconfigure $p $currentgrid(-row) -weight $value
		}
		resizecolumn {
			grid columnconfigure $p $currentgrid(-column) -weight $value
		}
		resizerow {
			grid rowconfigure $p $currentgrid(-row) -weight $value
		}
		-row {
			$object gridremove $p $currentgrid(-column) $currentgrid(-row)
			$object gridinsert $p $currentgrid(-column) $value
			grid configure $current(w) -row $value
		}
		-column {
			$object gridremove $p $currentgrid(-column) $currentgrid(-row)
			$object gridinsert $p $currentgrid(-column) $value
			grid configure $current(w) -column $value
		}
		rebuild {}
		dir {
			set value ""
			foreach dir {n s e w} {
				if $currentgrid(sticky$dir) {
					append value $dir
				}
			}
			grid configure $current(w) -sticky $value
		}		
		default {
			grid configure $current(w) $type $value
		}
	}
	catch {unset currentgrid}
	array set currentgrid [grid info $current(w)]
	if ![info exists currentgrid(-in)] return
	set p $currentgrid(-in)
	foreach option {weight minsize pad} {
		set currentgrid(row$option) [grid rowconfigure $p $currentgrid(-row) -$option]
		set currentgrid(column$option) [grid columnconfigure $p $currentgrid(-column) -$option]
	}
	if $currentgrid(rowweight) {set currentgrid(rowresize) 1} else {set currentgrid(rowresize) 0}
	if $currentgrid(columnweight) {set currentgrid(columnresize) 1} else {set currentgrid(columnresize) 0}
	foreach {type id option} {
		row row -row
		row weight rowweight
		row min rowminsize
		row rpad rowpad
		row span -rowspan
		row pad -padx
		row ipad -ipadx
		column column -column
		column weight columnweight
		column min columnminsize
		column cpad columnpad
		column span -columnspan
		column pad -pady
		column ipad -ipady
	} {
		$object.geom.$type.$id nocmdset $currentgrid($option)
	}
	$object.fastgeom.column nocmdset $currentgrid(-column)
	$object.fastgeom.row nocmdset $currentgrid(-row)
	$object.fastgeom.columnspan nocmdset $currentgrid(-columnspan)
	$object.fastgeom.rowspan nocmdset $currentgrid(-rowspan)
	$object.fastgeom.sticky nocmdset $currentgrid(-sticky)
	foreach dir {n s e w} {
		if [regexp $dir $currentgrid(-sticky)] {
			$object.fastgeom.st.$dir select
		} else {
			$object.fastgeom.st.$dir deselect
		}
	}
	update idletasks
	Classy::todo $object _drawselectedw
}

Classy::WindowBuilder method _creategeometry {w} {
	private $object currentgrid
	frame $w 
#	set w .try.dedit.geom
#	eval destroy [winfo children $w]
#	Classy::cleargrid $w
	frame $w.row -relief groove -bd 2
	grid $w.row -row 0 -column 1 -sticky we
		label $w.row.label -text "Row"
		grid $w.row.label -sticky we
	frame $w.column -relief groove -bd 2
	grid $w.column -row 0 -column 0 -sticky we
		label $w.column.label -text "Column"
		grid $w.column.label -sticky we
		foreach {type id label option} {
			row row "Row" -row
			row span "Span" -rowspan
			row weight "Resize" rowweight
			row min "Minimum size" rowminsize
			row pad "External padding" -padx
			row ipad "internal padding" -ipadx
			row rpad "Row padding" rowpad
			column column "Column" -column
			column span "Span" -columnspan
			column weight "Resize" columnweight
			column min "Minimum size" columnminsize
			column pad "External padding" -pady
			column ipad "internal padding" -ipady
			column cpad "Column padding" columnpad
		} {
			Classy::NumEntry $w.$type.$id -label $label -labelwidth 15 -constraint int -width 1 \
				 -command "$object geometryset $option \[$w.$type.$id get\]"
			grid $w.$type.$id -sticky we
		}
		grid rowconfigure $w.row 100 -weight 1
		grid columnconfigure $w.row 0 -weight 1
		grid rowconfigure $w.column 100 -weight 1
		grid columnconfigure $w.column 0 -weight 1
	grid rowconfigure $w 1 -weight 1
	grid columnconfigure $w 0 -weight 1
	grid columnconfigure $w 1 -weight 1
}

Classy::WindowBuilder method _createfastgeometry {w} {
	private $object currentgrid
	frame $w 
#	set w .try.dedit.fastgeom
#	eval destroy [winfo children $w]
#	Classy::cleargrid $w
	frame $w.move
	grid $w.move -row 0 -column 0 -columnspan 2
		button $w.move.up -image [Classy::geticon Builder/arrow_up] -anchor c -command "$object geometryset up"
		button $w.move.down -image [Classy::geticon Builder/arrow_down] -anchor c -command "$object geometryset down"
		button $w.move.left -image [Classy::geticon Builder/arrow_left] -anchor c -command "$object geometryset left"
		button $w.move.right -image [Classy::geticon Builder/arrow_right] -anchor c -command "$object geometryset right"
		grid $w.move.up -row 0 -column 1
		grid $w.move.down -row 2 -column 1
		grid $w.move.right -row 1 -column 2
		grid $w.move.left -row 1 -column 0
	Classy::OptionMenu $w.sel -list {{Move window} {Move row/col}}
	$w.sel set {Move window}
	Classy::NumEntry $w.row -label "Row" -labelwidth 6 -constraint int -width 4 \
		 -command "$object geometryset -row \[$w.row get\]"
	Classy::NumEntry $w.column -label "Column" -labelwidth 6 -constraint int -width 4 \
		 -command "$object geometryset -row \[$w.column get\]"
	grid $w.sel -row 1 -column 0 -sticky we
	grid $w.row -row 2 -column 0 -sticky we
	grid $w.column -row 3 -column 0 -sticky we
	frame $w.resize
	grid $w.resize -row 4 -column 0 -sticky we
		button $w.resize.all -text "Resize" -command "$object geometryset resizerow 1;$object geometryset resizecolumn 1"
		set var [privatevar $object currentgrid(rowresize)]
		checkbutton $w.resize.row -image [Classy::geticon Builder/resize_row] -indicatoron 0 -anchor c \
			-variable $var \
			-command "$object geometryset resizerow \[set $var\]"
		set var [privatevar $object currentgrid(columnresize)]
		checkbutton $w.resize.column -image [Classy::geticon Builder/resize_col] -indicatoron 0 -anchor c \
			-variable $var \
			-command "$object geometryset resizecolumn \[set $var\]"
		grid $w.resize.all -row 0 -column 0 -sticky we
		grid $w.resize.row -row 0 -column 1 -sticky we
		grid $w.resize.column -row 0 -column 2 -sticky we
	Classy::Entry $w.sticky -command "$object geometryset -sticky \[$w.sticky get\]" -width 4 \
		-label Sticky -labelwidth 6
	grid $w.sticky -row 5 -column 0 -sticky we
	frame $w.st
	grid $w.st -row 6 -column 0
		checkbutton $w.st.n -image [Classy::geticon Builder/sticky_n] -indicatoron 0 -anchor c \
			-variable [privatevar $object currentgrid(stickyn)] \
			-command "$object geometryset dir"
		checkbutton $w.st.s -image [Classy::geticon Builder/sticky_s] -indicatoron 0 -anchor c \
			-variable [privatevar $object currentgrid(stickys)] \
			-command "$object geometryset dir"
		checkbutton $w.st.e -image [Classy::geticon Builder/sticky_e] -indicatoron 0 -anchor c \
			-variable [privatevar $object currentgrid(stickye)] \
			-command "$object geometryset dir"
		checkbutton $w.st.w -image [Classy::geticon Builder/sticky_w] -indicatoron 0 -anchor c \
			-variable [privatevar $object currentgrid(stickyw)] \
			-command "$object geometryset dir"
		button $w.st.all -image [Classy::geticon Builder/sticky_all] -anchor c \
			 -command "$w.sticky set nesw"
		button $w.st.none -image [Classy::geticon Builder/sticky_none] -anchor c \
			 -command "$w.sticky set {}"
		button $w.st.we -image [Classy::geticon Builder/sticky_we] -anchor c \
			 -command "$w.sticky set we"
		button $w.st.ns -image [Classy::geticon Builder/sticky_ns] -anchor c \
			 -command "$w.sticky set ns"
		grid $w.st.none -row 7 -column 1 -sticky we
		grid $w.st.n -row 6 -column 1 -sticky we
		grid $w.st.s -row 8 -column 1 -sticky we
		grid $w.st.e -row 7 -column 2 -sticky we
		grid $w.st.w -row 7 -column 0 -sticky e
		grid $w.st.we -row 6 -column 3 -sticky e
		grid $w.st.ns -row 7 -column 3 -sticky e
		grid $w.st.all -row 8 -column 3 -sticky e
	Classy::NumEntry $w.rowspan -label "Rowspan" -labelwidth 9 -constraint int -width 2 \
		 -command "$object geometryset -rowspan \[$w.rowspan get\]"
	Classy::NumEntry $w.columnspan -label "Columnspan" -labelwidth 9 -constraint int -width 2 \
		 -command "$object geometryset -columnspan \[$w.columnspan get\]"
	grid $w.rowspan -row 7 -column 0 -sticky we
	grid $w.columnspan -row 8 -column 0 -sticky we
	grid rowconfigure $w 100 -weight 1
}

Classy::WindowBuilder method attribute {action args} {
	private $object current data
	if ![info exists current(w)] return
	set w $current(w)
	set option [lindex $args 0]
	switch -- $action {
		setf? {
			set value [lindex $args 1]
			switch -regexp -- $value {
				{^".*"$} - {^\[.*\]$} {
					set window $data(base)
					catch {eval $w configure $option $value} ::Classy::err
					set data(opt$option,$w) $value
				}
				{\$window} {
					set window $data(base)
					set value "\[varsubst window [list $value]\]"
					catch {eval $w configure $option $value} ::Classy::err
					set data(opt$option,$w) $value
				}
				default {
					$w configure $option $value
					catch {unset data(opt$option,$w)}
				}
			}
		}
		setf {
			set value [lindex $args 1]
			catch {eval $w configure $option $value} ::Classy::err
			set data(opt$option,$w) $value
		}
		set {
			set value [lindex $args 1]
			$w configure $option $value
			catch {unset data(opt$option,$w)}
		}
		get {
			if [info exists data(opt$option,$w)] {
				if [regexp "^\\\[varsubst window" $data(opt$option,$w)] {
					set len [string length $data(opt$option,$w)]
					return [lindex [string range $data(opt$option,$w) 1 [expr {$len-2}]] 2]
				} else {
					return $data(opt$option,$w)
				}
			} else {
				return [$w cget $option]
			}
		}
		select {
			set v $object.attr.edit
			set list $current(group,[$object.attr.type get])
			$object.attr.list activate [lsearch $list $option]
			$object.attr.list selection clear 0 end
			$object.attr.list selection set [lsearch $list $option]
			eval destroy [winfo children $v]
			Classy::cleargrid $v
			if [info exists ::Classy::WindowBuilder::options($option)] {
				set entry [set ::Classy::WindowBuilder::options($option)]
				if {[llength $entry] == 2} {
					set entry [lindex $entry 1]
				}
			} else {
				set entry line
			}
			label $v.label -text $option
			grid $v.label -row 0 -column 0 -sticky we
			set title [string range $option 1 end]
			set value [$object attribute get $option]
			switch $entry {
				text {
					button $v.change -text "Change $title" -command [varsubst {object v option} {
						$object attribute setf? $option [string trimright [$v.value get 1.0 end]]
						focus $object.attr.list
					}]
					Classy::Text $v.value
					grid $v.change -row 2 -column 0 -sticky we
					grid $v.value -row 3 -column 0 -sticky nswe
					grid columnconfigure $v 0 -weight 1
					grid rowconfigure $v 3 -weight 1
					$v.value insert end $value
				}
				int {
					Classy::NumEntry $v.value -width 2 -label "$title Value"	-orient stacked \
						-command [varsubst {object v option} {
							$object attribute setf? $option [$v.value get]
							focus $object.attr.list
						}]
					grid $v.value -row 2 -column 0 -sticky we
					grid columnconfigure $v 0 -weight 1
					$v.value nocmdset $value
					grid rowconfigure $v 3 -weight 1
				}
				default {
					Classy::Entry $v.value -width 2 -label "$title Value"	-orient stacked \
						-command [varsubst {object v option} {
							$object attribute setf? $option [$v.value get]
							focus $object.attr.list
						}] -textvariable [privatevar $object current(value)]
					grid $v.value -row 2 -column 0 -sticky we
					grid columnconfigure $v 0 -weight 1
					$v.value nocmdset $value
				}
			}
			switch $entry {
				color {
					$v.value configure -label "$title color"
					button $v.select -text "Select color" -command "$v.value set \[Classy::getcolor -initialcolor \[$v.value get\]\]"
					grid $v.select -row 3 -column 0 -sticky we
					grid rowconfigure $v 4 -weight 1
				}
				font {
					$v.value configure -label "$title font"
					button $v.select -text "Select font" -command "$v.value set \[Classy::getfont -font \[$v.value get\]\]"
					grid $v.select -row 3 -column 0 -sticky we
					grid rowconfigure $v 4 -weight 1
				}
				justify {
					frame $v.select
					set column 0
					foreach {type icon} {left justify_left.gif center justify_center.gif right justify_right.gif} {
						radiobutton $v.select.$type -indicatoron 0 -text $type \
							-image [Classy::geticon Builder/$icon] \
							-command  "$v.value set $type" -value $type \
							-variable [privatevar $object current(value)]
						grid $v.select.$type -row 0 -column $column
						incr column
					}
					grid $v.select -row 3 -column 0 -sticky nwe
					grid rowconfigure $v 4 -weight 1
				}
				relief {
					catch {destroy $v.select}
					frame $v.select
					set row 0
					set column 0
					foreach {type icon} {raised relief_raised sunken relief_sunken flat relief_flat ridge relief_ridge solid relief_solid groove relief_groove} {
						radiobutton $v.select.$type -indicatoron 0 -text $type \
							-image [Classy::geticon Builder/$icon] \
							-command  "$v.value set $type" -value $type \
							-variable [privatevar $object current(value)]
						grid $v.select.$type -row $row -column $column -sticky we
						incr column
						if {$column == 3} {set column 0;incr row}
					}
					grid $v.select -row 3 -column 0 -sticky nwe
					grid rowconfigure $v 4 -weight 1
				}
				anchor {
					frame $v.select
					set row 0
					set column 0
					foreach {type icon} {nw anchor_nw n anchor_n ne anchor_ne w anchor_w center anchor_center e anchor_e sw anchor_sw s anchor_s se anchor_se} {
						radiobutton $v.select.$type -indicatoron 0 -text $type \
							-image [Classy::geticon Builder/$icon] \
							-command  "$v.value set $type" -value $type \
							-variable [privatevar $object current(value)]
						grid $v.select.$type -row $row -column $column -sticky we
						incr column
						if {$column == 3} {set column 0;incr row}
					}
					$v.select.center configure -text c
					grid $v.select -row 3 -column 0 -sticky nwe
					grid rowconfigure $v 4 -weight 1
				}
				default {
					grid rowconfigure $v 3 -weight 1
				}
			}
			focus $v.value
		}
		group {
			$object.attr.list delete 0 end 
			if [info exists current(group,$option)] {
				eval $object.attr.list insert end $current(group,$option)
				$object attribute select [lindex $current(group,$option) 0]
				focus $object.attr.list
			}
		}
		rebuild {
			set cgroup [$object.attr.type get]
			set coption [$object.attr.list get active]
			foreach type [array names current group,*] {
				unset current($type)
			}
			set list ""
			foreach conf [$w configure] {
				if {[llength $conf] == 2} continue
				set option [lindex $conf 0]
				if [info exists ::Classy::WindowBuilder::options($option)] {
					set entry [set ::Classy::WindowBuilder::options($option)]
					if {[llength $entry] == 2} {
						set type [lshift entry]
					} else {
						set type Misc
					}
				} else {
					set type Misc
				}
				lappend current(group,$type) $option
				laddnew list $type
			}
			$object.attr.type configure -list [lsort $list]
			if {[lsearch $list $cgroup] != -1} {
				$object.attr.type set $cgroup
			} else {
				$object.attr.type set Display
			}
			$object.attr.list delete 0 end
			set list $current(group,[$object.attr.type get])
			eval $object.attr.list insert end $list
			set pos [lsearch $list $coption]
			if {$pos != -1} {
				$object attribute select [lindex $list $pos]
			} else {
				$object attribute select [lindex $list 0]
			}
			focus $object.attr.list
		}
		default {
			grid configure $current(w) $type $value
		}
	}
	update idletasks
	Classy::todo $object _drawselectedw
}

Classy::WindowBuilder method _createattributes {w} {
	private $object current
	frame $w
	eval destroy [winfo children $w]
	Classy::cleargrid $w
	Classy::OptionMenu $w.type -list {Misc Colors Sizes} -command "$object attribute group \[$w.type get\]"
	listbox $w.list -yscrollcommand [list $w.scroll set] -takefocus 1
	scrollbar $w.scroll -orient vertical -command [list $w.list yview]
	frame $w.edit
	grid $w.type -row 0 -column 0 -columnspan 2 -sticky nwse
	grid $w.list -row 1 -column 0 -sticky nwse
	grid $w.scroll -row 1 -column 1 -sticky nwse
	grid $w.edit -row 0 -column 2 -rowspan 2 -sticky nwse
	grid columnconfigure $w 2 -weight 1
	grid rowconfigure $w 1 -weight 1
	bind $w.list <<Invoke>> [varsubst {w object} {
		$object attribute select [$w.list get active]
	}]
	bind $w.list <<ButtonRelease-Action>> [varsubst {w object} {
		tkCancelRepeat
		%W activate @%x,%y
		$object attribute select [$w.list get active]
	}]
}

Classy::WindowBuilder method bindings {action args} {
	private $object current data
	if ![info exists current(w)] return
	set w $current(w)
	set event [lindex $args 0]
	switch -- $action {
		setf? {
			if {"$event" == ""} return
			set value [string trimleft [string trimright [lindex $args 1]]]
			switch -regexp -- $value {
				{^".*"$} - {^\[.*\]$} {
					set window $data(base)
					catch {eval bind $w $event $value} ::Classy::err
					set data(ev$event,$w) $value
				}
				{\$window} {
					set window $data(base)
					set value "\[varsubst window [list $value]\]"
					catch {eval bind $w $event $value} ::Classy::err
					set data(ev$event,$w) $value
				}
				default {
					bind $w $event $value
					catch {unset data(ev$event,$w)}
				}
			}
			$object bindings rebuild
		}
		set {
			if {"$event" == ""} return
			set value [lindex $args 1]
			bind $w $event $value
			catch {unset data(ev$event,$w)}
			$object bindings rebuild
		}
		get {
			if [info exists data(ev$event,$w)] {
				set value $data(ev$event,$w)
				if [regexp "^\\\[varsubst window" $value] {
					set len [string length $value]
					return [lindex [string range $value 1 [expr {$len-2}]] 2]
				} else {
					return $value
				}
			} else {
				return [bind $w $event]
			}
		}
		select {
			set v $object.bindings.edit
			set list [$object.bindings.list get 0 end]
			$object.bindings.list activate [lsearch $list $event]
			$object.bindings.list selection clear 0 end
			$object.bindings.list selection set active
			eval destroy [winfo children $v]
			Classy::cleargrid $v
			label $v.label -text $event
			grid $v.label -row 0 -column 0 -sticky we
			button $v.change -text "Change binding" -command [varsubst {object v event} {
				$object bindings setf? $event [string trimright [$v.value get 1.0 end]]
				focus $object.bindings.list
			}]
			Classy::Text $v.value
			grid $v.change -row 2 -column 0 -sticky we
			grid $v.value -row 3 -column 0 -sticky nswe
			grid columnconfigure $v 0 -weight 1
			grid rowconfigure $v 3 -weight 1
			$v.value insert end [$object bindings get $event]
			focus $v.value
		}
		rebuild {
			set cevent [$object.bindings.list get active]
			set list [lsort [bind $w]]
			$object.bindings.list delete 0 end
			eval $object.bindings.list insert end $list
			set pos [lsearch $list $cevent]
			if {$pos != -1} {
				$object bindings select [lindex $list $pos]
			} else {
				$object bindings select [lindex $list 0]
			}
			focus $object.bindings.list
		}
		default {
			grid configure $current(w) $type $value
		}
	}
	update idletasks
	Classy::todo $object _drawselectedw
}

Classy::WindowBuilder method _createbindings {w} {
	private $object current
	frame $w

	set w .try.dedit.bindings
	eval destroy [winfo children $w]
	Classy::cleargrid $w
	frame $w.b
	button $w.delete -text "Delete event" -command "$object bindings set \[$w.list get active\]"
	button $w.donew -text "New event" -command "$object.bindings.new set \[Classy::select Events \[lsort \[event info\]\]\]"
	Classy::Entry $w.new -command "$object bindings set \[$w.new get\] \"#binding\n\"" -width 5
	grid $w.delete -row 0 -column 0 -in $w.b -sticky we -columnspan 2
	grid $w.donew -row 1 -column 0 -in $w.b -sticky we
	grid $w.new -row 1 -column 1 -in $w.b -sticky we
	grid columnconfigure $w.b 1 -weight 1
	listbox $w.list -yscrollcommand [list $w.scroll set] -takefocus 1
	scrollbar $w.scroll -orient vertical -command [list $w.list yview]
	frame $w.edit
	grid $w.b -row 0 -column 0 -columnspan 2 -sticky nwse
	grid $w.list -row 1 -column 0 -sticky nwse
	grid $w.scroll -row 1 -column 1 -sticky nwse
	grid $w.edit -row 0 -column 2 -rowspan 2 -sticky nwse
	grid columnconfigure $w 2 -weight 1
	grid rowconfigure $w 1 -weight 1
	bind $w.list <<Invoke>> [varsubst {w object} {
		$object bindings select [$w.list get active]
	}]
	bind $w.list <<ButtonRelease-Action>> [varsubst {w object} {
		tkCancelRepeat
		%W activate @%x,%y
		$object bindings select [$w.list get active]
	}]

}

Classy::WindowBuilder method rename {args} {
	private $object data current
	set window $data(base)
	if {[llength  $args]==2} {
		set old [lindex $args 0]
		set new [lindex $args 1]
	} elseif {[llength  $args]==1} {
		set old $current(w)
		set new [lindex $args 0]
	} else {
		return -code error "wrong # args: should be \"$object rename ?old? new\""
	}
	if ![regexp {^\$window\.} $new] {return -code error "new name should be a child of \$window"}
	eval set old $old
	eval set new $new
	if [winfo exists $new] {return -code error "window $new exists"}
	set data(base) $old
	set gridinfo [grid info $old]
	set code [$object generate $old]
	proc ::Classy::buildertemp window $code
	$object parsecode $data(code)
	set data(base) $window
	::Classy::buildertemp $new
	rename ::Classy::buildertemp {}
	if {"[winfo parent $old]" == "[winfo parent $new]"} {
		eval grid $new $gridinfo
	} else {
		set p [winfo parent $new]
		grid $new -row [$object newpos $p 0] -column 0 -sticky nwse
	}
	destroy $old
	$object startedit $new
	$object select $new
}

