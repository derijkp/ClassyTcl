source tools.tcl

Classy::Builder .builder
.builder configure -dir ../dialogs
set object .builder

Classy::Editor .try
pack .try
