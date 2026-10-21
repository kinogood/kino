@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매오더 별 입고 현황(최종)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_PO_DATA_GRL 
as select from ZGTMM_CV_GET_PO_DATA_GR as A left outer join usr21 as B on A.ANAME = B.bname
association [0..1] to zgtmmt3000 as APP on $projection.ebeln = APP.ebeln
association [0..1] to adrp as ADRP on $projection.persnumber = ADRP.persnumber
association [0..1] to ZGTMM_CV_GET_NF_VALUE as NF on $projection.ebeln = NF.ebeln and $projection.ebelp = NF.ebelp and ( NF.NES_AL <> '' or NF.NES_CU <> '' and NF.NES_FI <> '')
association [0..1] to ZGTMM_CV_PO_VCVALUE_MAIN as dr on $projection.ebeln = dr.PDOC and $projection.ebelp = dr.PDOCITEM
 
{
 
      key A.ekgrp,
      key A.ebeln,
      key A.ebelp,
          A.ihrez,
          A.IHREZ_N,
          A.bukrs,
          A.ekorg,
          A.ekotx,  

          A.eknam,
          A.bsart,
          A.batxt,    
          A.AEDAT_H,
          A.ernam,   
          A.lifnr,
          A.name1,
          A.zterm,
          A.text1,
          A.zbd1t,
          A.zbd2t,
          A.zbd3t,
          A.frggr,
          case when A.REL_STAT = 'X' then cast('X' as abap.char(1))
               else
                case when APP.ebeln is not initial then cast('X' as abap.char(1))
                     else 
                        case when A.loekz = 'L' then cast('X' as abap.char(1))
                             else  cast('' as abap.char(1)) end
                end
          end as REQ_A,
          A.REL_STAT,
          A.PO_WAERS,
          A.wkurs,
          A.bedat,
          A.inco1,
          A.INCO_N,
          A.lands,
          A.loekz,
          A.statu,
          A.werks,
          A.WERKS_N,
          A.lgort,
          A.lgobe,
          A.matnr,
          A.txz01,
          A.COLOR,
          A.MAPKEY,
          @Semantics.quantity.unitOfMeasure: 'meins'  
          A.menge,
          A.LENGTH,
          @Semantics.quantity.unitOfMeasure: 'dr_meins'       
          A.po_drqty,             
          A.dr_meins,
          dr.drumname,
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
          A.zgrstatus_C,          
          A.zgrstatus,

          @Semantics.quantity.unitOfMeasure: 'GR_MEINS'
          A.GR_MENGE,
          A.GR_MEINS,
     
          @Semantics.quantity.unitOfMeasure: 'dr_meins'                   
          A.gr_drqty,            
               
          @Semantics.amount.currencyCode: 'konwa'      
          A.KBETR, //INFO 단가
          A.KONWA,   
          A.kpein ,
          A.kmein,     
          @Semantics.amount.currencyCode: 'INFOWAERS'
          A.PRICESUM,          
          A.INFOWAERS,
          A.PRICE_TYPE ,

          case when A.GR_MENGE > 0 then
                 case when A.IV1_QTY = 0 then cast('A' as abap.char(20))
                      else
                         case when A.GR_MENGE = A.IV1_QTY then cast('B' as abap.char(20))
                              else
                                  case when A.GR_MENGE > A.IV1_QTY then cast('C' as abap.char(20))
                                       else cast('D' as abap.char(20))
                                       end
                              end
                      end
               else      
                  case when A.IV1_QTY > 0 then cast('E' as abap.char(20))
                       else
                          cast('' as abap.char(20))
                       end
                      
               end as ZIVSTATUS_C,
          
          case when A.GR_MENGE > 0 then
                 case when A.IV1_QTY = 0 then cast('미정산' as abap.char(20))
                      else
                         case when A.GR_MENGE = A.IV1_QTY then cast('정산완료' as abap.char(20))
                              else
                                  case when A.GR_MENGE > A.IV1_QTY then cast('부분정산' as abap.char(20))
                                       else cast('부분미입고' as abap.char(20))
                                       end
                              end
                      end
               else      
                  case when A.IV1_QTY > 0 then cast('전체미입고' as abap.char(20))
                       else
                          cast('' as abap.char(20))
                       end
                      
               end as ZIVSTATUS,
          
          @Semantics.quantity.unitOfMeasure: 'IV1_BPRME'          
          A.IV1_QTY,
          A.IV1_BPRME,
               
          @Semantics.quantity.unitOfMeasure: 'dr_meins'                   
          A.IV_drqty,                  
               
          @Semantics.amount.currencyCode: 'IV1_WAERS'               
          A.IV1_AMOUNTY,
          A.IV1_WAERS,    

          @Semantics.amount.currencyCode: 'IV1_LC_WAERS'               
          A.IV1_AMOUNT_KRW,
          A.IV1_LC_WAERS,
               
          @Semantics.quantity.unitOfMeasure: 'IV1_BPRME'          
          A.IV2_QTY,
          A.IV2_BPRME,
          @Semantics.amount.currencyCode: 'IV1_WAERS'               
          A.IV2_AMOUNTY,
          A.IV2_WAERS,    

          @Semantics.amount.currencyCode: 'IV1_LC_WAERS'               
          A.IV2_AMOUNT_KRW,
          A.ANAME,
          B.persnumber,
          adrp.name_last ,
          NF.NES_CU,
          @Semantics.quantity.unitOfMeasure: 'BME_CU'             
          NF.VGW_CU,  //단위량(KG)
          NF.BME_CU,  //단위
          NF.VGE_CU,  //PER
          NF.MEINS_B_CU,//기본단위    
          @Semantics.quantity.unitOfMeasure: 'BME_CU'          
          NF.VGW_T_CU, //총량(KG)
                     
          
          NF.NES_AL,
          @Semantics.quantity.unitOfMeasure: 'BME_AL'             
          NF.VGW_AL,
          NF.BME_AL,
          NF.VGE_AL,
          NF.MEINS_B_AL,
          @Semantics.quantity.unitOfMeasure: 'BME_AL'          
          NF.VGW_T_AL,          
          
          
          NF.NES_FI,
          @Semantics.quantity.unitOfMeasure: 'BME_AL'             
          NF.VGW_FI,
          NF.BME_FI,
          NF.VGE_FI,
          NF.MEINS_B_FI,
          @Semantics.quantity.unitOfMeasure: 'BME_FI'          
          NF.VGW_T_FI                       
}
