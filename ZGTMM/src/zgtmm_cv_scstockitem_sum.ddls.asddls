@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 사급 재고 현황(자재 별 가격 SUM)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SCSTOCKITEM_SUM 

as select from ZGTMM_CV_SCSTOCKITEM
{
    key bukrs,
    key werks,    
    key lifnr,
    key matnr,
    key charg,
        TAGNR,
        butxt,
        PLANTNAME,
        VENDORNAME,
        maktx,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        lblab,
        meins,
    
        VPRSV,
        @Semantics.amount.currencyCode: 'waers'       
        VERPR,
        @Semantics.amount.currencyCode: 'waers'       
        STPRS,         
        PEINH,   
        waers,
        @Semantics.amount.currencyCode: 'waers'   
 /*       case when VPRSV = 'S' then
             cast(GET_NUMERIC_VALUE(STPRS) *  lblab  / PEINH as abap.dec(13,2))  
             else 
             cast(GET_NUMERIC_VALUE(VERPR) *  lblab  / PEINH as abap.dec(13,2))              
        end as totalscvalue   */
        case when VPRSV = 'S' then
             cast(round(cast(cast(STPRS as abap.dec(13,3)) *  lblab  / PEINH as abap.dec(13,3)),2) as abap.curr(13,2))  
             else 
             cast(round(cast(cast(VERPR as abap.dec(13,3)) *  lblab  / PEINH as abap.dec(13,3)),2) as abap.curr(13,2))              
        end as totalscvalue,
        xpcbt
     
}
