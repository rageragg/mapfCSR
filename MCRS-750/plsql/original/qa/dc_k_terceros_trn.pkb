create or replace PACKAGE BODY dc_k_terceros_trn
IS
   --
   /* -------------------- DESCRIPCION --------------------
   || Obtiene los datos de un tercero.
   || Los datos de un tercero se guardan en variables
   || globales del package, asi se pueden consultar en
   || diferentes funciones del package.
   || Las funciones de cada campo se iran a?adiendo segun
   || la necesidad de cada uno de acuerdo a la base
   || principal.
   */ -----------------------------------------------------
   --
   /* -------------------- VERSION = 1.51 -------------------- */
   --
   /* -------------------- MODIFICACIONES -------------------------------------
   || 2016/11/10 - HSOLIVE - 1.51 - (MU-2016-069005)
   || Se añaden las funciones para cada uno de los campos nuevos de la A1001331
   */ -------------------------------------------------------------------------
   --
   /* ---------------------------------------------------
   || Aqui comienza la declaracion de constantes GLOBALES
   */ ---------------------------------------------------
   --
   g_k_no           CONSTANT VARCHAR2(1)      := trn.NO  ;
   g_k_uno          CONSTANT NUMBER  (1)       := trn.UNO;
   g_k_ini_corchete CONSTANT VARCHAR2(2)      := ' ['    ;
   g_k_fin_corchete CONSTANT VARCHAR2(1)      := ']'     ;
   g_cod_mensaje    g1010020.cod_mensaje%TYPE            ;
   g_anx_mensaje    VARCHAR2(100);
   g_cod_entidad    a5020900.cod_entidad%TYPE            ;
   g_cta_cte        VARCHAR2(100)                        ;
   g_k_nulo         VARCHAR2(4)               := trn.NULO; -- Global valor nulo
   --
   g_k_cod_act_asegurado        a1002200.cod_act_tercero %TYPE := dc.ACT_ASEGURADO    ; -- asegurado
   g_k_cod_act_agente           a1002200.cod_act_tercero %TYPE := dc.ACT_AGENTE       ; -- agente
   g_k_cod_act_supervisor       a1002200.cod_act_tercero %TYPE := dc.ACT_SUPERVISOR   ; -- supervisor
   g_k_cod_act_tramitador       a1002200.cod_act_tercero %TYPE := dc.ACT_TRAMITADOR   ; -- tramitador
   g_k_cod_act_aseguradora      a1002200.cod_act_tercero %TYPE := dc.ACT_ASEGURADORA  ; -- aseguradora
   g_k_cod_act_reaseguradora    a1002200.cod_act_tercero %TYPE := dc.ACT_REASEGURADORA; -- reaseguradora
   g_k_cod_act_broker           a1002200.cod_act_tercero %TYPE := dc.ACT_BROKER       ; -- broker
   g_k_cod_act_empleado_agt     a1002200.cod_act_tercero %TYPE := dc.ACT_EMPLEADO_AGT ; -- empleado agt
   --
   g_existe          BOOLEAN;
   l_fec_validez     DATE;
   reg_a1001300_null c_a1001300_1 %ROWTYPE; -- TERCEROS COMUN
   reg_a1001331_null c_a1001331   %ROWTYPE; -- ASEGURADOS
   reg_a1001332_null c_a1001332_1 %ROWTYPE; -- AGENTES
   reg_a1001337_null a1001337     %ROWTYPE; --EMPLEADO AGENTES
   reg_a1001338_null c_a1001338   %ROWTYPE; -- SUPERVISORES
   reg_a1001339_null c_a1001339   %ROWTYPE; -- TRAMITADORES
   reg_a1000600_null c_a1000600_1 %ROWTYPE; -- ASEGURADORAS
   reg_g2000157_null c_g2000157_1 %ROWTYPE; -- REASEGURADORAS
   reg_g2000155_null c_g2000155_1 %ROWTYPE; -- BROKERS
   --
   --
   -- ==============================================================
   /*
   ||               Procedimientos Internos
   */
   -- ==============================================================
   /*
   || -------------------- p_comprueba_error --------------------
   */
   PROCEDURE p_comprueba_error(p_clave IN VARCHAR2) IS
      --
      l_cod_mensaje g1010020.cod_mensaje%TYPE;
      l_txt_mensaje g1010020.txt_mensaje%TYPE;
      l_hay_error EXCEPTION;
      --
   BEGIN
      IF NOT g_existe
      THEN
         l_cod_mensaje := 20001;
         l_txt_mensaje := ss_f_mensaje(l_cod_mensaje);
         l_txt_mensaje := SUBSTR(l_txt_mensaje || p_clave,
                                 1,
                                 69);
         --
         raise_application_error(-l_cod_mensaje,
                                 l_txt_mensaje);
         --
      END IF;
      --
   END p_comprueba_error;
   --
   -- ------------------------------------------------------------
   --
   /**
   || Devuelve el error al llamador
   */
   PROCEDURE pp_devuelve_error IS
   BEGIN
      --
      IF g_cod_mensaje BETWEEN 20000 AND 20999
      THEN
         --
         raise_application_error(-g_cod_mensaje,
                                 ss_k_mensaje.f_texto_idioma(g_cod_mensaje,
                                                             trn_k_global.cod_idioma) ||
                                 g_anx_mensaje);
         --
      ELSE
         --
         raise_application_error(-20000,
                                 ss_k_mensaje.f_texto_idioma(g_cod_mensaje,
                                                             trn_k_global.cod_idioma) ||
                                 g_anx_mensaje);
         --
      END IF;
      --
   END pp_devuelve_error;
   --
   /* --------------------------------------------------------
   || pp_asigna :
   || Llama a trn_k_global.asigna
   */ --------------------------------------------------------
   --
   --
   PROCEDURE pp_asigna(p_nom_global VARCHAR2,
                       p_val_global VARCHAR2)
   IS
   --
   BEGIN
      --
      trn_k_global.asigna(p_nom_global,
                          p_val_global);
      --
   END pp_asigna;
   --
   /* --------------------------------------------------------
   || pp_asigna :
   || Llama a trn_k_global.asigna
   */ --------------------------------------------------------
   --
   PROCEDURE pp_asigna(p_nom_global VARCHAR2,
                       p_val_global NUMBER  )
   IS
   --
   BEGIN
      --
      trn_k_global.asigna(p_nom_global         ,
                          TO_CHAR(p_val_global));
      --
   END pp_asigna;
   --
   /* --------------------------------------------------------
   || pp_asigna :
   ||
   || Llama a trn_k_global.asigna
   */ --------------------------------------------------------
   --
   PROCEDURE pp_asigna(p_nom_global VARCHAR2,
                       p_val_global DATE    )
   IS
   --
   BEGIN
      --
      trn_k_global.asigna(p_nom_global                     ,
                          TO_CHAR(p_val_global, 'ddmmyyyy'));
      --
   END pp_asigna;
   --
   /* --------------------------------------------------------
   || mx :
   || Genera la traza
   */ --------------------------------------------------------
   --
   PROCEDURE mx(p_tit VARCHAR2,
                p_val VARCHAR2)
   IS
   --
   BEGIN
      --
      pp_asigna('fic_traza',
                'AS100001' );
      --
      pp_asigna('cab_traza' ,
                'AS100001->');
      --
      em_k_traza.p_escribe(p_tit,
                           p_val);
      --
   END mx;
   --
   /* --------------------------------------------------------
   || mx :
   || Genera la traza
   */ --------------------------------------------------------
   --
   PROCEDURE mx(p_tit VARCHAR2,
                p_val BOOLEAN)
   IS
   --
   BEGIN
      --
      pp_asigna('fic_traza'    ,
                'em_k_as100001');
      --
      pp_asigna('cab_traza' ,
                'AS100001->');
      --
      em_k_traza.p_escribe(p_tit,
                           p_val);
      --
   END mx;
   --
   -- --------------------------------------------------------------
   PROCEDURE p_lee_datos_a1001300_1(p_cod_cia         a1001300.cod_cia %TYPE,
                                    p_tip_docum       a1001300.tip_docum %TYPE,
                                    p_cod_docum       a1001300.cod_docum %TYPE,
                                    p_cod_act_tercero a1001300.cod_act_tercero%TYPE,
                                    p_fec_validez     a1001300.fec_validez %TYPE) IS
      l_clave VARCHAR2(80);
      --
      l_fec_validez a1001300.fec_validez%TYPE;
      --
      CURSOR c_validez IS
         SELECT MAX(fec_validez)
           FROM a1001300
          WHERE cod_cia = p_cod_cia
            AND tip_docum = p_tip_docum
            AND cod_act_tercero = p_cod_act_tercero
            AND cod_docum = p_cod_docum
            AND fec_validez <= p_fec_validez;
      --
   BEGIN
      --
      OPEN c_validez;
      FETCH c_validez
       INTO l_fec_validez;
      CLOSE c_validez;
      --
      OPEN c_a1001300_1(p_cod_cia,
                        p_tip_docum,
                        p_cod_docum,
                        p_cod_act_tercero,
                        l_fec_validez);
      FETCH c_a1001300_1
       INTO reg_a1001300;
      g_existe := c_a1001300_1%FOUND;
      CLOSE c_a1001300_1;
      --
      l_clave := ' a1001300 PK:[' || TO_CHAR(p_cod_cia) || '-' ||
                 TO_CHAR(p_cod_act_tercero) || '-' || p_tip_docum || '-' ||
                 p_cod_docum || '-' ||
                 TO_CHAR(p_fec_validez,
                         'DDMMYYYY') || ']';
      --
      p_comprueba_error(l_clave);
      --
   END p_lee_datos_a1001300_1;
   -- --------------------------------------------------------------
   PROCEDURE p_lee_datos_a1001300_2(p_cod_cia         a1001300.cod_cia        %TYPE,
                                    p_cod_tercero     a1001300.cod_tercero    %TYPE,
                                    p_cod_act_tercero a1001300.cod_act_tercero%TYPE,
                                    p_fec_validez     a1001300.fec_validez    %TYPE) IS
      l_clave VARCHAR2(80);
      --
      l_fec_validez a1001300.fec_validez%TYPE;
      --
      CURSOR c_validez IS
         SELECT MAX(fec_validez)
           FROM a1001300
          WHERE cod_cia = p_cod_cia
            AND cod_tercero = p_cod_tercero
            AND cod_act_tercero = p_cod_act_tercero
            AND fec_validez <= p_fec_validez;
      --
   BEGIN
      OPEN c_validez;
      FETCH c_validez
         INTO l_fec_validez;
      CLOSE c_validez;
      --
      OPEN c_a1001300_2(p_cod_cia,
                        p_cod_tercero,
                        p_cod_act_tercero,
                        l_fec_validez);
      FETCH c_a1001300_2
         INTO reg_a1001300;
      g_existe := c_a1001300_2%FOUND;
      CLOSE c_a1001300_2;
      --
      l_clave := ' a1001300 PK:[' || TO_CHAR(p_cod_cia) || '-' ||
                 TO_CHAR(p_cod_act_tercero) || '-' || TO_CHAR(p_cod_tercero) || '-' ||
                 TO_CHAR(p_fec_validez,
                         'DDMMYYYY') || ']';
      --
      p_comprueba_error(l_clave);
      --
   END p_lee_datos_a1001300_2;
   -- --------------------------------------------------------------
   PROCEDURE p_lee_datos_a1001331(p_cod_cia   a1001331.cod_cia %TYPE,
                                  p_tip_docum a1001331.tip_docum %TYPE,
                                  p_cod_docum a1001331.cod_docum %TYPE) IS
      l_clave VARCHAR2(80);
      --
   BEGIN
      OPEN c_a1001331(p_cod_cia,
                      p_tip_docum,
                      p_cod_docum);
      FETCH c_a1001331
         INTO reg_a1001331;
      g_existe := c_a1001331%FOUND;
      CLOSE c_a1001331;
      --
      l_clave := ' a1001331 PK:[' || TO_CHAR(p_cod_cia) || '-' || p_tip_docum || '-' ||
                 p_cod_docum || ']';
      --
      p_comprueba_error(l_clave);
      --
   END p_lee_datos_a1001331;
   -- --------------------------------------------------------------
   PROCEDURE p_lee_datos_a1001331_poliza(p_cod_cia          a1001331.cod_cia          %TYPE,
                                         p_tip_docum        a1001331.tip_docum        %TYPE,
                                         p_cod_docum        a1001331.cod_docum        %TYPE,
                                         p_num_poliza       a1000802.num_poliza       %TYPE,
                                         p_num_spto         a1000802.num_spto         %TYPE,
                                         p_num_riesgo       a1000802.num_riesgo       %TYPE,
                                         p_num_secu_cta_tar a1002201.num_secu_cta_tar %TYPE)
   IS
   --
      l_clave VARCHAR2(80);
      --
      l_error EXCEPTION;
      PRAGMA EXCEPTION_INIT(l_error,
                            -20001);
      --
      l_reg_802 a1000802%ROWTYPE;
      --
      l_num_riesgo a1000802.num_riesgo%TYPE;
   --
   BEGIN
      --
      OPEN c_a1001331(p_cod_cia  ,
                      p_tip_docum,
                      p_cod_docum);
      FETCH c_a1001331 INTO reg_a1001331;
      g_existe := c_a1001331%FOUND;
      CLOSE c_a1001331;
      --
      IF g_existe THEN
         --
         BEGIN
            --
            IF f_es_multicuenta = 'S' THEN
               -- Si el tercero no tiene ninguna cuenta, este p_lee no falla
               dc_k_a1002201.p_lee(p_cod_cia          => p_cod_cia         ,
                                   p_tip_docum        => p_tip_docum       ,
                                   p_cod_docum        => p_cod_docum       ,
                                   p_cod_act_tercero  => trn.UNO           ,
                                   p_num_secu_cta_tar => p_num_secu_cta_tar);
            END IF;
            --
            IF p_num_riesgo IS NULL THEN
               --
               l_num_riesgo := 0;
               --
            ELSE
               --
               l_num_riesgo := p_num_riesgo;
               --
            END IF;
            --
            em_k_a1000802.p_lee_vigente(p_cod_cia,
                                        p_num_poliza,
                                        p_num_spto,
                                        l_num_riesgo,
                                        p_tip_docum,
                                        p_cod_docum);
            --
            l_reg_802 := em_k_a1000802.reg;
            --
           IF l_reg_802.tip_domicilio   IS NOT NULL OR
               l_reg_802.nom_domicilio1 IS NOT NULL OR
               l_reg_802.nom_domicilio2 IS NOT NULL OR
               l_reg_802.nom_domicilio3 IS NOT NULL OR
               l_reg_802.cod_localidad  IS NOT NULL OR
               l_reg_802.nom_localidad  IS NOT NULL OR
               l_reg_802.cod_pais       IS NOT NULL OR
               l_reg_802.cod_prov       IS NOT NULL OR
               l_reg_802.cod_estado     IS NOT NULL OR
               l_reg_802.cod_postal     IS NOT NULL OR
               l_reg_802.atr_domicilio1 IS NOT NULL OR
               l_reg_802.atr_domicilio2 IS NOT NULL OR
               l_reg_802.atr_domicilio3 IS NOT NULL OR
               l_reg_802.atr_domicilio4 IS NOT NULL OR
               l_reg_802.atr_domicilio5 IS NOT NULL OR
               l_reg_802.anx_domicilio  IS NOT NULL OR
               l_reg_802.ext_cod_postal IS NOT NULL OR
               l_reg_802.tlf_extension  IS NOT NULL
            THEN
               reg_a1001331.tip_domicilio  := l_reg_802.tip_domicilio ;
               reg_a1001331.nom_domicilio1 := l_reg_802.nom_domicilio1;
               reg_a1001331.nom_domicilio2 := l_reg_802.nom_domicilio2;
               reg_a1001331.nom_domicilio3 := l_reg_802.nom_domicilio3;
               reg_a1001331.cod_localidad  := l_reg_802.cod_localidad ;
               reg_a1001331.nom_localidad  := l_reg_802.nom_localidad ;
               reg_a1001331.cod_pais       := l_reg_802.cod_pais      ;
               reg_a1001331.cod_prov       := l_reg_802.cod_prov      ;
               reg_a1001331.cod_estado     := l_reg_802.cod_estado    ;
               reg_a1001331.cod_postal     := l_reg_802.cod_postal    ;
               reg_a1001331.atr_domicilio1 := l_reg_802. atr_domicilio1;
               reg_a1001331.atr_domicilio2 := l_reg_802.atr_domicilio2;
               reg_a1001331.atr_domicilio3 := l_reg_802.atr_domicilio3;
               reg_a1001331.atr_domicilio4 := l_reg_802.atr_domicilio4;
               reg_a1001331.atr_domicilio5 := l_reg_802.atr_domicilio5;
               reg_a1001331.anx_domicilio  := l_reg_802.anx_domicilio ;
               reg_a1001331.ext_cod_postal := l_reg_802.ext_cod_postal;
               reg_a1001331.tlf_extension  := l_reg_802. tlf_extension;
            END IF;
            --
            IF l_reg_802.tip_etiqueta           IS NOT NULL OR
               l_reg_802.txt_etiqueta1          IS NOT NULL OR
               l_reg_802.txt_etiqueta2          IS NOT NULL OR
               l_reg_802.txt_etiqueta3          IS NOT NULL OR
               l_reg_802.txt_etiqueta4          IS NOT NULL OR
               l_reg_802.txt_etiqueta5          IS NOT NULL OR
               l_reg_802.cod_pais_etiqueta      IS NOT NULL OR
               l_reg_802.cod_estado_etiqueta    IS NOT NULL OR
               l_reg_802.cod_prov_etiqueta      IS NOT NULL OR
               l_reg_802.cod_postal_etiqueta    IS NOT NULL OR
               l_reg_802.cod_localidad_etiqueta IS NOT NULL OR
               l_reg_802.nom_localidad_etiqueta IS NOT NULL
            THEN
               reg_a1001331.tip_etiqueta           := l_reg_802.tip_etiqueta          ;
               reg_a1001331.txt_etiqueta1          := l_reg_802.txt_etiqueta1         ;
               reg_a1001331.txt_etiqueta2          := l_reg_802.txt_etiqueta2         ;
               reg_a1001331.txt_etiqueta3          := l_reg_802.txt_etiqueta3         ;
               reg_a1001331.txt_etiqueta4          := l_reg_802.txt_etiqueta4         ;
               reg_a1001331.txt_etiqueta5          := l_reg_802.txt_etiqueta5         ;
               reg_a1001331.cod_pais_etiqueta      := l_reg_802.cod_pais_etiqueta     ;
               reg_a1001331.cod_estado_etiqueta    := l_reg_802.cod_estado_etiqueta   ;
               reg_a1001331.cod_prov_etiqueta      := l_reg_802.cod_prov_etiqueta     ;
               reg_a1001331.cod_postal_etiqueta    := l_reg_802.cod_postal_etiqueta   ;
               reg_a1001331.cod_localidad_etiqueta := l_reg_802.cod_localidad_etiqueta;
               reg_a1001331.nom_localidad_etiqueta := l_reg_802.nom_localidad_etiqueta;
            END IF;
            --
            IF l_reg_802.cod_entidad      IS NOT NULL OR
               l_reg_802.cod_oficina      IS NOT NULL OR
               l_reg_802.cta_cte          IS NOT NULL OR
               l_reg_802.cta_dc           IS NOT NULL OR
               l_reg_802.nom_titular_cta  IS NOT NULL
            THEN
               --
               reg_a1001331.cod_entidad     := l_reg_802.cod_entidad    ;
               reg_a1001331.cod_oficina     := l_reg_802.cod_oficina    ;
               reg_a1001331.cta_cte         := l_reg_802.cta_cte        ;
               reg_a1001331.cta_dc          := l_reg_802.cta_dc         ;
               reg_a1001331.nom_titular_cta := l_reg_802.nom_titular_cta;
               --
            END IF;
            --
            IF f_es_multicuenta = 'S' AND l_reg_802.num_secu_cta IS NOT NULL THEN
               -- Si el tercero no tiene ninguna cuenta, este p_lee no falla.
               dc_k_a1002201.p_lee(p_cod_cia          => p_cod_cia             ,
                                   p_tip_docum        => p_tip_docum           ,
                                   p_cod_docum        => p_cod_docum           ,
                                   p_cod_act_tercero  => 1                     ,
                                   p_num_secu_cta_tar => l_reg_802.num_secu_cta);
               --
               reg_a1001331.cod_entidad := dc_k_a1002201.f_cod_entidad;
               reg_a1001331.cod_oficina := dc_k_a1002201.f_cod_oficina;
               reg_a1001331.cta_cte     := dc_k_a1002201.f_cta_cte    ;
               reg_a1001331.cta_dc      := dc_k_a1002201.f_cta_dc     ;
               --
            END IF;
            --
            IF l_reg_802.tip_tarjeta      IS NOT NULL OR
               l_reg_802.cod_tarjeta      IS NOT NULL OR
               l_reg_802.num_tarjeta      IS NOT NULL OR
               l_reg_802.fec_vcto_tarjeta IS NOT NULL
            THEN
               reg_a1001331.tip_tarjeta      := l_reg_802.tip_tarjeta     ;
               reg_a1001331.cod_tarjeta      := l_reg_802.cod_tarjeta     ;
               reg_a1001331.num_tarjeta      := l_reg_802.num_tarjeta     ;
               reg_a1001331.fec_vcto_tarjeta := l_reg_802.fec_vcto_tarjeta;
            END IF;
            --
            IF l_reg_802.tlf_numero IS NOT NULL OR
               l_reg_802.tlf_zona   IS NOT NULL OR
               l_reg_802.tlf_numero IS NOT NULL OR
               l_reg_802.fax_numero IS NOT NULL
            THEN
               reg_a1001331.tlf_pais   := l_reg_802.tlf_pais  ;
               reg_a1001331.tlf_zona   := l_reg_802.tlf_zona  ;
               reg_a1001331.tlf_numero := l_reg_802.tlf_numero;
               reg_a1001331.fax_numero := l_reg_802.fax_numero;
            END IF;
            --
            reg_a1001331.num_apartado              := NVL(l_reg_802.num_apartado   ,
                                                          reg_a1001331.num_apartado);
            --
            reg_a1001331.num_apartado_etiqueta     := NVL(l_reg_802.num_apartado_etiqueta   ,
                                                          reg_a1001331.num_apartado_etiqueta);
            --
            reg_a1001331.email                     := NVL(l_reg_802.email   ,
                                                          reg_a1001331.email);
            --
            reg_a1001331.txt_email                 := NVL(l_reg_802.txt_email   ,
                                                          reg_a1001331.txt_email);
            --
            reg_a1001331.nom_contacto              := NVL(l_reg_802.nom_contacto   ,
                                                          reg_a1001331.nom_contacto);
            --
            reg_a1001331.apellido_contacto         := NVL(l_reg_802.apellido_contacto   ,
                                                          reg_a1001331.apellido_contacto);
            --
            reg_a1001331.tip_docum_contacto        := NVL(l_reg_802.tip_docum_contacto   ,
                                                          reg_a1001331.tip_docum_contacto);
            --
            reg_a1001331.cod_docum_contacto        := NVL(l_reg_802.cod_docum_contacto   ,
                                                          reg_a1001331.cod_docum_contacto);
            --
            reg_a1001331.cod_nacionalidad_contacto := NVL(l_reg_802.cod_nacionalidad_contacto   ,
                                                          reg_a1001331.cod_nacionalidad_contacto);
            --
            reg_a1001331.tip_cargo                 := NVL(l_reg_802.tip_cargo   ,
                                                          reg_a1001331.tip_cargo);
            --
            reg_a1001331.obs_asegurado             := NVL(l_reg_802.obs_asegurado   ,
                                                          reg_a1001331.obs_asegurado);
            --
            reg_a1001331.cod_compensacion          := NVL(l_reg_802.cod_compensacion   ,
                                                          reg_a1001331.cod_compensacion);
            --
         EXCEPTION
            WHEN l_error THEN
               NULL;
               --
         END;
         --
      END IF;
      --
      l_clave := ' a1001331 PK:[' || TO_CHAR(p_cod_cia) || '-' || p_tip_docum || '-' ||
                 p_cod_docum || '-' || p_num_poliza || '-' || p_num_spto || '-' ||
                 p_num_riesgo || ']';
      --
      p_comprueba_error(l_clave);
      --
   END p_lee_datos_a1001331_poliza;
   -- --------------------------------------------------------------
   PROCEDURE p_lee_datos_a1001332_1(p_cod_cia     a1001332.cod_cia %TYPE,
                                    p_tip_docum   a1001332.tip_docum %TYPE,
                                    p_cod_docum   a1001332.cod_docum %TYPE,
                                    p_fec_validez a1001332.fec_validez %TYPE) IS
      l_clave VARCHAR2(80);
      --
      l_fec_validez a1001332.fec_validez%TYPE;
      --
      CURSOR c_validez IS
         SELECT MAX(fec_validez)
           FROM a1001332
          WHERE cod_cia = p_cod_cia AND tip_docum = p_tip_docum AND
                cod_docum = p_cod_docum AND fec_validez <= p_fec_validez;
      --
   BEGIN
      --
      OPEN c_validez;
      FETCH c_validez
         INTO l_fec_validez;
      CLOSE c_validez;
      --
      OPEN c_a1001332_1(p_cod_cia,
                        p_tip_docum,
                        p_cod_docum,
                        l_fec_validez);
      FETCH c_a1001332_1
         INTO reg_a1001332;
      g_existe := c_a1001332_1%FOUND;
      CLOSE c_a1001332_1;
      --
      l_clave := ' a1001332 PK:[' || TO_CHAR(p_cod_cia) || '-' || p_tip_docum || '-' ||
                 p_cod_docum || '-' ||
                 TO_CHAR(p_fec_validez,
                         'DDMMYYYY') || ']';
      --
      p_comprueba_error(l_clave);
      --
   END p_lee_datos_a1001332_1;
   -- --------------------------------------------------------------
   PROCEDURE p_lee_datos_a1001332_2(p_cod_cia     a1001332.cod_cia %TYPE,
                                    p_cod_tercero a1001332.cod_agt %TYPE,
                                    p_fec_validez a1001332.fec_validez %TYPE) IS
      l_clave VARCHAR2(80);
      --
      l_fec_validez a1001332.fec_validez%TYPE;
      --
      CURSOR c_validez IS
         SELECT MAX(fec_validez)
           FROM a1001332
          WHERE cod_cia = p_cod_cia AND cod_agt = p_cod_tercero AND
                fec_validez <= p_fec_validez;
      --
   BEGIN
      --
      OPEN c_validez;
      FETCH c_validez
         INTO l_fec_validez;
      CLOSE c_validez;
      --
      OPEN c_a1001332_2(p_cod_cia,
                        p_cod_tercero,
                        l_fec_validez);
      FETCH c_a1001332_2
         INTO reg_a1001332;
      g_existe := c_a1001332_2%FOUND;
      CLOSE c_a1001332_2;
      --
      l_clave := ' a1001332 PK:[' || TO_CHAR(p_cod_cia) || '-' ||
                 TO_CHAR(p_cod_tercero) || '-' ||
                 TO_CHAR(p_fec_validez,
                         'DDMMYYYY') || ']';
      --
      p_comprueba_error(l_clave);
      --
   END p_lee_datos_a1001332_2;
   -- --------------------------------------------------------------
   ----
   PROCEDURE p_lee_datos_a1001337_1(p_cod_cia     a1001337.cod_cia     %TYPE,
                                    p_tip_docum   a1001337.tip_docum   %TYPE,
                                    p_cod_docum   a1001337.cod_docum   %TYPE,
                                    p_fec_validez a1001337.fec_validez %TYPE)
   IS
      --
      l_clave        VARCHAR2(80);
      l_fec_validez  a1001337.fec_validez%TYPE;
      --
      CURSOR c_validez IS
         SELECT MAX(fec_validez)
           FROM a1001337
          WHERE cod_cia   = p_cod_cia   AND tip_docum    = p_tip_docum AND
                cod_docum = p_cod_docum AND fec_validez <= p_fec_validez;
   BEGIN
      --
      OPEN c_validez;
      FETCH c_validez
         INTO l_fec_validez;
      CLOSE c_validez;
      --
      dc_k_a1001337.p_lee_1(p_cod_cia,
                            p_tip_docum,
                            p_cod_docum,
                            l_fec_validez);
      --
      reg_a1001337 := dc_k_a1001337.f_devuelve_reg;
      --
      IF reg_a1001337.cod_emp_agt IS NULL
      THEN
         g_existe := FALSE;
      ELSE
         g_existe := TRUE;
      END IF;
      --
      l_clave := ' a1001337 PK:[' || TO_CHAR(p_cod_cia) || '-' || p_tip_docum || '-' ||
                 p_cod_docum || '-' ||
                 TO_CHAR(p_fec_validez,
                         'DDMMYYYY') || ']';
      --
      p_comprueba_error(l_clave);
      --
   END p_lee_datos_a1001337_1;
   -- --------------------------------------------------------------
   PROCEDURE p_lee_datos_a1001337_2(p_cod_cia     a1001337.cod_cia     %TYPE,
                                    p_cod_tercero a1001337.cod_agt     %TYPE,
                                    p_fec_validez a1001337.fec_validez %TYPE)
   IS
      --
      l_clave        VARCHAR2(80);
      l_fec_validez  a1001337.fec_validez%TYPE;
      --
      CURSOR c_validez IS
         SELECT MAX(fec_validez)
           FROM a1001337
          WHERE cod_cia = p_cod_cia AND cod_emp_agt = p_cod_tercero AND
                fec_validez <= p_fec_validez;
      --
   BEGIN
      --
      OPEN c_validez;
      FETCH c_validez
         INTO l_fec_validez;
      CLOSE c_validez;
      --
      dc_k_a1001337.p_lee(p_cod_cia,
                          p_cod_tercero,
                          l_fec_validez);
      --
      reg_a1001337 := dc_k_a1001337.f_devuelve_reg;
      --
      IF reg_a1001337.cod_emp_agt IS NULL
      THEN
         g_existe := FALSE;
      ELSE
         g_existe := TRUE;
      END IF;
      --
      l_clave := ' a1001337 PK:[' || TO_CHAR(p_cod_cia) || '-' ||
                 TO_CHAR(p_cod_tercero) || '-' ||
                 TO_CHAR(p_fec_validez,
                         'DDMMYYYY') || ']';
      --
      p_comprueba_error(l_clave);
      --
   END p_lee_datos_a1001337_2;
   --
   PROCEDURE p_lee_datos_a1001338(p_cod_cia     a1001338.cod_cia     %TYPE,
                                  p_tip_docum   a1001338.tip_docum   %TYPE,
                                  p_cod_docum   a1001338.cod_docum   %TYPE,
                                  p_fec_validez a1001338.fec_validez %TYPE) IS
      --
      l_clave VARCHAR2(80);
      --
      l_fec_validez a1001337.fec_validez%TYPE;
      --
      CURSOR c_validez IS
         SELECT MAX(fec_validez)
           FROM a1001338
          WHERE cod_cia = p_cod_cia AND tip_docum = p_tip_docum AND
                cod_docum = p_cod_docum AND fec_validez <= p_fec_validez;
      --
   BEGIN
      --
      OPEN c_validez;
      FETCH c_validez
         INTO l_fec_validez;
      CLOSE c_validez;
      --
      OPEN c_a1001338(p_cod_cia,
                      p_tip_docum,
                      p_cod_docum,
                      l_fec_validez);
      FETCH c_a1001338
         INTO reg_a1001338;
      g_existe := c_a1001338%FOUND;
      CLOSE c_a1001338;
      --
      l_clave := ' a1001338 PK:[' || TO_CHAR(p_cod_cia) || '-' || p_tip_docum || '-' ||
                 p_cod_docum || '-' ||
                 TO_CHAR(p_fec_validez,
                         'DDMMYYYY') || ']';
      --
      p_comprueba_error(l_clave);
      --
   END p_lee_datos_a1001338;
   -- --------------------------------------------------------------
   PROCEDURE p_lee_datos_a1001338_1(p_cod_cia     a1001338.cod_cia        %TYPE,
                                    p_cod_tercero a1001338.cod_supervisor %TYPE,
                                    p_fec_validez a1001338.fec_validez    %TYPE) IS
      --
      l_clave VARCHAR2(80);
      --
      l_fec_validez a1001338.fec_validez%TYPE;
      --
      CURSOR c_validez IS
         SELECT MAX(fec_validez)
           FROM a1001338
          WHERE cod_cia = p_cod_cia AND cod_supervisor = p_cod_tercero AND
                fec_validez <= p_fec_validez;
      --
   BEGIN
      --
      OPEN c_validez;
      FETCH c_validez
         INTO l_fec_validez;
      CLOSE c_validez;
      --
      OPEN c_a1001338_1(p_cod_cia,
                        p_cod_tercero,
                        l_fec_validez);
      FETCH c_a1001338_1
         INTO reg_a1001338;
      g_existe := c_a1001338_1%FOUND;
      CLOSE c_a1001338_1;
      --
      l_clave := ' a1001338 PK:[' || TO_CHAR(p_cod_cia) || '-' ||
                 TO_CHAR(p_cod_tercero) || '-' ||
                 TO_CHAR(p_fec_validez,
                         'DDMMYYYY') || ']';
      --
      p_comprueba_error(l_clave);
      --
   END p_lee_datos_a1001338_1;
   -- --------------------------------------------------------------
   PROCEDURE p_lee_datos_a1001339(p_cod_cia   a1001339.cod_cia   %TYPE,
                                  p_tip_docum a1001339.tip_docum %TYPE,
                                  p_cod_docum a1001339.cod_docum %TYPE) IS
      l_clave VARCHAR2(80);
      --
   BEGIN
      OPEN c_a1001339(p_cod_cia,
                      p_tip_docum,
                      p_cod_docum);
      FETCH c_a1001339
         INTO reg_a1001339;
      g_existe := c_a1001339%FOUND;
      CLOSE c_a1001339;
      --
      l_clave := ' a1001339 PK:[' || TO_CHAR(p_cod_cia) || '-' || p_tip_docum || '-' ||
                 p_cod_docum || ']';
      --
      p_comprueba_error(l_clave);
      --
   END p_lee_datos_a1001339;
   -- --------------------------------------------------------------
   PROCEDURE p_lee_datos_a1001339_1(p_cod_cia     a1001339.cod_cia        %TYPE,
                                    p_cod_tercero a1001339.cod_supervisor %TYPE)
   IS
      --
      l_clave VARCHAR2(80);
      --
   BEGIN
      OPEN c_a1001339_1(p_cod_cia,
                        p_cod_tercero);
      FETCH c_a1001339_1
         INTO reg_a1001339;
      g_existe := c_a1001339_1%FOUND;
      CLOSE c_a1001339_1;
      --
      l_clave := ' a1001339 PK:[' || TO_CHAR(p_cod_cia) || '-' || p_cod_tercero || '/';
      --
      p_comprueba_error(l_clave);
      --
   END p_lee_datos_a1001339_1;
   -- --------------------------------------------------------------
   PROCEDURE p_lee_datos_a1000600_1(p_cod_cia   a1000600.cod_cia %TYPE,
                                    p_tip_docum a1000600.tip_docum_aseguradora%TYPE,
                                    p_cod_docum a1000600.cod_docum_aseguradora%TYPE) IS
      --
      l_clave VARCHAR2(80);
      --
   BEGIN
      OPEN c_a1000600_1(p_cod_cia,
                        p_tip_docum,
                        p_cod_docum);
      FETCH c_a1000600_1
         INTO reg_a1000600;
      g_existe := c_a1000600_1%FOUND;
      CLOSE c_a1000600_1;
      --
      l_clave := ' a1000600 PK:[' || TO_CHAR(p_cod_cia) || '-' || p_tip_docum || '-' ||
                 p_cod_docum || ']';
      --
      p_comprueba_error(l_clave);
      --
   END p_lee_datos_a1000600_1;
   -- --------------------------------------------------------------
   PROCEDURE p_lee_datos_a1000600_2(p_cod_cia     a1000600.cod_cia            %TYPE,
                                    p_cod_tercero a1000600.cod_cia_aseguradora%TYPE) IS
      --
      l_clave VARCHAR2(80);
      --
   BEGIN
      OPEN c_a1000600_2(p_cod_cia,
                        p_cod_tercero);
      FETCH c_a1000600_2
         INTO reg_a1000600;
      g_existe := c_a1000600_2%FOUND;
      CLOSE c_a1000600_2;
      --
      l_clave := ' a1000600 PK:[' || TO_CHAR(p_cod_cia) || '-' ||
                 TO_CHAR(p_cod_tercero) || ']';
      --
      p_comprueba_error(l_clave);
      --
   END p_lee_datos_a1000600_2;
   -- --------------------------------------------------------------
   PROCEDURE p_lee_datos_g2000157_1(p_cod_cia   g2000157.cod_cia   %TYPE,
                                    p_tip_docum g2000157.tip_docum %TYPE,
                                    p_cod_docum g2000157.cod_docum %TYPE) IS
      l_clave VARCHAR2(80);
      --
   BEGIN
      OPEN c_g2000157_1(p_cod_cia,
                        p_tip_docum,
                        p_cod_docum);
      FETCH c_g2000157_1
         INTO reg_g2000157;
      g_existe := c_g2000157_1%FOUND;
      CLOSE c_g2000157_1;
      --
      l_clave := ' g2000157 PK:[' || TO_CHAR(p_cod_cia) || '-' || p_tip_docum || '-' ||
                 p_cod_docum || ']';
      --
      p_comprueba_error(l_clave);
      --
   END p_lee_datos_g2000157_1;
   -- --------------------------------------------------------------
   PROCEDURE p_lee_datos_g2000157_2(p_cod_cia     g2000157.cod_cia     %TYPE,
                                    p_cod_tercero g2000157.cod_cia_rea %TYPE) IS
      --
      --
      l_clave VARCHAR2(80);
      --
   BEGIN
      OPEN c_g2000157_2(p_cod_cia,
                        p_cod_tercero);
      FETCH c_g2000157_2
         INTO reg_g2000157;
      g_existe := c_g2000157_2%FOUND;
      CLOSE c_g2000157_2;
      --
      l_clave := ' g2000157 PK:[' || TO_CHAR(p_cod_cia) || '-' ||
                 TO_CHAR(p_cod_tercero) || ']';
      --
      p_comprueba_error(l_clave);
      --
   END p_lee_datos_g2000157_2;
   -- --------------------------------------------------------------
   PROCEDURE p_lee_datos_g2000155_1(p_cod_cia   g2000155.cod_cia   %TYPE,
                                    p_tip_docum g2000155.tip_docum %TYPE,
                                    p_cod_docum g2000155.cod_docum %TYPE) IS
      --
      --
      l_clave VARCHAR2(80);
      --
   BEGIN
      --
      OPEN c_g2000155_1(p_cod_cia,
                        p_tip_docum,
                        p_cod_docum);
      FETCH c_g2000155_1
         INTO reg_g2000155;
      g_existe := c_g2000155_1%FOUND;
      CLOSE c_g2000155_1;
      --
      l_clave := ' g2000155 PK:[' || TO_CHAR(p_cod_cia) || '-' || p_tip_docum || '-' ||
                 p_cod_docum || ']';
      --
      p_comprueba_error(l_clave);
      --
   END p_lee_datos_g2000155_1;
   -- --------------------------------------------------------------
   PROCEDURE p_lee_datos_g2000155_2(p_cod_cia     g2000155.cod_cia    %TYPE,
                                    p_cod_tercero g2000155.cod_broker %TYPE) IS
      --
      --
      l_clave VARCHAR2(80);
      --
   BEGIN
      --
      OPEN c_g2000155_2(p_cod_cia,
                        p_cod_tercero);
      FETCH c_g2000155_2
         INTO reg_g2000155;
      g_existe := c_g2000155_2%FOUND;
      CLOSE c_g2000155_2;
      --
      l_clave := ' g2000155 PK:[' || TO_CHAR(p_cod_cia) || '-' ||
                 TO_CHAR(p_cod_tercero) || ']';
      --
      p_comprueba_error(l_clave);
      --
   END p_lee_datos_g2000155_2;
   --
   /*
   || ----------------------- p_lee -----------------------------
   */
   --
   PROCEDURE p_lee(p_cod_cia         a1001300.cod_cia        %TYPE,
                   p_tip_docum       a1001300.tip_docum      %TYPE,
                   p_cod_docum       a1001300.cod_docum      %TYPE,
                   p_cod_tercero     a1001300.cod_tercero    %TYPE,
                   p_fec_validez     a1001300.fec_validez    %TYPE,
                   p_cod_act_tercero a1001300.cod_act_tercero%TYPE)
   IS
   BEGIN
      --
      p_lee(p_cod_cia          => p_cod_cia        ,
            p_tip_docum        => p_tip_docum      ,
            p_cod_docum        => p_cod_docum      ,
            p_cod_tercero      => p_cod_tercero    ,
            p_fec_validez      => p_fec_validez    ,
            p_cod_act_tercero  => p_cod_act_tercero,
            p_num_secu_cta_tar => NULL             );
      --
   END p_lee;
   /*
   || ----------------------- p_lee -----------------------------
   */
   PROCEDURE p_lee(p_cod_cia          a1001300.cod_cia         %TYPE,
                   p_tip_docum        a1001300.tip_docum       %TYPE,
                   p_cod_docum        a1001300.cod_docum       %TYPE,
                   p_cod_tercero      a1001300.cod_tercero     %TYPE,
                   p_fec_validez      a1001300.fec_validez     %TYPE,
                   p_cod_act_tercero  a1001300.cod_act_tercero %TYPE,
                   p_num_secu_cta_tar a1002201.num_secu_cta_tar%TYPE)
   IS
   BEGIN
      --
      l_fec_validez := NVL(p_fec_validez,
                           TRUNC(SYSDATE));
      --
      g_cod_act_tercero := p_cod_act_tercero;
      --
      IF g_cod_act_tercero = 1
      THEN
         reg_a1001331 := reg_a1001331_null;
      ELSIF g_cod_act_tercero = 2
      THEN
         reg_a1001332 := reg_a1001332_null;
      ELSIF g_cod_act_tercero = 8
      THEN
         reg_a1001338 := reg_a1001338_null;
      ELSIF g_cod_act_tercero = 9
      THEN
         reg_a1001339 := reg_a1001339_null;
      ELSIF g_cod_act_tercero = 13
      THEN
         reg_a1000600 := reg_a1000600_null;
      ELSIF g_cod_act_tercero = 14
      THEN
         reg_g2000157 := reg_g2000157_null;
      ELSIF g_cod_act_tercero = 16
      THEN
         reg_g2000155 := reg_g2000155_null;
      ELSIF g_cod_act_tercero = 37
      THEN
         reg_a1001337 := reg_a1001337_null;
      ELSE
         reg_a1001300 := reg_a1001300_null;
      END IF;
      --
      IF p_cod_act_tercero = 1 --ASEGURADOS
      THEN
         --
         p_lee_datos_a1001331(p_cod_cia  ,
                              p_tip_docum,
                              p_cod_docum);
         --
      ELSIF p_cod_act_tercero = 2 --AGENTES
      THEN
         IF p_cod_tercero IS NULL
         THEN
            p_lee_datos_a1001332_1(p_cod_cia,
                                   p_tip_docum,
                                   p_cod_docum,
                                   l_fec_validez);
         ELSE
            p_lee_datos_a1001332_2(p_cod_cia,
                                   p_cod_tercero,
                                   l_fec_validez);
         END IF;
      ELSIF p_cod_act_tercero = 8 --SUPERVISORES
      THEN
         IF p_cod_tercero IS NULL
         THEN
            p_lee_datos_a1001338(p_cod_cia,
                                 p_tip_docum,
                                 p_cod_docum,
                                 l_fec_validez);
         ELSE
            p_lee_datos_a1001338_1(p_cod_cia,
                                   p_cod_tercero,
                                   l_fec_validez);
         END IF;
      ELSIF p_cod_act_tercero = 9 --TRAMITADORES
      THEN
         IF p_cod_tercero IS NULL
         THEN
            p_lee_datos_a1001339(p_cod_cia,
                                 p_tip_docum,
                                 p_cod_docum);
         ELSE
            p_lee_datos_a1001339_1(p_cod_cia,
                                   p_cod_tercero);
         END IF;
      ELSIF p_cod_act_tercero = 13 --CIAS. ASEGURADORAS
      THEN
         IF p_cod_tercero IS NULL
         THEN
            p_lee_datos_a1000600_1(p_cod_cia,
                                   p_tip_docum,
                                   p_cod_docum);
         ELSE
            p_lee_datos_a1000600_2(p_cod_cia,
                                   p_cod_tercero);
         END IF;
      ELSIF p_cod_act_tercero = 14 --CIAS. REASEGURADORAS
      THEN
         IF p_cod_tercero IS NULL
         THEN
            p_lee_datos_g2000157_1(p_cod_cia,
                                   p_tip_docum,
                                   p_cod_docum);
         ELSE
            p_lee_datos_g2000157_2(p_cod_cia,
                                   p_cod_tercero);
         END IF;
      ELSIF p_cod_act_tercero = 16 --BROKERS
      THEN
         IF p_cod_tercero IS NULL
         THEN
            p_lee_datos_g2000155_1(p_cod_cia,
                                   p_tip_docum,
                                   p_cod_docum);
         ELSE
            p_lee_datos_g2000155_2(p_cod_cia,
                                   p_cod_tercero);
         END IF;
      ELSIF p_cod_act_tercero = 37 -- EMP AGENTES
      THEN
         IF p_cod_tercero IS NULL
         THEN
            --
            p_lee_datos_a1001337_1(p_cod_cia,
                                   p_tip_docum,
                                   p_cod_docum,
                                   l_fec_validez);
         ELSE
            p_lee_datos_a1001337_2(p_cod_cia,
                                   p_cod_tercero,
                                   l_fec_validez);
         END IF;
      ELSE
         IF p_cod_tercero IS NULL
         THEN
            p_lee_datos_a1001300_1(p_cod_cia,
                                   p_tip_docum,
                                   p_cod_docum,
                                   p_cod_act_tercero,
                                   l_fec_validez);
         ELSE
            p_lee_datos_a1001300_2(p_cod_cia,
                                   p_cod_tercero,
                                   p_cod_act_tercero,
                                   l_fec_validez);
         END IF;
      END IF;
      --
      IF f_es_multicuenta = 'S'
      THEN
         -- Si el tercero no tiene ninguna cuenta, este p_lee no falla.
         dc_k_a1002201.p_lee(p_cod_cia          => p_cod_cia          ,
                             p_tip_docum        => p_tip_docum        ,
                             p_cod_docum        => p_cod_docum        ,
                             p_cod_act_tercero  => p_cod_act_tercero  ,
                             p_num_secu_cta_tar => p_num_secu_cta_tar );
      END IF;
      --
   END p_lee;
   --
   /*
   || ----------------------- p_lee_nom_completo --------------------
   */
   PROCEDURE p_lee_nom_completo(p_cod_cia         a1001300.cod_cia        %TYPE,
                                p_tip_docum       a1001300.tip_docum      %TYPE,
                                p_cod_docum       a1001300.cod_docum      %TYPE,
                                p_cod_tercero     a1001300.cod_tercero    %TYPE,
                                p_fec_validez     a1001300.fec_validez    %TYPE,
                                p_cod_act_tercero a1001300.cod_act_tercero%TYPE)
   IS
   BEGIN
      --
      p_lee_nom_completo(p_cod_cia          => p_cod_cia        ,
                         p_tip_docum        => p_tip_docum      ,
                         p_cod_docum        => p_cod_docum      ,
                         p_cod_tercero      => p_cod_tercero    ,
                         p_fec_validez      => p_fec_validez    ,
                         p_cod_act_tercero  => p_cod_act_tercero,
                         p_num_secu_cta_tar => NULL             );
      --
   END p_lee_nom_completo;
   /*
   || ----------------------- p_lee_nom_completo --------------------
   */
   PROCEDURE p_lee_nom_completo(p_cod_cia          a1001300.cod_cia         %TYPE,
                                p_tip_docum        a1001300.tip_docum       %TYPE,
                                p_cod_docum        a1001300.cod_docum       %TYPE,
                                p_cod_tercero      a1001300.cod_tercero     %TYPE,
                                p_fec_validez      a1001300.fec_validez     %TYPE,
                                p_cod_act_tercero  a1001300.cod_act_tercero %TYPE,
                                p_num_secu_cta_tar a1002201.num_secu_cta_tar%TYPE)
   IS
   BEGIN
      --
      -- v 1.29
      dc_k_v1001390.p_lee(p_cod_cia         => p_cod_cia        ,
                          p_cod_act_tercero => p_cod_act_tercero,
                          p_tip_docum       => p_tip_docum      ,
                          p_cod_docum       => p_cod_docum      ,
                          p_cod_tercero     => p_cod_tercero    );
      --
      p_lee(p_cod_cia          => p_cod_cia                                      ,
            p_tip_docum        => NVL(p_tip_docum  , dc_k_v1001390.f_tip_docum)  ,
            p_cod_docum        => NVL(p_cod_docum  , dc_k_v1001390.f_cod_docum)  ,
            p_cod_tercero      => NVL(p_cod_tercero, dc_k_v1001390.f_cod_tercero),
            p_fec_validez      => p_fec_validez                                  ,
            p_cod_act_tercero  => p_cod_act_tercero                              ,
            p_num_secu_cta_tar => p_num_secu_cta_tar                             );
      -- v 1.29
      --
   END p_lee_nom_completo;
   --
   /*
   || ----------------------- p_lee_con_poliza ------------------
   */
   PROCEDURE p_lee_con_poliza(p_cod_cia         a1001300.cod_cia        %TYPE,
                              p_tip_docum       a1001300.tip_docum      %TYPE,
                              p_cod_docum       a1001300.cod_docum      %TYPE,
                              p_cod_tercero     a1001300.cod_tercero    %TYPE,
                              p_fec_validez     a1001300.fec_validez    %TYPE,
                              p_cod_act_tercero a1001300.cod_act_tercero%TYPE,
                              p_num_poliza      a1000802.num_poliza     %TYPE,
                              p_num_spto        a1000802.num_spto       %TYPE,
                              p_num_riesgo      a1000802.num_riesgo     %TYPE) IS
   BEGIN
      --
      p_lee_con_poliza(p_cod_cia          => p_cod_cia        ,
                       p_tip_docum        => p_tip_docum      ,
                       p_cod_docum        => p_cod_docum      ,
                       p_cod_tercero      => p_cod_tercero    ,
                       p_fec_validez      => p_fec_validez    ,
                       p_cod_act_tercero  => p_cod_act_tercero,
                       p_num_poliza       => p_num_poliza     ,
                       p_num_spto         => p_num_spto       ,
                       p_num_riesgo       => p_num_riesgo     ,
                       p_num_secu_cta_tar => trn.NULO         );
      --
   END p_lee_con_poliza;
   --
   /*
   || ----------------------- p_lee_con_poliza ------------------
   */
   PROCEDURE p_lee_con_poliza(p_cod_cia          a1001300.cod_cia           %TYPE,
                              p_tip_docum        a1001300.tip_docum         %TYPE,
                              p_cod_docum        a1001300.cod_docum         %TYPE,
                              p_cod_tercero      a1001300.cod_tercero       %TYPE,
                              p_fec_validez      a1001300.fec_validez       %TYPE,
                              p_cod_act_tercero  a1001300.cod_act_tercero   %TYPE,
                              p_num_poliza       a1000802.num_poliza        %TYPE,
                              p_num_spto         a1000802.num_spto          %TYPE,
                              p_num_riesgo       a1000802.num_riesgo        %TYPE,
                              p_num_secu_cta_tar a1002201.num_secu_cta_tar  %TYPE)
   IS
   --
   BEGIN
      --
      g_cod_act_tercero := p_cod_act_tercero;
      --
      IF    g_cod_act_tercero != trn.UNO
         OR p_num_poliza      IS NULL
      THEN
         --
         p_lee(p_cod_cia         => p_cod_cia        ,
               p_tip_docum       => p_tip_docum      ,
               p_cod_docum       => p_cod_docum      ,
               p_cod_tercero     => p_cod_tercero    ,
               p_fec_validez     => p_fec_validez    ,
               p_cod_act_tercero => p_cod_act_tercero);
         --
      ELSE
         --
         p_lee_datos_a1001331_poliza(p_cod_cia          => p_cod_cia         ,
                                     p_tip_docum        => p_tip_docum       ,
                                     p_cod_docum        => p_cod_docum       ,
                                     p_num_poliza       => p_num_poliza      ,
                                     p_num_spto         => p_num_spto        ,
                                     p_num_riesgo       => p_num_riesgo      ,
                                     p_num_secu_cta_tar => p_num_secu_cta_tar);
         --
      END IF;
      --
   END p_lee_con_poliza;
   --
   /*
   || ----------------------- p_nom_fec_nac ------------------
   */
   PROCEDURE p_nom_fec_nac(p_cod_cia         IN a1001331.cod_cia       %TYPE,
                           p_tip_docum       IN a1001331.tip_docum     %TYPE,
                           p_cod_docum       IN a1001331.cod_docum     %TYPE,
                           p_nom_tercero    OUT a1001399.nom_tercero   %TYPE,
                           p_nom2_tercero   OUT a1001399.nom2_tercero  %TYPE,
                           p_ape1_tercero   OUT a1001399.ape1_tercero  %TYPE,
                           p_ape2_tercero   OUT a1001399.ape2_tercero  %TYPE,
                           p_nom_sufijo     OUT g1010031.nom_valor     %TYPE,
                           p_fec_nacimiento OUT a1001331.fec_nacimiento%TYPE)
   IS
   BEGIN
      --
      p_nom_tercero    := '';
      p_nom2_tercero   := '';
      p_ape1_tercero   := '';
      p_ape2_tercero   := '';
      p_nom_sufijo     := '';
      p_fec_nacimiento := '';
      --
      dc_k_v1001390.p_lee(p_cod_cia         => p_cod_cia        ,
                          p_cod_act_tercero => DC.ACT_ASEGURADO ,
                          p_tip_docum       => p_tip_docum      ,
                          p_cod_docum       => p_cod_docum      ,
                          p_cod_tercero     => trn.NULO         );
      --
      p_nom_tercero := dc_k_v1001390.f_nom_tercero;
      --
      p_ape1_tercero := dc_k_v1001390.f_ape1_tercero;
      --
      p_ape2_tercero := dc_k_v1001390.f_ape2_tercero;
      --
      p_nom2_tercero := dc_k_v1001390.f_nom2_tercero;
      --
      IF dc_k_v1001390.f_tip_sufijo_nombre IS NOT NULL
      THEN
         --
         p_nom_sufijo :=  ss_f_nom_valor(p_cod_campo  => 'TIPO_SUFIJO_NOMBRE'             ,
                                         p_cod_ramo   => '999'                            ,
                                         p_cod_valor  => dc_k_v1001390.f_tip_sufijo_nombre,
                                         p_cod_idioma => trn_k_global.cod_idioma          );
         --
      END IF;
      --
      dc_k_terceros.p_lee(p_cod_cia         => p_cod_cia        ,
                          p_tip_docum       => p_tip_docum      ,
                          p_cod_docum       => p_cod_docum      ,
                          p_cod_tercero     => trn.NULO         ,
                          p_fec_validez     => trn.NULO         ,
                          p_cod_act_tercero => DC.ACT_ASEGURADO );
      --
      p_fec_nacimiento := dc_k_terceros.f_fec_nacimiento;
      --
   END p_nom_fec_nac;
   --
   -- --------------------------------------------------------------
   -- ==============================================================
   /*
   ||               Funciones del Package
   */
   -- --------------------------------------------------------------
   FUNCTION f_cod_nacionalidad RETURN VARCHAR2 IS
      l_cod_nacionalidad a1001331.cod_nacionalidad%TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      l_cod_nacionalidad := reg_a1001331.cod_nacionalidad;
      --
      RETURN l_cod_nacionalidad;
      --
   END f_cod_nacionalidad;
   -- --------------------------------------------------------------
   FUNCTION f_tip_domicilio RETURN NUMBER IS
      l_tip_domicilio a1001300.tip_domicilio%TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_tip_domicilio := reg_a1001331.tip_domicilio;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_tip_domicilio := reg_a1001332.tip_domicilio;
      ELSIF g_cod_act_tercero = 8
      THEN
         l_tip_domicilio := reg_a1001338.tip_domicilio;
      ELSIF g_cod_act_tercero = 9
      THEN
         l_tip_domicilio := reg_a1001339.tip_domicilio;
      ELSIF g_cod_act_tercero = 13
      THEN
         l_tip_domicilio := reg_a1000600.tip_domicilio;
      ELSIF g_cod_act_tercero = 14
      THEN
         l_tip_domicilio := reg_g2000157.tip_domicilio;
      ELSIF g_cod_act_tercero = 16
      THEN
         l_tip_domicilio := reg_g2000155.tip_domicilio;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_tip_domicilio := reg_a1001337.tip_domicilio;
      ELSE
         l_tip_domicilio := reg_a1001300.tip_domicilio;
      END IF;
      --
      RETURN l_tip_domicilio;
      --
   END f_tip_domicilio;
   -- --------------------------------------------------------------
   FUNCTION f_nom_domicilio1 RETURN VARCHAR2 IS
      l_nom_domicilio1 a1001300.nom_domicilio1%TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_nom_domicilio1 := reg_a1001331.nom_domicilio1;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_nom_domicilio1 := reg_a1001332.nom_domicilio1;
      ELSIF g_cod_act_tercero = 8
      THEN
         l_nom_domicilio1 := reg_a1001338.nom_domicilio1;
      ELSIF g_cod_act_tercero = 9
      THEN
         l_nom_domicilio1 := reg_a1001339.nom_domicilio1;
      ELSIF g_cod_act_tercero = 13
      THEN
         l_nom_domicilio1 := reg_a1000600.nom_domicilio1;
      ELSIF g_cod_act_tercero = 14
      THEN
         l_nom_domicilio1 := reg_g2000157.nom_domicilio1;
      ELSIF g_cod_act_tercero = 16
      THEN
         l_nom_domicilio1 := reg_g2000155.nom_domicilio1;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_nom_domicilio1 := reg_a1001337.nom_domicilio1;
      ELSE
         l_nom_domicilio1 := reg_a1001300.nom_domicilio1;
      END IF;
      --
      RETURN l_nom_domicilio1;
   END f_nom_domicilio1;
   -- --------------------------------------------------------------
   FUNCTION f_nom_domicilio2 RETURN VARCHAR2 IS
      l_nom_domicilio2 a1001300.nom_domicilio2%TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_nom_domicilio2 := reg_a1001331.nom_domicilio2;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_nom_domicilio2 := reg_a1001332.nom_domicilio2;
      ELSIF g_cod_act_tercero = 8
      THEN
         l_nom_domicilio2 := reg_a1001338.nom_domicilio2;
      ELSIF g_cod_act_tercero = 9
      THEN
         l_nom_domicilio2 := reg_a1001339.nom_domicilio2;
      ELSIF g_cod_act_tercero = 13
      THEN
         l_nom_domicilio2 := reg_a1000600.nom_domicilio2;
      ELSIF g_cod_act_tercero = 14
      THEN
         l_nom_domicilio2 := reg_g2000157.nom_domicilio2;
      ELSIF g_cod_act_tercero = 16
      THEN
         l_nom_domicilio2 := reg_g2000155.nom_domicilio2;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_nom_domicilio2 := reg_a1001337.nom_domicilio2;
      ELSE
         l_nom_domicilio2 := reg_a1001300.nom_domicilio2;
      END IF;
      --
      RETURN l_nom_domicilio2;
   END f_nom_domicilio2;
   -- --------------------------------------------------------------
   FUNCTION f_nom_domicilio3 RETURN VARCHAR2 IS
      l_nom_domicilio3 a1001300.nom_domicilio3%TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_nom_domicilio3 := reg_a1001331.nom_domicilio3;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_nom_domicilio3 := reg_a1001332.nom_domicilio3;
      ELSIF g_cod_act_tercero = 13
      THEN
         l_nom_domicilio3 := reg_a1000600.nom_domicilio3;
      ELSIF g_cod_act_tercero = 14
      THEN
         l_nom_domicilio3 := reg_g2000157.nom_domicilio3;
      ELSIF g_cod_act_tercero = 16
      THEN
         l_nom_domicilio3 := reg_g2000155.nom_domicilio3;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_nom_domicilio3 := reg_a1001337.nom_domicilio3;
      ELSE
         l_nom_domicilio3 := reg_a1001300.nom_domicilio3;
      END IF;
      --
      RETURN l_nom_domicilio3;
   END f_nom_domicilio3;
   -- --------------------------------------------------------------
   FUNCTION f_num_apartado RETURN VARCHAR2 IS
      l_num_apartado a1001300.num_apartado %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_num_apartado := reg_a1001331.num_apartado;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_num_apartado := reg_a1001332.num_apartado;
      ELSIF g_cod_act_tercero = 13
      THEN
         l_num_apartado := reg_a1000600.num_apartado;
      ELSIF g_cod_act_tercero = 14
      THEN
         l_num_apartado := reg_g2000157.num_apartado;
      ELSIF g_cod_act_tercero = 16
      THEN
         l_num_apartado := reg_g2000155.num_apartado;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_num_apartado := reg_a1001337.num_apartado;
      ELSE
         l_num_apartado := reg_a1001300.num_apartado;
      END IF;
      --
      RETURN l_num_apartado;
   END f_num_apartado;
   -- --------------------------------------------------------------
   FUNCTION f_cod_localidad RETURN NUMBER IS
      l_cod_localidad a1001300.cod_localidad %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_cod_localidad := reg_a1001331.cod_localidad;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_cod_localidad := reg_a1001332.cod_localidad;
      ELSIF g_cod_act_tercero = 8
      THEN
         l_cod_localidad := reg_a1001338.cod_localidad;
      ELSIF g_cod_act_tercero = 9
      THEN
         l_cod_localidad := reg_a1001339.cod_localidad;
      ELSIF g_cod_act_tercero = 13
      THEN
         l_cod_localidad := reg_a1000600.cod_localidad;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_cod_localidad := reg_a1001337.cod_localidad;
      ELSE
         l_cod_localidad := reg_a1001300.cod_localidad;
      END IF;
      --
      RETURN l_cod_localidad;
   END f_cod_localidad;
   -- --------------------------------------------------------------
   FUNCTION f_nom_localidad RETURN VARCHAR2 IS
      l_nom_localidad a1001300.nom_localidad %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_nom_localidad := reg_a1001331.nom_localidad;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_nom_localidad := reg_a1001332.nom_localidad;
      ELSIF g_cod_act_tercero = 8
      THEN
         l_nom_localidad := reg_a1001338.nom_localidad;
      ELSIF g_cod_act_tercero = 9
      THEN
         l_nom_localidad := reg_a1001339.nom_localidad;
      ELSIF g_cod_act_tercero = 13
      THEN
         l_nom_localidad := reg_a1000600.nom_localidad;
      ELSIF g_cod_act_tercero = 14
      THEN
         l_nom_localidad := reg_g2000157.nom_localidad;
      ELSIF g_cod_act_tercero = 16
      THEN
         l_nom_localidad := reg_g2000155.nom_localidad;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_nom_localidad := reg_a1001337.nom_localidad;
      ELSE
         l_nom_localidad := reg_a1001300.nom_localidad;
      END IF;
      --
      RETURN l_nom_localidad;
   END f_nom_localidad;
   -- --------------------------------------------------------------
   FUNCTION f_cod_pais RETURN VARCHAR2 IS
      l_cod_pais a1001300.cod_pais %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_cod_pais := reg_a1001331.cod_pais;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_cod_pais := reg_a1001332.cod_pais;
      ELSIF g_cod_act_tercero = 8
      THEN
         l_cod_pais := reg_a1001338.cod_pais;
      ELSIF g_cod_act_tercero = 9
      THEN
         l_cod_pais := reg_a1001339.cod_pais;
      ELSIF
      --   g_cod_act_tercero = 13
      --THEN
      --   l_cod_pais       := reg_a1000600.cod_pais      ;
      --ELSIF
       g_cod_act_tercero = 14
      THEN
         l_cod_pais := reg_g2000157.cod_pais;
      ELSIF g_cod_act_tercero = 16
      THEN
         l_cod_pais := reg_g2000155.cod_pais;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_cod_pais := reg_a1001337.cod_pais;
      ELSE
         l_cod_pais := reg_a1001300.cod_pais;
      END IF;
      --
      RETURN l_cod_pais;
   END f_cod_pais;
   -- --------------------------------------------------------------
   FUNCTION f_cod_prov RETURN NUMBER IS
      l_cod_prov a1001300.cod_prov %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_cod_prov := reg_a1001331.cod_prov;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_cod_prov := reg_a1001332.cod_prov;
      ELSIF g_cod_act_tercero = 8
      THEN
         l_cod_prov := reg_a1001338.cod_prov;
      ELSIF g_cod_act_tercero = 9
      THEN
         l_cod_prov := reg_a1001339.cod_prov;
      ELSIF g_cod_act_tercero = 13
      THEN
         l_cod_prov := reg_a1000600.cod_prov;
         --ELSIF
         --   g_cod_act_tercero = 14
         --THEN
         --   l_cod_prov       := reg_g2000157.cod_prov      ;
         --ELSIF
         --   g_cod_act_tercero = 16
         --THEN
         --   l_cod_prov       := reg_g2000155.cod_prov      ;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_cod_prov := reg_a1001337.cod_prov;
      ELSE
         l_cod_prov := reg_a1001300.cod_prov;
      END IF;
      --
      RETURN l_cod_prov;
   END f_cod_prov;
   -- --------------------------------------------------------------
   FUNCTION f_cod_postal RETURN VARCHAR2 IS
      l_cod_postal a1001300.cod_postal %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_cod_postal := reg_a1001331.cod_postal;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_cod_postal := reg_a1001332.cod_postal;
      ELSIF g_cod_act_tercero = 8
      THEN
         l_cod_postal := reg_a1001338.cod_postal;
      ELSIF g_cod_act_tercero = 9
      THEN
         l_cod_postal := reg_a1001339.cod_postal;
      ELSIF g_cod_act_tercero = 13
      THEN
         l_cod_postal := reg_a1000600.cod_postal;
      ELSIF g_cod_act_tercero = 14
      THEN
         l_cod_postal := reg_g2000157.cod_postal;
      ELSIF g_cod_act_tercero = 16
      THEN
         l_cod_postal := reg_g2000155.cod_postal;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_cod_postal := reg_a1001337.cod_postal;
      ELSE
         l_cod_postal := reg_a1001300.cod_postal;
      END IF;
      --
      RETURN l_cod_postal;
   END f_cod_postal;
   -- --------------------------------------------------------------
   FUNCTION f_cod_estado RETURN NUMBER IS
      l_cod_estado a1001300.cod_estado %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_cod_estado := reg_a1001331.cod_estado;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_cod_estado := reg_a1001332.cod_estado;
      ELSIF g_cod_act_tercero = 8
      THEN
         l_cod_estado := reg_a1001338.cod_estado;
      ELSIF g_cod_act_tercero = 9
      THEN
         l_cod_estado := reg_a1001339.cod_estado;
      ELSIF g_cod_act_tercero = 13
      THEN
         l_cod_estado := reg_a1000600.cod_estado;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_cod_estado := reg_a1001337.cod_estado;
      ELSE
         l_cod_estado := reg_a1001300.cod_estado;
      END IF;
      --
      RETURN l_cod_estado;
   END f_cod_estado;
   -- --------------------------------------------------------------
   FUNCTION f_txt_etiqueta1 RETURN VARCHAR2 IS
      l_txt_etiqueta1 a1001300.txt_etiqueta1 %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_txt_etiqueta1 := reg_a1001331.txt_etiqueta1;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_txt_etiqueta1 := reg_a1001332.txt_etiqueta1;
      ELSIF
      --   g_cod_act_tercero = 8
      --THEN
      --   l_txt_etiqueta1  := reg_a1001338.txt_etiqueta1 ;
      --ELSIF
      --   g_cod_act_tercero = 9
      --THEN
      --   l_txt_etiqueta1  := reg_a1001339.txt_etiqueta1 ;
      --ELSIF
       g_cod_act_tercero = 13
      THEN
         l_txt_etiqueta1 := reg_a1000600.txt_etiqueta1;
      ELSIF g_cod_act_tercero = 14
      THEN
         l_txt_etiqueta1 := reg_g2000157.txt_etiqueta1;
      ELSIF g_cod_act_tercero = 16
      THEN
         l_txt_etiqueta1 := reg_g2000155.txt_etiqueta1;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_txt_etiqueta1 := reg_a1001337.txt_etiqueta1;
      ELSE
         l_txt_etiqueta1 := reg_a1001300.txt_etiqueta1;
      END IF;
      --
      RETURN l_txt_etiqueta1;
   END f_txt_etiqueta1;
   -- --------------------------------------------------------------
   FUNCTION f_txt_etiqueta2 RETURN VARCHAR2 IS
      l_txt_etiqueta2 a1001300.txt_etiqueta2 %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_txt_etiqueta2 := reg_a1001331.txt_etiqueta2;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_txt_etiqueta2 := reg_a1001332.txt_etiqueta2;
      ELSIF
      --   g_cod_act_tercero = 8
      --THEN
      --   l_txt_etiqueta2  := reg_a1001338.txt_etiqueta2 ;
      --ELSIF
      --   g_cod_act_tercero = 9
      --THEN
      --   l_txt_etiqueta2  := reg_a1001339.txt_etiqueta2 ;
      --ELSIF
       g_cod_act_tercero = 13
      THEN
         l_txt_etiqueta2 := reg_a1000600.txt_etiqueta2;
      ELSIF g_cod_act_tercero = 14
      THEN
         l_txt_etiqueta2 := reg_g2000157.txt_etiqueta2;
      ELSIF g_cod_act_tercero = 16
      THEN
         l_txt_etiqueta2 := reg_g2000155.txt_etiqueta2;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_txt_etiqueta2 := reg_a1001337.txt_etiqueta2;
      ELSE
         l_txt_etiqueta2 := reg_a1001300.txt_etiqueta2;
      END IF;
      --
      RETURN l_txt_etiqueta2;
   END f_txt_etiqueta2;
   -- --------------------------------------------------------------
   FUNCTION f_txt_etiqueta3 RETURN VARCHAR2 IS
      l_txt_etiqueta3 a1001300.txt_etiqueta3 %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_txt_etiqueta3 := reg_a1001331.txt_etiqueta3;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_txt_etiqueta3 := reg_a1001332.txt_etiqueta3;
      ELSIF
      --   g_cod_act_tercero = 8
      --THEN
      --   l_txt_etiqueta3  := reg_a1001338.txt_etiqueta3 ;
      --ELSIF
      --   g_cod_act_tercero = 9
      --THEN
      --   l_txt_etiqueta3  := reg_a1001339.txt_etiqueta3 ;
      --ELSIF
       g_cod_act_tercero = 13
      THEN
         l_txt_etiqueta3 := reg_a1000600.txt_etiqueta3;
      ELSIF g_cod_act_tercero = 14
      THEN
         l_txt_etiqueta3 := reg_g2000157.txt_etiqueta3;
      ELSIF g_cod_act_tercero = 16
      THEN
         l_txt_etiqueta3 := reg_g2000155.txt_etiqueta3;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_txt_etiqueta3 := reg_a1001337.txt_etiqueta3;
      ELSE
         l_txt_etiqueta3 := reg_a1001300.txt_etiqueta3;
      END IF;
      --
      RETURN l_txt_etiqueta3;
   END f_txt_etiqueta3;
   -- --------------------------------------------------------------
   FUNCTION f_txt_etiqueta4 RETURN VARCHAR2 IS
      l_txt_etiqueta4 a1001300.txt_etiqueta4 %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_txt_etiqueta4 := reg_a1001331.txt_etiqueta4;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_txt_etiqueta4 := reg_a1001332.txt_etiqueta4;
      ELSIF
      --   g_cod_act_tercero = 8
      --THEN
      --   l_txt_etiqueta4  := reg_a1001338.txt_etiqueta4 ;
      --ELSIF
      --   g_cod_act_tercero = 9
      --THEN
      --   l_txt_etiqueta4  := reg_a1001339.txt_etiqueta4 ;
      --ELSIF
       g_cod_act_tercero = 13
      THEN
         l_txt_etiqueta4 := reg_a1000600.txt_etiqueta4;
      ELSIF g_cod_act_tercero = 14
      THEN
         l_txt_etiqueta4 := reg_g2000157.txt_etiqueta4;
      ELSIF g_cod_act_tercero = 16
      THEN
         l_txt_etiqueta4 := reg_g2000155.txt_etiqueta4;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_txt_etiqueta4 := reg_a1001337.txt_etiqueta4;
      ELSE
         l_txt_etiqueta4 := reg_a1001300.txt_etiqueta4;
      END IF;
      --
      RETURN l_txt_etiqueta4;
   END f_txt_etiqueta4;
   -- --------------------------------------------------------------
   FUNCTION f_txt_etiqueta5 RETURN VARCHAR2 IS
      l_txt_etiqueta5 a1001300.txt_etiqueta5 %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_txt_etiqueta5 := reg_a1001331.txt_etiqueta5;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_txt_etiqueta5 := reg_a1001332.txt_etiqueta5;
      ELSIF
      --   g_cod_act_tercero = 8
      --THEN
      --   l_txt_etiqueta5  := reg_a1001338.txt_etiqueta5 ;
      --ELSIF
      --   g_cod_act_tercero = 9
      --THEN
      --   l_txt_etiqueta5  := reg_a1001339.txt_etiqueta5 ;
      --ELSIF
       g_cod_act_tercero = 13
      THEN
         l_txt_etiqueta5 := reg_a1000600.txt_etiqueta5;
      ELSIF g_cod_act_tercero = 14
      THEN
         l_txt_etiqueta5 := reg_g2000157.txt_etiqueta5;
      ELSIF g_cod_act_tercero = 16
      THEN
         l_txt_etiqueta5 := reg_g2000155.txt_etiqueta5;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_txt_etiqueta5 := reg_a1001337.txt_etiqueta5;
      ELSE
         l_txt_etiqueta5 := reg_a1001300.txt_etiqueta5;
      END IF;
      --
      RETURN l_txt_etiqueta5;
   END f_txt_etiqueta5;
   -- --------------------------------------------------------------
   FUNCTION f_tlf_pais RETURN VARCHAR2 IS
      l_tlf_pais a1001300.tlf_pais %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_tlf_pais := reg_a1001331.tlf_pais;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_tlf_pais := reg_a1001332.tlf_pais;
      ELSIF g_cod_act_tercero = 8
      THEN
         l_tlf_pais := reg_a1001338.tlf_pais;
      ELSIF g_cod_act_tercero = 9
      THEN
         l_tlf_pais := reg_a1001339.tlf_pais;
      ELSIF g_cod_act_tercero = 13
      THEN
         l_tlf_pais := reg_a1000600.tlf_pais;
      ELSIF g_cod_act_tercero = 14
      THEN
         l_tlf_pais := reg_g2000157.tlf_pais;
      ELSIF g_cod_act_tercero = 16
      THEN
         l_tlf_pais := reg_g2000155.tlf_pais;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_tlf_pais := reg_a1001337.tlf_pais;
      ELSE
         l_tlf_pais := reg_a1001300.tlf_pais;
      END IF;
      --
      RETURN l_tlf_pais;
   END f_tlf_pais;
   -- --------------------------------------------------------------
   FUNCTION f_tlf_zona RETURN VARCHAR2 IS
      l_tlf_zona a1001300.tlf_zona %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_tlf_zona := reg_a1001331.tlf_zona;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_tlf_zona := reg_a1001332.tlf_zona;
      ELSIF g_cod_act_tercero = 8
      THEN
         l_tlf_zona := reg_a1001338.tlf_zona;
      ELSIF g_cod_act_tercero = 9
      THEN
         l_tlf_zona := reg_a1001339.tlf_zona;
      ELSIF g_cod_act_tercero = 13
      THEN
         l_tlf_zona := reg_a1000600.tlf_zona;
      ELSIF g_cod_act_tercero = 14
      THEN
         l_tlf_zona := reg_g2000157.tlf_zona;
      ELSIF g_cod_act_tercero = 16
      THEN
         l_tlf_zona := reg_g2000155.tlf_zona;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_tlf_zona := reg_a1001337.tlf_zona;
      ELSE
         l_tlf_zona := reg_a1001300.tlf_zona;
      END IF;
      --
      RETURN l_tlf_zona;
   END f_tlf_zona;
   -- --------------------------------------------------------------
   FUNCTION f_tlf_numero RETURN VARCHAR2 IS
      l_tlf_numero a1001300.tlf_numero %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_tlf_numero := reg_a1001331.tlf_numero;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_tlf_numero := reg_a1001332.tlf_numero;
      ELSIF g_cod_act_tercero = 8
      THEN
         l_tlf_numero := reg_a1001338.tlf_numero;
      ELSIF g_cod_act_tercero = 9
      THEN
         l_tlf_numero := reg_a1001339.tlf_numero;
      ELSIF g_cod_act_tercero = 13
      THEN
         l_tlf_numero := reg_a1000600.tlf_numero;
      ELSIF g_cod_act_tercero = 14
      THEN
         l_tlf_numero := reg_g2000157.tlf_numero;
      ELSIF g_cod_act_tercero = 16
      THEN
         l_tlf_numero := reg_g2000155.tlf_numero;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_tlf_numero := reg_a1001337.tlf_numero;
      ELSE
         l_tlf_numero := reg_a1001300.tlf_numero;
      END IF;
      --
      RETURN l_tlf_numero;
   END f_tlf_numero;
   -- --------------------------------------------------------------
   FUNCTION f_fec_nacimiento RETURN DATE IS
      l_fec_nacimiento a1001300.fec_nacimiento%TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_fec_nacimiento := reg_a1001331.fec_nacimiento;
      ELSE
         l_fec_nacimiento := reg_a1001300.fec_nacimiento;
      END IF;
      --
      RETURN l_fec_nacimiento;
   END f_fec_nacimiento;
   -- --------------------------------------------------------------
   FUNCTION f_mca_sexo RETURN VARCHAR2 IS
      l_mca_sexo a1001300.mca_sexo %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_mca_sexo := reg_a1001331.mca_sexo;
      ELSE
         l_mca_sexo := reg_a1001300.mca_sexo;
      END IF;
      --
      RETURN l_mca_sexo;
   END f_mca_sexo;
   -- --------------------------------------------------------------
   FUNCTION f_cod_agt RETURN VARCHAR2 IS
      l_cod_agt a1001337.cod_agt %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 2
      THEN
         l_cod_agt := reg_a1001332.cod_agt;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_cod_agt := reg_a1001337.cod_agt;
      END IF;
      --
      RETURN l_cod_agt;
   END f_cod_agt;
   -- --------------------------------------------------------------
   FUNCTION f_cod_est_civil RETURN VARCHAR2 IS
      l_cod_est_civil a1001300.cod_est_civil %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_cod_est_civil := reg_a1001331.cod_est_civil;
      ELSE
         l_cod_est_civil := reg_a1001300.cod_est_civil;
      END IF;
      --
      RETURN l_cod_est_civil;
   END f_cod_est_civil;
   -- --------------------------------------------------------------
   FUNCTION f_cod_profesion RETURN NUMBER IS
      l_cod_profesion a1001300.cod_profesion %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_cod_profesion := reg_a1001331.cod_profesion;
      ELSE
         l_cod_profesion := reg_a1001300.cod_profesion;
      END IF;
      --
      RETURN l_cod_profesion;
   END f_cod_profesion;
   -- --------------------------------------------------------------
   FUNCTION f_cod_ocupacion RETURN NUMBER IS
      l_cod_ocupacion a1001331.cod_ocupacion %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      l_cod_ocupacion := reg_a1001331.cod_ocupacion;
      --
      RETURN l_cod_ocupacion;
   END f_cod_ocupacion;
   -- --------------------------------------------------------------
   FUNCTION f_tip_tercero RETURN VARCHAR2 IS
      l_tip_tercero a1001300.txt_aux1 %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_tip_tercero := reg_a1001331.txt_aux1;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_tip_tercero := reg_a1001332.txt_aux1;
      ELSIF g_cod_act_tercero = 13
      THEN
         l_tip_tercero := reg_a1000600.txt_aux1;
      ELSIF g_cod_act_tercero != 1
      THEN
         l_tip_tercero := reg_a1001300.txt_aux1;
      END IF;
      --
      RETURN l_tip_tercero;
   END f_tip_tercero;
   -- --------------------------------------------------------------
   FUNCTION f_tip_agt RETURN VARCHAR2 IS
      l_tip_agt a1001332.tip_agt %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 2
      THEN
         l_tip_agt := reg_a1001332.tip_agt;
      END IF;
      --
      RETURN l_tip_agt;
   END f_tip_agt;
   -- --------------------------------------------------------------
   FUNCTION f_mca_inh
      RETURN VARCHAR2
   IS
      --
      l_mca_inh a1001300.mca_inh %TYPE;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero =  g_k_cod_act_agente  --Agentes
      THEN
         --
         l_mca_inh := reg_a1001332.mca_inh;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_supervisor -- Supervisores
      THEN
         --
         l_mca_inh := reg_a1001338.mca_inh;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_tramitador -- Tramitadores
      THEN
         --
         l_mca_inh := reg_a1001339.mca_inh;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_aseguradora  -- Aseguradoras
      THEN
         --
         l_mca_inh := reg_a1000600.mca_inh;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_reaseguradora  -- Reaseguradora
      THEN
         --
         l_mca_inh := reg_g2000157.mca_inh;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_broker  -- Broker
      THEN
         --
         l_mca_inh := reg_g2000155.mca_inh;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_empleado_agt  -- Agente empleado
      THEN
         --
         l_mca_inh := reg_a1001337.mca_inh;
         --
      ELSIF g_cod_act_tercero != g_k_cod_act_asegurado -- Terceros Comunes
      THEN
         --
         l_mca_inh := reg_a1001300.mca_inh;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_asegurado  -- Asegurado
      THEN
         --
         l_mca_inh := reg_a1001331.mca_inh;
         --
      END IF;
      --
      RETURN l_mca_inh;
      --
   END f_mca_inh;
   -- --------------------------------------------------------------
   FUNCTION f_txt_aux1
      RETURN VARCHAR2
   IS
      --
      l_txt_aux1 a1001300.txt_aux1 %TYPE;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero =  g_k_cod_act_asegurado  -- Asegurado
      THEN
         --
         l_txt_aux1 := reg_a1001331.txt_aux1;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_agente   -- Agentes
      THEN
         --
         l_txt_aux1 := reg_a1001332.txt_aux1;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_reaseguradora  -- Reaseguradora
      THEN
         --
         l_txt_aux1 := reg_g2000157.txt_aux1;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_broker  -- Brokers
      THEN
         --
         l_txt_aux1 := reg_g2000155.txt_aux1;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_asegurado   -- Asegurados
      THEN
         --
         l_txt_aux1 := reg_a1001331.txt_aux1;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_aseguradora  -- Aseguradora
      THEN
         --
         l_txt_aux1 := reg_a1000600.txt_aux1;
         --
      ELSIF g_cod_act_tercero NOT IN(g_k_cod_act_asegurado     ,
                                     g_k_cod_act_agente        ,
                                     g_k_cod_act_empleado_agt  ,
                                     g_k_cod_act_supervisor    ,
                                     g_k_cod_act_tramitador    ,
                                     g_k_cod_act_aseguradora   ,
                                     g_k_cod_act_reaseguradora ,
                                     g_k_cod_act_broker        ) --terceros comunes
      THEN
         --
         l_txt_aux1 := reg_a1001300.txt_aux1;
         --
      END IF;
      --
      RETURN l_txt_aux1;
      --
   END f_txt_aux1;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el valor del campo auxiliar 2
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_txt_aux2
      RETURN VARCHAR2
   IS
      --
      l_txt_aux2 a1001300.txt_aux2 %TYPE;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_agente  -- Agente
      THEN
         --
         l_txt_aux2 := reg_a1001332.txt_aux2;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_reaseguradora  -- Reasegurdora
      THEN
         --
         l_txt_aux2 := reg_g2000157.txt_aux2;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_broker  -- Broker
      THEN
         --
         l_txt_aux2 := reg_g2000155.txt_aux2;
         --
      ELSIF g_cod_act_tercero != g_k_cod_act_asegurado  -- No asegurado
      THEN
         --
         l_txt_aux2 := reg_a1001300.txt_aux2;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_asegurado  -- Asegurado
      THEN
         --
         l_txt_aux2 := reg_a1001331.txt_aux2;
         --
      END IF;
      --
      RETURN l_txt_aux2;
      --
   END f_txt_aux2;
   -- --------------------------------------------------------------
   FUNCTION f_txt_aux3 RETURN VARCHAR2 IS
      l_txt_aux3 a1001300.txt_aux3 %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 2
      THEN
         l_txt_aux3 := reg_a1001332.txt_aux3;
      ELSIF g_cod_act_tercero = 1
      THEN
         l_txt_aux3 := reg_a1001331.txt_aux3;
      ELSIF g_cod_act_tercero != 1
      THEN
         l_txt_aux3 := reg_a1001300.txt_aux3;
      END IF;
      --
      RETURN l_txt_aux3;
      --
   END f_txt_aux3;
   -- --------------------------------------------------------------
   FUNCTION f_cod_nivel3 RETURN NUMBER IS
      l_cod_nivel3 a1001332.cod_nivel3 %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 2
      THEN
         l_cod_nivel3 := reg_a1001332.cod_nivel3;
      ELSIF g_cod_act_tercero = 8
      THEN
         l_cod_nivel3 := reg_a1001338.cod_nivel3;
      ELSIF g_cod_act_tercero = 9
      THEN
         l_cod_nivel3 := reg_a1001339.cod_nivel3;
      ELSIF g_cod_act_tercero IN (1, 13, 14, 16)
      THEN
         l_cod_nivel3 := NULL;
      ELSE
         l_cod_nivel3 := reg_a1001300.cod_nivel3;
      END IF;
      --
      RETURN l_cod_nivel3;
   END f_cod_nivel3;
   -- --------------------------------------------------------------
   FUNCTION f_cod_canal3 RETURN VARCHAR2 IS
      l_cod_canal3 a1001332.cod_canal3 %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 2
      THEN
         l_cod_canal3 := reg_a1001332.cod_canal3;
      ELSE
         l_cod_canal3 := NULL;
      END IF;
      --
      RETURN l_cod_canal3;
   END f_cod_canal3;
   -- --------------------------------------------------------------
   FUNCTION f_cod_reten RETURN VARCHAR2 IS
      l_cod_reten a1001332.cod_reten %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 2
      THEN
         l_cod_reten := reg_a1001332.cod_reten;
      ELSE
         l_cod_reten := NULL;
      END IF;
      --
      RETURN l_cod_reten;
   END f_cod_reten;
   -- --------------------------------------------------------------
   --
   FUNCTION f_cod_compensacion
      RETURN NUMBER
   IS
      --
      l_cod_compensacion a1001332.cod_compensacion %TYPE;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero NOT IN (g_k_cod_act_asegurado    ,
                                   g_k_cod_act_agente       ,
                                   g_k_cod_act_empleado_agt ,
                                   g_k_cod_act_supervisor   ,
                                   g_k_cod_act_tramitador   ,
                                   g_k_cod_act_aseguradora  ,
                                   g_k_cod_act_reaseguradora,
                                   g_k_cod_act_broker       ) -- Terceros comunes
      THEN
         --
         l_cod_compensacion := reg_a1001300.cod_compensacion;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_asegurado
      THEN
         --
         l_cod_compensacion := reg_a1001331.cod_compensacion;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_agente
      THEN
         --
         l_cod_compensacion := reg_a1001332.cod_compensacion;
         --
      ELSIF g_cod_act_tercero IN (g_k_cod_act_supervisor   ,
                                  g_k_cod_act_tramitador   ,
                                  g_k_cod_act_aseguradora  ,
                                  g_k_cod_act_reaseguradora,
                                  g_k_cod_act_broker       )
      THEN
         --
         l_cod_compensacion := g_k_nulo;
         --
      ELSE
         --
         l_cod_compensacion := reg_a1001300.cod_compensacion;
         --
      END IF;
      --
      RETURN l_cod_compensacion;
      --
   END f_cod_compensacion;
   --
   -- --------------------------------------------------------------
   FUNCTION f_cod_imptos_dep RETURN VARCHAR2 IS
      l_cod_imptos_dep g2000155.cod_imptos_dep%TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 14
      THEN
         l_cod_imptos_dep := reg_g2000157.cod_imptos_dep;
      ELSE
         IF g_cod_act_tercero = 16
         THEN
            l_cod_imptos_dep := reg_g2000155.cod_imptos_dep;
         END IF;
      END IF;
      --
      RETURN l_cod_imptos_dep;
   END f_cod_imptos_dep;
   -- --------------------------------------------------------------
   FUNCTION f_cod_imptos_renta RETURN VARCHAR2 IS
      l_cod_imptos_renta g2000155.cod_imptos_renta%TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 14
      THEN
         l_cod_imptos_renta := reg_g2000157.cod_imptos_renta;
      ELSE
         IF g_cod_act_tercero = 16
         THEN
            l_cod_imptos_renta := reg_g2000155.cod_imptos_renta;
         END IF;
      END IF;
      --
      RETURN l_cod_imptos_renta;
   END f_cod_imptos_renta;
   -- --------------------------------------------------------------
   FUNCTION f_tip_broker RETURN VARCHAR2 IS
      l_tip_broker g2000155.cod_imptos_renta%TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 16
      THEN
         l_tip_broker := reg_g2000155.tip_broker;
      END IF;
      --
      RETURN l_tip_broker;
   END f_tip_broker;
   -- --------------------------------------------------------------
   FUNCTION f_tip_cia_rea RETURN VARCHAR2 IS
      l_tip_cia_rea g2000157.tip_cia_rea %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 14
      THEN
         l_tip_cia_rea := reg_g2000157.tip_cia_rea;
      END IF;
      --
      RETURN l_tip_cia_rea;
   END f_tip_cia_rea;
   -- --------------------------------------------------------------
   FUNCTION f_fax_numero RETURN VARCHAR2 IS
      l_fax_numero a1001300.fax_numero %TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_fax_numero := reg_a1001331.fax_numero;
      ELSIF g_cod_act_tercero = 8
      THEN
         l_fax_numero := reg_a1001338.fax_numero;
      ELSIF g_cod_act_tercero = 9
      THEN
         l_fax_numero := reg_a1001339.fax_numero;
      ELSE
         l_fax_numero := reg_a1001300.fax_numero;
      END IF;
      --
      RETURN l_fax_numero;
   END f_fax_numero;
   -- --------------------------------------------------------------
   FUNCTION f_cod_entidad RETURN VARCHAR2 IS
      l_cod_entidad a1002201.cod_entidad%TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF f_es_multicuenta = 'N'
      THEN
         IF g_cod_act_tercero = 1
         THEN
            l_cod_entidad := reg_a1001331.cod_entidad;
         ELSIF g_cod_act_tercero = 2
         THEN
            l_cod_entidad := reg_a1001332.cod_entidad;
         ELSIF g_cod_act_tercero = 13
         THEN
            l_cod_entidad := reg_a1000600.cod_entidad;
         ELSIF g_cod_act_tercero = 14
         THEN
            l_cod_entidad := reg_g2000157.cod_entidad;
         ELSIF g_cod_act_tercero = 16
         THEN
            l_cod_entidad := reg_g2000155.cod_entidad;
         ELSIF g_cod_act_tercero IN (8, 9)
         THEN
            l_cod_entidad := NULL;
         ELSE
            l_cod_entidad := reg_a1001300.cod_entidad;
         END IF;
         --
      ELSE
         --
         IF g_cod_act_tercero IN (8, 9)
         THEN
            l_cod_entidad := NULL;
         ELSE
            l_cod_entidad := dc_k_a1002201.f_cod_entidad;
         END IF;
         --
      END IF;
      --
      RETURN l_cod_entidad;
      --
   END f_cod_entidad;
   -- --------------------------------------------------------------
   FUNCTION f_cod_oficina RETURN VARCHAR2 IS
      l_cod_oficina a1002201.cod_oficina%TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF f_es_multicuenta = 'N'
      THEN
         --
         IF g_cod_act_tercero = 1
         THEN
            l_cod_oficina := reg_a1001331.cod_oficina;
         ELSIF g_cod_act_tercero = 2
         THEN
            l_cod_oficina := reg_a1001332.cod_oficina;
         ELSIF g_cod_act_tercero = 13
         THEN
            l_cod_oficina := reg_a1000600.cod_oficina;
         ELSIF g_cod_act_tercero = 14
         THEN
            l_cod_oficina := reg_g2000157.cod_oficina;
         ELSIF g_cod_act_tercero = 16
         THEN
            l_cod_oficina := reg_g2000155.cod_oficina;
         ELSIF g_cod_act_tercero IN (8, 9)
         THEN
            l_cod_oficina := NULL;
         ELSE
            l_cod_oficina := reg_a1001300.cod_oficina;
         END IF;
      ELSE
         --
         IF g_cod_act_tercero IN (8, 9)
         THEN
            l_cod_oficina := NULL;
         ELSE
            l_cod_oficina := dc_k_a1002201.f_cod_oficina;
         END IF;
      END IF;
      --
      RETURN l_cod_oficina;
   END f_cod_oficina;
   -- --------------------------------------------------------------
   FUNCTION f_cta_cte RETURN VARCHAR2 IS
      l_cta_cte a1002201.cta_cte%TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF f_es_multicuenta = 'N'
      THEN
         IF g_cod_act_tercero = 1
         THEN
            l_cta_cte := reg_a1001331.cta_cte;
         ELSIF g_cod_act_tercero = 2
         THEN
            l_cta_cte := reg_a1001332.cta_cte;
         ELSIF g_cod_act_tercero = 13
         THEN
            l_cta_cte := reg_a1000600.cta_cte;
         ELSIF g_cod_act_tercero = 14
         THEN
            l_cta_cte := reg_g2000157.cta_cte;
         ELSIF g_cod_act_tercero = 16
         THEN
            l_cta_cte := reg_g2000155.cta_cte;
         ELSIF g_cod_act_tercero IN (8, 9)
         THEN
            l_cta_cte := NULL;
         ELSE
            l_cta_cte := reg_a1001300.cta_cte;
         END IF;
      ELSE
         IF g_cod_act_tercero IN (8, 9)
         THEN
            l_cta_cte := NULL;
         ELSE
            l_cta_cte := dc_k_a1002201.f_cta_cte;
         END IF;
         --
      END IF;
      --
      RETURN l_cta_cte;
      --
   END f_cta_cte;
   --
   /* -----------------------------------------------------
   || f_nom_titular_cta:
   ||
   || Devuelve el campo nom_titular_cta
   */ -----------------------------------------------------
   --
   FUNCTION f_nom_titular_cta
      RETURN a1001331.nom_titular_cta%TYPE
   IS
   --
      l_nom_titular_cta a1001331.nom_titular_cta%TYPE;
   --
   BEGIN
      --
      p_comprueba_error(g_k_nulo);
      --
      IF f_es_multicuenta = g_k_no
      THEN
         --
         IF g_cod_act_tercero = g_k_uno
         THEN
            --
            l_nom_titular_cta := reg_a1001331.nom_titular_cta;
            --
         ELSE
            --
            l_nom_titular_cta := g_k_nulo;
            --
         END IF;
         --
      ELSE
         --
         l_nom_titular_cta := g_k_nulo;
         --
      END IF;
      --
      RETURN l_nom_titular_cta;
      --
   END f_nom_titular_cta;
   -- --------------------------------------------------------------
   FUNCTION f_cta_dc RETURN VARCHAR2 IS
      l_cta_dc a1002201.cta_dc%TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF f_es_multicuenta = 'N'
      THEN
         IF g_cod_act_tercero = 1
         THEN
            l_cta_dc := reg_a1001331.cta_dc;
         ELSIF g_cod_act_tercero = 2
         THEN
            l_cta_dc := reg_a1001332.cta_dc;
         ELSIF g_cod_act_tercero = 13
         THEN
            l_cta_dc := reg_a1000600.cta_dc;
         ELSIF g_cod_act_tercero = 14
         THEN
            l_cta_dc := reg_g2000157.cta_dc;
         ELSIF g_cod_act_tercero = 16
         THEN
            l_cta_dc := reg_g2000155.cta_dc;
         ELSIF g_cod_act_tercero IN (8, 9)
         THEN
            l_cta_dc := NULL;
         ELSE
            l_cta_dc := reg_a1001300.cta_dc;
         END IF;
      ELSE
         IF g_cod_act_tercero IN (8, 9)
         THEN
            l_cta_dc := NULL;
         ELSE
            l_cta_dc := dc_k_a1002201.f_cta_dc;
         END IF;
         --
      END IF;
      --
      RETURN l_cta_dc;
   END f_cta_dc;
   -- --------------------------------------------------------------
   FUNCTION f_tip_tarjeta RETURN NUMBER IS
      l_tip_tarjeta a1001331.tip_tarjeta%TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_tip_tarjeta := reg_a1001331.tip_tarjeta;
      END IF;
      --
      RETURN l_tip_tarjeta;
   END f_tip_tarjeta;
   -- --------------------------------------------------------------
   FUNCTION f_cod_tarjeta RETURN NUMBER IS
      l_cod_tarjeta a1001331.cod_tarjeta%TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_cod_tarjeta := reg_a1001331.cod_tarjeta;
      END IF;
      --
      RETURN l_cod_tarjeta;
   END f_cod_tarjeta;
   -- --------------------------------------------------------------
   FUNCTION f_num_tarjeta RETURN VARCHAR2 IS
      l_num_tarjeta a1001331.num_tarjeta%TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_num_tarjeta := reg_a1001331.num_tarjeta;
      END IF;
      --
      RETURN l_num_tarjeta;
   END f_num_tarjeta;
   -- --------------------------------------------------------------
   FUNCTION f_cod_prov_etiqueta RETURN NUMBER IS
      --
      l_cod_prov_etiqueta a1001331.cod_prov_etiqueta%TYPE;
      --
   BEGIN
      --
      l_cod_prov_etiqueta := NULL;
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_cod_prov_etiqueta := reg_a1001331.cod_prov_etiqueta;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_cod_prov_etiqueta := reg_a1001332.cod_prov_etiqueta;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_cod_prov_etiqueta := reg_a1001337.cod_prov_etiqueta;
      ELSIF g_cod_act_tercero = 13
      THEN
         l_cod_prov_etiqueta := reg_a1000600.cod_prov_etiqueta;
      ELSIF g_cod_act_tercero IN (8, 9, 14, 16)
      THEN
         l_cod_prov_etiqueta := NULL;
      ELSE
         l_cod_prov_etiqueta := reg_a1001300.cod_prov_etiqueta;
      END IF;
      --
      RETURN l_cod_prov_etiqueta;
      --
   END f_cod_prov_etiqueta;
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 99/02/01
   || Se a?aden los campos :
   || - cod_localidad_etiqueta
   || - nom_localidad_etiqueta
   */ --------------------------------------------------------
   FUNCTION f_cod_localidad_etiqueta RETURN NUMBER IS
      --
      l_cod_localidad_etiqueta a1001331.cod_localidad_etiqueta%TYPE;
      --
   BEGIN
      --
      l_cod_localidad_etiqueta := NULL;
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_cod_localidad_etiqueta := reg_a1001331.cod_localidad_etiqueta;
         --
      END IF;
      --
      RETURN l_cod_localidad_etiqueta;
      --
   END f_cod_localidad_etiqueta;
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 99/02/01
   || Se a?aden los campos :
   || - cod_localidad_etiqueta
   || - nom_localidad_etiqueta
   */ --------------------------------------------------------
   FUNCTION f_nom_localidad_etiqueta RETURN VARCHAR2 IS
      --
      l_nom_localidad_etiqueta a1001331.nom_localidad_etiqueta%TYPE;
      --
   BEGIN
      --
      l_nom_localidad_etiqueta := NULL;
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_nom_localidad_etiqueta := reg_a1001331.nom_localidad_etiqueta;
         --
      END IF;
      --
      RETURN l_nom_localidad_etiqueta;
      --
   END f_nom_localidad_etiqueta;
   --
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 99/09/28
   || Creacion
   */ --------------------------------------------------------
   FUNCTION f_cod_pais_com RETURN VARCHAR2 IS
      --
      l_retorno reg_a1001331.cod_pais_com%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.cod_pais_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_cod_pais_com;
   --
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 99/09/28
   || Creacion
   */ --------------------------------------------------------
   FUNCTION f_cod_estado_com RETURN NUMBER IS
      --
      l_retorno reg_a1001331.cod_estado_com%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.cod_estado_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_cod_estado_com;
   --
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 99/09/28
   || Creacion
   */ --------------------------------------------------------
   FUNCTION f_cod_prov_com RETURN NUMBER IS
      --
      l_retorno reg_a1001331.cod_prov_com%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.cod_prov_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_cod_prov_com;
   --
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 99/09/28
   || Creacion
   */ --------------------------------------------------------
   FUNCTION f_cod_localidad_com RETURN NUMBER IS
      --
      l_retorno reg_a1001331.cod_localidad_com%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.cod_localidad_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_cod_localidad_com;
   --
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 99/09/28
   || Creacion
   */ --------------------------------------------------------
   FUNCTION f_cod_postal_com RETURN VARCHAR2 IS
      --
      l_retorno reg_a1001331.cod_postal_com%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.cod_postal_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_cod_postal_com;
   --
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 99/09/28
   || Creacion
   */ --------------------------------------------------------
   FUNCTION f_tip_domicilio_com RETURN NUMBER IS
      --
      l_retorno reg_a1001331.tip_domicilio_com%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.tip_domicilio_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_tip_domicilio_com;
   --
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 99/09/28
   || Creacion
   */ --------------------------------------------------------
   FUNCTION f_nom_domicilio1_com RETURN VARCHAR2 IS
      --
      l_retorno a1001331.nom_domicilio1_com%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.nom_domicilio1_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_nom_domicilio1_com;
   --
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 99/09/28
   || Creacion
   */ --------------------------------------------------------
   FUNCTION f_nom_domicilio2_com RETURN VARCHAR2 IS
      --
      l_retorno a1001331.nom_domicilio2_com%TYPE;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.nom_domicilio2_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_nom_domicilio2_com;
   --
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 99/09/28
   || Creacion
   */ --------------------------------------------------------
   FUNCTION f_nom_domicilio3_com RETURN VARCHAR2 IS
      --
      l_retorno a1001331.nom_domicilio3_com%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.nom_domicilio3_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_nom_domicilio3_com;
   --
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 99/09/28
   || Creacion
   */ --------------------------------------------------------
   FUNCTION f_nom_localidad_com RETURN VARCHAR2 IS
      --
      l_retorno a1001331.nom_localidad_com%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.nom_localidad_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_nom_localidad_com;
   --
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 99/09/28
   || Creacion
   */ --------------------------------------------------------
   FUNCTION f_num_apartado_com RETURN VARCHAR2 IS
      --
      l_retorno a1001331.num_apartado_com%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.num_apartado_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_num_apartado_com;
   --
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 99/09/28
   || Creacion
   */ --------------------------------------------------------
   FUNCTION f_tlf_pais_com RETURN VARCHAR2 IS
      --
      l_retorno a1001331.tlf_pais_com%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.tlf_pais_com;
         --
      ELSIF g_cod_act_tercero = 2
      THEN
         --
         l_retorno := reg_a1001332.tlf_pais_com;
         --
      ELSIF g_cod_act_tercero = 37
      THEN
         --
         l_retorno := reg_a1001337.tlf_pais_com;
      ELSE
         --
         l_retorno := reg_a1001300.tlf_pais_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_tlf_pais_com;
   --
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 99/09/28
   || Creacion
   */ --------------------------------------------------------
   FUNCTION f_tlf_zona_com RETURN VARCHAR2 IS
      --
      l_retorno a1001331.tlf_zona_com%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.tlf_zona_com;
         --
      ELSIF g_cod_act_tercero = 2
      THEN
         --
         l_retorno := reg_a1001332.tlf_zona_com;
         --
      ELSIF g_cod_act_tercero = 37
      THEN
         --
         l_retorno := reg_a1001337.tlf_zona_com;
         --
      ELSE
         --
         l_retorno := reg_a1001300.tlf_zona_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_tlf_zona_com;
   --
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 99/09/28
   || Creacion
   */ --------------------------------------------------------
   FUNCTION f_tlf_numero_com RETURN VARCHAR2 IS
      --
      l_retorno a1001331.tlf_numero_com%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.tlf_numero_com;
         --
      ELSIF g_cod_act_tercero = 2
      THEN
         --
         l_retorno := reg_a1001332.tlf_numero_com;
         --
      ELSIF g_cod_act_tercero = 37
      THEN
         --
         l_retorno := reg_a1001337.tlf_numero_com;
         --
      ELSE
         --
         l_retorno := reg_a1001300.tlf_numero_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_tlf_numero_com;
   --
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 99/09/28
   || Creacion
   */ --------------------------------------------------------
   FUNCTION f_fax_numero_com RETURN VARCHAR2 IS
      --
      l_retorno a1001331.fax_numero_com%TYPE;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.fax_numero_com;
         --
      ELSIF g_cod_act_tercero = 2
      THEN
         --
         l_retorno := reg_a1001332.fax_numero_com;
         --
      ELSIF g_cod_act_tercero = 37
      THEN
         --
         l_retorno := reg_a1001337.fax_numero_com;
         --
      ELSE
         --
         l_retorno := reg_a1001300.fax_numero_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_fax_numero_com;
   --
   /* -------------------- MODIFICACIONES --------------------
   || Javier    - 02/10/11
   || Creacion
   */ --------------------------------------------------------
   FUNCTION f_tlf_movil RETURN VARCHAR2 IS
      --
      l_retorno a1001331.tlf_movil%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.tlf_movil;
         --
      END IF;
      --
      IF l_retorno IS NULL
      THEN
         l_retorno := dc_k_v1001390.f_tlf_movil;
      END IF;
      --
      RETURN l_retorno;
      --
   END f_tlf_movil;
   --
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 99/09/28
   || Creacion
   */ --------------------------------------------------------
   FUNCTION f_email_com RETURN VARCHAR2 IS
      --
      l_retorno a1001331.email_com%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.email_com;
         --
      ELSIF g_cod_act_tercero = 2
      THEN
         --
         l_retorno := reg_a1001332.email_com;
         --
      ELSIF g_cod_act_tercero = 37
      THEN
         --
         l_retorno := reg_a1001337.email_com;
         --
      ELSE
         --
         l_retorno := reg_a1001300.email_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_email_com;
   --
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 00/06/05
   || Creacion
   */ --------------------------------------------------------
   FUNCTION f_cod_ejecutivo RETURN NUMBER IS
      --
      l_retorno a1001332.cod_ejecutivo%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 2
      THEN
         --
         l_retorno := reg_a1001332.cod_ejecutivo;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_cod_ejecutivo;
   --
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 00/06/05
   || Creacion
   */ --------------------------------------------------------
   FUNCTION f_cod_org RETURN NUMBER IS
      --
      l_retorno a1001332.cod_org%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 2
      THEN
         --
         l_retorno := reg_a1001332.cod_org;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_cod_org;
   --
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 00/06/05
   || Creacion
   */ --------------------------------------------------------
   --
   FUNCTION f_cod_asesor RETURN NUMBER IS
      --
      l_retorno a1001332.cod_asesor%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 2
      THEN
         --
         l_retorno := reg_a1001332.cod_asesor;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_cod_asesor;
   --
   /* -------------------- MODIFICACIONES --------------------
   || Antonio   - 00/07/28
   || Creacion
   */ --------------------------------------------------------
   --
   FUNCTION f_fec_carnet_con RETURN DATE IS
      --
      l_retorno a1001331.fec_carnet_con%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.fec_carnet_con;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_fec_carnet_con;
   --
   -- --------------------------------------------------------------
   FUNCTION f_cod_grp_tercero RETURN VARCHAR2 IS
      l_cod_grp_tercero a1001300.cod_grp_tercero%TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_cod_grp_tercero := reg_a1001331.cod_grp_tercero;
         --
      ELSIF g_cod_act_tercero = 2
      THEN
         --
         l_cod_grp_tercero := reg_a1001332.cod_grp_tercero;
         --
      ELSIF g_cod_act_tercero = 37
      THEN
         --
         l_cod_grp_tercero := reg_a1001337.cod_grp_tercero;
         --
      ELSIF g_cod_act_tercero NOT IN (8, 9, 13, 14, 16)
      THEN
         --
         l_cod_grp_tercero := reg_a1001300.cod_grp_tercero;
         --
      END IF;
      --
      RETURN l_cod_grp_tercero;
      --
   END f_cod_grp_tercero;
   -- --------------------------------------------------------------
   FUNCTION f_txt_email RETURN VARCHAR2 IS
      l_txt_email a1001300.txt_email%TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_txt_email := reg_a1001331.txt_email;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_txt_email := reg_a1001332.txt_email;
      ELSIF g_cod_act_tercero = 13
      THEN
         l_txt_email := reg_a1000600.txt_email;
      ELSIF g_cod_act_tercero = 14
      THEN
         l_txt_email := reg_g2000157.txt_email;
      ELSIF g_cod_act_tercero = 16
      THEN
         l_txt_email := reg_g2000155.txt_email;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_txt_email := reg_a1001337.txt_email;
      ELSE
         l_txt_email := reg_a1001300.txt_email;
      END IF;
      --
      RETURN l_txt_email;
   END f_txt_email;
   -- --------------------------------------------------------------
   FUNCTION f_email RETURN VARCHAR2 IS
      l_email a1001300.email%TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_email := reg_a1001331.email;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_email := reg_a1001332.email;
      ELSIF g_cod_act_tercero = 13
      THEN
         l_email := reg_a1000600.email;
      ELSIF g_cod_act_tercero = 14
      THEN
         l_email := reg_g2000157.email;
      ELSIF g_cod_act_tercero = 16
      THEN
         l_email := reg_g2000155.email;
      ELSIF g_cod_act_tercero = 8
      THEN
         l_email := reg_a1001338.email;
      ELSIF g_cod_act_tercero = 9
      THEN
         l_email := reg_a1001339.email;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_email := reg_a1001337.email;
      ELSE
         l_email := reg_a1001300.email;
      END IF;
      --
      RETURN l_email;
   END f_email;
   -- --------------------------------------------------------------
   FUNCTION f_cod_postal_etiqueta RETURN VARCHAR2 IS
      l_cod_postal_etiqueta a1001300.cod_postal_etiqueta%TYPE;
   BEGIN
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         l_cod_postal_etiqueta := reg_a1001331.cod_postal_etiqueta;
      ELSIF g_cod_act_tercero = 2
      THEN
         l_cod_postal_etiqueta := reg_a1001332.cod_postal_etiqueta;
      ELSIF g_cod_act_tercero = 13
      THEN
         l_cod_postal_etiqueta := reg_a1000600.cod_postal_etiqueta;
      ELSIF g_cod_act_tercero = 14
      THEN
         l_cod_postal_etiqueta := reg_g2000157.cod_postal_etiqueta;
      ELSIF g_cod_act_tercero = 16
      THEN
         l_cod_postal_etiqueta := reg_g2000155.cod_postal_etiqueta;
      ELSIF g_cod_act_tercero = 37
      THEN
         l_cod_postal_etiqueta := reg_a1001337.cod_postal_etiqueta;
      ELSE
         l_cod_postal_etiqueta := reg_a1001300.cod_postal_etiqueta;
      END IF;
      --
      RETURN l_cod_postal_etiqueta;
      --
   END f_cod_postal_etiqueta;
   -- --------------------------------------------------------------
   FUNCTION f_cod_idioma RETURN VARCHAR2 IS
      --
      l_cod_idioma a1001300.cod_idioma%TYPE;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1 -- Asegurados
      THEN
         --
         l_cod_idioma := reg_a1001331.cod_idioma;
         --
      ELSIF g_cod_act_tercero = 2 -- Agentes
      THEN
         --
         l_cod_idioma := reg_a1001332.cod_idioma;
         --
      ELSIF g_cod_act_tercero = 37 -- Empleado Agentes
      THEN
         --
         l_cod_idioma := reg_a1001337.cod_idioma;
         --
      ELSIF reg_a1001300.cod_idioma IS NOT NULL
      THEN
         --
         l_cod_idioma := reg_a1001300.cod_idioma; -- Terceros Comunes
         --
      ELSE
         --
         l_cod_idioma := NULL;
         --
      END IF;
      --
      RETURN l_cod_idioma;
      --
   END f_cod_idioma;
   ----
   FUNCTION f_pct_participacion RETURN NUMBER IS
      --
      l_pct_participacion a1001337.pct_participacion%TYPE;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 37 -- Empleado Agentes
      THEN
         --
         l_pct_participacion := reg_a1001337.pct_participacion;
         --
      ELSE
         --
         l_pct_participacion := NULL;
         --
      END IF;
      --
      RETURN l_pct_participacion;
      --
   END f_pct_participacion;
   -- --------------------------------------------------------------
   -- Validaci?n de los datos referentes al domicilio
   -- --------------------------------------------------------------
   --
   /**
   || Validacion del campo:tip_domicilio
   */
   PROCEDURE p_v_tip_domicilio(p_tip_domicilio     IN a1001300.tip_domicilio %TYPE,
                               p_nom_tip_domicilio IN OUT g1010031.nom_valor %TYPE) IS
      --
   BEGIN
      --
      --@mx('I','f_valida_tip_domicilio');
      --
      IF p_tip_domicilio IS NOT NULL
      THEN
         --
         p_nom_tip_domicilio := ss_f_nom_valor('TIP_DOMICILIO',
                                               999,
                                               TO_CHAR(p_tip_domicilio),
                                               trn_k_global.cod_idioma);
         --
      END IF;
      --
   END p_v_tip_domicilio;
   --
   -- ------------------------------------------------------------
   --
   -- ------------------------------------------------------------
   --
   /**
   || Validacion del campo:nom_domicilio1
   */
   PROCEDURE p_v_nom_domicilio1(p_nom_domicilio1 IN a1001300.nom_domicilio1 %TYPE) IS
   BEGIN
      --
      NULL;
      --
   END p_v_nom_domicilio1;
   --
   -- ------------------------------------------------------------
   --
   -- ------------------------------------------------------------
   --
   /**
   || Validacion del campo:nom_domicilio2
   */
   PROCEDURE p_v_nom_domicilio2(p_nom_domicilio2 IN a1001300.nom_domicilio2 %TYPE) IS
   BEGIN
      --
      NULL;
      --
   END p_v_nom_domicilio2;
   --
   -- ------------------------------------------------------------
   --
   -- ------------------------------------------------------------
   --
   /**
   || Validacion del campo:nom_domicilio3
   */
   PROCEDURE p_v_nom_domicilio3(p_nom_domicilio3 IN a1001300.nom_domicilio3 %TYPE) IS
   BEGIN
      --
      NULL;
      --
   END p_v_nom_domicilio3;
   --
   -- ------------------------------------------------------------
   --
   -- ------------------------------------------------------------
   --
   /**
   || Validacion del campo:cod_pais
   */
   PROCEDURE p_v_cod_pais(p_cod_pais     IN a1001300.cod_pais     %TYPE,
                          p_nom_cod_pais IN OUT a1000101.nom_pais %TYPE) IS
   BEGIN
      --
      IF p_cod_pais IS NOT NULL
      THEN
         --
         p_nom_cod_pais := dc_f_nom_pais(p_cod_pais);
         --
         trn_k_global.asigna('cod_pais',
                             p_cod_pais);
         --
      END IF;
      --
   END p_v_cod_pais;
   --
   -- ------------------------------------------------------------
   --
   -- ------------------------------------------------------------
   --
   /**
   || Validacion del campo:cod_estado
   */
   PROCEDURE p_v_cod_estado(p_cod_pais   IN a1001300.cod_pais       %TYPE,
                            p_cod_estado IN a1001300.cod_estado     %TYPE,
                            p_nom_estado IN OUT a1000104.nom_estado %TYPE) IS
   BEGIN
      --
      --
      --@mx('I','f_valida_estado');
      --
      IF p_cod_estado IS NOT NULL
      THEN
         --
         dc_k_a1000104.p_lee(p_cod_pais   => p_cod_pais,
                             p_cod_estado => p_cod_estado);
         --
         IF dc_k_a1000104.f_mca_inh = 'S'
         THEN
            --
            g_cod_mensaje := 20020; --codigo inhabilitado
            g_anx_mensaje := g_k_ini_corchete || 'cod_prov' || g_k_fin_corchete;
            --
            pp_devuelve_error;
            --
         ELSE
            --
            p_nom_estado := dc_f_nom_estado(p_cod_pais,
                                            p_cod_estado);
            --
            trn_k_global.asigna('cod_estado',
                                p_cod_estado);
            --
         END IF;
         --
      END IF;
      --
      --@mx('F','f_valida_estado');
      --
   END p_v_cod_estado;
   --
   -- ------------------------------------------------------------
   --
   -- ------------------------------------------------------------
   --
   /**
   || Validacion del campo:cod_prov
   */
   PROCEDURE p_v_cod_prov(p_cod_pais   IN a1001300.cod_pais     %TYPE,
                          p_cod_estado IN a1001300.cod_estado   %TYPE,
                          p_cod_prov   IN a1001300.cod_prov     %TYPE,
                          p_nom_prov   IN OUT a1000100.nom_prov %TYPE) IS
      --
      l_cod_estado a1000100.cod_estado%TYPE;
      --
   BEGIN
      --
      --@mx('I','f_valida_provincia');
      --
      IF p_cod_prov IS NOT NULL
      THEN
         --
         dc_k_a1000100.p_lee(p_cod_pais,
                             p_cod_prov);
         --
         IF dc_k_a1000100.f_mca_inh = 'S'
         THEN
            --
            g_cod_mensaje := 20020; --codigo inhabilitado
            g_anx_mensaje := g_k_ini_corchete || 'cod_prov' || g_k_fin_corchete;
            --
            pp_devuelve_error;
            --
         ELSE
            dc_p_a1000100_1(p_cod_pais,
                            p_cod_prov,
                            l_cod_estado,
                            p_nom_prov);
            --
            trn_k_global.asigna('cod_prov',
                                p_cod_prov);
            --
         END IF;
         --
         IF l_cod_estado != p_cod_estado
         THEN
            --
            g_cod_mensaje := 20062;
            g_anx_mensaje := NULL;
            --
            pp_devuelve_error;
            --
         END IF;
         --
      END IF;
      --
   END p_v_cod_prov;
   --
   -- ------------------------------------------------------------
   --
   -- ------------------------------------------------------------
   --
   /**
   || Validacion del campo:cod_postal
   */
   /* -------------------- MODIFICACIONES --------------------
   || TRON2000  - 99/05/17
   || Creacion
   */ --------------------------------------------------------
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
                            p_mca_inh_nom_prov       IN OUT VARCHAR2                    )
   IS
      --
   BEGIN
      --
      --@mx('I','p_valida_cod_postal');
      --
      p_mca_inh_cod_pais       := 'N';
      p_mca_inh_cod_estado     := 'N';
      p_mca_inh_cod_prov       := 'N';
      p_mca_inh_cod_localidad  := 'N';
      p_mca_inh_nom_localidad  := 'N';
      p_mca_inh_tip_domicilio  := 'N';
      p_mca_inh_nom_domicilio1 := 'N';
      p_mca_inh_nom_domicilio2 := 'N';
      p_mca_inh_nom_domicilio3 := 'N';
      p_mca_inh_cod_postal     := 'N';
      --
      p_mca_inh_nom_estado := g_k_no;
      p_mca_inh_nom_prov   := g_k_no;
      --
      IF p_cod_postal IS NOT NULL
      THEN
         --
         dc_p_valida_cod_postal(p_cod_pais                 =>  p_cod_pais              ,
                                p_mca_inh_cod_pais         =>  p_mca_inh_cod_pais      ,
                                p_cod_estado               =>  p_cod_estado            ,
                                p_mca_inh_cod_estado       =>  p_mca_inh_cod_estado    ,
                                p_cod_prov                 =>  p_cod_prov              ,
                                p_mca_inh_cod_prov         =>  p_mca_inh_cod_prov      ,
                                p_cod_localidad            =>  p_cod_localidad         ,
                                p_mca_inh_cod_localidad    =>  p_mca_inh_cod_localidad ,
                                p_nom_localidad            =>  p_nom_localidad         ,
                                p_mca_inh_nom_localidad    =>  p_mca_inh_nom_localidad ,
                                p_tip_docmicilio           =>  p_tip_domicilio         ,
                                p_mca_inh_tip_domicilio    =>  p_mca_inh_tip_domicilio ,
                                p_nom_domicilio1           =>  p_nom_domicilio1        ,
                                p_mca_inh_nom_domicilio1   =>  p_mca_inh_nom_domicilio1,
                                p_nom_domicilio2           =>  p_nom_domicilio2        ,
                                p_mca_inh_nom_domicilio2   =>  p_mca_inh_nom_domicilio2,
                                p_nom_domicilio3           =>  p_nom_domicilio3        ,
                                p_mca_inh_nom_domicilio3   =>  p_mca_inh_nom_domicilio3,
                                p_cod_postal               =>  p_cod_postal            ,
                                p_mca_inh_cod_postal       =>  p_mca_inh_cod_postal    ,
                                p_nom_estado               =>  p_nom_estado            ,
                                p_mca_inh_nom_estado       =>  p_mca_inh_nom_estado    ,
                                p_nom_prov                 =>  p_nom_prov              ,
                                p_mca_inh_nom_prov         =>  p_mca_inh_nom_prov      );
         --
      END IF;
      --
      --@mx('F','p_valida_cod_postal');
      --
      /*
      EXCEPTION
       WHEN OTHERS
        THEN
         --
         pp_devuelve_error (SQLCODE);
      */
      --
   END p_v_cod_postal;
   --
   -- ------------------------------------------------------------
   --
   -- ------------------------------------------------------------
   --
   /**
   || Validacion del campo:num_apartado
   */
   PROCEDURE p_v_num_apartado(p_num_apartado IN a1001300.num_apartado %TYPE) IS
   BEGIN
      --
      NULL;
      --
   END p_v_num_apartado;
   -- ------------------------------------------------------------
   --
   -- ------------------------------------------------------------
   --
   /**
   || Validacion del campo:cod_localidad
   */
   PROCEDURE p_v_cod_localidad(p_cod_pais      IN a1001300.cod_pais          %TYPE,
                               p_cod_prov      IN a1001300.cod_prov          %TYPE,
                               p_cod_localidad IN a1001300.cod_localidad     %TYPE,
                               p_nom_localidad IN OUT a1000102.nom_localidad %TYPE) IS
   BEGIN
      --@mx('I','f_valida_localidad');
      --
      IF p_cod_localidad IS NOT NULL
      THEN
         --
         dc_k_a1000102.p_lee(p_cod_pais      => p_cod_pais,
                             p_cod_localidad => p_cod_localidad,
                             p_cod_prov      => p_cod_prov);
         --
         IF dc_k_a1000102.f_mca_inh = 'S'
         THEN
            --
            g_cod_mensaje := 20020; --codigo inhabilitado
            g_anx_mensaje := g_k_ini_corchete || 'cod_localidad' ||
                             g_k_fin_corchete;
            --
            pp_devuelve_error;
            --
         ELSE
            p_nom_localidad := dc_f_nom_localidad(p_cod_pais,
                                                  p_cod_localidad,
                                                  p_cod_prov);
            --
            trn_k_global.asigna('cod_localidad',
                                p_cod_localidad);
            --
         END IF;
         --
      END IF;
      --
   END p_v_cod_localidad;
   --
   -- ------------------------------------------------------------
   --
   -- ------------------------------------------------------------
   --
   /**
   || Validacion del campo:nom_localidad
   */
   PROCEDURE p_v_nom_localidad(p_nom_localidad IN a1001300.nom_localidad %TYPE) IS
   BEGIN
      --
      NULL;
      --
   END p_v_nom_localidad;
   --
   -- ------------------------------------------------------------
   --
   -- ------------------------------------------------------------
   --
   /**
   || Validacion del campo:txt_etiqueta1
   */
   PROCEDURE p_v_txt_etiqueta1(p_txt_etiqueta1 IN a1001300.txt_etiqueta1 %TYPE) IS
   BEGIN
      --
      NULL;
      --
   END p_v_txt_etiqueta1;
   --
   -- ------------------------------------------------------------
   --
   -- ------------------------------------------------------------
   --
   /**
   || Validacion del campo:txt_etiqueta2
   */
   PROCEDURE p_v_txt_etiqueta2(p_txt_etiqueta2 IN a1001300.txt_etiqueta2 %TYPE) IS
   BEGIN
      --
      NULL;
      --
   END p_v_txt_etiqueta2;
   --
   -- ------------------------------------------------------------
   --
   -- ------------------------------------------------------------
   --
   /**
   || Validacion del campo:txt_etiqueta3
   */
   PROCEDURE p_v_txt_etiqueta3(p_txt_etiqueta3 IN a1001300.txt_etiqueta3 %TYPE) IS
   BEGIN
      --
      NULL;
      --
   END p_v_txt_etiqueta3;
   --
   -- ------------------------------------------------------------
   --
   -- ------------------------------------------------------------
   --
   /**
   || Validacion del campo:txt_etiqueta4
   */
   PROCEDURE p_v_txt_etiqueta4(p_txt_etiqueta4 IN a1001300.txt_etiqueta4 %TYPE) IS
   BEGIN
      --
      NULL;
      --
   END p_v_txt_etiqueta4;
   --
   -- ------------------------------------------------------------
   --
   -- ------------------------------------------------------------
   --
   /**
   || Validacion del campo:txt_etiqueta5
   */
   PROCEDURE p_v_txt_etiqueta5(p_txt_etiqueta5 IN a1001300.txt_etiqueta5 %TYPE) IS
   BEGIN
      --
      NULL;
      --
   END p_v_txt_etiqueta5;
   --
   -- ------------------------------------------------------------
   --
   -- ------------------------------------------------------------
   --
   /**
   || Validacion del campo:p_v_txt_email
   */
   PROCEDURE p_v_txt_email(p_txt_email IN a1001300.txt_email %TYPE) IS
   BEGIN
      --
      NULL;
      --
   END p_v_txt_email;
   --
   /* --------------------------------------------------------
   || fp_mca_pos_secuencia_dir :
   ||
   || Devuelve marca de si es secuencial o no la peticion de la direccion
   */ --------------------------------------------------------
   --
   FUNCTION f_mca_pos_secuencia_dir RETURN VARCHAR2 IS
      --
   BEGIN
      --
      --@mx('-','fp_mca_pos_secuencia_dir');
      --
      dc_k_g1000900.p_lee(trn_k_global.cod_cia);
      --
      RETURN dc_k_g1000900.f_mca_pos_secuencia_dir;
      --
   END f_mca_pos_secuencia_dir;
   --
   -- v 1.29
   --
   FUNCTION f_tip_docum RETURN VARCHAR2 IS
   BEGIN
      --
      RETURN dc_k_v1001390.f_tip_docum;
      --
   END f_tip_docum;
   --
   FUNCTION f_cod_docum RETURN VARCHAR2 IS
   BEGIN
      --
      RETURN dc_k_v1001390.f_cod_docum;
      --
   END f_cod_docum;
   --
   FUNCTION f_ape1_tercero RETURN VARCHAR2 IS
   BEGIN
      --
      RETURN dc_k_v1001390.f_ape1_tercero;
      --
   END f_ape1_tercero;
   --
   FUNCTION f_ape2_tercero RETURN VARCHAR2 IS
   BEGIN
      --
      RETURN dc_k_v1001390.f_ape2_tercero;
      --
   END f_ape2_tercero;
   --
   FUNCTION f_nom_tercero RETURN VARCHAR2 IS
   BEGIN
      --
      RETURN dc_k_v1001390.f_nom_tercero;
      --
   END f_nom_tercero;
   --
   FUNCTION f_cod_soc_gl RETURN VARCHAR2 IS
   BEGIN
      --
      RETURN dc_k_v1001390.f_cod_soc_gl;
      --
   END f_cod_soc_gl;
   --
   FUNCTION f_mca_fisico RETURN VARCHAR2 IS
   BEGIN
      --
      RETURN dc_k_v1001390.f_mca_fisico;
      --
   END f_mca_fisico;
   --
   FUNCTION f_cod_tercero RETURN NUMBER IS
   BEGIN
      --
      RETURN dc_k_v1001390.f_cod_tercero;
      --
   END f_cod_tercero;
   --
   FUNCTION f_nom_completo RETURN VARCHAR2 IS
   BEGIN
      --
      RETURN dc_k_v1001390.f_nom_completo;
      --
   END f_nom_completo;
   --
   FUNCTION f_tip_docum_padre RETURN VARCHAR2 IS
   BEGIN
      --
      RETURN dc_k_v1001390.f_tip_docum_padre;
      --
   END f_tip_docum_padre;
   --
   FUNCTION f_cod_docum_padre RETURN VARCHAR2 IS
   BEGIN
      --
      RETURN dc_k_v1001390.f_cod_docum_padre;
      --
   END f_cod_docum_padre;
   --
   FUNCTION f_nom_alias RETURN VARCHAR2 IS
   BEGIN
      --
      RETURN dc_k_v1001390.f_nom_alias;
      --
   END f_nom_alias;
   --
   FUNCTION f_devuelve_reg RETURN v1001390%ROWTYPE IS
   BEGIN
      --
      RETURN dc_k_v1001390.f_devuelve_reg;
      --
   END f_devuelve_reg;
   --
   -- v 1.29
   --
   /* -----------------------------------------------------
   || Validacion de la entidad bancaria
   */-----------------------------------------------------
   PROCEDURE p_v_cod_entidad(p_cod_entidad   IN a5020900.cod_entidad %TYPE,
                             p_nom_entidad   OUT a5020900.nom_entidad%TYPE,
                             p_cod_error     OUT g1010020.cod_mensaje%TYPE,
                             p_texto_mensaje OUT VARCHAR2                 )
   IS
   BEGIN
   --
      dc_k_a1002201.p_v_cod_entidad(p_cod_entidad   => p_cod_entidad,
                                    p_nom_entidad   => p_nom_entidad,
                                    p_cod_error     => p_cod_error,
                                    p_texto_mensaje => p_texto_mensaje );
      --
   END p_v_cod_entidad;
   /* -----------------------------------------------------
   || Validacion de la oficina de una entidad bancaria
   */-----------------------------------------------------
   PROCEDURE p_v_cod_oficina(p_cod_entidad   IN a5020900.cod_entidad %TYPE,
                             p_cod_oficina   IN a5020910.cod_oficina %TYPE,
                             p_nom_oficina   OUT a5020910.nom_oficina%TYPE,
                             p_cod_error     OUT g1010020.cod_mensaje%TYPE,
                             p_texto_mensaje OUT VARCHAR2) IS
      --
   BEGIN
      --
      dc_k_a1002201.p_v_cod_oficina(p_cod_entidad   => p_cod_entidad,
                                    p_cod_oficina   => p_cod_oficina,
                                    p_nom_oficina   => p_nom_oficina,
                                    p_cod_error     => p_cod_error  ,
                                    p_texto_mensaje => p_texto_mensaje);
   END p_v_cod_oficina;
   --
   /* -----------------------------------------------------
   || Validacion de la cuenta corriente
   */ -----------------------------------------------------
   PROCEDURE p_v_cta_cte(p_cod_entidad   IN a5020900.cod_entidad %TYPE,
                         p_cod_oficina   IN a5020910.cod_oficina %TYPE,
                         p_cta_cte       IN a1001300.cta_cte     %TYPE,
                         p_cod_error     OUT g1010020.cod_mensaje%TYPE,
                         p_texto_mensaje OUT VARCHAR2) IS
   BEGIN
      --
      dc_k_a1002201.p_v_cta_cte (p_cod_entidad => p_cod_entidad ,
                                 p_cod_oficina => p_cod_oficina,
                                 p_cta_cte => p_cta_cte,
                                 p_cod_error => p_cod_error,
                                 p_texto_mensaje => p_texto_mensaje);
   END p_v_cta_cte;
   --
   /* -----------------------------------------------------
   || Validacion del digito de control
   */ -----------------------------------------------------
   PROCEDURE p_v_cta_dc(p_cod_entidad   IN a5020900.cod_entidad %TYPE,
                        p_cod_oficina   IN a5020910.cod_oficina %TYPE,
                        p_cta_cte       IN a1001300.cta_cte     %TYPE,
                        p_cta_dc        IN a1001300.cta_dc      %TYPE,
                        p_cod_error     OUT g1010020.cod_mensaje%TYPE,
                        p_texto_mensaje OUT VARCHAR2) IS
   BEGIN
      --
      dc_k_a1002201.p_v_cta_dc(p_cod_entidad   => p_cod_entidad  ,
                               p_cod_oficina   => p_cod_oficina  ,
                               p_cta_cte       => p_cta_cte      ,
                               p_cta_dc        => p_cta_dc       ,
                               p_cod_error     => p_cod_error    ,
                               p_texto_mensaje => p_texto_mensaje);
   END p_v_cta_dc;
   --
   --
   /*--------------------------------------------------------------------------------
   || Valida la cuenta corriente, codigos separados
   */--------------------------------------------------------------------------------
   PROCEDURE p_val_cuenta_corriente ( p_cod_entidad  IN a1002201.cod_entidad %TYPE,
                                      p_cod_oficina  IN a1002201.cod_oficina %TYPE,
                                      p_cta_dc       IN a1002201.cta_dc      %TYPE,
                                      p_cta_cte      IN a1002201.cta_cte     %TYPE)
   IS
   BEGIN
      --
      dc_k_a1002201.p_valida_cuenta_corriente(p_cod_entidad => p_cod_entidad,
                                              p_cod_oficina => p_cod_oficina,
                                              p_cta_dc      => p_cta_dc     ,
                                              p_cta_cte     => p_cta_cte    );
      --
   END p_val_cuenta_corriente;
   /*------------------------------------------------------------------------------
   || Valida la cuenta corriente, 20 posiciones
   */------------------------------------------------------------------------------
   PROCEDURE p_val_cuenta_corriente(p_cta_cte       IN VARCHAR2  )
   IS
      --
      l_cod_entidad   a1002201.cod_entidad %TYPE;
      l_cod_oficina   a1002201.cod_oficina %TYPE;
      l_cta_dc        a1002201.cta_dc      %TYPE;
      l_cta_cte       a1002201.cta_cte     %TYPE;
      --
   BEGIN
      --
      IF p_cta_cte IS NOT NULL
      THEN
         --
         IF LENGTH(p_cta_cte) != 20
         THEN
            g_cod_mensaje := NULL;
            g_anx_mensaje := 'la Cta Cte debe ser de 20 digitos ';
            --
            pp_devuelve_error;
            --
         END IF;
         --
         l_cod_entidad := SUBSTR(p_cta_cte,1,4);
         l_cod_oficina := SUBSTR(p_cta_cte,5,8);
         l_cta_dc      := SUBSTR(p_cta_cte,9,10);
         l_cta_cte     := SUBSTR(p_cta_cte,10,20);
         --
         dc_k_a1002201.p_valida_cuenta_corriente(p_cod_entidad => l_cod_entidad,
                                                 p_cod_oficina => l_cod_oficina,
                                                 p_cta_dc      => l_cta_dc     ,
                                                 p_cta_cte     => l_cta_cte    );
         --
      ELSE
         g_cod_mensaje := 20003;
         g_anx_mensaje := NULL;
         --
         pp_devuelve_error;
      END IF;
      --
      --
   END p_val_cuenta_corriente;
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
            RETURN NUMBER
   IS
   --
      l_num_secu_cta_tar       a1002201.num_secu_cta_tar%TYPE;
   --
   BEGIN
      ---
      dc_k_a1002201.p_valida_cuenta_corriente( p_cod_entidad  => p_cod_entidad ,
                                               p_cod_oficina  => p_cod_oficina ,
                                               p_cta_dc       => p_cta_dc      ,
                                               p_cta_cte      => p_cta_cte     );
      --
      l_num_secu_cta_tar := dc_k_a1002201.f_inserta_cuenta (p_cod_cia         => p_cod_cia          ,
                                                            p_tip_docum       => p_tip_docum        ,
                                                            p_cod_docum       => p_cod_docum        ,
                                                            p_cod_act_tercero => p_cod_act_tercero  ,
                                                            p_cod_tercero     => p_cod_tercero      ,
                                                            p_cod_pais        => p_cod_pais         ,
                                                            p_tip_cta_tar     => p_tip_cta_tar      ,
                                                            p_cod_entidad     => p_cod_entidad      ,
                                                            p_cod_oficina     => p_cod_oficina      ,
                                                            p_cta_cte         => p_cta_cte          ,
                                                            p_cta_dc          => p_cta_dc           ,
                                                            p_tip_cta_cte     => p_tip_cta_cte      ,
                                                            p_cod_mon_cta_tar => p_cod_mon_cta_tar  ,
                                                            p_cod_uso_cta_tar => p_cod_uso_cta_tar  );
      --
      RETURN l_num_secu_cta_tar;
      --
   END f_val_graba_cuenta;
   /*-------------------------------------------------------------------------------
   || Devuelve los campos obligatorios definidos en la a2990060.
   */-------------------------------------------------------------------------------
   FUNCTION f_devuelve_campos_obligatorios (p_cod_tabla  a2990060.cod_tabla %TYPE)
   RETURN LONG IS
   --
   BEGIN
      --
      RETURN dc_k_a2990060.f_devuelve_campos_obligatorios(p_cod_cia         => trn_k_global.cod_cia,
                                                          p_cod_tabla       => p_cod_tabla         ,
                                                          p_cod_ramo        => em.cod_ramo_gen     ,
                                                          p_cod_act_tercero => g_cod_act_tercero   ,
                                                          p_tip_benef       => dc.tip_benef_gen    ,
                                                          p_mca_fisico      => ''                  );
      --
   END f_devuelve_campos_obligatorios;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve los campos inhabilitados definidos en la a2990060.
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_devuelve_campos_inh (p_cod_tabla  a2990060.cod_tabla %TYPE)
   RETURN LONG IS
      --
   BEGIN
      --
      RETURN dc_k_a2990060.f_devuelve_campos_inh(p_cod_cia         => trn_k_global.cod_cia,
                                                 p_cod_tabla       => p_cod_tabla         ,
                                                 p_cod_ramo        => em.cod_ramo_gen     ,
                                                 p_cod_act_tercero => g_cod_act_tercero   ,
                                                 p_tip_benef       => dc.tip_benef_gen    );
      --
   END f_devuelve_campos_inh;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve las cuentas de un tercero
   */-------------------------------------------------------------------------------
   FUNCTION f_tab_devuelve_ctas (p_cod_cia          a1002201.cod_cia         %TYPE,
                                 p_cod_act_tercero  a1002201.cod_act_tercero %TYPE,
                                 p_tip_docum        a1002201.tip_docum       %TYPE,
                                 p_cod_docum        a1002201.cod_docum       %TYPE,
                                 p_cod_tercero      a1002201.cod_tercero     %TYPE
                                )
     RETURN dc_k_a1002201.t_tab_ctas IS
     --
     l_t_tab_ctas     dc_k_a1002201.t_tab_ctas;
     --
   BEGIN
    -- l_t_tab_ctas := dc_k_a1002201.f_tab_devuelve_ctas(p_cod_cia         => p_cod_cia,
    --                                                   p_cod_act_tercero => p_cod_act_tercero,
    --                                                   p_tip_docum       => p_tip_docum,
    --                                                   p_cod_docum       => p_cod_docum,
    --                                                   p_cod_tercero     => p_cod_tercero);
     --
     RETURN l_t_tab_ctas;
     --
   END f_tab_devuelve_ctas;
   /*-------------------------------------------------------------------------------
   || Devuelve la constante que indica si se trabaja con una o varias cuentas
   */-------------------------------------------------------------------------------
   FUNCTION f_es_multicuenta
     RETURN VARCHAR2
    IS
   BEGIN
     --
     RETURN trn_k_g0000000.f_mca_multi_cta_cte;
     --
   END f_es_multicuenta;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve la cuenta corriente del tercero en un solo campo
   */-------------------------------------------------------------------------------
   FUNCTION f_cuenta_corriente
     RETURN VARCHAR2
   IS
      --
      l_cuenta_corriente  VARCHAR2(200)                      ;
      l_cod_id_oficina    a5020910.cod_id_oficina       %TYPE;
      l_tip_fomato_cta_cte g1000900.tip_formato_cta_cte %TYPE;
      --
   BEGIN
     --
     dc_p_formatea_cuenta(p_cod_cia             => trn_k_global.cod_cia,
                          p_cod_entidad         => f_cod_entidad       ,
                          p_cod_oficina         => f_cod_oficina       ,
                          p_cta_cte             => f_cta_cte           ,
                          p_cta_dc              => f_cta_dc            ,
                          p_cod_id_oficina      => l_cod_id_oficina    ,
                          p_tip_formato_cta_cte => l_tip_fomato_cta_cte,
                          p_cod_cuenta          => l_cuenta_corriente  );
     --
     RETURN l_cuenta_corriente;
     --
   END f_cuenta_corriente;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo atr_domicilio1 de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_atr_domicilio1 RETURN VARCHAR2 IS
      --
      l_retorno a1001331.atr_domicilio1%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1 --Asegurados
      THEN
         --
         l_retorno := reg_a1001331.atr_domicilio1;
         --
      ELSIF g_cod_act_tercero = 2 --Agentes
      THEN
         l_retorno := reg_a1001332.atr_domicilio1;
      ELSIF g_cod_act_tercero = 37 --Empleados de agentes
      THEN
         l_retorno := reg_a1001337.atr_domicilio1;
      ELSIF g_cod_act_tercero = 13 -- Aseguradoras
      THEN
         l_retorno := reg_a1000600.atr_domicilio1;
      ELSIF g_cod_act_tercero = 8 -- Supervisores
      THEN
         l_retorno := reg_a1001338.atr_domicilio1;
      ELSIF g_cod_act_tercero = 9 -- tramitadores
      THEN
         l_retorno := reg_a1001339.atr_domicilio1;
      ELSE --terceros comunes
         l_retorno := reg_a1001300.atr_domicilio1;
      END IF;
      --
      RETURN l_retorno;
      --
   END f_atr_domicilio1;
   --
  /*-------------------------------------------------------------------------------
   || Devuelve el campo atr_domicilio2 de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_atr_domicilio2 RETURN VARCHAR2 IS
      --
      l_retorno a1001331.atr_domicilio2%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.atr_domicilio2;
         --
      ELSIF g_cod_act_tercero = 2 --Agentes
      THEN
         l_retorno := reg_a1001332.atr_domicilio2;
      ELSIF g_cod_act_tercero = 37 --Empleados de agentes
      THEN
         l_retorno := reg_a1001337.atr_domicilio2;
      ELSIF g_cod_act_tercero = 13 -- Aseguradoras
      THEN
         l_retorno := reg_a1000600.atr_domicilio2;
      ELSIF g_cod_act_tercero = 8 -- Supervisores
      THEN
         l_retorno := reg_a1001338.atr_domicilio2;
      ELSIF g_cod_act_tercero = 9 -- tramitadores
      THEN
         l_retorno := reg_a1001339.atr_domicilio2;
      ELSE --terceros comunes
         l_retorno := reg_a1001300.atr_domicilio2;
      END IF;
      --
      RETURN l_retorno;
      --
   END f_atr_domicilio2;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo atr_domicilio3 de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_atr_domicilio3 RETURN VARCHAR2 IS
      --
      l_retorno a1001331.atr_domicilio3%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.atr_domicilio3;
         --
      ELSIF g_cod_act_tercero = 2 --Agentes
      THEN
         l_retorno := reg_a1001332.atr_domicilio3;
      ELSIF g_cod_act_tercero = 37 --Empleados de agentes
      THEN
         l_retorno := reg_a1001337.atr_domicilio3;
      ELSIF g_cod_act_tercero = 13 -- Aseguradoras
      THEN
         l_retorno := reg_a1000600.atr_domicilio3;
      ELSIF g_cod_act_tercero = 8 -- Supervisores
      THEN
         l_retorno := reg_a1001338.atr_domicilio3;
      ELSIF g_cod_act_tercero = 9 -- tramitadores
      THEN
         l_retorno := reg_a1001339.atr_domicilio3;
      ELSE --terceros comunes
         l_retorno := reg_a1001300.atr_domicilio3;
      END IF;
      --
      RETURN l_retorno;
      --
   END f_atr_domicilio3;
   --
  /*-------------------------------------------------------------------------------
   || Devuelve el campo atr_domicilio4 de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_atr_domicilio4 RETURN VARCHAR2 IS
      --
      l_retorno a1001331.atr_domicilio4%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.atr_domicilio4;
         --
      ELSIF g_cod_act_tercero = 2 --Agentes
      THEN
         l_retorno := reg_a1001332.atr_domicilio4;
      ELSIF g_cod_act_tercero = 37 --Empleados de agentes
      THEN
         l_retorno := reg_a1001337.atr_domicilio4;
      ELSIF g_cod_act_tercero = 13 -- Aseguradoras
      THEN
         l_retorno := reg_a1000600.atr_domicilio4;
      ELSIF g_cod_act_tercero = 8 -- Supervisores
      THEN
         l_retorno := reg_a1001338.atr_domicilio4;
      ELSIF g_cod_act_tercero = 9 -- tramitadores
      THEN
         l_retorno := reg_a1001339.atr_domicilio4;
      ELSE --terceros comunes
         l_retorno := reg_a1001300.atr_domicilio4;
      END IF;
      --
      RETURN l_retorno;
      --
   END f_atr_domicilio4;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo atr_domicilio5 de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_atr_domicilio5 RETURN VARCHAR2 IS
      --
      l_retorno a1001331.atr_domicilio5%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.atr_domicilio5;
         --
      ELSIF g_cod_act_tercero = 2 --Agentes
      THEN
         l_retorno := reg_a1001332.atr_domicilio5;
      ELSIF g_cod_act_tercero = 37 --Empleados de agentes
      THEN
         l_retorno := reg_a1001337.atr_domicilio5;
      ELSIF g_cod_act_tercero = 13 -- Aseguradoras
      THEN
         l_retorno := reg_a1000600.atr_domicilio5;
      ELSIF g_cod_act_tercero = 8 -- Supervisores
      THEN
         l_retorno := reg_a1001338.atr_domicilio5;
      ELSIF g_cod_act_tercero = 9 -- tramitadores
      THEN
         l_retorno := reg_a1001339.atr_domicilio5;
      ELSE --terceros comunes
         l_retorno := reg_a1001300.atr_domicilio5;
      END IF;
      --
      RETURN l_retorno;
      --
   END f_atr_domicilio5;
   --
  /*-------------------------------------------------------------------------------
   || Devuelve el campo anx_domicilio de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_anx_domicilio RETURN VARCHAR2 IS
      --
      l_retorno a1001331.anx_domicilio%TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.anx_domicilio;
         --
      ELSIF g_cod_act_tercero = 2 --Agentes
      THEN
         l_retorno := reg_a1001332.anx_domicilio;
      ELSIF g_cod_act_tercero = 37 --Empleados de agentes
      THEN
         l_retorno := reg_a1001337. anx_domicilio;
      ELSIF g_cod_act_tercero = 13 -- Aseguradoras
      THEN
         l_retorno := reg_a1000600.anx_domicilio;
      ELSIF g_cod_act_tercero = 8 -- Supervisores
      THEN
         l_retorno := reg_a1001338.anx_domicilio;
      ELSIF g_cod_act_tercero = 9 -- tramitadores
      THEN
         l_retorno := reg_a1001339.anx_domicilio;
      ELSE --terceros comunes
         l_retorno := reg_a1001300.anx_domicilio;
      END IF;
      --
      RETURN l_retorno;
      --
   END f_anx_domicilio;
   --
  /*-------------------------------------------------------------------------------
   || Devuelve el campo ext_cod_postal de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_ext_cod_postal RETURN VARCHAR2 IS
      --
      l_retorno a1001331.ext_cod_postal %TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.ext_cod_postal;
         --
      ELSIF g_cod_act_tercero = 2 --Agentes
      THEN
         l_retorno := reg_a1001332.ext_cod_postal;
      ELSIF g_cod_act_tercero = 37 --Empleados de agentes
      THEN
         l_retorno := reg_a1001337.ext_cod_postal;
      ELSIF g_cod_act_tercero = 13 -- Aseguradoras
      THEN
         l_retorno := reg_a1000600.ext_cod_postal;
      ELSIF g_cod_act_tercero = 8 -- Supervisores
      THEN
         l_retorno := reg_a1001338.ext_cod_postal;
      ELSIF g_cod_act_tercero = 9 -- tramitadores
      THEN
         l_retorno := reg_a1001339.ext_cod_postal;
      ELSE --terceros comunes
         l_retorno := reg_a1001300.ext_cod_postal;
      END IF;
      --
      RETURN l_retorno;
      --
   END f_ext_cod_postal;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo tlf_extension de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_tlf_extension RETURN VARCHAR2 IS
      --
      l_retorno a1001331.tlf_extension %TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.tlf_extension;
         --
      ELSIF g_cod_act_tercero = 2 --Agentes
      THEN
         l_retorno := reg_a1001332.tlf_extension;
      ELSIF g_cod_act_tercero = 37 --Empleados de agentes
      THEN
         l_retorno := reg_a1001337.tlf_extension;
      ELSIF g_cod_act_tercero = 13 -- Aseguradoras
      THEN
         l_retorno := reg_a1000600.tlf_extension;
      ELSE --terceros comunes
         l_retorno := reg_a1001300.tlf_extension;
      END IF;
      --
      RETURN l_retorno;
      --
   END f_tlf_extension;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo nom_empresa_com de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_nom_empresa_com RETURN VARCHAR2 IS
      --
      l_retorno a1001331.nom_empresa_com %TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.nom_empresa_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_nom_empresa_com;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo atr_domicilio1_com de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_atr_domicilio1_com RETURN VARCHAR2 IS
      --
      l_retorno a1001331.atr_domicilio1_com %TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.atr_domicilio1_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_atr_domicilio1_com;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo atr_domicilio2_com de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_atr_domicilio2_com RETURN VARCHAR2 IS
      --
      l_retorno a1001331.atr_domicilio2_com %TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.atr_domicilio2_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_atr_domicilio2_com;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo atr_domicilio3_com de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_atr_domicilio3_com RETURN VARCHAR2 IS
      --
      l_retorno a1001331.atr_domicilio3_com %TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.atr_domicilio3_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_atr_domicilio3_com;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo atr_domicilio4_com de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_atr_domicilio4_com RETURN VARCHAR2 IS
      --
      l_retorno a1001331.atr_domicilio4_com %TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.atr_domicilio4_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_atr_domicilio4_com;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo atr_domicilio5_com de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_atr_domicilio5_com RETURN VARCHAR2 IS
      --
      l_retorno a1001331.atr_domicilio5_com %TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.atr_domicilio5_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_atr_domicilio5_com;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo anx_domicilio_com de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_anx_domicilio_com RETURN VARCHAR2 IS
      --
      l_retorno a1001331.anx_domicilio_com %TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.anx_domicilio_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_anx_domicilio_com;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo ext_cod_postal de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_ext_cod_postal_com RETURN VARCHAR2 IS
      --
      l_retorno a1001331.ext_cod_postal_com %TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.ext_cod_postal_com;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_ext_cod_postal_com;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el campo tlf_extension_com de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_tlf_extension_com RETURN VARCHAR2 IS
      --
      l_retorno a1001331.tlf_extension_com %TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.tlf_extension_com;
         --
      ELSIF g_cod_act_tercero = 2 --Agentes
      THEN
         l_retorno := reg_a1001332. tlf_extension_com;
      ELSIF g_cod_act_tercero = 37 --Empleados de agentes
      THEN
         l_retorno := reg_a1001337.tlf_extension_com;
      END IF;
      --
      RETURN l_retorno;
      --
   END f_tlf_extension_com;
   --
  /*-------------------------------------------------------------------------------
   || Devuelve el campo ext_cod_postal_etiqueta de a1001331
   */-------------------------------------------------------------------------------
   FUNCTION f_ext_cod_postal_etiqueta RETURN VARCHAR2 IS
      --
      l_retorno a1001331.ext_cod_postal_etiqueta %TYPE := NULL;
      --
   BEGIN
      --
      p_comprueba_error(NULL);
      --
      IF g_cod_act_tercero = 2 --Agentes
      THEN
         --
         l_retorno := reg_a1001332.ext_cod_postal_etiqueta;
         --
      ELSIF g_cod_act_tercero = 37 --Empleados de agentes
      THEN
         --
         l_retorno := reg_a1001331.ext_cod_postal_etiqueta;
         --
      ELSIF g_cod_act_tercero = 13 -- Aseguradoras
      THEN
         --
         l_retorno := reg_a1000600.ext_cod_postal_etiqueta;
         --
      ELSIF g_cod_act_tercero = 1
      THEN
         --
         l_retorno := reg_a1001331.ext_cod_postal_etiqueta;
         --
      ELSE --terceros comunes
         --
         l_retorno := reg_a1001300.ext_cod_postal_etiqueta;
         --
      END IF;
      --
      RETURN l_retorno;
      --
   END f_ext_cod_postal_etiqueta;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve fecha de actualizacion del registro
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_fec_actu
      RETURN DATE
   IS
      --
      l_fec_actu a1001300.fec_actu%TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado --Asegurados
      THEN
         --
         l_fec_actu := reg_a1001331.fec_actu;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_agente --Agentes
      THEN
         --
         l_fec_actu := reg_a1001332.fec_actu;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_supervisor --Supervisores
      THEN
         --
         l_fec_actu := reg_a1001338.fec_actu;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_tramitador --Tramitadores
      THEN
         --
         l_fec_actu := reg_a1001339.fec_actu;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_aseguradora -- Aseguradoras
      THEN
         --
         l_fec_actu := reg_a1000600.fec_actu;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_reaseguradora -- Reaseguradoras
      THEN
         --
         l_fec_actu := reg_g2000157.fec_actu;
         --
      ELSIF g_cod_act_tercero =  g_k_cod_act_broker -- Brokers
      THEN
         --
         l_fec_actu := reg_g2000155.fec_actu;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_empleado_agt --Empleados de agentes
      THEN
         --
         l_fec_actu := reg_a1001337.fec_actu;
         --
      ELSE --terceros comunes
         --
         l_fec_actu := reg_a1001300.fec_actu;
         --
      END IF;
      --
      RETURN l_fec_actu;
      --
   END f_fec_actu;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve nombre del contacto
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_nombre_contacto
      RETURN VARCHAR2
   IS
      --
      l_nom_contacto a1001331.nom_contacto%TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado --Asegurados
      THEN
         --
         l_nom_contacto := reg_a1001331.nom_contacto;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_agente --Agentes
      THEN
         --
         l_nom_contacto := reg_a1001332.nom_contacto;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_empleado_agt --Empleados de agentes
      THEN
         --
         l_nom_contacto := reg_a1001337.nom_contacto;
         --
      ELSIF g_cod_act_tercero NOT IN(g_k_cod_act_asegurado     ,
                                     g_k_cod_act_agente        ,
                                     g_k_cod_act_empleado_agt  ,
                                     g_k_cod_act_supervisor    ,
                                     g_k_cod_act_tramitador    ,
                                     g_k_cod_act_aseguradora   ,
                                     g_k_cod_act_reaseguradora ,
                                     g_k_cod_act_broker        ) --terceros comunes
      THEN
         --
         l_nom_contacto := reg_a1001300.nom_contacto;
         --
      END IF;
      --
      RETURN l_nom_contacto;
      --
   END f_nombre_contacto;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el numero del colegio del agente
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_cod_agt_colegio
      RETURN VARCHAR2
   IS
      --
      l_cod_agt_colegio a1001332.cod_agt_colegio %TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_agente -- Agentes
      THEN
         --
         l_cod_agt_colegio := reg_a1001332.cod_agt_colegio;
         --
      END IF;
      --
      RETURN l_cod_agt_colegio;
      --
   END f_cod_agt_colegio;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve la marca del productor directo
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_mca_agt_dir
      RETURN VARCHAR2
   IS
      --
      l_mca_agt_dir a1001332.mca_agt_dir%TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_agente -- Agentes
      THEN
         --
         l_mca_agt_dir := reg_a1001332.mca_agt_dir;
         --
      END IF;
      --
      RETURN l_mca_agt_dir;
      --
   END f_mca_agt_dir;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve la fecha de credencial del agente
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_fec_credencial
      RETURN DATE
   IS
      --
      l_fec_credencial a1001332.fec_credencial%TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_agente -- Agentes
      THEN
         --
         l_fec_credencial := reg_a1001332.fec_credencial;
         --
      END IF;
      --
      RETURN l_fec_credencial;
      --
   END f_fec_credencial;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve la fecha de vencimiento de credencial del agente
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_fec_vcto_credencial
      RETURN DATE
   IS
      --
      l_fec_vcto_credencial  a1001332.fec_vcto_credencial%TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_agente -- Agentes
      THEN
         --
         l_fec_vcto_credencial := reg_a1001332.fec_vcto_credencial;
         --
      END IF;
      --
      RETURN l_fec_vcto_credencial;
      --
   END f_fec_vcto_credencial;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el numero de contrato del registro
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_num_contrato
      RETURN VARCHAR2
   IS
      --
      l_num_contrato a1001332.num_contrato%TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_agente -- Agentes
      THEN
         --
         l_num_contrato := reg_a1001332.num_contrato;
         --
      END IF;
      --
      RETURN l_num_contrato;
      --
   END f_num_contrato;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve la fecha de alta del contrato
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_fec_alta_contrato
      RETURN DATE
   IS
      --
      l_fec_alta_contrato a1001332.fec_alta_contrato %TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_agente -- Agentes
      THEN
         --
         l_fec_alta_contrato := reg_a1001332.fec_alta_contrato;
         --
      END IF;
      --
      RETURN l_fec_alta_contrato;
      --
   END f_fec_alta_contrato;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve la fecha de baja del contrato
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_fec_baja_contrato
      RETURN DATE
   IS
      --
      l_fec_baja_contrato a1001332.fec_baja_contrato %TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_agente -- Agentes
      THEN
         --
         l_fec_baja_contrato := reg_a1001332.fec_baja_contrato;
         --
      END IF;
      --
      RETURN l_fec_baja_contrato;
      --
   END f_fec_baja_contrato;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el codigo de envio del registro
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_cod_envio
      RETURN VARCHAR2
   IS
      --
      l_cod_envio a1001332.cod_envio %TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_agente -- Agentes
      THEN
         --
         l_cod_envio := reg_a1001332.cod_envio;
         --
      END IF;
      --
      RETURN l_cod_envio;
      --
   END f_cod_envio;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve las observaciones del agente del registro
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_obs_agt
      RETURN VARCHAR2
   IS
      --
      l_obs_agt a1001332.obs_agt %TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_agente -- Agentes
      THEN
         --
         l_obs_agt := reg_a1001332.obs_agt;
         --
      END IF;
      --
      RETURN l_obs_agt;
      --
   END f_obs_agt;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el valor del campo auxiliar 4
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_txt_aux4
      RETURN VARCHAR2
   IS
      --
      l_txt_aux4 a1001332.txt_aux4 %TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_agente -- Agentes
      THEN
         --
         l_txt_aux4 := reg_a1001332.txt_aux4;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_asegurado  -- Asegurado
      THEN
         --
         l_txt_aux4 := reg_a1001331.txt_aux4;
         --
      END IF;
      --
      RETURN l_txt_aux4;
      --
   END f_txt_aux4;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el valor del campo auxiliar 5
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_txt_aux5
      RETURN VARCHAR2
   IS
      --
      l_txt_aux5 a1001332.txt_aux5 %TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_agente -- Agentes
      THEN
         --
         l_txt_aux5 := reg_a1001332.txt_aux5;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_asegurado  -- Asegurado
      THEN
         --
         l_txt_aux5 := reg_a1001331.txt_aux5;
         --
      END IF;
      --
      RETURN l_txt_aux5;
      --
   END f_txt_aux5;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el valor del campo auxiliar 6
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_txt_aux6
      RETURN VARCHAR2
   IS
   --
      l_txt_aux6 a1001331.txt_aux6 %TYPE := g_k_nulo;
   --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado  -- Asegurado
      THEN
         --
         l_txt_aux6 := reg_a1001331.txt_aux6;
         --
      END IF;
      --
      RETURN l_txt_aux6;
      --
   END f_txt_aux6;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el valor del campo auxiliar 7
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_txt_aux7
      RETURN VARCHAR2
   IS
   --
      l_txt_aux7 a1001331.txt_aux7 %TYPE := g_k_nulo;
   --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado  -- Asegurado
      THEN
         --
         l_txt_aux7 := reg_a1001331.txt_aux7;
         --
      END IF;
      --
      RETURN l_txt_aux7;
      --
   END f_txt_aux7;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el valor del campo auxiliar 8
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_txt_aux8
      RETURN VARCHAR2
   IS
   --
      l_txt_aux8 a1001331.txt_aux8 %TYPE := g_k_nulo;
   --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado  -- Asegurado
      THEN
         --
         l_txt_aux8 := reg_a1001331.txt_aux8;
         --
      END IF;
      --
      RETURN l_txt_aux8;
      --
   END f_txt_aux8;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el valor del campo auxiliar 9
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_txt_aux9
      RETURN VARCHAR2
   IS
   --
      l_txt_aux9 a1001331.txt_aux9 %TYPE := g_k_nulo;
   --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado  -- Asegurado
      THEN
         --
         l_txt_aux9 := reg_a1001331.txt_aux9;
         --
      END IF;
      --
      RETURN l_txt_aux9;
      --
   END f_txt_aux9;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el tipo de situacion del registro
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_tip_situacion
      RETURN VARCHAR2
   IS
      --
      l_tip_situacion a1001332.tip_situacion %TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_agente -- Agentes
      THEN
         --
         l_tip_situacion := reg_a1001332.tip_situacion;
         --
      END IF;
      --
      RETURN l_tip_situacion;
      --
   END f_tip_situacion;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el tipo de proceso que afecta inhabilitacion
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_tip_proc_inh
      RETURN VARCHAR2
   IS
      --
      l_tip_proc_inh  a1001332.tip_proc_inh %TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_agente -- Agentes
      THEN
         --
         l_tip_proc_inh := reg_a1001332.tip_proc_inh;
         --
      END IF;
      --
      RETURN l_tip_proc_inh;
      --
   END f_tip_proc_inh;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve la fecha de validez del registro
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_fec_validez
      RETURN DATE
   IS
      --
      l_fec_validez a1001300.fec_validez %TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_agente --Agentes
      THEN
         --
         l_fec_validez := reg_a1001332.fec_validez;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_tramitador --Tramitadores
      THEN
         --
         l_fec_validez := reg_a1001339.fec_validez;
         --
      ELSIF g_cod_act_tercero NOT IN(g_k_cod_act_asegurado     ,
                                     g_k_cod_act_agente        ,
                                     g_k_cod_act_empleado_agt  ,
                                     g_k_cod_act_supervisor    ,
                                     g_k_cod_act_tramitador    ,
                                     g_k_cod_act_aseguradora   ,
                                     g_k_cod_act_reaseguradora ,
                                     g_k_cod_act_broker        ) --terceros comunes
      THEN
         --
         l_fec_validez := reg_a1001300.fec_validez;
         --
      END IF;
      --
      RETURN l_fec_validez;
      --
   END f_fec_validez;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el codigo de causa de inhabilitacion de tercero
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_cod_causa_inh_trc
      RETURN NUMBER
   IS
      --
      l_cod_causa_inh_trc a1001300.cod_causa_inh_trc %TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_agente --Agentes
      THEN
         --
         l_cod_causa_inh_trc := reg_a1001332.cod_causa_inh_trc;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_tramitador --Tramitadores
      THEN
         --
         l_cod_causa_inh_trc := reg_a1001339.cod_causa_inh_trc;
         --
      ELSIF g_cod_act_tercero NOT IN(g_k_cod_act_asegurado     ,
                                     g_k_cod_act_agente        ,
                                     g_k_cod_act_empleado_agt  ,
                                     g_k_cod_act_supervisor    ,
                                     g_k_cod_act_tramitador    ,
                                     g_k_cod_act_aseguradora   ,
                                     g_k_cod_act_reaseguradora ,
                                     g_k_cod_act_broker        ) --terceros comunes
      THEN
         --
         l_cod_causa_inh_trc := reg_a1001300.cod_causa_inh_trc;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_asegurado   -- Asegurado
      THEN
         --
         l_cod_causa_inh_trc := reg_a1001331.cod_causa_inh_trc;
         --
      END IF;
      --
      RETURN l_cod_causa_inh_trc;
      --
   END f_cod_causa_inh_trc;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el codigo de causa de inhabilitacion de tercero
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_cod_clase_benef
      RETURN VARCHAR2
   IS
      --
      l_cod_clase_benef a1001300.cod_clase_benef %TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_agente --Agentes
      THEN
         --
         l_cod_clase_benef := reg_a1001332.cod_clase_benef;
         --
      ELSIF g_cod_act_tercero NOT IN(g_k_cod_act_asegurado     ,
                                     g_k_cod_act_agente        ,
                                     g_k_cod_act_empleado_agt  ,
                                     g_k_cod_act_supervisor    ,
                                     g_k_cod_act_tramitador    ,
                                     g_k_cod_act_aseguradora   ,
                                     g_k_cod_act_reaseguradora ,
                                     g_k_cod_act_broker        ) --terceros comunes
      THEN
         --
         l_cod_clase_benef := reg_a1001300. cod_clase_benef;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_asegurado  -- Asegurado
      THEN
         --
         l_cod_clase_benef := reg_a1001331.cod_clase_benef;
         --
      END IF;
      --
      RETURN l_cod_clase_benef;
      --
   END f_cod_clase_benef;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el tipo de tramitador
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_tip_tramitador
      RETURN VARCHAR2
   IS
      --
      l_tip_tramitador a1001339.tip_tramitador %TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_tramitador -- Tramitadores
      THEN
         --
         l_tip_tramitador := reg_a1001339.tip_tramitador;
         --
      END IF;
      --
      RETURN l_tip_tramitador;
      --
   END f_tip_tramitador;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el codigo del tramitador
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_cod_tramitador
      RETURN NUMBER
   IS
      --
      l_cod_tramitador a1001339.cod_tramitador %TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_tramitador -- Tramitadores
      THEN
         --
         l_cod_tramitador := reg_a1001339.cod_tramitador;
         --
      END IF;
      --
      RETURN l_cod_tramitador;
      --
   END f_cod_tramitador;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el codigo del usuario del tramitador
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_cod_usr_tramitador
      RETURN VARCHAR2
   IS
      --
      l_cod_usr_tramitador a1001339.cod_usr_tramitador  %TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_tramitador -- Tramitadores
      THEN
         --
         l_cod_usr_tramitador := reg_a1001339.cod_usr_tramitador;
         --
      END IF;
      --
      RETURN l_cod_usr_tramitador;
      --
   END f_cod_usr_tramitador;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el codigo del supervisor del siniestro
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_cod_supervisor
      RETURN NUMBER
   IS
      --
      l_cod_supervisor a1001339.cod_supervisor %TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_tramitador -- Tramitadores
      THEN
         --
         l_cod_supervisor := reg_a1001339.cod_supervisor;
         --
      END IF;
      --
      RETURN l_cod_supervisor;
      --
   END f_cod_supervisor;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el tipo de estado del registro
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_tip_estado
      RETURN VARCHAR2
   IS
      --
      l_tip_estado a1001339.tip_estado %TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_tramitador -- Tramitadores
      THEN
         --
         l_tip_estado := reg_a1001339.tip_estado;
         --
      END IF;
      --
      RETURN l_tip_estado;
      --
   END f_tip_estado;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el numero de siniestros pendientes por supervisor
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_num_siniestros
      RETURN NUMBER
   IS
      --
      l_num_siniestros a1001339.num_siniestros %TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_tramitador -- Tramitadores
      THEN
         --
         l_num_siniestros := reg_a1001339.num_siniestros;
         --
      END IF;
      --
      RETURN l_num_siniestros;
      --
   END f_num_siniestros;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el numero maximo de expedientes asignado a supervisor
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_max_num_exp
      RETURN NUMBER
   IS
      --
      l_max_num_exp  a1001339.max_num_exp %TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_tramitador -- Tramitadores
      THEN
         --
         l_max_num_exp := reg_a1001339.max_num_exp;
         --
      END IF;
      --
      RETURN l_max_num_exp;
      --
   END f_max_num_exp;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve la marca de la consencuencia con pregunta
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_mca_preg_consecuencia
      RETURN VARCHAR2
   IS
      --
      l_mca_preg_consecuencia a1001339.mca_preg_consecuencia%TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_tramitador -- Tramitadores
      THEN
         --
         l_mca_preg_consecuencia := reg_a1001339.mca_preg_consecuencia;
         --
      END IF;
      --
      RETURN l_mca_preg_consecuencia;
      --
   END f_mca_preg_consecuencia;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el tipo de nacionalidad del registro
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_tip_nacionalidad
      RETURN VARCHAR2
   IS
      --
      l_tip_nacionalidad a1001331.tip_nacionalidad%TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado -- Asegurados
      THEN
         --
         l_tip_nacionalidad := reg_a1001331.tip_nacionalidad;
         --
      END IF;
      --
      RETURN l_tip_nacionalidad;
      --
   END f_tip_nacionalidad;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el codigo de calidad del tercero
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_cod_calidad
      RETURN VARCHAR2
   IS
      --
      l_cod_calidad a1001300.cod_calidad %TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_agente -- Agentes
      THEN
         --
         l_cod_calidad := reg_a1001332.cod_calidad;
         --
      ELSIF g_cod_act_tercero NOT IN(g_k_cod_act_asegurado     ,
                                     g_k_cod_act_agente        ,
                                     g_k_cod_act_empleado_agt  ,
                                     g_k_cod_act_supervisor    ,
                                     g_k_cod_act_tramitador    ,
                                     g_k_cod_act_aseguradora   ,
                                     g_k_cod_act_reaseguradora ,
                                     g_k_cod_act_broker        ) --terceros comunes
      THEN
         --
         l_cod_calidad := reg_a1001300.cod_calidad;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_asegurado   -- Asegurado
      THEN
         --
         l_cod_calidad := reg_a1001331.cod_calidad;
         --
      END IF;
      --
      RETURN l_cod_calidad;
      --
   END f_cod_calidad;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve las observaciones del tercero del registro
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_obs_tercero
      RETURN VARCHAR2
   IS
      --
      l_obs_tercero a1001300.obs_tercero  %TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero NOT IN (g_k_cod_act_asegurado    ,
                                   g_k_cod_act_agente       ,
                                   g_k_cod_act_empleado_agt ,
                                   g_k_cod_act_supervisor   ,
                                   g_k_cod_act_tramitador   ,
                                   g_k_cod_act_aseguradora  ,
                                   g_k_cod_act_reaseguradora,
                                   g_k_cod_act_broker       ) -- Terceros comunes
      THEN
         --
         l_obs_tercero := reg_a1001300.obs_tercero;
         --
      END IF;
      --
      RETURN l_obs_tercero;
      --
   END f_obs_tercero;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve eld codigo del colegiado del tercero
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_cod_ter_colegio
      RETURN VARCHAR2
   IS
      --
      l_cod_ter_colegio  a1001300.cod_ter_colegio%TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero NOT IN (g_k_cod_act_asegurado    ,
                                   g_k_cod_act_agente       ,
                                   g_k_cod_act_empleado_agt ,
                                   g_k_cod_act_supervisor   ,
                                   g_k_cod_act_tramitador   ,
                                   g_k_cod_act_aseguradora  ,
                                   g_k_cod_act_reaseguradora,
                                   g_k_cod_act_broker       ) -- Terceros comunes
      THEN
         --
         l_cod_ter_colegio := reg_a1001300.cod_ter_colegio;
         --
      END IF;
      --
      RETURN l_cod_ter_colegio;
      --
   END f_cod_ter_colegio;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el numero de identificacion fiscal
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_num_id_fiscal
      RETURN VARCHAR2
   IS
      --
      l_num_id_fiscal a1001300.num_id_fiscal %TYPE := g_k_nulo;
      --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero NOT IN (g_k_cod_act_asegurado    ,
                                   g_k_cod_act_agente       ,
                                   g_k_cod_act_empleado_agt ,
                                   g_k_cod_act_supervisor   ,
                                   g_k_cod_act_tramitador   ,
                                   g_k_cod_act_aseguradora  ,
                                   g_k_cod_act_reaseguradora,
                                   g_k_cod_act_broker       ) -- Terceros comunes
      THEN
         --
         l_num_id_fiscal := reg_a1001300.num_id_fiscal;
         --
      END IF;
      --
      RETURN l_num_id_fiscal;
      --
   END f_num_id_fiscal;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve tip_etiqueta
   */-------------------------------------------------------------------------------
   FUNCTION f_tip_etiqueta
      RETURN a1001331.tip_etiqueta%TYPE
   IS
   --
      l_tip_etiqueta  a1001331.tip_etiqueta%TYPE;
   --
   BEGIN
      --
      IF g_cod_act_tercero = dc.ACT_ASEGURADO
      THEN
         --
         l_tip_etiqueta := reg_a1001331.tip_etiqueta;
         --
      ELSE
         --
         l_tip_etiqueta := trn.NULO;
         --
      END IF;
      --
      RETURN l_tip_etiqueta;
      --
   END f_tip_etiqueta;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve cod_pais_etiqueta
   */-------------------------------------------------------------------------------
   FUNCTION f_cod_pais_etiqueta
      RETURN a1001331.cod_pais_etiqueta%TYPE
   IS
   --
      l_cod_pais_etiqueta  a1001331.cod_pais_etiqueta%TYPE;
   --
   BEGIN
      --
      CASE g_cod_act_tercero
         --
         WHEN dc.ACT_ASEGURADO
         THEN
            --
            l_cod_pais_etiqueta := reg_a1001331.cod_pais_etiqueta;
            --
         WHEN dc.ACT_AGENTE
         THEN
            --
            l_cod_pais_etiqueta := reg_a1001332.cod_pais_etiqueta;
            --
         WHEN dc.ACT_ASEGURADORA
         THEN
            --
            l_cod_pais_etiqueta := reg_a1000600.cod_pais_etiqueta;
            --
         WHEN dc.ACT_REASEGURADORA
         THEN
            --
            l_cod_pais_etiqueta := reg_g2000157.cod_pais_etiqueta;
            --
         WHEN dc.ACT_BROKER
         THEN
            --
            l_cod_pais_etiqueta := reg_g2000155.cod_pais_etiqueta;
            --
         WHEN dc.ACT_EMPLEADO_AGT
         THEN
            --
            l_cod_pais_etiqueta := reg_a1001337.cod_pais_etiqueta;
            --
         ELSE
            --
            l_cod_pais_etiqueta := reg_a1001300.cod_pais_etiqueta;
            --
      END CASE;
      --
      RETURN l_cod_pais_etiqueta;
      --
   END f_cod_pais_etiqueta;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve cod_estado_etiqueta
   */-------------------------------------------------------------------------------
   FUNCTION f_cod_estado_etiqueta
      RETURN a1001331.cod_estado_etiqueta%TYPE
   IS
   --
      l_cod_estado_etiqueta  a1001331.cod_estado_etiqueta%TYPE;
   --
   BEGIN
      --
      CASE g_cod_act_tercero
         --
         WHEN dc.ACT_ASEGURADO
         THEN
            --
            l_cod_estado_etiqueta := reg_a1001331.cod_estado_etiqueta;
            --
         WHEN dc.ACT_AGENTE
         THEN
            --
            l_cod_estado_etiqueta := reg_a1001332.cod_estado_etiqueta;
            --
         WHEN dc.ACT_ASEGURADORA
         THEN
            --
            l_cod_estado_etiqueta := reg_a1000600.cod_estado_etiqueta;
            --
         WHEN dc.ACT_REASEGURADORA
         THEN
            --
            l_cod_estado_etiqueta := reg_g2000157.cod_estado_etiqueta;
            --
         WHEN dc.ACT_BROKER
         THEN
            --
            l_cod_estado_etiqueta := reg_g2000155.cod_estado_etiqueta;
            --
         WHEN dc.ACT_EMPLEADO_AGT
         THEN
            --
            l_cod_estado_etiqueta := reg_a1001337.cod_estado_etiqueta;
            --
         ELSE
            --
            l_cod_estado_etiqueta := reg_a1001300.cod_estado_etiqueta;
            --
      END CASE;
      --
      RETURN l_cod_estado_etiqueta;
      --
   END f_cod_estado_etiqueta;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve num_apartado_etiqueta
   */-------------------------------------------------------------------------------
   FUNCTION f_num_apartado_etiqueta
      RETURN a1001331.num_apartado_etiqueta%TYPE
   IS
   --
      l_num_apartado_etiqueta  a1001331.num_apartado_etiqueta%TYPE;
   --
   BEGIN
      --
      CASE g_cod_act_tercero
         --
         WHEN dc.ACT_ASEGURADO
         THEN
            --
            l_num_apartado_etiqueta := reg_a1001331.num_apartado_etiqueta;
            --
         WHEN dc.ACT_AGENTE
         THEN
            --
            l_num_apartado_etiqueta := reg_a1001332.num_apartado_etiqueta;
            --
         WHEN dc.ACT_ASEGURADORA
         THEN
            --
            l_num_apartado_etiqueta := reg_a1000600.num_apartado_etiqueta;
            --
         WHEN dc.ACT_REASEGURADORA
         THEN
            --
            l_num_apartado_etiqueta := reg_g2000157.num_apartado_etiqueta;
            --
         WHEN dc.ACT_BROKER
         THEN
            --
            l_num_apartado_etiqueta := reg_g2000155.num_apartado_etiqueta;
            --
         WHEN dc.ACT_EMPLEADO_AGT
         THEN
            --
            l_num_apartado_etiqueta := reg_a1001337.num_apartado_etiqueta;
            --
         ELSE
            --
            l_num_apartado_etiqueta := reg_a1001300.num_apartado_etiqueta;
            --
      END CASE;
      --
      RETURN l_num_apartado_etiqueta;
      --
   END f_num_apartado_etiqueta;
   --
   /*-------------------------------------------------------------
   || Devuelve el codigo geografico del carnet de conduccion
   */-------------------------------------------------------------
   --
   FUNCTION f_cod_exp_carnet_con
      RETURN a1001331.cod_exp_carnet_con%TYPE
   IS
   --
      l_cod_exp_carnet_con   a1001331.cod_exp_carnet_con%TYPE;
   --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado  -- Asegurado
      THEN
         --
         l_cod_exp_carnet_con := reg_a1001331.cod_exp_carnet_con;
         --
      END IF;
      --
      RETURN l_cod_exp_carnet_con;
      --
   END f_cod_exp_carnet_con;
   --
   /*-------------------------------------------------------------
   || Devuelve la situacion del carnet de conducir
   */-------------------------------------------------------------
   --
   FUNCTION f_cod_situ_carnet_con
      RETURN a1001331.cod_situ_carnet_con%TYPE
   IS
   --
      l_cod_situ_carnet_con   a1001331.cod_situ_carnet_con%TYPE;
   --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado  -- Asegurado
      THEN
         --
         l_cod_situ_carnet_con := reg_a1001331.cod_situ_carnet_con;
         --
      END IF;
      --
      RETURN l_cod_situ_carnet_con;
      --
   END f_cod_situ_carnet_con;
   --
   /*-------------------------------------------------------------
   || Devuelve el n?mero del carnet de conducir
   */-------------------------------------------------------------
   --
   FUNCTION f_num_carnet_con
      RETURN a1001331.num_carnet_con%TYPE
   IS
   --
      l_num_carnet_con   a1001331.num_carnet_con%TYPE;
   --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado  -- Asegurado
      THEN
         --
         l_num_carnet_con := reg_a1001331.num_carnet_con;
         --
      END IF;
      --
      RETURN l_num_carnet_con;
      --
   END f_num_carnet_con;
   --
   /*-------------------------------------------------------------
   || Devuelve el valor del campo num_busca
   */-------------------------------------------------------------
   --
   FUNCTION f_num_busca
      RETURN a1001331.num_busca%TYPE
   IS
   --
      l_num_busca   a1001331.num_busca%TYPE;
   --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado  -- Asegurado
      THEN
         --
         l_num_busca := reg_a1001331.num_busca;
         --
      END IF;
      --
      RETURN l_num_busca;
      --
   END f_num_busca;
   --
   /*-------------------------------------------------------------
   || Devuelve la fecha de vencimiento de la tarjeta de credito
   */-------------------------------------------------------------
   --
   FUNCTION f_fec_vcto_tarjeta
      RETURN a1001331.fec_vcto_tarjeta%TYPE
   IS
   --
      l_fec_vcto_tarjeta   a1001331.fec_vcto_tarjeta%TYPE;
   --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado  -- Asegurado
      THEN
         --
         l_fec_vcto_tarjeta := reg_a1001331.fec_vcto_tarjeta;
         --
      END IF;
      --
      RETURN l_fec_vcto_tarjeta;
      --
   END f_fec_vcto_tarjeta;
   --
   /*-------------------------------------------------------------
   || Devuelve las observaciones del asegurado
   */-------------------------------------------------------------
   --
   FUNCTION f_obs_asegurado
      RETURN a1001331.obs_asegurado%TYPE
   IS
   --
      l_obs_asegurado    a1001331.obs_asegurado%TYPE;
   --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado  -- Asegurado
      THEN
         --
         l_obs_asegurado := reg_a1001331.obs_asegurado;
         --
      END IF;
      --
      RETURN l_obs_asegurado;
      --
   END f_obs_asegurado;
   --
   /*-------------------------------------------------------------
   || Devuelve el tipo de cargo en la empresa
   */-------------------------------------------------------------
   --
   FUNCTION f_tip_cargo
      RETURN a1001331.tip_cargo%TYPE
   IS
   --
      l_tip_cargo    a1001331.tip_cargo%TYPE;
   --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado  -- Asegurado
      THEN
         --
         l_tip_cargo := reg_a1001331.tip_cargo;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_agente  -- Agentes
      THEN
         --
         l_tip_cargo := reg_a1001332.tip_cargo;
         --
      ELSIF g_cod_act_tercero NOT IN (g_k_cod_act_asegurado    ,
                                      g_k_cod_act_agente       ,
                                      g_k_cod_act_supervisor   ,
                                      g_k_cod_act_tramitador   ,
                                      g_k_cod_act_aseguradora  ,
                                      g_k_cod_act_reaseguradora,
                                      g_k_cod_act_broker       ,
                                      g_k_cod_act_empleado_agt )  -- Terceros comunes
      THEN
         --
         l_tip_cargo := reg_a1001300.tip_cargo;
         --
      END IF;
      --
      RETURN l_tip_cargo;
      --
   END f_tip_cargo;
   --
   /*-------------------------------------------------------------
   || Devuelve el tipo de actividad economica
   */-------------------------------------------------------------
   --
   FUNCTION f_tip_act_economica
      RETURN a1001331.tip_act_economica%TYPE
   IS
   --
      l_tip_act_economica   a1001331.tip_act_economica%TYPE;
   --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado  -- Asegurado
      THEN
         --
         l_tip_act_economica := reg_a1001331.tip_act_economica;
         --
      ELSIF g_cod_act_tercero = g_k_cod_act_agente  -- Agentes
      THEN
         --
         l_tip_act_economica := reg_a1001332.tip_act_economica;
         --
      ELSIF g_cod_act_tercero NOT IN (g_k_cod_act_asegurado    ,
                                      g_k_cod_act_agente       ,
                                      g_k_cod_act_supervisor   ,
                                      g_k_cod_act_tramitador   ,
                                      g_k_cod_act_aseguradora  ,
                                      g_k_cod_act_reaseguradora,
                                      g_k_cod_act_broker       ,
                                      g_k_cod_act_empleado_agt )  -- Terceros comunes
      THEN
         --
         l_tip_act_economica := reg_a1001300.tip_act_economica;
         --
      END IF;
      --
      RETURN l_tip_act_economica;
      --
   END f_tip_act_economica;
   --
   /*-------------------------------------------------------------
   || Devuelve el tipo de iva del tercero, de la tabla A1001300
   */-------------------------------------------------------------
   --
   FUNCTION f_tip_tercero_iva
      RETURN a1001300.tip_tercero_iva%TYPE
   IS
   --
   BEGIN
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      RETURN reg_a1001300.tip_tercero_iva;
      --
   END f_tip_tercero_iva;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el apellido del contacto
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_apellido_contacto
      RETURN a1001331.apellido_contacto%TYPE
   IS
   --
      l_apellido_contacto a1001331.apellido_contacto%TYPE := g_k_nulo;
   --
   BEGIN
      --
      --@mx('I','f_apellido_contacto');
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado --Asegurados
      THEN
         --
         l_apellido_contacto := reg_a1001331.apellido_contacto;
         --
      END IF;
      --
      --@mx('F','f_apellido_contacto');
      --
      RETURN l_apellido_contacto;
      --
   END f_apellido_contacto;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el tipo de documento del contacto
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_tip_docum_contacto
      RETURN a1001331.tip_docum_contacto%TYPE
   IS
   --
      l_tip_docum_contacto a1001331.tip_docum_contacto%TYPE := g_k_nulo;
   --
   BEGIN
      --
      --@mx('I','f_tip_docum_contacto');
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado --Asegurados
      THEN
         --
         l_tip_docum_contacto := reg_a1001331.tip_docum_contacto;
         --
      END IF;
      --
      --@mx('F','f_tip_docum_contacto');
      --
      RETURN l_tip_docum_contacto;
      --
   END f_tip_docum_contacto;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el codigo de documento del contacto
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_cod_docum_contacto
      RETURN a1001331.cod_docum_contacto%TYPE
   IS
   --
      l_cod_docum_contacto a1001331.cod_docum_contacto%TYPE := g_k_nulo;
   --
   BEGIN
      --
      --@mx('I','f_cod_docum_contacto');
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado --Asegurados
      THEN
         --
         l_cod_docum_contacto := reg_a1001331.cod_docum_contacto;
         --
      END IF;
      --
      --@mx('F','f_cod_docum_contacto');
      --
      RETURN l_cod_docum_contacto;
      --
   END f_cod_docum_contacto;
   --
   /*-------------------------------------------------------------------------------
   || Devuelve el codigo de nacionalidad del contacto
   */-------------------------------------------------------------------------------
   --
   FUNCTION f_cod_nacionalidad_contacto
      RETURN a1001331.cod_nacionalidad_contacto%TYPE
   IS
   --
      l_cod_nacionalidad_contacto a1001331.cod_nacionalidad_contacto%TYPE := g_k_nulo;
   --
   BEGIN
      --
      --@mx('I','f_cod_nacionalidad_contacto');
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado --Asegurados
      THEN
         --
         l_cod_nacionalidad_contacto := reg_a1001331.cod_nacionalidad_contacto;
         --
      END IF;
      --
      --@mx('F','f_cod_nacionalidad_contacto');
      --
      RETURN l_cod_nacionalidad_contacto;
      --
   END f_cod_nacionalidad_contacto;
   --
   /*-------------------------------------------------------------
   || Devuelve el numero de hijos, de la tabla A1001331
   */-------------------------------------------------------------
   --
   FUNCTION f_num_hijos
      RETURN a1001331.num_hijos%TYPE
   IS
   --
      l_num_hijos a1001331.num_hijos%TYPE := g_k_nulo;
   --
   BEGIN
      --
      --@mx('I','f_num_hijos');
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado --Asegurados
      THEN
         --
         l_num_hijos := reg_a1001331.num_hijos;
         --
      END IF;
      --
      --@mx('F','f_num_hijos');
      --
      RETURN reg_a1001331.num_hijos;
      --
   END f_num_hijos;
   --
   /*-------------------------------------------------------------
   || Devuelve el tipo de rating, de la tabla A1001331
   */-------------------------------------------------------------
   --
   FUNCTION f_tip_rating
      RETURN a1001331.tip_rating%TYPE
   IS
   --
      l_tip_rating a1001331.tip_rating%TYPE := g_k_nulo;
   --
   BEGIN
      --
      --@mx('I','f_tip_rating');
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado --Asegurados
      THEN
         --
         l_tip_rating := reg_a1001331.tip_rating;
         --
      END IF;
      --
      --@mx('F','f_tip_rating');
      --
      RETURN reg_a1001331.tip_rating;
      --
   END f_tip_rating;
   --
   /*-------------------------------------------------------------
   || Devuelve la longitud de la direccion, de la tabla A1001331
   */-------------------------------------------------------------
   --
   FUNCTION f_txt_longitud
      RETURN a1001331.txt_longitud%TYPE
   IS
   --
      l_txt_longitud a1001331.txt_longitud%TYPE := g_k_nulo;
   --
   BEGIN
      --
      --@mx('I','f_txt_longitud');
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado --Asegurados
      THEN
         --
         l_txt_longitud := reg_a1001331.txt_longitud;
         --
      END IF;
      --
      --@mx('F','f_txt_longitud');
      --
      RETURN reg_a1001331.txt_longitud;
      --
   END f_txt_longitud;
   --
   /*-------------------------------------------------------------
   || Devuelve la latitud de la direccion, de la tabla A1001331
   */-------------------------------------------------------------
   --
   FUNCTION f_txt_latitud
      RETURN a1001331.txt_latitud%TYPE
   IS
   --
      l_txt_latitud a1001331.txt_latitud%TYPE := g_k_nulo;
   --
   BEGIN
      --
      --@mx('I','f_txt_latitud');
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado --Asegurados
      THEN
         --
         l_txt_latitud := reg_a1001331.txt_latitud;
         --
      END IF;
      --
      --@mx('F','f_txt_latitud');
      --
      RETURN reg_a1001331.txt_latitud;
      --
   END f_txt_latitud;
   --
   /*-------------------------------------------------------------
   || Devuelve la oficiana a la que esta asociada el asegurado, de la tabla A1001331
   */-------------------------------------------------------------
   --
   FUNCTION f_cod_nivel3_ref
      RETURN a1001331.cod_nivel3_ref%TYPE
   IS
   --
      l_cod_nivel3_ref a1001331.cod_nivel3_ref%TYPE := g_k_nulo;
   --
   BEGIN
      --
      --@mx('I','f_cod_nivel3_ref');
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado --Asegurados
      THEN
         --
         l_cod_nivel3_ref := reg_a1001331.cod_nivel3_ref;
         --
      END IF;
      --
      --@mx('F','f_cod_nivel3_ref');
      --
      RETURN reg_a1001331.cod_nivel3_ref;
      --
   END f_cod_nivel3_ref;
   --
   /*-------------------------------------------------------------
   || Devuelve la fecha de alta del asegurado, de la tabla A1001331
   */-------------------------------------------------------------
   --
   FUNCTION f_fec_alta
      RETURN a1001331.fec_alta%TYPE
   IS
   --
      l_fec_alta a1001331.fec_alta%TYPE := g_k_nulo;
   --
   BEGIN
      --
      --@mx('I','f_fec_alta');
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado --Asegurados
      THEN
         --
         l_fec_alta := reg_a1001331.fec_alta;
         --
      END IF;
      --
      --@mx('F','f_fec_alta');
      --
      RETURN reg_a1001331.fec_alta;
      --
   END f_fec_alta;
   --
   /*-------------------------------------------------------------
   || Devuelve la fecha de emision del documento, de la tabla A1001331
   */-------------------------------------------------------------
   --
   FUNCTION f_fec_emi_docum
      RETURN a1001331.fec_emi_docum%TYPE
   IS
   --
      l_fec_emi_docum a1001331.fec_emi_docum%TYPE := g_k_nulo;
   --
   BEGIN
      --
      --@mx('I','f_fec_emi_docum');
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado --Asegurados
      THEN
         --
         l_fec_emi_docum := reg_a1001331.fec_emi_docum;
         --
      END IF;
      --
      --@mx('F','f_fec_emi_docum');
      --
      RETURN reg_a1001331.fec_emi_docum;
      --
   END f_fec_emi_docum;
   --
   /*-------------------------------------------------------------
   || Devuelve la fecha de caducidad del documento, de la tabla A1001331
   */-------------------------------------------------------------
   --
   FUNCTION f_fec_caduc_docum
      RETURN a1001331.fec_caduc_docum%TYPE
   IS
   --
      l_fec_caduc_docum a1001331.fec_caduc_docum%TYPE := g_k_nulo;
   --
   BEGIN
      --
      --@mx('I','f_fec_caduc_docum');
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado --Asegurados
      THEN
         --
         l_fec_caduc_docum := reg_a1001331.fec_caduc_docum;
         --
      END IF;
      --
      --@mx('F','f_fec_caduc_docum');
      --
      RETURN reg_a1001331.fec_caduc_docum;
      --
   END f_fec_caduc_docum;
   --
   /*-------------------------------------------------------------
   || Devuelve el identificador del documento, de la tabla A1001331
   */-------------------------------------------------------------
   --
   FUNCTION f_cod_exp_docum
      RETURN a1001331.cod_exp_docum%TYPE
   IS
   --
      l_cod_exp_docum a1001331.cod_exp_docum%TYPE := g_k_nulo;
   --
   BEGIN
      --
      --@mx('I','f_cod_exp_docum');
      --
      p_comprueba_error(p_clave => g_k_nulo);
      --
      IF g_cod_act_tercero = g_k_cod_act_asegurado --Asegurados
      THEN
         --
         l_cod_exp_docum := reg_a1001331.cod_exp_docum;
         --
      END IF;
      --
      --@mx('F','f_cod_exp_docum');
      --
      RETURN reg_a1001331.cod_exp_docum;
      --
   END f_cod_exp_docum;
   --
END dc_k_terceros_trn;

