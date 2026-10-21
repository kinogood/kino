@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재문서 정보 조회(취소 제외)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_MATDOC 
as select from matdoc as A inner join ekpo as B on A.ebeln = B.ebeln and A.ebelp = B.ebelp 
                           inner join ekko as C on B.ebeln = C.ebeln
                           inner join P_USER002 as d on A.usnam = d.bname
                           left outer join zgtmmt5000 as E on A.mjahr = E.mjahr and A.mblnr = E.mblnr and A.zeile = E.zeile
{
  key A.mjahr,
  key A.mblnr,
  key A.zeile,
      B.bukrs,
      A.werks,
      C.bedat,
      A.budat,
      A.cpudt,
      A.xblnr,
      cast(LEFT(A.budat,6) as abap.numc(6)) as PERIOD,
      C.lifnr,
      C.ekorg,
      A.ebeln,
      A.ebelp,
      case when B.pstyp = '3' then B.pstyp
           else cast('0' as abap.char(1)) end as ESOKZ,
      B.matnr,
      LEFT(A.sgtxt,13) as DELNO,
      SUBSTRING(A.sgtxt,15,4) as DELITEM,
      @Semantics.quantity.unitOfMeasure: 'ERFME'  
      A.erfmg,       //입고수량
      A.erfme,       //입고단위
      @Semantics.amount.currencyCode: 'waers'
      B.netpr as PO_NETPR,
      A.waers,      
      B.peinh as PO_PEINH,
      B.bprme,
      B.meprf,
      @Semantics.amount.currencyCode: 'waers'
      cast(cast((cast(A.erfmg as abap.dec(13,3)) * cast(B.netpr as abap.dec(13,3))  / B.peinh) as abap.dec(13,2)) as abap.curr(13,2)) as PO_BRTWR,
      A.cancelled,
      A.reversal_movement,
      A.sjahr as lfbja,
      A.smbln as lfbnr,
      A.smblp as lfpos,
      A.usnam,
      A.sgtxt,
      d.name_text as ENAME,
      d.tel_number,
      d.smtp_addr,
      case when E.mblnr is not null then E.zgoconf 
           else cast('' as zgte_confirm) end as ZGOCONF,
      case when E.mblnr is not null then E.zvdconf 
           else cast('' as zgte_confirm) end as ZVDCONF,
      A.lgort     
      
} where A.ebeln <> ''  




