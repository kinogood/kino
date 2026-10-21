@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매 자재 납품 성적서 정보'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_MAT_INSPCERT 
as select from zgtmmt9410 as A inner join ekpo as B on A.ebeln = B.ebeln and A.ebelp = B.ebelp
                               inner join ekko as C on B.ebeln = C.ebeln
                               inner join t001k as D on B.werks = D.bwkey
                               inner join eket as I on B.ebeln = I.ebeln and B.ebelp = I.ebelp
                               inner join mara as F on B.matnr = F.matnr  
                               inner join zgtmmt9000 as G on A.zifkey = G.zifkey
                               inner join ZGTMM_CV_GET_MAX_ZGTMMT9410 as H on A.delno = H.delno and A.delitem = H.delitem
association [0..1] to lfa1 as A1 on $projection.lifnr = A1.lifnr
association [0..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language
association [0..1] to t001l as T001L on $projection.werks = T001L.werks and $projection.lgort = T001L.lgort
                               
{
 key   A.delno,
 key   A.delitem,
       D.bukrs, 
       A.werks,
       A.ebeln,
       A.ebelp,
       B.matnr,
       case when F.zzmaktx80 <> '' then F.zzmaktx80 else makt.maktx end as MAKTX,
       C.aedat,
       I.eindt,
       C.lifnr,
       A1.name1 as LIFNR_N,
       A.lgort,
       t001l.lgobe as LGORT_N,
       @Semantics.quantity.unitOfMeasure: 'MEINS'         
       A.menge,
       A.meins,
       A.budat,
       A.licha,
       A.hsdat,
       A.status,
       A.doc_url,
       A.potype,
       A.delclose,
       G.erdat as QCREQDATE
} where A.status = '' and I.etenr = '0001' and G.zifno = 'MM00031' and H.CHKSTATUS = '' and A.deltype = ''
