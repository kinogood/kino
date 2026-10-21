@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매오더 주요 Characteristic Value 조회2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_PO_VCVALUE_MAIN2 
as select from ekpo as a
association [0..1] to ZGTMM_CV_PO_VCVALUE as c1 on $projection.PDOC = c1.PDOC and $projection.PDOCITEM = c1.PDOCITEM and c1.atnam = 'SAP_MILLCA_LENGTH'
association [0..1] to ZGTMM_CV_PO_VCVALUE as c2 on $projection.PDOC = c2.PDOC and $projection.PDOCITEM = c2.PDOCITEM and c2.atnam = 'SAP_MILLCA_FACTOR'
association [0..1] to ZGTMM_CV_PO_VCVALUE as c3 on $projection.PDOC = c3.PDOC and $projection.PDOCITEM = c3.PDOCITEM and c3.atnam = 'PD_CA_COLOR_BASE'
association [0..1] to ZGTMM_CV_PO_VCVALUE as c4 on $projection.PDOC = c4.PDOC and $projection.PDOCITEM = c4.PDOCITEM and c4.atnam = 'PD_GA_DRUM_GUBUN'

{
  key a.ebeln as PDOC,
  key a.ebelp as PDOCITEM,
  
  key a.matnr,
  key a.txz01,  
      case when c1.VALUE is not null then 
         case when c1.VALUE = '' then cast('1' as atwrt)
              else c1.VALUE end
         else cast('1' as atwrt) end as LENGTH,
      case when c2.VALUE is not null then 
          case when c2.VALUE = '' then cast(cast('1' as abap.dec(5,0)) as abap.int4)
              else cast(cast(c2.VALUE as abap.dec(5,0)) as abap.int4) end
         else cast(cast('1' as abap.dec(5,0)) as abap.int4) end as DRQTY, 
      case when c3.VALUE is not null then c3.VALUE
           else cast('' as atwrt) end as COLOR,
      case when c4.VALUE is not null then c4.VALUE
           else cast('' as atwrt) end as DRUM
}
