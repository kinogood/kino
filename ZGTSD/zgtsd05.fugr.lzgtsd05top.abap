FUNCTION-POOL zgtsd05                     MESSAGE-ID zgtsd01.
*-----------------------------------------------------------------------
*-- Tables
*-----------------------------------------------------------------------
TABLES : zgtsdt0069,
         mara, marc, mard, mchb, mska,
         humseg.

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

DATA : gt_1020 TYPE TABLE OF zgtsdt1020 WITH HEADER LINE.

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

      413_flag   TYPE c LENGTH 1.
DATA: END OF gt_iftab.

DATA : BEGIN OF gs_so_his,
         zseqno          TYPE zgtsdt1013-zseqno,
         vbeln           TYPE zgtsdt1013-vbeln,
         changenr        TYPE cdpos-changenr,
         posnr           TYPE zgtsdt1014-posnr,
         approved_status TYPE zgtsdt1013-approved_status,
         trtyp           TYPE zgtsdt1013-trtyp,
         tabname         TYPE cdpos-tabname,
         fname           TYPE cdpos-fname,
         chngind         TYPE cdpos-chngind,
         value_old       TYPE cdpos-value_old,
         value_new       TYPE cdpos-value_new,
         fldtxt          TYPE as4text,
         zlevel          TYPE char10,
         cuky_new        TYPE cdpos-cuky_new,
         cuky_old        TYPE cdpos-cuky_old,
         tabkey          TYPE cdpos-tabkey,
         udate           TYPE cdhdr-udate,
         utime           TYPE cdhdr-utime,
         tcode           TYPE cdhdr-tcode,
         userid          TYPE cdhdr-username,
         username        TYPE lfa1-name1,
         fpltr           TYPE fpltr,
         abgru           TYPE abgru,
       END OF gs_so_his.

TYPES: BEGIN OF gty_mst,
         fld_01 LIKE zgtppt1010-fld_01,
         fld_02 LIKE zgtppt1010-fld_02,
         fld_04 LIKE zgtppt1010-fld_04,
         fld_06 LIKE zgtppt1010-fld_06,
       END OF gty_mst.

DATA: gt_mst TYPE STANDARD TABLE OF gty_mst.
*-----------------------------------------------------------------------
*-- Values & Structure
*-----------------------------------------------------------------------
*       BDC Option
DATA:   gs_ctu_params LIKE ctu_params.
DATA: gv_erdat LIKE sy-datum,
      gv_erzet LIKE sy-uzeit,
      gv_stamp TYPE timestampl.
DATA : gv_error.
DATA : gv_result TYPE n LENGTH 2.
DATA : gv_message TYPE string.
DATA : gv_mode LIKE hrvcost-mode.


DATA : BEGIN OF bdc_tab OCCURS 0.
         INCLUDE STRUCTURE bdcdata.
DATA : END OF bdc_tab.
DATA   BEGIN OF gt_msg OCCURS 0.
INCLUDE STRUCTURE bdcmsgcoll.
DATA   END OF gt_msg.
*... Added by sdc11
DATA: mode TYPE c VALUE 'N'.


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

DEFINE __rng.
  &1-sign   = &2.
  &1-option = &3.
  &1-low    = &4.
  &1-high    = &5.
  APPEND &1. CLEAR &1.
END-OF-DEFINITION.

DEFINE _clear.
  REFRESH &1. CLEAR : &1, &1[].
END-OF-DEFINITION.
* INCLUDE LZGTSD01D...                       " Local class definition
