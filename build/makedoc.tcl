#!/bin/sh
# the next line restarts using tclsh \
exec tclsh8.0 "$0" "$@"

cd [file dir [info script]]
cd ..
package require Extral
Extral::makedoc [lsort [glob lib/*.tcl]] help/ "ClassyTcl basics"

set f [open help/index.html w]
puts $f {
<HEAD>
<TITLE>ClassyTcl basics</TITLE>
</HEAD>
<BODY>
<h1>ClassyTcl index</h1>
<ul>
<li><a href="ClassyTcl.html">Introduction</a>
<li><a href="classy_object_system.html">ClassyTcl object system</a>
<li><a href="Class.html">Class</a>
</ul>
</body>
}
close $f