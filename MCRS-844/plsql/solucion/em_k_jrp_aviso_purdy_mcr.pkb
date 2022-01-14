create or replace PACKAGE BODY em_k_jrp_aviso_purdy_mcr AS
  --
  /* -------------------- VERSION = 1.0 --------------------
  || CARRIERHOUSE 22/06/2021
  || Creacion de package.
  */ -------------------------------------------------------
  /*---------------------- DESCRIPCION ---------------------
  ||
  || Reporte para JasperReports Aviso de Cobro PURDY.
  ||
  /* --------------------- MODIFICACIONES --------------------------
  || Modificacion 2021/09/30 - CARRIERHOUSE - v 1.01
  || Ajuste de calculos 
  || - Bruto total, Suma del total( restando comisiones y retenciones )
  || - Iva de la comision
  || Modificacion 2021/12/07 - CARRIERHOUSE - v 1.02
  || Se agrega 
  || - Poliza Colectiva
  */ ---------------------------------------------------------------
  /* -------------------------------------------
  || Definicion de Variables y Constantes
  */ -------------------------------------------
  g_cod_cia   a2000020.cod_cia%TYPE;
  g_num_aviso a5021646.cod_docum_pago%TYPE;
  --
  g_extension       PLS_INTEGER := trn_k_lis.ext_java;
  g_titulo_listado  VARCHAR2(1000) := NULL;
  g_pagina          PLS_INTEGER;
  g_linea           VARCHAR2(16000);
  g_txt_cab         VARCHAR2(16000);
  g_bool_write_form BOOLEAN := FALSE;
  g_cod_error       NUMBER;
  g_msg_error       VARCHAR2(2000);
  g_fila            BINARY_INTEGER;
  g_idioma          VARCHAR2(3);
  --
  g_secuencial    NUMBER := 0;
  g_id_fichero    NUMBER := 0; -- BINARY_INTEGER := 0;
  g_clob_datos    CLOB;
  g_clob_cab_par  CLOB;
  g_clob_cab_dat  CLOB;
  --
  k_cod_version     CONSTANT INTEGER := 1;
  k_nom_listado     CONSTANT VARCHAR2(100) := 'em_k_jrp_aviso_purdy_mcr';
  --
  g_k_pct_comis     CONSTANT NUMBER := 0.2;  
  g_k_pct_retencion CONSTANT NUMBER := 0.2;
  --
  l_nomaseg           VARCHAR2(145);
  l_numpoliza         a2000020.num_poliza%TYPE;
  l_polizagrupo       a2000030.num_poliza_grupo%TYPE;
  l_direccion         VARCHAR2(1000);
  l_fechasys          VARCHAR2(100);
  l_nom_agente        VARCHAR2(200);
  l_ramo              VARCHAR2(100);
  l_nombre_moneda     VARCHAR2(36);
  l_nombre_asegurado  VARCHAR2(256);
  l_simbolo_moneda    a1000400.cod_mon_iso%TYPE;
  --
  l_tdocum      VARCHAR(3);
  l_cdocum      VARCHAR(20);
  l_fech_efec   VARCHAR2(100);
  l_fech_vcto   VARCHAR2(100);
  l_impneta     VARCHAR2(100);
  l_imptotbruto VARCHAR2(100);
  --
  l_impimpuesto VARCHAR2(100);
  l_imprecargo  VARCHAR2(100);
  l_primatotal  VARCHAR2(100);
  l_concepto    VARCHAR2(1000);
  l_ideaseg     VARCHAR2(40);
  --
  l_documcia      VARCHAR2(16);
  l_provinciacia  VARCHAR2(30);
  l_domiciliocia  VARCHAR2(125);
  l_tlfcia        VARCHAR2(26);
  l_faxcia        VARCHAR2(26);
  l_emailcia      VARCHAR2(254);
  --
  -- CURSOR QUE OBTIENE LOS DATOS DEL NUMERO DE AVISO
  CURSOR c_datos_aviso( pc_cod_cia a2100170.cod_cia%TYPE, 
                        pc_num_aviso a5021646.cod_docum_pago%TYPE
                      ) IS
    SELECT a.cod_cia,
           a.cod_docum_pago,
           a.tip_docum,
           a.cod_docum,
           b.cod_agt,
           b.cod_mon,
           b.num_poliza,
           a.num_poliza_grupo,
           em_f_cod_ramo(a.cod_cia, min(b.num_poliza)) cod_ramo,
           min(b.fec_efec_recibo) fec_efec_desde,
           max(b.fec_vcto_recibo) fec_efec_hasta,
           sum(b.imp_recibo) imp_total_recibos
      FROM a5021646 a, a2990700 b
     where a.cod_cia = pc_cod_cia
       AND a.tip_docum_pago = 'AV'
       AND a.cod_docum_pago = pc_num_aviso
       AND a.num_mvto =
           (SELECT MAX(x.num_mvto)
              FROM a5021646 x
             WHERE x.cod_cia = pc_cod_cia
               AND x.tip_docum_pago = 'AV'
               AND x.cod_docum_pago = pc_num_aviso
           )
       AND a.cod_cia        = b.cod_cia
       AND a.tip_docum_pago = b.tip_docum_pago
       AND a.cod_docum_pago = b.cod_docum_pago
     GROUP BY a.cod_cia,
              a.cod_docum_pago,
              a.tip_docum,
              a.cod_docum,
              b.cod_agt,
              b.cod_mon,
              b.num_poliza,
              a.num_poliza_grupo;
  --
  -- TABLA QUE CONTIENE LOS VALORES DE LAS ETIQUETAS
  -------------------------------------------------------------
  TYPE reg_etiquetas IS RECORD(
    titulo_eti VARCHAR2(30),
    modulo_eti VARCHAR2(3),
    texto_eti  VARCHAR2(5),
    idioma_eti VARCHAR2(3),
    contenido  VARCHAR2(255)
  );
  --
  g_reg_etiquetas reg_etiquetas;
  g_reg_etiquetas_nulo reg_etiquetas;
  --
  TYPE tabla_etiquetas IS TABLE OF g_reg_etiquetas%TYPE INDEX BY BINARY_INTEGER;
  --
  g_tb_etiquetas tabla_etiquetas;
  --
  -- datos de dal empresa, RGUERRA, modificaciones 20210809
  PROCEDURE f_datos_mapfrecr( pp_cod_cia       IN  a2100170.cod_cia%TYPE,
                              pp_cod_docum_cia OUT VARCHAR2,
                              pp_provincia_cia OUT VARCHAR2,
                              pp_domicilio_cia OUT VARCHAR2,
                              pp_tlf_cia       OUT VARCHAR2,
                              pp_fax_cia       OUT VARCHAR2,
                              pp_email_cia     OUT VARCHAR2
                            ) IS
    --
    -- datos de la compania                        
    CURSOR c_dat_cia IS
      SELECT  TRIM(substr(cod_docum_cia, 1, 1) || '-' ||
                  substr(cod_docum_cia, 2, 3) || '-' ||
                  substr(cod_docum_cia, 5, 10)
              ) AS cod_docum_cia,
              initcap((SELECT nom_prov
                        FROM A1000100
                        WHERE cod_pais = a.cod_pais
                          AND cod_prov = a.cod_prov
                          AND cod_estado = a.cod_estado)
                     ) AS provincia_cia,
              initcap( nom_domicilio1 || ', ' || nom_domicilio2 || ', ' ||
                        nom_domicilio3 || '.'
                      ) AS domicilio_cia,
              'T. (' || tlf_pais || ') ' || substr(tlf_numero, 1, 4) || ' ' ||
                     substr(tlf_numero, 5, 10) || '.' AS tlf_cia,
              'F. (' || tlf_pais || ') ' || substr(fax_numero, 1, 4) || ' ' ||
                     substr(fax_numero, 5, 10) || '.' AS fax_cia,
              email AS email_cia
        FROM A1000900 a
       WHERE cod_cia = pp_cod_cia;
    --                          
  BEGIN
    --
    OPEN c_dat_cia;
    FETCH c_dat_cia INTO pp_cod_docum_cia, pp_provincia_cia, pp_domicilio_cia, 
                         pp_tlf_cia, pp_fax_cia,  pp_email_cia;
    CLOSE c_dat_cia;
    --
    EXCEPTION 
      WHEN OTHERS THEN 
        pp_cod_docum_cia := NULL;
        pp_provincia_cia := NULL;
        pp_domicilio_cia := NULL;
        pp_tlf_cia       := NULL;
        pp_fax_cia       := NULL;
        pp_email_cia     := NULL;
    --    
  END f_datos_mapfrecr;
  --
  -- calcula el importe para un determinado concepto de los recibios
  -- IVA, RECARGO y PRIMA
  FUNCTION f_importe_concepto(  pp_cod_cia        a2000030.cod_cia%TYPE, 
                                pp_num_poliza     a2000030.num_poliza%TYPE, 
                                pp_num_cuota      a2990700.num_cuota%TYPE, 
                                pp_num_spto       a2990700.num_spto%TYPE, 
                                pp_num_apli       a2990700.num_apli%TYPE, 
                                pp_num_spto_apli  a2990700.num_spto_apli%TYPE,
                                pp_list_concepto  VARCHAR2 -- lista separada por ','
                             ) RETURN NUMBER IS
    -- 
    l_cod_concepto  a2000161.cod_eco%TYPE;
    l_importe       NUMBER := 0;
    l_importe_total NUMBER := 0;
    --
    -- lista de parametros
    CURSOR c_conceptos(pc_lista VARCHAR2) IS
      SELECT rownum, regexp_substr(pc_lista, '[^;]+', 1, LEVEL) dato
        FROM DUAL
        CONNECT BY regexp_substr(pc_lista, '[^;]+', 1, LEVEL) IS NOT NULL;
    --
    -- buscamos los montos en los recibos
    CURSOR c_importe_eco IS
      SELECT sum(a.imp_eco) total_cto
        FROM a2000161 a,        -- conceptos economicos de recibos de una determinada poliza 
             g2000161 b         -- conceptos economicos de recibos (definicion)
       WHERE a.cod_cia       = pp_cod_cia
         AND a.num_poliza    = pp_num_poliza
         AND a.num_spto      = pp_num_spto
         AND a.num_apli      = pp_num_apli
         AND a.num_spto_apli = pp_num_spto_apli
         AND a.num_cuota     = pp_num_cuota
         AND a.cod_cia       = b.cod_cia
         AND a.cod_eco       = b.cod_eco
         AND a.cod_eco       = l_cod_concepto;
    --     
  BEGIN     
    --
    IF pp_list_concepto IS NOT NULL THEN 
      --
      FOR v IN c_conceptos(pp_list_concepto) LOOP
        --
        OPEN c_importe_eco;
        FETCH c_importe_eco INTO l_importe;
        IF c_importe_eco%FOUND THEN
          l_importe_total := l_importe_total + nvl(l_importe, 0);
        END IF; 
        CLOSE c_importe_eco;
        --
      END LOOP;
      --
      RETURN l_importe_total;
      --
    ELSE
      RETURN 0;
    END IF;  
    --
    EXCEPTION 
      WHEN OTHERS THEN 
        RETURN 0;
    --    
  END f_importe_concepto;
  --
  -- procesar cadenas
  FUNCTION f_procesa_cad(p_cad IN OUT VARCHAR2) RETURN VARCHAR2 IS
    --
    l_cad2 VARCHAR2(200);
    --
  BEGIN
    --
    l_cad2 := chr(65) || chr(69) || chr(73) || chr(79) || chr(85) ||
              chr(160) || chr(130) || chr(161) || chr(162) || chr(163) ||
              chr(78) || chr(209) || chr(241);
    --
    p_cad := translate(p_cad, '+?+?????????&', l_cad2);
    --
    RETURN p_cad;
    --
  END f_procesa_cad;
  --
  -- importes 
  PROCEDURE p_importes( p_cod_cia         IN a2000030.cod_cia%TYPE,
                        p_tip_docum_pago  IN a2990700.tip_docum_pago%TYPE,
                        p_cod_docum_pago  IN a2990700.tip_docum_pago%TYPE,
                        p_imp_prima_neta  IN OUT NUMBER, -- prima + recagago
                        p_imp_impuesto    IN OUT NUMBER, -- total del importe impuestos
                        p_imp_comision    IN OUT NUMBER, -- comision
                        p_imp_intereses   IN OUT NUMBER  -- importe de los intereses
                      ) IS
    --
    l_imp_prima_neta NUMBER := 0;
    l_imp_impuesto   NUMBER := 0;
    l_imp_recargo    NUMBER := 0;
    l_imp_comision   NUMBER := 0;
    l_imp_intereses  NUMBER := 0;
    --
    -- seleccionamos los recibos de un documento de cobro (aviso)
    CURSOR c_recibos IS
      SELECT cod_cia,
             num_poliza,
             num_recibo,
             imp_recibo,
             imp_neta,
             imp_recargo,
             imp_imptos,
             imp_comis,
             imp_interes,
             num_spto,
             num_apli,
             num_spto_apli,
             num_cuota
        from a2990700       -- recibos de un documento de cobro (aviso) determinado
       where cod_cia        = p_cod_cia
         and tip_docum_pago = p_tip_docum_pago
         and cod_docum_pago = p_cod_docum_pago;
    --
    -- imporce de los conceptos economicos de una determinda poliza para el codigo de concepto (OTROS)
    CURSOR c_otros( pc_cod_cia a2000030.cod_cia%TYPE, 
                    pc_num_poliza a2000030.num_poliza%TYPE, 
                    pc_num_cuota a2990700.num_cuota%TYPE, 
                    pc_num_spto a2990700.num_spto%TYPE, 
                    pc_num_apli a2990700.num_apli%TYPE, 
                    pc_num_spto_apli a2990700.num_spto_apli%TYPE
                  ) IS
      select sum(a.imp_eco) total_cto
        from a2000161 a, 
             g2000161 b
       where a.cod_cia = pc_cod_cia
         and a.num_poliza = pc_num_poliza
         and a.num_spto = pc_num_spto
         and a.num_apli = pc_num_apli
         and a.num_spto_apli = pc_num_spto_apli
         and a.num_cuota = pc_num_cuota
         and a.cod_cia = b.cod_cia
         and a.cod_eco = b.cod_eco
         and a.cod_eco NOT IN (1, 3, 4, 999);
    --
  BEGIN
    --
    -- calculamos los totales de los importes
    FOR reg IN c_recibos LOOP
      --
      -- obtenemos la prima neta
      l_imp_prima_neta := l_imp_prima_neta + nvl(reg.imp_neta, 0);
      l_imp_recargo    := l_imp_recargo + nvl(reg.imp_recargo, 0);
      --
      -- obtenemos el impuesto
      l_imp_impuesto   := l_imp_impuesto + nvl(reg.imp_imptos, 0);
      --
      -- comisiones
      l_imp_comision := l_imp_comision + nvl(reg.imp_comis, 0);
      --
      -- intereses
      l_imp_intereses := l_imp_intereses + nvl(reg.imp_interes, 0);
      --
    END LOOP;
    --
    p_imp_prima_neta := l_imp_prima_neta + l_imp_recargo;
    p_imp_impuesto   := l_imp_impuesto;
    --
    -- Este es el valor que viene del recibo original
    -- p_imp_comision   := l_imp_comision;
    p_imp_comision   := p_imp_prima_neta * ( 3.5/100 );
    p_imp_intereses  := l_imp_intereses;
    --
    EXCEPTION
      WHEN OTHERS THEN
        p_imp_prima_neta  := 0;
        p_imp_impuesto    := 0;
        p_imp_comision    := 0;
        p_imp_intereses   := 0;
    --    
  END p_importes;
  /* ---------------------------------------------------------------------
  || Imprime la Cabecera--------------------------------------------------
  */ ---------------------------------------------------------------------
  PROCEDURE p_lista(  p_cod_cia   a1000900.cod_cia%TYPE,
                      p_num_aviso a5021646.cod_docum_pago%TYPE
                   ) IS
    --
    l_ref_listado VARCHAR2(50);
    l_reg_poliza  a2000030%ROWTYPE;
    -----------------------------------------------------------------------
    /* ----------------------------------------------------------
    || Rellena tabla PL con los valores que se necesitan para las
    || etiqueta--------------------------------------------------
    */ ----------------------------------------------------------
    PROCEDURE pp_rellena_tb_etiquetas(p_titulo_eti VARCHAR2,
                                      p_modulo_eti VARCHAR2,
                                      p_texto_eti  VARCHAR2,
                                      p_idioma_eti VARCHAR2,
                                      p_tipo       VARCHAR2 := 'NORMAL'
                                     ) IS
    BEGIN
      --
      g_fila := g_fila + 1;
      --
      g_tb_etiquetas(g_fila).titulo_eti := p_titulo_eti;
      g_tb_etiquetas(g_fila).modulo_eti := p_modulo_eti;
      g_tb_etiquetas(g_fila).texto_eti  := p_texto_eti;
      g_tb_etiquetas(g_fila).idioma_eti := p_idioma_eti;
      --
      -- Se guarda el contenido  en la tabla
      ss_k_g1010021.p_lee(g_tb_etiquetas(g_fila).modulo_eti,
                          g_tb_etiquetas(g_fila).texto_eti,
                          g_tb_etiquetas(g_fila).idioma_eti);
      IF (nvl(p_tipo, 'NORMAL') = 'UPPER') THEN
        g_tb_etiquetas(g_fila).contenido := upper(ss_k_g1010021.f_txt_mensaje);
      ELSE
        g_tb_etiquetas(g_fila).contenido := ss_k_g1010021.f_txt_mensaje;
      END IF;
      --
    END pp_rellena_tb_etiquetas;
    /* ---------------------------------------------------------
    || Recupera el titulo de las etiquetas.
    */ ---------------------------------------------------------
    PROCEDURE pp_inicializa_titulo IS
    BEGIN
      --
      g_linea := NULL;
      --
      FOR l_fila IN 1 .. nvl(g_tb_etiquetas.LAST, 0) LOOP
        --
        g_linea := g_linea || g_tb_etiquetas(l_fila).titulo_eti || ';';
        --
      END LOOP;
      --
    END pp_inicializa_titulo;
    /* ---------------------------------------------------------
    || Recupera el valor de las etiquetas con los datos de la
    || la tabla PL
    */ ---------------------------------------------------------
    PROCEDURE pp_inicializa_etiquetas IS
    BEGIN
      --
      g_reg_etiquetas := g_reg_etiquetas_nulo;
      g_linea         := NULL;
      FOR l_fila IN 1 .. nvl(g_tb_etiquetas.LAST, 0) LOOP
        --
        g_linea := g_linea || g_tb_etiquetas(l_fila).contenido || ';';
        --
      END LOOP;
      --
    END pp_inicializa_etiquetas;
    --
    -- FUNCION QUE RETORNA NUMERO CON FORMATO
    FUNCTION fp_procesa_mto(p_num NUMBER, p_dec NUMBER := 0) RETURN VARCHAR2 AS
      --
      l_ret VARCHAR(30) := to_char(trunc(p_num, p_dec),'9,999,999,999,999.999999999');
      --
    BEGIN
      --
      -- Aplicar el formato de los decimales.
      l_ret := substr(l_ret, 1, 18) || '.' || substr(l_ret, 20, p_dec);
      --
      IF substr(rtrim(ltrim(l_ret)), 1, 1) = '.' THEN
        l_ret := '0' || rtrim(ltrim(l_ret));
      END IF;
      -- Fin versiÃ?Â³n 2.00
      --
      IF p_num IS NULL THEN
        l_ret := '0.00';
      END IF;
      --
      RETURN rtrim(ltrim(l_ret));
      --
    END fp_procesa_mto;
    --
    -- FUNCION QUE RETORNA FECHA CON FORMATO
    FUNCTION fp_desc_fecha(p_fecha DATE) RETURN VARCHAR2 IS
      --
      l_valor_retorno VARCHAR2(100);
      --
    BEGIN
      --
      l_valor_retorno := to_char(p_fecha, 'DD/MM/YYYY');
      --
      RETURN(l_valor_retorno);
      --
    END fp_desc_fecha;
    --
    -- FUNCION QUE RETORNA RAZON SOCIAL DE LA COMPA?IA
    FUNCTION cf_razon_socialFormula RETURN CHAR IS
      --
      l_razon VARCHAR2(200);
      --
    BEGIN
      --
      SELECT nom_razon_social
        INTO l_razon
        FROM a1000900
       WHERE cod_cia = g_cod_cia;
      --
      RETURN l_razon;
      --
      EXCEPTION
        WHEN OTHERS THEN
          RETURN NULL;
    END cf_razon_socialFormula;
    --
    -- datos de la poliza    
    PROCEDURE p_info_poliza IS 
    BEGIN 
      --
      l_reg_poliza := em_k_a2000030.f_reg_max_spto( p_cod_cia           => g_cod_cia,
                                                    p_num_poliza        => l_numpoliza,
                                                    p_num_spto          => null,
                                                    p_mca_spto_tmp      => 'N',
                                                    p_mca_spto_anulado  => 'N'
                                                  );  

      l_polizagrupo := l_reg_poliza.num_poliza_grupo;                                            

      --
      EXCEPTION 
        WHEN OTHERS THEN 
          l_reg_poliza := NULL;
          --
    END p_info_poliza;
    --
    -- informacion del asegurado
    FUNCTION cf_datos_asegurado RETURN VARCHAR2 IS
      --
      l_nom_tercero VARCHAR2(256);
      --
      CURSOR c_dato_asegurado IS 
        SELECT b.nom_tercero||' '||b.ape1_tercero||' '||b.ape2_tercero
          FROM a2000060 a,
               a1001399 b
        WHERE a.num_poliza = l_numpoliza
          AND a.tip_benef = 8
          AND b.cod_cia   = a.cod_cia
          AND b.tip_docum = a.tip_docum
          AND b.cod_docum = a.cod_docum;
    BEGIN 
      --
      OPEN c_dato_asegurado;
      FETCH c_dato_asegurado INTO l_nom_tercero;
      IF c_dato_asegurado%NOTFOUND THEN
        l_nom_tercero := NULL;
      END IF;
      CLOSE c_dato_asegurado;
      --
      RETURN l_nom_tercero;   
      --
      EXCEPTION 
        WHEN OTHERS THEN 
          RETURN NULL;
          --
    END cf_datos_asegurado;
    --
    -- INICIA PARAMETROS
    PROCEDURE pp_parametros IS
      --
      l_titulo_listado g1010161.nom_listado%TYPE;
      l_aseg_aviso     c_datos_aviso%ROWTYPE;
      l_numprimaneta   NUMBER := 0;
      l_numiva         a2990700.imp_imptos%TYPE;
      l_numrecargo     a2990700.imp_recargo%TYPE;
      l_numinteres     a2990700.imp_interes%TYPE;
      l_prima          a2990700.imp_neta%TYPE;
      l_num_aviso      VARCHAR2(100);
      l_comision       VARCHAR2(100);
      l_retencion      VARCHAR2(100);
      l_comis          NUMBER := 0;
      l_reten          NUMBER := 0;
      l_ivacomis       NUMBER := 0;
      l_numtotbruto    NUMBER := 0;
      --
      -- FUNCION QUE DEVUELVE NOMBRE DE AGENTE CONCATENADO
      FUNCTION CF_NomagtFormula(p_cod_agt a1001332.cod_agt%TYPE) RETURN CHAR IS
        --
        l_nombre_agt VARCHAR2(140);
        --
      BEGIN
        --
        SELECT a.cod_agt || ' ' || b.nom_tercero || ' ' || b.ape1_tercero || ' ' ||
               b.ape2_tercero
          INTO l_nombre_agt
          FROM a1001332 a, a1001399 b
         WHERE a.cod_cia = g_cod_cia
           AND a.cod_agt = p_cod_agt
           AND a.fec_validez =
               (SELECT MAX(x.fec_validez)
                  FROM a1001332 x
                 WHERE x.cod_agt = a.cod_agt)
           AND a.cod_cia = b.cod_cia
           AND a.tip_docum = b.tip_docum
           AND a.cod_docum = b.cod_docum;
        --
        RETURN l_nombre_agt;
        --
        EXCEPTION
          WHEN no_data_found THEN
            RETURN 'N/A';
      END CF_NomagtFormula;
      --
      -- FUNCION QUE DEVUELVE DIRECCION CONCATENADA
      FUNCTION CF_DireccionFormula(p_tdocum a1001331.tip_docum%TYPE,
                                   p_cdocum a1001331.cod_docum%TYPE) RETURN CHAR IS
        --
        l_direccion VARCHAR2(145);
        --
      BEGIN
        --
        SELECT nom_domicilio1 || ' ' || nom_domicilio2 || ' ' ||
               nom_domicilio3
          INTO l_direccion
          FROM a1001331
         WHERE tip_docum = p_tdocum
           AND cod_docum = p_cdocum;
        --
        RETURN l_direccion;
        --
        EXCEPTION
          WHEN no_data_found THEN
            RETURN 'N/A';
        --    
      END CF_DireccionFormula;
      --
      -- FUNCION QUE VALIDA SI HAY TOMADOR ALTERNO Y DEVUELVE NOMBRE ASEGURADO CONCATENADO
      FUNCTION CF_NomAsegFormula(p_tdocum a1001331.tip_docum%TYPE,
                                 p_cdocum a1001331.cod_docum%TYPE) RETURN CHAR IS
        --                         
        l_nom_aseg VARCHAR2(145);
        --
      BEGIN
        --
        SELECT a.nom_tercero || ' ' || a.ape1_tercero || ' ' ||
               a.ape2_tercero
          INTO l_nom_aseg
          FROM a1001399 a
         WHERE a.cod_cia = g_cod_cia
           AND a.tip_docum = p_tdocum
           AND a.cod_docum = p_cdocum;
        --
        RETURN l_nom_aseg;
        --
        EXCEPTION
          WHEN no_data_found THEN
            RETURN 'N/A';
        --    
      END CF_NomAsegFormula;
      --
      -- FUNCION QUE RETORNA NOMBRE DEL RAMO
      FUNCTION CF_NomRamoFormula(p_codramo a1001800.cod_ramo%TYPE) RETURN CHAR IS
        --
        l_nom_ramo VARCHAR2(40);
        --
      BEGIN
        BEGIN
          --
          SELECT nom_ramo
            INTO l_nom_ramo
            FROM a1001800
           WHERE cod_ramo = p_codramo;
          -- 
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_nom_ramo := NULL;
        END;
        --
        RETURN l_nom_ramo;
        --
      END CF_NomRamoFormula;
      --
      -- FUNCION QUE RETORNA NOMBRE DE LA MONEDA 
      FUNCTION CF_MonedaFormula(p_cod_mon a1000400.cod_mon%TYPE) RETURN CHAR IS
        --
        l_moneda VARCHAR2(36);
        --
      BEGIN
        --
        BEGIN
          SELECT cod_mon_iso || '   ' || nom_mon
            INTO l_moneda
            FROM a1000400
           WHERE cod_mon = p_cod_mon;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_moneda := NULL;
        END;
        --
        RETURN l_moneda;
        --
      END CF_MonedaFormula;
      --
      -- FUNCION QUE RETORNA SIMBOLO DE LA MONEDA
      FUNCTION CF_MonedaIsoFormula(p_cod_mon a1000400.cod_mon%TYPE) RETURN CHAR IS
        --
        monedaiso VARCHAR2(3);
        --
      BEGIN
        --
        BEGIN
          SELECT cod_mon_iso
            INTO monedaiso
            FROM a1000400
           WHERE cod_mon = p_cod_mon;
        EXCEPTION
          WHEN no_Data_found THEN
            monedaiso := NULL;
        END;
        --
        RETURN monedaiso;
        --
      END CF_MonedaIsoFormula;
      --
      -- FUNCION QUE RETORNA PRIMA TOTAL 
      FUNCTION CF_1Formula(p_impneta     a2990700.imp_neta%TYPE,
                           p_imprecargo  a2990700.imp_recargo%TYPE,
                           p_impimptos   a2990700.imp_imptos%TYPE,
                           p_imp_interes a2990700.imp_interes%TYPE) RETURN NUMBER IS
        --                    
        l_prima_total NUMBER := 0;
        --
      BEGIN
        --
        l_prima_total := nvl(p_impneta,0) + nvl(p_imprecargo,0) + nvl(p_impimptos,0) + nvl(p_imp_interes,0);
        --
        IF l_prima_total IS NULL THEN
          l_prima_total := 0;
        END IF;
        --
        RETURN l_prima_total;
        --
      END CF_1Formula; 
      --
      -- FUNCION QUE RETORNA CONCEPTO DEL RECIBO
      FUNCTION CF_ConceptoFormula(p_num_polizagrupo a2000030.num_poliza_grupo%TYPE) RETURN CHAR IS
        --
        l_concepto VARCHAR2(150);
        l_tip_spto a2000030.tip_spto%TYPE;
        l_num_spto a2000030.num_spto%TYPE;
        --
      BEGIN
        --
        BEGIN
          --
          SELECT MAX(num_spto)
            INTO l_num_spto
            FROM a2000030
           WHERE cod_cia = g_cod_cia
             AND num_poliza_grupo = p_num_polizagrupo
             AND tip_spto IN ('XX', 'RE');
          --   
          IF l_num_spto = 0 THEN
            l_tip_spto := 'XX';
          ELSE
            l_tip_spto := 'RE';
          END IF;
          --
          SELECT l_tip_spto || ' ' || nom_valor
            INTO l_concepto
            FROM g1010031
           WHERE cod_idioma = 'ES'
             AND cod_campo = 'TIP_SPTO'
             AND cod_valor = l_tip_spto;
          --   
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_concepto := 'N/A';
          --    
        END;
        --
        RETURN l_concepto;
        --
      END CF_ConceptoFormula;
      --
      -- PROCEDIMIENTO QUE RETORNA VALOR CERO SI UN REGISTRO NUMERICO NO TIENE DATOS
      PROCEDURE pi_valorcero IS
      BEGIN
        --
        IF l_numprimaneta IS NULL THEN
          l_numprimaneta := 0;
        END IF;
        --
        IF l_numiva IS NULL THEN
          l_numiva := 0;
        END IF;
        --
        IF l_numinteres IS NULL THEN
          l_numinteres := 0;
        END IF;
        --
      END pi_valorcero;
      --
    BEGIN
      --
      g_idioma := trn_k_global.cod_idioma;
      --
      pp_rellena_tb_etiquetas('No', 'TRN', '220', 'ES');
      pp_rellena_tb_etiquetas('Cedula', 'EM', '2070', 'ES');
      pp_rellena_tb_etiquetas('Fecha', 'TS', '499', 'ES');
      pp_rellena_tb_etiquetas('NombreTomador', 'EM', '1701', 'ES');
      pp_rellena_tb_etiquetas('PolizaNo', 'EM', '2000', 'ES');
      pp_rellena_tb_etiquetas('Ramo', 'TRN', '1053', 'ES');
      pp_rellena_tb_etiquetas('Intermediario', 'EM', '1702', 'ES');
      pp_rellena_tb_etiquetas('DireccionExacta', 'EM', '531', 'ES');
      pp_rellena_tb_etiquetas('Moneda', 'TRN', '1024', 'ES');
      pp_rellena_tb_etiquetas('Vigencia', 'DC', '119', 'ES');
      pp_rellena_tb_etiquetas('Desde', 'CO', '63', 'ES');
      pp_rellena_tb_etiquetas('Hasta', 'CO', '64', 'ES');
      pp_rellena_tb_etiquetas('NumeroRecibo', 'GC', '1', 'ES');
      pp_rellena_tb_etiquetas('Hora', 'TRN', '717', 'ES');
      pp_rellena_tb_etiquetas('Sub_Concepto', 'RA', '179', 'ES');
      pp_rellena_tb_etiquetas('Sub_Monto', 'EM', '1705', 'ES');
      pp_rellena_tb_etiquetas('PrimaNeta', 'TRN', '93', 'ES');
      pp_rellena_tb_etiquetas('IV', 'GC', '567', 'ES');
      pp_rellena_tb_etiquetas('Recargo', 'GC', '287', 'ES');
      pp_rellena_tb_etiquetas('PrimaTotal', 'EM', '118', 'ES');
      pp_rellena_tb_etiquetas('TotalSumaAseg', 'EM', '206', 'ES');
      pp_rellena_tb_etiquetas('Comision', 'EM', '79', 'ES');
      pp_rellena_tb_etiquetas('Retencion', 'GC', '49', 'ES');
      --
      g_fila := g_tb_etiquetas.count + 1;
      --
      -- RGUERRA, 20210812
      g_tb_etiquetas(g_fila).titulo_eti := 'IVComision';
      g_tb_etiquetas(g_fila).modulo_eti := 'EM';
      g_tb_etiquetas(g_fila).texto_eti  := '79';
      g_tb_etiquetas(g_fila).idioma_eti := 'ES';
      g_tb_etiquetas(g_fila).contenido  := 'IVA Comision';
      --
      g_fila := g_fila + 1;
      --
      -- RGUERRA, 20210930 v 1.02
      g_tb_etiquetas(g_fila).titulo_eti := 'TotalBruto';
      g_tb_etiquetas(g_fila).modulo_eti := 'EM';
      g_tb_etiquetas(g_fila).texto_eti  := '79';
      g_tb_etiquetas(g_fila).idioma_eti := 'ES';
      g_tb_etiquetas(g_fila).contenido  := 'Total Bruto';
      --
      g_fila := g_fila + 1;
      --
      -- RGUERRA, 20210930 v 1.03
      g_tb_etiquetas(g_fila).titulo_eti := 'PolizaGrupo';
      g_tb_etiquetas(g_fila).modulo_eti := 'GC';
      g_tb_etiquetas(g_fila).texto_eti  := '334';
      g_tb_etiquetas(g_fila).idioma_eti := 'ES';
      g_tb_etiquetas(g_fila).contenido  := 'Poliza Grupo';
      --
      g_fila := g_fila + 1;
      --
      -- RGUERRA, 20210930 v 1.03
      g_tb_etiquetas(g_fila).titulo_eti := 'Asegurado';
      g_tb_etiquetas(g_fila).modulo_eti := 'EM';
      g_tb_etiquetas(g_fila).texto_eti  := '341';
      g_tb_etiquetas(g_fila).idioma_eti := 'ES';
      g_tb_etiquetas(g_fila).contenido  := 'Asegurado';
      --
      l_ref_listado := k_nom_listado || '.' || to_char(g_extension);
      trn_k_global.asigna('JBNOM_PARAMETROS', l_ref_listado);
      --
      --
      g_id_fichero := 0;
      g_id_fichero := trn_k_report.f_open_report(g_clob_datos, l_ref_listado, 'param');
      --
      g_fila := 0;
      pp_inicializa_titulo;
      --
      g_clob_cab_par := to_clob(g_linea);
      --
      -- RGUERRA, se agrega IVA Comision y total bruto
      g_linea        := g_linea || 'Titulo' || ';' || 'F_numaviso' || ';' ||
                        'F_ideaseg' || ';' || 'F_Fecsys' || ';' ||
                        'Nom_Aseg' || ';' || 'Direccion' || ';' ||
                        'F_numpoliza' || ';' || 'F_nomramo' || ';' ||
                        'Nom_Agente' || ';' || 'Simb_Moneda' || ';' ||
                        'Nomb_moneda' || ';' || 'F_efecpoliza' || ';' ||
                        'F_vctopoliza' || ';' || 'F_concepto' || ';' ||
                        'F_primaneta' || ';' || 'F_iva' || ';' ||
                        'F_recargofin' || ';' || 'F_primatotal' || ';' ||
                        'docum_cia' || ';' || 'provincia_cia' || ';' ||
                        'domicilio_cia' || ';' || 'tlf_cia' || ';' ||
                        'fax_cia' || ';'||'F_comision'||';'||'F_retencion'||';'||'F_ivacomision'||';'||
                        'F_totalbruto' ||';'||'F_polizagrupo'||';'||'F_asegurado'||';';
      --                  
      g_linea        := f_procesa_cad(g_linea);
      g_clob_cab_par := to_clob(g_linea);
      pp_inicializa_etiquetas;
      --
      IF g_titulo_listado IS NOT NULL THEN
        g_titulo_listado := '';
      END IF;
      --
      LOOP
        l_titulo_listado := ss_k_g1010161.f_devuelve_titulo(k_nom_listado,
                                                            trn_k_global.cod_idioma,
                                                            'N');
        g_titulo_listado := l_titulo_listado || g_titulo_listado;
        EXIT WHEN l_titulo_listado IS NULL;
      END LOOP;
      --
      --VALIDA SI EL CURSOR ESTA ABIERTO SI ES ASI LO CIERRA
      IF c_datos_aviso%ISOPEN THEN
        CLOSE c_datos_aviso;
      END IF;
      --
      -- obtenemos los datos del aviso
      OPEN c_datos_aviso(g_cod_cia, g_num_aviso);
      FETCH c_datos_aviso INTO l_aseg_aviso;
      --
      l_cdocum         := l_aseg_aviso.cod_docum;
      l_tdocum         := l_aseg_aviso.tip_docum;
      l_nomaseg        := CF_NomAsegFormula(l_aseg_aviso.tip_docum, l_aseg_aviso.cod_docum);
      --
      -- datos de la poliza
      l_numpoliza         := l_aseg_aviso.num_poliza;
      l_polizagrupo       := l_aseg_aviso.num_poliza_grupo;
      --p_info_poliza;
      l_nombre_asegurado  := cf_datos_asegurado;
      --
      l_ramo           := CF_NomRamoFormula(l_aseg_aviso.cod_ramo);
      l_nom_agente     := CF_NomagtFormula(l_aseg_aviso.cod_agt);
      l_direccion      := CF_DireccionFormula(l_aseg_aviso.tip_docum, l_aseg_aviso.cod_docum);
      l_nombre_moneda  := CF_MonedaFormula(l_aseg_aviso.cod_mon);
      l_simbolo_moneda := CF_MonedaIsoFormula(l_aseg_aviso.cod_mon);
      l_numprimaneta   := 0; --l_aseg_aviso.primaneta;
      l_prima          := 0; --l_aseg_aviso.imp_neta;
      l_numiva         := 0; --l_aseg_aviso.imp_imptos;
      l_numinteres     := 0; --l_aseg_aviso.imp_interes;
      l_numrecargo     := 0; --l_aseg_aviso.imp_recargo;
      l_fech_efec      := fp_desc_fecha(l_aseg_aviso.fec_efec_desde);
      l_fech_vcto      := fp_desc_fecha(l_aseg_aviso.fec_efec_hasta);
      l_concepto       := CF_ConceptoFormula(l_aseg_aviso.num_poliza_grupo);
      l_num_aviso      := l_aseg_aviso.cod_docum_pago;
      --
      CLOSE c_datos_aviso;
      --
      -- inicializa a 0 varibale si son nulas
      pi_valorcero;
      --
      -- obtenemos los importes 
      p_importes( p_cod_cia         => g_cod_cia,
                  p_tip_docum_pago  => 'AV',
                  p_cod_docum_pago  => g_num_aviso,
                  p_imp_prima_neta  => l_numprimaneta,  -- prima + recagago
                  p_imp_impuesto    => l_numiva,        -- total del importe impuestos
                  p_imp_comision    => l_comis,         -- comision
                  p_imp_intereses   => l_numrecargo     -- importe de los intereses
                );
      --
      l_impneta     := fp_procesa_mto(l_numprimaneta, 2);
      l_impimpuesto := fp_procesa_mto(l_numiva, 2);
      --
      -- RGUERRA 20210930, se calcula el total bruto
      l_numtotbruto    := l_numprimaneta + l_numiva;
      l_imptotbruto := fp_procesa_mto(l_numtotbruto, 2);
      --
      l_imprecargo  := fp_procesa_mto(l_numrecargo, 2);
      l_fechasys    := fp_desc_fecha(SYSDATE);
      l_ideaseg     := l_tdocum || ' ' || l_cdocum;
      -- l_comis       := l_prima * g_k_pct_comis;
      -- RGUERRA 20210810, se modifica segun requerimiento
      l_ivacomis    := round(l_comis * (13/100), 2);
      -- l_reten       := l_comis * g_k_pct_retencion;
      -- RGUERRA 20210810, se modifica segun requerimiento
      l_reten       := l_comis * (2/100);
      --
      l_comision    := fp_procesa_mto(l_comis,2);
      l_retencion   := fp_procesa_mto(l_reten,2);
      -- l_primatotal := fp_procesa_mto( (l_numprimaneta - nvl(l_comis,2) + nvl(l_reten,2) ), 2);
      -- RGUERRA 20210810, se modifica segun requerimiento            
      --                   
      l_primatotal := fp_procesa_mto( ( l_numprimaneta + 
                                        l_numiva - 
                                        ( nvl(l_comis,2) + nvl(l_ivacomis, 0) ) + 
                                        nvl(l_reten,2) 
                                      ), 
                                    2);                        
      --
      -- OBTIENE DATOS DE COMPAÃ?`IA
      f_datos_mapfrecr( pp_cod_cia       => g_cod_cia,
                        pp_cod_docum_cia => l_documcia,
                        pp_provincia_cia => l_provinciacia,
                        pp_domicilio_cia => l_domiciliocia,
                        pp_tlf_cia       => l_tlfcia,
                        pp_fax_cia       => l_faxcia,
                        pp_email_cia     => l_emailcia
                      );
      --
      g_linea := g_linea || g_titulo_listado || ';' || l_num_aviso || ';' ||
                 l_ideaseg || ';' || l_fechasys || ';' || l_nomaseg || ';' ||
                 l_direccion || ';' || l_numpoliza || ';' || l_ramo || ';' ||
                 l_nom_agente || ';' || l_simbolo_moneda || ';' ||
                 l_nombre_moneda || ';' || l_fech_efec || ';' ||
                 l_fech_vcto || ';' || l_concepto || ';' || l_impneta || ';' ||
                 l_impimpuesto || ';' || l_imprecargo || ';' ||
                 l_primatotal || ';' || l_documcia || ';' || l_provinciacia || ';' ||
                 l_domiciliocia || ';' || l_tlfcia || ';' || l_faxcia || ';' ||
                 l_comision || ';' || l_retencion || ';' || l_ivacomis ||';'||
                 l_imptotbruto|| ';'||l_polizagrupo||';'||l_nombre_asegurado||';';
      --
      g_linea := f_procesa_cad(g_linea);
      --
      trn_k_report.p_write_clob(g_clob_datos,
                                g_clob_cab_par,
                                g_linea,
                                FALSE);
      --
      EXCEPTION 
        WHEN OTHERS THEN
          dbms_output.put_line('Error pp_parametros: '|| sqlerrm );
          RAISE;
          --
    END pp_parametros;
    --
    -- PROCEDIMIENTO TEXTO
    PROCEDURE pp_texto IS
    BEGIN
      --
      g_clob_cab_dat := to_clob(g_txt_cab);
      --
      IF g_bool_write_form = TRUE THEN
        trn_k_report.p_write_form(l_ref_listado,
                                  k_cod_version,
                                  g_clob_cab_par,
                                  g_clob_cab_dat);
      END IF;
      --
    END pp_texto;
    --
    -- PROCEDIMIENTO DETALLE
    PROCEDURE pp_detalle IS
    BEGIN
      --
      g_pagina     := 1;
      g_secuencial := g_secuencial + 1;
      --
    END pp_detalle;
    --
    -- INICIO DE P_LISTA
  BEGIN
    --
    trn_k_global.asigna('MCA_TER_TAR', 'N');
    --
    g_cod_cia   := p_cod_cia;
    g_num_aviso := p_num_aviso;
    --
    g_pagina := 0;
    --
    g_fila := 0;
    --
    pp_parametros;
    --
    pp_texto;
    pp_detalle;
    --
    IF g_pagina = 0 THEN
      trn_k_global.asigna('MCA_TER_TAR', 'N');
      trn_k_global.asigna('COD_TER_ERRONEA', '20057');
    ELSE
      trn_k_global.asigna('MCA_TER_TAR', 'S');
      trn_k_report.p_close_report(g_id_fichero, g_clob_datos, 'param');
      --
    END IF;
    --
    trn_k_global.asigna('MCA_TER_TAR', trn.si);
    --
  EXCEPTION
    WHEN OTHERS THEN
      g_cod_error := -20002;
      g_msg_error := '<p_lista> ' || SQLERRM;
      trn_k_report.p_close_report(g_id_fichero, g_clob_datos, 'param');
      --
      raise_application_error(g_cod_error, g_msg_error);
      --
  END p_lista;
  --
  -- PROCEDIMIENTO P_LISTA CON_GLOBALES
  PROCEDURE p_lista_con_globales IS
  BEGIN
    p_lista(
              trn_k_global.ref_f_global('COD_CIA'),
              trn_k_global.devuelve('NUM_AVISO')
           );
    --
    trn_k_global.asigna('JBID_FICHERO', g_id_fichero);
    trn_k_global.asigna('MCA_TER_TAR', 'S');
    --
    COMMIT;
    --
    EXCEPTION
      WHEN OTHERS THEN
        --
        dbms_output.put_line('Error: '|| sqlerrm);
        trn_k_global.asigna('mca_ter_tar', 'N');
      --
  END p_lista_con_globales;
  --
END em_k_jrp_aviso_purdy_mcr;