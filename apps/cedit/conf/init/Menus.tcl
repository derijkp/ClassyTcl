#ClassyTcl menu configuration file

Classy::configmenu Classy::Editor {menu used in the ClassyTcl Editor} {
menu "File" {
	action "Open file" {eval %W load [Classy::selectfile -title Open -selectmode persistent]} <<Load>>
	action "Open next" "%W loadnext" <<LoadNext>>
	action "Save" "%W save" <<Save>>
	action "Save as" "%W savedialog" <<SaveAs>>
	action "Reopen" "%W reopenlist" <<Reopen>>
	action "Save state" {savestate} <<SaveState>>
	separator
	action "New editor" "edit newfile" <<New>>
	action "Command window" {Classy::cmd} <<Cmd>>
	action "Customise application" {Classy::Config dialog} <<Customise>>
	action "Customise menu" {Classy::Config config menu Classy::Editor} <<CustomiseMenu>>
	action "Customise toolbar" {Classy::Config config tool Classy::Editor} <<CustomiseTool>>
	action "Close" "%W close" <<Close>>
	action "Exit" "exit" <<Exit>>
}
menu "Edit" {
	action "Cut" "%W cut" <<Cut>>
	action "Copy" "%W copy" <<Copy>>
	action "Paste" "%W paste" <<Paste>>
	action "Undo" "%W undo" <<Undo>>
	action "Redo" "%W redo" <<Redo>>
	action "Clear undo buffer" "%W clearundo" <<ClearUndo>>
}
menu "Find" {
	action "Goto line" {Classy::InputDialog %W.goto -label "Goto line" -title Goto -buttontext Goto -command {%W gotoline}} <<Goto>>
	action "Find" "%W finddialog" <<Find>>
	action "Find next" "%W findsel -forwards" <<FindNext>>
	action "Replace & Find next" "%W replace-find -forwards" <<ReplaceFindNext>>
	action "Find prev" "%W findsel -backwards" <<FindPrev>>
	action "Replace & Find prev" "%W replace-find -backwards" <<ReplaceFindPrev>>
	check "Search Reopen" {-variable [privatevar %W options(-searchreopen)]} <<SearchReopen>>
	action "Find Tcl function" "%W findfunction" <<FindFunction>>
}
menu "Select" {
	action "Select all" "%W select all" <<SelectAll>>
	action "Select none" "%W select none" <<SelectNone>>
	action "Matching Brackets" "%W matchingbrackets" <Alt-bracketleft>
	separator
	action "Marker Box" "%W marker select" <<MarkerSelect>>
	action "Marker set" "%W marker set" <<MarkerSet>>
	action "Current Marker" "%W marker current" <<MarkerCurrent>>
	action "Previous Marker" "%W marker previous" <<MarkerPrev>>
}
menu "Tools" {
	action "Indented Return" "%W indentedcr" <<IndentCr>>
	action "Indent in" "%W indent 1" <<IndentIn>>
	action "Indent out" "%W indent -1" <<IndentOut>>
	action "Comment" "%W comment add" <Alt-numbersign>
	action "Remove comment" "%W comment remove" <Control-Alt-numbersign>
	action "Set tab stops" {Classy::InputDialog %W.tabstops -label "Tab stops" -title Tabstops -buttontext Set -command {%W configure -tabs}} <<SetTabs>>
	separator
	action "Connect to" "%W connectto" <<Connect>>
	action "Execute Tcl command" "%W execute" <<ExecuteCmd>>
	action "format" "%W format 76" <<Format>>
}
activemenu "Macros" {%W getmacromenu}
activemenu "Pattern" {%W getpatternmenu}
menu "Help" {
	action "Editor" {Classy::help application} <<Help>>
	separator
	action "ClassyTcl" {Classy::help ClassyTcl} <<HelpClassyTcl>>
	action "Help" {Classy::help classy_help} <<HelpHelp>>
}



}






