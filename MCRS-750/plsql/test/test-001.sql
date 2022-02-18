declare
    --
	l_cod_cia        ta300003.cod_cia %TYPE;
	l_num_poliza     a2000030.num_poliza %TYPE;
	l_num_spto       a2000030.num_spto %TYPE;
	l_num_apli       a2000030.num_apli %TYPE;
	l_num_spto_apli  a2000030.num_spto_apli %TYPE;
	l_existe_pagador BOOLEAN;
	l_tip_docum      a1001331.tip_docum%TYPE;
	l_cod_docum      a1001331.cod_docum%TYPE;
	l_fec_efec_spto  a2000030.fec_efec_spto%TYPE;
	l_cod_entidad    a1001331.cod_entidad%TYPE;
	l_cod_oficina    a1001331.cod_oficina%TYPE;
	l_num_tarjeta    a1001331.num_tarjeta%TYPE;
	l_cod_tarjeta    a1001331.cod_tarjeta%TYPE;
	l_tip_tarjeta    a1001331.tip_tarjeta%TYPE;
	l_cod_gestor     a2000030.cod_gestor%TYPE;
	l_traza          VARCHAR2(100);
	--
	l_cant           NUMBER := 0;
	l_cod_usr        a2000030.cod_usr%TYPE := trn_k_global.cod_usr;
	l_tip_gestor_ta  a2990700.tip_gestor%TYPE := 'TA';
	l_num_riesgo     a2000031.num_riesgo%TYPE := 1;
    --
begin    	
    
    trn_k_global.asigna('COD_CIA', 1);
    trn_k_global.asigna('NUM_POLIZA', '3022210110771');
    trn_k_global.asigna('NUM_SPTO', 0);
	trn_k_global.asigna('NUM_APLI', 0 );
	trn_k_global.asigna('NUM_SPTO_APLI', 0 );
	trn_k_global.asigna('FEC_EFEC_SPTO', '17022022');
    --
    em_p_cambia_gestor_pagador_mcr;
    --

end;    