#!/bin/sh
# the next line restarts using wish \
exec wish8.0 "$0" "$@"
#
# ClassyTcl
# --------- Peter De Rijk
#
# $Format: "package require -exact ClassyTcl 0.$ProjectMajorVersion$"$
package require -exact ClassyTcl 0.3
set file [lindex $argv 0]

proc convtool {src} {
puts "Converting $src"
	set result ""
	array set ttl {
		Classy::configtool Toolbars
		Classy::configmenu Menus
	}
	array set tp {
		Classy::configtool toolbar
		Classy::configmenu menu
	}
	set f [open $src]
	while {![eof $f]} {
		set line [cmd_get $f]
		if [regexp ^Classy::config $line] {
			foreach {type name descr value} $line {}
			regsub -all \n\n\n* $value \n value
			append result [list # $ttl($type) $name]\n
			append result "# $descr\n"
			append result [list $tp($type) $name $value]\n
			append result "\n"
		}
	}
	close $f
	return $result
}

proc convother {src} {
puts "Converting $src"
	array set ttl {
		Classy::configkey Keys
		Classy::configmouse Mouse
		Classy::configcolor Colors
		Classy::configfont Fonts
		Classy::configmisc Misc
	}
	array set tp {
		Classy::configkey key
		Classy::configmouse mouse
		Classy::configcolor color
		Classy::configfont font
		Classy::configmisc misc
	}
	set f [open $src]
	set result ""
	while {![eof $f]} {
		set line [cmd_get $f]
		if [regexp ^Classy::configmisc $line] {
			foreach {type title cmd} $line {}
			foreach {name key value type descr} $cmd {
				if [regexp ^# $name] {
					set name [string range $name 1 end]
					set comment #
				} else {
					set comment ""
				}
				regsub -all \n\n $value \n value
				regsub -all \n\n $value \n value
				append result [list # Misc $title $name]\n
				append result "# $descr\n"
				append result $comment[list $type $key $value]\n
				append result "\n"
			}
		} elseif [regexp ^Classy::config $line] {
			foreach {type title cmd} $line {}
			foreach {name key value descr} $cmd {
				if [regexp ^# $name] {
					set name [string range $name 1 end]
					set comment #
				} else {
					set comment ""
				}
				regsub -all \n\n $value \n value
				regsub -all \n\n $value \n value
				append result [list # $ttl($type) $title $name]\n
				append result "# $descr\n"
				append result $comment[list $tp($type) $key $value]\n
				append result "\n"
			}
		}
	}
	close $f
	return $result
}

proc convfiles {files} {
	set result ""
	foreach src $files {
		set file [file tail $src]
		switch $file {
			Toolbars.tcl - Menus.tcl {
				append result [convtool $src]
			}
			Keys.tcl - Mouse.tcl - Colors.tcl - Fonts.tcl - Misc.tcl {
				append result [convother $src]
			}
		}
	}
	return $result
}

proc convrec {src} {
	foreach file [dirglob $src *.tcl] {
		if [file isdir [file join $src $file]] {
			convrec [file join $src $file]
		} else {
			switch $file {
				Toolbars.tcl - Menus.tcl {
					set c [convtool [file join $src $file]]
					file_write [file join $src [file root $file].conf] $c
					file delete [file join $src $file]
				}
				Keys.tcl - Mouse.tcl - Colors.tcl - Fonts.tcl - Misc.tcl {
					set c [convother [file join $src $file]]
					file_write [file join $src [file root $file].conf] $c
					file delete [file join $src $file]
				}
			}
		}
	}
}

proc convcode {dir} {
	set files [glob [file join $dir *.tcl]]
	foreach file $files {
		set c [cmd_split [file_read $file]]
		set newc ""
		foreach line $c {
			if [regexp "^proc \[^ \]+ args \{# ClassyTcl generated (\[^ \n\]+)" $line temp type] {
				set newcode ""
				set function [lindex $line 1]
				set code [lindex $line 3]
				set code [string_change $code {$window $object {varsubst window} {varsubst object}}]
				set code [cmd_split $code]
				set opt [lindex $code 2]
				set code [lreplace $code 0 2 "\tsuper init"]
				set code [lreplace $code 2 2]
				set pos [lsearch -regexp $code {^# ClassyTcl Initialise}]
				if {$pos == -1} {
					set pos [lsearch -regexp $code "^\t# Parse this"]
				}
				set code [linsert $code $pos \t[list if {"$args" == "___Classy::Builder__create"} {return $object}]]
				set pos [lsearch -regexp $code {^# ClassyTcl Finalise}]
				set insert "\t# Configure initial arguments"
				append insert \n\t[list if {"$args" != ""} {eval $object configure $args}]
				if {$pos != -1} {
					set code [linsert $code $pos $insert]
				} else {
					lappend code $insert
				}
				set code [join $code \n]
				lappend newcode [list Classy::$type subclass $function]
				lappend newcode "[list $function] method init args \{\n$code\}"
				foreach {option options default} [lindex $opt 3] {
					if [string length $options] {
						if {"$options" == "0 1"} {
							set code {set value [true $value]}
						} else {
							set code "\tif \{\[lsearch $options $value\] == -1\} \{\n"
							append code "\t\terror \"Unkown option(s): \\\"$value\\\"\\nmust be one of: $options\"\n"
							append code "\t\}\n"
						}
					} else {
						set code {}
					}
					lappend newcode [list $function addoption $option [list [string range $option 1 end] "[string toupper [string index $option 1]][string range $option 2 end]" $default] $code]
				}
				set f [open [file join [file dir $file] interface $function.tcl] w]
				set space 0
				foreach line $newcode {
					if ![string length $line] {
						if $space continue
						set space 1
					} else {
						set space 0
					}
					puts $f $line
				}
				close $f
			} elseif [regexp "^proc main \{?args\}?" $line] {
				regsub "(\[\[\n\t \]mainw)(\[\]\t\n \]\[^.\])" $line "\\1 .mainw\\2" line
				regsub "(\[\n\t \]mainw)(\n)" $line "\\1 .mainw\\2" line
				lappend newc $line
			} else {
				lappend newc $line
			}
		}
		catch {file rename -force $file $file~}
		set f [open [file join [file dir $file] code [file tail $file]] w]
		set space 0
		foreach line $newc {
			if ![string length $line] {
				if $space continue
				set space 1
			} else {
				set space 0
			}
			puts $f $line
		}
		close $f
	}
	catch {Classy::auto_mkindex [file join [file dirname $file] interface] *.tcl}	
	catch {Classy::auto_mkindex [file join [file dirname $file] code] *.tcl}
}

invoke {file} {
	if [file isdir $file] {
		set dir $file
		set file [file join $file [file tail $file].tcl]
	} else {
		set dir [file dir $file]
	}
	if [file exists [file join $dir conf init]] {
		puts "file $dir in older format: converting"
		set c [convfiles [glob [file join $dir conf init *.tcl]]]
		file_write [file join $dir conf init.conf] $c
		catch {file delete -force [file join $dir conf init]}
	}
	convrec [file join $dir conf]
	file copy -force [file join $::class::dir template template.tcl] $file
	catch {file mkdir [file join $dir conf themes]}
	foreach file [file join $dir conf opt *.tcl] {
		catch {file rename $file [file join $dir conf themes [file tail $file]]}
	}
	catch {file delete [file join $dir conf opt]}
	file mkdir [file join $dir lib interface]
	file mkdir [file join $dir lib code]
	convcode [file join $dir lib]
	file delete [file join $dir [file tail $dir]]
	puts "conversion done"
	puts "WARNING: behaviour has changed a lot between these versions, and you might very well need to change some code"
} $file

exit