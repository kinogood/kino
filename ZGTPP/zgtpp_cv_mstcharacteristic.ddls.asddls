@AbapCatalog.sqlViewName: 'ZGTCVMSTCHAR'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재 특성'
@ClientHandling.algorithm: #SESSION_VARIABLE
define view ZGTPP_CV_MSTCHARACTERISTIC as
select from ausp
inner join cabn
    on ausp.mandt = cabn.mandt
    and ausp.atinn = cabn.atinn
left outer join cawn
    on cabn.mandt = cawn.mandt
    and cabn.atinn = cawn.atinn
    and ausp.atwrt = cawn.atwrt
left outer join cawnt
    on cawn.mandt = cawnt.mandt
    and cawn.atinn = cawnt.atinn
    and cawn.atzhl = cawnt.atzhl
    and cawnt.spras = $session.system_language
{
    key ausp.objek,
    cabn.atnam,
    ausp.atwrt,
    ausp.dec_value_from,
    cawnt.atwtb  
    
}
where ausp.klart = '001'
