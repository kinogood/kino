@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[BD] 구매오더 자재문서'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_BD_PO_MATDOC as 
    select from matdoc as m inner join ekpo as p
                                    on m.ebeln = p.ebeln
                                   and m.ebelp = p.ebelp
                            inner join ekko as k
                                    on p.ebeln = k.ebeln
                            inner join lfa1 as l
                                    on k.lifnr = l.lifnr
                            inner join eket as t
                                    on p.ebeln = t.ebeln
                                   and p.ebelp = t.ebelp
                                   and t.etenr = '0001'
                            left outer join mara as a
                                    on m.matnr = a.matnr
                            left outer join lfa1 as e
                                    on m.lifnr_sid = e.lifnr
                            left outer join zgtmmt6000 as j  //pr 시리얼
                                    on t.banfn <> ''
                                   and t.banfn = j.banfn
                                   and t.bnfpo = j.bnfpo
                            left outer join zgtmmt6000 as o //po 시리얼
                                    on p.ebeln <> ''
                                   and p.ebeln = o.ebeln
                                   and p.ebelp = o.ebelp                                   
{
    key m.mblnr,
    key m.mjahr,
    key m.zeile,
    
        m.cpudt,
        m.budat,
        m.ebeln,
        m.ebelp,
        p.knttp,
        
        case when j.job_no is null then o.job_no
             else j.job_no end as job_no,
        case when j.line_no is null then o.line_no
             else j.line_no end as line_no,
        case when j.serial_info is null then o.serial_info
             else j.serial_info end as serial_no,        
        //j.job_no,
        //j.line_no,
        //j.serial_info as serial_no,
        
        m.werks,
        k.ekgrp,
        k.lifnr,
        l.name1,
        m.matnr,
        a.mtart,
        p.txz01,
        p.bednr,
        
        case when a.matkl is null then p.matkl
             else a.matkl end as matkl,
        
        m.bwart,
        m.shkzg,
        m.bstme,
        @Semantics.quantity.unitOfMeasure: 'bstme'
        m.bstmg,   //구매오더단위 입고 수량
        
        m.lgort_sid,
        m.lifnr_sid, //특별재고 공급업체
        e.name1 as name1_sid
        
} where m.kzbew = 'B'
    and m.kzzug = ' '
