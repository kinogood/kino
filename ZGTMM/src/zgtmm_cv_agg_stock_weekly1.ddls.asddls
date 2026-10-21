@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '주 단위 적정재고 SIMULATION BASE'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_AGG_STOCK_WEEKLY1 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as

// 예상 소요량 기준 - 01 소요량
select from ZGTMM_CV_RESB_REQCAL_WEEKLY as A
       left outer join ZGTMM_CV_RESB_WEEKLY_CAL1 as B on A.bukrs = B.bukrs and A.werks = B.werks and A.matnr = B.matnr 
 
{
   key  A.bukrs,
   key  A.BUKRS_N,   
   key  A.werks,
   key  A.werks_n,
   key  A.matnr,
   key  A.matnr_n, 
   
        cast('A' as abap.char(1)) as TYPE,  
        cast('계획소요량' as abap.char(20)) as TYPENAME, 
        A.LT,                                                // LeadTime 
        A.servicefactor, 
                
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        A.REQQTY,                    //총예약수량
        A.meins,       

        @Semantics.quantity.unitOfMeasure: 'MEINS'
        A.REQ_DAILY,     
        @Semantics.quantity.unitOfMeasure: 'MEINS' 
        A.UNQTY,                                         // 창고가용재고
        
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        A.BONDEDQTY,                // 보세창고재고        
        @Semantics.amount.currencyCode: 'waers'
        A.STOCKVAL,                  // 현 재고 금액
        A.waers,  

        A.F1,  

        @Semantics.quantity.unitOfMeasure: 'MEINS'             
        A.F2,
        A.PLANWEEK,

        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        case when B.REQQTY is not null then
          case B.WEEKDIFF when 0 then  B.REQQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3)) end as W0,
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        case when B.REQQTY is not null then
          case B.WEEKDIFF when 1 then  B.REQQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3)) end as W1,        
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        case when B.REQQTY is not null then        
        case B.WEEKDIFF when 2 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W2,    
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        case when B.REQQTY is not null then        
        case B.WEEKDIFF when 3 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W3,    
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        case when B.REQQTY is not null then        
        case B.WEEKDIFF when 4 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W4,    
        @Semantics.quantity.unitOfMeasure: 'MEINS'    
        case when B.REQQTY is not null then
        case B.WEEKDIFF when 5 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W5,  
        @Semantics.quantity.unitOfMeasure: 'MEINS'     
        case when B.REQQTY is not null then   
        case B.WEEKDIFF when 6 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W6,        
        @Semantics.quantity.unitOfMeasure: 'MEINS'     
        case when B.REQQTY is not null then           
        case B.WEEKDIFF when 7 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W7,    
        @Semantics.quantity.unitOfMeasure: 'MEINS'   
        case when B.REQQTY is not null then             
        case B.WEEKDIFF when 8 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W8,    
        @Semantics.quantity.unitOfMeasure: 'MEINS'    
        case when B.REQQTY is not null then            
        case B.WEEKDIFF when 9 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W9,    
        @Semantics.quantity.unitOfMeasure: 'MEINS'     
        case when B.REQQTY is not null then           
        case B.WEEKDIFF when 10 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W10, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'     
        case when B.REQQTY is not null then           
        case B.WEEKDIFF when 11 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W11,        
        @Semantics.quantity.unitOfMeasure: 'MEINS'  
        case when B.REQQTY is not null then              
        case B.WEEKDIFF when 12 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W12,    
        @Semantics.quantity.unitOfMeasure: 'MEINS'       
        case when B.REQQTY is not null then         
        case B.WEEKDIFF when 13 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W13,    
        @Semantics.quantity.unitOfMeasure: 'MEINS'    
        case when B.REQQTY is not null then        
        case B.WEEKDIFF when 14 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W14,    
        @Semantics.quantity.unitOfMeasure: 'MEINS'   
        case when B.REQQTY is not null then             
        case B.WEEKDIFF when 15 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W15      
}


union all


// 예상 소요량 기준 - 02 입고 예정량(구매요청 잔량)   
select from ZGTMM_CV_RESB_REQCAL_WEEKLY as A
       left outer join ZGTMM_CV_RESERVED_PR_WEEKLY as B on A.werks = B.werks and A.matnr = B.matnr 

{
   key  A.bukrs,
   key  A.BUKRS_N,   
   key  A.werks,
   key  A.werks_n,
   key  A.matnr,
   key  A.matnr_n, 
   
        cast('B' as abap.char(1)) as TYPE,   
        cast('입고예정(PR)' as abap.char(20)) as TYPENAME,         
        A.LT,                                                // LeadTime 
        A.servicefactor, 
                
        A.REQQTY,                    //총예약수량
        A.meins,       

        A.REQ_DAILY,     
        A.UNQTY,                                         // 창고가용재고
        
        A.BONDEDQTY,                // 보세창고재고        
        A.STOCKVAL,                  // 현 재고 금액
        A.waers,  

        A.F1,  

        A.F2,
        A.PLANWEEK,

        case when B.REQTY is not null then
        case B.WEEKDIFF when 0 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W0,       
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 1 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W1,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 2 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W2,                 
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 3 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W3,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 4 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W4,                 
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 5 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W5,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 6 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W6,                 
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 7 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W7,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 8 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W8,     
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 9 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W9,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 10 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W10,                 
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 11 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W11,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 12 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W12,                
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 13 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W13,                 
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 14 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W14,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 15 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W15                     
}


union all


// 예상 소요량 기준 - 03 입고 예정량(PO 잔량)   
select from ZGTMM_CV_RESB_REQCAL_WEEKLY as A
       left outer join ZGTMM_CV_RESERVED_GR_WEEKLY  as B on A.werks = B.werks and A.matnr = B.matnr 

{
   key  A.bukrs,
   key  A.BUKRS_N,   
   key  A.werks,
   key  A.werks_n,
   key  A.matnr,
   key  A.matnr_n, 
   
        cast('C' as abap.char(1)) as TYPE,   
        cast('입고예정(PO)' as abap.char(20)) as TYPENAME,         
        A.LT,                                                // LeadTime 
        A.servicefactor, 
                
        A.REQQTY,                    //총예약수량
        A.meins,       

        A.REQ_DAILY,     
        A.UNQTY,                                         // 창고가용재고
        
        A.BONDEDQTY,                // 보세창고재고        
        A.STOCKVAL,                  // 현 재고 금액
        A.waers,  

        A.F1,  

        A.F2,
        A.PLANWEEK,

        case when B.REQTY is not null then
        case B.WEEKDIFF when 0 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W0,   
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 1 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W1,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 2 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W2,                 
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 3 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W3,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 4 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W4,                 
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 5 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W5,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 6 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W6,                 
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 7 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W7,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 8 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W8,     
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 9 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W9,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 10 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W10,                 
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 11 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W11,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 12 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W12,                
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 13 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W13,                 
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 14 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W14,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 15 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W15                     
}

union all
// 예상 소요량 기준 - 04 1차 SIMMULATION
select from ZGTMM_CV_RESB_REQCAL_WEEKLY as A
{
   key  A.bukrs,
   key  A.BUKRS_N,   
   key  A.werks,
   key  A.werks_n,
   key  A.matnr,
   key  A.matnr_n, 
   
        cast('D' as abap.char(1)) as TYPE,  
        cast('Simul.Syst' as abap.char(20)) as TYPENAME, 
        A.LT,                                                // LeadTime 
        A.servicefactor, 

        A.REQQTY,                    //총예약수량
        A.meins,       

        A.REQ_DAILY,     
        A.UNQTY,                                         // 창고가용재고
        
        A.BONDEDQTY,                // 보세창고재고        
        A.STOCKVAL,                  // 현 재고 금액
        A.waers,
        
        A.F1,  

        A.F2,
        A.PLANWEEK,
 
        cast(0 as abap.quan(21,3)) as W0,         
        cast(0 as abap.quan(21,3)) as W1,        
        cast(0 as abap.quan(21,3)) as W2,  
        cast(0 as abap.quan(21,3)) as W3,        
        cast(0 as abap.quan(21,3)) as W4,      
        cast(0 as abap.quan(21,3)) as W5,        
        cast(0 as abap.quan(21,3)) as W6,  
        cast(0 as abap.quan(21,3)) as W7,        
        cast(0 as abap.quan(21,3)) as W8,
        cast(0 as abap.quan(21,3)) as W9,        
        cast(0 as abap.quan(21,3)) as W10,  
        cast(0 as abap.quan(21,3)) as W11,        
        cast(0 as abap.quan(21,3)) as W12,
        cast(0 as abap.quan(21,3)) as W13,  
        cast(0 as abap.quan(21,3)) as W14,        
        cast(0 as abap.quan(21,3)) as W15
}

union all
// 예상 소요량 기준 - 05 입고 예정 변경
select from ZGTMM_CV_RESB_REQCAL_WEEKLY as A
       left outer join ZGTMM_CV_RESERVED_PR_WEEKLY as B on A.werks = B.werks and A.matnr = B.matnr 
       left outer join ZGTMM_CV_RESERVED_GR_WEEKLY  as C on A.werks = C.werks and A.matnr = C.matnr       
{
   key  A.bukrs,
   key  A.BUKRS_N,   
   key  A.werks,
   key  A.werks_n,
   key  A.matnr,
   key  A.matnr_n, 
   
        cast('E' as abap.char(1)) as TYPE,  
        cast('입고예정변경' as abap.char(20)) as TYPENAME, 
        A.LT,                                                // LeadTime 
        A.servicefactor, 

        A.REQQTY,                    //총예약수량
        A.meins,       

        A.REQ_DAILY,     
        A.UNQTY,                                         // 창고가용재고
        
        A.BONDEDQTY,                // 보세창고재고        
        A.STOCKVAL,                  // 현 재고 금액
        A.waers,
        
        A.F1,  

        A.F2,
        A.PLANWEEK,
        
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 0
                                 then case when C.WEEKDIFF = 0
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 0
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 0
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 0
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W0, 
                       

        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 1
                                 then case when C.WEEKDIFF = 1
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 1
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 1
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 1
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W1,                                  

        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 2
                                 then case when C.WEEKDIFF = 2
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 2
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 2
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 2
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W2, 
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 3
                                 then case when C.WEEKDIFF = 3
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 3
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 3
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 3
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W3,              

        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 4
                                 then case when C.WEEKDIFF = 4
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 4
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 4
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 4
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W4,       
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 5
                                 then case when C.WEEKDIFF = 5
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 5
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 5
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 5
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W5,       
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 6
                                 then case when C.WEEKDIFF = 6
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 6
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 6
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 6
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W6,  
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 7
                                 then case when C.WEEKDIFF = 7
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 7
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 7
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 7
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W7,     
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 8
                                 then case when C.WEEKDIFF = 8
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 8
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 8
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 8
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W8,        
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 9
                                 then case when C.WEEKDIFF = 9
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 9
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 9
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 9
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W9,    
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 10
                                 then case when C.WEEKDIFF = 10
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 10
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 10
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 10
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W10,            
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 11
                                 then case when C.WEEKDIFF = 11
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 11
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 11
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 11
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W11,        
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 12
                                 then case when C.WEEKDIFF = 12
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 12
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 12
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 12
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W12,  
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 13
                                 then case when C.WEEKDIFF = 13
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 13
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 13
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 13
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W13,   
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 14
                                 then case when C.WEEKDIFF = 14
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 14
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 14
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 14
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W14,  
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 15
                                 then case when C.WEEKDIFF = 15
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 15
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 15
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 15
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W15      
        
}

union all
// 예상 소요량 기준 - 06 2차 SIMULATION 필드
select from ZGTMM_CV_RESB_REQCAL_WEEKLY as A

{
   key  A.bukrs,
   key  A.BUKRS_N,   
   key  A.werks,
   key  A.werks_n,
   key  A.matnr,
   key  A.matnr_n, 
   
        cast('F' as abap.char(1)) as TYPE,  
        cast('Simul.User' as abap.char(20)) as TYPENAME, 
        A.LT,                                                // LeadTime 
        A.servicefactor, 

        A.REQQTY,                    //총예약수량
        A.meins,       

        A.REQ_DAILY,     
        A.UNQTY,                                         // 창고가용재고
        
        A.BONDEDQTY,                // 보세창고재고        
        A.STOCKVAL,                  // 현 재고 금액
        A.waers,
        
        A.F1,  

        A.F2,
        A.PLANWEEK,

        cast(0 as abap.quan(21,3)) as W0,            
        cast(0 as abap.quan(21,3)) as W1,        
        cast(0 as abap.quan(21,3)) as W2,  
        cast(0 as abap.quan(21,3)) as W3,        
        cast(0 as abap.quan(21,3)) as W4,      
        cast(0 as abap.quan(21,3)) as W5,        
        cast(0 as abap.quan(21,3)) as W6,  
        cast(0 as abap.quan(21,3)) as W7,        
        cast(0 as abap.quan(21,3)) as W8,
        cast(0 as abap.quan(21,3)) as W9,        
        cast(0 as abap.quan(21,3)) as W10,  
        cast(0 as abap.quan(21,3)) as W11,        
        cast(0 as abap.quan(21,3)) as W12,
        cast(0 as abap.quan(21,3)) as W13,  
        cast(0 as abap.quan(21,3)) as W14,        
        cast(0 as abap.quan(21,3)) as W15
}
/*
union all
// 예상 소요량 기준 - 05 입고 예정 변경
select from ZGTMM_CV_RESB_REQCAL_WEEKLY as A
{
   key  A.bukrs,
   key  A.BUKRS_N,   
   key  A.werks,
   key  A.werks_n,
   key  A.matnr,
   key  A.matnr_n, 
   
        cast('E' as abap.char(1)) as TYPE,  
        cast('입고예정변경' as abap.char(20)) as TYPENAME, 
        A.LT,                                                // LeadTime 
        A.servicefactor, 

        A.REQQTY,                    //총예약수량
        A.meins,       

        A.REQ_DAILY,     
        A.UNQTY,                                         // 창고가용재고
        
        A.BONDEDQTY,                // 보세창고재고        
        A.STOCKVAL,                  // 현 재고 금액
        A.waers,
        
        A.F1,  

        A.F2,
        A.PLANWEEK,

        cast(0 as abap.quan(21,3)) as W0,          
        cast(0 as abap.quan(21,3)) as W1,        
        cast(0 as abap.quan(21,3)) as W2,  
        cast(0 as abap.quan(21,3)) as W3,        
        cast(0 as abap.quan(21,3)) as W4,      
        cast(0 as abap.quan(21,3)) as W5,        
        cast(0 as abap.quan(21,3)) as W6,  
        cast(0 as abap.quan(21,3)) as W7,        
        cast(0 as abap.quan(21,3)) as W8,
        cast(0 as abap.quan(21,3)) as W9,        
        cast(0 as abap.quan(21,3)) as W10,  
        cast(0 as abap.quan(21,3)) as W11,        
        cast(0 as abap.quan(21,3)) as W12,
        cast(0 as abap.quan(21,3)) as W13,  
        cast(0 as abap.quan(21,3)) as W14,        
        cast(0 as abap.quan(21,3)) as W15
}


*/
union all

// 과거 소모 기준 기준 - 04 소요량(실적기준)
select from ZGTMM_CV_GI_REQCAL_WEEKLY(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as A
       left outer join ZGTMM_CV_GI_WEEKLY_CAL1(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as B on A.bukrs = B.bukrs and A.werks = B.werks and A.matnr = B.matnr 

{
   key  A.bukrs,
   key  A.BUKRS_N,   
   key  A.werks,
   key  A.werks_n,
   key  A.matnr,
   key  A.matnr_n, 
   
        cast('G' as abap.char(1)) as TYPE,  
        cast('실적소요량' as abap.char(20)) as TYPENAME, 
        A.LT,                                                // LeadTime 
        A.servicefactor, 
                
        A.REQQTY,                    //총예약수량
        A.meins,       

        A.REQ_DAILY,     
        A.UNQTY,                                         // 창고가용재고
        
        A.BONDEDQTY,                // 보세창고재고        
        A.STOCKVAL,                  // 현 재고 금액
        A.waers,  

        A.F1,  

        A.F2,
        A.PLANWEEK,


        case when B.REQQTY is not null then
          case B.WEEKDIFF when 0 then  B.REQQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3)) end as W0,            
        case when B.REQQTY is not null then
          case B.WEEKDIFF when 1 then  B.REQQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3)) end as W1,        
        case when B.REQQTY is not null then        
        case B.WEEKDIFF when 2 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W2,    
        case when B.REQQTY is not null then        
        case B.WEEKDIFF when 3 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W3,    
        case when B.REQQTY is not null then        
        case B.WEEKDIFF when 4 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W4,    
        case when B.REQQTY is not null then
        case B.WEEKDIFF when 5 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W5,  
        case when B.REQQTY is not null then   
        case B.WEEKDIFF when 6 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W6,        
        case when B.REQQTY is not null then           
        case B.WEEKDIFF when 7 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W7,    
        case when B.REQQTY is not null then             
        case B.WEEKDIFF when 8 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W8,    
        case when B.REQQTY is not null then            
        case B.WEEKDIFF when 9 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W9,    
        case when B.REQQTY is not null then           
        case B.WEEKDIFF when 10 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W10, 
        case when B.REQQTY is not null then           
        case B.WEEKDIFF when 11 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W11,        
        case when B.REQQTY is not null then              
        case B.WEEKDIFF when 12 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W12,    
        case when B.REQQTY is not null then         
        case B.WEEKDIFF when 13 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W13,    
        case when B.REQQTY is not null then        
        case B.WEEKDIFF when 14 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W14,    
        case when B.REQQTY is not null then             
        case B.WEEKDIFF when 15 then  B.REQQTY else cast(0 as abap.quan(21,3)) end else cast(0 as abap.quan(21,3)) end as W15   
}

union all


// 예상 소요량 기준 - 05 입고 예정량(구매요청 잔량)   
select from ZGTMM_CV_GI_REQCAL_WEEKLY(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as A
       left outer join ZGTMM_CV_RESERVED_PR_WEEKLY as B on A.werks = B.werks and A.matnr = B.matnr 

{
   key  A.bukrs,
   key  A.BUKRS_N,   
   key  A.werks,
   key  A.werks_n,
   key  A.matnr,
   key  A.matnr_n, 
   
        cast('H' as abap.char(1)) as TYPE,   
        cast('입고예정(PR)' as abap.char(20)) as TYPENAME,         
        A.LT,                                                // LeadTime 
        A.servicefactor, 
                
        A.REQQTY,                    //총예약수량
        A.meins,       

        A.REQ_DAILY,     
        A.UNQTY,                                         // 창고가용재고
        
        A.BONDEDQTY,                // 보세창고재고        
        A.STOCKVAL,                  // 현 재고 금액
        A.waers,  

        A.F1,  

        A.F2,
        A.PLANWEEK,

        case when B.REQTY is not null then
        case B.WEEKDIFF when 0 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W0,  
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 1 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W1,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 2 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W2,                 
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 3 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W3,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 4 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W4,                 
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 5 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W5,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 6 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W6,                 
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 7 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W7,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 8 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W8,     
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 9 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W9,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 10 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W10,                 
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 11 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W11,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 12 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W12,                
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 13 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W13,                 
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 14 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W14,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 15 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W15                     
}


union all


// 예상 소요량 기준 - 06 입고 예정량(PO 잔량)   
select from ZGTMM_CV_GI_REQCAL_WEEKLY(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as A
       left outer join ZGTMM_CV_RESERVED_GR_WEEKLY  as B on A.werks = B.werks and A.matnr = B.matnr 

{
   key  A.bukrs,
   key  A.BUKRS_N,   
   key  A.werks,
   key  A.werks_n,
   key  A.matnr,
   key  A.matnr_n, 
   
        cast('I' as abap.char(1)) as TYPE,   
        cast('입고예정(PO)' as abap.char(20)) as TYPENAME,         
        A.LT,                                                // LeadTime 
        A.servicefactor, 
                
        A.REQQTY,                    //총예약수량
        A.meins,       

        A.REQ_DAILY,     
        A.UNQTY,                                         // 창고가용재고
        
        A.BONDEDQTY,                // 보세창고재고        
        A.STOCKVAL,                  // 현 재고 금액
        A.waers,  

        A.F1,  

        A.F2,
        A.PLANWEEK,
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 0 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W0,   
                
        case when B.REQTY is not null then
        case B.WEEKDIFF when 1 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W1,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 2 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W2,                 
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 3 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W3,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 4 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W4,                 
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 5 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3)) 
        end as W5,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 6 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W6,                 
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 7 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W7,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 8 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W8,     
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 9 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W9,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 10 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W10,                 
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 11 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W11,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 12 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W12,                
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 13 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W13,                 
        
        case when B.REQTY is not null then
        case B.WEEKDIFF when 14 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W14,        

        case when B.REQTY is not null then
        case B.WEEKDIFF when 15 then  B.REQTY else cast(0 as abap.quan(21,3)) end 
        else cast(0 as abap.quan(21,3))
        end as W15                     
}

union all
// 실적 소요량 기준 - 10 SIMULATION
select from ZGTMM_CV_GI_REQCAL_WEEKLY(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as A

{
   key  A.bukrs,
   key  A.BUKRS_N,   
   key  A.werks,
   key  A.werks_n,
   key  A.matnr,
   key  A.matnr_n, 
   
        cast('J' as abap.char(1)) as TYPE,  
        cast('Simul.Syst' as abap.char(20)) as TYPENAME, 
        A.LT,                                                // LeadTime 
        A.servicefactor, 

        A.REQQTY,                    //총예약수량
        A.meins,       

        A.REQ_DAILY,     
        A.UNQTY,                                         // 창고가용재고
        
        A.BONDEDQTY,                // 보세창고재고        
        A.STOCKVAL,                  // 현 재고 금액
        A.waers,
        
        A.F1,  

        A.F2,
        A.PLANWEEK,

        cast(0 as abap.quan(21,3)) as W0,           
        cast(0 as abap.quan(21,3)) as W1,        
        cast(0 as abap.quan(21,3)) as W2,  
        cast(0 as abap.quan(21,3)) as W3,        
        cast(0 as abap.quan(21,3)) as W4,      
        cast(0 as abap.quan(21,3)) as W5,        
        cast(0 as abap.quan(21,3)) as W6,  
        cast(0 as abap.quan(21,3)) as W7,        
        cast(0 as abap.quan(21,3)) as W8,
        cast(0 as abap.quan(21,3)) as W9,        
        cast(0 as abap.quan(21,3)) as W10,  
        cast(0 as abap.quan(21,3)) as W11,        
        cast(0 as abap.quan(21,3)) as W12,
        cast(0 as abap.quan(21,3)) as W13,  
        cast(0 as abap.quan(21,3)) as W14,        
        cast(0 as abap.quan(21,3)) as W15
}  

union all
// 예상 소요량 기준 - 05 입고 예정 변경
select from ZGTMM_CV_GI_REQCAL_WEEKLY(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as A
       left outer join ZGTMM_CV_RESERVED_PR_WEEKLY as B on A.werks = B.werks and A.matnr = B.matnr 
       left outer join ZGTMM_CV_RESERVED_GR_WEEKLY  as C on A.werks = C.werks and A.matnr = C.matnr       
{
   key  A.bukrs,
   key  A.BUKRS_N,   
   key  A.werks,
   key  A.werks_n,
   key  A.matnr,
   key  A.matnr_n, 
   
        cast('K' as abap.char(1)) as TYPE,  
        cast('입고예정변경' as abap.char(20)) as TYPENAME, 
        A.LT,                                                // LeadTime 
        A.servicefactor, 

        A.REQQTY,                    //총예약수량
        A.meins,       

        A.REQ_DAILY,     
        A.UNQTY,                                         // 창고가용재고
        
        A.BONDEDQTY,                // 보세창고재고        
        A.STOCKVAL,                  // 현 재고 금액
        A.waers,
        
        A.F1,  

        A.F2,
        A.PLANWEEK,
        
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 0
                                 then case when C.WEEKDIFF = 0
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 0
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 0
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 0
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W0, 
                       

        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 1
                                 then case when C.WEEKDIFF = 1
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 1
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 1
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 1
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W1,                                  

        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 2
                                 then case when C.WEEKDIFF = 2
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 2
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 2
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 2
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W2, 
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 3
                                 then case when C.WEEKDIFF = 3
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 3
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 3
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 3
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W3,              

        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 4
                                 then case when C.WEEKDIFF = 4
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 4
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 4
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 4
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W4,       
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 5
                                 then case when C.WEEKDIFF = 5
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 5
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 5
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 5
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W5,       
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 6
                                 then case when C.WEEKDIFF = 6
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 6
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 6
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 6
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W6,  
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 7
                                 then case when C.WEEKDIFF = 7
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 7
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 7
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 7
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W7,     
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 8
                                 then case when C.WEEKDIFF = 8
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 8
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 8
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 8
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W8,        
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 9
                                 then case when C.WEEKDIFF = 9
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 9
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 9
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 9
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W9,    
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 10
                                 then case when C.WEEKDIFF = 10
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 10
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 10
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 10
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W10,            
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 11
                                 then case when C.WEEKDIFF = 11
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 11
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 11
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 11
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W11,        
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 12
                                 then case when C.WEEKDIFF = 12
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 12
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 12
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 12
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W12,  
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 13
                                 then case when C.WEEKDIFF = 13
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 13
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 13
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 13
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W13,   
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 14
                                 then case when C.WEEKDIFF = 14
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 14
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 14
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 14
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W14,  
             
        case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.WEEKDIFF = 15
                                 then case when C.WEEKDIFF = 15
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.WEEKDIFF = 15
                                           then C.REQTY
                                           else cast(0 as abap.quan(21,3))
                                           end                                 
                                 end
                       else case when B.WEEKDIFF = 15
                                 then B.REQTY
                                 else  cast(0 as abap.quan(21,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.WEEKDIFF = 15
                                 then C.REQTY
                                 else cast(0 as abap.quan(21,3))                                
                                 end
                       else cast(0 as abap.quan(21,3))                       
                       end
             end as W15    
}   

union all
// 예상 소요량 기준 - 12 SIMULATION 필드
select from ZGTMM_CV_GI_REQCAL_WEEKLY(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as A

{
   key  A.bukrs,
   key  A.BUKRS_N,   
   key  A.werks,
   key  A.werks_n,
   key  A.matnr,
   key  A.matnr_n, 
   
        cast('L' as abap.char(1)) as TYPE,  
        cast('Simul.User' as abap.char(20)) as TYPENAME, 
        A.LT,                                                // LeadTime 
        A.servicefactor, 

        A.REQQTY,                    //총예약수량
        A.meins,       

        A.REQ_DAILY,     
        A.UNQTY,                                         // 창고가용재고
        
        A.BONDEDQTY,                // 보세창고재고        
        A.STOCKVAL,                  // 현 재고 금액
        A.waers,
        
        A.F1,  

        A.F2,
        A.PLANWEEK,

        cast(0 as abap.quan(21,3)) as W0,           
        cast(0 as abap.quan(21,3)) as W1,        
        cast(0 as abap.quan(21,3)) as W2,  
        cast(0 as abap.quan(21,3)) as W3,        
        cast(0 as abap.quan(21,3)) as W4,      
        cast(0 as abap.quan(21,3)) as W5,        
        cast(0 as abap.quan(21,3)) as W6,  
        cast(0 as abap.quan(21,3)) as W7,        
        cast(0 as abap.quan(21,3)) as W8,
        cast(0 as abap.quan(21,3)) as W9,        
        cast(0 as abap.quan(21,3)) as W10,  
        cast(0 as abap.quan(21,3)) as W11,        
        cast(0 as abap.quan(21,3)) as W12,
        cast(0 as abap.quan(21,3)) as W13,  
        cast(0 as abap.quan(21,3)) as W14,        
        cast(0 as abap.quan(21,3)) as W15   
        
}
/*


union all
// 예상 소요량 기준 - 11 입고 예정 변경
select from ZGTMM_CV_GI_REQCAL_WEEKLY(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as A

{
   key  A.bukrs,
   key  A.BUKRS_N,   
   key  A.werks,
   key  A.werks_n,
   key  A.matnr,
   key  A.matnr_n, 
   
        cast('K' as abap.char(1)) as TYPE,  
        cast('입고예정변경' as abap.char(20)) as TYPENAME, 
        A.LT,                                                // LeadTime 
        A.servicefactor, 

        A.REQQTY,                    //총예약수량
        A.meins,       

        A.REQ_DAILY,     
        A.UNQTY,                                         // 창고가용재고
        
        A.BONDEDQTY,                // 보세창고재고        
        A.STOCKVAL,                  // 현 재고 금액
        A.waers,
        
        A.F1,  

        A.F2,
        A.PLANWEEK,

        cast(0 as abap.quan(21,3)) as W0,           
        cast(0 as abap.quan(21,3)) as W1,        
        cast(0 as abap.quan(21,3)) as W2,  
        cast(0 as abap.quan(21,3)) as W3,        
        cast(0 as abap.quan(21,3)) as W4,      
        cast(0 as abap.quan(21,3)) as W5,        
        cast(0 as abap.quan(21,3)) as W6,  
        cast(0 as abap.quan(21,3)) as W7,        
        cast(0 as abap.quan(21,3)) as W8,
        cast(0 as abap.quan(21,3)) as W9,        
        cast(0 as abap.quan(21,3)) as W10,  
        cast(0 as abap.quan(21,3)) as W11,        
        cast(0 as abap.quan(21,3)) as W12,
        cast(0 as abap.quan(21,3)) as W13,  
        cast(0 as abap.quan(21,3)) as W14,        
        cast(0 as abap.quan(21,3)) as W15
}*/


