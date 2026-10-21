@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '보관 재고 직송 요청 수량'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_ZGTMMT4412_SUM
as select from zgtmmt4412 as A
     inner join zgtmmt4410 as B on A.bukrs = B.bukrs and A.dlvrq = B.dlvrq
     left outer join zgtmmt4405 as C
        on  A.bukrs = C.bukrs
        and A.dlvrq = C.dlvrq
        and A.vbeln = C.vbeln
        and A.posnr = C.posnr
{
   key A.bukrs,
   key A.vbeln,
   key A.posnr,
   @Semantics.quantity.unitOfMeasure: 'dr_meins'
   sum(A.req_drqty) as REQ_DRQTYSUM,
   A.dr_meins
}
where A.zmm_stat <> 'R'
  and A.zvd_stat <> 'R'
  and B.zreq_type = 'B'
  and B.zsd_stat = 'R'
  // ★ 추가: 이미 출고확인(완료) 처리된 건은 가용재고 경합 대상에서 제외
  and ( C.zmm_check is null or C.zmm_check <> 'A' )
group by A.bukrs, A.vbeln, A.posnr, A.dr_meins
