#
# Classy::Toplevel
#

proc ::Classy::WindowBuilder::start_Classy::Toplevel {object base} {
	private $object data bindtags
	set bindtags($base) [bindtags $base]
	$object startedit [winfo children $base]
	bindtags $base Classy::WindowBuilder_$object
	$object select $base
}

proc ::Classy::WindowBuilder::edit_Classy::Toplevel {object w} {
	set c [$object current]
	eval destroy [winfo children $w]
	frame $w.general
	::Classy::WindowBuilder::defattredit $object $w.general {
		-title Title 0 -menu Menu 0 -keepgeometry Keepgeometry 0 -resize Resize 0 -destroycommand destroycommand 1
	} 12 0
	set ::Classy::WindowBuilder::error {}
	grid $w.general -sticky nswe
	grid columnconfigure $w 0 -weight 1
	grid rowconfigure $w 0 -weight 1
}

proc ::Classy::WindowBuilder::generate_Classy::Toplevel {object base} {
	private $object current data
	set body ""
	set outw [$object outw $base]
	append body "\tClassy::Toplevel $outw [$object getoptions $base -menu]\n"
	append body [$object generatebindings $base $outw]
	set children ""
	foreach child [winfo children $base] {
		if [regexp "^$base.classy__\[a-z\]+\$" $child] continue
		if [regexp "^$base.#classy__#menu_" $child] continue
		lappend children $child
	}
	append body [$object generate $children]
	if [info exists data(opt-mainmenu,$base)] {
		if {"$data(opt-mainmenu,$base)" != ""} {
			if {"$data(opt-menuwin,$base)" != ""} {
				foreach win $data(opt-menuwin,$base) {
					append body "\tClassy::DynaMenu attachmainmenu $data(opt-mainmenu,$base) $win\n"
				}
			} else {
				append body "\tClassy::DynaMenu attachmainmenu $data(opt-mainmenu,$base)\n"
			}
		}
	}
	append body [$object gridconf $base]
	append body "\n"
	return $body
}



