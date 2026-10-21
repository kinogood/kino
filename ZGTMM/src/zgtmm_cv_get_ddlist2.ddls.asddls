@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '직송 의뢰 대상 조회(RFC용)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_DDLIST2 as select from ZGTMM_CV_GET_DDLIST
{
   key bukrs,
   key vkbur,
   key vkgrp,
   key zpjno,
   key vbeln,
   key posnr,
   key ebeln,
   key ebelp,
       lifnr,
       kunnr,
       matnr,
       txz01,
       @Semantics.quantity.unitOfMeasure: 'meins'  
       menge,      
       meins,
       @Semantics.quantity.unitOfMeasure: 'meins'    
       length,
       @Semantics.quantity.unitOfMeasure: 'meins'  
       GR_QTY,
       @Semantics.quantity.unitOfMeasure: 'meins'              
       REM_QTY,
       @Semantics.quantity.unitOfMeasure: 'dr_meins'            
       REM_QTY_DR,     
       @Semantics.quantity.unitOfMeasure: 'dr_meins'     
       REQ_DRQTY_N,     
       @Semantics.quantity.unitOfMeasure: 'dr_meins'
/*       case when ZVD_DRQTY > 0 then REM_QTY_DR - ZVD_DRQTY
            else 
                 case when ZMM_DRQTY > 0 then REM_QTY_DR - ZMM_DRQTY 
                      else REM_QTY_DR - req_drqty_n end
            end as AVA_NQTY,*/
        case when ZMM_DRQTY > 0 then REM_QTY_DR - ( ZMM_DRQTY - loadqty ) 
                      else REM_QTY_DR - REQ_DRQTY_N end as AVA_NQTY, 
       DR_MEINS,
       @Semantics.quantity.unitOfMeasure: 'meins'  
       KEEP_QTY,     
       @Semantics.quantity.unitOfMeasure: 'dr_meins'     
       req_drqty_k,
       @Semantics.quantity.unitOfMeasure: 'dr_meins'            
       KEEP_QTY_DR,
       @Semantics.quantity.unitOfMeasure: 'dr_meins'    
       case when ZVD_DRQTY > 0 then KEEP_QTY_DR - ZVD_DRQTY
            else 
                 case when ZMM_DRQTY > 0 then KEEP_QTY_DR - ZMM_DRQTY 
                      else KEEP_QTY_DR - req_drqty_k end
            end as AVA_KQTY        
}
