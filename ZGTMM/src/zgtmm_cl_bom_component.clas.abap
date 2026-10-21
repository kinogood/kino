CLASS zgtmm_cl_bom_component DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb.
    CLASS-METHODS get_bom_component FOR TABLE FUNCTION ZGTMM_CV_GET_BOM_COMPONENT.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zgtmm_cl_bom_component IMPLEMENTATION.
  METHOD get_bom_component
            BY DATABASE FUNCTION FOR HDB
            LANGUAGE SQLSCRIPT
            USING  ZGTMM_CV_GET_BOM_ML.
*** variable declaration
    declare lv_count integer;
    declare lv_level integer;
***initialize the BOM Level = 1
    lv_level = 1;
***select the data for 1st Level BOM
    root_bom = select mandt,
                      material,
                      plant,
                      productionversion,
                      validitystartdate,
                      validityenddate,
                      bomheaderqty,
                      bomheaderqtyunit,
                      :lv_level as bomlevel,
                      material as parent,
                      component,
                      bomitemqty,
                      bomitemqtyunit,
                      componentscrapinpercent,
                      bomvaliditystartdate,
                      bomvalidityenddate,
                      baseunit,
                      coproduct
                    from ZGTMM_CV_GET_BOM_ML( p_datum => :p_datum )
                    where mandt    = :p_clnt
                      and material = :p_matnr
                      and plant    = :p_werks;
***pass the selected BOM data into OUT_BOM
    out_bom = select * from :root_bom;
***select the components from the 1st Level BOM
    components = select component from :root_bom;
***select the count of components from the 1st Level BOM
    select count ( * ) into lv_count from :components;
***if the components are found, check for next level BOM data
    while :lv_count > 0 do
***increment the BOM level
        lv_level = lv_level + 1;
***select the data for the BOM of components
        child_bom = select a.mandt,
                           p_matnr as material,
                           a.plant,
                           a.productionversion,
                           a.validitystartdate,
                           a.validityenddate,
                           a.bomheaderqty,
                           a.bomheaderqtyunit,
                           :lv_level as bomlevel,
                           b.component as parent,
                           a.component,
                           a.bomitemqty,
                           a.bomitemqtyunit,
                           a.componentscrapinpercent,
                           a.bomvaliditystartdate,
                           a.bomvalidityenddate,
                           a.baseunit,
                           a.coproduct
                     from ZGTMM_CV_GET_BOM_ML( p_datum => :p_datum ) as a
                     inner join :components as b
                       on a.material = b.component and
                          a.plant    = :p_werks;
***select the components from the above selected child BOM
        components = SELECT component from :child_bom;
***select the count of components from the above selected child BOM
*** if the count of component from this level is 0, then while loop will be terminated
        select COUNT ( * ) into lv_count from :components;
***merge the BOM data (OUT_BOM) with the components from current level in selection
        out_bom = select * from :out_bom
                    union all
                  select * from :child_bom;
    end while;
***return the data back to table function using RETURN
    return select * from :out_bom;
  endmethod.
ENDCLASS.
