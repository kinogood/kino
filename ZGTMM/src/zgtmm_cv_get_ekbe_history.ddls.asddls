@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매 정산 용 구매 HISTORY 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_EKBE_HISTORY 
as 

select from ZGTMM_CV_GET_EKBE_BASE2 
association [0..1] to lfa1  as vd on $projection.lifnr = vd.lifnr   
association [0..1] to ZGTMM_CV_PO_VCVALUE_MAIN  as sp1 on $projection.ebeln = sp1.PDOC and $projection.ebelp = sp1.PDOCITEM 
association [0..1] to ZGTMM_CV_GET_TAX_RATE   as TAX on $projection.MWSKZ = TAX.mwskz       
              
{
   key ebeln,
   key ebelp,
   key mjahr,
   key mblnr,
   key zeile,
       XRECH,
       LEFT(budat,6) as SPMON,
       bukrs,
       ekorg,
       ekgrp,
       lifnr,
       vd.name1 as LIFNR_N,
       pstyp,
       shkzg,
       @Semantics.quantity.unitOfMeasure: 'MEINS'     
       menge,
       meins,
       @Semantics.amount.currencyCode: 'HSWAE'  
       DMBTR,     //현지통화
       @Semantics.amount.currencyCode: 'waers'
       WRBTR ,     //전표통화
       waers,
       hswae,     //현지통화키
       cpudt,
       cputm,
       matnr,
       txz01,
       werks,
       eindt,
       webre,
       MWSKZ,
       meprf,
       prdat,
       @Semantics.amount.currencyCode: 'waers'
       netpr, //구매발주단가
       peinh,     //단위
       bedat,
       BPUMN ,
       konwa,
       case when sp1.COLOR is not null then sp1.COLOR
            else '' end as COLOR,
       case when sp1.LENGTH is not null then sp1.LENGTH
            else '' end as LENGTH,            
       case when sp1.LENGTH is not null then cast('M' as abap.unit(3))
            else cast('' as abap.unit(3)) end as LENUNIT,  
       @Semantics.amount.currencyCode: 'waers'       
       ETIV_PRICE, //유효단가
       ETIV_PEINH, //유효단가 가격 단위,          
       ETIV_MEINS, //유효단가 단위     
       ETIV_waers,  
       BPWAERS,
       @Semantics.quantity.unitOfMeasure: 'BSTME_IV'        
       MENGE_IV,
       BSTME_IV,
       @Semantics.amount.currencyCode: 'waers_IV'       
       WRBTR_IV,
       WAERS_IV,
       @Semantics.quantity.unitOfMeasure: 'IV_UNIT'            
       case when MENGE_IV is not null then menge - MENGE_IV else menge end as IV_QTY,
       meins as IV_UNIT,
       
        @Semantics.quantity.unitOfMeasure: 'IV_UNIT'  
        case when BPUMN > 0 then
               case when MENGE_IV is not null then cast(cast((menge - MENGE_IV) / BPUMN as abap.dec(13,3)) as bstmg)   
                                              else cast(cast(menge / BPUMN as abap.dec(13,3)) as bstmg) end 
            else
               case when MENGE_IV is not null then cast(cast(menge - MENGE_IV as abap.dec(13,3)) as bstmg) 
                                              else cast(cast(menge as abap.dec(13,3)) as bstmg) end        
        end as IV_OQTY,
        TAX.RATE,
        vbeln,
        posnr                                   
    
} 
