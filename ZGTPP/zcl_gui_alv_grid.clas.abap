class ZCL_GUI_ALV_GRID definition
  public
  inheriting from CL_GUI_ALV_GRID
  final
  create public .

public section.

  methods Z_SET_MERGE_HORIZ
    importing
      !ROW type I
    changing
      !TAB_COL_MERGE type LVC_T_CO01 .
  methods Z_SET_MERGE_VERT
    importing
      !ROW type I
    changing
      !TAB_COL_MERGE type LVC_T_CO01 .
  methods Z_DISPLAY .
  methods Z_SET_CELL_STYLE
    importing
      !ROW type I optional
      !COL type I optional
      !STYLE type LVC_STYLE
      !STYLE2 type LVC_STYLE optional .
  methods Z_SET_FIXED_COL_ROW
    importing
      !COL type I
      !ROW type I .
  methods Z_INIT_CELL_STYLES .
  methods Z_LVC_TABLE_FILL
    importing
      !LASTLINE type I .
protected section.
private section.
ENDCLASS.



CLASS ZCL_GUI_ALV_GRID IMPLEMENTATION.


  method Z_DISPLAY.

  DATA lv_stable TYPE lvc_s_stbl.
  DATA lv_soft   TYPE c.

**** Prepare refresh
*  lv_stable-row = 'X'.
*  lv_stable-col = 'X'.
*  lv_soft       = 'X'.
*
**** Refresh table because Z_SET_CELL_STYLE adds style-values
**** Refresh initializes mt_data
*  CALL METHOD refresh_table_display
*    EXPORTING
*      is_stable      = lv_stable
*      i_soft_refresh = lv_soft
*    EXCEPTIONS
*      OTHERS         = 1.

* Jetzt noch  �bertragen der ge�nderten Daten
  CALL METHOD me->set_data_table
    CHANGING
      data_table = mt_data[].

  CALL METHOD set_auto_redraw
    EXPORTING
      enable = 1.

  endmethod.


  method Z_INIT_CELL_STYLES.

  FIELD-SYMBOLS <fs_data> TYPE lvc_s_data.
* Nur Spalte setze komplette Spalte
  LOOP AT mt_data ASSIGNING <fs_data>.
    <fs_data>-style = 0.
  ENDLOOP.

  endmethod.


  METHOD Z_LVC_TABLE_FILL.

    DATA: L_VIEW TYPE UI_FUNC.
    DATA : RT_DATA TYPE REF TO LVC_T_DATA.
    FIELD-SYMBOLS : <LT_DATA> TYPE TABLE.

    DATA LO_VIEW_SERVICE TYPE REF TO IF_SALV_GUI_GRID_LVC_DATA.
    CALL METHOD _O_GRID_FACADE->VIEW_SERVICE RECEIVING O_VIEW_SERVICE = LO_VIEW_SERVICE.
    CALL METHOD lo_view_service->('GET_ALL_DATA')
      EXPORTING
        GUI_TYPE = M_GUI_TYPE
        VIEW     = L_VIEW
      IMPORTING
        RT_DATA  = RT_DATA.

    ASSIGN RT_DATA->* TO <LT_DATA>.

  ENDMETHOD.


  METHOD Z_SET_CELL_STYLE.

    FIELD-SYMBOLS <FS_DATA> TYPE LVC_S_DATA.
    IF ROW IS INITIAL.
      IF COL IS INITIAL.
* Beides leer -> nichts zu tun.
        EXIT.
      ELSE.
* Nur Spalte setze komplette Spalte
        LOOP AT MT_DATA ASSIGNING <FS_DATA>
              WHERE COL_POS = COL.
          <FS_DATA>-STYLE  = <FS_DATA>-STYLE + STYLE.
          <FS_DATA>-STYLE2 = <FS_DATA>-STYLE2 + STYLE2.
        ENDLOOP.
      ENDIF.
    ELSE.
      IF COL IS INITIAL.
* Nur Zeile eingegeben -> komplette Zeile setzen
        LOOP AT MT_DATA ASSIGNING <FS_DATA>
              WHERE ROW_POS = ROW.
          <FS_DATA>-STYLE  = <FS_DATA>-STYLE + STYLE.
          <FS_DATA>-STYLE2 = <FS_DATA>-STYLE2 + STYLE2.
        ENDLOOP.
      ELSE.
        READ TABLE MT_DATA ASSIGNING <FS_DATA>
            WITH KEY ROW_POS = ROW
                     COL_POS = COL.
        IF SY-SUBRC EQ 0.
          <FS_DATA>-STYLE  = <FS_DATA>-STYLE + STYLE.
          <FS_DATA>-STYLE2 = <FS_DATA>-STYLE2 + STYLE2.
        ELSE.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  method Z_SET_FIXED_COL_ROW.

  me->set_fixed_cols( col ).
  me->set_fixed_rows( row ).

  endmethod.


  METHOD Z_SET_MERGE_HORIZ.

* ROW - Zeile deren Spalten zusammengef�hrt werden sollen
* tab_col_merge - Spalten, die zusammengef�hrt werden sollen
    FIELD-SYMBOLS <FS_COLS> TYPE LVC_S_CO01.
    FIELD-SYMBOLS <FS_DATA> TYPE LVC_S_DATA.
    DATA OUTPUTLEN TYPE I.

    SORT TAB_COL_MERGE.
* Die Spalten, die zusammengef�hrt werden sollen
    LOOP AT TAB_COL_MERGE ASSIGNING <FS_COLS>.
* ein paar Pr�fungen
      IF <FS_COLS>-COL_ID    LE 0.                CONTINUE. ENDIF.
      IF <FS_COLS>-OUTPUTLEN LE <FS_COLS>-COL_ID. CONTINUE. ENDIF.
      OUTPUTLEN = <FS_COLS>-OUTPUTLEN - <FS_COLS>-COL_ID.
      LOOP AT MT_DATA ASSIGNING <FS_DATA>
           WHERE ROW_POS = ROW  AND
                 ( COL_POS BETWEEN <FS_COLS>-COL_ID AND
                                   <FS_COLS>-OUTPUTLEN ).
* Setze wie weit soll gemerged werden Von Spalte in L�nge
* und zwar wird bei der 1 Spalte angefangen
        IF <FS_DATA>-COL_POS = <FS_COLS>-COL_ID.
          <FS_DATA>-MERGEHORIZ = OUTPUTLEN.
* bei allen anderen, die zusammangeh�ren
* muss der Wert raus, da er aus der 1. Spalte kommt
* und das mergekennzeichen muss auch weg !
        ELSE.
          CLEAR <FS_DATA>-MERGEHORIZ.
          CLEAR <FS_DATA>-VALUE.
        ENDIF.
      ENDLOOP.
    ENDLOOP.


  ENDMETHOD.


  METHOD Z_SET_MERGE_VERT.

* ROW - Zeile deren Spalten zusammengef�hrt werden sollen
* tab_col_merge - Spalten, die zusammengef�hrt werden sollen
    FIELD-SYMBOLS <FS_COLS> TYPE LVC_S_CO01.
    FIELD-SYMBOLS <FS_DATA> TYPE LVC_S_DATA.
    DATA OUTPUTLEN TYPE I.

    SORT TAB_COL_MERGE.
* Die Spalten, die zusammengef�hrt werden sollen
    LOOP AT TAB_COL_MERGE ASSIGNING <FS_COLS>.
* ein paar Pr�fungen
      IF <FS_COLS>-COL_ID    LE 0.                CONTINUE. ENDIF.
      IF <FS_COLS>-OUTPUTLEN LE <FS_COLS>-COL_ID. CONTINUE. ENDIF.
      OUTPUTLEN = <FS_COLS>-OUTPUTLEN - <FS_COLS>-COL_ID.
      LOOP AT MT_DATA ASSIGNING <FS_DATA>
           WHERE ROW_POS = ROW  AND
                 ( COL_POS BETWEEN <FS_COLS>-COL_ID AND
                                   <FS_COLS>-OUTPUTLEN ).
* Setze wie weit soll gemerged werden Von Spalte in L�nge
* und zwar wird bei der 1 Spalte angefangen
        IF <FS_DATA>-COL_POS = <FS_COLS>-COL_ID.
          <FS_DATA>-MERGEVERT = OUTPUTLEN.
* bei allen anderen, die zusammangeh�ren
* muss der Wert raus, da er aus der 1. Spalte kommt
* und das mergekennzeichen muss auch weg !
        ELSE.
          CLEAR <FS_DATA>-MERGEVERT.
          CLEAR <FS_DATA>-VALUE.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
