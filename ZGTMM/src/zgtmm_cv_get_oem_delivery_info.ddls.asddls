@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 직송 납품 정보 조회(입고처리대상조회)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_OEM_DELIVERY_INFO 
as select from ZGTMM_CV_GET_OEM_DELIVERY_BASE as a inner join marc as b on a.matnr = b.matnr and a.werks = b.werks
{
  key   a.bukrs,                 //회사코드
  key   a.dlvrq,                 //출하지시번호
        a.werks,                 //플랜트
        a.WERKS_N,               //플랜트명
        a.vbeln,                //판매오더
        a.posnr,                //항번
        a.ebeln,                //구매오더
        a.ebelp,                //항번
        a.eindt,                //PO납품예정일
        a.lifnr,                //공급업체
        a.vname,                //공급업체명
        a.matnr,                //OEM제품
        a.maktx,                //품명
        a.color,                //색상
        case when a.meins <>'M' and a.meins <>'KM' and a.meins <>'FT' then
           cast(sum(a.LOADQTY_M) as abap.char(70))
        else a.length end as length, //조장
        a.meins,                //발주단위      
        a.dr_meins,             //발주드럼단위
        @Semantics.quantity.unitOfMeasure: 'meins'           
        sum(a.LOADQTY_M) as LOADQTY_M,
        @Semantics.quantity.unitOfMeasure: 'dr_meins'       
        case when a.meins <>'M' and a.meins <>'KM' and a.meins <>'FT' then
           cast(1 as abap.quan(13,3)) 
           else sum(a.LOADQTY_DR) end as LOADQTY_DR,              //적재수량(DR)
        a.zdoc_no,              //거래명세서번호
        a.zdoc_item_no,         //항번
        a.delno,                //당사납품서
        a.delitem,              //항번
        a.MJAHR,                //출고연도
        a.MBLNR,                 //출고자재문서
        a.BUDAT,
        @Semantics.quantity.unitOfMeasure: 'meins'   
        a.GRQTY_M,
        @Semantics.quantity.unitOfMeasure: 'dr_meins' 
        a.GRQTY_DR,              //입고수량(DR),
        a.zmm_check,
        b.dpcbt   
          
} group by a.bukrs, a.dlvrq, a.werks,  a.WERKS_N,             
           a.vbeln, a.posnr, a.ebeln,  a.ebelp,   
           a.eindt, a.lifnr, a.vname,
           a.matnr, a.maktx, a.color,
           a.length,a.meins, a.dr_meins,
           a.zdoc_no, a.zdoc_item_no, a.delno,    a.delitem, 
           a.MJAHR, a.MBLNR, a.BUDAT,           
           a.GRQTY_M, a.GRQTY_DR, a.zmm_check, b.dpcbt
