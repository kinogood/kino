@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '업체 보관 재고 현황 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_OEM_STOCK_SD 
as select from ZGTMM_CV_GET_OEM_STOCK as a
association [0..1] to ZGTMM_CV_GET_OEM_STOCK_REQ as b on $projection.vbeln = b.vbeln and $projection.posnr = b.posnr and b.WBSTA <> 'C'

{
  key a.matnr,
  key a.werks,
  key a.TYPE, 
  key a.lgort,
      a.lifnr,
      a.vbeln,
      a.posnr,
      @Semantics.quantity.unitOfMeasure: 'meins'       
      a.STOCK,
      a.meins,
      a.length,
      @Semantics.quantity.unitOfMeasure: 'dr_meins'  
     case when a.length > 0 
        then cast((a.STOCK / a.length)  as abap.quan(13,3)) 
        else cast(0 as abap.quan(13,3)) end as stock_drqty,       
      @Semantics.quantity.unitOfMeasure: 'dr_meins'    
      case when b.REQ_DRQTY is not null then
         b.REQ_DRQTY
      else
        cast(0 as abap.quan(13,3)) 
      end as req_drqty,
      @Semantics.quantity.unitOfMeasure: 'dr_meins'      
      case when b.REQ_DRQTY is not null then  
        case when a.length > 0 
           then cast((a.STOCK / a.length) - b.REQ_DRQTY  as abap.quan(13,3)) 
           else cast(0 as abap.quan(13,3)) end 
       else    
         case when a.length > 0 
           then cast((a.STOCK / a.length)   as abap.quan(13,3)) 
           else cast(0 as abap.quan(13,3)) end
       end as rem_drqty,      
      cast('DR' as abap.unit) as dr_meins

} where a.werks = '6500' or a.werks = '6600'
