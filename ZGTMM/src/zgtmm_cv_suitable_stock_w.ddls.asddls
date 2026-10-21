@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '적정재고 조회(Weekly)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SUITABLE_STOCK_W 
as 

select from zgtmmt4220 as A inner join zgtmmt4221 as B 
                            on A.timestamp = B.timestamp and A.bukrs = B.bukrs and A.werks = B.werks
                            and A.matnr = B.matnr
association [1..1] to t001 as T001 on $projection.bukrs = T001.bukrs                             
association [1..1] to t001w as T001W on $projection.werks = T001W.werks
association [1..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language                     
association [1..1] to ZGTMM_CV_SUITABLE_LASTSIM as MX on $projection.bukrs = MX.bukrs and $projection.werks = MX.werks and $projection.timestamp = MX.TIMESTAMP and MX.TYPE = 'W'
association [0..1] to dd07t as DD07T on $projection.type = DD07T.domvalue_l and DD07T.domname = 'ZGTDSS_SUBTYPE' and DD07T.ddlanguage = $session.system_language 
{
    key A.timestamp,                        
    key A.bukrs,
    key t001.butxt as BUKRS_N,
    key A.werks,
    key t001w.name1 as WERKS_N,
    key A.matnr,
    key makt.maktx as MATNR_N,
    A.lt,
    A.servicefactor,

    @Semantics.quantity.unitOfMeasure: 'MEINS'     
    B.reqqty, 
    A.meins,

    @Semantics.quantity.unitOfMeasure: 'MEINS'     
    B.req_daily,

    @Semantics.quantity.unitOfMeasure: 'MEINS'     
    A.unqty,

    @Semantics.quantity.unitOfMeasure: 'MEINS'     
    A.bondedqty,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'        
    A.unqty + A.bondedqty  as TOTALQTY,
    
    @Semantics.amount.currencyCode: 'waers'   
    A.stockval,
    A.waers,
    A.f1,
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    B.f2,
    A.f1_sqrt,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    B.f2_sqrt,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    B.safty_qty,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    B.su_qty,
        
    @Semantics.quantity.unitOfMeasure: 'MEINS'     
    A.unqty + A.bondedqty - B.su_qty as DIFF,
 
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    cast( B.su_qty * cast(0.9 as abap.dec(13,3)) as abap.dec(13,3)) as su_qty_under,

    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    cast( B.su_qty * cast(1.1 as abap.dec(13,3)) as abap.dec(13,3)) as su_qty_over,
    
    A.planweek,
    
    B.type,
    dd07t.ddtext as TYPENAME,

    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    B.w0,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    B.w1,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    B.w2,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    B.w3,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    B.w4,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    B.w5,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    B.w6,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    B.w7,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    B.w8,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    B.w9,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    B.w10,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    B.w11,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    B.w12,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    B.w13,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    B.w14,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    B.w15,
    
    A.erdat,
    A.erdat_local,
    A.ertim,
    A.ertim_local,
    A.ernam,
    A.aedat,
    A.aedat_local,
    A.aetim,
    A.aetim_local,
    A.aenam,
    case when MX.TIMESTAMP is not null then cast('X' as abap.char(1)) else cast('' as abap.char(1)) end as DAILYLAST  
}
