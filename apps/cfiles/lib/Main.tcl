proc main {args} {
	mainw
}

proc mainw args {# ClassyTcl generated Toplevel
	if [regexp {^\.} $args] {
		set window [lshift args]
	} else {
		set window .mainw
	}
	Classy::parseopt $args opt {}
	# Create windows
	Classy::Toplevel $window 
	Classy::Browser $window.browser  \
		-gettext gettext \
		-getdata getdata \
		-getimage getimage \
		-height 50 \
		-width 50
	grid $window.browser -row 2 -column 0 -sticky nesw
	frame $window.dir  \
		-borderwidth 0 \
		-height 10 \
		-width 10
	grid $window.dir -row 0 -column 0 -sticky nesw
	Classy::DynaTool $window.dir.tool  \
		-cmdw .try.dedit.work \
		-type DirTool \
		-height 21
	grid $window.dir.tool -row 0 -column 0 -sticky nesw
	Classy::Entry $window.dir.entry \
		-label Dir \
		-default dir \
		-width 4
	grid $window.dir.entry -row 0 -column 1 -sticky nesw
	grid columnconfigure $window.dir 1 -weight 1
	frame $window.file  \
		-borderwidth 0 \
		-height 10 \
		-width 10
	grid $window.file -row 1 -column 0 -sticky nesw
	Classy::Entry $window.file.entry \
		-label File \
		-width 4
	grid $window.file.entry -row 0 -column 1 -sticky nesw
	Classy::DynaTool $window.file.tool  \
		-cmdw .try.dedit.work \
		-type FileTool \
		-height 17
	grid $window.file.tool -row 0 -column 0 -sticky nesw
	grid columnconfigure $window.file 1 -weight 1
	grid columnconfigure $window 0 -weight 1
	grid rowconfigure $window 2 -weight 1

	# End windows
	# Parse this
	$window configure \
		-destroycommand {} \
		-title {[tk appname]}
	$window.browser configure \
		-list {[concat .. [glob [pwd]/*]]}
	bind $window.browser <<Drop>> {filer_drop w x y}
	bind $window.browser <<MExecuteAjust>> {filer_exec_adjust %W [%W name %x %y]}
	bind $window.browser <<Adjust>> {filer_adjust %W [%W name %x %y]}
	bind $window.browser <<MExecute>> {filer_exec %W [%W name %x %y]}
	bind $window.browser <<Action>> {filer_action %W [%W name %x %y]}
	bind $window.browser <<Drag>> {filer_drag %W %x %y %X %Y}
	$window.dir.entry configure \
		-command {[varsubst window {setdir $window.browser}]} \
		-textvariable {[varsubst window {status($window.browser,dir)}]}
	$window.file.entry configure \
		-command {[varsubst window {file_rename $window.browser}]} \
		-textvariable {[varsubst window {status($window.browser,file)}]}
	Classy::DynaMenu attachmainmenu MainMenu $window.browser
# ClassyTcl Finalise
setdir $window.browser [pwd]
	return $window
	return $window
	return $window
	return $window
	return $window
	return $window
	return $window
	return $window
}

























