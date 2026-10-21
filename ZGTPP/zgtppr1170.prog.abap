*&---------------------------------------------------------------------*
*& 모듈풀            ZGTPPR1170                                        *
*&---------------------------------------------------------------------*
*&  GAP ID        : PPA24                                              *
*&  모듈/서브모듈 : PP/전선                                            *
*&  Type          :                                                    *
*&  T_Code        : SAPMZPP0050                                        *
*&  Creator       : 이 수 희                                           *
*&  Description   : BOM L/C DATA 수정                                  *
*&---------------------------------------------------------------------*
*                        MODIFICATION LOG
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION
* ----------   --------- ----------------------------------------------*
* 2005/00/00    PPC24     Initial Release
* 2006/01/16    방태영    제선(1305)의 DWH,DWF일때 BOM의 출고저장위치
*                         "2240"으로 통일
* 2007/07/05   이정익     CSR : C20070704_91902
*                         생산/원가 스크랩율 분리하여 적용되도록 보완
* 2007/09/11   이정익     [요청번호] C20070906_31315
*                         [제목]BOM L/C 스크랩율 관리 프로그램 개선의 건
*                          - 1401/OC 광케이블의 경우 길이계산방식이 있고
*                            S/U 배치이더라도 스크랩율 적용
* 2008/12/24   이정익     [요청번호]C20081223_76506
*                         [제목]삭제 자재 제외
* 2010/08/10   이정익     [요청번호]C20100810_17193
*                         [제목]1801 산특일 경우 BOM L/C수정시
*                         생산버전반영
* 2014/02/03   이정익     [요청번호]기능개선 11724
*                         [제목]투입자재의 저장위치 확장 기능 추가
* 2014/04/25   이정익     풍세전선 반영
* 2020/09/04   조영현     기능개선_SRM2009-01121 ALV 화면사이즈 수정
* 2026/05/12   ZGODEV06   SAPMZPP0050 복사 생성.
************************************************************************
REPORT  zgtppr1170  MESSAGE-ID zpp1.

INCLUDE zgtppr1170top.
INCLUDE zgtppr1170s01.
INCLUDE zgtppr1170cls.
INCLUDE zpplbdcpara.
INCLUDE zpplcommon.
INCLUDE zgtppr1170o01.
INCLUDE zgtppr1170i01.
INCLUDE zgtppr1170f01.
INCLUDE zgtppr1170bdc.

INITIALIZATION.
  CLEAR: gt_data[],  gt_temp[].

START-OF-SELECTION.
  AUTHORITY-CHECK OBJECT 'ZPP_DISPO'
                      ID 'WERKS'  FIELD gp_werks
                      ID 'DISPO'  FIELD gp_dispo.

  IF sy-subrc <> 0.
    MESSAGE s003 WITH 'MRP관리자[' gp_dispo
                      ']의 작업권한을 확인하세요.'.
    LEAVE LIST-PROCESSING.
  ENDIF.

*// Modified by ZGODEV06 on 2026-05-12 {
  IF contains( val = gp_procd regex = '[*]' ).
    MESSAGE s001 WITH TEXT-e01.
    LEAVE LIST-PROCESSING.
  ENDIF.
*// }

  PERFORM prepare_data_for_process.
