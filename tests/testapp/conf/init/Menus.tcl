#Application menu configuration file

Classy::configmenu MainMenu {Main application menu} {
	menu file "File" {
		action Load "Open file" {error "cannot load \"[Classy::selectfile -title Open -selectmode persistent]\" yet"}
		action Save "Save" {error "save not implemented yet"}
		action SaveAs "Save as" {error "save not implemented yet"}
		action Editor "New editor" {edit newfile}
		action Cmd "Command window" {Classy::cmd}
		action Builder "Builder" {Classy::Builder .classy__builder}
		separator
		action Configure "Customise application" {Classy::Configurator dialog}
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
	}
}
