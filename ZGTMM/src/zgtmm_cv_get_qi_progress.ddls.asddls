@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 검사 요청 결과 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_QI_PROGRESS 
as select from zgtmmt4402 as A inner join ekko as B on A.ebeln = B.ebeln
{
    key A.bukrs,
    key A.ebeln,
    key A.ebelp,
    key A.zinsp_no,
     @Semantics.quantity.unitOfMeasure: 'MEINS'     
        A.zinsp_qty,
        A.meins,
        A.zinsp_date,
        A.zinsptype,
        A.zinspdate,
        A.zinspres,
        A.zinsp_certi,
        A.zinsp_perno,
        A.zinsp_name,
        B.lifnr,
        A.aedat 
}
