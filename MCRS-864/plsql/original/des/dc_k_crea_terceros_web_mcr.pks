create or replace package dc_k_crea_terceros_web_mcr is

  /**
  || Procedimientos y funciones para crear terceros via web
  */
  --
  /* -------------------- VERSION = 1.00 -------------------- */
  -- 09/03/2020
  -- ENIETO - CONSTRUCCION
  --
  /* -------------------- MODIFICACIONES -----------------------
  --
  */ -----------------------------------------------------------
  --

  TYPE reg_x2000100_ter IS RECORD(
    cod_cia    x2000100_ter.cod_cia%TYPE,
    tip_docum  x2000100_ter.tip_docum%TYPE,
    cod_docum  x2000100_ter.cod_docum%TYPE,
    cod_campo  x2000100_ter.cod_campo%TYPE,
    num_secu   x2000100_ter.num_secu%TYPE,
    val_campo  x2000100_ter.val_campo%TYPE,
    txt_campo  x2000100_ter.txt_campo%TYPE,
    txt_campo1 x2000100_ter.txt_campo1%TYPE,
    txt_campo2 x2000100_ter.txt_campo2%TYPE);

  --
  TYPE table_x2000100_ter IS TABLE OF reg_x2000100_ter;

  TYPE gc_ref_cursor IS REF CURSOR;
  --
  g_table_key_values dc_k_util_json_web.t_table_key_values;
  --

  PROCEDURE pl_crea_terceros(p_dat_asegurado IN strarray,
                             p_errores       OUT gc_ref_cursor);

  PROCEDURE p_x2000100_ter_lee(p_cod_cia a1001331.cod_cia%TYPE,
                               p_errores       OUT gc_ref_cursor);

  --
  PROCEDURE p_graba_tercero(p_cod_cia      IN a1001331.cod_cia%TYPE,
                            p_session_id   IN x2000100_ter.session_id%TYPE,
                            p_reg_a1001331 IN a1001331%ROWTYPE,
                            p_reg_a1001399 IN a1001399%ROWTYPE);

end dc_k_crea_terceros_web_mcr;
