*&---------------------------------------------------------------------*
*&  Include           ZLER0019TOP                                      *
*&---------------------------------------------------------------------*
*
TYPE-POOLS vrm.

TABLES: ZGTMMT4511.

DATA: lt_values  TYPE vrm_values WITH HEADER LINE.
DATA: tt_flag,
      TT_FLAG2,  "자체개선 52275 - 추가
                 "기타통문증발행시 메시지 추가를 위한 FLAG
      ts_iv_type like ZGTMMT4500-iv_type,
      ts_bukrs   like MATDOC-bukrs.

* screen layout
SELECTION-SCREEN: BEGIN OF BLOCK B1 WITH FRAME TITLE T1.
*-{기능개선 48114 - 추가
PARAMETERS      : P_BUKRS   LIKE MATDOC-BUKRS ."OBLIGATORY.
*                            AS LISTBOX VISIBLE LENGTH 14 USER-COMMAND U01.
*} 자체개선 51951 - 추가
*-}기능개선 48114_2014.10.16
PARAMETERS      : P_GUBUN1 LIKE ZGTMMT4511-IV_TYPE AS LISTBOX
                           VISIBLE LENGTH 30. "OBLIGATORY.
                           "DEFAULT '1'.
SELECTION-SCREEN: END OF BLOCK B1.
