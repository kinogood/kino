*&---------------------------------------------------------------------*
*& Include          ZGTPPR3190S01
*&---------------------------------------------------------------------*
 SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001. "검색 조건
   PARAMETERS : P_WERKS LIKE MARD-WERKS OBLIGATORY. "플랜트
   SELECT-OPTIONS: S_MATNR FOR MARD-MATNR,          "자재코드
                   S_MTART FOR MARA-MTART,          "자재유형
                   S_MATKL FOR MARA-MATKL,          "자재그룹
                   S_LGORT FOR MARD-LGORT,          "저장위치
                   S_CHARG FOR MCHB-CHARG,          "배치번호
                   S_PRJNO FOR VBAK-ZPJNO,          "프로젝트번호
                   S_PONO  FOR VBAK-BSTNK,          "PO번호
                   S_VBELN FOR MSKA-VBELN,          "판매오더
                   S_POSNR FOR MSKA-POSNR,          "판매오더 아이템
                   S_LIFNR FOR MSLB-LIFNR,          "공급업체 코드
                   S_DISPO FOR MARC-DISPO,          "MRP관리자
                   S_AUFNR FOR AUFK-AUFNR,          "생산오더번호
                   S_EBELN FOR EKKO-EBELN,          "구매오더번호
                   S_TAGNR FOR ZPPT0001-TAGNR.      "꼬리표번호

   SELECTION-SCREEN SKIP 1.
   PARAMETERS: P_C1 AS CHECKBOX.  "완제품에 투입 목드럼 포함 조회
   PARAMETERS: P_C2 AS CHECKBOX.  "할당 정보 포함 조회
 SELECTION-SCREEN END OF BLOCK B1.

 SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-002. "레이아웃 선택
   PARAMETERS: P_LAYO LIKE DISVARIANT-VARIANT.      "레이아웃
 SELECTION-SCREEN END OF BLOCK B2.
