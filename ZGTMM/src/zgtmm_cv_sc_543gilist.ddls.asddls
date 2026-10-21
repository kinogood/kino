@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 가공 납품 투입 정보'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SC_543GILIST 
as 
select from ZGTMM_CV_SC_DELIVERY as a inner join ZGTMM_CV_SC_RESBLIST as B on a.ebeln = B.ebeln and a.ebelp = B.ebelp
      
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
    B.menge as poqty,
    B.meins as PO_meins,    
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    a.LFIMG as DVQTY,
    a.meins,
    B.IDNRK,
    ltrim(B.IDNRK,'0') as ckmatnr,
    @Semantics.quantity.unitOfMeasure: 'CMEINS' 
    B.BDMNG as REQTY,
    B.CMEINS,
    B.xchpf,    

    @Semantics.quantity.unitOfMeasure: 'CMEINS' 
    cast(cast(a.LFIMG as abap.dec(13,3)) * cast(B.BDMNG as abap.dec(13,3)) / B.menge as bdmng) as EREQTY    
    
}

