@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 단가 계산식 관리'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_OEM_CAL_SCHMA 
as select from zgtmmt1110 as A inner join mara as B on A.matnr = B.matnr
                               inner join zgtmmt1111 as C on A.infnr = C.infnr and A.matnr = C.matnr and A.lifnr = C.lifnr 
                               and A.ekorg = C.ekorg and A.esokz = C.esokz and A.werks = C.werks and A.period = C.period
                               inner join t024e as T024E on A.ekorg = T024E.ekorg
association [0..*] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language
association [0..*] to lfa1 as LFA1 on $projection.lifnr = LFA1.lifnr

association [0..*] to t001w as T001W on $projection.werks = T001W.werks
association [0..*] to ZGTSD_I_MaterialCharacteristic as S1 on $projection.matnr = S1.matnr and S1.atnam = 'PD_CA_VOLTAGE'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S2 on $projection.matnr = S2.matnr and S2.atnam = 'PD_AA_STD_PRODUCT_NAME'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S3 on $projection.matnr = S3.matnr and S3.atnam = 'PD_CA_CORE_NO_1ST'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S4 on $projection.matnr = S4.matnr and S4.atnam = 'PD_CA_COND_SIZE_1ST'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S5 on $projection.matnr = S5.matnr and S5.atnam = 'PD_CA_CORE_NO_2ND'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S6 on $projection.matnr = S6.matnr and S6.atnam = 'PD_CA_COND_SIZE_2ND'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S7 on $projection.matnr = S7.matnr and S7.atnam = 'PD_CA_SPEC_NO'
association [0..*] to ZGTSD_I_MaterialCharacteristic as S8 on $projection.matnr = S8.matnr and S8.atnam = 'PD_CA_COLOR_BASE'
association [0..*] to ZGTMM_CV_GET_INFOPRICE as INFO on $projection.matnr = INFO.matnr and $projection.lifnr = INFO.lifnr and $projection.ekorg = INFO.ekorg and $projection.werks = INFO.werks and INFO.esokz = '0' and INFO.period_f <=  $projection.period and INFO.period_t >= $projection.period and INFO.EINA_LOEKZ = '' and INFO.EINE_LOEKZ = ''   
association [0..*] to ZGTMM_CV_GET_MARV_CLOSING as CL on $projection.bukrs = CL.bukrs and  $projection.period = CL.PERIOD
association [0..*] to ZGTMM_CV_GET_LMC_MONTHLY_CAL   as Z1 on Z1.BUKRS = $projection.bukrs and Z1.CMON = $projection.period
association [0..*] to ZGTMM_CV_GET_TARGET_IVSUM  as I1 on $projection.lifnr = I1.lifnr and $projection.ekorg =I1.ekorg and $projection.matnr =I1.matnr and I1.SPMON =  $projection.period and $projection.werks =I1.werks
association [0..*] to ZGTMM_CV_GET_PODATA_MON  as P1 on $projection.lifnr = P1.lifnr and $projection.ekorg =P1.ekorg and $projection.matnr = P1.matnr

{
   key  A.infnr,
   key  A.matnr,
   key  A.lifnr,
   key  A.ekorg,
   key  A.esokz,
   key  A.werks,
   key  A.period,   
        T024E.bukrs,
        case when B.zzmaktx80 <> '' then B.zzmaktx80 else makt.maktx end as MATNR_N,
        lfa1.name1 as LIFNR_N,
        t024e.ekotx as EKORG_N,
        t001w.name1 as WERKS_N,
        
        CONCAT(S1.atwrt, CONCAT(' ' ,S2.atwrt) ) as PRDNAME,
        case when S6.atwrt <> '' then concat(concat(concat(concat(concat(concat(S3.atwrt, 'X'),S4.atwrt),'+'),S5.atwrt),'X'),S6.atwrt)
             else concat(concat(S3.atwrt, 'X'),S4.atwrt) end as PRODSIZE,      
        S7.atwrt as SPEC_NO,
        S8.atwrt as COLOR,  
            
 //       @Semantics.amount.currencyCode: 'kwaers'
 //       C.cu_slmc as cu_lmc,
 //       A.cu_lmc,
        @Semantics.amount.currencyCode: 'KWAERS'          
        case when Z1.CU_lmc is not null and Z1.CU_lmc <> 0 then
              Z1.CU_lmc
           else
             cast(A.cu_lmc as abap.curr(13,2))
           end as CU_LMC,        
        
        @Semantics.amount.currencyCode: 'kwaers'
        A.scr_sc,
        A.kwaers,
        @Semantics.quantity.unitOfMeasure: 'kgmeins'
        A.cu_c_qty,
        A.al_c_spec,
        @Semantics.quantity.unitOfMeasure: 'kgmeins'
        A.al_c_qty,
        A.kgmeins,
        @Semantics.amount.currencyCode: 'kwaers'
        A.al_c_price,
        @Semantics.quantity.unitOfMeasure: 'kgmeins'
        A.cu_s_qty,
        A.al_s_spec,
        @Semantics.quantity.unitOfMeasure: 'kgmeins'
        A.al_s_qty,
        @Semantics.amount.currencyCode: 'kwaers'
        A.al_s_price,
        @Semantics.quantity.unitOfMeasure: 'kgmeins'
        A.cu_t_qty,
        @Semantics.amount.currencyCode: 'kwaers'
        A.cu_price_total,
        @Semantics.amount.currencyCode: 'kwaers'
        A.al_price_total,
        @Semantics.amount.currencyCode: 'kwaers'
        A.s_mat_cost,
        @Semantics.amount.currencyCode: 'kwaers'
        A.mfg_cost,
        @Semantics.amount.currencyCode: 'kwaers'
        A.pkg_cost,
        @Semantics.amount.currencyCode: 'kwaers'
        A.add_cost,        
        @Semantics.amount.currencyCode: 'kwaers'
        A.sub_price_total,
        @Semantics.amount.currencyCode: 'kwaers'
        A.etc_cost,
        @Semantics.amount.currencyCode: 'kwaers'
        A.oem_price,
        @Semantics.amount.currencyCode: 'kwaers'
        A.dis_price,
        A.drum_spec,
        P1.BEDAT as LAST_PO_DATE,
        
        @Semantics.quantity.unitOfMeasure: 'GRMEINS'           
        case when I1.IV_QTY is not null then I1.IV_QTY else cast(0 as abap.quan(13,2)) end as GR_QTY,
        I1.IV_UNIT as GRMEINS ,        
       
//        @Semantics.quantity.unitOfMeasure: 'GRmeins'
//        A.gr_qty,
//        A.grmeins,
       
        @Semantics.amount.currencyCode: 'kwaers'  
        case when I1.IV_QTY is not null then cast(cast(I1.IV_QTY as abap.dec(13,2))  * cast(A.oem_price as abap.dec(13,2)) as abap.curr(20,2)) else cast(0 as abap.curr(20,2)) end as ap_price,
              
        //case when A.ap_price = 0 then A.oem_price else A.ap_price end as ap_price,
        B.meins,
        
        C.fwaers,        
        C.tts,
        C.ttm,
        C.al_nes,
        @Semantics.quantity.unitOfMeasure: 'al_bme'        
        C.al_kgw,
        C.al_bme,
        @Semantics.quantity.unitOfMeasure: 'MEINS'  
        C.al_kgu,
        @Semantics.amount.currencyCode: 'al_permium_waers'  
        C.al_premium,
        C.al_permium_waers,
        C.al_crate,
        @Semantics.amount.currencyCode: 'al_mwaers'  
        C.al_mcost,
        C.al_per,
        C.al_munit,
        C.al_mwaers,
        C.al_kurst,
        @Semantics.amount.currencyCode: 'fwaers'  
        C.al_price,
        C.al_lmeper,
        C.al_meins,
        @Semantics.amount.currencyCode: 'kwaers'   
        C.al_slmc,
        C.cu_nes,
        @Semantics.quantity.unitOfMeasure: 'CU_bme'    
        C.cu_kgw,
        C.cu_bme,
        @Semantics.quantity.unitOfMeasure: 'MEINS'  
        C.cu_kgu,
        @Semantics.amount.currencyCode: 'CU_permium_waers'
        C.cu_premium,
        C.cu_permium_waers,
        C.cu_crate,
        @Semantics.amount.currencyCode: 'CU_mwaers' 
        C.cu_mcost,
        C.cu_per,
        C.cu_munit,
        C.cu_mwaers,
        C.cu_kurst,
        @Semantics.amount.currencyCode: 'fwaers' 
        case when Z1.CU_CASH is not null and Z1.CU_CASH <> 0 then
              cast(Z1.CU_CASH as abap.curr(11,2))
           else C.cu_price end as cu_price,
        C.cu_lmeper,
        C.cu_meins,
        @Semantics.amount.currencyCode: 'kwaers'  
        case when Z1.CU_lmc is not null and Z1.CU_lmc <> 0 then
              cast(Z1.CU_lmc as abap.curr(11,2))
           else C.cu_slmc end as cu_slmc,
        @Semantics.amount.currencyCode: 'KONWA'          
        INFO.kbetr,
        INFO.kpein,
        INFO.kmein,
        INFO.konwa,
        case when CL.PERIOD is not null then cast('' as abap.char(1)) else cast('X' as abap.char(1)) end as CLOSING,
        A.qirate,
        A.mtype,
        A.message,
        A.erdat,
        A.erdat_local,
        A.ertim,
        A.ertim_local,
        A.ernam,
        A.aedat,
        A.aedat_local,
        A.aetim,
        A.aetim_local,
        A.aenam,
        INFO.EINE_LOEKZ,
        case when INFO.matnr is not null then cast('' as abap.char(1)) else cast('X' as abap.char(1)) end as delinfo

} where B.lvorm = ''
