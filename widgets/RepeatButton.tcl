#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# Classy::RepeatButton
# ----------------------------------------------------------------------
#doc RepeatButton title {
#RepeatButton
#} descr {
# creates a widget which behaves like a Tk button, but which repeats the 
# associated command when the user keeps the button pressed.
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc RepeatButton {} {}
}

bind Classy::RepeatButton <Any-Leave> {catch {unset ::Classy::repeat(%W)}}
bind Classy::RepeatButton <Any-ButtonRelease> {catch {unset ::Classy::repeat(%W)}}
bind Classy::RepeatButton <<Action>> {set ::Classy::repeat(%W) on ; ::Classy::repeat %W}
bind Classy::RepeatButton <<Action-ButtonPress>> {set ::Classy::repeat(%W) on ; ::Classy::repeat %W}

proc ::Classy::RepeatButton {object args} {
	eval {button $object} $args
	bindtags $object "Classy::RepeatButton [bindtags $object]"
}
Classy::export RepeatButton {}

proc ::Classy::repeat {w} {
	if ![info exists ::Classy::repeat($w)] {return}
	$w invoke
	after 100 [list ::Classy::repeat $w]
}

