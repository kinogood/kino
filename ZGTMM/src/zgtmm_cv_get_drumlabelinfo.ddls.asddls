@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '드럼 라벨 특기사항 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_DRUMLABELINFO 
as select from zgtsdt1199 as A inner join ekkn as B on A.vbeln = B.vbeln and A.posnr = B.vbelp and B.zekkn = '01'
                               inner join ekpo as C on B.ebeln = C.ebeln and B.ebelp = C.ebelp and C.loekz = ''
                               inner join ekko as D on C.ebeln = D.ebeln and D.loekz = ''
                               left outer join zgtmmt4420 as e on A.vbeln = e.vbeln and A.posnr = e.posnr and A.zseq = e.zseq
association [0..1] to dd07t as DD1 on $projection.zzlabel_title1_n = DD1.domvalue_l and DD1.domname = 'ZGTD_LABEL_TITLE_N' and DD1.ddlanguage = $session.system_language
association [0..1] to dd07t as DD2 on $projection.zzlabel_title2_n = DD2.domvalue_l and DD2.domname = 'ZGTD_LABEL_TITLE_N' and DD2.ddlanguage = $session.system_language
association [0..1] to dd07t as DD3 on $projection.zzlabel_title3_n = DD3.domvalue_l and DD3.domname = 'ZGTD_LABEL_TITLE_N' and DD3.ddlanguage = $session.system_language
association [0..1] to dd07t as DD4 on $projection.zzlabel_title4_n = DD4.domvalue_l and DD4.domname = 'ZGTD_LABEL_TITLE_N' and DD4.ddlanguage = $session.system_language
{
 key D.bukrs,
 key A.vbeln,
 key A.posnr,
 key A.zseq,
     A.zzlabel_type,
     A.zzlabel_prtqt,
     A.zzlabel_title1_n,
     A.zzlabel_title2_n,
     A.zzlabel_title3_n,
     A.zzlabel_title4_n,
     DD1.ddtext as TITLE1,
     DD2.ddtext as TITLE2,
     DD3.ddtext as TITLE3,
     DD4.ddtext as TITLE4,
     A.zzlabel_title1 as DESC1,
     A.zzlabel_title2 as DESC2,
     A.zzlabel_title3 as DESC3,
     A.zzlabel_title4 as DESC4,
     A.zpull_eye,
     A.lvorm,
     A.ernam,
     A.erdat,
     A.erzet,
     A.aenam,
     case when A.aedat >= '20260101' and A.aedat >= C.aedat then A.aedat
          when A.aedat <  '20260101' and A.erdat >= C.aedat then A.erdat
          else C.aedat end as AEDAT,
     case when A.aedat >= '20260101' and A.aedat >= C.aedat and A.aezet <> '000000' then A.aezet
          when A.aedat >= '20260101' and A.aedat >= C.aedat then A.erzet
          when A.aedat <  '20260101' and A.erdat >= C.aedat then A.erzet
          else cast('000000' as abap.tims) end as AEZET,
     case when e.hsdat is not null then e.hsdat else cast('' as abap.dats) end as hsdat,
     case when e.licha is not null then e.licha else cast('' as abap.char(30)) end as licha,
     D.lifnr,     
     case when e.reserv1 is not null then e.reserv1 else cast('' as abap.char(30)) end as reserv1,
     case when e.reserv2 is not null then e.reserv2 else cast('' as abap.char(30)) end as reserv2,
     case when e.reserv3 is not null then e.reserv3 else cast('' as abap.char(30)) end as reserv3,
     case when e.reserv4 is not null then e.reserv4 else cast('' as abap.char(30)) end as reserv4,
     case when e.reserv5 is not null then e.reserv5 else cast('' as abap.char(30)) end as reserv5,
     case when e.reserv6 is not null then e.reserv6 else cast('' as abap.char(30)) end as reserv6,
     case when e.reserv7 is not null then e.reserv7 else cast('' as abap.char(30)) end as reserv7,
     case when e.reserv8 is not null then e.reserv8 else cast('' as abap.char(30)) end as reserv8,
     case when e.reserv9 is not null then e.reserv9 else cast('' as abap.char(30)) end as reserv9,
     case when e.reserv10 is not null then e.reserv10 else cast('' as abap.char(30)) end as reserv10,
     case when e.reprintyn is not null then e.reprintyn else cast('' as abap.char(1)) end as REPRINTYN
}
