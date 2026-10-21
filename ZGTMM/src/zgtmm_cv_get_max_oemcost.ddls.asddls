@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 단가 정보 조회(최신)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_MAX_OEMCOST 
as select from a017 as A inner join konh as B on A.knumh = B.knumh and A.kappl = B.kappl and A.kschl = B.kschl
                         inner join konp as C on B.knumh = C.knumh and B.kappl = C.kappl and B.kschl = C.kschl
                         inner join eina as D on A.lifnr = D.lifnr and A.matnr = D.matnr
                         inner join eine as E on D.infnr = E.infnr and A.ekorg = E.ekorg and A.werks = E.werks and A.esokz = E.esokz
                         inner join zgtmmt1110 as F on E.infnr = F.infnr and D.matnr = F.matnr and D.lifnr = F.lifnr and E.ekorg = F.ekorg and E.werks = F.werks and E.esokz = F.esokz
                         inner join ZGTMM_CV_GET_MAX_ZGTMMT1110 as G on F.infnr = G.infnr and F.matnr = G.matnr and F.lifnr = G.lifnr and F.ekorg = G.ekorg and F.werks = G.werks and F.period = G.PERIOD
                         inner join mara as H on D.matnr = H.matnr
                         inner join marc as I on F.matnr = I.matnr and F.werks = I.werks
association [1..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language   
association [0..*] to ZGTMM_CV_GET_PODATA_MON  as P1 on $projection.lifnr = P1.lifnr and $projection.ekorg = P1.ekorg and $projection.matnr = P1.matnr                      

{
  key F.matnr,
  key F.werks,
  key E.ekorg,
  key F.lifnr,
      makt.maktx,
      I.beskz,
      @Semantics.amount.currencyCode: 'WAERS'
      F.cu_price_total   as CU_COST,
      @Semantics.amount.currencyCode: 'WAERS'
      F.al_price_total   as AL_COST,
      @Semantics.amount.currencyCode: 'WAERS'
      case when F.qirate > 0 then  cast(cast(F.s_mat_cost as abap.dec(11,2)) * F.qirate as abap.curr(11,2))
                             else F.s_mat_cost end  as SUBMAT_COST,
      @Semantics.amount.currencyCode: 'WAERS'
      case when F.qirate > 0 then  cast(cast(F.mfg_cost as abap.dec(11,2)) * F.qirate as abap.curr(11,2))
                             else F.mfg_cost end  as MFG_COST,
      @Semantics.amount.currencyCode: 'WAERS'
      case when F.qirate > 0 then  cast(cast(F.pkg_cost as abap.dec(11,2)) * F.qirate as abap.curr(11,2))
                             else F.pkg_cost end  as PKG_COST,

      @Semantics.amount.currencyCode: 'WAERS'
      case when F.qirate > 0 then  cast((cast(F.add_cost as abap.dec(11,2)) + cast(F.etc_cost as abap.dec(11,2))) * F.qirate as abap.curr(11,2))
                             else F.add_cost + F.etc_cost end  as add_COST,

      @Semantics.amount.currencyCode: 'WAERS'
      case when F.qirate > 0 then  cast(cast(F.s_mat_cost + F.mfg_cost + F.pkg_cost + F.add_cost as abap.dec(11,2)) * F.qirate as abap.curr(11,2))
                             else F.s_mat_cost + F.mfg_cost + F.pkg_cost + F.add_cost end  as sub_cost_total,

      F.kwaers as WAERS,
      C.kpein as PEINH,
      H.meins,
      case when P1.BEDAT is not null then P1.BEDAT else cast('' as kodatab) end as bedat,
      @Semantics.quantity.unitOfMeasure: 'KGMEINS'
      F.cu_c_qty + F.cu_s_qty + F.cu_t_qty as CU_QTY_TOTAL,
      @Semantics.quantity.unitOfMeasure: 'KGMEINS'
      F.al_c_qty + F.al_s_qty              as AL_QTY_TOTAL,
      F.kgmeins,
      @Semantics.quantity.unitOfMeasure: 'KGMEINS'
      F.cu_c_qty,
      @Semantics.quantity.unitOfMeasure: 'KGMEINS'
      F.cu_s_qty,
      @Semantics.quantity.unitOfMeasure: 'KGMEINS'
      F.cu_t_qty,
      @Semantics.quantity.unitOfMeasure: 'KGMEINS'
      F.al_c_qty,
      @Semantics.quantity.unitOfMeasure: 'KGMEINS'
      F.al_s_qty

} where D.loekz = '' and E.loekz = '' and E.esokz = '0' and (  F.cu_price_total <> 0 or  F.al_price_total <> 0 ) and H.lvorm = '' and C.loevm_ko = ''

union

select from a017 as A inner join konh as B on A.knumh = B.knumh and A.kappl = B.kappl and A.kschl = B.kschl
                         inner join konp as C on B.knumh = C.knumh and B.kappl = C.kappl and B.kschl = C.kschl
                         inner join eina as D on A.lifnr = D.lifnr and A.matnr = D.matnr
                         inner join eine as E on D.infnr = E.infnr and A.ekorg = E.ekorg and A.werks = E.werks and A.esokz = E.esokz
                         inner join zgtmmt1110 as F on E.infnr = F.infnr and D.matnr = F.matnr and D.lifnr = F.lifnr and E.ekorg = F.ekorg and E.werks = F.werks and E.esokz = F.esokz
                         inner join ZGTMM_CV_GET_MAX_ZGTMMT1110 as G on F.infnr = G.infnr and F.matnr = G.matnr and F.lifnr = G.lifnr and F.ekorg = G.ekorg and F.werks = G.werks and F.period = G.PERIOD
                         inner join mara as H on D.matnr = H.matnr
                         inner join marc as I on F.matnr = I.matnr and F.werks = I.werks
association [1..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language   
association [0..*] to ZGTMM_CV_GET_PODATA_MON  as P1 on $projection.lifnr = P1.lifnr and $projection.ekorg = P1.ekorg and $projection.matnr = P1.matnr                      

{
  key F.matnr,
  key F.werks,
  key E.ekorg,
  key F.lifnr,
      makt.maktx,
      I.beskz,
      F.cu_price_total   as CU_COST,

      F.al_price_total   as AL_COST,

      case when F.qirate > 0 then  cast(cast(C.kbetr as abap.dec(11,2)) * F.qirate as abap.curr(11,2))
                             else C.kbetr end  as SUBMAT_COST,
      cast(0 as abap.curr(11,2))  as MFG_COST,
      cast(0 as abap.curr(11,2))   as PKG_COST,

      cast(0 as abap.curr(11,2))   as add_COST,

      case when F.qirate > 0 then  cast(cast(C.kbetr as abap.dec(11,2)) * F.qirate as abap.curr(11,2))
                             else C.kbetr end  as sub_cost_total,

      C.konwa as WAERS,
      C.kpein as PEINH,
      H.meins,
      case when P1.BEDAT is not null then P1.BEDAT else cast('' as kodatab) end as bedat,
      F.cu_c_qty + F.cu_s_qty + F.cu_t_qty as CU_QTY_TOTAL,
      F.al_c_qty + F.al_s_qty              as AL_QTY_TOTAL,
      F.kgmeins,
      F.cu_c_qty,
      F.cu_s_qty,
      F.cu_t_qty,
      F.al_c_qty,
      F.al_s_qty

} where D.loekz = '' and E.loekz = '' and E.esokz = '0' and (  F.cu_price_total = 0 and  F.al_price_total = 0 ) and H.lvorm = '' and C.loevm_ko = ''


union

select from zgtmmt1040 as A inner join ZGTMM_CV_GET_MAX_ZGTMMT1040 as B on A.matnr = B.matnr and A.lifnr = B.lifnr and A.ekorg = B.ekorg and A.werks = B.werks
       and A.datab = B.datab and A.datbi = B.datbi 
       inner join mara as C on A.matnr = C.matnr inner join marc as D on A.matnr = D.matnr and A.werks = D.werks
association [1..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language       
association [0..*] to ZGTMM_CV_GET_PODATA_MON  as P1 on $projection.lifnr = P1.lifnr and $projection.ekorg = P1.ekorg and $projection.matnr = P1.matnr                      

{
  key A.matnr,
  key A.werks,
  key A.ekorg,
  key A.lifnr,
      makt.maktx,
      D.beskz,
      A.cu_sum as CU_COST,
      A.al_sum as AL_COST,
      A.mat_cost as SUBMAT_COST,
      A.mfg_cost,
      A.pak_cost as PKG_COST,
      A.others   as add_COST,

      A.mat_cost + A.mfg_cost + A.pak_cost + A.others  as sub_cost_total,

      cast('KRW' as abap.cuky(5)) as WAERS,
      A.peinh,
      C.meins,
      case when P1.BEDAT is not null then P1.BEDAT else cast('' as kodatab) end as bedat,
      A.cu_qt                              as CU_QTY_TOTAL,
      A.al_qt                              as AL_QTY_TOTAL,
      C.gewei                              as kgmeins,
      A.cu_qt                              as cu_c_qty,
      cast(0 as abap.quan(13,3))           as cu_s_qty,
      cast(0 as abap.quan(13,3))           as cu_t_qty,
      A.al_qt                              as al_c_qty,
      cast(0 as abap.quan(13,3))           as al_s_qty

} where A.esokz = '0' and C.lvorm = ''
 // and  C.mtart = 'MCHA' 
