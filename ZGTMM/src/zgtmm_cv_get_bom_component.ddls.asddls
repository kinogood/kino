@ClientHandling.type: #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Get BOM Components (Multi Level)'
define table function ZGTMM_CV_GET_BOM_COMPONENT
with parameters 
    @Environment.systemField: #CLIENT
    p_clnt  : abap.clnt,
    p_matnr : matnr,
    p_werks : werks_d,
    p_datum : datum
returns
{
  key Mandt                   : abap.clnt;
  key Material                : matnr;
      Plant                   : werks_d;
      ProductionVersion       : verid;
      ValidityStartDate       : adatm;
      ValidityEndDate         : bdatm;
      BOMHeaderQty            : basmn;
      BOMHeaderQtyUnit        : basme;
      BOMLevel                : abap.int4;
      Parent                  : matnr;
      Component               : matnr;
      BOMItemQty              : kmpmg;
      BOMItemQtyUnit          : kmpme;
      ComponentScrapInPercent : kausf;
      BOMValidityStartDate    : datuv;
      BOMValidityEndDate      : datuv;
      BaseUnit                : meins;
      CoProduct               : kzkup;

}
implemented by method
  zgtmm_cl_bom_component=>get_bom_component
