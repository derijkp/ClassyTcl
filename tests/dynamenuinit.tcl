set trydata {
	menu file "File" {
		action Load "Open file" {%W insert insert "Open: %W"}
		action LoadNext "Open next" {%W insert insert "Open next: %W"}
		action Try "Test" {%W insert insert "Test: %W"}
		activemenu active "Active" {getmenu}
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

proc testit w {return ok}
proc getmenu {} {
	if {"[Classy::DynaMenu cmdw Test]" == ".t"} {
		return {Test_active {
			action Test1 "Test1 t" {puts "Test1 t ok"} Alt-a
			action Test2 "Test2 t" {%W insert end "Test2 t %W"} Alt-b
		}}
	} else {
		return {Test_active {
			action Test1 "Test1 b" {puts "Test1 b ok"} Alt-a
			action Test2 "Test2 b" {%W insert end "Test2 b %W"} Alt-b
			action Test3 "Test3 b" {%W insert end "Test3 b"} Alt-c
		}}
	}
}

