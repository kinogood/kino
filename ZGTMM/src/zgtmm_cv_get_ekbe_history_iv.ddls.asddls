@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매 정산 용 송장 HISTORY 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_EKBE_HISTORY_IV 
as
select from rseg as A inner join rbkp as B on A.belnr = B.belnr and A.gjahr = B.gjahr 
{
   key A.belnr,
   key A.buzei,
   key A.gjahr as GJAHR_IV,
       B.bukrs,
       A.lfgja as GJAHR,
       A.lfbnr as MBLNR,
       A.lfpos as ZEILE,
       @Semantics.quantity.unitOfMeasure: 'BSTME'           
       A.menge,
       A.bstme,
       @Semantics.amount.currencyCode: 'waers'       
       A.wrbtr,
       B.waers,
       A.mwskz
    
} where B.stblg = '' and B.rbstat = '5'
