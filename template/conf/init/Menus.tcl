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
	menu "Help" {
		action "Application" {Classy::help application} <<Help>>
		separator
		action "ClassyTcl" {Classy::help ClassyTcl} <<HelpClassyTcl>>
		action "Help" {Classy::help help} <<HelpHelp>>
	}

}

