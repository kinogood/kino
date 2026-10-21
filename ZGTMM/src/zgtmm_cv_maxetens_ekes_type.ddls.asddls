@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매오더 Confirmation 최종 정보 조회2'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZGTMM_CV_MAXETENS_EKES_TYPE 
as select from ekes
{
    key ebeln,
    key ebelp,
    key ebtyp,
    max(etens) as ETENS
} group by ebeln, ebelp, ebtyp
