@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '주 단위 적정재고 SIMULATION BASE2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_AGG_STOCK_WEEKLY2 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as
select from ZGTMM_CV_AGG_STOCK_WEEKLY15(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as a
{
   key  a.bukrs,
   key  a.BUKRS_N,   
   key  a.werks,
   key  a.werks_n,
   key  a.matnr,
   key  a.matnr_n, 
   
        a.TYPE, 
        a.TYPENAME, 
        a.LT,                                                // LeadTime 
        a.servicefactor, 
                
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.REQQTY,                    //총예약수량
        a.meins,       

        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.REQ_DAILY,     
        @Semantics.quantity.unitOfMeasure: 'MEINS' 
        a.UNQTY,                                         // 창고가용재고
        
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.BONDEDQTY,                // 보세창고재고        
        @Semantics.amount.currencyCode: 'waers'
        a.STOCKVAL,                  // 현 재고 금액
        a.waers,  

        a.F1,  

        @Semantics.quantity.unitOfMeasure: 'MEINS'             
        a.F2,
        a.PLANWEEK,
 
 
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        a.W0,          
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        a.W1,        
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        a.W2,     
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        a.W3,        
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        a.W4,           
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        a.W5,        
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        a.W6,     
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        a.W7,        
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        a.W8,  
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        a.W9,        
        @Semantics.quantity.unitOfMeasure: 'MEINS'         
        a.W10,     
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        a.W11,        
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        a.W12,            
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        a.W13,     
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        a.W14,        
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        a.W15                
} where a.TYPE = 'A' or  a.TYPE = 'B' or a.TYPE = 'C' or a.TYPE = 'E' or a.TYPE = 'G' or a.TYPE = 'H' or a.TYPE = 'I' or a.TYPE = 'K'


union all

select from ZGTMM_CV_AGG_STOCK_WEEKLY15(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as a
       inner join ZGTMM_CV_AGG_STOCK_WEEKLY15(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as B
       on a.bukrs = B.bukrs and a.werks = B.werks and a.matnr = B.matnr 
       inner join ZGTMM_CV_AGG_STOCK_WEEKLY15(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as C
       on a.bukrs = C.bukrs and a.werks = C.werks and a.matnr = C.matnr        
{
   key  a.bukrs,
   key  a.BUKRS_N,   
   key  a.werks,
   key  a.werks_n,
   key  a.matnr,
   key  a.matnr_n, 
   
        a.TYPE, 
        a.TYPENAME, 
        a.LT,                                                // LeadTime 
        a.servicefactor, 
                
        a.REQQTY,                     //총예약수량
        a.meins,       

        a.REQ_DAILY,     
        a.UNQTY, 
        
        a.BONDEDQTY,    
        a.STOCKVAL,                  // 현 재고 금액
        a.waers,  

        a.F1,  

        a.F2,
        a.PLANWEEK,
 
        a.W0,          
        a.UNQTY + a.BONDEDQTY - B.W1 + C.W1 as W1,        
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2) 
                              + (C.W1 + C.W2) as W2,     
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3) 
                              + (C.W1 + C.W2 + C.W3) as W3,        
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4) 
                              + (C.W1 + C.W2 + C.W3 + C.W4) as W4,           
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4 + B.W5) 
                              + (C.W1 + C.W2 + C.W3 + C.W4 + C.W5) as W5,        
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4 + B.W5 + B.W6) 
                              + (C.W1 + C.W2 + C.W3 + C.W4 + C.W5 + C.W6) as W6,     
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4 + B.W5 + B.W6 + B.W7) 
                              + (C.W1 + C.W2 + C.W3 + C.W4 + C.W5 + C.W6 + C.W7) as W7,        
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4 + B.W5 + B.W6 + B.W7 + B.W8) 
                              + (C.W1 + C.W2 + C.W3 + C.W4 + C.W5 + C.W6 + C.W7 + C.W8) as W8,  
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4 + B.W5 + B.W6 + B.W7 + B.W8 + B.W9) 
                              + (C.W1 + C.W2 + C.W3 + C.W4 + C.W5 + C.W6 + C.W7 + C.W8 + C.W9) as W9,        
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4 + B.W5 + B.W6 + B.W7 + B.W8 + B.W9 + B.W10) 
                              + (C.W1 + C.W2 + C.W3 + C.W4 + C.W5 + C.W6 + C.W7 + C.W8 + C.W9 + C.W10) as W10,     
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4 + B.W5 + B.W6 + B.W7 + B.W8 + B.W9 + B.W10 + B.W11) 
                              + (C.W1 + C.W2 + C.W3 + C.W4 + C.W5 + C.W6 + C.W7 + C.W8 + C.W9 + C.W10 + C.W11) as W11,       
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4 + B.W5 + B.W6 + B.W7 + B.W8 + B.W9 + B.W10 + B.W11 + B.W12) 
                              + (C.W1 + C.W2 + C.W3 + C.W4 + C.W5 + C.W6 + C.W7 + C.W8 + C.W9 + C.W10 + C.W11 + C.W12) as W12,
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4 + B.W5 + B.W6 + B.W7 + B.W8 + B.W9 + B.W10 + B.W11 + B.W12 + B.W13) 
                              + (C.W1 + C.W2 + C.W3 + C.W4 + C.W5 + C.W6 + C.W7 + C.W8 + C.W9 + C.W10 + C.W11 + C.W12 + C.W13) as W13,     
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4 + B.W5 + B.W6 + B.W7 + B.W8 + B.W9 + B.W10 + B.W11 + B.W12 + B.W13 + B.W14) 
                              + (C.W1 + C.W2 + C.W3 + C.W4 + C.W5 + C.W6 + C.W7 + C.W8 + C.W9 + C.W10 + C.W11 + C.W12 + C.W13 + C.W14) as W14,        
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4 + B.W5 + B.W6 + B.W7 + B.W8 + B.W9 + B.W10 + B.W11 + B.W12 + B.W13 + B.W14 + B.W15) 
                              + (C.W1 + C.W2 + C.W3 + C.W4 + C.W5 + C.W6 + C.W7 + C.W8 + C.W9 + C.W10 + C.W11 + C.W12 + C.W13 + C.W14 + C.W15) as W15  
} where (a.TYPE = 'D' or a.TYPE = 'F') and B.TYPE = 'A' and C.TYPE ='E'

union all

select from ZGTMM_CV_AGG_STOCK_WEEKLY15(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as a
       inner join ZGTMM_CV_AGG_STOCK_WEEKLY15(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as B
       on a.bukrs = B.bukrs and a.werks = B.werks and a.matnr = B.matnr 
       inner join ZGTMM_CV_AGG_STOCK_WEEKLY15(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as C
       on a.bukrs = C.bukrs and a.werks = C.werks and a.matnr = C.matnr        
{
   key  a.bukrs,
   key  a.BUKRS_N,   
   key  a.werks,
   key  a.werks_n,
   key  a.matnr,
   key  a.matnr_n, 
   
        a.TYPE, 
        a.TYPENAME, 
        a.LT,                                                // LeadTime 
        a.servicefactor, 
                
        a.REQQTY,                    //총예약수량
        a.meins,       

        a.REQ_DAILY,     
        a.UNQTY,                                         // 창고가용재고
        
        a.BONDEDQTY,  
        a.STOCKVAL,                  // 현 재고 금액
        a.waers,  

        a.F1,  

        a.F2,
        a.PLANWEEK,
 
        a.W0,          
        a.UNQTY + a.BONDEDQTY - B.W1 + C.W1 as W1,        
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2) 
                              + (C.W1 + C.W2) as W2,     
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3) 
                              + (C.W1 + C.W2 + C.W3) as W3,        
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4) 
                              + (C.W1 + C.W2 + C.W3 + C.W4) as W4,           
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4 + B.W5) 
                              + (C.W1 + C.W2 + C.W3 + C.W4 + C.W5) as W5,        
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4 + B.W5 + B.W6) 
                              + (C.W1 + C.W2 + C.W3 + C.W4 + C.W5 + C.W6) as W6,     
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4 + B.W5 + B.W6 + B.W7) 
                              + (C.W1 + C.W2 + C.W3 + C.W4 + C.W5 + C.W6 + C.W7) as W7,        
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4 + B.W5 + B.W6 + B.W7 + B.W8) 
                              + (C.W1 + C.W2 + C.W3 + C.W4 + C.W5 + C.W6 + C.W7 + C.W8) as W8,  
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4 + B.W5 + B.W6 + B.W7 + B.W8 + B.W9) 
                              + (C.W1 + C.W2 + C.W3 + C.W4 + C.W5 + C.W6 + C.W7 + C.W8 + C.W9) as W9,        
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4 + B.W5 + B.W6 + B.W7 + B.W8 + B.W9 + B.W10) 
                              + (C.W1 + C.W2 + C.W3 + C.W4 + C.W5 + C.W6 + C.W7 + C.W8 + C.W9 + C.W10) as W10,     
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4 + B.W5 + B.W6 + B.W7 + B.W8 + B.W9 + B.W10 + B.W11) 
                              + (C.W1 + C.W2 + C.W3 + C.W4 + C.W5 + C.W6 + C.W7 + C.W8 + C.W9 + C.W10 + C.W11) as W11,       
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4 + B.W5 + B.W6 + B.W7 + B.W8 + B.W9 + B.W10 + B.W11 + B.W12) 
                              + (C.W1 + C.W2 + C.W3 + C.W4 + C.W5 + C.W6 + C.W7 + C.W8 + C.W9 + C.W10 + C.W11 + C.W12) as W12,
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4 + B.W5 + B.W6 + B.W7 + B.W8 + B.W9 + B.W10 + B.W11 + B.W12 + B.W13) 
                              + (C.W1 + C.W2 + C.W3 + C.W4 + C.W5 + C.W6 + C.W7 + C.W8 + C.W9 + C.W10 + C.W11 + C.W12 + C.W13) as W13,     
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4 + B.W5 + B.W6 + B.W7 + B.W8 + B.W9 + B.W10 + B.W11 + B.W12 + B.W13 + B.W14) 
                              + (C.W1 + C.W2 + C.W3 + C.W4 + C.W5 + C.W6 + C.W7 + C.W8 + C.W9 + C.W10 + C.W11 + C.W12 + C.W13 + C.W14) as W14,        
        a.UNQTY + a.BONDEDQTY - (B.W1 + B.W2 + B.W3 + B.W4 + B.W5 + B.W6 + B.W7 + B.W8 + B.W9 + B.W10 + B.W11 + B.W12 + B.W13 + B.W14 + B.W15) 
                              + (C.W1 + C.W2 + C.W3 + C.W4 + C.W5 + C.W6 + C.W7 + C.W8 + C.W9 + C.W10 + C.W11 + C.W12 + C.W13 + C.W14 + C.W15) as W15  
} where (a.TYPE = 'J' or a.TYPE = 'L') and B.TYPE = 'G' and C.TYPE ='K'

