*&---------------------------------------------------------------------*
*& Report ZGTTEST_003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGTTEST_003.


DATA: LS_YMCHA TYPE MCHA,
          LT_RETURN TYPE TABLE OF BAPIRET2.

LS_YMCHA-MATNR = '000000000002127101'.
LS_YMCHA-WERKS = '1306'.
LS_YMCHA-CHARG = 'TEST003'.
LS_YMCHA-ZZPJT_NO = 'PD12345678'.
LS_YMCHA-ZZJOB_NO = '12345678'.
LS_YMCHA-ZZLINE_NO = 'LINE0'.
LS_YMCHA-ZZSERIAL_INFO = '00100'.

*
*CALL FUNCTION 'VB_CREATE_BATCH'
*  EXPORTING
*    ymcha                              = LS_YMCHA
*  TABLES
*    RETURN                            = LT_RETURN
          .

CALL FUNCTION 'VB_CREATE_BATCH'
  EXPORTING
    ymcha                              = LS_YMCHA
 TABLES
   RETURN                             = LT_RETURN
 EXCEPTIONS
   NO_MATERIAL                        = 1
   NO_BATCH                           = 2
   NO_PLANT                           = 3
   MATERIAL_NOT_FOUND                 = 4
   PLANT_NOT_FOUND                    = 5
   STOLOC_NOT_FOUND                   = 6
   LOCK_ON_MATERIAL                   = 7
   LOCK_ON_PLANT                      = 8
   LOCK_ON_BATCH                      = 9
   LOCK_SYSTEM_ERROR                  = 10
   NO_AUTHORITY                       = 11
   BATCH_EXIST                        = 12
   STOLOC_EXIST                       = 13
   ILLEGAL_BATCH_NUMBER               = 14
   NO_BATCH_HANDLING                  = 15
   NO_VALUATION_AREA                  = 16
   VALUATION_TYPE_NOT_FOUND           = 17
   NO_VALUATION_FOUND                 = 18
   ERROR_AUTOMATIC_BATCH_NUMBER       = 19
   CANCELLED                          = 20
   WRONG_STATUS                       = 21
   INTERVAL_NOT_FOUND                 = 22
   NUMBER_RANGE_NOT_EXTERN            = 23
   OBJECT_NOT_FOUND                   = 24
   ERROR_CHECK_BATCH_NUMBER           = 25
   NO_EXTERNAL_NUMBER                 = 26
   NO_CUSTOMER_NUMBER                 = 27
   NO_CLASS                           = 28
   ERROR_IN_CLASSIFICATION            = 29
   INCONSISTENCY_IN_KEY               = 30
   REGION_OF_ORIGIN_NOT_FOUND         = 31
   COUNTRY_OF_ORIGIN_NOT_FOUND        = 32
   VENDOR_ERROR                       = 33
   OTHERS                             = 34
          .


IF sy-subrc <> 0.
   "배치마스터 생성 도중 오류가 발생하였습니다.
ELSE.
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
   EXPORTING
     WAIT          = 'X'
*   IMPORTING
*     RETURN        =
            .

  WRITE: 'SUCCESS'.

ENDIF.
