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
catch {set ::Classy::keepbgerror [info body bgerror]}
proc bgerror {err} {
	global errorInfo
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
	::Classy::Dialog .bgerrorDialog -title "Error in Tcl Script" -keepgeometry no -closecommand {
		catch {destroy .bgerrorDialog}
		catch {destroy .bgerrorTrace}
		set ::Classy::error(action) ok
	}
	.bgerrorDialog add ok "OK" {
		catch {destroy .bgerrorDialog}
		catch {destroy .bgerrorTrace}
		set ::Classy::error(action) ok
	} default 
	.bgerrorDialog add break "Break" {
		catch {destroy .bgerrorDialog}
		catch {destroy .bgerrorTrace}
		set ::Classy::error(action) break
	}
	.bgerrorDialog add trace "Stack Trace" {
		catch {destroy .bgerrorDialog}
		catch {destroy .bgerrorTrace}

		set w [edit $::Classy::error(file)]
		wm title $w "Stack Trace"
			
		# Be sure to release any grabs that might be present on the
		# screen, since they could make it impossible for the user
		# to interact with the stack trace.
	
		if {[grab current .] != ""} {
			grab release [grab current .]
		}
		set ::Classy::error(action) ok
	}
    # 2. Fill the top part with bitmap and message (use the option
    # database for -wraplength so that it can be overridden by
    # the caller).

	set w .bgerrorDialog.options
    label $w.msg -justify left -text "Error $err" -wraplength 3i
#    catch {$w.msg configure -font \
#		-Adobe-Times-Medium-R-Normal--*-180-*-*-*-*-*-*
#    }
    pack $w.msg -side right -expand 1 -fill both -padx 3m -pady 3m
	label $w.bitmap -bitmap error
	pack $w.bitmap -side left -padx 3m -pady 3m

	focus .bgerrorDialog
	tkwait window .bgerrorDialog
	return -code $::Classy::error(action)
}

