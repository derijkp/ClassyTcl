#Functions
proc filer_action {window x y} {
	if [catch {set name [$window name $x $y]}] return
	set type [$window type $x $y]
	$window active set $name
	puts [list $x $y $name $type]
	set curdir [file dirname [lindex [$window cget -list] 1]]
	if {"$name" == ".."} {
		if {"$curdir" != "."} {
			set name [file dirname $curdir]
		} else {
			set name [file dirname [pwd]]
		}
	}
	if [file isdir $name] {
		$window configure -list [getdir $name]
	} elseif {"$type"=="text"} {
		$window selection add $name
		puts $name
	} else {
		puts $name
	}
}

proc browser_order {window {type {}}} {
	global status
	if {"$type" == ""} {
		set type $status($window,order)
	} else {
		set status($window,order) $type
	}
	$window configure -order $type
}

proc browser_dataunder {window {value {}}} {
	global status
	if {"$value" == ""} {
		set value $status($window,dataunder)
	} else {
		set status($window,dataunder) $value
	}
	$window configure -dataunder $value
}

proc browser_small {window {value {}}} {
	global status
	if {"$value" == ""} {
		set value $status($window,small)
	} else {
		set status($window,small) $value
	}
	if $value {
		$window configure -getimage getsmimage
	} else {
		$window configure -getimage getimage
	}
}

proc browser_data {window {value {}}} {
	global status
	if {"$value" == ""} {
		set value $status($window,data)
	} else {
		set status($window,data) $value
	}
	if $value {
		$window configure -data {perm owner size date}
	} else {
		$window configure -data {}
	}
}
