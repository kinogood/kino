@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT_PP] 생산오더 상태 값 추출'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTPP_CV_ORD_STAT
  as select from    I_MfgOrderWithStatus as ORDST
    inner join      aufk                 as A on ORDST.ManufacturingOrder = A.aufnr
    left outer join jest                 as B on  A.objnr = B.objnr
                                              and B.stat  = 'E0001' // PAYOFF
                                              and B.inact = ''      // PAYOFF 활성
    left outer join ZGTPP_CV_AUFNR_261   as c on A.aufnr = c.aufnr
{
  key A.aufnr,
  key ORDST.ManufacturingOrderCategory      as AUTYP,
  key ORDST.ManufacturingOrderType          as AUART,
  key A.werks,
      @EndUserText.quickInfo : '생성'
      ORDST.OrderIsCreated                  as CRTD,
      @EndUserText.quickInfo: '릴리즈'
      ORDST.OrderIsReleased                 as REL,
      ORDST.OrderIsDeleted                  as DEL,
      ORDST.OrderIsMarkedForDeletion        as DLFL,
      ORDST.OrderIsLocked                   as LKD,
      ORDST.OrderIsTechnicallyCompleted     as TECO,
      ORDST.OrderIsClosed                   as CLSD,
      ORDST.OrderIsPartiallyConfirmed       as PCNF,
      ORDST.OrderIsConfirmed                as CNF,
      ORDST.OrderIsPartiallyDelivered       as PDLV,
      ORDST.OrderIsDelivered                as DLV,
      case
         when B.stat = 'E0001' then 'X' end as PAYO,
      case
         when c.mblnr <> '' then 'X' end    as GISTART
}
where
  ORDST.ManufacturingOrderCategory = '10'
group by
  A.aufnr,
  ORDST.ManufacturingOrderCategory,
  ORDST.ManufacturingOrderType,
  A.werks,
  ORDST.OrderIsCreated,
  ORDST.OrderIsReleased,
  ORDST.OrderIsDeleted,
  ORDST.OrderIsMarkedForDeletion,
  ORDST.OrderIsLocked,
  ORDST.OrderIsTechnicallyCompleted,
  ORDST.OrderIsClosed,
  ORDST.OrderIsPartiallyConfirmed,
  ORDST.OrderIsConfirmed,
  ORDST.OrderIsPartiallyDelivered,
  ORDST.OrderIsDelivered,
  B.stat,
  c.mblnr
