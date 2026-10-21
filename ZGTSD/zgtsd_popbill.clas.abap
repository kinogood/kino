class ZGTSD_POPBILL definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF s_popbill_result,
        code    TYPE int4,
        message TYPE string,
      END OF s_popbill_result .
  types:
    BEGIN OF s_pb_chargeinfo,
        unitcost     TYPE string,
        chargemethod TYPE string,
        ratesystem   TYPE string,
      END OF s_pb_chargeinfo .
  types:
    BEGIN OF s_pb_corpinfo,
        corpname TYPE string,
        ceoname  TYPE string,
        addr     TYPE string,
        biztype  TYPE string,
        bizclass TYPE string,
      END OF s_pb_corpinfo .
  types:
    BEGIN OF s_pb_contactinfo,
        id               TYPE string,
        pwd              TYPE string,
        email            TYPE string,
        hp               TYPE string,
        personname       TYPE string,
        searchallallowyn TYPE boolean,
        tel              TYPE string,
        fax              TYPE string,
        mgryn            TYPE boolean,
        regdt            TYPE string,
      END OF s_pb_contactinfo .
  types:
    t_pb_contactinfo TYPE HASHED TABLE OF s_pb_contactinfo WITH UNIQUE KEY id .
  types:
    BEGIN OF s_pb_joinform,
        id           TYPE string,
        pwd          TYPE string,
        linkid       TYPE string,
        corpnum      TYPE string,
        ceoname      TYPE string,
        corpname     TYPE string,
        addr         TYPE string,
        biztype      TYPE string,
        bizclass     TYPE string,
        contactname  TYPE string,
        contacttel   TYPE string,
        contacthp    TYPE string,
        contactfax   TYPE string,
        contactemail TYPE string,
      END OF s_pb_joinform .
  types:
** Kakao Open Talk
* Button
    BEGIN OF s_pb_button,
        n(14),
        t(2),
        u1    TYPE string,
        u2    TYPE string,
        tg(3),
      END OF s_pb_button .
  types:
*  Kakao Open Talk Receiver info
    BEGIN OF s_pb_msgs,
        rcv(20),
        rcvnm(70),
      END OF s_pb_msgs .
  types:
* Open Talk Structre
    BEGIN OF s_pb_content,
        templatecode(12),
        snd(20),
        content          TYPE string,
        altcontent(2000),
        altsendtype(1),
        snddt(14),
        requestnum(36),
        btns             TYPE TABLE OF s_pb_button WITH DEFAULT KEY,
        msgs             TYPE TABLE OF s_pb_msgs WITH DEFAULT KEY,
      END OF s_pb_content .
  types:
* Receipt Number.
    BEGIN OF s_pb_receiptnum,
        receiptnum TYPE string,
      END OF s_pb_receiptnum .
  types:
* Send Talk Detail
    BEGIN OF s_pb_send_stat_dtl,
        state          TYPE int1,    " 팝빌 상태코드
        senddt         TYPE string,  " 전송일시
        result         TYPE int3,    " 카카오 결과코드
        resultdt       TYPE string,  " 전송결과 수신일시
        contenttype    TYPE int1,   " 카카오톡 유형
        receivenum     TYPE string,  " 수신번호
        receivename    TYPE string,  " 수신자명
        content        TYPE string,  " 알림톡 내용
        altsubject     TYPE string,  " 대체문자 제목
        altcontent     TYPE string,  " 대체문자 내용
        altcontenttype TYPE string,  " 대체문자 전송타입
        altsenddt      TYPE string,  " 대체문자 전송일시
        altresult      TYPE int3,    " 대체문자 통신사 결과코드
        altresultdt    TYPE string,  " 대체문자 전송결과 수신일시
        receiptnum     TYPE string,  " 접수번호
        requestnum     TYPE string,  " 요청번호
        interoprefkey  TYPE string,  " 파트너 지정키
      END OF s_pb_send_stat_dtl .
  types:
* Receipt Number Status.
    BEGIN OF s_pb_send_stat,
        contenttype  TYPE int1,      " 카카오톡 유형
        templatecode TYPE string,    " 템플릿 코드
        plusfriendid TYPE string,    " 검색용 아이디
        sendnum      TYPE string,    " 발신번호
        altsubject   TYPE string,    " 대체문자 제목
        altcontent   TYPE string,    " 대체문자 내용
        altsendtype  TYPE string,    " 대체문자 유형
        reservedt    TYPE string,    " 예약일시
        adsyn        TYPE string,    " 광고메시지 전송 여부
        imageurl     TYPE string,    " 친구톡 이미지 URL
        sendcnt      TYPE string,    " 전송건수
        successcnt   TYPE string,    " 성공건수
        failcnt      TYPE string,    " 실패건수
        altcnt       TYPE string,    " 대체문자 건수
        cancelcnt    TYPE string,    " 취소건수
        btns         TYPE TABLE OF s_pb_button WITH DEFAULT KEY,
        msgs         TYPE TABLE OF s_pb_send_stat_dtl WITH DEFAULT KEY,
      END OF s_pb_send_stat .

**
  data IS_TEST type BOOLEAN .

  methods CONSTRUCTOR
    importing
      !P_LINKID type STRING
      !P_SECRETKEY type STRING .
  methods GETCORPINFO
    importing
      !P_CORPNUM type STRING
      !P_USERID type STRING optional
    exporting
      value(P_CORPINFO) type S_PB_CORPINFO
      value(P_RESULT) type S_POPBILL_RESULT .
  methods UPDATECORPINFO
    importing
      !P_CORPNUM type STRING
      !P_CORPINFO type S_PB_CORPINFO
      !P_USERID type STRING optional
    exporting
      value(P_RESULT) type S_POPBILL_RESULT .
  methods LISTCONTACT
    importing
      !P_CORPNUM type STRING
      !P_USERID type STRING optional
    exporting
      value(P_CONTACTLIST) type T_PB_CONTACTINFO
      value(P_RESULT) type S_POPBILL_RESULT .
  methods UPDATECONTACT
    importing
      !P_CORPNUM type STRING
      !P_CONTACTINFO type S_PB_CONTACTINFO
      !P_USERID type STRING optional
    exporting
      value(P_RESULT) type S_POPBILL_RESULT .
  methods REGISTCONTACT
    importing
      !P_CORPNUM type STRING
      !P_CONTACTINFO type S_PB_CONTACTINFO
      !P_USERID type STRING optional
    exporting
      value(P_RESULT) type S_POPBILL_RESULT .
  methods CHECKID
    importing
      !P_ID type STRING
    exporting
      value(P_RESULT) type S_POPBILL_RESULT .
  methods GETBALANCE
    importing
      !P_CORPNUM type STRING
    exporting
      value(P_BALANCE) type P
      value(P_RESULT) type S_POPBILL_RESULT .
  methods GETPARTNERBALANCE
    importing
      !P_CORPNUM type STRING
    exporting
      value(P_BALANCE) type P
      value(P_RESULT) type S_POPBILL_RESULT .
  methods CHECKISMEMBER
    importing
      !P_CORPNUM type STRING
      !P_LINKID type STRING
    exporting
      value(P_RESULT) type S_POPBILL_RESULT .
  methods JOINMEMBER
    importing
      !P_JOININFO type S_PB_JOINFORM
    exporting
      value(P_RESULT) type S_POPBILL_RESULT .
  methods GETPOPBILLURL
    importing
      !P_CORPNUM type STRING
      !P_TOGO type STRING
      !P_USERID type STRING optional
    exporting
      value(P_URL) type STRING
      value(P_RESULT) type S_POPBILL_RESULT .
  methods SENDOPENTALK
    importing
      !P_CORPNUM type STRING
      !P_CONTENT type S_PB_CONTENT
    exporting
      value(P_RESULT) type S_POPBILL_RESULT
      value(P_RECEIPTNUM) type STRING .
  methods GETTALKSTATUS
    importing
      !P_RECEIPTNUM type STRING
      !P_CORPNUM type STRING
    exporting
      value(P_STATUS) type S_PB_SEND_STAT
      value(P_RESULT) type S_POPBILL_RESULT
    exceptions
      ZGTSD_CX_LINKHUB .
protected section.

  types:
    BEGIN OF s_pb_file,
      fieldname TYPE string,
      filename  TYPE string,
      content   TYPE xstring,
    END OF s_pb_file .
  types:
    ts_pb_files TYPE STANDARD TABLE OF s_pb_file .

  data LT_SCOPE type ZGTSD_LINKHUB=>T_SCOPE .
  constants LC_SERVICEID_REAL type STRING value 'POPBILL' ##NO_TEXT.
  constants LC_SERVICEID_TEST type STRING value 'POPBILL_TEST' ##NO_TEXT.
  constants LC_POPBILL_URL_REAL type STRING value 'https://static-popbill.linkhub.co.kr' ##NO_TEXT.
  constants LC_POPBILL_URL_TEST type STRING value 'https://static-popbill-test.linkhub.co.kr' ##NO_TEXT.
  constants LC_API_VERSION type STRING value '1.0' ##NO_TEXT.
  constants LC_DEST_TEST type STRING value 'popbill-test.linkhub' ##NO_TEXT.
  constants LC_DEST_REAL type STRING value 'popbill.linkhub' ##NO_TEXT.

**
  methods INVOKEPB
    importing
      !P_URL type STRING
      !P_CORPNUM type STRING optional
      !P_USERID type STRING optional
      !P_POSTDATA type STRING optional
      !P_ACTION type STRING optional
    exporting
      value(P_OBJ) type ANY
    raising
      ZGTSD_CX_LINKHUB .
  methods INVOKEPB_STAT
    importing
      !P_URL type STRING
      !P_RECEIPTNUM type STRING
      !P_CORPNUM type STRING optional
      !P_USERID type STRING optional
      !P_POSTDATA type STRING optional
      !P_ACTION type STRING optional
    exporting
      value(P_OBJ) type ANY
      value(P_STATUS) type S_PB_SEND_STAT
    raising
      ZGTSD_CX_LINKHUB .
  methods INVOKEPB_TALK
    importing
      !P_URL type STRING
      !P_CORPNUM type STRING optional
      !P_USERID type STRING optional
      !P_POSTDATA type STRING optional
      !P_ACTION type STRING optional
    exporting
      value(P_OBJ) type ANY
      value(P_RECEIPTNUM) type STRING
    raising
      ZGTSD_CX_LINKHUB .
  methods INVOKEPB_FILE
    importing
      !P_URL type STRING
      !P_CORPNUM type STRING optional
      !P_USERID type STRING optional
      !P_POSTDATA type STRING optional
      !P_FILES type TS_PB_FILES
      !P_ACTION type STRING optional
    exporting
      value(P_OBJ) type ANY
    raising
      ZGTSD_CX_LINKHUB .
PRIVATE SECTION.

  TYPES:
    BEGIN OF cachedtoken,
      corpnum TYPE string,
      token   TYPE zgtsd_linkhub=>s_linkhub_token,
    END OF cachedtoken .
  TYPES:
    tokencache TYPE HASHED TABLE OF cachedtoken WITH UNIQUE KEY corpnum .

  DATA lt_tokencache TYPE tokencache .
  DATA lv_linkid TYPE string .
  DATA lv_secretkey TYPE string .

**
  METHODS gettoken
    IMPORTING
      !p_corpnum     TYPE string
      !p_forwardip   TYPE string OPTIONAL
    RETURNING
      VALUE(p_token) TYPE zgtsd_linkhub=>s_linkhub_token
    RAISING
      zgtsd_cx_linkhub .
  METHODS getserviceid
    RETURNING
      VALUE(p_serviceid) TYPE string .
  METHODS getserviceurl
    RETURNING
      VALUE(p_url) TYPE string .
  METHODS getservicedest
    RETURNING
      VALUE(p_dest) TYPE rfcdest .
ENDCLASS.



CLASS ZGTSD_POPBILL IMPLEMENTATION.


METHOD checkid.
  DATA:
    lv_url      TYPE string,
    lcx_linkhub TYPE REF TO zgtsd_cx_linkhub.

  CONCATENATE '/IDCheck?ID=' p_id INTO lv_url.

  TRY.
      CALL METHOD invokepb
        EXPORTING
          p_url = lv_url
        IMPORTING
          p_obj = p_result.
    CATCH zgtsd_cx_linkhub INTO lcx_linkhub.
      p_result-code = lcx_linkhub->code.
      p_result-message = lcx_linkhub->message.
  ENDTRY.

ENDMETHOD.


METHOD checkismember.
  DATA:
    lv_url      TYPE string,
    lcx_linkhub TYPE REF TO zgtsd_cx_linkhub.

  CONCATENATE '/Join?CorpNum=' p_corpnum '&LID=' p_linkid INTO lv_url.

  TRY.
      CALL METHOD invokepb
        EXPORTING
          p_url = lv_url
        IMPORTING
          p_obj = p_result.
    CATCH zgtsd_cx_linkhub INTO lcx_linkhub.
      p_result-code = lcx_linkhub->code.
      p_result-message = lcx_linkhub->message.
  ENDTRY.

ENDMETHOD.


METHOD constructor.

**
  lv_linkid    = p_linkid.
  lv_secretkey = p_secretkey.
  is_test      = abap_false.

  APPEND 'member' TO lt_scope.
  APPEND '153'    TO lt_scope.    " ATS code.

**

ENDMETHOD.


METHOD getbalance.
  DATA :
    ls_token    TYPE zgtsd_linkhub=>s_linkhub_token,
    lcx_popbill TYPE REF TO zgtsd_cx_linkhub.

  TRY.
      ls_token = gettoken( p_corpnum ).

      CALL METHOD zgtsd_linkhub=>balance
        EXPORTING
          p_token   = ls_token
        IMPORTING
          p_balance = p_balance.
      p_result-code = 1.
    CATCH zgtsd_cx_linkhub INTO lcx_popbill.
      p_result-code = lcx_popbill->code.
      p_result-message = lcx_popbill->message.
      RETURN.
  ENDTRY.

ENDMETHOD.


METHOD getcorpinfo.

  DATA: lv_url      TYPE string,
        lcx_linkhub TYPE REF TO zgtsd_cx_linkhub.

**
  CLEAR: lv_url.
  lv_url = '/CorpInfo'.

  TRY.
      CALL METHOD invokepb
        EXPORTING
          p_url     = lv_url
          p_corpnum = p_corpnum
          p_userid  = p_userid
        IMPORTING
          p_obj     = p_corpinfo.
      p_result-code = 1.

    CATCH zgtsd_cx_linkhub INTO lcx_linkhub.
      p_result-code    = lcx_linkhub->code.
      p_result-message = lcx_linkhub->message.

  ENDTRY.

**

ENDMETHOD.


METHOD getpartnerbalance.
  DATA :
    ls_token    TYPE zgtsd_linkhub=>s_linkhub_token,
    lcx_popbill TYPE REF TO zgtsd_cx_linkhub.

  TRY.
      ls_token = gettoken( p_corpnum ).

      CALL METHOD zgtsd_linkhub=>partnerbalance
        EXPORTING
          p_token   = ls_token
        IMPORTING
          p_balance = p_balance.
      p_result-code = 1.
    CATCH zgtsd_cx_linkhub INTO lcx_popbill.
      p_result-code = lcx_popbill->code.
      p_result-message = lcx_popbill->message.
      RETURN.
  ENDTRY.

ENDMETHOD.


METHOD getpopbillurl.
  DATA:
    lv_url      TYPE string,
    lcx_linkhub TYPE REF TO zgtsd_cx_linkhub.
  TYPES: BEGIN OF urlresponse,
           url TYPE string,
         END OF urlresponse.

  DATA : lv_urlresponse TYPE urlresponse.

  CONCATENATE '/?TG=' p_togo INTO lv_url.

  TRY.
      CALL METHOD invokepb
        EXPORTING
          p_url     = lv_url
          p_corpnum = p_corpnum
          p_userid  = p_userid
        IMPORTING
          p_obj     = lv_urlresponse.

      p_url = lv_urlresponse-url.
      p_result-code = 1.
    CATCH zgtsd_cx_linkhub INTO lcx_linkhub.
      p_result-code = lcx_linkhub->code.
      p_result-message = lcx_linkhub->message.
  ENDTRY.

ENDMETHOD.


  METHOD getservicedest.

    IF is_test = abap_true.
      p_dest = lc_dest_test.
    ELSE.
      p_dest = lc_dest_real.
    ENDIF.

  ENDMETHOD.


method GETSERVICEID.
    if is_Test = ABAP_TRUE.
      p_ServiceID = lc_serviceid_test.
    else.
      p_ServiceID = lc_serviceID_real.
    endif.
  ENDMETHOD.


method GETSERVICEURL.
    if is_test = ABAP_TRUE.
      p_url = lc_popbill_url_test.
    else.
      p_url = lc_popbill_url_real.
    endif.
  ENDMETHOD.


  METHOD gettalkstatus.

    DATA: lv_url      TYPE string,
          lcx_linkhub TYPE REF TO zgtsd_cx_linkhub.

**
    CLEAR: lv_url.
    lv_url = '/KakaoTalk/' && p_receiptnum .

    TRY.
        CALL METHOD invokepb_stat
          EXPORTING
            p_url        = lv_url
            p_receiptnum = p_receiptnum
            p_corpnum    = p_corpnum
*           P_USERID     = P_USERID
*           p_postdata   =
*           p_action     =
          IMPORTING
            p_obj        = p_result
            p_status     = p_status.

      CATCH zgtsd_cx_linkhub INTO lcx_linkhub.
        p_result-code = lcx_linkhub->code.
        p_result-message = lcx_linkhub->message.
    ENDTRY.

  ENDMETHOD.


METHOD gettoken.

  DATA: lv_reissue     TYPE boolean VALUE abap_true,
        lv_cachedtoken TYPE cachedtoken.

**
  READ TABLE lt_tokencache WITH TABLE KEY corpnum = p_corpnum INTO lv_cachedtoken.

  IF sy-subrc = 0.
    p_token = lv_cachedtoken-token.
    "check Token validation for expiration.

    DATA: utcnow           TYPE string,
          lv_compared      TYPE i,
          lv_now_timestamp TYPE timestamp.

    "current utctime... gettime().. String to TimeStamp is not yet supported.
*      lv_now_timestamp = ZGTSD_LINKHUB=>GETTIMESTAMP( ).

    GET TIME STAMP FIELD lv_now_timestamp.

    TRY.
        CALL METHOD cl_abap_tstmp=>compare
          EXPORTING
            tstmp1 = p_token-expiration
            tstmp2 = lv_now_timestamp
          RECEIVING
            comp   = lv_compared.

        IF lv_compared >= 0.
          lv_reissue = abap_false.
        ENDIF.
    ENDTRY.

  ENDIF.

  IF lv_reissue = abap_true.
    DELETE TABLE lt_tokencache WITH TABLE KEY corpnum = p_corpnum.

    p_token = zgtsd_linkhub=>generate_token( p_serviceid = getserviceid( )
                                             p_linkid    = lv_linkid
                                             p_secretkey = lv_secretkey
                                             p_accessid  = p_corpnum
                                             p_scope     = lt_scope ).
    lv_cachedtoken-corpnum = p_corpnum.
    lv_cachedtoken-token = p_token.
    INSERT lv_cachedtoken INTO TABLE lt_tokencache.

  ENDIF.

**

ENDMETHOD.


METHOD invokepb.

  DATA: http_client        TYPE REF TO if_http_client,
        lv_authheader      TYPE string,
        lv_response        TYPE string,
        ls_receiptnum      TYPE s_pb_receiptnum,
        lv_postdataxstring TYPE xstring,
        http_status_code   TYPE i.

**
** Create with Destination
  CALL METHOD cl_http_client=>create_by_destination
    EXPORTING
      destination              = getservicedest( )
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
*      url                = getserviceurl( )
*      ssl_id             = 'ANONYM'
*    IMPORTING
*      client             = http_client
*    EXCEPTIONS
*      argument_not_found = 1
*      internal_error     = 2
*      plugin_not_active  = 3
*      OTHERS             = 4.
**

  http_client->propertytype_logon_popup = http_client->co_disabled.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = '~request_uri'
      value = p_url.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = 'x-pb-version'
      value = lc_api_version.

  IF NOT p_corpnum IS INITIAL.

    DATA: lv_token TYPE zgtsd_linkhub=>s_linkhub_token.
    lv_token = gettoken( p_corpnum ).

    CONCATENATE 'Bearer' lv_token-session_token INTO lv_authheader SEPARATED BY space.

    CALL METHOD http_client->request->set_header_field
      EXPORTING
        name  = 'Authorization'
        value = lv_authheader.
  ENDIF.

  IF NOT p_userid IS INITIAL.
    CALL METHOD http_client->request->set_header_field
      EXPORTING
        name  = 'x-pb-userid'
        value = p_userid.
  ENDIF.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = 'Content-Type'
      value = 'Application/json'.

  IF NOT p_postdata IS INITIAL.

    IF NOT p_action IS INITIAL.
      CALL METHOD http_client->request->set_header_field
        EXPORTING
          name  = 'X-HTTP-Method-Override'
          value = p_action.
    ENDIF.

    CALL METHOD http_client->request->set_header_field
      EXPORTING
        name  = '~request_method'
        value = 'POST'.

    CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
      EXPORTING
        text   = p_postdata
      IMPORTING
        buffer = lv_postdataxstring
      EXCEPTIONS
        failed = 1
        OTHERS = 2.

    CALL METHOD http_client->request->set_data( data = lv_postdataxstring ).


  ENDIF.

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

    lv_response = http_client->response->get_cdata( ).

    CALL METHOD zgtsd_linkhub=>deserialize
      EXPORTING
        p_json = lv_response
      CHANGING
        p_data = p_obj.

  ELSE.

    lv_response = http_client->response->get_cdata( ).

    DATA: lv_result TYPE zgtsd_linkhub=>s_linkhub_result.

    CALL METHOD zgtsd_linkhub=>deserialize
      EXPORTING
        p_json = lv_response
      CHANGING
        p_data = lv_result.

    RAISE RESUMABLE EXCEPTION TYPE zgtsd_cx_linkhub
      EXPORTING
        code    = lv_result-code
        message = lv_result-message.

  ENDIF.

  CALL METHOD http_client->close
    EXCEPTIONS
      http_invalid_state = 1
      OTHERS             = 2.

**

ENDMETHOD.


METHOD invokepb_file.

  DATA: http_client        TYPE REF TO if_http_client,
        lv_authheader      TYPE string,
        lv_response        TYPE string,
        lv_postdataxstring TYPE xstring,
        http_status_code   TYPE i.

**
** Create with Destination
  CALL METHOD cl_http_client=>create_by_destination
    EXPORTING
      destination              = getservicedest( )
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
*        url                = getServiceurl( )
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
      value = p_url.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = 'x-pb-version'
      value = lc_api_version.

  IF NOT p_corpnum IS INITIAL.

    DATA: lv_token TYPE zgtsd_linkhub=>s_linkhub_token.
    lv_token = gettoken( p_corpnum ).

    CONCATENATE 'Bearer' lv_token-session_token INTO lv_authheader SEPARATED BY space.

    CALL METHOD http_client->request->set_header_field
      EXPORTING
        name  = 'Authorization'
        value = lv_authheader.
  ENDIF.

  IF NOT p_userid IS INITIAL.
    CALL METHOD http_client->request->set_header_field
      EXPORTING
        name  = 'x-pb-userid'
        value = p_userid.
  ENDIF.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = 'Content-Type'
      value = 'multipart/form-data'.

  IF NOT p_action IS INITIAL.
    CALL METHOD http_client->request->set_header_field
      EXPORTING
        name  = 'X-HTTP-Method-Override'
        value = p_action.
  ENDIF.

  CALL METHOD http_client->request->set_header_field
    EXPORTING
      name  = '~request_method'
      value = 'POST'.

  CALL METHOD http_client->request->if_http_entity~set_formfield_encoding
    EXPORTING
      formfield_encoding = cl_http_request=>if_http_entity~co_encoding_raw.

* mime multipart begin

  DATA: it_formulario TYPE tihttpnvp,
        wa_formulario LIKE LINE OF it_formulario,
        part          TYPE REF TO if_http_entity.

  IF NOT p_postdata IS INITIAL.

    part = http_client->request->if_http_entity~add_multipart( ).

    CALL METHOD part->set_header_field
      EXPORTING
        name  = 'content-disposition'
        value = 'form-data;name="form"'.

    CALL METHOD part->set_header_field
      EXPORTING
        name  = 'content-type'
        value = 'Application/json; charset=utf-8'.

    CALL METHOD part->append_cdata
      EXPORTING
        data = p_postdata.

  ENDIF.

  DATA : lv_file   TYPE s_pb_file,
         lv_tmpstr TYPE string,
         lv_length TYPE i.

  LOOP AT p_files INTO lv_file.
    part = http_client->request->if_http_entity~add_multipart( ).

    CONCATENATE 'form-data;name="' lv_file-fieldname '"; filename="' lv_file-filename '"' INTO lv_tmpstr.

    CALL METHOD part->set_header_field
      EXPORTING
        name  = 'content-disposition'
        value = lv_tmpstr.

    CALL METHOD part->set_header_field
      EXPORTING
        name  = 'content-type'
        value = 'Application/octet-stream'.

    CALL METHOD part->set_data
      EXPORTING
        data   = lv_file-content
        offset = 0
        length = xstrlen( lv_file-content ).

  ENDLOOP.

  DATA : lv_int TYPE i.
  lv_int = http_client->request->if_http_entity~num_multiparts( ).

* Mime multipart end.


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

    lv_response = http_client->response->get_cdata( ).

    CALL METHOD zgtsd_linkhub=>deserialize
      EXPORTING
        p_json = lv_response
      CHANGING
        p_data = p_obj.

  ELSE.
    lv_response = http_client->response->get_cdata( ).

    DATA: lv_result TYPE zgtsd_linkhub=>s_linkhub_result.

    CALL METHOD zgtsd_linkhub=>deserialize
      EXPORTING
        p_json = lv_response
      CHANGING
        p_data = lv_result.

    RAISE RESUMABLE EXCEPTION TYPE zgtsd_cx_linkhub
      EXPORTING
        code    = lv_result-code
        message = lv_result-message.

  ENDIF.

  CALL METHOD http_client->close
    EXCEPTIONS
      http_invalid_state = 1
      OTHERS             = 2.

**

ENDMETHOD.


  METHOD invokepb_stat.

    DATA: lo_http_client      TYPE REF TO if_http_client,

          ls_result           TYPE zgtsd_linkhub=>s_linkhub_result,
          ls_token            TYPE zgtsd_linkhub=>s_linkhub_token,
          lv_authheader       TYPE string,
          lv_http_status_code TYPE i,
          lv_response         TYPE string.

**
** Create with Destination
    CALL METHOD cl_http_client=>create_by_destination
      EXPORTING
        destination              = getservicedest( )
      IMPORTING
        client                   = lo_http_client
      EXCEPTIONS
        argument_not_found       = 1
        destination_not_found    = 2
        destination_no_authority = 3
        plugin_not_active        = 4
        internal_error           = 5
        OTHERS                   = 6.

    lo_http_client->propertytype_logon_popup = lo_http_client->co_disabled.

** Set Header Field.
* API Path.
    CALL METHOD lo_http_client->request->set_header_field
      EXPORTING
        name  = '~request_uri'
        value = p_url.

* Version.
    CALL METHOD lo_http_client->request->set_header_field
      EXPORTING
        name  = 'x-pb-version'
        value = lc_api_version.

    IF NOT p_corpnum IS INITIAL.
* Get token.
      CLEAR: ls_token.
      ls_token = gettoken( p_corpnum ).

* Authorization.
      CLEAR: lv_authheader.
      CONCATENATE 'Bearer' ls_token-session_token
             INTO lv_authheader SEPARATED BY space.

      CALL METHOD lo_http_client->request->set_header_field
        EXPORTING
          name  = 'Authorization'
          value = lv_authheader.
    ENDIF.

* User ID.
    IF NOT p_userid IS INITIAL.
      CALL METHOD lo_http_client->request->set_header_field
        EXPORTING
          name  = 'x-pb-userid'
          value = p_userid.
    ENDIF.

    CALL METHOD lo_http_client->request->set_header_field
      EXPORTING
        name  = 'Content-Type'
        value = 'Application/json'.

    IF NOT p_action IS INITIAL.
      CALL METHOD lo_http_client->request->set_header_field
        EXPORTING
          name  = 'X-HTTP-Method-Override'
          value = p_action.
    ENDIF.

* Set Method: GET.
    CALL METHOD lo_http_client->request->set_header_field
      EXPORTING
        name  = '~request_method'
        value = 'GET'.

** Send API and Receive.
    CALL METHOD lo_http_client->send
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2.

    CALL METHOD lo_http_client->receive
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3.

** Get Status.
    CLEAR: lv_http_status_code.
    CALL METHOD lo_http_client->response->get_status
      IMPORTING
        code = lv_http_status_code.

    CLEAR: lv_response.
    lv_response = lo_http_client->response->get_cdata( ).

    IF lv_http_status_code = 200.

      CALL METHOD zgtsd_linkhub=>deserialize
        EXPORTING
          p_json = lv_response
        CHANGING
          p_data = p_status.

    ELSE.

      CLEAR: ls_result.
      CALL METHOD zgtsd_linkhub=>deserialize
        EXPORTING
          p_json = lv_response
        CHANGING
          p_data = ls_result.

      RAISE RESUMABLE EXCEPTION TYPE zgtsd_cx_linkhub
        EXPORTING
          code    = ls_result-code
          message = ls_result-message.

    ENDIF.

    CALL METHOD lo_http_client->close
      EXCEPTIONS
        http_invalid_state = 1
        OTHERS             = 2.

**

  ENDMETHOD.


  METHOD invokepb_talk.

    DATA: http_client        TYPE REF TO if_http_client,
          lv_authheader      TYPE string,
          lv_response        TYPE string,
          ls_receiptnum      TYPE s_pb_receiptnum,
          lv_postdataxstring TYPE xstring,
          http_status_code   TYPE i.

**
* Create with Destination
    CALL METHOD cl_http_client=>create_by_destination
      EXPORTING
        destination              = getservicedest( )
      IMPORTING
        client                   = http_client
      EXCEPTIONS
        argument_not_found       = 1
        destination_not_found    = 2
        destination_no_authority = 3
        plugin_not_active        = 4
        internal_error           = 5
        OTHERS                   = 6.

    http_client->propertytype_logon_popup = http_client->co_disabled.

    CALL METHOD http_client->request->set_header_field
      EXPORTING
        name  = '~request_uri'
        value = p_url.

    CALL METHOD http_client->request->set_header_field
      EXPORTING
        name  = 'x-pb-version'
        value = lc_api_version.

    IF NOT p_corpnum IS INITIAL.

      DATA: lv_token TYPE zgtsd_linkhub=>s_linkhub_token.
      lv_token = gettoken( p_corpnum ).

      CONCATENATE 'Bearer' lv_token-session_token INTO lv_authheader SEPARATED BY space.

      CALL METHOD http_client->request->set_header_field
        EXPORTING
          name  = 'Authorization'
          value = lv_authheader.
    ENDIF.

    IF NOT p_userid IS INITIAL.
      CALL METHOD http_client->request->set_header_field
        EXPORTING
          name  = 'x-pb-userid'
          value = p_userid.
    ENDIF.

    CALL METHOD http_client->request->set_header_field
      EXPORTING
        name  = 'Content-Type'
        value = 'Application/json'.

    IF NOT p_postdata IS INITIAL.

      IF NOT p_action IS INITIAL.
        CALL METHOD http_client->request->set_header_field
          EXPORTING
            name  = 'X-HTTP-Method-Override'
            value = p_action.
      ENDIF.

      CALL METHOD http_client->request->set_header_field
        EXPORTING
          name  = '~request_method'
          value = 'POST'.

      CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
        EXPORTING
          text   = p_postdata
        IMPORTING
          buffer = lv_postdataxstring
        EXCEPTIONS
          failed = 1
          OTHERS = 2.

      CALL METHOD http_client->request->set_data( data = lv_postdataxstring ).


    ENDIF.

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

      lv_response = http_client->response->get_cdata( ).

      CALL METHOD zgtsd_linkhub=>deserialize
        EXPORTING
          p_json = lv_response
        CHANGING
          p_data = p_obj.

*     Get Receipt Number
      CALL METHOD zgtsd_linkhub=>deserialize
        EXPORTING
          p_json = lv_response
        CHANGING
          p_data = ls_receiptnum.

      IF ls_receiptnum IS NOT INITIAL.
        p_receiptnum = ls_receiptnum-receiptnum.
      ENDIF.

    ELSE.

      lv_response = http_client->response->get_cdata( ).

      DATA: lv_result TYPE zgtsd_linkhub=>s_linkhub_result.

      CALL METHOD zgtsd_linkhub=>deserialize
        EXPORTING
          p_json = lv_response
        CHANGING
          p_data = lv_result.

      RAISE RESUMABLE EXCEPTION TYPE zgtsd_cx_linkhub
        EXPORTING
          code    = lv_result-code
          message = lv_result-message.

    ENDIF.

    CALL METHOD http_client->close
      EXCEPTIONS
        http_invalid_state = 1
        OTHERS             = 2.

**

  ENDMETHOD.


METHOD joinmember.
  DATA: lv_postjson TYPE string,
        lv_url      TYPE string,
        lcx_linkhub TYPE REF TO zgtsd_cx_linkhub.
  lv_url = '/Join'.

  lv_postjson = zgtsd_linkhub=>serialize( p_obj = p_joininfo ).

  TRY.
      CALL METHOD invokepb
        EXPORTING
          p_url      = lv_url
          p_postdata = lv_postjson
        IMPORTING
          p_obj      = p_result.
    CATCH zgtsd_cx_linkhub INTO lcx_linkhub.
      p_result-code = lcx_linkhub->code.
      p_result-message = lcx_linkhub->message.
  ENDTRY.

ENDMETHOD.


METHOD listcontact.

  DATA: lv_url      TYPE string,
        lcx_linkhub TYPE REF TO zgtsd_cx_linkhub.

  lv_url = '/IDs'.

  TRY.
      CALL METHOD invokepb
        EXPORTING
          p_url     = lv_url
          p_corpnum = p_corpnum
          p_userid  = p_userid
        IMPORTING
          p_obj     = p_contactlist.
      p_result-code = 1.
    CATCH zgtsd_cx_linkhub INTO lcx_linkhub.
      p_result-code = lcx_linkhub->code.
      p_result-message = lcx_linkhub->message.
  ENDTRY.

ENDMETHOD.


METHOD registcontact.

  DATA: lv_postjson TYPE string,
        lv_url      TYPE string,
        lcx_linkhub TYPE REF TO zgtsd_cx_linkhub.

**
  lv_url = '/IDs/New'.

  lv_postjson = zgtsd_linkhub=>serialize( p_obj = p_contactinfo ).

  TRY.
      CALL METHOD invokepb
        EXPORTING
          p_url      = lv_url
          p_corpnum  = p_corpnum
          p_postdata = lv_postjson
          p_userid   = p_userid
        IMPORTING
          p_obj      = p_result.

    CATCH zgtsd_cx_linkhub INTO lcx_linkhub.
      p_result-code = lcx_linkhub->code.
      p_result-message = lcx_linkhub->message.
  ENDTRY.

ENDMETHOD.


  METHOD sendopentalk.

    DATA: lv_postjson   TYPE string,
          lv_url        TYPE string,
          lv_receiptnum TYPE string,
          lcx_linkhub   TYPE REF TO zgtsd_cx_linkhub.

**
    CLEAR: lv_url.
    lv_url = '/ATS'.

    CLEAR: lv_postjson.
    lv_postjson = zgtsd_linkhub=>serialize( p_obj = p_content ).

    CLEAR: lv_receiptnum.
    TRY.
*        CALL METHOD invokepb
        CALL METHOD invokepb_talk
          EXPORTING
            p_url        = lv_url
            p_corpnum    = p_corpnum
            p_postdata   = lv_postjson
*           P_USERID     = P_USERID
          IMPORTING
            p_obj        = p_result
            p_receiptnum = lv_receiptnum.

        IF lv_receiptnum IS NOT INITIAL.
          p_receiptnum = lv_receiptnum.
        ENDIF.

      CATCH zgtsd_cx_linkhub INTO lcx_linkhub.
        p_result-code = lcx_linkhub->code.
        p_result-message = lcx_linkhub->message.
    ENDTRY.

  ENDMETHOD.


METHOD updatecontact.

  DATA: lv_postjson TYPE string,
        lv_url      TYPE string,
        lcx_linkhub TYPE REF TO zgtsd_cx_linkhub.

**
  CLEAR: lv_url.
  lv_url = '/IDs'.

  lv_postjson = zgtsd_linkhub=>serialize( p_obj = p_contactinfo ).

  TRY.
      CALL METHOD invokepb
        EXPORTING
          p_url      = lv_url
          p_corpnum  = p_corpnum
          p_postdata = lv_postjson
          p_userid   = p_userid
        IMPORTING
          p_obj      = p_result.

    CATCH zgtsd_cx_linkhub INTO lcx_linkhub.
      p_result-code = lcx_linkhub->code.
      p_result-message = lcx_linkhub->message.
  ENDTRY.

**

ENDMETHOD.


METHOD updatecorpinfo.

  DATA: lv_postjson TYPE string,
        lv_url      TYPE string,
        lcx_linkhub TYPE REF TO zgtsd_cx_linkhub.

**
  CLEAR: lv_url.
  lv_url = '/CorpInfo'.

  lv_postjson = zgtsd_linkhub=>serialize( p_obj = p_corpinfo ).

  TRY.
      CALL METHOD invokepb
        EXPORTING
          p_url      = lv_url
          p_corpnum  = p_corpnum
          p_postdata = lv_postjson
          p_userid   = p_userid
        IMPORTING
          p_obj      = p_result.

    CATCH zgtsd_cx_linkhub INTO lcx_linkhub.
      p_result-code = lcx_linkhub->code.
      p_result-message = lcx_linkhub->message.
  ENDTRY.

**

ENDMETHOD.
ENDCLASS.
