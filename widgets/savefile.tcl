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
		-default {} peos__fileselect
		-transfercommand {} {}
		-help {} peos_file_save.html
	} remain
	if {"$remain"!=""} {
		error "Unknown options \"$remain\""
	}

	if {("$tcl_platform(platform)"=="windows")&&("[option get . saveFile SaveFile]"=="Win")} {
		return [lindex [Classy::GetSaveFile -defaultextension $opt(-defaultextension) \
					-filetypes $opt(-filetypes) -initialdir $opt(-initialdir) \
					-initialfile $opt(-initialfile) -title $opt(-title)] 0]
	} else {
		global peos__selectfile
		catch {destroy .peos__selectfile}
		set filter $opt(-filter)
		set dir $opt(-initialdir)
		if {"$dir"==""} {
			set dir [Classy::Default get app Classy__FileSelect__curdir]
		}
		if {"$dir"==""} {
			set dir [pwd]
		}
		Classy::FileSelect .peos__selectfile -dir $dir \
			-title $opt(-title) -command {set peos__selectfile [.peos__selectfile get]} \
			-filter $filter -default $opt(-default) -help $opt(-help)
		if {"$remain"!=""} {eval .peos__selectfile configure $remain}
		if {"$opt(-initialfile)"!=""} {
			.peos__selectfile set $opt(-initialfile)
		}
		tkwait window .peos__selectfile
		return $peos__selectfile
	}
}

Classy::export savefile {}
