@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MRP 관리자 조회(집계)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_DISPO2 
as select from ZGTMM_CV_GET_DISPO as a

association [0..1] to dd07t as b on b.domvalue_l = $projection.SPG1 and b.domname = 'ZGTDSPGCD' and b.ddlanguage = $session.system_language
       


{
    key a.werks,
    key a.matnr,
    key a.dispo,
    a.SPG1,
    case when b.ddtext is not null then b.ddtext
         else cast('' as val_text) end as SPG1NAME,
    a.DSNAM,
    a.spart,
    a.SPG2,
    a.SPG2NAME

}

group by a.werks, a.matnr, a.dispo, a.SPG1, a.DSNAM, a.spart, a.SPG2, a.SPG2NAME, b.ddtext


