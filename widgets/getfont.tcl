#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::getfont
# ----------------------------------------------------------------------
proc Classy::getfont {args} {
	global tcl_platform
	if {("$tcl_platform(platform)"=="windows")&&("[option get . getFont GetFont]"=="Win")} {
		set len [llength $args]
		if {[llength $args]==0} {
			set font ""
		} elseif {[llength $args]==1} {
			set font [lindex $args 0]
		} elseif {[llength $args]==2} {
			if {[lindex $args 0]!="-font"} {
				error "Illegal option \"[lindex $args 0]\"\n must be -font"
			}
			set font [lindex $args 1]
		} else {
			error "Wrong # arguments, format is \"Classygetfont ?-font font?\""
		}
		set family [lindex $font 0]
		if {"$family"==""} {set family Arial}
		set size [expr int([lindex $font 1]+0.5)]
		if {"$size"==""} {set size 12}
		set style [lindex $font 2]
		if {"$style"==""} {set style normal}
		return [ClassyGetFont $family $size $style]
	} else {
		set ::Classy::temp ""
		::Classy::Dialog .classy__fontselect -help classy_font_select
		set w [.classy__fontselect component options]
		.classy__fontselect add go "Select" "set ::Classy::temp \[$w.fontselect get\]" default
		::Classy::FontSelector $w.fontselect -command "$w.fontselect.font nocmdset \[$w.fontselect get\]"
		if [catch {
			if {"$args"!=""} {eval $w.fontselect configure $args}
		} error] {
			destroy .classy__fontselect
			error $error
		}
		pack $w.fontselect -fill both -expand yes
		update idletasks
		.classy__fontselect configure -resize {1 1}
		tkwait window .classy__fontselect
		return $::Classy::temp
	}
}

proc Classy::createfont {fontname font} {
	set family [lindex $font 0]
	set size [lindex $font 1]
	set underline 0
	set overstrike 0
	set weight normal
	set slant roman
	foreach style [lindex $font 2] {
		switch $style {
			normal {set weight normal}
			bold {set weight bold}
			roman {set slant roman}
			italic {set slant italic}
			underline {set underline 1}
			overstrike {set overstrike 1}
		}
	}
	if {"$fontname"!=""} {
		font create $fontname -family $family -size $size -weight $weight -slant $slant -underline $underline -overstrike $overstrike
	} else {
		font create -family $family -size $size -weight $weight -slant $slant -underline $underline -overstrike $overstrike
	}
}



