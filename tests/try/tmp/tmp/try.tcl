catch {destroy .try}
source classes/PeosDialog.tcl
source classes/SaveBox.tcl
Peos__SaveBox .try -savecommand {puts stdout}
.try set try.txt

source filer.tcl
wm deiconify .
catch {destroy .try}
source /home/peter/work/peos/classes/FilerWindow.tcl
Peos__FilerWindow .try -dir /home/peter/work/peos/try
pack .try -fill both -expand yes
.try configure -hidden yes
.try configure -view full -dist {70 70 40 20 15}

catch {destroy .t} ; text .t ; pack .t
d&d__addreceiver .t savebox {
    set w [lindex $data 0]
    set file [lindex $data 1]
    regexp {/([^/]+)$} $file temp file
    $w set newdir/$file
    $w invoke
}

destroy .try
itcl_unload ColorEntry
ColorEntry .try -label Test -value yellow -command {puts stdout [.try get]}
pack .try -fill x
.try configure -font -*-Times-*
.try configure -labelfont -*-Times-*

destroy .try
itcl_unload ColorHSV
ColorHSV .try -command {puts stdout [.try get]}
pack .try -fill both -expand yes

destroy .try
itcl_unload ColorRGB
ColorRGB .try -command {puts stdout [.try get]}
pack .try -fill both -expand yes

catch {destroy .try}
source classes/OptionBox.tcl
Peos__OptionBox .try -label Try -variable try -orient vertical
pack .try -fill x
.try add t1 "T 1"
.try add t2 "T 2"
.try add t3 "T 3"

catch {destroy .try}
Peos__FileBox .try -default try -title load -buttontext Load\
                   -actioncommand "puts \[.try get\];destroy .try"

destroy .try
eval itcl_unload [itcl_info classes *]
NoteBook .try
pack .try -fill both -expand yes
text .try.t1
.try.t1 insert end "try"
button .try.t2 -text "Yes" -command "puts stdout Yes"
.try manage t1 Text
.try manage t2 Button
.try select t1

destroy .try
eval itcl_unload [itcl_info classes *]
ColorSelect .try -command {puts stdout [.try get]} -value white
pack .try -fill both -expand yes

wish4
source init.tcl 

destroy .try
itcl_unload EntryScale
EntryScale .try -label Test\
    -from 1 -to 100 -value 10
pack .try -fill y -expand yes

catch {destroy .try .t}
catch {delete class PopupMenu}
Peos__PopupMenu .try
text .t
pack .t -side bottom -expand yes -fill both
.try addmenu file File A-f
.try addmenu try Try
.try.file addaction "Try 1" {puts stdout "Try 1"} A-1
.try.file addseparator
.try.file addaction "Try 2" {puts stdout "Try 2"} A-2
.try.try addmenu try Try
.try.try.try addaction "Try 3" {puts stdout "Try 3"} A-3
.try addcheck "Try check" var -onvalue on -offvalue off -accelerator "A-\["
.try bindto .t

namespace try {
catch {destroy .try .t}
menu .try
menu .try.file
menu .try.try
menu .try.try.try
text .t
pack .t -side bottom -expand yes -fill both
bind .t <Button-3> {tk_popup .try %X %Y 1}
.try add cascade -menu .try.file -label File
.try add cascade -menu .try.try -label Try
.try.file add command -label "Try 1" -command {puts stdout "Try 1"}
.try.file add separator
.try.file add command -label "Try 2" -command {puts stdout "Try 2"}
.try.try add cascade -label Try -menu .try.try.try
.try.try.try add command -label "Try 3" -command {puts stdout "Try 3"}
set w [info context]::.try
uplevel $w {add check -label "Try check" -onvalue on -offvalue off} \
         -variable var
}
eval [winfo command .try] entryconfigure 3

catch {destroy .try}
source classes/DefaultMenu.tcl
Peos__DefaultMenu .try try
pack .try
.try add hello

wm geometry . 250x70
source classes/PeosEntry.tcl
destroy .try
Peos__Entry .try -label Try -constraint {^[0-9]*$}\
                            -command {puts ok}\
                            -default try
pack .try -fill x -expand yes

catch {destroy .try}
source classes/Editor.tcl
source classes/PeosEntry.tcl
source classes/PeosDialog.tcl
source classes/OptionBox.tcl
Peos__Editor .try
pack .try -fill both -expand yes
wm iconify . ; wm deiconify . ; wm geometry . 60x25+348+50
.try load try/init.txt try/a.tcl try/temp
.try configure -font fixed

itcl_unload HTMLEdit
HTMLEdit .t
wm geometry . 60x25+348+50 ; wm iconify . ; wm deiconify .
pack .t -fill both -expand yes
.t HTMLload /home/peter/tcl/html_library-0.1/html/sample.html
 
.t HTMLload try.html
.t HTMLload /home/peter/tcl/tcltk-man-html/contents.html
.t HTMLload /info/howto/HOWTO-INDEX.html
.t HTMLload /info/howto/XFree86-HOWTO.html

image create photo test -file $peos_icondir/file_txt.gif
destroy .try
itcl_unload SaveBox
SaveBox .try -savecommand {puts stdout } -icon test -value NewFile

catch {destroy .try}
source classes/PeosDialog.tcl
Peos__Dialog .try -help try
.try add b1 Btn1 {puts stdout btn1} default
.try add b2 Btn2 {puts stdout btn2}

Peos__DefaultsHandler try
try add tc hello 2
try add tc try 3
try get tc hello

set this .;set findwhat try 
catch {destroy .find}
set w .find
Peos__Dialog $w -title Find
set what "\[wexec $w.options.what get\] "
$w add forw Forward "$this find $what -forwards" default
$w add backw Backward "$this find $what -backwards"

Peos__Entry $w.options.what -label Find
frame $w.options.frame
Peos__OptionBox $w.options.type -label "Type" -orient vertical
$w.options.type add exact Exact "$this configure -searchtype exact"
$w.options.type add regexp Regexp "$this configure -searchtype regexp"
Peos__OptionBox $w.options.case -label "Case" -orient vertical
$w.options.case add nocase "No case" "$this configure -searchcase nocase"
$w.options.case add case "Case sensitive" "$this configure -searchcase case"
pack $w.options.what -fill x
pack $w.options.frame -fill x
pack $w.options.type -in $w.options.frame -side left -fill x -expand yes
pack $w.options.case -in $w.options.frame -side right -fill x -expand yes
$w.options.what set try


set this .;set findwhat try 
catch {destroy .find}
set w .find
PeosDialog $w -title Find
set what "\[wexec $w.options.what get\] "
$w add forw Forward "$this find $what -forwards" default
$w add backw Backward "$this find $what -backwards"

PeosEntry $w.options.what -label Find
frame $w.options.frame
OptionBox $w.options.type -label "Type" -orient vertical
$w.options.type add exact Exact "$this configure -searchtype exact"
$w.options.type add regexp Regexp "$this configure -searchtype regexp"
OptionBox $w.options.case -label "Case" -orient vertical
$w.options.case add nocase "No case" "$this configure -searchcase nocase"
$w.options.case add case "Case sensitive" "$this configure -searchcase case"
pack $w.options.what -fill x
pack $w.options.frame -fill x
pack $w.options.type -in $w.options.frame -side left -fill x -expand yes
pack $w.options.case -in $w.options.frame -side right -fill x -expand yes

catch {destroy .t} ; text .t ; pack .t
catch {destroy .t2} ; toplevel .t2
source dragdrop.tcl
d&d__addreceiver .t mem_indirect:txt {.t insert insert [send $from $data]}
d&d__addreceiver .t mem_direct:txt {.t insert insert $data}
}
d&d__startdrag $iconpool(file:txt) {
    mem_direct:txt {Hello World}
    mem_indirect:txt {puts ok;set temp "[tk appname]:Hello World"}
    scratchfile:txt {puts stdout txt}
    scratchfile:rtxt {puts stdout rtxt}
}








