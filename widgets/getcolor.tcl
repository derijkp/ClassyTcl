#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::getcolor
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
proc Classy::getcolor {args} {
	Classy::parseopt $args opt {
		-initialcolor {} white
		-title {} "Set color"
	} remain
	if {"$remain" != ""} {
		error "unknown options \"$remain\": must be -initialcolor or -title"
	}

	array set opt $args
	if {"$opt(-initialcolor)" == ""} {
		set opt(-initialcolor) white
	}
	if {"[option get . getColor GetColor]"=="Tk"} {
		return [tk_chooseColor -initialcolor $opt(-initialcolor) -title $opt(-title)]
	}
	set ::Classy::temp $opt(-initialcolor)
	Classy::Dialog .classy__getcolor -title $opt(-title) -resize {1 1} -closecommand {
		set ::Classy::temp ""
		destroy .classy__getcolor
	}
	.classy__getcolor add go "Select" {
		set ::Classy::temp [.classy__getcolor.options.select get]
	} default
	Classy::ColorSelect .classy__getcolor.options.select
	.classy__getcolor.options.select set $opt(-initialcolor)
	pack .classy__getcolor.options.select -fill both -expand yes
	.classy__getcolor place
	tkwait window .classy__getcolor
	if {"$::Classy::temp"==""} {
		return -code return ""
	} else {
		return $::Classy::temp
	}
}


