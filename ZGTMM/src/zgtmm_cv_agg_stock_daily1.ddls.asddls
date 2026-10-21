@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '일 단위 적정재고 SIMULATION BASE'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_AGG_STOCK_DAILY1
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as
 
// 예상 소요량 기준 - 01 소요량
select from ZGTMM_CV_RESB_REQCAL_DAILY as A
       left outer join ZGTMM_CV_RESB_DAILY_CAL1 as B on A.bukrs = B.bukrs and A.werks = B.werks and A.matnr = B.matnr 

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
        case B.DAYDIFF when 1 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D1,        
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 2 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D2,  
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 3 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D3,  
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 4 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D4,  
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 5 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D5,  
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 6 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D6,  
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 7 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D7,  
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 8 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D8,  
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 9 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D9,  
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 10 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D10,     
        @Semantics.quantity.unitOfMeasure: 'MEINS'              
        case when B.REQQTY is not null then
        case B.DAYDIFF when 11 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D11, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 12 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D12, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 13 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D13, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 14 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D14, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 15 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D15, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 16 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D16,
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 17 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D17, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 18 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D18, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 19 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D19,       
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 20 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D20, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 21 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D21, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 22 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D22, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 23 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D23, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 24 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D24,
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 25 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D25, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 26 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D26, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 27 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D27, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 28 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D28,      
        @Semantics.quantity.unitOfMeasure: 'MEINS'             
        case when B.REQQTY is not null then
        case B.DAYDIFF when 29 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D29, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 30 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D30, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 31 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D31, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 32 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D32, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 33 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D33, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 34 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D34, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 35 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D35, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 36 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D36,  
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 37 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D37,    
        @Semantics.quantity.unitOfMeasure: 'MEINS'               
        case when B.REQQTY is not null then
        case B.DAYDIFF when 38 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D38, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 39 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D39, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 40 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D40, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 41 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D41,
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 42 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D42, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 43 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D43, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 44 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D44, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 45 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D45, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 46 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D46,       
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 47 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D47, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 48 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D48, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 49 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D49, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 50 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D50, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 51 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D51, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 52 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D52, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 53 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D53, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 54 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D54, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'    
        case when B.REQQTY is not null then
        case B.DAYDIFF when 55 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D55,    
        @Semantics.quantity.unitOfMeasure: 'MEINS'               
        case when B.REQQTY is not null then
        case B.DAYDIFF when 56 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D56, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 57 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D57, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 58 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D58, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 59 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D59, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 60 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D60, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 61 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D61, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 62 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D62, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 63 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D63, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 64 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D64,     
        @Semantics.quantity.unitOfMeasure: 'MEINS'              
        case when B.REQQTY is not null then
        case B.DAYDIFF when 65 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D65, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 66 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D66, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 67 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D67, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 68 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D68, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 69 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D69, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 70 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D70, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 71 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D71, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 72 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D72,         
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 73 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D73,       
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 74 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D74, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 75 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D75, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 76 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D76, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 77 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D77, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 78 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D78, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 79 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D79, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 80 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D80, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 81 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D81, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 82 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D82, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'                  
        case when B.REQQTY is not null then
        case B.DAYDIFF when 83 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D83, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 84 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D84, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 85 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D85, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 86 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D86, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 87 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D87, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 88 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D88, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 89 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D89, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 90 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D90, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 91 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D91,       
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 92 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D92, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 93 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D93, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 94 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D94, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 95 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D95, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 96 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D96,
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 97 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D97,
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 98 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D98,
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 99 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D99, 
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 100 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D100,      
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 101 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D101,
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 102 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D102,
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 103 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D103,
        @Semantics.quantity.unitOfMeasure: 'MEINS'             
        case when B.REQQTY is not null then
        case B.DAYDIFF when 104 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D104,
        @Semantics.quantity.unitOfMeasure: 'MEINS'            
        case when B.REQQTY is not null then
        case B.DAYDIFF when 105 then  B.REQQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D105                                                                                                          
                                                                    
}


union all


// 예상 소요량 기준 - 02 입고 예정량(구매요청 잔량)   
select from ZGTMM_CV_RESB_REQCAL_DAILY as A
       left outer join ZGTMM_CV_RESERVED_PR_DAILY as B on A.werks = B.werks and A.matnr = B.matnr 

{
   key  A.bukrs,
   key  A.BUKRS_N,   
   key  A.werks,
   key  A.werks_n,
   key  A.matnr,
   key  A.matnr_n, 
   
        cast('B' as abap.char(1)) as TYPE,   
        cast('입고예정수량(PR)' as abap.char(20)) as TYPENAME,         
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
        case B.DAYDIFF when 1 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D1,        
        case when B.REQTY is not null then
        case B.DAYDIFF when 2 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D2,  
        case when B.REQTY is not null then
        case B.DAYDIFF when 3 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D3,  
        case when B.REQTY is not null then
        case B.DAYDIFF when 4 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D4,  
        case when B.REQTY is not null then
        case B.DAYDIFF when 5 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D5,  
        case when B.REQTY is not null then
        case B.DAYDIFF when 6 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D6,  
        case when B.REQTY is not null then
        case B.DAYDIFF when 7 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D7,  
        case when B.REQTY is not null then
        case B.DAYDIFF when 8 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D8,  
        case when B.REQTY is not null then
        case B.DAYDIFF when 9 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D9,  
        case when B.REQTY is not null then
        case B.DAYDIFF when 10 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D10,       
        case when B.REQTY is not null then
        case B.DAYDIFF when 11 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D11, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 12 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D12, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 13 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D13, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 14 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D14, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 15 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D15, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 16 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D16,
        case when B.REQTY is not null then
        case B.DAYDIFF when 17 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D17, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 18 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D18, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 19 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D19,       
        case when B.REQTY is not null then
        case B.DAYDIFF when 20 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D20, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 21 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D21, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 22 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D22, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 23 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D23, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 24 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D24,
        case when B.REQTY is not null then
        case B.DAYDIFF when 25 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D25, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 26 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D26, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 27 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D27, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 28 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D28,       
        case when B.REQTY is not null then
        case B.DAYDIFF when 29 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D29, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 30 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D30, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 31 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D31, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 32 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D32, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 33 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D33, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 34 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D34, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 35 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D35, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 36 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D36,  
        case when B.REQTY is not null then
        case B.DAYDIFF when 37 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D37,       
        case when B.REQTY is not null then
        case B.DAYDIFF when 38 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D38, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 39 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D39, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 40 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D40, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 41 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D41,
        case when B.REQTY is not null then
        case B.DAYDIFF when 42 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D42, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 43 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D43, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 44 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D44, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 45 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D45, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 46 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D46,       
        case when B.REQTY is not null then
        case B.DAYDIFF when 47 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D47, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 48 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D48, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 49 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D49, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 50 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D50, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 51 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D51, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 52 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D52, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 53 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D53, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 54 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D54, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 55 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D55,       
        case when B.REQTY is not null then
        case B.DAYDIFF when 56 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D56, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 57 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D57, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 58 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D58, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 59 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D59, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 60 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D60, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 61 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D61, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 62 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D62, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 63 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D63, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 64 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D64,       
        case when B.REQTY is not null then
        case B.DAYDIFF when 65 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D65, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 66 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D66, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 67 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D67, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 68 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D68, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 69 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D69, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 70 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D70, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 71 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D71, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 72 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D72,         
        case when B.REQTY is not null then
        case B.DAYDIFF when 73 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D73,       
        case when B.REQTY is not null then
        case B.DAYDIFF when 74 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D74, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 75 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D75, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 76 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D76, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 77 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D77, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 78 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D78, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 79 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D79, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 80 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D80, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 81 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D81, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 82 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D82,       
        case when B.REQTY is not null then
        case B.DAYDIFF when 83 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D83, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 84 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D84, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 85 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D85, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 86 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D86, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 87 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D87, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 88 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D88, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 89 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D89, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 90 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D90, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 91 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D91,       
        case when B.REQTY is not null then
        case B.DAYDIFF when 92 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D92, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 93 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D93, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 94 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D94, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 95 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D95, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 96 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D96,
        case when B.REQTY is not null then
        case B.DAYDIFF when 97 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D97,
        case when B.REQTY is not null then
        case B.DAYDIFF when 98 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D98,
        case when B.REQTY is not null then
        case B.DAYDIFF when 99 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D99, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 100 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D100,      
        case when B.REQTY is not null then
        case B.DAYDIFF when 101 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D101,
        case when B.REQTY is not null then
        case B.DAYDIFF when 102 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D102,
        case when B.REQTY is not null then
        case B.DAYDIFF when 103 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D103,
        case when B.REQTY is not null then
        case B.DAYDIFF when 104 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D104,
        case when B.REQTY is not null then
        case B.DAYDIFF when 105 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D105                             
                
                                                                                         
}


union all


// 예상 소요량 기준 - 03 입고 예정량(PO 잔량)   
select from ZGTMM_CV_RESB_REQCAL_DAILY as A
       left outer join ZGTMM_CV_RESERVED_GR_DAILY  as B on A.werks = B.werks and A.matnr = B.matnr 

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
        case B.DAYDIFF when 1 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D1,        
        case when B.REQTY is not null then
        case B.DAYDIFF when 2 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D2,  
        case when B.REQTY is not null then
        case B.DAYDIFF when 3 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D3,  
        case when B.REQTY is not null then
        case B.DAYDIFF when 4 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D4,  
        case when B.REQTY is not null then
        case B.DAYDIFF when 5 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D5,  
        case when B.REQTY is not null then
        case B.DAYDIFF when 6 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D6,  
        case when B.REQTY is not null then
        case B.DAYDIFF when 7 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D7,  
        case when B.REQTY is not null then
        case B.DAYDIFF when 8 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D8,  
        case when B.REQTY is not null then
        case B.DAYDIFF when 9 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D9,  
        case when B.REQTY is not null then
        case B.DAYDIFF when 10 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D10,       
        case when B.REQTY is not null then
        case B.DAYDIFF when 11 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D11, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 12 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D12, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 13 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D13, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 14 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D14, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 15 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D15, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 16 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D16,
        case when B.REQTY is not null then
        case B.DAYDIFF when 17 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D17, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 18 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D18, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 19 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D19,       
        case when B.REQTY is not null then
        case B.DAYDIFF when 20 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D20, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 21 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D21, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 22 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D22, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 23 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D23, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 24 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D24,
        case when B.REQTY is not null then
        case B.DAYDIFF when 25 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D25, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 26 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D26, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 27 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D27, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 28 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D28,       
        case when B.REQTY is not null then
        case B.DAYDIFF when 29 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D29, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 30 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D30, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 31 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D31, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 32 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D32, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 33 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D33, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 34 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D34, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 35 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D35, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 36 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D36,  
        case when B.REQTY is not null then
        case B.DAYDIFF when 37 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D37,       
        case when B.REQTY is not null then
        case B.DAYDIFF when 38 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D38, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 39 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D39, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 40 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D40, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 41 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D41,
        case when B.REQTY is not null then
        case B.DAYDIFF when 42 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D42, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 43 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D43, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 44 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D44, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 45 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D45, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 46 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D46,       
        case when B.REQTY is not null then
        case B.DAYDIFF when 47 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D47, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 48 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D48, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 49 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D49, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 50 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D50, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 51 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D51, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 52 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D52, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 53 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D53, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 54 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D54, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 55 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D55,       
        case when B.REQTY is not null then
        case B.DAYDIFF when 56 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D56, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 57 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D57, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 58 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D58, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 59 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D59, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 60 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D60, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 61 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D61, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 62 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D62, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 63 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D63, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 64 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D64,       
        case when B.REQTY is not null then
        case B.DAYDIFF when 65 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D65, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 66 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D66, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 67 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D67, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 68 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D68, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 69 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D69, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 70 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D70, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 71 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D71, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 72 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D72,         
        case when B.REQTY is not null then
        case B.DAYDIFF when 73 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D73,       
        case when B.REQTY is not null then
        case B.DAYDIFF when 74 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D74, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 75 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D75, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 76 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D76, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 77 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D77, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 78 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D78, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 79 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D79, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 80 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D80, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 81 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D81, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 82 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D82,       
        case when B.REQTY is not null then
        case B.DAYDIFF when 83 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D83, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 84 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D84, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 85 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D85, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 86 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D86, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 87 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D87, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 88 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D88, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 89 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D89, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 90 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D90, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 91 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D91,       
        case when B.REQTY is not null then
        case B.DAYDIFF when 92 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D92, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 93 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D93, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 94 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D94, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 95 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D95, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 96 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D96,
        case when B.REQTY is not null then
        case B.DAYDIFF when 97 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D97,
        case when B.REQTY is not null then
        case B.DAYDIFF when 98 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D98,
        case when B.REQTY is not null then
        case B.DAYDIFF when 99 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D99, 
        case when B.REQTY is not null then
        case B.DAYDIFF when 100 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D100,      
        case when B.REQTY is not null then
        case B.DAYDIFF when 101 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D101,
        case when B.REQTY is not null then
        case B.DAYDIFF when 102 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D102,
        case when B.REQTY is not null then
        case B.DAYDIFF when 103 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D103,
        case when B.REQTY is not null then
        case B.DAYDIFF when 104 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D104,
        case when B.REQTY is not null then
        case B.DAYDIFF when 105 then  B.REQTY else cast(0 as abap.quan(13,3)) end 
        else cast(0 as abap.quan(13,3))
        end as D105     
}

union all
// 예상 소요량 기준 - 05 입고 예정 변경
select from ZGTMM_CV_RESB_REQCAL_DAILY as A       
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
        
        cast(0 as abap.quan(13,3)) as D1,
        cast(0 as abap.quan(13,3)) as D2,
        cast(0 as abap.quan(13,3)) as D3,
        cast(0 as abap.quan(13,3)) as D4,
        cast(0 as abap.quan(13,3)) as D5,
        cast(0 as abap.quan(13,3)) as D6,
        cast(0 as abap.quan(13,3)) as D7,
        cast(0 as abap.quan(13,3)) as D8,
        cast(0 as abap.quan(13,3)) as D9,
        cast(0 as abap.quan(13,3)) as D10,
        cast(0 as abap.quan(13,3)) as D11,
        cast(0 as abap.quan(13,3)) as D12,
        cast(0 as abap.quan(13,3)) as D13,
        cast(0 as abap.quan(13,3)) as D14,
        cast(0 as abap.quan(13,3)) as D15,
        cast(0 as abap.quan(13,3)) as D16,
        cast(0 as abap.quan(13,3)) as D17,
        cast(0 as abap.quan(13,3)) as D18,
        cast(0 as abap.quan(13,3)) as D19,
        cast(0 as abap.quan(13,3)) as D20,
        cast(0 as abap.quan(13,3)) as D21,
        cast(0 as abap.quan(13,3)) as D22,
        cast(0 as abap.quan(13,3)) as D23,
        cast(0 as abap.quan(13,3)) as D24,
        cast(0 as abap.quan(13,3)) as D25,
        cast(0 as abap.quan(13,3)) as D26,
        cast(0 as abap.quan(13,3)) as D27,
        cast(0 as abap.quan(13,3)) as D28,
        cast(0 as abap.quan(13,3)) as D29,
        cast(0 as abap.quan(13,3)) as D30,
        cast(0 as abap.quan(13,3)) as D31,
        cast(0 as abap.quan(13,3)) as D32,
        cast(0 as abap.quan(13,3)) as D33,
        cast(0 as abap.quan(13,3)) as D34,
        cast(0 as abap.quan(13,3)) as D35,
        cast(0 as abap.quan(13,3)) as D36,
        cast(0 as abap.quan(13,3)) as D37,
        cast(0 as abap.quan(13,3)) as D38,
        cast(0 as abap.quan(13,3)) as D39,
        cast(0 as abap.quan(13,3)) as D40,
        cast(0 as abap.quan(13,3)) as D41,
        cast(0 as abap.quan(13,3)) as D42,
        cast(0 as abap.quan(13,3)) as D43,
        cast(0 as abap.quan(13,3)) as D44,
        cast(0 as abap.quan(13,3)) as D45,
        cast(0 as abap.quan(13,3)) as D46,
        cast(0 as abap.quan(13,3)) as D47,
        cast(0 as abap.quan(13,3)) as D48,
        cast(0 as abap.quan(13,3)) as D49,
        cast(0 as abap.quan(13,3)) as D50,
        cast(0 as abap.quan(13,3)) as D51,
        cast(0 as abap.quan(13,3)) as D52,
        cast(0 as abap.quan(13,3)) as D53,
        cast(0 as abap.quan(13,3)) as D54,
        cast(0 as abap.quan(13,3)) as D55,
        cast(0 as abap.quan(13,3)) as D56,
        cast(0 as abap.quan(13,3)) as D57,
        cast(0 as abap.quan(13,3)) as D58,
        cast(0 as abap.quan(13,3)) as D59,
        cast(0 as abap.quan(13,3)) as D60,
        cast(0 as abap.quan(13,3)) as D61,
        cast(0 as abap.quan(13,3)) as D62,
        cast(0 as abap.quan(13,3)) as D63,
        cast(0 as abap.quan(13,3)) as D64,
        cast(0 as abap.quan(13,3)) as D65,
        cast(0 as abap.quan(13,3)) as D66,
        cast(0 as abap.quan(13,3)) as D67,
        cast(0 as abap.quan(13,3)) as D68,
        cast(0 as abap.quan(13,3)) as D69,
        cast(0 as abap.quan(13,3)) as D70,
        cast(0 as abap.quan(13,3)) as D71,
        cast(0 as abap.quan(13,3)) as D72,
        cast(0 as abap.quan(13,3)) as D73,
        cast(0 as abap.quan(13,3)) as D74,
        cast(0 as abap.quan(13,3)) as D75,
        cast(0 as abap.quan(13,3)) as D76,
        cast(0 as abap.quan(13,3)) as D77,
        cast(0 as abap.quan(13,3)) as D78,
        cast(0 as abap.quan(13,3)) as D79,
        cast(0 as abap.quan(13,3)) as D80,
        cast(0 as abap.quan(13,3)) as D81,
        cast(0 as abap.quan(13,3)) as D82,
        cast(0 as abap.quan(13,3)) as D83,
        cast(0 as abap.quan(13,3)) as D84,
        cast(0 as abap.quan(13,3)) as D85,
        cast(0 as abap.quan(13,3)) as D86,
        cast(0 as abap.quan(13,3)) as D87,
        cast(0 as abap.quan(13,3)) as D88,
        cast(0 as abap.quan(13,3)) as D89,
        cast(0 as abap.quan(13,3)) as D90,
        cast(0 as abap.quan(13,3)) as D91,
        cast(0 as abap.quan(13,3)) as D92,
        cast(0 as abap.quan(13,3)) as D93,
        cast(0 as abap.quan(13,3)) as D94,
        cast(0 as abap.quan(13,3)) as D95,
        cast(0 as abap.quan(13,3)) as D96,
        cast(0 as abap.quan(13,3)) as D97,
        cast(0 as abap.quan(13,3)) as D98,
        cast(0 as abap.quan(13,3)) as D99,
        cast(0 as abap.quan(13,3)) as D100,
        cast(0 as abap.quan(13,3)) as D101,
        cast(0 as abap.quan(13,3)) as D102,
        cast(0 as abap.quan(13,3)) as D103,
        cast(0 as abap.quan(13,3)) as D104,
        cast(0 as abap.quan(13,3)) as D105

}

union all
// 예상 소요량 기준 - 05 입고 예정 변경
select from ZGTMM_CV_RESB_REQCAL_DAILY as A
       left outer join ZGTMM_CV_RESERVED_PR_DAILY as B on A.werks = B.werks and A.matnr = B.matnr 
       left outer join ZGTMM_CV_RESERVED_GR_DAILY  as C on A.werks = C.werks and A.matnr = C.matnr 
{
   key  A.bukrs,
   key  A.BUKRS_N,   
   key  A.werks,
   key  A.werks_n,
   key  A.matnr,
   key  A.matnr_n, 
   
        cast('E' as abap.char(1)) as TYPE,  
        cast('입고예정수량변경' as abap.char(20)) as TYPENAME, 
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
                       then case when B.DAYDIFF = 1
                                 then case when C.DAYDIFF = 1
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.DAYDIFF = 1
                                           then C.REQTY
                                           else cast(0 as abap.quan(13,3))
                                           end                                 
                                 end
                       else case when B.DAYDIFF = 1
                                 then B.REQTY
                                 else  cast(0 as abap.quan(13,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.DAYDIFF = 1
                                 then C.REQTY
                                 else cast(0 as abap.quan(13,3))                                
                                 end
                       else cast(0 as abap.quan(13,3))                       
                       end
             end as D1, 
                       
         case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.DAYDIFF = 2
                                 then case when C.DAYDIFF = 2
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.DAYDIFF = 2
                                           then C.REQTY
                                           else cast(0 as abap.quan(13,3))
                                           end                                 
                                 end
                       else case when B.DAYDIFF = 2
                                 then B.REQTY
                                 else  cast(0 as abap.quan(13,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.DAYDIFF = 2
                                 then C.REQTY
                                 else cast(0 as abap.quan(13,3))                                
                                 end
                       else cast(0 as abap.quan(13,3))                       
                       end
             end as D2, 
             
    case when B.REQTY is not null
    then case when C.REQTY is not null
    then case when B.DAYDIFF = 3
    then case when C.DAYDIFF = 3
    then B.REQTY + C.REQTY
    else B.REQTY
    end
    else case when C.DAYDIFF = 3
    then C.REQTY
    else cast(0 as abap.quan(13,3))
    end
    end
    else case when B.DAYDIFF = 3
    then B.REQTY
    else cast(0 as abap.quan(13,3))
    end
    end
    else case when C.REQTY is not null
    then case when C.DAYDIFF = 3
    then C.REQTY
    else cast(0 as abap.quan(13,3))
    end
    else cast(0 as abap.quan(13,3))
    end
    end as D3,
    
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 4
        then case when C.DAYDIFF = 4
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 4
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 4
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 4
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D4,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 5
        then case when C.DAYDIFF = 5
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 5
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 5
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 5
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D5,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 6
        then case when C.DAYDIFF = 6
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 6
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 6
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 6
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D6,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 7
        then case when C.DAYDIFF = 7
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 7
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 7
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 7
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D7,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 8
        then case when C.DAYDIFF = 8
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 8
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 8
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 8
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D8,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 9
        then case when C.DAYDIFF = 9
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 9
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 9
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 9
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D9,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 10
        then case when C.DAYDIFF = 10
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 10
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 10
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 10
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D10,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 11
        then case when C.DAYDIFF = 11
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 11
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 11
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 11
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D11,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 12
        then case when C.DAYDIFF = 12
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 12
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 12
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 12
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D12,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 13
        then case when C.DAYDIFF = 13
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 13
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 13
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 13
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D13,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 14
        then case when C.DAYDIFF = 14
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 14
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 14
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 14
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D14,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 15
        then case when C.DAYDIFF = 15
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 15
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 15
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 15
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D15,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 16
        then case when C.DAYDIFF = 16
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 16
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 16
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 16
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D16,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 17
        then case when C.DAYDIFF = 17
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 17
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 17
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 17
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D17,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 18
        then case when C.DAYDIFF = 18
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 18
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 18
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 18
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D18,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 19
        then case when C.DAYDIFF = 19
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 19
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 19
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 19
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D19,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 20
        then case when C.DAYDIFF = 20
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 20
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 20
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 20
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D20,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 21
        then case when C.DAYDIFF = 21
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 21
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 21
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 21
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D21,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 22
        then case when C.DAYDIFF = 22
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 22
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 22
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 22
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D22,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 23
        then case when C.DAYDIFF = 23
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 23
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 23
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 23
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D23,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 24
        then case when C.DAYDIFF = 24
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 24
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 24
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 24
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D24,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 25
        then case when C.DAYDIFF = 25
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 25
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 25
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 25
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D25,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 26
        then case when C.DAYDIFF = 26
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 26
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 26
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 26
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D26,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 27
        then case when C.DAYDIFF = 27
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 27
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 27
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 27
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D27,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 28
        then case when C.DAYDIFF = 28
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 28
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 28
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 28
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D28,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 29
        then case when C.DAYDIFF = 29
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 29
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 29
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 29
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D29,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 30
        then case when C.DAYDIFF = 30
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 30
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 30
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 30
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D30,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 31
        then case when C.DAYDIFF = 31
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 31
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 31
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 31
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D31,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 32
        then case when C.DAYDIFF = 32
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 32
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 32
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 32
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D32,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 33
        then case when C.DAYDIFF = 33
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 33
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 33
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 33
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D33,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 34
        then case when C.DAYDIFF = 34
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 34
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 34
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 34
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D34,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 35
        then case when C.DAYDIFF = 35
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 35
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 35
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 35
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D35,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 36
        then case when C.DAYDIFF = 36
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 36
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 36
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 36
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D36,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 37
        then case when C.DAYDIFF = 37
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 37
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 37
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 37
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D37,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 38
        then case when C.DAYDIFF = 38
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 38
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 38
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 38
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D38,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 39
        then case when C.DAYDIFF = 39
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 39
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 39
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 39
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D39,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 40
        then case when C.DAYDIFF = 40
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 40
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 40
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 40
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D40,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 41
        then case when C.DAYDIFF = 41
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 41
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 41
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 41
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D41,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 42
        then case when C.DAYDIFF = 42
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 42
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 42
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 42
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D42,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 43
        then case when C.DAYDIFF = 43
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 43
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 43
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 43
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D43,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 44
        then case when C.DAYDIFF = 44
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 44
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 44
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 44
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D44,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 45
        then case when C.DAYDIFF = 45
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 45
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 45
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 45
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D45,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 46
        then case when C.DAYDIFF = 46
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 46
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 46
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 46
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D46,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 47
        then case when C.DAYDIFF = 47
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 47
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 47
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 47
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D47,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 48
        then case when C.DAYDIFF = 48
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 48
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 48
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 48
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D48,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 49
        then case when C.DAYDIFF = 49
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 49
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 49
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 49
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D49,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 50
        then case when C.DAYDIFF = 50
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 50
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 50
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 50
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D50,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 51
        then case when C.DAYDIFF = 51
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 51
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 51
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 51
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D51,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 52
        then case when C.DAYDIFF = 52
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 52
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 52
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 52
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D52,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 53
        then case when C.DAYDIFF = 53
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 53
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 53
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 53
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D53,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 54
        then case when C.DAYDIFF = 54
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 54
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 54
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 54
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D54,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 55
        then case when C.DAYDIFF = 55
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 55
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 55
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 55
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D55,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 56
        then case when C.DAYDIFF = 56
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 56
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 56
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 56
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D56,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 57
        then case when C.DAYDIFF = 57
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 57
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 57
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 57
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D57,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 58
        then case when C.DAYDIFF = 58
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 58
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 58
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 58
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D58,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 59
        then case when C.DAYDIFF = 59
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 59
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 59
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 59
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D59,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 60
        then case when C.DAYDIFF = 60
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 60
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 60
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 60
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D60,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 61
        then case when C.DAYDIFF = 61
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 61
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 61
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 61
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D61,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 62
        then case when C.DAYDIFF = 62
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 62
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 62
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 62
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D62,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 63
        then case when C.DAYDIFF = 63
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 63
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 63
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 63
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D63,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 64
        then case when C.DAYDIFF = 64
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 64
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 64
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 64
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D64,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 65
        then case when C.DAYDIFF = 65
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 65
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 65
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 65
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D65,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 66
        then case when C.DAYDIFF = 66
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 66
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 66
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 66
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D66,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 67
        then case when C.DAYDIFF = 67
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 67
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 67
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 67
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D67,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 68
        then case when C.DAYDIFF = 68
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 68
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 68
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 68
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D68,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 69
        then case when C.DAYDIFF = 69
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 69
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 69
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 69
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D69,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 70
        then case when C.DAYDIFF = 70
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 70
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 70
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 70
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D70,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 71
        then case when C.DAYDIFF = 71
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 71
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 71
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 71
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D71,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 72
        then case when C.DAYDIFF = 72
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 72
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 72
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 72
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D72,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 73
        then case when C.DAYDIFF = 73
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 73
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 73
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 73
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D73,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 74
        then case when C.DAYDIFF = 74
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 74
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 74
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 74
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D74,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 75
        then case when C.DAYDIFF = 75
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 75
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 75
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 75
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D75,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 76
        then case when C.DAYDIFF = 76
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 76
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 76
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 76
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D76,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 77
        then case when C.DAYDIFF = 77
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 77
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 77
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 77
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D77,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 78
        then case when C.DAYDIFF = 78
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 78
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 78
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 78
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D78,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 79
        then case when C.DAYDIFF = 79
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 79
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 79
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 79
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D79,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 80
        then case when C.DAYDIFF = 80
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 80
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 80
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 80
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D80,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 81
        then case when C.DAYDIFF = 81
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 81
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 81
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 81
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D81,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 82
        then case when C.DAYDIFF = 82
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 82
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 82
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 82
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D82,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 83
        then case when C.DAYDIFF = 83
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 83
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 83
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 83
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D83,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 84
        then case when C.DAYDIFF = 84
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 84
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 84
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 84
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D84,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 85
        then case when C.DAYDIFF = 85
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 85
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 85
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 85
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D85,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 86
        then case when C.DAYDIFF = 86
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 86
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 86
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 86
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D86,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 87
        then case when C.DAYDIFF = 87
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 87
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 87
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 87
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D87,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 88
        then case when C.DAYDIFF = 88
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 88
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 88
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 88
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D88,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 89
        then case when C.DAYDIFF = 89
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 89
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 89
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 89
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D89,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 90
        then case when C.DAYDIFF = 90
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 90
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 90
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 90
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D90,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 91
        then case when C.DAYDIFF = 91
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 91
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 91
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 91
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D91,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 92
        then case when C.DAYDIFF = 92
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 92
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 92
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 92
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D92,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 93
        then case when C.DAYDIFF = 93
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 93
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 93
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 93
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D93,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 94
        then case when C.DAYDIFF = 94
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 94
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 94
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 94
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D94,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 95
        then case when C.DAYDIFF = 95
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 95
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 95
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 95
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D95,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 96
        then case when C.DAYDIFF = 96
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 96
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 96
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 96
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D96,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 97
        then case when C.DAYDIFF = 97
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 97
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 97
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 97
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D97,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 98
        then case when C.DAYDIFF = 98
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 98
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 98
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 98
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D98,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 99
        then case when C.DAYDIFF = 99
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 99
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 99
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 99
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D99,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 100
        then case when C.DAYDIFF = 100
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 100
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 100
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 100
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D100,
        
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 101
        then case when C.DAYDIFF = 101
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 101
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 101
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 101
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D101,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 102
        then case when C.DAYDIFF = 102
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 102
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 102
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 102
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D102,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 103
        then case when C.DAYDIFF = 103
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 103
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 103
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 103
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D103,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 104
        then case when C.DAYDIFF = 104
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 104
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 104
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 104
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D104,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 105
        then case when C.DAYDIFF = 105
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 105
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 105
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 105
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D105
}

union all
// 예상 소요량 기준 - 06 SIMULATION 필드
select from ZGTMM_CV_RESB_REQCAL_DAILY as A

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
                
        cast(0 as abap.quan(13,3)) as D1,
        cast(0 as abap.quan(13,3)) as D2,
        cast(0 as abap.quan(13,3)) as D3,
        cast(0 as abap.quan(13,3)) as D4,
        cast(0 as abap.quan(13,3)) as D5,
        cast(0 as abap.quan(13,3)) as D6,
        cast(0 as abap.quan(13,3)) as D7,
        cast(0 as abap.quan(13,3)) as D8,
        cast(0 as abap.quan(13,3)) as D9,
        cast(0 as abap.quan(13,3)) as D10,
        cast(0 as abap.quan(13,3)) as D11,
        cast(0 as abap.quan(13,3)) as D12,
        cast(0 as abap.quan(13,3)) as D13,
        cast(0 as abap.quan(13,3)) as D14,
        cast(0 as abap.quan(13,3)) as D15,
        cast(0 as abap.quan(13,3)) as D16,
        cast(0 as abap.quan(13,3)) as D17,
        cast(0 as abap.quan(13,3)) as D18,
        cast(0 as abap.quan(13,3)) as D19,
        cast(0 as abap.quan(13,3)) as D20,
        cast(0 as abap.quan(13,3)) as D21,
        cast(0 as abap.quan(13,3)) as D22,
        cast(0 as abap.quan(13,3)) as D23,
        cast(0 as abap.quan(13,3)) as D24,
        cast(0 as abap.quan(13,3)) as D25,
        cast(0 as abap.quan(13,3)) as D26,
        cast(0 as abap.quan(13,3)) as D27,
        cast(0 as abap.quan(13,3)) as D28,
        cast(0 as abap.quan(13,3)) as D29,
        cast(0 as abap.quan(13,3)) as D30,
        cast(0 as abap.quan(13,3)) as D31,
        cast(0 as abap.quan(13,3)) as D32,
        cast(0 as abap.quan(13,3)) as D33,
        cast(0 as abap.quan(13,3)) as D34,
        cast(0 as abap.quan(13,3)) as D35,
        cast(0 as abap.quan(13,3)) as D36,
        cast(0 as abap.quan(13,3)) as D37,
        cast(0 as abap.quan(13,3)) as D38,
        cast(0 as abap.quan(13,3)) as D39,
        cast(0 as abap.quan(13,3)) as D40,
        cast(0 as abap.quan(13,3)) as D41,
        cast(0 as abap.quan(13,3)) as D42,
        cast(0 as abap.quan(13,3)) as D43,
        cast(0 as abap.quan(13,3)) as D44,
        cast(0 as abap.quan(13,3)) as D45,
        cast(0 as abap.quan(13,3)) as D46,
        cast(0 as abap.quan(13,3)) as D47,
        cast(0 as abap.quan(13,3)) as D48,
        cast(0 as abap.quan(13,3)) as D49,
        cast(0 as abap.quan(13,3)) as D50,
        cast(0 as abap.quan(13,3)) as D51,
        cast(0 as abap.quan(13,3)) as D52,
        cast(0 as abap.quan(13,3)) as D53,
        cast(0 as abap.quan(13,3)) as D54,
        cast(0 as abap.quan(13,3)) as D55,
        cast(0 as abap.quan(13,3)) as D56,
        cast(0 as abap.quan(13,3)) as D57,
        cast(0 as abap.quan(13,3)) as D58,
        cast(0 as abap.quan(13,3)) as D59,
        cast(0 as abap.quan(13,3)) as D60,
        cast(0 as abap.quan(13,3)) as D61,
        cast(0 as abap.quan(13,3)) as D62,
        cast(0 as abap.quan(13,3)) as D63,
        cast(0 as abap.quan(13,3)) as D64,
        cast(0 as abap.quan(13,3)) as D65,
        cast(0 as abap.quan(13,3)) as D66,
        cast(0 as abap.quan(13,3)) as D67,
        cast(0 as abap.quan(13,3)) as D68,
        cast(0 as abap.quan(13,3)) as D69,
        cast(0 as abap.quan(13,3)) as D70,
        cast(0 as abap.quan(13,3)) as D71,
        cast(0 as abap.quan(13,3)) as D72,
        cast(0 as abap.quan(13,3)) as D73,
        cast(0 as abap.quan(13,3)) as D74,
        cast(0 as abap.quan(13,3)) as D75,
        cast(0 as abap.quan(13,3)) as D76,
        cast(0 as abap.quan(13,3)) as D77,
        cast(0 as abap.quan(13,3)) as D78,
        cast(0 as abap.quan(13,3)) as D79,
        cast(0 as abap.quan(13,3)) as D80,
        cast(0 as abap.quan(13,3)) as D81,
        cast(0 as abap.quan(13,3)) as D82,
        cast(0 as abap.quan(13,3)) as D83,
        cast(0 as abap.quan(13,3)) as D84,
        cast(0 as abap.quan(13,3)) as D85,
        cast(0 as abap.quan(13,3)) as D86,
        cast(0 as abap.quan(13,3)) as D87,
        cast(0 as abap.quan(13,3)) as D88,
        cast(0 as abap.quan(13,3)) as D89,
        cast(0 as abap.quan(13,3)) as D90,
        cast(0 as abap.quan(13,3)) as D91,
        cast(0 as abap.quan(13,3)) as D92,
        cast(0 as abap.quan(13,3)) as D93,
        cast(0 as abap.quan(13,3)) as D94,
        cast(0 as abap.quan(13,3)) as D95,
        cast(0 as abap.quan(13,3)) as D96,
        cast(0 as abap.quan(13,3)) as D97,
        cast(0 as abap.quan(13,3)) as D98,
        cast(0 as abap.quan(13,3)) as D99,
        cast(0 as abap.quan(13,3)) as D100,
        cast(0 as abap.quan(13,3)) as D101,
        cast(0 as abap.quan(13,3)) as D102,
        cast(0 as abap.quan(13,3)) as D103,
        cast(0 as abap.quan(13,3)) as D104,
        cast(0 as abap.quan(13,3)) as D105

}

union all

// 과거 소모 기준 기준 - 04 소요량(실적기준)
select from ZGTMM_CV_GI_REQCAL_DAILY(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as A
       left outer join ZGTMM_CV_GI_DAILY_CAL1(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as B on A.bukrs = B.bukrs and A.werks = B.werks and A.matnr = B.matnr 

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
                
        A.REQ_TOTAL as REQQTY,                    //총예약수량
        A.meins,       

        A.REQ_DAILY,     
        A.UNQTY,                                         // 창고가용재고
        
        A.BONDEDQTY,                // 보세창고재고        
        A.STOCKVAL,                  // 현 재고 금액
        A.waers,  

        A.F1,  

        A.F2,
        A.PLANWEEK,
        
        case when B.REQQTY is not null then case B.DAYDIFF when 1 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D1,
        case when B.REQQTY is not null then case B.DAYDIFF when 2 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D2,
        case when B.REQQTY is not null then case B.DAYDIFF when 3 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D3,
        case when B.REQQTY is not null then case B.DAYDIFF when 4 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D4,
        case when B.REQQTY is not null then case B.DAYDIFF when 5 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D5,
        case when B.REQQTY is not null then case B.DAYDIFF when 6 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D6,
        case when B.REQQTY is not null then case B.DAYDIFF when 7 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D7,
        case when B.REQQTY is not null then case B.DAYDIFF when 8 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D8,
        case when B.REQQTY is not null then case B.DAYDIFF when 9 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D9,
        case when B.REQQTY is not null then case B.DAYDIFF when 10 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D10,
        case when B.REQQTY is not null then case B.DAYDIFF when 11 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D11,
        case when B.REQQTY is not null then case B.DAYDIFF when 12 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D12,
        case when B.REQQTY is not null then case B.DAYDIFF when 13 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D13,
        case when B.REQQTY is not null then case B.DAYDIFF when 14 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D14,
        case when B.REQQTY is not null then case B.DAYDIFF when 15 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D15,
        case when B.REQQTY is not null then case B.DAYDIFF when 16 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D16,
        case when B.REQQTY is not null then case B.DAYDIFF when 17 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D17,
        case when B.REQQTY is not null then case B.DAYDIFF when 18 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D18,
        case when B.REQQTY is not null then case B.DAYDIFF when 19 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D19,
        case when B.REQQTY is not null then case B.DAYDIFF when 20 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D20,
        case when B.REQQTY is not null then case B.DAYDIFF when 21 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D21,
        case when B.REQQTY is not null then case B.DAYDIFF when 22 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D22,
        case when B.REQQTY is not null then case B.DAYDIFF when 23 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D23,
        case when B.REQQTY is not null then case B.DAYDIFF when 24 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D24,
        case when B.REQQTY is not null then case B.DAYDIFF when 25 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D25,
        case when B.REQQTY is not null then case B.DAYDIFF when 26 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D26,
        case when B.REQQTY is not null then case B.DAYDIFF when 27 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D27,
        case when B.REQQTY is not null then case B.DAYDIFF when 28 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D28,
        case when B.REQQTY is not null then case B.DAYDIFF when 29 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D29,
        case when B.REQQTY is not null then case B.DAYDIFF when 30 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D30,
        case when B.REQQTY is not null then case B.DAYDIFF when 31 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D31,
        case when B.REQQTY is not null then case B.DAYDIFF when 32 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D32,
        case when B.REQQTY is not null then case B.DAYDIFF when 33 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D33,
        case when B.REQQTY is not null then case B.DAYDIFF when 34 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D34,
        case when B.REQQTY is not null then case B.DAYDIFF when 35 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D35,
        case when B.REQQTY is not null then case B.DAYDIFF when 36 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D36,
        case when B.REQQTY is not null then case B.DAYDIFF when 37 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D37,
        case when B.REQQTY is not null then case B.DAYDIFF when 38 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D38,
        case when B.REQQTY is not null then case B.DAYDIFF when 39 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D39,
        case when B.REQQTY is not null then case B.DAYDIFF when 40 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D40,
        case when B.REQQTY is not null then case B.DAYDIFF when 41 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D41,
        case when B.REQQTY is not null then case B.DAYDIFF when 42 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D42,
        case when B.REQQTY is not null then case B.DAYDIFF when 43 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D43,
        case when B.REQQTY is not null then case B.DAYDIFF when 44 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D44,
        case when B.REQQTY is not null then case B.DAYDIFF when 45 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D45,
        case when B.REQQTY is not null then case B.DAYDIFF when 46 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D46,
        case when B.REQQTY is not null then case B.DAYDIFF when 47 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D47,
        case when B.REQQTY is not null then case B.DAYDIFF when 48 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D48,
        case when B.REQQTY is not null then case B.DAYDIFF when 49 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D49,
        case when B.REQQTY is not null then case B.DAYDIFF when 50 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D50,
        case when B.REQQTY is not null then case B.DAYDIFF when 51 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D51,
        case when B.REQQTY is not null then case B.DAYDIFF when 52 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D52,
        case when B.REQQTY is not null then case B.DAYDIFF when 53 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D53,
        case when B.REQQTY is not null then case B.DAYDIFF when 54 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D54,
        case when B.REQQTY is not null then case B.DAYDIFF when 55 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D55,
        case when B.REQQTY is not null then case B.DAYDIFF when 56 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D56,
        case when B.REQQTY is not null then case B.DAYDIFF when 57 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D57,
        case when B.REQQTY is not null then case B.DAYDIFF when 58 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D58,
        case when B.REQQTY is not null then case B.DAYDIFF when 59 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D59,
        case when B.REQQTY is not null then case B.DAYDIFF when 60 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D60,
        case when B.REQQTY is not null then case B.DAYDIFF when 61 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D61,
        case when B.REQQTY is not null then case B.DAYDIFF when 62 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D62,
        case when B.REQQTY is not null then case B.DAYDIFF when 63 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D63,
        case when B.REQQTY is not null then case B.DAYDIFF when 64 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D64,
        case when B.REQQTY is not null then case B.DAYDIFF when 65 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D65,
        case when B.REQQTY is not null then case B.DAYDIFF when 66 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D66,
        case when B.REQQTY is not null then case B.DAYDIFF when 67 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D67,
        case when B.REQQTY is not null then case B.DAYDIFF when 68 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D68,
        case when B.REQQTY is not null then case B.DAYDIFF when 69 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D69,
        case when B.REQQTY is not null then case B.DAYDIFF when 70 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D70,
        case when B.REQQTY is not null then case B.DAYDIFF when 71 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D71,
        case when B.REQQTY is not null then case B.DAYDIFF when 72 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D72,
        case when B.REQQTY is not null then case B.DAYDIFF when 73 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D73,
        case when B.REQQTY is not null then case B.DAYDIFF when 74 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D74,
        case when B.REQQTY is not null then case B.DAYDIFF when 75 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D75,
        case when B.REQQTY is not null then case B.DAYDIFF when 76 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D76,
        case when B.REQQTY is not null then case B.DAYDIFF when 77 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D77,
        case when B.REQQTY is not null then case B.DAYDIFF when 78 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D78,
        case when B.REQQTY is not null then case B.DAYDIFF when 79 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D79,
        case when B.REQQTY is not null then case B.DAYDIFF when 80 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D80,
        case when B.REQQTY is not null then case B.DAYDIFF when 81 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D81,
        case when B.REQQTY is not null then case B.DAYDIFF when 82 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D82,
        case when B.REQQTY is not null then case B.DAYDIFF when 83 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D83,
        case when B.REQQTY is not null then case B.DAYDIFF when 84 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D84,
        case when B.REQQTY is not null then case B.DAYDIFF when 85 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D85,
        case when B.REQQTY is not null then case B.DAYDIFF when 86 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D86,
        case when B.REQQTY is not null then case B.DAYDIFF when 87 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D87,
        case when B.REQQTY is not null then case B.DAYDIFF when 88 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D88,
        case when B.REQQTY is not null then case B.DAYDIFF when 89 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D89,
        case when B.REQQTY is not null then case B.DAYDIFF when 90 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D90,
        case when B.REQQTY is not null then case B.DAYDIFF when 91 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D91,
        case when B.REQQTY is not null then case B.DAYDIFF when 92 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D92,
        case when B.REQQTY is not null then case B.DAYDIFF when 93 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D93,
        case when B.REQQTY is not null then case B.DAYDIFF when 94 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D94,
        case when B.REQQTY is not null then case B.DAYDIFF when 95 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D95,
        case when B.REQQTY is not null then case B.DAYDIFF when 96 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D96,
        case when B.REQQTY is not null then case B.DAYDIFF when 97 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D97,
        case when B.REQQTY is not null then case B.DAYDIFF when 98 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D98,
        case when B.REQQTY is not null then case B.DAYDIFF when 99 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D99,
        case when B.REQQTY is not null then case B.DAYDIFF when 100 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D100,
        case when B.REQQTY is not null then case B.DAYDIFF when 101 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D101,
        case when B.REQQTY is not null then case B.DAYDIFF when 102 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D102,
        case when B.REQQTY is not null then case B.DAYDIFF when 103 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D103,
        case when B.REQQTY is not null then case B.DAYDIFF when 104 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D104,
        case when B.REQQTY is not null then case B.DAYDIFF when 105 then B.REQQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D105

}


union all


// 예상 소요량 기준 - 05 입고 예정량(구매요청 잔량)   
select from ZGTMM_CV_GI_REQCAL_DAILY(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as A
       left outer join ZGTMM_CV_RESERVED_PR_DAILY as B on A.werks = B.werks and A.matnr = B.matnr 

{
   key  A.bukrs,
   key  A.BUKRS_N,   
   key  A.werks,
   key  A.werks_n,
   key  A.matnr,
   key  A.matnr_n, 
   
        cast('H' as abap.char(1)) as TYPE,   
        cast('입고예정수량(PR)' as abap.char(20)) as TYPENAME,         
        A.LT,                                                // LeadTime 
        A.servicefactor, 
                
        A.REQ_TOTAL as REQQTY,                     //총예약수량
        A.meins,       

        A.REQ_DAILY,     
        A.UNQTY,                                         // 창고가용재고
        
        A.BONDEDQTY,                // 보세창고재고        
        A.STOCKVAL,                  // 현 재고 금액
        A.waers,  

        A.F1,  

        A.F2,
        A.PLANWEEK,
        
        case when B.REQTY is not null then case B.DAYDIFF when 1 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D1,
        case when B.REQTY is not null then case B.DAYDIFF when 2 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D2,
        case when B.REQTY is not null then case B.DAYDIFF when 3 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D3,
        case when B.REQTY is not null then case B.DAYDIFF when 4 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D4,
        case when B.REQTY is not null then case B.DAYDIFF when 5 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D5,
        case when B.REQTY is not null then case B.DAYDIFF when 6 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D6,
        case when B.REQTY is not null then case B.DAYDIFF when 7 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D7,
        case when B.REQTY is not null then case B.DAYDIFF when 8 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D8,
        case when B.REQTY is not null then case B.DAYDIFF when 9 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D9,
        case when B.REQTY is not null then case B.DAYDIFF when 10 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D10,
        case when B.REQTY is not null then case B.DAYDIFF when 11 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D11,
        case when B.REQTY is not null then case B.DAYDIFF when 12 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D12,
        case when B.REQTY is not null then case B.DAYDIFF when 13 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D13,
        case when B.REQTY is not null then case B.DAYDIFF when 14 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D14,
        case when B.REQTY is not null then case B.DAYDIFF when 15 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D15,
        case when B.REQTY is not null then case B.DAYDIFF when 16 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D16,
        case when B.REQTY is not null then case B.DAYDIFF when 17 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D17,
        case when B.REQTY is not null then case B.DAYDIFF when 18 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D18,
        case when B.REQTY is not null then case B.DAYDIFF when 19 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D19,
        case when B.REQTY is not null then case B.DAYDIFF when 20 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D20,
        case when B.REQTY is not null then case B.DAYDIFF when 21 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D21,
        case when B.REQTY is not null then case B.DAYDIFF when 22 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D22,
        case when B.REQTY is not null then case B.DAYDIFF when 23 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D23,
        case when B.REQTY is not null then case B.DAYDIFF when 24 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D24,
        case when B.REQTY is not null then case B.DAYDIFF when 25 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D25,
        case when B.REQTY is not null then case B.DAYDIFF when 26 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D26,
        case when B.REQTY is not null then case B.DAYDIFF when 27 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D27,
        case when B.REQTY is not null then case B.DAYDIFF when 28 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D28,
        case when B.REQTY is not null then case B.DAYDIFF when 29 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D29,
        case when B.REQTY is not null then case B.DAYDIFF when 30 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D30,
        case when B.REQTY is not null then case B.DAYDIFF when 31 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D31,
        case when B.REQTY is not null then case B.DAYDIFF when 32 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D32,
        case when B.REQTY is not null then case B.DAYDIFF when 33 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D33,
        case when B.REQTY is not null then case B.DAYDIFF when 34 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D34,
        case when B.REQTY is not null then case B.DAYDIFF when 35 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D35,
        case when B.REQTY is not null then case B.DAYDIFF when 36 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D36,
        case when B.REQTY is not null then case B.DAYDIFF when 37 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D37,
        case when B.REQTY is not null then case B.DAYDIFF when 38 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D38,
        case when B.REQTY is not null then case B.DAYDIFF when 39 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D39,
        case when B.REQTY is not null then case B.DAYDIFF when 40 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D40,
        case when B.REQTY is not null then case B.DAYDIFF when 41 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D41,
        case when B.REQTY is not null then case B.DAYDIFF when 42 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D42,
        case when B.REQTY is not null then case B.DAYDIFF when 43 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D43,
        case when B.REQTY is not null then case B.DAYDIFF when 44 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D44,
        case when B.REQTY is not null then case B.DAYDIFF when 45 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D45,
        case when B.REQTY is not null then case B.DAYDIFF when 46 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D46,
        case when B.REQTY is not null then case B.DAYDIFF when 47 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D47,
        case when B.REQTY is not null then case B.DAYDIFF when 48 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D48,
        case when B.REQTY is not null then case B.DAYDIFF when 49 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D49,
        case when B.REQTY is not null then case B.DAYDIFF when 50 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D50,
        case when B.REQTY is not null then case B.DAYDIFF when 51 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D51,
        case when B.REQTY is not null then case B.DAYDIFF when 52 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D52,
        case when B.REQTY is not null then case B.DAYDIFF when 53 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D53,
        case when B.REQTY is not null then case B.DAYDIFF when 54 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D54,
        case when B.REQTY is not null then case B.DAYDIFF when 55 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D55,
        case when B.REQTY is not null then case B.DAYDIFF when 56 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D56,
        case when B.REQTY is not null then case B.DAYDIFF when 57 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D57,
        case when B.REQTY is not null then case B.DAYDIFF when 58 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D58,
        case when B.REQTY is not null then case B.DAYDIFF when 59 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D59,
        case when B.REQTY is not null then case B.DAYDIFF when 60 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D60,
        case when B.REQTY is not null then case B.DAYDIFF when 61 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D61,
        case when B.REQTY is not null then case B.DAYDIFF when 62 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D62,
        case when B.REQTY is not null then case B.DAYDIFF when 63 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D63,
        case when B.REQTY is not null then case B.DAYDIFF when 64 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D64,
        case when B.REQTY is not null then case B.DAYDIFF when 65 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D65,
        case when B.REQTY is not null then case B.DAYDIFF when 66 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D66,
        case when B.REQTY is not null then case B.DAYDIFF when 67 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D67,
        case when B.REQTY is not null then case B.DAYDIFF when 68 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D68,
        case when B.REQTY is not null then case B.DAYDIFF when 69 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D69,
        case when B.REQTY is not null then case B.DAYDIFF when 70 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D70,
        case when B.REQTY is not null then case B.DAYDIFF when 71 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D71,
        case when B.REQTY is not null then case B.DAYDIFF when 72 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D72,
        case when B.REQTY is not null then case B.DAYDIFF when 73 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D73,
        case when B.REQTY is not null then case B.DAYDIFF when 74 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D74,
        case when B.REQTY is not null then case B.DAYDIFF when 75 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D75,
        case when B.REQTY is not null then case B.DAYDIFF when 76 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D76,
        case when B.REQTY is not null then case B.DAYDIFF when 77 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D77,
        case when B.REQTY is not null then case B.DAYDIFF when 78 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D78,
        case when B.REQTY is not null then case B.DAYDIFF when 79 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D79,
        case when B.REQTY is not null then case B.DAYDIFF when 80 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D80,
        case when B.REQTY is not null then case B.DAYDIFF when 81 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D81,
        case when B.REQTY is not null then case B.DAYDIFF when 82 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D82,
        case when B.REQTY is not null then case B.DAYDIFF when 83 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D83,
        case when B.REQTY is not null then case B.DAYDIFF when 84 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D84,
        case when B.REQTY is not null then case B.DAYDIFF when 85 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D85,
        case when B.REQTY is not null then case B.DAYDIFF when 86 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D86,
        case when B.REQTY is not null then case B.DAYDIFF when 87 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D87,
        case when B.REQTY is not null then case B.DAYDIFF when 88 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D88,
        case when B.REQTY is not null then case B.DAYDIFF when 89 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D89,
        case when B.REQTY is not null then case B.DAYDIFF when 90 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D90,
        case when B.REQTY is not null then case B.DAYDIFF when 91 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D91,
        case when B.REQTY is not null then case B.DAYDIFF when 92 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D92,
        case when B.REQTY is not null then case B.DAYDIFF when 93 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D93,
        case when B.REQTY is not null then case B.DAYDIFF when 94 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D94,
        case when B.REQTY is not null then case B.DAYDIFF when 95 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D95,
        case when B.REQTY is not null then case B.DAYDIFF when 96 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D96,
        case when B.REQTY is not null then case B.DAYDIFF when 97 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D97,
        case when B.REQTY is not null then case B.DAYDIFF when 98 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D98,
        case when B.REQTY is not null then case B.DAYDIFF when 99 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D99,
        case when B.REQTY is not null then case B.DAYDIFF when 100 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D100,
        case when B.REQTY is not null then case B.DAYDIFF when 101 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D101,
        case when B.REQTY is not null then case B.DAYDIFF when 102 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D102,
        case when B.REQTY is not null then case B.DAYDIFF when 103 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D103,
        case when B.REQTY is not null then case B.DAYDIFF when 104 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D104,
        case when B.REQTY is not null then case B.DAYDIFF when 105 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D105
                           
}


union all


// 예상 소요량 기준 - 06 입고 예정량(PO 잔량)   
select from ZGTMM_CV_GI_REQCAL_DAILY(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as A
       left outer join ZGTMM_CV_RESERVED_GR_DAILY  as B on A.werks = B.werks and A.matnr = B.matnr 

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
                
        A.REQ_TOTAL as REQQTY,                    //총예약수량
        A.meins,       

        A.REQ_DAILY,     
        A.UNQTY,                                         // 창고가용재고
        
        A.BONDEDQTY,                // 보세창고재고        
        A.STOCKVAL,                  // 현 재고 금액
        A.waers,  

        A.F1,  

        A.F2,
        A.PLANWEEK,
        
        case when B.REQTY is not null then case B.DAYDIFF when 1 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D1,
        case when B.REQTY is not null then case B.DAYDIFF when 2 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D2,
        case when B.REQTY is not null then case B.DAYDIFF when 3 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D3,
        case when B.REQTY is not null then case B.DAYDIFF when 4 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D4,
        case when B.REQTY is not null then case B.DAYDIFF when 5 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D5,
        case when B.REQTY is not null then case B.DAYDIFF when 6 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D6,
        case when B.REQTY is not null then case B.DAYDIFF when 7 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D7,
        case when B.REQTY is not null then case B.DAYDIFF when 8 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D8,
        case when B.REQTY is not null then case B.DAYDIFF when 9 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D9,
        case when B.REQTY is not null then case B.DAYDIFF when 10 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D10,
        case when B.REQTY is not null then case B.DAYDIFF when 11 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D11,
        case when B.REQTY is not null then case B.DAYDIFF when 12 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D12,
        case when B.REQTY is not null then case B.DAYDIFF when 13 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D13,
        case when B.REQTY is not null then case B.DAYDIFF when 14 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D14,
        case when B.REQTY is not null then case B.DAYDIFF when 15 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D15,
        case when B.REQTY is not null then case B.DAYDIFF when 16 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D16,
        case when B.REQTY is not null then case B.DAYDIFF when 17 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D17,
        case when B.REQTY is not null then case B.DAYDIFF when 18 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D18,
        case when B.REQTY is not null then case B.DAYDIFF when 19 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D19,
        case when B.REQTY is not null then case B.DAYDIFF when 20 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D20,
        case when B.REQTY is not null then case B.DAYDIFF when 21 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D21,
        case when B.REQTY is not null then case B.DAYDIFF when 22 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D22,
        case when B.REQTY is not null then case B.DAYDIFF when 23 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D23,
        case when B.REQTY is not null then case B.DAYDIFF when 24 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D24,
        case when B.REQTY is not null then case B.DAYDIFF when 25 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D25,
        case when B.REQTY is not null then case B.DAYDIFF when 26 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D26,
        case when B.REQTY is not null then case B.DAYDIFF when 27 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D27,
        case when B.REQTY is not null then case B.DAYDIFF when 28 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D28,
        case when B.REQTY is not null then case B.DAYDIFF when 29 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D29,
        case when B.REQTY is not null then case B.DAYDIFF when 30 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D30,
        case when B.REQTY is not null then case B.DAYDIFF when 31 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D31,
        case when B.REQTY is not null then case B.DAYDIFF when 32 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D32,
        case when B.REQTY is not null then case B.DAYDIFF when 33 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D33,
        case when B.REQTY is not null then case B.DAYDIFF when 34 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D34,
        case when B.REQTY is not null then case B.DAYDIFF when 35 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D35,
        case when B.REQTY is not null then case B.DAYDIFF when 36 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D36,
        case when B.REQTY is not null then case B.DAYDIFF when 37 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D37,
        case when B.REQTY is not null then case B.DAYDIFF when 38 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D38,
        case when B.REQTY is not null then case B.DAYDIFF when 39 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D39,
        case when B.REQTY is not null then case B.DAYDIFF when 40 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D40,
        case when B.REQTY is not null then case B.DAYDIFF when 41 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D41,
        case when B.REQTY is not null then case B.DAYDIFF when 42 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D42,
        case when B.REQTY is not null then case B.DAYDIFF when 43 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D43,
        case when B.REQTY is not null then case B.DAYDIFF when 44 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D44,
        case when B.REQTY is not null then case B.DAYDIFF when 45 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D45,
        case when B.REQTY is not null then case B.DAYDIFF when 46 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D46,
        case when B.REQTY is not null then case B.DAYDIFF when 47 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D47,
        case when B.REQTY is not null then case B.DAYDIFF when 48 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D48,
        case when B.REQTY is not null then case B.DAYDIFF when 49 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D49,
        case when B.REQTY is not null then case B.DAYDIFF when 50 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D50,
        case when B.REQTY is not null then case B.DAYDIFF when 51 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D51,
        case when B.REQTY is not null then case B.DAYDIFF when 52 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D52,
        case when B.REQTY is not null then case B.DAYDIFF when 53 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D53,
        case when B.REQTY is not null then case B.DAYDIFF when 54 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D54,
        case when B.REQTY is not null then case B.DAYDIFF when 55 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D55,
        case when B.REQTY is not null then case B.DAYDIFF when 56 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D56,
        case when B.REQTY is not null then case B.DAYDIFF when 57 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D57,
        case when B.REQTY is not null then case B.DAYDIFF when 58 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D58,
        case when B.REQTY is not null then case B.DAYDIFF when 59 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D59,
        case when B.REQTY is not null then case B.DAYDIFF when 60 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D60,
        case when B.REQTY is not null then case B.DAYDIFF when 61 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D61,
        case when B.REQTY is not null then case B.DAYDIFF when 62 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D62,
        case when B.REQTY is not null then case B.DAYDIFF when 63 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D63,
        case when B.REQTY is not null then case B.DAYDIFF when 64 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D64,
        case when B.REQTY is not null then case B.DAYDIFF when 65 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D65,
        case when B.REQTY is not null then case B.DAYDIFF when 66 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D66,
        case when B.REQTY is not null then case B.DAYDIFF when 67 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D67,
        case when B.REQTY is not null then case B.DAYDIFF when 68 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D68,
        case when B.REQTY is not null then case B.DAYDIFF when 69 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D69,
        case when B.REQTY is not null then case B.DAYDIFF when 70 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D70,
        case when B.REQTY is not null then case B.DAYDIFF when 71 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D71,
        case when B.REQTY is not null then case B.DAYDIFF when 72 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D72,
        case when B.REQTY is not null then case B.DAYDIFF when 73 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D73,
        case when B.REQTY is not null then case B.DAYDIFF when 74 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D74,
        case when B.REQTY is not null then case B.DAYDIFF when 75 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D75,
        case when B.REQTY is not null then case B.DAYDIFF when 76 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D76,
        case when B.REQTY is not null then case B.DAYDIFF when 77 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D77,
        case when B.REQTY is not null then case B.DAYDIFF when 78 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D78,
        case when B.REQTY is not null then case B.DAYDIFF when 79 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D79,
        case when B.REQTY is not null then case B.DAYDIFF when 80 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D80,
        case when B.REQTY is not null then case B.DAYDIFF when 81 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D81,
        case when B.REQTY is not null then case B.DAYDIFF when 82 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D82,
        case when B.REQTY is not null then case B.DAYDIFF when 83 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D83,
        case when B.REQTY is not null then case B.DAYDIFF when 84 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D84,
        case when B.REQTY is not null then case B.DAYDIFF when 85 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D85,
        case when B.REQTY is not null then case B.DAYDIFF when 86 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D86,
        case when B.REQTY is not null then case B.DAYDIFF when 87 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D87,
        case when B.REQTY is not null then case B.DAYDIFF when 88 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D88,
        case when B.REQTY is not null then case B.DAYDIFF when 89 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D89,
        case when B.REQTY is not null then case B.DAYDIFF when 90 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D90,
        case when B.REQTY is not null then case B.DAYDIFF when 91 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D91,
        case when B.REQTY is not null then case B.DAYDIFF when 92 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D92,
        case when B.REQTY is not null then case B.DAYDIFF when 93 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D93,
        case when B.REQTY is not null then case B.DAYDIFF when 94 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D94,
        case when B.REQTY is not null then case B.DAYDIFF when 95 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D95,
        case when B.REQTY is not null then case B.DAYDIFF when 96 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D96,
        case when B.REQTY is not null then case B.DAYDIFF when 97 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D97,
        case when B.REQTY is not null then case B.DAYDIFF when 98 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D98,
        case when B.REQTY is not null then case B.DAYDIFF when 99 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D99,
        case when B.REQTY is not null then case B.DAYDIFF when 100 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D100,
        case when B.REQTY is not null then case B.DAYDIFF when 101 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D101,
        case when B.REQTY is not null then case B.DAYDIFF when 102 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D102,
        case when B.REQTY is not null then case B.DAYDIFF when 103 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D103,
        case when B.REQTY is not null then case B.DAYDIFF when 104 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D104,
        case when B.REQTY is not null then case B.DAYDIFF when 105 then B.REQTY else cast(0 as abap.quan(13,3)) end else cast(0 as abap.quan(13,3)) end as D105
                           
}
union all
// 실적 소요량 기준 - 10 SIMULATION
select from ZGTMM_CV_GI_REQCAL_DAILY(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as A

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

        A.REQ_TOTAL as REQQTY,                    //총예약수량
        A.meins,       

        A.REQ_DAILY,     
        A.UNQTY,                                         // 창고가용재고
        
        A.BONDEDQTY,                // 보세창고재고        
        A.STOCKVAL,                  // 현 재고 금액
        A.waers,
        
        A.F1,  

        A.F2,
        A.PLANWEEK,
        
        cast(0 as abap.quan(13,3)) as D1,
        cast(0 as abap.quan(13,3)) as D2,
        cast(0 as abap.quan(13,3)) as D3,
        cast(0 as abap.quan(13,3)) as D4,
        cast(0 as abap.quan(13,3)) as D5,
        cast(0 as abap.quan(13,3)) as D6,
        cast(0 as abap.quan(13,3)) as D7,
        cast(0 as abap.quan(13,3)) as D8,
        cast(0 as abap.quan(13,3)) as D9,
        cast(0 as abap.quan(13,3)) as D10,
        cast(0 as abap.quan(13,3)) as D11,
        cast(0 as abap.quan(13,3)) as D12,
        cast(0 as abap.quan(13,3)) as D13,
        cast(0 as abap.quan(13,3)) as D14,
        cast(0 as abap.quan(13,3)) as D15,
        cast(0 as abap.quan(13,3)) as D16,
        cast(0 as abap.quan(13,3)) as D17,
        cast(0 as abap.quan(13,3)) as D18,
        cast(0 as abap.quan(13,3)) as D19,
        cast(0 as abap.quan(13,3)) as D20,
        cast(0 as abap.quan(13,3)) as D21,
        cast(0 as abap.quan(13,3)) as D22,
        cast(0 as abap.quan(13,3)) as D23,
        cast(0 as abap.quan(13,3)) as D24,
        cast(0 as abap.quan(13,3)) as D25,
        cast(0 as abap.quan(13,3)) as D26,
        cast(0 as abap.quan(13,3)) as D27,
        cast(0 as abap.quan(13,3)) as D28,
        cast(0 as abap.quan(13,3)) as D29,
        cast(0 as abap.quan(13,3)) as D30,
        cast(0 as abap.quan(13,3)) as D31,
        cast(0 as abap.quan(13,3)) as D32,
        cast(0 as abap.quan(13,3)) as D33,
        cast(0 as abap.quan(13,3)) as D34,
        cast(0 as abap.quan(13,3)) as D35,
        cast(0 as abap.quan(13,3)) as D36,
        cast(0 as abap.quan(13,3)) as D37,
        cast(0 as abap.quan(13,3)) as D38,
        cast(0 as abap.quan(13,3)) as D39,
        cast(0 as abap.quan(13,3)) as D40,
        cast(0 as abap.quan(13,3)) as D41,
        cast(0 as abap.quan(13,3)) as D42,
        cast(0 as abap.quan(13,3)) as D43,
        cast(0 as abap.quan(13,3)) as D44,
        cast(0 as abap.quan(13,3)) as D45,
        cast(0 as abap.quan(13,3)) as D46,
        cast(0 as abap.quan(13,3)) as D47,
        cast(0 as abap.quan(13,3)) as D48,
        cast(0 as abap.quan(13,3)) as D49,
        cast(0 as abap.quan(13,3)) as D50,
        cast(0 as abap.quan(13,3)) as D51,
        cast(0 as abap.quan(13,3)) as D52,
        cast(0 as abap.quan(13,3)) as D53,
        cast(0 as abap.quan(13,3)) as D54,
        cast(0 as abap.quan(13,3)) as D55,
        cast(0 as abap.quan(13,3)) as D56,
        cast(0 as abap.quan(13,3)) as D57,
        cast(0 as abap.quan(13,3)) as D58,
        cast(0 as abap.quan(13,3)) as D59,
        cast(0 as abap.quan(13,3)) as D60,
        cast(0 as abap.quan(13,3)) as D61,
        cast(0 as abap.quan(13,3)) as D62,
        cast(0 as abap.quan(13,3)) as D63,
        cast(0 as abap.quan(13,3)) as D64,
        cast(0 as abap.quan(13,3)) as D65,
        cast(0 as abap.quan(13,3)) as D66,
        cast(0 as abap.quan(13,3)) as D67,
        cast(0 as abap.quan(13,3)) as D68,
        cast(0 as abap.quan(13,3)) as D69,
        cast(0 as abap.quan(13,3)) as D70,
        cast(0 as abap.quan(13,3)) as D71,
        cast(0 as abap.quan(13,3)) as D72,
        cast(0 as abap.quan(13,3)) as D73,
        cast(0 as abap.quan(13,3)) as D74,
        cast(0 as abap.quan(13,3)) as D75,
        cast(0 as abap.quan(13,3)) as D76,
        cast(0 as abap.quan(13,3)) as D77,
        cast(0 as abap.quan(13,3)) as D78,
        cast(0 as abap.quan(13,3)) as D79,
        cast(0 as abap.quan(13,3)) as D80,
        cast(0 as abap.quan(13,3)) as D81,
        cast(0 as abap.quan(13,3)) as D82,
        cast(0 as abap.quan(13,3)) as D83,
        cast(0 as abap.quan(13,3)) as D84,
        cast(0 as abap.quan(13,3)) as D85,
        cast(0 as abap.quan(13,3)) as D86,
        cast(0 as abap.quan(13,3)) as D87,
        cast(0 as abap.quan(13,3)) as D88,
        cast(0 as abap.quan(13,3)) as D89,
        cast(0 as abap.quan(13,3)) as D90,
        cast(0 as abap.quan(13,3)) as D91,
        cast(0 as abap.quan(13,3)) as D92,
        cast(0 as abap.quan(13,3)) as D93,
        cast(0 as abap.quan(13,3)) as D94,
        cast(0 as abap.quan(13,3)) as D95,
        cast(0 as abap.quan(13,3)) as D96,
        cast(0 as abap.quan(13,3)) as D97,
        cast(0 as abap.quan(13,3)) as D98,
        cast(0 as abap.quan(13,3)) as D99,
        cast(0 as abap.quan(13,3)) as D100,
        cast(0 as abap.quan(13,3)) as D101,
        cast(0 as abap.quan(13,3)) as D102,
        cast(0 as abap.quan(13,3)) as D103,
        cast(0 as abap.quan(13,3)) as D104,
        cast(0 as abap.quan(13,3)) as D105
}

union all
// 예상 소요량 기준 - 11 입고 예정 변경
select from ZGTMM_CV_GI_REQCAL_DAILY(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as A
       left outer join ZGTMM_CV_RESERVED_PR_DAILY as B on A.werks = B.werks and A.matnr = B.matnr 
       left outer join ZGTMM_CV_RESERVED_GR_DAILY  as C on A.werks = C.werks and A.matnr = C.matnr 

{
   key  A.bukrs,
   key  A.BUKRS_N,   
   key  A.werks,
   key  A.werks_n,
   key  A.matnr,
   key  A.matnr_n, 
   
        cast('K' as abap.char(1)) as TYPE,  
        cast('입고예정수량변경' as abap.char(20)) as TYPENAME, 
        A.LT,                                                // LeadTime 
        A.servicefactor, 

        A.REQ_TOTAL as REQQTY,                    //총예약수량
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
                       then case when B.DAYDIFF = 1
                                 then case when C.DAYDIFF = 1
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.DAYDIFF = 1
                                           then C.REQTY
                                           else cast(0 as abap.quan(13,3))
                                           end                                 
                                 end
                       else case when B.DAYDIFF = 1
                                 then B.REQTY
                                 else  cast(0 as abap.quan(13,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.DAYDIFF = 1
                                 then C.REQTY
                                 else cast(0 as abap.quan(13,3))                                
                                 end
                       else cast(0 as abap.quan(13,3))                       
                       end
             end as D1, 
                       
         case when B.REQTY is not null 
             then case when C.REQTY is not null 
                       then case when B.DAYDIFF = 2
                                 then case when C.DAYDIFF = 2
                                           then B.REQTY + C.REQTY
                                           else B.REQTY
                                           end
                                 else case when C.DAYDIFF = 2
                                           then C.REQTY
                                           else cast(0 as abap.quan(13,3))
                                           end                                 
                                 end
                       else case when B.DAYDIFF = 2
                                 then B.REQTY
                                 else  cast(0 as abap.quan(13,3))
                                 end
                       end
             else case when C.REQTY is not null 
                       then case when C.DAYDIFF = 2
                                 then C.REQTY
                                 else cast(0 as abap.quan(13,3))                                
                                 end
                       else cast(0 as abap.quan(13,3))                       
                       end
             end as D2, 
             
    case when B.REQTY is not null
    then case when C.REQTY is not null
    then case when B.DAYDIFF = 3
    then case when C.DAYDIFF = 3
    then B.REQTY + C.REQTY
    else B.REQTY
    end
    else case when C.DAYDIFF = 3
    then C.REQTY
    else cast(0 as abap.quan(13,3))
    end
    end
    else case when B.DAYDIFF = 3
    then B.REQTY
    else cast(0 as abap.quan(13,3))
    end
    end
    else case when C.REQTY is not null
    then case when C.DAYDIFF = 3
    then C.REQTY
    else cast(0 as abap.quan(13,3))
    end
    else cast(0 as abap.quan(13,3))
    end
    end as D3,
    
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 4
        then case when C.DAYDIFF = 4
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 4
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 4
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 4
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D4,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 5
        then case when C.DAYDIFF = 5
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 5
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 5
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 5
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D5,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 6
        then case when C.DAYDIFF = 6
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 6
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 6
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 6
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D6,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 7
        then case when C.DAYDIFF = 7
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 7
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 7
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 7
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D7,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 8
        then case when C.DAYDIFF = 8
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 8
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 8
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 8
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D8,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 9
        then case when C.DAYDIFF = 9
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 9
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 9
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 9
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D9,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 10
        then case when C.DAYDIFF = 10
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 10
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 10
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 10
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D10,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 11
        then case when C.DAYDIFF = 11
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 11
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 11
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 11
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D11,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 12
        then case when C.DAYDIFF = 12
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 12
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 12
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 12
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D12,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 13
        then case when C.DAYDIFF = 13
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 13
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 13
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 13
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D13,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 14
        then case when C.DAYDIFF = 14
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 14
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 14
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 14
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D14,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 15
        then case when C.DAYDIFF = 15
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 15
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 15
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 15
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D15,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 16
        then case when C.DAYDIFF = 16
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 16
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 16
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 16
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D16,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 17
        then case when C.DAYDIFF = 17
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 17
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 17
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 17
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D17,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 18
        then case when C.DAYDIFF = 18
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 18
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 18
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 18
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D18,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 19
        then case when C.DAYDIFF = 19
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 19
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 19
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 19
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D19,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 20
        then case when C.DAYDIFF = 20
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 20
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 20
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 20
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D20,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 21
        then case when C.DAYDIFF = 21
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 21
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 21
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 21
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D21,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 22
        then case when C.DAYDIFF = 22
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 22
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 22
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 22
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D22,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 23
        then case when C.DAYDIFF = 23
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 23
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 23
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 23
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D23,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 24
        then case when C.DAYDIFF = 24
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 24
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 24
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 24
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D24,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 25
        then case when C.DAYDIFF = 25
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 25
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 25
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 25
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D25,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 26
        then case when C.DAYDIFF = 26
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 26
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 26
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 26
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D26,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 27
        then case when C.DAYDIFF = 27
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 27
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 27
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 27
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D27,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 28
        then case when C.DAYDIFF = 28
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 28
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 28
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 28
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D28,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 29
        then case when C.DAYDIFF = 29
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 29
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 29
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 29
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D29,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 30
        then case when C.DAYDIFF = 30
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 30
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 30
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 30
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D30,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 31
        then case when C.DAYDIFF = 31
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 31
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 31
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 31
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D31,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 32
        then case when C.DAYDIFF = 32
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 32
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 32
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 32
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D32,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 33
        then case when C.DAYDIFF = 33
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 33
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 33
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 33
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D33,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 34
        then case when C.DAYDIFF = 34
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 34
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 34
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 34
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D34,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 35
        then case when C.DAYDIFF = 35
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 35
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 35
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 35
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D35,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 36
        then case when C.DAYDIFF = 36
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 36
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 36
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 36
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D36,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 37
        then case when C.DAYDIFF = 37
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 37
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 37
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 37
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D37,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 38
        then case when C.DAYDIFF = 38
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 38
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 38
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 38
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D38,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 39
        then case when C.DAYDIFF = 39
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 39
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 39
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 39
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D39,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 40
        then case when C.DAYDIFF = 40
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 40
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 40
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 40
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D40,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 41
        then case when C.DAYDIFF = 41
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 41
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 41
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 41
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D41,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 42
        then case when C.DAYDIFF = 42
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 42
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 42
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 42
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D42,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 43
        then case when C.DAYDIFF = 43
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 43
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 43
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 43
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D43,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 44
        then case when C.DAYDIFF = 44
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 44
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 44
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 44
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D44,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 45
        then case when C.DAYDIFF = 45
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 45
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 45
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 45
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D45,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 46
        then case when C.DAYDIFF = 46
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 46
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 46
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 46
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D46,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 47
        then case when C.DAYDIFF = 47
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 47
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 47
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 47
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D47,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 48
        then case when C.DAYDIFF = 48
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 48
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 48
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 48
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D48,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 49
        then case when C.DAYDIFF = 49
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 49
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 49
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 49
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D49,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 50
        then case when C.DAYDIFF = 50
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 50
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 50
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 50
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D50,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 51
        then case when C.DAYDIFF = 51
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 51
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 51
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 51
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D51,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 52
        then case when C.DAYDIFF = 52
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 52
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 52
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 52
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D52,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 53
        then case when C.DAYDIFF = 53
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 53
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 53
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 53
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D53,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 54
        then case when C.DAYDIFF = 54
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 54
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 54
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 54
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D54,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 55
        then case when C.DAYDIFF = 55
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 55
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 55
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 55
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D55,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 56
        then case when C.DAYDIFF = 56
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 56
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 56
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 56
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D56,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 57
        then case when C.DAYDIFF = 57
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 57
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 57
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 57
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D57,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 58
        then case when C.DAYDIFF = 58
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 58
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 58
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 58
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D58,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 59
        then case when C.DAYDIFF = 59
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 59
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 59
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 59
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D59,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 60
        then case when C.DAYDIFF = 60
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 60
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 60
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 60
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D60,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 61
        then case when C.DAYDIFF = 61
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 61
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 61
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 61
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D61,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 62
        then case when C.DAYDIFF = 62
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 62
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 62
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 62
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D62,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 63
        then case when C.DAYDIFF = 63
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 63
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 63
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 63
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D63,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 64
        then case when C.DAYDIFF = 64
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 64
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 64
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 64
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D64,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 65
        then case when C.DAYDIFF = 65
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 65
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 65
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 65
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D65,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 66
        then case when C.DAYDIFF = 66
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 66
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 66
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 66
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D66,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 67
        then case when C.DAYDIFF = 67
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 67
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 67
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 67
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D67,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 68
        then case when C.DAYDIFF = 68
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 68
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 68
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 68
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D68,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 69
        then case when C.DAYDIFF = 69
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 69
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 69
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 69
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D69,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 70
        then case when C.DAYDIFF = 70
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 70
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 70
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 70
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D70,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 71
        then case when C.DAYDIFF = 71
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 71
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 71
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 71
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D71,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 72
        then case when C.DAYDIFF = 72
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 72
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 72
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 72
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D72,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 73
        then case when C.DAYDIFF = 73
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 73
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 73
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 73
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D73,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 74
        then case when C.DAYDIFF = 74
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 74
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 74
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 74
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D74,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 75
        then case when C.DAYDIFF = 75
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 75
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 75
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 75
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D75,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 76
        then case when C.DAYDIFF = 76
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 76
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 76
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 76
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D76,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 77
        then case when C.DAYDIFF = 77
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 77
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 77
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 77
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D77,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 78
        then case when C.DAYDIFF = 78
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 78
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 78
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 78
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D78,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 79
        then case when C.DAYDIFF = 79
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 79
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 79
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 79
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D79,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 80
        then case when C.DAYDIFF = 80
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 80
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 80
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 80
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D80,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 81
        then case when C.DAYDIFF = 81
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 81
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 81
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 81
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D81,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 82
        then case when C.DAYDIFF = 82
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 82
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 82
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 82
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D82,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 83
        then case when C.DAYDIFF = 83
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 83
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 83
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 83
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D83,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 84
        then case when C.DAYDIFF = 84
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 84
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 84
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 84
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D84,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 85
        then case when C.DAYDIFF = 85
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 85
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 85
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 85
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D85,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 86
        then case when C.DAYDIFF = 86
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 86
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 86
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 86
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D86,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 87
        then case when C.DAYDIFF = 87
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 87
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 87
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 87
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D87,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 88
        then case when C.DAYDIFF = 88
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 88
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 88
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 88
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D88,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 89
        then case when C.DAYDIFF = 89
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 89
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 89
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 89
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D89,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 90
        then case when C.DAYDIFF = 90
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 90
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 90
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 90
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D90,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 91
        then case when C.DAYDIFF = 91
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 91
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 91
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 91
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D91,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 92
        then case when C.DAYDIFF = 92
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 92
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 92
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 92
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D92,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 93
        then case when C.DAYDIFF = 93
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 93
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 93
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 93
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D93,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 94
        then case when C.DAYDIFF = 94
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 94
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 94
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 94
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D94,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 95
        then case when C.DAYDIFF = 95
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 95
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 95
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 95
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D95,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 96
        then case when C.DAYDIFF = 96
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 96
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 96
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 96
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D96,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 97
        then case when C.DAYDIFF = 97
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 97
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 97
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 97
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D97,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 98
        then case when C.DAYDIFF = 98
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 98
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 98
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 98
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D98,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 99
        then case when C.DAYDIFF = 99
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 99
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 99
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 99
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D99,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 100
        then case when C.DAYDIFF = 100
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 100
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 100
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 100
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D100,
        
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 101
        then case when C.DAYDIFF = 101
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 101
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 101
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 101
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D101,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 102
        then case when C.DAYDIFF = 102
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 102
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 102
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 102
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D102,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 103
        then case when C.DAYDIFF = 103
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 103
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 103
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 103
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D103,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 104
        then case when C.DAYDIFF = 104
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 104
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 104
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 104
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D104,
        
        case when B.REQTY is not null
        then case when C.REQTY is not null
        then case when B.DAYDIFF = 105
        then case when C.DAYDIFF = 105
        then B.REQTY + C.REQTY
        else B.REQTY
        end
        else case when C.DAYDIFF = 105
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when B.DAYDIFF = 105
        then B.REQTY
        else cast(0 as abap.quan(13,3))
        end
        end
        else case when C.REQTY is not null
        then case when C.DAYDIFF = 105
        then C.REQTY
        else cast(0 as abap.quan(13,3))
        end
        else cast(0 as abap.quan(13,3))
        end
        end as D105
}

union all
// 예상 소요량 기준 - 12 SIMULATION 필드
select from ZGTMM_CV_GI_REQCAL_DAILY(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as A

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

        A.REQ_TOTAL as REQQTY,                    //총예약수량
        A.meins,       

        A.REQ_DAILY,     
        A.UNQTY,                                         // 창고가용재고
        
        A.BONDEDQTY,                // 보세창고재고        
        A.STOCKVAL,                  // 현 재고 금액
        A.waers,
        
        A.F1,  

        A.F2,
        A.PLANWEEK,
        
        cast(0 as abap.quan(13,3)) as D1,
        cast(0 as abap.quan(13,3)) as D2,
        cast(0 as abap.quan(13,3)) as D3,
        cast(0 as abap.quan(13,3)) as D4,
        cast(0 as abap.quan(13,3)) as D5,
        cast(0 as abap.quan(13,3)) as D6,
        cast(0 as abap.quan(13,3)) as D7,
        cast(0 as abap.quan(13,3)) as D8,
        cast(0 as abap.quan(13,3)) as D9,
        cast(0 as abap.quan(13,3)) as D10,
        cast(0 as abap.quan(13,3)) as D11,
        cast(0 as abap.quan(13,3)) as D12,
        cast(0 as abap.quan(13,3)) as D13,
        cast(0 as abap.quan(13,3)) as D14,
        cast(0 as abap.quan(13,3)) as D15,
        cast(0 as abap.quan(13,3)) as D16,
        cast(0 as abap.quan(13,3)) as D17,
        cast(0 as abap.quan(13,3)) as D18,
        cast(0 as abap.quan(13,3)) as D19,
        cast(0 as abap.quan(13,3)) as D20,
        cast(0 as abap.quan(13,3)) as D21,
        cast(0 as abap.quan(13,3)) as D22,
        cast(0 as abap.quan(13,3)) as D23,
        cast(0 as abap.quan(13,3)) as D24,
        cast(0 as abap.quan(13,3)) as D25,
        cast(0 as abap.quan(13,3)) as D26,
        cast(0 as abap.quan(13,3)) as D27,
        cast(0 as abap.quan(13,3)) as D28,
        cast(0 as abap.quan(13,3)) as D29,
        cast(0 as abap.quan(13,3)) as D30,
        cast(0 as abap.quan(13,3)) as D31,
        cast(0 as abap.quan(13,3)) as D32,
        cast(0 as abap.quan(13,3)) as D33,
        cast(0 as abap.quan(13,3)) as D34,
        cast(0 as abap.quan(13,3)) as D35,
        cast(0 as abap.quan(13,3)) as D36,
        cast(0 as abap.quan(13,3)) as D37,
        cast(0 as abap.quan(13,3)) as D38,
        cast(0 as abap.quan(13,3)) as D39,
        cast(0 as abap.quan(13,3)) as D40,
        cast(0 as abap.quan(13,3)) as D41,
        cast(0 as abap.quan(13,3)) as D42,
        cast(0 as abap.quan(13,3)) as D43,
        cast(0 as abap.quan(13,3)) as D44,
        cast(0 as abap.quan(13,3)) as D45,
        cast(0 as abap.quan(13,3)) as D46,
        cast(0 as abap.quan(13,3)) as D47,
        cast(0 as abap.quan(13,3)) as D48,
        cast(0 as abap.quan(13,3)) as D49,
        cast(0 as abap.quan(13,3)) as D50,
        cast(0 as abap.quan(13,3)) as D51,
        cast(0 as abap.quan(13,3)) as D52,
        cast(0 as abap.quan(13,3)) as D53,
        cast(0 as abap.quan(13,3)) as D54,
        cast(0 as abap.quan(13,3)) as D55,
        cast(0 as abap.quan(13,3)) as D56,
        cast(0 as abap.quan(13,3)) as D57,
        cast(0 as abap.quan(13,3)) as D58,
        cast(0 as abap.quan(13,3)) as D59,
        cast(0 as abap.quan(13,3)) as D60,
        cast(0 as abap.quan(13,3)) as D61,
        cast(0 as abap.quan(13,3)) as D62,
        cast(0 as abap.quan(13,3)) as D63,
        cast(0 as abap.quan(13,3)) as D64,
        cast(0 as abap.quan(13,3)) as D65,
        cast(0 as abap.quan(13,3)) as D66,
        cast(0 as abap.quan(13,3)) as D67,
        cast(0 as abap.quan(13,3)) as D68,
        cast(0 as abap.quan(13,3)) as D69,
        cast(0 as abap.quan(13,3)) as D70,
        cast(0 as abap.quan(13,3)) as D71,
        cast(0 as abap.quan(13,3)) as D72,
        cast(0 as abap.quan(13,3)) as D73,
        cast(0 as abap.quan(13,3)) as D74,
        cast(0 as abap.quan(13,3)) as D75,
        cast(0 as abap.quan(13,3)) as D76,
        cast(0 as abap.quan(13,3)) as D77,
        cast(0 as abap.quan(13,3)) as D78,
        cast(0 as abap.quan(13,3)) as D79,
        cast(0 as abap.quan(13,3)) as D80,
        cast(0 as abap.quan(13,3)) as D81,
        cast(0 as abap.quan(13,3)) as D82,
        cast(0 as abap.quan(13,3)) as D83,
        cast(0 as abap.quan(13,3)) as D84,
        cast(0 as abap.quan(13,3)) as D85,
        cast(0 as abap.quan(13,3)) as D86,
        cast(0 as abap.quan(13,3)) as D87,
        cast(0 as abap.quan(13,3)) as D88,
        cast(0 as abap.quan(13,3)) as D89,
        cast(0 as abap.quan(13,3)) as D90,
        cast(0 as abap.quan(13,3)) as D91,
        cast(0 as abap.quan(13,3)) as D92,
        cast(0 as abap.quan(13,3)) as D93,
        cast(0 as abap.quan(13,3)) as D94,
        cast(0 as abap.quan(13,3)) as D95,
        cast(0 as abap.quan(13,3)) as D96,
        cast(0 as abap.quan(13,3)) as D97,
        cast(0 as abap.quan(13,3)) as D98,
        cast(0 as abap.quan(13,3)) as D99,
        cast(0 as abap.quan(13,3)) as D100,
        cast(0 as abap.quan(13,3)) as D101,
        cast(0 as abap.quan(13,3)) as D102, 
        cast(0 as abap.quan(13,3)) as D103,
        cast(0 as abap.quan(13,3)) as D104,
        cast(0 as abap.quan(13,3)) as D105
}
