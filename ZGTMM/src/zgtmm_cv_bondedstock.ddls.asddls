@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '보세 창고 재고 현황'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_BONDEDSTOCK 
as 
select from ztitblk as a inner join ztitblp as b on a.iblno = b.iblno
       inner join mara as D on b.matnr = D.matnr
       left outer join ztitgrp as c on b.iblno = c.iblno and b.iblit = c.iblit
       left outer join ZGTMM_CV_UNIT_FACTOR as UNIT on b.meins = UNIT.UNIT        
{

    key a.iblno,
    key a.werks,
    key b.matnr,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    case when b.meins = D.meins then b.blmng
         else
             cast(b.blmng * UNIT.zaehl / UNIT.nennr as abap.quan(13,3))
         end as BLMNG,
    case when b.meins = D.meins then b.meins
         else UNIT.SIUNIT
         end as MEINS,
    a.bleta,
    case when c.igrno is null then cast('' as ztiigrno)
         else c.igrno end  as igrno, 
    a.rptty
     
} where  b.matnr <> '' 

 
/*
select from ztitblk as a inner join ztitblp as b on a.iblno = b.iblno
       inner join mara as D on b.matnr = D.matnr
       left outer join ztitgrp as c on b.iblno = c.iblno and b.iblit = c.iblit
       left outer join ZGTMM_CV_UNIT_FACTOR as UNIT on b.meins = UNIT.UNIT        
{

    key a.iblno,
    key a.werks,
    key b.matnr,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    case when b.meins = D.meins then b.blmng
         else
             cast(b.blmng * UNIT.zaehl / UNIT.nennr as abap.quan(13,3))
         end as BLMNG,
    case when b.meins = D.meins then b.meins
         else UNIT.SIUNIT
         end as MEINS,
    a.bleta,
    case when c.igrno is null then cast('' as ztiigrno)
         else c.igrno end  as igrno
     
} where  a.bleta <= $session.user_date and a.rptty = 'B' and b.matnr <> '' */
