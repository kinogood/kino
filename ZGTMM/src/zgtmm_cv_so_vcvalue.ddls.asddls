@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '판매오더 CHARACTERISTIC VALUE 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SO_VCVALUE 
as 
select from vbap as A inner join ibin as B on A.cuobj = B.instance
                      inner join ibinvalues as C on B.in_recno = C.in_recno
                      inner join ibsymbol as D on C.symbol_id = D.symbol_id      
                      inner join cabn as E on D.atinn = E.atinn          
                      inner join makt as F on A.matnr = F.matnr and F.spras = $session.system_language
                      inner join vbak as g on g.vbeln = A.vbeln
association [1..1] to cabnt as CABNT on $projection.atinn = CABNT.atinn and CABNT.spras = $session.system_language 
association [1..1] to ZGTMM_CV_GET_DRUM_NAME as DR on $projection.atwrt = DR.MATNR 
{
  key A.vbeln,
  key A.posnr,
  key A.matnr,
  key F.maktx,  
  key E.atnam,
      cabnt.atbez,
      case when E.atnam = 'PD_CA_PACKING_DM' then
         cast(DR.DRUMNAME as atwrt)
           when E.atnam = 'SAP_MILLCA_PACKAGING' then
         cast(DR.DRUMNAME as atwrt)
      else      
      case when D.atwrt = '' then cast(cast(ROUND(cast(C.dec_value_from as abap.dec(13,5)),3) as abap.dec(13,3)) as atwrt)
           else D.atwrt end 
      end as VALUE,
      cast(ROUND(cast(C.dec_value_from as abap.dec(13,5)),3) as abap.dec(13,3)) as VALUE_FROM,
      D.atwrt,
      D.atinn,
      @Semantics.quantity.unitOfMeasure: 'VRKME' 
      A.kwmeng,
      A.vrkme           
} where B.valto = 99991231235959 and g.bukrs_vf = '6000'       

union

select from vbap as A inner join makt as b on A.matnr = b.matnr and b.spras = $session.system_language
                      inner join vbak as c on c.vbeln = A.vbeln
                      inner join ZGTMM_CV_GET_SALES_TEAM as d on A.vbeln = d.vbeln and c.vkorg = d.vkorg
{
  key A.vbeln,
  key A.posnr,
  key A.matnr,
  key b.maktx,  
  key cast('PD_STD_TEAM2DGIT' as atnam) as ATNAM,
      cast('영업 팀 코드' as atbez) as ATBEZ,
      cast(d.zzyuscd as atwrt) as VALUE,
      cast(ROUND(cast('0' as abap.dec(13,5)),3) as abap.dec(13,3)) as VALUE_FROM,
      cast(d.zzyuscd as atwrt) as atwrt,
      cast('' as atinn) as atinn,
      A.kwmeng,
      A.vrkme           
} where d.zzyuscd <> ''
