#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::DragDrop
# ----------------------------------------------------------------------
#doc DragDrop title {
#DragDrop
#} descr {
# subclass of <a href="../basic/Class.html">Class</a><br>
# DragDrop is not a widget and is not intended to produce instances. 
# It is a class that manages drag and drop.
# A drop can be started using the command <br>
# Classy::DragDrop start window value ...<br>
# This should be bound to the <<Action-Motion>> event od source window.<p>
# A window will be notified of a drop by the virtual event &lt;&lt;Drop&gt;&gt;, so<br>
# bind window &lt;&lt;Drop&gt;&gt; command<br>
# will execute command when somethind is dropped on the window<p>
# The window is also notified of the current drag entering, moving in, or leaving the
# window by the &lt;&lt;Drag-Enter&gt;&gt; &lt;&lt;Drag-Motion&gt;&gt; and\
# &lt;&lt;Drag-Leave&gt;&gt; events, and can take apropriate actions.
# The program can get the data associated with the drag using the command <br>
# Classy::DragDrop get ?type?
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::DragDrop {} {}
proc DragDrop {} {}
}

# ------------------------------------------------------------------
#  Class creation
# ------------------------------------------------------------------

Class subclass Classy::DragDrop
Classy::export DragDrop {}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

bind Classy::DragDrop <Motion> {Classy::DragDrop move}
bind Classy::DragDrop <ButtonRelease> {Classy::DragDrop drop}
bind Classy::DragDrop <<Escape>> {Classy::DragDrop abort}
bind Classy::DragDrop <KeyRelease> {Classy::DragDrop configure -transfer copy}

#bind Classy::DragDrop <<Drag-Move>> {Classy::DragDrop configure -transfer move}
#bind Classy::DragDrop <<Drag-Link>> {Classy::DragDrop configure -transfer link}

#doc {DragDrop command start} cmd {
# Classy::DragDrop start window value ?option value ...?<br>
#} descr {
# starts a drag. It clears all previously changed drag and drop settings to their
# default values or the ones supplied as options to the start method.
# $window must the window from wich the drag is started.
# $value is the default value given for the drop if no type is specified.
# the options are the same as for the Classy::DragDrop configure method.
#}
Classy::DragDrop method start {from value args} {
	private $object data types ftypes
	set types() text/plain
	set types(text/plain) $value
	set data(transfer) none
	set data(prev) $from
	set data(from) $from
	set data(value) $value
	set data(cursor) [$from cget -cursor]
	set data(bindtags) [bindtags $from]
	set ftypes() {}
	foreach event [bind Classy::DragDrop_extra] {bind Classy::DragDrop_extra $event {}}
	set w .classy__dragdrop
	if ![winfo exists $w] {
		toplevel $w -class Classy::DragDrop -width 10 -height 10
		wm withdraw $w
		wm geometry $w +10000+10000
		wm overrideredirect $w 1
		label $w.small -image [Classy::geticon plus] -borderwidth 0 -highlightthickness 0
		grid $w.small -row 0 -column 0 -sticky se
		label $w.l -image [Classy::geticon file] -borderwidth 0 -highlightthickness 0
		grid $w.l -row 0 -column 0 -sticky se
		raise $w.small
		$w.l configure -cursor hand2
		bindtags $w Classy::DragDrop
	}
	lower .classy__dragdrop.small
	catch {unset data(remote)}
	if {[string first $args {-image {}}] == -1} {
	    wm geometry  $w +[expr {[winfo pointerx $w]+1}]+[expr {[winfo pointery $w]+1}]
		wm deiconify $w
	    raise $w
	}
	$from configure -cursor hand2
	eval $object configure $args
	bindtags $from {Classy::DragDrop_extra Classy::DragDrop}
    foreach app [lremove [winfo interps] [tk appname]] {
		catch {send -- $app ::class::setprivate Classy::DragDrop data(prev) {{}} }
		catch {send -- $app ::class::setprivate Classy::DragDrop data(remote) [list [tk appname]]}
	}
	focus $from
}

#doc {DragDrop command bind} cmd {
# Classy::DragDrop start window value ?option value ...?<br>
#} descr {
# with this method, bindings can be added to the current drag, eg. to change the transfer type
# in response to a keypress. Note that the command must come after the drag was
# started with the start method.
#}
Classy::DragDrop method bind {args} {
	eval bind Classy::DragDrop_extra $args
}

Classy::DragDrop method _events {app x y} {
	private $object data
	set dropw [winfo containing $x $y]
	if {"$data(prev)" != ""} {
		if {"$data(prev)" != "$dropw"} {
			event generate $data(prev) <<Drag-Leave>> -x $x -y $y
		}
	}
	if {"$dropw" == ""} {
		set data(prev) ""
		return ""
	}
	if {"$data(prev)" != "$dropw"} {
		event generate $dropw <<Drag-Enter>> -x $x -y $y
	}
	set data(dropw) [winfo containing $x $y]
	event generate $dropw <<Drag-Motion>> -x $x -y $y
	set data(prev) $dropw
}

#doc {DragDrop command start} cmd {
# Classy::DragDrop move<br>
#} descr {
# This method is called while dragging. It updates the dragged window, and generates
# the Drag events.
#}
Classy::DragDrop method move {} {
	private $object data
	set w .classy__dragdrop
	set x [winfo pointerx $w]
	set y [winfo pointery $w]
	if ![info exists data(withdrawn)] {
		wm geometry  $w +[expr {$x+1}]+[expr {$y+1}]
	}
	set data(app) {}
	set dropw [winfo containing $x $y]
	set curapp [tk appname]
	if {"$data(prev)" != ""} {
		if {"$data(prev)" != "$dropw"} {
			event generate $data(prev) <<Drag-Leave>> -x $x -y $y
		}
	}
	if {"$dropw" != ""} {
		set data(app) $curapp
		if {"$data(prev)" != "$dropw"} {
			event generate $dropw <<Drag-Enter>> -x $x -y $y
		}
		event generate $dropw <<Drag-Motion>> -x $x -y $y
	} else {
	    foreach app [lremove [winfo interps] $curapp] {
			catch {send -- $app Classy::DragDrop _events [list $curapp] $x $y} res
		}
	}
	set data(prev) $dropw
}

#doc {DragDrop command start} cmd {
# Classy::DragDrop configure ?option? ?value? ?option value...?<br>
#} descr {
# returns or changes the options for the current drag. following options are supported:
#<dl>
#<dt>-types {type data ?type data ...?}
#<dd>gives a list of types, and the data that should be returned when the drop site asks for the data.
#<dt>-ftypes {type function ?type function ...?}
#<dd>gives a list of types, and a function which will generate the data desired by the drop site. 
# The function will be executed at global level in the application where the drag originated.
#<dt>-transfer type
#<dd> type of transfer: $type can be none, copy, move or link
#<dt>-cursor cursor
#<dd> cursor of drag
#<dt>-image image
#<dd> dragged image
#</dl>
#}
Classy::DragDrop method configure {args} {
	private $object data types ftypes
	if [info exists data(remote)] {
		send -- $data(remote) Classy::DragDrop configure $args
	} else {
		if {[llength $args] == 0} {
			set list {}
			foreach option {-types -ftypes -transfer -cursor -image} {
				lappend list $option [$object configure $option]
			}
			return $list
		} elseif {[llength $args] == 1} {
			set option [lindex $args 0]
			switch -- $option {
				-transfer {
					return $data(transfer)
				}
				-types {
					set list {}
					foreach type $types() {
						lappend list $type $types($type)
					}
					return $list
				}
				-ftypes {
					set list {}
					foreach type $ftypes() {
						lappend list $type $ftypes($type)
					}
					return $list
				}
				-cursor {
					return [$data(from) cget -cursor]
				}
				-image {
					if [info exists data(withdrawn)] {return {}}
					return [.classy__dragdrop.l cget -image]
				}
				default {
					return -code error "Unknown option $option"
				}
			}
		}
		foreach {option value} $args {
			switch -- $option {
				-transfer {
					set data(transfer) $value
					switch $value {
						none {
							lower .classy__dragdrop.small
						}
						copy {
							.classy__dragdrop.small configure -image [Classy::geticon drag_copy]
							raise .classy__dragdrop.small
						}
						move {
							.classy__dragdrop.small configure -image [Classy::geticon drag_move]
							raise .classy__dragdrop.small
						}
						link {
							.classy__dragdrop.small configure -image [Classy::geticon drag_link]
							raise .classy__dragdrop.small
						}
					}
				}
				-types {
					set types() {}
					foreach {type d} $value {
						lappend types() $type
						set types($type) $d
					}
				}
				-ftypes {
					set ftypes() {}
					foreach {type d} $value {
						lappend ftypes() $type
						set ftypes($type) $d
					}
				}
				-cursor {
					$data(from) configure -cursor $value
				}
				-image {
					if {"$value" == ""} {
						wm withdraw .classy__dragdrop
						set data(withdrawn) 1
					} else {
						.classy__dragdrop.l configure -image $value
						wm deiconify .classy__dragdrop
						raise .classy__dragdrop
						catch {unset data(withdrawn)}
					}
				}
				default {
					return -code error "Unknown option $option"
				}
			}
		}
	}
}

#doc {DragDrop command types} cmd {
# Classy::DragDrop types ?pattern?<br>
#} descr {
# returns a list of all types supported by the current drag; optionally only those
# matching $pattern are returned
#}
Classy::DragDrop method types {{pattern *}} {
	private $object data types ftypes
	if [info exists data(remote)] {
		return [send -- $data(remote) Classy::DragDrop types $pattern]
	} else {
		return [concat $types() $ftypes()]
	}
}

#doc {DragDrop command get} cmd {
# Classy::DragDrop get ?type?<br>
#} descr {
# returns the data associated with with the type $type of the current drag.
# If no type is given, the default value is returned (the data given to the start method.)
#}
Classy::DragDrop method get {{type {}}} {
	private $object data types ftypes
	if [info exists data(remote)] {
		return [send -- $data(remote) Classy::DragDrop get $type]
	} else {
		if {"$type" == ""} {
			return $data(value)
		} else {
			if [info exists types($type)] {
				return $types($type)
			} elseif [info exists ftypes($type)] {
				return [uplevel #0 $ftypes($type)]
			} else {
				return -code error "Type \"$type\" not present"
			}
		}
	}
}

#doc {DragDrop command abort} cmd {
# Classy::DragDrop abort<br>
#} descr {
# abort the current drag.
#}
Classy::DragDrop method abort {} {
	private $object data
	set w .classy__dragdrop
	wm withdraw $w
	wm geometry $w +10000+10000
	bindtags $data(from) $data(bindtags)
	$data(from) configure -cursor $data(cursor)
}

#doc {DragDrop command drop} cmd {
# Classy::DragDrop stop<br>
#} descr {
# make the drop. The user normally does not have to call this method, as it is
# usually called by the bindings of DragDrop.
#}
Classy::DragDrop method drop {} {
	private $object data
	set w .classy__dragdrop
	set x [winfo pointerx $w]
	set y [winfo pointery $w]
    wm geometry  $w +[expr {[winfo pointerx $w]+1}]+[expr {[winfo pointery $w]+1}]
	wm withdraw $w
	wm geometry $w +10000+10000
	bindtags $data(from) $data(bindtags)
	$data(from) configure -cursor $data(cursor)
	set dropw [winfo containing $x $y]
	if {"$dropw" != ""} {
		event generate $dropw <<Drop>>
	} else {
	    foreach appl [winfo interps] {
	        set dropw [send -- $appl winfo containing $x $y]
	        if {"$dropw" != ""} break
	    }
		if {"$dropw" != ""} {
			send -- $appl [list catch [list Classy::DragDrop _remote [tk appname]]]
			send -- $appl [list catch [list event generate $dropw <<Drop>>]]
		}
	}
}

# event generate .e <<Drop>>
