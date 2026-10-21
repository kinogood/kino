************************************************************************
* Title:         판매가격 Excel 파일 Upload
* Creator:
* Created date:  2025.06.09
* Description:   판매가격 Excel 파일 Upload
* Issue :
************************************************************************
* Modification log:
* ---------------------------------------------------------------------*
* <Date>    <Changed by>    <Description>
* ---------------------------------------------------------------------*
* 2025.06.09 ZGSIDEV05       최초생성
************************************************************************
REPORT ZGTSDR0030 MESSAGE-ID ZGTSD01 NO STANDARD PAGE HEADING.

INCLUDE ZGTSDR0030TOP. " Global Data
INCLUDE ZGTSDR0030C01. " Class(Event Handler)
INCLUDE ZGTSDR0030SEL. " Selection-Screen
INCLUDE ZGTSDR0030O01. " PBO-Modules
INCLUDE ZGTSDR0030I01. " PAI-Modules
INCLUDE ZGTSDR0030F01. " FORM-Routines

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM INITIALIZATION.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_SCREEN.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FNAME.
  P_FNAME = ZGTSD_CL_COMMON=>FILE_OPEN_DIALOG( ).
*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

  "입력값 체크
  PERFORM CHECK_INPUT_DATA.
  CHECK GV_ERROR IS INITIAL.

  "권한 체크
  PERFORM AUTHORITY_CHECK.

  "데이터 구성
  CASE ZGTSD_X.
    WHEN RB_BT1.
      IF GV_WEB IS NOT INITIAL.
        PERFORM WEB_DATA_UPLOAD.
      ELSE.
        PERFORM DATA_UPLOAD.
      ENDIF.

      PERFORM MAKE_DATA.
    WHEN RB_BT3.
      PERFORM DATA_QUERY.

    WHEN OTHERS.
      PERFORM EXCEL_DOWNLOAD.
      LEAVE LIST-PROCESSING.

  ENDCASE.

*----------------------------------------------------------------------*
* END-OF-SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.

  CHECK GV_ERROR IS INITIAL.

  IF SY-BATCH  IS INITIAL.
    CALL SCREEN 0100.
  ENDIF.
