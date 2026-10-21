*&---------------------------------------------------------------------*
*&  Include           ZLER0019F01                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  value_request
*&---------------------------------------------------------------------*
FORM value_request  USING    p_xx.

* 통문유형 listbox
*  TYPE-POOLS vrm.
*  DATA: lt_values  TYPE vrm_values WITH HEADER LINE.
  DATA: lv_vrmid   TYPE vrm_id     .
  DATA: p_seq(2) TYPE c.
  DATA: p_seq1(2) TYPE N.
  DATA: p_type(30) TYPE c.
  DATA: lv_where(11) TYPE c.

  DATA: LT_0007      LIKE ZGTMMT4511 OCCURS 0 WITH HEADER LINE.
  DATA: LV_TYPE(30)  TYPE C.

  REFRESH: lt_values.
  CLEAR  : lt_values, lv_vrmid.

  CASE p_xx.
    WHEN 'GUBUN1'.

      lv_vrmid = 'P_GUBUN1'.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE LT_0007
        FROM   ZGTMMT4511
       WHERE bukrs = p_bukrs and  gubun = 'MA'.

        LOOP AT LT_0007.
        CONCATENATE LT_0007-IV_TYPE ':' LT_0007-IV_TYPE_NM
               INTO LV_TYPE.

        PERFORM GET_VRM_ID_VALUES TABLES LT_VALUES
                                  USING  LT_0007-IV_TYPE
                                         LV_TYPE.
      ENDLOOP.

  ENDCASE.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = lv_vrmid
      values          = lt_values[]
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " value_request
*&---------------------------------------------------------------------*
*&      Form  get_vrm_id_values
*&---------------------------------------------------------------------*
FORM get_vrm_id_values  TABLES   t_values TYPE vrm_values
                        USING    p_key
                                 p_text.

  t_values-key    = p_key.
  t_values-text   = p_text.
  APPEND t_values.

ENDFORM.                    " get_vrm_id_values
*&---------------------------------------------------------------------*
*&      Form  check_bukrs
*&---------------------------------------------------------------------*
FORM check_bukrs.

  CHECK p_bukrs IS NOT INITIAL.

  SELECT SINGLE mandt
    FROM t001
    INTO sy-mandt
    WHERE bukrs = p_bukrs.
  IF sy-subrc <> 0.
    MESSAGE e000(zle1) WITH '존재하지 않는 회사코드입니다'.
  ENDIF.

ENDFORM.                    " check_bukrs
*&---------------------------------------------------------------------*
*& FORM CHECK_AUTH
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
FORM CHECK_AUTH .

  AUTHORITY-CHECK OBJECT 'ZCBO_MM001'
               ID 'BUKRS' FIELD P_BUKRS.

  CHECK SY-SUBRC <> 0.

  SET CURSOR FIELD 'P_BUKRS'.
  MESSAGE E172(ZGTMM01) WITH P_BUKRS. "회사코드[&] 작업권한을 확인하세요.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  value_request_bukrs
*&---------------------------------------------------------------------*
FORM value_request_bukrs.
*-{ 자체개선 52275 - 변경
  DATA: lv_vrmid   TYPE vrm_id     .

  CLEAR   : LT_VALUES, LV_VRMID.
  REFRESH : LT_VALUES.

  SELECT BUKRS AS KEY
         BUTXT AS TEXT
    FROM T001
    INTO TABLE LT_VALUES
   WHERE KTOPL =  '1000'.

  LV_VRMID = 'P_BUKRS'.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID              = LV_VRMID
      VALUES          = LT_VALUES[]
    EXCEPTIONS
      ID_ILLEGAL_NAME = 1
      OTHERS          = 2.


ENDFORM.                    " value_request_bukrs
