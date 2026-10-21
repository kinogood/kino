@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[BD] Busbar Search help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_BD_SH_BUSBAR as 
    select from mara as m inner join marc as c
                                  on m.matnr = c.matnr
                          inner join t023t as b
                                  on m.matkl = b.matkl
                                 and b.spras = $session.system_language
                          inner join makt as t
                                  on m.matnr = t.matnr
                                 and t.spras = $session.system_language
{
    key m.matnr,
        
        t.maktx,
        m.matkl,
        b.wgbez
        
} where m.lvorm <> 'X'
    and m.mtart = 'ROH1'
    and c.lvorm <> 'X'
    and c.werks = '1306'
    and ( m.matkl = 'NBD000001' or m.matkl = 'NBD000002' )
