*&---------------------------------------------------------------------*
*& Include          ZNFR2700_FOM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .

  SELECT Z4~BUKRS, "회사코드
         Z4~NFCTR, "사업부
         Z4~PRCTR, "손익센터
         Z4~VKGRP, "영업그룹
         Z4~KUNNR, "고객
         Z4~NCUST, "고객명
         Z1~REQNO, "요청번호
         Z1~H_NO1, "요청번호 품목
         Z1~NFUTN, "신규집행번호
         Z1~CFUTN, "청산집행번호
         Z1~GJAHR, "회계연도
         Z2~RUDAT AS N_RUDAT,
         Z4~CONNO,
         Z4~ZPJNO,   "PJT No
         TEXT~ZPTXT, "PJT명
         Z5~RUDAT AS C_RUDAT,
         Z1~ENDAT, "만기일
         Z1~EMENG, "집행량 = 선물 청산수량
         Z1~MEINS, "
         Z1~NFKEY "비철구분

         INTO CORRESPONDING FIELDS OF TABLE @GT_DATA
    FROM ZNFT1051 AS Z1
         INNER JOIN ZNFT1020 AS Z2
            ON Z2~BUKRS EQ Z1~BUKRS AND Z2~NFUTN EQ Z1~NFUTN
         INNER JOIN ZNFT1030 AS Z5
            ON Z5~BUKRS EQ Z1~BUKRS AND Z5~CFUTN EQ Z1~CFUTN
         INNER JOIN ZNFT1011 AS Z3
            ON Z3~REQNO EQ Z1~REQNO
         INNER JOIN ZNFT1000 AS Z4
            ON Z4~CONNO EQ Z1~CONNO
         LEFT OUTER JOIN ZSD0106T AS TEXT
            ON Z4~ZPJNO  EQ TEXT~ZPJNO
         WHERE Z1~BUKRS  EQ @P_BUKRS "회사코드
           AND Z1~ENDAT  IN @S_ENDAT "만기일
           AND Z1~NFKEY  IN @S_NFKEY "비철구분
           AND Z1~PRCTR  IN @S_PRCTR "손익센터
           AND Z1~VKGRP  IN @S_VKGRP "영업그룹
           AND Z4~NFCTR  IN @S_NFCTR "사업부
           AND Z4~ZPJNO  IN @S_ZPJNO "PJT No
           AND Z1~CONNO  IN @S_CONNO "계약번호
           AND Z2~NFUTN  IN @S_NFUTN "신규선물 집행번호
           AND Z5~CFUTN  IN @S_CFUTN "청산선물 집행번호
           AND Z1~NBY_SL EQ 'B'     "[임시추가] Buy : 선물청산
           AND Z4~ZPJNO  NE ' '     " PJT No 누락 제외
           AND Z4~CSTAT  NE 'D'.    " 삭제건 제외

  SORT GT_DATA BY BUKRS GJAHR ZPJNO CONNO NFCTR PRCTR VKGRP KUNNR NFKEY REQNO H_NO1 NFUTN CFUTN.
  DELETE ADJACENT DUPLICATES FROM GT_DATA
  COMPARING BUKRS GJAHR ZPJNO CONNO NFCTR PRCTR VKGRP KUNNR NFKEY REQNO H_NO1 NFUTN CFUTN.

*___상세내역 보여주기 위해 옮겨두기
  GT_DATA_DETAIL = GT_DATA.


*___기준년도
  GV_GJAHR_B = P_GJAHR - 1.  "Before
  GV_GJAHR_A = P_GJAHR + 1.  "After


  SORT GT_DATA BY BUKRS GJAHR ZPJNO CONNO.
  DELETE ADJACENT DUPLICATES FROM GT_DATA COMPARING BUKRS GJAHR ZPJNO CONNO.

  MOVE-CORRESPONDING GT_DATA TO GT_ALV.


*___PJT No 기준으로 처음 ALV 화면을 뿌려준다.
  SORT GT_ALV BY BUKRS GJAHR ZPJNO.
  DELETE ADJACENT DUPLICATES FROM GT_ALV COMPARING BUKRS GJAHR ZPJNO.


  "조회년도인 부분만 데이터 보여주기
  DELETE GT_ALV WHERE GJAHR NE P_GJAHR.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form ZSD_365_NF_CONSUM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
* 수주계약 PJT No 에 해당하는 상세 내용 발췌
*&---------------------------------------------------------------------*
FORM DATA_PROCESSING .

*___선물 청산수량 계산
  PERFORM GET_EMENG.


*___PJT No,계약번호(conno)를 가지고 선물집행내역 조회한다
* Function : ZSD_365_NF_CONSUM 을 발췌하여 로직에 녹여냄.
  PERFORM CHECK_ZSD_365_NF_CONSUM.


*___Function 실행값을 통해 판매비철량 계산
  PERFORM GET_CONSUMQTY.


*___ 총 수주 비철수량 계산
  PERFORM GET_TOTAL_SUJU_EMENG.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form GET_SUBDATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& *현재 구성되어 있는 데이터상 대금청구 문서와 선물 및 청산집행번호
*& 1:1 Mapping 이 어려우므로 Sales, Billing 상관없이
*& 해당 PJT No 집행번호 및 청산 수량으로 출력한다.
*&---------------------------------------------------------------------*
FORM GET_SUBDATA .

  READ TABLE GT_SELECTED ASSIGNING FIELD-SYMBOL(<FS_SELECTED>) INDEX 1.

  IF SY-SUBRC EQ 0.
    DATA(LV_ZPJNO) = <FS_SELECTED>-ZPJNO.

    DATA(LT_DATA_DETAIL) = GT_DATA_DETAIL.
  ENDIF.

  CLEAR: GT_ALV2.
  LOOP AT LT_DATA_DETAIL INTO DATA(LS_DATA_DETAIL) WHERE ZPJNO = LV_ZPJNO.
    IF LT_DATA_DETAIL IS NOT INITIAL.
      GS_ALV2-NFKEY = LS_DATA_DETAIL-NFKEY.
      GS_ALV2-ENDAT = LS_DATA_DETAIL-ENDAT.
      GS_ALV2-EMENG = LS_DATA_DETAIL-EMENG.
      GS_ALV2-CONNO = LS_DATA_DETAIL-CONNO.
      GS_ALV2-NFUTN = LS_DATA_DETAIL-NFUTN.
      GS_ALV2-CFUTN = LS_DATA_DETAIL-CFUTN.
      APPEND GS_ALV2 TO GT_ALV2.
      CLEAR GS_ALV2.
    ENDIF.
  ENDLOOP.


   LOOP AT GT_OUT INTO DATA(LS_OUT) WHERE ZPJNO = LV_ZPJNO.
     IF LS_OUT IS NOT INITIAL.
       GS_ALV2-VBELN_VA   = LS_OUT-VBELN_VA.
       GS_ALV2-ERDAT      = LS_OUT-ERDAT.
       GS_ALV2-VBELN      = LS_OUT-VBELN.
       GS_ALV2-POSNR      = LS_OUT-POSNR.
       GS_ALV2-FKDAT      = LS_OUT-FKDAT.
       GS_ALV2-NFKEY      = LS_OUT-NES.
       GS_ALV2-CONSUM_QTY = LS_OUT-CONSUM_QTY.
       GS_ALV2-CONNO      = LS_OUT-CONNO.
       APPEND GS_ALV2 TO GT_ALV2.
       CLEAR GS_ALV2.
     ENDIF.
   ENDLOOP.


*___조회조건에 해당하지 않으면 지워준다.
  "___판매오더
  IF S_VBELN[] IS NOT INITIAL.
    DELETE GT_ALV2 WHERE VBELN_VA NOT IN S_VBELN.
  ENDIF.

  "___오더생성일
  IF S_ERDAT[] IS NOT INITIAL.
    DELETE GT_ALV2 WHERE ERDAT NOT IN S_ERDAT.
  ENDIF.

  "___만기일
   IF S_ENDAT[] IS NOT INITIAL.
     DELETE GT_ALV2 WHERE ENDAT NOT IN S_ENDAT.
   ENDIF.

  "___신규집행번호
   IF S_NFUTN[] IS NOT INITIAL.
     DELETE GT_ALV2 WHERE NFUTN NOT IN S_NFUTN.
   ENDIF.

  "___청산집행번호
   IF S_CFUTN[] IS NOT INITIAL.
     DELETE GT_ALV2 WHERE CFUTN NOT IN S_CFUTN.
   ENDIF.

  "___비철구분
   IF S_NFKEY[] IS NOT INITIAL.
     DELETE GT_ALV2 WHERE NFKEY NOT IN S_NFKEY.
   ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_event
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EVENT .

  DATA: LO_EVENT_RECEIVER TYPE REF TO LCL_EVENT_RECEIVER.

  LO_EVENT_RECEIVER = NEW #( ).

  SET HANDLER: LO_EVENT_RECEIVER->HANDLER_HOTSPOT_CLICK FOR GO_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_fb_function
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_FB_FUNCTION.

  REFRESH GT_EXCLUDE.
  GT_EXCLUDE = VALUE #( ( CL_GUI_ALV_GRID=>MC_FC_AUF                    )
                         ( CL_GUI_ALV_GRID=>MC_FC_AVERAGE               )
                         ( CL_GUI_ALV_GRID=>MC_FC_BACK_CLASSIC          )
                         ( CL_GUI_ALV_GRID=>MC_FC_CALL_ABC              )
                         ( CL_GUI_ALV_GRID=>MC_FC_CALL_CHAIN            )
                         ( CL_GUI_ALV_GRID=>MC_FC_CALL_CRBATCH          )
                         ( CL_GUI_ALV_GRID=>MC_FC_CALL_CRWEB            )
                         ( CL_GUI_ALV_GRID=>MC_FC_CALL_LINEITEMS        )
                         ( CL_GUI_ALV_GRID=>MC_FC_CALL_MASTER_DATA      )
                         ( CL_GUI_ALV_GRID=>MC_FC_CALL_MORE             )
                         ( CL_GUI_ALV_GRID=>MC_FC_CALL_REPORT           )
                         ( CL_GUI_ALV_GRID=>MC_FC_CALL_XINT             )
                         ( CL_GUI_ALV_GRID=>MC_FC_CALL_XML_EXPORT       )
                         ( CL_GUI_ALV_GRID=>MC_FC_CALL_XXL              )
                         ( CL_GUI_ALV_GRID=>MC_FC_CHECK                 )
                         ( CL_GUI_ALV_GRID=>MC_FC_COL_INVISIBLE         )
                         ( CL_GUI_ALV_GRID=>MC_FC_COL_OPTIMIZE          )
                         ( CL_GUI_ALV_GRID=>MC_FC_COUNT                 )
                         ( CL_GUI_ALV_GRID=>MC_FC_CURRENT_VARIANT       )
                         ( CL_GUI_ALV_GRID=>MC_FC_DATA_SAVE             )
                         ( CL_GUI_ALV_GRID=>MC_FC_DELETE_FILTER         )
                         ( CL_GUI_ALV_GRID=>MC_FC_DESELECT_ALL          )
                         ( CL_GUI_ALV_GRID=>MC_FC_DETAIL                )
*                        ( CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL              )
                         ( CL_GUI_ALV_GRID=>MC_FC_EXPCRDATA             )
                         ( CL_GUI_ALV_GRID=>MC_FC_EXPCRDESIG            )
                         ( CL_GUI_ALV_GRID=>MC_FC_EXPCRTEMPL            )
                         ( CL_GUI_ALV_GRID=>MC_FC_EXPMDB                )
                         ( CL_GUI_ALV_GRID=>MC_FC_EXTEND                )
                         ( CL_GUI_ALV_GRID=>MC_FC_F4                    )
                         ( CL_GUI_ALV_GRID=>MC_FC_FILTER                )
*                        ( CL_GUI_ALV_GRID=>MC_FC_FIND                  )
*                        ( CL_GUI_ALV_GRID=>MC_FC_FIND_MORE             )
                         ( CL_GUI_ALV_GRID=>MC_FC_FIX_COLUMNS           )
                         ( CL_GUI_ALV_GRID=>MC_FC_GRAPH                 )
                         ( CL_GUI_ALV_GRID=>MC_FC_HELP                  )
                         ( CL_GUI_ALV_GRID=>MC_FC_HTML                  )
                         ( CL_GUI_ALV_GRID=>MC_FC_INFO                  )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOAD_VARIANT          )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW        )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY              )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW          )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_CUT               )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW        )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW        )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW          )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE             )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW     )
                         ( CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO              )
                         ( CL_GUI_ALV_GRID=>MC_FC_MAINTAIN_VARIANT      )
                         ( CL_GUI_ALV_GRID=>MC_FC_MAXIMUM               )
                         ( CL_GUI_ALV_GRID=>MC_FC_MINIMUM               )
                         ( CL_GUI_ALV_GRID=>MC_FC_PC_FILE               )
                         ( CL_GUI_ALV_GRID=>MC_FC_PRINT                 )
                         ( CL_GUI_ALV_GRID=>MC_FC_PRINT_BACK            )
                         ( CL_GUI_ALV_GRID=>MC_FC_PRINT_PREV            )
                         ( CL_GUI_ALV_GRID=>MC_FC_REFRESH               )
                         ( CL_GUI_ALV_GRID=>MC_FC_REPREP                )
                         ( CL_GUI_ALV_GRID=>MC_FC_SAVE_VARIANT          )
                         ( CL_GUI_ALV_GRID=>MC_FC_SELECT_ALL            )
                         ( CL_GUI_ALV_GRID=>MC_FC_SEND                  )
                         ( CL_GUI_ALV_GRID=>MC_FC_SEPARATOR             )
*                        ( CL_GUI_ALV_GRID=>MC_FC_SORT                  )
*                        ( CL_GUI_ALV_GRID=>MC_FC_SORT_ASC              )
*                        ( CL_GUI_ALV_GRID=>MC_FC_SORT_DSC              )
                         ( CL_GUI_ALV_GRID=>MC_FC_SUBTOT                )
                         ( CL_GUI_ALV_GRID=>MC_FC_SUM                   )
                         ( CL_GUI_ALV_GRID=>MC_FC_TO_OFFICE             )
                         ( CL_GUI_ALV_GRID=>MC_FC_TO_REP_TREE           )
                         ( CL_GUI_ALV_GRID=>MC_FC_UNFIX_COLUMNS         )
                         ( CL_GUI_ALV_GRID=>MC_FC_URL_COPY_TO_CLIPBOARD )
                         ( CL_GUI_ALV_GRID=>MC_FC_VARIANT_ADMIN         )
                         ( CL_GUI_ALV_GRID=>MC_FC_VIEWS                 )
                         ( CL_GUI_ALV_GRID=>MC_FC_VIEW_CRYSTAL          )
                         ( CL_GUI_ALV_GRID=>MC_FC_VIEW_EXCEL            )
                         ( CL_GUI_ALV_GRID=>MC_FC_VIEW_GRID             )
                         ( CL_GUI_ALV_GRID=>MC_FC_VIEW_LOTUS            )
                         ( CL_GUI_ALV_GRID=>MC_FC_WORD_PROCESSOR        ) ).





ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FCAT USING PS_FCAT TYPE LVC_S_FCAT
                    PT_FCAT TYPE LVC_T_FCAT.

  DATA: LT_FIELDS TYPE STANDARD TABLE OF TY_FIELD WITH DEFAULT KEY ,
        LS_FIELD  TYPE TY_FIELD.


*___고정 필드 정의
  APPEND VALUE #( NAME = 'BUKRS'          TEXT = TEXT-T02 KEY = ABAP_ON ) TO LT_FIELDS.
  APPEND VALUE #( NAME = 'PRCTR'          TEXT = TEXT-T03 KEY = ABAP_ON ) TO LT_FIELDS.
  APPEND VALUE #( NAME = 'VKGRP'          TEXT = TEXT-T04 KEY = ABAP_ON ) TO LT_FIELDS.
  APPEND VALUE #( NAME = 'KUNNR'          TEXT = TEXT-T05 KEY = ABAP_ON ) TO LT_FIELDS.
  APPEND VALUE #( NAME = 'NCUST'          TEXT = TEXT-T06 KEY = ABAP_ON ) TO LT_FIELDS.
  APPEND VALUE #( NAME = 'ZPJNO'          TEXT = TEXT-T07 KEY = ABAP_ON HOT = ABAP_ON ) TO LT_FIELDS.
  APPEND VALUE #( NAME = 'ZPTXT'          TEXT = TEXT-T08 KEY = ABAP_ON HOT = ABAP_ON ) TO LT_FIELDS.
  APPEND VALUE #( NAME = 'EMENG_B'        TEXT = TEXT-T09 KEY = ABAP_ON COLOR = 'C300' HOT = ABAP_ON  ) TO LT_FIELDS.
  APPEND VALUE #( NAME = 'EMENG_S'        TEXT = TEXT-T10 KEY = ABAP_ON COLOR = 'C300' ) TO LT_FIELDS.

*___작년 수량
  APPEND VALUE #( NAME = 'YEAR_BEFORE_B'  TEXT = GV_GJAHR_B && '년 판매비철량'   COLOR = 'C211' ) TO LT_FIELDS.
  APPEND VALUE #( NAME = 'YEAR_BEFORE_S'  TEXT = GV_GJAHR_B && '년 선물청산수량' COLOR = 'C211' ) TO LT_FIELDS.


*___월별 필드 정의
  DO 12 TIMES.
    DATA(LV_MON) = SY-INDEX.
    LS_FIELD-NAME = |MON{ LV_MON WIDTH = 2 PAD = '0' ALIGN = RIGHT }_B | .
    LS_FIELD-TEXT = LV_MON && '월 판매비철량'.
    LS_FIELD-COLOR = 'C500'.
    CLEAR: LS_FIELD-KEY, LS_FIELD-HOT.
    APPEND LS_FIELD TO LT_FIELDS.

    LS_FIELD-NAME = |MON{ LV_MON WIDTH = 2 PAD = '0'ALIGN = RIGHT }_S | .
    LS_FIELD-TEXT = LV_MON && '월 선물청산 수량'.
    LS_FIELD-COLOR = 'C600'.
    CLEAR: LS_FIELD-KEY, LS_FIELD-HOT.
    APPEND LS_FIELD TO LT_FIELDS.
  ENDDO.

*___내년도 수량
  APPEND VALUE #( NAME = 'YEAR_AFTER_B'  TEXT = GV_GJAHR_A && '년 판매비철량'  COLOR = 'C211' ) TO LT_FIELDS.
  APPEND VALUE #( NAME = 'YEAR_AFTER_S'  TEXT = GV_GJAHR_A && '년 선물청산수량'COLOR = 'C211' ) TO LT_FIELDS.

*___작년+현재년도+내년도 합계
  APPEND VALUE #( NAME = 'YEAR_B' TEXT = TEXT-T23 COLOR = 'C010' ) TO LT_FIELDS. "판매비철 합계
  APPEND VALUE #( NAME = 'YEAR_S' TEXT = TEXT-T24 COLOR = 'C010' ) TO LT_FIELDS. "선물수량 합계


*___필드 카탈로그 채우기
  CLEAR: PT_FCAT.
  LOOP AT LT_FIELDS INTO LS_FIELD.
    CLEAR PS_FCAT.
    PS_FCAT-FIELDNAME = LS_FIELD-NAME.
    PS_FCAT-COLTEXT   = LS_FIELD-TEXT.
    PS_FCAT-KEY       = LS_FIELD-KEY.
    PS_FCAT-HOTSPOT   = LS_FIELD-HOT.
    PS_FCAT-COL_POS   = SY-TABIX.
    PS_FCAT-EMPHASIZE = LS_FIELD-COLOR.
    APPEND PS_FCAT TO PT_FCAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form alv_hotspot_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&---------------------------------------------------------------------*
FORM ALV_HOTSPOT_CLICK  USING PS_ROW_NO TYPE LVC_S_ROID
                              PS_COLUMN_ID TYPE LVC_S_COL.

*___메인 ALV 에서 Hotspot 클릭한 라인
  REFRESH: GT_SELECTED.
  READ TABLE GT_ALV INTO DATA(LS_ALV) INDEX PS_ROW_NO-ROW_ID.
  IF SY-SUBRC EQ 0.
    APPEND LS_ALV TO GT_SELECTED.
  ENDIF.

*___PJT No에 물린 계약번호 상세내용
*  PERFORM GET_SUBDATA.
*
*  CALL SCREEN '0200' STARTING AT 10 10
*                     ENDING AT 145 50.

  CASE PS_COLUMN_ID.

    "___PJT No에 물린 계약번호 상세내용
    WHEN 'ZPJNO' OR 'ZPTXT'.
      PERFORM GET_SUBDATA.

      CALL SCREEN '0200' STARTING AT 10 10
                         ENDING AT 145 50.


     "___총 수주 비철수량
    WHEN 'EMENG_B'.
      PERFORM GET_SUJU_EMENG.

      CALL SCREEN '0300' STARTING AT 10 10
                         ENDING AT 120 30.
    WHEN OTHERS.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_TABLE>
*&      --> CL_GUI_ALV_GRID=>MC_FC_LOC_UND
*&---------------------------------------------------------------------*
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES P_TABLE
                                 USING  P_VALUE.
*  DATA: l_exclude TYPE ui_func.
*  l_exclude = p_value.
*  APPEND l_exclude TO p_table.
  APPEND P_VALUE TO P_TABLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_FCAT2
*&      --> LT_FCAT2
*&---------------------------------------------------------------------*
FORM SET_FCAT2  USING PS_FCAT2 TYPE LVC_S_FCAT
                      PT_FCAT2 TYPE LVC_T_FCAT.

  DATA: LT_FIELDS TYPE STANDARD TABLE OF TY_FIELD WITH DEFAULT KEY,
        LS_FIELD  TYPE TY_FIELD.

  APPEND VALUE #( NAME = 'VBELN_VA'   TEXT = TEXT-T11 OUTPUTLEN = 12 ) TO LT_FIELDS.  "판매오더
  APPEND VALUE #( NAME = 'ERDAT'      TEXT = TEXT-T12 ) TO LT_FIELDS.                 "오더생성일
  APPEND VALUE #( NAME = 'VBELN'      TEXT = TEXT-T13 ) TO LT_FIELDS.                 "대금청구문서
  APPEND VALUE #( NAME = 'POSNR'      TEXT = TEXT-T14 OUTPUTLEN = 5 ) TO LT_FIELDS.   "품목
  APPEND VALUE #( NAME = 'FKDAT'      TEXT = TEXT-T15 OUTPUTLEN = 8 ) TO LT_FIELDS.   "매출일
  APPEND VALUE #( NAME = 'NFKEY'      TEXT = TEXT-T16 ) TO LT_FIELDS.                 "비철구분
  APPEND VALUE #( NAME = 'CONSUM_QTY' TEXT = TEXT-T17 OUTPUTLEN = 17
                  DO_SUM = 'X' ) TO LT_FIELDS.  "판매동량
  APPEND VALUE #( NAME = 'ENDAT'      TEXT = TEXT-T18 ) TO LT_FIELDS.  "만기일

  APPEND VALUE #( NAME = 'EMENG'      TEXT = TEXT-T19 OUTPUTLEN = 17
                  DO_SUM = 'X' ) TO LT_FIELDS.  "선물청산수량
  APPEND VALUE #( NAME = 'CONNO'      TEXT = TEXT-T20 ) TO LT_FIELDS.  "계약번호
  APPEND VALUE #( NAME = 'NFUTN'      TEXT = TEXT-T21 ) TO LT_FIELDS.  "신규 선물집행번호
  APPEND VALUE #( NAME = 'CFUTN'      TEXT = TEXT-T22 ) TO LT_FIELDS.  "청산 선물집행번호

  CLEAR: PT_FCAT2.
  LOOP AT LT_FIELDS INTO LS_FIELD.
    CLEAR: PS_FCAT2.
    PS_FCAT2-FIELDNAME = LS_FIELD-NAME.
    PS_FCAT2-COLTEXT   = LS_FIELD-TEXT.
    PS_FCAT2-COL_POS   = SY-TABIX.
    PS_FCAT2-DO_SUM    = LS_FIELD-DO_SUM.
    PS_FCAT2-OUTPUTLEN = LS_FIELD-OUTPUTLEN.
    PS_FCAT2-QFIELDNAME = LS_FIELD-QFIELDNAME.
    APPEND PS_FCAT2 TO PT_FCAT2.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_fb_function_all
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_FB_FUNCTION_ALL .

  REFRESH GT_EXCLUDE.
  APPEND CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL TO GT_EXCLUDE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_VALID_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4HELP_PRCTR USING PV_PRCTR.

  RANGES: LR_NFCTR FOR ZNFT1000-NFCTR.
  LR_NFCTR[] = S_NFCTR[].

  CLEAR   : SELECTFIELD, SELECT_VALUE,
            GT_FIELDS, SCR_FIELDS,LR_NFCTR,GT_PRCTR.

  REFRESH : GT_FIELDS, SCR_FIELDS,LR_NFCTR,GT_PRCTR.


*___ 화면상의 데이터를 읽는다.
  SCR_FIELDS-FIELDNAME = 'P_BUKRS'.
  APPEND SCR_FIELDS.

  SCR_FIELDS-FIELDNAME = 'S_NFCTR-LOW'.
  APPEND SCR_FIELDS.

  SCR_FIELDS-FIELDNAME = 'S_NFCTR-HIGH'.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME  = 'ZNFR2700'
      DYNUMB  = '1000'
    TABLES
      DYNPFIELDS = SCR_FIELDS.

  LOOP AT SCR_FIELDS.
    CASE SCR_FIELDS-FIELDNAME.
      WHEN 'P_BUKRS'.
        P_BUKRS = SCR_FIELDS-FIELDVALUE.
      WHEN 'S_NFCTR-LOW'.
        LR_NFCTR-LOW = SCR_FIELDS-FIELDVALUE.
        PERFORM CONVERSION_EXIT_ALPHA USING 'I' LR_NFCTR-LOW.
      WHEN 'S_NFCTR-HIGH'.
        LR_NFCTR-HIGH = SCR_FIELDS-FIELDVALUE.
        PERFORM CONVERSION_EXIT_ALPHA USING 'I' LR_NFCTR-HIGH.
    ENDCASE.
  ENDLOOP.

  READ TABLE LR_NFCTR INDEX 1 TRANSPORTING SIGN.
  IF SY-SUBRC EQ 0.
    IF LR_NFCTR-LOW IS NOT INITIAL OR
       LR_NFCTR-HIGH IS NOT INITIAL.
      IF LR_NFCTR-HIGH IS NOT INITIAL.
        LR_NFCTR-OPTION = 'BT'.
      ELSE.
        LR_NFCTR-OPTION = 'EQ'.
      ENDIF.

      MODIFY LR_NFCTR INDEX 1.

    ELSE.
      DELETE LR_NFCTR INDEX 1.
    ENDIF.

  ELSE.
    IF LR_NFCTR-LOW IS NOT INITIAL OR
       LR_NFCTR-HIGH IS NOT INITIAL.
      IF LR_NFCTR-SIGN   = 'I'.
         LR_NFCTR-OPTION = 'BT'.
         APPEND LR_NFCTR.
      ELSE.
        LR_NFCTR-SIGN   = 'I'.
        LR_NFCTR-OPTION = 'EQ'.
        APPEND LR_NFCTR.
      ENDIF.
    ENDIF.
  ENDIF.

  SELECT PRCTR
    INTO TABLE @GT_PRCTR
    FROM ZNFT0004           " SPG/사업부 Master
   WHERE KOKRS EQ @P_BUKRS
     AND NFCTR IN @LR_NFCTR "사업부
     AND BDATU >= @SY-DATLO "효력만료일
     AND CFACTIV = 'X'.     "선물요청(활성)

  IF SY-SUBRC EQ 0.
    LOOP AT GT_PRCTR INTO DATA(LS_PRCTR).
      PERFORM GET_PRCTR_DESC USING P_BUKRS
                                   LS_PRCTR-PRCTR
                                   LS_PRCTR-PTEXT.
      MODIFY GT_PRCTR FROM LS_PRCTR.
    ENDLOOP.

  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '손익센터가 없습니다.'.
    EXIT.
  ENDIF.


*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  GT_FIELDS-TABNAME    = 'ZNFT0004'.
  GT_FIELDS-FIELDNAME  = 'PRCTR'.
  GT_FIELDS-SELECTFLAG = 'X'.
  APPEND GT_FIELDS.

  GT_FIELDS-TABNAME    = 'ZNFT0004'.
  GT_FIELDS-FIELDNAME  = 'PTEXT'.
  GT_FIELDS-SELECTFLAG = 'X'.
  APPEND GT_FIELDS.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      SELECTFIELD  = SELECTFIELD
    IMPORTING
      IND          = GV_TABIX
      SELECT_VALUE = SELECT_VALUE
    TABLES
      FIELDS       = GT_FIELDS
      FULL_TABLE   = GT_PRCTR
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT GV_TABIX IS INITIAL.
  READ TABLE GT_PRCTR ASSIGNING FIELD-SYMBOL(<FS_PRCTR>) INDEX GV_TABIX.
  IF SY-SUBRC EQ 0.
    PV_PRCTR = <FS_PRCTR>-PRCTR.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_EXIT_ALPHA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> LR_NFCTR_LOW
*&---------------------------------------------------------------------*
FORM CONVERSION_EXIT_ALPHA  USING PV_FLAG
                                  PV_VALUE.
  IF PV_FLAG = 'I'.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = PV_VALUE
      IMPORTING
        OUTPUT = PV_VALUE.
  ELSE.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = PV_VALUE
      IMPORTING
        OUTPUT = PV_VALUE .
  ENDIF.

ENDFORM. "CONVERSION_EXIT_ALPHA
*&---------------------------------------------------------------------*
*& Form GET_PRCTR_DESC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_BUKRS
*&      --> LS_PRCTR_PRCTR
*&      --> LS_PRCTR_PTEXT
*&---------------------------------------------------------------------*
FORM GET_PRCTR_DESC  USING PV_KOKRS
                           PV_PRCTR
                           PV_PTEXT.
  CLEAR PV_PTEXT.
  CHECK PV_PRCTR IS NOT INITIAL.

  SELECT SINGLE KTEXT
    INTO @PV_PTEXT
    FROM CEPCT
   WHERE SPRAS EQ @SY-LANGU
     AND PRCTR EQ @PV_PRCTR
     AND DATBI >= @SY-DATLO
     AND KOKRS EQ @PV_KOKRS.

  IF SY-SUBRC NE 0 .
    MESSAGE E003 WITH '손익센터가 존재하지 않습니다.'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_FUNCTION
*&---------------------------------------------------------------------*

*___ Function : ZSD_365_NF_CONSUM 참고!!!
FORM CHECK_ZSD_365_NF_CONSUM.

*___Input 값 : 계약번호,PJT No
  CLEAR: GT_OUT,GT_FUNCTION.
  LOOP AT GT_DATA INTO DATA(LS_DATA).
    CLEAR: GS_FUNCTION.
*    GS_FUNCTION_CONNO = LS_DATA-CONNO.
    GS_FUNCTION-ZPJNO = LS_DATA-ZPJNO.
    APPEND GS_FUNCTION TO GT_FUNCTION.
  ENDLOOP.

  SORT GT_FUNCTION BY CONNO ZPJNO DESCENDING.
  DELETE ADJACENT DUPLICATES FROM GT_FUNCTION COMPARING CONNO ZPJNO.


  RANGES : LR_ZPJNO  FOR ZNFT1000-ZPJNO.
  DATA LV_ZPJNO TYPE ZPJNO.

  LOOP AT GT_FUNCTION INTO DATA(LS_FUNCTION) WHERE ZPJNO IS NOT INITIAL.
    IF LS_FUNCTION-ZPJNO(2) = 'PD'.
      _RANGES  LR_ZPJNO LS_FUNCTION-ZPJNO.
    ELSE.
      LV_ZPJNO = LS_FUNCTION-ZPJNO(8) && `*`.
      _RANGESCP LR_ZPJNO LV_ZPJNO.
    ENDIF.
  ENDLOOP.

  CHECK LR_ZPJNO[] IS NOT INITIAL.

*------------------------------매출기준 비철량 사용량 계산
  DATA: LT_BL TYPE TABLE OF TY_ZSD_365_NF_CONSUM.

  SELECT DISTINCT AK~ZPJNO, AK~VBELN AS VBELN_VA, AK~ERDAT,AK~CONNO,
                  RK~VBELN, RK~FKART, RK~GJAHR,
                  RP~POSNR, RP~MATNR,  RP~FKLMG, RP~MEINS, RK~FKDAT,
                  MM~NES,  MM~VGW,  MM~VGE, NF~BME
    FROM VBAK AS AK
          INNER JOIN VBRP AS RP ON RP~AUBEL = AK~VBELN
          INNER JOIN VBRK AS RK ON RK~VBELN = RP~VBELN
         LEFT OUTER JOIN /NFM/TVGW AS MM ON MM~MATNR = RP~MATNR AND MM~VTWEG = RK~VTWEG
         LEFT OUTER JOIN /NFM/TNES AS NF ON MM~NES = NF~NES
          WHERE AK~ZPJNO IN @LR_ZPJNO
            AND AK~ZPJNO <> ''
            AND AK~CONNO IN @S_CONNO "만기일
            AND AK~ERDAT IN @S_ERDAT "오더생성일
            AND RP~ABGRU IS INITIAL
            AND RK~SFAKN = ''
            AND RK~FKSTO = ''
            AND RK~FKART NOT IN ('ZF2', 'ZRE', 'ZCRB', 'ZDRB', 'G2','L2') "적송가매출, 적송 반품, 차액조정(대변메모), 차액조정(차변메모), 대변메모, 차변메모,
          INTO CORRESPONDING FIELDS OF TABLE @LT_BL.


  LOOP AT LT_BL ASSIGNING FIELD-SYMBOL(<BL>).
    MOVE-CORRESPONDING <BL> TO GS_OUT.
    IF GS_OUT-ZPJNO(2) <> 'PD'.
      GS_OUT-ZPJNO = GS_OUT-ZPJNO(8).
    ENDIF.
    IF GS_OUT-VGE <> 0.
      GS_OUT-CONSUM_QTY = GS_OUT-FKLMG * GS_OUT-VGW / GS_OUT-VGE.
      IF GS_OUT-FKART = 'RE'.                          "--------------------------RE "-", F2 "+'"
        GS_OUT-CONSUM_QTY = GS_OUT-CONSUM_QTY * -1.
      ENDIF.
    ENDIF.
    COLLECT GS_OUT INTO GT_OUT.
    CLEAR: GS_OUT.
  ENDLOOP.


  SORT GT_OUT BY GJAHR ZPJNO CONNO VBELN_VA VBELN POSNR MATNR FKART.
  DELETE ADJACENT DUPLICATES FROM GT_OUT
  COMPARING GJAHR ZPJNO CONNO VBELN_VA VBELN POSNR MATNR FKART.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_EMENG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_EMENG .
  DATA: LT_CALCULATE_EMENG TYPE TABLE OF TY_NF_MENGE.

  LT_CALCULATE_EMENG = GT_DATA_DETAIL.

  SORT LT_CALCULATE_EMENG BY BUKRS GJAHR KUNNR NFCTR PRCTR VKGRP ZPJNO CONNO REQNO H_NO1 NFUTN CFUTN.
  DELETE ADJACENT DUPLICATES FROM LT_CALCULATE_EMENG
  COMPARING BUKRS GJAHR KUNNR NFCTR PRCTR VKGRP ZPJNO CONNO REQNO H_NO1 NFUTN CFUTN.


*___ 조회년도 기준 1~12월 선물 청산수량 구하기
  LOOP AT GT_ALV ASSIGNING FIELD-SYMBOL(<FS_ALV>).
    LOOP AT LT_CALCULATE_EMENG INTO DATA(LS_EMENG) WHERE ZPJNO = <FS_ALV>-ZPJNO
                                                     AND GJAHR = <FS_ALV>-GJAHR.

      "만기일 기준 월별 청산수량 데이터 동적할당
      DATA(LV_MON) = LS_EMENG-ENDAT+4(2).
      DATA(LV_FIELD_S) = 'MON' && LV_MON && '_S'.

      ASSIGN COMPONENT LV_FIELD_S OF STRUCTURE <FS_ALV> TO FIELD-SYMBOL(<LV_MENGE>).
      IF SY-SUBRC EQ 0.
        <LV_MENGE> += LS_EMENG-EMENG .
      ENDIF.
    ENDLOOP.


   "___조회년도 기준 선물청산수량 합계 구하기
    <FS_ALV>-YEAR_S = <FS_ALV>-MON01_S + <FS_ALV>-MON02_S + <FS_ALV>-MON03_S +
                      <FS_ALV>-MON04_S + <FS_ALV>-MON05_S + <FS_ALV>-MON06_S +
                      <FS_ALV>-MON07_S + <FS_ALV>-MON08_S + <FS_ALV>-MON09_S +
                      <FS_ALV>-MON10_S + <FS_ALV>-MON11_S + <FS_ALV>-MON12_S.

   "___총 선물 수량
    <FS_ALV>-EMENG_S = <FS_ALV>-YEAR_S.
  ENDLOOP.

*___ 작년도 선물청산수량 구하기
  DATA(LT_BEFORE) = LT_CALCULATE_EMENG.
  DELETE LT_BEFORE WHERE GJAHR NE GV_GJAHR_B .

  DATA: LV_TOTAL_QTY TYPE P LENGTH 13 DECIMALS 3.

  LOOP AT LT_BEFORE INTO DATA(LS_BEFORE)
    GROUP BY ( ZPJNO = LS_BEFORE-ZPJNO ) ASSIGNING FIELD-SYMBOL(<FS_BEFORE_GROUP>).

    CLEAR: LV_TOTAL_QTY.
    LOOP AT GROUP <FS_BEFORE_GROUP> INTO DATA(LS_BEFORE_GROUP).
      LV_TOTAL_QTY += LS_BEFORE_GROUP-EMENG.
    ENDLOOP.

    READ TABLE GT_ALV ASSIGNING FIELD-SYMBOL(<FS_ALV_BEFORE>) WITH KEY ZPJNO = LS_BEFORE-ZPJNO.
    IF SY-SUBRC EQ 0.
      <FS_ALV_BEFORE>-YEAR_BEFORE_S = LV_TOTAL_QTY.

      "___총 선물수량(조회년도 + 작년도)
      <FS_ALV>-EMENG_S = <FS_ALV>-EMENG_S + <FS_ALV_BEFORE>-YEAR_BEFORE_S.
    ENDIF.
  ENDLOOP.


*___ 이전년도 선물청산수량 구하기
  DATA(LT_AFTER) = LT_CALCULATE_EMENG.
  DELETE LT_AFTER WHERE GJAHR NE GV_GJAHR_A .

  LOOP AT LT_AFTER INTO DATA(LS_AFTER)
    GROUP BY ( ZPJNO = LS_AFTER-ZPJNO ) ASSIGNING FIELD-SYMBOL(<FS_AFTER_GROUP>).

    CLEAR: LV_TOTAL_QTY.
    LOOP AT GROUP <FS_AFTER_GROUP> INTO DATA(LS_AFTER_GROUP).
      LV_TOTAL_QTY += LS_AFTER_GROUP-EMENG.
    ENDLOOP.

    READ TABLE GT_ALV ASSIGNING FIELD-SYMBOL(<FS_ALV_AFTER>) WITH KEY ZPJNO = LS_AFTER-ZPJNO.
    IF SY-SUBRC EQ 0.
      <FS_ALV_AFTER>-YEAR_AFTER_S = LV_TOTAL_QTY.

     "___총 선물수량(조회년도 수량 + 작년도 수량 + 내년도 수량
      <FS_ALV>-EMENG_S = <FS_ALV>-EMENG_S + <FS_ALV_AFTER>-YEAR_AFTER_S.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CONSUMQTY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_CONSUMQTY .

*___조회년도의 작년,내년도 데이터 가져오기
  DATA(LT_BEFORE_GJAHR) = GT_OUT.
  DELETE LT_BEFORE_GJAHR WHERE GJAHR NE GV_GJAHR_B.

  DATA(LT_AFTER_GJAHR)  = GT_OUT.
  DELETE LT_AFTER_GJAHR WHERE GJAHR NE GV_GJAHR_A.

  DATA(LT_GJAHR)        = GT_OUT.
  DELETE LT_GJAHR WHERE GJAHR NE P_GJAHR.

 " 회계년도가 0000 인 경우가 있음(제외)
  DELETE GT_OUT WHERE GJAHR = 0000.


*___현재년도 월별 판매비철량 계산
  LOOP AT GT_ALV ASSIGNING FIELD-SYMBOL(<FS_ALV>).
    LOOP AT GT_OUT INTO DATA(LS_OUT) WHERE ZPJNO = <FS_ALV>-ZPJNO
                                       AND GJAHR = P_GJAHR.

      IF LS_OUT IS NOT INITIAL.
        DATA(LV_MON) = LS_OUT-FKDAT+4(2).

        "___동적으로 필드설정
        DATA(LV_FIELD_B) = 'MON' && LV_MON && '_B'.

        "___월별 판매 비철량 데이터 채우기
        ASSIGN COMPONENT LV_FIELD_B OF STRUCTURE <FS_ALV> TO FIELD-SYMBOL(<LV_MENGE>).
        IF SY-SUBRC EQ 0. <LV_MENGE> += LS_OUT-CONSUM_QTY. ENDIF.
      ENDIF.

    ENDLOOP.

    "___조회년도 기준 판매비철량 합계 구하기
    <FS_ALV>-YEAR_B = <FS_ALV>-MON01_B + <FS_ALV>-MON02_B + <FS_ALV>-MON03_B +
                      <FS_ALV>-MON04_B + <FS_ALV>-MON05_B + <FS_ALV>-MON06_B +
                      <FS_ALV>-MON07_B + <FS_ALV>-MON08_B + <FS_ALV>-MON09_B +
                      <FS_ALV>-MON10_B + <FS_ALV>-MON11_B + <FS_ALV>-MON12_B.

  ENDLOOP.
*  UNASSIGN : <FS_ALV>, <LV_MENGE>.


*___위 조회된 내역 중 PJT No 기준 & 작년도 총 판매비철량 계산
  DATA: LV_TOTAL_QTY  TYPE P LENGTH 13 DECIMALS 3.

  LOOP AT LT_BEFORE_GJAHR INTO DATA(LS_BEFORE_GJAHR)
    GROUP BY ( ZPJNO = LS_BEFORE_GJAHR-ZPJNO ) ASSIGNING FIELD-SYMBOL(<FS_GROUP_BEFORE>).

    CLEAR: LV_TOTAL_QTY.
    LOOP AT GROUP <FS_GROUP_BEFORE> INTO DATA(LS_GROUP_BEFORE).
      LV_TOTAL_QTY += LS_GROUP_BEFORE-CONSUM_QTY.
    ENDLOOP.

    READ TABLE GT_ALV ASSIGNING FIELD-SYMBOL(<FS_ALV_BEFORE>) WITH KEY ZPJNO = <FS_GROUP_BEFORE>-ZPJNO.
    IF SY-SUBRC EQ 0.
      <FS_ALV_BEFORE>-YEAR_BEFORE_B = LV_TOTAL_QTY.

      "판매비철량 합계(현재년도+ 작년도)
      <FS_ALV>-year_b = <fs_alv>-year_b + lv_total_qty.

    ENDIF.
  ENDLOOP.


*___위 조회된 내역 중 PJT No 기준 & 내년도 총 판매비철량 계산
  LOOP AT LT_AFTER_GJAHR INTO DATA(LS_AFTER_GJAHR)
    GROUP BY ( ZPJNO = LS_AFTER_GJAHR-ZPJNO ) ASSIGNING FIELD-SYMBOL(<FS_GROUP_AFTER>).

    CLEAR: LV_TOTAL_QTY.
    LOOP AT GROUP <FS_GROUP_AFTER> INTO DATA(LS_GROUP_AFTER).
      LV_TOTAL_QTY += LS_GROUP_AFTER-CONSUM_QTY.
    ENDLOOP.

    READ TABLE GT_ALV ASSIGNING FIELD-SYMBOL(<FS_ALV_AFTER>) WITH KEY ZPJNO = <FS_GROUP_AFTER>-ZPJNO.
    IF SY-SUBRC EQ 0.
      <FS_ALV_AFTER>-YEAR_AFTER_B = LV_TOTAL_QTY.

      "판매비철량 합계 ( 현재년도+작년+내년)
      <FS_ALV>-YEAR_B = <FS_ALV>-YEAR_B + LV_TOTAL_QTY.

    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_AUTHORIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_BUKRS
*&      --> GV_ERROR
*&---------------------------------------------------------------------*
FORM CHECK_AUTHORIZATION  USING PV_BUKRS
                                PV_ERROR.
  CLEAR PV_ERROR.

  CASE PV_BUKRS.
    WHEN '1000'.

    WHEN OTHERS.
      PV_ERROR = 'X'.
  ENDCASE.

  IF PV_ERROR = 'X'.

    MESSAGE S003 DISPLAY LIKE 'E'
      WITH '회사코드'  PV_BUKRS '에 대한 권한을 점검하시기 바랍니다.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4HELP_VKGRP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> S_VKGRP_LOW
*&---------------------------------------------------------------------*
FORM F4HELP_VKGRP  USING PV_VKGRP.

  RANGES: LR_PRCTR FOR ZNFT1000-PRCTR.

  CLEAR   : SELECTFIELD, SELECT_VALUE,
            GT_FIELDS,SCR_FIELDS, LR_PRCTR.

  REFRESH : GT_FIELDS,SCR_FIELDS, LR_PRCTR.

  LR_PRCTR[] = S_PRCTR[].

*___화면상 데이터를 읽는다.
  SCR_FIELDS-FIELDNAME = 'P_BUKRS'.
  APPEND SCR_FIELDS.

  SCR_FIELDS-FIELDNAME = 'S_PRCTR-LOW'.
  APPEND SCR_FIELDS.

  SCR_FIELDS-FIELDNAME = 'S_PRCTR-HIGH'.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME   = 'ZNFR2700'
      DYNUMB   = '1000'
    TABLES
      DYNPFIELDS = SCR_FIELDS.

  LOOP AT SCR_FIELDS.
    CASE SCR_FIELDS-FIELDNAME.
      WHEN 'P_BUKRS'.
        P_BUKRS = SCR_FIELDS-FIELDVALUE.
      WHEN 'S_PRCTR-LOW'.
        LR_PRCTR-LOW = SCR_FIELDS-FIELDVALUE.
        PERFORM CONVERSION_EXIT_ALPHA USING 'I' LR_PRCTR-LOW.

      WHEN 'S_PRCTR-HIGH'.
        LR_PRCTR-HIGH = SCR_FIELDS-FIELDVALUE.
        PERFORM CONVERSION_EXIT_ALPHA USING 'I' LR_PRCTR-HIGH.
    ENDCASE.
  ENDLOOP.

  READ TABLE LR_PRCTR INDEX 1 TRANSPORTING SIGN.
  IF SY-SUBRC EQ 0.
    IF LR_PRCTR-LOW IS NOT INITIAL OR
       LR_PRCTR-HIGH IS NOT INITIAL.
      IF LR_PRCTR-HIGH IS NOT INITIAL.
        LR_PRCTR-OPTION = 'BT'.
      ELSE.
        LR_PRCTR-OPTION = 'EQ'.
      ENDIF.

      MODIFY LR_PRCTR INDEX 1.
    ELSE.
      DELETE LR_PRCTR INDEX 1.
    ENDIF.

  ELSE.  " SY-SUBRC NE 0.
    IF LR_PRCTR-LOW IS NOT INITIAL OR
      LR_PRCTR-HIGH IS NOT INITIAL.
      IF LR_PRCTR-HIGH IS NOT INITIAL.
        LR_PRCTR-SIGN   = 'I'.
        LR_PRCTR-OPTION = 'BT'.
        APPEND LR_PRCTR.

      ELSE.
        LR_PRCTR-SIGN   = 'I'.
        LR_PRCTR-OPTION = 'EQ'.
        APPEND LR_PRCTR.
      ENDIF.
    ENDIF.
  ENDIF.

  SELECT VKGRP
    INTO TABLE GT_VKGRP
    FROM ZNFT0003
   WHERE KOKRS EQ P_BUKRS     "회사코드
     AND PRCTR IN LR_PRCTR.  "손익센터

  IF SY-SUBRC EQ 0.
    LOOP AT GT_VKGRP INTO DATA(LS_VKGRP).
      PERFORM GET_VKGRP_DESC USING P_BUKRS
                                   LS_VKGRP-VKGRP
                                   LS_VKGRP-VTEXT.
      MODIFY GT_VKGRP FROM LS_VKGRP.
    ENDLOOP.
  ELSE.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '사업부가 없습니다.'.
    EXIT.
  ENDIF.


*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  GT_FIELDS-TABNAME    = 'ZNFT0003'.
  GT_FIELDS-FIELDNAME  = 'VKGRP'.
  GT_FIELDS-SELECTFLAG = 'X'.
  APPEND GT_FIELDS.

  GT_FIELDS-TABNAME    = 'ZNFT0003'.
  GT_FIELDS-FIELDNAME  = 'VTEXT'.
  GT_FIELDS-SELECTFLAG = 'X'.
  APPEND GT_FIELDS.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      SELECTFIELD                  = SELECTFIELD
    IMPORTING
      IND                          = GV_TABIX
      SELECT_VALUE                 = SELECT_VALUE
    TABLES
      FIELDS                       = GT_FIELDS
      FULL_TABLE                   = GT_VKGRP
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT GV_TABIX IS INITIAL.
  READ TABLE GT_VKGRP ASSIGNING FIELD-SYMBOL(<FS_VKGRP>) INDEX GV_TABIX.
  IF SY-SUBRC EQ 0 .
    PV_VKGRP = <FS_VKGRP>-VKGRP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_VKGRP_DESC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_BUKRS
*&      --> GT_VKGRP_VKGRP
*&      --> GT_VKGRP_VTEXT
*&---------------------------------------------------------------------*
FORM GET_VKGRP_DESC  USING PV_BUKRS
                           PV_VKGRP
                           PV_VTEXT.

  CLEAR PV_VTEXT.

  CHECK PV_VKGRP IS NOT INITIAL.

  SELECT SINGLE BEZEI
    INTO @PV_VTEXT
    FROM TVGRT
   WHERE SPRAS EQ @SY-LANGU
     AND VKGRP EQ @PV_VKGRP .


  IF SY-SUBRC NE 0.
    MESSAGE E003 WITH '영업그룹이 존재하지 않습니다.'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4HELP_NFCTR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> S_NFCTR_LOW
*&---------------------------------------------------------------------*
FORM F4HELP_NFCTR  USING PV_NFCTR.
  RANGES: LR_NFCTR FOR ZNFT1000-NFCTR.

  CLEAR   : SELECTFIELD, SELECT_VALUE, GV_TABIX,
            GT_FIELDS, SCR_FIELDS, LR_NFCTR.

  REFRESH : GT_FIELDS, SCR_FIELDS, LR_NFCTR.

  LR_NFCTR[] = S_NFCTR[].

*___화면상 데이터를 읽는다.
  SCR_FIELDS-FIELDNAME = 'P_BUKRS'.
  APPEND SCR_FIELDS.

  SCR_FIELDS-FIELDNAME = 'S_PRCTR-LOW'.
  APPEND SCR_FIELDS.

  SCR_FIELDS-FIELDNAME = 'S_PRCTR-HIGH'.
  APPEND SCR_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME   = 'ZNFR2700'
      DYNUMB   = '1000'
    TABLES
      DYNPFIELDS = SCR_FIELDS.

  IF P_BUKRS IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E'
       WITH '회사코드를 입력하시기 바랍니다.'.
    EXIT.
  ENDIF.

  SELECT NFCTR, NTEXT
    INTO TABLE @GT_NFCTR
    FROM ZNFT0005
   WHERE BUKRS = @P_BUKRS.

  IF SY-SUBRC NE 0.
    " 회사코드에 해당하는 사업부가 없습니다.
    MESSAGE S003 DISPLAY LIKE 'E' WITH TEXT-T02 && P_BUKRS && TEXT-T25.
    EXIT.
  ENDIF.

*___아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  GT_FIELDS-TABNAME    = 'ZNFT0005'.
  GT_FIELDS-FIELDNAME  = 'NFCTR'.
  GT_FIELDS-SELECTFLAG = 'X'.
  APPEND GT_FIELDS.

  GT_FIELDS-TABNAME    = 'ZNFT0005'.
  GT_FIELDS-FIELDNAME  = 'NTEXT'.
  GT_FIELDS-SELECTFLAG = ' '.
  APPEND GT_FIELDS.


  CALL FUNCTION 'HELP_VALUES_ET_NO_DD_NAME'
    EXPORTING
      SELECTFIELD  = SELECTFIELD
    IMPORTING
      IND          = GV_TABIX
      SELECT_VALUE = SELECT_VALUE
    TABLES
      FIELDS       = GT_FIELDS
      FULL_TABLE   = GT_NFCTR
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT GV_TABIX IS INITIAL.
  READ TABLE GT_NFCTR ASSIGNING FIELD-SYMBOL(<FS_NFCTR>) INDEX GV_TABIX.
  IF SY-SUBRC EQ 0.
    PV_NFCTR = <FS_NFCTR>-NFCTR.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SUJU_EMENG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_SUJU_EMENG .

  RANGES: LR_ZPJNO FOR ZNFT1000-ZPJNO.
  LR_ZPJNO-SIGN   = 'I'.
  LR_ZPJNO-OPTION = 'EQ'.


  READ TABLE GT_SELECTED ASSIGNING FIELD-SYMBOL(<FS_SELECTED>) INDEX 1.
  IF SY-SUBRC EQ 0.
    LR_ZPJNO-LOW = <FS_SELECTED>-ZPJNO.
    APPEND LR_ZPJNO.

    DATA(LT_DATA_DETAIL) = GT_DATA_DETAIL.
  ENDIF.

*___ 계약번호에 체결된 비철 수주량 구하기
  IF LT_DATA_DETAIL IS NOT INITIAL.
    SORT LT_DATA_DETAIL BY BUKRS ZPJNO CONNO NFKEY.
    DELETE ADJACENT DUPLICATES FROM LT_DATA_DETAIL COMPARING BUKRS ZPJNO CONNO NFKEY.

    SELECT CONNO, NFKEY, EMENG AS SUJU_EMENG, MEINS
      INTO CORRESPONDING FIELDS OF TABLE @GT_ALV3
      FROM ZNFT1001 AS A
      FOR ALL ENTRIES IN @LT_DATA_DETAIL
      WHERE A~CONNO EQ @LT_DATA_DETAIL-CONNO
        AND A~NFKEY EQ @LT_DATA_DETAIL-NFKEY
        AND A~NFKEY IN @S_NFKEY.
  ENDIF.


*___ 프로젝트번호,계약번호 매핑
  LOOP AT GT_ALV3 ASSIGNING FIELD-SYMBOL(<FS_ALV3>).
    READ TABLE LT_DATA_DETAIL INTO DATA(LS_DETAIL) WITH KEY CONNO = <FS_ALV3>-CONNO
                                                            NFKEY = <FS_ALV3>-NFKEY.
    IF SY-SUBRC EQ 0.
      <FS_ALV3>-ZPJNO = LS_DETAIL-ZPJNO.
    ENDIF.
  ENDLOOP.


*___ 선택한 라인의 프로젝트 번호에 해당하는 비철 수주량 구하기
  DELETE GT_ALV3 WHERE ZPJNO NOT IN LR_ZPJNO.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_FCAT3
*&      --> LT_FCAT3
*&---------------------------------------------------------------------*
FORM SET_FCAT3  USING PS_FCAT3 TYPE LVC_S_FCAT
                      PT_FCAT3 TYPE LVC_T_FCAT.



  DATA: LT_FIELDS TYPE STANDARD TABLE OF TY_FIELD WITH DEFAULT KEY,
        LS_FIELD  TYPE TY_FIELD.

  APPEND VALUE #( NAME = 'CONNO'      TEXT = TEXT-T20 ) TO LT_FIELDS.  "계약번호
  APPEND VALUE #( NAME = 'NFKEY'      TEXT = TEXT-T16 ) TO LT_FIELDS.  "비철구분
  APPEND VALUE #( NAME = 'SUJU_EMENG' TEXT = TEXT-T26 OUTPUTLEN = 17
                  DO_SUM = 'X' ) TO LT_FIELDS.                         "수주 비철수량
  APPEND VALUE #( NAME = 'MEINS'      TEXT = TEXT-T27 ) TO LT_FIELDS.  "단위


  CLEAR: PT_FCAT3.
  LOOP AT LT_FIELDS INTO LS_FIELD.
    PS_FCAT3-FIELDNAME = LS_FIELD-NAME.
    PS_FCAT3-COLTEXT   = LS_FIELD-TEXT.
    PS_FCAT3-COL_POS   = SY-TABIX.
    PS_FCAT3-DO_SUM    = LS_FIELD-DO_SUM.
    PS_FCAT3-OUTPUTLEN = LS_FIELD-OUTPUTLEN.
    PS_FCAT3-QFIELDNAME = LS_FIELD-QFIELDNAME.
    APPEND PS_FCAT3 TO PT_FCAT3.
    CLEAR : PS_FCAT3.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TOTAL_SUJU_EMENG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_TOTAL_SUJU_EMENG .

  DATA(LT_DETAIL) = GT_DATA_DETAIL .
  DATA: LT_SUJU_EMENG TYPE TABLE OF TY_ALV3.

  SORT LT_DETAIL BY BUKRS ZPJNO CONNO NFKEY.
  DELETE ADJACENT DUPLICATES FROM LT_DETAIL COMPARING BUKRS ZPJNO CONNO NFKEY.

 " 비철 수주량 데이터 가져오기
  SELECT CONNO, NFKEY, EMENG AS SUJU_EMENG, MEINS
    INTO CORRESPONDING FIELDS OF TABLE @LT_SUJU_EMENG
    FROM ZNFT1001 AS A
    FOR ALL ENTRIES IN @LT_DETAIL
    WHERE A~CONNO EQ @LT_DETAIL-CONNO
      AND A~NFKEY EQ @LT_DETAIL-NFKEY
      AND A~NFKEY IN @S_NFKEY.


 "프로젝트에 할당된 계약번호들에 해당하는 수주량 가져오기
  LOOP AT LT_SUJU_EMENG ASSIGNING FIELD-SYMBOL(<FS_SUJU_EMENG>).
    READ TABLE LT_DETAIL INTO DATA(LS_DETAIL) WITH KEY CONNO = <FS_SUJU_EMENG>-CONNO
                                                       NFKEY = <FS_SUJU_EMENG>-NFKEY .
    IF SY-SUBRC EQ 0.
      <FS_SUJU_EMENG>-ZPJNO = LS_DETAIL-ZPJNO.
    ENDIF.
  ENDLOOP.


 " 프로젝트 별 비철 수주량 합산
  DATA: LV_SUJU_SUM  TYPE ZNFT1001-EMENG,
        LT_SUM_EMENG TYPE TABLE OF TY_ALV3.
  SORT LT_SUJU_EMENG BY ZPJNO CONNO NFKEY.

  LOOP AT LT_SUJU_EMENG INTO DATA(LS_SUJU_EMENG)
    GROUP BY ( ZPJNO = LS_SUJU_EMENG-ZPJNO ) ASCENDING ASSIGNING FIELD-SYMBOL(<FS_GROUP>).

    LOOP AT GROUP <FS_GROUP> INTO DATA(LS_GROUP).
      LV_SUJU_SUM = LV_SUJU_SUM + LS_GROUP-SUJU_EMENG.
    ENDLOOP.

    LS_GROUP-SUJU_EMENG = LV_SUJU_SUM.

    APPEND LS_GROUP TO LT_SUM_EMENG.
    CLEAR: LS_GROUP, LV_SUJU_SUM.
  ENDLOOP.


  "GT_ALV 에 매핑
  LOOP AT GT_ALV ASSIGNING FIELD-SYMBOL(<FS_ALV>).
    READ TABLE LT_SUM_EMENG INTO DATA(LS_TEMP_EMENG) WITH KEY ZPJNO = <FS_ALV>-ZPJNO.
    IF SY-SUBRC EQ 0.
      <FS_ALV>-EMENG_B = LS_TEMP_EMENG-SUJU_EMENG.
    ENDIF.
  ENDLOOP.



ENDFORM.
