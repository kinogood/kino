@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직송의뢰 현황 조회 품목'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_DDR_REPORT_I 
as select from zgtmmt4411 as A inner join ekko as B on A.ebeln = B.ebeln
                               inner join ekpo as C on A.ebeln = C.ebeln and A.ebelp = C.ebelp
                               inner join mara as D on C.matnr = D.matnr
                               inner join zgtmmt4410 as F on A.bukrs = F.bukrs and A.dlvrq = F.dlvrq
                               left outer join ZGTMM_CV_POGR_INFO as E on A.ebeln = E.ebeln and A.ebelp = E.ebelp

association [0..1] to lfa1 as L1 on $projection.lifnr = L1.lifnr
association [0..1] to ZGTMM_CV_PO_VCVALUE_MAIN as VC1 on $projection.ebeln = VC1.PDOC and $projection.ebelp = VC1.PDOCITEM 
association [0..1] to ZGTMM_CV_GET_DDR_TRUCK_BASE as DO on $projection.bukrs = DO.bukrs and $projection.dlvrq = DO.dlvrq and $projection.vbeln = DO.vbeln and $projection.posnr = DO.posnr and $projection.ebeln = DO.ebeln and $projection.ebelp = DO.ebelp 
association [0..1] to ZGTSD_I_MaterialCharacteristic as mat1 on $projection.matnr = mat1.matnr and mat1.atnam = 'PD_CA_COLOR_STRIPE'
association [0..1] to ZGTSD_I_MaterialCharacteristic as mat2 on $projection.matnr = mat2.matnr and mat2.atnam = 'PD_CA_COLOR_STRIPE_NO'

{
 key    A.bukrs,
 key    A.dlvrq,
 key    A.vbeln,
 key    A.posnr,
 key    A.ebeln,
 key    A.ebelp,
        B.lifnr,
        L1.name1 as LIFNR_N,
        L1.name1 as vname,        
        C.matnr,
        case when D.zzmaktx80 = '' then C.txz01 else D.zzmaktx80 end as MAKTX,
        VC1.LENGTH,
        VC1.DRQTY,   
        VC1.COLOR,  
        VC1.DRUM,                                           //조장
        
        @Semantics.quantity.unitOfMeasure: 'meins'          
        C.menge,                                                      //발주량
        @Semantics.quantity.unitOfMeasure: 'meins'           
        cast(0 as abap.quan(13,3)) as MTOSTOCK,                       //보관재고량                                  
        C.meins,                 
        @Semantics.quantity.unitOfMeasure: 'dr_meins'    
        case when VC1.LENGTH is not null then cast(C.menge / cast(VC1.LENGTH as abap.dec(13,3))  as abap.quan(13,3))
             else C.menge  end as PO_DRQTY,                           //발주드럼수
        @Semantics.quantity.unitOfMeasure: 'dr_meins'                
        cast(0 as abap.quan(13,3)) as MTOSTOCKDR,                     //보관재고드럼수 
        A.dr_meins,                                                   //발주드럼단위        

        @Semantics.quantity.unitOfMeasure: 'meins'       
        case when E.MENGE is not null then E.MENGE 
        else cast(0 as abap.quan(13,3)) end as gr_MENGE,   //입고수량
        @Semantics.quantity.unitOfMeasure: 'dr_meins'  
        case when VC1.LENGTH is not null then 
             case when E.MENGE is not null then E.MENGE / cast(VC1.LENGTH as abap.dec(13,3))
                  else cast(0 as abap.quan(13,3)) end
             else 
             case when E.MENGE is not null then E.MENGE 
                  else cast(0 as abap.quan(13,3)) end 
        end as GR_DRQTY,  //입고 드럼수     
                
        @Semantics.quantity.unitOfMeasure: 'meins'    
        case when E.MENGE is not null then C.menge - E.MENGE 
             else C.menge end as NGR_MENGE,   //미입고 잔량
        case when E.MENGE is not null then
             case when VC1.LENGTH is not null then (C.menge-E.MENGE) / cast(VC1.LENGTH as abap.dec(13,3))
                  else C.menge-E.MENGE end
             else
                  cast(0 as abap.quan(13,3)) 
             end  as NGR_DRQTY,  //미입고 드럼수        
                
        @Semantics.quantity.unitOfMeasure: 'dr_meins'   
        A.req_drqty,
        A.zmm_stat,
        A.zmm_date,
        @Semantics.quantity.unitOfMeasure: 'dr_meins'
        case when A.zmm_stat = 'A' then A.req_drqty else cast(0 as abap.quan(13,3)) end as zmm_drqty,
        A.zvd_stat,
        A.zvd_date,
        @Semantics.quantity.unitOfMeasure: 'dr_meins'
        case when A.zvd_stat = 'A' then A.req_drqty else cast(0 as abap.quan(13,3)) end as zVD_drqty,        
        cast('' as abap.dats) as PROD_DATE,
        cast('' as abap.char(1)) as ZINSPTYPE,
        cast('' as abap.dats) as ZINSPDATE,
        cast('' as abap.char(1)) as ZINSPRES,
        cast('' as abap.dats) as ZQMDATE,
                     
        case when A.zmm_stat = '' then cast('직송의뢰' as abap.char(20))
             when A.zmm_stat = 'A' then
                  case when A.zvd_stat = '' then cast('구매접수' as abap.char(20))
                       when A.zvd_stat = 'A' then cast('업체접수' as abap.char(20))
                  end
             end as ZSTATUS,
        @Semantics.quantity.unitOfMeasure: 'dr_meins'
        case when DO.LOADQTY is not null then DO.LOADQTY else cast(0 as abap.quan(13,3)) end as LOADQTY ,    
        case when DO.LOADQTY is not null then
             case when DO.LOADQTY > 0 then cast('A' as abap.char(1))
                                      else cast('' as abap.char(1)) end
             else cast('' as abap.char(1)) end as LOADSTATUS ,           

        A.rej_code,
        A.aedat,
        A.aedat_local,
        A.aetim,
        A.aetim_local,
        A.aenam,
        case when mat1.atwrt is not null then mat1.atwrt else cast('' as atwrt ) end as st_color,
        case when mat2.atwrt is not null then mat2.atwrt else cast('' as atwrt ) end as st_color_no   
} where F.zsd_stat = 'R'

union all

select from zgtmmt4412 as A inner join vbap as B on A.vbeln = B.vbeln and A.posnr = B.posnr
                            inner join ZGTMM_CV_GET_OEM_STOCK  as C on B.matnr = C.matnr and B.werks = C.werks and B.vbeln = C.vbeln and B.posnr = C.posnr
                          //  inner join mch1 as D on C.matnr = D.matnr and C.charg = D.charg
                            inner join mara as E on C.matnr = E.matnr
                            inner join zgtmmt4410 as F on A.bukrs = F.bukrs and A.dlvrq = F.dlvrq

association [0..1] to lfa1 as L1 on $projection.lifnr = L1.lifnr
association [0..1] to ZGTMM_CV_SO_VCVALUE_MAIN  as VC1 on $projection.vbeln = VC1.vbeln and $projection.posnr = VC1.posnr
association [0..1] to ZGTMM_CV_GET_DDR_TRUCK_BASE as DO on $projection.bukrs = DO.bukrs and $projection.dlvrq = DO.dlvrq and $projection.vbeln = DO.vbeln and $projection.posnr = DO.posnr and DO.ebeln = ''
association [0..1] to ZGTSD_I_MaterialCharacteristic as mat1 on $projection.matnr = mat1.matnr and mat1.atnam = 'PD_CA_COLOR_STRIPE'
association [0..1] to ZGTSD_I_MaterialCharacteristic as mat2 on $projection.matnr = mat2.matnr and mat2.atnam = 'PD_CA_COLOR_STRIPE_NO'

{
 key    A.bukrs,
 key    A.dlvrq,
 key    A.vbeln,
 key    A.posnr,
 key    cast('' as ebeln) as EBELN,
 key    cast('' as ebelp) as ebelp,
        C.lifnr,
        L1.name1 as LIFNR_N,
        L1.name1 as vname,        
        C.matnr,
        case when E.zzmaktx80 = '' then B.arktx else E.zzmaktx80 end as MAKTX,

        VC1.LENGTH,
        VC1.DRQTY,   
        VC1.COLOR,  
        VC1.DRUM,       
        
        cast(0 as abap.quan(13,3)) as menge,                          //발주량             
        C.STOCK as MTOSTOCK,                                          //보관재고량
        E.meins,                 
        cast(0 as abap.quan(13,3)) as PO_DRQTY,                           //발주드럼수
        case when VC1.LENGTH is not null then cast(C.STOCK / cast(VC1.LENGTH as abap.dec(13,3)) as abap.quan(13,3))
             else C.STOCK  end as MTOSTOCKDR,                     //보관재고드럼수              
        A.dr_meins,                                                   //발주드럼단위        

        cast(0 as abap.quan(13,3)) as gr_MENGE,  //입고수량
        cast(0 as abap.quan(13,3)) as GR_DRQTY,  //입고 드럼수     
                
        cast(0 as abap.quan(13,3)) as NGR_MENGE,   //미입고 잔량
        cast(0 as abap.quan(13,3))  as NGR_DRQTY,  //미입고 드럼수        
                
        A.req_drqty,
        A.zmm_stat,
        A.zmm_date,
        case when A.zmm_stat = 'A' then A.req_drqty else cast(0 as abap.quan(13,3)) end as zmm_drqty,
        A.zvd_stat,
        A.zvd_date,
        case when A.zvd_stat = 'A' then A.req_drqty else cast(0 as abap.quan(13,3)) end as zVD_drqty,      
        cast('' as abap.dats) as PROD_DATE,
        cast('' as abap.char(1)) as ZINSPTYPE,
        cast('' as abap.dats) as ZINSPDATE,
        cast('' as abap.char(1)) as ZINSPRES,
        cast('' as abap.dats) as ZQMDATE,
                     
        case when A.zmm_stat = '' then cast('직송의뢰' as abap.char(20))
             when A.zmm_stat = 'A' then
                  case when A.zvd_stat = '' then cast('구매접수' as abap.char(20))
                       when A.zvd_stat = 'A' then cast('업체접수' as abap.char(20))
                  end
             end as ZSTATUS,
        case when DO.LOADQTY is not null then DO.LOADQTY else cast(0 as abap.quan(13,3)) end as LOADQTY ,
        case when DO.LOADQTY is not null then
             case when DO.LOADQTY > 0 then cast('A' as abap.char(1))
                                      else cast('' as abap.char(1)) end
             else cast('' as abap.char(1)) end as LOADSTATUS ,              
/*        cast('' as abap.char(1)) as zdoc_stat,
        cast('' as abap.char(10)) as zdoc_no,

        cast('' as abap.dats) as zdoc_date,
        cast('' as abap.char(1)) as  zdoc_trtype,
        cast('' as abap.char(1)) as zle_stat,
        cast('' as abap.dats) as zle_date,
        cast('' as abap.numc(2)) as ztruck_qty,*/
        A.rej_code,
//        A.zpp_stat,
//        A.zpp_date,
        A.aedat,
        A.aedat_local,
        A.aetim,
        A.aetim_local,
        A.aenam   ,
        case when mat1.atwrt is not null then mat1.atwrt else cast('' as atwrt ) end as st_color,
        case when mat2.atwrt is not null then mat2.atwrt else cast('' as atwrt ) end as st_color_no 
} where  C.lgort = '3497' and  F.zsd_stat = 'R'
