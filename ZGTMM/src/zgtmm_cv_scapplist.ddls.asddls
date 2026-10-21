@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 불출 품의 리스트 HEADER'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SCAPPLIST 
as 

//초과불출 처리 결과

select from zgtmmt4110 as A inner join zgtmmt4113 as B on A.bukrs = B.bukrs and A.werks = B.werks and A.lgort = B.lgort
          left outer join ZGTMM_CV_MVT542LIST as C on A.mjahr = C.sjahr and A.mblnr = C.smbln
          left outer join ZGTMM_CV_GATEOUTDOC as D on A.mjahr = D.mjahr and A.mblnr = D.mblnr
          left outer join nsdm_e_MKPF as E on A.mjahr = E.mjahr and A.mblnr = E.mblnr
association [0..1] to lfa1 as LFA1 on $projection.lifnr = LFA1.lifnr
association [0..1] to t001l as T001L on $projection.werks = T001L.werks and $projection.lgort = T001L.lgort
association [1..1] to dd07t as RES on $projection.ores = RES.domvalue_l and RES.domname = 'ZGTDMMRES' and RES.ddlanguage = $session.system_language
association [1..1] to dd07t as REJ on $projection.rejres = REJ.domvalue_l and REJ.domname = 'ZGTDMMREJ' and REJ.ddlanguage = $session.system_language
association [1..1] to ZGTMM_CV_GETUSERNAME as N1 on $projection.ernam = N1.USERID
association [1..1] to ZGTMM_CV_GETUSERNAME as N2 on $projection.aenam = N2.USERID


{
 key    A.zguid,
        A.zgitype,
        A.bukrs,
        A.werks,
        A.lgort,
        t001l.lgobe,
        A.lifnr,
        lfa1.name1,
        @Semantics.amount.currencyCode: 'waers'
        A.preis,
        @Semantics.amount.currencyCode: 'waers'        
        A.scval,
        @Semantics.amount.currencyCode: 'waers'        
        A.isval,
        @Semantics.amount.currencyCode: 'waers'        
        A.reval,
        @Semantics.amount.currencyCode: 'waers'        
        A.ivval,
        A.waers,
        A.ores,
        RES.ddtext as OREST,
        A.oetc,
        A.appstat,
        A.rejres,
        REJ.ddtext as REJREST,
        A.retc,
        case when C.smbln is null then A.mjahr 
             else cast('' as abap.numc(4)) end as MJAHR,
        case when C.smbln is null then A.mblnr
             else cast('' as abap.char(10)) end as mblnr,
             
        case when D.mblnr is not null
             then
               case when C.smbln is null then D.iv_no
                    else cast('' as abap.char(10)) end
             else cast('' as abap.char(10))     
        end as IV_NO,
             
        A.erdat,
        A.erdat_local,
        A.ertim,
        A.ertim_local,
        A.ernam,
        N1.NAME as REQNAME,
        A.aedat,
        A.aedat_local,
        A.aetim,
        A.aetim_local,
        A.aenam,
        N2.NAME as APPNAME,
        B.approver1,
        B.approver2,
        case when E.mblnr is null then cast('' as abap.dats(8))
             else E.bldat end as bldat,
        case when E.mblnr is null then cast('' as abap.dats(8))
             else E.budat end as budat,             
        case when E.mblnr is null then cast('' as abap.dats(8))
             else E.cpudt end as cpudt,      
        case when E.mblnr is null then cast('' as abap.dats(8))
             else E.usnam end as usnam                         
          
} where (A.zgitype = 'A' or A.zgitype = 'E' )  and A.loekz = ''

union

//직납 초과 결과

select from zgtmmt4110 as A 
          left outer join ZGTMM_CV_MVT542LIST as C on A.mjahr = C.sjahr and A.mblnr = C.smbln
          left outer join nsdm_e_MKPF as E on A.mjahr = E.mjahr and A.mblnr = E.mblnr
association [0..1] to lfa1 as LFA1 on $projection.lifnr = LFA1.lifnr
association [0..1] to t001l as T001L on $projection.werks = T001L.werks and $projection.lgort = T001L.lgort
association [1..1] to dd07t as RES on $projection.ores = RES.domvalue_l and RES.domname = 'ZGTDMMRES' and RES.ddlanguage = $session.system_language
association [1..1] to dd07t as REJ on $projection.rejres = REJ.domvalue_l and REJ.domname = 'ZGTDMMREJ' and REJ.ddlanguage = $session.system_language
association [1..1] to ZGTMM_CV_GETUSERNAME as N1 on $projection.ernam = N1.USERID
association [1..1] to ZGTMM_CV_GETUSERNAME as N2 on $projection.aenam = N2.USERID


{
 key    A.zguid,
        A.zgitype,
        A.bukrs,
        A.werks,
        A.lgort,
        t001l.lgobe,
        A.lifnr,
        lfa1.name1,
        A.preis,        
        A.scval,        
        A.isval,
                
        A.reval,
                
        A.ivval,
        A.waers,
        A.ores,
        RES.ddtext as OREST,
        A.oetc,
        A.appstat,
        A.rejres,
        REJ.ddtext as REJREST,
        A.retc,
        case when C.smbln is null then A.mjahr 
             else cast('' as abap.numc(4)) end as MJAHR,
        case when C.smbln is null then A.mblnr
             else cast('' as abap.char(10)) end as mblnr,
             
        cast('' as abap.char(10)) as IV_NO,
             
        A.erdat,
        A.erdat_local,
        A.ertim,
        A.ertim_local,
        A.ernam,
        N1.NAME as REQNAME,
        A.aedat,
        A.aedat_local,
        A.aetim,
        A.aetim_local,
        A.aenam,
        N2.NAME as APPNAME,
        cast('' as ernam) as approver1,
        cast('' as ernam) as approver2,
        case when E.mblnr is null then cast('' as abap.dats(8))
             else E.bldat end as bldat,
        case when E.mblnr is null then cast('' as abap.dats(8))
             else E.budat end as budat,             
        case when E.mblnr is null then cast('' as abap.dats(8))
             else E.cpudt end as cpudt,      
        case when E.mblnr is null then cast('' as abap.dats(8))
             else E.usnam end as usnam                         
          
} where A.zgitype = 'D'  and A.loekz = ''
