#!/bin/sh
# the next line restarts using wish \
exec tclsh8.0 "$0" ${1+"$@"}
#

if {[llength $argv] == 0} {
	set targetdir [file dir [pwd]]
} else {
	set targetdir [lindex $argv 0]
}

# $Format: "\tset version 0.$ProjectMajorVersion$"$
	set version 0.2
# $Format: "\tset minorversion $ProjectMinorVersion$"$
	set minorversion 1

set targetdir [file join $targetdir ClassyTcl-$tcl_platform(os)-$version.$minorversion]
puts "Building binary distribution in $targetdir"

proc clean {filemode dirmode dir} {
	if [catch {glob [file join $dir *]} files] return
	foreach file $files {
		if [regexp {~$} $file] {
			file delete $file
		} elseif [regexp {.save$} $file] {
			file delete $file
		} elseif [regexp "[info sharedlibextension]\$" $file] {
		} elseif [file isdirectory $file] {
			catch {file attributes $file -permissions $dirmode}
			clean $filemode $dirmode $file
		} else {
			catch {file attributes $file -permissions $filemode}
		}
	}
}

# Main Program
# ---------------------------------------------------------
	if [file exists $targetdir] {
		error "Target build directory $targetdir exists"
	}
	file mkdir $targetdir
	auto_mkindex lib *.tcl
	auto_mkindex widgets *.tcl
	auto_mkindex widgets/Builder *.tcl
	file copy apps bin conf dialogs help html_library-0.3 lib patches template widgets $targetdir
	file copy README pkgIndex.tcl $targetdir
	if [catch {file copy classy[info sharedlibextension] $targetdir}] {
		puts stderr "Warning, no compiled version available"
	}
	catch {file copy classywin[info sharedlibextension] $targetdir}
	catch {file attributes [file join $targetdir *[info sharedlibextension]] -permissions 0755}
	clean 0644 0755 $targetdir
	catch {file delete [file join $targetdir apps cdraw large.cld]}
	switch $tcl_platform(platform) {
		windows {
			file mkdir [file join $targetdir visitors]
			file copy visitors/visexport.dll visitors/visrotate.dll [file join $targetdir visitors]
			eval file copy -force [glob [file join $targetdir conf opt Windows *.tcl]] \
				[list [file join $targetdir conf init]]
		}
		default {
			file mkdir [file join $targetdir visitors]
			file copy visitors/visrotate.so [file join $targetdir visitors]
			eval file copy -force [glob [file join $targetdir conf opt Linux *.tcl]] \
				[list [file join $targetdir conf init]]
			foreach file [glob [file join $targetdir bin *]] {
				file attributes $file -permissions 0755
			}
			file attributes [file join $targetdir template template.tcl] -permissions 0755
		}
	}
exit


