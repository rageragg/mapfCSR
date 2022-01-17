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
	PROCEDURE p_datos_tesoreria( p_cod_ramo   			a2000030.cod_ramo%type,
	                             p_num_bloque 			a5020301.num_bloque_tes%type,
	                             p_fec_movimiento 		OUT DATE,
								 p_mon_creditos			OUT NUMBER,
								 p_mon_debitos			OUT NUMBER,
								 p_cod_usuario_registo	OUT VARCHAR2
								) IS 
		--
		-- datos de tesoreria
		CURSOR c_tesoreria IS 
			SELECT * 
	          FROM v5021600_1900
	         WHERE cod_cia        = g_cod_cia
	           AND cod_ramo       = p_cod_ramo
	           AND tip_docum      = g_tip_docum
	           AND cod_docum      = g_cod_docum
	           AND num_bloque_tes = p_num_bloque;
		--
		l_reg c_tesoreria%ROWTYPE;
		--
	BEGIN 
		--
		p_mon_creditos := 0;
		p_mon_debitos  := 0;
		--
		OPEN c_tesoreria;
		FETCH c_tesoreria INTO l_reg;
		IF c_tesoreria%FOUND THEN
			--
			p_fec_movimiento 		:= l_reg.fec_asto;
			p_cod_usuario_registo	:= l_reg.cod_cajero;
			--
			IF l_reg.tip_imp = 'H' THEN 
				p_mon_creditos := l_reg.imp_mon_pais;
			ELSIF l_reg.tip_imp = 'D' THEN
			 	p_mon_debitos := l_reg.imp_mon_pais;
			END IF;
			--
		END IF;
		CLOSE c_tesoreria;
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
		l_fec_movimiento 		DATE;
		l_mon_creditos			NUMBER;
		l_mon_debitos			NUMBER;
		l_cod_usuario_registo	VARCHAR2(8);
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
			p_agregar_registro( l_reg );
			--
			FOR h IN c_historico( v.num_recibo ) LOOP
				--
			    l_reg.num_identificacion_originario := h.num_bloque_tes;
				l_reg.ind_origen_transaccion        := h.tip_cobro;
				l_reg.mon_tipo_cambio        		:= h.val_cambio;
				--
				-- datos de tesoreria
				p_datos_tesoreria( p_cod_ramo, 
				                   h.num_bloque_tes, 
								   l_fec_movimiento, 
								   l_mon_creditos, 
								   l_mon_debitos,
								   l_cod_usuario_registo
								 );
				l_reg.fec_movimiento 			:= l_fec_movimiento;
				l_reg.mon_creditos   			:= l_mon_creditos;
				l_reg.mon_debitos    			:= l_mon_debitos;
				l_reg.cod_usuario_registo		:= l_cod_usuario_registo;
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