@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 Item 구매 정보'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_CV_SO_ITEM_PO
  as select from    vbap as _SItem
    inner join      ekkn as _PAcc   on  _SItem.vbeln = _PAcc.vbeln
                                    and _SItem.posnr = _PAcc.vbelp
                                    and _PAcc.zekkn  = '01'
    inner join      ekpo as _PItem  on  _PAcc.ebeln  = _PItem.ebeln
                                    and _PAcc.ebelp  = _PItem.ebelp
                                    and _SItem.matnr = _PItem.matnr
                                    and _PItem.knttp = 'M'
                                    and _PItem.loekz = ''
    inner join      ekko as _PHdr   on _PItem.ebeln = _PHdr.ebeln
    inner join      lfa1 as _Vendor on _PHdr.lifnr = _Vendor.lifnr
    left outer join ekbe as _PHstry on  _PItem.ebeln  = _PHstry.ebeln
                                    and _PItem.ebelp  = _PHstry.ebelp
                                    and _PHstry.vgabe = '1'
{
  key _SItem.vbeln,
  key cast(_SItem.posnr as posnr_va preserving type ) as posnr, 

      _PItem.ebeln,
      _PItem.ebelp,
      max(_SItem.matnr)                               as matnr,
      max(_Vendor.lifnr)                              as lifnr,
      max(_Vendor.name1)                              as vendor_name,
      max(_PHdr.bedat)                                as bedat,
      max(_PHstry.budat)                              as budat,

      @Semantics.quantity.unitOfMeasure: 'meins'
      sum( case when _PHstry.shkzg = 'H' then _PHstry.menge * -1
                else _PHstry.menge end )              as gr_menge,
      _PItem.meins
}
group by
  _SItem.vbeln,
  _SItem.posnr,
  _PItem.ebeln,
  _PItem.ebelp,
  _SItem.matnr,
  _PItem.meins
