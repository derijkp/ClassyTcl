#include <stdio.h>

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

int
Classy_GetFontCmd(notUsed, interp, argc, argv)
	 ClientData notUsed;        	        /* Not used. */
	 Tcl_Interp *interp;        	        /* Current interpreter. */
	 int argc;        	        	/* Number of arguments. */
	 char **argv;        	        /* Argument strings. */
{
	char buffer[255];
	char *pos, *end;
	CHOOSEFONT pcf;
	LOGFONT lf;
	int size, oldMode;

	if ((argc != 4)&&(argc != 1)) {
		Tcl_AppendResult(interp, "wrong # args: should be \"", argv[0],
			" [name size stylelist]\"", (char *) NULL);
		return TCL_ERROR;
	}
	GetObject (GetStockObject (SYSTEM_FONT), sizeof (LOGFONT),
		(LPSTR) &lf) ;

	pcf.lStructSize      = sizeof (CHOOSEFONT) ;
	pcf.hwndOwner        = NULL ;
	pcf.lpLogFont        = &lf ;
	pcf.Flags            = CF_INITTOLOGFONTSTRUCT | CF_SCREENFONTS | CF_EFFECTS;
	pcf.rgbColors=RGB(0, 0, 0);

	if (argc==4) {
		strncpy(pcf.lpLogFont->lfFaceName,argv[1],32);
		if (Tcl_GetInt(interp,argv[2],&size)==TCL_ERROR) {
			return TCL_ERROR;
		}
		pcf.lpLogFont->lfHeight=-size*1.339;
		pcf.lpLogFont->lfWidth=0;
		strncpy(buffer,argv[3],255);
		pos=buffer;
		while (*pos==' ') pos++;
		end=strchr(pos,' ');
		if (end!=NULL) end[0]='\0';
		pcf.lpLogFont->lfWeight=FW_NORMAL;
		while (1) {
			if (strcmp(pos,"thin")==1) pcf.lpLogFont->lfWeight=FW_THIN;
			else if (strcmp(pos,"extralight")==1) pcf.lpLogFont->lfWeight=100;
			else if (strcmp(pos,"light")==1) pcf.lpLogFont->lfWeight=200;
			else if (strcmp(pos,"normal")==1) pcf.lpLogFont->lfWeight=400;
			else if (strcmp(pos,"medium")==1) pcf.lpLogFont->lfWeight=500;
			else if (strcmp(pos,"semibold")==1) pcf.lpLogFont->lfWeight=600;
			else if (strcmp(pos,"bold")==1) pcf.lpLogFont->lfWeight=700;
			else if (strcmp(pos,"extrabold")==1) pcf.lpLogFont->lfWeight=800;
			else if (strcmp(pos,"heavy")==1) pcf.lpLogFont->lfWeight=900;
			if (strcmp(pos,"italic")==1) pcf.lpLogFont->lfItalic=TRUE;
			if (strcmp(pos,"underline")==1) pcf.lpLogFont->lfUnderline=TRUE;
			if (strcmp(pos,"strikeout")==1) pcf.lpLogFont->lfStrikeOut=TRUE;
			if (end==NULL) break;
			pos=end+1;
			end=strchr(pos,' ');
			if (end!=NULL) end[0]='\0';
		}
	}
    oldMode = Tcl_SetServiceMode(TCL_SERVICE_ALL);
 /*	TkWinEnterModalLoop(interp);*/
	if (ChooseFont(&pcf)==FALSE) {
		Tcl_AppendResult(interp,"No font selected",NULL);
		return TCL_ERROR;
	}
    (void) Tcl_SetServiceMode(oldMode);
/*	 TkWinLeaveModalLoop(interp);*/
	 sprintf(buffer,"%s",pcf.lpLogFont->lfFaceName);
	 Tcl_AppendElement(interp, buffer);
	 sprintf(buffer,"%d",pcf.iPointSize/10);
	 Tcl_AppendElement(interp, buffer);
	 pos=buffer;
	 switch (pcf.lpLogFont->lfWeight) {
		  case FW_THIN	      : strcpy(pos," thin");pos+=5;break;
		  case FW_EXTRALIGHT	: strcpy(pos," extralight");pos+=11;break;
		  case FW_LIGHT      : strcpy(pos," light");pos+=6;break;
		  case FW_NORMAL     : strcpy(pos," normal");pos+=7;break;
		  case FW_MEDIUM     : strcpy(pos," medium");pos+=7;break;
		  case FW_SEMIBOLD   : strcpy(pos," semibold");pos+=9;break;
		  case FW_BOLD	      : strcpy(pos," bold");pos+=5;break;
		  case FW_EXTRABOLD  : strcpy(pos," extrabold");pos+=10;break;
		  case FW_HEAVY      : strcpy(pos," heavy");pos+=6;break;
	 }
	 if (pcf.lpLogFont->lfItalic>0) {strcpy(pos," italic");pos+=7;}
	 if (pcf.lpLogFont->lfUnderline>0) {strcpy(pos," underline");pos+=10;}
	 if (pcf.lpLogFont->lfStrikeOut>0) {strcpy(pos," strikeout");pos+=10;}
	 Tcl_AppendElement(interp, buffer);
	 return TCL_OK;
}


