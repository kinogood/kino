@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[BD] 견적품-시리얼 Mapping 물량합계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTSD_CV_JOBNO_SUM_0067 as select from zgtsdt0067 as a
{
    key a.zsystem_id,
    key a.job_no,
    key a.line_no,
    key a.serial_info,
    key a.posnr,
    key a.qcode,
    cast(sum(a.qqty) as abap.dec(15,3)) as total_qty67,
    a.qunit, 
    a.erdat
}

where a.qqty <> 0

group by a.zsystem_id, a.job_no, a.line_no, a.serial_info, 
         a.posnr,      a.qcode,  a.qunit,   a.erdat
