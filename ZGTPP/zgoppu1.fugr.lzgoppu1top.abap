FUNCTION-POOL ZGOPPU1   MESSAGE-ID ZGTPP00.                      "MESSAGE-ID ..

DATA G_SUBRC TYPE SY-SUBRC.
DATA G_FLAG.
* INCLUDE LZGOPPU1D...                       " Local class definition
TYPE-POOLS : ABAP, RSDS.


FIELD-SYMBOLS: <DYN_TABLE>     TYPE STANDARD TABLE,
               <DYN_TABLE2>    TYPE STANDARD TABLE,
               <DYN_TABLE_OLD> TYPE STANDARD TABLE,
               <DYN_WA>,
               <DYN_FIELD>.
DATA: DY_TABLE     TYPE REF TO DATA,
      DY_TABLE_OLD TYPE REF TO DATA,
      DY_LINE      TYPE REF TO DATA,
      XFC          TYPE LVC_S_FCAT,
      IFC          TYPE LVC_T_FCAT,
      G_INIT_200,
      G_TITLE      LIKE SYST-TITLE.

*view 테이블 정보 담겨있는 테이블
DATA GS_ZFIT0113 LIKE ZFIT0113.

* Maintenance Table에 회사코드(BUKRS)가 존재하는지 여부
DATA: G_BUKRS_EXIST(1),
      G_SELOPT_BUKRS LIKE BKPF-BUKRS.

*View 테이블에서 데이타에 대한 sql의 where 절
DATA G_RSDS_WHERE TYPE  RSDS_WHERE.

*alv 데이터
DATA:
* table with class position
  G_TAB_POSITIONS TYPE TRFY_CLASS_POS_T,
* TRF manager
  G_TRF_MANAGER   TYPE REF TO CL_MANAGER_TRF,
* message that no positions were found
  G_MESSAGE       TYPE BAL_S_MSG.
TYPE-POOLS: SLIS , ICON.
DATA: OK_CODE             LIKE SY-UCOMM,
      OK_CODE2            LIKE SY-UCOMM,
      L_WRK_VARIANT       LIKE DISVARIANT,
      G_CONTAINER         TYPE SCRFNAME VALUE 'ZALV_GRID',
      G_CONTAINER2        TYPE SCRFNAME VALUE 'ZALV_GRID2',
      GRID1               TYPE REF TO CL_GUI_ALV_GRID,
      GRID2               TYPE REF TO CL_GUI_ALV_GRID,
      G_DOCKING_0100      TYPE REF TO CL_GUI_DOCKING_CONTAINER,
      G_CUSTOM_CONTAINER2 TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
*      EVENT_RECEIVER      TYPE REF TO LCL_EVENT_RECEIVER,
      GT_GFDCAT           TYPE LVC_T_FCAT,
      GS_GFDCAT           TYPE LVC_S_FCAT,
      GS_GEXCLUDE         TYPE UI_FUNC,
      GT_GEXCLUDE         TYPE UI_FUNCTIONS,
      G_REPID             LIKE SY-REPID,
      GS_GSTABLE          TYPE LVC_S_STBL,
      GS_LAYOUT           TYPE LVC_S_LAYO.
DATA: G_POS             LIKE SY-CUCOL.
DATA GT_FDCAT            TYPE SLIS_T_FIELDCAT_ALV.
DATA G_TABLE(30).

* Text_edit 0200.
DATA : GO_CONTAINER_200 TYPE REF TO CL_GUI_DOCKING_CONTAINER.
DATA : GO_TEXT_200 TYPE REF TO CL_GUI_TEXTEDIT.

DATA : GV_MODE TYPE CHAR01.
DATA : GV_TITLE TYPE SY-TITLE.
DATA : GT_TEXT TYPE TABLE OF CHAR255.

************************************************************************
*메크로
************************************************************************
* << GRID ALV >>
DEFINE MOD_GFDCAT.
  gs_gfdcat-key              = &1.
  if not &2 is initial.
    gs_gfdcat-outputlen      = &2.
  endif.

  if not &3 is initial.
    gs_gfdcat-scrtext_l      = &3.
    gs_gfdcat-scrtext_m      = &3.
    gs_gfdcat-scrtext_s      = &3.
    gs_gfdcat-reptext        = &3.
    gs_gfdcat-selddictxt     = 'M'.
  endif.
  gs_gfdcat-do_sum           = &4.
  gs_gfdcat-col_pos          = &5.
  gs_gfdcat-currency         = &6.
  gs_gfdcat-no_out           = &7.
  gs_gfdcat-edit             = &8.
  gs_gfdcat-f4availabl       = &9.
END-OF-DEFINITION.
*체크박스 정의
DEFINE MOD_CBOX.
  if &1 is not initial.
    if gs_gfdcat-fieldname = &1.
      gs_gfdcat-checkbox = 'X'.
    endif.
  endif.
END-OF-DEFINITION.
