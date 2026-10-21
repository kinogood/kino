@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 가공 투입 정보'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SC_543GICHECK2 
as 
select from ZGTMM_CV_SC_543GICHECK
{
    key vbeln,
    key tagnr,    
    key IDNRK,
    key charg,
        @Semantics.quantity.unitOfMeasure: 'MEINS'         
        GIQTY as LFIMG,
        GIMEINS as MEINS    
}
