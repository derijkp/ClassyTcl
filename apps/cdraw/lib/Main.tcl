proc main args {
set w [mainw]
line_init
text_init
set w $w.canvas
line_start $w
bind Classy::Canvas <Enter> [list focus $w]
bind Classy::Canvas <Enter> [list focus $w]
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
	Classy::DynaTool $window.maintool  \
		-width 179 \
		-type MainTool \
		-height 21
	grid $window.maintool -row 0 -column 0 -columnspan 2 -sticky new
	Classy::Canvas $window.canvas \
		-papersize A4 \
		-height 50 \
		-relief sunken \
		-scrollregion {0 0 595p 842p} \
		-width 50
	grid $window.canvas -row 1 -column 0 -sticky nesw
	scrollbar $window.scrollbar1
	
	scrollbar $window.scrollv
	grid $window.scrollv -row 1 -column 1 -sticky nesw
	scrollbar $window.scrollh \
		-orient horizontal
	grid $window.scrollh -row 2 -column 0 -sticky nesw
	grid columnconfigure $window 0 -weight 1
	grid rowconfigure $window 1 -weight 1

	# End windows
	# Parse this
	$window configure \
		-destroycommand "exit" \
		-title [tk appname]
	$window.maintool configure \
		-cmdw [varsubst window {$window.canvas}]
	$window.canvas configure \
		-xscrollcommand "$window.scrollh set" \
		-yscrollcommand "$window.scrollv set"
	$window.scrollv configure \
		-command "$window.canvas yview"
	$window.scrollh configure \
		-command "$window.canvas xview"
	Classy::DynaMenu attachmainmenu MainMenu $window.canvas
	return $window
}













proc clearpage w {
global current
$w delete all
catch {unset current}
}









