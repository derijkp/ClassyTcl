## Editor {menu used in the ClassyTcl Editor} menu
Classy::setoption *Classy::Editor.Menu {
menu file "File" {
	action Load "Open file" {eval %W load [Classy::selectfile -title Open -selectmode persistent]}
	action LoadNext "Open next" "%W loadnext"
	action Save "Save" "%W save"
	action SaveAs "Save as" "%W savebox"
	action Reopen "Reopen" "%W reopenlist"
	action Editor "New editor" "edit newfile"
	action Cmd "Command window" {Classy::cmd}
	separator
	action SaveState "Save state" {savestate}
	action Configure "Customise application" {Classy::Configurator dialog}
	action Close "Close" "%W close"
	action Exit "Exit" "exit"
}
menu edit "Edit" {
	action Cut "Cut" "%W cut"
	action Copy "Copy" "%W copy"
	action Paste "Paste" "%W paste"
	action Undo "Undo" "%W undo"
	action Redo "Redo" "%W redo"
	action ClearUndo "Clear undo buffer" "%W clearundo"
}
menu find "Find" {
	action Goto "Goto line" {Classy::InputBox %W.goto -label "Goto line" -title Goto -buttontext Goto -command {%W gotoline [%W.goto get]}}
	action Find "Find" "%W finddialog"
	action FindNext "Find next" "%W findsel -forwards"
	action ReplaceFindNext "Replace & Find next" "%W replace-find -forwards"
	action FindPrev "Find prev" "%W findsel -backwards"
	action ReplaceFindPrev "Replace & Find prev" "%W replace-find -backwards"
	check SearchReopen "Search Reopen" {-variable [privatevar %W searchreopen]}
	action FindFunction "Find Tcl function" "%W findfunction"
}
menu select "Select" {
	action SelectAll "Select all" "%W select all"
	action SelectNone "Select none" "%W select none"
	action MatchingBrackets "Matching Brackets" "%W matchingbrackets" Alt-bracketleft
	separator
	action MarkerSelect "Marker Box" "%W marker select"
	action MarkerSet "Marker set" "%W marker set"
	action MarkerCurrent "Current Marker" "%W marker current"
	action MarkerPrev "Previous Marker" "%W marker previous"
}
menu tools "Tools" {
	action IndentCr "Indented Return" "%W indentedcr"
	action IndentIn "Indent in" "%W indent 1"
	action IndentOut "Indent out" "%W indent -1"
	action Comment "Comment" "%W comment add" Alt-numbersign
	action DelComment "Remove comment" "%W comment remove" Control-Alt-numbersign
	action SetTabs "Set tab stops" {Classy::InputBox %W.tabstops -label "Tab stops" -title Tabstops -buttontext Set -command {%W configure -tabs [%W.tabstops get]}}
	separator
	action Connect "Connect to" "%W connectto"
	action ExecuteCmd "Execute Tcl command" "%W execute"
	action Format "format" "%W format 76"
}
activemenu macros "Macros" {%W getmacromenu}
activemenu pattern "Pattern" {%W getpatternmenu}
menu help "Help" {
}
}
