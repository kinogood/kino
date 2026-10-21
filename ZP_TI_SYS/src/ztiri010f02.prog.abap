************************************************************************
* Title         :  ZTIRI010F02                                         *
*                                                                      *
* Description   : TEXT ID 공용루틴 Include                             *
*                                                                      *
* Creation Date : 2003/10/10                                           *
*                                                                      *
* Author        : SeogBong, Kang                                       *
*                                                                      *
************************************************************************
*----------------------------------------------------------------------*
***INCLUDE DFKB1F10 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  VIEW_MARK_WRITE_BEGIN
*&---------------------------------------------------------------------*
*       Tabellen?derungsprotokoll
*----------------------------------------------------------------------*
FORM VIEW_MARK_WRITE_BEGIN  USING  OBJECT  LIKE OBJS-OBJECTNAME.

  CALL FUNCTION 'VIEW_MARK_WRITE'
       EXPORTING
            OBJNAME = OBJECT
            BEGIN   = 'X'
            OBJTYPE = 'L'.

ENDFORM.                    " VIEW_MARK_WRITE_BEGIN

*&---------------------------------------------------------------------*
*&      Form  VIEW_MARK_WRITE_END
*&---------------------------------------------------------------------*
*       Tabellen?derungsprotokoll
*----------------------------------------------------------------------*
FORM VIEW_MARK_WRITE_END  USING  OBJECT  LIKE OBJS-OBJECTNAME.

  CALL FUNCTION 'VIEW_MARK_WRITE'
       EXPORTING
            OBJNAME = OBJECT
            BEGIN   = SPACE
            OBJTYPE = 'L'.

ENDFORM.                    " VIEW_MARK_WRITE_END
