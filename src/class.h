/*	
 *	 File:    class.h
 *	 Purpose: Class extension to Tcl
 *	 Author:  Copyright (c) 1995 Peter De Rijk
 *
 *	 See the file "README" for information on usage and redistribution
 *	 of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

typedef struct Method {
	int copy;
	void *func;
	Tcl_Obj *proc;
	Tcl_Obj *args;
	int min;
	int max;
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
	Tcl_Obj *trace;
} Class;

typedef struct Object {
	Tcl_Command token;
	Class *parent;
	Tcl_Obj *name;
	Tcl_Obj *trace;
} Object;

typedef int Classy_Method _ANSI_ARGS_((Tcl_Interp *interp,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[]));

EXTERN int Classy_CreateClassMethod _ANSI_ARGS_((Tcl_Interp *interp,
	char *classname,
	char *name,
	Classy_Method *func));

EXTERN int Classy_CreateMethod _ANSI_ARGS_((Tcl_Interp *interp,
	char *classname,
	char *name,
	Classy_Method *func));

EXTERN Tcl_Obj *Classy_ObjectPrivateVar(
	Tcl_Obj *name,
	Tcl_Obj *var);
