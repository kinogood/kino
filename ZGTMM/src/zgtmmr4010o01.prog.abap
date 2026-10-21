*&---------------------------------------------------------------------*
*& Include          ZGTMMR4010O01
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

    CASE 'X'.
      WHEN P_RQP.
        PERFORM SET_FCAT_DISP TABLES GT_HRQP
                                     GT_IRQP.
      WHEN OTHERS.
        PERFORM SET_FCAT_DISP TABLES GT_HAPP
                                     GT_IAPP.
*     WHEN P_RQD.
*       PERFORM SET_FCAT_DISP TABLES GT_HRQD
*                                    GT_IRQD.
*     WHEN P_APM.
*       PERFORM SET_FCAT_DISP TABLES GT_HAPM
*                                    GT_IAPM.
*     WHEN P_APD.
*       PERFORM SET_FCAT_DISP TABLES GT_HAPD
*                                    GT_IAPD.
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

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module MODIFY_SCREEN OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE MODIFY_SCREEN OUTPUT.

  IF SY-DYNNR = GC_0210.
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = GC_APP.
        SCREEN-INPUT = GC_0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
    EXIT.
  ENDIF.

  CLEAR : GS_PRXX-TXT01, GS_PRXX-TXT02.

  CASE GV_PRXX.
    WHEN 'POD'.
      GS_PRXX-TXT01 = 'PO 분할 하시겠습니까?'(P06).
      GS_PRXX-TXT02 = '분할된 내용의 적용은 품의 승인 완료 후 반영됩니다.'(P07).
    WHEN 'REJ'.
      GS_PRXX-TXT01 = '해당 품의를 반려 하시겠습니까?'(P08).
  ENDCASE.

  LOOP AT SCREEN.
    CASE GV_PRXX.
      WHEN 'POD'.
        IF SCREEN-GROUP1 = GC_REJ.
          SCREEN-ACTIVE = GC_0.
          MODIFY SCREEN.
        ENDIF.

      WHEN 'REJ'.
        IF SCREEN-GROUP1 = GC_POD.
          SCREEN-ACTIVE = GC_0.
          MODIFY SCREEN.
        ENDIF.

    ENDCASE.
  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module PBO_0210 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE PBO_0210 OUTPUT.

  SET PF-STATUS '0210'.
  SET TITLEBAR  '0210'.

  IF GR_TCUST IS NOT BOUND.
    PERFORM SET_TXT_OBJ.
  ENDIF.

  GR_TEDIT->SET_TEXT_AS_R3TABLE( TABLE = GT_LINE ).

  "Plant/PGrp당 무조건 한 명이므로 바로 Display(선택할 필요 없음)
* CLEAR : GS_APPV.
  "승인자 변경 가능하도록 변경(SJM 25.03.25)
  CHECK GS_APPV IS INITIAL.
  SELECT SINGLE USERID,
                NAME,
                EMAIL
    FROM ZGTMM_CV_GETAPUSERLIST
    INTO CORRESPONDING FIELDS OF @GS_APPV
   WHERE WERKS  = @P_WERKS
     AND EKGRP IN @S_EKGRP.

ENDMODULE.
