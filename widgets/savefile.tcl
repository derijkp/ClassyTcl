#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::savefile
# ----------------------------------------------------------------------

proc Classy::savefile {args} {
	global tcl_platform
	Classy::parseopt $args opt {
		-defaultextension {} {}
		-filetypes {} {}
		-initialdir {} {}
		-initialfile {} {}
		-title {} {Select file}
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
