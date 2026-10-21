FUNCTION-POOL zgtsd61                       MESSAGE-ID zgtsd01.

*-----------------------------------------------------------------------
*-- Tables
*-----------------------------------------------------------------------
TABLES : zgtsdt9000,
         zgtsdt0065, zgtsdt0068, zgtsdt0069,
         mara, marc, mard, mchb, mska,
         humseg.

*-----------------------------------------------------------------------
*-- Types
*-----------------------------------------------------------------------
*-- I/F 수신 결과 메세지 정보 Types
TYPES : BEGIN OF gty_rst_if,
          zifrfc       TYPE zgte_ifrfc,         " RFC 이름
          zifkey       TYPE timestampl,         " I/F Key
          zsystem_id   TYPE zgtetarget,         " Interface Target 시스템

          zstat	       TYPE zgtestat,           " 전송상태
          zmessage     TYPE zgtemsg,            " 전송 Msg
          zerp_stat	   TYPE zgtestat_p,         " 처리상태(수신 I/F 사용)
          zerp_message TYPE zgtemsg_p,          " 처리메시지(수신 I/F 사용)
        END OF gty_rst_if.

*-- Table : ZGTSDT9000 Types
TYPES : gty_db_9000     TYPE zgtsdt9000,
        gty_t_db_9000   TYPE TABLE OF gty_db_9000   WITH EMPTY KEY,
*-- Table : ZGTSDT0065 Types
        gty_db_u_0065   TYPE zgtsdt0065             WITH INDICATORS ind,
        gty_t_db_u_0065 TYPE TABLE OF gty_db_u_0065 WITH EMPTY KEY,
*-- Table : ZGTSDT0068 Types
        gty_db_u_0068   TYPE zgtsdt0068             WITH INDICATORS ind,
        gty_t_db_u_0068 TYPE TABLE OF gty_db_u_0068 WITH EMPTY KEY,
*-- Table : ZGTSDT9000 Update Indicator Types
        gty_db_u_9000   TYPE zgtsdt9000             WITH INDICATORS ind,
        gty_t_db_u_9000 TYPE TABLE OF gty_db_u_9000 WITH EMPTY KEY.

*-----------------------------------------------------------------------
*-- Types
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
*-- Field-Symbols
*-----------------------------------------------------------------------
FIELD-SYMBOLS <tn>.

*-----------------------------------------------------------------------
*-- Internal Table
*-----------------------------------------------------------------------
*       Batchinputdata of single transaction
DATA:   gt_bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
*       messages of call transaction
DATA:   gt_messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.

DATA : gt_return  TYPE bapiret2  OCCURS 0 WITH HEADER LINE."메세지

*포장실적 생성
DATA : BEGIN OF gt_iftab OCCURS 0.
DATA: exidv      LIKE zgtsdt0069-exidv,
      zflag      LIKE zgtsdt0069-zflag,
      pflag      LIKE zgtsdt0069-pflag,
      inidv      LIKE zgtsdt0069-inidv,
      leg_rqno   LIKE zgtsdt0069-leg_rqno,
      sort_seq   LIKE zgtsdt0069-sort_seq,
      ifnum      LIKE zgtsdt0069-ifnum,
      werkscf    LIKE zgtsdt0069-werkscf,
      crdat      LIKE zgtsdt0069-crdat,
      crtim      LIKE zgtsdt0069-crtim,
      zregp      LIKE zgtsdt0069-zregp,
      zregdt     LIKE zgtsdt0069-zregdt,
      zmodp      LIKE zgtsdt0069-zmodp,
      zmoddt     LIKE zgtsdt0069-zmoddt,
      vhilm      LIKE zgtsdt0069-vhilm,
      werks      LIKE zgtsdt0069-werks,
      matnr      LIKE zgtsdt0069-matnr,
      lfimg      LIKE zgtsdt0069-lfimg,
      lgort      LIKE zgtsdt0069-lgort,
      umlgo      LIKE zgtsdt0069-umlgo,
      charg      LIKE zgtsdt0069-charg,
      sobkz      LIKE zgtsdt0069-sobkz,
      lsonr      LIKE zgtsdt0069-lsonr,
      mjahr      LIKE zgtsdt0069-mjahr,
      mblnr      LIKE zgtsdt0069-mblnr,
      budat      LIKE zgtsdt0069-budat,
      mjahr2     LIKE zgtsdt0069-mjahr2,
      mblnr2     LIKE zgtsdt0069-mblnr2,

      zifkey     LIKE zgtsdt0069-zifkey,
      zsystem_id LIKE zgtsdt0069-zsystem_id,
      ifsap      LIKE zgtsdt0069-ifsap,
      ifeai      LIKE zgtsdt0069-ifeai,
      ifleg      LIKE zgtsdt0069-ifleg,
      sap_ctim   LIKE zgtsdt0069-sap_ctim,
      zeret      LIKE zgtsdt0069-zeret,
      zetxt      LIKE zgtsdt0069-zetxt,

      aedat      LIKE zgtsdt0069-aedat,
      aezet      LIKE zgtsdt0069-aezet,
      aenam      LIKE zgtsdt0069-aenam,

      413_flag TYPE c LENGTH 1.
DATA: END OF gt_iftab.
*-----------------------------------------------------------------------
*-- Values & Structure
*-----------------------------------------------------------------------
*       BDC Option
DATA:   gs_ctu_params LIKE ctu_params.

*-----------------------------------------------------------------------
*-- CONSTANTS
*-----------------------------------------------------------------------
CONSTANTS : gc_update  TYPE char01              VALUE 'U',          " 업데이트
            gc_insert  TYPE char01              VALUE 'I',          " 삽입
            gc_delete  TYPE char01              VALUE 'D',          " 삭제
            gc_success TYPE char02              VALUE '00',         " Transaction 성공
            gc_error1  TYPE char02              VALUE '01',         " 실패
            gc_error   TYPE char02              VALUE '02',         " Transaction 실패\
            gc_error3  TYPE char02              VALUE '03',         " Transaction 실패
            gc_susap   TYPE char01              VALUE 'Y',          " Transaction 성공
            gc_ersap   TYPE char01              VALUE 'N',          " Transaction 실패

            gc_table69 TYPE tabname             VALUE 'ZGTSDT0069'.

*-- Range Sign
CONSTANTS : BEGIN OF gc_sign,
              i TYPE ddsign                     VALUE 'I',
              e TYPE ddsign                     VALUE 'E',
            END OF gc_sign,
*-- Range Option
            BEGIN OF gc_optn,
              eq TYPE ddoption                  VALUE 'EQ',
              ne TYPE ddoption                  VALUE 'NE',
              bt TYPE ddoption                  VALUE 'BT',
              cp TYPE ddoption                  VALUE 'CP',
            END OF gc_optn,
*-- 통화단위
            BEGIN OF gc_waerk,
              krw TYPE waerk                    VALUE 'KRW',
              usd TYPE waerk                    VALUE 'USD',
            END OF gc_waerk.

*-----------------------------------------------------------------------
*-- DEFINE
*-----------------------------------------------------------------------
DEFINE cls.
  CLEAR &1.
  REFRESH &1.
END-OF-DEFINITION.

DEFINE __RNG.
  &1-SIGN   = &2.
  &1-OPTION = &3.
  &1-LOW    = &4.
  &1-HIGH    = &5.
  APPEND &1. CLEAR &1.
END-OF-DEFINITION.


* INCLUDE LZGTSD60D...                       " Local class definition
