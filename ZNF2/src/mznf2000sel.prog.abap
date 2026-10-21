*&---------------------------------------------------------------------*
*&  Include           MZNF2000SEL
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* SELECTION SCREEN
*----------------------------------------------------------------------*

DATA: GV_BUKRS LIKE ZNFT1000-BUKRS,     " 회사코드
      GV_NFCTR LIKE ZNFT1000-NFCTR,     " 사업부
      GV_PRCTR LIKE ZNFT1000-PRCTR,     " 손익센터
      GV_VKGRP LIKE ZNFT1000-VKGRP.     " 영업그룹

DATA: GV_COTYP LIKE ZNFT1000-COTYP,     " 계약유형
      GV_COTXT LIKE ZNFT1000-COTXT,     " 계약명
      GV_KUNNR LIKE ZNFT1000-KUNNR,     " 고객코드
      GV_NCUST LIKE ZNFT1000-NCUST,     " 고객명
      GV_SUJUD LIKE ZNFT1000-SUJUD,     " 수주일
      GV_PRICE LIKE ZNFT1000-PRICE,     " 수주금액
      GV_PRATE LIKE ZNFT1000-PRATE,     " 영업이익률
      GV_SALER LIKE ZNFT1000-SALER,     " 영업담당자
      GV_CONTR LIKE RLGRAP-FILENAME.    " 계약서 또는 발주서
