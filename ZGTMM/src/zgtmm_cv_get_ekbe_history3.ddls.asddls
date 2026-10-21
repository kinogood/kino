@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매 정산 용 구매 HISTORY SUMMARY3'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_EKBE_HISTORY3 
as select from ZGTMM_CV_GET_EKBE_HISTORY2   
{
   key ebeln,
   key ebelp,
   key mjahr,
   key mblnr,
   key zeile,
       XRECH,
       SPMON,
       bukrs,
       ekorg,
       ekgrp,
       lifnr,
       LIFNR_N,
       pstyp,
       @Semantics.quantity.unitOfMeasure: 'MEINS'           
       MENGE,    //입고수량
       meins,
       @Semantics.amount.currencyCode: 'HSWAE'       
       DMBTR,     //현지통화
       @Semantics.amount.currencyCode: 'waers'
       WRBTR,     //전표통화
       waers,
       hswae,     //현지통화키
    //   cpudt,
    //   cputm,
       matnr,
       txz01,
       COLOR,
       LENGTH,            
       LENUNIT,                
       werks,
       eindt,
       webre,
       MWSKZ,
       meprf,
       prdat,
       @Semantics.amount.currencyCode: 'waers'
       netpr,     //구매발주단가
       peinh,     //단위
       bedat,
       @Semantics.amount.currencyCode: 'waers'
       ETIV_PRICE, //유효단가
       ETIV_PEINH, //유효단가 가격 단위,            
       ETIV_MEINS, //유효단가 단위     
       ETIV_waers, //유효단가 통화 
       
       @Semantics.quantity.unitOfMeasure: 'BSTME_IV'           
       MENGE_IV,
       BSTME_IV,
       @Semantics.amount.currencyCode: 'waers_IV'       
       WRBTR_IV,
       WAERS_IV,
       BPWAERS,
  
//       case when MENGE_IV >= menge  then cast('X' as abap.char(1)) else cast('' as abap.char(1)) end  as IV_COMPLETE,       
     //  IV_COMPLETE,  

     @Semantics.amount.currencyCode: 'waers_IV'   
 
                case when  ETIV_MEINS = meins then
                    case when MENGE_IV is not null then
                           case when MENGE_IV >= MENGE then 
                                cast(ROUND(cast(cast(0 * CURR_TO_DECFLOAT_AMOUNT(ETIV_PRICE) / ETIV_PEINH as abap.dec(13,2)) as abap.curr(13,2)),2) as abap.curr(13,2))
                                else 
                                cast(ROUND(cast(cast(cast( (MENGE - MENGE_IV) * CURR_TO_DECFLOAT_AMOUNT(ETIV_PRICE) / ETIV_PEINH as abap.dec(13,2)) / 100 as abap.dec(13,2)) as abap.curr(13,2)),2) as abap.curr(13,2)) end
            
                    
                        else
                            cast(ROUND(cast(cast(cast( MENGE * CURR_TO_DECFLOAT_AMOUNT(ETIV_PRICE) / ETIV_PEINH as abap.dec(13,2)) / 100 as abap.dec(13,2))  as abap.curr(13,2)),2) as abap.curr(13,2))
                        end 
                   else
                     case when ETIV_MEINS = 'KM' or ETIV_MEINS = 'KG'  then
            
                        case when MENGE_IV is not null then
                               case when MENGE_IV >= MENGE then 
                                    cast(ROUND(cast(cast(0 * CURR_TO_DECFLOAT_AMOUNT(ETIV_PRICE) / ETIV_PEINH / 1000 as abap.dec(13,2))  as abap.curr(13,2)),2) as abap.curr(13,2))
                                    else 
                                    cast(ROUND(cast(cast( (MENGE - MENGE_IV) * CURR_TO_DECFLOAT_AMOUNT(ETIV_PRICE) / ETIV_PEINH / 100 / 1000 as abap.dec(13,2)) as abap.curr(13,2)),2)  as abap.curr(13,2)) end
                
                        
                            else
                                cast(ROUND(cast(cast(cast( MENGE * CURR_TO_DECFLOAT_AMOUNT(ETIV_PRICE) / ETIV_PEINH as abap.dec(13,2)) / 100 / 1000 as abap.dec(13,2))  as abap.curr(13,2)),2) as abap.curr(13,2))
                            end 
                     when ETIV_MEINS = 'M' or ETIV_MEINS = 'G'  then
                          case when MENGE_IV is not null then
                               case when MENGE_IV >= MENGE then 
                                    cast(ROUND(cast(cast(0 * CURR_TO_DECFLOAT_AMOUNT(ETIV_PRICE) / ETIV_PEINH * 1000 as abap.dec(13,2))  as abap.curr(13,2)),2) as abap.curr(13,2))
                                    else 
                                    cast(ROUND(cast(cast( (MENGE - MENGE_IV) * CURR_TO_DECFLOAT_AMOUNT(ETIV_PRICE) / ETIV_PEINH / 100 * 1000 as abap.dec(13,2)) as abap.curr(13,2)),2) as abap.curr(13,2)) end
                
                        
                            else
                                cast(ROUND(cast(cast(cast( MENGE * CURR_TO_DECFLOAT_AMOUNT(ETIV_PRICE) / ETIV_PEINH as abap.dec(13,2)) / 100 * 1000 as abap.dec(13,2))  as abap.curr(13,2)),2) as abap.curr(13,2))
                            end      
                     end
                   end as TARGET_PRICE,

              @Semantics.amount.currencyCode: 'waers_IV'                
 
               case when RATE > 0 then
       
                    case when  ETIV_MEINS = meins then
                       case when MENGE_IV is not null then
                           case when MENGE_IV >= MENGE then 
                                      cast( cast(0 * CURR_TO_DECFLOAT_AMOUNT(ETIV_PRICE) / ETIV_PEINH / (RATE * 100) as abap.dec(13,2))  as abap.curr(13,2)) 
                                else 
                                     cast( cast((MENGE - MENGE_IV) * CURR_TO_DECFLOAT_AMOUNT(ETIV_PRICE) / ETIV_PEINH / (RATE * 100) as abap.dec(13,2))   as abap.curr(13,2))   end
                        else
                                    cast( cast( MENGE * CURR_TO_DECFLOAT_AMOUNT(ETIV_PRICE) / ETIV_PEINH / (RATE * 100)  as abap.dec(13,2))  as abap.curr(13,2)) 
                        end   
                     else
                       case when ETIV_MEINS = 'KM' or ETIV_MEINS = 'KG'  then
                              case when MENGE_IV is not null then
                                   case when MENGE_IV >= MENGE then 
                                      cast( cast(0 * CURR_TO_DECFLOAT_AMOUNT(ETIV_PRICE) / ETIV_PEINH / (RATE * 100) / 1000 as abap.dec(13,2))  as abap.curr(13,2)) 
                                  else 
                                     cast( cast((MENGE - MENGE_IV) * CURR_TO_DECFLOAT_AMOUNT(ETIV_PRICE) / ETIV_PEINH / (RATE * 100) / 1000 as abap.dec(13,2))   as abap.curr(13,2))   end
                               else
                                    cast( cast( MENGE * CURR_TO_DECFLOAT_AMOUNT(ETIV_PRICE) / ETIV_PEINH / (RATE * 100) / 1000 as abap.dec(13,2))  as abap.curr(13,2)) 
                               end              
                             when ETIV_MEINS = 'M' or ETIV_MEINS = 'G'  then
                               case when MENGE_IV is not null then
                                    case when MENGE_IV >= MENGE then 
                                      cast( cast(0 * CURR_TO_DECFLOAT_AMOUNT(ETIV_PRICE) / ETIV_PEINH / (RATE * 100) * 1000 as abap.dec(13,2))  as abap.curr(13,2)) 
                                else 
                                     cast( cast((MENGE - MENGE_IV) * CURR_TO_DECFLOAT_AMOUNT(ETIV_PRICE) / ETIV_PEINH / (RATE * 100) * 1000 as abap.dec(13,2))   as abap.curr(13,2))   end
                             else
                                    cast( cast( MENGE * CURR_TO_DECFLOAT_AMOUNT(ETIV_PRICE) / ETIV_PEINH / (RATE * 100) * 1000 as abap.dec(13,2))  as abap.curr(13,2)) 
                             end 
                           end
                     end
                 
                    else
                               cast(0 as abap.curr(13,2))              
                    end      as  TAXPRICE,       

/*       @Semantics.amount.currencyCode: 'waers_IV'   
       sum(TARGET_PRICE) as TARGET_PRICE,
        
       @Semantics.amount.currencyCode: 'waers_IV'                
       sum(TAXPRICE) as TAXPRICE, */
                       
       @Semantics.quantity.unitOfMeasure: 'IV_UNIT'         
       IV_QTY,
       IV_UNIT, 
       RATE,
       BPUMN,
       @Semantics.quantity.unitOfMeasure: 'IV_UNIT'  
       IV_OQTY,
       vbeln,
       posnr
 
} 
