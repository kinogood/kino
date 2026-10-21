@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '송장 전표 반제 현황 조회 LIST'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_AP_CLEARING
as select from ZGTMM_CV_GET_AP_RBKP as A inner join bkpf as B on A.AWKEY = B.awkey and A.bukrs = B.bukrs
                                         inner join bseg as C on B.gjahr = C.gjahr and B.belnr = C.belnr and C.bukrs = B.bukrs
                                         inner join ZGTMM_CV_GET_IV_PLANT as k on A.gjahr = k.gjahr and A.belnr = k.belnr
association [1..1] to ZGTMM_CV_GET_AP_CLDOC as DOC on $projection.bukrs = DOC.bukrs
                   and $projection.GJAHR_BKPF = DOC.gjahr and $projection.BELNR_BKPF = DOC.belnr
association [1..1] to t001 as T001 on $projection.bukrs = T001.bukrs
association [1..1] to lfa1 as LFA1 on $projection.lifnr = LFA1.lifnr
association [1..1] to ZGTMM_CV_GET_WELS_MAX_STATUS  as APP on $projection.APPID = APP.appid and $projection.LEGACYID = APP.legacyid

{
    key A.bukrs,
    key A.gjahr,
    key A.belnr,
    t001.butxt,
        A.blart,
        A.budat,
        LEFT(A.budat,6) as SPMON,
        A.cpudt,
        A.cputm,
        A.usnam,
        A.vgart,
        A.xrech,
        case when A.xrech = 'X' then cast('송장' as abap.char(4)) else cast('반품' as abap.char(4)) end as XRECH_N,
/*        case A.bupla when '610' then cast('6500' as ewerk)
                     when 'F610' then cast('6500' as ewerk)
                     when '620' then cast('6600' as ewerk)
                     when 'F620' then cast('6600' as ewerk)
                     else A.xblnr 
        end as WERKS,*/
        k.WERKS,
        A.lifnr,
        lfa1.name1 as LIFNR_N,
        A.waers,
        A.kursf,
        @Semantics.amount.currencyCode: 'waers'
        A.rmwwr,
        @Semantics.amount.currencyCode: 'waers'
        A.rmwwr - A.wmwst1 as SPRICE,
        @Semantics.amount.currencyCode: 'waers'
        A.wmwst1,
        A.mwskz1,
        A.zbd1t,
        A.zfbdt,
        A.expdate,
        B.gjahr as GJAHR_BKPF,
        B.belnr as BELNR_BKPF,
        C.zterm,
        C.zlspr,
        A.AP_BELNR,
        A.APPID,
        A.LEGACYID,
        C.sgtxt,
        A.bktxt,
        case when APP.status is not null then APP.status else cast('' as abap.char(1)) end as AP_STATUS,
        case when APP.STATUS_N is not null then APP.STATUS_N else cast('' as abap.char(60)) end as AP_STATUS_N,
        case when APP.appid is not null then
             case APP.status when 'T' then  cast('O' as abap.char(1))
                             when 'P' then  cast('O' as abap.char(1))
                             when 'C' then  cast('O' as abap.char(1))
                             when 'R' then  cast(' ' as abap.char(1))
                             when 'W' then  cast(' ' as abap.char(1))
                             when 'D' then  cast(' ' as abap.char(1))                             
                             end
             else cast('' as abap.char(1)) end as REQPAY,
        
          case when APP.appid is not null then
            case when APP.status = 'C' then cast(APP.Timestamp as abap.char(14))
                                       else     cast('' as abap.char(14)) end
               else  cast('' as abap.char(14)) end as timestamp, 
        case when DOC.budat is not null then DOC.budat
             else cast('' as budat) end as CL_budat,
        case when DOC.bldat is not null then DOC.bldat
             else cast('' as bldat) end as CL_BLDAT,
        case when DOC.cpudt is not null then DOC.cpudt
             else cast('' as cpudt) end as CL_CPUDT,
        case when DOC.augdt is not null then DOC.augdt
             else cast('' as augdt) end as CL_AUGDT,
        case when DOC.augbl is not null then DOC.augbl
             else cast('' as augbl) end as CL_AUGBL,
        case when DOC.budat is not null then cast('O' as abap.char(1))
             else cast('' as abap.char(1)) end as CLEARING               
    
} where C.lifnr <> '' and C.koart = 'K'
