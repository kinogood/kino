@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GR MIN,MAX DATE 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GRDATECHECK 
as 
select from ekbe as A inner join matdoc as B on A.belnr = B.mblnr and A.buzei = B.zeile and A.shkzg = B.shkzg
{
  key A.ebeln,
  key A.ebelp,
  min(A.budat) as MINGRDATE,
  max(A.budat) as MAXGRDATE
     
} 
where A.vgabe = '1' and A.zekkn = '00' and B.cancelled = '' and B.reversal_movement = ''

group by A.ebeln, A.ebelp
