@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] G/I 미완료 납품문서 Picking 수량'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_OPEN_PICKED_QTY
  as select from lips as _Dlv
    inner join   marc as _Mst  on  _Dlv.matnr = _Mst.matnr
                               and _Dlv.werks = _Mst.werks
    inner join   t006 as _Unit on _Dlv.vrkme = _Unit.msehi
    
    left outer join ZGTSD_CV_GET_VCOFSO as _Char on _Dlv.vgbel = _Char.vbeln
                                                 and _Dlv.vgpos = _Char.posnr
                                                 and _Dlv.matnr = _Char.matnr
{                                                                                                     
  key cast(_Dlv.vgbel as vbeln_va preserving type ) as vbeln,
  key cast(_Dlv.vgpos as posnr_va preserving type ) as posnr,
  key _Dlv.matnr,
  key _Dlv.charg,
  key _Dlv.werks,
  key _Dlv.lgort,

      @Semantics.quantity.unitOfMeasure: 'vrkme'
      //      sum( _Dlv.lfimg ) as Total_Picked_qty,
      cast(
         case when _Unit.dimid = 'LENGTH' and _Mst.dpcbt = 'A'
                    then case when _Char.LENGTH is not initial                         
                              then division(  cast(_Dlv.lfimg as abap.dec(13,3))
                                            , cast(_Char.LENGTH as abap.dec(13,3)), 0)
                         else 0 end
              when _Unit.dimid = 'LENGTH' and _Mst.dpcbt = 'C'
                    then 1
              else _Dlv.lfimg end
      as abap.quan(13,3))                           as picked_qty,
      
      _Dlv.vrkme
}
where
      _Dlv.wbsta <> 'C'
  and _Dlv.kosta =  'C'
  and _Dlv.lfimg >  0
