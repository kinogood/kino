@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MRP 관리자 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_DISPO 
as 
select from mara as A inner join marc as B on A.matnr = B.matnr
       left outer join t024d as C on B.dispo = C.dispo and B.werks = C.werks  
       left outer join zppt0107 as D on A.spart = D.spart and B.werks = D.werks              
       
       
{
    key B.werks,
    key B.matnr,
    B.dispo,
    LEFT(B.dispo,2) as SPG1,
    case when C.dsnam is not null then C.dsnam
    else cast('' as dsnam) end as DSNAM,
    
    A.spart,
    case when B.dispo is not null then LEFT(B.dispo,2)
         else cast('' as zspgcd ) end as SPG2,
    case when C.dsnam is not null then C.dsnam
         else cast('' as bu_text20 ) end as SPG2NAME
}
