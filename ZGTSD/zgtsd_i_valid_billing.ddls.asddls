@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 취소되지 않은 유효 Billing'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_VALID_BILLING
  as select from vbrp as _BlItem
    inner join   vbrk as _BlHdr on _BlItem.vbeln = _BlHdr.vbeln
{
  key    cast(_BlItem.vbeln as vbeln_vf preserving type ) as vbeln_bl,
  key    cast(_BlItem.posnr as posnr_vf preserving type)  as posnr_bl,

  key    cast(_BlItem.vgbel as vbeln_vl preserving type)  as vbeln_do,
  key    cast(_BlItem.vgpos as posnr_vl preserving type)  as posnr_do,
         cast(_BlItem.aubel as vbeln_va preserving type)  as vbeln_so,
         cast(_BlItem.aupos as posnr_va preserving type ) as posnr_so,
         

         _BlHdr.vkorg,
         _BlHdr.vtweg,
         _BlHdr.spart,
         _BlItem.vkbur,
         _BlItem.vkgrp,

         _BlHdr.fkart,
         _BlHdr.fkdat,
         cast(_BlHdr.inco1 as inco1 preserving type ) as inco1,
         _BlItem.werks,
         _BlItem.vstel,
         _BlItem.lgort,
         
         @Semantics.amount.currencyCode: 'waerk'
         _BlItem.netwr,
         @Semantics.amount.currencyCode: 'waerk' 
         _BlItem.mwsbp,
         _BlItem.waerk,
         _BlItem.prsdt,
         _BlItem.kursk,
         
         cast(_BlHdr.zzbilnr as zebilnr preserving type ) as zzbilnr,
         _BlItem.vf_status_ana,
         _BlItem.zzwadat_ist,


         _BlItem.matnr,
         _BlItem.arktx,
         @Semantics.quantity.unitOfMeasure: 'vrkme'
         _BlItem.fkimg,
         _BlItem.vrkme,
         _BlItem.umvkz,
         _BlItem.umvkn
}
where
      _BlHdr.vbtyp <> 'N'
  and _BlHdr.vbtyp <> 'S'
  and _BlHdr.sfakn is initial
  and _BlHdr.fksto is initial
