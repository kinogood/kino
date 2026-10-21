@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '일 단위 적정재고 SIMULATION BASE2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_AGG_STOCK_DAILY2 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as
select from ZGTMM_CV_AGG_STOCK_DAILY15(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as a 

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
        a.D1,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D2,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D3,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D4,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D5,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D6,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D7,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D8,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D9,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D10,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D11,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D12,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D13,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D14,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D15,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D16,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D17,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D18,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D19,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D20,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D21,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D22,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D23,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D24,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D25,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D26,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D27,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D28,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D29,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D30,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D31,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D32,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D33,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D34,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D35,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D36,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D37,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D38,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D39,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D40,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D41,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D42,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D43,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D44,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D45,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D46,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D47,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D48,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D49,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D50,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D51,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D52,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D53,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D54,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D55,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D56,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D57,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D58,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D59,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D60,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D61,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D62,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D63,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D64,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D65,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D66,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D67,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D68,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D69,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D70,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D71,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D72,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D73,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D74,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D75,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D76,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D77,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D78,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D79,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D80,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D81,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D82,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D83,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D84,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D85,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D86,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D87,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D88,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D89,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D90,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D91,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D92,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D93,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D94,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D95,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D96,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D97,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D98,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D99,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D100,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D101,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D102,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D103,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D104,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        a.D105       
}  where a.TYPE = 'A' or  a.TYPE = 'B' or a.TYPE = 'C' or a.TYPE = 'E' or a.TYPE = 'G' or a.TYPE = 'H' or a.TYPE = 'I' or a.TYPE = 'K'


union all

select from ZGTMM_CV_AGG_STOCK_DAILY15(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as a
       inner join ZGTMM_CV_AGG_STOCK_DAILY15(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as B
       on a.bukrs = B.bukrs and a.werks = B.werks and a.matnr = B.matnr 
       inner join ZGTMM_CV_AGG_STOCK_DAILY15(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as C
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
        
        a.BONDEDQTY,                // 보세창고재고        
        a.STOCKVAL,                  // 현 재고 금액
        a.waers,  

        a.F1,  

        a.F2,
        a.PLANWEEK,
 
        a.UNQTY + a.BONDEDQTY - B.D1 + C.D1 as D1, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2) + ( C.D1+C.D2) as D2,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3) +
          ( C.D1+C.D2+C.D3) as D3,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4) +
          ( C.D1+C.D2+C.D3+C.D4) as D4,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5) as D5,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6) as D6,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7) as D7,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8) as D8,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9) as D9,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10) as D10,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11) as D11,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12) as D12,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13) as D13,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14) as D14,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15) as D15,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16) as D16,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17) as D17,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18) as D18,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19) as D19,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20) as D20,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21) as D21,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22) as D22,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23) as D23,
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24) as D24, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25) as D25,
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26) as D26,                     
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27) as D27,
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28) as D28,
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29) as D29,
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30) as D30,                     
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31) as D31, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32) as D32, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33) as D33, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34) as D34,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35) as D35, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36) as D36,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37) as D37,                     
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38) as D38, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39) as D39,
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40) as D40,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41) as D41,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42) as D42,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43) as D43, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44) as D44,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45) as D45,                    
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46) as D46, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47) as D47,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48) as D48, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49) as D49,                    
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50) as D50, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51) as D51,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52) as D52,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53) as D53,                     
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54) as D54,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55) as D55,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56) as D56,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57) as D57,                    
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58) as D58,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59) as D59,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60) as D60,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61) as D61,                     
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62) as D62, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63) as D63,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64) as D64,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65) as D65, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66) as D66, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67) as D67, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68) as D68,                     
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69) as D69, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70) as D70,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71) as D71,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72) as D72,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73) as D73,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74) as D74, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75) as D75,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76) as D76,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77) as D77,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78) as D78, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79) as D79,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80) as D80,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81) as D81,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82) as D82,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83) as D83, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84) as D84,                     
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85) as D85,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86) as D86,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87) as D87, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88) as D88,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89) as D89, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90) as D90,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91) as D91,                     
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92) as D92, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93) as D93,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94) as D94, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94+B.D95) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94+C.D95) as D95,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94+B.D95+B.D96) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94+C.D95+C.D96) as D96,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94+B.D95+B.D96+B.D97) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94+C.D95+C.D96+C.D97) as D97,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94+B.D95+B.D96+B.D97+B.D98) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94+C.D95+C.D96+C.D97+C.D98) as D98,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94+B.D95+B.D96+B.D97+B.D98+B.D99) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94+C.D95+C.D96+C.D97+C.D98+C.D99) as D99,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94+B.D95+B.D96+B.D97+B.D98+B.D99+B.D100) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94+C.D95+C.D96+C.D97+C.D98+C.D99+C.D100) as D100,
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94+B.D95+B.D96+B.D97+B.D98+B.D99+B.D100+
            B.D101) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94+C.D95+C.D96+C.D97+C.D98+C.D99+C.D100+
            C.D101) as D101,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94+B.D95+B.D96+B.D97+B.D98+B.D99+B.D100+
            B.D101+B.D102) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94+C.D95+C.D96+C.D97+C.D98+C.D99+C.D100+
            C.D101+C.D102) as D102,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94+B.D95+B.D96+B.D97+B.D98+B.D99+B.D100+
            B.D101+B.D102+B.D103) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94+C.D95+C.D96+C.D97+C.D98+C.D99+C.D100+
            C.D101+C.D102+C.D103) as D103,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94+B.D95+B.D96+B.D97+B.D98+B.D99+B.D100+
            B.D101+B.D102+B.D103+B.D104) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94+C.D95+C.D96+C.D97+C.D98+C.D99+C.D100+
            C.D101+C.D102+C.D103+C.D104) as D104,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94+B.D95+B.D96+B.D97+B.D98+B.D99+B.D100+
            B.D101+B.D102+B.D103+B.D104+B.D105) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94+C.D95+C.D96+C.D97+C.D98+C.D99+C.D100+
            C.D101+C.D102+C.D103+C.D104+C.D105) as D105  
       
        
} where (a.TYPE = 'D' or a.TYPE = 'F') and B.TYPE = 'A' and C.TYPE ='E'


union all

select from ZGTMM_CV_AGG_STOCK_DAILY15(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as a
       inner join ZGTMM_CV_AGG_STOCK_DAILY15(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as B
       on a.bukrs = B.bukrs and a.werks = B.werks and a.matnr = B.matnr 
       inner join ZGTMM_CV_AGG_STOCK_DAILY15(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as C
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
        
        a.BONDEDQTY,                // 보세창고재고        
        a.STOCKVAL,                  // 현 재고 금액
        a.waers,  

        a.F1,  

        a.F2,
        a.PLANWEEK,
 
        a.UNQTY + a.BONDEDQTY - B.D1 + C.D1 as D1, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2) + ( C.D1+C.D2) as D2,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3) +
          ( C.D1+C.D2+C.D3) as D3,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4) +
          ( C.D1+C.D2+C.D3+C.D4) as D4,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5) as D5,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6) as D6,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7) as D7,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8) as D8,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9) as D9,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10) as D10,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11) as D11,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12) as D12,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13) as D13,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14) as D14,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15) as D15,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16) as D16,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17) as D17,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18) as D18,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19) as D19,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20) as D20,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21) as D21,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22) as D22,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23) as D23,
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24) as D24, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25) as D25,
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26) as D26,                     
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27) as D27,
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28) as D28,
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29) as D29,
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30) as D30,                     
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31) as D31, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32) as D32, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33) as D33, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34) as D34,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35) as D35, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36) as D36,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37) as D37,                     
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38) as D38, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39) as D39,
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40) as D40,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41) as D41,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42) as D42,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43) as D43, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44) as D44,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45) as D45,                    
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46) as D46, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47) as D47,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48) as D48, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49) as D49,                    
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50) as D50, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51) as D51,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52) as D52,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53) as D53,                     
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54) as D54,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55) as D55,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56) as D56,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57) as D57,                    
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58) as D58,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59) as D59,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60) as D60,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61) as D61,                     
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62) as D62, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63) as D63,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64) as D64,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65) as D65, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66) as D66, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67) as D67, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68) as D68,                     
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69) as D69, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70) as D70,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71) as D71,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72) as D72,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73) as D73,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74) as D74, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75) as D75,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76) as D76,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77) as D77,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78) as D78, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79) as D79,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80) as D80,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81) as D81,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82) as D82,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83) as D83, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84) as D84,                     
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85) as D85,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86) as D86,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87) as D87, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88) as D88,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89) as D89, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90) as D90,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91) as D91,                     
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92) as D92, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93) as D93,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94) as D94, 
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94+B.D95) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94+C.D95) as D95,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94+B.D95+B.D96) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94+C.D95+C.D96) as D96,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94+B.D95+B.D96+B.D97) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94+C.D95+C.D96+C.D97) as D97,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94+B.D95+B.D96+B.D97+B.D98) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94+C.D95+C.D96+C.D97+C.D98) as D98,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94+B.D95+B.D96+B.D97+B.D98+B.D99) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94+C.D95+C.D96+C.D97+C.D98+C.D99) as D99,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94+B.D95+B.D96+B.D97+B.D98+B.D99+B.D100) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94+C.D95+C.D96+C.D97+C.D98+C.D99+C.D100) as D100,
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94+B.D95+B.D96+B.D97+B.D98+B.D99+B.D100+
            B.D101) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94+C.D95+C.D96+C.D97+C.D98+C.D99+C.D100+
            C.D101) as D101,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94+B.D95+B.D96+B.D97+B.D98+B.D99+B.D100+
            B.D101+B.D102) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94+C.D95+C.D96+C.D97+C.D98+C.D99+C.D100+
            C.D101+C.D102) as D102,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94+B.D95+B.D96+B.D97+B.D98+B.D99+B.D100+
            B.D101+B.D102+B.D103) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94+C.D95+C.D96+C.D97+C.D98+C.D99+C.D100+
            C.D101+C.D102+C.D103) as D103,                      
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94+B.D95+B.D96+B.D97+B.D98+B.D99+B.D100+
            B.D101+B.D102+B.D103+B.D104) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94+C.D95+C.D96+C.D97+C.D98+C.D99+C.D100+
            C.D101+C.D102+C.D103+C.D104) as D104,  
        a.UNQTY + a.BONDEDQTY - 
          ( B.D1+B.D2+B.D3+B.D4+B.D5+B.D6+B.D7+B.D8+B.D9+B.D10+
            B.D11+B.D12+B.D13+B.D14+B.D15+B.D16+B.D17+B.D18+B.D19+B.D20+
            B.D21+B.D22+B.D23+B.D24+B.D25+B.D26+B.D27+B.D28+B.D29+B.D30+
            B.D31+B.D32+B.D33+B.D34+B.D35+B.D36+B.D37+B.D38+B.D39+B.D40+
            B.D41+B.D42+B.D43+B.D44+B.D45+B.D46+B.D47+B.D48+B.D49+B.D50+
            B.D51+B.D52+B.D53+B.D54+B.D55+B.D56+B.D57+B.D58+B.D59+B.D60+
            B.D61+B.D62+B.D63+B.D64+B.D65+B.D66+B.D67+B.D68+B.D69+B.D70+
            B.D71+B.D72+B.D73+B.D74+B.D75+B.D76+B.D77+B.D78+B.D79+B.D80+
            B.D81+B.D82+B.D83+B.D84+B.D85+B.D86+B.D87+B.D88+B.D89+B.D90+
            B.D91+B.D92+B.D93+B.D94+B.D95+B.D96+B.D97+B.D98+B.D99+B.D100+
            B.D101+B.D102+B.D103+B.D104+B.D105) +
          ( C.D1+C.D2+C.D3+C.D4+C.D5+C.D6+C.D7+C.D8+C.D9+C.D10+
            C.D11+C.D12+C.D13+C.D14+C.D15+C.D16+C.D17+C.D18+C.D19+C.D20+
            C.D21+C.D22+C.D23+C.D24+C.D25+C.D26+C.D27+C.D28+C.D29+C.D30+
            C.D31+C.D32+C.D33+C.D34+C.D35+C.D36+C.D37+C.D38+C.D39+C.D40+
            C.D41+C.D42+C.D43+C.D44+C.D45+C.D46+C.D47+C.D48+C.D49+C.D50+
            C.D51+C.D52+C.D53+C.D54+C.D55+C.D56+C.D57+C.D58+C.D59+C.D60+
            C.D61+C.D62+C.D63+C.D64+C.D65+C.D66+C.D67+C.D68+C.D69+C.D70+
            C.D71+C.D72+C.D73+C.D74+C.D75+C.D76+C.D77+C.D78+C.D79+C.D80+
            C.D81+C.D82+C.D83+C.D84+C.D85+C.D86+C.D87+C.D88+C.D89+C.D90+
            C.D91+C.D92+C.D93+C.D94+C.D95+C.D96+C.D97+C.D98+C.D99+C.D100+
            C.D101+C.D102+C.D103+C.D104+C.D105) as D105  
       
        
} where (a.TYPE = 'J' or a.TYPE = 'L') and B.TYPE = 'G' and C.TYPE ='K'
