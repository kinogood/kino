************************************************************************
* Title         :  ZTIR1000F01                                         *
*                                                                      *
* Description   : 적하부보 관리 Subroutine Include                     *
*                                                                      *
* Creation Date : 2003/08/20                                           *
*                                                                      *
* Author        : Seung Jun, Lee                                       *
*                 Copyright ⓒ ASEG Co., LTD. All rights reserved.     *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* dd-mmm-yyyy  xxxxxxxxxxxxxxx  DVPK9xxxxx  xxxxxxxxxxxxxxxxxxxxxxxxx  *
*                                                                      *
*                                                                      *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  set_bill_of_lading_data
*&---------------------------------------------------------------------*
*       B/L 아이템을 생성함.
*----------------------------------------------------------------------*
FORM SET_BILL_OF_LADING_DATA    TABLES P_IT_TAB   LIKE IT_TAB
                                USING  P_ZTIVRQ00 STRUCTURE ZTIVRQ00
                                       P_ZTITBLK STRUCTURE ZTITBLK
                                       P_ZTISRQIT STRUCTURE IT_ZTISRQIT.
*  CLEAR: p_it_tab.
*
*  MOVE-CORRESPONDING p_ZTIvrq00 TO : p_it_tab, p_ZTITBLK.
*
*  MOVE: p_ZTIsrqit-blmng  TO p_it_tab-blmng,
*        p_ZTIsrqit-blmngs TO p_it_tab-blmngs,
*        p_ZTIsrqit-blmngl TO p_it_tab-blmngl.
*
*  MOVE: sy-uname TO p_it_tab-cnam,
*        sy-datlo TO p_it_tab-cdat,
*        sy-timlo TO p_it_tab-ctme,
*        sy-uname TO p_it_tab-unam,
*        sy-datlo TO p_it_tab-udat,
*        sy-timlo TO p_it_tab-utme.
*
*  IF NOT  p_it_tab-ebeln IS INITIAL.
** 구매오더 정보 Read.
*    SELECT SINGLE menge werks lgort matnr txz01
*                  loekz elikz bprme bpumz bpumn umrez
*                  umren netpr peinh uebto uebtk untto
*    INTO CORRESPONDING FIELDS OF p_it_tab
*      FROM ekpo
*     WHERE ebeln  EQ  p_it_tab-ebeln
*       AND ebelp  EQ  p_it_tab-ebelp.
**> 수입의뢰 정보 Read.
*    IF NOT p_it_tab-reqno IS INITIAL.
*      SELECT SINGLE rqmng
*        INTO p_it_tab-rqmng
*        FROM ZTIvrq00
*       WHERE reqno   EQ  p_it_tab-reqno
*         AND reqit   EQ  p_it_tab-reqit.
*
*      SELECT  SUM( blmng ) INTO p_it_tab-blmngs FROM ZTIvbl00
*       WHERE  reqno       EQ  p_it_tab-reqno
*         AND  reqit       EQ  p_it_tab-reqit
*         AND NOT ( iblno  EQ  p_it_tab-iblno
*         AND       iblit  EQ  p_it_tab-iblit ).
***> 초과납품허용치.
**        if not ZTITBLP-UEBTO is initial.
**           ZTITBLP-rqmng = ZTITBLP-rqmng +
**                          ( ZTITBLP-rqmng * ZTITBLP-UEBTO ) / 100.
**        endif.
**        if not ZTITBLP-UEBTK is initial.
**
**        endif.
*      p_it_tab-blmngl =  p_it_tab-rqmng - p_it_tab-blmngs.
*    ENDIF.
*
*    IF p_it_tab-blmngl LE 0.
*      p_it_tab-blmngl = 0.
*    ENDIF.
*  ENDIF.
*  IF NOT p_it_tab-rsnum IS INITIAL.
**RSPOS
**RSART
*  ENDIF.
*
*  APPEND p_it_tab.
*
**>아이템 번호를 생성함.
*  PERFORM set_item_number_build TABLES p_it_tab
*                                USING  p_ZTITBLK.
*
*  PERFORM get_others_text_by_master_data.

ENDFORM.                    " set_request_of_import_data

*&---------------------------------------------------------------------*
*&      Form  get_and_check_po_data
*&---------------------------------------------------------------------*
*       Get 구매오더 데이타.
*----------------------------------------------------------------------*
FORM GET_AND_CHECK_PO_DATA  USING    P_EBELN
                                     P_EBELP
                                     P_MODIFY
                                     P_ZTIVPO00 STRUCTURE ZTIVPO00
                                     P_COUNT.

*  CLEAR: p_ZTIvpo00.
*
*  SELECT SINGLE * INTO p_ZTIvpo00
*    FROM ZTIvpo00
*   WHERE ebeln EQ p_ebeln
*     AND ebelp EQ p_ebelp.
*
*  IF sy-subrc EQ 0.
**>Vendor 체크.
*    IF ZTITRQK-lifnr     NE p_ZTIvpo00-lifnr AND
*       NOT ZTITRQK-lifnr IS INITIAL.
*      MESSAGE s003 WITH p_ZTIvpo00-lifnr ZTITRQK-lifnr.
*      p_modify = c_true.
*      EXIT.
*    ENDIF.
**통화키 체크.
*    IF ZTITRQS-waers    NE  p_ZTIvpo00-waers AND
*       p_count           GT  c_zero.
*      MESSAGE s006 WITH p_ZTIvpo00-waers ZTITRQS-waers.
*      p_modify = c_true.
*    ENDIF.
*
**> Lock Object
*    PERFORM  set_po_lock_object  USING p_ebeln
*                                       p_ebelp
*                                       c_lock
*                                       c_success
*                                       p_modify.
*  ELSE.
*    MESSAGE s019(06) WITH p_ebeln.
*    p_modify = c_true.
*    EXIT.
*  ENDIF.

ENDFORM.                    " get_and_check_po_data
*&---------------------------------------------------------------------*
*&      Form  get_and_check_lc_data
*&---------------------------------------------------------------------*
*       Get 구매오더 데이타.
*----------------------------------------------------------------------*
FORM GET_AND_CHECK_LC_DATA  USING    P_REQNO
                                     P_AMDSQ
                                     P_REQIT
                                     P_MODIFY
                                     P_ZTIVRQ00 STRUCTURE ZTIVRQ00
                                     P_COUNT.

  CLEAR: P_ZTIVRQ00.

  SELECT SINGLE * INTO P_ZTIVRQ00
    FROM ZTIVRQ00
   WHERE REQNO EQ P_REQNO
     AND REQIT EQ P_REQIT.

  IF SY-SUBRC EQ 0.
*>Vendor 체크.
    IF ZTITBLK-LIFNR     NE P_ZTIVRQ00-LIFNR AND
       NOT ZTITBLK-LIFNR IS INITIAL.
      MESSAGE S205 WITH P_ZTIVRQ00-LIFNR ZTITBLK-LIFNR.
      P_MODIFY = C_TRUE.
      EXIT.
    ENDIF.
*통화키 체크.
    IF ZTITBLK-WAERS    NE  P_ZTIVRQ00-WAERS AND
       P_COUNT           GT  C_ZERO.
      MESSAGE S206 WITH P_ZTIVRQ00-WAERS ZTITBLK-WAERS.
      P_MODIFY = C_TRUE.
    ENDIF.
*>기타 체크 로직.

*> Lock Object
    PERFORM  SET_LC_LOCK_OBJECT  USING P_REQNO
                                       P_AMDSQ
                                       P_REQIT
                                       C_LOCK
                                       C_SUCCESS
                                       P_MODIFY.
  ELSE.
    MESSAGE S019(06) WITH P_REQNO.
    P_MODIFY = C_TRUE.
    EXIT.
  ENDIF.

ENDFORM.                    " get_and_check_lc_data

*&---------------------------------------------------------------------*
*&      Form  p3000_set_data_of_screen
*&---------------------------------------------------------------------*
FORM P3000_SET_DATA_OF_SCREEN .

  CHECK : SY-TCODE EQ C_CREATE OR
          SY-TCODE EQ C_CREATE_D.

  REFRESH: IT_TAB, IT_REQNO.

  CLEAR: ZTITBLK,
         ZTITBLP,
         ZTISBLIT,
         ZTITBLC,
         ZTITIP1,
         ZTITIP3,
         ZTITRQK,
         IT_TAB,
         IT_REQNO,
         LFA1,
        *LFA1,
         W_LFA1,
         W_LFA1_BANK,
         T001,
         T024,
         T024E.

  CLEAR:  GT_CONTROL-TEXTLINES[], GT_CONTROL-TEXTTYPES[].

*  MOVE:  space        TO    ZTITBLK-bldty,  ">문서종류.
*         'KG'         TO    ZTITBLK-gewei,  ">중량단위.
**         'CBM'        TO    ZTITBLK-voleh,  ">부피단위.
*         'M3'         TO    ZTITBLK-voleh,  ">부피단위.
*         'CT'         TO    ZTITBLK-bpkty,  ">포장단위.
*         'KR'         TO    ZTITBLK-tland,  ">도착국가.
*         'PUS'        TO    ZTITBLK-tport.  ">도착항.
**
* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

ENDFORM.                    " p3000_set_data_of_screen

*&---------------------------------------------------------------------*
*&      Form  check_for_sub_document_exist
*&---------------------------------------------------------------------*
*  삭제시 후속 문서의 존재여부를 확인함..
*----------------------------------------------------------------------*
FORM CHECK_FOR_SUB_DOCUMENT_EXIST.

  DATA: L_COUNT  TYPE I.

*  LOOP AT it_tab INTO g_tc_2130_wa.
*    PERFORM check_ip_sub_document_exist(ZTIr0000)
*                             USING   g_tc_2130_wa-reqno
*                                     g_tc_2130_wa-reqit
*                                     c_error
*                                     g_subrc.
*  ENDLOOP.

*> 비용문서 체크.
  SELECT COUNT( * )
    INTO L_COUNT
    FROM ZTITCSP
   WHERE EXPGR  EQ  C_CHARI
     AND REFNO  EQ  ZTITIP1-IIPNO
     AND AMDSQ  EQ  ZTITIP1-AMDSQ.

  IF L_COUNT GT 0.
    MESSAGE ID 'ZMTI00' TYPE C_ERROR NUMBER '109' WITH '수입제비용'.
  ENDIF.

ENDFORM.                    " check_for_sub_document_exist

*&---------------------------------------------------------------------*
*&      Form  check_for_document_field
*&---------------------------------------------------------------------*
*  필드들의 오류 값들을 체크하여 공통 nternal table에 저장함.
*----------------------------------------------------------------------*
FORM CHECK_FOR_DOCUMENT_FIELD USING P_MODE.

  DATA: L_IF_NULL TYPE REF TO IF_MESSAGE_OBJ_MM.

  CHECK : G_MODE EQ C_CHARC OR
          G_MODE EQ C_CHARM OR
          G_MODE EQ C_CHARY OR
          G_MODE EQ C_CHARO.

* Message preparations
  PERFORM  SET_MESSAGE_PREPARATIONS.

  PERFORM  SET_RETURN_MANDATORY     USING  :
                                'ZTITIP1-INSCP'  C_ERROR,
*                                'ZTSTIG3-NAMET'  c_error,
                                'ZTITIP1-TAPDT'  C_ERROR,
*                                'ZTITIP1-PSPNR' C_ERROR,
                                'ZTITIP1-IOPDT'  C_ERROR,
*                                'ZTITRQS-OPNNO' C_ERROR,
                                'ZTITIP1-ITOCP'  C_ERROR,
                                'ZTITIP1-ITORT'  C_ERROR,
                                'ZTITIP1-IIVAT'  C_ERROR,
                                'ZTITIP1-IIVATC' C_ERROR,
                                'ZTITIP1-IWART'  C_ERROR,
                                'ZTITIP1-IOPNO'  C_ERROR,
                                'ZTITIP1-IVSLN'  C_ERROR,
                                'ZTITIP1-ISHCD'  C_ERROR,
                                'ZTITIP1-ISHNM'  C_ERROR,
*                                'ZTITIP1-ICARN' C_ERROR,
                                'ZTITIP1-ILDCD'  C_ERROR,
                                'ZTITIP1-ILDNM'  C_ERROR,
*                                'ZTITIP1-IDPDT' C_ERROR,
                                'ZTITIP1-IGOTE1' C_ERROR,
                                'ZTITIP1-IHSCD'  C_ERROR,
                                'ZTITIP1-IPCON'  C_ERROR,
                                'ZTITIP1-IPORN'  C_ERROR,
                                'ZTITIP1-IRECD'  C_ERROR,
                                'ZTITIP1-IRENO'  C_ERROR.
*                                'ZTITIP1-IISDT'  c_error,
*                                'ZTITIP1-ITPRT'  c_error.
*
  IF G_MODE EQ 'O'.
    PERFORM  SET_RETURN_MANDATORY     USING  :
                               'ZTITIP1-IISDT'  C_ERROR,
                               'ZTITIP1-ITPRT'  C_ERROR.
  ENDIF.



  IF ZTITIP1-AMDSQ GT 0.
    IF ZTITIP4-IIVYN EQ C_FALSE AND  ">송장금액배서여부
       ZTITIP4-IDUYN EQ C_FALSE AND  ">통관금액배서여부
       ZTITIP4-IINYN EQ C_FALSE AND  ">보험료배서여부
       ZTITIP4-IAMYN EQ C_FALSE AND  ">보험금배서여부
       ZTITIP4-IPEYN EQ C_FALSE AND  ">희망이익율배서여부
       ZTITIP4-IPDYN EQ C_FALSE AND  ">관세율 배서여부
       ZTITIP4-IDTYN EQ C_FALSE AND  ">출항일 배서여부
       ZTITIP4-IPRYN EQ C_FALSE AND  ">Port/Airport 배서여부
       ZTITIP4-IDOYN EQ C_FALSE AND  ">문서번호 배서여부
       ZTITIP4-ITMYN EQ C_FALSE AND  ">운송수단 배서여부
       ZTITIP4-IHSYN EQ C_FALSE AND  ">HS Code 배서여부
       ZTITIP4-IGDYN EQ C_FALSE AND  ">상품명세 배서여부
       ZTITIP4-IPAYN EQ C_FALSE AND  ">Partial 배서여부
       ZTITIP4-IEIYN EQ C_FALSE AND  ">질권기관 배서여부
       ZTITIP4-ICDYN EQ C_FALSE AND  ">부보조건 배서여부
       ZTITIP4-IETYN EQ C_FALSE AND  ">기타유형 배서여부
       ZTITIP4-IADYN EQ C_FALSE.    ">추가사항 배서여부
      MESSAGE S157.
      PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
    ENDIF.
  ENDIF.

  DESCRIBE TABLE G_TC_2210_ITAB LINES G_LINE.
  IF G_LINE EQ 0.
    MESSAGE S142.
    PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
  ENDIF.

*> 오류정보가 존재시 메시지 상자 POPUP.
  G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                          IM_BUSINESS_OBJ          = L_IF_NULL
                          IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

  IF G_LINE GT 0.
    CALL METHOD G_MESSAGE_HANDLER->SHOW( IM_POPUP = C_TRUE
      IM_AMODAL = C_FALSE ).
  ELSE.
    MESSAGE S911.
  ENDIF.

ENDFORM.                    " check_for_document_field
*&---------------------------------------------------------------------*
*&      Form  p8000_save_master_data
*&---------------------------------------------------------------------*
FORM P8000_SAVE_MASTER_DATA USING P_MODE.

*>Switches on the local update task.
  SET UPDATE TASK LOCAL.

*> 공통테이블 적용.
  IF G_MODE      EQ C_CHARY AND
     OK_CODE_OLD EQ 'ZTISAVE'.
    P_MODE = 'Y'.
  ENDIF.

  PERFORM P8100_SAVE_COMMON_DATA  TABLES IT_TAB
                                         G_TC_2210_ITAB
                                  USING  ZTITIP1
                                         ZTITIP3
                                         ZTITIP4
                                         G_SUBRC
                                         P_MODE.
  IF G_SUBRC NE C_ZERO.
    MESSAGE A912.   EXIT.
  ENDIF.

*> Long Text 저장 루틴.
  PERFORM SAVE_LONG_TEXT USING ZTITIP1+3(12)
                               C_TEXTOBJECT_HEADER
                               G_SUBRC.

  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    MESSAGE A912.   EXIT.
  ELSE.
*> Change document setting.
    PERFORM P8120_CHANGE_DOCUMENT.
*> Commit work.
    COMMIT WORK.
*> Set parameter ID
    IF OK_CODE_OLD EQ 'ZTIDELETE'.
      MESSAGE S201 WITH ZTITIP1-IIPNO.
    ELSE.
      SET PARAMETER ID 'ZTIIIPNO'  FIELD ZTITIP1-IIPNO.
      SET PARAMETER ID 'ZTIAMSEQ'  FIELD ZTITIP1-AMDSQ.
*      SET PARAMETER ID 'ZTIBLNUM' FIELD ZTITBLK-blnum.
      MESSAGE S202 WITH ZTITIP1-IIPNO.
    ENDIF.
  ENDIF.

ENDFORM.                    " p8000_save_master_data
*&---------------------------------------------------------------------*
*&      Form  p8100_save_common_data
*&---------------------------------------------------------------------*
FORM P8100_SAVE_COMMON_DATA  TABLES  PT_TAB     STRUCTURE G_TC_2130_WA
                                     PT_2210    STRUCTURE G_TC_2210_WA
                             USING   P_ZTITIP1 STRUCTURE ZTITIP1
                                     P_ZTITIP3 STRUCTURE ZTITIP3
                                     P_ZTITIP4 STRUCTURE ZTITIP4
                                     P_SUBRC    LIKE      SY-SUBRC
                                     P_MODE.
  DATA: L_DOCTY(9) TYPE C.

  DATA: L_IIPNO TYPE ZTIREQNO,
        L_REQTY TYPE ZTIREQTY,
        L_AMDSQ TYPE ZTIAMSEQ.

  CLEAR: P_SUBRC, L_IIPNO.
  L_REQTY = 'IP'.

  IF ( G_TCODE EQ C_CREATE OR  G_TCODE EQ C_CREATE_D ) AND
     P_ZTITIP1-IIPNO IS INITIAL.

    CALL FUNCTION 'Z_TI_GET_NUMBER_NEXT'
      EXPORTING
        ZMPTY          = L_REQTY
*   BUKRS          =
     IMPORTING
        LCONO          = L_IIPNO
     EXCEPTIONS
       NOT_TYPE       = 1
       OTHERS         = 2.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
    L_IIPNO = P_ZTITIP1-IIPNO.
    L_AMDSQ = P_ZTITIP1-AMDSQ.
  ENDIF.

  IF  P_ZTITIP1-CNAM IS INITIAL.
    MOVE: SY-UNAME   TO   P_ZTITIP1-CNAM,
          SY-DATLO   TO   P_ZTITIP1-CDAT,
          SY-TIMLO   TO   P_ZTITIP1-CTME.
  ENDIF.

  MOVE: SY-MANDT   TO   P_ZTITIP1-MANDT,
        L_IIPNO    TO   P_ZTITIP1-IIPNO,
        SY-UNAME   TO   P_ZTITIP1-UNAM,
        SY-DATLO   TO   P_ZTITIP1-UDAT,
        SY-TIMLO   TO   P_ZTITIP1-UTME.

  IF P_ZTITIP1-RECNO IS INITIAL.
    IF P_ZTITIP1-AMDSQ IS INITIAL.
      MOVE: 'APPCIP-'      TO  P_ZTITIP1-RECNO,
            ZTITIP1+3(10)  TO  P_ZTITIP1-RECNO+7(10),
            '-'            TO  P_ZTITIP1-RECNO+17(1),
            ZTITIP1+13(2)  TO  P_ZTITIP1-RECNO+18(2).
    ELSE.
      MOVE: 'APPEND-'      TO  P_ZTITIP1-RECNO,
            ZTITIP1+3(10)  TO  P_ZTITIP1-RECNO+7(10),
            '-'            TO  P_ZTITIP1-RECNO+17(1),
            ZTITIP1+13(2)  TO  P_ZTITIP1-RECNO+18(2).
    ENDIF.
  ENDIF.
*> EDI Partner관련 필드 Reset.
  PERFORM  SET_EDI_PARTNER_FIELD.

  CASE P_MODE.
    WHEN 'Y'.     ">신청서만 저장.
      MOVE: SPACE      TO  P_ZTITIP1-DOCST,
            SPACE      TO  P_ZTITIP1-SNDST.
    WHEN 'I'.     ">신청.
      MOVE: C_CHARY    TO  P_ZTITIP1-DOCST,
            SPACE      TO  P_ZTITIP1-SNDST,
            SY-UNAME   TO  P_ZTITIP1-SNDUN,
            SY-DATLO   TO  P_ZTITIP1-SNDDT,
            SY-TIMLO   TO  P_ZTITIP1-SNDTM.

*{ SRM2203-09738 - 추가_S
      IF G_EDI_ANSWER EQ C_Y AND ZTSTIG0-INSCP = P_ZTITIP1-INSCP AND
         P_ZTITIP1-INSCP <> 'NETLG'.
        IF P_ZTITIP1-AMDSQ IS INITIAL.
          L_DOCTY = 'APPCIP4AA'.
        ELSE.
          L_DOCTY = 'APPEND4BA'.
        ENDIF.

        PERFORM  BUILD_EDI_STATUS_RECORD USING ZTSTEDIS-SNCNT
                                               L_DOCTY
                                               P_ZTITIP1-BUKRS
                                               P_ZTITIP1-IIPNO
                                               P_ZTITIP1-AMDSQ
                                               P_ZTITIP1-RECID
                                               P_ZTITIP1-RECNM
                                               P_ZTITIP1-RECNO
                                               P_SUBRC.
        IF P_SUBRC NE 0.
          ROLLBACK WORK.      EXIT.
        ENDIF.
        P_ZTITIP1-SNCNT = ZTSTEDIS-SNCNT.
*        P_ZTITIP1-REQMT = C_CHARE.
      ELSE.
*        P_ZTITIP1-REQMT = C_CHARM.
      ENDIF.
*} SRM2203-09738 - 추가_E

    WHEN 'F'.     ">신청취소.
      MOVE: SPACE      TO  P_ZTITIP1-DOCST,
            SPACE      TO  P_ZTITIP1-SNDST,
            SY-UNAME   TO  P_ZTITIP1-SNDUN,
            SY-DATLO   TO  P_ZTITIP1-SNDDT,
            SY-TIMLO   TO  P_ZTITIP1-SNDTM.

**> EDI record delete
*      PERFORM  delete_edi_status_record USING p_ztitip1-sncnt
*                                              p_subrc.
*      IF p_subrc NE 0.
*        ROLLBACK WORK.      EXIT.
*      ENDIF.
*
*      CLEAR p_ztitip1-sncnt.
*
    WHEN 'O'.     ">개설.
      MOVE: C_CHARO    TO  P_ZTITIP1-DOCST,
            SY-UNAME   TO  P_ZTITIP1-RCVUN,
            SY-DATLO   TO  P_ZTITIP1-RCVDT,
            SY-TIMLO   TO  P_ZTITIP1-RCVTM.
      IF P_ZTITIP1-SNDST EQ C_CHARS.
*        MOVE C_CHARM   TO  P_ZTITIP1-SNDST.
        MOVE C_CHARS   TO  P_ZTITIP1-SNDST.
      ELSE.
        MOVE C_CHARM   TO  P_ZTITIP1-SNDST.
      ENDIF.

    WHEN 'N'.     ">개설취소.
      MOVE: C_CHARN    TO  P_ZTITIP1-DOCST,
            SPACE      TO  P_ZTITIP1-SNDST,
            SY-UNAME   TO  P_ZTITIP1-RCVUN,
            SY-DATLO   TO  P_ZTITIP1-RCVDT,
            SY-TIMLO   TO  P_ZTITIP1-RCVTM.
  ENDCASE.

  L_IIPNO = P_ZTITIP1-IIPNO.
  L_AMDSQ = P_ZTITIP1-AMDSQ.

  IF OK_CODE_OLD EQ 'ZTIDELETE'.
*> Header table delete.
    DELETE FROM ZTITIP1
     WHERE IIPNO EQ P_ZTITIP1-IIPNO
       AND AMDSQ EQ P_ZTITIP1-AMDSQ.

    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
    ENDIF.
*> 보험조건 table delete.
    DELETE FROM ZTITIP2
     WHERE IIPNO EQ P_ZTITIP1-IIPNO
       AND AMDSQ EQ P_ZTITIP1-AMDSQ.

*> AMEND table delete.
    DELETE FROM ZTITIP4
     WHERE IIPNO EQ P_ZTITIP1-IIPNO
       AND AMDSQ EQ P_ZTITIP1-AMDSQ.

*> 보험구상 table delete.
    IF NOT P_ZTITIP1-DAMAG IS INITIAL.
      DELETE FROM ZTITIP3 WHERE IIPNO EQ P_ZTITIP1-IIPNO.
    ENDIF.

    EXIT.
  ELSE.
*> Header table modify.
    MODIFY ZTITIP1 FROM P_ZTITIP1.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
    ENDIF.

*> Header table modify.
    P_ZTITIP4-IIPNO = P_ZTITIP1-IIPNO.
    P_ZTITIP4-AMDSQ = P_ZTITIP1-AMDSQ.
    MODIFY ZTITIP4 FROM P_ZTITIP4.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
    ENDIF.

*> 부가조건.
    REFRESH : XZTITIP2.
    DELETE FROM ZTITIP2
           WHERE IIPNO EQ P_ZTITIP1-IIPNO
             AND AMDSQ EQ P_ZTITIP1-AMDSQ.

    LOOP AT G_TC_2210_ITAB INTO G_TC_2210_WA.
      MOVE-CORRESPONDING  G_TC_2210_WA TO XZTITIP2.
      XZTITIP2-MANDT = SY-MANDT.
      XZTITIP2-IIPNO = P_ZTITIP1-IIPNO.
      XZTITIP2-AMDSQ = P_ZTITIP1-AMDSQ.
      APPEND XZTITIP2.
    ENDLOOP.
    MODIFY ZTITIP2 FROM TABLE XZTITIP2.

*> 구상 테이블.
    IF NOT P_ZTITIP1-DAMAG IS INITIAL.
      P_ZTITIP3-MANDT = P_ZTITIP1-MANDT.
      P_ZTITIP3-IIPNO = P_ZTITIP1-IIPNO.
      MODIFY ZTITIP3 FROM P_ZTITIP3.
      IF SY-SUBRC NE 0.
        ROLLBACK WORK.   MOVE SY-SUBRC  TO P_SUBRC.     EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " p8100_save_common_data
*&---------------------------------------------------------------------*
*&      Form  call_smartforms_functioins
*&---------------------------------------------------------------------*
FORM CALL_SMARTFORMS_FUNCTIOINS USING P_FUNC_MOD_NAME.

  CALL FUNCTION P_FUNC_MOD_NAME
       EXPORTING
*            ARCHIVE_INDEX      =
*            ARCHIVE_INDEX_TAB  =
*            ARCHIVE_PARAMETERS =
*            MAIL_APPL_OBJ      = MAIL_APPL_OBJ
*            MAIL_RECIPIENT     = MAIL_RECIPIENT
*            MAIL_SENDER        = MAIL_SENDER
            USER_SETTINGS      = SPACE
            CONTROL_PARAMETERS = G_CONTROL_PARAMETERS
            OUTPUT_OPTIONS     = G_OUTPUT_OPTIONS
*            LFA1               = LFA1
*            SUMMARY            = ZMMKR_RTC_ERS_LIST
*            SDATE              = GW_SDATE
*            TITLE              = TEXT-T01
*            TITLE              = 'ERS LIST'
       IMPORTING
            DOCUMENT_OUTPUT_INFO = G_DOCUMENT_OUTPUT_INFO
            JOB_OUTPUT_INFO      = G_JOB_OUTPUT_INFO
            JOB_OUTPUT_OPTIONS   = G_JOB_OUTPUT_OPTIONS
*       TABLES
*            I_ITEM             = XITAB
*            SUBTOTAL           = SITAB
       EXCEPTIONS
            FORMATTING_ERROR   = 1
            INTERNAL_ERROR     = 2
            SEND_ERROR         = 3
            USER_CANCELED      = 4.

  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " call_smartforms_functioins
*&---------------------------------------------------------------------*
*&      Form  GET_OTHERS_TEXT_BY_MASTER_DATA
*&---------------------------------------------------------------------*
*       화면상의 Text를 Master Data 등에서 Read.
*----------------------------------------------------------------------*
FORM GET_OTHERS_TEXT_BY_MASTER_DATA .

  IF ZTITIP1-BUKRS IS INITIAL.
    CLEAR: T001.
  ELSE.
    SELECT SINGLE * FROM T001
     WHERE BUKRS EQ ZTITIP1-BUKRS.
    IF SY-SUBRC EQ 0.
      SELECT SINGLE *
        FROM T005
       WHERE LAND1 EQ T001-LAND1.
    ENDIF.

    SELECT SINGLE *
      FROM ZTSTIG0
     WHERE BUKRS EQ ZTITIP1-BUKRS.
  ENDIF.
* 구매조직 SELECT ( T024E )
  IF ZTITIP1-EKORG IS INITIAL.
    CLEAR T024E.
  ELSE.
    CALL FUNCTION 'T024E_SINGLE_READ'
      EXPORTING
        T024E_EKORG = ZTITIP1-EKORG
      IMPORTING
        WT024E      = T024E
      EXCEPTIONS
        NOT_FOUND   = 1
        OTHERS      = 2.

    IF SY-SUBRC NE 0.
      IF SY-CALLD NE C_TRUE.
        MESSAGE W001(MH) WITH ZTITIP1-EKORG.
      ENDIF.
    ENDIF.
  ENDIF.

* 구매그룹 SELECT ( T024 )
  IF ZTITIP1-EKGRP IS INITIAL.
    CLEAR T024.
  ELSE.
    CALL FUNCTION 'MM_ARRANG_PURCHASE_GRP_SELECT'
      EXPORTING
        PURCHASE_GROUP           = ZTITIP1-EKGRP
      IMPORTING
        E_T024                   = T024
      EXCEPTIONS
        PURCHASE_GROUP_NOT_FOUND = 1
        OTHERS                   = 2.

    IF SY-SUBRC NE 0.
      IF SY-CALLD NE C_TRUE.
        MESSAGE W030(MN) WITH ZTITIP1-EKGRP.
      ENDIF.
    ENDIF.
  ENDIF.

*> Vender master check
  PERFORM  GET_IMPORT_VENDORS_TEXT  USING C_SUCCESS.

ENDFORM.                    " GET_OTHERS_TEXT_BY_MASTER_DATA
*&---------------------------------------------------------------------*
*&      Form  get_used_payment_term
*&---------------------------------------------------------------------*
FORM GET_USED_PAYMENT_TERM  TABLES   P_IT_ZTITIG02 STRUCTURE ZTITIG02
                            USING    P_SUBRC  P_TYPE.

  CLEAR: P_SUBRC.

  SELECT BSTYP BSART ZTERM REQTY SETYN FROM  ZTITIG02
    INTO CORRESPONDING FIELDS OF TABLE P_IT_ZTITIG02.

  P_SUBRC = SY-SUBRC.

  IF P_SUBRC NE 0.
    MESSAGE ID 'ZMTI00' TYPE P_TYPE NUMBER 001.
    EXIT.
  ENDIF.

ENDFORM.                    " get_used_payment_term
*&---------------------------------------------------------------------*
*&      Form  GET_available_PO_ITEM
*&---------------------------------------------------------------------*
FORM GET_AVAILABLE_PO_ITEM  TABLES   P_IT_PO    STRUCTURE IT_PO
                                     P_IT_PONUM STRUCTURE IT_PONUM
                            USING    P_MTYPE
                                     P_DELETE.

  DATA: L_RQMNG  LIKE ZTITRQP-RQMNG.
**
  CLEAR: G_COUNT, G_CNT.

  LOOP AT P_IT_PO.
    G_TABIX = SY-TABIX.
    CLEAR: L_RQMNG.

    SELECT  SUM( RQMNG ) INTO P_IT_PO-RQMNGS FROM ZTIVRQ00
     WHERE  EBELN  = P_IT_PO-EBELN
       AND  EBELP  = P_IT_PO-EBELP.

    P_IT_PO-RQMNG =  P_IT_PO-MENGE - P_IT_PO-RQMNGS.

    IF P_IT_PO-RQMNG LE C_ZERO.
      IF P_DELETE EQ C_TRUE.
        DELETE P_IT_PO INDEX G_TABIX.
        CONTINUE.
      ELSE.
        P_IT_PO-RQMNG = 0.
      ENDIF.
    ELSE.
      ADD 1 TO G_CNT.
    ENDIF.

    P_IT_PO-RQMNGL =  P_IT_PO-RQMNG.

    ADD 1 TO G_COUNT.
    P_IT_PO-INDEX = G_COUNT.
    MODIFY P_IT_PO INDEX G_TABIX.

    MOVE P_IT_PO-EBELN TO P_IT_PONUM-EBELN.
    COLLECT P_IT_PONUM.
  ENDLOOP.

  DESCRIBE TABLE P_IT_PO LINES G_LINE.
  IF G_LINE EQ 0.
    MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 902.
    EXIT.
  ENDIF.

  IF G_CNT EQ 0.
*    MESSAGE ID 'ZMTI00' TYPE c_warning NUMBER 103.
    MESSAGE ID 'ZMTI00' TYPE P_MTYPE NUMBER 103.
  ENDIF.

ENDFORM.                    " GET_available_PO_ITEM
*&---------------------------------------------------------------------*
*&      Form  p8120_change_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM P8120_CHANGE_DOCUMENT .

  DATA: L_OBJECTID              TYPE CDHDR-OBJECTID,
        L_TCODE                 TYPE CDHDR-TCODE,
        L_UTIME                 TYPE CDHDR-UTIME,
        L_UDATE                 TYPE CDHDR-UDATE,
        L_USERNAME              TYPE CDHDR-USERNAME,
        L_CDOC_UPD_OBJECT       TYPE CDHDR-CHANGE_IND,
        L_UPD_ICDTXT            TYPE CHAR1,
        L_UPD                   TYPE CHAR1,
*        l_upd                   TYPE char1,
        LT_CDTXT                TYPE STANDARD TABLE OF CDTXT
                                     INITIAL SIZE 0.

  CASE SY-TCODE.
    WHEN C_CREATE OR C_CREATE_D.
      L_CDOC_UPD_OBJECT = 'I'.
      L_UPD_ICDTXT      = ' '.
      L_UPD             = ' '.
*      l_upd_eban        = ' '.
*      l_upd_ebkn        = ' '.
    WHEN OTHERS.
      L_CDOC_UPD_OBJECT = 'U'.
      L_UPD_ICDTXT      = 'U'.
      L_UPD             = 'U'.
*      l_upd_eban        = 'U'.
*      l_upd_ebkn        = 'U'.
  ENDCASE.

  IF OK_CODE_OLD EQ 'ZTIDELETE'.
    L_CDOC_UPD_OBJECT = 'D'.
    L_UPD_ICDTXT      = 'D'.
    L_UPD             = 'D'.
*    l_upd_eban        = 'D'.
*    l_upd_ebkn        = 'D'.
  ENDIF.

  L_OBJECTID(12) = ZTITIP1+3(12).

  L_TCODE        = SY-TCODE.
  L_UTIME        = SY-TIMLO.
  L_UDATE        = SY-DATLO.
  L_USERNAME     = SY-UNAME.

  IF G_MODE EQ C_CHARC.  ">생성모드일 경우.
    REFRESH : YZTITIP2, YZTITIP2.
  ENDIF.

  CALL FUNCTION 'ZTIIPCHDOC_WRITE_DOCUMENT'
    EXPORTING
        OBJECTID                      = L_OBJECTID
        TCODE                         = L_TCODE
        UTIME                         = L_UTIME
        UDATE                         = L_UDATE
        USERNAME                      = L_USERNAME
*   PLANNED_CHANGE_NUMBER         = ' '
        OBJECT_CHANGE_INDICATOR       = L_CDOC_UPD_OBJECT
*   PLANNED_OR_REAL_CHANGES       = ' '
*   NO_CHANGE_POINTERS            = ' '
*   UPD_ICDTXT_ZTIBLCHDOC         = ' '
        N_ZTITIP1                    = ZTITIP1
        O_ZTITIP1                    = *ZTITIP1
        N_ZTITIP3                    = ZTITIP3
        O_ZTITIP3                    = *ZTITIP3
        N_ZTITIP4                    = ZTITIP4
        O_ZTITIP4                    = *ZTITIP4
        UPD_ZTITIP1                  = L_UPD
        UPD_ZTITIP2                  = L_UPD
        UPD_ZTITIP3                  = L_UPD
        UPD_ZTITIP4                  = L_UPD
    TABLES
      ICDTXT_ZTIIPCHDOC               = LT_CDTXT
      XZTITIP2                       = XZTITIP2
      YZTITIP2                       = YZTITIP2.

ENDFORM.                    " p8120_change_document
*&---------------------------------------------------------------------*
*&      Form  call_print_process
*&---------------------------------------------------------------------*
FORM CALL_PRINT_PROCESS .

*> GET OUTPUT OPTIONS
  IF IT_PRTCTL[] IS INITIAL.
    REFRESH : IT_PRTCTL.
    CLEAR: IT_PRTCTL.
    IF NOT ZTITRQK-OPNBK IS INITIAL.   ">Openning bank.
      SELECT LIFNR NAME1 LAND1 SPRAS TELFX ADRNR
      INTO CORRESPONDING FIELDS OF TABLE IT_PRTCTL
      FROM LFA1
      WHERE LIFNR IN ( SELECT LIFNR
                       FROM ZTSTIG3
                       WHERE EPART EQ ZTITRQK-OPNBK ).
    ENDIF.
    DESCRIBE TABLE IT_PRTCTL LINES G_LINE.
    IF G_LINE EQ C_ZERO.
      CLEAR: IT_PRTCTL.
      MOVE: T001-LAND1    TO    IT_PRTCTL-LAND1,
            SY-LANGU      TO    IT_PRTCTL-SPRAS.
      APPEND IT_PRTCTL.
    ENDIF.
  ENDIF.

*> Get Output Paramenters
  PERFORM GET_OUTPUT_INFORMATION TABLES IT_PRTCTL
                                 USING  G_ANSWER.
  IF G_ANSWER EQ C_Y.

    LOOP AT IT_PRTCTL WHERE FLAG EQ C_TRUE.
*> Get SMARTFORM NAME
      PERFORM P7000_SET_SMART_FORM_NAME USING 'IP'
                                              ZTITIP1-AMDSQ
                                              IT_PRTCTL-DOCTY
                                              G_SSF_NAME.
*> GET THE SMART FORM'S FUNCTION MODULE
      PERFORM GET_SMART_FORM_NAME    USING  G_SSF_NAME
                                            G_FUNC_MOD_NAME.

*> Set Output Paramenters
      PERFORM SET_OUTPUT_INFORMATION USING IT_PRTCTL.
*> Call SmartForms functions
      PERFORM CALL_SMARTFORMS_FUNCTIOINS USING G_FUNC_MOD_NAME.
*> Call SmartForms functions
      PERFORM EXEC_EXTERNAL_SENDING USING IT_PRTCTL.
    ENDLOOP.
  ELSE.
    MESSAGE S900.
  ENDIF.

ENDFORM.                    " call_print_process
*&---------------------------------------------------------------------*
*&      Form  SET_OTHERS_FIELDS_BY_ITEMS
*&---------------------------------------------------------------------*
*       아이템의 기타 필드들을 fill
*----------------------------------------------------------------------*
FORM SET_OTHERS_FIELDS_BY_ITEMS .

  DATA: L_EINDT  LIKE EKET-EINDT.

  LOOP AT IT_TAB INTO G_TC_2130_WA.
    IF ZTITIP1-EBELN IS INITIAL.
      ZTITIP1-EBELN = G_TC_2130_WA-EBELN.
    ENDIF.
*> 정가 계산.
    IF G_TC_2130_WA-NETWR IS INITIAL.
      CALL FUNCTION 'Z_TI_CALC_ITEM_AMOUNT'
        EXPORTING
          PEINH = G_TC_2130_WA-PEINH
          BPUMZ = G_TC_2130_WA-BPUMZ
          BPUMN = G_TC_2130_WA-BPUMN
          MENGE = G_TC_2130_WA-RQMNG
          NETPR = G_TC_2130_WA-NETPR
        CHANGING
          NETWR = G_TC_2130_WA-NETWR.
    ENDIF.
*>Get 플랜트명 및 사업장코드.
    IF NOT G_TC_2130_WA-WERKS IS INITIAL.
      SELECT SINGLE NAME1 J_1BBRANCH
        INTO (G_TC_2130_WA-NAME1, G_TC_2130_WA-BUPLA)
        FROM T001W
       WHERE WERKS  EQ  G_TC_2130_WA-WERKS.
    ELSE.
      CLEAR: G_TC_2130_WA-NAME1, G_TC_2130_WA-BUPLA.
    ENDIF.

*>Get 저장위치명.
    IF NOT G_TC_2130_WA-LGORT IS INITIAL.
      SELECT SINGLE LGOBE
        INTO (G_TC_2130_WA-LGOBE)
        FROM T001L
       WHERE WERKS  EQ  G_TC_2130_WA-WERKS
         AND LGORT  EQ  G_TC_2130_WA-LGORT.
    ELSE.
      CLEAR G_TC_2130_WA-LGOBE.
    ENDIF.

*>Get 납품일.
    IF NOT G_TC_2130_WA-EBELN IS INITIAL.
      CLEAR: L_EINDT.
      SELECT MIN( EINDT ) INTO L_EINDT
        FROM EKET
       WHERE EBELN EQ G_TC_2130_WA-EBELN
         AND EBELP EQ G_TC_2130_WA-EBELP.

      IF L_EINDT IS INITIAL.
        CLEAR G_TC_2130_WA-EEIND.
      ELSE.
        WRITE L_EINDT TO G_TC_2130_WA-EEIND.
      ENDIF.
    ENDIF.
    MODIFY IT_TAB FROM G_TC_2130_WA.
  ENDLOOP.

ENDFORM.                    " SET_OTHERS_FIELDS_BY_ITEMS
*&---------------------------------------------------------------------*
*&      Form  get_Import_vendors_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_IMPORT_VENDORS_TEXT USING P_MSGTY.

  IF ZTITRQK-LIFNR IS INITIAL.
    CLEAR: LFA1.
  ELSE.
    SELECT SINGLE * FROM LFA1
     WHERE LIFNR EQ ZTITRQK-LIFNR.
    IF SY-SUBRC NE 0.
      PERFORM MESSAGE_NOT_FOUND_VENDOR USING 'ZTITRQK'
                                             'LIFNR'
                                             P_MSGTY.
    ENDIF.
  ENDIF.

  CLEAR: ZTSTIG3.
  IF NOT ZTITIP1-INSCP IS INITIAL.
    PERFORM  GET_EDI_BUKRS_PARTNER USING  ZTITIP1-BUKRS
                                          ZTITIP1-INSCP
                                          C_CHARP
                                          ZTSTIG3
                                          C_ERROR.
  ENDIF.

ENDFORM.                    " get_Import_vendors_text
*&---------------------------------------------------------------------*
*&      Form  check_lc_sub_document_exist
*&---------------------------------------------------------------------*
*       하위문서 존재여부 체크.
*----------------------------------------------------------------------*
FORM CHECK_LC_SUB_DOCUMENT_EXIST  USING    P_REQNO
                                           P_REQIT
                                           P_MSGTY
                                           P_SUBRC.
  DATA: L_COUNT TYPE I.

  CLEAR: P_SUBRC.

*> 비용문서 체크.
  SELECT COUNT( * )
    INTO L_COUNT
    FROM ZTITCSP
   WHERE EXPGR  EQ  C_CHARI
     AND REFNO  EQ  ZTITIP1-IIPNO
     AND AMDSQ  EQ  ZTITIP1-AMDSQ.

  IF L_COUNT GT 0.
    MESSAGE ID 'ZMTI00' TYPE C_ERROR NUMBER '109' WITH '수입제비용'.
  ENDIF.

**> B/L 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ztitblp
*   WHERE reqno   EQ  p_reqno
*     AND reqit   EQ  p_reqit.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER '109' WITH 'B/L'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.
*
**> 선급금 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ztitivp
*   WHERE reqno   EQ  p_reqno
*     AND reqit   EQ  p_reqit.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER '109' WITH '선급금'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.
*
ENDFORM.                    " check_lc_sub_document_exist
*&---------------------------------------------------------------------*
*&      Form  check_bl_sub_document_exist
*&---------------------------------------------------------------------*
*       하위문서 존재여부 체크.
*----------------------------------------------------------------------*
FORM CHECK_BL_SUB_DOCUMENT_EXIST  USING    P_IBLNO
                                           P_IBLIT
                                           P_MSGTY
                                           P_SUBRC.
*  DATA: l_count TYPE i.
*
*  CLEAR: p_subrc.
*
**> 통관 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ZTItccit
*   WHERE iblno   EQ  p_iblno
*     AND iblit   EQ  p_iblit.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER '109' WITH 'B/L'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.
*
**> L/G 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ZTItlg01
*   WHERE iblno   EQ  p_iblno.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER '109' WITH 'L/G'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.
*
**> 반입예정정보 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ZTItbshd
*   WHERE iblno   EQ  p_iblno.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER '109' WITH '반입예정정보'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.
*
**> 반입정보 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ZTItbihd
*   WHERE iblno   EQ  p_iblno.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER '109' WITH '반입정보'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.
*
**> 반출정보 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ZTItbohd
*   WHERE iblno   EQ  p_iblno.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER '109' WITH '반출정보'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.
*
**> 송장 문서 체크.
*  SELECT COUNT( * ) INTO l_count
*    FROM ZTITIVP
*   WHERE iblno   EQ  p_iblno
*     AND iblit   EQ  p_iblit.
*  IF l_count GT c_zero.
*    IF p_msgty NE c_none.
*      MESSAGE ID 'ZMTI00' TYPE p_msgty NUMBER '109' WITH '선급금'.
*    ENDIF.
*    p_subrc = 4.
*    EXIT.
*  ENDIF.

ENDFORM.                    " check_lc_sub_document_exist

*&---------------------------------------------------------------------*
*&      Form  SET_INITIAL_VALUE
*&---------------------------------------------------------------------*
FORM SET_INITIAL_VALUE .

*> 문서 종류.
  G_DOCUMENT = C_IP.

  REFRESH: IT_TAB, IT_PO, IT_PONUM, G_TC_2210_ITAB.

*> global mode setting
  CASE SY-TCODE.
    WHEN C_DUE_LIST_PO.      G_MODE = 'C'.   ">생성.
    WHEN OTHERS.
  ENDCASE.
*
  CLEAR:   IT_TAB, IT_PO, IT_PONUM,
           ZTITIP1,    ">보험 Header
          *ZTITIP1,    ">보험 Header
           ZTITIP3,
          *ZTITIP3,
           ZTITIP4,
          *ZTITIP4,
           LFA1,
          *LFA1,
           ZTSTIG3,
           W_LFA1,
           W_LFA1_BANK.

ENDFORM.                    " SET_INITIAL_VALUE
*&---------------------------------------------------------------------*
*&      Form  double_click_event
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK_EVENT .

  CHECK G_FIELDNAME IS INITIAL.

  GET CURSOR LINE G_FINDLINE.
  IF SY-SUBRC EQ 0.
    GET CURSOR FIELD G_FIELDNAME.
    IF SY-SUBRC EQ 0.
      G_FINDSCR = SY-DYNNR.
      READ TABLE IT_TAB INTO G_TC_2130_WA INDEX G_FINDLINE.
      IF SY-SUBRC NE 0.
        EXIT.
      ENDIF.
      CHECK OK_CODE EQ 'ZTISELECT'.   ">문서선택.

      CASE G_FIELDNAME.
        WHEN 'ZTISRQIT-EBELN' OR 'ZTISRQIT-EBELP'.
          PERFORM DISPLAY_PURCHASE_ORDER USING G_TC_2130_WA-EBELN
                                               G_TC_2130_WA-EBELP.
        WHEN 'ZTISRQIT-REQNO' OR 'ZTISRQIT-REQIT'.
          SELECT SINGLE AMDSQ
            INTO ZTIVRQ00-AMDSQ
            FROM ZTIVRQ00
           WHERE REQNO  EQ  G_TC_2130_WA-REQNO
             AND REQIT  EQ  G_TC_2130_WA-REQIT.
          IF SY-SUBRC EQ 0.
            PERFORM DISPLAY_IMPORT_DOCUMENT USING G_TC_2130_WA-REQNO
                                                  ZTIVRQ00-AMDSQ
                                                  G_TC_2130_WA-REQIT.
          ENDIF.
        WHEN 'ZTISRQIT-MATNR'.
          PERFORM DISPLAY_MATERIAL_MASTER USING G_TC_2130_WA-MATNR
                                                G_TC_2130_WA-WERKS
                                                G_TC_2130_WA-LGORT.
      ENDCASE.
    ENDIF.
  ELSE.
    GET CURSOR FIELD G_FIELDNAME.
    IF SY-SUBRC EQ 0.
      G_FINDSCR = SY-DYNNR.
      CHECK OK_CODE EQ 'ZTISELECT'.   ">문서선택.

      CASE G_FIELDNAME.
        WHEN 'ZTITBLK-LIFNR'.
          PERFORM DISPLAY_VENDOR_MASTER USING ZTITRQK-LIFNR
                                              ZTITRQK-EKORG.
      ENDCASE.
    ENDIF.
  ENDIF.

ENDFORM.                    " double_click_event
*&---------------------------------------------------------------------*
*&      Form  set_function_by_business
*&---------------------------------------------------------------------*
FORM SET_FUNCTION_BY_BUSINESS .
  CASE SY-DYNNR.
    WHEN C_SCR2000.
      DELETE FTAB
        WHERE FCODE EQ 'ZTIEDI'
           OR FCODE EQ 'ZTIREQUEST'.
    WHEN OTHERS.
  ENDCASE.


  CASE G_TCODE.
    WHEN C_CREATE   OR C_CREATE_BL OR
         C_CREATE_D OR C_CREATE_A  OR                     ">생성.
         C_CHANGE.                                        ">변경.
      IF ZTITIP1-DOCST EQ 'C'.
        MOVE 'ZTIREQUEST'     TO FTAB-FCODE.   APPEND FTAB. ">의뢰.
      ELSE.
        MOVE 'ZTIREQCANC'     TO FTAB-FCODE.   APPEND FTAB. ">취소.
      ENDIF.
    WHEN C_ACCEPTANCE.                                      ">접수.
      IF ZTITIP1-DOCST EQ 'A'.
        MOVE 'ZTIACCEPT'      TO FTAB-FCODE.   APPEND FTAB. ">접수.
      ENDIF.
      IF ZTITIP1-DOCST EQ 'R'.
        MOVE 'ZTIRETURN'      TO FTAB-FCODE.   APPEND FTAB. ">접수.
      ENDIF.
    WHEN C_APPLY.                                           ">개설관리.
      IF ZTITIP1-DOCST EQ 'O'.
        MOVE 'ZTIREQUEST'    TO FTAB-FCODE.   APPEND FTAB. ">접수.
        MOVE 'ZTISEND'       TO FTAB-FCODE.   APPEND FTAB. ">접수.
      ELSE.
        MOVE 'ZTISEND'       TO FTAB-FCODE.   APPEND FTAB. ">접수.
        MOVE 'ZTIRECVC'      TO FTAB-FCODE.   APPEND FTAB. ">접수.
        MOVE 'ZTISENDC'      TO FTAB-FCODE.   APPEND FTAB. "
      ENDIF.
    WHEN C_OPEN.
      IF ZTITIP1-DOCST NE 'O'.
        MOVE 'ZTISENDC'      TO FTAB-FCODE.   APPEND FTAB. ">개설취소.
        MOVE 'ZTIRECVC'      TO FTAB-FCODE.   APPEND FTAB. ">개설취소.
      ENDIF.
      MOVE 'ZTIREQUEST'      TO FTAB-FCODE.   APPEND FTAB. ">의뢰.
      MOVE 'ZTISEND'         TO FTAB-FCODE.   APPEND FTAB. ">의뢰.
    WHEN C_DELETE.
      MOVE 'ZTIREQUEST'      TO FTAB-FCODE.   APPEND FTAB. ">의뢰.
      MOVE 'ZTISEND'         TO FTAB-FCODE.   APPEND FTAB. ">의뢰.
      MOVE 'ZTISENDC'        TO FTAB-FCODE.   APPEND FTAB. ">의뢰.
      MOVE 'ZTIRECVC'        TO FTAB-FCODE.   APPEND FTAB. ">의뢰.
    WHEN OTHERS.
      MOVE 'ZTIREQUEST'      TO FTAB-FCODE.   APPEND FTAB. ">의뢰.
      MOVE 'ZTISEND'         TO FTAB-FCODE.   APPEND FTAB. ">의뢰.
      MOVE 'ZTISENDC'        TO FTAB-FCODE.   APPEND FTAB. ">의뢰.
      MOVE 'ZTIRECVC'        TO FTAB-FCODE.   APPEND FTAB. ">의뢰.
      MOVE 'ZTIDELETE'       TO FTAB-FCODE.   APPEND FTAB. ">의뢰.
  ENDCASE.

  IF ZTITIP1-AMDSQ EQ 0.
    MOVE 'ZTIAMEND'     TO FTAB-FCODE.   APPEND FTAB. ">변경항목.
  ENDIF.

  MOVE 'ZTICOPY1'       TO FTAB-FCODE.   APPEND FTAB. ">변경항목.

ENDFORM.                    " set_function_by_business
*&---------------------------------------------------------------------*
*&      Form  check_request_of_import
*&---------------------------------------------------------------------*
*  수입의뢰문서의 종류/상태를 검증.
*----------------------------------------------------------------------*
FORM CHECK_REQUEST_OF_IMPORT .

  DATA: L_DDTEXT LIKE G_DDTEXT,
        L_REQNO  TYPE ZTIREQNO.

*> 부보대상 조건 체크.
  IF ZTITRQS-INSYN EQ C_CHARN.
    MESSAGE E152 WITH ZTITRQK-REQNO.
  ENDIF.
*> 부보조건 체크.
  SELECT REQNO
    INTO L_REQNO
    FROM ZTITIP1 UP TO 1 ROWS
   WHERE REQNO  EQ  ZTITRQK-REQNO.
  ENDSELECT.
  IF SY-SUBRC EQ 0.
    MESSAGE W153 WITH ZTITRQK-REQNO.
  ENDIF.

  CASE ZTITRQK-REQTY.
    WHEN C_PU OR C_LO.
*> 수입의뢰 종류 Fixed value read.
      PERFORM  DDIC_DOMAIN_VALUE_TEXT_READ USING 'ZTIREQTY'
                                                 SY-LANGU
                                                 ZTITRQK-REQTY
                                                 G_DDTEXT
                                                 C_SUCCESS.
      L_DDTEXT = G_DDTEXT.
      MESSAGE W151 WITH L_DDTEXT.
    WHEN OTHERS.
*> 선급금일 경우.
*      IF NOT ztitrqk-ppaid IS INITIAL.
      IF ZTITRQK-PPAID EQ C_TRUE.
        MESSAGE E150 WITH '선급금'.
      ENDIF.
*> 유보금일 경우.
      IF NOT ZTITRQK-RPAID IS INITIAL.
        MESSAGE E150 WITH '유보금'.
      ENDIF.
  ENDCASE.

ENDFORM.                    " check_request_of_import
*&---------------------------------------------------------------------*
*&      Form  display_import_doc_by_node
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_IMPORT_DOC_BY_NODE  USING    P_NODE_KEY.

  READ TABLE IT_ZTISRQIT INTO G_ZTISRQIT_WA
                         WITH KEY INDEX = P_NODE_KEY(10).
  IF SY-SUBRC EQ 0.
    PERFORM  DISPLAY_IMPORT_DOCUMENT USING G_ZTISRQIT_WA-REQNO
                                           G_ZTISRQIT_WA-AMDSQ
                                           G_ZTISRQIT_WA-REQIT.
  ELSE.
    MESSAGE S903.
  ENDIF.

ENDFORM.                    " display_import_doc_by_node
*&---------------------------------------------------------------------*
*&      Form  set_tree_chosen_item
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_TREE_CHOSEN_ITEM .

ENDFORM.                    " set_tree_chosen_item
*&---------------------------------------------------------------------*
*&      Form  GET_OLD_IP_TABLES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZTITIP1_IIPNO  text
*      -->P_ZTITIP1_AMDSQ  text
*----------------------------------------------------------------------*
FORM GET_OLD_IP_TABLES  USING    P_IIPNO
                                 P_AMDSQ.

*> I/P Table
  SELECT SINGLE *
    INTO OLD_ZTITIP1
    FROM ZTITIP1
   WHERE IIPNO = P_IIPNO
     AND AMDSQ = P_AMDSQ.

  IF SY-SUBRC  NE  0.
    MESSAGE E156 WITH P_IIPNO.
  ENDIF.

*> I/P 배서 Table
  SELECT SINGLE *
    INTO OLD_ZTITIP4
    FROM ZTITIP4
   WHERE IIPNO = P_IIPNO
     AND AMDSQ = P_AMDSQ.

* 부가조건.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE G_TC_2210_ITAB_O
    FROM ZTITIP2
   WHERE IIPNO  EQ P_IIPNO
     AND AMDSQ  EQ P_AMDSQ.

*> I/P 구상관리 Table
  SELECT SINGLE *
    INTO OLD_ZTITIP3
    FROM ZTITIP3
   WHERE IIPNO = P_IIPNO.

ENDFORM.                    " GET_OLD_IP_TABLES
*&---------------------------------------------------------------------*
*&      Form  compare_fields_changed
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM COMPARE_FIELDS_CHANGED .
  DATA: LV_LCNO(35),
        LV_LCNO_O(35),
        LV_IVNO(35),
        LV_IVNO_O(35).

*>송장금액배서여부.
  IF ZTITIP1-IIVAT NE OLD_ZTITIP1-IIVAT.
    ZTITIP4-IIVYN = C_TRUE.
  ELSE.
    ZTITIP4-IIVYN = C_FALSE.
  ENDIF.
*>통관금액배서여부.
  IF ZTITIP1-ICUAT NE OLD_ZTITIP1-ICUAT.
    ZTITIP4-IDUYN = C_TRUE.
  ELSE.
    ZTITIP4-IDUYN = C_FALSE.
  ENDIF.
*>보험료배서여부.
  IF ZTITIP1-ITPA1 NE OLD_ZTITIP1-ITPA1 OR
     ZTITIP1-ITPA2 NE OLD_ZTITIP1-ITPA2 OR
     ZTITIP1-ITPA3 NE OLD_ZTITIP1-ITPA3 OR
     ZTITIP1-ICPAM NE OLD_ZTITIP1-ICPAM OR
     ZTITIP1-IDPAM NE OLD_ZTITIP1-IDPAM OR
     ZTITIP1-IVPAM NE OLD_ZTITIP1-IVPAM OR
     ZTITIP1-ITEAM NE OLD_ZTITIP1-ITEAM.
    ZTITIP4-IINYN = C_TRUE.
  ELSE.
    ZTITIP4-IINYN = C_FALSE.
  ENDIF.
*ZTITIP1-ITPA1
*ITPA1C
*ZTITIP1-ITPA2
*ITPA2C
*ZTITIP1-ITPA3
*ITPA3C
*ZTITIP1-ICPAM
*ICPAMC
*ZTITIP1-IDPAM
*IDPAMC
*ZTITIP1-IVPAM
*IVPAMC
*ZTITIP1-ITEAM
*ITEAMC
*
*>보험금배서여부
  IF ZTITIP1-ITOAT NE OLD_ZTITIP1-ITOAT OR
     ZTITIP1-ICAAT NE OLD_ZTITIP1-ICAAT OR
     ZTITIP1-IDUAT NE OLD_ZTITIP1-IDUAT.
    ZTITIP4-IAMYN = C_TRUE.
  ELSE.
    ZTITIP4-IAMYN = C_FALSE.
  ENDIF.

*ZTITIP1-ITOAT
*ZTITIP1-ITOATC
*ZTITIP1-ICAAT
*ZTITIP1-ICAATC
*ZTITIP1-IDUAT
*ZTITIP1-IDUATC

*>희망이익율배서여부.
  IF ZTITIP1-IWART NE OLD_ZTITIP1-IWART.
    ZTITIP4-IPEYN = C_TRUE.
  ELSE.
    ZTITIP4-IPEYN = C_FALSE.
  ENDIF.

*>관세율 배서여부.
  IF ZTITIP1-ICURT NE OLD_ZTITIP1-ICURT.
    ZTITIP4-IPDYN = C_TRUE.
  ELSE.
    ZTITIP4-IPDYN = C_FALSE.
  ENDIF.

*>>출항일 배서여부.
  IF ZTITIP1-IDPDT NE OLD_ZTITIP1-IDPDT.
    ZTITIP4-IDTYN = C_TRUE.
  ELSE.
    ZTITIP4-IDTYN = C_FALSE.
  ENDIF.

*>Port/Airport 배서여부.
  IF ZTITIP1-ISHCD NE OLD_ZTITIP1-ISHCD OR
     ZTITIP1-ISHNM NE OLD_ZTITIP1-ISHNM OR
     ZTITIP1-ILDCD NE OLD_ZTITIP1-ILDCD OR
     ZTITIP1-ILDNM NE OLD_ZTITIP1-ILDNM OR
     ZTITIP1-ILPCD NE OLD_ZTITIP1-ILPCD OR
     ZTITIP1-ILPNM NE OLD_ZTITIP1-ILPNM OR
     ZTITIP1-ITRCD NE OLD_ZTITIP1-ITRCD OR
     ZTITIP1-ITRNM NE OLD_ZTITIP1-ITRNM.
    ZTITIP4-IPRYN = C_TRUE.
  ELSE.
    ZTITIP4-IPRYN = C_FALSE.
  ENDIF.

  CLEAR : LV_LCNO, LV_LCNO_O,
          LV_IVNO, LV_IVNO_O.

*___L/C 번호
  IF ZTITIP1-IRECD = 'LC'.
    LV_LCNO = ZTITIP1-IRENO.
  ELSEIF ZTITIP1-IRECD2 = 'LC'.
    LV_LCNO = ZTITIP1-IRENO2.
  ELSEIF ZTITIP1-IRECD3 = 'LC'.
    LV_LCNO = ZTITIP1-IRENO3.
  ENDIF.

  IF OLD_ZTITIP1-IRECD = 'LC'.
    LV_LCNO_O = OLD_ZTITIP1-IRENO.
  ELSEIF OLD_ZTITIP1-IRECD2 = 'LC'.
    LV_LCNO_O = OLD_ZTITIP1-IRENO2.
  ELSEIF OLD_ZTITIP1-IRECD3 = 'LC'.
    LV_LCNO_O = OLD_ZTITIP1-IRENO3.
  ENDIF.

*___I/V 번호
  IF ZTITIP1-IRECD = 'IV'.
    LV_IVNO = ZTITIP1-IRENO.
  ELSEIF ZTITIP1-IRECD2 = 'IV'.
    LV_IVNO = ZTITIP1-IRENO2.
  ELSEIF ZTITIP1-IRECD3 = 'IV'.
    LV_IVNO = ZTITIP1-IRENO3.
  ENDIF.

  IF OLD_ZTITIP1-IRECD = 'IV'.
    LV_IVNO_O = OLD_ZTITIP1-IRENO.
  ELSEIF OLD_ZTITIP1-IRECD2 = 'IV'.
    LV_IVNO_O = OLD_ZTITIP1-IRENO2.
  ELSEIF OLD_ZTITIP1-IRECD3 = 'IV'.
    LV_IVNO_O = OLD_ZTITIP1-IRENO3.
  ENDIF.

*>문서번호 배서여부.
  IF LV_LCNO NE LV_LCNO_O OR
     LV_IVNO NE LV_LCNO_O.
    ZTITIP4-IDOYN = C_TRUE.
  ELSE.
    ZTITIP4-IDOYN = C_FALSE.
  ENDIF.

*>운송수단 배서여부.
  IF ZTITIP1-IVSLN NE OLD_ZTITIP1-IVSLN OR
     ZTITIP1-ICARN NE OLD_ZTITIP1-ICARN.
    ZTITIP4-ITMYN = C_TRUE.
  ELSE.
    ZTITIP4-ITMYN = C_FALSE.
  ENDIF.

*>HS Code 배서여부.
  IF ZTITIP1-IHSCD NE OLD_ZTITIP1-IHSCD.
    ZTITIP4-IHSYN  = C_TRUE.
  ELSE.
    ZTITIP4-IHSYN  = C_FALSE.
  ENDIF.

*>상품명세 배서여부.
  IF ZTITIP1-IGOTE1 NE OLD_ZTITIP1-IGOTE1 OR
     ZTITIP1-IGOTE2 NE OLD_ZTITIP1-IGOTE2 OR
     ZTITIP1-IGOTE3 NE OLD_ZTITIP1-IGOTE3 OR
     ZTITIP1-IGOTE4 NE OLD_ZTITIP1-IGOTE4 OR
     ZTITIP1-IGOTE5 NE OLD_ZTITIP1-IGOTE5 OR
     ZTITIP1-IPGNM  NE OLD_ZTITIP1-IPGNM OR
     ZTITIP1-IPGNMU NE OLD_ZTITIP1-IPGNMU.
    ZTITIP4-IGDYN = C_TRUE.
  ELSE.
    ZTITIP4-IGDYN = C_FALSE.
  ENDIF.

*>추가사항 배서여부.
  IF ZTITIP4-ADTX1 NE OLD_ZTITIP4-ADTX1 OR
     ZTITIP4-ADTX2 NE OLD_ZTITIP4-ADTX2 OR
     ZTITIP4-ADTX3 NE OLD_ZTITIP4-ADTX3 OR
     ZTITIP4-ADTX4 NE OLD_ZTITIP4-ADTX4 OR
     ZTITIP4-ADTX5 NE OLD_ZTITIP4-ADTX5.
    ZTITIP4-IADYN = C_TRUE.
  ELSE.
    ZTITIP4-IADYN = C_FALSE.
  ENDIF.

*>Partial 배서여부.
  IF ZTITIP4-FTX01 NE OLD_ZTITIP4-FTX01 OR
     ZTITIP4-FTX02 NE OLD_ZTITIP4-FTX02 OR
     ZTITIP4-FTX03 NE OLD_ZTITIP4-FTX03 OR
     ZTITIP4-FTX04 NE OLD_ZTITIP4-FTX04 OR
     ZTITIP4-FTX05 NE OLD_ZTITIP4-FTX05.
    ZTITIP4-IPAYN = C_TRUE.
  ELSE.
    ZTITIP4-IPAYN = C_FALSE.
  ENDIF.

*>부보조건 배서여부.
  IF G_TC_2210_ITAB[] NE G_TC_2210_ITAB_O[].
    ZTITIP4-ICDYN = C_TRUE.
  ELSE.
    ZTITIP4-ICDYN = C_FALSE.
  ENDIF.

*>질권기관 배서여부.
  IF ZTITIP1-ILCCD NE OLD_ZTITIP1-ILCCD OR
     ZTITIP1-ILCNM NE OLD_ZTITIP1-ILCNM OR
     ZTITIP1-ILCBR NE OLD_ZTITIP1-ILCBR.
    ZTITIP4-IEIYN = C_TRUE.
  ELSE.
    ZTITIP4-IEIYN = C_FALSE.
  ENDIF.

*>>기타유형 배서여부.
  IF ZTITIP1-IASNM1 NE OLD_ZTITIP1-IASNM1 OR  ">피보험자.
     ZTITIP1-IASNM2 NE OLD_ZTITIP1-IASNM2 OR
     ZTITIP1-IAPNM  NE OLD_ZTITIP1-IAPNM  OR  ">보험계약자.
     ZTITIP1-IAPPR  NE OLD_ZTITIP1-IAPPR  OR
     ZTITIP1-IAPSG  NE OLD_ZTITIP1-IAPSG  OR
     ZTITIP1-IAPID  NE OLD_ZTITIP1-IAPID  OR
     ZTITIP1-ICPNM  NE OLD_ZTITIP1-ICPNM  OR  ">손보사.
     ZTITIP1-ICPPR  NE OLD_ZTITIP1-ICPPR  OR
     ZTITIP1-ICPID  NE OLD_ZTITIP1-ICPID  OR
     ZTITIP1-ICSCD  NE OLD_ZTITIP1-ICSCD  OR  ">담당자.
     ZTITIP1-ICSNM  NE OLD_ZTITIP1-ICSNM  OR
     ZTITIP1-IPORN  NE OLD_ZTITIP1-IPORN  OR  ">발급부수.
     ZTITIP1-IISPL  NE OLD_ZTITIP1-IISPL  OR  ">증권발급지.
     ZTITIP1-IISDT  NE OLD_ZTITIP1-IISDT  OR  ">증권발급일.
     ZTITIP1-IIVDT  NE OLD_ZTITIP1-IIVDT  OR  ">Invoice 발행일.
     ZTITIP1-ITPRT  NE OLD_ZTITIP1-ITPRT  OR  ">보험요율
     ZTITIP1-IAJRT  NE OLD_ZTITIP1-IAJRT.     ">적용환율.
    ZTITIP4-IETYN = C_TRUE.
  ELSE.
    ZTITIP4-IETYN = C_FALSE.
  ENDIF.

ENDFORM.                    " compare_fields_changed
*&---------------------------------------------------------------------*
*&      Form  move_req_fields_to_ZTITIP1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MOVE_REQ_FIELDS_TO_ZTITIP1.

  FIELD-SYMBOLS <L_FS>.
  DATA: L_FIELDNAME TYPE FIELDNAME.

  MOVE-CORRESPONDING ZTITRQK TO ZTITIP1.

  IF G_MODE EQ C_CHARC.
    MOVE-CORRESPONDING : ZTITRQK TO ZTITIP1.

    MOVE: ZTITRQS-FLAND   TO ZTITIP1-ISHCD,
          ZTITRQS-PLLOD   TO ZTITIP1-ISHNM,
          ZTITRQS-TLAND   TO ZTITIP1-ILDCD,
          ZTITRQS-PLTRN   TO ZTITIP1-ILDNM,
          SY-DATLO        TO ZTITIP1-TAPDT,
          SY-DATLO        TO ZTITIP1-IOPDT,  ">보험개시일.
          '22'            TO ZTITIP1-ENDCD,
          ZTITRQS-EBELN   TO ZTITIP1-EBELN,
          ZTITRQS-WAERS   TO ZTITIP1-IIVATC,
          ZTITRQS-OPAMT   TO ZTITIP1-IIVAT,
*          ZTITRQS-WAERS   TO ZTITIP1-ITOATC,
*          ZTITRQS-WAERS   TO ZTITIP1-ICAATC,
*          ZTITRQS-WAERS   TO ZTITIP1-IDUATC,
*          T001-WAERS      TO ZTITIP1-ITPA1C,
*          T001-WAERS      TO ZTITIP1-ITPA2C,
*          T001-WAERS      TO ZTITIP1-ITPA3C,
          T001-WAERS      TO ZTITIP1-ICPAMC,
          T001-WAERS      TO ZTITIP1-IDPAMC,
          T001-WAERS      TO ZTITIP1-IVPAMC,
          T001-WAERS      TO ZTITIP1-ITEAMC,
*          3               TO ZTITIP1-IPCON,  ">사본.
*          4               TO ZTITIP1-IPORN,  ">원본.
          'T.B.D'         TO ZTITIP1-IVSLN,
*---> 부보생성 시 Default 값 추가 by MSH
          '110'           TO ZTITIP1-IWART.

    IF ZTITIP1-AMDSQ EQ 0.
      MOVE: 3             TO ZTITIP1-IPCON,  ">사본.
            4             TO ZTITIP1-IPORN.  ">원본.
    ENDIF.

*> 선급금액 누적..
    ZTITIP1-IIVAT = ZTITIP1-IIVAT + ZTITRQS-PPAMT.

*> 회사코드.
    CALL FUNCTION 'Z_TS_GET_COMPANY_EDI_DATA'
      EXPORTING
        BUKRS           = ZTITRQK-BUKRS
        APPCT           = ZTITRQK-APPCT
     IMPORTING
       YZTSTIG0        = ZTSTIG0
*       nztstig0        = ztstig0
       XT001            = T001
     EXCEPTIONS
       NOT_FOUND       = 1
       OTHERS          = 2 .
    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      MESSAGE ID SY-MSGID TYPE C_WARNING  NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    MOVE: ZTSTIG0-INSCP TO ZTITIP1-INSCP,  ">보험회사코드.
          ZTSTIG0-EOMNM TO ZTITIP1-IASNM1, ">피보험자.
          ZTSTIG0-EOMPR TO ZTITIP1-IASNM2, ">피보험자.
          ZTSTIG0-BUSID TO ZTITIP1-IAPID,  ">보험계약자.
          ZTSTIG0-EOMNM TO ZTITIP1-IAPNM,  "> ** 상호.
          ZTSTIG0-EOMPR TO ZTITIP1-IAPPR,  "> ** 대표자.
          ZTSTIG0-ESIGN TO ZTITIP1-IAPSG,  "> ** 전자서명.
          T001-WAERS     TO ZTITIP1-ICUATC. ">
*          T001-WAERS     TO ZTITIP1-ICAATC,
*          T001-WAERS     TO ZTITIP1-IDUATC.

*> Set 보험회사 관련 Default value
    IF NOT ZTITIP1-INSCP IS INITIAL.
      SELECT SINGLE *
        FROM ZTSTIG3
       WHERE PARTI   EQ   C_CHARP
         AND EPART   EQ   ZTITIP1-INSCP
*>by YSH(070817) 회사코드 추가
         AND BUKRS   EQ   ZTITIP1-BUKRS.

      IF SY-SUBRC EQ 0.
        MOVE: ZTSTIG3-IOPNO  TO ZTITIP1-IOPNO,
              ZTSTIG3-ICSNM  TO ZTITIP1-ICSNM,
              ZTSTIG3-EPART  TO ZTITIP1-RECID,
              ZTSTIG3-NAMET  TO ZTITIP1-RECNM,
              SPACE          TO ZTITIP1-DOCST,
              '9'            TO ZTITIP1-RECTR,
              'AB'           TO ZTITIP1-RECAS,
              ZTSTIG3-IWART  TO ZTITIP1-IWART, ">희망이익율.
              ZTSTIG3-ITOCP  TO ZTITIP1-ITOCP, ">공동인수사.
              ZTSTIG3-ITORT  TO ZTITIP1-ITORT, ">공동인수율.
              ZTSTIG3-NAMET  TO ZTITIP1-ICPNM,
*              TO ZTITIP1-ICPPR,
              ZTSTIG3-ESIGN  TO ZTITIP1-ICPID.
      ENDIF.
    ENDIF.

    LOOP AT IT_TAB INTO G_TC_2130_WA.
      IF ZTITIP1-EBELN IS INITIAL.
        MOVE G_TC_2130_WA-EBELN TO ZTITIP1-EBELN.           ">상품명세1
      ENDIF.
      IF ZTITIP1-IGOTE1 IS INITIAL.
        MOVE G_TC_2130_WA-TXZ01 TO ZTITIP1-IGOTE1.          ">상품명세1
      ENDIF.
      IF ZTITIP1-IHSCD IS INITIAL.
        MOVE G_TC_2130_WA-STAWN TO ZTITIP1-IHSCD.  ">>H/S Code
      ENDIF.
      IF ZTITIP1-EBELN IS INITIAL.
        ZTITIP1-EBELN = G_TC_2130_WA-EBELN.
      ENDIF.
    ENDLOOP.

    CASE ZTITRQK-REQTY.
      WHEN 'LC'.
        MOVE: ZTITRQK-REQTY  TO ZTITIP1-IRECD2,
              ZTITRQS-OPNNO  TO ZTITIP1-IRENO2.
      WHEN 'TT'.
      WHEN 'PU'.
      WHEN 'LO'.
      WHEN 'DA'.
      WHEN 'DP'.
    ENDCASE.

    MOVE: 'POR'          TO ZTITIP1-IRECD,
          ZTITIP1-EBELN  TO ZTITIP1-IRENO.

*> 보험회사 코드.
    IF NOT ZTITIP1-INSCP IS INITIAL.
      SELECT SINGLE *
        FROM ZTSTIG3
       WHERE PARTI EQ C_CHARP
         AND EPART EQ ZTITIP1-INSCP.
    ENDIF.


    IF NOT ZTITRQS-ITECD IS INITIAL AND ZTITIP1-AMDSQ EQ 0.
      SELECT SINGLE *
        INTO CORRESPONDING FIELDS OF G_TC_2210_WA
        FROM ZTSTIG4
       WHERE ITECD  EQ  ZTITRQS-ITECD.
      IF SY-SUBRC <> 0 .
        SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF G_TC_2210_WA
          FROM ZTSTIG4
         WHERE ITECD_OLD  EQ  ZTITRQS-ITECD.
      ENDIF.
      G_TC_2210_WA-ITETY = C_CHARB.
      APPEND G_TC_2210_WA TO G_TC_2210_ITAB.
    ENDIF.

*> 복사할 구매오더 헤더상의 부보필드.

    SELECT SINGLE *
      FROM ZTITIG30.

    CHECK SY-SUBRC EQ 0.

    SELECT SINGLE *
      FROM EKKO
     WHERE EBELN EQ ZTITIP1-EBELN.

    IF NOT ( ZTITIG30-ITECD  IS INITIAL AND
             ZTITIG30-ITECD1 IS INITIAL AND
             ZTITIG30-ITECD2 IS INITIAL AND
             ZTITIG30-ITECD3 IS INITIAL ).
      REFRESH: G_TC_2210_ITAB.
    ENDIF.
*> 복사규칙 Select.

    IF NOT ZTITIG30-ITECD IS INITIAL.

      CONCATENATE 'EKKO-' ZTITIG30-ITECD INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-ZZOFFER'.
      ASSIGN (L_FIELDNAME) TO <L_FS>.
      IF SY-SUBRC     EQ 0        AND
         NOT <L_FS>   IS INITIAL.
        SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF G_TC_2210_WA
          FROM ZTSTIG4
         WHERE ITECD  EQ  <L_FS>.

        IF SY-SUBRC EQ 0.
          G_TC_2210_WA-ITETY = C_CHARB.
          APPEND G_TC_2210_WA TO G_TC_2210_ITAB.
        ENDIF.
      ENDIF.
    ENDIF.
    IF NOT ZTITIG30-ITECD1 IS INITIAL.
      CONCATENATE 'EKKO-' ZTITIG30-ITECD1 INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-ZZOFFER'.
      ASSIGN (L_FIELDNAME) TO <L_FS>.
      IF SY-SUBRC     EQ 0        AND
         NOT <L_FS>   IS INITIAL.
        SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF G_TC_2210_WA
          FROM ZTSTIG4
         WHERE ITECD  EQ  <L_FS>.

        IF SY-SUBRC EQ 0.
          G_TC_2210_WA-ITETY = C_CHARA.
          APPEND G_TC_2210_WA TO G_TC_2210_ITAB.
        ENDIF.
      ENDIF.
    ENDIF.
    IF NOT ZTITIG30-ITECD2 IS INITIAL.
      CONCATENATE 'EKKO-' ZTITIG30-ITECD2 INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-ZZOFFER'.
      ASSIGN (L_FIELDNAME) TO <L_FS>.
      IF SY-SUBRC     EQ 0        AND
         NOT <L_FS>   IS INITIAL.
        SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF G_TC_2210_WA
          FROM ZTSTIG4
         WHERE ITECD  EQ  <L_FS>.

        IF SY-SUBRC EQ 0.
          G_TC_2210_WA-ITETY = C_CHARA.
          APPEND G_TC_2210_WA TO G_TC_2210_ITAB.
        ENDIF.
      ENDIF.
    ENDIF.
    IF NOT ZTITIG30-ITECD3 IS INITIAL.
      CONCATENATE 'EKKO-' ZTITIG30-ITECD3 INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-ZZOFFER'.
      ASSIGN (L_FIELDNAME) TO <L_FS>.
      IF SY-SUBRC     EQ 0        AND
         NOT <L_FS>   IS INITIAL.
        SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF G_TC_2210_WA
          FROM ZTSTIG4
         WHERE ITECD  EQ  <L_FS>.

        IF SY-SUBRC EQ 0.
          G_TC_2210_WA-ITETY = C_CHARA.
          APPEND G_TC_2210_WA TO G_TC_2210_ITAB.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR: G_COUNT.
  LOOP AT  G_TC_2210_ITAB INTO G_TC_2210_WA.
    ADD 1 TO G_COUNT.
    G_TC_2210_WA-ITESQ = G_COUNT.
    MODIFY G_TC_2210_ITAB FROM G_TC_2210_WA.
  ENDLOOP.

ENDFORM.                    " move_req_fields_to_ZTITIP1
*&---------------------------------------------------------------------*
*&      Form  SET_EDI_PARTNER_FIELD
*&---------------------------------------------------------------------*
*> EDI Partner관련 필드 Reset.
*----------------------------------------------------------------------*
FORM SET_EDI_PARTNER_FIELD .

  CHECK : G_MODE EQ C_CHARY OR
          G_MODE EQ C_CHARO OR
          G_MODE EQ C_CHARC.

  MOVE: ZTSTIG3-IOPNO TO ZTITIP1-IOPNO,
        ZTSTIG3-ICSNM TO ZTITIP1-ICSNM,
        ZTSTIG3-EPART TO ZTITIP1-RECID,
        ZTSTIG3-NAMET TO ZTITIP1-RECNM,
*        ztstig3-iwart TO ztitip1-iwart, ">희망이익율.
*        ztstig3-itocp TO ztitip1-itocp, ">공동인수사.
*        ztstig3-itort TO ztitip1-itort, ">공동인수율.
        ZTSTIG3-NAMET TO ZTITIP1-ICPNM,
        ZTSTIG3-ESIGN TO ZTITIP1-ICPID.

ENDFORM.                    " SET_EDI_PARTNER_FIELD
*&---------------------------------------------------------------------*
*&      Form  display_amendent_fields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_AMENDENT_FIELDS .

  REFRESH: IT_AMEND_FIELDS.

*> Amount 구분자.
*--------> 금액.
  IF ZTITIP4-IIVYN = C_TRUE.
    PERFORM  FILL_AMENDENT_FILED USING :
           'ZTITIP1-IIVAT' 'OLD_ZTITIP1-IIVAT' 'C' ZTITIP1-IIVATC ''.
  ENDIF.

*-------->>통관금액배서여부.
  IF ZTITIP4-IDUYN = C_TRUE.
    PERFORM  FILL_AMENDENT_FILED USING :
           'ZTITIP1-ICUAT' 'OLD_ZTITIP1-ICUAT' 'C' ZTITIP1-ICUATC ''.
  ENDIF.

*-------->>보험료배서여부.
  IF ZTITIP4-IINYN = C_TRUE.
    PERFORM  FILL_AMENDENT_FILED USING :
           'ZTITIP1-ITPA1' 'OLD_ZTITIP1-ITPA1' 'C' ZTITIP1-ITPA1C ''.
  ENDIF.

*-------->>보험료배서여부.
  IF ZTITIP4-IAMYN = C_TRUE.
    PERFORM  FILL_AMENDENT_FILED USING :
           'ZTITIP1-ITOAT' 'OLD_ZTITIP1-ITOAT' 'C' ZTITIP1-ITOATC ''.
  ENDIF.

*-------->>희망이익율배서여부.
  IF ZTITIP4-IPEYN = C_TRUE.
    PERFORM  FILL_AMENDENT_FILED USING :
           'ZTITIP1-IWART' 'OLD_ZTITIP1-IWART' 'N' '' ''.
  ENDIF.
*-------->>관세율 배서여부.
  IF ZTITIP4-IPDYN = C_TRUE.
    PERFORM  FILL_AMENDENT_FILED USING :
           'ZTITIP1-ICURT' 'OLD_ZTITIP1-ICURT' 'N' '' ''.
  ENDIF.
**-------->>부보조건 배서여부.
*    IF ZTITIP4-icdyn = c_true.
*      g_tc_2210_itab[] NE g_tc_2210_itab_o[].
*    ENDIF.
*

*-------->>출항일 배서여부.
  IF ZTITIP4-IDTYN = C_TRUE.
    PERFORM  FILL_AMENDENT_FILED USING :
           'ZTITIP1-IDPDT' 'OLD_ZTITIP1-IDPDT' 'D' '' ''.
  ENDIF.

*-------->>PORT/AIRPORT 배서여부.
  IF ZTITIP4-IPRYN = C_TRUE.
    IF ZTITIP1-ISHCD NE OLD_ZTITIP1-ISHCD.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-ISHCD' 'OLD_ZTITIP1-ISHCD' '' '' ''.
    ENDIF.
    IF ZTITIP1-ISHNM NE OLD_ZTITIP1-ISHNM.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-ISHNM' 'OLD_ZTITIP1-ISHNM' '' '' ''.
    ENDIF.
    IF ZTITIP1-ILDCD NE OLD_ZTITIP1-ILDCD.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-ILDCD' 'OLD_ZTITIP1-ILDCD' '' '' ''.
    ENDIF.
    IF ZTITIP1-ILDNM NE OLD_ZTITIP1-ILDNM.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-ILDNM' 'OLD_ZTITIP1-ILDNM' '' '' ''.
    ENDIF.
    IF ZTITIP1-ILPCD NE OLD_ZTITIP1-ILPCD.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-ILPCD' 'OLD_ZTITIP1-ILPCD' '' '' ''.
    ENDIF.
    IF ZTITIP1-ILPNM NE OLD_ZTITIP1-ILPNM.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-ILPNM' 'OLD_ZTITIP1-ILPNM' '' '' ''.
    ENDIF.
    IF ZTITIP1-ITRCD NE OLD_ZTITIP1-ITRCD.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-ITRCD' 'OLD_ZTITIP1-ITRCD' '' '' ''.
    ENDIF.
    IF ZTITIP1-ITRNM NE OLD_ZTITIP1-ITRNM.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-ITRNM' 'OLD_ZTITIP1-ITRNM' '' '' ''.
    ENDIF.
  ENDIF.

*-------->>문서번호 배서여부.
  IF ZTITIP4-IDOYN = C_TRUE.
    IF ZTITIP1-IRECD NE OLD_ZTITIP1-IRECD.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-IRECD' 'OLD_ZTITIP1-IRECD' '' '' ''.
    ENDIF.
    IF ZTITIP1-IRENO NE OLD_ZTITIP1-IRENO.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-IRENO' 'OLD_ZTITIP1-IRENO' '' '' ''.
    ENDIF.
  ENDIF.

*-------->>운송수단 배서여부.
  IF ZTITIP4-ITMYN = C_TRUE.
    IF ZTITIP1-IVSLN NE OLD_ZTITIP1-IVSLN.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-IVSLN' 'OLD_ZTITIP1-IVSLN' '' '' ''.

    ENDIF.
    IF ZTITIP1-ICARN NE OLD_ZTITIP1-ICARN.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-ICARN' 'OLD_ZTITIP1-ICARN' '' '' ''.
    ENDIF.
  ENDIF.

*-------->>HS CODE 배서여부.
  IF ZTITIP4-IHSYN  = C_TRUE.
    PERFORM  FILL_AMENDENT_FILED USING :
           'ZTITIP1-IHSCD' 'OLD_ZTITIP1-IHSCD' '' '' ''.
  ENDIF.

*-------->>상품명세 배서여부.
  IF ZTITIP4-IGDYN = C_TRUE.
    IF ZTITIP1-IGOTE1 NE OLD_ZTITIP1-IGOTE1.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-IGOTE1' 'OLD_ZTITIP1-IGOTE1' '' '' ''.
    ENDIF.
    IF ZTITIP1-IGOTE2 NE OLD_ZTITIP1-IGOTE2.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-IGOTE2' 'OLD_ZTITIP1-IGOTE2' '' '' ''.
    ENDIF.
    IF ZTITIP1-IGOTE3 NE OLD_ZTITIP1-IGOTE3.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-IGOTE3' 'OLD_ZTITIP1-IGOTE3' '' '' ''.
    ENDIF.
    IF ZTITIP1-IGOTE4 NE OLD_ZTITIP1-IGOTE4.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-IGOTE4' 'OLD_ZTITIP1-IGOTE4' '' '' ''.
    ENDIF.
    IF ZTITIP1-IGOTE5 NE OLD_ZTITIP1-IGOTE5.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-IGOTE5' 'OLD_ZTITIP1-IGOTE5' '' '' ''.
    ENDIF.

    IF ZTITIP1-IPGNM  NE OLD_ZTITIP1-IPGNM OR
       ZTITIP1-IPGNMU NE OLD_ZTITIP1-IPGNMU.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-IPGNM' 'OLD_ZTITIP1-IPGNM'
             'Q' ZTITIP1-IPGNMU ''.
    ENDIF.
  ENDIF.

*-------->>PARTIAL 배서여부.
  IF ZTITIP4-IPAYN = C_TRUE.
    IF ZTITIP4-ADTX1 NE OLD_ZTITIP4-ADTX1.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP4-ADTX1' 'OLD_ZTITIP4-ADTX1' '' '' ''.
    ENDIF.

    IF ZTITIP4-ADTX2 NE OLD_ZTITIP4-ADTX2.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP4-ADTX2' 'OLD_ZTITIP4-ADTX2' '' '' ''.
    ENDIF.
    IF ZTITIP4-ADTX3 NE OLD_ZTITIP4-ADTX3.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP4-ADTX3' 'OLD_ZTITIP4-ADTX3' '' '' ''.
    ENDIF.
    IF ZTITIP4-ADTX4 NE OLD_ZTITIP4-ADTX4.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP4-ADTX4' 'OLD_ZTITIP4-ADTX4' '' '' ''.
    ENDIF.
    IF ZTITIP4-ADTX5 NE OLD_ZTITIP4-ADTX5.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP4-ADTX5' 'OLD_ZTITIP4-ADTX5' '' '' ''.
    ENDIF.
  ENDIF.

*-------->>추가사항 배서여부.
  IF ZTITIP4-IADYN = C_TRUE.
    IF ZTITIP4-FTX01 NE OLD_ZTITIP4-FTX01.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP4-FTX01' 'OLD_ZTITIP4-FTX01' '' '' ''.
    ENDIF.
    IF ZTITIP4-FTX02 NE OLD_ZTITIP4-FTX02.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP4-FTX02' 'OLD_ZTITIP4-FTX02' '' '' ''.
    ENDIF.
    IF ZTITIP4-FTX03 NE OLD_ZTITIP4-FTX03.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP4-FTX03' 'OLD_ZTITIP4-FTX03' '' '' ''.
    ENDIF.
    IF ZTITIP4-FTX04 NE OLD_ZTITIP4-FTX04.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP4-FTX04' 'OLD_ZTITIP4-FTX04' '' '' ''.
    ENDIF.
    IF ZTITIP4-FTX05 NE OLD_ZTITIP4-FTX05.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP4-FTX05' 'OLD_ZTITIP4-FTX05' '' '' ''.
    ENDIF.
  ENDIF.

*-------->>질권기관 배서여부.
  IF ZTITIP4-IEIYN = C_TRUE.
    IF ZTITIP1-ILCCD NE OLD_ZTITIP1-ILCCD.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-ILCCD' 'OLD_ZTITIP1-ILCCD' '' '' ''.
    ENDIF.
    IF ZTITIP1-ILCNM NE OLD_ZTITIP1-ILCNM.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-ILCNM' 'OLD_ZTITIP1-ILCNM' '' '' ''.
    ENDIF.
    IF ZTITIP1-ILCBR NE OLD_ZTITIP1-ILCBR.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-ILCBR' 'OLD_ZTITIP1-ILCBR' '' '' ''.
    ENDIF.
  ENDIF.

*-------->>기타유형 배서여부.
  IF ZTITIP4-IETYN = C_TRUE.
    IF ZTITIP1-IASNM1 NE OLD_ZTITIP1-IASNM1.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-IASNM1' 'OLD_ZTITIP1-IASNM1' '' '' ''.
    ENDIF.
    IF ZTITIP1-IASNM2 NE OLD_ZTITIP1-IASNM2.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-IASNM2' 'OLD_ZTITIP1-IASNM2' '' '' ''.
    ENDIF.
    IF ZTITIP1-IAPNM  NE OLD_ZTITIP1-IAPNM.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-IAPNM' 'OLD_ZTITIP1-IAPNM' '' '' ''.
    ENDIF.
    IF ZTITIP1-IAPPR  NE OLD_ZTITIP1-IAPPR.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-IAPPR' 'OLD_ZTITIP1-IAPPR' '' '' ''.
    ENDIF.
    IF ZTITIP1-IAPSG  NE OLD_ZTITIP1-IAPSG.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-IAPSG' 'OLD_ZTITIP1-IAPSG' '' '' ''.
    ENDIF.
    IF ZTITIP1-IAPID  NE OLD_ZTITIP1-IAPID.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-IAPID' 'OLD_ZTITIP1-IAPID' '' '' ''.
    ENDIF.
    IF ZTITIP1-ICPNM  NE OLD_ZTITIP1-ICPNM.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-ICPNM' 'OLD_ZTITIP1-ICPNM' '' '' ''.
    ENDIF.
    IF ZTITIP1-ICPPR  NE OLD_ZTITIP1-ICPPR.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-ICPPR' 'OLD_ZTITIP1-ICPPR' '' '' ''.
    ENDIF.
    IF ZTITIP1-ICPID  NE OLD_ZTITIP1-ICPID.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-ICPID' 'OLD_ZTITIP1-ICPID' '' '' ''.
    ENDIF.
    IF ZTITIP1-ICSCD  NE OLD_ZTITIP1-ICSCD.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-ICSCD' 'OLD_ZTITIP1-ICSCD' '' '' ''.
    ENDIF.
    IF ZTITIP1-ICSNM  NE OLD_ZTITIP1-ICSNM.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-ICSNM' 'OLD_ZTITIP1-ICSNM' '' '' ''.
    ENDIF.
    IF ZTITIP1-IPORN  NE OLD_ZTITIP1-IPORN.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-IPORN' 'OLD_ZTITIP1-IPORN' '' '' ''.
    ENDIF.
    IF ZTITIP1-IISPL  NE OLD_ZTITIP1-IISPL.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-IISPL' 'OLD_ZTITIP1-IISPL' '' '' ''.
    ENDIF.
    IF ZTITIP1-IISDT  NE OLD_ZTITIP1-IISDT.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-IISDT' 'OLD_ZTITIP1-IISDT' '' '' ''.
    ENDIF.
    IF ZTITIP1-IIVDT  NE OLD_ZTITIP1-IIVDT.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-IIVDT' 'OLD_ZTITIP1-IIVDT' '' '' ''.
    ENDIF.
    IF ZTITIP1-ITPRT  NE OLD_ZTITIP1-ITPRT.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-ITPRT' 'OLD_ZTITIP1-ITPRT' '' '' ''.
    ENDIF.
    IF ZTITIP1-IAJRT  NE OLD_ZTITIP1-IAJRT.
      PERFORM  FILL_AMENDENT_FILED USING :
             'ZTITIP1-IAJRT' 'OLD_ZTITIP1-IAJRT' '' '' ''.
    ENDIF.
  ENDIF.

*> 변경 내역 display.
  CALL FUNCTION 'Z_TI_DISPLAY_AMENDENT_FIELDS'
    TABLES
      IT_ZTISAMENDFID = IT_AMEND_FIELDS
    EXCEPTIONS
      NO_DATA         = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " display_amendent_fields

*&---------------------------------------------------------------------*
*&      Form  get_longtext_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_LONGTEXT_DATA .

*> Partner Text
  PERFORM  P1000_GET_TEXTID_AND_TEXT USING ZTITIP1+3(12)
                                           C_TEXTOBJECT_HEADER
                                           C_SCR0100
                                           C_TRUE
                                           C_FALSE.

ENDFORM.                    " get_longtext_data
*&---------------------------------------------------------------------*
*&      Form  build_query_factories_class
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUILD_QUERY_FACTORIES_CLASS .

  CALL FUNCTION 'Z_TI_GET_REQ_OF_IMPORT_QUERY'
    IMPORTING
      EX_FACTORY = G_DATABLADE.
*
ENDFORM.                    " build_query_factories_class

*&---------------------------------------------------------------------*
*&      Form  OTHER_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM OTHER_FUNCTIONS .

  CASE OK_CODE.
    WHEN 'ZTIREQUEST' OR 'ZTISEND'.  ">부보의뢰.
      PERFORM  CALL_OTHERS_TRANSACTION  USING   C_CHARI
                                                C_DELETE
                                                C_FALSE
                                                C_FALSE.
    WHEN 'ZTISENDC'.   ">신청취소.
      PERFORM  CALL_OTHERS_TRANSACTION  USING   C_CHARF
                                                C_DELETE
                                                C_FALSE
                                                C_FALSE.
    WHEN 'ZTIRECVC'.   ">부보취소.
      PERFORM  CALL_OTHERS_TRANSACTION  USING   C_CHARN
                                                C_DELETE
                                                C_FALSE
                                                C_FALSE.
    WHEN 'ZTIAMEND'.    ">변경데이타 확인.
      PERFORM  DISPLAY_AMENDENT_FIELDS.
    WHEN 'ZTIEDI'.      ">EDI 화면으로 이동.
*> Set 문서별 EDI Default value
      PERFORM SET_EDI_DEFAULT_VALUE.
*> EDI Main 화면으로 이동.
      SET SCREEN C_SCR2200.
    WHEN 'ZTICHDOC'.    ">변경문서.
      G_OBJEKT   = 'ZTIIPCHDOC'.
      G_OBJEKTID = ZTITIP1+3(12).
      PERFORM DISPLAY_CHANGE_DOCUMENT USING G_OBJEKT
                                            G_OBJEKTID.
    WHEN 'ZTIMK03'.     ">공급업체.
      PERFORM DISPLAY_VENDOR_MASTER USING ZTITRQK-LIFNR
                                          ZTITRQK-EKORG.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " OTHER_FUNCTIONS

*&---------------------------------------------------------------------*
*&      Form  BEFORE_TRANSPORT_PAI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BEFORE_TRANSPORT_PAI .

*> 이전 값과 비교하여 change 구분자를 설정함.
  IF G_MODE NE C_CHARS.
    READ TABLE IT_TAB INTO G_TC_2130_WA INDEX 1.
    ZTITIP1-EBELN = G_TC_2130_WA-EBELN.
    ZTITIP1-WERKS = G_TC_2130_WA-WERKS.
    SELECT SINGLE J_1BBRANCH
      INTO ZTITIP1-BUPLA
      FROM T001W
     WHERE WERKS EQ ZTITIP1-WERKS.
  ENDIF.

  IF ZTITIP1-AMDSQ GT C_ZERO.
    PERFORM  COMPARE_FIELDS_CHANGED.
  ENDIF.

ENDFORM.                    " BEFORE_TRANSPORT_PAI
*&---------------------------------------------------------------------*
*&      Form  p1001_initialization
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P1001_INITIALIZATION .

  SET TITLEBAR 'T1000'.

* PRINTING SETTINGS
  GS_LAYOUT-GET_SELINFOS      = 'X'.
  GS_LAYOUT-GROUP_CHANGE_EDIT = 'X'.
  GS_LAYOUT-NO_VLINE          = C_CHAR1.


  GS_PRINT-NO_PRINT_SELINFOS  = 'X'.
  GS_PRINT-NO_COVERPAGE       = 'X'.
  GS_PRINT-NO_PRINT_LISTINFOS = 'X'.

ENDFORM.                    " p1001_initialization
*&---------------------------------------------------------------------*
*&      Form  p1100_check_input_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P1100_CHECK_INPUT_VALUES .

  DATA: L_BUKRS   LIKE T001-BUKRS,
        L_WERKS   LIKE T001W-WERKS,
        L_MATNR   LIKE MARA-MATNR,
        L_MTART   LIKE T134-MTART,
        L_EBELN   LIKE EKKO-EBELN,
        L_LIFNR   LIKE LFA1-LIFNR,
        L_EKORG   LIKE T024E-EKORG,
        L_EKGRP   LIKE T024-EKGRP.

* Company code
  SELECT BUKRS INTO (L_BUKRS)
               FROM T001 UP TO 1 ROWS WHERE BUKRS IN S_BUKRS.
  ENDSELECT.
  IF SY-SUBRC <> 0.
    PERFORM GET_FTEXT(RDDFIE00) USING 'T001' 'BUKRS' SY-LANGU
                                CHANGING DFIES G_SUBRC.
    SET CURSOR FIELD 'S_BUKRS-LOW'.
    MESSAGE E348(M7) WITH DFIES-SCRTEXT_M.
  ENDIF.

* Vendor
  READ TABLE S_LIFNR INDEX 1 TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    SELECT LIFNR INTO (L_LIFNR)
                 FROM LFB1 UP TO 1 ROWS WHERE LIFNR IN S_LIFNR
                                        AND   BUKRS IN S_BUKRS.
    ENDSELECT.
    IF SY-SUBRC <> 0.
      PERFORM GET_FTEXT(RDDFIE00) USING 'LFA1' 'LIFNR' SY-LANGU
                                  CHANGING DFIES G_SUBRC.
      SET CURSOR FIELD 'S_LIFNR-LOW'.
      MESSAGE E348(M7) WITH DFIES-SCRTEXT_M.
    ENDIF.
  ENDIF.

* Purchase Organization
  READ TABLE S_EKORG INDEX 1 TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    SELECT EKORG INTO (L_EKORG)
                 FROM T024E UP TO 1 ROWS WHERE EKORG IN S_EKORG.
    ENDSELECT.
    IF SY-SUBRC <> 0.
      PERFORM GET_FTEXT(RDDFIE00) USING 'T024E' 'EKORG' SY-LANGU
                                  CHANGING DFIES G_SUBRC.
      SET CURSOR FIELD 'S_EKORG-LOW'.
      MESSAGE E348(M7) WITH DFIES-SCRTEXT_M.
    ENDIF.
  ENDIF.

* Purchase GROUP
  READ TABLE S_EKGRP INDEX 1 TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    SELECT EKGRP INTO (L_EKGRP)
                 FROM T024 UP TO 1 ROWS WHERE EKGRP IN S_EKGRP.
    ENDSELECT.
    IF SY-SUBRC <> 0.
      PERFORM GET_FTEXT(RDDFIE00) USING 'T024' 'EKGRP' SY-LANGU
                                  CHANGING DFIES G_SUBRC.
      SET CURSOR FIELD 'S_EKGRP-LOW'.
      MESSAGE E348(M7) WITH DFIES-SCRTEXT_M.
    ENDIF.
  ENDIF.

ENDFORM.                    " p1100_check_input_values
*&---------------------------------------------------------------------*
*&      Form  clearing_work_area
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CLEARING_WORK_AREA .

  FREE:  XLFA1.
  CLEAR: XLFA1.

  IF P_FULL EQ 'X'.
    ALV_DETAIL_FUNC = 'REUSE_ALV_GRID_DISPLAY'.
  ELSE.
    ALV_DETAIL_FUNC = 'REUSE_ALV_LIST_DISPLAY'.
  ENDIF.

ENDFORM.                    " clearing_work_area
*&---------------------------------------------------------------------*
*&      Form  set_fieldcat_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_FIELDCAT_BUILD .

  DATA: COLOR TYPE SLIS_T_SPECIALCOL_ALV WITH HEADER LINE.

  FREE : FC.  CLEAR: FC.

  AC 'ITAB   BOX   ZTISRQIT                     FLAG  X'.
*대표PO       ZTISRQIT-EBELN
  AC 'ITAB   EBELN ZTISRQIT                     EBELN '.
*수입요청 문서
  AC 'ITAB   REQNO ZTITRQS                      REQNO '.
  AC 'ITAB   AMDSQ ZTITRQS                      AMDSQ '.
  AC 'ITAB   REQTY ZTITRQK                      REQTY '.
*문서상태
  AC 'ITAB   DOCST ZTITRQS                      DOCST '.
  AC 'ITAB   DDTEXTDD07T                        DDTEXT'.
*L/C NO       ZTITRQS-OPNNO
  AC 'ITAB   OPNNO ZTITRQS                      OPNNO '.
*공사번호     ZTITRQK-PSPNR
  AC 'ITAB   PSPNR ZTITRQK                      PSPNR '.
*OPEN금액통화 ZTITRQS-WAERS
  AC 'ITAB   WAERS ZTITRQS                      WAERS '.
*OPEN금액     ZTITRQS-OPAMT
  AC 'ITAB   OPAMT ZTITRQS                      OPAMT  CWAERS '.
*선급금액     ZTITRQS-PPAMT
  AC 'ITAB   PPAMT ZTITRQS                      PPAMT  CWAERS '.
*품명         ZTISRQIT-TXZ01
  AC 'ITAB   TXZ01 ZTISRQIT                     TXZ01 '.
*LC OPEN일자  ZTITRQS-OPNDT
  AC 'ITAB   OPNDT ZTITRQS                      OPNDT '.
*선적지       ZTITRQS-PLLOD
  AC 'ITAB   PLLOD ZTITRQS                      PLLOD '.
*도착지       ZTITRQS-PLTRN
  AC 'ITAB   PLTRN ZTITRQS                      PLTRN '.
*  ac 'ITAB   LIFNR ZTITRQK                     LIFNR '.
*  ac 'ITAB   NAME1 LFA1                         NAME1 '.
*  ac 'ITAB   OPAMT ZTITRQS                     OPAMT  CWAERS '.
*  ac 'ITAB   WAERS ZTITRQS                     WAERS '.
*  ac 'ITAB   USAMT ZTITRQS                     USAMT  CUCURR '.
*  ac 'ITAB   UCURR ZTITRQS                     UCURR '.
*  ac 'ITAB   ZTERM ZTITRQS                     ZTERM '.
*  ac 'ITAB   REQDT ZTITRQS                     REQDT '.
*  ac 'ITAB   INCO1 ZTITRQS                     INCO1 '.


*L/C NO       ZTITRQS-OPNNO
*보험사제출일
*공사번호     ZTITRQK-PSPNR
*OPEN금액통화 ZTITRQS-WAERS
*OPEN금액     ZTITRQS-OPAMT
*보험료(원화)
*보험회사
*부보조건
*보험요율
*부보일자
*전표번호
*보험료(USD)
*품명        ZTISRQIT-TXZ01
*LC OPEN일자 ZTITRQS-OPNDT
*선적지      ZTITRQS-PLLOD
*도착지      ZTITRQS-PLTRN
*대표PO      ZTISRQIT-EBELN

*> Create field catagory table
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = 'ZTIVRQ02'
      I_CLIENT_NEVER_DISPLAY = 'X'
    CHANGING
      CT_FIELDCAT            = IT_FIELDCAT_G[].

*>Adjust ALV field category
  PERFORM ADJUST_FIELDCAT.         ">Adjust ALV field category

  FC1[] = FC[].

  AC 'ITAB   COLOR SLIS_T_SPECIALCOL_ALV              X'.

  LOOP AT FC1 INTO FCS.
    CLEAR: FCS-KEY .
    CASE FCS-FIELDNAME.
      WHEN 'REQNO' OR 'AMDSQ'.
        FCS-HOTSPOT = 'X'.
        FCS-KEY     = 'X'.
      WHEN 'OPAMT' OR 'USAMT'.
        FCS-DO_SUM = 'X'.
    ENDCASE.
    MODIFY FC1 FROM FCS.
  ENDLOOP.

ENDFORM.                    " set_fieldcat_build
*&---------------------------------------------------------------------*
*&      Form  create_dynamic_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CREATE_DYNAMIC_TABLE .

  DATA: LP_TABLE        TYPE REF TO DATA.
  DATA: E_STYLE_FNAME   TYPE LVC_FNAME.
  DATA: I_STYLE_TABLE   TYPE C.
  DATA: LT_FIELDCAT     TYPE LVC_T_FCAT.

*create_dynamic_table
  CLEAR LP_TABLE.
  CALL METHOD Z_TI_CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE_GRID
    EXPORTING
      IT_FIELDCATALOG = FC
*      i_style_table   = i_style_table
    IMPORTING
      EP_TABLE        = LP_TABLE.

*      ep_table        = lp_table.

  ASSIGN LP_TABLE->* TO <GT_TABLE>.

ENDFORM.                    " create_dynamic_table
*&---------------------------------------------------------------------*
*&      Form  get_data_for_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATA_FOR_DISPLAY .

  DATA:  L_COUNT     TYPE  I.
  RANGES: LR_DOCST   FOR   ZTITRQS-DOCST OCCURS 1.

  FIELD-SYMBOLS: <LS_TABLE>.
  FIELD-SYMBOLS: <L_FIELD1>.
  FIELD-SYMBOLS: <L_FIELD2>.

  REFRESH : <GT_TABLE>.
*> PROGRESS Display.
  G_LINEN    = 30.
  G_OUT_TEXT = '데이타를 검색 중입니다 %99999%%'(P01).
  REPLACE '%99999%' WITH G_LINEN INTO G_OUT_TEXT.
  PERFORM SHOW_PROGRESS_BAR(ZTIR0000) USING G_OUT_TEXT G_LINEN.

*> 수입의뢰 데이타 select.
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE <GT_TABLE>
    FROM ZTIVRQ04
   WHERE BUKRS  IN  S_BUKRS        "회사코드.
     AND EKORG  IN  S_EKORG        "구매조직.
     AND EKGRP  IN  S_EKGRP        "구매그룹.
     AND REQNO  IN  S_REQNO        "수입의뢰 관리번호.
     AND AMDSQ  IN  S_AMDSQ        "Amend 차수.
     AND REQTY  IN  S_REQTY        "수입의뢰 종류.
     AND ILCTY  IN  S_ILCTY        "신용장 종류.
     AND LIFNR  IN  S_LIFNR        "공급업체 계정번호.
     AND LIFRE  IN  S_LIFRE        "다른 송장발행처.
     AND OFFER  IN  S_OFFER        "오퍼상(Offer).
     AND OPNBK  IN  S_OPNBK        "개설은행.
     AND ZTERM  IN  S_ZTERM        "지급조건키.
     AND WAERS  IN  S_WAERS        "개설통화.
     AND INCO1  IN  S_INCO1        "인도조건 (파트 1).
     AND EXDAT  IN  S_EXDAT        "유효기일.
     AND LSDAT  IN  S_LSDAT        "최종선적일자.
     AND FLAND  IN  S_FLAND        "선적국가.
     AND FPORT  IN  S_FPORT        "선적항.
     AND OPNNO  IN  S_OPNNO        "수입개설번호
     AND OPNDT  IN  S_OPNDT        "개설일자.
     AND CNAM   IN  S_CNAM         "작성인.
     AND CDAT   IN  S_CDAT         "생성일.
     AND UNAM   IN  S_UNAM         "최종변경인.
     AND UDAT   IN  S_UDAT         "변경일
     AND INSYN  EQ  'Y'.
*     AND docst  IN  lr_docst.

  IF SY-SUBRC NE 0.
    MESSAGE S902.
  ENDIF.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <GT_TABLE> TO <LS_TABLE>.
*  FIELD-SYMBOLS: <ls_table>.
  FIELD-SYMBOLS: <L_FIELD3>.
  FIELD-SYMBOLS: <L_FIELD4>.
  FIELD-SYMBOLS: <L_FIELD5>.
  FIELD-SYMBOLS: <L_REQTY>.
  FIELD-SYMBOLS: <L_PPAID>.
  FIELD-SYMBOLS: <L_ZTERM>.



  DATA: L_DDTEXT LIKE DD07T-DDTEXT,
        L_TXZ01  LIKE EKPO-TXZ01.
  LOOP AT <GT_TABLE> INTO <LS_TABLE>.
    G_TABIX = SY-TABIX.
    ASSIGN COMPONENT 'DOCST' OF STRUCTURE
                        <LS_TABLE> TO <L_FIELD1>.

    ASSIGN COMPONENT 'DDTEXT' OF STRUCTURE
                        <LS_TABLE> TO <L_FIELD2>.

    ASSIGN COMPONENT 'EBELN' OF STRUCTURE
                        <LS_TABLE> TO <L_FIELD3>.

    ASSIGN COMPONENT 'TXZ01' OF STRUCTURE
                        <LS_TABLE> TO <L_FIELD4>.

    ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                        <LS_TABLE> TO <L_FIELD5>.


    ASSIGN COMPONENT 'REQTY' OF STRUCTURE
                        <LS_TABLE> TO <L_REQTY>.

    ASSIGN COMPONENT 'PPAID' OF STRUCTURE
                        <LS_TABLE> TO <L_PPAID>.

* 20060706 simcho by
*>REQTY = ‘TT’and PPAID = ‘X’ 인 건은 리스트에서 제외
*    IF <l_reqty> EQ 'TT' AND <l_ppaid> EQ 'X'.
*      DELETE <gt_table> INDEX g_tabix.
*      CONTINUE.
*    ENDIF.
    ASSIGN COMPONENT 'ZTERM' OF STRUCTURE
                        <LS_TABLE> TO <L_ZTERM>.

    IF <L_REQTY> EQ 'TT' AND <L_ZTERM>+0(2) EQ 'TA'.
      DELETE <GT_TABLE> INDEX G_TABIX.
      CONTINUE.
    ENDIF.
* end simcho

*********************************************************
* 20070627 simcho by C2007061201000000128
* 입고여부 확인
*********************************************************

    DATA LV_IBLNO LIKE ZTITBLP-IBLNO.
    CLEAR LV_IBLNO.

    SELECT SINGLE IBLNO INTO LV_IBLNO
      FROM ZTITBLP
     WHERE REQNO = <L_FIELD5>.

    IF SY-SUBRC = 0 .

      SELECT SINGLE IBLNO INTO LV_IBLNO
         FROM ZTITGRP
        WHERE IBLNO =  LV_IBLNO.
      IF SY-SUBRC = 0.
        DELETE <GT_TABLE> INDEX G_TABIX.
        CONTINUE.
      ENDIF.

    ENDIF.


*********************************************************



*> 기존 부보내역 확인.
    CLEAR:  L_COUNT.
    SELECT COUNT( * )
      INTO L_COUNT
      FROM ZTITIP1
     WHERE REQNO EQ <L_FIELD5>.
    IF L_COUNT GT 0.
      DELETE <GT_TABLE> INDEX G_TABIX.
      CONTINUE.
    ENDIF.

    SELECT EBELN
      INTO <L_FIELD3>
      FROM ZTITRQP UP TO 1 ROWS
     WHERE REQNO EQ <L_FIELD5>.
    ENDSELECT.

    IF NOT <L_FIELD3> IS INITIAL.
      SELECT TXZ01
        INTO <L_FIELD4>
        FROM EKPO UP TO 1 ROWS
       WHERE EBELN EQ <L_FIELD3>.
      ENDSELECT.
    ENDIF.

    PERFORM  GET_DOMAIN_VALUE_TEXT(ZTIR0000) USING 'ZTIDOCST'
                                                   <L_FIELD1>
                                                   <L_FIELD2>.
    MODIFY <GT_TABLE> FROM <LS_TABLE>.
  ENDLOOP.

  DESCRIBE TABLE <GT_TABLE> LINES G_LINE.
  IF G_LINE EQ 0.
    MESSAGE S902.
  ENDIF.

ENDFORM.                    " get_data_for_display
*&---------------------------------------------------------------------*
*&      Form  set_colorize_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_COLORIZE_BUILD .

  FIELD-SYMBOLS: <LT_TABLE> TYPE TABLE.
  FIELD-SYMBOLS: <LS_TABLE>.
  FIELD-SYMBOLS: <LT_COLOR>.
  FIELD-SYMBOLS: <LS_COLOR>.
  FIELD-SYMBOLS: <L_FIELD> TYPE TABLE.
  FIELD-SYMBOLS: <L_NAME>.
  FIELD-SYMBOLS: <L_COL>.
  FIELD-SYMBOLS: <L_INT>.

  ASSIGN LOCAL COPY OF INITIAL LINE OF <GT_TABLE> TO <LT_TABLE>.

  DATA: COLOR TYPE SLIS_T_SPECIALCOL_ALV WITH HEADER LINE.

*> colorize
  LOOP AT <GT_TABLE> INTO <LT_TABLE>.

    ASSIGN COMPONENT 'COLOR' OF STRUCTURE
                             <LT_TABLE> TO <L_FIELD>.

    ASSIGN LOCAL COPY OF INITIAL LINE OF <L_FIELD> TO <LS_COLOR>.

    ASSIGN COMPONENT 'COLOR-COL' OF STRUCTURE
                             <LS_COLOR> TO <L_COL>.
    ASSIGN COMPONENT 'COLOR-INT' OF STRUCTURE
                             <LS_COLOR> TO <L_INT>.
    ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE
                             <LS_COLOR> TO <L_NAME>.
    <L_COL> = 4.
    <L_INT> = 0.
    <L_NAME> = 'REQTY'.
    APPEND <LS_COLOR> TO <L_FIELD>.

    MODIFY <GT_TABLE> FROM <LT_TABLE>.
  ENDLOOP.

ENDFORM.                    " set_colorize_build
*&---------------------------------------------------------------------*
*&      Form  set_sort_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_SORT_FIELD .

  DATA: ST_SORT             TYPE SLIS_SORTINFO_ALV.


  REFRESH: IT_SORT.

*  CLEAR  st_sort.
*  st_sort-spos = '01'.
*  st_sort-fieldname = 'REQNO'.
*  st_sort-tabname   = '<GT_TABLE>'.
*  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
*  st_sort-subtot    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.
*
*  CLEAR  st_sort.
*  st_sort-spos = '02'.
*  st_sort-fieldname = 'MTBEZ'.
*  st_sort-tabname   = 'ITAB'.
*  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
**  ST_SORT-SUBTOT    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort.
*
*  CLEAR  st_sort.
*  st_sort-spos = '03'.
*  st_sort-fieldname = 'EBELN'.
*  st_sort-tabname   = 'ITAB'.
*  st_sort-up        = 'X'.
**  ST_SORT-GROUP     = 'X'.
**  ST_SORT-SUBTOT    = 'X'.
**  ST_SORT-EXPA      = 'X'.
*  APPEND st_sort TO it_sort

ENDFORM.                    " set_sort_field
*&---------------------------------------------------------------------*
*&      Form  display_alv_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_ALV_LIST .

  DATA: FC_DETAIL  TYPE SLIS_FIELDCAT_ALV OCCURS 0 WITH HEADER LINE.
  DATA: VARIANT_DETAIL      LIKE DISVARIANT.
  DATA: EXIT       TYPE SLIS_EVENT_EXIT   OCCURS 0 WITH HEADER LINE.
  DATA: EVENTS     TYPE SLIS_ALV_EVENT    OCCURS 0 WITH HEADER LINE.
  DATA: GROUPS     TYPE SLIS_SP_GROUP_ALV OCCURS 0 WITH HEADER LINE.
  DATA: LS_VARIANT LIKE DISVARIANT.


*----------------------------------------------------------------------
*  : 의뢰대상
*C : 수입의뢰
*A : 접수완료
*W : 신청서작성
*Y : 개설신청
*N : 개설취소
*O : 개설완료
*R : 접수반려
*----------------------------------------------------------------------
*  CASE 'X'.
*    WHEN p_step1.  ">의뢰대상
*      SET TITLEBAR 'T1000' WITH '수입의뢰 요청대상'.
*    WHEN p_step2. ">접수대상
*      SET TITLEBAR 'T1000' WITH '수입의뢰 접수대상'.
*    WHEN p_step3. ">신청대상
*      SET TITLEBAR 'T1000' WITH '수입의뢰 신청대상'.
*    WHEN p_step4. ">개설의뢰 진행 중
*      SET TITLEBAR 'T1000' WITH '수입의뢰 신청 진행 중'.
*    WHEN p_step5. ">개설완료
*      SET TITLEBAR 'T1000' WITH '수입의뢰 개설'.
*  ENDCASE.

* The detail ALV may modify the list (sorting). If returned to the
* base list, the original list needs to be restored.
  REFRESH FC_DETAIL.
  LOOP AT FC1 INTO FCS.
    MOVE-CORRESPONDING FCS TO FC_DETAIL.
    CLEAR FC_DETAIL-TABNAME.
    APPEND FC_DETAIL.
  ENDLOOP.

  CLEAR VARIANT_DETAIL.
  VARIANT_DETAIL-REPORT = G_REPID.
  VARIANT_DETAIL-HANDLE = ' '.

  GS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  GS_LAYOUT-ZEBRA             = 'X'.
  GS_LAYOUT-BOX_FIELDNAME     = 'BOX'.
*>color field define.
  GS_LAYOUT-COLTAB_FIELDNAME  = 'COLOR'.
  GS_LAYOUT-GROUP_CHANGE_EDIT = 'X'.
  GS_LAYOUT-F2CODE            = 'DISPLAY'.

  REFRESH EXIT.
  EXIT-UCOMM = '&OL0'. EXIT-AFTER = 'X'. APPEND EXIT.
  EXIT-UCOMM = '&OLX'. APPEND EXIT.
  EXIT-UCOMM = '&OAD'. APPEND EXIT.

*> event define.
  REFRESH EVENTS.
  EVENTS-NAME = SLIS_EV_TOP_OF_PAGE.
  EVENTS-FORM = 'TOP_OF_PAGE'.
  APPEND EVENTS.

*  events-name = slis_ev_subtotal_text.
*  events-form = slis_ev_subtotal_text.
*  APPEND events.
*
  LS_VARIANT-REPORT  = SY-REPID.
  LS_VARIANT-VARIANT = P_VARI.
  G_REPID            = SY-REPID.                  " Callback Program.

*> ALV reuse function call..
  CALL FUNCTION ALV_DETAIL_FUNC
      EXPORTING
        I_CALLBACK_PROGRAM       = G_REPID
        I_CALLBACK_PF_STATUS_SET = 'SET_ALV_STATUS'
        I_CALLBACK_USER_COMMAND  = 'USER_ALV_COMMAND'
*     I_STRUCTURE_NAME               =
*     IT_EXCLUDING                   =
*     IT_SPECIAL_GROUPS              =
*     IT_FILTER                      =
*     IS_SEL_HIDE                    =
*     I_DEFAULT                      = 'X'
*     I_SAVE                         = ' '
*     IS_VARIANT                     =
      IT_EVENTS                      = EVENTS[]
      IT_EVENT_EXIT                  = EXIT[]
*     IS_PRINT                       =
*     IS_REPREP_ID                   =
*     I_SCREEN_START_COLUMN          = 0
*     I_SCREEN_START_LINE            = 0
*     I_SCREEN_END_COLUMN            = 0
*     I_SCREEN_END_LINE              = 0
        IT_FIELDCAT              = FC_DETAIL[]
        IT_SORT                  = IT_SORT
*        I_DEFAULT                = 'X'
*        IS_VARIANT               = VARIANT_DETAIL
        IS_VARIANT               = LS_VARIANT
        I_SAVE                   = C_SAVE
        IS_LAYOUT                = GS_LAYOUT
        IS_PRINT                 = GS_PRINT
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER        =
*     ES_EXIT_CAUSED_BY_USER         =
      TABLES
        T_OUTTAB                 = <GT_TABLE>.

ENDFORM.                    " display_alv_list

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_STATUS
*&---------------------------------------------------------------------*
FORM SET_ALV_STATUS USING  EXTAB TYPE SLIS_T_EXTAB.


  APPEND 'ARCHIVE'   TO EXTAB.
  APPEND '&VEXCEL'   TO EXTAB.
  APPEND '&AQW'      TO EXTAB.
  APPEND '&VCRYSTAL' TO EXTAB.
  APPEND '&VGRID'    TO EXTAB.
  APPEND '&EB9'      TO EXTAB.
  APPEND '&CRDESIG'  TO EXTAB.

  SET TITLEBAR 'T1000' WITH '부보의뢰'.

  SET PF-STATUS 'STANDARD' EXCLUDING EXTAB.

ENDFORM.                    " SET_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  USER_ALV_COMMAND
*&---------------------------------------------------------------------*
FORM USER_ALV_COMMAND USING   R_UCOMM      LIKE SY-UCOMM
                              RS_SELFIELD  TYPE SLIS_SELFIELD.
*
  DATA: L_COUNT   TYPE I.
  DATA: L_INDEX   TYPE I.
  DATA: L_SUBRC   LIKE SY-SUBRC.
  DATA: L_TCODE   LIKE SY-TCODE.
  DATA: L_IF_NULL TYPE REF TO IF_MESSAGE_OBJ_MM.

  FIELD-SYMBOLS: <LS_TABLE>.
  FIELD-SYMBOLS: <L_FIELD>.
  FIELD-SYMBOLS: <L_FIELD1>.
  FIELD-SYMBOLS: <L_FIELD2>.
  FIELD-SYMBOLS: <L_FIELD3>.


  ASSIGN LOCAL COPY OF INITIAL LINE OF <GT_TABLE> TO <LS_TABLE>.

  CASE R_UCOMM.
    WHEN 'ZTIT005'.
      ASSIGN COMPONENT 'BOX' OF STRUCTURE
                               <LS_TABLE> TO <L_FIELD>.
      CLEAR: L_COUNT.
      LOOP AT <GT_TABLE> INTO   <LS_TABLE>.
        IF <L_FIELD> EQ 'X'.
          ADD 1 TO L_COUNT.
        ENDIF.
      ENDLOOP.
      IF L_COUNT EQ 0.
        MESSAGE S903.
      ELSE.

*-{ 자체개선 192404 - 출항일 입력
        CALL SCREEN 300 STARTING  AT  25 5.
        CHECK OK_CODE EQ 'OKAY'.
*-} 자체개선 192404

*        PERFORM set_initail_ip_batchdata.
* Message preparations
        PERFORM  SET_MESSAGE_PREPARATIONS.

        REFRESH: BDCDATA.
        CLEAR: SESSION.
        CTU_PARAMS-DISMODE  = 'N'. ">처리모드
        CTU_PARAMS-UPDMODE  = 'S'. ">갱신모드
        CTU_PARAMS-CATTMODE = ' '. ">CATT 모드...
        CTU_PARAMS-DEFSIZE  = ' '. ">기본화면 크기
        CTU_PARAMS-RACOMMIT = 'X'.
        CTU_PARAMS-NOBINPT  = ' ' .
        CTU_PARAMS-NOBIEND  = ' '.
*
        LOOP AT <GT_TABLE> INTO   <LS_TABLE>.
          IF <L_FIELD> EQ 'X'.
*> 초기화면.
            ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                                  <LS_TABLE> TO <L_FIELD1>.
*            ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
*                                  <ls_table> TO <l_field2>.

            PERFORM BDC_DYNPRO_BUILD USING :
                   'X' 'ZTIR1000'          '0100',
                   ' ' 'ZTISSCRCOM-REQNO'  <L_FIELD1>,
                   ' ' 'BDC_OKCODE'       '=ZTIENTER'.
*> 세부화면.
            PERFORM BDC_DYNPRO_BUILD USING :
                   'X' 'ZTIR1000'         '2000',
*****************************************************************
                   ' ' 'ZTITIP1-IDPDT'     ZTITIP1-IDPDT,
                   ' ' 'BDC_OKCODE'       '=ZTIENTER'.
*****************************************************************
            PERFORM BDC_DYNPRO_BUILD USING :
                   ' ' 'BDC_OKCODE'       '=ZTIREQUEST'.

            PERFORM BDC_DYNPRO_BUILD USING :
                   'X' 'SAPLSPO1'         '0300',
                   ' ' 'BDC_OKCODE'       '=YES'.

            PERFORM BDC_TRANSACTION USING 'ZTIT101' L_SUBRC.

            IF L_SUBRC EQ 0.
              MESSAGE S154 WITH <L_FIELD1>.
              PERFORM SET_RETURN_MESSAGE_FILL USING SY-MSGTY.
            ELSE.
              LOOP AT MESSTAB WHERE MSGTYP EQ 'E'.
                SY-MSGNO = MESSTAB-MSGNR.
                ZTI_MESSAGE MESSTAB-MSGTYP MESSTAB-MSGID SY-MSGNO
                    MESSTAB-MSGV1 MESSTAB-MSGV2
                    MESSTAB-MSGV3 MESSTAB-MSGV4.
              ENDLOOP.
              IF SY-SUBRC NE 0.
                MESSAGE S926.
                PERFORM SET_RETURN_MESSAGE_FILL USING C_ERROR.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
*> 오류정보가 존재시 메시지 상자 POPUP.
        G_LINE = G_MESSAGE_HANDLER->GET_SEVERITY_BO(
                                IM_BUSINESS_OBJ          = L_IF_NULL
                                IM_INCLUDE_CHILD_OBJECTS = C_TRUE ).

        IF G_LINE GT 0.
          CALL METHOD G_MESSAGE_HANDLER->SHOW( IM_POPUP = C_TRUE
            IM_AMODAL = C_FALSE ).
        ENDIF.

        PERFORM GET_DATA_FOR_DISPLAY.    ">data select
        RS_SELFIELD-REFRESH = 'X'.
      ENDIF.

    WHEN 'ZTIT002'.
      ASSIGN COMPONENT 'BOX' OF STRUCTURE
                               <LS_TABLE> TO <L_FIELD>.
      CLEAR: L_COUNT.
      LOOP AT <GT_TABLE> INTO   <LS_TABLE>.
        IF <L_FIELD> EQ 'X'.
          ADD 1 TO L_COUNT.
          L_INDEX = SY-TABIX.
        ENDIF.
      ENDLOOP.
      IF L_COUNT NE 1.
        MESSAGE S906.
      ELSE.
        READ TABLE <GT_TABLE> INTO   <LS_TABLE>
                              INDEX L_INDEX.

        ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                              <LS_TABLE> TO <L_FIELD1>.
*        ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
*                              <ls_table> TO <l_field2>.
        SET PARAMETER ID 'ZTIREQNO' FIELD <L_FIELD1>.
*          SET PARAMETER ID 'ZTIAMDSQ' FIELD <l_field2>.
        CALL TRANSACTION 'ZTIT101' AND SKIP FIRST SCREEN .

        PERFORM GET_DATA_FOR_DISPLAY.    ">data select
        RS_SELFIELD-REFRESH = 'X'.
      ENDIF.

    WHEN 'DISPLAY' OR '&IC1'.    " AUF DOPPELKLICK REAGIERIEN
      CHECK RS_SELFIELD-TABINDEX GT 0.

      READ TABLE <GT_TABLE> INTO <LS_TABLE> INDEX RS_SELFIELD-TABINDEX.
      IF SY-SUBRC NE 0.
        MESSAGE S906.            EXIT.
      ENDIF.
      ASSIGN COMPONENT 'REQNO' OF STRUCTURE
                            <LS_TABLE> TO <L_FIELD1>.
      ASSIGN COMPONENT 'AMDSQ' OF STRUCTURE
                            <LS_TABLE> TO <L_FIELD2>.
      ASSIGN COMPONENT 'EBELN' OF STRUCTURE
                            <LS_TABLE> TO <L_FIELD3>.

      CASE RS_SELFIELD-FIELDNAME.
        WHEN 'REQNO' OR 'AMDSQ'.
          PERFORM DISPLAY_IMPORT_DOCUMENT(ZTIR0000)
                               USING <L_FIELD1> <L_FIELD2> '00000'.
        WHEN 'EBELN'.
          PERFORM  DISPLAY_PURCHASE_ORDER(ZTIR0000)
                                          USING <L_FIELD3> '00'.

        WHEN OTHERS.              ">해당작업수행..
      ENDCASE.

  ENDCASE.
  CLEAR: R_UCOMM.

ENDFORM.                    " USER_ALV_COMMAND
*&---------------------------------------------------------------------*
*&      Form  adjust_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ADJUST_FIELDCAT .

  FIELD-SYMBOLS: <LS_TABLE>,
                 <L_FIELD>.

  DATA: LT_FIELDCAT_G TYPE LVC_T_FCAT.

*>Internal table에 존재하지 않는 필드.
  LOOP AT IT_FIELDCAT_G INTO GS_FIELDCAT_G.
    READ TABLE FC INTO FCS WITH KEY FIELDNAME = GS_FIELDCAT_G-FIELDNAME.
    IF SY-SUBRC NE 0.
      IF NOT GS_FIELDCAT_G-FIELDNAME IS INITIAL AND
         GS_FIELDCAT_G-FIELDNAME     NE 'MANDT'.
        MOVE-CORRESPONDING  GS_FIELDCAT_G TO FCS.
        MOVE: GS_FIELDCAT_G-FIELDNAME     TO FCS-REF_FIELDNAME,
              'ZTIVRQ02'                  TO FCS-REF_TABNAME.
        CLEAR: FCS-KEY.
        FCS-NO_OUT = 'X'.
        APPEND FCS TO FC.
      ENDIF.
    ENDIF.
    DESCRIBE TABLE FC LINES G_LINE.
    IF G_LINE GT 50.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " adjust_fieldcat
*&---------------------------------------------------------------------*
*&      Form  set_edi_default_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_EDI_DEFAULT_VALUE .

  CHECK : G_MODE EQ C_CHARY OR               "신청
          G_MODE EQ C_CHARO OR               "구상
          G_MODE EQ C_CHARM OR               "변경
          G_MODE EQ C_CHARC.                 "생성/Amend

  MOVE: ZTSTIG3-IOPNO TO ZTITIP1-IOPNO,      "포괄보험번호
        ZTSTIG3-EPART TO ZTITIP1-RECID,      "수신자ID
        ZTSTIG3-NAMET TO ZTITIP1-RECNM,      "수신자명
        ZTSTIG3-IWART TO ZTITIP1-IWART,      "희망이익율
        ZTSTIG3-ITOCP TO ZTITIP1-ITOCP,      "공동인수사
        ZTSTIG3-ITORT TO ZTITIP1-ITORT,      "공동인수율
        ZTSTIG3-NAMET TO ZTITIP1-ICPNM,      "손보사상호
        ZTSTIG3-ESIGN TO ZTITIP1-ICPID,      "손보사전자서명
        ZTSTIG3-ICSNM TO ZTITIP1-ICSNM.      "손보사영업담당자명

ENDFORM.                    " set_edi_default_value

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM TOP_OF_PAGE.

  DATA: L_MODE TYPE I.
  DATA: HEADER TYPE SLIS_LISTHEADER OCCURS 0 WITH HEADER LINE.

  REFRESH HEADER.

  HEADER-TYP = 'H'.

  HEADER-INFO = '적하부보 Due List'.

  CLEAR: HEADER-KEY.
  APPEND HEADER.

** JS전선 회사코드 2007/04 KSH --------------------------------------
  DATA: L_BUTXT LIKE T001-BUTXT.
  CLEAR: L_BUTXT.
  SELECT SINGLE BUTXT FROM T001
                      INTO L_BUTXT
                     WHERE BUKRS EQ S_BUKRS-LOW.

  HEADER-TYP = 'S'.
  HEADER-KEY = '회사코드 '.
  CONCATENATE S_BUKRS-LOW L_BUTXT INTO HEADER-INFO SEPARATED BY SPACE.
  APPEND HEADER.
  CLEAR: HEADER.
** JS전선 회사코드 2007/04 KSH --------------------------------------

  HEADER-TYP = 'S'.
  HEADER-KEY = '출력일자'(106).
  WRITE: SY-DATLO TO HEADER-INFO.
  APPEND HEADER.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = HEADER[].

ENDFORM.    ">TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  edi_data_sending
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM EDI_DATA_SENDING .

  DATA: L_IMEXI   TYPE C,
        L_DOCNO   TYPE CHAR10,
        L_AMDSQ   TYPE NUMC2,
        L_DOCTY   TYPE ZTSTEDIS-EDITY,
        L_SNCNT   TYPE ZTSTEDIS-SNCNT.

  CASE ZTSTIG0-FNAME.
    WHEN 'L'.    ">LG CNS VAN I/F
      CASE G_DOCUMENT.
        WHEN C_IP.
          IF ZTSTIG0-LGIPI EQ C_TRUE.
*>[TraSys] LG 화재 VAN용 OutBound 공통모듈 .
            G_EDI_FUNC = 'Z_TD_APPLICATION_TO_LGINSURE'.
          ELSE.
*>[TraSys] LG CNS VAN용 OutBound 공통모듈 .
            G_EDI_FUNC = 'Z_TD_EDI_OUTBOUND_FOR_LGCNS'.
          ENDIF.
        WHEN OTHERS.
*>[TraSys] LG CNS VAN용 OutBound 공통모듈 .
          G_EDI_FUNC = 'Z_TD_EDI_OUTBOUND_FOR_LGCNS'.
      ENDCASE.
    WHEN 'R'.   ">Ready Korea Package I/F
      CASE G_DOCUMENT.
        WHEN C_IP.
          IF ZTSTIG0-LGIPI EQ C_TRUE.
*>[TraSys] LG 화재 VAN용 OutBound 공통모듈 .
            G_EDI_FUNC = 'Z_TD_APPLICATION_TO_LGINSURE'.
*            g_edi_func = 'Z_TD_EDI_OUTBOUND_FOR_RK'.
          ELSE.
*>[TraSys] LG CNS VAN용 OutBound 공통모듈 .
            G_EDI_FUNC = 'Z_TD_EDI_OUTBOUND_FOR_RK'.
          ENDIF.
        WHEN OTHERS.
*>[TraSys] 레디코리아용 OutBound 공통모듈 .
          G_EDI_FUNC = 'Z_TD_EDI_OUTBOUND_FOR_RK'.
      ENDCASE.
    WHEN OTHERS.
      EXIT.
  ENDCASE.

*{ SRM2203-09738 - 변경_S
  IF ZTSTIG0-INSCP = ZTITIP1-INSCP.
    IF ZTITIP1-INSCP = 'NETLG'.
      G_EDI_FUNC = 'Z_TD_TO_LGINSURANCE_BY_RFC'.
    ELSE.
      G_EDI_FUNC = 'Z_TD_EDI_OUTBOUND_FOR_RK'.
    ENDIF.
  ELSE.
    MESSAGE I996 WITH 'EDI 전송대상(보험사)이 아닙니다.'
                      '수작업으로 진행하십시오.'.
    EXIT.
  ENDIF.

**>[TraSys] LG 화재 VAN용 OutBound 공통모듈 .
*  IF ZTSTIG0-LGIPI EQ C_TRUE AND
*     G_DOCUMENT    EQ C_IP.
*    G_EDI_FUNC = 'Z_TD_TO_LGINSURANCE_BY_RFC'.
*  ELSE.
*
*  ENDIF.
*} SRM2203-09738 - 변경_E

*> 수출입 구분.
  L_IMEXI = C_CHARI.

  L_SNCNT  =  ZTITIP1-SNCNT.
  L_DOCNO  =  ZTITIP1-IIPNO.
  L_AMDSQ  =  ZTITIP1-AMDSQ.

  IF ZTSTIG0-LGIPI NE C_TRUE .
    SELECT SINGLE *
      FROM ZTSTEDIS
     WHERE SNCNT  EQ  ZTITIP1-SNCNT.
    IF SY-SUBRC EQ 0.
      L_DOCTY = ZTSTEDIS-EDITY.
    ENDIF.
  ENDIF.

*> EDI Sending.
*----> LG 화재 Interface.
  IF ZTSTIG0-LGIPI EQ C_TRUE AND ZTITIP1-INSCP = 'NETLG'.
    CALL FUNCTION G_EDI_FUNC
      EXPORTING
        IM_IMEXI   = L_IMEXI
        IM_DOCNO   = L_DOCNO
        IM_AMDSQ   = L_AMDSQ
      IMPORTING
        EX_SUBRC   = G_SUBRC
      EXCEPTIONS
        NOT_FOUND  = 4
        MAKE_ERROR = 8.
  ELSE.
    CALL FUNCTION G_EDI_FUNC
      EXPORTING
        IM_IMEXI    = L_IMEXI
        IM_DOCTY    = L_DOCTY
        IM_DOCNO    = L_DOCNO
        IM_SEQNO    = L_AMDSQ
        IM_ZTSTEDIS = ZTSTEDIS
        IM_ZTSTIG0  = ZTSTIG0
      IMPORTING
        EX_SUBRC    = G_SUBRC
        EX_ZTSTEDIS = ZTSTEDIS.
  ENDIF.

  IF SY-SUBRC EQ 0.
    MESSAGE S045.
  ELSE.
    MESSAGE S046.
  ENDIF.

ENDFORM.                    " edi_data_sending
*&---------------------------------------------------------------------*
*&      Form  set_request_by_pur_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_REQUEST_BY_PUR_DOCUMENT .

  PERFORM P3000_SET_DATA_OF_SCREEN.
*   ztitrqs-setyn  = c_true.
*
*   IF sy-calld EQ c_true AND
*      g_tcode1 EQ c_due_list_po.
*     LOOP AT it_rkwa.
*       MOVE-CORRESPONDING it_rkwa TO g_tc_2130_wa.
*       MOVE: 1             TO g_tc_2130_wa-peinh,
*             1             TO g_tc_2130_wa-bpumz,
*             1             TO g_tc_2130_wa-bpumn,
*             it_rkwa-bstmg TO g_tc_2130_wa-menge,
*             it_rkwa-bstme TO g_tc_2130_wa-meins.
*
*       SELECT  SUM( rqmng )
*         INTO g_tc_2130_wa-rqmngs
*         FROM ztivrq00
*        WHERE  mblnr  = g_tc_2130_wa-mblnr
*          AND  mjahr  = g_tc_2130_wa-mjahr
*          AND  zeile  = g_tc_2130_wa-zeile.
*
*       g_tc_2130_wa-rqmng  = g_tc_2130_wa-menge - g_tc_2130_wa-rqmngs.
*       g_tc_2130_wa-rqmngl = g_tc_2130_wa-rqmng.
*
*       IF g_tc_2130_wa-rqmng LE c_zero.
*         MESSAGE e103.
*       ENDIF.
*
*       SELECT SINGLE ps_psp_pnr aufnr
*         INTO (g_tc_2130_wa-ps_psp_pnr, g_tc_2130_wa-nplnr)
*         FROM mseg
*        WHERE mblnr   = it_rkwa-mblnr
*          AND mjahr   = it_rkwa-mjahr
*          AND zeile   = it_rkwa-zeile.
*       IF g_tc_2130_wa-ps_psp_pnr IS INITIAL.
*         IF g_tc_2130_wa-menge EQ 0.
*           g_tc_2130_wa-netpr = 0.
*         ELSE.
*           g_tc_2130_wa-netpr = it_rkwa-wrbtr / it_rkwa-bstmg.
*         ENDIF.
*       ELSE.
*         PERFORM get_parent_wbs_element(ztir0000)
*                                        USING g_tc_2130_wa-ps_psp_pnr
*                                              gs_proj.
*         MOVE: gs_proj-pspnr   TO g_tc_2130_wa-ps_psp_pnr.
*
**        SELECT SINGLE netpr
**          INTO g_tc_2130_wa-netpr
**          FROM zmmt0003
**         WHERE lifnr EQ it_rkwa-lifnr
**           AND matnr EQ g_tc_2130_wa-matnr
**           AND pspid EQ g_tc_2130_wa-ps_psp_pnr
**           AND sdate LE it_rkwa-budat
**           AND edate GE it_rkwa-budat.
**
*         g_tc_2130_wa-netwr = g_tc_2130_wa-netpr * g_tc_2130_wa-menge.
*
*       ENDIF.
*       IF NOT g_tc_2130_wa-nplnr IS INITIAL.
*         PERFORM get_wbs_element_by_network(ztir0000)
*                                        USING g_tc_2130_wa-nplnr
*                                              gs_proj.
*         MOVE: gs_proj-pspnr   TO g_tc_2130_wa-ps_psp_pnr.
*       ENDIF.
*
*       MOVE: sy-uname TO g_tc_2130_wa-cnam,
*             sy-datlo TO g_tc_2130_wa-cdat,
*             sy-timlo TO g_tc_2130_wa-ctme,
*             sy-uname TO g_tc_2130_wa-unam,
*             sy-datlo TO g_tc_2130_wa-udat,
*             sy-timlo TO g_tc_2130_wa-utme.
*
*       APPEND g_tc_2130_wa  TO it_tab.
*
*       MOVE : it_rkwa-lifnr TO ztitrqk-lifnr,
*              it_rkwa-bukrs TO ztitrqk-bukrs,
*              it_rkwa-bwaer TO ztitrqs-waers,
*              c_pu          TO ztitrqk-reqty,
*              c_true        TO ztitrqs-setyn.
*     ENDLOOP.
**>아이템 번호를 생성함.
*     PERFORM set_item_number_build TABLES it_tab
*                                   USING  ztitrqs.
*   ELSE.
**      perform
*
*   ENDIF.
*
*   CLEAR: g_modify.


ENDFORM.                    " set_request_by_pur_document
*&---------------------------------------------------------------------*
*&      Form  move_ekko_fields_to_ztitip1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MOVE_EKKO_FIELDS_TO_ZTITIP1 .

  FIELD-SYMBOLS <L_FS>.
  DATA: L_FIELDNAME TYPE FIELDNAME.

  MOVE-CORRESPONDING EKKO TO ZTITIP1.

  IF G_MODE EQ C_CHARC.
    MOVE: SY-DATLO        TO ZTITIP1-TAPDT,
          SY-DATLO        TO ZTITIP1-IOPDT,  ">보험개시일.
          '22'            TO ZTITIP1-ENDCD,
          EKKO-EBELN      TO ZTITIP1-EBELN,
          EKKO-WAERS      TO ZTITIP1-IIVATC,
*          ztitrqs-opamt   TO ztitip1-iivat,
          EKKO-WAERS      TO ZTITIP1-ITOATC,
          EKKO-WAERS      TO ZTITIP1-ICAATC,
          EKKO-WAERS      TO ZTITIP1-IDUATC,
          T001-WAERS      TO ZTITIP1-ITPA1C,
          T001-WAERS      TO ZTITIP1-ITPA2C,
          T001-WAERS      TO ZTITIP1-ITPA3C,
          T001-WAERS      TO ZTITIP1-ICPAMC,
          T001-WAERS      TO ZTITIP1-IDPAMC,
          T001-WAERS      TO ZTITIP1-IVPAMC,
          T001-WAERS      TO ZTITIP1-ITEAMC,
          3               TO ZTITIP1-IPCON,  ">사본.
          4               TO ZTITIP1-IPORN,  ">원본.
          'T.B.D'         TO ZTITIP1-IVSLN,
*---> 부보생성 시 Default 값 추가 by MSH
          '110'           TO ZTITIP1-IWART.

*> 선급금액 누적..
    ZTITIP1-IIVAT = ZTITIP1-IIVAT + ZTITRQS-PPAMT.

*> 회사코드.
    CALL FUNCTION 'Z_TS_GET_COMPANY_EDI_DATA'
      EXPORTING
        BUKRS           = ZTITIP1-BUKRS
        APPCT           = 'Y'
     IMPORTING
       YZTSTIG0        = ZTSTIG0
*       nztstig0        = ztstig0
       XT001            = T001
     EXCEPTIONS
       NOT_FOUND       = 1
       OTHERS          = 2 .
    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      MESSAGE ID SY-MSGID TYPE C_WARNING  NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    MOVE: ZTSTIG0-INSCP TO ZTITIP1-INSCP,  ">보험회사코드.
          ZTSTIG0-EOMNM TO ZTITIP1-IASNM1, ">피보험자.
          ZTSTIG0-EOMPR TO ZTITIP1-IASNM2, ">피보험자.
          ZTSTIG0-BUSID TO ZTITIP1-IAPID,  ">보험계약자.
          ZTSTIG0-EOMNM TO ZTITIP1-IAPNM,  "> ** 상호.
          ZTSTIG0-EOMPR TO ZTITIP1-IAPPR,  "> ** 대표자.
          ZTSTIG0-ESIGN TO ZTITIP1-IAPSG,  "> ** 전자서명.
          T001-WAERS    TO ZTITIP1-ICUATC, ">
          T001-WAERS    TO ZTITIP1-ICAATC,
          T001-WAERS    TO ZTITIP1-IDUATC.

*> Set 보험회사 관련 Default value
    IF NOT ZTITIP1-INSCP IS INITIAL.
      SELECT SINGLE *
        FROM ZTSTIG3
       WHERE PARTI   EQ   C_CHARP
         AND EPART   EQ   ZTITIP1-INSCP.
      IF SY-SUBRC EQ 0.
        MOVE: ZTSTIG3-IOPNO  TO ZTITIP1-IOPNO,
              ZTSTIG3-ICSNM  TO ZTITIP1-ICSNM,
              ZTSTIG3-EPART  TO ZTITIP1-RECID,
              ZTSTIG3-NAMET  TO ZTITIP1-RECNM,
              SPACE          TO ZTITIP1-DOCST,
              '9'            TO ZTITIP1-RECTR,
              'AB'           TO ZTITIP1-RECAS,
              ZTSTIG3-IWART  TO ZTITIP1-IWART, ">희망이익율.
              ZTSTIG3-ITOCP  TO ZTITIP1-ITOCP, ">공동인수사.
              ZTSTIG3-ITORT  TO ZTITIP1-ITORT, ">공동인수율.
              ZTSTIG3-NAMET  TO ZTITIP1-ICPNM,
*              TO ZTITIP1-ICPPR,
              ZTSTIG3-ESIGN  TO ZTITIP1-ICPID.
      ENDIF.
    ENDIF.

    LOOP AT IT_TAB INTO G_TC_2130_WA.
      IF ZTITIP1-EBELN IS INITIAL.
        MOVE G_TC_2130_WA-EBELN TO ZTITIP1-EBELN.           ">상품명세1
      ENDIF.
      IF ZTITIP1-IGOTE1 IS INITIAL.
        MOVE G_TC_2130_WA-TXZ01 TO ZTITIP1-IGOTE1.          ">상품명세1
      ENDIF.
      IF ZTITIP1-IHSCD IS INITIAL.
        MOVE G_TC_2130_WA-STAWN TO ZTITIP1-IHSCD.  ">>H/S Code
      ENDIF.
      IF ZTITIP1-EBELN IS INITIAL.
        ZTITIP1-EBELN = G_TC_2130_WA-EBELN.
      ENDIF.
      ADD G_TC_2130_WA-NETWR TO ZTITIP1-IIVAT.
    ENDLOOP.

*    CASE ztitrqk-reqty.
*      WHEN 'LC'.
*        MOVE: ztitrqk-reqty  TO ztitip1-irecd2,
*              ztitrqs-opnno  TO ztitip1-ireno2.
*      WHEN 'TT'.
*      WHEN 'PU'.
*      WHEN 'LO'.
*      WHEN 'DA'.
*      WHEN 'DP'.
*    ENDCASE.
*
    MOVE: 'POR'          TO ZTITIP1-IRECD,
          ZTITIP1-EBELN  TO ZTITIP1-IRENO.

*> 보험회사 코드.
    IF NOT ZTITIP1-INSCP IS INITIAL.
      SELECT SINGLE *
        FROM ZTSTIG3
       WHERE PARTI EQ C_CHARP
         AND EPART EQ ZTITIP1-INSCP.
    ENDIF.

*> 복사할 구매오더 헤더상의 부보필드.

*> 복사규칙 Select.
    REFRESH: G_TC_2210_ITAB.

    SELECT SINGLE *
      FROM ZTITIG30.

    CHECK SY-SUBRC EQ 0.

    SELECT SINGLE *
      FROM EKKO
     WHERE EBELN EQ ZTITIP1-EBELN.

*> 선적국가코드 복사할 구매오더 헤더필드
    IF NOT ZTITIG30-FLAND IS INITIAL.
      CONCATENATE 'EKKO-' ZTITIG30-FLAND INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-FLAND'.
      ASSIGN (L_FIELDNAME) TO <L_FS>.
      IF SY-SUBRC     EQ 0        AND
         NOT <L_FS>   IS INITIAL.
        ZTITIP1-ISHCD = <L_FS>.
      ENDIF.
    ENDIF.

*> 선적항 텍스트를 복사할 구매오더 헤더필드
    IF NOT ZTITIG30-PLLOD IS INITIAL.
      CONCATENATE 'EKKO-' ZTITIG30-PLLOD INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-PLLOD'.
      ASSIGN (L_FIELDNAME) TO <L_FS>.
      IF SY-SUBRC     EQ 0        AND
         NOT <L_FS>   IS INITIAL.
        ZTITIP1-ISHNM = <L_FS>.
      ENDIF.
    ENDIF.

*> 도착국가코드 복사할 구매오더 헤더필드
    IF NOT ZTITIG30-TLAND IS INITIAL.
      CONCATENATE 'EKKO-' ZTITIG30-TLAND INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-TLAND'.
      ASSIGN (L_FIELDNAME) TO <L_FS>.
      IF SY-SUBRC     EQ 0        AND
         NOT <L_FS>   IS INITIAL.
        ZTITIP1-ILDCD = <L_FS>.
      ENDIF.
    ENDIF.

*> 도착항 텍스트를 복사할 구매오더 헤더필드
    IF NOT ZTITIG30-PLTRN IS INITIAL.
      CONCATENATE 'EKKO-' ZTITIG30-PLTRN INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-PLTRN'.
      ASSIGN (L_FIELDNAME) TO <L_FS>.
      IF SY-SUBRC     EQ 0        AND
         NOT <L_FS>   IS INITIAL.
        ZTITIP1-ILDNM = <L_FS>.
      ENDIF.
    ENDIF.


    IF NOT ZTITIG30-ITECD IS INITIAL.
      CONCATENATE 'EKKO-' ZTITIG30-ITECD INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-ZZOFFER'.
      ASSIGN (L_FIELDNAME) TO <L_FS>.
      IF SY-SUBRC     EQ 0        AND
         NOT <L_FS>   IS INITIAL.
        SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF G_TC_2210_WA
          FROM ZTSTIG4
         WHERE ITECD  EQ  <L_FS>.

        IF SY-SUBRC EQ 0.
          G_TC_2210_WA-ITETY = C_CHARB.
          APPEND G_TC_2210_WA TO G_TC_2210_ITAB.
        ENDIF.
      ENDIF.
    ENDIF.
    IF NOT ZTITIG30-ITECD1 IS INITIAL.
      CONCATENATE 'EKKO-' ZTITIG30-ITECD1 INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-ZZOFFER'.
      ASSIGN (L_FIELDNAME) TO <L_FS>.
      IF SY-SUBRC     EQ 0        AND
         NOT <L_FS>   IS INITIAL.
        SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF G_TC_2210_WA
          FROM ZTSTIG4
         WHERE ITECD  EQ  <L_FS>.

        IF SY-SUBRC EQ 0.
          G_TC_2210_WA-ITETY = C_CHARA.
          APPEND G_TC_2210_WA TO G_TC_2210_ITAB.
        ENDIF.
      ENDIF.
    ENDIF.
    IF NOT ZTITIG30-ITECD2 IS INITIAL.
      CONCATENATE 'EKKO-' ZTITIG30-ITECD2 INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-ZZOFFER'.
      ASSIGN (L_FIELDNAME) TO <L_FS>.
      IF SY-SUBRC     EQ 0        AND
         NOT <L_FS>   IS INITIAL.
        SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF G_TC_2210_WA
          FROM ZTSTIG4
         WHERE ITECD  EQ  <L_FS>.

        IF SY-SUBRC EQ 0.
          G_TC_2210_WA-ITETY = C_CHARA.
          APPEND G_TC_2210_WA TO G_TC_2210_ITAB.
        ENDIF.
      ENDIF.
    ENDIF.
    IF NOT ZTITIG30-ITECD3 IS INITIAL.
      CONCATENATE 'EKKO-' ZTITIG30-ITECD3 INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-ZZOFFER'.
      ASSIGN (L_FIELDNAME) TO <L_FS>.
      IF SY-SUBRC     EQ 0        AND
         NOT <L_FS>   IS INITIAL.
        SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF G_TC_2210_WA
          FROM ZTSTIG4
         WHERE ITECD  EQ  <L_FS>.

        IF SY-SUBRC EQ 0.
          G_TC_2210_WA-ITETY = C_CHARA.
          APPEND G_TC_2210_WA TO G_TC_2210_ITAB.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR: G_COUNT.
  LOOP AT  G_TC_2210_ITAB INTO G_TC_2210_WA.
    ADD 1 TO G_COUNT.
    G_TC_2210_WA-ITESQ = G_COUNT.
    MODIFY G_TC_2210_ITAB FROM G_TC_2210_WA.
  ENDLOOP.

ENDFORM.                    " move_ekko_fields_to_ztitip1
*&---------------------------------------------------------------------*
*&      Form  check_insurance_doc_by_ebeln
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_INSURANCE_DOC_BY_EBELN .

  DATA: L_CDAT  TYPE DATUM.

  IF ZTISSCRCOM-EBELN IS INITIAL.
    PERFORM NO_INPUT_CHECK USING 'ZTISSCRCOM' 'EBELN' C_ERROR.
  ENDIF.

  SELECT SINGLE *
    FROM EKKO
   WHERE EBELN EQ ZTISSCRCOM-EBELN.
  IF SY-SUBRC EQ 0.
    IF EKKO-FRGRL EQ C_TRUE.   ">릴리즈 지시자.
      MESSAGE E147 WITH ZTISSCRCOM-EBELN.
    ENDIF.

    IF NOT ( EKKO-INCO1 EQ 'FOB' OR
             EKKO-INCO1 EQ 'FCA' OR
             EKKO-INCO1 EQ 'FAS' OR
             EKKO-INCO1 EQ 'CPT' OR
             EKKO-INCO1 EQ 'CFR' OR
             EKKO-INCO1 EQ 'EXW' ).
      MESSAGE E146 WITH ZTISSCRCOM-EBELN EKKO-INCO1.
    ENDIF.
    SELECT IIPNO
      INTO G_IIPNO
      FROM ZTITIP1 UP TO 1 ROWS
     WHERE EBELN EQ ZTISSCRCOM-EBELN.
    ENDSELECT.
    IF SY-SUBRC EQ 0.
      MESSAGE E110 WITH ZTISSCRCOM-EBELN SPACE.
    ENDIF.
  ELSE.
    MESSAGE E145 WITH ZTISSCRCOM-EBELN.
  ENDIF.

*> Items Select
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE IT_TAB
    FROM EKPO
   WHERE EBELN EQ ZTISSCRCOM-EBELN.

  LOOP AT IT_TAB INTO G_TC_2130_WA.
    G_TC_2130_WA-RQMNG = G_TC_2130_WA-MENGE.
    IF G_TC_2130_WA-STAWN IS INITIAL.
      SELECT SINGLE STAWN
        INTO (G_TC_2130_WA-STAWN)
        FROM EIPO
       WHERE EXNUM EQ ( SELECT EXNUM
                          FROM EKKO
                         WHERE EBELN EQ G_TC_2130_WA-EBELN )
         AND EXPOS EQ G_TC_2130_WA-EBELP.

      IF G_TC_2130_WA-STAWN IS INITIAL.
        SELECT SINGLE STAWN
          INTO (G_TC_2130_WA-STAWN)
          FROM MARC
         WHERE MATNR  EQ  G_TC_2130_WA-MATNR
           AND WERKS  EQ  G_TC_2130_WA-WERKS.

        IF G_TC_2130_WA-STAWN IS INITIAL.
          SELECT CDAT STAWN
            INTO (L_CDAT, G_TC_2130_WA-STAWN)
            FROM ZTIVPO01 UP TO 1 ROWS
           WHERE MATNR  EQ  G_TC_2130_WA-MATNR
             AND WERKS  EQ  G_TC_2130_WA-WERKS
             AND STAWN  NE  SPACE
           ORDER BY CDAT DESCENDING.
          ENDSELECT.
        ENDIF.
      ENDIF.
    ENDIF.

    MODIFY IT_TAB FROM G_TC_2130_WA.
  ENDLOOP.

ENDFORM.                    " check_insurance_doc_by_ebeln
*&---------------------------------------------------------------------*
*&      Form  get_authorization_bukrs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_AUTHORIZATION_BUKRS .

*  PERFORM init_authorization_check USING a_bukrs
*                                CHANGING a_bukrs.

ENDFORM.                    " get_authorization_bukrs
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.
  SET PF-STATUS '0300'.
  SET TITLEBAR 'T300'.
ENDMODULE.                 " STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_EXIT_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_EXIT_0300 INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " USER_COMMAND_EXIT_0300  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.
  OK_CODE = SY-UCOMM.

  CASE OK_CODE.
    WHEN 'CANC' OR 'OKAY'.
      LEAVE TO SCREEN 0.
  ENDCASE.

  CLEAR OK_CODE.
ENDMODULE.                 " USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*&      Form  CHECK_BILL_OF_LADING
*&---------------------------------------------------------------------*
*       기능개선 283274 - 추가
*----------------------------------------------------------------------*
FORM CHECK_BILL_OF_LADING .
  DATA: LV_IIPNO    LIKE ZTITIP1-IIPNO.

*> B/L의 인도조건 체크.
  IF ZTITBLK-INCO1 = 'FOB' OR ZTITBLK-INCO1 = 'FCA' OR
     ZTITBLK-INCO1 = 'FAS' OR ZTITBLK-INCO1 = 'CPT' OR
     ZTITBLK-INCO1 = 'CFR' OR ZTITBLK-INCO1 = 'EXW'.
*> BL 관리번호로 생성된 적하보험 존재여부 점검
    CLEAR : LV_IIPNO.

    SELECT SINGLE IIPNO
      INTO LV_IIPNO
      FROM ZTITIP1
     WHERE IBLNO = ZTITBLK-IBLNO.

    IF SY-SUBRC = 0.
      MESSAGE E997 WITH '적하보험이 생성된 B/L 관리번호입니다.'
                        'I/P 관리번호:' LV_IIPNO.
    ENDIF.

  ELSE.
    MESSAGE E997 WITH 'B/L 관리번호' ZTITBLK-IBLNO
                      '의 인도조건을 확인하십시오.'..
  ENDIF.
ENDFORM.                    " CHECK_BILL_OF_LADING
*&---------------------------------------------------------------------*
*&      Form  MOVE_BL_ITEM_TO_ZTITIP1
*&---------------------------------------------------------------------*
*       기능개선 283274 - 추가
*----------------------------------------------------------------------*
FORM MOVE_BL_ITEM_TO_ZTITIP1 .

  FIELD-SYMBOLS <L_FS>.
  DATA: L_FIELDNAME TYPE FIELDNAME.

  DATA: LV_FWDTY    LIKE ZTITBLK-FWDTY,
        LV_ITECD    LIKE ZTITRQS-ITECD.

  IF ZTITRQK IS NOT INITIAL.
    MOVE-CORRESPONDING ZTITRQK TO ZTITIP1.
  ELSE.
    MOVE-CORRESPONDING ZTITBLK TO ZTITIP1.
  ENDIF.

  READ TABLE IT_TAB INTO G_TC_2130_WA INDEX 1.

  IF G_MODE EQ C_CHARC.
    IF ZTITRQK IS NOT INITIAL.
      MOVE-CORRESPONDING ZTITRQK TO ZTITIP1.
    ELSE.
      MOVE-CORRESPONDING ZTITBLK TO ZTITIP1.
    ENDIF.

    MOVE: ZTITBLK-FLAND   TO ZTITIP1-ISHCD,
          ZTITBLK-PLLOD   TO ZTITIP1-ISHNM,
          ZTITBLK-TLAND   TO ZTITIP1-ILDCD,
          ZTITBLK-PLTRN   TO ZTITIP1-ILDNM,
          SY-DATLO        TO ZTITIP1-TAPDT,
          SY-DATLO        TO ZTITIP1-IOPDT,  ">보험개시일.
          '22'            TO ZTITIP1-ENDCD,
          G_TC_2130_WA-EBELN TO ZTITIP1-EBELN,
          ZTITBLK-WAERS   TO ZTITIP1-IIVATC,
*          ZTITBLK-SMAMT   TO ZTITIP1-IIVAT,
          ZTITBLK-WAERS   TO ZTITIP1-ITOATC,
          ZTITBLK-WAERS   TO ZTITIP1-ICAATC,
          ZTITBLK-WAERS   TO ZTITIP1-IDUATC,
          T001-WAERS      TO ZTITIP1-ITPA1C,
          T001-WAERS      TO ZTITIP1-ITPA2C,
          T001-WAERS      TO ZTITIP1-ITPA3C,
          T001-WAERS      TO ZTITIP1-ICPAMC,
          T001-WAERS      TO ZTITIP1-IDPAMC,
          T001-WAERS      TO ZTITIP1-IVPAMC,
          T001-WAERS      TO ZTITIP1-ITEAMC,
          3               TO ZTITIP1-IPCON,  ">사본.
          4               TO ZTITIP1-IPORN,  ">원본.
          ZTITBLK-IVSLN   TO ZTITIP1-IVSLN,
*          'T.B.D'         TO ZTITIP1-IVSLN,
*---> 부보생성 시 Default 값 추가 by MSH
          '110'           TO ZTITIP1-IWART.

*> 선급금액 누적..
*    ZTITIP1-IIVAT = ZTITIP1-IIVAT + ZTITRQS-PPAMT.

*> 회사코드.
    CALL FUNCTION 'Z_TS_GET_COMPANY_EDI_DATA'
      EXPORTING
        BUKRS           = ZTITBLK-BUKRS
        APPCT           = ZTITBLK-APPCT
     IMPORTING
       YZTSTIG0        = ZTSTIG0
*       nztstig0        = ztstig0
       XT001            = T001
     EXCEPTIONS
       NOT_FOUND       = 1
       OTHERS          = 2 .
    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      MESSAGE ID SY-MSGID TYPE C_WARNING  NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    MOVE: ZTSTIG0-INSCP TO ZTITIP1-INSCP,  ">보험회사코드.
          ZTSTIG0-EOMNM TO ZTITIP1-IASNM1, ">피보험자.
          ZTSTIG0-EOMPR TO ZTITIP1-IASNM2, ">피보험자.
          ZTSTIG0-BUSID TO ZTITIP1-IAPID,  ">보험계약자.
          ZTSTIG0-EOMNM TO ZTITIP1-IAPNM,  "> ** 상호.
          ZTSTIG0-EOMPR TO ZTITIP1-IAPPR,  "> ** 대표자.
          ZTSTIG0-ESIGN TO ZTITIP1-IAPSG,  "> ** 전자서명.
          T001-WAERS    TO ZTITIP1-ICUATC, ">
          T001-WAERS    TO ZTITIP1-ICAATC,
          T001-WAERS    TO ZTITIP1-IDUATC.

*> Set 보험회사 관련 Default value
    IF NOT ZTITIP1-INSCP IS INITIAL.
      SELECT SINGLE *
        FROM ZTSTIG3
       WHERE PARTI   EQ   C_CHARP
         AND EPART   EQ   ZTITIP1-INSCP
*>by YSH(070817) 회사코드 추가
         AND BUKRS   EQ   ZTITIP1-BUKRS.

      IF SY-SUBRC EQ 0.
        MOVE: ZTSTIG3-IOPNO  TO ZTITIP1-IOPNO,
              ZTSTIG3-ICSNM  TO ZTITIP1-ICSNM,
              ZTSTIG3-EPART  TO ZTITIP1-RECID,
              ZTSTIG3-NAMET  TO ZTITIP1-RECNM,
              SPACE          TO ZTITIP1-DOCST,
              '9'            TO ZTITIP1-RECTR,
              'AB'           TO ZTITIP1-RECAS,
              ZTSTIG3-IWART  TO ZTITIP1-IWART, ">희망이익율.
              ZTSTIG3-ITOCP  TO ZTITIP1-ITOCP, ">공동인수사.
              ZTSTIG3-ITORT  TO ZTITIP1-ITORT, ">공동인수율.
              ZTSTIG3-NAMET  TO ZTITIP1-ICPNM,
*              TO ZTITIP1-ICPPR,
              ZTSTIG3-ESIGN  TO ZTITIP1-ICPID.
      ENDIF.
    ENDIF.

    IF ZTITIP1-IBLNO IS NOT INITIAL.

      SELECT SINGLE SMAMT
            FROM ZTITBLK
            INTO   ZTITIP1-IIVAT
           WHERE IBLNO EQ ZTITIP1-IBLNO.
    ENDIF.

    LOOP AT IT_TAB INTO G_TC_2130_WA.
      IF ZTITIP1-EBELN IS INITIAL.
        MOVE G_TC_2130_WA-EBELN TO ZTITIP1-EBELN.           ">상품명세1
      ENDIF.
      IF ZTITIP1-IGOTE1 IS INITIAL.
        MOVE G_TC_2130_WA-TXZ01 TO ZTITIP1-IGOTE1.          ">상품명세1
      ENDIF.
      IF ZTITIP1-IHSCD IS INITIAL.
        MOVE G_TC_2130_WA-STAWN TO ZTITIP1-IHSCD.  ">>H/S Code
      ENDIF.
      IF ZTITIP1-EBELN IS INITIAL.
        ZTITIP1-EBELN = G_TC_2130_WA-EBELN.
      ENDIF.

*      ZTITIP1-IIVAT = ZTITIP1-IIVAT +
*                     ( ( G_TC_2130_WA-NETPR / G_TC_2130_WA-PEINH )
*                      * G_TC_2130_WA-MENGE ) .
    ENDLOOP.

    CASE ZTITRQK-REQTY.
      WHEN 'LC'.
        MOVE: ZTITRQK-REQTY  TO ZTITIP1-IRECD2,
              ZTITRQS-OPNNO  TO ZTITIP1-IRENO2.
      WHEN 'TT'.
      WHEN 'PU'.
      WHEN 'LO'.
      WHEN 'DA'.
      WHEN 'DP'.
    ENDCASE.

    MOVE: 'POR'          TO ZTITIP1-IRECD,
          ZTITIP1-EBELN  TO ZTITIP1-IRENO.

*> 보험회사 코드.
    IF NOT ZTITIP1-INSCP IS INITIAL.
      SELECT SINGLE *
        FROM ZTSTIG3
       WHERE PARTI EQ C_CHARP
         AND EPART EQ ZTITIP1-INSCP.
    ENDIF.


    IF NOT ZTITRQS-ITECD IS INITIAL.
      SELECT SINGLE *
        INTO CORRESPONDING FIELDS OF G_TC_2210_WA
        FROM ZTSTIG4
       WHERE ITECD  EQ  ZTITRQS-ITECD.
      IF SY-SUBRC <> 0 .
*CHM2302-00480
        SELECT SINGLE *
        INTO CORRESPONDING FIELDS OF G_TC_2210_WA
        FROM ZTSTIG4
        WHERE ITECD_OLD  EQ  ZTITRQS-ITECD.
      ENDIF.
*}CHM2302-00480
      G_TC_2210_WA-ITETY = C_CHARB.
      APPEND G_TC_2210_WA TO G_TC_2210_ITAB.
*{ 기능개선 283274 - 추가_S
    ELSE.
      CLEAR : LV_FWDTY, LV_ITECD.

      IF ZTITBLK-FWDTY IS NOT INITIAL.
        LV_FWDTY = ZTITBLK-FWDTY.
      ELSE.
        LV_FWDTY = ZTITRQS-FWDTY.
      ENDIF.

*CHM2302-00480
*      CASE LV_FWDTY.
*        WHEN 'A'.    "항공 - 185
*          LV_ITECD = '185'.
*        WHEN 'O'.    "해상 - 184
*          LV_ITECD = '184'.
*      ENDCASE.
      CASE LV_FWDTY.
        WHEN 'A'.    "항공 - 185
          LV_ITECD = '014'.
        WHEN 'O'.    "해상 - 184
          LV_ITECD = '011'.
      ENDCASE.

*}CHM2302-00480
      IF LV_ITECD IS NOT INITIAL.
        SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF G_TC_2210_WA
          FROM ZTSTIG4
         WHERE ITECD = LV_ITECD.
        IF SY-SUBRC <> 0 .
          SELECT SINGLE *
            INTO CORRESPONDING FIELDS OF G_TC_2210_WA
            FROM ZTSTIG4
           WHERE ITECD_OLD = LV_ITECD.
        ENDIF.
        G_TC_2210_WA-ITETY = C_CHARB.
        APPEND G_TC_2210_WA TO G_TC_2210_ITAB.
      ENDIF.
*} 기능개선 283274 - 추가_E
    ENDIF.

*> 복사할 구매오더 헤더상의 부보필드.

    SELECT SINGLE *
      FROM ZTITIG30.

    CHECK SY-SUBRC EQ 0.

    SELECT SINGLE *
      FROM EKKO
     WHERE EBELN EQ ZTITIP1-EBELN.

    IF NOT ( ZTITIG30-ITECD  IS INITIAL AND
             ZTITIG30-ITECD1 IS INITIAL AND
             ZTITIG30-ITECD2 IS INITIAL AND
             ZTITIG30-ITECD3 IS INITIAL ).
      REFRESH: G_TC_2210_ITAB.
    ENDIF.
*> 복사규칙 Select.

    IF NOT ZTITIG30-ITECD IS INITIAL.

      CONCATENATE 'EKKO-' ZTITIG30-ITECD INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-ZZOFFER'.
      ASSIGN (L_FIELDNAME) TO <L_FS>.
      IF SY-SUBRC     EQ 0        AND
         NOT <L_FS>   IS INITIAL.
        SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF G_TC_2210_WA
          FROM ZTSTIG4
         WHERE ITECD  EQ  <L_FS>.

        IF SY-SUBRC EQ 0.
          G_TC_2210_WA-ITETY = C_CHARB.
          APPEND G_TC_2210_WA TO G_TC_2210_ITAB.
        ENDIF.
      ENDIF.
    ENDIF.
    IF NOT ZTITIG30-ITECD1 IS INITIAL.
      CONCATENATE 'EKKO-' ZTITIG30-ITECD1 INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-ZZOFFER'.
      ASSIGN (L_FIELDNAME) TO <L_FS>.
      IF SY-SUBRC     EQ 0        AND
         NOT <L_FS>   IS INITIAL.
        SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF G_TC_2210_WA
          FROM ZTSTIG4
         WHERE ITECD  EQ  <L_FS>.

        IF SY-SUBRC EQ 0.
          G_TC_2210_WA-ITETY = C_CHARA.
          APPEND G_TC_2210_WA TO G_TC_2210_ITAB.
        ENDIF.
      ENDIF.
    ENDIF.
    IF NOT ZTITIG30-ITECD2 IS INITIAL.
      CONCATENATE 'EKKO-' ZTITIG30-ITECD2 INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-ZZOFFER'.
      ASSIGN (L_FIELDNAME) TO <L_FS>.
      IF SY-SUBRC     EQ 0        AND
         NOT <L_FS>   IS INITIAL.
        SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF G_TC_2210_WA
          FROM ZTSTIG4
         WHERE ITECD  EQ  <L_FS>.

        IF SY-SUBRC EQ 0.
          G_TC_2210_WA-ITETY = C_CHARA.
          APPEND G_TC_2210_WA TO G_TC_2210_ITAB.
        ENDIF.
      ENDIF.
    ENDIF.
    IF NOT ZTITIG30-ITECD3 IS INITIAL.
      CONCATENATE 'EKKO-' ZTITIG30-ITECD3 INTO L_FIELDNAME.
*     l_fieldname = 'EKKO-ZZOFFER'.
      ASSIGN (L_FIELDNAME) TO <L_FS>.
      IF SY-SUBRC     EQ 0        AND
         NOT <L_FS>   IS INITIAL.
        SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF G_TC_2210_WA
          FROM ZTSTIG4
         WHERE ITECD  EQ  <L_FS>.

        IF SY-SUBRC EQ 0.
          G_TC_2210_WA-ITETY = C_CHARA.
          APPEND G_TC_2210_WA TO G_TC_2210_ITAB.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR: G_COUNT.
  LOOP AT  G_TC_2210_ITAB INTO G_TC_2210_WA.
    ADD 1 TO G_COUNT.
    G_TC_2210_WA-ITESQ = G_COUNT.
    MODIFY G_TC_2210_ITAB FROM G_TC_2210_WA.
  ENDLOOP.

ENDFORM.                    " MOVE_BL_ITEM_TO_ZTITIP1
*&---------------------------------------------------------------------*
*&      Form  CHECK_BL_ITEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_BL_ITEM USING P_CHK.
  DATA: LV_IIPNO    LIKE ZTITIP1-IIPNO.
  DATA: LS_ZTITIP1  LIKE ZTITIP1.
  CLEAR:  LV_IIPNO, LS_ZTITIP1.
  CLEAR P_CHK.

  IF IT_ZTITBLP-REQNO IS INITIAL. "사후

    SELECT SINGLE *
      INTO LS_ZTITIP1
      FROM ZTITIP1
     WHERE EBELN = IT_ZTITBLP-EBELN.

    IF SY-SUBRC = 0.
      IF LS_ZTITIP1-IBLNO IS INITIAL.
        P_CHK = 'X'.
      ENDIF.

    ENDIF.

  ELSE. "사전

    SELECT SINGLE *
      INTO LS_ZTITIP1
      FROM ZTITIP1
     WHERE REQNO = IT_ZTITBLP-REQNO.

    IF SY-SUBRC = 0.
      IF LS_ZTITIP1-IBLNO IS INITIAL.
        P_CHK = 'X'.
      ENDIF.
    ENDIF.

  ENDIF.


ENDFORM.                    " CHECK_BL_ITEM
