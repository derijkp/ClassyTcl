#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Editor
# ----------------------------------------------------------------------
#doc Editor title {
#Editor
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# The Editor widget provides a fairly complete editor with undo redo
# search, menus and toolbar, invoke Tcl commands, macros, etc. ...
#}
#doc {Editor options} h2 {
#	Editor specific options
#}
#doc {Editor command} h2 {
#	Editor specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::Editor {} {}
proc Editor {} {}
}
catch {Classy::Editor destroy}

option add *Classy:Editor.KeySearchReopen Control-Alt-r widgetDefault
option add *Classy::Editor.KeyMatchingBrackets "Alt-bracketleft" widgetDefault
option add *Classy::Editor.KeyIndentCr Control-j widgetDefault
option add *Classy::Editor.KeyComment "Alt-numbersign" widgetDefault
option add *Classy::Editor.KeyDelComment "Control-Alt-numbersign" widgetDefault
bind Classy::Editor <FocusIn> {focus %W.edit}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Editor
Classy::export Editor {}

Classy::Editor classmethod init {args} {
	super
	set w [::Classy::widget $object]
	$w configure -highlightthickness 0 -borderwidth 0
	Classy::Text $object.edit -wrap none -tabs 24 -yscrollcommand [list $object.vbar set] \
		-xscrollcommand [list $object.hbar set] -changedcommand [varsubst object {
			set top [winfo toplevel $object]
			if ![regexp {\*$} [wm title $top]] {catch [wm title $top "[wm title $top] *"]}
		}]
	bindtags $object.edit "$object Classy::Text $object.edit all"
	scrollbar $object.vbar -orient vertical -command "$object.edit yview"
	scrollbar $object.hbar -orient horizontal -command "$object.edit xview"

	set menu .classy__editormenu
	Classy::DynaMenu makemenu Classy::Editor .classy__editormenu $object Classy::EditorMenu
	# replace default cmdw commands to make Editor cmdw instead of Editor.edit
	bind $object <FocusIn> "Classy::DynaMenu cmdw .classy__editormenu $object"
	bind $object <Enter> "Classy::DynaMenu cmdw .classy__editormenu $object"
	if {[option get $object showTool ShowTool]} {
		Classy::DynaTool maketool Classy::Editor $object.tool $object
		grid $object.tool - -sticky we
		grid rowconfigure $object 1 -weight 1
	} else {
		grid rowconfigure $object 0 -weight 1
	}
	if {"[option get $object scrollSide ScrollSide]"=="left"} {
		grid $object.vbar $object.edit -sticky nswe
		grid $object.hbar -column 1 -sticky nswe
		grid columnconfigure $object 1 -weight 1
	} else {
		grid $object.edit $object.vbar -sticky nswe
		grid $object.hbar -column 0 -sticky nswe
		grid columnconfigure $object 0 -weight 1
	}

	# REM Initialise options and variables
	# ------------------------------------
	private $object curfile reopenlist findwhat replace marker curmarker prevmarker
	set curfile {}
	set reopenlist {}
	set findwhat {}
	set replace {}
	set marker Mark
	set curmarker {}
	set prevmarker {}

	# REM Create bindings
	# --------------------
	bindtags $object.edit "Classy::EditorMenu Classy::EditorMenu::macros [bindtags $object.edit]"

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::Editor chainoptions {$object.edit}

#doc {Editor options -loadcommand} option {-loadcommand loadCommand LoadCommand} descr {
#}
Classy::Editor addoption -loadcommand {loadCommand LoadCommand {}}

#doc {Editor options -icon} option {-icon icon Icon} descr {
#}
Classy::Editor addoption -icon {icon Icon blank}

#doc {Editor options -searchtype} option {-searchtype searchType SearchType} descr {
#}
Classy::Editor addoption -searchtype {searchType SearchType exact}

#doc {Editor options -searchdir} option {-searchdir searchDir SearchDir} descr {
#}
Classy::Editor addoption -searchdir {searchDir SearchDir forward}

#doc {Editor options -searchcase} option {-searchcase searchCase SearchCase} descr {
#}
Classy::Editor addoption -searchcase {searchCase SearchCase nocase}

#doc {Editor options -searchreopen} option {-searchreopen SearchReopen searchReopen} descr {
#}
Classy::Editor addoption -searchreopen {SearchReopen searchReopen 0}
Classy::Editor addoption -connection [list connection Connection [tk appname]]

#doc {Editor options -menu} option {-menu menu Menu} descr {
#}
Classy::Editor addoption -menu {menu Menu popup}

#doc {Editor options -closecommand} option {-closecommand closeCommand CloseCommand} descr {
#}
Classy::Editor addoption -closecommand {closeCommand CloseCommand {}}

# ------------------------------------------------------------------
#  destroy
# ------------------------------------------------------------------

#doc {Editor command destroy} cmd {
#pathname destroy 
#} descr {
#}
Classy::Editor method destroy {} {
	private $object curfile
	private $class editing
	set temp [::Classy::fullpath $curfile]
	if [info exists editing($temp)] {
		set editing($temp) [lremove $editing($temp) $object]
		if {"$editing($temp)"==""} {unset editing($temp)}
	}
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Editor chainallmethods {$object.edit} Classy::Text

#doc {Editor command cut} cmd {
#pathname cut 
#} descr {
#}
Classy::Editor method cut {} {
	private $object replace
	clipboard clear -displayof $object			  
	catch {									
		set replace [$object get sel.first sel.last]
		clipboard append -displayof $object $replace
		$object delete sel.first sel.last
	}
}

#doc {Editor command copy} cmd {
#pathname copy 
#} descr {
#}
Classy::Editor method copy {} {
	private $object replace
	clipboard clear -displayof $object			  
	catch {									
		set replace [$object get sel.first sel.last]
		clipboard append -displayof $object $replace
	}										  
}

#doc {Editor command connectto} cmd {
#pathname connectto 
#} descr {
#}
Classy::Editor method connectto {} {
	set w $object.connectto
	Classy::SelectDialog $w -title "Connect execution to" \
		-command "$object configure -connection \[$w get\]"
	$w fill [winfo interps]
	$w set [getprivate $object options(-connection)]
}

#doc {Editor command execute} cmd {
#pathname execute 
#} descr {
#}
Classy::Editor method execute {} {
	if {"[$object tag ranges sel]" != ""} {
		set command [$object get sel.first sel.last]
		send -- [getprivate $object options(-connection)] $command
	}
}

#doc {Editor command findfunction} cmd {
#pathname findfunction ?function?
#} descr {
#load the file containing function $function (must be auto loadable),
#and find the function definition.
#if function is not given, the current selection will be searched.
#}
Classy::Editor method findfunction {args} {
	if {"$args"!=""} {
		set function $args
	} elseif {"[$object tag ranges sel]"!=""} {
		set function [$object get sel.first sel.last]
	} else {
		ClassyInputBox $object.findfunction -command "$object findfunction \[$object.findfunction get\]"
		return
	}
	set index [send -- [getprivate $object options(-connection)] setglobal auto_index($function)]
	$object load [lindex $index 1]
	$object find "proc $function"
}

#doc {Editor command save} cmd {
#pathname save 
#} descr {
#}
Classy::Editor method save {} {
	private $object curfile
	set temp [$object get 1.0 "end-1c"]
	set f [open $curfile w]
	puts -nonewline $f $temp
	close $f
	$object textchanged 0
	catch {wm title [winfo toplevel $object] "$curfile"}
	foreach w [$object.edit link] {
		catch {wm title [winfo toplevel $w] "$curfile"}
	}
}

#doc {Editor command saveas} cmd {
#pathname saveas file
#} descr {
#}
Classy::Editor method saveas {file} {
	if ![Classyoverwriteyn $file 0] return
	private $object curfile reopenlist
	$object unlink
	set curfile $file
	lappend reopenlist $file
	$object save
	$object textchanged 0
	catch {wm title [winfo toplevel $object] "$curfile"}
}

#doc {Editor command savebox} cmd {
#pathname savebox 
#} descr {
#}
Classy::Editor method savebox {} {
	private $object curfile
	$object saveas [Classysavefile -title "Save as" \
		-transfercommand "$object transfercommand" -initialfile $curfile]
}

#doc {Editor command transfercommand} cmd {
#pathname transfercommand 
#} descr {
#}
Classy::Editor method transfercommand {} {
	set type [string trimleft [file extension [$object.savebox get]] "."]
	return [varsubst {type object} {$type {$object get 1.0 end}}]
}

#doc {Editor command loadnext} cmd {
#pathname loadnext 
#} descr {
#}
Classy::Editor method loadnext {} {
	private $object curfile reopenlist
	set pos [lsearch $reopenlist $curfile]
	incr pos
	if {$pos==[llength $reopenlist]} {set pos 0}
	set file [lindex $reopenlist $pos]
	$object load $file
}

#doc {Editor command loadprev} cmd {
#pathname loadprev 
#} descr {
#}
Classy::Editor method loadprev {} {
	private $object curfile reopenlist
	set pos [lsearch $reopenlist $curfile]
	if {$pos==0} {set pos [llength $reopenlist]}
	incr pos -1
	set file [lindex $reopenlist $pos]
	$object load $file
}

#doc {Editor command close} cmd {
#pathname close 
#} descr {
#}
Classy::Editor method close {} {
	if [true [$object closefile]] {
		eval [getprivate $object options(-closecommand)]
	}
}

#doc {Editor command closefile} cmd {
#pathname closefile 
#} descr {
#}
Classy::Editor method closefile {} {
	private $object curfile curmarkers curmarker prevmarker cur
	private $class editing
	if [true [$object textchanged]] {
		set temp [Classy::yorn "File not saved!\nSave file first?" -close yes]
		switch $temp {
			1 {$object save}
			close {return false}
		}
	}
	set cur(pos,$curfile) [$object index insert]
	set cur(curmarker,$curfile) $curmarker
	set cur(prevmarker,$curfile) $prevmarker
	set curmarkers($curfile) [$object marker lget]
	if {"$curmarkers($curfile)" == ""} {unset curmarkers($curfile)}
	[::Classy::widget $object.edit] delete 1.0 end
	$object.edit unlink
	set temp [::Classy::fullpath $curfile]
	if [info exists editing($temp)] {
		set editing($temp) [lremove $editing($temp) $object]
		if {"$editing($temp)"==""} {unset editing($temp)}
	}
	return true
}

#doc {Editor command load} cmd {
#pathname load ?filename? ?filename ...?
#} descr {
#}
Classy::Editor method load {{file {}} args} {
	if {"$file"==""} return
	private $object curfile curmarkers curmarker prevmarker reopenlist cur
	private $class editing
	if {"[$object closefile]" != "true"} {return}
	set curfile $file
	::Classy::busy add $object
	if [info exists editing([::Classy::fullpath $curfile])] {
		set w [lindex $editing([::Classy::fullpath $curfile]) 0]
		$object.edit link $w.edit
	} elseif [file exists $file] {
		if [file isdir $file] {
			error "Cannot open directory \"$file\""
		}
		set f [open $file r]
		[::Classy::widget $object.edit] insert end [read $f]
		close $f
		$object clearundo
		$object textchanged 0
	}

	if [info exists cur(pos,$curfile)] {
		$object mark set insert $cur(pos,$curfile)
		$object see insert
	} else {
		$object mark set insert 1.0
		$object see insert
	}
	if [info exists curmarkers($curfile)] {
		eval $object marker lset $curmarkers($curfile)
	}
	if [info exists cur(curmarker,$curfile)] {
		set curmarker $cur(curmarker,$curfile)
	}
	if [info exists cur(prevmarker,$curfile)] {
		set prevmarker $cur(prevmarker,$curfile)
	}
	laddnew reopenlist $file
	if {"$args" != ""} {
		eval lappend reopenlist $args 
	}
	set reopenlist [lmanip remdup $reopenlist]
	set loadcommand [getprivate $object options(-loadcommand)]
	if {"$loadcommand" != ""} {
		 eval $loadcommand [list $file]
	}
	lappend editing([::Classy::fullpath $curfile]) $object
#	if [$object textchanged] {$object _changed}
	::Classy::busy remove $object
	return $file
}

#doc {Editor command set} cmd {
#pathname set data
#} descr {
#}
Classy::Editor method set {data} {
	private $object curfile curmarkers curmarker prevmarker
	private $object reopenlist cur

	if {"[$object closefile]" != "true"} {return}
	set curfile ""
	$object insert 0.0 $data
	$object clearundo
	$object textchanged 0
}

#doc {Editor command forget} cmd {
#pathname forget filename ?filename ...?
#} descr {
#}
Classy::Editor method forget {args} {
	private $object reopenlist
	set reopenlist [llremove $reopenlist $args]
}

#doc {Editor command reopenlist} cmd {
#pathname reopenlist 
#} descr {
#}
Classy::Editor method reopenlist {} {
	private $object curfile reopenlist

	set w $object.reopenlist
	destroy $w
	Classy::SelectDialog $w -title "Reopen list" \
		-command "$object load \[$w get\]" \
		-deletecommand "$object forget \[$w get\]"
	$w fill $reopenlist
	$w set $curfile
}

#doc {Editor command findsel} cmd {
#pathname findsel direction
#} descr {
# direction can be -forwards or -backwards
#}
Classy::Editor method findsel {dir} {
	private $object findwhat
	if {"[$object tag ranges sel]" != ""} {
		if {"$dir" == "-forwards"} {set index sel.last} else {set index sel.first}
		set findwhat [$object get sel.first sel.last]
	}
	$object find $findwhat $dir -exact
}

Classy::Editor method replace-find {dir} {
	private $object findwhat replace
	if {"[$object tag ranges sel]"==""} {
		if {"$dir" == "-forwards"} {set index sel.last} else {set index sel.first}
		set findwhat [$object get sel.first sel.last]
	}
	eval $object delete sel.first sel.last
	$object insert insert $replace
	$object find $findwhat $dir -exact
}

#doc {Editor command find} cmd {
#pathname find what ?option? ?value? ?option value?
#} descr {
#}
Classy::Editor method find {what args} {
	private $object options
	if ![regexp -- {-case|-nocase} $args] {
		lappend args -$options(-searchcase)
	}
	regsub -- {-case} $args {} args
	if ![regexp -- {-exact|-regexp} $args] {
		lappend args -$options(-searchtype)
	}

	set stopindex {}
	if [regexp -- {-backwards} $args] {
		set nextcmd "$object loadprev"
		set index "insert"
		set startindex end
		set stopindex 1.0
	} else {
		set nextcmd "$object loadnext"
		set index "insert+1c"
		set startindex 1.0
		set stopindex end
	}
	set ::Classy::number 0
	if $options(-searchreopen) {
		private $object curfile
		set startfile $curfile
		set startpos [$object index $index]
		if [$object compare $startpos != $stopindex] {
			set pos [eval {$object search -count number} $args -- {$what} $index $stopindex]
		} else {
			set pos ""
		}
		while {"$pos" == ""} {
			eval $nextcmd
			if {"$curfile" != "$startfile"} {
				set pos [eval {$object search -count number} $args -- {$what} $startindex $stopindex]
			} else {
				set pos [eval {$object search -count number} $args -- {$what} $startindex $startpos]
				break
			}
		}
		catch {unset startfile}
		catch {unset startpos}
	} else {
		set pos [eval {$object search -count ::Classy::number} $args -- {$what} $index]
	}
	if {"$pos" == ""} {error "Not found"}
	$object mark set insert $pos
	catch {$object tag remove sel sel.first sel.last}
	$object tag add sel insert "insert + $::Classy::number c"
	$object see insert
}

#doc {Editor command gotoline} cmd {
#pathname gotoline line
#} descr {
#}
Classy::Editor method gotoline {line} {
	$object mark set insert $line.0
	catch {$object tag remove sel sel.first sel.last}
	$object see insert
}

#doc {Editor command command} cmd {
#pathname command command
#} descr {
#}
Classy::Editor method command {command} {
	eval $command
}

#doc {Editor command replace} cmd {
#pathname replace ?all?
#} descr {
#}
Classy::Editor method replace {args} {
	private $object options replace findwhat
	if {"$args" == "all"} {
		set start [$object index insert]
		if {"$options(-searchdir)"=="forwards"} {
			set stop end
		} else {
			set stop 1.0
		}
		while 1 {
			set pos [eval {$object search -count number} -$options(-searchdir) -$options(-searchtype) -$options(-searchcase) \
				-- {$findwhat} $start $stop]
			if {"$pos"==""} {break}
			$object delete $pos "$pos + $number c"
			$object insert $pos $replace
			set start [$object index "$pos + [string length $replace] c"]
		}
		$object mark set insert $start
	} else { 
		set sel ""
		catch {set sel [$object get sel.first sel.last]}
		$object delete sel.first sel.last
		$object insert insert $replace
		$object find $findwhat -$options(-searchdir)
	}
}

#doc {Editor command finddialog} cmd {
#pathname finddialog 
#} descr {
#}
Classy::Editor method finddialog {} {
	private $object options
	set options(-searchdir) forwards
	set w $object.find
	if ![winfo exists $w] {
		Classy::Dialog $w -cache 1
		wm title $w Find
		set what "\[$w.options.find get\] "
		$w add find Find "$object find $what -\[set [privatevar $object options(-searchdir)]\]" default
		$w add repl Replace "$object replace"
		$w add replall "Replace all" "$object replace all"
	
		Classy::Entry $w.options.find -label Find -textvariable [privatevar $object findwhat]
		Classy::Entry $w.options.replace -label Replace -textvariable [privatevar $object replace]
		frame $w.options.frame
		Classy::OptionBox $w.options.type -label "Type" -orient vertical -variable [privatevar $object options(-searchtype)]
		$w.options.type add exact Exact
		$w.options.type add regexp Regexp
		Classy::OptionBox $w.options.case -label "Case" -orient vertical -variable [privatevar $object options(-searchcase)]
		$w.options.case add nocase "No case"
		$w.options.case add case "Case sensitive"
		Classy::OptionBox $w.options.dir -label "Direction" -orient horizontal -variable [privatevar $object options(-searchdir)]
		$w.options.dir add forwards "Forward"
		$w.options.dir add backwards "Backwards"
		checkbutton $w.options.searchreopen -text "Search Reopen" -variable [privatevar $object options(-searchreopen)]
		pack $w.options.find -fill x
		pack $w.options.replace -fill x
		pack $w.options.frame -fill x
		pack $w.options.searchreopen -in $w.options.frame -side bottom -fill x -expand yes
		pack $w.options.dir -in $w.options.frame -side bottom -fill x -expand yes
		pack $w.options.type -in $w.options.frame -side left -fill x -expand yes
		pack $w.options.case -in $w.options.frame -side left -fill x -expand yes
	} else {
		$w place
		focus $w.options.find.entry
		$w.options.find.entry select range 0 end
	}
	focus $w.options.find.entry
	$w.options.find.entry select range 0 end
}

#doc {Editor command indentedcr} cmd {
#pathname indentedcr 
#} descr {
#}
Classy::Editor method indentedcr {} {
	set line [$object get "insert linestart" "insert lineend"]
	$object insert insert "\n"
	if [regexp "(^\[ \t\]+)" $line prefix] {
		$object insert insert $prefix
	}
}

#doc {Editor command indent} cmd {
#pathname indent number
#} descr {
#}
Classy::Editor method indent {number} {
	if {[$object tag ranges sel] == ""} return
	regexp {^([0-9]+)\.} [$object index sel.first] temp begin
	regexp {^([0-9]+)\.} [$object index sel.last] temp end
	if {$number>=0} {
		set insert ""
		for {set i 0} {$i<$number} {incr i} {
			append insert "\t"
		}
		for {set i $begin} {$i<$end} {incr i} {
			$object insert $i.0 $insert
		}
	} else {
		set number [expr -$number]
		for {set i $begin} {$i<$end} {incr i} {
			set temp [$object get $i.0 $i.$number]
			if [regexp "^\[\t \]*$" $temp] {
				$object delete $i.0 $i.$number
			}
		}
	}
}

#doc {Editor command macro} cmd {
#pathname macro 
#} descr {
#}
Classy::Editor method macro {} {
	set obj $object
	Classy::Dialog $object.macro -title "Make macro" -closecommand [varsubst object {
		::class::untraceobject $object
		::class::untraceobject $object.edit
		catch {unset [privatevar $object macro]}
		destroy $object.macro
	}] -resize {1 1}
	set record [$object.macro add record Record {}]
	set stop [$object.macro add stop "Stop" {}]
	$record configure -command [varsubst {stop record object} {
		set [privatevar $object macro] ""
		$object.macro.options.text delete 1.0 end
		$record configure -text "Recording ..." -state disabled
		$stop configure -state normal
		focus $object
		::class::traceobject $object [list append [privatevar $object macro]] 1
		::class::traceobject $object.edit [list append [privatevar $object macro]] 1
	}]
	$stop configure -command [varsubst {stop record object} {
		$record configure -text "Record" -state normal
		$stop configure -state disabled
		::class::untraceobject $object
		::class::untraceobject $object.edit
		$object.macro.options.text insert end [set [privatevar $object macro]]
		catch {unset [privatevar $object macro]}
	}]
	$stop configure -state disabled
	$object.macro add set Set [concat $object setmacro "\[$object.macro.options.name get\]" \
		"\[$object.macro.options.text get 1.0 end\]" \
		"\[$object.macro.options.key get\]"]
	$object.macro add delete Delete [concat $object deletemacro "\[$object.macro.options.name get\]"]
	$object.macro add exec Execute [varsubst {} {
		set object $object
		eval [$object.macro.options.text get 1.0 end]
	}]
	$object.macro add get Get "$object getmacro"
	set key [privatevar $object macrokey]
	$object.macro add save "Save now" {Classy::Default save}
	# Options
	#--------
	private $object macrokey macroname
	Classy::Entry $object.macro.options.name -label "Name" -default Classy::Editor_macros \
		-textvariable [privatevar $object macroname] -command [varsubst object {
			$object.macro invoke get
#			set key [Classy::Default get Classy__EditorMacro [$object.macro.options.name get]]
#			if {"$key"!=""} {$object.macro.options.key set $key}
		}]
	Classy::Entry $object.macro.options.key -textvariable [privatevar $object macrokey] -label "Key-code"
	scrollbar $object.macro.options.scroll -command "$object.macro.options.text yview"
	Classy::Text $object.macro.options.text -yscrollcommand "$object.macro.options.scroll set" -width 20 -height 10

	if {"$macrokey"==""} {set macrokey F5}
	if {"$macroname"==""} {set macroname $macrokey}
	pack $object.macro.options.key -side bottom -fill x
	pack $object.macro.options.name -side bottom -fill x
	pack $object.macro.options.scroll -fill y -side right
	pack $object.macro.options.text -fill both -expand yes
	$object getmacro
}

#doc {Editor command setmacro} cmd {
#pathname setmacro
#} descr {
#}
Classy::Editor method setmacro {name command {key {}}} {
	if {"$name"==""} {
		tkerror "No name selected"
		return
	}
	set macros [Classy::Default get app Classy::Editor_macros]
	laddnew macros $name
	Classy::Default set app Classy::Editor_macros $macros
	Classy::Default set app Classy::Editor_macro_$name [list $command $key]
	eval [.classy__editormenu.macros cget -postcommand]
}

#doc {Editor command deletemacro} cmd {
#pathname deletemacro
#} descr {
#}
Classy::Editor method deletemacro {name} {
	if {"$name"==""} {
		tkerror "No name selected"
		return
	}
	Classy::Default unset app Classy::Editor_macro_$name
	eval [.classy__editormenu.macros cget -postcommand]
}

#doc {Editor command getmacromenu} cmd {
#pathname macromenu 
#} descr {
#}
Classy::Editor method getmacromenu {} {
	set data {action Macro "Manage Macros" "%W macro"}
	append data "\n"
	set names ""
	foreach m [Classy::Default names app Classy::Editor_macro_*] {
		regexp {^Classy::Editor_macro_(.*)$} $m temp name
		set temp [Classy::Default get app Classy::Editor_macro_$name]
		set key [lindex $temp 1]
		append data "action [list Macro$name] \"$name\" \{[list %W runmacro $name]\}"
		if {"$key" == ""} {
			append data "\n"
		} else {
			append data " $key\n"
		}
		lappend names $name
	}
	Classy::Default set app Classy::Editor_macros $names
	return $data
}

#doc {Editor command getmacro} cmd {
#pathname getmacro 
#} descr {
#}
Classy::Editor method getmacro {} {
	set name [$object.macro.options.name get]
	set temp [Classy::Default get app Classy::Editor_macro_$name]
	$object.macro.options.text delete 1.0 end
	$object.macro.options.text insert end [lindex $temp 0]
	$object.macro.options.key set [lindex $temp 1]
}

#doc {Editor command runmacro} cmd {
#pathname runmacro name
#} descr {
#}
Classy::Editor method runmacro {name} {
	set temp	[Classy::Default get app Classy::Editor_macro_$name]
	eval [lindex $temp 0]
}

#doc {Editor command comment} cmd {
#pathname comment add/remove
#} descr {
#}
Classy::Editor method comment {command} {
	set w $object
	switch $command {
		add {
			if {[$w tag ranges sel] == ""} {
				$w insert "insert linestart" "#"
				tkTextSetCursor $w [tkTextUpDownLine $w 1]
			} else {
				regexp {^([0-9]+)\.} [$w index sel.first] temp begin
				regexp {^([0-9]+)\.} [$w index sel.last] temp end
				for {set i $begin} {$i<$end} {incr i} {
					$w insert $i.0 "#"
				}
			}
		}
		remove {
			if {[$w tag ranges sel] == ""} {
				if {[$w get "insert linestart"] == "#"} {
					$w delete "insert linestart"
					tkTextSetCursor $w [tkTextUpDownLine $w 1]
				}
			} else {
				regexp {^([0-9]+)\.} [$w index sel.first] temp begin
				regexp {^([0-9]+)\.} [$w index sel.last] temp end
				for {set i $begin} {$i<$end} {incr i} {
					if {[$w get $i.0] == "#"} {
						$w delete $i.0
					}
				}
			}
		}
	}
}

#doc {Editor command format} cmd {
#pathname format length
#} descr {
#}
Classy::Editor method format {length} {
	set w $object
	
	set line [$w get "insert linestart" "insert lineend"]
	$w delete "insert linestart" "insert lineend"
	set line [split $line " "]
	set pos 0
	set result ""
	foreach el $line {
		set len [string length $el]
		incr pos $len
		if {$pos<$length} {
			append result $el 
			append result " "
		} else {
			append result "\n"
			append result $el
			append result " "
			set pos [expr $len+1]
		}
	}
	$w insert insert $result
}

#doc {Editor command transpose} cmd {
#pathname transpose pos
#} descr {
#}
Classy::Editor method transpose {pos} {
	if [$object compare $pos != "$pos lineend"] {
	set pos [$object index "$pos + 1 char"]
	}
	set new [$object get "$pos - 1 char"][$object get  "$pos - 2 char"]
	if [$object compare "$pos - 1 char" == 1.0] {
	return
	}
	$object delete "$pos - 2 char" $pos
	$object insert insert $new
	$object see insert
}

#doc {Editor command matchingbrackets} cmd {
#pathname matchingbrackets 
#} descr {
#}
Classy::Editor method matchingbrackets {} {
	set w $object
	set startpattern "\{|\\\(|\\\["
	set endpattern "\}|\\\)|\\\]"
	if {[$w tag ranges sel] == ""} {
		set curstart [$w index insert]
		set curend [$w index insert]
	} else {
		set curstart [$w index sel.first]
		set curend [$w index sel.last]
	}
	set num 1
	while 1 {
		set start [$w search -backwards -regexp -- "$startpattern|$endpattern" $curstart 1.0]
		if {"$start" == ""} {
			set start 1.0
			break
		}
		if [regexp $endpattern [$w get $start]] {
			set curstart $start
			incr num
		} elseif [regexp $startpattern [$w get $start]] {
			set curstart $start
			incr num -1
		}
		if {$num==0} break
	}
	set num 1
	while 1 {
		set end [$w search -forwards -regexp -- "$startpattern|$endpattern" $curend end]
		if {"$end" == ""} {
			set end end
			break
		}
		if [regexp $startpattern [$w get $end]] {
			set curend [$w index "$end +1 c"]
			incr num
		} elseif [regexp $endpattern [$w get $end]] {
			set curend [$w index "$end +1 c"]
			incr num -1
		}
		if {$num==0} break
	}
	$w tag add sel $start "$end +1 c"
}

#doc {Editor command marker} cmd {
#pathname marker command ?args?
#} descr {
#command must be one of
#<dl>
#<dt>set
#<dt>delete
#<dt>goto
#<dt>current
#<dt>previous
#<dt>select
#<dt>refresh
#<dt>lset
#<dt>lget
#</dl>
#}
Classy::Editor method marker {command args} {
	private $object marker
	set we [::Classy::widget $object.edit]
	set arg [lindex $args 0]
	switch $command {
		set {
			if {"$arg"==""} {
				set arg $marker
			}
			private $object curmarker prevmarker
			if {"[$we tag ranges sel]"==""} {
				$we mark set $arg insert
			} else {
				set select [$we get sel.first sel.last]
				$we mark set $arg sel.first
				$we mark set $arg' sel.last
			}
			set prevmarker $curmarker
			set curmarker $arg
			regexp {^(.*[^0-9])([0-9]*)$} $arg temp mark num
			if {"$num"==""} {set num 1}
			set marker $mark$num
			$object marker refresh
			return $temp
		}
		delete {
			private $object curmarker prevmarker
			if {"$curmarker"=="$arg"} {set curmarker {}}
			if {"$prevmarker"=="$arg"} {set prevmarker {}}
			$we mark unset $arg
			$object marker refresh
		}
		goto {
			private $object curmarker prevmarker
			if {"$arg"==""} {return}
			if {"$curmarker" != "$arg"} {
				set prevmarker $curmarker
			}
			set curmarker $arg
			catch {$we tag remove sel 0.0 end}
			$we mark set insert [$object index $arg]
			catch {$we tag add sel insert [$object index $arg']}
			$we see insert
		}
		current {
			private $object curmarker
			$object marker goto $curmarker
		}
		previous {
			private $object prevmarker
			$object marker goto $prevmarker
		}
		select {
			set w $object.selectmark
			if [winfo exists $w] {
				$w place
			} else {
				if ![winfo exists $w] {
					Classy::SelectDialog $w -title "Select mark" -cache 1 \
						-command "$object marker goto \[$w get\]" \
						-addcommand "$object marker set" \
						-addvariable [privatevar $object marker] \
						-deletecommand "$object marker delete \[$w get\]"
				} else {
					$w place
				}
			}
			private $object curmarker
			if [info exists $curmarker] {
				$w set $curmarker
			 }
			$object marker refresh
		}
		refresh {
			set w $object.selectmark
			set names [$we mark names]
			set names [lremove $names anchor current insert]
			set names [lsub $names -exclude [lfind -regexp $names {'$}]]
			if {"$names" != ""} {$w fill $names}
		}
		lset {
			array set temp $args
			foreach name [array names temp] {
				$we mark set $name $temp($name)
			}
			$object marker refresh
		}
		lget {
			set result ""
			set names [$we mark names]
			set names [lremove $names anchor current insert]
			foreach name $names {
				lappend result $name
				lappend result [$we index $name]
				$we mark unset $name
			}
			return $result
			$object marker refresh
		}
	}
}

Classy::Editor method _reconfigure {} {
	foreach w [list $object $object.edit $object.vbar $object.hbar] {
		foreach {option name class} {
			-font font Font
			-foreground foreground Foreground
	      -background background Background
			-highlightbackground highlightBackground HighlightBackground
			-highlightcolor highlightColor HighlightColor
			-highlightthickness highlightThickness HighlightThickness
			-borderwidth borderWidth BorderWidth
			-disabledforeground disabledForeground DisabledForeground
			-insertbackground insertBackground Foreground
	 		-insertborderwidth insertBorderWidth BorderWidth
			-selectbackground selectBackground Foreground
			-selectborderwidth selectBorderWidth BorderWidth
	 		-selectforeground selectForeground Background
			-troughcolor troughColor Background
		} {
			catch {[::Classy::widget $w] configure $option [option get $w $name $class]}
		}
	}
	if [winfo exists $object.find] {
		Classy::Configurator _reconfigure $object.find
	}
	[::Classy::widget $object] configure -highlightthickness 0 -borderwidth 0
	eval grid forget [winfo children $object]
	if {[option get $object showTool ShowTool]} {
		catch {Classy::Configurator _reconfigure $object.tool}
		set row 1
		grid $object.tool -row 0 -column 0 -columnspan 2 -sticky we
		grid rowconfigure $object 0 -weight 0
		grid rowconfigure $object 1 -weight 1
	} else {
		set row 0
		grid rowconfigure $object 0 -weight 1
		grid rowconfigure $object 1 -weight 0
		grid rowconfigure $object 2 -weight 0
	}
	if {"[option get $object scrollSide ScrollSide]"=="left"} {
		grid $object.vbar -row $row -column 0 -sticky ns
		grid $object.edit -row $row -column 1 -sticky nswe
		incr row
		grid $object.hbar -row $row -column 1 -sticky we
		grid columnconfigure $object 0 -weight 0
		grid columnconfigure $object 1 -weight 1
	} else {
		grid $object.edit -row $row -column 0 -sticky nswe
		grid $object.vbar -row $row -column 1 -sticky ns
		incr row
		grid $object.hbar -row $row -column 0 -sticky we
		grid columnconfigure $object 0 -weight 1
		grid columnconfigure $object 1 -weight 0
	}
	update idletasks
}

Classy::Editor method cut {} {
	$object.edit cut
}

Classy::Editor method paste {} {
	$object.edit paste
}

Classy::Editor method undo {} {
	$object.edit undo
}

Classy::Editor method redo {} {
	$object.edit redo
}

proc Classy::title {w title} {
	wm title $w $title
	wm iconname $w $title
}

proc edit {args} {
	if {"$args"==""} {set args "Newfile"}
	set w .classy__edit
	set num 1
	while {[winfo exists $w$num] == 1} {incr num}
	set w $w$num
	catch {destroy $w}
	toplevel $w -bd 0 -highlightthickness 0
	wm protocol $w WM_DELETE_WINDOW "destroy $w"
	Classy::Editor $w.editor -loadcommand "Classy::title $w" -closecommand "after idle \{destroy $w\}" -setgrid yes
	pack $w.editor -fill both -expand yes
	eval $w.editor load $args
	return $w
}
