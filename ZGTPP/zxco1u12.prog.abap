*&---------------------------------------------------------------------*
*& Include          ZXCO1U12
*&---------------------------------------------------------------------*
IF SY-TCODE <> 'CO03'.
  E_COCI_AUFK-ZZPRIORITY  = GV_ZZPRIORITY.
  E_COCI_AUFK-ZZORIGIN    = GV_ZZORIGIN.
  E_COCI_AUFK-ZZFOLLOWING = GV_ZZFOLLOWING.
* 묶음 생산오더 추가(20260108)
  E_COCI_AUFK-ZZBUNDLE = GV_ZZBUNDLE.
  E_COCI_AUFK-ZZPOSNR = GV_ZZPOSNR.
  E_COCI_AUFK-ZZCUT_REQ = GV_ZZCUT_REQ.
ENDIF.
