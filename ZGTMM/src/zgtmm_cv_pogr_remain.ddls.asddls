@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO 별 입고 잔량 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_POGR_REMAIN 
as 
select from ekko as A inner join ekpo as B on A.ebeln = B.ebeln
                      inner join eket as e on B.ebeln = e.ebeln and B.ebelp = e.ebelp
             left outer join ZGTMM_CV_INDELIVERY_INFO as C on B.ebeln = C.ebeln and B.ebelp = C.ebelp
             left outer join ZGTMM_CV_POGR_INFO  as D on B.ebeln = D.ebeln and B.ebelp = D.ebelp
            
association [1..1] to lfa1 as LFA1 on $projection.lifnr = LFA1.lifnr     
{
    key B.ebeln,
    key B.ebelp,
    
    A.lifnr,
    lfa1.land1,
    B.matnr,
    B.txz01,      
    B.werks,
    B.retpo,
    @Semantics.quantity.unitOfMeasure: 'MEINS'  
    case when B.retpo = 'X' then B.menge * -1 
         else B.menge end as menge,
    B.meins,
    B.uebto,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    case when C.LFIMG is not null then C.LFIMG else cast(0 as menge_d) end as INBQTY,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    case when D.MENGE is not null then D.MENGE else cast(0 as menge_d) end as GRQTY,
    @Semantics.quantity.unitOfMeasure: 'MEINS'  
    case when D.MENGE is null and C.LFIMG is null then 
              case when B.retpo = 'X' then B.menge * -1 else  B.menge end 
         else 
            case when C.LFIMG is null then
                     case when B.retpo = 'X' then B.menge * -1 - D.MENGE else B.menge   - D.MENGE end 
                 else
                      case when D.MENGE is null then 
                              case when B.retpo = 'X' then B.menge * -1  - C.LFIMG else B.menge  - C.LFIMG end
                           else 
                                 case when C.LFIMG >= D.MENGE then  
                                         case when B.retpo = 'X' then B.menge * -1 - C.LFIMG else B.menge  - C.LFIMG end
                                      else  
                                         case when B.retpo = 'X' then B.menge * -1 - D.MENGE else B.menge - D.MENGE end 
                                      end
                           end           
                 end
             end as REQTY,
    @Semantics.quantity.unitOfMeasure: 'MEINS' 
    case when D.MENGE is null and C.LFIMG is null then cast(0 as ktmng) 
         else 
            case when C.LFIMG is null then
                      D.MENGE
                 else
                      case when D.MENGE is null then 
                                C.LFIMG
                           else 
                                 case when C.LFIMG >= D.MENGE then C.LFIMG
                                      else D.MENGE end  
                           
                           end                 
                 
                 end          
         end as MAXQTY,
    B.banfn,
    B.bnfpo,
    B.elikz,
    e.eindt     
} where e.etenr = '0001'



/*
select from ekko as A inner join ekpo as B on A.ebeln = B.ebeln
            left outer join ZGTMM_CV_POGR_COLLECT as C on B.ebeln = C.ebeln and B.ebelp = C.ebelp
//            left outer join ZGTMM_CV_INDELIVERY_INFO as C on B.EBELN = C.EBELN and B.EBELP = C.EBELP
//            left outer join ZGTMM_CV_POGR_INFO  as D on B.EBELN = D.EBELN and B.EBELP = D.EBELP
            
association [1..1] to lfa1 as LFA1 on $projection.lifnr = LFA1.lifnr     
{
    key B.ebeln,
    key B.ebelp,
    A.lifnr,
    lfa1.land1,
    B.matnr,
    B.txz01,      
    B.werks,
    @Semantics.quantity.unitOfMeasure: 'MEINS'  
    B.menge,
    B.meins,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    C.INBQTY,
    @Semantics.quantity.unitOfMeasure: 'MEINS'
    C.GRQTY,
    @Semantics.quantity.unitOfMeasure: 'MEINS'  
    case when C.GRQTY is null then B.menge
         else 
             case when C.INBQTY >= C.GRQTY then B.menge-C.INBQTY
                  else B.menge - C.GRQTY end 
         end as REQTY,
    @Semantics.quantity.unitOfMeasure: 'MEINS' 
    case when C.GRQTY is null then cast(0 as ktmng) 
         else 
             case when C.INBQTY >= C.GRQTY then C.INBQTY
                  else C.GRQTY end 
         end as MAXQTY         
         
}*/
