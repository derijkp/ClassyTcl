#
# ####  #####  ####   #### 
# #   # #     #    # # 
# ####  ####  #    #  #### 
# #     #     #    #      # 
# #     #####  ####   ####  Peter De Rijk
#
# New error handling
# ----------------------------------------------------------------------
#auto_load Classy::dialog
#auto_load busy
if {"[option get . bgerror Bgerror]" == "Classy"} {

auto_load bgerror
namespace eval Tk {}
if {"[info commands ::Tk::bgerror]" == ""} {
	rename bgerror ::Tk::bgerror
}

proc bgerror {err} {
	global errorInfo
	set ::class::errorInfo $errorInfo
	set ::class::error $err
	foreach grab [grab current .] {
		grab release $grab
	}
	if ![info exists ::Classy::error(file)] {
		set ::Classy::error(file) [tempfile get]
	}
	set f [open $::Classy::error(file) w]
	puts $f $errorInfo
	close $f
	::Classy::busy remove
	::Classy::msg {}
	set info $errorInfo
	catch {destroy .bgerrorDialog}
	set ::Classy::error(action) ok
	if [catch {
		::Classy::Dialog .bgerrorDialog -title "Error in Tcl Script" -keepgeometry no
	}] {
		::Tk::bgerror $err
		return
	}
	.bgerrorDialog add ok "OK" {
		set ::Classy::error(action) ok
	} default 
	.bgerrorDialog add break "Break" {
		set ::Classy::error(action) break
	}
	.bgerrorDialog add trace "Stack Trace" {
		if [catch {
			set w [edit $::Classy::error(file)]
			$w.editor.edit set [readfile $::Classy::error(file)]
			$w.editor.edit textchanged 0
			wm title $w "Stack Trace"
		}] {
			Tk::bgtrace $info
		}
			
		# Be sure to release any grabs that might be present on the
		# screen, since they could make it impossible for the user
		# to interact with the stack trace.
	
		if {[grab current .] != ""} {
			grab release [grab current .]
		}
		set ::Classy::error(action) ok
	}
	.bgerrorDialog persistent set {}
    # 2. Fill the top part with bitmap and message (use the option
    # database for -wraplength so that it can be overridden by
    # the caller).
	set w .bgerrorDialog.options
    label $w.msg -justify left -text "Error $err" -wraplength 3i
    pack $w.msg -side right -expand 1 -fill both -padx 3m -pady 3m
	label $w.bitmap -bitmap error
	pack $w.bitmap -side left -padx 3m -pady 3m
	focus .bgerrorDialog
	tkwait window .bgerrorDialog
	return -code $::Classy::error(action)
}

proc ::Tk::bgtrace info {
	global tcl_platform
    set w .bgerrorTrace
    catch {destroy $w}
    toplevel $w -class ErrorTrace
    wm minsize $w 1 1
    wm title $w "Stack Trace for Error"
    wm iconname $w "Stack Trace"
    button $w.ok -text OK -command "destroy $w" -default active
    if {$tcl_platform(platform) == "macintosh"} {
      text $w.text -relief flat -bd 2 -highlightthickness 0 -setgrid true  -yscrollcommand "$w.scroll set" -width 60 -height 20
    } else {
      text $w.text -relief sunken -bd 2 -yscrollcommand "$w.scroll set"  -setgrid true -width 60 -height 20
    }
    scrollbar $w.scroll -relief sunken -command "$w.text yview"
    pack $w.ok -side bottom -padx 3m -pady 2m
    pack $w.scroll -side right -fill y
    pack $w.text -side left -expand yes -fill both
    $w.text insert 0.0 $info
    $w.text mark set insert 0.0
    bind $w <Return> "destroy $w"
    bind $w.text <Return> "destroy $w; break"
    # Center the window on the screen.
    wm withdraw $w
    update idletasks
    set x [expr [winfo screenwidth $w]/2 - [winfo reqwidth $w]/2  - [winfo vrootx [winfo parent $w]]]
    set y [expr [winfo screenheight $w]/2 - [winfo reqheight $w]/2  - [winfo vrooty [winfo parent $w]]]
    wm geom $w +$x+$y
    wm deiconify $w
}

}
