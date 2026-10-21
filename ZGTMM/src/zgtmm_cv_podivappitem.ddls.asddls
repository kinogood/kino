@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO 분할 품목 현황'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_PODIVAPPITEM 
as 
select from zgtmmt4013 as A left outer join ekpo as B on A.ebeln = B.ebeln and A.ebelp = B.ebelp
                            inner join ekko as C on A.ebeln = C.ebeln    
association [0..1] to lfa1 as VD1 on $projection.lifnr = VD1.lifnr
association [0..1] to lfa1 as VD2 on $projection.EMLIF_O = VD2.lifnr
association [0..1] to lfa1 as VD3 on $projection.EMLIF_N = VD3.lifnr
association [0..1] to kna1 as CU1 on $projection.KUNNR_O = CU1.kunnr
association [0..1] to kna1 as CU2 on $projection.KUNNR_N = CU2.kunnr
{                            

    key A.zguid,
    key A.ebeln,
    key A.ebelp,
    A.matnr,
    A.txz01,
    A.werks,
    A.lgort,
    @Semantics.quantity.unitOfMeasure: 'MEINS' 
    cast(B.menge as bstmg) as MENGE_O,
    @Semantics.quantity.unitOfMeasure: 'MEINS' 
    A.menge as MENGE_N,
    A.meins,
    C.lifnr,
    VD1.name1 as LIFNR_N,
    B.emlif as EMLIF_O,
    VD2.name1 as EMLIF_O_N,
    A.emlif as EMLIF_N,
    VD3.name1 as EMLIF_N_N,
    B.kunnr as KUNNR_O,
    CU1.name1 as KUNNR_O_N,
    A.kunnr as KUNNR_N,
    CU2.name1 as KUNNR_N_N,
    A.znew,
    A.ebelp_o
    
    
}
