@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 출고 리스트'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_MVT541LIST 
as 
select from matdoc as A
       left outer join ZGTMM_CV_GETGATEOUTLIST as b on A.mjahr = b.mjahr and A.mblnr = b.mblnr and A.zeile = b.zeile

association [0..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language   
{
   key A.bukrs,    //회사코드
   key A.werks,    //플랜트
   key A.lgort_sid as LGORT,    //저장위치
   key case when A.bwart = '541' then A.lifnr_cid
            else A.lifnr_sid end  as LIFNR,    //공급업체
   key A.mjahr,    //연도
   key A.mblnr,    //자재문서번호
   key A.zeile,    //항번   
                   
       A.budat,    //전기일
       A.bldat,    //증빙일
       A.cpudt,    //입력일
       A.cputm,    //입력시간
       A.usnam,    //입력자
       
       @Semantics.amount.currencyCode: 'waers'  
       case when A.lbkum = 0 then cast(0 as abap.curr(13,2))
       else
        cast(cast(cast(A.salk3 as abap.dec(13,2)) / A.lbkum as abap.dec(13,2)) * A.menge as abap.curr(13,2)) 
       end as ISVAL,
         
       A.waers,    //통화
                   //품목건수
       A.bktxt,    //비고

       A.matnr,    //자재코드
       makt.maktx,  //자재명
       A.charg,    //배치번호
       @Semantics.quantity.unitOfMeasure: 'MEINS'       
       A.menge,    //출고수량
       A.meins,    //단위
       
       case when b.iv_no is not null then b.iv_no
            else cast('' as abap.char(10)) end as IV_NO //통문번호
       
} where A.cancelled = ''  and ((A.bstaus_cg = 'Q' and  A.bwart = '541')  or (A.sobkz = 'O' and A.bwart = '101')) 
 
