@AbapCatalog.sqlViewName: 'ZGTCVMSTVAL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재 특성 값'
@ClientHandling.algorithm: #SESSION_VARIABLE
define view ZGTPP_CV_MASTVAL as 
select from zgtimstval
{
    key werks,
    key matnr,
    spart,
    spg,
    mtart,
    mtref,
    lvormc,
    lvormp, 
    matkl,
    mmsta,
    dispo,
    beskz,
    sobsl,
    dpcbt,
    maabc,
    maktx,
    ersda,
    laeda,
    cuobj,
    
    max(pdcaproccode) as PdCaProcCode,              //공정코드
    max(pdcaprocname) as PdCaProcName,              //공정코드명
    max(pdcadesignno) as PdCaDesignNo,              //설계번호
    max(pdcadesignrevno) as PdCaDesignRevNo,        //설계번호 Rev.
    max(pdcavoltage) as PdCaVoltage,                //전압
    max(pdcaprocoutdia) as PdCaProcOutDia,          //공정외경
    max(pdstdproductname) as PdStdProductName,      //표준품명(제품)
    max(pdcasegmentno) as PdCaSegmentNo,            //SEGMENT수
    
    max(pdcacoreno) as PdCaCoreNo,                  //선심수(1)
    max(pdcacondsize) as PdCaCondSize,              //도체사이즈(1)
    max(pdcaconddia) as PdCaCondDia,                //소선경(1)
    max(pdcacondmat) as PdCaCondMat,                //도체재질
    max(pdlninsmat) as PdLnInsMat,                  //Lan절연자재
    
    max(pdcafibertype1) as PdCaFiberType1,          //광섬유 종류(1)
    max(pdocfibernotube1) as PdOcFiberNoTube1,      //광섬유 심선수(1)/튜브
    
    max(pdpcdrydayno) as PdPcDryDayNo,              //건조일수    
    max(pdcainxnomthick) as PdCaInxNomThick,        //절연공칭두께 
    
    max(colorbase) as ColorBase,                    //색상(통합)
    max(pdcacolorstripe) as PdcaColorStripe,        //스트라이프
    max(pdcacolorstripeno) as PdcaColorStripeNo,    //스트라이프 No
    
    max(rlcaprotecttype) as RlCaProtectType,        //포장재Type
    max(rlcastdmatname) as RlCaStdMatName,          //드럼/드럼부품 표준품명
    max(pdcaspecno) as PdCaSpecNo,
    max(msolddesignno) as MsOldDesingNo             //구 설계번호
    
}
group by werks, matnr, spart, spg, mtart, mtref, lvormc, lvormp, matkl, mmsta, dispo, beskz, sobsl, dpcbt, maabc, maktx, ersda, laeda, cuobj
