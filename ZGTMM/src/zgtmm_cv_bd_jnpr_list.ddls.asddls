@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[BD] 제조지시 구매요청'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_BD_JNPR_LIST as 
    select from zgtmmt6210 as a inner join mara as m
                                        on a.matnr = m.matnr
                                inner join makt as kt
                                        on a.matnr = kt.matnr
                                       and kt.spras = $session.system_language
                                inner join zgtedt2121 as j
                                        on a.job_no = j.zjob_no
                                       and a.werks = j.zwerks
                           left outer join proj as p
                                        on j.zpjt_no = p.pspid
                           /*left outer join ZGTMM_CV_BD_JOBNO_SO as s
                                        on a.job_no = s.job_no
                                       and a.line_no = s.line_no
                                       and a.serial_info = s.serial_info
                           */
                           left outer join lfa1 as l
                                        on a.flief = l.lifnr
                           left outer join lfa1 as e
                                        on a.emlif = e.lifnr                                        
                           left outer join ZGTMM_CV_BD_JOBLS_PRPO as b
                                        on a.jobls = b.jobls
                           left outer join eban as r
                                        on b.banfn = r.banfn
                                       and b.bnfpo = r.bnfpo
                           left outer join lfa1 as f
                                        on r.flief = f.lifnr
                           left outer join lfa1 as em
                                        on r.emlif = em.lifnr
                           left outer join ebkn as k
                                        on r.banfn = k.banfn
                                       and r.bnfpo = k.bnfpo
                                       and k.zebkn = '01'
                           left outer join zgtmmt6100 as g
                                        on a.zmtgrp = g.zmtgrp
                                       and g.zused <> 'X'
                                       and g.lvorm <> 'X'
                           left outer join ekpo as po
                                        on r.banfn = po.banfn
                                       and r.bnfpo = po.bnfpo
                                       and po.loekz <> 'L'
                           left outer join zgtmmt6600 as rq
                                        on a.job_no = rq.job_no
                                       and a.jobls = rq.jobls
{
    key a.jobls,
    
        a.werks,
        a.knttp,
        a.pstyp,
        
        case when a.zmtgrp = '' then 'ZZ'
        else a.zmtgrp end as zmtgrp,
        //a.zmtgrp,
        g.zmtgrpt,
        
        a.matnr,
        kt.maktx as txz01_erp,
        a.txz01 as txz01,
        
        @Semantics.quantity.unitOfMeasure: 'meins'
        a.menge,
        m.meins,
        a.meins as meins_mes,
        
        a.ordch,
        a.cnfcl,
        a.eindt,
        
        case when a.flief = '' then r.flief
        else a.flief end as flief,
        case when l.name1 is null then f.name1
                                  else l.name1 end as flief_nm, //l.name1 as flief_nm,
        r.infnr,
        
        r.banfn,
        r.bnfpo,
        case when r.statu = 'B' and po.ebeln is null then 'N'
                                                     else r.statu end as statu,
        //r.statu,
        po.ebeln,
        po.ebelp,
        
        case when a.emlif = '' then r.emlif
        else a.emlif end as emlif,
        case when a.emlif = '' then em.name1
        else e.name1 end as emlif_nm,
        //a.emlif,
        //e.name1 as emlif_nm,        
        
        
        a.afnam,
        a.bstyp,
        
        a.ekorg,
        a.ekgrp,        
        m.mtart,
        m.matkl,
        a.lgort,
        a.ablad,
        a.sobkz,
        
        a.vbeln,
        a.vbelp,
        
        a.job_no,
        j.zjob_name,
        a.line_no,
        a.serial_info,
        j.zpjt_no,
        p.post1,
        a.mes_req,
        a.mes_seq,
        a.sakto,
        a.kostl,
        j.zstatus,
        //j.zdeliv_date,
        j.zapprove_userid as zaprid, //설계승인자
        cast(j.zapprove_date as datum) as zaprdt, //설계승인일
        a.erdat_local,
        rq.erdat_local as del_reqdt,
        rq.clcrs     
        
} where a.bstyp = 'B'
