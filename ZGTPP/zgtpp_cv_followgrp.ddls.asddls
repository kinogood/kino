@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: '후속 조장 정보'
define view entity ZGTPP_CV_FOLLOWGRP as select from zgtppt2010 
{
    key grpnr,
    key ordnr,
    sum(inlength) as inlength
}
group by grpnr, ordnr
