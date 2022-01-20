declare
  -- Non-scalar parameters require additional processing 
  -- p_dat_asegurado strarray;
  p_dat_asegurado strarray := strarray();
  p_errors dc_k_crea_terceros_web_mcr.gc_ref_cursor;
  
  p_any sys.anydata;
  p_json json;
  l_json_value  json_value_web;
  
  l_json_keys   json_list;
  l_json_values json_list;
  
  TYPE r_data IS RECORD(
     cod_cia   number(2),
     session_id  varchar2(512),
     tip_docum   varchar2(20),
     cod_docum   varchar2(20),
     txt_mensaje varchar2(512)
  );
  
  p_data r_data;
  --
  l_index INTEGER := 0;
  --
begin
  -- Call the procedure
  p_dat_asegurado.EXTEND(1);
  l_index := 1;
  --
  p_dat_asegurado(l_index) := '{';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'COD_CIA: "1",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'TIP_DOCUM: "CIN",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'COD_DOCUM: "9988888",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'NOM1_TERCERO: "CARLOS",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'NOM2_TERCERO: "Enrique",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'APE1_TERCERO: "SUAREZ",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'APE2_TERCERO: "MUJICA",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'FEC_NACIMIENTO: "",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'MCA_SEXO: "M",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'COD_EST_CIVIL: "",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'COD_PROFESION: "98",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'COD_NACIONALIDAD: "NIC",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'COD_PAIS: "",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'COD_ESTADO: "",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'COD_PROV: "",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'COD_LOCALIDAD: "",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'TIP_DOMICILIO: "",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'NOM_DOMICILIO1: "",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'NOM_DOMICILIO2: "",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'NOM_DOMICILIO3: "",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'TLF_PAIS: "1",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'TLF_ZONA: "123",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'TLF_NUMERO: "1234567",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'TLF_MOVIL_COD_PAIS: "1",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'TLF_MOVIL_COD_AREA: "123",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'TLF_MOVIL: "1234567",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'EMAIL: "prueba@gmail.com"';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || '}';
  
    -- Call the procedure
  p_dat_asegurado.EXTEND(1);
  l_index := 2;
  --
  p_dat_asegurado(l_index) := '{';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'COD_CIA: "1",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'TIP_DOCUM: "CIN",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'COD_DOCUM: "8897577",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'NOM1_TERCERO: "JAVIER",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'NOM2_TERCERO: "CLEMENTE",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'APE1_TERCERO: "PANTANO",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'APE2_TERCERO: "DIAZ",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'FEC_NACIMIENTO: "",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'MCA_SEXO: "M",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'COD_EST_CIVIL: "",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'COD_PROFESION: "98",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'COD_NACIONALIDAD: "NIC",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'COD_PAIS: "",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'COD_ESTADO: "",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'COD_PROV: "",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'COD_LOCALIDAD: "",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'TIP_DOMICILIO: "",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'NOM_DOMICILIO1: "",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'NOM_DOMICILIO2: "",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'NOM_DOMICILIO3: "",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'TLF_PAIS: "1",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'TLF_ZONA: "123",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'TLF_NUMERO: "1234567",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'TLF_MOVIL_COD_PAIS: "1",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'TLF_MOVIL_COD_AREA: "123",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'TLF_MOVIL: "1234567",';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || 'EMAIL: "prueba123@gmail.com"';
  p_dat_asegurado(l_index) := p_dat_asegurado(l_index) || '}';
  
  p_json := json(p_dat_asegurado(l_index));
  l_json_keys := p_json.get_keys;
  l_json_values := p_json.get_values;
  /*
   FOR i IN 1 .. l_json_keys.COUNT() LOOP
      l_json_value := l_json_values.get(i);
      dbms_output.put_line(upper(l_json_value.get_type));
      dbms_output.put_line(upper(l_json_keys.get(i).get_string()));
   END LOOP;
  */

  dc_k_crea_terceros_web_mcr.pl_crea_terceros(p_dat_asegurado, p_errors);
  if p_errors%ISOPEN then
     dbms_output.put_line( 'Cursor abierto' );
     loop
         fetch p_errors into p_data;
         exit when p_errors%NOTFOUND;
         dbms_output.put_line( p_data.txt_mensaje || ' para ' || p_data.cod_docum );
     end loop;
     dbms_output.put_line( 'Cursor cerrado' );
     close p_errors;
  else 
    dbms_output.put_line( 'Cursor cerrado' );
  end if;

end;