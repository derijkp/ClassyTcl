#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::getfont
# ----------------------------------------------------------------------
#doc getfont title {
#getfont
#} index {
# Dialogs
#} shortdescr {
# returns a font selected by the user
#}
#doc {getfont getfont} cmd {
#getfont ?option value ...?
#} descr {
# returns a font selected by the user. The select method depends om the
# ClassyTcl configuration. Possible options are
#<dl>
#<dt>-font
#</dl>
#}
# These will be added to tclIndex by Classy::auto_mkindex
#auto_index getfont
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
			error "Wrong # arguments, format is \"getfont ?-font font?\""
		}
		set family [lindex $font 0]
		if {"$family"==""} {set family Arial}
		set size [expr int([lindex $font 1]+0.5)]
		if {"$size"==""} {set size 12}
		set style [lindex $font 2]
		if {"$style"==""} {set style normal}
		return [Classy::GetFont $family $size $style]
	} else {
		set ::Classy::temp ""
		::Classy::Dialog .classy__.fontselect -help classy_font_select
		set w [.classy__.fontselect component options]
		.classy__.fontselect add go "Select" "set ::Classy::temp \[$w.fontselect get\]" default
		::Classy::FontSelect $w.fontselect -command "$w.fontselect.font nocmdset \[$w.fontselect get\]"
		if [catch {
			if {"$args"!=""} {eval $w.fontselect configure $args}
		} error] {
			destroy .classy__.fontselect
			error $error
		}
		pack $w.fontselect -fill both -expand yes
		update idletasks
		.classy__.fontselect configure -resize {1 1}
		tkwait window .classy__.fontselect
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

Classy::export getfont {}

