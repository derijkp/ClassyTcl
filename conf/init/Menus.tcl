#ClassyTcl menu configuration file

Classy::configmenu Classy::Editor {menu used in the ClassyTcl Editor} {
menu file "File" {
	action Load "Open file" {eval %W load [Classy::selectfile -title Open -selectmode persistent]}
	action LoadNext "Open next" "%W loadnext"
	action Save "Save" "%W save"
	action SaveAs "Save as" "%W savedialog"
	action Reopen "Reopen" "%W reopenlist"
	action Editor "New editor" "edit newfile"
	action Cmd "Command window" {Classy::cmd}
	separator
	action Configure "Customise application" {Classy::Config dialog}
	action ConfigureMenu "Customise menu" {Classy::Config config menu Classy::Editor}
	action ConfigureTool "Customise toolbar" {Classy::Config config tool Classy::Editor}
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
	action DefaultDir "Code dir" {%W configure -dir code}
	action DefaultDir "Configuration dir" {%W configure -dir config}
	action DefaultDir "Help dir" {%W configure -dir help}
	action DefaultDir "Application dir" {%W configure -dir {}}
	action Dir "Select dir" {%W configure -dir [Classy::selectfile -default Classy::Builder]}
	action Save "Save" {%W save}
	separator
	action Close "Close" {destroy %W}
	action Exit "Exit" {exit}
}
menu add "Add" {
	action newfile "New file" {%W new file}
	action newtoplevel "New Toplevel" {%W new toplevel}
	action newdialog "New Dialog" {%W new dialog}
	action newframe "New Frame" {%W new frame}
	action newfunction "New function" {%W new function}
	action newfile "New configuration" {%W new config}
}
menu edit "Edit" {
	action Edit "Edit" {%W openendnode [lindex [%W.browse selection] 0]}
	action Rename "Rename" {%W rename}
	separator
	action Copy "Copy" {%W copy}
	action Cut "Cut" {%W cut}
	action Delete "Delete" {%W delete}
	action Paste "Paste" {%W paste}
}
menu help "Help" {
	action Help "Builder" {Classy::help classy_builder}
	separator
	action HelpClassyTcl "ClassyTcl" {Classy::help ClassyTcl}
	action HelpHelp "Help" {Classy::help help}
}
}

Classy::configmenu Classy::WindowBuilder {menu used in the ClassyTcl WindowBuilder} {
menu sel "File" {
	action New "New" {[Classy::WindowBuilder_win %W] new}
	action Save "Save" {[Classy::WindowBuilder_win %W] save}
	action Delete "Delete" {[Classy::WindowBuilder_win %W] delete}
	action Editor "New editor" "edit newfile"
	action Cmd "Command window" {Classy::cmd}
	separator
	action Close "Close" {[Classy::WindowBuilder_win %W] close}
}
menu edit "Edit" {
	action Copy "Copy" {[Classy::WindowBuilder_win %W] copy}
	action Cut "Cut" {[Classy::WindowBuilder_win %W] cut}
	action Delete "Delete" {[Classy::WindowBuilder_win %W] delete}
	action Paste "Paste" {[Classy::WindowBuilder_win %W] paste}
	separator
	action Up "Move up" {[Classy::WindowBuilder_win %W] geometryset up}
	action Down "Move down" {[Classy::WindowBuilder_win %W] geometryset down}
	action Left "Move left" {[Classy::WindowBuilder_win %W] geometryset left}
	action Right "Move right" {[Classy::WindowBuilder_win %W] geometryset right}
	action SelectUp "Rowspan smaller" {[Classy::WindowBuilder_win %W] geometryset spanup}
	action SelectDown "Rowspan larger" {[Classy::WindowBuilder_win %W] geometryset spandown}
	action SelectLeft "Columnspan smaller" {[Classy::WindowBuilder_win %W] geometryset spanleft}
	action SelectRight "Columnspan larger" {[Classy::WindowBuilder_win %W] geometryset spanright}
}
menu tk "Tk" {
	action AddFrame Frame {[Classy::WindowBuilder_win %W] add frame}
	action AddEntry Entry {[Classy::WindowBuilder_win %W] add entry}
	action AddLabel Label {[Classy::WindowBuilder_win %W] add label}
	action AddButton Button {[Classy::WindowBuilder_win %W] add button}
	action AddCheckbutton {Check button} {[Classy::WindowBuilder_win %W] add checkbutton}
	action AddRadiobutton {Radio button} {[Classy::WindowBuilder_win %W] add radiobutton}
	action AddMessage Message {[Classy::WindowBuilder_win %W] add message}
	action AddVScroll "Vertical Scrollbar" {[Classy::WindowBuilder_win %W] add scrollbar -orient vertical}
	action AddHScroll "Horizontal Scrollbar" {[Classy::WindowBuilder_win %W] add scrollbar -orient horizontal}
	action AddListbox Listbox {[Classy::WindowBuilder_win %W] add listbox}
	action AddText Text {[Classy::WindowBuilder_win %W] add text}
	action AddCanvas Canvas {[Classy::WindowBuilder_win %W] add canvas}
	action AddScale Scale {[Classy::WindowBuilder_win %W] add scale}
}
menu classytcl "ClassyTcl" {
	action AddClassy::dynamenu {Main Menu} {[Classy::WindowBuilder_win %W] add Classy::DynaMenu}
	action AddClassy::dynatool {Toolbar} {%W add Classy::DynaTool}
	action AddClassy::entry {Entry} {[Classy::WindowBuilder_win %W] add Classy::Entry}
	action AddClassy::numentry {Numerical Entry} {[Classy::WindowBuilder_win %W] add Classy::NumEntry}
	action AddClassy::listbox {ListBox} {[Classy::WindowBuilder_win %W] add Classy::ListBox}
	action AddClassy::scrolledtext {scrolled Text} {[Classy::WindowBuilder_win %W] add Classy::ScrolledText}
	action AddClassy::message "Message" {%W add Classy::Message}
	action AddClassy::text {Text} {[Classy::WindowBuilder_win %W] add Classy::Text}
	action AddClassy::canvas {Canvas} {[Classy::WindowBuilder_win %W] add Classy::Canvas}
	action AddClassy::notebook {Notebook with tabs} {[Classy::WindowBuilder_win %W] add Classy::NoteBook}
	action AddClassy::optionbox {OptionBox} {[Classy::WindowBuilder_win %W] add Classy::OptionBox}
	action AddClassy::optionmenu {OptionMenu} {[Classy::WindowBuilder_win %W] add Classy::OptionMenu}
	action AddClassy::paned {Paned} {[Classy::WindowBuilder_win %W] add Classy::Paned}
	action AddClassy::progress {Progress bar} {[Classy::WindowBuilder_win %W] add Classy::Progress}
	action AddClassy::scrolledframe {Scrolled frame} {[Classy::WindowBuilder_win %W] add Classy::ScrolledFrame}
	action AddClassy::table {Table} {[Classy::WindowBuilder_win %W] add Classy::Table}
	action AddClassy::fold {Fold} {[Classy::WindowBuilder_win %W] add Classy::Fold}
	action AddClassy::fontselect {Font select} {[Classy::WindowBuilder_win %W] add button -text "Select font" -command {set font [Classy::getfont]}}
	action AddClassy::colorselect {Color select} {[Classy::WindowBuilder_win %W] add button -text "Select color" -command {set color [Classy::getcolor]}}
	action AddClassy::treewidget {Tree widget} {[Classy::WindowBuilder_win %W] add Classy::TreeWidget}
	action AddClassy::browser {Browser} {[Classy::WindowBuilder_win %W] add Classy::Browser}
}
menu help "Help" {
	action Help "Window Builder" {Classy::help classy_windowbuilder}
	action HelpBuilder "Builder" {Classy::help classy_builder}
	separator
	action HelpClassyTcl "ClassyTcl" {Classy::help ClassyTcl}
	action HelpHelp "Help" {Classy::help help}
}
}

Classy::configmenu Classy::Dummy {menu used in the Builder as a dummy} {
menu sel "Menu" {
}
}

Classy::configmenu Classy::Test {menu used for testing} {
	menu file "File" {
		action Load "Open file" {%W insert insert "Open: %W"}
		action LoadNext "Open next" {%W insert insert "Open next: %W"}
		action Try "Test" {%W insert insert "Test: %W"}
		menu trying "Trying" {
			action Try "Trying" {%W insert insert "submenu: %W"} Alt-d
		}
		action Save Save {puts save}
		radio Radio1 "Radio try" {-variable test -value try}
		radio Radio2 "Radio try2" {-variable test -value try2}
	} Alt-f
	# The find menu
	menu find "Find" {
		action Goto "Goto line" {puts "Goto line"}
		action Find "Find" {%W insert end find}
		separator
		action ReplaceFindNext "Replace & Find next" {%W insert end replace}
		check SearchReopen "Search Reopen" {-variable test%W -onvalue yes -offvalue no}
	}
	action Trytop "Test" {%W insert insert "Test: %W"} Alt-t
}

