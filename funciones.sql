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


-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


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


-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


CREATE OR REPLACE FUNCTION validarJugadas()
RETURNS trigger AS $$
DECLARE
   ciCliente CHARACTER(8);
   sorteoId INT;

BEGIN

   SELECT ci INTO ciCliente FROM cuentas WHERE ci = NEW.ci;
   IF NOT FOUND THEN
    RAISE NOTICE 'El cliente no existe';
	RETURN NULL;
   END IF;
   
   SELECT id INTO sorteoId FROM sorteos WHERE abierto = true;
   IF NOT FOUND THEN
    RAISE NOTICE 'No existe un sorteo Vigente';
	RETURN NULL;
   END IF;
 
 
   IF NEW.n1 < 1  OR NEW.n1 > 45 THEN
    RAISE NOTICE 'Nro 1 no comprende el rango entre 1y 45';
	RETURN NULL;
   END IF;
   
   IF NEW.n2< 1  OR NEW.n2> 45 THEN
    RAISE NOTICE 'Nro 2 o comprende el rango entre 1y 45';
	RETURN NULL;
   END IF;
   
   IF NEW.n3 < 1  OR NEW.n3> 45 THEN
    RAISE NOTICE 'Nro 3    no comprende el rango entre 1y 45';
	RETURN NULL;
   END IF;
   
   IF NEW.n4 < 1  OR NEW.n4 > 45 THEN
    RAISE NOTICE 'Nro 4 no comprende el rango entre 1y 45';
	RETURN NULL;
   END IF;
   
    IF NEW.n5 < 1  OR NEW.n5 > 45 THEN
    RAISE NOTICE 'Nro 5 no comprende el rango entre 1y 45';
	RETURN NULL;
   END IF;
   
   RETURN new;

END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER validar_jugadas 
BEFORE INSERT ON jugadas FOR EACH ROW 
EXECUTE PROCEDURE validarJugadas();


-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


CREATE OR REPLACE FUNCTION crearCuenta()
RETURNS trigger
AS $$
BEGIN
	if (new.ci is null) then
        RAISE NOTICE 'La cedula de identidad no puede estar vacia.';
		RETURN NULL;
    end if;
	if (new.ci !~ '[0-9]') then
		RAISE NOTICE 'Solo numeros por favor.';
    	RETURN NULL;
	end if;

	if (age(new.fnacimiento) < interval '18 years') then
        RAISE NOTICE 'El Usuario no puede ser menor de edad';
		RETURN NULL;
    end if;
	if (new.nombre is null) then
        RAISE NOTICE 'El nombre no puede ser vacio.';
		RETURN NULL;
    end if;
	if (new.nombre SIMILAR TO '%[0-9@$?¡_.!]%') then 
        RAISE NOTICE 'El campo nombre solo puede contener letras.';
		RETURN NULL;
    end if;
	if (new.apellido is null) then
        RAISE NOTICE 'El apellido no puede ser vacio.';
		RETURN NULL;
    end if;
	
	if (new.apellido SIMILAR TO '%[0-9@$?¡_.!]%') then
        RAISE NOTICE 'El campo apellido solo puede contener letras.';
		RETURN NULL;
    end if;
    return new;
END;
$$ LANGUAGE 'plpgsql';

Create trigger crearCuenta
before insert or update on cuentas
for each row
execute procedure crearCuenta();

insert into cuentas (ci, nombre, apellido, fnacimiento) VALUES ('456546', 'asdasd', 'Diu', '02-04-2002');
select * from cuentas;
-- *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

