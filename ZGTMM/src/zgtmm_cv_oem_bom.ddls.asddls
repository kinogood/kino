@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OEM BOM 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #L,
    dataClass: #MIXED
}
// OEM 자재(MARA, 3번대) -> 특성 PD_CA_DESIGN_NO(=설계번호) -> 설계서(ZEDT1000, 상태 'Z'=확정 개정)
//   -> 설계 자재정보(ZEDT1090: 자재BOM·자재량) / 설계공정(ZEDT1010)
// 색상·띠줄·띠줄수·스펙은 OEM 자재(3번대) 마스터 값이 기준, 설계서(1번대)는 BOM·자재량만 사용
define view entity ZGTMM_CV_OEM_BOM
  as select from mara                              as M
    inner join   marc                              as C  on C.matnr = M.matnr
    inner join   t001w                             as W  on W.werks = C.werks
    inner join   t001k                             as K  on K.bwkey = W.bwkey
    inner join   ZGTSD_I_MaterialCharacteristic    as D  on  D.matnr = M.matnr
                                                         and D.atnam = 'PD_CA_DESIGN_NO'
    inner join   zedt1000                          as H  on  H.sul_no = D.atwrt
                                                         and H.status = 'Z'
    left outer join zedt1000                       as H2 on  H2.sul_no  = H.sul_no
                                                         and H2.status  = 'Z'
                                                         and H2.rev_seq > H.rev_seq
    inner join   zedt1090                          as I  on  I.sul_no  = H.sul_no
                                                         and I.rev_seq = H.rev_seq
    left outer join zedt1010                       as P  on  P.sul_no   = I.sul_no
                                                         and P.rev_seq  = I.rev_seq
                                                         and P.gong_seq = I.gong_seq
    left outer join ZGTSD_I_MaterialCharacteristic as S1 on  S1.matnr = M.matnr
                                                         and S1.atnam = 'PD_CA_COLOR_STRIPE'
    left outer join ZGTSD_I_MaterialCharacteristic as S2 on  S2.matnr = M.matnr
                                                         and S2.atnam = 'PD_CA_COLOR_STRIPE_NO'
    left outer join ZGTSD_I_MaterialCharacteristic as S5 on  S5.matnr = M.matnr
                                                         and S5.atnam = 'PD_CA_SPEC_NO'
    left outer join ZGTSD_I_MaterialCharacteristic as S6 on  S6.matnr = M.matnr
                                                         and S6.atnam = 'PD_CA_COLOR_BASE'
    left outer join ZGTMM_CV_GET_NFWEIGHT_MATERIAL as N4 on  N4.matnr = M.matnr
                                                         and N4.werks = C.werks
                                                         and N4.nes   = 'FI'
    left outer join makt                           as T1 on  T1.matnr = M.matnr
                                                         and T1.spras = $session.system_language
    left outer join makt                           as T2 on  T2.matnr = I.matnr
                                                         and T2.spras = $session.system_language
{
  K.bukrs                                          as bukrs,            // 회사코드
  C.werks                                          as werks,            // 플랜트
  M.mtart                                          as mtart,            // 자재유형
  H.new_matnr                                      as est_matnr,        // 견적자재 (1번째 상품코드)
  M.matnr                                          as matnr,            // OEM자재코드 (3번째 상품코드)
  T1.maktx                                         as maktx,            // 품명/규격
  S6.atwrt                                         as color,            // 색상 (분류특성 PD_CA_COLOR_BASE)
  S1.atwrt                                         as stripe_color,     // 띠줄
  S2.atwrt                                         as stripe_cnt,       // 띠줄수
  S5.atwrt                                         as spec_no,          // 스펙 (분류특성 PD_CA_SPEC_NO)
  @Semantics.quantity.unitOfMeasure: 'wgt_unit'
  cast( H.cu_wgt as abap.quan( 13, 3 ) )           as cu_wgt,           // Cu
  @Semantics.quantity.unitOfMeasure: 'wgt_unit'
  cast( H.al_wgt as abap.quan( 13, 3 ) )           as al_wgt,           // AL
  @Semantics.quantity.unitOfMeasure: 'opt_unit'
  case when N4.nes is not null then N4.kgw
       else cast( 0 as /nfm/kgw ) end              as opt_qty,          // Opt(광량) = NFM 중량 (NES 'FI')
  case when N4.nes is not null then N4.bme
       else cast( '' as meins ) end                as opt_unit,
  T2.maktx                                         as design_maktx,     // 설계자재명
  I.matnr                                          as design_matnr,     // 설계자재코드
  @Semantics.quantity.unitOfMeasure: 'mat_unit'
  cast( I.unit_qty as abap.quan( 13, 3 ) )         as mat_qty,          // 자재량
  cast( I.unit_unit as meins )                     as mat_unit,
  P.gong_cd                                        as gong_cd,          // 공정
  I.bigo                                           as bigo,             // 비고

  cast( 'KG' as abap.unit( 3 ) )                   as wgt_unit,
  H.sul_no                                         as sul_no,
  H.rev_seq                                        as rev_seq,
  H.sul_date                                       as sul_date,
  I.gong_seq                                       as gong_seq,
  I.jack_seq                                       as jack_seq,
  I.layer                                          as layer,
  I.seqno                                          as seqno
}
where M.lvorm <> 'X'
  and H2.sul_no is null
