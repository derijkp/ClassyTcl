#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"
#
# Edit
# ----------------------------------------------------------------------
set pwd [send Filer "set home(Edit)"]
source $pwd/init.tcl

tk appname Edit
wm withdraw .
set id 1

proc load {args} {
    eval edit $args
}

proc edit {args} {
    global id
    set w .edit$id
    catch {destroy $w}
    toplevel $w -bd 0 -highlightthickness 0
    incr id

    frame $w.frame -relief raised 
    Peos__Editor $w.edit -loadcommand "wm title $w" -font Fixed \
         -yscrollcommand [list $w.vbar set] -xscrollcommand [list $w.hbar set]
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
    $w.edit.menu.file addaction Close "destroy $w" A-q
    $w.edit.menu bindto $w.edit
    eval $w.edit load $args
    wm geometry $w =80x40
    return $w
}

Peos__PopupMenu .barmenu
.barmenu addmenu file File
.barmenu addaction Quit {
    iconbar deleteicon
    exit
}

iconbar addicon $pwd/.image.gif
iconbar addcommand {edit Newfile}
iconbar addmenu {tk_popup .barmenu %X %Y 1}
iconbar adddragcommand {edit}

if {$argc>0} {
    eval edit $argv
}








