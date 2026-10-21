@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 구매요청 특성 정보'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_GET_VCOFPR 
  as select from eban       as a
    inner join   ibin       as b  on  a.cuobj = b.instance
                                  and b.valto = 99991231235959
    inner join   ibinvalues as cv on b.in_recno = cv.in_recno
    inner join   ibsymbol   as cs on cv.symbol_id = cs.symbol_id
    inner join   cabn       as d  on cs.atinn = d.atinn
{
  key a.banfn,
  key a.bnfpo,

      a.matnr,
      a.txz01,
      a.werks,
      a.lgort,
      @Semantics.quantity.unitOfMeasure: 'meins'
      a.menge,
      a.meins,

      case when d.atnam = 'SAP_MILLCA_LENGTH'
           then fltp_to_dec( cs.atflv as abap.dec(13,3) )
           when d.atnam = 'SAP_MILLCA_FACTOR'
           then fltp_to_dec( cs.atflv as abap.dec(13,3) )
           else cs.atflv end as atflv

}
where
  a.loekz <> 'X'
