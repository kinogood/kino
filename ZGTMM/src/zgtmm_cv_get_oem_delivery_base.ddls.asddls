@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 직송 납품 정보 기초 데이터 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_OEM_DELIVERY_BASE 
as select from ZGTMM_CV_GET_DDINFO as A left outer join ZGTMM_CV_GET_OEM_DELIVER_BASE2   as B on A.bukrs = B.bukrs and A.zreq_type = B.zreq_type
                                                                   and     A.dlvrq = B.dlvrq and A.vbeln = B.vbeln
                                                                   and     A.posnr = B.posnr and A.ebeln = B.ebeln
                                                                   and     A.ebelp = B.ebelp
{
  key   A.bukrs,                 //회사코드
  key   A.dlvrq,                 //출하지시번호
        A.werks,                 //플랜트
        A.WERKS_N,               //플랜트명
        A.vkbur,                 //영업팀
        A.vkbur_n,               //영업팀명
        A.vkgrp,                 //영업그룹
        A.vkgrp_n,               //영업그룹명
        A.vbeln,                //판매오더
        A.posnr,                //항번
        A.ebeln,                //구매오더
        A.ebelp,                //항번
        A.reqdate,              //직송요청일
        A.eindt,                //PO납품예정일
        A.lifnr,                //공급업체
        A.vname,                //공급업체명
        A.kunnr,                //고객
        A.cname,                //고객명
        A.matnr,                //OEM제품
        A.maktx,                //품명
        A.color,                //색상
        A.length,               //조장
        A.meins,                //발주단위      
        A.dr_meins,             //발주드럼단위
 /*     @Semantics.quantity.unitOfMeasure: 'meins'          
        A.menge,                //발주량(M)
     
        @Semantics.quantity.unitOfMeasure: 'dr_meins'    
        A.PO_DRQTY,             //발주량(DR)

        @Semantics.quantity.unitOfMeasure: 'meins'   
        A.kalab,                //보관재고량(M)
        @Semantics.quantity.unitOfMeasure: 'dr_meins'           
        A.STOCK_DRQTY,          //보관재고량(DR)
        @Semantics.quantity.unitOfMeasure: 'meins'        
        A.REQ_MENGE,            //직송요청량(M)
        @Semantics.quantity.unitOfMeasure: 'dr_meins'    
        A.req_drqty,            //직송요청량(DR) 
        @Semantics.quantity.unitOfMeasure: 'meins'        
        A.gr_MENGE,             //입고량(M)
        @Semantics.quantity.unitOfMeasure: 'dr_meins'  
        A.GR_DRQTY,             //입고량(DR)        
        @Semantics.quantity.unitOfMeasure: 'meins'    
        A.NGR_MENGE,            //미입고량(M)
        @Semantics.quantity.unitOfMeasure: 'dr_meins'      
        A.NGR_DRQTY,            //미입고량(DR)          
        A.ar_date,              //도착요청일
        A.ar_time,
        A.dest1,                //납지
        A.city1,
        A.site_name,            //현장명
        A.site_tel,             //현장전화번호
        A.sp_note,              //특기사항
        A.pernr,                //요청자사번
        A.name,                 //요청자명
        A.email,                //요청자 E-MAIL
        A.zmm_stat,             //구매접수상태
        A.zmm_stat_n,           //구매접수상태명
        A.zmm_date,             //구매접수일자
        A.zvd_stat,             //업체접수상태 
        A.zvd_stat_n,           //업체접수상태명
        A.zvd_date,             //업체접수일자
        B.zseq,                 //배차순번
        B.ztrtype,              //운송유형
        CONCAT(CONCAT(CONCAT(B.regiont,B.no2digit),B.ch1digit),B.no4digit) as CARNO, //차량번호
        B.tel,                  //운전자TEL   
        B.name as DRIVER,       //운전자명                  
        B.parcelname,           //택배사명*/
        @Semantics.quantity.unitOfMeasure: 'meins'           
        cast(cast(B.LOADQTY as abap.dec(13,3)) * cast(A.length as abap.dec(13,3)) as abap.quan(13,3)) as LOADQTY_M,
        @Semantics.quantity.unitOfMeasure: 'dr_meins'            
        B.LOADQTY as LOADQTY_DR,              //적재수량(DR)
        B.zdoc_no,              //거래명세서번호
        B.zdoc_item_no,         //항번
  //      B.zdoc_date,            //거래명세서발행일
        B.delno,                //당사납품서
        B.delitem,              //항번
 //       B.gidate,               //출고일
        B.mjahr,                //출고연도
        B.mblnr,                 //출고자재문서
        B.budat,
        @Semantics.quantity.unitOfMeasure: 'meins'   
        case when B.mblnr <> '' then 
          cast(cast(B.LOADQTY as abap.dec(13,3)) * cast(A.length as abap.dec(13,3)) as abap.quan(13,3)) 
        else cast(0 as abap.quan(13,3))  
        end as GRQTY_M,
        @Semantics.quantity.unitOfMeasure: 'dr_meins' 
        case when  B.mblnr <> '' then
          B.LOADQTY else cast(0 as abap.quan(13,3))
        end as GRQTY_DR,              //입고수량(DR),
        case when B.zmm_check is not null then B.zmm_check else cast('' as abap.char(1)) end as zmm_check
    
} where A.zreq_type = 'A' and A.trtyp <> '06' and A.trtyp <> '07'
