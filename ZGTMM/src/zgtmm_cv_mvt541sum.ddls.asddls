@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 출고 정보 SUM'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_MVT541SUM 
as select from ZGTMM_CV_MVT541LIST as A left outer join zgtmmt4110 as B on A.mjahr = B.mjahr and A.mblnr = B.mblnr
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
       sum(A.ISVAL) as ISVAL,
       A.waers,    //통화
       A.bktxt,    //비고  
       case when B.zgitype is null then 
             case when A.bktxt = 'ZGTMMR4130' then cast('' as zgtemmgt) else cast('A' as zgtemmgt) end
            else B.zgitype end as ZTIGYPE
} group by A.bukrs,A.werks,A.LGORT,A.LIFNR,A.mjahr,A.mblnr,A.IV_NO,A.budat,A.bldat,A.cpudt,A.cputm,A.usnam,A.waers,A.bktxt,B.zgitype
