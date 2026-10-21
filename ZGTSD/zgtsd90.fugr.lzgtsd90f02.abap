*----------------------------------------------------------------------*
***INCLUDE LZGTSD90F02.
*----------------------------------------------------------------------*
FORM SAVE_BEFORE.
  CONSTANTS : L_NAME TYPE STRING VALUE 'N_____'.
  DATA : L_INDEX LIKE SY-TABIX.
  DATA : LS_COMPONENT TYPE ABAP_COMPONENTDESCR,
         LT_COMPONENT TYPE ABAP_COMPONENT_TAB,

         LR_STRUCTURE TYPE REF TO CL_ABAP_STRUCTDESCR,
         LR_HANDLE    TYPE REF TO DATA,
         LR_BEFORE    TYPE REF TO DATA,
         LR_CHANGE    TYPE REF TO DATA,
         LR_MOVE      TYPE REF TO DATA.

  FIELD-SYMBOLS : <L_STRUCTURE> TYPE ANY,
                  <L_FIELD>     TYPE ANY,
                  <LS_CHANGE>   TYPE ANY,
                  <LV_VIEW>     TYPE ANY.

*-- Get data
  LR_STRUCTURE  ?=
     CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_NAME( X_HEADER-VIEWNAME ).
  LT_COMPONENT = LR_STRUCTURE->GET_COMPONENTS( ).
  LS_COMPONENT-TYPE ?= CL_ABAP_DATADESCR=>DESCRIBE_BY_DATA( <ACTION> ).
  LS_COMPONENT-NAME = L_NAME.
  APPEND LS_COMPONENT TO LT_COMPONENT.

  LR_STRUCTURE = CL_ABAP_STRUCTDESCR=>CREATE( LT_COMPONENT ).

  CREATE DATA LR_HANDLE TYPE HANDLE LR_STRUCTURE.
  ASSIGN LR_HANDLE->* TO <L_STRUCTURE>.


*-- Set user, time, date
  LOOP AT TOTAL.

    IF <ACTION> = NEUER_EINTRAG OR <ACTION> = AENDERN.

      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.

      IF SY-SUBRC EQ 0.
        L_INDEX = SY-TABIX.
      ELSE.
        CLEAR L_INDEX.
      ENDIF.

      CHECK L_INDEX GT 0.
      MOVE-CORRESPONDING TOTAL TO <L_STRUCTURE>.

      CASE <ACTION>.
        WHEN AENDERN. "Change/Update
          ASSIGN COMPONENT 'AEDAT' OF STRUCTURE <L_STRUCTURE>
                                             TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-DATUM TO <L_FIELD>.
          ENDIF.

          ASSIGN COMPONENT 'AEZET' OF STRUCTURE <L_STRUCTURE>
                                             TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-UZEIT TO <L_FIELD>.
          ENDIF.

          ASSIGN COMPONENT 'AEZEIT' OF STRUCTURE <L_STRUCTURE>
                                              TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-UZEIT TO <L_FIELD>.
          ENDIF.

          ASSIGN COMPONENT 'AENAM' OF STRUCTURE <L_STRUCTURE>
                                             TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-UNAME TO <L_FIELD>.
          ENDIF.

          "LOCAL TIME
          ASSIGN COMPONENT 'AEDATLO' OF STRUCTURE <L_STRUCTURE>
                                               TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-DATLO TO <L_FIELD>.
          ENDIF.

          ASSIGN COMPONENT 'AETIMLO' OF STRUCTURE <L_STRUCTURE>
                                               TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-TIMLO TO <L_FIELD>.
          ENDIF.

          ASSIGN COMPONENT 'AETCODE' OF STRUCTURE <L_STRUCTURE>
                                               TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-TCODE TO <L_FIELD>.
          ENDIF.

          ASSIGN COMPONENT 'AEEMPNO' OF STRUCTURE <L_STRUCTURE>
                                             TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-UNAME TO <L_FIELD>.
          ENDIF.


        WHEN NEUER_EINTRAG. "New Entries
          ASSIGN COMPONENT 'MANDT' OF STRUCTURE <L_STRUCTURE>
                                             TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-MANDT TO <L_FIELD>.
          ENDIF.

          ASSIGN COMPONENT 'ERDAT' OF STRUCTURE <L_STRUCTURE>
                                             TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-DATUM TO <L_FIELD>.
          ENDIF.

          ASSIGN COMPONENT 'ERZET' OF STRUCTURE <L_STRUCTURE>
                                             TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-UZEIT TO <L_FIELD>.
          ENDIF.

          ASSIGN COMPONENT 'ERZEIT' OF STRUCTURE <L_STRUCTURE>
                                             TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-UZEIT TO <L_FIELD>.
          ENDIF.

          ASSIGN COMPONENT 'ERNAM' OF STRUCTURE <L_STRUCTURE>
                                             TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-UNAME TO <L_FIELD>.
          ENDIF.

          "LOCAL TIME
          ASSIGN COMPONENT 'ERDATLO' OF STRUCTURE <L_STRUCTURE>
                                               TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-DATLO TO <L_FIELD>.
          ENDIF.

          ASSIGN COMPONENT 'ERTIMLO' OF STRUCTURE <L_STRUCTURE>
                                               TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-TIMLO TO <L_FIELD>.
          ENDIF.

          ASSIGN COMPONENT 'ERTCODE' OF STRUCTURE <L_STRUCTURE>
                                               TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-TCODE TO <L_FIELD>.
          ENDIF.

          ASSIGN COMPONENT 'EREMPNO' OF STRUCTURE <L_STRUCTURE>
                                             TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-UNAME TO <L_FIELD>.
          ENDIF.

*          ASSIGN COMPONENT 'AEDAT' OF STRUCTURE <L_STRUCTURE>
*                                             TO <L_FIELD>.
*          IF SY-SUBRC = 0.
*            MOVE SPACE TO <L_FIELD>.
*          ENDIF.
*
*          ASSIGN COMPONENT 'AEZET' OF STRUCTURE <L_STRUCTURE>
*                                             TO <L_FIELD>.
*          IF SY-SUBRC = 0.
*            MOVE  SPACE TO <L_FIELD>.
*          ENDIF.
*
*          ASSIGN COMPONENT 'AEZEIT' OF STRUCTURE <L_STRUCTURE>
*                                              TO <L_FIELD>.
*          IF SY-SUBRC = 0.
*            MOVE SY-UZEIT TO <L_FIELD>.
*          ENDIF.
*
*          ASSIGN COMPONENT 'AENAM' OF STRUCTURE <L_STRUCTURE>
*                                             TO <L_FIELD>.
*          IF SY-SUBRC = 0.
*            MOVE SPACE TO <L_FIELD>.
*          ENDIF.
      ENDCASE.

      MOVE-CORRESPONDING <L_STRUCTURE> TO TOTAL.
      MODIFY TOTAL.
      EXTRACT = TOTAL.
      MODIFY EXTRACT INDEX L_INDEX.
    ENDIF.
  ENDLOOP.

ENDFORM.
