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
	|| 		Creacion del programa
	|| 2022/02/17 - CARRIERHOUSE - RGUERRA
	||		Se agrega el siguiente flujo
	||      1.- Se verifica que la poliza tiene pagador
	||      2.- Si tiene pagador, verifique que sus datos esten en a1000802
	||		2.1.- Si estan sus datos, comprobar que los datos de a1001331 sean compatibles con a1000802
	||		2.2.- Si no son iguales entonces actualizar tabla a1000802 con base a a1001331
	||      3.- Si los datos no estan en a1000802 entonces poblar la tabla a1000802
	||      Esto se aplica con el proceso P_PROCESA_PAGADOR
	*/ --------------------------------------------------------
	--
	/* --------------------------------------------------------------------------------------------
	|| Declaracion de Variables Locales
	*/ --------------------------------------------------------------------------------------------
    --
    -- constantes
    k_cod_grupo CONSTANT VARCHAR2(15) := 'PCGC00001';
    k_vi        CONSTANT VARCHAR2(03) := 'VI_';
    k_cod_sur   CONSTANT VARCHAR2(15) := 'TRON2000';
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
    l_cod_gestor_ana a2000030.cod_gestor%TYPE;
	l_traza          VARCHAR2(100);
	--
	l_cant           NUMBER := 0;
	l_cod_usr        a2000030.cod_usr%TYPE := trn_k_global.cod_usr;
	l_tip_gestor_ta  a2990700.tip_gestor%TYPE := 'TA';
	l_num_riesgo     a2000031.num_riesgo%TYPE := 1;
	--
	-- se seleccionan los recibos pendientes que seran procesados
	CURSOR c_a2990700 IS
		SELECT *
		  FROM a2990700
		 WHERE cod_cia       = l_cod_cia
		   AND num_poliza    = l_num_poliza
		   AND num_apli      = l_num_apli
	 	   AND num_spto_apli = l_num_spto_apli
		   AND tip_situacion = 'EP';
    --
    -- analisis de tarjeta
    PROCEDURE pp_analisis_tarjeta IS 
        --
        -- buscamos la configuracion de la tarjeta
        CURSOR c_analisis IS
            SELECT cast( txt_valor_variable as varchar2(13))
              FROM g1010107
             WHERE cod_usr              = k_cod_sur
               AND cod_grupo            = k_cod_grupo
               AND txt_nombre_variable  = k_vi || substr(l_num_tarjeta,1,1);
        --
    BEGIN 
		--
        OPEN c_analisis; 
        FETCH c_analisis INTO l_cod_gestor_ana;
        CLOSE c_analisis;
        --
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN
                l_cod_gestor_ana := NULL;
            WHEN OTHERS THEN 
                l_cod_gestor_ana := NULL;
        --        
    END pp_analisis_tarjeta;
    --
  	--
	-- verifica la integridad del dato del pagador si lo hubiera
	PROCEDURE p_procesa_pagador IS 
		--
		l_existe_a1000802		BOOLEAN	:= FALSE;
		l_existe_a1001331		BOOLEAN	:= FALSE;
		l_datos_consistentes	BOOLEAN := FALSE;
		--
		-- seleccionamos el pagador si lo hubiese
		CURSOR c_a2000060 IS
			SELECT tip_docum, cod_docum
			  FROM a2000060
			 WHERE cod_cia     = l_cod_cia
			   AND num_poliza  = l_num_poliza
			   AND tip_benef   = 21
			   AND mca_vigente = trn.SI;
		--
		l_x_no_existe EXCEPTION;
  		PRAGMA        EXCEPTION_INIT(l_x_no_existe,-20001);
		--
		-- existe datos en a1000802
		FUNCTION f_existe_a1000802 RETURN BOOLEAN IS 
		BEGIN
			-- 
			em_k_a1000802_trn.p_lee_vigente( p_cod_cia    => l_cod_cia,
                         					 p_num_poliza => l_num_poliza,
                         					 p_num_spto   => 0,
                         					 p_num_riesgo => 1,
                         					 p_tip_docum  => l_tip_docum,
                         					 p_cod_docum  => l_cod_docum 
										   );
			--
			RETURN TRUE;							    
			--
			EXCEPTION
   				WHEN l_x_no_existe THEN
				   RETURN FALSE;
			--
		END f_existe_a1000802;
		--
		-- existe datos en a1001331
		FUNCTION f_existe_a1001331 RETURN BOOLEAN IS 
		BEGIN
			-- 
			dc_k_terceros_trn.p_lee(  p_cod_cia          => l_cod_cia,
                   					  p_tip_docum        => l_tip_docum,
                   				      p_cod_docum        => l_cod_docum,
                   					  p_cod_tercero      => NULL,
                   					  p_fec_validez      => trunc(sysdate),
                   					  p_cod_act_tercero  => 1,
                   					  p_num_secu_cta_tar => NULL
								   );
			--
			RETURN TRUE;							    
			--
			EXCEPTION
   				WHEN OTHERS THEN
				   RETURN FALSE;
			--
		END f_existe_a1001331;
		--
	BEGIN 
		--
		ptraza(l_traza, 'a', 'Inicio Analisis del Pagador');
		--
		-- 1.- Se verifica que tenga pagador
		OPEN c_a2000060;
		FETCH c_a2000060 INTO l_tip_docum, l_cod_docum;
		l_existe_pagador := c_a2000060%FOUND;
		CLOSE c_a2000060;
		--
		IF l_existe_pagador THEN 
			--
			-- 2.- Si tiene pagador, verifique que sus datos esten en a1000802
			ptraza(l_traza,	'a', 'Existe pagador. ' || l_tip_docum || '-' || l_cod_docum);
			--
			l_existe_a1000802 := f_existe_a1000802;
			l_existe_a1001331 := f_existe_a1001331;
			--
			IF l_existe_a1000802 THEN 
				--
				-- 2.1.- Si estan sus datos, comprobar que los datos de a1001331 sean compatibles con a1000802
				IF l_existe_a1001331 THEN 
					--
					IF dc_k_terceros_trn.f_mca_inh = 'N' THEN
						l_datos_consistentes := ( em_k_a1000802_trn.f_cod_entidad = dc_k_terceros_trn.f_cod_entidad );
						l_datos_consistentes := ( em_k_a1000802_trn.f_cod_oficina = dc_k_terceros_trn.f_cod_oficina ) AND l_datos_consistentes;
						l_datos_consistentes := ( em_k_a1000802_trn.f_cta_cte = dc_k_terceros_trn.f_cta_cte ) AND l_datos_consistentes;
						l_datos_consistentes := ( em_k_a1000802_trn.f_cta_dc = dc_k_terceros_trn.f_cta_dc ) AND l_datos_consistentes;
						l_datos_consistentes := ( em_k_a1000802_trn.f_tip_tarjeta = dc_k_terceros_trn.f_tip_tarjeta ) AND l_datos_consistentes;
						l_datos_consistentes := ( em_k_a1000802_trn.f_cod_tarjeta = dc_k_terceros_trn.f_cod_tarjeta ) AND l_datos_consistentes;
						l_datos_consistentes := ( em_k_a1000802_trn.f_num_tarjeta = dc_k_terceros_trn.f_num_tarjeta ) AND l_datos_consistentes;
						--
						-- 2.2.- Si no son iguales entonces actualizar tabla a1000802 con base a a1001331
						IF NOT l_datos_consistentes THEN
							--
							UPDATE a1000802 
							   SET cod_entidad	= dc_k_terceros_trn.f_cod_entidad,
							       cod_oficina	= dc_k_terceros_trn.f_cod_oficina,
								   cta_cte		= dc_k_terceros_trn.f_cta_cte,
								   cta_dc		= dc_k_terceros_trn.f_cta_dc,
								   tip_tarjeta	= dc_k_terceros_trn.f_tip_tarjeta,
								   cod_tarjeta	= dc_k_terceros_trn.f_cod_tarjeta,
								   num_tarjeta	= dc_k_terceros_trn.f_num_tarjeta
							 WHERE cod_cia    = l_cod_cia
							   AND num_poliza = l_num_poliza
							   AND num_spto   = em_k_a1000802_trn.reg.num_spto
							   AND num_riesgo = em_k_a1000802_trn.reg.num_riesgo
							   AND tip_docum  = l_tip_docum
							   AND cod_docum  = l_cod_docum;  
							--
							ptraza(l_traza, 'a', 'Se actualiza Pagador '  || l_tip_docum || '-' || l_cod_docum);   
							--   	   
						END IF;
					ELSE
						ptraza(l_traza,	'a', 'Pagador Inhabilitado. ' || l_tip_docum || '-' || l_cod_docum);
						l_existe_pagador := FALSE;
					END IF;	
					--
				ELSE 
					--
					-- se anula el pagador
					ptraza(l_traza,	'a', 'Se anula el pagador (No existe en a1001331). ' || l_tip_docum || '-' || l_cod_docum);
					l_existe_pagador := FALSE;
					--
				END IF;
				--
			ELSE
				--
				-- 3.- Si los datos no estan en a1000802 entonces poblar la tabla a1000802
				IF l_existe_a1001331 THEN 
					--
					ptraza(l_traza, 'a', 'Se incluye Pagador '  || l_tip_docum || '-' || l_cod_docum);
					--
					em_k_a1000802_trn.reg.cod_cia    		:= l_cod_cia;
					em_k_a1000802_trn.reg.num_poliza 		:= l_num_poliza;
					em_k_a1000802_trn.reg.num_spto   		:= l_num_spto;
					em_k_a1000802_trn.reg.num_riesgo   		:= l_num_riesgo;
					em_k_a1000802_trn.reg.tip_docum  		:= l_tip_docum;
					em_k_a1000802_trn.reg.cod_docum  		:= l_cod_docum;
					em_k_a1000802_trn.reg.nom_domicilio1 	:= dc_k_terceros_trn.f_nom_domicilio1;
					em_k_a1000802_trn.reg.nom_domicilio2	:= dc_k_terceros_trn.f_nom_domicilio2;
					em_k_a1000802_trn.reg.nom_domicilio3	:= dc_k_terceros_trn.f_nom_domicilio3;
					em_k_a1000802_trn.reg.nom_localidad		:= dc_k_terceros_trn.f_nom_localidad;
					em_k_a1000802_trn.reg.cod_pais 			:= dc_k_terceros_trn.f_cod_pais;
					em_k_a1000802_trn.reg.num_apartado		:= dc_k_terceros_trn.f_num_apartado;
					em_k_a1000802_trn.reg.cod_prov			:= dc_k_terceros_trn.f_cod_prov;
					em_k_a1000802_trn.reg.cod_postal		:= dc_k_terceros_trn.f_cod_postal;
					em_k_a1000802_trn.reg.tlf_pais 			:= dc_k_terceros_trn.f_tlf_pais;
					em_k_a1000802_trn.reg.txt_etiqueta1 	:= dc_k_terceros_trn.f_txt_etiqueta1;
					em_k_a1000802_trn.reg.txt_etiqueta2 	:= dc_k_terceros_trn.f_txt_etiqueta2;
					em_k_a1000802_trn.reg.txt_etiqueta3 	:= dc_k_terceros_trn.f_txt_etiqueta3;
					em_k_a1000802_trn.reg.txt_etiqueta4 	:= dc_k_terceros_trn.f_txt_etiqueta4;
					em_k_a1000802_trn.reg.txt_etiqueta5 	:= dc_k_terceros_trn.f_txt_etiqueta5;
					em_k_a1000802_trn.reg.nom_contacto 		:= dc_k_terceros_trn.f_nombre_contacto;
					em_k_a1000802_trn.reg.tip_cargo 		:= dc_k_terceros_trn.f_tip_cargo;
					em_k_a1000802_trn.reg.tlf_zona 			:= dc_k_terceros_trn.f_tlf_zona;
					em_k_a1000802_trn.reg.tlf_numero 		:= dc_k_terceros_trn.f_tlf_numero;
					em_k_a1000802_trn.reg.fax_numero 		:= dc_k_terceros_trn.f_fax_numero;
					em_k_a1000802_trn.reg.email 			:= dc_k_terceros_trn.f_email;
					em_k_a1000802_trn.reg.cod_entidad 		:= dc_k_terceros_trn.f_cod_entidad;
					em_k_a1000802_trn.reg.cod_oficina 		:= dc_k_terceros_trn.f_cod_oficina;
					em_k_a1000802_trn.reg.cta_cte 			:= dc_k_terceros_trn.f_cta_cte;
					em_k_a1000802_trn.reg.cta_dc			:= dc_k_terceros_trn.f_cta_dc;
					em_k_a1000802_trn.reg.cod_estado		:= dc_k_terceros_trn.f_cod_estado;
					em_k_a1000802_trn.reg.txt_email			:= dc_k_terceros_trn.f_txt_email;
					em_k_a1000802_trn.reg.obs_asegurado		:= dc_k_terceros_trn.f_obs_asegurado;
					em_k_a1000802_trn.reg.cod_pais_etiqueta	:= dc_k_terceros_trn.f_cod_pais_etiqueta;
					em_k_a1000802_trn.reg.cod_prov_etiqueta	:= dc_k_terceros_trn.f_cod_prov_etiqueta;
					em_k_a1000802_trn.reg.cod_localidad		:= dc_k_terceros_trn.f_cod_localidad;
					em_k_a1000802_trn.reg.tip_tarjeta		:= dc_k_terceros_trn.f_tip_tarjeta;
					em_k_a1000802_trn.reg.cod_tarjeta		:= dc_k_terceros_trn.f_cod_tarjeta;
					em_k_a1000802_trn.reg.num_tarjeta		:= dc_k_terceros_trn.f_num_tarjeta;
					em_k_a1000802_trn.reg.fec_vcto_tarjeta	:= dc_k_terceros_trn.f_fec_vcto_tarjeta;
					em_k_a1000802_trn.reg.cod_compensacion	:= dc_k_terceros_trn.f_cod_compensacion;
					em_k_a1000802_trn.reg.tip_etiqueta		:= dc_k_terceros_trn.f_tip_etiqueta;
					em_k_a1000802_trn.reg.num_secu_cta		:= NULL;
					em_k_a1000802_trn.reg.atr_domicilio1	:= dc_k_terceros_trn.f_atr_domicilio1;
					em_k_a1000802_trn.reg.atr_domicilio2	:= dc_k_terceros_trn.f_atr_domicilio2;
					em_k_a1000802_trn.reg.atr_domicilio3	:= dc_k_terceros_trn.f_atr_domicilio3;
					em_k_a1000802_trn.reg.atr_domicilio4	:= dc_k_terceros_trn.f_atr_domicilio4;
					em_k_a1000802_trn.reg.atr_domicilio5	:= dc_k_terceros_trn.f_atr_domicilio5;
					em_k_a1000802_trn.reg.anx_domicilio		:= dc_k_terceros_trn.f_anx_domicilio;
					em_k_a1000802_trn.reg.ext_cod_postal	:= dc_k_terceros_trn.f_ext_cod_postal;
					em_k_a1000802_trn.reg.tlf_extension		:= dc_k_terceros_trn.f_tlf_extension;
					em_k_a1000802_trn.reg.nom_empresa_com	:= dc_k_terceros_trn.f_nom_empresa_com;
					--
					em_k_a1000802_trn.reg.cod_estado_etiqueta 		:= dc_k_terceros_trn.f_cod_estado_etiqueta;
					em_k_a1000802_trn.reg.cod_postal_etiqueta 		:= dc_k_terceros_trn.f_cod_postal_etiqueta;
					em_k_a1000802_trn.reg.num_apartado_etiqueta		:= dc_k_terceros_trn.f_num_apartado_etiqueta;
					em_k_a1000802_trn.reg.cod_localidad_etiqueta	:= dc_k_terceros_trn.f_cod_localidad_etiqueta;
					em_k_a1000802_trn.reg.nom_localidad_etiqueta	:= dc_k_terceros_trn.f_nom_localidad_etiqueta;
					em_k_a1000802_trn.reg.atr_domicilio1_com		:= dc_k_terceros_trn.f_atr_domicilio1_com;
					em_k_a1000802_trn.reg.atr_domicilio2_com		:= dc_k_terceros_trn.f_atr_domicilio2_com;
					em_k_a1000802_trn.reg.atr_domicilio3_com		:= dc_k_terceros_trn.f_atr_domicilio3_com;
					em_k_a1000802_trn.reg.atr_domicilio4_com		:= dc_k_terceros_trn.f_atr_domicilio4_com;
					em_k_a1000802_trn.reg.atr_domicilio5_com		:= dc_k_terceros_trn.f_atr_domicilio5_com;
					em_k_a1000802_trn.reg.anx_domicilio_com			:= dc_k_terceros_trn.f_anx_domicilio_com;
					em_k_a1000802_trn.reg.ext_cod_postal_com		:= dc_k_terceros_trn.f_ext_cod_postal_com;
					em_k_a1000802_trn.reg.tlf_extension_com			:= dc_k_terceros_trn.f_tlf_extension_com;
					em_k_a1000802_trn.reg.ext_cod_postal_etiqueta	:= dc_k_terceros_trn.f_ext_cod_postal_etiqueta;
					em_k_a1000802_trn.reg.nom_titular_cta			:= dc_k_terceros_trn.f_nom_titular_cta;
					em_k_a1000802_trn.reg.apellido_contacto			:= dc_k_terceros_trn.f_apellido_contacto;
					em_k_a1000802_trn.reg.tip_docum_contacto		:= dc_k_terceros_trn.f_tip_docum_contacto;
					em_k_a1000802_trn.reg.cod_docum_contacto		:= dc_k_terceros_trn.f_cod_docum_contacto;
					em_k_a1000802_trn.reg.cod_nacionalidad_contacto	:= dc_k_terceros_trn.f_cod_nacionalidad_contacto;
					--
					em_k_a1000802_trn.reg.mca_domicilio_comprobado	:= 'N';
					em_k_a1000802_trn.reg.mca_tlf_numero_comprobado	:= 'N';
					em_k_a1000802_trn.reg.mca_fax_numero_comprobado	:= 'N';
					em_k_a1000802_trn.reg.mca_email_comprobado		:= 'N';
					em_k_a1000802_trn.reg.mca_busca_comprobado		:= 'N';
					em_k_a1000802_trn.reg.mca_txt_email_comprobado	:= 'N';
					em_k_a1000802_trn.reg.mca_email_com_comprobado	:= 'N';
					em_k_a1000802_trn.reg.mca_tlf_movil_comprobado	:= 'N';
					--
					em_k_a1000802_trn.reg.mca_domicilio_com_comprobado	:= 'N';
					em_k_a1000802_trn.reg.mca_domicilio_etiq_comprobado	:= 'N';
					em_k_a1000802_trn.reg.mca_tlf_numero_com_comprobado	:= 'N';
					em_k_a1000802_trn.reg.mca_fax_numero_com_comprobado	:= 'N';
					--
					em_k_a1000802_trn.p_inserta( p_reg => em_k_a1000802_trn.reg );
					--
				ELSE
					--
					-- se anula el pagador
					ptraza(l_traza,	'a', 'Se anula el pagador (No existe en a1001331). ' || l_tip_docum || '-' || l_cod_docum);
					l_existe_pagador := FALSE;	
					--
				END IF;
				--	
			END IF; 
			--
		END IF;
		--
		ptraza(l_traza, 'a', 'Fin Analisis del Pagador');
		--
		EXCEPTION 
			WHEN OTHERS THEN
                ptraza( l_traza, 'a', 'p_procesa_pagador => ' || SQLERRM );
		--		
	END p_procesa_pagador;  
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
	-- se procesa y analiza los datos del pagador
	p_procesa_pagador;
	--
	IF l_existe_pagador THEN
		--
		ptraza('em_p_cambia_gestor_pagador', 'a', 'PROCESANDO..!');
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
			-- analiza el codigo numero de tarjeta
			pp_analisis_tarjeta;
			--
			-- si existe un codigo de gestor derivado del analisis entonces se aplica
			IF l_cod_gestor_ana IS NOT NULL THEN 
			  	l_cod_gestor := l_cod_gestor_ana;
			ELSE	  
				IF l_cod_entidad IS NOT NULL THEN
					l_cod_gestor := l_cod_entidad || l_cod_oficina;
				ELSE
					l_cod_gestor := '01020000'; -- OJO
				END IF;
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
