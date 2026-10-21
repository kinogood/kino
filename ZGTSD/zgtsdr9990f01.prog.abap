*&---------------------------------------------------------------------*
*& Include          ZGTSDR9990F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INITIALIZATION .

*-영업조직
*  S_VKORG[] = VALUE #( ( SIGN = 'I' OPTION = 'EQ' LOW = GC_VKORG_6000 ) ).

*-VIEW
  PERFORM SET_VIEW.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECTION_SCREEN_OUTPUT .
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 EQ 'ZM1'.
      SCREEN-INPUT = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VIEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_VIEW .
  "[판매]
  "여신관리영역 결정 by Sales Group
  APPEND VALUE #( FCODE = 'ZC11' VIEWNAME = 'ZGTSDV1012' ) TO GT_VIEWNAME.
  "SO HEADER DO BLOCK 결정
  APPEND VALUE #( FCODE = 'ZC12' VIEWNAME = 'ZGTSDV1100' ) TO GT_VIEWNAME.
  "출하지점/운송경로 결정
  APPEND VALUE #( FCODE = 'ZC13' VIEWNAME = 'ZGTSDV1101' ) TO GT_VIEWNAME.
  "영업그룹/고객조건그룹4 별 영업소코드 결정
  APPEND VALUE #( FCODE = 'ZC14' VIEWNAME = 'ZGTSDV1103' ) TO GT_VIEWNAME.
  "영업그룹별 영업소코드 결정
  APPEND VALUE #( FCODE = 'ZC15' VIEWNAME = 'ZGTSDV1104' ) TO GT_VIEWNAME.
  "저장위치 결정
  APPEND VALUE #( FCODE = 'ZC16' VIEWNAME = 'ZGTSDV1105' ) TO GT_VIEWNAME.

  "유보금
  APPEND VALUE #( FCODE = 'ZC17' VIEWNAME = 'ZGTSDV1112' ) TO GT_VIEWNAME.

  "[LE]
  "통문 미대상 관리
  APPEND VALUE #( FCODE = 'ZC21' VIEWNAME = 'ZGTSDV1106' ) TO GT_VIEWNAME.
  "운송경로별 통문 미대상 관리
  APPEND VALUE #( FCODE = 'ZC22' VIEWNAME = 'ZGTSDV1111' ) TO GT_VIEWNAME.
  "통문유형 코드
  APPEND VALUE #( FCODE = 'ZC23' VIEWNAME = 'ZLET0007'   ) TO GT_VIEWNAME.
  "거래명세서 - 사업장 매핑 (LE용)
  APPEND VALUE #( FCODE = 'ZC24' VIEWNAME = 'ZLET0033'   ) TO GT_VIEWNAME.
  "계약 선적업체 CBO관리
  APPEND VALUE #( FCODE = 'ZC25' VIEWNAME = 'ZLET0039'   ) TO GT_VIEWNAME.
  "코드관리
  APPEND VALUE #( FCODE = 'ZC26' VIEWNAME = 'ZLEV0200'   ) TO GT_VIEWNAME.
  "우편번호 관리
  APPEND VALUE #( FCODE = 'ZC27' VIEWNAME = 'ZGTSDV9121' ) TO GT_VIEWNAME.

  "[동가]
  "당월평균 동선물 적용 대상 관리
  APPEND VALUE #( FCODE = 'ZC31' VIEWNAME = 'ZGTSDV1107' ) TO GT_VIEWNAME.
  "동가/환율 관리
  APPEND VALUE #( FCODE = 'ZC32' VIEWNAME = 'ZSD0099T'   ) TO GT_VIEWNAME.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_MAINT_VIEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SAVE_OK
*&---------------------------------------------------------------------*
FORM CALL_MAINT_VIEW  USING PV_FCODE.
  CLEAR:GV_VIEWNAME,GV_CLUSNAME,GV_ACTION,GT_SELECTIONS[].

  GV_VIEWNAME = VALUE #( GT_VIEWNAME[ FCODE = PV_FCODE ]-VIEWNAME OPTIONAL ).
  CHECK GV_VIEWNAME IS NOT INITIAL.

  "VIEWCLUSTER
  SELECT SINGLE VCLNAME
    FROM VCLDIR
   WHERE VCLNAME EQ @GV_VIEWNAME
    INTO @DATA(LV_VCLNAME).
  IF SY-SUBRC EQ 0.
    GV_ACTION   = GC_S.
    GV_CLUSNAME = GV_VIEWNAME.
    CLEAR GV_VIEWNAME.
    PERFORM VIEWCLUSTER_MAINTENANCE_CALL.
  ELSE.
    GV_ACTION = GC_S.

    PERFORM VIEW_MAINTENANCE_CALL.
  ENDIF.

*  IF GV_VIEWNAME EQ 'ZLEV0200'. "[LE]코드관리
*    GV_ACTION   = GC_S.
*    GV_CLUSNAME = GV_VIEWNAME.
*    CLEAR GV_VIEWNAME.
*    PERFORM VIEWCLUSTER_MAINTENANCE_CALL.
*
*  ELSE.
*    GV_ACTION = GC_S.
*
*    PERFORM VIEW_MAINTENANCE_CALL.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form VIEW_MAINTENANCE_CALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VIEW_MAINTENANCE_CALL .

  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      ACTION                       = GV_ACTION
      VIEW_NAME                    = GV_VIEWNAME
*     NO_WARNING_FOR_CLIENTINDEP   = ' '
*     RFC_DESTINATION_FOR_UPGRADE  = ' '
*     CLIENT_FOR_UPGRADE           = ' '
*     VARIANT_FOR_SELECTION        = ' '
*     COMPLEX_SELCONDS_USED        = ' '
*     CHECK_DDIC_MAINFLAG          = ' '
*     SUPPRESS_WA_POPUP            = ' '
    TABLES
      DBA_SELLIST                  = GT_SELECTIONS
*     EXCL_CUA_FUNCT               =
    EXCEPTIONS
      CLIENT_REFERENCE             = 1
      FOREIGN_LOCK                 = 2
      INVALID_ACTION               = 3
      NO_CLIENTINDEPENDENT_AUTH    = 4
      NO_DATABASE_FUNCTION         = 5
      NO_EDITOR_FUNCTION           = 6
      NO_SHOW_AUTH                 = 7
      NO_TVDIR_ENTRY               = 8
      NO_UPD_AUTH                  = 9
      ONLY_SHOW_ALLOWED            = 10
      SYSTEM_FAILURE               = 11
      UNKNOWN_FIELD_IN_DBA_SELLIST = 12
      VIEW_NOT_FOUND               = 13
      MAINTENANCE_PROHIBITED       = 14
      OTHERS                       = 15.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form VIEWCLUSTER_MAINTENANCE_CALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM VIEWCLUSTER_MAINTENANCE_CALL .

  CALL FUNCTION 'VIEWCLUSTER_MAINTENANCE_CALL'
    EXPORTING
      VIEWCLUSTER_NAME          = GV_CLUSNAME   " 뷰 클러스터 이름 (필수)
      MAINTENANCE_ACTION        = GV_ACTION     " S:조회(Display), U:수정(Update)
    EXCEPTIONS
      NO_AUTHORITY              = 1
      NO_CLIENTINDEPENDENT_AUTH = 2
      VIEWCLUSTER_NOT_FOUND     = 3
      OTHERS                    = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
