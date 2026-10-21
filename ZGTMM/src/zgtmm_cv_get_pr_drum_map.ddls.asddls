@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매요청 CBO Drum 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_PR_DRUM_MAP 
as select from eban as a 
association [1..1] to zgtppt2450 as pr on  $projection.banfn = pr.banfn and $projection.bnfpo = pr.bnfpo


{
   key a.banfn,
   key a.bnfpo,
   case when pr.matnr_dm is not null and pr.matnr_dm <> '' then cast('X' as abap.char(1))
                                                           else cast('' as abap.char(1))
   end as checkpr 
}
