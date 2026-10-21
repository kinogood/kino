@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '[BD] 제조지시 물량합계 검증'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTSD_CV_JOBNO_Verify as 
    select from zgtsdt0066 as base left outer join ZGTSD_CV_JOBNO_SUM_0067 as qty67
                                        on base.job_no     = qty67.job_no
                                       and base.posnr      = qty67.posnr
                                       and base.qcode      = qty67.qcode
                                       and base.zsystem_id = qty67.zsystem_id
       
                                   left outer join zgtsdt0065 as qty65
                                     on base.job_no        = qty65.job_no
                                    and base.posnr         = qty65.posnr
                                    and base.zsystem_id    = qty65.zsystem_id
                                   
                                   left outer join zgtedt2121 as ed21
                                    on base.zsystem_id     = ed21.zsystem_id
                                   and base.job_no         = ed21.zjob_no
                                   and qty65.zpjno         = ed21.zpjt_no
{
    /* Key Fields */
    key base.zsystem_id as sysid,
    key qty65.zpjno as pjtno,
    key base.job_no as jobno,
    key qty65.vbeln,
    key base.posnr  as itemno,
    key qty65.matnr,
    key base.qcode,
    
    ed21.zjob_name, qty65.zdelv_date, base.qname,    
    cast(sum(base.qqty) as abap.dec(15,3)) as total_qyt66,
    qty67.total_qty67, qty65.ord_len as ordlen, base.qunit,
    
     /* Verification Logic */
    case
        when base.qunit <> 'M' and
            ( cast(sum(base.qqty) as abap.dec(15,3)) = qty67.total_qty67 )
        then 'O'
        
        when base.qunit <> 'M' and
            ( cast(sum(base.qqty) as abap.dec(15,3)) <> qty67.total_qty67 )
        then 'X'
        
        when base.qunit  = 'M' and 
            (cast(sum(base.qqty) as abap.dec(15,3)) = qty67.total_qty67 and 
            qty67.total_qty67 = qty65.ord_len)
        then 'O'
        
        when base.qunit  = 'M' and 
            (cast(sum(base.qqty) as abap.dec(15,3)) <> qty67.total_qty67 or 
            qty67.total_qty67 <> qty65.ord_len)
        then 'X'
         
        else 'N/A' 
    end as vrfy,
    
--    @Semantics.amount.currencyCode: 'qwaerk'
--    base.qamt as qamt,
--    base.qwaerk as qwaerk,
    base.erdat    
    
}
group by 
    base.zsystem_id, base.job_no, base.posnr, base.qunit, base.erdat, 
    base.qcode, base.qname, base.qamt, base.qwaerk,
    qty65.ord_len, qty65.zpjno, qty65.matnr, qty65.zdelv_date, qty65.vbeln,
    qty67.total_qty67,
    ed21.zjob_name
