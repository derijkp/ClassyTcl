wish4
source init.tcl
puts stdout test
destroy .try
itcl_unload ColorEntry
ColorEntry .try -label Test -value yellow -command {puts stdout [.try get]}
pack .try -fill x
.try configure -font -*-Times-*
.try configure -labelfont -*-Times-*
puts stdout test
destroy .try
itcl_unload ColorHSV
ColorHSV .try -command {puts stdout [.try get]}
pack .try -fill both -expand yes
destroy .try
itcl_unload ColorRGB
ColorRGB .try -command {puts stdout [.try get]}
pack .try -fill both -expand yes
destroy .try
itcl_unload OptionBox
OptionBox .try -label Try -variable try
pack .try -fill x
.try add t1 "T 1" {puts stdout t1}
.try add t2 "T 2" {puts stdout t2}
.try add t3 "T 3" {puts stdout t3}
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
exit
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

destroy .try .t
itcl_unload MainMenu
MainMenu .try
pack .try -side top -fill x -anchor e
text .tAAAAAAAAA
pack .t -side bottom -expand yes -fill both
.try addmenu file File
.try addmenu try Try
.try addaction file "Try 1" {puts stdout "Try 1"} A-1
.try addseparator file
.try addaction file "Try 2" {puts stdout "Try 2"} A-2
.try addsubmenu try.try Try
.try addaction try.try "Try 3" {puts stdout "Try 3"} A-3
.try bindto .t
bind .t <Button-3> {.try popup %X %Y}

destroy .try
itcl_unload Editor
source init.tcl
Editor .try
pack .try -fill both -expand yes


