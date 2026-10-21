@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[BD] 정보레코드 송신 로그 - MM00061'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_BD_INFO_LOG as 
    select from zgtmmt9000 as a inner join zgtmmt6010 as b
                                        on a.zifkey = b.zifkey
                                left outer join makt as m
                                        on b.matnr = m.matnr
                                       and m.spras = $session.system_language                                
{
    key a.zifno,
    key a.zifkey,
    key a.system_id,
        a.zstat,
        a.message,
        a.ifdat,
        a.iftim,
        a.ifnam,
        
        b.infnr,
        b.txz01,
        b.ekorg,
        b.esokz,
        b.werks,
        b.lifnr,        
        b.matkl,
        b.matnr,
        m.maktx,
        b.datbi,
        b.idnlf,
        b.name1,
        @Semantics.amount.currencyCode: 'waers'
        b.kbetr,
        b.waers,
        b.peinh,
        b.bprme,
        b.datab,
        b.udate,
        b.utime
} where a.zifno = 'MM00061'
