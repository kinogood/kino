@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매요청/청구 정보 RAW DATA2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_REQPO_RAW2 
as 
select from ZGTMM_CV_GET_REQPO_RAW as a
association [0..1] to t023t as T023T on $projection.matkl = T023T.matkl and T023T.spras = $session.system_language
association [0..1] to t024e as T024e on $projection.ekorg = T024e.ekorg 
association [0..1] to t001l as T001L on $projection.werks = t001l.werks and $projection.lgort = t001l.lgort 
association [0..1] to t024 as T024 on $projection.ekgrp = T024.ekgrp 
association [0..1] to cskt as CSKT on $projection.kokrs = CSKT.kokrs and $projection.KOSTL = CSKT.kostl and CSKT.spras = $session.system_language
association [0..1] to t163i as T163I on $projection.knttp = T163I.knttp and T163I.spras = $session.system_language
association [0..1] to t163y as T163Y on $projection.pstyp = T163Y.pstyp and T163Y.spras = $session.system_language
association [0..1] to skat as SKAT on $projection.ktopl = SKAT.ktopl and $projection.SAKTO = SKAT.saknr and SKAT.spras = $session.system_language
association [0..1] to vbak as VBAK on $projection.vbeln = VBAK.vbeln
association [0..1] to vbap as VBAp on $projection.vbeln = VBAp.vbeln and $projection.POSNR = VBAp.posnr 
association [0..1] to anla as ANLA on $projection.bukrs = ANLA.bukrs and $projection.ANLN1 = ANLA.anln1 and $projection.ANLN2 = ANLA.anln2 and ANLA.spras = $session.system_language
association [0..1] to prps as PRPS on $projection.pS_PSP_PNR = PRPS.pspnr
//association [0..1] to ekpo as ekpo on $projection.banfn = ekpo.banfn and $projection.bnfpo = ekpo.bnfpo and ekpo.loekz = ''
association [0..1] to zgtmmt2010  as SCREQ on $projection.banfn = SCREQ.banfn and $projection.bnfpo = SCREQ.bnfpo
association [0..1] to zgtppt1010  as PP on $projection.werks = PP.fld_01 and $projection.TEAMCODE = PP.fld_02 and PP.module_kind = 'MM' and PP.codegrp = '0840'   
association [0..1] to zgtppt1010  as PP1 on $projection.werks = PP1.fld_01 and $projection.specno = PP1.fld_02 and PP1.module_kind = 'MM' and PP1.codegrp = '0890'
association [0..1] to ZGTMM_CV_PACK_DRUM_GUBUN as PK on $projection.PACKCODE = PK.PACKCODE
{
  key a.banfn,
  key a.bnfpo,
      a.bsart,
      a.ZTYPE,
      a.ZTYPE_n,      
      a.matnr,
      a.txz01,
      a.erdat, //최종 변경일
      @Semantics.quantity.unitOfMeasure: 'meins'
      a.MENGE,
      a.meins,
      a.LENGTH,
      a.DRQTY,
      a.COLOR,
      a.specno,
      a.PACKCODE,
      STRIPE_COLOR,  
      STRIPE_NO,        
      a.DRUM,      
      a.drumname,            
      a.INSPECTION,
      a.MCONTENTS,
      a.TEAMCODE,      
      a.lfdat,
      a.matkl,
      t023t.wgbez60 as MATKL_N,
      a.bukrs,
      a.kokrs,
      a.ktopl,
      a.ekorg,
      t024e.ekotx as EKORG_N,
      a.werks,
      a.WERKS_N,
      case when a.MTART = 'MCFE' or a.MTART = 'MCHA' or a.MTART = 'HAWA' then 
        case when a.werks = '6500' then
              case when a.estkz = 'V' and a.flief <> '' then '3498'
                   else
                     case when a.INSPECTION = '유' then '3410'
                          else
                            case when PP.fld_03 is not null then PP.fld_03 
                                 else
                                     case when a.vbeln = '' then '3410'
                                          else
                                            case when a.dpcbt = 'A' or a.dpcbt = '' then '3410'
                                                 else
                                                    case when PP1.fld_03 is not null then PP1.fld_03
                                                         else
                                                            case when a.MTART = 'MCFE' or a.MTART = 'HAWA' then '3410'
                                                                 else 
                                                                   // 9-1번: 판매오더/구매요청 SAP_MILLCA_PACKAGING 드럼 자재의 드럼구분이 수출용 코드면 3410
                                                                   case when PK.DRM_GUBUN = 'E' or PK.DRM_GUBUN = 'EB' or PK.DRM_GUBUN = 'J' or PK.DRM_GUBUN = 'LS-E' or PK.DRM_GUBUN = 'ME' or PK.DRM_GUBUN = 'MEB' or PK.DRM_GUBUN = 'MH' or PK.DRM_GUBUN = 'NEMA' or PK.DRM_GUBUN = 'UE' then '3410'
                                                                        else
                                                                   case when a.DRUMC <> 'D' and a.DRUMC <> 'H' then '3410'
                                                                        else '3420' end
                                                                   end
                                                            end 
                                                         end
                                                 end
                                          
                                          end
                                 end  
                          end
                   
                   end
             when a.werks = '6600' then 
                   case when a.estkz = 'V' and a.flief <> '' then '3498'
                        else '3410' end
             end
      
      else
        a.lgort
      end as lgort,

      // 8번 분기(총중량 3.5톤 초과 판단) 대상 표시: 1~7번 분기를 통과해 3420 후보가 된 건
      // 총중량은 CDS 에서 구할 수 없어 ZGTMMR3000 (SET_LGORT_BY_WEIGHT) 에서 판단한다
      case when a.MTART = 'MCHA' and a.werks = '6500' then
              case when a.estkz = 'V' and a.flief <> '' then ''
                   else
                     case when a.INSPECTION = '유' then ''
                          else
                            case when PP.fld_03 is not null then ''
                                 else
                                     case when a.vbeln = '' then ''
                                          else
                                            case when a.dpcbt = 'A' or a.dpcbt = '' then ''
                                                 else
                                                    case when PP1.fld_03 is not null then ''
                                                         else
                                                            // 9번: DRUMC 값이 있고 D/H 가 아니면 3410. NULL(드럼 없음)은 체크하지 않고 통과
                                                            case when PK.DRM_GUBUN = 'E' or PK.DRM_GUBUN = 'EB' or PK.DRM_GUBUN = 'J' or PK.DRM_GUBUN = 'LS-E' or PK.DRM_GUBUN = 'ME' or PK.DRM_GUBUN = 'MEB' or PK.DRM_GUBUN = 'MH' or PK.DRM_GUBUN = 'NEMA' or PK.DRM_GUBUN = 'UE' then ''
                                                                 else
                                                            case when a.DRUMC <> 'D' and a.DRUMC <> 'H' then ''
                                                                 else 'X' end
                                                            end
                                                         end
                                                 end
                                          end
                                 end
                          end
                   end
           else '' end as LGCHK,


      a.ablad,
      a.ekgrp,
      t024.eknam as EKGRP_N,
      a.afnam,
      case when a.flief <> '' then a.flief
           else
             case when a.lifnr <> '' then a.lifnr else cast('' as lifnr) end
           end as FLIEF,
      case when a.FLIEF_N <> '' then a.FLIEF_N
           else
             case when a.LIFNR_N <> '' then a.LIFNR_N else cast('' as name1) end
           end as FLIEF_N,

      a.lifnr,
      a.LIFNR_N,
      @Semantics.amount.currencyCode: 'waers' 
      a.preis,    
      a.waers,
      a.peinh,
      @Semantics.amount.currencyCode: 'waers' 
      a.GSWRT,
      case when vbap.mwsbp is not null then
            case when vbap.mwsbp > 0 then cast('과세' as abap.char(4))
                 else cast('영세' as abap.char(4)) end
           else cast('' as abap.char(4)) end as sotax,
      a.ebakz,  //종료
      a.loekz, //삭제
      a.emlif,
      a.lblkz,
      a.knttp, //계정지정범주
      t163i.knttx as KNTTP_N,
      a.pstyp, //품목지정범주
      t163y.ptext as PSTYP_N,
      a.frgst, //릴리즈그룹
      a.frgzu, //릴리즈상태 , 'X'릴리즈
      a.SAKTO,
      skat.txt20 as SAKTO_N,
      a.KOSTL,   
      cskt.ktext as KOSTL_N,
      a.vbeln,        
      a.POSNR,        
      vbak.kunnr,
      vbak.vkbur,
      vbak.vkgrp,      
      a.ANLN1,      
      a.ANLN2,
      anla.txt50 as ANLN1_N,
      a.pS_PSP_PNR,   
      prps.post1 as PS_PSP_PNR_N,
      a.AUFNR,
      case when SCREQ.banfn_n is not initial then SCREQ.banfn_n
           else cast('' as banfn) end as BANFN_N,
      a.flag,
      a.poprocess,
      a.ebeln,          
      a.ebelp,
      a.estkz,
      case when vbap.mwsbp is not null then
            case when vbap.mwsbp > 0 then cast('VA' as mwskz)
                 else cast('V1' as mwskz) end
           else a.mwskz end as mwskz,
      a.MTART,
      a.IRONDRUM,
      a.DRUMTITLEMARK,
      a.FLANGE_PROT,
      a.HANJEON,
      a.SOM,
      a.dpcbt,
      a.PR_STATUS,
      a.blckd,
      a.INSMK               
      
}

