@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매요청/청구 정보 RAW DATA'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_REQPO_RAW 
as 
select from eban as A inner join ebkn as B on A.banfn = B.banfn and A.bnfpo = B.bnfpo and B.zebkn = '01'
                      inner join t001w as C on A.werks = C.werks
                      inner join t001k as D on C.bwkey = D.bwkey
                      inner join tka02 as E on D.bukrs = E.bukrs
                      inner join t001 as F on E.bukrs = F.bukrs
                      inner join vbak as G on B.vbeln = G.vbeln
                      inner join ZGTMM_CV_GET_SALES_TEAM as H on G.vbeln = H.vbeln and G.vkorg = H.vkorg 
                      inner join vbap as I on B.vbeln = I.vbeln and B.vbelp = I.posnr
association [0..1] to mara as mara on $projection.matnr = mara.matnr
association [0..1] to marc as marC on $projection.matnr = marC.matnr and  $projection.werks = marC.werks
association [0..1] to makt as MAKT on $projection.matnr = makt.matnr and makt.spras = $session.system_language
association [0..1] to ZGTMM_CV_SO_VCVALUE_MAIN   as VC1 on $projection.vbeln = VC1.vbeln and $projection.POSNR = VC1.posnr
association [0..1] to lfa1  as L1 on $projection.flief = L1.lifnr  
association [0..1] to lfa1  as L2 on $projection.lifnr = L2.lifnr
association [0..1] to zgtmmt2000  as rfq on $projection.banfn = rfq.banfn and $projection.bnfpo = rfq.bnfpo   
association [0..1] to zgtppt1010  as PP on $projection.werks = PP.fld_01 and $projection.TEAMCODE = PP.fld_02 and PP.module_kind = 'MM' and PP.codegrp = '0840'   
//association [0..1] to ekpo as ekpo on $projection.banfn = ekpo.banfn and $projection.bnfpo = ekpo.bnfpo and ekpo.loekz = ''
association [0..1] to ZGTMM_CV_GET_POQTY_BYPR  as prqty on $projection.banfn = prqty.banfn and $projection.bnfpo = prqty.bnfpo 
association [0..1] to ZGTSD_I_MaterialCharacteristic  as MAT on $projection.matnr = MAT.matnr and MAT.atnam = 'RL_GA_DRUM_GUBUN' 
{
  key A.banfn,
  key A.bnfpo,
      A.bsart,
      cast('PR' as abap.char(2)) as ZTYPE,
      case when A.bsart = 'NB' then cast('구매요청' as abap.char(4)) 
           else cast('단순견적' as abap.char(4)) end as ZTYPE_n,
      A.matnr,
      // 전체품명(MARA-ZZMAKTX80) 우선, 없으면 구매요청 단품명(EBAN-TXZ01) 사용
      case when mara.zzmaktx80 is not null and mara.zzmaktx80 <> ''
           then mara.zzmaktx80
           else cast(A.txz01 as zzmaktx80) end as txz01,
      A.erdat, //최종 변경일
      @Semantics.quantity.unitOfMeasure: 'meins'
      case when prqty.diff_qty is not null then
            case when prqty.pr_meins = 'G' then cast(round(prqty.diff_qty / 1000 ,3) as bamng) else prqty.diff_qty end
           else  
             case when A.meins = 'G' then cast(round(A.menge / 1000 ,3) as bamng) else A.menge end 
           end as MENGE,
      A.meins,
      VC1.LENGTH,
      VC1.DRQTY,   
      VC1.COLOR,  
      VC1.STRIPE_COLOR,
      VC1.STRIPE_NO,
      VC1.DRUM,   
      VC1.drumname,
      VC1.INSPECTION,         
      VC1.MCONTENTS,
      VC1.specno,
      H.zzyuscd as TEAMCODE,         
      A.lfdat,
      A.matkl,
      D.bukrs,
      E.kokrs,
      F.ktopl,
      A.ekorg,
      A.werks,
      C.name1 as WERKS_N,
     
     A.lgort,
     B.ablad,
     A.ekgrp,
     A.afnam,
     A.flief,
     L1.name1 as FLIEF_N,
     A.lifnr,
     L2.name1 as LIFNR_N,
     @Semantics.amount.currencyCode: 'waers' 
     A.preis,    
     A.waers,
     A.peinh,
     @Semantics.amount.currencyCode: 'waers'
      
     case when A.peinh <> 0 then
      case when prqty.diff_qty is not null then
                (GET_NUMERIC_VALUE(prqty.diff_qty) * GET_NUMERIC_VALUE(A.preis) / GET_NUMERIC_VALUE(A.peinh) )
           else (GET_NUMERIC_VALUE(A.menge) * GET_NUMERIC_VALUE(A.preis) / GET_NUMERIC_VALUE(A.peinh) ) end
     else 
      case when prqty.diff_qty is not null then     
                (GET_NUMERIC_VALUE(prqty.diff_qty) * GET_NUMERIC_VALUE(A.preis)  )
           else (GET_NUMERIC_VALUE(A.menge) * GET_NUMERIC_VALUE(A.preis)  ) end
     end as GSWRT,
     
     A.ebakz,  //종료
     A.loekz, //삭제
     A.emlif,
     A.lblkz,
     A.knttp, //계정지정범주
     A.pstyp, //품목지정범주
     A.frgst, //릴리즈그룹
     A.frgzu, //릴리즈상태 , 'X'릴리즈
     case when B.sakto is not null then B.sakto
          else cast('' as saknr) end as SAKTO,
     case when B.kostl is not null then B.kostl
          else cast('' as kostl) end as KOSTL,   
     B.vbeln,        
     B.vbelp as POSNR,        
     case when B.anln1 is not null then B.anln1
          else cast('' as anln1) end as ANLN1,  
     case when B.anln2 is not null then B.anln2
          else cast('' as anln2) end as ANLN2,               
     case when B.ps_psp_pnr is not null then B.ps_psp_pnr
          else cast('' as ps_psp_pnr) end as pS_PSP_PNR,   
     case when B.aufnr is not null then B.aufnr
          else cast('' as aufnr) end as AUFNR,
     case when rfq.banfn is not null then cast('X' as abap.char(1))
          else cast('' as abap.char(1)) end as flag,
     case when marc.insmk is not null then 
            marc.insmk 
          else
            cast('' as insmk) 
          end as INSMK,
      A.estkz,
      case when A.mwskz <> '' then A.mwskz
           else
             case when A.bednr = 'VA' or A.bednr = 'V0' 
                  then A.bednr else  cast('' as mwskz) end 
           end as mwskz,
      case when mara.mtart is not null then mara.mtart else cast('' as mtart) end as MTART,
//      case when ekpo.ebeln is not null then cast('O' as abap.char(1))
//           else cast('' as abap.char(1)) end as poprocess,
      cast('' as abap.char(1)) as poprocess,           
//      case when ekpo.ebeln is not null then ekpo.ebeln
//           else cast('' as ebeln) end as ebeln,
      cast('' as ebeln) as ebeln,            
//      case when ekpo.ebelp is not null then ekpo.ebelp
//           else cast('' as ebelp) end as ebelp,
      cast('' as ebelp) as ebelp,           
      cast('' as zgteirondrum) as  IRONDRUM,
      cast('' as zgtedrumtitlemark) as DRUMTITLEMARK,
      cast('' as zgteflange_prot) as FLANGE_PROT,
      cast('' as zgtehanjeon) as HANJEON,
      case when I.fixmg = 'X' then cast('SM' as abap.char(2)) else cast('OM' as abap.char(2)) end as SOM ,
      marc.dpcbt,
      case when A.statu = 'N' then cast('신규' as abap.char(105))
           when A.statu = 'B' and A.bsmng > 0 then cast('PO 발행' as abap.char(10))
           when A.statu = 'B' and A.bsmng = 0 then cast('PO 삭제' as abap.char(10))
      end as PR_STATUS,
      A.blckd,
      MAT.atwrt as DRUMC,
      VC1.PACKCODE as PACKCODE
           
} where A.knttp = 'M' 
//where ( A.frgst = ''  or ( A.frgst <> '' and A.frgzu <> '' ) ) and A.knttp = 'M'


union all
select from eban as A inner join ebkn as B on A.banfn = B.banfn and A.bnfpo = B.bnfpo and B.zebkn = '01'
                      inner join t001w as C on A.werks = C.werks
                      inner join t001k as D on C.bwkey = D.bwkey
                      inner join tka02 as E on D.bukrs = E.bukrs
                      inner join t001 as F on E.bukrs = F.bukrs
association [0..1] to mara as mara on $projection.matnr = mara.matnr
association [0..1] to marc as marC on $projection.matnr = marC.matnr and  $projection.werks = marC.werks
association [0..1] to makt as MAKT on $projection.matnr = makt.matnr and makt.spras = $session.system_language
association [0..1] to ZGTMM_CV_PR_VCVALUE_MAIN  as VC1 on $projection.banfn = VC1.PDOC and $projection.bnfpo = VC1.PDOCITEM
association [0..1] to lfa1  as L1 on $projection.flief = L1.lifnr  
association [0..1] to lfa1  as L2 on $projection.lifnr = L2.lifnr
association [0..1] to zgtmmt2000  as rfq on $projection.banfn = rfq.banfn and $projection.bnfpo = rfq.bnfpo   
//association [0..1] to ekpo as ekpo on $projection.banfn = ekpo.banfn and $projection.bnfpo = ekpo.bnfpo and ekpo.loekz = ''
association [0..1] to ZGTMM_CV_GET_POQTY_BYPR  as prqty on $projection.banfn = prqty.banfn and $projection.bnfpo = prqty.bnfpo 
association [0..1] to ZGTMM_CV_GET_DRUM_NAME_PR  as prDR on $projection.banfn = prDR.banfn and $projection.bnfpo = prDR.bnfpo
association [0..1] to ZGTSD_I_MaterialCharacteristic  as MAT on $projection.matnr = MAT.matnr and MAT.atnam = 'RL_GA_DRUM_GUBUN' 


{
  key A.banfn,
  key A.bnfpo,
      A.bsart,
      cast('PR' as abap.char(2)) as ZTYPE,
      case when A.bsart = 'NB' then cast('구매요청' as abap.char(4)) 
           else cast('단순견적' as abap.char(4)) end as ZTYPE_n,
      A.matnr,
      // 전체품명(MARA-ZZMAKTX80) 우선, 없으면 자재 품목명(MAKT-MAKTX) 사용
      case when mara.zzmaktx80 is not null and mara.zzmaktx80 <> ''
           then mara.zzmaktx80
           else cast(A.txz01 as zzmaktx80) end as txz01,
      A.erdat, //최종 변경일
      case when prqty.diff_qty is not null then
            case when prqty.pr_meins = 'G' then cast(round(prqty.diff_qty / 1000 ,3) as bamng) else prqty.diff_qty end
           else  
             case when A.meins = 'G' then cast(round(A.menge / 1000 ,3) as bamng) else A.menge end 
           end as MENGE,
      case when A.meins = 'G' then cast('KG' as bstme) else A.meins end as MEINS,  
      VC1.LENGTH,
      VC1.DRQTY,   
      VC1.COLOR,  
      VC1.STRIPE_COLOR,
      VC1.STRIPE_NO,      
      VC1.DRUM,  
      case when prDR.DRUMNAME is not initial then prDR.DRUMNAME
           else VC1.drumname end as DRUMNAME,
      cast('' as abap.char(70)) as INSPECTION,         
      cast('' as abap.char(70)) as MCONTENTS,       
      VC1.SPECNO,        
      cast('' as abap.char(2)) as TEAMCODE,
     A.lfdat,
     A.matkl,
     D.bukrs,
     E.kokrs,
     F.ktopl,
     A.ekorg,
     A.werks,
     C.name1 as WERKS_N,
     A.lgort,
     B.ablad,
     A.ekgrp,
     A.afnam,
     A.flief,
     L1.name1 as FLIEF_N,
     A.lifnr,
     L2.name1 as LIFNR_N,
     A.preis,    
     A.waers,
     A.peinh,
     case when A.peinh <> 0 then
      case when prqty.diff_qty is not null then
                (GET_NUMERIC_VALUE(prqty.diff_qty) * GET_NUMERIC_VALUE(A.preis) / GET_NUMERIC_VALUE(A.peinh) )
           else (GET_NUMERIC_VALUE(A.menge) * GET_NUMERIC_VALUE(A.preis) / GET_NUMERIC_VALUE(A.peinh) ) end
     else 
      case when prqty.diff_qty is not null then     
                (GET_NUMERIC_VALUE(prqty.diff_qty) * GET_NUMERIC_VALUE(A.preis)  )
           else (GET_NUMERIC_VALUE(A.menge) * GET_NUMERIC_VALUE(A.preis)  ) end
     end as GSWRT,
     A.ebakz,  //종료
     A.loekz, //삭제
     A.emlif,
     A.lblkz,
     A.knttp, //계정지정범주
     A.pstyp, //품목지정범주
     A.frgst, //릴리즈그룹
     A.frgzu, //릴리즈상태 , 'X'릴리즈
     case when B.sakto is not null then B.sakto
          else cast('' as saknr) end as SAKTO,
     case when B.kostl is not null then B.kostl
          else cast('' as kostl) end as KOSTL,   
     case when B.vbeln is not null then B.vbeln
          else cast('' as vbeln) end as VBELN,        
     case when B.vbelp is not null then B.vbelp
          else cast('' as posnr_va) end as POSNR,        
     case when B.anln1 is not null then B.anln1
          else cast('' as anln1) end as ANLN1,  
     case when B.anln2 is not null then B.anln2
          else cast('' as anln2) end as ANLN2,               
     case when B.ps_psp_pnr is not null then B.ps_psp_pnr
          else cast('' as ps_psp_pnr) end as pS_PSP_PNR,   
     case when B.aufnr is not null then B.aufnr
          else cast('' as aufnr) end as AUFNR,
     case when rfq.banfn is not null then cast('X' as abap.char(1))
          else cast('' as abap.char(1)) end as flag,
     case when marc.insmk is not null then 
            marc.insmk 
          else
            cast('' as insmk) 
          end as INSMK,
      A.estkz,
      case when A.mwskz <> '' then A.mwskz
           else
             case when A.bednr = 'VA' or A.bednr = 'V0' 
                  then A.bednr else  cast('' as mwskz) end 
           end as mwskz,
      case when mara.mtart is not null then mara.mtart else cast('' as mtart) end as MTART,
//      case when ekpo.ebeln is not null then cast('O' as abap.char(1))
//           else cast('' as abap.char(1)) end as poprocess,
      cast('' as abap.char(1)) as poprocess,           
//      case when ekpo.ebeln is not null then ekpo.ebeln
//           else cast('' as ebeln) end as ebeln,
      cast('' as ebeln) as ebeln,            
//      case when ekpo.ebelp is not null then ekpo.ebelp
//           else cast('' as ebelp) end as ebelp,
      cast('' as ebelp) as ebelp,   
      cast('' as zgteirondrum) as  IRONDRUM,
      cast('' as zgtedrumtitlemark) as DRUMTITLEMARK,
      cast('' as zgteflange_prot) as FLANGE_PROT,
      cast('' as zgtehanjeon) as HANJEON,
      cast('' as abap.char(2)) as SOM,
      marc.dpcbt,
      case when A.statu = 'N' then cast('신규' as abap.char(105))
           when A.statu = 'B' and A.bsmng > 0 then cast('PO 발행' as abap.char(10))
           when A.statu = 'B' and A.bsmng = 0 then cast('PO 삭제' as abap.char(10))
      end as PR_STATUS,
      A.blckd,
      MAT.atwrt as DRUMC,
      VC1.PACKCODE as PACKCODE
} where A.knttp <> 'M' and A.knttp <> '' and ( A.frgst = ''  or ( A.frgst <> '' and A.frgzu <> '' ) )
//where A.frgst = ''  or ( A.frgst <> '' and A.frgzu <> '' ) and A.knttp <> '' and A.knttp <> 'M'

union all

select from eban as A 
                      inner join t001w as C on A.werks = C.werks
                      inner join t001k as D on C.bwkey = D.bwkey
                      inner join tka02 as E on D.bukrs = E.bukrs
                      inner join t001 as F on E.bukrs = F.bukrs
association [0..1] to mara as mara on $projection.matnr = mara.matnr
association [0..1] to marc as marC on $projection.matnr = marC.matnr and  $projection.werks = marC.werks
association [0..1] to makt as MAKT on $projection.matnr = makt.matnr and makt.spras = $session.system_language
association [0..1] to ZGTMM_CV_PR_VCVALUE_MAIN  as VC1 on $projection.banfn = VC1.PDOC and $projection.bnfpo = VC1.PDOCITEM
association [0..1] to lfa1  as L1 on $projection.flief = L1.lifnr  
association [0..1] to lfa1  as L2 on $projection.lifnr = L2.lifnr
association [0..1] to zgtmmt2000  as rfq on $projection.banfn = rfq.banfn and $projection.bnfpo = rfq.bnfpo   
//association [0..1] to ekpo as ekpo on $projection.banfn = ekpo.banfn and $projection.bnfpo = ekpo.bnfpo and ekpo.loekz = ''
association [0..1] to ZGTMM_CV_GET_POQTY_BYPR  as prqty on $projection.banfn = prqty.banfn and $projection.bnfpo = prqty.bnfpo 
association [0..1] to ZGTMM_CV_GET_DRUM_NAME_PR  as prDR on $projection.banfn = prDR.banfn and $projection.bnfpo = prDR.bnfpo
association [0..1] to ZGTSD_I_MaterialCharacteristic  as MAT on $projection.matnr = MAT.matnr and MAT.atnam = 'RL_GA_DRUM_GUBUN' 

{
  key A.banfn,
  key A.bnfpo,
      A.bsart,
      cast('PR' as abap.char(2)) as ZTYPE,
      case when A.bsart = 'NB' then cast('구매요청' as abap.char(4)) 
           else cast('단순견적' as abap.char(4)) end as ZTYPE_n,
      A.matnr,
      // 전체품명(MARA-ZZMAKTX80) 우선, 없으면 자재 품목명(MAKT-MAKTX) 사용
      case when mara.zzmaktx80 is not null and mara.zzmaktx80 <> ''
           then mara.zzmaktx80
           else cast(A.txz01 as zzmaktx80) end as txz01,
      A.erdat, //최종 변경일
      case when prqty.diff_qty is not null then
            case when prqty.pr_meins = 'G' then cast(round(prqty.diff_qty / 1000 ,3) as bamng) else prqty.diff_qty end
           else  
             case when A.meins = 'G' then cast(round(A.menge / 1000 ,3) as bamng) else A.menge end 
           end as MENGE,
      case when A.meins = 'G' then cast('KG' as bstme) else A.meins end as MEINS,      
      VC1.LENGTH,
      VC1.DRQTY,   
      VC1.COLOR,  
      VC1.STRIPE_COLOR,
      VC1.STRIPE_NO,      
      VC1.DRUM,        
      case when prDR.DRUMNAME is not initial then prDR.DRUMNAME
           else VC1.drumname end as DRUMNAME,
      cast('' as abap.char(70)) as INSPECTION,    
      cast('' as abap.char(70)) as MCONTENTS,     
      VC1.SPECNO,     
      cast('' as abap.char(2)) as TEAMCODE,
     A.lfdat,
     A.matkl,
     D.bukrs,
     E.kokrs,
     F.ktopl,
     A.ekorg,
     A.werks,
     C.name1 as WERKS_N,
     A.lgort,
     cast('' as ablad) as ablad,
     A.ekgrp,
     A.afnam,
     A.flief,
     L1.name1 as FLIEF_N,
     A.lifnr,
     L2.name1 as LIFNR_N,
     A.preis,    
     A.waers,
     A.peinh,
     case when A.peinh <> 0 then
      case when prqty.diff_qty is not null then
                (GET_NUMERIC_VALUE(prqty.diff_qty) * GET_NUMERIC_VALUE(A.preis) / GET_NUMERIC_VALUE(A.peinh) )
           else (GET_NUMERIC_VALUE(A.menge) * GET_NUMERIC_VALUE(A.preis) / GET_NUMERIC_VALUE(A.peinh) ) end
     else 
      case when prqty.diff_qty is not null then     
                (GET_NUMERIC_VALUE(prqty.diff_qty) * GET_NUMERIC_VALUE(A.preis)  )
           else (GET_NUMERIC_VALUE(A.menge) * GET_NUMERIC_VALUE(A.preis)  ) end
     end as GSWRT,
     A.ebakz,  //종료
     A.loekz, //삭제
     A.emlif,
     A.lblkz,
     A.knttp, //계정지정범주
     A.pstyp, //품목지정범주
     A.frgst, //릴리즈그룹
     A.frgzu, //릴리즈상태 , 'X'릴리즈
     cast('' as saknr)  as SAKTO,
     cast('' as kostl)  as KOSTL,   
     cast('' as vbeln)  as VBELN,        
     cast('' as posnr_va) as POSNR,        
     cast('' as anln1)  as ANLN1,  
     cast('' as anln2)  as ANLN2,               
     cast('' as ps_psp_pnr)  as pS_PSP_PNR,   
     cast('' as aufnr)  as AUFNR,
     case when rfq.banfn is not null then cast('X' as abap.char(1))
          else cast('' as abap.char(1)) end as flag,
     case when marc.insmk is not null then 
            marc.insmk 
          else
            cast('' as insmk) 
          end as INSMK,
      A.estkz,
      case when A.mwskz <> '' then A.mwskz
           else
             case when A.bednr = 'VA' or A.bednr = 'V0' 
                  then A.bednr else  cast('' as mwskz) end 
           end as mwskz   ,
      case when mara.mtart is not null then mara.mtart else cast('' as mtart) end as MTART  ,
//      case when ekpo.ebeln is not null then cast('O' as abap.char(1))
//           else cast('' as abap.char(1)) end as poprocess,
      cast('' as abap.char(1)) as poprocess,           
//      case when ekpo.ebeln is not null then ekpo.ebeln
//           else cast('' as ebeln) end as ebeln,
      cast('' as ebeln) as ebeln,            
//      case when ekpo.ebelp is not null then ekpo.ebelp
//           else cast('' as ebelp) end as ebelp,
      cast('' as ebelp) as ebelp,   
      cast('' as zgteirondrum) as  IRONDRUM,
      cast('' as zgtedrumtitlemark) as DRUMTITLEMARK,
      cast('' as zgteflange_prot) as FLANGE_PROT,
      cast('' as zgtehanjeon) as HANJEON,
      cast('' as abap.char(2)) as SOM,
      marc.dpcbt,
      case when A.statu = 'N' then cast('신규' as abap.char(105))
           when A.statu = 'B' and A.bsmng > 0 then cast('PO 발행' as abap.char(10))
           when A.statu = 'B' and A.bsmng = 0 then cast('PO 삭제' as abap.char(10))
      end as PR_STATUS,
      A.blckd,
      MAT.atwrt as DRUMC,
      VC1.PACKCODE as PACKCODE
} where A.knttp = ''


union all

select from zgtppt3420 as a inner join t001w as b on a.werks = b.werks
                            inner join t001k as c on b.bwkey = c.bwkey
                            inner join t001 as d on c.bukrs = d.bukrs    
                            inner join marc as e on a.matnr = e.matnr and a.werks = e.werks                        
                            inner join mara as MARA on  a.matnr = mara.matnr
                            left outer join marm as MARM on a.erfme = MARM.meinh and a.matnr = MARM.matnr
association [0..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language
association [0..1] to marc as marC on $projection.matnr = marC.matnr and  $projection.werks = marC.werks 
//association [0..1] to ekpo as ekpo on $projection.banfn = ekpo.bednr and $projection.bnfpo = ekpo.afnam and ekpo.loekz = ''
association [0..1] to ZGTMM_CV_GET_CL_PO_DAT  as prqty on $projection.banfn = prqty.reqno and $projection.bnfpo = prqty.posnr 
association [0..1] to ZGTSD_I_MaterialCharacteristic  as MAT on $projection.matnr = MAT.matnr and MAT.atnam = 'RL_GA_DRUM_GUBUN' 

{
  key a.reqno as banfn,
  key a.posnr as bnfpo,
      cast('NB' as bbsrt) as BSART,
      cast('CL' as abap.char(2)) as ZTYPE,
      cast('청구현황' as abap.char(4)) as ZTYPE_n,
      a.matnr,
      case when mara.zzmaktx80 <> '' then mara.zzmaktx80
                else makt.maktx end as txz01,
      a.chdat as erdat, //최종 변경일

      case when MARA.meins = a.erfme then 
          case when prqty.diff_qty is not null then prqty.diff_qty 
               else a.lfimg end
         else                                      
            case when MARM.meinh is not null then
                    case when prqty.diff_qty is not null then cast(ROUND(MARM.umrez * prqty.diff_qty / MARM.umren,3) as bamng)  else  cast(ROUND(MARM.umrez * a.lfimg / MARM.umren,3) as bamng) end              
                 else
                    case a.erfme when  'G' then
                                 case MARA.meins when 'KG' then case when prqty.diff_qty is not null then cast(round(prqty.diff_qty / 1000 ,3) as bamng) else cast(round(a.lfimg / 1000 ,3) as bamng) end
                                                 when 'TON' then case when prqty.diff_qty is not null then cast(round(prqty.diff_qty / 1000000 ,3) as bamng) else cast(round(a.lfimg / 1000000 ,3) as bamng) end
                                                 else case when prqty.diff_qty is not null then prqty.diff_qty else a.lfimg end end
                                 when 'M' then
                                  case MARA.meins when 'KM' then case when prqty.diff_qty is not null then cast(round(prqty.diff_qty / 1000 ,3) as bamng) else cast(round(a.lfimg / 1000 ,3) as bamng) end
                                                 else case when prqty.diff_qty is not null then prqty.diff_qty else a.lfimg end   end                                                 
                                  else case when prqty.diff_qty is not null then prqty.diff_qty else a.lfimg end end 
                 end
            end  as MENGE,
      MARA.meins as MEINS,         
      
      cast('' as abap.char(70)) as LENGTH,
      cast('' as abap.char(70)) as DRQTY,   
      cast('' as abap.char(70)) as COLOR,  
      cast('' as abap.char(70)) as STRIPE_COLOR,  
      cast('' as abap.char(70)) as STRIPE_NO,  
      cast('' as abap.char(70)) as DRUM,        
      cast('' as abap.char(70)) as DRUMname,         
      cast('' as abap.char(70)) as INSPECTION,
      cast('' as abap.char(70)) as MCONTENTS,
      cast('' as abap.char(70)) as SPECNO,    
      cast('' as abap.char(2)) as TEAMCODE,
      a.reqdat as lfdat,
      mara.matkl,
      d.bukrs,
      cast('' as kokrs) as kokrs,
      d.ktopl,
      b.ekorg,
      a.werks,
      b.name1 as WERKS_N,
      a.lgort_t as lgort,
      cast('' as ablad) as ABLAD,
      e.ekgrp,
      a.crnam as afnam,
      cast('' as lifnr) as flief,
      cast('' as name1_gp) as FLIEF_N,
      cast('' as lifnr) as lifnr,
      cast('' as name1_gp) as LIFNR_N,
      cast(0 as bapre) as preis,    
      cast('KRW' as waers) as waers,
      cast(1 as epein) as peinh,
      cast(0 as abap.decfloat34(34))  as GSWRT,
      cast('' as ebakz) as ebakz,  //종료
      case when a.zstatus = '' then cast('' as eloek) 
           else cast('X' as eloek) end as loekz, //삭제
      cast('' as emlif ) as emlif,
      cast('' as lblkz) as lblkz,          
      cast('' as knttp) as knttp, //계정지정범주
      cast('0' as pstyp) as pstyp, //품목지정범주
      cast('' as frgst) as frgst, //릴리즈그룹
      cast('' as frgzu) as frgzu, //릴리즈상태 , 'X'릴리즈
      cast('' as saknr) as SAKTO,
      cast('' as kostl) as KOSTL,   
      a.vbeln,        
      a.vbelp as POSNR,        
      cast('' as anln1) as ANLN1,  
      cast('' as anln2) as ANLN2,               
      cast('' as ps_psp_pnr) as pS_PSP_PNR,   
      cast('' as aufnr)  as AUFNR,
      cast('' as abap.char(1)) as flag,
      case when marc.insmk is not null then 
            marc.insmk 
          else
            cast('' as insmk) 
          end as INSMK,
      cast('' as estkz) as estkz ,
      cast('' as mwskz) as MWSKZ       ,
      case when mara.mtart is not null then mara.mtart else cast('' as mtart) end as MTART  ,
//      case when ekpo.ebeln is not null then cast('O' as abap.char(1))
//           else cast('' as abap.char(1)) end as poprocess,
      cast('' as abap.char(1)) as poprocess,           
//      case when ekpo.ebeln is not null then ekpo.ebeln
//           else cast('' as ebeln) end as ebeln,
      cast('' as ebeln) as ebeln,            
//      case when ekpo.ebelp is not null then ekpo.ebelp
//           else cast('' as ebelp) end as ebelp,
      cast('' as ebelp) as ebelp,   
      a.irondrum,
      a.drumtitlemark,
      a.flange_prot,
      a.hanjeon,
      cast('' as abap.char(2)) as SOM,
      e.dpcbt,
      cast('' as abap.char(10)) as PR_STATUS,
      cast('' as abap.char(1)) as BLCKD,
      MAT.atwrt as DRUMC,
      cast('' as abap.char(70)) as PACKCODE
} where a.drumflag = ''
