package require pkgtools
namespace import pkgtools::*

if ![info exists classy_tools] {
set classy_tools 1
set auto_path [concat [file dir [pwd]] $auto_path]
if {[catch {package require Class}]} {
	lappend auto_path [file dir [file dir [pwd]]]
	package require Class
}

proc clean {} {
	catch {Base destroy}
	catch {::Test destroy}
	catch {::Try destroy}
	catch {::try destroy}
	catch {::.try destroy}
	catch {rename ::Test {}}
	catch {rename ::try {}}
	catch {rename ::.try {}}
	Class subclass Base
}

proc display {e} {
	puts $e
}
}
