@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매 정산 용 구매 HISTORY SUMMARY'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_EKBE_HISTORY2 
as select from ZGTMM_CV_GET_EKBE_HISTORY as A 
//      left outer join ZGTMM_CV_GET_EKBE_HISTORY_IV2 as B on A.mjahr = B.MJAHR and A.mblnr = B.MBLNR and A.zeile = B.ZEILE
association [0..1] to lfa1  as vd on $projection.lifnr = vd.lifnr 
association [0..1] to ZGTMM_CV_GET_TAX_RATE   as TAX on $projection.MWSKZ = TAX.mwskz       
{
   key A.ebeln,
   key A.ebelp,
   key A.mjahr,
   key A.mblnr,
   key A.zeile,
       A.XRECH,     
       A.SPMON,
       A.bukrs,
       A.ekorg,
       A.ekgrp,
       A.lifnr,
       A.LIFNR_N,
       A.pstyp,
       @Semantics.quantity.unitOfMeasure: 'MEINS'           
       sum(A.menge) as MENGE,    //입고수량
       A.meins,
       @Semantics.amount.currencyCode: 'HSWAE'       
       sum(A.DMBTR) as DMBTR,     //현지통화
       @Semantics.amount.currencyCode: 'waers'
       sum(A.WRBTR) as WRBTR,     //전표통화
       A.waers,
       A.hswae,     //현지통화키
 //    A.cpudt,
//     A.cputm,
       A.matnr,
       A.txz01,
       A.COLOR,
       A.LENGTH,            
       A.LENUNIT,                
       A.werks,
       A.eindt,
       A.webre,
       A.MWSKZ,
       A.meprf,
       A.prdat,
       @Semantics.amount.currencyCode: 'waers'
       A.netpr,     //구매발주단가
       A.peinh,     //단위
       A.bedat,
       @Semantics.amount.currencyCode: 'waers'
       A.ETIV_PRICE, //유효단가
       A.ETIV_PEINH, //유효단가 가격 단위,            
       A.ETIV_MEINS, //유효단가 단위     
       A.ETIV_waers, //유효단가 통화 
       @Semantics.quantity.unitOfMeasure: 'BSTME_IV'        
       sum(A.MENGE_IV) as MENGE_IV,
       A.BSTME_IV,
       @Semantics.amount.currencyCode: 'waers_IV'       
       sum(A.WRBTR_IV) as WRBTR_IV,   
       A.WAERS_IV,
       A.BPWAERS,

   /*    @Semantics.amount.currencyCode: 'waers_IV'   
 
                case when  A.ETIV_MEINS = A.meins then
                    case when MENGE_IV is not null then
                           case when MENGE_IV >= A.menge then 
                                cast(ROUND(cast(cast(0 * CURR_TO_DECFLOAT_AMOUNT(A.ETIV_PRICE) / A.ETIV_PEINH as abap.dec(13,2)) as abap.curr(13,2)),2) as abap.curr(13,2))
                                else 
                                cast(ROUND(cast(cast(cast( (A.menge - MENGE_IV) * CURR_TO_DECFLOAT_AMOUNT(A.ETIV_PRICE) / A.ETIV_PEINH as abap.dec(13,2)) / 100 as abap.dec(13,2)) as abap.curr(13,2)),2) as abap.curr(13,2)) end
            
                    
                        else
                            cast(ROUND(cast(cast(cast( A.menge * CURR_TO_DECFLOAT_AMOUNT(A.ETIV_PRICE) / A.ETIV_PEINH as abap.dec(13,2)) / 100 as abap.dec(13,2))  as abap.curr(13,2)),2) as abap.curr(13,2))
                        end 
                   else
                     case when A.ETIV_MEINS = 'KM' or A.ETIV_MEINS = 'KG'  then
            
                        case when MENGE_IV is not null then
                               case when MENGE_IV >= A.menge then 
                                    cast(ROUND(cast(cast(0 * CURR_TO_DECFLOAT_AMOUNT(A.ETIV_PRICE) / A.ETIV_PEINH / 1000 as abap.dec(13,2))  as abap.curr(13,2)),2) as abap.curr(13,2))
                                    else 
                                    cast(ROUND(cast(cast( (A.menge - MENGE_IV) * CURR_TO_DECFLOAT_AMOUNT(A.ETIV_PRICE) / A.ETIV_PEINH / 100 / 1000 as abap.dec(13,2)) as abap.curr(13,2)),2)  as abap.curr(13,2)) end
                
                        
                            else
                                cast(ROUND(cast(cast(cast( A.menge * CURR_TO_DECFLOAT_AMOUNT(A.ETIV_PRICE) / A.ETIV_PEINH as abap.dec(13,2)) / 100 / 1000 as abap.dec(13,2))  as abap.curr(13,2)),2) as abap.curr(13,2))
                            end 
                     when A.ETIV_MEINS = 'M' or A.ETIV_MEINS = 'G'  then
                          case when MENGE_IV is not null then
                               case when MENGE_IV >= A.menge then 
                                    cast(ROUND(cast(cast(0 * CURR_TO_DECFLOAT_AMOUNT(A.ETIV_PRICE) / A.ETIV_PEINH * 1000 as abap.dec(13,2))  as abap.curr(13,2)),2) as abap.curr(13,2))
                                    else 
                                    cast(ROUND(cast(cast( (A.menge - MENGE_IV) * CURR_TO_DECFLOAT_AMOUNT(A.ETIV_PRICE) / A.ETIV_PEINH / 100 * 1000 as abap.dec(13,2)) as abap.curr(13,2)),2) as abap.curr(13,2)) end
                
                        
                            else
                                cast(ROUND(cast(cast(cast( A.menge * CURR_TO_DECFLOAT_AMOUNT(A.ETIV_PRICE) / A.ETIV_PEINH as abap.dec(13,2)) / 100 * 1000 as abap.dec(13,2))  as abap.curr(13,2)),2) as abap.curr(13,2))
                            end      
                     end
                   end as TARGET_PRICE,
       
  
           
       @Semantics.amount.currencyCode: 'waers_IV'                
 
               case when TAX.RATE > 0 then
       
                    case when  A.ETIV_MEINS = A.meins then
                       case when MENGE_IV is not null then
                           case when MENGE_IV >= A.menge then 
                                      cast( cast(0 * CURR_TO_DECFLOAT_AMOUNT(A.ETIV_PRICE) / A.ETIV_PEINH / (TAX.RATE * 100) as abap.dec(13,2))  as abap.curr(13,2)) 
                                else 
                                     cast( cast((A.menge - MENGE_IV) * CURR_TO_DECFLOAT_AMOUNT(A.ETIV_PRICE) / A.ETIV_PEINH / (TAX.RATE * 100) as abap.dec(13,2))   as abap.curr(13,2))   end
                        else
                                    cast( cast( A.menge * CURR_TO_DECFLOAT_AMOUNT(A.ETIV_PRICE) / A.ETIV_PEINH / (TAX.RATE * 100)  as abap.dec(13,2))  as abap.curr(13,2)) 
                        end   
                     else
                       case when A.ETIV_MEINS = 'KM' or A.ETIV_MEINS = 'KG'  then
                              case when MENGE_IV is not null then
                                   case when MENGE_IV >= A.menge then 
                                      cast( cast(0 * CURR_TO_DECFLOAT_AMOUNT(A.ETIV_PRICE) / A.ETIV_PEINH / (TAX.RATE * 100) / 1000 as abap.dec(13,2))  as abap.curr(13,2)) 
                                  else 
                                     cast( cast((A.menge - MENGE_IV) * CURR_TO_DECFLOAT_AMOUNT(A.ETIV_PRICE) / A.ETIV_PEINH / (TAX.RATE * 100) / 1000 as abap.dec(13,2))   as abap.curr(13,2))   end
                               else
                                    cast( cast( A.menge * CURR_TO_DECFLOAT_AMOUNT(A.ETIV_PRICE) / A.ETIV_PEINH / (TAX.RATE * 100) / 1000 as abap.dec(13,2))  as abap.curr(13,2)) 
                               end              
                             when A.ETIV_MEINS = 'M' or A.ETIV_MEINS = 'G'  then
                               case when MENGE_IV is not null then
                                    case when MENGE_IV >= A.menge then 
                                      cast( cast(0 * CURR_TO_DECFLOAT_AMOUNT(A.ETIV_PRICE) / A.ETIV_PEINH / (TAX.RATE * 100) * 1000 as abap.dec(13,2))  as abap.curr(13,2)) 
                                else 
                                     cast( cast((A.menge - MENGE_IV) * CURR_TO_DECFLOAT_AMOUNT(A.ETIV_PRICE) / A.ETIV_PEINH / (TAX.RATE * 100) * 1000 as abap.dec(13,2))   as abap.curr(13,2))   end
                             else
                                    cast( cast( A.menge * CURR_TO_DECFLOAT_AMOUNT(A.ETIV_PRICE) / A.ETIV_PEINH / (TAX.RATE * 100) * 1000 as abap.dec(13,2))  as abap.curr(13,2)) 
                             end 
                           end
                     end
                 
                    else
                               cast(0 as abap.curr(13,2))              
                    end      as  TAXPRICE,  */

                
        @Semantics.quantity.unitOfMeasure: 'IV_UNIT'         
        sum(A.IV_QTY) as IV_QTY,
        A.IV_UNIT, 
        A.RATE,
        A.BPUMN,
        
        @Semantics.quantity.unitOfMeasure: 'IV_UNIT'  
        sum(A.IV_OQTY) as IV_OQTY,
        A.vbeln,
        A.posnr
 
} 
group by A.ebeln, A.ebelp, A.mjahr, A.mblnr, A.zeile,  A.SPMON, A.bukrs, A.ekorg, A.ekgrp, A.lifnr, 
         A.LIFNR_N, A.pstyp, A.meins, A.waers, A.hswae,  A.matnr, A.txz01,
         A.COLOR, A.LENGTH, A.LENUNIT, A.werks, A.eindt, A.webre, A.MWSKZ, A.meprf, A.prdat, A.netpr, A.peinh,
         A.bedat,  A.ETIV_PRICE, A.ETIV_PEINH, A.ETIV_MEINS,  A.ETIV_waers, //유효단가 통화 
         A.BSTME_IV, A.WAERS_IV, A.BPWAERS, A.IV_UNIT, A.RATE, A.BPUMN,A.XRECH, A.vbeln, A.posnr

