@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '판매오더 주요 CHARACTERISTIC VALUE 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SO_VCVALUE_MAIN 
as select from vbap as A 
association [0..1] to ZGTMM_CV_SO_VCVALUE as c1 on $projection.vbeln = c1.vbeln and $projection.posnr = c1.posnr and c1.atnam = 'SAP_MILLCA_LENGTH'
association [0..1] to ZGTMM_CV_SO_VCVALUE as c2 on $projection.vbeln = c2.vbeln and $projection.posnr = c2.posnr and c2.atnam = 'SAP_MILLCA_FACTOR'
association [0..1] to ZGTMM_CV_SO_VCVALUE as c3 on $projection.vbeln = c3.vbeln and $projection.posnr = c3.posnr and c3.atnam = 'PD_CA_COLOR_BASE'
association [0..1] to ZGTMM_CV_SO_VCVALUE as c4 on $projection.vbeln = c4.vbeln and $projection.posnr = c4.posnr and c4.atnam = 'PD_GA_DRUM_GUBUN'
association [0..1] to ZGTMM_CV_SO_VCVALUE as C5 on $projection.vbeln = C5.vbeln and $projection.posnr = C5.posnr and C5.atnam = 'PD_AA_WITNESS_INSPECTION'
association [0..1] to ZGTMM_CV_SO_VCVALUE as c6 on $projection.vbeln = c6.vbeln and $projection.posnr = c6.posnr and c6.atnam = 'PD_CA_COLOR_STRIPE'
association [0..1] to ZGTMM_CV_SO_VCVALUE as c7 on $projection.vbeln = c7.vbeln and $projection.posnr = c7.posnr and c7.atnam = 'PD_CA_COLOR_STRIPE_NO'
association [0..1] to ZGTMM_CV_SO_VCVALUE as c8 on $projection.vbeln = c8.vbeln and $projection.posnr = c8.posnr and c8.atnam = 'PD_CA_SPEC_NO'
association [0..1] to ZGTMM_CV_SO_VCVALUE as c9 on $projection.vbeln = c9.vbeln and $projection.posnr = c9.posnr and c9.atnam = 'PD_CA_PACKING_DM'
association [0..1] to ZGTMM_CV_SO_VCVALUE as c10 on $projection.vbeln = c10.vbeln and $projection.posnr = c10.posnr and c10.atnam = 'SAP_MILLCA_PACKAGING'
association [0..1] to ZGTMM_CV_SO_VCVALUE as c11 on $projection.vbeln = c11.vbeln and $projection.posnr = c11.posnr and c11.atnam = 'SAP_MILLCA_PACKAGING_CAT'


association [0..1] to ZGTMM_CV_SO_VCVALUE as S1 on $projection.vbeln = S1.vbeln and $projection.posnr = S1.posnr and S1.atnam = 'PD_CA_MARK_CONTENTS_1ST'
association [0..1] to ZGTMM_CV_SO_VCVALUE as S2 on $projection.vbeln = S2.vbeln and $projection.posnr = S2.posnr and S2.atnam = 'PD_CA_MARK_CONTENTS_2ND'
association [0..1] to ZGTMM_CV_SO_VCVALUE as S3 on $projection.vbeln = S3.vbeln and $projection.posnr = S3.posnr and S3.atnam = 'PD_CA_MARK_CONTENTS_3RD'
association [0..1] to ZGTMM_CV_SO_VCVALUE as S4 on $projection.vbeln = S4.vbeln and $projection.posnr = S4.posnr and S4.atnam = 'PD_CA_MARK_CONTENTS_4TH'
association [0..1] to ZGTMM_CV_SO_VCVALUE as S5 on $projection.vbeln = S5.vbeln and $projection.posnr = S5.posnr and S5.atnam = 'PD_CA_MARK_CONTENTS_5TH'
association [0..1] to ZGTMM_CV_SO_VCVALUE as S6 on $projection.vbeln = S6.vbeln and $projection.posnr = S6.posnr and S6.atnam = 'PD_CA_MARK_CONTENTS_6TH'
association [0..1] to ZGTMM_CV_SO_VCVALUE as S7 on $projection.vbeln = S7.vbeln and $projection.posnr = S7.posnr and S7.atnam = 'PD_CA_MARK_CONTENTS_7TH'
association [0..1] to ZGTMM_CV_SO_VCVALUE as S8 on $projection.vbeln = S8.vbeln and $projection.posnr = S8.posnr and S8.atnam = 'PD_CA_MARK_CONTENTS_8TH'
association [0..1] to ZGTMM_CV_SO_VCVALUE as S9 on $projection.vbeln = S9.vbeln and $projection.posnr = S9.posnr and S9.atnam = 'PD_CA_MARK_CONTENTS_9TH'
association [0..1] to ZGTMM_CV_SO_VCVALUE as S10 on $projection.vbeln = S10.vbeln and $projection.posnr = S10.posnr and S10.atnam = 'PD_CA_MARK_CONTENTS_10TH'
{
  key A.vbeln,
  key A.posnr,
  key A.matnr,
      @Semantics.quantity.unitOfMeasure: 'VRKME' 
      A.kwmeng,
      A.vrkme,
      case when c1.VALUE is not null then 
         case when c1.VALUE = '' then cast('1' as atwrt)
              else c1.VALUE end
         else cast('1' as atwrt) end as LENGTH,

      case when c2.VALUE is not null then 
          case when c2.VALUE = '' then cast('1' as atwrt)
              else c2.VALUE end
         else cast('1' as atwrt) end as DRQTY,
      case when c3.VALUE is not null then c3.VALUE
           else cast('' as atwrt) end as COLOR,
      case when c6.VALUE is not null then c6.VALUE
           else cast('' as atwrt) end as STRIPE_COLOR,
      case when c7.VALUE is not null then c7.VALUE
           else cast('' as atwrt) end as STRIPE_NO,
      case when c4.VALUE is not null then c4.VALUE
           else cast('' as atwrt) end as DRUM,
      case when C5.VALUE is not null then C5.VALUE
           else cast('' as atwrt) end as INSPECTION,         
      case when c8.VALUE is not null then c8.VALUE
           else cast('' as atwrt) end as specno,  
      case when c11.VALUE is not null and c11.VALUE = 'CO' then c10.VALUE
           else
                case when c9.VALUE is not null then c9.VALUE
                    else cast('' as atwrt) end
           end as drumname,
      // VALUE 는 드럼 품명(DRUMNAME)으로 치환되므로 자재코드 7자리는 원본 특성값 atwrt 를 사용
      case when c10.atwrt is not null then c10.atwrt
           else cast('' as atwrt) end as PACKCODE,                 
      CONCAT(S1.atwrt,CONCAT(S2.atwrt,CONCAT(S3.atwrt,CONCAT(S4.atwrt,CONCAT(S5.atwrt,CONCAT(S6.atwrt,CONCAT(S7.atwrt,CONCAT(S8.atwrt,CONCAT(S9.atwrt,S10.atwrt)))))))))  as MCONTENTS
            
} 

