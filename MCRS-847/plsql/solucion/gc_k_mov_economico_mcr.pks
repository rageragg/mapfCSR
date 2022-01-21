create or replace PACKAGE gc_k_mov_economico_mcr AS
	---
	/* -------------------- VERSION = 1.0 --------------------
	|| CARRIERHOUSE 14/01/2022, RGUERRA
	|| Creacion de package.
	*/ -------------------------------------------------------
	/*---------------------- DESCRIPCION ---------------------
	||
	|| Proceso que multiproposito de los movimientos economicos
	||
	/* -------------------- MODIFICACIONES --------------------
	|| Modificacion 14/01/2022 - CARRIERHOUSE - v 1.0
	|| Creacion de Proceso f_list_mov_economico
	*/ --------------------------------------------------------
	--
	-- tipos de datos
	-- ESTRUCTURA DE LA VISTA DE MOVIMIENTOS ECONOMICOS
	TYPE typ_reg_me IS RECORD(
		cod_tipo_identificacion     a2000030.tip_docum%TYPE,               -- tipo de documento
		num_identificacion          a2000030.cod_docum%TYPE,              -- codigo de documento
		nom_completo                VARCHAR2(255),
		cod_tipo_producto           a2000030.cod_ramo%TYPE,
		cod_subproducto             VARCHAR2(50),
		num_referencia              VARCHAR2(64),               -- numero de poliza + numero de suplemento
		fec_movimiento              DATE,
		cod_tipo_movimiento         a2000030.tip_spto%TYPE,
		cod_oficina                 INTEGER,
		cod_canal                   VARCHAR2(2),
		des_canal                   VARCHAR2(50),
		cod_moneda                  a2990700.cod_mon%TYPE,
		cod_moneda_producto         a2990700.cod_mon%TYPE,
		ind_naturaleza_transaccion  CHAR(1)       DEFAULT 'O',  
		ind_origen_transaccion      VARCHAR2(20),                  -- tipo cobro
		mon_tipo_cambio             a5020301.val_cambio%TYPE DEFAULT 0,
		mon_debitos                 NUMBER(15,2)  DEFAULT 0,
		mon_creditos                NUMBER(15,2)  DEFAULT 0,
		cod_usuario_registo         VARCHAR2(8),
		fec_registro                DATE,
		--
		num_identificacion_originario   VARCHAR2(255),
		des_nombre_originario           VARCHAR2(255),
		num_identificacion_beneficiario VARCHAR2(255),
		des_nombre_beneficiario         VARCHAR2(255),
		num_cuenta_origen               VARCHAR2(22),
		num_cuenta_destino              VARCHAR2(22),
		cod_pais_origen                 VARCHAR2(3)	DEFAULT 'CRI',
		cod_pais_destino                VARCHAR2(3) DEFAULT 'CRI',
		cod_banco_origen                VARCHAR2(5),
		cod_banco_destino               VARCHAR2(5),
		tip_pago                        CHAR(3)
	);

	TYPE typ_tab_lista_me IS TABLE OF typ_reg_me;
	--
	-- lista de movimientos economicos
	FUNCTION f_list_mov_economico(  p_cod_cia       IN a1001331.cod_cia%type,
									p_tip_docum     IN a1001331.tip_docum%type,
									p_cod_docum     IN a1001331.cod_docum%TYPE,
									p_fecha_desde	DATE,
									p_fecha_hasta	DATE
								) RETURN typ_tab_lista_me  PIPELINED;   
	--
	-- lista de movimientos economicos
	FUNCTION f_list_mov_economico( p_json VARCHAR2 ) RETURN typ_tab_lista_me PIPELINED;  							                          
	-- 
end gc_k_mov_economico_mcr;