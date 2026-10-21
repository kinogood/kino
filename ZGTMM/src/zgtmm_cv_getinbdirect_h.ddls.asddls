@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직납 납품서 헤더 정보'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETINBDIRECT_H 
as select from zgtmmt4010 as A
          inner join likp as B on A.vbeln = B.vbeln 
          left outer join ZGTMM_CV_GETMAXGRDOC  as C on A.vbeln = C.VBELN
          left outer join ZGTMM_CV_CHECK_GRQI  as d on C.MJAHR = d.mjahr and C.MBLNR = d.mblnr
association [0..1] to lfa1 as L1 on $projection.lifnr = L1.lifnr
association [0..1] to lfa1 as L2 on $projection.emlif = L2.lifnr
association [0..1] to dd07t as D1 on $projection.ispstat = D1.domvalue_l and D1.domname = 'ZGTDISPCOD' and D1.ddlanguage = $session.system_language
association [0..1] to dd07t as D2 on $projection.fcode = D2.domvalue_l and D2.domname = 'ZGTDERCOD' and D2.ddlanguage = $session.system_language
{
  key   A.bukrs,
  key   A.werks,       
  key   A.vbeln,
        
        A.lifnr,
        L1.name1 as LIFNRN,
        A.vberdat,
        A.lfdat,
        A.emlif,
        L2.name1 as EMLIFN,
        A.ipdat,
        A.ispstat,
        D1.ddtext as ISPSTATN,
        A.fcode,
        case when A.fcode = '' then cast('' as ddtext)
             else D2.ddtext end as FCODEN,
        A.zetc,
        case when B.wbstk = 'B' or B.wbstk = 'C' then cast('X' as abap.char(1)) 
                    else cast('' as abap.char(1)) end as ZCLOSE,
        case when C.VBELN is null 
             then
                cast('' as abap.numc(4))
             else
                C.MJAHR
             end as MJAHR,
        case when C.VBELN is null 
             then
                cast('' as abap.dats(8))
             else
                C.BUDAT
             end as BUDAT,   
        case when C.VBELN is null 
             then
                cast('' as abap.char(10))
             else
                C.MBLNR
             end as MBLNR, 
        case when d.mblnr is null
             then
                cast('' as abap.char(1))
             else
                d.insmk
             end as insmk, 
        A.erdat,
        A.erdat_local,
        A.ertim,
        A.ertim_local,
        A.ernam,        
        @Semantics.amount.currencyCode: 'waers'  
        A.stockvalsum,
        A.waers,
        A.zguid
} where A.loekz <> 'X'

union
select from zgtmmt4010 as A
          inner join ZGTMM_CV_SC_DELIVERY_SUM as B on A.vbeln = B.vbeln 
          left outer join ZGTMM_CV_CHECK_GRQI  as C on B.gjahr = C.mjahr and B.mblnr = C.mblnr
association [0..1] to lfa1 as L1 on $projection.lifnr = L1.lifnr
association [0..1] to lfa1 as L2 on $projection.emlif = L2.lifnr
association [0..1] to dd07t as D1 on $projection.ispstat = D1.domvalue_l and D1.domname = 'ZGTDISPCOD' and D1.ddlanguage = $session.system_language
association [0..1] to dd07t as D2 on $projection.fcode = D2.domvalue_l and D2.domname = 'ZGTDERCOD' and D2.ddlanguage = $session.system_language
{
  key   A.bukrs,
  key   A.werks,       
  key   A.vbeln,
        
        A.lifnr,
        L1.name1 as LIFNRN,
        A.vberdat,
        A.lfdat,
        A.emlif,
        L2.name1 as EMLIFN,
        A.ipdat,
        A.ispstat,
        D1.ddtext as ISPSTATN,
        A.fcode,
        case when A.fcode = '' then cast('' as ddtext)
             else D2.ddtext end as FCODEN,
        A.zetc,
        case when B.mblnr <> '' then cast('X' as abap.char(1)) 
                    else cast('' as abap.char(1)) end as ZCLOSE,
        case when B.gjahr is not null then B.gjahr else cast('' as mjahr ) end as MJAHR,
        case when B.budat is not null then B.budat else cast('' as budat) end as budat,   
        case when B.mblnr is not null then B.mblnr else cast('' as mblnr) end as mblnr, 
        case when C.mblnr is not null then C.insmk else cast('' as abap.char(1)) end as INSMK,
        A.erdat,
        A.erdat_local,
        A.ertim,
        A.ertim_local,
        A.ernam,
        A.stockvalsum,
        A.waers,
        A.zguid
} where A.loekz <> 'X'
