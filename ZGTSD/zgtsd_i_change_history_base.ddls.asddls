@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 변경이력 Base'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_CHANGE_HISTORY_BASE 
    with parameters 
        p_date_from : abap.dats,
        p_date_to   : abap.dats
as select distinct from cdhdr as Base
{
    key Base.objectclas,
    key Base.objectid,
    key Base.changenr,
    
    max(Base.udate)  as max_udate,
    max(Base.utime)  as max_utime
    
} where Base.udate between $parameters.p_date_from 
                       and $parameters.p_date_to
    and ( Base.objectclas = 'VERKBELEG'
     or   Base.objectclas = 'IBINVALUES'
     or   Base.objectclas = 'ZGTSDT1199CHDO1' )
    and Base.langu = $session.system_language
    
  group by Base.objectclas, Base.objectid, Base.changenr 
