if ![info exists Classy::patchtk] {
set Classy::patchtk 1
::Tk::bind Button <Button-1> {}
::Tk::bind Button <ButtonRelease-1> {}
::Tk::bind Button <Key-space> {}
::Tk::bind Checkbutton <Button-1> {}
::Tk::bind Checkbutton <Key-Return> {}
::Tk::bind Checkbutton <Key-space> {}
::Tk::bind Entry <<PasteSelection>> {}
::Tk::bind Entry <B1-Enter> {}
::Tk::bind Entry <B1-Leave> {}
::Tk::bind Entry <B1-Motion> {}
::Tk::bind Entry <B2-Motion> {}
::Tk::bind Entry <Button-1> {}
::Tk::bind Entry <Button-2> {}
::Tk::bind Entry <ButtonRelease-1> {}
::Tk::bind Entry <Control-Button-1> {}
::Tk::bind Entry <Control-Key-Left> {}
::Tk::bind Entry <Control-Key-Right> {}
::Tk::bind Entry <Control-Key-a> {}
::Tk::bind Entry <Control-Key-b> {}
::Tk::bind Entry <Control-Key-backslash> {}
::Tk::bind Entry <Control-Key-d> {}
::Tk::bind Entry <Control-Key-e> {}
::Tk::bind Entry <Control-Key-f> {}
::Tk::bind Entry <Control-Key-h> {}
::Tk::bind Entry <Control-Key-k> {}
::Tk::bind Entry <Control-Key-slash> {}
::Tk::bind Entry <Control-Key-space> {}
::Tk::bind Entry <Control-Key-t> {}
::Tk::bind Entry <Control-Shift-Key-Left> {}
::Tk::bind Entry <Control-Shift-Key-Right> {}
::Tk::bind Entry <Control-Shift-Key-space> {}
::Tk::bind Entry <Double-Button-1> {}
::Tk::bind Entry <Double-Shift-Button-1> {}
::Tk::bind Entry <Key-BackSpace> {}
::Tk::bind Entry <Key-Delete> {}
::Tk::bind Entry <Key-End> {}
::Tk::bind Entry <Key-Escape> {}
::Tk::bind Entry <Key-Home> {}
::Tk::bind Entry <Key-Insert> {}
::Tk::bind Entry <Key-Left> {}
::Tk::bind Entry <Key-Return> {}
::Tk::bind Entry <Key-Right> {}
::Tk::bind Entry <Key-Select> {}
::Tk::bind Entry <Meta-Key-BackSpace> {}
::Tk::bind Entry <Meta-Key-Delete> {}
::Tk::bind Entry <Meta-Key-b> {}
::Tk::bind Entry <Meta-Key-d> {}
::Tk::bind Entry <Meta-Key-f> {}
::Tk::bind Entry <Shift-Button-1> {}
::Tk::bind Entry <Shift-Key-End> {}
::Tk::bind Entry <Shift-Key-Home> {}
::Tk::bind Entry <Shift-Key-Left> {}
::Tk::bind Entry <Shift-Key-Right> {}
::Tk::bind Entry <Shift-Key-Select> {}
::Tk::bind Entry <Triple-Button-1> {}
::Tk::bind Entry <Triple-Shift-Button-1> {}
::Tk::bind Listbox <B1-Enter> {}
::Tk::bind Listbox <B1-Leave> {}
::Tk::bind Listbox <B1-Motion> {}
::Tk::bind Listbox <B2-Motion> {}
::Tk::bind Listbox <Button-1> {}
::Tk::bind Listbox <Button-2> {}
::Tk::bind Listbox <ButtonRelease-1> {}
::Tk::bind Listbox <Control-Button-1> {}
::Tk::bind Listbox <Control-Key-End> {}
::Tk::bind Listbox <Control-Key-Home> {}
::Tk::bind Listbox <Control-Key-Left> {}
::Tk::bind Listbox <Control-Key-Next> {}
::Tk::bind Listbox <Control-Key-Prior> {}
::Tk::bind Listbox <Control-Key-Right> {}
::Tk::bind Listbox <Control-Key-backslash> {}
::Tk::bind Listbox <Control-Key-slash> {}
::Tk::bind Listbox <Control-Shift-Key-End> {}
::Tk::bind Listbox <Control-Shift-Key-Home> {}
::Tk::bind Listbox <Control-Shift-Key-space> {}
::Tk::bind Listbox <Double-Button-1> {}
::Tk::bind Listbox <Key-Down> {}
::Tk::bind Listbox <Key-End> {}
::Tk::bind Listbox <Key-Escape> {}
::Tk::bind Listbox <Key-Home> {}
::Tk::bind Listbox <Key-Left> {}
::Tk::bind Listbox <Key-Next> {}
::Tk::bind Listbox <Key-Prior> {}
::Tk::bind Listbox <Key-Right> {}
::Tk::bind Listbox <Key-Select> {}
::Tk::bind Listbox <Key-Up> {}
::Tk::bind Listbox <Key-space> {}
::Tk::bind Listbox <Shift-Button-1> {}
::Tk::bind Listbox <Shift-Key-Down> {}
::Tk::bind Listbox <Shift-Key-Select> {}
::Tk::bind Listbox <Shift-Key-Up> {}
::Tk::bind Menu <Key-Down> {}
::Tk::bind Menu <Key-Escape> {}
::Tk::bind Menu <Key-Left> {}
::Tk::bind Menu <Key-Return> {}
::Tk::bind Menu <Key-Right> {}
::Tk::bind Menu <Key-Up> {}
::Tk::bind Menu <Key-space> {}
::Tk::bind Menubutton <B1-Motion> {}
::Tk::bind Menubutton <Button-1> {}
::Tk::bind Menubutton <ButtonRelease-1> {}
::Tk::bind Menubutton <Key-space> {}
::Tk::bind Radiobutton <Button-1> {}
::Tk::bind Radiobutton <Key-Return> {}
::Tk::bind Radiobutton <Key-space> {}
::Tk::bind Scale <B1-Enter> {}
::Tk::bind Scale <B1-Leave> {}
::Tk::bind Scale <B1-Motion> {}
::Tk::bind Scale <B2-Enter> {}
::Tk::bind Scale <B2-Leave> {}
::Tk::bind Scale <B2-Motion> {}
::Tk::bind Scale <Button-1> {}
::Tk::bind Scale <Button-2> {}
::Tk::bind Scale <ButtonRelease-1> {}
::Tk::bind Scale <ButtonRelease-2> {}
::Tk::bind Scale <Control-Button-1> {}
::Tk::bind Scale <Control-Key-Down> {}
::Tk::bind Scale <Control-Key-Left> {}
::Tk::bind Scale <Control-Key-Right> {}
::Tk::bind Scale <Control-Key-Up> {}
::Tk::bind Scale <Key-Down> {}
::Tk::bind Scale <Key-End> {}
::Tk::bind Scale <Key-Home> {}
::Tk::bind Scale <Key-Left> {}
::Tk::bind Scale <Key-Right> {}
::Tk::bind Scale <Key-Up> {}
::Tk::bind Scrollbar <B1-B2-Motion> {}
::Tk::bind Scrollbar <B1-Button-2> {}
::Tk::bind Scrollbar <B1-ButtonRelease-2> {}
::Tk::bind Scrollbar <B1-Enter> {}
::Tk::bind Scrollbar <B1-Leave> {}
::Tk::bind Scrollbar <B1-Motion> {}
::Tk::bind Scrollbar <B2-Button-1> {}
::Tk::bind Scrollbar <B2-ButtonRelease-1> {}
::Tk::bind Scrollbar <B2-Enter> {}
::Tk::bind Scrollbar <B2-Leave> {}
::Tk::bind Scrollbar <B2-Motion> {}
::Tk::bind Scrollbar <Button-1> {}
::Tk::bind Scrollbar <Button-2> {}
::Tk::bind Scrollbar <ButtonRelease-1> {}
::Tk::bind Scrollbar <ButtonRelease-2> {}
::Tk::bind Scrollbar <Control-Button-1> {}
::Tk::bind Scrollbar <Control-Button-2> {}
::Tk::bind Scrollbar <Control-Key-Down> {}
::Tk::bind Scrollbar <Control-Key-Left> {}
::Tk::bind Scrollbar <Control-Key-Right> {}
::Tk::bind Scrollbar <Control-Key-Up> {}
::Tk::bind Scrollbar <Key-Down> {}
::Tk::bind Scrollbar <Key-End> {}
::Tk::bind Scrollbar <Key-Home> {}
::Tk::bind Scrollbar <Key-Left> {}
::Tk::bind Scrollbar <Key-Next> {}
::Tk::bind Scrollbar <Key-Prior> {}
::Tk::bind Scrollbar <Key-Right> {}
::Tk::bind Scrollbar <Key-Up> {}
::Tk::bind Text <<PasteSelection>> {}
::Tk::bind Text <B1-Enter> {}
::Tk::bind Text <B1-Leave> {}
::Tk::bind Text <B1-Motion> {}
::Tk::bind Text <B2-Motion> {}
::Tk::bind Text <Button-1> {}
::Tk::bind Text <Button-2> {}
::Tk::bind Text <ButtonRelease-1> {}
::Tk::bind Text <Control-Button-1> {}
::Tk::bind Text <Control-Key-Down> {}
::Tk::bind Text <Control-Key-End> {}
::Tk::bind Text <Control-Key-Home> {}
::Tk::bind Text <Control-Key-Left> {}
::Tk::bind Text <Control-Key-Next> {}
::Tk::bind Text <Control-Key-Prior> {}
::Tk::bind Text <Control-Key-Right> {}
::Tk::bind Text <Control-Key-Tab> {}
::Tk::bind Text <Control-Key-Up> {}
::Tk::bind Text <Control-Key-a> {}
::Tk::bind Text <Control-Key-b> {}
::Tk::bind Text <Control-Key-backslash> {}
::Tk::bind Text <Control-Key-d> {}
::Tk::bind Text <Control-Key-e> {}
::Tk::bind Text <Control-Key-f> {}
::Tk::bind Text <Control-Key-h> {}
::Tk::bind Text <Control-Key-i> {}
::Tk::bind Text <Control-Key-k> {}
::Tk::bind Text <Control-Key-n> {}
::Tk::bind Text <Control-Key-o> {}
::Tk::bind Text <Control-Key-p> {}
::Tk::bind Text <Control-Key-slash> {}
::Tk::bind Text <Control-Key-space> {}
::Tk::bind Text <Control-Key-t> {}
::Tk::bind Text <Control-Key-v> {}
::Tk::bind Text <Control-Shift-Key-Down> {}
::Tk::bind Text <Control-Shift-Key-End> {}
::Tk::bind Text <Control-Shift-Key-Home> {}
::Tk::bind Text <Control-Shift-Key-Left> {}
::Tk::bind Text <Control-Shift-Key-Right> {}
::Tk::bind Text <Control-Shift-Key-Tab> {}
::Tk::bind Text <Control-Shift-Key-Up> {}
::Tk::bind Text <Control-Shift-Key-space> {}
::Tk::bind Text <Double-Button-1> {}
::Tk::bind Text <Double-Shift-Button-1> {}
::Tk::bind Text <Key-BackSpace> {}
::Tk::bind Text <Key-Delete> {}
::Tk::bind Text <Key-Down> {}
::Tk::bind Text <Key-End> {}
::Tk::bind Text <Key-Escape> {}
::Tk::bind Text <Key-Home> {}
::Tk::bind Text <Key-Insert> {}
::Tk::bind Text <Key-Left> {}
::Tk::bind Text <Key-Next> {}
::Tk::bind Text <Key-Prior> {}
::Tk::bind Text <Key-Return> {}
::Tk::bind Text <Key-Right> {}
::Tk::bind Text <Key-Select> {}
::Tk::bind Text <Key-Up> {}
::Tk::bind Text <Meta-Key-BackSpace> {}
::Tk::bind Text <Meta-Key-Delete> {}
::Tk::bind Text <Meta-Key-b> {}
::Tk::bind Text <Meta-Key-d> {}
::Tk::bind Text <Meta-Key-f> {}
::Tk::bind Text <Meta-Key-greater> {}
::Tk::bind Text <Meta-Key-less> {}
::Tk::bind Text <Shift-Button-1> {}
::Tk::bind Text <Shift-Key-Down> {}
::Tk::bind Text <Shift-Key-End> {}
::Tk::bind Text <Shift-Key-Home> {}
::Tk::bind Text <Shift-Key-Left> {}
::Tk::bind Text <Shift-Key-Next> {}
::Tk::bind Text <Shift-Key-Prior> {}
::Tk::bind Text <Shift-Key-Right> {}
::Tk::bind Text <Shift-Key-Select> {}
::Tk::bind Text <Shift-Key-Up> {}
::Tk::bind Text <Triple-Button-1> {}
::Tk::bind Text <Triple-Shift-Button-1> {}
::Tk::bind Button <<Action-ButtonRelease>> {
    tkButtonUp %W
}
::Tk::bind Button <<Action>> {
    tkButtonDown %W
}
::Tk::bind Button <<Invoke>> {
    tkButtonInvoke %W
}
::Tk::bind Button <Enter> {
    tkButtonEnter %W
}
::Tk::bind Button <Leave> {
    tkButtonLeave %W
}
::Tk::bind Checkbutton <<Action>> {
	tkCheckRadioInvoke %W
    }
::Tk::bind Checkbutton <<Invoke>> {
    tkCheckRadioInvoke %W
}
::Tk::bind Checkbutton <<Return>> {
	if {!$tk_strictMotif} {
	    tkCheckRadioInvoke %W
	}
    }
::Tk::bind Checkbutton <Enter> {
	tkButtonEnter %W
    }
::Tk::bind Checkbutton <Leave> {
    tkButtonLeave %W
}
::Tk::bind Entry <<Action-ButtonRelease>> {
    tkCancelRepeat
}
::Tk::bind Entry <<Action-Enter>> {
    tkCancelRepeat
}
::Tk::bind Entry <<Action-Leave>> {
    set tkPriv(x) %x
    tkEntryAutoScan %W
}
::Tk::bind Entry <<Action-Motion>> {
    set tkPriv(x) %x
    tkEntryMouseSelect %W %x
}
::Tk::bind Entry <<Action>> {
    tkEntryButton1 %W %x
    %W selection clear
}
::Tk::bind Entry <<Adjust-ButtonRelease>> {}
::Tk::bind Entry <<BackSpace>> {
    tkEntryBackspace %W
}
::Tk::bind Entry <<Clear>> {
    %W delete sel.first sel.last
}
::Tk::bind Entry <<Copy>> {
    if {![catch {set data [string range [%W get] [%W index sel.first] [expr {[%W index sel.last] - 1}]]}]} {
	clipboard clear -displayof %W
	clipboard append -displayof %W $data
    }
}
::Tk::bind Entry <<Cut>> {
    if {![catch {set data [string range [%W get] [%W index sel.first] [expr {[%W index sel.last] - 1}]]}]} {
	clipboard clear -displayof %W
	clipboard append -displayof %W $data
	%W delete sel.first sel.last
    }
}
::Tk::bind Entry <<Delete>> {
    if {[%W selection present]} {
	%W delete sel.first sel.last
    } else {
	%W delete insert
    }
}
::Tk::bind Entry <<DeleteEnd>> {
    if {!$tk_strictMotif} {
	%W delete insert end
    }
}
::Tk::bind Entry <<Empty>> {%W delete 0 end}
::Tk::bind Entry <<End>> {
    tkEntrySetCursor %W end
}
::Tk::bind Entry <<EndSelect>> {
    %W selection adjust insert
}
::Tk::bind Entry <<Escape>> {# nothing}
::Tk::bind Entry <<Home>> {
    tkEntrySetCursor %W 0
}
::Tk::bind Entry <<Left>> {
    tkEntrySetCursor %W [expr {[%W index insert] - 1}]
}
::Tk::bind Entry <<MAdd>> {
    %W icursor @%x
}
::Tk::bind Entry <<MExtend>> {
    set tkPriv(selectMode) char
    %W selection adjust @%x
}
::Tk::bind Entry <<MExtendLine>> {
    set tkPriv(selectMode) line
    tkEntryMouseSelect %W %x
}
::Tk::bind Entry <<MExtendWord>> {
    set tkPriv(selectMode) word
    tkEntryMouseSelect %W %x
}
::Tk::bind Entry <<MIcursor>> {}
::Tk::bind Entry <<MSelectLine>> {
    set tkPriv(selectMode) line
    tkEntryMouseSelect %W %x
    %W icursor 0
}
::Tk::bind Entry <<MSelectWord>> {
    set tkPriv(selectMode) word
    tkEntryMouseSelect %W %x
    catch {%W icursor sel.first}
}
::Tk::bind Entry <<Paste>> {
    global tcl_platform
    catch {
	if {"$tcl_platform(platform)" != "unix"} {
	    catch {
		%W delete sel.first sel.last
	    }
	}
	%W insert insert [selection get -displayof %W -selection CLIPBOARD]
	tkEntrySeeInsert %W
    }
}
::Tk::bind Entry <<Return>> {# nothing}
::Tk::bind Entry <<Right>> {
    tkEntrySetCursor %W [expr {[%W index insert] + 1}]
}
::Tk::bind Entry <<SelectAll>> {
    %W selection range 0 end
}
::Tk::bind Entry <<SelectEnd>> {
    tkEntryKeySelect %W end
    tkEntrySeeInsert %W
}
::Tk::bind Entry <<SelectHome>> {
    tkEntryKeySelect %W 0
    tkEntrySeeInsert %W
}
::Tk::bind Entry <<SelectLeft>> {
    tkEntryKeySelect %W [expr {[%W index insert] - 1}]
    tkEntrySeeInsert %W
}
::Tk::bind Entry <<SelectNone>> {
    %W selection clear
}
::Tk::bind Entry <<SelectRight>> {
    tkEntryKeySelect %W [expr {[%W index insert] + 1}]
    tkEntrySeeInsert %W
}
::Tk::bind Entry <<SelectWordLeft>> {
    tkEntryKeySelect %W [tkEntryPreviousWord %W insert]
    tkEntrySeeInsert %W
}
::Tk::bind Entry <<SelectWordRight>> {
    tkEntryKeySelect %W [tkEntryNextWord %W insert]
    tkEntrySeeInsert %W
}
::Tk::bind Entry <<StartSelect>> {
    %W selection from insert
}
::Tk::bind Entry <<Transpose>> {
    if {!$tk_strictMotif} {
	tkEntryTranspose %W
    }
}
::Tk::bind Entry <<WordLeft>> {
    tkEntrySetCursor %W [tkEntryPreviousWord %W insert]
}
::Tk::bind Entry <<WordRight>> {
    tkEntrySetCursor %W [tkEntryNextWord %W insert]
}
::Tk::bind Entry <Alt-Key> {# nothing}
::Tk::bind Entry <Control-Key> {# nothing}
::Tk::bind Entry <Key-KP_Enter> {# nothing}
::Tk::bind Entry <Key-Tab> {# nothing}
::Tk::bind Entry <Key> {
    tkEntryInsert %W %A
}
::Tk::bind Entry <Meta-Key> {# nothing}
::Tk::bind Listbox <<Action-ButtonRelease>> {
    tkCancelRepeat
    %W activate @%x,%y
}
::Tk::bind Listbox <<Action-Enter>> {
    tkCancelRepeat
}
::Tk::bind Listbox <<Action-Leave>> {
    set tkPriv(x) %x
    set tkPriv(y) %y
    tkListboxAutoScan %W
}
::Tk::bind Listbox <<Action-Motion>> {
    set tkPriv(x) %x
    set tkPriv(y) %y
    tkListboxMotion %W [%W index @%x,%y]
}
::Tk::bind Listbox <<Action>> {
    if {[winfo exists %W]} {
	tkListboxBeginSelect %W [%W index @%x,%y]
    }
}
::Tk::bind Listbox <<Adjust-Motion>> {
    %W scan dragto %x %y
}
::Tk::bind Listbox <<Adjust>> {
    %W scan mark %x %y
}
::Tk::bind Listbox <<Bottom>> {
    %W activate end
    %W see end
    %W selection clear 0 end
    %W selection set end
}
::Tk::bind Listbox <<Copy>> {
    if {[selection own -displayof %W] == "%W"} {
	clipboard clear -displayof %W
	clipboard append -displayof %W [selection get -displayof %W]
    }
}
::Tk::bind Listbox <<Down>> {
    tkListboxUpDown %W 1
}
::Tk::bind Listbox <<End>> {
    %W xview moveto 1
}
::Tk::bind Listbox <<EndSelect>> {
    tkListboxBeginExtend %W [%W index active]
}
::Tk::bind Listbox <<Escape>> {
    tkListboxCancel %W
}
::Tk::bind Listbox <<Home>> {
    %W xview moveto 0
}
::Tk::bind Listbox <<Invoke>> {
    tkListboxBeginSelect %W [%W index active]
}
::Tk::bind Listbox <<Left>> {
    %W xview scroll -1 units
}
::Tk::bind Listbox <<MAdd>> {
    tkListboxBeginToggle %W [%W index @%x,%y]
}
::Tk::bind Listbox <<MExtend>> {
    tkListboxBeginExtend %W [%W index @%x,%y]
}
::Tk::bind Listbox <<MSelectWord>> {
    # Empty script
}
::Tk::bind Listbox <<PageDown>> {
    %W yview scroll 1 pages
    %W activate @0,0
}
::Tk::bind Listbox <<PageUp>> {
    %W yview scroll -1 pages
    %W activate @0,0
}
::Tk::bind Listbox <<Right>> {
    %W xview scroll 1 units
}
::Tk::bind Listbox <<ScrollPageDown>> {
    %W xview scroll 1 pages
}
::Tk::bind Listbox <<ScrollPageUp>> {
    %W xview scroll -1 pages
}
::Tk::bind Listbox <<SelectAll>> {
    tkListboxSelectAll %W
}
::Tk::bind Listbox <<SelectBottom>> {
    tkListboxDataExtend %W [%W index end]
}
::Tk::bind Listbox <<SelectDown>> {
    tkListboxExtendUpDown %W 1
}
::Tk::bind Listbox <<SelectNone>> {
    if {[%W cget -selectmode] != "browse"} {
	%W selection clear 0 end
    }
}
::Tk::bind Listbox <<SelectTop>> {
    tkListboxDataExtend %W 0
}
::Tk::bind Listbox <<SelectUp>> {
    tkListboxExtendUpDown %W -1
}
::Tk::bind Listbox <<Top>> {
    %W activate 0
    %W see 0
    %W selection clear 0 end
    %W selection set 0
}
::Tk::bind Listbox <<Up>> {
    tkListboxUpDown %W -1
}
::Tk::bind Listbox <<WordLeft>> {
    %W xview scroll -1 pages
}
::Tk::bind Listbox <<WordRight>> {
    %W xview scroll 1 pages
}
::Tk::bind Menu <<Down>> {
    tkMenuDownArrow %W
}
::Tk::bind Menu <<Escape>> {
    tkMenuEscape %W
}
::Tk::bind Menu <<Invoke>> {
    tkMenuInvoke %W 0
}
::Tk::bind Menu <<Left>> {
    tkMenuLeftArrow %W
}
::Tk::bind Menu <<Return>> {
    tkMenuInvoke %W 0
}
::Tk::bind Menu <<Right>> {
    tkMenuRightArrow %W
}
::Tk::bind Menu <<Up>> {
    tkMenuUpArrow %W
}
::Tk::bind Menu <Button> {
    tkMenuButtonDown %W
}
::Tk::bind Menu <ButtonRelease> {
   tkMenuInvoke %W 1
}
::Tk::bind Menu <Enter> {
    set tkPriv(window) %W
    if {[%W cget -type] == "tearoff"} {
	if {"%m" != "NotifyUngrab"} {
	    if {$tcl_platform(platform) == "unix"} {
		tk_menuSetFocus %W
	    }
	}
    }
    tkMenuMotion %W %x %y %s
}
::Tk::bind Menu <Key> {
    tkTraverseWithinMenu %W %A
}
::Tk::bind Menu <Leave> {
    tkMenuLeave %W %X %Y %s
}
::Tk::bind Menu <Motion> {
    tkMenuMotion %W %x %y %s
}
::Tk::bind Menubutton <<Action-ButtonRelease>> {
    tkMbButtonUp %W
}
::Tk::bind Menubutton <<Action-Motion>> {
    tkMbMotion %W down %X %Y
}
::Tk::bind Menubutton <<Action>> {
    if {$tkPriv(inMenubutton) != ""} {
	tkMbPost $tkPriv(inMenubutton) %X %Y
    }
}
::Tk::bind Menubutton <<Invoke>> {
    tkMbPost %W
    tkMenuFirstEntry [%W cget -menu]
}
::Tk::bind Menubutton <Enter> {
    tkMbEnter %W
}
::Tk::bind Menubutton <Leave> {
    tkMbLeave %W
}
::Tk::bind Menubutton <Motion> {
    tkMbMotion %W up %X %Y
}
::Tk::bind Radiobutton <<Action>> {
	tkCheckRadioInvoke %W
    }
::Tk::bind Radiobutton <<Invoke>> {
    tkCheckRadioInvoke %W
}
::Tk::bind Radiobutton <<Return>> {
	if {!$tk_strictMotif} {
	    tkCheckRadioInvoke %W
	}
    }
::Tk::bind Radiobutton <Enter> {
	tkButtonEnter %W
    }
::Tk::bind Radiobutton <Leave> {
    tkButtonLeave %W
}
::Tk::bind Scale <<Action-ButtonRelease>> {
    tkCancelRepeat
    tkScaleEndDrag %W
    tkScaleActivate %W %x %y
}
::Tk::bind Scale <<Action-Enter>> { }
::Tk::bind Scale <<Action-Leave>> { }
::Tk::bind Scale <<Action-Motion>> {
    tkScaleDrag %W %x %y
}
::Tk::bind Scale <<Action>> {
    tkScaleButtonDown %W %x %y
}
::Tk::bind Scale <<Adjust-ButtonRelease>> {}
::Tk::bind Scale <<Adjust-Enter>> { }
::Tk::bind Scale <<Adjust-Leave>> { }
::Tk::bind Scale <<Adjust-Motion>> {
    tkScaleDrag %W %x %y
}
::Tk::bind Scale <<Adjust>> {
    tkScaleButton2Down %W %x %y
}
::Tk::bind Scale <<Down>> {
    tkScaleIncrement %W down little noRepeat
}
::Tk::bind Scale <<End>> {
    %W set [%W cget -to]
}
::Tk::bind Scale <<Home>> {
    %W set [%W cget -from]
}
::Tk::bind Scale <<Left>> {
    tkScaleIncrement %W up little noRepeat
}
::Tk::bind Scale <<MAdd>> {
    tkScaleControlPress %W %x %y
}
::Tk::bind Scale <<MXPaste>> {
    tkCancelRepeat
    tkScaleEndDrag %W
    tkScaleActivate %W %x %y
}
::Tk::bind Scale <<ParaDown>> {
    tkScaleIncrement %W down big noRepeat
}
::Tk::bind Scale <<ParaUp>> {
    tkScaleIncrement %W up big noRepeat
}
::Tk::bind Scale <<Right>> {
    tkScaleIncrement %W down little noRepeat
}
::Tk::bind Scale <<Up>> {
    tkScaleIncrement %W up little noRepeat
}
::Tk::bind Scale <<WordLeft>> {
    tkScaleIncrement %W up big noRepeat
}
::Tk::bind Scale <<WordRight>> {
    tkScaleIncrement %W down big noRepeat
}
::Tk::bind Scale <Enter> {
    if {$tk_strictMotif} {
	set tkPriv(activeBg) [%W cget -activebackground]
	%W config -activebackground [%W cget -background]
    }
    tkScaleActivate %W %x %y
}
::Tk::bind Scale <Leave> {
    if {$tk_strictMotif} {
	%W config -activebackground $tkPriv(activeBg)
    }
    if {[%W cget -state] == "active"} {
	%W configure -state normal
    }
}
::Tk::bind Scale <Motion> {
    tkScaleActivate %W %x %y
}
::Tk::bind Scrollbar <<Action-ButtonRelease>> {
    tkScrollButtonUp %W %x %y
}
::Tk::bind Scrollbar <<Action-Enter>> {
    # Prevents <Enter> binding from being invoked.
}
::Tk::bind Scrollbar <<Action-Leave>> {
    # Prevents <Leave> binding from being invoked.
}
::Tk::bind Scrollbar <<Action-Motion>> {
    tkScrollDrag %W %x %y
}
::Tk::bind Scrollbar <<Action>> {
    tkScrollButtonDown %W %x %y
}
::Tk::bind Scrollbar <<Adjust-Enter>> {
    # Prevents <Enter> binding from being invoked.
}
::Tk::bind Scrollbar <<Adjust-Leave>> {
    # Prevents <Leave> binding from being invoked.
}
::Tk::bind Scrollbar <<Adjust-Motion>> {
    tkScrollDrag %W %x %y
}
::Tk::bind Scrollbar <<Adjust>> {
    tkScrollButton2Down %W %x %y
}
::Tk::bind Scrollbar <<Down>> {
    tkScrollByUnits %W v 1
}
::Tk::bind Scrollbar <<End>> {
    tkScrollToPos %W 1
}
::Tk::bind Scrollbar <<Home>> {
    tkScrollToPos %W 0
}
::Tk::bind Scrollbar <<Left>> {
    tkScrollByUnits %W h -1
}
::Tk::bind Scrollbar <<MAdd>> {
    tkScrollTopBottom %W %x %y
}
::Tk::bind Scrollbar <<MPosition>> {}
::Tk::bind Scrollbar <<MXPaste>> {
    tkScrollButtonUp %W %x %y
}
::Tk::bind Scrollbar <<PageDown>> {
    tkScrollByPages %W hv 1
}
::Tk::bind Scrollbar <<PageUp>> {
    tkScrollByPages %W hv -1
}
::Tk::bind Scrollbar <<ParaDown>> {
    tkScrollByPages %W v 1
}
::Tk::bind Scrollbar <<ParaUp>> {
    tkScrollByPages %W v -1
}
::Tk::bind Scrollbar <<Right>> {
    tkScrollByUnits %W h 1
}
::Tk::bind Scrollbar <<Up>> {
    tkScrollByUnits %W v -1
}
::Tk::bind Scrollbar <<WordLeft>> {
    tkScrollByPages %W h -1
}
::Tk::bind Scrollbar <<WordRight>> {
    tkScrollByPages %W h 1
}
::Tk::bind Scrollbar <Enter> {
    if {$tk_strictMotif} {
	set tkPriv(activeBg) [%W cget -activebackground]
	%W config -activebackground [%W cget -background]
    }
    %W activate [%W identify %x %y]
}
::Tk::bind Scrollbar <Leave> {
    if {$tk_strictMotif && [info exists tkPriv(activeBg)]} {
	%W config -activebackground $tkPriv(activeBg)
    }
    %W activate {}
}
::Tk::bind Scrollbar <Motion> {
    %W activate [%W identify %x %y]
}
::Tk::bind Text <<Action-ButtonRelease>> {
    tkCancelRepeat
}
::Tk::bind Text <<Action-Enter>> {
    tkCancelRepeat
}
::Tk::bind Text <<Action-Leave>> {
    set tkPriv(x) %x
    set tkPriv(y) %y
    tkTextAutoScan %W
}
::Tk::bind Text <<Action-Motion>> {
    set tkPriv(x) %x
    set tkPriv(y) %y
    tkTextSelectTo %W %x %y
}
::Tk::bind Text <<Action>> {
    tkTextButton1 %W %x %y
    %W tag remove sel 0.0 end
}
::Tk::bind Text <<Adjust-ButtonRelease>> {}
::Tk::bind Text <<BackSpace>> {
    if {[%W tag nextrange sel 1.0 end] != ""} {
	%W delete sel.first sel.last
    } elseif {[%W compare insert != 1.0]} {
	%W delete insert-1c
	%W see insert
    }
}
::Tk::bind Text <<Bottom>> {
    tkTextSetCursor %W {end - 1 char}
}
::Tk::bind Text <<Clear>> {
    catch {%W delete sel.first sel.last}
}
::Tk::bind Text <<Copy>> {
    tk_textCopy %W
}
::Tk::bind Text <<Cut>> {
    tk_textCut %W
}
::Tk::bind Text <<Delete>> {
    if {[%W tag nextrange sel 1.0 end] != ""} {
	%W delete sel.first sel.last
    } else {
	%W delete insert
	%W see insert
    }
}
::Tk::bind Text <<DeleteEnd>> {
    if {!$tk_strictMotif} {
	if {[%W compare insert == {insert lineend}]} {
	    %W delete insert
	} else {
	    %W delete insert {insert lineend}
	}
    }
}
::Tk::bind Text <<Down>> {
    tkTextSetCursor %W [tkTextUpDownLine %W 1]
}
::Tk::bind Text <<End>> {
    tkTextSetCursor %W {insert lineend}
}
::Tk::bind Text <<EndSelect>> {
    set tkPriv(selectMode) char
    tkTextKeyExtend %W insert
}
::Tk::bind Text <<Escape>> {# nothing}
::Tk::bind Text <<Home>> {
    tkTextSetCursor %W {insert linestart}
}
::Tk::bind Text <<Left>> {
    tkTextSetCursor %W insert-1c
}
::Tk::bind Text <<MAdd>> {
    %W mark set insert @%x,%y
}
::Tk::bind Text <<MExtend>> {
    tkTextResetAnchor %W @%x,%y
    set tkPriv(selectMode) char
    tkTextSelectTo %W %x %y
}
::Tk::bind Text <<MExtendLine>> {
    set tkPriv(selectMode) line
    tkTextSelectTo %W %x %y
}
::Tk::bind Text <<MExtendWord>> {
    set tkPriv(selectMode) word
    tkTextSelectTo %W %x %y
}
::Tk::bind Text <<MIcursor>> {}
::Tk::bind Text <<MSelectLine>> {
    set tkPriv(selectMode) line
    tkTextSelectTo %W %x %y
    catch {%W mark set insert sel.first}
}
::Tk::bind Text <<MSelectWord>> {
    set tkPriv(selectMode) word
    tkTextSelectTo %W %x %y
    catch {%W mark set insert sel.first}
}
::Tk::bind Text <<PageDown>> {
    tkTextSetCursor %W [tkTextScrollPages %W 1]
}
::Tk::bind Text <<PageUp>> {
    tkTextSetCursor %W [tkTextScrollPages %W -1]
}
::Tk::bind Text <<ParaDown>> {
    tkTextSetCursor %W [tkTextNextPara %W insert]
}
::Tk::bind Text <<ParaUp>> {
    tkTextSetCursor %W [tkTextPrevPara %W insert]
}
::Tk::bind Text <<Paste>> {
    tk_textPaste %W
}
::Tk::bind Text <<Return>> {
    tkTextInsert %W \n
}
::Tk::bind Text <<Right>> {
    tkTextSetCursor %W insert+1c
}
::Tk::bind Text <<ScrollPageDown>> {
    %W xview scroll 1 page
}
::Tk::bind Text <<ScrollPageUp>> {
    %W xview scroll -1 page
}
::Tk::bind Text <<SelectAll>> {
    %W tag add sel 1.0 end
}
::Tk::bind Text <<SelectBottom>> {
    tkTextKeySelect %W {end - 1 char}
}
::Tk::bind Text <<SelectDown>> {
    tkTextKeySelect %W [tkTextUpDownLine %W 1]
}
::Tk::bind Text <<SelectEnd>> {
    tkTextKeySelect %W {insert lineend}
}
::Tk::bind Text <<SelectHome>> {
    tkTextKeySelect %W {insert linestart}
}
::Tk::bind Text <<SelectLeft>> {
    tkTextKeySelect %W [%W index {insert - 1c}]
}
::Tk::bind Text <<SelectNone>> {
    %W tag remove sel 1.0 end
}
::Tk::bind Text <<SelectPageDown>> {
    tkTextKeySelect %W [tkTextScrollPages %W 1]
}
::Tk::bind Text <<SelectPageUp>> {
    tkTextKeySelect %W [tkTextScrollPages %W -1]
}
::Tk::bind Text <<SelectParaDown>> {
    tkTextKeySelect %W [tkTextNextPara %W insert]
}
::Tk::bind Text <<SelectParaUp>> {
    tkTextKeySelect %W [tkTextPrevPara %W insert]
}
::Tk::bind Text <<SelectRight>> {
    tkTextKeySelect %W [%W index {insert + 1c}]
}
::Tk::bind Text <<SelectTop>> {
    tkTextKeySelect %W 1.0
}
::Tk::bind Text <<SelectUp>> {
    tkTextKeySelect %W [tkTextUpDownLine %W -1]
}
::Tk::bind Text <<SelectWordLeft>> {
    tkTextKeySelect %W [tkTextPrevPos %W insert tcl_startOfPreviousWord]
}
::Tk::bind Text <<SelectWordRight>> {
    tkTextKeySelect %W [tkTextNextWord %W insert]
}
::Tk::bind Text <<StartSelect>> {
    %W mark set anchor insert
}
::Tk::bind Text <<TextFocusNext>> {
    focus [tk_focusNext %W]
}
::Tk::bind Text <<TextFocusPrev>> {
    focus [tk_focusPrev %W]
}
::Tk::bind Text <<Top>> {
    tkTextSetCursor %W 1.0
}
::Tk::bind Text <<Transpose>> {
    if {!$tk_strictMotif} {
	tkTextTranspose %W
    }
}
::Tk::bind Text <<Up>> {
    tkTextSetCursor %W [tkTextUpDownLine %W -1]
}
::Tk::bind Text <<WordLeft>> {
    tkTextSetCursor %W [tkTextPrevPos %W insert tcl_startOfPreviousWord]
}
::Tk::bind Text <<WordRight>> {
    tkTextSetCursor %W [tkTextNextWord %W insert]
}
::Tk::bind Text <Alt-Key> {# nothing }
::Tk::bind Text <Control-Key> {# nothing}
::Tk::bind Text <Escape> {}
::Tk::bind Text <Key-KP_Enter> {# nothing}
::Tk::bind Text <Key-Tab> {
    tkTextInsert %W \t
    focus %W
    break
}
::Tk::bind Text <Key> {
    tkTextInsert %W %A
}
::Tk::bind Text <Meta-Key> {# nothing}
::Tk::bind Text <Return> {}
::Tk::bind Text <Shift-Key-Tab> {
    # Needed only to keep <Tab> binding from triggering;  doesn't
    # have to actually do anything.
    break
}
}
