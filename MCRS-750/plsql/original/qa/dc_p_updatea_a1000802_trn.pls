create or replace PROCEDURE          dc_p_updatea_a1000802_trn
                  ( p_cod_cia    a1000802.cod_cia    %TYPE,
                    p_num_poliza a1000802.num_poliza %TYPE,
                    p_num_spto   a1000802.num_spto   %TYPE,
                    p_num_riesgo a1000802.num_riesgo %TYPE,
                    p_tip_docum  a1000802.tip_docum  %TYPE,
                    p_cod_docum  a1000802.cod_docum  %TYPE)
IS
 /* -------------------- DESCRIPCION --------------------
 || Procedimiento para actualizar la a1000802 a partir de la
 || transitoria x1000802 (modificaciones locales de beneficiarios).
 || Se utiliza en la rutina de terceros.
 */ -----------------------------------------------------
 --
 /* -------------------- MODIFICACIONES --------------------
 || Antonio   - 99/02/01
 || Se a?aden los campos :
 || - cod_localidad_etiqueta
 || - nom_localidad_etiqueta
 */ --------------------------------------------------------
 --
BEGIN
  UPDATE A1000802
     SET
    (cod_cia        , num_poliza     , num_spto       ,
     num_riesgo     , tip_docum      , cod_docum      ,
     tip_domicilio  , nom_domicilio1 , nom_domicilio2 ,
     nom_domicilio3 , nom_localidad  , cod_pais       ,
     num_apartado   , cod_prov       , cod_postal     ,
     tlf_pais       , txt_etiqueta1  , txt_etiqueta2  ,
     txt_etiqueta3  , txt_etiqueta4  , txt_etiqueta5  ,
     nom_contacto   , tip_cargo      , tlf_zona       ,
     tlf_numero     , fax_numero     , email          ,
     cod_entidad    , cod_oficina    , cta_cte        ,
     cta_dc         , cod_estado     , txt_email      ,
     obs_asegurado     , cod_pais_etiqueta   , cod_estado_etiqueta  ,
     cod_prov_etiqueta , cod_postal_etiqueta , num_apartado_etiqueta,
     cod_localidad     , tip_tarjeta         , cod_tarjeta          ,
     num_tarjeta       ,
     cod_localidad_etiqueta,
     nom_localidad_etiqueta
    ) =
  ( SELECT cod_cia        , num_poliza     , p_num_spto     ,
           num_riesgo     , tip_docum      , cod_docum      ,
           tip_domicilio  , nom_domicilio1 , nom_domicilio2 ,
           nom_domicilio3 , nom_localidad  , cod_pais       ,
           num_apartado   , cod_prov       , cod_postal     ,
           tlf_pais       , txt_etiqueta1  , txt_etiqueta2  ,
           txt_etiqueta3  , txt_etiqueta4  , txt_etiqueta5  ,
           nom_contacto   , tip_cargo      , tlf_zona       ,
           tlf_numero     , fax_numero     , email          ,
           cod_entidad    , cod_oficina    , cta_cte        ,
           cta_dc         , cod_estado     , txt_email      ,
           obs_asegurado     , cod_pais_etiqueta   , cod_estado_etiqueta  ,
           cod_prov_etiqueta , cod_postal_etiqueta , num_apartado_etiqueta,
           cod_localidad     , tip_tarjeta         , cod_tarjeta          ,
           num_tarjeta ,
           cod_localidad_etiqueta,
           nom_localidad_etiqueta
      FROM X1000802
     WHERE cod_cia     = p_cod_cia
       AND num_poliza  = p_num_poliza
       AND num_riesgo  = p_num_riesgo
       AND tip_docum   = p_tip_docum
       AND cod_docum   = p_cod_docum  )
  WHERE cod_cia     = p_cod_cia
    AND num_poliza  = p_num_poliza
    AND num_spto    = p_num_spto
    AND num_riesgo  = p_num_riesgo
    AND tip_docum   = p_tip_docum
    AND cod_docum   = p_cod_docum;
    --
END dc_p_updatea_a1000802_trn;
 
 
 