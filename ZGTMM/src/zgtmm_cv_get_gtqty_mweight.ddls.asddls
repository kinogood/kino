@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매 입고 내역 조회(비철 중량 포함)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_GTQTY_MWEIGHT 
as select from ZGTMM_CV_GET_GRLIST_BASE as a inner join mara as B on a.matnr = B.matnr
association [0..1] to ZGTMM_CV_GET_NFWEIGHT_PLANT as PNF on $projection.matnr = PNF.matnr and $projection.werks = PNF.werks  and (PNF.nes = 'CU' )
{
  key a.mjahr,
  key a.mblnr,
  key a.zeile,
      a.budat,
      LEFT(a.budat,6) as PERIOD,
      a.bukrs,
      a.ekorg,
      a.werks,
      a.matnr,
      a.lifnr,
      @Semantics.quantity.unitOfMeasure: 'BPRME'
      case when a.shkzg = 'H' then a.bpmng * -1 else a.bpmng end as BPMNG,
      a.bprme,
      a.ebeln,
      a.ebelp,
      a.mwskz,
      B.mtart,
      case when PNF.nes is not null then PNF.nes else cast('' as /nfm/nes ) end as NES,
      @Semantics.quantity.unitOfMeasure: 'BME'             
      case when PNF.vgw is not null then PNF.vgw else cast(0 as /nfm/vgw) end as VGW,
      case when PNF.bme is not null then PNF.bme else cast('' as unit) end as BME,
      case when PNF.vge is not null then PNF.vge else cast(1 as /nfm/vge) end as VGE,
      case when PNF.meins is not null then PNF.meins else cast('' as unit) end as MEINS_B,
      @Semantics.quantity.unitOfMeasure: 'BME'  
      case when PNF.vgw is not null and a.mwskz = 'VA' then 
          cast(a.bpmng * PNF.vgw / PNF.vge as abap.quan(13,3))
      else
          cast(0 as abap.quan(13,3))
      end as METAL_TAX10,
      @Semantics.quantity.unitOfMeasure: 'BME'  
      case when PNF.vgw is not null and ( a.mwskz = 'V1' or  a.mwskz = 'V0') then 
          cast(a.bpmng * PNF.vgw / PNF.vge as abap.quan(13,3))
      else
          cast(0 as abap.quan(13,3))
      end as METAL_TAX0      
            
} where a.cancelled = '' and a.reversal_movement = '' 
