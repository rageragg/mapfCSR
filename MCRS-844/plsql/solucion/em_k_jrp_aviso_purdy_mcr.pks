create or replace PACKAGE em_k_jrp_aviso_purdy_mcr AS
  ---
  /* -------------------- VERSION = 1.0 --------------------
  || CARRIERHOUSE 09/08/2021, RGUERRA
  || Creacion de package.
  */ -------------------------------------------------------
  /*---------------------- DESCRIPCION ---------------------
  ||
  || Reporte para JasperReports Aviso de Cobro PURDY.
  ||
  /* -------------------- MODIFICACIONES --------------------
  || Modificacion 2021/09/30 - CARRIERHOUSE - v 1.01
  || Ajuste de calculos 
  || - Bruto total, Suma del total( restando comisiones y retenciones )
  || - Iva de la comision
  */ --------------------------------------------------------
  --
  PROCEDURE p_lista_con_globales;
  --
  PROCEDURE p_lista( p_cod_cia   a1000900.cod_cia%TYPE,
                     p_num_aviso a5021646.cod_docum_pago%TYPE
                   );

END em_k_jrp_aviso_purdy_mcr;