#
# Classy::TreeWidget
#

proc ::Classy::WindowBuilder::add_Classy::TreeWidget {object base args} {
	private $object data
	Classy::TreeWidget $base -width 10 -height 10
	eval $base configure $args
	$base addnode {} tree -text Tree
}

proc ::Classy::WindowBuilder::start_Classy::TreeWidget {object base} {
	private $object data
	bindtags $base Classy::WindowBuilder_$object
	$object _recursestartedit $base [winfo children $base]
}

proc ::Classy::WindowBuilder::edit_Classy::TreeWidget {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-closecommand closecommand 1 -opencommand opencommand 1
		-endnodecommand endnodecommand 1
	} 12
}

#proc ::Classy::WindowBuilder::generate_Classy::TreeWidget {object base} {
#	private $object current data
#	set outw [$object outw $base]
#	set body ""
#	append body "\tClassy::TreeWidget $outw [$object getoptions $base]\n"
#	append body [$object generatebindings $base $outw]
#	append body "\t[$object gridwconf $base]\n"
#	append body "\t[$object generate [winfo children $base.view.frame]]"
#	return $body
#}
