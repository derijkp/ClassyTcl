#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Canvas
# ----------------------------------------------------------------------
#doc Canvas title {
#Canvas
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# Classy::Canvas creates a canvas widget with undo and redo. All options
# and commands are the same as for canvas, with those for undo and redo
# added.
#}
#doc {Canvas command} h2 {
#	Canvas specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Canvas {} {}
proc Canvas {} {}
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Canvas
Classy::export Canvas {}

Classy::Canvas classmethod init {args} {
	private $object data undo currentname w
	setprivate $object data(w) [super canvas]
	set w $data(w)

	# REM Initialise options and variables
	# ------------------------------------
	set undo(prevact) ""
	if [info exists undo] {unset undo}
	set data(undo) 1
	set undo(num) 0
	set undo(undo) ""
	set undo(redo) ""
	set currentname 1
	set data(zoom) 1

	# REM Create bindings
	# --------------------

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::Canvas chainoptions {$object}

Classy::Canvas	addoption -undosteps {undoSteps UndoSteps 40} {
	private $object undo
	set undo(redo) ""
	if {$value<1} {set value 1}
	if {$undo(num)>$value} {
		if {"[lindex $undo(list) 0]"==""} {lshift undo(list)}
		while {$undo(num)> $value} {
			while {"[lshift undo(list)]"!=""} {}
			incr undo(num) -1
		}
	}
}

# ------------------------------------------------------------------
#  destroy
# ------------------------------------------------------------------

Classy::Canvas method destroy {} {
	private $object fonts
	foreach font [array names fonts] {
		font delete $fonts($font)
	}
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Canvas chainallmethods {$object} canvas

#doc {Canvas command undo} cmd {
#pathname undo ?action? ?args?
#} descr {
# Without arguments, this method will undo the actions
# until the previous checkpoint is reached<br>
# When action is provided, it can have the following values
#<dl>
#<dt>check<dd>insert a checkpoint
#<dt>clear<dd>clear undo buffer
#<dt>add<dd>add ?args? to undo buffer, they will be executed when undo is called
#<dt>off<dd>turn undo buffering of
#<dt>on<dd>turn undo buffering on
#<dt>status<dd>query state of undo
#</dl>
#}
Classy::Canvas method undo {{action {}} args} {
	private $object w data undo ids
	switch $action {
		"" {
			if ![info exists undo(pos)] {
				set undo(pos) [expr {[llength $undo(undo)]-1}]
				if {"[lindex $undo(undo) $undo(pos)]" == ""} {incr undo(pos) -1}
			} else {
				incr undo(pos) -1
			}
			if {$undo(pos) == -1} {
				set undo(pos) 0
				return -code error "No more undo steps"
			}
			while 1 {
				set current [lindex $undo(undo) $undo(pos)]
				if {"$current"==""} break
				set action [lshift current]
				switch $action {
					create {
						$w delete $ids([lindex $current 0])
					}
					delete {
						private $object itemw names
						set items [lindex $current 0]
						foreach item $items args [lindex $current 1] width [lindex $current 2] {
							set ids($item) [eval $w create $args]
							set names($ids($item)) $item
							if {"$width" != ""} {
								set itemw($item) $width
							} else {
								catch {unset itemw($item)}
							}
						}
						set poss [lindex $current 3]
						set i [llength $items]
						incr i -1
						for {} {$i > -1} {incr i -1} {
							$w lower $ids([lindex $items $i]) $ids([lindex $poss $i])
						}
					}
					addtag {
						foreach {tag items} $current {
							foreach item [$object _realitems $items] {
								$w dtag $item $tag
							}
							lappend undo(redo) [list addtag $tag $items]
						}
					}
					dtag {
						foreach {items tag} $current {
							foreach item [$object _realitems $items] {
								$w addtag $tag withtag $item
							}
							lappend undo(redo) [list dtag $items $tag]
						}
					}
					itemconfigure {
						private $object itemw
						foreach item [lindex $current 0] args [lindex $current 1] width [lindex $current 2] {
							eval $w itemconfigure $ids($item) $args
							if {"$width" != ""} {
								set itemw($item) $width
							} else {
								catch {unset itemw($item)}
							}
						}
					}
					coords {
						set templist ""
						foreach item [lindex $current 0] coords [lindex $current 1]  {
							eval $w coords $ids($item) $coords
						}
					}
					move {
						foreach {action tagOrId xAmount yAmount} $current {
							set ctagOrId [Extral::arraytrans ids $tagOrId]
							$w move $ctagOrId [expr -$xAmount] [expr -$yAmount]
						}
					}
					scale {
						foreach {tagOrId xOrigin yOrigin xScale yScale} $current {
							set ctagOrId [Extral::arraytrans ids $tagOrId]
							set data(undo) 0
							$object scale $ctagOrId $xOrigin $yOrigin [expr {1/$xScale}] [expr {1/$yScale}]
							set data(undo) 1
						}
					}
					zoom {
						set zoom [lindex $current 0]
						set data(undo) 0
						$object zoom $zoom
						set data(undo) 1
					}
					rotate {
						foreach {tagOrId x y a} $current {
							set ctagOrId [Extral::arraytrans ids $tagOrId]
							$w visitor rotate $ctagOrId \
								-xcenter $x -ycenter $y -angle [expr -$a]
						}
					}
					raise {
						foreach {items poss} $current {
							set prevposs ""
							set ritems [$object _realitems $items]
							set vitems ""
							foreach item $items ritem $ritems {
								lappend prevposs [$w find below $ritem]
								lappend vitems $item
							}
							lappend undo(redo) [list raise $vitems [$object _virtualitems $prevposs]]
							foreach ritem $ritems pos [$object _realitems $poss] {
								lappend prevpos [$w find below $ritem]
								if {"$pos"==""} {
									$w raise $ritem
								} else {
									$w raise $ritem $pos
								}
							}
						}
					}
					a {
						set undo(busy) 1
						uplevel #0 [lindex $current 0]
						lappend undo(redo) [concat a $current]
						unset undo(busy)
					}
				}
				incr undo(pos) -1
				if {$undo(pos) == -1} {
					set undo(pos) 0
					break
				}
			}
			return 1
		}
		check {
			if $data(undo) {
				private $object options
				if {"[lindex $undo(undo) end]"==""} return
				lappend undo(undo) {}
				lappend undo(redo) {}
				incr undo(num)
				if {$undo(num)>$options(-undosteps)} {
					if {"[lindex $undo(undo) 0]"==""} {lshift undo(undo)}
					while {"[lshift undo(undo)]"!=""} {lshift undo(redo)}
					incr undo(num) -1
				}
			}
		}
		clear {
			if [info exists undo] {unset undo}
			set undo(num) 0
			set undo(undo) ""
			set undo(redo) ""
		}
		add {
			if ![info exists undo(pos)] {
				lappend undo(redo) [concat a [lindex $args 0]]
				lappend undo(undo) [concat a [lindex $args 1]]
			}
		}
		0 -
		off {
			set data(undo) 0
		}
		1 -
		on {
			set data(undo) 1
		}
		status {
			return $data(undo)
		}
	}
}

#doc {Canvas command redo} cmd {
#pathname redo 
#} descr {
# redo undone actions
#}
Classy::Canvas method redo {} {
	private $object w data undo
	if ![info exists undo(pos)] {
		return -code error "Nothing to redo"
	} else {
		if {"[lindex $undo(redo) $undo(pos)]" ==""} {
			incr undo(pos)
		}
	}
	set len [llength $undo(redo)]
	if {$undo(pos) == $len} {
		unset undo(pos)
		return -code error "No more undo steps"
	}
	while 1 {
		set current [lindex $undo(redo) $undo(pos)]
		if {"$current"==""} break
		set action [lshift current]
		switch $action {
			create {
				foreach {item type args} $current {
					set data(undo) 0
					set citem [eval $object create $type $args]
					set data(undo) 1
					$object rename $citem $item
				}
			}
			delete {
				set data(undo) 0
				$object delete [lindex $current 0]
			}
			addtag {
				foreach {tag items} $current {
					foreach item [$object _realitems $items] {
						$w addtag $tag withtag $item
					}
					lappend undo(list) [list addtag $tag $items]
				}
			}
			dtag {
				foreach {items tag} $current {
					foreach item [$object _realitems $items] {
						$w dtag $item $tag
					}
					lappend undo(list) [list dtag $items $tag]
				}
			}
			itemconfigure {
				set data(undo) 0
				eval $object itemconfigure [lindex $current 0] [lindex $current 1]
				set data(undo) 1
			}
			coords {
				set data(undo) 0
				eval $object coords [lindex $current 0] [lindex $current 1]
				set data(undo) 1
			}
			move {
				foreach {tagOrId xAmount yAmount} $current {
					set ctagOrId [Extral::arraytrans ids $tagOrId]
					$w move $ctagOrId $xAmount $yAmount
				}
			}
			scale {
				foreach {tagOrId xOrigin yOrigin xScale yScale} $current {
					set ctagOrId [Extral::arraytrans ids $tagOrId]
					set data(undo) 0
					$object scale $ctagOrId $xOrigin $yOrigin $xScale $yScale
					set data(undo) 1
				}
			}
			zoom {
				set zoom [lindex $current 0]
				set data(undo) 0
				$object zoom $zoom
				set data(undo) 1
			}
			rotate {
				foreach {tagOrId x y a} $current {
					set ctagOrId [Extral::arraytrans ids $tagOrId]
					$w visitor rotate $ctagOrId -xcenter $x -ycenter $y -angle $a
				}
			}
			raise {
				foreach {items poss} $current {
					set prevposs ""
					set ritems [$object _realitems $items]
					foreach item $items ritem $ritems {
						lappend prevposs [$w find below $ritem]
					}
					foreach ritem $ritems pos [$object _realitems $poss] {
						if {"$pos"==""} {
							$w raise $ritem
						} else {
							$w raise $ritem $pos
						}
					}
					lappend undo(list) [list raise $items [$object _virtualitems $prevposs]]
				}
			}
			a {
				set undo(busy) 1
				uplevel #0 [lindex $current 1]
				lappend undo(undo) [concat a $current]
				unset undo(busy)
			}
		}
		incr undo(pos)
		if {$undo(pos) == $len} {
			unset undo(pos)
			break
		}
	}
}

Classy::Canvas method addundo {redodata undodata} {
	private $object undo
	if [info exists undo(pos)] {
		set remove [lrange $undo(redo) [expr {$undo(pos)+1}] end]
		incr undo(num) [llength [lfind $remove ""]]
		set undo(redo) [lrange $undo(redo) 0 $undo(pos)]
		set undo(undo) [lrange $undo(undo) 0 $undo(pos)]
	}
	lappend undo(redo) $redodata
	lappend undo(undo) $undodata
}

#doc {Canvas command noundo} cmd {
#pathname noundo ?args?
#} descr {
# execute command without storing in undo buffer
#}
Classy::Canvas method noundo {args} {
	set keep $data(undo)
	set data(undo) 0
	eval [getprivate $object w] $args
	set data(undo) $keep
}


Classy::Canvas method raise {tagOrId {aboveThis all}} {
	private $object w data
	if $data(undo) {
		return [$w raise $tagOrId $aboveThis]
	}
	set undo(redo) ""

	set list [$w find withtag $tagOrId]
	set items ""
	set poss ""
	foreach item $list {
		lappend poss [$w find below $item]
	}
	lappend undo(list) [list raise [$object _virtualitems $list] [$object _virtualitems $poss]]
	set undo(prevact) ""
	$w raise $tagOrId $aboveThis
}


Classy::Canvas method lower {tagOrId {belowThis all}} {
	private $object w data
	if $data(undo) {
		return [$w lower $tagOrId $belowThis]
	}
	set undo(redo) ""

	set list [$w find withtag $tagOrId]
	set items ""
	set poss ""
	foreach item $list {
		lappend poss [$w find below $item]
	}
	lappend undo(list) [list raise [$object _virtualitems $list] [$object _virtualitems $poss]]
	set undo(prevact) ""
	$w lower $tagOrId $belowThis
}

Classy::Canvas method addtag {tag searchCommand args} {
	private $object w data
	set undo(prevact) ""
	if $data(undo) {
		return [eval $w addtag $tag $searchCommand $args]
	}
	set undo(redo) ""
	set list [eval $w find $searchCommand $args]
	set list [llremove $list [$w find withtag $tag]]
	if {"$list"!=""} {
		lappend undo(list) [list addtag $tag [$object _virtualitems $list]]
		eval $w addtag $tag $searchCommand $args
	}
}

Classy::Canvas method dtag {tagOrId {tagToDelete {}}} {
	private $object w data
	set undo(prevact) ""
	if $data(undo) {
		return [$w dtag $tagOrId $tagToDelete]
	}
	set undo(redo) ""
	if {"$tagToDelete"==""} {set tagToDelete $tagOrId}
	set list [$w find withtag $tagOrId]
	if {"$list"!=""} {
		lappend undo(list) [list dtag [$object _virtualitems $list] $tagToDelete]
		$w dtag $tagOrId $tagToDelete
	}
}

proc Classy::zoomfont {font zoom} {
	set size [lindex $font 1]
	if {"$size" == ""} {return $font}
	set size [expr int($size*$zoom)]
	if {$size==0} {set size 1}
	return [lreplace $font 1 1 $size]
}

Classy::Canvas method fastconfigure {items option value} {
	private $object w ids
	foreach item $items {
		$w itemconfigure $ids($item) $option $value
	}
}

Classy::Canvas method zoom {factor} {
	private $object w data fonts widths itemw ids
	if $data(undo) {
		$object addundo [list zoom $factor] [list zoom $data(zoom)]
	}
	set rfactor [expr {double($factor)/$data(zoom)}]
	$w scale all 0 0 $rfactor $rfactor
	foreach font [array names fonts] {
		eval font configure {$fonts($font)} [font actual [::Classy::zoomfont $font $factor]]
	}
	foreach width [array names widths] {
		set widths($width) [expr {$width*$factor}]
	}
	foreach {citem value} [array get itemw] {
		$w itemconfigure $citem -width $widths($value)
	}
	set data(zoom) $factor
}

Classy::Canvas method font {font} {
	private $object fonts rfonts data
	if ![info exists fonts($font)] {
		set fname [list $object font $font]
		eval font create {$fname} [font actual [::Classy::zoomfont $font $data(zoom)]]
		set fonts($font) $fname
		set rfonts($fname) $font
	}
	return $fonts($font)
}

Classy::Canvas method width {width} {
	private $object widths rwidths data
	if ![info exists widths($width)] {
		set widths($width) [expr $width*$data(zoom)]
		set rwidths($widths($width)) $width
	}
}

Classy::Canvas method rename {src dst} {
	private $object w names ids
	set id $ids($src)
	unset ids($src)
	unset names($id)
	set ids($dst) $id
	set names($id) $dst
}

Classy::Canvas method create {type args} {
	private $object w data names ids
	if {"$type" == "text"} {
		private $object fonts
		set pos [lsearch -exact $args -font]
		if {$pos == -1} {
			set font [option get $object font Font]
		} else {
			incr pos
			set font [lindex $args $pos]
			if {"[lindex $font 0]" == "$object"} {
				set font [lindex $font 2]
			}
		}
		if ![info exists fonts($font)] {
			$object font $font
		}
		if {$pos == -1} {
			lappend args -font $fonts($font)
		} else {
			set args [lreplace $args end end $fonts($font)]
		}
	}
	set pos [lsearch -exact $args -width]
	if {$pos != -1} {
		private $object widths itemw
		incr pos
		set width [lindex $args $pos]
		if ![info exists widths($width)] {
			$object width $width
		}
		set args [lreplace $args $pos $pos $widths($width)]
	}
	set citem [leval $w create $type $args]
	set names($citem) $citem
	set ids($citem) $citem
	if {$pos != -1} {
		set itemw($citem) $width
	}
	if $data(undo) {
		$object addundo [list create $citem $type $args] [list create $citem]
	}
	return $citem
}

Classy::Canvas method _items {id} {
	
}

Classy::Canvas method moptions {citems options} {
	private $object w names
	set list ""
	set items [Extral::arraytrans names $citems]
	set coptions ""
	foreach citem $citems {
		set temp ""
		foreach option $options {
			lappend temp $option [$w itemcget $citem $option]
		}
		lappend coptions $temp
	}
	set ws ""
	if {[lsearch $options -width] != -1} {
		private $object widths itemw
		set ws [Extral::arraytrans itemw $citems ""]
	}
	return [list $items $coptions $ws]
}

Classy::Canvas method itemconfigure {tagOrId args} {
	private $object w ids data undo
	set ctagOrId [Extral::arraytrans ids $tagOrId]
	set len [llength $args]
	if {$len == 0} {
		return [$w itemconfigure $ctagOrId]
	} elseif {$len == 1} {
		return [$w itemconfigure $ctagOrId $args]
	} else {
		set fpos [lsearch $args -font]
		set wpos [lsearch $args -width]
		if $data(undo) {
			$object addundo [list itemconfigure $tagOrId $args] \
				[concat itemconfigure [$object moptions [$w find withtag $ctagOrId] [lunmerge $args]]]
		}
		if {$fpos != -1} {
			private $object fonts
			incr fpos
			set font [lindex $args $fpos]
			if ![info exists fonts($font)] {
				$object font $font
			}			
			set args [lreplace $args $fpos $fpos $fonts($font)]
		}
		if {$wpos != -1} {
			private $object widths itemw
			incr wpos
			set width [lindex $args $wpos]
			if ![info exists widths($width)] {
				$object width $width
			}			
			set args [lreplace $args $wpos $wpos $widths($width)]
			foreach citem [$w find withtag $ctagOrId] {set itemw($citem) $width}
		}
		set result [eval $w itemconfigure $ctagOrId $args]
	}
}

Classy::Canvas method mcoords {citems} {
	private $object w names
	set items ""
	set coords ""
	foreach citem $citems {
		lappend coords [$w coords $citem]
		lappend items $names($citem)
	}
	return [list $items $coords]
}

Classy::Canvas method coords {tagOrId args} {
	private $object w data ids
	set ctagOrId [Extral::arraytrans ids $tagOrId]
	if {"$args"==""} {
		$w coords $ctagOrId
	} else {
		if $data(undo) {
			$object addundo [list coords $tagOrId $args] [concat coords [$object mcoords [$w find withtag $ctagOrId]]]
		}
		return [eval $w coords $ctagOrId $args]
	}
}

Classy::Canvas method find {args} {
	private $object names w
	return [Extral::arraytrans names [eval $w find $args]]
}

Classy::Canvas method move {tagOrId xAmount yAmount} {
	private $object w data ids
	set ctagOrId [Extral::arraytrans ids $tagOrId]
	if $data(undo) {
		private $object undo
		set lastundo [lindex $undo(undo) end]
		if {("[lindex $lastundo 0]" != "move")||("[lindex $lastundo 1]" != "$tagOrId")} {
			$object addundo [list move $tagOrId $xAmount $yAmount] [list move $tagOrId $xAmount $yAmount]
		} else {
			lpop undo(undo)			
			lpop undo(redo)			
			set x [expr {[lindex $lastundo 2]+$xAmount}]
			set y [expr {[lindex $lastundo 3]+$yAmount}]
			$object addundo [list move $tagOrId $x $y] [list move $tagOrId $x $y]
			set undo(undo)
		}
	}
	return [$w move $ctagOrId $xAmount $yAmount]
}

Classy::Canvas method scale {tagOrId xOrigin yOrigin xScale yScale} {
	private $object w data ids itemw fonts widths
	set ctagOrId [Extral::arraytrans ids $tagOrId]
	if $data(undo) {
		$object addundo [list scale $tagOrId $xOrigin $yOrigin $xScale $yScale] \
			[list scale $tagOrId $xOrigin $yOrigin $xScale $yScale]
	}
	foreach citem [$w find withtag $ctagOrId] {
		set nf [catch {$w itemcget $citem -font} font]
		if !$nf {
			set font [lindex $font 2]
			if ![info exists scalef($font)] {
				set newfont [Classy::zoomfont $font $yScale]
				set scalef($font) [$object font $newfont]
			}
			$w itemconfigure $citem -font $scalef($font)
		}
		if [info exists itemw($citem)] {
			set itemw($citem) [expr {$itemw($citem)*$yScale}]
			$w itemconfigure $citem -width [expr {$itemw($citem)*$data(zoom)}]
		}
	}
	return [$w scale $tagOrId $xOrigin $yOrigin $xScale $yScale]
}

if ![catch {package require Visrotate}] {
Classy::Canvas method rotate {tagOrId xcenter ycenter angle} {
	private $object w data
	set ctagOrId [Extral::arraytrans ids $tagOrId]
	if $data(undo) {
		$object addundo [list rotate $tagOrId $xcenter $ycenter $angle] \
			[list rotate $tagOrId $xcenter $ycenter $angle]
	}
	return [eval $w visitor rotate $ctagOrId -xcenter $xcenter -ycenter $ycenter -angle $angle]
}
} else {
Classy::Canvas method rotate {tagOrId xcenter ycenter angle} {
	private $object w data
	set ctagOrId [Extral::arraytrans ids $tagOrId]
	if $data(undo) {
		$object addundo [list rotate $tagOrId $xcenter $ycenter $angle] \
			[list rotate $tagOrId $xcenter $ycenter $angle]
	}
	set a [expr {$angle*0.0174532925199}]
	set cs [expr {cos($a)}]
	set sn [expr {sin($a)}]
	foreach citem [$w find withtag $ctagOrId] {
		set coords [$w coords $citem]
		set newcoords ""
		foreach {x y} $coords {
			set x [expr {$x - $xcenter}]
			set y [expr {$y - $ycenter}]
			lappend newcoords [expr {($x*$cs)+($y*$sn)+$xcenter}] [expr {-($x*$sn)+($y*$cs)+$ycenter}]
		}
		eval $w coords $citem $newcoords
	}
}
}

Classy::Canvas method delete {args} {
	private $object w data ids
	if $data(undo) {
		private $object names itemw
		foreach tagOrId $args {
			set ctagOrId [Extral::arraytrans ids $tagOrId]
			set citems [$w find withtag $ctagOrId]
			set items [Extral::arraytrans names $citems]
			set widths [Extral::arraytrans itemw $citems ""]
			set poss ""
			set allargs ""
			foreach citem $citems {
				set args [concat [$w type $citem] [$w coords $citem]]
				lappend poss $names([$w find above $citem])
				foreach option [$w itemconfigure $citem] {
					foreach {tag name class def value} $option {
						if {"$def"!="$value"} {
							lappend args $tag $value
						}
					}
				}
				lappend allargs $args
			}
			$object addundo [list delete $tagOrId] [list delete $items $allargs $widths $poss]
			$w delete $ctagOrId
		}
		return ""
	} else {
		set cargs [Extral::arraytrans ids $args]
		return [eval $w delete $cargs]
	}
}

