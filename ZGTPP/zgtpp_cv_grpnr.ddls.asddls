@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: '생산 오더 조장표 구성'
define view entity ZGTPP_CV_GRPNR as select from zgtppt2000 as a
inner join zgtppt2010 as b
    on  a.grpnr = b.grpnr
{
    key cast(b.ordnr as aufnr) as aufnr,
    key cast(cast(right(b.posnr,4) as abap.char(4)) as co_posnr) as posnr,
    b.grpnr,
    b.inlength,
    b.infactor,
    b.qlength,
    b.clength,
    b.adlength,
    b.adtype,
    b.dmord,
    b.dmline,
    b.gong_seq
}
where ( b.ordty = 'PRD' or b.ordty = 'PO' or b.ordty = 'PR' )
group by b.ordnr, b.posnr, b.grpnr, b.inlength, b.infactor, b.qlength, b.clength, b.adlength, b.adtype, b.dmord, b.dmline, b.gong_seq
