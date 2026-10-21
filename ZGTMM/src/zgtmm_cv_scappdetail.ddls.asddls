@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 불출 품의 리스트 ITEM'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SCAPPDETAIL 
as select from zgtmmt4111

association [0..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language 
{
   key  zguid,
   key  matnr,
        makt.maktx,
        xchpf,
        
        @Semantics.quantity.unitOfMeasure: 'MEINS'   
        reqty,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        scqty,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        neqty,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        slqty,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        isqty,
        meins,
        
        @Semantics.amount.currencyCode: 'waers'
        isval,
        
        @Semantics.amount.currencyCode: 'waers'
        scval,
        waers 
}
