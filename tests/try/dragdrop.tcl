#
# ####  #####  ####   #### 
# #   # #     #    # #     
# ####  ####  #    #  #### 
# #     #     #    #      # 
# #     #####  ####   ####  Peter De Rijk
#
# drag&drop
# ----------------------------------------------------------------------

option add *Drag&Drop.borderWidth 0 widgetDefault
option add *Drag&Drop.highlightThickness 0 widgetDefault

bind Drag&Drop <B1-Motion> {
    wm geometry .drag&drop +[winfo pointerx .drag&drop]+[winfo pointery .drag&drop]
}
bind Drag&Drop <ButtonRelease-1> {
    global d&d__save
    destroy .drag&drop
    bindtags [set d&d__save(widget)] [set d&d__save(bindtags)]
    unset d&d__save
    d&d__informtarget %X %Y
}

# d&d__startdrag icon from data
#     icon: the icon to be used during the drag
#     from: the senders name
#     data: a list of protocols and the data used for that protocol
# -----------------------------------------------------------------
# This command start a drag. It will offer any of the protocols in the protocol
# list to the receiver.

proc d&d__startdrag {icon from data} {
REM startdata:$data
    global d&d__clientdata d&d__save
    set d&d__clientdata $data
    catch {destroy .drag&drop}
    toplevel .drag&drop -class Drag&Drop
    wm overrideredirect .drag&drop 1
    label .drag&drop.l -image $icon -borderwidth 0 -highlightthickness 0
    pack .drag&drop.l
    wm geometry .drag&drop +[winfo pointerx .drag&drop]+[winfo pointery .drag&drop]
    raise .drag&drop
    set d&d__save(widget) $from
    set d&d__save(bindtags) [bindtags $from]
    bindtags $from Drag&Drop
}

# d&d__addreceiver w protocol data
#     w: the name of the targetted widget
#     protocol: protocol useable for transfer
#     data: the data used for this protocol by the receiver.
# ----------------------------------------------------------
# adds a receiver to a widget w for a specific protocol. when a drop is received which
# can use this protocol, the drop will be handled by the associated protocol handler.
# Depending on the protocol, data can be different things. It is usually a command 
# that will be executed in the receiving application and that can use several 
# variables depending on the protocol:
#

proc d&d__addreceiver {w protocol data} {
    global d&d__receivers__${w}
    lappend d&d__receivers__${w}(list) $protocol
    set d&d__receivers__${w}($protocol) $data
}

# d&d__delreceivers w
# -------------------
# deletes the receivers associated to widget w

proc d&d__delreceivers {w} {
    global d&d__receivers__${w}
    unset d&d__receivers__${w}
}

# This routine informs the target of a drop by executing the d&d__receivedrop
# routine in the target if it supports Peos drag & drop
proc d&d__informtarget {x y} {
    global d&d__clientdata
    set target [d&d__findtarget $x $y]
    set tappl [lindex $target 0]
    set twidget [lindex $target 1]
    if {"$target" == ""} {
        unset d&d__clientdata
        error "drop failed: no Tk application"
    }
REM "$tappl d&d__receivedrop [tk appname] [lindex $target 1] [list [set d&d__clientdata]]"
    if {"$tappl" == [tk appname]} {
        # Internal drag & drop
        d&d__receivedrop $tappl $twidget [set d&d__clientdata]
    } else {
        # External drag & drop
        if {[send -- $tappl info procs d&d__receivedrop] == ""} {
            unset d&d__clientdata
            error "Drop failed: application does not support drag&drop"
        }
        send -- $tappl d&d__receivedrop [list [tk appname]] $twidget [list [set d&d__clientdata]]
    }
    unset d&d__clientdata
}

proc d&d__findtarget {x y} {
    set widget [winfo containing $x $y]
    if {"$widget" != ""} {
        return [list [tk appname] $widget]
    }
    foreach appl [winfo interps] {
        set widget [send -- $appl winfo containing $x $y]
        if {"$widget" != ""} {
            return [list $appl $widget]
        }
    }
    return ""
}

# Receives the drop
# The clientdata is sent together with the drop, and is a list of protocols
# together with clientdata specific for each protocol. 
# The first protocol for which a d&d__handle$protocol routine exists, 
# will be called to handle the drop.

proc d&d__receivedrop {from w clientdata} {
    global d&d__receivers__${w}
REM clientdata received: [set clientdata]
    array set sentdata $clientdata
    if [info exists d&d__receivers__${w}(list)] {
        foreach protocol [set d&d__receivers__${w}(list)] {
            if [info exists sentdata($protocol)] {
                d&d__handle$protocol $from $w [set d&d__receivers__${w}($protocol)] $sentdata($protocol)
                return
            }
        }
    } else {
        error "Drop failed: no compatible protocol"
    }
    return
 }

# d&d handlers for different protocols
# The handler for first protocol matching a receiver will be called with 
# the following arguments:
#    from: sending application
#    w: targetted widget
#    recdata: protocol data for the receiver, usually a command
#    sentdata: protocol data from the sender

# Protocol handler: mem_indirect
# ------------------------------
# 

proc d&d__handlemem_indirect {from w recdata sentdata} {
    set num [expr [llength $recdata]/2]
    set reclist [list_sub $recdata [list_fill $num 0 2]]
    array set recar $recdata
    array set sentar $sentdata
    foreach type $reclist {
        if [info exists sentar($type)] {
            set getdata $sentar($type)
            eval $recar($type)
            return
        }
    }
    if [info exists recar(*)] {
        set getdata [lindex $sentdata 1]
        eval $recar(*)
        return
    } else {
        error "Drop failed: no compatible type"
    }
}

proc d&d__handlescratchfile {from w recdata sentdata} {
    set num [expr [llength $recdata]/2]
    set reclist [list_sub $recdata [list_fill $num 0 2]]
    array set recar $recdata
    array set sentar $sentdata
    foreach type $reclist {
        if [info exists sentar($type)] {
            set savecommand $sentar($type)
            eval $recar($type)
            return
        }
    }
    if [info exists recar(*)] {
        set savecommand [lindex $sentdata 1]
        eval $recar(*)
        return
    } else {
        error "Drop failed: no compatible type"
    }
}

# Protocol handler: files
# -----------------------
# The sent data contains a list of filenames. The variable files is set to this list,
# and the receivers protocol data is executed as a command.

proc d&d__handlefiles {from w recdata sentdata} {
    set files $sentdata
    eval $recdata
}

# Protocol handler: savebox
# -------------------------
# used in the Filer to handle a drop from a savebox. 
# The receivers data is executed as a command
# Following variables can be used:
# savebox: the widget name of the sending savebox
# file: the desired file name

proc d&d__handlesavebox {from w recdata sentdata} {
    set savebox [lindex $sentdata 0]
    set file [lindex $sentdata 1]
    eval $recdata
}


