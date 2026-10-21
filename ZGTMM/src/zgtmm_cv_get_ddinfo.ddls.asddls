@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직송 의뢰 및 진행 상태 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_DDINFO 
as select from ZGTMM_CV_GET_DDLIST3  as a 
                               inner join vbap as e on e.vbeln = a.vbeln and e.posnr = a.posnr
                               inner join vbak as f on e.vbeln = f.vbeln 
                               inner join mara as I on e.matnr = I.matnr
                               left outer join ZGTMM_CV_POGR_INFO as g on a.ebeln = g.ebeln and a.ebelp = g.ebelp

association [0..1] to tvkbt as TVKBT on $projection.vkbur = TVKBT.vkbur and TVKBT.spras = $session.system_language
association [0..1] to tvgrt as TVGRT on $projection.vkgrp = TVGRT.vkgrp and TVGRT.spras = $session.system_language
association [0..1] to lfa1 as lfa1 on $projection.lifnr = lfa1.lifnr
association [0..1] to kna1 as kna1 on $projection.kunnr = kna1.kunnr
association [0..1] to ZGTMM_CV_PO_VCVALUE_MAIN as ch1 on $projection.ebeln = ch1.PDOC and $projection.ebelp = ch1.PDOCITEM 
association [0..1] to ZGTMM_CV_SO_VCVALUE_MAIN as ch3 on $projection.vbeln = ch3.vbeln and $projection.posnr = ch3.posnr 

association [0..1] to dd07t as DD1 on $projection.zreq_type = DD1.domvalue_l and DD1.domname = 'ZGTD_REQTYPE' and DD1.ddlanguage = $session.system_language
association [0..1] to dd07t as DD2 on $projection.zsd_stat = DD2.domvalue_l and DD2.domname = 'ZGTD_REQSTAT' and DD2.ddlanguage = $session.system_language
association [0..1] to dd07t as DD3 on $projection.zmm_stat = DD3.domvalue_l and DD3.domname = 'ZGTD_REQSTATP' and DD3.ddlanguage = $session.system_language
association [0..1] to dd07t as DD4 on $projection.zvd_stat = DD4.domvalue_l and DD4.domname = 'ZGTD_REQSTATV' and DD4.ddlanguage = $session.system_language
//association [0..1] to dd07t as DD8 on $projection.zqm_stat = DD8.domvalue_l and DD8.domname = 'ZGTD_REQSTAT2' and DD8.ddlanguage = $session.system_language
association [0..1] to t005u as T005U on $projection.bland = T005U.bland and T005U.spras = $session.system_language and T005U.land1 = 'KR'
association [0..1] to t001w as T001W on $projection.werks = T001W.werks 
association [0..1] to eket as EKET on $projection.ebeln = EKET.ebeln and $projection.ebelp = EKET.ebelp and EKET.etenr = '0001'

association [0..1] to ZGTMM_CV_GET_ZGTMMT4411_SUM  as J
                   on $projection.bukrs = J.bukrs and $projection.ebeln = J.ebeln and $projection.ebelp = J.ebelp        
                   and $projection.vbeln = J.vbeln and $projection.posnr = J.posnr                      
association [0..1] to ZGTMM_CV_GET_ZGTMMT4412_SUM  as K
                   on $projection.bukrs = K.bukrs and $projection.vbeln = K.vbeln and $projection.posnr = K.posnr     
association [0..1] to ZGTMM_CV_GET_NFWEIGHT_PLANT as PNF1 on $projection.matnr = PNF1.matnr and $projection.werks = PNF1.werks  and (PNF1.nes = 'CU')
association [0..1] to ZGTMM_CV_GET_NFWEIGHT_PLANT as PNF2 on $projection.matnr = PNF2.matnr and $projection.werks = PNF2.werks  and (PNF2.nes = 'FI')

association [0..1] to ZGTSD_I_MaterialCharacteristic as mat1 on $projection.matnr = mat1.matnr and mat1.atnam = 'PD_CA_COLOR_STRIPE'       // 띠줄색상
association [0..1] to ZGTSD_I_MaterialCharacteristic as mat2 on $projection.matnr = mat2.matnr and mat2.atnam = 'PD_CA_COLOR_STRIPE_NO'    // 띠줄개수
{
  key   a.bukrs,
  key   a.zreq_type,
  key   DD1.ddtext as zreq_name,
  key   a.dlvrq,
        a.werks,
        t001w.name1 as WERKS_N,
        a.vkbur,
        tvkbt.bezei as vkbur_n,
        a.vkgrp,
        tvgrt.bezei as vkgrp_n,
        a.vbeln,
        a.posnr,
        a.ebeln,
        a.ebelp,
        a.reqdate,
        eket.eindt,
        a.lifnr,
        lfa1.name1 as vname,
        f.kunnr,
        kna1.name1 as cname,
        a.matnr,
        case when I.zzmaktx80 <> '' then I.zzmaktx80
             else a.txz01 end as maktx,
        case when a.zreq_type = 'A' then     
             ch1.COLOR                                          //색상
             else
             ch3.COLOR 
             end as color,
        case when a.zreq_type = 'A' then                 
             ch1.LENGTH 
             else
             ch3.LENGTH
             end as length,                                          //조장
        @Semantics.quantity.unitOfMeasure: 'meins'          
        a.menge,                                                      //발주량
        a.meins,                                                      //발주단위          
        @Semantics.quantity.unitOfMeasure: 'dr_meins'    
        a.menge / cast(ch1.LENGTH as abap.dec(13,3)) as PO_DRQTY,      //발주드럼수
        a.dr_meins,                                                   //발주드럼단위
        @Semantics.quantity.unitOfMeasure: 'meins'   
        a.kalab,                                                      //보관재고량
        @Semantics.quantity.unitOfMeasure: 'dr_meins'           
        a.kalab  / cast(ch3.LENGTH as abap.dec(13,3)) as STOCK_DRQTY,  //보관재고드럼수

        @Semantics.quantity.unitOfMeasure: 'meins'        
        cast(a.req_drqty * cast(ch1.LENGTH as abap.dec(13,3)) as abap.quan(13,3)) as REQ_MENGE,   //직송요청수량(M)
                
        @Semantics.quantity.unitOfMeasure: 'dr_meins'    
        a.req_drqty,                                                    //직송요청드럼수 

        @Semantics.quantity.unitOfMeasure: 'meins'        
        g.MENGE as gr_MENGE,   //입고수량
        @Semantics.quantity.unitOfMeasure: 'dr_meins'  
        cast(g.MENGE / cast(ch1.LENGTH as abap.dec(13,3)) as abap.quan(13,3)) as GR_DRQTY,  //입고 드럼수              

        @Semantics.quantity.unitOfMeasure: 'meins'    
        a.menge - g.MENGE as NGR_MENGE,   //미입고 잔량
        
        @Semantics.quantity.unitOfMeasure: 'dr_meins'      
        case when g.MENGE is not null then    
             cast((a.menge - g.MENGE) / cast(ch1.LENGTH as abap.dec(13,3)) as abap.quan(13,3)) 
             else      
             cast(a.menge  / cast(ch1.LENGTH as abap.dec(13,3)) as abap.quan(13,3))
             end as NGR_DRQTY,  //미입고 드럼수          
             
       @Semantics.quantity.unitOfMeasure: 'dr_meins'               
   /*    case when a.zreq_type = 'A' then       
       
        case when J.REQ_DRQTYSUM is not null 
             then
              case when g.MENGE is not null then 
                   //미입고 드럼수 - (입고 안된 전체 직송 요청 수 - 해당 요청의 직송 요청 수)
                   cast(((a.menge - g.MENGE) / cast(ch1.LENGTH as abap.dec(13,3))) - ( J.REQ_DRQTYSUM - a.req_drqty ) as abap.quan(13,3))
                   else
                   cast((a.menge  / cast(ch1.LENGTH as abap.dec(13,3))) - ( J.REQ_DRQTYSUM - a.req_drqty ) as abap.quan(13,3))
                   end 
             else  //미입고 드럼수 -  해당 요청의 직송 요청 수
               case when g.MENGE is not null then 
                   cast(((a.menge - g.MENGE) / cast(ch1.LENGTH as abap.dec(13,3))) -  a.req_drqty  as abap.quan(13,3))
                   else
                   cast((a.menge  / cast(ch1.LENGTH as abap.dec(13,3))) -  a.req_drqty  as abap.quan(13,3))
                   end       
             end  
           else
             case when K.REQ_DRQTYSUM is not null 
             then
                   //현 재고 드럼수 - 입고 안된 전체 직송 요청 수
                cast((a.kalab  / cast(ch3.LENGTH as abap.dec(13,3))) - K.REQ_DRQTYSUM  as abap.quan(13,3))
             else  //현 재고 드럼수
               cast((a.kalab  / cast(ch3.LENGTH as abap.dec(13,3)))  as abap.quan(13,3))    
             end          
           end as ANO_QTY_A,*/
           
    case when a.zreq_type = 'A' then       
       
        case when J.REQ_DRQTYSUM is not null 
             then
              case when g.MENGE is not null then 
                   //미입고 드럼수 - (전체 직송 요청 수 - 입고 수) - 해당 요청의 직송 요청 수)
                   cast(((a.menge - g.MENGE) / cast(ch1.LENGTH as abap.dec(13,3))) - ((J.REQ_DRQTYSUM - (g.MENGE / cast(ch1.LENGTH as abap.dec(13,3)))) - a.req_drqty ) as abap.quan(13,3))
                   else
                   cast((a.menge  / cast(ch1.LENGTH as abap.dec(13,3))) - ( J.REQ_DRQTYSUM - a.req_drqty ) as abap.quan(13,3))
                   end 
             else  //미입고 드럼수 -  해당 요청의 직송 요청 수
               case when g.MENGE is not null then 
                   cast(((a.menge - g.MENGE) / cast(ch1.LENGTH as abap.dec(13,3))) -  a.req_drqty  as abap.quan(13,3))
                   else
                   cast((a.menge  / cast(ch1.LENGTH as abap.dec(13,3))) -  a.req_drqty  as abap.quan(13,3))
                   end       
             end  
           else
             case when K.REQ_DRQTYSUM is not null 
             then
                   //현 재고 드럼수 - 입고 안된 전체 직송 요청 수
                cast((a.kalab  / cast(ch3.LENGTH as abap.dec(13,3))) - K.REQ_DRQTYSUM  as abap.quan(13,3))
             else  //현 재고 드럼수
               cast((a.kalab  / cast(ch3.LENGTH as abap.dec(13,3)))  as abap.quan(13,3))    
             end          
           end as ANO_QTY_A,           
         
        @Semantics.quantity.unitOfMeasure: 'dr_meins'   
      case when a.zreq_type = 'A' then                 
        case when J.REQ_DRQTYSUM is not null 
             then
              case when g.MENGE is not null then
                   //미입고 드럼수 - 입고 안된 전체 직송 요청 수 
              cast(((a.menge - g.MENGE) / cast(ch1.LENGTH as abap.dec(13,3))) - (J.REQ_DRQTYSUM - (g.MENGE / cast(ch1.LENGTH as abap.dec(13,3))))  as abap.quan(13,3))
              else
              cast((a.menge / cast(ch1.LENGTH as abap.dec(13,3))) - J.REQ_DRQTYSUM  as abap.quan(13,3))
              end 
             else  //미입고 드럼수 
              case when g.MENGE is not null then 
              cast(((a.menge - g.MENGE) / cast(ch1.LENGTH as abap.dec(13,3)))  as abap.quan(13,3))
              else
              cast((a.menge  / cast(ch1.LENGTH as abap.dec(13,3)))  as abap.quan(13,3))
              end       
             end  
         else    
         case when K.REQ_DRQTYSUM is not null 
             then
                   //현 재고 드럼수 - 입고 안된 전체 직송 요청 수
              cast((a.kalab  / cast(ch3.LENGTH as abap.dec(13,3))) - K.REQ_DRQTYSUM  as abap.quan(13,3))
             else  //현 재고 드럼수
             cast((a.kalab  / cast(ch3.LENGTH as abap.dec(13,3)))  as abap.quan(13,3))    
             end  
             
         end    as REMAIN_QTY_A,
               
 /*       @Semantics.quantity.unitOfMeasure: 'dr_meins'     
        case when a.zreq_type = 'B' then    
            case when K.REQ_DRQTYSUM is not null 
                 then
                       //현 재고 드럼수 - (입고 안된 전체 직송 요청 수 - 해당 요청의 직송 요청 수)
                  cast((a.kalab  / cast(ch4.VALUE as abap.dec(13,3))) - (K.REQ_DRQTYSUM - a.req_drqty) as abap.quan(13,3))
                 else  //현 재고 드럼수 -  해당 요청의 직송 요청 수
                 cast((a.kalab  / cast(ch4.VALUE as abap.dec(13,3))) - a.req_drqty as abap.quan(13,3))    
                 end         
        else
            cast(0 as abap.quan(13,3))
        end as ANO_QTY_B, */
        
/*        @Semantics.quantity.unitOfMeasure: 'dr_meins'       
        case when a.zreq_type = 'B' then              
        case when K.REQ_DRQTYSUM is not null 
             then
                   //현 재고 드럼수 - 입고 안된 전체 직송 요청 수
              cast((a.kalab  / cast(ch4.VALUE as abap.dec(13,3))) - K.REQ_DRQTYSUM  as abap.quan(13,3))
             else  //현 재고 드럼수
             cast((a.kalab  / cast(ch4.VALUE as abap.dec(13,3)))  as abap.quan(13,3))    
             end  
        else
            cast(0 as abap.quan(13,3))        
        end as REMAIN_QTY_B,           */
        cast('' as abap.char(1)) as ZCHECK, 
        a.ar_date,
        case when a.ar_time = '000000' then cast('000000' as abap.tims(6)) else a.ar_time end as ar_time,
        
        a.bland,
        t005u.bezei as BLAND_N,
        
        a.dest1,
        a.city1,
        
        a.site_name,
        a.site_tel,
        a.cust_name,
        a.cust_tel,
       
        a.dest2,
        a.sp_note,
        a.pernr,
        a.name,
        a.email,
        cast('00000000' as abap.dats(8)) as PROD_DATE,
        cast('' as abap.char(1)) as ZINSPTYPE,
        cast('00000000' as abap.dats(8)) as ZINSPDATE,
        cast('' as abap.char(1)) as ZINSPRES,             
        a.zsd_stat,
        DD2.ddtext as zsd_stat_n,
        a.zmm_stat,
     //   case when J.zmm_stat is not null then J.zmm_stat
     //        else cast('' as zgte_reqstatp) end as zmm_stat,
     //   a.zmm_stat,
        DD3.ddtext as zmm_stat_n,
        @Semantics.quantity.unitOfMeasure: 'dr_meins'         
        a.zmm_drqty,
        a.zmm_date,
        cast('' as abap.char(1)) as zqm_stat ,
        cast('' as abap.char(80)) as zQM_stat_n,
        case when a.zvd_stat = '' then cast('W' as abap.char(1))
             else  a.zvd_stat end as zvd_stat,
        //a.zvd_stat,
        
        case a.zvd_stat  when '' then  cast('대기' as abap.char(60))
                         when 'R' then  cast('반려' as abap.char(60))
                         when 'A' then  cast('접수' as abap.char(60))
                         end as zvd_stat_n,
        @Semantics.quantity.unitOfMeasure: 'dr_meins'         
        a.zVD_drqty,
        a.zvd_date,
        a.zvd_time,
 //       case when a.zvd_date = '00000000' then cast('' as abap.dats(8)) else a.zvd_date end as zvd_date,
 //       case when a.zvd_time = '000000' then cast('' as abap.tims(6)) else a.zvd_time end as zvd_time,
        a.per_name,
//        a.zle_stat,
//        a.zdoc_stat,
//        a.zdoc_no,
//        a.zdoc_date,
  //      case when a.zdoc_date = '00000000' then cast('' as abap.dats(8)) else a.zdoc_date end as zdoc_date,

 //       a.zdoc_trtype,
 //       a.zpp_stat,
 /*       case when J.rej_code is not null then J.rej_code
            else cast('' as abap.char(200)) end as rej_code,        */
        a.rej_code,
        a.rej_code as REJ_CODE_N,
    //    cast('' as abap.char(60)) as REJ_CODE_N,
        a.zdesc,
        cast('' as guid_32) as ZGUID, 
        cast(0 as abap.char(100)) as DRUM_NO,
        cast(0 as abap.dec(10,1)) as PLAN_DIA,
        cast(0 as abap.dec(10,1)) as OUTN_WID,
        @Semantics.quantity.unitOfMeasure: 'GEWEI'   
        cast(a.req_drqty * cast(ch1.LENGTH as abap.dec(8,2)) * I.brgew as abap.quan(13,3)) as brgew,
        @Semantics.quantity.unitOfMeasure: 'GEWEI'      
        cast(a.req_drqty * cast(ch1.LENGTH as abap.dec(8,2)) * I.ntgew as abap.quan(13,3)) as ntgew,     
        I.gewei,
        a.erdat,
        a.erdat_local,
        a.ertim,
        a.ertim_local,
        a.ernam,
        a.aedat,
        a.aedat_local,
        a.aetim,
        a.aetim_local,
        a.aenam,
 
//세금계산서용 필드        
        a.GO_STCD2,  //공급자등록번호
        a.GO_BUTXT,  //공급자상호
        a.GO_ADDRESS,
        a.GO_TEL,
        a.CU_STCD2,
        a.CU_BUTXT,
        a.CU_ADDRESS,       
        a.TEAM2DGIT as TEM2DGIT,
        a.MTOYN,
        a.PACK_GUBUN,
   
       @Semantics.quantity.unitOfMeasure: 'BME_CU'             
       case when PNF1.Vgw is not null then PNF1.Vgw else cast(0 as /nfm/vgw) end as VGW_CU,
       case when PNF1.bme is not null then PNF1.bme else cast('' as unit) end as BME_CU,
       case when PNF1.vge is not null then PNF1.vge else cast(1 as /nfm/vge) end as VGE_CU,
       case when PNF1.meins is not null then PNF1.meins else cast('' as unit) end as MEINS_CU,        
       @Semantics.quantity.unitOfMeasure: 'BME_FI'             
       case when PNF2.Vgw is not null then PNF2.Vgw else cast(0 as /nfm/vgw) end as VGW_FI,
       case when PNF2.bme is not null then PNF2.bme else cast('' as unit) end as BME_FI,
       case when PNF2.vge is not null then PNF2.vge else cast(1 as /nfm/vge) end as VGE_FI,
       case when PNF2.meins is not null then PNF2.meins else cast('' as unit) end as MEINS_FI,
       a.drdat,
       a.trtyp,
       //a.zmm_check    
       case when mat1.atwrt is not null then mat1.atwrt else cast('' as atwrt ) end as STRIPE,        // 띠줄색상
       case when mat2.atwrt is not null then mat2.atwrt else cast('' as atwrt ) end as STRIPE_NO      // 띠줄개수         
        
}
