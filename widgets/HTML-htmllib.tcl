#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# HTML-htmllib
# ----------------------------------------------------------------------

if ![string_equal [Classy::HTML private type] htmllib] break
source [file join $::class::dir html_library-0.3 html_library.tcl]

#proc ::html::link_callback {win href} {
#	private $win options
#	if {"$options(-errorcommand)" == ""} {
#		$win geturl $href
#	} else {
#		if [catch {$win geturl $href} result] {
#			eval $options(-errorcommand) {$href $result}
#		}
#	}
#}

proc ::html::submit_form {win param query} {
	regexp {method="([^"]+)"} $param temp method
	regexp {action="([^"]+)"} $param temp action
	if {"$method"=="post"} {
		$win geturl $action [eval ::http::formatQuery $query]
	} else {
		error "unsupported method \"$method\""
	}
}

proc ::html::set_image {win handle src} {
	$win _setimage $handle $src
}

catch {unset ::html::events}
array set ::html::events {
	Enter	{-borderwidth 2 -relief raised }
	Leave	{-borderwidth 2 -relief flat }
	<Action>		{-borderwidth 2 -relief sunken}
	<Action-ButtonRelease>	{-borderwidth 2 -relief raised}
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::HTML method init {args} {
	super init text
	bindtags $object [list $object Classy::HTML . all]
	set w [Classy::window $object]
	$w tag bind link <<Action>> {%W geturl [%W linkat %x %y]}

	::html::init_win $object

	# REM Initialise options and variables
	# ------------------------------------
	private $object control options
	setprivate $object options(-url) "file:/"
	setprivate $object tempfile [tempfile]
	setprivate $object currentquery ""
	set control(history) ""
	set control(forward) ""
	set control(back) ""
	set options(-update) [set html::${object}(S_update)]
	set options(-tab) [set html::${object}(S_tab)]
	set options(-unknown) [set html::${object}(S_unknown)]
	set options(-size) [set html::${object}(S_adjust_size)]
	set options(-symbols) [set html::${object}(S_symbols)]


	# REM Create bindings
	# --------------------

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::HTML chainoptions {$object}

#doc {HTML options -url} option {-url url Url} descr {
#}
Classy::HTML addoption -url {url Url {}} {
	set value [$object geturl $value]
}

#doc {HTML options -indent} option {-indent indent Indent} descr {
#}
Classy::HTML addoption -indent {indent Indent {}} {
	html::set_indent $object $value
}

#doc {HTML options -update} option {-update update Update} descr {
#}
Classy::HTML addoption -update {update Update {}} {
	html::set_state $object -update $value
}

#doc {HTML options -tab} option {-tab tab Tab} descr {
#}
Classy::HTML addoption -tab {tab Tab {}} {
	html::set_state $object -tab $value
}

#doc {HTML options -unknown} option {-unknown unknown Unknown} descr {
#}
Classy::HTML addoption -unknown {unknown Unknown {}} {
	html::set_state $object -unknown $value
}

#doc {HTML options -size} option {-size size Size} descr {
#}
Classy::HTML addoption -size {size Size {}} {
	html::set_state $object -size $value
}

#doc {HTML options -symbols} option {-symbols symbols Symbols} descr {
#}
Classy::HTML addoption -symbols {symbols Symbols {}} {
	html::set_state $object -symbols $value
}

#doc {HTML options -tagmap} option {-tagmap tagMap TagMap} descr {
#}
Classy::HTML addoption -tagmap {tagMap TagMap {}}

#doc {HTML options -insertmap} option {-insertmap insertMap InsertMap} descr {
#}
Classy::HTML addoption -insertmap {insertMap InsertMap {}}

#doc {HTML options -errorcommand} option {-errorcommand errorCommand Command} descr {
#}
Classy::HTML addoption -errorcommand {errorCommand Command {}}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::HTML chainallmethods {$object} text

#doc {HTML command geturl} cmd {
#pathname geturl url
#} descr {
#}
Classy::HTML method geturl {url {query {}}} {
	private $object control options currentquery html
	Classy::busy add $object
	set url [$object fullurl $url]

	# if it is the same url as the current, don't reload
	# --------------------------------------------------
	set base $url
	set currentbase $options(-url)
	set fragment ""
	set currentfragment ""
	regexp {([^#]*)#(.+)} $url dummy base fragment
	regexp {([^#]*)#(.+)} $options(-url) dummy currentbase currentfragment
	if ![info exists control(reload)] {
		if {"$query" == ""} {
			if {"$currentbase" == "$base"} {
				if {"$currentfragment" != "$fragment"} {
					if {"$fragment" != ""} {::html::goto $object $fragment}
					if [info exists control(direction)] {
						unset control(direction)
					} else {
						if {"$query" != ""} {
							set keep [list $options(-url) $currentquery]
						} else {
							set keep $options(-url)
						}
						lappend control(back) $keep
						set control(forward) ""
						list_unshift control(history) $keep
						set control(history) [lrange $control(history) 0 50]
					}
					set options(-url) $url
				}
				set currentquery $query
				return $url
			}
		}
	}

	# get the html data according to protocol
	# ---------------------------------------
	if ![regexp {^([^:]*)://([^/]+)(/.*)$} $url dummy protocol host file] {
		error "error in url format of \"$url\""
	}
	set code [catch {
		switch $protocol {
			http {
				package require http
				if {"$query" == ""} {
					set id [http::geturl $base]
				} else {
					set id [http::geturl $base -query $query]
				}
				set html [http::data $id]
				array set state [set [set id](meta)]
				if [info exists state(Content-Type)] {
					set type [string trimright [string trimleft $state(Content-Type)]]
	#				if {"$type" != "text/html"} {
	#					set html "<pre>$html</pre>"
	#				}
				} else {
					set type text/html
				}
				unset $id
			}
			file {
				if {"$::tcl_platform(platform)" == "windows"} {
					regsub {^/([A-Za-z]:/)} $file {\1} file
				}
				set html [file_read $file]
				if [regexp {html?$} $file] {
					set type text/html
				} else {
	#				set html "<pre>$html</pre>"
				}
			}
			data {
				set html [string range $file 1 end]
				set type text/html
			}
			ftp {
				error "not yet"
			}
			default {
				error "unsupported protocol"
			}
		}
	} result]
	if $code {
		private $object options
		if {"$options(-errorcommand)" == ""} {
			return -code $code $result
		} else {
			set code [catch {eval $options(-errorcommand) {$url $query $result}} result]
			return -code $code $result
		}
	}

	# adjust controls
	# ---------------
	if [info exists control(reload)] {
		unset control(reload)
	} elseif [info exists control(direction)] {
		unset control(direction)
	} else {
		if {"$query" != ""} {
			set keep [list $options(-url) $currentquery]
		} else {
			set keep $options(-url)
		}
		lappend control(back) $keep
		set control(forward) ""
		list_unshift control(history) $keep
		set control(history) [lrange $control(history) 0 50]
	}
	set options(-url) $url

	# render
	# ------
	::html::set_state $object -stop 1	;# stop rendering previous page if busy
	update idletasks
	::html::reset_win $object
	if {$fragment != ""} {
		::html::goto $object $fragment
	}
	# These are Defined in HTML 2.0
	catch {unset ::html::tag_map}
	array set ::html::tag_map {
		b      {weight bold}
		blockquote	{style italic indent 1 Trindent rindent}
		bq		{style italic indent 1 Trindent rindent}
		cite   {style italic}
		code   {family courier}
		dfn    {style italic}	
		dir    {indent 1}
		dl     {indent 1}
		em     {style i}
		h1     {size 24 weight bold style italic}
		h2     {size 18 weight bold style italic}		
		h3     {size 14 weight bold}	
		h4     {size 14 weight bold}
		h5     {size 12 weight bold}
		h6     {size 12 style italic}
		i      {style italic}
		kbd    {family courier weight bold}
		menu     {indent 1}
		ol     {indent 1}
		pre    {fill 0 family courier Tnowrap nowrap}
		samp   {family courier}		
		strong {weight bold}		
		tt     {family courier}
		u	 {Tunderline underline}
		ul     {indent 1}
		var    {style italic}	
	}

	# These are in common(?) use, but not defined in html2.0

	array set ::html::tag_map {
		center {Tcenter center}
		strike {Tstrike strike}
		u	   {Tunderline underline}
	}
	set html::tag_map(hmstart) {
		family times   weight normal   style roman   size 12
		Tcenter ""   Tlink ""   Tnowrap ""   Tunderline ""   list list
		fill 1   indent "" counter 0 adjust 0
	}
	array set ::html::tag_map $options(-tagmap)

	array set ::html::insert_map {
		blockquote "\n\n" /blockquote "\n"
		br	"\n"
		dd	"\n" /dd	"\n"
		dl	"\n" /dl	"\n"
		dt	"\n"
		form "\n"	/form "\n"
		h1	"\n\n"	/h1	"\n"
		h2	"\n\n"	/h2	"\n"
		h3	"\n\n"	/h3	"\n"
		h4	"\n"	/h4	"\n"
		h5	"\n"	/h5	"\n"
		h6	"\n"	/h6	"\n"
		li   "\n"
		/dir "\n"
		/ul "\n"
		/ol "\n"
		/menu "\n"
		p	"\n\n"
		pre "\n"	/pre "\n"
	}
	array set ::html::insert_map $options(-insertmap)
	if {"$type" == "text/html"} {
		::html::parse_html $html [list ::html::render $object]
	} else {
		[Classy::window $object] insert end $html
	}
	set currentquery $query
	Classy::busy remove $object
}

#doc {HTML command reload} cmd {
#pathname reload 
#} descr {
#}
Classy::HTML method reload {} {
	private $object options control currentquery
	set control(reload) 1
	$object geturl $options(-url) $currentquery
}

#doc {HTML command back} cmd {
#pathname back 
#} descr {
#}
Classy::HTML method back {} {
	private $object options control
	if {"$control(back)" == ""} return
	set url [list_pop control(back)]
	lappend control(forward) $options(-url)
	set control(direction) 1
	if ![regexp ^data: $url] {
		set query [lindex $url 1]
		set url [lindex $url 0]
	} else {
		set query {}
	}
	$object geturl $url $query
}

#doc {HTML command forward} cmd {
#pathname forward 
#} descr {
#}
Classy::HTML method forward {} {
	private $object options control
	if {"$control(forward)" == ""} return
	set url [list_pop control(forward)]
	lappend control(back) $options(-url)
	set control(direction) 1
	if ![regexp ^data: $url] {
		set query [lindex $url 1]
		set url [lindex $url 0]
	} else {
		set query {}
	}
	$object geturl $url $query
}

#doc {HTML command history} cmd {
#pathname history
#} descr {
#}
Classy::HTML method history {} {
	private $object control
	return $control(history)
}

Classy::HTML method _setimage {handle url} {
	private $object tempfile

	set url [$object fullurl $url]

	# if doesn't exists yet, load
	# ---------------------------
	set image ::html::image_$url
	if {"[info commands $image]" == ""} {
		# get the html data according to protocol
		# ---------------------------------------
		if ![regexp {^([^:]*)://([^/]+)(/.*)$} $url dummy protocol host file] {
			error "error in url format of \"$url\""
		}
		set type photo
		if {[file extension $image] == ".bmp"} {set type bitmap}
		switch $protocol {
			http {
				package require http
				set id [http::geturl $url]
				set data [http::data $id]
				unset $id
				set f [open $tempfile w]
				puts -nonewline $f $data
				close $f
				image create $type $image -file $tempfile
				file delete $tempfile
			}
			file {
				image create $type $image -file $file
			}
			ftp {
				error "not yet"
			}
			default {
				error "unsupported protocol"
			}
		}
	}
	::html::got_image $handle $image
}

#doc {HTML command fullurl} cmd {
#pathname fullurl url
#} descr {
#}
Classy::HTML method fullurl {url} {
	private $object options

	# make url fully specified
	# ------------------------
	if [regexp ^# $url] {
		set base $options(-url)
		regexp {([^#]*)#(.+)} $options(-url) dummy base fragment
		return $base$url
	}
	regsub {/[^/]*$} $options(-url) {} dir
	switch -regexp $url {
		{^(http|ftp|file|data)://} {
		}
		{^(http|ftp|file|data):/} {
			regsub {^(http|ftp|file|data):/} $url {\0/localhost/} url
		}
		{^file:} {
			regsub {^file:} $url {file://localhost/} url
		}
		^/ {
			regexp {^([^:]*)://([^/]+)(/.*)$} $options(-url) dummy protocol host file
			set url $protocol://$host$url
		}
		default {
			set url $dir/$url
		}
	}
	return $url
}

#doc {HTML command load} cmd {
#pathname load file
#} descr {
#}
Classy::HTML method load {file} {
	if {"[file pathtype $file]" != "absolute"} {
		set file [file join [pwd] $file]
	}
	$object geturl file:$file
}

#doc {HTML command set} cmd {
#pathname set html
#} descr {
#}
Classy::HTML method set {html} {
	$object geturl "data://localhost/$html"
}

#doc {HTML command linkat} cmd {
#pathname linkat x y
#} descr {
# returns the link (href) at position x,y.
# This is used in comination with bindlink to change the behaviour
# of links.
#} example {
# objectName bindlink <3> {puts [%W linkat %x %y]}
#}
Classy::HTML method linkat {x y} {
	set tags [$object tag names @$x,$y]
	set link [lindex $tags [lsearch -glob $tags L:*]]
	regsub L: $link {} link
#	return [$object fullurl $link]
	return $link
}

#doc {HTML command bindlink} cmd {
#pathname bindlink ?event? ?sequence?
#} descr {
# binds action to a certain event happening on a link
#} example {
# objectName bindlink <3> {puts [%W linkat %x %y]}
#}
Classy::HTML method bindlink {args} {
	eval [Classy::window $object] tag bind link $args
}

