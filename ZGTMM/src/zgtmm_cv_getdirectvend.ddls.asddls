@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직납 Vendor 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETDIRECTVEND 
as 
select from zgtmmt4000

association [0..1] to t001 as Company on $projection.bukrs = Company.bukrs  
association [0..1] to t001w as Plant on $projection.werks = Plant.werks  
association [0..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language   
association [0..1] to lfa1 as vendor on $projection.lifnr = vendor.lifnr    
association [0..1] to lfa1 as direct on $projection.emlif = direct.lifnr   
association [1..1] to ZGTMM_CV_GETDVCOUNT as cnt  on $projection.bukrs = cnt.bukrs and $projection.werks = cnt.werks 
                                                  and $projection.matnr = cnt.matnr and $projection.lifnr = cnt.lifnr


{
 key  bukrs,
 key  werks,
 key  matnr,
 key  lifnr,
 key  zseq,
      Company.butxt,
      Plant.name1 as plantname,
      makt.maktx,
      vendor.name1 as vendorname,
      emlif,
      direct.name1 as directname,
      lblkz,
      cnt.CNT,
      erdat,
      erdat_local,
      ertim, 
      ertim_local,
      ernam,
      aedat,
      aedat_local,
      aetim,
      aetim_local,
      aenam
}
