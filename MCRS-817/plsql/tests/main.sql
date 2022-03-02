begin
    --
    trn_k_global.asigna('COD_USR', 'TRON2000');
    trn_k_global.asigna('COD_IDIOMA', 'ES');
    --
    trn_k_global.asigna('JBCOD_CIA', 1);
    trn_k_global.asigna('JBCOD_RAMO', NULL);
    trn_k_global.asigna('JBID_PROCESO', NULL);
    trn_k_global.asigna('JBNOMBRE_ARCHIVO', 'PRUEBA_AVISO_230_01.CSV' );
    --
    gc_k_cobro_aviso_bco_nacional.p_aviso_cobro_globales;
    --
end;