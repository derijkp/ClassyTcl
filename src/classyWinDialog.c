/*
 * peosWinDlg.c --
 *
 *	Contains the Windows implementation of the common dialog boxes.
 *
 * Copyright (c) 1996 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * SCCS: @(#) tkWinDialog.c 1.4 96/08/28 22:15:59
 *
 * This is the same as the Tk code for the open and save file dialogs,
 * but with some changes:
 * * added -selectmode (to allow multiple selections)
 * * Doesn't put up a diolog if the file already exists (I think this is up
 *   to the application; you sometimes need other choices then the default
 *   ones, eg. overwrite, append or cancel.
 * * allows input of none existant files (up to the application)
 */

#include "tcl.h"
#include "tkPort.h"
#include "tkInt.h"
#include "tkWinInt.h"
#include "tkFileFilter.h"
#include <windows.h>    /* includes basic windows functionality */
#include <commdlg.h>    /* includes common dialog functionality */
#include <dlgs.h>       /* includes common dialog template defines */
#include <cderr.h>      /* includes the common dialog error codes */

#if ((TK_MAJOR_VERSION == 4) && (TK_MINOR_VERSION <= 2))
/*
 * The following function is implemented on tk4.3 and after only
 */
#define Tk_GetHWND TkWinGetHWND
#endif

#define SAVE_FILE 0
#define OPEN_FILE 1

/*
 * The following structure is used in the GetOpenFileName() and
 * GetSaveFileName() calls.
 */
typedef struct _OpenFileData {
	 Tcl_Interp * interp;
	 TCHAR szFile[MAX_PATH+1024+1];
} OpenFileData;

static int 		Peos_GetFileName _ANSI_ARGS_((ClientData clientData,
					 Tcl_Interp *interp, int argc, char **argv,
					 int isOpen));
static int 		Peos_MakeFilter _ANSI_ARGS_((Tcl_Interp *interp,
					 OPENFILENAME *ofnPtr, char * string));
static int		Peos_ParseFileDlgArgs _ANSI_ARGS_((Tcl_Interp * interp,
					 OPENFILENAME *ofnPtr, int argc, char ** argv,
				 int isOpen));
static int 		Peos_ProcessCDError _ANSI_ARGS_((Tcl_Interp * interp,
				 DWORD dwErrorCode, HWND hWnd));

/*
 *----------------------------------------------------------------------
 *
 * Tk_GetOpenFileCmd --
 *
 *	This procedure implements the "open file" dialog box for the
 *	Windows platform. See the user documentation for details on what
 *	it does.
 *
 * Results:
 *	See user documentation.
 *
 * Side effects:
 *	A dialog window is created the first this procedure is called.
 *	This window is not destroyed and will be reused the next time
 *	the application invokes the "tk_getOpenFile" or
 *	"tk_getSaveFile" command.
 *
 *----------------------------------------------------------------------
 */

int
Peos_GetOpenFileCmd(clientData, interp, argc, argv)
	 ClientData clientData;	/* Main window associated with interpreter. */
	 Tcl_Interp *interp;		/* Current interpreter. */
	 int argc;			/* Number of arguments. */
	 char **argv;		/* Argument strings. */
{
	 return Peos_GetFileName(clientData, interp, argc, argv, OPEN_FILE);
}

/*
 *----------------------------------------------------------------------
 *
 * Tk_GetSaveFileCmd --
 *
 *	Same as Tk_GetOpenFileCmd but opens a "save file" dialog box
 *	instead
 *
 * Results:
 *	Same as Tk_GetOpenFileCmd.
 *
 * Side effects:
 *	Same as Tk_GetOpenFileCmd.
 *
 *----------------------------------------------------------------------
 */

int
Peos_GetSaveFileCmd(clientData, interp, argc, argv)
	 ClientData clientData;	/* Main window associated with interpreter. */
	 Tcl_Interp *interp;		/* Current interpreter. */
	 int argc;			/* Number of arguments. */
	 char **argv;		/* Argument strings. */
{
	 return Peos_GetFileName(clientData, interp, argc, argv, SAVE_FILE);
}

/*
 *----------------------------------------------------------------------
 *
 * GetFileName --
 *
 *	Calls GetOpenFileName() or GetSaveFileName().
 *
 * Results:
 *	See user documentation.
 *
 * Side effects:
 *	See user documentation.
 *
 *----------------------------------------------------------------------
 */

static int Peos_GetFileName(clientData, interp, argc, argv, isOpen)
	 ClientData clientData;	/* Main window associated with interpreter. */
	 Tcl_Interp *interp;		/* Current interpreter. */
	 int argc;			/* Number of arguments. */
	 char **argv;		/* Argument strings. */
	 int isOpen;			/* true if we should call GetOpenFileName(),
				 * false if we should call GetSaveFileName() */
{
	 OPENFILENAME openFileName, *ofnPtr;
	 int tclCode = TCL_OK;
	 int winCode, oldMode;
	 OpenFileData * custData = NULL;
    char buffer[MAX_PATH+1024+1];

	 ofnPtr = &openFileName;

	 /*
	  * 1. Parse the arguments.
	  */
	 if (Peos_ParseFileDlgArgs(interp, ofnPtr, argc, argv, isOpen)!= TCL_OK) {
	return TCL_ERROR;
	 }
	 custData = (OpenFileData*)ofnPtr->lCustData;

	 /*
	  * 2. Call the common dialog function.
	  */
    oldMode = Tcl_SetServiceMode(TCL_SERVICE_ALL);
    /*	 TkWinEnterModalLoop(interp);*/
    GetCurrentDirectory(MAX_PATH+1024+1, buffer);
	 if (isOpen) {
	winCode = GetOpenFileName(ofnPtr);
	 } else {
	winCode = GetSaveFileName(ofnPtr);
	 }
    SetCurrentDirectory(buffer);
    (void) Tcl_SetServiceMode(oldMode);
/*	 TkWinLeaveModalLoop(interp);*/

	 /*
	  * 3. Process the results.
	  */
	 if (winCode) {
	char * p;
	Tcl_ResetResult(interp);

/* Peos patch */
	if ((ofnPtr->Flags & OFN_EXPLORER)&&(ofnPtr->Flags & OFN_ALLOWMULTISELECT)) {
		char *keep;
		keep=ofnPtr->lpstrFile;
      p=ofnPtr->lpstrFile;
		while (1) {
			 /*
			  * Change the pathname to the Tcl "normalized" pathname, where
			  * back slashes are used instead of forward slashes
			  */
			if (*p == '\\') {
				*p = '/';
         }
		 	if (*p == '\0') {
				Tcl_AppendElement(interp,keep);
				keep=p+1;
            if (*keep=='\0') break;
		 	}
         p++;
		}
   } else {
/* end patch */
	for (p=custData->szFile; p && *p; p++) {
		 /*
		  * Change the pathname to the Tcl "normalized" pathname, where
		  * back slashes are used instead of forward slashes
		  */
		 if (*p == '\\') {
		*p = '/';
		 }
	}
   Tcl_AppendElement(interp,custData->szFile);
	}
	tclCode = TCL_OK;
	 }
   else {
	tclCode = Peos_ProcessCDError(interp, CommDlgExtendedError(),
		 ofnPtr->hwndOwner);
	 }

	 if (custData) {
	ckfree((char*)custData);
	 }
	 if (ofnPtr->lpstrFilter) {
	ckfree((char*)ofnPtr->lpstrFilter);
	 }

	 return tclCode;
}

/*
 *----------------------------------------------------------------------
 *
 * ParseFileDlgArgs --
 *
 *	Parses the arguments passed to tk_getOpenFile and tk_getSaveFile.
 *
 * Results:
 *	A standard TCL return value.
 *
 * Side effects:
 *	The OPENFILENAME structure is initialized and modified according
 *	to the arguments.
 *
 *----------------------------------------------------------------------
 */

static int Peos_ParseFileDlgArgs(interp, ofnPtr, argc, argv, isOpen)
	 Tcl_Interp * interp;	/* Current interpreter. */
	 OPENFILENAME *ofnPtr;	/* Info about the file dialog */
	 int argc;			/* Number of arguments. */
	 char **argv;		/* Argument strings. */
	 int isOpen;			/* true if we should call GetOpenFileName(),
				 * false if we should call GetSaveFileName() */
{
	 OpenFileData * custData;
	 int i;
	 Tk_Window parent = Tk_MainWindow(interp);
	 int doneFilter = 0;
	 int windowsMajorVersion;
    Tcl_DString buffer;

	 custData = (OpenFileData*)ckalloc(sizeof(OpenFileData));
	 custData->interp = interp;
	 strcpy(custData->szFile, "");

	 /* Fill in the OPENFILENAME structure to */
	 ofnPtr->lStructSize       = sizeof(OPENFILENAME);
	 ofnPtr->hwndOwner         = 0;			/* filled in below */
	 ofnPtr->lpstrFilter       = NULL;
	 ofnPtr->lpstrCustomFilter = NULL;
	 ofnPtr->nMaxCustFilter    = 0;
	 ofnPtr->nFilterIndex      = 0;
	 ofnPtr->lpstrFile         = custData->szFile;
	 ofnPtr->nMaxFile          = sizeof(custData->szFile);
	 ofnPtr->lpstrFileTitle    = NULL;
	 ofnPtr->nMaxFileTitle     = 0;
	 ofnPtr->lpstrInitialDir   = NULL;
	 ofnPtr->lpstrTitle        = NULL;
	 ofnPtr->nFileOffset       = 0;
	 ofnPtr->nFileExtension    = 0;
	 ofnPtr->lpstrDefExt       = NULL;
	 ofnPtr->lpfnHook 	      = NULL;
	 ofnPtr->lCustData         = (DWORD)custData;
	 ofnPtr->lpTemplateName    = NULL;
	 ofnPtr->Flags             = OFN_HIDEREADONLY | OFN_PATHMUSTEXIST;

	 windowsMajorVersion = LOBYTE(LOWORD(GetVersion()));
	 if (windowsMajorVersion >= 4) {
	/*
	 * Use the "explorer" style file selection box on platforms that
	 * support it (Win95 and NT4.0, both have a major version number
	 * of 4)
	 */
	ofnPtr->Flags |= OFN_EXPLORER;
	 }

/* Peos patch
	 if (isOpen) {
	ofnPtr->Flags |= OFN_FILEMUSTEXIST;
	 } else {
	ofnPtr->Flags |= OFN_OVERWRITEPROMPT;
	 }
*/
	 for (i=1; i<argc; i+=2) {
		  int v = i+1;
	int len = strlen(argv[i]);

	if (strncmp(argv[i], "-defaultextension", len)==0) {
		 if (v==argc) {goto arg_missing;}

		 ofnPtr->lpstrDefExt = argv[v];
		 if (ofnPtr->lpstrDefExt[0] == '.') {
		/* Windows will insert the dot for us */
		ofnPtr->lpstrDefExt ++;
		 }
	}
	else if (strncmp(argv[i], "-filetypes", len)==0) {
		 if (v==argc) {goto arg_missing;}

		 if (Peos_MakeFilter(interp, ofnPtr, argv[v]) != TCL_OK) {
		return TCL_ERROR;
		 }
		 doneFilter = 1;
	}
	else if (strncmp(argv[i], "-initialdir", len)==0) {
		 if (v==argc) {goto arg_missing;}

 	    if (Tcl_TranslateFileName(interp, argv[v], &buffer) == NULL) {
		return TCL_ERROR;
	    }
	    ofnPtr->lpstrInitialDir = ckalloc(Tcl_DStringLength(&buffer)+1);
	    strcpy((char*)ofnPtr->lpstrInitialDir, Tcl_DStringValue(&buffer));
	    Tcl_DStringFree(&buffer);
	}
	else if (strncmp(argv[i], "-initialfile", len)==0) {
		 if (v==argc) {goto arg_missing;}

	    if (Tcl_TranslateFileName(interp, argv[v], &buffer) == NULL) {
		return TCL_ERROR;
	    }
	    strcpy(ofnPtr->lpstrFile, Tcl_DStringValue(&buffer));
	    Tcl_DStringFree(&buffer);
	}
	else if (strncmp(argv[i], "-parent", len)==0) {
		 if (v==argc) {goto arg_missing;}

		 parent=Tk_NameToWindow(interp, argv[v], Tk_MainWindow(interp));
		 if (parent == NULL) {
		return TCL_ERROR;
		 }
	}
	else if (strncmp(argv[i], "-title", len)==0) {
		 if (v==argc) {goto arg_missing;}

		 ofnPtr->lpstrTitle = argv[v];
	}
/* Peos patch */
	else if (strncmp(argv[i], "-selectmode", len)==0) {
		 if (v==argc) {goto arg_missing;}
		 if (strcmp(argv[v], "browse")!=0) {
		 ofnPtr->Flags |= OFN_ALLOWMULTISELECT;
		 }
	}
	else {
			 Tcl_AppendResult(interp, "unknown option \"",
		argv[i], "\", must be -defaultextension, ",
		"-filetypes, -initialdir, -initialfile, -parent -selectmode or -title",
		NULL);
		 return TCL_ERROR;
	}
/* end patch */
	 }

    if (!doneFilter) {
	if (Peos_MakeFilter(interp, ofnPtr, "") != TCL_OK) {
	    return TCL_ERROR;
	}
	 }

    if (Tk_WindowId(parent) == None) {
	Tk_MakeWindowExist(parent);
    }
    ofnPtr->hwndOwner = Tk_GetHWND(Tk_WindowId(parent));

    return TCL_OK;

  arg_missing:
    Tcl_AppendResult(interp, "value for \"", argv[argc-1], "\" missing",
	NULL);
    return TCL_ERROR;
}

/*
 *----------------------------------------------------------------------
 *
 * MakeFilter --
 *
 *	Allocate a buffer to store the filters in a format understood by
 *	Windows
 *
 * Results:
 *	A standard TCL return value.
 *
 * Side effects:
 *	ofnPtr->lpstrFilter is modified.
 *
 *----------------------------------------------------------------------
 */
static int Peos_MakeFilter(interp, ofnPtr, string)
	 Tcl_Interp *interp;		/* Current interpreter. */
	 OPENFILENAME *ofnPtr;	/* Info about the file dialog */
	 char * string;		/* String value of the -filetypes option */
{
	 char * filterStr = NULL;
	 char * p;
	 int pass;
	 FileFilterList flist;
	 FileFilter * filterPtr;

    TkInitFileFilters(&flist);
    if (TkGetFileFilters(interp, &flist, string, 1) != TCL_OK) {
	return TCL_ERROR;
    }

    if (flist.filters == NULL) {
	/*
	 * Use "All Files (*.*) as the default filter is none is specified
	 */
	char * defaultFilter = "All Files (*.*)";

	p = filterStr = (char*)ckalloc(30 * sizeof(char));

	strcpy(p, defaultFilter);
	p+= strlen(defaultFilter);

	*p++ = '\0';
	*p++ = '*';
	*p++ = '.';
	*p++ = '*';
	*p++ = '\0';
	*p++ = '\0';
	*p = '\0';

    } else {
	/* We format the filetype into a string understood by Windows:
	 * {"Text Documents" {.doc .txt} {TEXT}} becomes
	 * "Text Documents (*.doc,*.txt)\0*.doc;*.txt\0"
	 *
	 * See the Windows OPENFILENAME manual page for details on the filter
	 * string format.
	 */

	/*
	 * Since we may only add asterisks (*) to the filter, we need at most
	 * twice the size of the string to format the filter
	 */
	filterStr = ckalloc(strlen(string) * 3);

	for (filterPtr=flist.filters, p=filterStr; filterPtr;
	        filterPtr=filterPtr->next) {
	    char * sep;
	    FileFilterClause * clausePtr;

	    /*
	     *  First, put in the name of the file type
	     */
	    strcpy(p, filterPtr->name);
	    p+= strlen(filterPtr->name);
	    *p++ = ' ';
	    *p++ = '(';

	    for (pass = 1; pass <= 2; pass++) {
		/*
		 * In the first pass, we format the extensions in the
		 * name field. In the second pass, we format the extensions in
		 * the filter pattern field
		 */
		sep = "";
		for (clausePtr=filterPtr->clauses;clausePtr;
		         clausePtr=clausePtr->next) {
		    GlobPattern * globPtr;


		    for (globPtr=clausePtr->patterns; globPtr;
			    globPtr=globPtr->next) {
			strcpy(p, sep);
			p+= strlen(sep);
			strcpy(p, globPtr->pattern);
			p+= strlen(globPtr->pattern);

			if (pass==1) {
			    sep = ",";
			} else {
			    sep = ";";
			}
		    }
		}
		if (pass == 1) {
		    if (pass == 1) {
			*p ++ = ')';
		    }
		}
		*p ++ = '\0';
	    }
	}

	/*
	 * Windows requires the filter string to be ended by two NULL
	 * characters.
	 */
	*p++ = '\0';
	*p++ = '\0';
    }

    if (ofnPtr->lpstrFilter != NULL) {
	ckfree((char*)ofnPtr->lpstrFilter);
    }
    ofnPtr->lpstrFilter = filterStr;

    TkFreeFileFilters(&flist);
    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ProcessCDError --
 *
 *	This procedure gets called if a Windows-specific error message
 *	has occurred during the execution of a common dialog or the
 *	user has pressed the CANCEL button.
 *
 * Results:
 *	If an error has indeed happened, returns a standard TCL result
 *	that reports the error code in string format. If the user has
 *	pressed the CANCEL button (dwErrorCode == 0), resets
 *	interp->result to the empty string.
 *
 * Side effects:
 *	interp->result is changed.
 *
 *----------------------------------------------------------------------
 */
static int Peos_ProcessCDError(interp, dwErrorCode, hWnd)
	 Tcl_Interp * interp;		/* Current interpreter. */
	 DWORD dwErrorCode;			/* The Windows-specific error code */
	 HWND hWnd;				/* window in which the error happened*/
{
	 char * string;

	 Tcl_ResetResult(interp);

	 switch(dwErrorCode) {
		case 0:	  /* User has hit CANCEL */
	return TCL_OK;

		case CDERR_DIALOGFAILURE:   string="CDERR_DIALOGFAILURE";  	break;
		case CDERR_STRUCTSIZE:      string="CDERR_STRUCTSIZE";   		break;
		case CDERR_INITIALIZATION:  string="CDERR_INITIALIZATION";   	break;
		case CDERR_NOTEMPLATE:      string="CDERR_NOTEMPLATE";   		break;
      case CDERR_NOHINSTANCE:     string="CDERR_NOHINSTANCE";   	break;
      case CDERR_LOADSTRFAILURE:  string="CDERR_LOADSTRFAILURE";   	break;
      case CDERR_FINDRESFAILURE:  string="CDERR_FINDRESFAILURE";   	break;
      case CDERR_LOADRESFAILURE:  string="CDERR_LOADRESFAILURE";   	break;
      case CDERR_LOCKRESFAILURE:  string="CDERR_LOCKRESFAILURE";   	break;
      case CDERR_MEMALLOCFAILURE: string="CDERR_MEMALLOCFAILURE";   	break;
		case CDERR_MEMLOCKFAILURE:  string="CDERR_MEMLOCKFAILURE";   	break;
		case CDERR_NOHOOK:          string="CDERR_NOHOOK";   	 	break;
      case PDERR_SETUPFAILURE:    string="PDERR_SETUPFAILURE";   	break;
      case PDERR_PARSEFAILURE:    string="PDERR_PARSEFAILURE";   	break;
      case PDERR_RETDEFFAILURE:   string="PDERR_RETDEFFAILURE";   	break;
      case PDERR_LOADDRVFAILURE:  string="PDERR_LOADDRVFAILURE";   	break;
      case PDERR_GETDEVMODEFAIL:  string="PDERR_GETDEVMODEFAIL";   	break;
      case PDERR_INITFAILURE:     string="PDERR_INITFAILURE";   	break;
      case PDERR_NODEVICES:       string="PDERR_NODEVICES";   		break;
      case PDERR_NODEFAULTPRN:    string="PDERR_NODEFAULTPRN";   	break;
      case PDERR_DNDMMISMATCH:    string="PDERR_DNDMMISMATCH";   	break;
      case PDERR_CREATEICFAILURE: string="PDERR_CREATEICFAILURE";   	break;
      case PDERR_PRINTERNOTFOUND: string="PDERR_PRINTERNOTFOUND";   	break;
      case CFERR_NOFONTS:         string="CFERR_NOFONTS";   	 	break;
      case FNERR_SUBCLASSFAILURE: string="FNERR_SUBCLASSFAILURE";   	break;
      case FNERR_INVALIDFILENAME: string="FNERR_INVALIDFILENAME";   	break;
		case FNERR_BUFFERTOOSMALL:  string="FNERR_BUFFERTOOSMALL";   	break;

      default:
	string="unknown error";
	 }

	 Tcl_AppendResult(interp, "Win32 internal error: ", string, NULL);
	 return TCL_ERROR;
}

