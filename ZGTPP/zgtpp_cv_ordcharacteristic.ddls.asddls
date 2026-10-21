@AbapCatalog.sqlViewName: 'ZGTCVORDCHAR'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '생산오더 특성값'
@ClientHandling.algorithm: #SESSION_VARIABLE
define view ZGTPP_CV_ORDCHARACTERISTIC as 
select from v_ibin_syval as syval 
inner join ibin
    on  syval.mandt = ibin.mandt
    and syval.in_recno = ibin.in_recno
inner join cabn
    on  syval.mandt = cabn.mandt
    and syval.atinn = cabn.atinn
left outer join cawn
    on  cabn.mandt = cawn.mandt
    and cabn.atinn = cawn.atinn
    and syval.atwrt = cawn.atwrt
left outer join cawnt
    on  cawn.mandt = cawnt.mandt
    and cawn.atinn = cawnt.atinn
    and cawn.atzhl = cawnt.atzhl
    and cawnt.spras = $session.system_language
{
    key ibin.instance as cuobj,
    syval.atwrt,
    syval.dec_value_from,
    cabn.atnam,
    cawnt.atwtb    
}
