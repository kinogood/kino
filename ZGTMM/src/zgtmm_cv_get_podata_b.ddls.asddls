@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매오더 특성 정보 추출'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_PODATA_B
// 비상비 구매-PR 업음 
as select from ekpo as A inner join ZGTMM_CV_PO_VCVALUE as B on A.ebeln = B.PDOC and A.ebelp = B.PDOCITEM
                         left outer join ZGTMM_CV_SRMPO_CHANGECHAR as C on B.PDOC = C.ebeln and B.PDOCITEM = C.ebelp and B.atnam = C.atnam 
{
 
   key    A.ebeln,
   key    A.ebelp,
          @Semantics.quantity.unitOfMeasure: 'MEINS'      
          A.menge,
          A.meins,
          B.atnam,
          B.atbez,
          B.VALUE as atwrt,
          case when C.atwrt is not null then C.atwrt else cast('' as atwrt) end as ATWRT_O,
          cast('' as abap.char(1)) as DUPCHECK   
} where A.knttp <> 'M' and A.knttp <> '' and (B.atnam <> 'PD_CA_CORE_NO_1ST' and B.atnam <> 'PD_CA_CORE_TYPE_1ST' and B.atnam <> 'PD_CA_COND_SIZE_1ST'
                            and B.atnam <> 'PD_CA_CORE_NO_2ND' and B.atnam <> 'PD_CA_CORE_TYPE_2ND' and B.atnam <> 'PD_CA_COND_SIZE_2ND'
                            and B.atnam <> 'PD_CA_FIBER_TYPE_1ST' and B.atnam <> 'PD_CA_FIBER_NO_1ST' and B.atnam <> 'PD_CA_FIBER_TYPE_2ND'
                            and B.atnam <> 'PD_CA_FIBER_NO_2ND') and A.banfn = ''

union
// 비상비 구매-PR 존재-드럼 존재
select from ekpo as A inner join ZGTMM_CV_PO_VCVALUE as B on A.ebeln = B.PDOC and A.ebelp = B.PDOCITEM
                      inner join ZGTMM_CV_GET_PR_DRUM_MAP  as pr on A.banfn = pr.banfn and A.bnfpo = pr.bnfpo
                      left outer join ZGTMM_CV_SRMPO_CHANGECHAR as C on B.PDOC = C.ebeln and B.PDOCITEM = C.ebelp and B.atnam = C.atnam 
{
 
   key    A.ebeln,
   key    A.ebelp, 
          A.menge,
          A.meins,
          B.atnam,
          B.atbez,
          B.VALUE as atwrt,
          case when C.atwrt is not null then C.atwrt else cast('' as atwrt) end as ATWRT_O,
          cast('' as abap.char(1)) as DUPCHECK   
} where A.knttp <> 'M' and A.knttp <> '' and (B.atnam <> 'PD_CA_CORE_NO_1ST' and B.atnam <> 'PD_CA_CORE_TYPE_1ST' and B.atnam <> 'PD_CA_COND_SIZE_1ST'
                            and B.atnam <> 'PD_CA_CORE_NO_2ND' and B.atnam <> 'PD_CA_CORE_TYPE_2ND' and B.atnam <> 'PD_CA_COND_SIZE_2ND'
                            and B.atnam <> 'PD_CA_FIBER_TYPE_1ST' and B.atnam <> 'PD_CA_FIBER_NO_1ST' and B.atnam <> 'PD_CA_FIBER_TYPE_2ND'
                            and B.atnam <> 'PD_CA_FIBER_NO_2ND') and A.banfn <> '' and pr.checkpr = 'X' and B.atnam <>'PD_CA_PACKING_DM' and B.atnam <> 'SAP_MILLCA_PACKAGING'


union
// 비상비 구매-PR 존재-드럼 존재-특성 추가
select from ekpo as A inner join ZGTMM_CV_GET_DRUM_NAME_PR  as pr on A.banfn = pr.banfn and A.bnfpo = pr.bnfpo
                      left outer join ZGTMM_CV_SRMPO_CHANGECHAR as C on A.ebeln = C.ebeln and A.ebelp = C.ebelp and C.atnam ='PD_CA_PACKING_DM'
{
 
   key    A.ebeln,
   key    A.ebelp, 
          A.menge,
          A.meins,
          cast('PD_CA_PACKING_DM' as atnam) as atnam,
          cast('포장재(드럼)' as atbez) as atbez,
          cast(pr.DRUMNAME as atwrt) as atwrt,
          case when C.atwrt is not null then C.atwrt else cast('' as atwrt) end as ATWRT_O,
          cast('' as abap.char(1)) as DUPCHECK   
} where A.knttp <> 'M' and A.knttp <> ''  


union
// 비상비 구매-PR 존재-드럼 없음
select from ekpo as A inner join ZGTMM_CV_PO_VCVALUE as B on A.ebeln = B.PDOC and A.ebelp = B.PDOCITEM
                      inner join ZGTMM_CV_GET_PR_DRUM_MAP  as pr on A.banfn = pr.banfn and A.bnfpo = pr.bnfpo
                      left outer join ZGTMM_CV_SRMPO_CHANGECHAR as C on B.PDOC = C.ebeln and B.PDOCITEM = C.ebelp and B.atnam = C.atnam 
{
 
   key    A.ebeln,
   key    A.ebelp, 
          A.menge,
          A.meins,
          B.atnam,
          B.atbez,
          B.VALUE as atwrt,
          case when C.atwrt is not null then C.atwrt else cast('' as atwrt) end as ATWRT_O,
          cast('' as abap.char(1)) as DUPCHECK   
} where A.knttp <> 'M' and A.knttp <> '' and (B.atnam <> 'PD_CA_CORE_NO_1ST' and B.atnam <> 'PD_CA_CORE_TYPE_1ST' and B.atnam <> 'PD_CA_COND_SIZE_1ST'
                            and B.atnam <> 'PD_CA_CORE_NO_2ND' and B.atnam <> 'PD_CA_CORE_TYPE_2ND' and B.atnam <> 'PD_CA_COND_SIZE_2ND'
                            and B.atnam <> 'PD_CA_FIBER_TYPE_1ST' and B.atnam <> 'PD_CA_FIBER_NO_1ST' and B.atnam <> 'PD_CA_FIBER_TYPE_2ND'
                            and B.atnam <> 'PD_CA_FIBER_NO_2ND') and A.banfn <> '' and pr.checkpr = '' 
union

//일반구매-pr 없음
select from ekpo as A inner join ZGTMM_CV_PO_VCVALUE as B on A.ebeln = B.PDOC and A.ebelp = B.PDOCITEM
                         left outer join ZGTMM_CV_SRMPO_CHANGECHAR as C on B.PDOC = C.ebeln and B.PDOCITEM = C.ebelp and B.atnam = C.atnam 
{
 
   key    A.ebeln,
   key    A.ebelp,   
          A.menge,
          A.meins,
          B.atnam,
          B.atbez,
          B.VALUE as atwrt,
          case when C.atwrt is not null then C.atwrt else cast('' as atwrt) end as ATWRT_O,
          cast('' as abap.char(1)) as DUPCHECK   
} where A.knttp = '' and (B.atnam <> 'PD_CA_CORE_NO_1ST' and B.atnam <> 'PD_CA_CORE_TYPE_1ST' and B.atnam <> 'PD_CA_COND_SIZE_1ST'
                            and B.atnam <> 'PD_CA_CORE_NO_2ND' and B.atnam <> 'PD_CA_CORE_TYPE_2ND' and B.atnam <> 'PD_CA_COND_SIZE_2ND'
                            and B.atnam <> 'PD_CA_FIBER_TYPE_1ST' and B.atnam <> 'PD_CA_FIBER_NO_1ST' and B.atnam <> 'PD_CA_FIBER_TYPE_2ND'
                            and B.atnam <> 'PD_CA_FIBER_NO_2ND') and A.banfn = ''
                            
union

//일반구매-pr 존재-드럼 있음
select from ekpo as A inner join ZGTMM_CV_PO_VCVALUE as B on A.ebeln = B.PDOC and A.ebelp = B.PDOCITEM
                      inner join ZGTMM_CV_GET_PR_DRUM_MAP  as pr on A.banfn = pr.banfn and A.bnfpo = pr.bnfpo
                      left outer join ZGTMM_CV_SRMPO_CHANGECHAR as C on B.PDOC = C.ebeln and B.PDOCITEM = C.ebelp and B.atnam = C.atnam 
{
 
   key    A.ebeln,
   key    A.ebelp,   
          A.menge,
          A.meins,
          B.atnam,
          B.atbez,
          B.VALUE as atwrt,
          case when C.atwrt is not null then C.atwrt else cast('' as atwrt) end as ATWRT_O,
          cast('' as abap.char(1)) as DUPCHECK   
} where A.knttp = '' and (B.atnam <> 'PD_CA_CORE_NO_1ST' and B.atnam <> 'PD_CA_CORE_TYPE_1ST' and B.atnam <> 'PD_CA_COND_SIZE_1ST'
                            and B.atnam <> 'PD_CA_CORE_NO_2ND' and B.atnam <> 'PD_CA_CORE_TYPE_2ND' and B.atnam <> 'PD_CA_COND_SIZE_2ND'
                            and B.atnam <> 'PD_CA_FIBER_TYPE_1ST' and B.atnam <> 'PD_CA_FIBER_NO_1ST' and B.atnam <> 'PD_CA_FIBER_TYPE_2ND'
                            and B.atnam <> 'PD_CA_FIBER_NO_2ND') and A.banfn <> ''  and pr.checkpr = 'X' and B.atnam <>'PD_CA_PACKING_DM' and B.atnam <> 'SAP_MILLCA_PACKAGING'                          

union
// 일 구매-PR 존재-드럼 존재-특성 추가
select from ekpo as A inner join ZGTMM_CV_GET_DRUM_NAME_PR  as pr on A.banfn = pr.banfn and A.bnfpo = pr.bnfpo
                      left outer join ZGTMM_CV_SRMPO_CHANGECHAR as C on A.ebeln = C.ebeln and A.ebelp = C.ebelp and C.atnam ='PD_CA_PACKING_DM'
{
 
   key    A.ebeln,
   key    A.ebelp, 
          A.menge,
          A.meins,
          cast('PD_CA_PACKING_DM' as atnam) as atnam,
          cast('포장재(드럼)' as atbez) as atbez,
          cast(pr.DRUMNAME as atwrt) as atwrt,
          case when C.atwrt is not null then C.atwrt else cast('' as atwrt) end as ATWRT_O,
          cast('' as abap.char(1)) as DUPCHECK   
} where A.knttp = ''  

union

//일반구매-pr 존재-드럼 없음
select from ekpo as A inner join ZGTMM_CV_PO_VCVALUE as B on A.ebeln = B.PDOC and A.ebelp = B.PDOCITEM
                      inner join ZGTMM_CV_GET_PR_DRUM_MAP  as pr on A.banfn = pr.banfn and A.bnfpo = pr.bnfpo
                      left outer join ZGTMM_CV_SRMPO_CHANGECHAR as C on B.PDOC = C.ebeln and B.PDOCITEM = C.ebelp and B.atnam = C.atnam 
{
 
   key    A.ebeln,
   key    A.ebelp,   
          A.menge,
          A.meins,
          B.atnam,
          B.atbez,
          B.VALUE as atwrt,
          case when C.atwrt is not null then C.atwrt else cast('' as atwrt) end as ATWRT_O,
          cast('' as abap.char(1)) as DUPCHECK   
} where A.knttp = '' and (B.atnam <> 'PD_CA_CORE_NO_1ST' and B.atnam <> 'PD_CA_CORE_TYPE_1ST' and B.atnam <> 'PD_CA_COND_SIZE_1ST'
                            and B.atnam <> 'PD_CA_CORE_NO_2ND' and B.atnam <> 'PD_CA_CORE_TYPE_2ND' and B.atnam <> 'PD_CA_COND_SIZE_2ND'
                            and B.atnam <> 'PD_CA_FIBER_TYPE_1ST' and B.atnam <> 'PD_CA_FIBER_NO_1ST' and B.atnam <> 'PD_CA_FIBER_TYPE_2ND'
                            and B.atnam <> 'PD_CA_FIBER_NO_2ND') and A.banfn <> ''  and pr.checkpr = ''                          
        
                            
union

//MTO 구매
select from ekpo as A inner join ekkn as B on A.ebeln = B.ebeln and A.ebelp = B.ebelp and B.zekkn = '01'
                      inner join vbap as C on B.vbeln = C.vbeln and B.vbelp = C.posnr 
                      inner join ZGTMM_CV_SO_VCVALUE as D on C.vbeln = D.vbeln and C.posnr = D.posnr
                      left outer join ZGTMM_CV_SRMPO_CHANGECHAR as E on A.ebeln = E.ebeln and A.ebelp = E.ebelp and D.atnam = E.atnam 
association [0..*] to ZGTMM_CV_PO_VCVALUE as SO on $projection.ebeln = SO.PDOC and $projection.ebelp = SO.PDOCITEM and $projection.atnam = SO.atnam

{
   key    A.ebeln,
   key    A.ebelp,    
          A.menge,
          A.meins,
          D.atnam,
          D.atbez,
          D.VALUE as atwrt,
          case when E.atwrt is not null then E.atwrt else cast('' as atwrt) end as ATWRT_O,
          case when SO.atnam is not null then cast('X' as abap.char(1)) else cast('' as abap.char(1)) end as DUPCHECK   
} where A.knttp = 'M' and (D.atnam <> 'PD_CA_CORE_NO_1ST' and D.atnam <> 'PD_CA_CORE_TYPE_1ST' and D.atnam <> 'PD_CA_COND_SIZE_1ST'
                            and D.atnam <> 'PD_CA_CORE_NO_2ND' and D.atnam <> 'PD_CA_CORE_TYPE_2ND' and D.atnam <> 'PD_CA_COND_SIZE_2ND'
                            and D.atnam <> 'PD_CA_FIBER_TYPE_1ST' and D.atnam <> 'PD_CA_FIBER_NO_1ST' and D.atnam <> 'PD_CA_FIBER_TYPE_2ND'
                            and D.atnam <> 'PD_CA_FIBER_NO_2ND')
                            
union

//기타특성정보
select from ekpo as A inner join ZGTSD_I_MaterialCharacteristic as b on A.matnr = b.matnr
                       left outer join ZGTMM_CV_SRMPO_CHANGECHAR as E on A.ebeln = E.ebeln and A.ebelp = E.ebelp and b.atnam = E.atnam
{
   key    A.ebeln,
   key    A.ebelp,    
          A.menge,
          A.meins,
          b.atnam,
          b.atbez,
          b.atwrt,
          case when E.atwrt is not null then E.atwrt else cast('' as atwrt) end as ATWRT_O,
          cast('' as abap.char(1)) as DUPCHECK   
} where  b.atnam = 'PD_CA_CORE_NO_1ST' or b.atnam = 'PD_CA_CORE_TYPE_1ST' or b.atnam = 'PD_CA_COND_SIZE_1ST'
                            or b.atnam = 'PD_CA_CORE_NO_2ND' or b.atnam = 'PD_CA_CORE_TYPE_2ND' or b.atnam = 'PD_CA_COND_SIZE_2ND'
                            or b.atnam = 'PD_CA_FIBER_TYPE_1ST' or b.atnam = 'PD_CA_FIBER_NO_1ST' or b.atnam = 'PD_CA_FIBER_TYPE_2ND'
                            or b.atnam = 'PD_CA_FIBER_NO_2ND'                            
