@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매오더 별 입고 현황'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_PO_DATA_GR  
as select from ZGTMM_CV_GET_PODATA_I as A 
          inner join ekko as C on A.ebeln = C.ebeln
          inner join lfa1 as D on C.lifnr = D.lifnr
          left outer join  ZGTMM_CV_GET_GRLIST_SUM as B on A.ebeln = B.ebeln and A.ebelp = B.ebelp 
association [1..1] to ZGTMM_CV_GET_IV_DATA_SUM as IV1 on $projection.ebeln = IV1.ebeln and $projection.ebelp = IV1.ebelp and IV1.vgabe ='2'
association [1..1] to ZGTMM_CV_GET_IV_DATA_SUM as IV2 on $projection.ebeln = IV2.ebeln and $projection.ebelp = IV2.ebelp and IV2.vgabe = '3'
association [0..1] to t024e as T024E on $projection.ekorg = T024E.ekorg
association [0..1] to t024 as T024 on $projection.ekgrp = T024.ekgrp
association [0..1] to t161t as T161T on $projection.bsart = T161T.bsart and T161T.spras = $session.system_language and T161T.bstyp = 'F'
association [0..1] to t052u as T052U on $projection.zterm = T052U.zterm and T052U.spras = $session.system_language    
association [0..1] to tinct as TINCT on $projection.inco1 = TINCT.inco1 and TINCT.spras = $session.system_language   
association [0..1] to ZGTMM_CV_PO_VCVALUE_MAIN as vc1 on $projection.ebeln = vc1.PDOC and $projection.ebelp = vc1.PDOCITEM  
association [0..1] to zgtmmt1020 as AR on $projection.werks = AR.werks and $projection.ekgrp = AR.ekgrp 
{
      key A.ebeln,
      key A.ebelp,
          C.bukrs,
          C.ekorg,
          t024e.ekotx,  
          C.ekgrp,
          t024.eknam,
          C.bsart,
          t161t.batxt,    
          C.aedat as AEDAT_H,
          C.ernam,   
          C.lifnr,
          D.name1,
          C.zterm,
          t052u.text1,
          C.zbd1t,
          C.zbd2t,
          C.zbd3t,
          C.frggr,
          C.frgzu,
          case when C.frggr <> '' then
                   case when C.frgzu = '' then cast('' as abap.char(1))
                        else cast('X' as abap.char(1)) end
               else
                   cast('X' as abap.char(1)) 
               end as REL_STAT,
          C.ihrez,
          case C.ihrez  when 'C' then cast('업체 접수' as abap.char(8))
                        when 'R' then cast('업체 반려' as abap.char(8))
          end as IHREZ_N,      
          C.waers as PO_WAERS,
          C.wkurs,
          C.bedat,
          C.inco1,
          tinct.bezei as INCO_N,
          C.lands,
          A.loekz,
          A.statu,
          A.werks,
          A.name1 as WERKS_N,
          A.lgort,
          A.lgobe,
          A.matnr,
          A.txz01,
          case when vc1.LENGTH is not null then vc1.LENGTH 
               else cast('' as abap.char(70)) end as LENGTH,
          case when vc1.DRQTY is not null then vc1.DRQTY
               else cast('' as abap.char(70)) end as DRQTY,   
          case when vc1.COLOR is not null then vc1.COLOR 
               else cast('' as abap.char(70)) end as COLOR,  
          case when vc1.DRUM is not null then vc1.DRUM 
               else cast('' as abap.char(70)) end as DRUM,
          A.MAPKEY,
          @Semantics.quantity.unitOfMeasure: 'meins'  
          A.menge,
          @Semantics.quantity.unitOfMeasure: 'dr_meins'       
          case when vc1.LENGTH is not null then cast(A.menge / cast(vc1.LENGTH as abap.dec(13,3)) as abap.dec(13,3))
               else cast(0 as abap.dec(13,3)) end as po_drqty,             
          cast('DR' as abap.unit(3)) as dr_meins,
          @Semantics.quantity.unitOfMeasure: 'meins' 
          A.MENGE_O,
          A.meins,
          A.umrez,
          A.umren,
          A.lmein,
          A.eindt,
          A.bednr,
          A.matkl,
          A.wgbez60,
          A.infnr,
          A.idnlf,
          @Semantics.amount.currencyCode: 'waers'          
          A.netpr,
          A.peinh,
          A.bprme,
          A.bpumz,
          A.bpumn,
          A.waers,
          @Semantics.amount.currencyCode: 'waers'    
          A.netwr,
          @Semantics.amount.currencyCode: 'waers'    
          A.brtwr,
          @Semantics.quantity.unitOfMeasure: 'gewei'           
          A.ntgew,
          @Semantics.quantity.unitOfMeasure: 'gewei'    
          A.brgew,  
          A.gewei,
          @Semantics.quantity.unitOfMeasure: 'voleh'    
          A.volum,
          A.voleh,
          A.banfn,
          A.bnfpo,
          A.mtart,
          A.mtbez,
          A.mfrpn,
          A.mfrnr,
          A.mwskz,
          A.retpo,
          A.uebto,
          A.uebtk,
          A.untto,
          A.bwtar,
          A.bwtty,
          A.elikz,
          A.erekz,
          A.PSTYP,
          A.ptext,
          A.knttp,
          A.knttx,
          A.wepos,
          A.weunb,
          A.repos,
          A.webre,
          A.xersy,
          A.eildt,
          A.mhdrz,
          A.eglkz,
          A.kztlf,
          A.kzabs,
          A.labnr,
          A.abskz,
          A.prdat,
          A.bstyp,
          A.webaz,
          A.plifz,
          A.VBELN,
          A.posnr,
          A.VKORG,
          A.VTWEG,
          A.vkbur,
          A.VKBUR_N,
          A.vkgrp,
          A.VKGRP_N,
          A.kunnr,
          A.NAME_K,
          A.emlif,
          A.NAME_V,
          A.lblkz,
          A.adrnr,
          A.DNAME1,
          A.DNAME2,               
          A.STREET,  
          A.HOUSE_NUM1,  
          A.POST_CODE1,       
          A.CITY1,        
          A.REGION,
          A.BEZEI,
          A.COUNTRY,       
          A.bstae,
          A.meprf,
          A.uebpo,
          A.chg_srv,
          A.berid,
          A.afnam,
          A.NES,
          @Semantics.quantity.unitOfMeasure: 'BME'             
          A.VGW,
          A.BME,
          A.VGE,
          A.MEINS_B,
          @Semantics.quantity.unitOfMeasure: 'BME'           
          A.VGW_T,
          A.MEMI_I,
          A.creationdate,
          A.creationtime,
          A.aedat,
          A.AETIM,
          case when A.loekz <> '' then cast('A' as abap.char(20))
               else
                 case when A.elikz = '' then cast('B' as abap.char(20))
                      else
                           case when B.ebeln is null then cast('C' as abap.char(20))
                               else
                                 case when A.menge > B.MENGE then cast('D' as abap.char(20))
                                      else cast('E' as abap.char(20))  end                     
                      
                           end
                      end
               end as zgrstatus_C,          
          
          case when A.loekz <> '' then cast('PO 취소' as abap.char(20))
               else
                 case when A.elikz = 'X' then cast('납품 완료' as abap.char(20))
                      else
                           case when B.ebeln is null then cast('미입고' as abap.char(20))
                               else
                                 case when A.menge > B.MENGE then cast('부분입고' as abap.char(20))
                                      else cast('전량 입고' as abap.char(20))  end                     
                      
                           end
                      end
               end as zgrstatus,
               

          @Semantics.quantity.unitOfMeasure: 'GR_MEINS'
          case when B.ebeln is not null then B.MENGE 
               else cast(0 as bstmg) end as GR_MENGE,
          case when B.GR_MEINS is not null then B.GR_MEINS
               else cast('' as meins) end as GR_MEINS,
     
          @Semantics.quantity.unitOfMeasure: 'dr_meins'                   
          case when B.ebeln is not null then      
               case when vc1.LENGTH is not null then cast(B.MENGE / cast(vc1.LENGTH as abap.dec(13,3)) as abap.dec(13,3))
               else cast(0 as abap.dec(13,3)) end
               else cast(0 as abap.dec(13,3)) end as gr_drqty,            
               
          @Semantics.amount.currencyCode: 'konwa'      
          case when B.kbetr is not null then B.kbetr
               else cast(0 as kbetr_kond) end as KBETR, //INFO 단가
          case when B.konwa is not null then B.konwa
               else cast('' as konwa) end as KONWA,   
          case when B.kpein is not null then B.kpein
               else cast(1 as kpein) end as kpein ,
          case when B.kmein is not null then B.kmein
               else cast('' as abap.unit( 3 )) end as kmein,     
          @Semantics.amount.currencyCode: 'INFOWAERS'
          B.PRICESUM,          
          case when B.waers is not null then B.waers
               else cast('' as abap.cuky( 5 )) end as INFOWAERS,
          B.PRICE_TYPE ,
          
          @Semantics.quantity.unitOfMeasure: 'IV1_BPRME'          
          case when IV1.ebeln is not null then IV1.IV_QTY
               else cast(0 as menge_d) end as IV1_QTY,
          case when IV1.ebeln is not null then IV1.bprme
               else cast('' as abap.unit( 3 )) end as IV1_BPRME,
               
          @Semantics.quantity.unitOfMeasure: 'dr_meins'                   
          case when IV1.ebeln is not null then      
               case when vc1.LENGTH is not null then cast(IV1.IV_QTY / cast(vc1.LENGTH as abap.dec(13,3)) as abap.dec(13,3))
               else cast(0 as abap.dec(13,3)) end
               else cast(0 as abap.dec(13,3)) end as IV_drqty,                  
               
          @Semantics.amount.currencyCode: 'IV1_WAERS'               
          case when IV1.ebeln is not null then IV1.IV_AMOUNT
               else cast(0 as abap.curr( 15, 2)) end as IV1_AMOUNTY,
          case when IV1.ebeln is not null then IV1.waers
               else cast('' as abap.cuky( 5 )) end as IV1_WAERS,    

          @Semantics.amount.currencyCode: 'IV1_LC_WAERS'               
          case when IV1.ebeln is not null then IV1.IV_AMOUNT_KRW
               else cast(0 as abap.curr( 15, 2)) end as IV1_AMOUNT_KRW,
          case when IV1.ebeln is not null then IV1.LC_WAERS
               else cast('' as abap.cuky( 5 )) end as IV1_LC_WAERS,
               
          @Semantics.quantity.unitOfMeasure: 'IV1_BPRME'          
          case when IV2.ebeln is not null then IV2.IV_QTY
               else cast(0 as menge_d) end as IV2_QTY,
          case when IV2.ebeln is not null then IV2.bprme
               else cast('' as abap.unit( 3 )) end as IV2_BPRME,
          @Semantics.amount.currencyCode: 'IV1_WAERS'               
          case when IV2.ebeln is not null then IV2.IV_AMOUNT
               else cast(0 as abap.curr( 15, 2)) end as IV2_AMOUNTY,
          case when IV2.ebeln is not null then IV2.waers
               else cast('' as abap.cuky( 5 )) end as IV2_WAERS,    

          @Semantics.amount.currencyCode: 'IV1_LC_WAERS'               
          case when IV2.ebeln is not null then IV2.IV_AMOUNT_KRW
               else cast(0 as abap.curr( 15, 2)) end as IV2_AMOUNT_KRW,
          case when IV2.ebeln is not null then IV2.LC_WAERS
               else cast('' as abap.cuky( 5 )) end as IV2_LC_WAERS,
          case when AR.aname is not null then AR.aname else cast('' as abap.char(12)) end as ANAME    
                        
} where C.ekgrp <> 'T60' and C.ekgrp <>'T61'
