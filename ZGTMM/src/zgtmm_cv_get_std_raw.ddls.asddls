@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '제품 규격 정보 조회 Base Data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_STD_RAW 
as select from ekpo as A inner join mara as B on A.matnr = B.matnr 
association [1..1] to ZGTMM_CV_PO_VCVALUE as S1 on $projection.ebeln = S1.PDOC and $projection.ebelp = S1.PDOCITEM and S1.atnam = 'PD_CA_CORE_NO_1ST'
association [1..1] to ZGTMM_CV_PO_VCVALUE as S2 on $projection.ebeln = S2.PDOC and $projection.ebelp = S2.PDOCITEM and S2.atnam = 'PD_CA_COND_SIZE_1ST'
association [1..1] to ZGTMM_CV_PO_VCVALUE as S3 on $projection.ebeln = S3.PDOC and $projection.ebelp = S3.PDOCITEM and S3.atnam = 'PD_CA_CORE_NO_2ND'
association [1..1] to ZGTMM_CV_PO_VCVALUE as S4 on $projection.ebeln = S4.PDOC and $projection.ebelp = S4.PDOCITEM and S4.atnam = 'PD_CA_COND_SIZE_2ND'  
association [1..1] to ZGTMM_CV_PO_VCVALUE as S5 on $projection.ebeln = S5.PDOC and $projection.ebelp = S5.PDOCITEM and S5.atnam = 'PD_CA_VOLTAGE'
association [1..1] to ZGTMM_CV_PO_VCVALUE as S6 on $projection.ebeln = S6.PDOC and $projection.ebelp = S6.PDOCITEM and S6.atnam = 'PD_AA_STD_PRODUCT_NAME'
association [1..1] to ZGTMM_CV_PO_VCVALUE as S7 on $projection.ebeln = S7.PDOC and $projection.ebelp = S7.PDOCITEM and S7.atnam = 'PD_CA_SPEC_NO'
association [1..1] to ZGTMM_CV_PO_VCVALUE as S8 on $projection.ebeln = S8.PDOC and $projection.ebelp = S8.PDOCITEM and S8.atnam = 'PD_CA_COLOR_BASE'
association [1..1] to ZGTMM_CV_PO_VCVALUE as S9 on $projection.ebeln = S9.PDOC and $projection.ebelp = S9.PDOCITEM and S9.atnam = 'SAP_MILLCA_LENGTH'
association [1..1] to ZGTMM_CV_PO_VCVALUE as S10 on $projection.ebeln = S10.PDOC and $projection.ebelp = S10.PDOCITEM and S10.atnam = 'SAP_MILLCA_FACTOR'
{
   key A.ebeln,
   key A.ebelp,
       A.matnr,
       A.txz01,
       concat(concat(cast(cast(cast(S1.VALUE as abap.dec(4,0)) as abap.int4) as abap.char(20)),'X'),S2.VALUE) as c1,
       concat(concat(cast(cast(cast(S3.VALUE as abap.dec(4,0)) as abap.int4) as abap.char(20)),'X'),S4.VALUE) as c2,
       concat(concat(S5.VALUE, ('')),S6.VALUE) as c3,
       S7.VALUE as c4,
       S8.VALUE as color,
       @Semantics.quantity.unitOfMeasure: 'meins'        
       cast(cast(S9.VALUE as abap.dec(13,2)) as menge_d) as length,
       B.meins,
       cast(cast(S10.VALUE as abap.dec(10,0)) as abap.int8) as drqty
    
} where B.mtart = 'MCFE' or B.mtart = 'MCHA' 
