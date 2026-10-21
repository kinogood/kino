@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 변경이력'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_GET_CHANGE_HISTORY
with parameters 
    p_date_from : abap.dats,
    p_date_to   : abap.dats 
    
as select distinct from ZGTSD_I_PREPARE_CDHDR_KEY as KeyMap

  // 1. 판매오더 유형(AUART) 필터링을 위한 조인
  inner join vbak as HeaderInfo on KeyMap.vbeln = HeaderInfo.vbeln

  // 2. 변경이력 체크 (1) - 헤더 변경
  left outer join ZGTSD_I_CHANGE_HISTORY_BASE( 
                    p_date_from : $parameters.p_date_from, 
                    p_date_to   : $parameters.p_date_to 
                  ) as ChgHead on  KeyMap.HeaderObjID = ChgHead.objectid
                               and ChgHead.objectclas = 'VERKBELEG'

  // 3. 변경이력 체크 (2) - 특성 변경
  left outer join ZGTSD_I_CHANGE_HISTORY_BASE( 
                    p_date_from : $parameters.p_date_from, 
                    p_date_to   : $parameters.p_date_to 
                  ) as ChgIbin on  KeyMap.IbinObjID   = ChgIbin.objectid
                               and ChgIbin.objectclas = 'IBINVALUES'

  // 4. 변경이력 체크 (3) - 드럼 라벨 변경
  left outer join ZGTSD_I_CHANGE_HISTORY_BASE( 
                    p_date_from : $parameters.p_date_from, 
                    p_date_to   : $parameters.p_date_to 
                  ) as ChgDrum on  KeyMap.DrumObjID   = ChgDrum.objectid
                               and ChgDrum.objectclas = 'ZGTSDT1199CHDO1'
{
  key KeyMap.vbeln
  
} where ( ChgHead.objectid is not null
     or   ChgIbin.objectid is not null
     or   ChgDrum.objectid is not null )
