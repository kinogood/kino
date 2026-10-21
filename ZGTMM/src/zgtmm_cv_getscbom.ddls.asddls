@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 사급 BOM 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETSCBOM 
as select from eina as A inner join eine as B on A.infnr = B.infnr
                         inner join mkal as C on A.matnr = C.matnr and B.werks = C.werks and B.verid = C.verid
                         inner join mast as D on C.matnr = D.matnr and C.werks = D.werks and C.stlan = D.stlan and C.stlal = D.stlal
                         inner join stko as E on D.stlnr = E.stlnr and D.stlal = E.stlal 
                         inner join stas as F on E.stlty = F.stlty and E.stlnr = F.stlnr and E.stlal = F.stlal
                         inner join stpo as G on F.stlty = G.stlty and F.stlnr = G.stlnr and F.stlkn = G.stlkn
                         inner join marc as H on G.idnrk = H.matnr and B.werks = H.werks
                         inner join mbew as I on H.matnr = I.matnr and H.werks = I.bwkey
                         inner join t001k as J on I.bwkey = J.bwkey
                         inner join t001 as K on J.bukrs = K.bukrs
                         inner join mara as L on G.idnrk = L.matnr
                         
association [0..1] to makt as MAKT on $projection.CMATNR = MAKT.matnr and MAKT.spras = $session.system_language
{
   key K.bukrs,
   key B.ekorg,
   key B.werks,
   key A.matnr,
   key A.lifnr,
   key B.esokz,
       B.verid,             //생산버전
       C.stlan,             //BOM 용도
       C.stlal,             //대체
       G.idnrk as CMATNR,   //투입자재
       makt.maktx,
       H.xchpf,
       I.vprsv,             //가격관리지시자
   
       @Semantics.amount.currencyCode: 'waers'
       case when I.vprsv ='S' then I.stprs
            else I.verpr end as PRICE ,
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       I.peinh,
       K.waers,
       L.meins 
} 
where A.loekz = '' and B.loekz = '' and B.esokz = '3' 
  and C.bdatu >= $session.user_date and C.adatu <= $session.user_date
  and E.stlty =  'M' and F.stlty = 'M' 
  and G.beikz = '' 
