@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매오더 변경 내역 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_CDHDR_EINKBELEG 
as select from cdhdr as A inner join cdpos as B on A.objectclas = B.objectclas and A.objectid = B.objectid
                          and A.changenr = B.changenr

{
   key A.objectclas,
   key A.objectid,
   key A.changenr,
       A.username,
       A.udate,
       A.utime,
       A.tcode 
} where B.fname <> 'IHREZ' and A.objectclas = 'EINKBELEG' and A.tcode <> 'MASS'
