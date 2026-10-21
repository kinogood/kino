FUNCTION-POOL ZGTMM10.                      "MESSAGE-ID ..
* INCLUDE LZGTMM10D...                       " LOCAL CLASS DEFINITION

DATA :
  GT_9000   LIKE TABLE OF ZGTMMT9000,
  GT_RETURN LIKE TABLE OF BAPIRET2.

DATA :
  GT_PRICE LIKE TABLE OF ZGTMMS1001.   "IT_PRICE  ZGTMMS1013

DATA :
  GS_9000   LIKE ZGTMMT9000,
  GS_RETURN LIKE  BAPIRET2,
  GS_MSG    LIKE ZGTMMS1002.

DATA :
  GV_SYSTEM_ID TYPE ZGTE_IF_TARGET,
  GV_BUDAT     LIKE MATDOC-BUDAT.


TYPES : BEGIN OF TY_4403,
          BUKRS     TYPE BUKRS,
          ZREQ_TYPE TYPE ZGTE_REQTYPE,
          DLVRQ     TYPE ZEDLVRQ,
          VBELN     TYPE VBELN_VA,
          POSNR     TYPE POSNR_VA,
          EBELN     TYPE EBELN,
          EBELP     TYPE EBELP,
          ZSEQ      TYPE ZGTMMT4403-ZSEQ,
        END OF TY_4403.
DATA : GT_4403 TYPE TABLE OF TY_4403.

TYPES : BEGIN OF TY_4405,
          BUKRS     TYPE BUKRS,
          ZREQ_TYPE TYPE ZGTE_REQTYPE,
          DLVRQ     TYPE ZEDLVRQ,
          VBELN     TYPE VBELN_VA,
          POSNR     TYPE POSNR_VA,
          ZSEQ      TYPE ZGTMMT4405-ZSEQ,
        END OF TY_4405.
DATA : GT_4405 TYPE TABLE OF TY_4405.

CONSTANTS :
  GC_A(1)    VALUE 'A',
  GC_B(1)    VALUE 'B',
  GC_C(1)    VALUE 'C',
  GC_D(1)    VALUE 'D',
  GC_E(1)    VALUE 'E',
  GC_H(1)    VALUE 'H',
  GC_I(1)    VALUE 'I',
  GC_J(1)    VALUE 'J',
  GC_R(1)    VALUE 'R',
  GC_N(1)    VALUE 'N',
  GC_S(1)    VALUE 'S',
  GC_T(1)    VALUE 'T',
  GC_U(1)    VALUE 'U',
  GC_W(1)    VALUE 'W',
  GC_X(1)    VALUE 'X',
  GC_Y(1)    VALUE 'Y',
  GC_1(1)    VALUE '1',
  GC_2(1)    VALUE '2',
  GC_5(1)    VALUE '5',
  GC_AB(2)   VALUE 'AB',
  GC_AU(2)   VALUE 'AU',
  GC_OK(2)   VALUE 'OK',
  GC_EQ(2)   VALUE 'EQ',
  GC_00(2)   VALUE '00',
  GC_01(2)   VALUE '01',
  GC_02(2)   VALUE '02',
  GC_03(2)   VALUE '03',
  GC_000(3)  VALUE '000',
  GC_KRW(3)  VALUE 'KRW',
  GC_0001(4) VALUE '0001'.


CONSTANTS:
  GC_MM00026 TYPE C LENGTH 7 VALUE 'MM00026',
  GC_MM00030 TYPE C LENGTH 7 VALUE 'MM00030',
  GC_MM00031 TYPE C LENGTH 7 VALUE 'MM00031',
  GC_MM00048 TYPE C LENGTH 7 VALUE 'MM00048',  "[직송관리]배차정보수신(TRUCK_INFO)
  GC_MM00062 TYPE C LENGTH 7 VALUE 'MM00062'.  "납품문서 입고 실적 전송(GR_RESULT_SEND)

*----------------------------------------------------------------------*
* ZGTMM_IF_I_INFODATA_RCV "단가 계약 정보 수신(G-SRM->SAP)
*----------------------------------------------------------------------*
DATA :
  GS_9230 LIKE ZGTMMT9230,
  GS_9231 LIKE ZGTMMT9231,
  GS_9232 LIKE ZGTMMT9232,
  GS_1040 LIKE ZGTMMT1040.

DATA :
  GT_9230 LIKE TABLE OF ZGTMMT9230,
  GT_9231 LIKE TABLE OF ZGTMMT9231,
  GT_9232 LIKE TABLE OF ZGTMMT9232,
  GT_1040 LIKE TABLE OF ZGTMMT1040.

*----------------------------------------------------------------------*
* ZGTMM_IF_I_POCONFIRM "구매 오더 확정/반려 정보 수신(G-SRM->SAP)
*----------------------------------------------------------------------*
DATA :
GS_9240 LIKE ZGTMMT9240.

*----------------------------------------------------------------------*
* ZGTMM_IF_I_DRUM_RESULT_RCV "목드럼 작업 실적 수신(G-SRM->SAP)
*----------------------------------------------------------------------*
DATA :
  GT_9300 LIKE TABLE OF ZGTMMT9300,
  GT_9301 LIKE TABLE OF ZGTMMT9301,
  GT_1042 LIKE TABLE OF ZGTMMT1042.
