#  Tkhtml.tcl by Tim Trainor
#  A network-enabled demo of D. Richard Hipp's html widget, based on his hv.tcl
#  local file viewer.
#  Although this script offers only very basic browser functionality,
#  it features progressive rendering, and asynchronous image loading (using
#  a crude caching scheme)
#  NOTE:
#  This demo is unix-specific, although it can easily be ported to other platforms.
#  tkhtml.so is expected to be found in the current directory
#  the Img package is highly recommended, but not required.
#  still very buggy, so use at your own risk !

wm title . {HTML Widget Demo}
wm iconname . {TkHTML}

load [file join [pwd] tkhtml.so] Tkhtml
package require http 1.0
catch {package require Img}

image create photo biggray -data {
    R0lGODdhPAA+APAAALi4uAAAACwAAAAAPAA+AAACQISPqcvtD6OctNqLs968+w+G4kiW5omm
    6sq27gvH8kzX9o3n+s73/g8MCofEovGITCqXzKbzCY1Kp9Sq9YrNFgsAO///
}

set redirect 0

pack [entry .e -bg white] -fill x -padx 5 -pady 5
bind .e <Return> enterUrl
frame .h
pack .h -side top -fill both -expand 1
html .h.h \
  -yscrollcommand {.h.vsb set} \
  -xscrollcommand {.f2.hsb set} \
  -padx 5 \
  -pady 9 \
  -cursor left_ptr \
  -formcommand FormCmd \
  -imagecommand ImageCmd \
  -scriptcommand ScriptCmd \
  -relief sunken -tablerelief flat -background grey

.h.h token handler body bodyHandler

bind .h.h.x <1> {HrefBinding %x %y}
bind .h.h.x <Motion> {looklinks %x %y}
pack .h.h -side left -fill both -expand 1
scrollbar .h.vsb -orient vertical -command {.h.h yview}
pack .h.vsb -side left -fill y
frame .f2
pack .f2 -side top -fill x
frame .f2.sp -width [winfo reqwidth .h.vsb] -bd 2 -relief raised
pack .f2.sp -side right -fill y
scrollbar .f2.hsb -orient horizontal -command {.h.h xview}
pack .f2.hsb -side top -fill x
pack [label .status -anchor w -textvariable STATUS -relief sunken] -side bottom -fill x

proc Clear {} {
  global Images
  .h.h clear
  .h.h config -background grey
  foreach img [array names Images] {
    image delete $img
  }
  catch {unset Images}
}

proc getUrl {url} {
    global tokens
    Clear
    Status "getting $url"

    # here, we use the -handler option to http_get to progressively render the page
    set tokens [http_get $url -handler "renderer $url"]
    set redirect 0
    }
    
proc renderer {url sock token} {
    global redirect
    .h.h config -base $url
    .e delete 0 end
    .e insert end $url
    upvar #0 $token state

    # check for redirects (this doesn't always work!)
    if {[regexp 302 $state(http)] && $redirect == 0} {
	array set info $state(meta)
	set redirect 1
	getUrl [string trim $info(Location)] 
        return}

    # read the incoming html and render it
    set html [read $sock $state(-blocksize)]
    .h.h parse $html
    return
    }
      
proc enterUrl {} {
    set url [.e get]
    if !{[regexp ^http:// $url]} {set url "http://$url"}
    getUrl $url
    }

proc FormCmd {n cmd args} {
  # this needs work!
  #puts $args
  switch $cmd {
    input {
      set w [lindex $args 0]
      array set info [lindex $args end]
      if {[info exists info(size)]} {return [entry $w -width $info(size) -bg white]}
      if {[info exists info(type)]} {return [button $w -text $info(value)]}
      label $w -text "form"
    }
  }
}

proc ImageCmd {args} {
    global Images
    array set info [lindex $args end]
    set src [string trim $info(src)]
    set src [url2abs $src]

    # Lots of Web authors neglect the width and height attributes on images
    # let's do what we can to fix that...
    set Width ""
    set Height ""
    if {[info exists info(width)]} {set Width "-width $info(width)"}
    if {[info exists info(height)]} {set Height "-height $info(height)"}
    set fn [file tail $src]

    # see if we already have the image in cache
    # otherwise, return the default image, and set up a callback
    if {[file exists /tmp/$fn]} {return [eval image create photo $Height $Width -file /tmp/$fn]}
    set fd [open /tmp/$fn w]
    set img [eval image create photo $Width $Height]
    $img copy biggray
    set Images($img) 1
    Status "loading image $src"
    set token [http_get $src -channel $fd -command "gotimage $img $fn $fd" ]
    return $img
    }

proc gotimage {img fn fd token} {
    # configure the default image we created earlier
    close $fd
    $img blank
    $img read /tmp/$fn
    }
    
proc HrefBinding {x y} {
   set new [.h.h href $x $y]
    if {"$new" == ""} {return}
   getUrl $new
   }

proc looklinks {x y} {
    set url [.h.h href $x $y]
    if {$url == ""} {
        .h.h configure -cursor left_ptr
        Status ""
        return }
    .h.h configure -cursor hand2
    Status $url
    }

proc bodyHandler {n tag args} {
    array set attr $tag
    if {[info exists attr(bgcolor)]} {.h.h configure -bg $attr(bgcolor)}
    }

proc Status {msg} {
    global STATUS
    set STATUS $msg
    }

proc url2abs {url} {
    # make an absolute URL. this is lousy, but it works
    regexp {([^:]+)://([^:/]+)(:([0-9]+))?(/.*)} [.h.h cget -base] match proto host port path
    switch -glob -- $url {
        http://*  {return $url}
        /*         {return $proto://$host$url}
        default  {return $proto://$host[file dirname $path]/$url}
        }
    }
