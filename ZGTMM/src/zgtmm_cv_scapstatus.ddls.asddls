@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '사급자재 불출 Block 체크'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SCAPSTATUS 
as 
select from zgtmmt4110 as a left outer join matdoc as b on a.mjahr = b.mjahr and a.mblnr = b.mblnr and a.lgort = b.lgort_sid
{
 key    a.zguid,
        a.zgitype,
        a.bukrs,
        a.werks,
        a.lgort,
        a.lifnr,

        case when a.appstat = '' then cast('B' as abap.char(1))
             else
                 case when a.appstat = 'A' 
                      then
                          case when a.mblnr = '' then cast('B' as abap.char(1))
                               else
                                   case when b.cancelled = 'X' then cast('B' as abap.char(1))
                                        else cast('' as abap.char(1))
                                   end
                           end
                      else cast('' as abap.char(1))
                 end
         end as blcheck
}
