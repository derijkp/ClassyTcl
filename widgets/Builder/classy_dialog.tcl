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
	foreach w [list $base $base.actions $base.options] {
		bindtags $w Classy::WindowBuilder_$object
	}
	$object select $base.options
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
	append body "\tClassy::Dialog $outw [$object getoptions $base]\n"
	append body [$object generate [winfo children $base.options]]
	append body [$object gridconf $base.options]
	append body "\n"
	foreach b [lremove [$base button] close] {
		catch {
			append body "\t$outw add $b [$object getoption $base.actions.$b -text]"
			append body " [$object getoption $base.actions.$b -command]"
			regsub -all "\\\\\n\t*" [$object getoptions $base.actions.$b -text -command] {} options
			append body " $options\n"
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
	bindtags $w Classy::WindowBuilder_$object
}

proc ::Classy::WindowBuilder::edit_Classy::DialogButton {object w} {
	set c [$object current]
	eval destroy [winfo children $w]
	::Classy::WindowBuilder::defattredit $object $w {
		-text Text 0 -default Default 0 -command Command 1
	} 12 0
}

