@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매요청 주요 CHARACTERISTIC VALUE 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_PR_VCVALUE_MAIN 
as 
select from eban as a
association [0..1] to ZGTMM_CV_PR_VCVALUE as c1 on $projection.PDOC = c1.PDOC and $projection.PDOCITEM = c1.PDOCITEM and c1.atnam = 'SAP_MILLCA_LENGTH'
association [0..1] to ZGTMM_CV_PR_VCVALUE as c2 on $projection.PDOC = c2.PDOC and $projection.PDOCITEM = c2.PDOCITEM and c2.atnam = 'SAP_MILLCA_FACTOR'
association [0..1] to ZGTMM_CV_PR_VCVALUE as c3 on $projection.PDOC = c3.PDOC and $projection.PDOCITEM = c3.PDOCITEM and c3.atnam = 'PD_CA_COLOR_BASE'
association [0..1] to ZGTMM_CV_PR_VCVALUE as c4 on $projection.PDOC = c4.PDOC and $projection.PDOCITEM = c4.PDOCITEM and c4.atnam = 'PD_GA_DRUM_GUBUN'
association [0..1] to ZGTMM_CV_PR_VCVALUE as c5 on $projection.PDOC = c5.PDOC and $projection.PDOCITEM = c5.PDOCITEM and c5.atnam = 'PD_CA_COLOR_STRIPE'
association [0..1] to ZGTMM_CV_PR_VCVALUE as c6 on $projection.PDOC = c6.PDOC and $projection.PDOCITEM = c6.PDOCITEM and c6.atnam = 'PD_CA_COLOR_STRIPE_NO'
association [0..1] to ZGTMM_CV_PR_VCVALUE as c7 on $projection.PDOC = c7.PDOC and $projection.PDOCITEM = c7.PDOCITEM and c7.atnam = 'PD_CA_SPEC_NO'
association [0..1] to ZGTMM_CV_PR_VCVALUE as c8 on $projection.PDOC = c8.PDOC and $projection.PDOCITEM = c8.PDOCITEM and c8.atnam = 'PD_CA_PACKING_DM'
association [0..1] to ZGTMM_CV_PR_VCVALUE as c9 on $projection.PDOC = c9.PDOC and $projection.PDOCITEM = c9.PDOCITEM and c9.atnam = 'SAP_MILLCA_PACKAGING'
association [0..1] to ZGTMM_CV_PR_VCVALUE as c10 on $projection.PDOC = c10.PDOC and $projection.PDOCITEM = c10.PDOCITEM and c10.atnam = 'SAP_MILLCA_PACKAGING_CAT'

{
  key a.banfn as PDOC,
  key a.bnfpo as PDOCITEM,
  key a.matnr,
  key a.txz01,  
 
      case when c1.VALUE is not null then c1.VALUE else cast('' as atwrt) end as LENGTH,
      case when c1.VALUE is not null then c2.VALUE else cast('' as atwrt) end as DRQTY,
      case when c1.VALUE is not null then c3.VALUE else cast('' as atwrt) end as COLOR,
      case when c1.VALUE is not null then c4.VALUE else cast('' as atwrt) end as DRUM,
      case when c5.VALUE is not null then c5.VALUE else cast('' as atwrt) end as STRIPE_COLOR,
      case when c6.VALUE is not null then c6.VALUE else cast('' as atwrt) end as STRIPE_NO,
      case when c7.VALUE is not null then c7.VALUE else cast('' as atwrt) end as SPECNO, 
      case when c10.VALUE is not null and c10.VALUE = 'CO' then c9.VALUE
           else
                case when c8.VALUE is not null then c8.VALUE
                    else cast('' as atwrt) end
           end as drumname,
      // VALUE 는 드럼 품명(DRUMNAME)으로 치환되므로 자재코드 7자리는 원본 특성값 atwrt 를 사용
      case when c9.atwrt is not null then c9.atwrt
           else cast('' as atwrt) end as PACKCODE
  
}
