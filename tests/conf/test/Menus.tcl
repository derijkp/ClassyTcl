#ClassyTcl menu configuration file

Classy::configmenu Classy::Editor {menu used in the ClassyTcl Editor} {
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
	action Close "Close" "%W close"
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
	action SetTabs "Set tab stops" {Classy::InputBox %W.tabstops -label "Tab stops" -title Tabstops -buttontext Set -command {%W configure -tabs [%W.tabstops get]}}
	separator
	action Connect "Connect to" "%W connectto"
	action ExecuteCmd "Execute Tcl command" "%W execute"
	action Format "format" "%W format 76"
}
activemenu macros "Macros" {%W getmacromenu}
activemenu pattern "Pattern" {%W getpatternmenu}
}

Classy::configmenu Classy::Help {menu used in the ClassyTcl help system} {
menu file "File" {
	action Reload "Reload" {%W reload}
	action Edit "Edit" {%W edit}
	action Save "Save source" {%W save [Classy::selectfile]}
	action SaveText "Save as text" {%W save [Classy::selectfile] text}
	action Configure "Configure" {Configurator dialog}
	separator
	action Close "Close" {destroy %W}
}
activemenu contents "Contents" {%W getcontentsmenu}
menu go "Go" {
	action Back "Back" {%W back}
	action Forward "Forward" {%W forward} C-r
	action History "History" {%W historymenu}
}
activemenu general "General" {%W getgeneralmenu}
}

Classy::configmenu Classy::Filer {menu used in the ClassyTcl Filer} {
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
}

Classy::configmenu Classy::Builder {menu used in the ClassyTcl Builder} {
menu sel "File" {
	action New "New" {%W new}
	action Save "Save" {%W save}
	action Delete "Delete" {%W delete}
	action Close "Close" {%W destroy}
}
menu option "Windows" {
	action AddLabel "Add Label" {%W add label}
	action AddEntry "Add Entry" {%W add entry}
	action AddText "Add Text" {%W add text}
	action AddFrame "Add Frame" {%W add frame}
}
action Test "Test" {%W test}
}

Classy::configmenu Classy::WindowBuilder {menu used in the ClassyTcl WindowBuilder} {
menu sel "File" {
	action New "New" {%W new}
	action Save "Save" {%W save}
	action Delete "Delete" {%W delete}
	action Close "Close" {%W close}
}
menu option "Windows" {
	action AddLabel "Add Label" {%W add label}
	action AddEntry "Add Entry" {%W add entry}
	action AddText "Add Text" {%W add text}
	action AddFrame "Add Frame" {%W add frame}
}
action Test "Test" {%W test}
}


