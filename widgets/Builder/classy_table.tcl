#
# Classy::Table
#

proc ::Classy::WindowBuilder::add_Classy::Table {object base args} {
	private $object data
	Classy::Table $base -rows 5 -cols 4 \
		-getcommand {invoke {object w x y} {get ::table($x,$y) ""}} \
		-setcommand {invoke {object w x y v} {set ::table($x,$y) $v}} \
		-xlabelcommand {invoke {o w col} {return $col}} \
		-ylabelcommand {invoke {o w row} {return $row}}
	eval $base configure $args
	return $base
}

proc ::Classy::WindowBuilder::start_Classy::Table {object base} {
	private $object data bindtags
	set bindtags($base) [bindtags $base]
	bindtags $base $data(tags)
	$object _recursestartedit $base [winfo children $base]
	$base _redraw
}

proc ::Classy::WindowBuilder::edit_Classy::Table {object w} {
	::Classy::WindowBuilder::defattredit $object $w {
		-rows Rows 0 -cols Columns 0
		-getcommand "Get command" 1 -setcommand "Set command" 1
		-xlabelcommand "xlabelcommand" 1 -ylabelcommand "ylabelcommand" 1
	} 12 0
}

