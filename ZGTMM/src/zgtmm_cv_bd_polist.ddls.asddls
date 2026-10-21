@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[BD] 업체별 발주 LIST'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_BD_POLIST as 
    select from ZGTMM_CV_BD_POLIST_R as a inner join lfa1 as l
                                                  on a.lifnr = l.lifnr 
                                     left outer join t023t as t
                                                  on t.spras = $session.system_language
                                                 and a.matkl = t.matkl
                                     left outer join zgtmmt6100 as g
                                                  on a.zmtgrp = g.zmtgrp

{
    key a.zmtgrp,
    key a.ymonth,
    key a.lifnr,
    key a.waers,
    key a.meins,
    
        case when a.zmtgrp > '99' then case when t.wgbez is null then a.matkl else t.wgbez end
        else g.zmtgrpt end as char30,
        
        l.name1,
        a.ekorg,
        a.werks,
        
        @Semantics.quantity.unitOfMeasure: 'meins'
        sum(a.bstmg) as bstmg,
        @Semantics.amount.currencyCode: 'waers'
        sum(a.bwert) as bwert

} group by a.zmtgrp, a.ymonth, a.lifnr, a.waers, a.meins, t.wgbez, g.zmtgrpt, a.matkl, l.name1, a.ekorg, a.werks

