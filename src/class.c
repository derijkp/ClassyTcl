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

typedef struct Method {
	int copy;
	void *func;
	Tcl_Obj *proc;
} Method;

typedef struct Class {
	Tcl_Command token;
	struct Class *parent;
	Tcl_Interp *interp;
	Tcl_Obj *class;
	Tcl_HashTable methods;
	Tcl_HashTable classmethods;
	Tcl_HashTable children;
	Tcl_HashTable subclasses;
	Method *init;
	Method *classdestroy;
	Method *destroy;
} Class;

typedef struct Object {
	Tcl_Command token;
	Class *parent;
	Tcl_Obj *name;
} Object;

typedef int Classy_Method _ANSI_ARGS_((Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[]));

int Classy_ExecMethod(
	Tcl_Interp *interp,
	Method *method,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	int error,i;
	Tcl_Obj *execObj;
	if (method->proc != NULL) {
		/* Tcl 8.1 ?
			Tcl_Obj *objvstatic[10],**objv;
			if (argc<7) {
				objv = objvstatic;
			} else {
				objv = (Tcl_Obj **)Tcl_Alloc(sizeof(Tcl_Obj *));
			}
			objv[1] = method->proc;
			objv[2] = class->class;
			if (object != NULL) {
				objv[3] = object->name;
				pos = 4;
			} else {
				pos = 3;
			}
			for(i=0;i<argc;i++) {
				objv[pos++] = argv[i];
			}
			error = Tcl_EvalObjv(interp,pos,objv,Tcl_GetStringFromObj(method->proc,NULL),-1,TCL_EVAL_DIRECT);
			if (error != TCL_OK) {return error;}
			return error;
		*/
		execObj = Tcl_DuplicateObj(method->proc);
		error = Tcl_ListObjAppendElement(interp,execObj,class->class);
		if (error != TCL_OK) {return error;}
		if (object != NULL) {
			error = Tcl_ListObjAppendElement(interp,execObj,object->name);
			if (error != TCL_OK) {return error;}
		}
		for(i=0;i<argc;i++) {
			error = Tcl_ListObjAppendElement(interp,execObj,argv[i]);
			if (error != TCL_OK) {return error;}
		}
		error = Tcl_EvalObj(interp,execObj);
		if (error != TCL_OK) {return error;}
		return error;
	} else {
		error = ((Classy_Method *)method->func)(interp,class,object,argc,argv);
		return error;
	}
}

int Classy_FreeMethod(Method *method) {
	if (method->proc != NULL) {
		Tcl_DecrRefCount(method->proc);
	}
	return TCL_OK;
}

int Classy_FreeObject(Object *object) {
	if (object->name != NULL) {
		Tcl_DecrRefCount(object->name);
	}
	return TCL_OK;
}

void Classy_FreeClass(Class *class) {
	Tcl_HashEntry *entry;
	Tcl_HashSearch search;
	Method *method;

	/* todo: also all children, objects, vars, etc */
	if (class->init != NULL) {
		Classy_FreeMethod(class->init);
	}
	if (class->destroy != NULL) {
		Classy_FreeMethod(class->destroy);
	}
	if (class->classdestroy != NULL) {
		Classy_FreeMethod(class->classdestroy);
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
}

int Classy_CreateTclClassMethod(
	Tcl_Interp *interp,
	Method *method,
	Tcl_Obj *name,
	Tcl_Obj *args,
	Tcl_Obj *body)	
{
	Tcl_Obj *createObj, *realargs;
	int error;

	Tcl_IncrRefCount(name);
	method->copy = 0;
	method->proc = name;
	method->func = NULL;
	Tcl_IncrRefCount(method->proc);
	createObj = Tcl_NewStringObj("proc",4);
	error = Tcl_ListObjAppendElement(interp,createObj,method->proc);
	if (error != TCL_OK) {return error;}
	realargs = Tcl_NewStringObj("class",5);
	error = Tcl_ListObjAppendList(interp,realargs,args);
	if (error != TCL_OK) {return error;}
	error = Tcl_ListObjAppendElement(interp,createObj,realargs);
	if (error != TCL_OK) {return error;}
	error = Tcl_ListObjAppendElement(interp,createObj,body);
	if (error != TCL_OK) {return error;}
	Tcl_EvalObj(interp,createObj);
	return TCL_OK;
}

int Classy_CreateTclMethod(
	Tcl_Interp *interp,
	Method *method,
	Tcl_Obj *name,
	Tcl_Obj *args,
	Tcl_Obj *body)	
{
	Tcl_Obj *createObj, *realargs;
	int error;

	Tcl_IncrRefCount(name);
	method->copy = 0;
	method->proc = name;
	method->func = NULL;
	Tcl_IncrRefCount(method->proc);
	createObj = Tcl_NewStringObj("proc",4);
	error = Tcl_ListObjAppendElement(interp,createObj,method->proc);
	if (error != TCL_OK) {return error;}
	realargs = Tcl_NewStringObj("class object",12);
	error = Tcl_ListObjAppendList(interp,realargs,args);
	if (error != TCL_OK) {return error;}
	error = Tcl_ListObjAppendElement(interp,createObj,realargs);
	if (error != TCL_OK) {return error;}
	error = Tcl_ListObjAppendElement(interp,createObj,body);
	if (error != TCL_OK) {return error;}
	Tcl_EvalObj(interp,createObj);
	return TCL_OK;
}

int Classy_ClassMethodObjCmd(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Method *method;
	Tcl_HashEntry *entry;
	Tcl_Obj *procname;
	char *name;
	char *classname;
	int namelen, error,i, new;

	if (argc!=3) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(class->class,NULL),
			" classmethod name args body\"", (char *)NULL);
		return TCL_ERROR;
	}
	classname = Tcl_GetStringFromObj(class->class,NULL);
	name = Tcl_GetStringFromObj(argv[0],&namelen);
	if ((namelen == 11)&&(strncmp(name,"classmethod",11)==0)) {
	} else if ((namelen == 6)&&(strncmp(name,"method",6)==0)) {
	} else if ((namelen == 12)&&(strncmp(name,"deletemethod",12)==0)) {
	} else if ((namelen == 17)&&(strncmp(name,"deleteclassmethod",17)==0)) {
	} else if ((namelen == 8)&&(strncmp(name,"subclass",8)==0)) {
	} else if ((namelen == 6)&&(strncmp(name,"parent",6)==0)) {
	} else if ((namelen == 8)&&(strncmp(name,"children",8)==0)) {
	} else if ((namelen == 3)&&(strncmp(name,"new",3)==0)) {
	} else if ((namelen == 4)&&(strncmp(name,"init",4)==0)) {
		if (strcmp(classname,"Class")==0) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"init classmethod of base Class cannot be redefined", (char *)NULL);
			return TCL_ERROR;
		}
		if (class->init != NULL) {
			Classy_FreeMethod(class->init);
			Tcl_Free((char *)class->init);
		}
		method = (Method *)Tcl_Alloc(sizeof(Method));
		procname = Tcl_NewObj();
		Tcl_AppendStringsToObj(procname,"::class::",classname,",,init",(char *)NULL);
		error = Classy_CreateTclMethod(interp,method,procname,argv[1],argv[2]);
		if (error != TCL_OK) {Tcl_Free((char *)method);return error;}
		class->init=method;
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		return TCL_OK;
	} else if ((namelen == 7)&&(strncmp(name,"destroy",7)==0)) {
		if (strcmp(classname,"Class")==0) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"destroy classmethod of base Class cannot be redefined", (char *)NULL);
			return TCL_ERROR;
		}
		Tcl_GetStringFromObj(argv[1],&i);
		if (i!=0) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"destroy classmethod cannot have arguments", (char *)NULL);
			return TCL_ERROR;
		}
		if (class->classdestroy != NULL) {
			Classy_FreeMethod(class->classdestroy);
			Tcl_Free((char *)class->classdestroy);
		}
		method = (Method *)Tcl_Alloc(sizeof(Method));
		procname = Tcl_NewObj();
		Tcl_AppendStringsToObj(procname,"::class::",classname,",,classdestroy",(char *)NULL);
		error = Classy_CreateTclClassMethod(interp,method,procname,argv[1],argv[2]);
		if (error != TCL_OK) {Tcl_Free((char *)method);return error;}
		class->classdestroy=method;
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		return TCL_OK;
	} else {
		entry = Tcl_CreateHashEntry(&(class->classmethods),name,&new);
		if (new == 1) {
			method = (Method *)Tcl_Alloc(sizeof(Method));
			Tcl_SetHashValue(entry,(ClientData)method);
		} else {
			method = (Method *)Tcl_GetHashValue(entry);
			Classy_FreeMethod(method);
		}
		procname = Tcl_NewObj();
		Tcl_AppendStringsToObj(procname,"::class::",classname,",,cm,",name,(char *)NULL);
		error = Classy_CreateTclClassMethod(interp,method,procname,argv[1],argv[2]);
		if (error != TCL_OK) {return error;}
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		return TCL_OK;
	}
	Tcl_ResetResult(interp);
	Tcl_AppendResult(interp, "\"", name, "\" classmethod cannot be redefined", (char *)NULL);
	return TCL_ERROR;
}

int Classy_MethodObjCmd(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Method *method;
	Tcl_HashEntry *entry;
	Tcl_Obj *procname;
	char *name;
	char *classname;
	int namelen, error,i, new;

	if (argc!=3) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(class->class,NULL),
			" method name args body\"", (char *)NULL);
		return TCL_ERROR;
	}
	classname = Tcl_GetStringFromObj(class->class,NULL);
	name = Tcl_GetStringFromObj(argv[0],&namelen);
	if ((namelen == 7)&&(strncmp(name,"destroy",7)==0)) {
		if (strcmp(classname,"Class")==0) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"destroy method of base Class cannot be redefined", (char *)NULL);
			return TCL_ERROR;
		}
		Tcl_GetStringFromObj(argv[1],&i);
		if (i!=0) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"destroy method cannot have arguments", (char *)NULL);
			return TCL_ERROR;
		}
		if (class->destroy != NULL) {
			Classy_FreeMethod(class->destroy);
			Tcl_Free((char *)class->destroy);
		}
		method = (Method *)Tcl_Alloc(sizeof(Method));
		procname = Tcl_NewObj();
		Tcl_AppendStringsToObj(procname,"::class::",classname,",,destroy",(char *)NULL);
		error = Classy_CreateTclMethod(interp,method,procname,argv[1],argv[2]);
		if (error != TCL_OK) {Tcl_Free((char *)method);return error;}
		class->destroy=method;
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		return TCL_OK;
	} else {
		entry = Tcl_CreateHashEntry(&(class->methods),name,&new);
		if (new == 1) {
			method = (Method *)Tcl_Alloc(sizeof(Method));
			Tcl_SetHashValue(entry,(ClientData)method);
		} else {
			method = (Method *)Tcl_GetHashValue(entry);
			Classy_FreeMethod(method);
		}
		procname = Tcl_NewObj();
		Tcl_AppendStringsToObj(procname,"::class::",classname,",,m,",name,(char *)NULL);
		error = Classy_CreateTclMethod(interp,method,procname,argv[1],argv[2]);
		if (error != TCL_OK) {return error;}
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		return TCL_OK;
	}
}

void Classy_CopyMethods(
	Tcl_HashTable *src,
	Tcl_HashTable *dst)
{
	Tcl_HashSearch search;
	Tcl_HashEntry *entry;
	Method *srcmethod,*method;
	char *key;
	int new;

	entry = Tcl_FirstHashEntry(src, &search);
	while(1) {
		if (entry == NULL) break;
		srcmethod = Tcl_GetHashValue(entry);
		key = Tcl_GetHashKey(src, entry);
		entry = Tcl_CreateHashEntry(dst,key,&new);
		if (new == 1) {
			method = (Method *)Tcl_Alloc(sizeof(Method));
			Tcl_SetHashValue(entry,(ClientData)method);
		} else {
			method = (Method *)Tcl_GetHashValue(entry);
			Classy_FreeMethod(method);
		}
		method->copy = 1;
		method->proc = srcmethod->proc;
		method->func = srcmethod->func;
		entry = Tcl_NextHashEntry(&search);
	}
}

int Classy_ClassObjCmd(
	ClientData clientdata,
	Tcl_Interp *interp,
	int argc,
	Tcl_Obj *CONST argv[])
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
		error = Classy_ExecMethod(interp,method,class,NULL,argc,argv);
		return error;
	}
	entry = Tcl_FindHashEntry(&(class->methods), cmd);
	if (entry != NULL) {
		Method *method;
		method = (Method *)Tcl_GetHashValue(entry);
		error = Classy_ExecMethod(interp,method,class,NULL,argc,argv);
		return error;
	}
	Tcl_ResetResult(interp);
	Tcl_AppendResult(interp,"bad option \"",cmd ,"\" must be ...", (char *)NULL);
	return TCL_ERROR;
}

void Classy_ClassDestroy(ClientData clientdata) {
	Tcl_Interp *interp;
	Class *class, *parent, *subclass;
	Object *object;
	Tcl_HashSearch search;
	Tcl_HashEntry *entry;
	char *string;

	class = (Class *)clientdata;
	interp = class->interp;
	if (class->classdestroy != NULL) {
		Classy_ExecMethod(interp,class->classdestroy,class,NULL,0,NULL);
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
		Tcl_DeleteHashEntry(entry);
	}
	Tcl_VarEval(interp,"foreach var [info vars ::class::", string,",,*] {unset $var}", (char *)NULL);
	Tcl_VarEval(interp,"foreach cmd [info commands ::class::", string,",,*] {rename $cmd {}}", (char *)NULL);
	Classy_FreeClass(class);
	Tcl_Free((char *)class);
}

int Classy_SubclassObjCmd(
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
			error = Tcl_VarEval(interp,"namespace eval ",subclassname, " {
				catch {namespace import ::class::super}
				catch {namespace import ::class::private}
				catch {namespace import ::class::privatevar}
				catch {namespace import ::class::setprivate}
				catch {namespace import ::class::getprivate}
			}");
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
		subclass = (Class *)Tcl_GetHashValue(entry);
		Classy_FreeClass(subclass);
	}
	subclass->parent = class;
	subclass->class = name;
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
	error = Tcl_VarEval(interp,"foreach var [info vars ::class::", classname, ",,v,*] {",
		"regexp {^::class::", classname, ",,v,(.*)$} $var temp name ",
		"if [array exists $var] {",
			"array set ::class::", subclassname , ",,v,${name} [array get $var]",
		"} else {",
			"set ::class::", subclassname , ",,v,${name} [set $var]",
		"}}",(char *)NULL);
	if (error != TCL_OK) {return error;}
	Tcl_SetObjResult(interp,name);
	return TCL_OK;
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
	cmd = Tcl_GetStringFromObj(argv[1],NULL);
	argv+=2;
	argc-=2;
	entry = Tcl_FindHashEntry(&(class->methods), cmd);
	if (entry != NULL) {
		Method *method;
		method = (Method *)Tcl_GetHashValue(entry);
		error = Classy_ExecMethod(interp,method,class,object,argc,argv);
		return error;
	}
	Tcl_ResetResult(interp);
	Tcl_AppendResult(interp,"bad option \"",cmd ,"\" must be ...", (char *)NULL);
	return TCL_ERROR;
}

void Classy_ObjectDestroy(ClientData clientdata) {
	Class *class, *tempclass;
	Object *object;
	Tcl_HashEntry *entry;
	char *string;

	object = (Object *)clientdata;
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
	Tcl_DeleteHashEntry(entry);
	Tcl_VarEval(class->interp,"foreach var [info vars ::class::", string,",,*] {unset $var}", (char *)NULL);
	Classy_FreeObject(object);
	Tcl_Free((char *)object);
}

int Classy_ObjectDestroyObjCmd(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Tcl_DeleteCommandFromToken(interp,object->token);
	return TCL_OK;
}

int Classy_ClassDestroyObjCmd(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Tcl_DeleteCommandFromToken(interp,class->token);
	return TCL_OK;
}

int Classy_NewObjCmd(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Class *tempclass;
	Tcl_HashEntry *entry;
	Tcl_Obj *name;
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
			error = Tcl_VarEval(interp,"namespace eval ",string, " {}");
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
		object = (Object *)Tcl_GetHashValue(entry);
		Classy_FreeObject(object);
	}
	object->parent = class;
	object->name = name;
	Tcl_IncrRefCount(name);
	object->token = Tcl_CreateObjCommand(interp,string,(Tcl_ObjCmdProc *)Classy_ObjectObjCmd,
		(ClientData)object,(Tcl_CmdDeleteProc *)Classy_ObjectDestroy);
	tempclass = class;
	while(1) {
		if (tempclass->init != NULL) {
			error = Classy_ExecMethod(interp,tempclass->init,class,object,argc-1,argv+1);
			if (error != TCL_OK) {
				Classy_FreeObject(object);
				Tcl_Free((char *)object);
				Tcl_DeleteHashEntry(entry);
			}
			return error;
		}
		tempclass = tempclass->parent;
		if (tempclass == NULL) break;
	}
	Tcl_SetObjResult(interp,name);
	return TCL_OK;
}

int Classy_CreateClassMethod(
	Tcl_Interp *interp,
	char *classname,
	char *name,
	Classy_Method *func) 
{
	Tcl_CmdInfo cmdinfo;
	Class *class;
	Method *method;
	Tcl_HashEntry *entry;
	int namelen,new,found;

	found = Tcl_GetCommandInfo(interp,classname,&cmdinfo);
	if (found == 0) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"class \"",classname,"\" does not exist", (char *)NULL);
		return TCL_ERROR;
	}
	class = (Class *)cmdinfo.objClientData;
	namelen = strlen(name);
	if ((namelen == 4)&&(strncmp(name,"init",4)==0)) {
		if (class->init != NULL) {
			Classy_FreeMethod(class->init);
			Tcl_Free((char *)class->init);
		}
		method = (Method *)Tcl_Alloc(sizeof(Method));
		method->copy = 0;
		method->proc = NULL;
		method->func = func;
		class->init=method;
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		return TCL_OK;
	} else if ((namelen == 7)&&(strncmp(name,"destroy",7)==0)) {
		if (class->classdestroy != NULL) {
			Classy_FreeMethod(class->classdestroy);
			Tcl_Free((char *)class->classdestroy);
		}
		method = (Method *)Tcl_Alloc(sizeof(Method));
		method->copy = 0;
		method->proc = NULL;
		method->func = func;
		class->classdestroy=method;
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		return TCL_OK;
	} else {
		entry = Tcl_CreateHashEntry(&(class->classmethods),name,&new);
		if (new == 1) {
			method = (Method *)Tcl_Alloc(sizeof(Method));
			Tcl_SetHashValue(entry,(ClientData)method);
		} else {
			method = (Method *)Tcl_GetHashValue(entry);
			Classy_FreeMethod(method);
		}
		method->copy = 0;
		method->proc = NULL;
		method->func = func;
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		return TCL_OK;
	}
}

int Classy_CreateMethod(
	Tcl_Interp *interp,
	char *classname,
	char *name,
	Classy_Method *func) 
{
	Tcl_CmdInfo cmdinfo;
	Class *class;
	Method *method;
	Tcl_HashEntry *entry;
	int namelen,new,found;

	found = Tcl_GetCommandInfo(interp,classname,&cmdinfo);
	if (found == 0) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"class \"",classname,"\" does not exist", (char *)NULL);
		return TCL_ERROR;
	}
	class = (Class *)cmdinfo.objClientData;
	namelen = strlen(name);
	if ((namelen == 7)&&(strncmp(name,"destroy",7)==0)) {
		if (class->destroy != NULL) {
			Classy_FreeMethod(class->destroy);
			Tcl_Free((char *)class->destroy);
		}
		method = (Method *)Tcl_Alloc(sizeof(Method));
		method->copy = 0;
		method->proc = NULL;
		method->func = func;
		class->destroy=method;
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		return TCL_OK;
	} else {
		entry = Tcl_CreateHashEntry(&(class->methods),name,&new);
		if (new == 1) {
			method = (Method *)Tcl_Alloc(sizeof(Method));
			Tcl_SetHashValue(entry,(ClientData)method);
		} else {
			method = (Method *)Tcl_GetHashValue(entry);
			Classy_FreeMethod(method);
		}
		method->copy = 0;
		method->proc = NULL;
		method->func = func;
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		return TCL_OK;
	}
}

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
	Classy_CreateClassMethod(interp,"::Class","classmethod",Classy_ClassMethodObjCmd);
	Classy_CreateClassMethod(interp,"::Class","new",Classy_NewObjCmd);
	Classy_CreateClassMethod(interp,"::Class","method",Classy_MethodObjCmd);
	Classy_CreateClassMethod(interp,"::Class","subclass",Classy_SubclassObjCmd);
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

int Classy_ClassInit(interp)
	Tcl_Interp *interp;
{
	int error;

	error = Classy_CreateClass(interp);
	if (error != TCL_OK) {return error;}
	Tcl_CreateObjCommand(interp,"class::reinit",(Tcl_ObjCmdProc *)Classy_ReinitObjCmd,
		(ClientData)NULL,(Tcl_CmdDeleteProc *)NULL);
	return TCL_OK;
}

