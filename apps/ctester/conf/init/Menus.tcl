#Application menu configuration file

Classy::configmenu MainMenu {Main application menu} {
	menu file "File" {
		action Load "Open file" {error "cannot load \"[Classy::selectfile -title Open -selectmode persistent]\" yet"}
		action Save "Save" {error "save not implemented yet"}
		action SaveAs "Save as" {error "save not implemented yet"}
		separator
		action Editor "New editor" {edit newfile}
		action Cmd "Command window" {Classy::cmd}
		action Builder "Builder" {Classy::Builder .classy__.builder}
		action Configure "Customise application" {Classy::Config dialog}
		action ConfigureMenu "Customise menu" {Classy::Config config menu MainMenu}
		action ConfigureTool "Customise toolbar" {Classy::Config config tool MainTool}
		action Exit "Exit" "exit"
	}
	menu edit "Edit" {
		action Cut "Cut" {error "cut not implemented yet"}
		action Copy "Copy" {error "copy not implemented yet"}
		action Paste "Paste" {error "paste not implemented yet"}
		action Undo "Undo" {error "undo not implemented yet"}
		action Redo "Redo" {error "redo not implemented yet"}
		action ClearUndo "Clear undo buffer" {error "clearundo not implemented yet"}
	}
	menu help "Help" {
		action Help "Application" {Classy::help application}
		separator
		action HelpClassyTcl "ClassyTcl" {Classy::help ClassyTcl}
		action HelpHelp "Help" {Classy::help help}
	}

}

