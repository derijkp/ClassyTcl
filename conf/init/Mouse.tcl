## ---- Basic Buttons ----
## Action {The Action button is used to select something, to invoke a button, etc.}
setevent <<Action>> <1>
## Adjust {The Adjust button provides an alternative action, eg. invoke button without closing dialog, etc}
setevent <<Adjust>> <2>
## {X paste} {paste the currently selected characters}
setevent <<MXPaste>> <2>
## Menu {The Menu button can pop up a menu}
setevent <<Menu>> <3>
## Execute {execute action, like when selecting in a listbox}
setevent <<MExecute>> <Double-1>
## {Adjust Execute} {executes an alternative action, like when selecting in a listbox, but without removing the dialog it is in}
setevent <<MExecuteAjust>> <Double-2>

## ---- Change selection ----
## {Select word} {Select entire words}
setevent <<MSelectWord>> <Double-1>
## {Select line} {Select entire lines}
setevent <<MSelectLine>> <Triple-1>
## {Extend} {extend the current selection}
setevent <<MExtend>> <Shift-1>
## {Extend by words} {extend the current selection by entire words}
setevent <<MExtendWord>> <Double-Shift-1>
## {Extend by lines} {extend the current selection by entire lines}
setevent <<MExtendLine>> <Triple-Shift-1>
## {Add} {add to the current selection}
setevent <<MAdd>> <Control-1>
## {Add by words} {add to the current selection by entire words}
setevent <<MAddWord>> <Double-Control-1>
## {Add by lines} {add to the current selection by entire lines}
setevent <<MAddLine>> <Triple-Control-1>
