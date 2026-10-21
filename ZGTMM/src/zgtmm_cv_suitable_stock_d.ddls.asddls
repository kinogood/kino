@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '적정재고 조회(Daily)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SUITABLE_STOCK_D 
as
select from zgtmmt4222 as A inner join zgtmmt4223 as B 
                            on A.timestamp = B.timestamp and A.bukrs = B.bukrs and A.werks = B.werks
                            and A.matnr = B.matnr
association [1..1] to t001 as T001 on $projection.bukrs = T001.bukrs                             
association [1..1] to t001w as T001W on $projection.werks = T001W.werks
association [1..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language   
association [1..1] to ZGTMM_CV_SUITABLE_LASTSIM as MX on $projection.bukrs = MX.bukrs and $projection.werks = MX.werks and $projection.timestamp = MX.TIMESTAMP and MX.TYPE = 'D'                          
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
    A.unqty + A.bondedqty as TOTALQTY,
    
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
    (A.unqty + A.bondedqty) - B.su_qty as DIFF,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    cast(B.su_qty * cast(0.9 as abap.dec(13,2)) as menge_d) as su_qty_under,

    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    cast(B.su_qty * cast(1.1 as abap.dec(13,2)) as menge_d) as su_qty_over,    
    A.planweek,
    
    B.type,
    dd07t.ddtext as TYPENAME,
    
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d1,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d2,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d3,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d4,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d5,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d6,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d7,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d8,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d9,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d10,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d11,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d12,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d13,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d14,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d15,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d16,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d17,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d18,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d19,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d20,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d21,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d22,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d23,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d24,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d25,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d26,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d27,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d28,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d29,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d30,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d31,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d32,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d33,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d34,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d35,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d36,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d37,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d38,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d39,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d40,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d41,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d42,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d43,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d44,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d45,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d46,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d47,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d48,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d49,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d50,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d51,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d52,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d53,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d54,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d55,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d56,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d57,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d58,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d59,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d60,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d61,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d62,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d63,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d64,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d65,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d66,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d67,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d68,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d69,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d70,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d71,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d72,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d73,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d74,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d75,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d76,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d77,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d78,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d79,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d80,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d81,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d82,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d83,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d84,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d85,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d86,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d87,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d88,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d89,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d90,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d91,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d92,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d93,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d94,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d95,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d96,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d97,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d98,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d99,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d100,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d101,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d102,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d103,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d104,
    @Semantics.quantity.unitOfMeasure: 'MEINS' B.d105,

    
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
