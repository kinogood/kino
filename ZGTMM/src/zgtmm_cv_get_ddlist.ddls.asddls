@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직송 의뢰 대상 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_DDLIST 
as select from ekpo as A inner join ekkn as B on A.ebeln = B.ebeln and A.ebelp = B.ebelp and B.zekkn = '01'
                         inner join vbap as C on B.vbeln = C.vbeln and B.vbelp = C.posnr
                         inner join ekko as D on A.ebeln = D.ebeln
                         inner join vbak as E on C.vbeln = E.vbeln
                         left outer join ZGTMM_CV_POGR_INFO as F on A.ebeln = F.ebeln and A.ebelp = F.ebelp
   //                      left outer join ZGTMM_CV_GET_GODELIVERY_SUMPO as I on A.ebeln = I.ebeln and A.ebelp = I.ebelp
   //                      left outer join ZGTMM_CV_GET_OEM_DELIVER_ITEM  as I on A.ebeln = I.ebeln and A.ebelp = I.ebelp and C.vbeln = I.vbeln and C.posnr = I.posnr
                         left outer join ZGTMM_CV_GET_ZGTMMT4403_SUM2  as I on A.ebeln = I.ebeln and A.ebelp = I.ebelp and C.vbeln = I.vbeln and C.posnr = I.posnr
                         left outer join ZGTMM_CV_GET_ZGTMMT4403_SUM  as J on A.ebeln = J.ebeln and A.ebelp = J.ebelp and C.vbeln = J.vbeln and C.posnr = J.posnr
                         left outer join ZGTMM_CV_GET_ZGTMMT4411_QTY   as K on A.ebeln = K.ebeln and A.ebelp = K.ebelp and C.vbeln = K.vbeln and C.posnr = K.posnr
                         left outer join ZGTMM_CV_GET_ZGTMMT4411_QTY2   as L on A.ebeln = L.ebeln and A.ebelp = L.ebelp and C.vbeln = L.vbeln and C.posnr = L.posnr
                         left outer join ZGTMM_CV_GET_ZGTMMT4411_QTY3   as M on A.ebeln = M.ebeln and A.ebelp = M.ebelp and C.vbeln = M.vbeln and C.posnr = M.posnr
  
  
   //                      left outer join ZGTMM_CV_GET_SALESSTOCKSUM as G on C.vbeln = G.vbeln and C.posnr = G.posnr
   //                      left outer join ZGTMM_CV_PO_VCVALUE_MAIN as H on H.PDOC = A.ebeln and H.PDOCITEM = A.ebelp and H.atnam = 'SAP_MILLCA_LENGTH'
//association [0..1] to ZGTMM_CV_GET_DDQTYSUM  as QTY1 
//                   on $projection.vbeln = QTY1.vbeln and $projection.posnr = QTY1.posnr and $projection.ebeln = QTY1.ebeln and $projection.ebelp = QTY1.ebelp and QTY1.zreq_type = 'A'
association [0..1] to ZGTMM_CV_GET_DDQTYSUM  as QTY2 
                   on $projection.vbeln = QTY2.vbeln and $projection.posnr = QTY2.posnr and $projection.ebeln = QTY2.ebeln and $projection.ebelp = QTY2.ebelp and QTY2.zreq_type = 'B'
association [0..1] to ZGTMM_CV_GET_SALESSTOCKSUM  as G
                   on $projection.vbeln = G.vbeln and $projection.posnr = G.posnr 
association [0..1] to ZGTMM_CV_PO_VCVALUE_MAIN as H
                   on $projection.ebeln = H.PDOC and $projection.ebelp = H.PDOCITEM                                       
                   
{
   key D.bukrs,
   key E.vkbur,
   key E.vkgrp,
   key E.zpjno,
   key E.vbeln,
   key C.posnr,
   key A.ebeln,
   key A.ebelp,
       D.lifnr,
       E.kunnr,
       A.matnr,
       A.txz01,
       @Semantics.quantity.unitOfMeasure: 'meins'  
       A.menge,      
       A.meins,
       @Semantics.quantity.unitOfMeasure: 'meins'    
       case when H.LENGTH is not null then cast(H.LENGTH as abap.quan(13,3)) 
            else A.menge end as length,
       @Semantics.quantity.unitOfMeasure: 'meins'  
       case when F.MENGE is not null then F.MENGE
            else cast(0 as abap.quan(13,3)) end as GR_QTY,
       @Semantics.quantity.unitOfMeasure: 'meins'            
       case when I.LOADQTY is not null then 
          cast(cast(I.LOADQTY as abap.dec(13,3)) * cast(H.LENGTH as abap.dec(13,3)) as abap.quan(13,3)) 
            else cast(0 as abap.quan(13,3)) end as DO_QTY,                  
       @Semantics.quantity.unitOfMeasure: 'meins'              
/*       case when F.MENGE is not null then 
                 case when I.LOADQTY is not null then 
                 A.menge - ( F.MENGE - cast(cast(I.LOADQTY as abap.dec(13,3)) * cast(H.LENGTH as abap.dec(13,3)) as abap.quan(13,3)) )
                      else A.menge - F.MENGE end
            else 
                 case when I.LOADQTY is not null then A.menge - cast(cast(I.LOADQTY as abap.dec(13,3)) * cast(H.LENGTH as abap.dec(13,3)) as abap.quan(13,3)) 
                      else A.menge end 
            end as REM_QTY,*/
       case when F.MENGE is not null then 
                 A.menge - F.MENGE 
            else 
                  A.menge  
            end as REM_QTY,            
       @Semantics.quantity.unitOfMeasure: 'dr_meins'            
/*       case when F.MENGE is not null then
            case when I.LOADQTY is not null then       
                  case when H.LENGTH is not null then cast((A.menge - ( F.MENGE - cast(cast(I.LOADQTY as abap.dec(13,3)) * cast(H.LENGTH as abap.dec(13,3)) as abap.quan(13,3)) ) )  / cast(H.LENGTH as abap.dec(13,3)) as abap.quan(13,3))
                  else cast((A.menge - ( F.MENGE - cast(cast(I.LOADQTY as abap.dec(13,3)) * cast(H.LENGTH as abap.dec(13,3)) as abap.quan(13,3)))) as abap.quan(13,3)) end
                 else
                  case when H.LENGTH is not null then cast((A.menge - F.MENGE)  / cast(H.LENGTH as abap.dec(13,3)) as abap.quan(13,3))
                  else cast((A.menge - F.MENGE) as abap.quan(13,3)) end
            end       
            else 
             case when I.LOADQTY is not null then
                 case when H.LENGTH is not null then cast((A.menge - cast(cast(I.LOADQTY as abap.dec(13,3)) * cast(H.LENGTH as abap.dec(13,3)) as abap.quan(13,3))) / cast(H.LENGTH as abap.dec(13,3)) as abap.quan(13,3))
                 else cast(A.menge - cast(cast(I.LOADQTY as abap.dec(13,3)) * cast(H.LENGTH as abap.dec(13,3)) as abap.quan(13,3)) as abap.quan(13,3))  end
             else            
              case when H.LENGTH is not null then cast(A.menge / cast(H.LENGTH as abap.dec(13,3)) as abap.quan(13,3))
                 else cast(A.menge as abap.quan(13,3))  end
             end
            end as REM_QTY_DR,     */
       case when F.MENGE is not null then
               case when H.LENGTH is not null then cast((A.menge - F.MENGE)  / cast(H.LENGTH as abap.dec(13,3)) as abap.quan(13,3))
                else cast((A.menge - F.MENGE) as abap.quan(13,3)) end
            else 
              case when H.LENGTH is not null then cast(A.menge / cast(H.LENGTH as abap.dec(13,3)) as abap.quan(13,3))
                 else cast(A.menge as abap.quan(13,3))  end
            end as REM_QTY_DR,              
     /*  @Semantics.quantity.unitOfMeasure: 'dr_meins'     
       case when QTY1.REQ_DRQTY is not null then QTY1.REQ_DRQTY
            else cast(0 as abap.quan(13,3)) end as req_drqty_n,                          
       case when QTY1.dr_meins is not null then QTY1.dr_meins
            else cast('DR' as abap.unit) end as dr_meins,*/
       @Semantics.quantity.unitOfMeasure: 'dr_meins'
       case when K.REQ_DRQTY is not null then 
              case when J.LOADQTY is not null then K.REQ_DRQTY - J.LOADQTY
                                              else K.REQ_DRQTY end
                                              
            else
              cast(0 as abap.quan(13,0))  
            end as REQ_DRQTY_N,
       case when K.REQ_DRQTY is not null then K.dr_meins
            else cast('DR' as abap.unit) end as DR_MEINS,
            
       @Semantics.quantity.unitOfMeasure: 'meins'  
       case when G.KALAB is not null then G.KALAB
            else cast(0 as abap.quan(13,3)) end as KEEP_QTY,     
       @Semantics.quantity.unitOfMeasure: 'dr_meins'     
       case when QTY2.REQ_DRQTY is not null then QTY2.REQ_DRQTY
            else cast(0 as abap.quan(13,3)) end as req_drqty_k,
       @Semantics.quantity.unitOfMeasure: 'dr_meins'            
       case when G.KALAB is not null then   
            case when H.LENGTH is not null then cast(G.KALAB / cast(H.LENGTH as abap.dec(13,3)) as abap.quan(13,3))
                 else cast(cast(H.LENGTH as abap.dec(13,3)) as abap.quan(13,3)) end
            else
               cast(0 as abap.quan(13,3)) 
            end as KEEP_QTY_DR,
/*       @Semantics.quantity.unitOfMeasure: 'dr_meins'   
       case when QTY1.zmm_drqty is not null then QTY1.zmm_drqty
            else cast(0 as abap.quan(13,3)) end as ZMM_DRQTY,            
       @Semantics.quantity.unitOfMeasure: 'dr_meins'   
       case when QTY1.zvd_drqty is not null then QTY1.zvd_drqty
            else cast(0 as abap.quan(13,3)) end as ZVD_DRQTY*/
       @Semantics.quantity.unitOfMeasure: 'dr_meins'      
       case when L.REQ_DRQTYSUM is not null then L.REQ_DRQTYSUM
            else cast(0 as abap.quan(13,3)) end as ZMM_DRQTY,   
       @Semantics.quantity.unitOfMeasure: 'dr_meins'              
       case when M.REQ_DRQTYSUM is not null then M.REQ_DRQTYSUM
            else cast(0 as abap.quan(13,3)) end as ZVD_DRQTY,
       @Semantics.quantity.unitOfMeasure: 'dr_meins'              
       case when J.LOADQTY is not null then J.LOADQTY
            else cast(0 as abap.quan(13,3)) end as loadqty   
                              
} where (A.werks = '6500' or A.werks = '6600' or A.werks = '6581') and A.loekz = '' and A.elikz = ''
