@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '기간 별 표준원가 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETSTPRICE 
as
select from mbew as A inner join ckmlcr as B  on A.kaln1 = B.kalnr
                   
{
  key A.matnr,
  key A.bwkey as WERKS,
  key B.bdatj as LFGJA,
  key RIGHT(B.poper,2) as LFMON,
  key cast(CONCAT(B.bdatj,RIGHT(B.poper,2)) as abap.numc(6)) as PERIOD,
  @Semantics.amount.currencyCode: 'waers'
  case when B.vprsv = 'S' then B.stprs
       else B.pvprs end as STPRS,
  B.waers,
  B.peinh
} where B.curtp = '10'   



/*
select from mbewh as A 
       inner join t001k as B on A.bwkey = B.bwkey 
       inner join t001 as C on B.bukrs = C.bukrs
{
    key A.matnr,
    key A.bwkey as WERKS,
    key A.lfgja,
    key A.lfmon,
    key cast(concat(A.lfgja,A.lfmon) as abap.numc(6)) as period,
    @Semantics.amount.currencyCode: 'waers'
    A.stprs,
    C.waers,
    A.peinh
} 

union

select from mbew as A 
       inner join t001k as B on A.bwkey = B.bwkey 
       inner join t001 as C on B.bukrs = C.bukrs
{
    key A.matnr,
    key A.bwkey as WERKS,
    key A.lfgja,
    key A.lfmon,
    key cast(concat(A.lfgja,A.lfmon) as abap.numc(6)) as period,
    A.stprs,
    C.waers,
    A.peinh
    
} */
