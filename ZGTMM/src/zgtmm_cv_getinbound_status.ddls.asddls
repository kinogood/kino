@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inbound Delivery Complete 상태 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETINBOUND_STATUS 
as 
select from ekes as A inner join lips as B on A.vbeln = B.vbeln and A.vbelp = B.posnr 
                      inner join likp as c on B.vbeln = c.vbeln 
                      inner join ekko as F on A.ebeln = F.ebeln
                      inner join ekpo as h on A.ebeln = h.ebeln and A.ebelp = h.ebelp
                      inner join t001w as i on h.werks = i.werks
                      inner join t001k as j on i.bwkey = j.bwkey
association [0..1] to dd07t as d on d.domvalue_l = $projection.wbsta and d.domname = 'STATV' and d.ddlanguage = $session.system_language   
association [0..1] to lfa1 as e on e.lifnr = $projection.lifnr           
association [0..1] to ZGTMM_CV_GETUSERNAME as g on $projection.ernam = g.USERID          
{
    key A.ebeln,
    key A.ebelp,
    key A.etens,
    key B.vbeln,
    key B.posnr,
    F.aedat,  //po 생성일
    c.lfdat,  //납품예정일
    h.matnr,
    h.txz01,
    c.lifnr,
    e.name1,
    B.werks,    
    B.wbsta,  // 품목 완료 지시지
    d.ddtext,
    F.ernam,
    g.NAME
} where B.lfimg > 0 and j.bukrs = '1000' and h.knttp = ''
