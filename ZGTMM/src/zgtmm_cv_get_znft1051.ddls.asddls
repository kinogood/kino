@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '선물정산현황 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_ZNFT1051 
as select from znft1051 as A inner join znft1011 as B on A.reqno = B.reqno and A.h_no1 = B.h_no1
                             inner join znft1000 as C on A.conno = C.conno
association [0..*] to ZGTMM_CV_GET_ZNFT1052   as d on $projection.gjahr = d.gjahr and $projection.belnr = d.belnr                            
{
 key    A.nfutn,             //선물집행번호
 key    A.cfutn,             //선물청산번호
        A.bukrs,
        A.reqno,             //선물집행요청정보        
        A.h_no1,
        A.conno,             //계약번호
        A.prctr,
        A.vkgrp,             //영업그룹
        A.kunnr,
        A.nfkey,             //비철구분
        C.zpjno,             //프로젝트 번호
        A.fcm,               //선물사
        A.endat,             //만기일
        @Semantics.quantity.unitOfMeasure: 'MEINS'        
        A.emeng,             //집행수량
        A.meins,             //단위
        @Semantics.amount.currencyCode: 'waers'           
        A.nprice,            //집행단가
        @Semantics.amount.currencyCode: 'waers'           
        A.cprice,            //집행단가
        A.waers,
        @Semantics.amount.currencyCode: 'waers'        
        A.n_fee,             //신규수수료
        @Semantics.amount.currencyCode: 'waers'        
        A.c_fee,             //청산수수료
        @Semantics.amount.currencyCode: 'UAERS'           
        A.uprlo,             //선물손익(USD)
        A.uaers,          
        A.kursf,             //환율
        A.wwert,             //환산일
        @Semantics.amount.currencyCode: 'KAERS'            
        A.kprlo,             //선물손익(krw)
        A.kaers,
        A.belnr,             //선물청산전표
        A.gjahr,
        case when d.belnr_s is not null then d.belnr_s else A.zbelnr end as zbelnr,
        case when d.gjahr_s is not null then d.gjahr_s else A.zgjahr end as zgjahr,
        A.ybelnr,
        A.ygjahr,
        case when LEFT(B.bigo4,4) = '[3C]' then cast('6500' as werks_d) 
             when LEFT(B.bigo4,4) = '[4C]' then cast('6600' as werks_d)
             else cast('' as werks_d) end as werks
}
