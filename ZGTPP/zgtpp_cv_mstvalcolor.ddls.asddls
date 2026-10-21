@AbapCatalog.sqlViewName: 'ZGTIMSTCOLVAL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재 컬러 속성 값'
@ClientHandling.algorithm: #SESSION_VARIABLE
define view ZGTPP_CV_MSTVALCOLOR as
select from mara
inner join marc
   on mara.mandt = marc.mandt
   and mara.matnr = marc.matnr
left outer join ausp
    on marc.mandt = ausp.mandt
    and marc.matnr = ausp.objek
    and ausp.klart = '001'
left outer join cabn
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
    key marc.werks,
    key marc.matnr,
    case cabn.atnam when 'PD_CA_COLOR_BASE' 
                    then ausp.atwrt
                    else '' end as PdCaColorBase,
    case cabn.atnam when 'PD_CA_COLOR_BASE' 
                    then cawnt.atwtb
                    else '' end as PdCaColorBaseNm,
    case cabn.atnam when 'PD_CA_INS_IDEN_CODE' 
                    then ausp.atwrt
                    else '' end as PdCaInsIdenCode,
    case cabn.atnam when 'PD_GL_PAR_COLOR' 
                    then ausp.atwrt
                    else '' end as PdGlParColor,
    case cabn.atnam when 'PD_OC_FIBER_COLOR_BASE' 
                    then ausp.atwrt
                    else '' end as PdOcFiberColBase,
    case cabn.atnam when 'PD_OC_FIBER_COLOR_BASE' 
                    then cawnt.atwtb
                    else '' end as PdOcFiberColBaseNm,
    case cabn.atnam when 'PD_OC_TUBE_COLOR_BASE' 
                    then ausp.atwrt
                    else '' end as PdOcTubeColBase,
    case cabn.atnam when 'PD_OC_TUBE_COLOR_BASE' 
                    then cawnt.atwtb
                    else '' end as PdOcTubeColBaseNm,
    case cabn.atnam when 'PD_GL_INS_COLOR' 
                    then ausp.atwrt
                    else '' end as PdGlInsColor,
    case cabn.atnam when 'PD_GL_INS_COLOR' 
                    then cawnt.atwtb
                    else '' end as PdGlInsColorNm,
    case cabn.atnam when 'PD_OC_BUFFER_COLOR_BASE' 
                    then ausp.atwrt
                    else '' end as PdOcBufColor,
    case cabn.atnam when 'PD_OC_BUFFER_COLOR_BASE' 
                    then cawnt.atwtb
                    else '' end as PdOcBufColorNm
}
