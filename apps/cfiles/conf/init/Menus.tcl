#Application menu configuration file

Classy::configmenu MainMenu {Main application menu} {
	menu "File" {
		action "Open file" {error "cannot load \"[Classy::selectfile -title Open -selectmode persistent]\" yet"} <<Load>>
		action "Save" {error "save not implemented yet"} <<Save>>
		action "Save as" {error "save not implemented yet"} <<SaveAs>>
		separator
		action "New editor" {edit newfile} <<Editor>>
		action "Command window" {Classy::cmd} <<Cmd>>
		action "Builder" {Classy::Builder .classy__.builder} <<Builder>>
		action "Customise application" {Classy::Config dialog} <<Configure>>
		action "Customise menu" {Classy::Config config menu MainMenu} <<ConfigureMenu>>
		action "Customise toolbar" {Classy::Config config tool MainTool} <<ConfigureTool>>
		action "Exit" "exit" <<Exit>>
	}
	menu "Edit" {
		action "Cut" {error "cut not implemented yet"} <<Cut>>
		action "Copy" {error "copy not implemented yet"} <<Copy>>
		action "Paste" {error "paste not implemented yet"} <<Paste>>
		action "Undo" {error "undo not implemented yet"} <<Undo>>
		action "Redo" {error "redo not implemented yet"} <<Redo>>
		action "Clear undo buffer" {error "clearundo not implemented yet"} <<ClearUndo>>
	}
	menu "Mode" {
		radio "Row" {-variable status(%W,order) -value row -command {browser_order %W}} <<OrderRow>>
		radio "Column" {-variable status(%W,order) -value column -command {browser_order %W}} <<OrderColumn>>
		radio "List" {-variable status(%W,order) -value list -command {browser_order %W}} <<OrderList>>
		separator
		check "Small images" {-variable status(%W,small) -command {browser_small %W}} <<OrderList>>
		check "Data" {-variable status(%W,data) -command {browser_data %W}} <<OrderList>>
		check "Data under" {-variable status(%W,dataunder) -command {browser_dataunder %W}} <<OrderList>>
		
	}
	menu "Help" {
		action "Application" {Classy::help application} <<Help>>
		separator
		action "ClassyTcl" {Classy::help ClassyTcl} <<HelpClassyTcl>>
		action "Help" {Classy::help help} <<HelpHelp>>
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
	action "Customise application" {Classy::Config dialog} <<Customise>>
	action "Customise menu" {Classy::Config config menu Classy::Editor} <<CustomiseMenu>>
	action "Customise toolbar" {Classy::Config config tool Classy::Editor} <<CustomiseTool>>
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
	action "Test parameters" {[Classy::WindowBuilder_win %W] testparam} <<TestParam>>
	action "Recreate" {[Classy::WindowBuilder_win %W] recreate} <<Recreate>>
	separator
	action "Editor" "edit newfile" <<Editor>>
	action "Command window" {Classy::cmd} <<Cmd>>
	action "Customise application" {Classy::Config dialog} <<Customise>>
	action "Customise menu" {Classy::Config config menu Classy::Editor} <<CustomiseMenu>>
	action "Customise toolbar" {Classy::Config config tool Classy::Editor} <<CustomiseTool>>
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




