*&---------------------------------------------------------------------*
*& Include          ZGTSDR1420SCR
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
  PARAMETERS : P_MODULE LIKE GV_MODULE OBLIGATORY.
  SELECT-OPTIONS : S_VKORG FOR VBAK-VKORG MEMORY ID VKO OBLIGATORY NO INTERVALS
                                                     NO-EXTENSION,  "영업조직
                   S_VTWEG FOR VBAK-VTWEG ,                         "유통경로
                   S_SPART FOR VBAK-SPART,                          "제품군
                   S_REQD  FOR ZGTSDT1410-REQDATE,                  "요청일
                   S_KUNNR FOR VBAK-KUNNR,                          "판매처
                   S_VBELN FOR VBAK-VBELN,                          "판매오더번호
                   S_REQNO FOR ZGTSDT1410-REQNO.                    "요청번호
SELECTION-SCREEN END OF BLOCK B1 .

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-002.
  SELECTION-SCREEN BEGIN OF LINE.
    "전체
    SELECTION-SCREEN POSITION 1.
    PARAMETERS P_RD1 RADIOBUTTON GROUP RD USER-COMMAND RD DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (10) TEXT-R01 FOR FIELD P_RD1.

    "진행중
    SELECTION-SCREEN POSITION 15.
    PARAMETERS P_RD2 RADIOBUTTON GROUP RD .
    SELECTION-SCREEN COMMENT (10) TEXT-R02 FOR FIELD P_RD2.

    "처리완료
    SELECTION-SCREEN POSITION 30.
    PARAMETERS P_RD3 RADIOBUTTON GROUP RD .
    SELECTION-SCREEN COMMENT (10) TEXT-R03 FOR FIELD P_RD3.

  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK B2 .

SELECTION-SCREEN BEGIN OF BLOCK B3 WITH FRAME TITLE TEXT-003.
  PARAMETERS : P_VARI LIKE DISVARIANT-VARIANT.
SELECTION-SCREEN END OF BLOCK B3 .
