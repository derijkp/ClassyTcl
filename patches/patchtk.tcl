package require Tk

if ![info exists Classy::patchtk] {
proc Classy::patchtk {} {
	foreach item {
		FocusIn FocusOut Enter Leave Motion Key KeyPress ButtonPress ButtonRelease
		Key-KP_Enter Control-Key Meta-Key Alt-Key
		Button
		Key-Tab Shift-Key-Tab
	} {
		set map(<$item>) <$item>
	}
	array set map {
		<Button-1> <<Action>>
		<ButtonRelease-1> <<ButtonRelease-Action>>
		<B1-Motion> <<Action-Motion>>
		<B1-Leave> <<Action-Leave>>
		<B1-Enter> <<Action-Enter>>
		<Double-Button-1> <<MSelectWord>>
		<Triple-Button-1> <<MSelectLine>>
		<Shift-Button-1> <<MExtend>>
		<Control-Button-1> <<MAdd>>
		<Double-Shift-Button-1> <<MExtendWord>>
		<Triple-Shift-Button-1> <<MExtendLine>>
		<Button-2> <<Adjust>>
		<ButtonRelease-2> <<MXPaste>>
		<B2-Motion> <<Adjust-Motion>>
		<B2-Leave> <<Adjust-Leave>>
		<B2-Enter> <<Adjust-Enter>>
	
		<Key-Left> <<Left>>
		<Shift-Key-Left> <<SelectLeft>>
		<Control-Key-Left> <<WordLeft>>
		<Control-Shift-Key-Left> <<SelectWordLeft>>
		<Key-Right> <<Right>>
		<Shift-Key-Right> <<SelectRight>>
		<Control-Key-Right> <<WordRight>>
		<Control-Shift-Key-Right> <<SelectWordRight>>
		<Key-Up> <<Up>>
		<Shift-Key-Up> <<SelectUp>>
		<Control-Key-Up> <<ParaUp>>
		<Control-Shift-Key-Up> <<SelectParaUp>>
		<Key-Down> <<Down>>
		<Shift-Key-Down> <<SelectDown>>
		<Control-Key-Down> <<ParaDown>>
		<Control-Shift-Key-Down> <<SelectParaDown>>
		<Key-Home> <<Home>>
		<Shift-Key-Home> <<SelectHome>>
		<Control-Key-Home> <<Top>>
		<Control-Shift-Key-Home> <<SelectTop>>
		<Key-End> <<End>>
		<Shift-Key-End> <<SelectEnd>>
		<Control-Key-End> <<Bottom>>
		<Control-Shift-Key-End> <<SelectBottom>>
		<Key-Prior> <<PageUp>>
		<Key-Next> <<PageDown>>
		<Shift-Key-Prior> <<SelectPageUp>>
		<Shift-Key-Next> <<SelectPageDown>>
		<Control-Key-Prior> <<ScrollPageUp>>
		<Control-Key-Next> <<ScrollPageDown>>
	
		<Key-Delete> <<Delete>>
		<Key-BackSpace> <<BackSpace>>
		<Control-Key-space> <<StartSelect>>
		<Control-Shift-Key-space> <<EndSelect>>
		<Control-Key-slash> <<SelectAll>>
		<Control-Key-backslash> <<SelectNone>>
		<Control-Key-t> <<Transpose>>
		<Control-Key-k> <<DeleteEnd>>
		<Meta-Key-f> <<WordRight>>
		<Meta-Key-b> <<WordLeft>>
	
		<Key-space> <<Invoke>>
		<<Cut>> <<Cut>>
		<<Paste>> <<Paste>>
		<<Copy>> <<Copy>>
		<<Clear>> <<Clear>>
		<Key-Escape> <<Escape>>
		<Key-Return> <<Return>>
		<Control-Key-Tab> <<TextFocusNext>>
		<Control-Shift-Key-Tab> <<TextFocusPrev>>
	}
	
	set list {Button Radiobutton Checkbutton Entry Listbox Menubutton Menu Scale Scrollbar Text}
	
	foreach type $list {
		foreach event [bind $type] {
			set temp [bind $type $event]
			bind $type $event {}
			if [info exists map($event)] {
				bind $type $map($event) $temp
			}
		}
	}
	
	bind Text <<Adjust>> {}
	bind Text <<Adjust-Motion>> {}
	bind Entry <<Adjust>> {}
	bind Entry <<Adjust-Motion>> {}
	bind Entry <Tab> {}
	bind Entry <<Empty>> {%W delete 0 end}
	foreach {type old new} {
		Text <<Return>> <Return>
		Text <<Escape>> <Escape>
		Text <<MAdd>> <<MIcursor>>
		Entry <<MAdd>> <<MIcursor>>
		Scale <<MXPaste>> <<ButtonRelease-Adjust>>
		Scrollbar <<MAdd> <<MPosition>>
	} {
		set temp [bind $type $old]
		bind $type $old {}
		bind $type $new $temp
	}
}

set Classy::patchtk 1
Classy::patchtk
rename Classy::patchtk {}
}