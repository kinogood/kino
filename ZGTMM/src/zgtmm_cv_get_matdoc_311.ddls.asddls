@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재문서 정보 조회-매입/매출보관품 311(MES 드럼라벨)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_MATDOC_311
as select from zgtmmt9423 as R
                           left outer join zgtmmt9425 as P on  P.zifkey      = R.zifkey
                                                     and P.system_id   = R.system_id
                                                     and P.dr_label_no = R.dr_label_no
                                                     and P.ebeln       = R.ebeln
                                                     and P.ebelp       = R.ebelp
                           inner join matdoc as A on (    A.mjahr = R.mjahr
                                                      and A.mblnr = R.mblnr )
                                                  or (    A.sjahr = R.mjahr
                                                      and A.smbln = R.mblnr )
                           left outer join P_USER002 as D on A.usnam = D.bname
{
  key A.mjahr,
  key A.mblnr,
  key A.zeile,
      A.werks,
      A.budat,
      A.cpudt,
      R.ebeln,
      R.ebelp,
      P.delno   as DELNO,
      P.delitem as DELITEM,
      @Semantics.quantity.unitOfMeasure: 'ERFME'
      A.erfmg,       //이동수량
      A.erfme,       //이동단위
      A.bwart,
      A.cancelled,
      A.reversal_movement,
      A.sjahr as lfbja,
      A.smbln as lfbnr,
      A.smblp as lfpos,
      A.usnam,
      D.name_text as ENAME,
      D.tel_number,
      D.smtp_addr,
      A.lgort
}
where R.mblnr <> ''
  and ( A.bwart = '311' or A.bwart = '312' )
  and A.shkzg = 'S'
