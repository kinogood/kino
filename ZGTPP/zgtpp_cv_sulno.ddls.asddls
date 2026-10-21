@AbapCatalog.sqlViewName: 'ZGTCVSULNO'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '완제품 기준 설계서 번호'
@Metadata.ignorePropagatedAnnotations: true
define view ZGTPP_CV_SULNO
  as select from zedt1000 as A
{
  key A.new_matnr      as MATNR,
  key A.sul_no,
  key max( A.rev_seq ) as REV_SEQ,
      A.spart,
      A.werks,
      A.sul_gubun,
      A.mat_desc,
      A.status
}
where A.status    =  'Z'
  and ( A.sul_gubun = '2' or
        A.sul_gubun = '3' or
        A.sul_gubun = '4' )
  and A.new_matnr <> ''
group by
  A.new_matnr,
  A.sul_no,
  A.spart,
  A.werks,
  A.sul_gubun,
  A.mat_desc,
  A.status
