#include "tcl.h"
#include <sys/types.h>
#include <time.h>
#include <math.h>

extern int Classy_ReinitObjCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int argc, char *argv[]));
extern int Classy_SuperObjCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int argc, char *argv[]));
extern int Classy_PrivateObjCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int argc, char *argv[]));
extern int Classy_SetPrivateObjCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int argc, char *argv[]));
extern int Classy_GetPrivateObjCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int argc, char *argv[]));
extern int Classy_PrivateVarObjCmd _ANSI_ARGS_((ClientData clientData,
	Tcl_Interp *interp, int argc, char *argv[]));

int
Classy_Init(interp)
	Tcl_Interp *interp;		/* Interpreter to add extra commands */
{
	Tcl_CreateObjCommand(interp,"::class::reinit",(Tcl_ObjCmdProc *)Classy_ReinitObjCmd,
		(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
	Classy_InitSuper();
	Tcl_CreateObjCommand(interp,"::class::super",(Tcl_ObjCmdProc *)Classy_SuperObjCmd,
		(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp,"::class::private",(Tcl_ObjCmdProc *)Classy_PrivateObjCmd,
		(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp,"::class::setprivate",(Tcl_ObjCmdProc *)Classy_SetPrivateObjCmd,
		(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp,"::class::getprivate",(Tcl_ObjCmdProc *)Classy_GetPrivateObjCmd,
		(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateObjCommand(interp,"::class::privatevar",(Tcl_ObjCmdProc *)Classy_PrivateVarObjCmd,
		(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
	return TCL_OK;
}


