@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '목드럼 특성 및 상태값'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGTMM_CV_DRUM_STATUS
  as select from mara as A
    left outer join makt as B on  A.matnr = B.matnr
                              and B.spras = '3'
    inner join   kssk as C on A.matnr = C.objek
    inner join   klah as D on C.clint = D.clint
    inner join   ksml as E on D.clint = E.clint
    inner join   cabn as F on E.imerk = F.atinn
    inner join   ausp as G on  C.objek = G.objek
                           and F.atinn = G.atinn
                           and D.klart = G.klart
{
  key A.matnr,
      case when A.zzmaktx80 <> ''
           then A.zzmaktx80
           else cast( B.maktx as abap.char( 80 ) )
      end                                         as maktx,
      A.meins,

      /* RL_GA_DRUM_GUBUN 가온 드럼 기호*/
      max( case when F.atnam = 'RL_GA_DRUM_GUBUN' then F.atnam end )   as DRM_GUBUN_ATNAM,
      max( case when F.atnam = 'RL_GA_DRUM_GUBUN' then G.atwrt end )   as DRM_GUBUN,

      /* 신드럼, 고드럼 구분 */
      cast(
        max(
          case
            when F.atnam = 'RL_CA_STD_MAT_NAME' and G.atwrt = '목드럼'     then 'S'
            when F.atnam = 'RL_CA_STD_MAT_NAME' and G.atwrt = '프라스틱드럼'     then 'S'
            when F.atnam = 'RL_CA_STD_MAT_NAME' and G.atwrt = '합판드럼' then 'S'            
            when F.atnam = 'RL_CA_STD_MAT_NAME' and G.atwrt = '목드럼(고)' then 'G'
          end
        )
        as abap.char(1)
      )                                                                as DRM_SG_TYPE,

      /* RL_CA_NO 드럼 규격*/
      max( case when F.atnam = 'RL_CA_NO' then F.atnam end )           as CA_NO_ATNAM,
      max( case when F.atnam = 'RL_CA_NO' then G.atwrt end )           as CA_NO,

      /* 규격에서 호수만 분리 */
      cast(
        max(
          case
            when F.atnam = 'RL_CA_NO' and instr( G.atwrt, '-' ) > 0
              then substring( G.atwrt, 1, instr( G.atwrt, '-' ) - 1 )

            when F.atnam = 'RL_CA_NO'
              then G.atwrt
          end
        )
        as abap.dec(3,0)
      )                                                                as DRM_SIZE,

      /* 목드럼, 플랜지, 합판 등 구분 */
      max( case when F.atnam = 'RL_CA_STD_MAT_NAME' then G.atwrt end ) as MAT_NAME,


      A.lvorm
}
where
       C.klart = '001'
  and(
       F.atnam = 'RL_CA_NO'
    or F.atnam = 'RL_GA_DRUM_GUBUN'
    or F.atnam = 'RL_CA_STD_MAT_NAME'
  )

group by
  A.matnr,
  A.zzmaktx80,
  B.maktx,
  A.meins,
  A.lvorm

having
  max( case when F.atnam = 'RL_GA_DRUM_GUBUN' then G.atwrt end ) is not null
