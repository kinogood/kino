@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매 입고 내역 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_GRLIST_BASE 
as 
select from matdoc as A inner join ekpo as B on A.ebeln = B.ebeln and A.ebelp = B.ebelp
                        inner join ekko as C on B.ebeln = C.ebeln
                        inner join ekbe as E on A.ebeln = E.ebeln and A.ebelp = E.ebelp and A.mjahr = E.gjahr
                                           and  A.mblnr = E.belnr and A.zeile = E.buzei
association [0..1] to ZGTMM_CV_GET_INFOPRICE as info on $projection.matnr = info.matnr and $projection.lifnr = info.lifnr
                                                    and $projection.ekorg = info.ekorg and $projection.werks = info.werks
                                                    and $projection.pstyp = info.esokz and info.datab <= A.budat and info.datbi >= A.budat and info.EINA_LOEKZ = '' and info.EINE_LOEKZ = ''                                            
{
  key A.mjahr,
  key A.mblnr,
  key A.zeile,
      A.budat,
      C.bukrs,
      C.ekorg,
      A.werks,
      A.matnr,
      C.lifnr,
      B.pstyp,
      A.shkzg,
      A.sobkz,
      @Semantics.quantity.unitOfMeasure: 'BPRME'
      A.bpmng,
      A.bprme,

      A.ebeln,
      A.ebelp,
      A.cancelled,
      A.cancellation_type,
      A.reversal_movement,
      @Semantics.amount.currencyCode: 'WAERS'
      B.netpr,
         
      @Semantics.quantity.unitOfMeasure: 'POBPRME'
      B.peinh,
      B.bprme as POBPRME,
      @Semantics.amount.currencyCode: 'WAERS'
      case when E.shkzg = 'H' then
      
          case when B.meprf <> '5' then 
                 cast( cast(cast(B.netpr as abap.dec(13,2)) * A.bpmng * -1 / B.peinh  as abap.dec(13,2)) as abap.curr(13,2)) 
               else 
                case when info.kbetr is not null then
                  case when C.waers = info.konwa then
                            cast( cast(cast(info.kbetr as abap.dec(13,2)) * A.bpmng * -1 / info.kpein  as abap.dec(13,2)) as abap.curr(13,2))
                       else  
                            cast( cast(cast(B.netpr as abap.dec(13,2)) * A.bpmng * -1 / B.peinh  as abap.dec(13,2)) as abap.curr(13,2))
                       end
                  else 
                      cast( cast(cast(B.netpr as abap.dec(13,2)) * A.bpmng * -1 / B.peinh  as abap.dec(13,2)) as abap.curr(13,2))
                  end
               end 
      else
          case when B.meprf <> '5' then 
                 cast( cast(cast(B.netpr as abap.dec(13,2)) * A.bpmng / B.peinh  as abap.dec(13,2)) as abap.curr(13,2)) 
               else 
                case when info.kbetr is not null then
                  case when C.waers = info.konwa then
                            cast( cast(cast(info.kbetr as abap.dec(13,2)) * A.bpmng / info.kpein  as abap.dec(13,2)) as abap.curr(13,2))
                       else  
                            cast( cast(cast(B.netpr as abap.dec(13,2)) * A.bpmng / B.peinh  as abap.dec(13,2)) as abap.curr(13,2))
                       end
                  else 
                      cast( cast(cast(B.netpr as abap.dec(13,2)) * A.bpmng / B.peinh  as abap.dec(13,2)) as abap.curr(13,2))
                  end
               end       
      end  as PRICESUM,          
      C.waers,
      B.meprf,
      B.prdat,
      @Semantics.amount.currencyCode: 'konwa'      
      info.kbetr,
      info.konwa,
      info.kpein,
      info.kmein,
      B.mwskz
} where A.lifnr <> '' and A.xauto = '' and A.sobkz <> 'K'
  and C.bsart <> 'MB' and A.bwart <> '543' and A.bwart <> '544' and B.meprf = '5'
  
union all  

select from matdoc as A inner join ekpo as B on A.ebeln = B.ebeln and A.ebelp = B.ebelp
                        inner join ekko as C on B.ebeln = C.ebeln
                        inner join ekbe as E on A.ebeln = E.ebeln and A.ebelp = E.ebelp and A.mjahr = E.gjahr
                                           and  A.mblnr = E.belnr and A.zeile = E.buzei                                           
{
  key A.mjahr,
  key A.mblnr,
  key A.zeile,
      A.budat,
      C.bukrs,
      C.ekorg,
      A.werks,
      A.matnr,
      C.lifnr,
      B.pstyp,
      A.shkzg,
      A.sobkz,
      A.bpmng,
      A.bprme,

      A.ebeln,
      A.ebelp,
      A.cancelled,
      A.cancellation_type,
      A.reversal_movement,
      B.netpr,

      B.peinh,
      B.bprme as POBPRME,
      case when E.shkzg = 'H' then      
        cast( cast(cast(B.netpr as abap.dec(13,2)) * A.bpmng * -1 / B.peinh  as abap.dec(13,2)) as abap.curr(13,2)) 
      else
        cast( cast(cast(B.netpr as abap.dec(13,2)) * A.bpmng  / B.peinh  as abap.dec(13,2)) as abap.curr(13,2))       
      end as PRICESUM,      
      C.waers as WAERS,
      B.meprf,
      B.prdat,
      B.netpr as kbetr,
      C.waers as konwa,
      B.peinh as kpein,
      B.bprme as kmein,
      B.mwskz
} where A.lifnr <> '' and A.xauto = '' and A.sobkz <> 'K'
  and C.bsart <> 'MB' and A.bwart <> '543' and A.bwart <> '544' and B.meprf <> '5'
