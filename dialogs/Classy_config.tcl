Classy::Toplevel subclass Classy_config
Classy_config method init args {
	super init
	# Create windows
	Classy::TreeWidget $object.browse \
		-width 160 \
		-height 50
	grid $object.browse -row 0 -column 0 -rowspan 2 -sticky nesw
	Classy::Paned $object.paned
	grid $object.paned -row 0 -column 1 -rowspan 2 -sticky nesw
	Classy::Selector $object.selector1 \
		-type color
	
	frame $object.frame  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $object.frame -row 1 -column 2 -columnspan 2 -sticky nesw
	Classy::Selector $object.frame.select \
		-type color
	grid $object.frame.select -row 2 -column 0 -sticky nesw
	Classy::Message $object.frame.descr \
		-highlightthickness 0 \
		-text message \
		-width 281
	grid $object.frame.descr -row 0 -column 0 -sticky nesw
	button $object.frame.button1 \
		-text button
	
	frame $object.frame.from  \
		-borderwidth 0 \
		-height 10 \
		-width 10
	grid $object.frame.from -row 1 -column 0 -sticky nesw
	Classy::Message $object.frame.from.msg \
		-highlightthickness 0 \
		-width 176
	grid $object.frame.from.msg -row 0 -column 0 -rowspan 2 -sticky nesw
	radiobutton $object.frame.from.radiobutton1 \
		-indicatoron 0 \
		-text Set \
		-value set \
		-variable Classy::Config_leveltype
	grid $object.frame.from.radiobutton1 -row 0 -column 1 -sticky nesw
	radiobutton $object.frame.from.radiobutton2 \
		-indicatoron 0 \
		-text Clear \
		-value clear \
		-variable Classy::Config_leveltype
	grid $object.frame.from.radiobutton2 -row 0 -column 2 -sticky nesw
	radiobutton $object.frame.from.radiobutton3 \
		-indicatoron 0 \
		-text {Dont Use} \
		-value comment \
		-variable Classy::Config_leveltype
	grid $object.frame.from.radiobutton3 -row 0 -column 3 -sticky nesw
	grid columnconfigure $object.frame.from 0 -weight 1
	grid rowconfigure $object.frame.from 1 -weight 1
	grid columnconfigure $object.frame 0 -weight 1
	grid rowconfigure $object.frame 2 -weight 1
	frame $object.level  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $object.level -row 0 -column 2 -columnspan 2 -sticky nesw
	button $object.level.button1 \
		-text button
	
	frame $object.level.pasted1  \
		-borderwidth 0 \
		-height 10 \
		-width 10
	grid $object.level.pasted1 -row 0 -column 0 -sticky nsw
	radiobutton $object.level.pasted1.pasted1 \
		-text Default \
		-value def \
		-variable Classy::config_level
	grid $object.level.pasted1.pasted1 -row 0 -column 3 -sticky nesw
	radiobutton $object.level.pasted1.pasted2 \
		-text User \
		-value user \
		-variable Classy::config_level
	grid $object.level.pasted1.pasted2 -row 0 -column 2 -sticky nesw
	radiobutton $object.level.pasted1.appdef1 \
		-text Application \
		-value appdef \
		-variable Classy::config_level
	grid $object.level.pasted1.appdef1 -row 0 -column 1 -sticky nesw
	radiobutton $object.level.pasted1.appuser1 \
		-text Final \
		-value appuser \
		-variable Classy::config_level
	grid $object.level.pasted1.appuser1 -row 0 -column 0 -sticky nesw
	Classy::DynaTool $object.level.dynatool1  \
		-type Classy::Config \
		-height 37
	grid $object.level.dynatool1 -row 1 -column 0 -sticky nesw
	grid columnconfigure $object.level 0 -weight 1
	grid columnconfigure $object 2 -weight 1
	grid rowconfigure $object 1 -weight 1

	# End windows
	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object configure \
		-destroycommand 
	$object.browse configure \
		-endnodecommand [varsubst object {invoke node {Classy::config_open $object.browse $node}}] \
		-opencommand [varsubst object {invoke node {Classy::config_browse $object.browse $node}}] \
		-closecommand [varsubst object {invoke node {Classy::config_close $object.browse $node}}]
	$object.paned configure \
		-window [varsubst object {$object.browse}]
	$object.frame.select configure \
		-command [varsubst object {invoke {} {Classy::config_setleveltype $object set}}]
	$object.frame.from.radiobutton1 configure \
		-command [varsubst object {Classy::config_setleveltype $object set}]
	$object.frame.from.radiobutton2 configure \
		-command [varsubst object {Classy::config_setleveltype $object clear}]
	$object.frame.from.radiobutton3 configure \
		-command [varsubst object {Classy::config_setleveltype $object comment}]
	$object.level.pasted1.pasted1 configure \
		-command [varsubst object {Classy::config_selectlevel $object def}]
	$object.level.pasted1.pasted2 configure \
		-command [varsubst object {Classy::config_selectlevel $object user}]
	$object.level.pasted1.appdef1 configure \
		-command [varsubst object {Classy::config_selectlevel $object appdef}]
	$object.level.pasted1.appuser1 configure \
		-command [varsubst object {Classy::config_selectlevel $object appuser}]
	$object.level.dynatool1 configure \
		-cmdw [varsubst object {$object}]
	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
# ClassyTcl Finalise
Classy::config_start $object
	return $object
}
Classy_config addoption -node {node Node {}} {
	Classy::config_open $object.browse $value
}
Classy_config addoption -level {level Level {}} {
	Classy::config_selectlevel $object $value
}
