source tools.tcl
#set ::class::tkhtmllib [file join $::class::dir tkhtml tkhtml-$tcl_platform(os)-$tcl_platform(machine)[info sharedlibextension]]
#load $::class::tkhtmllib
	classyclean
	Classy::HTML .try -yscrollcommand {.vbar set}
	scrollbar .vbar -command {.try yview}
	pack .try -side left -fill both -expand yes
	pack .vbar -side left -fill y
	.try geturl file:[file join $::class::dir html_library-0.3 html help.html]

set object .try
set query {}
set url file:[file join $::class::dir html_library-0.3 html help.html]
set url file:[file join $::class::dir html_library-0.3 html sample.html]
bind .try <2> {%W linkat %x %y}
bind Classy::HTML <2> {%W linkat %x %y}
	.try geturl file:[file join $::class::dir html_library-0.3 html help.html]
	.try geturl file:[file join $::class::dir html_library-0.3 html sample.html]
	.try geturl file:[file join $::class::dir html_library-0.3 html forms.html]
	.try geturl http://www.slashdot.org/

test Classy::HTML {create and configure} {
	classyclean
	Classy::HTML .try -yscrollcommand {.vbar set}
	scrollbar .vbar -command {.try yview}
	pack .try -side left -fill both -expand yes
	pack .vbar -side left -fill y
	.try geturl file:[file join $::class::dir html_library-0.3 html help.html]
} {}

test Classy::help {create and configure} {
	classyclean
	Classy::Help .try
	.try gethelp ClassyTcl
} {}

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
	.try cget -wrap
} {word}

.try bindlink <3> {puts [.try linkat %x %y]}

}
