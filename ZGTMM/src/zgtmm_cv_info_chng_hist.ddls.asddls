@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '정보레코드 변경 히스토리'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_INFO_CHNG_HIST as 
    select from cdhdr as h inner join konp as k
                                   on h.objectid = k.knumh
                           inner join a017 as a  //플랜트,자재코드
                                   on k.knumh = a.knumh
                                  and k.kappl = a.kappl
                                  and k.kschl = a.kschl
                           inner join eina as i
                                   on a.lifnr = i.lifnr
                                  and a.matnr = i.matnr
                           inner join eine as e
                                   on i.infnr = e.infnr
                                  and a.ekorg = e.ekorg
                                  and a.esokz = e.esokz
                                  and a.werks = e.werks
                           inner join lfa1 as l
                                   on a.lifnr = l.lifnr
                           inner join mara as r
                                   on a.matnr = r.matnr
                           inner join makt as m
                                   on a.matnr = m.matnr
                                  and m.spras = $session.system_language
{
    key h.objectclas,
    key h.objectid,
    
        h.username,  //변경자
        h.tcode,  //변경 t-code
        h.udate,  //변경일자
        h.utime,  //변경시간
        k.kappl,  //애플리케이션 M(구매)
        k.kschl,  //어플리케이션 PB00(구매단가)
        
        e.infnr,  //정보레코드번호
        e.ekorg,  //구매조직
        e.esokz,  //정보범주
        e.werks,  //플랜트
        i.lifnr,  //공급업체
        case when r.matkl = '' then '.' else r.matkl end as matkl,  //자재그룹
        //r.matkl,  //자재그룹
        case when i.matnr = '' then '.' else i.matnr end as matnr,  //자재
        //i.matnr,  //자재
        m.maktx,  //자재 내역
        i.txz01,  //정보레코드 내역
        i.idnlf,  //업체자재
        l.name1,  //공급업체 이름
        a.datab,  //시작일
        a.datbi,  //종료일
        
        @Semantics.amount.currencyCode: 'konwa'
        k.kbetr,  //단가,비율
        k.konwa,  //통화
        k.kpein as peinh,  //per
        k.kmein as bprme  //갸격단위
        
} where h.objectclas = 'COND_A'

union

    select from cdhdr as h inner join konp as k
                                   on h.objectid = k.knumh
                           inner join a025 as a  //자재그룹,플랜트
                                   on k.knumh = a.knumh
                                  and k.kappl = a.kappl
                                  and k.kschl = a.kschl
                           inner join eina as i
                                   on a.infnr = i.infnr
                           inner join lfa1 as l
                                   on a.lifnr = l.lifnr
{
    key h.objectclas,
    key h.objectid,
    
        h.username,  //변경자
        h.tcode,  //변경 t-code
        h.udate,  //변경일자
        h.utime,  //변경시간
        k.kappl,  //애플리케이션 M(구매)
        k.kschl,  //어플리케이션 PB00(구매단가)
        
        a.infnr,  //정보레코드번호
        a.ekorg,  //구매조직
        a.esokz,  //정보범주
        a.werks,  //플랜트
        a.lifnr,  //공급업체
        a.matkl,  //자재그룹
        cast('.' as matnr ) as matnr,  //자재
        cast('.' as maktx ) as maktx,  //자재 내역
        i.txz01,  //정보레코드 내역
        i.idnlf,  //업체자재
        l.name1,  //공급업체 이름
        a.datab,  //시작일
        a.datbi,  //종료일
        
//        @Semantics.amount.currencyCode: 'konwa'
        k.kbetr,  //단가,비율
        k.konwa,  //통화
        k.kpein as peinh,  //per
        k.kmein as bprme  //갸격단위
        
} where h.objectclas = 'COND_A'

union
//정보레코드 공급업체 자재그룹 변경
    select from cdhdr as h inner join cdpos as c
                                   on h.objectclas = c.objectclas
                                  and h.objectid = c.objectid
                                  and h.changenr = c.changenr
                           inner join a025 as a
                                   on h.objectid = a.infnr
                           inner join konp as k
                                   on a.knumh = k.knumh
                           inner join eina as i
                                   on a.infnr = i.infnr
                           inner join lfa1 as l
                                   on a.lifnr = l.lifnr
{
    key h.objectclas,
    key h.objectid,
    
        h.username,  //변경자
        h.tcode,  //변경 t-code
        h.udate,  //변경일자
        h.utime,  //변경시간
        cast('M' as kappl) as kappl,  //애플리케이션 M(구매)
        cast('PB00' as kschl) as kschl, //어플리케이션 PB00(구매단가)
        
        a.infnr,  //정보레코드번호
        a.ekorg,  //구매조직
        a.esokz,  //정보범주
        a.werks,  //플랜트
        a.lifnr,  //공급업체
        a.matkl,  //자재그룹
        cast('.' as matnr ) as matnr,  //자재
        cast('.' as maktx ) as maktx,  //자재 내역
        i.txz01,  //정보레코드 내역
        i.idnlf,  //업체자재
        l.name1,  //공급업체 이름
        a.datab,  //시작일
        a.datbi,  //종료일
        
//        @Semantics.amount.currencyCode: 'konwa'
        k.kbetr,  //단가,비율
        k.konwa,  //통화
        k.kpein as peinh,  //per
        k.kmein as bprme  //갸격단위
        
} where h.objectclas = 'INFOSATZ'
    and c.tabname = 'EINA'
    and c.fname = 'IDNLF'
