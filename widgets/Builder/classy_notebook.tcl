#
# Classy::NoteBook
#

proc ::Classy::WindowBuilder::add_Classy::NoteBook {object base args} {
	Classy::NoteBook $base
	if {"$args" != ""} {eval $base configure $args}
	frame $base.f1 -width 10 -height 10
	update idletasks
	raise $base.f1
	$base manage label $base.f1 -sticky nwse
	$base select label
	return $base
}

proc ::Classy::WindowBuilder::start_Classy::NoteBook {object base} {
	private $object data bindtags
	set bindtags($base) [bindtags $base]
	foreach w [list $base $base.label $base.book $base.cover_] {
		bindtags $w Classy::WindowBuilder_$object
	}
	bindtags $base [list Classy::WindowBuilder_$object ::Classy::NoteBook]
	foreach label [$base labels] {
		set b [$base window $label]
		$object protected $b set delete
		bindtags $b Classy::WindowBuilder_$object
		set b "$base.tab[getprivate $base button($label)]"
		set data(class,$b) Classy::NoteBookButton
		bindtags $b Classy::WindowBuilder_$object
	}
}

proc ::Classy::WindowBuilder::attr_Classy::NoteBook_initialselection {object w args} {
	if {"$args" == ""} {
		return [$w get]
	} else {
		$w set [lindex $args 0]
	}
}

proc ::Classy::WindowBuilder::edit_Classy::NoteBook {object w} {
	private $object current
	frame $w.general
	set base $current(w)
	::Classy::WindowBuilder::defattredit $object $w.general {
		-label Label 0 initialselection "Initial selection" 0
	} 10
	catch {destroy .classy__.temp}
	button $w.add -text "Add Tab" -command [varsubst {object w base} {
			::Classy::InputBox .classy__.temp -title "Tab name" -label "Tab name" \
			-command "::Classy::WindowBuilder::edit_Classy::NoteBook_add $object $w $base \[.classy__.temp get\]"
		}]
	grid $w.general -sticky we -columnspan 2
	grid $w.add -sticky we
	grid columnconfigure $w 0 -weight 0
	grid columnconfigure $w 1 -weight 1
	grid rowconfigure $w 100 -weight 1
}

proc ::Classy::WindowBuilder::delete_Classy::NoteBook {object base} {
	private $object current data
	foreach name [array names data pr,$base.tab*] {
		unset data($name)
	}
	foreach name [array names data class,$base.tab*] {
		unset data($name)
	}
}

proc ::Classy::WindowBuilder::generate_Classy::NoteBook {object base} {
	private $object current data
	set outw [$object outw $base]
	set body ""
	append body "\tClassy::NoteBook $outw [$object getoptions $base]\n"
	append body [$object generatebindings $base $outw]
	append body "\t[$object gridwconf $base]"
	append body "\n"
	foreach b [$base labels] {
		set w [$base window $b]
		append body [$object generate $w]
		catch {append body "\t$outw add [[$base button $b] cget -text] $w\n"}
	}
	append body "\t$outw select [$base get]\n"
	return $body
}

#
# Classy::NoteBookButton
#

proc ::Classy::WindowBuilder::edit_Classy::NoteBookButton {object w} {
	private $object current
	$current(w) invoke
	frame $w.general
	button $w.delete
	::Classy::WindowBuilder::defattredit $object $w {
		-text Text 0 -command Command 1
	} 8 1
}

proc ::Classy::WindowBuilder::edit_Classy::NoteBook_add {object w base name} {
	private $object data
	set list ""
	foreach b [winfo children $base] {
		if [regexp "^$object.tab\[0-9\]+\$" $b] {lappend list $b}
	}
	set num 1
	while {[winfo exists $base.f$num]} {incr num}
	set new $base.f$num
	frame $new
	$object startedit $new
	$base manage $name $new -sticky nwse
	raise $new
	foreach label [$base labels] {
		set b [$base window $label]
		catch {unset data(redir,$b)}
		$object protected $b set delete
		bindtags $b Classy::WindowBuilder_$object
		set b $base.tab[getprivate $base button($label)]	
		catch {unset data(redir,$b)}
		set data(class,$b) Classy::NoteBookButton
		bindtags $b Classy::WindowBuilder_$object
	}
}

proc ::Classy::WindowBuilder::delete_Classy::NoteBookButton {object w} {
	[winfo parent $w] delete [lindex [$w cget -command] 2]
}
