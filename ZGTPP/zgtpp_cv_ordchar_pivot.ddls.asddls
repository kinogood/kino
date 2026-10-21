@AbapCatalog.sqlViewName: 'ZGTIORDCHARPVT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '생산 오더 특성 Pivot'
@ClientHandling.algorithm: #SESSION_VARIABLE
define view ZGTPP_CV_ORDCHAR_PIVOT as
select from zgtcvordchar
{
    key cuobj,
    max( case when atnam = 'SAP_MILLCA_LENGTH' then dec_value_from end ) as MillCaLength,
    max( case when atnam = 'SAP_MILLCA_FACTOR' then dec_value_from end ) as MillCaFactor,
    max( case when atnam = 'SAP_MILLCA_PACKAGING_CAT' then atwrt end ) as MillCaPackCat,
    max( case when atnam = 'SAP_MILLCA_PACKAGING_CAT' then atwtb end ) as MillCaPackCatNm,
    max( case when atnam = 'SAP_MILLCA_PACKAGING' then atwrt end ) as MillCaPacking,
    max( case when atnam = 'PD_CA_PACKING_DM' then atwrt end ) as PdCaPackingDm,
    max( case when atnam = 'PD_CA_PACKING_BX' then atwrt end ) as PdCaPackingBx,
    max( case when atnam = 'PD_CA_VOLTAGE' then atwrt end ) as PdCaVoltage,
    max( case when atnam = 'PD_CA_INX_NOM_THICK' then dec_value_from end ) as PdCaInxNumThick,
    max( case when atnam = 'PD_CA_CORE_TYPE_1ST' then atwtb end ) as PdCaCoreType1st,
    max( case when atnam = 'PD_CA_COND_SIZE_1ST' then atwrt end ) as PdCaCondSize1st,
    max( case when atnam = 'PD_PC_SHE_THICK' then dec_value_from end ) as PdPcSheThick,
    max( case when atnam = 'PD_PC_DRY_DAY_NO' then dec_value_from end ) as PdPcDryDayNo,
    max( case when atnam = 'PD_CA_PROC_OUT_DIA' then dec_value_from end ) as PdCaProcOutDia,
    max( case when atnam = 'PD_CA_PROC_OUT_DIA_LONG' then dec_value_from end ) as PdCaProcOutDiaLong
}
group by cuobj
