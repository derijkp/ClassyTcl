#
# ####  #####  ####   #### 
# #   # #     #    # # 
# ####  ####  #    #  #### 
# #     #     #    #      # 
# #     #####  ####   ####  Peter De Rijk
#
# ClassyFilerWindow
# ----------------------------------------------------------------------

option add *ClassyFilerWindow.highlightThickness 0 widgetDefault
option add *ClassyFilerWindow.borderWidth 0 widgetDefault
option add *ClassyFilerWindow.filter.entry.width 4 widgetDefault

Classy::DynaMenu loadmenu ClassyFiler


#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# FilerWindow
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::FilerWindow {} {}
proc FilerWindow {} {}
}
catch {Classy::FilerWindow destroy}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass FilerWindow
Classy::export FilerWindow {}

FilerWindow classmethod init {args} {
	toplevel $object -class ClassyFilerWindow
	if ![winfo exists .peos__filermenu] {
		Classy::DynaMenu makepopup ClassyFiler .peos__filermenu $object ClassyFilerMenu
	}
	if {"[option get $object menuType MenuType]"=="top"} {
		.peos__filermenu configure -type menubar
		$object configure -menu .peos__filermenu
	}
#	bind $object <FocusIn> "Classy::DynaMenu cmdw .peos__filermenu $object"
	bind $object <Enter> "Classy::DynaMenu cmdw .peos__filermenu $object"

	frame $object.dir
	pack $object.dir -fill x -side top
	checkbutton $object.filtertype -text "R" -variable [publicvar $object filtertype] -indicatoron no\
		-onvalue regexp -offvalue glob -command "$object redraw"
	pack $object.filtertype -in $object.dir -side right
	Classy::Entry $object.filter -textvariable [publicvar $object filter]
	pack $object.filter -in $object.dir -side right -expand yes -fill x
	canvas $object.files -yscrollcommand [list $object.vbar set] -width 0 -height 0
	bindtags $object.files "$object Canvas $object.edit all"
	scrollbar $object.vbar -orient vertical -command "$object.files yview"
	pack $object.vbar -fill y -side right
	pack $object.files -fill both -expand yes -side left
	Classycreateobject $object ClassyFilerWindow

	# REM Initialise options and variables
	# ------------------------------------
	private $object action selection
	set selection {}
	set action none

	Classyaddoptions $object -dir [setglobal env(HOME)] -view normal -order extension \
					 -hidden no -dist {70 70 40 20 150 20} -font fixed \
					 -filter {*} -filtertype glob \
					 -getfilesCmd "$object getfilesFS \$dir \$filter \$sort \$view"

	Classyaddtodo $object getdir {$object getdir} redraw {$object redraw} drawdir {ClassyFilerWindow_drawdir $object}
	Classytodo $object getdir redraw
	Classyoptionactions $object {
		-dir {
			set dir [getprivate $object options(-dir)]
			regsub -all {//} $dir {/} dir
			Classytodo $object getdir redraw drawdir
		}
		-view {
			Classytodo $object redraw
		}
		-filter {
			set dir [getprivate $object options(-dir)]
			set filter [getprivate $object options(-filter)]
			if [regexp {^(.*)/([^/]*)$} $filter temp ndir filter] {
				if {"[string index $ndir 0]" == "/"} {
					set tdir $ndir
				} else {
					set tdir $dir/$ndir
				}
				regsub -all {//} $tdir {/} tdir
				if [file isdir $tdir] {
					set dir $tdir
				}
				Classytodo $object getdir redraw drawdir
			}
			Classytodo $object redraw
		}
		-filtertype {
			Classytodo $object redraw
		}
		-order {
			Classytodo $object getdir redraw
		}
		-hidden {
			Classytodo $object getdir redraw
		}
		-dist {
			Classytodo $object redraw
		}
		-font {
			Classytodo $object redraw
		}
		-getfilesCmd {
			public $object getfilesCmd
# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

			FilerWindow chainallmethods {$object} widget

			FilerWindow method getfiles {dir filter sort view} $getfilesCmd
		}
	}

	# REM Create bindings
	# -------------------
	bindtags $object.files "ClassyFilerMenu [bindtags $object.files]"

	bind $object <Configure> [list $object redraw]
	bind $object.files <<Action>> "$object actionbutton %X %Y %x %y"
	bind $object.files <<Action-Motion>> "$object actiondrag %X %Y %x %y"
	bind $object.files <<ButtonRelease-Action>> "$object actionrelease %X %Y %x %y"
	bind $object.files <<ButtonPress-Adjust>> "$object selection from %x %y"
	bind $object.files <<Adjust-Motion>> "$object selection to %x %y"
	bind $object.files <<ButtonRelease-Adjust>> "$object selection change %x %y"
	bind $object.files <<Menu>> "$object menupress %X %Y %x %y"
	bind $object.files <<Double-Action>> "$object action %x %y 1"
	bind $object.files <<Double-Adjust>> "$object action %x %y 2"
	bind $object.files <Enter> "focus $object.files"
	bind $object.filter.entry <Return> "puts ok;$object configure -filter \[$object.filter get\]"
	

	# REM Drag & drop
	# ---------------
	d&d__addreceiver $object.files files [varsubst object {
		set dir [$object cget -dir]
#		eval exec cp -r $files $dir
		set command "|cp -viRd --help $files $dir"
		set f [open $command "r"]
		fileevent $f readable [varsubst {f object} {
			if [eof $f] {
				close $f
				$object refresh
			} else {
				puts "copied [gets $f]"
			}
		}]
		
	}]

#	d&d__addreceiver $object.files save [varsubst object {
#		set dir [$object cget -dir]
#		send $from "set dir $dir ; $data"
#		$object redraw
#	}]

	d&d__addreceiver $object.files savebox [varsubst object {
		set dir [$object cget -dir]
		set file [file tail $file]
		send $from $savebox set $dir/$file
		send $from $savebox invoke save
#		send $from $savebox invoke close
		$object refresh
	}]
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

FilerWindow method _destructor {} {
	d&d__delreceivers $object.files
}

# ------------------------------------------------------------------
#  METHODS
# ------------------------------------------------------------------
FilerWindow method getselection {} {
	public $object dir 
	private $object selection
	set result ""
	foreach file $selection {
		lappend result $dir/$file
	}
	return $result
}

FilerWindow method actionbutton {X Y x y} {
	private $object action selection
	set x [$object.files canvasx $x]
	set y [$object.files canvasy $y]
	set current [$object getselfiles $x $y $x $y]
	if {"$current" == ""} {
		set action select
		$object selection from $x $y
	} elseif {[lsearch $selection $current]!=-1} {
		set action drag
   } else {
		set action drag
		$object select ""
		$object selection make $x $y
	}
}

FilerWindow method actiondrag {X Y x y} {
	private $object action
	if {"$action" == "drag"} {
		private $object selection dirinfo
		public $object dir
		foreach file $selection {
			lappend files $dir/$file
		}
		if {[llength $selection]==1} {
			set icon $dirinfo(icon,$file)
		} else {
			global iconpool
			set icon $iconpool(smfile:xxx)
		}
		d&d__startdrag $icon $object.files "files [list $files]"
	} else {
		set x [$object.files canvasx $x]
		set y [$object.files canvasy $y]
		$object selection to $x $y
	}
}

FilerWindow method actionrelease {X Y x y} {
	private $object action
#	if {"$action" == "drag"} {
#		blt_drag&drop drop $object.files $X $Y
#	} else {
		set x [$object.files canvasx $x]
		set y [$object.files canvasy $y]
		$object selection make $x $y
#	}
	set action none
}

FilerWindow method menupress {X Y x y} {
	private $object selection
	if {"$selection" == ""} {
		set x [$object.files canvasx $x]
		set y [$object.files canvasy $y]
		$object selection make $x $y
	}
	tk_popup $object.menu $X $Y 1
}

FilerWindow method selection {option args} {
	private $object selection xsel ysel
	switch $option {
		get {
			return $selection
		}
	}
	if {[llength $args]!=2} {
		error "Format is \$object selection $option x y\""
	}
	set x [lindex $args 0]
	set y [lindex $args 1]
	if ![info exists xsel] {
		set xsel $x
	}
	if ![info exists ysel] {
		set ysel $y
	}
	switch $option {
		from {
			set xsel $x
			set ysel $y
		}
		to {
			catch {$object.files delete selrectangle}
			$object.files create rectangle $xsel $ysel $x $y -tags selrectangle
		}
		make {
			set files [eval $object getselfiles $xsel $ysel $x $y]
			unset xsel;unset ysel
			catch {$object.files delete selrectangle}
			eval $object select [lmanip remdup $files]
		}
		change {
			set files [eval $object getselfiles $xsel $ysel $x $y]
			unset xsel;unset ysel
			catch {$object.files delete selrectangle}
			set files [lmanip remdup $files]
			set selection [leor $selection $files]
			eval $object select $selection
		}
	}
}

FilerWindow method select {args} {
	private $object selection dirinfo
	set selection ""
	$object.files delete selfiles
	foreach file $args {
		if ![info exists dirinfo(type,$file)] continue
		lappend selection $file
		eval $object.files create rectangle [eval $object.files bbox $file] \
			-fill darkgray -outline darkgray -tags selfiles
	}
	$object.files lower selfiles
}

FilerWindow method getselfiles {x1 y1 x2 y2} {
	private $object dispinfo
	set list [$object.files find overlapping $x1 $y1 $x2 $y2]
	foreach canvobj $list {
		if [info exists dispinfo($canvobj)] {
			lappend files $dispinfo($canvobj)
		}
	}
	if ![info exists files] {
		set files ""
	}
	return [lmanip remdup $files]
}

FilerWindow method deletefiles {args} {
	public $object dir
	private $object selection
	if {"$args" == "sel"} {
		set args $selection
	}
	foreach file $args {
		eval exec rm -r $dir/$file
	}
	eval $object select ""
	$object refresh
}

FilerWindow method copyto {file} {
	public $object dir
	private $object selection
	set targetdir [file dirname $file]
	set sel [lregsub {^} $selection $dir/]
	if {[llength $selection]==1} {
			exec cp $sel $file
		} else {
			eval exec cp $sel $targetdir
		}
	catch {updatedir $targetdir}
}

FilerWindow method copybox {} {
	public $object dir
	private $object selection
	ClassySaveBox $object.savebox -command "$object copyto \[$object.savebox get\]"
	if {[llength $selection] > 1} {
		$object.savebox set $dir/
	} else {
		$object.savebox set $dir/$selection
	}
	wm title $object.savebox "Copy $selection to"
}

FilerWindow method filterbox {} {
	public $object filter filtertype
	ClassyInputBox $object.filterbox -default filter -command [varsubst object {
		$object configure -filter [$object.filterbox.options.entry get] -filtertype [$object.filterbox.options.type get]
		$object redraw
	}]
	Classy::OptionBox $object.filterbox.options.type -label "Type" -orient horizontal
	$object.filterbox.options.type add glob Glob
	$object.filterbox.options.type add regexp Regexp
	pack $object.filterbox.options.type -fill x

	$object.filterbox.options.entry configure -label Filter
	$object.filterbox.options.entry set $filter
	$object.filterbox.options.type set $filtertype
	wm title $object.filterbox "Filter"
}

FilerWindow method rename {file newfile} {
	public $object dir
	private $object selection
	eval exec mv $dir/$file $dir/$newfile
	eval $object select $newfile
	$object refresh
}

FilerWindow method renamebox {} {
	public $object dir
	private $object selection
	set file $selection
	catch {destroy $object.rename}
	ClassyInputBox $object.rename -title "Rename $file to" -buttontext Rename \
		-command "$object rename $file \[$object.rename get\] \; destroy $object.rename"
	$object.rename set $file
}

# display
# =======

# find filenames and extensions
# -----------------------------
FilerWindow method getfileicon {file} {
	common $object imgs
	if ![info exists imgs($file)] {
		set imgs($file) [image create photo -file $file]
	}
	return $imgs($file)
}

FilerWindow method getfiles {dir filter {sort none} {view default}} {
	return [$object getfilesFS $dir $filter $sort $view]
}

FilerWindow method getfilesFS {dir filter {sort alpha} {view default}} {
	set pwd [pwd]
	cd $dir
	set files [glob $filter]
	set result ""
	switch -- $sort {
		alpha {
			set files [lsort $files]
		}
		alpha {
			set files [lsort $files]
		}
	}
	foreach file $files {
		lappend result $file
		set type ""
		regexp {\.([^.]*)$} $file temp type
		if [file isdir $file] {
			set ftype dir
			set imgfile [Classygetconffile fileicons/dir.gif]
		} else {
			set ftype file
			set imgfile [Classygetconffile fileicons/file_${type}.gif]
		}
		if ![file readable $imgfile] {
			set imgfile [Classygetconffile fileicons/unknown.gif]
		}
		lappend result $ftype $type $imgfile
		if {"$view"=="full"} {
			lappend result {}
		} else {
			lappend result {}
		}
	}
	cd $pwd
	return $result
}

FilerWindow method redraw {} {
	public $object dir view font dist
	private $object dirinfo
	global peos
	set w $object.files

	# calculate geometries
	# --------------------
	switch $view {
		full {
			set xdist [lindex $dist 2]
			set ydist [lindex $dist 3]
			set pos 20
		}
		small {
			set xdist [lindex $dist 4]
			set ydist [lindex $dist 5]
			set pos 20
		}
		default {
			set xdist [lindex $dist 0]
			set ydist [lindex $dist 1]
			set pos [expr $xdist/2]
		}
	}
	set width [winfo width $w]
	set height [winfo height $w]
	set ncols [expr $width/$xdist]
	if {$ncols==0} return
	set cols $pos
	for {set i 0} {$i<$ncols} {incr i} {
		incr pos $xdist
		lappend cols $pos
	}

	$w delete all
	set pos 0
	set ypos $ydist
	set twidth [expr $xdist-2]

	# place icons on the canvas
	# ------------------------
	public $object filter filtertype getfilesCmd
	private $object dispinfo fileCmds

	set files [$object getfiles $dir $filter $view]
	foreach {file ftype type img info} $files {
		switch $view {
			full {
				#set fullformat "  $file\t$dirinfo(size,$file)\t$dirinfo(date,$file)\t$dirinfo(access,$file)\t$dirinfo(user,$file)\t$dirinfo(group,$file)"
				set fullformat " $dirinfo(full,$file)"
				set iconid [$w create image [lindex $cols $pos] $ypos -tag $file -anchor e -image $dirinfo(sicon,$file)]
				set textid [$w create text [lindex $cols $pos] $ypos -tag $file -anchor w \
						 -justify left -text $fullformat -font $font]
				incr ypos $ydist
			}
			small {
				set iconid [$w create image [lindex $cols $pos] $ypos -tag $file -anchor e -image $dirinfo(sicon,$file)]
				set textid [$w create text [lindex $cols $pos] $ypos -tag $file -anchor w \
						 -justify left -text " $file" -font $font]
				incr pos
				if {$pos==$ncols} {
					incr ypos $ydist
					set pos 0
				}
			}
			default {
				set iconid [$w create image [lindex $cols $pos] $ypos -tag $file -anchor s -image [$object getfileicon $img]]
				set textid [$w create text [lindex $cols $pos] $ypos -tag $file -anchor n -width $twidth \
						 -justify center -text $file -font $font]
				incr pos
				if {$pos==$ncols} {
					incr ypos $ydist
					set pos 0
				}
			}
		}
		set dispinfo($iconid) $file
		set dispinfo($textid) $file
#		$w bind $iconid <Double-ButtonPress> "$object action $file $dirinfo(type,$file) %b"
#		$w bind $textid <Double-ButtonPress> "$object action $file $dirinfo(type,$file) %b"
	}		
	eval $object select [$object selection get]
	$w configure -scrollregion "0 0 $width [expr $ypos+$ydist/2]"
}

FilerWindow method refresh {} {
	$object getdir
	$object redraw
}

FilerWindow method action {x y button} {
	global fileractions
	public $object dir
	private $object dirinfo dispinfo

	set x [$object.files canvasx $x]
	set y [$object.files canvasy $y]
	set file $dispinfo([$object.files find closest $x $y])
	set type $dirinfo(type,$file)
	if [info exists fileractions($type$button)] {
		eval $fileractions($type$button)
	} elseif [info exists fileractions($type)] {
		eval $fileractions($type)
	}
}

proc ClassyFilerWindow_drawdir {} {
	public $object dir
	catch {eval destroy [winfo children $object.dir]}
	set tdir $dir
	set num 1
	if {"$tdir" != "/"} {
		while 1 {
			set tail [file tail $tdir]
			button $object.dir.l$num -text $tail -command "$object configure -dir $tdir"
			pack $object.dir.l$num -side right
			set tdir [file dirname $tdir]
			incr num
			if {"$tdir" == "/"} break
		}
	}
	button $object.dir.l$num -text "/" -command "$object configure -dir /"
	pack $object.dir.l$num -side right
}

