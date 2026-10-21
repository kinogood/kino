@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SRM 전송 PO 특성 정보 조회(공통)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_PODATA_C 
as select from ZGTMM_CV_GET_PODATA_B as A
association [0..1] to ZGTMM_CV_PO_VCVALUE_MAIN as VC on $projection.ebeln = VC.PDOC and $projection.ebelp = VC.PDOCITEM

{
 
   key    ebeln,
   key    ebelp,
          atnam,          
          atbez,
          case when atnam = 'SAP_MILLCA_FACTOR' then
                case when cast(VC.LENGTH as abap.dec(13,3)) > 0 then
                     cast(cast(cast(A.menge as abap.dec(13,3)) / cast(VC.LENGTH as abap.dec(13,3)) as int4) as atwrt)
                else 
                     cast(cast(A.menge as abap.dec(13,3)) as atwrt) 
                end  
               else 
           atwrt end as atwrt,
          ATWRT_O   
} where A.atnam <> 'PD_GA_PACKAGE_METHOD'

union all
select from ZGTMM_CV_GET_PODATA_B as A inner join ZGTMM_CV_GET_CAWNT as B on A.atnam = B.atnam and A.atwrt = B.atwrt
association [0..1] to ZGTMM_CV_PO_VCVALUE_MAIN as VC on $projection.ebeln = VC.PDOC and $projection.ebelp = VC.PDOCITEM
{
 
   key    A.ebeln,
   key    A.ebelp,
          A.atnam,          
          A.atbez,
          cast(B.atwtb as atwrt) as atwrt,
          A.ATWRT_O   
} where A.atnam = 'PD_GA_PACKAGE_METHOD'
