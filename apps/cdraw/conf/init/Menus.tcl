#Application menu configuration file

Classy::configmenu MainMenu {Main application menu} {
	menu "File" {
		action "Open file" {fileload %W} <<Load>>
		action "Save" {filesave %W} <<Save>>
		action "Save as" {saveas %W} <<SaveAs>>
		action "Print" {%W print} <<Print>>
		separator
		action "Clear page" {
			if [Classy::yorn "Are you absolutely sure you want to clear the page (no undo)"] {%W clear}
		} <<Clear>>
		separator
		action "Editor" {edit newfile} <<Editor>>
		action "Command window" {Classy::cmd} <<Cmd>>
		action "Builder" {Classy::Builder .classy__.builder} <<Builder>>
		action "Customise application" {Classy::Config dialog} <<Customise>>
		action "Customise menu" {Classy::Config config menu MainMenu} <<CustomiseMenu>>
		action "Customise toolbar" {Classy::Config config tool MainTool} <<CustomiseTool>>
		action "Exit" "exit" <<Exit>>
	}
	menu "Edit" {
		action "Group" {group %W} <<Group>>
		action "Ungroup" {ungroup %W} <<UnGroup>>
		separator
		action "Raise object" {raise_objects %W _sel} <<Raise>>
		action "Lower object" {lower_objects %W _sel} <<Lower>>
		action "Raise to top" {top_objects %W _sel} <<Top>>
		action "Lower to bottom" {bottom_objects %W _sel} <<Bottom>>
		separator
		action "Delete" {delete %W} <<Delete>>
		action "Cut" {%W cut _sel} <<Cut>>
		action "Copy" {%W copy _sel} <<Copy>>
		action "Paste" {%W paste} <<Paste>>
		action "Undo" {%W undo} <<Undo>>
		action "Redo" {%W redo} <<Redo>>
		action "Clear undo buffer" {%W undo clear} <<ClearUndo>>
	}
	menu "Windows" {
		action "Zoom" {catch {destroy .zoomdialog};zoomdialog} <<ZoomDialog>>
		action "Configure objects" {catch {destroy .configwindow};configwindow -startw %W} <<ConfigObjects>>
	}
	menu "Mode" {
		action "Select" {select_start %W} <<Select>>
		check "Rotate" {-variable status(%W,rotate) -command {rotate_set %W}} <<Rotate>>
		action "Zoom" {zoom_start %W} <<Zoom>>
		action "Text" {text_start %W} <<Text>>
		action "Line" {line_start %W} <<Line>>
		action "Polygon" {polygon_start %W} <<Polygon>>
		action "Rectangle" {rectangle_start %W} <<Rectangle>>
		action "Oval" {oval_start %W} <<Oval>>
		action "Arc" {arc_start %W} <<Arc>>
	}
	menu "Help" {
		action "Application" {Classy::help application} <<Help>>
		separator
		action "ClassyTcl" {Classy::help ClassyTcl} <<HelpClassyTcl>>
		action "Help" {Classy::help classy_help} <<HelpHelp>>
	}









}










