#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::savefile
# ----------------------------------------------------------------------
#doc savefile title {
#savefile
#} index {
# Dialogs
#} shortdescr {
# select a file name to save a file to
#}
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
#<dt>-combo
#<dt>-combopreset
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
		-default {} {}
		-combo {} 20
		-combopreset {} {}
		-transfercommand {} {}
		-help {} classy_file_save
	} remain
	if {"$remain"!=""} {
		error "Unknown options \"$remain\""
	}

	set filter $opt(-filter)
	if {"$filter"==""} {
		set dir [::Classy::Default get app Classy__FileSelect__curfilter]
	}
	if {"$filter"==""} {
		set filter *
	}
	set dir $opt(-initialdir)
	if {"$dir"==""} {
		set dir [::Classy::Default get app Classy__FileSelect__curdir]
	}
	if {"$dir"==""} {
		set dir [pwd]
	}
	if {("$tcl_platform(platform)"=="windows")&&("[option get . saveFile SaveFile]"=="Win")} {
		if {"$opt(-initialfile)"==""} {
			set opt(-initialfile) $opt(-initialdir)
		}		
		return [lindex [Classy::GetSaveFile -defaultextension $opt(-defaultextension) \
					-filetypes $opt(-filetypes) -initialdir $dir \
					-initialfile $opt(-initialfile) -title $opt(-title)] 0]
	} else {
		catch {destroy .classy__.selectfile}
		Classy::FileSelect .classy__.selectfile -dir $dir \
			-title $opt(-title) -command {set ::Classy::selectfile} \
			-filter $filter -help $opt(-help) \
			-default $opt(-default) -combo $opt(-combo) -combopreset $opt(-combopreset) \
			-closecommand {set ::Classy::selectfile ""}
		if {"$remain"!=""} {eval .classy__.selectfile configure $remain}
		if {"$opt(-initialfile)"!=""} {
			.classy__.selectfile set $opt(-initialfile)
		}
		tkwait window .classy__.selectfile
		return $::Classy::selectfile
	}
}


