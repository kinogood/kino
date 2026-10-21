@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매오더 주요 CHARACTERISTIC VALUE 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_PO_VCVALUE_MAIN 
as select from ekpo as a
association [0..1] to ZGTMM_CV_PO_VCVALUE as c1 on $projection.PDOC = c1.PDOC and $projection.PDOCITEM = c1.PDOCITEM and c1.atnam = 'SAP_MILLCA_LENGTH'
association [0..1] to ZGTMM_CV_PO_VCVALUE as c2 on $projection.PDOC = c2.PDOC and $projection.PDOCITEM = c2.PDOCITEM and c2.atnam = 'SAP_MILLCA_FACTOR'
association [0..1] to ZGTMM_CV_PO_VCVALUE as c3 on $projection.PDOC = c3.PDOC and $projection.PDOCITEM = c3.PDOCITEM and c3.atnam = 'PD_CA_COLOR_BASE'
association [0..1] to ZGTMM_CV_PO_VCVALUE as c4 on $projection.PDOC = c4.PDOC and $projection.PDOCITEM = c4.PDOCITEM and c4.atnam = 'PD_GA_DRUM_GUBUN'
association [0..1] to ZGTMM_CV_PO_VCVALUE as c5 on $projection.PDOC = c5.PDOC and $projection.PDOCITEM = c5.PDOCITEM and c5.atnam = 'PD_CA_PACKING_DM'
association [0..1] to ZGTMM_CV_PO_VCVALUE as c6 on $projection.PDOC = c6.PDOC and $projection.PDOCITEM = c6.PDOCITEM and c6.atnam = 'SAP_MILLCA_PACKAGING'
association [0..1] to ZGTMM_CV_PO_VCVALUE as c7 on $projection.PDOC = c7.PDOC and $projection.PDOCITEM = c7.PDOCITEM and c7.atnam = 'SAP_MILLCA_PACKAGING_CAT'

{
  key a.ebeln as PDOC,
  key a.ebelp as PDOCITEM,
  
  key a.matnr,
  key a.txz01,  
      case when c1.VALUE is not null then 
         case when c1.VALUE = '' then cast('1' as atwrt)
              else c1.VALUE end
         else 
           cast('1' as atwrt)  
         end as LENGTH,
      case when c2.VALUE is not null then 
          case when c2.VALUE = '' then cast('1' as atwrt)
              else c2.VALUE end
         else cast('1' as atwrt) end as DRQTY, 
      case when c3.VALUE is not null then c3.VALUE
           else cast('' as atwrt) end as COLOR,
      case when c4.VALUE is not null then c4.VALUE
           else cast('' as atwrt) end as DRUM,
      case when c7.VALUE is not null and c7.VALUE = 'CO' then c6.VALUE
           else
                case when c5.VALUE is not null then c5.VALUE
                    else cast('' as atwrt) end
           end as drumname      
}
