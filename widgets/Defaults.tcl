#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::Default
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Default {} {}
proc Default {} {}
}
catch {Classy::Default destroy}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Class subclass Classy::Default
Classy::export Default {}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Default method get {type {item {}} {notfound {}}} {
	private $object defaults_$type
	if {"$item"==""} {
		if [info exists defaults_${type}] {
			return [array get defaults_${type}]
		}
	}
	if [info exists defaults_${type}($item)] {
		return [set defaults_${type}($item)]
	} else {
		return $notfound
	}
}

Classy::Default method set {type item value} {
	private $object defaults_$type
	set defaults_${type}($item) $value
}

Classy::Default method unset {type item} {
	private $object defaults_$type
	unset defaults_${type}($item)
}

Classy::Default method add {type item value} {
	private $object defaults_$type
	if ![info exists defaults_${type}($item)] {
		set defaults_${type}($item) [list $value]
	} elseif {[lsearch -exact [set defaults_${type}($item)] $value]==-1} {
		lunshift defaults_${type}($item) $value
	}
}

Classy::Default method remove {type item value} {
	private $object defaults_$type
	if [info exists defaults_${type}($item)] {
		set defs [set defaults_${type}($item)]
		set pos [lsearch -exact $defs $value]
		if {$pos==-1} return
		if {$pos==0} {
			set temp ""
		} else {
			set temp "[lrange $defs 0 [expr $pos-1]] "
		}
		append temp [lrange $defs [expr $pos+1] end]
		set defaults_${type}($item) $temp
	}
}

Classy::Default method names {{type {}}} {
	if {"$type"!=""} {
		private $object defaults_$type
		array names defaults_$type
	} else {
		set types ""
		foreach var [$object private] {
			if [regexp {^defaults_(.*)$} $var temp var] {
				lappend types $var
			}
		}
		return $types
	}
}

Classy::Default method load {{type {}} {file {}}} {
	if {"$type" == ""} {
		foreach dir [set ::Classy::dirs] {
			set dir [file join $dir def]
			foreach type [dirglob $dir *] {
				private $object defaults_$type
				if [file readable [file join $dir $type]] {
					array set defaults_$type [readfile [file join $dir $type]]
				}
			}
		}
		return {}
	}
	private $object defaults_$type
	if {"$file"==""} {
		set file $type.def
	}
	foreach dir [set ::Classy::dirs] {
		set dir [file join $dir def]
		foreach file [dirglob $dir *] {
			if [file readable [file join $dir $type]] {
				array set defaults_$type [readfile [file join $dir $file]]
			}
		}
	}
}

#Classy::Default method customise {msg type {file {}} {options {app*}}} {
#	set file [$object save $type $file]
#	Classycustomise__item $msg $file "Classy::Default clear $type;Classy::Default load $class %F" $options
#}

Classy::Default method save {{type {}} {file {}}} {
	if {"$type" == ""} {
		set todo [$object names]
	} else {
		set todo $type
	}
	set workdir [file join $::Classy::dir(appuser) def]
	if ![file writable $workdir] {
		return "not saved"
	}
	foreach type $todo {
		private $object defaults_$type
		set f [open [file join $workdir $type] "w"]
		foreach {name value} [array get defaults_$type] {
			puts $f "[list $name] [list $value]"
		}
		close $f
	}
	return {}
}

Classy::Default method clear {{type {}}} {
	if {"$type" == ""} {
		set todo [$object names]
	} else {
		set todo $type
	}
	foreach type $todo {
		private $object defaults_$type
		if [info exists defaults_$type] {unset defaults_$type}
	}
}

Classy::Default load
atexit add {
	catch {Classy::Default save}
}
