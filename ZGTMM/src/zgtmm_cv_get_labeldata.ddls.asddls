@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM 제품 라벨 인쇄 정보 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_LABELDATA 
as select from zgtsdt1199 as A inner join ekkn as B on A.vbeln = B.vbeln and A.posnr = B.vbelp and B.zekkn = '01'
                               inner join ekpo as C on B.ebeln = C.ebeln and B.ebelp = C.ebelp
                               inner join ekko as D on C.ebeln = D.ebeln
 
                               
{
   key D.bukrs,
   key D.lifnr,
   key A.vbeln,
   key A.posnr,
   A.zseq,
   A.zzlabel_type,
   A.zzlabel_prtqt,
   A.zzlabel_title1_n as TITLE1,
   A.zzlabel_title2_n as TITLE2,
   A.zzlabel_title3_n as TITLE3,
   A.zzlabel_title4_n as TITLE4,  
   A.zzlabel_title1 as DESC1,
   A.zzlabel_title2 as DESC2,
   A.zzlabel_title3 as DESC3,
   A.zzlabel_title4 as DESC4
} where A.lvorm = ''
