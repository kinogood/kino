@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[BD] 제조지시 vs. 판매오더'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_BD_JOBNO_SO as 
    select distinct from zgtsdt0067 as a
{
    key a.job_no,
    key a.line_no,
    key a.serial_info,
        a.vbeln,
        a.posnr
}
