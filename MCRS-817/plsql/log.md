# Registro de Actividades Resaltantes
### Fecha       Descripcion
* 14/01/2022    Se coloca al control github esta solicitud
* 14/01/2022    Se modifica el paquete gc_k_cobro_aviso_bco_nacional, funcion **f_verifica_poliza_grupo**, en QA
* 14/01/2022    Se modifica el paquete gc_k_cobro_aviso_bco_nacional, procedimiento **p_numero_poliza**, se filtra por ramo 230
* 08/02/2022    Se modifica la seleccion de los recibos, eliminando la restriccion del mes y anho.
* 08/02/2022    Se ajusta el proceso para actualizar la tabla a5021691_mcr luego del procesamiento

                
### Objetos Relacionados
- **gc_k_cobro_aviso_bco_nacional**, Paquete de Procesamiento de datos de la solicitud
- programa_config, Configuracion del programa para la ejecucion de tronweb
- reporte_config, Configuracion del reporte para la ejecucion de tronweb
- tarea_config, Configuracion de la tarea para la ejecucion de tronweb, se ejecuta esta tarea via 
  gc_k_cobro_aviso_bco_nacional.p_aviso_cobro_globales, tarea: **MCRGC10610**