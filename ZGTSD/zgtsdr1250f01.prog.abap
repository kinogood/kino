*&---------------------------------------------------------------------*
*&  Include           MZQM0696F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  INIT_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INIT_VARIANT .
* 고객불만 접수 버튼
*  MOVE C_TEMP_CREAT TO SSCRFIELDS-FUNCTXT_01.
  CONCATENATE  ICON_CREATE  C_TEMP_CREAT
                        INTO SSCRFIELDS-FUNCTXT_01.



  S_RCEPDT-SIGN   = 'I'.
  S_RCEPDT-OPTION = 'BT'.
  S_RCEPDT-HIGH   = SY-DATUM.

  CALL FUNCTION 'HR_PT_ADD_MONTH_TO_DATE'
    EXPORTING
      DMM_DATIN = SY-DATUM
      DMM_COUNT = '1'
      DMM_OPER  = '-'
      DMM_POS   = ''
    IMPORTING
      DMM_DAOUT = S_RCEPDT-LOW.

  APPEND S_RCEPDT.

  CLEAR GS_VARIANT.
  GS_VARIANT-REPORT = SY-REPID.

ENDFORM.                    " INIT_VARIANT
*&---------------------------------------------------------------------*
*&      Form  SSCRFIELDS-UCOMM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SSCRFIELDS-UCOMM .
  CASE SSCRFIELDS-UCOMM.
    WHEN 'FC01'.
* 고객불만 접수
      GD_BUKRS = S_BUKRS+3(4).
*      EXPORT GD_BUKRS TO MEMORY ID 'BUKRS_ID'.
      EXPORT GD_BUKRS TO MEMORY ID 'BUKRS_ID_GO'.
      CALL TRANSACTION 'ZGTSDR1230'.
  ENDCASE.

ENDFORM.                    " SSCRFIELDS-UCOMM
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .

  %%CLEAR : GT_0011M,  GT_0016F,  GT_DATA.

  DATA : LT_0011M LIKE GT_0011M OCCURS 0 WITH HEADER LINE.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_DATA
    FROM ZQMT0011H
   WHERE BUKRS    IN S_BUKRS
     AND RCEPDT   IN S_RCEPDT
     AND RCEPNO   IN S_RCEPNO
     AND WERKS_H  IN S_WERKSH
     AND PRCTR    IN S_PRCTR
     AND KUNUM    IN S_KUNUM
     AND STATUS   IN S_STATUS
     AND RCPERNR  IN S_RCPER
     AND CORDINR  IN S_CORDI
     AND JGNAMNR  IN S_JGNAM
     AND SDNAMNR  IN S_SDNAM
    AND SPGCD IN S_SPGCD
    .

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE LT_0011M
    FROM ZQMT0011M
   WHERE RCEPNO   IN S_RCEPNO
     AND WERKS_M  IN S_WERKSM
     AND SPGCD    IN S_SPGCD
     AND MATNR    IN S_MATNR
     AND KZLOESCH <> 'X'.

  LOOP AT LT_0011M.
    MOVE-CORRESPONDING LT_0011M TO GT_0011M.
    COLLECT GT_0011M.
    CLEAR : GT_0011M, LT_0011M.
  ENDLOOP.


*->[가온전선]--------------------CHG S
*  IF  S_BUKRS-LOW EQ '5000'.
** 총손실금액 = 물류손실금액 +
**  A/S관련 손실금액 中 협력업체회수금(외부), 손실보상비
*    SELECT  RCEPNO AS RCEPNO
*          QCODE1 AS  QCODE1
*          SHKZG AS SHKZG
*          SUM( WOGBTR ) AS WOGBTR
*     FROM ZQMT0016F
*     INTO TABLE GT_0016F
*    WHERE BUKRS IN S_BUKRS
*       AND RCEPNO IN S_RCEPNO
*      AND DFLG  <> 'X'
*      AND KOSTL <> SPACE
*       OR ( KOSTL EQ SPACE
*      AND   QCODE1 EQ 'CD018'
*       OR   QCODE1 EQ 'CD023'  )
*    GROUP BY RCEPNO QCODE1 SHKZG.
*
*  ELSE.
*-<[가온전선]--------------------CHG E
*총손실금액 =
*물류손실금액 + A/S관련 손실금액 中 협력업체회수금(외부)
  SELECT  RCEPNO AS RCEPNO
          QCODE1 AS  QCODE1
          SHKZG AS SHKZG
          SUM( WOGBTR ) AS WOGBTR
  FROM ZQMT0016F
  INTO TABLE GT_0016F
 WHERE BUKRS IN S_BUKRS
   AND RCEPNO IN S_RCEPNO
   AND DFLG  <> 'X'
   AND KOSTL <> SPACE
       OR ( KOSTL EQ SPACE
            AND QCODE1 EQ 'CD018')
 GROUP BY RCEPNO QCODE1 SHKZG.
*  ENDIF.

  SORT : GT_0011M BY RCEPNO ZMATSEQ,
         GT_0016F BY RCEPNO.

ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_ALV_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_ALV_CONTAINER .

  CREATE OBJECT G_DOCKCONTAINER1
    EXPORTING
      DYNNR                       = '0100'
      REPID                       = SY-REPID
      SIDE                        = G_DOCKCONTAINER1->DOCK_AT_TOP
      EXTENSION                   = 700
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5.

  CREATE OBJECT LCL_GRID
    EXPORTING
      I_PARENT      = G_DOCKCONTAINER1
      I_APPL_EVENTS = 'X'.

ENDFORM.                    " SET_ALV_CONTAINER
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_ATTRIBUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GS_LVC_LAYO  text
*----------------------------------------------------------------------*
FORM LAYOUT_ATTRIBUTE  CHANGING P_S_LVC_LAYO TYPE LVC_S_LAYO.

  P_S_LVC_LAYO-SEL_MODE        = 'D'.
  P_S_LVC_LAYO-CWIDTH_OPT      = 'X'.
  P_S_LVC_LAYO-ZEBRA           = 'X'.
  P_S_LVC_LAYO-BOX_FNAME       = 'SELX'.
*  P_S_LVC_LAYO-CTAB_FNAME      = 'CELLCOLOR'.   "라인칼라제어
  P_S_LVC_LAYO-STYLEFNAME      = 'CELLTAB'.
  GS_VARIANT-REPORT                   = SY-REPID.

ENDFORM.                    " LAYOUT_ATTRIBUTE
*&---------------------------------------------------------------------*
*&      Form  TOOLBAR_PART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0027   text
*----------------------------------------------------------------------*
FORM TOOLBAR_PART  USING   P_T_UI_FUNCTIONS.
  FIELD-SYMBOLS : <TABLE> TYPE UI_FUNCTIONS.
  DATA : LV_TABLE_NAME    LIKE FELD-NAME.

  CONCATENATE P_T_UI_FUNCTIONS '[]' INTO  LV_TABLE_NAME.
  ASSIGN     (LV_TABLE_NAME)    TO <TABLE>.

  PERFORM APPEND_EXCLUDE_FUNCTIONS
        TABLES  <TABLE>
         USING :
                CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,
                CL_GUI_ALV_GRID=>MC_FC_GRAPH,
                CL_GUI_ALV_GRID=>MC_FC_HELP,
                CL_GUI_ALV_GRID=>MC_FC_INFO,
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,               " 행 카피
                CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,           " 행 카피
                CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,                " 가위
                CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,         " 행삭제
                CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,         " 행삽입
                CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW,
                CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,
                " 라인생성
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,
                " 겹쳐쓰기
                CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW,
                " 겹쳐쓰기
                CL_GUI_ALV_GRID=>MC_FC_TO_REP_TREE,
                CL_GUI_ALV_GRID=>MC_FC_REFRESH.

ENDFORM.                    " TOOLBAR_PART
*&---------------------------------------------------------------------*
*&      Form  APPEND_EXCLUDE_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<TABLE>  text
*      -->P_CL_GUI_ALV_GRID=>MC_FC_LOC_UND  text
*----------------------------------------------------------------------*
FORM APPEND_EXCLUDE_FUNCTIONS  TABLES  P_T_TABLE
                                USING  P_VALUE.

  DATA : L_UI_FUNC TYPE UI_FUNC.

  L_UI_FUNC = P_VALUE.
  APPEND L_UI_FUNC TO P_T_TABLE.

ENDFORM.                    " APPEND_EXCLUDE_FUNCTIONS
*&---------------------------------------------------------------------*
*&      Form  LVC_FIELDCATALOG_MERGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_LVC_FCAT  text
*----------------------------------------------------------------------*
FORM LVC_FIELDCATALOG_MERGE  CHANGING P_T_LVC_FCAT TYPE LVC_T_FCAT.

  DATA LS_FCAT TYPE LVC_S_FCAT.

  CLEAR:   P_T_LVC_FCAT, P_T_LVC_FCAT[].
*
  PERFORM FILL_FIELD_CATALOGS TABLES P_T_LVC_FCAT USING:

      'S' 'FIELDNAME'    'RCEPNO',
      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '접수번호',

      'S' 'FIELDNAME'    'KZLOESCH',
      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '삭제',

      'S' 'FIELDNAME'    'AJAHR',
      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '연도',

      'S' 'FIELDNAME'    'RCEPDT',
      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '접수일',

      'S' 'FIELDNAME'    'STATUS',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '상태',

      'S' 'FIELDNAME'    'STATUST',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '상태내역',

      'S' 'FIELDNAME'    'KUNUM',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '고객',

      'S' 'FIELDNAME'    'KUNUMT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '고객내역',

      'S' 'FIELDNAME'    'PRIORITY',
*      ' '  'KEY'         'X',
      ' ' 'JUST'         'C',
      'E' 'COLTEXT'      '중요도',

      'S' 'FIELDNAME'    'PRCTR',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '손익센터',

      'S' 'FIELDNAME'    'PRCTRT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '손익센터내역',

      'S' 'FIELDNAME'    'WERKS_H',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '접수플랜트',

      'S' 'FIELDNAME'    'WERKS_HT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '플랜트내역',

      'S' 'FIELDNAME'    'SPGCD',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '제품군',

      'S' 'FIELDNAME'    'SPGCDT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '제품군내역',

      'S' 'FIELDNAME'    'QMTXT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '주제',

*->[가온전선]--------------------CHG S
       'S' 'FIELDNAME'    'ATTCH',
*      ' '  'KEY'         'X',
*       ' ' 'HOTSPOT'     'X',
       ' ' 'ICON'         'X',
       ' ' 'JUST'         'C',
      'E' 'COLTEXT'      '첨부파일',
*      'S' 'FIELDNAME'    'DOKNR',
**      ' '  'KEY'         'X',
*       ' ' 'HOTSPOT'     'X',
*      'E' 'COLTEXT'      '문서번호',
*-<[가온전선]--------------------CHG E

      'S' 'FIELDNAME'    'RCLAS',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '접수구분',

      'S' 'FIELDNAME'    'RCLAST',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '접수구분내역',

      'S' 'FIELDNAME'    'DSTGR',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '불만사유',

      'S' 'FIELDNAME'    'DSTGRT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '불만사유내역',

      'S' 'FIELDNAME'    'VTWEG',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '유통경로',

      'S' 'FIELDNAME'    'VTWEGT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '유통경로내역',

      'S' 'FIELDNAME'    'SQMNUM',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      'SVC통지',

      'S' 'FIELDNAME'    'AUFNR',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      'SVC오더',

      'S' 'FIELDNAME'    'QMNUM',
*      ' '  'KEY'         'X',
       ' ' 'HOTSPOT'     'X',
      'E' 'COLTEXT'      '고객불만통지',

      'S' 'FIELDNAME'    'DCLAS1',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '불만구분(불만)',

      'S' 'FIELDNAME'    'DCLAS2',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '불만구분(반품)',

      'S' 'FIELDNAME'    'DCLAS3',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '불만구분(클레임)',

      'S' 'FIELDNAME'    'DCLAS4',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '불만구분(VOC)',

      'S' 'FIELDNAME'    'DCLAS5',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '불만구분(기타)',

      'S' 'FIELDNAME'    'COKAT2',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '원인부문카타로그',

      'S' 'FIELDNAME'    'COGRP2',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '원인부문코드그룹',

      'S' 'FIELDNAME'    'CONET2',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '원인부문코드',

      'S' 'FIELDNAME'    'COVER2',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '원인부문코드버전',

      'S' 'FIELDNAME'    'CONET2T',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '원인부문코드내역',


      'S' 'FIELDNAME'    'RESPT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '책임부서',

      'S' 'FIELDNAME'    'RESPTT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '책임부서내역',

      'S' 'FIELDNAME'    'QMDAT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '고객불만릴리즈일',

      'S' 'FIELDNAME'    'DSTDT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '최종처리일',

      'S' 'FIELDNAME'    'CMPDT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '고객불만종료일',

      'S' 'FIELDNAME'    'SUMAMT',
*      ' '  'KEY'         'X',
      ' ' 'CURRENCY'     'KRW',
      'E' 'COLTEXT'      '총손실금액',

      'S' 'FIELDNAME'    'ETAMT',
*      ' '  'KEY'         'X',
      ' ' 'CURRENCY'     'KRW',
      'E' 'COLTEXT'      '추정손실금액',

      'S' 'FIELDNAME'    'RKMNG',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '불만제기수량',

      'S' 'FIELDNAME'    'MGEIN',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '불만제기수량단위',

      'S' 'FIELDNAME'    'KWMENG',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '불만확정수량',

      'S' 'FIELDNAME'    'VRKME',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '불만확정수량단위',

      'S' 'FIELDNAME'    'RFAMT',
*      ' '  'KEY'         'X',
      ' ' 'CURRENCY'     'KRW',
      'E' 'COLTEXT'      '반품금액',

      'S' 'FIELDNAME'    'RTAMT',
*      ' '  'KEY'         'X',
      ' ' 'CURRENCY'     'KRW',
      'E' 'COLTEXT'      '반품폐기비',

      'S' 'FIELDNAME'    'RTAMT2',
*      ' '  'KEY'         'X',
      ' ' 'CURRENCY'     'KRW',
      'E' 'COLTEXT'      '반품폐기비(외부)',

      'S' 'FIELDNAME'    'GBAMT',
*      ' '  'KEY'         'X',
      ' ' 'CURRENCY'     'KRW',
      'E' 'COLTEXT'      '잡손실폐기비',

      'S' 'FIELDNAME'    'CLAMT',
*      ' '  'KEY'         'X',
      ' ' 'CURRENCY'     'KRW',
      'E' 'COLTEXT'      '클레임출고비',

      'S' 'FIELDNAME'    'IPCST',
*      ' '  'KEY'         'X',
      ' ' 'CURRENCY'     'KRW',
      'E' 'COLTEXT'      '반품검사비',

      'S' 'FIELDNAME'    'MVCST',
*      ' '  'KEY'         'X',
      ' ' 'CURRENCY'     'KRW',
      'E' 'COLTEXT'      '반품운반비',

      'S' 'FIELDNAME'    'CSACT',
*      ' '  'KEY'         'X',
      ' ' 'CURRENCY'     'KRW',
      'E' 'COLTEXT'      'CS인건비',

      'S' 'FIELDNAME'    'CSOUT',
*      ' '  'KEY'         'X',
      ' ' 'CURRENCY'     'KRW',
      'E' 'COLTEXT'      'CS외주비',

      'S' 'FIELDNAME'    'CSPAT',
*      ' '  'KEY'         'X',
      ' ' 'CURRENCY'     'KRW',
      'E' 'COLTEXT'      'CS부품비',

      'S' 'FIELDNAME'    'AMT1',
*      ' '  'KEY'         'X',
      ' ' 'CURRENCY'     'KRW',
      'E' 'COLTEXT'      '손실보상비',

      'S' 'FIELDNAME'    'AMT2',
*      ' '  'KEY'         'X',
      ' ' 'CURRENCY'     'KRW',
      'E' 'COLTEXT'      '지체상환금',

      'S' 'FIELDNAME'    'AMT3',
*      ' '  'KEY'         'X',
      ' ' 'CURRENCY'     'KRW',
      'E' 'COLTEXT'      'A/S지원비',

      'S' 'FIELDNAME'    'AMT4',
*      ' '  'KEY'         'X',
      ' ' 'CURRENCY'     'KRW',
      'E' 'COLTEXT'      '하자보수비',

      'S' 'FIELDNAME'    'AMT5',
*      ' '  'KEY'         'X',
      ' ' 'CURRENCY'     'KRW',
      'E' 'COLTEXT'      '분석검사비',

      'S' 'FIELDNAME'    'AMT6',
*      ' '  'KEY'         'X',
      ' ' 'CURRENCY'     'KRW',
      'E' 'COLTEXT'      'Warranty비',

      'S' 'FIELDNAME'    'AMT7',
*      ' '  'KEY'         'X',
      ' ' 'CURRENCY'     'KRW',
      'E' 'COLTEXT'      'CS자재등구입비',

      'S' 'FIELDNAME'    'AMT8',
*      ' '  'KEY'         'X',
      ' ' 'CURRENCY'     'KRW',
      'E' 'COLTEXT'      '고객불만구상권',

      'S' 'FIELDNAME'    'AMT9',
*      ' '  'KEY'         'X',
      ' ' 'CURRENCY'     'KRW',
      'E' 'COLTEXT'      '협력업체회수금',

      'S' 'FIELDNAME'    'AMT10',
*      ' '  'KEY'         'X',
      ' ' 'CURRENCY'     'KRW',
      'E' 'COLTEXT'      '공사재작업비(외부)',

      'S' 'FIELDNAME'    'RCPERNR',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '접수자사번',

      'S' 'FIELDNAME'    'RCPERNRT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '접수자이름',

      'S' 'FIELDNAME'    'RCNAM',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '접수자ID',

      'S' 'FIELDNAME'    'RCNAMT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '접수자ID내역',

      'S' 'FIELDNAME'    'CORDINR',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '코디네이터사번',

      'S' 'FIELDNAME'    'CORDINRT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '코디네이터이름',

      'S' 'FIELDNAME'    'CORDI',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '코디네이터ID',

      'S' 'FIELDNAME'    'CORDIT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '코디네이터ID내역',

      'S' 'FIELDNAME'    'JGNAMNR',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '처리승인자사번',

      'S' 'FIELDNAME'    'JGNAMNRT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '처리승인자이름',

      'S' 'FIELDNAME'    'JGNAM',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '처리승인자ID',

      'S' 'FIELDNAME'    'JGNAMT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '처리승인자ID내역',

      'S' 'FIELDNAME'    'SDNAMNR',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '영업담당자사번',

      'S' 'FIELDNAME'    'SDNAMNRT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '영업담당자이름',

      'S' 'FIELDNAME'    'SDNAM',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '영업담당자ID',

      'S' 'FIELDNAME'    'SDNAMT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '영업담당자ID내역',

      'S' 'FIELDNAME'    'VKBUR',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '영업팀',

      'S' 'FIELDNAME'    'VKBURT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '영업팀내역',

      'S' 'FIELDNAME'    'VKGRP',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '영업그룹',

      'S' 'FIELDNAME'    'VKGRPT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '영업그룹내역',

      'S' 'FIELDNAME'    'ERNAM',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '생성인',

      'S' 'FIELDNAME'    'ERDAT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '생성일',

      'S' 'FIELDNAME'    'ERZET',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '생성시간',

      'S' 'FIELDNAME'    'AENAM',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '변경인',

      'S' 'FIELDNAME'    'AEDAT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '변경일',

      'S' 'FIELDNAME'    'AEZET',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '변경시간',

      'S' 'FIELDNAME'    'QMDAT',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      '릴리즈일',

      'S' 'FIELDNAME'    'ZAEDAT_B',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      'BackJobUpdate일',

      'S' 'FIELDNAME'    'ZAEZET_B',
*      ' '  'KEY'         'X',
      'E' 'COLTEXT'      'BackJobUpdate시간'.

* *   C20111012_79186     호사코드 1000인경우 필드값 제어추가
  READ TABLE S_BUKRS INDEX 1.
*  IF SY-SUBRC = 0.
*    IF S_BUKRS-LOW = '1000'.
*
  PERFORM FILL_FIELD_CATALOGS TABLES P_T_LVC_FCAT USING:
      'S' 'FIELDNAME'    'CDDAT',
     'E' 'COLTEXT'      '생산완료일',

      'S' 'FIELDNAME'    'DLDAT',
      'E' 'COLTEXT'      '출하일'.
*    ENDIF.
*  ENDIF.
* *   C20111012_79186   END
*  LOOP AT P_T_LVC_FCAT ASSIGNING FIELD-SYMBOL(<FS_FCAT>)
*                         WHERE FIELDNAME = 'ATTCH'.
*    <FS_FCAT>-ICON = 'X'.
*    <FS_FCAT>-JUST = 'C'.
*  ENDLOOP.
ENDFORM.                    " LVC_FIELDCATALOG_MERGE
*&---------------------------------------------------------------------*
*&      Form  FILL_FIELD_CATALOGS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_T_LVC_FCAT  text
*      -->P_0243   text
*      -->P_0244   text
*      -->P_0245   text
*----------------------------------------------------------------------*
FORM FILL_FIELD_CATALOGS  TABLES   P_T_LVC_FCAT LIKE GT_LVC_FCAT
                           USING P_GUB  P_FNAME  P_VALUE.

  DATA : LV_FNAME(40).
  FIELD-SYMBOLS <FS> TYPE ANY.

  IF P_GUB = 'S'.
    CLEAR GS_LVC_FCAT.
  ENDIF.

  CONCATENATE 'GS_LVC_FCAT-' P_FNAME INTO LV_FNAME.

  ASSIGN (LV_FNAME) TO <FS>.
  <FS> = P_VALUE.

  IF P_FNAME = 'REPTEXT'. " 텍스트 반영
    GS_LVC_FCAT-SCRTEXT_L = GS_LVC_FCAT-SCRTEXT_M
                          = GS_LVC_FCAT-SCRTEXT_S
                          = P_VALUE.
    GS_LVC_FCAT-COLDDICTXT = 'L'.
  ENDIF.

  IF P_GUB = 'E'.
    APPEND GS_LVC_FCAT TO P_T_LVC_FCAT.
  ENDIF.


ENDFORM.                    " FILL_FIELD_CATALOGS
*&---------------------------------------------------------------------*
*&      Form  EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER .

  CALL METHOD LCL_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

*  CALL METHOD LCL_GRID->SET_READY_FOR_INPUT
*    EXPORTING
*      I_READY_FOR_INPUT = 1.

  CHECK LCL_EVENT_RECEIVER IS INITIAL.
* Event Handler 등록
  CREATE OBJECT LCL_EVENT_RECEIVER.
  SET HANDLER :
      LCL_EVENT_RECEIVER->HANDLE_TOOLBAR                FOR LCL_GRID,
      LCL_EVENT_RECEIVER->HANDLE_USER_COMMAND           FOR LCL_GRID,
      LCL_EVENT_RECEIVER->HANDLE_DATA_CHANGED           FOR LCL_GRID,
      LCL_EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK          FOR LCL_GRID,
      LCL_EVENT_RECEIVER->HANDLE_DOUBLE_CLICK           FOR LCL_GRID,
      LCL_EVENT_RECEIVER->HANDLE_ON_F4                  FOR LCL_GRID,
      LCL_EVENT_RECEIVER->HANDLE_DATA_CHANGED_FINISHED  FOR LCL_GRID,
      LCL_EVENT_RECEIVER->HANDLE_TOP_OF_PAGE            FOR LCL_GRID.


ENDFORM.                    " EVENT_HANDLER_REGISTER
*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY_PART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_DISPLAY_PART .

  GS_VARIANT-REPORT = SY-REPID.

  CALL METHOD LCL_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LVC_LAYO
      IT_TOOLBAR_EXCLUDING = GT_UI_FUNCTIONS
      I_SAVE               = 'A'        " 전체가능유형.
      I_DEFAULT            = 'X'        " 레이아웃 사전셋팅 허용.
      IS_VARIANT           = GS_VARIANT " 선택메뉴Display
    CHANGING
      IT_OUTTAB            = GT_DATA[]
      IT_FIELDCATALOG      = GT_LVC_FCAT[]
      IT_SORT              = GT_LVC_SORT[].


ENDFORM.                    " ALV_DISPLAY_PART
*&---------------------------------------------------------------------*
*&      Form  REFRESH_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REFRESH_CONTAINER .

  DATA LS_STABLE TYPE LVC_S_STBL.
  LS_STABLE-ROW = 'X'.
  LS_STABLE-COL  = 'X'.

  CALL METHOD LCL_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.                    " REFRESH_CONTAINER
*&---------------------------------------------------------------------*
*&      Form  GET_SUL_STATUS_TXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0225   text
*      -->P_GT_DATA_STATUS  text
*      <--P_GT_DATA_STATUST  text
*----------------------------------------------------------------------*
FORM GET_SUL_STATUS_TXT  USING    P_DOMNAME P_VAL
                         CHANGING P_TEXT.

  IF  NOT  P_VAL IS INITIAL.

    DATA: L_DOMNAME LIKE DD07L-DOMNAME,
          L_VALUE   LIKE DD07L-DOMVALUE_L,
          L_DD07V   LIKE DD07V,
          L_RC      LIKE SY-SUBRC.

    L_DOMNAME = P_DOMNAME.
    L_VALUE   = P_VAL.

    CLEAR: L_DD07V, L_RC.
    CALL FUNCTION 'DD_DOMVALUE_TEXT_GET'
      EXPORTING
        DOMNAME  = L_DOMNAME
        VALUE    = L_VALUE
        LANGU    = SY-LANGU
*       BYPASS_BUFFER       = ' '
      IMPORTING
        DD07V_WA = L_DD07V
        RC       = L_RC.

    P_TEXT = L_DD07V-DDTEXT.
*  p_rc   = l_rc.
  ELSE.
    CLEAR: P_TEXT.
  ENDIF.

ENDFORM.                    " GET_SUL_STATUS_TXT
*&---------------------------------------------------------------------*
*&      Form  GET_KUNUMT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_DATA_KUNUM  text
*      <--P_GT_DATA_KUNUMT  text
*----------------------------------------------------------------------*
FORM GET_KUNUMT  USING    P_KUNUM
                 CHANGING P_KUNUMT.

  DATA L_KUNNR TYPE KUNNR.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = P_KUNUM
    IMPORTING
      OUTPUT = L_KUNNR.

  IF  NOT  P_KUNUM  IS INITIAL.
    SELECT SINGLE NAME1
             INTO P_KUNUMT
             FROM KNA1
            WHERE KUNNR = L_KUNNR.   "고객번호
  ELSE.
    CLEAR: P_KUNUMT.
  ENDIF.

ENDFORM.                    " GET_KUNUMT
*&---------------------------------------------------------------------*
*&      Form  GET_PRCTRT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_DATA_PRCTR  text
*      <--P_GT_DATA_PRCTRT  text
*----------------------------------------------------------------------*
FORM GET_PRCTRT  USING    P_PRCTR
                 CHANGING P_PRCTRT.

  DATA : L_PRCTR TYPE PRCTR.

  L_PRCTR = P_PRCTR.


  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = L_PRCTR
    IMPORTING
      OUTPUT = L_PRCTR.



  IF  NOT  P_PRCTR  IS INITIAL.
    SELECT SINGLE KTEXT
      INTO P_PRCTRT
      FROM CEPCT
     WHERE PRCTR = L_PRCTR    "손익센터
       AND SPRAS = SY-LANGU.
  ELSE.
    CLEAR: P_PRCTRT.
  ENDIF.

ENDFORM.                    " GET_PRCTRT
*&---------------------------------------------------------------------*
*&      Form  GET_SPGCD_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_DATA_SPGCD  text
*      <--P_GT_DATA_SPGCDT  text
*----------------------------------------------------------------------*
FORM GET_SPGCD_DESC  USING    P_CODE
                     CHANGING P_TEXT.

  CHECK NOT P_CODE IS INITIAL.

  CLEAR: P_TEXT.

  SELECT SINGLE VTEXT
    FROM TSPAT
    INTO P_TEXT
   WHERE SPRAS EQ SY-LANGU
     AND SPART EQ P_CODE.    "SPG (제품군 )

ENDFORM.                    " GET_SPGCD_DESC
*&---------------------------------------------------------------------*
*&      Form  GET_SUL_RCLAS_TXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0250   text
*      -->P_GT_DATA_RCLAS  text
*      <--P_GT_DATA_RCLAST  text
*----------------------------------------------------------------------*
FORM GET_SUL_RCLAS_TXT  USING    P_DOMNAME   P_VAL
                         CHANGING P_TEXT.

  IF  NOT  P_VAL IS INITIAL.

    DATA: L_DOMNAME LIKE DD07L-DOMNAME,
          L_VALUE   LIKE DD07L-DOMVALUE_L,
          L_DD07V   LIKE DD07V,
          L_RC      LIKE SY-SUBRC.

    L_DOMNAME = P_DOMNAME.
    L_VALUE   = P_VAL.

    CLEAR: L_DD07V, L_RC.
    CALL FUNCTION 'DD_DOMVALUE_TEXT_GET'
      EXPORTING
        DOMNAME  = L_DOMNAME
        VALUE    = L_VALUE
        LANGU    = SY-LANGU
*       BYPASS_BUFFER       = ' '
      IMPORTING
        DD07V_WA = L_DD07V
        RC       = L_RC.

    P_TEXT = L_DD07V-DDTEXT.
*  p_rc   = l_rc.
  ELSE.
    CLEAR: P_TEXT.
  ENDIF.

ENDFORM.                    " GET_SUL_RCLAS_TXT
*&---------------------------------------------------------------------*
*&      Form  GET_SUL_DSTGR_TXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0257   text
*      -->P_GT_DATA_DSTGR  text
*      <--P_GT_DATA_DSTGRT  text
*----------------------------------------------------------------------*
FORM GET_SUL_DSTGR_TXT  USING    P_DOMNAME   P_VAL
                         CHANGING P_TEXT.

  IF  NOT  P_VAL IS INITIAL.

    DATA: L_DOMNAME LIKE DD07L-DOMNAME,
          L_VALUE   LIKE DD07L-DOMVALUE_L,
          L_DD07V   LIKE DD07V,
          L_RC      LIKE SY-SUBRC.

    L_DOMNAME = P_DOMNAME.
    L_VALUE   = P_VAL.

    CLEAR: L_DD07V, L_RC.
    CALL FUNCTION 'DD_DOMVALUE_TEXT_GET'
      EXPORTING
        DOMNAME  = L_DOMNAME
        VALUE    = L_VALUE
        LANGU    = SY-LANGU
*       BYPASS_BUFFER       = ' '
      IMPORTING
        DD07V_WA = L_DD07V
        RC       = L_RC.

    P_TEXT = L_DD07V-DDTEXT.
*  p_rc   = l_rc.
  ELSE.
    CLEAR: P_TEXT.
  ENDIF.

ENDFORM.                    " GET_SUL_DSTGR_TXT
*&---------------------------------------------------------------------*
*&      Form  GET_BASE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_BASE .
  %%CLEAR : R_CD023,  R_CD019,  R_CD029,
            R_CD028,  R_CD017,  R_CD031,
            R_CD032,  R_CD033,  R_CD018, R_CH002.

*__손실보상비
  R_CD023      = 'IEQ'.
  R_CD023-LOW  = 'CD023'.   APPEND R_CD023.

*__지체상환금
  R_CD019      = 'IEQ'.
  R_CD019-LOW  = 'CD019'.   APPEND R_CD019.

*__AS지원비
  R_CD029      = 'IEQ'.
  R_CD029-LOW  = 'CD029'.   APPEND R_CD029.

*__하자보수비
  R_CD028      = 'IEQ'.
  R_CD028-LOW  = 'CD028'.   APPEND R_CD028.

*__분석검사비
  R_CD017      = 'IEQ'.
  R_CD017-LOW  = 'CD017'.   APPEND R_CD017.

*__Warranty비
  R_CD031      = 'IEQ'.
  R_CD031-LOW  = 'CD031'.   APPEND R_CD031.

*__CS자재구입비
  R_CD032      = 'IEQ'.
  R_CD032-LOW  = 'CD032'.   APPEND R_CD032.

*__고객불만구상권
  R_CD033      = 'IEQ'.
  R_CD033-LOW  = 'CD033'.   APPEND R_CD033.

*__협력업체회수금
  R_CD018      = 'IEQ'.
  R_CD018-LOW  = 'CD018'.  APPEND R_CD018.
  R_CD018-LOW  = 'CD022'.  APPEND R_CD018.

*-- 공사재작업비(외부)  ZQMT0700
  R_CH002      = 'IEQ'.
  R_CH002-LOW  = 'CH002'.   APPEND R_CH002.

ENDFORM.                    " GET_BASE
*&---------------------------------------------------------------------*
*&      Form  MAKE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKE_DATA .

  LOOP AT GT_DATA.

    %%ALPHA_CONV_OUT : GT_DATA-KUNUM  GT_DATA-KUNUM,
                       GT_DATA-PRCTR  GT_DATA-PRCTR,
                       GT_DATA-DOKNR  GT_DATA-DOKNR.

* 기계번호
    SELECT SINGLE MCNO INTO GT_DATA-MCNO
      FROM ZQMT0011B
     WHERE RCEPNO = GT_DATA-RCEPNO.

*__플랜트 내역
    PERFORM GET_WERKS USING GT_DATA-WERKS_H
                      CHANGING GT_DATA-WERKS_HT.

*__제품군 내역
    PERFORM GET_SPGCD_TEXT USING GT_DATA-SPGCD
                           CHANGING GT_DATA-SPGCDT.

*__원인부문내역 카타로그
    PERFORM GET_KURZTEXT USING GT_DATA-COKAT2 GT_DATA-COGRP2
                               GT_DATA-CONET2 GT_DATA-COVER2
                         CHANGING GT_DATA-CONET2T.

*__상태내역
    PERFORM GET_SUL_STATUS_TXT USING    'ZSTATUS_H' GT_DATA-STATUS
                               CHANGING GT_DATA-STATUST.
*__고객내역
    PERFORM GET_KUNUMT USING GT_DATA-KUNUM CHANGING GT_DATA-KUNUMT.

*__손익센터내역
    PERFORM GET_PRCTRT USING GT_DATA-PRCTR CHANGING GT_DATA-PRCTRT.

*__접수구분내역
    PERFORM GET_SUL_RCLAS_TXT USING    'ZDRCLAS' GT_DATA-RCLAS
                              CHANGING GT_DATA-RCLAST.

*__불만사유내역
    PERFORM GET_SUL_DSTGR_TXT USING    'ZAUGRU' GT_DATA-DSTGR
                              CHANGING GT_DATA-DSTGRT.

*__책임부서내역
    PERFORM RESPT_READ  USING    'AB'  GT_DATA-RESPT
                        CHANGING  GT_DATA-RESPTT.

*__유통경로내역
    PERFORM VTWEG_READ  USING  GT_DATA-VTWEG CHANGING GT_DATA-VTWEGT.

*__영업팀내역
    PERFORM VKBUR_READ  USING  GT_DATA-VKBUR CHANGING GT_DATA-VKBURT.

*__영업그룹내역
    PERFORM VKGRP_READ  USING  GT_DATA-VKGRP CHANGING GT_DATA-VKGRPT.

    "첨부파일
    PERFORM CHECK_ATTACH USING GT_DATA-RCEPNO CHANGING GT_DATA-ATTCH.


    READ TABLE GT_0011M WITH KEY RCEPNO = GT_DATA-RCEPNO
                                 BINARY SEARCH.
    IF SY-SUBRC = 0.
      GT_DATA-RKMNG  = GT_0011M-RKMNG.
      GT_DATA-MGEIN  = GT_0011M-MGEIN.
      GT_DATA-KWMENG = GT_0011M-KWMENG.
      GT_DATA-VRKME  = GT_0011M-VRKME.
    ENDIF.

    LOOP AT GT_0011M WHERE RCEPNO = GT_DATA-RCEPNO.
      GT_DATA-RFAMT = GT_DATA-RFAMT + GT_0011M-RFAMT. "반품금액
      GT_DATA-RTAMT = GT_DATA-RTAMT + GT_0011M-RTAMT. "반품폐기비
      GT_DATA-RTAMT2 = GT_DATA-RTAMT2 + GT_0011M-RTAMT2. "반품폐기비(외부)
      GT_DATA-GBAMT = GT_DATA-GBAMT + GT_0011M-GBAMT. "잡손실폐기비
      GT_DATA-CLAMT = GT_DATA-CLAMT + GT_0011M-CLAMT. "클레임출고비
      GT_DATA-MVCST = GT_DATA-MVCST + GT_0011M-MVCST. "반품운반비
      GT_DATA-IPCST = GT_DATA-IPCST + GT_0011M-IPCST. "반품검사비
    ENDLOOP.



    LOOP AT GT_0016F WHERE RCEPNO = GT_DATA-RCEPNO.



      IF GT_0016F-QCODE1 IN R_CD023.
        IF GT_0016F-SHKZG = 'S'.
          GT_DATA-AMT1 = GT_DATA-AMT1 + GT_0016F-WOGBTR.
        ELSEIF  GT_0016F-SHKZG = 'H'.
          GT_DATA-AMT1 = GT_DATA-AMT1 - GT_0016F-WOGBTR.
        ENDIF.

      ELSEIF GT_0016F-QCODE1 IN R_CD019.
        IF GT_0016F-SHKZG = 'S'.
          GT_DATA-AMT2 = GT_DATA-AMT2 + GT_0016F-WOGBTR.
        ELSEIF  GT_0016F-SHKZG = 'H'.
          GT_DATA-AMT2 = GT_DATA-AMT2 - GT_0016F-WOGBTR.
        ENDIF.

      ELSEIF GT_0016F-QCODE1 IN R_CD029.
        IF GT_0016F-SHKZG = 'S'.
          GT_DATA-AMT3 = GT_DATA-AMT3 + GT_0016F-WOGBTR.
        ELSEIF  GT_0016F-SHKZG = 'H'.
          GT_DATA-AMT3 = GT_DATA-AMT3 - GT_0016F-WOGBTR.
        ENDIF.

      ELSEIF GT_0016F-QCODE1 IN R_CD028.
        IF GT_0016F-SHKZG = 'S'.
          GT_DATA-AMT4 = GT_DATA-AMT4 + GT_0016F-WOGBTR.
        ELSEIF  GT_0016F-SHKZG = 'H'.
          GT_DATA-AMT4 = GT_DATA-AMT4 - GT_0016F-WOGBTR.
        ENDIF.

      ELSEIF GT_0016F-QCODE1 IN R_CD017.
        IF GT_0016F-SHKZG = 'S'.
          GT_DATA-AMT5 = GT_DATA-AMT5 + GT_0016F-WOGBTR.
        ELSEIF  GT_0016F-SHKZG = 'H'.
          GT_DATA-AMT5 = GT_DATA-AMT5 - GT_0016F-WOGBTR.
        ENDIF.

      ELSEIF GT_0016F-QCODE1 IN R_CD031.
        IF GT_0016F-SHKZG = 'S'.
          GT_DATA-AMT6 = GT_DATA-AMT6 + GT_0016F-WOGBTR.
        ELSEIF  GT_0016F-SHKZG = 'H'.
          GT_DATA-AMT6 = GT_DATA-AMT6 - GT_0016F-WOGBTR.
        ENDIF.

      ELSEIF GT_0016F-QCODE1 IN R_CD032.
        IF GT_0016F-SHKZG = 'S'.
          GT_DATA-AMT7 = GT_DATA-AMT7 + GT_0016F-WOGBTR.
        ELSEIF  GT_0016F-SHKZG = 'H'.
          GT_DATA-AMT7 = GT_DATA-AMT7 - GT_0016F-WOGBTR.
        ENDIF.

      ELSEIF GT_0016F-QCODE1 IN R_CD033.
        IF GT_0016F-SHKZG = 'S'.
          GT_DATA-AMT8 = GT_DATA-AMT8 + GT_0016F-WOGBTR.
        ELSEIF  GT_0016F-SHKZG = 'H'.
          GT_DATA-AMT8 = GT_DATA-AMT8 - GT_0016F-WOGBTR.
        ENDIF.

      ELSEIF GT_0016F-QCODE1 IN R_CD018.
        IF GT_0016F-SHKZG = 'S'.
          GT_DATA-AMT9 = GT_DATA-AMT9 + GT_0016F-WOGBTR.
        ELSEIF  GT_0016F-SHKZG = 'H'.
          GT_DATA-AMT9 = GT_DATA-AMT9 - GT_0016F-WOGBTR.
        ENDIF.

      ELSEIF GT_0016F-QCODE1 IN R_CH002.
        IF GT_0016F-SHKZG = 'S'.
          GT_DATA-AMT10 = GT_DATA-AMT10 + GT_0016F-WOGBTR.
        ELSEIF  GT_0016F-SHKZG = 'H'.
          GT_DATA-AMT10 = GT_DATA-AMT10 - GT_0016F-WOGBTR.
        ENDIF.

      ENDIF.
    ENDLOOP.

    GT_DATA-SUMAMT =
                GT_DATA-RTAMT           "반품폐기비
              + GT_DATA-RTAMT2          "반품폐기비(외부)
              + GT_DATA-GBAMT           "잡손실폐기비
              + GT_DATA-CLAMT           "클레임출고비
*              + GT_DATA-CSACT           "CS인건비
              + GT_DATA-CSOUT            "CS외주비
              + GT_DATA-CSPAT            "CS부품비
              + GT_DATA-MVCST            "반품운반비
              + GT_DATA-AMT1  * 100      "손실보상비
              + GT_DATA-AMT2  * 100      "지체상환금
              + GT_DATA-AMT3  * 100      "A/S지원비
              + GT_DATA-AMT4  * 100      "하자보수비
              + GT_DATA-AMT5  * 100      "분석검사비
              + GT_DATA-AMT6  * 100      "Warranty비
              + GT_DATA-AMT7  * 100      "CS자재등구입비
              + GT_DATA-AMT8  * 100      "고객불만구상권
              + GT_DATA-AMT9  * 100      "협력업체회수금
              + GT_DATA-AMT10 * 100.     "공사재작업비(외부)



    MODIFY GT_DATA.
  ENDLOOP.



ENDFORM.                    " MAKE_DATA
*&---------------------------------------------------------------------*
*&      Form  MODI_CHECKBOX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODI_CHECKBOX .

  DATA  : LT_ROW_NO LIKE LVC_S_ROW OCCURS 0 WITH HEADER LINE.
  %%CLEAR LT_ROW_NO.

*..기존 mark제거
  GT_DATA-SELX = ' '.
  MODIFY GT_DATA TRANSPORTING SELX WHERE SELX = 'X'.

*..선택 row의 index 가져오기
  CALL METHOD LCL_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW_NO[].

*..itab에 mark 하기
  LOOP AT LT_ROW_NO.
    READ TABLE GT_DATA INDEX LT_ROW_NO-INDEX.
    IF SY-SUBRC = 0.
      GT_DATA-SELX = 'X'.
      MODIFY GT_DATA INDEX LT_ROW_NO-INDEX.
    ENDIF.


  ENDLOOP.

ENDFORM.                    " MODI_CHECKBOX
*&---------------------------------------------------------------------*
*&      Form  RESPT_READ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_2694   text
*      -->P_GT_DATA_RESPT  text
*      <--P_GT_DATA_RESPTT  text
*----------------------------------------------------------------------*
FORM RESPT_READ  USING     P_PARVW      LIKE IHPA-PARVW
                           P_PARNR      LIKE IHPA-PARNR
                 CHANGING  P_NAME.

  CLEAR: DIADRP, DIADRC, DIADR.

  CALL FUNCTION 'PM_PARTNER_READ'
    EXPORTING
      PARVW                = P_PARVW
      PARNR                = P_PARNR
    IMPORTING
      DIADRP_WA            = DIADRP
      DIADRC_WA            = DIADRC
      DIADR_WA             = DIADR
*     parnr_exp            = p_parnr
    EXCEPTIONS
      NO_VALID_PARNR_TODAY = 01
      OTHERS               = 02.
*  if sy-subrc <> 0.
*    clear: diadrp, diadrc, diadr.
*  endif.

*  F_KUNNR = DIADRP-KUNNR.
  P_NAME    =  DIADR-NAME_LIST.

ENDFORM.                    " RESPT_READ
*&---------------------------------------------------------------------*
*&      Form  VTWEG_READ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_DATA_VTWEG  text
*      <--P_GT_DATA_VTWEGT  text
*----------------------------------------------------------------------*
FORM VTWEG_READ  USING    P_VTWEG
                 CHANGING P_VTWEGT.

  IF  NOT  P_VTWEG  IS INITIAL.

    SELECT SINGLE  VTEXT
      INTO P_VTWEGT
      FROM TVTWT
     WHERE SPRAS EQ '3'
       AND VTWEG EQ P_VTWEG.
  ELSE.
    CLEAR P_VTWEGT.
  ENDIF.

ENDFORM.                    " VTWEG_READ
*&---------------------------------------------------------------------*
*&      Form  VKBUR_READ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_DATA_VKBUR  text
*      <--P_GT_DATA_VKBURT  text
*----------------------------------------------------------------------*
FORM VKBUR_READ  USING    P_VKBUR
                 CHANGING P_VKBURT.

  IF  NOT  P_VKBUR  IS INITIAL.

    SELECT SINGLE BEZEI
      INTO P_VKBURT
      FROM TVKBT
     WHERE SPRAS = SY-LANGU
       AND VKBUR = P_VKBUR.

  ELSE.
    CLEAR P_VKBURT.
  ENDIF.

ENDFORM.                    " VKBUR_READ
*&---------------------------------------------------------------------*
*&      Form  VKGRP_READ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_DATA_VKGRP  text
*      <--P_GT_DATA_VKGRPT  text
*----------------------------------------------------------------------*
FORM VKGRP_READ  USING    P_VKGRP
                 CHANGING P_VKGRPT.

  IF  NOT  P_VKGRP  IS INITIAL.

    SELECT SINGLE BEZEI
      INTO P_VKGRPT
      FROM TVGRT
     WHERE SPRAS = SY-LANGU
       AND VKGRP = P_VKGRP.

  ELSE.
    CLEAR P_VKGRPT.
  ENDIF.

ENDFORM.                    " VKGRP_READ
*&---------------------------------------------------------------------*
*&      Form  F4_FOR_VARIANT
*&---------------------------------------------------------------------*
FORM F4_FOR_VARIANT  USING    P_VARI.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      IS_VARIANT    = GS_VARIANT
      I_SAVE        = 'A'
    IMPORTING
      E_EXIT        = G_EXIT
      ES_VARIANT    = GS_CS_VARIANT
    EXCEPTIONS
      NOT_FOUND     = 1
      PROGRAM_ERROR = 2
      OTHERS        = 3.

  IF SY-SUBRC EQ 0 AND G_EXIT IS INITIAL.
    P_VARI = GS_CS_VARIANT-VARIANT.
  ELSE.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " F4_FOR_VARIANT
*&---------------------------------------------------------------------*
*&      Form  GET_WERKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_DATA_WERKS_H  text
*      -->P_CHANING  text
*      -->P_GT_DATA_WERKS_HT  text
*----------------------------------------------------------------------*
FORM GET_WERKS  USING    P_WERKS
                CHANGING  VALUE(P_NAME1).

  IF P_WERKS IS NOT INITIAL.
    SELECT SINGLE NAME1 INTO P_NAME1
    FROM T001W
    WHERE WERKS = P_WERKS.
  ELSE.
    CLEAR: P_NAME1.
  ENDIF.



ENDFORM.                    " GET_WERKS
*&---------------------------------------------------------------------*
*&      Form  GET_KURZTEXT
*&---------------------------------------------------------------------*

FORM GET_KURZTEXT  USING    P_KATALOGART
                            P_CODEGRUPPE
                            P_CODE
                            P_VERSION
                   CHANGING VALUE(P_KURZTEXT).
  IF P_CODE IS NOT INITIAL.
    SELECT SINGLE KURZTEXT INTO P_KURZTEXT
    FROM QPCT
    WHERE
         KATALOGART = P_KATALOGART
    AND  CODEGRUPPE = P_CODEGRUPPE
    AND  CODE = P_CODE
    AND  SPRACHE = '3'
    AND  VERSION = P_VERSION.
  ELSE.
    CLEAR: P_KURZTEXT.
  ENDIF.


ENDFORM.                    " GET_KURZTEXT
*&---------------------------------------------------------------------*
*&      Form  GET_SPGCD_TEXT
*&---------------------------------------------------------------------*
FORM GET_SPGCD_TEXT  USING    P_SPGCD
                     CHANGING VALUE(P_SPGCDT).
  IF P_SPGCD IS NOT INITIAL.
    SELECT SINGLE VTEXT INTO P_SPGCDT
    FROM TSPAT
    WHERE SPART = P_SPGCD
    AND SPRAS = '3'.
  ELSE.
    CLEAR: P_SPGCDT.
  ENDIF.
ENDFORM.                    " GET_SPGCD_TEXT
*&---------------------------------------------------------------------*
*&      Form  HOTSPOT_CLICK
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK  USING    E_ROW_ID    TYPE LVC_S_ROW
                             E_COLUMN_ID TYPE LVC_S_COL.

  IF E_ROW_ID-ROWTYPE NE SPACE.
    MESSAGE S009.
    EXIT.
  ENDIF.

  CLEAR GT_DATA.
  READ TABLE GT_DATA INDEX E_ROW_ID.
  IF SY-SUBRC NE 0.
    MESSAGE S009.
    EXIT.
  ENDIF.

  CASE E_COLUMN_ID-FIELDNAME.

    WHEN 'QMNUM'.
      IF GT_DATA-QMNUM IS INITIAL.
        MESSAGE S009.
        EXIT.
      ENDIF.

      SET PARAMETER ID 'IQM' FIELD GT_DATA-QMNUM.
      CALL TRANSACTION 'QM03' AND SKIP FIRST SCREEN.

*->[가온전선]--------------------CHG S
*    WHEN 'ATTCH'.
*      IF GT_DATA-ATTCH IS NOT INITIAL.
*        PERFORM GET_ATTACHMENT USING GT_DATA.
*      ENDIF.
**    WHEN 'DOKNR'.
**      IF GT_DATA-DOKNR IS INITIAL.
**        MESSAGE S009.
**        EXIT.
**      ENDIF.
**
**
**      SET PARAMETER ID 'CV1'  FIELD GT_DATA-DOKNR .
**      SET PARAMETER ID 'CV2'  FIELD  GT_DATA-DOKAR.
**      SET PARAMETER ID 'CV3'  FIELD  GT_DATA-DOKVR .
**      CALL TRANSACTION 'CV03N' AND SKIP FIRST SCREEN.
*-<[가온전선]--------------------CHG E

    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*&      Form  CHECK_AUTH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_AUTH .

  DATA L_SUBRC TYPE SY-SUBRC.
  LOOP AT S_WERKSH.

    IF S_WERKSH-HIGH IS NOT INITIAL.
      MESSAGE E003 WITH '플랜트 [' S_WERKSH-HIGH
                  '] 는 범위값을 이용할 수 없습니다.'.
    ENDIF.

    PERFORM AUTHORITY_CHECKING_PROC(SAPMZQM0010)  USING S_WERKSH-LOW
                                      CHANGING L_SUBRC.
    IF L_SUBRC <> 0.
      MESSAGE E003 WITH '플랜트 [' S_WERKSH-LOW
                      '] 작업권한을 확인하세요.'.
    ENDIF.
  ENDLOOP.

  LOOP AT S_WERKSM.

    IF S_WERKSM-HIGH IS NOT INITIAL.
      MESSAGE E003 WITH '플랜트 [' S_WERKSM-HIGH
                  '] 는 범위값을 이용할 수 없습니다.'.
    ENDIF.

    PERFORM AUTHORITY_CHECKING_PROC(SAPMZQM0010)  USING S_WERKSM-LOW
                                      CHANGING L_SUBRC.
    IF L_SUBRC <> 0.
      MESSAGE E003 WITH '플랜트 [' S_WERKSM-LOW
                      '] 작업권한을 확인하세요.'.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " CHECK_AUTH
*&---------------------------------------------------------------------*
*&      Form  CHECK_USER_ID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_UNAME  text
*      -->P_CORDI_NAME  text
*      <--P_CHK  text
*----------------------------------------------------------------------*
FORM  CHECK_USER_ID  USING  P_SY_USER_ID
                           P_USER_ID
                  CHANGING P_CHK.

  DATA : L_SY_USER_DEP TYPE NAME_TEXT,
         L_USER_DEP    TYPE NAME_TEXT.
* LS전선의 경우,
* 로그인 사용자 ID의 부서명과
* 고객불만의 코디네이터 ID의 부서명이 동일한지 확인한다
  SELECT SINGLE NAME_TEXTC
           FROM USER_ADDR
           INTO L_SY_USER_DEP
          WHERE BNAME EQ P_SY_USER_ID.

  SELECT SINGLE NAME_TEXTC
           FROM USER_ADDR
           INTO L_USER_DEP
          WHERE BNAME EQ P_USER_ID.

  IF L_SY_USER_DEP EQ L_USER_DEP.
    P_CHK = 'X'.
  ELSE.
    P_CHK = ''.
  ENDIF.

ENDFORM.                    " CHECK_UNAME
*&---------------------------------------------------------------------*
*&      Form  CHECK_USER_CC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_UNAME  text
*      -->P_G_SDNAM  text
*      <--P_G_SDNAM_CHK  text
*----------------------------------------------------------------------*
FORM CHECK_USER_CC  USING    P_SY_USER_ID
                             P_USER_ID
                    CHANGING P_CHK.

  DATA : L_SY_USER_CC LIKE USR21-KOSTL,
         L_USER_CC    LIKE USR21-KOSTL.
* LS전선의 경우,
* 로그인 사용자 ID의 CC와
* 고객불만의 코디네이터 ID의 CC가 동일한지 확인한다
  SELECT SINGLE KOSTL
           FROM USR21
           INTO L_SY_USER_CC
          WHERE BNAME EQ P_SY_USER_ID.

  SELECT SINGLE KOSTL
           FROM USR21
           INTO L_USER_CC
          WHERE BNAME EQ P_USER_ID.

  IF L_SY_USER_CC EQ L_USER_CC.
    P_CHK = 'X'.
  ELSE.
    P_CHK = ''.
  ENDIF.

ENDFORM.                    " CHECK_USER_CC
*&---------------------------------------------------------------------*
*& Form SET_BUKRS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BUKRS .
  APPEND VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = GC_BUKRS_6000 ) TO S_BUKRS.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN_OUTPUT .
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 EQ 'ZM1'.
      SCREEN-INPUT = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_SUSER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_SUSER .
  CLEAR:GV_SUSER.

  DATA(LV_BUKRS) = VALUE BUKRS( S_BUKRS[ 1 ]-LOW OPTIONAL ).

  SELECT SINGLE FLD_02
    INTO @DATA(LV_FLD_02)
    FROM ZGTPPT1010
   WHERE MODULE_KIND  EQ 'SD'
     AND CODEGRP      EQ '6003'
     AND FLD_01       EQ @LV_BUKRS
     AND FLD_02       EQ @SY-UNAME.
  IF SY-SUBRC EQ 0.
    GV_SUSER = GC_X.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ATTACHMENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_DATA
*&---------------------------------------------------------------------*
FORM GET_ATTACHMENT  USING    PS_DATA LIKE GT_DATA.
  DATA:
    LV_MODE     TYPE C LENGTH 1,
    LS_OBJECT   TYPE SIBFLPORB,
    LV_SGS_FLAG TYPE SGS_FLAG.

  LS_OBJECT-INSTID = PS_DATA-RCEPNO.
  LS_OBJECT-TYPEID = GC_TYPEID_A.
  LS_OBJECT-CATID  = GC_CATID_A.

  SELECT SINGLE BRELGUID
    FROM SRGBTBREL
   WHERE INSTID_A EQ @LS_OBJECT-INSTID
     AND TYPEID_A EQ @LS_OBJECT-TYPEID
     AND CATID_A  EQ @LS_OBJECT-CATID
    INTO @DATA(LV_BRELGUID).
  IF SY-SUBRC NE 0.
    MESSAGE S001 WITH TEXT-M01 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  LV_MODE = GC_D.

  CALL FUNCTION 'GOS_ATTACHMENT_LIST_POPUP'
    EXPORTING
      IS_OBJECT       = LS_OBJECT
      IP_MODE         = LV_MODE
    IMPORTING
      EP_SAVE_REQUEST = LV_SGS_FLAG.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING    PS_E_ROW  TYPE LVC_S_ROW
                            PS_E_COLUMN TYPE LVC_S_COL
                            PS_ES_ROW_NO TYPE LVC_S_ROID.

  IF PS_E_ROW-ROWTYPE NE SPACE.
    MESSAGE S009.
    EXIT.
  ENDIF.

  CLEAR GT_DATA.
  READ TABLE GT_DATA INDEX PS_E_ROW-INDEX.
  IF SY-SUBRC NE 0.
    MESSAGE S009.
    EXIT.
  ENDIF.

  CASE PS_E_COLUMN-FIELDNAME.

    WHEN 'ATTCH'.  "첨부파일
      IF GT_DATA-ATTCH IS NOT INITIAL.
        PERFORM GET_ATTACHMENT USING GT_DATA.
      ENDIF.


    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ATTACH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_DATA_RCEPNO
*&      <-- GT_DATA_ATTCH
*&---------------------------------------------------------------------*
FORM CHECK_ATTACH  USING    PV_RCEPNO
                   CHANGING PV_ATTCH.

  DATA: LV_RELTYPE  TYPE SRGBTBREL-RELTYPE,
        LV_INSTID_A TYPE SRGBTBREL-INSTID_A,
        LV_TYPEID_A TYPE SRGBTBREL-TYPEID_A,
        LV_CATID_A  TYPE SRGBTBREL-CATID_A.

  LV_INSTID_A = PV_RCEPNO.
  LV_TYPEID_A = GC_TYPEID_A.
  LV_CATID_A  = GC_CATID_A.

  SELECT SINGLE BRELGUID
    FROM SRGBTBREL
   WHERE INSTID_A EQ @LV_INSTID_A
     AND TYPEID_A EQ @LV_TYPEID_A
     AND CATID_A  EQ @LV_CATID_A
    INTO @DATA(LV_BRELGUID).
  IF SY-SUBRC EQ 0.
    PV_ATTCH = ICON_ATTACHMENT.
  ELSE.
    CLEAR PV_ATTCH.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_WERKS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_WERKS  USING    PV_FNAME.

  SELECT DISTINCT B~WERKS,B~NAME1
    FROM T001K AS A INNER JOIN T001W AS B
                    ON A~BWKEY = B~BWKEY
   WHERE A~BUKRS IN @S_BUKRS
     INTO TABLE @DATA(LT_VALUE).
  SORT LT_VALUE BY WERKS.
  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'WERKS'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_SPART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_SPART  USING    PV_FNAME.

  SELECT DISTINCT B~SPART,C~VTEXT
    FROM TVKO AS A INNER JOIN TVTA AS B
                   ON A~VKORG = B~VKORG
                   INNER JOIN TSPAT AS C
                   ON B~SPART = C~SPART AND
                      C~SPRAS = @SY-LANGU
   WHERE A~BUKRS IN @S_BUKRS
     INTO TABLE @DATA(LT_VALUE).

  SORT LT_VALUE BY SPART .
  DELETE ADJACENT DUPLICATES FROM LT_VALUE COMPARING SPART.

  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'SPART'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_VALUE
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.
ENDFORM.
