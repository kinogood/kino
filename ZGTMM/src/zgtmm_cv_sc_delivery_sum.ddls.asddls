@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 가공 CBO DELIVERY HEADER'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SC_DELIVERY_SUM 
as 


select from zmmti34 as A left outer join matdoc as B on A.belnr = B.mblnr and  B.cancelled = '' and B.reversal_movement = ''
{
    key A.vbeln,
    A.werks,
    B.budat,
    B.mjahr as gjahr,
    //belnr as mblnr
    B.mblnr
} where A.belnr <> '' 
//where B.cancelled = '' and B.reversal_movement = ''
group by A.vbeln, A.werks, B.budat, B.mjahr, B.mblnr

union

select from zmmti34 as A left outer join matdoc as B on  A.vbeln = B.xblnr and  B.cancelled = '' and B.reversal_movement = ''
{
    key A.vbeln,
    A.werks,
    B.budat,
    B.mjahr as gjahr,
    //belnr as mblnr
    B.mblnr
} where A.belnr = '' 
//where B.cancelled = '' and B.reversal_movement = ''
group by A.vbeln, A.werks, B.budat, B.mjahr, B.mblnr

union 

select from zmmti26 as A left outer join matdoc as B on A.gjahr = B.mjahr and A.belnr = B.mblnr and A.belnr = B.mblnr and  B.cancelled = '' and B.reversal_movement = ''
{
    key A.vbeln,
    A.werks,
    B.budat,
    B.mjahr as gjahr,
    //belnr as mblnr
    B.mblnr
} 
//where B.cancelled = '' and B.reversal_movement = ''
group by A.vbeln, A.werks, B.budat, B.mjahr, B.mblnr
