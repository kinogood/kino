@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SRM 전송 PO 품목 정보 조회(공통)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_PODATA_I 
as select from ZGTMM_CV_GET_PODATA_RAW as a
association [0..1] to tvkbt as TVKBT on $projection.vkbur = TVKBT.vkbur and TVKBT.spras = $session.system_language
association [0..1] to tvgrt as TVGRT on $projection.vkgrp = TVGRT.vkgrp and TVGRT.spras = $session.system_language
association [0..1] to t005u as T005U on $projection.COUNTRY = T005U.land1 and $projection.REGION = T005U.bland and T005U.spras = $session.system_language
//association [0..1] to ZGTMM_CV_GET_NFWEIGHT_SORG as SNF on $projection.matnr = SNF.matnr and $projection.VKORG = SNF.org and $projection.VTWEG = SNF.vtweg   
association [0..1] to ZGTMM_CV_GET_NFWEIGHT_PLANT as PNF on $projection.matnr = PNF.matnr and (PNF.nes = 'CU' or PNF.nes = 'FI')  and $projection.werks = PNF.werks
association [0..1] to kna1 as KNA1 on $projection.KUNNR = KNA1.kunnr 
association [0..1] to ZGTMM_CV_GET_MAT_CLASS as cl on $projection.matnr = cl.matnr


{
     key  a.ebeln,
          a.ebelp,
          a.loekz,
          a.statu,
          a.werks,
          a.name1,
          a.lgort,
          a.lgobe,
          a.matnr,
          a.txz01,
          a.MAPKEY,
          @Semantics.quantity.unitOfMeasure: 'meins'  
          a.menge,          
          @Semantics.quantity.unitOfMeasure: 'meins' 
          a.MENGE_O,
          a.meins,
          a.umrez,
          a.umren,
          a.lmein,
          a.eindt,
          a.bednr,
          a.matkl,
          a.wgbez60,
          a.infnr,
          a.idnlf,
          @Semantics.amount.currencyCode: 'waers'          
          a.netpr,
          a.peinh,
          a.bprme,
          a.bpumz,
          a.bpumn,
          a.waers,
          @Semantics.amount.currencyCode: 'waers'    
          a.netwr,
          @Semantics.amount.currencyCode: 'waers'    
          a.brtwr,
          @Semantics.quantity.unitOfMeasure: 'gewei'        
          case when a.meins ='KG' or a.meins = 'G' or a.meins = 'TON' then cast(a.menge as abap.quan(13,3))
               else cast(cast(a.menge as abap.dec(13,3)) * a.ntgew as abap.quan(13,3)) end as NTGEW,
          @Semantics.quantity.unitOfMeasure: 'gewei'
          case when a.meins ='KG' or a.meins = 'G' or a.meins = 'TON' then cast(a.menge as abap.quan(13,3))
               else  cast(cast(a.menge as abap.dec(13,3)) * a.brgew as abap.quan(13,3)) end as brgew,  
          a.gewei,
          @Semantics.quantity.unitOfMeasure: 'voleh'    
          a.volum,
          a.voleh,
          a.banfn,
          a.bnfpo,
          a.mtart,
          a.mtbez,
          a.mfrpn,
          a.mfrnr,
          a.mwskz,
          a.retpo,
          a.uebto,
          a.uebtk,
          a.untto,
          a.bwtar,
          a.bwtty,
          a.elikz,
          a.erekz,
          case a.pstyp when '0' then cast('' as abap.char(1))
                       when '1' then cast('B' as abap.char(1))
                       when '2' then cast('K' as abap.char(1))
                       when '3' then cast('L' as abap.char(1))
                       when '4' then cast('M' as abap.char(1))
                       when '5' then cast('S' as abap.char(1))
                       when '6' then cast('T' as abap.char(1))
                       when '7' then cast('U' as abap.char(1))
                       when '8' then cast('W' as abap.char(1))
                       when '9' then cast('D' as abap.char(1))
                       when 'A' then cast('E' as abap.char(1))
                       when 'C' then cast('C' as abap.char(1))
                       when 'P' then cast('P' as abap.char(1))
          end as PSTYP,                       
          a.ptext,
          a.knttp,
          a.knttx,
          a.wepos,
          a.weunb,
          a.repos,
          a.webre,
          a.xersy,
          case when a.eildt = '00000000' then $session.system_date else a.eildt end as eildt,
          a.mhdrz,
          a.eglkz,
          a.kztlf,
          a.kzabs,
          a.labnr,
          a.abskz,
          a.prdat,
          a.bstyp,
          a.webaz,
          a.plifz,
          a.VBELN,
          a.posnr,
          a.VKORG,
          a.VTWEG,
          a.vkbur,
          tvkbt.bezei as VKBUR_N,
          a.vkgrp,
          tvgrt.bezei as VKGRP_N,
          a.KUNNR,
          kna1.name1 as NAME_K,
          a.emlif,
          a.NAME_V,
          a.lblkz,
          a.adrnr,
          a.DNAME1,
          a.DNAME2,               
          a.STREET,  
          a.HOUSE_NUM1,  
          a.POST_CODE1,       
          a.CITY1,        
          a.REGION,
          t005u.bezei as BEZEI,
          a.COUNTRY,             



          a.bstae,
          a.meprf,
          a.uebpo,
          a.chg_srv,
          a.berid,
          a.afnam,
          case when PNF.nes is not null then PNF.nes else cast('' as /nfm/nes ) end as NES,
          @Semantics.quantity.unitOfMeasure: 'BME'             
          case when PNF.Vgw is not null then PNF.Vgw else cast(0 as /nfm/vgw) end as VGW,
          case when PNF.bme is not null then PNF.bme else cast('' as unit) end as BME,
          case when PNF.vge is not null then PNF.vge else cast(1 as /nfm/vge) end as VGE,
          case when PNF.meins is not null then PNF.meins else cast('' as unit) end as MEINS_B,
          @Semantics.quantity.unitOfMeasure: 'BME'           
          case when PNF.Vgw is not null then 
               cast(( a.menge * PNF.Vgw ) / PNF.vge as /nfm/vgw )
               else cast(0 as /nfm/vgw) end as VGW_T,
          @Semantics.quantity.unitOfMeasure: 'BME'                 
          case when PNF.Vgw is not null then 
               cast(( a.MENGE_O * PNF.Vgw ) / PNF.vge as /nfm/vgw )
               else cast(0 as /nfm/vgw) end as VGW_T_O,               
          cast('' as abap.char(200)) as MEMI_I,
          
          a.creationdate,
          a.creationtime,
          a.aedat,
          a.AETIM,
          case when cl.class is not null then cl.class else cast('' as klasse_d) end as zclass
    
}
