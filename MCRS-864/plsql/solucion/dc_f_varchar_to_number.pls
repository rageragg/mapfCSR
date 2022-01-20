create or replace FUNCTION dc_f_varchar_to_number(p_number_char IN VARCHAR2) RETURN NUMBER IS
  --
  /* ------------------------------------------------------------------
  || Funcion para convertir a number, un numero que viene en una
  || variable tipo varchar, y cumpla con las siguientes condiciones:
  ||
  || 1.- Solo puede contener un separador de decimales.
  || 2.- El separador de decimales debe ser punto o coma.
  || 3.- No debe contener separador de miles.
  || 4.- No debe contener caracteres.
  ||
  || ------------------------------------------------------------------
  */
  --
  /* ------------------------- VERSION = 1.00 -------------------------
  -- SMEJIAS (CARRIERHOUSE) 13-04-2018
  -- CONSTRUCCION
  /* ------------------------- MODIFICACIONES -------------------------
  --
  --
  */ ------------------------------------------------------------------
  -- ------------------------------------------------------------------
  --
  l_sep_dec VARCHAR2(1) := ',';
  l_sep_mil VARCHAR2(1) := '.';
  --
  l_return NUMBER;
  --
  CURSOR c_nls_sep_dec_sep_mil IS
    SELECT (SELECT substr(VALUE,
                          1,
                          1)
              FROM nls_session_parameters
             WHERE parameter = 'NLS_NUMERIC_CHARACTERS') sep_dec,
           (SELECT substr(VALUE,
                          2,
                          1)
              FROM nls_session_parameters
             WHERE parameter = 'NLS_NUMERIC_CHARACTERS') sep_mil
      FROM dual;
  --
BEGIN
  --
  l_return := NULL;
  --
  IF (TRIM(p_number_char) IS NOT NULL) AND
     (upper(p_number_char) != 'NULL') THEN
    --
    OPEN c_nls_sep_dec_sep_mil;
    FETCH c_nls_sep_dec_sep_mil
      INTO l_sep_dec, l_sep_mil;
    CLOSE c_nls_sep_dec_sep_mil;
    --
    l_return := to_number(REPLACE(TRIM(p_number_char),
                                  l_sep_mil,
                                  l_sep_dec));
    --
  END IF;
  --
  RETURN l_return;
  --
END dc_f_varchar_to_number;
