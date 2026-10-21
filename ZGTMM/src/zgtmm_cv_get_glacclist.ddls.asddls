@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'G/L계정 리스트 조회(비용 계정)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_GLACCLIST 
as 
select from ska1 as a inner join skb1 as b on a.saknr = b.saknr
                      inner join tkska as c on a.ktopl = c.ktopl and a.saknr = c.vonkto
                      inner join skat as d on a.ktopl = d.ktopl and a.saknr = d.saknr
{
   key b.bukrs,
   key a.saknr,
   d.txt50,
   case when a.xloev = 'X' or b.xloeb = 'X' then cast('X' as abap.char(1))
        else cast('' as abap.char(1)) end as xlobe
    
} where d.spras = $session.system_language and c.katyp = '01' and left(a.saknr,4) = '0006'
