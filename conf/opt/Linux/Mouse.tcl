#ClassyTcl mouse configuration file

Classy::configmouse {Basic Buttons} {
	Action <<Action>> <1> {The Action button is used to select something, to invoke a button, etc.}
	Adjust <<Adjust>> <2> {The Adjust button provides an alternative action, eg. invoke button without closing dialog, etc}
	{X paste} <<MXPaste>> <2> {paste the currently selected characters}
	MainMenu <<MainMenu>> <Control-3> {The MainMenu button is used to pop up the main menu}
	Menu <<Menu>> <3> {The Menu button can pop up a menu}
	Execute <<MExecute>> <Double-1> {execute action, like when selecting in a listbox}
	{Adjust Execute} <<MExecuteAjust>> <Double-2> {executes an alternative action, like when selecting in a listbox, but without removing the dialog it is in}
	{icursor} <<MIcursor>> <Control-1> {set the insertion cursor, without removing the selection}
	{position} <<MPosition>> {<Control-1> <Control-2>} {set the a scrollbar to the give position}
}

Classy::configmouse {Change selection} {
	{Select word} <<MSelectWord>> <Double-1> {Select entire words}
	{Select line} <<MSelectLine>> <Triple-1> {Select entire lines}
	{Extend} <<MExtend>> <Shift-1> {extend the current selection}
	{Extend by words} <<MExtendWord>> <Double-Shift-1> {extend the current selection by entire words}
	{Extend by lines} <<MExtendLine>> <Triple-Shift-1> {extend the current selection by entire lines}
	{Add} <<MAdd>> <Control-1> {add to the current selection}
	{Add by words} <<MAddWord>> <Double-Control-1> {add to the current selection by entire words}
	{Add by lines} <<MAddLine>> <Triple-Control-1> {add to the current selection by entire lines}
}

Classy::configmouse {Drag & Drop keys} {
	{start drag} <<Drag>> {<ButtonPress-1><B1-Motion>} {start drag}
	{Adjust drag} <<AdjustDrag>> {<ButtonPress-3><B3-Motion>} {start adjust drag}
	{drag copy} <<Drag-Copy>> {<KeyPress-Control_L> <KeyPress-Control_R>} {copy instead of move}
	{drag link} <<Drag-Link>> {<KeyPress-Shift_L> <KeyPress-Shift_R>} {link instead of move}
}
