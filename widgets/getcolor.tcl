#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::getcolor
# ----------------------------------------------------------------------
#doc getcolor title {
#getcolor
#} index {
# Dialogs
#} shortdescr {
# select a color
#getcolor
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::getcolor {} {}
proc getcolor {} {}
}

#doc {getcolor getcolor} cmd {
#getcolor ?option value ...?
#} index {
# Dialogs
#} shortdescr {
# returns a color selected by the user
#} descr {
# returns a color selected by the user. The selectmethod depends om the
# ClassyTcl configuration. Possible options are
#<dl>
#<dt>-initialcolor
#<dt>-title
#</dl>
#}
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
	Classy::Dialog .classy__.getcolor -title $opt(-title) -resize {1 1} -closecommand {
		set ::Classy::temp ""
		destroy .classy__.getcolor
	}
	.classy__.getcolor add go "Select" {
		set ::Classy::temp [.classy__.getcolor.options.select get]
	} default
	Classy::ColorSelect .classy__.getcolor.options.select
	catch {.classy__.getcolor.options.select set $opt(-initialcolor)}
	pack .classy__.getcolor.options.select -fill both -expand yes
	.classy__.getcolor place
	tkwait window .classy__.getcolor
	if {"$::Classy::temp"==""} {
		return -code return ""
	} else {
		return $::Classy::temp
	}
}
Classy::export getcolor {}


