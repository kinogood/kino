@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '배치번호 기준 PO 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_PODATA_BYBATCH 
as select from nsdm_e_mchb as A inner join matdoc as B on A.matnr = B.matnr and A.charg = B.charg
                                inner join marc as C on B.werks = C.werks and B.matnr = C.matnr
{
  key A.werks,
  key A.matnr,
  key A.charg,
      B.ebeln,
      B.ebelp  
} where A.werks = '6591' and B.werks  = '6500' and B.bwart = '101' and B.ebeln <> '' and C.dpcbt <> 'A' and A.clabs > 0 and B.cancelled = '' and B.reversal_movement = ''

union all

select from nsdm_e_mchb as A inner join matdoc as B on A.matnr = B.matnr and A.charg = B.charg
                                inner join marc as C on B.werks = C.werks and B.matnr = C.matnr
{
  key A.werks,
  key A.matnr,
  key A.charg,
      B.ebeln,
      B.ebelp  
} where A.werks = '6691' and B.werks  = '6600' and B.bwart = '101' and B.ebeln <> '' and C.dpcbt <> 'A' and A.clabs > 0  and B.cancelled = '' and B.reversal_movement = ''

union all

select from nsdm_e_mchb as A inner join matdoc as B on A.matnr = B.matnr and A.charg = B.charg
                                inner join marc as C on B.werks = C.werks and B.matnr = C.matnr
{
  key A.werks,
  key A.matnr,
  key A.charg,
      B.ebeln,
      B.ebelp  
} where A.werks = '6500' and B.werks  = '6500' and B.bwart = '101' and B.ebeln <> '' and C.dpcbt <> 'A' and A.clabs > 0  and B.cancelled = '' and B.reversal_movement = ''

union all

select from nsdm_e_mchb as A inner join matdoc as B on A.matnr = B.matnr and A.charg = B.charg
                                inner join marc as C on B.werks = C.werks and B.matnr = C.matnr
{
  key A.werks,
  key A.matnr,
  key A.charg,
      B.ebeln,
      B.ebelp  
} where A.werks = '6600' and B.werks  = '6600' and B.bwart = '101' and B.ebeln <> '' and C.dpcbt <> 'A' and A.clabs > 0  and B.cancelled = '' and B.reversal_movement = ''
