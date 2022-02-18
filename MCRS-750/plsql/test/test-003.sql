begin
     dbms_output.put_line( 'BAC01_' || TO_CHAR(SYSDATE, 'YYYY-MM-DD_HH-MI_AM') || '.txt');
     gc_p_remesa_recibo_imp( p_cod_cia   => 1,
                             p_num_aviso => 220017943
                           );
end;