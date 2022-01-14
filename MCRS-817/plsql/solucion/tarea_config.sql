-- G0200001, definicion de la tarea
Insert into G0200001 (COD_CIA,COD_TAR,NOM_TAR,TIP_TAR,TIP_PRG,NOM_PRG,MCA_DIRECTO,COD_EST_PARAMETROS,
                      COD_EST_ANEXO,COD_USR,FEC_ACTU,MCA_VISUALIZA
                     ) 
        values ('1','MCRGC10610','Aviso Cobro PRF Bco Nac.','2','1',
                'gc_k_cobro_aviso_bco_nacional.p_aviso_cobro_globales','S',null,null,'TRON2000',sysdate,'N'
               );
-- G0200002, parametros de la tarea
Insert into G0200002 ( COD_CIA,COD_TAR,NUM_SECU_CAMPO,COD_CAMPO,MCA_VISIBLE,MCA_OBLIGATORIO,
                       NOM_PRG_PRE_CAMPO,VAL_DEFECTO,NOM_PGM_HELP,NOM_TABLA_VALIDA,
                       COD_VERSION,NOM_GLOBAL_PGM_HELP,NOM_PRG_CAMPO,COD_LISTA,COD_USR,FEC_ACTU,
                       MCA_VALIDA_SI_NULL,MCA_VLD_ONLINE
                     ) 
              values ('1','MCRGC10610',1,'JBCOD_CIA','N','S','CO_K_TAREAS.P_V_JBCOD_CIA',
                       1,null,null,null,null,null,null,'TRON2000',to_date('22/07/19','DD/MM/RR'),'N','N'
                     );
Insert into G0200002 ( COD_CIA,COD_TAR,NUM_SECU_CAMPO,COD_CAMPO,MCA_VISIBLE,MCA_OBLIGATORIO,
                       NOM_PRG_PRE_CAMPO,VAL_DEFECTO,NOM_PGM_HELP,NOM_TABLA_VALIDA,
                       COD_VERSION,NOM_GLOBAL_PGM_HELP,NOM_PRG_CAMPO,COD_LISTA,COD_USR,FEC_ACTU,
                       MCA_VALIDA_SI_NULL,MCA_VLD_ONLINE
                     ) 
              values ('1','MCRGC10610',2,'JBCOD_RAMO','N','N',
                      null,null,null,null,null,null,null,null,'TRON2000',to_date('22/07/19','DD/MM/RR'),'N','N'
                     );
Insert into G0200002 ( COD_CIA,COD_TAR,NUM_SECU_CAMPO,COD_CAMPO,MCA_VISIBLE,MCA_OBLIGATORIO,
                       NOM_PRG_PRE_CAMPO,VAL_DEFECTO,NOM_PGM_HELP,NOM_TABLA_VALIDA,
                       COD_VERSION,NOM_GLOBAL_PGM_HELP,NOM_PRG_CAMPO,COD_LISTA,COD_USR,FEC_ACTU,
                       MCA_VALIDA_SI_NULL,MCA_VLD_ONLINE
                     ) 
              values ('1','MCRGC10610',3,'JBNOMBRE_ARCHIVO','S','S',
                       null,null,null,null,null,null,null,null,'TRON2000',to_date('22/07/19','DD/MM/RR'),'N','N'
                     );
