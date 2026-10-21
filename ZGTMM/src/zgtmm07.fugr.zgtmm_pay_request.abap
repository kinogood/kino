FUNCTION ZGTMM_PAY_REQUEST.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_APPID) TYPE  CHAR32
*"     VALUE(I_STATE) TYPE  CHAR10
*"  EXPORTING
*"     VALUE(MTYPE) TYPE  BAPI_MTYPE
*"     VALUE(MESSAGE) TYPE  BAPI_MSG
*"----------------------------------------------------------------------
  DATA : LT_SAVE TYPE TABLE OF ZGTMMT5010.

*--APPID기준 결재 정보 확인
  SELECT FROM ZGTMMT5010
    FIELDS *
    WHERE APPID = @I_APPID
    INTO TABLE @DATA(LT_5010).

LT_SAVE = VALUE #( BASE LT_SAVE FOR LS_5010 IN LT_5010

               ( VALUE #(  BASE CORRESPONDING #( LS_5010 )
               STATUS = I_STATE
                                  AEDAT = SY-DATUM
                                  AEDAT_LOCAL = SY-DATLO
                                  AETIM = SY-UZEIT
                                  AETIM_LOCAL = SY-TIMLO
                                  AENAM = SY-UNAME ) ) ) .

 MODIFY ZGTMMT5010 FROM TABLE LT_SAVE.

 IF SY-SUBRC = 0.
      COMMIT WORK AND WAIT.
      MTYPE     = 'S'.
      MESSAGE = '결재 진행 상태가 등록 되었습니다.'(M01).
 ELSE.
      MTYPE     = 'S'.
      MESSAGE = '결재 진행 상태 저장  실패'(M04).
 ENDIF.

ENDFUNCTION.
