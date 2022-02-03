create or replace PACKAGE BODY gc_k_mov_economico_mcr AS
	--
	-- variable globales
	g_cod_cia       				a1001331.cod_cia%type;
	g_tip_docum     				a1001331.tip_docum%type;
	g_cod_docum     				a1001331.cod_docum%TYPE;
	g_fecha_desde	                DATE;
	g_fecha_hasta					DATE;
	g_nom_completo					VARCHAR2(255);
	g_varios_clientes               BOOLEAN;
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
        g_cod_cia   	:= json_value(p_json, '$.codcia' );
        g_tip_docum 	:= json_value(p_json, '$.tipdocum' );
        g_cod_docum 	:= json_value(p_json, '$.coddocum' );
		g_fecha_desde 	:= json_value(p_json, '$.fecdesde' );
		g_fecha_hasta 	:= json_value(p_json, '$.fechasta' );
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
			   dbms_output.put_line(p_reg.num_referencia);
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
    -- informacion del asegurado
    FUNCTION f_datos_asegurado( p_tip_docum a1001399.tip_docum%TYPE,
	                            p_cod_docum a1001399.cod_docum%TYPE
	                          ) RETURN VARCHAR2 IS
      --
      l_nom_tercero VARCHAR2(256);
      --
      CURSOR c_dato_asegurado IS 
        SELECT b.nom_tercero||' '||b.ape1_tercero||' '||b.ape2_tercero
          FROM a1001399 b
        WHERE b.cod_cia   = g_cod_cia
          AND b.tip_docum = p_tip_docum
          AND b.cod_docum = p_cod_docum;
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
	PROCEDURE p_agregar_recibos(  	p_cod_ramo   a2000030.cod_ramo%TYPE,
		            				p_num_poliza a2990700.num_poliza%TYPE,
                                	p_num_spto   a2990700.num_spto%TYPE,
									p_tip_spto   a2000030.tip_spto%TYPE  
		                        )	IS  
		--
		l_reg 						typ_reg_me;
		l_tip_pago					CHAR(3);
		--
		-- seleccionamos los recibos
		CURSOR c_recibos IS
			SELECT * 
			  FROM a2990700
			 WHERE cod_cia       = g_cod_cia
		  	   AND num_poliza    = p_num_poliza
			   AND num_spto      = p_num_spto
			   AND num_apli      = 0
			   AND num_spto_apli = 0 
			   AND tip_situacion = 'CT'
			   AND fec_efec_recibo >= g_fecha_desde 
			   AND fec_efec_recibo <= g_fecha_hasta
			ORDER BY num_recibo;
		--
		-- historicos de recibos
		CURSOR c_historico( p_num_recibo a5020301.num_recibo%TYPE, 
		                    p_num_cuota  a5020301.num_cuota%TYPE
		                  ) IS
			SELECT * 
			  FROM a5020301
		     WHERE cod_cia       = g_cod_cia
			   AND num_poliza    = p_num_poliza
			   AND num_spto      = p_num_spto
			   AND num_apli      = 0
			   AND num_spto_apli = 0
			   AND num_cuota     = p_num_cuota
			   AND num_recibo    = p_num_recibo
			   AND tip_situacion = 'CT'
			   AND num_bloque_tes is not null
			   AND fec_efec_recibo >= g_fecha_desde 
			   AND fec_efec_recibo <= g_fecha_hasta
		    ORDER BY num_recibo;
		--
		-- tesoreria
		CURSOR c_tesoreria( p_num_bloque a5020301.num_bloque_tes%TYPE ) IS 
			SELECT *  
	          FROM v5021600_1900 
	         WHERE cod_cia        = g_cod_cia
			--    AND  ( fec_asto >= nvl( g_fecha_desde, fec_asto ) 
			--           AND  
			-- 		  fec_asto <= nvl( g_fecha_hasta, fec_asto )  
			-- 		)
	           AND num_bloque_tes = p_num_bloque;	
		--
		-- datos de	traspasos de tesoreria
		CURSOR c_traspasos( p_num_bloque a5020034.num_bloque_tes_origen%TYPE,
		                    p_fec_asto a5020034.fec_asto%TYPE,
		                    p_num_asto a5020034.num_asto%TYPE 
		                  ) IS 
			SELECT *
			  FROM a5020034
			 WHERE cod_cia 					= g_cod_cia
			   AND fec_asto     			= p_fec_asto  
			   AND num_asto     			= p_num_asto   
			   AND num_bloque_tes_origen	= p_num_bloque; 
		--
		l_reg_trs c_traspasos%ROWTYPE;
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
			FOR h IN c_historico( v.num_recibo, v.num_cuota ) LOOP
				--
			    l_reg.num_identificacion_originario := h.num_bloque_tes;
				l_reg.ind_origen_transaccion        := 'RECIBO';
				l_reg.mon_tipo_cambio        		:= h.val_cambio;
				--
				FOR t IN c_tesoreria( h.num_bloque_tes ) LOOP 
					--
					l_reg.fec_movimiento 			:= t.fec_asto;
					l_reg.cod_usuario_registo		:= t.cod_cajero;
					l_reg.fec_registro 				:= t.fec_actu;
					l_reg.des_nombre_originario     := t.nom_movim;
					l_reg.cod_banco_destino	 		:= t.cod_entidad;
					l_reg.num_cuenta_destino		:= t.cod_cta_simp;
					l_reg.cod_canal				    := t.tip_actu;
					l_reg.des_canal                 := fp_desc_catalogo( 'TIP_ACTU', l_reg.cod_canal, 'ES' ); 
					--
					IF t.tip_imp = 'H' THEN 
						l_reg.mon_creditos := t.imp_mon_pais;
						l_reg.mon_debitos  := 0;
					ELSIF t.tip_imp = 'D' THEN
			 			l_reg.mon_debitos 	:= t.imp_mon_pais;
						l_reg.mon_creditos 	:= 0; 
					END IF;
					--
					IF t.num_cheque IS NOT NULL THEN
			    		l_tip_pago		     := 'CHQ';
						l_reg.cod_banco_origen   := t.cod_entidad_cheque;
					ELSIF t.num_tarjeta IS NOT NULL THEN 
			    		l_tip_pago		     := 'TAR';
						l_reg.num_cuenta_origen := t.num_tarjeta; 
					ELSE
						l_reg.num_cuenta_origen := NULL;	
					END IF;	
					--
					OPEN c_traspasos( t.num_bloque_tes, t.fec_asto, t.num_asto);
					FETCH c_traspasos INTO l_reg_trs;
					IF c_traspasos%FOUND THEN
						--
						IF l_tip_pago = 'CHQ' THEN
							l_reg.num_cuenta_origen  	  := nvl( l_reg.num_cuenta_origen, l_reg_trs.cta_cte_cheque ); 
							l_reg.des_nombre_beneficiario := nvl( l_reg.des_nombre_beneficiario, l_reg_trs.nom_tercero_giro );
						ELSIF l_tip_pago = 'TAR' THEN
							l_reg.num_cuenta_origen := nvl( l_reg.num_cuenta_origen, l_reg_trs.num_tarjeta );
						END IF;	
						l_reg.num_cuenta_destino := nvl( l_reg.num_cuenta_destino, l_reg_trs.cod_cta_simp ); 
						--
					END IF;
					CLOSE c_traspasos;
					l_reg.tip_pago	:= l_tip_pago;
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
		-- tesoreria
		CURSOR c_tesoreria( p_num_bloque a5020301.num_bloque_tes%TYPE ) IS 
			SELECT * 
	          FROM v5021600_1900 
	         WHERE cod_cia        = g_cod_cia
			   AND  ( fec_asto >= nvl( g_fecha_desde, fec_asto ) 
			          AND  
					  fec_asto <= nvl( g_fecha_hasta, fec_asto )  
					) 
	           AND num_bloque_tes = p_num_bloque;	
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
					FOR t IN c_tesoreria(r_chq.num_bloque_tes) LOOP 
						--
						l_reg.fec_movimiento 			:= t.fec_asto;
						l_reg.cod_usuario_registo		:= t.cod_cajero;
						l_reg.fec_registro 				:= t.fec_actu;
						l_reg.des_nombre_originario     := t.nom_movim;
						l_reg.cod_banco_destino	 		:= t.cod_entidad;
						l_reg.num_cuenta_destino		:= t.cod_cta_simp;
						l_reg.cod_canal				    := t.tip_actu;
						l_reg.des_canal                 := fp_desc_catalogo( 'TIP_ACTU', l_reg.cod_canal, 'ES' ); 
						--
						l_reg.num_identificacion_beneficiario 	:= t.cod_docum;
						l_reg.des_nombre_beneficiario 			:= f_datos_asegurado( t.tip_docum, t.cod_docum );
						--
						IF t.tip_imp = 'H' THEN 
							l_reg.mon_creditos := t.imp_mon_pais;
							l_reg.mon_debitos  := 0;
						ELSIF t.tip_imp = 'D' THEN
			 				l_reg.mon_debitos 	:= t.imp_mon_pais;
							l_reg.mon_creditos 	:= 0; 
						END IF;
						--
						IF t.num_cheque IS NOT NULL THEN
							l_tip_pago		     := 'CHQ';
							l_reg.cod_banco_origen   := t.cod_entidad_cheque;
						ELSIF t.num_tarjeta IS NOT NULL THEN 
							l_tip_pago		     := 'TAR';
							l_reg.num_cuenta_origen := t.num_tarjeta; 
						ELSE
							l_reg.num_cuenta_origen := NULL;	
						END IF;	
						--
						l_reg.tip_pago := l_tip_pago;
						p_agregar_registro( l_reg );
						--
					END LOOP;
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
		CURSOR c_polizas IS
		WITH rm AS ( SELECT cod_cia, cod_ramo FROM a1001800 where cod_cia = g_cod_cia order by cod_ramo )
		SELECT DISTINCT a.cod_ramo, a.num_poliza, a.num_spto, a.tip_spto, a.tip_docum, a.cod_docum
			FROM a2000030 a,
			     rm
		   WHERE a.tip_docum  = nvl( NULL, a.tip_docum )
			 AND a.cod_docum  = nvl( NULL, a.cod_docum )
			 AND a.tip_spto  != 'SM'
			 AND a.mca_poliza_anulada = 'N'
			 AND a.cod_cia    = rm.cod_cia
			 AND a.cod_ramo   = rm.cod_ramo
			 AND (  
                   EXISTS( 
                             SELECT DISTINCT 'X' 
                              FROM a2990700 b
                             WHERE b.cod_cia    = a.cod_cia
                               AND b.num_poliza = a.num_poliza
                               AND b.num_spto   = a.num_spto
                               AND b.fec_efec_recibo >= g_fecha_desde AND b.fec_efec_recibo <=  g_fecha_hasta
                   ) OR
                   EXISTS(
                       SELECT DISTINCT 'X' 
                          FROM a7000900 c,
                               a3001700 d  
                         WHERE c.cod_cia    = d.cod_cia
                           AND c.cod_ramo   = d.cod_ramo
                           AND c.num_sini   = d.num_sini
                           AND c.cod_cia    = a.cod_cia
                           AND c.cod_ramo   = a.cod_ramo
                           AND c.num_poliza = a.num_poliza
                           AND c.num_spto   = a.num_spto
                           AND c.fec_sini   >= g_fecha_desde AND  c.fec_sini <= g_fecha_hasta
                   )
                 )    
		  ORDER BY a.num_poliza, a.num_spto; 
		--   
	BEGIN 
		--
		FOR v IN c_polizas LOOP
			-- 
			-- agreamos al vector de polizas
			IF g_varios_clientes THEN
				--
				IF nvl(g_tip_docum,'*') != v.tip_docum OR nvl(g_cod_docum,'*') != v.cod_docum THEN
					g_tip_docum         := v.tip_docum;
					g_cod_docum         := v.cod_docum;
					g_nom_completo		:= f_datos_asegurado( g_tip_docum, g_cod_docum );
				END IF;
				--	
			END IF;	

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
		COMMIT;
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
                                  	p_cod_docum     IN a1001331.cod_docum%TYPE,
									p_fecha_desde	IN DATE,
									p_fecha_hasta	IN DATE  
                                ) RETURN typ_tab_lista_me PIPELINED IS 

	BEGIN 
		--
		p_eliminar_registros;
	  	--
		g_cod_cia    		:= p_cod_cia;
		g_tip_docum  		:= p_tip_docum;
		g_cod_docum  		:= p_cod_docum;
		g_fecha_desde       := p_fecha_desde;
		g_fecha_hasta		:= p_fecha_hasta;
		g_varios_clientes   := ( p_tip_docum IS NULL ) OR ( p_cod_docum IS NULL );

		IF NOT g_varios_clientes THEN
			g_nom_completo := f_datos_asegurado( g_tip_docum, g_cod_docum );
		END IF;	
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
				pp_establecer_error;
		--
	END f_list_mov_economico;	
	--
	-- lista de movimientos economicos
  	FUNCTION f_list_mov_economico( p_json VARCHAR2 ) RETURN typ_tab_lista_me PIPELINED IS 
	BEGIN 
		--
		p_eliminar_registros;
		--
        p_tratar_json(p_json);
		g_varios_clientes   := ( g_tip_docum IS NULL ) OR ( g_cod_docum IS NULL );
		
		IF NOT g_varios_clientes THEN
			g_nom_completo := f_datos_asegurado( g_tip_docum, g_cod_docum );
		END IF;	
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
				pp_establecer_error;
		--
	END f_list_mov_economico;															
	--
end gc_k_mov_economico_mcr;