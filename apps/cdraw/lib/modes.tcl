#Functions
proc line_init {} {
bind Line <<Action>> {line_action %W %x %y}
bind Line <<Escape>> {line_abort %W %x %y}
bind Line <<Adjust>> {line_abort %W %x %y}

}
proc text_init {} {
bind DrawText <<Action>> {text_action %W %x %y}
bind DrawText <<Adjust>> {text_action %W %x %y}
bind DrawText <KeyPress> {text_key %W %A}
bind DrawText <BackSpace> {text_key %W backspace}
bind DrawText <Delete> {text_key %W delete}
bind DrawText <<Left>> {text_key %W left}
bind DrawText <<Right>> {text_key %W right}
bind DrawText <<Up>> {text_key %W up}
bind DrawText <<Down>> {text_key %W down}

bind DrawText <<Action-Motion>> {
	text_select %W drag %x %y
}
bind DrawText <<MXPaste>> {
	catch {%W insert $current(cur) insert [selection get -displayof %W]}
}
bind DrawText <<SelectLeft>> {
	text_select %W left
}
bind DrawText <<SelectRight>> {
	text_select %W right
}
bind DrawText <<SelectUp>> {
	text_select %W up
}
bind DrawText <<SelectDown>> {
	text_select %W down
}

bind DrawText <<Home>> {
	text_key %W linestart
}
bind DrawText <<SelectHome>> {
	text_select %W linestart
}
bind DrawText <<End>> {
	text_key %W lineend
}
bind DrawText <<SelectEnd>> {
	text_select %W lineend
}
bind DrawText <<Top>> {
	text_key %W textstart
}
bind DrawText <<SelectTop>> {
	text_select %W textstart
}
bind DrawText <<Bottom>> {
	text_key %W textend
}
bind DrawText <<SelectBottom>> {
	text_select %W textend
}

bind DrawText <Tab> {
	text_key %W \t
}
bind DrawText <Control-i> {
	text_key %W \t
}
bind DrawText <Return> {
	text_key %W \n
}
bind DrawText <<Delete>> {
	text_key %W textdelete
}
bind DrawText <<BackSpace>> {
	text_key %W backspace
}

bind DrawText <<SelectAll>> {
	text_select %W all
}
bind DrawText <<SelectNone>> {
	text_select %W none
}
bind DrawText <Insert> {
	catch {%W textinsert [selection get -displayof %W]}
}

# The new bindings

bind DrawText <<Copy>> {
	text_key %W copy
	break
}												  
bind DrawText <<Cut>> {
	text_key %W cut
	break
}
bind DrawText <<Paste>> {
	text_key %W paste
	break
}
bind DrawText <<Undo>> {
	%W undo
}
bind DrawText <<Redo>> {
	%W redo
}

# Ignore all Alt, Meta, and Control keypresses unless explicitly bound.
# Otherwise, if a widget binding for one of these is defined, the
# <KeyPress> class binding will also fire and insert the character,
# which is wrong.  Ditto for <Escape>.

bind DrawText <Alt-KeyPress> {# nothing }
bind DrawText <Meta-KeyPress> {# nothing}
bind DrawText <Control-KeyPress> {# nothing}
bind DrawText <Escape> {# nothing}
bind DrawText <KP_Enter> {# nothing}

}
proc select_init {} {
bind Select <<Action>> {select_action %W %x %y}
bind Select <<Escape>> {select_abort %W %x %y}
bind Select <<Adjust>> {select_adjust %W %x %y}
}



