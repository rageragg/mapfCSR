CREATE OR REPLACE PACKAGE BODY gc_k_cobro_aviso_bco_nacional IS 
    --
    g_cod_usr            x2000030.cod_usr %TYPE     := trn_k_global.cod_usr;
    g_cod_cia            a5021691_mcr.cod_cia%TYPE;
    g_cod_ramo           a2000030.cod_ramo%TYPE;
    g_id_proceso         a5021691_mcr.id_proceso%TYPE;
    g_nombre_archivo     VARCHAR2(60);
    g_file               utl_file.file_type;
    g_line               VARCHAR2(1024);
    g_file_is_open       BOOLEAN := FALSE;
    --
    g_num_poliza         a2000030.num_poliza%TYPE;
    g_num_spto           a2000030.num_spto%TYPE;
    g_mca_poliza_anulada a2000030.mca_poliza_anulada%TYPE;
    g_num_poliza_grupo   a2000030.num_poliza_grupo%TYPE;
    g_cod_agt            a2000030.cod_agt%TYPE;
    g_num_tarjeta        VARCHAR2(128);
    g_cod_docum_pago     VARCHAR2(128);
    g_tip_docum_pago     a1001331.tip_docum%TYPE;
    g_cod_docum_tomador  a2000030.cod_docum%TYPE;
    g_tip_docum_tomador  a2000030.tip_docum%TYPE;
    g_num_recibo         a2990700.num_recibo%TYPE;
    g_imp_recibo         a2990700.imp_recibo%TYPE;
    g_nombre_apellido    VARCHAR2(128);
    g_monto_pago         VARCHAR2(128);
    g_moneda             VARCHAR2(128);
    g_fecha_pago         VARCHAR2(128);
    --
    g_lista_datos        gc_k_cobro_aviso_bco_nacional.tab_lista_datos := gc_k_cobro_aviso_bco_nacional.tab_lista_datos();
    g_registo_dato       gc_k_cobro_aviso_bco_nacional.typ_rec_formato;
    g_tab_polizas_grupo  gc_k_cobro_aviso_bco_nacional.tab_poliza_grupo;
    --
    g_fec_proceso        a5021691_mcr.fec_proceso%TYPE := trunc(sysdate);
    g_cant_registros     NUMBER := 1;
    --
    g_msg_error          VARCHAR2(4000);
    g_cod_error          NUMBER;
    e_iniciar_proceso    EXCEPTION;
    e_fin_proceso        EXCEPTION;
    e_tratar_line        EXCEPTION;
    e_procesar_archivo   EXCEPTION;
    e_archivo_procesado  EXCEPTION;
    e_registro_aviso     EXCEPTION;
    e_manejo_archivo     EXCEPTION;
    e_manejo_argumento   EXCEPTION;
    --
    -- inicializa polizas grupos que solo son permitidas
    PROCEDURE p_inicia_tabla_poliza_grupo IS 
    BEGIN 
        --
        g_tab_polizas_grupo(1) := '2302000089200';
        g_tab_polizas_grupo(2) := '2302000089201';
        g_tab_polizas_grupo(3) := '2302000089202';
        g_tab_polizas_grupo(4) := '2302000099103';
        --
    END p_inicia_tabla_poliza_grupo;
    --
    -- verifica poliza grupo
    FUNCTION f_verifica_poliza_grupo( p_poliza_grupo VARCHAR2 ) RETURN BOOLEAN IS 
        --
        l_ok    BOOLEAN := FALSE;
    BEGIN 
        --
        -- Se modifica segun observaciones de Michael Montero en reunion de seguimiento, 13/01/2022
        -- FOR i IN 1..g_tab_polizas_grupo.count LOOP 
        --     IF g_tab_polizas_grupo(i) = p_poliza_grupo THEN 
        --         l_ok := TRUE;
        --         EXIT;
        --     END IF;
        -- END LOOP;
        --
        -- RETURN l_ok;
        --
        RETURN TRUE;
        --
    END f_verifica_poliza_grupo;
    --
    -- funcion que retorna numero con formato
    FUNCTION fp_procesa_mto( p_num NUMBER, p_dec NUMBER := 0 ) RETURN VARCHAR2 AS
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
        -- Fin versiÃ??Ã?Â³n 2.00
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
    FUNCTION fp_desc_fecha( p_fecha DATE ) RETURN VARCHAR2 IS
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
    -- funcion que retorna nombre de la moneda 
    FUNCTION CF_MonedaFormula( p_cod_mon a1000400.cod_mon%TYPE ) RETURN VARCHAR2 IS
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
    -- FUNCION QUE RETORNA NOMBRE DEL RAMO
    FUNCTION CF_NomRamoFormula( p_codramo a1001800.cod_ramo%TYPE ) RETURN CHAR IS
        --
        l_nom_ramo VARCHAR2(40);
        --
    BEGIN
        --
        SELECT nom_ramo
          INTO l_nom_ramo
          FROM a1001800
         WHERE cod_ramo = p_codramo;
        -- 
        RETURN l_nom_ramo;
        --
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
                l_nom_ramo := NULL;
        --
    END CF_NomRamoFormula;
    --
    -- solo formatea el mensaje de error
    PROCEDURE p_devuelve_error( p_msg VARCHAR2 ) IS 
    BEGIN 
        --
        g_msg_error := '<'||p_msg||'> '|| SQLERRM;
        --
    END p_devuelve_error;
    --
    -- manejo de tabla plsql se agrega a la lista
    PROCEDURE p_agregar_a_lista IS 
    BEGIN 
        --
        g_lista_datos.extend;
        g_lista_datos(g_lista_datos.count) := g_registo_dato;
        --
    END p_agregar_a_lista;
    --
    -- id del proceso
    PROCEDURE p_id_proceso IS
    BEGIN
        --
        IF g_id_proceso IS NULL THEN
            --
            SELECT SEQ_A5021691_MCR.NEXTVAL INTO g_id_proceso from DUAL;
            --
        END IF;
        --    
    END p_id_proceso;
    --
    -- inicio de proceso
    PROCEDURE p_inicio_proceso IS 
    BEGIN 
        --
        trn_k_global.asigna('MCA_TER_TAR', 'N');
        g_cant_registros := 1;
        g_lista_datos.delete;
        p_inicia_tabla_poliza_grupo;
        --
        g_cod_cia        := trn_k_global.devuelve('JBCOD_CIA');
        g_cod_ramo       := trn_k_global.ref_f_global('JBCOD_RAMO');
        g_id_proceso     := trn_k_global.ref_f_global('JBID_PROCESO');
        g_nombre_archivo := trn_k_global.ref_f_global('JBNOMBRE_ARCHIVO');
        --
        trn_p_ejecuta_sentencia('ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''');
        trn_p_ejecuta_sentencia('ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ''.,''');
        --
        g_file_is_open := FALSE;
        g_file := utl_file.fopen('AP_LIS', g_nombre_archivo, 'r' );
        g_file_is_open := TRUE;
        --
        p_id_proceso;
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                trn_k_global.asigna('MCA_TER_TAR', 'S');
                g_cod_error := -20001;
                p_devuelve_error( p_msg => 'p_inicio_proceso');
                RAISE e_iniciar_proceso;
                --
    END p_inicio_proceso;
    --
    -- fin de proceso
    PROCEDURE p_fin_proceso IS 
        --
        l_listado VARCHAR2(256);
        --
    BEGIN 
        -- 
        trn_k_global.asigna('MCA_TER_TAR', 'S');
        IF g_file_is_open THEN
            utl_file.fclose(g_file);
            g_file_is_open := FALSE;
        END IF;    
        --
        l_listado := trn_k_global.ref_f_global('JBNOM_LISTADO');
        IF l_listado IS NOT NULL THEN 
            trn_k_global.asigna('TXT_TAREA', 'Se ha finalizado la Carga del Archivo: ' || 
                                g_nombre_archivo || chr(13) || chr(10) ||
                                'Listado: ' || l_listado 
            );
        ELSE
            trn_k_global.asigna('TXT_TAREA', 'Se ha finalizado la Carga del Archivo: ' || g_nombre_archivo );
        END IF;    
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                g_cod_error := -20002;
                p_devuelve_error( p_msg => 'p_fin_proceso');
                RAISE e_fin_proceso;
                --
    END p_fin_proceso;
    --
    -- se verifica que el archivo no sea procesado nuevamente
    FUNCTION f_archivo_procesado RETURN BOOLEAN IS 
        --
        l_mca_existe        CHAR(01);
        l_existe_archivo    BOOLEAN;
        --
        CURSOR c_archivo IS
            SELECT 'S'
              FROM a5021691_mcr
             WHERE cod_cia       = g_cod_cia
              AND nombre_archivo = g_nombre_archivo;
    BEGIN 
        --
        OPEN c_archivo;
        FETCH c_archivo INTO l_mca_existe;
        l_existe_archivo := c_archivo%FOUND;
        CLOSE c_archivo;
        --
        RETURN l_existe_archivo;
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                RETURN FALSE;
                --
    END f_archivo_procesado;
    --
    -- Genera listado del proceso
    PROCEDURE p_lista_aviso_cobro(  pp_listado OUT VARCHAR2 ) IS
        --
        l_cant_recibos NUMBER := 0;
        l_listado      VARCHAR2(200);
        l_cod_mon      NUMBER(2);
        l_num_aviso    a5021691_mcr.num_aviso%TYPE;
        l_una_vez      BOOLEAN := TRUE;
        --
        -- listamos los avisos
        CURSOR c_avisos IS
            SELECT DISTINCT num_aviso, cod_mon 
              FROM TABLE(g_lista_datos)
              ORDER BY num_aviso, cod_mon; 
        --
        CURSOR c_recibos_lista IS
            WITH datos AS ( SELECT * FROM TABLE(g_lista_datos) WHERE num_aviso = l_num_aviso AND cod_mon = l_cod_mon)
            SELECT  a.num_aviso,
                    g_fec_proceso fec_proceso,
                    a.nombre_apellido nombre_tercero,
                    a.num_tarjeta,
                    b.num_poliza,
                    b.num_recibo,
                    b.imp_recibo,
                    b.tip_situacion,
                    b.fec_efec_recibo,
                    b.fec_vcto_recibo,
                    a.monto_pago
               FROM datos a, 
                    a2990700 b
              WHERE b.cod_cia   = g_cod_cia
                AND nvl(a.mca_procesado, 'N') = 'S'
                AND a.num_recibo = b.num_recibo
            ORDER BY b.num_poliza, b.num_recibo;
        --
        CURSOR c_lista_no_procesada IS
            SELECT * 
              FROM TABLE(g_lista_datos) 
             WHERE nvl(mca_procesado, 'N') = 'N'
               AND num_aviso               = l_num_aviso
               AND cod_mon                 = l_cod_mon; 
        --
    BEGIN
        --
        --
        l_listado := 'listado_aviso_cobro_' || g_id_proceso || '.csv';
        ptraza1(l_listado,
                'w',
                'LISTADO DE RECIBOS ASOCIADOS A AVISO ' ||
                -- ' Fecha ' || to_char(g_fec_proceso, 'dd/mm/yyyy') || 
                ' ID ' || g_id_proceso
        );
        --
        ptraza1(l_listado, 'a','');
        --
        FOR r_aviso IN c_avisos LOOP 
            --
            IF r_aviso.num_aviso IS NOT NULL THEN
                --
                l_num_aviso := r_aviso.num_aviso;
                l_cod_mon   := r_aviso.cod_mon;
                --
                l_una_vez      := TRUE;
                l_cant_recibos := 0;
                FOR reg_recibo IN c_recibos_lista LOOP
                    --
                    IF l_una_vez THEN
                        ptraza1(l_listado, 'a', 'AVISO DE COBRO: ' || l_num_aviso );
                        ptraza1(l_listado, 'a', 'Moneda: '|| CF_MonedaFormula( r_aviso.cod_mon ) );
                        ptraza1(l_listado, 'a', '');
                        ptraza1(l_listado, 'a', 'NUM_AVISO;Num Poliza;Num Recibo;Situacion;Importe Recibo;Importe Pago;Fecha Efecto Recibo; Fecha Vcto Recibo');
                        l_una_vez := FALSE;
                    END IF;
                    --
                    ptraza1(l_listado,
                            'a',
                            l_num_aviso || ';' || reg_recibo.num_poliza || ';' ||
                            reg_recibo.num_recibo || ';' || reg_recibo.tip_situacion || ';' ||
                            fp_procesa_mto( reg_recibo.imp_recibo, 2 )  || ';' || 
                            fp_procesa_mto( reg_recibo.monto_pago, 2 )  || ';' || 
                            fp_desc_fecha( reg_recibo.fec_efec_recibo )  || ';' ||
                            fp_desc_fecha( reg_recibo.fec_vcto_recibo )  
                    );
                    l_cant_recibos := l_cant_recibos + 1;
                    --
                END LOOP;
                --
                IF l_cant_recibos > 0 THEN
                    ptraza1(l_listado, 'a', '');
                    ptraza1(l_listado, 'a', 'Total Recibos ' || l_cant_recibos);
                END IF;    
                --
                l_cant_recibos := 0;
                l_una_vez      := TRUE;
                FOR reg_no_procesado IN c_lista_no_procesada LOOP 
                    --
                    IF l_una_vez THEN
                        -- 
                        -- lista de los no procesados
                        ptraza1(l_listado, 'a', '');
                        ptraza1(l_listado, 'a', '');
                        ptraza1(l_listado, 'a', 'LISTADO DE TARJETAS NO PROCESADAS');
                        ptraza1(l_listado, 'a', '');
                        ptraza1(l_listado, 'a', 'NUM_AVISO;Num Poliza;Num Tarjeta;Observacion');
                        l_una_vez := FALSE;
                    END IF;
                    --
                    ptraza1(l_listado,
                            'a',
                            l_num_aviso || ';' || 
                            reg_no_procesado.num_poliza || ';' ||
                            reg_no_procesado.num_tarjeta || ';' ||
                            reg_no_procesado.observacion  
                    );
                    --
                    l_cant_recibos := l_cant_recibos + 1;
                    --
                END LOOP;
                --
                IF l_cant_recibos > 0 THEN
                    ptraza1(l_listado, 'a', '');
                    ptraza1(l_listado, 'a', 'Total NO Procesados ' || l_cant_recibos);
                END IF;    
                --
            END IF;
            --
            ptraza1(l_listado, 'a', ' ');
            --
        END LOOP;
        --    
        pp_listado := l_listado;
        --
        EXCEPTION
            WHEN OTHERS THEN
            NULL;
        --    
    END p_lista_aviso_cobro;
    --
    -- elimina los registros anteriores no procesados
    PROCEDURE p_reinicia_registro IS 
    BEGIN 
        --
        DELETE a5021691_mcr
         WHERE cod_cia       = g_cod_cia
           AND id_proceso    = g_id_proceso
           AND mca_procesado = 'N'
           AND num_aviso IS NULL
           AND fec_proceso = g_fec_proceso;
        --
    END p_reinicia_registro;
    --
    -- registro de datos 
    PROCEDURE p_registrar_aviso IS 
        --
    BEGIN 
        --
        INSERT INTO a5021691_mcr(
            cod_cia,
            id_proceso,
            fec_proceso,
            cantidad_registros,
            cod_docum,
            nombre_tercero,
            ape1_tercero,
            ape2_tercero,
            num_tarjeta,
            mca_procesado,
            observaciones,
            nombre_archivo,
            cod_usr,
            fec_actu,
            num_recibo,
            num_poliza,
            num_spto,
            tip_docum
        )
        VALUES(
            g_cod_cia,
            g_id_proceso,
            g_fec_proceso,
            g_cant_registros,
            g_cod_docum_pago,
            g_nombre_apellido,
            NULL,
            NULL,
            g_num_tarjeta,
            'N',
            NULL,
            g_nombre_archivo,
            g_cod_usr,
            trn_k_tiempo.f_fec_actu,
            g_num_recibo,
            g_num_poliza,
            g_num_spto,
            g_tip_docum_tomador
        );
        --
        --ptraza('cobro_aviso', 'a', '0.1');
        IF SQL%ROWCOUNT > 0 THEN
            g_cant_registros := g_cant_registros + 1;
        END IF;
        --
        EXCEPTION
            WHEN OTHERS THEN
                g_cod_error := -20004;
                p_devuelve_error( p_msg => 'p_registrar_aviso');
                RAISE e_procesar_archivo;
                --
    END p_registrar_aviso;
    --
    -- tratamiento de montos
    FUNCTION f_procesa_monto( p_monto IN OUT VARCHAR2 ) RETURN NUMBER IS
      --
      l_valor_retorno NUMBER;
      l_sep_mil       g0000000.val_param%TYPE := trn_k_g0000000.f_txt_separador_miles;
      l_sep_dec       g0000000.val_param%TYPE := trn_k_g0000000.f_txt_separador_decimales;
      --
    BEGIN
        --
        IF p_monto IS NOT NULL THEN
          --
          l_valor_retorno := trim(p_monto);
        --   SELECT to_number( trim(p_monto),
        --                       '9G999G999G990D00'
        --                   )
        --     INTO l_valor_retorno
        --     FROM DUAL;
          --
        END IF;
        --
        RETURN l_valor_retorno;
        --
        EXCEPTION
            WHEN OTHERS THEN
                dbms_output.put_line( 'f_procesa_monto ' || SQLERRM);
                RETURN NULL;
        --        
    END f_procesa_monto;  
    -- 
    -- tratamiento de fecha
    FUNCTION f_procesa_fecha( p_fecha IN OUT VARCHAR2 ) RETURN DATE IS
        --
        l_valor_retorno DATE;
        --
    BEGIN 
        --
        IF p_fecha IS NOT NULL THEN
          --
          SELECT to_date( trim(p_fecha),'DD/MM/YYYY' )
            INTO l_valor_retorno
            FROM DUAL;
          --
        END IF;
        --
        RETURN l_valor_retorno;
        --
        EXCEPTION
            WHEN OTHERS THEN
                dbms_output.put_line( SQLERRM );
                RETURN NULL;
        --                
    END f_procesa_fecha; 
    --
    -- tratamiento del tipo de documento
    FUNCTION f_procesa_tip_docum RETURN VARCHAR2 IS
        --
        l_tip_docum          a1001331.tip_docum%TYPE;
        --
    BEGIN 
        --
        l_tip_docum := NULL;
        --
        IF length(g_cod_docum_pago) = 9 THEN
            --
            IF substr(g_cod_docum_pago, 1, 1) IN ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0') THEN
                l_tip_docum := 'CNA';
            ELSE
                l_tip_docum := 'PAS';
            END IF;
        ELSIF length(g_cod_docum_pago) = 10 THEN
            l_tip_docum := 'CJU';
        ELSIF length(g_cod_docum_pago) = 12 THEN
            l_tip_docum := 'CRE';
        ELSE
            l_tip_docum := 'PAS';
        END IF;
        --
        RETURN l_tip_docum;
        --
    END f_procesa_tip_docum;
    --
    -- determinamos el numero de poliza
    PROCEDURE p_numero_poliza IS 
        --
        CURSOR c_poliza IS
            SELECT a.num_poliza, b.num_spto, b.mca_poliza_anulada,
                   b.num_poliza_grupo, b.cod_agt, b.cod_docum, b.tip_docum
              FROM a2000060 a, 
                   a2000030 b, 
                   a2000020 c
             WHERE a.cod_cia     = g_cod_cia
               AND b.cod_ramo    = nvl( g_cod_ramo, b.cod_ramo )
               AND a.tip_docum   = g_tip_docum_pago
               AND a.cod_docum   = g_cod_docum_pago
               AND a.tip_benef   = 2
               AND a.cod_cia     = b.cod_cia
               AND a.num_poliza  = b.num_poliza
               AND a.num_spto    = b.num_spto
               AND a.mca_baja    = 'N'
               AND a.mca_vigente = 'S'
               AND c.cod_cia     = a.cod_cia
               AND c.num_poliza  = a.num_poliza
               AND c.cod_campo   = 'NUM_TARJETA'
               AND c.val_campo   = g_num_tarjeta 
               AND c.mca_vigente = 'S'
               AND b.cod_ramo IN ( 230 );
        --
    BEGIN 
        --
        OPEN c_poliza;
        FETCH c_poliza INTO g_num_poliza, g_num_spto, g_mca_poliza_anulada,
                            g_num_poliza_grupo, g_cod_agt, g_cod_docum_tomador, g_tip_docum_tomador;
        IF c_poliza%NOTFOUND THEN
            g_num_poliza        := NULL;
            g_num_spto          := NULL; 
            g_num_poliza_grupo  := NULL;   
            g_cod_agt           := NULL;
            g_cod_docum_tomador := NULL;
            g_tip_docum_tomador := NULL;
        END IF;                     
        CLOSE c_poliza;
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                g_num_poliza := NULL;
                g_num_spto   := NULL;    
                --
    END p_numero_poliza;
    --
    -- determina el recibo de la poliza
    PROCEDURE p_recibo_poliza( p_fec_pago DATE ) IS 
        --
        -- recibos 
        CURSOR c_recibos IS
            SELECT x.num_recibo, x.imp_recibo
              FROM (SELECT r.*
                      FROM a2990700 r
                     WHERE r.cod_cia       = g_cod_cia
                       AND r.tip_situacion = 'EP'
                       AND r.num_poliza    = g_num_poliza
                       AND r.imp_recibo > 0
                       AND r.num_aviso IS NULL
                      -- AND extract(MONTH FROM r.fec_efec_recibo) = extract(MONTH FROM p_fec_pago) 
                      -- AND extract(YEAR FROM r.fec_efec_recibo) = extract(YEAR FROM p_fec_pago) 
                     ORDER BY r.fec_efec_recibo ASC
                   ) x
             WHERE (  x.num_recibo ) NOT IN (
                 SELECT z.num_recibo
                   FROM a5021691_mcr z
                  WHERE z.cod_cia = g_cod_cia  
                    AND z.num_recibo IS NOT NULL
             );
        --     
    BEGIN 
        --
        OPEN c_recibos;
        FETCH c_recibos INTO g_num_recibo, g_imp_recibo;
        IF c_recibos%NOTFOUND THEN
            g_num_recibo    := NULL;
            g_imp_recibo    := 0; 
        ELSE
            --
            gc_k_a2990700.p_lee_rec( g_cod_cia, g_num_recibo );
            g_imp_recibo := gc_k_a2990700.f_tot_recibo;   

            dbms_output.put_line(g_num_poliza ||' -> '||g_imp_recibo);
            -- 
        END IF; 
        CLOSE c_recibos;
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                g_num_recibo    := NULL;
                g_imp_recibo    := 0; 
        --
    END p_recibo_poliza;
    --
    -- tratamiento de datos
    PROCEDURE p_tratar_linea( p_line VARCHAR2 ) IS
        --
        l_linea    NUMBER := 0;
        --
        -- formaert datos
        CURSOR c_datos IS
            SELECT rownum, regexp_substr(p_line, '[^;]+', 1, LEVEL) dato
            FROM DUAL
            CONNECT BY regexp_substr(p_line, '[^;]+', 1, LEVEL) IS NOT NULL;
        --    
    BEGIN 
        -- 
        g_fecha_pago := NULL;
        --
        FOR reg IN c_datos LOOP
            --
            l_linea := l_linea + 1;
            --
            dbms_output.put_line(reg.dato);
            --
            IF l_linea = 1 THEN         -- id. tarjeta
                g_num_tarjeta := reg.dato;
            ELSIF l_linea = 2 THEN      -- id. tomador
                g_cod_docum_pago := reg.dato;
            ELSIF l_linea = 3 THEN      -- nombres y Apellidos del Asegurado
                g_nombre_apellido := reg.dato;
            ELSIF l_linea = 4 THEN      -- monto del pago
                g_monto_pago := reg.dato;
            ELSIF l_linea = 5 THEN      -- moneda de pago
                g_moneda := reg.dato;
            ELSIF l_linea = 6 THEN      -- fecha de pago 
                g_fecha_pago := reg.dato;
            END IF;
            --
        END LOOP;
        --
        IF g_fecha_pago IS NOT NULL THEN
            g_registo_dato.fec_pago := f_procesa_fecha(g_fecha_pago);
        END IF;
        --    
        g_tip_docum_pago        := f_procesa_tip_docum;
        p_numero_poliza;
        p_recibo_poliza(g_registo_dato.fec_pago);
        --
        -- hacemos el registro de los datos
        g_registo_dato.num_tarjeta          := g_num_tarjeta;
        g_registo_dato.cod_docum_pago       := g_cod_docum_pago;
        g_registo_dato.tip_docum_pago       := g_tip_docum_pago;
        g_registo_dato.nombre_apellido      := g_nombre_apellido;
        g_registo_dato.monto_pago           := f_procesa_monto( g_monto_pago );
        
        g_registo_dato.cod_mon              := substr(g_moneda,1,1);

        g_registo_dato.num_poliza           := g_num_poliza;
        g_registo_dato.num_spto             := g_num_spto;
        g_registo_dato.mca_poliza_anulada   := g_mca_poliza_anulada;
        g_registo_dato.num_poliza_grupo     := g_num_poliza_grupo;
        g_registo_dato.cod_agt              := g_cod_agt;
        g_registo_dato.num_aviso            := NULL;
        g_registo_dato.num_recibo           := g_num_recibo;
        g_registo_dato.imp_recibo           := g_imp_recibo;
        g_registo_dato.cod_docum_tomador    := g_cod_docum_tomador;
        g_registo_dato.tip_docum_tomador    := g_tip_docum_tomador;
        --
        p_agregar_a_lista;
        --
        EXCEPTION 
            WHEN OTHERS THEN 
                dbms_output.put_line( 'p_tratar_line ' || SQLERRM);
                g_cod_error := -20003;
                p_devuelve_error( p_msg => 'p_tratar_line');
                RAISE e_tratar_line;
                --
    END p_tratar_linea;
    --
    -- procesar archivo
    PROCEDURE p_procesar_archivo IS 
        --
        l_cant_registros    NUMBER := 0;
        l_line              VARCHAR2(1024);
        --
    BEGIN 
        --
        IF g_file_is_open THEN
            LOOP
                --
                utl_file.get_line(g_file, l_line);
                l_cant_registros := l_cant_registros + 1;
                dbms_output.put_line(l_line);
                p_tratar_linea( l_line );
                --
                p_registrar_aviso;
                --
            END LOOP;
        END IF;
        --
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN;
            WHEN OTHERS THEN
                g_cod_error := -20004;
                p_devuelve_error( p_msg => 'p_procesar_archivo');
                RAISE e_procesar_archivo;
                --
    END p_procesar_archivo;
    --
    -- procesar el aviso de cobro
    PROCEDURE p_procesar_aviso_cobro IS 
        --
        l_tip_docum_pago        a2990700.tip_docum_pago %TYPE := 'AV';
        l_num_aviso             a2990700.num_aviso%TYPE;
        l_imp_aviso             NUMBER  := 0;
        l_fec_vcto              DATE    := trunc(sysdate);
        l_cod_mon               a2000030.cod_mon%TYPE;
        l_val_cambio            a1000500.val_cambio%TYPE;
        l_tip_docum             a2000030.tip_docum%TYPE;
        l_cod_docum             a2000030.cod_docum%TYPE;
        l_num_poliza_cliente    a2000030.num_poliza_cliente %TYPE;
        l_num_poliza_grupo      a2000030.num_poliza_grupo %TYPE;
        l_num_contrato          a2000030.num_contrato %TYPE;
        l_num_poliza            a2000030.num_poliza %TYPE;
        l_cod_agt               a2990700.cod_agt %TYPE;
        l_tip_gestor            a2990700.tip_gestor%TYPE;
        l_cod_gestor            a2990700.cod_gestor%TYPE;
        l_fec_remesa            DATE;
        l_listado               VARCHAR2(50);
        --
        -- se agrupa las polizas
        CURSOR c_poliza_grupo IS 
            SELECT num_poliza_grupo, cod_mon,  
                   tip_docum_tomador, cod_docum_tomador, 
                   sum(imp_recibo) imp_aviso
              FROM TABLE( g_lista_datos ) 
             GROUP BY num_poliza_grupo, cod_mon, tip_docum_tomador, cod_docum_tomador 
             ORDER BY num_poliza_grupo, cod_mon, tip_docum_tomador, cod_docum_tomador;
        --
        PROCEDURE pi_actualiza_aviso( p_registro IN gc_k_cobro_aviso_bco_nacional.typ_rec_formato ) IS
        BEGIN
            --
            UPDATE a2990700
               SET num_aviso = l_num_aviso
             WHERE cod_cia       = g_cod_cia
               AND num_recibo    = p_registro.num_recibo
               AND tip_situacion = 'RE'
               AND num_aviso IS NULL;
            --
            UPDATE a5021691_mcr
               SET num_aviso     = p_registro.num_aviso,
                   observaciones = p_registro.observacion,
                   mca_procesado = p_registro.mca_procesado
             WHERE cod_cia            = g_cod_cia 
               AND id_proceso         = g_id_proceso    
               AND trunc(fec_proceso) = g_fec_proceso 
               AND num_tarjeta        = p_registro.num_tarjeta
               AND cod_docum          = p_registro.cod_docum_pago
               AND nombre_archivo     = g_nombre_archivo
               AND num_recibo         = p_registro.num_recibo;
            --   
        END pi_actualiza_aviso;    
        --
        --   
        PROCEDURE pi_actualiza_registro( p_registro IN gc_k_cobro_aviso_bco_nacional.typ_rec_formato ) IS
        BEGIN
            --
            UPDATE a5021691_mcr
               SET num_aviso     = p_registro.num_aviso,
                   observaciones = p_registro.observacion,
                   mca_procesado = p_registro.mca_procesado
             WHERE cod_cia            = g_cod_cia 
               AND id_proceso         = g_id_proceso    
               AND trunc(fec_proceso) = g_fec_proceso 
               AND num_tarjeta        = p_registro.num_tarjeta
               AND cod_docum          = p_registro.cod_docum_pago
               AND nombre_archivo     = g_nombre_archivo
               AND num_recibo         = p_registro.num_recibo;
            --   
        END pi_actualiza_registro;   
        --
    BEGIN 
        --   
        g_registo_dato := NULL;
        --
        FOR r_poliza_grupo IN c_poliza_grupo LOOP 
            -- 
            l_num_aviso := NULL;
            IF f_verifica_poliza_grupo( r_poliza_grupo.num_poliza_grupo ) AND r_poliza_grupo.imp_aviso > 0 THEN 
                l_num_aviso     := gc_f_s5020009;
                l_val_cambio    := dc_f_val_cambio( r_poliza_grupo.cod_mon, g_fec_proceso );
                gc_k_a5021646.p_inserta_por_campos( p_cod_cia            => g_cod_cia,
                                                    p_tip_docum_pago     => 'AV',
                                                    p_cod_docum_pago     => l_num_aviso,
                                                    p_fec_mvto           => g_fec_proceso,
                                                    p_fec_vcto           => l_fec_vcto,
                                                    p_cod_mon            => r_poliza_grupo.cod_mon,
                                                    p_imp_docum          => r_poliza_grupo.imp_aviso,
                                                    p_val_cambio         => l_val_cambio,
                                                    p_cod_act_tercero    => 1,
                                                    p_tip_docum          => r_poliza_grupo.tip_docum_tomador,
                                                    p_cod_docum          => r_poliza_grupo.cod_docum_tomador,
                                                    p_tip_estado         => 'RE',
                                                    p_num_poliza_cliente => NULL,
                                                    p_num_poliza         => NULL,
                                                    p_num_contrato       => NULL,
                                                    p_num_poliza_grupo   => r_poliza_grupo.num_poliza_grupo,
                                                    p_cod_agt            => NULL,
                                                    p_tip_gestor         => NULL,
                                                    p_cod_gestor         => NULL,
                                                    p_cod_usr            => g_cod_usr,
                                                    p_fec_actu           => trn_k_tiempo.f_fec_actu
                );
            END IF;    
            --
            --  recorremos los datos a procesar
            FOR i IN 1..g_lista_datos.count LOOP
                --
                IF r_poliza_grupo.num_poliza_grupo = g_lista_datos(i).num_poliza_grupo THEN
                    --
                    g_lista_datos(i).observacion    := 'Sin Procesar';
                    g_lista_datos(i).mca_procesado  := 'N';
                    g_lista_datos(i).num_aviso      := 'N/A';

                    IF g_lista_datos(i).num_recibo IS NULL THEN
                        g_lista_datos(i).observacion    := 'No se selecciono Recibo'; 
                    ELSE
                        --
                        IF l_num_aviso IS NOT NULL THEN 
                            --
                            g_lista_datos(i).num_aviso      := l_num_aviso;                 
                            l_num_poliza                    := g_lista_datos(i).num_poliza;
                            --
                            IF g_lista_datos(i).tip_docum_pago IS NOT NULL THEN
                                --
                                IF g_lista_datos(i).mca_poliza_anulada = 'N' THEN  
                                    --
                                    IF g_lista_datos(i).imp_recibo > 0 THEN
                                        --
                                        g_lista_datos(i).mca_procesado := 'S';
                                        g_lista_datos(i).observacion   := 'Procesado';
                                        --
                                        gc_p_remesa_letra( g_cod_cia,
                                            g_lista_datos(i).num_recibo,
                                            g_fec_proceso,
                                            l_tip_docum_pago,
                                            l_num_aviso,
                                            g_cod_usr,
                                            trn_k_tiempo.f_fec_actu
                                        );
                                        --
                                        pi_actualiza_aviso( g_lista_datos(i) );
                                        --
                                        gc_p_cambia_gestor_recibo( g_cod_cia,
                                            g_lista_datos(i).num_recibo,
                                            'CR',
                                            g_fec_proceso,
                                            gc_k_a2990700.f_tip_gestor,
                                            gc_k_a2990700.f_cod_gestor,
                                            NULL,
                                            g_cod_usr,
                                            trn_k_tiempo.f_fec_actu
                                        );   
                                        -- 
                                    ELSE
                                        g_lista_datos(i).mca_procesado   := 'N';
                                        g_lista_datos(i).observacion     := 'No se procesa, monto Importe < 0';       
                                    END IF;
                                    --
                                ELSE
                                    g_lista_datos(i).mca_procesado  := 'N';
                                    g_lista_datos(i).observacion    := 'Poliza Anulada';    
                                END IF;
                            --
                            ELSE
                                g_lista_datos(i).mca_procesado  := 'N';
                                g_lista_datos(i).observacion    := 'Codigo de Documento no es Valido!';  
                            END IF;
                        ELSE
                            g_lista_datos(i).mca_procesado  := 'N';
                            g_lista_datos(i).observacion    := 'Poliza Grupo no esta Permitida'; 
                        END IF;    
                        --
                    END IF;    
                    pi_actualiza_registro( g_lista_datos(i) );
                    --
                END IF;
                --  
            END LOOP;
            --
        END LOOP;    
        -- creamos los listados .CSV
        p_lista_aviso_cobro( l_listado );
        --                    
        trn_k_global.asigna('JBNOM_LISTADO', l_listado);
        --
    END p_procesar_aviso_cobro;
    -- 
    -- eliminar aviso
    PROCEDURE p_elimina_aviso( p_num_aviso IN a2990700.num_aviso%TYPE ) IS 
        --
        CURSOR c_recibos_aviso IS
            SELECT num_recibo
              FROM a2990700
             WHERE cod_cia   = g_cod_cia
               AND num_aviso = p_num_aviso
               AND tip_situacion = 'RE'
            ORDER BY 1;
    BEGIN 
        --
        IF p_num_aviso IS NOT NULL THEN
            --
            -- leemos el aviso 
            g_cod_cia        := trn_k_global.devuelve('JBCOD_CIA');
            gc_k_a5021646.p_lee( g_cod_cia, 'AV', p_num_aviso, 1);
            --
            FOR r_recibos_aviso IN c_recibos_aviso LOOP
                --
                gc_p_desremesa_recibo( g_cod_cia,
                                       r_recibos_aviso.num_recibo,
                                        trunc(sysdate),
                                        g_cod_usr,
                                        g_fec_proceso
                                     );
                --
                UPDATE a2990700
                   SET tip_docum_pago = NULL,
                       cod_docum_pago = NULL,
                       fec_actu       = sysdate,
                       num_aviso      = NULL
                 WHERE cod_cia    = g_cod_cia
                   AND num_aviso  = p_num_aviso
                   AND num_recibo = r_recibos_aviso.num_recibo
                   AND tip_situacion IN ('RE', 'EP');
                --                     
            END LOOP;
            --
            DELETE a5021646
             WHERE cod_cia         = g_cod_cia
               AND tip_docum_pago  = 'AV'
               AND cod_docum_pago  = p_num_aviso
               AND cod_act_tercero = 1;
            --
            p_reinicia_registro;
            --
        END IF;
        --
    END p_elimina_aviso;
    --
    PROCEDURE p_aviso_cobro_globales IS 
    BEGIN
        --
        -- se inicia el proceso para la lectura de las globales
        p_inicio_proceso;
        --
        IF NOT f_archivo_procesado THEN
            --
            p_reinicia_registro;
            --
            -- se procesa el archivo
            p_procesar_archivo;
            --
            -- se procesa el aviso de cobro
            p_procesar_aviso_cobro;
            --
            COMMIT;
            --
        ELSE
            g_cod_error := -20005;
            g_msg_error := 'Archivo: '|| g_nombre_archivo ||', ya fue procesado!';
            RAISE e_archivo_procesado;    
        END IF;    
        --
        -- finalizamos el proceso
        p_fin_proceso;
        --
        EXCEPTION 
            WHEN e_iniciar_proceso THEN 
                raise_application_error(g_cod_error, g_msg_error);
            WHEN e_archivo_procesado THEN 
                raise_application_error(g_cod_error, g_msg_error);    
            WHEN e_fin_proceso THEN 
                raise_application_error(g_cod_error, g_msg_error);
            WHEN e_tratar_line THEN 
                raise_application_error(g_cod_error, g_msg_error);
            WHEN e_procesar_archivo THEN 
                raise_application_error(g_cod_error, g_msg_error);
            WHEN e_registro_aviso THEN 
                raise_application_error(g_cod_error, g_msg_error);   
            WHEN e_manejo_argumento THEN    
                raise_application_error(g_cod_error, g_msg_error);  
            WHEN OTHERS THEN
                raise_application_error(SQLCODE, SQLERRM);   
            --
    END p_aviso_cobro_globales;
    --
END gc_k_cobro_aviso_bco_nacional;