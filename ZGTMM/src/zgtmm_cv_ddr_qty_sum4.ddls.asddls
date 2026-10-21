@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 배차 수량 집계'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_DDR_QTY_SUM4 
as select from zgtmmt4410 as A inner join zgtmmt4411 as B on A.bukrs = B.bukrs and A.dlvrq = B.dlvrq
                               inner join zgtmmt4403 as c on B.bukrs = c.bukrs and A.zreq_type = c.zreq_type and B.dlvrq = c.dlvrq and B.vbeln = c.vbeln and B.posnr = c.posnr and B.ebeln = c.ebeln and B.ebelp = c.ebelp
{
   key A.bukrs,
   key A.dlvrq,
   @Semantics.quantity.unitOfMeasure: 'dr_meins'      
   cast(sum(c.loadqty) as abap.int4) as REQ_COUNT, 
   c.dr_meins
} where B.zvd_stat = 'A' and A.zreq_type = 'A' and A.zsd_stat = 'R' and c.zmm_check = 'A'
group by A.bukrs, A.dlvrq, c.dr_meins

union all

select from zgtmmt4410 as A inner join zgtmmt4412 as B on A.bukrs = B.bukrs and A.dlvrq = B.dlvrq
                            inner join zgtmmt4405 as c on B.bukrs = c.bukrs and A.zreq_type = c.zreq_type and B.dlvrq = c.dlvrq and B.vbeln = c.vbeln and B.posnr = c.posnr 
{
   key A.bukrs,
   key A.dlvrq,
   cast(sum(c.loadqty) as abap.int4) as REQ_COUNT, 
   c.dr_meins 
} where B.zvd_stat = 'A' and A.zreq_type = 'B' and A.zsd_stat = 'R' and c.zmm_check = 'A'
group by A.bukrs, A.dlvrq, c.dr_meins



