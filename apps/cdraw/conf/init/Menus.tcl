#Application menu configuration file

Classy::configmenu MainMenu {Main application menu} {
	menu file "File" {
		action Load "Open file" {load}
		action Save "Save" {save}
		action SaveAs "Save as" {saveas}
		separator
		action Clear "Clear page" {%W delete all}
		separator
		action Editor "Editor" {edit newfile}
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
		action Undo "Undo" {%W undo}
		action Redo "Redo" {%W redo}
		action ClearUndo "Clear undo buffer" {%W undo clear}
	}
	menu mode "Mode" {
		action Text "Text" {text_start %W}
		action Line "Line" {line_start %W}
	}
	menu help "Help" {
		action Help "Application" {Classy::help application}
		separator
		action HelpClassyTcl "ClassyTcl" {Classy::help ClassyTcl}
		action HelpHelp "Help" {Classy::help help}
	}






}








