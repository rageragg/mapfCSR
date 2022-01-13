create or replace PACKAGE dc_k_terceros_trn
AS
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el campo elegido de las tablas de la estructura
   ||  de terceros dependiendo del codigo de actividad
   */ -----------------------------------------------------
   --
   /* -------------------- VERSION = 1.42 ------------------- */
   --
   /* -------------------- MODIFICACIONES ----------------------------------------
   || 2016/11/10 - HSOLIVE - 1.42 - (MU-2016-069005)
   || Se añaden las funciones para cada uno de los campos nuevos de la A1001331
   */ ----------------------------------------------------------------------------
   --
   TYPE t_reg_ctas IS RECORD
     ( num_secu_cta_tar  a1002201.num_secu_cta_tar  %TYPE,
       cod_entidad       a1002201.cod_entidad       %TYPE,
       cod_oficina       a1002201.cod_oficina       %TYPE,
       cta_dc            a1002201.cta_dc            %TYPE,
       cta_cte           a1002201.cta_cte           %TYPE
     );
   --
   TYPE t_tab_ctas IS TABLE OF t_reg_ctas INDEX BY BINARY_INTEGER;
   --
   PROCEDURE p_lee(p_cod_cia         a1001300.cod_cia        %TYPE,
                   p_tip_docum       a1001300.tip_docum      %TYPE,
                   p_cod_docum       a1001300.cod_docum      %TYPE,
                   p_cod_tercero     a1001300.cod_tercero    %TYPE,
                   p_fec_validez     a1001300.fec_validez    %TYPE,
                   p_cod_act_tercero a1001300.cod_act_tercero%TYPE);
   /* -------------------- DESCRIPCION --------------------
   || Lee el registro de la tabla correspondiente
   */ -----------------------------------------------------
   --
   PROCEDURE p_lee(p_cod_cia          a1001300.cod_cia         %TYPE,
                   p_tip_docum        a1001300.tip_docum       %TYPE,
                   p_cod_docum        a1001300.cod_docum       %TYPE,
                   p_cod_tercero      a1001300.cod_tercero     %TYPE,
                   p_fec_validez      a1001300.fec_validez     %TYPE,
                   p_cod_act_tercero  a1001300.cod_act_tercero %TYPE,
                   p_num_secu_cta_tar a1002201.num_secu_cta_tar%TYPE);
   /* -------------------- DESCRIPCION --------------------
   || Lee el registro de la tabla correspondiente, por si hay
   || multicuenta recuperar una de ellas.
   */ -----------------------------------------------------
   --
   PROCEDURE p_lee_nom_completo(p_cod_cia         a1001300.cod_cia        %TYPE,
                                p_tip_docum       a1001300.tip_docum      %TYPE,
                                p_cod_docum       a1001300.cod_docum      %TYPE,
                                p_cod_tercero     a1001300.cod_tercero    %TYPE,
                                p_fec_validez     a1001300.fec_validez    %TYPE,
                                p_cod_act_tercero a1001300.cod_act_tercero%TYPE);
   /* -------------------- DESCRIPCION --------------------
   || Lee el registro de la tabla correspondiente mas la vista v1001390
   */ -----------------------------------------------------
   --
   --
   PROCEDURE p_lee_nom_completo(p_cod_cia          a1001300.cod_cia         %TYPE,
                                p_tip_docum        a1001300.tip_docum       %TYPE,
                                p_cod_docum        a1001300.cod_docum       %TYPE,
                                p_cod_tercero      a1001300.cod_tercero     %TYPE,
                                p_fec_validez      a1001300.fec_validez     %TYPE,
                                p_cod_act_tercero  a1001300.cod_act_tercero %TYPE,
                                p_num_secu_cta_tar a1002201.num_secu_cta_tar%TYPE);
   /* -------------------- DESCRIPCION --------------------
   || Lee el registro de la tabla correspondiente mas la vista v1001390
   */ -----------------------------------------------------
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   --
   PROCEDURE p_lee_con_poliza(p_cod_cia         a1001300.cod_cia        %TYPE,
                              p_tip_docum       a1001300.tip_docum      %TYPE,
                              p_cod_docum       a1001300.cod_docum      %TYPE,
                              p_cod_tercero     a1001300.cod_tercero    %TYPE,
                              p_fec_validez     a1001300.fec_validez    %TYPE,
                              p_cod_act_tercero a1001300.cod_act_tercero%TYPE,
                              p_num_poliza      a1000802.num_poliza     %TYPE,
                              p_num_spto        a1000802.num_spto       %TYPE,
                              p_num_riesgo      a1000802.num_riesgo     %TYPE);
   /* -------------------- DESCRIPCION --------------------
   || Lee el registro completo de la tabla, en caso de ser asegurado
   || comprueba si existen modificaciones locales.
   */ -----------------------------------------------------
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   --
   PROCEDURE p_lee_con_poliza(p_cod_cia          a1001300.cod_cia          %TYPE,
                              p_tip_docum        a1001300.tip_docum        %TYPE,
                              p_cod_docum        a1001300.cod_docum        %TYPE,
                              p_cod_tercero      a1001300.cod_tercero      %TYPE,
                              p_fec_validez      a1001300.fec_validez      %TYPE,
                              p_cod_act_tercero  a1001300.cod_act_tercero  %TYPE,
                              p_num_poliza       a1000802.num_poliza       %TYPE,
                              p_num_spto         a1000802.num_spto         %TYPE,
                              p_num_riesgo       a1000802.num_riesgo       %TYPE,
                              p_num_secu_cta_tar a1002201.num_secu_cta_tar %TYPE);
   --
   /* --------------------------------------------------------
   || Lee el registro completo de la tabla, en caso de ser asegurado
   || comprueba si existen modificaciones locales con la opci?n de
   || enviar el c?digo de secuencia de la cuenta bancaria del tercero.
   */ -----------------------------------------------------
   --
   PROCEDURE p_nom_fec_nac(p_cod_cia         IN a1001331.cod_cia       %TYPE,
                           p_tip_docum       IN a1001331.tip_docum     %TYPE,
                           p_cod_docum       IN a1001331.cod_docum     %TYPE,
                           p_nom_tercero    OUT a1001399.nom_tercero   %TYPE,
                           p_nom2_tercero   OUT a1001399.nom2_tercero  %TYPE,
                           p_ape1_tercero   OUT a1001399.ape1_tercero  %TYPE,
                           p_ape2_tercero   OUT a1001399.ape2_tercero  %TYPE,
                           p_nom_sufijo     OUT g1010031.nom_valor     %TYPE,
                           p_fec_nacimiento OUT a1001331.fec_nacimiento%TYPE);
   /* -------------------- DESCRIPCION --------------------
   || Devuelve la informaci?n del tomador: nombres, apellidos
   || y fecha de nacimiento.
   */ -----------------------------------------------------
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   --
   FUNCTION f_cod_nacionalidad RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   FUNCTION f_tip_domicilio RETURN NUMBER;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_nom_domicilio1 RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_nom_domicilio2 RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_nom_domicilio3 RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_num_apartado RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - 01/09/25
   || Creacion
   */ -----------------------------------------------------
   FUNCTION f_txt_etiqueta1 RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_txt_etiqueta2 RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_txt_etiqueta3 RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_txt_etiqueta4 RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_txt_etiqueta5 RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_cod_localidad RETURN NUMBER;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Belen     - 99/02/08
   || Se a?ade el campo :
   || - cod_localidad.
   */ --------------------------------------------------------
   FUNCTION f_nom_localidad RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_cod_pais RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_cod_prov RETURN NUMBER;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_cod_estado RETURN NUMBER;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_cod_postal RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_tlf_pais RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_tlf_zona RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_tlf_numero RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_cod_pais_com RETURN VARCHAR2;
   FUNCTION f_cod_estado_com RETURN NUMBER;
   FUNCTION f_cod_prov_com RETURN NUMBER;
   FUNCTION f_cod_localidad_com RETURN NUMBER;
   FUNCTION f_cod_postal_com RETURN VARCHAR2;
   FUNCTION f_tip_domicilio_com RETURN NUMBER;
   FUNCTION f_nom_domicilio1_com RETURN VARCHAR2;
   FUNCTION f_nom_domicilio2_com RETURN VARCHAR2;
   FUNCTION f_nom_domicilio3_com RETURN VARCHAR2;
   FUNCTION f_nom_localidad_com RETURN VARCHAR2;
   FUNCTION f_num_apartado_com RETURN VARCHAR2;
   FUNCTION f_tlf_pais_com RETURN VARCHAR2;
   FUNCTION f_tlf_zona_com RETURN VARCHAR2;
   FUNCTION f_tlf_numero_com RETURN VARCHAR2;
   FUNCTION f_fax_numero_com RETURN VARCHAR2;
   FUNCTION f_tlf_movil RETURN VARCHAR2;
   FUNCTION f_email_com RETURN VARCHAR2;
   FUNCTION f_email RETURN VARCHAR2;
   FUNCTION f_txt_email RETURN VARCHAR2;
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_fec_nacimiento RETURN DATE;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_mca_sexo RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_cod_est_civil RETURN VARCHAR2;
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_cod_agt RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_cod_profesion RETURN NUMBER;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_cod_ocupacion RETURN NUMBER;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_tip_tercero RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   --
   FUNCTION f_tip_agt RETURN VARCHAR2;
   --
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_mca_inh RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_txt_aux1 RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_txt_aux2 RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_txt_aux3 RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_cod_nivel3 RETURN NUMBER;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_cod_canal3 RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_cod_reten RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_cod_compensacion RETURN NUMBER;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_cod_imptos_dep RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES -------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_cod_imptos_renta RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || Usuario   - AA/MM/DD
   || Comentario
   */ --------------------------------------------------------
   FUNCTION f_tip_cia_rea RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || C.Rguez  - 98/02/24
   || Se crea esta funcion
   */ --------------------------------------------------------
   FUNCTION f_tip_broker RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   FUNCTION f_fax_numero RETURN VARCHAR2;
   /* -------------------- MODIFICACIONES --------------------
   || C.Rguez  - 98/02/24
   || Se crea esta funcion
   */ --------------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || David    - 98/09/24
   || Se crea esta funcion
   */ --------------------------------------------------------
   FUNCTION f_cod_entidad RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || David    - 98/09/24
   || Se crea esta funcion
   */ --------------------------------------------------------
   FUNCTION f_cod_oficina RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   FUNCTION f_nom_titular_cta
      RETURN a1001331.nom_titular_cta%TYPE;
   --
   /* -------------------- MODIFICACIONES --------------------
   || David    - 98/09/24
   || Se crea esta funcion
   */ --------------------------------------------------------
   FUNCTION f_cta_cte RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || David    - 98/09/24
   || Se crea esta funcion
   */ --------------------------------------------------------
   FUNCTION f_cta_dc RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || David    - 98/09/24
   || Se crea esta funcion
   */ --------------------------------------------------------
   FUNCTION f_tip_tarjeta RETURN NUMBER;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || David    - 98/09/24
   || Se crea esta funcion
   */ --------------------------------------------------------
   FUNCTION f_cod_tarjeta RETURN NUMBER;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   /* -------------------- MODIFICACIONES --------------------
   || David    - 98/09/24
   || Se crea esta funcion
   */ --------------------------------------------------------
   FUNCTION f_num_tarjeta RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   FUNCTION f_cod_prov_etiqueta RETURN NUMBER;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 99/02/01
   || Se a?aden los campos :
   || - cod_localidad_etiqueta
   || - nom_localidad_etiqueta
   */ --------------------------------------------------------
   FUNCTION f_cod_localidad_etiqueta RETURN NUMBER;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 99/02/01
   || Se a?aden los campos :
   || - cod_localidad_etiqueta
   || - nom_localidad_etiqueta
   */ --------------------------------------------------------
   FUNCTION f_nom_localidad_etiqueta RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   FUNCTION f_cod_grp_tercero RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   -- --------------------------------------------------------------
   -- Validaci?n de los datos referentes al domicilio
   -- --------------------------------------------------------------
   --
   /**
   || Validacion del campo:tip_domicilio
   */
   PROCEDURE p_v_tip_domicilio(p_tip_domicilio     IN a1001300.tip_domicilio %TYPE,
                               p_nom_tip_domicilio IN OUT g1010031.nom_valor %TYPE);
   /**
   || Validacion del campo:nom_domicilio1
   */
   PROCEDURE p_v_nom_domicilio1(p_nom_domicilio1 IN a1001300.nom_domicilio1 %TYPE);
   /**
   || Validacion del campo:nom_domicilio2
   */
   PROCEDURE p_v_nom_domicilio2(p_nom_domicilio2 IN a1001300.nom_domicilio2 %TYPE);
   /**
   || Validacion del campo:nom_domicilio3
   */
   PROCEDURE p_v_nom_domicilio3(p_nom_domicilio3 IN a1001300.nom_domicilio3 %TYPE);
   /**
   || Validacion del campo:cod_pais
   */
   PROCEDURE p_v_cod_pais(p_cod_pais     IN a1001300.cod_pais     %TYPE,
                          p_nom_cod_pais IN OUT a1000101.nom_pais %TYPE);
   /**
   || Validacion del campo:cod_estado
   */
   PROCEDURE p_v_cod_estado(p_cod_pais   IN a1001300.cod_pais       %TYPE,
                            p_cod_estado IN a1001300.cod_estado     %TYPE,
                            p_nom_estado IN OUT a1000104.nom_estado %TYPE);
   /**
   || Validacion del campo:cod_prov
   */
   PROCEDURE p_v_cod_prov(p_cod_pais   IN a1001300.cod_pais     %TYPE,
                          p_cod_estado IN a1001300.cod_estado   %TYPE,
                          p_cod_prov   IN a1001300.cod_prov     %TYPE,
                          p_nom_prov   IN OUT a1000100.nom_prov %TYPE);
   /**
   || Validacion del campo:cod_postal
   */
   --
   PROCEDURE p_v_cod_postal(p_cod_pais               IN OUT a1001300.cod_pais      %TYPE,
                            p_mca_inh_cod_pais       IN OUT VARCHAR2                    ,
                            p_cod_estado             IN OUT a1001300.cod_estado    %TYPE,
                            p_mca_inh_cod_estado     IN OUT VARCHAR2                    ,
                            p_cod_prov               IN OUT a1001300.cod_prov      %TYPE,
                            p_mca_inh_cod_prov       IN OUT VARCHAR2                    ,
                            p_cod_localidad          IN OUT a1001300.cod_localidad %TYPE,
                            p_mca_inh_cod_localidad  IN OUT VARCHAR2                    ,
                            p_nom_localidad          IN OUT a1001300.nom_localidad %TYPE,
                            p_mca_inh_nom_localidad  IN OUT VARCHAR2                    ,
                            p_tip_domicilio          IN OUT a1001300.tip_domicilio %TYPE,
                            p_mca_inh_tip_domicilio  IN OUT VARCHAR2                    ,
                            p_nom_domicilio1         IN OUT a1001300.nom_domicilio1%TYPE,
                            p_mca_inh_nom_domicilio1 IN OUT VARCHAR2                    ,
                            p_nom_domicilio2         IN OUT a1001300.nom_domicilio2%TYPE,
                            p_mca_inh_nom_domicilio2 IN OUT VARCHAR2                    ,
                            p_nom_domicilio3         IN OUT a1001300.nom_domicilio3%TYPE,
                            p_mca_inh_nom_domicilio3 IN OUT VARCHAR2                    ,
                            p_cod_postal             IN OUT a1001300.cod_postal    %TYPE,
                            p_mca_inh_cod_postal     IN OUT VARCHAR2                    ,
                            p_nom_estado             IN OUT a1000104.nom_estado    %TYPE,
                            p_mca_inh_nom_estado     IN OUT VARCHAR2                    ,
                            p_nom_prov               IN OUT a1000100.nom_prov      %TYPE,
                            p_mca_inh_nom_prov       IN OUT VARCHAR2                    );
   --
   /**
   || Validacion del campo:num_apartado
   */
   PROCEDURE p_v_num_apartado(p_num_apartado IN a1001300.num_apartado %TYPE);
   /**
   || Validacion del campo:cod_localidad
   */
   PROCEDURE p_v_cod_localidad(p_cod_pais      IN a1001300.cod_pais          %TYPE,
                               p_cod_prov      IN a1001300.cod_prov          %TYPE,
                               p_cod_localidad IN a1001300.cod_localidad     %TYPE,
                               p_nom_localidad IN OUT a1000102.nom_localidad %TYPE);
   /**
   || Validacion del campo:nom_localidad
   */
   PROCEDURE p_v_nom_localidad(p_nom_localidad IN a1001300.nom_localidad %TYPE);
   /**
   || Validacion del campo:txt_etiqueta1
   */
   PROCEDURE p_v_txt_etiqueta1(p_txt_etiqueta1 IN a1001300.txt_etiqueta1 %TYPE);
   /**
   || Validacion del campo:txt_etiqueta2
   */
   PROCEDURE p_v_txt_etiqueta2(p_txt_etiqueta2 IN a1001300.txt_etiqueta2 %TYPE);
   /**
   || Validacion del campo:txt_etiqueta3
   */
   PROCEDURE p_v_txt_etiqueta3(p_txt_etiqueta3 IN a1001300.txt_etiqueta3 %TYPE);
   /**
   || Validacion del campo:txt_etiqueta4
   */
   PROCEDURE p_v_txt_etiqueta4(p_txt_etiqueta4 IN a1001300.txt_etiqueta4 %TYPE);
   /**
   || Validacion del campo:txt_etiqueta5
   */
   PROCEDURE p_v_txt_etiqueta5(p_txt_etiqueta5 IN a1001300.txt_etiqueta5 %TYPE);
   /**
   || Validacion del campo:txt_email
   */
   PROCEDURE p_v_txt_email(p_txt_email IN a1001300.txt_email %TYPE);
   /* -----------------------------------------------------
   || Validacion de la entidad bancaria
   */-----------------------------------------------------
   PROCEDURE p_v_cod_entidad(p_cod_entidad   IN a5020900.cod_entidad %TYPE,
                             p_nom_entidad   OUT a5020900.nom_entidad%TYPE,
                             p_cod_error     OUT g1010020.cod_mensaje%TYPE,
                             p_texto_mensaje OUT VARCHAR2);
   /* -----------------------------------------------------
   || Validacion de la oficina de una entidad bancaria
   */-----------------------------------------------------
   PROCEDURE p_v_cod_oficina(p_cod_entidad   IN a5020900.cod_entidad %TYPE,
                             p_cod_oficina   IN a5020910.cod_oficina %TYPE,
                             p_nom_oficina   OUT a5020910.nom_oficina%TYPE,
                             p_cod_error     OUT g1010020.cod_mensaje%TYPE,
                             p_texto_mensaje OUT VARCHAR2);
   --
   /* -----------------------------------------------------
   || Validacion de la cuenta corriente
   */ -----------------------------------------------------
   PROCEDURE p_v_cta_cte(p_cod_entidad   IN a5020900.cod_entidad %TYPE,
                         p_cod_oficina   IN a5020910.cod_oficina %TYPE,
                         p_cta_cte       IN a1001300.cta_cte     %TYPE,
                         p_cod_error     OUT g1010020.cod_mensaje%TYPE,
                         p_texto_mensaje OUT VARCHAR2);
   /* -----------------------------------------------------
   || Validacion del digito de control
   */ -----------------------------------------------------
   PROCEDURE p_v_cta_dc(p_cod_entidad   IN a5020900.cod_entidad  %TYPE,
                        p_cod_oficina   IN a5020910.cod_oficina  %TYPE,
                        p_cta_cte       IN  a1001300.cta_cte     %TYPE,
                        p_cta_dc        IN a1001300.cta_dc       %TYPE,
                        p_cod_error     OUT g1010020.cod_mensaje %TYPE,
                        p_texto_mensaje OUT VARCHAR2);
  /*--------------------------------------------------------------------------------
   || Valida la cuenta corriente, codigos separados
   */--------------------------------------------------------------------------------
   PROCEDURE p_val_cuenta_corriente ( p_cod_entidad  IN a1002201.cod_entidad %TYPE,
                                      p_cod_oficina  IN a1002201.cod_oficina %TYPE,
                                      p_cta_dc       IN a1002201.cta_dc      %TYPE,
                                      p_cta_cte      IN a1002201.cta_cte     %TYPE);
   /*------------------------------------------------------------------------------
   || Valida la cuenta corriente, 20 posiciones
   */------------------------------------------------------------------------------
   PROCEDURE p_val_cuenta_corriente(p_cta_cte       IN VARCHAR2  );
   /*------------------------------------------------------------------------------
   || Valida la cuenta e inserta el registro
   */------------------------------------------------------------------------------
   FUNCTION f_val_graba_cuenta ( p_cod_cia          IN a1002201.cod_cia         %TYPE,
                                 p_tip_docum        IN a1002201.tip_docum       %TYPE,
                                 p_cod_docum        IN a1002201.cod_docum       %TYPE,
                                 p_cod_act_tercero  IN a1002201.cod_act_tercero %TYPE,
                                 p_cod_tercero      IN a1002201.cod_tercero     %TYPE,
                                 p_cod_pais         IN a1002201.cod_pais        %TYPE,
                                 p_tip_cta_tar      IN a1002201.tip_cta_tar     %TYPE,
                                 p_cod_entidad      IN a1002201.cod_entidad     %TYPE,
                                 p_cod_oficina      IN a1002201.cod_oficina     %TYPE,
                                 p_cta_cte          IN a1002201.cta_cte         %TYPE,
                                 p_cta_dc           IN a1002201.cta_dc          %TYPE,
                                 p_tip_cta_cte      IN a1002201.tip_cta_cte     %TYPE,
                                 p_cod_mon_cta_tar  IN a1002201.cod_mon_cta_tar %TYPE,
                                 p_cod_uso_cta_tar  IN a1002201.cod_uso_cta_tar %TYPE)
   RETURN NUMBER;
   /*
   ||
   ||     Definicion de cursores.
   ||
   /* -------------------- MODIFICACIONES --------------------
   || Marta     - 99/05/21
   || Se a?aden la actividad como parametro y en el where, ya que en esta tabla
   || se pueden grabar varias actividades.
   ||
   */ --------------------------------------------------------
   CURSOR c_a1001300_1(pl_cod_cia a1001300.cod_cia                %TYPE,
                       pl_tip_docum a1001300.tip_docum            %TYPE,
                       pl_cod_docum a1001300.cod_docum            %TYPE,
                       pl_cod_act_tercero a1001300.cod_act_tercero%TYPE,
                       pl_fec_validez a1001300.fec_validez        %TYPE) IS
      SELECT *
      /*
                                                            SELECT cod_cia          , tip_docum          , cod_docum         ,
                                                                   cod_tercero      ,
                                                                   tip_domicilio    , nom_domicilio1     , nom_domicilio2    ,
                                                                   nom_domicilio3   , nom_localidad      , cod_pais          ,
                                                                   cod_prov         , cod_localidad      ,
                                                                   cod_postal       , cod_estado         ,
                                                                   txt_etiqueta1    , txt_etiqueta2      , txt_etiqueta3     ,
                                                                   txt_etiqueta4    , txt_etiqueta5      , fax_numero        ,
                                                                   tlf_pais         , tlf_zona           , tlf_numero        ,
                                                                   fec_nacimiento   , mca_sexo           , cod_est_civil     ,
                                                                   cod_profesion    , txt_aux1           , txt_aux2          ,
                                                                   fec_validez      , mca_inh            ,
                                                                   tlf_pais_com     , tlf_zona_com       , tlf_numero_com    ,
                                                                   fax_numero_com   , email_com          , cod_compensacion
                                                      */
        FROM a1001300
       WHERE cod_cia = pl_cod_cia
         AND tip_docum = pl_tip_docum
         AND cod_docum = pl_cod_docum
         AND cod_act_tercero = pl_cod_act_tercero
         AND fec_validez = pl_fec_validez;
   --
   CURSOR c_a1001300_2(pl_cod_cia a1001300.cod_cia               %TYPE,
                      pl_cod_tercero a1001300.cod_tercero        %TYPE,
                      pl_cod_act_tercero a1001300.cod_act_tercero%TYPE,
                      pl_fec_validez a1001300.fec_validez        %TYPE) IS
      SELECT *
      /*
                                                            SELECT cod_cia          , tip_docum          , cod_docum         ,
                                                                   cod_tercero      ,
                                                                   tip_domicilio    , nom_domicilio1     , nom_domicilio2    ,
                                                                   nom_domicilio3   , nom_localidad      , cod_pais          ,
                                                                   cod_prov         , cod_localidad      ,
                                                                   cod_postal       , cod_estado         ,
                                                                   txt_etiqueta1    , txt_etiqueta2      , txt_etiqueta3     ,
                                                                   txt_etiqueta4    , txt_etiqueta5      , fax_numero        ,
                                                                   tlf_pais         , tlf_zona           , tlf_numero        ,
                                                                   fec_nacimiento   , mca_sexo           , cod_est_civil     ,
                                                                   cod_profesion    , txt_aux1           , txt_aux2          ,
                                                                   fec_validez      , mca_inh            ,
                                                                   tlf_pais_com     , tlf_zona_com       , tlf_numero_com    ,
                                                                   fax_numero_com   , email_com          , cod_compensacion
                                                      */
        FROM a1001300
       WHERE cod_cia = pl_cod_cia
         AND cod_tercero = pl_cod_tercero
         AND cod_act_tercero = pl_cod_act_tercero
         AND fec_validez = pl_fec_validez;
   --
   CURSOR c_a1001331(pl_cod_cia a1001331.cod_cia    %TYPE,
                     pl_tip_docum a1001331.tip_docum%TYPE,
                     pl_cod_docum a1001331.cod_docum%TYPE) IS
      SELECT *
      /*
                                                            SELECT cod_cia            , tip_docum          , cod_docum         ,
                                                                   tip_domicilio      , nom_domicilio1     , nom_domicilio2    ,
                                                                   nom_domicilio3     , nom_localidad      , cod_pais          ,
                                                                   cod_prov           , cod_localidad      ,
                                                                   cod_postal         , cod_estado         ,
                                                                   txt_etiqueta1      , txt_etiqueta2      , txt_etiqueta3     ,
                                                                   txt_etiqueta4      , txt_etiqueta5      , fax_numero        ,
                                                                   tlf_pais           , tlf_zona           , tlf_numero        ,
                                                                   fec_nacimiento     , mca_sexo           , cod_est_civil     ,
                                                                   cod_profesion      , cod_ocupacion      , cod_entidad       ,
                                                                   cod_oficina        , cta_cte            , cta_dc            ,
                                                                   tip_tarjeta        , cod_tarjeta        , num_tarjeta       ,
                                                                   cod_localidad_etiqueta ,
                                                                   nom_localidad_etiqueta ,
                                                                   tip_domicilio_com  , nom_domicilio1_com , nom_domicilio2_com,
                                                                   nom_domicilio3_com , nom_localidad_com  , cod_pais_com      ,
                                                                   cod_prov_com       , cod_postal_com     ,
                                                                   tlf_pais_com       , tlf_zona_com       , tlf_numero_com    ,
                                                                   fax_numero_com     , email_com          , cod_estado_com    ,
                                                                   num_apartado_com   , cod_localidad_com  , txt_aux1
                                                      */
        FROM a1001331
       WHERE cod_cia = pl_cod_cia
         AND tip_docum = pl_tip_docum
         AND cod_docum = pl_cod_docum;
   --
   CURSOR c_a1001332_1(pl_cod_cia a1001332.cod_cia        %TYPE,
                       pl_tip_docum a1001332.tip_docum    %TYPE,
                       pl_cod_docum a1001332.cod_docum    %TYPE,
                       pl_fec_validez a1001332.fec_validez%TYPE) IS
      SELECT *
      /*
                                                            SELECT cod_cia          , tip_docum          , cod_docum         ,
                                                                   cod_agt          ,
                                                                   tip_domicilio    , nom_domicilio1     , nom_domicilio2    ,
                                                                   nom_domicilio3   , nom_localidad      , cod_pais          ,
                                                                   cod_prov         , cod_localidad      ,
                                                                   cod_postal       , cod_estado         ,
                                                                   txt_etiqueta1    , txt_etiqueta2      , txt_etiqueta3     ,
                                                                   txt_etiqueta4    , txt_etiqueta5      ,
                                                                   tlf_pais         , tlf_zona           , tlf_numero        ,
                                                                   fec_validez      , mca_inh            , txt_aux1          ,
                                                                   NVL(txt_aux2, 'N') txt_aux2           , tip_agt           ,
                                                                   cod_nivel3       , cod_reten          , cod_compensacion  ,
                                                                   tlf_pais_com     , tlf_zona_com       , tlf_numero_com    ,
                                                                   fax_numero_com   , email_com
                                                      */
        FROM a1001332
       WHERE cod_cia = pl_cod_cia
         AND tip_docum = pl_tip_docum
         AND cod_docum = pl_cod_docum
         AND fec_validez = pl_fec_validez;
   --
   CURSOR c_a1001332_2(pl_cod_cia a1001332.cod_cia        %TYPE,
                       pl_cod_tercero a1001332.cod_agt    %TYPE,
                       pl_fec_validez a1001332.fec_validez%TYPE) IS
      SELECT *
      /*
                                                            SELECT cod_cia          , tip_docum          , cod_docum         ,
                                                                   cod_agt          ,
                                                                   tip_domicilio    , nom_domicilio1     , nom_domicilio2    ,
                                                                   nom_domicilio3   , nom_localidad      , cod_pais          ,
                                                                   cod_prov         , cod_localidad      ,
                                                                   cod_postal       , cod_estado         ,
                                                                   txt_etiqueta1    , txt_etiqueta2      , txt_etiqueta3     ,
                                                                   txt_etiqueta4    , txt_etiqueta5      ,
                                                                   tlf_pais         , tlf_zona           , tlf_numero        ,
                                                                   fec_validez      , mca_inh            , txt_aux1          ,
                                                                   NVL(txt_aux2, 'N') txt_aux2           , tip_agt           ,
                                                                   cod_nivel3       , cod_reten          , cod_compensacion  ,
                                                                   tlf_pais_com     , tlf_zona_com       , tlf_numero_com    ,
                                                                   fax_numero_com   , email_com
                                                      */
        FROM a1001332
       WHERE cod_cia = pl_cod_cia
         AND cod_agt = pl_cod_tercero
         AND fec_validez = pl_fec_validez;
   --
   CURSOR c_a1001338(pl_cod_cia a1001338.cod_cia        %TYPE,
                     pl_tip_docum a1001338.tip_docum    %TYPE,
                     pl_cod_docum a1001338.cod_docum    %TYPE,
                     pl_fec_validez a1001338.fec_validez%TYPE) IS
      SELECT *
      /*
                                                            SELECT cod_cia          , tip_docum          , cod_docum         ,
                                                                   tip_domicilio    , nom_domicilio1     , nom_domicilio2    ,
                                                                   nom_localidad    , cod_pais           ,
                                                                   cod_prov         , cod_postal         ,
                                                                   cod_localidad    , cod_estado         ,
                                                                   tlf_pais         , tlf_zona           , tlf_numero        ,
                                                                   fec_validez
                                                      */
        FROM a1001338
       WHERE cod_cia = pl_cod_cia
         AND tip_docum = pl_tip_docum
         AND cod_docum = pl_cod_docum
         AND fec_validez = pl_fec_validez;
   --
   CURSOR c_a1001338_1(pl_cod_cia a1001338.cod_cia           %TYPE,
                       pl_cod_tercero a1001338.cod_supervisor%TYPE,
                       pl_fec_validez a1001338.fec_validez   %TYPE) IS
      SELECT *
      /*
                                                            SELECT cod_cia          , tip_docum          , cod_docum         ,
                                                                   tip_domicilio    , nom_domicilio1     , nom_domicilio2    ,
                                                                   nom_localidad    , cod_pais           ,
                                                                   cod_prov         , cod_postal         ,
                                                                   cod_localidad    , cod_estado         ,
                                                                   tlf_pais         , tlf_zona           , tlf_numero        ,
                                                                   fec_validez
                                                      */
        FROM a1001338
       WHERE cod_cia = pl_cod_cia
         AND cod_supervisor = pl_cod_tercero
         AND fec_validez = pl_fec_validez;
   --
   CURSOR c_a1001339(pl_cod_cia a1001338.cod_cia    %TYPE,
                     pl_tip_docum a1001338.tip_docum%TYPE,
                     pl_cod_docum a1001338.cod_docum%TYPE) IS
      SELECT *
      /*
                                                            SELECT cod_cia          , tip_docum          , cod_docum         ,
                                                                   tip_domicilio    , nom_domicilio1     , nom_domicilio2    ,
                                                                   nom_localidad    , cod_pais           ,
                                                                   cod_prov         , cod_postal         ,
                                                                   cod_localidad    , cod_estado         ,
                                                                   tlf_pais         , tlf_zona           , tlf_numero
                                                      */
        FROM a1001339
       WHERE cod_cia = pl_cod_cia
         AND tip_docum = pl_tip_docum
         AND cod_docum = pl_cod_docum;
   --
   CURSOR c_a1001339_1(pl_cod_cia a1001339.cod_cia           %TYPE,
                       pl_cod_tercero a1001339.cod_tramitador%TYPE)
   IS
      SELECT *
      /*
                                                            SELECT cod_cia          , tip_docum          , cod_docum         ,
                                                                   tip_domicilio    , nom_domicilio1     , nom_domicilio2    ,
                                                                   nom_localidad    , cod_pais           ,
                                                                   cod_prov         , cod_postal         ,
                                                                   cod_localidad    , cod_estado         ,
                                                                   tlf_pais         , tlf_zona           , tlf_numero
                                                      */
        FROM a1001339
       WHERE cod_cia = pl_cod_cia
         AND cod_tramitador = pl_cod_tercero;
   --
   CURSOR c_a1000600_1(pl_cod_cia a1000600.cod_cia                %TYPE,
                       pl_tip_docum a1000600.tip_docum_aseguradora%TYPE,
                       pl_cod_docum a1000600.cod_docum_aseguradora%TYPE) IS
      SELECT *
      /*
                                                            SELECT cod_cia          , tip_docum_aseguradora ,
                                                                   cod_docum_aseguradora ,
                                                                   cod_cia_aseguradora ,
                                                                   tip_domicilio    , nom_domicilio1     , nom_domicilio2    ,
                                                                   nom_domicilio3   , cod_localidad      , nom_localidad     ,
                                                                   cod_prov         , cod_postal         , cod_estado        ,
                                                                   txt_etiqueta1    , txt_etiqueta2      , txt_etiqueta3     ,
                                                                   txt_etiqueta4    , txt_etiqueta5      ,
                                                                   tlf_pais         , tlf_zona           , tlf_numero
                                                      */
        FROM a1000600
       WHERE cod_cia = pl_cod_cia
         AND tip_docum_aseguradora = pl_tip_docum
         AND cod_docum_aseguradora = pl_cod_docum;
   --
   CURSOR c_a1000600_2(pl_cod_cia a1000600.cod_cia                 %TYPE,
                       pl_cod_tercero a1000600.cod_cia_aseguradora %TYPE) IS
      SELECT *
      /*
                                                            SELECT cod_cia               ,
                                                                   tip_docum_aseguradora , cod_docum_aseguradora ,
                                                                   cod_cia_aseguradora   ,
                                                                   tip_domicilio    , nom_domicilio1     , nom_domicilio2    ,
                                                                   nom_domicilio3   , cod_localidad      , nom_localidad     ,
                                                                   cod_prov         , cod_postal         , cod_estado        ,
                                                                   txt_etiqueta1    , txt_etiqueta2      , txt_etiqueta3     ,
                                                                   txt_etiqueta4    , txt_etiqueta5      ,
                                                                   tlf_pais         , tlf_zona           , tlf_numero
                                                      */
        FROM a1000600
       WHERE cod_cia = pl_cod_cia
         AND cod_cia_aseguradora = pl_cod_tercero;
   --
   CURSOR c_g2000155_1(pl_cod_cia g2000155.cod_cia     %TYPE,
                       pl_tip_docum g2000155.tip_docum %TYPE,
                       pl_cod_docum g2000155.cod_docum %TYPE) IS
      SELECT *
      /*
                                                            SELECT cod_cia          , tip_docum          , cod_docum         ,
                                                                   cod_broker       ,
                                                                   tip_domicilio    , nom_domicilio1     , nom_domicilio2    ,
                                                                   nom_domicilio3   , nom_localidad      , cod_pais          ,
                                                                   nom_prov         , cod_postal         ,
                                                                   txt_etiqueta1    , txt_etiqueta2      , txt_etiqueta3     ,
                                                                   txt_etiqueta4    , txt_etiqueta5      ,
                                                                   tlf_pais         , tlf_zona           , tlf_numero        ,
                                                                   cod_imptos_dep   , cod_imptos_renta   , tip_broker        ,
                                                                   txt_aux1         , txt_aux2
                                                      */
        FROM g2000155
       WHERE cod_cia = pl_cod_cia
         AND tip_docum = pl_tip_docum
         AND cod_docum = pl_cod_docum;
   --
   CURSOR c_g2000155_2(pl_cod_cia g2000155.cod_cia %TYPE,
                       pl_cod_tercero g2000155.cod_broker %TYPE) IS
      SELECT *
      /*
                                                            SELECT cod_cia          , tip_docum          , cod_docum         ,
                                                                   cod_broker       ,
                                                                   tip_domicilio    , nom_domicilio1     , nom_domicilio2    ,
                                                                   nom_domicilio3   , nom_localidad      , cod_pais          ,
                                                                   nom_prov         , cod_postal         ,
                                                                   txt_etiqueta1    , txt_etiqueta2      , txt_etiqueta3     ,
                                                                   txt_etiqueta4    , txt_etiqueta5      ,
                                                                   tlf_pais         , tlf_zona           , tlf_numero        ,
                                                                   cod_imptos_dep   , cod_imptos_renta   , tip_broker        ,
                                                                   txt_aux1         , txt_aux2
                                                      */
        FROM g2000155
       WHERE cod_cia = pl_cod_cia
         AND cod_broker = pl_cod_tercero;
   --
   CURSOR c_g2000157_1(pl_cod_cia g2000157.cod_cia     %TYPE,
                       pl_tip_docum g2000157.tip_docum %TYPE,
                       pl_cod_docum g2000157.cod_docum %TYPE) IS
      SELECT *
      /*
                                                            SELECT cod_cia          , tip_docum          , cod_docum         ,
                                                                   cod_cia_rea      ,
                                                                   tip_domicilio    , nom_domicilio1     , nom_domicilio2    ,
                                                                   nom_domicilio3   , nom_localidad      , cod_pais          ,
                                                                   nom_prov         , cod_postal         ,
                                                                   txt_etiqueta1    , txt_etiqueta2      , txt_etiqueta3     ,
                                                                   txt_etiqueta4    , txt_etiqueta5      ,
                                                                   tlf_pais         , tlf_zona           , tlf_numero        ,
                                                                   cod_imptos_dep   , cod_imptos_renta   , tip_cia_rea       ,
                                                                   txt_aux1         , txt_aux2
                                                      */
        FROM g2000157
       WHERE cod_cia = pl_cod_cia
         AND tip_docum = pl_tip_docum
         AND cod_docum = pl_cod_docum;
   --
   CURSOR c_g2000157_2(pl_cod_cia g2000157.cod_cia         %TYPE,
                       pl_cod_tercero g2000157.cod_cia_rea %TYPE) IS
      SELECT *
      /*
                                                            SELECT cod_cia          , tip_docum          , cod_docum         ,
                                                                   cod_cia_rea      ,
                                                                   tip_domicilio    , nom_domicilio1     , nom_domicilio2    ,
                                                                   nom_domicilio3   , nom_localidad      , cod_pais          ,
                                                                   nom_prov         , cod_postal         ,
                                                                   txt_etiqueta1    , txt_etiqueta2      , txt_etiqueta3     ,
                                                                   txt_etiqueta4    , txt_etiqueta5      ,
                                                                   tlf_pais         , tlf_zona           , tlf_numero        ,
                                                                   cod_imptos_dep   , cod_imptos_renta   , tip_cia_rea       ,
                                                                   txt_aux1         , txt_aux2
                                                      */
        FROM g2000157
       WHERE cod_cia = pl_cod_cia
         AND cod_cia_rea = pl_cod_tercero;
   --
   reg_a1001300 c_a1001300_1 %ROWTYPE; -- TERCEROS COMUN
   reg_a1001331 c_a1001331   %ROWTYPE; -- ASEGURADOS
   reg_a1001332 c_a1001332_1 %ROWTYPE; -- AGENTES
   reg_a1001338 c_a1001338   %ROWTYPE; -- SUPERVISORES
   reg_a1001337 a1001337     %ROWTYPE; -- EMPLEADOS AGENTES
   reg_a1001339 c_a1001339   %ROWTYPE; -- TRAMITADORES
   reg_a1000600 c_a1000600_1 %ROWTYPE; -- ASEGURADORAS
   reg_g2000157 c_g2000157_1 %ROWTYPE; -- REASEGURADORAS
   reg_g2000155 c_g2000155_1 %ROWTYPE; -- BROKERS
   --
   g_cod_act_tercero a1001300.cod_act_tercero %TYPE;
   --
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   FUNCTION f_cod_ejecutivo RETURN NUMBER;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   FUNCTION f_cod_org RETURN NUMBER;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   FUNCTION f_cod_asesor RETURN NUMBER;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   FUNCTION f_fec_carnet_con RETURN DATE;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   FUNCTION f_cod_postal_etiqueta RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve el valor del campo
   */ -----------------------------------------------------
   --
   FUNCTION f_mca_pos_secuencia_dir RETURN VARCHAR2;
   /* -------------------- DESCRIPCION --------------------
   || Devuelve marca de si es secuencial o no la peticion de la direccion
   */ -----------------------------------------------------
   --
   FUNCTION f_cod_idioma      RETURN VARCHAR2;
   -- v 1.22
   FUNCTION f_tip_docum       RETURN VARCHAR2;
   --
   FUNCTION f_cod_docum       RETURN VARCHAR2;
   --
   FUNCTION f_ape1_tercero    RETURN VARCHAR2;
   --
   FUNCTION f_ape2_tercero    RETURN VARCHAR2;
   --
   FUNCTION f_nom_tercero     RETURN VARCHAR2;
   --
   FUNCTION f_cod_soc_gl      RETURN VARCHAR2;
   --
   FUNCTION f_mca_fisico      RETURN VARCHAR2;
   --
   FUNCTION f_cod_tercero     RETURN NUMBER;
   --
   FUNCTION f_nom_completo    RETURN VARCHAR2;
   --
   FUNCTION f_tip_docum_padre RETURN VARCHAR2;
   --
   FUNCTION f_cod_docum_padre RETURN VARCHAR2;
   --
   FUNCTION f_nom_alias       RETURN VARCHAR2;
   --
   FUNCTION f_devuelve_reg    RETURN v1001390%ROWTYPE;
   -- v 1.22
   FUNCTION f_pct_participacion RETURN NUMBER;
   --
   FUNCTION f_devuelve_campos_obligatorios (p_cod_tabla    a2990060.cod_tabla %TYPE) RETURN LONG;
   --
   FUNCTION f_devuelve_campos_inh          (p_cod_tabla    a2990060.cod_tabla %TYPE) RETURN LONG;
   --
   --FUNCTION f_tab_devuelve_ctas (p_cod_cia          a1002201.cod_cia         %TYPE,
   --                             p_cod_act_tercero  a1002201.cod_act_tercero %TYPE,
   --                              p_tip_docum        a1002201.tip_docum       %TYPE,
   --                              p_cod_docum        a1002201.cod_docum       %TYPE,
   --                              p_cod_tercero      a1002201.cod_tercero     %TYPE
   --                             ) RETURN dc_k_a1002201.t_tab_ctas;
      /*-------------------------------------------------------------------------------
   || Devuelve la constante que indica si se trabaja con una o varias cuentas
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_es_multicuenta RETURN VARCHAR2;
   --
   --
   /*-------------------------------------------------------------------------------
   || Devuelve la cuenta corriente del tercero en un solo campo
   */-------------------------------------------------------------------------------
   FUNCTION f_cuenta_corriente RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo atr_domicilio1 de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_atr_domicilio1 RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo atr_domicilio2 de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_atr_domicilio2 RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo atr_domicilio3 de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_atr_domicilio3 RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo atr_domicilio4 de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_atr_domicilio4 RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo atr_domicilio5 de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_atr_domicilio5 RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo anx_domicilio de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_anx_domicilio RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo ext_cod_postal de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_ext_cod_postal  RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo tlf_extension de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_tlf_extension   RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo nom_empresa_com de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_nom_empresa_com   RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo atr_domicilio1_com  de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_atr_domicilio1_com    RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo atr_domicilio2_com  de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_atr_domicilio2_com    RETURN VARCHAR2;
    --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo atr_domicilio3_com  de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_atr_domicilio3_com    RETURN VARCHAR2;
    --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo atr_domicilio4_com  de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_atr_domicilio4_com    RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo atr_domicilio5_com  de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_atr_domicilio5_com    RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo anx_domicilio_com   de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_anx_domicilio_com     RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo ext_cod_postal_com   de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_ext_cod_postal_com     RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo tlf_extension_com    de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_tlf_extension_com      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo ext_cod_postal_etiqueta     de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_ext_cod_postal_etiqueta       RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve fecha de actualizacion del registro
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_fec_actu
      RETURN DATE;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve nombre del contacto
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_nombre_contacto
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el numero del colegio del agente
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_cod_agt_colegio
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve la marca del productor directo
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_mca_agt_dir
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve la fecha de credencial del agente
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_fec_credencial
      RETURN DATE;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve la fecha de vencimiento de credencial del agente
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_fec_vcto_credencial
      RETURN DATE;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el numero de contrato del registro
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_num_contrato
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve la fecha de alta del contrato
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_fec_alta_contrato
      RETURN DATE;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve la fecha de baja del contrato
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_fec_baja_contrato
      RETURN DATE;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el codigo de envio del registro
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_cod_envio
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve las observaciones del agente del registro
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_obs_agt
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el valor del campo auxiliar 4
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_txt_aux4
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el valor del campo auxiliar 5
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_txt_aux5
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el valor del campo auxiliar 6
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_txt_aux6
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el valor del campo auxiliar 7
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_txt_aux7
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el valor del campo auxiliar 8
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_txt_aux8
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el valor del campo auxiliar 9
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_txt_aux9
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el tipo de situacion del registro
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_tip_situacion
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el tipo de proceso que afecta inhabilitacion
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_tip_proc_inh
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve la fecha de validez del registro
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_fec_validez
      RETURN DATE;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el codigo de clase del beneficiario
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_cod_causa_inh_trc
      RETURN NUMBER;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el codigo de causa de inhabilitacion de tercero
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_cod_clase_benef
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el tipo de tramitador
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_tip_tramitador
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el codigo del tramitador
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_cod_tramitador
      RETURN NUMBER;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el codigo del usuario del tramitador
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_cod_usr_tramitador
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el codigo del supervisor del siniestro
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_cod_supervisor
      RETURN NUMBER;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el tipo de estado del registro
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_tip_estado
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el numero de siniestros pendientes por supervisor
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_num_siniestros
      RETURN NUMBER;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el numero maximo de expedientes asignado a supervisor
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_max_num_exp
      RETURN NUMBER;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve la marca de la consencuencia con pregunta
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_mca_preg_consecuencia
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el tipo de nacionalidad del registro
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_tip_nacionalidad
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el codigo de calidad del tercero
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_cod_calidad
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve las observaciones del tercero del registro
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_obs_tercero
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el codigo del colegiado del tercero
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_cod_ter_colegio
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el numero de identificacion fiscal
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_num_id_fiscal
      RETURN VARCHAR2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve tip_etiqueta
   */-------------------------------------------------------------------------------
   FUNCTION f_tip_etiqueta RETURN a1001331.tip_etiqueta%TYPE;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve cod_pais_etiqueta
   */-------------------------------------------------------------------------------
   FUNCTION f_cod_pais_etiqueta RETURN a1001331.cod_pais_etiqueta%TYPE;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve cod_estado_etiqueta
   */-------------------------------------------------------------------------------
   FUNCTION f_cod_estado_etiqueta RETURN a1001331.cod_estado_etiqueta%TYPE;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve num_apartado_etiqueta
   */-------------------------------------------------------------------------------
   FUNCTION f_num_apartado_etiqueta RETURN a1001331.num_apartado_etiqueta%TYPE;
   --
   /*-------------------------------------------------------------
   || Devuelve el codigo geografico del carnet de conduccion
   */-------------------------------------------------------------
   --
   FUNCTION f_cod_exp_carnet_con
      RETURN a1001331.cod_exp_carnet_con%TYPE;
   --
   /*-------------------------------------------------------------
   || Devuelve la situacion del carnet de conducir
   */-------------------------------------------------------------
   --
   FUNCTION f_cod_situ_carnet_con
      RETURN a1001331.cod_situ_carnet_con%TYPE;
   --
   /*-------------------------------------------------------------
   || Devuelve el n?mero del carnet de conducir
   */-------------------------------------------------------------
   --
   FUNCTION f_num_carnet_con
      RETURN a1001331.num_carnet_con%TYPE;
   --
   /*-------------------------------------------------------------
   || Devuelve el valor del campo num_busca
   */-------------------------------------------------------------
   --
   FUNCTION f_num_busca
      RETURN a1001331.num_busca%TYPE;
   --
   /*-------------------------------------------------------------
   || Devuelve la fecha de vencimiento de la tarjeta de credito
   */-------------------------------------------------------------
   --
   FUNCTION f_fec_vcto_tarjeta
      RETURN a1001331.fec_vcto_tarjeta%TYPE;
   --
   /*-------------------------------------------------------------
   || Devuelve las observaciones del asegurado
   */-------------------------------------------------------------
   --
   FUNCTION f_obs_asegurado
      RETURN a1001331.obs_asegurado%TYPE;
   --
   /*-------------------------------------------------------------
   || Devuelve el tipo de cargo en la empresa
   */-------------------------------------------------------------
   --
   FUNCTION f_tip_cargo
      RETURN a1001331.tip_cargo%TYPE;
   --
   /*-------------------------------------------------------------
   || Devuelve el tipo de actividad economica
   */-------------------------------------------------------------
   --
   FUNCTION f_tip_act_economica
      RETURN a1001331.tip_act_economica%TYPE;
   --
   /*-------------------------------------------------------------
   || Devuelve el tipo de iva del tercero, de la tabla A1001300
   */-------------------------------------------------------------
   --
   FUNCTION f_tip_tercero_iva
      RETURN a1001300.tip_tercero_iva%TYPE;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el apellido del contacto
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_apellido_contacto
      RETURN a1001331.apellido_contacto%TYPE;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el tipo de documento del contacto
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_tip_docum_contacto
      RETURN a1001331.tip_docum_contacto%TYPE;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el codigo de documento del contacto
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_cod_docum_contacto
      RETURN a1001331.cod_docum_contacto%TYPE;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el codigo de nacionalidad del contacto
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_cod_nacionalidad_contacto
      RETURN a1001331.cod_nacionalidad_contacto%TYPE;
   --
   /*-------------------------------------------------------------
   || Devuelve el número de hijos, de la tabla A1001331
   */-------------------------------------------------------------
   --
   FUNCTION f_num_hijos
      RETURN a1001331.num_hijos%TYPE;
   --
   /*-------------------------------------------------------------
   || Devuelve el tipo de rating, de la tabla A1001331
   */-------------------------------------------------------------
   --
   FUNCTION f_tip_rating
      RETURN a1001331.tip_rating%TYPE;
   --
   /*-------------------------------------------------------------
   || Devuelve la longitud de la direccion, de la tabla A1001331
   */-------------------------------------------------------------
   --
   FUNCTION f_txt_longitud
      RETURN a1001331.txt_longitud%TYPE;
   --
   /*-------------------------------------------------------------
   || Devuelve la latitud de la direccion, de la tabla A1001331
   */-------------------------------------------------------------
   --
   FUNCTION f_txt_latitud
      RETURN a1001331.txt_latitud%TYPE;
   --
   /*-------------------------------------------------------------
   || Devuelve la oficiana a la que esta asociada el asegurado, de la tabla A1001331
   */-------------------------------------------------------------
   --
   FUNCTION f_cod_nivel3_ref
      RETURN a1001331.cod_nivel3_ref%TYPE;
   --
   /*-------------------------------------------------------------
   || Devuelve la fecha de alta del asegurado, de la tabla A1001331
   */-------------------------------------------------------------
   --
   FUNCTION f_fec_alta
      RETURN a1001331.fec_alta%TYPE;
   --
   /*-------------------------------------------------------------
   || Devuelve la fecha de emision del documento, de la tabla A1001331
   */-------------------------------------------------------------
   --
   FUNCTION f_fec_emi_docum
      RETURN a1001331.fec_emi_docum%TYPE;
   --
   /*-------------------------------------------------------------
   || Devuelve la fecha de caducidad del documento, de la tabla A1001331
   */-------------------------------------------------------------
   --
   FUNCTION f_fec_caduc_docum
      RETURN a1001331.fec_caduc_docum%TYPE;
   --
   /*-------------------------------------------------------------
   || Devuelve el identificador del documento, de la tabla A1001331
   */-------------------------------------------------------------
   --
   FUNCTION f_cod_exp_docum
      RETURN a1001331.cod_exp_docum%TYPE;
   --
END dc_k_terceros_trn;

