@AbapCatalog.sqlViewName: 'ZGTCVSULCHAR'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '완제품 설계서 특성'
@Metadata.ignorePropagatedAnnotations: true
define view ZGTPP_CV_SULCHAR
  as select from  zgtcvsulno as A
  left outer join zedt1030   as B on  A.sul_no  = B.sul_no
                                  and A.rev_seq = B.rev_seq
{
  key A.matnr,
  key A.werks,
  key A.spart,
  key A.sul_no,
  key A.rev_seq,
  key B.gong_seq,
  key B.jack_seq,
      //  key B.attribute,
/* KV 전압 */
      max( case when B.attribute = 'CTY_VOLTAGE'
                 and B.data_char is not null
                then B.data_char end ) as KV,

/* SQ 스퀘어 */
      max( case when B.attribute = 'CORE1_CONDUCTOR_SIZE'
                 and B.data_char is not null
                then B.data_char end ) as SQ,
             
/* CORE1 자재, 형상 */             
      max( case when B.attribute = 'CORE1_JAJE'
                 and B.data_char is not null
                then B.data_char end ) as CORE1_JAJE,
      max( case when B.attribute = 'CORE1_SHAPE'
                 and B.data_char is not null
                then B.data_char end ) as CORE1_SHAPE,                
                
/* CORE3 자재, 형상 */
      max( case when B.attribute = 'CORE3_JAJE'
                 and B.data_char is not null
                then B.data_char end ) as CORE3_JAJE,
                
      max( case when B.attribute = 'CORE3_SHAPE'
                 and B.data_char is not null
                then B.data_char end ) as CORE3_SHAPE,
                
/* CORE1, CORE3 선심 코드 */
      sum( case when B.attribute = 'CORE1_SOSUN_CD'
                 and B.data_num is not null
                then B.data_num end ) as SOSUN1,
      sum( case when B.attribute = 'CORE3_SOSUN_CD'
                 and B.data_num is not null
                then B.data_num end ) as SOSUN3,
                
/* 0~7층 소선 본수, 소션경 길이 */
      sum( case when B.attribute = 'BONSU0'
                 and B.data_num is not null
                then B.data_num end ) as BONSU0,
      sum( case when B.attribute = 'SUNDIA0'
                 and B.data_num is not null
                then B.data_num end ) as SUNDIA0,
                
      sum( case when B.attribute = 'BONSU1'
                 and B.data_num is not null
                then B.data_num end ) as BONSU1,
      sum( case when B.attribute = 'SUNDIA1'
                 and B.data_num is not null
                then B.data_num end ) as SUNDIA1,
                
      sum( case when B.attribute = 'BONSU2'
                 and B.data_num is not null
                then B.data_num end ) as BONSU2,
      sum( case when B.attribute = 'SUNDIA2'
                 and B.data_num is not null
                then B.data_num end ) as SUNDIA2,
                
      sum( case when B.attribute = 'BONSU3'
                 and B.data_num is not null
                then B.data_num end ) as BONSU3,
      sum( case when B.attribute = 'SUNDIA3'
                 and B.data_num is not null
                then B.data_num end ) as SUNDIA3,
                
                
      sum( case when B.attribute = 'BONSU4'
                 and B.data_num is not null
                then B.data_num end ) as BONSU4,
      sum( case when B.attribute = 'SUNDIA4'
                 and B.data_num is not null
                then B.data_num end ) as SUNDIA4,
                
      sum( case when B.attribute = 'BONSU5'
                 and B.data_num is not null
                then B.data_num end ) as BONSU5,
      sum( case when B.attribute = 'SUNDIA5'
                 and B.data_num is not null
                then B.data_num end ) as SUNDIA5,
                
      sum( case when B.attribute = 'BONSU6'
                 and B.data_num is not null
                then B.data_num end ) as BONSU6,
      sum( case when B.attribute = 'SUNDIA6'
                 and B.data_num is not null
                then B.data_num end ) as SUNDIA6,
                
      sum( case when B.attribute = 'BONSU7'
                 and B.data_num is not null
                then B.data_num end ) as BONSU7,
      sum( case when B.attribute = 'SUNDIA7'
                 and B.data_num is not null
                then B.data_num end ) as SUNDIA7
                
}
where
     B.attribute = 'CTY_VOLTAGE'
  or B.attribute = 'CORE1_CONDUCTOR_SIZE'
  or B.attribute = 'CORE1_JAJE'
  or B.attribute = 'CORE1_SHAPE'
  or B.attribute = 'CORE3_JAJE'
  or B.attribute = 'CORE3_SHAPE'
  or B.attribute = 'CORE1_SOSUN_CD'
  or B.attribute = 'CORE3_SOSUN_CD'
  or B.attribute = 'BONSU0'
  or B.attribute = 'SUNDIA0'
  or B.attribute = 'BONSU1'
  or B.attribute = 'SUNDIA1'
  or B.attribute = 'BONSU2'
  or B.attribute = 'SUNDIA2'
  or B.attribute = 'BONSU3'
  or B.attribute = 'SUNDIA3'
  or B.attribute = 'BONSU4'
  or B.attribute = 'SUNDIA4'
  or B.attribute = 'BONSU5'
  or B.attribute = 'SUNDIA5'
  or B.attribute = 'BONSU6'
  or B.attribute = 'SUNDIA6'
  or B.attribute = 'BONSU7'
  or B.attribute = 'SUNDIA7'
group by
  A.matnr,
  A.werks,
  A.spart,
  A.sul_no,
  A.rev_seq,
  B.gong_seq,
  B.jack_seq
