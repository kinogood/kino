@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매 정산 용 구매 HISTORY 기초 정보 조회 2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_EKBE_BASE2 
as select from ZGTMM_CV_GET_EKBE_BASE as A 
association [0..1] to zgtmmt5020 as TAXC on $projection.SPMON = TAXC.spmon and $projection.lifnr = TAXC.lifnr and $projection.vbeln = TAXC.vbeln and $projection.posnr = TAXC.posnr   
                                             and $projection.ebeln = TAXC.ebeln and $projection.ebelp = TAXC.ebelp  
{
   key A.ebeln,
   key A.ebelp,
   key A.mjahr,
   key A.mblnr,
   key A.zeile,
       A.XRECH,
       A.budat,
       A.SPMON,
       A.bukrs,
       A.ekorg,
       A.ekgrp,
       A.lifnr,
       A.pstyp,
       A.shkzg,
       @Semantics.quantity.unitOfMeasure: 'MEINS'     
       A.menge,
       A.meins,
       @Semantics.amount.currencyCode: 'HSWAE'  
       A.DMBTR,     //현지통화
       @Semantics.amount.currencyCode: 'waers'
       A.WRBTR ,     //전표통화
       A.waers,
       A.hswae,     //현지통화키
       A.cpudt,
       A.cputm,
       A.matnr,
       A.txz01,
       A.werks,
       A.eindt,
       A.webre,
       case when TAXC.mwskz is not null then TAXC.mwskz else A.mwskz end as MWSKZ,
       A.meprf,
       A.prdat,
       @Semantics.amount.currencyCode: 'waers'
       A.netpr, //구매발주단가
       A.peinh,     //단위
       A.bedat,
       A.BPUMN ,
       A.konwa,
       @Semantics.amount.currencyCode: 'waers'       
       A.ETIV_PRICE, //유효단가
 
       A.ETIV_PEINH, //유효단가 가격 단위,          

       A.ETIV_MEINS, //유효단가 단위       

       A.ETIV_waers, //유효단가 단위     
       A.BPWAERS,
       @Semantics.quantity.unitOfMeasure: 'BSTME_IV'           
       A.MENGE_IV,
       A.BSTME_IV,
       @Semantics.amount.currencyCode: 'waers_IV'       
       A.WRBTR_IV,
       A.WAERS_IV,
       A.vbeln,
       A.posnr      
}
