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
		set line [getcomplete $f]
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
		set line [getcomplete $f]
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
					writefile [file join $src [file root $file].conf] $c
					file delete [file join $src $file]
				}
				Keys.tcl - Mouse.tcl - Colors.tcl - Fonts.tcl - Misc.tcl {
					set c [convother [file join $src $file]]
					writefile [file join $src [file root $file].conf] $c
					file delete [file join $src $file]
				}
			}
		}
	}
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
		writefile [file join $dir conf init.conf] $c
		catch {file delete -force [file join $dir conf init]}
	}
	convrec [file join $dir conf]
	file copy -force [file join $::class::dir template template.tcl] $file
	catch {file mkdir [file join $dir conf themes]}
	foreach file [file join $dir conf opt *.tcl] {
		catch {file rename $file [file join $dir conf themes [file tail $file]]}
	}
	catch {file delete [file join $dir conf opt]}
	puts "conversion ok"
} $file

exit