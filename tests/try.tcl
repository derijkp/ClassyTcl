source tools.tcl
set object .try
	classyclean
button .b -text break -command {.try geturl file:[file join $::class::dir html_library-0.3 html help.html]}
pack .b -side bottom
	Classy::HTML .try -yscrollcommand {.vbar set}
	scrollbar .vbar -command {.try yview}
	pack .try -side left -fill both -expand yes
	pack .vbar -side left -fill y
	.try geturl file:[file join $::class::dir tkhtml tests page3 index.html]
#	.try geturl file:[file join $::class::dir html_library-0.3 html help.html]


set query {}
set url http://rrna.uia.ac.be/lsu/query/index.html
#	.try geturl http://rrna.uia.ac.be/lsu/query/index.html
	.try geturl http://www.slashdot.org/

set url file:[file join $::class::dir tkhtml tests page1 index.html]
	.try geturl file:[file join $::class::dir tkhtml tests page1 index.html]
	.try geturl file:[file join $::class::dir tkhtml tests page2 index.html]
	.try geturl file:[file join $::class::dir tkhtml tests page3 index.html]
	.try geturl file:[file join $::class::dir tkhtml tests page4 index.html]

	.try geturl file:[file join $::class::dir html_library-0.3 html forms.html]

	.try geturl file:[file join $::class::dir html_library-0.3 html sample.html]
	.try geturl http://www.slashdot.org/

source tools.tcl
test Classy::HTML {create and configure} {
	classyclean
	Classy::HTML .try -yscrollcommand {.vbar set}
	scrollbar .vbar -command {.try yview}
	pack .try -side left -fill both -expand yes
	pack .vbar -side left -fill y
	.try geturl file:[file join $::class::dir html_library-0.3 html help.html]
	.try geturl file:[file join $::class::dir html_library-0.3 html sample.html]
	.try geturl file:[file join $::class::dir html_library-0.3 html forms.html]
} {}

test Classy::help {create and configure} {
	classyclean
	Classy::Help .try
	.try gethelp ClassyTcl
	.try cget -wrap
} {word}

if [Classy::yorn "Do you have a network connection"] {

test Classy::HTML {create and configure} {
	classyclean
	Classy::HTML .try -yscrollcommand {.vbar set}
	scrollbar .vbar -command {.try yview}
	pack .try -side left -fill both -expand yes
	pack .vbar -side left -fill y
	.try geturl http://rrna.uia.ac.be/
	.try cget -wrap
} {word}

test Classy::HTML {create and configure} {
	classyclean
	Classy::HTML .try -yscrollcommand {.vbar set}
	scrollbar .vbar -command {.try yview}
	pack .try -side left -fill both -expand yes
	pack .vbar -side left -fill y
	.try geturl http://rrna.uia.ac.be/lsu/query/index.html
} {}

.try bindlink <3> {puts [.try linkat %x %y]}

test Classy::HTML {tkhtml tests} {
	classyclean
	Classy::HTML .try -yscrollcommand {.vbar set}
	scrollbar .vbar -command {.try yview}
	pack .try -side left -fill both -expand yes
	pack .vbar -side left -fill y
	.try geturl file:[file join $::class::dir tkhtml tests page1 index.html]
	.try geturl file:[file join $::class::dir tkhtml tests page2 index.html]
	.try geturl file:[file join $::class::dir tkhtml tests page3 index.html]
	.try geturl file:[file join $::class::dir tkhtml tests page4 index.html]
} {}

}

testsummarize



