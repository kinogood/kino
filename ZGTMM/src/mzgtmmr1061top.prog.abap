*&---------------------------------------------------------------------*
*& Include MZNF0020TOP                                       모듈풀    *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  sapmznf0020 MESSAGE-ID znf1.

*----------------------------------------------------------------------*
*   TABLES
*----------------------------------------------------------------------*
TABLES : znft0002,  "월별 비철시세관리(기준정보)
         znft0069,  "월별 비철시세 이자관리(기준정보)
         hrvcost,   "BDC 관련
         t100.      "메세지

*----------------------------------------------------------------------*
*   DATA
*----------------------------------------------------------------------*
DATA : gt_znft0002 LIKE znft0002 OCCURS 0 WITH HEADER LINE,
       gt_znft0069 LIKE znft0069 OCCURS 0 WITH HEADER LINE,

       gv_cu1_o_cash       LIKE znft0002-o_cash,
       gv_cu1_o_cash_waers LIKE znft0002-o_cash_waers,

       gv_cu3_o_cash       LIKE znft0002-o_cash,
       gv_cu3_o_cash_waers LIKE znft0002-o_cash_waers,

       gv_al1_o_cash       LIKE znft0002-o_cash,
       gv_al1_o_cash_waers LIKE znft0002-o_cash_waers,

       gv_al2_o_cash       LIKE znft0002-o_cash,
       gv_al2_o_cash_waers LIKE znft0002-o_cash_waers,

       gv_pb1_o_cash       LIKE znft0002-o_cash,
       gv_pb1_o_cash_waers LIKE znft0002-o_cash_waers,

       gv_sn1_o_cash       LIKE znft0002-o_cash,
       gv_sn1_o_cash_waers LIKE znft0002-o_cash_waers,

       gv_ni1_o_cash       LIKE znft0002-o_cash,
       gv_ni1_o_cash_waers LIKE znft0002-o_cash_waers,

       gv_pe1_o_cash       LIKE znft0002-o_cash,
       gv_pe1_o_cash_waers LIKE znft0002-o_cash_waers,

       bdctab  LIKE bdcdata    OCCURS 0 WITH HEADER LINE,
       messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE,

       gv_cu1_o_cash_c(5) VALUE '    1',
       gv_cu3_o_cash_c(5) VALUE '1,000',
       gv_al1_o_cash_c(5) VALUE '    1',
       gv_al2_o_cash_c(5) VALUE '1,000',
       gv_pb1_o_cash_c(5) VALUE '    1',
       gv_sn1_o_cash_c(5) VALUE '    1',
       gv_ni1_o_cash_c(5) VALUE '    1',
       gv_pe1_o_cash_c(5) VALUE '    1',

       gv_rate1 LIKE znft0069-rate,
       gv_rate2 LIKE znft0069-rate.
