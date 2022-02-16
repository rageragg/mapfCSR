create or replace PROCEDURE gc_p_remesa_recibo_imp(p_cod_cia   A5020039.cod_cia%TYPE,
                                                   p_num_aviso A5020039.num_aviso%TYPE) IS

  --------------------------------------------------------------------------------
  -- Proposito: Imprimir la remesa de recibos a cobrar por tarjeta de credito.
  --------------------------------------------------------------------------------
  --
  -- CARRIERHOUSE v.1.01 - 2019/12/20
  -- Se incorpora llamada a funcion dc_f_tarjeta_cifrado_mcr para desencriptar
  -- numero TDC 
  --
  -- CARRIERHOUSE v.1.02 - 2020/03/18
  -- En el caso de TDC de longitud diferente a 6 digitos se mantiene elnumero actual
  --
  -- CARRIERHOUSE v.1.03 - 2020/09/16
  -- Correccin en cursor que trae los recibos ya que para obtener la fecha de vencimiento
  -- de tarjeta estaba considerando que el registro en la a1000802 debia estar en el mismo 
  -- spto del recibo. Se cambio para qe busque el maximo movimiento vigente en A1000802
  --
  l_num_tdc_real num_tarjeta_mcr.num_tarjeta_vista%TYPE;
  --
  CURSOR c_recibos(p_cod_cta_simp_bco A5020039.cod_cta_simp_bco%TYPE) IS
    SELECT rec.num_aviso envio,
           rec.num_recibo acuerdo,
           rec.num_tarjeta tarjeta,
           NVL((SELECT TO_CHAR(a.fec_vcto_tarjeta, 'MMYY')
                 FROM a1000802 a -- Modificaciones locales de un tercero para una poliza.
                WHERE a.cod_cia = rec.cod_cia
                  AND a.num_poliza = rec.num_poliza
                     --AND a.num_spto = rec.num_spto
                  AND a.num_riesgo = 0 -- Ruben Ruiz se coloca por que trae más de un registro
                  AND a.tip_docum = rec.tip_docum
                  AND a.cod_docum = rec.cod_docum
                  AND a.tip_tarjeta = rec.tip_tarjeta
                  AND a.cod_tarjeta = rec.cod_tarjeta
                  AND a.num_tarjeta = rec.num_tarjeta
                  AND a.num_spto =
                      (SELECT max(x.num_spto)
                         FROM a1000802 x
                        WHERE x.cod_cia = a.cod_cia
                          AND x.num_poliza = a.num_poliza
                          AND x.num_riesgo = a.num_riesgo
                          AND x.tip_docum = a.tip_docum
                          AND x.cod_docum = a.cod_docum
                          AND x.tip_tarjeta = a.tip_tarjeta
                          AND x.cod_tarjeta = a.cod_tarjeta
                          AND x.num_tarjeta = a.num_tarjeta)),
               (SELECT TO_CHAR(a.fec_vcto_tarjeta, 'MMYY')
                  FROM a1001331 a -- Terceros Relacionados con Polizas
                 WHERE a.cod_cia = rec.cod_cia
                   AND a.tip_docum = rec.tip_docum
                   AND a.cod_docum = rec.cod_docum
                      ---   
                   AND a.tip_tarjeta = rec.tip_tarjeta
                   AND a.cod_tarjeta = rec.cod_tarjeta
                   AND a.num_tarjeta = rec.num_tarjeta)) vence,
           ter.nom_tercero || ' ' || ter.ape1_tercero cliente,
           rec.imp_recibo monto,
           rec.fec_remesa fecha,
           rec.num_poliza poliza,
           rec.cod_cta_simp_bco banco,
           ter.tip_docum,
           ter.cod_docum
    ---       
      FROM A5020039 rec, -- Recibos Batch
           A1001399 ter -- Terceros
    ---       
     WHERE rec.cod_cia = p_cod_cia
       AND rec.num_aviso = p_num_aviso
       AND rec.cod_cta_simp_bco = p_cod_cta_simp_bco
          ---
       AND rec.cod_cia = ter.cod_cia
       AND rec.tip_docum = ter.tip_docum
       AND rec.cod_docum = ter.cod_docum;
  ---
  ---
  CURSOR c_bancos IS
    SELECT DISTINCT cod_cta_simp_bco
      FROM A5020039 -- Recibos Batch
     WHERE cod_cia = p_cod_cia
       AND num_aviso = p_num_aviso;
  --
  l_nombre_archivo VARCHAR2(100) := NULL;
  --
BEGIN
  --
  ptraza('gc_p_remesa_recibo_imp',
         'w',
         'INCIO cod_cia ' || p_cod_cia || ' p_num_aviso ' || p_num_aviso);
  --
  FOR ban IN c_bancos LOOP
  
    -- Genera un archivo para cada banco en el envio.
    --
    l_nombre_archivo := ban.cod_cta_simp_bco || '_' ||
                        TO_CHAR(SYSDATE, 'YYYY-MM-DD_HH-MI_AM') || '.txt';
    ptraza('gc_p_remesa_recibo_imp',
           'a',
           'l_nombre_archivo ' || l_nombre_archivo);
    --
    ptraza1(l_nombre_archivo, 'W', 'TABLE');
    ptraza1(l_nombre_archivo, 'A', '0,1');
    ptraza1(l_nombre_archivo, 'A', '"EXCEL"');
    ptraza1(l_nombre_archivo, 'A', 'VECTORS');
    ptraza1(l_nombre_archivo, 'A', '0,0');
    ptraza1(l_nombre_archivo, 'A', '""');
    ptraza1(l_nombre_archivo, 'A', 'TUPLES');
    ptraza1(l_nombre_archivo, 'A', '0,0');
    ptraza1(l_nombre_archivo, 'A', '""');
    ptraza1(l_nombre_archivo, 'A', 'DATA');
    ptraza1(l_nombre_archivo, 'A', '0,0');
    ptraza1(l_nombre_archivo, 'A', '""');
    ptraza1(l_nombre_archivo, 'A', '-0,1');
    ptraza1(l_nombre_archivo, 'A', 'BOT');
    ptraza1(l_nombre_archivo, 'A', '1,0');
    ptraza1(l_nombre_archivo, 'A', '"ENVIO"');
    ptraza1(l_nombre_archivo, 'A', '1,0');
    ptraza1(l_nombre_archivo, 'A', '"ACUERDO"');
    ptraza1(l_nombre_archivo, 'A', '1,0');
    ptraza1(l_nombre_archivo, 'A', '"TARJETA"');
    ptraza1(l_nombre_archivo, 'A', '1,0');
    ptraza1(l_nombre_archivo, 'A', '"VENCE"');
    ptraza1(l_nombre_archivo, 'A', '1,0');
    ptraza1(l_nombre_archivo, 'A', '"CLIENTE"');
    ptraza1(l_nombre_archivo, 'A', '1,0');
    ptraza1(l_nombre_archivo, 'A', '"MONTO"');
    ptraza1(l_nombre_archivo, 'A', '1,0');
    ptraza1(l_nombre_archivo, 'A', '"FECHA"');
    ptraza1(l_nombre_archivo, 'A', '1,0');
    ptraza1(l_nombre_archivo, 'A', '"POLIZA"');
  
    FOR rec IN c_recibos(ban.cod_cta_simp_bco) LOOP
      --
      ptraza('gc_p_remesa_recibo_imp', 'a', 'rec.tarjeta ' || rec.tarjeta);
      --       
      IF (length(rec.tarjeta) = 16 AND rec.tarjeta LIKE '%********%') THEN
        --
        l_num_tdc_real := dc_f_tarjeta_cifrado_mcr(p_cod_cia,
                                                   rec.poliza,
                                                   rec.tip_docum,
                                                   rec.cod_docum,
                                                   rec.tarjeta);
        --
        IF l_num_tdc_real IS NULL THEN
          ptraza('gc_p_remesa_recibo_imp', 'a', '    OJO devuelve NULL');
          l_num_tdc_real := rec.tarjeta;
        END IF;
      ELSE
        l_num_tdc_real := rec.tarjeta;
      END IF;
      --
      ptraza('gc_p_remesa_recibo_imp',
             'a',
             rec.acuerdo || ' tercero ' || rec.tip_docum || '-' ||
             rec.cod_docum || ' pol ' || rec.poliza || ' tarjeta ' ||
             rec.tarjeta || ' l_num_tdc_real ' || l_num_tdc_real);
      --
      ptraza1(l_nombre_archivo, 'A', '-1,0');
      ptraza1(l_nombre_archivo, 'A', 'BOT');
      ptraza1(l_nombre_archivo, 'A', '1,0');
      ptraza1(l_nombre_archivo, 'A', '"' || rec.acuerdo || '"');
      ptraza1(l_nombre_archivo, 'A', '1,0');
      ptraza1(l_nombre_archivo, 'A', '"' || rec.envio || '"');
      ptraza1(l_nombre_archivo, 'A', '1,0');
      --ptraza1(l_nombre_archivo, 'A', '"' || '''' || rec.tarjeta || '"');
      ptraza1(l_nombre_archivo, 'A', '"' || '''' || l_num_tdc_real || '"');
      ptraza1(l_nombre_archivo, 'A', '1,0');
      ptraza1(l_nombre_archivo, 'A', '"' || '''' || rec.vence || '"');
      ptraza1(l_nombre_archivo, 'A', '1,0');
      ptraza1(l_nombre_archivo, 'A', '"' || rec.cliente || '"');
      ptraza1(l_nombre_archivo, 'A', '1,0');
      ptraza1(l_nombre_archivo, 'A', '"' || rec.monto || '"');
      ptraza1(l_nombre_archivo, 'A', '1,0');
      ptraza1(l_nombre_archivo, 'A', '"' || rec.fecha || '"');
      ptraza1(l_nombre_archivo, 'A', '1,0');
      ptraza1(l_nombre_archivo, 'A', '"' || '''' || rec.poliza || '"');
      --
    
    END LOOP;
  
  END LOOP;
  --
  ptraza('gc_p_remesa_recibo_imp', 'a', 'FIN');
  --
END gc_p_remesa_recibo_imp;
