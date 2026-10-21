*&---------------------------------------------------------------------*
*& Include          ZGTMMR4010I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

  CASE GV_OKCODE.
    WHEN 'EXIT' OR 'CANC'.
      PERFORM FREE_OBJ.

      CASE SY-DYNNR.
        WHEN '0100'.
          LEAVE PROGRAM.
        WHEN '0200' OR '0210'.
          SET SCREEN 0.
      ENDCASE.

  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PAI_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_0100 INPUT.

  "'CCEL'(ESC) 일때 프로그램을 나가지 않도록(SJM 25.01.14)

  CLEAR : GV_REF, GV_PRXX.

  CASE GV_OKCODE.
    WHEN 'BACK' OR 'CCEL'.
      PERFORM FREE_OBJ.
      SET SCREEN 0.

    WHEN 'REFR'. "재조회
      PERFORM PRCS_REFR.

    WHEN 'PCAP'. "상신
      PERFORM PRCS_PCAP.

    WHEN 'CCAP'. "상신취소
      PERFORM PRCS_CCAP.

    WHEN 'REPC'. "재처리
      PERFORM PRCS_REPC.

    WHEN 'APPV'. "승인
      PERFORM PRCS_APPV.

    WHEN 'REJT'. "반려
      PERFORM PRCS_REJT.

  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PAI_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_0200 INPUT.

  CASE GV_OKCODE.
    WHEN 'YPRX'. "Yes
      CLEAR : GV_ERR.

      CASE GV_PRXX.
        WHEN 'POD'.
          PERFORM PRCS_YPOD.
        WHEN 'REJ'.
          PERFORM PRCS_YREJ.
      ENDCASE.

      IF GV_ERR IS INITIAL.
        SET SCREEN 0.
      ENDIF.

    WHEN 'NPRX'. "No
      SET SCREEN 0.

  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_REJRES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_REJRES INPUT.

  DATA : LT_IFNO TYPE VRM_VALUES.


  SELECT FLD_03
         FLD_04
    FROM ZGTPPT1010
    INTO TABLE LT_IFNO
   WHERE FLD_01 = SY-CPROG
     AND FLD_02 = GC_R.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID     = 'GS_PRXX-REJRES'
      VALUES = LT_IFNO.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PAI_0210  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_0210 INPUT.

  CASE GV_OKCODE.
    WHEN 'RAPP'. "승인요청
      PERFORM PRCS_RAPP.

      IF GV_ERR IS INITIAL.
        LEAVE TO SCREEN 0.
      ENDIF.

  ENDCASE.

  CLEAR : GV_OKCODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_USERID  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_USERID INPUT.

  SELECT EKGRP,
         EKNAM,
         USERID,
         NAME,
         EMAIL
    FROM ZGTMM_CV_GETAPUSERLIST
    INTO TABLE @DATA(LT_USER)
   WHERE WERKS  = @P_WERKS.
*    AND EKGRP IN @S_EKGRP. "삭제(SJM 25.03.27)

  SORT LT_USER BY USERID.
  DELETE ADJACENT DUPLICATES FROM LT_USER COMPARING USERID. "추가(SJM 25.03.27)

  _CALL_F4 'USERID' LT_USER.

  CHECK GT_RTAB[] IS NOT INITIAL.

  CLEAR : GS_APPV.
  GS_APPV = CORRESPONDING #( LT_USER[ USERID = VALUE #( GT_RTAB[ 1 ]-FIELDVAL OPTIONAL ) ] ).

  PERFORM SET_FUNC_CODE.

ENDMODULE.
