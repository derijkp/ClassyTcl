#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::savefile
# ----------------------------------------------------------------------
#doc savefile title {
#savefile
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::savefile {} {}
proc savefile {} {}
}
#doc {savefile savefile} cmd {
#savefile ?option value ...?
#} descr {
# returns a filename to save a file to selected by the user. The selection
# method depends om the ClassyTcl configuration. Possible options are
#<dl>
#<dt>-defaultextension
#<dt>-filetypes
#<dt>-initialdir
#<dt>-initialfile
#<dt>-title
#<dt>-filter
#<dt>-default
#<dt>-transfercommand
#<dt>-help
#</dl>
#}
proc Classy::savefile {args} {
	global tcl_platform
	Classy::parseopt $args opt {
		-defaultextension {} {}
		-filetypes {} {}
		-initialdir {} {}
		-initialfile {} {}
		-title {} {Save file}
		-filter {} *
		-default {} classy__fileselect
		-transfercommand {} {}
		-help {} classy_file_save
	} remain
	if {"$remain"!=""} {
		error "Unknown options \"$remain\""
	}

	if {("$tcl_platform(platform)"=="windows")&&("[option get . saveFile SaveFile]"=="Win")} {
		return [lindex [Classy::GetSaveFile -defaultextension $opt(-defaultextension) \
					-filetypes $opt(-filetypes) -initialdir $opt(-initialdir) \
					-initialfile $opt(-initialfile) -title $opt(-title)] 0]
	} else {
		catch {destroy .classy__selectfile}
		set filter $opt(-filter)
		set dir $opt(-initialdir)
		if {"$dir"==""} {
			set dir [Classy::Default get app Classy__FileSelect__curdir]
		}
		if {"$dir"==""} {
			set dir [pwd]
		}
		Classy::FileSelect .classy__selectfile -dir $dir \
			-title $opt(-title) -command {set ::Classy::selectfile [.classy__selectfile get]} \
			-filter $filter -default $opt(-default) -help $opt(-help) \
			-closecommand {set ::Classy::selectfile ""}
		if {"$remain"!=""} {eval .classy__selectfile configure $remain}
		if {"$opt(-initialfile)"!=""} {
			.classy__selectfile set $opt(-initialfile)
		}
		tkwait window .classy__selectfile
		return $::Classy::selectfile
	}
}

Classy::export savefile {}
