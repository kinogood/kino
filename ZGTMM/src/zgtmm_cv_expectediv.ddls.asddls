@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '당월 송장 처리 예상 금액'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_EXPECTEDIV 
as 
select from matdoc as A inner join ekpo as B on A.ebeln = B.ebeln and A.ebelp = B.ebelp
                        inner join ekko as C on B.ebeln = C.ebeln
                        inner join lfa1 as D on C.lifnr = D.lifnr
                        inner join ekbe as E on A.ebeln = E.ebeln and A.ebelp = E.ebelp and A.mjahr = E.gjahr 
                                           and  A.mblnr = E.belnr and A.zeile = E.buzei
{
  key A.mjahr,
  key A.mblnr,
  key A.zeile,
      A.budat,
      C.bukrs,
      A.werks,
      A.matnr,  
      C.lifnr, 
      A.shkzg,
      A.sobkz,
      @Semantics.quantity.unitOfMeasure: 'BPRME'      
      A.bpmng,
      A.bprme,
      @Semantics.amount.currencyCode: 'waers'    
      case when E.shkzg = 'H' 
           then 
                case when E.dmbtr <> 0 then E.dmbtr * -1
                     else
                      cast( cast(cast(B.netpr as abap.dec(13,2)) * A.bpmng * -1 / B.peinh  as abap.dec(13,2)) as abap.curr(13,2))
                     end 
           else
                case when E.dmbtr <> 0 then E.dmbtr 
                     else
                      cast( cast(cast(B.netpr as abap.dec(13,2)) * A.bpmng  / B.peinh  as abap.dec(13,2)) as abap.curr(13,2))
                     end            
           end as DMBTR,
      E.waers,

      A.ebeln,
      A.ebelp,
      A.lfbnr,
      A.lfpos,
      A.kostl,
      A.aufnr,
      A.smbln,
      A.smblp,
      A.cancelled,
      A.cancellation_type,
      A.reversal_movement,
      @Semantics.amount.currencyCode: 'POWAERS'          
      B.netpr,
      @Semantics.amount.currencyCode: 'POWAERS'          
      cast( cast(cast(B.netpr as abap.dec(13,2)) * A.bpmng  / B.peinh  as abap.dec(13,2)) as abap.curr(13,2)) as DDD,      
      @Semantics.quantity.unitOfMeasure: 'POBPRME' 
      B.peinh,
      B.bprme as POBPRME,
      C.waers as POWAERS
} where A.lifnr <> '' and A.xauto = '' and A.sobkz <> 'K' 
  and C.bsart <> 'MB' and B.repos <> ''
  and left(A.budat,6) = left($session.user_date,6)
