*&---------------------------------------------------------------------*
*&  Include           ZMMR1360_F02
*&---------------------------------------------------------------------*
*&  공용 Form
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*FORM progress_indicator
*FORM popup_confirm
*FORM popup_message
*FORM conversion_exit_alpha_input
*FORM conversion_exit_alpha_output


*FORM select_domvalue / read_domvalue
*FORM select_comm_code / read_comm_code
*FORM set_table_field / select_field_desc / read_field_desc
*FORM change_cp_patern

*FORM ERROR_MESSAGE_POPUP


FIELD-SYMBOLS : <WA_TAB> TYPE ANY.

"cp_patern
*DATA : GV_CHAR240 LIKE MARA-ZZMAKTX80.

"Domain
DATA : BEGIN OF GT_DD07T OCCURS 0,
         DOMNAME  LIKE DD07T-DOMNAME,
         DOMVALUE LIKE DD07T-DOMVALUE_L,
         DDTEXT   LIKE DD07T-DDTEXT,
       END   OF GT_DD07T.

"자재내역
DATA : BEGIN OF GT_MATNR OCCURS 0,
         MATNR   LIKE MARA-MATNR,
         MAKTX   LIKE MAKT-MAKTX,
       END   OF GT_MATNR.
DATA : GV_MATNR  LIKE GT_MATNR,
       GT_MATNRT LIKE GT_MATNR OCCURS 0 WITH HEADER LINE.
FIELD-SYMBOLS : <FS_MATNR>  TYPE ANY,
                <FS_MATNRT> TYPE ANY,
                <WA_MATNRT> LIKE LINE OF GT_MATNRT.

"자재그룹
DATA : BEGIN OF GT_MATKL OCCURS 0,
         MATKL LIKE MARA-MATKL,
         WGBEZ LIKE T023T-WGBEZ,
       END   OF GT_MATKL.
DATA : GV_MATKL  LIKE GT_MATKL,
       GT_MATKLT LIKE GT_MATKL OCCURS 0 WITH HEADER LINE.
FIELD-SYMBOLS : <FS_MATKL>  TYPE ANY,
                <FS_MATKLT> TYPE ANY,
                <WA_MATKLT> LIKE LINE OF GT_MATKLT.

"용품별그룹
DATA : BEGIN OF GT_PRDHA OCCURS 0,
         PRDHA LIKE MARA-PRDHA,
         VTEXT LIKE T179T-VTEXT,
       END   OF GT_PRDHA.
DATA : GV_PRDHA  LIKE GT_PRDHA,
       GT_PRDHAT LIKE GT_PRDHA OCCURS 0 WITH HEADER LINE.
FIELD-SYMBOLS : <FS_PRDHA>  TYPE ANY,
                <FS_PRDHAT> TYPE ANY,
                <WA_PRDHAT> LIKE LINE OF GT_PRDHAT.

"플랜트
DATA : BEGIN OF GT_WERKS OCCURS 0,
         WERKS LIKE T001W-WERKS,
         NAME1 LIKE T001W-NAME1,
       END   OF GT_WERKS.
DATA : GV_WERKS  LIKE GT_WERKS,
       GT_WERKST LIKE GT_WERKS OCCURS 0 WITH HEADER LINE.
FIELD-SYMBOLS : <FS_WERKS>  TYPE ANY,
                <FS_WERKST> TYPE ANY,
                <WA_WERKST> LIKE LINE OF GT_WERKST.

"저장위치
DATA : BEGIN OF GT_LGORT OCCURS 0,
         WERKS LIKE T001W-WERKS,
         LGORT LIKE T001L-LGORT,
         LGOBE LIKE T001L-LGOBE,
       END   OF GT_LGORT.
DATA : GV_LGORT  LIKE GT_LGORT,
       GT_LGORTT LIKE GT_LGORT OCCURS 0 WITH HEADER LINE.
FIELD-SYMBOLS : <FS_LGORT>  TYPE ANY,
                <FS_LGORTT> TYPE ANY,
                <WA_LGORTT> LIKE LINE OF GT_LGORTT.

"구매조직
DATA : BEGIN OF GT_EKORG OCCURS 0,
         EKORG LIKE T024E-EKORG,
         EKOTX LIKE T024E-EKOTX,
       END   OF GT_EKORG.
DATA : GV_EKORG  LIKE GT_EKORG,
       GT_EKORGT LIKE GT_EKORG OCCURS 0 WITH HEADER LINE.
FIELD-SYMBOLS : <FS_EKORG>  TYPE ANY,
                <FS_EKORGT> TYPE ANY,
                <WA_EKORGT> LIKE LINE OF GT_EKORGT.

"구매그룹
DATA : BEGIN OF GT_EKGRP OCCURS 0,
         EKGRP LIKE T024-EKGRP,
         EKNAM LIKE T024-EKNAM,
       END   OF GT_EKGRP.
DATA : GV_EKGRP  LIKE GT_EKGRP,
       GT_EKGRPT LIKE GT_EKGRP OCCURS 0 WITH HEADER LINE.
FIELD-SYMBOLS : <FS_EKGRP>  TYPE ANY,
                <FS_EKGRPT> TYPE ANY,
                <WA_EKGRPT> LIKE LINE OF GT_EKGRPT.

"오더유형내역
DATA : BEGIN OF GT_AUART OCCURS 0,
         AUART LIKE V_AUART-AUART,
         TXT   LIKE V_AUART-TXT,
       END   OF GT_AUART.
DATA : GV_AUART  LIKE GT_AUART,
       GT_AUARTT LIKE GT_AUART OCCURS 0 WITH HEADER LINE.
FIELD-SYMBOLS : <FS_AUART>  TYPE ANY,
                <FS_AUARTT> TYPE ANY,
                <WA_AUARTT> LIKE LINE OF GT_AUARTT.

"공급업체내역
DATA : BEGIN OF GT_LIFNR OCCURS 0,
         LIFNR LIKE LFA1-LIFNR,
         NAME1 LIKE LFA1-NAME1,
       END   OF GT_LIFNR.
DATA : GV_LIFNR  LIKE GT_LIFNR,
       GT_LIFNRT LIKE GT_LIFNR OCCURS 0 WITH HEADER LINE.
FIELD-SYMBOLS : <FS_LIFNR>  TYPE ANY,
                <FS_LIFNRT> TYPE ANY,
                <WA_LIFNRT> LIKE LINE OF GT_LIFNRT.

"외부자재그룹
DATA : BEGIN OF GT_EXTWG OCCURS 0,
         EXTWG   LIKE MARA-EXTWG,
         EWBEZ LIKE TWEWT-EWBEZ,
       END   OF GT_EXTWG.
DATA : GV_EXTWG  LIKE GT_EXTWG,
       GT_EXTWGT LIKE GT_EXTWG OCCURS 0 WITH HEADER LINE.
FIELD-SYMBOLS : <FS_EXTWG>  TYPE ANY,
                <FS_EXTWGT> TYPE ANY,
                <WA_EXTWGT> LIKE LINE OF GT_EXTWGT.

"구매문서유형 내역
DATA : BEGIN OF GT_BSART OCCURS 0,
         BSART LIKE T161T-BSART,
         BATXT LIKE T161T-BATXT,
       END   OF GT_BSART.

"이동유형 내역
DATA : BEGIN OF GT_BWART OCCURS 0,
         BWART LIKE T156T-BWART,
         BTEXT LIKE T156T-BTEXT,
       END   OF GT_BWART.

*"공급업체 내역
*DATA : BEGIN OF GT_LIFNR OCCURS 0,
*         LIFNR LIKE LFA1-LIFNR,
*         NAME1 LIKE LFA1-NAME1,
*       END   OF GT_LIFNR.

"계정지정범주 내역
DATA : BEGIN OF GT_T163I OCCURS 0,
         KNTTP LIKE T163I-KNTTP,
         KNTTX LIKE T163I-KNTTX,
       END   OF GT_T163I.

"메세지 처리 테이블
DATA: BEGIN OF GT_MSG OCCURS 0,
         MSGID  LIKE SY-MSGID,
         MSGTY  LIKE SY-MSGTY,
         MSGNO  LIKE SY-MSGNO,
         MSGV1  LIKE SY-MSGV1,
         MSGV2  LIKE SY-MSGV2,
         MSGV3  LIKE SY-MSGV3,
         MSGV4  LIKE SY-MSGV4,
         LINENO LIKE MESG-ZEILE,
       END OF GT_MSG.
DATA : GV_LINENO LIKE MESG-ZEILE.

DEFINE %RA_ITAB.
  "RANGE 변수 세팅
  &1-SIGN   = &2.
  &1-OPTION = &3.
  &1-LOW    = &4.
  &1-HIGH   = &5.
  APPEND &1.
  CLEAR: &1.
END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*&      Form  SET_TABLE_FIELD
*&---------------------------------------------------------------------*
* 01. 자재내역     MATNR : MARA-MAKTX
* 02. 자재그룹     MATKL : T023T-WGBEZ
* 03. 용품별그룹   PRDHA : T179T-VTEXT
* 04. 플랜트       WERKS : T001W-NAME1
* 05. 저장위치     LGORT : T001L-LGOBE
* 06. 구매조직     EKORG : T024E-EKOTX
* 07. 구매그룹     EKGRP : T024-EKNAM
* 08. 오더유형내역 AUART : V_AUART-TXT
* 09. 공급업체내역 LIFNR : LFA1-NAME1
* 10. G2B코드내역  ZZG2BCOD : ZTMMY_0310-CODE
* 11. 외부자재그룹 내역  EXTWG : TWEWT-EWBEZ
*----------------------------------------------------------------------*
FORM SET_TABLE_FIELD USING PT_TAB TYPE ANY TABLE.

*--01. 대상 DATA 간추리기
  LOOP AT PT_TAB ASSIGNING <WA_TAB>.
    "자재내역
    ASSIGN COMPONENT 'MATNR' OF STRUCTURE <WA_TAB> TO <FS_MATNR>.
    IF SY-SUBRC = 0.
      GV_MATNR-MATNR = <FS_MATNR>.
      INSERT GV_MATNR INTO TABLE GT_MATNR.
    ENDIF.

    "자재그룹
    ASSIGN COMPONENT 'MATKL' OF STRUCTURE <WA_TAB> TO <FS_MATKL>.
    IF SY-SUBRC = 0.
      GV_MATKL-MATKL = <FS_MATKL>.
      INSERT GV_MATKL INTO TABLE GT_MATKL.
    ENDIF.

    "용품별그룹
    ASSIGN COMPONENT 'PRDHA' OF STRUCTURE <WA_TAB> TO <FS_PRDHA>.
    IF SY-SUBRC = 0.
      GV_PRDHA-PRDHA = <FS_PRDHA>.
      INSERT GV_PRDHA INTO TABLE GT_PRDHA.
    ENDIF.

    "플랜트
    ASSIGN COMPONENT 'WERKS' OF STRUCTURE <WA_TAB> TO <FS_WERKS>.
    IF SY-SUBRC = 0.
      GV_WERKS-WERKS = <FS_WERKS>.
      INSERT GV_WERKS INTO TABLE GT_WERKS.
    ENDIF.

    "저장위치
    ASSIGN COMPONENT 'WERKS' OF STRUCTURE <WA_TAB> TO <FS_WERKS>.
    ASSIGN COMPONENT 'LGORT' OF STRUCTURE <WA_TAB> TO <FS_LGORT>.
    IF SY-SUBRC = 0.
      GV_LGORT-WERKS = <FS_WERKS>.
      GV_LGORT-LGORT = <FS_LGORT>.
      INSERT GV_LGORT INTO TABLE GT_LGORT.
    ENDIF.

    "구매조직
    ASSIGN COMPONENT 'EKORG' OF STRUCTURE <WA_TAB> TO <FS_EKORG>.
    IF SY-SUBRC = 0.
      GV_EKORG-EKORG = <FS_EKORG>.
      INSERT GV_EKORG INTO TABLE GT_EKORG.
    ENDIF.

    "구매그룹
    ASSIGN COMPONENT 'EKGRP' OF STRUCTURE <WA_TAB> TO <FS_EKGRP>.
    IF SY-SUBRC = 0.
      GV_EKGRP-EKGRP = <FS_EKGRP>.
      INSERT GV_EKGRP INTO TABLE GT_EKGRP.
    ENDIF.

    "오더유형내역
    ASSIGN COMPONENT 'AUART' OF STRUCTURE <WA_TAB> TO <FS_AUART>.
    IF SY-SUBRC = 0.
      GV_AUART-AUART = <FS_AUART>.
      INSERT GV_AUART INTO TABLE GT_AUART.
    ENDIF.

    "공급업체내역
    ASSIGN COMPONENT 'LIFNR' OF STRUCTURE <WA_TAB> TO <FS_LIFNR>.
    IF SY-SUBRC = 0.
      GV_LIFNR-LIFNR = <FS_LIFNR>.
      INSERT GV_LIFNR INTO TABLE GT_LIFNR.
    ENDIF.

    "외부자재그룹
    ASSIGN COMPONENT 'EXTWG' OF STRUCTURE <WA_TAB> TO <FS_EXTWG>.
    IF SY-SUBRC = 0.
      GV_EXTWG-EXTWG = <FS_EXTWG>.
      INSERT GV_EXTWG INTO TABLE GT_EXTWG.
    ENDIF.
  ENDLOOP.
ENDFORM.                        "SET_TABLE_FIELD
*&---------------------------------------------------------------------*
*&      Form  SELECT_FIELD_DESC
*&---------------------------------------------------------------------*
* 01. 자재내역    MATNR  : MARA-MAKTX
* 02. 자재그룹    MATKL  : T023T-WGBEZ
* 03. 용품별그룹  PRDHA  : T179T-VTEXT
* 04. 플랜트      WERKS  : T001W-NAME1
* 05. 저장위치    LGORT  : T001L-LGOBE
* 06. 구매조직    EKORG  : T024E-EKOTX
* 07. 구매그룹    EKGRP  : T024-EKNAM
* 08. 오더유형내역 AUART : V_AUART-TXT
* 09. 공급업체내역 LIFNR : LFA1-NAME1
* 10. G2B코드내역  ZZG2BCOD : ZTMMY_0310-CODE
* 11. 외부자재그룹 내역  EXTWG : TWEWT-EWBEZ
*----------------------------------------------------------------------*
FORM SELECT_FIELD_DESC USING PV_FIELD.

*--02. 대상 DATA for all entries

  CASE PV_FIELD.
    WHEN 'MATNR'. "자재내역

      IF GT_MATNR[] IS NOT INITIAL.
        SORT GT_MATNR.
        DELETE ADJACENT DUPLICATES FROM GT_MATNR.

        SELECT MATNR MAKTX
          FROM MAKT
          INTO CORRESPONDING FIELDS OF TABLE GT_MATNRT
          FOR ALL ENTRIES IN GT_MATNR
          WHERE MATNR = GT_MATNR-MATNR
            AND SPRAS EQ SY-LANGU.
      ENDIF.

    WHEN 'MATKL'. "자재그룹

      IF GT_MATKL[] IS NOT INITIAL.
        SORT GT_MATKL.
        DELETE ADJACENT DUPLICATES FROM GT_MATKL.

        SELECT MATKL WGBEZ
          FROM T023T
          INTO CORRESPONDING FIELDS OF TABLE GT_MATKLT
          FOR ALL ENTRIES IN GT_MATKL
          WHERE MATKL = GT_MATKL-MATKL
            AND SPRAS = SY-LANGU.
      ENDIF.


    WHEN 'PRDHA'. "용품별그룹

      IF GT_PRDHA[] IS NOT INITIAL.
        SORT GT_PRDHA.
        DELETE ADJACENT DUPLICATES FROM GT_PRDHA.

        SELECT PRODH AS PRDHA VTEXT
          FROM T179T
          INTO CORRESPONDING FIELDS OF TABLE GT_PRDHAT
          FOR ALL ENTRIES IN GT_PRDHA
          WHERE PRODH = GT_PRDHA-PRDHA
            AND SPRAS = SY-LANGU.
      ENDIF.

    WHEN 'WERKS'. "플랜트

      IF GT_WERKS[] IS NOT INITIAL.
        SORT GT_WERKS.
        DELETE ADJACENT DUPLICATES FROM GT_WERKS.

        SELECT WERKS NAME1
          FROM T001W
          INTO CORRESPONDING FIELDS OF TABLE GT_WERKST
          FOR ALL ENTRIES IN GT_WERKS
          WHERE WERKS = GT_WERKS-WERKS.
      ENDIF.

    WHEN 'LGORT'. "저장위치

      IF GT_LGORT[] IS NOT INITIAL.
        SORT GT_LGORT.
        DELETE ADJACENT DUPLICATES FROM GT_LGORT.

        SELECT WERKS LGORT LGOBE
          FROM T001L
          INTO CORRESPONDING FIELDS OF TABLE GT_LGORTT
          FOR ALL ENTRIES IN GT_LGORT
          WHERE WERKS = GT_LGORT-WERKS
            AND LGORT = GT_LGORT-LGORT.
      ENDIF.

    WHEN 'EKORG'. "구매조직

      IF GT_EKORG[] IS NOT INITIAL.
        SORT GT_EKORG.
        DELETE ADJACENT DUPLICATES FROM GT_EKORG.

        SELECT EKORG EKOTX
          FROM T024E
          INTO CORRESPONDING FIELDS OF TABLE GT_EKORGT
          FOR ALL ENTRIES IN GT_EKORG
          WHERE EKORG = GT_EKORG-EKORG.
      ENDIF.

    WHEN 'EKGRP'. "구매그룹

      IF GT_EKGRP[] IS NOT INITIAL.
        SORT GT_EKGRP.
        DELETE ADJACENT DUPLICATES FROM GT_EKGRP.

        SELECT EKGRP EKNAM
          FROM T024
          INTO CORRESPONDING FIELDS OF TABLE GT_EKGRPT
          FOR ALL ENTRIES IN GT_EKGRP
          WHERE EKGRP = GT_EKGRP-EKGRP.
      ENDIF.

    WHEN 'AUART'. "오더유형내역

      IF GT_AUART[] IS NOT INITIAL.
        SORT GT_AUART.
        DELETE ADJACENT DUPLICATES FROM GT_AUART.

        SELECT AUART TXT
          FROM V_AUART
          INTO CORRESPONDING FIELDS OF TABLE GT_AUARTT
          FOR ALL ENTRIES IN GT_AUART
          WHERE AUART = GT_AUART-AUART
            AND SPRAS = SY-LANGU.
      ENDIF.

    WHEN 'LIFNR'. "공급업체내역

      IF GT_LIFNR[] IS NOT INITIAL.
        SORT GT_LIFNR.
        DELETE ADJACENT DUPLICATES FROM GT_LIFNR.

        SELECT LIFNR NAME1
          FROM LFA1
          INTO CORRESPONDING FIELDS OF TABLE GT_LIFNRT
          FOR ALL ENTRIES IN GT_LIFNR
          WHERE LIFNR = GT_LIFNR-LIFNR.
      ENDIF.

    WHEN 'EXTWG'. "외부자재그룹

      IF GT_EXTWG[] IS NOT INITIAL.
        SORT GT_EXTWG.
        DELETE ADJACENT DUPLICATES FROM GT_EXTWG.

        SELECT EXTWG EWBEZ
          FROM TWEWT
          INTO CORRESPONDING FIELDS OF TABLE GT_EXTWGT
          FOR ALL ENTRIES IN GT_EXTWG
          WHERE EXTWG = GT_EXTWG-EXTWG
            AND SPRAS = SY-LANGU.
      ENDIF.

  ENDCASE.

ENDFORM.                   " SELECT_FIELD_DESC
*&---------------------------------------------------------------------*
*&      Form  READ_FIELD_DESC
*&---------------------------------------------------------------------*
* 01. 자재내역     MATNR : MARA-ZZMAKTX
* 02. 자재그룹     MATKL : T023T-WGBEZ
* 03. 용품별그룹   PRDHA : T179T-VTEXT
* 04. 플랜트       WERKS : T001W-NAME1
* 05. 저장위치     LGORT : T001L-LGOBE
* 06. 구매조직     EKORG : T024E-EKOTX
* 07. 구매그룹     EKGRP : T024-EKNAM
* 08. 오더유형내역 AUART : V_AUART-TXT
* 09. 공급업체내역 LIFNR : LFA1-NAME1
* 10. G2B코드내역  ZZG2BCOD : ZTMMY_0310-CODE
* 11. 외부자재그룹 내역  EXTWG : TWEWT-EWBEZ
*----------------------------------------------------------------------*
FORM READ_FIELD_DESC USING PV_FIELD
                           PV_FIELD_VALUE
                    CHANGING PV_FIELD_NM.

*--03. 대상 READ field name

  CASE PV_FIELD.
    WHEN 'MATNR'. "자재내역

      READ TABLE GT_MATNRT ASSIGNING <WA_MATNRT>
                           WITH KEY MATNR = PV_FIELD_VALUE.
      IF SY-SUBRC = 0.
        PV_FIELD_NM = <WA_MATNRT>-MAKTX.
      ENDIF.

    WHEN 'MATKL'. "자재그룹

      READ TABLE GT_MATKLT ASSIGNING <WA_MATKLT>
                           WITH KEY MATKL = PV_FIELD_VALUE.
      IF SY-SUBRC = 0.
        PV_FIELD_NM = <WA_MATKLT>-WGBEZ.
      ENDIF.

    WHEN 'PRDHA'. "용품별그룹

      READ TABLE GT_PRDHAT ASSIGNING <WA_PRDHAT>
                           WITH KEY PRDHA = PV_FIELD_VALUE.
      IF SY-SUBRC = 0.
        PV_FIELD_NM = <WA_PRDHAT>-VTEXT.
      ENDIF.

    WHEN 'WERKS'. "플랜트

      READ TABLE GT_WERKST ASSIGNING <WA_WERKST>
                           WITH KEY WERKS = PV_FIELD_VALUE.
      IF SY-SUBRC = 0.
        PV_FIELD_NM = <WA_WERKST>-NAME1.
      ENDIF.

    WHEN 'LGORT'. "저장위치

      READ TABLE GT_LGORTT ASSIGNING <WA_LGORTT>
                           WITH KEY LGORT = PV_FIELD_VALUE.
      IF SY-SUBRC = 0.
        PV_FIELD_NM = <WA_LGORTT>-LGOBE.
      ENDIF.

    WHEN 'EKORG'. "구매조직

      READ TABLE GT_EKORGT ASSIGNING <WA_EKORGT>
                           WITH KEY EKORG = PV_FIELD_VALUE.
      IF SY-SUBRC = 0.
        PV_FIELD_NM = <WA_EKORGT>-EKOTX.
      ENDIF.

    WHEN 'EKGRP'. "구매그룹

      READ TABLE GT_EKGRPT ASSIGNING <WA_EKGRPT>
                           WITH KEY EKGRP = PV_FIELD_VALUE.
      IF SY-SUBRC = 0.
        PV_FIELD_NM = <WA_EKGRPT>-EKNAM.
      ENDIF.

    WHEN 'AUART'. "오더유형내역

      READ TABLE GT_AUARTT ASSIGNING <WA_AUARTT>
                           WITH KEY AUART = PV_FIELD_VALUE.
      IF SY-SUBRC = 0.
        PV_FIELD_NM = <WA_AUARTT>-TXT.
      ENDIF.

    WHEN 'LIFNR'. "공급업체내역

      READ TABLE GT_LIFNRT ASSIGNING <WA_LIFNRT>
                           WITH KEY LIFNR = PV_FIELD_VALUE.
      IF SY-SUBRC = 0.
        PV_FIELD_NM = <WA_LIFNRT>-NAME1.
      ENDIF.

  ENDCASE.

ENDFORM.                    " READ_FIELD_DESC

*&---------------------------------------------------------------------*
*&      Form  GET_FIELD_DESC
*&---------------------------------------------------------------------*
* 01. 자재내역     MATNR : MARA-ZZMAKTX
* 02. 자재그룹     MATKL : T023T-WGBEZ
* 03. 용품별그룹   PRDHA : T179T-VTEXT
* 04. 플랜트       WERKS : T001W-NAME1
* 05. 저장위치     LGORT : T001L-LGOBE
* 06. 구매조직     EKORG : T024E-EKOTX
* 07. 구매그룹     EKGRP : T024-EKNAM
* 08. 오더유형내역 AUART : V_AUART-TXT
* 09. 공급업체내역 LIFNR : LFA1-NAME1
* 10. G2B코드내역  ZZG2BCOD : ZTMMY_0310-CODE
*----------------------------------------------------------------------*
FORM GET_FIELD_DESC  USING PT_TAB TYPE ANY TABLE.

*--01. 대상 DATA 간추리기
  LOOP AT PT_TAB ASSIGNING <WA_TAB>.
    "자재내역
    ASSIGN COMPONENT 'MATNR' OF STRUCTURE <WA_TAB> TO <FS_MATNR>.
    IF SY-SUBRC = 0.
      GV_MATNR-MATNR = <FS_MATNR>.
      INSERT GV_MATNR INTO TABLE GT_MATNR.
    ENDIF.

    "자재그룹
    ASSIGN COMPONENT 'MATKL' OF STRUCTURE <WA_TAB> TO <FS_MATKL>.
    IF SY-SUBRC = 0.
      GV_MATKL-MATKL = <FS_MATKL>.
      INSERT GV_MATKL INTO TABLE GT_MATKL.
    ENDIF.

    "용품별그룹
    ASSIGN COMPONENT 'PRDHA' OF STRUCTURE <WA_TAB> TO <FS_PRDHA>.
    IF SY-SUBRC = 0.
      GV_PRDHA-PRDHA = <FS_PRDHA>.
      INSERT GV_PRDHA INTO TABLE GT_PRDHA.
    ENDIF.

    "플랜트
    ASSIGN COMPONENT 'WERKS' OF STRUCTURE <WA_TAB> TO <FS_WERKS>.
    IF SY-SUBRC = 0.
      GV_WERKS-WERKS = <FS_WERKS>.
      INSERT GV_WERKS INTO TABLE GT_WERKS.
    ENDIF.

    "저장위치
    ASSIGN COMPONENT 'WERKS' OF STRUCTURE <WA_TAB> TO <FS_WERKS>.
    ASSIGN COMPONENT 'LGORT' OF STRUCTURE <WA_TAB> TO <FS_LGORT>.
    IF SY-SUBRC = 0.
      GV_LGORT-WERKS = <FS_WERKS>.
      GV_LGORT-LGORT = <FS_LGORT>.
      INSERT GV_LGORT INTO TABLE GT_LGORT.
    ENDIF.

    "구매조직
    ASSIGN COMPONENT 'EKORG' OF STRUCTURE <WA_TAB> TO <FS_EKORG>.
    IF SY-SUBRC = 0.
      GV_EKORG-EKORG = <FS_EKORG>.
      INSERT GV_EKORG INTO TABLE GT_EKORG.
    ENDIF.

    "구매그룹
    ASSIGN COMPONENT 'EKGRP' OF STRUCTURE <WA_TAB> TO <FS_EKGRP>.
    IF SY-SUBRC = 0.
      GV_EKGRP-EKGRP = <FS_EKGRP>.
      INSERT GV_EKGRP INTO TABLE GT_EKGRP.
    ENDIF.

    "오더유형내역
    ASSIGN COMPONENT 'AUART' OF STRUCTURE <WA_TAB> TO <FS_AUART>.
    IF SY-SUBRC = 0.
      GV_AUART-AUART = <FS_AUART>.
      INSERT GV_AUART INTO TABLE GT_AUART.
    ENDIF.

    "공급업체내역
    ASSIGN COMPONENT 'LIFNR' OF STRUCTURE <WA_TAB> TO <FS_LIFNR>.
    IF SY-SUBRC = 0.
      GV_LIFNR-LIFNR = <FS_LIFNR>.
      INSERT GV_LIFNR INTO TABLE GT_LIFNR.
    ENDIF.
  ENDLOOP.

*--02. 대상 DATA for all entries
  "자재내역
  IF GT_MATNR[] IS NOT INITIAL.
    SORT GT_MATNR.
    DELETE ADJACENT DUPLICATES FROM GT_MATNR.

    SELECT MATNR MAKTX
      FROM MAKT
      INTO CORRESPONDING FIELDS OF TABLE GT_MATNRT
      FOR ALL ENTRIES IN GT_MATNR
      WHERE MATNR = GT_MATNR-MATNR
       AND SPRAS  = SY-LANGU.
  ENDIF.

  "자재그룹
  IF GT_MATKL[] IS NOT INITIAL.
    SORT GT_MATKL.
    DELETE ADJACENT DUPLICATES FROM GT_MATKL.

    SELECT MATKL WGBEZ
      FROM T023T
      INTO CORRESPONDING FIELDS OF TABLE GT_MATKLT
      FOR ALL ENTRIES IN GT_MATKL
      WHERE MATKL = GT_MATKL-MATKL
        AND SPRAS = SY-LANGU.
  ENDIF.

  "용품별그룹
  IF GT_PRDHA[] IS NOT INITIAL.
    SORT GT_PRDHA.
    DELETE ADJACENT DUPLICATES FROM GT_PRDHA.

    SELECT PRODH AS PRDHA VTEXT
      FROM T179T
      INTO CORRESPONDING FIELDS OF TABLE GT_PRDHAT
      FOR ALL ENTRIES IN GT_PRDHA
      WHERE PRODH = GT_PRDHA-PRDHA
        AND SPRAS = SY-LANGU.
  ENDIF.

  "플랜트
  IF GT_WERKS[] IS NOT INITIAL.
    SORT GT_WERKS.
    DELETE ADJACENT DUPLICATES FROM GT_WERKS.

    SELECT WERKS NAME1
      FROM T001W
      INTO CORRESPONDING FIELDS OF TABLE GT_WERKST
      FOR ALL ENTRIES IN GT_WERKS
      WHERE WERKS = GT_WERKS-WERKS.
  ENDIF.

  "저장위치
  IF GT_LGORT[] IS NOT INITIAL.
    SORT GT_LGORT.
    DELETE ADJACENT DUPLICATES FROM GT_LGORT.

    SELECT LGORT LGOBE
      FROM T001L
      INTO CORRESPONDING FIELDS OF TABLE GT_LGORTT
      FOR ALL ENTRIES IN GT_LGORT
      WHERE WERKS = GT_LGORT-WERKS
        AND LGORT = GT_LGORT-LGORT.
  ENDIF.

  "구매조직
  IF GT_EKORG[] IS NOT INITIAL.
    SORT GT_EKORG.
    DELETE ADJACENT DUPLICATES FROM GT_EKORG.

    SELECT EKORG EKOTX
      FROM T024E
      INTO CORRESPONDING FIELDS OF TABLE GT_EKORGT
      FOR ALL ENTRIES IN GT_EKORG
      WHERE EKORG = GT_EKORG-EKORG.
  ENDIF.

  "구매그룹
  IF GT_EKGRP[] IS NOT INITIAL.
    SORT GT_EKGRP.
    DELETE ADJACENT DUPLICATES FROM GT_EKGRP.

    SELECT EKGRP EKNAM
      FROM T024
      INTO CORRESPONDING FIELDS OF TABLE GT_EKGRPT
      FOR ALL ENTRIES IN GT_EKGRP
      WHERE EKGRP = GT_EKGRP-EKGRP.
  ENDIF.

  "오더유형내역
  IF GT_AUART[] IS NOT INITIAL.
    SORT GT_AUART.
    DELETE ADJACENT DUPLICATES FROM GT_AUART.

    SELECT AUART TXT
      FROM V_AUART
      INTO CORRESPONDING FIELDS OF TABLE GT_AUARTT
      FOR ALL ENTRIES IN GT_AUART
      WHERE AUART = GT_AUART-AUART
        AND SPRAS = SY-LANGU.
  ENDIF.

  "공급업체내역
  IF GT_LIFNR[] IS NOT INITIAL.
    SORT GT_LIFNR.
    DELETE ADJACENT DUPLICATES FROM GT_LIFNR.

    SELECT LIFNR NAME1
      FROM LFA1
      INTO CORRESPONDING FIELDS OF TABLE GT_LIFNRT
      FOR ALL ENTRIES IN GT_LIFNR
      WHERE LIFNR = GT_LIFNR-LIFNR.
  ENDIF.

*--03. DATA Modify
  LOOP AT PT_TAB ASSIGNING <WA_TAB>.
    "내역 필드 ASSIGN
    "자재 내역
    ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <WA_TAB> TO <FS_MATNRT>.
    "자재그룹 내역
    ASSIGN COMPONENT 'WGBEZ' OF STRUCTURE <WA_TAB> TO <FS_MATKLT>.
    "용품별 내역
    ASSIGN COMPONENT 'VTEXT' OF STRUCTURE <WA_TAB> TO <FS_PRDHAT>.
    "플랜트 내역
    ASSIGN COMPONENT 'NAME1' OF STRUCTURE <WA_TAB> TO <FS_WERKST>.
    "저장위치 내역
    ASSIGN COMPONENT 'LGOBE' OF STRUCTURE <WA_TAB> TO <FS_LGORTT>.
    "구매조직 내역
    ASSIGN COMPONENT 'EKOTX' OF STRUCTURE <WA_TAB> TO <FS_EKORGT>.
    "구매그룹 내역
    ASSIGN COMPONENT 'EKNAM' OF STRUCTURE <WA_TAB> TO <FS_EKGRPT>.
    "오더유형 내역
    ASSIGN COMPONENT 'TXT' OF STRUCTURE <WA_TAB> TO <FS_AUARTT>.
    "공급업체 내역
    ASSIGN COMPONENT 'NAME1' OF STRUCTURE <WA_TAB> TO <FS_LIFNRT>.

    "필드 ASSIGN
    "자재번호
    ASSIGN COMPONENT 'MATNR' OF STRUCTURE <WA_TAB> TO <FS_MATNR>.
    "자재그룹
    ASSIGN COMPONENT 'MATKL' OF STRUCTURE <WA_TAB> TO <FS_MATKL>.
    "용품별
    ASSIGN COMPONENT 'PRDHA' OF STRUCTURE <WA_TAB> TO <FS_PRDHA>.
    "플랜트
    ASSIGN COMPONENT 'WERKS' OF STRUCTURE <WA_TAB> TO <FS_WERKS>.
    "저장위치
    ASSIGN COMPONENT 'LGORT' OF STRUCTURE <WA_TAB> TO <FS_LGORT>.
    "구매조직
    ASSIGN COMPONENT 'EKORG' OF STRUCTURE <WA_TAB> TO <FS_EKORG>.
    "구매그룹
    ASSIGN COMPONENT 'EKGRP' OF STRUCTURE <WA_TAB> TO <FS_EKGRP>.
    "오더유형
    ASSIGN COMPONENT 'AUART' OF STRUCTURE <WA_TAB> TO <FS_AUART>.
    "공급업체
    ASSIGN COMPONENT 'LIFNR' OF STRUCTURE <WA_TAB> TO <FS_LIFNR>.

    "자재 내역
    READ TABLE GT_MATNRT ASSIGNING <WA_MATNRT>
                         WITH KEY MATNR = <FS_MATNR>.
    IF SY-SUBRC = 0.
      <FS_MATNRT> = <WA_MATNRT>-MAKTX.
    ENDIF.

    "자재그룹 내역
    READ TABLE GT_MATKLT ASSIGNING <WA_MATKLT>
                         WITH KEY MATKL = <FS_MATKL>.
    IF SY-SUBRC = 0.
      <FS_MATKLT> = <WA_MATKLT>-WGBEZ.
    ENDIF.


    "용품별그룹 내역
    READ TABLE GT_PRDHAT ASSIGNING <WA_PRDHAT>
                         WITH KEY PRDHA = <FS_PRDHA>.
    IF SY-SUBRC = 0.
      <FS_PRDHAT> = <WA_PRDHAT>-VTEXT.
    ENDIF.

    "플랜트 내역
    READ TABLE GT_WERKST ASSIGNING <WA_WERKST>
                         WITH KEY WERKS = <FS_WERKS>.
    IF SY-SUBRC = 0.
      <FS_WERKST> = <WA_WERKST>-NAME1.
    ENDIF.

    "저장위치 내역
    READ TABLE GT_LGORTT ASSIGNING <WA_LGORTT>
                         WITH KEY LGORT = <FS_LGORT>.
    IF SY-SUBRC = 0.
      <FS_LGORTT> = <WA_LGORTT>-LGOBE.
    ENDIF.

    "구매조직 내역
    READ TABLE GT_EKORGT ASSIGNING <WA_EKORGT>
                         WITH KEY EKORG = <FS_EKORG>.
    IF SY-SUBRC = 0.
      <FS_EKORGT> = <WA_EKORGT>-EKOTX.
    ENDIF.

    "구매그룹 내역
    READ TABLE GT_EKGRPT ASSIGNING <WA_EKGRPT>
                         WITH KEY EKGRP = <FS_EKGRP>.
    IF SY-SUBRC = 0.
      <FS_EKGRPT> = <WA_EKGRPT>-EKNAM.
    ENDIF.

    "오더유형 내역
    READ TABLE GT_AUARTT ASSIGNING <WA_AUARTT>
                         WITH KEY AUART = <FS_AUART>.
    IF SY-SUBRC = 0.
      <FS_AUARTT> = <WA_AUARTT>-TXT.
    ENDIF.

    "공급업체 내역
    READ TABLE GT_LIFNRT ASSIGNING <WA_LIFNRT>
                         WITH KEY LIFNR = <FS_LIFNR>.
    IF SY-SUBRC = 0.
      <FS_LIFNRT> = <WA_LIFNRT>-NAME1.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "GET_FIELD_DESC

*&---------------------------------------------------------------------*
*&      Form  PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_TEXT  text
*----------------------------------------------------------------------*
FORM PROGRESS_INDICATOR  USING    PV_TEXT
                                  PV_PERCENTAGE.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      PERCENTAGE = PV_PERCENTAGE
      TEXT       = PV_TEXT.

ENDFORM.                    " PROGRESS_INDICATOR

*&---------------------------------------------------------------------*
*&      Form  POPUP_CONFIRM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM POPUP_CONFIRM  USING    PV_TEXT_M01
                             PV_TEXT_M02
                    CHANGING PV_RESULT.

  CLEAR PV_RESULT.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR       = PV_TEXT_M01
      TEXT_QUESTION  = PV_TEXT_M02
      DEFAULT_BUTTON = '1'
    IMPORTING
      ANSWER         = PV_RESULT
    EXCEPTIONS
      TEXT_NOT_FOUND = 1
      OTHERS         = 2.

ENDFORM.                    " POPUP_CONFIRM

*&---------------------------------------------------------------------*
*&      Form  POPUP_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM POPUP_MESSAGE USING    PV_TITLE
                             PV_LINE1
                             PV_DEFAULT
                             PV_CANCEL
                    CHANGING PV_ANSWER.

  CLEAR PV_ANSWER.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = PV_TITLE
      TEXT_QUESTION         = PV_LINE1
      TEXT_BUTTON_1         = '예'
      TEXT_BUTTON_2         = '아니오'
      DEFAULT_BUTTON        = PV_DEFAULT     " 1:예, 2:아니오, A:취소
      DISPLAY_CANCEL_BUTTON = PV_CANCEL      " 1:예, 2:아니오
    IMPORTING
      ANSWER                = PV_ANSWER
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.

  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.                    " POPUP_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  CONVERSION_EXIT_ALPHA_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CONVERSION_EXIT_ALPHA_INPUT  CHANGING PV_VAL.

  CHECK PV_VAL IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = PV_VAL
    IMPORTING
      OUTPUT = PV_VAL.

ENDFORM.                    " CONVERSION_EXIT_ALPHA_INPUT

*&---------------------------------------------------------------------*
*&      Form  CONVERSION_EXIT_ALPHA_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CONVERSION_EXIT_ALPHA_OUTPUT  CHANGING PV_VAL.

  CHECK PV_VAL IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = PV_VAL
    IMPORTING
      OUTPUT = PV_VAL.

ENDFORM.                    " CONVERSION_EXIT_ALPHA_OUTPUT


*&---------------------------------------------------------------------*
*&      Form  CONVERSION_EXIT_ALPHA_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CONVERSION_EXIT_MATN1_INPUT  CHANGING PV_VAL.

  CHECK PV_VAL IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT  = PV_VAL
    IMPORTING
      OUTPUT = PV_VAL.

ENDFORM.                    " CONVERSION_EXIT_ALPHA_INPUT

*&---------------------------------------------------------------------*
*&      Form  CONVERSION_EXIT_ALPHA_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CONVERSION_EXIT_MATN1_OUTPUT  CHANGING PV_VAL.

  CHECK PV_VAL IS NOT INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
    EXPORTING
      INPUT  = PV_VAL
    IMPORTING
      OUTPUT = PV_VAL.

ENDFORM.                    " CONVERSION_EXIT_ALPHA_OUTPUT



*&---------------------------------------------------------------------*
*&      Form  SELECT_DOMVALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SELECT_DOMVALUE USING PV_DOMNAME.

*  Domain 고정값
*  여러번 호출가능 하기 때문에 appending 함.
  SELECT DOMNAME DOMVALUE_L DDTEXT
    APPENDING TABLE GT_DD07T
    FROM DD07T
   WHERE DOMNAME = PV_DOMNAME
     AND DDLANGUAGE = SY-LANGU.

  SORT GT_DD07T BY DOMNAME DOMVALUE.

ENDFORM.                    " SELECT_DOMVALUE

*&---------------------------------------------------------------------*
*&      Form  READ_DOMVALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM READ_DOMVALUE  USING  PV_DOMNAME
                           PV_DOMVALUE
                    CHANGING PV_DOMVALUE_NM.

  CLEAR : GT_DD07T, PV_DOMVALUE_NM.

  READ TABLE GT_DD07T WITH KEY DOMNAME  = PV_DOMNAME
                               DOMVALUE = PV_DOMVALUE
                               BINARY SEARCH.
  CHECK SY-SUBRC = 0.

  PV_DOMVALUE_NM = GT_DD07T-DDTEXT.

ENDFORM.                    " READ_DOMVALUE
**&---------------------------------------------------------------------
**&      Form  CHANGE_CP_PATERN
**&---------------------------------------------------------------------
**       text
**----------------------------------------------------------------------
*
*FORM CHANGE_CP_PATERN TABLES PT_RANGES STRUCTURE ZSMME9000
*                      USING  PV_PATERN.
*
*  CLEAR : GV_CHAR240.
*  SHIFT PV_PATERN LEFT DELETING LEADING SPACE.
*  GV_CHAR240 = PV_PATERN.
*  PERFORM CONVERSION_EXIT_ALPHA_OUTPUT USING GV_CHAR240.
*
*  PT_RANGES(3) = 'ICP'.
*  CONCATENATE '*'GV_CHAR240'*' INTO PT_RANGES-LOW.
*  APPEND PT_RANGES. CLEAR PT_RANGES.
*
*ENDFORM.                    " CHANGE_CP_PATERN
*&---------------------------------------------------------------------*
*&      Form  ERROR_MESSAGE_POPUP
*&---------------------------------------------------------------------*
*       에러 메세지 팝업
*----------------------------------------------------------------------*
FORM ERROR_MESSAGE_POPUP .

  CHECK GT_MSG[] IS NOT INITIAL.

  CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
    TABLES
      I_MESSAGE_TAB = GT_MSG[].

ENDFORM.                    "ERROR_MESSAGE_POPUP
