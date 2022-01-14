-- PROGRAMAS
Insert into PROGRAMAS ( COD_PGM,TXT_PGM,TIP_PGM,VAL_PACKAGE,MCA_EXTERNO,MCA_TAR,COD_VERSION,
                        NUM_ICONO,COD_TRONWEB,NUM_SESIONES,STATUS,FEC_ACTU,URL_OPERACION
                      ) 
               values ( 'MCRGC10610','AVISO COBRO PRF BCO. NAC.', 
                        'TAR',null,'N','S',null,2,'J13',null,null,
                        trunc(sysdate),null
                      );
-- G1010100 PROGRAMAS DE UN MENU
Insert into G1010100 ( COD_CIA,COD_PADRE,NUM_SECU,COD_PGM,FEC_ACTU ) 
     values ( '1', 'AM700100', '42','MCRGC10610', trunc(sysdate) );
-- G1010110 NOMBRE DE PROGRAMAS
Insert into G1010110 ( COD_PGM,COD_IDIOMA,NOM_PGM,FEC_ACTU ) 
              values ( 'MCRGC10610', 'ES', 'AVISO COBRO PRF BCO. NAC.', trunc(sysdate) );
-- G1010210 ROLES PERMITIDOS PARA ACCEDER A UN PROGRAMA
Insert into G1010210 ( COD_ROL,COD_PGM,MCA_CONSULTA,FEC_ACTU ) 
              values ( '1','MCRGC10610','N', trunc(sysdate) );
Insert into G1010210 ( COD_ROL,COD_PGM,MCA_CONSULTA,FEC_ACTU ) 
              values ( 'LANZATAREA','MCRGC10610','N', trunc(sysdate) );           
