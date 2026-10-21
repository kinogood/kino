@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '저장위치별 재고 리스트'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_STOCKLIST 
as 
select from mara as A inner join marc as B on A.matnr = B.matnr
                      inner join nsdm_e_mchb as C on B.matnr = C.matnr and B.werks = C.werks
                      inner join mch1 as D on C.matnr = D.matnr and C.charg = D.charg 
                      
association [0..1] to zppt0001 as ZPPT0001 on $projection.werks = ZPPT0001.werks
                                          and $projection.matnr = ZPPT0001.matnr      
                                          and $projection.charg = ZPPT0001.charg     
                                          and ZPPT0001.remain > 0            
{
    key C.matnr,
    key C.werks,
    key C.lgort,
    key C.charg,
    zppt0001.tagnr,
    @Semantics.quantity.unitOfMeasure: 'MEINS'    
    C.clabs as UNQTY,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    C.cinsm as QIQTY,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    C.cspem as BLQTY,
    A.meins,
    B.xchpf,
    D.xpcbt
} where B.xchpf = 'X'  

union all

select from mara as A inner join marc as B on A.matnr = B.matnr
                      inner join nsdm_e_mard as C on B.matnr = C.matnr and B.werks = C.werks 
        
{
    key C.matnr,
    key C.werks,
    key C.lgort,
    key cast('' as abap.char(10)) as CHARG,
    cast('' as abap.char(17)) as tagnr,
    C.labst as UNQTY,
    C.insme as QIQTY,
    C.speme as BLQTY,
    A.meins,
    B.xchpf,
    cast('' as abap.char(1)) as XPCBT
} where B.xchpf = ''  

