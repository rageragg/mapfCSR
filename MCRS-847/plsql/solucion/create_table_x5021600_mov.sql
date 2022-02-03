CREATE TABLE "TRON2000"."X5021600_MOV" (
        cod_cia                     NUMBER(2, 0),
		cod_tipo_identificacion     VARCHAR(3),               -- tipo de documento
		num_identificacion          VARCHAR2(20),              -- codigo de documento
		nom_completo                VARCHAR2(255),
		cod_tipo_producto           NUMBER(3),
		cod_subproducto             VARCHAR2(50),
		num_referencia              VARCHAR2(64),               -- numero de poliza + numero de suplemento
		fec_movimiento              DATE,
		cod_tipo_movimiento         VARCHAR2(2),
		cod_oficina                 INTEGER,
		cod_canal                   VARCHAR2(2),
		des_canal                   VARCHAR2(50),
		cod_moneda                  NUMBER(2),
		cod_moneda_producto         NUMBER(2),
		ind_naturaleza_transaccion  CHAR(1)       DEFAULT 'O',  
		ind_origen_transaccion      VARCHAR2(20),                  -- tipo cobro
		mon_tipo_cambio             NUMBER,
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
)
SEGMENT CREATION IMMEDIATE
PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
    STORAGE ( INITIAL 2097152 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645 PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT )
TABLESPACE "DATOS";

CREATE INDEX "TRON2000"."I_X5021600_MOV_1" ON
    "TRON2000"."X5021600_MOV" (
        cod_cia,
        cod_tipo_identificacion,
        num_identificacion,
        cod_tipo_producto,
        num_referencia
    )
        PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS
            STORAGE ( INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645 PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT )
        TABLESPACE "IDX";

GRANT SELECT ON "TRON2000"."X5021600_MOV" TO "RSEL_TRON2000_ALIADOS";
GRANT ALTER ON "TRON2000"."X5021600_MOV" TO "ROL_TRON2000_TI_ALL";
GRANT DELETE ON "TRON2000"."X5021600_MOV" TO "ROL_TRON2000_TI_ALL";
GRANT INSERT ON "TRON2000"."X5021600_MOV" TO "ROL_TRON2000_TI_ALL";
GRANT UPDATE ON "TRON2000"."X5021600_MOV" TO "ROL_TRON2000_TI_ALL";
GRANT UPDATE ON "TRON2000"."X5021600_MOV" TO "ROL_TRON2000_ALL";
GRANT INSERT ON "TRON2000"."X5021600_MOV" TO "ROL_TRON2000_ALL";
GRANT DELETE ON "TRON2000"."X5021600_MOV" TO "ROL_TRON2000_ALL";
GRANT ALTER ON "TRON2000"."X5021600_MOV" TO "ROL_TRON2000_ALL";
GRANT SELECT ON "TRON2000"."X5021600_MOV" TO "ROL_TRON2000_SEL";
GRANT SELECT ON "TRON2000"."X5021600_MOV" TO "ROL_TRON2000_ALL";
GRANT DELETE ON "TRON2000"."X5021600_MOV" TO "NWT_DL";
GRANT INSERT ON "TRON2000"."X5021600_MOV" TO "NWT_DL";
GRANT SELECT ON "TRON2000"."X5021600_MOV" TO "NWT_DL";
GRANT UPDATE ON "TRON2000"."X5021600_MOV" TO "NWT_DL";
GRANT REFERENCES ON "TRON2000"."X5021600_MOV" TO "NWT_DL";
GRANT DELETE ON "TRON2000"."X5021600_MOV" TO "NWT_DM_APP";
GRANT INSERT ON "TRON2000"."X5021600_MOV" TO "NWT_DM_APP";
GRANT SELECT ON "TRON2000"."X5021600_MOV" TO "NWT_DM_APP";
GRANT UPDATE ON "TRON2000"."X5021600_MOV" TO "NWT_DM_APP";
GRANT REFERENCES ON "TRON2000"."X5021600_MOV" TO "NWT_DM_APP";
GRANT SELECT ON "TRON2000"."X5021600_MOV" TO "NWT_IL";