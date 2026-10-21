*&---------------------------------------------------------------------*
*& Include MZNF0010TOP                                       모듈풀    *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  sapmznf0010 MESSAGE-ID znf1.

*----------------------------------------------------------------------*
*   TABLES
*----------------------------------------------------------------------*
TABLES : znft0001,  "일별 비철시세관리(기준정보)
         hrvcost,   "BDC 관련
         t100.      "메세지

*----------------------------------------------------------------------*
*   DATA
*----------------------------------------------------------------------*
DATA : gt_znft0001 LIKE znft0001 OCCURS 0 WITH HEADER LINE,

       gv_cu1_o_cash       LIKE znft0001-o_cash,
       gv_cu1_o_cash_waers LIKE znft0001-o_cash_waers,
       gv_cu1_c_cash       LIKE znft0001-c_cash,
       gv_cu1_c_cash_waers LIKE znft0001-c_cash_waers,
       gv_cu1_c_3m         LIKE znft0001-c_3m,
       gv_cu1_c_3m_waers   LIKE znft0001-c_3m_waers,
       gv_cu1_c_b,
       gv_cu1_spread       LIKE znft0001-spread,
       gv_cu1_spread_waers LIKE znft0001-spread_waers,
       gv_cu1_stock        LIKE znft0001-stock,
       gv_cu1_meins        LIKE znft0001-meins,
       gv_cu1_c_6m         LIKE znft0001-c_6m,
       gv_cu1_c_6m_waers   LIKE znft0001-c_6m_waers,

       gv_cu2_c_cash       LIKE znft0001-c_cash,
       gv_cu2_c_cash_waers LIKE znft0001-c_cash_waers,
       gv_cu2_stock        LIKE znft0001-stock,
       gv_cu2_meins        LIKE znft0001-meins,
       gv_cu2_shfe_1m      LIKE znft0001-shfe_1m,
       gv_cu2_shfe_1m_waers(3) VALUE 'RMB',
       gv_cu2_shfe_logic1  LIKE ZNFT0001-C_VAT,          "증치세
       gv_cu2_shfe_logic2  LIKE ZNFT0001-C_EXCHANGE,     "달러 / 위안 환율

       gv_cu3_c_cash       LIKE znft0001-c_cash,
       gv_cu3_c_cash_waers LIKE znft0001-c_cash_waers,

       gv_al1_o_cash       LIKE znft0001-o_cash,
       gv_al1_o_cash_waers LIKE znft0001-o_cash_waers,
       gv_al1_c_cash       LIKE znft0001-c_cash,
       gv_al1_c_cash_waers LIKE znft0001-c_cash_waers,
       gv_al1_c_3m         LIKE znft0001-c_3m,
       gv_al1_c_3m_waers   LIKE znft0001-c_3m_waers,
       gv_al1_c_b,
       gv_al1_spread       LIKE znft0001-spread,
       gv_al1_spread_waers LIKE znft0001-spread_waers,
       gv_al1_stock        LIKE znft0001-stock,
       gv_al1_meins        LIKE znft0001-meins,
       gv_al1_c_6m         LIKE znft0001-c_6m,
       gv_al1_c_6m_waers   LIKE znft0001-c_6m_waers,

       gv_pb1_o_cash       LIKE znft0001-o_cash,
       gv_pb1_o_cash_waers LIKE znft0001-o_cash_waers,
       gv_pb1_c_cash       LIKE znft0001-c_cash,
       gv_pb1_c_cash_waers LIKE znft0001-c_cash_waers,
       gv_pb1_c_3m         LIKE znft0001-c_3m,
       gv_pb1_c_3m_waers   LIKE znft0001-c_3m_waers,
       gv_pb1_c_b,
       gv_pb1_spread       LIKE znft0001-spread,
       gv_pb1_spread_waers LIKE znft0001-spread_waers,
       gv_pb1_stock        LIKE znft0001-stock,
       gv_pb1_meins        LIKE znft0001-meins,
       gv_pb1_c_6m         LIKE znft0001-c_6m,
       gv_pb1_c_6m_waers   LIKE znft0001-c_6m_waers,

       gv_ni1_o_cash       LIKE znft0001-o_cash,
       gv_ni1_o_cash_waers LIKE znft0001-o_cash_waers,
       gv_ni1_c_cash       LIKE znft0001-c_cash,
       gv_ni1_c_cash_waers LIKE znft0001-c_cash_waers,
       gv_ni1_c_3m         LIKE znft0001-c_3m,
       gv_ni1_c_3m_waers   LIKE znft0001-c_3m_waers,
       gv_ni1_c_b,
       gv_ni1_spread       LIKE znft0001-spread,
       gv_ni1_spread_waers LIKE znft0001-spread_waers,

       gv_sn1_o_cash       LIKE znft0001-o_cash,
       gv_sn1_o_cash_waers LIKE znft0001-o_cash_waers,
       gv_sn1_c_cash       LIKE znft0001-c_cash,
       gv_sn1_c_cash_waers LIKE znft0001-c_cash_waers,

       gv_pe1_o_cash       LIKE znft0001-o_cash,
       gv_pe1_o_cash_waers LIKE znft0001-o_cash_waers,
       gv_pe1_c_cash       LIKE znft0001-c_cash,
       gv_pe1_c_cash_waers LIKE znft0001-c_cash_waers,

       bdctab  LIKE bdcdata    OCCURS 0 WITH HEADER LINE,
       messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE,

       GV_ANSWER TYPE CHAR01. "팝업 대답메시지
