@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '(외주 가공 납품 투입 정보 점검'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SC_543GICHECK 
as 
select from ZGTMM_CV_SC_543GILIST as a 
      left outer join zmmti35 as B on a.vbeln = B.vbeln and a.posnr = B.posnr and a.tagnr = B.tagnr and  a.ckmatnr = B.idnrk  
{
    key a.vbeln,
    key a.posnr,
    key a.tagnr,    
    a.werks,
    a.matnr,
    a.lfdat,
    a.hsdat,    
    a.ekgrp,
    a.ebeln,
    a.ebelp,
    a.lifnr,
    @Semantics.quantity.unitOfMeasure: 'PO_MEINS' 
    a.poqty,
    a.PO_meins,    
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    a.DVQTY,
    a.meins,
    a.IDNRK,
    @Semantics.quantity.unitOfMeasure: 'CMEINS' 
    a.REQTY,
    a.CMEINS,
    a.xchpf,    
    @Semantics.quantity.unitOfMeasure: 'CMEINS' 
    a.EREQTY,
    B.charg,
    @Semantics.quantity.unitOfMeasure: 'GIMEINS' 
    case when B.lfimg is not null then B.lfimg
         else 
            case when a.xchpf = 'X' then cast(0 as lfimg)
                 else a.EREQTY end 
         end as GIQTY,
    case when B.meins is not null then B.meins
         else a.CMEINS end as GIMEINS,
    case when a.xchpf = 'X'
     then 
            case when B.idnrk is null then cast('N' as abap.char(1))
                 else cast('Y' as abap.char(1))
            end
     else cast('Y' as abap.char(1)) end as GICHECK    
}
