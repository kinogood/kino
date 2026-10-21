@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 사급 업체 보증금액+사급재고액(최종)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SCSTOCKHEADER 
as select from ZGTMM_CV_SCSTOCKHEADER_T as A
     left outer join ZGTMM_CV_EXPECTEDIV_SUM as B on A.bukrs = B.bukrs and A.lifnr = B.lifnr 
{
    key A.bukrs,
    key A.lifnr,
        A.butxt,
        A.VENDORNAME,
        
        //보증보험금액
        @Semantics.amount.currencyCode: 'waers'
        A.PREIS,
        
        //재고총액          
        @Semantics.amount.currencyCode: 'waers'  
        cast(cast(A.totalscvalue as abap.dec(13,2)) as abap.curr(13,2)) as totalscvalue,
        A.waers,
        
        //한도금액(보증보험금액 - 재고총액)
        @Semantics.amount.currencyCode: 'waers'  
        cast(cast(A.limitvalue as abap.dec(13,2)) as abap.curr(13,2)) as limitvalue,
        
        //당월 AP
        @Semantics.amount.currencyCode: 'waers'
        case when B.EXPECTEDIV is null then cast(0 as abap.curr(13,2))
             else B.EXPECTEDIV
        end as APvalue    
}
