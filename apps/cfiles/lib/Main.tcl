proc main {args} {
	mainw .mainw
}

Classy::Toplevel subclass mainw
mainw method init args {
	super init
	# Create windows
	Classy::Browser $object.browser  \
		-gettext gettext \
		-getdata getdata \
		-getimage getimage \
		-height 50 \
		-width 50
	grid $object.browser -row 2 -column 0 -sticky nesw
	frame $object.dir  \
		-borderwidth 0 \
		-height 10 \
		-width 10
	grid $object.dir -row 0 -column 0 -sticky nesw
	Classy::DynaTool $object.dir.tool  \
		-cmdw .try.dedit.work \
		-type DirTool \
		-height 21
	grid $object.dir.tool -row 0 -column 0 -sticky nesw
	Classy::Entry $object.dir.entry \
		-label Dir \
		-default dir \
		-width 4
	grid $object.dir.entry -row 0 -column 1 -sticky nesw
	grid columnconfigure $object.dir 1 -weight 1
	frame $object.file  \
		-borderwidth 0 \
		-height 10 \
		-width 10
	grid $object.file -row 1 -column 0 -sticky nesw
	Classy::Entry $object.file.entry \
		-label File \
		-width 4
	grid $object.file.entry -row 0 -column 1 -sticky nesw
	Classy::DynaTool $object.file.tool  \
		-cmdw .try.dedit.work \
		-type FileTool \
		-height 17
	grid $object.file.tool -row 0 -column 0 -sticky nesw
	grid columnconfigure $object.file 1 -weight 1
	grid columnconfigure $object 0 -weight 1
	grid rowconfigure $object 2 -weight 1

	# End windows
	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object configure \
		-destroycommand {} \
		-title {[tk appname]}
	$object.browser configure \
		-list {[concat .. [glob [pwd]/*]]}
	bind $object.browser <<Drop>> {filer_drop w x y}
	bind $object.browser <<MExecuteAjust>> {filer_exec_adjust %W [%W name %x %y]}
	bind $object.browser <<Adjust>> {filer_adjust %W [%W name %x %y]}
	bind $object.browser <<MExecute>> {filer_exec %W [%W name %x %y]}
	bind $object.browser <<Action>> {filer_action %W [%W name %x %y]}
	bind $object.browser <<Drag>> {filer_drag %W %x %y %X %Y}
	$object.dir.entry configure \
		-command {[varsubst object {setdir $object.browser}]} \
		-textvariable {[varsubst object {status($object.browser,dir)}]}
	$object.file.entry configure \
		-command {[varsubst object {file_rename $object.browser}]} \
		-textvariable {[varsubst object {status($object.browser,file)}]}
	Classy::DynaMenu attachmainmenu MainMenu $object.browser
	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
# ClassyTcl Finalise
setdir $object.browser [pwd]
	return $object
	return $object
	return $object
	return $object
	return $object
	return $object
	return $object
	return $object
}

