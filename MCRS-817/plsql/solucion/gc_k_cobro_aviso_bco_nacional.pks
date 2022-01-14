CREATE OR REPLACE PACKAGE gc_k_cobro_aviso_bco_nacional IS 
    --
    TYPE typ_rec_formato IS RECORD(
        num_tarjeta         VARCHAR2(30),
        cod_docum_pago      VARCHAR2(20),
        tip_docum_pago      VARCHAR2(03),
        nombre_apellido     VARCHAR2(160),
        monto_pago          NUMBER DEFAULT 0,
        cod_mon             NUMBER(2),
        fec_pago            DATE,
        num_poliza          VARCHAR2(13),
        num_spto            NUMBER(4),
        mca_poliza_anulada  CHAR(1) DEFAULT 'N',
        num_poliza_grupo    VARCHAR2(13),
        cod_docum_tomador   VARCHAR2(20),
        tip_docum_tomador   VARCHAR2(03),
        cod_agt             NUMBER(06),
        num_aviso           VARCHAR2(20),
        num_recibo          NUMBER,
        imp_recibo          NUMBER  DEFAULT 0,
        mca_procesado       CHAR(1) DEFAULT 'N',
        observacion         VARCHAR2(150),
        nombre_archivo      VARCHAR2(50)
    );

    TYPE tab_lista_datos    IS TABLE OF typ_rec_formato;
    TYPE tab_poliza_grupo   IS TABLE OF VARCHAR2(13) INDEX BY PLS_INTEGER;
    --
    -- lista de aviso de cobro para globales
    PROCEDURE p_aviso_cobro_globales;
    -- 
    -- eliminar aviso
    PROCEDURE p_elimina_aviso( p_num_aviso IN a2990700.num_aviso%TYPE );
    --

END gc_k_cobro_aviso_bco_nacional;