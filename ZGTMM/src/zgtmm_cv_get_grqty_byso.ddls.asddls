@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '판매오더 기준 입고 수량 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_GET_GRQTY_BYSO 
as select from matdoc as A inner join ekpo as B on A.ebeln = B.ebeln and A.ebelp = B.ebelp
                        inner join ekko as C on B.ebeln = C.ebeln
                        inner join ekbe as E on A.ebeln = E.ebeln and A.ebelp = E.ebelp and A.mjahr = E.gjahr
                                           and  A.mblnr = E.belnr and A.zeile = E.buzei
                        inner join ekkn as F on B.ebeln = F.ebeln and B.ebelp = F.ebelp                   
{
  key F.vbeln,
  key F.vbelp as POSNR,
      left(A.budat,6) as spmon,
      @Semantics.quantity.unitOfMeasure: 'ERFME'
      A.erfmg,
      A.erfme,
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      case when A.lgort is not null then
         case when A.lgort = '3410' then 
                 case when A.erfmg is not null then A.erfmg else cast(0 as abap.quan(13,3)) end      
              else cast(0 as abap.quan(13,3))      
              end
       else cast(0 as abap.quan(13,3))       
       end as WH3410,
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      case when A.lgort is not null then
         case when A.lgort = '3420' then 
                 case when A.erfmg is not null then A.erfmg else cast(0 as abap.quan(13,3)) end    
              else cast(0 as abap.quan(13,3))                        
              end
       else cast(0 as abap.quan(13,3))                  
       end as WH3420,       
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      case when A.lgort is not null then
           case when A.lgort = '3498' then 
                  case when A.erfmg is not null then A.erfmg else cast(0 as abap.quan(13,3)) end        
                  else cast(0 as abap.quan(13,3))                    
                  end
           else cast(0 as abap.quan(13,3))                  
           end as WH3498,       
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      case when A.lgort is not null then
           case when A.lgort = '3497' then 
                    case when A.erfmg is not null then A.erfmg else cast(0 as abap.quan(13,3)) end     
                    else cast(0 as abap.quan(13,3))                       
                    end
           else cast(0 as abap.quan(13,3))                 
           end as WH3497,       
      @Semantics.quantity.unitOfMeasure: 'ERFME' 
      case when A.lgort is not null then
            case when A.lgort <> '3497' and A.lgort <> '3498' and A.lgort <> '3410' and A.lgort <> '3420' then 
                      case when A.erfmg is not null then A.erfmg else cast(0 as abap.quan(13,3)) end        
                      else cast(0 as abap.quan(13,3))                    
                      end
            else cast(0 as abap.quan(13,3))                  
            end as WHETC 
} where A.lifnr <> '' and A.xauto = '' and A.sobkz <> 'K' and F.zekkn ='01'
  and C.bsart <> 'MB' and A.bwart <> '543' and A.bwart <> '544' and E.vgabe = '1' and A.cancelled = '' and A.reversal_movement = ''

