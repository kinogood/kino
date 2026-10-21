@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '배치번호 기준 PO 정보 조회 SUM'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_PODATA_BY_B_SUM 
as select from ZGTMM_CV_GET_PODATA_BYBATCH as A

// 26.09 LGORT, LGOBE 추가 
    left outer join ekpo as L
                             on A.ebeln = L.ebeln
                            and A.ebelp = L.ebelp
    left outer join t001l as LT
                             on L.lgort = LT.lgort
                            and L.werks = LT.werks
                           
{
  key A.werks,
  key A.matnr,
  key A.charg,
      A.ebeln,
      A.ebelp,
      
// 26.09 LGORT, LGOBE 추가
      max( L.lgort  ) as lgort,
      max( LT.lgobe ) as lgobe       
      
} 
 group by A.werks, A.matnr,A.charg,A.ebeln, A.ebelp
