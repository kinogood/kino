@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 직송 검수 요청 정보'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_DD_QCDATA 
as select from zgtmmt4402 as a inner join ekkn as B on a.ebeln = B.ebeln and a.ebelp = B.ebelp and B.zekkn = '01' 
{
   key B.vbeln,
   key B.vbelp,
   key a.ebeln,
   key a.ebelp,
   key a.zinsp_no, // 검사요청번호
      @Semantics.quantity.unitOfMeasure: 'MEINS'   
       a.zinsp_qty,  // 검사요청수량
       a.meins,
       a.zinsptype,
       a.zinspdate,
       a.zinspres,
       a.zinsp_date as erdat       //접수일
}
