@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 직송 납품서 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_OEM_DELIVERY_DOC 
as select from zgtmmt4403 as B left outer join ZGTMM_CV_GET_GODELIVERY_DATA2  as A
               on A.delno = B.delno and A.delitem = B.delitem
//as select from zgtmmt4403 as B left outer join ZGTMM_CV_GET_GODELIVERY_DATA as A
//               on A.delno = B.delno and A.delitem = B.delitem               
{
    key B.bukrs
/*    ,
        B.zreq_type,
        B.dlvrq,
        B.vbeln,
        B.posnr,
        B.ebeln,
        B.ebelp,
        B.zseq,
        B.ztrtype,
        B.regiont,
        B.no2digit,
        B.ch1digit,
        B.no4digit,
        B.tel,
        B.name,
        B.parcelname,
        @Semantics.quantity.unitOfMeasure: 'DR_MEINS'           
        B.loadqty,
        B.dr_meins,
        B.zdoc_no,
        B.zdoc_item_no,
        B.zdoc_date,
        B.delno,
        B.delitem,
        B.gidate,
        B.zmm_check,
        A.BUDAT,
        A.MJAHR,
        A.MBLNR,
        cast('' as mblpo) as ZEILE */
} 
