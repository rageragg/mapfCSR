declare
    g_file               utl_file.file_type;
    g_nombre_archivo     VARCHAR2(60) := 'PRUEBA_AVISO.CSV';
begin
    ptraza1(g_nombre_archivo,'w','5244710266618387;303900096;DAHIANNA PEREZ LARA;1,794,42;1;01/06/2021');
    ptraza1(g_nombre_archivo,'a','5244710266618387;303900096;DAHIANNA PEREZ LARA;1,794,42;1;01/07/2020');
    ptraza1(g_nombre_archivo,'a','5244710239489023;111680310;RELFA ISABEL CASTILLO RODRIGUEZ;540.26;1;01/10/2021');
    exception
        when others then
            dbms_output.put_line(sqlerrm);
end;            