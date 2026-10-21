@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZNFT0002 LME 입력 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_LME_INFO_MONTHLY 
//as select from znft0002 as A inner join znft0002 as B on A.inmon = B.inmon
//                             inner join znft0002 as C on A.inmon = C.inmon
as select from ZGTMM_CV_GET_LME_INFO_DAILY
{
/*   key A.inmon,
   key left(A.inmon,4) as cyear,
       @Semantics.amount.currencyCode: 'CU_WAERS'    
       A.o_cash as CU_CASH,
       A.o_cash_waers as CU_WAERS,
       @Semantics.amount.currencyCode: 'AL_WAERS'    
       B.o_cash as AL_CASH,
       B.o_cash_waers as AL_WAERS,
       @Semantics.amount.currencyCode: 'PB_WAERS'    
       C.o_cash as PB_CASH,
       C.o_cash_waers as PB_WAERS */
       
   key LEFT(indat,6) as INMON,
       @Semantics.amount.currencyCode: 'CU_WAERS'    
       CU_CASH,
       CU_WAERS,
       @Semantics.amount.currencyCode: 'CU_WAERS'           
       CU_3M,
       @Semantics.amount.currencyCode: 'AL_WAERS'    
       AL_CASH,
       AL_WAERS,
       @Semantics.amount.currencyCode: 'AL_WAERS'    
       AL_3M,            
       @Semantics.amount.currencyCode: 'PB_WAERS'    
       PB_CASH,
       PB_WAERS,
       @Semantics.amount.currencyCode: 'PB_WAERS'    
       PB_3M                
       
}
