@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[BD] 정보레코드 단가'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_BD_INFO_PRICE as 
    select from eina as i inner join eine as e
                                  on i.infnr = e.infnr
                          inner join a017 as a
                                  on i.lifnr = a.lifnr
                                 and i.matnr = a.matnr
                                 and e.ekorg = a.ekorg
                                 and e.werks = a.werks
                                 and e.esokz = a.esokz
                                 and a.kappl = 'M'
                                 and a.kschl = 'PB00'
                          inner join lfm1 as m
                                  on a.lifnr = m.lifnr
                                 and a.ekorg = m.ekorg
                                 and m.loevm <> 'X'
                                 and m.sperm <> 'X'
                          inner join konp as k
                                  on a.knumh = k.knumh
                                 and k.kopos = '01'
{
    key i.infnr,
    key e.ekorg,
    key e.esokz,
    key e.werks,
    
        i.matnr,
        i.matkl,
        i.idnlf,
        i.lifnr,
        
        a.datbi,
        a.datab,
        a.knumh,
        
        @Semantics.amount.currencyCode: 'konwa'
        k.kbetr,  //단가,비율
        k.konwa,  //통화
        k.kpein as peinh,  //per
        k.kmein as bprme,  //갸격단위
        i.txz01
        
} where i.loekz = '' 
    and e.loekz = ''
    
union

    select from eina as i inner join eine as e
                                  on i.infnr = e.infnr
                          inner join a025 as a
                                  on i.lifnr = a.lifnr
                                 and e.ekorg = a.ekorg
                                 and i.matkl = a.matkl
                                 and i.infnr = a.infnr
                                 and e.werks = a.werks
                                 and e.esokz = a.esokz
                                 and a.kappl = 'M'
                                 and a.kschl = 'PB00'
                          inner join lfm1 as m
                                  on a.lifnr = m.lifnr
                                 and a.ekorg = m.ekorg
                                 and m.loevm <> 'X'
                                 and m.sperm <> 'X'
                          inner join konp as k
                                  on a.knumh = k.knumh
                                 and k.kopos = '01'
{
    key i.infnr,
    key e.ekorg,
    key e.esokz,
    key e.werks,
    
        i.matnr,
        i.matkl,
        i.idnlf,
        i.lifnr,
        
        a.datbi,
        a.datab,
        a.knumh,
        
//        @Semantics.amount.currencyCode: 'konwa'
        k.kbetr,  //단가,비율
        k.konwa,  //통화
        k.kpein as peinh,  //per
        k.kmein as bprme,  //갸격단위
        i.txz01
        
} where i.loekz = '' 
    and e.loekz = ''
