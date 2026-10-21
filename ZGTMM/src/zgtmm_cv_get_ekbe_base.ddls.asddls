@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매 정산 용 구매 HISTORY 기초 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_EKBE_BASE 
as 
select from ekbe as A inner join ekpo as B on A.ebeln = B.ebeln and A.ebelp = B.ebelp
                      inner join matdoc as C on A.gjahr = C.mjahr and A.belnr = C.mblnr and A.buzei = C.zeile 
                      inner join eket as D on B.ebeln = D.ebeln and B.ebelp = D.ebelp 
                      inner join ekko as E on A.ebeln = E.ebeln
                      inner join lfm1 as F on E.lifnr = F.lifnr and E.ekorg = F.ekorg
                      left outer join ZGTMM_CV_GET_EKBE_HISTORY_IV2 as k on A.gjahr = k.MJAHR and A.belnr = k.MBLNR and A.buzei = k.ZEILE
                      left outer join ekkn as z on B.ebeln = z.ebeln and B.ebelp = z.ebelp and z.zekkn = '01'
association [0..1] to ZGTMM_CV_GET_INFOPRICE  as INFO on $projection.ekorg = INFO.ekorg and $projection.werks = INFO.werks 
         and $projection.matnr = INFO.matnr and $projection.lifnr = INFO.lifnr and $projection.pstyp = INFO.esokz and INFO.datab <= $projection.budat and INFO.datbi >= $projection.budat and INFO.EINA_LOEKZ = '' and INFO.EINE_LOEKZ = ''                           
                      
                      
{
   key A.ebeln,
   key A.ebelp,
   key case when C.lfbnr <> '' then C.lfbja else C.mjahr end as mjahr,
   key case when C.lfbnr <> '' then C.lfbnr else C.mblnr end as mblnr,
   key case when C.lfbnr <> '' then C.lfpos else C.zeile end as zeile,   
//   key C.mjahr,
//   key C.mblnr,
//   key C.zeile,
       case when A.bwart = '161' then cast('' as xrech) else cast('X' as xrech) end as XRECH,
       C.budat,
       LEFT(C.budat,6) as SPMON,
       E.bukrs,
       E.ekorg,
       E.ekgrp,
       E.lifnr,
       B.pstyp,
       A.shkzg,
       @Semantics.quantity.unitOfMeasure: 'MEINS'     
       case when A.bwart <> '161' then
            case when A.shkzg = 'H' then A.menge * -1 else A.menge end 
            else
            case when A.shkzg = 'S' then A.menge * -1 else A.menge end             
            end as menge,
       B.meins,
       @Semantics.amount.currencyCode: 'HSWAE'  
       case when A.bwart <> '161' then       
             case when A.shkzg = 'H' then cast(A.dmbtr * -1 as dmbtr_cs) else cast(A.dmbtr as dmbtr_cs) end 
            else
             case when A.shkzg = 'S' then cast(A.dmbtr * -1 as dmbtr_cs) else cast(A.dmbtr as dmbtr_cs) end
            end as DMBTR,     //현지통화
       @Semantics.amount.currencyCode: 'waers'
       case when A.bwart <> '161' then         
             case when A.shkzg = 'H' then A.wrbtr * -1 else A.wrbtr end 
            else
             case when A.shkzg = 'S' then A.wrbtr * -1 else A.wrbtr end            
            end as WRBTR ,     //전표통화
       A.waers,
       A.hswae,     //현지통화키
       A.cpudt,
       A.cputm,
       B.matnr,
       B.txz01,
       B.werks,
       D.eindt,
       B.webre,
       B.mwskz,
       B.meprf,
       B.prdat,
       @Semantics.amount.currencyCode: 'waers'
       B.netpr, //구매발주단가
       B.peinh,     //단위
       E.bedat,
       case when B.bpumn = cast('0' as bpumn) then cast('1' as bpumn) else B.bpumn end as BPUMN ,
       INFO.konwa,

       @Semantics.amount.currencyCode: 'waers'       
       case when A.waers = INFO.konwa then      // 구매 통화와 info 통화가 같은 경우  
           case when E.ekgrp = 'Z32' then
                   case when INFO.kbetr is not null then INFO.kbetr
                       else B.netpr end 
           else
             case when B.meprf = '5' then
                  case when INFO.kbetr is not null then INFO.kbetr
                       else B.netpr end 
                   else
                                   B.netpr     //구매발주단가      
                   end            
           end         
          else
              B.netpr 
       end as ETIV_PRICE, //유효단가
 
       case when A.waers = INFO.konwa then      
           case when E.ekgrp = 'Z32' then
                   case when INFO.kpein is not null then INFO.kpein
                       else B.peinh end           
           else
            case when B.meprf = '5' then
                  case when INFO.kpein is not null then INFO.kpein
                       else B.peinh end 
                else
                   B.peinh      
                end          
           end    
           else
             B.peinh                   
       end  as ETIV_PEINH, //유효단가 가격 단위,          

       case when A.waers = INFO.konwa then       
            case when E.ekgrp = 'Z32' then
                  case when INFO.kmein is not null then INFO.kmein
                       else B.meins end             
            else      
                case when B.meprf = '5' then
                  case when INFO.kmein is not null then INFO.kmein
                       else B.meins end 
                else
                   B.meins     
                end 
            end    
           else
                    B.meins 
        end  as ETIV_MEINS, //유효단가 단위       

       case when A.waers = INFO.konwa then 
             case when E.ekgrp = 'Z32' then
                   case when INFO.konwa is not null then INFO.konwa
                       else A.waers end             
             else
             case when B.meprf = '5' then
                  case when INFO.konwa is not null then INFO.konwa
                       else A.waers end 
                  else
                    A.waers     
                  end             
             end      
           else 
              A.waers 
           end as ETIV_waers, //유효단가 단위     
       F.waers as BPWAERS,
       @Semantics.quantity.unitOfMeasure: 'BSTME_IV'           
       case when k.MENGE is not null then k.MENGE else cast(0 as menge_d) end as MENGE_IV,
       case when k.bstme is not null then k.bstme else B.meins end as BSTME_IV,
       @Semantics.amount.currencyCode: 'waers_IV'       
       case when k.WRBTR is not null then k.WRBTR else cast(0 as wrbtr_cs) end as WRBTR_IV,
       case when k.waers is not null then k.waers else A.waers end as WAERS_IV,
       case when z.vbeln is not null then z.vbeln else cast('' as vbeln_va) end as vbeln,
       case when z.vbelp is not null then z.vbelp else cast('' as posnr_va) end as posnr,
       C.mjahr as orig_mjahr,     //원본 물리 자재문서연도(추적/감사용)
       C.mblnr as orig_mblnr,     //원본 물리 자재문서번호(추적/감사용)
       C.zeile as orig_zeile     //원본 물리 자재문서항목(추적/감사용)                              
    
} where  A.zekkn = '00' and A.vgabe = '1' and  C.cancelled = '' and C.reversal_movement = '' and B.pstyp <> 'U' and D.etenr = '0001' and B.loekz = '' and B.webre = 'X' and A.bwart <> '122'

union all

select from ekbe as A inner join ekpo as B on A.ebeln = B.ebeln and A.ebelp = B.ebelp
                      inner join matdoc as C on A.gjahr = C.mjahr and A.belnr = C.mblnr and A.buzei = C.zeile 
                      inner join eket as D on B.ebeln = D.ebeln and B.ebelp = D.ebelp 
                      inner join ekko as E on A.ebeln = E.ebeln
                      inner join lfm1 as F on E.lifnr = F.lifnr and E.ekorg = F.ekorg
                      left outer join ZGTMM_CV_GET_EKBE_HISTORY_IV2 as k on A.gjahr = k.MJAHR and A.belnr = k.MBLNR and A.buzei = k.ZEILE
                      left outer join ekkn as z on B.ebeln = z.ebeln and B.ebelp = z.ebelp and z.zekkn = '01'
association [0..1] to ZGTMM_CV_GET_INFOPRICE  as INFO on $projection.ekorg = INFO.ekorg and $projection.werks = INFO.werks 
         and $projection.matnr = INFO.matnr and $projection.lifnr = INFO.lifnr and $projection.pstyp = INFO.esokz and INFO.datab <= $projection.budat and INFO.datbi >= $projection.budat and INFO.EINA_LOEKZ = '' and INFO.EINE_LOEKZ = ''                         
                      
                      
{
   key A.ebeln,
   key A.ebelp,
   key A.lfgja as mjahr,
   key A.lfbnr as mblnr,
   key A.lfpos as zeile,
       cast('X' as xrech) as XRECH,   
       C.budat,
       LEFT(C.budat,6) as SPMON,
       E.bukrs,
       E.ekorg,
       E.ekgrp,
       E.lifnr,
       B.pstyp,
       A.shkzg,
       case when A.shkzg = 'H' then A.menge * -1 else A.menge end as menge,
       B.meins,
       case when A.shkzg = 'H' then A.dmbtr * -1 else A.dmbtr end as DMBTR,     //현지통화
       case when A.shkzg = 'H' then A.wrbtr * -1 else A.wrbtr end as WRBTR ,     //전표통화
       A.waers,
       A.hswae,     //현지통화키
       A.cpudt,
       A.cputm,
       B.matnr,
       B.txz01,
       B.werks,
       D.eindt,
       B.webre,
       B.mwskz,
       B.meprf,
       B.prdat,
       B.netpr, //구매발주단가
       B.peinh,     //단위
       E.bedat,
       case when B.bpumn = cast('0' as bpumn) then cast('1' as bpumn) else B.bpumn end as BPUMN ,
       INFO.konwa,
        
       case when A.waers = INFO.konwa then      // 구매 통화와 info 통화가 같은 경우  
           case when E.ekgrp = 'Z32' then
                   case when INFO.kbetr is not null then INFO.kbetr
                       else B.netpr end 
           else
             case when B.meprf = '5' then
                  case when INFO.kbetr is not null then INFO.kbetr
                       else B.netpr end 
                   else
                                   B.netpr     //구매발주단가      
                   end            
           end         
          else
              B.netpr 
       end as ETIV_PRICE, //유효단가
 
       case when A.waers = INFO.konwa then      
           case when E.ekgrp = 'Z32' then
                   case when INFO.kpein is not null then INFO.kpein
                       else B.peinh end           
           else
            case when B.meprf = '5' then
                  case when INFO.kpein is not null then INFO.kpein
                       else B.peinh end 
                else
                   B.peinh      
                end          
           end    
           else
             B.peinh                   
       end  as ETIV_PEINH, //유효단가 가격 단위,          

       case when A.waers = INFO.konwa then       
            case when E.ekgrp = 'Z32' then
                  case when INFO.kmein is not null then INFO.kmein
                       else B.meins end             
            else      
                case when B.meprf = '5' then
                  case when INFO.kmein is not null then INFO.kmein
                       else B.meins end 
                else
                   B.meins     
                end 
            end    
           else
                    B.meins 
        end  as ETIV_MEINS, //유효단가 단위       

       case when A.waers = INFO.konwa then 
             case when E.ekgrp = 'Z32' then
                   case when INFO.konwa is not null then INFO.konwa
                       else A.waers end             
             else
             case when B.meprf = '5' then
                  case when INFO.konwa is not null then INFO.konwa
                       else A.waers end 
                  else
                    A.waers     
                  end             
             end      
           else 
              A.waers 
           end as ETIV_waers, //유효단가 단위     
       F.waers as BPWAERS,      
       case when k.MENGE is not null then k.MENGE else cast(0 as menge_d) end as MENGE_IV,
       case when k.bstme is not null then k.bstme else B.meins end as BSTME_IV,
       case when k.WRBTR is not null then k.WRBTR else cast(0 as wrbtr_cs) end as WRBTR_IV,
       case when k.waers is not null then k.waers else A.waers end as WAERS_IV,
       case when z.vbeln is not null then z.vbeln else cast('' as vbeln_va) end as vbeln,
       case when z.vbelp is not null then z.vbelp else cast('' as posnr_va) end as posnr ,                          
       C.mjahr as orig_mjahr,     //원본 물리 자재문서연도(추적/감사용)
       C.mblnr as orig_mblnr,     //원본 물리 자재문서번호(추적/감사용)
       C.zeile as orig_zeile     //원본 물리 자재문서항목(추적/감사용)     
} where  A.zekkn = '00' and A.vgabe = '1' and  C.cancelled = '' and C.reversal_movement = '' and B.pstyp <> 'U' and D.etenr = '0001' and B.loekz = '' and B.webre = 'X' and A.bwart = '122'
