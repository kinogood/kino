@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 Item 및 납품 비철 수량 (Base)'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_SO_ITEM_NF_QTY_BASE
  as select from           vbap           as a
//    left outer to one join /nfm/torderpos as cu on  a.vbeln = cu.belnr
//                                                and a.posnr = cu.posnr
//                                                and cu.nes  = 'CU'
//    left outer to one join /nfm/torderpos as al on  a.vbeln = al.belnr
//                                                and a.posnr = al.posnr
//                                                and al.nes  = 'AL'
//    left outer to one join /nfm/torderpos as fi on  a.vbeln = fi.belnr
//                                                and a.posnr = fi.posnr
//                                                and fi.nes  = 'FI'
    left outer join        lips           as c  on  a.vbeln = c.vgbel
                                                and a.posnr = c.vgpos
                                                and c.lfimg > 0

    left outer to one join /nfm/tkgw as cu on a.matnr = cu.matnr
                                            and a.werks = cu.werks
                                            and cu.nes = 'CU'

    left outer to one join /nfm/tkgw as al on a.matnr = al.matnr
                                            and a.werks = al.werks
                                            and al.nes = 'AL'

    left outer to one join /nfm/tkgw as fi on a.matnr = fi.matnr
                                            and a.werks = fi.werks
                                            and fi.nes = 'FI'
    inner join mara as m on a.matnr = m.matnr

{
  key a.vbeln,
  key cast(a.posnr as posnr_va preserving type ) as posnr,
  key cast(c.vbeln as vbeln_vl preserving type ) as do_vbeln,

      -- CASE 문을 여기서 사전 연산하여 do_posnr 필드로 고정 확정
  key cast( case when c.uecha is null or c.uecha = '000000'
                 then c.posnr
                 else c.uecha end
            as posnr_vl preserving type )        as do_posnr, 

      a.auart_ana                                as auart,
      a.vkorg_ana                                as vkorg,
      a.vtweg_ana                                as vtweg,
      a.spart_ana                                as spart,
      a.spart                                    as item_spart,
      a.vkbur_ana                                as vkbur,
      a.vkgrp_ana                                as vkgrp,
      a.werks,
      a.matnr,
      m.meins,
      a.umvkz,
      a.umvkn,

      @Semantics.quantity.unitOfMeasure: 'vrkme'
      a.kwmeng,
      a.vrkme,
      @Semantics.quantity.unitOfMeasure: 'do_unit'
      c.lfimg,
      c.vrkme                                    as do_unit,
      c.umvkz                                    as do_umvkz,
      c.umvkn                                    as do_umvkn,

//      cu.nes                                     as nes_cu,
//      cu.vge                                     as vge_cu,
//      @Semantics.quantity.unitOfMeasure: 'bme_cu'
//      cu.vgw                                     as vgw_cu,
//      cu.bme                                     as bme_cu,
//      
//      al.nes                                     as nes_al,
//      al.vge                                     as vge_al,
//      @Semantics.quantity.unitOfMeasure: 'bme_fi'
//      al.vgw                                     as vgw_al,
//      al.bme                                     as bme_al,
//
//      fi.nes                                     as nes_fi,
//      fi.vge                                     as vge_fi,
//      @Semantics.quantity.unitOfMeasure: 'bme_fi'
//      fi.vgw                                     as vgw_fi,
//      fi.bme                                     as bme_fi,

      cu.nes as nes_cu,
      @Semantics.quantity.unitOfMeasure: 'bme_cu'
      cu.kgw as vgw_cu,
      @Semantics.quantity.unitOfMeasure: 'meins'      
      cu.kgu as vge_cu,
      cu.bme as bme_cu,

      al.nes as nes_al,
      @Semantics.quantity.unitOfMeasure: 'bme_al'
      al.kgw as vgw_al,
      @Semantics.quantity.unitOfMeasure: 'meins'      
      al.kgu as vge_al,
      al.bme as bme_al,

      fi.nes as nes_fi,
      @Semantics.quantity.unitOfMeasure: 'bme_al'
      fi.kgw as vgw_fi,
      @Semantics.quantity.unitOfMeasure: 'meins'      
      fi.kgu as vge_fi,
      fi.bme as bme_fi

}
where
  a.abgru is initial
