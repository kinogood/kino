@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매요청/청구 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_REQPO_DATA 
as select from ZGTMM_CV_GET_REQPO_RAW2 as a
association [0..1] to kna1 as kna1 on $projection.kunnr = kna1.kunnr 
association [0..1] to lfa1 as LFA1 on $projection.emlif = LFA1.lifnr 
association [0..1] to tvkbt as TVKBT on $projection.vkbur = TVKBT.vkbur and TVKBT.spras = $session.system_language
association [0..1] to tvgrt as TVGRT on $projection.vkgrp = TVGRT.vkgrp and TVGRT.spras = $session.system_language 
association [0..1] to ekko as ekKo on $projection.ebeln = ekKo.ebeln
association [0..1] to ZGTMM_CV_GETSLSTOCK as STOCK on $projection.matnr = STOCK.matnr and  $projection.werks = STOCK.werks and  $projection.lgort = STOCK.lgort
association [0..1] to ZGTMM_CV_GET_NON_SALESS_SUM as FGSTOCK on $projection.matnr = FGSTOCK.matnr and $projection.werks = FGSTOCK.werks 
association [0..1] to t001l as T001L on $projection.werks = T001L.werks and $projection.lgort = T001L.lgort      
{
  key a.banfn,
  key a.bnfpo,
      a.bsart,
      a.ZTYPE,
      a.ZTYPE_n,
      a.matnr,
      a.txz01,
      a.specno,
      a.erdat, //최종 변경일
      @Semantics.quantity.unitOfMeasure: 'meins'
      a.MENGE,
      a.meins,
      a.LENGTH,
      a.DRQTY,
      a.COLOR,
      a.STRIPE_COLOR,  
      a.STRIPE_NO,        
      a.DRUM,
      a.drumname,
      a.MCONTENTS,
      a.TEAMCODE,
      a.INSPECTION,
      a.lfdat,
      a.matkl,
      a.MATKL_N,
      a.bukrs,
      a.kokrs,
      a.ktopl,
      a.ekorg,
      a.EKORG_N,
      a.werks,
      a.WERKS_N,
      a.lgort,
      t001l.lgobe as LGORT_N,
      a.ablad,
      a.ekgrp,
      a.EKGRP_N,
      a.afnam,
      case when a.lifnr <> '' then a.lifnr else a.FLIEF end as FLIEF,
      case when a.lifnr <> '' then a.LIFNR_N else a.FLIEF_N end as FLIEF_N,
      a.lifnr,
      a.LIFNR_N,
      @Semantics.amount.currencyCode: 'waers' 
      case when a.lifnr = '' and a.FLIEF = '' then cast(0 as bapre) 
           else a.preis end as preis,    
      a.waers,
      a.peinh,
      @Semantics.amount.currencyCode: 'waers' 
      a.GSWRT,
      a.sotax,
      a.ebakz,  //종료
      a.loekz, //삭제
      a.emlif,
      lfa1.name1 as SCVNAME,
      a.lblkz,
      a.knttp, //계정지정범주
      a.KNTTP_N,
      a.pstyp, //품목지정범주
      a.PSTYP_N,
      case when a.frgst = '' then cast('X' as abap.char(1))
           else  
               case when a.frgzu = 'X' then cast('X' as abap.char(1))
                    else cast('' as abap.char(1)) end
           end as REL,
      a.SAKTO,
      a.SAKTO_N,
      a.KOSTL,   
      a.KOSTL_N,
      a.vbeln,        
      a.POSNR,        
      a.kunnr,
      kna1.name1 as kunnr_n,
      a.vkbur,
      tvkbt.bezei as vkbur_n,
      a.vkgrp,
      tvgrt.bezei as vkgrp_n,
      a.ANLN1,      
      a.ANLN2,
      a.ANLN1_N,
      a.pS_PSP_PNR,   
      a.PS_PSP_PNR_N,
      a.AUFNR,
      a.BANFN_N,
      a.flag,
      a.poprocess,
      a.ebeln,          
      a.ebelp,
      case when ekko.frggr is null then cast('' as abap.char(1))
           else
              case when ekko.frggr = '' then cast('' as abap.char(1))
                   else cast('X' as abap.char(1)) end
           end as PORELSTATUS,
      @Semantics.quantity.unitOfMeasure: 'meins'           
      case when STOCK.LABST is not null then STOCK.LABST 
           else cast(0 as labst) end as SLQTY,
      a.estkz,
      a.mwskz,
      a.MTART,
      a.IRONDRUM,
      a.DRUMTITLEMARK,
      a.FLANGE_PROT,
      a.HANJEON,
      a.SOM,
      @Semantics.quantity.unitOfMeasure: 'FGMEINS'         
      FGSTOCK.CLABS as FGSTOCK,
      FGSTOCK.meins as FGMEINS,
      FGSTOCK.DRQTY as FGDRQTY,
      a.dpcbt,
      a.LGCHK,
      a.PR_STATUS,
      a.INSMK           
      
} where a.blckd = ''
