*----------------------------------------------------------------------*
***INCLUDE ZSDR0950F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CREATE_CONTROLS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_CONTROLS .

  CREATE OBJECT G_CUSTOM_CONTAINER
    EXPORTING
      CONTAINER_NAME = G_CON.

  CREATE OBJECT GRID
    EXPORTING
*     I_APPL_EVENTS = 'X'
      I_PARENT = G_CUSTOM_CONTAINER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EVENT .
  CALL METHOD GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  CREATE OBJECT EVENT_RECEIVER.
*  SET HANDLER event_receiver->handle_top_of_page  FOR grid.
*  SET HANDLER event_receiver->handle_double_click FOR grid.
*  SET HANDLER event_receiver->handle_hotspot_click FOR grid.
  SET HANDLER EVENT_RECEIVER->HANDLE_TOOLBAR      FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_USER_COMMAND FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_DATA_CHANGED FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_ONF4         FOR GRID.

  CALL METHOD GRID->SET_READY_FOR_INPUT
    EXPORTING
      I_READY_FOR_INPUT = 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ALV_LAYOUT .
  GS_LAYOUT-SEL_MODE   = 'A'.
  GS_LAYOUT-ZEBRA      = 'X'.
*  GS_LAYOUT-CWIDTH_OPT = 'X'.
  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_EXCLUDE
*&---------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS  CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.
  DATA LS_EXCLUDE TYPE UI_FUNC.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_GRAPH.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_INFO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_DETAIL.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_REFRESH.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
*  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.
*  APPEND LS_EXCLUDE TO PT_EXCLUDE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_VARIANT .
  GS_VARIANT-REPORT   = SY-CPROG.
  GS_VARIANT-USERNAME = SY-UNAME.
  GS_VARIANT-HANDLE   = SY-DYNNR.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIELDCAT_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FIELDCAT_INIT .

  DATA  : L_COL_POS LIKE SY-CUCOL,
          LV_ACT,
          LV_INACT.
  CLEAR : LV_ACT, LV_INACT.

  DATA(LV_TABNAME) = VALUE #( GT_LIST[ KSCHL = GS_HEADER-KOBOG ]-TABNAME OPTIONAL ).
  DATA(LV_SIGN)    = VALUE #( GT_LIST[ KSCHL = GS_HEADER-KOBOG ]-KRECH OPTIONAL ).

  SELECT FIELDNAME
   INTO TABLE @DATA(LT_FNAM)
   FROM DD03L
   WHERE TABNAME = @LV_TABNAME.

  DATA(LO_TABLE) = CAST CL_ABAP_TABLEDESCR( CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( GT_ITAB ) ).
  DATA(LO_STRUC) = CAST CL_ABAP_STRUCTDESCR( LO_TABLE->GET_TABLE_LINE_TYPE( ) ).
  DATA(LT_DFIES) = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUC ).

  GT_FIELDCAT = CORRESPONDING #( LT_DFIES MAPPING REF_TABLE = REFTABLE
                                                REF_FIELD = REFFIELD ).

  LOOP AT GT_FIELDCAT ASSIGNING FIELD-SYMBOL(<FS_FCAT>).
    IF LV_SIGN = 'C'.
      IF <FS_FCAT>-FIELDNAME = 'KBETR' OR
         <FS_FCAT>-FIELDNAME = 'KONWA' OR
         <FS_FCAT>-FIELDNAME = 'KPEIN' OR
         <FS_FCAT>-FIELDNAME = 'KMEIN' OR
         <FS_FCAT>-FIELDNAME = 'ICON'  OR
         <FS_FCAT>-FIELDNAME = 'LOEVM' OR
         <FS_FCAT>-FIELDNAME = 'MESSAGE'.
        CONTINUE.
      ENDIF.
    ELSE.
      IF <FS_FCAT>-FIELDNAME = 'KBETR' OR
         <FS_FCAT>-FIELDNAME = 'KONWA' OR
         <FS_FCAT>-FIELDNAME = 'ICON'  OR
         <FS_FCAT>-FIELDNAME = 'LOEVM' OR
         <FS_FCAT>-FIELDNAME = 'MESSAGE'.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF LINE_EXISTS( LT_FNAM[ FIELDNAME = <FS_FCAT>-FIELDNAME ] ).
      CONTINUE.
    ELSE.
      <FS_FCAT>-TECH = 'X'.
    ENDIF.
  ENDLOOP.
  UNASSIGN <FS_FCAT>.


  CASE SY-TCODE.
    WHEN GC_ZVBO1.
      LV_ACT = 'X'.
    WHEN GC_ZVBO2.
      IF GV_APRV_STAT = 'P'.
        LV_INACT = 'X'.
      ELSEIF GV_APRV_STAT = 'C'.
        LV_INACT = 'X'.
      ELSE.
        LV_ACT = 'X'.
      ENDIF.
    WHEN GC_ZVBO3.
      LV_INACT = 'X'.
*    WHEN GC_ZVBO4.
*      LV_INACT = 'X'.
*    WHEN GC_ZVBO5.
*      LV_INACT = 'X'.
*    WHEN GC_ZVBO6.
*      LV_ACT = 'X'.
  ENDCASE.

  IF LV_ACT = 'X'.

    LOOP AT GT_FIELDCAT ASSIGNING FIELD-SYMBOL(<FS_FCAT2>).

      L_COL_POS = L_COL_POS + 1.
      <FS_FCAT2>-COL_POS = L_COL_POS.

      <FS_FCAT2>-KEY = ''.

      CASE <FS_FCAT2>-FIELDNAME.
        WHEN 'ICON'.
          <FS_FCAT2>-COLTEXT    = TEXT-F24. "TEXT-F18. "상태
          <FS_FCAT2>-JUST       = 'C'.
          <FS_FCAT2>-OUTPUTLEN = 5.
        WHEN 'MESSAGE'.
          <FS_FCAT2>-COLTEXT    = TEXT-F19. "Message
          <FS_FCAT2>-OUTPUTLEN = 20.
        WHEN 'KSCHL'.
          <FS_FCAT2>-COLTEXT    = TEXT-F01.
          <FS_FCAT2>-OUTPUTLEN = 5.
        WHEN 'VKORG'.
          <FS_FCAT2>-COLTEXT    = TEXT-F02.
          <FS_FCAT2>-F4AVAILABL = 'X'.
          <FS_FCAT2>-REF_FIELD = 'VKORG'.
          <FS_FCAT2>-REF_TABLE = 'VBAK'.
          <FS_FCAT2>-OUTPUTLEN = 5.
        WHEN 'VTWEG'.
          <FS_FCAT2>-COLTEXT    = TEXT-F03.
          <FS_FCAT2>-F4AVAILABL = 'X'.
          <FS_FCAT2>-REF_FIELD = 'VTWEG'.
          <FS_FCAT2>-REF_TABLE = 'VBAK'.
          <FS_FCAT2>-OUTPUTLEN = 5.
        WHEN 'SPART'.
          <FS_FCAT2>-COLTEXT    = TEXT-F04.
          <FS_FCAT2>-F4AVAILABL = 'X'.
          <FS_FCAT2>-REF_FIELD = 'SPART'.
          <FS_FCAT2>-REF_TABLE = 'VBAK'.
          <FS_FCAT2>-OUTPUTLEN = 5.
        WHEN 'AUSFU'.
          <FS_FCAT2>-COLTEXT    = TEXT-F05.
          <FS_FCAT2>-OUTPUTLEN = 10.
        WHEN 'DATAB'.
          <FS_FCAT2>-COLTEXT    = TEXT-F06.
          <FS_FCAT2>-F4AVAILABL = 'X'.
          <FS_FCAT2>-OUTPUTLEN = 11.
        WHEN 'DATBI'.
          <FS_FCAT2>-COLTEXT    = TEXT-F07.
          <FS_FCAT2>-F4AVAILABL = 'X'.
          <FS_FCAT2>-OUTPUTLEN = 11.
        WHEN 'KBETR'.
          <FS_FCAT2>-COLTEXT    = TEXT-F08.
          <FS_FCAT2>-CFIELDNAME = 'KONWA'.
*          <FS_FCAT2>-EDIT       = 'X'.
        WHEN 'KONWA'.
          <FS_FCAT2>-COLTEXT    = TEXT-F09.
          <FS_FCAT2>-F4AVAILABL = 'X'.
          <FS_FCAT2>-OUTPUTLEN = 10.
        WHEN 'KPEIN'.
          <FS_FCAT2>-COLTEXT    = TEXT-F10.
*          <FS_FCAT2>-EDIT       = 'X'.
          <FS_FCAT2>-OUTPUTLEN = 4.
        WHEN 'KMEIN'.
          <FS_FCAT2>-COLTEXT    = TEXT-F11.
          <FS_FCAT2>-F4AVAILABL = 'X'.
          <FS_FCAT2>-REF_FIELD = 'KMEIN'.
          <FS_FCAT2>-REF_TABLE = 'KONP'.
          <FS_FCAT2>-OUTPUTLEN = 4.
*          <FS_FCAT2>-EDIT       = 'X'.
        WHEN 'LOEVM'.
          <FS_FCAT2>-COLTEXT    = TEXT-F20. "삭제지시자
          <FS_FCAT2>-CHECKBOX   = 'X'.
          <FS_FCAT2>-OUTPUTLEN = 6.
        WHEN OTHERS.

          IF <FS_FCAT2>-FIELDNAME = 'KUNNR' AND
             <FS_FCAT2>-TECH <> 'X'.
            <FS_FCAT2>-COLTEXT   = TEXT-F12.
            <FS_FCAT2>-F4AVAILABL = 'X'.
            <FS_FCAT2>-REF_FIELD = 'KUNNR'.
            <FS_FCAT2>-REF_TABLE = 'KNA1'.
            CASE GC_X.
              WHEN GS_HEADER-A925.
                CLEAR:<FS_FCAT2>-NO_OUT.
              WHEN OTHERS.
                <FS_FCAT2>-NO_OUT = GC_X.
            ENDCASE.
*            <FS_FCAT2>-EDIT      = 'X'.
          ELSEIF <FS_FCAT2>-FIELDNAME = 'MATNR' AND
                 <FS_FCAT2>-TECH <> 'X'.
            <FS_FCAT2>-COLTEXT   = TEXT-F13.
            <FS_FCAT2>-F4AVAILABL = 'X'.
            <FS_FCAT2>-REF_FIELD = 'MATNR'.
            <FS_FCAT2>-REF_TABLE = 'MARA'.
*            <FS_FCAT2>-EDIT      = 'X'.
          ELSEIF <FS_FCAT2>-FIELDNAME = 'PRODH' AND
                 <FS_FCAT2>-TECH <> 'X'.
            <FS_FCAT2>-COLTEXT   = TEXT-F14.
            <FS_FCAT2>-F4AVAILABL = 'X'.
            <FS_FCAT2>-REF_FIELD = 'PRDHA'.
            <FS_FCAT2>-REF_TABLE = 'MARA'.
*            <FS_FCAT2>-EDIT      = 'X'.
          ELSEIF <FS_FCAT2>-FIELDNAME = 'INCO1' AND
                 <FS_FCAT2>-TECH <> 'X'.
            <FS_FCAT2>-COLTEXT   = TEXT-F15.
            <FS_FCAT2>-F4AVAILABL = 'X'.
            <FS_FCAT2>-REF_FIELD = 'INCO1'.
            <FS_FCAT2>-REF_TABLE = 'VBKD'.
            CASE GC_X.
              WHEN GS_HEADER-A925.
                CLEAR:<FS_FCAT2>-NO_OUT.
              WHEN OTHERS.
                <FS_FCAT2>-NO_OUT = GC_X.
            ENDCASE.
*            <FS_FCAT2>-EDIT      = 'X'.
          ELSEIF <FS_FCAT2>-FIELDNAME = 'AUBEL' AND
                 <FS_FCAT2>-TECH <> 'X'.
            <FS_FCAT2>-COLTEXT   = TEXT-F16.
            <FS_FCAT2>-F4AVAILABL = 'X'.
            <FS_FCAT2>-REF_FIELD = 'VBELN'.
            <FS_FCAT2>-REF_TABLE = 'VBAP'.
*            <FS_FCAT2>-EDIT      = 'X'.
          ELSEIF <FS_FCAT2>-FIELDNAME = 'AUPOS' AND
                 <FS_FCAT2>-TECH <> 'X'.
            <FS_FCAT2>-COLTEXT   = TEXT-F17.
            <FS_FCAT2>-F4AVAILABL = 'X'.
            <FS_FCAT2>-REF_FIELD = 'POSNR'.
            <FS_FCAT2>-REF_TABLE = 'VBAP'.
*            <FS_FCAT2>-EDIT      = 'X'.
          ENDIF.
      ENDCASE.
    ENDLOOP.

  ELSEIF LV_INACT = 'X'.
    LOOP AT GT_FIELDCAT ASSIGNING FIELD-SYMBOL(<FS_FCAT3>).

      L_COL_POS = L_COL_POS + 1.
      <FS_FCAT3>-COL_POS = L_COL_POS.

      <FS_FCAT3>-KEY = ''.

      CASE <FS_FCAT3>-FIELDNAME.
        WHEN 'ICON'.
          <FS_FCAT3>-COLTEXT    = TEXT-F24. "TEXT-F18. "상태
          <FS_FCAT3>-JUST       = 'C'.
          <FS_FCAT3>-OUTPUTLEN = 5.
        WHEN 'MESSAGE'.
          <FS_FCAT3>-COLTEXT    = TEXT-F19. "Message
          <FS_FCAT3>-OUTPUTLEN = 20.
          <FS_FCAT3>-NO_OUT    = 'X'.
        WHEN 'KSCHL'.
          <FS_FCAT3>-COLTEXT    = TEXT-F01.
          <FS_FCAT3>-OUTPUTLEN = 5.
        WHEN 'VKORG'.
          <FS_FCAT3>-COLTEXT    = TEXT-F02.
          <FS_FCAT3>-OUTPUTLEN = 5.
        WHEN 'VTWEG'.
          <FS_FCAT3>-COLTEXT    = TEXT-F03.
          <FS_FCAT3>-OUTPUTLEN = 5.
        WHEN 'SPART'.
          <FS_FCAT3>-COLTEXT    = TEXT-F04.
          <FS_FCAT3>-OUTPUTLEN = 5.
        WHEN 'AUSFU'.
          <FS_FCAT3>-COLTEXT    = TEXT-F05.
          <FS_FCAT3>-OUTPUTLEN = 10.
        WHEN 'DATAB'.
          <FS_FCAT3>-COLTEXT    = TEXT-F06.
          <FS_FCAT3>-OUTPUTLEN = 11.
        WHEN 'DATBI'.
          <FS_FCAT3>-COLTEXT    = TEXT-F07.
          <FS_FCAT3>-OUTPUTLEN = 11.
        WHEN 'KBETR'.
          <FS_FCAT3>-COLTEXT    = TEXT-F08.
          <FS_FCAT3>-CFIELDNAME = 'KONWA'.
          <FS_FCAT3>-OUTPUTLEN = 10.
        WHEN 'KONWA'.
          <FS_FCAT3>-COLTEXT    = TEXT-F09.
        WHEN 'KPEIN'.
          <FS_FCAT3>-COLTEXT    = TEXT-F10.
          <FS_FCAT3>-OUTPUTLEN = 4.
        WHEN 'KMEIN'.
          <FS_FCAT3>-COLTEXT    = TEXT-F11.
        WHEN 'LOEVM'.
          <FS_FCAT3>-COLTEXT    = TEXT-F20. "삭제지시자
          <FS_FCAT3>-CHECKBOX   = 'X'.
          <FS_FCAT3>-OUTPUTLEN = 6.
        WHEN OTHERS.

          IF <FS_FCAT3>-FIELDNAME = 'KUNNR' AND
             <FS_FCAT3>-TECH <> 'X'.
            <FS_FCAT3>-COLTEXT   = TEXT-F12.
            <FS_FCAT3>-NO_OUT = GC_X.
          ELSEIF <FS_FCAT3>-FIELDNAME = 'MATNR' AND
                 <FS_FCAT3>-TECH <> 'X'.
            <FS_FCAT3>-COLTEXT   = TEXT-F13.
          ELSEIF <FS_FCAT3>-FIELDNAME = 'PRODH' AND
                 <FS_FCAT3>-TECH <> 'X'.
            <FS_FCAT3>-COLTEXT   = TEXT-F14.
          ELSEIF <FS_FCAT3>-FIELDNAME = 'INCO1' AND
                 <FS_FCAT3>-TECH <> 'X'.
            <FS_FCAT3>-COLTEXT   = TEXT-F15.
            <FS_FCAT3>-NO_OUT = GC_X.
          ELSEIF <FS_FCAT3>-FIELDNAME = 'AUBEL' AND
                 <FS_FCAT3>-TECH <> 'X'.
            <FS_FCAT3>-COLTEXT   = TEXT-F16.
          ELSEIF <FS_FCAT3>-FIELDNAME = 'AUPOS' AND
                 <FS_FCAT3>-TECH <> 'X'.
            <FS_FCAT3>-COLTEXT   = TEXT-F17.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDIF.
  UNASSIGN <FS_FCAT2>.
  UNASSIGN <FS_FCAT3>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INITIAIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INITIAIZATION .
  CLEAR : GT_ITAB, GT_HIST, GS_HEADER, GV_ERROR, GV_SAVE, GV_KNUMA, GV_REQNO.
  IF GRID IS NOT INITIAL.
    CALL METHOD GRID->FREE.
    CALL METHOD G_CUSTOM_CONTAINER->FREE.
    CLEAR : GRID, G_CUSTOM_CONTAINER.
  ENDIF.

  GS_ORG = VALUE #( VKORG = VBAK-VKORG
                    VTWEG = VBAK-VTWEG
                    SPART = VBAK-SPART
                    VKBUR = VBAK-VKBUR
                    VKGRP = VBAK-VKGRP ).

  DATA(LV_DATAB) =  CONV D( |{ SY-DATUM+0(6) }01| ).
  DATA(LV_DATBI) =  CONV D( |{ SY-DATUM+0(4) + 1 }1231| ).

  GS_HEADER = VALUE #( DATAB = LV_DATAB
                       DATBI = LV_DATBI ).



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&---------------------------------------------------------------------*
FORM SET_TOOLBAR  USING P_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

  CASE SY-TCODE.
    WHEN GC_ZVBO1.
*-----[CHG]-----S
*      P_OBJECT->MT_TOOLBAR = VALUE #( BASE P_OBJECT->MT_TOOLBAR
*                                 ( FUNCTION = 'APPEND'
*                                   QUICKINFO = 'APPEND'
*                                   TEXT = '추가'
*                                   ICON = ICON_INSERT_ROW  ) ).
*
*
*      P_OBJECT->MT_TOOLBAR = VALUE #( BASE P_OBJECT->MT_TOOLBAR
*                                    ( FUNCTION = 'DELETE'
*                                      QUICKINFO = 'DELETE'
*                                      TEXT = '삭제'
*                                      ICON = ICON_DELETE_ROW  ) ).
*-----[CHG]-----E

*      P_OBJECT->MT_TOOLBAR = VALUE #( BASE P_OBJECT->MT_TOOLBAR
*                                 ( FUNCTION = 'RESTORE'
*                                   QUICKINFO = 'RESTORE'
*                                   TEXT = '복구'
*                                   DISABLED = 'X'
*                                   ICON = ICON_SYSTEM_UNDO ) ).
    WHEN GC_ZVBO2.
*-----[CHG]-----S
*      IF GV_APRV_STAT = '' OR " 승인요청 전
**         GV_APRV_STAT = 'C' OR
*         GV_APRV_STAT = 'D' OR "승인요청 취소
*         GV_APRV_STAT = 'R'.  "승인 반려
*        P_OBJECT->MT_TOOLBAR = VALUE #( BASE P_OBJECT->MT_TOOLBAR
*                                 ( FUNCTION = 'APPEND'
*                                   QUICKINFO = 'APPEND'
*                                   TEXT = '추가'
*                                   ICON = ICON_INSERT_ROW  ) ).
*
*        P_OBJECT->MT_TOOLBAR = VALUE #( BASE P_OBJECT->MT_TOOLBAR
*                                      ( FUNCTION = 'DELETE'
*                                        QUICKINFO = 'DELETE'
*                                        TEXT = '삭제'
*                                        ICON = ICON_DELETE_ROW  ) ).
*-----[CHG]-----E

*        P_OBJECT->MT_TOOLBAR = VALUE #( BASE P_OBJECT->MT_TOOLBAR
*                                ( FUNCTION = 'RESTORE'
*                                  QUICKINFO = 'RESTORE'
*                                  TEXT = '복구'
*                                  DISABLED = 'X'
*                                  ICON = ICON_SYSTEM_UNDO ) ).
*      ELSEIF GV_APRV_STAT = 'C'.
*        P_OBJECT->MT_TOOLBAR = VALUE #( BASE P_OBJECT->MT_TOOLBAR
*                                   ( FUNCTION = 'APPEND'
*                                     QUICKINFO = 'APPEND'
*                                     TEXT = '추가'
*                                     DISABLED = 'X'
*                                     ICON = ICON_INSERT_ROW  ) ).
*
*        P_OBJECT->MT_TOOLBAR = VALUE #( BASE P_OBJECT->MT_TOOLBAR
*                                      ( FUNCTION = 'DELETE'
*                                        QUICKINFO = 'DELETE'
*                                        TEXT = '삭제'
*                                        DISABLED = 'X'
*                                        ICON = ICON_DELETE_ROW  ) ).
*        P_OBJECT->MT_TOOLBAR = VALUE #( BASE P_OBJECT->MT_TOOLBAR
*                                  ( FUNCTION = 'RESTORE'
*                                    QUICKINFO = 'RESTORE'
*                                    TEXT = '복구'
*                                    DISABLED = 'X'
*                                    ICON = ICON_SYSTEM_UNDO ) ).
*      ENDIF.
    WHEN GC_ZVBO6.
      P_OBJECT->MT_TOOLBAR = VALUE #( BASE P_OBJECT->MT_TOOLBAR
                                 ( FUNCTION = 'APPEND'
                                   QUICKINFO = 'APPEND'
                                   TEXT = '추가'
                                   ICON = ICON_INSERT_ROW  ) ).

      P_OBJECT->MT_TOOLBAR = VALUE #( BASE P_OBJECT->MT_TOOLBAR
                                    ( FUNCTION = 'DELETE'
                                      QUICKINFO = 'DELETE'
                                      TEXT = '삭제'
                                      ICON = ICON_DELETE_ROW  ) ).

      P_OBJECT->MT_TOOLBAR = VALUE #( BASE P_OBJECT->MT_TOOLBAR
                                 ( FUNCTION = 'RESTORE'
                                   QUICKINFO = 'RESTORE'
                                   TEXT = '복구'
                                   ICON = ICON_SYSTEM_UNDO ) ).
*    WHEN OTHERS.
*      P_OBJECT->MT_TOOLBAR = VALUE #( BASE P_OBJECT->MT_TOOLBAR
*                                   ( FUNCTION = 'APPEND'
*                                     QUICKINFO = 'APPEND'
*                                     TEXT = '추가'
*                                     DISABLED = 'X'
*                                     ICON = ICON_INSERT_ROW  ) ).
*
*      P_OBJECT->MT_TOOLBAR = VALUE #( BASE P_OBJECT->MT_TOOLBAR
*                                    ( FUNCTION = 'DELETE'
*                                      QUICKINFO = 'DELETE'
*                                      TEXT = '삭제'
*                                      DISABLED = 'X'
*                                      ICON = ICON_DELETE_ROW  ) ).
*      P_OBJECT->MT_TOOLBAR = VALUE #( BASE P_OBJECT->MT_TOOLBAR
*                                ( FUNCTION = 'RESTORE'
*                                  QUICKINFO = 'RESTORE'
*                                  TEXT = '복구'
*                                  DISABLED = 'X'
*                                  ICON = ICON_SYSTEM_UNDO ) ).
  ENDCASE.
**-> CCM : 21.11.2023 12:01:23 / ZLSGSD4
*  P_OBJECT->MT_TOOLBAR = VALUE #( BASE P_OBJECT->MT_TOOLBAR
*                             ( FUNCTION = 'KSCHL'
*                               QUICKINFO = 'KSCHL'
*                               TEXT = '조건'
*                               ICON = ICON_PROTOCOL  ) ).
**<-

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_COMMISSION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_COMMISSION .

  DATA : LT_ZKONA TYPE TABLE OF ZKONA,
         LS_ZKONA TYPE ZKONA.
  DATA : LT_ZKONA_ITEM TYPE TABLE OF ZKONA_ITEM,
         LS_ZKONA_ITEM TYPE ZKONA_ITEM.
  DATA : LV_ERR,
         LV_ANSWER,
         LV_DATBI TYPE ZKONA-DATBI.
  DATA : LS_OLD TYPE ZKONA.
  DATA : LV_DATE LIKE SY-DATUM.
  DATA: LV_SUBRC TYPE SY-SUBRC.

  CLEAR : LS_ZKONA, LT_ZKONA, LS_ZKONA_ITEM, LT_ZKONA_ITEM,
          LS_OLD, LV_ERR, LV_ANSWER, LV_DATBI.

  CLEAR : XZKONA, YZKONA.

  PERFORM VALUE_VALIDATION USING LV_ERR.

  IF LV_ERR = 'X'.
    EXIT.
  ENDIF.

*- 커미션 생성
  IF GS_HEADER-KNUMA IS INITIAL.

    PERFORM POPUP_CONFIRM USING '확인'
                                '저장 하시겠습니까?'
                                 LV_ANSWER.
    IF LV_ANSWER <> 1.
      EXIT.
    ENDIF.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        NR_RANGE_NR             = '10'
        OBJECT                  = 'ZSD_000013'
      IMPORTING
        NUMBER                  = GS_HEADER-KNUMA
      EXCEPTIONS
        INTERVAL_NOT_FOUND      = 1
        NUMBER_RANGE_NOT_INTERN = 2
        OBJECT_NOT_FOUND        = 3
        QUANTITY_IS_0           = 4
        QUANTITY_IS_NOT_1       = 5
        INTERVAL_OVERFLOW       = 6
        BUFFER_OVERFLOW         = 7
        OTHERS                  = 8.

    IF SY-SUBRC <> 0.
      MESSAGE I001 WITH TEXT-E04 DISPLAY LIKE 'E'. "계약번호 생성 실패
      EXIT.
    ENDIF.

    CLEAR LS_ZKONA.
    LS_ZKONA-KNUMA = GS_HEADER-KNUMA.
    LS_ZKONA-VKORG = GS_ORG-VKORG.
    LS_ZKONA-VTWEG = GS_ORG-VTWEG.
    LS_ZKONA-SPART = GS_ORG-SPART.
    LS_ZKONA-VKBUR = GS_ORG-VKBUR.
    LS_ZKONA-VKGRP = GS_ORG-VKGRP.
    LS_ZKONA-BOART = GS_HEADER-KOBOG.
    LS_ZKONA-KOBOG = GS_HEADER-KOBOG.
    LS_ZKONA-KAPPL = GC_V.
    LS_ZKONA-BOTEXT = GS_HEADER-BOTEXT.
    LS_ZKONA-AUSFU = GS_HEADER-AUSFU.
    LS_ZKONA-BONEM = GS_HEADER-AUSFU.
    LS_ZKONA-WAERS = GS_HEADER-WAERS.
    LS_ZKONA-ERNAM = SY-UNAME.
    LS_ZKONA-ERDAT = SY-DATUM.
    LS_ZKONA-ERZET = SY-UZEIT.
    LS_ZKONA-DATAB = GS_HEADER-DATAB.
    LS_ZKONA-DATBI = GS_HEADER-DATBI.
    LS_ZKONA-BOSTA = GC_B.               "GS_HEADER-BOSTA.
    LS_ZKONA-ABSPZ = GS_HEADER-ABSPZ.

    APPEND LS_ZKONA TO LT_ZKONA.
    MOVE-CORRESPONDING LS_ZKONA TO YZKONA.
    MODIFY ZKONA FROM TABLE LT_ZKONA.

    IF SY-SUBRC = 0.
      LOOP AT GT_HIST INTO DATA(LS_HIST).

        PERFORM CREATE_VAKEY USING LS_HIST.
        CLEAR LS_ZKONA_ITEM.
        LS_ZKONA_ITEM-KNUMA     = GS_HEADER-KNUMA.
        LS_ZKONA_ITEM-KSCHL     = LS_HIST-KSCHL.
        LS_ZKONA_ITEM-BONEM     = LS_HIST-AUSFU.
        LS_ZKONA_ITEM-AUSFU     = LS_HIST-AUSFU.
        LS_ZKONA_ITEM-VAKEY     = GV_VAKEY.
        LS_ZKONA_ITEM-VKORG     = LS_HIST-VKORG.
        LS_ZKONA_ITEM-VTWEG     = LS_HIST-VTWEG.
        LS_ZKONA_ITEM-SPART     = LS_HIST-SPART.
        LS_ZKONA_ITEM-KUNNR     = LS_HIST-KUNNR.
        LS_ZKONA_ITEM-MATNR     = LS_HIST-MATNR.
        LS_ZKONA_ITEM-PRODH     = LS_HIST-PRODH.
        LS_ZKONA_ITEM-INCO1     = LS_HIST-INCO1.
        LS_ZKONA_ITEM-WAERS     = LS_HIST-KONWA.
        LS_ZKONA_ITEM-AUBEL     = LS_HIST-AUBEL.
        LS_ZKONA_ITEM-AUPOS     = LS_HIST-AUPOS.
        LS_ZKONA_ITEM-DATAB     = LS_HIST-DATAB.
        LS_ZKONA_ITEM-DATBI     = LS_HIST-DATBI.
        LS_ZKONA_ITEM-KBETR     = LS_HIST-KBETR.
        LS_ZKONA_ITEM-KONWA     = LS_HIST-KONWA.
        LS_ZKONA_ITEM-KPEIN     = LS_HIST-KPEIN.
        LS_ZKONA_ITEM-KMEIN     = LS_HIST-KMEIN.
        LS_ZKONA_ITEM-STAT_FLAG = LS_HIST-STAT_FLAG.
        APPEND LS_ZKONA_ITEM TO LT_ZKONA_ITEM.

        MOVE-CORRESPONDING LS_ZKONA_ITEM TO YZKONA_ITEM.
        YZKONA_ITEM-KZ = 'I'.
        APPEND YZKONA_ITEM.

      ENDLOOP.

      MODIFY ZKONA_ITEM FROM TABLE LT_ZKONA_ITEM.
      IF SY-SUBRC = 0.

        GV_SAVE = 'X'.
*        DATA(LV_TEXT1) = |커미션 { GS_HEADER-KNUMA } 생성되었습니다.|.
*        PERFORM POPUP_TO_DISPLAY_MULTI_TEXT
*          USING '메시지'
*                LV_TEXT1
*                '승인 요청 및 커미션 변경은 T-CODE ZVBO2에서 진행해 주세요.'.

        COMMIT WORK AND WAIT.

        PERFORM SAVE_CHANGE_DOC TABLES LT_ZKONA_ITEM
                                USING  'I'.


        "CONDITION RECORD 생성
        PERFORM PROCESS_VK11_ZBO5 USING LV_ERR.

        DATA(LV_TEXT1) = |커미션 { GS_HEADER-KNUMA } 생성되었습니다.|.
        IF LV_ERR IS INITIAL.
          DATA(LV_TEXT2) = |조건 레코드를 생성 하였습니다.|.
        ELSE.
          LV_TEXT2 = |조건 레코드 생성 중 에러가 발생 하였습니다.|.
        ENDIF.
        PERFORM POPUP_TO_DISPLAY_MULTI_TEXT
          USING '메시지'
                LV_TEXT1
                LV_TEXT2.

      ELSE.

        MESSAGE I001 WITH TEXT-E05 DISPLAY LIKE 'E'. "계약 생성 실패
        ROLLBACK WORK.

      ENDIF.

    ELSE.
      MESSAGE I001 WITH TEXT-E05 DISPLAY LIKE 'E'. "계약 생성 실패
      ROLLBACK WORK.
    ENDIF.



  ELSE.

    PERFORM GET_LS_OLD_NEW USING LV_ERR
                                 LS_OLD.
    IF LV_ERR = 'X'.
      EXIT.
    ENDIF.

    CLEAR:LT_ZKONA[],LT_ZKONA_ITEM[].
    CLEAR LS_ZKONA.
    LS_ZKONA-KNUMA = GS_HEADER-KNUMA.
    LS_ZKONA-VKORG = GS_ORG-VKORG.
    LS_ZKONA-VTWEG = GS_ORG-VTWEG.
    LS_ZKONA-SPART = GS_ORG-SPART.
    LS_ZKONA-VKBUR = GS_ORG-VKBUR.
    LS_ZKONA-VKGRP = GS_ORG-VKGRP.
    LS_ZKONA-BOTEXT = GS_HEADER-BOTEXT.
    LS_ZKONA-AUSFU = GS_HEADER-AUSFU.
    LS_ZKONA-BONEM = GS_HEADER-AUSFU.
    LS_ZKONA-WAERS = GS_HEADER-WAERS.
    LS_ZKONA-ERNAM = LS_OLD-ERNAM.
    LS_ZKONA-ERDAT = LS_OLD-ERDAT.
    LS_ZKONA-ERZET = LS_OLD-ERZET.
    LS_ZKONA-AENAM = SY-UNAME.
    LS_ZKONA-AEDAT = SY-DATUM.
    LS_ZKONA-AEZET = SY-UZEIT.
    LS_ZKONA-DATAB = GS_HEADER-DATAB.
    LS_ZKONA-DATBI = GS_HEADER-DATBI.
    LS_ZKONA-BOSTA = GS_HEADER-BOSTA.
    LS_ZKONA-ABSPZ = GS_HEADER-ABSPZ.

    APPEND LS_ZKONA TO LT_ZKONA.

    LOOP AT GT_HIST INTO DATA(LS_HIST2).

      CLEAR LS_ZKONA_ITEM.

      PERFORM CREATE_VAKEY USING LS_HIST2.

      LS_ZKONA_ITEM-KNUMA     = GS_HEADER-KNUMA.
      LS_ZKONA_ITEM-KSCHL     = LS_HIST2-KSCHL.
      LS_ZKONA_ITEM-BONEM     = LS_HIST2-AUSFU.
      LS_ZKONA_ITEM-AUSFU     = LS_HIST2-AUSFU.
      LS_ZKONA_ITEM-VAKEY     = GV_VAKEY.
      LS_ZKONA_ITEM-VKORG     = LS_HIST2-VKORG.
      LS_ZKONA_ITEM-VTWEG     = LS_HIST2-VTWEG.
      LS_ZKONA_ITEM-SPART     = LS_HIST2-SPART.
      LS_ZKONA_ITEM-KUNNR     = LS_HIST2-KUNNR.
      LS_ZKONA_ITEM-MATNR     = LS_HIST2-MATNR.
      LS_ZKONA_ITEM-PRODH     = LS_HIST2-PRODH.
      LS_ZKONA_ITEM-INCO1     = LS_HIST2-INCO1.
      LS_ZKONA_ITEM-WAERS     = LS_HIST2-KONWA.
      LS_ZKONA_ITEM-AUBEL     = LS_HIST2-AUBEL.
      LS_ZKONA_ITEM-AUPOS     = LS_HIST2-AUPOS.
      LS_ZKONA_ITEM-DATAB     = LS_HIST2-DATAB.
      LS_ZKONA_ITEM-DATBI     = LS_HIST2-DATBI.
      LS_ZKONA_ITEM-KBETR     = LS_HIST2-KBETR.
      LS_ZKONA_ITEM-KONWA     = LS_HIST2-KONWA.
      LS_ZKONA_ITEM-KPEIN     = LS_HIST2-KPEIN.
      LS_ZKONA_ITEM-KMEIN     = LS_HIST2-KMEIN.
      LS_ZKONA_ITEM-STAT_FLAG = LS_HIST2-STAT_FLAG.

      APPEND LS_ZKONA_ITEM TO LT_ZKONA_ITEM.
    ENDLOOP.

    "변경사항 체크
    CLEAR:GS_CHANGE.
    PERFORM CHECK_CHAGE_DATA TABLES LT_ZKONA_ITEM
                              USING LS_ZKONA.
    IF GS_CHANGE-H IS INITIAL AND
       GS_CHANGE-I IS INITIAL.
      MESSAGE S001 WITH TEXT-E43 DISPLAY LIKE GC_E.
    ENDIF.

    "조건레코드
    CLEAR LV_ERR.
    DATA(LS_ITEM) = VALUE #( LT_ZKONA_ITEM[ 1 ] OPTIONAL ).
    IF GS_CHANGE-I IS NOT INITIAL.
      IF LS_ITEM-STAT_FLAG EQ GC_X.

        PERFORM PROCESS_VK11_ZBO5 USING LV_ERR.
        IF LV_ERR IS INITIAL.
          CLEAR:LS_ZKONA_ITEM.
          LS_ZKONA_ITEM-STAT_FLAG = GC_B.
          MODIFY LT_ZKONA_ITEM FROM LS_ZKONA_ITEM TRANSPORTING STAT_FLAG WHERE KNUMA = GS_HEADER-KNUMA.
        ENDIF.
      ENDIF.
      IF LV_ERR IS INITIAL.
        PERFORM PROCESS_VK12_ZBO5 USING LV_ERR LS_OLD-DATAB.
      ENDIF.

    ENDIF.

    IF LV_ERR IS NOT INITIAL.
      MESSAGE S001 WITH TEXT-E44 DISPLAY LIKE GC_E.
      EXIT.
    ELSE.
      CLEAR:LV_SUBRC.
      LV_SUBRC = 0.

      IF GS_CHANGE-H IS NOT INITIAL.
        MODIFY ZKONA FROM TABLE LT_ZKONA.
        IF SY-SUBRC NE 0.
          LV_SUBRC = 4.
        ENDIF.
      ENDIF.
      IF GS_CHANGE-I IS NOT INITIAL.
        IF LV_SUBRC EQ 0.
          MODIFY ZKONA_ITEM FROM TABLE LT_ZKONA_ITEM.
          IF SY-SUBRC NE 0.
            LV_SUBRC = 4.
          ENDIF.
        ENDIF.
      ENDIF.
      IF LV_SUBRC EQ 0.
        COMMIT WORK AND WAIT.
        GV_SAVE = 'X'.
        CLEAR LV_TEXT2.
        LV_TEXT2 = |커미션 { GS_HEADER-KNUMA } 변경되었습니다.|.

        PERFORM POPUP_TO_DISPLAY_TEXT USING '메시지'
                                            LV_TEXT2.

        PERFORM DEQUEUE_KNUMA.
        PERFORM SAVE_CHANGE_DOC TABLES LT_ZKONA_ITEM
                                USING  'U'.

      ELSE.
        ROLLBACK WORK.
        MESSAGE I001 WITH TEXT-E06 DISPLAY LIKE 'E'. "계약 변경 실패
      ENDIF.
    ENDIF.


  ENDIF.

*----------------------------------------------------------------
*- 커미션 생성
*  IF GS_HEADER-KNUMA IS INITIAL.
*
*    PERFORM POPUP_CONFIRM USING '확인'
*                                '저장 하시겠습니까?'
*                                 LV_ANSWER.
*    IF LV_ANSWER <> 1.
*      EXIT.
*    ENDIF.
*
*
*

**승인자 정보가 없으면 커미션 생성 에러처리
*    SELECT ZNUMC, PERNR, SNAME
*      INTO TABLE @DATA(LT_VALUE)
*      FROM ZSD0105T
*      WHERE VKORG  = @GS_ORG-VKORG
*        AND VTWEG  = @GS_ORG-VTWEG
*        AND SPART  = @GS_ORG-SPART
*        AND VKBUR  = @GS_ORG-VKBUR
*        AND ZAUART = 'V6'.
*
*    IF LINE_EXISTS( LT_VALUE[ ZNUMC = '01' ] ) AND
*       LINE_EXISTS( LT_VALUE[ ZNUMC = '02' ] ) AND
*       LINE_EXISTS( LT_VALUE[ ZNUMC = '03' ] ).
*
*      DATA(LV_LINES) = LINES( LT_VALUE ).
*
*      IF LV_LINES > 3.
*        MESSAGE I002 WITH TEXT-E35 TEXT-E36 DISPLAY LIKE 'E'. "승인자 결제라인은 1/2/3차 각 1명씩 3명까지 등록가능합니다. 승인자 정보를 확인해주세요.
*        EXIT.
*      ENDIF.
*
*    ELSE.
*      MESSAGE I001 WITH TEXT-E29 DISPLAY LIKE 'E'. "승인자 정보를 확인해 주세요.
*      EXIT.
*    ENDIF.
*
*    CALL FUNCTION 'NUMBER_GET_NEXT'
*      EXPORTING
*        NR_RANGE_NR             = '10'
*        OBJECT                  = 'ZSD_000013'
*      IMPORTING
*        NUMBER                  = GS_HEADER-KNUMA
*      EXCEPTIONS
*        INTERVAL_NOT_FOUND      = 1
*        NUMBER_RANGE_NOT_INTERN = 2
*        OBJECT_NOT_FOUND        = 3
*        QUANTITY_IS_0           = 4
*        QUANTITY_IS_NOT_1       = 5
*        INTERVAL_OVERFLOW       = 6
*        BUFFER_OVERFLOW         = 7
*        OTHERS                  = 8.
*
*    IF SY-SUBRC <> 0.
*      MESSAGE I001 WITH TEXT-E04 DISPLAY LIKE 'E'. "계약번호 생성 실패
*      EXIT.
*    ENDIF.
*
*    CLEAR LS_ZKONA.
*    LS_ZKONA-KNUMA = GS_HEADER-KNUMA.
*    LS_ZKONA-VKORG = GS_ORG-VKORG.
*    LS_ZKONA-VTWEG = GS_ORG-VTWEG.
*    LS_ZKONA-SPART = GS_ORG-SPART.
*    LS_ZKONA-VKBUR = GS_ORG-VKBUR.
*    LS_ZKONA-VKGRP = GS_ORG-VKGRP.
*    LS_ZKONA-BOTEXT = GS_HEADER-BOTEXT.
*    LS_ZKONA-AUSFU = GS_HEADER-AUSFU.
*    LS_ZKONA-BONEM = GS_HEADER-AUSFU.
*    LS_ZKONA-WAERS = GS_HEADER-WAERS.
*    LS_ZKONA-ERNAM = SY-UNAME.
*    LS_ZKONA-ERDAT = SY-DATUM.
*    LS_ZKONA-ERZET = SY-UZEIT.
*    LS_ZKONA-DATAB = GS_HEADER-DATAB.
*    LS_ZKONA-DATBI = GS_HEADER-DATBI.
*    LS_ZKONA-BOSTA = GS_HEADER-BOSTA.
*    LS_ZKONA-ABSPZ = GS_HEADER-ABSPZ.
*
*    APPEND LS_ZKONA TO LT_ZKONA.
*    MOVE-CORRESPONDING LS_ZKONA TO YZKONA. "SRM2402-10021 생성Doc 관리
*    MODIFY ZKONA FROM TABLE LT_ZKONA.
*
*    IF SY-SUBRC = 0.
*
*      LOOP AT GT_HIST INTO DATA(LS_HIST).
*
*        PERFORM CREATE_VAKEY USING LS_HIST.
*        CLEAR LS_ZKONA_ITEM.
*        LS_ZKONA_ITEM-KNUMA     = GS_HEADER-KNUMA.
*        LS_ZKONA_ITEM-KSCHL     = LS_HIST-KSCHL.
*        LS_ZKONA_ITEM-BONEM     = LS_HIST-AUSFU.
*        LS_ZKONA_ITEM-AUSFU     = LS_HIST-AUSFU.
*        LS_ZKONA_ITEM-VAKEY     = GV_VAKEY.
*        LS_ZKONA_ITEM-VKORG     = LS_HIST-VKORG.
*        LS_ZKONA_ITEM-VTWEG     = LS_HIST-VTWEG.
*        LS_ZKONA_ITEM-SPART     = LS_HIST-SPART.
*        LS_ZKONA_ITEM-KUNNR     = LS_HIST-KUNNR.
*        LS_ZKONA_ITEM-MATNR     = LS_HIST-MATNR.
*        LS_ZKONA_ITEM-PRODH     = LS_HIST-PRODH.
*        LS_ZKONA_ITEM-INCO1     = LS_HIST-INCO1.
*        LS_ZKONA_ITEM-WAERS     = LS_HIST-KONWA.
*        LS_ZKONA_ITEM-AUBEL     = LS_HIST-AUBEL.
*        LS_ZKONA_ITEM-AUPOS     = LS_HIST-AUPOS.
*        LS_ZKONA_ITEM-DATAB     = LS_HIST-DATAB.
*        LS_ZKONA_ITEM-DATBI     = LS_HIST-DATBI.
*        LS_ZKONA_ITEM-KBETR     = LS_HIST-KBETR.
*        LS_ZKONA_ITEM-KONWA     = LS_HIST-KONWA.
*        LS_ZKONA_ITEM-KPEIN     = LS_HIST-KPEIN.
*        LS_ZKONA_ITEM-KMEIN     = LS_HIST-KMEIN.
*        LS_ZKONA_ITEM-STAT_FLAG = LS_HIST-STAT_FLAG.
*        APPEND LS_ZKONA_ITEM TO LT_ZKONA_ITEM.
*
**{ SRM2402-10021 생성Doc 관리 - s
*        MOVE-CORRESPONDING LS_ZKONA_ITEM TO YZKONA_ITEM.
*        YZKONA_ITEM-KZ = 'I'.
*        APPEND YZKONA_ITEM.
**} SRM2402-10021 - e
*
*      ENDLOOP.
*
*      MODIFY ZKONA_ITEM FROM TABLE LT_ZKONA_ITEM.
*      IF SY-SUBRC = 0.
*
*        GV_SAVE = 'X'.
*        DATA(LV_TEXT1) = |커미션 { GS_HEADER-KNUMA } 생성되었습니다.|.
*        PERFORM POPUP_TO_DISPLAY_MULTI_TEXT
*          USING '메시지'
*                LV_TEXT1
*                '승인 요청 및 커미션 변경은 T-CODE ZVBO2에서 진행해 주세요.'.
*
*        COMMIT WORK.
*
**{ SRM2402-10021 - s Lock해제 및 History 추가
*        PERFORM SAVE_CHANGE_DOC TABLES LT_ZKONA_ITEM
*                                USING  'I'.
**} SRM2402-10021 - e
*
*        LEAVE TO SCREEN 0.
*
*      ELSE.
*
*        MESSAGE I001 WITH TEXT-E05
*        DISPLAY LIKE 'E'. "계약 생성 실패
*        ROLLBACK WORK.
*
*      ENDIF.
*    ENDIF.
*
**- 커미션 변경
*  ELSE.
*
*    PERFORM SAVE_LONG_TEXT USING '0'. "기안자 long text SRM2404-03220
*
*    PERFORM GET_LS_OLD USING LV_ANSWER
*                             LV_ERR
*                             LS_OLD.
*
*    IF LV_ERR = 'X'.
*      EXIT.
*    ENDIF.
*
**-[SRM2406-00779_S
**- 로직 수정 : 판가마스터 생성 후 -> DB 저장
**- 기존 로직 : DB 저장 후 판가마스터 생성
*    IF GV_APRV_STAT = 'C' OR GS_HEADER-BOSTA = 'B'.
*
*      PERFORM PROCESS_VK11 USING LV_ERR.
*      PERFORM PROCESS_VK12 USING LV_ERR LS_OLD-DATAB.
*
*      IF LV_ERR = 'X'.
*
*        EXIT.
*
*      ELSE.
*
*        CLEAR LS_ZKONA.
*
*        LS_ZKONA-KNUMA = GS_HEADER-KNUMA.
*        LS_ZKONA-VKORG = GS_ORG-VKORG.
*        LS_ZKONA-VTWEG = GS_ORG-VTWEG.
*        LS_ZKONA-SPART = GS_ORG-SPART.
*        LS_ZKONA-VKBUR = GS_ORG-VKBUR.
*        LS_ZKONA-VKGRP = GS_ORG-VKGRP.
*        LS_ZKONA-BOTEXT = GS_HEADER-BOTEXT.
*        LS_ZKONA-AUSFU = GS_HEADER-AUSFU.
*        LS_ZKONA-BONEM = GS_HEADER-AUSFU.
*        LS_ZKONA-WAERS = GS_HEADER-WAERS.
*        LS_ZKONA-ERNAM = LS_OLD-ERNAM.
*        LS_ZKONA-ERDAT = LS_OLD-ERDAT.
*        LS_ZKONA-ERZET = LS_OLD-ERZET.
*        LS_ZKONA-AENAM = SY-UNAME.
*        LS_ZKONA-AEDAT = SY-DATUM.
*        LS_ZKONA-AEZET = SY-UZEIT.
*        LS_ZKONA-DATAB = GS_HEADER-DATAB.
*        LS_ZKONA-DATBI = GS_HEADER-DATBI.
*        LS_ZKONA-BOSTA = GS_HEADER-BOSTA.
*        LS_ZKONA-ABSPZ = GS_HEADER-ABSPZ.
*
*        APPEND LS_ZKONA TO LT_ZKONA.
*        MOVE-CORRESPONDING LS_ZKONA TO YZKONA. "SRM2402-10021
*
*        MODIFY ZKONA FROM TABLE LT_ZKONA.
*
*        IF SY-SUBRC = 0.
*
*          DELETE FROM ZKONA_ITEM WHERE  KNUMA = GS_HEADER-KNUMA.
*
*          IF SY-SUBRC = 0.
*            COMMIT WORK.
*          ELSE.
*            ROLLBACK WORK.
*          ENDIF.
*
*          LOOP AT GT_HIST INTO DATA(LS_HIST2).
*
*            PERFORM CREATE_VAKEY USING LS_HIST2.
*
*            CLEAR LS_ZKONA_ITEM.
*
*            LS_ZKONA_ITEM-KNUMA     = GS_HEADER-KNUMA.
*            LS_ZKONA_ITEM-KSCHL     = LS_HIST2-KSCHL.
*            LS_ZKONA_ITEM-BONEM     = LS_HIST2-AUSFU.
*            LS_ZKONA_ITEM-AUSFU     = LS_HIST2-AUSFU.
*            LS_ZKONA_ITEM-VAKEY     = GV_VAKEY.
*            LS_ZKONA_ITEM-VKORG     = LS_HIST2-VKORG.
*            LS_ZKONA_ITEM-VTWEG     = LS_HIST2-VTWEG.
*            LS_ZKONA_ITEM-SPART     = LS_HIST2-SPART.
*            LS_ZKONA_ITEM-KUNNR     = LS_HIST2-KUNNR.
*            LS_ZKONA_ITEM-MATNR     = LS_HIST2-MATNR.
*            LS_ZKONA_ITEM-PRODH     = LS_HIST2-PRODH.
*            LS_ZKONA_ITEM-INCO1     = LS_HIST2-INCO1.
*            LS_ZKONA_ITEM-WAERS     = LS_HIST2-KONWA.
*            LS_ZKONA_ITEM-AUBEL     = LS_HIST2-AUBEL.
*            LS_ZKONA_ITEM-AUPOS     = LS_HIST2-AUPOS.
*            LS_ZKONA_ITEM-DATAB     = LS_HIST2-DATAB.
*            LS_ZKONA_ITEM-DATBI     = LS_HIST2-DATBI.
*            LS_ZKONA_ITEM-KBETR     = LS_HIST2-KBETR.
*            LS_ZKONA_ITEM-KONWA     = LS_HIST2-KONWA.
*            LS_ZKONA_ITEM-KPEIN     = LS_HIST2-KPEIN.
*            LS_ZKONA_ITEM-KMEIN     = LS_HIST2-KMEIN.
*            LS_ZKONA_ITEM-STAT_FLAG = LS_HIST2-STAT_FLAG.
*
*            IF LS_HIST2-DELETE = 'X'.
*              LS_ZKONA_ITEM-LOEVM = 'X'.
*            ENDIF.
*
*            APPEND LS_ZKONA_ITEM TO LT_ZKONA_ITEM.
*
*          ENDLOOP.
*
*          MODIFY ZKONA_ITEM FROM TABLE LT_ZKONA_ITEM.
*
*          IF SY-SUBRC = 0.                               "계약 변경 성공
*
*            COMMIT WORK.
*            GV_SAVE = 'X'.
*            DATA(LV_TEXT2) = |커미션 { GS_HEADER-KNUMA } 변경되었습니다.|.
*
*            PERFORM POPUP_TO_DISPLAY_TEXT USING '메시지'
*                                                LV_TEXT2.
*
**{ SRM2402-10021 - s Lock해제 및 History 추가
*            PERFORM DEQUEUE_KNUMA.
*            PERFORM SAVE_CHANGE_DOC TABLES LT_ZKONA_ITEM
*                                    USING  'U'.
**} SRM2402-10021 - e
*
*            LEAVE TO SCREEN 0.
*
*          ELSE.
*
*            MESSAGE I001 WITH TEXT-E06 DISPLAY LIKE 'E'. "계약 변경 실패
*            ROLLBACK WORK.
*
*          ENDIF.
*        ENDIF.
*      ENDIF.
*
*
*    ENDIF.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPR_REQ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM APPR_REQ .
  DATA : LV_ANSWER.

  PERFORM POPUP_CONFIRM USING '확인'
                     '승인 요청 하시겠습니까?'
                             LV_ANSWER.
  CHECK LV_ANSWER = 1.

  PERFORM SAVE_LONG_TEXT USING '0'. " 기안자 long text SRM2404-03220

*- 승인 요청 번호 생성
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '10'
      OBJECT                  = 'ZSD_000012'
    IMPORTING
      NUMBER                  = GV_REQNO
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      BUFFER_OVERFLOW         = 7
      OTHERS                  = 8.

  IF SY-SUBRC <> 0.
    MESSAGE I001 WITH TEXT-E09 DISPLAY LIKE 'E'. "승인번호 요청에 실패했습니다.
    EXIT.
  ENDIF.

  DATA : LT_ZSDT0620 TYPE TABLE OF ZSDT0620,
         LT_ZSDT0630 TYPE TABLE OF ZSDT0630,
         LT_ZSDT0700 TYPE TABLE OF ZSDT0700,
         LT_ZSD0105T TYPE TABLE OF ZSD0105T.
  CLEAR: LT_ZSDT0620, LT_ZSDT0630, LT_ZSD0105T, LT_ZSDT0700.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @LT_ZSD0105T
    FROM ZSD0105T
    WHERE VKORG  = @GS_ORG-VKORG
     AND  VTWEG  = @GS_ORG-VTWEG
     AND  SPART  = @GS_ORG-SPART
     AND  VKBUR  = @GS_ORG-VKBUR
     AND  ZAUART = 'V6'.

*- 품의개요(0620)테이블 INSERT
  LT_ZSDT0620 = VALUE #( ( ZV4REQNO = GV_REQNO
                          CON_TYPE = 'V6'
                          APRV_STAT = 'P'
                          ZNUMC = '01'
                          PROG_NAM = VALUE #( LT_ZSD0105T[ ZNUMC = '01' ]-PERNR OPTIONAL )
                          REQ_DAT = SY-DATUM
                          VKORG = GS_ORG-VKORG
                          VTWEG = GS_ORG-VTWEG
                          SPART = GS_ORG-SPART
                          VKBUR = GS_ORG-VKBUR
                          APRV_1ST = VALUE #( LT_ZSD0105T[ ZNUMC = '01' ]-PERNR OPTIONAL )
                          APRV_2ST = VALUE #( LT_ZSD0105T[ ZNUMC = '02' ]-PERNR OPTIONAL )
                          APRV_3ST = VALUE #( LT_ZSD0105T[ ZNUMC = '03' ]-PERNR OPTIONAL )
                          DRAFT_OPIN = SWITCH #( GV_LONG WHEN 'S' THEN 'X'   "SRM2404-03220 long text추가
                                                                ELSE ' ' )
                          ERNAM = SY-UNAME
                          ERDAT = SY-DATUM
                          ERZET = SY-UZEIT   ) ).

  MODIFY ZSDT0620 FROM TABLE LT_ZSDT0620.
  IF SY-SUBRC = 0.
*- 커미션 결재관리(0630)테이블 INSERT
*- 승인요청자(-0차수)
    DATA : LV_PERSNUMBER TYPE USR21-PERSNUMBER,
           LV_NAME       TYPE ADRP-NAME_TEXT.
    CLEAR : LV_PERSNUMBER, LV_NAME.

    SELECT SINGLE PERSNUMBER
      INTO @LV_PERSNUMBER
      FROM USR21
      WHERE BNAME = @SY-UNAME.

    SELECT SINGLE NAME_TEXT
      INTO @LV_NAME
      FROM ADRP
      WHERE PERSNUMBER = @LV_PERSNUMBER.

    LT_ZSDT0630 = VALUE #( ( ZV4REQNO = GV_REQNO
                             VBELN = GS_HEADER-KNUMA
                             ZNUMC = '00'
                             UNAME = SY-UNAME
                             SNAME = LV_NAME
                             ZAPPRV = 'Y'
                             ZLONGID = SWITCH #( GV_LONG WHEN 'S' THEN 'X'   "SRM2404-03220 long text추가
                                                                  ELSE ' ' )
                             ZAPRDAT = SY-DATUM
                             ZAPRTIME = SY-UZEIT
                             ERDAT = SY-DATUM
                             ERZET = SY-UZEIT ) ).

    LOOP AT LT_ZSD0105T INTO DATA(LS_ZSD0105T).

      LT_ZSDT0630 = VALUE #( BASE LT_ZSDT0630
                           ( ZV4REQNO = GV_REQNO
                             VBELN = GS_HEADER-KNUMA
                             ZNUMC = LS_ZSD0105T-ZNUMC
                             UNAME = LS_ZSD0105T-PERNR
                             SNAME = LS_ZSD0105T-SNAME
                             ZAPRDAT = SY-DATUM
                             ZAPRTIME = SY-UZEIT
                             ERDAT = SY-DATUM
                             ERZET = SY-UZEIT ) ).
    ENDLOOP.

    MODIFY ZSDT0630 FROM TABLE LT_ZSDT0630.
    IF SY-SUBRC = 0.
*- 커미션 승인요청(0700)테이블 INSERT
      LT_ZSDT0700 = VALUE #( ( ZV4REQNO = GV_REQNO
                               KNUMA = GS_HEADER-KNUMA
                               VKORG = GS_ORG-VKORG
                               VTWEG = GS_ORG-VTWEG
                               SPART = GS_ORG-SPART
                               VKBUR = GS_ORG-VKBUR
                               VKGRP = GS_ORG-VKGRP
                               BONEM = GS_HEADER-AUSFU
                               AUSFU = GS_HEADER-AUSFU
                               ZCHDAT = SY-DATUM
                               ZCHTIM = SY-UZEIT
                               ERDAT = SY-DATUM
                               ERZET = SY-UZEIT ) ).
      MODIFY ZSDT0700 FROM TABLE LT_ZSDT0700.
      IF SY-SUBRC = 0.
        MESSAGE I001 WITH TEXT-S04. "승인요청이 완료되었습니다.
        GV_APRV_STAT = 'P'.
        COMMIT WORK.
*- 승인메일 전송(1차수 승인자)
*-> CCM : 22.11.2023 11:53:05 / ZLSGSD4
        IF SY-SYSID NE 'S4D'. "개발서버에서는 메일전송 X
          PERFORM SEND_MAIL.
        ENDIF.
*<-
        PERFORM DEQUEUE_KNUMA.  "SRM2402-10021
        PERFORM CALL_SIMPLE_APPROVAL USING GV_REQNO.
        LEAVE TO SCREEN 0.
      ELSE.
        MESSAGE I001 WITH TEXT-E12 DISPLAY LIKE 'E'. "승인요청에 실패했습니다.
        ROLLBACK WORK.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_VALUE_VALIDATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_COND .
  DATA: LV_ERR.
  CLEAR LV_ERR.

*- 필수값 입력 확인
  IF GS_HEADER-BOTEXT IS NOT INITIAL AND
     GS_HEADER-AUSFU  IS NOT INITIAL AND
     GS_HEADER-WAERS  IS NOT INITIAL AND
     GS_HEADER-DATAB  IS NOT INITIAL AND
     GS_HEADER-DATBI  IS NOT INITIAL.
    PERFORM CHECK_DATE_VALUE_VALIDATION USING LV_ERR.   "디폴트값이 존재해서 값을 따로 입력 안하면 유효기간 체크 로직을 타지 않고 바로  조건유형이 변경된다.
    IF LV_ERR = 'X'.                                    "날짜체크로직 체크 - 필드값 입력할 때, 조건유형변경할 때, 라인추가할 때, 저장할 때.
      PERFORM RECOVER_VALUE_KOBOG.
      EXIT.
    ENDIF.
  ELSE.
    MESSAGE S001 WITH TEXT-E02 DISPLAY LIKE 'E'.
    PERFORM RECOVER_VALUE_KOBOG.
    EXIT.
  ENDIF.

*- 빈값 체크
  IF GT_ITAB IS NOT INITIAL.
    IF GS_HEADER-KOBOG <> VALUE #( GT_ITAB[ 1 ]-KSCHL ).
      PERFORM CHECK_EMPTY_VALUE.
      IF GV_ERROR = 'X'.               "DATA_CHANGED의 GV_ERROR 값도 같이 체크
        PERFORM RECOVER_VALUE_KOBOG.
*        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

*- 조건유형 변경
  IF ( GV_ERROR = 'X' AND SY-TCODE = GC_ZVBO1 ) OR
     ( GV_ERROR = 'X' AND SY-TCODE = GC_ZVBO2 ) OR
     ( GV_ERROR = 'X' AND SY-TCODE = GC_ZVBO6 ).
    MESSAGE S001 WITH TEXT-E07 DISPLAY LIKE 'E'.
    EXIT.
  ELSE.
    PERFORM SET_TABNAME.
    GS_COPY = CORRESPONDING #( GS_HEADER ).
    IF GT_ITAB IS NOT INITIAL.
      DATA(LS_LINE) = VALUE #( GT_ITAB[ 1 ] OPTIONAL ).
      DELETE GT_HIST WHERE KSCHL   =  LS_LINE-KSCHL
                       AND TABNAME = LS_LINE-TABNAME.
      GT_HIST = VALUE #( BASE GT_HIST FOR LS_ITAB IN GT_ITAB
                        ( CORRESPONDING #( LS_ITAB )  ) ).
    ENDIF.

    CLEAR GT_ITAB.
    IF LINE_EXISTS( GT_HIST[ KSCHL = GS_HEADER-KOBOG TABNAME = GS_HEADER-TABNAME ] ).
      LOOP AT GT_HIST INTO DATA(LS_HIST) WHERE KSCHL = GS_HEADER-KOBOG
                                            AND TABNAME = GS_HEADER-TABNAME.
        GT_ITAB = VALUE #( BASE GT_ITAB ( CORRESPONDING #( LS_HIST ) ) ).
      ENDLOOP.
    ENDIF.

*    IF GT_ITAB IS NOT INITIAL.
*      DELETE GT_HIST WHERE KSCHL = VALUE #( GT_ITAB[ 1 ]-KSCHL OPTIONAL ).
*      GT_HIST = VALUE #( BASE GT_HIST FOR LS_ITAB IN GT_ITAB
*                        ( CORRESPONDING #( LS_ITAB )  ) ).
*    ENDIF.
*
*    CLEAR GT_ITAB.
*
*    IF LINE_EXISTS( GT_HIST[ KSCHL = GS_HEADER-KOBOG ] ).
*      LOOP AT GT_HIST INTO DATA(LS_HIST) WHERE KSCHL = GS_HEADER-KOBOG.
*        GT_ITAB = VALUE #( BASE GT_ITAB ( CORRESPONDING #( LS_HIST ) ) ).
*      ENDLOOP.
*    ENDIF.
  ENDIF.


*    GS_COPY = CORRESPONDING #( GS_HEADER ).
*    IF GT_ITAB IS NOT INITIAL.
*      DELETE GT_HIST WHERE KSCHL = VALUE #( GT_ITAB[ 1 ]-KSCHL OPTIONAL ).
*      GT_HIST = VALUE #( BASE GT_HIST FOR LS_ITAB IN GT_ITAB
*                        ( CORRESPONDING #( LS_ITAB )  ) ).
*    ENDIF.
*
*    CLEAR GT_ITAB.
*
*    IF LINE_EXISTS( GT_HIST[ KSCHL = GS_HEADER-KOBOG ] ).
*      LOOP AT GT_HIST INTO DATA(LS_HIST) WHERE KSCHL = GS_HEADER-KOBOG.
*        GT_ITAB = VALUE #( BASE GT_ITAB ( CORRESPONDING #( LS_HIST ) ) ).
*      ENDLOOP.
*    ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_LISTBOX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_LISTBOX .

  TYPE-POOLS : VRM.
  DATA : LV_ID     TYPE VRM_ID,
         LT_VALUES TYPE VRM_VALUES.
  CLEAR : LV_ID, LT_VALUES, GT_LIST.

  SELECT DISTINCT A~KSCHL,
                  C~VTEXT,
                  B~KVEWE && B~KOTABNR AS TABNAME,
                  E~KRECH
   INTO TABLE @DATA(LT_VALUE5)
   FROM T685 AS A INNER JOIN T682I AS B
                    ON A~KOZGF = B~KOZGF
                   AND A~KVEWE = B~KVEWE
                   AND A~KAPPL = B~KAPPL
                  INNER JOIN T685T AS C
                    ON C~SPRAS = '3'
                   AND A~KVEWE = C~KVEWE
                   AND A~KAPPL = C~KAPPL
                   AND A~KSCHL = C~KSCHL
                  INNER JOIN T685A AS E
                   ON E~KSCHL = A~KSCHL
                  AND E~KAPPL = A~KAPPL
   WHERE
*      A~KSCHL = 'ZBO1'
*      OR A~KSCHL = 'ZBO2'
*      OR A~KSCHL = 'ZBO3'
*      OR A~KSCHL = 'ZBO4'
       A~KSCHL = 'ZBO5'.
*      OR A~KSCHL = 'ZBO6'
*      OR A~KSCHL = 'ZBO7'.


  IF LT_VALUE5 IS NOT INITIAL.
    SELECT B~KSCHL,
           B~VTEXT,
           B~TABNAME,
           B~KRECH,
           A~DDTEXT
      FROM DD02T AS A INNER JOIN @LT_VALUE5 AS B
                            ON A~DDLANGUAGE = '3'
                           AND A~TABNAME = B~TABNAME
      INTO CORRESPONDING FIELDS OF TABLE @GT_LIST.
  ENDIF.

  GS_HEADER-KOBOG = 'ZBO5'.
*  GS_HEADER-BOSTA = GC_B.    "계약상태
*  PERFORM SET_BOSTA_TEXT.
  GS_HEADER-A925  = SPACE.GS_HEADER-A928  = GC_X.
  PERFORM SET_TABNAME.


  LOOP AT GT_LIST INTO DATA(LS_VALUE).
    DATA(LV_TEXT) = COND #( WHEN LS_VALUE-KRECH = 'A' THEN | { LS_VALUE-VTEXT } { LS_VALUE-DDTEXT } Rate|
                            WHEN LS_VALUE-KRECH = 'C' THEN | { LS_VALUE-VTEXT } { LS_VALUE-DDTEXT } 정액| ).

    ASSIGN COMPONENT LS_VALUE-TABNAME OF STRUCTURE GS_DESC TO FIELD-SYMBOL(<FS_VAL>).
    IF SY-SUBRC EQ 0.
      <FS_VAL> = LV_TEXT.
    ENDIF.
    CLEAR LV_TEXT.
    IF <FS_VAL> IS ASSIGNED. UNASSIGN <FS_VAL>. ENDIF.
  ENDLOOP.


*  LT_VALUES = VALUE #( BASE LT_VALUES FOR LS_VALUE IN GT_LIST
*                     ( KEY = LS_VALUE-KSCHL
*                       TEXT = COND #( WHEN LS_VALUE-KRECH = 'A' THEN | { LS_VALUE-VTEXT } { LS_VALUE-DDTEXT } Rate|
*                                      WHEN LS_VALUE-KRECH = 'C' THEN | { LS_VALUE-VTEXT } { LS_VALUE-DDTEXT } 정액| ) ) ).
*
*  IF GS_HEADER-KOBOG IS INITIAL.
*    SORT LT_VALUES BY KEY.
*    GS_HEADER-KOBOG = VALUE #( LT_VALUES[ 1 ]-KEY OPTIONAL ).
*  ENDIF.
*
*  LV_ID = 'GS_HEADER-KOBOG'.
*
*  CALL FUNCTION 'VRM_SET_VALUES'
*    EXPORTING
*      ID     = LV_ID
*      VALUES = LT_VALUES.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM HANDLE_USER_COMMAND  USING P_UCOMM LIKE SY-UCOMM.

  CASE P_UCOMM.
    WHEN 'APPEND'.
      PERFORM APPEND.
    WHEN 'DELETE'.
      PERFORM DELETE.
    WHEN 'RESTORE'.
      PERFORM RESTORE. "복구
*-> CCM : 21.11.2023 11:20:26 / ZLSGSD4
    WHEN 'KSCHL'.
      PERFORM DISPLAY_KSCHL. "조회
*<-
  ENDCASE.

  CLEAR P_UCOMM.

  CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
    EXPORTING
      NEW_CODE = 'Z1'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPEND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM APPEND .
  DATA : LV_ERR.
  CLEAR  LV_ERR.

*  IF GS_HEADER-BOTEXT IS NOT INITIAL AND
*     GS_HEADER-AUSFU  IS NOT INITIAL AND
*     GS_HEADER-WAERS  IS NOT INITIAL AND
*     GS_HEADER-DATAB  IS NOT INITIAL AND
*     GS_HEADER-DATBI  IS NOT INITIAL.
*  ELSE.
*    MESSAGE S001 WITH TEXT-E02 DISPLAY LIKE 'E'.
*    EXIT.
*  ENDIF.

  IF GS_HEADER-BOTEXT IS NOT INITIAL AND
     GS_HEADER-AUSFU  IS NOT INITIAL AND
     GS_HEADER-WAERS  IS NOT INITIAL AND
     GS_HEADER-DATAB  IS NOT INITIAL AND
     GS_HEADER-DATBI  IS NOT INITIAL.
    PERFORM CHECK_DATE_VALUE_VALIDATION USING LV_ERR.
    IF LV_ERR = 'X'.
      EXIT.
    ENDIF.
  ELSE.
    MESSAGE S001 WITH TEXT-E02 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.


  DATA(LV_SIGN) = VALUE #( GT_LIST[ KSCHL = GS_HEADER-KOBOG ]-KRECH OPTIONAL ).
  IF LV_SIGN = 'C'.

    GT_ITAB = VALUE #( BASE GT_ITAB
                     ( KSCHL = GS_HEADER-KOBOG
                       VKORG = GS_ORG-VKORG
                       VTWEG = GS_ORG-VTWEG
                       SPART = GS_ORG-SPART
                       AUSFU = GS_HEADER-AUSFU
                       DATAB = GS_HEADER-DATAB
                       DATBI = GS_HEADER-DATBI
                       KONWA = GS_HEADER-WAERS
                       ICON  = ICON_CREATE
                       STAT_FLAG = 'X'
                       NEW   = 'X'
                       TABNAME = GS_HEADER-TABNAME ) ).
  ELSE.
    GT_ITAB = VALUE #( BASE GT_ITAB
                  ( KSCHL  = GS_HEADER-KOBOG
                    VKORG  = GS_ORG-VKORG
                    VTWEG  = GS_ORG-VTWEG
                    SPART  = GS_ORG-SPART
                    AUSFU  = GS_HEADER-AUSFU
                    DATAB  = GS_HEADER-DATAB
                    DATBI  = GS_HEADER-DATBI
                    KONWA  = '%'
                    ICON   = ICON_CREATE
                    NEW   = 'X' "S4HANA PJT CHM2301-00029
                    STAT_FLAG = 'X'
                    TABNAME = GS_HEADER-TABNAME ) ).

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DELETE .
  DATA: LT_INDEX_ROWS TYPE LVC_T_ROW,
        LT_ROW_NO     TYPE LVC_T_ROID,
        LT_ITAB       LIKE TABLE OF GS_ITAB,
        LV_ANSWER.
  CLEAR: LT_INDEX_ROWS, LT_ROW_NO, LT_ITAB, LV_ANSWER.

  PERFORM POPUP_CONFIRM USING '확인'
                     '삭제 하시겠습니까?'
                               LV_ANSWER.
  CHECK LV_ANSWER = 1.

  CALL METHOD GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_INDEX_ROWS
      ET_ROW_NO     = LT_ROW_NO.

  IF LT_ROW_NO[] IS NOT INITIAL.
    LOOP AT LT_ROW_NO INTO DATA(LS_ROW_NO).
      GS_ITAB-DELETE = 'X'.
      GS_ITAB-ICON   = ICON_DELETE.
      MODIFY GT_ITAB FROM GS_ITAB INDEX LS_ROW_NO-ROW_ID TRANSPORTING ICON DELETE.
    ENDLOOP.


*-> S4HANA PJT : 25.01.2024 11:26:16 / ZLSGSD2

    IF GV_APRV_STAT IS INITIAL.
      DELETE GT_ITAB WHERE DELETE = 'X'.
    ELSE.
      DELETE GT_ITAB WHERE DELETE = 'X'
                       AND STAT_FLAG = 'X'.
    ENDIF.
*<-

    IF LINE_EXISTS( GT_ITAB[ ERROR = 'X' ] ).
    ELSE.
      CLEAR GV_ERROR.
    ENDIF.

    GS_ITAB-STAT_FLAG = 'D'.
    MODIFY GT_ITAB FROM GS_ITAB TRANSPORTING STAT_FLAG WHERE ICON = ICON_DELETE.
  ENDIF.

  SORT GT_HIST BY KSCHL TABNAME.
  IF LINE_EXISTS( GT_HIST[ KSCHL = GS_HEADER-KOBOG TABNAME = GS_HEADER-TABNAME ] ).
    DELETE GT_HIST WHERE KSCHL = GS_HEADER-KOBOG
                     AND TABNAME = GS_HEADER-TABNAME.
    GT_HIST = VALUE #( BASE GT_HIST FOR LS_ITAB4 IN GT_ITAB
                       WHERE ( KSCHL = GS_HEADER-KOBOG AND
                               TABNAME = GS_HEADER-TABNAME )
                       ( CORRESPONDING #( LS_ITAB4 )  ) ).
  ENDIF.

*  SORT GT_HIST BY KSCHL.
*  IF LINE_EXISTS( GT_HIST[ KSCHL = GS_HEADER-KOBOG ] ).
*    DELETE GT_HIST WHERE KSCHL = GS_HEADER-KOBOG.
*    GT_HIST = VALUE #( BASE GT_HIST FOR LS_ITAB4 IN GT_ITAB
*                       WHERE ( KSCHL = GS_HEADER-KOBOG )
*                       ( CORRESPONDING #( LS_ITAB4 )  ) ).
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form POPUP_CONFIRM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> LV_ANSWER
*&---------------------------------------------------------------------*
FORM POPUP_CONFIRM  USING    PV_TITLE
                             PV_QUESTION
                             PV_ANSWER.
  CLEAR PV_ANSWER.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = PV_TITLE
      TEXT_QUESTION         = PV_QUESTION
      DISPLAY_CANCEL_BUTTON = ' '
    IMPORTING
      ANSWER                = PV_ANSWER
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_MAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_MAIL .

  DATA : LV_MAIL      TYPE P0105-USRID,
         LV_BODYNUM   TYPE I,
         LS_DOCDATA   LIKE SODOCCHGI1,
         LT_OBJHEAD   LIKE SOLISTI1   OCCURS 1  WITH HEADER LINE,
         LT_OBJPACK   LIKE SOPCKLSTI1 OCCURS 2  WITH HEADER LINE,
         LT_OBJTXT    LIKE SOLISTI1   OCCURS 10 WITH HEADER LINE,
         LT_OBJBIN    LIKE SOLISTI1   OCCURS 10 WITH HEADER LINE,
         LT_RECEIVERS LIKE SOMLRECI1  OCCURS 5  WITH HEADER LINE.
  DATA : LV_KNUMA TYPE KONA-KNUMA,
         LV_AUSFU TYPE LFB1-LIFNR.

  CLEAR   : LV_MAIL,
            LV_BODYNUM,
            LS_DOCDATA,
            LT_RECEIVERS,
            LT_OBJHEAD,
            LT_OBJTXT,
            LT_OBJBIN,
            LT_OBJPACK,
            LV_KNUMA,
            LV_AUSFU.

  REFRESH : LT_RECEIVERS,
            LT_OBJHEAD,
            LT_OBJTXT,
            LT_OBJBIN,
            LT_OBJPACK.

  CHECK GV_SIMPLE_APPROVAL = ' '.


  SELECT SINGLE NAME1
    INTO @DATA(LV_NAME)
    FROM LFA1
    WHERE LIFNR = @GS_HEADER-AUSFU .

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = GS_HEADER-KNUMA
    IMPORTING
      OUTPUT = LV_KNUMA.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = GS_HEADER-AUSFU
    IMPORTING
      OUTPUT = LV_AUSFU.

  SELECT SINGLE NAME_LAST
    INTO @DATA(LV_SNAME)
    FROM USER_ADDR AS A INNER JOIN ZSDT0620 AS B
                           ON A~BNAME = B~ERNAM
   WHERE B~ZV4REQNO = @GV_REQNO.

*- 메일 내용
  LT_OBJTXT-LINE = '[시스템 자동 발송 메일입니다.]'.
  APPEND LT_OBJTXT.

  CONCATENATE 'SAP 커미션 생성 승인 요청이' '아래와 같이 접수 되었습니다.'
  INTO LT_OBJTXT-LINE.
  APPEND LT_OBJTXT.

  CLEAR LT_OBJTXT.
  APPEND LT_OBJTXT.

  CONCATENATE '커미션계약 ' LV_KNUMA ' 내역을 확인 후 ' '커미션 계약 등록을 승인해주세요.'
  INTO LT_OBJTXT-LINE SEPARATED BY SPACE.
  APPEND LT_OBJTXT.

  CLEAR LT_OBJTXT.
  APPEND LT_OBJTXT.

  CONCATENATE '요청자 : ' LV_SNAME
  INTO LT_OBJTXT-LINE.
  APPEND LT_OBJTXT.
  CLEAR LT_OBJTXT.

  CONCATENATE '커미션 번호 : ' LV_KNUMA
  INTO LT_OBJTXT-LINE.
  APPEND LT_OBJTXT.
  CLEAR LT_OBJTXT.

  CONCATENATE '승인 요청 번호 : ' GV_REQNO
  INTO LT_OBJTXT-LINE.
  APPEND LT_OBJTXT.
  CLEAR LT_OBJTXT.

  CONCATENATE 'Agent 명 : ' LV_AUSFU  LV_NAME
  INTO LT_OBJTXT-LINE.
  APPEND LT_OBJTXT.
  CLEAR LT_OBJTXT.

  CONCATENATE 'SAP에 접속하시어 아래의 프로그램을'
              '통해 승인 해주시기 바랍니다.'
  INTO LT_OBJTXT-LINE.
  APPEND LT_OBJTXT.
  CLEAR LT_OBJTXT.


  CONCATENATE '접속 T-CODE : ' 'ZSD1R2700' '-' '[SD]승인 프로그램'
  INTO LT_OBJTXT-LINE SEPARATED BY SPACE.
  APPEND LT_OBJTXT.

  CLEAR LT_OBJTXT.
  APPEND LT_OBJTXT.

  LT_OBJTXT-LINE = '감사합니다.'.
  APPEND LT_OBJTXT.

*- 메일 헤더
  LS_DOCDATA-OBJ_NAME = 'URGENT'.
  LS_DOCDATA-EXPIRY_DAT = SY-DATUM + 10.
  LS_DOCDATA-OBJ_DESCR = | [SAP 커미션 승인 요청 안내] 커미션 승인 요청 No : { GV_REQNO } |.
  LS_DOCDATA-SENSITIVTY = '0'.

  LOOP AT LT_OBJTXT.
    LS_DOCDATA-DOC_SIZE = LS_DOCDATA-DOC_SIZE + STRLEN( LT_OBJTXT ).
  ENDLOOP.

  CLEAR : LT_OBJPACK-TRANSF_BIN.

  DESCRIBE TABLE LT_OBJTXT LINES LV_BODYNUM.

  LT_OBJPACK-HEAD_START = 1.
  LT_OBJPACK-HEAD_NUM   = 0.
  LT_OBJPACK-BODY_START = 1.
  LT_OBJPACK-BODY_NUM   = LV_BODYNUM.
  LT_OBJPACK-DOC_TYPE   = 'RAW'.

  APPEND LT_OBJPACK.

*- 수신자
  SELECT SINGLE A~USRID
    INTO LV_MAIL
*    FROM pa0105 AS a
    FROM ZPA0105 AS A   "ZLSGSD4 S/4HANA인사테이블 변경
                INNER JOIN ZSDT0630 AS B
                        ON A~PERNR EQ B~UNAME
    WHERE A~SUBTY    = '0007'
      AND A~BEGDA   <= SY-DATUM
      AND A~ENDDA   >= SY-DATUM
      AND B~ZV4REQNO = GV_REQNO
      AND B~ZNUMC    = 01.

  IF LV_MAIL IS NOT INITIAL.
    LT_RECEIVERS-RECEIVER   = LV_MAIL.
    LT_RECEIVERS-REC_TYPE   = 'U'.
    LT_RECEIVERS-NOTIF_DEL  = 'X'.
    LT_RECEIVERS-NOTIF_NDEL = 'X'.
    APPEND LT_RECEIVERS.
  ENDIF.

  CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
    EXPORTING
      DOCUMENT_DATA              = LS_DOCDATA
      PUT_IN_OUTBOX              = 'X'
      SENDER_ADDRESS             = 'ADMIN'
      SENDER_ADDRESS_TYPE        = 'U'
      COMMIT_WORK                = 'X'
    TABLES
      PACKING_LIST               = LT_OBJPACK
      OBJECT_HEADER              = LT_OBJHEAD
      CONTENTS_TXT               = LT_OBJTXT
      RECEIVERS                  = LT_RECEIVERS
    EXCEPTIONS
      TOO_MANY_RECEIVERS         = 1
      DOCUMENT_NOT_SENT          = 2
      DOCUMENT_TYPE_NOT_EXIST    = 3
      OPERATION_NO_AUTHORIZATION = 4
      PARAMETER_ERROR            = 5
      X_ERROR                    = 6
      ENQUEUE_ERROR              = 7
      OTHERS                     = 8.

  IF SY-SUBRC <> 0.
    MESSAGE I003(ZSD1) WITH '변경요청 생성은 완료하였지만'
                            '메일 발송은 실패했습니다!'.
  ELSE.
    COMMIT WORK.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_VAKEY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_HIST
*&---------------------------------------------------------------------*
FORM CREATE_VAKEY  USING PS_HIST STRUCTURE GS_ITAB.

  CLEAR GV_VAKEY.

*  CASE PS_HIST-TABNAME.
*    WHEN 'A925'.
*      GV_VAKEY = |{ GS_HEADER-KNUMA }{ PS_HIST-KSCHL }{ PS_HIST-VKORG }{ PS_HIST-VTWEG }{ PS_HIST-SPART }{ PS_HIST-AUSFU }{ PS_HIST-KUNNR }{ PS_HIST-INCO1 }|.
*
*    WHEN 'A928'.
  GV_VAKEY = |{ GS_HEADER-KNUMA }{ PS_HIST-KSCHL }{ PS_HIST-VKORG }{ PS_HIST-VTWEG }{ PS_HIST-SPART }{ PS_HIST-AUSFU }|.
*  ENDCASE.

*  IF PS_HIST-KSCHL = 'ZBO1'.
*    GV_VAKEY = |{ GS_HEADER-KNUMA }{ PS_HIST-KSCHL }{ PS_HIST-VKORG }{ PS_HIST-VTWEG }{ PS_HIST-SPART }{ PS_HIST-AUSFU }{ PS_HIST-KUNNR }{ PS_HIST-MATNR }|.
*
*  ELSEIF PS_HIST-KSCHL = 'ZBO2'.
*    GV_VAKEY = |{ GS_HEADER-KNUMA }{ PS_HIST-KSCHL }{ PS_HIST-VKORG }{ PS_HIST-VTWEG }{ PS_HIST-SPART }{ PS_HIST-AUSFU }{ PS_HIST-KUNNR }{ PS_HIST-PRODH }|.
*
*  ELSEIF PS_HIST-KSCHL = 'ZBO3'.
*    GV_VAKEY = |{ GS_HEADER-KNUMA }{ PS_HIST-KSCHL }{ PS_HIST-VKORG }{ PS_HIST-VTWEG }{ PS_HIST-SPART }{ PS_HIST-AUSFU }{ PS_HIST-KUNNR }{ PS_HIST-MATNR }{ PS_HIST-INCO1 }|.
*
*  ELSEIF PS_HIST-KSCHL = 'ZBO4'.
*    GV_VAKEY = |{ GS_HEADER-KNUMA }{ PS_HIST-KSCHL }{ PS_HIST-VKORG }{ PS_HIST-VTWEG }{ PS_HIST-SPART }{ PS_HIST-AUSFU }{ PS_HIST-KUNNR }{ PS_HIST-PRODH }{ PS_HIST-INCO1 }|.
*
*  ELSEIF PS_HIST-KSCHL = 'ZBO5'.
*    GV_VAKEY = |{ GS_HEADER-KNUMA }{ PS_HIST-KSCHL }{ PS_HIST-VKORG }{ PS_HIST-VTWEG }{ PS_HIST-SPART }{ PS_HIST-AUSFU }{ PS_HIST-KUNNR }{ PS_HIST-INCO1 }|.
*
*  ELSEIF PS_HIST-KSCHL = 'ZBO6'.
*    GV_VAKEY = |{ GS_HEADER-KNUMA }{ PS_HIST-KSCHL }{ PS_HIST-VKORG }{ PS_HIST-VTWEG }{ PS_HIST-SPART }{ PS_HIST-AUSFU }{ PS_HIST-AUBEL }{ PS_HIST-AUPOS }|.
*
*  ELSEIF PS_HIST-KSCHL = 'ZBO7'.
*    GV_VAKEY = |{ GS_HEADER-KNUMA }{ PS_HIST-KSCHL }{ PS_HIST-VKORG }{ PS_HIST-VTWEG }{ PS_HIST-SPART }{ PS_HIST-AUSFU }{ PS_HIST-AUBEL }{ PS_HIST-AUPOS }|.
*
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM HANDLE_DATA_CHANGED   USING P_CHANGED  TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.
  DATA: LS_CELLS  TYPE LVC_S_MODI,
        LS_OUTTAB LIKE GS_ITAB.
  CLEAR GV_ERROR.

  IF P_CHANGED->MT_GOOD_CELLS IS INITIAL.
    EXIT.
  ENDIF.

  LS_CELLS = VALUE #( P_CHANGED->MT_GOOD_CELLS[ 1 ] OPTIONAL ).

  GS_ITAB = VALUE #( GT_ITAB[ LS_CELLS-ROW_ID ] OPTIONAL ).

  PERFORM CHECK_INPUT_VALUE USING P_CHANGED
                                  LS_CELLS-ROW_ID
                                  LS_CELLS-FIELDNAME
                                  LS_CELLS-VALUE.

  IF GV_ERROR = 'X'.
    GS_ITAB-ERROR = 'X'.
    CALL METHOD P_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = LS_CELLS-ROW_ID
        I_FIELDNAME = 'ERROR'
        I_VALUE     = GS_ITAB-ERROR.
    EXIT.
  ELSE.
    CLEAR GS_ITAB-ERROR.
    CALL METHOD P_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = LS_CELLS-ROW_ID
        I_FIELDNAME = 'ERROR'
        I_VALUE     = GS_ITAB-ERROR.
  ENDIF.


  CALL METHOD GRID->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYOUT.

  CALL METHOD GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = GS_STBL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CELL_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_CHANGED
*&      --> LS_CELLS_ROW_ID
*&      --> LS_CELLS_FIELDNAME
*&      --> LS_CELLS_VALUE
*&---------------------------------------------------------------------*
FORM GET_CELL_VALUE  USING  P_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                            PV_ROW_ID
                            PV_FIELDNAME
                            PV_VALUE.

  CALL METHOD P_CHANGED->GET_CELL_VALUE
    EXPORTING
      I_ROW_ID    = PV_ROW_ID
      I_FIELDNAME = PV_FIELDNAME
    IMPORTING
      E_VALUE     = PV_VALUE.

*-> CCM : 15.11.2023 16:35:16 / ZLSGSD4
  DATA : FNAME(25).
  FIELD-SYMBOLS : <LV_FIELD>, <LV_VALUE>.

*__릴리즈 된 계약에 기등록된 품목은 금액필드만 변경 가능
  CHECK GS_HEADER-BOSTA = 'B' AND GS_ITAB-STAT_FLAG NE 'X'.

  IF PV_FIELDNAME NE 'KBETR'.

    CONCATENATE 'GS_ITAB-' PV_FIELDNAME INTO FNAME.
    ASSIGN (FNAME) TO <LV_VALUE>.

    IF PV_VALUE NE <LV_VALUE>.
      "값 원상복구
      CALL METHOD P_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = PV_ROW_ID
          I_FIELDNAME = PV_FIELDNAME
          I_VALUE     = <LV_VALUE>.

      MESSAGE S001 WITH TEXT-E38 DISPLAY LIKE 'E'.
      GV_ERROR = 'X'.
    ENDIF.
  ENDIF.
*<-

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_INPUT_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_CHANGED
*&      --> LS_CELLS_ROW_ID
*&      --> LS_CELLS_FIELDNAME
*&      --> LS_CELLS_VALUE
*&      <-- LV_ERROR_FLAG
*&---------------------------------------------------------------------*
FORM CHECK_INPUT_VALUE  USING  P_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                               PV_ROW_ID
                               PV_FIELDNAME
                               PV_VALUE.

  DATA : LV_KBETR TYPE KONP-KBETR,
         LV_KUNNR TYPE KNA1-KUNNR,
         LV_AUSFU TYPE ZKONA-AUSFU,
         LV_MATNR TYPE MARA-MATNR,
         LV_PRODH TYPE MARA-PRDHA,
         LV_INCO1 TYPE VBKD-INCO1,
         LV_AUBEL TYPE VBAP-VBELN,
         LV_AUPOS TYPE VBAP-POSNR,
         LV_KPEIN TYPE KONP-KPEIN,
         LV_KMEIN TYPE KONP-KMEIN.
  CLEAR : LV_KBETR, LV_KUNNR, LV_MATNR, LV_PRODH, LV_INCO1,LV_AUSFU,
          LV_AUBEL, LV_AUPOS, LV_KPEIN, LV_KMEIN.

  IF PV_ROW_ID < 1.
    EXIT.
  ENDIF.


  PERFORM GET_CELL_VALUE USING P_CHANGED
                               PV_ROW_ID
                               'KBETR'
                               LV_KBETR.

  PERFORM GET_CELL_VALUE USING P_CHANGED
                               PV_ROW_ID
                               'KUNNR'
                               LV_KUNNR.

  PERFORM GET_CELL_VALUE USING P_CHANGED
                               PV_ROW_ID
                               'MATNR'
                               LV_MATNR.

  PERFORM GET_CELL_VALUE USING P_CHANGED
                               PV_ROW_ID
                               'PRODH'
                               LV_PRODH.

  PERFORM GET_CELL_VALUE USING P_CHANGED
                               PV_ROW_ID
                               'INCO1'
                               LV_INCO1.

  PERFORM GET_CELL_VALUE USING P_CHANGED
                               PV_ROW_ID
                               'AUBEL'
                               LV_AUBEL.

  PERFORM GET_CELL_VALUE USING P_CHANGED
                               PV_ROW_ID
                               'AUPOS'
                               LV_AUPOS.

  PERFORM GET_CELL_VALUE USING P_CHANGED
                               PV_ROW_ID
                               'KPEIN'
                               LV_KPEIN.

  PERFORM GET_CELL_VALUE USING P_CHANGED
                               PV_ROW_ID
                               'KMEIN'
                               LV_KMEIN.

*-> CCM : 15.11.2023 22:49:43 / ZLSGSD4
  CHECK GV_ERROR NE 'X'.
*<-

*-조건유형별 키값 중복체크
  PERFORM CHECK_DUPLICATE USING LV_KUNNR LV_MATNR LV_PRODH LV_INCO1 LV_AUBEL LV_AUPOS PV_ROW_ID PV_FIELDNAME P_CHANGED.
*-> CCM : 17.11.2023 12:02:06 / ZLSGSD4
  CHECK GV_ERROR NE 'X'.
*  IF GV_ERROR = 'X'.
*    MESSAGE S001 WITH TEXT-E33 DISPLAY LIKE 'E'.
*    EXIT.
*  ENDIF.
*<-

*-유효성 체크
  IF LV_AUSFU IS NOT INITIAL.
    SELECT SINGLE MANDT
      INTO @SY-MANDT
      FROM LFB1
     WHERE LIFNR = @GS_HEADER-AUSFU
      AND  BUKRS = @GS_ORG-VKORG.
    IF SY-SUBRC <> 0.
      MESSAGE S001 WITH TEXT-E01 DISPLAY LIKE 'E'. "리베이트 수령인을 확인해 주세요.
      GV_ERROR = 'X'.
      EXIT.
    ELSE.
      SELECT SINGLE MANDT
        INTO @SY-MANDT
        FROM KNVV
       WHERE KUNNR = @LV_AUSFU
         AND VKORG = @GS_ORG-VKORG
         AND VTWEG = @GS_ORG-VTWEG
         AND SPART = @GS_ORG-SPART.
      IF SY-SUBRC <> 0.
        MESSAGE S001 WITH TEXT-E01 DISPLAY LIKE 'E'. "리베이트 수령인을 확인해 주세요.
        GV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

  IF LV_KUNNR IS NOT INITIAL.
    SELECT SINGLE KUNNR
      INTO @DATA(LV_KUNNR2)
      FROM KNVV
      WHERE KUNNR = @LV_KUNNR
        AND VKORG = @GS_ORG-VKORG
        AND VTWEG = @GS_ORG-VTWEG
        AND SPART = @GS_ORG-SPART.
    IF SY-SUBRC <> 0.
      MESSAGE S001 WITH TEXT-E20 DISPLAY LIKE 'E'.
      GV_ERROR = 'X'.
      EXIT.
*-> CCM : 15.11.2023 15:38:33 / ZLSGSD4 리베이트 수령인 입력 막기
    ELSE.
      SELECT SINGLE KTOKD
        INTO @DATA(LV_KUNNR3)
        FROM KNA1
       WHERE KUNNR = @LV_KUNNR.
      IF  LV_KUNNR3 EQ '1850' OR LV_KUNNR3 EQ '0094'
        OR LV_KUNNR3 EQ '0093' OR LV_KUNNR3 EQ '9093'.

        MESSAGE S001 WITH TEXT-E37 DISPLAY LIKE 'E'.
        GV_ERROR = 'X'.
        EXIT.
      ENDIF.
*<-
    ENDIF.
  ENDIF.

  IF LV_MATNR IS NOT INITIAL.
    SELECT SINGLE MATNR
      INTO @DATA(LV_MATNR2)
      FROM MVKE
      WHERE MATNR = @LV_MATNR
        AND VKORG = @GS_ORG-VKORG
        AND VTWEG = @GS_ORG-VTWEG.
    IF SY-SUBRC <> 0.
      MESSAGE S001 WITH TEXT-E21 DISPLAY LIKE 'E'.
      GV_ERROR = 'X'.
      EXIT.
    ELSE.
      IF GS_ITAB-KSCHL = 'ZBO1'.
        SELECT SINGLE MEINS
          INTO @LV_KMEIN
          FROM MARA
          WHERE MATNR = @LV_MATNR.
        IF SY-SUBRC = 0.
          CALL METHOD P_CHANGED->MODIFY_CELL
            EXPORTING
              I_ROW_ID    = PV_ROW_ID
              I_FIELDNAME = 'KMEIN'
              I_VALUE     = LV_KMEIN.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF LV_PRODH IS NOT INITIAL.
    SELECT SINGLE PRODH
     INTO @DATA(LV_PRODH2)
     FROM T179T
     WHERE SPRAS = @SY-LANGU
       AND PRODH = @LV_PRODH.
    IF SY-SUBRC <> 0.
      MESSAGE S001 WITH TEXT-E22 DISPLAY LIKE 'E'.
      GV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.

  IF LV_INCO1 IS NOT INITIAL.
    SELECT SINGLE INCO1
      INTO @DATA(LV_INCO12)
      FROM TINCT
      WHERE SPRAS = @SY-LANGU
        AND INCO1 = @LV_INCO1.
    IF SY-SUBRC <> 0.
      MESSAGE S001 WITH TEXT-E23 DISPLAY LIKE 'E'.
      GV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.

  IF LV_AUBEL IS NOT INITIAL.
    SELECT SINGLE VBELN
      INTO @DATA(LV_AUBEL2)
      FROM VBAK
      WHERE VBELN = @LV_AUBEL.
    IF SY-SUBRC <> 0.
      MESSAGE S001 WITH TEXT-E24 DISPLAY LIKE 'E'.
      GV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ELSEIF LV_AUBEL IS NOT INITIAL AND
         LV_AUPOS IS NOT INITIAL.
    SELECT SINGLE POSNR
    INTO @DATA(LV_AUPOS2)
    FROM VBAP
    WHERE VBELN = @LV_AUBEL
      AND POSNR = @LV_AUPOS.
    IF SY-SUBRC <> 0.
      MESSAGE S001 WITH TEXT-E25 DISPLAY LIKE 'E'.
      GV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.

  IF LV_MATNR IS NOT INITIAL AND
     LV_KMEIN IS NOT INITIAL.
    SELECT SINGLE MEINS
      INTO @DATA(LV_KMEIN2)
      FROM MARA
      WHERE MATNR = @LV_MATNR
        AND MEINS = @LV_KMEIN.
    IF SY-SUBRC <> 0.
      MESSAGE S001 WITH TEXT-E27 DISPLAY LIKE 'E'.
      GV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.


  IF LV_KBETR IS NOT INITIAL.
    LV_KBETR = ABS( LV_KBETR ) * -1.
    CALL METHOD P_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = PV_ROW_ID
        I_FIELDNAME = 'KBETR'
        I_VALUE     = LV_KBETR.
  ENDIF.

*- 라인별 필드 빈값 체크
*  CASE GS_ITAB-KSCHL.
*    WHEN 'ZBO1'.
*      IF LV_KBETR IS INITIAL OR
*         LV_KUNNR IS INITIAL OR
*         LV_MATNR IS INITIAL OR
*         LV_KPEIN IS INITIAL OR
*         LV_KMEIN IS INITIAL.
*        GV_ERROR = 'X'.
*        EXIT.
*      ELSE.
**        GV_INPUT = 'X'.
*      ENDIF.
*    WHEN 'ZBO2'.
*      IF LV_KBETR IS INITIAL OR
*         LV_KUNNR IS INITIAL OR
*         LV_PRODH IS INITIAL OR
*         LV_KPEIN IS INITIAL OR
*         LV_KMEIN IS INITIAL.
*        GV_ERROR = 'X'.
*        EXIT.
*      ELSE.
**        GV_INPUT = 'X'.
*      ENDIF.
*    WHEN 'ZBO3'.
*      IF LV_KBETR IS INITIAL OR
*         LV_KUNNR IS INITIAL OR
*         LV_MATNR IS INITIAL OR
*         LV_INCO1 IS INITIAL.
*        GV_ERROR = 'X'.
*        EXIT.
*      ELSE.
**        GV_INPUT = 'X'.
*      ENDIF.
*    WHEN 'ZBO4'.
*      IF LV_KBETR IS INITIAL OR
*         LV_KUNNR IS INITIAL OR
*         LV_PRODH IS INITIAL OR
*         LV_INCO1 IS INITIAL.
*        GV_ERROR = 'X'.
*        EXIT.
*      ELSE.
**        GV_INPUT = 'X'.
*      ENDIF.
*    WHEN 'ZBO5'.
*      IF LV_KBETR IS INITIAL OR
*         LV_KUNNR IS INITIAL OR
*         LV_INCO1 IS INITIAL.
*        GV_ERROR = 'X'.
*        EXIT.
*      ELSE.
**        GV_INPUT = 'X'.
*      ENDIF.
*    WHEN 'ZBO6'.
*      IF LV_KBETR IS INITIAL OR
*         LV_AUBEL IS INITIAL OR
*         LV_AUPOS IS INITIAL.
*        GV_ERROR = 'X'.
*        EXIT.
*      ELSE.
**        GV_INPUT = 'X'.
*      ENDIF.
*    WHEN 'ZBO7'.
*      IF LV_KBETR IS INITIAL OR
*        LV_AUBEL IS INITIAL OR
*        LV_AUPOS IS INITIAL OR
*        LV_KPEIN IS INITIAL OR
*        LV_KMEIN IS INITIAL.
*        GV_ERROR = 'X'.
*        EXIT.
*      ELSE.
**        GV_INPUT = 'X'.
*      ENDIF.
*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_CONDITION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DELETE_CONDITION .
  DATA : LT_ZKONA TYPE TABLE OF ZKONA,
         LS_ZKONA TYPE ZKONA.
  DATA : LT_ZKONA_ITEM TYPE TABLE OF ZKONA_ITEM,
         LS_ZKONA_ITEM TYPE ZKONA_ITEM.
  DATA : LV_ERR,
         LV_ANSWER,
         LV_DATBI TYPE ZKONA-DATBI.
  DATA : LS_OLD TYPE ZKONA.
  DATA : LV_DATE LIKE SY-DATUM.

  PERFORM POPUP_CONFIRM USING '확인'
                     '삭제 하시겠습니까?'
                               LV_ANSWER.
  CHECK LV_ANSWER = 1.

  PERFORM GET_LS_OLD_NEW USING LV_ERR
                               LS_OLD.

  IF LV_ERR = 'X'.
    EXIT.
  ENDIF.

*-01. 조건레코드 삭제처리
  PERFORM PROCESS_VK12_DEL USING LV_ERR LS_OLD-DATAB.

  IF LV_ERR IS INITIAL.
    UPDATE ZKONA SET BOSTA = 'E' WHERE KNUMA = GS_HEADER-KNUMA.
    IF SY-SUBRC EQ 0.
      COMMIT WORK AND WAIT.
      MESSAGE I001 WITH TEXT-S05.
      PERFORM DEQUEUE_KNUMA.
      PERFORM CHANGE_DOC_DELETE.

      LEAVE TO SCREEN 0.
    ELSE.
      ROLLBACK WORK.
      MESSAGE I001 WITH TEXT-E14 DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.
  ELSE.
    MESSAGE I001 WITH TEXT-E42 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPR_CANC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM APPR_CANC .

  DATA : LT_0630 TYPE TABLE OF ZSDT0630,
         LT_0640 TYPE TABLE OF ZSDT0640.
  DATA : LV_ANSWER.

  PERFORM POPUP_CONFIRM USING '확인'
                     '승인요청을 취소 하시겠습니까?'
                               LV_ANSWER.
  CHECK LV_ANSWER = 1.


  UPDATE ZSDT0620 SET LVORM     = 'X',
                      APRV_STAT = 'D',
                      ZNUMC     = @GS_0620-ZNUMC,
                      AEDAT     = @SY-DATUM,
                      AENAM     = @SY-UNAME,
                      AEZET     = @SY-UZEIT
                WHERE ZV4REQNO = @GS_0620-ZV4REQNO.
  IF SY-SUBRC <> 0.
    ROLLBACK WORK.
    MESSAGE I001 WITH TEXT-E19 DISPLAY LIKE 'E'. "삭제처리 실패하였습니다.
    EXIT.
  ENDIF.

  UPDATE ZSDT0630 SET ZAPPRV   = 'N',
                      ZAPRDAT  = @SY-DATUM,
                      ZAPRTIME = @SY-UZEIT
                WHERE ZV4REQNO = @GS_0620-ZV4REQNO
                  AND ZNUMC    = @GS_0620-ZNUMC.
  IF SY-SUBRC = 0.
    UPDATE ZSDT0700 SET ZDELETE = 'X',
                        ZCLOSE  = 'X',
                        ZCHDAT  = @SY-DATUM,
                        ZCHTIM  = @SY-UZEIT
                 WHERE ZV4REQNO = @GS_0620-ZV4REQNO.
    IF SY-SUBRC = 0.
      COMMIT WORK.
      GV_SAVE = 'X'.
      MESSAGE I001 WITH TEXT-S10. "삭제되었습니다.
      PERFORM DEQUEUE_KNUMA. "SRM2402-10021
      PERFORM CALL_SIMPLE_APPROVAL USING GS_0620-ZV4REQNO.
      LEAVE TO SCREEN 0.
    ELSE.
      ROLLBACK WORK.
      MESSAGE I001 WITH TEXT-E19 DISPLAY LIKE 'E'. "삭제처리 실패하였습니다.
    ENDIF.
  ELSE.
    ROLLBACK WORK.
    MESSAGE I001 WITH TEXT-E19 DISPLAY LIKE 'E'. "삭제처리 실패하였습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM APPR .
  DATA : LV_ERR,
         LV_ANSWER.
  DATA : LT_DYNPUPD TYPE DYNPREAD OCCURS 0 WITH HEADER LINE.
  DATA : LV_LONG. "SRM2404-03220
  CLEAR: LV_ERR, LT_DYNPUPD, LT_DYNPUPD[].
  CLEAR GV_SAVE.
  CLEAR: XZKONA, YZKONA. "SRM2402-10021

  PERFORM POPUP_CONFIRM USING '확인'
                     '승인 하시겠습니까?'
                               LV_ANSWER.
  CHECK LV_ANSWER = 1.


  SELECT SINGLE *
     FROM ZSDT0620
    WHERE ZV4REQNO = @GS_0620-ZV4REQNO
     INTO @DATA(LS_0620).

  SELECT COUNT(*)
    INTO @DATA(LV_LINE)
    FROM ZSDT0630
    WHERE ZV4REQNO = @GS_0620-ZV4REQNO
    AND  ZNUMC <> '00'.


  CASE GS_0620-ZNUMC.
    WHEN 1.
*      ls_0620-aprv_1st = sy-uname.
      LS_0620-STAT_1ST = 'C'.

      IF GS_0620-ZNUMC <> LV_LINE.
        LS_0620-PROG_NAM  = GS_0620-APRV_2ST.
        LS_0620-ZNUMC     = '02'.
      ENDIF.
    WHEN 2.
*      ls_0620-aprv_2st = sy-uname.
      LS_0620-STAT_2ST = 'C'.

      IF GS_0620-ZNUMC <> LV_LINE.
        LS_0620-PROG_NAM  = GS_0620-APRV_3ST.
        LS_0620-ZNUMC     = '03'.
      ENDIF.
    WHEN 3.
*      ls_0620-aprv_3st = sy-uname.
      LS_0620-STAT_3ST = 'C'.

      IF GS_0620-ZNUMC <> LV_LINE.
        LS_0620-PROG_NAM  = GS_0620-APRV_4ST.
        LS_0620-ZNUMC     = '04'.
      ENDIF.
    WHEN 4.
*      ls_0620-aprv_4st = sy-uname.
      LS_0620-STAT_4ST = 'C'.

      IF GS_0620-ZNUMC <> LV_LINE.
        LS_0620-PROG_NAM  = SY-UNAME.
        LS_0620-ZNUMC     = '04'.
      ENDIF.
  ENDCASE.

  PERFORM SAVE_LONG_TEXT USING GS_0620-ZNUMC. " SRM2404-03220 첨언 추가



  "최종 승인의 경우 완료 처리
  IF GS_0620-ZNUMC = LV_LINE.
    PERFORM PROCESS_VK11 USING LV_ERR.
*    PERFORM PROCESS_VK12 USING LV_ERR.
    IF LV_ERR = 'X'.
      EXIT.
    ENDIF.
    LS_0620-APRV_STAT = 'C'.
*{ SRM2402-10021 - s
    SELECT SINGLE *
      FROM ZKONA
      INTO XZKONA "변경 전 헤더
     WHERE KNUMA = GS_HEADER-KNUMA.
*} SRM2402-10021 - e
  ENDIF.

  LS_0620-AEDAT = SY-DATUM.
  LS_0620-AENAM = SY-UNAME.
  LS_0620-AEZET = SY-UZEIT.
*{ SRM2404-03220 - s
  CLEAR LV_LONG.
  IF GV_LONG = 'S'.
    LV_LONG = 'X'.
    CASE GS_0620-ZNUMC.
      WHEN '01'.
        LS_0620-OPIN_1ST = 'X'.
      WHEN '02'.
        LS_0620-OPIN_2ST = 'X'.
      WHEN '03'.
        LS_0620-OPIN_3ST = 'X'.
    ENDCASE.
  ENDIF.
*} SRM2404-03220 - e

  MODIFY ZSDT0620 FROM LS_0620.
  IF SY-SUBRC <> 0.
    ROLLBACK WORK.
    MESSAGE I001 WITH TEXT-E17 DISPLAY LIKE 'E'. "승인에 실패했습니다.
    EXIT.
  ENDIF.

  UPDATE ZSDT0630 SET ZAPPRV = 'Y',
                      ZLONGID = @LV_LONG,  "SRM2404-03220
                      ZAPRDAT = @SY-DATUM,
                      ZAPRTIME = @SY-UZEIT WHERE ZV4REQNO = @GS_0620-ZV4REQNO
                                             AND  ZNUMC = @GS_0620-ZNUMC.

  IF SY-SUBRC = 0.
    GV_SAVE = 'X'.
    COMMIT WORK .

    IF GS_0620-ZNUMC <> LV_LINE.
*        MESSAGE s001 DISPLAY LIKE 'S' WITH TEXT-m14.

      MESSAGE I001 WITH TEXT-S08.  "승인되었습니다.
*      IF sy-sysid NE 'S4D'. "개발서버에서는 메일전송 X
*        PERFORM send_mail2.
*      ENDIF.
*<-
*{ ZLSGSD4_23.10.24 - s 외부 호출시 Back 프로그램 종료
*      LEAVE TO SCREEN 0.
      PERFORM DEQUEUE_KNUMA. " SRM2402-10021
      IF GV_EXIT = 'X'.
        PERFORM CALL_SIMPLE_APPROVAL USING GS_0620-ZV4REQNO.
        LEAVE PROGRAM.
      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.
*} ZLSGSD4 - e
    ELSE.
      UPDATE ZSDT0700 SET  ZFINAPR = 'X',
                         ZCLOSE  = 'X',
                         ZCHDAT  = @SY-DATUM,
                         ZCHTIM  = @SY-UZEIT WHERE ZV4REQNO = @GS_0620-ZV4REQNO.
      UPDATE ZKONA SET BOSTA = 'B' WHERE KNUMA = @GS_HEADER-KNUMA.

      IF SY-SUBRC = 0.
        COMMIT WORK.
        MESSAGE I001 WITH TEXT-S08.  "승인되었습니다.
*        MESSAGE s001 DISPLAY LIKE 'S' WITH TEXT-m14.
        PERFORM UPDATE_BOSTA TABLES LT_DYNPUPD.
*-> CCM : 22.11.2023 11:53:05 / ZLSGSD4
        IF SY-SYSID NE 'S4D'. "개발서버에서는 메일전송 X
          PERFORM SEND_MAIL3.
        ENDIF.
*<-
*{ ZLSGSD4_23.10.24 - s 외부 호출시 Back 프로그램 종료
*        LEAVE TO SCREEN 0.
*{ SRM2402-10021 - s LOCK해제 및 변경문서 관리
        SELECT SINGLE *
          FROM ZKONA
          INTO YZKONA "변경 후 헤더
         WHERE KNUMA = GS_HEADER-KNUMA.
        PERFORM DEQUEUE_KNUMA.
        PERFORM SAVE_CHANGE_DOC TABLES YZKONA_ITEM
                                USING 'U'.
        PERFORM CALL_SIMPLE_APPROVAL USING GS_0620-ZV4REQNO.
*} SRM2402-10021 - e
        IF GV_EXIT = 'X'.
          LEAVE PROGRAM.
        ELSE.
          LEAVE TO SCREEN 0.
        ENDIF.
*} ZLSGSD4 - e
      ELSE.
        ROLLBACK WORK.
        MESSAGE I001 WITH TEXT-E17 DISPLAY LIKE 'E'.  "승인에 실패했습니다.
        EXIT.
      ENDIF.
    ENDIF.
  ELSE.
    ROLLBACK WORK.
    MESSAGE I001 WITH TEXT-E17 DISPLAY LIKE 'E'. "승인에 실패했습니다.
  ENDIF.


*  IF SY-SUBRC = 0.
*    GV_SAVE = 'X'.
*    COMMIT WORK.
*    MESSAGE I001 WITH TEXT-S08. "승인되었습니다.
*    IF GS_0620-ZNUMC <> LV_LINE.
*      PERFORM SEND_MAIL2.
*    ENDIF.
*  ELSE.
*    ROLLBACK WORK.
*    MESSAGE I001 WITH TEXT-E17 DISPLAY LIKE 'E'. "승인에 실패했습니다.
*    EXIT.
*  ENDIF.
*
*  IF GS_0620-ZNUMC = LV_LINE.
*    UPDATE ZSDT0700 SET  ZFINAPR = 'X',
*                         ZCLOSE  = 'X',
*                         ZCHDAT  = @SY-DATUM,
*                         ZCHTIM  = @SY-UZEIT WHERE ZV4REQNO = @GS_0620-ZV4REQNO.
*    UPDATE ZKONA SET BOSTA = 'B' WHERE KNUMA = @GS_HEADER-KNUMA.
*
*    IF SY-SUBRC = 0.
*      COMMIT WORK.
*      MESSAGE I001 WITH TEXT-S08.  "승인되었습니다.
*      PERFORM UPDATE_BOSTA TABLES LT_DYNPUPD.
*      PERFORM SEND_MAIL3.
*    ELSE.
*      ROLLBACK WORK.
*      MESSAGE I001 WITH TEXT-E17 DISPLAY LIKE 'E'.  "승인에 실패했습니다.
*    ENDIF.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form REJEC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REJEC .
  DATA LV_ANSWER.
  DATA LV_LONG. "SRM2404-03220
  CLEAR GV_SAVE.

  PERFORM POPUP_CONFIRM USING '확인'
                     '반려 하시겠습니까?'
                               LV_ANSWER.
  CHECK LV_ANSWER = 1.


  SELECT SINGLE *
     FROM ZSDT0620
    WHERE ZV4REQNO = @GS_0620-ZV4REQNO
     INTO @DATA(LS_0620).

  CASE GS_0620-ZNUMC.
    WHEN 1.
*      ls_0620-aprv_1st = sy-uname.
      LS_0620-STAT_1ST = 'B'.
    WHEN 2.
*      ls_0620-aprv_2st = sy-uname.
      LS_0620-STAT_2ST = 'B'.
    WHEN 3.
*      ls_0620-aprv_3st = sy-uname.
      LS_0620-STAT_3ST = 'B'.
    WHEN 4.
*      ls_0620-aprv_4st = sy-uname.
      LS_0620-STAT_4ST = 'B'.
  ENDCASE.

  PERFORM SAVE_LONG_TEXT USING GS_0620-ZNUMC. " SRM2404-03220 첨언 추가

  LS_0620-APRV_STAT = 'R'.
  LS_0620-ZNUMC = GS_0620-ZNUMC.
  LS_0620-AEDAT = SY-DATUM.
  LS_0620-AENAM = SY-UNAME.
  LS_0620-AEZET = SY-UZEIT.
*{ SRM2404-03220 - s
  CLEAR LV_LONG.
  IF GV_LONG = 'S'.
    LV_LONG = 'X'.
    CASE GS_0620-ZNUMC.
      WHEN '01'.
        LS_0620-OPIN_1ST = 'X'.
      WHEN '02'.
        LS_0620-OPIN_2ST = 'X'.
      WHEN '03'.
        LS_0620-OPIN_3ST = 'X'.
    ENDCASE.
  ENDIF.
*} SRM2404-03220 - e

  MODIFY ZSDT0620 FROM LS_0620.
  IF SY-SUBRC <> 0.
    ROLLBACK WORK.
    MESSAGE I001 WITH TEXT-E18 DISPLAY LIKE 'E'. "반려처리 실패하였습니다.
    EXIT.
  ENDIF.

  UPDATE ZSDT0630 SET ZAPPRV   = 'N',
                      ZLONGID  = @LV_LONG, " SRM2404-03220
                      ZAPRDAT  = @SY-DATUM,
                      ZAPRTIME = @SY-UZEIT WHERE ZV4REQNO = @GS_0620-ZV4REQNO
                                             AND  ZNUMC = @GS_0620-ZNUMC.
  IF SY-SUBRC = 0.
    UPDATE ZSDT0700 SET  ZDENY   = 'X',
                         ZCLOSE  = 'X',
                         ZCHDAT  = @SY-DATUM,
                         ZCHTIM  = @SY-UZEIT WHERE ZV4REQNO = @GS_0620-ZV4REQNO.
    IF SY-SUBRC = 0.
      GV_SAVE = 'X'.
*      COMMIT WORK.
      MESSAGE I001 WITH TEXT-S09. "반려되었습니다.
*-> CCM : 22.11.2023 11:53:05 / ZLSGSD4
      IF SY-SYSID NE 'S4D'. "개발서버에서는 메일전송 X
        PERFORM SEND_MAIL4.
      ENDIF.
*<-
*{ ZLSGSD4_23.10.24 - s 외부 호출시 Back 프로그램 종료
*      LEAVE TO SCREEN 0.
      PERFORM DEQUEUE_KNUMA. "SRM2402-10021
      PERFORM CALL_SIMPLE_APPROVAL USING GS_0620-ZV4REQNO.

      IF GV_EXIT = 'X'.
        LEAVE PROGRAM.
      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.
*} ZLSGSD4 - e
    ELSE.
      ROLLBACK WORK.
      MESSAGE I001 WITH TEXT-E18 DISPLAY LIKE 'E'. "반려처리 실패하였습니다.
    ENDIF.
  ELSE.
    ROLLBACK WORK.
    MESSAGE I001 WITH TEXT-E18 DISPLAY LIKE 'E'. "반려처리 실패하였습니다.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_VK11
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_VK11 USING PV_ERR.

  CHECK GT_HIST[] IS NOT INITIAL.

  PERFORM PROCESS_VK11_ZBO1 USING PV_ERR.
  PERFORM PROCESS_VK11_ZBO2 USING PV_ERR.
  PERFORM PROCESS_VK11_ZBO3 USING PV_ERR.
  PERFORM PROCESS_VK11_ZBO4 USING PV_ERR.
  PERFORM PROCESS_VK11_ZBO5 USING PV_ERR.
  PERFORM PROCESS_VK11_ZBO6 USING PV_ERR.
  PERFORM PROCESS_VK11_ZBO7 USING PV_ERR.

  IF PV_ERR = 'X'.
    PERFORM POPUP_TO_DISPLAY_MULTI_TEXT
      USING '확인'
            '조건유형을 저장하는데 실패하였습니다. 재승인 처리 바랍니다.'
            '승인처리가 계속 되지 않을시 ITC에 문의해 주세요.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> GS_HIST_KSCHL
*&---------------------------------------------------------------------*
FORM BDC_INPUT  USING P_PROGRAM P_DYNPRO P_DYNBEGIN P_FNAM P_FVAL.
  CLEAR GT_BDCDATA.
  GT_BDCDATA-PROGRAM  = P_PROGRAM.
  GT_BDCDATA-DYNPRO   = P_DYNPRO.
  GT_BDCDATA-DYNBEGIN = P_DYNBEGIN.
  GT_BDCDATA-FNAM     = P_FNAM.
  GT_BDCDATA-FVAL     = P_FVAL.
  APPEND GT_BDCDATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_CTU_PARAMS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM FILL_CTU_PARAMS  USING P_MODE.
  GS_PARAMS-DISMODE  = P_MODE. "N즉시수행 A단계별 E에러가 존재할때
  GS_PARAMS-UPDMODE  = 'S'.
  GS_PARAMS-RACOMMIT = 'X'.
  GS_PARAMS-DEFSIZE  = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MESSAGE_FUNCTION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_MESSAGE
*&---------------------------------------------------------------------*
FORM MESSAGE_FUNCTION  USING PS_MESSAGE STRUCTURE BDCMSGCOLL
                             P_TEXT.
  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      MSGID               = PS_MESSAGE-MSGID "SY-MSGID
      MSGNR               = PS_MESSAGE-MSGNR "SY-MSGNO
      MSGV1               = PS_MESSAGE-MSGV1 "SY-MSGV1
      MSGV2               = PS_MESSAGE-MSGV2 "SY-MSGV2
      MSGV3               = PS_MESSAGE-MSGV3 "SY-MSGV3
      MSGV4               = PS_MESSAGE-MSGV4 "SY-MSGV4
    IMPORTING
      MESSAGE_TEXT_OUTPUT = P_TEXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_VK12
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_VK12 USING PV_ERR PV_DATAB.

*-> CCM : 04.12.2023 22:38:59 / ZLSGSD4
  CHECK GV_APRV_STAT = 'C' OR GS_HEADER-BOSTA = 'B'.
*<-

  DATA : LV_MESSAGE(220),
         LV_PRICE        TYPE KONV-KBETR,
         LV_KBETR(17).

  LOOP AT GT_HIST INTO DATA(GS_HIST) WHERE STAT_FLAG <> 'X'.

    CLEAR : GT_BDCDATA, GT_BDCDATA[],
            GT_MESSAGE, GT_MESSAGE[],
            LV_MESSAGE.

    PERFORM BDC_INPUT USING :
    'SAPMV13A' '0100' 'X' 'RV13A-KSCHL' GS_HIST-KSCHL,
    '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

    CLEAR : LV_PRICE, LV_KBETR.
    LV_PRICE = ABS( GS_HIST-KBETR ).
    WRITE LV_PRICE TO LV_KBETR CURRENCY GS_HIST-KONWA.
    CONDENSE LV_KBETR NO-GAPS.

    CASE GS_HIST-KSCHL.
      WHEN 'ZBO1'.
        PERFORM BDC_INPUT USING :
        'RV13A921' '1000' 'X' 'F001' GS_HIST-VKORG,
        '        ' '    ' ' ' 'F002' GS_HIST-VTWEG,
        '        ' '    ' ' ' 'F003' GS_HIST-SPART,
        '        ' '    ' ' ' 'F004' GS_HIST-AUSFU,
        '        ' '    ' ' ' 'F005' GS_HIST-KUNNR,
        '        ' '    ' ' ' 'F006-LOW' GS_HIST-MATNR,
        '        ' '    ' ' ' 'SEL_DATE' PV_DATAB,
        '        ' '    ' ' ' 'KODELFL' 'X',
        '        ' '    ' ' ' 'BDC_OKCODE' '=ONLI'.

        IF GS_HIST-DELETE = 'X'.
          PERFORM BDC_INPUT USING :
          'SAPMV13A' '1921' 'X' 'BDC_OKCODE' '=MARL',
          'SAPMV13A' '1921' 'X' 'BDC_OKCODE' '=ENTF'.
        ELSEIF GS_HIST-STAT_FLAG = 'R'.
          PERFORM BDC_INPUT USING :
          'SAPMV13A' '1921' 'X' 'BDC_OKCODE' '=MARL',
          'SAPMV13A' '1921' 'X' 'BDC_OKCODE' '=ENRE'.
        ELSE.
          PERFORM BDC_INPUT USING :
          'SAPMV13A' '1921' 'X' 'KONP-KBETR(01)' LV_KBETR,
          '        ' '    ' ' ' 'RV13A-DATAB(01)' GS_HIST-DATAB,
          '        ' '    ' ' ' 'RV13A-DATBI(01)' GS_HIST-DATBI,
          '        ' '    ' ' ' 'BDC_OKCODE' '/00'.
        ENDIF.

        PERFORM BDC_INPUT USING :
        'SAPMV13A' '1921' 'X' 'BDC_OKCODE' '=SICH'.
      WHEN 'ZBO2'.
        PERFORM BDC_INPUT USING :
        'RV13A922' '1000' 'X' 'F001' GS_HIST-VKORG,
        '        ' '    ' ' ' 'F002' GS_HIST-VTWEG,
        '        ' '    ' ' ' 'F003' GS_HIST-SPART,
        '        ' '    ' ' ' 'F004' GS_HIST-AUSFU,
        '        ' '    ' ' ' 'F005' GS_HIST-KUNNR,
        '        ' '    ' ' ' 'F006-LOW' GS_HIST-PRODH,
        '        ' '    ' ' ' 'SEL_DATE' PV_DATAB,
        '        ' '    ' ' ' 'KODELFL' 'X',
        '        ' '    ' ' ' 'BDC_OKCODE' '=ONLI'.

        IF GS_HIST-DELETE = 'X'.
          PERFORM BDC_INPUT USING :
          'SAPMV13A' '1922' 'X' 'BDC_OKCODE' '=MARL',
          'SAPMV13A' '1922' 'X' 'BDC_OKCODE' '=ENTF'.
        ELSEIF GS_HIST-STAT_FLAG = 'R'.
          PERFORM BDC_INPUT USING :
          'SAPMV13A' '1922' 'X' 'BDC_OKCODE' '=MARL',
          'SAPMV13A' '1922' 'X' 'BDC_OKCODE' '=ENRE'.
        ELSE.
          PERFORM BDC_INPUT USING :
          'SAPMV13A' '1922' 'X' 'KONP-KBETR(01)' LV_KBETR,
          '        ' '    ' ' ' 'RV13A-DATAB(01)' GS_HIST-DATAB,
          '        ' '    ' ' ' 'RV13A-DATBI(01)' GS_HIST-DATBI,
          '        ' '    ' ' ' 'BDC_OKCODE' '/00'.
        ENDIF.

        PERFORM BDC_INPUT USING :
        'SAPMV13A' '1922' 'X' 'BDC_OKCODE' '=SICH'.
      WHEN 'ZBO3'.
        PERFORM BDC_INPUT USING :
        'RV13A923' '1000' 'X' 'F001' GS_HIST-VKORG,
        '        ' '    ' ' ' 'F002' GS_HIST-VTWEG,
        '        ' '    ' ' ' 'F003' GS_HIST-SPART,
        '        ' '    ' ' ' 'F004' GS_HIST-AUSFU,
        '        ' '    ' ' ' 'F005' GS_HIST-KUNNR,
        '        ' '    ' ' ' 'F006' GS_HIST-MATNR,
        '        ' '    ' ' ' 'F007-LOW' GS_HIST-INCO1,
        '        ' '    ' ' ' 'SEL_DATE' PV_DATAB,
        '        ' '    ' ' ' 'KODELFL' 'X',
        '        ' '    ' ' ' 'BDC_OKCODE' '=ONLI'.

        IF GS_HIST-DELETE = 'X'.
          PERFORM BDC_INPUT USING :
          'SAPMV13A' '1923' 'X' 'BDC_OKCODE' '=MARL',
          'SAPMV13A' '1923' 'X' 'BDC_OKCODE' '=ENTF'.
        ELSEIF GS_HIST-STAT_FLAG = 'R'.
          PERFORM BDC_INPUT USING :
          'SAPMV13A' '1923' 'X' 'BDC_OKCODE' '=MARL',
          'SAPMV13A' '1923' 'X' 'BDC_OKCODE' '=ENRE'.
        ELSE.
          PERFORM BDC_INPUT USING :
          'SAPMV13A' '1923' 'X' 'KONP-KBETR(01)' LV_KBETR,
          '        ' '    ' ' ' 'RV13A-DATAB(01)' GS_HIST-DATAB,
          '        ' '    ' ' ' 'RV13A-DATBI(01)' GS_HIST-DATBI,
          '        ' '    ' ' ' 'BDC_OKCODE' '/00'.
        ENDIF.

        PERFORM BDC_INPUT USING :
        'SAPMV13A' '1923' 'X' 'BDC_OKCODE' '=SICH'.
      WHEN 'ZBO4'.
        PERFORM BDC_INPUT USING :
        'RV13A924' '1000' 'X' 'F001' GS_HIST-VKORG,
        '        ' '    ' ' ' 'F002' GS_HIST-VTWEG,
        '        ' '    ' ' ' 'F003' GS_HIST-SPART,
        '        ' '    ' ' ' 'F004' GS_HIST-AUSFU,
        '        ' '    ' ' ' 'F005' GS_HIST-KUNNR,
        '        ' '    ' ' ' 'F006' GS_HIST-PRODH,
        '        ' '    ' ' ' 'F007-LOW' GS_HIST-INCO1,
        '        ' '    ' ' ' 'SEL_DATE' PV_DATAB,
        '        ' '    ' ' ' 'KODELFL' 'X',
        '        ' '    ' ' ' 'BDC_OKCODE' '=ONLI'.

        IF GS_HIST-DELETE = 'X'.
          PERFORM BDC_INPUT USING :
          'SAPMV13A' '1924' 'X' 'BDC_OKCODE' '=MARL',
          'SAPMV13A' '1924' 'X' 'BDC_OKCODE' '=ENTF'.
        ELSEIF GS_HIST-STAT_FLAG = 'R'.
          PERFORM BDC_INPUT USING :
          'SAPMV13A' '1924' 'X' 'BDC_OKCODE' '=MARL',
          'SAPMV13A' '1924' 'X' 'BDC_OKCODE' '=ENRE'.
        ELSE.
          PERFORM BDC_INPUT USING :
          'SAPMV13A' '1924' 'X' 'KONP-KBETR(01)' LV_KBETR,
          '        ' '    ' ' ' 'RV13A-DATAB(01)' GS_HIST-DATAB,
          '        ' '    ' ' ' 'RV13A-DATBI(01)' GS_HIST-DATBI,
          '        ' '    ' ' ' 'BDC_OKCODE' '/00'.
        ENDIF.

        PERFORM BDC_INPUT USING :
        'SAPMV13A' '1924' 'X' 'BDC_OKCODE' '=SICH'.
      WHEN 'ZBO5'.
        PERFORM BDC_INPUT USING :
        'RV13A925' '1000' 'X' 'F001' GS_HIST-VKORG,
        '        ' '    ' ' ' 'F002' GS_HIST-VTWEG,
        '        ' '    ' ' ' 'F003' GS_HIST-SPART,
        '        ' '    ' ' ' 'F004' GS_HIST-AUSFU,
        '        ' '    ' ' ' 'F005' GS_HIST-KUNNR,
        '        ' '    ' ' ' 'F006-LOW' GS_HIST-INCO1,
        '        ' '    ' ' ' 'SEL_DATE' PV_DATAB,
        '        ' '    ' ' ' 'KODELFL' 'X',
        '        ' '    ' ' ' 'BDC_OKCODE' '=ONLI'.

        IF GS_HIST-DELETE = 'X'.
          PERFORM BDC_INPUT USING :
          'SAPMV13A' '1925' 'X' 'BDC_OKCODE' '=MARL',
          'SAPMV13A' '1925' 'X' 'BDC_OKCODE' '=ENTF'.
        ELSEIF GS_HIST-STAT_FLAG = 'R'.
          PERFORM BDC_INPUT USING :
          'SAPMV13A' '1925' 'X' 'BDC_OKCODE' '=MARL',
          'SAPMV13A' '1925' 'X' 'BDC_OKCODE' '=ENRE'.
        ELSE.
          PERFORM BDC_INPUT USING :
          'SAPMV13A' '1925' 'X' 'KONP-KBETR(01)' LV_KBETR,
          '        ' '    ' ' ' 'RV13A-DATAB(01)' GS_HIST-DATAB,
          '        ' '    ' ' ' 'RV13A-DATBI(01)' GS_HIST-DATBI,
          '        ' '    ' ' ' 'BDC_OKCODE' '/00'.
        ENDIF.

        PERFORM BDC_INPUT USING :
        'SAPMV13A' '1925' 'X' 'BDC_OKCODE' '=SICH'.
      WHEN 'ZBO6'.
        PERFORM BDC_INPUT USING :
        'RV13A927' '1000' 'X' 'F001' GS_HIST-VKORG,
        '        ' '    ' ' ' 'F002' GS_HIST-VTWEG,
        '        ' '    ' ' ' 'F003' GS_HIST-SPART,
        '        ' '    ' ' ' 'F004' GS_HIST-AUSFU,
        '        ' '    ' ' ' 'F005' GS_HIST-AUBEL,
        '        ' '    ' ' ' 'F006-LOW' GS_HIST-AUPOS,
        '        ' '    ' ' ' 'SEL_DATE' PV_DATAB,
        '        ' '    ' ' ' 'KODELFL' 'X',
        '        ' '    ' ' ' 'BDC_OKCODE' '=ONLI'.

        IF GS_HIST-DELETE = 'X'.
          PERFORM BDC_INPUT USING :
          'SAPMV13A' '1927' 'X' 'BDC_OKCODE' '=MARL',
          'SAPMV13A' '1927' 'X' 'BDC_OKCODE' '=ENTF'.
        ELSEIF GS_HIST-STAT_FLAG = 'R'.
          PERFORM BDC_INPUT USING :
          'SAPMV13A' '1927' 'X' 'BDC_OKCODE' '=MARL',
          'SAPMV13A' '1927' 'X' 'BDC_OKCODE' '=ENRE'.
        ELSE.
          PERFORM BDC_INPUT USING :
          'SAPMV13A' '1927' 'X' 'KONP-KBETR(01)' LV_KBETR,
          '        ' '    ' ' ' 'RV13A-DATAB(01)' GS_HIST-DATAB,
          '        ' '    ' ' ' 'RV13A-DATBI(01)' GS_HIST-DATBI,
          '        ' '    ' ' ' 'BDC_OKCODE' '/00'.
        ENDIF.

        PERFORM BDC_INPUT USING :
        'SAPMV13A' '1927' 'X' 'BDC_OKCODE' '=SICH'.
      WHEN 'ZBO7'.
        PERFORM BDC_INPUT USING :
        'RV13A927' '1000' 'X' 'F001' GS_HIST-VKORG,
        '        ' '    ' ' ' 'F002' GS_HIST-VTWEG,
        '        ' '    ' ' ' 'F003' GS_HIST-SPART,
        '        ' '    ' ' ' 'F004' GS_HIST-AUSFU,
        '        ' '    ' ' ' 'F005' GS_HIST-AUBEL,
        '        ' '    ' ' ' 'F006-LOW' GS_HIST-AUPOS,
        '        ' '    ' ' ' 'SEL_DATE' PV_DATAB,
        '        ' '    ' ' ' 'KODELFL' 'X',
        '        ' '    ' ' ' 'BDC_OKCODE' '=ONLI'.

        IF GS_HIST-DELETE = 'X'.
          PERFORM BDC_INPUT USING :
          'SAPMV13A' '1927' 'X' 'BDC_OKCODE' '=MARL',
          'SAPMV13A' '1927' 'X' 'BDC_OKCODE' '=ENTF'.
        ELSEIF GS_HIST-STAT_FLAG = 'R'.
          PERFORM BDC_INPUT USING :
          'SAPMV13A' '1927' 'X' 'BDC_OKCODE' '=MARL',
          'SAPMV13A' '1927' 'X' 'BDC_OKCODE' '=ENRE'.
        ELSE.
          PERFORM BDC_INPUT USING :
          'SAPMV13A' '1927' 'X' 'KONP-KBETR(01)' LV_KBETR,
          '        ' '    ' ' ' 'RV13A-DATAB(01)' GS_HIST-DATAB,
          '        ' '    ' ' ' 'RV13A-DATBI(01)' GS_HIST-DATBI,
          '        ' '    ' ' ' 'BDC_OKCODE' '/00'.
        ENDIF.

        PERFORM BDC_INPUT USING :
        'SAPMV13A' '1927' 'X' 'BDC_OKCODE' '=SICH'.
    ENDCASE.

    PERFORM FILL_CTU_PARAMS USING 'N'.

    CALL TRANSACTION 'VK12' USING GT_BDCDATA
                            OPTIONS FROM GS_PARAMS
                            MESSAGES INTO GT_MESSAGE.

    PERFORM MESSAGE_FUNCTION USING GT_MESSAGE LV_MESSAGE.

    READ TABLE GT_MESSAGE WITH KEY MSGTYP = 'E'.

    IF SY-SUBRC = 0.

      PERFORM UPDATE_MESSAGE USING PV_ERR LV_MESSAGE GS_HIST.

    ELSE.

      READ TABLE GT_MESSAGE INDEX 1.
      IF SY-SUBRC = 0.
        PERFORM MESSAGE_FUNCTION USING GT_MESSAGE LV_MESSAGE.

        PERFORM UPDATE_ZKONA_ITEM USING PV_ERR LV_MESSAGE
                                        'B'    GS_HIST.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF PV_ERR = 'X'.
    MESSAGE I001 DISPLAY LIKE 'E' WITH LV_MESSAGE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_VK11_ZBO1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_ERR
*&---------------------------------------------------------------------*
FORM PROCESS_VK11_ZBO1  USING    PV_ERR.

  DATA : LV_MESSAGE(220),
         LV_PRICE        TYPE KONV-KBETR,
         LV_KBETR(17),
         LV_KPEIN(17),
         LV_CNT          TYPE I.

  DATA : LT_HIST LIKE TABLE OF GS_ITAB.
  DATA : LS_HIST LIKE GS_ITAB.

  CLEAR: LT_HIST, LS_HIST.

  LOOP AT GT_HIST INTO DATA(GS_HIST) WHERE KSCHL = 'ZBO1'
                                       AND STAT_FLAG = 'X'.

    CLEAR LS_HIST.
    MOVE-CORRESPONDING GS_HIST TO LS_HIST.
    APPEND LS_HIST TO LT_HIST.

  ENDLOOP.

  LOOP AT LT_HIST INTO LS_HIST GROUP BY LS_HIST-KUNNR.

    CLEAR : GT_BDCDATA, GT_BDCDATA[],
            GT_MESSAGE, GT_MESSAGE[],
            LV_MESSAGE, LV_CNT.

    PERFORM BDC_INPUT USING :
    'SAPMV13A' '0100' 'X' 'RV13A-KSCHL' LS_HIST-KSCHL,
    '        ' '    ' ' ' 'BDC_OKCODE' '/00',

    'SAPMV13A' '1921' 'X' 'KOMG-VKORG' LS_HIST-VKORG,
    '        ' '    ' ' ' 'KOMG-VTWEG' LS_HIST-VTWEG,
    '        ' '    ' ' ' 'KOMG-SPART' LS_HIST-SPART,
    '        ' '    ' ' ' 'KOMG-AUSFU' LS_HIST-AUSFU,
    '        ' '    ' ' ' 'KOMG-KUNNR' LS_HIST-KUNNR,
    '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

    LOOP AT GROUP LS_HIST INTO DATA(LS_DATA).

      LV_CNT = LV_CNT + 1.

      CLEAR : LV_PRICE, LV_KBETR, LV_KPEIN.
      LV_PRICE = ABS( LS_DATA-KBETR ).
      WRITE LV_PRICE TO LV_KBETR CURRENCY LS_DATA-KONWA.
      CONDENSE LV_KBETR NO-GAPS.
      LV_KPEIN = LS_DATA-KPEIN.
      CONDENSE LV_KPEIN NO-GAPS.

      PERFORM BDC_INPUT USING :
      'SAPMV13A' '1921' 'X' 'KOMG-MATNR(02)'  LS_DATA-MATNR,
      '        ' '    ' ' ' 'KONP-KBETR(02)'  LV_KBETR,
      '        ' '    ' ' ' 'KONP-KONWA(02)'  LS_DATA-KONWA,
      '        ' '    ' ' ' 'KONP-KPEIN(02)'  LV_KPEIN,
      '        ' '    ' ' ' 'KONP-KMEIN(02)'  LS_DATA-KMEIN,
      '        ' '    ' ' ' 'RV13A-DATAB(02)' LS_DATA-DATAB,
      '        ' '    ' ' ' 'RV13A-DATBI(02)' LS_DATA-DATBI,
      '        ' '    ' ' ' 'BDC_OKCODE'      '/00'.

      PERFORM BDC_INPUT USING :
      'SAPMV13A' '1921' 'X' 'BDC_OKCODE' '=SUCH'.

      PERFORM BDC_INPUT USING :
     'SAPLSSEL' '1104' 'X' '%%DYN007-LOW' LS_DATA-MATNR,
     '        ' '    ' ' ' 'BDC_OKCODE'   '=CRET'.

      PERFORM BDC_INPUT USING :
      'SAPMV13A' '1921' 'X' 'BDC_OKCODE' '=KDAT'.

      PERFORM BDC_INPUT USING :
     'SAPMV13A' '0200' 'X' 'RV13A-DATAB' LS_HIST-DATAB,
     '        ' '    ' ' ' 'RV13A-DATBI' LS_HIST-DATBI,
     '        ' '    ' ' ' 'KONH-KOSRT'  GS_HEADER-KNUMA, "계약번호
     '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

      PERFORM BDC_INPUT USING :
      'SAPMV13A' '0200' 'X' 'BDC_OKCODE' '=BACK'.

    ENDLOOP.

    IF GV_APRV_STAT = 'C' AND LV_CNT = 0.
      CONTINUE.
    ENDIF.

    PERFORM BDC_INPUT USING :
    'SAPMV13A' '1921' 'X' 'BDC_OKCODE' '=SICH'.

    PERFORM FILL_CTU_PARAMS USING 'N'.
    CALL TRANSACTION 'VK11' USING GT_BDCDATA
                            OPTIONS FROM GS_PARAMS
                            MESSAGES INTO GT_MESSAGE.

    PERFORM MESSAGE_FUNCTION USING GT_MESSAGE LV_MESSAGE.

    READ TABLE GT_MESSAGE WITH KEY MSGTYP = 'E'.

    IF SY-SUBRC = 0.

      PV_ERR = 'X'.
      LS_HIST-MESSAGE = LV_MESSAGE.

      MODIFY GT_HIST FROM LS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                    AND KUNNR = LS_HIST-KUNNR.

      MODIFY GT_ITAB FROM LS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                    AND KUNNR = LS_HIST-KUNNR.

      EXIT.

    ELSE.

      READ TABLE GT_MESSAGE INDEX 1.

      IF SY-SUBRC = 0.
        PERFORM MESSAGE_FUNCTION USING GT_MESSAGE LV_MESSAGE.
      ENDIF.

      LS_HIST-MESSAGE = LV_MESSAGE.

      MODIFY GT_HIST FROM LS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                    AND KUNNR = LS_HIST-KUNNR.

      MODIFY GT_ITAB FROM LS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                    AND KUNNR = LS_HIST-KUNNR.

      UPDATE ZKONA_ITEM SET STAT_FLAG = 'B' WHERE KNUMA = GV_KNUMA
                                              AND KSCHL = LS_HIST-KSCHL
                                              AND KUNNR = LS_HIST-KUNNR.

      IF SY-SUBRC = 0.
        COMMIT WORK.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form POPUP_TO_DISPLAY_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM POPUP_TO_DISPLAY_MULTI_TEXT  USING PV_TITLE
                                        PV_TEXT1
                                        PV_TEXT2.

  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      TITEL        = PV_TITLE
      TEXTLINE1    = PV_TEXT1
      TEXTLINE2    = PV_TEXT2
      START_COLUMN = 25
      START_ROW    = 6.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_VK11_ZBO2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_ERR
*&---------------------------------------------------------------------*
FORM PROCESS_VK11_ZBO2  USING    PV_ERR.
  DATA : LV_MESSAGE(220),
         LV_PRICE        TYPE KONV-KBETR,
         LV_KBETR(17),
         LV_KPEIN(17),
         LV_CNT          TYPE I.

  DATA : LT_HIST LIKE TABLE OF GS_ITAB.
  DATA : LS_HIST LIKE GS_ITAB.
  CLEAR: LT_HIST, LS_HIST.
  LOOP AT GT_HIST INTO DATA(GS_HIST) WHERE KSCHL = 'ZBO2'
                                       AND STAT_FLAG = 'X'.
    CLEAR LS_HIST.
    MOVE-CORRESPONDING GS_HIST TO LS_HIST.
    APPEND LS_HIST TO LT_HIST.
  ENDLOOP.

  LOOP AT LT_HIST INTO LS_HIST GROUP BY LS_HIST-KUNNR.
    CLEAR : GT_BDCDATA, GT_BDCDATA[], GT_MESSAGE, GT_MESSAGE[],
            LV_MESSAGE, LV_CNT.

    PERFORM BDC_INPUT USING :
    'SAPMV13A' '0100' 'X' 'RV13A-KSCHL' LS_HIST-KSCHL,
    '        ' '    ' ' ' 'BDC_OKCODE' '/00',

    'SAPMV13A' '1922' 'X' 'KOMG-VKORG' LS_HIST-VKORG,
    '        ' '    ' ' ' 'KOMG-VTWEG' LS_HIST-VTWEG,
    '        ' '    ' ' ' 'KOMG-SPART' LS_HIST-SPART,
    '        ' '    ' ' ' 'KOMG-AUSFU' LS_HIST-AUSFU,
    '        ' '    ' ' ' 'KOMG-KUNNR' LS_HIST-KUNNR,
    '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

    LOOP AT GROUP LS_HIST INTO DATA(LS_DATA).

      LV_CNT = LV_CNT + 1.

      CLEAR : LV_PRICE, LV_KBETR, LV_KPEIN.
      LV_PRICE = ABS( LS_DATA-KBETR ).
      WRITE LV_PRICE TO LV_KBETR CURRENCY LS_DATA-KONWA.
      CONDENSE LV_KBETR NO-GAPS.
      LV_KPEIN = LS_DATA-KPEIN.
      CONDENSE LV_KPEIN NO-GAPS.

      PERFORM BDC_INPUT USING :
      'SAPMV13A' '1922' 'X' 'KOMG-PRODH(02)' LS_DATA-PRODH,
      '        ' '    ' ' ' 'KONP-KBETR(02)' LV_KBETR,
      '        ' '    ' ' ' 'KONP-KONWA(02)' LS_DATA-KONWA,
      '        ' '    ' ' ' 'KONP-KPEIN(02)' LV_KPEIN,
      '        ' '    ' ' ' 'KONP-KMEIN(02)' LS_DATA-KMEIN,
      '        ' '    ' ' ' 'RV13A-DATAB(02)' LS_DATA-DATAB,
      '        ' '    ' ' ' 'RV13A-DATBI(02)' LS_DATA-DATBI,
      '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

      PERFORM BDC_INPUT USING :
      'SAPMV13A' '1922' 'X' 'BDC_OKCODE' '=SUCH'.

      PERFORM BDC_INPUT USING :
     'SAPLSSEL' '1104' 'X' '%%DYN007-LOW' LS_DATA-PRODH,
     '        ' '    ' ' ' 'BDC_OKCODE' '=CRET'.

      PERFORM BDC_INPUT USING :
    'SAPMV13A' '1922' 'X' 'BDC_OKCODE' '=KDAT'.

      PERFORM BDC_INPUT USING :
     'SAPMV13A' '0200' 'X' 'RV13A-DATAB' LS_HIST-DATAB,
     '        ' '    ' ' ' 'RV13A-DATBI' LS_HIST-DATBI,
     '        ' '    ' ' ' 'KONH-KOSRT'  GS_HEADER-KNUMA, "계약번호
     '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

      PERFORM BDC_INPUT USING :
     'SAPMV13A' '0200' 'X' 'BDC_OKCODE' '=BACK'.

    ENDLOOP.

    IF GV_APRV_STAT = 'C' AND LV_CNT = 0.
      CONTINUE.
    ENDIF.

    PERFORM BDC_INPUT USING :
   'SAPMV13A' '1922' 'X' 'BDC_OKCODE' '=SICH'.

    PERFORM FILL_CTU_PARAMS USING 'N'.
    CALL TRANSACTION 'VK11' USING GT_BDCDATA
                            OPTIONS FROM GS_PARAMS
                            MESSAGES INTO GT_MESSAGE.

    PERFORM MESSAGE_FUNCTION USING GT_MESSAGE LV_MESSAGE.

    READ TABLE GT_MESSAGE WITH KEY MSGTYP = 'E'.

    IF SY-SUBRC = 0.

      PV_ERR = 'X'.
      LS_HIST-MESSAGE = LV_MESSAGE.

      MODIFY GT_HIST FROM LS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                    AND KUNNR = LS_HIST-KUNNR.

      MODIFY GT_ITAB FROM LS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                    AND KUNNR = LS_HIST-KUNNR.

      EXIT.

    ELSE.

      READ TABLE GT_MESSAGE INDEX 1.

      IF SY-SUBRC = 0.
        PERFORM MESSAGE_FUNCTION USING GT_MESSAGE LV_MESSAGE.
      ENDIF.

      LS_HIST-MESSAGE = LV_MESSAGE.

      MODIFY GT_HIST FROM LS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                    AND KUNNR = LS_HIST-KUNNR.

      MODIFY GT_ITAB FROM LS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                    AND KUNNR = LS_HIST-KUNNR.

      UPDATE ZKONA_ITEM SET STAT_FLAG = 'B' WHERE KNUMA = GV_KNUMA
                                              AND KSCHL = LS_HIST-KSCHL
                                              AND KUNNR = LS_HIST-KUNNR.
      IF SY-SUBRC = 0.
        COMMIT WORK.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_VK11_ZBO3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_ERR
*&---------------------------------------------------------------------*
FORM PROCESS_VK11_ZBO3  USING PV_ERR.

  DATA : LV_MESSAGE(220),
         LV_PRICE        TYPE KONV-KBETR,
         LV_KBETR(17),
         LV_KPEIN(17),
         LV_CNT          TYPE I.

  DATA : LT_HIST LIKE TABLE OF GS_ITAB.
  DATA : LS_HIST LIKE GS_ITAB.

  CLEAR: LT_HIST, LS_HIST.

  LOOP AT GT_HIST INTO DATA(GS_HIST) WHERE KSCHL = 'ZBO3'
                                       AND STAT_FLAG = 'X'.

    CLEAR LS_HIST.
    MOVE-CORRESPONDING GS_HIST TO LS_HIST.
    APPEND LS_HIST TO LT_HIST.

  ENDLOOP.

  LOOP AT LT_HIST INTO LS_HIST GROUP BY ( KUNNR = LS_HIST-KUNNR MATNR = LS_HIST-MATNR ).

    CLEAR : GT_BDCDATA, GT_BDCDATA[],
            GT_MESSAGE, GT_MESSAGE[],
            LV_MESSAGE, LV_CNT.

    PERFORM BDC_INPUT USING :
    'SAPMV13A' '0100' 'X' 'RV13A-KSCHL' LS_HIST-KSCHL,
    '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

    PERFORM BDC_INPUT USING :
    'SAPMV13A' '1923' 'X' 'KOMG-VKORG' LS_HIST-VKORG,
    '        ' '    ' ' ' 'KOMG-VTWEG' LS_HIST-VTWEG,
    '        ' '    ' ' ' 'KOMG-SPART' LS_HIST-SPART,
    '        ' '    ' ' ' 'KOMG-AUSFU' LS_HIST-AUSFU,
    '        ' '    ' ' ' 'KOMG-KUNNR' LS_HIST-KUNNR,
    '        ' '    ' ' ' 'KOMG-MATNR' LS_HIST-MATNR,
    '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

    LOOP AT GROUP LS_HIST INTO DATA(LS_DATA).

      LV_CNT = LV_CNT + 1.

      CLEAR : LV_PRICE, LV_KBETR, LV_KPEIN.
      LV_PRICE = ABS( LS_DATA-KBETR ).
      WRITE LV_PRICE TO LV_KBETR CURRENCY LS_DATA-KONWA.
      CONDENSE LV_KBETR NO-GAPS.
      LV_KPEIN = LS_DATA-KPEIN.
      CONDENSE LV_KPEIN NO-GAPS.

      PERFORM BDC_INPUT USING :
      'SAPMV13A' '1923' 'X' 'KOMG-INCO1(02)' LS_DATA-INCO1,
      '        ' '    ' ' ' 'KONP-KBETR(02)' LV_KBETR,
      '        ' '    ' ' ' 'KONP-KONWA(02)' LS_DATA-KONWA,
      '        ' '    ' ' ' 'RV13A-DATAB(02)' LS_DATA-DATAB,
      '        ' '    ' ' ' 'RV13A-DATBI(02)' LS_DATA-DATBI,
      '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

      PERFORM BDC_INPUT USING :
      'SAPMV13A' '1923' 'X' 'BDC_OKCODE' '=SUCH'.

      PERFORM BDC_INPUT USING :
     'SAPLSSEL' '1104' 'X' '%%DYN008-LOW' LS_DATA-INCO1,
     '        ' '    ' ' ' 'BDC_OKCODE' '=CRET'.

      PERFORM BDC_INPUT USING :
   'SAPMV13A' '1923' 'X' 'BDC_OKCODE' '=KDAT'.

      PERFORM BDC_INPUT USING :
   'SAPMV13A' '0200' 'X' 'RV13A-DATAB' LS_HIST-DATAB,
   '        ' '    ' ' ' 'RV13A-DATBI' LS_HIST-DATBI,
   '        ' '    ' ' ' 'KONH-KOSRT'  GS_HEADER-KNUMA, "계약번호
   '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

      PERFORM BDC_INPUT USING :
      'SAPMV13A' '0200' 'X' 'BDC_OKCODE' '=BACK'.

    ENDLOOP.

    IF GV_APRV_STAT = 'C' AND LV_CNT = 0.
      CONTINUE.
    ENDIF.

    PERFORM BDC_INPUT USING :
    'SAPMV13A' '1923' 'X' 'BDC_OKCODE' '=SICH'.

    PERFORM FILL_CTU_PARAMS USING 'N'.
    CALL TRANSACTION 'VK11' USING GT_BDCDATA
                            OPTIONS FROM GS_PARAMS
                            MESSAGES INTO GT_MESSAGE.

    PERFORM MESSAGE_FUNCTION USING GT_MESSAGE LV_MESSAGE.

    READ TABLE GT_MESSAGE WITH KEY MSGTYP = 'E'.

    IF SY-SUBRC = 0.

      PV_ERR = 'X'.
      LS_HIST-MESSAGE = LV_MESSAGE.
      MODIFY GT_HIST FROM LS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                    AND KUNNR = LS_HIST-KUNNR
                                    AND MATNR = LS_HIST-MATNR.

      MODIFY GT_ITAB FROM LS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                    AND KUNNR = LS_HIST-KUNNR
                                    AND MATNR = LS_HIST-MATNR.

      EXIT.

    ELSE.

      READ TABLE GT_MESSAGE INDEX 1.
      IF SY-SUBRC = 0.
        PERFORM MESSAGE_FUNCTION USING GT_MESSAGE LV_MESSAGE.
      ENDIF.

      LS_HIST-MESSAGE = LV_MESSAGE.
      MODIFY GT_HIST FROM LS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                    AND KUNNR = LS_HIST-KUNNR
                                    AND MATNR = LS_HIST-MATNR.

      MODIFY GT_ITAB FROM LS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                    AND KUNNR = LS_HIST-KUNNR
                                    AND MATNR = LS_HIST-MATNR.

      UPDATE ZKONA_ITEM SET STAT_FLAG = 'B' WHERE KNUMA = GV_KNUMA
                                              AND KSCHL = LS_HIST-KSCHL
                                              AND KUNNR = LS_HIST-KUNNR
                                              AND MATNR = LS_HIST-MATNR.
      IF SY-SUBRC = 0.
        COMMIT WORK.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_VK11_ZBO4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_ERR
*&---------------------------------------------------------------------*
FORM PROCESS_VK11_ZBO4  USING    PV_ERR.
  DATA : LV_MESSAGE(220),
         LV_PRICE        TYPE KONV-KBETR,
         LV_KBETR(17),
         LV_KPEIN(17),
         LV_CNT          TYPE I.

  DATA : LT_HIST LIKE TABLE OF GS_ITAB.
  DATA : LS_HIST LIKE GS_ITAB.

  CLEAR: LT_HIST, LS_HIST.

  LOOP AT GT_HIST INTO DATA(GS_HIST) WHERE KSCHL = 'ZBO4'
                                       AND STAT_FLAG = 'X'.

    CLEAR LS_HIST.
    MOVE-CORRESPONDING GS_HIST TO LS_HIST.
    APPEND LS_HIST TO LT_HIST.

  ENDLOOP.


  LOOP AT LT_HIST INTO LS_HIST GROUP BY ( KUNNR = LS_HIST-KSCHL PRODH = LS_HIST-PRODH ).
    CLEAR : GT_BDCDATA, GT_BDCDATA[],
            GT_MESSAGE, GT_MESSAGE[],
            LV_MESSAGE, LV_CNT.

    PERFORM BDC_INPUT USING :
    'SAPMV13A' '0100' 'X' 'RV13A-KSCHL' LS_HIST-KSCHL,
    '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

    PERFORM BDC_INPUT USING :
    'SAPMV13A' '1924' 'X' 'KOMG-VKORG' LS_HIST-VKORG,
    '        ' '    ' ' ' 'KOMG-VTWEG' LS_HIST-VTWEG,
    '        ' '    ' ' ' 'KOMG-SPART' LS_HIST-SPART,
    '        ' '    ' ' ' 'KOMG-AUSFU' LS_HIST-AUSFU,
    '        ' '    ' ' ' 'KOMG-KUNNR' LS_HIST-KUNNR,
    '        ' '    ' ' ' 'KOMG-PRODH' LS_HIST-PRODH,
    '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

    LOOP AT GROUP LS_HIST INTO DATA(LS_DATA).

      LV_CNT = LV_CNT + 1.

      CLEAR : LV_PRICE, LV_KBETR, LV_KPEIN.
      LV_PRICE = ABS( LS_DATA-KBETR ).
      WRITE LV_PRICE TO LV_KBETR CURRENCY LS_DATA-KONWA.
      CONDENSE LV_KBETR NO-GAPS.
      LV_KPEIN = LS_DATA-KPEIN.
      CONDENSE LV_KPEIN NO-GAPS.

      PERFORM BDC_INPUT USING :
      'SAPMV13A' '1924' 'X' 'KOMG-INCO1(02)' LS_DATA-INCO1,
      '        ' '    ' ' ' 'KONP-KBETR(02)' LV_KBETR,
      '        ' '    ' ' ' 'KONP-KONWA(02)' LS_DATA-KONWA,
      '        ' '    ' ' ' 'RV13A-DATAB(02)' LS_DATA-DATAB,
      '        ' '    ' ' ' 'RV13A-DATBI(02)' LS_DATA-DATBI,
      '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

      PERFORM BDC_INPUT USING :
      'SAPMV13A' '1924' 'X' 'BDC_OKCODE' '=SUCH'.

      PERFORM BDC_INPUT USING :
     'SAPLSSEL' '1104' 'X' '%%DYN008-LOW' LS_DATA-INCO1,
     '        ' '    ' ' ' 'BDC_OKCODE' '=CRET'.

      PERFORM BDC_INPUT USING :
    'SAPMV13A' '1924' 'X' 'BDC_OKCODE' '=KDAT'.

      PERFORM BDC_INPUT USING :
    'SAPMV13A' '0200' 'X' 'RV13A-DATAB' LS_HIST-DATAB,
    '        ' '    ' ' ' 'RV13A-DATBI' LS_HIST-DATBI,
    '        ' '    ' ' ' 'KONH-KOSRT'  GS_HEADER-KNUMA, "계약번호
    '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

      PERFORM BDC_INPUT USING :
     'SAPMV13A' '0200' 'X' 'BDC_OKCODE' '=BACK'.

    ENDLOOP.

    IF GV_APRV_STAT = 'C' AND LV_CNT = 0.
      CONTINUE.
    ENDIF.

    PERFORM BDC_INPUT USING :
       'SAPMV13A' '1924' 'X' 'BDC_OKCODE' '=SICH'.

    PERFORM FILL_CTU_PARAMS USING 'N'.
    CALL TRANSACTION 'VK11' USING GT_BDCDATA
                            OPTIONS FROM GS_PARAMS
                            MESSAGES INTO GT_MESSAGE.

    PERFORM MESSAGE_FUNCTION USING GT_MESSAGE LV_MESSAGE.
    READ TABLE GT_MESSAGE WITH KEY MSGTYP = 'E'.
    IF SY-SUBRC = 0.
*      MESSAGE S001 DISPLAY LIKE 'E' WITH LV_MESSAGE.
      PV_ERR = 'X'.
      LS_HIST-MESSAGE = LV_MESSAGE.
      MODIFY GT_HIST FROM LS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                    AND KUNNR = LS_HIST-KUNNR
                                    AND PRODH = LS_HIST-PRODH.

      MODIFY GT_ITAB FROM LS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                    AND KUNNR = LS_HIST-KUNNR
                                    AND PRODH = LS_HIST-PRODH.

      EXIT.

    ELSE.

      READ TABLE GT_MESSAGE INDEX 1.

      IF SY-SUBRC = 0.
        PERFORM MESSAGE_FUNCTION USING GT_MESSAGE LV_MESSAGE.
      ENDIF.

      LS_HIST-MESSAGE = LV_MESSAGE.

      MODIFY GT_HIST FROM LS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                    AND KUNNR = LS_HIST-KUNNR
                                    AND PRODH = LS_HIST-PRODH.

      MODIFY GT_ITAB FROM LS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                    AND KUNNR = LS_HIST-KUNNR
                                    AND PRODH = LS_HIST-PRODH.

      UPDATE ZKONA_ITEM SET STAT_FLAG = 'B' WHERE KNUMA = GV_KNUMA
                                              AND KSCHL = LS_HIST-KSCHL
                                              AND KUNNR = LS_HIST-KUNNR
                                              AND PRODH = LS_HIST-PRODH.
      IF SY-SUBRC = 0.
        COMMIT WORK.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_VK11_ZBO5
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_ERR
*&---------------------------------------------------------------------*
FORM PROCESS_VK11_ZBO5  USING    PV_ERR.

  DATA : LV_MESSAGE(220),
         LV_PRICE        TYPE KONV-KBETR,
         LV_KBETR(17),
         LV_KPEIN(17),
         LV_CNT          TYPE I.
  DATA: LV_RSLT(1),
        LV_STAT_FLAG(1).

  DATA : LT_HIST LIKE TABLE OF GS_ITAB.
  DATA : LS_HIST LIKE GS_ITAB.
  DATA : LV_ICON TYPE ICON-ID.
  CLEAR: LT_HIST, LS_HIST.


  LOOP AT GT_HIST INTO DATA(LS_DATA) WHERE TABNAME EQ 'A928'
                                       AND RSLT    NE GC_S
                                     GROUP BY ( KSCHL   = LS_HIST-KSCHL
                                                KUNNR   = LS_HIST-AUSFU )
                                     ASCENDING ASSIGNING FIELD-SYMBOL(<FS_MAIN>).
    CLEAR : GT_BDCDATA, GT_BDCDATA[],
            GT_MESSAGE, GT_MESSAGE[],
            LV_MESSAGE, LV_CNT,LV_ICON,LV_STAT_FLAG,
            LV_RSLT.

    CLEAR:LS_HIST.
    LOOP AT GROUP <FS_MAIN> ASSIGNING FIELD-SYMBOL(<FS_LINE>).
      MOVE-CORRESPONDING <FS_LINE> TO LS_HIST.
      LV_STAT_FLAG = LS_HIST-STAT_FLAG.
      EXIT.
    ENDLOOP.

    PERFORM BDC_INPUT USING :
    'SAPMV13A' '0100' 'X' 'RV13A-KSCHL' LS_HIST-KSCHL,
    '        ' '    ' ' ' 'BDC_OKCODE' '=ANTA'.

    "테이블 선택
    PERFORM BDC_INPUT USING :
    'SAPLV14A' '0100' 'X' 'BDC_CURSOR'     'RV130-SELKZ(02)',
    '        ' '    ' ' ' 'RV130-SELKZ(01)' ' ',
    '        ' '    ' ' ' 'RV130-SELKZ(02)' 'X',
    '        ' '    ' ' ' 'BDC_OKCODE'      '=WEIT'.


    PERFORM BDC_INPUT USING :
    'SAPMV13A' '1928' 'X' 'KOMG-VKORG' LS_HIST-VKORG,
    '        ' '    ' ' ' 'KOMG-VTWEG' LS_HIST-VTWEG,
    '        ' '    ' ' ' 'KOMG-SPART' LS_HIST-SPART,
*    '        ' '    ' ' ' 'KOMG-AUSFU' LS_HIST-AUSFU,
*    '        ' '    ' ' ' 'KOMG-KUNNR' LS_HIST-KUNNR,
    '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

    LOOP AT GROUP <FS_MAIN> ASSIGNING <FS_LINE>.
      LV_CNT = LV_CNT + 1.

      CLEAR : LV_PRICE, LV_KBETR, LV_KPEIN.
      LV_PRICE = ABS( <FS_LINE>-KBETR ).
      WRITE LV_PRICE TO LV_KBETR CURRENCY <FS_LINE>-KONWA.
      CONDENSE LV_KBETR NO-GAPS.


      PERFORM BDC_INPUT USING :
      'SAPMV13A' '1928' 'X' 'KOMG-AUSFU(02)'  <FS_LINE>-AUSFU,
      '        ' '    ' ' ' 'KONP-KBETR(02)'  LV_KBETR,
      '        ' '    ' ' ' 'KONP-KONWA(02)'  <FS_LINE>-KONWA,
      '        ' '    ' ' ' 'RV13A-DATAB(02)' <FS_LINE>-DATAB,
      '        ' '    ' ' ' 'RV13A-DATBI(02)' <FS_LINE>-DATBI,
      '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

      PERFORM BDC_INPUT USING :
      'SAPMV13A' '1928' 'X' 'BDC_OKCODE' '=SUCH'.

      PERFORM BDC_INPUT USING :
      'SAPLSSEL' '1104' 'X' '%%DYN005-LOW' <FS_LINE>-AUSFU,
      '        ' '    ' ' ' 'BDC_OKCODE' '=CRET'.

      PERFORM BDC_INPUT USING :
      'SAPMV13A' '1928' 'X' 'BDC_OKCODE' '=KDAT'.

      PERFORM BDC_INPUT USING :
      'SAPMV13A' '0200' 'X' 'RV13A-DATAB' LS_HIST-DATAB,
      '        ' '    ' ' ' 'RV13A-DATBI' LS_HIST-DATBI,
      '        ' '    ' ' ' 'KONH-KOSRT'  GS_HEADER-KNUMA, "계약번호
      '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

      PERFORM BDC_INPUT USING :
      'SAPMV13A' '0200' 'X' 'BDC_OKCODE' '=BACK'.

    ENDLOOP.

    IF LV_CNT = 0.
      CONTINUE.
    ENDIF.

    PERFORM BDC_INPUT USING :
        'SAPMV13A' '1928' 'X' 'BDC_OKCODE' '=SICH'.

    PERFORM FILL_CTU_PARAMS USING 'N'.

    CALL TRANSACTION 'VK11' USING GT_BDCDATA
                            OPTIONS FROM GS_PARAMS
                            MESSAGES INTO GT_MESSAGE.

    IF LINE_EXISTS( GT_MESSAGE[ MSGTYP = 'S'
                                MSGID  = 'VK' MSGNR = '023' ] ).

      LV_RSLT = GC_S.
      LV_ICON = ICON_COMPLETE.

      UPDATE ZKONA_ITEM SET STAT_FLAG = 'B'
                        WHERE KNUMA = GS_HEADER-KNUMA
                          AND KSCHL = LS_HIST-KSCHL
                          AND AUSFU = LS_HIST-AUSFU.
      IF SY-SUBRC = 0.
        LV_STAT_FLAG = 'B'.
        COMMIT WORK AND WAIT.
      ENDIF.


    ELSE.
      LOOP AT GT_MESSAGE INTO DATA(LS_MSG) WHERE MSGTYP CA 'AE'.
        EXIT.
      ENDLOOP.
      IF SY-SUBRC EQ 0.
        PV_ERR = 'X'.
        LV_RSLT = GC_E.
        LV_ICON = ICON_LED_RED.

        PERFORM MESSAGE_FUNCTION USING LS_MSG LV_MESSAGE.
        LS_HIST-MESSAGE = LV_MESSAGE.

      ELSE.
        LV_RSLT = GC_E.
        LV_ICON = ICON_LED_RED.
        LS_HIST-MESSAGE = |조건 레코드 생성 중 에러.|.
      ENDIF.

    ENDIF.

    LS_HIST-RSLT      = LV_RSLT.
    LS_HIST-ICON      = LV_ICON.
    LS_HIST-STAT_FLAG = LV_STAT_FLAG.
    MODIFY GT_HIST FROM LS_HIST
           TRANSPORTING ICON STAT_FLAG MESSAGE RSLT WHERE KSCHL = LS_HIST-KSCHL
                                                      AND AUSFU = LS_HIST-AUSFU.

    MODIFY GT_ITAB FROM LS_HIST
           TRANSPORTING ICON  STAT_FLAG MESSAGE RSLT WHERE KSCHL = LS_HIST-KSCHL
                                                       AND AUSFU = LS_HIST-AUSFU.

  ENDLOOP.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_VK11_ZBO6
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_ERR
*&---------------------------------------------------------------------*
FORM PROCESS_VK11_ZBO6  USING    PV_ERR.

  DATA : LV_MESSAGE(220),
         LV_PRICE        TYPE KONV-KBETR,
         LV_KBETR(17),
         LV_KPEIN(17),
         LV_CNT          TYPE I.

  DATA : LT_HIST LIKE TABLE OF GS_ITAB.
  DATA : LS_HIST LIKE GS_ITAB.
  CLEAR: LT_HIST, LS_HIST.
  LOOP AT GT_HIST INTO DATA(GS_HIST) WHERE KSCHL = 'ZBO6'
                                       AND STAT_FLAG = 'X'.
    CLEAR LS_HIST.
    MOVE-CORRESPONDING GS_HIST TO LS_HIST.
    APPEND LS_HIST TO LT_HIST.
  ENDLOOP.

  LOOP AT LT_HIST INTO LS_HIST GROUP BY LS_HIST-AUBEL.

    CLEAR : GT_BDCDATA, GT_BDCDATA[],
            GT_MESSAGE, GT_MESSAGE[],
            LV_MESSAGE, LV_CNT.

    PERFORM BDC_INPUT USING :
    'SAPMV13A' '0100' 'X' 'RV13A-KSCHL' LS_HIST-KSCHL,
    '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

    PERFORM BDC_INPUT USING :
    'SAPMV13A' '1927' 'X' 'KOMG-VKORG' LS_HIST-VKORG,
    '        ' '    ' ' ' 'KOMG-VTWEG' LS_HIST-VTWEG,
    '        ' '    ' ' ' 'KOMG-SPART' LS_HIST-SPART,
    '        ' '    ' ' ' 'KOMG-AUSFU' LS_HIST-AUSFU,
    '        ' '    ' ' ' 'KOMG-AUBEL' LS_HIST-AUBEL,
    '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

    LOOP AT GROUP LS_HIST INTO DATA(LS_DATA).

      LV_CNT = LV_CNT + 1.

      CLEAR : LV_PRICE, LV_KBETR, LV_KPEIN.
      LV_PRICE = ABS( LS_DATA-KBETR ).
      WRITE LV_PRICE TO LV_KBETR CURRENCY LS_DATA-KONWA.
      CONDENSE LV_KBETR NO-GAPS.
      LV_KPEIN = LS_DATA-KPEIN.
      CONDENSE LV_KPEIN NO-GAPS.

      PERFORM BDC_INPUT USING :
      'SAPMV13A' '1927' 'X' 'KOMG-AUPOS(02)' LS_DATA-AUPOS,
      '        ' '    ' ' ' 'KONP-KBETR(02)' LV_KBETR,
      '        ' '    ' ' ' 'KONP-KONWA(02)' LS_DATA-KONWA,
      '        ' '    ' ' ' 'RV13A-DATAB(02)' LS_DATA-DATAB,
      '        ' '    ' ' ' 'RV13A-DATBI(02)' LS_DATA-DATBI,
      '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

      PERFORM BDC_INPUT USING :
      'SAPMV13A' '1927' 'X' 'BDC_OKCODE' '=SUCH'.

      PERFORM BDC_INPUT USING :
     'SAPLSSEL' '1104' 'X' '%%DYN007-LOW' LS_DATA-AUPOS,
     '        ' '    ' ' ' 'BDC_OKCODE' '=CRET'.

      PERFORM BDC_INPUT USING :
   'SAPMV13A' '1927' 'X' 'BDC_OKCODE' '=KDAT'.

      PERFORM BDC_INPUT USING :
   'SAPMV13A' '0200' 'X' 'RV13A-DATAB' LS_HIST-DATAB,
   '        ' '    ' ' ' 'RV13A-DATBI' LS_HIST-DATBI,
   '        ' '    ' ' ' 'KONH-KOSRT'  GS_HEADER-KNUMA, "계약번호
   '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

      PERFORM BDC_INPUT USING :
      'SAPMV13A' '0200' 'X' 'BDC_OKCODE' '=BACK'.

    ENDLOOP.

    IF GV_APRV_STAT = 'C' AND LV_CNT = 0.
      CONTINUE.
    ENDIF.

    PERFORM BDC_INPUT USING :
    'SAPMV13A' '1927' 'X' 'BDC_OKCODE' '=SICH'.

    PERFORM FILL_CTU_PARAMS USING 'N'.
    CALL TRANSACTION 'VK11' USING GT_BDCDATA
                            OPTIONS FROM GS_PARAMS
                            MESSAGES INTO GT_MESSAGE.

    PERFORM MESSAGE_FUNCTION USING GT_MESSAGE LV_MESSAGE.
    READ TABLE GT_MESSAGE WITH KEY MSGTYP = 'E'.
    IF SY-SUBRC = 0.

      PV_ERR = 'X'.
      LS_HIST-MESSAGE = LV_MESSAGE.
      MODIFY GT_HIST FROM LS_HIST TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                                         AND AUBEL = LS_HIST-AUBEL.
      MODIFY GT_ITAB FROM LS_HIST TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                                         AND AUBEL = LS_HIST-AUBEL.

      EXIT.
    ELSE.
      READ TABLE GT_MESSAGE INDEX 1.
      IF SY-SUBRC = 0.
        PERFORM MESSAGE_FUNCTION USING GT_MESSAGE LV_MESSAGE.
      ENDIF.
*      MESSAGE S001 WITH LV_MESSAGE.
      LS_HIST-MESSAGE = LV_MESSAGE.
      MODIFY GT_HIST FROM LS_HIST TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                                         AND AUBEL = LS_HIST-AUBEL.
      MODIFY GT_ITAB FROM LS_HIST TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                                         AND AUBEL = LS_HIST-AUBEL.

      UPDATE ZKONA_ITEM SET STAT_FLAG = 'B' WHERE KNUMA = GV_KNUMA
                                              AND KSCHL = LS_HIST-KSCHL
                                              AND AUBEL = LS_HIST-AUBEL.
      IF SY-SUBRC = 0.
        COMMIT WORK.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_VK11_ZBO7
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_ERR
*&---------------------------------------------------------------------*
FORM PROCESS_VK11_ZBO7  USING    PV_ERR.

  DATA : LV_MESSAGE(220),
         LV_PRICE        TYPE KONV-KBETR,
         LV_KBETR(17),
         LV_KPEIN(17),
         LV_CNT          TYPE I.

  DATA : LT_HIST LIKE TABLE OF GS_ITAB.
  DATA : LS_HIST LIKE GS_ITAB.
  CLEAR: LT_HIST, LS_HIST.
  LOOP AT GT_HIST INTO DATA(GS_HIST) WHERE KSCHL = 'ZBO7'
                                       AND STAT_FLAG = 'X'.
    CLEAR LS_HIST.
    MOVE-CORRESPONDING GS_HIST TO LS_HIST.
    APPEND LS_HIST TO LT_HIST.
  ENDLOOP.


  LOOP AT LT_HIST INTO LS_HIST GROUP BY LS_HIST-KSCHL.

    CLEAR : GT_BDCDATA, GT_BDCDATA[],
            GT_MESSAGE, GT_MESSAGE[],
            LV_MESSAGE, LV_CNT.

    PERFORM BDC_INPUT USING :
    'SAPMV13A' '0100' 'X' 'RV13A-KSCHL' LS_HIST-KSCHL,
    '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

    PERFORM BDC_INPUT USING :
    'SAPMV13A' '1927' 'X' 'KOMG-VKORG' LS_HIST-VKORG,
    '        ' '    ' ' ' 'KOMG-VTWEG' LS_HIST-VTWEG,
    '        ' '    ' ' ' 'KOMG-SPART' LS_HIST-SPART,
    '        ' '    ' ' ' 'KOMG-AUSFU' LS_HIST-AUSFU,
    '        ' '    ' ' ' 'KOMG-AUBEL' LS_HIST-AUBEL,
    '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

    LOOP AT GROUP LS_HIST INTO DATA(LS_DATA).

      LV_CNT = LV_CNT + 1.

      CLEAR : LV_PRICE, LV_KBETR, LV_KPEIN.
      LV_PRICE = ABS( LS_DATA-KBETR ).
      WRITE LV_PRICE TO LV_KBETR CURRENCY LS_DATA-KONWA.
      CONDENSE LV_KBETR NO-GAPS.
      LV_KPEIN = LS_DATA-KPEIN.
      CONDENSE LV_KPEIN NO-GAPS.

      PERFORM BDC_INPUT USING :
      'SAPMV13A' '1927' 'X' 'KOMG-AUPOS(02)' LS_DATA-AUPOS,
      '        ' '    ' ' ' 'KONP-KBETR(02)' LV_KBETR,
      '        ' '    ' ' ' 'KONP-KONWA(02)' LS_DATA-KONWA,
      '        ' '    ' ' ' 'KONP-KPEIN(02)' LV_KPEIN,
      '        ' '    ' ' ' 'KONP-KMEIN(02)' LS_DATA-KMEIN,
      '        ' '    ' ' ' 'RV13A-DATAB(02)' LS_DATA-DATAB,
      '        ' '    ' ' ' 'RV13A-DATBI(02)' LS_DATA-DATBI,
      '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

      PERFORM BDC_INPUT USING :
     'SAPMV13A' '1927' 'X' 'BDC_OKCODE' '=SUCH'.

      PERFORM BDC_INPUT USING :
     'SAPLSSEL' '1104' 'X' '%%DYN007-LOW' LS_DATA-AUPOS,
     '        ' '    ' ' ' 'BDC_OKCODE' '=CRET'.

      PERFORM BDC_INPUT USING :
    'SAPMV13A' '1927' 'X' 'BDC_OKCODE' '=KDAT'.

      PERFORM BDC_INPUT USING :
   'SAPMV13A' '0200' 'X' 'RV13A-DATAB' LS_HIST-DATAB,
   '        ' '    ' ' ' 'RV13A-DATBI' LS_HIST-DATBI,
   '        ' '    ' ' ' 'KONH-KOSRT'  GS_HEADER-KNUMA, "계약번호
   '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

      PERFORM BDC_INPUT USING :
    'SAPMV13A' '0200' 'X' 'BDC_OKCODE' '=BACK'.


    ENDLOOP.

    IF GV_APRV_STAT = 'C' AND LV_CNT = 0.
      CONTINUE.
    ENDIF.

    PERFORM BDC_INPUT USING :
    'SAPMV13A' '1927' 'X' 'BDC_OKCODE' '=SICH'.

    PERFORM FILL_CTU_PARAMS USING 'N'.
    CALL TRANSACTION 'VK11' USING GT_BDCDATA
                            OPTIONS FROM GS_PARAMS
                            MESSAGES INTO GT_MESSAGE.

    PERFORM MESSAGE_FUNCTION USING GT_MESSAGE LV_MESSAGE.
    READ TABLE GT_MESSAGE WITH KEY MSGTYP = 'E'.

    IF SY-SUBRC = 0.

      PV_ERR = 'X'.
      LS_HIST-MESSAGE = LV_MESSAGE.
      MODIFY GT_HIST FROM LS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                    AND AUBEL = LS_HIST-AUBEL.

      MODIFY GT_ITAB FROM LS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                    AND AUBEL = LS_HIST-AUBEL.

      EXIT.

    ELSE.
      READ TABLE GT_MESSAGE INDEX 1.

      IF SY-SUBRC = 0.
        PERFORM MESSAGE_FUNCTION USING GT_MESSAGE LV_MESSAGE.
      ENDIF.

      LS_HIST-MESSAGE = LV_MESSAGE.
      MODIFY GT_HIST FROM LS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                    AND AUBEL = LS_HIST-AUBEL.
      MODIFY GT_ITAB FROM LS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = LS_HIST-KSCHL
                                    AND AUBEL = LS_HIST-AUBEL.

      UPDATE ZKONA_ITEM SET STAT_FLAG = 'B' WHERE KNUMA = GV_KNUMA
                                              AND KSCHL = LS_HIST-KSCHL
                                              AND AUBEL = LS_HIST-AUBEL.
      IF SY-SUBRC = 0.
        COMMIT WORK.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_BOSTA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_DYNPUPD
*&---------------------------------------------------------------------*
FORM UPDATE_BOSTA  TABLES PT_DYNPUPD STRUCTURE DYNPREAD.

  GS_HEADER-BOSTA = 'B'.

  PT_DYNPUPD-FIELDNAME  = 'GS_HEADER-BOSTA'.
  PT_DYNPUPD-FIELDVALUE =  GS_HEADER-BOSTA..
  APPEND PT_DYNPUPD.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = PT_DYNPUPD
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      UNDEFIND_ERROR       = 7
      OTHERS               = 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_MAIL2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_MAIL2 .

*  DATA : lv_mail      TYPE p0105-usrid,
*         lv_bodynum   TYPE i,
*         ls_docdata   LIKE sodocchgi1,
*         lt_objhead   LIKE solisti1   OCCURS 1  WITH HEADER LINE,
*         lt_objpack   LIKE sopcklsti1 OCCURS 2  WITH HEADER LINE,
*         lt_objtxt    LIKE solisti1   OCCURS 10 WITH HEADER LINE,
*         lt_objbin    LIKE solisti1   OCCURS 10 WITH HEADER LINE,
*         lt_receivers LIKE somlreci1  OCCURS 5  WITH HEADER LINE.
*  DATA : lv_knuma TYPE kona-knuma,
*         lv_ausfu TYPE lfb1-lifnr.
*
*  CLEAR   : lv_mail,
*            lv_bodynum,
*            ls_docdata,
*            lt_receivers,
*            lt_objhead,
*            lt_objtxt,
*            lt_objbin,
*            lt_objpack,
*            lv_knuma,
*            lv_ausfu.
*
*  REFRESH : lt_receivers,
*            lt_objhead,
*            lt_objtxt,
*            lt_objbin,
*            lt_objpack.
*
*  DATA(lv_znumc) = CONV num2( gs_0620-znumc + 1 ).
*
*
*  CHECK gv_simple_approval = ' '.
*
*
*  SELECT SINGLE name1
*    INTO @DATA(lv_name)
*    FROM lfa1
*    WHERE lifnr = @gs_header-ausfu .
*
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*    EXPORTING
*      input  = gs_header-knuma
*    IMPORTING
*      output = lv_knuma.
*
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*    EXPORTING
*      input  = gs_header-ausfu
*    IMPORTING
*      output = lv_ausfu.
*
*  SELECT SINGLE name_last
*    INTO @DATA(lv_sname)
*    FROM user_addr AS a
*             INNER JOIN zsdt0620 AS b
*                     ON a~bname = b~ernam
*   WHERE b~zv4reqno = @gs_0620-zv4reqno.
*
**- 메일 내용
*  lt_objtxt-line = '[시스템 자동 발송 메일입니다.]'.
*  APPEND lt_objtxt.
*
*  CONCATENATE 'SAP 커미션 생성 승인 요청이'
*              '아래와 같이 접수 되었습니다.'
*         INTO lt_objtxt-line SEPARATED BY space.
*
*  APPEND lt_objtxt.
*
*  CLEAR lt_objtxt.
*  APPEND lt_objtxt.
*
*  CONCATENATE '커미션계약 ' lv_knuma ' 내역을 확인 후 '
*              '커미션 계약 등록을 승인해주세요.'
*         INTO lt_objtxt-line SEPARATED BY space.
*  APPEND lt_objtxt.
*
*  CLEAR lt_objtxt.
*  APPEND lt_objtxt.
*
*  CONCATENATE '요청자 : ' lv_sname
*         INTO lt_objtxt-line.
*  APPEND lt_objtxt.
*
*  CLEAR lt_objtxt.
*
*  CONCATENATE '커미션 번호 : ' lv_knuma
*         INTO lt_objtxt-line.
*  APPEND lt_objtxt.
*
*  CLEAR lt_objtxt.
*
*  CONCATENATE '승인 요청 번호 : ' gs_0620-zv4reqno
*         INTO lt_objtxt-line.
*  APPEND lt_objtxt.
*
*  CLEAR lt_objtxt.
*
*  CONCATENATE 'Agent 명 : ' lv_ausfu lv_name
*         INTO lt_objtxt-line.
*  APPEND lt_objtxt.
*
*  CLEAR lt_objtxt.
*
*  CONCATENATE 'SAP에 접속하시어 아래의 프로그램을'
*              '통해 승인 해주시기 바랍니다.'
*         INTO lt_objtxt-line.
*  APPEND lt_objtxt.
*
*  CLEAR lt_objtxt.
*
*  CONCATENATE '접속 T-CODE : ' 'ZSD1R2700' '-' '[SD]승인 프로그램'
*         INTO lt_objtxt-line SEPARATED BY space.
*  APPEND lt_objtxt.
*
*  CLEAR lt_objtxt.
*  APPEND lt_objtxt.
*
*  lt_objtxt-line = '감사합니다.'.
*  APPEND lt_objtxt.
*
**- 메일 헤더
*  ls_docdata-obj_name = 'URGENT'.
*  ls_docdata-expiry_dat = sy-datum + 10.
*  ls_docdata-obj_descr = | [SAP 커미션 승인 요청 안내] 커미션 승인 요청 No : { gs_0620-zv4reqno } |.
*  ls_docdata-sensitivty = '0'.
*
*  LOOP AT lt_objtxt.
*    ls_docdata-doc_size = ls_docdata-doc_size + strlen( lt_objtxt ).
*  ENDLOOP.
*
*  CLEAR : lt_objpack-transf_bin.
*
*  DESCRIBE TABLE lt_objtxt LINES lv_bodynum.
*
*  lt_objpack-head_start = 1.
*  lt_objpack-head_num   = 0.
*  lt_objpack-body_start = 1.
*  lt_objpack-body_num   = lv_bodynum.
*  lt_objpack-doc_type   = 'RAW'.
*
*  APPEND lt_objpack.
*
**- 수신자
*  SELECT SINGLE a~usrid
*    INTO lv_mail
*    FROM zpa0105 AS a
*           INNER JOIN zsdt0630 AS b
*                   ON a~pernr EQ b~uname
*    WHERE a~subty    = '0007'
*      AND a~begda   <= sy-datum
*      AND a~endda   >= sy-datum
*      AND b~zv4reqno = gs_0620-zv4reqno
*      AND b~znumc    = lv_znumc.
*
*  IF lv_mail IS NOT INITIAL.
*    lt_receivers-receiver   = lv_mail.
*    lt_receivers-rec_type   = 'U'.
*    lt_receivers-notif_del  = 'X'.
*    lt_receivers-notif_ndel = 'X'.
*    APPEND lt_receivers.
*  ENDIF.
*
*  CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
*    EXPORTING
*      document_data              = ls_docdata
*      put_in_outbox              = 'X'
*      sender_address             = 'ADMIN'
*      sender_address_type        = 'U'
*      commit_work                = 'X'
*    TABLES
*      packing_list               = lt_objpack
*      object_header              = lt_objhead
*      contents_txt               = lt_objtxt
*      receivers                  = lt_receivers
*    EXCEPTIONS
*      too_many_receivers         = 1
*      document_not_sent          = 2
*      document_type_not_exist    = 3
*      operation_no_authorization = 4
*      parameter_error            = 5
*      x_error                    = 6
*      enqueue_error              = 7
*      OTHERS                     = 8.
*
*  IF sy-subrc <> 0.
*    MESSAGE i003(zsd1) WITH '변경요청 생성은 완료하였지만'
*                            '메일 발송은 실패했습니다!'.
*  ELSE.
**    COMMIT WORK.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONTROL_CELL_EDIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONTROL_CELL_EDIT .

  DATA : LT_CELLTAB TYPE TABLE OF LVC_S_STYL.
  DATA  : LV_ACT,
          LV_HALF_ACT,
          LV_INACT.
  CLEAR : LV_ACT, LV_HALF_ACT, LV_INACT.

  CASE SY-TCODE.
    WHEN GC_ZVBO1.
      LV_ACT = 'X'.
    WHEN GC_ZVBO2.
      IF GV_APRV_STAT = 'P'.
        LV_INACT = 'X'.
      ELSEIF GV_APRV_STAT = 'C'.
        LV_INACT = 'X'.
      ELSE.
        LV_ACT = 'X'.
      ENDIF.
    WHEN GC_ZVBO3.
      LV_INACT = 'X'.
*    WHEN GC_ZVBO4.
*      LV_INACT = 'X'.
*    WHEN GC_ZVBO5.
*      LV_INACT = 'X'.
*    WHEN GC_ZVBO6.
*      LV_ACT = 'X'.
  ENDCASE.


  LOOP AT GT_ITAB INTO DATA(LS_ITAB).

    CLEAR : LT_CELLTAB, LS_ITAB-CELLTAB.

    PERFORM SET_CELLTAB TABLES LT_CELLTAB
                         USING 'DEL' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

    PERFORM SET_CELLTAB TABLES LT_CELLTAB
                         USING 'KSCHL' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

    PERFORM SET_CELLTAB TABLES LT_CELLTAB
                         USING 'VKORG' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

    PERFORM SET_CELLTAB TABLES LT_CELLTAB
                         USING 'VTWEG' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

    PERFORM SET_CELLTAB TABLES LT_CELLTAB
                         USING 'SPART' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

    PERFORM SET_CELLTAB TABLES LT_CELLTAB
                         USING 'AUSFU' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

    PERFORM SET_CELLTAB TABLES LT_CELLTAB
                         USING 'DATAB' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

    PERFORM SET_CELLTAB TABLES LT_CELLTAB
                         USING 'DATBI' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

    IF LV_ACT = 'X'.
      IF LS_ITAB-NEW = 'X'.
        PERFORM SET_CELLTAB TABLES LT_CELLTAB
                           USING 'KONWA' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

        "정상생성 후 필드 입력 불가
        CASE LS_ITAB-RSLT.
          WHEN GC_S.
            PERFORM SET_CELLTAB TABLES LT_CELLTAB
                                 USING 'KBETR' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          WHEN OTHERS.
            PERFORM SET_CELLTAB TABLES LT_CELLTAB
                                 USING 'KBETR' CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
        ENDCASE.


        PERFORM SET_CELLTAB TABLES LT_CELLTAB
                             USING 'KUNNR' CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.

        PERFORM SET_CELLTAB TABLES LT_CELLTAB
                             USING 'MATNR' CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.

        PERFORM SET_CELLTAB TABLES LT_CELLTAB
                             USING 'PRODH' CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.

        PERFORM SET_CELLTAB TABLES LT_CELLTAB
                             USING 'INCO1' CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.

        PERFORM SET_CELLTAB TABLES LT_CELLTAB
                             USING 'AUBEL' CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.

        PERFORM SET_CELLTAB TABLES LT_CELLTAB
                             USING 'AUPOS' CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.

        PERFORM SET_CELLTAB TABLES LT_CELLTAB
                             USING 'KPEIN' CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.

        PERFORM SET_CELLTAB TABLES LT_CELLTAB
                             USING 'KMEIN' CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
      ELSE.
        PERFORM SET_CELLTAB TABLES LT_CELLTAB
                           USING 'KONWA' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
        PERFORM SET_CELLTAB TABLES LT_CELLTAB
                             USING 'KBETR' CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.

        PERFORM SET_CELLTAB TABLES LT_CELLTAB
                             USING 'KUNNR' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

        PERFORM SET_CELLTAB TABLES LT_CELLTAB
                             USING 'MATNR' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

        PERFORM SET_CELLTAB TABLES LT_CELLTAB
                             USING 'PRODH' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

        PERFORM SET_CELLTAB TABLES LT_CELLTAB
                             USING 'INCO1' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

        PERFORM SET_CELLTAB TABLES LT_CELLTAB
                             USING 'AUBEL' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

        PERFORM SET_CELLTAB TABLES LT_CELLTAB
                             USING 'AUPOS' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

        PERFORM SET_CELLTAB TABLES LT_CELLTAB
                             USING 'KPEIN' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

        PERFORM SET_CELLTAB TABLES LT_CELLTAB
                             USING 'KMEIN' CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

      ENDIF.

    ELSEIF LV_INACT = 'X'.

      PERFORM SET_CELLTAB TABLES LT_CELLTAB
                           USING 'KONWA'
                                 CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

      PERFORM SET_CELLTAB TABLES LT_CELLTAB
                           USING 'KBETR'
                                 CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

      PERFORM SET_CELLTAB TABLES LT_CELLTAB
                           USING 'KUNNR'
                                 CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

      PERFORM SET_CELLTAB TABLES LT_CELLTAB
                           USING 'MATNR'
                                 CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

      PERFORM SET_CELLTAB TABLES LT_CELLTAB
                           USING 'PRODH'
                                 CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

      PERFORM SET_CELLTAB TABLES LT_CELLTAB
                           USING 'INCO1'
                                 CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

      PERFORM SET_CELLTAB TABLES LT_CELLTAB
                           USING 'AUBEL'
                                 CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

      PERFORM SET_CELLTAB TABLES LT_CELLTAB
                           USING 'AUPOS'
                                 CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

      PERFORM SET_CELLTAB TABLES LT_CELLTAB
                           USING 'KPEIN'
                                 CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

      PERFORM SET_CELLTAB TABLES LT_CELLTAB
                           USING 'KMEIN'
                                 CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    ENDIF.

    INSERT LINES OF LT_CELLTAB INTO TABLE LS_ITAB-CELLTAB.
    MODIFY GT_ITAB FROM LS_ITAB.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_MAIL3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_MAIL3 .

  DATA : LV_MAIL      TYPE P0105-USRID,
         LV_BODYNUM   TYPE I,
         LS_DOCDATA   LIKE SODOCCHGI1,
         LT_OBJHEAD   LIKE SOLISTI1   OCCURS 1  WITH HEADER LINE,
         LT_OBJPACK   LIKE SOPCKLSTI1 OCCURS 2  WITH HEADER LINE,
         LT_OBJTXT    LIKE SOLISTI1   OCCURS 10 WITH HEADER LINE,
         LT_OBJBIN    LIKE SOLISTI1   OCCURS 10 WITH HEADER LINE,
         LT_RECEIVERS LIKE SOMLRECI1  OCCURS 5  WITH HEADER LINE.
  DATA : LV_KNUMA TYPE KONA-KNUMA,
         LV_AUSFU TYPE LFB1-LIFNR.

  CLEAR   : LV_MAIL,
            LV_BODYNUM,
            LS_DOCDATA,
            LT_RECEIVERS,
            LT_OBJHEAD,
            LT_OBJTXT,
            LT_OBJBIN,
            LT_OBJPACK,
            LV_KNUMA,
            LV_AUSFU.

  REFRESH : LT_RECEIVERS,
            LT_OBJHEAD,
            LT_OBJTXT,
            LT_OBJBIN,
            LT_OBJPACK.
  CHECK GV_SIMPLE_APPROVAL = ' '.

  SELECT SINGLE NAME1
    INTO @DATA(LV_NAME)
    FROM LFA1
    WHERE LIFNR = @GS_HEADER-AUSFU .

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = GS_HEADER-KNUMA
    IMPORTING
      OUTPUT = LV_KNUMA.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = GS_HEADER-AUSFU
    IMPORTING
      OUTPUT = LV_AUSFU.



*- 메일 내용
  LT_OBJTXT-LINE = '[시스템 자동 발송 메일입니다.]'.
  APPEND LT_OBJTXT.

  CONCATENATE 'SAP 커미션 승인이' '완료 되었습니다.'
         INTO LT_OBJTXT-LINE SEPARATED BY SPACE.
  APPEND LT_OBJTXT.

  CLEAR LT_OBJTXT.
  APPEND LT_OBJTXT.

  CONCATENATE '커미션 번호 : ' LV_KNUMA
         INTO LT_OBJTXT-LINE SEPARATED BY SPACE.
  APPEND LT_OBJTXT.
  CLEAR LT_OBJTXT.

  CONCATENATE '승인 요청 번호 : ' GS_0620-ZV4REQNO
         INTO LT_OBJTXT-LINE SEPARATED BY SPACE.
  APPEND LT_OBJTXT.
  CLEAR LT_OBJTXT.

  CONCATENATE 'Agent 명 : ' LV_AUSFU  LV_NAME
         INTO LT_OBJTXT-LINE SEPARATED BY SPACE.
  APPEND LT_OBJTXT.
  CLEAR LT_OBJTXT.

  CONCATENATE 'SAP에 접속하시어' '커미션 계약상태가'
              '릴리즈인지 확인 바랍니다. '
              '커미션 변경은 1~3차수 결제를' '다시 받아야 하기에'
              '변경시 참고 부탁드립니다.'
         INTO LT_OBJTXT-LINE SEPARATED BY SPACE.
  APPEND LT_OBJTXT.

  CLEAR LT_OBJTXT.
  APPEND LT_OBJTXT.

  LT_OBJTXT-LINE = '감사합니다.'.
  APPEND LT_OBJTXT.

*- 메일 헤더
  LS_DOCDATA-OBJ_NAME = 'URGENT'.
  LS_DOCDATA-EXPIRY_DAT = SY-DATUM + 10.
  LS_DOCDATA-OBJ_DESCR = | [SAP 커미션 승인 안내] 커미션 승인 요청 No : { GS_0620-ZV4REQNO } |.
  LS_DOCDATA-SENSITIVTY = '0'.

  LOOP AT LT_OBJTXT.
    LS_DOCDATA-DOC_SIZE = LS_DOCDATA-DOC_SIZE + STRLEN( LT_OBJTXT ).
  ENDLOOP.

  CLEAR : LT_OBJPACK-TRANSF_BIN.

  DESCRIBE TABLE LT_OBJTXT LINES LV_BODYNUM.

  LT_OBJPACK-HEAD_START = 1.
  LT_OBJPACK-HEAD_NUM   = 0.
  LT_OBJPACK-BODY_START = 1.
  LT_OBJPACK-BODY_NUM   = LV_BODYNUM.
  LT_OBJPACK-DOC_TYPE   = 'RAW'.

  APPEND LT_OBJPACK.

*- 수신자
  SELECT SINGLE A~USRID
    INTO LV_MAIL
    FROM ZPA0105 AS A
           INNER JOIN ZSDT0630 AS B
                   ON A~PERNR EQ B~UNAME
    WHERE A~SUBTY    = '0007'
      AND A~BEGDA   <= SY-DATUM
      AND A~ENDDA   >= SY-DATUM
      AND B~ZV4REQNO = GS_0620-ZV4REQNO
      AND B~ZNUMC    = 00.

  IF LV_MAIL IS NOT INITIAL.
    LT_RECEIVERS-RECEIVER   = LV_MAIL.
    LT_RECEIVERS-REC_TYPE   = 'U'.
    LT_RECEIVERS-NOTIF_DEL  = 'X'.
    LT_RECEIVERS-NOTIF_NDEL = 'X'.
    APPEND LT_RECEIVERS.
  ENDIF.

  CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
    EXPORTING
      DOCUMENT_DATA              = LS_DOCDATA
      PUT_IN_OUTBOX              = 'X'
      SENDER_ADDRESS             = 'ADMIN'
      SENDER_ADDRESS_TYPE        = 'U'
      COMMIT_WORK                = 'X'
    TABLES
      PACKING_LIST               = LT_OBJPACK
      OBJECT_HEADER              = LT_OBJHEAD
      CONTENTS_TXT               = LT_OBJTXT
      RECEIVERS                  = LT_RECEIVERS
    EXCEPTIONS
      TOO_MANY_RECEIVERS         = 1
      DOCUMENT_NOT_SENT          = 2
      DOCUMENT_TYPE_NOT_EXIST    = 3
      OPERATION_NO_AUTHORIZATION = 4
      PARAMETER_ERROR            = 5
      X_ERROR                    = 6
      ENQUEUE_ERROR              = 7
      OTHERS                     = 8.

  IF SY-SUBRC <> 0.
    MESSAGE I003(ZSD1) WITH '커미션 승인은 완료하였지만'
                            '메일 발송은 실패했습니다!'.
  ELSE.
*    COMMIT WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_MAIL4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_MAIL4 .

  DATA : LV_MAIL      TYPE P0105-USRID,
         LV_BODYNUM   TYPE I,
         LS_DOCDATA   LIKE SODOCCHGI1,
         LT_OBJHEAD   LIKE SOLISTI1   OCCURS 1  WITH HEADER LINE,
         LT_OBJPACK   LIKE SOPCKLSTI1 OCCURS 2  WITH HEADER LINE,
         LT_OBJTXT    LIKE SOLISTI1   OCCURS 10 WITH HEADER LINE,
         LT_OBJBIN    LIKE SOLISTI1   OCCURS 10 WITH HEADER LINE,
         LT_RECEIVERS LIKE SOMLRECI1  OCCURS 5  WITH HEADER LINE.
  DATA : LV_KNUMA TYPE KONA-KNUMA,
         LV_AUSFU TYPE LFB1-LIFNR.

  CLEAR   : LV_MAIL,
            LV_BODYNUM,
            LS_DOCDATA,
            LT_RECEIVERS,
            LT_OBJHEAD,
            LT_OBJTXT,
            LT_OBJBIN,
            LT_OBJPACK,
            LV_KNUMA,
            LV_AUSFU.

  REFRESH : LT_RECEIVERS,
            LT_OBJHEAD,
            LT_OBJTXT,
            LT_OBJBIN,
            LT_OBJPACK.

  CHECK GV_SIMPLE_APPROVAL = ' '.

  SELECT SINGLE NAME1
    INTO @DATA(LV_NAME)
    FROM LFA1
    WHERE LIFNR = @GS_HEADER-AUSFU .

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = GS_HEADER-KNUMA
    IMPORTING
      OUTPUT = LV_KNUMA.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = GS_HEADER-AUSFU
    IMPORTING
      OUTPUT = LV_AUSFU.


  DATA : LV_PERNR TYPE ZSD0105T-PERNR.
  LV_PERNR = SY-UNAME.
  SELECT SINGLE SNAME
    INTO @DATA(LV_SNAME)
    FROM ZSD0105T
    WHERE VKORG = @GS_ORG-VKORG
     AND VTWEG  = @GS_ORG-VTWEG
     AND SPART  = @GS_ORG-SPART
     AND VKBUR  = @GS_ORG-VKBUR
     AND ZAUART = 'V6'
     AND ZNUMC  = @GS_0620-ZNUMC
     AND PERNR  = @LV_PERNR.


*- 메일 내용
  LT_OBJTXT-LINE = '[ERP 시스템 자동 발송 메일입니다.]'.
  APPEND LT_OBJTXT.

  CONCATENATE 'SAP 커미션 요청이' '반려되었습니다.'
  INTO LT_OBJTXT-LINE.
  APPEND LT_OBJTXT.

  CLEAR LT_OBJTXT.
  APPEND LT_OBJTXT.

  CONCATENATE '커미션 번호 : ' LV_KNUMA
  INTO LT_OBJTXT-LINE.
  APPEND LT_OBJTXT.
  CLEAR LT_OBJTXT.

  CONCATENATE '승인 요청 번호 : ' GS_0620-ZV4REQNO
  INTO LT_OBJTXT-LINE.
  APPEND LT_OBJTXT.
  CLEAR LT_OBJTXT.

  CONCATENATE 'Agent 명 : ' LV_AUSFU  LV_NAME
  INTO LT_OBJTXT-LINE.
  APPEND LT_OBJTXT.
  CLEAR LT_OBJTXT.

  CONCATENATE '승인 차수 : ' GS_0620-ZNUMC
  INTO LT_OBJTXT-LINE.
  APPEND LT_OBJTXT.
  CLEAR LT_OBJTXT.

  CONCATENATE '담당자 : ' LV_SNAME
  INTO LT_OBJTXT-LINE.
  APPEND LT_OBJTXT.
  CLEAR LT_OBJTXT.

  CONCATENATE 'T-code : ' 'ZVBO2에서' '커미션 확인 및 변경 후'
              '승인요청 재부탁드리겠습니다.'
  INTO LT_OBJTXT-LINE.
  APPEND LT_OBJTXT.

  CLEAR LT_OBJTXT.
  APPEND LT_OBJTXT.

  CONCATENATE '커미션 1~3차수 결제를' '다시 받아야 하기에'
              '참고 부탁드립니다.'
  INTO LT_OBJTXT-LINE.
  APPEND LT_OBJTXT.

  CLEAR LT_OBJTXT.
  APPEND LT_OBJTXT.

  LT_OBJTXT-LINE = '감사합니다.'.
  APPEND LT_OBJTXT.

*- 메일 헤더
  LS_DOCDATA-OBJ_NAME = 'URGENT'.
  LS_DOCDATA-EXPIRY_DAT = SY-DATUM + 10.
  LS_DOCDATA-OBJ_DESCR = | [SAP 커미션 반려메일 발송] 커미션 승인 요청 No : { GS_0620-ZV4REQNO } |.
  LS_DOCDATA-SENSITIVTY = '0'.

  LOOP AT LT_OBJTXT.
    LS_DOCDATA-DOC_SIZE = LS_DOCDATA-DOC_SIZE + STRLEN( LT_OBJTXT ).
  ENDLOOP.

  CLEAR : LT_OBJPACK-TRANSF_BIN.

  DESCRIBE TABLE LT_OBJTXT LINES LV_BODYNUM.

  LT_OBJPACK-HEAD_START = 1.
  LT_OBJPACK-HEAD_NUM   = 0.
  LT_OBJPACK-BODY_START = 1.
  LT_OBJPACK-BODY_NUM   = LV_BODYNUM.
  LT_OBJPACK-DOC_TYPE   = 'RAW'.

  APPEND LT_OBJPACK.

*- 수신자
  SELECT SINGLE A~USRID
    INTO LV_MAIL
    FROM ZPA0105 AS A
           INNER JOIN ZSDT0630 AS B
                   ON A~PERNR EQ B~UNAME
    WHERE A~SUBTY    = '0007'
      AND A~BEGDA   <= SY-DATUM
      AND A~ENDDA   >= SY-DATUM
      AND B~ZV4REQNO = GS_0620-ZV4REQNO
      AND B~ZNUMC    = 00.

  IF LV_MAIL IS NOT INITIAL.
    LT_RECEIVERS-RECEIVER   = LV_MAIL.
    LT_RECEIVERS-REC_TYPE   = 'U'.
    LT_RECEIVERS-NOTIF_DEL  = 'X'.
    LT_RECEIVERS-NOTIF_NDEL = 'X'.
    APPEND LT_RECEIVERS.
  ENDIF.

  CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
    EXPORTING
      DOCUMENT_DATA              = LS_DOCDATA
      PUT_IN_OUTBOX              = 'X'
      SENDER_ADDRESS             = 'ADMIN'
      SENDER_ADDRESS_TYPE        = 'U'
      COMMIT_WORK                = 'X'
    TABLES
      PACKING_LIST               = LT_OBJPACK
      OBJECT_HEADER              = LT_OBJHEAD
      CONTENTS_TXT               = LT_OBJTXT
      RECEIVERS                  = LT_RECEIVERS
    EXCEPTIONS
      TOO_MANY_RECEIVERS         = 1
      DOCUMENT_NOT_SENT          = 2
      DOCUMENT_TYPE_NOT_EXIST    = 3
      OPERATION_NO_AUTHORIZATION = 4
      PARAMETER_ERROR            = 5
      X_ERROR                    = 6
      ENQUEUE_ERROR              = 7
      OTHERS                     = 8.

  IF SY-SUBRC <> 0.
    MESSAGE I003(ZSD1) WITH '승인 반려는 완료하였지만'
                            '메일 발송은 실패했습니다!'.
  ELSE.
*    COMMIT WORK.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELLTAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_CELLTAB
*&      --> P_
*&      --> CL_GUI_ALV_GRID=>MC_STYLE_ENAB
*&---------------------------------------------------------------------*
FORM SET_CELLTAB  TABLES   PT_CELLTAB STRUCTURE LVC_S_STYL
                  USING    PV_FIELDNAME
                           PV_FLAG.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  CLEAR : LS_CELLTAB.

  LS_CELLTAB-FIELDNAME = PV_FIELDNAME.
  LS_CELLTAB-STYLE = PV_FLAG.
  INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GT_ITAB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GT_ITAB .

  DATA : LV_FIRST TYPE I.
  CLEAR LV_FIRST.

  SORT GT_HIST BY KSCHL.

  LOOP AT GT_HIST INTO DATA(LS_HIST) GROUP BY ( KSCHL = LS_HIST-KSCHL ).
    IF LS_HIST-KSCHL IS INITIAL.
      CONTINUE.
    ENDIF.

    LV_FIRST = LV_FIRST + 1.

    LOOP AT GROUP LS_HIST INTO DATA(WA).
      IF LV_FIRST <> 1.
        CONTINUE.
      ENDIF.
      GT_ITAB = VALUE #( BASE GT_ITAB
                       ( CORRESPONDING #( WA ) ) ).
      GS_HEADER-KOBOG = WA-KSCHL.
    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_FIELDS_VALUE_VALIDATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_DATBI_VALUE_VALIDATION USING PV_ER.


*{ SRM2402-10021 - s 유효기간 제한 로직 주석처리
*  DATA(lv_date) =  CONV d( |{ sy-datum+0(4) + 1 }1231| ). "유효기간은 내년 12월31일까지
*
*  IF gs_header-datbi > lv_date.
*    MESSAGE e001 WITH TEXT-e30.
*    pv_er = 'X'.
*    EXIT.
*  ENDIF.
*} SRM2402-10021 - e

  IF GS_HEADER-DATAB IS NOT INITIAL AND
     GS_HEADER-DATBI IS NOT INITIAL.

    IF GS_HEADER-DATAB > GS_HEADER-DATBI.
      MESSAGE E207.
      PV_ER = 'X'.
      EXIT.
    ENDIF.

*-> CCM : 17.11.2023 08:39:49 / ZLSGSD4  주석-> 헤더에서 점검x,품목에서
    LOOP AT GT_ITAB INTO GS_ITAB.  "수정 하고있는 조건유형 중복확인
      PERFORM CHECK_DUPLICATE_ITEM USING GS_ITAB-AUSFU
                                         GS_ITAB-KUNNR
                                         GS_ITAB-MATNR
                                         GS_ITAB-PRODH
                                         GS_ITAB-INCO1
                                         GS_ITAB-AUBEL
                                         GS_ITAB-AUPOS
                                         PV_ER.
      IF PV_ER = 'X'.
        EXIT.
      ENDIF.

    ENDLOOP.
    LOOP AT GT_HIST INTO GS_ITAB "다른 조건유형에서도 중복 확인
                     WHERE KSCHL NE GS_HEADER-KOBOG.
      PERFORM CHECK_DUPLICATE_ITEM USING GS_ITAB-AUSFU
                                         GS_ITAB-KUNNR
                                         GS_ITAB-MATNR
                                         GS_ITAB-PRODH
                                         GS_ITAB-INCO1
                                         GS_ITAB-AUBEL
                                         GS_ITAB-AUPOS
                                         PV_ER.
      IF PV_ER = 'X'.
        EXIT.
      ENDIF.

    ENDLOOP.
*<-

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_DYNPUPD
*&      --> GS_TEXT
*&---------------------------------------------------------------------*
FORM UPDATE  TABLES  PT_DYNPUPD STRUCTURE DYNPREAD.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = PT_DYNPUPD
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      UNDEFIND_ERROR       = 7
      OTHERS               = 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_GS_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GS_TEXT
  .
*-필드내역
*리베이트수령인
  SELECT SINGLE NAME1
   INTO @GS_TEXT-AUSFU_TX
   FROM LFA1
   WHERE LIFNR = @GS_HEADER-AUSFU.

*계약상태
  SELECT SINGLE DDTEXT
   INTO @GS_TEXT-BOSTA_TX
   FROM DD07V
   WHERE DOMNAME = 'ZBOSTA'
     AND DDLANGUAGE = '3'
     AND DOMVALUE_L = @GS_HEADER-BOSTA.

*검증레벨
  SELECT SINGLE DDTEXT
   INTO @GS_TEXT-ABSPZ_TX
   FROM DD07V
   WHERE DOMNAME = 'ABSPZ'
     AND DDLANGUAGE = '3'
     AND DOMVALUE_L = @GS_HEADER-ABSPZ.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DUPLICATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_KUNNR
*&      --> LV_MATNR
*&      --> LV_PRODH
*&      --> LV_INCO1
*&      --> LV_AUBEL
*&      --> LV_AUPOS
*&---------------------------------------------------------------------*
FORM CHECK_DUPLICATE  USING
                               PV_KUNNR
                               PV_MATNR
                               PV_PRODH
                               PV_INCO1
                               PV_AUBEL
                               PV_AUPOS
                               PV_ROW_ID
                               PV_FIELDNAME
                               P_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

*-> CCM : 17.11.2023 11:03:38 / ZLSGSD4 다른 커미션의 품목과 중복여부 점검
  DATA : LV_VAKEY TYPE ZKONA_ITEM-VAKEY.

*  IF GS_ITAB-KSCHL = 'ZBO1'.
*    LV_VAKEY = |{ GS_ITAB-KSCHL }{ GS_ORG-VKORG }{ GS_ORG-VTWEG }{ GS_ORG-SPART }{ GS_ITAB-AUSFU }{ PV_KUNNR }{ PV_MATNR }|.
*
*  ELSEIF GS_ITAB-KSCHL = 'ZBO2'.
*    LV_VAKEY = |{ GS_ITAB-KSCHL }{ GS_ORG-VKORG }{ GS_ORG-VTWEG }{ GS_ORG-SPART }{ GS_ITAB-AUSFU }{ PV_KUNNR }{ PV_PRODH }|.
*
*  ELSEIF GS_ITAB-KSCHL = 'ZBO3'.
*    LV_VAKEY = |{ GS_ITAB-KSCHL }{ GS_ORG-VKORG }{ GS_ORG-VTWEG }{ GS_ORG-SPART }{ GS_ITAB-AUSFU }{ PV_KUNNR }{ PV_MATNR }{ PV_INCO1 }|.
*
*  ELSEIF GS_ITAB-KSCHL = 'ZBO4'.
*    LV_VAKEY = |{ GS_ITAB-KSCHL }{ GS_ORG-VKORG }{ GS_ORG-VTWEG }{ GS_ORG-SPART }{ GS_ITAB-AUSFU }{ PV_KUNNR }{ PV_PRODH }{ PV_INCO1 }|.
*
*  ELSEIF GS_ITAB-KSCHL = 'ZBO5'.
*    LV_VAKEY = |{ GS_ITAB-KSCHL }{ GS_ORG-VKORG }{ GS_ORG-VTWEG }{ GS_ORG-SPART }{ GS_ITAB-AUSFU }{ PV_KUNNR }{ PV_INCO1 }|.
  LV_VAKEY = |{ GS_ITAB-KSCHL }{ GS_ORG-VKORG }{ GS_ORG-VTWEG }{ GS_ORG-SPART }{ GS_ITAB-AUSFU }|.

*  ELSEIF GS_ITAB-KSCHL = 'ZBO6'.
*    LV_VAKEY = |{ GS_ITAB-KSCHL }{ GS_ORG-VKORG }{ GS_ORG-VTWEG }{ GS_ORG-SPART }{ GS_ITAB-AUSFU }{ PV_AUBEL }{ PV_AUPOS }|.
*
*  ELSEIF GS_ITAB-KSCHL = 'ZBO7'.
*    LV_VAKEY = |{ GS_ITAB-KSCHL }{ GS_ORG-VKORG }{ GS_ORG-VTWEG }{ GS_ORG-SPART }{ GS_ITAB-AUSFU }{ PV_AUBEL }{ PV_AUPOS }|.
*
*  ENDIF.

  CONCATENATE '%' LV_VAKEY INTO LV_VAKEY.

  SELECT SINGLE A~KNUMA
    INTO @DATA(LV_DUPLI)      "중복 데이터 체크
    FROM ZKONA AS A
   INNER JOIN ZKONA_ITEM AS B
      ON A~KNUMA = B~KNUMA
    WHERE A~BOSTA <> 'E'
      AND A~DATAB <= @GS_HEADER-DATBI
      AND A~DATBI >= @GS_HEADER-DATAB
      AND A~KNUMA <> @GS_HEADER-KNUMA
      AND B~VAKEY LIKE @LV_VAKEY
      AND B~LOEVM <> 'X'.
  IF SY-SUBRC = 0.
    PERFORM MODIFY_CELL USING P_CHANGED
                              PV_ROW_ID
                              PV_FIELDNAME.
    MESSAGE S002 WITH LV_DUPLI TEXT-E31 DISPLAY LIKE 'E'.
    GV_ERROR = 'X'.
    EXIT.
  ENDIF.
*<-

* 동일 커미션 내 중복데이터 점검
  LOOP AT GT_ITAB INTO DATA(LS_ITAB) .

    IF SY-TABIX = PV_ROW_ID.
      CONTINUE.
    ENDIF.

*    CASE LS_ITAB-KSCHL.
*      WHEN 'ZBO1'.
*        IF PV_KUNNR IS NOT INITIAL AND
*           PV_MATNR IS NOT INITIAL.
*          IF LS_ITAB-KUNNR = PV_KUNNR AND
*             LS_ITAB-MATNR = PV_MATNR.
*            PERFORM MODIFY_CELL USING P_CHANGED
*                                      PV_ROW_ID
*                                      PV_FIELDNAME.
*
*            MESSAGE S001 WITH TEXT-E33 DISPLAY LIKE 'E'.
*            GV_ERROR = 'X'.
*            EXIT.
*
*          ENDIF.
*
*        ENDIF.
*
*      WHEN 'ZBO2'.
*        IF PV_KUNNR IS NOT INITIAL AND
*           PV_PRODH IS NOT INITIAL.
*          IF LS_ITAB-KUNNR = PV_KUNNR AND
*             LS_ITAB-PRODH = PV_PRODH.
*            PERFORM MODIFY_CELL USING P_CHANGED
*                                      PV_ROW_ID
*                                      PV_FIELDNAME.
*            MESSAGE S001 WITH TEXT-E33 DISPLAY LIKE 'E'.
*            GV_ERROR = 'X'.
*            EXIT.
*          ENDIF.
*        ENDIF.
*
*      WHEN 'ZBO3'.
*        IF PV_KUNNR IS NOT INITIAL AND
*           PV_MATNR IS NOT INITIAL AND
*           PV_INCO1 IS NOT INITIAL.
*          IF LS_ITAB-KUNNR = PV_KUNNR AND
*             LS_ITAB-MATNR = PV_MATNR AND
*             LS_ITAB-INCO1 = PV_INCO1.
*            PERFORM MODIFY_CELL USING P_CHANGED
*                                      PV_ROW_ID
*                                      PV_FIELDNAME.
*            MESSAGE S001 WITH TEXT-E33 DISPLAY LIKE 'E'.
*            GV_ERROR = 'X'.
*            EXIT.
*          ENDIF.
*        ENDIF.
*
*      WHEN 'ZBO4'.
*        IF PV_KUNNR IS NOT INITIAL AND
*           PV_PRODH IS NOT INITIAL AND
*           PV_INCO1 IS NOT INITIAL.
*          IF LS_ITAB-KUNNR = PV_KUNNR AND
*             LS_ITAB-PRODH = PV_PRODH AND
*             LS_ITAB-INCO1 = PV_INCO1.
*            PERFORM MODIFY_CELL USING P_CHANGED
*                                      PV_ROW_ID
*                                      PV_FIELDNAME.
*            MESSAGE S001 WITH TEXT-E33 DISPLAY LIKE 'E'.
*            GV_ERROR = 'X'.
*            EXIT.
*          ENDIF.
*        ENDIF.

*  WHEN 'ZBO5'.
*    IF PV_AUFSU IS NOT INITIAL .
*      IF LS_ITAB-AUSFU = PV_AUFSU.
*        PERFORM MODIFY_CELL USING P_CHANGED
*                                  PV_ROW_ID
*                                  PV_FIELDNAME.
*        MESSAGE S001 WITH TEXT-E33 DISPLAY LIKE 'E'.
*        GV_ERROR = 'X'.
*        EXIT.
*      ENDIF.
*    ENDIF.

*      WHEN 'ZBO6'.
*        IF PV_AUBEL IS NOT INITIAL AND
*           PV_AUPOS IS NOT INITIAL.
*          IF LS_ITAB-AUBEL = PV_AUBEL AND
*             LS_ITAB-AUPOS = PV_AUPOS.
*            PERFORM MODIFY_CELL USING P_CHANGED
*                                      PV_ROW_ID
*                                      PV_FIELDNAME.
*            MESSAGE S001 WITH TEXT-E33 DISPLAY LIKE 'E'.
*            GV_ERROR = 'X'.
*            EXIT.
*          ENDIF.
*        ENDIF.
*
*      WHEN 'ZBO7'.
*        IF PV_AUBEL IS NOT INITIAL AND
*           PV_AUPOS IS NOT INITIAL.
*          IF LS_ITAB-AUBEL = PV_AUBEL AND
*            LS_ITAB-AUPOS = PV_AUPOS.
*            PERFORM MODIFY_CELL USING P_CHANGED
*                                      PV_ROW_ID
*                                      PV_FIELDNAME.
*            MESSAGE S001 WITH TEXT-E33 DISPLAY LIKE 'E'.
*            GV_ERROR = 'X'.
*            EXIT.
*          ENDIF.
*        ENDIF.
*    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_ZVBO6
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ANSWER
*&---------------------------------------------------------------------*
FORM GET_LS_OLD  USING  PV_ANSWER
                        PV_ERR
                        PS_OLD TYPE ZKONA.

*-승인 후 변경시(권한자) 확인 메시지 - 바로 판가 적용됨.
  PERFORM POPUP_CONFIRM USING '확인'
                              '커미션을 변경 하시겠습니까?'
                              PV_ANSWER.

  IF PV_ANSWER = 1.

    SELECT SINGLE *
      INTO @PS_OLD
      FROM ZKONA
     WHERE KNUMA = @GS_HEADER-KNUMA .

  ELSE.

    PV_ERR = 'X'.
    EXIT.

  ENDIF.

*{ SRM2402-10021 - s
  CLEAR XZKONA.

  SELECT SINGLE *
    FROM ZKONA
    INTO XZKONA  "변경 전 헤더
   WHERE KNUMA = GS_HEADER-KNUMA.
*} SRM2402-10021 - e


ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESTORE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RESTORE .

  DATA: LT_INDEX_ROWS TYPE LVC_T_ROW,
        LT_ROW_NO     TYPE LVC_T_ROID,
        LS_ITAB       LIKE GS_ITAB,
        LT_ITAB       LIKE TABLE OF GS_ITAB,
        LV_ANSWER.

  CLEAR: LT_INDEX_ROWS, LT_ROW_NO,
         LT_ITAB,       LS_ITAB.

  PERFORM POPUP_CONFIRM USING '확인'
                              '복구 하시겠습니까?'
                              LV_ANSWER.
  CHECK LV_ANSWER = 1.

  CALL METHOD GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_INDEX_ROWS
      ET_ROW_NO     = LT_ROW_NO.

  IF LT_ROW_NO[] IS NOT INITIAL.

*- 아이콘 변경 : 삭제 -> 복구
    LT_ITAB = VALUE #( BASE LT_ITAB FOR LS_ROW_NO IN LT_ROW_NO
                      ( CORRESPONDING #( GT_ITAB[ LS_ROW_NO-ROW_ID ] ) ) ).

    IF LINE_EXISTS( LT_ITAB[ ICON = ' ' ] )    AND
       LINE_EXISTS( LT_ITAB[ ICON = '@0Y@' ] ) AND
       LINE_EXISTS( LT_ITAB[ ICON = '@DF@' ] ).

      MESSAGE S460 DISPLAY LIKE 'E'.
      EXIT.

    ENDIF.

    LOOP AT LT_ROW_NO INTO DATA(LS_ROW).

      LS_ITAB-ICON = '@2W@'. "복구
      LS_ITAB-DELETE = ' '.
      LS_ITAB-STAT_FLAG = 'R'.
      MODIFY GT_ITAB FROM LS_ITAB INDEX LS_ROW-ROW_ID
                     TRANSPORTING ICON DELETE STAT_FLAG.

    ENDLOOP.

    SORT GT_HIST BY KSCHL.

    IF LINE_EXISTS( GT_HIST[ KSCHL = GS_HEADER-KOBOG ] ).

      DELETE GT_HIST WHERE KSCHL = GS_HEADER-KOBOG.

      GT_HIST = VALUE #( BASE GT_HIST FOR WA IN GT_ITAB
                         WHERE ( KSCHL = GS_HEADER-KOBOG )
                       ( CORRESPONDING #( WA ) ) ).
    ENDIF.

  ELSE.

    MESSAGE S909 DISPLAY LIKE 'E'.  "라인을 선택하지 않았습니다.
    EXIT.

  ENDIF.

  CALL METHOD GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = GS_STBL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_ZKONA_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_ERROR
*&      --> LV_MESSAGE
*&---------------------------------------------------------------------*
FORM UPDATE_MESSAGE USING PV_ERR
                          PV_MESSAGE
                          PS_HIST STRUCTURE GS_ITAB.

  CASE PS_HIST-KSCHL.

    WHEN 'ZBO1'.

      PV_ERR = 'X'.
      PS_HIST-MESSAGE = PV_MESSAGE.
      MODIFY GT_HIST FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND KUNNR = PS_HIST-KUNNR
                                    AND MATNR = PS_HIST-MATNR.

      MODIFY GT_ITAB FROM PS_HIST
              TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                     AND KUNNR = PS_HIST-KUNNR
                                     AND MATNR = PS_HIST-MATNR.

      EXIT.

    WHEN 'ZBO2'.

      PV_ERR = 'X'.
      PS_HIST-MESSAGE = PV_MESSAGE.
      MODIFY GT_HIST FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND KUNNR = PS_HIST-KUNNR
                                    AND PRODH = PS_HIST-PRODH.

      MODIFY GT_ITAB FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND KUNNR = PS_HIST-KUNNR
                                    AND PRODH = PS_HIST-PRODH.

      EXIT.

    WHEN 'ZBO3'.

      PV_ERR = 'X'.
      PS_HIST-MESSAGE = PV_MESSAGE.
      MODIFY GT_HIST FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND KUNNR = PS_HIST-KUNNR
                                    AND MATNR = PS_HIST-MATNR
                                    AND INCO1 = PS_HIST-INCO1.

      MODIFY GT_ITAB FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND KUNNR = PS_HIST-KUNNR
                                    AND MATNR = PS_HIST-MATNR
                                    AND INCO1 = PS_HIST-INCO1.

      EXIT.

    WHEN 'ZBO4'.

      PV_ERR = 'X'.
      PS_HIST-MESSAGE = PV_MESSAGE.
      MODIFY GT_HIST FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND KUNNR = PS_HIST-KUNNR
                                    AND PRODH = PS_HIST-PRODH
                                    AND INCO1 = PS_HIST-INCO1.

      MODIFY GT_ITAB FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND KUNNR = PS_HIST-KUNNR
                                    AND PRODH = PS_HIST-PRODH
                                    AND INCO1 = PS_HIST-INCO1.

      EXIT.

    WHEN 'ZBO5'.
      PV_ERR = 'X'.
      PS_HIST-MESSAGE = PV_MESSAGE.
      MODIFY GT_HIST FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND KUNNR = PS_HIST-KUNNR
                                    AND INCO1 = PS_HIST-INCO1.

      MODIFY GT_ITAB FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND KUNNR = PS_HIST-KUNNR
                                    AND INCO1 = PS_HIST-INCO1.

      EXIT.

    WHEN 'ZBO6'.

      PV_ERR = 'X'.
      PS_HIST-MESSAGE = PV_MESSAGE.
      MODIFY GT_HIST FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND AUBEL = PS_HIST-AUBEL
                                    AND AUPOS = PS_HIST-AUPOS.

      MODIFY GT_ITAB FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND AUBEL = PS_HIST-AUBEL
                                    AND AUPOS = PS_HIST-AUPOS.

      EXIT.

    WHEN 'ZBO7'.

      PV_ERR = 'X'.
      PS_HIST-MESSAGE = PV_MESSAGE.
      MODIFY GT_HIST FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND AUBEL = PS_HIST-AUBEL
                                    AND AUPOS = PS_HIST-AUPOS.

      MODIFY GT_ITAB FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND AUBEL = PS_HIST-AUBEL
                                    AND AUPOS = PS_HIST-AUPOS.

      EXIT.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_ZKONA_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_ERR
*&      --> LV_MESSAGE
*&      --> GS_HIST
*&---------------------------------------------------------------------*
FORM UPDATE_ZKONA_ITEM  USING PV_ERR
                              PV_MESSAGE
                              PV_STAT
                              PS_HIST STRUCTURE GS_ITAB.

  CASE PS_HIST-KSCHL.

    WHEN 'ZBO1'.

      PS_HIST-MESSAGE = PV_MESSAGE.
      MODIFY GT_HIST FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND KUNNR = PS_HIST-KUNNR
                                    AND MATNR = PS_HIST-MATNR.

      MODIFY GT_ITAB FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND KUNNR = PS_HIST-KUNNR
                                    AND MATNR = PS_HIST-MATNR.

      UPDATE ZKONA_ITEM SET STAT_FLAG = PV_STAT
                            LOEVM = PS_HIST-LOEVM
                                            WHERE KNUMA = GV_KNUMA
                                              AND KSCHL = PS_HIST-KSCHL
                                              AND KUNNR = PS_HIST-KUNNR
                                              AND MATNR = PS_HIST-MATNR.
    WHEN 'ZBO2'.

      PS_HIST-MESSAGE = PV_MESSAGE.
      MODIFY GT_HIST FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND KUNNR = PS_HIST-KUNNR
                                    AND PRODH = PS_HIST-PRODH.

      MODIFY GT_ITAB FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND KUNNR = PS_HIST-KUNNR
                                    AND PRODH = PS_HIST-PRODH.

      UPDATE ZKONA_ITEM SET STAT_FLAG = PV_STAT "'B'
                            LOEVM = PS_HIST-LOEVM
                                            WHERE KNUMA = GV_KNUMA
                                              AND KSCHL = PS_HIST-KSCHL
                                              AND KUNNR = PS_HIST-KUNNR
                                              AND PRODH = PS_HIST-PRODH.
    WHEN 'ZBO3'.

      PS_HIST-MESSAGE = PV_MESSAGE.
      MODIFY GT_HIST FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND KUNNR = PS_HIST-KUNNR
                                    AND MATNR = PS_HIST-MATNR
                                    AND INCO1 = PS_HIST-INCO1.

      MODIFY GT_ITAB FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND KUNNR = PS_HIST-KUNNR
                                    AND MATNR = PS_HIST-MATNR
                                    AND INCO1 = PS_HIST-INCO1.

      UPDATE ZKONA_ITEM SET STAT_FLAG = PV_STAT"'B'
                            LOEVM = PS_HIST-LOEVM
                                            WHERE KNUMA = GV_KNUMA
                                              AND KSCHL = PS_HIST-KSCHL
                                              AND KUNNR = PS_HIST-KUNNR
                                              AND MATNR = PS_HIST-MATNR
                                              AND INCO1 = PS_HIST-INCO1.
    WHEN 'ZBO4'.

      PS_HIST-MESSAGE = PV_MESSAGE.
      MODIFY GT_HIST FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND KUNNR = PS_HIST-KUNNR
                                    AND PRODH = PS_HIST-PRODH
                                    AND INCO1 = PS_HIST-INCO1.

      MODIFY GT_ITAB FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND KUNNR = PS_HIST-KUNNR
                                    AND PRODH = PS_HIST-PRODH
                                    AND INCO1 = PS_HIST-INCO1.

      UPDATE ZKONA_ITEM SET STAT_FLAG = PV_STAT"'B'
                            LOEVM = PS_HIST-LOEVM
                                            WHERE KNUMA = GV_KNUMA
                                              AND KSCHL = PS_HIST-KSCHL
                                              AND KUNNR = PS_HIST-KUNNR
                                              AND PRODH = PS_HIST-PRODH
                                              AND INCO1 = PS_HIST-INCO1.
    WHEN 'ZBO5'.

      PS_HIST-MESSAGE = PV_MESSAGE.
      MODIFY GT_HIST FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND KUNNR = PS_HIST-KUNNR
                                    AND INCO1 = PS_HIST-INCO1.

      MODIFY GT_ITAB FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND KUNNR = PS_HIST-KUNNR
                                    AND INCO1 = PS_HIST-INCO1.

      UPDATE ZKONA_ITEM SET STAT_FLAG = PV_STAT "'B'
                            LOEVM = PS_HIST-LOEVM
                                            WHERE KNUMA = GV_KNUMA
                                              AND KSCHL = PS_HIST-KSCHL
                                              AND KUNNR = PS_HIST-KUNNR
                                              AND INCO1 = PS_HIST-INCO1.
    WHEN 'ZBO6'.

      PS_HIST-MESSAGE = PV_MESSAGE.
      MODIFY GT_HIST FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND AUBEL = PS_HIST-AUBEL
                                    AND AUPOS = PS_HIST-AUPOS.

      MODIFY GT_ITAB FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND AUBEL = PS_HIST-AUBEL
                                    AND AUPOS = PS_HIST-AUPOS.

      UPDATE ZKONA_ITEM SET STAT_FLAG = PV_STAT "'B'
                            LOEVM = PS_HIST-LOEVM
                                            WHERE KNUMA = GV_KNUMA
                                              AND KSCHL = PS_HIST-KSCHL
                                              AND AUBEL = PS_HIST-AUBEL
                                              AND AUPOS = PS_HIST-AUPOS.
    WHEN 'ZBO7'.

      PS_HIST-MESSAGE = PV_MESSAGE.
      MODIFY GT_HIST FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                    AND AUBEL = PS_HIST-AUBEL
                                    AND AUPOS = PS_HIST-AUPOS.

      MODIFY GT_ITAB FROM PS_HIST
             TRANSPORTING MESSAGE WHERE KSCHL = PS_HIST-KSCHL
                                  AND AUBEL = PS_HIST-AUBEL
                                  AND AUPOS = PS_HIST-AUPOS.

      UPDATE ZKONA_ITEM SET STAT_FLAG = PV_STAT "'B'
                            LOEVM = PS_HIST-LOEVM
                                            WHERE KNUMA = GV_KNUMA
                                              AND KSCHL = PS_HIST-KSCHL
                                              AND AUBEL = PS_HIST-AUBEL
                                              AND AUPOS = PS_HIST-AUPOS.
  ENDCASE.

  IF SY-SUBRC = 0.
    COMMIT WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_CELL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_CHANGED
*&      --> PV_ROW_ID
*&      --> PV_FIELDNAME
*&---------------------------------------------------------------------*
FORM MODIFY_CELL  USING    P_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                           PV_ROW_ID
                           PV_FIELDNAME.

  IF PV_FIELDNAME  = 'KUNNR'.

    CLEAR GS_ITAB-KUNNR.

    CALL METHOD P_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = PV_ROW_ID
        I_FIELDNAME = 'KUNNR'
        I_VALUE     = GS_ITAB-KUNNR.

  ELSEIF PV_FIELDNAME  = 'MATNR'.

    CLEAR GS_ITAB-MATNR.

    CALL METHOD P_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = PV_ROW_ID
        I_FIELDNAME = 'MATNR'
        I_VALUE     = GS_ITAB-MATNR.

  ELSEIF PV_FIELDNAME  = 'PRODH'.

    CLEAR GS_ITAB-PRODH.

    CALL METHOD P_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = PV_ROW_ID
        I_FIELDNAME = 'PRODH'
        I_VALUE     = GS_ITAB-PRODH.

  ELSEIF PV_FIELDNAME  = 'INCO1'.

    CLEAR GS_ITAB-INCO1.

    CALL METHOD P_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = PV_ROW_ID
        I_FIELDNAME = 'INCO1'
        I_VALUE     = GS_ITAB-INCO1.

  ELSEIF PV_FIELDNAME  = 'AUBEL'.

    CLEAR GS_ITAB-AUBEL.

    CALL METHOD P_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = PV_ROW_ID
        I_FIELDNAME = 'AUBEL'
        I_VALUE     = GS_ITAB-AUBEL.

  ELSEIF PV_FIELDNAME  = 'AUPOS'.

    CLEAR GS_ITAB-AUPOS.

    CALL METHOD P_CHANGED->MODIFY_CELL
      EXPORTING
        I_ROW_ID    = PV_ROW_ID
        I_FIELDNAME = 'AUPOS'
        I_VALUE     = GS_ITAB-AUPOS.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_EMPTY_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_EMPTY_VALUE .

*{ ZLSGSD4 - s ECC이관된 데이터 중 삭제표시 된 품목 중에
*              가격이 0인 경우 존재 변경 t-code를 제외하고는
*              조회시엔 넘어갈 수 있도록 check로직 추가
  CHECK SY-TCODE EQ 'ZGTSDR1101' OR SY-TCODE EQ 'ZGTSDR1102'.
*  CHECK SY-TCODE EQ 'ZVBO6' OR SY-TCODE EQ 'ZVBO2' OR SY-TCODE EQ 'ZVBO1'..
*}

  IF GT_ITAB IS NOT INITIAL.
    LOOP AT GT_ITAB INTO DATA(LS_ITAB).

      CASE LS_ITAB-KSCHL.

*        WHEN 'ZBO1'.
*
*          IF LS_ITAB-NEW = 'X'.
*            IF LS_ITAB-KBETR IS INITIAL OR
*               LS_ITAB-KONWA IS INITIAL OR
*               LS_ITAB-KUNNR IS INITIAL OR
*               LS_ITAB-MATNR IS INITIAL OR
*               LS_ITAB-KPEIN IS INITIAL OR
*               LS_ITAB-KMEIN IS INITIAL.
*              GV_ERROR = 'X'.
*              EXIT.
*            ENDIF.
*          ELSE.
*            IF LS_ITAB-KBETR IS INITIAL OR
*               LS_ITAB-KUNNR IS INITIAL OR
*               LS_ITAB-MATNR IS INITIAL OR
*               LS_ITAB-KPEIN IS INITIAL OR
*               LS_ITAB-KMEIN IS INITIAL.
*              GV_ERROR = 'X'.
*              EXIT.
*            ENDIF.
*          ENDIF.
*
*        WHEN 'ZBO2'.
*
*          IF LS_ITAB-NEW = 'X'.
*            IF LS_ITAB-KBETR IS INITIAL OR
*               LS_ITAB-KONWA IS INITIAL OR
*               LS_ITAB-KUNNR IS INITIAL OR
*               LS_ITAB-PRODH IS INITIAL OR
*               LS_ITAB-KPEIN IS INITIAL OR
*               LS_ITAB-KMEIN IS INITIAL.
*              GV_ERROR = 'X'.
*              EXIT.
*            ENDIF.
*          ELSE.
*            IF LS_ITAB-KBETR IS INITIAL OR
*               LS_ITAB-KUNNR IS INITIAL OR
*               LS_ITAB-PRODH IS INITIAL OR
*               LS_ITAB-KPEIN IS INITIAL OR
*               LS_ITAB-KMEIN IS INITIAL.
*              GV_ERROR = 'X'.
*              EXIT.
*            ENDIF.
*          ENDIF.
*
*        WHEN 'ZBO3'.
*
*          IF LS_ITAB-KBETR IS INITIAL OR
*             LS_ITAB-KUNNR IS INITIAL OR
*             LS_ITAB-MATNR IS INITIAL OR
*             LS_ITAB-INCO1 IS INITIAL.
*            GV_ERROR = 'X'.
*            EXIT.
*          ENDIF.
*
*        WHEN 'ZBO4'.
*
*          IF LS_ITAB-KBETR IS INITIAL OR
*             LS_ITAB-KUNNR IS INITIAL OR
*             LS_ITAB-PRODH IS INITIAL OR
*             LS_ITAB-INCO1 IS INITIAL.
*            GV_ERROR = 'X'.
*            EXIT.
*          ENDIF.

        WHEN 'ZBO5'.
*          CASE LS_ITAB-TABNAME.
*            WHEN 'A925'.
*              IF LS_ITAB-KBETR IS INITIAL OR
*                 LS_ITAB-KUNNR IS INITIAL OR
*                 LS_ITAB-INCO1 IS INITIAL.
*                GV_ERROR = 'X'.
*                EXIT.
*              ENDIF.
*            WHEN OTHERS.
          IF LS_ITAB-KBETR IS INITIAL .
            GV_ERROR = 'X'.
            EXIT.
          ENDIF.

*          ENDCASE.


*        WHEN 'ZBO6'.
*
*          IF LS_ITAB-KBETR IS INITIAL OR
*             LS_ITAB-AUBEL IS INITIAL OR
*             LS_ITAB-AUPOS IS INITIAL.
*            GV_ERROR = 'X'.
*            EXIT.
*          ENDIF.
*
*        WHEN 'ZBO7'.
*
*          IF LS_ITAB-NEW = 'X'.
*            IF LS_ITAB-KBETR IS INITIAL OR
*               LS_ITAB-KONWA IS INITIAL OR
*               LS_ITAB-AUBEL IS INITIAL OR
*               LS_ITAB-AUPOS IS INITIAL OR
*               LS_ITAB-KPEIN IS INITIAL OR
*               LS_ITAB-KMEIN IS INITIAL.
*              GV_ERROR = 'X'.
*              EXIT.
*            ENDIF.
*          ELSE.
*            IF LS_ITAB-KBETR IS INITIAL OR
*               LS_ITAB-AUBEL IS INITIAL OR
*               LS_ITAB-AUPOS IS INITIAL OR
*               LS_ITAB-KPEIN IS INITIAL OR
*               LS_ITAB-KMEIN IS INITIAL.
*              GV_ERROR = 'X'.
*              EXIT.
*            ENDIF.
*          ENDIF.

      ENDCASE.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATE_VALUE_VALIDATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ERR
*&---------------------------------------------------------------------*
FORM CHECK_DATE_VALUE_VALIDATION  USING    PV_ERR.

*{ SRM2402-10021 - s 유효기간 제한 로직 주석처리
*  DATA(lv_date) =  CONV d( |{ sy-datum+0(4) + 1 }1231| ). "유효기간은 내년 12월31일까지
*
*  IF gs_header-datbi > lv_date.
*    MESSAGE s001 WITH TEXT-e30 DISPLAY LIKE 'E'.
*    pv_err = 'X'.
*    EXIT.
*  ENDIF.
*} SRM2402-10021 - e

  IF GS_HEADER-DATAB IS NOT INITIAL AND
     GS_HEADER-DATBI IS NOT INITIAL.

    IF GS_HEADER-DATAB > GS_HEADER-DATBI.

      PV_ERR = 'X'.
      MESSAGE S207 DISPLAY LIKE 'E'.
      EXIT.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALUE_VALIDATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ERR
*&---------------------------------------------------------------------*
FORM VALUE_VALIDATION  USING    PV_ERR.

  IF GT_ITAB IS NOT INITIAL.
    DELETE GT_HIST WHERE KSCHL = VALUE #( GT_ITAB[ 1 ]-KSCHL OPTIONAL ).
    GT_HIST = VALUE #( BASE GT_HIST FOR LS_ITAB8 IN GT_ITAB
                      ( CORRESPONDING #( LS_ITAB8 )  ) ).
  ENDIF.

  PERFORM CHECK_EMPTY_VALUE .

  IF GV_ERROR = 'X'.

    PV_ERR = 'X'.
    MESSAGE S001 WITH TEXT-E07 DISPLAY LIKE 'E'.
    EXIT.

  ENDIF.

  IF GT_HIST IS INITIAL.

    PV_ERR = 'X'.
    MESSAGE S001 WITH TEXT-E08 DISPLAY LIKE 'E'.
    EXIT.

  ENDIF.

  PERFORM CHECK_DATE_VALUE_VALIDATION USING PV_ERR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RECOVER_VALUE_KOBOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RECOVER_VALUE_KOBOG .

*  IF GS_COPY-KOBOG IS INITIAL.
*    GS_HEADER-KOBOG = 'ZBO1'.
*  ELSE.
*    GS_HEADER-KOBOG = GS_COPY-KOBOG.
*  ENDIF.

  GS_HEADER-A925 = GS_COPY-A925.
  GS_HEADER-A928 = GS_COPY-A928.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form POPUP_TO_DISPLAY_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM POPUP_TO_DISPLAY_TEXT  USING PV_TITLE
                                  PV_TEXT1.

  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
    EXPORTING
      TITEL        = PV_TITLE
      TEXTLINE1    = PV_TEXT1
*     TEXTLINE2    = PV_TEXT2
      START_COLUMN = 25
      START_ROW    = 6.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ATTACHMENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ATTACHMENT .

  CHECK GS_HEADER-KNUMA IS NOT INITIAL.

  DATA:
    LV_MODE   TYPE C LENGTH 1,
    LS_OBJECT TYPE SIBFLPORB.

  LS_OBJECT-INSTID = GS_HEADER-KNUMA.
  LS_OBJECT-TYPEID = 'ZSD_ZKONA'.
  LS_OBJECT-CATID = 'BO'.

  IF SY-TCODE EQ GC_ZVBO3.
    LV_MODE = 'D'.
  ELSE.
    LV_MODE = 'E'.
  ENDIF.

  CALL FUNCTION 'GOS_ATTACHMENT_LIST_POPUP'
    EXPORTING
      IS_OBJECT = LS_OBJECT
      IP_MODE   = LV_MODE.

*- CCM : 24.11.2023 11:00:08 / ZLSGSD4
* 커미션 승인 이후, 영업팀에서 zvbo2로 첨부파일 등록 시 commit work.
*  IF GV_APRV_STAT = 'C' AND SY-TCODE = 'ZVBO2'
*                        AND LV_MODE = 'E'.
  IF SY-TCODE EQ GC_ZVBO2 AND LV_MODE = 'E'.
    COMMIT WORK  AND WAIT.
  ENDIF.
*<-

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DUPLICATE_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CHECK_DUPLICATE_ITEM  USING    PV_AUSFU
                                    PV_KUNNR
                                    PV_MATNR
                                    PV_PRODH
                                    PV_INCO1
                                    PV_AUBEL
                                    PV_AUPOS
                                    PV_ER.

  DATA : LV_VAKEY TYPE ZKONA_ITEM-VAKEY.

*  IF GS_ITAB-KSCHL = 'ZBO1'.
*
*    LV_VAKEY = |{ GS_ITAB-KSCHL }{ GS_ORG-VKORG }{ GS_ORG-VTWEG }{ GS_ORG-SPART }{ GS_ITAB-AUSFU }{ PV_KUNNR }{ PV_MATNR }|.
*
*  ELSEIF GS_ITAB-KSCHL = 'ZBO2'.
*
*    LV_VAKEY = |{ GS_ITAB-KSCHL }{ GS_ORG-VKORG }{ GS_ORG-VTWEG }{ GS_ORG-SPART }{ GS_ITAB-AUSFU }{ PV_KUNNR }{ PV_PRODH }|.
*
*  ELSEIF GS_ITAB-KSCHL = 'ZBO3'.
*
*    LV_VAKEY = |{ GS_ITAB-KSCHL }{ GS_ORG-VKORG }{ GS_ORG-VTWEG }{ GS_ORG-SPART }{ GS_ITAB-AUSFU }{ PV_KUNNR }{ PV_MATNR }{ PV_INCO1 }|.
*
*  ELSEIF GS_ITAB-KSCHL = 'ZBO4'.
*
*    LV_VAKEY = |{ GS_ITAB-KSCHL }{ GS_ORG-VKORG }{ GS_ORG-VTWEG }{ GS_ORG-SPART }{ GS_ITAB-AUSFU }{ PV_KUNNR }{ PV_PRODH }{ PV_INCO1 }|.
*
*  ELSEIF GS_ITAB-KSCHL = 'ZBO5'.

  LV_VAKEY = |{ GS_ITAB-KSCHL }{ GS_ORG-VKORG }{ GS_ORG-VTWEG }{ GS_ORG-SPART }{ GS_ITAB-AUSFU }|.

*  ELSEIF GS_ITAB-KSCHL = 'ZBO6'.
*
*    LV_VAKEY = |{ GS_ITAB-KSCHL }{ GS_ORG-VKORG }{ GS_ORG-VTWEG }{ GS_ORG-SPART }{ GS_ITAB-AUSFU }{ PV_AUBEL }{ PV_AUPOS }|.
*
*  ELSEIF GS_ITAB-KSCHL = 'ZBO7'.
*
*    LV_VAKEY = |{ GS_ITAB-KSCHL }{ GS_ORG-VKORG }{ GS_ORG-VTWEG }{ GS_ORG-SPART }{ GS_ITAB-AUSFU }{ PV_AUBEL }{ PV_AUPOS }|.
*
*  ENDIF.

  CONCATENATE '%' LV_VAKEY INTO LV_VAKEY.

  SELECT SINGLE A~KNUMA
    INTO @DATA(LV_DUPLI)      "중복 데이터 체크
    FROM ZKONA AS A
         INNER JOIN ZKONA_ITEM AS B
                 ON A~KNUMA = B~KNUMA
    WHERE A~BOSTA <> 'E'
      AND A~DATAB <= @GS_HEADER-DATBI
      AND A~DATBI >= @GS_HEADER-DATAB
      AND A~KNUMA <> @GS_HEADER-KNUMA
      AND B~VAKEY LIKE @LV_VAKEY
      AND B~LOEVM <> 'X'.

  IF SY-SUBRC = 0.

    GS_HEADER-DATAB = GS_COPY-DATAB.
    GS_HEADER-DATBI = GS_COPY-DATBI.

    PV_ER = 'X'.
    MESSAGE E002 WITH LV_DUPLI TEXT-E39 .

    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_KSCHL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DISPLAY_KSCHL .

  CALL SCREEN 0600  STARTING AT 90 15
                    ENDING AT 160 22.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_KSCHL_COUNT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_KSCHL_COUNT .

  DATA LV_COUNT TYPE I.

  SELECT DISTINCT A~KSCHL, C~VTEXT,
                  B~KVEWE && B~KOTABNR AS TABNAME
    INTO TABLE @GT_KSCHL
    FROM T685 AS A
        INNER JOIN T682I AS B
                ON A~KOZGF = B~KOZGF
               AND A~KVEWE = B~KVEWE
               AND A~KAPPL = B~KAPPL
        INNER JOIN T685T AS C
                ON C~SPRAS = '3'
               AND A~KVEWE = C~KVEWE
               AND A~KAPPL = C~KAPPL
               AND A~KSCHL = C~KSCHL
   WHERE
*      A~KSCHL = 'ZBO1'
*      OR A~KSCHL = 'ZBO2'
*      OR A~KSCHL = 'ZBO3'
*      OR A~KSCHL = 'ZBO4'
       A~KSCHL = 'ZBO5'
*      OR A~KSCHL = 'ZBO6'
*      OR A~KSCHL = 'ZBO7'
   ORDER BY A~KSCHL.

  LOOP AT GT_KSCHL INTO GS_KSCHL.

    SELECT SINGLE DDTEXT
      FROM DD02T
      INTO GS_KSCHL-DDTEXT
     WHERE TABNAME = GS_KSCHL-TABNAME
       AND DDLANGUAGE = SY-LANGU.

    IF GS_KSCHL-KSCHL EQ GS_HEADER-KOBOG.
      IF GS_KSCHL-TABNAME EQ GS_HEADER-TABNAME.
        LOOP AT GT_ITAB INTO GS_ITAB WHERE KSCHL = GS_KSCHL-KSCHL
                                       AND TABNAME = GS_KSCHL-TABNAME.
          LV_COUNT = LV_COUNT + 1.
        ENDLOOP.

      ELSE.
        LOOP AT GT_HIST INTO GS_ITAB WHERE KSCHL = GS_KSCHL-KSCHL
                                       AND TABNAME = GS_KSCHL-TABNAME.
          LV_COUNT = LV_COUNT + 1.
        ENDLOOP.
      ENDIF.

    ELSE.

*      LOOP AT GT_HIST INTO GS_ITAB WHERE KSCHL = GS_KSCHL-KSCHL.
*        LV_COUNT = LV_COUNT + 1.
*      ENDLOOP.

    ENDIF.

    GS_KSCHL-COUNT = LV_COUNT.

    MODIFY GT_KSCHL FROM GS_KSCHL.
    CLEAR LV_COUNT.

  ENDLOOP.
*  LOOP AT GT_KSCHL INTO GS_KSCHL.
*
*    SELECT SINGLE DDTEXT
*      FROM DD02T
*      INTO GS_KSCHL-DDTEXT
*     WHERE TABNAME = GS_KSCHL-TABNAME
*       AND DDLANGUAGE = SY-LANGU.
*
*    IF GS_KSCHL-KSCHL EQ GS_HEADER-KOBOG.
*
*      LOOP AT GT_ITAB INTO GS_ITAB WHERE KSCHL = GS_KSCHL-KSCHL.
*        LV_COUNT = LV_COUNT + 1.
*      ENDLOOP.
*
*    ELSE.
*
*      LOOP AT GT_HIST INTO GS_ITAB WHERE KSCHL = GS_KSCHL-KSCHL.
*        LV_COUNT = LV_COUNT + 1.
*      ENDLOOP.
*
*    ENDIF.
*
*    GS_KSCHL-COUNT = LV_COUNT.
*
*    MODIFY GT_KSCHL FROM GS_KSCHL.
*    CLEAR LV_COUNT.
*
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DISPLAY_DATA .

  CALL METHOD GRID2->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      I_SAVE                        = 'A'
      I_DEFAULT                     = 'X'
      IS_LAYOUT                     = GS_LAYOUT2
      IT_TOOLBAR_EXCLUDING          = GT_EXCLUDE
    CHANGING
      IT_OUTTAB                     = GT_KSCHL
      IT_FIELDCATALOG               = GT_FIELDCAT2
*     IT_SORT                       = GT_SORT
*     IT_FILTER                     =
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_CONTROLS2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CREATE_CONTROLS2 .

  CREATE OBJECT G_CUSTOM_CONTAINER2
    EXPORTING
      CONTAINER_NAME = G_CON2.

  CREATE OBJECT GRID2
    EXPORTING
      I_PARENT = G_CUSTOM_CONTAINER2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_ALYOUT2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM ALV_ALYOUT2 .

  GS_LAYOUT2-SEL_MODE   = 'A'.
  GS_LAYOUT2-ZEBRA      = 'X'.
  GS_LAYOUT2-CWIDTH_OPT = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIELDCAT_INIT2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM FIELDCAT_INIT2 .

  GS_FIELDCAT2-FIELDNAME = 'KSCHL'.
  GS_FIELDCAT2-COLTEXT   = TEXT-F01.
  GS_FIELDCAT2-JUST       = 'C'.
  APPEND GS_FIELDCAT2 TO GT_FIELDCAT2.
  CLEAR GS_FIELDCAT2.

  GS_FIELDCAT2-FIELDNAME = 'VTEXT'.
  GS_FIELDCAT2-COLTEXT   = TEXT-F21.
  APPEND GS_FIELDCAT2 TO GT_FIELDCAT2.
  CLEAR GS_FIELDCAT2.

  GS_FIELDCAT2-FIELDNAME = 'DDTEXT'.
  GS_FIELDCAT2-COLTEXT   = TEXT-F22.
  APPEND GS_FIELDCAT2 TO GT_FIELDCAT2.
  CLEAR GS_FIELDCAT2.

  GS_FIELDCAT2-FIELDNAME = 'COUNT'.
  GS_FIELDCAT2-COLTEXT   = TEXT-F23.
  GS_FIELDCAT2-JUST       = 'C'.
  APPEND GS_FIELDCAT2 TO GT_FIELDCAT2.
  CLEAR GS_FIELDCAT2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_gt_itab_status
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_GT_ITAB_STATUS .

  LOOP AT GT_ITAB INTO DATA(LS_ITAB).
    IF LS_ITAB-LOEVM = 'X'.
      LS_ITAB-ICON = '@11@'.
    ENDIF.
    MODIFY GT_ITAB FROM LS_ITAB.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form dequeue_knuma
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DEQUEUE_KNUMA .

  CALL FUNCTION 'DEQUEUE_EVKONAE'
    EXPORTING
      KNUMA = GV_KNUMA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_change_doc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SAVE_CHANGE_DOC TABLES PT_ZKONA_ITEM STRUCTURE ZKONA_ITEM
                     USING  PV_TYP.

  DATA: LV_OBJECTID        TYPE CDHDR-OBJECTID,
        LV_TCODE           TYPE CDHDR-TCODE,
        LV_CDOC_UPD_OBJECT TYPE CDHDR-CHANGE_IND,
        LV_UPD_ICDTXT      TYPE CHAR1,
        LT_CDTXT           TYPE STANDARD TABLE OF CDTXT
                           INITIAL SIZE 0.

  CLEAR XZKONA_ITEM.
  REFRESH XZKONA_ITEM.

  " I - 생성, U - 변경
  LV_CDOC_UPD_OBJECT = PV_TYP.

  IF PV_TYP = 'U'. "변경

    LOOP AT PT_ZKONA_ITEM.
      CLEAR XZKONA_ITEM.
      MOVE-CORRESPONDING PT_ZKONA_ITEM TO XZKONA_ITEM.
      XZKONA_ITEM-KZ = LV_CDOC_UPD_OBJECT.
      APPEND XZKONA_ITEM.
    ENDLOOP.

  ELSEIF PV_TYP = 'I'. "생성
    XZKONA = YZKONA.
    XZKONA_ITEM[] = YZKONA_ITEM[].
  ENDIF.

  LV_OBJECTID = GS_HEADER-KNUMA.
  LV_TCODE    = SY-TCODE.

  CALL FUNCTION 'ZKONACHDOC_WRITE_DOCUMENT'
    EXPORTING
      OBJECTID          = LV_OBJECTID
      TCODE             = LV_TCODE
      UTIME             = SY-UZEIT
      UDATE             = SY-DATUM
      USERNAME          = SY-UNAME
      N_ZKONA           = YZKONA "변경 후
      O_ZKONA           = XZKONA "변경 전
      UPD_ZKONA         = LV_CDOC_UPD_OBJECT
      UPD_ZKONA_ITEM    = LV_CDOC_UPD_OBJECT
    TABLES
      ICDTXT_ZKONACHDOC = LT_CDTXT
      XZKONA_ITEM       = XZKONA_ITEM   "변경 후
      YZKONA_ITEM       = YZKONA_ITEM.  "변경 전

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_APPROVER_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_APPROVER_INFO .

  CLEAR GS_APPROVER.

* 해당 커미션 번호로 생성된 마지막 승인요청번호 대상
  SELECT SINGLE MAX( A~ZV4REQNO )
    INTO @DATA(LV_ZV4REQNO)
    FROM ZSDT0620 AS A
   INNER JOIN ZSDT0630 AS B
      ON A~ZV4REQNO  EQ B~ZV4REQNO
   WHERE A~CON_TYPE  EQ 'V6'    "커미션
     AND A~APRV_STAT NOT IN ('D', 'R') "삭제, 반려는 제외
     AND B~VBELN     EQ @GS_HEADER-KNUMA.


*__계약 상태가 릴리즈되어있지 않고, 진행중이 승인요청번호가 없는 경우
*__ZSD1V2000에 등록되어있는 승인자 보여줌
  IF GS_HEADER-BOSTA NE 'B' AND LV_ZV4REQNO IS INITIAL.

    GS_APPROVER-UNAME1 = SY-UNAME.

    SELECT SINGLE ENAME
           FROM ZZPA0001
           INTO GS_APPROVER-SNAME1
           WHERE PERNR = SY-UNAME.

    IF GS_APPROVER-SNAME1 IS INITIAL.
      SELECT SINGLE NAME_TEXT
        INTO GS_APPROVER-SNAME1
        FROM ADRP AS A
       INNER JOIN USR21 AS B
          ON A~PERSNUMBER EQ B~PERSNUMBER
       WHERE B~BNAME EQ SY-UNAME.
    ENDIF.

    SELECT ZNUMC, PERNR, SNAME
      INTO TABLE @DATA(LT_APP1)
      FROM ZSD0105T
      WHERE VKORG  = @GS_ORG-VKORG
        AND VTWEG  = @GS_ORG-VTWEG
        AND SPART  = @GS_ORG-SPART
        AND VKBUR  = @GS_ORG-VKBUR
        AND ZAUART = 'V6'.

    IF LT_APP1[] IS NOT INITIAL.
      LOOP AT LT_APP1 INTO DATA(LS_APP1).
        CASE LS_APP1-ZNUMC.

          WHEN '01'. "1차수 승인자
            GS_APPROVER-UNAME2 = LS_APP1-PERNR.
            GS_APPROVER-SNAME2 = LS_APP1-SNAME.

          WHEN '02'. "2차수 승인자
            GS_APPROVER-UNAME3 = LS_APP1-PERNR.
            GS_APPROVER-SNAME3 = LS_APP1-SNAME.

          WHEN '03'. "3차수 승인자
            GS_APPROVER-UNAME4 = LS_APP1-PERNR.
            GS_APPROVER-SNAME4 = LS_APP1-SNAME.

        ENDCASE.
      ENDLOOP.
    ENDIF.

*__ 승인요청번호가 있을 경우 승인요청 때 생성된 승인자 정보를 보여줌
  ELSEIF LV_ZV4REQNO IS NOT INITIAL.

    GS_APPROVER-ZV4REQNO = LV_ZV4REQNO.

    SELECT ZNUMC, UNAME, SNAME, ZAPPRV
      INTO TABLE @DATA(LT_APP2)
      FROM ZSDT0630
     WHERE ZV4REQNO EQ @LV_ZV4REQNO.

    IF LT_APP2[] IS NOT INITIAL.
      LOOP AT LT_APP2 INTO DATA(LS_APP2).

        CASE LS_APP2-ZNUMC.

          WHEN '00'.
            GS_APPROVER-UNAME1  = LS_APP2-UNAME.
            GS_APPROVER-SNAME1  = LS_APP2-SNAME.
            PERFORM GET_ICON USING : LS_APP2-ZAPPRV
                                     GS_APPROVER-ICON1.

          WHEN '01'. "1차수 승인자
            GS_APPROVER-UNAME2 = LS_APP2-UNAME.
            GS_APPROVER-SNAME2 = LS_APP2-SNAME.
            PERFORM GET_ICON USING : LS_APP2-ZAPPRV
                                     GS_APPROVER-ICON2.

          WHEN '02'. "2차수 승인자
            GS_APPROVER-UNAME3 = LS_APP2-UNAME.
            GS_APPROVER-SNAME3 = LS_APP2-SNAME.
            PERFORM GET_ICON USING : LS_APP2-ZAPPRV
                                     GS_APPROVER-ICON3.

          WHEN '03'. "3차수 승인자
            GS_APPROVER-UNAME4 = LS_APP2-UNAME.
            GS_APPROVER-SNAME4 = LS_APP2-SNAME.
            PERFORM GET_ICON USING : LS_APP2-ZAPPRV
                                     GS_APPROVER-ICON4.
        ENDCASE.
      ENDLOOP.
    ENDIF.

    IF GS_0620-ZNUMC EQ '01'.
      PERFORM GET_ICON USING : 'P'
                               GS_APPROVER-ICON2.

    ELSEIF GS_0620-ZNUMC EQ '02'.
      PERFORM GET_ICON USING : 'P'
                               GS_APPROVER-ICON3.

    ELSEIF GS_0620-ZNUMC EQ '03'.
      PERFORM GET_ICON USING : 'P'
                               GS_APPROVER-ICON4.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_TEXT USING PV_NUM.

  DATA: LT_LINES  TYPE TLINE OCCURS 0 WITH HEADER LINE,
        LT_TEMP   TYPE TLINE OCCURS 0 WITH HEADER LINE,
        LT_TEXT   TYPE TABLE OF TDLINE,
        LV_TDNAME TYPE THEAD-TDNAME,
        LV_MODI   TYPE I,
        LV_TDID   TYPE THEAD-TDID.

  CASE PV_NUM.
    WHEN '0'. "기안자
      CONCATENATE GS_HEADER-KNUMA '0000000000' '00'
             INTO LV_TDNAME.
      LV_TDID = 'Z000'.
    WHEN '1'. "1차 승인자
      CONCATENATE GS_HEADER-KNUMA GS_APPROVER-ZV4REQNO '01'
             INTO LV_TDNAME.
      LV_TDID = 'Z001'.
    WHEN '2'. "2차 승인자
      CONCATENATE GS_HEADER-KNUMA GS_APPROVER-ZV4REQNO '02'
             INTO LV_TDNAME.
      LV_TDID = 'Z002'.
    WHEN '3'. "3차 승인자
      CONCATENATE GS_HEADER-KNUMA GS_APPROVER-ZV4REQNO '03'
             INTO LV_TDNAME.
      LV_TDID = 'Z003'.
  ENDCASE.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      CLIENT                  = SY-MANDT
      ID                      = LV_TDID
      LANGUAGE                = SY-LANGU
      NAME                    = LV_TDNAME
      OBJECT                  = 'ZKNUMA'
    TABLES
      LINES                   = LT_TEMP
    EXCEPTIONS
      ID                      = 1
      LANGUAGE                = 2
      NAME                    = 3
      NOT_FOUND               = 4
      OBJECT                  = 5
      REFERENCE_CHECK         = 6
      WRONG_ACCESS_TO_ARCHIVE = 7.

  LT_TEXT = VALUE #( FOR WA_TEMP IN LT_TEMP
                   ( WA_TEMP-TDLINE ) ).

  G_EDITOR->SET_TEXT_AS_R3TABLE(
    EXPORTING
      TABLE = LT_TEXT ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LONGTEXT_TABLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_LONGTEXT_TABLE  USING  P_VAR.

  G_EDITOR->SET_READONLY_MODE(
    EXPORTING
      READONLY_MODE          = P_VAR
    EXCEPTIONS
      ERROR_CNTL_CALL_METHOD = 1
      INVALID_PARAMETER      = 2
      OTHERS                 = 3 ).

  G_EDITOR->SET_TOOLBAR_MODE(
    EXPORTING
      TOOLBAR_MODE = 0 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_long_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SAVE_LONG_TEXT USING PV_NUM.

  DATA: LT_LINES  TYPE TLINE OCCURS 0 WITH HEADER LINE,
        LT_TEMP   TYPE TLINE OCCURS 0 WITH HEADER LINE,
        LT_TEXT   TYPE TABLE OF TDLINE,
        LS_HEADER LIKE THEAD,
        LV_MODI   TYPE I,
        LV_TDNAME TYPE THEAD-TDNAME,
        LV_TDID   TYPE THEAD-TDID.


  CASE PV_NUM.
    WHEN '0'. "기안자
      CONCATENATE GS_HEADER-KNUMA '0000000000' '00'
            INTO LV_TDNAME.
      LV_TDID = 'Z000'.

      IF LV_MODI <> 1.
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            CLIENT                  = SY-MANDT
            ID                      = LV_TDID
            LANGUAGE                = SY-LANGU
            NAME                    = LV_TDNAME
            OBJECT                  = 'ZKNUMA'
          TABLES
            LINES                   = LT_TEMP
          EXCEPTIONS
            ID                      = 1
            LANGUAGE                = 2
            NAME                    = 3
            NOT_FOUND               = 4
            OBJECT                  = 5
            REFERENCE_CHECK         = 6
            WRONG_ACCESS_TO_ARCHIVE = 7.

        LT_TEXT = VALUE #( FOR WA_TEMP IN LT_TEMP
                         ( WA_TEMP-TDLINE ) ).

        G_EDITOR->SET_TEXT_AS_R3TABLE(
          EXPORTING
            TABLE = LT_TEXT ).
        IF LT_TEXT[] IS NOT INITIAL.
          LV_MODI = 1.

        ENDIF.
      ENDIF.

    WHEN '1'. "1차 승인자
      CONCATENATE GS_HEADER-KNUMA GS_0620-ZV4REQNO '01'
             INTO LV_TDNAME.
      LV_TDID = 'Z001'.
    WHEN '2'. "2차 승인자
      CONCATENATE GS_HEADER-KNUMA GS_0620-ZV4REQNO '02'
             INTO LV_TDNAME.
      LV_TDID = 'Z002'.
    WHEN '3'. "3차 승인자
      CONCATENATE GS_HEADER-KNUMA GS_0620-ZV4REQNO '03'
             INTO LV_TDNAME.
      LV_TDID = 'Z003'.
  ENDCASE.

  LS_HEADER-TDOBJECT = 'ZKNUMA'.
  LS_HEADER-TDID     = LV_TDID.
  LS_HEADER-TDSPRAS  = 3.
  LS_HEADER-TDNAME   = LV_TDNAME.

  IF   GV_ZSA1 = ' '.
    G_EDITOR->GET_TEXT_AS_R3TABLE(
      EXPORTING
        ONLY_WHEN_MODIFIED = CL_GUI_TEXTEDIT=>TRUE
      IMPORTING
        TABLE       = LT_TEXT
        IS_MODIFIED = LV_MODI   "수정된 값이 있으면 체크됨
      EXCEPTIONS
        OTHERS = 1 ).


    IF LV_MODI <> 1.
      EXIT.
    ENDIF.

    LT_LINES[] = VALUE #( FOR WA_LINES IN LT_TEXT
                        ( TDLINE = WA_LINES ) ).

  ELSE.
    IMPORT LT_LINES FROM DATABASE INDX(AB) ID 'LT_LINES'.

  ENDIF.

  IF LT_LINES[] IS  INITIAL.
    EXIT.
  ENDIF.



  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      HEADER = LS_HEADER
    TABLES
      LINES  = LT_LINES[].

  IF SY-SUBRC = 0.
    GV_LONG = 'S'.   "첨언 저장 시 ZLONGID Update 를 위한 Flag
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_longtext
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM DISPLAY_LONGTEXT .

  DATA : LV_CHA.

  LV_CHA = SY-UCOMM+7(1).
  PERFORM GET_TEXT USING LV_CHA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_icon
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_ICON  USING PV_APPRV PV_ICON.

  DATA LV_NAME TYPE ICON-NAME.

  IF PV_APPRV EQ 'Y'.
    LV_NAME = 'ICON_OKAY'.
  ELSEIF PV_APPRV EQ 'P'.
    LV_NAME = 'ICON_NEXT_STEP'.
  ENDIF.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      NAME                  = LV_NAME
    IMPORTING
      RESULT                = PV_ICON
    EXCEPTIONS
      ICON_NOT_FOUND        = 1
      OUTPUTFIELD_TOO_SHORT = 2
      OTHERS                = 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_commission_zvbo6
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SAVE_COMMISSION_ZVBO6 .

  DATA : LV_ERROR(1),
         LS_OLD      TYPE ZKONA,
         LT_NEW      TYPE TABLE OF ZKONA.

  CLEAR : GT_BDCDATA, GT_BDCDATA[],
          GT_MESSAGE, GT_MESSAGE[].

*- 계약 상태를 확인해서 처리
  CASE GS_HEADER-BOSTA.
    WHEN 'B'.               "마스터 활성화
      PERFORM ACTIVATE_VK12 USING LV_ERROR.

    WHEN OTHERS.           "마스터 삭제 처리
      PERFORM DEACTIVATE_VK12 USING LV_ERROR.

  ENDCASE.

  IF GV_LOG = 'X' AND LV_ERROR IS INITIAL.

    CLEAR LS_OLD.

    SELECT SINGLE *
      INTO CORRESPONDING FIELDS OF LS_OLD
      FROM ZKONA
      WHERE KNUMA = GS_HEADER-KNUMA.

    IF SY-SUBRC = 0.
      LS_OLD-WAERS = GS_LOG-WAERS_N.
      LS_OLD-ABSPZ = GS_LOG-ABSPZ_N.
      LS_OLD-BOSTA = GS_LOG-BOSTA_N.
      LS_OLD-DATAB = GS_LOG-DATAB_N.
      LS_OLD-DATBI = GS_LOG-DATBI_N.
      LS_OLD-AENAM = GS_LOG-AENAM.
      LS_OLD-AEDAT = GS_LOG-AEDAT.
      LS_OLD-AEZET = GS_LOG-AEZET.
    ENDIF.

    APPEND LS_OLD TO LT_NEW.

    MODIFY ZKONA FROM TABLE LT_NEW.
    IF SY-SUBRC = 0.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
      MESSAGE I001
      WITH '계약의 헤더 정보를 저장하는 것에 실패하였습니다!'
      DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.
    INSERT ZKONA_LOG FROM GS_LOG.

    IF SY-SUBRC = 0.
      COMMIT WORK.
      MESSAGE I001
         WITH '커미션 및 조건 유형 수정, 변경 내역 저장이 완료되었습니다.'.
      LEAVE TO SCREEN 0.

    ELSE.
      ROLLBACK WORK.
      MESSAGE I002
         WITH '커미션 계약과 조건유형의 수정은 성공했으나 변경 내역 저장에 실패하였습니다.'
              '동일 현상 반복 시 LS ITC에 문의해주세요!'
         DISPLAY LIKE 'E'.
      LEAVE TO SCREEN 0.
    ENDIF.

  ELSE.
    MESSAGE I001
       WITH '커미션 계약 및 조건 유형 수정에 실패하였습니다.'
            '동일 현상 반복 시 LS ITC에 문의해주세요!'
       DISPLAY LIKE 'E'.
    LEAVE TO SCREEN 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_changed_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_CHANGED_LOG .

  DATA : LT_LOG      LIKE ZKONA_LOG OCCURS 0,
         LS_LOG_FCAT TYPE SLIS_FIELDCAT_ALV,
         LT_LOG_FCAT TYPE SLIS_T_FIELDCAT_ALV.

  DEFINE _FIELD_CAT.
    LS_LOG_FCAT-FIELDNAME = &1.
    LS_LOG_FCAT-SELTEXT_L = &2.
    LS_LOG_FCAT-SELTEXT_M = &2.
    LS_LOG_FCAT-SELTEXT_S = &2.
    APPEND LS_LOG_FCAT TO LT_LOG_FCAT.
    CLEAR LS_LOG_FCAT.
  END-OF-DEFINITION.

  CLEAR : LT_LOG, LT_LOG[].

  SELECT ZSEQ,    AENAM,
         AEDAT,   AEZET,
         WAERS_O, WAERS_N,
         DATAB_O, DATAB_N,
         DATBI_O, DATBI_N,
         BOSTA_O, BOSTA_N,
         ABSPZ_O, ABSPZ_N
    INTO CORRESPONDING FIELDS OF TABLE @LT_LOG
    FROM ZKONA_LOG
   WHERE KNUMA = @GS_HEADER-KNUMA
     AND VKORG = @GS_ORG-VKORG
     AND VTWEG = @GS_ORG-VTWEG
     AND SPART = @GS_ORG-SPART
     AND VKBUR = @GS_ORG-VKBUR
     AND VKGRP = @GS_ORG-VKGRP.

  IF LT_LOG[] IS NOT INITIAL.

    SORT LT_LOG[] BY ZSEQ.

    _FIELD_CAT : 'ZSEQ'    'No.',
                 'AENAM'   '변경자',
                 'AEDAT'   '변경일자',
                 'WAERS_O' '통화(전)',
                 'WAERS_N' '통화(후)',
                 'DATAB_O' '효력시작일(전)',
                 'DATAB_N' '효력시작일(후)',
                 'DATBI_O' '유효기간(전)',
                 'DATBI_N' '유효기간(후)',
                 'BOSTA_O' '계약상태(전)',
                 'BOSTA_N' '계약상태(후)',
                 'ABSPZ_O' '검증레벨(전)',
                 'ABSPZ_N' '검증레벨(후)'.

    CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
      EXPORTING
        I_TITLE               = '커미션 헤더 변경 이력 조회'
        I_SELECTION           = ' '
        I_ZEBRA               = 'X'
        I_SCREEN_START_COLUMN = 2
        I_SCREEN_START_LINE   = 1
        I_SCREEN_END_COLUMN   = 185
        I_SCREEN_END_LINE     = 15
        I_TABNAME             = 'LT_LOG'
        IT_FIELDCAT           = LT_LOG_FCAT[]
      TABLES
        T_OUTTAB              = LT_LOG.

  ELSE.

    MESSAGE I001
       WITH '커미션이 ZVBO6에서 권한자에 의해 변경된 기록이 없습니다.'
       DISPLAY LIKE 'E'.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form activate_vk12
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ACTIVATE_VK12 USING PV_ERROR.

  DATA : LV_MESSAGE(220).

  LOOP AT GT_HIST INTO DATA(GS_HIST) WHERE STAT_FLAG = 'Y'.

    CLEAR : GT_BDCDATA, GT_BDCDATA[].

    CASE GS_HIST-KSCHL.

      WHEN 'ZBO1'.

        PERFORM BDC_INPUT USING :
        'SAPMV13A' '0100' 'X' 'RV13A-KSCHL'     GS_HIST-KSCHL,
        '        ' '    ' ' ' 'BDC_OKCODE'      '/00',

        'RV13A921' '1000' 'X' 'F001'            GS_HIST-VKORG,
        '        ' '    ' ' ' 'F002'            GS_HIST-VTWEG,
        '        ' '    ' ' ' 'F003'            GS_HIST-SPART,
        '        ' '    ' ' ' 'F004'            GS_HIST-AUSFU,
        '        ' '    ' ' ' 'F005'            GS_HIST-KUNNR,
        '        ' '    ' ' ' 'F006-LOW'        GS_HIST-MATNR,
        '        ' '    ' ' ' 'SEL_DATE'        GS_HIST-DATAB,
        '        ' '    ' ' ' 'KODELFL'         'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ONLI',

        'SAPMV13A' '1921' 'X' 'RV130-SELKZ(01)' 'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ENRE',

        'SAPMV13A' '1921' 'X' 'BDC_OKCODE'      '=SICH'.

      WHEN 'ZBO2'.

        PERFORM BDC_INPUT USING :
        'SAPMV13A' '0100' 'X' 'RV13A-KSCHL'     GS_HIST-KSCHL,
        '        ' '    ' ' ' 'BDC_OKCODE'      '/00',

        'RV13A922' '1000' 'X' 'F001'            GS_HIST-VKORG,
        '        ' '    ' ' ' 'F002'            GS_HIST-VTWEG,
        '        ' '    ' ' ' 'F003'            GS_HIST-SPART,
        '        ' '    ' ' ' 'F004'            GS_HIST-AUSFU,
        '        ' '    ' ' ' 'F005'            GS_HIST-KUNNR,
        '        ' '    ' ' ' 'F006-LOW'        GS_HIST-PRODH,
        '        ' '    ' ' ' 'SEL_DATE'        GS_HIST-DATAB,
        '        ' '    ' ' ' 'KODELFL'         'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ONLI',

        'SAPMV13A' '1922' 'X' 'RV130-SELKZ(01)' 'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ENRE',

        'SAPMV13A' '1922' 'X' 'BDC_OKCODE'      '=SICH'.

      WHEN 'ZBO3'.
        PERFORM BDC_INPUT USING :
        'SAPMV13A' '0100' 'X' 'RV13A-KSCHL'     GS_HIST-KSCHL,
        '        ' '    ' ' ' 'BDC_OKCODE'      '/00',

        'RV13A923' '1000' 'X' 'F001'            GS_HIST-VKORG,
        '        ' '    ' ' ' 'F002'            GS_HIST-VTWEG,
        '        ' '    ' ' ' 'F003'            GS_HIST-SPART,
        '        ' '    ' ' ' 'F004'            GS_HIST-AUSFU,
        '        ' '    ' ' ' 'F005'            GS_HIST-KUNNR,
        '        ' '    ' ' ' 'F006'            GS_HIST-MATNR,
        '        ' '    ' ' ' 'F007-LOW'        GS_HIST-INCO1,
        '        ' '    ' ' ' 'SEL_DATE'        GS_HIST-DATAB,
        '        ' '    ' ' ' 'KODELFL'         'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ONLI',

        'SAPMV13A' '1923' 'X' 'RV130-SELKZ(01)' 'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ENRE',

        'SAPMV13A' '1923' 'X' 'BDC_OKCODE'      '=SICH'.

      WHEN 'ZBO4'.

        PERFORM BDC_INPUT USING :
        'SAPMV13A' '0100' 'X' 'RV13A-KSCHL'     GS_HIST-KSCHL,
        '        ' '    ' ' ' 'BDC_OKCODE'      '/00',

        'RV13A924' '1000' 'X' 'F001'            GS_HIST-VKORG,
        '        ' '    ' ' ' 'F002'            GS_HIST-VTWEG,
        '        ' '    ' ' ' 'F003'            GS_HIST-SPART,
        '        ' '    ' ' ' 'F004'            GS_HIST-AUSFU,
        '        ' '    ' ' ' 'F005'            GS_HIST-KUNNR,
        '        ' '    ' ' ' 'F006'            GS_HIST-PRODH,
        '        ' '    ' ' ' 'F007-LOW'        GS_HIST-INCO1,
        '        ' '    ' ' ' 'SEL_DATE'        GS_HIST-DATAB,
        '        ' '    ' ' ' 'KODELFL'         'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ONLI',

        'SAPMV13A' '1924' 'X' 'RV130-SELKZ(01)' 'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ENRE',

        'SAPMV13A' '1924' 'X' 'BDC_OKCODE'      '=SICH'.

      WHEN 'ZBO5'.

        PERFORM BDC_INPUT USING :
        'SAPMV13A' '0100' 'X' 'RV13A-KSCHL'     GS_HIST-KSCHL,
        '        ' '    ' ' ' 'BDC_OKCODE'      '/00',

        'RV13A925' '1000' 'X' 'F001'            GS_HIST-VKORG,
        '        ' '    ' ' ' 'F002'            GS_HIST-VTWEG,
        '        ' '    ' ' ' 'F003'            GS_HIST-SPART,
        '        ' '    ' ' ' 'F004'            GS_HIST-AUSFU,
        '        ' '    ' ' ' 'F005'            GS_HIST-KUNNR,
        '        ' '    ' ' ' 'F006-LOW'        GS_HIST-INCO1,
        '        ' '    ' ' ' 'SEL_DATE'        GS_HIST-DATAB,
        '        ' '    ' ' ' 'KODELFL'         'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ONLI',

        'SAPMV13A' '1925' 'X' 'RV130-SELKZ(01)' 'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ENRE',

        'SAPMV13A' '1925' 'X' 'BDC_OKCODE'      '=SICH'.

      WHEN 'ZBO6'.

        PERFORM BDC_INPUT USING :
        'SAPMV13A' '0100' 'X' 'RV13A-KSCHL'     GS_HIST-KSCHL,
        '        ' '    ' ' ' 'BDC_OKCODE'      '/00',

        'RV13A927' '1000' 'X' 'F001'            GS_HIST-VKORG,
        '        ' '    ' ' ' 'F002'            GS_HIST-VTWEG,
        '        ' '    ' ' ' 'F003'            GS_HIST-SPART,
        '        ' '    ' ' ' 'F004'            GS_HIST-AUSFU,
        '        ' '    ' ' ' 'F005'            GS_HIST-AUBEL,
        '        ' '    ' ' ' 'F006-LOW'        GS_HIST-AUPOS,
        '        ' '    ' ' ' 'SEL_DATE'        GS_HIST-DATAB,
        '        ' '    ' ' ' 'KODELFL'         'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ONLI',

        'SAPMV13A' '1927' 'X' 'RV130-SELKZ(01)' 'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ENRE',

        'SAPMV13A' '1927' 'X' 'BDC_OKCODE'      '=SICH'.

      WHEN 'ZBO7'.

        PERFORM BDC_INPUT USING :
        'SAPMV13A' '0100' 'X' 'RV13A-KSCHL'     GS_HIST-KSCHL,
        '        ' '    ' ' ' 'BDC_OKCODE'      '/00',

        'RV13A927' '1000' 'X' 'F001'            GS_HIST-VKORG,
        '        ' '    ' ' ' 'F002'            GS_HIST-VTWEG,
        '        ' '    ' ' ' 'F003'            GS_HIST-SPART,
        '        ' '    ' ' ' 'F004'            GS_HIST-AUSFU,
        '        ' '    ' ' ' 'F005'            GS_HIST-AUBEL,
        '        ' '    ' ' ' 'F006-LOW'        GS_HIST-AUPOS,
        '        ' '    ' ' ' 'SEL_DATE'        GS_HIST-DATAB,
        '        ' '    ' ' ' 'KODELFL'         'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ONLI',

        'SAPMV13A' '1927' 'X' 'RV130-SELKZ(01)' 'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ENRE',

        'SAPMV13A' '1927' 'X' 'BDC_OKCODE'      '=SICH'.

    ENDCASE.

    PERFORM FILL_CTU_PARAMS USING 'N'.

    CALL TRANSACTION 'VK12' USING GT_BDCDATA
                            OPTIONS FROM GS_PARAMS
                            MESSAGES INTO GT_MESSAGE.

    PERFORM MESSAGE_FUNCTION USING GT_MESSAGE LV_MESSAGE.

    READ TABLE GT_MESSAGE WITH KEY MSGTYP = 'E'.

    IF SY-SUBRC = 0.
      PV_ERROR = 'X'.
      PERFORM UPDATE_MESSAGE USING PV_ERROR LV_MESSAGE GS_HIST.


    ELSE.

      READ TABLE GT_MESSAGE INDEX 1.

      IF SY-SUBRC = 0.
        GS_HIST-STAT_FLAG = 'B'.
        PERFORM MESSAGE_FUNCTION USING GT_MESSAGE LV_MESSAGE.

        PERFORM UPDATE_ZKONA_ITEM USING PV_ERROR LV_MESSAGE
                                        'B'      GS_HIST.

      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form deactivate_vk12
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DEACTIVATE_VK12 USING PV_ERROR.

  DATA : LV_MESSAGE(220).

  LOOP AT GT_HIST INTO DATA(GS_HIST) WHERE STAT_FLAG = 'N'.

    CLEAR : GT_BDCDATA, GT_BDCDATA[].

    CASE GS_HIST-KSCHL.

      WHEN 'ZBO1'.
        PERFORM BDC_INPUT USING :
        'SAPMV13A' '0100' 'X' 'RV13A-KSCHL'     GS_HIST-KSCHL,
        '        ' '    ' ' ' 'BDC_OKCODE'      '/00',

        'RV13A921' '1000' 'X' 'F001'            GS_HIST-VKORG,
        '        ' '    ' ' ' 'F002'            GS_HIST-VTWEG,
        '        ' '    ' ' ' 'F003'            GS_HIST-SPART,
        '        ' '    ' ' ' 'F004'            GS_HIST-AUSFU,
        '        ' '    ' ' ' 'F005'            GS_HIST-KUNNR,
        '        ' '    ' ' ' 'F006-LOW'        GS_HIST-MATNR,
        '        ' '    ' ' ' 'SEL_DATE'        GS_HIST-DATAB,
        '        ' '    ' ' ' 'KODELFL'         'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ONLI',

        'SAPMV13A' '1921' 'X' 'RV130-SELKZ(01)' 'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ENTF',

        'SAPMV13A' '1921' 'X' 'BDC_OKCODE'      '=SICH'.

      WHEN 'ZBO2'.

        PERFORM BDC_INPUT USING :
        'SAPMV13A' '0100' 'X' 'RV13A-KSCHL'     GS_HIST-KSCHL,
        '        ' '    ' ' ' 'BDC_OKCODE'      '/00',

        'RV13A922' '1000' 'X' 'F001'            GS_HIST-VKORG,
        '        ' '    ' ' ' 'F002'            GS_HIST-VTWEG,
        '        ' '    ' ' ' 'F003'            GS_HIST-SPART,
        '        ' '    ' ' ' 'F004'            GS_HIST-AUSFU,
        '        ' '    ' ' ' 'F005'            GS_HIST-KUNNR,
        '        ' '    ' ' ' 'F006-LOW'        GS_HIST-PRODH,
        '        ' '    ' ' ' 'SEL_DATE'        GS_HIST-DATAB,
        '        ' '    ' ' ' 'KODELFL'         'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ONLI',

        'SAPMV13A' '1922' 'X' 'RV130-SELKZ(01)' 'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ENTF',

        'SAPMV13A' '1922' 'X' 'BDC_OKCODE'      '=SICH'.

      WHEN 'ZBO3'.
        PERFORM BDC_INPUT USING :
        'SAPMV13A' '0100' 'X' 'RV13A-KSCHL'     GS_HIST-KSCHL,
        '        ' '    ' ' ' 'BDC_OKCODE'      '/00',

        'RV13A923' '1000' 'X' 'F001'            GS_HIST-VKORG,
        '        ' '    ' ' ' 'F002'            GS_HIST-VTWEG,
        '        ' '    ' ' ' 'F003'            GS_HIST-SPART,
        '        ' '    ' ' ' 'F004'            GS_HIST-AUSFU,
        '        ' '    ' ' ' 'F005'            GS_HIST-KUNNR,
        '        ' '    ' ' ' 'F006'            GS_HIST-MATNR,
        '        ' '    ' ' ' 'F007-LOW'        GS_HIST-INCO1,
        '        ' '    ' ' ' 'SEL_DATE'        GS_HIST-DATAB,
        '        ' '    ' ' ' 'KODELFL'         'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ONLI',

        'SAPMV13A' '1923' 'X' 'RV130-SELKZ(01)' 'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ENTF',

        'SAPMV13A' '1923' 'X' 'BDC_OKCODE'      '=SICH'.

      WHEN 'ZBO4'.

        PERFORM BDC_INPUT USING :
        'SAPMV13A' '0100' 'X' 'RV13A-KSCHL'     GS_HIST-KSCHL,
        '        ' '    ' ' ' 'BDC_OKCODE'      '/00',

        'RV13A924' '1000' 'X' 'F001'            GS_HIST-VKORG,
        '        ' '    ' ' ' 'F002'            GS_HIST-VTWEG,
        '        ' '    ' ' ' 'F003'            GS_HIST-SPART,
        '        ' '    ' ' ' 'F004'            GS_HIST-AUSFU,
        '        ' '    ' ' ' 'F005'            GS_HIST-KUNNR,
        '        ' '    ' ' ' 'F006'            GS_HIST-PRODH,
        '        ' '    ' ' ' 'F007-LOW'        GS_HIST-INCO1,
        '        ' '    ' ' ' 'SEL_DATE'        GS_HIST-DATAB,
        '        ' '    ' ' ' 'KODELFL'         'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ONLI',

        'SAPMV13A' '1924' 'X' 'RV130-SELKZ(01)' 'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ENTF',

        'SAPMV13A' '1924' 'X' 'BDC_OKCODE'      '=SICH'.

      WHEN 'ZBO5'.

        PERFORM BDC_INPUT USING :
        'SAPMV13A' '0100' 'X' 'RV13A-KSCHL'     GS_HIST-KSCHL,
        '        ' '    ' ' ' 'BDC_OKCODE'      '/00',

        'RV13A925' '1000' 'X' 'F001'            GS_HIST-VKORG,
        '        ' '    ' ' ' 'F002'            GS_HIST-VTWEG,
        '        ' '    ' ' ' 'F003'            GS_HIST-SPART,
        '        ' '    ' ' ' 'F004'            GS_HIST-AUSFU,
        '        ' '    ' ' ' 'F005'            GS_HIST-KUNNR,
        '        ' '    ' ' ' 'F006-LOW'        GS_HIST-INCO1,
        '        ' '    ' ' ' 'SEL_DATE'        GS_HIST-DATAB,
        '        ' '    ' ' ' 'KODELFL'         'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ONLI',

        'SAPMV13A' '1925' 'X' 'RV130-SELKZ(01)' 'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ENTF',

        'SAPMV13A' '1925' 'X' 'BDC_OKCODE'      '=SICH'.

      WHEN 'ZBO6'.

        PERFORM BDC_INPUT USING :
        'SAPMV13A' '0100' 'X' 'RV13A-KSCHL'     GS_HIST-KSCHL,
        '        ' '    ' ' ' 'BDC_OKCODE'      '/00',

        'RV13A927' '1000' 'X' 'F001'            GS_HIST-VKORG,
        '        ' '    ' ' ' 'F002'            GS_HIST-VTWEG,
        '        ' '    ' ' ' 'F003'            GS_HIST-SPART,
        '        ' '    ' ' ' 'F004'            GS_HIST-AUSFU,
        '        ' '    ' ' ' 'F005'            GS_HIST-AUBEL,
        '        ' '    ' ' ' 'F006-LOW'        GS_HIST-AUPOS,
        '        ' '    ' ' ' 'SEL_DATE'        GS_HIST-DATAB,
        '        ' '    ' ' ' 'KODELFL'         'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ONLI',

        'SAPMV13A' '1927' 'X' 'RV130-SELKZ(01)' 'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ENTF',

        'SAPMV13A' '1927' 'X' 'BDC_OKCODE'      '=SICH'.

      WHEN 'ZBO7'.

        PERFORM BDC_INPUT USING :
        'SAPMV13A' '0100' 'X' 'RV13A-KSCHL'     GS_HIST-KSCHL,
        '        ' '    ' ' ' 'BDC_OKCODE'      '/00',

        'RV13A927' '1000' 'X' 'F001'            GS_HIST-VKORG,
        '        ' '    ' ' ' 'F002'            GS_HIST-VTWEG,
        '        ' '    ' ' ' 'F003'            GS_HIST-SPART,
        '        ' '    ' ' ' 'F004'            GS_HIST-AUSFU,
        '        ' '    ' ' ' 'F005'            GS_HIST-AUBEL,
        '        ' '    ' ' ' 'F006-LOW'        GS_HIST-AUPOS,
        '        ' '    ' ' ' 'SEL_DATE'        GS_HIST-DATAB,
        '        ' '    ' ' ' 'KODELFL'         'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ONLI',

        'SAPMV13A' '1927' 'X' 'RV130-SELKZ(01)' 'X',
        '        ' '    ' ' ' 'BDC_OKCODE'      '=ENTF',

        'SAPMV13A' '1927' 'X' 'BDC_OKCODE'      '=SICH'.

    ENDCASE.

    PERFORM FILL_CTU_PARAMS USING 'N'.

    CALL TRANSACTION 'VK12' USING GT_BDCDATA
                            OPTIONS FROM GS_PARAMS
                            MESSAGES INTO GT_MESSAGE.

    PERFORM MESSAGE_FUNCTION USING GT_MESSAGE LV_MESSAGE.

    READ TABLE GT_MESSAGE WITH KEY MSGTYP = 'E'.

    IF SY-SUBRC = 0.

      PERFORM UPDATE_MESSAGE USING PV_ERROR LV_MESSAGE GS_HIST.

    ELSE.

      READ TABLE GT_MESSAGE INDEX 1.

      IF SY-SUBRC = 0.
        GS_HIST-STAT_FLAG = 'D'.
        PERFORM MESSAGE_FUNCTION USING GT_MESSAGE LV_MESSAGE.

        PERFORM UPDATE_ZKONA_ITEM USING PV_ERROR LV_MESSAGE
                                        'D'      GS_HIST.

      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.

FORM CALL_SIMPLE_APPROVAL  USING    P_REQNO.

  CALL FUNCTION 'ZSA1_SD_MAKE_SEND_DATA'
    EXPORTING
      I_ZV4REQNO = P_reqno
      I_BUKRS    = '1000'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_AUTHORITY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_AUTHORITY .
*  DATA:LV_SUBRC TYPE SY-SUBRC.
*
*  CHECK VBAK-VKGRP IS NOT INITIAL.
*
*  CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
*    EXPORTING
*      I_VKGRP = VBAK-VKGRP
*      I_TYPE  = '7'
*    IMPORTING
*      E_SUBRC = LV_SUBRC.
*  IF LV_SUBRC NE 0.
*    GV_ERROR = GC_X.
*    MESSAGE S203(ZGTSD01) WITH VBAK-VKGRP DISPLAY LIKE GC_E.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_TABNAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_TABNAME .
  CASE GC_X.
    WHEN GS_HEADER-A925.
      GS_HEADER-TABNAME = 'A925'.
    WHEN GS_HEADER-A928.
      GS_HEADER-TABNAME = 'A928'.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_BOSTA_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BOSTA_TEXT .

  IF GS_HEADER-BOSTA IS NOT INITIAL.
    SELECT SINGLE DDTEXT
     INTO @GS_TEXT-BOSTA_TX
     FROM DD07V
     WHERE DOMNAME = 'BOSTA'
       AND DDLANGUAGE = '3'
       AND DOMVALUE_L = @GS_HEADER-BOSTA.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPEND_NEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM APPEND_NEW .
  DATA : LV_ERR.
  CLEAR  LV_ERR.

  CHECK SY-TCODE EQ GC_ZVBO1.

*  IF GS_HEADER-BOTEXT IS NOT INITIAL AND
*     GS_HEADER-AUSFU  IS NOT INITIAL AND
*     GS_HEADER-WAERS  IS NOT INITIAL AND
*     GS_HEADER-DATAB  IS NOT INITIAL AND
*     GS_HEADER-DATBI  IS NOT INITIAL.
*  ELSE.
*    MESSAGE S001 WITH TEXT-E02 DISPLAY LIKE 'E'.
*    EXIT.
*  ENDIF.

*  IF GS_HEADER-BOTEXT IS NOT INITIAL AND
*     GS_HEADER-AUSFU  IS NOT INITIAL AND
*     GS_HEADER-WAERS  IS NOT INITIAL AND
*     GS_HEADER-DATAB  IS NOT INITIAL AND
*     GS_HEADER-DATBI  IS NOT INITIAL.
*    PERFORM CHECK_DATE_VALUE_VALIDATION USING LV_ERR.
*    IF LV_ERR = 'X'.
*      EXIT.
*    ENDIF.
*  ELSE.
*    MESSAGE S001 WITH TEXT-E02 DISPLAY LIKE 'E'.
*    EXIT.
*  ENDIF.


  DATA(LV_SIGN) = VALUE #( GT_LIST[ KSCHL = GS_HEADER-KOBOG ]-KRECH OPTIONAL ).
  IF LV_SIGN = 'C'.

    GT_ITAB = VALUE #( BASE GT_ITAB
                     ( KSCHL = GS_HEADER-KOBOG
                       VKORG = GS_ORG-VKORG
                       VTWEG = GS_ORG-VTWEG
                       SPART = GS_ORG-SPART
                       AUSFU = GS_HEADER-AUSFU
                       DATAB = GS_HEADER-DATAB
                       DATBI = GS_HEADER-DATBI
                       KONWA = GS_HEADER-WAERS
                       ICON  = ICON_CREATE
                       STAT_FLAG = 'X'
                       NEW   = 'X'
                       TABNAME = GS_HEADER-TABNAME ) ).
  ELSE.
    GT_ITAB = VALUE #( BASE GT_ITAB
                  ( KSCHL  = GS_HEADER-KOBOG
                    VKORG  = GS_ORG-VKORG
                    VTWEG  = GS_ORG-VTWEG
                    SPART  = GS_ORG-SPART
                    AUSFU  = GS_HEADER-AUSFU
                    DATAB  = GS_HEADER-DATAB
                    DATBI  = GS_HEADER-DATBI
                    KONWA  = '%'
                    ICON   = ICON_CREATE
                    NEW   = 'X'
                    STAT_FLAG = 'X'
                    TABNAME = GS_HEADER-TABNAME ) ).

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_LS_OLD_NEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ERR
*&      --> LS_OLD
*&---------------------------------------------------------------------*
FORM GET_LS_OLD_NEW  USING    PV_ERR
                              PS_OLD TYPE ZKONA.


  SELECT SINGLE *
    INTO @PS_OLD
    FROM ZKONA
   WHERE KNUMA = @GS_HEADER-KNUMA .

  CLEAR XZKONA.


  SELECT SINGLE *
    FROM ZKONA
    INTO YZKONA  "변경 전 헤더
   WHERE KNUMA = GS_HEADER-KNUMA.

  SELECT *
    FROM ZKONA_ITEM
    INTO TABLE YZKONA_ITEM
   WHERE KNUMA = GS_HEADER-KNUMA.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_VK12_DEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ERR
*&      --> LS_OLD_DATAB
*&---------------------------------------------------------------------*
FORM PROCESS_VK12_DEL  USING    PV_ERR PV_DATAB.
  DATA : LV_MESSAGE(220),
         LV_PRICE        TYPE KONV-KBETR,
         LV_KBETR(17).
  DATA: LV_RSLT(1),
        LV_ICON         TYPE ICON-ID,
        LV_STAT_FLAG(1).


  LOOP AT GT_HIST INTO DATA(LS_HIST) WHERE STAT_FLAG <> 'X'.
    SELECT SINGLE A~KNUMH
      FROM A928 AS A INNER JOIN KONP AS B
                     ON A~KNUMH = B~KNUMH
     WHERE A~KSCHL EQ @LS_HIST-KSCHL
       AND A~VKORG EQ @LS_HIST-VKORG
       AND A~VTWEG EQ @LS_HIST-VTWEG
       AND A~SPART EQ @LS_HIST-SPART
       AND A~AUSFU EQ @LS_HIST-AUSFU
       AND A~DATBI >= @PV_DATAB
       AND A~DATAB <= @PV_DATAB
       AND B~LOEVM_KO EQ @SPACE
      INTO @DATA(LV_KNUMH).
    IF SY-SUBRC NE 0.
      CONTINUE.
    ENDIF.

    CLEAR : GT_BDCDATA, GT_BDCDATA[],
            GT_MESSAGE, GT_MESSAGE[],
            LV_MESSAGE.
    CLEAR : LV_ICON,LV_STAT_FLAG,LV_RSLT.

    PERFORM BDC_INPUT USING :
    'SAPMV13A' '0100' 'X' 'RV13A-KSCHL' LS_HIST-KSCHL,
    '        ' '    ' ' ' 'BDC_OKCODE' '=ANTA'.

    "테이블 선택
    PERFORM BDC_INPUT USING :
    'SAPLV14A' '0100' 'X' 'BDC_CURSOR'     'RV130-SELKZ(02)',
    '        ' '    ' ' ' 'RV130-SELKZ(01)' ' ',
    '        ' '    ' ' ' 'RV130-SELKZ(02)' 'X',
    '        ' '    ' ' ' 'BDC_OKCODE'      '=WEIT'.


    PERFORM BDC_INPUT USING :
    'RV13A928' '1000' 'X' 'F001'       LS_HIST-VKORG,
    '        ' '    ' ' ' 'F002'       LS_HIST-VTWEG,
    '        ' '    ' ' ' 'F003'       LS_HIST-SPART,
    '        ' '    ' ' ' 'F004-LOW'   LS_HIST-AUSFU,
    '        ' '    ' ' ' 'SEL_DATE'   PV_DATAB,
    '        ' '    ' ' ' 'KODELFL'    'X',
    '        ' '    ' ' ' 'BDC_OKCODE' '=ONLI'.

    PERFORM BDC_INPUT USING :
    'SAPMV13A' '1928' 'X' 'BDC_OKCODE' '=MARL',  "전체선택
    'SAPMV13A' '1928' 'X' 'BDC_OKCODE' '=ENTF'.  "라인삭제

    PERFORM BDC_INPUT USING :
    'SAPMV13A' '1928' 'X' 'BDC_OKCODE' '=SICH'.

    PERFORM FILL_CTU_PARAMS USING 'N'.

    CALL TRANSACTION 'VK12' USING GT_BDCDATA
                            OPTIONS FROM GS_PARAMS
                            MESSAGES INTO GT_MESSAGE.

    IF LINE_EXISTS( GT_MESSAGE[ MSGTYP = 'S'
                                MSGID  = 'VK' MSGNR = '023' ] ).

      LV_RSLT = GC_S.

      UPDATE ZKONA_ITEM SET LOEVM = GC_X
                        WHERE KNUMA = GS_HEADER-KNUMA
                          AND KSCHL = LS_HIST-KSCHL
                          AND AUSFU = LS_HIST-AUSFU.
      IF SY-SUBRC = 0.
        COMMIT WORK AND WAIT.
      ENDIF.


    ELSE.
      LOOP AT GT_MESSAGE INTO DATA(LS_MSG) WHERE MSGTYP CA 'AE'.
        EXIT.
      ENDLOOP.
      IF SY-SUBRC EQ 0.
        PV_ERR = 'X'.
        LV_RSLT = GC_E.
        LV_ICON = ICON_LED_RED.

        PERFORM MESSAGE_FUNCTION USING LS_MSG LV_MESSAGE.
        LS_HIST-MESSAGE = LV_MESSAGE.

      ELSE.
        LV_RSLT = GC_E.
        LV_ICON = ICON_LED_RED.
        LS_HIST-MESSAGE = |조건 레코드 삭제 중 에러.|.
      ENDIF.

    ENDIF.

    LS_HIST-RSLT    = LV_RSLT.
    LS_HIST-ICON    = LV_ICON.

    MODIFY GT_HIST FROM LS_HIST
           TRANSPORTING ICON MESSAGE RSLT WHERE KSCHL = LS_HIST-KSCHL
                                                      AND AUSFU = LS_HIST-AUSFU.

    MODIFY GT_ITAB FROM LS_HIST
           TRANSPORTING ICON  MESSAGE RSLT WHERE KSCHL = LS_HIST-KSCHL
                                                       AND AUSFU = LS_HIST-AUSFU.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_DELETE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_DOC_DELETE .
  "헤더
  XZKONA = YZKONA.
  XZKONA-BOSTA = 'E'.
  "아이템
  XZKONA_ITEM[] = YZKONA_ITEM[].
  CLEAR XZKONA_ITEM.
  XZKONA_ITEM-LOEVM = GC_X.
  MODIFY XZKONA_ITEM TRANSPORTING LOEVM WHERE KNUMA IS NOT INITIAL.
  PERFORM SAVE_CHANGE_DOC TABLES YZKONA_ITEM
                           USING  'U'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CHAGE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_CHAGE_DATA TABLES PT_ZKONA_ITEM STRUCTURE ZKONA_ITEM
                       USING PS_ZKONA TYPE ZKONA.
  "헤더
  IF YZKONA-BOTEXT EQ PS_ZKONA-BOTEXT AND
     YZKONA-DATAB  EQ PS_ZKONA-DATAB  AND
     YZKONA-DATBI  EQ PS_ZKONA-DATBI.
    CLEAR:GS_CHANGE-H.
  ELSE.
    GS_CHANGE-H = GC_X.
    IF YZKONA-DATAB  EQ PS_ZKONA-DATAB  AND
       YZKONA-DATBI  EQ PS_ZKONA-DATBI.
    ELSE.
      GS_CHANGE-I = GC_X.
    ENDIF.
  ENDIF.

  CHECK GS_CHANGE-I IS INITIAL.
  "아이템
  DATA(LS_ITEM_OLD) = VALUE #( YZKONA_ITEM[ 1 ] OPTIONAL ).
  DATA(LS_ITEM_NEW) = VALUE #( PT_ZKONA_ITEM[ 1 ] OPTIONAL ).
  IF LS_ITEM_OLD-KBETR NE LS_ITEM_NEW-KBETR.
    GS_CHANGE-I = GC_X.
  ENDIF.

  "아이템 조건레코드 생성 대상
  IF LS_ITEM_NEW-STAT_FLAG EQ GC_X.
    GS_CHANGE-I = GC_X.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_VK12_ZBO5
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ERR
*&      --> LS_OLD_DATAB
*&---------------------------------------------------------------------*
FORM PROCESS_VK12_ZBO5  USING    PV_ERR PV_DATAB.
  DATA : LV_MESSAGE(220),
         LV_PRICE        TYPE KONV-KBETR,
         LV_KBETR(17).
  DATA: LV_RSLT(1),
        LV_ICON         TYPE ICON-ID,
        LV_STAT_FLAG(1).

  LOOP AT GT_HIST INTO DATA(LS_HIST) WHERE STAT_FLAG NE GC_X.
    CLEAR : GT_BDCDATA, GT_BDCDATA[],
            GT_MESSAGE, GT_MESSAGE[],
            LV_MESSAGE.

    PERFORM BDC_INPUT USING :
    'SAPMV13A' '0100' 'X' 'RV13A-KSCHL' LS_HIST-KSCHL,
    '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

    "테이블 선택
    PERFORM BDC_INPUT USING :
    'SAPLV14A' '0100' 'X' 'BDC_CURSOR'     'RV130-SELKZ(02)',
    '        ' '    ' ' ' 'RV130-SELKZ(01)' ' ',
    '        ' '    ' ' ' 'RV130-SELKZ(02)' 'X',
    '        ' '    ' ' ' 'BDC_OKCODE'      '=WEIT'.

    PERFORM BDC_INPUT USING :
    'RV13A928' '1000' 'X' 'F001'       LS_HIST-VKORG,
    '        ' '    ' ' ' 'F002'       LS_HIST-VTWEG,
    '        ' '    ' ' ' 'F003'       LS_HIST-SPART,
    '        ' '    ' ' ' 'F004-LOW'   LS_HIST-AUSFU,
    '        ' '    ' ' ' 'SEL_DATE'   PV_DATAB,
    '        ' '    ' ' ' 'KODELFL'    ' ',
    '        ' '    ' ' ' 'BDC_OKCODE' '=ONLI'.

    CLEAR : LV_PRICE, LV_KBETR.
    LV_PRICE = ABS( LS_HIST-KBETR ).
    WRITE LV_PRICE TO LV_KBETR CURRENCY LS_HIST-KONWA.
    CONDENSE LV_KBETR NO-GAPS.

    PERFORM BDC_INPUT USING :
          'SAPMV13A' '1928' 'X' 'KONP-KBETR(01)' LV_KBETR,
          '        ' '    ' ' ' 'RV13A-DATAB(01)' LS_HIST-DATAB,
          '        ' '    ' ' ' 'RV13A-DATBI(01)' LS_HIST-DATBI,
          '        ' '    ' ' ' 'BDC_OKCODE' '/00'.

    PERFORM BDC_INPUT USING :
        'SAPMV13A' '1928' 'X' 'BDC_OKCODE' '=SICH'.

    PERFORM FILL_CTU_PARAMS USING 'N'.

    CALL TRANSACTION 'VK12' USING GT_BDCDATA
                            OPTIONS FROM GS_PARAMS
                            MESSAGES INTO GT_MESSAGE.

    IF LINE_EXISTS( GT_MESSAGE[ MSGTYP = 'S'
                                MSGID  = 'VK' MSGNR = '023' ] ).

      LV_RSLT = GC_S.


    ELSE.
      LOOP AT GT_MESSAGE INTO DATA(LS_MSG) WHERE MSGTYP CA 'AE'.
        EXIT.
      ENDLOOP.
      IF SY-SUBRC EQ 0.
        PV_ERR = 'X'.
        LV_RSLT = GC_E.
        LV_ICON = ICON_LED_RED.

        PERFORM MESSAGE_FUNCTION USING LS_MSG LV_MESSAGE.
        LS_HIST-MESSAGE = LV_MESSAGE.

      ELSE.
        LV_RSLT = GC_E.
        LV_ICON = ICON_LED_RED.
        LS_HIST-MESSAGE = |조건 레코드 변경 중 에러.|.
      ENDIF.

    ENDIF.

    LS_HIST-RSLT    = LV_RSLT.
    LS_HIST-ICON    = LV_ICON.

    MODIFY GT_HIST FROM LS_HIST
           TRANSPORTING MESSAGE RSLT WHERE KSCHL = LS_HIST-KSCHL
                                            AND AUSFU = LS_HIST-AUSFU.

    MODIFY GT_ITAB FROM LS_HIST
           TRANSPORTING MESSAGE RSLT WHERE KSCHL = LS_HIST-KSCHL
                                             AND AUSFU = LS_HIST-AUSFU.

  ENDLOOP.

ENDFORM.
