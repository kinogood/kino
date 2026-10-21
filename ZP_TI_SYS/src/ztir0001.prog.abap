************************************************************************
* Title         :  ZTIR0001                                            *
*                                                                      *
* Description   : [Report]  구매처별 수취계좌 관리                     *
*                                                                      *
* Creation Date : 2008/10/31                                           *
*                                                                      *
************************************************************************
*                                                                      *
* Inputs        :                                                      *
*                                                                      *
* Outputs       :                                                      *
*                                                                      *
************************************************************************
*                                                                      *
* Processing Steps:                                                    *
* 1.                                                                   *
* 2.                                                                   *
*                                                                      *
************************************************************************
*----------------------------------------------------------------------*
*                M O D I F I C A T I O N   L O G                       *
*----------------------------------------------------------------------*
* Date         Programmer       Transport#  Description                *
*----------------------------------------------------------------------*
* 2008/10/31   FIB05            [제목] 수입개설요청변경   생성         *
*                               [CSR_NO] C20080910_27638               *
* 2008/11/24   FIB05            [제목] TT지급계좌설정관련요청          *
*                               [CSR_NO] C20081120_61009               *
* 2008/12/12   FIB05            [제목] 해외송금정보입력화면 추가보완   *
*                               [CSR_NO] C20081118_59222               *
* 2009/01/08   FIB05            [제목] 송금정보입력시계좌번호제한수정  *
*                               [CSR_NO] C20081231_79157               *
* 2009/07/08   FIB05            수출 TT 송금 계좌정보 SYSTEM 수정 요청 *
*                               [CSR_NO] C20090619_76375               *
************************************************************************
REPORT  ZTIR0001     message-id zmti00
                       no standard page heading.

************************************************************************
* SAP Include Define                                                   *
************************************************************************
INCLUDE ZTRI0001T01.
DATA: l_yn    type c.
INCLUDE zts_authorization_check. "AUTHORIZATION_CHECK

************************************************************************
* SELECT-OPTIONS / PARAMETERS                                          *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK dbsel WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_bukrs  FOR ZTITIG04-bukrs                   "회사코드.
                    NO-EXTENSION NO INTERVALS OBLIGATORY
                    MEMORY ID buk,
  s_lifnr  FOR ZTITIG04-lifnr,
  s_waers  FOR ZTITIG04-waers.

SELECTION-SCREEN ULINE.
PARAMETERS: p_step1 RADIOBUTTON GROUP ab1 DEFAULT 'X',
            p_step2 RADIOBUTTON GROUP ab1 modif id g1,
            p_step3 RADIOBUTTON GROUP ab1.
SELECTION-SCREEN END OF BLOCK dbsel.

SELECTION-SCREEN BEGIN OF BLOCK lists WITH FRAME TITLE text-002.
PARAMETERS: p_vari LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK lists.

************************************************************************
* User Include Define                                                  *
************************************************************************
INCLUDE: zts_reuse_alvforms_t00, ">[Include] AVL 공용 Data 선언 .
         zts_reuse_alvforms_t02, ">[Include] AVL 공용 Data 선언.
         zts_reuse_alvforms_f00, ">[Include] AVL 공용 Subroutines
         ZTIR0001F01,             ">[Include]수취인계관리 SubRoutine
         ZTIR0001O01,             ">[Include]수취인계관리 PBO Include
         ZTIR0001I01.             ">[Include]수취인계관리 PAI Include

************************************************************************
* INITIALIZATION Event                                                 *
************************************************************************
INITIALIZATION.
  PERFORM p1000_alv_fields_initial.
  PERFORM p1001_initialization.

************************************************************************
* AT SELECTION-SCREEN Events                                           *
************************************************************************
AT SELECTION-SCREEN.
*> 사용자 Input values Check
  PERFORM p1101_check_input_value.
*> 사용자 레이아웃 Input values Check
  PERFORM p1101_check_variant_value.
** JS전선 회사코드 2007/04 MH.LEE --------------------------------------
*> AUTHORIZATION_CHECK
  PERFORM p1102_authorization_check USING s_bukrs-low.
** JS전선 회사코드 2007/04 MH.LEE --------------------------------------

*> 레이아웃 HELP
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM p1102_f4_for_variant.

AT SELECTION-SCREEN OUTPUT.
*  perform modify_screen.

************************************************************************
* START-OF-SELECTION Event                                             *
************************************************************************
START-OF-SELECTION.
*> 검색조건에 해당하는 데이타를 Select.
  PERFORM p2000_data_selections.

************************************************************************
* END-OF-SELECTION Event                                               *
************************************************************************
END-OF-SELECTION.
*> PROGRESS Display.
  g_linen    = 90.
  g_out_text = '리스트를 구성 중입니다 %99999%%'(p03).
  REPLACE '%99999%'(p99) WITH g_linen INTO g_out_text.
  PERFORM show_progress_bar(ztir0000) USING g_out_text g_linen.

*> Dynamic Data Table build
  PERFORM p3000_field_category_build.
  PERFORM p3210_exclude_table_build   USING 'IT_EXCLUDE'.
  PERFORM p3500_sort_table_build .
  PERFORM p3700_layout_build.
  PERFORM p3800_field_attribute_change.
  CALL SCREEN 2000.

************************************************************************
* TOP-OF-PAGE Event                                                    *
************************************************************************
TOP-OF-PAGE.

************************************************************************
* END-OF-PAGE Event                                                    *
************************************************************************
END-OF-PAGE.

************************************************************************
* TOP-OF-PAGE DURING LINE-SELECTION Event                              *
************************************************************************
TOP-OF-PAGE DURING LINE-SELECTION.

************************************************************************
* AT LINE-SELECTION Event                                              *
************************************************************************
AT LINE-SELECTION.

************************************************************************
* AT USER-COMMAND Event                                                *
************************************************************************
AT USER-COMMAND.

************************************************************************
*                                                                      *
* S U B R O U T I N E S                                                *
*                                                                      *
************************************************************************
