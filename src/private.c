/*
 *       File:    variable.c
 *       Purpose: object extension to Tcl
 *       Author:  Copyright (c) 1998 Peter De Rijk
 *
 *       See the file "README" for information on usage and redistribution
 *       of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#include <string.h>
#include "tcl.h"
#include "class.h"

Tcl_Obj *Classy_ObjectPrivateVar(
	Tcl_Obj *name,
	Tcl_Obj *var)
{
	Tcl_Obj *result;
	char buffer[100];
	char *obj, *dbuffer,*varstring;
	int objlen,varlen,bsize=0,end;
	obj = Tcl_GetStringFromObj(name,&objlen);
	dbuffer = buffer;
	varstring = Tcl_GetStringFromObj(var,&varlen);
	end = objlen+13+varlen;
	if (end > 98) {
		if (bsize == 0) {
			dbuffer = (char *)Tcl_Alloc(end*sizeof(char *));
			bsize = end-1;
		}
	}
	memcpy(dbuffer,"::class::",9);
	memcpy(dbuffer+9,obj,objlen);
	memcpy(dbuffer+9+objlen,",,v,",4);
	memcpy(dbuffer+objlen+13,varstring,varlen);
	result = Tcl_NewStringObj(dbuffer,end);
	if (bsize != 0) {
		Tcl_Free(dbuffer);
	}
	return result;
}

int Classy_PrivateObjCmd(
	ClientData clientdata,
	Tcl_Interp *interp,
	int argc,
	Tcl_Obj *CONST argv[])
{
	char buffer[100];
	char *obj, *var, *dbuffer;
	int error,objlen,varlen,bsize=0,i,end;
	if (argc < 2) {
		Tcl_ResetResult(interp);
		Tcl_SetResult(interp,"no value given for parameter \"object\" to \"private\"",TCL_STATIC);
		return TCL_ERROR;
	}
	obj = Tcl_GetStringFromObj(argv[1],&objlen);
	dbuffer = buffer;
	memcpy(dbuffer,"::class::",9);
	memcpy(dbuffer+9,obj,objlen);
	memcpy(dbuffer+9+objlen,",,v,",4);
	for (i=2;i<argc;i++) {
		var = Tcl_GetStringFromObj(argv[i],&varlen);
		end = objlen+13+varlen;
		if (end > 98) {
			if (bsize == 0) {
				dbuffer = (char *)Tcl_Alloc(end*sizeof(char *));
				memcpy(dbuffer,"::class::",9);
				memcpy(dbuffer+9,obj,objlen);
				memcpy(dbuffer+9+objlen,",,v,",4);
				bsize = end-1;
			} else if (end>bsize) {
				dbuffer = (char *)Tcl_Realloc(dbuffer,end*sizeof(char *));
				bsize = end-1;
			}
		}
		memcpy(dbuffer+objlen+13,var,varlen);
		dbuffer[end] = '\0';
		error = Tcl_UpVar(interp, "#0", dbuffer, var, 0);
	}
	if (bsize != 0) {
		Tcl_Free(dbuffer);
	}
	return TCL_OK;
}

int Classy_SetPrivateObjCmd(
	ClientData clientdata,
	Tcl_Interp *interp,
	int argc,
	Tcl_Obj *CONST argv[])
{
	if (argc != 4) {
		Tcl_ResetResult(interp);
		Tcl_WrongNumArgs(interp,argc,argv,"object var value");
		return TCL_ERROR;
	}
	if (Tcl_ObjSetVar2(interp, Classy_ObjectPrivateVar(argv[1],argv[2]), NULL, argv[3], TCL_GLOBAL_ONLY|TCL_PARSE_PART1|TCL_LEAVE_ERR_MSG) == NULL) {
		return TCL_ERROR;
	}
	return TCL_OK;
}

int Classy_GetPrivateObjCmd(
	ClientData clientdata,
	Tcl_Interp *interp,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Tcl_Obj *result;
	if (argc != 3) {
		Tcl_ResetResult(interp);
		Tcl_WrongNumArgs(interp,argc,argv,"object var");
		return TCL_ERROR;
	}
	result = Tcl_ObjGetVar2(interp, Classy_ObjectPrivateVar(argv[1],argv[2]), NULL, TCL_GLOBAL_ONLY|TCL_PARSE_PART1|TCL_LEAVE_ERR_MSG);
	if (result == NULL) {
		return TCL_ERROR;
	}
	Tcl_SetObjResult(interp,result);
	return TCL_OK;
}

int Classy_PrivateVarObjCmd(
	ClientData clientdata,
	Tcl_Interp *interp,
	int argc,
	Tcl_Obj *CONST argv[])
{
	if (argc != 3) {
		Tcl_ResetResult(interp);
		Tcl_WrongNumArgs(interp,argc,argv,"object var");
		return TCL_ERROR;
	}
	Tcl_SetObjResult(interp,Classy_ObjectPrivateVar(argv[1],argv[2]));
	return TCL_OK;
}

