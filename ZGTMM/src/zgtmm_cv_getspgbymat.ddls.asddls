@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재 별 대상 SPG 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETSPGBYMAT 
as 
select from mara as A 
       inner join marc as B on A.matnr = B.matnr     
       inner join ZGTMM_CV_GET_DISPO2 as C on B.werks = C.werks and B.matnr = C.matnr 
       
       association [0..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language   
       association [0..1] to t001w as T001W on $projection.werks = T001W.werks    
{
  key C.matnr,
  key C.werks,
  case when C.SPG1 <> ''   then 
            case when C.SPG1NAME <> '' then C.SPG1 
                 else
                      case when C.SPG2 <> '' then C.SPG2
                           else cast('ZZ' as zspgcd) 
                      end
            end 
        else
             case when C.SPG2 <> '' then C.SPG2
                  else cast('ZZ' as zspgcd)
             end 
        end as SPGCD,
  makt.maktx,
  t001w.name1 as PLANTNAME,
  case when C.SPG1NAME <> '' then C.SPG1NAME 
       else
            case when C.SPG2NAME <> '' then C.SPG2NAME
                 else cast('공통' as zspgcd) 
                 end
       end as SPGNAME,
  B.dispo,
  A.spart  
} 



