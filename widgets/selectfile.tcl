#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::selectfile
# ----------------------------------------------------------------------
#doc selectfile title {
#selectfile
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::selectfile {} {}
proc selectfile {} {}
}
#doc {selectfile selectfile} cmd {
#selectfile ?option value ...?
#} descr {
# returns a filename selected by the user. The selection
# method depends om the ClassyTcl configuration. Possible options are
#<dl>
#<dt>-defaultextension
#<dt>-filetypes
#<dt>-initialdir
#<dt>-initialfile
#<dt>-title
#<dt>-filter
#<dt>-selectmode<dd>single, browse, multiple, extended or persistent
#<dt>-default
#<dt>-help
#</dl>
#}
proc Classy::selectfile {args} {
	global tcl_platform
	Classy::parseopt $args opt {
		-defaultextension {} {}
		-filetypes {} {}
		-initialdir {} {}
		-initialfile {} {}
		-title {} {Select file}
		-filter {} {}
		-selectmode {single browse multiple extended persistent} browse
		-default {} Classy__fileselect
		-help {} Classy_file_select
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
	if {("$tcl_platform(platform)"=="windows")&&("[option get . selectFile SelectFile]"=="Win")} {
		if {"$opt(-selectmode)"=="single"} {
			set opt(-selectmode) browse
		}
		if {"$opt(-initialfile)"==""} {
			set opt(-initialfile) $opt(-initialdir)
		}		
		set result [Classy::GetOpenFile -defaultextension $opt(-defaultextension) \
			-filetypes $opt(-filetypes) -initialdir $dir \
			-initialfile $opt(-initialfile) -title $opt(-title) \
			-selectmode $opt(-selectmode)]
		if {"$opt(-selectmode)"=="browse"} {
			return [lindex $result 0]
		} elseif {[llength $result]<2} {
			Classy::Default set app Classy__FileSelect__curdir [list [file dirname $result]]
			return $result
		} else {
			set dir [lshift result]
			Classy::Default set app Classy__FileSelect__curdir [list $dir]
			set temp ""
			foreach file $result {
				lappend temp [file join $dir $file]
			}
			return $temp
		}
	} else {
		catch {destroy .classy__.selectfile}
		Classy::FileSelect .classy__.selectfile -dir $dir \
			-title $opt(-title) -textvariable ::Classy::selectfile \
			-filter $filter -default $opt(-default) -selectmode $opt(-selectmode) -help $opt(-help) \
			-closecommand {set ::Classy::selectfile ""}
		if {"$opt(-initialfile)" != ""} {
			.classy__.selectfile set $opt(-initialfile)
		}
		tkwait window .classy__.selectfile
		return $::Classy::selectfile
	}
}
Classy::export selectfile {}
