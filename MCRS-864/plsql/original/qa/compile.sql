
BEGIN
    --
    -- paquetes
    FOR cur_rec IN ( SELECT owner,
                            object_name,
                            object_type,
                            decode(object_type, 'PACKAGE', 1,
                                                'PACKAGE BODY', 2, 2
                                    ) AS recompile_order
                       FROM dba_objects
                      WHERE object_type IN ('PACKAGE', 'PACKAGE BODY')
                        AND status != 'VALID'
                        AND owner = 'TRON2000'
                     ORDER BY 4
                   )
    LOOP
        BEGIN
        IF cur_rec.object_type = 'PACKAGE' THEN
            dbms_output.put_line( 'ALTER ' || cur_rec.object_type || 
                ' "' || cur_rec.owner || '"."' || cur_rec.object_name || '" COMPILE;' );
        ElSE
            dbms_output.put_line('ALTER PACKAGE "' || cur_rec.owner ||   '"."' || cur_rec.object_name || '" COMPILE BODY;' );
        END IF;
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.put_line(cur_rec.object_type || ' : ' || cur_rec.owner || 
                                ' : ' || cur_rec.object_name);
        END;
    END LOOP;
    --
    -- tipos
    FOR cur_rec IN ( SELECT owner,
                            object_name,
                            object_type,
                            decode(object_type, 'TYPE', 1,
                                                'TYPE BODY', 2, 2
                                    ) AS recompile_order
                       FROM dba_objects
                      WHERE object_type IN ('TYPE', 'TYPE BODY')
                        AND status != 'VALID'
                        AND owner = 'TRON2000'
                     ORDER BY 4
                   )
    LOOP
        BEGIN
        IF cur_rec.object_type = 'TYPE' THEN
            dbms_output.put_line( 'ALTER ' || cur_rec.object_type || 
                ' "' || cur_rec.owner || '"."' || cur_rec.object_name || '" COMPILE;' );
        ElSE
            dbms_output.put_line( 'ALTER TYPE "' || cur_rec.owner ||   '"."' || cur_rec.object_name || '" COMPILE BODY;' );
        END IF;
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.put_line(cur_rec.object_type || ' : ' || cur_rec.owner || 
                                ' : ' || cur_rec.object_name);
        END;
    END LOOP;
    --
END;