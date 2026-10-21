@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 구매 오더 기초 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_OEM_PO_DATA_BASE 
as select from ekko as A inner join ekpo as B on A.ebeln = B.ebeln
                         inner join ekkn as C on B.ebeln = C.ebeln and B.ebelp = C.ebelp
                         inner join vbap as D on C.vbeln = D.vbeln and C.vbelp = D.posnr
                         inner join vbak as E on D.vbeln = E.vbeln
                         inner join mara as F on B.matnr = F.matnr
                         inner join lfa1 as G on A.lifnr = G.lifnr
                         inner join kna1 as H on E.kunnr = H.kunnr
                         inner join eket as I on B.ebeln = I.ebeln and B.ebelp = I.ebelp
                         inner join zgtppt1010 as J on B.werks = J.fld_01 and F.mtart = J.fld_02 
                         left outer join zgtmmt4402 as k on A.bukrs = k.bukrs and A.ebeln = k.ebeln and B.ebelp = k.ebelp
association [0..1] to ZGTMM_CV_GET_GRLIST_SUM  as GR on $projection.ebeln = GR.ebeln and $projection.ebelp = GR.ebelp
association [0..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language
association [0..1] to ZGTMM_CV_SO_VCVALUE_MAIN as VC1 on $projection.vbeln = VC1.vbeln and  $projection.posnr = VC1.posnr
association [0..1] to tvkbt as TVKBT on $projection.vkbur = TVKBT.vkbur and TVKBT.spras = $session.system_language
association [0..1] to tvgrt as TVGRT on $projection.vkgrp = TVGRT.vkgrp and TVGRT.spras = $session.system_language

{
  key B.ebeln,
  key B.ebelp,
      B.werks,
      B.loekz,
      A.aedat,
      I.eindt,
      A.bukrs,
      A.lifnr,
      G.name1 as LIFNR_N,
      D.vbeln,
      D.posnr,
      E.kunnr,
      H.name1 as KUNNR_N,
      E.vkbur,
      tvkbt.bezei as vkbur_n,
      E.vkgrp,
      tvgrt.bezei as vkgrp_n,
      B.matnr,
      case when F.zzmaktx80 <> '' then F.zzmaktx80 else makt.maktx end as MAKTX,
      @Semantics.quantity.unitOfMeasure: 'MEINS'
      B.menge,
      B.meins,
      VC1.LENGTH,
      VC1.DRQTY,   
      VC1.COLOR,  
      VC1.DRUM,
      VC1.INSPECTION,           
      cast('DR' as bstme) as DR_MEINS,
      @Semantics.quantity.unitOfMeasure: 'GR_MEINS_M'
      case when GR.MENGE is not null then GR.MENGE else cast(0 as erfmg) end as GR_QTY_M,
      case when GR.GR_MEINS is not null then GR.GR_MEINS else cast('' as bstme) end as GR_MEINS_M,

      @Semantics.quantity.unitOfMeasure: 'DR_MEINS'
      case when GR.MENGE is null then cast(0 as abap.quan(13,3))
           else
               case when VC1.LENGTH is not null then  cast(cast(GR.MENGE as abap.dec(13,3)) / cast(VC1.LENGTH as abap.dec(13,3)) as abap.quan(13,3))
                    else cast(cast(GR.MENGE as abap.dec(13,3)) as abap.quan(13,3)) end
           end as GR_QTY_DR,
      B.elikz,
      F.mtart,
      case when k.zinsp_no is not null then k.zinsp_no else cast('' as abap.char(20)) end as ZINSP_NO,
      @Semantics.quantity.unitOfMeasure: 'QCMEINS'       
      k.zinsp_qty,
      k.meins as QCMEINS,
      k.zinsp_date,
      k.zinsptype,
      k.zinspdate,
      k.zinspres,
      k.zinsp_certi,
      k.zinsp_perno,
      k.zinsp_name,
      k.erdat as QCREQDATE,
      k.aedat_local as QCREQDATELOCAL      

} where C.zekkn = '01'  and I.etenr = '0001'  and B.knttp = 'M' and J.module_kind = 'MM' and J.codegrp = '0610'

union all

select from ekko as A inner join ekpo as B on A.ebeln = B.ebeln
                         inner join mara as F on B.matnr = F.matnr
                         inner join lfa1 as G on A.lifnr = G.lifnr
                         inner join eket as I on B.ebeln = I.ebeln and B.ebelp = I.ebelp
                         inner join zgtppt1010 as J on B.werks = J.fld_01 and F.mtart = J.fld_02                          
                         left outer join zgtmmt4402 as k on A.bukrs = k.bukrs and A.ebeln = k.ebeln and B.ebelp = k.ebelp
association [0..1] to ZGTMM_CV_GET_GRLIST_SUM  as GR on $projection.ebeln = GR.ebeln and $projection.ebelp = GR.ebelp
association [0..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language
association [0..1] to ZGTMM_CV_PO_VCVALUE_MAIN as VC1 on $projection.ebeln = VC1.PDOC and  $projection.ebelp = VC1.PDOCITEM 

{
  key B.ebeln,
  key B.ebelp,
      B.werks,
      B.loekz,
      A.aedat,
      I.eindt,
      A.bukrs,
      A.lifnr,
      G.name1 as LIFNR_N,
      cast('' as vbeln_co ) as vbeln,
      cast('' as posnr_co) as posnr,
      cast('' as kunag) as kunnr,
      cast('' as name1_gp) as KUNNR_N,
      cast('' as vkbur) as vkbur,
      cast('' as bezei20) as vkbur_n,
      cast('' as vkgrp) as vkgrp,
      cast('' as bezei20) as vkgrp_n,
      B.matnr,
      case when F.zzmaktx80 <> '' then F.zzmaktx80 else makt.maktx end as MAKTX,
      B.menge,
      B.meins,     
      VC1.LENGTH,
      VC1.DRQTY,   
      VC1.COLOR,  
      VC1.DRUM,
      cast('' as abap.char(70)) as INSPECTION,
      cast('DR' as bstme) as DR_MEINS,
      case when GR.MENGE is not null then GR.MENGE else cast(0 as erfmg) end as GR_QTY_M,
      case when GR.GR_MEINS is not null then GR.GR_MEINS else cast('' as bstme) end as GR_MEINS_M,

      case when GR.MENGE is null then cast(0 as abap.quan(13,3))
           else
               case when VC1.LENGTH is not null then  cast(cast(GR.MENGE as abap.dec(13,3)) / cast(VC1.LENGTH as abap.dec(13,3)) as abap.quan(13,3))
                    else cast(cast(GR.MENGE as abap.dec(13,3)) as abap.quan(13,3)) end
           end as GR_QTY_DR,
      B.elikz,
      F.mtart,
      k.zinsp_no,
      k.zinsp_qty,
      k.meins as QCMEINS,
      k.zinsp_date,
      k.zinsptype,
      k.zinspdate,
      k.zinspres,
      k.zinsp_certi,
      k.zinsp_perno,
      k.zinsp_name,
      k.erdat as QCREQDATE,
      k.aedat_local as QCREQDATELOCAL       

} where B.knttp = '' and  I.etenr = '0001' and B.knttp <> 'M' and J.module_kind = 'MM' and J.codegrp = '0610' 
