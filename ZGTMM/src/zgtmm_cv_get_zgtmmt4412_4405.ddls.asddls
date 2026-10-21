@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '보관품 요청 및 거래명세서 발행 수량'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_ZGTMMT4412_4405 
as select from zgtmmt4410 as Z inner join zgtmmt4412 as A on Z.dlvrq = A.dlvrq
          left outer join ZGTMM_CV_GET_ZGTMMT4405_SUM as B on A.bukrs = B.bukrs and A.dlvrq = B.dlvrq  and A.vbeln = B.vbeln and A.posnr = B.posnr
{
  key A.vbeln,
  key A.posnr,  
  @Semantics.quantity.unitOfMeasure: 'DR_MEINS'  
  sum(A.req_drqty) as REQ_QTY,
  A.dr_meins,
  @Semantics.quantity.unitOfMeasure: 'DR_MEINS'   
  B.LOADQTY  
} where Z.zreq_type = 'B' and Z.zsd_stat ='R' and A.zmm_stat <> 'R' and A.zvd_stat <>'R'
group by A.vbeln, A.posnr, A.dr_meins, B.LOADQTY
