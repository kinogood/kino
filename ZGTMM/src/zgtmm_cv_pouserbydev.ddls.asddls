@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '납품서 기준 PO 생성자 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_POUSERBYDEV
as select from ekes as A inner join ekko as B on A.ebeln = B.ebeln
                         inner join ZGTMM_CV_GETUSERNAME as C on B.ernam = C.USERID
association [1..1] to lfa1 as lfa1 on $projection.lifnr = lfa1.lifnr                         
{
  key A.vbeln,
      B.ernam,
      C.EMAIL,
      B.lifnr,
      lfa1.name1
} where A.vbeln <> ''
group by A.vbeln,  B.ernam, C.EMAIL, B.lifnr, lfa1.name1     
       
union all

select from zmmti26 as A inner join ekko as B on A.ebeln = B.ebeln
                         inner join ZGTMM_CV_GETUSERNAME as C on B.ernam = C.USERID
association [1..1] to lfa1 as lfa1 on $projection.lifnr = lfa1.lifnr                  
{
  key A.vbeln,
      B.ernam,
      C.EMAIL,
      B.lifnr,
      lfa1.name1
} 
group by A.vbeln,  B.ernam, C.EMAIL   , B.lifnr, lfa1.name1   

union all

select from zmmti34 as A inner join ekko as B on A.ebeln = B.ebeln
                         inner join ZGTMM_CV_GETUSERNAME as C on B.ernam = C.USERID
association [1..1] to lfa1 as lfa1 on $projection.lifnr = lfa1.lifnr                  
{
  key A.vbeln,
      B.ernam,
      C.EMAIL,
      B.lifnr,
      lfa1.name1
} where A.vbeln <> '' 
group by A.vbeln, B.ernam, C.EMAIL     , B.lifnr, lfa1.name1        
