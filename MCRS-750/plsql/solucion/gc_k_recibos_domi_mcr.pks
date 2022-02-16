create or replace PACKAGE gc_k_recibos_domi_mcr
AS
/*-----------------------DESCRIPCION-----------------------------------
|| Carga de los recibos para la Domiciliacion Bancaria. (PAC).
*/---------------------------------------------------------------------
--
/*-------------------- VERSION = 1.03 --------------------- */
--
/* -------------------- MODIFICACIONES --------------------
|| David  23-07-2001 Version 1.03
|| Se a?ade el x5020039.cod_cta_simp
|| David  21-09-2000 Version 1.02
|| Se a?ade la fec_cobro
*/ --------------------------------------------------------
--
PROCEDURE p_proceso (p_cod_cia          a2990700.cod_cia           %TYPE,
                     p_fec_desde        a2990700.fec_efec_recibo   %TYPE,
                     p_fec_hasta        a2990700.fec_efec_recibo   %TYPE,
                     p_tip_gestor       a2990700.tip_gestor        %TYPE,
                     p_cod_gestor       a2990700.cod_gestor        %TYPE,
                     p_cod_mon          a2990700.cod_mon           %TYPE,
                     p_cod_cta_simp     a5022600.cod_cta_simp      %TYPE,
                     p_fec_remesa       a2990700.fec_remesa        %TYPE,
                     p_fec_cobro        a2990700.fec_remesa        %TYPE);
/* -------------------- DESCRIPCION -----------------------
||
*/ --------------------------------------------------------
PROCEDURE p_proceso_con_globales;
/* -------------------- DESCRIPCION -----------------------
|| Recoge las globales por trn_k_global
*/ --------------------------------------------------------
PROCEDURE p_borra_x5020039;
/* -------------------- DESCRIPCION -----------------------
|| Borra la tabla x5020039;
*/ --------------------------------------------------------
PROCEDURE p_borra_rec_x5020039
              (p_cod_cia     x5020039.cod_cia      %TYPE,
               p_num_recibo  x5020039.num_recibo   %TYPE);
/* -------------------- DESCRIPCION -----------------------
|| Borra recibo de la tabla x5020039;
*/ --------------------------------------------------------
PROCEDURE p_inserta_x5020039
              (p_cod_cia      x5020039.cod_cia      %TYPE,
               p_num_recibo   x5020039.num_recibo   %TYPE,
               p_imp_recibo   x5020039.imp_recibo   %TYPE,
               p_cod_mon      x5020039.cod_mon      %TYPE,
               p_cod_cta_simp x5020039.cod_cta_simp %TYPE,
               p_fec_actu     x5020039.fec_actu     %TYPE,
               p_cod_usr      x5020039.cod_usr      %TYPE);
/* -------------------- DESCRIPCION -----------------------
|| Inserta en la tabla x5020039;
*/ --------------------------------------------------------
--
END gc_k_recibos_domi_mcr; 
 
