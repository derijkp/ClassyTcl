package require Extral

proc convert {c} {
#	regsub -all {Peos__} $c {Classy} try	
	regsub -all {Classymethod Classy([^ ]+) } $c {\1 method } c	
	regsub -all {{object}} $c {{}} c
	regsub -all "\{object " $c "\{" try	
set replace {
#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# \1
# ----------------------------------------------------------------------
# Next is to get the attention of auto_mkindex
if 0 {
proc \1 {} {}
}
catch {\1 destroy}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass \1

\1 method init {\2} }
	regsub "proc Classy(\[^ \]+) \{(.*)\} " $c $replace c

set replace {
# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

\1 chainallmethods {$object} widget

\1 method }
	regsub "\n(\[^\n \]+) method " $c $replace c
	return $c
}

proc converthead {c} {
	set pattern "auto_mkindex\n\[^\n\]+\nproc (\[^ \]+)\[^\n\]+\n\[^\n\]+\n"
	set replace "auto_mkindex\nif 0 \{\nproc Classy::\\1 \{\} \{\}\nproc \\1 \{\} \{\}\n\}\ncatch \{Classy::\\1 destroy\}\n"
	regsub $pattern $c $replace c
	set pattern "Widget subclass (\[^\n\]+)\n"
	set replace "Widget subclass \\1\nClassy::export \\1 \{\}\n"
	regsub $pattern $c $replace c
	return $c
}

proc convertpublic {c} {
	set pattern "public (\[^ \]+) (.+)\n"
	set replace "getoptions \$class \\1 -\\2\n"
	regsub -all $pattern $c $replace c
	return $c
}

proc convertmethodobj {c} {
	set pattern "method (\[^ \]+) \{object "
	set replace "method \\1 \{"
	regsub -all $pattern $c $replace c
	return $c
}

proc convertoptions {c} {
	set pattern "addoption -(\[^ \]+) \{(\[^\{\}\]+)\}"
	set replace "addoption -\\1 \{\\1 \\1 \\2\}"
	regsub -all $pattern $c $replace c
	set pattern "addoption -(\[^ \]+) \{\}"
	set replace "addoption -\\1 \{\\1 \\1 {}\}"
	regsub -all $pattern $c $replace c
	return $c
}

set files [glob *.tcl]
foreach file $files {
	puts $file
	set c [readfile $file]
	set c [convertoptions $c]
	writefile $file $c
}


