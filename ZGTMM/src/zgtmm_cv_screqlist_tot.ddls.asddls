@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 임가공 모품/투입자재 별 소요량 리스트'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SCREQLIST_TOT 
as
select from ZGTMM_CV_SCREQLIST
{
    key bukrs,          
    key ekorg,
    key lifnr,
    key werks,
    key CMATNR,
        butxt,    
        BPNAME,    
        name1,    
        maktx,
        batchyn,
        @Semantics.quantity.unitOfMeasure: 'CMEINS'
        sum(bdmng) as bdmng,
        CMEINS,
        waers,
        mtart,
        lgpro,
        lgfsb,
        ISSUESL,
        meins
        
} where elikz = ''
group by bukrs,ekorg,butxt,lifnr,BPNAME,werks,name1,CMATNR,maktx,CMEINS,batchyn,waers,mtart,lgpro,lgfsb,ISSUESL,meins
