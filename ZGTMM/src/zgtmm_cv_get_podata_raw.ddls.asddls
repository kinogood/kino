@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SRM 전송 PO 품목 정보 조회(RAW)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_PODATA_RAW 
as select from ekpo as A inner join eket as B on A.ebeln = B.ebeln and A.ebelp = B.ebelp and B.etenr = '0001'
                         inner join t001w as T001W on A.werks = T001W.werks
                         inner join adrc as ADRCW on t001w.adrnr = ADRCW.addrnumber
                         inner join ekko as K on A.ebeln = K.ebeln
                         left outer join mara as C on A.matnr = C.matnr
                         left outer join ZGTMM_CV_SRMPO_CHANGEDATA as D on A.ebeln = D.ebeln and A.ebelp = D.ebelp
                         left outer join ekkn as E on A.ebeln = E.ebeln and A.ebelp = E.ebelp and E.zekkn = '01'
                         left outer join vbap as F on E.vbeln = F.vbeln and E.vbelp = F.posnr
                         left outer join vbak as G on F.vbeln = G.vbeln  
association [0..1] to t001l as T001L on $projection.werks = T001L.werks and $projection.lgort = T001L.lgort
association [0..1] to t023t as T023T on $projection.matkl = T023T.matkl and T023T.spras = $session.system_language
association [0..1] to t134t as T134T on $projection.mtart = T134T.mtart and T134T.spras = $session.system_language
association [0..1] to t163i as T163I on $projection.knttp = T163I.knttp and T163I.spras = $session.system_language
association [0..1] to t163y as T163Y on $projection.pstyp = T163Y.pstyp and T163Y.spras = $session.system_language

association [0..1] to t005u as T005U on $projection.COUNTRY = t005u.land1 and $projection.REGION = t005u.bland and t005u.spras = $session.system_language
//association [0..1] to kna1 as KNA1 on $projection.KUNNR = kna1.kunnr
association [0..1] to lfa1 as LFA1 on $projection.emlif = LFA1.lifnr
association [0..1] to adrc as ADRC on $projection.adrnr = ADRC.addrnumber
//association [0..1] to /NFM/TNES as I on $projection.NES = I.NES
{
     key  A.ebeln,
          A.ebelp,
          A.loekz,
          A.statu,
          A.werks,
          T001W.name1,
          A.lgort,
          t001l.lgobe,
          A.matnr,
          // 전체품명(MARA-ZZMAKTX80) 우선, 없으면 PO 품목 단품명(EKPO-TXZ01) 사용
          case when C.zzmaktx80 is not null and C.zzmaktx80 <> ''
               then C.zzmaktx80
               else cast(A.txz01 as zzmaktx80) end as txz01,
           cast('' as abap.char(100)) as MAPKEY,
          @Semantics.quantity.unitOfMeasure: 'meins'  
          A.menge,          
          @Semantics.quantity.unitOfMeasure: 'meins' 
          case when D.menge is not null then D.menge
               else cast(0 as bstmg) end as MENGE_O,
          A.meins,
          A.umrez,
          A.umren,
          A.lmein,
          B.eindt,
          A.bednr,
          A.matkl,
          t023t.wgbez60,
          A.infnr,
          A.idnlf,
          @Semantics.amount.currencyCode: 'waers'          
          A.netpr,
          A.peinh,
          A.bprme,
          A.bpumz,
          A.bpumn,
          K.waers,
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
          t134t.mtbez,
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
          A.pstyp,
          t163y.ptext,
          A.knttp,
          t163i.knttx,
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
          case when F.vbeln is not null then F.vbeln else cast('' as vbeln_va) end as VBELN,
          F.posnr,
          case when G.vkorg is not null then G.vkorg else cast('' as vkorg) end as VKORG,
          case when G.vtweg is not null then G.vtweg else cast('' as vtweg) end as VTWEG,
          case when G.vkbur is not null then G.vkbur else cast('' as vkbur) end as vkbur,
           
          case when G.vkgrp is not null then G.vkgrp else cast('' as vkgrp) end as vkgrp,
          
          case when G.kunnr is not null then G.kunnr else cast('' as kunag) end as KUNNR,
      //    kna1.name1 as NAME_K,
          A.emlif,
          lfa1.name1 as  NAME_V,
          A.lblkz,
          A.adrnr,
          case when A.adrnr <> '' then adrc.name1
               else ADRCW.name1 end as DNAME1,
          case when A.adrnr <> '' then adrc.name2
               else ADRCW.name2 end as DNAME2,               
          case when A.adrnr <> '' then adrc.street
               else ADRCW.street end as STREET,  
          case when A.adrnr <> '' then adrc.house_num1
               else ADRCW.house_num1 end as HOUSE_NUM1,  
          case when A.adrnr <> '' then adrc.post_code1
               else ADRCW.post_code1 end as POST_CODE1,       
          case when A.adrnr <> '' then adrc.city1
               else ADRCW.city1 end as CITY1,        
          case when A.adrnr <> '' then adrc.region
               else ADRCW.region end as REGION, 
          case when A.adrnr <> '' then adrc.country
               else ADRCW.country end as COUNTRY,             

          A.bstae,
          A.meprf,
          A.uebpo,
          A.chg_srv,
          A.berid,
          A.afnam,
          A.creationdate,
          A.creationtime,
          A.aedat,
          A.creationtime as AETIM
    
} where A.emlif = ''

union all

select from ekpo as A inner join eket as B on A.ebeln = B.ebeln and A.ebelp = B.ebelp and B.etenr = '0001'
                         inner join t001w as T001W on A.werks = T001W.werks
                         inner join lfa1 as LFA1 on A.emlif = LFA1.lifnr
                         inner join adrc as ADRCW on LFA1.adrnr = ADRCW.addrnumber
                         inner join ekko as K on A.ebeln = K.ebeln
                         left outer join mara as C on A.matnr = C.matnr
                         left outer join ZGTMM_CV_SRMPO_CHANGEDATA as D on A.ebeln = D.ebeln and A.ebelp = D.ebelp
                         left outer join ekkn as E on A.ebeln = E.ebeln and A.ebelp = E.ebelp and E.zekkn = '01'
                         left outer join vbap as F on E.vbeln = F.vbeln and E.vbelp = F.posnr
                         left outer join vbak as G on F.vbeln = G.vbeln  
association [0..1] to t001l as T001L on $projection.werks = T001L.werks and $projection.lgort = T001L.lgort
association [0..1] to t023t as T023T on $projection.matkl = T023T.matkl and T023T.spras = $session.system_language
association [0..1] to t134t as T134T on $projection.mtart = T134T.mtart and T134T.spras = $session.system_language
association [0..1] to t163i as T163I on $projection.knttp = T163I.knttp and T163I.spras = $session.system_language
association [0..1] to t163y as T163Y on $projection.pstyp = T163Y.pstyp and T163Y.spras = $session.system_language

association [0..1] to t005u as T005U on $projection.COUNTRY = t005u.land1 and $projection.REGION = t005u.bland and t005u.spras = $session.system_language
association [0..1] to kna1 as KNA1 on $projection.KUNNR = kna1.kunnr
association [0..1] to adrc as ADRC on $projection.adrnr = adrc.addrnumber
//association [0..1] to /NFM/TNES as I on $projection.NES = I.NES
{
     key  A.ebeln,
          A.ebelp,
          A.loekz,
          A.statu,
          A.werks,
          T001W.name1,
          A.lgort,
          t001l.lgobe,
          A.matnr,
          // 전체품명(MARA-ZZMAKTX80) 우선, 없으면 PO 품목 단품명(EKPO-TXZ01) 사용
          case when C.zzmaktx80 is not null and C.zzmaktx80 <> ''
               then C.zzmaktx80
               else cast(A.txz01 as zzmaktx80) end as txz01,
           cast('' as abap.char(100)) as MAPKEY,
          A.menge,           
          case when D.menge is not null then D.menge
               else cast(0 as bstmg) end as MENGE_O,
          A.meins,
          A.umrez,
          A.umren,
          A.lmein,
          B.eindt,
          A.bednr,
          A.matkl,
          t023t.wgbez60,
          A.infnr,
          A.idnlf,       
          A.netpr,
          A.peinh,
          A.bprme,
          A.bpumz,
          A.bpumn,
          K.waers,   
          A.netwr,  
          A.brtwr,           
          A.ntgew,   
          A.brgew,  
          A.gewei,   
          A.volum,
          A.voleh,
          A.banfn,
          A.bnfpo,
          A.mtart,
          t134t.mtbez,
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
          A.pstyp,
          t163y.ptext,
          A.knttp,
          t163i.knttx,
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
          case when F.vbeln is not null then F.vbeln else cast('' as vbeln_va) end as VBELN,
          F.posnr,
          case when G.vkorg is not null then G.vkorg else cast('' as vkorg) end as VKORG,
          case when G.vtweg is not null then G.vtweg else cast('' as vtweg) end as VTWEG,
          case when G.vkbur is not null then G.vkbur else cast('' as vkbur) end as vkbur,
           
          case when G.vkgrp is not null then G.vkgrp else cast('' as vkgrp) end as vkgrp,
          
          case when G.kunnr is not null then G.kunnr else cast('' as kunag) end as KUNNR,
     //     kna1.name1 as NAME_K,
          A.emlif,
          lfa1.name1 as  NAME_V,
          A.lblkz,
          A.adrnr,
          ADRCW.name1 as DNAME1,
          ADRCW.name2 as DNAME2,               
          ADRCW.street as STREET,  
          ADRCW.house_num1 as HOUSE_NUM1,  
          ADRCW.post_code1 as POST_CODE1,       
          ADRCW.city1 as CITY1,        
          ADRCW.region as REGION, 
          ADRCW.country as COUNTRY,             

          A.bstae,
          A.meprf,
          A.uebpo,
          A.chg_srv,
          A.berid,
          A.afnam,
          A.creationdate,
          A.creationtime,
          A.aedat,
          A.creationtime as AETIM
    
} where A.emlif <> ''
