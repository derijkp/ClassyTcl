#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::DynaMenu
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::DynaMenu {} {}
proc DynaMenu {} {}
}
catch {Classy::DynaMenu destroy}

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

Classy::DynaMenu method define {menutype {data {}}} {
	private $object menudata keep
	if [info exists menudata($menutype)] {set keep $menudata($menutype)}
	if {"$data" != ""} {
		set menudata($menutype) $data
	} else {
		catch {destroy .classy__temp}
		frame .classy__temp -class $menutype
		set menudata($menutype) [option get .classy__temp menu Menu]
		destroy .classy__temp
	}
	$object redraw $menutype
}

Classy::DynaMenu method names {} {
	private $object menudata
	return [array names menudata]
}

#Classy::DynaMenu method add {menutype data} {
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

Classy::DynaMenu method redraw {menutype} {
	private $object keep
	if [catch {$object _refresh $menutype} result] {
		global errorInfo
		set error $errorInfo
		if [info exists keep] {
			set menudata($menutype) $keep
			$object _refresh $menutype
			append result "\nRestored old menu"
		}
		error $result $error
	}
}

Classy::DynaMenu method get {menutype} {
	private $object menudata
	return $menudata($menutype)
}

Classy::DynaMenu method delete {menutype} {
	private $object menudata menutypes mtype cmdws checks bindtags
	unset menudata($menutype)
	if [info exists menutypes] {
		set menulist [array get menutypes]
		set poss [lfind -exact $menulist $menutype]
		foreach pos $poss {
			set menu [lindex $menulist [expr $pos-1]]
			if [winfo exists $menu] {destroy $menu}
			unset menutypes($menu)
			unset mtype($menu)
			unset cmdws($menu)
			unset checks($menu)
			unset bindtags($menu)
		}
	}
}

Classy::DynaMenu method _refresh {menutype} {
	private $object menutypes mtype cmdws checks bindtags notop
	if [info exists menutypes] {
		set menulist [array get menutypes]
		set poss [lfind -exact $menulist $menutype]
		foreach pos $poss {
			set menu [lindex $menulist [expr $pos-1]]
			if ![winfo exists $menu] {
				catch {unset menutypes($menu)}
				catch {unset mtype($menu)}
				catch {unset cmdws($menu)}
				catch {unset bindtags($menu)}
				catch {unset checks($menu)}
			} else {
				set tag $bindtags($menu)
				foreach binding [bind $tag] {
					bind $tag $binding {}
				}
				if {"$mtype($menu)"=="top"} {
					eval destroy [winfo children $menu]
				} else {
					destroy $menu
				}
				set notop 1
				$object make$mtype($menu) $menutype $menu $cmdws($menu) $tag
				unset notop
			}
		}
	}
}

Classy::DynaMenu method makepopup {menutype menu cmdw bindtag} {
	private $object mtype cmdws menudata menutypes checks bindtags
	if ![info exists menudata($menutype)] {
		$object define $menutype
	}
	set bindtags($menu) $bindtag
	set menutypes($menu) $menutype
	set mtype($menu) popup
	set cmdws($menu) $cmdw
	set checks($menu) ""
	bind $bindtag <<KeyMenu>> [list $object post $menu %X %Y]
	bind $bindtag <<Menu>> [list $object post $menu %X %Y]
	bind $bindtag <FocusIn> [list $object cmdw $menu %W]
	set todo($menu) $menudata($menutype)
	menu $menu -title [lindex $menutype 0]
	while {[array names todo] != ""} {
		foreach curmenu [array names todo] {
			set num 1
			foreach current [splitcomplete $todo($curmenu)] {
				set type [lindex $current 0]
				set key [lindex $current 1]
				set text [lindex $current 2]
				if {"$type"=="menu"} {
					menu $curmenu.$key
					set todo($curmenu.$key) [lindex $current 3]
					set shortcut [lindex $current 4]
					if {"$shortcut"!=""} {
						catch {bind $bindtag <$shortcut> "tk_popup $curmenu.$key %X %Y 1;break"}
					} else {
						set shortcut [event info <<menu$key>>]
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
						catch {bind $bindtag <$shortcut> "$object invoke $curmenu $num;break"}
					} else {
						set shortcut [event info <<$key>>]
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
						catch {bind $bindtag <$shortcut> "$object invoke $curmenu $num;break"}
					} else {
						set shortcut [event info <<$key>>]
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
						catch {bind $bindtag <$shortcut> "$object invoke $curmenu $num;break"}
					} else {
						set shortcut [event info <<$key>>]
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
			unset todo($curmenu)
		}
	}
}

#new
Classy::DynaMenu method maketop {menutype menu cmdw bindtag} {
	private $object mtype cmdws menudata menutypes checks bindtags
	if ![info exists menudata($menutype)] {
		$object define $menutype
	}
	set bindtags($menu) $bindtag
	set menutypes($menu) $menutype
	set mtype($menu) popup
	set cmdws($menu) $cmdw
	set checks($menu) ""
	if ![info exists notop] {
		frame $menu -class Classy::TopMenu -highlightthickness 0 -bd 0
#		bind $menu <Configure> [list $object placetop $menu]
	}
	bind $bindtag <<KeyMenu>> [list $object post $menu %X %Y]
	bind $bindtag <<Menu>> [list $object post $menu %X %Y]
	bind $bindtag <FocusIn> [list $object cmdw $menu %W]
	set num 1
	foreach current [splitcomplete $menudata($menutype)] {
		set type [lindex $current 0]
		set key [lindex $current 1]
		set text [lindex $current 2]
		if {"$type"=="menu"} {
			set shortcut [lindex $current 4]
			if {"$shortcut"!=""} {
				catch {bind $bindtag <$shortcut> "tk_popup $menu.$key.menu %X %Y 1;break"}
			} else {
				set shortcut [event info <<menu$key>>]
				catch {bind $bindtag <<menu$key>> "tk_popup $menu.$key.menu %X %Y 1;break"}
			}
			menubutton $menu.$key -text $text -highlightthickness 0 -menu $menu.$key.menu
			menu $menu.$key.menu
			set todo($menu.$key.menu) [lindex $current 3]
			place $menu.$key -x 0 -y 0
		} elseif {"$type"=="separator"} {
		} elseif {"$type"=="action"} {
			set command [lindex $current 3]
			set shortcut [lindex $current 4]
			regsub -all {%W} $command "\[$object cmdw $menu\]" command
			regsub -all {%%} $command % command
			regexp {^(.)(.*)$} $key temp f end
			set key [string tolower $f]$end
			if {"$shortcut"!=""} {
				catch {bind $bindtag <$shortcut> [list $menu.$key invoke]}
			} else {
				set shortcut [event info <<$key>>]
				catch {bind $bindtag <<$key>> [list $menu.$key invoke]}
			}
			if {"$shortcut"!=""} {
				append text " ([::Classy::shrink_accelerator $shortcut])"
			}
			button $menu.$key -text $text -highlightthickness 0 -command [list Classy::check $command]
			place $menu.$key -x 0 -y 0
		} elseif {"$type"=="check"} {
			set command [lindex $current 3]
			set shortcut [lindex $current 4]
			regsub -all {%W} $command $cmdw tempcmd
			regsub -all {%%} $tempcmd % tempcmd
			regexp {^(.)(.*)$} $key temp f end
			set key [string tolower $f]$end
			if {"$shortcut"!=""} {
				catch {bind $bindtag <$shortcut> [list $menu.$key invoke]}
			} else {
				set shortcut [event info <<$key>>]
				catch {bind $bindtag <<$key>> [list $menu.$key invoke]}
			}
			if {"$shortcut"!=""} {
				append text " ([::Classy::shrink_accelerator $shortcut])"
			}
			eval {checkbutton $menu.$key -text $text -highlightthickness 0} $tempcmd
			place $menu.$key -x 0 -y 0
			append checks($menu) "$menu.$key configure $command\n"
		} elseif {"$type"=="radio"} {
			set command [lindex $current 3]
			set shortcut [lindex $current 4]
			regsub -all {%W} $command $cmdw tempcmd
			regsub -all {%%} $tempcmd % tempcmd
			regexp {^(.)(.*)$} $key temp f end
			set key [string tolower $f]$end
			if {"$shortcut"!=""} {
				catch {bind $bindtag <$shortcut> [list $menu.$key invoke]}
			} else {
				set shortcut [event info <<$key>>]
				catch {bind $bindtag <<$key>> [list $menu.$key invoke]}
			}
			eval {radiobutton $menu.$key -text $text -highlightthickness 0} $tempcmd
			place $menu.$key -x 0 -y 0
			append checks($menu) "$menu.$key configure $command\n"
		} elseif [regexp ^# $type] {
		} elseif {"$type" ==""} {
		} else {
			error "Unknown entrytype $type" 
		}
	}
#
#	Do submenus: same as popup
#
	while {[array names todo] != ""} {
		foreach curmenu [array names todo] {
			set num 1
			foreach current [splitcomplete $todo($curmenu)] {
				set type [lindex $current 0]
				set key [lindex $current 1]
				set text [lindex $current 2]
				if {"$type"=="menu"} {
					menu $curmenu.$key
					set todo($curmenu.$key) [lindex $current 3]
					set shortcut [lindex $current 4]
					if {"$shortcut"!=""} {
						catch {bind $bindtag <$shortcut> "tk_popup $curmenu.$key %X %Y 1;break"}
					} else {
						set shortcut [event info <<menu$key>>]
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
						catch {bind $bindtag <$shortcut> "$object invoke $curmenu $num;break"}
					} else {
						set shortcut [event info <<$key>>]
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
						catch {bind $bindtag <$shortcut> "$object invoke $curmenu $num;break"}
					} else {
						set shortcut [event info <<$key>>]
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
						catch {bind $bindtag <$shortcut> "$object invoke $curmenu $num;break"}
					} else {
						set shortcut [event info <<$key>>]
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
			unset todo($curmenu)
		}
	}
	$object _placetopfirst $menu
}

Classy::DynaMenu method cmdw {menu {cmdw {}}} {
	private $object cmdws
	if {"$cmdw"==""} {
		return $cmdws($menu)
	} else {
		if {"$cmdws($menu)"=="$cmdw"} {return $cmdw}
		set cmdws($menu) $cmdw
		private $object checks
		if [info exists checks($menu)] {
			regsub -all {%W} $checks($menu) $cmdw command
			regsub -all {%%} $command % command
			eval $command
		}
		return $cmdw
	}
}

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

Classy::DynaMenu method invoke {curmenu index} {
	$curmenu invoke $index
}

Classy::DynaMenu method confmenu {menutype {options {*}}} {
	Classycustomise__item "Configure menu" $menutype.mnu [list $object loadmenu $menutype %F] $options
}

Classy::DynaMenu method loadmenu {menutype {file {}}} {
	if {"$file"==""} {
		set file [Classygetconffile $menutype.mnu]
	}
	if [file exists $file] {
		set f [open $file]
		set c [read $f]
		close $f
		$object define $menutype $c
		return $file
	} else {
		error "Menu file $menutype.mnu not found in search path"
	}
}

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
	bind $menu <Configure> "$object placetop $menu"
}

Classy::DynaMenu method placetop {menu} {
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
