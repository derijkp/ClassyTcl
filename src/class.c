/*
 *       File:    class.c
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

void Classy_FreeClass(char *clientdata) {
	Class *class = (Class *)clientdata;
	Tcl_HashEntry *entry;
	Tcl_HashSearch search;
	Method *method;

	/* todo: also all children, objects, vars, etc */
	if (class->init != NULL) {
		Classy_FreeMethod(class->init);
		Tcl_Free((char *)class->init);
		class->init = NULL;
	}
	if (class->destroy != NULL) {
		Classy_FreeMethod(class->destroy);
		Tcl_Free((char *)class->destroy);
		class->destroy = NULL;
	}
	if (class->classdestroy != NULL) {
		Classy_FreeMethod(class->classdestroy);
		Tcl_Free((char *)class->classdestroy);
		class->classdestroy = NULL;
	}
	if (class->class != NULL) {
		Tcl_DecrRefCount(class->class);
		class->class = NULL;
	}
	if (class->trace != NULL) {
		Tcl_DecrRefCount(class->trace);
		class->trace = NULL;
	}

	entry = Tcl_FirstHashEntry(&(class->classmethods), &search);
	while(1) {
		if (entry == NULL) break;
		method = (Method *)Tcl_GetHashValue(entry);
		Classy_FreeMethod(method);
		Tcl_Free((char *)method);
		entry = Tcl_NextHashEntry(&search);
	}
	Tcl_DeleteHashTable(&(class->classmethods));
	entry = Tcl_FirstHashEntry(&(class->methods), &search);
	while(1) {
		if (entry == NULL) break;
		method = (Method *)Tcl_GetHashValue(entry);
		Classy_FreeMethod(method);
		Tcl_Free((char *)method);
		entry = Tcl_NextHashEntry(&search);
	}
	Tcl_DeleteHashTable(&(class->methods));
	Tcl_Free((char *)class);
}

int Classy_ClassObjCmd(
	ClientData clientdata,
	Tcl_Interp *interp,
	int argc,
	Tcl_Obj *argv[])
{
	Class *class;
	Tcl_HashEntry *entry;
	char *cmd;
	int error;

	class = (Class *)clientdata;
	if (argc<=1) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"no value given for parameter \"cmd\" to \"",Tcl_GetStringFromObj(argv[0],NULL),"\"", (char *)NULL);
		return TCL_ERROR;
	}
	if (class->trace != NULL) {
		Tcl_Obj *cmd;
		cmd = Tcl_DuplicateObj(class->trace);
		error = Tcl_ListObjAppendElement(interp, cmd, Tcl_NewListObj(argc,argv));
		if (error != TCL_OK) {Tcl_DecrRefCount(cmd);return error;}
		error = Tcl_EvalObj(interp,cmd);
		Tcl_DecrRefCount(cmd);
		if (error != TCL_OK) {return error;}
	}
	argv++;
	argc--;
	cmd = Tcl_GetStringFromObj(argv[0],NULL);
	if (cmd[0]=='.') {
		cmd = "new";
	} else {
		argv++;
		argc--;
	}
	entry = Tcl_FindHashEntry(&(class->classmethods), cmd);
	if (entry != NULL) {
		Method *method;
		method = (Method *)Tcl_GetHashValue(entry);
		Tcl_Preserve((ClientData)class);
		error = Classy_ExecClassMethod(interp,method,class,NULL,argc,argv);
		if (error == TCL_ERROR) {
			Tcl_Obj *errorObj=Tcl_NewStringObj("\nwhile invoking classmethod \"",29);
			Tcl_AppendStringsToObj(errorObj, cmd, "\" of class \"", Tcl_GetStringFromObj(class->class,NULL), "\"\n", (char *) NULL);
			Tcl_AddObjErrorInfo(interp, Tcl_GetStringFromObj(errorObj,NULL), -1);
			Tcl_DecrRefCount(errorObj);
		}
		Tcl_Release((ClientData)class);
		return error;
	}
	entry = Tcl_FindHashEntry(&(class->methods), cmd);
	if (entry != NULL) {
		Method *method;
		method = (Method *)Tcl_GetHashValue(entry);
		error = Classy_ExecMethod(interp,method,class,NULL,argc,argv);
		if (error == TCL_ERROR) {
			Tcl_Obj *errorObj=Tcl_NewStringObj("\nwhile invoking method \"",24);
			Tcl_AppendStringsToObj(errorObj, cmd, "\" of class \"", Tcl_GetStringFromObj(class->class,NULL), "\"", (char *) NULL);
			Tcl_AddObjErrorInfo(interp, Tcl_GetStringFromObj(errorObj,NULL), -1);
			Tcl_DecrRefCount(errorObj);
		}
		return error;
	} else {
		Tcl_Obj *result, **objv;
		int objc,i;
		Tcl_ResetResult(interp);
		error = Classy_InfoClassMethods(interp,class,NULL);
		if (error != TCL_OK) {return error;}
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

void Classy_ClassDestroy(ClientData clientdata) {
	Tcl_Interp *interp;
	Class *class, *parent, *subclass;
	Object *object;
	Tcl_HashSearch search;
	Tcl_HashEntry *entry;
	char *string;

	class = (Class *)clientdata;
	Tcl_Preserve(clientdata);
	interp = class->interp;
	if (class->classdestroy != NULL) {
		Classy_ExecClassMethod(interp,class->classdestroy,class,NULL,0,NULL);
	}
	entry = Tcl_FirstHashEntry(&(class->subclasses), &search);
	while(1) {
		if (entry == NULL) break;
		subclass = (Class *)Tcl_GetHashValue(entry);
		Tcl_DeleteCommandFromToken(interp,subclass->token);
		entry = Tcl_NextHashEntry(&search);
	}
	entry = Tcl_FirstHashEntry(&(class->children), &search);
	while(1) {
		if (entry == NULL) break;
		object = (Object *)Tcl_GetHashValue(entry);
		Tcl_DeleteCommandFromToken(interp,object->token);
		entry = Tcl_NextHashEntry(&search);
	}
	string = Tcl_GetStringFromObj(class->class,NULL);
	parent = class->parent;
	if (parent != NULL) {
		entry = Tcl_FindHashEntry(&(parent->subclasses),string);
		if (entry != NULL) {Tcl_DeleteHashEntry(entry);}
	}
	Tcl_VarEval(interp,"foreach ::class::var [info vars ::class::", string,",,*] {unset $::class::var}", (char *)NULL);
	Tcl_VarEval(interp,"foreach ::class::cmd [info commands ::class::", string,",,*] {rename $::class::cmd {}}", (char *)NULL);
	Tcl_EventuallyFree(clientdata,Classy_FreeClass);
	Tcl_Release(clientdata);
}

int Classy_SubclassClassMethod(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Class *subclass;
	Tcl_HashEntry *entry;
	Tcl_Obj *name;
	Tcl_CmdInfo cmdinfo;
	char *subclassname, *classname;
	int len,pos,found,error,new;

	if (argc!=1) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(class->class,NULL),
			" subclass class\"", (char *)NULL);
		return TCL_ERROR;
	}
	subclassname = Tcl_GetStringFromObj(argv[0],&len);
	if (len>2) {
		if ((subclassname[0]==':')&&(subclassname[1]==':')) {
			subclassname += 2;
			len -= 2;
		}
		pos = len - 1;
		while (pos>1) {
			if ((subclassname[pos]==':')&&(subclassname[pos-1]==':')) break;
			pos--;
		}
		if (pos != 1) {
			subclassname[pos-1] = '\0';
			error = Tcl_VarEval(interp,"namespace eval ::class::", subclassname, " {catch {namespace import ::class::super} ; catch {namespace import ::class::private} ; catch {namespace import ::class::privatevar} ; catch {namespace import ::class::setprivate} ; catch {namespace import ::class::getprivate}}", (char *)NULL);
			subclassname[pos-1] = ':';
		}
	}
	name = Tcl_NewStringObj(subclassname,len);
	found = Tcl_GetCommandInfo(interp,subclassname,&cmdinfo);
	if (found == 1) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"command \"",subclassname,"\" exists", (char *)NULL);
		return TCL_ERROR;
	}
	entry = Tcl_CreateHashEntry(&(class->subclasses),subclassname,&new);
	if (new == 1) {
		subclass = (Class *)Tcl_Alloc(sizeof(Class));
		Tcl_SetHashValue(entry,(ClientData)subclass);
	} else {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"command \"",subclassname,"\" exists", (char *)NULL);
		return TCL_ERROR;
	}
	subclass->parent = class;
	subclass->class = name;
	subclass->trace = NULL;
	Tcl_IncrRefCount(name);
	subclass->interp = interp;
	Tcl_InitHashTable(&(subclass->methods),TCL_STRING_KEYS);
	Tcl_InitHashTable(&(subclass->classmethods),TCL_STRING_KEYS);
	Tcl_InitHashTable(&(subclass->children),TCL_STRING_KEYS);
	Tcl_InitHashTable(&(subclass->subclasses),TCL_STRING_KEYS);
	subclass->init = (Method *)NULL;
	subclass->destroy = (Method *)NULL;
	subclass->classdestroy = (Method *)NULL;
	subclass->token = Tcl_CreateObjCommand(interp,subclassname,(Tcl_ObjCmdProc *)Classy_ClassObjCmd,
		(ClientData)subclass,(Tcl_CmdDeleteProc *)Classy_ClassDestroy);
	Classy_CopyMethods(&(class->methods),&(subclass->methods));
	Classy_CopyMethods(&(class->classmethods),&(subclass->classmethods));
	classname = Tcl_GetStringFromObj(class->class,NULL);
	error = Tcl_VarEval(interp,"namespace eval class {foreach var [info vars ::class::", classname, ",,v,*] {",
		"regexp {^::class::", classname, ",,v,(.*)$} $var temp name \n",
		"if [array exists $var] {",
			"array set ::class::", subclassname , ",,v,${name} [array get $var]",
		"} else {",
			"set ::class::", subclassname , ",,v,${name} [set $var]",
		"}}}",(char *)NULL);
	if (error != TCL_OK) {return error;}
	Tcl_SetObjResult(interp,name);
	return TCL_OK;
}

int Classy_ClassDestroyObjCmd(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Tcl_Preserve((ClientData)class);
	Tcl_DeleteCommandFromToken(interp,class->token);
	Tcl_Release((ClientData)class);
	return TCL_OK;
}

int Classy_InfoMethod(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Tcl_Obj *genname;
	char *option;
	int optionlen;
	if (object != NULL) {genname = object->name;} else {genname = class->class;}
	if (argc < 1) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(genname,NULL),
			" info option ?...?\"", (char *)NULL);
		return TCL_ERROR;
	}
	option = Tcl_GetStringFromObj(argv[0],&optionlen);
	if ((optionlen == 6)&&(strncmp(option,"parent",optionlen) == 0)) {
		if (object == NULL) {
			Tcl_SetObjResult(interp,class->parent->class);
			return TCL_OK;
		} else {
			Tcl_SetObjResult(interp,class->class);
			return TCL_OK;
		}
	} else if ((optionlen == 5)&&(strncmp(option,"class",optionlen) == 0)) {
		Tcl_SetObjResult(interp,class->class);
		return TCL_OK;
	} else if ((optionlen == 8)&&(strncmp(option,"children",optionlen) == 0)) {
		Tcl_HashEntry *entry;
		Tcl_HashSearch search;
		Tcl_Obj *temp;
		char *name;
		int error;
	
		if (object == NULL) {
			entry = Tcl_FirstHashEntry(&(class->children), &search);
			while(1) {
				if (entry == NULL) break;
				name = Tcl_GetHashKey(&(class->children),entry);
				Tcl_AppendElement(interp, name);
				entry = Tcl_NextHashEntry(&search);
			}
			temp = Tcl_NewStringObj("lsort",5);
			error = Tcl_ListObjAppendElement(interp,temp,Tcl_GetObjResult(interp));
			if (error != TCL_OK) {Tcl_DecrRefCount(temp);return error;}
			error = Tcl_EvalObj(interp,temp);
			Tcl_DecrRefCount(temp);
			return error;
		}
	} else if ((optionlen == 10)&&(strncmp(option,"subclasses",optionlen) == 0)) {
		Tcl_HashEntry *entry;
		Tcl_HashSearch search;
		Tcl_Obj *temp;
		char *name;
		int error;
	
		if (object == NULL) {
			entry = Tcl_FirstHashEntry(&(class->subclasses), &search);
			while(1) {
				if (entry == NULL) break;
				name = Tcl_GetHashKey(&(class->subclasses),entry);
				Tcl_AppendElement(interp, name);
				entry = Tcl_NextHashEntry(&search);
			}
			temp = Tcl_NewStringObj("lsort",5);
			error = Tcl_ListObjAppendElement(interp,temp,Tcl_GetObjResult(interp));
			if (error != TCL_OK) {Tcl_DecrRefCount(temp);return error;}
			error = Tcl_EvalObj(interp,temp);
			Tcl_DecrRefCount(temp);
			return error;
		}
	} else if ((optionlen == 7)&&(strncmp(option,"methods",optionlen) == 0)) {
		if (argc == 1) {
			return Classy_InfoMethods(interp,class,NULL);
		} else if (argc == 2) {
			return Classy_InfoMethods(interp,class,argv[1]);
		} else {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(genname,NULL),
				" info methods ?pattern?\"", (char *)NULL);
			return TCL_ERROR;
		}
	} else if ((optionlen == 12)&&(strncmp(option,"classmethods",optionlen) == 0)) {
		if (argc == 1) {
			return Classy_InfoClassMethods(interp,class,NULL);
		} else if (argc == 2) {
			return Classy_InfoClassMethods(interp,class,argv[1]);
		} else {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(genname,NULL),
				" info classmethods ?pattern?\"", (char *)NULL);
			return TCL_ERROR;
		}
	} else if ((optionlen == 6)&&(strncmp(option,"method",optionlen) == 0)) {
		if (argc < 3) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(genname,NULL),
				" info method option name ?...?\"", (char *)NULL);
			return TCL_ERROR;
		} else {
			return Classy_InfoMethodinfo(interp,class,object,argc-1,argv+1);
		}
	} else if ((optionlen == 11)&&(strncmp(option,"classmethod",optionlen) == 0)) {
		if (argc < 3) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(genname,NULL),
				" info classmethod option name ?...?\"", (char *)NULL);
			return TCL_ERROR;
		} else {
			if (object == NULL) {
				return Classy_InfoClassMethodinfo(interp,class,argc-1,argv+1);
			} else {
				Tcl_ResetResult(interp);
				Tcl_AppendResult(interp,"object cannot have classmethods", (char *)NULL);
				return TCL_ERROR;
			}
		}
	}
	if (object == NULL) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"wrong option \"",option,
			"\" must be parent, class, children, subclasses, methods, method, classmethods or classmethod", (char *)NULL);
		return TCL_ERROR;
	} else {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"wrong option \"",option,
			"\" must be parent, class, methods or method", (char *)NULL);
		return TCL_ERROR;
	}
}

Classy_Method Classy_PrivateClassMethod;
Classy_Method Classy_PrivateMethod;

Classy_Method Classy_NewClassMethod;
Classy_Method Classy_TraceMethod;
Classy_Method Classy_ObjectDestroyObjCmd;

int Classy_CreateClass(interp)
	Tcl_Interp *interp;
{
	Class *class;
	Method *method;
	Tcl_HashEntry *entry;
	int new;

	class = (Class *)Tcl_Alloc(sizeof(Class));
	class->interp = interp;
	class->class = Tcl_NewStringObj("Class",5);
	class->trace = NULL;
	Tcl_IncrRefCount(class->class);
	Tcl_InitHashTable(&(class->methods),TCL_STRING_KEYS);
	Tcl_InitHashTable(&(class->classmethods),TCL_STRING_KEYS);
	Tcl_InitHashTable(&(class->children),TCL_STRING_KEYS);
	Tcl_InitHashTable(&(class->subclasses),TCL_STRING_KEYS);
	class->init = (Method *)NULL;
	class->destroy = (Method *)NULL;
	class->classdestroy = (Method *)NULL;
	class->parent = (Class *)NULL;
	class->token = Tcl_CreateObjCommand(interp,"::Class",(Tcl_ObjCmdProc *)Classy_ClassObjCmd,
		(ClientData)class,(Tcl_CmdDeleteProc *)Classy_ClassDestroy);
	Classy_CreateClassMethod(interp,"::Class","classmethod",Classy_ClassMethodClassMethod);
	Classy_CreateClassMethod(interp,"::Class","deleteclassmethod",Classy_DeleteClassMethodClassMethod);
	Classy_CreateClassMethod(interp,"::Class","new",Classy_NewClassMethod);
	Classy_CreateClassMethod(interp,"::Class","method",Classy_MethodClassMethod);
	Classy_CreateClassMethod(interp,"::Class","deletemethod",Classy_DeleteMethodClassMethod);
	Classy_CreateClassMethod(interp,"::Class","subclass",Classy_SubclassClassMethod);
	Classy_CreateClassMethod(interp,"::Class","private",Classy_PrivateClassMethod);
	Classy_CreateMethod(interp,"::Class","info",Classy_InfoMethod);
	Classy_CreateMethod(interp,"::Class","private",Classy_PrivateMethod);
	Classy_CreateMethod(interp,"::Class","trace",Classy_TraceMethod);
	entry = Tcl_CreateHashEntry(&(class->methods),"destroy",&new);
	if (new == 1) {
		method = (Method *)Tcl_Alloc(sizeof(Method));
		Tcl_SetHashValue(entry,(ClientData)method);
	} else {
		method = (Method *)Tcl_GetHashValue(entry);
		Classy_FreeMethod(method);
	}
	method->copy = 0;
	method->proc = NULL;
	method->args = NULL;
	method->func = Classy_ObjectDestroyObjCmd;

	entry = Tcl_CreateHashEntry(&(class->classmethods),"destroy",&new);
	if (new == 1) {
		method = (Method *)Tcl_Alloc(sizeof(Method));
		Tcl_SetHashValue(entry,(ClientData)method);
	} else {
		method = (Method *)Tcl_GetHashValue(entry);
		Classy_FreeMethod(method);
	}
	method->copy = 0;
	method->proc = NULL;
	method->args = NULL;
	method->func = Classy_ClassDestroyObjCmd;
	return TCL_OK;
}

int Classy_ReinitObjCmd(
	ClientData clientdata,
	Tcl_Interp *interp,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Tcl_CmdInfo cmdinfo;
	int found, error;

	found = Tcl_GetCommandInfo(interp,"::Class",&cmdinfo);
	if (found == 1) {
		Tcl_DeleteCommand(interp,"::Class");
	}
	error = Classy_CreateClass(interp);
	return error;
}

