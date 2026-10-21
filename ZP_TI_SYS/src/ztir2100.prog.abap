************************************************************************
*  Module/Submodule :   수입/MM
*  TYPE             :   Report
*  P/G              :   B/L업로드 및 이력 조회
*  Author           :   ZLSGLE
*  RICEF-ID         :
*  Date             :   2020.09.07
************************************************************************
*                        MODIFICATION LOG
*-----------------------------------------------------------------------
* Date.      Author.  CSR #            Description.
*-----------------------------------------------------------------------
************************************************************************


REPORT ZTIR2100 NO STANDARD PAGE HEADING MESSAGE-ID ZMM1.

**----------------------------------------------------------------------
*
** INCLUDE
**----------------------------------------------------------------------

INCLUDE ZTIR2100_F02.
INCLUDE ZTIR2100_C01.
INCLUDE ZTIR2100_TOP.
INCLUDE ZTIR2100_S01.
INCLUDE ZTIR2100_F01.
INCLUDE ZTIR2100_O01.
INCLUDE ZTIR2100_I01.


*&---------------------------------------------------------------------
*& INITIALIZATION.
*&---------------------------------------------------------------------
INITIALIZATION.
  PERFORM SET_INIT.
  SELECTION-SCREEN FUNCTION KEY 1.
  CONCATENATE ICON_XLS '업로드양식 다운로드'
         INTO  SSCRFIELDS-FUNCTXT_01.


*----------------------------------------------------------------------*
* AT SELECTION-SCREEN                                                  *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  IF SY-UCOMM = 'FC01'. "양식 다운로드
    PERFORM EXCEL_FORMAT_DOWNLOAD.
  ENDIF.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FNAME.
*- 파일업로드
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      MASK             = ',*.*,*.*.'
      MODE             = 'O'
    IMPORTING
      FILENAME         = P_FNAME
    EXCEPTIONS
      INV_WINSYS       = 1
      NO_BATCH         = 1
      SELECTION_CANCEL = 1
      SELECTION_ERROR  = 1.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.




*&----------------------------------------------------------------------
*& AT SELECTION-SCREEN OUTPUT
*&----------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.
*  IF SY-UNAME NE 'C526811' AND SY-UNAME(3) NE 'ZLS' AND
*     SY-UNAME NE 'C007501'.
*    MESSAGE S001 WITH '이용이 제한된 사용자입니다.'.
*    LEAVE PROGRAM.
*  ENDIF.
  PERFORM SET_SCREEN_OUTPUT.



*&---------------------------------------------------------------------
*& START-OF-SELECTION
*&---------------------------------------------------------------------

START-OF-SELECTION.

  "EXECEL UPLOAD
  IF R_UPD IS NOT  INITIAL.
    PERFORM EXCEL_UPLOAD.
  ELSE.
    PERFORM GET_DATA.
  ENDIF.

  CHECK GV_CHK IS INITIAL.

  DESCRIBE TABLE GT_LIST LINES GV_LINES.
  IF GV_LINES = 0.
    MESSAGE S005 DISPLAY LIKE 'E'.  "자료가 존재하지 않습니다.
    EXIT.
  ELSE.
    MESSAGE S009 WITH GV_LINES. "& 건의 데이터를 찾았습니다.
  ENDIF.

  CALL SCREEN 100.
