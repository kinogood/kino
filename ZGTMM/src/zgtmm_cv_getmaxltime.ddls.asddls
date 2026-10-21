@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '플랜트/자재 별 MAX LEAD TIME'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETMAXLTIME 
as 
select from eina as A inner join eine as B on A.infnr = B.infnr
       inner join marc as C on A.matnr = C.matnr and B.werks = C. werks
       inner join t001k as D on C.werks = D.bwkey
       inner join t001 as E on D.bukrs = E.bukrs
{
    key E.bukrs,
    key B.werks,
    key A.matnr,
    max(B.aplfz) as APLFZ,
    count(*) as CNT
    
} where A.loekz = '' and B.loekz = '' and C.sobsl <> '30' and B.esokz = '0'

group by E.bukrs, B.werks, A.matnr

union 
select from eina as A inner join eine as B on A.infnr = B.infnr
       inner join marc as C on A.matnr = C.matnr and B.werks = C. werks
       inner join t001k as D on C.werks = D.bwkey
       inner join t001 as E on D.bukrs = E.bukrs
{
    key E.bukrs,
    key B.werks,
    key A.matnr,
    max(B.aplfz) as APLFZ,
    count(*) as CNT
    
} where A.loekz = '' and B.loekz = '' and C.sobsl = '30' and B.esokz = '3'

group by E.bukrs, B.werks, A.matnr
