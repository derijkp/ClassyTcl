#include "tcl.h"
#include <sys/types.h>
#include <time.h>
#include <math.h>

extern int Classy_GetOpenFileCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int argc, char *argv[]));
extern int Classy_GetSaveFileCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int argc, char *argv[]));
extern int Classy_GetFontCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int argc, char *argv[]));

int
Classywin_Init(interp)
	Tcl_Interp *interp;		/* Interpreter to add extra commands */
{
	Tcl_CreateCommand(interp, "Classy::GetOpenFile", Classy_GetOpenFileCmd,
		(ClientData) Tk_MainWindow(interp), (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateCommand(interp, "Classy::GetSaveFile", Classy_GetSaveFileCmd,
		(ClientData) Tk_MainWindow(interp), (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateCommand(interp, "Classy::GetFont", Classy_GetFontCmd,
		(ClientData) Tk_MainWindow(interp), (Tcl_CmdDeleteProc *)NULL);
	return TCL_OK;
}


