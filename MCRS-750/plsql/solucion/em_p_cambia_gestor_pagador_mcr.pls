CREATE OR REPLACE PROCEDURE em_p_cambia_gestor_pagador_mcr IS
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
	l_cod_entidad    a1001331.cod_entidad%TYPE;
	l_cod_oficina    a1001331.cod_oficina%TYPE;
	l_num_tarjeta    a1001331.num_tarjeta%TYPE;
	l_cod_tarjeta    a1001331.cod_tarjeta%TYPE;
	l_tip_tarjeta    a1001331.tip_tarjeta%TYPE;
	l_cod_gestor     a2000030.cod_gestor%TYPE;
	l_traza          VARCHAR2(100);
	--
	l_cant           NUMBER := 0;
	l_cod_usr        a2000030.cod_usr%TYPE := trn_k_global.cod_usr;
	l_tip_gestor_ta  a2990700.tip_gestor%TYPE := 'TA';
	l_num_riesgo     a2000031.num_riesgo%TYPE := 1;
	--
	-- se seleccionan los recibos pendientes que seran procesados
	CURSOR c_a2990700 IS
		SELECT a.*
		  FROM a2990700 a
		 WHERE a.cod_cia       = l_cod_cia
		   AND a.num_poliza    = l_num_poliza
		   AND a.num_apli      = l_num_apli
	 	   AND a.num_spto_apli = l_num_spto_apli
		   AND a.tip_situacion = 'EP';
	--
	-- seleccionamos el pagador si lo hubiese
	CURSOR c_a2000060 IS
		SELECT tip_docum, cod_docum
		  FROM a2000060
		 WHERE cod_cia     = l_cod_cia
		   AND num_poliza  = l_num_poliza
		   AND tip_benef   = 21 				-- Pagador
		   AND mca_vigente = trn.SI;
  	--
BEGIN
  	--
  	ptraza('em_p_cambia_gestor_pagador', 'w', 'INICIO');
	--
	IF trn_k_global.ref_f_global('TIP_EMISION') = 'C' THEN
		ptraza('em_p_cambia_gestor_pagador', 'a', 'NO APLICA EL TIPO DE EMISION, FIN DE PROCESAMIENTO');
		RETURN;
	END IF;
	--
	l_cod_cia       := trn_k_global.ref_f_global('COD_CIA');
	l_num_poliza    := trn_k_global.ref_f_global('NUM_POLIZA');
	l_num_spto      := trn_k_global.ref_f_global('NUM_SPTO');
	l_num_apli      := trn_k_global.ref_f_global('NUM_APLI');
	l_num_spto_apli := trn_k_global.ref_f_global('NUM_SPTO_APLI');
	l_fec_efec_spto := to_date(trn_k_global.ref_f_global('FEC_EFEC_SPTO'), 'ddmmyyyy');
	--
  	l_traza := 'em_p_cambia_gestor_pagador_' || l_num_poliza;
  	--
	ptraza(l_traza,
			'w',
			'l_cod_cia =>' || l_cod_cia || 
			' l_fec_efec_spto =>' || l_fec_efec_spto || 
			' l_num_spto => ' || l_num_spto
		  );
  	--
	-- verificamos si existe pagador
	OPEN c_a2000060;
	FETCH c_a2000060 INTO l_tip_docum, l_cod_docum;
	l_existe_pagador := c_a2000060%FOUND;
	CLOSE c_a2000060;
	--
	IF l_existe_pagador THEN
		--
		ptraza('em_p_cambia_gestor_pagador', 'a', 'PROCESANDO..!');
		ptraza(l_traza,	'a', 'Existe pagador. ' || l_tip_docum || '-' || l_cod_docum);
		--
		-- se busca el dato del pagador desde la poliza, tambien busca datos en a1000802 que debe estar inicializada previamente
		dc_k_terceros.p_lee_con_poliza( p_cod_cia 			=> l_cod_cia,
										p_tip_docum			=> l_tip_docum,
										p_cod_docum			=> l_cod_docum,
										p_cod_tercero		=> null,
										p_fec_validez		=> trunc(sysdate),
										p_cod_act_tercero	=> 1,
										p_num_poliza		=> l_num_poliza,
										p_num_spto			=> l_num_spto,
										p_num_riesgo		=> l_num_riesgo
									  );
		--
		-- se captura la informacion de las tarjetas para el pago
		l_num_tarjeta := dc_k_terceros.f_num_tarjeta;
		l_cod_tarjeta := dc_k_terceros.f_cod_tarjeta;
		l_tip_tarjeta := dc_k_terceros.f_tip_tarjeta;
		--
		IF (l_num_tarjeta IS NOT NULL AND l_cod_tarjeta IS NOT NULL AND	l_tip_tarjeta IS NOT NULL) THEN
			--
			ptraza(l_traza,	'a', 'Tarjeta ' || l_num_tarjeta || ' Gestor ' || l_cod_gestor);
			--
			l_cod_entidad := dc_k_terceros.f_cod_entidad;
			l_cod_oficina := dc_k_terceros.f_cod_oficina;
			--
			IF l_cod_entidad IS NOT NULL THEN
				l_cod_gestor := l_cod_entidad || l_cod_oficina;
			ELSE
				l_cod_gestor := '01020000'; -- OJO
			END IF;
			--
			-- se cambian los recibos pendientes
			FOR reg IN c_a2990700 LOOP
				--
				ptraza( l_traza,	'a', '   Recibo ' || reg.num_recibo || 
				                         ' gestor ' || l_tip_gestor_ta || '-' || l_cod_gestor
					  );
				--
				gc_p_cambia_gestor_recibo( p_cod_cia		=> l_cod_cia,
										   p_num_recibo		=> reg.num_recibo,
										   p_tip_situacion	=> reg.tip_situacion,
										   p_fec_remesa		=> l_fec_efec_spto,
										   p_tip_gestor		=> l_tip_gestor_ta,
										   p_cod_gestor		=> l_cod_gestor,
										   p_cod_causa		=> 'CG',
										   p_cod_usr		=> l_cod_usr,
										   p_fec_actu		=> sysdate
										 );
				--
				l_cant := l_cant + 1;
				--
			END LOOP;
			--
			IF l_cant > 0 THEN
				--
				ptraza(l_traza, 'a', 'Actualiza gestor de la poliza');
				--
				gc_p_cambia_gestor_poliza( p_cod_cia 	=> l_cod_cia,
										   p_num_poliza	=> l_num_poliza,
										   p_num_apli	=> l_num_apli,
										   p_tip_gestor	=> l_tip_gestor_ta,
										   p_cod_gestor	=> l_cod_gestor
										 );
				--
			END IF;
			--
		ELSE
			--
			ptraza(l_traza, 'a', 'NO tiene datos financieros');
			--
		END IF;
		--
	ELSE
		ptraza('em_p_cambia_gestor_pagador', 'a', 'NO SE REALIZO PROCESO..!');
		ptraza(l_traza, 'a', 'NO tiene pagador');
	END IF;
	--
	COMMIT;
  	--
	ptraza('em_p_cambia_gestor_pagador', 'a', 'FIN');
	--  
	EXCEPTION
		WHEN OTHERS THEN
			ptraza('em_p_cambia_gestor_pagador',
			       'a',
			       'Error EM_P_CAMBIA_GESTOR_PAGADOR_MCR ' || sqlerrm);
	--
END em_p_cambia_gestor_pagador_mcr;
