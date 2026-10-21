@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '가온전선 구매납품서 정보'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_GODELIVERY_DATA 
as select from zgtmmt9410 as A inner join ekpo as D on A.ebeln = D.ebeln and A.ebelp = D.ebelp  
                               inner join ZGTMM_CV_GET_MAX_ZGTMMT9410 as e on A.delno = e.delno and A.delitem = e.delitem
                               left outer join ZGTMM_CV_GET_MATDOC as B on A.delno = B.DELNO and A.delitem = B.DELITEM
                               left outer join ZGTMM_CV_GET_XBLNRNO  as C on A.delno = C.xblnr 
                             
            
{
  key A.zifkey,
  key A.system_id,
  key A.delno,
  key A.delitem,
  key A.werks,
      A.ebeln,
      A.ebelp,
      A.lgort,
      @Semantics.quantity.unitOfMeasure: 'MEINS'        
      A.menge,
      A.meins,
      @Semantics.quantity.unitOfMeasure: 'ERFME'         
      case when B.erfmg is not null then B.erfmg
           else cast(0 as abap.quan(13,3)) end as ERFMG,
      case when B.erfme is not null then B.erfme
           else cast('' as abap.unit) end as ERFME,     
      A.budat,
      A.emlif,
      A.licha,
      A.hsdat,
      A.status,
      A.doc_url,
      
      case when B.mjahr is not null then B.mjahr
           else cast('' as gjahr) end as MJAHR,
      case when B.mblnr is not null then B.mblnr
           else cast('' as mblnr) end as MBLNR,
      case when B.zeile is not null then B.zeile
           else cast('' as mblpo) end as ZEILE,
      case when B.budat is not null then B.budat
           else cast('' as budat) end as MBUDAT,           
      case when C.xblnr is not null then cast('Y' as abap.char(1))
           else cast('N' as abap.char(1)) end as GRYN,
      case when B.cancelled is not null then B.cancelled
           else cast('' as nsdm_cancelled_ind) end as cancelled,
      case when B.reversal_movement is not null then B.reversal_movement
           else cast('' as xstbw) end as reversal_movement,           
      case when B.cpudt is not null then B.cpudt
           else cast('' as cpudt ) end as CPUDT,     
      case when B.lfbja is not null then B.lfbja
           else cast('' as lfbja) end as lfbja,
      case when B.lfbnr is not null then B.lfbnr
           else cast('' as lfbnr) end as lfbnr,
      case when B.lfpos is not null then B.lfpos
           else cast('' as lfpos) end as lfpos,
      case when B.usnam is not null then B.usnam
           else cast('' as usnam) end as USNAM,
      case when B.sgtxt is not null then B.sgtxt
           else cast('' as sgtxt) end as sgtxt,
      case when B.ENAME is not null then B.ENAME
           else cast('' as ad_namtext) end as ENAME,
      case when B.tel_number is not null then B.tel_number
           else cast('' as ad_tlnmbr1) end as TEL_NUMBER,
      case when B.smtp_addr is not null then B.smtp_addr
           else cast('' as ad_smtpadr ) end as SMTP_ADDR,
      case when B.lgort is not null then B.lgort
           else cast('' as lgort_d ) end as LGORT_GR
           
           
                      
                                
} where A.system_id ='KSRM' and e.CHKSTATUS = '' and A.deltype = ''
