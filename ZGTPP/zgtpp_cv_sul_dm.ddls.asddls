@AbapCatalog.sqlViewName: 'ZGTCVSULDM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '설계서 기준 자재량 소요 정보'
@Metadata.ignorePropagatedAnnotations: true
define view ZGTPP_CV_SUL_DM
  as select from    zgtcvsulno as A
    left outer join zedt1090   as B on  A.sul_no  = B.sul_no
                                    and A.rev_seq = B.rev_seq
    left outer join zedt1010   as C on  B.sul_no   = C.sul_no
                                    and B.rev_seq  = C.rev_seq
                                    and B.gong_seq = C.gong_seq
    left outer join zedt0011   as d on C.gong_cd = d.gong_cd
    left outer join mara       as E on B.matnr   = E.matnr
{
  key A.matnr as FINSHMAT,
  key A.werks,
  key A.spart,
  key A.sul_no,
  key A.rev_seq,
  key B.gong_seq,
      C.gong_cd,
      d.gong_nm,
      B.matnr,
      B.jaje_qty,
      B.jaje_unit,
      E.mtart
}
where E.mtart = 'ROH1' 
   or E.mtart = 'ROH2' 
   or E.mtart = 'MRM1' 
   or E.mtart = 'MRM2'
   or E.mtart = 'MRM3'
