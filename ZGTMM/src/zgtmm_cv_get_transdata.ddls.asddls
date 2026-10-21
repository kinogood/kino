@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직송 의뢰 배차 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_TRANSDATA 
as select from ZGTMM_CV_GET_TRANSRAW 
{
  key   bukrs,
  key   zreq_type,
  key   dlvrq,
  key   vbeln,
  key   posnr,
  key   ebeln,
  key   ebelp,
  key   zseq,
        ztrtype,
        regiont,
        no2digit,
        ch1digit,
        no4digit,
        tel,
        name,
        parcelname,
        @Semantics.quantity.unitOfMeasure: 'dr_meins'            
        loadqty,
        dr_meins,    
        zdoc_no,
        zdoc_item_no,
        case when zdoc_date = '00000000' then cast('00000000' as abap.dats(8)) else zdoc_date end as zdoc_date,
        
        erdat,
        erdat_local,
        ertim,
        ertim_local,
        ernam,
        aedat,
        aedat_local,
        aetim,
        aetim_local,
        aenam,
        @Semantics.quantity.unitOfMeasure: 'dr_meins'    
        case when LENGTH > 0 then cast(ERFMG / cast(LENGTH as abap.dec(13,3)) as abap.quan(13,3))
                  else ERFMG 
             end as GR_DRQTY,
        case when BUDAT = '00000000' then cast('00000000' as abap.dats(8)) else BUDAT end as BUDAT,             

        delno,
        delitem,
        case when gidate = '00000000' then cast('00000000' as abap.dats(8)) else gidate end as gidate,             

        LENGTH,
        printyn  
}

