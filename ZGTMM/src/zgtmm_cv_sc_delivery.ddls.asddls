@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 가공 납품 정보'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SC_DELIVERY 
as select from zmmti34 as a inner join ekpo as b on a.ebeln = b.ebeln and a.ebelp = b.ebelp 
{
    key a.vbeln,
    key a.posnr,
    key a.tagnr,
    a.werks,
    a.matnr,
    a.ekgrp,
    a.ebeln,
    a.ebelp,
    a.lifnr,
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    sum(a.lfimg) as LFIMG,
    a.meins,
    a.lfdat,
    a.hsdat,
    cast('ZMMTI34' as abap.char(6)) as INBTYPE
} where b.bstae <> '0004'
group by a.vbeln, a.posnr, a.werks, a.matnr, a.ekgrp, a.ebeln, a.ebelp, a.lifnr, a.meins, a.lfdat, a.hsdat, a.tagnr


union all

select from lips as a inner join ekes as b on a.vbeln = b.vbeln and a.posnr = b.vbelp
                      inner join ekpo as c on b.ebeln = c.ebeln and b.ebelp = c.ebelp
                      inner join ekko as d on c.ebeln = d.ebeln
                      inner join likp as e on a.vbeln = e.vbeln
{
   key a.vbeln,
   key a.posnr,
   key cast('' as ztagnr) as tagnr,
   a.werks,
   a.matnr,
   d.ekgrp,
   c.ebeln,
   c.ebelp,
   d.lifnr,
   sum(a.lfimg) as LFIMG,
   a.meins,
   e.lfdat,
   a.hsdat,
    cast('LIKP' as abap.char(6)) as INBTYPE
} where c.pstyp = '3' and c.bstae = '0004' and b.menge > 0 and a.lfimg > 0
group by a.vbeln, a.posnr, a.werks, a.matnr, d.ekgrp, c.ebeln, c.ebelp, d.lifnr, a.meins, e.lfdat, a.hsdat 



