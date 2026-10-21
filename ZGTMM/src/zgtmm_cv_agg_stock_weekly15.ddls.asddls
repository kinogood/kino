@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '주 단위 적정재고 SIMULATION BASE1.5'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_AGG_STOCK_WEEKLY15 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as
select from ZGTMM_CV_AGG_STOCK_WEEKLY1(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as a
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
        cast(ROUND(a.REQQTY,0) as abap.quan(21,0)) as REQQTY,                    //총예약수량
        a.meins,       

        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(a.REQ_DAILY,0) as abap.quan(21,0)) as REQ_DAILY,     
        @Semantics.quantity.unitOfMeasure: 'MEINS' 
        cast(ROUND(a.UNQTY,0) as abap.quan(21,0)) as UNQTY,                                         // 창고가용재고
        
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(a.BONDEDQTY,0) as abap.quan(21,0)) as BONDEDQTY,               // 보세창고재고        
        @Semantics.amount.currencyCode: 'waers'
        a.STOCKVAL,                 // 현 재고 금액
        a.waers,  

        a.F1,  

        @Semantics.quantity.unitOfMeasure: 'MEINS'             
        a.F2,
        a.PLANWEEK,
 
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        cast(ROUND(sum(a.W0),0) as abap.quan(21,0)) as W0,          
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        cast(ROUND(sum(a.W1),0) as abap.quan(21,0))  as W1,        
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        cast(ROUND(sum(a.W2),0) as abap.quan(21,0))  as W2,     
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        cast(ROUND(sum(a.W3),0) as abap.quan(21,0))  as W3,        
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        cast(ROUND(sum(a.W4),0) as abap.quan(21,0))  as W4,           
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        cast(ROUND(sum(a.W5),0) as abap.quan(21,0))  as W5,        
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        cast(ROUND(sum(a.W6),0) as abap.quan(13,0))  as W6,     
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        cast(ROUND(sum(a.W7),0) as abap.quan(21,0))  as W7,        
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        cast(ROUND(sum(a.W8),0) as abap.quan(21,0))  as W8,  
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        cast(ROUND(sum(a.W9),0) as abap.quan(21,0))  as W9,        
        @Semantics.quantity.unitOfMeasure: 'MEINS'         
        cast(ROUND(sum(a.W10),0) as abap.quan(21,0))  as W10,     
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        cast(ROUND(sum(a.W11),0) as abap.quan(21,0))  as W11,        
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        cast(ROUND(sum(a.W12),0) as abap.quan(21,0))  as W12,            
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        cast(ROUND(sum(a.W13),0) as abap.quan(21,0))  as W13,     
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        cast(ROUND(sum(a.W14),0) as abap.quan(21,0))  as W14,        
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        cast(ROUND(sum(a.W15),0) as abap.quan(21,0))  as W15                
} 
group by  a.bukrs, a.BUKRS_N, a.werks, a.werks_n, a.matnr, a.matnr_n, a.TYPE, a.TYPENAME, 
            a.LT, a.servicefactor, a.REQQTY, a.meins, a.REQ_DAILY, a.UNQTY, a.BONDEDQTY,          
            a.STOCKVAL, a.waers, a.F1, a.F2, a.PLANWEEK
