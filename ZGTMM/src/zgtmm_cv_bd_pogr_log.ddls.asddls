@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[BD] 구매오더 PO입고 수신 로그 - MM00063'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_BD_POGR_LOG as 
    select from zgtmmt9000 as a inner join zgtmmt6030 as b
                                        on a.zifno = b.zifno
                                       and a.zifkey = b.zifkey
                                       and a.system_id = b.system_id
                                left outer join makt as m
                                        on b.matnr = m.matnr
                                       and m.spras = $session.system_language
                                left outer join lfa1 as l
                                        on b.emlif = l.lifnr
{
    key a.zifno,
    key a.zifkey,
    key a.system_id,
        a.zstat,
        a.message,
        a.ifdat,
        a.iftim,
        a.ifnam,
        
        b.zgrcd,  //R:입고, C:취소
        b.ebeln,  //PO 번호
        b.ebelp,  //PO 항목
        b.smbln,  //취소대상 자재문서 번호
        b.sjahr,  //취소대상 자재문서 연월
        
        b.bldat,  //처리 증빙일
        b.budat,  //처리 전기일
        b.lfsnr,  //외부 납품번호
        b.bktxt,  //문서 헤더 텍스트
        
        b.zscmat, //구성품 자재 여부
        b.matnr,  //자재 번호
        m.maktx,  //자재 내역
        b.charg,  //배치 번호
        
        @Semantics.quantity.unitOfMeasure: 'meins'
        b.lfimg,  //수량
        b.meins,  //단위
        
        b.werks,  //플랜트
        b.lgort,  //저장위치
        b.emlif,  //공급대상 납품/수령 공급업체
        l.name1,  //납품/수령 공급업체 이름
        b.ablad,  //하적지점
        
        b.mblnr1,  //입고 자재문서 번호
        b.mjahr1,  //입고 자재문서 연월
        b.mblnr2,  //직납 후속 자재문서 번호
        b.mjahr2   //직납 후속 자재문서 연월
        
} where a.zifno = 'MM00063'
