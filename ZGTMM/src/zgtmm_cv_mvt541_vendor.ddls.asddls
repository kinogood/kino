@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '업체 별 전체 불출 이력'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_MVT541_VENDOR 
as select from ZGTMM_CV_MVT541SUM as A left outer join zgtmmt4110 as B on A.mjahr = B.mjahr and A.mblnr = B.mblnr 
association [0..1] to zgtppt1010 as PP on $projection.ores = PP.fld_03 and PP.module_kind = 'MM' and PP.codegrp = '0100' and PP.fld_01 = 'ZGTMMR4110' and PP.fld_02 = 'A'
{
   key A.bukrs,    //회사코드
   key A.werks,    //플랜트
   key A.LGORT,    //저장위치
   key A.LIFNR,    //공급업체
   key A.mjahr,    //연도
   key A.mblnr,    //자재문서번호
       A.IV_NO,    //통문번호
       A.budat,    //전기일
       A.bldat,    //증빙일
       A.cpudt,    //입력일
       A.cputm,    //입력시간
       A.usnam,    //입력자
       
       @Semantics.amount.currencyCode: 'waers'  
       A.ISVAL,
       A.waers,    //통화
       A.bktxt,    //비고
       @Semantics.amount.currencyCode: 'waers'       
       case when B.preis is not null then B.preis
       else cast(0 as salk3) end as preis,    //보증금액   
       @Semantics.amount.currencyCode: 'waers'  
       case when B.scval is not null then B.scval
       else cast(0 as salk3) end as scval,    //외주재고액
       @Semantics.amount.currencyCode: 'waers'  
       case when B.isval is not null then B.isval
       else cast(0 as salk3) end as ISVALUE,  //출고예정액,
       @Semantics.amount.currencyCode: 'waers'  
       case when B.reval is not null then B.reval
       else cast(0 as salk3) end as reval,    //출고가용액
       B.ores,
       PP.fld_04 as ORESNAME,
       B.oetc
       
}
