#ClassyTcl key configuration file

Classy::configkey Edit {
	Cut <<Cut>> <Alt-x> {Cut key}
	Copy <<Copy>> <Alt-c> {Copy key}
	Paste <<Paste>> <Alt-v> {Paste key}
	{Paste special} <<PasteSpecial>> <Alt-V> {Paste special key}
	Undo <<Undo>> <Alt-u> {Undo key}
	Redo <<Redo>> <Alt-U> {Redo key}
	Insert <<Insert>> <Insert> {Insert key}
	Empty <<Empty>> <Control-u> {Empty key}
	Delete <<Delete>> <Delete> {Delete key}
	BackSpace <<BackSpace>> <BackSpace> {BackSpace key}
	Transpose <<Transpose>> <Control-t> {Transpose key: switches the letters before and after the cursor}
	DeleteEnd <<DeleteEnd>> <Control-k> {Delete from cursor to end}
}

Classy::configkey Select {
	SelectAll <<SelectAll>> <Alt-a> {SelectAll key}
	SelectNone <<SelectNone>> <Alt-z> {SelectNone key}
	StartSelect <<StartSelect>> <Control-space> {StartSelect key}
	EndSelect <<EndSelect>> <Control-Shift-space> {EndSelect key}
}
Classy::configkey File {
	Load <<Load>> <Alt-o> {Load key}
	LoadNext <<LoadNext>> <Control-Alt-o> {LoadNext key}
	Save <<Save>> <Alt-s> {Save key}
	SaveAs <<SaveAs>> <Alt-S> {SaveAs key}
	New <<New>> <Alt-n> {New key}
	Quit <<Quit>> <Alt-Q> {Quit key}
	Close <<Close>> <Alt-q> {Close key}
	Reopen <<Reopen>> <Alt-r> {Reopen key}
	Macro <<Macro>> <Alt-m> {Macro key}
}
Classy::configkey Find {
	Goto <<Goto>> <Alt-j> {Goto key}
	Find <<Find>> <Alt-F> {Find key}
	FindNext <<FindNext>> <Alt-f> {FindNext key}
	FindPrev <<FindPrev>> <Alt-b> {FindPrev key}
	ReplaceFindNext <<ReplaceFindNext>> <Alt-g> {ReplaceFindNext key}
	FindFunction <<FindFunction>> <Control-Alt-f> {FindFunction key}
}
Classy::configkey Control {
	Escape <<Escape>> <Escape> {Escape key}
	Return <<Return>> <Return> {Return key}
	Invoke <<Invoke>> <space> {Invoke key}
	KeyMenu <<KeyMenu>> <Alt-m> {KeyMenu key}
	Default <<Default>> <Alt-d> {Default key}
	#Complete <<CompleteTab>> <Control-Shift-v> {Complete key}
	FocusNext <<FocusNext>> {<Tab> <Control-Tab>} {FocusNext key}
	FocusPrev <<FocusPrev>> <ISO_Left_Tab> {FocusPrev key}
	SpecialFocusNext <<SpecialFocusNext>> <Control-Tab> {TextFocusNext key}
	SpecialFocusPrev <<SpecialFocusPrev>> <ISO_Left_Tab> {TextFocusPrev key}
}
Classy::configkey Misc {
	New <<New>> <Alt-n> {Help key}
	Help <<Help>> <F1> {Help key}
	Format <<Format>> <Control-Alt-j> {Format key}
	Print <<Print>> <Control-p> {Print key}
	MarkerSet <<MarkerSet>> <Alt-w> {MarkerSet key}
	MarkerSelect <<MarkerSelect>> <Alt-Shift-w> {MarkerSelect key}
	MarkerCurrent <<MarkerCurrent>> <Control-w> {MarkerCurrent key}
	MarkerPrev <<MarkerPrev>> <Control-Shift-w> {MarkerPrev key}
	IndentIn <<IndentIn>> <Alt-i> {IndentIn key}
	IndentOut <<IndentOut>> <Alt-I> {IndentOut key}
	Connect <<Connect>> <Control-c> {Connect key}
	{Execute command} <<ExecuteCmd>> <Alt-e> {Execute command key}
	HistoryUp <<HistoryUp>> <Alt-Up> {HistoryUp key}
	HistoryDown <<HistoryDown>> <Alt-Down> {HistoryDown key}
}
Classy::configkey Movement {
	Up <<Up>> <Up> {Up key}
	Down <<Down>> <Down> {Down key}
	Left <<Left>> <Left> {Left key}
	Right <<Right>> <Right> {Right key}
	Home <<Home>> {<Home> <Alt-Left>} {Home key}
	End <<End>> {<End> <Alt-Right>} {End key}
	Top <<Top>> <Control-Home> {Top key}
	Bottom <<Bottom>> <Control-End> {Bottom key}
	PageTop <<PageTop>> <Alt-Up> {PageTop key}
	PageBottom <<PageBottom>> <Alt-Down> {PageBottom key}
	PageUp <<PageUp>> <Prior> {PageUp key}
	PageDown <<PageDown>> <Next> {PageDown key}
	WordLeft <<WordLeft>> <Control-Left> {WordLeft key}
	WordRight <<WordRight>> <Control-Right> {WordRight key}
	ParaUp <<ParaUp>> <Control-Up> {ParaUp key}
	ParaDown <<ParaDown>> <Control-Down> {ParaDown key}
}
Classy::configkey {Movement with selection} {
	SelectUp <<SelectUp>> <Shift-Up> {SelectUp key}
	SelectDown <<SelectDown>> <Shift-Down> {SelectDown key}
	SelectLeft <<SelectLeft>> <Shift-Left> {SelectLeft key}
	SelectRight <<SelectRight>> <Shift-Right> {SelectRight key}
	SelectHome <<SelectHome>> {<Shift-Home> <Shift-Alt-Left>} {SelectHome key}
	SelectEnd <<SelectEnd>> {<Shift-End> <Shift-Alt-Right>} {SelectEnd key}
	SelectTop <<SelectTop>> <Shift-Control-Home> {SelectTop key}
	SelectBottom <<SelectBottom>> <Shift-Control-End> {SelectBottom key}
	SelectPageTop <<SelectPageTop>> <Shift-Alt-Up> {SelectPageTop key}
	SelectPageBottom <<SelectPageBottom>> <Shift-Alt-Down> {SelectPageBottom key}
	SelectPageUp <<SelectPageUp>> <Shift-Prior> {SelectPageUp key}
	SelectPageDown <<SelectPageDown>> <Shift-Next> {SelectPageDown key}
	SelectWordLeft <<SelectWordLeft>> <Shift-Control-Left> {SelectWordLeft key}
	SelectWordRight <<SelectWordRight>> <Shift-Control-Right> {SelectWordRight key}
	SelectParaUp <<SelectParaUp>> <Shift-Control-Up> {SelectParaUp key}
	SelectParaDown <<SelectParaDown>> <Shift-Control-Down> {SelectParaDown key}
}
Classy::configkey Scroll {
	ScrollPageUp <<ScrollPageUp>> {<Control-Prior> <Control-Alt-Up>} {ScrollPageUp key}
	ScrollPageDown <<ScrollPageDown>> {<Control-Next> <Control-Alt-Down>} {ScrollPageDown key}
}
Classy::configkey Table {
	TableUp <<TableUp>> <Control-Up> {Table Up key}
	TableDown <<TableDown>> <Control-Down> {Table Down key}
	TableLeft <<TableLeft>> <Control-Left> {Table Left key}
	TableRight <<TableRight>> <Control-Right> {Table Right key}
	SelectTableUp <<SelectTableUp>> <Control-Shift-Up> {Table Up Select key}
	SelectTableDown <<SelectTableDown>> <Control-Shift-Down> {Table Down Select key}
	SelectTableLeft <<SelectTableLeft>> <Control-Shift-Left> {Table Left Select key}
	SelectTableRight <<SelectTableRight>> <Control-Shift-Right> {Table Right Select key}
}
