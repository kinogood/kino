@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '판매오더 SKID 지정관련 CHARACTERISTIC VALUE 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SO_VCVALUE_SKID
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
      max( case E.atnam when 'PD_CA_SPEC_NO'         then D.atwrt end ) as SUL_NO,
      max( case E.atnam when 'PD_CA_SPEC_REV_NO'     then D.atwrt end ) as REV_SEQ,
      max( case E.atnam when 'PD_CA_COLOR_BASE'      then D.atwrt end ) as COLOR,
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      max( case E.atnam when 'SAP_LENGTH_VKRME'      then D.atflv end ) as WELENG,
      max( case E.atnam when 'SAP_MILLCA_FACTOR'     then D.atflv end ) as WECNT,
      max( case E.atnam when 'PD_CA_PACKING_DM'      then D.atwrt end ) as MATNR_DRUM,
      max( case E.atnam when 'PD_CA_PACKING_SK'      then D.atwrt end ) as MATNR_SKID,
      max( case E.atnam when 'PD_CA_SKID_YN'         then D.atwrt end ) as SKID_YN,
      max( case E.atnam when 'PD_CA_PACKMARK_STATUS' then D.atwrt end ) as PACKMARK

}
where
      E.atnam = 'PD_CA_SPEC_NO'
  or  E.atnam = 'PD_CA_SPEC_REV_NO'
  or  E.atnam = 'PD_CA_COLOR_BASE'
  or  E.atnam = 'SAP_LENGTH_VKRME'
  or  E.atnam = 'SAP_MILLCA_FACTOR'
  or  E.atnam = 'PD_CA_PACKING_DM'
  or  E.atnam = 'PD_CA_PACKING_SK'
  or  E.atnam = 'PD_CA_SKID_YN'
  or  E.atnam = 'PD_CA_PACKMARK_STATUS'
  and B.valto = 99991231235959

group by
  A.vbeln,
  A.posnr,
  A.vrkme
