FUNCTION Z_TI_CONFIRMATION_ANL_QTY.
*"--------------------------------------------------------------------
*"*"광역인터페이스:
*"       IMPORTING
*"             VALUE(I_EBELN) LIKE  EKKO-EBELN
*"             VALUE(I_EBELP) LIKE  EKPO-EBELP
*"             VALUE(I_EINDT) LIKE  EKET-EINDT
*"             VALUE(I_BSTAE) LIKE  EKPO-BSTAE OPTIONAL
*"             VALUE(I_UPTYP) LIKE  EKPO-UPTYP OPTIONAL
*"       TABLES
*"              XEKET STRUCTURE  BEKET
*"--------------------------------------------------------------------
*- wegen allgemein globalen Schnittstellen, wird auch hier xeket benutzt

  REFRESH XEKET.
* lines deleted ...                                       "v_n_631132
  ekpo-ebeln = i_ebeln.
  ekpo-ebelp = i_ebelp.
  ekpo-bstae = i_bstae.
  ekpo-uptyp = i_uptyp.                                   "^_n_631132

  CALL FUNCTION 'ME_EKET_SINGLE_READ_ITEM'
       EXPORTING
            PI_EBELN            = I_EBELN
            PI_EBELP            = I_EBELP
       TABLES
            PTO_EKET            = XEKET
       EXCEPTIONS
            ERR_NO_RECORD_FOUND = 1
            OTHERS              = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  READ TABLE XT163D WITH KEY IBTYP = '2' BINARY SEARCH.
  H-INDEX = SY-TABIX.
  IF SY-SUBRC <> 0.
    SELECT SINGLE * FROM T163D INTO XT163D WHERE IBTYP EQ '2'.
    INSERT XT163D INDEX H-INDEX.
  ELSE.
    MOVE-CORRESPONDING XT163D TO T163D.
  ENDIF.
  PERFORM ETS_BEREITSTELLEN_MULTI.
  PERFORM LESEN_T163G USING 'X'.
  PERFORM ETD_AUFBAUEN USING 'A'.
  PERFORM ETD_UPDATE USING '1'.
  REFRESH XEKET.
*- nur Einteilungen die noch offen, offene Menge in xeket-menge
*  LOOP AT ETD WHERE EINDT LE I_EINDT
  LOOP AT ETD WHERE BLFDN EQ '0'.
    CLEAR XEKET.
    CHECK ETD-MENGE GT ETD-DABMG.
    XEKET-EBELN = I_EBELN.
    XEKET-EBELP = I_EBELP.
    XEKET-ETENR = ETD-ETENR.
    XEKET-LPEIN = ETD-LPEIN.
    XEKET-UZEIT = ETD-UZEIT.                    "n_508423
    XEKET-EINDT = ETD-EINDT.
    XEKET-CHARG = ETD-CHARG.
    XEKET-LICHA = ETD-LICHA.
*---- dispositiv relevante Menge berechnen ----------------------------*
    IF ETD-DABMG GT ETD-WEMNG.
      XEKET-MENGE = ETD-MENGE - ETD-DABMG.
    ELSE.
      XEKET-MENGE = ETD-MENGE - ETD-WEMNG.
    ENDIF.
    CHECK XEKET-MENGE GT 0.
    APPEND XEKET.
  ENDLOOP.

ENDFUNCTION.
