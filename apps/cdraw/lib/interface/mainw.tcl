Classy::Toplevel subclass mainw
mainw method init args {
	super init
	# Create windows
	Classy::DynaTool $object.maintool  \
		-width 179 \
		-type MainTool \
		-height 21
	grid $object.maintool -row 0 -column 0 -columnspan 2 -sticky new
	Classy::Canvas $object.canvas \
		-papersize A4 \
		-height 50 \
		-relief sunken \
		-scrollregion {0 0 595p 842p} \
		-width 50
	grid $object.canvas -row 1 -column 0 -sticky nesw
	scrollbar $object.scrollbar1
	
	scrollbar $object.scrollv
	grid $object.scrollv -row 1 -column 1 -sticky nesw
	scrollbar $object.scrollh \
		-orient horizontal
	grid $object.scrollh -row 2 -column 0 -sticky nesw
	grid columnconfigure $object 0 -weight 1
	grid rowconfigure $object 1 -weight 1

	# End windows
	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object configure \
		-destroycommand "exit" \
		-title [tk appname]
	$object.maintool configure \
		-cmdw [varsubst object {$object.canvas}]
	$object.canvas configure \
		-xscrollcommand "$object.scrollh set" \
		-yscrollcommand "$object.scrollv set"
	$object.scrollv configure \
		-command "$object.canvas yview"
	$object.scrollh configure \
		-command "$object.canvas xview"
	Classy::DynaMenu attachmainmenu MainMenu $object.canvas
	return $object

	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}}
