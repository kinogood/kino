*&---------------------------------------------------------------------*
*& Include          ZGTSDR1185SEL
*&---------------------------------------------------------------------*
*--------------------------------------------------------------------*
*   SELECTION SCREEN                                                 *
*--------------------------------------------------------------------*

*- 전송옵션
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-s01.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 1.
    PARAMETERS: p_opt3  RADIOBUTTON GROUP rad2.
    SELECTION-SCREEN COMMENT 3(10) TEXT-p05 FOR FIELD p_opt3.

    SELECTION-SCREEN POSITION 21.
    PARAMETERS: p_opt1  RADIOBUTTON GROUP rad2.
    SELECTION-SCREEN COMMENT 23(10) TEXT-p03 FOR FIELD p_opt1.

    SELECTION-SCREEN POSITION 41.
    PARAMETERS: p_opt2  RADIOBUTTON GROUP rad2.
    SELECTION-SCREEN COMMENT 43(10) TEXT-p04 FOR FIELD p_opt2.

    SELECTION-SCREEN POSITION 61.
    PARAMETERS: p_opt4  RADIOBUTTON GROUP rad2.
    SELECTION-SCREEN COMMENT 63(10) TEXT-p06 FOR FIELD p_opt4.

  SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END OF BLOCK b2.

*- 선택옵션
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_bukrs LIKE t001cm-bukrs   OBLIGATORY
                                          MEMORY ID buk.  "회사코드

  SELECT-OPTIONS:
                  s_kunnr FOR vbak-kunnr                ,     "고객
                  s_bupla FOR j_1bt001wv-j_1bbranch
                              MATCHCODE OBJECT ztr_bupla,     "사업장
                  s_vbeln FOR lips-vbeln                ,     "납품번호
                  s_seqno FOR zsdt0010-erdat            ,     "일련번호
                  s_wadat FOR likp-wadat_ist OBLIGATORY ,     "GI 일자
                  s_gubun FOR zsdt0010-gubun,                   "담보구분
                  s_dambg FOR zsdt0001-damb_gubn.               "보증유형

  SELECTION-SCREEN SKIP 1.
  PARAMETERS: p_ex_215   AS CHECKBOX .   "취소된건 제외
SELECTION-SCREEN END OF BLOCK b3.
