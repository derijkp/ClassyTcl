#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# tools
# ----------------------------------------------------------------------

proc Class::cmd_split {data} {
        set result ""
        set current ""
        foreach line [split $data "\n"] {
                if {"$current" != ""} {
                        append current "\n"
                }
                append current $line
                set end [string length $line]
                incr end -1
                if ![regexp {\\$} $current] {
                        if [info complete $current] {
                                lappend result $current
                                set current ""
                        }
                }
        }
        return $result
}

proc Class::auto_mkindex {dir args} {
	eval ::auto_mkindex $dir $args
	global errorCode errorInfo
	set oldDir [pwd]
	cd $dir
	set dir [pwd]
	append index "\n# Addition of ClassyTcl classes defined in the directory\n"
	if {$args == ""} {
		set args *.tcl
	}
	foreach file [eval glob $args] {
		set f ""
		set error [catch {
			set f [open $file]
			set c [Class::cmd_split [read $f]]
			close $f
			catch {unset definedhere}
			foreach line $c {
				if {"[string index $line 0]" == "#"} {
					if {"[string range $line 0 10]" == "#auto_index"} {
						set Name [lindex $line 1]
						append index "set [list auto_index($Name)] \[list source \[file join \$dir [list $file]\]\]\n"
					}
				} elseif [regexp {^[ ]*([^ ]+)[ ]+([^ ]+)[ ]+([^ ]+)} $line temp c cmd name] {
					switch -- $cmd {
						subclass {
							set name [auto_qualify $name ::]
							append index "set [list auto_index($name)] \[list source \[file join \$dir [list $file]\]\]\n"
							set definedhere($name) 1
						}
						classmethod {
							set c [auto_qualify $c ::]
							if ![info exists definedhere($c)] {
								set name ::Class::${c},,cm,$name
								append index "set [list auto_index($name)] \[list source \[file join \$dir [list $file]\]\]\n"
							}
						}
						method {
							set c [auto_qualify $c ::]
							if ![info exists definedhere($c)] {
								set name ::Class::${c},,m,$name
								append index "set [list auto_index($name)] \[list source \[file join \$dir [list $file]\]\]\n"
							}
						}
					}			
				}
			}
		} msg]
		if $error {
			set code $errorCode
			set info $errorInfo
			catch {close $f}
			cd $oldDir
			error $msg $info $code
		}
	}
	set f ""
	set error [catch {
		set f [open tclIndex a]
		puts $f $index nonewline
		close $f
		cd $oldDir
	} msg]
	if $error {
		set code $errorCode
		set info $errorInfo
		catch {close $f}
		cd $oldDir
		error $msg $info $code
	}
}
