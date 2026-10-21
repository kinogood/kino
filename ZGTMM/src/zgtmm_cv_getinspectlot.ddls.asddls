@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매 입고 검사 LOT 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETINSPECTLOT 
as 
select from matdoc as A 
 left outer join qals as B on A.mjahr = B.mjahr and A.mblnr = B.mblnr and A.zeile = B.zeile 
{
 key A.mjahr,
 key A.mblnr,
 key A.zeile,
 case when B.prueflos is not null then B.prueflos
                                  else cast('' as qplos) end as prueflos
}
