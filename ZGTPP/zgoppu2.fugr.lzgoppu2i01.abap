*----------------------------------------------------------------------*
***INCLUDE LZGOPPU2I01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE GV_OK_CODE.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.

*     종료
      CALL METHOD G_DOCKING_0100->FREE.

      FREE : G_DOCKING_0100.
      FREE : HTML_CONTROL.

      CALL METHOD CL_GUI_CFW=>FLUSH.

      SET SCREEN 0.       " 현재 팝업 스크린의 다음 화면을 없앱니다.
      LEAVE SCREEN.       " 현재 화면 처리를 즉시 중단하고 팝업을 닫습니다.

  ENDCASE.

ENDMODULE.
