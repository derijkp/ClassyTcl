int Classy_ExecClassMethod _ANSI_ARGS_((Tcl_Interp *interp,
	Method *method,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[]));

int Classy_ExecMethod _ANSI_ARGS_((Tcl_Interp *interp,
	Method *method,
	Class *class,
	Object *object,
	int argc,
	Tcl_Obj *CONST argv[]));

int Classy_FreeMethod _ANSI_ARGS_((Method *method));

int Classy_CreateTclClassMethod _ANSI_ARGS_((Tcl_Interp *interp,
	Method *method,
	Tcl_Obj *name,
	Tcl_Obj *args,
	Tcl_Obj *body,
	char *rname));	

int Classy_CreateTclMethod _ANSI_ARGS_((Tcl_Interp *interp,
	Method *method,
	Tcl_Obj *name,
	Tcl_Obj *args,
	Tcl_Obj *body,
	char *rname));	

void Classy_CopyMethods _ANSI_ARGS_((Tcl_HashTable *src,
	Tcl_HashTable *dst));

int Classy_CopyMethod _ANSI_ARGS_((Tcl_HashTable *src,
	Tcl_HashTable *dst,
	char *name));

Classy_Method Classy_ClassMethodClassMethod;
Classy_Method Classy_DeleteClassMethodClassMethod;
Classy_Method Classy_MethodClassMethod;
Classy_Method Classy_DeleteMethodClassMethod;