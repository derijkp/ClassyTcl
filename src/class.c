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

int Classy_ExecClassMethod(
	Tcl_Interp *interp,
	Method *method,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	int error,i;
	if (method->proc != NULL) {
		Tcl_CmdInfo cmdinfo;
		Tcl_Obj *objvstatic[10],**objv;\
		int objc;

		if ((argc < method->min)||((method->max != -1)&&(argc > method->max))) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(class->class,NULL), 
				" ", Tcl_GetStringFromObj(method->args,NULL), "\"", (char *)NULL);
			return TCL_ERROR;
		}

		if (argc<7) {
			objv = objvstatic;
		} else {
			objv = (Tcl_Obj **)Tcl_Alloc((argc+3)*sizeof(Tcl_Obj *));
		}
		objv[0] = method->proc;
		objv[1] = class->class;
		objc = 2;
		for(i=0;i<argc;i++) {
			objv[objc++] = argv[i];
		}
		objv[objc] = NULL;
		i = Tcl_GetCommandInfo(interp,Tcl_GetStringFromObj(method->proc,NULL),&cmdinfo);
		if (i==0) {return TCL_OK;}
		error = cmdinfo.objProc(cmdinfo.objClientData,interp,objc,objv);
		return error;
	} else {
		error = ((Classy_Method *)method->func)(interp,class,object,argc,argv);
		return error;
	}
}

int Classy_ExecMethod(
	Tcl_Interp *interp,
	Method *method,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	int error,i;
	if (method->proc != NULL) {
		Tcl_CmdInfo cmdinfo;
		Tcl_Obj *objvstatic[20],**objv;\
		int objc;

		if ((argc < method->min)||((method->max != -1)&&(argc > method->max))) {
			Tcl_ResetResult(interp);
			if (object != NULL) {
				Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(object->name,NULL), 
					" ", Tcl_GetStringFromObj(method->args,NULL), "\"", (char *)NULL);
			} else {
				Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(class->class,NULL), 
					" ", Tcl_GetStringFromObj(method->args,NULL), "\"", (char *)NULL);
			}
			return TCL_ERROR;
		}

		if (argc<16) {
			objv = objvstatic;
		} else {
			objv = (Tcl_Obj **)Tcl_Alloc((argc+4)*sizeof(Tcl_Obj *));
		}
		objv[0] = method->proc;
		objv[1] = class->class;
		if (object != NULL) {
			objv[2] = object->name;
		} else {
			objv[2] = class->class;
		}
		objc = 3;
		for(i=0;i<argc;i++) {
			objv[objc++] = argv[i];
		}
		objv[objc] = NULL;
		i = Tcl_GetCommandInfo(interp,Tcl_GetStringFromObj(method->proc,NULL),&cmdinfo);
		if (i == 0) {return TCL_OK;}
		error = cmdinfo.objProc(cmdinfo.objClientData,interp,objc,objv);
		return error;
	} else {
		error = ((Classy_Method *)method->func)(interp,class,object,argc,argv);
		return error;
	}
}

int Classy_FreeMethod(Method *method) {
	if (method->proc != NULL) {
		Tcl_DecrRefCount(method->proc);
		method->proc = NULL;
	}
	if (method->args != NULL) {
		Tcl_DecrRefCount(method->args);
		method->args = NULL;
	}
	return TCL_OK;
}

int Classy_FreeObject(Object *object) {
	if (object->name != NULL) {
		Tcl_DecrRefCount(object->name);
		object->name = NULL;
	}
	if (object->trace != NULL) {
		Tcl_DecrRefCount(object->trace);
		object->trace = NULL;
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
}

int Classy_ParseArgs(
	Tcl_Interp *interp,
	Tcl_Obj *args,
	int *minptr,
	int *maxptr,
	Tcl_Obj *resultargs)
{
	Tcl_Obj **objv, *temp, *temp2;
	int objc,i,len,min,max,error;

	min = 0;
	max = 0;
	error = Tcl_ListObjGetElements(interp, args, &objc, &objv);
	if (error != TCL_OK) {return error;}
	if (objc==0) {
		min = 0;
		max = 0;
	} else {
		for(i=0;i<objc;i++) {
			error = Tcl_ListObjLength(interp, objv[i], &len);
			if (error != TCL_OK) {return error;}
			if (len == 1) {
				min++;
				max++;
				error = Tcl_ListObjAppendElement(interp, resultargs, objv[i]);
				if (error == TCL_ERROR) {return error;}
			} else {
				max++;
				temp = Tcl_NewStringObj("?",1);
				error = Tcl_ListObjIndex(interp, objv[i], 0, &temp2);
				if (error == TCL_ERROR) {return error;}
				Tcl_AppendStringsToObj(temp,Tcl_GetStringFromObj(temp2,NULL),"?",NULL);
				error = Tcl_ListObjAppendElement(interp, resultargs, temp);
				if (error == TCL_ERROR) {return error;}
			}
		}
		if (strcmp(Tcl_GetStringFromObj(objv[objc-1],NULL),"args")==0) {
			min--;
			max = -1;
			error = Tcl_ListObjLength(interp, resultargs, &len);
			if (error == TCL_ERROR) {return error;}
			temp = Tcl_NewStringObj("...",3);
			error = Tcl_ListObjReplace(interp, resultargs, len-1, 1, 1, &temp);
			if (error == TCL_ERROR) {return error;}
		}
	}
	*minptr = min;
	*maxptr = max;
	return TCL_OK;
}

int Classy_CreateTclClassMethod(
	Tcl_Interp *interp,
	Method *method,
	Tcl_Obj *name,
	Tcl_Obj *args,
	Tcl_Obj *body,
	char *rname)	
{
	Tcl_Obj *createObj, *realargs;
	int error;
	method->copy = 0;
	method->func = NULL;
	method->proc = name;
	Tcl_IncrRefCount(method->proc);
	method->args = Tcl_NewStringObj(rname,strlen(rname));
	Tcl_IncrRefCount(method->args);
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
	error = Tcl_EvalObj(interp,createObj);
	if (error != TCL_OK) {return error;}
	error = Classy_ParseArgs(interp,args,&(method->min),&(method->max),method->args);
	return error;
}

int Classy_CreateTclMethod(
	Tcl_Interp *interp,
	Method *method,
	Tcl_Obj *name,
	Tcl_Obj *args,
	Tcl_Obj *body,
	char *rname)	
{
	Tcl_Obj *createObj, *realargs;
	int error;

	method->copy = 0;
	method->proc = name;
	method->func = NULL;
	Tcl_IncrRefCount(method->proc);
	method->args = Tcl_NewStringObj(rname,strlen(rname));
	Tcl_IncrRefCount(method->args);
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
	if (error != TCL_OK) {return error;}
	error = Classy_ParseArgs(interp,args,&(method->min),&(method->max),method->args);
	return error;
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
		if (method->proc != NULL) {Tcl_IncrRefCount(method->proc);}
		method->args = srcmethod->args;
		if (method->args != NULL) {Tcl_IncrRefCount(method->args);}
		method->func = srcmethod->func;
		method->min = srcmethod->min;
		method->max = srcmethod->max;
		entry = Tcl_NextHashEntry(&search);
	}
}

int Classy_CopyMethod(
	Tcl_HashTable *src,
	Tcl_HashTable *dst,
	char *name)
{
	Tcl_HashEntry *entry;
	Method *srcmethod,*method;
	int new;

	entry = Tcl_FindHashEntry(src, name);
	if (entry == NULL) {return 0;}
	srcmethod = Tcl_GetHashValue(entry);
	entry = Tcl_CreateHashEntry(dst,name,&new);
	if (new == 1) {
		method = (Method *)Tcl_Alloc(sizeof(Method));
		Tcl_SetHashValue(entry,(ClientData)method);
	} else {
		method = (Method *)Tcl_GetHashValue(entry);
		if (method->copy == 0) {return 0;}
		Classy_FreeMethod(method);
	}
	method->copy = 1;
	method->proc = srcmethod->proc;
	if (method->proc != NULL) {Tcl_IncrRefCount(method->proc);}
	method->args = srcmethod->args;
	if (method->args != NULL) {Tcl_IncrRefCount(method->args);}
	method->func = srcmethod->func;
	method->min = srcmethod->min;
	method->max = srcmethod->max;
	return 1;
}

int Classy_PropagateMethod(
	Tcl_Interp *interp,
	Class *class,
	int type,
	char *name)
{
	Tcl_HashEntry *entry;
	Tcl_HashSearch search;
	Class *subclass;
	int done,error;

	entry = Tcl_FirstHashEntry(&(class->subclasses), &search);
	while(1) {
		if (entry == NULL) break;
		subclass = (Class *)Tcl_GetHashValue(entry);
		if (type == 'm') {
			done = Classy_CopyMethod(&(class->methods),&(subclass->methods),name);
		} else {
			done = Classy_CopyMethod(&(class->classmethods),&(subclass->classmethods),name);
		}
		if (done == 1) {
			error = Classy_PropagateMethod(interp,subclass,type,name);
			if (error != TCL_OK) {return error;}
		}
		entry = Tcl_NextHashEntry(&search);
	}
	return TCL_OK;
}

int Classy_PropagateDeleteMethod(
	Tcl_Interp *interp,
	Class *class,
	int type,
	char *name)
{
	Tcl_HashEntry *entry,*mentry;
	Tcl_HashSearch search;
	Class *subclass;
	Method *method;
	int error;

	entry = Tcl_FirstHashEntry(&(class->subclasses), &search);
	while(1) {
		if (entry == NULL) break;
		subclass = (Class *)Tcl_GetHashValue(entry);
		if (type == 'm') {
			mentry = Tcl_FindHashEntry(&(subclass->methods),name);
		} else {
			mentry = Tcl_FindHashEntry(&(subclass->classmethods),name);
		}
		if (mentry != NULL) {
			method = Tcl_GetHashValue(mentry);
			if (method->copy != 0) {
				Classy_FreeMethod(method);
				Tcl_DeleteHashEntry(entry);
				error = Classy_PropagateDeleteMethod(interp,subclass,type,name);
				if (error != TCL_OK) {return error;}
			}
		}
		entry = Tcl_NextHashEntry(&search);
	}
	return TCL_OK;
}

int Classy_ClassMethodClassMethod(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Method *method;
	Tcl_HashEntry *entry;
	Tcl_Obj *procname, *temp;
	char *name;
	char *classname;
	int namelen,error,i,new;

	if (argc==0) {
		Tcl_HashEntry *entry;
		Tcl_HashSearch search;
		entry = Tcl_FirstHashEntry(&(class->classmethods), &search);
		while(1) {
			if (entry == NULL) break;
			name = Tcl_GetHashKey(&(class->methods),entry);
			if (name[0] != '_') {
				Tcl_AppendElement(interp, name);
			}
			entry = Tcl_NextHashEntry(&search);
		}
		temp = Tcl_NewStringObj("lsort",5);
		error = Tcl_ListObjAppendElement(interp,temp,Tcl_GetObjResult(interp));
		if (error != TCL_OK) {return error;}
		error = Tcl_EvalObj(interp,temp);
		return error;
	} else if (argc==1) {
		Tcl_HashEntry *entry;
		Tcl_HashSearch search;
		char *pattern;
		pattern = Tcl_GetStringFromObj(argv[0],NULL);
		entry = Tcl_FirstHashEntry(&(class->classmethods), &search);
		while(1) {
			if (entry == NULL) break;
			name = Tcl_GetHashKey(&(class->methods),entry);
			if (Tcl_StringMatch(name, pattern) == 2) {
				Tcl_AppendElement(interp, name);
			}
			entry = Tcl_NextHashEntry(&search);
		}
		temp = Tcl_NewStringObj("lsort",5);
		error = Tcl_ListObjAppendElement(interp,temp,Tcl_GetObjResult(interp));
		if (error != TCL_OK) {return error;}
		error = Tcl_EvalObj(interp,temp);
		return error;
	} else if (argc!=3) {
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
			class->init = NULL;
		}
		method = (Method *)Tcl_Alloc(sizeof(Method));
		procname = Tcl_NewObj();
		Tcl_AppendStringsToObj(procname,"::class::",classname,",,init",(char *)NULL);
		error = Classy_CreateTclMethod(interp,method,procname,argv[1],argv[2],"init");
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
		error = Classy_CreateTclClassMethod(interp,method,procname,argv[1],argv[2],"classdestroy");
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
		error = Classy_CreateTclClassMethod(interp,method,procname,argv[1],argv[2],name);
		if (error != TCL_OK) {return error;}
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		error = Classy_PropagateMethod(interp,class,'c',name);
		if (error != TCL_OK) {return error;}
		return TCL_OK;
	}
	Tcl_ResetResult(interp);
	Tcl_AppendResult(interp, "\"", name, "\" classmethod cannot be redefined", (char *)NULL);
	return TCL_ERROR;
}

int Classy_DeleteClassMethodClassMethod(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Method *method;
	Tcl_HashEntry *entry;
	Tcl_Obj *string;
	char *name;
	char *classname;
	int namelen,error;

	if (argc!=1) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(class->class,NULL),
			" deleteclassmethod name\"", (char *)NULL);
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
			Tcl_AppendResult(interp,"init classmethod of base Class cannot be deleted", (char *)NULL);
			return TCL_ERROR;
		}
		if (class->init != NULL) {
			Classy_FreeMethod(class->init);
			Tcl_Free((char *)class->init);
			class->init = NULL;
			string = Tcl_NewObj();
			Tcl_AppendStringsToObj(string,"rename ::class::",classname,",,init {}",(char *)NULL);
			Tcl_EvalObj(interp,string);
		}
		Tcl_ResetResult(interp);
		return TCL_OK;
	} else if ((namelen == 7)&&(strncmp(name,"destroy",7)==0)) {
		if (strcmp(classname,"Class")==0) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"destroy classmethod of base Class cannot be deleted", (char *)NULL);
			return TCL_ERROR;
		}
		if (class->classdestroy != NULL) {
			Classy_FreeMethod(class->classdestroy);
			Tcl_Free((char *)class->classdestroy);
			class->classdestroy = NULL;
			string = Tcl_NewObj();
			Tcl_AppendStringsToObj(string,"rename ::class::",classname,",,classdestroy {}",(char *)NULL);
			Tcl_EvalObj(interp,string);
		}
		Tcl_ResetResult(interp);
		return TCL_OK;
	} else {
		entry = Tcl_FindHashEntry(&(class->classmethods),name);
		method = (Method *)Tcl_GetHashValue(entry);
		Classy_FreeMethod(method);
		Tcl_DeleteHashEntry(entry);
		string = Tcl_NewObj();
		Tcl_AppendStringsToObj(string,"rename ::class::",classname,",,cm,",name," {}",(char *)NULL);
		Tcl_EvalObj(interp,string);
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		error = Classy_PropagateDeleteMethod(interp,class,'c',name);
		if (error != TCL_OK) {return error;}
		Tcl_ResetResult(interp);
		return TCL_OK;
	}
	Tcl_ResetResult(interp);
	Tcl_AppendResult(interp, "\"", name, "\" classmethod cannot be delted", (char *)NULL);
	return TCL_ERROR;
}

int Classy_MethodClassMethod(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Method *method;
	Tcl_HashEntry *entry;
	Tcl_Obj *procname, *temp;
	char *name;
	char *classname;
	int namelen, error,i, new;

	if (argc==0) {
		Tcl_HashEntry *entry;
		Tcl_HashSearch search;
		entry = Tcl_FirstHashEntry(&(class->methods), &search);
		while(1) {
			if (entry == NULL) break;
			name = Tcl_GetHashKey(&(class->methods),entry);
			if (name[0] != '_') {
				Tcl_AppendElement(interp, name);
			}
			entry = Tcl_NextHashEntry(&search);
		}
		temp = Tcl_NewStringObj("lsort",5);
		error = Tcl_ListObjAppendElement(interp,temp,Tcl_GetObjResult(interp));
		if (error != TCL_OK) {return error;}
		error = Tcl_EvalObj(interp,temp);
		return error;
	} else if (argc==1) {
		Tcl_HashEntry *entry;
		Tcl_HashSearch search;
		char *pattern;
		pattern = Tcl_GetStringFromObj(argv[0],NULL);
		entry = Tcl_FirstHashEntry(&(class->methods), &search);
		while(1) {
			if (entry == NULL) break;
			name = Tcl_GetHashKey(&(class->methods),entry);
			if (Tcl_StringMatch(name, pattern) == 2) {
				Tcl_AppendElement(interp, name);
			}
			entry = Tcl_NextHashEntry(&search);
		}
		temp = Tcl_NewStringObj("lsort",5);
		error = Tcl_ListObjAppendElement(interp,temp,Tcl_GetObjResult(interp));
		if (error != TCL_OK) {return error;}
		error = Tcl_EvalObj(interp,temp);
		return error;
	} else if (argc!=3) {
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
		error = Classy_CreateTclMethod(interp,method,procname,argv[1],argv[2],"destroy");
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
		error = Classy_CreateTclMethod(interp,method,procname,argv[1],argv[2],name);
		if (error != TCL_OK) {return error;}
		error = Classy_PropagateMethod(interp,class,'m',name);
		if (error != TCL_OK) {return error;}
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		return TCL_OK;
	}
}

int Classy_DeleteMethodClassMethod(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Method *method;
	Tcl_HashEntry *entry;
	Tcl_Obj *string;
	char *name;
	char *classname;
	int namelen, error;

	if (argc!=1) {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(class->class,NULL),
			" deletemethod\"", (char *)NULL);
		return TCL_ERROR;
	}

	classname = Tcl_GetStringFromObj(class->class,NULL);
	name = Tcl_GetStringFromObj(argv[0],&namelen);
	if ((namelen == 7)&&(strncmp(name,"destroy",7)==0)) {
		if (strcmp(classname,"Class")==0) {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"destroy method of base Class cannot be deleted", (char *)NULL);
			return TCL_ERROR;
		}
		if (class->destroy != NULL) {
			Classy_FreeMethod(class->destroy);
			Tcl_Free((char *)class->destroy);
			class->destroy = NULL;
			string = Tcl_NewObj();
			Tcl_AppendStringsToObj(string,"rename ::class::",classname,",,destroy {}",(char *)NULL);
			Tcl_EvalObj(interp,string);
		}
		Tcl_ResetResult(interp);
		return TCL_OK;
	} else {
		entry = Tcl_FindHashEntry(&(class->methods),name);
		method = (Method *)Tcl_GetHashValue(entry);
		Classy_FreeMethod(method);
		Tcl_DeleteHashEntry(entry);
		string = Tcl_NewObj();
		Tcl_AppendStringsToObj(string,"rename ::class::",classname,",,m,",name," {}",(char *)NULL);
		Tcl_EvalObj(interp,string);
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		error = Classy_PropagateDeleteMethod(interp,class,'m',name);
		if (error != TCL_OK) {return error;}
		Tcl_ResetResult(interp);
		return TCL_OK;
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
	if (class->trace != NULL) {
		Tcl_Obj *cmd;
		cmd = Tcl_DuplicateObj(class->trace);
		error = Tcl_ListObjAppendElement(interp, cmd, Tcl_NewListObj(argc,argv));
		if (error != TCL_OK) {return error;}
		error = Tcl_EvalObj(interp,cmd);
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
		error = Classy_ExecClassMethod(interp,method,class,NULL,argc,argv);
		if (error == TCL_ERROR) {
			Tcl_Obj *errorObj=Tcl_NewStringObj("\nwhile invoking classmethod \"",29);
			Tcl_AppendStringsToObj(errorObj, cmd, "\" of class \"", Tcl_GetStringFromObj(class->class,NULL), "\"\n", (char *) NULL);
			Tcl_AddObjErrorInfo(interp, Tcl_GetStringFromObj(errorObj,NULL), -1);
		}
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
		}
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
	Tcl_VarEval(interp,"foreach var [info vars ::class::", string,",,*] {unset $var}", (char *)NULL);
	Tcl_VarEval(interp,"foreach cmd [info commands ::class::", string,",,*] {rename $cmd {}}", (char *)NULL);
	Classy_FreeClass(class);
	Tcl_Free((char *)class);
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
			error = Tcl_VarEval(interp,"namespace eval ::class::",subclassname, " {
				catch {namespace import ::class::super}
				catch {namespace import ::class::private}
				catch {namespace import ::class::privatevar}
				catch {namespace import ::class::setprivate}
				catch {namespace import ::class::getprivate}
			}",(char *)NULL);
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
	error = Tcl_VarEval(interp,"foreach var [info vars ::class::", classname, ",,v,*] {",
		"regexp {^::class::", classname, ",,v,(.*)$} $var temp name \n",
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
	if (object->trace != NULL) {
		Tcl_Obj *cmd;
		cmd = Tcl_DuplicateObj(object->trace);
		error = Tcl_ListObjAppendElement(interp, cmd, Tcl_NewListObj(argc,argv));
		if (error != TCL_OK) {return error;}
		error = Tcl_EvalObj(interp,cmd);
		if (error != TCL_OK) {return error;}
	}
	cmd = Tcl_GetStringFromObj(argv[1],NULL);
	argv+=2;
	argc-=2;
	entry = Tcl_FindHashEntry(&(class->methods), cmd);
	if (entry != NULL) {
		Method *method;
		Tcl_Obj *name = Tcl_DuplicateObj(object->name);
		method = (Method *)Tcl_GetHashValue(entry);
		error = Classy_ExecMethod(interp,method,class,object,argc,argv);
		if (error != TCL_OK) {
			Tcl_Obj *errorObj=Tcl_NewStringObj("\nwhile invoking method \"",24);
			Tcl_AppendStringsToObj(errorObj, cmd, "\" of object \"", Tcl_GetStringFromObj(name,NULL), "\"\n", (char *) NULL);
			Tcl_AddObjErrorInfo(interp, Tcl_GetStringFromObj(errorObj,NULL), -1);
			return error;
		}
		return TCL_OK;
	} else {
		Tcl_Obj *result, **objv;
		int objc,i;
		Tcl_ResetResult(interp);
		error = Classy_MethodClassMethod(interp,class,object,0,NULL);
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

static Class *classcurrent = NULL;

int Classy_NewClassMethod(
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
		object = (Object *)Tcl_GetHashValue(entry);
		Classy_FreeObject(object);
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
				Tcl_Obj *name = Tcl_DuplicateObj(object->name);
				Tcl_Obj *errorObj, *errorinfo;
				errorObj = Tcl_GetObjResult(interp);
				Tcl_IncrRefCount(errorObj);
				errorinfo = Tcl_ObjGetVar2(interp, Tcl_NewStringObj("errorInfo",-1), NULL, TCL_GLOBAL_ONLY);
				Tcl_IncrRefCount(errorinfo);
				Tcl_DeleteCommandFromToken(interp,object->token);
				Tcl_ResetResult(interp);
				Tcl_AddObjErrorInfo(interp, Tcl_GetStringFromObj(errorinfo,NULL), -1);
				Tcl_SetObjResult(interp,errorObj);
				Tcl_DecrRefCount(errorObj);
				Tcl_DecrRefCount(errorinfo);
				if (error == TCL_ERROR) {
					Tcl_Obj *errorObj=Tcl_NewStringObj("\nwhile invoking init method of object \"",39);
					Tcl_AppendStringsToObj(errorObj, Tcl_GetStringFromObj(name,NULL), "\"\n", (char *) NULL);
					Tcl_AddObjErrorInfo(interp, Tcl_GetStringFromObj(errorObj,NULL), -1);
				}
			}
			return error;
		}
		tempclass = tempclass->parent;
		if (tempclass == NULL) break;
	}
	Tcl_SetObjResult(interp,name);
	return TCL_OK;
}

extern int Classy_CreateClassMethod(
	Tcl_Interp *interp,
	char *classname,
	char *name,
	Classy_Method *func) 
{
	Tcl_CmdInfo cmdinfo;
	Class *class;
	Method *method;
	Tcl_HashEntry *entry;
	int namelen,new,found,error;

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
		method->args = NULL;
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
		method->args = NULL;
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
		method->args = NULL;
		method->func = func;
		error = Classy_PropagateMethod(interp,class,'c',name);
		if (error != TCL_OK) {return error;}
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		return TCL_OK;
	}
}

extern int Classy_CreateMethod(
	Tcl_Interp *interp,
	char *classname,
	char *name,
	Classy_Method *func) 
{
	Tcl_CmdInfo cmdinfo;
	Class *class;
	Method *method;
	Tcl_HashEntry *entry;
	int namelen,new,found,error;

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
		method->args = NULL;
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
		method->args = NULL;
		method->func = func;
		error = Classy_PropagateMethod(interp,class,'m',name);
		if (error != TCL_OK) {return error;}
		Tcl_SetResult(interp,name,TCL_VOLATILE);
		return TCL_OK;
	}
}

int Classy_PrivateMethod(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Tcl_Obj *temp,*res;
	int error;

	if (argc==0) {
		Tcl_Obj **objv,*result,*src;
		char *name;
		int len,start,objc,i;
		name = Tcl_GetStringFromObj(object->name, &len);
		error = Tcl_VarEval(interp, "lsort [info vars ::class::",name, ",,v,*]",(char *)NULL);
		if (error != TCL_OK) {return error;}
		src = Tcl_GetObjResult(interp);
		error = Tcl_ListObjGetElements(interp, src, &objc, &objv);
		if (error != TCL_OK) {return error;}
		start = len + 13;
		result = Tcl_NewObj();
		i = 0;
		while(i<objc) {
			name = Tcl_GetStringFromObj(objv[i],&len);
			error = Tcl_ListObjAppendElement(interp, result, Tcl_NewStringObj(name+start,len-start));
			if (error != TCL_OK) {return error;}
			i++;
		}
		Tcl_SetObjResult(interp,result);
		return TCL_OK;
	} else if (argc==1) {
		temp = Tcl_NewObj();
		Tcl_AppendStringsToObj(temp, "::class::", Tcl_GetStringFromObj(object->name,NULL), ",,v,", 
			Tcl_GetStringFromObj(argv[0],NULL), (char *)NULL);
		res = Tcl_ObjGetVar2(interp,temp,NULL,TCL_PARSE_PART1|TCL_GLOBAL_ONLY);
		if (res != NULL) {
			Tcl_SetObjResult(interp,res);
			return TCL_OK;
		} else {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"\"", Tcl_GetStringFromObj(object->name,NULL), 
				"\" does not have a private variable \"", Tcl_GetStringFromObj(argv[0],NULL), "\"",NULL);
			return TCL_ERROR;
		}
	} else if (argc==2) {
		temp = Tcl_NewObj();
		Tcl_AppendStringsToObj(temp, "::class::", Tcl_GetStringFromObj(object->name,NULL), ",,v,", 
			Tcl_GetStringFromObj(argv[0],NULL), (char *)NULL);
		Tcl_SetObjResult(interp,Tcl_ObjSetVar2(interp,temp,NULL,argv[1],TCL_PARSE_PART1|TCL_GLOBAL_ONLY));
		return TCL_OK;
	} else {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(object->name,NULL),
			" private ?varName? ?newValue?\"", (char *)NULL);
		return TCL_ERROR;
	}
	return TCL_OK;
}

int Classy_PropagateVar(
	Tcl_Interp *interp,
	Class *class,
	Tcl_Obj *name,
	Tcl_Obj *value)
{
	Tcl_HashEntry *entry;
	Tcl_HashSearch search;
	Class *subclass;
	Tcl_Obj *val,*temp;
	int error;

	entry = Tcl_FirstHashEntry(&(class->subclasses), &search);
	while(1) {
		if (entry == NULL) break;
		subclass = (Class *)Tcl_GetHashValue(entry);
		temp = Tcl_NewObj();
		Tcl_AppendStringsToObj(temp, "::class::", Tcl_GetStringFromObj(subclass->class,NULL), ",,vd", (char *)NULL);
		val = Tcl_ObjGetVar2(interp, temp, name, TCL_GLOBAL_ONLY);
		if (val == NULL) {
			temp = Tcl_NewObj();
			Tcl_AppendStringsToObj(temp, "::class::", Tcl_GetStringFromObj(subclass->class,NULL), ",,v,", 
				Tcl_GetStringFromObj(name,NULL), (char *)NULL);
			Tcl_ObjSetVar2(interp,temp,NULL,value,TCL_PARSE_PART1|TCL_GLOBAL_ONLY);
			error = Classy_PropagateVar(interp,subclass,name,value);
			if (error != TCL_OK) {return error;}
		}
		entry = Tcl_NextHashEntry(&search);
	}
	return TCL_OK;
}

int Classy_PrivateClassMethod(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Tcl_Obj *temp,*res;
	int error;

	if (argc==0) {
		Tcl_Obj **objv,*result,*src;
		char *name;
		int len,start,objc,i;
		name = Tcl_GetStringFromObj(class->class, &len);
		error = Tcl_VarEval(interp, "lsort [info vars ::class::",name, ",,v,*]",(char *)NULL);
		if (error != TCL_OK) {return error;}
		src = Tcl_GetObjResult(interp);
		error = Tcl_ListObjGetElements(interp, src, &objc, &objv);
		if (error != TCL_OK) {return error;}
		start = len + 13;
		result = Tcl_NewObj();
		i = 0;
		while(i<objc) {
			name = Tcl_GetStringFromObj(objv[i],&len);
			error = Tcl_ListObjAppendElement(interp, result, Tcl_NewStringObj(name+start,len-start));
			if (error != TCL_OK) {return error;}
			i++;
		}
		Tcl_SetObjResult(interp,result);
		return TCL_OK;
	} else if (argc==1) {
		temp = Tcl_NewObj();
		Tcl_AppendStringsToObj(temp, "::class::", Tcl_GetStringFromObj(class->class,NULL), ",,v,", 
			Tcl_GetStringFromObj(argv[0],NULL), (char *)NULL);
		res = Tcl_ObjGetVar2(interp,temp,NULL,TCL_PARSE_PART1|TCL_GLOBAL_ONLY);
		if (res != NULL) {
			Tcl_SetObjResult(interp,res);
			return TCL_OK;
		} else {
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp,"\"", Tcl_GetStringFromObj(class->class,NULL), 
				"\" does not have a private variable \"", Tcl_GetStringFromObj(argv[0],NULL), "\"",NULL);
			return TCL_ERROR;
		}
	} else if (argc==2) {
		error = Classy_PropagateVar(interp,class,argv[0],argv[1]);
		if (error != TCL_OK) {return error;}
		temp = Tcl_NewObj();
		Tcl_AppendStringsToObj(temp, "::class::", Tcl_GetStringFromObj(class->class,NULL), ",,vd", (char *)NULL);
		temp = Tcl_ObjSetVar2(interp, temp, argv[0], Tcl_NewObj(), TCL_GLOBAL_ONLY|TCL_LEAVE_ERR_MSG);
		if (temp == NULL) {return TCL_ERROR;}
		temp = Tcl_NewObj();
		Tcl_AppendStringsToObj(temp, "::class::", Tcl_GetStringFromObj(class->class,NULL), ",,v,", 
			Tcl_GetStringFromObj(argv[0],NULL), (char *)NULL);
		Tcl_SetObjResult(interp,Tcl_ObjSetVar2(interp,temp,NULL,argv[1],TCL_PARSE_PART1|TCL_GLOBAL_ONLY));
		return TCL_OK;
	} else {
		Tcl_ResetResult(interp);
		Tcl_AppendResult(interp,"wrong # args: should be \"",Tcl_GetStringFromObj(class->class,NULL),
			" private ?varName? ?newValue?\"", (char *)NULL);
		return TCL_ERROR;
	}
	return TCL_OK;
}

int Classy_ClassMethod(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Tcl_SetObjResult(interp,class->class);
	return TCL_OK;
}

int Classy_ParentClassMethod(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Tcl_SetObjResult(interp,class->parent->class);
	return TCL_OK;
}

int Classy_ChildrenClassMethod(
	Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[])
{
	Tcl_HashEntry *entry;
	Tcl_HashSearch search;
	Tcl_Obj *temp;
	char *name;
	int error;

	entry = Tcl_FirstHashEntry(&(class->children), &search);
	while(1) {
		if (entry == NULL) break;
		name = Tcl_GetHashKey(&(class->methods),entry);
		Tcl_AppendElement(interp, name);
		entry = Tcl_NextHashEntry(&search);
	}
	temp = Tcl_NewStringObj("lsort",5);
	error = Tcl_ListObjAppendElement(interp,temp,Tcl_GetObjResult(interp));
	if (error != TCL_OK) {return error;}
	error = Tcl_EvalObj(interp,temp);
	return error;
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
	Classy_CreateClassMethod(interp,"::Class","parent",Classy_ParentClassMethod);
	Classy_CreateClassMethod(interp,"::Class","children",Classy_ChildrenClassMethod);
	Classy_CreateClassMethod(interp,"::Class","private",Classy_PrivateClassMethod);
	Classy_CreateMethod(interp,"::Class","class",Classy_ClassMethod);
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

