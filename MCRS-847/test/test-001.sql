declare
    -- 
    -- parametros
    p_cod_cia       a1001331.cod_cia%type       := 1;
    p_tip_docum     a1001331.tip_docum%type     := 'CNA';
    p_cod_docum     a1001331.cod_docum%type     := '109700572';
    --
    -- manejo de error
    g_error_text    varchar2(8000);
    g_error_code    varchar2(20);
    g_hay_error     boolean := false;
    --
    -- establecer el error
    procedure pp_establecer_error is 
    begin 
        --
        g_error_text    := sqlerrm;
        g_error_code    := sqlcode;
        g_hay_error     := true;
        --
    end pp_establecer_error;
    --
    -- determina el tomador
    function pf_tomador return boolean is 
    begin 
        --
        -- se lee los datos del tomador
        dc_k_terceros_trn. p_lee(   p_cod_cia       => p_cod_cia,
                                    p_tip_docum     => p_tip_docum,
                                    p_cod_docum     => p_cod_docum,
                                    p_cod_tercero   => null,
                                    p_fec_validez   => null,
                                    p_cod_act_tercero  => 1
                                );
        return true;
        --
        exception 
            when others then
                pp_establecer_error; 
                return false;
            --                        
    end pf_tomador;
    --
    -- agregar recibos asociados
    procedure pp_agregar_recibos( p_num_poliza a2990700.num_poliza%type,
                                  p_num_spto   a2990700.num_spto%type
                                ) is 
        --
        cursor c_recibos is
        select * 
          from a2990700
         where cod_cia    = p_cod_cia
           and num_poliza = p_num_poliza
           and num_spto   = p_num_spto
         order by num_recibo;
        --
        cursor c_historico( p_num_recibo a5020301.num_recibo%type ) is
        select * 
          from a5020301
         where cod_cia    = p_cod_cia
           and num_poliza = p_num_poliza
           and num_spto   = p_num_spto
           and num_recibo = p_num_recibo
           and tip_situacion = 'CT'
           and num_bloque_tes is not null
         order by num_recibo;
        -- 
    begin 
        --
        for v in c_recibos loop
            --
            dbms_output.put_line( v.num_recibo ); 
            for h in c_historico( v.num_recibo ) loop
              dbms_output.put_line( v.tip_situacion );
            end loop;
            --
        end loop;
        --
    end pp_agregar_recibos;
    --
    --
    -- cargamos las polizas y las colocamos en un vector
    procedure pp_agregar_polizas is
        --
        -- cursor polizas asociadas al tomador
        cursor c_polizas is 
        select distinct num_poliza, num_spto
          from a2000030 
         where cod_cia    = p_cod_cia
           and tip_docum  = p_tip_docum
           and cod_docum  = p_cod_docum
           and tip_spto  != 'SM'
           and mca_poliza_anulada = 'N'
           order by num_poliza, num_spto; 
        --   
    begin 
        --
        for v in c_polizas loop
            -- 
            -- agreamos al vector de polizas
            dbms_output.put_line( v.num_poliza ||' '|| v.num_spto ); 
            pp_agregar_recibos( p_num_poliza => v.num_poliza,
                                p_num_spto   => v.num_spto
                              );
        end loop;
        --    
    end pp_agregar_polizas;
    --
begin
    -- 
    -- se determina el tomador o asegurado
    if pf_tomador then 
        --
        -- se carga las polizas asociadas a este tomador
        dbms_output.put_line('agregar polizas al vector: ');
        pp_agregar_polizas;
        --
    end if;

    dbms_output.put_line(g_error_text);

end;