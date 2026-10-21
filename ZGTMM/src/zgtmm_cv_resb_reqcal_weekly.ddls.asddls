@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '예약 기준 적정 재고 산출 용 플랜트/자재 별 소요량 계산(주별)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_RESB_REQCAL_WEEKLY 
as 
select from ZGTMM_CV_RESB_GI_MATNR as A 
       left outer join ZGTMM_CV_RESB_WEEKLY_CAL2 as B on A.werks = B.werks and A.matnr = B.matnr
       left outer join ZGTMM_CV_RESB_DAILY_REQ as C on A.werks = C.werks and A.matnr = C.matnr
   association [1..1] to zgtmmt4202 as ZGTMMT4202 on  ZGTMMT4202.werks = $projection.werks and ZGTMMT4202.zuse = 'X'   //$projection.bukrs = ZGTMMT4202.bukrs and ZGTMMT4202.zuse = 'X'  
{
   key  A.bukrs,
   key  A.BUKRS_N,   
   key  A.werks,
   key  A.werks_n,  
   key  A.matnr,
   key  A.matnr_n,
   
        A.LT,                                                // LeadTime 
        zgtmmt4202.factor as servicefactor, 
                
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        case when B.REQQTY is not null then B.REQQTY else cast(0 as abap.quan(21,3)) end as REQQTY,                   //총예약수량
        A.meins,       

        @Semantics.quantity.unitOfMeasure: 'MEINS'
        case when C.DREQ is not null then C.DREQ else cast(0 as abap.quan(21,3)) end as REQ_DAILY,     
        @Semantics.quantity.unitOfMeasure: 'MEINS' 
        A.UNQTY,                                         // 창고가용재고
        
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        A.BONDEDQTY,                // 보세창고재고        
        @Semantics.amount.currencyCode: 'waers'
        A.STOCKVAL,                  // 현 재고 금액
        A.waers,  

        cast(A.LT / 7 as abap.dec(6,3)) as F1,     
         @Semantics.quantity.unitOfMeasure: 'MEINS'             
        case when B.AVGQTY is not null then B.AVGQTY else cast(0 as abap.quan(21,3)) end as F2,
        A.PLANWEEK          
}






/*
select from ZGTMM_CV_RESB_WEEKLY_CAL2 as A 
            inner join ZGTMM_CV_RESB_DAILY_REQ as B on A.werks = B.werks and A.matnr = B.matnr
            inner join ZGTMM_CV_GETMAXLTIME as C on  A.werks = C.werks and A.matnr = C.matnr  
            left outer join ZGTMM_CV_GETPLANTSTOCKVAL as D on A.werks = D.werks and A.matnr = D.matnr  
   association [1..1] to t001 as T001 on $projection.bukrs = T001.bukrs
   association [1..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language   
   association [1..1] to t001w as T001W on $projection.werks = T001W.werks     
   association [1..1] to zgtmmt4202 as ZGTMMT4202 on $projection.bukrs = ZGTMMT4202.bukrs and ZGTMMT4202.zuse = 'X'      
{
   key  A.bukrs,
   key  t001.butxt as bukrs_n,   
   key  A.werks,
   key  t001w.name1 as werks_n,
   key  A.matnr,
   key  makt.maktx as matnr_n, 
   

        C.APLFZ as LT,                                                // LeadTime 
        zgtmmt4202.factor as servicefactor, 
                
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        A.REQQTY,                    //총예약수량
        A.meins,       

        @Semantics.quantity.unitOfMeasure: 'MEINS'
        B.DREQ as REQ_DAILY,     
        @Semantics.quantity.unitOfMeasure: 'MEINS' 
        case when D.UNQTY is null then cast(0 as abap.quan(21,3))
             else D.UNQTY end as UNQTY,                                         // 창고가용재고
        
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        case when D.BDQTY is null then cast(0 as abap.quan(21,3))
             else D.BDQTY end as BONDEDQTY,                // 보세창고재고        
        @Semantics.amount.currencyCode: 'waers'
        case when D.STOCKVAL is null then cast(0 as salk3)
             else D.STOCKVAL end as STOCKVAL,                  // 현 재고 금액
        D.waers,  

        cast(C.APLFZ / 7 as abap.dec(6,3)) as F1,  
          

        @Semantics.quantity.unitOfMeasure: 'MEINS'             
        A.AVGQTY as F2,
        A.PLANWEEK                                         
}
*/
