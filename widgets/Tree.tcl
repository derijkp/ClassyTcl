# *************************************************
#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Tree
# ----------------------------------------------------------------------
#doc Tree title {
#Tree
#} descr {
# subclass of <a href="../basic/Class.html">Class</a><br>
# <b>Tree is not a widget type</b>. It is a class whose objects can 
# be associated with a canvas widget. When a Tree instance is 
# associated with a canvas, it will draw a tree on this canvas. 
#}
#doc {Tree options} h2 {
#	Tree options
#} descr {
# A tree object supports the following options in its configure method
#<dl>
#<dt>-canvas<dd>name of canvas to draw the chart
#<dt>-tag<dd>unique tag for all canvas items of the chart
#<dt>-padx<dd>size of indentation
#<dt>-pady<dd>size left open between different lines
#<dt>-font<dd>default font for the text lines
#</dl>
#}
#doc {Tree command} h2 {
#	Tree specific methods
#} descr {
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Tree {} {}
proc Tree {} {}
}
catch {Classy::Tree destroy}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Class subclass Classy::Tree
Classy::export Tree {}

Classy::Tree classmethod init {args} {
	super
	private $object options data
	array set options {
		-canvas {}
		-padx 10
		-pady 2
		-font {}
	}
	setprivate $object order ""
	set options(-tag) "Tree:$object"
	eval $object configure $args
	set data() {t c}
}


#doc {Tree command destroy} cmd {
#pathname destroy 
#} descr {
#}
Classy::Tree method destroy {} {
	private $object options
	::Classy::busy
	$options(-canvas) delete $options(-tag)
	update idletasks
	::Classy::busy remove
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------


#doc {Tree command configure} cmd {
#pathname configure ?option? ?value? ?option value ...?
#} descr {
#}
Classy::Tree method configure {args} {
	private $object options
	set len [llength $args]
	if {$len == 0} {
		return [array get options]
	} elseif {$len == 1} {
		return $options([lindex $args 0])
	} else {
		foreach {option value} $args {
			if ![info exists options($option)] {
				error "unknown option \"$option\""
			}
			set previous $options($option)
			set options($option) $value
			switch -- $option {
				-canvas {
					private $object options
					if {"$options(-tag)" == ""} {
						set options(-tag) Tree::$object
					}
					update idletasks
					::Classy::todo $object _redraw
				}
				-padx {
					::Classy::todo $object _redraw
				}
				-pady {
					::Classy::todo $object _redraw
				}
				-font {
					::Classy::todo $object _redraw
				}
				-tag {
					::Classy::todo $object _redraw
				}
			}
		}
	}
}

Classy::Tree method _drawnode {node} {
	private $object data options
	set canvas $options(-canvas)
	if {"$canvas" == ""} return

	array set pa $data($node)
	set tag $options(-tag)
	set x [$canvas coords $pa(i)]
	set y [lpop x]
	set sy $y
	set bbox [$canvas bbox $pa(i)]
	set height [expr {[lindex $bbox 3]-[lindex $bbox 1]}]
	set width [expr {[lindex $bbox 2]-[lindex $bbox 0]}]
	set y [expr {$y + $height/2}]
	set plusicon [Classy::geticon plus]
	set minusicon [Classy::geticon minus]
	set padx $options(-padx)
	set pady $options(-pady)
	set font $options(-font)
	if ![info exists pa(l)] {return $y}
	foreach name $pa(l) {
		catch {unset ca}
		array set ca $data($name)
		if ![info exists ca(w)] {
			set ca(i) [$canvas create image $x $y -image $ca(im) \
				-tags [list $tag classy::Tree $name item]]
		} else {
			set ca(i) [$canvas create window $x $y -window $ca(w)\
				-tags [list $tag classy::Tree $name item]]
		}
		set bbox [$canvas bbox $ca(i)]
		set height [expr {[lindex $bbox 3]-[lindex $bbox 1]}]
		set width [expr {[lindex $bbox 2]-[lindex $bbox 0]}]
		set ypos [expr {$y + $height/2.0}]
		set xpos [expr {$x + $width/2.0 + $padx + $ca(len)}]
		$canvas coords $ca(i) $xpos $ypos
		set ca(x) [$canvas create line $x $ypos $xpos $ypos \
			-tags [list $tag classy::Tree $name line]]
		$canvas lower $ca(x)
		set ca(ti) [$canvas create text [expr {$x + $padx + $ca(len) + $width + 5}] $ypos -text $ca(txt) -anchor w \
			-tags [list $tag classy::Tree $name text]]
		if {"$font" != ""} {
			$canvas itemconfigure $ca(ti) -font $font
		}
		set y [expr {$y + $height + $pady}]
		switch $ca(t) {
			f {
				set ca(s) [$canvas create image $x $ypos -image $plusicon \
					-tags [list $tag classy::Tree $name symbol]]
			}
			c {
				set ca(s) [$canvas create image $x $ypos -image $minusicon \
					-tags [list $tag classy::Tree $name symbol]]
			}
		}
		set data($name) [array get ca]
		if {"$ca(t)" == "f"} {
			set y [$object _drawnode $name]
		}
	}
	set pa(y) [$canvas create line $x $sy $x $ypos \
		-tags [list $tag classy::Tree $node yline]]
	$canvas lower $pa(y)
	set data($node) [array get pa]
	return $y
}

Classy::Tree method _redraw {} {
	private $object options data
	::Classy::canceltodo $object _redraw
	set canvas $options(-canvas)
	if {"$canvas" == ""} return

	::Classy::busy
	$canvas delete $options(-tag)
	set i [$canvas create text 10 10 -text "" -tags [list $options(-tag) classy::Tree]]
	set data() [structlset $data() i $i]
	$object _drawnode {}
	::Classy::busy remove
}

#doc {Tree command addnode} cmd {
# pathname addnode parent node args
#} descr {
#}
Classy::Tree method addnode {parent node args} {
	private $object data options
	if [info exists data($node)] {
		error "node \"$node\" exists"
	}
	if ![info exists data($parent)] {
		error "parent node \"$parent\" doesn't exist"
	}
	array set pa $data($parent)
	if {("$pa(t)" != "f")&&("$pa(t)" != "c")} {
		error "parent node \"$parent\" is an endnode"
	}
	set pa(t) f
	lappend pa(l) $node

	Classy::parseopt $args opt {
		-text {} {}
		-image {} {}
		-window {} {}
		-length {} 0
		-type {folder end} folder
	} args

	if {"$opt(-type)" == "folder"} {
		set im [Classy::geticon sm_folder]
		set type c
	} else {
		set im [Classy::geticon sm_file]
		set type e
	}
	if {"$opt(-image)" != ""} {
		set im $opt(-image)
	}
	set data($parent) [array get pa]
	set data($node) [list t $type p $parent txt $opt(-text) im $im len $opt(-length)]
	if {"$opt(-window)" != ""} {
		lappend data($node) w $opt(-window)
	}
	Classy::todo $object _redraw
}

#doc {Tree command closenode} cmd {
# pathname closenode node
#} descr {
#}
Classy::Tree method closenode {node} {
	private $object data options
	set data($node) [structlset $data($node) t c]
	Classy::todo $object _redraw
}

#doc {Tree command opennode} cmd {
# pathname opennode node
#} descr {
#}
Classy::Tree method opennode {node} {
	private $object data options
	set data($node) [structlset $data($node) t f]
	Classy::todo $object _redraw
}

#doc {Tree command clearnode} cmd {
# pathname clearnode node
#} descr {
#}
Classy::Tree method clearnode {node} {
	private $object data options
	array set pa $data($node)
	if {("$pa(t)" != "f")&&("$pa(t)" != "c")} {
		error "parent node \"$node\" is an endnode"
	}
	set canvas $options(-canvas)
	if {"$canvas" == ""} return
	if [info exists pa(l)] {
		foreach name $pa(l) {
			catch {unset ca}
			array set ca $data($name)
			switch $ca(t) {
				f -
				c {
					$object clearnode $name
					$canvas delete $ca(s)
				}
			}
			$canvas delete $ca(i)
			$canvas delete $ca(ti)
			$canvas delete $ca(x)
			catch {unset data($name)}
		}
		catch {
			$canvas delete $pa(y)
			unset pa(y)
		}
		unset pa(l)
	}
	set pa(t) c
	set data($node) [array get pa]
	Classy::todo $object _redraw
}

#doc {Tree command deletenode} cmd {
# pathname deletenode node
#} descr {
#}
Classy::Tree method deletenode {node} {
	private $object data options
	set canvas $options(-canvas)
	if {"$canvas" == ""} return
	array set ca $data($node)
	switch $ca(t) {
		f -
		c {
			$object clearnode $node
			$canvas delete $ca(s)
		}
	}
	$canvas delete $ca(i)
	$canvas delete $ca(ti)
	$canvas delete $ca(x)

	set parent $ca(p)
	array set pa $data($parent)
	set pa(l) [lremove $pa(l) $node]
	set data($parent) [array get pa]

	catch {unset data($node)}
	Classy::todo $object _redraw
}

#doc {Tree command exists} cmd {
# pathname exists node
#} descr {
#}
Classy::Tree method exists {node} {
	private $object data
	return [info exists data($node)]
}

#doc {Tree command type} cmd {
# pathname type node
#} descr {
#}
Classy::Tree method type {node} {
	private $object data
	return [structlget $data($node) t]
}

#doc {Tree command node} cmd {
# pathname node index
# pathname node x y
#} descr {
#}
Classy::Tree method node {index {y {}}} {
	private $object data options
	set canvas $options(-canvas)
	if {"$canvas" == ""} return
	if {"$y" != ""} {
		set index [$canvas find overlapping $index $y $index $y]
	}
	set tags [$canvas itemcget $index -tags]
	return [lindex $tags 2]
}

#doc {Tree command parentnode} cmd {
# pathname parentnode node
#} descr {
#}
Classy::Tree method parentnode {node} {
	private $object data
	return [structlget $data($node) p]
}