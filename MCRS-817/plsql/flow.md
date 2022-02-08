# flujo de Proceso

### Paso        Proceso                             Descripcion
*   1           p_inicio_proceso                    Determina las globales y establece el entorno
*   2           f_archivo_procesado                 Verifica si el archivo fue registrado o procesado
*   3           p_reinicia_registro                 Reinicia los marcadores de proceso del registro de archivo
*   4           p_procesar_archivo                  Procesa el archivo suministrado, linea a linea  
*   4.1         p_tratar_linea                      Trata la linea del archivo
*   4.1.1       p_numero_poliza                     Determina el numero de poliza asociado a la tarjeta de credito
*   4.1.2       p_recibo_poliza                     Determina los recibos a asociar al pago
*   4.1.3       p_agregar_a_lista                   Transforma la linea de archivo en un registro y lo agrega a una tabla PL/SQL
*   4.2         p_registrar_aviso                   Registra los datos en la tabla a5021691_mcr
*   5           p_procesar_aviso_cobro              Procesa el aviso de cobro
*   5.1         f_verifica_poliza_grupo             Verifica que grupos de polizas son validas
*   5.2         dc_f_val_cambio                     Determina el valor de cambio para la fecha
*   5.3         gc_k_a5021646.p_inserta_por_campos  Crea la cabecera de documentos de pagos
*   5.4         gc_p_remesa_letra                   Genera movimiento de remesa de los recibos de una letra, recibo a recibo.
*   5.5         pi_actualiza_aviso                  Actualiza la tabla a2990700 y a5021691_mcr
*   5.6         gc_p_cambia_gestor_recibo           Se procede a cambio de gestor si aplica
*   5.7         pi_actualiza_registro               Registra el resultado de la operacion en la tabla a5021691_mcr
*   5.8         p_lista_aviso_cobro                 Genera el listado de aviso de cobro
*   6           p_fin_proceso                       Finaliza el proceso
