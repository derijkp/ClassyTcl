#!/bin/sh
# the next line restarts using wish \
exec tclsh8.0 "$0" ${1+"$@"}
#
#if {[llength $argv] == 0} {
#	set targetdir [file dir [pwd]]
#} else {
#	set targetdir [lindex $argv 0]
#}

cd [file dir [info script]]
if ![file exists [file join lib Class.tcl]] {
	puts stderr "ERROR: makedist.tcl must be run in the ClassyTcl developement directory"
	exit 1
}
# $Format: "\tset currentversion 0.$ProjectMajorVersion$"$
	set currentversion 0.3
# $Format: "\tset patchLevel $ProjectMinorVersion$"$
	set patchLevel 21

lappend auto_path [pwd]
package require Extral
package require -exact Class $currentversion

set targetdir ClassyTcl-$tcl_platform(os)-$currentversion.$patchLevel
set len [llength $argv]
if {($len != 1)&&($len != 2)} {
	puts stderr "ERROR: format is \"makedist.tcl targetdirectory ?bindir?\""
	puts stderr "Using this command a ClassyTcl package will the be build"
	puts stderr "in the subdirectory \"$targetdir\" of the targetdirtory"
	exit 1
}


set targetdir [file join [lindex $argv 0] $targetdir]
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
	Classy::auto_mkindex lib *.tcl
	Classy::auto_mkindex widgets *.tcl
	Classy::auto_mkindex widgets/Builder *.tcl
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
			eval file copy -force [glob [file join $targetdir conf themes Windows]] \
				[list [file join $targetdir conf conf.values]]
		}
		default {
			file mkdir [file join $targetdir visitors]
			file copy visitors/visrotate.so [file join $targetdir visitors]
			eval file copy -force [glob [file join $targetdir conf themes Linux]] \
				[list [file join $targetdir conf conf.values]]
			foreach file [glob [file join $targetdir bin *]] {
				catch {file attributes $file -permissions 0755}
			}
			catch {file attributes [file join $targetdir template template.tcl] -permissions 0755}
		}
	}
	if {$len == 2} {
		set bindir [lindex  $argv 1]
		catch {file delete $bindir/cbuild}
		exec ln -s $targetdir/bin/cbuild.tcl $bindir/cbuild
		catch {file delete $bindir/convert0.1_to_0.2}
		exec ln -s $targetdir/bin/convert0.1_to_0.2.tcl $bindir/convert0.1_to_0.2
		foreach base {ccalc ccenter cdraw cedit cfiles ctester} {
			catch {file delete $bindir/$base}
			exec ln -s $targetdir/apps/$base/$base.tcl $bindir/$base
		}
	}
exit
