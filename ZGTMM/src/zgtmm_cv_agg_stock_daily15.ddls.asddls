@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '일 단위 적정재고 SIMULATION BASE1.5'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_AGG_STOCK_DAILY15 
with parameters 
    @Consumption.hidden: true
    @Environment.systemField: #SYSTEM_DATE
    p_startdate : vdm_v_start_date,
    p_enddate : vdm_v_end_date
as
select from ZGTMM_CV_AGG_STOCK_DAILY1(p_startdate: $parameters.p_startdate,p_enddate : $parameters.p_enddate) as a 

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
        cast(ROUND(a.REQQTY,0) as abap.quan(13,0)) as REQQTY,                   //총예약수량
        a.meins,       

        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(a.REQ_DAILY,0) as abap.quan(21,0)) as REQ_DAILY,    
        @Semantics.quantity.unitOfMeasure: 'MEINS' 
        cast(ROUND(a.UNQTY,0) as abap.quan(21,0)) as UNQTY,                                        // 창고가용재고
        
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(a.BONDEDQTY,0) as abap.quan(21,0)) as BONDEDQTY,                // 보세창고재고        
        @Semantics.amount.currencyCode: 'waers'
        a.STOCKVAL,                  // 현 재고 금액
        a.waers,  

        a.F1,  

        @Semantics.quantity.unitOfMeasure: 'MEINS'             
        a.F2,
        a.PLANWEEK,
        
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D1),0) as abap.quan(21,0)) as D1,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D2),0) as abap.quan(21,0)) as D2,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D3),0) as abap.quan(21,0)) as D3,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D4),0) as abap.quan(21,0)) as D4,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D5),0) as abap.quan(21,0)) as D5,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D6),0) as abap.quan(21,0)) as D6,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D7),0) as abap.quan(21,0)) as D7,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D8),0) as abap.quan(21,0)) as D8,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D9),0) as abap.quan(21,0)) as D9,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D10),0) as abap.quan(21,0)) as D10,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D11),0) as abap.quan(21,0)) as D11,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D12),0) as abap.quan(21,0)) as D12,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D13),0) as abap.quan(21,0)) as D13,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D14),0) as abap.quan(21,0)) as D14,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D15),0) as abap.quan(21,0)) as D15,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D16),0) as abap.quan(21,0)) as D16,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D17),0) as abap.quan(21,0)) as D17,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D18),0) as abap.quan(21,0)) as D18,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D19),0) as abap.quan(21,0)) as D19,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D20),0) as abap.quan(21,0)) as D20,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D21),0) as abap.quan(21,0)) as D21,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D22),0) as abap.quan(21,0)) as D22,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D23),0) as abap.quan(21,0)) as D23,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D24),0) as abap.quan(21,0)) as D24,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D25),0) as abap.quan(21,0)) as D25,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D26),0) as abap.quan(21,0)) as D26,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D27),0) as abap.quan(21,0)) as D27,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D28),0) as abap.quan(21,0)) as D28,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D29),0) as abap.quan(21,0)) as D29,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D30),0) as abap.quan(21,0)) as D30,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D31),0) as abap.quan(21,0)) as D31,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D32),0) as abap.quan(21,0)) as D32,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D33),0) as abap.quan(21,0)) as D33,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D34),0) as abap.quan(21,0)) as D34,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D35),0) as abap.quan(21,0)) as D35,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D36),0) as abap.quan(21,0)) as D36,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D37),0) as abap.quan(21,0)) as D37,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D38),0) as abap.quan(21,0)) as D38,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D39),0) as abap.quan(21,0)) as D39,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D40),0) as abap.quan(21,0)) as D40,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D41),0) as abap.quan(21,0)) as D41,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D42),0) as abap.quan(21,0)) as D42,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D43),0) as abap.quan(21,0)) as D43,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D44),0) as abap.quan(21,0)) as D44,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D45),0) as abap.quan(21,0)) as D45,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D46),0) as abap.quan(21,0)) as D46,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D47),0) as abap.quan(21,0)) as D47,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D48),0) as abap.quan(21,0)) as D48,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D49),0) as abap.quan(21,0)) as D49,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D50),0) as abap.quan(21,0)) as D50,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D51),0) as abap.quan(21,0)) as D51,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D52),0) as abap.quan(21,0)) as D52,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D53),0) as abap.quan(21,0)) as D53,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D54),0) as abap.quan(21,0)) as D54,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D55),0) as abap.quan(21,0)) as D55,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D56),0) as abap.quan(21,0)) as D56,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D57),0) as abap.quan(21,0)) as D57,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D58),0) as abap.quan(21,0)) as D58,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D59),0) as abap.quan(21,0)) as D59,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D60),0) as abap.quan(21,0)) as D60,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D61),0) as abap.quan(21,0)) as D61,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D62),0) as abap.quan(21,0)) as D62,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D63),0) as abap.quan(21,0)) as D63,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D64),0) as abap.quan(21,0)) as D64,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D65),0) as abap.quan(21,0)) as D65,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D66),0) as abap.quan(21,0)) as D66,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D67),0) as abap.quan(21,0)) as D67,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D68),0) as abap.quan(21,0)) as D68,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D69),0) as abap.quan(21,0)) as D69,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D70),0) as abap.quan(21,0)) as D70,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D71),0) as abap.quan(21,0)) as D71,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D72),0) as abap.quan(21,0)) as D72,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D73),0) as abap.quan(21,0)) as D73,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D74),0) as abap.quan(21,0)) as D74,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D75),0) as abap.quan(21,0)) as D75,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D76),0) as abap.quan(21,0)) as D76,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D77),0) as abap.quan(21,0)) as D77,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D78),0) as abap.quan(21,0)) as D78,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D79),0) as abap.quan(21,0)) as D79,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D80),0) as abap.quan(21,0)) as D80,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D81),0) as abap.quan(21,0)) as D81,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D82),0) as abap.quan(21,0)) as D82,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D83),0) as abap.quan(21,0)) as D83,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D84),0) as abap.quan(21,0)) as D84,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D85),0) as abap.quan(21,0)) as D85,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D86),0) as abap.quan(21,0)) as D86,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D87),0) as abap.quan(21,0)) as D87,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D88),0) as abap.quan(21,0)) as D88,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D89),0) as abap.quan(21,0)) as D89,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D90),0) as abap.quan(21,0)) as D90,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D91),0) as abap.quan(21,0)) as D91,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D92),0) as abap.quan(21,0)) as D92,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D93),0) as abap.quan(21,0)) as D93,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D94),0) as abap.quan(21,0)) as D94,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D95),0) as abap.quan(21,0)) as D95,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D96),0) as abap.quan(21,0)) as D96,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D97),0) as abap.quan(21,0)) as D97,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D98),0) as abap.quan(21,0)) as D98,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D99),0) as abap.quan(21,0)) as D99,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D100),0) as abap.quan(21,0)) as D100,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D101),0) as abap.quan(21,0)) as D101,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D102),0) as abap.quan(21,0)) as D102,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D103),0) as abap.quan(21,0)) as D103,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D104),0) as abap.quan(21,0)) as D104,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        cast(ROUND(sum(a.D105),0) as abap.quan(21,0)) as D105 
       
}  group by  a.bukrs, a.BUKRS_N, a.werks, a.werks_n, a.matnr, a.matnr_n, a.TYPE, a.TYPENAME, 
             a.LT, a.servicefactor, a.REQQTY, a.meins, a.REQ_DAILY, a.UNQTY, a.BONDEDQTY,          
             a.STOCKVAL, a.waers, a.F1, a.F2, a.PLANWEEK      
