@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[BD] 부스덕트 Billing 정보 제조지시변환'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTSD_CV_JOBNO_BILLING as 
select from vbrp as A inner join vbrk as B
                         on A.vbeln = B.vbeln
                        and B.fksto <> 'X'
{
    key A.vbeln, key A.posnr, 
    B.kunrg, B.spart, B.fkdat,
    A.aubel, A.aupos, A.vgbel, A.vgpos, 
    @Semantics.amount.currencyCode: 'WAERK'
    A.netwr, A.waerk
}
