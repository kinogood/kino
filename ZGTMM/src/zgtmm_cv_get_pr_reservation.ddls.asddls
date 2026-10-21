@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매요청 임가공 소요량 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_PR_RESERVATION 
as select from resb as A inner join eban as B on A.banfn = B.banfn and A.bnfpo = B.bnfpo
                         inner join ebkn as C on B.banfn = C.banfn and B.bnfpo = C.bnfpo and C.zebkn = '01'
                         inner join mara as d on A.matnr = d.matnr
association [0..1] to makt as MAKT on $projection.matnr = MAKT.matnr and MAKT.spras = $session.system_language
association [0..1] to zgtppt1010 as z1 on $projection.werks  = z1.fld_01 and $projection.matkl  = z1.fld_02 and z1.module_kind ='MM' and z1.codegrp ='0030'                           
{
  key A.rsnum,
  key A.rspos,
  key A.werks,
      B.banfn,
      B.bnfpo,
      A.matnr,
      makt.maktx,
      A.bdter,
      @Semantics.quantity.unitOfMeasure: 'MEINS'        
      A.bdmng,
      A.meins,
      C.vbeln,
      C.vbelp,
      d.matkl,
      case when z1.fld_03 is not null then z1.fld_03 else cast('' as kostl) end as KOSTL,
      case when z1.fld_04 is not null then z1.fld_04 else cast('' as saknr) end as SAKTO        
} where B.pstyp = '3' and C.vbeln <> ''
