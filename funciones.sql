CREATE OR REPLACE FUNCTION validarSorteo()
RETURNS trigger AS $$
DECLARE
	contador integer;
BEGIN
	SELECT COUNT(*) INTO contador FROM sorteos WHERE abierto=true;
	IF (contador > 0) THEN
		RAISE NOTICE 'Ya hay un sorteo abierto.';
		RETURN NULL;
	END IF;
	IF (NEW.fecha < current_date) THEN
		RAISE NOTICE 'Ingrese una fecha superior a la fecha actual.';
		RETURN NULL;
	END IF;
	IF (NEW.abierto = false) THEN
		RAISE NOTICE 'No se permite insertar un sorteo cerrado.';
		RETURN NULL;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

--disparador
CREATE TRIGGER validarSorteo
BEFORE INSERT ON sorteos
FOR EACH ROW
EXECUTE PROCEDURE validarSorteo();

INSERT INTO sorteos (fecha, abierto) VALUES ('2022-06-12', false);
delete from sorteos where abierto=true;

