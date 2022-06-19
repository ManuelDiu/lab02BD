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



-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- Previo a la generación de resultados debe cerrar el sorteo para no recibir más apuestas.
CREATE OR REPLACE FUNCTION cerrarSorteo()
RETURNS trigger AS $$
	DECLARE
		contador integer;
	BEGIN
		UPDATE sorteos SET abierto=false WHERE id = NEW.id_sorteo;
		RETURN NEW;
	END;
$$ LANGUAGE 'plpgsql';

--disparador
CREATE TRIGGER cerrarSorteo
BEFORE INSERT ON resultados
FOR EACH ROW
EXECUTE PROCEDURE cerrarSorteo();

INSERT INTO sorteos (fecha, abierto) VALUES ('2022-06-19', true);
INSERT INTO resultados (fecha, id_sorteo, n1, n2, n3, n4, n5) VALUES ('2022-06-20', 03, 17, 25, 36, 45, 38);


-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- Realizar Sorteo.
CREATE OR REPLACE FUNCTION realizarSorteo()
RETURNS void AS $$
	DECLARE
		id_sorteo_abierto integer;
		n1 integer;
		n2 integer;
		n3 integer;
		n4 integer;
		n5 integer;	
	BEGIN
		SELECT id INTO id_sorteo_abierto
		FROM sorteos WHERE abierto=true;
		IF (not found) THEN
			RAISE NOTICE 'No hay ningun sorteo abierto en este momento.';
			RETURN;
		END IF;
		n1 = rnd_integer(1, 45);
		n2 = rnd_integer(1, 45);
		n3 = rnd_integer(1, 45);
		n4 = rnd_integer(1, 45);
		n5 = rnd_integer(1, 45);
		INSERT INTO resultados (fecha, id_sorteo, n1, n2, n3, n4, n5) 
		VALUES (CURRENT_DATE, id_sorteo_abierto, n1, n2, n3, n4, n5); --Se podria validar que la fecha sea mayor a la del sorteo pero complica el testing
	END;
$$ LANGUAGE 'plpgsql';

select * from sorteos;
INSERT INTO sorteos (fecha, abierto) VALUES ('2022-06-20', true);
select realizarsorteo();
select * from resultados;

-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


-- Revisar Jugada. (DUDAS, SIN HACER)
CREATE OR REPLACE FUNCTION revisarJugada(integer)
RETURNS void AS $$
	DECLARE
		cant_3aciertos integer;
		cant_4aciertos integer;
		cant_5aciertos integer;
		num1 integer;
		num2 integer;
		num3 integer;
		num4 integer;
		num5 integer;
		idsorteojugada integer;
		
		res1 integer;
		res2 integer;
		res3 integer;
		res4 integer;
		res5 integer;
		
	BEGIN
		IF ($1 IS NULL) THEN
			RAISE NOTICE 'Por favor proporcione una CI.';
			return;
		END IF;
		SELECT n1, n2 , n3, n4, n5, id_sorteo INTO num1, num2, num3, num4, num5, idsorteojugada
		FROM jugadas WHERE ci = $1;
		IF (not found) THEN
			RAISE NOTICE 'No hay ninguna jugada registrada con esa CI.';
			RETURN;
		END IF;
		SELECT n1, n2 , n3, n4, n5 INTO res1, res2, res3, res4, res5 
		FROM resultados WHERE id_sorteo = idsorteojugada;
		
		
		cant_3aciertos = 0; --serían variables anfitrionas
		cant_4aciertos = 0;
		cant_5aciertos = 0;

		--...
		--comparamos numeros y sumamos 1 a los contadores si coinciden 3 veces o más
		--...

		
		
		--...
		--...
	END;
$$ LANGUAGE 'plpgsql';
