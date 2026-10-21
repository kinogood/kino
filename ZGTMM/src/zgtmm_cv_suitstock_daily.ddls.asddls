@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '일자 별 적정재고(주차 기준)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SUITSTOCK_DAILY 
as select from zgtmmt4220 as a inner join ZGTMM_CV_SUITSTOCK_AGG as b on a.timestamp = b.timestamp
                                                                   and a.bukrs = b.bukrs  
                                                                   and a.werks = b.werks
                                                                   and a.matnr = b.matnr
                               inner join zgtmmt4221 as C on b.timestamp = C.timestamp
                                                        and b.bukrs = C.bukrs
                                                        and b.werks = C.werks
                                                        and b.matnr = C.matnr
                                                        and C.type = 'A'
                               inner join zgtmmt4221 as D on b.timestamp = D.timestamp
                                                        and b.bukrs = D.bukrs
                                                        and b.werks = D.werks
                                                        and b.matnr = D.matnr
                                                        and D.type = 'G'                                                        
                                                                                                        


{
   key C.bukrs,
   key C.werks,
   key C.matnr,
   @Semantics.quantity.unitOfMeasure: 'meins'
   C.su_qty as su_qty_f,      //미래
   @Semantics.quantity.unitOfMeasure: 'meins'
   D.su_qty as SU_QTY_P,      //과거
   C.meins,
   a.erdat 
}
