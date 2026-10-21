@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 판매오더 생성/변경 날짜 및 시간'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_SALESDOC_UPD_DATE
  as select from vbak

{

  key vbeln,
      erdat,
      erzet,

      // 판매오더 수정 날짜
      TSTMP_TO_DATS( cast( upd_tmstmp as abap.dec(15,0) ),
                     abap_system_timezone( $session.client, 'NULL' ),
                     $session.client,
                     'NULL' )   as upd_dat,

      // 판매오더 수정 시간
      TSTMP_TO_TIMS( cast( upd_tmstmp as abap.dec(15,0) ),
                     abap_system_timezone( $session.client, 'NULL' ),
                     $session.client,
                     'NULL' )   as upd_tim 

}
