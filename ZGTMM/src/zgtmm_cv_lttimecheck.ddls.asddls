@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'LEADTIME 비교 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_LTTIMECHECK 
as 
select from ekko as A inner join ekpo as B on A.ebeln = B.ebeln 
                      inner join eina as C on B.infnr = C.infnr 
                      inner join eine as D on C.infnr = D.infnr and A.ekorg = D.ekorg and B.werks = D.werks and B.pstyp = D.esokz  //일반,외주만
                      inner join eket as E on B.ebeln = E.ebeln and B.ebelp = E.ebelp and E.etenr = '0001'   
 
association [0..1] to eban as PR on $projection.banfn = PR.banfn and $projection.bnfpo = PR.bnfpo     
association [0..1] to ZGTMM_CV_GRDATECHECK as GR on $projection.ebeln = GR.ebeln and $projection.ebelp = GR.ebelp    
association [1..1] to lfa1 as LFA1 on $projection.lifnr = LFA1.lifnr              
association [1..1] to t001 as T001 on $projection.bukrs = T001.bukrs  
association [1..1] to t024e as T024E on $projection.ekorg = T024E.ekorg      
association [1..1] to t001w as T001W on $projection.werks = T001W.werks      
{
   key B.ebeln,
   key B.ebelp,
       A.bukrs,
       t001.butxt as BUKRS_N,
       A.ekorg,
       t024e.ekotx as EKORG_N,
       B.werks,
       t001w.name1 as WERKS_N,
       A.lifnr,
       lfa1.name1 as LIFNR_N,
       B.matnr,
       B.txz01,
       @Semantics.quantity.unitOfMeasure: 'MEINS'  
       B.menge,
       B.meins,
       B.banfn,
       B.bnfpo,
       cast(PR.creationdate as me_pdi_creationdate) as PRDATE_C,   //구매요청일
       cast(PR.lfdat as eindt) as PRDATE_R,                        //PR납품요청일
       A.bedat as PODATE_C,                                        //구매오더생성일 
       E.eindt as PODATE_R,                                        //PO납품요청일      
       D.aplfz as INFO_LT,                                         //표준리드타임    
       dats_days_between(PR.creationdate,PR.lfdat) as PRDATE_LT,   //PR리드타임  
       dats_days_between(A.bedat,E.eindt) as PODATE_LT,            //PO리드타임
       
       case when D.aplfz = dats_days_between(A.bedat,E.eindt)
            then
               cast('SAME' as abap.char(4))
            else
               cast('DIFF' as abap.char(4))
            end as POLTCHECK,                                      //Info표준 리드타임 Vs PO 리드타임 점검
       
       cast(GR.MINGRDATE as budat) as GRDATE_F,                    //최초입고일
       cast(GR.MAXGRDATE as budat) as GRDATA_L,                    //최종입고일
       case when GR.MINGRDATE is not null                           
            then dats_days_between(A.bedat,GR.MINGRDATE)
            else cast(0 as abap.int4) end as LT_F,                 //최초입고기준 리드타임
/*            
       case when GR.MINGRDATE is not null 
            then case when GR.MINGRDATE = E.eindt 
                      then  cast('SAME' as abap.char(4))
                      else
                            cast('DIFF' as abap.char(4))
                 end
            else cast('' as abap.char(4)) end as FIRSTGR_CHECK,    //최초 입고일 체크 */

       case when GR.MINGRDATE is not null 
            then case when D.aplfz = dats_days_between(A.bedat,GR.MINGRDATE)
                      then  cast('SAME' as abap.char(4))
                      else
                            cast('DIFF' as abap.char(4))
                 end
            else cast('' as abap.char(4)) end as FIRSTGR_CHECK,    //최초 입고일 체크            
             
       case when GR.MAXGRDATE is not null 
            then dats_days_between(A.bedat,GR.MAXGRDATE)
            else cast(0 as abap.int4) end as LT_L,                 //최종입고기준 리드타임

       case when GR.MAXGRDATE is not null 
            then case when D.aplfz = dats_days_between(A.bedat,GR.MAXGRDATE)
                      then  cast('SAME' as abap.char(4))
                      else
                            cast('DIFF' as abap.char(4))
                 end
            else cast('' as abap.char(4)) end as LASTGR_CHECK      //최종 입고일 체크

       
/*       case when GR.MAXGRDATE is not null 
            then case when GR.MAXGRDATE = E.eindt 
                      then  cast('SAME' as abap.char(4))
                      else
                            cast('DIFF' as abap.char(4))
                 end
            else cast('' as abap.char(4)) end as LASTGR_CHECK      //최종 입고일 체크*/
            
} where A.lifnr  <> '' and B.loekz = ''
