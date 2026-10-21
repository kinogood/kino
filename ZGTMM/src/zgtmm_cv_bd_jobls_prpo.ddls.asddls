@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[BD] 제조지시 구매문서 연결'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_BD_JOBLS_PRPO as 
    select from zgtmmt6000 as j inner join eban as b
                                        on j.banfn = b.banfn
                                       and j.bnfpo = b.bnfpo
{
    key j.jobls,
        j.mes_req,
        j.mes_seq,
        j.job_no,
        j.line_no,
        j.serial_info,
        j.banfn,
        j.bnfpo,
        j.ebeln,
        j.ebelp    
} where b.loekz <> 'X'

union

    select from zgtmmt6000 as j inner join ekpo as f
                                        on j.ebeln = f.ebeln
                                       and j.ebelp = f.ebelp
{
    key j.jobls,
        j.mes_req,
        j.mes_seq,
        j.job_no,
        j.line_no,
        j.serial_info,
        j.banfn,
        j.bnfpo,
        j.ebeln,
        j.ebelp    
} where f.loekz <> 'L'
