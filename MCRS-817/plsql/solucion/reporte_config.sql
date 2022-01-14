-- G1010160, configuracion de reporte
Insert into G1010160 ( COD_LISTADO,TIP_EXTENSION,MCA_MANTENER_LISTADO,MCA_VISUALIZA,MCA_CLIENTE,MCA_EXPORTA,TIP_EXPORTA,COD_USR,
                       FEC_ACTU,TIP_LISTADO,IMP_LOGICA,MCA_CAMBIO_IMP,MCA_IMP_DIRECTA,CANT_COPIAS,MCA_ENVIO_CORREO,
                       RUTA_RAIZ_HISTORICO,MCA_PRIMACIA,MCA_BORRADO_FISICO,MODULO_LISTADO,TIP_FORMATO,MCA_PTF
                     ) 
     values ( 'aviso_cobro_prf_bco_nacional','CSV','S','S','S','N',null,'TRON2000',
              sysdate,'1','DEFECTO','N','N','1','S',null,null,'N',null,'VC',null
            );
-- G1010161
Insert into G1010161 ( COD_LISTADO,COD_IDIOMA,NUM_LINEA,NOM_LISTADO,COD_USR,
                       FEC_ACTU,MCA_SUBINFORME,NOM_PRG
                     ) 
    values ( 'aviso_cobro_prf_bco_nacional','ES','1','AVISO COBRO PRF BCO NAC.','TRON2000',
             sysdate, 'N','gc_k_cobro_aviso_bco_nacional.p_aviso_cobro_globales'
           );