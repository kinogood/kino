@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[BD] 제조지시 구매오더'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_BD_JNPO_LIST as 
    select from zgtmmt6210 as a inner join zgtedt2121 as j
                                        on a.job_no = j.zjob_no
                                       and a.werks = j.zwerks
                           left outer join proj as p
                                        on j.zpjt_no = p.pspid
                           left outer join mara as m
                                        on a.matnr = m.matnr   
                           left outer join makt as kt
                                        on a.matnr = kt.matnr
                                       and kt.spras = $session.system_language
                           /*left outer join ZGTMM_CV_BD_JOBNO_SO as s
                                        on a.job_no = s.job_no
                                       and a.line_no = s.line_no
                                       and a.serial_info = s.serial_info                                
                           */
                           left outer join ZGTMM_CV_BD_JOBLS_PRPO as b
                                        on a.jobls = b.jobls
                           left outer join ekko as h
                                        on b.ebeln = h.ebeln
                           left outer join lfa1 as l
                                        on a.flief = l.lifnr
                           left outer join lfa1 as ll
                                        on h.lifnr = ll.lifnr
                           left outer join ekpo as i
                                        on b.ebeln = i.ebeln
                                       and b.ebelp = i.ebelp
                           left outer join lfa1 as e
                                        on a.emlif = e.lifnr
                           left outer join lfa1 as ee
                                        on i.emlif = ee.lifnr
                           left outer join eket as sl
                                        on i.ebeln  = sl.ebeln
                                       and i.ebelp  = sl.ebelp
                                       and sl.etenr = '0001'
                           left outer join ekkn as k
                                        on i.ebeln = k.ebeln
                                       and i.ebelp = k.ebelp
                                       and k.zekkn = '01'
                           left outer join zgtmmt6100 as g
                                        on a.zmtgrp = g.zmtgrp
                                       and g.zused <> 'X'
                                       and g.lvorm <> 'X'
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
        case when a.matnr = '' 
        then a.txz01
        else kt.maktx end as txz01_erp,
        
        //MES 자재명으로 PO의 자재내역으로 전환
        //전환의 경우 a.txz01에 값이 안 들어옴
        case when a.ordch = 'X' 
        then case when a.matnr = '' then a.txz01
             else kt.maktx end
        else case when a.txz01 = '' then kt.maktx
             else a.txz01 end 
        end as txz01,
        //a.txz01 as txz01,

        @Semantics.quantity.unitOfMeasure: 'meins'
        a.menge,        
        case when a.matnr = '' then a.meins
        else m.meins end as meins,
        a.meins as meins_mes,
        
        a.ordch,
        a.cnfcl,
        a.eindt,
        
        case when a.flief = '' then cast( h.lifnr as flief ) 
        else a.flief end as flief,
        
        case when a.flief = '' then ll.name1
        else l.name1 end as flief_nm,
        
        i.infnr,
        
        i.ebeln,
        i.ebelp,
        
        case when a.emlif = '' then i.emlif 
        else a.emlif end as emlif,
        
        case when a.emlif = '' then ee.name1
        else e.name1 end as emlif_nm,

        a.afnam,
        a.bstyp,
        @Semantics.quantity.unitOfMeasure: 'meins'
        sl.wemng,
        
        h.waers,
        @Semantics.amount.currencyCode: 'waers'
        i.netwr,
        @Semantics.amount.currencyCode: 'waers'
        i.netpr,
        i.peinh,
        i.bprme,
        
        a.exprc,
        a.idnlf,
        @Semantics.quantity.unitOfMeasure: 'bstme'
        a.bstmg,
        a.bstme,
        a.infnr as oinfr,
        @Semantics.amount.currencyCode: 'owaer'
        a.netpr as onetp,
        a.peinh as opein,
        
        //@Semantics.amount.currencyCode: 'owaer'
        a.netwr as onetw,
        a.waers as owaer,
        a.ekorg,
        a.ekgrp,        
        m.mtart,
        
        case when a.matnr = '' and a.knttp = 'K' then a.matkl
        else m.matkl end as matkl,
        
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
        i.bstae,
        a.umson,
        j.zstatus,
        //j.zdeliv_date,
        j.zapprove_userid as zaprid, //설계승인자
        cast(j.zapprove_date as datum) as zaprdt, //설계승인일
        a.erdat_local,
        a.zweight,
        a.zlength_1,
        a.zlength_2,
        a.zlength_3,
        a.zlength_4,
        a.zlength_5,
        a.zlength_6,
        a.zlength_7   
        
} where a.bstyp = 'F'
