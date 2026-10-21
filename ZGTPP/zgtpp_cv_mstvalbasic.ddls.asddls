@AbapCatalog.sqlViewName: 'ZGTIMSTVAL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재 특성 값'
@ClientHandling.algorithm: #SESSION_VARIABLE
define view ZGTPP_CV_MSTVALBASIC as 
select from mara
inner join marc
   on mara.mandt = marc.mandt
   and mara.matnr = marc.matnr
inner join t134
   on mara.mandt = t134.mandt
   and mara.mtart = t134.mtart
inner join makt
    on marc.mandt = makt.mandt
    and marc.matnr = makt.matnr
    and makt.spras = $session.system_language

association [0..*] to zgtcvmstchar as _char on $projection.matnr = _char.objek
{
    key marc.werks,
    key marc.matnr,
    mara.mtart,
    t134.mtref,
    mara.spart,
    left(marc.dispo,2) as spg,
    mara.lvorm as lvormC,
    marc.lvorm as lvormP,
    mara.matkl,
    marc.mmsta,
    marc.dispo,
    marc.beskz,
    marc.sobsl,
    marc.dpcbt,
    marc.maabc,
    makt.maktx,
    mara.ersda,
    mara.laeda,
    marc.cuobj,
    
    _char[atnam = 'PD_CA_PROC_NAME'].atwrt as PdCaProcCode,
    _char[atnam = 'PD_CA_PROC_NAME'].atwtb as PdCaProcName,        
    _char[atnam = 'PD_CA_COND_SIZE_1ST'].atwtb as PdCaCondSize,
    _char[atnam = 'PD_CA_INX_NOM_THICK'].dec_value_from as PdCaInxNomThick,
    _char[atnam = 'PD_CA_CORE_NO_1ST'].dec_value_from as PdCaCoreNo,
    _char[atnam = 'PD_CA_PROC_OUT_DIA'].dec_value_from as PdCaProcOutDia,
    _char[atnam = 'PD_AA_STD_PRODUCT_NAME'].atwrt as PdStdProductName,
    _char[atnam = 'PD_CA_SEGMENT_NO'].dec_value_from as PdCaSegmentNo,
    _char[atnam = 'PD_CA_DESIGN_NO'].atwrt as PdCaDesignNo,
    _char[atnam = 'PD_CA_DESIGN_REV_NO'].atwrt as PdCaDesignRevNo,   
    _char[atnam = 'RL_CA_STD_MAT_NAME'].atwrt as RlCaStdMatName,
    _char[atnam = 'PD_PC_DRY_DAY_NO'].dec_value_from as PdPcDryDayNo,
    _char[atnam = 'PD_CA_COND_DIA_1ST'].dec_value_from as PdCaCondDia,
    _char[atnam = 'PD_CA_COND_MAT'].atwrt as PdCaCondMat,
    _char[atnam = 'PD_LN_INS_MAT'].atwrt as PdLnInsMat,
    _char[atnam = 'PD_CA_SPEC_NO'].atwrt as PdCaSpecNo,
    _char[atnam = 'PD_CA_FIBER_TYPE_1ST'].atwrt as PdCaFiberType1,
    _char[atnam = 'PD_OC_FIBER_NO_1ST_IN_TUBE'].dec_value_from as PdOcFiberNoTube1,
    _char[atnam = 'MS_OLD_DESIGN_NO'].atwrt as MsOldDesignNo,
    
    case coalesce(_char[atnam = 'PD_CA_VOLTAGE'].atwtb,'') 
        when '' then _char[atnam = 'PD_CA_VOLTAGE'].atwrt 
        else _char[atnam = 'PD_CA_VOLTAGE'].atwtb end as PdCaVoltage,
        
    case coalesce(_char[atnam = 'RL_CA_PROTECT_TYPE'].atwtb,'') 
        when '' then _char[atnam = 'RL_CA_PROTECT_TYPE'].atwrt 
        else _char[atnam = 'RL_CA_PROTECT_TYPE'].atwtb end as RlCaProtectType,
    
    case coalesce(_char[atnam = 'PD_CA_COLOR_BASE'].atwrt,'')                           //<1 색상(Base)값
    when '' then (case coalesce(_char[atnam = 'PD_CA_COLOR_BASE'].atwtb,'')             //<2 색상(Base)내역
    when '' then (case coalesce(_char[atnam = 'PD_CA_INS_IDEN_CODE'].atwrt,'')          //<3 절연선심식별코드값
    when '' then (case coalesce(_char[atnam = 'PD_GL_INS_COLOR'].atwtb,'')              //<4 LAN절연색상내역
    when '' then (case coalesce(_char[atnam = 'PD_GL_INS_COLOR'].atwrt,'')              //<5 LAN절연색상값
    when '' then (case coalesce(_char[atnam = 'PD_GL_PAR_COLOR'].atwrt,'')              //<6 LAN대연색상값
    when '' then (case coalesce(_char[atnam = 'PD_OC_FIBER_COLOR_BASE'].atwtb,'')       //<7 광섬유색상(Base)내역
    when '' then (case coalesce(_char[atnam = 'PD_OC_FIBER_COLOR_BASE'].atwrt,'')       //<8 광섬유색상(Base)값
    when '' then (case coalesce(_char[atnam = 'PD_OC_TUBE_COLOR_BASE'].atwtb,'')        //<9 튜브색상(Base)내역
    when '' then (case coalesce(_char[atnam = 'PD_OC_TUBE_COLOR_BASE'].atwrt,'')        //<10 튜브색상(Base)값
    when '' then (case coalesce(_char[atnam = 'PD_OC_BUFFER_COLOR_BASE'].atwtb,'')      //<11 Buffer색상내역
    when '' then (case coalesce(_char[atnam = 'PD_OC_BUFFER_COLOR_BASE'].atwrt,'')      //<12 Buffer색상값
    when '' then (case coalesce(_char[atnam = 'PD_CA_SHE_IDEN_CODE'].atwrt,'')          //<13 쉬스식별코드(색상)값
    when '' then (case coalesce(_char[atnam = 'RW_CA_COLOR'].atwrt,'')                  //<14 테핑색상값
    when '' then ''                                                                     //=======================//
    else _char[atnam = 'RW_CA_COLOR'].atwrt end)                                        //14> 테핑색상값
    else _char[atnam = 'PD_CA_SHE_IDEN_CODE'].atwrt end)                                //13> 쉬스식별코드(색상)값
    else _char[atnam = 'PD_OC_BUFFER_COLOR_BASE'].atwrt end)                            //12> Buffer색상값
    else _char[atnam = 'PD_OC_BUFFER_COLOR_BASE'].atwtb end)                            //11> Buffer색상내역
    else _char[atnam = 'PD_OC_TUBE_COLOR_BASE'].atwrt end)                              //10> 튜브색상(Base)값
    else _char[atnam = 'PD_OC_TUBE_COLOR_BASE'].atwtb end)                              //9> 튜브색상(Base)내역
    else _char[atnam = 'PD_OC_FIBER_COLOR_BASE'].atwrt end)                             //8> 광섬유색상(Base)값
    else _char[atnam = 'PD_OC_FIBER_COLOR_BASE'].atwtb end)                             //7> 광섬유색상(Base)내역
    else _char[atnam = 'PD_GL_PAR_COLOR'].atwrt end)                                    //6> LAN대연색상값
    else _char[atnam = 'PD_GL_INS_COLOR'].atwrt end)                                    //5> LAN절연색상값
    else _char[atnam = 'PD_GL_INS_COLOR'].atwtb end)                                    //4> LAN절연색상내역
    else _char[atnam = 'PD_CA_INS_IDEN_CODE'].atwrt end)                                //3> 절연선심식별코드값
    else _char[atnam = 'PD_CA_COLOR_BASE'].atwtb end)                                   //2> 색상(Base)내역
    else _char[atnam = 'PD_CA_COLOR_BASE'].atwrt end as ColorBase,                      //1> 색상(Base)값
    
    _char[atnam = 'PD_CA_COLOR_STRIPE'].atwrt as PdcaColorStripe,
    _char[atnam = 'PD_CA_COLOR_STRIPE_NO'].atwrt as PdcaColorStripeNo

}
