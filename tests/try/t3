#==========================================
#============== Start of try ==============
#==========================================
catch {destroy .try}
source classes/PeosDialog.tcl
source classes/SaveBox.tcl
Peos__SaveBox .try -savecommand {puts stdout}
.try set try.txt

source filer.tcl
wm deiconify .
catch {destroy .try}
source /home/peter/work/peos/classes/FilerWindow.tcl
Peos__FilerWindow .try -dir /home/peter/work/peos/try
pack .try -fill both -expand yes
.try configure -hidden yes
.try configure -view full -dist {70 70 40 20 15}

#==========================================
#============== Start of try ==============
#==========================================

