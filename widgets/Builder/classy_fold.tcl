#
# Classy::Fold
#

proc ::Classy::WindowBuilder::add_Classy::Fold {object base args} {
	private $object data
	Classy::Fold $base -title Fold
	eval $base configure $args
}

proc ::Classy::WindowBuilder::start_Classy::Fold {object base} {
	private $object data
	bindtags $base Classy::WindowBuilder_$object
	foreach w {title spacer} {
		bindtags $base.$w Classy::WindowBuilder_$object
		set data(redir,$base.$w) $base
	}
	$object startedit $base.content
	$object protected $base.content set delete
}

proc ::Classy::WindowBuilder::edit_Classy::Fold {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-relief Relief 0 -borderwidth "Border width" 0 -opencommand opencommand 1
	} 8 0
}

proc ::Classy::WindowBuilder::generate_Classy::Fold {object base} {
	private $object current data
	set outw [$object outw $base]
	set body ""
	append body "\tClassy::Fold $outw [$object getoptions $base]\n"
	append body [$object generatebindings $base $outw]
	append body "\t[$object gridwconf $base]\n"
	append body "\t[$object generate [winfo children $base.content]]"
	return $body
}

