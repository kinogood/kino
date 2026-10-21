@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '인포레코드 기간 별 단가 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_INFOPRICE 
as select from a017 as A inner join konh as B on A.knumh = B.knumh and A.kappl = B.kappl and A.kschl = B.kschl
                         inner join konp as C on B.knumh = C.knumh and B.kappl = C.kappl and B.kschl = C.kschl
                         inner join eina as D on A.lifnr = D.lifnr and A.matnr = D.matnr
                         inner join eine as E on D.infnr = E.infnr and A.ekorg = E.ekorg and A.werks = E.werks and A.esokz = E.esokz
                         inner join mara as F on D.matnr = F.matnr //자재그룹 INFO RECORD는 관리안함 
                         inner join makt as G on F.matnr = G.matnr and G.spras = $session.system_language
                         inner join t024e as H on E.ekorg = H.ekorg
                         inner join t024 as I on E.ekgrp = I.ekgrp
                         inner join lfa1 as lfa1 on D.lifnr = lfa1.lifnr
                         inner join lfm1 as lfm1 on D.lifnr = lfm1.lifnr and E.ekorg = lfm1.ekorg
association [0..1] to zgtmmt1060 as Z1 on Z1.ekorg = $projection.ekorg and Z1.mtart = $projection.mtart    
             
association [0..1] to t001w as T001W on $projection.werks = T001W.werks        
association [0..1] to dd07t as TYPE on $projection.esokz = TYPE.domvalue_l and TYPE.domname = 'ESOKZ' and TYPE.ddlanguage = $session.system_language
association [0..1] to t007s as T007S on $projection.mwskz = T007S.mwskz and T007S.kalsm = 'TAXKR' and T007S.spras = $session.system_language
association [0..1] to t163m as T163M on $projection.bstae = T163M.bstae and T163M.spras = $session.system_language
association [0..1] to dd07t as Z2 on $projection.meprf = Z2.domvalue_l and Z2.domname = 'MEPRF' and Z2.ddlanguage = $session.system_language
association [0..1] to tinct as TINCT on $projection.inco1 = TINCT.inco1 and TINCT.spras = $session.system_language        
association [0..1] to zgtmmt1061 as Z3 on $projection.matnr = Z3.matnr and $projection.lifnr = Z3.lifnr and $projection.ekorg = Z3.ekorg and $projection.werks = Z3.werks and $projection.esokz = Z3.esokz
association [0..1] to ZGTMM_CV_GET_KONP_ZFR1 as ZF1 on $projection.knumh = ZF1.knumh and $projection.datab = ZF1.datab and $projection.datbi = ZF1.datbi and ZF1.kschl = 'ZFR1'
association [0..1] to ZGTMM_CV_GET_KONP_ZFR1 as ZF2 on $projection.knumh = ZF2.knumh and $projection.datab = ZF2.datab and $projection.datbi = ZF2.datbi and ZF2.kschl = 'ZFR2'         
{
  key A.lifnr,
  key A.matnr,  
  key A.ekorg,
  key A.werks,
  key A.esokz,
  key A.datab,
  key A.datbi,
      left(A.datab,6) as period_f,
      left(A.datbi,6) as period_t,
      lfa1.name1 as LIFNR_N,
      case when F.zzmaktx80 = '' then G.maktx 
           else F.zzmaktx80 end as MATNR_N,
      H.ekotx as EKORG_N,
      t001w.name1 as WERKS_N,
      TYPE.ddtext as ESKOZ_N,
      I.eknam as EKGRP_N,
      t007s.text1 as MWSKZ_N,
      @Semantics.amount.currencyCode: 'KONWA'
      C.kbetr,
      C.konwa,
      C.kpein,
      C.kmein,
      @Semantics.amount.currencyCode: 'ZFR1_UNIT'      
      case when ZF1.kschl is not null then ZF1.KBETR else cast(0 as kbetr_kond) end as ZFR1,
      ZF1.konwa as ZFR1_UNIT,
      @Semantics.amount.currencyCode: 'ZFR2_UNIT'         
      case when ZF2.kschl is not null then ZF2.KBETR else cast(0 as kbetr_kond) end as ZFR2, 
      ZF2.konwa as ZFR2_UNIT,
      A.knumh,
      E.mwskz,
      E.aplfz,
      E.ekgrp,
      @Semantics.quantity.unitOfMeasure: 'MEINS'        
      E.norbm,
      E.uebto,
      E.untto,
      E.uebtk,
      E.verid,
      E.webre,
      E.xersn,
      E.bstae,
      t163m.bsbez as BSTAE_N,
      E.meprf,
      Z2.ddtext as MEPRF_N,
      E.inco1,
      tinct.bezei as inco1_n,
      D.idnlf,
      D.infnr,
      D.meins,
      F.mtart,
      case when Z1.mtart is null then cast('' as zgte_mmyn)
           else Z1.zmanyn end as ZYN,
      case when Z3.approved is not null then Z3.approved
           else cast('' as zgte_mmyn) end as APPROVED,
      D.loekz as EINA_LOEKZ,
      E.loekz as EINE_LOEKZ,
      A.datab as DATAB_I,
      A.datbi as DATBI_I,      
      @Semantics.amount.currencyCode: 'KONWA'
      C.kbetr as KBETR_I,
      C.konwa as KONWA_I,
      C.kpein as KPEIN_I,
      C.kmein as KMEIN_I,
      @Semantics.amount.currencyCode: 'ZFR1_UNIT_I'         
      case when ZF1.kschl is not null then ZF1.KBETR else cast(0 as kbetr_kond) end as ZFR1_I,
      ZF1.konwa as ZFR1_UNIT_I,
      @Semantics.amount.currencyCode: 'ZFR2_UNIT_I'
      case when ZF2.kschl is not null then ZF2.KBETR else cast(0 as kbetr_kond) end as ZFR2_I, 
      ZF2.konwa as ZFR2_UNIT_I,
      lfm1.kalsk
                      
} where A.kappl = 'M' and A.kschl = 'PB00' and C.loevm_ko = '' and F.lvorm = ''
