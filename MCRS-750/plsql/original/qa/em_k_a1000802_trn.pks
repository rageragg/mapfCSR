create or replace PACKAGE em_k_a1000802_trn AS
 --
 /* -------------------- DESCRIPCION --------------------
 || Trata la Tabla : A1000802
 */ -----------------------------------------------------
 --
 /* -------------------- VERSION = 1.07 -------------------- */
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
 */ --------------------------------------------------------
 --
 PROCEDURE p_lee(
                 p_cod_cia a1000802.cod_cia%TYPE,
                 p_num_poliza a1000802.num_poliza%TYPE,
                 p_num_spto a1000802.num_spto%TYPE,
                 p_num_riesgo a1000802.num_riesgo%TYPE,
                 p_tip_docum a1000802.tip_docum%TYPE,
                 p_cod_docum a1000802.cod_docum%TYPE);
 /* -------------------- DESCRIPCION --------------------
 || Lee el registro
 */ -----------------------------------------------------
 --
 PROCEDURE p_lee_vigente(p_cod_cia    a1000802.cod_cia   %TYPE,
                         p_num_poliza a1000802.num_poliza%TYPE,
                         p_num_spto   a1000802.num_spto  %TYPE,
                         p_num_riesgo a1000802.num_riesgo%TYPE,
                         p_tip_docum  a1000802.tip_docum %TYPE,
                         p_cod_docum  a1000802.cod_docum %TYPE);
 /* -------------------- DESCRIPCION --------------------
 || Lee el registro del ultimo suplemento vigente. Es
 || utilizado en emsion (suplementos)
 */ -----------------------------------------------------
 --
 FUNCTION f_cod_pais RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_cod_estado RETURN NUMBER;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_cod_prov RETURN NUMBER;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_cod_localidad RETURN NUMBER;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_nom_localidad RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_tip_domicilio RETURN NUMBER;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_nom_domicilio1 RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_nom_domicilio2 RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_nom_domicilio3 RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_cod_postal RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_num_apartado RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_tlf_pais RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_tlf_zona RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_tlf_numero RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_fax_numero RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_email RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_txt_etiqueta1 RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_txt_etiqueta2 RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_txt_etiqueta3 RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_txt_etiqueta4 RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_txt_etiqueta5 RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_txt_email RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_nom_contacto RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_tip_cargo RETURN NUMBER;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_cod_entidad RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_cod_oficina RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_nom_titular_cta
    RETURN a1000802.nom_titular_cta%TYPE;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_cta_cte RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_cta_dc RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_cod_compensacion RETURN NUMBER;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_tip_tarjeta RETURN NUMBER;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_cod_tarjeta RETURN NUMBER;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_num_tarjeta RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_obs_asegurado RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_cod_pais_etiqueta RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_cod_estado_etiqueta RETURN NUMBER;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_cod_prov_etiqueta RETURN NUMBER;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_cod_postal_etiqueta RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_num_apartado_etiqueta RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_cod_localidad_etiqueta RETURN NUMBER;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_nom_localidad_etiqueta RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_tip_etiqueta RETURN NUMBER;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_fec_vcto_tarjeta RETURN DATE;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_num_secu_cta RETURN NUMBER;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_atr_domicilio1 RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_atr_domicilio2 RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_atr_domicilio3 RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_atr_domicilio4 RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_atr_domicilio5 RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_anx_domicilio RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_ext_cod_postal RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_tlf_extension RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_nom_empresa_com RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_atr_domicilio1_com RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_atr_domicilio2_com RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_atr_domicilio3_com RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_atr_domicilio4_com RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_atr_domicilio5_com RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_anx_domicilio_com RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_ext_cod_postal_com RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_tlf_extension_com RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 FUNCTION f_ext_cod_postal_etiqueta RETURN VARCHAR2;
 /* -------------------- DESCRIPCION --------------------
 || Devuelve la columna indicada en el nombre
 */ -----------------------------------------------------
 --
 CURSOR c_a1000802(
                   pl_cod_cia a1000802.cod_cia%TYPE,
                   pl_num_poliza a1000802.num_poliza%TYPE,
                   pl_num_spto a1000802.num_spto%TYPE,
                   pl_num_riesgo a1000802.num_riesgo%TYPE,
                   pl_tip_docum a1000802.tip_docum%TYPE,
                   pl_cod_docum a1000802.cod_docum%TYPE) IS
        SELECT *
          FROM a1000802
         WHERE cod_cia = pl_cod_cia
           AND num_poliza = pl_num_poliza
           AND num_spto = pl_num_spto
           AND num_riesgo = pl_num_riesgo
           AND tip_docum = pl_tip_docum
           AND cod_docum = pl_cod_docum
               ;
 --
 reg a1000802%ROWTYPE;
 --
 /* --------------------------------------------------
 || Devuelve el valor de la columna apellido_contacto
 */ --------------------------------------------------
 --
 FUNCTION f_apellido_contacto
    RETURN a1000802.apellido_contacto%TYPE;
 --
 /* --------------------------------------------------
 || Devuelve el valor de la columna tip_docum_contacto
 */ --------------------------------------------------
 --
 FUNCTION f_tip_docum_contacto
    RETURN a1000802.tip_docum_contacto%TYPE;
 --
 /* --------------------------------------------------
 || Devuelve el valor de la columna cod_docum_contacto
 */ --------------------------------------------------
 --
 FUNCTION f_cod_docum_contacto
    RETURN a1000802.cod_docum_contacto%TYPE;
 --
 /* --------------------------------------------------
 || Devuelve el valor de la columna cod_nacionalidad_contacto
 */ --------------------------------------------------
 --
 FUNCTION f_cod_nacionalidad_contacto
    RETURN a1000802.cod_nacionalidad_contacto%TYPE;
 --
 /* --------------------------------------------------
 || Procedimiento para insertar un registro en la tabla
 || a1000802.
 */ --------------------------------------------------
 --
 PROCEDURE p_inserta(p_reg IN     a1000802%ROWTYPE);
 --
 PROCEDURE p_borra(p_cod_cia    a1000802.cod_cia   %TYPE,
                   p_num_poliza a1000802.num_poliza%TYPE,
                   p_num_spto   a1000802.num_spto  %TYPE);
 --
 /* -------------------- DESCRIPCION --------------------
 || Borra la informacion de un suplemento. Se utiliza
 || cuando se abandona la emision.
 */ -----------------------------------------------------
 --
END em_k_a1000802_trn;

