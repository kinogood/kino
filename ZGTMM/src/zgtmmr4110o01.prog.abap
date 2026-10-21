*&---------------------------------------------------------------------*
*& Include          ZGTMMR4110O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module PBO_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE PBO_0100 OUTPUT.

  IF GR_HDOCK IS NOT BOUND.
    PERFORM SET_GUI.

    SET PF-STATUS '0100' EXCLUDING GT_EXCD.
    SET TITLEBAR  '0100' WITH GV_TITLE.

    PERFORM SET_OBJ.

    PERFORM SET_EXCL TABLES GT_HEXCL.
    PERFORM SET_LAYO  USING GS_HLAYO 'H'.
    PERFORM SET_EVNT  USING GR_HGRID 'GR_HGRID'.

    PERFORM SET_EXCL TABLES GT_IEXCL.
    PERFORM SET_LAYO  USING GS_ILAYO 'I'.
    PERFORM SET_EVNT  USING GR_IGRID 'GR_IGRID'.

    PERFORM SET_TTIP.

    CASE 'X'.
      WHEN P_GOP.
        PERFORM SET_FCAT_DISP TABLES GT_HGOP
                                     GT_IGOP.
      WHEN P_GOD.
        PERFORM SET_FCAT_DISP TABLES GT_HGOD
                                     GT_IGOD.
      WHEN P_APM.
        PERFORM SET_FCAT_DISP TABLES GT_HAPM
                                     GT_IAPX.
      WHEN P_APD.
        PERFORM SET_FCAT_DISP TABLES GT_HAPD
                                     GT_IAPX.
    ENDCASE.
  ELSE.
    CHECK GV_REF = GC_X.
    PERFORM REFRESH_GRID USING GR_HGRID
                               GS_HLAYO.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module PBO_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE PBO_0200 OUTPUT.

  SET PF-STATUS '0200'.
  SET TITLEBAR  '0200'.

  IF GR_PCUST IS NOT BOUND.
    PERFORM SET_OBJ.

    PERFORM SET_EXCL TABLES GT_IEXCL.
    PERFORM SET_LAYO  USING GS_PLAYO 'P'.
    PERFORM SET_EVNT  USING GR_PGRID 'GR_PGRID'.

    PERFORM SET_FCAT TABLES GT_PFCAT
                      USING 'P'.
    PERFORM SET_DISP TABLES GT_IEXCL
                            GT_PFCAT
                            GT_BGOP
                      USING GR_PGRID
                            GS_PLAYO 'P'.
  ELSE.
    PERFORM REFRESH_GRID USING GR_PGRID
                               GS_PLAYO.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module PBO_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE PBO_0400 OUTPUT.

  SET PF-STATUS '0200'.
  SET TITLEBAR  '0400'.

  IF GR_MDOCK IS NOT BOUND.
    PERFORM SET_OBJ.

    PERFORM SET_EXCL TABLES GT_IEXCL.
    PERFORM SET_LAYO  USING GS_MLAYO 'M'.
    PERFORM SET_EVNT  USING GR_MGRID 'GR_MGRID'.

    PERFORM SET_FCAT TABLES GT_MFCAT
                      USING 'M'.
    PERFORM SET_DISP TABLES GT_IEXCL
                            GT_MFCAT
                            GT_MGOP
                      USING GR_MGRID
                            GS_MLAYO 'M'.
  ELSE.
    PERFORM REFRESH_GRID USING GR_MGRID
                               GS_MLAYO.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module PBO_0500 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE PBO_0500 OUTPUT.

  PERFORM SET_GUI.

  SET PF-STATUS '0500' EXCLUDING GT_EXCD.
  SET TITLEBAR  '0500' WITH GV_TITLE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module MODIFY_SCREEN OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE MODIFY_SCREEN OUTPUT.

  DATA : LV_TXT(50),
         LV_TXT1(50),
         LV_TXT2(50),
         LV_TXT3(50),
         LV_TXT4(50),
         LV_TXT5(50),
         LV_TXT6(50),
         LV_TXT7(50),
         LV_TXT8(50).

  CLEAR : GS_PRXX-TXT01, GS_PRXX-TXT02, GS_PRXX-TXT03.

*--> [CHM2603-00086] 사급자재 불출금액 및 담보초과금액 계산
  DATA : LV_CNT TYPE I. " 연간 초과불출횟수
  DATA : LV_CNT_C(10).  " 연간 초과불출횟수

  DATA : LV_OVVAL LIKE ZGTMMT4110-PREIS.  " 사급자재 불출금액
  DATA : LV_GAP LIKE ZGTMMT4110-PREIS.    " 담보초과금액 = 사급자재 불출금액 - 보증(담보)금액

  DATA : LV_PREIS_C(20). " 보증(담보)금액
  DATA : LV_OVVAL_C(20). " 사급자재 불출금액
  DATA : LV_GAP_C(20).   " 담보초과금액

  PERFORM OVER_SET_VALUES CHANGING  LV_OVVAL
                                    LV_GAP
                                    LV_CNT.

  WRITE GS_HDR-PREIS TO LV_PREIS_C CURRENCY GS_HDR-WAERS.
  CONDENSE LV_PREIS_C NO-GAPS.

  WRITE LV_OVVAL TO LV_OVVAL_C CURRENCY GS_HDR-WAERS.
  CONDENSE LV_OVVAL_C NO-GAPS.

  WRITE LV_GAP TO LV_GAP_C CURRENCY GS_HDR-WAERS.
  CONDENSE LV_GAP_C NO-GAPS.

  LV_CNT_C = LV_CNT.
  CONDENSE LV_CNT_C NO-GAPS.
*<-- [CHM2603-00086] 사급자재 불출금액 및 담보초과금액 계산

  CASE GV_PRXX.
    WHEN 'POD'.
      GS_PRXX-TXT01 = '출하지시를 생성하시겠습니까?'(M18).
    WHEN 'PGI'.
      GS_PRXX-TXT01 = '출고처리 하시겠습니까?'(M19).
*    WHEN 'MGI'.
*      OR 'MOD'. "위치 변경(SJM 25.06.11)
*      GS_PRXX-TXT01 = '출고 진행 수량이 가용 금액을 초과했습니다.'(M20).
*      GS_PRXX-TXT02 = '출고 사유를 등록하여 내부 승인 후 출고 가능합니다.'(M21).
*      GS_PRXX-TXT03 = '계속 진행하시겠습니까?'(M22).
*--> [CHM2603-00086] 외주 초과불출 문구 수정
    WHEN 'MGI' OR 'MOD'.
      GS_PRXX-TXT01 = '사급자재 불출금액이 보증금액을 초과하였습니다.'.

      LV_TXT1 = '담보금액 :'.
      LV_TXT2 = LV_PREIS_C.
      LV_TXT3 = '사급자재 불출금액 :'.
      LV_TXT4 = LV_OVVAL_C.
      CONCATENATE '-' LV_TXT1 LV_TXT2 '/' LV_TXT3 LV_TXT4 INTO GS_PRXX-TXT02 SEPARATED BY SPACE.

      LV_TXT5 = '담보초과금액 :'.
      LV_TXT6 = LV_GAP_C.
      LV_TXT7 = '연간 초과불출횟수 :'.
      LV_TXT8 = LV_CNT_C.
      CONCATENATE '-' LV_TXT5 LV_TXT6 '/' LV_TXT7 LV_TXT8 INTO GS_PRXX-TXT03 SEPARATED BY SPACE.

      GS_PRXX-TXT04 = '미회수 리스크가 높아 출고사유 등록 및 내부승인 후 출고가 가능합니다.'.
      GS_PRXX-TXT05 = '계속 진행하시겠습니까?'.
*<-- [CHM2603-00086] 외주 초과불출 문구 수정
    WHEN 'CGI'.
      GS_PRXX-TXT01 = '출고 취소 처리 하시겠습니까?'(M23).
    WHEN 'APV'.
      GS_PRXX-TXT01 = '불출 요청을 승인하시겠습니까?'(M24).
    WHEN 'REJ'.
      GS_PRXX-TXT01 = '반려 처리 하시겠습니까?'(M25).
    WHEN 'CAP'.
      GS_PRXX-TXT01 = '품의 취소시 출고 처리를 다시 해야 합니다. 취소 하시겠습니까?'(M26).
  ENDCASE.


  LOOP AT SCREEN.
    CASE GV_PRXX.
      WHEN 'APV' OR 'CAP'. "위치 변경(SJM 25.06.11) 'POD' OR 'MOD' OR
        IF SCREEN-GROUP1 = GC_PGI
        OR SCREEN-GROUP1 = GC_MGI
        OR SCREEN-GROUP1 = GC_REJ
        OR SCREEN-GROUP1 = GC_CGI.
          SCREEN-ACTIVE = GC_0.
          MODIFY SCREEN.
        ENDIF.

      WHEN 'PGI'
        OR 'POD'. "위치 변경(SJM 25.06.11)
        IF SCREEN-GROUP1 = GC_MGI
        OR SCREEN-GROUP1 = GC_REJ.
          SCREEN-ACTIVE = GC_0.
          MODIFY SCREEN.
        ENDIF.

*      WHEN 'MGI'.
*        OR 'MOD'. "위치 변경(SJM 25.06.11)
*        IF SCREEN-GROUP1 = GC_PGI
*        OR SCREEN-GROUP1 = GC_REJ.
*          SCREEN-ACTIVE = GC_0.
*          MODIFY SCREEN.
*        ENDIF.

*--> [CHM2603-00086] 외주 초과불출 문구 수정
      WHEN 'MGI' OR 'MOD'.
        IF SCREEN-GROUP1 = GC_PGI
        OR SCREEN-GROUP1 = GC_REJ.
          SCREEN-ACTIVE = GC_0.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-GROUP1 = GC_MGI.
          SCREEN-INTENSIFIED = '1'.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = '%#AUTOTEXT003'.
          SCREEN-INTENSIFIED = '0'.
          MODIFY SCREEN.
        ENDIF.

        IF SCREEN-NAME = 'GS_PRXX-TXT04'.
          SCREEN-INTENSIFIED = '1'.
          MODIFY SCREEN.
        ENDIF.
*<-- [CHM2603-00086] 외주 초과불출 문구 수정

*      WHEN 'MGI'
*        OR 'MOD'. "위치 변경(SJM 25.06.11)
*        IF SCREEN-GROUP1 = GC_PGI
*        OR SCREEN-GROUP1 = GC_REJ.
*          SCREEN-ACTIVE = GC_0.
*          MODIFY SCREEN.
*        ENDIF.

      WHEN 'CGI'.
        IF SCREEN-GROUP1 = GC_MGI
        OR SCREEN-GROUP1 = GC_REJ
        OR SCREEN-GROUP1 = GC_CGI.
          SCREEN-ACTIVE = GC_0.
          MODIFY SCREEN.
        ENDIF.

      WHEN 'REJ'.
        IF SCREEN-GROUP1 = GC_PGI
        OR SCREEN-GROUP1 = GC_MGI.
          SCREEN-ACTIVE = GC_0.
          MODIFY SCREEN.
        ENDIF.

    ENDCASE.
  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_LIST_BOX OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE SET_LIST_BOX OUTPUT.

  CLEAR : GT_LBOX[].

  DATA(LV_TYPE) = SWITCH #( GV_PRXX WHEN 'MGI' THEN GC_A
                                    WHEN 'MOD' THEN GC_A  "추가(SJM 25.06.11)
                                    WHEN 'REJ' THEN GC_R ).

  CHECK LV_TYPE IS NOT INITIAL.

  SELECT FLD_03
         FLD_04
    FROM ZGTPPT1010
    INTO TABLE GT_LBOX
   WHERE FLD_01 = SY-CPROG
     AND FLD_02 = LV_TYPE.

  CASE GV_PRXX.
    WHEN 'MGI'  "출고 사유 등록 및 품의
      OR 'MOD'. "추가(SJM 25.06.11)
      PERFORM VRM_SET_VALUES USING 'GS_PRXX-ORES'
                                    GS_PRXX-ORES.

    WHEN 'REJ'. "반려 처리
      PERFORM VRM_SET_VALUES USING 'GS_PRXX-REJRES'
                                    GS_PRXX-REJRES.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module PBO_0600 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE PBO_0600 OUTPUT.

  DATA : LT_EXCD TYPE TABLE OF FCODE.


  LT_EXCD[] = VALUE #( ( 'OKAY' ) ).
  SET PF-STATUS '0200' EXCLUDING LT_EXCD.
  SET TITLEBAR  '0600'.

  IF GR_TDOCK IS NOT BOUND.
    PERFORM SET_OBJ.

    PERFORM SET_EXCL TABLES GT_IEXCL.
    PERFORM SET_LAYO  USING GS_TLAYO 'T'.
*   PERFORM SET_EVNT  USING GR_TGRID 'GR_TGRID'.

    PERFORM SET_FCAT TABLES GT_TFCAT
                      USING 'T'.
    PERFORM SET_DISP TABLES GT_IEXCL
                            GT_TFCAT
                            GT_TGIH
                      USING GR_TGRID
                            GS_TLAYO 'T'.
  ELSE.
    PERFORM REFRESH_GRID USING GR_TGRID
                               GS_TLAYO.
  ENDIF.

ENDMODULE.
