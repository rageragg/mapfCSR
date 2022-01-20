create or replace package body dc_k_crea_terceros_web_mcr is
  --
  /**
  || Procedimientos y funciones para crear terceros via web
  */
  --
  /* -------------------- VERSION = 1.00 -------------------- */
  -- 09/03/2020
  -- ENIETO - CONSTRUCCION
  --
  /* -------------------- MODIFICACIONES -----------------------
  --
  */ -----------------------------------------------------------
  --
  --
  g_sessionid VARCHAR2(500);
  g_fec_actu  DATE := sysdate;
  g_cod_usr   VARCHAR2(20) := 'TRONBACH';
  --
  g_nom_archivo VARCHAR2(30) := 'dc_k_crea_terceros_web_mcr';

  g_modo VARCHAR2(1) := 'w';

  -- g_tab_x2000100_ter table_x2000100_ter := table_x2000100_ter();

  g_reg_x2000100_ter reg_x2000100_ter;

  p_cod_cia x2000100_ter.cod_cia%TYPE;

  p_tip_docum x2000100_ter.tip_docum%TYPE;

  p_cod_docum x2000100_ter.cod_docum%TYPE;

  -- p_dat_asegurado strarray;
  p_dat_asegurado strarray := strarray();

  --
  FUNCTION f_verifica(p_cod_cia   IN a1001331.cod_cia%TYPE,
                      p_tip_docum IN a1001331.tip_docum%TYPE,
                      p_cod_docum IN a1001331.cod_docum%TYPE) RETURN varchar2 IS
    --

    l_val_campo varchar2(1);
    --
  BEGIN
    --
    BEGIN
      --

      SELECT 'S'
        INTO l_val_campo
        FROM a1001331
       WHERE cod_cia = p_cod_cia
         AND tip_docum = p_tip_docum
         AND cod_docum = p_cod_docum;
      --
    EXCEPTION
      WHEN OTHERS THEN
        --
        l_val_campo := 'N';
        --
    END;
    --
    --
    RETURN l_val_campo;
    --
  END f_verifica;
  --
  --
  -- Busca valores del COD_CAMPO
  --
  FUNCTION f_busca_valor(p_cod_cia   IN a1001331.cod_cia%TYPE,
                         p_tip_docum IN a1001331.tip_docum%TYPE,
                         p_cod_docum IN a1001331.cod_docum%TYPE,
                         p_cod_campo IN x2000100_ter.cod_campo%TYPE )
    RETURN x2000100_ter.val_campo%TYPE IS
    --

    l_val_campo x2000100_ter.val_campo%TYPE;
    --
  BEGIN
    --
    BEGIN
      --

      SELECT val_campo
        INTO l_val_campo
        FROM x2000100_ter
       WHERE cod_cia = p_cod_cia
         AND tip_docum = p_tip_docum
         AND cod_docum = p_cod_docum
         AND cod_campo = p_cod_campo;

      --
    EXCEPTION
      WHEN OTHERS THEN
        --
        l_val_campo := NULL;
        --
    END;
    --
    --
    RETURN l_val_campo;
    --
  END f_busca_valor;
  --
  FUNCTION f_devuelve_errores(p_cod_cia     x2000100_ter.cod_cia%TYPE,
                              p_session_id  x2000100_ter.session_id%TYPE)

    RETURN gc_ref_cursor IS
    l_ref_cursor gc_ref_cursor;
    --
  BEGIN
    OPEN l_ref_cursor FOR
      SELECT cod_cia,
             session_id,
             tip_docum,
             cod_docum,
             txt_mensaje
        FROM x2000100_ter
       WHERE cod_cia = p_cod_cia
         AND session_id = p_session_id
         AND mca_valido = 'N';
    RETURN l_ref_cursor;

  END f_devuelve_errores;

  -- Verifica el estado de los datos temporales
  PROCEDURE p_x2000100_ter_lee(p_cod_cia a1001331.cod_cia%TYPE,
                               p_errores       OUT gc_ref_cursor) IS
    --
    l_cod_cia   x2000100_ter.cod_cia%TYPE;
    l_tip_docum x2000100_ter.tip_docum%TYPE;
    l_cod_docum x2000100_ter.cod_docum%TYPE;
    l_sessionid x2000100_ter.session_id%TYPE;
    --
    greg_a1001331 a1001331%ROWTYPE;
    greg_a1001399 a1001399%ROWTYPE;
    --
    CURSOR c_x2000100_ter IS
      SELECT distinct cod_cia, tip_docum, cod_docum, session_id
        FROM x2000100_ter
       WHERE cod_cia = p_cod_cia
         AND session_id = g_sessionid;

    --
  BEGIN
    --
    FOR reg IN c_x2000100_ter LOOP
      l_sessionid := reg.session_id;
      l_cod_cia   := reg.cod_cia;
      l_tip_docum := reg.tip_docum;
      l_cod_docum := reg.cod_docum;

      --
      greg_a1001331.cod_cia         := nvl(f_busca_valor(reg.cod_cia,
                                                         reg.tip_docum,
                                                         reg.cod_docum,
                                                         'COD_CIA'),
                                           1);

      greg_a1001331.tip_docum       := nvl(f_busca_valor(reg.cod_cia,
                                                         reg.tip_docum,
                                                         reg.cod_docum,
                                                         'TIP_DOCUM'),
                                           null);

      greg_a1001331.cod_docum       := nvl(f_busca_valor(reg.cod_cia,
                                                         reg.tip_docum,
                                                         reg.cod_docum,
                                                         'COD_DOCUM'),
                                           null);
      greg_a1001331.cod_act_tercero := 1;

      greg_a1001399.nom_tercero := nvl(f_busca_valor(reg.cod_cia,
                                                     reg.tip_docum,
                                                     reg.cod_docum,
                                                     'NOM1_TERCERO'),
                                       null);

      greg_a1001399.nom2_tercero := nvl(f_busca_valor(reg.cod_cia,
                                                      reg.tip_docum,
                                                      reg.cod_docum,
                                                      'NOM2_TERCERO'),
                                        null);

      greg_a1001399.APE1_TERCERO := nvl(f_busca_valor(reg.cod_cia,
                                                      reg.tip_docum,
                                                      reg.cod_docum,
                                                      'APE1_TERCERO'),
                                        null);

      greg_a1001399.APE2_TERCERO := nvl(f_busca_valor(reg.cod_cia,
                                                      reg.tip_docum,
                                                      reg.cod_docum,
                                                      'APE2_TERCERO'),
                                        null);

      greg_a1001331.fec_nacimiento := nvl(f_busca_valor(reg.cod_cia,
                                                        reg.tip_docum,
                                                        reg.cod_docum,
                                                        'FEC_NACIMIENTO'),
                                          null);

      greg_a1001331.mca_sexo := nvl(f_busca_valor(reg.cod_cia,
                                                  reg.tip_docum,
                                                  reg.cod_docum,
                                                  'MCA_SEXO'),
                                    null);

      greg_a1001331.cod_est_civil := nvl(f_busca_valor(reg.cod_cia,
                                                       reg.tip_docum,
                                                       reg.cod_docum,
                                                       'COD_EST_CIVIL'),
                                         null);

      greg_a1001331.cod_profesion := nvl(f_busca_valor(reg.cod_cia,
                                                       reg.tip_docum,
                                                       reg.cod_docum,
                                                       'COD_PROFESION'),
                                         1);

      greg_a1001331.cod_nacionalidad := nvl(f_busca_valor(reg.cod_cia,
                                                          reg.tip_docum,
                                                          reg.cod_docum,
                                                          'COD_NACIONALIDAD'),
                                            null);

      greg_a1001331.cod_pais := nvl(f_busca_valor(reg.cod_cia,
                                                  reg.tip_docum,
                                                  reg.cod_docum,
                                                  'COD_PAIS'),
                                    null);

      greg_a1001331.cod_estado := nvl(f_busca_valor(reg.cod_cia,
                                                    reg.tip_docum,
                                                    reg.cod_docum,
                                                    'COD_ESTADO'),
                                      null);

      greg_a1001331.cod_prov := nvl(f_busca_valor(reg.cod_cia,
                                                  reg.tip_docum,
                                                  reg.cod_docum,
                                                  'COD_PROV'),
                                    null);

      greg_a1001331.cod_localidad := nvl(f_busca_valor(reg.cod_cia,
                                                       reg.tip_docum,
                                                       reg.cod_docum,
                                                       'COD_LOCALIDAD'),
                                         null);

      greg_a1001331.tip_domicilio := nvl(f_busca_valor(reg.cod_cia,
                                                       reg.tip_docum,
                                                       reg.cod_docum,
                                                       'TIP_DOMICILIO'),
                                         null);

      greg_a1001331.nom_domicilio1 := nvl(f_busca_valor(reg.cod_cia,
                                                        reg.tip_docum,
                                                        reg.cod_docum,
                                                        'NOM_DOMICILIO1'),
                                          null);

      greg_a1001331.nom_domicilio2 := nvl(f_busca_valor(reg.cod_cia,
                                                        reg.tip_docum,
                                                        reg.cod_docum,
                                                        'NOM_DOMICILIO2'),
                                          null);

      greg_a1001331.nom_domicilio3 := nvl(f_busca_valor(reg.cod_cia,
                                                        reg.tip_docum,
                                                        reg.cod_docum,
                                                        'NOM_DOMICILIO3'),
                                          null);

      greg_a1001331.tlf_pais := nvl(f_busca_valor(reg.cod_cia,
                                                  reg.tip_docum,
                                                  reg.cod_docum,
                                                  'TLF_PAIS'),
                                    null);

      greg_a1001331.tlf_zona := nvl(f_busca_valor(reg.cod_cia,
                                                  reg.tip_docum,
                                                  reg.cod_docum,
                                                  'TLF_ZONA'),
                                    null);

      greg_a1001331.tlf_numero := nvl(f_busca_valor(reg.cod_cia,
                                                    reg.tip_docum,
                                                    reg.cod_docum,
                                                    'TLF_NUMERO'),
                                      null);

      greg_a1001331.tlf_numero := nvl(f_busca_valor(reg.cod_cia,
                                                    reg.tip_docum,
                                                    reg.cod_docum,
                                                    'TLF_NUMERO'),
                                      null);
      --
      /*  este no se quita  ORIGINAL
       greg_a1001331.TLF_MOVIL_COD_PAIS        :=   nvl(f_busca_valor(reg.cod_cia,
                                                    reg.tip_docum ,
                                                    reg.cod_docum ,
                                                    'TLF_MOVIL_COD_PAIS' ),null);

       greg_a1001331.TLF_MOVIL_COD_AREA        :=   nvl(f_busca_valor(reg.cod_cia,
                                                    reg.tip_docum ,
                                                    reg.cod_docum ,
                                                    'TLF_MOVIL_COD_AREA' ),null);

      */
      --

      greg_a1001331.tlf_movil := nvl(f_busca_valor(reg.cod_cia,
                                                   reg.tip_docum,
                                                   reg.cod_docum,
                                                   'TLF_MOVIL'),
                                     null);

      greg_a1001331.email := nvl(f_busca_valor(reg.cod_cia,
                                               reg.tip_docum,
                                               reg.cod_docum,
                                               'EMAIL'),
                                 null);

      --

      IF f_verifica(reg.cod_cia, reg.tip_docum, reg.cod_docum) = 'N' THEN
        p_graba_tercero(l_cod_cia,
                        l_sessionid,
                        greg_a1001331,
                        greg_a1001399);
      ELSE

        UPDATE X2000100_TER
           SET MCA_VALIDO = 'N',
               TXT_MENSAJE = 'Error el asegurado ya existe'
         WHERE cod_cia = l_cod_cia
           AND tip_docum = l_tip_docum
           AND cod_docum = l_cod_docum
           AND cod_campo = 'COD_CIA'
           AND session_id = g_sessionid;

        ptraza('pl_crea_terceros',
               'a',
               'Cod Campo ' || g_reg_x2000100_ter.cod_campo ||
               ' val_campo ' || g_reg_x2000100_ter.val_campo ||
               ' Tercero ya Existe ' || g_reg_x2000100_ter.val_campo);
      END IF;
      --

    END LOOP;
    --
    p_errores := f_devuelve_errores(l_cod_cia,
                                    l_sessionid);

    --
    delete x2000100_ter WHERE session_id = g_sessionid;
    --
    COMMIT;
    --

  EXCEPTION
    WHEN OTHERS THEN
      --
       ptraza('pl_crea_terceros', 'a', 'Error general en (p_x2000100_ter_lee) -> ' || sqlerrm);
      --
    --
  END p_x2000100_ter_lee;
  -- Tabla temporal de procesamiento
  PROCEDURE pl_guarda_datos_tercero(p_cod_cia     IN x2000100_ter.cod_cia%TYPE,
                                    p_tip_docum   IN x2000100_ter.tip_docum%TYPE,
                                    p_cod_docum   IN x2000100_ter.cod_docum%TYPE,
                                    p_json_riesgo IN VARCHAR2) IS
    l_fila number := 0;
  BEGIN
    --
    ptraza('pl_crea_terceros', 'a', 'En pl_guarda_datos_tercero ');
    g_table_key_values := dc_k_util_json_web.f_get_table_key_values(json(p_json_riesgo));

    --
    IF g_table_key_values.COUNT > 0 THEN
      --
      ptraza('pl_crea_terceros', 'a', '------');
      --
      FOR fila_objeto IN g_table_key_values.FIRST .. g_table_key_values.LAST LOOP
        --
        l_fila := l_fila + 1;
        --
        g_reg_x2000100_ter.cod_cia    := p_cod_cia;
        g_reg_x2000100_ter.tip_docum  := p_tip_docum;
        g_reg_x2000100_ter.cod_docum  := p_cod_docum;
        g_reg_x2000100_ter.cod_campo  := upper(g_table_key_values(fila_objeto)
                                               .key_values);
        g_reg_x2000100_ter.num_secu   := l_fila;
        g_reg_x2000100_ter.txt_campo  := NULL;
        g_reg_x2000100_ter.txt_campo1 := NULL;
        g_reg_x2000100_ter.txt_campo2 := NULL;
        --
        FOR fila IN g_table_key_values(fila_objeto).array_values.FIRST .. g_table_key_values(fila_objeto)
                                                                         .array_values.LAST LOOP
          --
          IF g_table_key_values(fila_objeto).array_values(fila) = 'NULL' THEN
            --
            g_reg_x2000100_ter.val_campo := NULL;
            --
          ELSE
            --
            g_reg_x2000100_ter.val_campo := g_table_key_values(fila_objeto)
                                           .array_values(fila);
            --
          END IF;
          --
          ptraza('pl_crea_terceros',
                 'a',
                 'Cod Campo ' || g_reg_x2000100_ter.cod_campo ||
                 ' val_campo ' || g_reg_x2000100_ter.val_campo);
          --
          BEGIN
            INSERT INTO x2000100_ter
              (COD_CIA,
               TIP_DOCUM,
               COD_DOCUM,
               COD_CAMPO,
               NUM_SECU,
               VAL_CAMPO,
               TXT_CAMPO,
               TXT_CAMPO1,
               TXT_CAMPO2,
               SESSION_ID,
               FEC_ACTU,
               COD_USR)
            VALUES
              (g_reg_x2000100_ter.cod_cia,
               g_reg_x2000100_ter.tip_docum,
               g_reg_x2000100_ter.cod_docum,
               g_reg_x2000100_ter.cod_campo,
               g_reg_x2000100_ter.num_secu,
               g_reg_x2000100_ter.val_campo,
               g_reg_x2000100_ter.val_campo,
               trn.NULO,
               trn.NULO,
               g_sessionid,
               g_fec_actu,
               g_cod_usr);
            --
          EXCEPTION
            WHEN OTHERS THEN
              ptraza('pl_crea_terceros', 'a', 'Error insert ' || sqlerrm);
          END;
          /*g_tab_x2000100_ter.EXTEND(1);
          g_tab_x2000100_ter(g_tab_x2000100_ter.LAST) := g_reg_x2000100_ter;*/
        --
        END LOOP;
        --
      END LOOP;
      --
    END IF;
    --
  EXCEPTION
    WHEN OTHERS THEN
      ptraza('pl_crea_terceros',
             'a',
             'Error pl_guarda_datos_tercero ' || sqlerrm);
  END pl_guarda_datos_tercero;
  --
  PROCEDURE pl_crea_terceros(p_dat_asegurado IN strarray,
                             p_errores       OUT gc_ref_cursor) IS

  BEGIN
    --
    ptraza('pl_crea_terceros', 'w', 'INICIO: '|| g_fec_actu );
    ptraza('pl_crea_terceros',
           'a',
           'p_dat_asegurado.COUNT ' || p_dat_asegurado.COUNT);

    select userenv('sessionid') into g_sessionid from dual;

    IF p_dat_asegurado.COUNT > 0 THEN
      --
      ptraza('pl_crea_terceros', 'a', 'Se encontraron Asegurado(s)');
      FOR l_fila_aseg IN p_dat_asegurado.FIRST .. p_dat_asegurado.LAST LOOP
        --
        ptraza('pl_crea_terceros', 'a', 'dc_k_util_json_web');
        BEGIN
        dc_k_util_json_web.p_lee(json(p_dat_asegurado(l_fila_aseg)));
        EXCEPTION
          WHEN OTHERS THEN
            ptraza('pl_crea_terceros', 'a', 'Error dc_k_util_json_web '||SQLERRM);
        END;
        --
        ptraza('pl_crea_terceros', 'a', '2');
        p_cod_cia   := dc_f_varchar_to_number(dc_k_util_json_web.f_get_value('COD_CIA'));
        p_tip_docum := dc_k_util_json_web.f_get_value('TIP_DOCUM');
        p_cod_docum := dc_f_varchar_to_number(dc_k_util_json_web.f_get_value('COD_DOCUM'));
        --
        ptraza('pl_crea_terceros',
               'a',
               'COD_CIA ' || p_cod_cia || ' p_tip_docum ' || p_tip_docum ||
               ' p_cod_docum ' || p_cod_docum);
        --
        IF (p_tip_docum IS NOT NULL AND p_cod_docum IS NOT NULL) THEN
          ptraza('pl_crea_terceros', 'a', 'Se procede a Guardar los datos de Terceros');
          --
          pl_guarda_datos_tercero(p_cod_cia     => p_cod_cia,
                                  p_tip_docum   => p_tip_docum,
                                  p_cod_docum   => p_cod_docum,
                                  p_json_riesgo => p_dat_asegurado(l_fila_aseg));

          --
        ELSE
          ptraza('pl_crea_terceros', 'a', 'No hay datos tipo documento es NULO o codigo del Documento es NULO');
        END IF;
      END LOOP;

    END IF;
    --
    COMMIT;
    --
    p_x2000100_ter_lee(p_cod_cia, p_errores );

    if p_errores%ISOPEN then
      ptraza('pl_crea_terceros', 'a', 'El cursor de referencia esta Abierto');
    else
      ptraza('pl_crea_terceros', 'a', 'El cursor de referencia esta Cerrado');
    end if;

    --
    ptraza('pl_crea_terceros', 'a', 'Fin pl_crea_terceros');
  EXCEPTION
    WHEN OTHERS THEN
      ptraza('pl_crea_terceros', 'a', 'Error general ' || sqlerrm);
  END pl_crea_terceros;
  -- Terceros (Tomadores y/o asegurados)
  PROCEDURE p_graba_reg_a1001331(p_reg_in IN a1001331%ROWTYPE) IS
    --
    greg_a1001331 a1001331%ROWTYPE;
    --
  BEGIN
    --
    BEGIN
      --
      ptraza(g_nom_archivo, g_modo, 'Antes de insertar');
      --
      INSERT INTO a1001331
        (cod_cia,
         tip_docum,
         cod_docum,
         cod_act_tercero,
         cod_nacionalidad,
         tip_act_economica,
         fec_nacimiento,
         cod_ocupacion,
         cod_profesion,
         cod_est_civil,
         mca_sexo,
         cod_idioma,
         cod_usr,
         cod_pais,
         cod_estado,
         cod_prov,
         cod_localidad,
         nom_localidad,
         tip_domicilio,
         nom_domicilio1,
         nom_domicilio2,
         nom_domicilio3,
         cod_postal,
         num_apartado,
         tlf_pais,
         tlf_zona,
         tlf_numero,
         fax_numero,
         email,
         tlf_movil,
         num_busca,
         cod_pais_com,
         cod_estado_com,
         cod_prov_com,
         cod_localidad_com,
         nom_localidad_com,
         tip_domicilio_com,
         nom_domicilio1_com,
         nom_domicilio2_com,
         nom_domicilio3_com,
         cod_postal_com,
         num_apartado_com,
         tlf_pais_com,
         tlf_zona_com,
         tlf_numero_com,
         fax_numero_com,
         email_com,
         tip_etiqueta,
         txt_etiqueta1,
         txt_etiqueta2,
         txt_etiqueta3,
         txt_etiqueta4,
         txt_etiqueta5,
         txt_email,
         cod_pais_etiqueta,
         cod_estado_etiqueta,
         cod_prov_etiqueta,
         cod_postal_etiqueta,
         num_apartado_etiqueta,
         fec_actu,
         cod_localidad_etiqueta,
         nom_localidad_etiqueta,
         cod_entidad,
         cod_oficina,
         cta_cte,
         cta_dc,
         tip_tarjeta,
         cod_tarjeta,
         num_tarjeta,
         fec_vcto_tarjeta,
         txt_aux6,
         txt_aux7,
         txt_aux8)
      VALUES
        (p_reg_in.cod_cia,
         p_reg_in.tip_docum,
         p_reg_in.cod_docum,
         p_reg_in.cod_act_tercero,
         p_reg_in.cod_nacionalidad,
         p_reg_in.tip_act_economica,
         p_reg_in.fec_nacimiento,
         p_reg_in.cod_ocupacion,
         p_reg_in.cod_profesion,
         p_reg_in.cod_est_civil,
         p_reg_in.mca_sexo,
         p_reg_in.cod_idioma,
         p_reg_in.cod_usr,
         p_reg_in.cod_pais,
         p_reg_in.cod_estado,
         p_reg_in.cod_prov,
         p_reg_in.cod_localidad,
         p_reg_in.nom_localidad,
         p_reg_in.tip_domicilio,
         p_reg_in.nom_domicilio1,
         p_reg_in.nom_domicilio2,
         p_reg_in.nom_domicilio3,
         p_reg_in.cod_postal,
         p_reg_in.num_apartado,
         p_reg_in.tlf_pais,
         p_reg_in.tlf_zona,
         p_reg_in.tlf_numero,
         p_reg_in.fax_numero,
         p_reg_in.email,
         p_reg_in.tlf_movil,
         p_reg_in.num_busca,
         p_reg_in.cod_pais_com,
         p_reg_in.cod_estado_com,
         p_reg_in.cod_prov_com,
         p_reg_in.cod_localidad_com,
         p_reg_in.nom_localidad_com,
         p_reg_in.tip_domicilio_com,
         p_reg_in.nom_domicilio1_com,
         p_reg_in.nom_domicilio2_com,
         p_reg_in.nom_domicilio3_com,
         p_reg_in.cod_postal_com,
         p_reg_in.num_apartado_com,
         p_reg_in.tlf_pais_com,
         p_reg_in.tlf_zona_com,
         p_reg_in.tlf_numero_com,
         p_reg_in.fax_numero_com,
         p_reg_in.email_com,
         p_reg_in.tip_etiqueta,
         p_reg_in.txt_etiqueta1,
         p_reg_in.txt_etiqueta2,
         p_reg_in.txt_etiqueta3,
         p_reg_in.txt_etiqueta4,
         p_reg_in.txt_etiqueta5,
         p_reg_in.txt_email,
         p_reg_in.cod_pais_etiqueta,
         p_reg_in.cod_estado_etiqueta,
         p_reg_in.cod_prov_etiqueta,
         p_reg_in.cod_postal_etiqueta,
         p_reg_in.num_apartado_etiqueta,
         p_reg_in.fec_actu,
         p_reg_in.cod_localidad_etiqueta,
         p_reg_in.nom_localidad_etiqueta,
         p_reg_in.cod_entidad,
         p_reg_in.cod_oficina,
         p_reg_in.cta_cte,
         p_reg_in.cta_dc,
         p_reg_in.tip_tarjeta,
         p_reg_in.cod_tarjeta,
         p_reg_in.num_tarjeta,
         p_reg_in.fec_vcto_tarjeta,
         p_reg_in.txt_aux6,
         p_reg_in.txt_aux7,
         p_reg_in.txt_aux8);
      --
      ptraza(g_nom_archivo, g_modo, 'Despues de insertar');
      --
    EXCEPTION
      --
      WHEN dup_val_on_index THEN
        --
        ptraza(g_nom_archivo, g_modo, 'antes de dc_k_a1001331.p_lee');
        --
        dc_k_a1001331.p_lee(p_reg_in.cod_cia,
                            p_reg_in.tip_docum,
                            p_reg_in.cod_docum);
        --
        greg_a1001331 := dc_k_a1001331.f_devuelve_reg;
        --
        ptraza(g_nom_archivo, g_modo, 'antes de actualizar');
        --
        UPDATE a1001331
           SET cod_cia                = nvl(greg_a1001331.cod_cia,
                                            p_reg_in.cod_cia),
               tip_docum              = nvl(greg_a1001331.tip_docum,
                                            p_reg_in.tip_docum),
               cod_docum              = nvl(greg_a1001331.cod_docum,
                                            p_reg_in.cod_docum),
               cod_act_tercero        = nvl(greg_a1001331.cod_act_tercero,
                                            p_reg_in.cod_act_tercero),
               cod_nacionalidad       = nvl(greg_a1001331.cod_nacionalidad,
                                            p_reg_in.cod_nacionalidad),
               tip_act_economica      = nvl(greg_a1001331.tip_act_economica,
                                            p_reg_in.tip_act_economica),
               fec_nacimiento         = nvl(greg_a1001331.fec_nacimiento,
                                            p_reg_in.fec_nacimiento),
               cod_ocupacion          = nvl(greg_a1001331.cod_ocupacion,
                                            p_reg_in.cod_ocupacion),
               cod_profesion          = nvl(greg_a1001331.cod_profesion,
                                            p_reg_in.cod_profesion),
               cod_est_civil          = nvl(greg_a1001331.cod_est_civil,
                                            p_reg_in.cod_est_civil),
               mca_sexo               = nvl(greg_a1001331.mca_sexo,
                                            p_reg_in.mca_sexo),
               cod_idioma             = nvl(greg_a1001331.cod_idioma,
                                            p_reg_in.cod_idioma),
               cod_usr                = nvl(greg_a1001331.cod_usr,
                                            p_reg_in.cod_usr),
               cod_pais               = nvl(p_reg_in.cod_pais,
                                            greg_a1001331.cod_pais),
               cod_estado             = nvl(p_reg_in.cod_estado,
                                            greg_a1001331.cod_estado),
               cod_prov               = nvl(p_reg_in.cod_prov,
                                            greg_a1001331.cod_prov),
               cod_localidad          = nvl(p_reg_in.cod_localidad,
                                            greg_a1001331.cod_localidad),
               nom_localidad          = nvl(p_reg_in.nom_localidad,
                                            greg_a1001331.nom_localidad),
               tip_domicilio          = nvl(p_reg_in.tip_domicilio,
                                            greg_a1001331.tip_domicilio),
               nom_domicilio1         = nvl(p_reg_in.nom_domicilio1,
                                            greg_a1001331.nom_domicilio1),
               nom_domicilio2         = nvl(p_reg_in.nom_domicilio2,
                                            greg_a1001331.nom_domicilio2),
               nom_domicilio3         = nvl(p_reg_in.nom_domicilio3,
                                            greg_a1001331.nom_domicilio3),
               cod_postal             = nvl(p_reg_in.cod_postal,
                                            greg_a1001331.cod_postal),
               num_apartado           = nvl(p_reg_in.num_apartado,
                                            greg_a1001331.num_apartado),
               tlf_pais               = nvl(p_reg_in.tlf_pais,
                                            greg_a1001331.tlf_pais),
               tlf_zona               = nvl(p_reg_in.tlf_zona,
                                            greg_a1001331.tlf_zona),
               tlf_numero             = nvl(p_reg_in.tlf_numero,
                                            greg_a1001331.tlf_numero),
               fax_numero             = nvl(p_reg_in.fax_numero,
                                            greg_a1001331.fax_numero),
               email                  = nvl(p_reg_in.email,
                                            greg_a1001331.email),
               tlf_movil              = nvl(p_reg_in.tlf_movil,
                                            greg_a1001331.tlf_movil),
               num_busca              = nvl(p_reg_in.num_busca,
                                            greg_a1001331.num_busca),
               tip_cargo              = nvl(p_reg_in.tip_cargo,
                                            greg_a1001331.tip_cargo),
               nom_contacto           = nvl(p_reg_in.nom_contacto,
                                            greg_a1001331.nom_contacto),
               cod_pais_com           = nvl(p_reg_in.cod_pais_com,
                                            greg_a1001331.cod_pais_com),
               cod_estado_com         = nvl(p_reg_in.cod_estado_com,
                                            greg_a1001331.cod_estado_com),
               cod_prov_com           = nvl(p_reg_in.cod_prov_com,
                                            greg_a1001331.cod_prov_com),
               cod_localidad_com      = nvl(p_reg_in.cod_localidad_com,
                                            greg_a1001331.cod_localidad_com),
               nom_localidad_com      = nvl(p_reg_in.nom_localidad_com,
                                            greg_a1001331.nom_localidad_com),
               tip_domicilio_com      = nvl(p_reg_in.tip_domicilio_com,
                                            greg_a1001331.tip_domicilio_com),
               nom_domicilio1_com     = nvl(p_reg_in.nom_domicilio1_com,
                                            greg_a1001331.nom_domicilio1_com),
               nom_domicilio2_com     = nvl(p_reg_in.nom_domicilio2_com,
                                            greg_a1001331.nom_domicilio2_com),
               nom_domicilio3_com     = nvl(p_reg_in.nom_domicilio3_com,
                                            greg_a1001331.nom_domicilio3_com),
               cod_postal_com         = nvl(p_reg_in.cod_postal_com,
                                            greg_a1001331.cod_postal_com),
               num_apartado_com       = nvl(p_reg_in.num_apartado_com,
                                            greg_a1001331.num_apartado_com),
               tlf_pais_com           = nvl(p_reg_in.tlf_pais_com,
                                            greg_a1001331.tlf_pais_com),
               tlf_zona_com           = nvl(p_reg_in.tlf_zona_com,
                                            greg_a1001331.tlf_zona_com),
               tlf_numero_com         = nvl(p_reg_in.tlf_numero_com,
                                            greg_a1001331.tlf_numero_com),
               fax_numero_com         = nvl(p_reg_in.fax_numero_com,
                                            greg_a1001331.fax_numero_com),
               email_com              = nvl(p_reg_in.email_com,
                                            greg_a1001331.email_com),
               tip_etiqueta           = nvl(p_reg_in.tip_etiqueta,
                                            greg_a1001331.tip_etiqueta),
               txt_etiqueta1          = nvl(p_reg_in.txt_etiqueta1,
                                            greg_a1001331.txt_etiqueta1),
               txt_etiqueta2          = nvl(p_reg_in.txt_etiqueta2,
                                            greg_a1001331.txt_etiqueta2),
               txt_etiqueta3          = nvl(p_reg_in.txt_etiqueta3,
                                            greg_a1001331.txt_etiqueta3),
               txt_etiqueta4          = nvl(p_reg_in.txt_etiqueta4,
                                            greg_a1001331.txt_etiqueta4),
               txt_etiqueta5          = nvl(p_reg_in.txt_etiqueta5,
                                            greg_a1001331.txt_etiqueta5),
               txt_email              = nvl(p_reg_in.txt_email,
                                            greg_a1001331.txt_email),
               cod_pais_etiqueta      = nvl(p_reg_in.cod_pais_etiqueta,
                                            greg_a1001331.cod_pais_etiqueta),
               cod_estado_etiqueta    = nvl(p_reg_in.cod_estado_etiqueta,
                                            greg_a1001331.cod_estado_etiqueta),
               cod_prov_etiqueta      = nvl(p_reg_in.cod_prov_etiqueta,
                                            greg_a1001331.cod_prov_etiqueta),
               cod_postal_etiqueta    = nvl(p_reg_in.cod_postal_etiqueta,
                                            greg_a1001331.cod_postal_etiqueta),
               num_apartado_etiqueta  = nvl(p_reg_in.num_apartado_etiqueta,
                                            greg_a1001331.num_apartado_etiqueta),
               fec_actu               = nvl(p_reg_in.fec_actu,
                                            greg_a1001331.fec_actu),
               cod_localidad_etiqueta = nvl(p_reg_in.cod_localidad_etiqueta,
                                            greg_a1001331.cod_localidad_etiqueta),
               nom_localidad_etiqueta = nvl(p_reg_in.nom_localidad_etiqueta,
                                            greg_a1001331.nom_localidad_etiqueta),
               cod_entidad            = nvl(p_reg_in.cod_entidad,
                                            greg_a1001331.cod_entidad),
               cod_oficina            = nvl(p_reg_in.cod_oficina,
                                            greg_a1001331.cod_oficina),
               cta_cte                = nvl(p_reg_in.cta_cte,
                                            greg_a1001331.cta_cte),
               cta_dc                 = nvl(p_reg_in.cta_dc,
                                            greg_a1001331.cta_dc),
               tip_tarjeta            = nvl(p_reg_in.tip_tarjeta,
                                            greg_a1001331.tip_tarjeta),
               cod_tarjeta            = nvl(p_reg_in.cod_tarjeta,
                                            greg_a1001331.cod_tarjeta),
               num_tarjeta            = nvl(p_reg_in.num_tarjeta,
                                            greg_a1001331.num_tarjeta),
               fec_vcto_tarjeta       = nvl(p_reg_in.fec_vcto_tarjeta,
                                            greg_a1001331.fec_vcto_tarjeta),
               txt_aux6               = nvl(p_reg_in.txt_aux6,
                                            greg_a1001331.txt_aux6),
               txt_aux7               = nvl(p_reg_in.txt_aux7,
                                            greg_a1001331.txt_aux7),
               txt_aux8               = nvl(p_reg_in.txt_aux8,
                                            greg_a1001331.txt_aux8)
        --
         WHERE cod_cia = p_reg_in.cod_cia
           AND tip_docum = p_reg_in.tip_docum
           AND cod_docum = p_reg_in.cod_docum;
        --
        ptraza(g_nom_archivo, g_modo, 'despues de actualizar');
        --
      WHEN OTHERS THEN
        --
        ptraza(g_nom_archivo,
               g_modo,
               'Error en INSERT INTO a1001331: ' || SQLERRM);
        --
    END;
    --
    ptraza(g_nom_archivo, g_modo, 'Fin p_graba_reg_a1001331');
    --
  END p_graba_reg_a1001331;
  -- Actividades de Terceros
  PROCEDURE p_graba_a1001390(p_cod_cia   a1001390.cod_cia%TYPE,
                             p_tip_docum a1001390.tip_docum%TYPE,
                             p_cod_docum a1001390.cod_docum%TYPE,
                             p_cod_usr   a1001390.cod_usr%TYPE) IS
  BEGIN
    --
    INSERT INTO a1001390
      (cod_cia, tip_docum, cod_docum, cod_act_tercero, cod_usr, fec_actu)
    VALUES
      (p_cod_cia, p_tip_docum, p_cod_docum, 1, p_cod_usr, g_fec_actu);
    --
  EXCEPTION
    WHEN dup_val_on_index THEN
      --
      NULL;
      --
  END p_graba_a1001390;
  -- Datos Fijos del Tercero
  PROCEDURE p_graba_a1001399(p_cod_cia      a1001399.cod_cia%TYPE,
                             p_tip_docum    a1001399.tip_docum%TYPE,
                             p_cod_docum    a1001399.cod_docum%TYPE,
                             p_nom_tercero  a1001399.nom_tercero%TYPE,
                             p_ape1_tercero a1001399.ape1_tercero%TYPE,
                             p_ape2_tercero a1001399.ape2_tercero%TYPE,
                             p_mca_fisico   a1001399.mca_fisico%TYPE,
                             p_cod_usr      a1001399.cod_usr%TYPE) IS
  BEGIN
    --
    INSERT INTO a1001399
      (cod_cia,
       tip_docum,
       cod_docum,
       mca_fisico,
       ape1_tercero,
       ape2_tercero,
       nom_tercero,
       cod_usr,
       fec_actu)
    VALUES
      (p_cod_cia,
       p_tip_docum,
       p_cod_docum,
       p_mca_fisico,
       p_ape1_tercero,
       p_ape2_tercero,
       p_nom_tercero,
       p_cod_usr,
       g_fec_actu);
    --
  EXCEPTION
    WHEN dup_val_on_index THEN
      --
      NULL;
      --
  END p_graba_a1001399;
  -- Transferir de la temporal a datos fijos de terceros
  PROCEDURE p_graba_tercero(p_cod_cia      IN a1001331.cod_cia%TYPE,
                            p_session_id   IN x2000100_ter.session_id%TYPE,
                            p_reg_a1001331 IN a1001331%ROWTYPE,
                            p_reg_a1001399 IN a1001399%ROWTYPE) IS
    --
    l_reg_a1001331     a1001331%ROWTYPE;
    l_reg_a1001399     a1001399%ROWTYPE;
    l_reg_x2000100_ter x2000100_ter%ROWTYPE;
    --
  BEGIN
    --
    g_modo := 'w';
    ptraza(g_nom_archivo,
           g_modo,
           'Inicio << p_graba_tercero >> ' ||
           to_char(SYSDATE, 'dd-mm-yyyy hh_mi_ss'));
    g_modo := 'a';
    --
    l_reg_a1001331 := p_reg_a1001331;
    l_reg_a1001399 := p_reg_a1001399;
    --
    l_reg_a1001399.nom_tercero  := TRIM(upper(substr(p_reg_a1001399.nom_tercero,
                                                     1,
                                                     80)));
    l_reg_a1001399.ape1_tercero := TRIM(upper(substr(p_reg_a1001399.ape1_tercero,
                                                     1,
                                                     30)));
    l_reg_a1001399.ape2_tercero := TRIM(upper(substr(p_reg_a1001399.ape2_tercero,
                                                     1,
                                                     30)));
    --
    l_reg_a1001331.nom_domicilio1 := TRIM(upper(substr(p_reg_a1001331.nom_domicilio1,
                                                       1,
                                                       40)));
    l_reg_a1001331.nom_domicilio2 := TRIM(upper(substr(p_reg_a1001331.nom_domicilio2,
                                                       1,
                                                       40)));
    l_reg_a1001331.nom_domicilio3 := TRIM(upper(substr(p_reg_a1001331.nom_domicilio3,
                                                       1,
                                                       40)));
    --
    l_reg_a1001331.txt_etiqueta4      := TRIM(upper(p_reg_a1001331.txt_etiqueta4));
    l_reg_a1001331.txt_etiqueta5      := TRIM(upper(p_reg_a1001331.txt_etiqueta5));
    l_reg_a1001331.nom_contacto       := TRIM(upper(p_reg_a1001331.nom_contacto));
    l_reg_a1001331.nom_domicilio1_com := l_reg_a1001331.nom_domicilio1;
    l_reg_a1001331.nom_domicilio2_com := l_reg_a1001331.nom_domicilio2;
    l_reg_a1001331.nom_domicilio3_com := l_reg_a1001331.nom_domicilio3;
    l_reg_a1001331.txt_etiqueta1      := l_reg_a1001331.nom_domicilio1;
    l_reg_a1001331.txt_etiqueta2      := l_reg_a1001331.nom_domicilio2;
    l_reg_a1001331.txt_etiqueta3      := l_reg_a1001331.nom_domicilio3;
    l_reg_a1001331.cod_cia            := p_cod_cia;
    l_reg_a1001331.fec_actu           := g_fec_actu;
    --
    -- INSERTA EN LA TABLA a1001390
    --
    ptraza(g_nom_archivo, g_modo, 'INSERTA EN LA TABLA a1001390');
    --
    p_graba_a1001390(p_cod_cia,
                     l_reg_a1001331.tip_docum,
                     l_reg_a1001331.cod_docum,
                     'TRONBACH');
    --
    -- INSERTA EN LA TABLA a1001399
    --
    ptraza(g_nom_archivo, g_modo, 'INSERTA EN LA TABLA a1001399');
    --
    p_graba_a1001399(p_cod_cia,
                     l_reg_a1001331.tip_docum,
                     l_reg_a1001331.cod_docum,
                     l_reg_a1001399.nom_tercero,
                     l_reg_a1001399.ape1_tercero,
                     l_reg_a1001399.ape2_tercero,
                     l_reg_a1001399.mca_fisico,
                     'TRONBACH');
    --
    -- INSERTA EN LA TABLA A1001331
    --
    ptraza(g_nom_archivo, g_modo, 'INSERTA EN LA TABLA A1001331');
    --
    p_graba_reg_a1001331(l_reg_a1001331);
    --
    ptraza(g_nom_archivo,
           g_modo,
           'Fin << p_graba_tercero >> ' ||
           to_char(SYSDATE, 'dd-mm-yyyy hh_mi_ss'));
    --
  END p_graba_tercero;

END dc_k_crea_terceros_web_mcr;
