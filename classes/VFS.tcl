# *************************************************
#
# Class
# ----- Peter De Rijk
#
# VFS
# ----------------------------------------------------------------------
#doc VFS title {
#VFS
#} index {
# Classes
#} shortdescr {
# Virtual filing system
#} descr {
#}
#doc {VFS command} h2 {
#	VFS specific methods
#} descr {
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::class::VFS {} {}
proc VFS {} {}
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Class subclass class::VFS
class::export VFS {}

class::VFS method init {args} {
	super init
	private $object cpwd
	set cpwd [pwd]
}


#doc {Tree command destroy} cmd {
#pathname destroy 
#} descr {
#}
class::VFS method destroy {} {
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------


#doc {VFS command glob} cmd {
#pathname glob pattern
#} descr {
# returns a list of files in the current directory
#}
class::VFS method glob {pattern} {
	private $object cpwd
	set pwd [pwd]
	cd $cpwd
	return [glob -nocomplain $pattern]
	cd $pwd
}

class::VFS method cd {dir} {
	private $object cpwd
	set cpwd $dir
}

class::VFS method pwd {} {
	private $object cpwd
	return $cpwd
}
