#Functions

proc save w {
global status
if ![info exists status(file)] {
	set status(file) [Classy::savefile -title "Save as"]
}
$w save $status(file)
}

proc load w {
global status
set status(file) [Classy::selectfile -title Open -selectmode persistent]
$w load $status(file)

}

proc saveas {} {
global status
set status(file) [Classy::savefile -title Save as -selectmode persistent]
$w save $status(file)

}










