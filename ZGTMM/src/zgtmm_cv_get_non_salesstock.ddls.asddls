@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MTS 재고 현황 조회(공장 내)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_NON_SALESSTOCK 
as select from nsdm_e_mchb as A inner join marc as B on A.matnr = B.matnr and A.werks = B.werks
                         inner join mara as C on B.matnr = C.matnr
{
   key A.matnr,
   key A.werks,
   key A.charg,
       @Semantics.quantity.unitOfMeasure: 'MEINS'     
       A.clabs,
       C.meins,
       case when B.dpcbt = 'C' then  cast(A.clabs as abap.dec(6,0))
            when B.dpcbt = 'A'
             and replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                 A.charg,'0','#'),'1','#'),'2','#'),'3','#'),'4','#'),'5','#'),'6','#'),'7','#'),'8','#'),'9','#') = '##########'
             and A.charg <> '0000000000'
             and A.charg <= '0000999999'
                 then cast(A.charg as abap.dec(6,0))
            else cast('0' as abap.dec(6,0)) end as LENGTH,
       case when B.dpcbt = 'C' then cast(1 as abap.int4)
            when B.dpcbt = 'A'
             and replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                 A.charg,'0','#'),'1','#'),'2','#'),'3','#'),'4','#'),'5','#'),'6','#'),'7','#'),'8','#'),'9','#') = '##########'
             and A.charg <> '0000000000'
             and A.charg <= '0000999999'
                 then cast(A.clabs / cast(A.charg as abap.dec(6,0)) as abap.int4) 
            else cast('0' as abap.int4) end as DRQTY
} where A.clabs > 0 and ( A.lgort = '3410' or A.lgort = '3420' or A.lgort = '3497' )
