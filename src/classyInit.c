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
Classy_Init(interp)
	Tcl_Interp *interp;		/* Interpreter to add extra commands */
{
#ifdef BORLAND32
	Tcl_CreateCommand(interp, "Classy__GetOpenFile", Classy_GetOpenFileCmd,
		(ClientData) Tk_MainWindow(interp), (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateCommand(interp, "Classy__GetSaveFile", Classy_GetSaveFileCmd,
		(ClientData) Tk_MainWindow(interp), (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateCommand(interp, "Classy__GetFont", Classy_GetFontCmd,
		(ClientData) Tk_MainWindow(interp), (Tcl_CmdDeleteProc *)NULL);
#endif
	 return TCL_OK;
}
