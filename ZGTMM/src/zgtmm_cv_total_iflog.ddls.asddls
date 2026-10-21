@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface 전체 Log'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGTMM_CV_TOTAL_IFLOG 
as 

//MM00001
select from ZGTMM_CV_VENDOR_IF_LOG_L 
{
   key  zifno,         
   key  cast(ZIFNO_N as zgteifname) as ZIFNO_N,   
   key  zifkey,
   key  system_id,            
        cast(ZTARGET_N as zgteifsyst) as ZTARGET_N,
        zstat,
        message,
        ifdat,
        iftim,
        ifnam,       
        lastdata      
}

union all
//MM00002
select from  ZGTMM_CV_PO_IF_LOG_L 
{
   key  zifno,
   key  cast(ZIFNO_N as zgteifname) as ZIFNO_N,   
   key  zifkey,
   key  system_id,            
        cast(ZTARGET_N as zgteifsyst) as ZTARGET_N,
        zstat,
        message,
        ifdat,
        iftim,
        ifnam,       
        
        lastdata 
}


union all
//MM00003
select from  ZGTMM_CV_BL_IF_LOG_L
{
   key  zifno,    
   key  cast(ZIFNO_N as zgteifname) as ZIFNO_N,   
   key  zifkey,
   key  system_id,            
        cast(ZTARGET_N as zgteifsyst) as ZTARGET_N,
        zstat,
        message,
        ifdat,
        iftim,
        ifnam,             
        lastdata
}

union all

//MM00004
select from  ZGTMM_CV_CU_IF_LOG_L
{
   key  zifno,    
   key  cast(ZIFNO_N as zgteifname) as ZIFNO_N,   
   key  zifkey,
   key  system_id,            
        cast(ZTARGET_N as zgteifsyst) as ZTARGET_N,
        zstat,
        message,
        ifdat,
        iftim,
        ifnam,            
        lastdata
}

union all

//MM00005
select from ZGTMM_CV_ID_IF_LOG_L 
{
   key  zifno,    
   key  cast(ZIFNO_N as zgteifname) as ZIFNO_N,   
   key  zifkey,
   key  system_id,            
        cast(ZTARGET_N as zgteifsyst) as ZTARGET_N,
        zstat,
        message,
        ifdat,
        iftim,
        ifnam,            
        lastdata
}

union all
//MM00006
select from ZGTMM_CV_RES_IF_LOG_L 
{
   key  zifno,      
   key  cast(ZIFNO_N as zgteifname) as ZIFNO_N,   
   key  zifkey,
   key  system_id,            
        cast(ZTARGET_N as zgteifsyst) as ZTARGET_N,
        zstat,
        message,
        ifdat,
        iftim,
        ifnam,           
        lastdata
}

union all
//MM00007
select from ZGTMM_CV_IMGR_IF_LOG_L 
{
   key  zifno,   
   key  cast(ZIFNO_N as zgteifname) as ZIFNO_N,   
   key  zifkey,
   key  system_id,            
        cast(ZTARGET_N as zgteifsyst) as ZTARGET_N,
        zstat,
        message,
        ifdat,
        iftim,
        ifnam,            
        lastdata
}

union all
//MM00008
select from ZGTMM_CV_SCGR_IF_LOG_L 
{
   key  zifno,     
   key  cast(ZIFNO_N as zgteifname) as ZIFNO_N,   
   key  zifkey,
   key  system_id,            
        cast(ZTARGET_N as zgteifsyst) as ZTARGET_N,
        zstat,
        message,
        ifdat,
        iftim,
        ifnam,             
        lastdata
}

union all
//MM00009
select from ZGTMM_CV_NGR_IF_LOG_L 
{
   key  zifno,     
   key  cast(ZIFNO_N as zgteifname) as ZIFNO_N,   
   key  zifkey,
   key  system_id,            
        cast(ZTARGET_N as zgteifsyst) as ZTARGET_N,
        zstat,
        message,
        ifdat,
        iftim,
        ifnam,             
        lastdata
}

union all
//MM00010
select from ZGTMM_CV_GRC_IF_LOG_L 
{
   key  zifno,    
   key  cast(ZIFNO_N as zgteifname) as ZIFNO_N,   
   key  zifkey,
   key  system_id,            
        cast(ZTARGET_N as zgteifsyst) as ZTARGET_N,
        zstat,
        message,
        ifdat,
        iftim,
        ifnam,           
        lastdata
}

union all
//MM00011
select from ZGTMM_CV_EMVT_IF_LOG_L
{
   key  zifno,    
   key  cast(ZIFNO_N as zgteifname) as ZIFNO_N,   
   key  zifkey,
   key  system_id,            
        cast(ZTARGET_N as zgteifsyst) as ZTARGET_N,
        zstat,
        message,
        ifdat,
        iftim,
        ifnam,     
        lastdata
}

union all
//MM00012
select from ZGTMM_CV_RMVT_IF_LOG_L 
{
   key  zifno,      
   key  cast(ZIFNO_N as zgteifname) as ZIFNO_N,   
   key  zifkey,
   key  system_id,            
        cast(ZTARGET_N as zgteifsyst) as ZTARGET_N,
        zstat,
        message,
        ifdat,
        iftim,
        ifnam,           
        lastdata
}
