#
# Classy::Dialog
#

proc ::Classy::WindowBuilder::start_Classy::Dialog {object base} {
	private $object data
	set buttons [lremove [winfo children $base.actions] $base.actions.close]
	$object startedit $buttons
	foreach b $buttons {
		set data(class,$b) Classy::DialogButton
	}
	bindtags $base.actions.close Classy::none
	$object startedit [winfo children $base.options]
	set data(redir,$base.actions) $base
	set data(parent,$base.options) $base.options
	foreach w [list $base $base.actions $base.options] {
		bindtags $w $data(tags)
	}
	$object select $base.options
	wm protocol $base WM_DELETE_WINDOW [varsubst base {
		catch {$base configure -destroycommand {}}
		catch {destroy $base}
	}]
}

proc ::Classy::WindowBuilder::edit_Classy::Dialog {object w} {
	set c [$object current]
	eval destroy [winfo children $w]
	frame $w.general
	::Classy::WindowBuilder::defattredit $object $w.general {
		-title Title 0 -keepgeometry Keepgeometry 0 -closecommand Closecommand 1
	} 12 0
	set ::Classy::WindowBuilder::error {}
	button $w.addb -text "Add Button" -command [list ::Classy::WindowBuilder::Dialog_addbutton $object $c]
	grid $w.addb -sticky w
	grid $w.general -sticky nswe
	grid columnconfigure $w 0 -weight 1
	grid rowconfigure $w 1 -weight 1
}

proc ::Classy::WindowBuilder::generate_Classy::Dialog {object base} {
	private $object current data
	set outw [$object outw $base]
	set body ""
	append body "\tClassy::Dialog $outw [$object getoptions $base -menu]\n"
	append body [$object generate [winfo children $base.options]]
	append body [$object gridconf $base.options]
	append body "\n"
	set def 1
	foreach b [lremove [$base button] close] {
		catch {
			append data(parse) "\t$outw add $b [$object getoption $base.actions.$b -text]"
			append data(parse) " [$object getoption $base.actions.$b -command]"
			if $def {
				if {"[$base.actions.$b cget -default]" == "active"} {
					append data(parse) " default"
				}
				set def 0
			}
			append data(parse) "\n"
		}
	}
	if [info exists data(opt-mainmenu,$base)] {
		if {"$data(opt-mainmenu,$base)" != ""} {
			if {"$data(opt-menuwin,$base)" != ""} {
				foreach win $data(opt-menuwin,$base) {
					append data(parse) "\tClassy::DynaMenu attachmainmenu $data(opt-mainmenu,$base) $win\n"
				}
			} else {
				append data(parse) "\tClassy::DynaMenu attachmainmenu $data(opt-mainmenu,$base)\n"
			}
		}
	}
	return $body
}

proc ::Classy::WindowBuilder::Dialog_addbutton {object base} {
	private $object data
	set list [::$base button]
	set num 1
	while 1 {
		if {[lsearch $list b$num] == -1} break
		incr num
	}
	::$base add b$num "button $num" {}
	set w $base.actions.b$num
	set data(class,$w) Classy::DialogButton
	bindtags $w $data(tags)
}

proc ::Classy::WindowBuilder::attr_Classy::DialogButton_name {object w args} {
puts buttonname
putsvars object w args
	private $object data
	if {"$args" == ""} {
		return [lindex [split $w {\.}] end]
	} else {
		set value [lindex $args 0]
		set split [split $w {\.}]
		[winfo toplevel $w] rename [lindex $split end] $value
		set w [join [lreplace $split end end $value] .]
		set data(class,$w) Classy::DialogButton
		bindtags $w $data(tags)
	}
}

proc ::Classy::WindowBuilder::edit_Classy::DialogButton {object w} {
	set c [$object current]
	eval destroy [winfo children $w]
	::Classy::WindowBuilder::defattredit $object $w {
		-text Text 0 -default Default 0 name Name 0 -command Command 1
	} 12 0
}

proc ::Classy::WindowBuilder::generate_Classy::DialogButton {object base} {
	error "Cannot copy Dialog buttons, use dialog itself"
}

proc ::Classy::WindowBuilder::parse_Classy::Dialog {object base line} {
	private $object data
	set pos [string first "\"" $line]
	set end [string last "\"" $line]
	if {$pos == -1} {
		set pos [string first "\[" $line]
		set end [string last "\]" $line]
	}
	if {$pos == -1} return
	set command [string range $line $pos $end]
	regexp {add ([^ ]+)} $line temp b
	set data(opt-command,$base.actions.$b) $command
}
