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
catch {Classy::Canvas destroy}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Canvas
Classy::export Canvas {}

Classy::Canvas classmethod init {args} {
	setprivate $object w [super canvas]

	# REM Initialise options and variables
	# ------------------------------------
	private $object undo
	set undo(prevact) ""
	if [info exists undo] {unset undo}
	set undo(num) 0
	set undo(list) ""
	set undo(redo) ""

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
	private $object w undo
	switch $action {
		"" {
			if ![info exists undo(list)] {return 0}
			if {"$undo(list)"==""} {return 0}
			if {"[lindex $undo(list) end]"==""} {lpop undo(list)}
			if {"[lindex $undo(redo) end]"!=""} {lappend undo(redo) {}}
			while 1 {
				set list [lpop undo(list)]
				if {"$list"==""} break
				set action [lshift list]
				switch $action {
					coords {
						set templist ""
						foreach {item coords} $list {
							set ritem [$object _realitems $item]
							lappend undo(redo) [list coords $item [$w coords $ritem]]
							eval $w coords $ritem $coords
						}
					}
					move {
						foreach {tagOrId xAmount yAmount} $list {
							$w move [$object _realitems $tagOrId] [expr -$xAmount] [expr -$yAmount]
							lappend undo(redo) [list move $tagOrId $xAmount $yAmount]
						}
					}
					scale {
						foreach {tagOrId xOrigin yOrigin xScale yScale} $list {
							$w scale [$object _realitems $tagOrId] $xOrigin $yOrigin \
								[expr 1/$xScale] [expr 1/$yScale]
							lappend undo(redo) [list scale $tagOrId \
								$xOrigin $yOrigin $xScale $yScale]
						}
					}
					rotate {
						foreach {tagOrId x y a} $list {
							$w visitor rotate [$object _realitems $tagOrId] \
								-xcenter $x -ycenter $y -angle [expr -$a]
							lappend undo(redo) [list rotate $tagOrId $x $y [expr -$a]]
						}
					}
					create {
						foreach {item type args} $list {
							set ritem [$object _realitems $item]
							lappend undo(redo) [list create $item $type $args]
							$w delete $ritem
							$object _rmtranslate $item
						}
					}
					delete {
						foreach {item type args pos} $list {
							$object _translate $item [eval $w create $type $args]
							lappend undo(redo) [list delete $item $type $args $pos]
							if {"$pos"!=""} {
								eval $w lower [$object _realitems [list $item $pos]]
							}
						}
					}
					addtag {
						foreach {tag items} $list {
							foreach item [$object _realitems $items] {
								$w dtag $item $tag
							}
							lappend undo(redo) [list addtag $tag $items]
						}
					}
					dtag {
						foreach {items tag} $list {
							foreach item [$object _realitems $items] {
								$w addtag $tag withtag $item
							}
							lappend undo(redo) [list dtag $items $tag]
						}
					}
					itemconfigure {
						foreach {tagOrId args} $list {
							set options ""
							set rtagOrId [$object _realitems $tagOrId] 
							foreach {option value} $args {
								lappend options $option [$w itemcget $rtagOrId $option]
							}
							lappend undo(redo) [list itemconfigure $tagOrId $options]
							eval $w itemconfigure $rtagOrId $args
						}
					}
					raise {
						foreach {items poss} $list {
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
						uplevel #0 [lindex $list 0]
						lappend undo(redo) [concat a $list]
						unset undo(busy)
					}
				}
			}
			incr undo(num) -1
			if {"[lindex $undo(redo) end]"!=""} {lappend undo(redo) {}}
			return 1
		}
		check {
			if ![info exists undo(off)] {
				private $object options
				set undo(redo) ""
				if {"[lindex $undo(list) end]"!=""} {
					lappend undo(list) {}
				}
				incr undo(num)
				if {$undo(num)>$options(-undosteps)} {
					if {"[lindex $undo(list) 0]"==""} {lshift undo(list)}
					while {"[lshift undo(list)]"!=""} {}
					incr undo(num) -1
				}
				set undo(prevact) ""
			}
		}
		clear {
			private $object translate
			if [info exists undo] {unset undo}
			if [info exists translate] {unset translate}
			set undo(num) 0
			set undo(list) ""
			set undo(redo) ""
			set undo(prevact) ""
		}
		add {
			if ![info exists undo(busy)] {
				lappend undo(list) [concat a $args]
				set undo(prevact) ""
			}
		}
		0 -
		off {
			set undo(off) 1
		}
		1 -
		on {
			if [info exists undo(off)] {unset undo(off)}
		}
		status {
			if [info exists undo(off)] {
				return 0
			} else {
				return 1
			}
		}
	}
}

#doc {Canvas command redo} cmd {
#pathname redo 
#} descr {
# redo undone actions
#}
Classy::Canvas method redo {} {
	private $object w undo
	if {"$undo(redo)"==""} return
	if {"[lindex $undo(redo) end]"==""} {lpop undo(redo)}
	if {"[lindex $undo(list) end]"!=""} {lappend undo(list) {}}
	while 1 {
		set list [lpop undo(redo)]
		if {"$list"==""} break
		set action [lshift list]
		switch $action {
			coords {
				set templist ""
				foreach {item coords} $list {
					set ritem [$object _realitems $item]
					lappend undo(list) [list coords $item [$w coords $ritem]]
					eval $w coords $ritem $coords
				}
			}
			move {
				foreach {tagOrId xAmount yAmount} $list {
					$w move [$object _realitems $tagOrId] $xAmount $yAmount
					lappend undo(list) [list move $tagOrId $xAmount $yAmount]
				}
			}
			scale {
				foreach {tagOrId xOrigin yOrigin xScale yScale} $list {
					$w scale [$object _realitems $tagOrId] $xOrigin $yOrigin $xScale $yScale
					lappend undo(list) [list scale $tagOrId \
						$xOrigin $yOrigin $xScale $yScale]
				}
			}
			rotate {
				foreach {tagOrId x y a} $list {
					$w visitor rotate [$object _realitems $tagOrId] \
						-xcenter $x -ycenter $y -angle [expr -$a]
					lappend undo(list) [list rotate $tagOrId $x $y [expr -$a]]
				}
			}
			create {
				foreach {item type args} $list {
					$object _translate $item [eval $w create $type $args]
					lappend undo(list) [list create $item $type $args]
				}
			}
			delete {
				foreach {item type args pos} $list {
					set ritem [$object _realitems $item]
					lappend undo(list) [list delete $item $type $args $pos]
					$w delete $ritem
					$object _rmtranslate $item
				}
			}
			addtag {
				foreach {tag items} $list {
					foreach item [$object _realitems $items] {
						$w addtag $tag withtag $item
					}
					lappend undo(list) [list addtag $tag $items]
				}
			}
			dtag {
				foreach {items tag} $list {
					foreach item [$object _realitems $items] {
						$w dtag $item $tag
					}
					lappend undo(list) [list dtag $items $tag]
				}
			}
			itemconfigure {
				foreach {tagOrId args} $list {
					set options ""
					set rtagOrId [$object _realitems $tagOrId]
					foreach {option value} $args {
						lappend options $option [$w itemcget $rtagOrId $option]
					}
					lappend undo(list) [list itemconfigure $tagOrId $options]
					eval $w itemconfigure $rtagOrId $args
				}
			}
			raise {
				foreach {items poss} $list {
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
				uplevel #0 [lindex $list 1]
				lappend undo(undo) [concat a $list]
				unset undo(busy)
			}
		}
	}
	if {"[lindex $undo(list) end]"!=""} {lappend undo(list) {}}
	incr undo(num)
}

#doc {Canvas command noundo} cmd {
#pathname noundo ?args?
#} descr {
# execute command without storing in undo buffer
#}
Classy::Canvas method noundo {args} {
	eval [getprivate $object w] $args
}


Classy::Canvas method raise {tagOrId {aboveThis all}} {
	private $object w undo
	if [info exists undo(off)] {
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
	private $object w undo
	if [info exists undo(off)] {
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


Classy::Canvas method itemconfigure {tagOrId args} {
	private $object w
	if {"$args"==""} {
		eval $w itemconfigure $tagOrId $args
	} elseif {[llength $args]==1} {
		$w itemconfigure $tagOrId $args
	} else {
		private $object undo
		set undo(prevact) ""
		if [info exists undo(off)] {
			return [eval $w itemconfigure $tagOrId $args]
		}
		set undo(redo) ""
		set list [$w find withtag $tagOrId]
		foreach item $list vitem [$object _virtualitems $list] {
			set options ""
			foreach {option value} $args {
				lappend options $option [$w itemcget $item $option]
			}
			lappend undo(list) [list itemconfigure $vitem $options]
		}
		eval $w itemconfigure $tagOrId $args
	}
}


Classy::Canvas method move {tagOrId xAmount yAmount} {
	private $object w undo
	if [info exists undo(off)] {
		return [$w move $tagOrId $xAmount $yAmount]
	}
	set vtagOrId [$object _virtualitems $tagOrId]
	set undo(redo) ""

	if {("$undo(prevact)"=="move")&&("$undo(prevargs)"=="$tagOrId")} {
		set act [lpop undo(list)]
		lappend undo(list) [list move $vtagOrId \
			[expr $xAmount+[lindex $act 2]] [expr $yAmount+[lindex $act 3]]]
	} else {
		lappend undo(list) [list move $vtagOrId $xAmount $yAmount]
	}
	$w move $tagOrId $xAmount $yAmount
	set undo(prevact) move
	set undo(prevargs) $tagOrId
}


Classy::Canvas method scale {tagOrId xOrigin yOrigin xScale yScale} {
	private $object w undo
	if [info exists undo(off)] {
		return [$w scale $tagOrId $xOrigin $yOrigin $xScale $yScale]
	}
	set undo(redo) ""

	set vtagOrId [$object _virtualitems $tagOrId]
	lappend undo(list) [list scale $vtagOrId $xOrigin $yOrigin $xScale $yScale]
	set undo(prevact) ""
	$w scale $tagOrId $xOrigin $yOrigin $xScale $yScale
}


Classy::Canvas method visitor {type tagOrId args} {
	private $object w undo
	if [info exists undo(off)] {
		return [eval $w visitor $type $tagOrId $args]
	}
	set undo(redo) ""

	set vtagOrId [$object _virtualitems $tagOrId]
	if {"$type"=="rotate"} {
		set temp(-xcenter) 0
		set temp(-ycenter) 0
		set temp(-angle) 0
		array set temp $args
		lappend undo(list) [list rotate $vtagOrId $temp(-xcenter) $temp(-ycenter) $temp(-angle)]
		eval $w visitor rotate [$object _realitems $tagOrId] $args
	} else {
		return [eval $w visitor $type $tagOrId $args]
	}
}


Classy::Canvas method coords {tagOrId args} {
	private $object w
	if {"$args"==""} {
		$w coords $tagOrId
	} else {
		private $object undo
		if [info exists undo(off)] {
			return [eval $w coords $tagOrId $args]
		}
		set undo(redo) ""
	
		set list [$w find withtag $tagOrId]
		if {("$undo(prevact)"!="coords")||("$undo(prevargs)"!="$tagOrId")} {
			foreach item $list vitem [$object _virtualitems $list] {
				lappend undo(list) [list coords $vitem [$w coords $item]]
			}
		}
		set undo(prevact) coords
		set undo(prevargs) $tagOrId
		eval $w coords $tagOrId $args
	}
}


Classy::Canvas method addtag {tag searchCommand args} {
	private $object w undo
	set undo(prevact) ""
	if [info exists undo(off)] {
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
	private $object w undo
	set undo(prevact) ""
	if [info exists undo(off)] {
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


Classy::Canvas method create {type args} {
	private $object w undo
	set undo(prevact) ""
	if [info exists undo(off)] {
		return [eval $w create $type $args]
	}
	set undo(redo) ""

	set item [eval $w create $type $args]
	lappend undo(list) [list create $item $type $args]
	return $item
}

Classy::Canvas method delete {args} {
	private $object w undo
	set undo(prevact) ""
	if [info exists undo(off)] {
		return [eval $w delete $args]
	}
	set undo(redo) ""

	set list ""
	foreach tag $args {
		set list [concat $list [$w find withtag $tag]]
	}
	foreach item $list vitem [$object _virtualitems $list] {
		set type [$w type $item]
		set args [$w coords $item]
		set pos [$w find above $item]
		set options ""
		foreach option [$w itemconfigure $item] {
			foreach {tag name class def value} $option {
				if {"$def"!="$value"} {
					lappend args $tag $value
				}
			}
		}
		lappend undo(list) [list delete $vitem $type $args [$object _virtualitems $pos]]
		$w delete $item
	}
	return ""
}

Classy::Canvas method _translate {virtual real} {
	private $object translate
	set translate($virtual) $real
	set translate(v$real) $virtual
}

Classy::Canvas method _rmtranslate {virtual} {
	private $object translate
	if [info exists translate($virtual)] {
		unset translate(v$translate($virtual))
		unset translate($virtual)
	}
}

Classy::Canvas method _realitems {list} {
	private $object translate
	set result ""
	foreach item $list {
		if [info exists translate($item)] {
			lappend result $translate($item)
		} else {
			lappend result $item
		}
	}
	return $result
}

Classy::Canvas method _virtualitems {list} {
	private $object translate
	set result ""
	foreach item $list {
		if [info exists translate(v$item)] {
			lappend result $translate(v$item)
		} else {
			lappend result $item
		}
	}
	return $result
}
