*&------------------------------------------------------
*&  (LGCable)SD Rate Det. Module(Month) (Copy 006 -> 720)
*&  기존의 Module을 Copy하여 하나로 정리함
*&  2004.10.19
*&------------------------------------------------------
*
*
*
*  TABLES: ZSD0099T.
*  TABLES: KNVV.
  DATA: LS_ZSD0099T TYPE ZSD0099T,
        LS_KNVV     TYPE KNVV.
  DATA: LS_SCAL TYPE SCAL.
  DATA: LV_EXCETP TYPE CHAR01.

  DATA: BEGIN OF ZNFSO_GO OCCURS 1,
          FKDAT_I   LIKE VBKD-FKDAT,
          KUNRG_I   LIKE VBPA-KUNNR,
          AUART_I   LIKE VBAK-AUART,
          VKGRP_I   LIKE VBAK-VKGRP,
          SPART_H_I LIKE VBAK-SPART,
        END   OF ZNFSO_GO.

  DATA: LV_T_NDT    LIKE /NFM/DATA-PRSDT.
  DATA: LV_AUART_O LIKE VBAK-AUART.

*-- 공통코드 정보 기준 User Exit 수행여부 구성 2025.02.25
*-> 시작


  CALL FUNCTION 'ZGTSD_EXITCONTROL_HAIMK'
    EXPORTING
      I_WERKS  = G_NE-WERKS
    IMPORTING
      E_EXCETP = LV_EXCETP.

  CHECK LV_EXCETP EQ 'N'.

*-> 끝

*
*&  NF-Modul    /NFM/I001     Kursdatum = Auftragsdatum
*Rate date = order date
*&&&&&  move g_ne-audat to g_ne-ndt.
*& - End


* -------- 추가 (LGCable) 2004.10.20    1/55555


  IF G_NE-KAPPL = 'V'.
    CLEAR LS_ZSD0099T.

    IF G_NE-BLT = '' OR
       G_NE-BLT = 'A'.            "A, Sales Order

*     userexit_move_field_to_VBKD @sapmv45a에서 Export함
      IMPORT ZNFSO_GO FROM MEMORY ID 'ZNFSO_GO'.
      READ TABLE ZNFSO_GO INDEX 1.
      G_NE-KUNRG = ZNFSO_GO-KUNRG_I.
      G_NE-FKDAT = ZNFSO_GO-FKDAT_I.
      LV_AUART_O = ZNFSO_GO-AUART_I.
    ELSE.                   "F, Billing

    ENDIF.

    CHECK LV_AUART_O NE 'ZCR'.
    CHECK LV_AUART_O NE 'ZDR'.
    CHECK LV_AUART_O NE 'ZOT'.

    G_NE-PARNR = G_NE-KUNRG.

    SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZSD0099T
                    FROM ZSD0099T
                   WHERE PARNR = G_NE-PARNR   "지급처기준(지급처별)
                     AND KAPPL = G_NE-KAPPL
                     AND WERKS = ''
                     AND ORG   = G_NE-ORG
                     AND VTWEG = G_NE-VTWEG
                     AND SPART = G_NE-SPART.
    IF SY-SUBRC NE 0.
      SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_ZSD0099T
                      FROM ZSD0099T
                     WHERE PARNR = ''         "영업조직별
                       AND KAPPL = G_NE-KAPPL
                       AND WERKS = ''
                       AND ORG   = G_NE-ORG
                       AND VTWEG = G_NE-VTWEG
                       AND SPART = G_NE-SPART.
      IF SY-SUBRC NE 0.
        LS_ZSD0099T-ZZNF_RATE_BASE   = 'SO'.
        LS_ZSD0099T-ZZNF_RATE_BUCKET = 'T'.
        LS_ZSD0099T-ZZNF_RATE_NUM    = 1.
*       LS_ZSD0099T-ZZNF_EXCH_KURST  = 'TTM'. "월평균 매매기준율
        LS_ZSD0099T-ZZNF_EXCH_KURST  = 'M'.   "일일   매매기준율
        LS_ZSD0099T-ZZNF_EXCH_BASE   = 'SO'.
        LS_ZSD0099T-ZZNF_EXCH_BUCKET = 'D'.   "M:Monthly, D:Daily
        LS_ZSD0099T-ZZNF_EXCH_NUM    = 0.     "당일자
      ENDIF.
    ENDIF.

    CASE LS_ZSD0099T-ZZNF_RATE_BASE.   "SO, IV
      WHEN 'IV'.   G_NE-NDT = G_NE-FKDAT.
      WHEN OTHERS. G_NE-NDT = G_NE-AUDAT.
    ENDCASE.


* - Monthly rate사용
*   72를 사용하는 경우, Monthly rate임.
    IF LS_ZSD0099T-ZZNF_RATE_BUCKET = ''.
      LS_ZSD0099T-ZZNF_RATE_BUCKET = 'T'.
    ENDIF.
*---
    IF LS_ZSD0099T-ZZNF_EXCH_KURST = ''.
*     ZSD0099T-ZZNF_EXCH_KURST = 'TTM'. "환율유형:월평균 매매기준율
      LS_ZSD0099T-ZZNF_EXCH_KURST = 'M'.   "환율유형:일일   매매기준율
    ENDIF.
*---
    IF LS_ZSD0099T-ZZNF_EXCH_BUCKET = ''.
*     ZSD0099T-ZZNF_EXCH_BUCKET = 'M'.  "Montly rate. 사용
      LS_ZSD0099T-ZZNF_EXCH_BUCKET = 'D'.  "M:Monthly, D:Daily
    ENDIF.
*---


*- AL은 LME 고시가만 사용함.
*  아직은 NIKKO에서 CU에 대해서만 고시가를 공시하고 있음.
    IF G_NE-NES = 'CU'.
      SELECT SINGLE J_1NBOESL INTO G_NE-BOESL
                              FROM KNVV
                             WHERE KUNNR = G_NE-PARNR
                               AND VKORG = G_NE-ORG
                               AND VTWEG = G_NE-VTWEG
                               AND SPART = ZNFSO_GO-SPART_H_I.
    ELSE.
      G_NE-BOESL = 'LME'.
    ENDIF.
* --------


*&  NF-Modul    /NFM/I002     Ber?ksichtigung der PB-Tage
*Take PB days into account
    IF NOT G_NE-WERKS IS INITIAL AND
      NOT G_NE-NDT IS INITIAL.
      PERFORM T001W_SELECT USING G_NE-WERKS.
      MOVE T001W-FABKL TO SCAL-FCALID.
      MOVE G_NE-NDT TO SCAL-DATE.
      IF /NFM/TNFS-PBT <> 0.
        SCAL-DATE = SCAL-DATE + /NFM/TNFS-PBT.
      ENDIF.
      IF NOT /NFM/TNFS-EAT IS INITIAL.
        SCAL-INDICATOR = '+'.
      ENDIF.
      IF NOT /NFM/TNFS-LAT IS INITIAL.
        SCAL-INDICATOR = '-'.
      ENDIF.
      LS_SCAL = SCAL.
      CALL FUNCTION '/NFM/KALENDER'
        EXPORTING
*         i_date      = scal-date
*         i_fcalid    = scal-fcalid
*         i_indicator = scal-indicator
          I_DATE      = LS_SCAL-DATE
          I_FCALID    = LS_SCAL-FCALID
          I_INDICATOR = LS_SCAL-INDICATOR
        IMPORTING
          E_DATE      = SCAL-DATE.
      MOVE SCAL-DATE TO G_NE-NDT.
    ENDIF.

*    if not g_ne-werks is initial and
*       not g_ne-ndt is initial.
*      perform t001w_select using g_ne-werks.
*      move t001w-fabkl to scal-fcalid.
*      move g_ne-ndt to scal-date.
*      if /nfm/tnfs-pbt <> 0.
*        scal-date = scal-date + /nfm/tnfs-pbt.
*      endif.
*      if not /nfm/tnfs-eat is initial.
*        scal-indicator = '+'.
*      endif.
*      if not /nfm/tnfs-lat is initial.
*        scal-indicator = '-'.
*      endif.
*      call function '/NFM/KALENDER'
*        EXPORTING
*          i_date      = scal-date
*          i_fcalid    = scal-fcalid
*          i_indicator = scal-indicator
*        IMPORTING
*          e_date      = scal-date.
*      move scal-date to g_ne-ndt.
*    endif.
*& - End


* -------- 추가 (LGCable) 2004.10.20    2/55555
* 동가의 기준을 찾을때,
    IF LS_ZSD0099T-ZZNF_RATE_BUCKET = 'M'.
      LV_T_NDT    = G_NE-NDT.

      CALL FUNCTION 'ZSD_DATE_GET_YEAR_MONTH'
        EXPORTING
          I_NDT      = LV_T_NDT
          I_EXCH_NUM = LS_ZSD0099T-ZZNF_RATE_NUM
        IMPORTING
          O_NDT      = LV_T_NDT.
*-----

      G_NE-NDT = LV_T_NDT.
    ENDIF.
* --------



*&  NF-Modul    /NFM/I018     Kurs "0" setzen
*Set rate = 0
    G_NE-NKU = 0.
*& - End



*&  NF-Modul    /NFM/I019     Belegw?rung f? Kurse verwenden
*Use document currency for rates
*  g_waers = g_ne-bcu.
*& - End
* -----> Currency translation.
* LME then Currency is USD, LOP then Currency is LOP.
    CASE G_NE-BOESL.
      WHEN 'LME'.  G_WAERS = 'USD'.
      WHEN 'LOP'.  G_WAERS = 'KRW'.
      WHEN OTHERS. G_WAERS = 'USD'.
    ENDCASE.
* -----> END Currency translation


    IF LS_ZSD0099T-ZZNF_RATE_BUCKET = 'M'.
*&  NF-Modul    /NFM/I008     Monatskurs ermitteln
*Determine month rate
      IF G_NE-NKU = 0.
        CALL FUNCTION '/NFM/DAY_RATE'
          EXPORTING
            I_BUKRS        = G_NE-BUKRS
            I_KAPPL        = G_NE-KAPPL
            I_ORG          = G_NE-ORG
            I_WAERK        = G_WAERS
            I_ART          = 'M'  "Monatskurs
            I_KDT          = G_NE-NDT
            I_NES          = G_NE-NES
            I_KURS2        = G_NE-KK2
            I_KURS3        = G_NE-KK3
            I_BOESL        = G_NE-BOESL
            I_BMG          = G_NE-BMG
            I_BME          = G_NE-BME
          IMPORTING
            E_BZU          = G_NE-BZU
            E_NKU          = G_NE-NKU
            E_NKW          = G_NE-NKW
            E_NMO          = G_NE-NMO
          EXCEPTIONS
            RATE_NOT_FOUND = 1.
        IF SY-SUBRC = 0.
          MOVE G_NE-NDT TO G_NE-KDT.
        ENDIF.
        CLEAR G_NE-KDT.
      ENDIF.

    ELSE.
      IF G_NE-NKU = 0.
        CALL FUNCTION '/NFM/DAY_RATE'
          EXPORTING
            I_BUKRS        = G_NE-BUKRS
            I_KAPPL        = G_NE-KAPPL
            I_ORG          = G_NE-ORG
            I_WAERK        = G_WAERS
            I_ART          = 'T'  "Monatskurs
            I_KDT          = G_NE-NDT
            I_NES          = G_NE-NES
            I_KURS2        = G_NE-KK2
            I_KURS3        = G_NE-KK3
            I_BOESL        = G_NE-BOESL
            I_BMG          = G_NE-BMG
            I_BME          = G_NE-BME
          IMPORTING
            E_BZU          = G_NE-BZU
            E_NKU          = G_NE-NKU
            E_NKW          = G_NE-NKW
            E_NMO          = G_NE-NMO
          EXCEPTIONS
            RATE_NOT_FOUND = 1.
        IF SY-SUBRC = 0.
          MOVE G_NE-NDT TO G_NE-KDT.
        ENDIF.
        CLEAR G_NE-KDT.
      ENDIF.
    ENDIF.
*& - End



*&  NF-Modul    /NFM/I005     Fakturasperre bei Kurs = 0
*Set billing block if rate=0
    IF G_NE-NES = 'FI'.  "FI(광섬유) 제외
    ELSE.
*      IF G_NE-NKU = 0.
*        IF G_NE-FSP IS INITIAL.
*          G_NE-FSP = '00'.          " 00 = Notizfindung pr?en
*        ENDIF.
*      ENDIF.
    ENDIF.
*& - End



*&  NF-Modul    /NFM/I034     Aktuellsten Monatskurs ermitteln
*Determine most current month rate
    IF G_NE-NKU = 0.
      CALL FUNCTION '/NFM/LAST_RATE'
        EXPORTING
          I_BUKRS        = G_NE-BUKRS
          I_KAPPL        = G_NE-KAPPL
          I_ORG          = G_NE-ORG
          I_WAERK        = G_WAERS
          I_ART          = 'M'
          I_NES          = G_NE-NES
          I_KURS2        = G_NE-KK2
          I_KURS3        = G_NE-KK3
          I_BZU          = G_NE-BZU
          I_BOESL        = G_NE-BOESL
          I_BMG          = G_NE-BMG
          I_BME          = G_NE-BME
        IMPORTING
          E_BZU          = G_NE-BZU
          E_KDT          = G_NE-KDT
          E_NKU          = G_NE-NKU
          E_NKW          = G_NE-NKW
        EXCEPTIONS
          RATE_NOT_FOUND = 1.
      IF SY-SUBRC = 0.
        G_NE-NMO = G_NE-KDT(6).
      ENDIF.
    ENDIF.
*& - End



***--> Local currency로 찾는 부분  Start
***
****&  NF-Modul    /NFM/I022  Fakturasperre aufheben bei Kurs = 0
****Remove billing block if rate = 0
***    if g_ne-nku = 0.
***      clear g_ne-fsp.
***    endif.
****& - End
***
***
***
***
****&  NF-Modul    /NFM/I020     Hausw?rung f? Kurse verwenden
****Use local currency for rates
***    g_waers = g_ne-hwaer.
****& - End
***
***
***
***
****&  NF-Modul    /NFM/I008     Monatskurs ermitteln
****Determine month rate
***    if g_ne-nku = 0.
***      call function '/NFM/DAY_RATE'
***        EXPORTING
***          i_bukrs        = g_ne-bukrs
***          i_kappl        = g_ne-kappl
***          i_org          = g_ne-org
***          i_waerk        = g_waers
***          i_art          = 'M'  "Monatskurs
***          i_kdt          = g_ne-ndt
***          i_nes          = g_ne-nes
***          i_kurs2        = g_ne-kk2
***          i_kurs3        = g_ne-kk3
***          i_boesl        = g_ne-boesl
***          i_bmg          = g_ne-bmg
***          i_bme          = g_ne-bme
***        IMPORTING
***          e_bzu          = g_ne-bzu
***          e_nku          = g_ne-nku
***          e_nkw          = g_ne-nkw
***          e_nmo          = g_ne-nmo
***        EXCEPTIONS
***          rate_not_found = 1.
***      if sy-subrc = 0.
***        move g_ne-ndt to g_ne-kdt.
***      endif.
***      clear g_ne-kdt.
***    endif.
****& - End
***
***
***
***
****&  NF-Modul    /NFM/I005     Fakturasperre bei Kurs = 0
****Set billing block if rate=0
***    if g_ne-nku = 0.
***      if g_ne-fsp is initial.
***        g_ne-fsp = '00'.          " 00 = Notizfindung pr?en
***      endif.
***    endif.
****& - End
***
***
***
***
****&  NF-Modul    /NFM/I034     Aktuellsten Monatskurs ermitteln
****Determine most current month rate
***    if g_ne-nku = 0.
***      call function '/NFM/LAST_RATE'
***        EXPORTING
***          i_bukrs        = g_ne-bukrs
***          i_kappl        = g_ne-kappl
***          i_org          = g_ne-org
***          i_waerk        = g_waers
***          i_art          = 'M'
***          i_nes          = g_ne-nes
***          i_kurs2        = g_ne-kk2
***          i_kurs3        = g_ne-kk3
***          i_bzu          = g_ne-bzu
***          i_boesl        = g_ne-boesl
***          i_bmg          = g_ne-bmg
***          i_bme          = g_ne-bme
***        IMPORTING
***          e_bzu          = g_ne-bzu
***          e_kdt          = g_ne-kdt
***          e_nku          = g_ne-nku
***          e_nkw          = g_ne-nkw
***        EXCEPTIONS
***          rate_not_found = 1.
***      if sy-subrc = 0.
***        g_ne-nmo = g_ne-kdt(6).
***      endif.
***    endif.
****& - End
***--> Local currency로 찾는 부분  END




*****--> g_ne-bkw로 NF Rate를 찾는 부분 Start
*****
******&  NF-Modul  /NFM/I022     Fakturasperre aufheben bei Kurs = 0
******Remove billing block if rate = 0
*****    if g_ne-nku = 0.
*****      clear g_ne-fsp.
*****    endif.
******& - End
*****
*****
*****
*****
******&  NF-Modul    /NFM/I021     W?r. aus Matzuordn. f? Kurseverwenden
******Use curr. of mat. assignment for rates
*****    g_waers = g_ne-bkw.
******& - End
*****
*****
*****
******&  NF-Modul    /NFM/I008     Monatskurs ermitteln
******Determine month rate
*****    if g_ne-nku = 0.
*****      call function '/NFM/DAY_RATE'
*****        EXPORTING
*****          i_bukrs        = g_ne-bukrs
*****          i_kappl        = g_ne-kappl
*****          i_org          = g_ne-org
*****          i_waerk        = g_waers
*****          i_art          = 'M'  "Monatskurs
*****          i_kdt          = g_ne-ndt
*****          i_nes          = g_ne-nes
*****          i_kurs2        = g_ne-kk2
*****          i_kurs3        = g_ne-kk3
*****          i_boesl        = g_ne-boesl
*****          i_bmg          = g_ne-bmg
*****          i_bme          = g_ne-bme
*****        IMPORTING
*****          e_bzu          = g_ne-bzu
*****          e_nku          = g_ne-nku
*****          e_nkw          = g_ne-nkw
*****          e_nmo          = g_ne-nmo
*****        EXCEPTIONS
*****          rate_not_found = 1.
*****      if sy-subrc = 0.
*****        move g_ne-ndt to g_ne-kdt.
*****      endif.
*****      clear g_ne-kdt.
*****    endif.
******& - End
*****
*****
*****
*****
******&  NF-Modul    /NFM/I005     Fakturasperre bei Kurs = 0
******Set billing block if rate=0
*****    if g_ne-nku = 0.
*****      if g_ne-fsp is initial.
*****        g_ne-fsp = '00'.          " 00 = Notizfindung pr?en
*****      endif.
*****    endif.
******& - End
*****
*****
*****
*****
******&  NF-Modul    /NFM/I034     Aktuellsten Monatskurs ermitteln
******Determine most current month rate
*****    if g_ne-nku = 0.
*****      call function '/NFM/LAST_RATE'
*****        EXPORTING
*****          i_bukrs        = g_ne-bukrs
*****          i_kappl        = g_ne-kappl
*****          i_org          = g_ne-org
*****          i_waerk        = g_waers
*****          i_art          = 'M'
*****          i_nes          = g_ne-nes
*****          i_kurs2        = g_ne-kk2
*****          i_kurs3        = g_ne-kk3
*****          i_bzu          = g_ne-bzu
*****          i_boesl        = g_ne-boesl
*****          i_bmg          = g_ne-bmg
*****          i_bme          = g_ne-bme
*****        IMPORTING
*****          e_bzu          = g_ne-bzu
*****          e_kdt          = g_ne-kdt
*****          e_nku          = g_ne-nku
*****          e_nkw          = g_ne-nkw
*****        EXCEPTIONS
*****          rate_not_found = 1.
*****      if sy-subrc = 0.
*****        g_ne-nmo = g_ne-kdt(6).
*****      endif.
*****    endif.
******& - End
*****--> g_ne-bkw로 NF Rate를 찾는 부분 END





*&  NF-Modul    /NFM/I013     Zuschlag ber?ksichtigen
*Take surcharge into account
    IF G_NE-KAPPL = 'M'.
      IF NOT G_NE-KZUEI IS INITIAL.
        G_ZUSCHLAG = G_NE-KZUEI / 100 + 1.
        G_NE-NKU = G_NE-NKU * G_ZUSCHLAG.
      ENDIF.
    ELSE.
      IF NOT G_NE-BZU IS INITIAL.
        G_ZUSCHLAG = G_NE-BZU / 100 + 1.
        G_NE-NKU = G_NE-NKU * G_ZUSCHLAG.
      ENDIF.
    ENDIF.
*& - End




*-------------
*   g_ne-bcu = 'KRW'.
*   G_NE-NKW = 'KRW'.
* g_ne-nkw와 g_ne-bcu와 다른경우
* g_ne-nku 금액을 g_ne-bcu화폐기준으로 환율을 고려하여 변경하고
* g_ne-nkw를 g_ne-bcu값으로 대체함.
* YEN으로 변경되는 경우에는 어떻게하나요?
* --> 동가변경에 사용되는 환율Logic을 추가할 것
* /NFM/SAPLPROCESSING.
* form FORM orderpos_umrechnen_notizk
* function module CALL FUNCTION '/NFM/CURRENCY_CONVERT'
    DATA: T_NKS   LIKE /NFM/TORDERPOS-BKS.
*   data: t_kursk like /NFM/DATA-KURSK.
    DATA: L_NKN   LIKE /NFM/TORDERPOS-BWR.
**************

*-- 환율의 기준을 찾을 때,
    CASE LS_ZSD0099T-ZZNF_EXCH_BASE.   "SO, IV
      WHEN 'IV'.   LV_T_NDT = G_NE-FKDAT.
      WHEN OTHERS. LV_T_NDT = G_NE-AUDAT.
    ENDCASE.


    IF LS_ZSD0099T-ZZNF_EXCH_BUCKET = 'M'.

      CALL FUNCTION 'ZSD_DATE_GET_YEAR_MONTH'
        EXPORTING
          I_NDT      = LV_T_NDT
          I_EXCH_NUM = LS_ZSD0099T-ZZNF_RATE_NUM
        IMPORTING
          O_NDT      = LV_T_NDT.
*-----

      LV_T_NDT+6(2) = '01'.
    ENDIF.



    IF G_NE-BCU NE G_NE-NKW AND
       G_NE-NKU NE 0.             "NF rate
***  t_kursk = 1.
*** 즉, doc : jpy, 동가 : usd, local currency : krw일때 사용.
      L_NKN   = G_NE-NKU.

      CALL FUNCTION '/NFM/CURRENCY_CONVERT'
        EXPORTING
          I_BWERT = L_NKN
***       i_kursk = t_kursk                  "원화를 외화로 할때 사용
          I_KURST = LS_ZSD0099T-ZZNF_EXCH_KURST "NF rate반영 환율유형
          I_PRSDT = LV_T_NDT                  "NF rate반영 적용일자
          I_KAPPL = G_NE-KAPPL
          I_ORG   = G_NE-ORG
          I_WAERN = G_NE-BCU        "Document currency
          I_WAERV = G_NE-NKW        "NF rate currency
        IMPORTING
          E_BWERT = L_NKN
          E_KURSV = T_NKS
        EXCEPTIONS
          NO_CONV = 1
          OTHERS  = 2.
      IF SY-SUBRC = 0.
        G_NE-NKU = L_NKN.
        G_NE-NKW = G_NE-BCU. "Doc. curr와 NF rate curr를 일치시킴
      ELSE.
        G_NE-NKU = 0.
        G_NE-FSP = '95'.  "Fakturasperre
      ENDIF.
    ENDIF.

  ENDIF.   "KAPPL = V

*************
***-------------------------
