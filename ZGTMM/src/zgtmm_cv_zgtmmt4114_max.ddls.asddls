@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '최종 사급자재 불출 이력'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_ZGTMMT4114_MAX 
as select from zgtmmt4114 as A inner join ZGTMM_CV_ZGTMMT4114_MAXGUID as B 
           on  A.pswrk = B.pswrk and A.ebeln = B.ebeln and A.ebelp = B.ebelp and A.matnr = B.matnr
           and A.tagnr = B.tagnr and A.charg = B.charg and A.zseq = B.zseq and A.zguid = B.ZGUID 
{
   key  A.pswrk,
   key  A.ebeln,
   key  A.ebelp,
   key  A.matnr,
   key  A.tagnr,
   key  A.posnr,
   key  A.charg,
   key  A.zseq,
        A.lgort,
        @Semantics.quantity.unitOfMeasure: 'meins'
        A.bdmng,
        @Semantics.quantity.unitOfMeasure: 'meins'
        A.enmng,
        A.lossr,
        A.meins,
        A.mblnr,
        A.mjahr,
        A.sernr,
        A.lotno,
        A.lbear,
        @Semantics.quantity.unitOfMeasure: 'meins'
        A.scqty,
        A.loekz,
        A.mblnr_f,
        A.outpr_f,
        A.gubun,
        A.erdat,
        A.ertim,
        A.ernam,
        A.zeile,
        A.zguid 
}
