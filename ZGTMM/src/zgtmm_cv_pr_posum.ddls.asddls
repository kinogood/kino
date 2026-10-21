@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PR 별 후속 진행 총량'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_PR_POSUM 
as 
select from ZGTMM_CV_PR_POLIST as A 
       inner join eban as B on A.banfn = B.banfn and A.bnfpo = B.bnfpo
       left outer join ZGTMM_CV_UNIT_FACTOR as c on A.meins = c.UNIT and B.meins = c.SIUNIT
       association [1..1] to t001w as T001W on $projection.werks = T001W.werks  
       association [0..1] to t001l as T001L on $projection.werks = T001L.werks and $projection.lgort = T001L.lgort
       association [0..1] to marm as marm on $projection.matnr = marm.matnr and $projection.POUNIT = marm.meinh       
{
    A.banfn,
    A.bnfpo,   
    A.werks, 
    t001w.name1 as WERKS_N,
    B.lgort,
    t001l.lgobe,
    B.matnr,
    B.txz01,
    B.afnam,
    @Semantics.quantity.unitOfMeasure: 'PRUNIT'      
    B.menge as PRQTY,
    B.meins as PRUNIT,
    @Semantics.quantity.unitOfMeasure: 'POUNIT'  
    case when B.meins <> A.meins  
         then
              case when c.SIUNIT is not null 
                   then cast(A.POQTY * c.zaehl / c.nennr as abap.quan(13,3))
                   else cast(marm.umrez * A.POQTY / marm.umren as abap.quan(13,3)) 
                   end
         else
           A.POQTY
         end as poqty,

    @Semantics.quantity.unitOfMeasure: 'POUNIT'
    case when B.meins <> A.meins  
         then
              case when c.SIUNIT is not null 
                   then cast(A.INBQTY * c.zaehl / c.nennr as abap.quan(13,3))
                   else cast(marm.umrez * A.INBQTY / marm.umren as abap.quan(13,3)) 
                   end
         else
           A.INBQTY
         end as INBQTY,
    @Semantics.quantity.unitOfMeasure: 'POUNIT'
    case when B.meins <> A.meins  
         then
              case when c.SIUNIT is not null 
                   then cast(A.GRQTY * c.zaehl / c.nennr as abap.quan(13,3))
                   else cast(marm.umrez * A.GRQTY / marm.umren as abap.quan(13,3)) 
                   end
         else
           A.GRQTY
         end as GRQTY,  
    @Semantics.quantity.unitOfMeasure: 'POUNIT'  
    case when B.meins <> A.meins  
         then
              case when c.SIUNIT is not null 
                   then cast(A.REQTY * c.zaehl / c.nennr as abap.quan(13,3))
                   else cast(marm.umrez * A.REQTY / marm.umren as abap.quan(13,3)) 
                   end
         else
           A.REQTY
         end as REQTY,
    @Semantics.quantity.unitOfMeasure: 'POUNIT'
    A.POQTY as oriqty,           
    A.meins as POUNIT         
}
