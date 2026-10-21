*&---------------------------------------------------------------------*
*& Include          ZGTPPR4130S01
*&---------------------------------------------------------------------*
  SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-T01. "선택옵션
    PARAMETERS: P_WERKS LIKE ZPPT0601-WERKS MEMORY ID WRK. "플랜트
    SELECT-OPTIONS: S_INSMM FOR ZPPT0601-INSMM   "재고실사년월
                            NO-EXTENSION NO INTERVALS,
                    S_LGORT FOR ZPPT0601-LGORT,  "저장위치
                    S_MATNR FOR ZPPT0601-MATNR,  "자재코드
                    S_CHARG FOR ZPPT0601-CHARG,  "배치번호
                    S_TAGNR FOR ZPPT0001-TAGNR.  "꼬리표번호
  SELECTION-SCREEN END OF BLOCK B1.
