## ---- Basic Buttons ----
## Action {The Action button is used to select something, to invoke a button, etc.} mouse
setevent <<Action>> <1>
## Adjust {The Adjust button provides an alternative action, eg. invoke button without closing dialog, etc} mouse
setevent <<Adjust>> <2>
## {X paste} {paste the currently selected characters} mouse
setevent <<MXPaste>> <2>
## Menu {The Menu button can pop up a menu} mouse
setevent <<Menu>> <3>
## Execute {execute action, like when selecting in a listbox} mouse
setevent <<MExecute>> <Double-1>
## {Adjust Execute} {executes an alternative action, like when selecting in a listbox, but without removing the dialog it is in} mouse
setevent <<MExecuteAjust>> <Double-2>
## {icursor} {set the insertion cursor, without removing the selection} mouse
setevent <<MIcursor>> <Control-1>
## {position} {set the a scrollbar to the give position} mouse
setevent <<MPosition>> <Control-1> <Control-2>

## ---- Change selection ----
## {Select word} {Select entire words} mouse
setevent <<MSelectWord>> <Double-1>
## {Select line} {Select entire lines} mouse
setevent <<MSelectLine>> <Triple-1>
## {Extend} {extend the current selection} mouse
setevent <<MExtend>> <Shift-1>
## {Extend by words} {extend the current selection by entire words} mouse
setevent <<MExtendWord>> <Double-Shift-1>
## {Extend by lines} {extend the current selection by entire lines} mouse
setevent <<MExtendLine>> <Triple-Shift-1>
## {Add} {add to the current selection} mouse
setevent <<MAdd>> <Control-1>
## {Add by words} {add to the current selection by entire words} mouse
setevent <<MAddWord>> <Double-Control-1>
## {Add by lines} {add to the current selection by entire lines} mouse
setevent <<MAddLine>> <Triple-Control-1>
