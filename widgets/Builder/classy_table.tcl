#
# Classy::Table
#

proc ::Classy::WindowBuilder::add_Classy::Table {object base args} {
	private $object data
	Classy::Table $base -rows 10 -cols 4 -getcommand {get table(%x,%y)} \
		-setcommand {set table(%x,%y) %v} -xlabelcommand {echo %x}  -ylabelcommand {echo %y}
	eval $base configure $args
	return $base
}

proc ::Classy::WindowBuilder::start_Classy::Table {object base} {
	private $object data bindtags
	set bindtags($base) [bindtags $base]
	bindtags $base $data(tags)
	$object _recursestartedit $base [winfo children $base]
	$base redraw
}

proc ::Classy::WindowBuilder::edit_Classy::Table {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-rows Rows 0 -cols Columns 0
		-getcommand "Get command" 1 -setcommand "Set command" 1
		-xlabelcommand "xlabelcommand" 1 -ylabelcommand "ylabelcommand" 1
	} 12 0
}
