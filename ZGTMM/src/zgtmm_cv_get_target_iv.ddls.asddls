@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매 정산 대상 수량 및 금액 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_TARGET_IV 
as select from ZGTMM_CV_GET_EKBE_HISTORY3 as a inner join nsdm_e_MKPF as b on a.mjahr = b.mjahr and a.mblnr = b.mblnr  
//association [0..1] to ekkn  as EKKN on $projection.ebeln = EKKN.ebeln and $projection.ebelp = EKKN.ebelp and EKKN.zekkn = '01'  

{
   key a.ebeln,
   key a.ebelp,
   key a.mjahr,
   key a.mblnr,
   key a.zeile,
       a.XRECH,
       b.budat,       
       a.SPMON,
       a.bukrs,
       a.ekorg,
       a.ekgrp,
       a.lifnr,
       a.LIFNR_N,
       a.pstyp,
       @Semantics.quantity.unitOfMeasure: 'MEINS'           
       sum(a.MENGE) as menge,    //입고수량
       a.meins,
       @Semantics.amount.currencyCode: 'HSWAE'       
       sum(a.DMBTR) as dmbtr,     //현지통화
       @Semantics.amount.currencyCode: 'waers'
       sum(a.WRBTR) as wrbtr,     //전표통화
       a.waers,
       a.hswae,     //현지통화키
    //   cpudt,
    //   cputm,
       a.matnr,
       a.txz01,
       a.COLOR,
       a.LENGTH,            
       a.LENUNIT,                
       a.werks,
       a.eindt,
       a.webre,
       a.MWSKZ,
       a.meprf,
       a.prdat,
       @Semantics.amount.currencyCode: 'waers'
       a.netpr,     //구매발주단가
       a.peinh,     //단위
       a.bedat,
       @Semantics.amount.currencyCode: 'waers'
       a.ETIV_PRICE, //유효단가
       a.ETIV_PEINH, //유효단가 가격 단위,            
       a.ETIV_MEINS, //유효단가 단위     
       a.ETIV_waers, //유효단가 통화 
       
       @Semantics.quantity.unitOfMeasure: 'BSTME_IV'           
       sum(a.MENGE_IV) as menge_iv,
       a.BSTME_IV,
       @Semantics.amount.currencyCode: 'waers_IV'       
       sum(a.WRBTR_IV) as WRBTR_IV,
       a.WAERS_IV,
       a.BPWAERS,
  
       case when sum(a.MENGE_IV) >= sum(a.MENGE)  then cast('X' as abap.char(1)) else cast('' as abap.char(1)) end  as IV_COMPLETE,       
     //  IV_COMPLETE,  

       @Semantics.amount.currencyCode: 'waers_IV'   
       sum(a.TARGET_PRICE) as TARGET_PRICE,
        
       @Semantics.amount.currencyCode: 'waers_IV'                
       sum(a.TAXPRICE) as TAXPRICE,
                       
       @Semantics.quantity.unitOfMeasure: 'IV_UNIT'         
       sum(a.IV_QTY) as IV_QTY,
       a.IV_UNIT, 
       a.RATE,
       a.BPUMN,
       @Semantics.quantity.unitOfMeasure: 'IV_UNIT'  
       sum(a.IV_OQTY) as IV_OQTY,
 //      case when ekkn.vbeln is not null then ekkn.vbeln else cast('' as vbeln_co) end as VBELN,
 //      case when ekkn.vbelp is not null then ekkn.vbelp else cast('' as posnr_co) end as VBELP
       a.vbeln, a.posnr as vbelp
 
} where b.budat > DATS_ADD_MONTHS(b.budat,-12,'NULL')
group by a.ebeln,a.ebelp,a.mjahr,a.mblnr,a.zeile, b.budat,
           a.SPMON,a.bukrs,a.ekorg,a.ekgrp,a.lifnr,a.LIFNR_N,a.pstyp,a.meins,
           a.waers,a.hswae,a.matnr,a.txz01,a.COLOR,a.LENGTH,a.LENUNIT,              
           a.werks,a.eindt,a.webre,a.MWSKZ,a.meprf,a.prdat,
           a.netpr,a.peinh,a.bedat,a.ETIV_PRICE,a.ETIV_PEINH,             
           a.ETIV_MEINS, a.ETIV_waers, a.BSTME_IV, a.WAERS_IV, a.BPWAERS,a.IV_UNIT, a.RATE, a.BPUMN, a.XRECH, a.vbeln, a.posnr
