@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '외주 임가공 소요량 리스트'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_SCREQLIST 
as 
select from ekko as A 
       inner join ekpo as B on B.ebeln = A.ebeln
       inner join resb as C on C.ebeln = B.ebeln and C.ebelp = B.ebelp
       inner join marc as d on C.matnr = d.matnr and C.werks = d.werks 
       inner join mara as e on d.matnr = e.matnr
       inner join ZGTMM_CV_POGR_REMAIN2 as f on B.ebeln = f.ebeln and B.ebelp = f.ebelp 
association [0..1] to t001 as Company on $projection.bukrs = Company.bukrs  
association [0..1] to t001w as Plant on $projection.werks = Plant.werks
association [0..1] to lfa1 as VENDOR on $projection.lifnr = VENDOR.lifnr 
association [0..1] to makt as MAKT on $projection.CMATNR = MAKT.matnr and MAKT.spras = $session.system_language   
       
{
    key A.bukrs,   
    key A.ekorg,
    key B.ebeln,
    key B.ebelp,
    key C.rsnum,
    key C.rspos,
    Company.butxt,
    A.lifnr,
    VENDOR.name1 as BPNAME,
    e.mtart,
    B.matnr,
    B.txz01,
    B.elikz,
    d.xchar as batchyn,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    case when f.GRQTY > 0 then B.menge - f.GRQTY else B.menge end as menge,
    B.meins,
    B.werks,
    Plant.name1,
    C.matnr as CMATNR,
    d.lgpro,   //생산 저장위치
    d.lgfsb,   //외주 조달 저장위치
    case when d.lgpro <> '' then d.lgpro
         else
           case when d.lgfsb <> '' then d.lgfsb
                else B.lgort
                end
         end as ISSUESL,     
    makt.maktx,
   @Semantics.quantity.unitOfMeasure: 'CMEINS'
    case when f.GRQTY > 0 then  round((GET_NUMERIC_VALUe(B.menge) - GET_NUMERIC_VALUe(f.GRQTY)) * C.bdmng / GET_NUMERIC_VALUE(B.menge),3)
         else C.bdmng end as bdmng,  
    C.meins as CMEINS,
    Company.waers
    
} where B.pstyp = '3' and B.loekz = '' and C.xloek = '' and B.elikz = ''

