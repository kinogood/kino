@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 직송 납품 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_OEM_DELIVER_ITEM
 as select from zgtmmt4403 as B 
      inner join zgtmmt4411 as a on a.dlvrq = B.dlvrq and a.vbeln = B.vbeln and a.posnr = B.posnr and a.ebeln = B.ebeln and a.ebelp = B.ebelp
      left outer join ZGTMM_CV_GET_GODELIVERY_SUM2   as c  on B.delno = c.delno and B.delitem = c.delitem



{
    key B.bukrs,
        B.zreq_type,
        B.dlvrq,
        B.vbeln,
        B.posnr,
        B.ebeln,
        B.ebelp,
        @Semantics.quantity.unitOfMeasure: 'DR_MEINS'           
        sum(B.loadqty) as LOADQTY,
        B.dr_meins,
        case when c.ebeln is not null then c.ebeln else cast('' as ebeln) end as GRCHECK
}  
group by B.bukrs,     B.zreq_type,      B.dlvrq,       B.vbeln,
        B.posnr,        B.ebeln,        B.ebelp,        B.dr_meins , c.ebeln
