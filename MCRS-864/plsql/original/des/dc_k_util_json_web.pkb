create or replace PACKAGE BODY dc_k_util_json_web IS

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
  ------- PROPIEDADES DE OBJETOS JSON
  TYPE t_record_json_value IS RECORD(
    key_object VARCHAR2(30),
    val_object VARCHAR2(8000),
    typ_object VARCHAR2(10));

  --
  TYPE t_table_json_value IS TABLE OF t_record_json_value INDEX BY BINARY_INTEGER;

  --
  g_new_fila INTEGER;

  g_object_primitive t_table_json_value;

  g_object_array t_table_json_value;

  g_table_key_values t_table_key_values;

  --
  FUNCTION fl_get_reg_object_vector(p_json_tablas_array IN t_table_key_values,
                                    p_key_values        IN VARCHAR2) RETURN t_record_key_values IS
    --
    l_reg_object_vector t_record_key_values;
    --
  BEGIN
    --
    l_reg_object_vector := NULL;
    --
    IF (p_json_tablas_array.COUNT > 0) AND
       (p_key_values IS NOT NULL) THEN
      --
      FOR fila IN p_json_tablas_array.FIRST .. p_json_tablas_array.LAST LOOP
        --
        IF upper(p_json_tablas_array(fila).key_values) = upper(p_key_values) THEN
          --
          l_reg_object_vector := p_json_tablas_array(fila);
          --
        END IF;
        --
      END LOOP;
      --
    END IF;
    --
    RETURN l_reg_object_vector;
    --
  END fl_get_reg_object_vector;

  --
  FUNCTION fl_found_key_values(p_objetos_con_valores t_table_key_values,
                               p_key_values          VARCHAR2) RETURN BOOLEAN IS
    --
    l_existe BOOLEAN;
    --
  BEGIN
    --
    l_existe := FALSE;
    --
    IF p_objetos_con_valores.COUNT > 0 THEN
      --
      FOR fila_objeto IN p_objetos_con_valores.FIRST .. p_objetos_con_valores.LAST LOOP
        --
        IF p_objetos_con_valores(fila_objeto).key_values = p_key_values THEN
          --
          l_existe := TRUE;
          --
        END IF;
        --
      END LOOP;
      --
    END IF;
    --
    RETURN l_existe;
    --
  END fl_found_key_values;

  --
  PROCEDURE pl_table_key_values(p_table_json_value IN t_table_json_value) IS
    --
    l_fila_object     INTEGER;
    l_fila_val_object INTEGER;
    --
  BEGIN
    --
    l_fila_object := 0;
    g_table_key_values.DELETE;
    --
    IF p_table_json_value.COUNT > 0 THEN
      --
      FOR fila IN p_table_json_value.FIRST .. p_table_json_value.LAST LOOP
        --
        IF NOT fl_found_key_values(g_table_key_values,
                                   p_table_json_value(fila).key_object) THEN
          --
          g_table_key_values(l_fila_object).key_values := p_table_json_value(fila).key_object;
          --
          l_fila_object := l_fila_object + 1;
          --
        END IF;
        --
      END LOOP;
      --
    END IF;
    --
    IF g_table_key_values.COUNT > 0 THEN
      --
      FOR fila_objeto IN g_table_key_values.FIRST .. g_table_key_values.LAST LOOP
        --
        l_fila_val_object := 0;
        --
        FOR fila IN p_table_json_value.FIRST .. p_table_json_value.LAST LOOP
          --
          IF p_table_json_value(fila).key_object = g_table_key_values(fila_objeto).key_values THEN
            --
            g_table_key_values(fila_objeto).array_values(l_fila_val_object) := p_table_json_value(fila).val_object;
            --
            l_fila_val_object := l_fila_val_object + 1;
            --
          END IF;
          --
        END LOOP;
        --
      END LOOP;
      --
    END IF;
    --
  END pl_table_key_values;

  --
  FUNCTION fl_is_primitive(p_json_value IN json_value) RETURN BOOLEAN IS
    --
    l_is_primitive BOOLEAN;
    --
  BEGIN
    --
    l_is_primitive := TRUE;
    --
    IF p_json_value.is_array OR
       p_json_value.is_object THEN
      --
      l_is_primitive := FALSE;
      --
    END IF;
    --
    RETURN l_is_primitive;
    --
  END fl_is_primitive;

  --
  FUNCTION fl_get_json_value(p_json_value IN json_value) RETURN VARCHAR2 IS
  BEGIN
    --
    IF p_json_value.is_string THEN
      --
      RETURN p_json_value.get_string;
      --
    ELSIF p_json_value.is_number THEN
      --
      RETURN p_json_value.get_number;
      --
    ELSIF p_json_value.is_bool THEN
      --
      IF p_json_value.get_bool THEN
        RETURN 'SI';
      ELSE
        RETURN 'NO';
      END IF;
      --
    ELSIF p_json_value.is_null THEN
      --
      RETURN p_json_value.get_null;
      --
    END IF;
    --
    RETURN NULL;
    --
  END fl_get_json_value;

  --
  PROCEDURE pl_lee_json(p_json IN json) IS
    --
    l_json_value  json_value;
    l_json_keys   json_list;
    l_json_values json_list;
    --
  BEGIN
    --
    l_json_keys   := p_json.get_keys;
    l_json_values := p_json.get_values;
    --
    FOR i IN 1 .. l_json_keys.COUNT() LOOP
      --
      l_json_value := l_json_values.get(i);
      --
      IF NOT fl_is_primitive(l_json_value) THEN
        --
        IF (upper(l_json_value.get_type) = 'OBJECT' AND l_json_value.to_char != '{}') OR
           (upper(l_json_value.get_type) = 'ARRAY' AND l_json_value.to_char != '[]') THEN
          --
          g_new_fila := g_object_array.COUNT + 1;
          --
          g_object_array(g_new_fila).key_object := l_json_keys.get(i).get_string();
          g_object_array(g_new_fila).val_object := l_json_value.to_char;
          g_object_array(g_new_fila).typ_object := l_json_value.get_type;
          --
        END IF;
        --
      ELSE
        --
        IF fl_get_json_value(l_json_value) IS NOT NULL THEN
          --
          g_new_fila := g_object_primitive.COUNT + 1;
          --
          g_object_primitive(g_new_fila).key_object := l_json_keys.get(i).get_string();
          g_object_primitive(g_new_fila).val_object := fl_get_json_value(l_json_value);
          g_object_primitive(g_new_fila).typ_object := l_json_value.get_type;
          --
        END IF;
        --
      END IF;
      --
    END LOOP;
    --
  END pl_lee_json;

  --
  PROCEDURE pl_lee_array(p_object_array IN t_table_json_value) IS
    --
    l_json_list  json_list;
    l_json_value json_value;
    --
  BEGIN
    --
    g_object_array.DELETE;
    --
    IF p_object_array.COUNT > 0 THEN
      --
      FOR fila IN p_object_array.FIRST .. p_object_array.LAST LOOP
        --
        IF upper(p_object_array(fila).typ_object) = 'ARRAY' AND
           p_object_array(fila).val_object != '[]' THEN
          --
          l_json_list := json_list(p_object_array(fila).val_object);
          --
          FOR i IN 1 .. l_json_list.COUNT() LOOP
            --
            IF fl_is_primitive(l_json_list.get(i)) THEN
              --
              IF fl_get_json_value(l_json_list.get(i)) IS NOT NULL THEN
                --
                g_new_fila := g_object_primitive.COUNT + 1;
                --
                g_object_primitive(g_new_fila).key_object := p_object_array(fila).key_object;
                g_object_primitive(g_new_fila).val_object := fl_get_json_value(l_json_list.get(i));
                g_object_primitive(g_new_fila).typ_object := l_json_list.get(i).get_type;
                --
              END IF;
              --
            ELSE
              --
              l_json_value := l_json_list.get(i);
              --
              g_new_fila := g_object_array.COUNT + 1;
              --
              g_object_array(g_new_fila).key_object := p_object_array(fila).key_object;
              g_object_array(g_new_fila).val_object := l_json_value.to_char;
              g_object_array(g_new_fila).typ_object := l_json_value.get_type;
              --
            END IF;
            --
          END LOOP;
          --
        ELSIF upper(p_object_array(fila).typ_object) = 'OBJECT' AND
              p_object_array(fila).val_object != '{}' THEN
          --
          pl_lee_json(json(p_object_array(fila).val_object));
          --
        END IF;
        --
      END LOOP;
      --
    END IF;
    --
  END pl_lee_array;

  --
  PROCEDURE p_lee(p_json IN json) IS
    --
    l_table_json_value t_table_json_value;
    --
  BEGIN
    --
    g_object_array.DELETE;
    g_object_primitive.DELETE;
    --
    pl_lee_json(p_json);
    --
    LOOP
      --
      l_table_json_value := g_object_array;
      pl_lee_array(l_table_json_value);
      --
      EXIT WHEN(g_object_array.COUNT = 0);
      --
    END LOOP;
    --
    pl_table_key_values(g_object_primitive);
    --
  END p_lee;

  --
  FUNCTION f_get_value(p_key_values IN VARCHAR2) RETURN VARCHAR2 IS
    --
    l_val_object_json VARCHAR2(1000) := NULL;
    l_first           INTEGER;
    --
    l_reg_object_vector t_record_key_values;
    --
  BEGIN
    --
    l_reg_object_vector := fl_get_reg_object_vector(g_table_key_values,
                                                    p_key_values);
    --
    IF l_reg_object_vector.array_values.COUNT > 0 THEN
      --
      l_first := l_reg_object_vector.array_values.FIRST;
      --
      IF upper(l_reg_object_vector.array_values(l_first)) = 'NULL' THEN
        --
        l_val_object_json := NULL;
        --
      ELSE
        --
        l_val_object_json := l_reg_object_vector.array_values(l_first);
        --
      END IF;
      --
    END IF;
    --
    RETURN l_val_object_json;
    --
  END f_get_value;

  --
  FUNCTION f_get_array_values(p_key_values IN VARCHAR2) RETURN t_values IS
    --
    l_reg_object_vector t_record_key_values;
    l_values            t_values;
    --
  BEGIN
    --
    l_reg_object_vector := fl_get_reg_object_vector(g_table_key_values,
                                                    p_key_values);
    --
    l_values.DELETE;
    --
    IF l_reg_object_vector.array_values.COUNT > 0 THEN
      --
      l_values := l_reg_object_vector.array_values;
      --
    END IF;
    --
    RETURN l_values;
    --
  END f_get_array_values;

  --
  FUNCTION f_get_table_key_values(p_json IN json) RETURN t_table_key_values IS
  BEGIN
    --
    p_lee(p_json);
    --
    RETURN g_table_key_values;
    --
  END f_get_table_key_values;

--
END dc_k_util_json_web;
