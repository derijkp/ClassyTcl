#
# ClassyTcl Widgets 
# ----------------- Peter De Rijk
#
# HTML
# ----------------------------------------------------------------------
#doc HTML title {
#HTML
#} descr {
# subclass of <a href="../basic/Widget.html">Widget</a><br>
# creates a HTML display widget. The widget is based on the
# html_library by Stephan Uhler, with a few modifications.
#}
#doc {HTML options} h2 {
#	HTML specific options
#}
#doc {HTML command} h2 {
#	HTML specific methods
#}
# Next is to get the attention of auto_mkindex
if 0 {
proc ::Classy::HTML {} {}
proc HTML {} {}
}
catch {Classy::HTML destroy}

source [file join $::class::dir html_library-0.3 html_library.tcl]
proc ::html::link_callback {win href} {
	$win geturl $href
}
proc ::html::set_image {win handle src} {
	$win _setimage $handle $src
}
array set ::html::events {
	Enter	{-borderwidth 2 -relief raised }
	Leave	{-borderwidth 2 -relief flat }
	<Action>		{-borderwidth 2 -relief sunken}
	<ButtonRelease-Action>	{-borderwidth 2 -relief raised}
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::HTML
Classy::export HTML {}

Classy::HTML classmethod init {args} {
	super text
	::html::init_win $object

	# REM Initialise options and variables
	# ------------------------------------
	private $object control options
	setprivate $object options(-url) "file:/"
	setprivate $object tempfile [tempfile]
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

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::HTML chainallmethods {$object} text

#doc {HTML command geturl} cmd {
#pathname geturl url
#} descr {
#}
Classy::HTML method geturl {url} {
	private $object control options

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
		if {"$currentbase" == "$base"} {
			if {"$currentfragment" != "$fragment"} {
				::html::goto $object $url
				if [info exists control(direction)] {
					unset control(direction)
				} else {
					lappend control(back) $options(-url)
					set control(forward) ""
					lunshift control(history) $options(-url)
					set control(history) [lrange $control(history) 0 50]
				}
				set options(-url) $url
			}
			return $url
		}
	}

	# get the html data according to protocol
	# ---------------------------------------
	if ![regexp {^([^:]*)://([^/]+)(/.*)$} $url dummy protocol host file] {
		error "error in url format of \"$url\""
	}
	switch $protocol {
		http {
			package require http
			set id [http::geturl $base]
			set html [http::data $id]
			array set state [set [set id](meta)]
			set type $state(Content-Type)
			unset id
			if {"$type" != "text/html"} {
				set html "<pre>$html</pre>"
			}
		}
		file {
			set html [readfile $file]
			if [regexp {html?$} $file] {
				set type text/html
			} else {
				set html "<pre>$html</pre>"
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

	# adjust controls
	# ---------------
	if [info exists control(reload)] {
		unset control(reload)
	} elseif [info exists control(direction)] {
		unset control(direction)
	} else {
		lappend control(back) $options(-url)
		set control(forward) ""
		lunshift control(history) $options(-url)
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
	::html::parse_html $html [list ::html::render $object]
}

#doc {HTML command reload} cmd {
#pathname reload 
#} descr {
#}
Classy::HTML method reload {} {
	private $object options control
	set control(reload) 1
	$object geturl $options(-url)
}


#doc {HTML command back} cmd {
#pathname back 
#} descr {
#}
Classy::HTML method back {} {
	private $object options control
	if {"$control(back)" == ""} return
	set url [lpop control(back)]
	lappend control(forward) $options(-url)
	set control(direction) 1
	$object geturl $url
}


#doc {HTML command forward} cmd {
#pathname forward 
#} descr {
#}
Classy::HTML method forward {} {
	private $object options control
	if {"$control(forward)" == ""} return
	set url [lpop control(forward)]
	lappend control(back) $options(-url)
	set control(direction) 1
	$object geturl $url
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
	regsub {/[^/]*$} $options(-url) {} dir
	switch -regexp $url {
		^# {
			set url $options(-url)$url
		}
		{^(http|ftp|file|data)://} {
		}
		{^(http|ftp|file|data):/} {
			regsub {^(http|ftp|file|data):/} $url {\0/localhost/} url
		}
		^/ {
			set url $dir$url
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
#	private $object options
#	set options(-url) ""
#	::html::set_state $object -stop 1	;# stop rendering previous page if busy
#	update idletasks
#	::html::reset_win $object
#	::html::parse_html $html [list ::html::render $object]
}
