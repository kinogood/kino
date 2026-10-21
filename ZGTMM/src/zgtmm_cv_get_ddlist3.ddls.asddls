@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직송의뢰정보(HEADER+ITEM)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_DDLIST3 
as 
select from zgtmmt4410 as A inner join zgtmmt4411 as B  on A.bukrs = B.bukrs and A.dlvrq = B.dlvrq 
                            inner join ekpo as C on B.ebeln = C.ebeln and B.ebelp = C.ebelp
                            inner join t001w as D on C.werks = D.werks
                            inner join j_1bbranch as E on D.j_1bbranch = E.branch
                            inner join t001 as F on A.bukrs = F.bukrs
                            inner join adrc as G on F.adrnr = G.addrnumber
                            inner join vbap as H on B.vbeln = H.vbeln and B.posnr = H.posnr
                            inner join tvst as I on H.vstel = I.vstel
                            inner join adrc as J on I.adrnr = J.addrnumber
                            inner join kna1 as K on A.kunnr = K.kunnr     
                            inner join adrc as L on K.adrnr = L.addrnumber          
                            inner join ZGTMM_CV_GET_SALES_TEAM  as M on B.vbeln = M.vbeln    
                            inner join ekko as N on C.ebeln = N.ebeln
                            inner join zlet0400 as le on B.dlvrq = le.dlvrq
                            
{
  key   A.bukrs,
  key   A.werks,
  key   A.zreq_type,
  key   A.dlvrq,
  key   B.vbeln,
  key   B.posnr,
  key   B.ebeln,
  key   B.ebelp,      
        N.lifnr,  
        C.matnr,
        C.txz01,
        @Semantics.quantity.unitOfMeasure: 'meins'            
        C.menge,
        C.meins,
        A.vkbur,
        A.vkgrp,
        A.kunnr,
        A.reqdate,
        A.ar_date,
        A.ar_time,
        A.bland,
        A.city1,
        A.dest1,
        A.site_name,
        A.site_tel,
        A.cust_name,
        A.cust_tel,
        A.dest2,
        A.sp_note,
        A.zsd_stat,
 //       cast('' as abap.char(1)) as zle_stat,
 //       cast('' as abap.numc(2)) as ztruck_qty,
 //       cast('' as abap.char(1)) as zdoc_stat,
        
 //       cast('' as abap.char(10)) as zdoc_no,
 //       B.zdoc_no,
//        cast('' as abap.dats) as zdoc_date,
//        cast('' as abap.char(1)) as zdoc_trtype,
        A.zdesc,
        @Semantics.quantity.unitOfMeasure: 'dr_meins' 
        B.req_drqty,
        B.dr_meins,
        B.zmm_stat,
        @Semantics.quantity.unitOfMeasure: 'dr_meins'         
        case when B.zmm_stat = 'A' then B.req_drqty else cast(0 as abap.quan(13,3)) end as zmm_drqty,
        B.zmm_date,
        B.zvd_stat,
        @Semantics.quantity.unitOfMeasure: 'dr_meins'      

        case when B.zvd_stat = 'A' then B.req_drqty else cast(0 as abap.quan(13,3)) end as zVD_drqty,           

        B.zvd_date,
        B.zvd_time,        
        B.per_name,
        B.rej_code,
//        B.zpp_stat,
        A.pernr,
        A.name,
        A.email,
        A.per_tel,
        A.erdat,
        A.erdat_local,
        A.ertim,
        A.ertim_local,
        A.ernam,
        B.aedat,
        B.aedat_local,
        B.aetim,
        B.aetim_local,
        B.aenam,
        //세금계산서 발행 용 정보
        E.stcd2 as GO_STCD2,  //공급자등록번호
        F.butxt as GO_BUTXT,  //공급자상호
        CONCAT(CONCAT(G.city1,' '),G.street) as GO_ADDRESS,
        CONCAT('TEL)',  CONCAT(J.tel_number,CONCAT(' ', CONCAT('FAX)',J.fax_number) ))) as GO_TEL,
        K.stcd2 as CU_STCD2,
        A.cust_name as CU_BUTXT,
        CONCAT(CONCAT(L.city1,' '),L.street) as CU_ADDRESS,       
        M.zzyuscd as TEAM2DGIT,
        case when B.vbeln <> '' then cast('O' as abap.char(1)) 
                                else cast('S' as abap.char(1)) end as MTOYN,
        cast('' as abap.char(10)) as PACK_GUBUN,
        @Semantics.quantity.unitOfMeasure: 'meins'             
        cast(0 as labst) as kalab,
        A.drdat,
        le.trtyp
} where G.nation = '' and M.zzyuscd <> '' and A.zsd_stat = 'R' 


union all

select from zgtmmt4410 as A inner join zgtmmt4412 as B  on A.bukrs = B.bukrs and A.dlvrq = B.dlvrq 
                            inner join vbap as H on B.vbeln = H.vbeln and B.posnr = H.posnr
                            inner join t001w as D on H.werks = D.werks
                            inner join j_1bbranch as E on D.j_1bbranch = E.branch
                            inner join t001 as F on A.bukrs = F.bukrs
                            inner join adrc as G on F.adrnr = G.addrnumber
                            inner join tvst as I on H.vstel = I.vstel
                            inner join adrc as J on I.adrnr = J.addrnumber
                            inner join kna1 as K on A.kunnr = K.kunnr     
                            inner join adrc as L on K.adrnr = L.addrnumber          
                            inner join ZGTMM_CV_GET_SALES_TEAM  as M on B.vbeln = M.vbeln    
                            inner join ZGTMM_CV_GET_OEM_STOCK as N on H.werks = N.werks and H.matnr = N.matnr and H.vbeln = N.vbeln and H.posnr = N.posnr
                            inner join mara as o on H.matnr = o.matnr
                            inner join zlet0400 as le on B.dlvrq = le.dlvrq
                      //      inner join mch1 as O on N.matnr = O.matnr and  N.charg = O.charg
                            
                            
{
  key   A.bukrs,
  key   A.werks,
  key   A.zreq_type,
  key   A.dlvrq,
  key   B.vbeln,
  key   B.posnr,
  key   cast('' as ebeln) as ebeln,
  key   cast('' as ebelp) as ebelp,        
        N.lifnr,
        H.matnr,
        H.arktx as TXZ01,
        cast(0 as ktmng) as MENGE,
        o.meins,
        A.vkbur,
        A.vkgrp,
        A.kunnr,
        A.reqdate,
        A.ar_date,
        A.ar_time,
        A.bland,
        A.city1,
        A.dest1,
        A.site_name,
        A.site_tel,
        A.cust_name,
        A.cust_tel,
        A.dest2,
        A.sp_note,
        A.zsd_stat,
//        cast('' as abap.char(1)) as zle_stat,
//        cast('' as abap.numc(2)) as ztruck_qty,
//        cast('' as abap.char(1)) as zdoc_stat,

//        cast('' as abap.char(10)) as zdoc_no,        
//       B.zdoc_no,
//        cast('' as abap.dats) as zdoc_date,
//        cast('' as abap.char(1)) as zdoc_trtype,
        A.zdesc,
        B.req_drqty,
        B.dr_meins,
        B.zmm_stat,
        case when B.zmm_stat = 'A' then B.req_drqty else cast(0 as abap.quan(13,3)) end as zmm_drqty,
        B.zmm_date,
        B.zvd_stat,
        case when B.zvd_stat = 'A' then B.req_drqty else cast(0 as abap.quan(13,3)) end as zVD_drqty,   
        B.zvd_date,
        B.zvd_time,        
        B.per_name,
        B.rej_code,
//        B.zpp_stat,
        A.pernr,
        A.name,
        A.email,
        A.per_tel,
        A.erdat,
        A.erdat_local,
        A.ertim,
        A.ertim_local,
        A.ernam,
        B.aedat,
        B.aedat_local,
        B.aetim,
        B.aetim_local,
        B.aenam,
        //세금계산서 발행 용 정보
        E.stcd2 as GO_STCD2,  //공급자등록번호
        F.butxt as GO_BUTXT,  //공급자상호
        CONCAT(CONCAT(G.city1,' '),G.street) as GO_ADDRESS,
        CONCAT('TEL)',  CONCAT(J.tel_number,CONCAT(' ', CONCAT('FAX)',J.fax_number) ))) as GO_TEL,
        K.stcd2 as CU_STCD2,
        A.cust_name as CU_BUTXT,
        CONCAT(CONCAT(L.city1,' '),L.street) as CU_ADDRESS,       
        M.zzyuscd as TEAM2DGIT,
        case when B.vbeln <> '' then cast('O' as abap.char(1)) 
                                else cast('S' as abap.char(1)) end as MTOYN,
        cast('' as abap.char(10)) as PACK_GUBUN,
        N.STOCK as kalab,
        A.drdat,
        le.trtyp

} where G.nation = '' and N.lgort = '3497' and M.zzyuscd <> '' and A.zsd_stat = 'R'
