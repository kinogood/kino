@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매 단가 자재 리스트'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_INFOMAT 
as 
select from eina as A inner join eine as B on A.infnr = B.infnr
{
    key A.matnr,
    key B.werks
} where A.loekz = '' and B.loekz = '' and A.matnr <> ''
group by A.matnr, B.werks
