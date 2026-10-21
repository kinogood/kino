@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '판매오더 SKID 지정관련 CHARACTERISTIC VALUE 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SO_VCVALUE_BRGEW
  as select from vbap       as A
    inner join   ibin       as B on A.cuobj = B.instance
    inner join   ibinvalues as C on B.in_recno = C.in_recno
    inner join   ibsymbol   as D on C.symbol_id = D.symbol_id
    inner join   cabn       as E on D.atinn = E.atinn
{
  key A.vbeln,
  key A.posnr,
      A.vrkme,
      /* 판매오더 특성 값 */
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      max( case E.atnam when 'SAP_LENGTH_VKRME'      then D.atflv end ) as WELENG,
      max( case E.atnam when 'SAP_MILLCA_FACTOR'     then D.atflv end ) as WECNT

}
where
      E.atnam = 'SAP_LENGTH_VKRME'
  or  E.atnam = 'SAP_MILLCA_FACTOR'
  and B.valto = 99991231235959

group by
  A.vbeln,
  A.posnr,
  A.vrkme
