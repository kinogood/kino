@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[BD] 원자재 송신 로그 - MM00067'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_BD_RPOGR_LOG as 
    select from zgtmmt9000 as a inner join zgtmmt6060 as b
                                        on a.zifkey = b.zifkey
                                        
{
    key a.zifno,
    key a.zifkey,
    key a.system_id,
        a.zstat,
        a.message,
        a.ifdat,
        a.iftim,
        a.ifnam,
        
        b.mblnr,
        b.mjahr,
        b.zeile,
        b.cpudt,
        b.budat,
        b.ebeln,
        b.ebelp,
        b.knttp,
        b.job_no,
        b.line_no,
        b.serial_no,
        b.werks,
        b.ekgrp,
        b.lifnr,
        b.name1,
        b.matnr,
        b.mtart,
        b.txz01,
        b.bednr,
        b.matkl,
        b.bwart,
        b.shkzg,
        b.bstme,
        @Semantics.quantity.unitOfMeasure: 'bstme'
        b.bstmg,
        b.lgort_sid,
        b.lifnr_sid,
        b.name1_sid
        
} where a.zifno = 'MM00067'
