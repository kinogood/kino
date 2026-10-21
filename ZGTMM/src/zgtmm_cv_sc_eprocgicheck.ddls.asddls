@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 가공 납품 투입 정보 점검-EPROC'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SC_EPROCGiCHECK 
as select from zmmti35 as a left outer join ZGTMM_CV_SC_543GILIST  as b 
    on a.vbeln = b.vbeln and a.posnr = b.posnr and a.idnrk = b.ckmatnr
{
   key a.vbeln,
   key a.posnr,
   a.idnrk,
   b.IDNRK as resbmat,
   case when b.IDNRK is null then cast('N' as abap.char(1))
        else cast('Y' as abap.char(1)) end as GICHECK  
         
} 
where a.erdat > '20240101'
group by a.vbeln,a.posnr, a.idnrk, b.IDNRK
