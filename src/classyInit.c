#include "tcl.h"
#include <sys/types.h>
#include <time.h>
#include <math.h>

extern int Peos_GetOpenFileCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int argc, char *argv[]));
extern int Peos_GetSaveFileCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int argc, char *argv[]));
extern int Peos_GetFontCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int argc, char *argv[]));

int
Peos_Init(interp)
	Tcl_Interp *interp;		/* Interpreter to add extra commands */
{
#ifdef BORLAND32
	Tcl_CreateCommand(interp, "Peos__GetOpenFile", Peos_GetOpenFileCmd,
		(ClientData) Tk_MainWindow(interp), (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateCommand(interp, "Peos__GetSaveFile", Peos_GetSaveFileCmd,
		(ClientData) Tk_MainWindow(interp), (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateCommand(interp, "Peos__GetFont", Peos_GetFontCmd,
		(ClientData) Tk_MainWindow(interp), (Tcl_CmdDeleteProc *)NULL);
#endif
	 return TCL_OK;
}
