#
# Classy::DynaMenu
#

proc ::Classy::WindowBuilder::add_Classy::DynaMenu {object base args} {
	private $object data current
	set base $data(base)
	if [info exists ::Classy::targetwindow] {
		set menuwin $::Classy::targetwindow
	} else {
		set menuwin $current(w)
	}
	set outw [$object outw $base]
	if {"$outw" == "$base"} {return -code error "cannot add main menu to \"$base\""}
	if {![info exists data(opt-mainmenu,$base)] || ("$data(opt-mainmenu,$base)" == "")} {
		set data(opt-mainmenu,$base) Classy::Dummy
		set data(opt-menuwin,$base) [$object outw $menuwin]
		set menu [::Classy::WindowBuilder::menuset $object]
	} else {
		append data(opt-menuwin,$base) " [$object outw $menuwin]"
	}
	return ""
}

proc ::Classy::WindowBuilder::delete_Classy::DynaMenu {object w} {
	private $object data
	set base $data(base)
	set data(opt-mainmenu,$base) ""
	::Classy::WindowBuilder::menuset $object
	return ""
}

proc ::Classy::WindowBuilder::edit_Classy::DynaMenu {object w} {
	private $object data current
	Classy::Entry $w.menutype -width 2 -label "Menutype"	-orient stacked \
		-command "::Classy::WindowBuilder::menuset $object" \
		-textvariable [privatevar $object data(opt-mainmenu,$data(base))]
	$w.menutype configure -orient horizontal -labelwidth 12
	grid $w.menutype -row 2 -column 0 -sticky we
	Classy::Entry $w.cmdw -width 2 -label "Menu window(s)"	-orient stacked \
		-command "::Classy::WindowBuilder::menuset $object" \
		-textvariable [privatevar $object data(opt-menuwin,$data(base))]
	$w.cmdw configure -orient horizontal -labelwidth 12
	grid $w.cmdw -row 3 -column 0 -sticky we
	grid rowconfigure $w 4 -weight 1
	grid columnconfigure $w 0 -weight 1
}
