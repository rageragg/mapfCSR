
/*
Se hacen las pruebas pero al ejecutar el select luego de esperar un buen tiempo no devuelve resultados, se queda enciclado, 
estos son los parametros con los que se realiza la prueba
*/
select *
from table(
gc_k_mov_economico_mcr.f_list_mov_economico( p_cod_cia => 1,
p_tip_docum => 'CJU',
p_cod_docum => 3101367292,
p_fecha_desde => to_date('01012020','ddmmyyyy'),
p_fecha_hasta => to_date('01062020','ddmmyyyy')
)
);

/*
Haciendo otro ejercicio para otra cedula en especifico nos devuelve muchisimos resultados, 
pero noto que vienen diferentes fechas que no corresponde al periodo que estoy consultando:
*/
select *
from table(
gc_k_mov_economico_mcr.f_list_mov_economico( p_cod_cia => 1,
p_tip_docum => 'CNA',
p_cod_docum => '105380787',
p_fecha_desde => to_date('17012020','ddmmyyyy'),
p_fecha_hasta => to_date('17012020','ddmmyyyy')
)
);

/*
Otro ejercicio trayendo todo en un rango de fecha, de un dia devuelve muchos movimientos como el caso 
anterior no correspondientes a la fecha que se esta consultando:
*/

select *
from table(
gc_k_mov_economico_mcr.f_list_mov_economico( p_cod_cia => 1,
p_tip_docum => null,
p_cod_docum => null,
p_fecha_desde => to_date('16012020','ddmmyyyy'),
p_fecha_hasta => to_date('16012020','ddmmyyyy')
)
);