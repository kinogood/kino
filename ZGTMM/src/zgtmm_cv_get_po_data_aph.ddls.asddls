@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매오더 승인 헤더 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_PO_DATA_APH 
as select from ZGTMM_CV_GET_PO_DATA_GR as A
association [0..1] to zgtmmt1020 as AR on $projection.werks = AR.werks and $projection.ekgrp = AR.ekgrp 
{
      key A.ebeln,
          A.bukrs,
          A.ekorg,
          A.ekotx,  
          A.werks,
          A.WERKS_N,
          A.ekgrp,
          A.eknam,
          A.AEDAT_H,
          A.ernam,   
          A.lifnr,
          A.name1,
          A.frggr,
          A.REL_STAT,
          A.PO_WAERS,          

          @Semantics.amount.currencyCode: 'PO_waers'    
          sum(A.brtwr) as BRTWR,
       
          A.BME,
          @Semantics.quantity.unitOfMeasure: 'BME'           
          sum(A.VGW_T) as VGW_T,
          @Semantics.quantity.unitOfMeasure: 'GR_MEINS'            
          sum(A.GR_MENGE) as gr_menge,
          A.GR_MEINS,
           @Semantics.quantity.unitOfMeasure: 'IV1_BPRME'            
          sum(A.IV1_QTY) as iv1_qty,
          A.IV1_BPRME,
          AR.aname,
          A.ihrez,
          A.IHREZ_N
     
} where A.GR_MENGE = 0 and A.IV1_QTY = 0 and A.loekz = '' 
                       and ( A.lifnr like '2%') /* 공급업체가 '2'로 시작하는 경우 */
                       or  ( A.GR_MENGE = 0 and A.IV1_QTY = 0 )  /* 그 외의 경우 적용될 조건*/

group by  A.ebeln, A.bukrs, A.ekorg, A.ekotx, A.werks, A.WERKS_N, A.ekgrp, A.eknam, A.AEDAT_H, A.ernam,   
          A.lifnr, A.name1, A.frggr, A.REL_STAT, A.PO_WAERS , A.BME, A.GR_MEINS, A.IV1_BPRME, AR.aname, A.ihrez, A.IHREZ_N
