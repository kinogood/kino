@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직송 요청 및 승인 수량 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_DDQTYBASE 
as
select from zgtmmt4410 as A inner join zgtmmt4411 as B on A.bukrs = B.bukrs and A.dlvrq = B.dlvrq 
// left outer join ZGTMM_CV_GET_OEM_DELIVER_ITEM as c on A.zreq_type = c.zreq_type and B.vbeln = c.vbeln and B.posnr = c.posnr and B.ebeln = c.ebeln and B.ebelp = c.ebelp
association [0..1] to ZGTMM_CV_GET_OEM_DELIVER_ITEM   as C
                   on $projection.zreq_type = C.zreq_type and  $projection.vbeln = C.vbeln and $projection.posnr = C.posnr and $projection.ebeln = C.ebeln and $projection.ebelp = C.ebelp

{
 key A.zreq_type,
 key B.bukrs, 
 key B.vbeln,
 key B.posnr,
 key B.ebeln,
 key B.ebelp,
 @Semantics.quantity.unitOfMeasure: 'DR_MEINS' 
 B.req_drqty,
 @Semantics.quantity.unitOfMeasure: 'DR_MEINS' 
 case when B.zmm_stat = 'A' then B.req_drqty else cast(0 as abap.quan(13,3)) end as ZMM_DRQTY,
 @Semantics.quantity.unitOfMeasure: 'DR_MEINS' 
 case when B.zvd_stat = 'A' then B.req_drqty else cast(0 as abap.quan(13,3)) end as ZVD_DRQTY, 
 B.dr_meins,  
 case when C.ebeln is not null then
         case when C.GRCHECK <> '' then cast('' as abap.char(1))
         else  cast('X' as abap.char(1)) end
      else cast('X' as abap.char(1)) end as checkmm
} where A.zsd_stat = 'R' and (B.zmm_stat = '' or B.zmm_stat = 'A' ) and (B.zvd_stat <> 'R')

/*
union all

select from zgtmmt4410 as A inner join zgtmmt4412 as B on A.bukrs = B.bukrs and A.dlvrq = B.dlvrq 
{
 key A.zreq_type,
 key B.bukrs, 
 key B.vbeln,
 key B.posnr,
 key cast('' as ebeln ) as ebeln,
 key cast('' as ebelp) as ebelp,
 B.req_drqty, 
 case when B.zmm_stat = 'A' then B.req_drqty else cast(0 as abap.quan(13,3)) end as ZMM_DRQTY,
 case when B.zvd_stat = 'A' then B.req_drqty else cast(0 as abap.quan(13,3)) end as ZVD_DRQTY, 
 B.dr_meins  
} where A.zsd_stat = 'R' and (B.zmm_stat = '' or B.zmm_stat = 'A' )*/
