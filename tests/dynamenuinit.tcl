set trydata {
	menu "File" {
		action "Open file" {%W insert insert "Open: %W"} <<Load>>
		action "Open next" {%W insert insert "Open next: %W"} <<LoadNext>>
		action "Test" {%W insert insert "Test: %W"} <<Try>>
		activemenu "Active" {getmenu}
		menu "Trying" {
			action Try "Trying" {%W insert insert "submenu: %W"} <Alt-d>
		}
		action "Save" {puts save} <<Save>>
		radio "Radio try" {-variable test -value try}
		radio "Radio try2" {-variable test -value try2}
	} <Alt-f>
	# The find menu
	menu "Find" {
		action "Goto line" {puts "Goto line"} <<Goto>>
		action "Find" {%W insert end find} <<Find>>
		separator
		action "Replace & Find next" {%W insert end replace} <<ReplaceFindNext>>
		check "Search Reopen" {-variable test%W -onvalue yes -offvalue no} <<SearchReopen>>
	}
	action "Test" {%W insert insert "Test: %W"} <Alt-t>
}

proc testit w {return ok}
proc getmenu {} {
	if {"[Classy::DynaMenu cmdw Test]" == ".t"} {
		return {{
			action "Test1 t" {puts "Test1 t ok"} <Alt-a>
			action "Test2 t" {%W insert end "Test2 t %W"} <Alt-b>
		} Test_active}
	} else {
		return {{
			action "Test1 b" {puts "Test1 b ok"} <Alt-a>
			action "Test2 b" {%W insert end "Test2 b %W"} <Alt-b>
			action "Test3 b" {%W insert end "Test3 b"} <Alt-c>
		} Test_active}
	}
}


