@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 임가공 BOM 없는 소요량_SUM'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SCREQLIST_EXCT 
as            

select from ZGTMM_CV_SCREQLIST_TOT2 as A 
       inner join mbew as b on A.werks = b.bwkey and A.cmatnr = b.matnr
       inner join marc as c on A.werks = c.werks and A.cmatnr = c.matnr
       inner join t024w as D on c.werks = D.werks
       inner join t001k as F on c.werks = F.bwkey
       inner join t001 as G on F.bukrs = G.bukrs
       inner join mara as H on c.matnr = H.matnr
       inner join ZGTMM_CV_SCSTOCKITEM_TOT as E
                 on A.werks = E.werks and A.lifnr = E.lifnr and A.cmatnr = E.matnr
       association [1..1] to makt as MAKT on $projection.cmatnr = MAKT.matnr and MAKT.spras = $session.system_language
{
   key A.bukrs,
   key D.ekorg,
   key A.werks,
   key A.lifnr,
   key case when c.lgfsb <> '' then c.lgfsb
            else c.lgpro
            end as  LGORT,
   key A.cmatnr,              //투입자재
       makt.maktx,               //투입자재명
       c.xchpf,               //배치관리여부   
       @Semantics.amount.currencyCode: 'waers'
       case when b.vprsv ='S' then b.stprs
            else b.verpr end as PRICE ,
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       b.peinh,
       G.waers,    
       H.meins,            
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       E.lblab as SCSTOCK,                  //외주재고수량
    
       @Semantics.amount.currencyCode: 'waers'  
       E.totalscvalue as SCVALUE,    //외주재고금액
       
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       cast(0 as abap.quan(13,3)) as BDMNG   
  } 
  group by A.bukrs,D.ekorg,A.werks,A.lifnr, A.cmatnr, makt.maktx, c.xchpf,
           b.vprsv,b.stprs,b.verpr,b.peinh,G.waers,H.meins,E.lblab,E.totalscvalue,c.lgfsb,c.lgpro
