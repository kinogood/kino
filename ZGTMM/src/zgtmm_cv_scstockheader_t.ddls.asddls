@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 사급 업체 보증금액+사급재고액(임시)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SCSTOCKHEADER_T 
as 
select from ZGTMM_CV_SCSTOCKHEADER_CAL  as A 
   left outer join ZGTMM_CV_DEPOSITAMT_SUM as B on A.bukrs = B.bukrs and A.lifnr = B.lifnr
{
    key A.bukrs,
    key A.lifnr,
        A.butxt,
        A.VENDORNAME,
        
        //보증보험금액
        @Semantics.amount.currencyCode: 'waers'
        cast(cast(B.PREIS as abap.dec(13,2)) as abap.curr(13,2)) as PREIS,
        
        //재고총액          
        @Semantics.amount.currencyCode: 'waers'  
        //GET_NUMERIC_VALUE(A.totalscvalue) as totalscvalue,
        A.totalscvalue,
        A.waers,
        
        //한도금액(보증보험금액 - 재고총액)
        @Semantics.amount.currencyCode: 'waers'  
//        GET_NUMERIC_VALUE(B.PREIS) - GET_NUMERIC_VALUE(A.totalscvalue)  as limitvalue,
        case when B.PREIS is null then cast(0 as abap.curr(13,2)) - A.totalscvalue
             else  B.PREIS - A.totalscvalue end as limitvalue
 
/*        //당월 AP
        @Semantics.amount.currencyCode: 'waers'
        cast(0 as abap.curr(11,2)) as APvalue*/
}


union

select from ZGTMM_CV_DEPOSITAMT_SUM as B  
   left outer join ZGTMM_CV_SCSTOCKHEADER_CAL as A on A.bukrs = B.bukrs and A.lifnr = B.lifnr
{
    key B.bukrs,
    key B.lifnr,
        B.butxt,
        B.vendorname,
        
        //보증보험금액
        cast(cast(B.PREIS as abap.dec(13,2)) as abap.curr(13,2)) as PREIS,
        
        //재고총액          
        //GET_NUMERIC_VALUE(A.totalscvalue) as totalscvalue,
        A.totalscvalue,
        B.waers,
        
        //한도금액(보증보험금액 - 재고총액)
//        GET_NUMERIC_VALUE(B.PREIS) - GET_NUMERIC_VALUE(A.totalscvalue)  as limitvalue,
        case when B.PREIS is null then cast(0 as abap.curr(13,2)) - A.totalscvalue
             else  B.PREIS - A.totalscvalue end as limitvalue
 
/*        //당월 AP
        @Semantics.amount.currencyCode: 'waers'
        cast(0 as abap.curr(11,2)) as APvalue*/
}
