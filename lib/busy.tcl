#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# busy command
# ----------------------------------------------------------------------
if 0 {
proc busy {} {}
}
proc ::Classy::busy {{action {add}} args} {
	switch $action {
		remove {
			if ![info exists ::Classy::busy] return
			if {"$args"==""} {
				set args .
			}
			foreach p $args {
				if {"$p"=="."} {
					set pattern $p*,c
				} else {
					set pattern $p.*,c
				}
				set list [lsort -decreasing [array names ::Classy::busy $pattern]]
				lappend list $p,c
				foreach w $list {
					regexp {^(.*),c$} $w temp w
					if [info exists ::Classy::busy($w,c)] {
						if [winfo exists $w] {
							$w configure -cursor $::Classy::busy($w,c)
						}
						unset ::Classy::busy($w,c)
					}
					if [info exists ::Classy::busy($w,bt)] {
						if [winfo exists $w] {
							bindtags $w $::Classy::busy($w,bt)
						}
						unset ::Classy::busy($w,bt)
					}
				}
				if [info exists ::Classy::busy([winfo parent $p],c)] {
					if {"[$p cget -cursor]"==""} {
						$p configure -cursor arrow
						set ::Classy::busy($p,c) {}
					}
				}
			}
			update idletasks
		}
		default {
			update idletasks
			if [regexp {^\.} $action] {lunshift args $action;set action add}
			if {"$action"!="add"} {
				error "Unkown action $action: should be one of add, remove status"
			}
			if {"$args"==""} {
				set args .
			}
			foreach p $args {
				if {"$p"=="."} {
					set pattern $p*
				} else {
					set pattern $p.*
					if ![info exists ::Classy::busy($p,c)] {
						set ::Classy::busy($p,c) [$p cget -cursor]
						$p configure -cursor watch
					}
					if ![info exists ::Classy::busy($p,bt)] {
						set ::Classy::busy($p,bt) [bindtags $p]
						bindtags $p none
					}
				}
				foreach w [lsort [info commands $pattern]] {
					if ![info exists ::Classy::busy($p,c)] {
						set ::Classy::busy($w,c) [$w cget -cursor]
						$w configure -cursor watch
					}
					if ![info exists ::Classy::busy($p,bt)] {
						set ::Classy::busy($w,bt) [bindtags $w]
						bindtags $w none
					}
				}
			}
			update idletasks
		}
	}
}

Classy::export busy {}
