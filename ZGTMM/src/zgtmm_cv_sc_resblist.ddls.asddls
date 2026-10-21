@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 가공 투입자재 소요량 정보'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SC_RESBLIST 
as select from ekpo as A inner join resb as B on A.ebeln = B.ebeln and A.ebelp = B.ebelp
                         inner join marc as C on B.matnr = C.matnr and B.werks = C.werks
{
    key A.ebeln,
    key A.ebelp,
        A.matnr,
        @Semantics.quantity.unitOfMeasure: 'MEINS' 
        A.menge,
        A.meins,
        B.matnr as IDNRK,
        @Semantics.quantity.unitOfMeasure: 'CMEINS' 
        sum(B.bdmng) as BDMNG,
        B.meins as CMEINS,
        C.xchpf
} where A.pstyp = '3' and A.loekz = '' and B.xloek = ''
group by A.ebeln, A.ebelp, A.matnr, A.menge, A.meins, B.matnr, B.meins, C.xchpf
