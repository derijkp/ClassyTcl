if {"[info commands REM]"==""} {
proc remon {} {
    proc REM {args} {
        puts stdout $args
    }
}

proc remof {} {
    proc REM {args} {}
}

remon

REM Start init file
wm geometry . 100x100+600+18
catch {extinit extral}

set Peos__dir /home/peter/dev/peos
source $Peos__dir/Peos.tcl

REM Rest of init
proc true {expr} {
    set result 0
    switch $expr {
        yes {set result 1}
        true {set result 1}
        1 {set result 1}
    }
    return $result
}

# tkMenuMotion -- patched: always post submenus
# This procedure is called to handle mouse motion events for menus.
# It does two things.  First, it resets the active element in the
# menu, if the mouse is over the menu.  Second, if a mouse button
# is down, it posts and unposts cascade entries to match the mouse
# position.
#
# Arguments:
# menu -		The menu window.
# y -			The y position of the mouse.
# state -		Modifier state (tells whether buttons are down).
source $tk_library/menu.tcl
proc tkMenuMotion {menu y state} {
    global tkPriv
    if {$menu == $tkPriv(window)} {
        eval $menu activate @$y
    }
    eval $menu postcascade active 
}

proc opt {w} {
    set list [$w configure]
    list_extract $list {(-[^ ]+)}
}
proc debug {text} {
    puts stdout $text
}

proc edit {args} {
    set w .edit
    set num 1
    while {[winfo exists $w$num] == 1} {incr num}
    set w $w$num
    catch {destroy $w}
    toplevel $w -bd 0 -highlightthickness 0
    frame $w.frame -relief raised 
    Peos__Editor $w.edit -loadcommand "wm title $w" -font Fixed \
         -yscrollcommand [list $w.vbar set] -xscrollcommand [list $w.hbar set] \
         -width 1 -height 1
    scrollbar $w.vbar -orient vertical -command "$w.edit yview"
    scrollbar $w.hbar -orient horizontal -command "$w.edit xview"
#    blt_table $object \
    	$object.edit 0,1 -fill both \
    	$object.vbar 0,0 -fill y \
    	$object.hbar 1,1 -fill x \
    	$object.frame 1,0
#    blt_table column $object configure 0 -resize none
#    blt_table row $object configure 1 -resize none
    pack $w.frame -fill both -expand yes -side top
    pack $w.vbar -in $w.frame -fill y -side left
    pack $w.edit -in $w.frame -fill both -expand yes
    pack $w.hbar -fill x -side bottom
    pack $w.edit -fill both -expand yes
    $w.edit.menu.file addaction Close "destroy $w" C-q
    $w.edit.menu bindto $w.edit
    eval $w.edit load $args
    wm geometry $w =80x40
    return $w
}

proc setglobal {globalvar args} {
    upvar #0 $globalvar var
    if [string match $args ""] {
        if ![info exists var] {
            error "can't read \"$globalvar\": no such global variable"
        } else {
            puts $var
        }
    } else {
        set var $args
    }
}

proc new_widget {base} {
    set num 1
    while {[winfo exists $base$num]==1} {
debug try:$base$num
        incr num
    }
    return $base$num
}

proc opendir {dir args} {
    global opendirs
#    set topl [new_widget .filerdir]
#    toplevel $topl
    set topl .filer$dir
    if [winfo exists $topl] {
        wm withdraw $topl
        wm deiconify $topl
    } else {
        toplevel $topl
        wm protocol $topl WM_DELETE_WINDOW "destroy $topl"
        if {"$args" != ""} {
            wm geometry $topl $args
        } else {
            wm geometry $topl 250x200+100+50
        }
        FilerWindow $topl.filerw -dir $dir
        wm title $topl $dir
        pack $topl.filerw -fill both -expand yes
    }
}

proc iconbar {command args} {
    send IconBar $command [list [tk appname]] $args
}

proc gethomedir {app} {
    send Filer "set home($app)"
}

proc newwindow {base} {
    set num 1
    while {[winfo exists $base$num]==1} {
        incr num
    }
    return $base$num
}

bind Text <ButtonRelease-2> {
    if !$tkPriv(mouseMoved) {
        catch {
            %W insert insert [selection get -displayof %W]
        }
    }
}

bind Button <2> {
    tkButtonDown %W
}

bind Button <ButtonRelease-2> {
    tkButtonUp %W
}

proc larrset {var items values} {
    set temp [list_join [lmanip merge $items $values] { } all]
    uplevel [list array set $var $temp]
}

proc lstrset {var type items values} {
    set temp [list_join [lmanip merge [list_regsub {^(.+)$} $items "$type,\\1"] $values] { } all]
    uplevel [list array set $var $temp]
}

proc allchildren w {
    set result $w
    set children [winfo children $w]
    if {"$children" == ""} {
        return $result
    } else {
        foreach child $children {
            eval lappend result [allchildren $child]
        }
        return $result
    }
}

proc list_set {listref value args} {
    upvar $listref list
    foreach index $args {
        set list [lreplace $list $index $index $value]
    }
}

REM End init file
} else {
REM init was already sourced
}
