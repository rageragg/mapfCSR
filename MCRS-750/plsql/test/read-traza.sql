declare
    g_file               utl_file.file_type;
    g_nombre_archivo     VARCHAR2(60) := 'BAC01_2022-02-17_06-30_PM.txt';
    --
    l_line              VARCHAR2(1024);
    --
begin
    g_file := utl_file.fopen('AP_LIS', g_nombre_archivo, 'r' ); 
    LOOP
        --
        utl_file.get_line(g_file, l_line);
        dbms_output.put_line(l_line);
        --
    END LOOP;
    utl_file.fclose(g_file);
    exception
        when others then
            dbms_output.put_line(sqlerrm);
end;