@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '사급제품 꼬리표 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_TAGNUMBER 
as 
select from matdoc as A inner join zmmti34 as B on A.werks = B.werks and A.matnr = B.matnr and A.sgtxt = B.tagnr
                        inner join ekpo as C on A.ebeln = C.ebeln and A.ebelp = C.ebelp and A.matnr = C.matnr
                        inner join marc as D on C.matnr = D.matnr and C.werks = D.werks
{
  
   key A.mjahr,
   key A.mblnr,
   key A.zeile,
   key A.werks,
   key cast(A.ebeln as aufnr) as AUFNR,
   key B.tagnr,
   key A.ebelp,
   key A.charg,
       A.budat,
       A.matnr,
       B.vbeln,
       B.posnr,
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       A.menge as MGVRG,
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       A.menge as REMAIN,
       C.lgort,
       A.meins,
       LEFT(D.dispo,2) as SPGCD,
       RIGHT(LEFT(C.matkl,7),3) as PROCD,
       cast('1' as zfostcnt) as FOSTCNT,
       case when C.pstyp = '3' 
            then cast('X' as zoutflg)
            else cast('' as zoutflg) end as OUTFLG,
       case when A.sobkz = 'O' 
            then cast('Y' as zgiflg)
            else cast('X' as zgiflg) end as GIFLG,
       cast('Y' as zgrflg) as GRFLG,
       cast('OK' as zinspflg) as INSPFLG,    
       $session.user_date as WKDAT,
       $session.user_date as GRINDAT,   
       TSTMP_TO_TIMS(TSTMP_CURRENT_UTCTIMESTAMP(), ABAP_USER_TIMEZONE($session.user, $session.client, 'FAIL'), $session.client, 'FAIL') as GRINTIM,
       $session.user as GRINNAM
} where A.bwart = '101' and A.cancelled = ''
