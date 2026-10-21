@AbapCatalog.sqlViewName: 'ZGTIORDSYVAL'
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '생산오더 특성값'
@ClientHandling.algorithm: #SESSION_VARIABLE
define view ZGTPP_CV_ORDSYVALBASIC as 
select from aufk
inner join afko
    on aufk.mandt = afko.mandt
    and aufk.aufnr = afko.aufnr 
inner join afpo
    on afko.mandt = afpo.mandt
    and afko.aufnr = afpo.aufnr
inner join zgtimstval as mstval
    on afpo.mandt = mstval.mandt
    and afpo.matnr = mstval.matnr
    and aufk.werks = mstval.werks
inner join imfgorderwstts as ordst
    on afpo.mandt = ordst.mandt
    and afpo.aufnr = ordst.manufacturingorder
left outer join vbak
    on afpo.mandt = vbak.mandt
    and afpo.kdauf = vbak.vbeln
left outer join kna1
    on vbak.mandt = kna1.mandt
    and vbak.kunnr = kna1.kunnr
left outer join zsd0106t as pjt
    on vbak.mandt = pjt.mandt
    and vbak.zpjno = pjt.zpjno
left outer join ZGTPP_CV_GRPNR as grp
    on afpo.aufnr = grp.aufnr
    and afpo.posnr = grp.posnr
left outer join ZGTPP_CV_AFVC_LAST as afvc
    on afko.mandt = afvc.mandt
    and afko.aufpl = afvc.aufpl
left outer join crhd
    on afvc.mandt = crhd.mandt
    and afvc.arbid = crhd.objid
    and crhd.objty = 'A'
left outer join crtx
    on crhd.mandt = crtx.mandt
    and crhd.objty = crtx.objty
    and crhd.objid = crtx.objid
    and crtx.spras = $session.system_language
left outer join ZGTPP_CV_ORDCHAR_PIVOT as char_piv
    on afpo.cuobj = char_piv.cuobj
    
{
    key aufk.werks,
    key aufk.auart,
    key afpo.aufnr,
    key afpo.posnr,   
    afko.terkz, 
    afko.gstrp,
    afko.gsuzp,
    afko.gltrp,
    afko.gluzp,
    afko.gamng,
    afko.gasmg,
    afko.gmein,
    afpo.matnr,
    mstval.maktx,
    mstval.dispo,
    @Semantics.quantity.unitOfMeasure: 'meins'
    afpo.psmng,
    @Semantics.quantity.unitOfMeasure: 'meins'
    afpo.psamg,
    @Semantics.quantity.unitOfMeasure: 'meins'
    afpo.wemng,
    afpo.meins,
    cast(coalesce(grp.grpnr,' ') as zgtegrpnr) as grpnr,
    afpo.elikz,
    aufk.zzpriority,
    aufk.zzorigin,
    aufk.zzfollowing,
    aufk.zzbundle,
    aufk.zzposnr,
    aufk.zzkdauf,
    aufk.zzkdpos,
    aufk.zztandem,
    afpo.kdauf,
    afpo.kdpos,
    
    vbak.kunnr,
    kna1.name1,
    vbak.zpjno,
    pjt.zptxt,    
    
    aufk.objnr,
    afpo.cuobj,    
    
    grp.inlength,
    grp.infactor,
    grp.qlength,
    grp.clength,
    grp.adlength,
    grp.adtype,
    grp.dmord,
    grp.dmline,
    grp.gong_seq,
    mstval.pdcaproccode,                        //공정코드
    mstval.pdcaprocname,                        //공정명
    
    // Pivot View 필드 바인딩
    char_piv.MillCaLength,
    char_piv.MillCaFactor,
    char_piv.MillCaPackCat,                     //포장재 유형값
    char_piv.MillCaPackCatNm,                   //포장재 유형명
    char_piv.MillCaPacking,                     //포장재
    char_piv.PdCaPackingDm,                     //포장재(드럼)
    char_piv.PdCaPackingBx,                     //포장재(BOX)
    char_piv.PdCaVoltage,                       //전압
    char_piv.PdCaInxNumThick,                   //절연공칭두께
    char_piv.PdCaCoreType1st,                   //선심Type(1)
    char_piv.PdCaCondSize1st,                   //도체Size(1)
    char_piv.PdPcSheThick,                      //완제품 시스 두께
    char_piv.PdPcDryDayNo,                      //건조일수
    char_piv.PdCaProcOutDia,                    //공정외경
    char_piv.PdCaProcOutDiaLong,                //공정외경(장경
    
//    _char[atnam = 'SAP_MILLCA_LENGTH'].dec_value_from as MillCaLength,
//    _char[atnam = 'SAP_MILLCA_FACTOR'].dec_value_from as MillCaFactor,
//    
//    _char[atnam = 'SAP_MILLCA_PACKAGING_CAT'].atwrt as MillCaPackCat,               //포장재 유형값
//    _char[atnam = 'SAP_MILLCA_PACKAGING_CAT'].atwtb as MillCaPackCatNm,             //포장재 유형명
//    _char[atnam = 'SAP_MILLCA_PACKAGING'].atwrt as MillCaPacking,                   //포장재
//    _char[atnam = 'PD_CA_PACKING_DM'].atwrt as PdCaPackingDm,                       //포장재(드럼)
//    _char[atnam = 'PD_CA_PACKING_BX'].atwrt as PdCaPackingBx,                       //포장재(BOX)
//    _char[atnam = 'PD_CA_VOLTAGE'].atwrt as PdCaVoltage,                            //전압
//    _char[atnam = 'PD_CA_INX_NOM_THICK'].dec_value_from as PdCaInxNumThick,         //절연공칭두께
//    _char[atnam = 'PD_CA_CORE_TYPE_1ST'].atwtb as PdCaCoreType1st,                  //선심Type(1)
//    _char[atnam = 'PD_CA_COND_SIZE_1ST'].atwrt as PdCaCondSize1st,                  //도체Size(1)
//    _char[atnam = 'PD_PC_SHE_THICK'].dec_value_from as PdPcSheThick,                //완제품 시스 두께
//    _char[atnam = 'PD_PC_DRY_DAY_NO'].dec_value_from as PdPcDryDayNo,               //건조일수
//    _char[atnam = 'PD_CA_PROC_OUT_DIA'].dec_value_from as PdCaProcOutDia,           //공정외경
//    _char[atnam = 'PD_CA_PROC_OUT_DIA_LONG'].dec_value_from as PdCaProcOutDiaLong,  //공정외경(장경)
    
    crhd.arbpl,
    crtx.ktext,
    aufk.erdat,
    aufk.aedat,
    ordst.orderisreleased as rel,
    ordst.orderismarkedfordeletion as dlfl,
    ordst.orderislocked as lkd,
    ordst.orderistechnicallycompleted as teco,
    ordst.orderisclosed as clsd,
    ordst.orderispartiallyconfirmed as pcnf,
    ordst.orderisconfirmed as cnf,
    ordst.orderispartiallydelivered as pdlv,
    ordst.orderisdelivered as dlv
}
