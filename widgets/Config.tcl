#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Config
# ----------------------------------------------------------------------
#doc Config title {
#Config
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
#}
#doc {Config options} h2 {
#	Config specific options
#}
#doc {Config command} h2 {
#	Config specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Config {} {}
proc Config {} {}
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Config
Classy::export Config {}

Classy::Config classmethod init {args} {
	super
	Classy::OptionMenu $object.select
	message $object.help
#	grid $object.select -row 0 -column 0 -sticky we
#	grid $object.help -row 0 -column 1 -sticky we
	grid columnconfigure $object 1 -weight 1
	grid rowconfigure $object 1 -weight 1

	# REM Initialise options and variables
	# ------------------------------------

	# REM Create bindings
	# --------------------

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	update idletasks
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::Config addoption -closecommand {closeCommand CloseCommand {}} {
}

# ------------------------------------------------------------------
#  destroy
# ------------------------------------------------------------------

#doc {Config command destroy} cmd {
#pathname destroy 
#} descr {
#}
Classy::Config method destroy {} {
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Config method close {} {
	private $object data options
	if [info exists data(changed)] {
		if ![Classy::yorn "Are you sure you want to abort the current editing session"] {
			return 1
		}
	}
	uplevel #0 $options(-closecommand)
	return 0
}

Classy::Config method new {type function file} {
	global auto_index
	if [file isdir $file] {return -code error "please select a file instead of a directory"}
	set f [open $file a]
	switch $type {
		dialog {
			puts $f "\nproc $function args \{# ClassyTcl generated Dialog"
			puts $f "\tif \[regexp \{^\\.\} \$args] \{"
			puts $f "\t\tset window \[lpop args\]"
			puts $f "\t\} else \{"
			puts $f "\t\tset window .$function"
			puts $f "\t\}"
			puts $f "\tClassy::parseopt \$args opt {}"
			puts $f "\t# Create windows"
			puts $f "\tClassy::Dialog \$window"
			puts $f "\t#Initialisation code"			
			puts $f "\}"
		}
		toplevel {
			puts $f "\nproc $function args \{# ClassyTcl generated Toplevel"
			puts $f "\tif \[regexp \{^\\.\} \$args] \{"
			puts $f "\t\tset window \[lpop args\]"
			puts $f "\t\} else \{"
			puts $f "\t\tset window .$function"
			puts $f "\t\}"
			puts $f "\tClassy::parseopt \$args opt {}"
			puts $f "\t# Create windows"
			puts $f "\ttoplevel \$window"
			puts $f "\t#Initialisation code"			
			puts $f "\}"
		}
	}
	close $f
}

Classy::Config method save {} {
	global auto_index
	private $object data
	set file $data(file)
	switch $data(type) {
		dialog - toplevel {
			set function $data(function)
			set code [$object code]
			uplevel #0 $code
			if ![info complete $code] {
				error "error: generated code not complete (contains unmatched braces, parentheses, ...)"
			}
			set result ""
			set work ""
			set done 0
			foreach line [split [readfile $file] "\n"] {
				append work "$line\n"
				if [info complete $work] {
					if [string match "proc $function args *" $work] {
						append result "$code\n"
						set done 1
					} else {
						append result $work
					}
					set work ""
				}
			}
			if !$done {
				append result "$code\n"
			}
			file copy -force $file $file~
			writefile $file $result
			catch {auto_mkindex [file dirname $file] *.tcl}
			set auto_index($function) [list source $file]
			set result $function
		}
		function {	
			file copy -force $file $file~
			$object.feditor save
			uplevel #0 source $data(file)
			catch {auto_mkindex [file dirname $file] *.tcl}
			set result $file
		}
	}
	return $result
}

Classy::Config method open {file function type} {
	private $object data
	catch {grid forget $object.$type}
	set data(type) $type
	if ![winfo exists $object.$type] {
		$object _create$type $object.$type
	}
#	$object.select configure -list "dfg sdfg sdgh"
	grid $object.$type -row 1 -column 0 -columnspan 2 -sticky nwse
	$object select$type $file $function
}

Classy::Config method _createcolor {w} {
	private $object data
	frame $w
	listbox $w.list -yscrollcommand [list $w.scroll set]
	scrollbar $w.scroll -orient vertical -command [list $w.list yview]
	Classy::Entry $w.current -label current
	grid $w.list -row 0 -column 0 -sticky nwse
	grid $w.scroll -row 0 -column 1 -sticky ns
	grid columnconfigure $w 2 -weight 1
	grid rowconfigure $w 0 -weight 1
}

Classy::Config method _selectcolor {w} {
}
