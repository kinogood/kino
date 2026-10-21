@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '사급 투입 꼬리표 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_TAGNUMBER_GI 
as select from ZGTMM_CV_TAGNUMBER as A 
          inner join zmmti35  as B on A.vbeln = B.vbeln and A.posnr = B.posnr and A.matnr = B.matnr and A.tagnr = B.tagnr
          inner join ZGTMM_CV_TAG_AGG  as c on A.werks = c.werks and B.idnrk = LTRIM(c.matnr,'0') and B.charg = c.charg
{
   key A.mjahr,
   key A.mblnr,
   key A.werks,
   key A.tagnr as tagnr_o,
   key c.TAGNR as tagnr_i,
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       B.lfimg as mgvrg,
       B.meins,
       $session.user_date as ZIDAT,   
       TSTMP_TO_TIMS(TSTMP_CURRENT_UTCTIMESTAMP(), ABAP_USER_TIMEZONE($session.user, $session.client, 'FAIL'), $session.client, 'FAIL') as ZITIM
           
} where B.status = 'C'
