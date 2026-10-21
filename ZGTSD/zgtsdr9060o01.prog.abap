*&---------------------------------------------------------------------*
*& Include          ZGTSDR9060O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*& Screen 0100 Status 정보 구성
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  DATA : lv_stat  TYPE string,
         lt_fcode TYPE TABLE OF syucomm.

  CLEAR : lt_fcode,
          lv_stat.

*-- Radio Buttion 기준 Status 정보 구성
  CASE abap_true.
    WHEN p_crte.            " 생성
      IF p_mapp EQ abap_true.
        lv_stat = '0100'.
      ELSE.
        lv_stat = '0101'.
      ENDIF.

    WHEN p_search.          " 조회
      lv_stat = '0100'.

      lt_fcode = VALUE #(
                          ( 'SAVE' )
                          ( 'DEL' )
                        ).
    WHEN p_del.             " 삭제
      lv_stat = '0103'.

      CASE abap_true.
        WHEN p_del_m.       " Mapping 삭제
          lt_fcode = VALUE #(
                              ( 'ORD_DEL' )
                              ( 'ORD_REJ' )
                              ( 'CRTE'    )
                            ).
        WHEN p_del_t.       " To-Be 삭제
          lt_fcode = VALUE #(
                              ( 'ORD_DEL' )
                              ( 'ORD_REJ' )
                            ).
        WHEN p_del_o.       " To-Be 판매오더 삭제
          lt_fcode = VALUE #(
                              ( 'DEL_DB' )
                              ( 'ORD_REJ' )
                              ( 'CRTE'    )
                            ).
      ENDCASE.

    WHEN p_rej.             " As-Is 판매오더 거부사유 처리
      lv_stat = '0103'.

      lt_fcode = VALUE #(
                          ( 'DEL_DB' )
                          ( 'ORD_DEL' )
                        ).

  ENDCASE.

  SET PF-STATUS lv_stat EXCLUDING lt_fcode.
  SET TITLEBAR  '0100'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_CLASS_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&  Screen 0100 Class Doc. 정보 구성
*&---------------------------------------------------------------------*
MODULE init_class_alv_0100 OUTPUT.

  PERFORM init_class_alv_info_0100.

ENDMODULE.
