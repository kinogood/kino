@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[BD] 판매 구성형 특성값'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_BD_GET_VCOFSO as 
    select from vbap as v inner join ibin as b
                                  on v.cuobj = b.instance
                          inner join ibinvalues as cv
                                  on b.in_recno = cv.in_recno
                          inner join ibsymbol as cs
                                  on cv.symbol_id = cs.symbol_id
                          inner join cabn as d
                                  on cs.atinn = d.atinn
                          inner join cabnt as t
                                  on d.atinn = t.atinn
                                 and t.spras = $session.system_language
                          /*inner join cawn as ca
                                  on cs.atinn = ca.atinn
                                 and cs.atwrt = ca.atwrt
                                 //and ca.adzhl = '0000'
                          inner join cawnt as ct
                                  on ca.atinn = ct.atinn
                                 and ca.atzhl = ct.atzhl
                                 and ca.spras = $session.system_language */                 
{
    key v.vbeln,
    key v.posnr,
    key v.werks,
    key v.matnr,
    
        b.instance,
        b.klart,
        b.valfr,
        b.valto,
        b.in_recno,
        
        d.atinn,
        d.atnam,
        d.atfor,
        t.atbez,
        
        cs.atwrt, //특성갑
        cs.atflv, //하한값
        cs.atflb //상한값    
        
        //ct.atwtb  //특징값 내역
}
