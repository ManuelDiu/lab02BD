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


CREATE OR REPLACE FUNCTION revisarJugada(character)
RETURNS text  AS $$
	DECLARE
		contador_aciertos integer;
        
        cont3 int;
		cont4 int;
        cont5 int;

        reg RECORD;
		idsorteojugada integer;
        
		res1 integer;
		res2 integer;
		res3 integer;
		res4 integer;
		res5 integer;
        
        cant_jugadas integer;
		result_string VARCHAR;
	BEGIN
		IF ($1 IS NULL) THEN
			RAISE NOTICE 'Por favor proporcione una CI.';
            RETURN NULL;
		END IF;
       
        
        SELECT n1, n2 , n3, n4, n5 , id_sorteo INTO res1, res2, res3, res4, res5, idsorteojugada
		FROM resultados JOIN sorteos ON sorteos.id = resultados.id WHERE sorteos.abierto = false order by sorteos.fecha desc limit 1;
        IF NOT FOUND THEN
            RAISE NOTICE 'Aun no se ha publicado el resultado de algun sorteo';
            RETURN NULL;
        END IF;
        
		SELECT COUNT(*) into cant_jugadas from jugadas join sorteos on sorteos.id = jugadas.id_sorteo where ci = $1 AND sorteos.id = idsorteojugada;

        IF cant_jugadas <= 0 THEN
            RAISE NOTICE 'El jugador no ha realizado jugadas';
            RETURN NULL;
        end if;
           
        cont3 := 0;
        cont4 := 0;
        cont5 := 0;
        
        contador_aciertos := 0;
		for reg in SELECT * from jugadas join sorteos on sorteos.id = jugadas.id_sorteo where jugadas.ci = $1 and sorteos.id = idsorteojugada
            LOOP
                

                if (reg.n1 = res1 or reg.n1 = res2 or reg.n1 = res3 or reg.n1 = res4 or reg.n1 = res5) THEN
                    contador_aciertos := contador_aciertos + 1;
                end if;
                
                if (reg.n2 = res1 or reg.n2 = res2 or reg.n2 = res3 or reg.n2 = res4 or reg.n2 = res5) then
                    contador_aciertos := contador_aciertos + 1;
                end if;
                
                if (reg.n3 = res1 or reg.n3 = res2 or reg.n3 = res3 or reg.n3 = res4 or reg.n3 = res5) then 
                    contador_aciertos := contador_aciertos + 1;
                end if;
                
                if (reg.n4 = res1 or reg.n4 = res2 or reg.n4 = res3 or reg.n4 = res4 or reg.n4 = res5) then
                    contador_aciertos := contador_aciertos + 1;
                end if;
                
                if(reg.n5 = res1 or reg.n5 = res2 or reg.n5 = res3 or reg.n5 = res4 or reg.n5 = res5) then
                    contador_aciertos := contador_aciertos + 1;
                end if;
                
                if (contador_aciertos = 3) THEN
                    cont3 := cont3 + 1;
                elseif (contador_aciertos = 4) then
                    cont4 := cont4 + 1;
                elseif (contador_aciertos = 5) then
                    cont5 := cont5 +1;
                end if;
                contador_aciertos := 0;
		    end loop;
            
		SELECT CONCAT( 'Cantidad de aciertos de 3 números: ',cont3 , E'\n',
                     'Cantidad de aciertos de 4 numeros: ' , cont4, E'\n',
                     'Cantidad de aciertos de 5 numeros: ' , cont5, E'\n') INTO result_string;
        return result_string;
	END;
$$ 
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION validarJugadas()
RETURNS trigger AS $$
DECLARE
   ciCliente CHARACTER(8);
   sorteoId INT;

BEGIN

   SELECT ci INTO ciCliente FROM cuentas WHERE ci = NEW.ci;
   IF NOT FOUND THEN
      RAISE 'El cliente no existe';
   END IF;
   
   SELECT id INTO sorteoId FROM sorteos WHERE abierto = true;
   IF NOT FOUND THEN
      RAISE 'No existe un sorteo Vigente';
   END IF;
 
 
   IF NEW.n1 < 1  OR NEW.n1 > 45 THEN
        RAISE 'Nro 1 no comprende el rango entre 1y 45';
   END IF;
   
   IF NEW.n2< 1  OR NEW.n2> 45 THEN
        RAISE 'Nro 2 o comprende el rango entre 1y 45';
   END IF;
   
   IF NEW.n3 < 1  OR NEW.n3> 45 THEN
        RAISE 'Nro 3    no comprende el rango entre 1y 45';
   END IF;
   
   IF NEW.n4 < 1  OR NEW.n4 > 45 THEN
        RAISE 'Nro 4 no comprende el rango entre 1y 45';
   END IF;
   
    IF NEW.n5 < 1  OR NEW.n5 > 45 THEN
        RAISE 'Nro 5 no comprende el rango entre 1y 45';
   END IF;
   
   
   RETURN new;


END;
$$ LANGUAGE 'plpgsql';



CREATE OR REPLACE TRIGGER validar_jugadas 
BEFORE INSERT ON jugadas FOR EACH ROW 
EXECUTE PROCEDURE validarJugadas();

15 6 10 13 1


