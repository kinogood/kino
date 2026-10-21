@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직송 의뢰 배차 정보 RAW DATA'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_TRANSRAW 
as select from zgtmmt4403 as A inner join ekpo as B on A.ebeln = B.ebeln and A.ebelp = B.ebelp
association [0..1] to ZGTMM_CV_GET_GODELIVERY_SUM  as GR1 on $projection.delno = GR1.delno and $projection.delitem = GR1.delitem 
association [0..1] to ZGTMM_CV_SO_VCVALUE as SO on $projection.vbeln = SO.vbeln and $projection.posnr = SO.posnr and SO.atnam = 'SAP_MILLCA_LENGTH'
{
  key   A.bukrs,
  key   A.zreq_type,
  key   A.dlvrq,
  key   A.vbeln,
  key   A.posnr,
  key   A.ebeln,
  key   A.ebelp,
  key   A.zseq,
        A.ztrtype,
        A.regiont,
        A.no2digit,
        A.ch1digit,
        A.no4digit,
        A.tel,
        A.name,
        A.parcelname,
        @Semantics.quantity.unitOfMeasure: 'dr_meins'            
        A.loadqty,
        A.dr_meins,    
        A.zdoc_no,
        A.zdoc_item_no,
        A.zdoc_date,
        A.erdat,
        A.erdat_local,
        A.ertim,
        A.ertim_local,
        A.ernam,
        A.aedat,
        A.aedat_local,
        A.aetim,
        A.aetim_local,
        A.aenam,
        @Semantics.quantity.unitOfMeasure: 'ERFME'    
        case when GR1.ERFMG is not null then GR1.ERFMG 
         else cast(0 as abap.quan(13,3)) end as ERFMG,
        case when GR1.ERFME is not null then GR1.ERFME 
         else cast('' as abap.unit(3)) end as ERFME,         
        case when GR1.BUDAT is not null then GR1.BUDAT
        else  cast('' as abap.dats) end as BUDAT,
        A.delno,
        A.delitem,
        A.gidate,
        case when SO.VALUE is not null then cast(ROUND(cast(SO.VALUE as abap.dec(13,5)),3) as abap.dec(13,3))
        else cast(0 as abap.dec(13,3)) end as LENGTH,
        A.printyn
                
} where B.loekz = ''

union all

select from zgtmmt4405 as A 
association [0..1] to ZGTMM_CV_GET_GODELIVERY_SUM  as GR1 on $projection.delno = GR1.delno and $projection.delitem = GR1.delitem 
association [0..1] to ZGTMM_CV_SO_VCVALUE as SO on $projection.vbeln = SO.vbeln and $projection.posnr = SO.posnr and SO.atnam = 'SAP_MILLCA_LENGTH'
{
  key   A.bukrs,
  key   A.zreq_type,
  key   A.dlvrq,
  key   A.vbeln,
  key   A.posnr,
  key   cast('' as ebeln) as EBELN,
  key   cast('' as ebelp ) as ebelp,
  key   A.zseq,
        A.ztrtype,
        A.regiont,
        A.no2digit,
        A.ch1digit,
        A.no4digit,
        A.tel,
        A.name,
        A.parcelname,          
        A.loadqty,
        A.dr_meins,    
        A.zdoc_no,
        A.zdoc_item_no,
        A.zdoc_date,
        A.erdat,
        A.erdat_local,
        A.ertim,
        A.ertim_local,
        A.ernam,
        A.aedat,
        A.aedat_local,
        A.aetim,
        A.aetim_local,
        A.aenam,
 
        case when GR1.ERFMG is not null then GR1.ERFMG 
         else cast(0 as abap.quan(13,3)) end as ERFMG,
        case when GR1.ERFME is not null then GR1.ERFME 
         else cast('' as abap.unit(3)) end as ERFME,  
        case when GR1.BUDAT is not null then GR1.BUDAT
        else  cast('' as abap.dats) end as BUDAT,
        A.delno,
        A.delitem,
        A.gidate,
        case when SO.VALUE is not null then cast(ROUND(cast(SO.VALUE as abap.dec(13,5)),3) as abap.dec(13,3))
        else cast(0 as abap.dec(13,3)) end as LENGTH,
        A.printyn
} 

