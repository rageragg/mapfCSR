create or replace PACKAGE dc_k_util_json_web IS

  /* ------------------------------------------------------------------------ */
  -- Procedimientos y funciones que facilitan la lectura de variables
  -- y parametros tipo JSON.
  -- ------------------------------------------------------------------------
  -- ---------------------------- Modos de uso: -----------------------------
  -- ------------------------------------------------------------------------
  -- 1.- POR MEDIO DE "P_LEE", para lo cual se debe:
  --
  -- Primero: llamar al procedimiento "p_lee" pasandole por parametro el JSON.
  -- Segundo: recuperar los valores del JSON, por medio de las funciones:
  --
  --    -> "f_get_value" retorna unicamente el primer valor que encuentre.
  --    -> "f_get_array_values" retorna un vector con todos los valores
  --       que encuentre.
  --
  --    Ambas funciones reciben por parametro el nombre del campo que se requiera.
  --
  -- 2.- POR MEDIO DE "F_GET_TABLE_KEY_VALUES", la cual recibe por parametro
  --     el JSON, el cual procesa y luego retorna una variable tipo tabla con todos
  --     los valores obtenidos.
  --
  /* ------------------------------------------------------------------------ */
  /* ----------------------------- VERSION = 1.00 --------------------------- */
  -- SMEJIAS (CARRIERHOUSE) - 15/07/2019
  -- CONSTRUCCION
  /* ----------------------------- MODIFICACIONES --------------------------- */
  --
  --
  /* ------------------------------------------------------------------------ */
  --
  ------- TIPO JSON TABLAS ARRAY
  TYPE t_values IS TABLE OF CLOB INDEX BY BINARY_INTEGER;

  --
  TYPE t_record_key_values IS RECORD(
    key_values   VARCHAR2(30),
    array_values t_values);

  --
  TYPE t_table_key_values IS TABLE OF t_record_key_values INDEX BY BINARY_INTEGER;

  --
  PROCEDURE p_lee(p_json IN json);

  --
  FUNCTION f_get_value(p_key_values IN VARCHAR2) RETURN VARCHAR2;

  --
  FUNCTION f_get_array_values(p_key_values IN VARCHAR2) RETURN t_values;

  --
  FUNCTION f_get_table_key_values(p_json IN json) RETURN t_table_key_values;

--
END dc_k_util_json_web;
