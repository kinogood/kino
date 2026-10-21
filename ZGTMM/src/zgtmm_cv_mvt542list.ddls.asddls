@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 출고 취소 리스트'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_MVT542LIST as select from matdoc
{
    key sjahr,
    key smbln,
    key max(smblp) as SMBLP
} 
where bwart = '542' and smbln <> ''
group by sjahr, smbln
