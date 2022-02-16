CREATE OR REPLACE PROCEDURE EM_P_CAMBIA_GESTOR_PAGADOR_MCR IS
  --
  /* ------------------------ VERSION = 1.00 ---------------------------- */
  /* -------------------- DESCRIPCION --------------------
  || Procedimiento que realiza la actualizacion de gestor de cobro si 
  || existe la figura de pagador (21)  y tiene datos financieros
  || de tarjeta
  */
  --
  /* -------------------- MODIFICACIONES --------------------
  || 2021/07/19 - MAPFRE COsta Rica
  ||    Creacion del programa
  ||
  */ --------------------------------------------------------
  --
  /* --------------------------------------------------------------------------------------------
  || Declaracion de Variables Locales
  */ --------------------------------------------------------------------------------------------
  --

  -- Variables para almacenar los datos variables del riesgo
  l_cod_cia        ta300003.cod_cia %TYPE;
  l_num_poliza     a2000030.num_poliza %TYPE;
  l_num_spto       a2000030.num_spto %TYPE;
  l_num_apli       a2000030.num_apli %TYPE;
  l_num_spto_apli  a2000030.num_spto_apli %TYPE;
  l_existe_pagador BOOLEAN;
  l_tip_docum      a1001331.tip_docum%TYPE;
  l_cod_docum      a1001331.cod_docum%TYPE;
  l_fec_efec_spto  a2000030.fec_efec_spto%TYPE;
  l_tip_gestor_ta  a2990700.tip_gestor%TYPE := 'TA';
  l_cod_entidad    a1001331.cod_entidad%TYPE;
  l_cod_oficina    a1001331.cod_oficina%TYPE;
  l_num_tarjeta    a1001331.num_tarjeta%TYPE;
  l_cod_tarjeta    a1001331.cod_tarjeta%TYPE;
  l_tip_tarjeta    a1001331.tip_tarjeta%TYPE;
  l_cod_gestor     a2000030.cod_gestor%TYPE;
  l_cod_usr        a2000030.cod_usr%TYPE := trn_k_global.cod_usr;
  l_cant           NUMBER := 0;
  l_traza          VARCHAR2(100);
  l_num_riesgo     a2000031.num_riesgo%TYPE := 1;
  --
  CURSOR c_a2990700 IS
    SELECT a.*
      FROM a2990700 a
     WHERE a.cod_cia = l_cod_cia
       AND a.num_poliza = l_num_poliza
          --AND a.num_spto = l_num_spto
       AND a.num_apli = l_num_apli
       AND a.num_spto_apli = l_num_spto_apli
       AND a.tip_situacion = 'EP';
  --
  CURSOR c_a2000060 IS
    SELECT tip_docum, cod_docum
      FROM a2000060
     WHERE cod_cia = l_cod_cia
       AND num_poliza = l_num_poliza
       AND tip_benef = 21 -- Pagador
       AND mca_vigente = trn.SI;
  --
BEGIN
  --
  ptraza('em_p_cambia_gestor_pagador', 'w', 'INICIO');
  --
  IF trn_k_global.ref_f_global('tip_emision') = 'C' THEN
    RETURN;
  END IF;
  --
  l_cod_cia       := trn_k_global.ref_f_global('cod_cia');
  l_num_poliza    := trn_k_global.ref_f_global('num_poliza');
  l_num_spto      := trn_k_global.ref_f_global('num_spto');
  l_num_apli      := trn_k_global.ref_f_global('num_apli');
  l_num_spto_apli := trn_k_global.ref_f_global('num_spto_apli');
  l_fec_efec_spto := to_date(trn_k_global.ref_f_global('fec_efec_spto'),
                             'ddmmyyyy');
  --
  l_traza := 'em_p_cambia_gestor_pagador_' || l_num_poliza;
  --
  ptraza(l_traza,
         'w',
         'l_cod_cia ' || l_cod_cia || ' l_fec_efec_spto ' ||
         l_fec_efec_spto || ' l_num_spto ' || l_num_spto);
  --
  OPEN c_a2000060;
  FETCH c_a2000060
    INTO l_tip_docum, l_cod_docum;
  l_existe_pagador := c_a2000060%FOUND;
  CLOSE c_a2000060;
  --
  IF l_existe_pagador THEN
    --
    ptraza(l_traza,
           'a',
           'EXISTE PAGADOR. ' || l_tip_docum || '-' || l_cod_docum);
    dc_k_terceros.p_lee_con_poliza(l_cod_cia,
                                   l_tip_docum,
                                   l_cod_docum,
                                   null,
                                   trunc(sysdate),
                                   1,
                                   l_num_poliza,
                                   l_num_spto,
                                   l_num_riesgo);
    --
    l_num_tarjeta := dc_k_terceros.f_num_tarjeta;
    l_cod_tarjeta := dc_k_terceros.f_cod_tarjeta;
    l_tip_tarjeta := dc_k_terceros.f_tip_tarjeta;
    --
    IF (l_num_tarjeta IS NOT NULL AND l_cod_tarjeta IS NOT NULL AND
       l_tip_tarjeta IS NOT NULL) THEN
      --
      l_cod_entidad := dc_k_terceros.f_cod_entidad;
      l_cod_oficina := dc_k_terceros.f_cod_oficina;
      --
      l_cod_gestor := l_cod_entidad || l_cod_oficina;
      --
      IF l_cod_entidad IS NOT NULL THEN
        l_cod_gestor := l_cod_entidad || l_cod_oficina;
      ELSE
        l_cod_gestor := '01020000'; -- OJO
      END IF;
      --
      ptraza(l_traza,
             'a',
             'Tarjeta ' || l_num_tarjeta || ' Gestor ' || l_cod_gestor);
      --
      FOR reg IN c_a2990700 LOOP
        --
        ptraza(l_traza,
               'a',
               '   Recibo ' || reg.num_recibo || ' gestor ' ||
               l_tip_gestor_ta || '-' || l_cod_gestor);
        gc_p_cambia_gestor_recibo(l_cod_cia,
                                  reg.num_recibo,
                                  reg.tip_situacion,
                                  l_fec_efec_spto,
                                  l_tip_gestor_ta,
                                  l_cod_gestor,
                                  'CG',
                                  l_cod_usr,
                                  SYSDATE);
        --
        l_cant := l_cant + 1;
        --
      END LOOP;
      --
      IF l_cant > 0 THEN
        --
        ptraza(l_traza, 'a', 'Actualiza gestor de la poliza');
        --
        gc_p_cambia_gestor_poliza(l_cod_cia,
                                  l_num_poliza,
                                  l_num_apli,
                                  l_tip_gestor_ta,
                                  l_cod_gestor);
        --
      END IF;
      --
    ELSE
      ptraza(l_traza, 'a', 'NO tiene datos financieros');
    END IF;
    --
  ELSE
    ptraza(l_traza, 'a', 'NO tiene pagador');
  END IF;
  --
  COMMIT;
  --
EXCEPTION
  WHEN OTHERS THEN
    ptraza('em_p_cambia_gestor_pagador',
           'a',
           'Error EM_P_CAMBIA_GESTOR_PAGADOR_MCR ' || sqlerrm);
END EM_P_CAMBIA_GESTOR_PAGADOR_MCR;
/
