#ClassyTcl menu configuration file

Classy::configmenu Classy::Editor {menu used in the ClassyTcl Editor} {
menu file "File" {
	action Load "Open file" {eval %W load [Classy::selectfile -title Open -selectmode persistent]}
	action LoadNext "Open next" "%W loadnext"
	action Save "Save" "%W save"
	action SaveAs "Save as" "%W savedialog"
	action Reopen "Reopen" "%W reopenlist"
	action SaveState "Save state" {savestate}
	separator
	action New "New editor" "edit newfile"
	action Cmd "Command window" {Classy::cmd}
	action Configure "Customise application" {Classy::Config dialog}
	action ConfigureMenu "Customise menu" {Classy::Config config menu Classy::Editor}
	action ConfigureTool "Customise toolbar" {Classy::Config config tool Classy::Editor}
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
	action Goto "Goto line" {Classy::InputDialog %W.goto -label "Goto line" -title Goto -buttontext Goto -command {%W gotoline}}
	action Find "Find" "%W finddialog"
	action FindNext "Find next" "%W findsel -forwards"
	action ReplaceFindNext "Replace & Find next" "%W replace-find -forwards"
	action FindPrev "Find prev" "%W findsel -backwards"
	action ReplaceFindPrev "Replace & Find prev" "%W replace-find -backwards"
	check SearchReopen "Search Reopen" {-variable [privatevar %W options(-searchreopen)]}
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
	action SetTabs "Set tab stops" {Classy::InputDialog %W.tabstops -label "Tab stops" -title Tabstops -buttontext Set -command {%W configure -tabs}}
	separator
	action Connect "Connect to" "%W connectto"
	action ExecuteCmd "Execute Tcl command" "%W execute"
	action Format "format" "%W format 76"
}
activemenu macros "Macros" {%W getmacromenu}
activemenu pattern "Pattern" {%W getpatternmenu}
menu help "Help" {
	action Help "Editor" {Classy::help classy_editor}
	separator
	action HelpClassyTcl "ClassyTcl" {Classy::help ClassyTcl}
	action HelpHelp "Help" {Classy::help help}
}
}
