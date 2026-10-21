@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[GT] 변경이력 조인용 Key 준비 뷰'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTSD_I_PREPARE_CDHDR_KEY
as select from vbak as hdr
   
   inner join      vbap as itm on hdr.vbeln = itm.vbeln
   left outer join ibin as ib  on itm.cuobj = ib.instance
{
    key hdr.vbeln,
    key itm.posnr,
    
    /* [핵심] CDHDR과 조인하기 위해 미리 타입을 CHAR 90으로 맞춤 */
    
    // 1. 헤더 키 (Header ObjectId)
    cast( hdr.vbeln as abap.char(90) )                    as HeaderObjID,
    
    // 2. IBIN 키 (IBIN ObjectId) - NUMC를 CHAR로 변환
    cast( ib.in_recno as abap.char(90) )                  as IbinObjID,
    
    // 3. 아이템 키 (Item ObjectId) - CONCAT 미리 수행
    cast( concat(itm.vbeln, itm.posnr) as abap.char(90) ) as DrumObjID 
}
