@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'InfoRecord 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_INFO 
as 
select from ekko as A inner join ekpo as B on A.ebeln = B.ebeln
                      inner join eine as C on B.infnr = C.infnr and A.ekorg = C.ekorg and B.werks = C.werks and B.pstyp = C.esokz
                      inner join eina as D on C.infnr = D.infnr and A.lifnr = D.lifnr and B.matnr = D.matnr
{
    key C.ekorg,
    key C.werks,
    key D.matnr,
    key D.lifnr,
    case when C.loekz <> '' or D.loekz <> ''
         then 'X' else '' end as LOEKZ
} group by C.ekorg, C.werks, D.matnr, D.lifnr, C.loekz, D.loekz
