#ClassyTcl menu configuration file

Classy::configmenu Classy::Editor {menu used in the ClassyTcl Editor} {
menu "File" {
	action "Open file" {eval %W load [Classy::selectfile -title Open -selectmode persistent]} <<Load>>
	action "Open next" {%W loadnext} <<LoadNext>>
	action "Save" {%W save} <<Save>>
	action "Save as" {%W savedialog} <<SaveAs>>
	action "Reopen" {%W reopenlist} <<Reopen>>
	action "New editor" {edit newfile} <<New>>
	action "Command window" {Classy::cmd} <<Cmd>>
	separator
	action "Customise application" {Classy::Config dialog} <<Customise>>
	action "Customise menu" {Classy::Config config menu Classy::Editor} <<CustomiseMenu>>
	action "Customise toolbar" {Classy::Config config tool Classy::Editor} <<CustomiseTool>>
	action "Close" "%W close" <<Close>>
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
	action "Matching Brackets" "%W matchingbrackets" Alt-bracketleft <<MatchingBrackets>>
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
	action "Editor" {Classy::help classy_editor} <<Help>>
	separator
	action "ClassyTcl" {Classy::help ClassyTcl} <<HelpClassyTcl>>
	action "Help" {Classy::help help} <<HelpHelp>>
}
}

Classy::configmenu Classy::Help {menu used in the ClassyTcl help system} {
menu "File" {
	action "Reload" {%W reload} <<Reload>>
	action "Edit" {%W edit} <<Edit>>
	action "Save source" {%W save [Classy::selectfile]} <<Save>>
	action "Save as text" {%W save [Classy::selectfile] text} <<SaveText>>
	action "Editor" {edit newfile} <<Editor>>
	action "Command window" {Classy::cmd} <<Cmd>>
	separator
	action "Customise application" {Classy::Config dialog} <<Customise>>
	action "Customise menu" {Classy::Config config menu Classy::Help} <<CustomiseMenu>>
	action "Customise toolbar" {Classy::Config config tool Classy::Help} <<CustomiseTool>>
	action "Close" {destroy %W} <<Close>>
}
activemenu "Contents" {%W getcontentsmenu}
menu "Go" {
	action "Back" {%W back} <<Back>>
	action "Forward" {%W forward} C-r <<Forward>>
	action "History" {%W historymenu} <<History>>
}
activemenu "General" {%W getgeneralmenu}
}

Classy::configmenu Classy::Filer {menu used in the ClassyTcl Filer} {
menu "Selection" {
	action "Delete" {%W deletefiles sel} <<Delete>>
	action "Rename" {%W renamebox} C-r <<Rename>>
	action "Copy" {%W copybox} <<Copy>>
}
menu "Options" {
	check "Hidden files" {-variable [privatevar %W hidden] -onvalue yes -offvalue no -command {%W refresh}} <<HiddenFiles>>
	action "Filter" "%W filterbox" C-f <<Filter>>
	separator
	radio "Sort by extension" {-variable [privatevar %W order] -value extension -command {%W refresh}} <<SortExt>>
	radio "Sort by time" {-variable [privatevar %W order] -value time -command {%W refresh}} <<SortTime>>
	radio "Sort by access" {-variable [privatevar %W order] -value accesstime -command {%W refresh}} <<SortAccess>>
	radio "Sort by size" {-variable [privatevar %W order] -value size -command {%W refresh}} <<SortSize>>
	radio "Unsorted (as on disk)" {-variable [privatevar %W order] -value disk -command {%W refresh}} <<Unsorted>>
	separator
	radio "Normal icons" {-variable [privatevar %W view] -value normal -command {%W redraw}} <<NormalIcons>>
	radio "Small icons" {-variable [privatevar %W view] -value small -command {%W redraw}} <<SmallIcons>>
	radio "Full info" {-variable [privatevar %W view] -value full -command {%W redraw}} <<FullInfo>>
}
}

Classy::configmenu Classy::Builder {menu used in the ClassyTcl Builder} {
menu "File" {
	action "Code dir" {%W configure -dir code} <<CodeDir>>
	action "Configuration dir" {%W configure -dir config} <<ConfDir>>
	action "Help dir" {%W configure -dir help} <<HelpDir>>
	action "Application dir" {%W configure -dir {}} <<AppDir>>
	action "Select dir" {%W configure -dir [Classy::selectfile -default Classy::Builder]} <<Dir>>
	action "Save" {%W save} <<Save>>
	action "Editor" "edit newfile" <<Editor>>
	action "Command window" {Classy::cmd} <<Cmd>>
	separator
	action "Close" {destroy %W} <<Close>>
	action "Exit" {exit} <<Exit>>
}
menu "Add" {
	action "New file" {%W new file} <<newfile>>
	action "New Toplevel" {%W new toplevel} <<newtoplevel>>
	action "New Dialog" {%W new dialog} <<newdialog>>
	action "New Frame" {%W new frame} <<newframe>>
	action "New function" {%W new function} <<newfunction>>
	action "New configuration" {%W new config} <<newfile>>
}
menu "Edit" {
	action "Edit" {%W openendnode [lindex [%W.browse selection] 0]} <<Edit>>
	action "Rename" {%W rename} <<Rename>>
	separator
	action "Copy" {%W copy} <<Copy>>
	action "Cut" {%W cut} <<Cut>>
	action "Delete" {%W delete} <<Delete>>
	action "Paste" {%W paste} <<Paste>>
}
menu "Help" {
	action "Builder" {Classy::help classy_builder} <<Help>>
	separator
	action "ClassyTcl" {Classy::help ClassyTcl} <<HelpClassyTcl>>
	action "Help" {Classy::help help} <<HelpHelp>>
}
}

Classy::configmenu Classy::WindowBuilder {menu used in the ClassyTcl WindowBuilder} {
menu "File" {
	action "Save" {[Classy::WindowBuilder_win %W] save} <<Save>>
	action "Test" {[Classy::WindowBuilder_win %W] test} <<Test>>
	action "Fast test" {[Classy::WindowBuilder_win %W] ftest} <<FastTest>>
	action "Recreate" {[Classy::WindowBuilder_win %W] recreate} <<Recreate>>
	separator
	action "Editor" "edit newfile" <<Editor>>
	action "Command window" {Classy::cmd} <<Cmd>>
	separator
	action "Close" {[Classy::WindowBuilder_win %W] close} <<Close>>
}
menu "Edit" {
	action "Copy" {[Classy::WindowBuilder_win %W] copy} <<Copy>>
	action "Cut" {[Classy::WindowBuilder_win %W] cut} <<Cut>>
	action "Delete" {[Classy::WindowBuilder_win %W] delete} <<Delete>>
	action "Paste" {[Classy::WindowBuilder_win %W] paste} <<Paste>>
	separator
	action "Move up" {[Classy::WindowBuilder_win %W] geometryset up} <<Up>>
	action "Move down" {[Classy::WindowBuilder_win %W] geometryset down} <<Down>>
	action "Move left" {[Classy::WindowBuilder_win %W] geometryset left} <<Left>>
	action "Move right" {[Classy::WindowBuilder_win %W] geometryset right} <<Right>>
	action "Rowspan smaller" {[Classy::WindowBuilder_win %W] geometryset spanup} <<SelectUp>>
	action "Rowspan larger" {[Classy::WindowBuilder_win %W] geometryset spandown} <<SelectDown>>
	action "Columnspan smaller" {[Classy::WindowBuilder_win %W] geometryset spanleft} <<SelectLeft>>
	action "Columnspan larger" {[Classy::WindowBuilder_win %W] geometryset spanright} <<SelectRight>>
}
menu "Tk" {
	action Frame {[Classy::WindowBuilder_win %W] add frame}
	action Entry {[Classy::WindowBuilder_win %W] add entry}
	action Label {[Classy::WindowBuilder_win %W] add label}
	action Button {[Classy::WindowBuilder_win %W] add button}
	action "Check button" {[Classy::WindowBuilder_win %W] add checkbutton}
	action "Radio button" {[Classy::WindowBuilder_win %W] add radiobutton}
	action Message {[Classy::WindowBuilder_win %W] add message}
	action "Vertical Scrollbar" {[Classy::WindowBuilder_win %W] add scrollbar -orient vertical}
	action "Horizontal Scrollbar" {[Classy::WindowBuilder_win %W] add scrollbar -orient horizontal}
	action Listbox {[Classy::WindowBuilder_win %W] add listbox}
	action Text {[Classy::WindowBuilder_win %W] add text}
	action Canvas {[Classy::WindowBuilder_win %W] add canvas}
	action Scale {[Classy::WindowBuilder_win %W] add scale}
}
menu "ClassyTcl" {
	action "Main Menu" {[Classy::WindowBuilder_win %W] add Classy::DynaMenu}
	action "Toolbar" {%W add Classy::DynaTool}
	action "Entry" {[Classy::WindowBuilder_win %W] add Classy::Entry}
	action "Numerical Entry" {[Classy::WindowBuilder_win %W] add Classy::NumEntry}
	action "ListBox" {[Classy::WindowBuilder_win %W] add Classy::ListBox}
	action "scrolled Text" {[Classy::WindowBuilder_win %W] add Classy::ScrolledText}
	action "Message" {%W add Classy::Message}
	action "Text" {[Classy::WindowBuilder_win %W] add Classy::Text}
	action "Canvas" {[Classy::WindowBuilder_win %W] add Classy::Canvas}
	action "Notebook with tabs" {[Classy::WindowBuilder_win %W] add Classy::NoteBook}
	action "OptionBox" {[Classy::WindowBuilder_win %W] add Classy::OptionBox}
	action "OptionMenu" {[Classy::WindowBuilder_win %W] add Classy::OptionMenu}
	action "Paned" {[Classy::WindowBuilder_win %W] add Classy::Paned}
	action "Progress bar" {[Classy::WindowBuilder_win %W] add Classy::Progress}
	action "Scrolled frame" {[Classy::WindowBuilder_win %W] add Classy::ScrolledFrame}
	action "Table" {[Classy::WindowBuilder_win %W] add Classy::Table}
	action "Fold" {[Classy::WindowBuilder_win %W] add Classy::Fold}
	action "Font select" {[Classy::WindowBuilder_win %W] add button -text "Select font" -command {set font [Classy::getfont]}}
	action "Color select" {[Classy::WindowBuilder_win %W] add button -text "Select color" -command {set color [Classy::getcolor]}}
	action "Tree widget" {[Classy::WindowBuilder_win %W] add Classy::TreeWidget}
	action "Browser" {[Classy::WindowBuilder_win %W] add Classy::Browser}
	action "CmdWidget" {[Classy::WindowBuilder_win %W] add Classy::CmdWidget}
}
menu "Help" {
	action "Window Builder" {Classy::help classy_windowbuilder} <<Help>>
	action "Builder" {Classy::help classy_builder} <<HelpBuilder>>
	separator
	action "ClassyTcl" {Classy::help ClassyTcl} <<HelpClassyTcl>>
	action "Help" {Classy::help help} <<HelpHelp>>
}
}

Classy::configmenu Classy::Dummy {menu used in the Builder as a dummy} {
menu "Menu" {
}
}

Classy::configmenu Classy::Test {menu used for testing} {
	menu "File" {
		action "Open file" {%W insert insert "Open: %W"} <<Load>>
		action "Open next" {%W insert insert "Open next: %W"} <<LoadNext>>
		action "Test" {%W insert insert "Test: %W"} <<Try>>
		menu "Trying" {
			action "Trying" {%W insert insert "submenu: %W"} Alt-d
		}
		action Save {puts save} Save
		radio "Radio try" {-variable test -value try} <<Radio1>>
		radio "Radio try2" {-variable test -value try2} <<Radio2>>
	} Alt-f
	# The find menu
	menu "Find" {
		action "Goto line" {puts "Goto line"} <<Goto>>
		action "Find" {%W insert end find} <<Find>>
		separator
		action "Replace & Find next" {%W insert end replace} <<ReplaceFindNext>>
		check "Search Reopen" {-variable test%W -onvalue yes -offvalue no} <<SearchReopen>>
	}
	action "Test" {%W insert insert "Test: %W"} Alt-t
}

