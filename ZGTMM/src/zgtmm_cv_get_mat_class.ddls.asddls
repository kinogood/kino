@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재마스터 클래스 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_MAT_CLASS 
as select from mara as A inner join kssk as B on A.matnr = B.objek 
                         inner join klah as C on B.clint = C.clint
{
   key A.matnr,
       C.class 
} where B.klart = '001' and B.mafid = 'O'
