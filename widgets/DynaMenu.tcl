#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::DynaMenu
# ----------------------------------------------------------------------
#doc DynaMenu title {
#DynaMenu
#} descr {
# subclass of <a href="../basic/Class.html">Class</a><br>
# DynaMenu is not a widget and is not intended to produce instances. 
# It is a class that manages menus in an easy and dynamic way.
# Dynamenu can handle several menutypes.
#<p>
# Each menutype is defined by a definition in a simple format. 
# Dynamenu can create one or more popup or top menus for each
# menutype. When the definition of the menutype is redefined
# all menus of that type will be changed accordingly.
#<p>
# Menu definitions for menutype are usually controlled from the
# Menus part of the <a href="../classy_configure.html">configuration 
# system</a>. Creation of a menu of a certain type, will get the menu
# definition from the option database by creating a dummy frame with 
# class menutype and getting its option value for menu (class Menu).
# you can add a menutype in the configuration system by adding
#<pre>
### Somemenu {this is an example menu} menu
#option add *Somemenu.Menu definition widgetDefault
#</pre>
# to the Menus configuration file. You will usually only need this 
# configuration and the makemenu method to get working menus.
#<p>
# A menu managed by DynaMenu can control several widgets: The commands 
# associated with the menu can include a %W, that on invocation is
# changed to the current cmdw (command widget). The cmdw of a menu can be
# changed at any time. DynaMenu also handles key shortcuts.
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::DynaMenu {} {}
proc DynaMenu {} {}
}

option add *Classy::TopMenu.Button.padY 0 widgetDefault
option add *Classy::TopMenu.Checkbutton.padY 1 widgetDefault
option add *Classy::TopMenu.Menubutton.padY 1 widgetDefault

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Class subclass Classy::DynaMenu
Classy::export DynaMenu {}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {DynaMenu makemenu} cmd {
#DynaMenu makemenu menutype menu cmdw bindtag ?menuroot?
#} descr {
# This is usually the only method you need to create menus. It
# creates a menu named $menu of type $menutype if $menu does not exist yet.
# $cmdw determines the initial command widget. All key bindings 
# from key shortcuts
# are bound to $bindtag. Adding $bindtag to the bindtags of a widget
# will make all shortcuts available from that widget.
# The menu created will be a popup or top menu depending
# on the <a href="../classy_configure.html">ClassyTcl configuration</a>.
# <br>menuw can optionally be given to give the window on wich to tag 
# a menubar. If not given the toplevel of the cmdw is used. In this case,
# the cmdw has to exist when the menu is made.
#}
Classy::DynaMenu method makemenu {menutype menu cmdw bindtag {menuroot {}}} {
	private $object mtype cmdws checks bindtags bindings
	private $object menudata menutypes
	if ![info exists menudata($menutype)] {
		$object define $menutype
	}
	set menutypes($menu) $menutype
	set bindtags($menu) $bindtag
	set cmdws($menu) $cmdw
	set checks($menu) ""
	bind $bindtag <<KeyMenu>> [list $object post $menu %X %Y]
	bind $bindtag <<Menu>> [list $object post $menu %X %Y]
	bind $bindtag <FocusIn> [list $object cmdw $menu %W]
	if ![winfo exists $menu] {
		menu $menu -title [lindex $menutype 0]
		$object makepopup $menu $menu $menudata($menutype) $cmdw $bindtag
	}
	if {"$menuroot" == ""} {
		set root [winfo toplevel $cmdw]
	} else {
		set root [winfo toplevel $menuroot]
	}
	if {"[option get $root menuType MenuType]"=="top"} {
		set mtype($menu) top
		$menu configure -type menubar
		[Classy::window $root] configure -menu $menu
	} else {
		set mtype($menu) popup
	}
}
#doc {DynaMenu makepopup} cmd {
#DynaMenu makepopup menu curmenu data cmdw bindtag
#} descr {
# create a popup menu by the definition given in data. $cmdw
# determines the initial cmdw. All key bindings for key shortcuts
# are bound to $bindtag. Adding $bindtag to the bindtags of a widget
# will make all shortcuts available from that widget.
#}
Classy::DynaMenu method makepopup {menu curmenu data cmdw bindtag} {
	private $object checks base bindings
	if [info exists bindings($curmenu)] {
		foreach binding $bindings($curmenu) {
			bind $bindtag $binding {}
		}
	}
	$curmenu delete 0 end
	set bindings($curmenu) ""
	set base($curmenu) $menu
	set num 1
	foreach current [splitcomplete $data] {
		set type [lindex $current 0]
		set key [lindex $current 1]
		set text [lindex $current 2]
		if {"$type"=="menu"} {
			menu $curmenu.$key -title $key
			$object makepopup $menu $curmenu.$key [lindex $current 3] $cmdw $bindtag
			set shortcut [lindex $current 4]
			if {"$shortcut"!=""} {
				lappend bindings($curmenu) <$shortcut>
				catch {bind $bindtag <$shortcut> "tk_popup $curmenu.$key %X %Y 1;break"}
			} else {
				lappend bindings($curmenu) <<menu$key>>
				set shortcut [event info <<menu$key>>]
				lappend bindings($curmenu) <<menu$key>>
				catch {bind $bindtag <<menu$key>> "tk_popup $curmenu.$key %X %Y 1;break"}
			}
			$curmenu add cascade -label $text -menu $curmenu.$key -accelerator $shortcut
			incr num
		} elseif {"$type"=="activemenu"} {
			set command [lindex $current 3]
			regsub -all {%W} $command "\[$object cmdw $menu\]" command
			regsub -all {%%} $command % command

			set data [uplevel #0 $command]
			menu $curmenu.$key -title $key -postcommand [list $object _activemenu $menu $curmenu.$key $key $command]
			$object makepopup $menu $curmenu.$key $data $cmdw $bindtag
			set shortcut [lindex $current 4]
			if {"$shortcut"!=""} {
				lappend bindings($curmenu) <$shortcut>
				catch {bind $bindtag <$shortcut> "tk_popup $curmenu.$key %X %Y 1;break"}
			} else {
				set shortcut [event info <<menu$key>>]
				lappend bindings($curmenu) <<menu$key>>
				catch {bind $bindtag <<menu$key>> "tk_popup $curmenu.$key %X %Y 1;break"}
			}
			$curmenu add cascade -label $text -menu $curmenu.$key -accelerator $shortcut
			incr num
		} elseif {"$type"=="separator"} {
			$curmenu add separator
			incr num
		} elseif {"$type"=="action"} {
			set command [lindex $current 3]
			set shortcut [lindex $current 4]
			regsub -all {%W} $command "\[$object cmdw $menu\]" command
			regsub -all {%%} $command % command
			if {"$shortcut"!=""} {
				lappend bindings($curmenu) <$shortcut>
				catch {bind $bindtag <$shortcut> "$object invoke $curmenu $num;break"}
			} else {
				set shortcut [event info <<$key>>]
				lappend bindings($curmenu) <<$key>>
				catch {bind $bindtag <<$key>> "$object invoke $curmenu $num;break"}
			}
			$curmenu add command -label $text -command [list Classy::check $command] -accelerator [::Classy::shrink_accelerator $shortcut]
			incr num
		} elseif {"$type"=="check"} {
			set command [lindex $current 3]
			set shortcut [lindex $current 4]
			regsub -all {%W} $command $cmdw temp
			regsub -all {%%} $temp % temp
			if {"$shortcut"!=""} {
				lappend bindings($curmenu) <$shortcut>
				catch {bind $bindtag <$shortcut> "$object invoke $curmenu $num;break"}
			} else {
				set shortcut [event info <<$key>>]
				lappend bindings($curmenu) <<$key>>
				catch {bind $bindtag <<$key>> "$object invoke $curmenu $num;break"}
			}
			eval {$curmenu add check -label $text -accelerator $shortcut} $temp
			append checks($menu) "$curmenu entryconfigure [$curmenu index last] $command\n"
			incr num
		} elseif {"$type"=="radio"} {
			set command [lindex $current 3]
			set shortcut [lindex $current 4]
			regsub -all {%W} $command $cmdw temp
			regsub -all {%%} $temp % temp
			if {"$shortcut"!=""} {
				lappend bindings($curmenu) <$shortcut>
				catch {bind $bindtag <$shortcut> "$object invoke $curmenu $num;break"}
			} else {
				set shortcut [event info <<$key>>]
				lappend bindings($curmenu) <<$key>>
				catch {bind $bindtag <<$key>> "$object invoke $curmenu $num;break"}
			}
			eval {$curmenu add radio -label $text -accelerator $shortcut} $temp
			append checks($menu) "$curmenu entryconfigure [$curmenu index last] $command\n"
			incr num
		} elseif [regexp ^# $type] {
		} elseif {"$type" ==""} {
		} else {
			error "Unknown entrytype $type" 
		}
	}
}

#doc {DynaMenu define} cmd {
#DynaMenu define menutype ?data?
#} descr {
# set the definition describing the menus that will be generated 
# for menutype to $data.
# If data is not given, the menu definition for menutype is obtained 
# from the option database. A dummy frame with class $menutype is created,
# and the its option value for menu (class Menu) obtained. This option
# will usually be set in the Menus part 
# <a href="../classy_configure.html">configuration system</a>.
# You will usually not invoke this method, as the maketop and 
# makepopup methods will automatically define a menutype
# that isn't managed yet.
#}
Classy::DynaMenu method define {menutype {data {}}} {
	private $object menudata menutypes mtype cmdws checks bindtags flag
	if {"$data" == ""} {
		catch {destroy .classy__temp}
		frame .classy__temp -class $menutype
		set data [option get .classy__temp menu Menu]
		destroy .classy__temp
	}
	foreach menu [$object menus $menutype] {
		if ![winfo exists $menu] {
			catch {unset menutypes($menu)}
			catch {unset mtype($menu)}
			catch {unset cmdws($menu)}
			catch {unset bindtags($menu)}
			catch {unset checks($menu)}
		} else {
			eval destroy [winfo children $menu]
			if [catch {$object makepopup $menu $menu $data $cmdws($menu) $bindtags($menu)} error] {
				if [info exists flag] {
					unset flag
					error "error while defining menu; could not restore old: $error"
				} else {
					if [info exists menudata($menutype)] {
						set flag 1
						eval destroy [winfo children $menu]
						$object define $menutype $menudata($menutype)
						unset flag
					}
				}
				error "error while defining menu; restored old: $error"
			}
		}
	}
	set menudata($menutype) $data
}

#doc {DynaMenu types} cmd {
#DynaMenu names 
#} descr {
# returns a list of menutypes managed by Dynamenu
#}
Classy::DynaMenu method types {} {
	private $object menudata
	return [array names menudata]
}

#doc {DynaMenu menus} cmd {
#DynaMenu menus menutype
#} descr {
# returns a list of menus of type $menutype managed by Dynamenu
#}
Classy::DynaMenu method menus {menutype} {
	private $object menutypes
	if ![info exists menutypes] {return ""}
	set menulist [array get menutypes]
	set poss [lfind -exact $menulist $menutype]
	set result ""
	foreach pos $poss {
		lappend result [lindex $menulist [expr $pos-1]]
	}
	return $result
}

Classy::DynaMenu method add {menutype data} {
#	private $object menudata keep
#	set data [split $data "\n"]
#	set data [lremove $data {}]
#	
#	if ![info exists menudata($menutype)] {
#		$object define $menutype $data
#		return
#	}
#	set mdata $menudata($menutype)
#
#	set pos end
#	foreach line $data {
#		if [regexp {^menu} $line] {
#			set menus [lsub $mdata [lfind -regexp $mdata {^menu}]]
#			set search [lsearch -exact $menus $line]
#			if {$search==-1} {
#				lappend mdata $line
#				set pos end
#			} else {
#				set len [llength [lfind -regexp $mdata {^menu}]]
#				incr search
#				if {$search==$len} {
#					set pos end
#				} else {
#					set pos [lindex [lfind -regexp $mdata {^menu}] $search]
#				}
#			}
#		} else {
#			set item [lindex $line 1]
#			set temp [lsearch -regexp $mdata "\[ \t\]*\[a-z\]* $item "]
#			if {$temp==-1} {
#				set mdata [linsert $mdata $pos $line]
#			} else {
#				set mdata [lreplace $mdata $temp $temp $line]
#			}
#		}
#	}
#
#	set keep $menudata($menutype)
#	set menudata($menutype) $mdata
#	after cancel "$object redraw $menutype"
#	after idle "$object redraw $menutype"
#}

#doc {DynaMenu get} cmd {
#DynaMenu get menutype
#} descr {
# returns the definition of $menutype
#}
Classy::DynaMenu method get {menutype} {
	private $object menudata
	return $menudata($menutype)
}

#doc {DynaMenu delete} cmd {
#DynaMenu delete menutype
#} descr {
# delete the definition and all menus of $menutype
#}
Classy::DynaMenu method delete {menutype} {
	private $object menudata menutypes mtype cmdws checks bindtags active
	unset menudata($menutype)
	foreach menu [$object menus $menutype] {
		if [winfo exists $menu] {destroy $menu}
		unset menutypes($menu)
		unset mtype($menu)
		unset cmdws($menu)
		unset checks($menu)
		unset bindtags($menu)
	}
}

#doc {DynaMenu cmdw} cmd {
#DynaMenu cmdw menu ?cmdw?
#} descr {
# change the current cmdw for menu to $cmdw. If the cmdw argument is
# not given, the method returns the current cmdw for menu.
# This method is automatically called when a widget which has bindtags
# defined by DynaMenu recieves the focus.
#}
Classy::DynaMenu method cmdw {menu {cmdw {}}} {
	private $object cmdws base
	if [info exists base($menu)] {
		set basemenu $base($menu)
	} else {
		set basemenu $menu
	}
	if {"$cmdw"==""} {
		return $cmdws($basemenu)
	} else {
		if {"$cmdws($basemenu)"=="$cmdw"} {return $cmdw}
		set cmdws($basemenu) $cmdw
		private $object checks
		if [info exists checks($basemenu)] {
			regsub -all {%W} $checks($basemenu) $cmdw command
			regsub -all {%%} $command % command
			eval $command
		}
		return $cmdw
	}
}

#doc {DynaMenu post} cmd {
#DynaMenu post menu ?x y?
#} descr {
# post menu
#}
Classy::DynaMenu method post {menu {x {}} {y {}}} {
	private $object mtype
	if {"$mtype($menu)"=="popup"} {
		tk_popup $menu $x $y 1
	} else {
	    set w [tkMenuFind $menu ""]
	    if {$w != ""} {
			tkMbPost $w
			tkMenuFirstEntry [$w cget -menu]
		}
	}
}

#doc {DynaMenu invoke} cmd {
#DynaMenu invoke curmenu index
#} descr {
# invoke the item given by $index in $curmenu
#}
Classy::DynaMenu method invoke {curmenu index} {
	uplevel $curmenu invoke $index
}

#doc {DynaMenu confmenu} cmd {
#DynaMenu confmenu menutype
#} descr {
#}
Classy::DynaMenu method confmenu {menutype} {
	Classy::Configurator confmenu $menutype
}

#Classy::DynaMenu method loadmenu {menutype {file {}}} {
#	if {"$file"==""} {
#		set file [Classygetconffile $menutype.mnu]
#	}
#	if [file exists $file] {
#		set f [open $file]
#		set c [read $f]
#		close $f
#		$object define $menutype $c
#		return $file
#	} else {
#		error "Menu file $menutype.mnu not found in search path"
#	}
#}

Classy::DynaMenu method reqwidth {menu} {
	set slaves [place slaves $menu]
	set x 0
	foreach slave $slaves {
		incr x [winfo reqwidth $slave]
	}
	return $x
}


Classy::DynaMenu method reqheight {menu} {
	set slaves [place slaves $menu]
	set mh 0
	foreach slave $slaves {
		set h [winfo reqheight $slave]
		if {$h>$mh} {set mh $h}
	}
	return $mh
}

Classy::DynaMenu method _placetopfirst {menu} {
	set slaves [place slaves $menu]
	set mh 0
	set x 0
	while {"$slaves"!=""} {
		set slave [lpop slaves]
		set w [winfo reqwidth $slave]
		set h [winfo reqheight $slave]
		if {$h>$mh} {set mh $h}
		set temp [expr $x+$w]
		place forget $slave
		place $slave -x $x -y 0
		incr x $w
	}
	$menu configure -height $mh -width $x
	bind $menu <Configure> "$object _placetop $menu"
}

Classy::DynaMenu method _placetop {menu} {
	set keep [bind $menu <Configure>]
	bind $menu <Configure> {}
	set width [winfo width $menu]
	set slaves [place slaves $menu]
	set y 0
	set mh 0
	set x 0
	while {"$slaves"!=""} {
		set slave [lpop slaves]
		set w [winfo reqwidth $slave]
		set h [winfo reqheight $slave]
		if {$h>$mh} {set mh $h}
		set temp [expr $x+$w]
		if {$temp>$width} {
			set x 0
			incr y $mh
			set mh $h
		}
		place forget $slave
		place $slave -x $x -y $y
		incr x $w
	}
	incr y $mh
	$menu configure -height $y
	after idle "bind $menu <Configure> [list $keep]"
}

Classy::DynaMenu method _activemenu {menu curmenu key command} {
	private $object cmdws bindtags bindings
	set data [uplevel #0 $command]
	set cmdw $cmdws($menu)
	set bindtag $bindtags($menu)
	$object makepopup $menu $curmenu $data $cmdw $bindtag
}
