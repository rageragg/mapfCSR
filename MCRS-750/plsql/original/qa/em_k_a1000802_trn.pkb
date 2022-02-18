create or replace PACKAGE BODY em_k_a1000802_trn AS
 --
 l_existe BOOLEAN := FALSE;
 --
 /* -------------------- VERSION = 1.07 --------------------  */
 --
 /* -------------------- MODIFICACIONES --------------------
 || 2014/05/02 - GACASTANEDA - 1.07 - (MS-2013-12-00620)
 || Se da de alta las siguientes funciones:
 || * f_apellido_contacto: Retorna el apellido del contacto
 ||   de la tabla a1000802.
 || * f_tip_docum_contacto: Retorna el tipo de documento del contacto
 ||   de la tabla a1000802.
 || * f_cod_docum_contacto: Retorna el codigo de documento del contacto
 ||   de la tabla a1000802.
 || * f_cod_nacionalidad_contacto: Retorna el codigo de nacionalidad
 ||   del contacto de la tabla a1000802.
 || Se modifica el procedimiento p_inserta agregando los campos
 || apellido_contacto, tip_docum_contacto, cod_docum_contacto
 || y cod_nacionalidad_contacto en la sentencia de insercion
 || de datos a la tabla a1000802.
 */ --------------------------------------------------------
 --
 PROCEDURE p_comprueba_error IS
  --
  l_cod_mensaje g1010020.cod_mensaje%TYPE;
  l_txt_mensaje g1010020.txt_mensaje%TYPE;
  l_hay_error   EXCEPTION;
  --
  BEGIN
   IF NOT l_existe
    THEN
     l_cod_mensaje := 20001;
     l_txt_mensaje := ss_f_mensaje(l_cod_mensaje);
     l_txt_mensaje := l_txt_mensaje || ' (PK a1000802)';
     --
     RAISE_APPLICATION_ERROR(-l_cod_mensaje,l_txt_mensaje);
     --
   END IF;
   --
  END p_comprueba_error;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 PROCEDURE p_lee(
                 p_cod_cia a1000802.cod_cia%TYPE,
                 p_num_poliza a1000802.num_poliza%TYPE,
                 p_num_spto a1000802.num_spto%TYPE,
                 p_num_riesgo a1000802.num_riesgo%TYPE,
                 p_tip_docum a1000802.tip_docum%TYPE,
                 p_cod_docum a1000802.cod_docum%TYPE) IS
 BEGIN
  OPEN        c_a1000802(
                         p_cod_cia,
                         p_num_poliza,
                         p_num_spto,
                         p_num_riesgo,
                         p_tip_docum,
                         p_cod_docum);
  FETCH       c_a1000802 INTO reg;
  l_existe := c_a1000802%FOUND;
  CLOSE       c_a1000802;
  --
  p_comprueba_error;
  --
 END p_lee;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_cod_pais RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.cod_pais;
  --
 END f_cod_pais;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_cod_estado RETURN NUMBER IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.cod_estado;
  --
 END f_cod_estado;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_cod_prov RETURN NUMBER IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.cod_prov;
  --
 END f_cod_prov;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_cod_localidad RETURN NUMBER IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.cod_localidad;
  --
 END f_cod_localidad;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_nom_localidad RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.nom_localidad;
  --
 END f_nom_localidad;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_tip_domicilio RETURN NUMBER IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.tip_domicilio;
  --
 END f_tip_domicilio;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_nom_domicilio1 RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.nom_domicilio1;
  --
 END f_nom_domicilio1;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_nom_domicilio2 RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.nom_domicilio2;
  --
 END f_nom_domicilio2;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_nom_domicilio3 RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.nom_domicilio3;
  --
 END f_nom_domicilio3;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_cod_postal RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.cod_postal;
  --
 END f_cod_postal;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_num_apartado RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.num_apartado;
  --
 END f_num_apartado;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_tlf_pais RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.tlf_pais;
  --
 END f_tlf_pais;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_tlf_zona RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.tlf_zona;
  --
 END f_tlf_zona;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_tlf_numero RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.tlf_numero;
  --
 END f_tlf_numero;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_fax_numero RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.fax_numero;
  --
 END f_fax_numero;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_email RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.email;
  --
 END f_email;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_txt_etiqueta1 RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.txt_etiqueta1;
  --
 END f_txt_etiqueta1;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_txt_etiqueta2 RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.txt_etiqueta2;
  --
 END f_txt_etiqueta2;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_txt_etiqueta3 RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.txt_etiqueta3;
  --
 END f_txt_etiqueta3;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_txt_etiqueta4 RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.txt_etiqueta4;
  --
 END f_txt_etiqueta4;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_txt_etiqueta5 RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.txt_etiqueta5;
  --
 END f_txt_etiqueta5;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_txt_email RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.txt_email;
  --
 END f_txt_email;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_nom_contacto RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.nom_contacto;
  --
 END f_nom_contacto;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_tip_cargo RETURN NUMBER IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.tip_cargo;
  --
 END f_tip_cargo;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_cod_entidad RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.cod_entidad;
  --
 END f_cod_entidad;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_cod_oficina RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.cod_oficina;
  --
 END f_cod_oficina;
 --
 /* -------------------------------------------------------
 || f_nom_titular_cta
 */ --------------------------------------------------------
 FUNCTION f_nom_titular_cta
    RETURN a1000802.nom_titular_cta%TYPE
 IS
 --
 BEGIN
    --
    p_comprueba_error;
    --
    RETURN reg.nom_titular_cta;
    --
 END f_nom_titular_cta;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_cta_cte RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.cta_cte;
  --
 END f_cta_cte;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_cta_dc RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.cta_dc;
  --
 END f_cta_dc;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || Elena  - 00/10/06
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_cod_compensacion RETURN NUMBER IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.cod_compensacion;
  --
 END f_cod_compensacion;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_tip_tarjeta RETURN NUMBER IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.tip_tarjeta;
  --
 END f_tip_tarjeta;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_cod_tarjeta RETURN NUMBER IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.cod_tarjeta;
  --
 END f_cod_tarjeta;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_num_tarjeta RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.num_tarjeta;
  --
 END f_num_tarjeta;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_obs_asegurado RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.obs_asegurado;
  --
 END f_obs_asegurado;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_cod_pais_etiqueta RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.cod_pais_etiqueta;
  --
 END f_cod_pais_etiqueta;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_cod_estado_etiqueta RETURN NUMBER IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.cod_estado_etiqueta;
  --
 END f_cod_estado_etiqueta;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_cod_prov_etiqueta RETURN NUMBER IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.cod_prov_etiqueta;
  --
 END f_cod_prov_etiqueta;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_cod_postal_etiqueta RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.cod_postal_etiqueta;
  --
 END f_cod_postal_etiqueta;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_num_apartado_etiqueta RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.num_apartado_etiqueta;
  --
 END f_num_apartado_etiqueta;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_cod_localidad_etiqueta RETURN NUMBER IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.cod_localidad_etiqueta;
  --
 END f_cod_localidad_etiqueta;
 --
 /* -------------------- MODIFICACIONES --------------------
 || Usuario   - AA/MM/DD
 || Comentario
 || --------------------------------------------------------
 || TRON2000  - 99/02/15
 || Creacion
 */ --------------------------------------------------------
 FUNCTION f_nom_localidad_etiqueta RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.nom_localidad_etiqueta;
  --
 END f_nom_localidad_etiqueta;
 --
 --
 FUNCTION f_tip_etiqueta RETURN NUMBER IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.tip_etiqueta;
  --
 END f_tip_etiqueta;
 --
 --
 FUNCTION f_fec_vcto_tarjeta RETURN DATE IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.fec_vcto_tarjeta;
  --
 END f_fec_vcto_tarjeta;
 --
 --
 FUNCTION f_num_secu_cta RETURN NUMBER IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.num_secu_cta;
  --
 END f_num_secu_cta;
 --
 --
 FUNCTION f_atr_domicilio1 RETURN VARCHAR2 IS
 BEGIN
    --
    p_comprueba_error;
    --
    RETURN reg.atr_domicilio1;
    --
 END f_atr_domicilio1;
 --
 FUNCTION f_atr_domicilio2 RETURN VARCHAR2 IS
 BEGIN
    --
    p_comprueba_error;
    --
    RETURN reg.atr_domicilio2;
    --
 END f_atr_domicilio2;
 --
 FUNCTION f_atr_domicilio3 RETURN VARCHAR2 IS
 BEGIN
    --
    p_comprueba_error;
    --
    RETURN reg.atr_domicilio3;
    --
 END f_atr_domicilio3;
  --
 FUNCTION f_atr_domicilio4 RETURN VARCHAR2 IS
 BEGIN
    --
    p_comprueba_error;
    --
    RETURN reg.atr_domicilio4;
    --
 END f_atr_domicilio4;
  --
 FUNCTION f_atr_domicilio5 RETURN VARCHAR2 IS
 BEGIN
    --
    p_comprueba_error;
    --
    RETURN reg.atr_domicilio5;
    --
 END f_atr_domicilio5;
  --
 FUNCTION f_anx_domicilio RETURN VARCHAR2 IS
 BEGIN
    --
    p_comprueba_error;
    --
    RETURN reg.anx_domicilio;
    --
 END f_anx_domicilio;
  --
 FUNCTION f_ext_cod_postal RETURN VARCHAR2 IS
 BEGIN
    --
    p_comprueba_error;
    --
    RETURN reg.ext_cod_postal;
    --
 END f_ext_cod_postal;
   --
 FUNCTION f_tlf_extension RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.tlf_extension;
  --
 END f_tlf_extension;
    --
 FUNCTION f_nom_empresa_com RETURN VARCHAR2 IS
 BEGIN
    --
    p_comprueba_error;
    --
    RETURN reg.nom_empresa_com;
    --
 END f_nom_empresa_com;
     --
 FUNCTION f_atr_domicilio1_com RETURN VARCHAR2 IS
 BEGIN
    --
    p_comprueba_error;
    --
    RETURN reg.atr_domicilio1_com;
    --
 END f_atr_domicilio1_com;
      --
 FUNCTION f_atr_domicilio2_com RETURN VARCHAR2 IS
 BEGIN
    --
    p_comprueba_error;
    --
    RETURN reg.atr_domicilio2_com;
    --
 END f_atr_domicilio2_com;
      --
 FUNCTION f_atr_domicilio3_com RETURN VARCHAR2 IS
 BEGIN
    --
    p_comprueba_error;
    --
    RETURN reg.atr_domicilio3_com;
    --
 END f_atr_domicilio3_com;
      --
 FUNCTION f_atr_domicilio4_com RETURN VARCHAR2 IS
 BEGIN
    --
    p_comprueba_error;
    --
    RETURN reg.atr_domicilio4_com;
    --
 END f_atr_domicilio4_com;
      --
 FUNCTION f_atr_domicilio5_com RETURN VARCHAR2 IS
 BEGIN
    --
    p_comprueba_error;
    --
    RETURN reg.atr_domicilio5_com;
    --
 END f_atr_domicilio5_com;
      --
 FUNCTION f_anx_domicilio_com RETURN VARCHAR2 IS
 BEGIN
    --
    p_comprueba_error;
    --
    RETURN reg.anx_domicilio_com;
    --
 END f_anx_domicilio_com;
 --
 FUNCTION f_ext_cod_postal_com RETURN VARCHAR2 IS
 BEGIN
    --
    p_comprueba_error;
    --
    RETURN reg.ext_cod_postal_com;
    --
 END f_ext_cod_postal_com;
   --
 FUNCTION f_tlf_extension_com RETURN VARCHAR2 IS
 BEGIN
  --
  p_comprueba_error;
  --
  RETURN reg.tlf_extension_com;
  --
 END f_tlf_extension_com;
 --
 --
 FUNCTION f_ext_cod_postal_etiqueta      RETURN VARCHAR2  IS
 BEGIN
    --
    p_comprueba_error;
    --
    RETURN reg.ext_cod_postal_etiqueta;
    --
 END f_ext_cod_postal_etiqueta;
 --
 /* --------------------------------------------------
 || Devuelve el valor de la columna apellido_contacto
 */ --------------------------------------------------
 --
 FUNCTION f_apellido_contacto
    RETURN a1000802.apellido_contacto%TYPE
 IS
 --
 BEGIN
    --
    p_comprueba_error;
    --
    RETURN reg.apellido_contacto;
    --
 END f_apellido_contacto;
 --
 /* --------------------------------------------------
 || Devuelve el valor de la columna tip_docum_contacto
 */ --------------------------------------------------
 --
 FUNCTION f_tip_docum_contacto
    RETURN a1000802.tip_docum_contacto%TYPE
 IS
 --
 BEGIN
    --
    p_comprueba_error;
    --
    RETURN reg.tip_docum_contacto;
    --
 END f_tip_docum_contacto;
 --
 /* --------------------------------------------------
 || Devuelve el valor de la columna cod_docum_contacto
 */ --------------------------------------------------
 --
 FUNCTION f_cod_docum_contacto
    RETURN a1000802.cod_docum_contacto%TYPE
 IS
 --
 BEGIN
    --
    p_comprueba_error;
    --
    RETURN reg.cod_docum_contacto;
    --
 END f_cod_docum_contacto;
 --
 /* --------------------------------------------------
 || Devuelve el valor de la columna cod_nacionalidad_contacto
 */ --------------------------------------------------
 --
 FUNCTION f_cod_nacionalidad_contacto
    RETURN a1000802.cod_nacionalidad_contacto%TYPE
 IS
 --
 BEGIN
    --
    p_comprueba_error;
    --
    RETURN reg.cod_nacionalidad_contacto;
    --
 END f_cod_nacionalidad_contacto;
 --
 /* --------------------------------------------------
 || Procedimiento para insertar un registro en la tabla
 || a1000802.
 */ --------------------------------------------------
 --
 PROCEDURE p_inserta(p_reg IN     a1000802%ROWTYPE)
 IS
 --
 BEGIN
    --
    INSERT INTO a1000802(cod_cia                  ,
                         num_poliza               ,
                         num_spto                 ,
                         num_riesgo               ,
                         tip_docum                ,
                         cod_docum                ,
                         cod_pais                 ,
                         cod_estado               ,
                         cod_prov                 ,
                         cod_localidad            ,
                         nom_localidad            ,
                         tip_domicilio            ,
                         nom_domicilio1           ,
                         nom_domicilio2           ,
                         nom_domicilio3           ,
                         cod_postal               ,
                         num_apartado             ,
                         tlf_pais                 ,
                         tlf_zona                 ,
                         tlf_numero               ,
                         fax_numero               ,
                         email                    ,
                         txt_etiqueta1            ,
                         txt_etiqueta2            ,
                         txt_etiqueta3            ,
                         txt_etiqueta4            ,
                         txt_etiqueta5            ,
                         txt_email                ,
                         nom_contacto             ,
                         tip_cargo                ,
                         cod_entidad              ,
                         cod_oficina              ,
                         cta_cte                  ,
                         cta_dc                   ,
                         tip_tarjeta              ,
                         cod_tarjeta              ,
                         num_tarjeta              ,
                         obs_asegurado            ,
                         cod_pais_etiqueta        ,
                         cod_estado_etiqueta      ,
                         cod_prov_etiqueta        ,
                         cod_postal_etiqueta      ,
                         num_apartado_etiqueta    ,
                         cod_localidad_etiqueta   ,
                         nom_localidad_etiqueta   ,
                         fec_vcto_tarjeta         ,
                         cod_compensacion         ,
                         tip_etiqueta             ,
                         num_secu_cta             ,
                         atr_domicilio1           ,
                         atr_domicilio2           ,
                         atr_domicilio3           ,
                         atr_domicilio4           ,
                         atr_domicilio5           ,
                         anx_domicilio            ,
                         ext_cod_postal           ,
                         tlf_extension            ,
                         nom_empresa_com          ,
                         atr_domicilio1_com       ,
                         atr_domicilio2_com       ,
                         atr_domicilio3_com       ,
                         atr_domicilio4_com       ,
                         atr_domicilio5_com       ,
                         anx_domicilio_com        ,
                         ext_cod_postal_com       ,
                         tlf_extension_com        ,
                         ext_cod_postal_etiqueta  ,
                         nom_titular_cta          ,
                         apellido_contacto        ,
                         tip_docum_contacto       ,
                         cod_docum_contacto       ,
                         cod_nacionalidad_contacto)
         VALUES (p_reg.cod_cia                  ,
                 p_reg.num_poliza               ,
                 p_reg.num_spto                 ,
                 p_reg.num_riesgo               ,
                 p_reg.tip_docum                ,
                 p_reg.cod_docum                ,
                 p_reg.cod_pais                 ,
                 p_reg.cod_estado               ,
                 p_reg.cod_prov                 ,
                 p_reg.cod_localidad            ,
                 p_reg.nom_localidad            ,
                 p_reg.tip_domicilio            ,
                 p_reg.nom_domicilio1           ,
                 p_reg.nom_domicilio2           ,
                 p_reg.nom_domicilio3           ,
                 p_reg.cod_postal               ,
                 p_reg.num_apartado             ,
                 p_reg.tlf_pais                 ,
                 p_reg.tlf_zona                 ,
                 p_reg.tlf_numero               ,
                 p_reg.fax_numero               ,
                 p_reg.email                    ,
                 p_reg.txt_etiqueta1            ,
                 p_reg.txt_etiqueta2            ,
                 p_reg.txt_etiqueta3            ,
                 p_reg.txt_etiqueta4            ,
                 p_reg.txt_etiqueta5            ,
                 p_reg.txt_email                ,
                 p_reg.nom_contacto             ,
                 p_reg.tip_cargo                ,
                 p_reg.cod_entidad              ,
                 p_reg.cod_oficina              ,
                 p_reg.cta_cte                  ,
                 p_reg.cta_dc                   ,
                 p_reg.tip_tarjeta              ,
                 p_reg.cod_tarjeta              ,
                 p_reg.num_tarjeta              ,
                 p_reg.obs_asegurado            ,
                 p_reg.cod_pais_etiqueta        ,
                 p_reg.cod_estado_etiqueta      ,
                 p_reg.cod_prov_etiqueta        ,
                 p_reg.cod_postal_etiqueta      ,
                 p_reg.num_apartado_etiqueta    ,
                 p_reg.cod_localidad_etiqueta   ,
                 p_reg.nom_localidad_etiqueta   ,
                 p_reg.fec_vcto_tarjeta         ,
                 p_reg.cod_compensacion         ,
                 p_reg.tip_etiqueta             ,
                 p_reg.num_secu_cta             ,
                 p_reg.atr_domicilio1           ,
                 p_reg.atr_domicilio2           ,
                 p_reg.atr_domicilio3           ,
                 p_reg.atr_domicilio4           ,
                 p_reg.atr_domicilio5           ,
                 p_reg.anx_domicilio            ,
                 p_reg.ext_cod_postal           ,
                 p_reg.tlf_extension            ,
                 p_reg.nom_empresa_com          ,
                 p_reg.atr_domicilio1_com       ,
                 p_reg.atr_domicilio2_com       ,
                 p_reg.atr_domicilio3_com       ,
                 p_reg.atr_domicilio4_com       ,
                 p_reg.atr_domicilio5_com       ,
                 p_reg.anx_domicilio_com        ,
                 p_reg.ext_cod_postal_com       ,
                 p_reg.tlf_extension_com        ,
                 p_reg.ext_cod_postal_etiqueta  ,
                 p_reg.nom_titular_cta          ,
                 p_reg.apellido_contacto        ,
                 p_reg.tip_docum_contacto       ,
                 p_reg.cod_docum_contacto       ,
                 p_reg.cod_nacionalidad_contacto);
    --
 END p_inserta;
 --
 PROCEDURE p_lee_vigente(p_cod_cia    a1000802.cod_cia   %TYPE,
                         p_num_poliza a1000802.num_poliza%TYPE,
                         p_num_spto   a1000802.num_spto  %TYPE,
                         p_num_riesgo a1000802.num_riesgo%TYPE,
                         p_tip_docum  a1000802.tip_docum %TYPE,
                         p_cod_docum  a1000802.cod_docum %TYPE) IS
  --
  l_x_no_existe EXCEPTION;
  PRAGMA        EXCEPTION_INIT(l_x_no_existe,-20001);
  --
  l_num_spto    a1000802.num_spto%TYPE;
  --
 BEGIN
  --
  BEGIN
   --
   p_lee(p_cod_cia   ,
         p_num_poliza,
         p_num_spto  ,
         p_num_riesgo,
         p_tip_docum ,
         p_cod_docum );
   --
  EXCEPTION
   WHEN l_x_no_existe
    THEN
     --
     l_num_spto := em_f_max_spto_a1000802(p_cod_cia   ,
                                          p_num_poliza,
                                          p_num_spto  ,
                                          p_num_riesgo,
                                          p_tip_docum ,
                                          p_cod_docum );
     --
     p_lee(p_cod_cia   ,
           p_num_poliza,
           l_num_spto  ,
           p_num_riesgo,
           p_tip_docum ,
           p_cod_docum );
     --
  END;
  --
 END p_lee_vigente;
 --
 /*-----------------------------------------------------
 || p_borra :
 ||
 || Borra la informacion de un suplemento. Se utiliza
 || cuando se abandona la emision.
 */ -----------------------------------------------------
 --
 PROCEDURE p_borra(p_cod_cia    a1000802.cod_cia   %TYPE,
                   p_num_poliza a1000802.num_poliza%TYPE,
                   p_num_spto   a1000802.num_spto  %TYPE) IS
 BEGIN
  --
  DELETE FROM a1000802
   WHERE cod_cia    = p_cod_cia
     AND num_poliza = p_num_poliza
     AND num_spto   = p_num_spto;
  --
 END p_borra;
 --
END em_k_a1000802_trn;

