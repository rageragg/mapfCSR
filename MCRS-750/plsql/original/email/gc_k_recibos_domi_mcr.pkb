CREATE OR REPLACE PACKAGE gc_k_recibos_domi_mcr
AS
/*-----------------------DESCRIPCION-----------------------------------
|| Carga de los recibos para la Domiciliacion Bancaria. (PAC).
*/---------------------------------------------------------------------
--
/*-------------------- VERSION = 1.03 --------------------- */
--
/* -------------------- MODIFICACIONES --------------------
|| David  23-07-2001 Version 1.03
|| Se a?ade el x5020039.cod_cta_simp
|| David  21-09-2000 Version 1.02
|| Se a?ade la fec_cobro
*/ --------------------------------------------------------
--
PROCEDURE p_proceso (p_cod_cia          a2990700.cod_cia           %TYPE,
                     p_fec_desde        a2990700.fec_efec_recibo   %TYPE,
                     p_fec_hasta        a2990700.fec_efec_recibo   %TYPE,
                     p_tip_gestor       a2990700.tip_gestor        %TYPE,
                     p_cod_gestor       a2990700.cod_gestor        %TYPE,
                     p_cod_mon          a2990700.cod_mon           %TYPE,
                     p_cod_cta_simp     a5022600.cod_cta_simp      %TYPE,
                     p_fec_remesa       a2990700.fec_remesa        %TYPE,
                     p_fec_cobro        a2990700.fec_remesa        %TYPE);
/* -------------------- DESCRIPCION -----------------------
||
*/ --------------------------------------------------------
PROCEDURE p_proceso_con_globales;
/* -------------------- DESCRIPCION -----------------------
|| Recoge las globales por trn_k_global
*/ --------------------------------------------------------
PROCEDURE p_borra_x5020039;
/* -------------------- DESCRIPCION -----------------------
|| Borra la tabla x5020039;
*/ --------------------------------------------------------
PROCEDURE p_borra_rec_x5020039
              (p_cod_cia     x5020039.cod_cia      %TYPE,
               p_num_recibo  x5020039.num_recibo   %TYPE);
/* -------------------- DESCRIPCION -----------------------
|| Borra recibo de la tabla x5020039;
*/ --------------------------------------------------------
PROCEDURE p_inserta_x5020039
              (p_cod_cia      x5020039.cod_cia      %TYPE,
               p_num_recibo   x5020039.num_recibo   %TYPE,
               p_imp_recibo   x5020039.imp_recibo   %TYPE,
               p_cod_mon      x5020039.cod_mon      %TYPE,
               p_cod_cta_simp x5020039.cod_cta_simp %TYPE,
               p_fec_actu     x5020039.fec_actu     %TYPE,
               p_cod_usr      x5020039.cod_usr      %TYPE);
/* -------------------- DESCRIPCION -----------------------
|| Inserta en la tabla x5020039;
*/ --------------------------------------------------------
--
END gc_k_recibos_domi_mcr; 
 
/
CREATE OR REPLACE PACKAGE BODY gc_k_recibos_domi_mcr
AS

/* -----------------------------------------------------------------------------
   Version de paquete del gc_k_recibos_domi_trn para Mapfre Costa Rica.
   Actualizar este paquete cada vez que se haga una actualizacion en
   gc_k_recibos_domi_trn. JLGO. (20/03/2012)
*/ -----------------------------------------------------------------------------


/* -------------------- VERSION = 1.13 -------------- */
--
/* ----------------- MODIFICACIONES ---------------------------------
|| 2011/10/05 - JCCARO - 1.13 - (MS-2010-12-01496)
|| Se modifica el llamado al procedimiento dc_k_terceros.p_lee_con_poliza
|| agregandole como ultimo parametro em_k_a2000030.f_num_secu_cta_tar.
|| Se agrega el llamado al procedimiento dc_k_a1002201.p_lee.
|| Se agrega la condicion IF dc_k_a1002201.f_mca_inh = trn.SI que permite
|| saber si la cuenta de la poliza esta inhabilitada.
*/ -------------------------------------------------------------------
--
g_clave       VARCHAR2(80);
g_cod_cta_simp a5021600.cod_cta_simp %TYPE;
--
PROCEDURE p_proceso (p_cod_cia          a2990700.cod_cia           %TYPE,
                     p_fec_desde        a2990700.fec_efec_recibo   %TYPE,
                     p_fec_hasta        a2990700.fec_efec_recibo   %TYPE,
                     p_tip_gestor       a2990700.tip_gestor        %TYPE,
                     p_cod_gestor       a2990700.cod_gestor        %TYPE,
                     p_cod_mon          a2990700.cod_mon           %TYPE,
                     p_cod_cta_simp     a5022600.cod_cta_simp      %TYPE,
                     p_fec_remesa       a2990700.fec_remesa        %TYPE,
                     p_fec_cobro        a2990700.fec_remesa        %TYPE)
IS
   --
   l_tip_docum            a2000030.tip_docum            %TYPE;
   l_cod_docum            a2000030.cod_docum            %TYPE;
   l_cod_entidad          a1001331.cod_entidad          %TYPE;
   l_cod_oficina          a1001331.cod_oficina          %TYPE;
   l_cta_cte              a1001331.cta_cte              %TYPE;
   l_cta_dc               a1001331.cta_dc               %TYPE;
   l_tip_tarjeta          a1001331.tip_tarjeta          %TYPE;
   l_cod_tarjeta          a1001331.cod_tarjeta          %TYPE;
   l_num_tarjeta          a1001331.num_tarjeta          %TYPE;
   l_tip_situacion        a5020039.tip_situacion        %TYPE;
   l_cod_causa_anu        a5020039.cod_causa_anu        %TYPE := NULL;
   l_cod_cta_simp_bco     a5020039.cod_cta_simp_bco     %TYPE := NULL;
   l_val_cambio_cobro     a5020039.val_cambio_cobro     %TYPE := NULL;
   l_cod_mon_cobro        a5020039.cod_mon_cobro        %TYPE := NULL;
   l_fec_cobro            a5020039.fec_cobro            %TYPE := NULL;
   l_imp_cobro            a5020039.imp_cobro            %TYPE := NULL;
   l_cod_tercero          a1001390.cod_tercero          %TYPE := NULL;
   l_mca_excluir          a5020039.mca_excluir          %TYPE := NULL;
   l_cod_docum_pago       a5020039.cod_docum_pago       %TYPE := NULL;
   l_tip_docum_pago       a5020039.tip_docum_pago       %TYPE := NULL;
   l_cod_error            a5020039.cod_error            %TYPE := NULL;
   l_num_riesgo           a1000802.num_riesgo           %TYPE := NULL;
   --
   l_num_poliza           a2990700.num_poliza           %TYPE;
   l_num_spto             a2990700.num_spto             %TYPE;
   l_num_apli             a2990700.num_apli             %TYPE;
   l_num_spto_apli        a2990700.num_spto_apli        %TYPE;
   l_cod_ramo             a2000030.cod_ramo             %TYPE;
   l_cod_mon              a2990700.cod_mon              %TYPE;
   l_fec_efec_recibo      a2990700.fec_efec_recibo      %TYPE;
   l_num_aviso            a2990700.num_aviso            %TYPE;
   l_tip_gestor           a2990700.tip_gestor           %TYPE;
   l_cod_gestor           a2990700.cod_gestor           %TYPE;
   l_cod_agt              a2990700.cod_agt              %TYPE;
   l_fec_remesa           a2990700.fec_remesa           %TYPE;
   l_fec_remesa_cobro     a2990700.fec_remesa           %TYPE;
   l_numrecibo            a2990700.num_recibo           %TYPE;
   l_cod_usr              a5020039.cod_usr              %TYPE;
   l_tip_clase_gestor     a5020200.tip_clase_gestor     %TYPE;
   l_cuantos              NUMBER   := trn.CERO               ;
   l_obs_cta_inh          VARCHAR2(2000)                       ;
   --
   g_cod_mensaje          g1010020.cod_mensaje          %TYPE;
   g_cod_idioma           a1000101.cod_idioma           %TYPE;
   g_anx_mensaje          g1010020.txt_mensaje          %TYPE;
   g_cod_mon_cia          a1000400.cod_mon              %TYPE;
   --
   l_cta_inh_exception EXCEPTION;
   --
-- --------------------------------------------------------------
-- Recibos que cumplen la condicion de pac
-- -------------------------
CURSOR c_a2990700 (p_cod_cia    a2990700.cod_cia         %TYPE
                  ,p_fec_desde  a2990700.fec_efec_recibo %TYPE
                  ,p_fec_hasta  a2990700.fec_efec_recibo %TYPE
                  ,p_tip_gestor a2990700.tip_gestor      %TYPE
                  ,p_cod_gestor a2990700.cod_gestor      %TYPE
                  ,p_cod_mon    a2990700.cod_mon         %TYPE)
IS
  SELECT num_recibo , SUM(NVL(imp_recibo,0)) imp_recibo
    FROM a2990700
   WHERE cod_cia + 0   = p_cod_cia
     AND tip_situacion = 'EP'
     AND tip_gestor    = p_tip_gestor
     AND (cod_gestor   = p_cod_gestor OR p_cod_gestor IS NULL)
     AND (cod_mon      = p_cod_mon    OR p_cod_mon    IS NULL)
     AND fec_efec_recibo BETWEEN p_fec_desde
                             AND P_fec_hasta
     AND num_recibo + 0 > 0
--   AND tip_remesa != '3 '
   GROUP BY num_recibo
   HAVING SUM(NVL(imp_recibo,0)) != 0;
-- FOR UPDATE OF num_recibo NOWAIT;
--
-- -----------------------------
-- Obtiene los recibos de la domiciliacion bancaria manual
-- -----------------------------
CURSOR c_x5020039 IS
  SELECT num_recibo, imp_recibo
    FROM x5020039
   WHERE cod_cia = p_cod_cia;
--
    reg_700 c_x5020039%ROWTYPE;
--
CURSOR c_x5020039_todo (pi_num_recibo x5020039.num_recibo %TYPE)
IS
  SELECT *
    FROM x5020039
   WHERE cod_cia    = p_cod_cia
     AND num_recibo = pi_num_recibo;
--
    reg_x39 c_x5020039_todo%ROWTYPE;
--
   CURSOR c_bloquea_recibo (pl_cod_cia    a2990700.cod_cia    %TYPE,
                            pl_num_recibo a2990700.num_recibo %TYPE)
   IS
      SELECT num_recibo
        FROM a2990700
       WHERE cod_cia +0 = pl_cod_cia
         AND num_recibo = pl_num_recibo
      FOR UPDATE OF num_recibo;
--
-- -----------------------------
-- p_comprueba_error
-- ----------------------------------------
PROCEDURE p_comprueba_error
         ( p_clave IN VARCHAR2  )  IS
 --
 l_cod_mensaje g1010020.cod_mensaje%TYPE;
 l_txt_mensaje g1010020.txt_mensaje%TYPE;
 l_hay_error   EXCEPTION;
 --
 BEGIN
    l_cod_mensaje := 20001;
    l_txt_mensaje := ss_f_mensaje(l_cod_mensaje);
    l_txt_mensaje := l_txt_mensaje || p_clave;
    --
    RAISE_APPLICATION_ERROR(-l_cod_mensaje,l_txt_mensaje);
    --
 END p_comprueba_error;
 --
 PROCEDURE pp_devuelve_error IS
 BEGIN
    --
    IF g_cod_mensaje BETWEEN 20000
                         AND 20999
    THEN
       --
       RAISE_APPLICATION_ERROR(-g_cod_mensaje                           ,
                               ss_k_mensaje.f_texto_idioma(g_cod_mensaje,
                                                           g_cod_idioma ) ||
                               ' ' || g_anx_mensaje
                              );
       --
    ELSE
       --
       RAISE_APPLICATION_ERROR(-20000                                   ,
                               ss_k_mensaje.f_texto_idioma(g_cod_mensaje,
                                                           g_cod_idioma ) ||
                               ' ' || g_anx_mensaje
                              );
       --
   END IF;
   --
 END pp_devuelve_error;
--
-- --------------------------------------------------------------
--   AQUI EMPIEZA EL PROCESO
-- --------------------------------------------------------------
BEGIN
   --
   l_cod_usr  := trn_k_global.cod_usr;     --v1.10
   --
   g_cod_mon_cia      := dc_f_cod_mon_cia (p_cod_cia);
   g_cod_idioma       := trn_k_global.cod_idioma;
   --
   IF NVL(trn_k_global.ref_f_global('MARCAR_CT'),'N') = 'S' AND
      p_cod_cta_simp IS NOT NULL AND p_fec_cobro IS NOT NULL
   THEN
      --
      -- Se quedan los recibos marcados como 'CT' para poder
      -- cobrarlos sin tener que actualizar la tabla buzon.
      --
      gc_k_a5022600.p_lee(p_cod_cia, p_cod_cta_simp);
      --
      l_cod_mon_cobro    := gc_k_a5022600.f_cod_mon;
      --
      IF p_cod_mon IS NOT NULL
      THEN
         IF l_cod_mon_cobro  != p_cod_mon -- La moneda de cobro es != a la moneda del recibo
         THEN
            --
            IF l_cod_mon_cobro != g_cod_mon_cia
            THEN
               -- la moneda del cobro no es la des pais.
               g_cod_mensaje := 50207057;
               g_anx_mensaje := ' [' || TO_CHAR(l_cod_mon_cobro) || ']' ||
                                ' [' || TO_CHAR(p_cod_mon) || ']';
               pp_devuelve_error;
               --
            ELSE
               -- La moneda de cobro es la del pais y la de los recibos es extranjera.
               dc_k_a1000500.p_lee_max_fecha ( p_cod_mon, p_fec_cobro);
                l_val_cambio_cobro := dc_k_a1000500.f_val_cambio;
                --
            END IF;
            --
         ELSE
            -- La moneda de cobro y de los recibos es la misma
            l_val_cambio_cobro := 1;
            --
         END IF;
         --
      END IF;
      --
   END IF;
   --
   DELETE A5020039
    WHERE cod_cia       = p_cod_cia
   -- AND fec_proceso   = p_fec_hasta
      AND fec_efec_recibo BETWEEN p_fec_desde
                              AND P_fec_hasta
      AND tip_situacion = 'EP'
      AND tip_gestor    = p_tip_gestor
      AND (cod_gestor   = p_cod_gestor OR p_cod_gestor IS NULL)
      AND (cod_mon      = p_cod_mon    OR p_cod_mon    IS NULL);
   --
   -- Version 1.08
   IF trn_k_global.ref_f_global('num_aviso') IS NULL
   THEN
      gc_p_envio_banco (l_num_aviso);
   ELSE
      l_num_aviso := trn_k_global.ref_f_global('num_aviso');
      trn_k_global.borra_variable('num_aviso');
   END IF;
   --
   g_cod_cta_simp := p_cod_cta_simp;
   --
   IF p_fec_desde IS NOT NULL
   THEN
      OPEN c_a2990700 (p_cod_cia   , p_fec_desde , p_fec_hasta,
                       p_tip_gestor, p_cod_gestor, p_cod_mon);
   ELSE
      OPEN c_x5020039;
   END IF;
   LOOP
     BEGIN
        IF p_fec_desde IS NOT NULL
        THEN
           FETCH c_a2990700 INTO reg_700;
           EXIT WHEN c_a2990700%NOTFOUND;
        ELSE
           FETCH c_x5020039 INTO reg_700;
           EXIT WHEN c_x5020039%NOTFOUND;
           IF c_x5020039%FOUND
           THEN
              OPEN c_x5020039_todo (reg_700.num_recibo);
              FETCH c_x5020039_todo INTO reg_x39;
              CLOSE c_x5020039_todo;
              g_cod_cta_simp := reg_x39.cod_cta_simp;
           END IF;
        END IF;
        --
        BEGIN
           gc_k_a2990700.p_lee_rec ( p_cod_cia
                                   , reg_700.num_recibo);
           --
           em_k_a2000030.p_lee     ( p_cod_cia
                                    , gc_k_a2990700.f_num_poliza
                                    , gc_k_a2990700.f_max_spto_030
                                    , gc_k_a2990700.f_num_apli
                                    , gc_k_a2990700.f_num_spto_apli);
           EXCEPTION
           WHEN OTHERS
           THEN g_clave := ' a2000030 :[' ||TO_CHAR(p_cod_cia)
                           ||'-'||gc_k_a2990700.f_num_poliza
                           ||'-'||TO_CHAR(gc_k_a2990700.f_max_spto_030)
                           ||'-'||TO_CHAR(gc_k_a2990700.f_num_apli)
                           ||'-'||TO_CHAR(gc_k_a2990700.f_num_spto_apli)
                           ||']';
                --
                p_comprueba_error ( g_clave );
                --
        END;
        --
        IF NVL(em_k_a2000030.f_mca_provisional,'N') = 'N'
        THEN
           --
           -- AQUI SE DEBE ASIGNAR TIP_DOCUM y COD_DOCUM DEPENDIENDO DE:
           --    Si la poliza tiene PAGADOR el tip_docum y cod_docum es del pagador
           --    Si la poliza NO tiene PAGADOR el tip_docum y cod_docum es tal como estaba antes (tomador)
           l_tip_docum     := em_k_a2000030.f_tip_docum;
           l_cod_docum     := em_k_a2000030.f_cod_docum;
           -- Verion 1.06
           --
           BEGIN
              --
              dc_k_terceros.p_lee_con_poliza(p_cod_cia          => p_cod_cia                       ,
                                             p_tip_docum        => l_tip_docum,--em_k_a2000030.f_tip_docum       ,
                                             p_cod_docum        => l_cod_docum,--em_k_a2000030.f_cod_docum       ,
                                             p_cod_tercero      => l_cod_tercero                   ,
                                             p_fec_validez      => trn_k_tiempo.f_fec_actu         ,
                                             p_cod_act_tercero  => trn.UNO                         ,
                                             p_num_poliza       => gc_k_a2990700.f_num_poliza      ,
                                             p_num_spto         => gc_k_a2990700.f_max_spto_030    ,
                                             p_num_riesgo       => 1,--l_num_riesgo                    ,
                                             p_num_secu_cta_tar => em_k_a2000030.f_num_secu_cta_tar);
              --
              dc_k_a1002201.p_lee(p_cod_cia          => p_cod_cia                       ,
                                  p_tip_docum        => em_k_a2000030.f_tip_docum       ,
                                  p_cod_docum        => em_k_a2000030.f_cod_docum       ,
                                  p_cod_act_tercero  => trn.UNO                         ,
                                  p_num_secu_cta_tar => em_k_a2000030.f_num_secu_cta_tar);
              --
              IF dc_k_a1002201.f_mca_inh = trn.SI
              THEN
                 --
                 RAISE l_cta_inh_exception;
                 --
              END IF;
              --
           EXCEPTION
              WHEN l_cta_inh_exception
              THEN
                 --
                 RAISE_APPLICATION_ERROR(-20000, ss_k_mensaje.f_texto_v(51001015, TO_CHAR(gc_k_a2990700.f_num_poliza )  || ' ' ||
                                         '  ' || TO_CHAR(dc_k_terceros.f_cod_entidad)  || '-' ||
                                         '  ' || TO_CHAR(dc_k_terceros.f_cod_oficina)  || '-' ||
                                         '  ' || TO_CHAR(dc_k_terceros.f_cta_cte    )));
                 --
              WHEN OTHERS
              THEN g_clave := ' a1001331 :[' ||to_char(p_cod_cia)
                              ||'-1-'||em_k_a2000030.f_tip_docum
                              ||'-'||em_k_a2000030.f_cod_docum
                              ||'-'||TRUNC(sysdate)
                              ||']';
              --
              p_comprueba_error ( g_clave );
              --
           END;
           --
           l_tip_situacion := gc_k_a2990700.f_tip_situacion;
           --
           dc_k_a5020200.p_lee(gc_k_a2990700.f_tip_gestor);
           l_tip_clase_gestor := dc_k_a5020200.f_tip_clase_gestor;
           --
           IF l_tip_clase_gestor = '4' -- 'DB'
           THEN
              l_cod_entidad := dc_k_terceros.f_cod_entidad;
              l_cod_oficina := dc_k_terceros.f_cod_oficina;
              l_cta_cte     := dc_k_terceros.f_cta_cte    ;
              l_cta_dc      := dc_k_terceros.f_cta_dc     ;
              l_tip_tarjeta := NULL;
              l_cod_tarjeta := NULL;
              l_num_tarjeta := NULL;
           ELSIF l_tip_clase_gestor = '8' --  'TA'
           THEN
              l_tip_tarjeta := dc_k_terceros.f_tip_tarjeta;
              l_cod_tarjeta := dc_k_terceros.f_cod_tarjeta;
              l_num_tarjeta := dc_k_terceros.f_num_tarjeta;
              l_cod_entidad := NULL;
              l_cod_oficina := NULL;
              l_cta_cte     := NULL;
              l_cta_dc      := NULL;
           ELSE
              l_tip_tarjeta := dc_k_terceros.f_tip_tarjeta;
              l_cod_tarjeta := dc_k_terceros.f_cod_tarjeta;
              l_num_tarjeta := dc_k_terceros.f_num_tarjeta;
              l_cod_entidad := dc_k_terceros.f_cod_entidad;
              l_cod_oficina := dc_k_terceros.f_cod_oficina;
              l_cta_cte     := dc_k_terceros.f_cta_cte    ;
              l_cta_dc      := dc_k_terceros.f_cta_dc     ;
           END IF;
           --
           l_num_poliza        := gc_k_a2990700.f_num_poliza     ;
           l_num_spto          := gc_k_a2990700.f_num_spto       ;
           l_num_apli          := gc_k_a2990700.f_num_apli       ;
           l_num_spto_apli     := gc_k_a2990700.f_num_spto_apli  ;
           l_cod_ramo          := em_k_a2000030.f_cod_ramo       ;
           l_cod_mon           := gc_k_a2990700.f_cod_mon        ;
           l_fec_efec_recibo   := gc_k_a2990700.f_fec_efec_recibo;
           l_tip_gestor        := gc_k_a2990700.f_tip_gestor     ;
           l_cod_gestor        := gc_k_a2990700.f_cod_gestor     ;
           l_cod_agt           := gc_k_a2990700.f_cod_agt        ;
           l_tip_docum_pago    := gc_k_a2990700.f_tip_docum_pago ;
           l_cod_docum_pago    := gc_k_a2990700.f_cod_docum_pago ;
           l_fec_remesa        := p_fec_remesa                   ;
           l_fec_cobro         := p_fec_cobro                    ;
           --
           IF l_fec_cobro IS NULL
           THEN
              --
              l_fec_remesa_cobro := l_fec_remesa;
              --
           ELSE
              --
              l_fec_remesa_cobro := l_fec_cobro;
              --
              IF NVL(trn_k_global.ref_f_global('MARCAR_CT'),'N') = 'S' AND
              p_cod_cta_simp IS NOT NULL AND p_fec_cobro IS NOT NULL   AND
              l_cod_mon_cobro IS NOT NULL
              THEN
                 --
                 IF p_cod_mon IS NULL
                 THEN
                    --
                    IF l_cod_mon_cobro = gc_k_a2990700.f_cod_mon
                    THEN
                       l_val_cambio_cobro := 1;
                    ELSE
                       -- La moneda de cobro es la del pais y la de los recibos es extranjera.
                       dc_k_a1000500.p_lee_max_fecha ( gc_k_a2990700.f_cod_mon, p_fec_cobro);
                       l_val_cambio_cobro := dc_k_a1000500.f_val_cambio;
                       --
                    END IF;
                    --
                 END IF;
                 --
                 -- Se quedan los recibos marcados como 'CT' para poder
                 -- cobrarlos sin tener que actualizar la tabla buzon.
                 --
                 -- La moneda de cobro es = a la moneda del recibo
                 --
                 IF l_cod_mon_cobro = gc_k_a2990700.f_cod_mon
                 THEN
                    l_imp_cobro        := gc_k_a2990700.f_tot_recibo;
                 ELSE
                    -- El l_cod_mon_cobro solo puede ser el del pais.
                    --
                    l_imp_cobro := dc_k_a1000400.f_redondea_importe
                          (g_cod_mon_cia,
                               dc_k_oper_monedas.f_a_pais(gc_k_a2990700.f_tot_recibo,
                                                          l_val_cambio_cobro));
                       --
                 END IF;
                 --
                 gc_p_remesa_recibo (p_cod_cia,
                                     reg_700.num_recibo,
                                     NVL(l_fec_remesa,TRUNC(sysdate)),
                                     l_cod_usr,
                                     trn_k_tiempo.f_fec_actu,
                 --- Modificado corporativa 022018
                                     null);

                 --
                 l_tip_situacion := 'CT';
                 --
              END IF;
              --
           END IF;
           --
           l_cuantos           := l_cuantos + 1                  ;
           l_mca_excluir       := NULL                           ;
           l_cod_error         := NULL                           ;
        --   l_cod_id_cb         := gc_f_seq_cod_id_ch             ;
           --
           -- Insertar en el buzon
           INSERT INTO A5020039
            ( cod_cia         , num_poliza      , num_spto        ,
              num_apli        , num_spto_apli   , cod_ramo        ,
              num_recibo      , imp_recibo      , cod_mon         ,
              fec_efec_recibo , num_aviso       , tip_gestor      ,
              cod_gestor      , cod_agt         , tip_docum       ,
              cod_docum       , cod_entidad     , cod_oficina     ,
              cta_cte         , cta_dc          , tip_tarjeta     ,
              cod_tarjeta     , num_tarjeta     , fec_remesa      ,
              tip_situacion   , cod_causa_anu   , cod_cta_simp_bco,
              val_cambio_cobro, cod_mon_cobro   , fec_cobro       ,
              imp_cobro       , cod_usr         , fec_actu        ,
              fec_proceso     , mca_excluir     , tip_docum_pago  ,
              cod_docum_pago  , cod_error       , cod_compensacion,
              cod_id_cb)
           VALUES
            ( p_cod_cia         , l_num_poliza      , l_num_spto             ,
              l_num_apli        , l_num_spto_apli   , l_cod_ramo             ,
              reg_700.num_recibo, reg_700.imp_recibo, l_cod_mon              ,
              l_fec_efec_recibo , l_num_aviso       , l_tip_gestor           ,
              l_cod_gestor      , l_cod_agt         , l_tip_docum            ,
              l_cod_docum       , l_cod_entidad     , l_cod_oficina          ,
              l_cta_cte         , l_cta_dc          , l_tip_tarjeta          ,
              l_cod_tarjeta     , l_num_tarjeta     , l_fec_remesa_cobro     ,
              l_tip_situacion   , l_cod_causa_anu   ,
              NVL(g_cod_cta_simp, l_cod_cta_simp_bco),
              l_val_cambio_cobro, l_cod_mon_cobro   , l_fec_cobro            ,
              l_imp_cobro       , l_cod_usr         , trn_k_tiempo.f_fec_actu,
              p_fec_hasta       , l_mca_excluir     , l_tip_docum_pago       ,
              l_cod_docum_pago  , l_cod_error       , null                      ,
              null);
           --
           --
           OPEN   c_bloquea_recibo( p_cod_cia
                                   ,reg_700.num_recibo);
           FETCH  c_bloquea_recibo INTO l_numrecibo;
           CLOSE  c_bloquea_recibo;

           --
           -- La remesa del recibo se puede hacer aqui o en el programa que
           -- genera el fichero para el banco JLGO.
           --
           gc_p_remesa_recibo (p_cod_cia,
                               reg_700.num_recibo,
                               NVL(l_fec_remesa,TRUNC(sysdate)),
                               l_cod_usr,
                               TRUNC(sysdate),
                  -- Modificado corporativa 022018
                               null);

           --
           -- Actualiza el tipo de situacion a 'RE' en la tabla A5020039. JLGO.
           gc_p_remesa_recibo_act_tip_sit(p_cod_cia,
                                          reg_700.num_recibo);

           --
        END IF;
     END;
     END LOOP;
   --
     IF c_a2990700%ISOPEN
     THEN
        CLOSE c_a2990700;
     END IF;
     IF c_x5020039%ISOPEN
     THEN
        CLOSE c_x5020039;
     END IF;
   --
   -- control impresion
   -- control_arc_nom

   -- Generar el archivo de texto que se envia al banco. JLGO.
   IF p_tip_gestor = 'DB' THEN
      -- Debito Bancario a Cuenta
      --
      ptraza('trazaP_proceso.txt',
             'A',
             'Llama al proceso que genera el archivo de debito directo');
      gc_p_remesa_rec_cta_imp(p_cod_cia, l_num_aviso);
      --
   ELSE
      --
      gc_p_remesa_recibo_imp(p_cod_cia, l_num_aviso);
      --
   END IF;

   trn_k_global.asigna('mca_ter_tar','S');
   --
   trn_k_global.asigna('cuantos_rec',TO_CHAR(l_cuantos));
   trn_k_global.asigna('num_aviso39',l_num_aviso);
   --
   trn_k_global.borra_variable('MARCAR_CT');
   --
END p_proceso;
/* -------------------- MODIFICACIONES --------------------
|| Usuario   - 98/09/21
|| Creaci?n del Package
*/ --------------------------------------------------------
PROCEDURE p_proceso_con_globales IS
BEGIN
   p_proceso (TO_NUMBER(trn_k_global.devuelve('jbcod_cia'))   ,
              TO_DATE  (trn_k_global.devuelve('jbfec_desde'),'dd-mm-yyyy') ,
              TO_DATE  (trn_k_global.devuelve('jbfec_hasta'),'dd-mm-yyyy') ,
              trn_k_global.devuelve('jbtip_gestor')           ,
              trn_k_global.devuelve('jbcod_gestor')           ,
              trn_k_global.devuelve('jbcod_mon')              ,
              trn_k_global.devuelve('jbcod_cta_simp')         ,
              TO_DATE  (trn_k_global.devuelve('jbfec_remesa'),'dd-mm-yyyy') ,
              TO_DATE  (trn_k_global.devuelve('jbfec_cobro' ),'dd-mm-yyyy') );
END p_proceso_con_globales;
/* -------------------- MODIFICACIONES --------------------
|| Usuario   - 99/12/27
|| Creaci?n del Package
*/ --------------------------------------------------------
PROCEDURE p_borra_x5020039 IS
BEGIN
   DELETE X5020039;
END p_borra_x5020039;
/* -------------------- MODIFICACIONES --------------------
|| Usuario   - 99/12/27
|| Creaci?n del Package
*/ --------------------------------------------------------
PROCEDURE p_borra_rec_x5020039
              (p_cod_cia     x5020039.cod_cia      %TYPE,
               p_num_recibo  x5020039.num_recibo   %TYPE)
IS
BEGIN
   DELETE X5020039
    WHERE cod_cia    = p_cod_cia
      AND num_recibo = p_num_recibo;
END p_borra_rec_x5020039;
/* -------------------- MODIFICACIONES --------------------
|| Usuario   - 99/12/27
|| Creaci?n del Package
*/ --------------------------------------------------------
PROCEDURE p_inserta_x5020039
              (p_cod_cia      x5020039.cod_cia      %TYPE,
               p_num_recibo   x5020039.num_recibo   %TYPE,
               p_imp_recibo   x5020039.imp_recibo   %TYPE,
               p_cod_mon      x5020039.cod_mon      %TYPE,
               p_cod_cta_simp x5020039.cod_cta_simp %TYPE,
               p_fec_actu     x5020039.fec_actu     %TYPE,
               p_cod_usr      x5020039.cod_usr      %TYPE)
IS
BEGIN
   INSERT INTO X5020039
      (cod_cia, num_recibo, imp_recibo, cod_mon, cod_cta_simp,
       fec_actu, cod_usr)
   VALUES
      (p_cod_cia, p_num_recibo, p_imp_recibo, p_cod_mon, p_cod_cta_simp,
       p_fec_actu, p_cod_usr);
END p_inserta_x5020039;
---------------------------------------------------------------------
END gc_k_recibos_domi_mcr;
/
