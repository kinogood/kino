*&---------------------------------------------------------------------*
*&  Include           ZGTSDR0140_EXCEL                                   *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* TABLES                                                               *
*----------------------------------------------------------------------*
INCLUDE OLE2INCL.

*----------------------------------------------------------------------*
* DATA                                                                 *
*----------------------------------------------------------------------*
DATA : BEGIN OF G_EXCEL_T OCCURS 0,
         OFFER(20),
         Z081(132),
         Z082(132),
         Z091(132),
         Z091_2(132),
         Z091_3(132),
         Z092(132),
         Z093(132),
         Z094(132),
         Z095(132),
         Z096(132),
         Z097(132),
         STAWN(17),
         MATNR(18),
         MAKTX(35),
         LFIMG(20),
         VRKME(3),
         NETPR(15),
         NETWR(20),
         WAERK(5),
       END OF G_EXCEL_T.

DATA : G_WORK_FLAG.        " 'A' : Offer Sheet, 'B' : 구매승인요청서

** Excel Exporting관련 Variant
DATA: GLOBAL_UPLOAD_PATH LIKE RLGRAP-FILENAME.
DATA: GLOBAL_FILEMASK_MASK(20),
      GLOBAL_FILEMASK_TEXT(20).
DATA: GLOBAL_FILEMASK_ALL(80).
DATA: GLOBAL_FILESEL_CANCEL,
      FIELDLN TYPE I.
DATA: STANDARTFONT    TYPE OLE2_OBJECT.

DATA: W_WRAPTEXT1(300)   TYPE C,
      W_WRAPTEXT2(65535) TYPE C,
      W_WRAPTEXT3(300)   TYPE C.
DATA: W_FILENAME(30) TYPE C,
      W_TITLE(30)    TYPE C,
      W_DATE(15)     TYPE C.

DATA: BEGIN OF IT_TAB OCCURS 0,
        CR_LF TYPE   X     VALUE   '0A',
      END OF IT_TAB.

DATA: EXCEL       TYPE OLE2_OBJECT.
DATA: BOOKS       TYPE OLE2_OBJECT.
DATA: BOOK        TYPE OLE2_OBJECT.
DATA: SHEETS      TYPE OLE2_OBJECT.
DATA: SHEET       TYPE OLE2_OBJECT.
DATA: NAME        TYPE OLE2_OBJECT.
DATA: CELL        TYPE OLE2_OBJECT.
DATA: CELL1       TYPE OLE2_OBJECT.
DATA: CELL2       TYPE OLE2_OBJECT.
DATA: FONT        TYPE OLE2_OBJECT.
DATA: SFONT       TYPE OLE2_OBJECT.
DATA: SMARGE      TYPE OLE2_OBJECT.
DATA: RANGE       TYPE OLE2_OBJECT.
DATA: SELECT      TYPE OLE2_OBJECT.
DATA: SELECTION   TYPE OLE2_OBJECT.
DATA: ACTIVESHEET TYPE OLE2_OBJECT.
DATA: SAVEAS      TYPE OLE2_OBJECT.
DATA: SWRAPTEXT   TYPE OLE2_OBJECT.
DATA: APPLICATION TYPE OLE2_OBJECT.
DATA: COLUMN      TYPE OLE2_OBJECT.
DATA: ROW         TYPE OLE2_OBJECT.
DATA: BORDERS     TYPE OLE2_OBJECT.
DATA: BORDERS1    TYPE OLE2_OBJECT.
DATA: BORDERS2    TYPE OLE2_OBJECT.
DATA: BORDERS3    TYPE OLE2_OBJECT.
DATA: ITEM        TYPE OLE2_OBJECT.
DATA: PICTURES    TYPE OLE2_OBJECT.
DATA: INSERT      TYPE OLE2_OBJECT.
DATA: PAGESETUP   TYPE OLE2_OBJECT.

DATA: I TYPE I VALUE '4',
      J TYPE I,
      K TYPE I,
      L TYPE I,
      M TYPE I,
      N TYPE I.

*&---------------------------------------------------------------------*
*&      Form  excel_down_rtn
*&---------------------------------------------------------------------*
FORM EXCEL_DOWN_RTN .

  PERFORM  DATA_GETHERING.

  READ TABLE G_EXCEL_T INDEX 1.

  IF  SY-SUBRC  =  0.

** 납품 Header Text를 가져온다.
    PERFORM  DO_GET_TEXT.

** Excel file Exporting
    PERFORM  EXCEL_EXPORTING_RTN.

  ELSE.
    MESSAGE E000 WITH '발행할 Data를 선택하세요.'.
  ENDIF.

ENDFORM.                    " excel_down_rtn

*&---------------------------------------------------------------------*
*&      Form  excel_exporting_rtn
*&---------------------------------------------------------------------*
FORM EXCEL_EXPORTING_RTN .

  CLEAR : STATUS, TITLE, TITLE_1, TITLE_2, WINID, PGMID,
          POPUP_EVENT, READ_CNT, TOTAL_CNT, CALL_CNT,
          PERSENT.

*>>Create Object , init setting
  IF NOT EXCEL IS INITIAL.
    FREE OBJECT EXCEL.
  ENDIF.
*  SET PROPERTY OF EXCEL 'VISIBLE' = 1.
  CREATE OBJECT EXCEL 'EXCEL.APPLICATION'.
  CALL METHOD OF EXCEL 'WORKBOOKS' = BOOKS.
  CALL METHOD OF BOOKS 'ADD' = BOOK.

** 진행율표시
  TOTAL_CNT  =  10.
  READ_CNT  =  READ_CNT  +  1.
  PERFORM  PROGRESS_RATE_RTN.

  CALL METHOD OF EXCEL 'APPLICATION' = APPLICATION.
  SET PROPERTY OF APPLICATION 'STANDARDFONT' = '바탕체'.
  SET PROPERTY OF APPLICATION 'STANDARDFONTSIZE' = '10'.

  PERFORM  SET_MARGIN.

*---->> Header 출력.
  DATA WL_TABIX LIKE SY-TABIX.

  CALL METHOD OF EXCEL 'APPLICATION' = APPLICATION.
  SET PROPERTY OF APPLICATION 'STANDARDFONT' = '바탕체'.
  SET PROPERTY OF APPLICATION 'STANDARDFONTSIZE' = '10'.

** 진행율표시
  READ_CNT  =  READ_CNT  +  1.
  PERFORM  PROGRESS_RATE_RTN.

  CALL METHOD OF EXCEL 'SHEETS' = SHEETS
       EXPORTING #1 = 1.

  IF  G_WORK_FLAG  =  'A'.        " Offer Sheet

** 진행율표시
    READ_CNT  =  READ_CNT  +  1.
    PERFORM  PROGRESS_RATE_RTN.

    PERFORM  FILL_CELL_HEADER_WRITE.

** 진행율표시
    READ_CNT  =  READ_CNT  +  1.
    PERFORM  PROGRESS_RATE_RTN.

    PERFORM  FILL_CELL_DETAIL_WRITE.

    GLOBAL_FILEMASK_ALL = ',*.XLS,*.*.'.
    W_TITLE = 'Offer Sheet Save'.

  ELSEIF  G_WORK_FLAG  =  'B'.    " 구매승인요청서

** 진행율표시
    READ_CNT  =  READ_CNT  +  1.
    PERFORM  PROGRESS_RATE_RTN.

    PERFORM  FILL_CELL_HEADER_WRITE_PUCH.

** 진행율표시
    READ_CNT  =  READ_CNT  +  1.
    PERFORM  PROGRESS_RATE_RTN.

    PERFORM  FILL_CELL_DETAIL_WRITE_PUCH.

    GLOBAL_FILEMASK_ALL = ',*.XLS,*.*.'.
    W_TITLE = '구매승인요청서 Save'.

  ENDIF.

** 진행율표시
  READ_CNT  =  READ_CNT  +  1.
  PERFORM  PROGRESS_RATE_RTN.

  PERFORM  STATUS_END.

  PERFORM QUERY_FILENAME USING GLOBAL_UPLOAD_PATH 'S' W_TITLE.

  IF  GLOBAL_FILESEL_CANCEL EQ 'Y'.
    MESSAGE E001 WITH 'CANCEL !'.
  ENDIF.

  PERFORM SAVE_EXCEL USING RLGRAP-FILENAME.

  SEARCH RLGRAP-FILENAME FOR '...'.

  IF SY-SUBRC NE 0.
    CONCATENATE RLGRAP-FILENAME '.XLS' INTO RLGRAP-FILENAME.
  ENDIF.

  CALL FUNCTION 'WS_EXECUTE'
    EXPORTING
*     CD                 = RLGRAP-FILENAME
      PROGRAM            = RLGRAP-FILENAME
    EXCEPTIONS
      FRONTEND_ERROR     = 1
      NO_BATCH           = 2
      PROG_NOT_FOUND     = 3
      ILLEGAL_OPTION     = 4
      GUI_REFUSE_EXECUTE = 5
      OTHERS             = 6.

** Object를 Free해주는 것은 한장을 발행하고 트랜잭션을 종료할때는
** 여기에서 하고 그렇지 않으면 트랜잭션을 종료할때 수행한다.
*  perform free_object.

ENDFORM.                    " excel_exporting_rtn

*&---------------------------------------------------------------------*
*&      Form  excel_down_rtn2
*&---------------------------------------------------------------------*
FORM EXCEL_DOWN_RTN2 .

ENDFORM.                    " excel_down_rtn2



*&---------------------------------------------------------------------*
*&      Form  set_margin
*&---------------------------------------------------------------------*
FORM SET_MARGIN .

  CALL METHOD OF APPLICATION 'ActiveSheet' = ACTIVESHEET.
  CALL METHOD OF ACTIVESHEET 'PAGESETUP' = PAGESETUP.
  SET PROPERTY OF PAGESETUP 'LEFTMARGIN'   = 5.
  SET PROPERTY OF PAGESETUP 'RIGHTMARGIN'  = 5.
  SET PROPERTY OF PAGESETUP 'TOPMARGIN'    = 30.
  SET PROPERTY OF PAGESETUP 'BOTTOMMARGIN' = 30.
  SET PROPERTY OF PAGESETUP 'HEADERMARGIN' = 0.
  SET PROPERTY OF PAGESETUP 'FOOTERMARGIN' = 0.

ENDFORM.                    " set_margin

*&---------------------------------------------------------------------*
*&      Form  FILL_CELL_HEADER_WRITE
*&---------------------------------------------------------------------*
FORM FILL_CELL_HEADER_WRITE .

  PERFORM FIT_CELL USING 1  5  'C'.  "COLUMN조정.
  PERFORM FIT_CELL USING 2  15 'C'.
  PERFORM FIT_CELL USING 3  15 'C'.
  PERFORM FIT_CELL USING 4  14 'C'.
  PERFORM FIT_CELL USING 5  13 'C'.
  PERFORM FIT_CELL USING 6  13 'C'.
  PERFORM FIT_CELL USING 7  14 'C'.
  PERFORM FIT_CELL USING 8  14 'C'.

  I = 5.

  READ TABLE G_EXCEL_T INDEX 1.

** Title.
  PERFORM FILL_CELL_FONT  USING 3 4 'B' 20.
  PERFORM FILL_CELL_MERGE USING 3 3 4 6 'OFFER SHEET'.

** Messers
  PERFORM FILL_CELL_FONT  USING 5  2  'B' 10.
  PERFORM FILL_CELL_MERGE USING 5 5 2 2 'Messers'.
  PERFORM FILL_CELL_MERGE USING 5 5 3 5 G_H_Z091.
  PERFORM FILL_CELL_MERGE USING 6 6 3 5 G_H_Z091_2.
  PERFORM FILL_CELL_MERGE USING 7 7 3 5 G_H_Z091_3.

** Offer No
  PERFORM FILL_CELL_FONT  USING 5  7  'B' 10.
  PERFORM FILL_CELL_MERGE USING 5 5 7 8 'Offer No. : '.
  PERFORM FILL_CELL_FONT  USING 6  7  'B' 10.
  PERFORM FILL_CELL_MERGE USING 6 6 7 8 'Registered No. : '.
  CLEAR W_WRAPTEXT1.
  CONCATENATE  'Date. : ' G_H_Z081
         INTO  W_WRAPTEXT1 SEPARATED BY SPACE.
  PERFORM FILL_CELL_MERGE USING 7 7 7 8 W_WRAPTEXT1.

** Text
  PERFORM FILL_CELL_FONT  USING 9  3  'B' 10.
  PERFORM FILL_CELL_MERGE USING 9 9 3 7
  'We are pleased to offer you the under-mentioned articles as per'.
  PERFORM FILL_CELL_FONT  USING 10  3  'B' 10.
  PERFORM FILL_CELL_MERGE USING 10 10 3 7
  'conditions and details described as follows.'.

** 진행율표시
  READ_CNT  =  READ_CNT  +  1.
  PERFORM  PROGRESS_RATE_RTN.

** Origin/Supplier/Packing...등등
  PERFORM FILL_CELL_FONT  USING 12  2  'B' 10.
  PERFORM FILL_CELL_MERGE USING 12 12 2 2 'Origin      : '.
  PERFORM FILL_CELL_MERGE USING 12 12 3 5
          'Republic of Korea'.
  PERFORM FILL_CELL_FONT  USING 13  2  'B' 10.
  PERFORM FILL_CELL_MERGE USING 13 13 2 2 'Supplier    : '.
  PERFORM FILL_CELL_MERGE USING 13 13 3 5
          'LG Cable Ltd.'.
  PERFORM FILL_CELL_FONT  USING 14  2  'B' 10.
  PERFORM FILL_CELL_MERGE USING 14 14 2 2 'Packing     : '.
  PERFORM FILL_CELL_MERGE USING 14 14 3 5 G_H_Z092.
  PERFORM FILL_CELL_FONT  USING 15  2  'B' 10.
  PERFORM FILL_CELL_MERGE USING 15 15 2 2 'Inspection  : '.
  PERFORM FILL_CELL_MERGE USING 15 15 3 5 G_H_Z093.
  PERFORM FILL_CELL_FONT  USING 16  2  'B' 10.
  PERFORM FILL_CELL_MERGE USING 16 16 2 2 'Payment     : '.
  PERFORM FILL_CELL_MERGE USING 16 16 3 5 G_H_Z094.
  PERFORM FILL_CELL_FONT  USING 17  2  'B' 10.
  PERFORM FILL_CELL_MERGE USING 17 17 2 2 'Shipment    : '.
  PERFORM FILL_CELL_MERGE USING 17 17 3 5 G_H_Z095.
  PERFORM FILL_CELL_FONT  USING 18  2  'B' 10.
  PERFORM FILL_CELL_MERGE USING 18 18 2 2 'Destination : '.
  PERFORM FILL_CELL_MERGE USING 18 18 3 5 G_H_Z096.
  PERFORM FILL_CELL_FONT  USING 19  2  'B' 10.
  PERFORM FILL_CELL_MERGE USING 19 19 2 2 'Validity    : '.
  PERFORM FILL_CELL_MERGE USING 19 19 3 5 G_H_Z082.
  PERFORM FILL_CELL_FONT  USING 20  2  'B' 10.
  PERFORM FILL_CELL_MERGE USING 20 20 2 2 'Remarks     : '.
  PERFORM FILL_CELL_MERGE USING 20 20 3 5 G_H_Z097.

** Text2
  PERFORM FILL_CELL_FONT  USING 22  2  'B' 10.
  PERFORM FILL_CELL_MERGE USING 22 22 2 7
  'Looking forword to your valued order for the above offer.'.

** 진행율표시
  READ_CNT  =  READ_CNT  +  1.
  PERFORM  PROGRESS_RATE_RTN.

** Commidity
  PERFORM FILL_CELL_FONT  USING 24  2  'B' 10.
  PERFORM FILL_CELL_MERGE USING 24 24 2 2 'Commidity   : '.

ENDFORM.                    " FILL_CELL_HEADER_WRITE

*&---------------------------------------------------------------------*
*&      Form  fill_cell_detail_write
*&---------------------------------------------------------------------*
FORM FILL_CELL_DETAIL_WRITE .

** 통화
  PERFORM FILL_CELL_FONT  USING 25  8  'B' 10.
  CLEAR W_WRAPTEXT1.
  CONCATENATE  '[통화 : ' G_H_WAERK ']'
         INTO  W_WRAPTEXT1 SEPARATED BY SPACE.
  PERFORM FILL_CELL_MERGE USING 25 25 8 8 W_WRAPTEXT1.

** Item Header Line.
  PERFORM FILL_LINE       USING 26 26 2  2  2  ' '.
  PERFORM FILL_LINE       USING 26 26 3  5  2  ' '.
  PERFORM FILL_LINE       USING 26 26 6  6  2  ' '.
  PERFORM FILL_LINE       USING 26 26 7  7  2  ' '.
  PERFORM FILL_LINE       USING 26 26 8  8  2  ' '.

  PERFORM FILL_CELL_FONT  USING 26  2  'B' 10.
  PERFORM FILL_CELL_FONT  USING 26  3  'B' 10.
  PERFORM FILL_CELL_FONT  USING 26  6  'B' 10.
  PERFORM FILL_CELL_FONT  USING 26  7  'B' 10.
  PERFORM FILL_CELL_FONT  USING 26  8  'B' 10.

  PERFORM FILL_CELL       USING 26  2 'HS No'.
  PERFORM FILL_CELL_MERGE USING 26 26 3 5 'Description'.
  PERFORM FILL_CELL       USING 26  6 'Quantity'.
  PERFORM FILL_CELL       USING 26  7 'Unit Price'.
  PERFORM FILL_CELL       USING 26  8 'Amount'.

** 진행율표시
  READ_CNT  =  READ_CNT  +  1.
  PERFORM  PROGRESS_RATE_RTN.

  M  =  27.

  PERFORM FILL_LINE       USING 27 55 2  2  2  ' '.
  PERFORM FILL_LINE       USING 27 55 3  5  2  ' '.
  PERFORM FILL_LINE       USING 27 55 6  6  2  ' '.
  PERFORM FILL_LINE       USING 27 55 7  7  2  ' '.
  PERFORM FILL_LINE       USING 27 55 8  8  2  ' '.

** 진행율표시
  READ_CNT  =  READ_CNT  +  1.
  PERFORM  PROGRESS_RATE_RTN.

  LOOP AT G_EXCEL_T.

    PERFORM FILL_CELL_FONT  USING M  2  ' ' 10.
    PERFORM FILL_CELL_FONT  USING M  3  ' ' 10.
    PERFORM FILL_CELL_FONT  USING M  6  ' ' 10.
    PERFORM FILL_CELL_FONT  USING M  7  ' ' 10.
    PERFORM FILL_CELL_FONT  USING M  8  ' ' 10.

    PERFORM FILL_CELL_MERGE USING M M 2 2 G_EXCEL_T-STAWN.
    PERFORM FILL_CELL_MERGE USING M M 3 5 G_EXCEL_T-MAKTX.
    PERFORM FILL_CELL_MERGE USING M M 6 6 G_EXCEL_T-LFIMG.
*    clear w_wraptext1.
*    concatenate  g_excel_t-netpr '/' g_excel_t-vrkme
*           into  w_wraptext1.
*    perform fill_cell_merge using m m 7 7 w_wraptext1.
    PERFORM FILL_CELL_MERGE USING M M 7 7 G_EXCEL_T-NETPR.
    PERFORM FILL_CELL_MERGE USING M M 8 8 G_EXCEL_T-NETWR.

    M  =  M  +  1.

  ENDLOOP.

** 진행율표시
  READ_CNT  =  READ_CNT  +  1.
  PERFORM  PROGRESS_RATE_RTN.

** Total
  PERFORM FILL_LINE       USING 56 56 2  7  2  ' '.
  PERFORM FILL_LINE       USING 56 56 8  8  2  ' '.

  PERFORM FILL_CELL_FONT  USING 56  2  'B' 10.
  PERFORM FILL_CELL_FONT  USING 56  8  ' ' 10.

  PERFORM FILL_CELL_MERGE USING 56 56 2 7 'TOTAL'.
  PERFORM FILL_CELL_MERGE USING 56 56 8 8 G_H_TOTAL.

** Confirmed
  PERFORM FILL_CELL_FONT  USING 58  2  'B' 10.
  PERFORM FILL_CELL_MERGE USING 58 58 2 3 'Confirmed by :'.
  PERFORM FILL_CELL_FONT  USING 58  6  'B' 10.
  PERFORM FILL_CELL_MERGE USING 58 58 6 8
          'Faithfully yours,'.

ENDFORM.                    " fill_cell_detail_write

*&---------------------------------------------------------------------*
*&      Form  FILL_CELL_HEADER_WRITE_PUCH
*&---------------------------------------------------------------------*
FORM FILL_CELL_HEADER_WRITE_PUCH .

  PERFORM FIT_CELL USING 1  5  'C'.  "COLUMN조정.
  PERFORM FIT_CELL USING 2  15 'C'.
  PERFORM FIT_CELL USING 3  15 'C'.
  PERFORM FIT_CELL USING 4  14 'C'.
  PERFORM FIT_CELL USING 5  12 'C'.
  PERFORM FIT_CELL USING 6  14 'C'.
  PERFORM FIT_CELL USING 7  14 'C'.
  PERFORM FIT_CELL USING 8  14 'C'.

  I = 5.

  READ TABLE G_EXCEL_T INDEX 1.

** Title.
  PERFORM FILL_CELL_FONT  USING 2 3 'B' 20.
  PERFORM FILL_CELL_MERGE USING 2 2 3 7
          '외화획득용 원료구매승인요청서'.

** 진행율표시
  READ_CNT  =  READ_CNT  +  1.
  PERFORM  PROGRESS_RATE_RTN.

** (    용)
  PERFORM FILL_CELL_MERGE USING 4 4 2 2 '(             용)'.

** 신청인
  PERFORM FILL_LINE       USING 5 8 2  4  2  ''.
  PERFORM FILL_CELL_FONT  USING 5  2  'B' 10.
  PERFORM FILL_CELL       USING 5  2 '1.신청인(상호,주소,성명)'.

** 공급자
  PERFORM FILL_LINE       USING 5 8 6  8  2  ''.
  PERFORM FILL_CELL_FONT  USING 5  6  'B' 10.
  PERFORM FILL_CELL       USING 5  6 '2.공급자(상호,주소,성명)'.

** 진행율표시
  READ_CNT  =  READ_CNT  +  1.
  PERFORM  PROGRESS_RATE_RTN.

** Text
  PERFORM FILL_CELL_FONT  USING 9  2  'B' 10.
  PERFORM FILL_CELL_MERGE USING 9 9 2 7
'공급물품명세(국산원자재, 기초원자재, 수출물품등 해당사항에 O표하것.)'.

ENDFORM.                    " FILL_CELL_HEADER_WRITE_PUCH

*&---------------------------------------------------------------------*
*&      Form  fill_cell_detail_write_puch
*&---------------------------------------------------------------------*
FORM FILL_CELL_DETAIL_WRITE_PUCH .

** 통화
  PERFORM FILL_CELL_FONT  USING 10  8  'B' 10.
  CLEAR W_WRAPTEXT1.
  CONCATENATE  '[통화 : ' G_H_WAERK ']'
         INTO  W_WRAPTEXT1 SEPARATED BY SPACE.
  PERFORM FILL_CELL_MERGE USING 10 10 8 8 W_WRAPTEXT1.

** Item Header Line.
  PERFORM FILL_LINE       USING 11 11 2  2  2  ' '.
  PERFORM FILL_LINE       USING 11 11 3  5  2  ' '.
  PERFORM FILL_LINE       USING 11 11 6  6  2  ' '.
  PERFORM FILL_LINE       USING 11 11 7  7  2  ' '.
  PERFORM FILL_LINE       USING 11 11 8  8  2  ' '.

  PERFORM FILL_CELL_FONT  USING 11  2  'B' 10.
  PERFORM FILL_CELL_FONT  USING 11  3  'B' 10.
  PERFORM FILL_CELL_FONT  USING 11  6  'B' 10.
  PERFORM FILL_CELL_FONT  USING 11  7  'B' 10.
  PERFORM FILL_CELL_FONT  USING 11  8  'B' 10.

  PERFORM FILL_CELL       USING 11  2 'HS No'.
  PERFORM FILL_CELL_MERGE USING 11 11 3 5 'Description'.
  PERFORM FILL_CELL       USING 11  6 'Quantity'.
  PERFORM FILL_CELL       USING 11  7 'Unit Price'.
  PERFORM FILL_CELL       USING 11  8 'Amount'.

** 진행율표시
  READ_CNT  =  READ_CNT  +  1.
  PERFORM  PROGRESS_RATE_RTN.

  PERFORM FILL_LINE       USING 12 40 2  2  2  ' '.
  PERFORM FILL_LINE       USING 12 40 3  5  2  ' '.
  PERFORM FILL_LINE       USING 12 40 6  6  2  ' '.
  PERFORM FILL_LINE       USING 12 40 7  7  2  ' '.
  PERFORM FILL_LINE       USING 12 40 8  8  2  ' '.

  M  =  12.

  LOOP AT G_EXCEL_T.

    PERFORM FILL_CELL_FONT  USING M  2  ' ' 10.
    PERFORM FILL_CELL_FONT  USING M  3  ' ' 10.
    PERFORM FILL_CELL_FONT  USING M  6  ' ' 10.
    PERFORM FILL_CELL_FONT  USING M  7  ' ' 10.
    PERFORM FILL_CELL_FONT  USING M  8  ' ' 10.

    PERFORM FILL_CELL_MERGE USING M M 2 2 G_EXCEL_T-STAWN.
    PERFORM FILL_CELL_MERGE USING M M 3 5 G_EXCEL_T-MAKTX.
    PERFORM FILL_CELL_MERGE USING M M 6 6 G_EXCEL_T-LFIMG.
*    clear w_wraptext1.
*    concatenate  g_excel_t-netpr '/' g_excel_t-vrkme
*           into  w_wraptext1.
*    perform fill_cell_merge using m m 7 7 w_wraptext1.
    PERFORM FILL_CELL_MERGE USING M M 7 7 G_EXCEL_T-NETPR.
    PERFORM FILL_CELL_MERGE USING M M 8 8 G_EXCEL_T-NETWR.

    M  =  M  +  1.

  ENDLOOP.

** 진행율표시
  READ_CNT  =  READ_CNT  +  1.
  PERFORM  PROGRESS_RATE_RTN.

** Total
  PERFORM FILL_LINE       USING 41 41 2  7  2  ' '.
  PERFORM FILL_LINE       USING 41 41 8  8  2  ' '.

  PERFORM FILL_CELL_FONT  USING 41  2  'B' 10.
  PERFORM FILL_CELL_FONT  USING 41  8  ' ' 10.

  PERFORM FILL_CELL_MERGE USING 41 41 2 7 'TOTAL'.
  PERFORM FILL_CELL_MERGE USING 41 41 8 8 G_H_TOTAL.

** 근거서류/HS No/품명/금액/유효기일/선적기일
  PERFORM FILL_LINE       USING 43 43 2  2  2  ' '.
  PERFORM FILL_LINE       USING 43 43 3  3  2  ' '.
  PERFORM FILL_LINE       USING 43 43 4  5  2  ' '.
  PERFORM FILL_LINE       USING 43 43 6  6  2  ' '.
  PERFORM FILL_LINE       USING 43 43 7  7  2  ' '.
  PERFORM FILL_LINE       USING 43 43 8  8  2  ' '.

  PERFORM FILL_CELL_FONT  USING 43  2  'B' 10.
  PERFORM FILL_CELL_FONT  USING 43  3  'B' 10.
  PERFORM FILL_CELL_FONT  USING 43  4  'B' 10.
  PERFORM FILL_CELL_FONT  USING 43  6  'B' 10.
  PERFORM FILL_CELL_FONT  USING 43  7  'B' 10.
  PERFORM FILL_CELL_FONT  USING 43  8  'B' 10.

  PERFORM FILL_CELL       USING 43  2 '8. 근거서류명/번호'.
  PERFORM FILL_CELL       USING 43  3 '9. HS No.'.
  PERFORM FILL_CELL_MERGE USING 43 43 4 5 '10. 품    명'.
  PERFORM FILL_CELL       USING 43  6 '11. 금    액'.
  PERFORM FILL_CELL       USING 43  7 '12. 유효기일'.
  PERFORM FILL_CELL       USING 43  8 '13. 선적기일'.

  M  =  44.

  PERFORM FILL_LINE       USING 44 46 2  2  2  ' '.
  PERFORM FILL_LINE       USING 44 46 3  3  2  ' '.
  PERFORM FILL_LINE       USING 44 46 4  6  2  ' '.
*  perform fill_line       using 44 46 6  6  2  ' '.
  PERFORM FILL_LINE       USING 44 46 7  7  2  ' '.
  PERFORM FILL_LINE       USING 44 46 8  8  2  ' '.

** 진행율표시
  READ_CNT  =  READ_CNT  +  1.
  PERFORM  PROGRESS_RATE_RTN.

  DO 3 TIMES.

    PERFORM FILL_CELL_FONT  USING M  2  ' ' 10.
    PERFORM FILL_CELL_FONT  USING M  3  ' ' 10.
    PERFORM FILL_CELL_FONT  USING M  4  ' ' 10.
*    perform fill_cell_font  using m  6  ' ' 10.
    PERFORM FILL_CELL_FONT  USING M  7  ' ' 10.
    PERFORM FILL_CELL_FONT  USING M  8  ' ' 10.

    IF  M  =  44.

      PERFORM FILL_CELL_MERGE USING M M 2 2 'Offer No -'.
      PERFORM FILL_CELL_MERGE USING M M 3 3 G_H_HSNO.
      PERFORM FILL_CELL_MERGE USING M M 4 6
              'Copper Foil with Adhesive Coating'.

    ELSEIF  M  =  45.

      PERFORM FILL_CELL_MERGE USING M M 2 2 G_H_OFFER.
      PERFORM FILL_CELL_MERGE USING M M 4 6
              'Uncoated Copper Foil'.

    ELSEIF  M  =  46.

      G_C_TOTAL  =  G_H_TOTAL.
      CONCATENATE  G_C_TOTAL '/' G_H_WAERK
             INTO  W_WRAPTEXT1.
      PERFORM FILL_CELL_MERGE USING M M 5 6 W_WRAPTEXT1.

    ENDIF.

    M  =  M  +  1.

  ENDDO.

** 승인조건
  PERFORM FILL_LINE       USING 47 49 2  8  2  ''.
  PERFORM FILL_CELL_FONT  USING 47  2  'B' 10.
  PERFORM FILL_CELL       USING 47  2 '14. 승인조건'.

** 승인번호
  PERFORM FILL_LINE       USING 50 52 2  8  2  ''.
  PERFORM FILL_CELL_FONT  USING 50  2  'B' 10.
  PERFORM FILL_CELL       USING 50  2 '14. 승인번호'.

** 은행장
  PERFORM FILL_LINE       USING 53 58 2  8  2  ''.
  PERFORM FILL_CELL_FONT  USING 53  2  'B' 10.
*20090205 1ST Upgrade UPGDCC02 start*******************************
  DATA: L_TEXT1(100).

  CONCATENATE '16.' '위' '신청사항을' '대외무역관리규정'
              '제5-2-8조' '제1항의' '규정에' '의하여'
              '승인합니다' INTO L_TEXT1.

  PERFORM FILL_CELL_MERGE USING 53 53 2 7  L_TEXT1.
*  '16. 위 신청사항을 대외무역관리규정 제5-2-8조 제1항의 규정에 의하여 승
*인합니다'.
*20090205 1ST Upgrade UPGDCC02 end*********************************

  PERFORM FILL_CELL_FONT  USING 56  4  'B' 10.
  PERFORM FILL_CELL_MERGE USING 56 56 4 7
  '은     행     장                  (인)'.

ENDFORM.                    " fill_cell_detail_write_puch

*&---------------------------------------------------------------------*
*&      Form  FIT_CELL
*&---------------------------------------------------------------------*
FORM FIT_CELL USING    P_COL1
                       P_WIDTH
                       P_GUBUN.

*  CALL METHOD OF EXCEL 'APPLICATION' = APPLICATION.
  IF P_GUBUN EQ 'C'.
    CALL METHOD OF APPLICATION 'CELLS' = CELL EXPORTING #1 = P_COL1.
    SET PROPERTY OF CELL 'COLUMNWIDTH' = P_WIDTH.
  ENDIF.
  IF P_GUBUN EQ 'R'.
    CALL METHOD OF APPLICATION 'CELLS' = CELL EXPORTING #1 = P_COL1.
    SET PROPERTY OF CELL 'ROWHEIGHT' = P_WIDTH. "HEIGHT.
  ENDIF.

ENDFORM.                    " FIT_CELL

*&---------------------------------------------------------------------*
*&      Form  fill_cell_font
*&---------------------------------------------------------------------*
FORM FILL_CELL_FONT USING    I
                             J
                             P_GUBUN
                             P_VALUE.

  CALL METHOD OF EXCEL 'CELLS' = CELL EXPORTING #1 = I #2 = J.
  CALL METHOD OF CELL 'FONT' = SFONT.
  SET PROPERTY OF SFONT 'SIZE' = P_VALUE.

  IF P_GUBUN EQ 'B'.
    SET PROPERTY OF SFONT 'FONTSTYLE' = '굵게'.
  ENDIF.

ENDFORM.                    " fill_cell_font

*&---------------------------------------------------------------------*
*&      Form  fill_cell_merge
*&---------------------------------------------------------------------*
FORM FILL_CELL_MERGE USING    P_START
                              P_I
                              P_VAL1
                              P_VAL2
                              P_VALUE.

  CALL METHOD OF EXCEL 'CELLS' = CELL1
       EXPORTING   #1 = P_START  #2 = P_VAL1.

  CALL METHOD OF EXCEL 'CELLS' = CELL2
       EXPORTING   #1 = P_I  #2 = P_VAL2.

  CALL METHOD OF APPLICATION 'RANGE'
     = RANGE EXPORTING #1 = CELL1 #2 = CELL2.
  CALL METHOD OF RANGE 'SELECT'.

  CALL METHOD OF APPLICATION 'SELECTION' = SELECTION.
  CALL METHOD OF SELECTION 'MERGE'.

  SET PROPERTY OF SELECTION 'VALUE' = P_VALUE.
  SET PROPERTY OF SELECTION 'HorizontalAlignment' = '2'.
  SET PROPERTY OF SELECTION 'VerticalAlignment' = '1'.

ENDFORM.                    " fill_cell_merge

*&---------------------------------------------------------------------*
*&      Form  query_filename
*&---------------------------------------------------------------------*
FORM QUERY_FILENAME USING DEF_PATH LIKE RLGRAP-FILENAME
                         MODE      TYPE C
                         TITLE     LIKE W_TITLE.

  DATA: TMP_FILENAME LIKE RLGRAP-FILENAME.
  DATA: TMP_MASK LIKE GLOBAL_FILEMASK_ALL.
  FIELD-SYMBOLS: <TMP_SYM>.

  CLEAR GLOBAL_FILESEL_CANCEL.
* Build Filter for Fileselektor

  IF GLOBAL_FILEMASK_MASK IS INITIAL.
    TMP_MASK = ',*.*,*.*.'.
  ELSE.
    TMP_MASK = ','.
    WRITE GLOBAL_FILEMASK_TEXT TO TMP_MASK+1.
    WRITE ',' TO TMP_MASK+21.
    WRITE GLOBAL_FILEMASK_MASK TO TMP_MASK+22.
    WRITE '.' TO TMP_MASK+42.
    CONDENSE TMP_MASK NO-GAPS.
  ENDIF.

  IF NOT GLOBAL_FILEMASK_ALL IS INITIAL.
    TMP_MASK = GLOBAL_FILEMASK_ALL.
  ENDIF.

  FIELDLN = STRLEN( DEF_PATH ) - 1.
  ASSIGN DEF_PATH+FIELDLN(1) TO <TMP_SYM>.
*  if <tmp_sym> = '/' or <tmp_sym> = '\'.
*    clear <tmp_sym>.
*  endif.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      DEF_FILENAME     = RLGRAP-FILENAME
      DEF_PATH         = DEF_PATH
*     MASK             = ',*.*,*.*.'
      MASK             = TMP_MASK
      MODE             = MODE
      TITLE            = TITLE "'Shipping Request Save !'
    IMPORTING
      FILENAME         = TMP_FILENAME
*     RC               =
    EXCEPTIONS
      INV_WINSYS       = 01
      NO_BATCH         = 02
      SELECTION_CANCEL = 03
      SELECTION_ERROR  = 04.

  IF SY-SUBRC = 0.
    RLGRAP-FILENAME = TMP_FILENAME.
    EXIT.
  ENDIF.
  IF SY-SUBRC = 3.
    GLOBAL_FILESEL_CANCEL = 'Y'.
  ENDIF.

ENDFORM.                    " query_filename

*&---------------------------------------------------------------------*
*&      Form  save_excel
*&---------------------------------------------------------------------*
FORM SAVE_EXCEL USING P_NAME.

  CALL METHOD OF APPLICATION 'ActiveSheet' = ACTIVESHEET.
  CALL METHOD OF ACTIVESHEET 'SAVEAS' =   SAVEAS
                              EXPORTING  #1 = P_NAME.

ENDFORM.                    " save_excel

*&---------------------------------------------------------------------*
*&      Form  free_object
*&---------------------------------------------------------------------*
FORM FREE_OBJECT .

  FREE OBJECT SAVEAS.
  FREE OBJECT SAVEAS.

  FREE OBJECT BORDERS3.
  FREE OBJECT BORDERS2.
  FREE OBJECT BORDERS1.
  FREE OBJECT BORDERS.
  FREE OBJECT RANGE.
  FREE OBJECT SELECTION.
  FREE OBJECT CELL2.
  FREE OBJECT CELL1.
  FREE OBJECT SFONT.
  FREE OBJECT INSERT.
  FREE OBJECT PICTURES.
  FREE OBJECT PAGESETUP.
  FREE OBJECT ACTIVESHEET.
  FREE OBJECT CELL.
  FREE OBJECT APPLICATION.
  FREE OBJECT BOOK.
  FREE OBJECT BOOKS.

  FREE OBJECT EXCEL.

ENDFORM.                    " free_object

*&---------------------------------------------------------------------*
*&      Form  fill_line
*&---------------------------------------------------------------------*
FORM FILL_LINE USING    P_SCOL
                        P_ECOL
                        P_SROW
                        P_EROW
                        P_WID                 "선종류.
                        P_SEL.                "Box형태.

  CALL METHOD OF EXCEL 'CELLS' = CELL1
       EXPORTING   #1 = P_SCOL  #2 = P_SROW.

  CALL METHOD OF EXCEL 'CELLS' = CELL2
       EXPORTING   #1 = P_ECOL   #2 = P_EROW.

  CALL METHOD OF APPLICATION 'RANGE'
     = RANGE EXPORTING #1 = CELL1 #2 = CELL2.
  CALL METHOD OF RANGE 'SELECT'.

  CALL METHOD OF APPLICATION 'SELECTION' = SELECTION.

  IF P_SEL NE 'L'.  " Left Line.
    CALL METHOD OF SELECTION 'BORDERS' = BORDERS EXPORTING #1 = 7.
    SET PROPERTY OF BORDERS  'WEIGHT'  = P_WID.
  ENDIF.

  IF P_SEL NE 'U'.  " Upper Line.
    CALL METHOD OF SELECTION 'BORDERS' = BORDERS1 EXPORTING #2 = 8.
    SET PROPERTY OF BORDERS1 'WEIGHT' = P_WID.
  ENDIF.

  IF P_SEL NE 'D'.  " Under Line.
    CALL METHOD OF SELECTION 'BORDERS' = BORDERS2 EXPORTING #3 = 9.
    SET PROPERTY OF BORDERS2 'WEIGHT' = P_WID.
  ENDIF.

  IF P_SEL NE 'R'.  " Right Line.
    CALL METHOD OF SELECTION 'BORDERS' = BORDERS3 EXPORTING #4 = 10.
    SET PROPERTY OF BORDERS3 'WEIGHT' = P_WID.
  ENDIF.

ENDFORM.                    " fill_line

*&---------------------------------------------------------------------*
*&      Form  fill_line2
*&---------------------------------------------------------------------*
FORM FILL_LINE2 USING    P_SCOL
                         P_ECOL
                         P_SROW
                         P_EROW
                         P_WID                 "선종류.
                         P_SEL.                "Box형태.

  CALL METHOD OF EXCEL 'CELLS' = CELL1
       EXPORTING   #1 = P_SCOL  #2 = P_SROW.

  CALL METHOD OF EXCEL 'CELLS' = CELL2
       EXPORTING   #1 = P_ECOL   #2 = P_EROW.

  CALL METHOD OF APPLICATION 'RANGE'
     = RANGE EXPORTING #1 = CELL1 #2 = CELL2.
  CALL METHOD OF RANGE 'SELECT'.

  CALL METHOD OF APPLICATION 'SELECTION' = SELECTION.

  IF P_SEL NE 'U'.  " Upper Line.
    CALL METHOD OF SELECTION 'BORDERS' = BORDERS1 EXPORTING #2 = 8.
    SET PROPERTY OF BORDERS1 'WEIGHT' = P_WID.
  ENDIF.

  IF P_SEL NE 'D'.  " Under Line.
    CALL METHOD OF SELECTION 'BORDERS' = BORDERS2 EXPORTING #3 = 9.
    SET PROPERTY OF BORDERS2 'WEIGHT' = P_WID.
  ENDIF.

ENDFORM.                    " fill_line2

*&---------------------------------------------------------------------*
*&      Form  fill_cell
*&---------------------------------------------------------------------*
FORM FILL_CELL USING    I
                        J
                        P_VALUE.

  CALL METHOD OF EXCEL 'CELLS' = CELL EXPORTING #1 = I #2 = J.
  SET PROPERTY OF CELL 'VALUE' = P_VALUE.

ENDFORM.                    " fill_cell

*&---------------------------------------------------------------------*
*&      Form  progress_rate_rtn
*&---------------------------------------------------------------------*
*  진행율표시
*----------------------------------------------------------------------*
FORM PROGRESS_RATE_RTN .

  PERFORM  SELECT_TITLE_AND_STATUS.

  CALL FUNCTION 'PROGRESS_POPUP'
    EXPORTING
      BTN_TXT     = '&Cancel'  "S-BTN_TXT
      CURVAL      = PERSENT  "진행율
      MAXVAL      = 000100  "100
      STAT        = STATUS  "S-STAT
      TEXT_1      = TITLE_1
      TEXT_2      = SPACE
      TEXT_3      = TITLE_2  "
      TITLE       = TITLE
      WINID       = PGMID  "S-WINID
    IMPORTING
      POPUP_EVENT = POPUP_EVENT.

  IF  POPUP_EVENT = 'CANCEL'.
    PERFORM  STATUS_END.
  ENDIF.

ENDFORM.                    " progress_rate_rtn

*&---------------------------------------------------------------------*
*&      Form  select_title_and_status
*&---------------------------------------------------------------------*
FORM SELECT_TITLE_AND_STATUS .

  ADD  1    TO  CALL_CNT.

  IF  CALL_CNT  >  1.
    STATUS = '3'.
  ELSE.
    STATUS = '1'.
  ENDIF.

  PERSENT  =  ( READ_CNT / TOTAL_CNT ) * 100.

  PERFORM  SETTING_TITLE.

ENDFORM.                    " select_title_and_status

*&---------------------------------------------------------------------*
*&      Form  setting_title
*&---------------------------------------------------------------------*
FORM SETTING_TITLE .

  CLEAR: TITLE_1, TITLE_2.

  MOVE ' Excel File로 변환중입니다.'   TO TITLE_1.

  CONCATENATE  READ_CNT  ' / ' TOTAL_CNT
         INTO  TITLE_2.

*  concatenate ' 사원번호 : ' itab-pernr
*                ' 사원수 : ' read_cnt   ' /  '  total_cnt
*              into title_2.

ENDFORM.                    " setting_title

*&---------------------------------------------------------------------*
*&      Form  status_end
*&---------------------------------------------------------------------*
FORM STATUS_END .

  CLEAR: CALL_CNT.

  CALL FUNCTION 'GRAPH_DIALOG'
    EXPORTING
      CLOSE = 'X'
      KWDID = PGMID.

ENDFORM.                    " status_end
