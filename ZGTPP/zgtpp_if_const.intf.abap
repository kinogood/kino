INTERFACE ZGTPP_IF_CONST
  PUBLIC .
*// 처리모드...........................................................................................
  CONSTANTS: BEGIN OF GC_MODE,
               CREATE  TYPE CHAR10 VALUE 'CREATE',
               CHANGE  TYPE CHAR10 VALUE 'CHANGE',
               DISPLAY TYPE CHAR10 VALUE 'DISPLAY',
               DELETE  TYPE CHAR10 VALUE 'DELETE',
             END   OF GC_MODE.

*// CRUD 지시자.
  CONSTANTS: BEGIN OF GC_CRUDQ,
               CREATE TYPE GHO_CRUD_INDICATOR VALUE 'C',
               READ   TYPE GHO_CRUD_INDICATOR VALUE 'R',
               UPDATE TYPE GHO_CRUD_INDICATOR VALUE 'U',
               DELETE TYPE GHO_CRUD_INDICATOR VALUE 'D',
             END OF GC_CRUDQ.

*// 처리결과...........................................................................................
  CONSTANTS: BEGIN OF GC_RESULT,
               SUCCESS TYPE C VALUE 'S',
               ERROR   TYPE C VALUE 'E',
               ABORT   TYPE C VALUE 'A',
               FAIL    TYPE C VALUE 'F',
             END OF GC_RESULT.

  CONSTANTS: BEGIN OF GC_IF_REC_RESULT,
               SUCCESS   TYPE ZO_RESULT VALUE '00',
               EAI_ERROR TYPE ZO_RESULT VALUE '01',
               SAP_ERROR TYPE ZO_RESULT VALUE '02',
             END OF GC_IF_REC_RESULT.

*// 선택.
  CONSTANTS: BEGIN OF GC_YN,
               YES TYPE CHAR01 VALUE 'Y',
               NO  TYPE CHAR01 VALUE 'N',
             END   OF GC_YN.

*// Parallel Processing 설정 : T-CODE : RZ11, Table: RZLLITAB.
  CONSTANTS: BEGIN OF GC_PARALLEL,
               SERVER_GROUP TYPE SPTA_RFCGR VALUE 'GAON_PP',
               PROCESSOR    TYPE INT4 VALUE '15',
               PACKAGE_SIZE TYPE INT4 VALUE '10',
             END   OF GC_PARALLEL.

*// 시스템 ID.
  CONSTANTS: BEGIN OF GC_SYSTEM_ID,
               KGPM TYPE CHAR04 VALUE 'KGPM', "// 가온전력 MES.
               KGOM TYPE CHAR04 VALUE 'KGOM', "// 가온통신 MES.
             END OF GC_SYSTEM_ID.

*// [BOM]..........................................................................................
*// BOM 범주.
  CONSTANTS GC_STLTY TYPE STKO-STLTY  VALUE 'M'. "- 자재 BOM.

*// BOM 용도.
  CONSTANTS: BEGIN OF GC_STLAN,
               PRODUCTION  TYPE MAST-STLAN VALUE '1', "- 생산.
               ENGINEERING TYPE MAST-STLAN VALUE '2', "- 엔지니어링/설계.
             END OF GC_STLAN.

*// 어플리케이션.
  CONSTANTS GC_CAPID TYPE CAPID VALUE 'PP01'. "- 생산 - 일반.

*// BOM 처리 모드.
  CONSTANTS: BEGIN OF GC_BOM_MODE,
               CREATE TYPE C VALUE 'C', "- 생성.
               UPDATE TYPE C VALUE 'U', "- 변경.
               DELETE TYPE C VALUE 'D', "- 삭제.
             END   OF GC_BOM_MODE.

*// 품목 범주(BOM).
  CONSTANTS: BEGIN OF GC_POSTP,
               L TYPE STPO-POSTP VALUE 'L', "- 재고 품목.
               N TYPE STPO-POSTP VALUE 'N', "- 비재고 품목.
               T TYPE STPO-POSTP VALUE 'T', "- 텍스트 품목.
             END OF GC_POSTP.

*// [Routing]......................................................................................
*// 태스크 리스트 유형.
  CONSTANTS GC_PLNTY TYPE MAPL-PLNTY  VALUE 'N'. "- 공정.

*// 직무리스트 어플리케이션.
  CONSTANTS GC_PLNAW TYPE TCA09-PLNAW VALUE 'P'. "- 생산 공정.

*// Routing 처리 모드.
  CONSTANTS: BEGIN OF GC_ROUTING_MODE,
               CREATE TYPE CP_TASK_LIST_MAINT_MODE VALUE 'C', "- 생성.
               MODIFY TYPE CP_TASK_LIST_MAINT_MODE VALUE 'M', "- 변경.
               DELETE TYPE CP_TASK_LIST_MAINT_MODE VALUE 'D', "- 삭제.
             END OF GC_ROUTING_MODE.

*// [Work Center]......................................................................................
*// CIM 자원 오브젝트유형.
  CONSTANTS GC_OBJTY TYPE CRHD-OBJTY  VALUE 'A'. "- 워크 센터.

*// 워크 센터 범주.
  CONSTANTS GC_VERWE TYPE CRHD-VERWE VALUE '0007'. "- 생산 라인.

*// [자재]...........................................................................................
*// 자재유형.
  CONSTANTS: BEGIN OF GC_MTART,
               MCHF TYPE MARA-MTART VALUE 'MCHF', "- 반제품.
               MCHA TYPE MARA-MTART VALUE 'MCHA', "- 상품.
               HAWA TYPE MARA-MTART VALUE 'HAWA', "- 상품.
               MRM1 TYPE MARA-MTART VALUE 'MRM1', "- 목드럼.
               MRM2 TYPE MARA-MTART VALUE 'MRM2', "- 철드럼, PT 보빈.
               MRM3 TYPE MARA-MTART VALUE 'MRM3', "- 드럼(자산 회수용).
             END OF GC_MTART.

*// 조달 유형.
  CONSTANTS: BEGIN OF GC_BESKZ,
               IN_HOUSE TYPE MARC-BESKZ VALUE 'E',
               EXTERNAL TYPE MARA-MTART VALUE 'F',
               BOTH     TYPE MARA-MTART VALUE 'X',
             END OF GC_BESKZ.

*// 단위
  CONSTANTS: BEGIN OF GC_MEINS,
               M  TYPE MARA-MEINS VALUE 'M',
               G  TYPE MARA-MEINS VALUE 'G',
               KG TYPE MARA-MEINS VALUE 'KG',
               EA TYPE MARA-MEINS VALUE 'EA',
             END OF GC_MEINS.

*// 할당 유형.
  CONSTANTS: BEGIN OF GC_ZASSIGN_TYPE,
               CT TYPE ZGTPPT2170-ZASSIGN_TYPE VALUE 'CT', "// 절단
               RW TYPE ZGTPPT2170-ZASSIGN_TYPE VALUE 'RW', "// 랜 박스류
               PC TYPE ZGTPPT2170-ZASSIGN_TYPE VALUE 'PC', "// Picking Lot 변경
               OI TYPE ZGTPPT2170-ZASSIGN_TYPE VALUE 'OI', "// 광 옥내
               EA TYPE ZGTPPT2170-ZASSIGN_TYPE VALUE 'EA', "// EA단위 품목
               AD TYPE ZGTPPT2170-ZASSIGN_TYPE VALUE 'AD', "// 난척 발생 분 추가
             END OF GC_ZASSIGN_TYPE.

*// 지시 유형.
  CONSTANTS: BEGIN OF GC_ZORD_TYPE,
               C0 TYPE ZGTPPT2180-ZORD_TYPE VALUE 'C0', "// 정조장.
               C1 TYPE ZGTPPT2180-ZORD_TYPE VALUE 'C1', "// 절단.
               C2 TYPE ZGTPPT2180-ZORD_TYPE VALUE 'C2', "// 랜 박스류.
               C3 TYPE ZGTPPT2180-ZORD_TYPE VALUE 'C3', "// 광 옥내.
               C5 TYPE ZGTPPT2180-ZORD_TYPE VALUE 'C5', "// EA단위 품목.
               C9 TYPE ZGTPPT2180-ZORD_TYPE VALUE 'C9', "// 재고 비활성
             END OF GC_ZORD_TYPE.

  CONSTANTS: BEGIN OF GC_ATNAM,
               PD_CA_PROC_NAME       TYPE ATNAM VALUE 'PD_CA_PROC_NAME',       "// 공정코드.
               PD_CA_SKID_YN         TYPE ATNAM VALUE 'PD_CA_SKID_YN',         "// SKIP유무.
               PD_GA_DRUM_GUBUN      TYPE ATNAM VALUE 'PD_GA_DRUM_GUBUN',      "// 드럼구분.
               PD_GA_PACKAGE_METHOD  TYPE ATNAM VALUE 'PD_GA_PACKAGE_METHOD',  "// 포장구분.
               PD_GA_FLANGE_PROT_YN  TYPE ATNAM VALUE 'PD_GA_FLANGE_PROT_YN',  "// 악판골판지.
               PD_GA_PRINT_METHOD    TYPE ATNAM VALUE 'PD_GA_PRINT_METHOD',    "// 프린트.
               PD_GA_NEW_DRUM_YN     TYPE ATNAM VALUE 'PD_GA_NEW_DRUM_YN',     "// 신드럼사용.
               PD_GA_WRAP_PACKING_YN TYPE ATNAM VALUE 'PD_GA_WRAP_PACKING_YN', "// 랩포장.
               PD_CA_COLOR_BASE      TYPE ATNAM VALUE 'PD_CA_COLOR_BASE',      "// 색상.
               SAP_MILLCA_LENGTH     TYPE ATNAM VALUE 'SAP_MILLCA_LENGTH',     "// 조장.
               SAP_MILLCA_FACTOR     TYPE ATNAM VALUE 'SAP_MILLCA_FACTOR',     "// 조장 수.
               PD_CA_DESIGN_NO       TYPE ATNAM VALUE 'PD_CA_DESIGN_NO',       "// 설계서 번호.
               PD_CA_DESIGN_REV_NO   TYPE ATNAM VALUE 'PD_CA_DESIGN_REV_NO',   "// 설계서 개정번호.
             END OF GC_ATNAM.

*// 공정
  CONSTANTS: BEGIN OF GC_PD_CA_PROC,
               REW TYPE ATNAM VALUE 'REW',
               ISH TYPE ATNAM VALUE 'ISH',
             END OF GC_PD_CA_PROC.

*// 처리 구분.
  CONSTANTS: BEGIN OF GC_UPD_TYPE,
               U1 TYPE ZGTPPT3360-UPD_TYPE VALUE 'U1', "// 절단 실적.
               Z1 TYPE ZGTPPT3360-UPD_TYPE VALUE 'Z1', "// 절단 실적 취소.
               U2 TYPE ZGTPPT3360-UPD_TYPE VALUE 'U2', "// 출하(랜 권취).
               Z2 TYPE ZGTPPT3360-UPD_TYPE VALUE 'Z2', "// 출하(랜 권취) 취소.
               U3 TYPE ZGTPPT3360-UPD_TYPE VALUE 'U3', "// 출하(일반) 스캔.
               Z3 TYPE ZGTPPT3360-UPD_TYPE VALUE 'Z3', "// 출하(일반) 스캔 취소.
             END OF GC_UPD_TYPE.

*// 재고 테이블.
  CONSTANTS: BEGIN OF GC_STOCK_TABLE,
               MARD TYPE ZGTESTOCK_TABLE VALUE 'MARD', "// 플랜트 재고.
               MCHB TYPE ZGTESTOCK_TABLE VALUE 'MCHB', "// 배치 배고.
               MSKA TYPE ZGTESTOCK_TABLE VALUE 'MSKA', "// 판매오더 재고.
             END OF GC_STOCK_TABLE.

  CONSTANTS:
    BEGIN OF GC_GM_CODE,
      GR_FOR_PO          TYPE BAPI2017_GM_CODE VALUE '01', " 구매 오더 입고 (MB01)
      GR_FOR_PROD_ORDER  TYPE BAPI2017_GM_CODE VALUE '02', " 생산 오더 입고 (MB31)
      GI_FOR_ORDER       TYPE BAPI2017_GM_CODE VALUE '03', " 자재 출고 (MB1A)
      TRANSFER_POSTING   TYPE BAPI2017_GM_CODE VALUE '04', " 이전 전기 (MB1B)
      OTHER_GR           TYPE BAPI2017_GM_CODE VALUE '05', " 기타 입고 (MB1C)
      REVERSAL           TYPE BAPI2017_GM_CODE VALUE '06', " 자재 이동/취소 (MB11)
      SUBCONTRACT_ADJUST TYPE BAPI2017_GM_CODE VALUE '07', " 외주 소비 조정 (MB04)
    END OF GC_GM_CODE.

*// 수기 등록 유형.
  CONSTANTS: BEGIN OF GC_ZMANUAL_TYPE,
               M1 TYPE ZGTPPT2300-ZMANUAL_TYPE VALUE 'M1', "// 수기 물량 추가.
               S1 TYPE ZGTPPT2300-ZMANUAL_TYPE VALUE 'S1', "// 판매주문 추가.
               S2 TYPE ZGTPPT2300-ZMANUAL_TYPE VALUE 'S2', "// 판매주문 제외.
             END OF GC_ZMANUAL_TYPE.

*// 처리유형.
  CONSTANTS: BEGIN OF GC_ITEM_TYPE,
               A TYPE ZPPT0610-ITEM_TYPE VALUE 'A', "// 재고실사 차이 조정.
               B TYPE ZPPT0610-ITEM_TYPE VALUE 'B', "// 스크랩 처리.
             END OF GC_ITEM_TYPE.

ENDINTERFACE.
