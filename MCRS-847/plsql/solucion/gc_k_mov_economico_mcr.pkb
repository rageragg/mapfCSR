create or replace PACKAGE BODY gc_k_mov_economico_mcr AS
	--
	-- variable globales
	g_cod_cia       				a1001331.cod_cia%type;
	g_tip_docum     				a1001331.tip_docum%type;
	g_cod_docum     				a1001331.cod_docum%TYPE;
	g_nom_completo					VARCHAR2(255);
	g_cod_subproducto				VARCHAR2(50);
	g_reg 							typ_reg_me;
	--
	g_tabla_list_mv    			typ_tab_lista_me := typ_tab_lista_me();
	-- manejo de error
	g_error_text    varchar2(8000);
	g_error_code    varchar2(20);
	g_hay_error     boolean := false;
	--
  	-- establecer el error
	PROCEDURE pp_establecer_error IS 
	BEGIN 
		--
		g_error_text    := sqlerrm;
		g_error_code    := sqlcode;
		g_hay_error     := true;
		dbms_output.put_line(g_error_text);
        --
	END pp_establecer_error;
    --
    -- tratar el json
    PROCEDURE p_tratar_json( p_json VARCHAR2 ) IS 
    BEGIN
        --
        g_cod_cia   := json_value(p_json, '$.codcia' );
        g_tip_docum := json_value(p_json, '$.tipdocum' );
        g_cod_docum := json_value(p_json, '$.coddocum' );
        --
		EXCEPTION
			WHEN OTHERS THEN
				pp_establecer_error;
		--
    END p_tratar_json;
	--
	-- busque de datos catalogos
	FUNCTION fp_desc_catalogo( p_campo VARCHAR2, p_valor VARCHAR2, p_idioma VARCHAR2 ) RETURN VARCHAR2 IS 
		-- 
		l_nom_valor g1010031.nom_valor%TYPE;
		--
	BEGIN 
		--
		SELECT nom_valor 
		  INTO l_nom_valor
		  FROM g1010031 
		 WHERE cod_campo  = p_campo 
		   AND cod_valor  = p_valor
		   AND cod_idioma = 'ES';
		-- 
		RETURN l_nom_valor;
		--
		EXCEPTION 
			WHEN OTHERS THEN 
				RETURN NULL;
		--		   
	END fp_desc_catalogo;
	--
	-- agregar registro
	PROCEDURE p_agregar_registro( p_reg typ_reg_me ) IS 
	BEGIN 
		--
        g_tabla_list_mv.extend;
        g_tabla_list_mv(g_tabla_list_mv.count) := p_reg;
		--
		EXCEPTION
			WHEN OTHERS THEN
				pp_establecer_error;
		--			 
	END p_agregar_registro;
	--
	-- agregar registro
	PROCEDURE p_eliminar_registros IS 
	BEGIN 
		--
        g_tabla_list_mv.delete;
		--
		EXCEPTION
			WHEN OTHERS THEN
				pp_establecer_error;
		--			 
	END p_eliminar_registros;
    --
    -- determina la modalidad
    FUNCTION f_modalidad( p_num_poliza a2000020.num_poliza%TYPE ) RETURN INTEGER IS 
        --
        l_modalidad INTEGER;
        --
    BEGIN
		--
		SELECT CAST( VAL_CAMPO AS INTEGER )
		  INTO l_modalidad
          FROM a2000020
         WHERE cod_cia      = g_cod_cia
           AND num_poliza   = p_num_poliza
		   AND num_spto     = 0
           AND cod_campo    = 'COD_MODALIDAD';
		--
		RETURN l_modalidad;
		--
		EXCEPTION
			WHEN NO_DATA_FOUND THEN 
			     RETURN NULL;
			WHEN OTHERS THEN
				pp_establecer_error;
		--
    END f_modalidad;
	--
	-- datos de tesoreria
	PROCEDURE p_datos_tesoreria( p_cod_ramo   				a2000030.cod_ramo%TYPE,
	                             p_num_bloque 				a5020301.num_bloque_tes%TYPE,
	                             p_fec_movimiento 			OUT DATE,
								 p_mon_creditos				OUT NUMBER,
								 p_mon_debitos				OUT NUMBER,
								 p_cod_usuario_registo		OUT VARCHAR2,
								 p_fec_registro         	OUT DATE,
								 p_des_nombre_originario	OUT VARCHAR2,
								 p_des_nombre_beneficiario	OUT VARCHAR2,
								 p_num_cuenta_origen		OUT VARCHAR2,
								 p_num_cuenta_destino		OUT VARCHAR2,
								 p_cod_banco_origen			OUT VARCHAR2,
								 p_cod_banco_destino        OUT VARCHAR2,
								 p_cod_canal                OUT VARCHAR2,
								 p_des_canal                OUT VARCHAR2,
								 p_tip_pago					OUT VARCHAR2,
								 p_origen_transaccion       IN VARCHAR2 DEFAULT 'RECIBO',
								 p_num_sini					IN a7000900.num_sini%TYPE
								) IS 
		--
		l_tip_pago	CHAR(3);						
		--
		-- datos de tesoreria
		CURSOR c_tesoreria IS 
			SELECT * 
	          FROM v5021600_1900
	         WHERE cod_cia        = g_cod_cia
	           AND cod_ramo       = p_cod_ramo
	           AND tip_docum      = g_tip_docum
	           AND cod_docum      = g_cod_docum
	           AND num_bloque_tes = p_num_bloque
			   AND p_origen_transaccion = 'RECIBO'
			UNION 
			SELECT * 
	          FROM v5021600_1900
	         WHERE cod_cia        		= g_cod_cia
	           AND num_bloque_tes 		= p_num_bloque
			   AND num_sini       		= p_num_sini
			   AND p_origen_transaccion = 'SINIESTRO';
		--
		-- datos de	traspasos de tesoreria
		CURSOR c_traspasos( p_fec_asto a5020034.fec_asto%TYPE,
		                    p_num_asto a5020034.num_asto%TYPE 
		                  ) IS 
			SELECT *
			  FROM a5020034
			 WHERE cod_cia 					= g_cod_cia
			   AND fec_asto     			= p_fec_asto  
			   AND num_asto     			= p_num_asto   
			   AND num_bloque_tes_origen	= p_num_bloque;
		--
		l_reg_tes c_tesoreria%ROWTYPE;
		l_reg_trs c_traspasos%ROWTYPE;
		--
	BEGIN 
		--
		p_mon_creditos := 0;
		p_mon_debitos  := 0;
		--
		OPEN c_tesoreria;
		FETCH c_tesoreria INTO l_reg_tes;
		IF c_tesoreria%FOUND THEN
			--
			p_fec_movimiento 		:= l_reg_tes.fec_asto;
			p_cod_usuario_registo	:= l_reg_tes.cod_cajero;
			p_fec_registro          := l_reg_tes.fec_actu;
			p_des_nombre_originario	:= l_reg_tes.nom_movim;
			p_cod_canal				:= l_reg_tes.tip_actu;
			p_des_canal             := fp_desc_catalogo( 'TIP_ACTU', p_cod_canal, 'ES' ); 
			--
			IF l_reg_tes.tip_imp = 'H' THEN 
				p_mon_creditos := l_reg_tes.imp_mon_pais;
			ELSIF l_reg_tes.tip_imp = 'D' THEN
			 	p_mon_debitos := l_reg_tes.imp_mon_pais;
			END IF;
			--
			IF l_reg_tes.num_cheque IS NOT NULL THEN
			    l_tip_pago		     := 'CHQ';
				p_cod_banco_origen   := l_reg_tes.cod_entidad_cheque;
			ELSIF l_reg_tes.num_tarjeta IS NOT NULL THEN 
			    l_tip_pago		     := 'TAR';
				p_num_cuenta_origen := l_reg_tes.num_tarjeta; 
			ELSE
				p_num_cuenta_origen := NULL;	
			END IF;	
			p_cod_banco_destino	 := l_reg_tes.cod_entidad;
			p_num_cuenta_destino := l_reg_tes.cod_cta_simp;
			--
		END IF;
		CLOSE c_tesoreria; 
		--
		OPEN c_traspasos(l_reg_tes.fec_asto, l_reg_tes.num_asto);
		FETCH c_traspasos INTO l_reg_trs;
		IF c_traspasos%FOUND THEN
			--
			IF l_tip_pago = 'CHQ' THEN
				p_num_cuenta_origen  	  := nvl( p_num_cuenta_origen, l_reg_trs.cta_cte_cheque ); 
				p_des_nombre_beneficiario := nvl( p_des_nombre_beneficiario, l_reg_trs.nom_tercero_giro );
			ELSIF l_tip_pago = 'TAR' THEN
				p_num_cuenta_origen := nvl( p_num_cuenta_origen, l_reg_trs.num_tarjeta );
			END IF;	
			p_num_cuenta_destino := nvl( p_num_cuenta_destino, l_reg_trs.cod_cta_simp ); 
			--
		END IF;
		CLOSE c_traspasos;
		--
		p_tip_pago := l_tip_pago;
		--
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				RETURN;
			WHEN OTHERS THEN
				pp_establecer_error;
		--
	END p_datos_tesoreria;	
    --
    -- informacion del asegurado
    FUNCTION f_datos_asegurado RETURN VARCHAR2 IS
      --
      l_nom_tercero VARCHAR2(256);
      --
      CURSOR c_dato_asegurado IS 
        SELECT b.nom_tercero||' '||b.ape1_tercero||' '||b.ape2_tercero
          FROM a1001399 b
        WHERE b.cod_cia   = g_cod_cia
          AND b.tip_docum = g_tip_docum
          AND b.cod_docum = g_cod_docum;
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
    END f_datos_asegurado;									
    --
	-- agregamos los recibos asociadas al tercero
	PROCEDURE p_agregar_recibos(  	p_cod_ramo   a2000030.cod_ramo%type,
		            				p_num_poliza a2990700.num_poliza%type,
                                	p_num_spto   a2990700.num_spto%type,
									p_tip_spto   a2000030.tip_spto%type  
		                        )	IS  
		--
		l_reg 					typ_reg_me;
		l_fec_movimiento 			DATE;
		l_mon_creditos				NUMBER;
		l_mon_debitos				NUMBER;
		l_cod_usuario_registo		VARCHAR2(8);
		l_fec_registro				DATE;
		l_des_nombre_originario		VARCHAR2(255);
		l_des_nombre_beneficiario	VARCHAR2(255);
		l_cod_banco_origen			VARCHAR2(5);
		l_cod_banco_destino			VARCHAR2(5);
		l_num_cuenta_origen			VARCHAR2(22);
		l_num_cuenta_destino		VARCHAR2(22);
		l_cod_canal                 VARCHAR2(2);
		l_des_canal                 VARCHAR2(50);
		l_tip_pago					CHAR(3);
		--
		-- seleccionamos los recibos
		CURSOR c_recibos IS
			SELECT * 
			  FROM a2990700
			 WHERE cod_cia    = g_cod_cia
		  	   AND num_poliza = p_num_poliza
			   AND num_spto   = p_num_spto
			ORDER BY num_recibo;
		--
		-- historicos de recibos
		CURSOR c_historico( p_num_recibo a5020301.num_recibo%type ) IS
			SELECT * 
			  FROM a5020301
		     WHERE cod_cia    = g_cod_cia
			   AND num_poliza = p_num_poliza
			   AND num_spto   = p_num_spto
			   AND num_recibo = p_num_recibo
			   AND tip_situacion = 'CT'
			   AND num_bloque_tes is not null
		    ORDER BY num_recibo;
		-- 
	BEGIN 
		--
		l_reg.cod_tipo_identificacion     := g_tip_docum;
    	l_reg.num_identificacion          := g_cod_docum;
		l_reg.nom_completo                := g_nom_completo; 
		l_reg.cod_tipo_producto           := p_cod_ramo;
		l_reg.num_referencia              := p_num_poliza ||'-'||to_char(p_num_spto);
		l_reg.cod_subproducto             := g_cod_subproducto;
		l_reg.cod_tipo_movimiento		  := p_tip_spto;
		--
		FOR v IN c_recibos LOOP
			--
			l_reg.cod_moneda  			:= v.cod_mon;
			l_reg.cod_moneda_producto	:= v.cod_mon;
			l_reg.cod_oficina			:= v.cod_nivel3;
			--
			FOR h IN c_historico( v.num_recibo ) LOOP
				--
			    l_reg.num_identificacion_originario := h.num_bloque_tes;
				l_reg.ind_origen_transaccion        := 'RECIBO';
				l_reg.mon_tipo_cambio        		:= h.val_cambio;
				--
				-- datos de tesoreria 
				p_datos_tesoreria( p_cod_ramo, 
				                   h.num_bloque_tes, 
								   l_fec_movimiento, 
								   l_mon_creditos, 
								   l_mon_debitos,
								   l_cod_usuario_registo,
								   l_fec_registro,
								   l_des_nombre_originario,
								   l_des_nombre_beneficiario,
								   l_num_cuenta_origen,
								   l_num_cuenta_destino,
								   l_cod_banco_origen,
								   l_cod_banco_destino,
								   l_cod_canal,
								   l_des_canal,
								   l_tip_pago,
								   'RECIBO',
								   NULL
								 );
				l_reg.fec_movimiento 			:= l_fec_movimiento;
				l_reg.mon_creditos   			:= l_mon_creditos;
				l_reg.mon_debitos    			:= l_mon_debitos;
				l_reg.cod_usuario_registo		:= l_cod_usuario_registo;
				l_reg.fec_registro 				:= l_fec_registro;
				l_reg.des_nombre_originario     := l_des_nombre_originario;
				l_reg.des_nombre_beneficiario	:= l_des_nombre_beneficiario;
				l_reg.cod_banco_origen			:= l_cod_banco_origen;
				l_reg.cod_banco_destino			:= l_cod_banco_destino;
				l_reg.num_cuenta_origen			:= l_num_cuenta_origen;
				l_REG.num_cuenta_destino		:= l_num_cuenta_destino;
				l_reg.cod_canal					:= l_cod_canal;
				l_reg.des_canal					:= l_des_canal;
				l_reg.tip_pago					:= l_tip_pago;
				--					
				p_agregar_registro( l_reg );
				--
			END LOOP;
			--
    	END LOOP;
		--
		EXCEPTION
			WHEN OTHERS THEN
				pp_establecer_error;	
		--
	END p_agregar_recibos;
	--
	-- agregamos siniestros
	PROCEDURE p_agregar_siniestros(	p_cod_ramo   a2000030.cod_ramo%type,
		            				p_num_poliza a2990700.num_poliza%type,
                                	p_num_spto   a2990700.num_spto%type,
									p_tip_spto   a2000030.tip_spto%type 
								  ) IS 
		--
		l_reg 						typ_reg_me;
		l_fec_movimiento 			DATE;
		l_mon_creditos				NUMBER;
		l_mon_debitos				NUMBER;
		l_cod_usuario_registo		VARCHAR2(8);
		l_fec_registro				DATE;
		l_des_nombre_originario		VARCHAR2(255);
		l_des_nombre_beneficiario	VARCHAR2(255);
		l_cod_banco_origen			VARCHAR2(5);
		l_cod_banco_destino			VARCHAR2(5);
		l_num_cuenta_origen			VARCHAR2(22);
		l_num_cuenta_destino		VARCHAR2(22);
		l_cod_canal                 VARCHAR2(2);
		l_des_canal                 VARCHAR2(50);
		l_tip_pago					CHAR(3);
		--
		-- seleccionamos las polizas con siniestros
		CURSOR c_siniestros IS 
			SELECT a.*,
                   b.num_ord_pago 
			  FROM a7000900 a,
			       a3001700 b  
			 WHERE b.cod_cia    = a.cod_cia
			   AND b.cod_ramo   = a.cod_ramo
			   AND b.num_sini   = a.num_sini
			   AND a.cod_cia    = g_cod_cia
			   AND a.cod_ramo   = p_cod_ramo
			   AND a.num_poliza = p_num_poliza
			   AND a.num_spto   = p_num_spto;
		--
		-- ordenes de pago de cada siniestro
		CURSOR c_ord_pagos( p_num_ord_pago a5021604.num_ord_pago%TYPE ) IS
			SELECT * 
  			  FROM a5021604
 			 WHERE cod_cia      = g_cod_cia
			   AND num_ord_pago = p_num_ord_pago
               AND tip_estado   = 'T';
		--
		-- detalles de pagos (historial de cheques)
		CURSOR c_cheques( p_num_clave a5021606.num_clave%TYPE ) IS 
			SELECT *
			  FROM a5021606	
			 WHERE cod_cia 		= g_cod_cia 
			   AND num_clave    = p_num_clave;	   
		--
    BEGIN 
		--
		l_reg.cod_tipo_identificacion     := g_tip_docum;
    	l_reg.num_identificacion          := g_cod_docum;
		l_reg.nom_completo                := g_nom_completo; 
		l_reg.cod_tipo_producto           := p_cod_ramo;
		l_reg.num_referencia              := p_num_poliza ||'-'||to_char(p_num_spto);
		l_reg.cod_subproducto             := g_cod_subproducto;
		l_reg.cod_tipo_movimiento		  := p_tip_spto;
		--
		FOR r_sini IN c_siniestros LOOP  
			--
			FOR r_ord IN c_ord_pagos( r_sini.num_ord_pago ) LOOP
				--
				FOR r_chq IN c_cheques( r_ord.num_clave ) LOOP
					--
					l_reg.cod_moneda  					:= r_chq.cod_mon_pago;
					l_reg.cod_moneda_producto			:= r_chq.cod_mon_pago;
					l_reg.cod_oficina					:= r_chq.cod_nivel3_pago; 
					l_reg.num_identificacion_originario := r_chq.num_bloque_tes;
					l_reg.ind_origen_transaccion        := 'SINIESTRO';
					l_reg.mon_tipo_cambio        		:= r_chq.val_cambio;
					--
					-- datos de tesoreria 
					p_datos_tesoreria( 	p_cod_ramo, 
										r_chq.num_bloque_tes, 
										l_fec_movimiento, 
										l_mon_creditos, 
										l_mon_debitos,
										l_cod_usuario_registo,
										l_fec_registro,
										l_des_nombre_originario,
										l_des_nombre_beneficiario,
										l_num_cuenta_origen,
										l_num_cuenta_destino,
										l_cod_banco_origen,
										l_cod_banco_destino,
										l_cod_canal,
										l_des_canal,
										l_tip_pago,
										'SINIESTRO',
										r_sini.num_sini
									  );
					l_reg.fec_movimiento 			:= l_fec_movimiento;
					l_reg.mon_creditos   			:= l_mon_creditos;
					l_reg.mon_debitos    			:= l_mon_debitos;
					l_reg.cod_usuario_registo		:= l_cod_usuario_registo;
					l_reg.fec_registro 				:= l_fec_registro;
					l_reg.des_nombre_originario     := l_des_nombre_originario;
					l_reg.des_nombre_beneficiario	:= l_des_nombre_beneficiario;
					l_reg.cod_banco_origen			:= l_cod_banco_origen;
					l_reg.cod_banco_destino			:= l_cod_banco_destino;
					l_reg.num_cuenta_origen			:= l_num_cuenta_origen;
					l_REG.num_cuenta_destino		:= l_num_cuenta_destino;
					l_reg.cod_canal					:= l_cod_canal;
					l_reg.des_canal					:= l_des_canal;
					l_reg.tip_pago					:= 'XXX';
					--					
					p_agregar_registro( l_reg );
					--
				END LOOP;
				-- 
			END LOOP;
			--
		END LOOP;
		--
		EXCEPTION
			WHEN OTHERS THEN
				pp_establecer_error;	
		--		
	END p_agregar_siniestros;								  
	--
	-- cargamos las polizas y las colocamos en un vector
	PROCEDURE p_agregar_polizas IS
		--
		-- cursor polizas asociadas al tomador
		CURSOR c_polizas is 
		SELECT DISTINCT cod_ramo, num_poliza, num_spto, tip_spto
			FROM a2000030 
		   WHERE cod_cia    = g_cod_cia
		 	 AND tip_docum  = g_tip_docum
			 AND cod_docum  = g_cod_docum
			 AND tip_spto  != 'SM'
			 AND mca_poliza_anulada = 'N'
		 ORDER BY num_poliza, num_spto; 
		--   
	BEGIN 
		--
		FOR v IN c_polizas LOOP
			-- 
			-- agreamos al vector de polizas
		    g_cod_subproducto	:= f_modalidad( p_num_poliza => v.num_poliza );
			p_agregar_recibos( 	p_cod_ramo   => v.cod_ramo,
								p_num_poliza => v.num_poliza,
								p_num_spto   => v.num_spto,
								p_tip_spto   => v.tip_spto
							);
			-- 				
			p_agregar_siniestros( p_cod_ramo   => v.cod_ramo,
								  p_num_poliza => v.num_poliza,
								  p_num_spto   => v.num_spto,
								  p_tip_spto   => v.tip_spto
								);				
			--									
		END LOOP;
			--
		EXCEPTION
			WHEN OTHERS THEN
				pp_establecer_error;	
		--   
	END p_agregar_polizas;
	--
	-- lista de movimientos economicos
  	FUNCTION f_list_mov_economico(  p_cod_cia       IN a1001331.cod_cia%type,
                                  	p_tip_docum     IN a1001331.tip_docum%type,
                                  	p_cod_docum     IN a1001331.cod_docum%TYPE
                                ) RETURN typ_tab_lista_me PIPELINED IS 

	BEGIN 
		--
		p_eliminar_registros;
	  	--
		g_cod_cia    		:= p_cod_cia;
		g_tip_docum  		:= p_tip_docum;
		g_cod_docum  		:= p_cod_docum;
		g_nom_completo		:= f_datos_asegurado;
		--
		p_agregar_polizas;
		--
		FOR i IN 1..g_tabla_list_mv.count LOOP 
      		PIPE ROW( g_tabla_list_mv(i) );
    	END LOOP;
    	--
    	RETURN;
		--
		EXCEPTION
			WHEN OTHERS THEN 
				-- pp_establecer_error;
				null;
		--
	END f_list_mov_economico;	
	--
	-- lista de movimientos economicos
  	FUNCTION f_list_mov_economico( p_json VARCHAR2 ) RETURN typ_tab_lista_me PIPELINED IS 
	BEGIN 
		--
        p_tratar_json(p_json);
		--
		p_agregar_polizas;
		--
		FOR i IN 1..g_tabla_list_mv.count LOOP 
      		PIPE ROW(g_tabla_list_mv(i));
    	END LOOP;
    	--
    	RETURN;
		--
		EXCEPTION
			WHEN OTHERS THEN 
				-- pp_establecer_error;
				null;
		--
	END f_list_mov_economico;															
	--
end gc_k_mov_economico_mcr;