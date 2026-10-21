CLASS zgtsd_linkhub DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      t_scope TYPE STANDARD TABLE OF string .
    TYPES:
      BEGIN OF s_linkhub_token,
        session_token TYPE string,
        serviceid     TYPE string,
        linkid        TYPE string,
        usercode      TYPE string,
        ipaddress     TYPE string,
        expiration    TYPE timestamp,
        scope         TYPE TABLE OF string WITH DEFAULT KEY,
      END OF s_linkhub_token .
    TYPES:
      BEGIN OF s_linkhub_result,
        code    TYPE int4,
        message TYPE string,
      END OF s_linkhub_result .

    CLASS-METHODS generate_token
      IMPORTING
        !p_serviceid   TYPE string
        !p_linkid      TYPE string
        !p_secretkey   TYPE string
        !p_accessid    TYPE string
        !p_scope       TYPE t_scope
        !p_forwardedip TYPE string OPTIONAL
      RETURNING
        VALUE(p_token) TYPE s_linkhub_token
      RAISING
        zgtsd_cx_linkhub .
    CLASS-METHODS balance
      IMPORTING
        !p_token         TYPE s_linkhub_token
      EXPORTING
        VALUE(p_balance) TYPE p
      RAISING
        zgtsd_cx_linkhub .
    CLASS-METHODS partnerbalance
      IMPORTING
        !p_token         TYPE s_linkhub_token
      EXPORTING
        VALUE(p_balance) TYPE p
      RAISING
        zgtsd_cx_linkhub .
    CLASS-METHODS gettime
      RETURNING
        VALUE(p_utctime) TYPE string
      RAISING
        zgtsd_cx_linkhub .
    CLASS-METHODS gettimestamp
      RETURNING
        VALUE(p_utctimestamp) TYPE timestamp
      RAISING
        zgtsd_cx_linkhub .
    CLASS-METHODS deserialize
      IMPORTING
        VALUE(p_json) TYPE string
      CHANGING
        VALUE(p_data) TYPE any .
    CLASS-METHODS serialize
      IMPORTING
        !p_obj        TYPE any
      RETURNING
        VALUE(p_json) TYPE string .
protected section.
private section.

  constants LV_AUTHURL type STRING value 'https://static-auth.linkhub.co.kr' ##NO_TEXT.
  constants LV_AUTHDEST type RFCDEST value 'linkhub' ##NO_TEXT.
ENDCLASS.



CLASS ZGTSD_LINKHUB IMPLEMENTATION.


METHOD BALANCE.
  DATA:
    HTTP_CLIENT      TYPE REF TO IF_HTTP_CLIENT,
    LV_URL           TYPE STRING,
    LV_AUTHHEADER    TYPE STRING,
    LV_RESPONSE      TYPE STRING,
    LV_RESULT        TYPE S_LINKHUB_RESULT,
    HTTP_STATUS_CODE TYPE I.

  CONCATENATE '/' P_TOKEN-SERVICEID '/Point' INTO LV_URL.

** Create with Destination
  CALL METHOD CL_HTTP_CLIENT=>CREATE_BY_DESTINATION
    EXPORTING
      DESTINATION              = LV_AUTHDEST
    IMPORTING
      CLIENT                   = HTTP_CLIENT
    EXCEPTIONS
      ARGUMENT_NOT_FOUND       = 1
      DESTINATION_NOT_FOUND    = 2
      DESTINATION_NO_AUTHORITY = 3
      PLUGIN_NOT_ACTIVE        = 4
      INTERNAL_ERROR           = 5
      OTHERS                   = 6.
**
*    CALL METHOD cl_http_client=>create_by_url
*      EXPORTING
*        url                = lv_authurl
*        ssl_id             = 'ANONYM'
*      IMPORTING
*        client             = http_client
*      EXCEPTIONS
*        argument_not_found = 1
*        internal_error     = 2
*        plugin_not_active  = 3
*        others             = 4.
**

  HTTP_CLIENT->PROPERTYTYPE_LOGON_POPUP = HTTP_CLIENT->CO_DISABLED.

  CALL METHOD HTTP_CLIENT->REQUEST->SET_HEADER_FIELD
    EXPORTING
      NAME  = '~request_uri'
      VALUE = LV_URL.

  CONCATENATE 'Bearer' P_TOKEN-SESSION_TOKEN INTO LV_AUTHHEADER SEPARATED BY SPACE.

  CALL METHOD HTTP_CLIENT->REQUEST->SET_HEADER_FIELD
    EXPORTING
      NAME  = 'Authorization'
      VALUE = LV_AUTHHEADER.

  CALL METHOD HTTP_CLIENT->SEND
    EXCEPTIONS
      HTTP_COMMUNICATION_FAILURE = 1
      HTTP_INVALID_STATE         = 2.

  CALL METHOD HTTP_CLIENT->RECEIVE
    EXCEPTIONS
      HTTP_COMMUNICATION_FAILURE = 1
      HTTP_INVALID_STATE         = 2
      HTTP_PROCESSING_FAILED     = 3.

  CALL METHOD HTTP_CLIENT->RESPONSE->GET_STATUS
    IMPORTING
      CODE = HTTP_STATUS_CODE.

  IF HTTP_STATUS_CODE = 200.
    TYPES :
      BEGIN OF POINTRESPONSE,
        REMAINPOINT TYPE P LENGTH 16 DECIMALS 2,
      END OF POINTRESPONSE.
    DATA LV_REMAINPOINT TYPE POINTRESPONSE.

    LV_RESPONSE = HTTP_CLIENT->RESPONSE->GET_CDATA( ).

    CALL METHOD ZGTSD_LINKHUB=>DESERIALIZE
      EXPORTING
        P_JSON = LV_RESPONSE
      CHANGING
        P_DATA = LV_REMAINPOINT.
    P_BALANCE = LV_REMAINPOINT-REMAINPOINT.

  ELSE.
    LV_RESPONSE = HTTP_CLIENT->RESPONSE->GET_CDATA( ).
    CALL METHOD ZGTSD_LINKHUB=>DESERIALIZE
      EXPORTING
        P_JSON = LV_RESPONSE
      CHANGING
        P_DATA = LV_RESULT.

    RAISE RESUMABLE EXCEPTION TYPE ZGTSD_CX_LINKHUB
      EXPORTING
        CODE    = LV_RESULT-CODE
        MESSAGE = LV_RESULT-MESSAGE.

  ENDIF.

  CALL METHOD HTTP_CLIENT->CLOSE
    EXCEPTIONS
      HTTP_INVALID_STATE = 1
      OTHERS             = 2.

ENDMETHOD.


method DESERIALIZE.

    CALL METHOD cl_json=>deserialize
      EXPORTING
        json = p_json
      CHANGING
        data = p_data.

  endmethod.


METHOD generate_token.

  DATA: http_client      TYPE REF TO if_http_client,
        lv_sign_string   TYPE string,
        lv_sign_key_x    TYPE xstring,
        lv_hmac_result   TYPE string,
        authorization    TYPE string,
        lv_url           TYPE string,
        lv_timeout       TYPE i,
        lv_str           TYPE string,
        postdata         TYPE string,
        postdataxstring  TYPE xstring,
        calldt           TYPE string,
        lv_hashb64string TYPE string,
        lv_signature     TYPE string,
        lv_length        TYPE i,
        http_status_code TYPE i,
        status_text      TYPE string.

**
** Create with Destination
  CALL METHOD cl_http_client=>create_by_destination
    EXPORTING
      destination              = lv_authdest
    IMPORTING
      client                   = http_client
    EXCEPTIONS
      argument_not_found       = 1
      destination_not_found    = 2
      destination_no_authority = 3
      plugin_not_active        = 4
      internal_error           = 5
      OTHERS                   = 6.
**
*  CALL METHOD cl_http_client=>create_by_url
*    EXPORTING
*      url                = lv_authurl
*      ssl_id             = 'ANONYM'
*    IMPORTING
*      client             = http_client
*    EXCEPTIONS
*      argument_not_found = 1
*      internal_error     = 2
*      plugin_not_active  = 3
*      OTHERS             = 6.
**

  http_client->propertytype_logon_popup = http_client->co_disabled.

  calldt = zgtsd_linkhub=>gettime( ).

  TYPES : BEGIN OF t_post,
            access_id TYPE string,
            scope     TYPE TABLE OF string WITH DEFAULT KEY,
          END OF t_post.

  DATA: lv_postdata TYPE t_post.

  lv_postdata-access_id = p_accessid.
  lv_postdata-scope = p_scope.

  postdata =  zgtsd_linkhub=>serialize( p_obj = lv_postdata ).

  CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
    EXPORTING
      text   = postdata
    IMPORTING
      buffer = postdataxstring
    EXCEPTIONS
      failed = 1
      OTHERS = 2.

  lv_length = xstrlen( postdataxstring ).

  CALL FUNCTION 'CALCULATE_HASH_FOR_RAW'
    EXPORTING
      alg            = 'MD5'
      data           = postdataxstring
      length         = lv_length
    IMPORTING
      hashb64string  = lv_hashb64string
    EXCEPTIONS
      unknown_alg    = 1
      param_error    = 2
      internal_error = 3
      OTHERS         = 4.

  CONCATENATE '/'  p_serviceid  '/Token' INTO lv_url.

  CONCATENATE 'POST'           cl_abap_char_utilities=>newline
              lv_hashb64string cl_abap_char_utilities=>newline
              calldt           cl_abap_char_utilities=>newline
         "     '*'            cl_abap_char_utilities=>newline
              '1.0'            cl_abap_char_utilities=>newline
               lv_url
         INTO lv_sign_string.
*
  CALL FUNCTION 'SSFC_BASE64_DECODE'
    EXPORTING
      b64data                  = p_secretkey
    IMPORTING
      bindata                  = lv_sign_key_x
    EXCEPTIONS
      ssf_krn_error            = 1
      ssf_krn_noop             = 2
      ssf_krn_nomemory         = 3
      ssf_krn_opinv            = 4
      ssf_krn_input_data_error = 5
      ssf_krn_invalid_par      = 6
      ssf_krn_invalid_parlen   = 7
      OTHERS                   = 8.

  TRY.
      cl_abap_hmac=>calculate_hmac_for_char(
        EXPORTING
          if_algorithm     = 'SHA1'
          if_key           = lv_sign_key_x
          if_data          = lv_sign_string
        IMPORTING
          ef_hmacb64string = lv_hmac_result ).

    CATCH cx_abap_message_digest.
      CLEAR lv_signature.
  ENDTRY.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = '~request_uri'
      value = lv_url.


  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = '~request_method'
      value = 'POST'.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = 'x-lh-date'
      value = calldt.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = 'x-lh-version'
      value = '1.0'.

  " CALL METHOD http_client->request->set_header_field
  "  EXPORTING
  "    name  = 'x-lh-forwarded'
  "    value = '*'.

  CONCATENATE 'LINKHUB' p_linkid lv_hmac_result INTO authorization
                                                 SEPARATED BY space.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = 'Authorization'
      value = authorization.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = 'Content-Type'
      value = 'Application/json'.

  CALL METHOD http_client->request->set_data( data = postdataxstring ).

  CALL METHOD http_client->send
    EXPORTING
      timeout                    = lv_timeout
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      OTHERS                     = 4.

  CALL METHOD http_client->receive
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      OTHERS                     = 4.

  CALL METHOD http_client->response->get_status
    IMPORTING
      code   = http_status_code
      reason = status_text.

  IF http_status_code <> 200.
    lv_str = http_client->response->get_cdata( ).
    DATA : lv_result TYPE s_linkhub_result.
    CALL METHOD zgtsd_linkhub=>deserialize
      EXPORTING
        p_json = lv_str
      CHANGING
        p_data = lv_result.

    RAISE RESUMABLE EXCEPTION TYPE zgtsd_cx_linkhub
      EXPORTING
        code    = lv_result-code
        message = lv_result-message.
  ENDIF.

  lv_str = http_client->response->get_cdata( ).

  CALL METHOD zgtsd_linkhub=>deserialize
    EXPORTING
      p_json = lv_str
    CHANGING
      p_data = p_token.

  CALL METHOD http_client->close
    EXCEPTIONS
      http_invalid_state = 1
      OTHERS             = 2.

ENDMETHOD.


METHOD gettime.

  DATA: http_client      TYPE REF TO if_http_client,
        my_message       TYPE string,
        http_status_code TYPE i,
        lv_dest          TYPE rfcdisplay-rfcdest.

**

*  CLEAR: lv_dest.
*  lv_dest = zgtsd_popbill=>getservicedest( ).

** Create with Destination
  CALL METHOD cl_http_client=>create_by_destination
    EXPORTING
*     destination              = 'popbill-test.linkhub'  "LV_DEST
      destination              = lv_authdest
    IMPORTING
      client                   = http_client
    EXCEPTIONS
      argument_not_found       = 1
      destination_not_found    = 2
      destination_no_authority = 3
      plugin_not_active        = 4
      internal_error           = 5
      OTHERS                   = 6.
**
*    CALL METHOD cl_http_client=>create_by_url
*      EXPORTING
*        url                = lv_authurl
*        ssl_id             = 'ANONYM'
*      IMPORTING
*        client             = http_client
*      EXCEPTIONS
*        argument_not_found = 1
*        internal_error     = 2
*        plugin_not_active  = 3
*        others             = 4.
**

  http_client->propertytype_logon_popup = http_client->co_disabled.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = '~request_uri'
      value = '/Time'.

  CALL METHOD http_client->send
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2.

  CALL METHOD http_client->receive
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3.

  CALL METHOD http_client->response->get_status
    IMPORTING
      code = http_status_code.

  IF http_status_code = 200.
    p_utctime = http_client->response->get_cdata( ).
  ELSE.
    p_utctime = http_client->response->get_cdata( ).
    RAISE RESUMABLE EXCEPTION TYPE zgtsd_cx_linkhub
      EXPORTING
        code    = -99999999
        message = 'GETTIME FAILED.'.
  ENDIF.

  CALL METHOD http_client->close
    EXCEPTIONS
      http_invalid_state = 1
      OTHERS             = 2.

ENDMETHOD.


METHOD gettimestamp.
  DATA:
    http_client      TYPE REF TO if_http_client,
    my_message       TYPE string,
    http_status_code TYPE i.

** Create with Destination
  CALL METHOD cl_http_client=>create_by_destination
    EXPORTING
      destination              = lv_authdest
    IMPORTING
      client                   = http_client
    EXCEPTIONS
      argument_not_found       = 1
      destination_not_found    = 2
      destination_no_authority = 3
      plugin_not_active        = 4
      internal_error           = 5
      OTHERS                   = 6.
**
*    CALL METHOD cl_http_client=>create_by_url
*      EXPORTING
*        url                = lv_authurl
*        ssl_id             = 'ANONYM'
*      IMPORTING
*        client             = http_client
*      EXCEPTIONS
*        argument_not_found = 1
*        internal_error     = 2
*        plugin_not_active  = 3
*        others             = 4.
**

  http_client->propertytype_logon_popup = http_client->co_disabled.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = '~request_uri'
      value = '/Time'.

  CALL METHOD http_client->send
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2.

  CALL METHOD http_client->receive
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3.

  CALL METHOD http_client->response->get_status
    IMPORTING
      code = http_status_code.

  IF http_status_code = 200.
    p_utctimestamp = http_client->response->get_cdata( ).
  ELSE.
    RAISE RESUMABLE EXCEPTION TYPE zgtsd_cx_linkhub
      EXPORTING
        code    = -99999999
        message = 'GETTIME FAILED.'.
  ENDIF.

  CALL METHOD http_client->close
    EXCEPTIONS
      http_invalid_state = 1
      OTHERS             = 2.

ENDMETHOD.


METHOD PARTNERBALANCE.
  DATA:
    HTTP_CLIENT      TYPE REF TO IF_HTTP_CLIENT,
    LV_URL           TYPE STRING,
    LV_AUTHHEADER    TYPE STRING,
    LV_RESPONSE      TYPE STRING,
    HTTP_STATUS_CODE TYPE I.

  CONCATENATE '/' P_TOKEN-SERVICEID '/PartnerPoint' INTO LV_URL.

** Create with Destination
  CALL METHOD CL_HTTP_CLIENT=>CREATE_BY_DESTINATION
    EXPORTING
      DESTINATION              = LV_AUTHDEST
    IMPORTING
      CLIENT                   = HTTP_CLIENT
    EXCEPTIONS
      ARGUMENT_NOT_FOUND       = 1
      DESTINATION_NOT_FOUND    = 2
      DESTINATION_NO_AUTHORITY = 3
      PLUGIN_NOT_ACTIVE        = 4
      INTERNAL_ERROR           = 5
      OTHERS                   = 6.
**
*    CALL METHOD cl_http_client=>create_by_url
*      EXPORTING
*        url                = lv_authurl
*        ssl_id             = 'ANONYM'
*      IMPORTING
*        client             = http_client
*      EXCEPTIONS
*        argument_not_found = 1
*        internal_error     = 2
*        plugin_not_active  = 3
*        others             = 4.
**

  HTTP_CLIENT->PROPERTYTYPE_LOGON_POPUP = HTTP_CLIENT->CO_DISABLED.

  CALL METHOD HTTP_CLIENT->REQUEST->SET_HEADER_FIELD
    EXPORTING
      NAME  = '~request_uri'
      VALUE = LV_URL.

  CONCATENATE 'Bearer' P_TOKEN-SESSION_TOKEN INTO LV_AUTHHEADER SEPARATED BY SPACE.

  CALL METHOD HTTP_CLIENT->REQUEST->SET_HEADER_FIELD
    EXPORTING
      NAME  = 'Authorization'
      VALUE = LV_AUTHHEADER.

  CALL METHOD HTTP_CLIENT->SEND
    EXCEPTIONS
      HTTP_COMMUNICATION_FAILURE = 1
      HTTP_INVALID_STATE         = 2.

  CALL METHOD HTTP_CLIENT->RECEIVE
    EXCEPTIONS
      HTTP_COMMUNICATION_FAILURE = 1
      HTTP_INVALID_STATE         = 2
      HTTP_PROCESSING_FAILED     = 3.

  CALL METHOD HTTP_CLIENT->RESPONSE->GET_STATUS
    IMPORTING
      CODE = HTTP_STATUS_CODE.

  IF HTTP_STATUS_CODE = 200.
    TYPES :
      BEGIN OF POINTRESPONSE,
        REMAINPOINT TYPE P LENGTH 16 DECIMALS 2,
      END OF POINTRESPONSE.
    DATA LV_REMAINPOINT TYPE POINTRESPONSE.

    LV_RESPONSE = HTTP_CLIENT->RESPONSE->GET_CDATA( ).

    CALL METHOD ZGTSD_LINKHUB=>DESERIALIZE
      EXPORTING
        P_JSON = LV_RESPONSE
      CHANGING
        P_DATA = LV_REMAINPOINT.
    P_BALANCE = LV_REMAINPOINT-REMAINPOINT.

  ELSE.
    LV_RESPONSE = HTTP_CLIENT->RESPONSE->GET_CDATA( ).
    DATA : LV_RESULT TYPE S_LINKHUB_RESULT.

    CALL METHOD ZGTSD_LINKHUB=>DESERIALIZE
      EXPORTING
        P_JSON = LV_RESPONSE
      CHANGING
        P_DATA = LV_RESULT.
    RAISE RESUMABLE EXCEPTION TYPE ZGTSD_CX_LINKHUB
      EXPORTING
        CODE    = LV_RESULT-CODE
        MESSAGE = LV_RESULT-MESSAGE.
  ENDIF.

  CALL METHOD HTTP_CLIENT->CLOSE
    EXCEPTIONS
      HTTP_INVALID_STATE = 1
      OTHERS             = 2.

ENDMETHOD.


method SERIALIZE.

    P_JSON = cl_json=>serialize( data = P_OBJ compress = abap_true pretty_name = cl_json=>pretty_mode-low_case ).

  endmethod.
ENDCLASS.
