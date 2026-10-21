*&---------------------------------------------------------------------*
*& PROGRAM ID  : ZGTMMR4510
*& TITLE       : [MM]가온전선_통문증 리스트 및 발행취소
*& CREATE DATE : 2026.04. 27
*& AUTHOR      : ZGODEV04
*& FREQUENCY   : FREQUENCY
*& GAP NO      :
*& DESCRIPTION :가온전선_기존 LS 통문증 리스트 및 발행취소(ZLER0016)프로그램
*                       복사 후 단순화 및 스마트폼 변경
*&---------------------------------------------------------------------*
*  CHANGED BY  |  DESCRIPTION OF CHANGE   |  DATE     *
*  <NAME>      |                                           |<MM-DD-YY> *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*                        MODIFICATION LOG                              *
*----------------------------------------------------------------------*
*   DATE        AUTHORS              DESCRIPTION                       *
* ----------   --------- --------------------------------------------- *
* 2007/08/10    SONG     통문 조회조건에서 MRP 관리자 조회 조건을      *
*                        추가한다.                                     *
*                        [요청번호] C20070810_14860                    *
* 2007/10/22    SONGK    [제목] 기계 통문증 인쇄 개선요청              *
*                        [요청번호] C20071015_50616                    *
* 2008/02/15    BCKOO    [제목] 사업장5100, 이동유형B11경우 TEXT변경   *
*                        [요청번호] C20080130_09401                    *
* 2008/03/13    BCKOO    [제목] 데이터클린작업으로 인해 무상사급데이터 *
*                        의 경우 삭제됨 그리므로 2006년이후분만 조회   *
*                        [요청번호] C20080221_20568                    *
* 2008/05/02    SONGK    [제목] 데이터클린작업 전체 조회 시에도        *
*                        06년 이전 무상사급데이터 조회 금지            *
*                        [요청번호] C20080430_59983                    *
* 2008/06/13    BCKOO    [제목] LS엠트론 CI 추가                       *
*                        [요청번호] 법인분리                           *
* 2012/12/11    J.Y.LEE  [제목] 트랙터 완제품 외부창고 이전 통문증에   *
*                               배치번호 추가                          *
*                        [요청번호] C20121116_19475                    *
* 2013/02/21    J.Y.LEE  [제목] 통문증 비고란 데이터 표시 로직 수정    *
*                        [요청번호] C20130220_76107                    *
* 2013/10/25    J.Y.LEE  [제목] 통문증 조회시 필드 값 내용 추가        *
*                        [요청번호] C20131010_16602                    *
* 2014/08/28    H.M.LIM  [제목] 통문증 발행일자,출력일자 구분표시      *
*                        [요청번호] 기능개선 41489                     *
* 2014/09/19    H.M.LIM  [제목] 통문증 발행시 회사명 오류 수정         *
*                        [요청번호] 기능개선 45041
* 2014/11/06    S.J.NAM  [자체개선 52264] 회사코드 리스트 박스로 수정
* 2014/11/12    H.M.LIM  [제목] 통문발행일자 시간 정보 화면 추가       *
*                        [요청번호] 기능개선 101979                    *
* 2014/11/06    H.M.LIM  [기능개선110094]커넥터통문증 자재별합계 추가  *
*-----------------------------------------------------------------------
*  DATE.     AUTHOR.  CSR #.           DESCRIPTION
*-----------------------------------------------------------------------
* 2014.08.04 J.Y.LEE  자체개선 38665   매각/폐기 통문증 양식 변경
* 2019.03.22 노승남   기능개선 273305  통문유형에 따른 데이터 선택 변경
* 2019.03.27 노승남   기능개선 273711  사업장별 사용가능 통문유형 보완
* 2019.05.29 MJD      기능개선 281134  PP선택후 조회 오류 수정
* 2020.08.20 ZLSGSD   CHM2008-00227    통문증 사번 추가
* 2024.01.30 ZLSGDV1  SRM2401-14519    사내이체 통문증 발행 오류 수정
************************************************************************

REPORT  ZGTMMR4510 MESSAGE-ID ZGTMM01..

INCLUDE ZGTMMR4510TOP.
INCLUDE ZGTMMR4510C01.
INCLUDE ZGTMMR4510F01.

*&---------------------------------------------------------------------*
*&   EVENT AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_GUBUN1 .
  PERFORM VALUE_REQUEST USING 'GUBUN1' .

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_BUKRS .
  PERFORM VALUE_REQUEST_BUKRS.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR I_WERKS-LOW .
*  PERFORM VALUE_REQUEST_WERKS USING '1' .
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR I_WERKS-HIGH .
*  PERFORM VALUE_REQUEST_WERKS USING '2' .
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR I_BRANCH-LOW .
*  PERFORM VALUE_REQUEST_BRANCH USING '1' .
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR I_BRANCH-HIGH .
*  PERFORM VALUE_REQUEST_BRANCH USING '2' .

*&---------------------------------------------------------------------*
*&   EVENT INITIALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
  T1 = '통문문서 조회대상 구분'.
  T2 = '선택조건'.
  T3 = '발행조건'.

  I_DATE-SIGN   = 'I'.
  I_DATE-OPTION = 'BT'.
  I_DATE-LOW    = SY-DATUM.                                "- 30.
  I_DATE-HIGH   = SY-DATUM.
  APPEND I_DATE.

AT SELECTION-SCREEN.
  PERFORM CHECK_BUKRS.
  PERFORM CHECK_INPUT(ZLER0012) USING P_BZAREA.
** 권한CHECK
  PERFORM AUTHORITY_CHECK.

*&---------------------------------------------------------------------*
*&   EVENT AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
* RADIO BUTTON CLICK시 필드 활성/비활성
*  P_GUBUN1 = '2'.
*  IF R3 <> 'X'.
    IF R1 = 'X' AND GV_FLAG1 = ' '.
*      P_GUBUN1 = '2'.
      GV_FLAG1 = 'X'.
      CLEAR: GV_FLAG2, GV_FLAG3.
    ENDIF.
    IF R2 = 'X' AND GV_FLAG2 = ' '.
*      P_GUBUN1 = '2'.
      GV_FLAG2 = 'X'.
      CLEAR: GV_FLAG1, GV_FLAG3.
    ENDIF.
*  IF R3 = 'X' AND GV_FLAG3 = ' '.
*    P_GUBUN1 = '2'.
*    GV_FLAG3 = 'X'.
*    CLEAR: GV_FLAG1, GV_FLAG2.
*  ENDIF.
*  ENDIF.

  PERFORM SCREEN_FIELD_CHANG.

*&---------------------------------------------------------------------*
*&   EVENT START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  IF P_BUKRS IS INITIAL.
    MESSAGE S000(ZLE1) DISPLAY LIKE 'E' WITH '회사코드를 입력하십시오'.
    RETURN.
  ENDIF.
*  IF P_BZAREA IS INITIAL.
*    MESSAGE S000(ZLE1) DISPLAY LIKE 'E' WITH '사업장을 입력하십시오'.
*    RETURN.
*  ENDIF.
*  IF P_GUBUN1 IS INITIAL.
*    MESSAGE S000(ZLE1) DISPLAY LIKE 'E' WITH '통문유형을 입력하십시오'.
*    RETURN.
*  ENDIF.

  IF R1 = 'X'.
*   MM 일반 이동유형
    PERFORM DATA_GET.
  ELSEIF R2 = 'X'.
*   매각/폐기
    PERFORM MA_DATA_GET.
*  ELSE.
**   PP
*    PERFORM PP_DATA_GET.
  ENDIF.
*  SORT GT_OUT BY IV_TYPE IV_NO.

*/ 2005.07.13 BY SDC08
  LOOP AT GT_OUT.
    CASE GT_OUT-IV_TYPE .
     WHEN 'B04' OR 'B17' OR 'B21' OR 'B22'.  "플랜트간 이동
      PERFORM COSTOMER_INFO USING ' ' ' ' 'X'.
     WHEN 'D02'.  "매각
      PERFORM COSTOMER_INFO USING ' ' 'X' ' '.
     WHEN OTHERS.
      PERFORM COSTOMER_INFO USING 'X' ' ' ' '.
    ENDCASE.

*___자재문서 취소여부
    SELECT SINGLE CANCELLED
      INTO GT_OUT-CANCELLED
      FROM MATDOC
     WHERE MBLNR = GT_OUT-MBLNR
       AND MJAHR = GT_OUT-MJAHR
       AND ZEILE = GT_OUT-ZEILE.

    MODIFY GT_OUT TRANSPORTING LIFNR KUNNR UMWRK.
  ENDLOOP.

  CALL SCREEN 100.

*&---------------------------------------------------------------------*
*&      MODULE  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '100'.
  SET TITLEBAR '100'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      MODULE  CREATE_INSTANCE_CONTROLS  OUTPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE CREATE_INSTANCE_CONTROLS OUTPUT.

  PERFORM CREATE_AND_INIT_CONTROLS.

ENDMODULE.                 " CREATE_INSTANCE_CONTROLS  OUTPUT
*&---------------------------------------------------------------------*
*&      MODULE  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND INPUT.

  CASE SY-UCOMM.
    WHEN 'BACK' OR '%EX' OR 'RW'.
      LEAVE TO SCREEN 0.
  ENDCASE.
*  CLEAR SY-UCOMM.

ENDMODULE.                 " EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*&      MODULE  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       TEXT
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE SY-UCOMM.
*   통문증 CANCEL
    WHEN 'CANC'.
      PERFORM TONGMOON_CANCEL.
*   통문증 재발행
    WHEN 'PRIN'.
      PERFORM TONGMOON_REPRINT.
*   REFRESH
    WHEN 'REFR'.
      IF R1 = 'X' .
*        OR R4 = 'X'.
*   MM 일반 이동유형
        PERFORM DATA_GET.
      ELSEIF R2 = 'X'.
*   매각/폐기
        PERFORM MA_DATA_GET.
*      ELSE.
**   PP
*        PERFORM PP_DATA_GET.
      ENDIF.
*  SORT GT_OUT BY IV_TYPE IV_NO.

*/ 2005.07.13 BY SDC08
      LOOP AT GT_OUT.
        CASE GT_OUT-IV_TYPE .
         WHEN 'B04' OR 'B17' OR 'B21' OR 'B22'.  "플랜트간 이동
          PERFORM COSTOMER_INFO USING ' ' ' ' 'X'.
         WHEN 'D02'.  "매각
          PERFORM COSTOMER_INFO USING ' ' 'X' ' '.
         WHEN OTHERS.
          PERFORM COSTOMER_INFO USING 'X' ' ' ' '.
        ENDCASE.

*___자재문서 취소여부
        SELECT SINGLE CANCELLED
          INTO GT_OUT-CANCELLED
          FROM MATDOC
         WHERE MBLNR = GT_OUT-MBLNR
           AND MJAHR = GT_OUT-MJAHR
           AND ZEILE = GT_OUT-ZEILE.

        MODIFY GT_OUT TRANSPORTING LIFNR KUNNR UMWRK.
      ENDLOOP.
*   CHECK OPTION
    WHEN 'DSEL'.
      PERFORM CHK_DESELECT.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
