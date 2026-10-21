@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 임가공 BOM 없는 소요량'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SCREQLIST_EXC 
as

select from ZGTMM_CV_SCREQLIST_TOT as A 
       inner join mbew as B on A.werks = B.bwkey and A.CMATNR = B.matnr
       left outer join ZGTMM_CV_STOCKLIST_SUM  as C on A.werks = C.werks and A.ISSUESL = C.lgort and A.CMATNR = C.matnr
       left outer join ZGTMM_CV_SCSTOCKITEM_SUM as D on A.bukrs = D.bukrs and A.werks = D.werks and A.lifnr = D.lifnr and A.CMATNR = D.matnr
{
    key A.bukrs,   
        A.ekorg,
        A.butxt,
        A.lifnr,
        A.BPNAME,
        A.werks,
        A.name1,
        A.CMATNR,
        A.maktx,
        A.batchyn,
        @Semantics.quantity.unitOfMeasure: 'CMEINS'
        A.bdmng,     //소요량
        A.CMEINS,
        A.waers,
        A.mtart,
        A.ISSUESL as LGORT,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        C.UNQTY,
        C.meins,
        @Semantics.quantity.unitOfMeasure: 'MEINS'
        sum(D.lblab) as LBLAB,
        @Semantics.amount.currencyCode: 'waers'  
        sum(D.totalscvalue) as TOTALSCVALUE    ,
        
       B.vprsv,
               @Semantics.amount.currencyCode: 'waers' 
       B.stprs,
               @Semantics.amount.currencyCode: 'waers' 
       B.verpr,
       @Semantics.amount.currencyCode: 'waers'
       case when B.vprsv ='S' then B.stprs
            else B.verpr end as PRICE ,
       @Semantics.quantity.unitOfMeasure: 'MEINS'
       B.peinh
} //where B.CHECKYN = 'X'
group by A.bukrs,   
         A.ekorg,
        A.butxt,
        A.lifnr,
        A.BPNAME,
        A.werks,
        A.name1,
        A.CMATNR,
        A.maktx,
        A.batchyn,A.bdmng,     //소요량
        A.CMEINS,
        A.waers,
        A.mtart,A.ISSUESL,C.UNQTY,
        C.meins,
        B.vprsv,
        B.stprs,
        B.verpr,
        B.peinh
