/*
 *       File:    object.c
 *       Purpose: object extension to Tcl
 *       Author:  Copyright (c) 1998 Peter De Rijk
 *
 *       See the file "README" for information on usage and redistribution
 *       of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#include <string.h>
#include "tcl.h"
#include "class.h"
#include "method.h"

static Class *classcurrent = NULL;
Classy_Method Classy_MethodClassMethod;

void Classy_FreeObject(char *clientdata) {
	Object *object = (Object *)clientdata;
	if (object->name != NULL) {
		Tcl_DecrRefCount(object->name);
		object->name = NULL;
	}
	if (object->trace != NULL) {
		Tcl_DecrRefCount(object->trace);
		object->trace = NULL;
	}
	Tcl_Free(clientdata);
}

int Classy_ObjectObjCmd(
	ClientData clientdata,
	Tcl_Interp *interp,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Class *class;
	Object *object;
	Tcl_HashEntry *entry;
	char *cmd;
	int error;

	object = (Object *)clientdata;
	class = object->parent;
	if (argc<2) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"no value given for parameter \"cmd\" to \"",Tcl_GetStringFromObj(argv[0],NULL),"\"", (char *)NULL);
		return TCL_ERROR;
	}
	if (object->trace != NULL) {
		Tcl_Obj *cmd;
		cmd = Tcl_DuplicateObj(object->trace);
		error = Tcl_ListObjAppendElement(interp, cmd, Tcl_NewListObj(argc,argv));
		if (error != TCL_OK) {Tcl_DecrRefCount(cmd);return error;}
		error = Tcl_EvalObj(interp,cmd);
		Tcl_DecrRefCount(cmd);
		if (error != TCL_OK) {return error;}
	}
	cmd = Tcl_GetStringFromObj(argv[1],NULL);
	argv+=2;
	argc-=2;
	entry = Tcl_FindHashEntry(&(class->methods), cmd);
	if (entry != NULL) {
		Method *method;
		method = (Method *)Tcl_GetHashValue(entry);
		Tcl_Preserve((ClientData)object);
		error = Classy_ExecMethod(interp,method,class,object,argc,argv);
		if (error != TCL_OK) {
			Tcl_Obj *errorObj = Tcl_NewStringObj("\nwhile invoking method \"",24);
			Tcl_AppendStringsToObj(errorObj, cmd, "\" of object \"", Tcl_GetStringFromObj(object->name,NULL), "\"\n", (char *) NULL);
			Tcl_AddObjErrorInfo(interp, Tcl_GetStringFromObj(errorObj,NULL), -1);
			Tcl_DecrRefCount(errorObj);
		}
		Tcl_Release((ClientData)object);
		return error;
	} else {
		Tcl_Obj *result, **objv;
		int objc,i;
		Tcl_ResetResult(interp);
		error = Classy_InfoMethods(interp,class,NULL);
		if (error != TCL_OK) {return error;}
		result = Tcl_GetObjResult(interp);
		Tcl_IncrRefCount(result);
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"bad option \"",cmd ,"\": must be ", (char *)NULL);
		error = Tcl_ListObjGetElements(interp, result, &objc, &objv);
		if (error != TCL_OK) {return error;}
		Tcl_AppendElement(interp, Tcl_GetStringFromObj(objv[0],NULL));
		for (i=1;i<objc;i++) {
			Tcl_AppendResult(interp, ", ", Tcl_GetStringFromObj(objv[i],NULL), NULL);
		}
		Tcl_DecrRefCount(result);
		return TCL_ERROR;
	}
}

void Classy_ObjectDestroy(ClientData clientdata) {
	Class *class, *tempclass;
	Object *object;
	Tcl_HashEntry *entry;
	char *string;

	object = (Object *)clientdata;
	Tcl_Preserve(clientdata);
	class = object->parent;
	tempclass = class;
	while(1) {
		if (tempclass->destroy != NULL) {
			Classy_ExecMethod(class->interp,tempclass->destroy,class,object,0,NULL);
		}
		tempclass = tempclass->parent;
		if (tempclass == NULL) break;
	}
	string = Tcl_GetStringFromObj(object->name,NULL);
	entry = Tcl_FindHashEntry(&(class->children),string);
	if (entry != NULL) {Tcl_DeleteHashEntry(entry);}
	Tcl_VarEval(class->interp,"foreach var [info vars ::class::", string,",,*] {unset $var}", (char *)NULL);
	Tcl_EventuallyFree(clientdata,Classy_FreeObject);
	Tcl_Release(clientdata);
}

int Classy_ObjectDestroyObjCmd(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Tcl_Preserve((ClientData)object);
	Tcl_DeleteCommandFromToken(interp,object->token);
	Tcl_Release((ClientData)object);
	return TCL_OK;
}

int Classy_NewClassMethod(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Class *tempclass;
	Tcl_HashEntry *entry;
	Tcl_Obj *name,*tempobj;
	Tcl_CmdInfo cmdinfo;
	char *string;
	int len,pos,found,error,new;

	if (argc<1) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(class->class,NULL),
			" new object ?args?\"", (char *)NULL);
		return TCL_ERROR;
	}
	string = Tcl_GetStringFromObj(argv[0],&len);
	if (len>2) {
		if ((string[0]==':')&&(string[1]==':')) {
			string += 2;
			len -= 2;
		}
		pos = len - 1;
		while (pos>1) {
			if ((string[pos]==':')&&(string[pos-1]==':')) break;
			pos--;
		}
		if (pos != 1) {
			string[pos-1] = '\0';
			error = Tcl_VarEval(interp,"namespace eval ",string, " {}", (char *)NULL);
			if (error != TCL_OK) {return error;}
			error = Tcl_VarEval(interp,"namespace eval ::class::",string, " {}", (char *)NULL);
			if (error != TCL_OK) {return error;}
			string[pos-1] = ':';
		}
	}
	name = Tcl_NewStringObj(string,len);
	found = Tcl_GetCommandInfo(interp,string,&cmdinfo);
	if (found == 1) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"command \"",string,"\" exists", (char *)NULL);
		return TCL_ERROR;
	}
	entry = Tcl_CreateHashEntry(&(class->children),string,&new);
	if (new == 1) {
		object = (Object *)Tcl_Alloc(sizeof(Object));
		Tcl_SetHashValue(entry,(ClientData)object);
	} else {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"command \"",string,"\" exists", (char *)NULL);
		return TCL_ERROR;
	}
	object->parent = class;
	object->name = name;
	Tcl_IncrRefCount(name);
	object->trace = NULL;
	object->token = Tcl_CreateObjCommand(interp,string,(Tcl_ObjCmdProc *)Classy_ObjectObjCmd,
		(ClientData)object,(Tcl_CmdDeleteProc *)Classy_ObjectDestroy);
	tempclass = class;
	while(1) {
		if (tempclass->init != NULL) {
			classcurrent = tempclass;
			error = Classy_ExecMethod(interp,tempclass->init,class,object,argc-1,argv+1);
			if (error != TCL_OK) {
				Tcl_Obj *errorObj, *errorinfo;
				errorObj = Tcl_GetObjResult(interp);
				Tcl_IncrRefCount(errorObj);
				tempobj = Tcl_NewStringObj("errorInfo",-1);
				errorinfo = Tcl_ObjGetVar2(interp, tempobj, NULL, TCL_GLOBAL_ONLY);
				Tcl_DecrRefCount(tempobj);
				Tcl_IncrRefCount(errorinfo);
				Tcl_DeleteCommandFromToken(interp,object->token);
				Tcl_ResetResult(interp);
				Tcl_AddObjErrorInfo(interp, Tcl_GetStringFromObj(errorinfo,NULL), -1);
				Tcl_SetObjResult(interp,errorObj);
				Tcl_DecrRefCount(errorObj);
				Tcl_DecrRefCount(errorinfo);
				return error;
			}
			break;
		}
		tempclass = tempclass->parent;
		if (tempclass == NULL) break;
	}
	Tcl_SetObjResult(interp,name);
	return TCL_OK;
}

int Classy_TraceMethod(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	char *command;
	int len;

	if (argc!=1) {
		Tcl_ResetResult(interp);
		Tcl_WrongNumArgs(interp,argc,argv," procedure");
		return TCL_ERROR;
	}
	command = Tcl_GetStringFromObj(argv[0],&len);
	if (len != 0) {
		if (object != NULL) {
			object->trace = Tcl_DuplicateObj(argv[0]);
			Tcl_IncrRefCount(object->trace);
		} else {
			class->trace = Tcl_DuplicateObj(argv[0]);
			Tcl_IncrRefCount(class->trace);
		}
	} else {
		if (object != NULL) {
			if (object->trace != NULL) {
				Tcl_DecrRefCount(object->trace);
				object->trace = NULL;
			}
		} else {
			if (class->trace != NULL) {
				Tcl_DecrRefCount(class->trace);
				class->trace = NULL;
			}
		}
	}
	return TCL_OK;
}

int Classy_SuperObjCmd(
	ClientData clientdata,
	Tcl_Interp *interp,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Tcl_CmdInfo cmdinfo;
	Class *class;
	Object *object;
	char *classname, *objectname;
	int found, error;

	classname = Tcl_GetVar(interp, "class", TCL_LEAVE_ERR_MSG);
	if (classname == NULL) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"no variable \"class\" found", (char *)NULL);
		return TCL_ERROR;
	}
	found = Tcl_GetCommandInfo(interp, classname, &cmdinfo);
	if (found == 0) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"class \"",classname,"\" does not exist", (char *)NULL);
		return TCL_ERROR;
	}
	class = (Class *)cmdinfo.objClientData;

	objectname = Tcl_GetVar(interp, "object", TCL_LEAVE_ERR_MSG);
	if (objectname == NULL) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"no variable \"object\" found", (char *)NULL);
		return TCL_ERROR;
	}
	found = Tcl_GetCommandInfo(interp, objectname, &cmdinfo);
	if (found == 0) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"object \"",objectname,"\" does not exist", (char *)NULL);
		return TCL_ERROR;
	}
	object = (Object *)cmdinfo.objClientData;

	if (classcurrent->parent != NULL) {
		classcurrent = classcurrent->parent;
		while(1) {
			if (classcurrent->init != NULL) {
				error = Classy_ExecMethod(interp,classcurrent->init,class,object,argc-1,argv+1);
				return error;
			}
			classcurrent = classcurrent->parent;
			if (classcurrent == NULL) break;
		}
	}
	Tcl_SetResult(interp,objectname,TCL_VOLATILE);
	return TCL_OK;
}

