#Functions
proc gettext {file} {
	return [file tail $file]
}

proc getimage {file} {
	if {[file isdirectory $file]} {
		return [Classy::geticon folder]
	} else {
		return [Classy::geticon file]
	}
}

proc getsmimage {file} {
	set pre {}
	if {[file isdirectory $file]} {
		return [Classy::geticon sm_folder]
	} else {
		return [Classy::geticon sm_file]
	}
}

proc getdata {file} {
	file lstat $file temp
	array set attr [file attributes $file]
	set data ""
	lappend data $attr(-permissions)
	lappend data "$attr(-owner).$attr(-group)"
	lappend data $temp(size)
	lappend data [clock format $temp(mtime) -format "%b %d %H:%M %Y"]
	return $data
}

proc getdir {dir} {
	if {"$dir" == ""} return
	set dirs {}
	set files {}
	foreach file [glob -nocomplain $dir/*] {
		if {[file isdirectory $file]} {
			lappend dirs $file
		} else {
			lappend files $file
		}
	}
	set result ..
	foreach file [lsort $dirs] {
		lappend result $file
	}
	foreach file [lsort $files] {
		lappend result $file
	}
	return $result
}

