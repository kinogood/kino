@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매요청 CHARACTERISTIC VALUE 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_PR_VCVALUE 
as 
select from eban as A inner join ibin as B on A.cuobj = B.instance
                      inner join ibinvalues as C on B.in_recno = C.in_recno
                      inner join ibsymbol as D on C.symbol_id = D.symbol_id      
                      inner join cabn as E on D.atinn = E.atinn          
                      inner join t001w as W on A.werks = W.werks
                      inner join t001k as K on W.bwkey = K.bwkey
association [1..1] to cabnt as CABNT on $projection.atinn = CABNT.atinn and CABNT.spras = $session.system_language 
association [1..1] to ZGTMM_CV_GET_DRUM_NAME as DR on $projection.atwrt = DR.MATNR 
{
  key A.banfn as PDOC,
  key A.bnfpo as PDOCITEM,
  key A.matnr,
  key A.txz01,
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
      D.atinn     
} where B.valto = 99991231235959
    and K.bukrs = '6000'
