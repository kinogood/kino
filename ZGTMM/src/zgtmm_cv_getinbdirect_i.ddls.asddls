@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직납 납품서 품목 정보'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GETINBDIRECT_I 
as 
select from lips as A inner join t001w as B on A.werks = B.werks
                      inner join t001k as E on B.bwkey = E.bwkey
                      inner join t001 as F on E.bukrs = F.bukrs
association [0..1] to makt as c on $projection.matnr =  c.matnr and c.spras = $session.system_language
association [0..1] to Mbv_Mbew as d on $projection.werks =  d.bwkey and $projection.matnr =  d.matnr


{
 key  A.vbeln,
 key  A.werks,
 key  A.posnr,
      A.matnr,
      c.maktx,
      @Semantics.quantity.unitOfMeasure: 'MEINS'  
      A.lfimg,
      A.vrkme as meins,
      A.charg,
      A.lichn,
      A.lgort,
      A.ebeln,
      A.ebelp,
      @Semantics.amount.currencyCode: 'waers'    
      case when d.vprsv is null then cast(0 as salk3)
           else
             case when d.vprsv = 'S'
                  then
                     cast(cast( cast( cast(d.stprs as abap.dec(22,2)) * A.lfimg as abap.dec(22,2)) / d.peinh as abap.dec(22,2)) as abap.curr(22,2))
                  else  
                     cast(cast( cast( cast(d.verpr as abap.dec(22,2)) * A.lfimg as abap.dec(22,2)) / d.peinh as abap.dec(22,2)) as abap.curr(22,2))           
                  end
           end as stockvalue,
      F.waers
} 

union

select from zmmti26 as A inner join t001w as B on A.werks = B.werks
                         inner join t001k as E on B.bwkey = E.bwkey
                         inner join t001 as F on E.bukrs = F.bukrs
association [0..1] to makt as c on $projection.matnr =  c.matnr and c.spras = $session.system_language
association [0..1] to Mbv_Mbew as d on $projection.werks =  d.bwkey and $projection.matnr =  d.matnr
{
 key  A.vbeln,
 key  A.werks,
 key  A.posnr,
      A.matnr,
      c.maktx,
      A.lfimg,
      A.meins,
      A.charg,
      A.lichn,
      A.lgort,
      A.ebeln,
      A.ebelp,   
      case when d.vprsv is null then cast(0 as salk3)
           else
             case when d.vprsv = 'S'
                  then
                     cast(cast( cast( cast(d.stprs as abap.dec(22,2)) * A.lfimg as abap.dec(22,2)) / d.peinh as abap.dec(22,2)) as abap.curr(22,2))
                  else  
                     cast(cast( cast( cast(d.verpr as abap.dec(22,2)) * A.lfimg as abap.dec(22,2)) / d.peinh as abap.dec(22,2)) as abap.curr(22,2))           
                  end
           end as stockvalue,
      F.waers
} 


union

select from zmmti34 as b inner join ekpo as c on b.ebeln = c.ebeln and b.ebelp = c.ebelp 
                         inner join t001w as F on c.werks = F.werks
                         inner join t001k as G on F.bwkey = G.bwkey
                         inner join t001 as H on G.bukrs = H.bukrs
association [0..1] to makt as d on $projection.matnr =  d.matnr and d.spras = $session.system_language
association [0..1] to Mbv_Mbew as E on $projection.werks =  E.bwkey and $projection.matnr =  E.matnr
{
 key  b.vbeln,
 key  b.werks,
 key  b.posnr,
      b.matnr,
      d.maktx,
      b.lfimg,
      b.meins,
      cast('' as charg_d) as charg,
      b.tagnr as lichn,
      c.lgort,
      b.ebeln,
      b.ebelp,   
      case when E.vprsv is null then cast(0 as salk3)
           else
             case when E.vprsv = 'S'
                  then
                     cast(cast( cast( cast(E.stprs as abap.dec(22,2)) * b.lfimg as abap.dec(22,2)) / E.peinh as abap.dec(22,2)) as abap.curr(22,2))
                  else  
                     cast(cast( cast( cast(E.verpr as abap.dec(22,2)) * b.lfimg as abap.dec(22,2)) / E.peinh as abap.dec(22,2)) as abap.curr(22,2))           
                  end
           end as stockvalue,
      H.waers
}
/*

select from zgtmmt4011 as a          
association [0..1] to makt as B on $projection.matnr =  B.matnr and B.spras = $session.system_language

{
 key  a.vbeln,
 key  a.posnr,
      a.matnr,
      B.maktx,
      @Semantics.quantity.unitOfMeasure: 'MEINS'  
      a.lfimg,
      a.meins,
      a.charg,
      a.lichn,
      a.lgort,
      a.ebeln,
      a.ebelp,
      @Semantics.amount.currencyCode: 'waers'      
      a.stockvalue,
      a.waers
}
*/
