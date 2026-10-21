@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[BD] 업체별 발주 LIST RAW'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_BD_POLIST_R as // PO
    select from ekko as a inner join ekpo as b
                                  on a.ebeln = b.ebeln
                                 and b.loekz = ''
                                 and a.bstyp = 'F'
                          inner join zgtmmt6000 as s
                                  on b.ebeln = s.ebeln
                                 and b.ebelp = s.ebelp
                          inner join zgtmmt6210 as g
                                  on s.jobls = g.jobls
                                 and g.bstyp = 'F'                           
                     left outer join mara as m
                                  on b.matnr = m.matnr
{
    key case when m.mtart is null  then 'P1'   //자재코드 없음
             when m.mtart = 'ROH1' then 'R1'  //원재료1
             when m.mtart = 'ROH2' then 'R2'  //원재료2
             when m.mtart = 'HALB' then 'H1'  //반제품
             when m.mtart = 'FERT' then 'F1'  //완제품
             when m.mtart = 'HAWA' then 'H1'  //상품
             else 'OT' end as zmtgrp,
    
    key cast(substring(a.bedat, 1, 6) as nsdm_yearmonth) as ymonth,
    key a.bedat,
    key a.lifnr,
    
        a.waers,
        b.meins,
    
        a.ekorg,
        b.werks,
        b.matnr,
        
        m.mtart,
        case when m.mtart is null then b.matkl  //po 자재코드 없으면 po의 자재그룹
        else m.matkl end as matkl,              //po 자재코드 있으면 mara의 자재그룹
        s.jobls,
        
        @Semantics.quantity.unitOfMeasure: 'meins'
        b.menge as bstmg,
        @Semantics.amount.currencyCode: 'waers'
        b.netwr as bwert

} 

union all
//BusBar is MTS process
    select from ekko as a inner join ekpo as b
                                  on a.ebeln = b.ebeln
                                 and b.loekz = ''
                                 and a.bstyp = 'F'
                          inner join mara as m
                                  on b.matnr = m.matnr
{
    key case when m.matkl = 'NBD000002' then '02'  //BusBar CU
             else '03' end as zmtgrp,              //BusBar AL
    key cast(substring(a.bedat, 1, 6) as nsdm_yearmonth) as ymonth,
    key a.bedat,
    key a.lifnr,
    
        a.waers,
        b.meins,
    
        a.ekorg,
        b.werks,
        b.matnr,
        m.mtart,
        b.matkl,
        '9999999999' as jobls,
        
        b.menge as bstmg,
        b.netwr as bwert
        
} where m.matkl = 'NBD000001' or m.matkl = 'NBD000002'

union all
// PR
    select from ekko as a inner join ekpo as b
                                  on a.ebeln = b.ebeln
                                 and b.loekz = ''
                                 and a.bstyp = 'F'
                          inner join eket as t
                                  on b.ebeln = t.ebeln
                                 and b.ebelp = t.ebelp
                                 and t.etenr = '0001' 
                          inner join zgtmmt6000 as s
                                  on t.banfn = s.banfn
                                 and t.bnfpo = s.bnfpo
                                 and s.banfn <> ''
                          inner join zgtmmt6210 as g
                                  on s.jobls = g.jobls
                                 and g.bstyp = 'B'
                     left outer join mara as m
                                  on b.matnr = m.matnr
{
    key g.zmtgrp,
    key cast(substring(a.bedat, 1, 6) as nsdm_yearmonth) as ymonth,
    key a.bedat,
    key a.lifnr,
    
        a.waers,
        b.meins,
    
        a.ekorg,
        b.werks,
        b.matnr,
        m.mtart,
        b.matkl,
        s.jobls,
        
        b.menge as bstmg,
        b.netwr as bwert

} 
