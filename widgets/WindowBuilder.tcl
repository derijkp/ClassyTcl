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

Classy::Toplevel subclass Classy::WindowBuilder
Classy::export WindowBuilder {}

Classy::WindowBuilder classmethod init {args} {
	super	-keepgeometry all -resize {2 2}
	private $object current options
	set current(w) ""
	set w [Classy::window $object]
	Classy::DynaMenu makemenu Classy::WindowBuilder .classy__.windowBuildermenu $object Classy::WindowBuilderMenu
	bindtags $object [list $object Classy::WindowBuilder all]
	$w configure -menu .classy__.windowBuildermenu
	frame $object.toolhold
		Classy::DynaTool maketool Classy::WindowBuilder $object.tool $object
		Classy::OptionMenu $object.children -list {Select {Select parent}} \
			-command "$object select \[$object.children get\]"
		$object.children set Select
		Classy::Entry $object.current -label "Current window" -width 15 \
			-command "$object rename \[$object.current get\]"
		grid $object.tool -in $object.toolhold -row 0 -column 0 -sticky ew
		grid $object.children -in $object.toolhold -row 0 -column 1 -sticky nsew
		grid $object.current -in $object.toolhold -row 0 -column 2 -sticky nsew
		grid columnconfigure $object.toolhold 2 -weight 1
	Classy::DynaTool maketool Classy::WindowBuilder_icons $object.icons $object
	foreach c [winfo children $object.icons] {
		if {"[winfo class $c]" == "Button"} {
			set command [$c cget -command]
			regexp { add ([^ {}]+)} $command temp type
			set name [string tolower $type]
			regsub -all : $name _ name
			bind $c <<Action-Motion>> "DragDrop start %W $type -types [list [list create $command]] -image [Classy::geticon Builder/$name]"			
		}
	}
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

	# REM Initialise options and variables
	# ------------------------------------

	# REM Create bindings
	# --------------------
	bind Classy::WindowBuilder_$object <<ButtonRelease-Action>> [list $object select %W]
	bind Classy::WindowBuilder_$object <<Adjust>> [list $object insertname %W]
	bind Classy::WindowBuilder_$object <<Drag>> "$object drag %W"
	bind Classy::WindowBuilder_$object <<Drop>> "$object drop %W"
	bind Classy::WindowBuilder_$object <<Cut>> "$object delete"
	bind Classy::WindowBuilder_$object <<Delete>> "$object delete"
	bind Classy::WindowBuilder_$object <<Configure>> [list $object _drawselectedw]
	bind Classy::WindowBuilder_$object <<Up>> [list $object geometryset up]
	bind Classy::WindowBuilder_$object <<Down>> [list $object geometryset down]
	bind Classy::WindowBuilder_$object <<Left>> [list $object geometryset left]
	bind Classy::WindowBuilder_$object <<Right>> [list $object geometryset right]
	bind Classy::WindowBuilder_$object <Configure> [list $object _drawselectedw]

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	update idletasks
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

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
Classy::WindowBuilder method select {w} {
	private $object current prev data
	if [info exists data(redir,$w)] {set w $data(redir,$w)}
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
	if [info exists data(redir,$w)] {set w $data(redir,$w)}
	$object _drawselectedw $w
	if {[string first $data(base) $w] != 0} return
	catch {unset current}
	set current(w) $w
	$object geometryset rebuild
	switch [$object.book get] {
		Attributes {$object attribute rebuild}
		Bindings {$object bindings rebuild}
		Special {$object drawedit}
	}
	$object.current nocmdset [$object outw $w]
	if [catch {$w children} list] {
		set list [lremove [winfo children $w] $object.work.classy__nw $object.work.classy__n $object.work.classy__ne \
			$object.work.classy__e $object.work.classy__se $object.work.classy__s $object.work.classy__sw $object.work.classy__w]
	}
	$object.children configure -list [concat {Select {Select parent}} $list]
	$object.children set Select
	focus $w
}

Classy::WindowBuilder method current {} {
	private $object current
	return $current(w)
}

Classy::WindowBuilder method insertname {w} {
	private $object current prev data
	clipboard clear -displayof $object			  
	clipboard append -displayof $object [$object outw $w]
	set w [focus -lastfor $object]
	if {"$w" != ""} {
		event generate $w <<Paste>>
	}
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
	set w [$object newname [string tolower [namespace tail $type]]]
	if {"[info commands ::Classy::WindowBuilder::add_$type]" == ""} {
		auto_load ::Classy::WindowBuilder::add_$type
	}
	if {"[info commands ::Classy::WindowBuilder::add_$type]" != ""} {
		set result [eval {::Classy::WindowBuilder::add_$type $object $w} $args]
	} else {
		set result $w
		$type $w
		if {"$args" != ""} {eval $w configure $args}
	}
	if ![info exists currentgrid(-column)] {
		set currentgrid(-column) 0
	}
	if [winfo exists $w] {
		set p [winfo parent $w]
		set row [$object newpos $p $currentgrid(-column)]
		grid $w -sticky nwse -column $currentgrid(-column) -row $row
		$object startedit $w
		$object select $w
	}
	return $result
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

Classy::WindowBuilder method newname {{base w}} {
	private $object current
	if [info exists ::Classy::WindowBuilder::parents([$object itemclass $current(w)])] {
		set parent $current(w)
	} else {
		set parent [winfo parent $current(w)]
	}
	if ![info exists ::Classy::WindowBuilder::parents([$object itemclass $parent])] {
		error "Adding child windows to to parent window \"$parent\" is not possible"
	}
	set num 1
	while {[winfo exists $parent.$base$num]} {
		incr num
	}
	return $parent.$base$num
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
	if [info exists data(base)] {
		if ![Classy::yorn "Are you sure you want to abort the current editing session"] {
			return 1
		}
	}
#	Classy::Default set geom $object [wm geometry $object]
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
			puts $f "\tClassy::Toplevel \$window"
			puts $f "\t#Initialisation code"			
			puts $f "\}"
		}
		frame {
			puts $f "\nproc $function args \{# ClassyTcl generated Frame"
			puts $f "\tif \[regexp \{^\\.\} \$args] \{"
			puts $f "\t\tset window \[lpop args\]"
			puts $f "\t\} else \{"
			puts $f "\t\tset window .$function"
			puts $f "\t\}"
			puts $f "\tClassy::parseopt \$args opt {}"
			puts $f "\t# Create windows"
			puts $f "\tframe \$window \\"
			puts $f "\t\t-class Classy::Topframe"
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
			$object startedit $data(base)
		}
		{# ClassyTcl generated Toplevel}  {
			uplevel #0 $code
			set data(type) toplevel
			::$function $object.work
			$object parsecode $data(code)
			set data(base) $object.work
			$object startedit $data(base)
		}
		{# ClassyTcl generated Frame}  {
			uplevel #0 $code
			set data(type) frame
			Classy::Toplevel $object.work
			::$function $object.work.frame
			grid $object.work.frame -row 0 -column 0 -sticky nsew
			grid columnconfigure $object.work 0 -weight 1
			grid rowconfigure $object.work 0 -weight 1
			$object parsecode $data(code)
			set data(base) $object.work.frame
			$object startedit $data(base)
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
	set list [Extral::splitcomplete [lindex $code 3]]
	set pos [lsearch -regexp $list {#ClassyTcl init}]
	$object.code.icode.text delete 1.0 end
	set init ""
	if {$pos != -1} {
		$object.code.icode.text insert end [join [lrange $list [expr {$pos+1}] end] \n]
		set list [lrange $list 0 [expr {$pos-1}]]
	}
	# window
	set line [lindex $list 1]
	set data(options,window,def) [lindex [lindex $line 6] 2]
	#options
	set line [lindex $list 2]
	set data(options) window
	foreach {option limit def} [lindex $line 3] {
		lappend data(options) $option
		set data(options,$option,limit) $limit
		set data(options,$option,def) $def
	}
	$object.code.chooseopt configure -list $data(options)
	$object.code.chooseopt set window
	set i 4
	set len [llength $list]
	while {$i<$len} {
		set line [lindex $list $i]
		switch -regexp -- $line {
			{\\$} {
				eval set w [lindex $line 1]
				incr i
				while {$i<$len} {
					set line [lindex $list $i]
					set continue [regsub { \\$} $line {} line]
					regexp "^\[\t \]*(-\[a-z\]+) (.*)$" $line temp option value
					switch -regexp -- $value {
						{^".*"$} - {^\[.*\]$} {
							set data(opt$option,$w) $value
						}
						default {
							catch {unset data(opt$option,$w)}
						}
					}
					if !$continue break
					incr i
				}
			}
			{bind } {
				set line [lindex $list $i]
				regexp "bind (\[^ \]+) (\[^ \]+) (.*)$" $line temp w event value
				eval set w $w
				switch -regexp -- $value {
					{^".*"$} - {^\[.*\]$} {
						set data(ev$event,$w) $value
					}
					default {
						catch {unset data(ev$event,$w)}
					}
				}
			}
			{Classy::DynaMenu attachmainmenu} {
				set data(opt-menutype,$window) [lindex $line 2]
				if {"[lindex $line 3]" != ""} {
					if [info exists data(opt-menuwin,$window)] {
						append data(opt-menuwin,$window) " "
					}
					append data(opt-menuwin,$window) [lindex $line 3]
				}
			}
		}
		incr i
	}
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
	if {"$data(type)" != "frame"} {
		$data(function)
	} else {
		Classy::Toplevel $object.test
		$data(function) $object.test.frame
		pack $object.test.frame -fill both -expand yes
	}
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
	} elseif {"$data(type)" == "toplevel"} {
		set body "proc $function args \{# ClassyTcl generated Toplevel\n"
	} else {
		set body "proc $function args \{# ClassyTcl generated Frame\n"
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

Classy::WindowBuilder method getoption {base option} {
	private $object data
	if [info exists data(opt$option,$base)] {
		return $data(opt$option,$base)
	} else {
		return	[list [$base cget $option]]
	}
}

Classy::WindowBuilder method getoptions {base args} {
	private $object data
	set result ""
	set rem ""
	foreach line [$base configure] {
		if {[llength $line] != 5} continue
		set option [lindex $line 0]
		if {"$option" == "-class"} continue
		if {[lsearch $args $option] != -1} continue
		if [info exists data(opt$option,$base)] {
			append result " \\\n\t\t$option $data(opt$option,$base)"
		} else {
			set def [lindex $line 3]
			set real [lindex $line 4]
			if {"$def" != "$real"} {
				if {"[option get $base [lindex $line 1] [lindex $line 2]]" != "$real"} {
					append result " \\\n\t\t$option [list $real]"
				}
			}
		}
	}
	return $result
}

Classy::WindowBuilder method gridwconf {base} {
	if {"[winfo manager $base]" != "grid"} return
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
	if {"[info commands ::Classy::WindowBuilder::edit_$type]" == ""} {
		auto_load ::Classy::WindowBuilder::edit_$type
	}
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

Classy::WindowBuilder method _recursestartedit {top list} {
	private $object data bindtags
	foreach base $list {
		set bindtags($base) [bindtags $base]
		bindtags $base Classy::WindowBuilder_$object
		set data(redir,$base) $top
		$object _recursestartedit $top [winfo children $base]
	}
}

Classy::WindowBuilder method startedit {list} {
	private $object data bindtags
	foreach base $list {
		set type [$object itemclass $base]
		if {"[info commands ::Classy::WindowBuilder::start_$type]" == ""} {
			auto_load ::Classy::WindowBuilder::start_$type
		}
		if {"[info commands ::Classy::WindowBuilder::start_$type]" != ""} {
			::Classy::WindowBuilder::start_$type $object $base
		} else {
			set bindtags($base) [bindtags $base]
			bindtags $base Classy::WindowBuilder_$object
			if [regexp ^Classy:: $type] {
				$object _recursestartedit $base [winfo children $base]
			}
		}
	}
}

Classy::WindowBuilder method protected {base args} {
	private $object data
	if {[llength $args] == 0} {
		if [info exists data(pr,$base)] {
			return $data(pr,$base)
		} else {
			return ""
		}
	} elseif {[llength $args] == 1} {
		if [info exists data(pr,$base)] {
			if {[lsearch $data(pr,$base) [lindex $args 0]] != -1} {
				return 1
			} else {
				return 0
			}
		} else {
			return 0
		}
	} else {
		switch [lindex $args 0] {
			set {
				set data(pr,$base) [lrange $args 1 end]
				if {"$data(pr,$base)" == ""} {unset data(pr,$base)}
			}
		}
	}
}

Classy::WindowBuilder method recurseunset {{list {}}} {
	private $object data
	foreach base $list {
		$object recurseunset [winfo children $base]
		foreach name [array names data *,$base] {unset data($name)}
	}
}

Classy::WindowBuilder method delete {{list {}}} {
	private $object data current
	set keep $current(w)
	if {"$list" == ""} {set list $keep}
	catch {$object finalcode}
	set p [winfo parent [lindex $list end]]
	foreach base $list {
		set type [$object itemclass $base]
		if [$object protected $base delete] continue
		if {"[info commands ::Classy::WindowBuilder::delete_$type]" == ""} {
			auto_load ::Classy::WindowBuilder::delete_$type
		}
		if {"[info commands ::Classy::WindowBuilder::delete_$type]" != ""} {
			::Classy::WindowBuilder::delete_$type $object $base
		}
		catch {$object recurseunset $base}
		catch {destroy $base}
	}
	$object select $p
}

Classy::WindowBuilder method outw {base} {
	private $object data
	return [replace $base [list $data(base) {$window}]]
}

Classy::WindowBuilder method generatebindings {base outw} {
	private $object data bindtags
	set body ""
	foreach event [bind $base] {
		if [info exists data(ev$event,$base)] {
			set binding $data(ev$event,$base)
		} else {
			set binding [list [bind $base $event]]
		}
		append body "\tbind $outw $event $binding\n"
	}
	return $body
}

Classy::WindowBuilder method generate {list} {
	private $object data
	set body {}
	foreach base $list {
		set type [$object itemclass $base]
		if {"[info commands ::Classy::WindowBuilder::generate_$type]" == ""} {
			auto_load ::Classy::WindowBuilder::generate_$type
		}
		if {"[info commands ::Classy::WindowBuilder::generate_$type]" != ""} {
			append body [::Classy::WindowBuilder::generate_$type $object $base]
		} else {
			if {[lsearch {
				Frame Button Entry Label Listbox Checkbutton Radiobutton Menubutton 
				Message Scrollbar Scale Text Canvas} $type] != -1} {
					set cmd [string tolower $type]
			} else {
				set cmd $type
			}
			set outw [$object outw $base]
			append body "\t$cmd $outw[$object getoptions $base]\n"
			append body "\t[$object gridwconf $base]\n"
			append body [$object generatebindings $base $outw]
		}
	}
	return $body	
}

Classy::WindowBuilder method itemclass {w} {
	private $object data
	if [info exists data(class,$w)] {
		return $data(class,$w)
	} else {
		if ![catch {$w info class} class] {
			return $class
		} else {
			return [winfo class $w]
		}
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
	$object startedit $data(base)
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
			$object gridmoverow $p $currentgrid(-column) $currentgrid(-row) $value
		}
		-column {
			$object gridmovecol $p $currentgrid(-row) $currentgrid(-column) $value
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
		grid columnconfigure $w.resize 3 -weight 1
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
					set data(opt$option,$w) $value
					set window $data(base)
					catch {eval set value $value} ::Classy::WindowBuilder::error
				}
				{\$window} {
					set value "\[varsubst window [list $value]\]"
					set data(opt$option,$w) $value
					set window $data(base)
					catch {eval set value $value} ::Classy::WindowBuilder::error
				}
				default {
					catch {unset data(opt$option,$w)}
				}
			}
			if [regexp {^-} $option] {
				$w configure $option $value
			} else {
				::Classy::WindowBuilder::attr_[$object itemclass $w]_$option $object $w $value
			}
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
				if [regexp {^-} $option] {
					return [$w cget $option]
				} else {
					return [::Classy::WindowBuilder::attr_[$object itemclass $w]_$option $object $w]
				}
			}
		}
		select {
			private $object attredit
			catch {unset attredit}
			set v $object.attr.edit
			set list $current(group,[$object.attr.type get])
			$object.attr.list activate [lsearch $list $option]
			$object.attr.list selection clear 0 end
			$object.attr.list selection set [lsearch $list $option]
			eval destroy [winfo children $v]
			Classy::cleargrid $v
			label $v.label -text $option
			grid $v.label -row 0 -column 0 -sticky we
			$object _createattributeedit $v $option [string range $option 1 end]
		}
		group {
			$object.attr.list delete 0 end 
			if [info exists current(group,$option)] {
				eval $object.attr.list insert end $current(group,$option)
				$object attribute select [lindex $current(group,$option) 0]
			}
		}
		rebuild {
			set cgroup [$object.attr.type get]
			set coption [$object.attr.list get active]
			foreach type [array names current group,*] {
				unset current($type)
			}
			set list All
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
				lappend current(group,All) $option
				if {[lsearch [set ::Classy::WindowBuilder::options(common)] $option] != -1} {
					lappend current(group,Common) $option
					laddnew list Common
				}
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
		}
		default {
			grid configure $current(w) $type $value
		}
	}
	update idletasks
	Classy::todo $object _drawselectedw
}

Classy::WindowBuilder method _createattributeedit {v option title {w 0}} {
	private $object data
	if [info exists ::Classy::WindowBuilder::options($option)] {
		set entry [set ::Classy::WindowBuilder::options($option)]
		if {[llength $entry] == 2} {
			set entry [lindex $entry 1]
		}
	} else {
		set entry line
	}
	if {"[info commands ::Classy::WindowBuilder::attredit_$entry]" != ""} {
		::Classy::WindowBuilder::attredit_$entry $object $v $option $title $w
	} else {
		::Classy::WindowBuilder::attredit_line $object $v $option $title $w
	}
}

Classy::WindowBuilder method _createattributes {w} {
	private $object current
	frame $w
	eval destroy [winfo children $w]
	Classy::cleargrid $w
	Classy::OptionMenu $w.type -list {Misc Colors Sizes} -command "$object attribute group \[$w.type get\]"
	listbox $w.list -yscrollcommand [list $w.scroll set] -takefocus 1 -width 6
	scrollbar $w.scroll -orient vertical -command [list $w.list yview]
	frame $w.edit
	Classy::Paned $w.pane -orient vertical -window $w.list
	grid $w.type -row 0 -column 0 -columnspan 2 -sticky nwse
	grid $w.list -row 1 -column 0 -sticky nwse
	grid $w.scroll -row 1 -column 1 -sticky ns
	grid $w.pane -row 0 -column 2 -rowspan 2 -sticky ns
	grid $w.edit -row 0 -column 3 -rowspan 2 -sticky nwse
	grid columnconfigure $w 3 -weight 1
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
			}]
			Classy::Text $v.value
			grid $v.change -row 2 -column 0 -sticky we
			grid $v.value -row 3 -column 0 -sticky nswe
			grid columnconfigure $v 0 -weight 1
			grid rowconfigure $v 3 -weight 1
			$v.value insert end [$object bindings get $event]
		}
		rebuild {
#			if {"$current(w)" != ""} {
#				$object.bindings.bindtags set [$object outw [getprivate $object bindtags($current(w))]]
#			}
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
#	Classy::Entry $w.bindtags -label "Bindtags" \
#		-command "setprivate $object bindtags(\[$object current\]) \[$w.bindtags get\]" -width 5
#	if {"$current(w)" != ""} {
#		$w.bindtags set [$object outw [getprivate $object bindtags($current(w))]]
#	}
	frame $w.b
	button $w.delete -text "Delete event" -command "$object bindings set \[$w.list get active\]"
	button $w.donew -text "New event" -command "$object.bindings.new set \[Classy::select Events \[lsort \[event info\]\]\]"
	Classy::Entry $w.new -command "$object bindings set \[$w.new get\] \"#binding\n\"" -width 5
	grid $w.delete -row 0 -column 0 -in $w.b -sticky we
	grid $w.donew -row 1 -column 0 -in $w.b -sticky we
	grid $w.new -row 2 -column 0 -in $w.b -sticky we
	grid columnconfigure $w.b 0 -weight 1
	listbox $w.list -yscrollcommand [list $w.scroll set] -takefocus 1 -width 5
	scrollbar $w.scroll -orient vertical -command [list $w.list yview]
	Classy::Paned $w.pane -orient vertical -window $w.list
	frame $w.edit
#	grid $w.bindtags -row 0 -column 0 -columnspan 4 -sticky we
	grid $w.b -row 1 -column 0 -columnspan 2 -sticky nwse
	grid $w.list -row 2 -column 0 -sticky nwse
	grid $w.scroll -row 2 -column 1 -sticky ns
	grid $w.pane -row 1 -column 2 -rowspan 2 -sticky ns
	grid $w.edit -row 1 -column 3 -rowspan 2 -sticky nwse
	grid columnconfigure $w 3 -weight 1
	grid rowconfigure $w 2 -weight 1
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

Classy::WindowBuilder method drag {w} {
	private $object data current
	if [info exists data(redir,$w)] {
		set rw $data(redir,$w)
	} else {
		set rw $w
	}
	set name [string tolower [$object itemclass $rw]]
	regsub -all : $name _ name
	DragDrop start $w [$object outw $rw] -image [Classy::geticon Builder/$name]
}

Classy::WindowBuilder method drop {dst} {
	private $object data
	set window $data(base)
	if {"[DragDrop types create]" != ""} {
		set type [DragDrop get]
		set cmd [DragDrop get create]
		set ::Classy::targetwindow $dst
		set src [uplevel #0 $cmd]
		unset ::Classy::targetwindow
		if {"$src" == ""} {return ""}
		set outsrc [$object outw $src]
		set checkrename 0
	} else {
		if [info exists data(redir,$dst)] {
			set dst $data(redir,$dst)
		}
		set outsrc [DragDrop get]
		eval set src $outsrc
		set checkrename 1
	}
	set outdst [$object outw $dst]
	if {"$src" == "$dst"} return
	if {"$src" == "$outsrc"} {error "\"$outsrc\" is not a window in this dialog"}
	set p [winfo parent $src]
	if ![info exists ::Classy::WindowBuilder::parents([$object itemclass $dst])] {
		set newp [winfo parent $dst]
	} else {
		set newp $dst
	}
	set x [expr {[winfo pointerx $newp]-[winfo rootx $newp]-1}]
	set y [expr {[winfo pointery $newp]-[winfo rooty $newp]-1}]
	set col [grid location $newp $x $y]
	set row [lpop col]
	if {"$newp" != "$p"} {
		regexp {\.([^.]*[^.0-9])[0-9]*$} $src temp base 
		set num 1
		while {[winfo exists $newp.$base$num]} {
			incr num
		}
		set newname $newp.$base$num
		if $checkrename {
			if ![Classy::yorn "Rename from \"$outsrc\" to \"[$object outw $newname]\""] return
		}
		$object rename $src [$object outw $newname]
		set src $newname
	}
	array set ta [grid info $src]
	if {$ta(-row) != $row} {
		$object gridmoverow $newp $ta(-column) $ta(-row) $row
	}
	if {$ta(-column) != $col} {
		$object gridmovecol $newp $row $ta(-column) $col
	}
	update idletasks
	Classy::todo $object _drawselectedw
}
