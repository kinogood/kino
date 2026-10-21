@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '송장 헤더 정보 LIST'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_AP_RBKP 
as select from rbkp as A inner join lfa1 as B on A.lifnr = B.lifnr  
association [1..1] to zgtmmt5010 as APP on $projection.bukrs = APP.bukrs and $projection.gjahr = APP.gjahr and $projection.belnr = APP.belnr

{
    key A.bukrs,
    key A.gjahr,
    key A.belnr,
        A.blart,
        A.budat,
        A.cpudt,
        A.cputm,
        A.usnam,
        A.vgart,
        A.lifnr,
        A.waers,
        A.xblnr,
        A.kursf,
        A.xrech,
        @Semantics.amount.currencyCode: 'waers'         
        A.rmwwr,
        @Semantics.amount.currencyCode: 'waers'         
        A.wmwst1,
        A.mwskz1,
        A.zbd1t,
        A.zfbdt,    
        A.bupla, 
        A.bktxt,  
        DATS_ADD_DAYS(A.zfbdt, cast(A.zbd1t as abap.int4), 'NULL') as expdate,
        CONCAT(A.belnr,A.gjahr) as AWKEY,
        case when APP.legacyid is not null then APP.legacyid else cast(''as abap.char(32)) end as LEGACYID,
        case when APP.appid is not null then APP.appid else cast(''as abap.char(32)) end as APPID,
        case when APP.belnr is not null then APP.belnr else cast(''as re_belnr) end as AP_BELNR,  
        A.sgtxt      
        
    
} where B.land1 = 'KR' and A.stblg = '' 
