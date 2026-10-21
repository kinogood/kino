@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZNFT0001 LME 입력 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_LME_INFO_DAILY 
as select from znft0001 as A inner join znft0001 as B on A.indat = B.indat
                             inner join znft0001 as C on A.indat = C.indat
{
   key A.indat,
       @Semantics.amount.currencyCode: 'CU_WAERS'    
       A.o_cash as CU_CASH,
       A.o_cash_waers as CU_WAERS,
       @Semantics.amount.currencyCode: 'CU_WAERS'           
       A.c_3m as CU_3M,
       @Semantics.amount.currencyCode: 'AL_WAERS'    
       B.o_cash as AL_CASH,
       B.o_cash_waers as AL_WAERS,
       @Semantics.amount.currencyCode: 'AL_WAERS'    
       B.c_3m as AL_3M,            
       @Semantics.amount.currencyCode: 'PB_WAERS'    
       C.o_cash as PB_CASH,
       C.o_cash_waers as PB_WAERS,
       @Semantics.amount.currencyCode: 'PB_WAERS'    
       C.c_3m as PB_3M          
       
} where A.nfkey = 'CU1' and B.nfkey = 'AL1' and C.nfkey = 'PB1'
