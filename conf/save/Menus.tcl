## Editor {menu used in the ClassyTcl Editor} menu
option add *Classy::Editor.Menu {
menu file "File" {
	action Load "Open file" {eval %W load [Classy::selectfile -title Open -selectmode persistent]}
	action LoadNext "Open next" "%W loadnext"
	action Save "Save" "%W save"
	action SaveAs "Save as" "%W savebox"
	action Reopen "Reopen" "%W reopenlist"
	action Editor "New editor" "edit newfile"
	action Cmd "Command window" {Classy::cmd}
	separator
	action Configure "Customise application" {Classy::Configurator dialog}
	action Quit "Quit" "%W close"
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
	action Execute "Execute Tcl command" "%W execute"
	action Format "format" "%W format 76"
}
activemenu macros "Macros" {%W getmacromenu}
} widgetDefault

## Help {menu used in the ClassyTcl help system} menu
option add *Classy::Help.Menu {
menu file "File" {
	action Reload "Reload" {%W reload}
	action Edit "Edit" {%W edit}
	action Close "Close" {destroy %W}
}
activemenu contents "Contents" {%W getcontents}
menu go "Go" {
	action Back "Back" {%W back}
	action Forward "Forward" {%W forward} C-r
	action History "History" {%W historymenu}
	action HelpWord "search in helptext" "%W search word"
	action HelpGrep "search through all helpfiles" "%W search grep"
	action HelpFile "search a named Helpfile" "%W search file"
}
menu general "General" {
	action HelpHelp "Help on Help" {%W load help}
}
} widgetDefault

## Filer {menu used in the ClassyTcl Filer} menu
option add *Classy::Filer.Menu {
menu sel "Selection" {
	action Delete "Delete" {%W deletefiles sel}
	action Rename "Rename" {%W renamebox} C-r
	action Copy "Copy" {%W copybox}
}
menu option "Options" {
	check HiddenFiles "Hidden files" {-variable [privatevar %W hidden] -onvalue yes -offvalue no -command {%W refresh}}
	action Filter "Filter" "%W filterbox" C-f
	separator
	radio SortExt "Sort by extension" {-variable [privatevar %W order] -value extension -command {%W refresh}}
	radio SortTime "Sort by time" {-variable [privatevar %W order] -value time -command {%W refresh}}
	radio SortAccess "Sort by access" {-variable [privatevar %W order] -value accesstime -command {%W refresh}}
	radio SortSize "Sort by size" {-variable [privatevar %W order] -value size -command {%W refresh}}
	radio Unsorted "Unsorted (as on disk)" {-variable [privatevar %W order] -value disk -command {%W refresh}}
	separator
	radio NormalIcons "Normal icons" {-variable [privatevar %W view] -value normal -command {%W redraw}}
	radio SmallIcons "Small icons" {-variable [privatevar %W view] -value small -command {%W redraw}}
	radio FullInfo "Full info" {-variable [privatevar %W view] -value full -command {%W redraw}}
}
} widgetDefault
