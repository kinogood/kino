@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '배치번호 별 꼬리표 리스트'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_TAGNOBYBATCH 
as select from zppt0001 as A 
          inner join nsdm_e_mslb as b on A.werks = b.werks and A.matnr = b.matnr and A.charg = b.charg
          inner join matdoc as c on b.werks = c.werks and b.matnr = c.matnr and b.charg = c.charg and b.lifnr = c.lifnr
{
  key A.werks,
  key A.matnr,
  key A.charg,
  key A.tagnr,
      b.lifnr,
      max(c.budat) as grindat
} where b.lblab > 0 and c.cancelled= '' and c.bwart = '541' and c.sobkz = '' and A.charg <> ''
group by A.werks, A.matnr, A.charg, A.tagnr,b.lifnr 


