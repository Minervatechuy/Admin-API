SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `minervatech`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `add_usuario_entidad` (IN `mail` VARCHAR(510), IN `entidad` VARCHAR(510))   BEGIN
INSERT INTO `users_to_entites` (`user_email`, `entity_id`) VALUES (mail, entidad);
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `comprar_token` ()   BEGIN

SELECT token INTO @token FROM `tokens` WHERE vendido=0 LIMIT 1;
UPDATE `tokens` SET `vendido` = '1'  WHERE token=@token;
SELECT @token;

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `count_users_by_email` (IN `emai` VARCHAR(255))   BEGIN 
	SELECT count(mail) 
    FROM users
    WHERE mail=email AND  pass=pasw;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `createCalculator` (IN `token` VARCHAR(40), IN `url` VARCHAR(255), IN `ip` VARCHAR(255), IN `entidad` VARCHAR(50), IN `nombre` VARCHAR(120), IN `email` VARCHAR(255))   BEGIN

	DECLARE pToken VARCHAR(40);
    DECLARE pUrl VARCHAR(255);
    DECLARE pIp VARCHAR(255);
    DECLARE pEntidad VARCHAR(50);
    DECLARE pNombre VARCHAR(255);
    DECLARE pEmail VARCHAR(255);
    
    SET pToken = token;
    SET pUrl = url;
    SET pIp = ip;
    SET pEntidad = entidad;
    SET pNombre = nombre;
    SET pEmail = email;
    
    INSERT INTO  calculators(token, url, ip, formula, entity_ID, name, activo)
    VALUES (pToken, pUrl, pIp, NULL, pEntidad, pNombre, 1);
    
	INSERT INTO users_to_calculators
    VALUES (pEmail, pToken);
    
    INSERT INTO entidades_calculadoras
    VALUES (pEntidad, pToken);
    
	UPDATE tokens t 
    SET t.canjeado = 1 
    WHERE t.token = pToken;
    
    
    SELECT count(*)
    FROM calculators c 
    WHERE c.token = pToken;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `create_entidad` (IN `id` VARCHAR(510), IN `nombre` VARCHAR(510), IN `telefono` VARCHAR(510), IN `direccion` VARCHAR(510), IN `type` VARCHAR(510), IN `activo` VARCHAR(510), IN `descripcion` VARCHAR(510), IN `usuario` VARCHAR(510))   BEGIN

INSERT INTO `entities` (`ID`, `nombre`, `telefono`, `direccion`, `type`, `activo`, `descripcion`) VALUES (id, nombre, telefono, direccion, type, '1', descripcion);
INSERT INTO `users_to_entites` VALUES (usuario, id);

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `create_presupuesto` (IN `token` VARCHAR(255), IN `formula` VARCHAR(255), IN `email_cliente` VARCHAR(510), IN `name_cliente` VARCHAR(510), IN `telefono_cliente` VARCHAR(510))   BEGIN

INSERT INTO `presupuestos` (`id`, `resultado`, `formula`, `finalizado`) VALUES (NULL, NULL, formula, '0');

SET @v1 := (SELECT LAST_INSERT_ID());

INSERT INTO `calculadoras_presupuestos_clientes` (`token`, `presupuestos_id`, `fecha`, `email_cliente`) VALUES (token, @v1, now(), email_cliente);

SELECT LAST_INSERT_ID();

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `delete_calc` (IN `token` VARCHAR(255))   BEGIN
SET foreign_key_checks = 0;
DELETE FROM `calculators` WHERE `calculators`.`token` = token;
SET foreign_key_checks = 1;
DELETE FROM `users_to_calculators` WHERE `users_to_calculators`.`calculator_token` = token;
UPDATE `tokens` SET `canjeado` = '0' WHERE `tokens`.`token` = token;

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `delete_dato_de_etapa` (IN `etapa_id` INT)   DELETE FROM `etapa_data` WHERE `etapa_data`.`etapa_id` = etapa_id$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `delete_entidad` (IN `entidad_id` VARCHAR(255))   BEGIN
SET FOREIGN_KEY_CHECKS=0;
DELETE FROM `users_to_entites` WHERE `users_to_entites`.`entity_id` = entidad_id;
DELETE FROM `entities` WHERE `entities`.`ID` = entidad_id;
SET FOREIGN_KEY_CHECKS=1;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `delete_etapa` (IN `identificador` INT)   BEGIN

SELECT e.posicion, e.token
INTO @pos, @tok
FROM etapa e
WHERE e.id=identificador;

DELETE FROM `etapa` WHERE `etapa`.`id` = identificador;

UPDATE etapa e SET e.posicion = e.posicion-1 WHERE e.token = @tok and e.posicion>@pos; 

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `delete_etapa_data` (IN `etapa_id` INT, IN `meta_key` VARCHAR(510))   BEGIN

DELETE FROM `etapa_data` WHERE `etapa_data`.`etapa_id` =etapa_id AND `etapa_data`.`meta_key`=meta_key;

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `delete_etapa_de_calculadora` (IN `token` VARCHAR(255))   DELETE FROM `etapa` WHERE `etapa`.`token` = token$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `delete_etapa_opcion` (IN `etapa_id` INT, IN `meta_key` VARCHAR(510))   BEGIN
DELETE FROM etapa_opcion WHERE etapa_opcion.etapa_id = etapa_id AND etapa_opcion.meta_key=meta_key;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `delete_opcion` (IN `etapa_id` INT)   BEGIN
DELETE FROM etapa_opcion WHERE etapa_opcion.id= etapa_id;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `delete_opcion_de_etapa` (IN `etapa_id` INT)   DELETE FROM `etapa_opcion` WHERE `etapa_opcion`.`etapa_id` = etapa_id$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `delete_user` (IN `email` VARCHAR(255))   BEGIN
DELETE FROM users
WHERE email= email;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `delete_usuario_entidad` (IN `email` VARCHAR(510), IN `entidad_id` VARCHAR(510))   BEGIN
DELETE FROM `users_to_entites` WHERE `users_to_entites`.`user_email` = email AND `users_to_entites`.`entity_id` = entidad_id;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `editProfile` (IN `email` VARCHAR(255), IN `pass` VARCHAR(255), IN `nombre` VARCHAR(255), IN `tlf` VARCHAR(255), IN `apellidos` VARCHAR(255))   BEGIN
UPDATE `6705937_calculadoras`.`usuarios` SET `pass` = pass, `telefono` = tlf, `nombre` = nombre, `apellidos` = apellidos 
WHERE (`mail` = email);
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `editStagePos` (IN `id` INT, IN `pos` INT)   BEGIN
UPDATE `etapa` SET `posicion` = pos WHERE `etapa`.`id` = id;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `edit_calulators` (IN `token` VARCHAR(255), IN `nombre` VARCHAR(255), IN `url` VARCHAR(255), IN `entidad` VARCHAR(255))   UPDATE `calculators` SET `url` = url, `entity_ID` = entidad, `name` = nombre WHERE `calculators`.`token` = token$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `edit_entidad` (IN `id` VARCHAR(255), IN `nombre` VARCHAR(510), IN `telefono` VARCHAR(510), IN `direccion` VARCHAR(510), IN `tipo` VARCHAR(510))   BEGIN
UPDATE `entities` SET `ID` = id, `nombre` = nombre, `telefono` = telefono, `direccion` = direccion, `type` = tipo WHERE `entities`.`ID` = id;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `edit_etapa` (IN `etapa_id` INT, IN `titulo` VARCHAR(255), IN `subtitulo` VARCHAR(255))   BEGIN
UPDATE `etapa` SET `titulo` = titulo, `subtitulo` = subtitulo WHERE `etapa`.`id` = etapa_id;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `edit_etapa_data` (IN `etapa_id` INT, IN `meta_key` VARCHAR(255), IN `meta_value` VARCHAR(255))   BEGIN
UPDATE `etapa_data` SET `meta_value` = meta_value WHERE `etapa_data`.`etapa_id` = etapa_id AND `etapa_data`.`meta_key`= meta_key;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `edit_etapa_opcion` (IN `etapa_id` INT, IN `pMetaKey` VARCHAR(510), IN `pMetaValue` VARCHAR(510), IN `imagen` LONGBLOB)   BEGIN

UPDATE `etapa_opcion`
SET `meta_value` = pMetaValue, etapa_opcion.imagen= imagen
WHERE `etapa_opcion`.`etapa_id` = etapa_id
AND `etapa_opcion`.`meta_key` = pMetaKey;

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `existEmail` (IN `email` VARCHAR(255))   BEGIN 
	SELECT count(*) 
    FROM usuarios u
    WHERE u.mail = email;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `existUserInUsersTable` (IN `email` VARCHAR(255))   BEGIN 
	SELECT count(mail) 
    FROM usuarios
    WHERE mail=email;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `exist_user_entidad` (IN `email` VARCHAR(510), IN `entidad` VARCHAR(510))   BEGIN
SELECT COUNT(*)
FROM users_to_entites ue
WHERE ue.user_email=email AND ue.entity_id=entidad;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `exist_usuario` (IN `email` VARCHAR(255), IN `pasw` VARCHAR(255))   BEGIN 
	SELECT count(mail) 
    FROM usuarios
    WHERE mail=email AND  pass=pasw;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `getAllStagesOfUser` (IN `email` VARCHAR(255), IN `id` INT)   BEGIN
SELECT * FROM users u, users_to_calculators utc, calculators c, etapa e WHERE u.mail=utc.user_email AND utc.calculator_token=c.token AND c.token=e.token AND u.mail=email AND etapa.id= id;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `getCalcFormula` (IN `token` VARCHAR(255))   BEGIN
	SELECT c.formula
FROM calculators c 
WHERE c.token=token;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `getCalcsInfo` (IN `mail` VARCHAR(255))   BEGIN
	SELECT c.name, c.url, c.ip, c.formula, c.entity_ID, c.name, c.activo, c.token
FROM usuarios u, calculators c, users_to_calculators utc
WHERE u.mail=utc.user_email AND c.activo=1 AND utc.calculator_token=c.token AND u.mail=mail;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `getCalcsOfUser` (IN `mail` VARCHAR(255), OUT `result` VARCHAR(255))   BEGIN
	SELECT GROUP_CONCAT(DISTINCT c.name)
FROM users u, calculators c, users_to_calculators utc
WHERE u.mail=utc.user_email AND c.activo=1 AND utc.calculator_token=c.token AND u.mail=mail;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `getCalcStagesId` (IN `token` VARCHAR(255))   BEGIN

SELECT e.id
FROM etapa e
WHERE e.token=token;

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `getClientEmailOcurrences` (IN `email` VARCHAR(510))   BEGIN

SELECT COUNT(*)
FROM clientes cli
WHERE cli.email=email;

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `getClientsCount` (IN `mail` VARCHAR(255), OUT `result` VARCHAR(255))   BEGIN
	SELECT COUNT(DISTINCT ibc.email_cliente)
    FROM calculadoras_presupuestos_clientes ibc
    WHERE ibc.token IN (
    	SELECT uc.user_email 
        FROM users_to_calculators uc
        WHERE uc.user_email = mail
    );
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `getOpcion` (IN `identificador` INT)   BEGIN
SELECT *
FROM etapa_opcion o
WHERE o.id= identificador OR o.id= identificador+1 OR o.id= identificador+2;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `getOpciones` (IN `identificador` INT)   BEGIN
SELECT *
FROM etapa_opcion o
WHERE o.etapa_id= identificador
ORDER BY o.id;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `getQueriesCount` (IN `mail` VARCHAR(255), OUT `result` VARCHAR(255))   BEGIN
	SELECT count(*)
    FROM calculadoras_presupuestos_clientes ibc
    WHERE ibc.token IN (
    	SELECT uc.calculator_token 
        FROM users_to_calculators uc
        WHERE uc.user_email = mail
    );
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `getSpecificCalculatorInfo` (IN `token` VARCHAR(255))   BEGIN
	SELECT c.name, c.url, c.ip, c.formula, c.entity_ID, c.name, c.activo, c.token
FROM usuarios u, calculators c, users_to_calculators utc
WHERE u.mail=utc.user_email AND c.activo=1 AND utc.calculator_token=c.token AND c.token=token;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `getStageGeneralInfo` (IN `id` INT)   BEGIN
SELECT * FROM etapa e WHERE e.id=id;	
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `getStageInfo` (IN `id` INT)   BEGIN 

SELECT ed.* FROM etapa e, etapa_data ed WHERE e.id=id AND e.id=ed.etapa_id;

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `getStageInsertedValue` (IN `p_etapa_id` INT, IN `n_presupuesto` INT)   BEGIN

SELECT meta_value FROM presupuestos_data WHERE etapa_id= p_etapa_id AND presupuesto_id= n_presupuesto;

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `getStagesGeneralInfo` (IN `token` VARCHAR(255))   BEGIN
    SELECT *
    FROM etapa e
    WHERE e.token= token
    ORDER BY e.posicion ASC;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `getStageType` (IN `identificador` INT)   BEGIN
SELECT tipo
FROM etapa e
WHERE e.id= identificador;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `getTeamMates` (IN `mail` VARCHAR(255), OUT `result` VARCHAR(255))   BEGIN
	SELECT count(DISTINCT u.user_email)
    FROM users_to_calculators u
    WHERE u.user_email IN(
    	SELECT uc.user_email
        FROM users_to_calculators uc
        WHERE uc.calculator_token IN (
        	SELECT utc.calculator_token
            FROM users_to_calculators utc
            WHERE utc.user_email = mail
        )
    );
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `getTipoEtapa` (IN `p_posicion` INT)   BEGIN 

SELECT e.tipo
FROM etapa e
WHERE e.posicion=p_posicion;

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `getUserEntities` (IN `mail` VARCHAR(255))   BEGIN
	SELECT e.nombre, e.telefono, e.direccion, e.type, e.descripcion, e.ID
FROM usuarios u, entities e, users_to_entites ue
WHERE u.mail=mail AND ue.user_email=u.mail AND ue.entity_id=e.ID AND e.activo=1;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `get_all_users` ()   BEGIN
SELECT *
FROM users;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `get_entidad` (IN `id` VARCHAR(255))   BEGIN
SELECT *
FROM entities e
WHERE e.ID=id;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `get_etapa_actual` (IN `prueba` VARCHAR(255), IN `posicion` VARCHAR(255))   BEGIN
SELECT * 
FROM etapa e
WHERE e.token=prueba AND e.posicion= posicion-1;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `get_id_de_posicion` (IN `url` VARCHAR(5100), IN `posicion` INT)   BEGIN
SELECT e.id
FROM etapa e, calculators c
WHERE c.url=url AND c.token= e.token AND e.posicion=posicion;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `get_monthly_average` (IN `p_etapa_id` INT, IN `n_presupuesto` INT)   BEGIN
    SELECT presupuestos_data.meta_value
    FROM presupuestos_data
    JOIN etapa ON etapa.id = presupuestos_data.etapa_id
    WHERE presupuestos_data.etapa_id = p_etapa_id
        AND presupuestos_data.presupuesto_id = n_presupuesto
        AND etapa.titulo LIKE '%UTE%';
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `get_presupuestos_calculadora` (IN `token` VARCHAR(510))   BEGIN

SELECT p.id, p.resultado, p.formula, p.finalizado, cli.email, cli.telephone, cli.name, cpc.fecha
FROM calculators c, calculadoras_presupuestos_clientes cpc, presupuestos p, clientes cli
WHERE c.token=token AND cpc.presupuestos_id=p.id AND cpc.email_cliente=cli.email;

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `get_presupuestos_calculadoras_nombre` (IN `email` VARCHAR(510))   BEGIN

SELECT DISTINCT c.name, c.token
FROM usuarios u, users_to_entites ue, entities e, entidades_calculadoras ec, calculators c, calculadoras_presupuestos_clientes cpc, presupuestos p, clientes cli
WHERE u.mail=email AND u.mail=ue.user_email AND ue.entity_id=e.ID AND ue.entity_id=ec.id_entidad AND ec.token=cpc.token AND cpc.token=c.token AND cpc.presupuestos_id=p.id AND cpc.email_cliente=cli.email;

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `get_presupuestos_email` (IN `email` VARCHAR(510))   BEGIN

SELECT c.name, cpc.fecha, cli.email, cli.telephone, cli.name, p.finalizado, p.resultado
FROM usuarios u, users_to_entites ue, entities e, entidades_calculadoras ec, calculators c, calculadoras_presupuestos_clientes cpc, presupuestos p, clientes cli
WHERE u.mail=email AND u.mail=ue.user_email AND ue.entity_id=e.ID AND ue.entity_id=ec.id_entidad AND ec.token=cpc.token AND cpc.token=c.token AND cpc.presupuestos_id=p.id AND cpc.email_cliente=cli.email
ORDER BY cpc.fecha DESC;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `get_presupuestos_entidad` (IN `entidad_id` VARCHAR(255))   BEGIN

SELECT p.id, e.nombre, c.name,  p.resultado, p.formula, p.finalizado, cli.email, cli.telephone, cli.name, cpc.fecha
FROM entities e, entidades_calculadoras ec, calculators c, calculadoras_presupuestos_clientes cpc, presupuestos p, clientes cli
WHERE entidad_id = e.ID AND ec.id_entidad=e.ID AND ec.token=cpc.token AND cpc.presupuestos_id=p.id AND cpc.email_cliente=cli.email;

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `get_sum_presupuestos_data` (IN `presupuesto_id` INT)   BEGIN

SET @resultado := (SELECT SUM(meta_value)
FROM presupuestos_data
WHERE presupuesto_id=presupuesto_id);

UPDATE `presupuestos` SET `finalizado` = '1' WHERE `presupuestos`.`id` = presupuesto_id;

UPDATE `presupuestos` SET `resultado` = @resultado WHERE `presupuestos`.`id` = presupuesto_id;

SELECT @resultado;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `get_ultima_etapa_posicion` (IN `url` VARCHAR(510))   BEGIN

SELECT MAX(e.posicion)
FROM etapa e, calculators c
WHERE c.url=url
AND e.token = c.token;

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `get_user` (IN `email` VARCHAR(255))   BEGIN
    SELECT u.email, u.completeName, u.lastAccess, u.telephone, u.isActive, u.profilePhoto
    FROM users u 
    WHERE u.email=email;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `get_usuario` (IN `email` VARCHAR(255))   BEGIN
SELECT u.telefono, u.nombre, u.apellidos
FROM usuarios u WHERE u.mail=email;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `get_usuarios_entidad` (IN `entidad_id` VARCHAR(510), IN `email` VARCHAR(510))   BEGIN
SELECT ue.user_email, ue.entity_id, u.nombre, u.apellidos
FROM usuarios u, users_to_entites ue WHERE ue.entity_id= entidad_id AND ue.user_email!=email AND u.mail=ue.user_email;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `get_usuario_pass` (IN `email_param` VARCHAR(255))   BEGIN
    SELECT pass
    FROM usuarios
    WHERE mail = email_param;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `insert_client` (IN `email_cliente` VARCHAR(510), IN `name_cliente` VARCHAR(510), IN `telefono_cliente` VARCHAR(510))   BEGIN

INSERT INTO `clientes` (`email`, `name`, `telephone`) VALUES (email_cliente, name_cliente, telefono_cliente);

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `insert_etapa` (IN `token` VARCHAR(255), IN `tipo` VARCHAR(255), IN `titulo` VARCHAR(255), IN `subtitulo` VARCHAR(255))   BEGIN

SET @posicion = 0;

SELECT IFNULL(MAX(e.posicion), -1) AS count into @posicion FROM etapa e WHERE e.token= token;

INSERT INTO `etapa` (`token`, `tipo`, `titulo`, `subtitulo`, `posicion`) VALUES (token, tipo, titulo, subtitulo, @posicion+1);

SELECT LAST_INSERT_ID();

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `insert_etapa_data` (IN `etapa_id` INT, IN `meta_key` VARCHAR(510), IN `meta_value` VARCHAR(510))   BEGIN
INSERT INTO `etapa_data` (`etapa_id`, `meta_key`, `meta_value`) VALUES (etapa_id, meta_key, meta_value);
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `insert_etapa_opcion` (IN `etapa_id` INT, IN `meta_key` VARCHAR(510), IN `meta_value` VARCHAR(510), IN `imagen` LONGBLOB)   BEGIN 
INSERT INTO `etapa_opcion` (`etapa_id`, `meta_key`, `meta_value`, `imagen`) VALUES ( etapa_id, meta_key, meta_value, imagen);
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `insert_log` (IN `p_date` VARCHAR(20), IN `p_time` VARCHAR(8), IN `p_procedure` VARCHAR(255), IN `p_in` VARCHAR(1000), IN `p_out` VARCHAR(1000))   BEGIN
    INSERT INTO logs (`date`, `time`, `procedure`, `in`, `out`)
    VALUES (p_date, p_time, p_procedure, p_in, p_out);
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `insert_movement` (IN `p_date` VARCHAR(20), IN `p_time` VARCHAR(8), IN `p_procedure` VARCHAR(255), IN `p_in` VARCHAR(1000), IN `p_out` VARCHAR(1000))   BEGIN
INSERT INTO `logs` (`date`, `time`, `procedure`, `in`, `out`) VALUES (p_date, p_time, p_procedure, p_in, p_out);
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `insert_presupuesto_data` (IN `presupuesto_id` INT, IN `etapa_id` INT, IN `meta_key` VARCHAR(255), IN `meta_value` VARCHAR(255))   BEGIN

INSERT INTO `presupuestos_data` (`id`, `presupuesto_id`, `meta_key`, `meta_value`, `etapa_id`) VALUES (NULL, presupuesto_id, meta_key, meta_value, etapa_id);

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `insert_user` (IN `email` VARCHAR(255), IN `pwd` VARCHAR(255), IN `telephone` INT(20), IN `completeName` VARCHAR(255), IN `lastAccess` DATE, IN `isActive` TINYINT, IN `profilePhoto` LONGBLOB)   BEGIN
INSERT INTO `users` (`email`, `pwd`, `telephone`, `completeName`, `lastAccess`, `isActive`, `profilePhoto`) VALUES ( email, pwd, telephone, completeName, lastAccess, isActive, profilephoto);
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `insert_usuario` (IN `email` VARCHAR(255), IN `pass` VARCHAR(255), IN `nombre` VARCHAR(255), IN `ultimoAcceso` VARCHAR(255), IN `ip` VARCHAR(255), IN `apellidos` VARCHAR(255), IN `imagen` LONGBLOB)   BEGIN
INSERT INTO `usuarios` (`mail`, `pass`, `telefono`, `nombre`, `ultimoAcceso`, `ultimaIP`, `apellidos`, `activo`, `imagen`) VALUES (email, pass, NULL, nombre, ultimoAcceso, ip, apellidos, '1', imagen);
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `is_user_logged` (IN `email` VARCHAR(255), IN `pasw` VARCHAR(255))   BEGIN 
	SELECT count(email) 
    FROM users u
    WHERE u.email=email AND u.pwd=pasw;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `nextStagePosition` (IN `token` VARCHAR(255))   BEGIN
SELECT max(Position)+1
FROM stages
WHERE token_calculator=token;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `n_dominio_cal` (IN `url` VARCHAR(510))   BEGIN
SELECT COUNT(*)
FROM calculators c
WHERE c.url=url;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `select_calc_by_url` (IN `url` VARCHAR(5100))   BEGIN

SELECT c.token, c.formula
FROM calculators c
WHERE c.url=url;

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `token_disponible` (IN `token` VARCHAR(510))   SELECT count(*)
FROM tokens t
WHERE t.vendido=1 AND t.canjeado=0 AND t.token=token$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `updateFormula` (IN `token` VARCHAR(255), IN `formula` VARCHAR(5100))   BEGIN
UPDATE `calculators` SET `formula` = formula WHERE `calculators`.`token` = token;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `update_presupuesto_resultado` (IN `resultado` INT, IN `n_presupuesto` INT)   BEGIN

UPDATE `presupuestos` SET `resultado` = resultado WHERE `presupuestos`.`id` = n_presupuesto;

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `update_user` (IN `email` VARCHAR(255), IN `pwd` VARCHAR(255), IN `telephone` VARCHAR(255), IN `completeName` VARCHAR(255), IN `lastAccess` DATE, IN `isActive` BOOLEAN, IN `profilePhoto` LONGBLOB)   BEGIN
UPDATE users u
SET u.email= email, u.pwd= pwd, u.telephone= telephone, u.completeName= completeName, u.lastAccess= lastAccess, u.isActive= isActive, u.profilePhoto= profilePhoto WHERE `email` = email;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `verficar_vista` (IN `url` VARCHAR(5100))   SELECT COUNT(*) FROM calculators c, tokens t 
WHERE c.token=t.token AND c.url=url AND c.activo=1 AND t.fechaFin>now() AND t.vendido=1 AND t.canjeado=1$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `verifyIfTokenExists` (IN `pToken` VARCHAR(255))   BEGIN
	SELECT count(*)
    FROM tokens t
    WHERE t.token = pToken
    AND t.canjeado = 0
    AND t.vendido = 1;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `vista_calculadora_n_etapas` (IN `url` VARCHAR(510))   BEGIN
SELECT COUNT(*)
FROM calculators c, etapa e
WHERE c.url=url AND c.token=e.token;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `vista_etapa_opciones_n_opciones` (IN `id` INT)   BEGIN

SELECT COUNT(*)/3
FROM etapa_opcion eo
WHERE eo.etapa_id=id;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `calculadoras_presupuestos_clientes`
--

CREATE TABLE `calculadoras_presupuestos_clientes` (
  `token` varchar(255) NOT NULL,
  `presupuestos_id` int(11) NOT NULL,
  `fecha` date DEFAULT NULL,
  `email_cliente` varchar(510) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `calculadoras_presupuestos_clientes`
--

INSERT INTO `calculadoras_presupuestos_clientes` (`token`, `presupuestos_id`, `fecha`, `email_cliente`) VALUES
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 1, '2023-05-16', 'pruebas@minervatech.uy'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 2, '2023-08-14', 'test@test.test'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 3, '2023-08-14', 'asf@harakirimail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 4, '2023-08-16', 'minervatechuy252000@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 5, '2023-08-17', 'minervatechuy252000@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 6, '2023-08-17', 'minervatechuy252000@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 7, '2023-08-17', 'minervatechuy252000@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 8, '2023-08-17', 'minervatechuy252000@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 9, '2023-08-17', 'minervatechuy252000@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 10, '2023-08-17', 'minervatechuy252000@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 11, '2023-08-17', 'minervatechuy252000@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 12, '2023-08-17', 'minervatechuy252000@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 13, '2023-08-17', 'minervatechuy252000@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 14, '2023-08-17', 'minervatechuy252000@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 15, '2023-08-17', 'minervatechuy252000@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 16, '2023-08-17', 'minervatechuy252000@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 17, '2023-08-17', 'minervatechuy252000@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 18, '2023-08-17', 'minervatechuy252000@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 19, '2023-08-17', 'minervatechuy252000@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 20, '2023-08-17', 'minervatechuy252000@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 21, '2023-08-17', 'minervatechuy252000@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 22, '2023-08-22', 'minervatechuy252000@gmail.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 23, '2023-11-10', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 24, '2023-11-10', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 25, '2023-11-10', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 26, '2023-11-10', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 27, '2023-11-10', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 28, '2023-11-10', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 29, '2023-11-10', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 30, '2023-11-10', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 31, '2023-11-10', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 32, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 33, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 34, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 35, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 36, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 37, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 38, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 39, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 40, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 41, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 42, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 43, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 44, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 45, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 46, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 47, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 48, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 49, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 50, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 51, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 52, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 53, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 54, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 55, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 56, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 57, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 58, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 59, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 60, '2023-11-11', NULL),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 61, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 62, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 63, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 64, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 65, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 66, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 67, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 68, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 69, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 70, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 71, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 72, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 73, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 74, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 75, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 76, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 77, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 78, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 79, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 80, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 81, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 82, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 83, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 84, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 85, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 86, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 87, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 88, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 89, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 90, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 91, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 92, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 93, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 94, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 95, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 96, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 97, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 98, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 99, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 100, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 101, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 102, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 103, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 104, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 105, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 106, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 107, '2023-11-11', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 108, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 109, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 110, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 111, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 112, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 113, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 114, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 115, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 116, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 117, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 118, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 119, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 120, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 121, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 122, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 123, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 124, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 125, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 126, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 127, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 128, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 129, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 130, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 131, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 132, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 133, '2023-11-12', 'adas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 134, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 135, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 136, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 137, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 138, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 139, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 140, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 141, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 142, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 143, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 144, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 145, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 146, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 147, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 148, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 149, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 150, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 151, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 152, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 153, '2023-11-12', 'm.gonzalez.uy1991@gmail.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 154, '2023-11-12', 'm.gonzalez.uy1991@gmail.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 155, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 156, '2023-11-12', 'm.gonzalez.uy1991@gmail.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 157, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 158, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 159, '2023-11-12', 'm.gonzalez.uy1991@gmail.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 160, '2023-11-12', 'm.gonzalez.uy1991@gmail.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 161, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 162, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 163, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 164, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 165, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 166, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 167, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 168, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 169, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 170, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 171, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 172, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 173, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 174, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 175, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 176, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 177, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 178, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 179, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 180, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 181, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 182, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 183, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 184, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 185, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 186, '2023-11-12', 'sdfsd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 187, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 188, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 189, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 190, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 191, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 192, '2023-11-12', 'asdsa'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 193, '2023-11-12', 'zcxz'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 194, '2023-11-12', 'adas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 195, '2023-11-12', 'asdsa'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 196, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 197, '2023-11-12', 'asdsa'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 198, '2023-11-12', 'asd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 199, '2023-11-12', 'dzf'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 200, '2023-11-12', 'zxczx'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 201, '2023-11-12', 'asd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 202, '2023-11-12', 'ASA'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 203, '2023-11-12', 'ASDA'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 204, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 205, '2023-11-12', 'asdsa'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 206, '2023-11-12', 'asd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 207, '2023-11-12', 'zxczx'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 208, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 209, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 210, '2023-11-12', 'asdsa'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 211, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 212, '2023-11-12', 'asdsa'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 213, '2023-11-12', 'adsas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 214, '2023-11-12', 'asdsa'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 215, '2023-11-12', 'asdsa'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 216, '2023-11-12', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 217, '2023-11-12', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 218, '2023-11-13', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 219, '2023-11-13', 'asdasd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 220, '2023-11-13', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 221, '2023-11-13', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 222, '2023-11-13', 'asdasd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 223, '2023-11-13', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 224, '2023-11-13', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 225, '2023-11-13', 'asdasd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 226, '2023-11-13', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 227, '2023-11-13', 'asdasd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 228, '2023-11-13', 'dzf'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 229, '2023-11-13', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 230, '2023-11-13', 'm.gonzalez.uy1991@gmail.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 231, '2023-11-13', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 232, '2023-11-13', 'asd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 233, '2023-11-13', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 234, '2023-11-13', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 235, '2023-11-13', 'asdasd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 236, '2023-11-13', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 237, '2023-11-13', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 238, '2023-11-13', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 239, '2023-11-13', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 240, '2023-11-13', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 241, '2023-11-13', 'asdasd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 242, '2023-11-13', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 243, '2023-11-13', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 244, '2023-11-13', 'asdsa'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 245, '2023-11-13', 'asdsa'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 246, '2023-11-13', 'asdsa'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 247, '2023-11-13', 'sdfsd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 248, '2023-11-13', 'sdfsd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 249, '2023-11-13', 'sdfsd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 250, '2023-11-13', 'sdfsd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 251, '2023-11-13', 'sdfsd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 252, '2023-11-13', 'adas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 253, '2023-11-13', 'asd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 254, '2023-11-13', 'asd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 255, '2023-11-13', 'asdsa'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 256, '2023-11-13', 'asdsa'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 257, '2023-11-13', 'sdfsd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 258, '2023-11-13', 'asa'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 259, '2023-11-13', 'asd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 260, '2023-11-13', 'asdsa'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 261, '2023-11-13', 'asd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 262, '2023-11-13', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 263, '2023-11-13', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 264, '2023-11-13', 'asd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 265, '2023-11-13', 'asd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 266, '2023-11-13', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 267, '2023-11-13', 'asda'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 268, '2023-11-13', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 269, '2023-11-13', 'sdfsd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 270, '2023-11-13', 'asd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 271, '2023-11-13', 'asd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 272, '2023-11-13', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 273, '2023-11-13', 'adsa'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 274, '2023-11-13', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 275, '2023-11-13', 'asda'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 276, '2023-11-13', 'asda'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 277, '2023-11-13', 'asda'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 278, '2023-11-13', 'asda'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 279, '2023-11-13', 'asda'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 280, '2023-11-13', 'asda'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 281, '2023-11-13', 'asda'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 282, '2023-11-13', 'asda'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 283, '2023-11-13', 'asda'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 284, '2023-11-13', 'asda'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 285, '2023-11-13', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 286, '2023-11-13', 'asd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 287, '2023-11-13', 'asda'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 288, '2023-11-13', 'asda'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 289, '2023-11-13', 'asda'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 290, '2023-11-13', 'asda'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 291, '2023-11-13', 'asda'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 292, '2023-11-13', 'asd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 293, '2023-11-13', 'asd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 294, '2023-11-13', 'asd'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 295, '2023-11-13', 'asdsa'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 296, '2023-11-13', 'asdsa'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 297, '2023-11-13', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 298, '2023-11-13', 'asda'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 299, '2023-11-13', 'asdas'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 300, '2023-11-13', 'gabriela.perezcaviglia@gmail.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 301, '2023-11-13', 'max@gmial.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 302, '2023-11-13', 'gabriela.perez@estudiantes.utec.edu.uy'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 303, '2023-11-13', 'test@test1.test'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 304, '2023-11-14', 'asdsa'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 410, '2023-11-17', 'carlostafura@gmail.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 411, '2023-11-17', 'carlostafura@gmail.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 412, '2023-11-17', 'carlostafura@gmail.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 413, '2023-11-17', 'ctafura@gmail.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 414, '2023-11-17', 'ctafura@gmail.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 415, '2023-11-17', 'ctafura@gmail.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 416, '2023-11-17', 'dsfsdf'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 417, '2023-11-17', 'dsfsdf'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 418, '2023-11-17', 'dsfsdf'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 419, '2023-11-17', 'dsfsdf'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 420, '2023-11-17', 's@g.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 421, '2023-11-17', 's@g.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 422, '2023-11-17', 's@g.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 423, '2023-11-17', 's@g.com'),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 424, '2023-11-17', 's@g.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 305, '2023-11-14', 'aksjdalksjdklaj'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 306, '2023-11-14', 'aksjdalksjdklaj'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 307, '2023-11-14', 'aksjdalksjdklaj'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 308, '2023-11-14', 'aksjdalksjdklaj'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 309, '2023-11-14', 'aksjdalksjdklaj'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 310, '2023-11-14', 'aksjdalksjdklaj'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 311, '2023-11-14', 'aksjdalksjdklaj'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 312, '2023-11-14', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 313, '2023-11-14', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 314, '2023-11-14', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 315, '2023-11-14', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 316, '2023-11-14', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 317, '2023-11-14', 'ads'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 318, '2023-11-14', 'ads'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 319, '2023-11-14', 'ads'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 320, '2023-11-14', 'ads'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 321, '2023-11-14', 'ads'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 322, '2023-11-14', 'ads'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 323, '2023-11-14', 'ads'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 324, '2023-11-14', 'ads'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 325, '2023-11-14', 'ads'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 326, '2023-11-14', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 327, '2023-11-14', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 328, '2023-11-14', 'sdfds'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 329, '2023-11-14', 'sdfds'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 330, '2023-11-14', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 331, '2023-11-14', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 332, '2023-11-14', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 333, '2023-11-14', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 334, '2023-11-14', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 335, '2023-11-14', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 336, '2023-11-14', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 337, '2023-11-14', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 338, '2023-11-14', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 339, '2023-11-14', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 340, '2023-11-14', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 341, '2023-11-14', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 342, '2023-11-14', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 343, '2023-11-14', 'sdf'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 344, '2023-11-14', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 345, '2023-11-14', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 346, '2023-11-14', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 347, '2023-11-14', 'asdsa'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 348, '2023-11-14', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 349, '2023-11-14', 'asdsa'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 350, '2023-11-14', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 351, '2023-11-14', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 352, '2023-11-14', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 353, '2023-11-14', 's'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 354, '2023-11-14', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 355, '2023-11-15', 'carlostafura@gmail.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 356, '2023-11-15', 'carlostafura@gmail.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 357, '2023-11-15', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 358, '2023-11-15', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 359, '2023-11-15', 's'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 360, '2023-11-15', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 361, '2023-11-15', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 362, '2023-11-15', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 363, '2023-11-15', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 364, '2023-11-15', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 365, '2023-11-15', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 366, '2023-11-15', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 367, '2023-11-15', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 368, '2023-11-15', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 369, '2023-11-15', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 370, '2023-11-15', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 371, '2023-11-15', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 372, '2023-11-15', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 373, '2023-11-15', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 374, '2023-11-15', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 375, '2023-11-16', 'asdasda'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 376, '2023-11-16', 'a@a.a'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 377, '2023-11-16', 'mail@leroydeniz.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 378, '2023-11-16', 'asdsa'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 379, '2023-11-16', 'mail@leroydeniz.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 380, '2023-11-16', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 381, '2023-11-16', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 382, '2023-11-16', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 383, '2023-11-16', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 384, '2023-11-16', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 385, '2023-11-16', 'asdsa'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 386, '2023-11-16', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 387, '2023-11-16', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 388, '2023-11-16', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 389, '2023-11-16', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 390, '2023-11-16', 'asdasd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 391, '2023-11-16', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 392, '2023-11-16', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 393, '2023-11-16', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 394, '2023-11-16', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 395, '2023-11-16', 'as'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 396, '2023-11-17', 'asdasd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 397, '2023-11-17', 'adsa'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 398, '2023-11-17', 'jjj'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 399, '2023-11-17', 'yy'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 400, '2023-11-17', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 401, '2023-11-17', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 402, '2023-11-17', 'asdasd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 403, '2023-11-17', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 404, '2023-11-17', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 405, '2023-11-17', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 406, '2023-11-17', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 407, '2023-11-17', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 408, '2023-11-17', 'carlostafura@gmail.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 409, '2023-11-17', 'carlostafura@gmail.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 425, '2023-11-17', 'carlostafura@gmail.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 426, '2023-11-17', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 427, '2023-11-17', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 428, '2023-11-17', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 429, '2023-11-17', 's'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 430, '2023-11-17', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 431, '2023-11-17', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 432, '2023-11-17', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 433, '2023-11-17', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 434, '2023-11-17', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 435, '2023-11-17', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 436, '2023-11-17', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 437, '2023-11-17', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 438, '2023-11-17', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 439, '2023-11-17', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 440, '2023-11-17', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 441, '2023-11-17', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 442, '2023-11-17', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 443, '2023-11-17', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 444, '2023-11-17', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 445, '2023-11-17', 'asdas'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 446, '2023-11-17', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 447, '2023-11-17', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 448, '2023-11-17', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 449, '2023-11-17', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 450, '2023-11-17', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 451, '2023-11-17', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 452, '2023-11-17', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 453, '2023-11-17', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 454, '2023-11-17', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 455, '2023-11-18', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 456, '2023-11-18', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 457, '2023-11-18', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 458, '2023-11-18', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 459, '2023-11-18', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 460, '2023-11-18', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 461, '2023-11-18', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 462, '2023-11-18', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 463, '2023-11-18', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 464, '2023-11-18', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 465, '2023-11-18', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 466, '2023-11-18', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 467, '2023-11-18', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 468, '2023-11-18', 'asd'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 469, '2023-11-18', 'max@gmial.com'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 470, '2023-11-18', 'asd');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `calculators`
--

CREATE TABLE `calculators` (
  `token` varchar(40) NOT NULL,
  `url` varchar(255) DEFAULT NULL,
  `ip` varchar(255) DEFAULT NULL,
  `formula` varchar(5100) DEFAULT NULL,
  `entity_ID` varchar(50) NOT NULL,
  `name` varchar(120) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `calculators`
--

INSERT INTO `calculators` (`token`, `url`, `ip`, `formula`, `entity_ID`, `name`, `activo`) VALUES
('9rq(HgmFZ#/uZqutFRGYAwxFSH9bkdHQ5VRb', 'https://empresa1.uy', NULL, '[14]+10', '123123', 'Calculadora de la empresa 2', 1),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 'https://cliente1.com.uy/calculadora/', NULL, '5+[12]+1+[13]', '78995828M', 'Calculadora de presupuesto web', 1),
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 'https://minervatech.uy/simulador/', NULL, NULL, '2895789856634', 'MiSimulador', 1),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 'https://barreirosoluciones.minervatech.uy/simulador/', NULL, '[66]+[79]++[80]+[81]+[68]', '289578985663', 'Simulador1', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

CREATE TABLE `clientes` (
  `email` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `telephone` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `clientes`
--

INSERT INTO `clientes` (`email`, `name`, `telephone`) VALUES
('a@a.a', 'asdad', '095738989'),
('adas', 'adas', 'asda'),
('ads', 'Maxi', 'asdas'),
('adsa', 'asda', 'asdas'),
('adsas', 'Maxi', 'asdsa'),
('aksjdalksjdklaj', 'Gabriela', '123123'),
('as', 'sa', 'sa'),
('ASA', 'AS', 'AS'),
('asd', 'Maxi', 'asda'),
('ASDA', 'ASDDS', 'ASD'),
('asdas', 'sadas', 'asdas'),
('asdasd', 'dssad', 'asdas'),
('asdasda', 'dssad', 'asd'),
('asdsa', 'sdad', 'asdas'),
('asf@harakirimail.com', 'paquito', '666777888'),
('carlostafura@gmail.com', 'carlos tafura', '096229511'),
('cliente_prueba@minervatech.uy', 'Pruebas ', '683 745 695'),
('ctafura@gmail.com', 'Carlos tafura', '094123456'),
('dsfsdf', 'dfsd', 'sdfdsfsd'),
('dzf', 'Maxi', 'fds'),
('gabi@minervatech.uy', 'Gabriela', '683 258 761'),
('gabriela.perez@estudiantes.utec.edu.uy', 'Gabriela', '12345678'),
('gabriela.perezcaviglia@gmail.com', 'Gabriela', '123123123'),
('jjj', 'Kk', '6777'),
('m.gonzalez.uy1991@gmail.com', 'Maxi', '9978978'),
('mail@leroydeniz.com', 'leroy', '669987109'),
('max@gmial.com', 'Maxi', '9978978'),
('maxi@minervatech.uy2', 'Maximiliano', '69632145'),
('minervatechuy252000@gmail.com', 'Carlos', '6832586'),
('pruebas@minervatech.uy', 'Fabián', '68325861'),
('s', 'Maxi', 'asd'),
('s@g.com', 'dfsd', 'sdfdsfsd'),
('sdf', 'sdfds', 'sdfds'),
('sdfds', 'dsfsd', 'sdf'),
('sdfsd', 'fds', 'dsfsd'),
('test@test.test', 'test', 'test123'),
('test@test1.test', 'test', 'test3214'),
('yy', 'Yy', 'Uui'),
('zcxz', 'zczx', 'zxcz'),
('zxczx', 'cxzc', 'zxczx');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entidades_calculadoras`
--

CREATE TABLE `entidades_calculadoras` (
  `id_entidad` varchar(510) NOT NULL,
  `token` varchar(510) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Volcado de datos para la tabla `entidades_calculadoras`
--

INSERT INTO `entidades_calculadoras` (`id_entidad`, `token`) VALUES
('78995828M', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('78995828M', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('78995828M', 'L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub'),
('12312132NNN', 'r8bUKmHHVxEKBHUxvG4kQ+PHj?S7QmaWaqhb'),
('123123', '9rq(HgmFZ#/uZqutFRGYAwxFSH9bkdHQ5VRb'),
('2890456789', '4Dpd9LJX-K9DA_A5ZRLY_JnTxdVUevXSqZb'),
('213859760019', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('2890456789', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('213859760019', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('213859760019', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('213859760019', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('213859760019', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('213859760019', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('213859760019', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('2890456789', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('2890456789', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('213859760019', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('213859760019', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('2890456789', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('78995828M', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('78995828M', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('78995828M', 'L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub'),
('12312132NNN', 'r8bUKmHHVxEKBHUxvG4kQ+PHj?S7QmaWaqhb'),
('123123', '9rq(HgmFZ#/uZqutFRGYAwxFSH9bkdHQ5VRb'),
('2890456789', '4Dpd9LJX-K9DA_A5ZRLY_JnTxdVUevXSqZb'),
('213859760019', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('2890456789', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('213859760019', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('213859760019', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('213859760019', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('213859760019', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('213859760019', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('213859760019', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('2890456789', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('2890456789', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('213859760019', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('213859760019', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('2890456789', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('289578985663', '_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb'),
('289578985663', '_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb'),
('289578985663', '_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb'),
('289578985663', '_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb'),
('2895789856634', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entities`
--

CREATE TABLE `entities` (
  `ID` varchar(50) NOT NULL,
  `nombre` varchar(255) DEFAULT NULL,
  `telefono` varchar(255) DEFAULT NULL,
  `direccion` varchar(500) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL,
  `descripcion` varchar(1024) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `entities`
--

INSERT INTO `entities` (`ID`, `nombre`, `telefono`, `direccion`, `type`, `activo`, `descripcion`) VALUES
('123123', 'nombre de la empresa', '123123 int 3', 'fdsf 6789', 'Empresa', 1, ''),
('289578985663', 'Gabita', '12312356', 'Intrucciones y fraile muerto', 'Empresa', 1, ''),
('2895789856634', 'MiEmpresa', '24093804', '18 de Julio 2044', 'Empresa', 1, ''),
('78998855J', 'Nombre de la segunda empresa', '7979897', 'hbfdsfd 6t', 'Particular', 1, '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `etapa`
--

CREATE TABLE `etapa` (
  `id` int(11) NOT NULL,
  `token` varchar(255) NOT NULL,
  `tipo` varchar(255) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `subtitulo` varchar(255) NOT NULL,
  `posicion` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Volcado de datos para la tabla `etapa`
--

INSERT INTO `etapa` (`id`, `token`, `tipo`, `titulo`, `subtitulo`, `posicion`) VALUES
(13, 'L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 'Discreta', '¿Cuanto consumes de electricidad?', 'Introduce tu gasto', 0),
(12, 'L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 'Cualificada', 'Prueba', 'Elige lorem ipsum', 1),
(14, '9rq(HgmFZ#/uZqutFRGYAwxFSH9bkdHQ5VRb', 'Cualificada', 'Tejados', 'subtítulo aquí', 1),
(15, '9rq(HgmFZ#/uZqutFRGYAwxFSH9bkdHQ5VRb', 'Discreta', 'etapa de intervalos', 'subtítulo de los intervalos', 0),
(67, '_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 'Cualificada', 'Cuéntanos la inclinación de tu techo', 'Inclinación', 0),
(68, '_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 'Cualificada', 'Cuéntanos las características de tu techo', 'Elige el material de tu techo', 1),
(66, '_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 'Geografica', 'Selecciona el área del techo', 'Con el cursor dibuja el area', 6),
(77, '_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 'Cualificada', 'Elija su tipo de Tarifa', 'Elija su tipo de Tarifa', 2),
(79, '_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 'Discreta', 'Ingrese su potencia contratada en w', 'Recuerde si es Kw tiene que multiplicarla x 1000. Ej 3.7 Kw son 3700 w', 3),
(80, '_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 'Discreta', 'Ingrese su promedio de gasto en Kw', '', 4),
(81, '_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 'Discreta', 'Ingrese su promedio de gasto mensual UTE', 'Ingrese su promedio de gasto mensual UTE', 5);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `etapa_data`
--

CREATE TABLE `etapa_data` (
  `id` int(11) NOT NULL,
  `etapa_id` int(11) NOT NULL,
  `meta_key` varchar(2550) NOT NULL,
  `meta_value` varchar(2550) NOT NULL,
  `imagen` longblob DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Volcado de datos para la tabla `etapa_data`
--

INSERT INTO `etapa_data` (`id`, `etapa_id`, `meta_key`, `meta_value`, `imagen`) VALUES
(30, 13, 'minimo', '10', NULL),
(29, 13, 'maximo', '120', NULL),
(31, 13, 'valor_inicial', '100', NULL),
(32, 13, 'rangos', '1', NULL),
(33, 15, 'maximo', '2000', NULL),
(34, 15, 'minimo', '100', NULL),
(35, 15, 'valor_inicial', '150', NULL),
(36, 15, 'rangos', '10', NULL),
(175, 79, 'valor_inicial', '100', NULL),
(174, 79, 'minimo', '100', NULL),
(173, 79, 'maximo', '10000', NULL),
(151, 66, 'latitud', '-34.9045171', NULL),
(150, 66, 'zoom', '18', NULL),
(149, 66, 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay', NULL),
(177, 80, 'maximo', '10000', NULL),
(178, 80, 'minimo', '10', NULL),
(176, 79, 'rangos', '100', NULL),
(152, 66, 'longitud', '-56.1951619', NULL),
(182, 81, 'minimo', '100', NULL),
(181, 81, 'maximo', '100000', NULL),
(180, 80, 'rangos', '10', NULL),
(179, 80, 'valor_inicial', '10', NULL),
(183, 81, 'valor_inicial', '100', NULL),
(184, 81, 'rangos', '50', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `etapa_opcion`
--

CREATE TABLE `etapa_opcion` (
  `id` int(11) NOT NULL,
  `etapa_id` int(11) NOT NULL,
  `meta_key` varchar(2550) NOT NULL,
  `meta_value` varchar(2550) NOT NULL,
  `imagen` longblob DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Volcado de datos para la tabla `etapa_opcion`
--

INSERT INTO `etapa_opcion` (`id`, `etapa_id`, `meta_key`, `meta_value`, `imagen`) VALUES
(262, 67, 'nombre', 'Alta', NULL),
(263, 67, 'valor', '3', NULL),
(264, 67, 'imagen', 'imagen', 0x646174613a696d6167653b6261736536342c6956424f5277304b47676f414141414e5355684555674141416c674141414a5943414d414141434a75476a7541414141475852465748525462325a30643246795a5142425a4739695a53424a6257466e5a564a6c5957523563636c6c5041414141795a70564668305745314d4f6d4e76625335685a4739695a53353462584141414141414144772f654842685932746c644342695a576470626a30693737752f496942705a443069567a564e4d4531775132566f61556836636d5654656b355559337072597a6c6b496a382b494478344f6e68746347316c6447456765473173626e4d366544306959575276596d5536626e4d366257563059533869494867366547317764477339496b466b62324a6c4946684e5543424462334a6c494459754d43316a4d444132494463354c6d5268596d466a596d4973494449774d6a45764d4451764d5451744d4441364d7a6b364e44516749434167494341674943492b494478795a475936556b5247494868746247357a4f6e4a6b5a6a30696148523063446f764c336433647935334d793576636d63764d546b354f5338774d6938794d6931795a47597463336c75644746344c57357a4979492b494478795a4759365247567a59334a706348527062323467636d526d4f6d46696233563050534969494868746247357a4f6e6874634430696148523063446f764c32357a4c6d466b62324a6c4c6d4e7662533934595841764d5334774c79496765473173626e4d366547317754553039496d6830644841364c793975637935685a4739695a53356a62323076654746774c7a45754d43397462533869494868746247357a4f6e4e30556d566d50534a6f644852774f693876626e4d7559575276596d5575593239744c336868634338784c6a41766331523563475576556d567a62335679593256535a57596a496942346258413651334a6c59585276636c527662327739496b466b62324a6c4946426f6233527663326876634341794d6934304943684e59574e70626e527663326770496942346258424e5454704a626e4e305957356a5a556c4550534a346258417561576c6b4f6a51304e555a454f554930517a46434d44457852554a424e454d304f5445314d5551344d7a4243516a6779496942346258424e5454704562324e316257567564456c4550534a34625841755a476c6b4f6a51304e555a454f554931517a46434d44457852554a424e454d304f5445314d5551344d7a4243516a6779496a3467504868746345314e4f6b526c636d6c325a575247636d397449484e30556d566d4f6d6c7563335268626d4e6c53555139496e6874634335706157513652554e4351545130526b5a444d5546474d544646516b4530517a51354d5455785244677a4d454a434f44496949484e30556d566d4f6d5276593356745a57353053555139496e68746343356b6157513652554e43515451314d4442444d5546474d544646516b4530517a51354d5455785244677a4d454a434f4449694c7a3467504339795a4759365247567a59334a70634852706232342b49447776636d526d4f6c4a45526a3467504339344f6e68746347316c6447452b4944772f654842685932746c6443426c626d5139496e4969507a37664b785966414141444146424d56455857536a475a7552435477517a55576b4c7372477a7374487669342b7230765979716d4b62373639756b716233657858337163574c3530363358556a62746c496a3736656271362f4364724d5438384f4b776a70584b49784f747373547368336e613365546d6e6c54357a4a2f33344d6a3332627a513039377472334c4b647a4c357a61486d6e564b586e62546f626c377a74613375736e6271684771646f726a62534369687072766c6d6b334947777a3179714f52755158514f795070706d4c79755950353264583277705857555453687342626e6f6c763176342f626154374b5a31665956546a3938756e6f7056336969553732304d7278387657626f4c662b2b50483939764b317563713766587565704c6d707273476e76696e4c7a746e2b2f507233795a727475594c416433447165327a6564306231797358352b6675677062712f303272337970374f4d682f6a5a6c505a57447a3139666a46794e586b624672717157665030747a35354d2f4177394832785a725a547a4b677037336969464c6863567a6f6f317a6b6b564c6d6547667a7649765772564734764d793079302f6c64474c32774a4c6f7046727a74496e7a392b546d6e316232784a5036303654776f5a66677a5958382f2f2f2b2b766a38376575777463627672596e6f6246334d4c42726f6f466e3177627270715637787434446d6d6c62693637723076497257564472337a61696c6e3744493258372b2f667a76746e766a615662307749767a756f666a66576e3735654c5431742f3479357232787058372f5033382f50337036752f35344e7a64356133716457586c37634c716633486d352b336e6f6c6a655a314456556933655955762f2f76766f62324475372f5031774a4c363664667a30613757547a6a77775a50362b76764f5830766d6e4662575754444c4a7862666356483479353238774d2f3277355057324f4871643269697037767a73355031754a437974386676763437392f6637743839586358555458555458322b656e65332b6567714c2f57546a504a4878436a75527a54345a6a332b506e3177342f6e6f566e66674566477964616a6f3762617547547839742f6e6f6c7a7a75346a7a74347633794a6a34784a722f2f2f2f595944586e6f3176565544546e6f4669627568586e6f466e31774a486e6f56722b2f7637317635442f2f76372b2f762f6e6f566a585644663479707a2b2f66373479357a6f6256332f2f2f376d623133392f2f2f307570483479703732763548777735582f2f762b6576427231764a726e6e6c666c30355733673458357a714431764a58777870766c654772372b2f7a526c6b50317535576970626e6d6f46667837394c30765a4c3076705032784b443678714c367a715478724b502b2f2f2f68615672746f6e722f2f2f397664696d454141414241485253546c502f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f3841552f63484a5141414e41394a52454655654e72736e51396355326561372b6b5674624978534a3249695a59626a4253424c71426374426f6878554c464e69687a49517071375968324c57556d316c313059454258327548506175752f7953413144565847566761584d4773644d6852324e4861333437684879566955676d50737a4f3530506e4f5862643037334c33334b74335a38796545633034434a4f454563384c764a324f484e79386f385058335075397a6e766435512f344551583551434c3446454d434341425945734341495945454143774a59454153774949414641537749416c675177494941466751424c4168675151414c67674157424c4167674156424141734357424441676943414251457343474242454d434341425945734341495945454143774a59454153774949414641537749416c675177494941466751424c4168675151414c67674157424c4167674156424141734357424441676943414251457343474242454d434341425945734341495945454143774a59454153774949414641537749416c675177494941466751424c4168675151414c67674157424c4167674156424141734357424441676943414251457343474242454d434341425945734341495945454143774a59454153774949414641537749416c675177494941466751424c4168675151414c416c6751424c4167674155424c4167435742444167674157424145734347424241417543414259457343434146535136735435744e4330747851386459506d6f3748446a7144703047443930674f576a71694e50535650632f534a313641522b3641444c522f315670485130415379414e524848716871564c49414673507a685741414c5945334173634a50415379414a62794f546a58487970367a4632424e546f795649705661584253735947565552495948576e347569474f73546864316b3776436e6345483175474839585a566655554777504b3365734f6e745a5053366268763765546f744b65434c5546616e5261756f71546463774a672b56744c4b796f714676386e58393965764c36694969306a754c37555659767256513646727764596b3745654c6e79647077577a677643663042364479716e36785873426c743956756e4241776462413277766e426c3355766a37634e4d4b56796d37596336496159506b62724e6c76743341314f396a416d725059624c6572324a4a457273384157503556396d776556346f674136743661626842785a64642b33417677504b7a59796e346a725571714c697171446570334567536e6761773446672b362f41654c59736d3077686a646c506b34677941426366794e5771586a4b416b6b5253624a537a3730675a4144412f48457150324c6d62626c555269624b6f7953695373534376386b656668345667692f4d715737696e6a634e57656c35435132473569682f4c6178584d4146687a4c753257776f74374f5867592f62354a31795a71376d6e566d67346b6477352f49426c68774c492f564f3465646131644a44506d4a58544a47495762326369694a664b544c4952784c5a486156786f72615653614a515a725852594a462f302b576d4339686d5a5a4a752b637777494a6a65526931313676734c4b342b4435456c644456337963706c4e4631355652497a4f3663566e74594c734f4259343273703236374b794e3167596863565869557379566d5252793249586330684569307230444939757366536343775266555872772b314f6175786c32732b6c65516d795a6c6d43374e5471796f61635247593544506e617a496e42486c57564668784c4e447138574f74634265313269626b67704a6c434b5348762b6f374b6b704c4b4b366449784d6a6c4d4e466f4d7074597932586b2b6c4b41426363612f64384a65786d306b394656666d4943795657434c50464b5357574a3156705375654e364f573161355530714d7a7641667a51704c546957534861444666587352344d535652564e6b617a353349354b646172565370456c7a306d6b7367376b377243596e64465347523746535173346c6a695751553779717378636b4e684d5a362f7956736a564a565a4744535639713566496d4f47764f5753707442576c4141754f35535a716a32512f434a51596a486d4d4e5956632b61416b316572556a527337726a636e304752566d54683568386c5061634778416c397a486e4b5751584e745578354654304c353952306c4a566132626c5165574d4873447374443875736c6e43717439646b41433437462f6a7253396e41494d5273545a557965666355486c51315772686f71533636636f6a654c58596e35374649616b366c2b636d4e344f466141613238464b39644f3751626279796d3749693170746272534e677855483975307a6a484a306e4b6a715a694e70476e50306d714142636569565833344962756758534c4a62354a314e564d50623637486c347a596c633171637a4b6d7279786830764179575657426755325766544a5057734378416a724a6b425a655a756374677a4a366e6374704b484a4737545a355557686f6b64364a6c727268696d4e336d5069316c70743465446748594d47787145664f624b784d5a683170566952577a61645771395673726d71755861744a3067387937393973554b74336e47746d596e696a6c6d4e6170764330556f41317852324c6437784c5971674e6f522f614a4f53744f46437064713644672f72437132382f65484433594f47495a3556554471354970454f7835696f4a68797856354f4a56414774436574665673555146566d6c464a4773564b7a4f5964596d7942437138576e4b6c70444a314a4b547169377173554c626356536f75527730365236325635484c595255566a7368436a6c704d734e557a4f592b6b67766b42673967435072495669416d764f5131614730323433467a65565536416b4e4a396258616c32416d534c56746363476143732b6135436561536d5347357a724a413264636e71633654426b537469597275576b79785668552f4759326d52674a5639654b6e5865706f486c754c31744b56695552716e4b59506451433644564f5656516b4c696967507147303566307375546b75386f683739413562726b51726d385a7a696c705435775059393654743356334c37544c4747567964736e4936556c4572443237716d50394537316b662b6246324d4e2f46753474352f6b6b616e655947666e326958746444343951555975677950526c5533664531716e554935386855706c586569674d394b366f565937697253366d676f4d374539494c6f644c7377455770524e6d6c5865796c786e2b726f564c317344665056566d56346c504a6b6c7869457a6d4b4756517337697971574f754b5468666f304a354c55627454476b31714374586e32496556696361446577547258615433303961694153734e494f335077353359455557694245735361336a484535657a6b67704137554f4a6957334b4869757246446576566f3445734f586c4278595563366b345a75306e4d32685372746e44734436553061465a4b6f366c73536779324e4f53707936496d636e322f5768645866344352554b725a624c55587239384b7a55427630564f7538676177375a61545a4e59764f51454a474557424a42484b74576446787043304a6f792b47564d746a6b71544737373772686969524c7362736d6c5a57474c317039797047477a7a647a4169325458314e6134674472634c684b434c43654b684f6458526b645a795153637759725762744263686c637033544c466255636b7274443237427032556f71643679677a78374b714d4e68484e4d792b7a4747467764595338313278384d796a3258512f705950316d386a446561414672667330323479312b72796d464b475536737231534d5644487072614e3241736d56556b627644714b4a68736d34327145747936494c544c6c6d5479637931667638396c68594857476d4f64493532703863713176365746396b4f2f45646b38633541316c64614139657571484d3464436b4456586c3130376b4d4471716a646f396d56384e664b376b37484f776271644a61545a2f6f6b58556c466b69345a456b5748353743594a55754e6a486e5451377075693265535271692b7a5933426c454d665076486e536c535330424b61756e75586d6d307339756e536379315446305664513648566442484c6f5037337834624b2b7172765a4f633546774f53624a32584765655375635a545159545a77766a70354d576f6742724c314f554a436e6533702f6971556977576c7a4143756c4f435578316433627238753263516c464a6c534e7150375744586371674879797355796a4742307652556864716c6475636559666f6e4478487a544a764f5454353530344c555942314972794d53656a6f2b71556571743874574a30576155444b6b744a764c44424a57446c523764654a7a665435303779636550617a515432354778777276474948576b6469696f624a756e6c4458624936684361724f624741302f3650506d6c5250535842366b316a2b74655a61314e535050355a64664c41756b7337566d43435a5348745373582b5955764d526b63546d5a41724461785342687535444635376f4c7a6a43566774696766726b70506b66534e702b42335879786c576a64784b4770553966483331564153726572336a346f5669716564676865682b4f664436414675762f7a4a414861746232703676596f6458326f4b7163726f72512f6d35485a556c7a716739566138505058685832584b3378554d70465857687a6b4472356f334b44315a5170366562452f4b7143725463584c48777a554e4541645a69527a43777338726942566a66336633534d705a657576626467485373464d744b63686b63616661684d6d694e495652684f31334b774436484539305464566d7061504643437358756d4b4c6f6b5765484a5665576443585154576e79745a4979546a58396e7156544436794d5059354e34665a2b7a3339656e537350666573707272375633686d41646d58526365784b596a5977797942567974417738736a5a717065726134353478785556574c363950306d7564353656727478786a6737645a486e354f77307162683565324a5357474d4279354e306c426531654f55476e4a61583746457664416267516b6c463765793072757249624a475536356c78672b626b446c534f37775436397266447148572b356f744c77697272434875646a365a4a4b2f51726d30574e7a657a456e705755796d51553961534547734e49693658396142714d584952626c42533733594162675171677a6c706e596e644b302b59367544496b354461786e4f4661624e585333776d7573474c534f784978734b315070497a7a4d2b66774337755a514a52457970535543734b715a30675a3766554633696a536f6c4e4c6458737574764b72586c544d2f39564f723961786c3043722f526330316e37436941363172354f3577354554724948574568383437474c55534f7a656c746268304b6f48316b506d485662396461676b71727272376a62556d54704a686578504e56554c65697668556c6c3152423347754b583046693072443134584b57615a315941583943464a575873563764456a64616445375a63417133654e6f506c41515848596c31655862326430567a4f6232454b6279616b6e4f54645a757345395037675a626c4330546b464a784f595a316f7256536e724f45336838304e785877486e7958685173557734734172446e6844466966473775447961355763714a326c6352676d4f626f796e427564655649567759714b56707a375947695a554a53444b79724b5854572f393155713165664b366379576c314c326957474d753639644d49386c68594257476d525450786844434b734c4261645563567049694d7061364b536c31316469537649364972466c6255775754467770325769556e4353705131714f56576b5266357835653266532b7a3847443537536f425651542f516b576944794c42532b6e58356e4d32676d6571734c5774324b57576744754a6356696861684a42796435535656566c6177687a686b5855314655744d76426865674f56514247445273627664554638624c47436c6b464637775568536c4b71512b6171706d59376171584d344c4c4147395555783131714534596f3677724e667252394a6c7061736476525a4471474b7444686f6d5238656e674a6730556333795a33344f796e42777055756e3532384d686b6b32356c65616c324a4f5166554935576966595079704f5337536f47346f736871715176563634632f7631704e486547686d6f7a6b74527463556c6f54625234532b474374596b4b73346d4a6a634351625571547474535a3265475532544b50506431486e63456f7162397763386176424b4d353531496c72514c6b3778756f4d74456f7171655751616a4e53486c4a73344231676d75686a3659414871336f704135624b75444a493749715461376562366b33554f5a786d2b68774f617a66593079645072646d74554e3456457179377a484a6f63787a44743156574d6b6434714f5851724f4c4638424e374c4233775947557a4463346c686b4238676a7a685238346d6737614d69646f54456e4d2b71457831326c5750506a70702f78314237636f52777239394e56512f334f444256714b6d6972536f33574769305744676c744b5949696653447a666777537039534a38774d4e5148776161516a4e7262617a6d4e7462563270724e3251764f704b3270575a2b302b7553333034494369785139534b433548395554334f52733832484c6f4b79363671413765764e336852464a614151395742744e3278567a2f547266346f7975646b5a4e724a2b3071704a794f72764b7548366a6b48484d7569746d745648714569564b705a416f5a79662f6a55574b4358413572314d3536683461537969744c6d68334c4954634e503645374c514965724c3331394b6251634d676f396b326870622b646d3777796d51746f753549314a31367863556f5a624737614d72686c704f58756e585872316c326a745737646e547565665a5379355770684136763933343772544c496a6a2f506f6b6f354166443570456642674c64557950345233644b4c6e796c696d4d6e4761794c517a70517a4e7033625932466e52767348514f732b38523747754c6a6b6d71724177695652686146524e386d585073684e556777666e377442366f2b4641446e50534c4b2f64784576447138772b4e67384a644c424b4b2b69373143516d6e62685877705155586237647850474372784f4853786b4f4e4c41764174436e786e695162436558774e33376f30696b696c4c3762446139336d62724b564b54644d566376546167394f4230474e582b7a336e733849627443763155576c5a4f376737742f4f58517078672b304d484b634d54755770326f4e34583843686b7976484c6368394f314a45664f4c6d77663143636c6a312b4272465165755270546d4753545530543144532b6767337139764345704e4b61755a64793458304875446775482b7978623654374c39424565716e5549647a6d307133787141426a6f594f304e747a4f7865337533714f334b714f4a5558686d2b706936596f4a34426e2b4e305a6144614d6877634e796d715542354a6a6b7153522b763772433679366150316854477658504f417a6374527a6c4b616d38356265424c79326c555331355257616243426462696565556837534d5267705569355562764b594443473043324e75784a5857466c6447617839656e58553767666a597257754c695931576a384355773874566d6f314f716d476a4c6247505864494e59646e7466396a72683149614b374b3535334356366b694b2f594747566a44735875424c6b57306472577976597754585a484c49426c645561554d533636776a6733537932444e4e615548345647536e456d6539365432325054796149666b656c7671634e4e6b6665485664654f5a46686e6f7339762f575374336e43706e367531727a66775958754c745359734142797437765a6b356f4b4d5436345043626d375562696674367173714a726f7170306f5a32497559767442746b7a3758513668306d394765486c74306448793037595936695a5936645a423856392f583432684a457a4e2b714b5a515841346461644c5755506d426f354e577564484d4b3656523262314d615955456575784f4a366f4e7853764675524a6175716c487a707a4b4b374d7830584876573834674f3779797961315234795a464663713779556c79476f552b6654533548435a4e2f2f4c4d77675662546d2f5a736d4468307a2b4b55657670306547577975506d574a5655737651506738366e306e706d64356851726a4e4a654b5a6c392b3678644943444e5763343779354f734379576c635979626c4d47625a4f6a4f64477031577257733047534b366f43655677513174576f6f2f55394e446879656569584337664d585658364c6b46704b50765a56624f326e4c6d614643316e2b69627235556e6a7038506f3365487751517462583657614f634b5449417668377735564a6d3334696141427931486151494b5649737277716a316678586b32614459314e6450506e4d7458734a7649554f4656364d473348796a47726d57344f33434e4f684e42637056716978353834637a705651526658387a64386b5a55664c53565a6938363665723436644942396c3070394f34776a326b643071376c4231716d534d2b62687751345745796647565078397055696a4c453675636b7275306c72706e65447a516e6b4d76694853697372624a64544e2b4b4d4238456430712f6f7a6a4f7031766a346d6a4f6e377848754e48523279394f683864453057664c4b672b4e2b3172734b3565345974664f756c4c354b6555356956774a5678714d7a63452f68303965303767304f7343726f324e315532793547753649654f584e62502b726f5a54434258415972533167357145487152707a78487a6b72572f62546e5556543566464a5835372b676758544c66724e695662706767392f4555385a6d303165364d6e44496561756c4a487244706d615a547276494f4831417a5a34656b317259495046314d7a59446257694f36707153654648375a49796f364e514e4f2f364154576e2b614f744d506e752b467770427067447a58335238756b4c533465523274683473714e6a49304645644d77346e6e374a4d66707578706c514f6f596e79664b6b5151336e727053476b736f44312b6d615a566d6955634b764c465635654b644659494d31682b347a59394c75374c61494c32713363376853315459782f57576245362b55734c4d4d66625a552b6d4b3438523863317858536264546b71522f4f716d59413270446573576c65324b4a354a776e6972617a5973463172543234385372397772335142457a6a5a354b48586c4236563073515539546c76346146716c716b724e32586b636d6a6939776a3372486c4969426869642b3268464c474278536b55706149544a736c41636e574f6652454139614d767176486f494937695769693932395033505a3368434e51625035345831706162535950315a4a596d4d36347437454c7252756246367450547254626d6b665964547a3637346d35796f5931315638727774514d684c705a6c4e30536d565973637250584d6b634b6478534c62452f613331334b346b716830544f5656516c344f707973446c57564958756642442f37755145744e4551324b2f4f6d4d3339446f704b2b64463561626d527358703245634b7a4d754e7a637a4c75744336316b4857545630436249387163367a79744b57792b52797943716c5952704c4e696657756a7a6749575034444847447866535a4d52574936784330526372725457544964397862496c7479785462533834704b6367354731586c5532613551586b375330317839796551594c6e61634434764e6a4b506b42497455626d787331746149577737506f6c4a65677a6150466b506d7270516272445338334847694e62484b594f42663654482b6e525942445a616a7a34776b583179476c534a6c6432773353557a746a6d4f4465646433564b6f35647556706b373637796d74307a4b5250665748564545584e7053657a596d506a346c7a416f743756374f71345434667743304c6a4b525a376b742f32714870656f5879626456664b7a55723146667053756f546d4a7058727258376a78664168596f6a6443305257693258704e7a7058516f6d6b646a6a586e706a5478383631577763487162594d4868367571627568703835595444394e2b39576c745a6d6175446a33594c566c61724c6d3038766872545071364236727a55627544443338557762716f6c4b64742f4251665a617076337043516b67743730494c3870394c2b46377867725755766d37625646387374694b2f46444a32482b59716e2b354e524457555856334a61765a426453656962735478374e776775576b62484c5432524265656f626d36767a597a746d3030734d6a314d444e735075315a70622b4c3736482b704753506a2b6c547a6545354452376f7870494a69666b6d3376597763707838566b6a67782b366d2b753269653143596f714f506564484c494a4f384b7238657a3237525279364452544648504737333861424f54526c4a2f4964302f75726f573232786358476a677855586c7a6d766734717a65726645524e76494d4374307438636e464256336b74556a4d58784443564f6b4a5375665a75626370476d754b4256786a4f5734517164596643652f4c4e3155445a5a45556b446450552b584d6c7a35674e57566754515266564c7958592b35557479703065744a77777064304575746342316873626c6a6735577232525642422f427655486e5376745372447a773955553033654f687a3976396a6170597074454b2b596c316f49586b34337259776b4d487133634e3845574a736a4e56744d5a4a6347524e6c6a6c4b474857725742525057506e4b7256716363384e68466c4a6444716655702f73746e4b56714f5839437775584948566c796d5a684f314750356d316e53714758653052376b73316c307071633637556b6f7144394333384a4168596b48784d466d6d3848467a7049454d31743577326e7931526a47656f30685a615651786c2b3753353341346c614a57356a7a7158632f425375367855644830516a72413273546c79693159625a7173566d707939706c6f4d6e365868313732346c51316456654b657669756c4a734e354f3577435631496e54684e346a6a43457a6c2b2f557849514d6675644b4933736c6163423352574e6a4833664d7557354f67725756543155456e5261307146352b302b46486472534166706933356c4c7255517a7069337147316373456a50576b4d2f4f647853474e316e4855784b39716f4e684c4c6c3445697974453964755a712b646b4257486d4b7170354b6c3276576966715254766236652b65636830735a594b59365436346c584b6a6e50634f5436304950654e564e5437493653323370733857657953564c4f6275555a316d68675a62562b526b36662b79455a6e66554e786a786f386570505646356d335a584346476c5270685653706a57595449737a5241315771614d4e39303752646c796a48672b574a2f5a6673616b357538476f79774e65336f6854567a6a59313264725745425a55415466734559424b7a6433446658597350654d6e6c774c6f364f386249656b554b37626e7951665a4e33437731784f6e666831675747504a7a565a4151785778683536515266763466722b2f73546d764242702f386f72493438486262616b2f6436326243644472434b6256572b62506f744f59595846656752575847625953586f7437496d32556b4757397932383677705468772f44557266776e4b4c376c355133525870556f427753794c453755316f6d33684f462f5345684a4663576932373163506d567a565a5935335650555957796872514f2b654476714b65456c793745386c62435563474b3230784757554f6e51306d7739495631506c7a44737a7471704871617670534f50687457305374797349627a376d4a756a475768793330365678793434536a706939727466644d727053496d32746f6a743732524d5551516a566d614e732f4179733039333067465764504a77462b666c4f784c372b56722b306675536d6c51663768346d6b7957463534753867725355695a324e30574b762b4f61525a706a5453587436672f712f5564383646577276424e4667685774703870473733654565516f57476235486b493631366b4f396a647757317667436c6d4c64516564644b54646a5a7431662b6c5865646738507267597557426d4c4a557a396672763475795633727279696274446251672b2b375575585073573155446b4a6c6d3368752b524b75446b734e73354473474c6a5a70434f7465704c6d3536714a765370577a7a727270544368655153654f4a686d756750552b786c7274443576465958424e3253753355372b7451787533317272613034516f5a4a716445337955336876593262776a49394253737a743450386947652f744a4a677063623465696b646331644b6a2f707037356f5a425442596449676c4d656d6b5153434c644d57426d6a7350576e7953596a634e6c6f334b4e6d7738332b5946574b32394250487330784d42693372435179644c50317a31707941423633416b58562b743151584676514864756d2b393950716469594f5676737362734e36365342415a4577534c376f5a726a567251477952674f664c75356b6864554e7762304c6e794b5748415768506e44566a484241434c576736547a377a37707941424b324f78675334587277384f734a724f5062564d724743314b42374d6e76576e594146723152366d392b6a326f496978794b587771522b4a467179576c6f567a677761734f5a474f786c6842775a553070657062346e57736c72646e427739594a2b69795a494e707053565948457645594c554544316a566166534a493231396b49416c366867726d4d4279784f37612b7544494e6f673978676f657350597952776f4e3231636978674a5967715a4836627837516244634d4934594b314269642b5a43696f4c2b494c6d76467a46576743694e72683756466c656c5342466a415377425933666d445052584b314d515977457341644f6a544d324d74726a666768674c59416b59596a463539382f66365a636978674a59416f5a595443752f2f47434a3352466a42596a5730776430744158647751495759717a414f456842782b36712b6d4a7045446b5777417159657666363756494c596979414a574473487134796d557953346e6373306e354b314145396361747a35564f584164616a6a39306a4457617a576674352b7a54484c35335974664936484f7652713364787535475372736d687a68445271776d37776b65762b2b48557a62624e7a633079366a663676324a58562f6b684f4e616a722f494c373549466d62724b6e2f6f647748725532684175437a367734466742344669527a63336c3744645a6775676c4f2f517077487230696666493848444f32314d2f46727532662f656c6752614146576a464467734833686135426d623779685841386d5043645062664c7238746169322f5046734a73414a4f7a7970766931334c5a6973415673427031527569422b73394f426241676d4d424c44675777494a6a41537941426363435748417367415848416c674143343446734f4259414d762f5948333632755472505468573849503153764c6b362b70794f46617767375638662b486b4b2b7156392b4259775133577037646a2b714c312b73464a6c4636754c2f7962312b4259515137573870686636465031306647544a6e6d507a565a343954553456744137567172656d71704f53764c684c636d586a37706874566e484277754f4651794f4652317a35765157373358616c772f6138714e6f6652386361796f3431692f3038532f4d4a535a4e5a386a46454934314e5277722f6f565a6b385a564c776d574659343156527872466e45786f6e587a6b353572382b62576a51517859374e58482f4e6b3679586958546a5731484b736f322b464c644a346f55565a78776c69713163666f74466b4e644a677762476d6b474d646653744c6b2b6d356368664e697943474e6d6c694d373152566a6f6361386f355671767274336f73615569776945325a75643538544e793864446a576c484f73317178593738474b3951617333474777344668547937456d445377344668774c6a675777344667414334344678344a6a776245414668774c594d4778344668774c44675777494a6a415377344668774c6a675848416c68774c49414678344a6a776248675741414c6a675777344668774c44675748417467776245414668774c6a675848676d4d424c44675777494a6a776248675748417367415848416c68774c4467574841754f426244675741414c6a675848676d4f4a7737457958526f744c574c41636d6e61704d6c38456d44427354774361326a6a316e6b7579746f5651587778663433722b4c7a3546774557484d736a787a6f6163644a564552734959754e784e7939737641577734466765675558632b72574c4c743669786d396464426e2f4e66554377416f4d78386f4d624d6536314c725756572b6c453854784a39323863504c584145747778376f2f696331744a334e584f4572772f69534339306c7972474d64752f5a6438454c7a7a6a6353784f5a39586e334d68664d6268795a35563369423543575749776459595a70593372676d466d4435776247474e715133657158306f325149334f6a6c7831796b4c784359544d64717932336a4c7368746f2b537832704448386f4e6a546536564a38693854784848696f355a75475853394c746f5057372f6d694b4f5a55754b6d6a35704b72514e347661764b654a5950595079364d6d53584e2b442b77716e686d5031794732442b736e546f45302f434d6561416d4456714b31466b3676555834544373594964724e75335a2f374e354f755635626668574d454f317533334a6c2b666a762b58676d4f4a487179414642774c59506c46634379414263634357484173674158484567677366696c694738434359776c524e6f4e364c49446c6a33717357483764566579694c4c6631574c45614463434359336b49316f5a5253704f48334a596d48386468436a69575a3244644f727642525a664f58695349597876633642674f553843785044796c34363375415377346c6a2f41497035394f685667776246474261736e577238673277666457775848676d4f4e425a61383738754650756d4648687641676d4f4e42706131727965703043636c57613041433434314b6c685771342f6c316e4b4142636361457978726a302b7941717a52775a71392b32394672694f7a4279594d6c7538534131675a63795a66532f2f664c37387463763379446155435949326c745042486f4b64457238682f557743734d6656514e656d796c346c65745961662f504d4177426f72334e6d6a5567457437775777787448536342586b7663724d414774737261383341524d6677444c38704156676a61584642766f625a5a4a413373696b68574f4e7254324d59646c723879467639506c502f696641476974324432663836683164437553464f74752f433744476a4e306a4b636553474e7137705a4158416c6a6a714b4b656369784a2f5475646741566743516a5751776b466c71472b466f3446734151457135514a73517948336746594145744173505a476c6c46676d5772625577414c7742494d72462b6e4d5347574362453777424953724e4c4657686f73625474696434416c4946675a652b6a5976546a53434c41416c6f4267375931554d5a74434930497367435567574366716d6278374d574a3367435567574c33723652444c5a446632417857414a527859475578706730537945707443674355675748764448586c334863414357414b4364594b4a335863434c49416c4b46684c6d52424c636b69483242316743516857685a6b47532f584f5367745141566943675a58783047436e597665434b6f41437341514536334134585a5a734b45374253676977424152724b5a306556576e724152624145684b73395851577932512b4a4557494262434541367533676c344a546162743441526743516a574b75626b6c365257423034416c6f42676e57414f3135734c55444944734951454b34314a6a32714c6b58594857454b435663476372612f66436241416c6f426756544f4e73557a613755673241437742775a717a78303748376758747741526743516a57556b645a4d717153415a615159505579543642564f414d4e734151464b3373783037346f636a7641416c6743677058426846696d2b6749736851424c514c414f4d2b6c52557a46694c49416c49466a56615a484d70744349596979414a534259705937656f32596a516979414a5342594751397077314a466f6e3852774249537246574f397534414332414a43745a687576656f5361564637413677424151726d326d4d5a564c56366c413943724345413674302b484139486851434c43484247713465725563725034416c4a466a446a62456934566741533069774849327869757652474174674351685736586f7a303952324f7735534143774277637034794d54755a65336f75416177424152726c654e77765146745a6743576b47444e30546f4f31774d7367435567574c314c6d54505132767070534938434c4f4841797169675730524b444d574933514757674744745a55352b535172514c526c6743516b573877546162696841743253414a535259537731306a4b5864436241416c70426772576471736571784b515259516f4b56736469784b647935456f51414c4f48416d724f486964324c33384642436f416c49466a4d7a66586f754161774241614c65514b744d686449456273444c414842716d414f364e54766c434a3242316a4367565836304c4570334e6b50734143576347444e32564e4762777033466741736743556757476d5254426675664a516c4179776877617067376730773548664473414357674741394e446e364633576a5a675a674351645774694d39576c384d73414357674741786433365a3048454e59416b4c46744d5979325171514e63476743556b5749755a6131564e3441706743517157493854536f754d61774249537241796d4d5a596b73685a334d77457341634536346567396976377541457449734c4c584d2f6631467539456a415777424153726c446c63543862757142344657414b433551697854495a326846674153304377396736485745614142624145424773704532495a367438425741424c4f4c424b4858642b5351346864676459416f4b5673596675326d4436484e3253415a6151594d3178784f346d484e414257454b4364614c6554736d6b31534845416c6743677056576236436b6a577a7658776c4e5142626a747745572b393641346a4a536e357671645a325759556d6c4673686264657267574f77514b7a49784c3546525868373542766d73784f332f392f5737414773597245504e4d6c6b7a2b5976386e667950557a4c49573557332f2f62314f77444c435659356b4241494c4f4e7658386453364154724b37666d314a55416553745a2b332f41735561654649593375564e494975533166767766694c4763326e42697654733933504574794676393535454857417164756e6a303644472b4c6d5973434e5866684c79533752637852355141613579713067574666546367723952514e50306177426f587243533944664a4f71544541613179774669624a395a423336674e59343670365330776f354a304b6f36376541566a6a694a69316243626b7054353951366b41574f4e63426a623370666367372f547073746d2b477462554165765863312b3644586d70397743574a343446554c7a5673746b4b67415848676d50427361614f592f58344a6a67574847744d7350547876736e574578794f39656c722f744237553932782b6d784a30312f775156656e713233423456677a722f704442356450626366713065756e6e3335325647574d2b734b394c5a54644259466a7a59777039494f53516d6375382f6c6e2b756c6b79772b4f5259473161756a577857507564504857766446664f533065734d5a797250646d5271587165367843617a447034444a665057766d7756636d575450393456694430316352366131507574486d316e5369306630724852754a30384868574a2f4f6a4f725239396c736651314371592f38624461397a3243396437756d4d476d534654507a50663834316f774c5957465a4c6d39782b3034534866766376524a32506f49494573636977556f644a43306d7455516f33614333797a3644396472744746743064507a6b4b54706148756f474c434563613268476c695a57773166736f717954785077776a65734c6d6b56726a676552593658715361342b32434755447467614a7249556b6d4370396572516d4a696f795244357879514e57715038356c6a374d7476692b4772547a4350426d7066702b6b4a753571366763697753724a49644b3454536c513975544253732b4e417a43795a4c43312b513636503835466a4544446634784d585259475735655356545a47423534466a71315a61517a69556362624e30686e4248704e336275414f64557636556b4535707a6f474a677a58394e44465a5776576a614c6e2f484375347752726673527255717a7337713661397a394b3071733671717663354935336433436e7656323372356736516379773542306f6d43465a522f50525a784e474e66473067694130756735637545686464426a65654a595a63706d37347a4d336e76452b732b703137734f4259416a6d5774504f5a622f7a787a5245392f76365361632f39413276676a392f597475325a78334e5a41387755397077336e39753262654a6771654e6a54762f6d35506c3961396936734f3874347637384e647a424e66732b6269516164313159343234715a2f54436863337078417a2b7841767a2f77714f356463596931774b753539352f496b526666546d4d79513154374246676655503749452f6b6d44394b32664b453839744538617854672f4e7a394a6b7368573761424f7859584d75647a427a305a6f49346e6762627a423230636375557a5761382b6c667a4e6645636964714e6f384b4668784c714269726b77544c2b53572b4850633442645a48482b5536683269773368795a457666456d7a525972436b76357a37584b5a526a6457544663722f706d6f2b4a7335766275494f35476771734d4e37504b464f7a39724d4e764b6d5a6d56765469666d5a756477507a3377536a7556337833495056687758724d6566794f5742785a3779555a78676a7555435669344e566c677337326530797a315978495442676d4d4a36466766745930483170766a67655533782f494f724b454e764b6c774c446957514934564273654359384778344668774c4467574841754f4263654359384778344668774c4467574841754f4263654359384778344668774c4467574841754f4263654359384778344668774c44695755493646656977346c6a7648636c39426d736b6652415570484d73377835707849597572734c58452f62666d385165334e765a47374f4f4f7a63734b323079633555346c332f6b346e656a49347173566a6a5846484f76656873614969456257723469496a63537453397778636a54392f72316a4c6f4e757070497a6a7847585843666567324e4e4c6365364e566e6e4375664373616157593930366470536e697754685a764157385a6e4c6f4e7570463465495732346d7772476d6c6d4d4e52617a64784e58576a71466a4d7a376d443736565471547a42386d707846475871613258694f5038695a746d2f415978316c546246655975346d6b727357457466327a52764f50455359334c364362696b73765558593145713876457464675654734538466966706c456e53636e5a7a6d49616269584a2f726e4452326c73624e726478706d6247556e6d73574634654b785a354c47546542636d387879487a44736643733049344670345677724565685750786d38444473654259516a6a574b2f7435577634654841754f4e5748486569325a3177613563506b794f42596361384b4f3964722b564c312b63455279396377783469383446687a4c55386661722b3772593130756f4538614279773446687a4c4d38666967695650676d504273654259634377344668774c6a675848676d504273654259634377344668774c6a67584843687248696f4e6a5052724865706b5243797a6e7950414641734d444932413570776a74574c6b734f53345130484147687938513449794e39486c6e6a325579685834635a634b784a756c6d4370616f4b302b3439356b387a722f79354758584b302f2b4e635174574a78726654317a72506c68697a693352464b6c795766586b762f686a75343754687a5035493570714e4c6b446279706978616470307554655250587772483837566a537a6d6b76507666636379383633365a74713371473966357a7a7a316a3266622b692b7942463663746d66624d632b77506575345a366c6f356438384b57596f753873437868744937356e505665707734316a696672786d58686937785a3835766a58417a3965545a4c394a64507278784349376c5a386553646b72485556552f2f6676494150562b565256336b71586658585744467a666344352f534954376a697a6f463644493435473751375653334834357a685a5067575031564846486b634159596a736163556c585636517257375a6e4a5043332f6450787a68635174766b6947766e415a704136327567373275706e613632346d67584f462f6e657361533979524332466e49466e2b6933384b5347384b532b365777724a48784b336750513944797049435a656c6350357834714b37705a42775851726e5237695a6576497334575970784132726b37497266486c59482b5536646f556a493435646f5850673553662b67626c57626d546b6f35654672486e5863486477477572345678782f6b4e3456386a64376936686449586471624f7a5739432f6d78334c336a356d783644597a4f6276436c7a397969676272695a4833683846694454426773542f6f4930484163755378584e73596e585735434a4d453678344a6c7273325274794f5237476172656c4438336b666e546c4747794d345667426c336c2f4f396638706e5462504d2b39744f4663594b4a6e334f48396b336e477545493646633456774c4467574841754f4263654359384778344668774c4467574841754f4263654359384778344668774c4467574841754f4263654359384778344668774c4467574841754f42636543593847784174757868722f7675634e67765a7a4c6436772f44722f2f78324777637631556a35585a7870617a486f757475466a794a7845527870314a546c33724d6e5734486f7337385a45345668734e6c707458794c38507a6856532b73697a6334572b4f6462384e746372542b687a685678523577706a586138382b5779447939526436563934632b574a4d493656785476797942786e44435042436e50377970726a5165685937332f6a7a636448394132536d68665a41322f2b4b776b5765387162314a546e32464d65662f7a4662564b42484f766b726e3058324e6f3337306e693750774c334d454c387a5931456f3172654950373572314633472f6c6a7537627433596a4d594d3338634b2b2b622f7871324f64334f567939535a315479654a543865614c4866613268694d70335465663459746e61574b4f2f432b31444c7447653655626277707a3777764246695559393037323867546462766c52763567592f70393472374c594d516c4e314d334869557575637938354e39544f70644f7a6e436e6b3565496a65356669646751684f634b705a5a744c4b576b534c6b4432797a386752517066325362706274666f50734b482f56466d4949344676485a4c62647965786953306d664555424365684c5a775246457a7a6f69624b554b41785a79456e69543531624853573964756474586174394b4a78726663766a4a2f597a41366c6841537972462b63334c726d6c306372534544702f6d3765494d5831704978316e6e65344b34317253355431367a5a544d5a594c684d372f42746a7a6267516c70586c38685a333453545273532f4d3959577773504e54735866447049486c7474754d68743456787649484c376a704e714f687a68587970693561644436646148585a6857302b3675633846752f494936314657565165532b50365171776d4b487333424a5a6a38524f6b7a763559334b7a706d6c457a37323349764d4f786b486b50356d347a676531596546594978344a6a77624867574841734f4259634334344678344a6a77624867574841734f4259634334344678344a6a77624867574841734f4259634334344678344a6a54656e71427338644339554e63437a336a725849545a2f3354453073643541716d326e6a4e33393339486c6e5439566f7a704e67635438364d785a393371655559366b70783571784a6d736557316c5a6d346e3772664f34672f4f6f597930522b2f6944575538535a336c547337492b546963367376677a572b4659553853786c672f6670624f526634436c6f3547343244696a677a643466414f785959596e557a736937684d624f2f6754302f31396c30377571416457593131667959566a2b5175733551646e486f794b6a6f383633657675547139654e2b646137765865752b585a31487475426f654975522f477834662b7a6379444d2f336a5742707653704d3156454573484d736659433137366157586b6b5037587468536e5a33394c6b2f5a3261356a376766646a727166575433337936536b47764b5035663931425849736a5863313732766757503441612f6e743262506d7a6a71395a6348706a4e3771624c36717131334852686e31654c443633644a5a433761636e6a5672316f4b4479345633724d624e483776523173316b594c68326b2b734c6d7a613170672f427366774131737946784b5053724b764c685865735935633275744f6c5938543955563635434d66794131677a6c7a383673453566466469783943396b2b504c3375445533436f345654493531576e6a48326b4b753639362f4c5369455977557a57424e304c4775665652337a77765158706e7631566b502b466c4e6b6732504273555946693452444c2f64462b6a34724841754f4e515a5956707476736c7268574e67566a67585742415448456a5a424f6e4d324762342b457331646546427778777036734d535565582f36306569663333684a32476546634b7741653159343878464a36476546634b78414b35734a464d4778677177654b31414578344a6a77624867574841734f4259634332444273654259634377344668774c6a675777344668774c4467574841754f42636343574841734f4259634334344678344a6a415377344668774c6a675848676d5042735141574841754f4263654359384778344667414334344678344a6a776248675748417367415848676d504273654259634377344673434359384778344668774c444743396165352f2f51766f2b6d316d5646462b7034653957704c703055496455707a4471522b37337636704a6e4c2f6b5855576a5a627166425253716f48716656374535445631684f6a564c516f664e5a6b6766582f583173326d6c364c4b6670655556486c7436524e676a685730387163412b71696f7538563376366e5a614c575038312b384544706b7834387542623668364b4a365874464d62372b386151554478622b482f2b413965783350766b68537a2f34737a48306a33394236642f2f75314436642f727a2f6357666956312f3662736333394d4a36522f2f63694c36587a2f343455382f2b566d70774741392b396666662f583556352b6e3368792f6a61572f5a2f512f4242507a2b5a3666797670374154544276774a4a774b732f2f326d326b474439384a76502f2f3678587a3147762f32652b7531586a2f33357550707677756e506f55657678796a392f74587666794959574d2f2b2f4657534a472f30713865382f49447850702f516e3142382b70586a6d7a43524e32482b49742f38613448412b733733662f385942446e312f412f654651497363415878765050356e3738376362422b4271346756382b614d466a5a507764586b49747050662f4469594c31672b66786259526339633266546779736e37364b3779486b7a724f2b6e7a30527345712f6a323868354775594e515a596634324645427246736c37397848657766765a4e66414f6830537872334a78444341774c386b4776667364587348373236712f7737594e47743678734838483636664f502f5171435274466a722f374d4e374371662f684e43427064332f2b4f623243392b375076514e426f2b7553545437496e587567485156344c5945454143774a59454d4343494941464153786f4b75752f424267412b67346a7069314f7a4d3841414141415355564f524b35435949493d),
(265, 67, 'nombre', 'Media', NULL),
(266, 67, 'valor', '2', NULL);
INSERT INTO `etapa_opcion` (`id`, `etapa_id`, `meta_key`, `meta_value`, `imagen`) VALUES
(267, 67, 'imagen', 'imagen', 0x646174613a696d6167653b6261736536342c6956424f5277304b47676f414141414e5355684555674141416c674141414a5943414d414141434a75476a7541414141475852465748525462325a30643246795a5142425a4739695a53424a6257466e5a564a6c5957523563636c6c5041414141795a70564668305745314d4f6d4e76625335685a4739695a53353462584141414141414144772f654842685932746c644342695a576470626a30693737752f496942705a443069567a564e4d4531775132566f61556836636d5654656b355559337072597a6c6b496a382b494478344f6e68746347316c6447456765473173626e4d366544306959575276596d5536626e4d366257563059533869494867366547317764477339496b466b62324a6c4946684e5543424462334a6c494459754d43316a4d444132494463354c6d5268596d466a596d4973494449774d6a45764d4451764d5451744d4441364d7a6b364e44516749434167494341674943492b494478795a475936556b5247494868746247357a4f6e4a6b5a6a30696148523063446f764c336433647935334d793576636d63764d546b354f5338774d6938794d6931795a47597463336c75644746344c57357a4979492b494478795a4759365247567a59334a706348527062323467636d526d4f6d46696233563050534969494868746247357a4f6e6874634430696148523063446f764c32357a4c6d466b62324a6c4c6d4e7662533934595841764d5334774c79496765473173626e4d366547317754553039496d6830644841364c793975637935685a4739695a53356a62323076654746774c7a45754d43397462533869494868746247357a4f6e4e30556d566d50534a6f644852774f693876626e4d7559575276596d5575593239744c336868634338784c6a41766331523563475576556d567a62335679593256535a57596a496942346258413651334a6c59585276636c527662327739496b466b62324a6c4946426f6233527663326876634341794d6934304943684e59574e70626e527663326770496942346258424e5454704a626e4e305957356a5a556c4550534a346258417561576c6b4f6b5644516b45304e455a45517a4642526a457852554a424e454d304f5445314d5551344d7a4243516a6779496942346258424e5454704562324e316257567564456c4550534a34625841755a476c6b4f6b5644516b45304e455a46517a4642526a457852554a424e454d304f5445314d5551344d7a4243516a6779496a3467504868746345314e4f6b526c636d6c325a575247636d397449484e30556d566d4f6d6c7563335268626d4e6c53555139496e6874634335706157513652554e4351545130526b4a444d5546474d544646516b4530517a51354d5455785244677a4d454a434f44496949484e30556d566d4f6d5276593356745a57353053555139496e68746343356b6157513652554e4351545130526b4e444d5546474d544646516b4530517a51354d5455785244677a4d454a434f4449694c7a3467504339795a4759365247567a59334a70634852706232342b49447776636d526d4f6c4a45526a3467504339344f6e68746347316c6447452b4944772f654842685932746c6443426c626d5139496e4969507a365a6f6e4967414141444146424d5645582b2b764c723364507a362b58753439717a676c335562414756306479356a6d32366b48486a30634f6e63302f357a5866333875367165465054375048557571586579626d33695761366b58536e776a44436d33327567575731332b65336a6e4c3478463762784c4b636145725173357a6773336574322b5461717a443832364b6a63565330696d334c323462616351545a7761365658547a3037656a2b392b726c3763547338745035396648476f6f6279707933382b2f6e3936636232746a6e566c526a4735757956586b434f56445770656c3338372b475a5a4561726657486d317371525754726e6667324e557a544c717044456e6f4b2b6c4858746f7975346a477636392f54713976693934756e3078356530685748332b75764e725a585a3561587939754779686d722f2f506931686d4c5374714779796b7a6e324d796f645648486f346a74716c72763574376a32597657764b6a50735a6d376b5848716f7a75625a6b6e697a38484a706f7678717a48392f50766d65777133696d66706e6937373034337a79347274784954372b666631304a506d677858797244483376557a667a4c332f2f2f2f6d696866706979656c6456697a694779786746715759454a387874535a7552436862314c42354f723377466273344e627a2b7676786f696e6f32732f4b714937546177436e65467a633850533267316150567a65366a322f2b2f76797579454b54584479627568573369326a30734457357a31726e7533337577344b7766317232754437677755723479477638354c585962774c71696862363170434d7a646e776f43663533734c736e4566756d4348393774536c324f4833756b583733366a676467667874485879765954526f32373835372f7475586d2b342b723376314c39387476766e43543935722f787458626f67786e7a7659582b3864762b394f4c37317054383437666f75336a6c357133706d69546d395066746c523730727a50736b527a4635757a43685466566c7a65786746763733366e726e696676786f6163314e2b2f6c336a2b2f667a2b2f76363268324c37324a753268325439374d335976367a4d71354b7a67312f4e733661555844757967567a6b6b427a392f667a6e6c5344456b324864794c665a655175766847662b3975656662452f77352b435859442b773365582b2b652f706e7a542b3739666964776954576a76327a615037374e7a7739647a687846486936377a76725762716d69507373326d637578666e6a7876762b5071617568507578596a35303558323071762f2f767977674672363159374f367644726a426a6c7548666930485834796d2b327a5650372f66664435657a312b4f666865416e7a727a54347832663478326a6575304f3169322f392f666e392f76724a326e2f393764482f2f2f394a567934314141414241485253546c502f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f3841552f63484a5141414556644a52454655654e727333586d59585756397750454267776b5969444e47416c4b58734953774249516f454337457044596f4567775242575670616b57524b453745476c735245375859466865304c725855566d317239785a74626164596b686a4474436b7452564f703074703973626257326b7133744c53647953544f7a486e7633487650506374397a7a6d66373538333835447a6e5074684d722f66632b6339512f386e4664435157794377424a62416b73415357414a4c416b74674353774a4c49456c73435377424a62416b73415357414a4c416b74674353774a4c49456c73435377424a62416b73415357414a4c416b74674353774a4c49456c73435377424a62416b73415357414a4c416b74674353774a4c49456c73435377424a62416b73415357414a4c416b74674353774a4c49456c73435377424a62416b73415357414a4c416b74674353774a4c49456c73435377424a62416b73415357414a4c416b74674353774a4c49456c73435377424a6241456c675357414a4c59456c67435379424a59456c73415357424a6241456c675357414a4c59456c67435379424a59456c73415357424a6241456c675357414a4c59456c67435379424a59456c73415357424a6241456c675357414a4c59456c67435379424a59456c73415357424a6241456c675357414a4c59456c67435379424a59456c73415357424a6241456c675357414a4c59456c67435379424a59456c73415357424a6241456c675357414a4c59456c67435379424a59456c73415357424a6241456c674353774a4c59416b73435379424a62416b73415357774a4c41456c674353774a4c59416b73435379424a62416b73415357774a4c41456c674353774a4c59416b73435379424a62416b73415357774a4c41456c674353774a4c59416b73435379424a62416b73415357774a4c41456c674353774a4c59416b73435379424a62416b73415357774a4c41456c674353774a4c59416b73435379424a62416b73415357774a4c41456c674353774a4c59416b73435379424a62416b73415357774a4c41456c67435332433542514a4c59416b734353794256624f75664f4e566837734c594f58635957654d6a6f364f5858536c4f774657667532385950486f776334347a4f30414b352b7576326231364977575837445450514572637973656d442b61615055313137737659475671375a37683054624e6632434665774e5733793163744735306a6f62337248562f774f71725a53664d472b3351756b554c33534f77557266766f7248524c73327a324149725a567333426f79326e2f2f676d755272466c746770576e44346f4456315465334a6a702f652f4148466c74673964614f493163483335684750743836324e4e47416c6f57573242316238586a6732394b3479506e74576230704a4635466c746770577674795a7553614e59764f626556614d755364525a6259505865776b587267335856306c57744e7133615032797842565a764c54746850496c6c7a594d7257334f304d6877524c62624143747433333935777639447157446769576d79424e62757447344e74364d6a4e7261364649364c46466c6a54626267343657507639483668633231475249737473436262636553395866594c6e57737a496c707367625869707530393742633631325a45744e68714e71793178392b654a4c467036625a573674714d694531666244555a31756b76326831776d48752f304670313142586e70686b526d373359616936735a5a655070396b7650487a5548524e6630596c574f4349326562485656466a376e684f7372525a3032432b734f7572515631317853706f5273626d4c72576243657379317166594c55392b74446e58554b576c47784b597574706f49362f75437464583467764e362b573756433630324932496a4631754e6739566d626256727964766d687649377337356239554a72355950423734737433724154724670332f553158422f754631327a72784771757a3774336f74553666304734324c6f66724e7032772f4672556e782b6f524f727272544345624668693630477757717a746c72776a46612f724c7253436b6645345a5058676c5737466f5a727135476e5a574c566c565934496a5a6f73645551574963486136753949302f4b7a4b6f72725842456e4866434d724271764c62712f506d46336c6c317052574f6941315a62445541316d455870396f767445354a78616f727254596a34736174594657396e526345613676624f2b30582b6d44566e56593449745a2f735656765747335756764f6675444a335674317068534e693352646264595a3177774e72557530584d7244715469736345657539324b6f76724e50333745363158386a49716a75746345537338324b72727241575872347531583468423162646159556a596e3058572f5745646668567952397031693359556a7972377254434562477569363036776e724d47354f2f4a4c693734333668646534566f7a6e576856597749745a7a7356552f5741644f2b702b3958336a6574764a593955417248424672754e69714761775a4a2f3333746c386f67465550744c597357562f33785661745943564f2b6a3977454e2b625775577a366f4857717158443956357331516a574465464a2f35333343775779366f46574f434c576172465647316a6853662f7a4f753858436d6256413633574d7862556437465645316a6853662f726c6e54634c37542b734842577664414b527354614c4c5a7141537463572b33652f33414572487168465979494e566c73315144576c63464a2f3273363778644b5a4e554c72574245724d5669712f4b777470365263722f51617233354a307275364737483151516a597655585739574774544d3836622f4c666d47793333397079623235682b4e71357464737356566c57506348613675786b646631634f6851684c44616a596a56586d785646316234674d703549792f70365453724f47473147524772764e69714b7179314a772b6e33432f454436764e69466a647856593159595672712b483971336f2b6679396557473147784b6f7574716f494b3378415a626639516d49712f4c5a45582f2f6c585074363872392f6449714c433066456169363271676372504f6d2f36333668573739786471373965726172435566457359763267565830326d706a2b77634a31676c5775784778636f75746173454b316c6139375265714236764e694c683441316a4646443667737466395168566874526b5256312b7a41367a383131624241797054482f546647367a6a4870653662785143713832494f502f784b38444b643230566e5053665a722b5143745a76626b3764554547774a6b664554525664624655433173495837637130583667757244595076616a4959717343734d494856485a376b474364594c555a4553757832496f65566e6a5366773737685736776e7633594e6e3174382b5a766871392b6f5868596b79506937492b636a6432334436787361367472672f334335334e2f32304a59543335746d38375a76506e59384e58664b674e57712f5753354967592b324972616c6a4253662b70486952594b31697431726e4a4554487578566138734e34536e50536633333668697244616a4967784c375a69686255694f444a74654f6d7167743677717342714d794c477539694b45315a34306e2f48672f34624136764e69426a7259697447574f464a2f336e7646796f4d4b78775234317873785163726645446c794d3346766c4d566778574f69444575746d4b44465a7a30763765492f554c465959556a596e794c72626867425366396433795159494e6874526b52493174737851517257467356746c2b6f4161773249324a556936316f594e30666e50532f61656d326374366869734a714d794a47744e694b42465a3430762f384976634c645945566a6f6a524c4c616967425775725172654c395148566a676952724c596967445736587432425166787257794231666549474d5669612b43776770502b79396776314174574f434a47734e67614d4b7a446e7a4e6579756358616734722f46334567532b3242676f724f4f6d2f38344d4577656f38496c346430324a72674c414f4f2b4f4f4e4138534243763169446a4978646167594955507143787a76314254574f47494f4c6a46316d42676853663964333651594e6d77627674556d7a347838666f3577617648524155724842454874646761424b7a77415a566444766f7648565a6376365754635551637a474b726646696e4a302f36372f4967516241796a34694457477956445374595734325062426e302b314137574f47494f46373659717463574d464a2f37734873312f6f424f763137307264663859484b7867523935613832436f54566e44532f2b3350327862466578446e61544f356a34696c4c72624b677855386f444c7a5158786770523052533178736c5151726645446c5150634c545945566a6f69726a39785249316a68326d72412b34586d77417048784f336c4c4c5a4b67425763394439763450754668705559455465567364677148466277674d703143375a347177633849713476667246564d4b7a67705038343967734e4c444569467237594b685257634e4a2f4c507546527059594551746562425549613939395937487546787061636b517363724656474b7a67705038654869536f736b664534685a624263464b6e7653667a30482f796e39454c47717856515373344b522f2b34576f65743373456247597856622b73494b542f6e742f6b4b424b47784848693135733551317237636d4a7379703237332f5947786e39694a6a2f596974665741735872532f796f482f6c324c625862437079735a556e724f436b662f75464b6f32492b533632386f4d56504b44536671467949324b4f69363238594733644f47612f55494d524d626646566a36774e6c78637a494d45566636496d4e4e694b7764594f35496e2f647376564874457a4757786c526e5769707532462f63675151316d524d7868735a55525676434153767546656f79496d5264626d5741464a2f31765039392b6f53346a5973624656675a5977556e2f56392f737a616e54694a687073645533724f51444b73664b5034685068592b492f532b322b6f5356504f6c2f3369414f346c4d4a49324b2f6936322b594356502b692f726f48384e596b5473623745316c48317456654344424457674566474a38374d7574744c43436b3736582f4f675162434f76576e6d2b7a795766724756446c5a77306e2b35422f317263434e6932735857554a61316c66314376547476316f6959627248564f367946696257562f554c6a52735130693631655953556655446c75763943554566483276685a6276634661647133396768487834474c727968786858574f2f59455138314a3643594e6b764e4c456c6478514e61366d62334d5432462f3464792b494b4c4c41456c734153574e6c682f6539544a2f724b79366237515457777635734738504b6e54705552316c6b766c646f466c7341535741494c4c45554836374f666d656772337a336470772f305132704d4c2f76307246372b6d616d4b2b623143483574705472396435692b736767555757414a4c59416b737341535747676e72716e7350644c5161302f44555733377638595843536877306f2b5a304f5667435332434242565952734334626d7569686a62734f3941393371436d4e5437336c7578594e4865697976474639316964464e4e465a59416b736753577777424a59416b7467355166727135664e364a58766d4e6e72507a4a487837316a5945563254663834783958634e5a69373878397a335a3158686c39373132577a2b6d71684835763530624e6e64747a6d4f58725832514d72736d74363978785838314f44755475506d2b76752f475434745865562b586b73734d4143437979777741494c4c4c44414171764b7349592b5074336e496f4556797a556468505846366173354b774a59703836344f772f46432b76554757753048346b4556697a58644244574c3031667a533947414f766e5a3979645877414c4c4c444141677373734d4143437979777741494c4c4c444141677373734d414343797977774b6f45724f50656d37467667445634574f2f4c314e754c675058657a526c3764393677627378306b3835734a4b774c767a4e4c5a7a5944316b396e756b6e764151737373476f4f367a732b3047642f44465930734637782f7237362b794a6866626a66642f484869344c31352f336470526330474e6250397663507a6a4f624265766e2b72744c4877594c72434a672f51785959494756503678762f2b46304e52505746394c6470492b4274666b54723031584d3246394b4e314e4f685973734d4271477179546a706a646e5a4d764a6c34373469537777456f4a363835625a3366453549754a31323639457979777741494c4c4c444141677373734d4143437979777741494c4c4c444141677373734d414343797977774f727a383169505456637a5952326237695a394536794950304561457979664941554c724468677665466a36576f6d724750533361546277504c4475782f657751494c4c4c444141677373734d4143437979777741494c4c4c444141677373734d4143437979777741494c4c4c444141677373734d41434336793850764d6537526d6b4d63467942716d504a76746f4d6c686731666b7a372b656b71356d77627674557170766b4d2b392b655066444f316867675155575747434242525a5959494546466c6867675155575747434242525a5959494546466c686767515557574743424256596a5966334e6b39505654466a6e704c744a7834446c4536512b51516f5757465836702f424436576f6d724f394a64354f2b427059663376337733685857304d656e2b31776b73464a64552f4777766a68394e576446414f76554758666e6f58686868513065567170724b6835573047426868594546466c6867675155575747434242525a59594b574264643364422f716a6a3837526936662b2f4c6f795957573470694a6733545031313731676a71763579366b2f767273735747644f2f5855766e757675664e66556e2f2f3767474864665774502f56365a7348713870727537776a6f70325a7776646f4c3142373164546c6d776672653379336b57574d584253686c5959494546466c68676751565758724275764f65656531373159783137316353583346676d72417a586c506a682f5968456b79386d582b7636772f757a4a763675662b74384f5838783853566c77627075347539365265664c2b65754a4c336c37424875734433622b482f6d546739686a64626d6d4435613878377177382b583861736c3772462f7266446e766932524243685a594d634a36773750543155785978365337536265425663786e336d73484b39665076494d46466c6867675255507241732f30462f4e677658712f6d37537178734d4b304d4e6774562f59494546566d36772f756b39576271784762432b4e394e4e2b6d516a5952565a62574156456c6867675155575747434242525a5959494546466c6867675155575747434242525a5959494546466c6867675155575747434242525a5959494546466c6867675155575747434242525a5959494546466c6867675155575747434242525a5959494546466c6867675155575747434242525a5959494546466c69566850576c354c4e414a6c394d7676596c734d424b4353746c59494546466c6867675155575747434242525a5959494546466c6867675655697244393566353839457979774f73444b46466867675255647245744f5737373854392f35725a377939493439355a3044714d39722b7564667964674c322f39334f312f4e302f38723772767a7775584c6c353932536447774c6e33304362656f675433687845634b685057766a33362f57397a552f7572452f79344b3171567664587562334673664b5162576c2f30723250522f447938744174596a584a4631536636772f73652f6737726c2b572f4a4864616a3771707575655845764747643972647571695a6d77792f6e444f763537716b6d2b3564385966325a4f3671706c75634b79302f754f76547a653536776c7275664f7452704f634a36376739494233747567522b626b63415357414a4c416b74674353774a4c4a585a2f777377415056446c533769354c63554141414141456c46546b5375516d4343),
(268, 67, 'nombre', 'Baja', NULL),
(269, 67, 'valor', '1', NULL),
(270, 67, 'imagen', 'imagen', 0x646174613a696d6167653b6261736536342c6956424f5277304b47676f414141414e5355684555674141416c674141414a5943414d414141434a75476a7541414141475852465748525462325a30643246795a5142425a4739695a53424a6257466e5a564a6c5957523563636c6c5041414141795a70564668305745314d4f6d4e76625335685a4739695a53353462584141414141414144772f654842685932746c644342695a576470626a30693737752f496942705a443069567a564e4d4531775132566f61556836636d5654656b355559337072597a6c6b496a382b494478344f6e68746347316c6447456765473173626e4d366544306959575276596d5536626e4d366257563059533869494867366547317764477339496b466b62324a6c4946684e5543424462334a6c494459754d43316a4d444132494463354c6d5268596d466a596d4973494449774d6a45764d4451764d5451744d4441364d7a6b364e44516749434167494341674943492b494478795a475936556b5247494868746247357a4f6e4a6b5a6a30696148523063446f764c336433647935334d793576636d63764d546b354f5338774d6938794d6931795a47597463336c75644746344c57357a4979492b494478795a4759365247567a59334a706348527062323467636d526d4f6d46696233563050534969494868746247357a4f6e6874634430696148523063446f764c32357a4c6d466b62324a6c4c6d4e7662533934595841764d5334774c79496765473173626e4d366547317754553039496d6830644841364c793975637935685a4739695a53356a62323076654746774c7a45754d43397462533869494868746247357a4f6e4e30556d566d50534a6f644852774f693876626e4d7559575276596d5575593239744c336868634338784c6a41766331523563475576556d567a62335679593256535a57596a496942346258413651334a6c59585276636c527662327739496b466b62324a6c4946426f6233527663326876634341794d6934304943684e59574e70626e527663326770496942346258424e5454704a626e4e305957356a5a556c4550534a346258417561576c6b4f6b5644516b45304e455935517a4642526a457852554a424e454d304f5445314d5551344d7a4243516a6779496942346258424e5454704562324e316257567564456c4550534a34625841755a476c6b4f6b5644516b45304e455a42517a4642526a457852554a424e454d304f5445314d5551344d7a4243516a6779496a3467504868746345314e4f6b526c636d6c325a575247636d397449484e30556d566d4f6d6c7563335268626d4e6c53555139496e6874634335706157513652554e4351545130526a64444d5546474d544646516b4530517a51354d5455785244677a4d454a434f44496949484e30556d566d4f6d5276593356745a57353053555139496e68746343356b6157513652554e4351545130526a68444d5546474d544646516b4530517a51354d5455785244677a4d454a434f4449694c7a3467504339795a4759365247567a59334a70634852706232342b49447776636d526d4f6c4a45526a3467504339344f6e68746347316c6447452b4944772f654842685932746c6443426c626d5139496e4969507a357449574159414141444146424d56455747626d4c4770337262352f4c4173367a59354b53576a6d6e353059534c63326577794e374c7738436575744c4a72347a39387476476f6c477078445836377457546e616c44624a5069362f4a76556b4e775630753079302f362b2f33457939503631704470372f616b707175757864706c53546a4a76376d6d736d6a64313950323950504a776232445a567274374f7478574569556c55534c696d2b2b3034392f63577a38354c583733366e68363771347a642f32746a6e4831486d4b6648664e7571566d656f482b2b2f4f69766458783964324f6d4b5074383958392f666d63694831395931576d6c347a4476627469526a54593063315764496e4c32345847326572357a3375646a49436c6b34715a755243377572762f2f2f2f6d37734f79736258372f506154666e4a64684b7a723850573674376e392f6632636e4b487939666d455a6c73335a356e6e3665616f6d592b436f7276413147794462562b616b476a53344a6151643275376e6c653079643241596c65776f706d4863474f617473366e7137474f72637241304e2b4969446c7054447978795965656e4a3768334e6e337631476f77646a5534752b4870386275382f6439626d663478463662754e476e77646434573036666f31533578394f696b324e62646f663632707a38364d48357a58614a666e3337323578736b72662b3975666335752f38364d4b416f734a6668362f4a322b742f68585772784e766572455661646f66713866652b6b6b6d626f7175327462625233757258347533663464332b3975624c327566357a58664b7845373479477262785a503479477452664b682b684858322b5076507762542b2b4f764731342f4675724e31584532546d3079596d702f61342b7a52344f367472375a2f62574a72546a37302b507458616f5754723865476e3753637578664377734b387a2b47666f3633373371576c76395a6a527a5837346137413075506c344e31786633785867617638364c2b6b714c423458314330707036486b4a2b306e586e426d313135676e69767834552f61355764757869716c312b4b645775627568585076713673766332357934622f2f50642b656d2b617474424a627044446e3265456647753576634f50653237342b75333631496e2b392b6d736d5a4c677a6143686f497073556b4b6a767458563465792f30326e6a3374764d7a4d2b617568506133754f6a764e533279747646324f6e3936386c305730765a354f3736325a6e493271436b70316d327a496c516359316b534462352b506678377532567338374b786c5a396132502b39654e7556454e62684b32327261533973616d5265322b42686e542b2b6536586e492f6e3475447136655449795750497a6e43516a49373478326559744d325974632b6b6c4972693364722f2f2f38397679716c4141414241485253546c502f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f3841552f63484a514141436c5a4a52454655654e727333586c3048415564775045674b54576c704a56616f425145576735374161574659677459514976514675687943475368676e4b715246447751504867617341445647694c614253744279676741703667494a63486549426742546c45504d4837506f695473504f634e4a747364724d7a757a507a2b6637543933733732356d642b627a64795752333039496a7856434c58534377424a62416b73415357414a4c416b74674353774a4c49456c73435377424a62416b73415357414a4c416b74674353774a4c49456c73435377424a62416b73415357414a4c416b74674353774a4c49456c73435377424a62416b73415357414a4c416b74674353774a4c49456c73435377424a62416b73415357414a4c416b74674353774a4c49456c73435377424a62416b73415357414a4c416b74674353774a4c49456c73435377424a62416b73415357414a4c416b74674353774a4c49456c73435377424a6241456c675357414a4c59456c67435379424a59456c73415357424a6241456c675357414a4c59456c67435379424a59456c73415357424a6241456c675357414a4c59456c67435379424a59456c73415357424a6241456c675357414a4c59456c67435379424a59456c73415357424a6241456c675357414a4c59456c67435379424a59456c73415357424a6241456c675357414a4c59456c67435379424a59456c73415357424a6241456c675357414a4c59456c67435379424a59456c73415357424a6241456c674353774a4c59416b73435379424a62416b73415357774a4c41456c674353774a4c59416b73435379424a62416b73415357774a4c41456c674353774a4c59416b73435379424a62416b73415357774a4c41456c674353774a4c59416b73435379424a62416b73415357774a4c41456c674353774a4c59416b73435379424a62416b73415357774a4c41456c674353774a4c59416b73435379424a62416b73415357774a4c41456c674353774a4c59416b73435379424a62416b73415357774a4c41456c67435332445a42514a4c59416b73435379424a62416b73415357774a4c41456c674353774a4c59416b734b563559337a387173665a31474849453636686c6962586359636752724e484a775272744d4f5149566f746e4c4b55636c6d63737344786a7153376e57464e4f54364144484962632f5652343949514532743168414173736753577742425a59416b746743537977424a6241456c686743537a6c457459666a39474174674a72784c58736f51453941785a594d5853466c304b77346d672b57474446305a35676752564439783049466c67786c5034724d4741315a647541425662397532614c726345434b34612b36386f3757484730506c686778644655734d434b6f5a66374a54525963665246734d434b6f382b444256594d33655439574744463061466731616652792f5065662b6448657843734f7347616b50653237736c6359494546466c6867675155575747434242525a5959494546466c6867675155575747434242525a5959494546466c6867675155575747434242525a5959475548316b34766247536e4a743176587a53677255357172715a6d4139623477334c5670384c3374752b7a714c63505a664f54324743424e66424c5354786a676457736e38514743367859506f6b4e466c697866424b37475741644e435a58376472737347374b79755747452b666b7171614864536859594d58526e6d434246554e50487767575744473054773959517a586d4e5133717270544461674e72794934724e4b68337042765738623845433677594f7141484c4c43613936764173773172646b63747a5137756555524e392b79345076577772766b56574a56686e544f726c69344c37726c52546665637458337159625830674a5653574f4f334c54572f44396157327a613452362b493967657755677372664e7a375067757230652b4c336a4b7a62303047437979777741494c4c4c444141677373734d4143437979777741494c4c4c444141677373734d414343367a6d6776584e5455763970412f573145317262663336394665777367467235734a537a2b6d4464634843476e765869412f2b6f6d6344437979777741494c4c4c44417969367353346666633845436139697771766763304c6c67675155575741324864635247772b686d734d4371456c624863466278504c444141677373734d4143437979777741494c4c4c444141677373734d4143437979777741494c4c4c444141677373734d41434b3346594c333174484333703775342b5a47777448644c642f6469346d753435396d2f4253696456324c4344503146714537446937544f4c3868785959494546466c6867675156575043316475584c6c776356533130574871344a685a6239685a6d6d594752324b76634e563065473659764768785973582f36587a71645772562b2f64575770734d4777514865344e6833484273466b346e445270795a4966684d4d4e7753316e5259665068734f30364842744d467a6232666e44594b582f4c6a3457624d485a346562384b44706346417954506c70715937446937634c67775730532f6a42656a41365465783933762b4755306e424b644a6a544f30794f4473587763734d757764415a48704f3342634d486f3850463454413247445949682f6345777766433465334273466c304f437363706b57483663457750627a63384f35674f4476636e497569772f7543595a4c4c4457434242525a5959494546466c6867675155575747434242525a5959494546466c6867675155575747434242525a5959494546466c6867675155575747434242525a5959494546466c6867675155575747434242525a5959494546466c6867675155575747434242525a5959494546466c6867675155575747434242525a5959494546466c6867675155575747434242525a5959494546466c6867675155575747434242525a597a51647238376132746d323653743059485870766165733358463061726f344f586233443574486878713675586465735758506e69747457725672316c52576c64673647627730367242634f76312b77594d475877324844364331444478757557504874594b566636726f7732494b6c34656138624e31687763644b4c65336430725966677856587935633152314d6173745957734c494f61786c5959494546566d5659552f4c636372446961765345504c63545747434242525a5959494546466c68676751555757446e753433756b7679764241677373734d4143437979777741494c4c4c444141677373734d444b664663656d2f362b4131627a586e6c5063363847437979777741494c4c4c444141677373734d416151643934667234434b79465934772f4c565a39636d4c6e4141677373734d414343797977774d6f4e72494e656b61736d673555517242506e354b715a59494546466c6867675155575747434242525a5959494546466c68675a5148577234394c7350384d6576672f56367a552f5255586d517857453846365a794842336a6f6f724f4b6953703157635a474e775149724f566750767a4b4e2f54514c734a3438733672324b685275507250717a722b375162412b6b736f504f37386843374347395a574a2f2b2b3851754838576457336657565933337476326536497776707a2b57563241517573515747645850366562347243656e50355a643449466c6867675155575747434242525a5959494546466c6867675a5555724838656e35352b41565a36594c306c526439597367565959494546466c6867675155575747434242525a5959494546466c6867675155575747434242525a5959494546466c6867675155575747434242525a5959494546466c6867675155575747434242525a5959494546466c6867675155575747434242525a5959494546466c686767515657584c422b567968386456525642554c75486c56397338484b466177764e4e46667067414c4c4c4441717668532b4b637a716d705538464a34527656354b585479377551644c4c444141677373734d4143437979777741494c4c4c444141677373734d4143437979777741494c4c4c444141677373734d4143437979777741494c4c4c444141677373734d4143437979777741494c4c4c444141677373734d4143437979777741494c4c4c444141677373734d4143437979777741494c4c4c444141677373734d4143437979777741494c4c4c444161676973555231563966564334636d4f36727365724c7a4238676345774d6f32724c336658375a78555669506c31396d476c68674451707279453672754168597a5152727a4f735362417859755948564a494546566e79772f6e56793252364a777271332f444c5477514c4c54345667675155575747434242525a5959494546466c6867675155575747434242525a59594945465668706833544f6a39596e742b6e70394172336768436273353563482f656153737533596539766c587a756837352b2f6c312f6d4838464e4f3554396e3539345658726137734e68742b387752442f62622f3968774e712f7458337453354973326255317645772b3346736e7a71674561306237327077646164576c6962734e425776656a76615161757654725950446d6a66522f6c484e765867775746797054724c36777a7263727447496169304c7139574f30516a5073335972413276754c58614d526c6a37764947776e4743706271645a4c5634495664385877376e72774a72583772716f3674414436384479684b573674485a7566316a74646f6e7130754839594d32775131536e733678376f7244324f314b7154334f4865714f664e4a4c41456c67435332424a59416b73675358567566384a4d41434a4962383939707058365141414141424a52553545726b4a6767673d3d),
(271, 68, 'nombre', 'Planchada', NULL),
(272, 68, 'valor', '1', NULL);
INSERT INTO `etapa_opcion` (`id`, `etapa_id`, `meta_key`, `meta_value`, `imagen`) VALUES
(273, 68, 'imagen', 'imagen', 0x646174613a696d6167653b6261736536342c6956424f5277304b47676f414141414e5355684555674141414a59414141426b434159414141426b57386e77414141414358424957584d41414173544141414c457745416d7077594141414141584e535230494172733463365141414141526e51553142414143786a7776385951554141462b3053555242564867425a62335a6a69314a6469566d5070307070687433794d7761794a6230432f6f567355476f77534b425a6a562f492f2b48547749685157694a716c652b365647434945447359755634387734786e644548325670724c334f2f3153637a4548456a7a6e45334e39753268375858336c6239307a2f395439506c664535314e61564c3336653236394b51767a644e6b3837346656337a6137316570367075307a524e7156335661526f54763571365357315470346648542f6b61546572484b5858354775667a4a5730326137372f63726b6b764d5a68534f4d3470715a742b6631794f655850312f6e335978727935336a7466462f2b50662f733178512f597779723154722f564f5578705851366e644c7437617430504237546b4b2f643533467a72506d2b6662356d6b386531577133793779393550483271386e5771716b7074766a37486b386651356238504978356d346e506a4f726a654e4131707539336d363757384c39364c362b4e76347a6a6b332b667264453161723635543136375336597a6639337766766e41507a414e2b78706777566e7a2b2b6e7248612b44312b5069593532695437396e6e76326e38322b306d59546937335530653879476566654a36634c7a356d6e69663171624b3138707a324854382b584935383736613230466a574b2f53716c7478376a4550303654783444715943317872696e6d4248505144786e6954446f63443136334b64322b614b72392f6c65566a4b4d397965337554762b6633347a333564786766666f2f587a63314e716a464a6d4e7770582f67362f774b5469357467634a6a5174753334356a34507a414e496f78596269344362482f4a456e5339355556734934496f33776476773848772f50702b766577704278534a69775346512b4630654753634231384d69637a4c7a393676646a7466434a4f414c6e39337639337741766a6545344f6e7053524d54416f7a33337437655a7347587347445263453963692f63506f6349394a33375852452f78486f7974616472796a48694f352b666e736b6e774d33352f3242386f5a432f37353777512b2f5479387049654868374b732b43467a2b4c3366577a576c35663959685034325662386a722f6a30534777682b4d5468665638506e484d65442f756a656666352f766947716654686338324c4e5947416d466c7750584a392b64383572397474377369564a36446e764d7a662b48392b7a78657a417557726c7470586a44507544367569652b506a3038554b71376a7150746a6b2b41376e363350752b7a536e2f696d59783455507053486d4866394c74322f667075315231375176434f7572322f4c6f683250353778674572777837774149336537714b737662524d4867524137356f63637a686341337662362b706c62454679594944396c696f554f5138634c37494b67444869615042786f4d442b4f4a776b4d3850487a4b397a68516d3241387539303266666a77506c4869382b74344f4b5966767673752f66443939316d4c31756d63642f556833322b564e566e5474656b716a78586a676f4241434536485533722f38382b38687a52636e3865787a5665713837563376432b65315976377a54652f79703962356139316e6f74447674614232746d37315a6f545835685033412f6670533262304d4d566852665867366242642b2f3478346648764c68375767504d48595154583170457a4c7530327067336a6f5475484a6f527a33615478374c6a76474175323379506337357556566655354f76314e6c3854416949727342786e796c70367665716f6f6143787836793954766e35494f32594a34783979764979356258647244764f397a4672316433564e742b763554574b6c6d347137595a446e6e774d6e75712f306137473475506656747465334e564b456f2f646751656e554f527872764a45567a46745a36724a6757722b3036645076496433626839615555712b346e7367644f733845525975616a6d71394175766a78304456593666735868532b564c33474363654341767a38764a4d45346872766e6e7a4f6e33382b49472f4f3532795a737537374f58354a5176686839427564537a6d78456d6a42737650382f58583334543261726c344d4f7434346230594a38775078672b68772b2b676153677156565863426f7a6e2b666d4a5933743665715251344f2f507a2f7469346f647744617a5638526d384832504464636251337259676d47395a695850524842573176645a44476d387132744c767757592f35544644792b437a4d49643248364474626662363245415151736a433658777170684c6a755678367a6b6562312f385943734e61627869483247516e66745751424b6854374e433257394d5759364b6878664351537a55722f324b6b4a4464315656516a646f523256364a3654395251752f7939346b4e44554c777a384c64316e6d54387a50666e786176674d38586b706a396248447773684673544e685a7a4e75526441774836386366766932394259633254426d474343634843766e2f2f4d332b485a3849347165727a6339485879352f4842483733335a38347354533765644a47617236614a687161356572714f67522b6d77566b777732437a2b505a372b37754f46614d4435704a5a72544a39336a685066484945484b4d555437554e6e39645a564e397433416e2b6d4c4734517669627859716d31557437435663674a3561685271773654695055394c374d5764346e7a616966454c4d4c5a346446674362444273555768594368612b58724c6d68305448336d4f386163357733476a64362f74336e624e34785a787866316f35514345303231336c354f54357332464f2b443751573168707a3046377477766e4d4767612f664870386f4d626151464d317166677a6544424d4367594330344d487948745141342b485469463875426d75396677386c4d6e487a734369796d524d464741734c415a7a6d5251343044546d687a70634c735657307a634c45314838735069792f345637346d646f6b50667633387345355066693931676b3341664341474752536d2f356a4f657a7876373639527475434e77487755756654574f567237664a416b4e54413138692b3434667336626a704c564e38666b6b7a464d784166616c6250707733646d68766e4273324e6c34442f785243427a396e6c62613865623669707259472b69796d4173484d64674d45455949644b4a515a614f555464633037716c6c665839392f737a3578755936484936787956495a2b35733362796877464d4c38643477443639686c685141335a775674434f326466332f496d34562b626a625456316679317a444830496161363164385074792f665870364c70454d6f356162577734635a67775444574661685962425150417a54414f656b512b5758396970454467372f466244396d576f396144792b55425650477745414444742b51456764426751766b506f34485376593543344c36374c68512b426f532b4637336b6351353738633135414c4d4c7231362f3533677364797a555846746f4e50397535784856657658724638554c67384579654550694f304c36376649336a43575a446d71536547676f644e674a4d4d61357668312f7577596f2f327a786734615539354b526a5468464a79625150645062784f653734764f6d776f4867504e71484e49674942664b6435436747324673507665563947724243744e67536f4b732b4a367949776753446a4d336433742b567a4e734d59447a626b4d62734b77796a6868666243732b497a5746664d4b625159664649346477306a79427849354c3964357a564f6d796e4755504d39464b78546472366f3772506d5969694a3352396d42563934574a677a5449596a715858735a4538452f4338376d66694f6d3432546e4574724f576f34376a414e49737458446f4d376d6873346b686349596a6a49436d6476633753314c774a6c5038622b67336364424c444c7a697a4d4f52594f417552647270433834595261512b425a4d535a4d357566506e796b6b62392b2b54662f36722f2f4b65384c634d5a7a50554d69556e786e6a61384b3378494c5a4d586534376d664764377767594e68514e6d33576b4e595947412f47576d566f4275594d7a34354e69726e422f65455033642f66702b397a344f474e6a487469764170775a4f34784870676e614f4d71513058367561484738735a627a704d31486234674b4c674f42595861446d7432486536497a434730474f36397a6339797a4e486e4f427a6f57394e3039396f305539365554646265352f314645656e78685a73794e4838484430642b5462375151353773645a695332566c66683071586173624559664259494479517733524d2f446849307947536c4d4e2b6a456d5a754e736638793645786f49714a5178515335567a6f506e374a6679515a636a4d4852414c684776624442466e6f63715853736534594172704931374f444b3872426966616c645a5764336633464370724141692b745149636257744a6151344a2b30674874754a43577667645a4268574d53376b344d5143694845716b704d444c6b48723657766833322f667673742f31364a4e415766494d6b68594d522b346e332f6e386548336d4550346b2f675a767144484a6f642f6f4f76686363336d5655363441786347476e41564a7130524e30624d4e77526c76646e535a325377466c6f4f312f7a7171362f535073773666645a61473245466678302f514331767171306335627741316b7234376f73344d75424e4554336d41644f4a6e65515572776e30435465684430344d53543446506f38464f52466a53544642766534542b413230453335764655322f49582f4868474633343448686a42735373432b48485939414154393742324b43395a354467494c61306276646458496b6950645969474679374854697537457941623079767742584d616e5a6946426a514f3465486a3454677a4c6761682f4955416f57452f4f46755954544449304b614544413754593254633351667071306b48436b5958627757577259615967676f4334614779614c4d41716a3153774d62553374682b654659342f33474b76714c2b6669796b7945415a713865615138716d6f4d6f6273517249616734373737773074366b375561744e487a30777555474c5533726b4e776d6e36633572484c503538416b303070377032314752514277753868776e627641692f774542455a5443472b4d41486e634b536831696b456b387a6447466f7234534569756d6a69675251425467786a6958584175642f75796b4b6b454479385a4c4c57385241707a4d6b71613568503348336539665a6c4d43363833316b434c43524d69554c336a67747158775a6658332f394e51584a506c696664792f65627844515562443947467a33654c774536743179517968674f4e44735347764d6a6e5554516d473441454a6d625961665063346d46676461304c356f69733045544a44674c357a704843674a522b714b51414d6454346a4349656a5570746d305a6e385151753535595343456747413463373477332f61443878624a377374446c746b5a3675446142624b2f3671553934654c67476e425a4947693431394d7a34496b4d534e654b4750452b6d48413846304862383547433231356443377a37394f6c7a646d6a76436f614379634869597447633373455854497244574b614151694237497567564232467a5942584f4d422f7670626e64454f6b765a677a714f57756b56362f65524a682b4a4d694865384e634b59587751724f477a304439516a4e5a475059482b562b2f76503870664b524e524b54504e494d41646a45474f2b7059524a6d764538326c7a4772693332516152793632545343756f35524f6e34546c5673586e67366d424275724352484f6a44545854593763335638523671495869326b307a42794f34447878746641344c446e7a7354332f3645374d4e39747341546f395a493964726251726952554e48743854724e4d54476850386a445a33394d5778307744476870654333666672346b52767a6b4c555254544d3262715333686a46676e4b796849445462626750317738396a505062766f4f564f4846744e50484158774b2b4444575950386d6665354369372b66662f2f6e2f3431684c65424d714e68544632704a66734d4278372b46415638337444354a476157417846545241552f4d3043526b32465a34652f7364424342465133696d696f4f664a37376678536855632b544761306f5a4f4e42375250393873767631447a345033554a4c47776e675338427a396a45694745446a79774966434636396c38515943396156364950386c76556b4277473171374b55454c6f6933376633587332696e4e4954796573776d7731646754676749417133675a6f384d59414e77694e77647a4e4d516332446b32344f6c314d4c5144614169664f352b4f67674a6f43524b316f44556c4c55686768586a645a4e4d504345563530436c6e5656357a5862426d65424d45572b6d3869516d4d4b712f6e474b6d676461794a556d716148327877354455462b6a3658414b614a5464623839562f2f3962665932586744424d717158673777685a4f4133425158472b6f4f7067676d6f2f634f6c70545957575867477a6b342f4978424f6338492b30734251314a30456a427261566543397271417270685552322f325962437a62577277586d67662b4631476b6a46574c4c715478734a576273733141547441533245684457485930636231384d577750372f6e64525a4761494864626b4d663148414d74492f4e4178362b6f6e42696b30324b397269594654664d6a4970582f4e73557a72464d336b524277396f646d66573463454e657a6a50594f775a7958767372684b61746f5a305545634b354f666648794a4c4d327334534e51432b7762696648326a714546654f6f5477675647504d4e59514241516130326f6b51536376767177794539734f4a7a77566f436b4c454f61316c547146526c7a346d3838364a5a494a6d416167314d3534444f793564552f77493567507a34465a51723042335431684d7751424b435977433243496171706468656d54426354333972536d7047507357424e7643624748773375305747417367684d3352466f57423245786633762f6a6a7a2f79337439386f39514d684d48775146584e6b6161646449502b4e47385a574874312b34626771514b476c374b67396c487153456431595a36307465514879535364772f6c6546376641476c4d413834344a637669637544626d42306a344f454c72373853304349794b2f696f532f66417251336850703730304f694c54625259452b7274352f764947674a4375596a366d62416d77546f6d42563873784d354b6c4973715930354d5163776a5962635976662f6a2b687a786e377969497a465577757942543274526e617176583936384532476168653372386a4e586b2f456d57523045533254316f44615a5a6f41516f39677448644969466c38613475626e4f6748774f56574671327573536757516c5644416d32332b61735a426d713356455a5662506867414d4d446f527a575131514d2b383277426b326e7a34586b763048654f57674631466e716f755143722b687277674250626475336655786f4967716d4a5347564a483076587a35343853755079632b4177777571487641783176697661645566594c66593432774d32727178573131524978707a4d63344b6b79474b6b6b6a706c4962376f7733534e394e7273435a47574578526743774d595945374131754138414d4d6b30796665415173674c634a314e30367373494b6373324d38765477674a6d545157794c6f6a68576149514d44523357312b52756449582b576f39516a3278515535777578665a662f55472b4753736179337231345446766e304b61664d514d764a6b764359685974755532793053785a7572486e7a482f37442f2f697473513262524f336f4e736e4556735673534d43475148595437667779366e504b786162497631636152436b4c2b777332766373495374424356634a6a353933386433793339766d4347684b6179684d4777425050677676682f57524d424834457a59646435633879705a512f4c774672364c695453745470336b62594d626e6e4344696b69516265532b79486b6664544a50704333386e527257454358307362517471764a716834704b3934504d4f587a4946536266696735643948527175484169553077534b414e734e435973377748546e4f784f54786f485455526e515762415a5969705a345a6356554672516157412f49415736792b667533662f733362644b733454356e51636b68434f6342344444652f2b6e6a4a7a374c62724f6a6d37426e51767454426c56766141356c42724e73394e6f6351426d71662f376e2f32305336486c54386d3559624469385676314e4f48334c426361695133306238625754625676724c79527438583563433550677962564745796a355649544b346636534d47636d675847714a627867382b6977486c6f47453364333934714c2f4e4e5050365a662f65705876442f754931425445654c6274313978496d4162434b3067465253497473327a6655434830397264536b6a6a5753424578743667385a5277627776753534314538446769552f774f31423945584d2f42665272726a4879334f55767839457657484375427a4d6875304a534a4d3163764e743352675254797463444e7569794d324142492f694f417142505263305279422b4a715969523051652b424e73776a5a4a626b464b42726b7755612b5644346f4a662b5346774c75554a6f6f484f2b4837546b5933594e594d4b3749486a75583536347159444c456464623564396e4161332b6a332f2b7a784e562b3153466d526d4c414f45687a415441784a495a474b6b635234504d3830583677704e6f706f44516249586c324731674d754c68696c4d61707466435a6e2f505a74504a5a5175384939656c634e7458737561797348334d34545769466b456c462b3567434264304e6e59646e67584f714d596f62784b4c434e4e7255796f6934536e3875584f5956776d55306a4f4356364474552b51385254696363624e6c4f6758506850754a67705152396177746a6d66424d63634d49337a2b3845764f494e786e725455456736546d332f707869496a344d56392f7073694130596b413569452f617a2b6463674c374655325545746f586d6b3273357a7237596631357a454c38484668696b78584836337a4e713749427346764f6f452f6c514f336d396f3461636b76475330736868414b446f4a3779504f415a75486d7a48347a37514f4d4353344d577844704430467638674b676e456431656c6579347730666a464f59656d61466f37515254347666377658677469586e7947533746695757534536594875364670693262692b786135514b63697645743954384d6949736c646970617a50775031444c394a2f4b3242354c5939474a6b484359793037536c6f77474e4563444e4e747739387a694371664b6754545a2b5372644963634f4842426f477071594e6449664e6146384666306c315767643968446d39767268556c78334d6957506a366256366f42424b6c67476567357066734c384533777658763739396c6d4f56393048657935716b75544a72665a517a773651554a3632334f6e476a63774e4d773173314f4c6b6a646a756e74563965634433446c4d50646b6c435178574c5a3046303435514c734f757251695847784b7a4373305035675872392b3835544e6c5634357a647a726d2b392b39595a51494f617079384c4e72726c4d72735050454d424f34794269384969564b3632494768635a6a467955356f4a6f522b6c6e51514c4478694572777745434d56336c7748586639544e4f5947463355564b31513758677669574e6837737732525537536643634c6e4a3133764278644f5632304e4b30764c302b63574a6a575170302b5046506472774d38686141684a2b694946435954546a32656530367953357461364a46662f4a4a6f3178644d442f4e776d7a5567636d706946465478766c4e45533649304167763735663248664b38316852723447514862504d2b62797a3767436b5673717a7a5232317346447a417432505359792f7538734a75316372533444345335716356744e3777786a6b63475353734371335641424b39492f654738726139496651487a4538454955486e507135502b44757063497742486e732f332b4a5265356369776a32654431734d38486a4b493359335a727a73686e6a69546138474573483057682b4e4b46462f7a595a31796d434a666469454e356b514a5734587468387147734a4150506f70667451764f756961324b546b77596a4b686c65776a325a53613136366b396171595a543834786d6d68673739694b45526170744547695765527075687071687739517067524b63495549736f366b7143324b684d4a4d79565334334f4a6c4157573969554a54717a6e4e425673715970415174714d5438494177556c765931505170485954624e6f78583569336d2b73746e77732b4475637474446d6d44695a47776369737a52453569324938794179317a6e676f4458632b712f366736357067325761666153637a446f64644f4f4756436b38436a5059634f3443796c735534337a5251426b69314e53587a73694a78594b4a377331376c6a626d37706461436d394257596363426a69587977342b6343506b585368476b615532317a365179426733484d6e77494a4939544a486d686f524239334146737a4d4c347777382f4d4370787851306e502f774d5532627372786b366b4f4d756871525a44556f4564384535502f487671315562676e5068763645466a4458685a66384d677451307177676b316b53747863385751477634776755533244676d436c6f54436a7863462b336c79504a416f637a504165704c306f593842356c786161615232482f4a6e38464e73556d683655445866706652613567374d4169775754463261424338623364314578737650304d49676a6a754f356f6e6b77524d4549432f42593343564243304c534355714e6142414f4b2b75416143477869627a56624d444b656e4d45366b762b7267325a656f486f59706138544e72677472416e39336f41614434474e545176746a624a68504a506f4a756267634332742f43556a6546424954386c503448514d52334f6369735a7a774c44684171516c5535702b78327a41674f4d2b49656c716b58494931674d39504555466855616155436b68716251514e59314d6b7a58456f544e4d6c3378333359426f692f43745830726845797369386370796e68525a734b5254346e6630794335474a657a434e4e734857314b3651635258506e4b6865465368476f4f696d2b46463449626f6d624a426d38694f7770462f2f356a656b4b4930524c446d43785074426f334755664233504b355066302f53596b59726e7457447361506f46653652594f2f50465a6a7033464b5845426c6c473361416231625641637338446854625359793736774e2f6b4d73695677622f68526a416e6247594c6f76332f35582f2b70386b5462476539693353465338464146346150677346666e50397a676a503848697a5768787a563249476d354b637746576b6d39757442366c443154584b6867454e384f65656d3662544355394b556e4b57416b44484b6a427241532f434d58485368435a52444475465a30363834785361526e7a4a587971526b4c686b756a6b336a757235554e385848672b4441664970313058494472734f30326a316f4937666e4b4e5561426159563977595037563347313536792b5459306768666f7a30545961785746494f4e41656e52456861414947326644754b686849373155685444627a317778576a75575449633558464f784745705751374d4938314f61445a734139345a514f3168796b4d5a3532383773437842447561625454425576517267417531746f6d454f6730505156717543787879346f4f7847446a6149414a59355878525a7a4a396431554737574559306c68725a5973453277484451494a61514c3934705569334d4253313163716f6d59676b347a4d625569334776327a655a6f636f35475a7968433567364341743437697974373862394e657450374a2f4b537068676e79754775722b3449486e6f7a514b696b6e61544648724e5a7577734d726f734358792b7963357779327a30314768636c62795a516e5445327a446b6975385068554f673356545a3535704656334a534a715072706449374e4e564f4c7649697571714b47437531716b2b323159554675314442656574556c4f4350437a516e516d6f70684864424b792b2b594639797669516f67764b636e6a666d616137335057514d4372775374633944577a556c334b675536787058714347556635554376497a5475493757414634514b5a6d494a596b4a53326d422f786a384a696b3755556d4e786549666777384d50594253425363324f4871494c664347727271792f6f68756f66414f7145715357575879624d4f4e65754b657269456d6a686859456462652f63454845707a71454c35614934646a6630794c4e7458586937417530784f4b4c3464466e764f61615642686753336750306b645947464e772f4d4c756e396d6b796f75364167725049344a6378336d756f366f4a2f386163584e2f63305a63716d5953654f354d4f6339504f776a6135456972384e566368392b4566466773433878796d554f75514931477362366f4c386a395145486f57303753494f6c6b73752b5a3461564841415575794b45395a3838726b51396a574f5256306e792b2f4b6a4356535a4a65733970712b565453426e444d72756d554c35486e4e436c626a304851787470636c6a7a57704572716344376834786967314f3652304e685a727150364762763136766f6d69517375674e4f5548576d4556666d63474a2b374549516d2f4a6b7a773362765667704c614e346d56446d54734a574b525a556f586644426d4c645456544d353374734e7a53666d597870564c336c6936666c414146554d69375a777a5344494c6a51777443497764417768764934357a4e666541655557754e7152797a366b7237372b68686f514c334866326f4b6c4c626c664a6555456a6a754232566e6a32302b6f497170587a4630526b384b3859353677635748435556454449617270507653696e5466532b697244467731622f746d4679576249434b6a665a454f4d633873454174525658564a632b484b30572f33762f2f6c2f6e666f464b476e536c35315455475571703034693073484f49574336414643705162435934574f5a35566c48716d65313368614f4552357569735172564431414d552b636864533849544d68525a38396c2b6a4476687a6f493459666e4e5475466f36334e6162394b57555a7071497835722b505a62633552515368325956574d6c3347506f68707833674f6c34325a5a69544247496f5a6c456c614a3964464570316e744431786762746771374a774f496f5975446e43424a6b6d6254345a724174417a6c565846327251506a41326b774f647a485a714459774943465154365362336b7541636e6f37303564716d6b726c4d306f6f51754f65636e6269376b2f6c6a4170365631496c5562577767593447706b70574146614c7341446259594b4a41734a2f47534c4d6f7430656e473473526d4242744e38786b76746a37583334685938415544394241554c6b38424d346b43736c4b5545453474593673716d524e30576556656b744e5950747372534d687376416469785a51437567736d7a344f70534c4744697032585a74563875656374366f726d62632b324a4234635846433035785a6548414d32737046555272535638477764446f49417166716c31506b4171482b3554396951667659625059335955726b784d72486735413935764541694c53446a383857476b75774c575965667a616655525674666a38322f4c5a71434e54616d76525a6741426c37434f6833516275686b705361434f737957717a4375696c70635074776d4e70484a584a49375855386e3750544f47306a5462643858416d6249514e636f3643454a686b614464533143736c374a6d3448355355542f464d72584a62462f6f65645657484c364b645a52546550676e784c54694354432f634a356466395245394e574c644a37455a6d33496a395776344d6c6d74584e636c73766369365a6b6861682f4f484866397a6f3778706a41514c706552312b42592b373445425363794b3063754d50776c613177446e56566f6762715a6930626c6d2b564e42437a7435575847334e714f524563496d4e67665474576f4f387571363072316a41744a6437756d4d4357676b66455a5041507051476a79455a6f6431754151306641517246736d75564d712f757667545145634c76732f70776a70425a73496f7247574645394b516a3730453675566b515742674e566859735771554175434d314a4849364c724b5677567a66635a744f61496872574f3254335a4b46304679304571464d3078637044497637724b665a7a785069514d45526e417a394575323854334a6e4352687447556e58583353494145677951476636776d4862666a42414a6435694a5644523157377859377949596363433033797a426d777a4c34383746515577447547616c6668334e6f686972523966677346336837465535737a2b694c3055784551416a705654726530732b42396f4451592f7751756a375163444a45392f7653526d6e673737734668464958645074456b71504d7a544571675a455332775a70542f575552327075584674497561692b46505257734d5551556177434355453732417a48594f44326b627243654e6a45704a754257776d45695a6e5a643178334e4e6d69484e6438377a6b713346314530557a4b4a41412f673544413938494752433043716e4c594c4f5546594863576a7678386f4d4c49723676704837614557793455496e516f576e565a693255542b767a30554e6f73734f4b38446b316a7647565a64574b51545a4e33354d3435524563613779536f774455707a656643676d69516b397475533968723957373277544b5874325361506a77384d735256676573712f4b75472f516e734a2f5868413245704e6f48626b456b52714830644a7464596c667447394e774574396e6350535433637343316c4c4e637a5837594f4c4d372b6b676241613165316a6869726c544274436c35564e423073436b65737a6b64694b496643522f596d53336a4f506538683331494333514b6a664d6370574f6e49426361634e5a63706f4a704f63335468524d766a567052477946314d3431394563426c5053627541645943376b746841504363426654543530397955584a75455778537a417561667a796a6b55692b4e755a316d334f4c5148704230656d6a4d636b495a54476748346349695855455436326a44314e514843334e614f39514847766d76434b714d7a2f64434443304533594e754478512f3977356c617052794431435367476d69765a617a6e49584f3851305930556370784c74594f656f3238315569684f63596b486f6a3751462f4b58376e4e3233412b39493169626542625375494e6b773468793575416a76787a43377a475969497232364b734b4b75586e3337723734666a416653462b3866764e4f666c383278613965335166754d334a7873564770776475475067744d6a50456d435a4c49696e56456570667a5344384a39424d786447384567454a627375784f6a424f32496b4b79656933776c4c57463950734f764d647146635558774b5547646c7668764b335771375173706d30435755636b2f546c765a497a664c46576c676d70397a304a32654437775a38774c424a6e7444314b7767565036676d3243494d72502b504c384a42384c43344c534c3550516c6e6b795253766e5973616f7363496b59484b51746e464e6f51577262645756526b30774d4445376b646d69475273314249687130777873757049616e376d37466677776a46503048564355367168506a4e415856624f7357723476446373365348563767632f6b756b64477173647a675446366f764f42576f6647554952304b756b6373547a3635436f6c4e6a5a425a4a7746434b3744532b54494848304a706a68536548464e384a5441657a4a755a36362f71634455516f364577363953634a50696561386f41444256324279373750796a726f2f6f504f634572734b732f51717672512b73447237554b4f4c69656a575838646c793347544e7444654669664f744947772f4b4d446162612b6c3262504a584739572f426c724469453857734f447454473264414867587541616f7744534a42704a31697077334d31374b6773514767337044744f434f7a70324739703341575443583744626a4975684d776e554d6149742b436d49584c423751466f4475513061434a584245754a4c7554655474506e65487a39394c497743436a73304348436b665033506e33395276677537766c6d586e674c3276533768704c736c443373524d4f4b7171536e68417a464943647a47666c554b584f735555524d46506272717a586e434e5a5842547a3939547764614f2f5178612b314833686650354379475373796d52633269366861686c64324773577372387265794f30385130383633357679527253574a2b4d4d3979786f613177534f78654b4a6f2f686d6f6a4a72377244355450734777632f727556367479775977424f4a476368423635417142355945455753557a655164324678516c366b53455941707a56316f72734731562f6e6665744f692f355a34504c5038695135432b544d744657486166636571456e6e346a4c4d50416f694d6b2b302f475968776c4962794673347946522b5331436476754256486e6d5436694e5147486f6e7963696c42446750472b4b6e6230496372306d2f41643846434143574457536d5345794b5771696e6c6a4b42346d6642574a63695a4d77327953627738666252796a65474a753649467343755948694c516a4d48486975354b764a46736936444f475070774f6767433469485949737979555770695a384c78456878324c36436f676d2f5268457245516546704e31447553784a46574536657454323447516b6662484c564b62734d4e41724e7854724b7a6a5654773445673453414a63366339786a5874424471477459445653394d4c796d69486435796f6a6a496d75414d4463746947653156625535425656366c696e517350467a6f4b6d30515172346750337568334834722f306d4b52754a74335a66474c77554c4e65534b6e6256647a6e7774514d42766a3530796471503741707a7a536259346b4b58654b75666c4c363351587146365a7766633347634a637a416f63757a473862346243792b63675148414f4e74312f4761445750416d56502b4c344f514c5474526470446530733849775158594f46682f787a50636b4d6677735248737a7575737a4f4c6532785965376c6e356b4539516166534d744b4c366172757a61493145796c4954446b647952704e4b34486f4c385443524e315236366445736d4a645a617577766d554f45663835744c2f304b6f5a5274637a45664b646769346b4363346e2b46616a42685041796b4d6957357548784956707a4869676b597a527632374563663839374d7444695271796a702b76636a6747716132513075696f7344584b30704b53454e316e535a516137704b34715179476d53577631555652354b5a3332344564736f383750455a4b6462414e78396f31775466676835484f4672794749346b6e387142424d49726f42467944426d634966676643746774494473746f77756c685579656e4a2b4673343874326652614e4435424f62534d4e67305a36433373494b626f437934574e325a4d49714f71583254574a56754b355271592b4b37583949494d7a6a77587646685a2b6230554a51314f3770466674492b472b4564514b2b45514f6b4b736c6c35307374784b66777a787a35376b39482b6c2f5734487a664e4e43633934514368497552595a45313254344c53633132417a644a2f553552487661676273714f67717552372b6c7a6276546e6e33384f69732b577a464d4b316b6b6f4f3637336d48314c437645515565314651444e64456c6732724b306d73696d7132366242494b5964517856584b4c66586249536f737739446d30316e33684650444f6476696d396d37455268756c675268514d656261454273474568684e514c367a4848433545576b724e59334f31477a565042646f537635304c565a334c4438763162505a4278713849366a59336966787434765378774b394e6435497857785645476452636179455770384c756d694a356476615253396b51687249507443644d3354584f466a376c6c545844694851436f794752636d47674a324f62756e6e4d75476a54726c67737355586a34613358476762384a5451464e636b742f72694c4f68446c34494f2b2f6f576e4331795953334242616146636b2f686d455a424f376639375466364d6d612b70794c33547867616c466c735535543574454f2b343153385371306d5a383161724b76667248662f7a4853636e58475864795a496946753472715a2b37304f675833614d316b73417378657349504e38554d756e544a4741794c42697252537279346663414c62505956706739494f2b6771776b536d387637644e6e41584f4d674268304437504c4d58364d444b476e5a33447642783367697245746d7976304330594154623868494e35637941614f6866716c7379684971556e36546d6347506b413055446e686a70315a4749466850683867566c784d3148794d6469616473567a622f63437a664372636b6962534b4c41564233773652367a39626d72374b477537446670337770434d46717453364d5650782b7550536c4767684f4e484a2b6a4c346e4c546a4c744b4b65384e4b7241426a6153326d664964676564664668595245772f362f765835644e775634582b6270585a4a75735757534c6c336868412b38724f5a4870787469423972634b7a39754341626d4b7857513143344c51386f45344451614f6a72716b535652586e456a34454d6941473154314e52574a4a476f6b6c3838585538554b6175785943523134543079395248394e7430733852686e384d696c4e4d7871674a514945677163423742703357786244736c41306138307a696f656a337742367166373430302f5a7562326d4b752b6f6a645457365870335735676570434c486a6f635061496f757973664d6c4c44416d4a3368435058746d37656b6e73414d506e7a2b56466f3034626e633168494378384c53504c61625733505a5664354f6b3371652b35717949434c5742754a67516835394c6a6a7930556344656439717249692b517969744d54392f2b6f7841506d75576873494d7a586c7a7334764778536c392f645858685662744a6e75514263784c6d6e726c454c4d31776670766f33696b627571794f526b55494a6a3577782f2b4d474677787064632b32614a4e624e547844496e4c7a64464141744e6f767179394d75764b6c516e4a6f2f73434f627171714c6d4c784646547545586d4e7474656f31513653464f5339687a5576455a395444584b52616e614870504c43777671685a4c324a67707378536374676e685331464173615657494555453266354233574e5958776966364c4350484e32716e4a77686d76534b44414f566d6a30713151566d35766e305a2b784c4e664c564c74367a5059466258357570414c4d686b484962674c4e796e6b4d3035684376545273556944704d6e316b6978716e454e705835736e4e3943516f5374666567644937584276574674453445686b64757a504e4a476731437364334d575247384633336e4d542b2f2b63327647556d6341684257354834526c616c4a616b7838504e486e7170324b7353396949634943514174354d43542f4264335776704f6466514f54586b69624834586436764c6d2f4349573668674a59416a514e527868306d69504b76784d565846383866715538537a32346f71477545316f497a4976416c42386968366f466d377971773548716e6b384e4149473970474862374c6552446e544655324b36786f4c6f524858344856666d4e68574a553556386f5871415a726f63373145493163335648486178787455383971574d72564c30495664764945355777656478707370565371435a627567304e4c53726a76327048492b3150344f6f2f5a474b527636546a672b5a5a7854636c356642305555434b426d6244736c59424f43594479717157616967494f654e6e6f3851504e57553157695861337a536f6938335956657a42425543436166462b4f45384e4c6353454f744370663863686b433947793579387778386f544f7a55576976447843625465357749534b5a6946777a347745706b45366761584c6859426641573346336c4b4255384555487979636763516a5972706c7832477a4e53594b4b3842517741765764437a5876377168634c447879456b354c7953515165346a7753397068374e7a634e59366c313475417377436d4a37345061434b64597754516a73475155362b33546f454a6671327576315470477a596279476936463230336f546d417a69356a6277722b6c6656645655324d4a5032655236794c3849787735514f5930545267534757476f4967484449795a474572465366485357465943516444395249304c33776e705a2b517856415849644f737a786e34524342672f746237442b394c6a314e45376c3045546b4e594869714f444d3230546b57495a4e2b5878716f514e4654614941487233323159586e536763446d56595331686a574556372f7755564b504e6b5a4b6b6c5a2b544133637a666a6d4562596d6f2f44732b484879754b4a673168674c62666f37386c55375461416f67615a36382b342f695a576145424c38726d68642b466f52705138425070675771506c563131465465464c596f656541384547466277464437574972595468777272752b4f684b627a62745a4b64714e686e44575148574e475a4b7374735356444a76436c38765a57314d7a4d5135366257706f614a74454d556a766a5448555267686d2b4944316d5943684e4639466c4e745647484c56684c47416f344a794b7152704330425273554b46526d416f4e69455a30556a72524a6676326a6f6c386179336644314e75634a7a756a78714c48614b4d61565041546b67326f68567a666479316a524e5644517a46535739427558656e2f7067715139664f634d4e594c417a704e3832596258584f63393363733738415472613633736d7655502f305475566e7457725a7a76525831715558466f514131534a6f6d344f4a464c517831796f324a4d734a3034466d555a635a41596949797579766f58594f59355067547951456d746a472b313164383265446f456f4664585273662f6e6c41384e714c41536575313077587430585851464759694c6550647376314e524b675343434c515548534747427267796f4a75722b614d725a6247536a346f596f6642552f7134354472494352716a6344467671596664382b2b6b6467334e5977634f4376646e70324343707248676c56344443414a784546733675416c424349416166414639462b633470556c4e6b75324353373354665543416736364b666c64595667332b55384d797751655737687137637a6c5156706c5a6e563446795151632b53503677626c6d366250754f2b566d614a4f736c706a53444a6c676263724b354c3267647148673533486441427739337a4f55304c70393968725a7a765537522b644f51586661534753316c5168664f72744777573474643152486667692b6d6b4c70323534386239536854765358564264416757677a6855717554424e622f2b2b71746f73727374564743385a3237454b787a7330596832666f2f4c3643316b4d6c654a6d67494c5244506271564561626e627556616d4d54574c6f4a305842527839774236507a53764f496a574833785831665966345174533154633352506b6f42594855637a73582b376863454d6a794e625639377832587963432b4358332f7a6d4e7a4f764b7767426f6a3731624a4a4c6a5138594f6137564f69793362774331446657374444557832664444554752366c794d5974644a756d476a4762745070434450786e77356c4f79633535796f594e5637447a2b69787749526c2f697a384877794d4b654a522f52333636454e65476e386845597830437961356b7472754b524272567232347a4234762b43744c6f5852754550344f2b37754463734a73773472656c427a564d2f4f6c594433306737686e69494a5274554e3076784b512f4e585876364a514b5647734250536165543968594b495137596f51475175614932575a364e4b545969567a68314165706865674d54736c456e5374715857473450676a2f625a686d38332b43367a77456f64494b637567456a6f343862694779494e745644433146446a36754a4e636c65504a6c6b46704b3768454654706b54634b6a536e464c6d67392f6b6856513733656b314741474c51637145736e50702b686b46386837436f704a7831354858707935567139543549426d47594d756669774a3036706b306b58666d414b39627773306b64496c374842626475426d45566e32343169793839556733727731703361456f74556e394d6b4b7334793077724937332f4937586d35696d7959644b6b4177734f6c4365456669637144586f6f6e594b71702b5a425a6c4f735a75444532673076625675696b437a435971676236546b30584e5561566c68783466762f4a54787376557a462f2b714a7652415174726f7149615552667559626f317432476c356d73514c67524c7950636862577563444335444b644b6f71394a44613132746f3769697055384776354674313675577a723674692f4b4a6379563471516f506e4b384a6a497a7264526c496e7a456c617375633467737a443464412b75484f49506659766e6e7a4c7567704858656b512b4b5a4c7079535432506757586568436c3371524165525769482f6a526e2b6872545963525264647875436b7049306c67525031337237646b334865646b6e584d55634c6630342b6c5842444c6863616b34692f414c346261646a394538586b796d357061584e67744d6735744d6658783470534b6f3255514e2b4d464f4a662b48396f504d63586e67643139534e45544661323749676f61364c547a694e37694832777577416b3966747175427872684c437a2b2f65765330344841445a4b6e77767a6c66624d637046456351322b74397a6a6e477544396759473548317a70646a4f4e6d7034456958304e54647050416663454864316c396b4b4d512f6b77614450325a756c6971616f6e4564364d68722b497878554368705342573147444d7250416452357847646f316359553273337432535a64717575414e4934394b703162344c566f6f4a5769795177554255376b55792b366c69526a495539486835546b3850555858614d6a7746553476322f665067594b6e364f4e48564130785264576b374a6459627769585a584f7a6271776f4e43453531492f65674b5a6d596e563179776c6947386734527a6c4b625275366c64764841713454797258624c5479716233374573666956706f6845315479496f2b4f67546a67564d4b302b704b623338356e7a6f353856757252344c34616a58425439424c6d4451505433475a454d65315732715048652f4a5474535643684b4f432b66642f696c654b6758725376496247736d526e387578544a4230516c7052614979376c6a5768623156565152564b685975466c314e75704774584b6c44462f7a79504d416949616d72634d7743703631636c416f6541776e6c484a417a30766d3255566d49374a552f414b63727137534f4a4c335369763449536458777052336a4e33393251304259714d6438417839656964344d4c49644b66325752304b4a48443342524d5a4d314f4a552f4d6f754e42414670435a64647a6177554b69507549417064534b4c306c4f4f6b36503845597762317135684d6c594849426e6d4b4d52785143424f5031464943654e574956494769716846586875564474624c394e6253716630736563322f7674622f2b53476f665037644e675563427831496d76624861325752574e36595175674635773544482b7a3945364737335338526e2b4c6b65713373526b545051367a6754486a78423862744730583063466233665334754e4a357532386c2f6b786a57596135764f786c7930323266502b396233596f6f4e363249504a67496131567a6337776953495a724875547332393541304165744c4e39593674796664486455573876726f56664c4d5772516b35524c4a58567047372f492f2f38652b2f39564566544c6a474147514b61344b4138434775647149582b3967534f4946494f374478366d477651346a433735477a507839514a444f6e68555671344a4664384851674a716f3957474762763674706d646f3775366d5a6f70314c385a33455534724473776366344e5370336d32426f3047682f4c2f2f312f2b645872322b4639326d552f2f78756f433561324a56724a564c4b666d517a3675414e2b433341566856333464544353706579417a4955454b474461716f356e612f4262554b55492b465a554c36454f634249676a417767482b654a4e7a69443771726d6e6234677241526642476f6b4f4f6971424c6b414f334d6d4644394d6d36634c4f49466a4d6655364d313065464b6d394c4e6832532b745451567a42624e576150306a5a7533635a35576f7565346967646f2f2b32644b726a59777830626368415267554c597a3145354e584d6161645761332f337562373874682f69456b2b7679635077627a7155504d4a71433365693848776875374d654173484f634436353276303073654e63354757306b2f4569654f6a43595435382f787a6b38636a357632425650314267313961726f6c327933346c4f37757067704a2f6f2b445156543648525463707a69707a396b6f5872463931313655594a6f506c7755573155463547304e4d416170384d4b4b336d506b5232654b6a525a49784d6542745871366e6b3031544c5131766a35375876683764584b50563979487a545843515665576f593935566e4a5a6a4e534b3273464d4463377271495331436d2b506858636c62334f69774c446a34436849774361395a77644339534d6470376c624976784733494f6c5a6d53546a41585347614d67324a43534b726c6b5a566934764a6f6a586a41316147716e6b5a6170645554474e415536386b55667161717453686b35612b554d4b3053306852304c37775971334e33647a507145366957644e55334a7032644e556332443363445372725551587474724a3234333761625547304c3672536e5072497135694a614d53424f6e5479485257756e51627053504c35467767714b4967716a317576444a6849575a554567634a73365a54704638486963317973437a4371655a75395049764b346a4f5a2b31796b70556e596c6f2f6235516a357a654d69684c2f7a4576426a41766c726674566345452b6733753535507634594d71627a69514c5474464555645864515679594d4b356177724e6d584f564a44674434596f73674e50634259685562375178714651637772517a6b744c44564a4c4f4b614c67676e6d31366d6b2f78444739506f3953324f54452b5554673435356b2b4d4b6d5946425336524342326e694970486f6f644a555559617354307479562b514c6e4b41484467794d396358597a6a675656427569794d44435a4154526b4c656674525858485532424e334b326c432f4f556c685572615a7143433339516f375951616d712b73772b7172457075457a34443771487162634a314a566d4b4230636c3069464d6e703358565751576d6d43384f6b6671306e3376655073634d493341777141567345734e736143332f4c49683278413169537741445636626f4254714d34344250756c446e4c41466e77344c6a766f2b5247366e4f494d515552752b6f774d666e7168724f6a627a78396a77764f7a3363447945477a486e6468334555427456555459484c504167726c6e5669426476784435564b5330723154485149644a714b4c4d48315279414b5a4238494f334b326334304b2f7a4e35457365552b4f7564367977375857512b43724b6c5a7a674e6633566957714d5978385243425a4b704430373669442f446178753261376c517a584e7468776d446c4152416f47427545365244544b476f5a674f30484c497a3236567a48596537784b6f6668574f4d554c306a5a483870692b49757a654c38526150487a734e564674316e70766f3838425067662b6e7a6a586932474f6b7637782f587a416f2b46492b6e514b4f4c5949485a5376364950684a4b37576b4644643852702f6f425132463534446641634456354d444344494666746847523734566e4674574d745066546e7055375135777768756a5a4e51686f56324333777a7772437a2f65692b6642763547437572705357794c554e4f445a756a4559717742616d37485558464b4c59563562735278453868694c706762384176425979754663544b38507a344a504236334a66683534696948713851354d49616a506768713843684d79645861756f743255677835395172715a4349697337477577713343537633595654464944706f345532556b6c582b4d2b617a6a3455307a324f6c6c7466684848746d64765645657764516a354f6a6f7a753951646b2b5144454e7a577942783361366c5a794770695746346346624375465647567050496c506d64753031697941646951474f4d793451356e466c55313772546a566f375162436b49654667456e2f2f6a316f716b784c42665242563946654c416746716f4f625159316f534e37336f646649356d4b736a6c5175425962594f47642b6a484142384c49505336492b61464b424e7a696c53526d53576c737271757974783454566b55676330512f6269455836355659623152326f62564f6b487549794e6d7377327465313269374f62762f2f373333374978786c6d4341596c336b51504278326e677775467663416778534c5139464752775a6b364e68774f733144485a6b527435574142655632336857676e3036794f687646556d5054684d4c54503636394c66485067544d625a77684c4844616b522f516458463773584333742f727242326f476152397575694c365932775a4867692f514a2f4750366179386d4d51336c4275664f44344c67385168686146466f4e43585451632f424d366c5861714c3935334c3832527972714a574869426770765862686a7a7a77684938366669545a4159494667306359496f4c596f454757397567357a5175574d54726458746377706f415a536c746572344b694a656b544c78766363324245626c636e72375066633565674f755556467077645658625861374d5748796f4946614148774565664e744a30495a4470575a6230514b5143463258366b69314177615061507834646455476e436e6b2b6a4d4d486633504f4b32584f66754e55576e3853375530446a525130797a75714c3450593244756342454736697653456269357831674f594c366138484876754b42375735734639464836365a3259752b336e666666312b69753247596532755a6e57434e5a65616f49706570374672375536654c6d6f774e6936494c6173564943467462586b574c38546236584c6a66717338686f76447750454e7058624176365335455a6d415835454a334f46786963573633704e5a4876553759656e67536a536545315653564f7170344f4f6558766c516a565834664f57374e46316b55746b587175704a494e76586d474f56666d704f42775151676f797565584647784771707032314a707a564e746b635935524945727355757861566d68666d6166643055684474586e77795631504a716a47367438445070776e6d6b662b50744c30494c5030645948484236543377414149766c4c72436d6c306c4a6f47495a532b5041682b7a4f373643565044634663586a5a58656366337364444b34555562375748756c417a2f63682f4a556c427044486f366e4d62442b6e6c385844426f49673549326d6a45686e49714e43555a5137316673367368544b56714a5058734f67524b5454394f356242506646594675367667654f325354712f496b783843786277665450686d7039615045516e6252357159324e327079706e30346a5639474e4b524a3058553234325377543473536443476a6e676a7879747270314f344a7865304f37693934394739447361633936555048613746784249303861324d44676a584f354e736f47596a6952754d7a555951515859626a6d6d4b484f59556459357055733459633966613661756a695151694453734a55576b7544494f564d4832536c4a34766e47794465466478687247694b2f584932764d67636848483241634c5953713079755579352b2f674f4c597448586b497978425258682f316654423772453273314d6149366143772b2b344b7339334f4a386b62623350456878657576637a6230646e75786674615266386e3579395244494c64363950643155707855366845324a55363348784e515945475063594a615067337a4e34366d6e4434484554344974657271394c666772307038706a6371586875615a44492b49417052774548316769436a45676357683361413545686e7a74766a487173793646544d495830643465614c67574d784736587453333761653270496146786e694e7952426c62546362445a64465856413738736f436d71643165632b4961716e6832506d634a34436b444f466961746775665679544c31716b4e5244506d55434569673233474a4d315a3948505a2b596f4f7036426f394d555a683870392f50674c426573386e614e6238704852784735782b71664c353774594d4a382b78534b4c426458474c59524931345641526c3841743256307333303533747553687a514e714d416f5562334434414f4d6a4b4d347246576b704f5441742b57454d6d6965373737374579645654767063746f35464147694d6539336d6f4750596f326c4a4b6872667a643134464d77343042395673554844354b7a6847317750676f7a6e466e79685254342f797a5668535269504a396c475934386e415a59674270344f55594236586469694b555832494173797949716c4851465a4477325264545435554658346b5759536c633845574466724941394742565576424233704a48644762696f5274733845754f654453553276676c6c4675386a6a49515435372f3775373735565077586c3939716f773166796379796d30414f3148325a6e6279625a43616b6c35625674524c4770356f623037427254714c6a424c4d4f53704955504232686a74537246456f5133324c30334f74384530785137755935614f4a5a534d554a7861646c51634b655a46365954715867515a4b656941783230325266367331737947535733582b652b3578366e44394730622f5953506476686478305a4c6536544f777261436b417233675a31352b7271716e53656358387766596b56697441647a2f4432375a76302f756633456f676f4846486c637a624c784f703034686a4c773942384e756a4a4c4e4c497150647a4246515147506934487a3938354746534f6c666e68527548633944334a58336a4449434b61427431477a7771325734755752337346624961737641694d4e4f4255684c476d6b4477413556533831642f39566666716f4f4b544b45615873796c3663754b47584f312f57384c6d687a675855514d682b686c5a55306f367641597252365a4a473762306d335a692b5244723732515444377634366a6357696b4f45516e563466635358515a6863756b4578384f333358796136637a4e4172396f58614154503476614f4659464c6565354e78453061434b62736f6c6335574b4e362f7a684d6d33437736584151386678625a56614a596b6e4a59454637414268784176673876725054444863433054616345477745562f64335165324e7a64676332564d477a336e6e627531513936426b564b6c4568566a4d2b764d6f4830416f746f415632674a48707650522b664e6c55366a2b744747746e667a6b43466f547970797255734847394a7773496e694b426b795933373375393939793455427268495547752f596d556173427763773649674d442b79643767517146794d65557170396f346336484b4a794a5a554d76484e73426c3768517a3046616a76533378716a437269544178344f7142423170564653505a2f73577058737763775473374f7173775a566a47707a7669795077766a61364236445865367a736355366251502f7151734d343561574f7333686464726e5854704d326446392b546b39483753495666682f6d413945574959797a4761464c367446525175686e2f6c6f5349644132376b47346379534e7957316a396e3841616c76476e583559653165565a65476444783434585149762f6a4d6a547a30665a794842435a474678444a50767a48492b63516d673056355470703438786d4b4e616b4d4875694e6c305836414661302f4454464d36363645523961477a424a37563551454e2f4b57697267612b6c5a74494f6e382b664d632f625356437063584869315468576d456868656b36704950644d4f434e49434751583733645a2b6a43714d7a5037624530714879764867415461724478694b75624c57674d2b463753436653727a79335363794850784266456539494d696f426f5a6849466863795343366a6c7139444d61425058395a6471754a5a6949797570442b75502f38332f476874716d65395468525462423348756b756c6a374630437474474a467033385433593374773370784654673144487955696442474276703978726e5341634a657a756667677a30585267562b786d49447346624c704b476b6a2f433352374d2b737742392b506d4839436e377832617677744548693969516a38467157416f4174696679726c4c4969425141724a62756b2b474a762f6d62762f6e57685a5a4c6f746b6d4f72514a3246542b795356465338633478514c6268416e466e6f497532394c486742427477423150305a4b4b714b63495a536f524f7859306e4f384a704e2b61525832583272493756327331573650414a68317972544c3250626c4662735268574d4f6d31562b73584c617043414c664d4537465a4a6c46692f4841535a3043545564454b4347726b772b52776a6a59786d664d62734b72622b6966724150435549656f4b667855416245476256303843676365666f2f4a67517a3144306636624c766f6c72694b664b64777259394b55694f68546a78775a44523565486e6b385849346836696c56705051326f654664756d4378514c576268654578784d626b447a524e324b31447039623752523832414a6368715a5278546d6a39476b2b5042375859424257563658596f354876335a614466667a5162744d7a54616e735869775779477056565a555733557573694a5158467734416d33466c44355457434761682b70686a78364a386e546d70537232346474456e697659636a6e4a4b7056523948373269744f7356444f69395a32705a306a676957734d59594b4b557a746b73614d566a4d652b75794c4657526e6442562b66343141733357494e6d382f4f75756831544a50416a7a584679613442316d2f327a6c782f542b75354e416c4b42306a5a6f6b43745758362f4c6769776231586c63414639464c68796f5758536d304d432b43766a4d3237633335636937586237653534382f6379375a474f5354446e39336f7a70516b5944674e35463046784c65702b7337745952303453794b4d715a615164417a6a37735431307a777853556e786a387a634246584c50755a4b77486664437677624d7a4f494173443562464a6d316f4d566866544d4a634c4838755471644d66396f49492b7148734c4b686a534851564961377a61445a66636e377a357847654e75705636547764516c5a454c516952495543414852443649706b4c3454447568496c447a68436e5936486147446b75382b6f424e35426b466d666b5445484e72554e6c70306b4641573051374e7833314b613835707a3336664d6e6e62674f5838366d446236662f4d64644c455256327666416d5659615938586e457972394b6633786a2f2b462f7161794430694e4e4e6e502b692f3538322f53316330726e634b78326a447147734c48633551346130333572417a396d574d39524b416a576a435375526754535a47564247694c637842377458426b4f774a616b7062775473384441395434544c357456534a3161326a31496c3146487766316259434b644f2f347068454d7778776f636f785255776c4c41423971546330386350326b735858654e38385947766f4973687279394672374963794c4d633153682b666670666d6b557430594f397246412b344537424e4a326273413643327168362f6e416c466f41765876374e51706d4652637479714d633236514a387a582f2b36373739516a4944516e4241712b4148624f7a396b6e5567666c4b436149546e4945514a6e6a4773693459482f31364c76754b4f6434696a36695765586a617869723950585858786567316d6b5652616e716a71507758655137434244674f6d73372b78302b7378464c6450336d76302f442b52674f72637751786f4a634b6f5148383841466d7162413236617977336d65554852726472326d30314932362b714d72414c6539386835316e5830365a4b67676232673872324b517356436c67435078346932715755426430516d786536486d77704c434855497151572b2f364257426b782b643867337667353863315541587650516d674264482f4238662f6a4450302f797261497050534f44484e4a75646f7377466b44664335316f5243666d344a534f4b534763597a6a625378616c53482f4830725041506f3959454d6479736b50704278445247626c4f41646861364f6c7352324d322b3352306f6b6c503651716a41636739484d38324847476670327966715a534578637658635745733375636d63445970546d6d5a633655532b6b394a356677315133593478644f437547642f4470397a6c4f6b76743848457979304d3241673367394e6f31453853594c42786331614a324259304253714a494a526f662b414b494a5a387858456b39704f526e455a3348666864376f774d72642f4673357a594e5645395a326b314c6a36745671334b557a58335163584772634c3368556265425567722b5568787a72625351756a4f534e6e41507a417062756f3144505070574856785a7355485970347154495978724f58754a616f646932745156597430565362426349554b49305876485966684333543765443762415578393049726472306e636e2f6c45556b64507a687a6756586a656c656a496668392b682b706a5a786777576374547a74677a495877677034424d6e586b4a76457748636172524c7869546a30383435336e386f714a6f7a6b34676b747555354b337649327179356c456e305635527132717a64695154516c6768554732587835374e375965666634777a754d56665a3756505548566161743075544b6e57543131736b4145596443546470444b39635a6a5046584c39494b76427956595265344942773871706e5a45677442317a355779334a5675422b79393962686259674165666b6f35753832753751496454636d466b3467656d5351673963426f533751374b683846556b4b4e54313658586734485070716b4b78755530414e51736d70436853755638556a4c5842523347744a684d58736370397741393262316c4c45316a78346757517a58796d344d51524b47445437474334432f534f6a4c74467a6132324e426e794f59792b4f686d755872783751724d2f4b73715449386d474631777a76325244724931577a6d6345723874464b51714d6756644b64647975306b343073537456746f4941484c5247413474756f3973314675582f434d74536c6746467073457577456c5a432f50652f70736c3641776b59392f4875696c4932665974444e3767684669624852753569427073703467744a564f4b646c46466947374c3846746e7a484b62535437483470354678746b5a57466646775463435049357569463371335742482b614572785a48507453463241555754546a576d4a5a555a7775586154503432596553493877326a635a4e4d65685368704f7a6a524e5879524a415258536878677a4a62617870527463366a5373462b4b6777474957656135715947394a337065346455454441735168346f624958575875594e52506550412f384f36754f72744a634739695165456749414c4244517376756f57774b612f446e5a2f5747614271544a4d666b686948326e616a42643975696157422b5035772f554e503051355331425533596d7856704c3537456865517a306b6f3571767a343851504c385137485066764356765a4530637875764442424c504a6c7467777367352b5075444d32614b456835466c463065726f64755554345a796d6e63385534686d482b58316f327174735253705144512f552b763376662f2b743654443269345a6f506f75486375666a55413178334f79782b4131744d566e3946346c716d7968486c6a59317a427447615870356d4e474673694d66577369776b73776d365a31706a6c566b59543656546f446779644f38706c7330536742484566504f73776e314f437a34616f64394356676830612f78337a456d7752667a475545704d7635732b41614e486768344638396f474b4574326d4265494a31674e70597871426276686663774f34464a39316433664e5a786d4d3946484f4b4c617a50715442316f42526567444a504d2b6a6f617735314f7a6f524d5042706c47506f6f2b68684c31326d544279376e785a6d446d4c65416d627059562f6a56754e3455522f7a436c31567666754679646e75574e517467684e522b634b4f2b32446b3469773856787a774a4e4d4135357732644c3354504b414f495a6d4e36676a3177492b335867656e59484a6b4462334d6a415930494e4a423135654c455237493551436b34646737624731356b457247376e576c4848314d4c7257454d525764504265564864785345307a72717842326975364148317956617772576d4b5958666336764476452b692f684b4a5a69535a3835555a344f535a504f436e583836525a4e37513142495233782f4b6e43474b645a736f2f497a4444773578354677642b5643304a6f496d634a632f566b6f46715641397a46344b73394d6e6443416152324d50622f5168434a62676f414838646432414e30324b5646776f746a4464417a6532546d4474714a5747614332416e384749594e38486171344e6f337677747441784236516f616a565573554e722f73752f2f4d746b4a784a466c44694a382b587045792b385771735268746d554e67386d714c6b48715174636d3457477337396842392f61536f49734a35454e6364484b4a7a4378645577344a706f3942364356677135735a37324e48756a326d537a4d534a636f6a664643423933764e345053446a6a394a666f4f3055796a72557379467465434143335a4559695770594576464537354969303143767032517641594c5a505a656c466a317a71777056356e4f7a747066416c5736784a30687444392b6a652f5a6f326c6b38787352737373684a724938516957536d56764244727a664f455a4961412b7451314b4142516235656f71346c393077463144324d69636b76666d644655454e31596375367562736c37756a575658434d494e47554645434f4562325278474c644a4a4c4c7945433452357a4850574f6d4a426739552b46684d6835536c4f5750564e72646c634d753449547869597536704950627136786f4f306f4e6e50596b456c713446575442704432736e6b7a4975415276686f3637766164467738505078783059734b6673314c6441313277747a4f7342664c475946534b424c4e657731336f4c43416f5863313579386443565a565577524a6d6878526f7941476f4e4875514967783332534e77785a423647472f515553336f7a424267774155567674474351643848437747727545576c513231316f3234383356544e47573955744e592b33566f52594150677955467a664d716d3277464e674e4233465057476f674337632f533755433068325a7241574b6a37704656344d484b554d667164574671704b6f4f627234343762574f4c436b57786d59587a304174664f71706359464c307535645644514d5a6752644b2f64616b4d3838306c385a794b76437764683953616e59462f4b35666e4f483551314e685250556258516d646d64416639356759424734354a6151557948514b564e2b695a4b6e437773414c7345345a624b386e6273422b7a416f30337067616c7a4b68702b58366142706763524475797a625a39756e636c536a413949525273765a74676144514431474453437562333971694e3778426c74466d54366d5a5130427138625a71724b61365477784636667a73625133387361674d43456f365a56594a71586d2b6f6276326559356558582f4a76333434772f3068573975376f6f46675243376a667153303638444c31572f4b6162464a656a633472786458777469516465594d2b474567486a795273644732456339417562585a7436464a6a3732424273316a53723851507677577368795238424c6561637a5463547a587054677530444358524270454e5061437859616151354d4a6e61334b54583256614379533456746b4e4655756179326a463559466a2f67484a336168776c733252774d5654487676767147615a4978364c72476f63787363446d5638337149794a7736385348686469364e5a2b6e4d61546938572f70536a687264466d4163315859637234656f396a6174324b656c49697567493166476e502b3830566b2f49794c614b7831314f2b6f776457425a614168737941443341682f3939647576307633727239514675564966554b32426a776c7571426d335758693257544f786833762b2f45382f666b2f2f5466357678546b476149726c41506e7536756161377a4f6367516131624c52473037564e6239352b7a624f6c6232356645615648526f43632f53793049504368736535662f4d562f567979426c514c6e745156386f56626f45485934614d623835464a6f3437473572512b364e763145654a434f697250486a2b6a464a44684443556171625834637a727542463737517a51514f7549732f4c575375503750574d5948515a447254632f7779574f6c446a5a6a354479337168444172706863485275486c616d476e624f77444568374a7a69647748365233544e7944566e4176552f48666a30586a5976637566625835384d6d78704569676159705737337a59657363713745746f562f6f73742f664577626f483158412b66503546745878544373425a74474c3031594b5a2b35543947775149544b4846664c4135423067414c3439307372746f547249734c6836627146454d594e664a6457396d6233676b346c6d757837482b696f3636447a724150582f3936392b6d6d3675373950487a65315a557778397a457846754672524c574c76574e5045774c3462356e6a53784143592b72506f7564415670337852734b583068694d76386d513864734843386666754f3573366736704b6a62647a4446546375617a6330344776345058617762553664432f5135696e6259725448744f316c37756d57316e503468756b4137414841426868696554736936797469524c2b594c7a774f4264666f45546a5a6251455735316550545a2f61323249624a64446c634878414b4e315057496f6378703238754d756b4e57327669395071617861594b376e564f3059656e78324b2b75516178775a4438526e42785a722b466c6a3146433834557a337a47526b5a586d6d72754c577533674b66455272334237633372724a452b5577435035324f6b36695234304e444d432b652f373635755261704d616c776e7a6c30694e36772f716c3838457557745133707a64347870366677373057494e477868456c542b784b5436554854765872316c624b534661422f4e774c476255704d476c6a7a4d54323452344f366777455247665a572f7a774d594d486544765471493639544e4653674b373047624c35576b432f57435370734b7a4d70454e4a735652322b66504878665151784e4f376a6b5946366f67476d6f7a4f47744f376948777558667676697242446d414e466974457a534d774b3272327977752f624a356859746e7634656d5a676f7346427566715a645152772b54364e32726d72305a3236727550776865646239523934566234756e363542514b65785172453677477a43384436664a45573568457630556c4763393257786e4b754b4d4b396c572b733261536b6177555967334a396e7750423975626d4b724c306379574c7a7a463265674d4477413656513379512f784d6d6a6656386b5376796f6d72415370637730527849746f58535a745049723757597a6573795a3765634842646f4768473265545461623367447554615a70434d684458646541525846425a66576e6a364e336747494a39334e5565434451484e4c5977564348576663414e64694a49333233594e4f45754f5a7a6f4f3062434c565258376134657947637374444d764e33554744362b52437256525a436e456e49347055634c534944777237306a546f724978654c38335a59464c4657556e6e2f496b72794f69794b5851774c46333037736a327a426b70362f68553757566352484a335478302b2f5250434556754e587a4950434e327458596b73493741324e683936714f77567454546a767a61726d49664f2f2f653176655a38575a7351346c42646d4b65304735647a676462587175584f587834446f384d6568614372545361787064434332474159326d3459684c4c6832794831676751584a7a766153456d774e56433142766d41635347426273687638506c7762433635374e2b565a39586478692f534d5135447564476267724f4653415969374b5070514c2f704c71665744512b756f2b53554f53596350687a7769547831465558444f41774c595a6375686d4e3878734c59554b4c62724566656b3249777132323836526d4c56564564762b616e6b5a64584d493368726b614f30482b66457430366a62536767304c413455424f6d4834654a41705332722b796a6c3945436968466f76756678504a2f5a534f5a497a6e5338792b344e2b476249506c784d54687947306b364a6c65444f7844733074514e754d36514271712b36795631744842384c416342467a454277576275306c707269436c587636417334617250547655774d7a31466d6d7247563045707536755664754477437a31434541566f4a67376a69454c5258374c78585262445166424652756e6538454734785a7745432b717a41716c494e586b6f7a7a35384847717a55317774526c4951654f4e3959657175447a58463970534f4c79634a746447354e47395651337268302b494f43424d542b54332f364e364c33502f377750612b48364254614161306868594d4e62456b6b436c43557a75583376333737687453685a516b6258735674514a53393368617444506f306b7449702b6d434162332f2f366732444358326d54582f383437396d5a4f43784e4b4d7a37383448526147764b3748427a59364f5074704a757350686d7a657631647a574471306e5735324b626537554878332b436e356e4c625a4d3835784f53756f61724e534f3663495276796f4c71656a6a57446857624d51574a73632b484d2f586959536d383355327556345159316a347430326f74616f6a564c2b6b41615447543053306d2b5454514376344b796c4d65654138336c69624f45594653443954474a4579477365704a4c57396b665a4275464f4e41415137684266335261466e4c3468465a74394e334534384c65794872466c6864694451762f7256722f6a3556646546646f2b7a46426542794a6e4e5736514148416d376d6b67625536785962656749776b354b76412b6a41657570594658533074634d34464174684e637a47625a3164696e75435a6d513259486a5566625032614b7343516c7457783153536f3931556a45466f5a577570764e654f314c79516c6c4c3441484d597454766d684a74754532514e527a2b35735230715250304f644b686d7175714c6c7830544c4952624a7446664635355239334c4549564a64365a723244517565657a4c576b47624150744a336a41562b64305a3034715166496f2b56447867484f3052516169444f55666a4e704438677043485356646641375838646e736c5237474b4e7475676d36517674427550513359454f36625162436b693744564e4a4459656e504f2f2b4d742f78364b5351357a726734334d53444f3455425167356846766b672f44636a306b31734e426c4462756c46776651422b7239736d7a637a646d6233532f442b344b31687975434462726a70587775774b45496e317a63334d2f382f596958387072312f4c423248634333576f7935746161666542534a34583669724477733752444862364d4d43447a6e707a576357692f4a4165616334315455536b736e52624d336674417773644475665966454b36316a664a7a71344966655463617248577a4d49394675493034364c69587a3835523638574265547a34687a416c714c3237662f3247375954415934664a65636f43683855454e6b4d364c707a50526a34644f685876727261632f4a7531576b6575534d6c35797344714a7759454b714a31695a5153323668475a72493850774e2b72674d54584966446a2f483077794d2f422b655a4c63447a39622f36367576306d41466e4e57317249304c5747593966662f4f4e5374797964674d3739424252476a6278724252553938674764394e5953766559346b4671356e676f36776654683068376d5a6f44474333716b476a6771446b45614d6f717a33457165565432765638313063436b3051486e624e366e79702f6d482f376848373531335a7474644f4537527a4e5a745a6a654a5063624e375858453757733462503275455161513857696a55362f4341666330614f316c77567a465163534c5158556b5a3864635a6d4463336c416337596b2f4a66694150747a457259714c547442493154766f774441373150317a34574a5a5531475976736761313765653152544d6d4538366f71484f5649507a6d304934724f4f707174637148476d454b7033717a7178494d4947346f3844415162365a486630425858326e337a4c7a396d7658456646446b4a36764b3970745a6e676e75444634754242522f55757155394c706b6e5a394c3043445150477064416b676743784c65345a6f627142384451714737434a576763566379626d422b746f4667497a7a646268305135394664304261776c426e395231574766437147705a30636235484364514a58467872453574497548554f625869756b4b3135746b79504d6470577a416e34477133305437495a74506d46696b6835712f5175532b45786d4173544b593434577665322f36457a61456f4b44704241554a6b33303956523450435a3354416938706a6470316a762f576f62456c7a483949327a6e6c6d514c5071745073726c62484c38644e7a4136306e4259554c6e6647372f48784e4c43723753315179636651707333446576336e4c33775068522b45733667412f665067787663395a4366673154507257456c6a356e52764f473932544a456f7766722f506e7a757a4d4f4f474b52716b7863545863694845444e635933726e50655555316a56737a432f492b576d4153635765315452646c65633935485435536144636f68647570317a786161774b796f537543504334456d546e4c4e5539635930554f74446c4d657165326e784447356d2f2f396d2b2f5661374e5a56686a684b5a7a39312f374b46533356565736304e6a48636e587645756c326c41644233652f6c334971637073494b352f44476357346f597332336249746b584577525a684e70696455587542582b6a6d734b2f314953312f366749516c2f336b666e61626371454f6d69506e434b33675277636756434a6e6233593271473164333245376673334f4c5569546f50547852777357416e58672f33564c354e476737523752534f4c673936496f4e326d352f335676333147545273324b45477944334d455170394156385937314d562b56304a59475357687551576e493536565a6f665a3264584b5871367469557a49642b3635715a474a5a45325a45392f44354143356e674b2b4152524a4f5144344b35614566693459425847416742324947654655554f695555666e714d706d44464b736b2b6e5672746b4644384132624a726d4571567477594b634976464459336679374f654c574b6b3468654a794d5851774a68304c4e356368695762636344646970324633346a705863657847465758644e70583276615465686138684c346351657364467534706d4a66746947736677726142317a6863644b41586636416e6e375552683573504455395a434f514c4b615a4f325751562b35593538537274416b36744d445131524d6d445941664a594d376e3736664d44665558554338366e316770506b764f2b54622f39692f386d432b69744e6855325975657a657472496965355a7a776c6e474c36505531435876454650714a6147706f734f7a447a714e383173584155376663784c583142324579347848702b533969626a556a6a56374f37564c664f534e316336484c537134614e6c446471317048447a694a4e6e67625a31754532305870652b434374653347784f6e7868645873634a57443677306447694b364f7253385764446930454964504f7246674e596a506f5861504f4b745543304e747773594561753858694d67566a77545a6b595366647442513738393531637559546855612b6b496f575a744f7330375545464b49376e674b46495a695a55357a614251452b38315232705a50475953726c574e424168354e36317274427257435451386c4d554c4d695834676a5577434135744439332f336c6630752b4f5a756450436d415762452f3671785265507862666d5a773461417064507a496c72344f3267375a72454f344d4e65484f4d5077696d6639644b5463754b6d6175776e616b6f427834554d30545446324974364c62363661557a6454734f587441716c443949376155373577573378504e51645a6c394e426e44646c70372b733857706a4b78696f4741334e416a44566f5930717674775571414533634d394e2f4d334e586531415770504a3137706965305272714f656f2b4f56686a464631444e2b74615451356f4f52756f6c4c4851755557506e62385665427749323431577731647865653741737a537a346a4f763167303974514d452b766b4f666a79504d5076694c4c2f75325358414936706e58716662414634416a34567a4e782b373452364e68564851536c676a37356b6a59636f4744787a35515133304974353454666b554d464577466653326444583146533444776f35734b533347557259353274382b7667687a585274416169344c383575686a4368756877616b3941422f5655394b2b62427459717949474e705865414d43394e475563667065367943455973576b506a334c396e76472b5041636d5959546a715a6e74424e514567773454775971326c433630635073316243312f4b586a41513049476d4a3572394b596c714956484d6f416870557532766b584852703546316e786d7a4a4f415361444f34566a334c7246463151693077704a6d364b683154556c384c784e456e506a6378304b763032774657542b4f425072554b596b6379396e644d5a61726c4d3573597175466c75494e4950327445366850776b6d474b334a515142703959556d4a66446b6143714331465862564f5337546967694c306a586835494a39615a50346d7741663639325732554e327356686e4d4f617058376f3744544a657562545a7a45456169396b2f304f5a4b42424436646e7a6c7564366c4c544358542f4575452b68487935587365544f576c75634e642f6b6531516e77315a48666d4e74787a66365867714a366471382f55556e4531305a415473675971675452784f414d636561615a2b556f454a4e685551674f62332f2b6b2f666274686973514a33316d676a4d4b62472b5577653470534a5365585863787033306655336a6c376673333857796f70495a72487044534b5433796e6d61336e6e764748425863655552484f6f45357872677a4c753449393452336b73554f4666365a2f49776f484b346e416845412b4c42707a5a4a31476b397a48755462776f65546e784e473477345761464659446b77716668787776614a687779493368415266716f3945736e47384545634373354f664d63344355437643774b756c6b7457467733535643644457745656316a56377057327a58596264546a6f63574736316f6d325a667a413866637447496658574b7a364e4a354335507a704635504f653778664433387a4764712f644b6f4a5753427345722b4777384d32456a493050544f687a62682b6d4331337435635577486c7362622f337a544f306d36627642775946764c6a782b64777367574f736659746e485430572b677657514d6748315658306174417533415672595a3472754159666b717473346d62516a3762384e5251394c6b6b4c37357041364e53314954376f666b4830783263654541674b4a69552b62547068662b694d503949707554643758564238352b5a3034776a54427078747a636f4e617646536d32793739677a7a366a78515469493661786149755259764472472f7078443839754d5055454c7341666e395656704934414e645467387068584f5a733442434d3858524e3478442b4c6e6e33387151524438306f6548765169416c3548506850474272714e307a54723130514345704433516d6e497773496d4b497a625837655353334c4f3336636a354d684c76456a796e6e7377577763764d57717754537436635a4f355746667579737233525751637558534c4a6a3059747432686f6a4b6a36434a72324d7746766f675235724d44643146316e513344322f7764382f4d50364673616a316741414141424a52553545726b4a6767673d3d);
INSERT INTO `etapa_opcion` (`id`, `etapa_id`, `meta_key`, `meta_value`, `imagen`) VALUES
(274, 68, 'nombre', 'Isopanel', NULL),
(275, 68, 'valor', '1', NULL);
INSERT INTO `etapa_opcion` (`id`, `etapa_id`, `meta_key`, `meta_value`, `imagen`) VALUES
(276, 68, 'imagen', 'imagen', 0x646174613a696d6167653b6261736536342c6956424f5277304b47676f414141414e5355684555674141414a59414141426b434159414141426b57386e77414141414358424957584d41414173544141414c457745416d7077594141414141584e535230494172733463365141414141526e51553142414143786a77763859515541414747375355524256486742686233706535335863536459353730582b3049514142654141416e75693668643375524e746d57376b3354697361777354747a5a4f6e6c364f766b776e2b5a766d506b79655a37707a6e536d34323437635765786e596d38536c376b545a5a585762597353364932556c78414167514a41675378412f652b5a2b7058565764354c30443131584d4641766539373375574f6c572f2b6c57644f753666482f7571627a6162354d75534e6a59336158352b6e727a33314c396a422b336f373665694b41697674725932616a516138723531367859744c6935545a317337446538656f75366548766d4f633037654262394c766c2b442f37613876455a7a6337503863346c366533747039363564314e485a535757746f46724e4554564c716e762b486a2b6a69546533595731395864714235335233643950655058756f683539523437615533465938772f4f3165475a344c6a35724e4a765331705756465a7135646f336d6239366b675945426557592f2b754b63664337667a3734623369562b74382f527a79623341653259766e71566c685958615944485a4f2f2b4d6672795637354f6b3266503079632b386474303475527848694e2b506a576f682f74315947796376382f334b58514d4375376e496e2f33797451566f704a6f313537644e4469776b396f3632376e2f64653650506f3937772f2f7842667a505777734c4e443039545a73624a513050443073664f6a6f36346c7a67766e687462477a514e65346e376f2f7877625664585633784f7651507236576c4a62707834775a7438746a69586e3139666454575874687a69565a58312b6a473744797472712f775a373079356c3338504d6a44545237443565555636756e746f52372b4f385a6c65586c5a6e743350392b6e6976363275726371593877425362302b76744d393936682f2f78614e687542434e772b533338303078555449424a6e43343261326c52666e377a683044314d73336257397678366a494e5956644479466458567554427433692b335a77523463486430706a367a795154632b44776f4b4541665375355075315539466f307672364b7333784a4d374e7a636e7a4d556751374671396a68464b516f47424e594841774257316d6e794f396d487762764939494f6844346673595a4c733246364b4b594d6d30386d5638375361504138626a4b6776544c5a365166683650585379594f3365794d4c533338614131364955585836462f2f4e792f306e30503345322f2b38676a684566552b535a74334a2f523362746f594f654169456c526546726e535a4f2b637a2b57563166707874774e6d72302b4b2f63614764334841723944506b4d4c5a4b4939424d644c527a4868437a635870462f34624f2f657662526a6831346668435949454e6f38782f646557566d6c7763464247543963462f714b31365970446c786238434f4864724a53364f376861776f5242752b62744c6830537752376b7755497a34495134747372504c34513041316539464136454f425637733879437853653038322f743958622b473872744c7930544f342f2f622b66386e303841626d6b6177633972624741584a2b644663487037652b6a4856687062585771467a5735727242566a6d744c46706962504167514b45776d47745572676c47542b336f546a6a416347506a475a70506d466d3753776f30355972584a6b7a644951377547714a3031496537707252334f4a4b714e68616a4a48586238664477586e5a786e5162782b2f54725657526833386d7145454e54354f67694a303146586f576b52726c79776f4155586565426d574a6a5166697775434f6251304b414d466c6f72327163517361614e4274462f2b65536e615a6b58772f2f367033394d65345a33696b415550444539585230306357412f393573314d6c2b2b7a466f58332b70695464445231536e3377654c44633942753941486a7633667643485631396b51746b67734f726f644767494268636a485a6531694c593247334c68596f43437a4f4252594f574a6d686f53487054356944634f2b6c46516a514c5670623361424f317252594f4f3064515243356a2b75387746695251464f33386468433437667a2f6441577447474e6851723368494c4258437a787459324e54566c45304b377563313938777563726435303775735364674e5a42487764594f30454e6f70466c3145776b6d6d4a7a625a4e575670653545376459713345444d626b73484c6935614b3853776b517361453630427636447556726d52737a79494b337964377135307a745a6141663764684357666f6d567978717445474556347941437165624f7362437630774a504667514b4b3743507634385669734775635a75436d516a6d42524c705462694b62414a77377858546370674566413554467961694a734a623268334b3248635a4b396138582f2f57642b6e3750336961507661526a394439393931446a6d3161775a4a55353456306148794d745757664748665043324639593132306345646e68356753352b70694b6a4867474974353039543175677243344d3568476539574963507679365935304736304233324865594f513563494941634e31364a754d457776326a674657494a31645042426b6b4b4b67645a3544614b6e46785676792b7737576f4432395864454372664e396f4a6b572b5434594d316731764c466749535034444850613264464f6e653264386979303058332b53312f44307157624333707a76486177394d4a2b34756241434867677269455a4379656d63575a6d526d777670483259745577334e7869644b3055556e4f414a544b657a435630544d7a436e706f3676323731374e335874364765547749504d3932366a5172364a71617a6855563746676b777272724b774133656730656759634665667263536759536d62694e77454a45466a63394459704f7658726b763738536d30334735674f46344d497678326e334150665a57716c594566433132417235302f54332f3339352b685930654f30534f50664a54364f6a705a344a77493933422f447833595079366d6b4e573944485a6e643663754c41696771317562754f336332644b774963622f3674555a3169524c624d7032695662434973317856586a68643847534d672f4c59694647526b59556e6d516d4d676a5a37493172596970686d66627732414d754f466c307169696135535a7271515a6a747573734d457369734c676e2b6c4d4978436c6c374344514b356a33376935654149414837614a31736468584670644548694363376a2f2f37643935534a32594c70346f47654361457a7350745666496a526b59627a4a6f35343476734f6e7970614f6467775053534e796f5669766b2b6a675070414c59354962637572556f3568534e673771465a756d41437566374e68542b554b334a777152534b2f634a4a6e6d46327757546763354144512b7a6d514d34724c4d35626a507335557a3466424373374739425a30464c344434413944447650647a5045517775612b4c4f396737566a4b55435a2f5131434a526f4b584645476a494f6541624d5777666a6f38737a732f545a7a33325772742b5970306366665a54754f485a557a44362b3239376d364f6a4267367764326a46315049344e6d7032394c6d506250364361475843667643302b5565672b6d6d6349796b335745446434334e6f5946757869737a7a496d6b797756556b32316d6b5259663767364e7934635a30467130334d4f4579586a4a475a556b43446b6f563638646179614d69316a5656655644745a322b31513753686a70654d4941514c4f67736244633641523066624338437277312b7279736d6a44426f2f52446f4e53304d4a726a504557576344635a7a37376d4d646b6834454c336c47544734464f7279797679674e774d6134625a43414f5955497a616a55646e4e4c77453236387951494941446c2f63343557476352317357547633624f585630686165566a495750326c5538426334394743686d4c39534f754e44526d6b2b626c3545617a4277534561356b487473652b3361696278464f47465a482f44573777585874485865554958576267784b534d4d666d4671594a6277755968766a7639793463793056756d307a5a6a4171636c4c6f765a66506e65657a6c2b34534c39383451793936384633304f38382b6768504550664141564d32615a515877563732414c565a6e6d356376305a546c792b4c353774723978372b624352694a4f39555261754338594a706f6333772f4675386b4b2b786745464c394c4e353362317272336a564b6d526c70706e567231376943623932625561304765594c593964702b466d7541387867354c3678615261454679307745545355514942614c59346c666d494f5a6f45465765766963316779434b4b4d4764385443785777424a3438376f4e72524846383461766645414469445042434c572f774370756676796b5369565734672f48504c6c376875763556765262526131544e316a424143674350695234655669414f33414333505870322f4f2b365334432b464d45735a644b67316f485868474a6749646a4a6d4543476d692b536751794346565339445763514c50784552364868727335636c557633736e6b4133644444672b75334555796e366b4c615a6171445847592b3178756750324279324a53774e37664a674833333044434e37442f41654853542f756f2f2f5265657748373669372f384d2b726430534d6d4861354e4e3576474977635069415a68414d5a39624c433234346e67435a2b3864496c7538754b426c5267623238646d7059636444683450567a50455964725779326f546259614a76546f31785270796c716d41546a475430456f71434458525a456b6731477a42556d41736f4c6e3237686e6c78646d72706c7963714759555369674f6a44337774586a6a33433449422b5a4e6e4342524e4b563633547a486d4173345365337448584b2f4d4a66516373444f306f5976505045747239696a495236416d43336768463344417651364f74704e6b4f72696a6f59425678566273743265462b38474134414a6849665461513855445358414f58686d374a5a37364358314a41454d4c30394e692f734c59634b7141655952545569557441685239504943454866324e314864664a3870786c2f584444667447783056303946722f467046694737334d6f47546578706c4176357168675730775a4d307357394d54506e416a6a37564451432b374e562b2f67746670444e6e5871575050666f5275756665753669393173596175456b64764b4232733765494352417a4a7a697446444f4f467862416f6d6e6d525a37597765456848722f647246325972354f4a39324b57645179624a684346386f67776b2f79396d7a666e47576632734a434e69484472424d73333750744f5442584d45785146356771616678645449723239335559566b546859734643774e6a4444632f4e7a44483032525a6c413639567858317477775276486e4d4779414f2f696d6937576f6e675768484364762b762b37702f2f31614e6a6d36796c326c6d492b726d427653625a364952714376367643554b5438556f544a6f6274394a7836472f68386347676e396654334375456e657153704a737257765169644a39564d72414b346b33506969586857793168464f316d67594b4d70383334433053715443414c587a4a356f565a6736666a5963415a694a6b74754a37344d2f476d4a744973384f484264565858664b744647534b52396464654177724572426e627849686e6a4368396a38743775614f694a77542b4174386b4c447a352b66655a482b35664e666f6d504854394c48502f347849556c727244486132617673624b2f5277594d546f7255617a5533784c7574476c63424359455962384c70414a584266676a5941526f4b517464553778505633426442506f553858766b6b7834515a376d33507a374e586557684161426e305855392f574552563778497438482b446b6d77733352434177647a74344551385037684b72524f5a30415438336d7573692b45497238452b59506d67796d4c7041544f4f757541644d376a4c6b783367767a494e6f30622f36667a3770736171416854415234705642516b73664a775158626a4a4841655150615735794130645a4b34673074395756594b50414e72505a676970584c4136314971425277435545616e354276676350427152617748614643554f5a67572b30417972595a36342b4d41516d48326f5a37547034344942304b4c726e51526a68317074486f39704b524569453257563471755346417677496a51657341454a336c4d30775445306b496e30704846564e674c3158495748504474686f6a756d572f2f724a7a2f44344f50716a502f6f4548526e624c6349766244782f506a344b55724e66666d2f79392f682f374f4b764365384763724c4a397856546a6a627a5434443279354f544975516a492f73597541384a5451467a52394c327049486c5077674d453276774a71387a74734a59695741796a757673376b6d526b4b6935537a4744574469774e4941654f3745676558463341714337517251584e412f36675847635932304835774f43426173453452465331367475524e75587a554e46583241706f696d7332515237736164656141596c7735616a6d7a38324e6d594472673958633155593046464a77675332675541317a7557716d4a4d5a34596a4757516a77304d49454a3569674d4e466f41374261434b7449572f6a33594f716d47474f675177665a347849696c502b4e7961675a2b373664566b716d73307968473136634d507558723179522b324c416a68303549717066376d6b614d6d6b3752416a596a464e5a4d616e345a4a502f39396858487163665066733866666a684439482f387146336b3463354e4b54573339314f2b7a6b4d4a4135566f5149504d414174524167457357445654624f47554a55756a4b6145675335637543426d5a754c67495a37385859536839654a5961656a71476b4f4a4d792b3951432b2b38437671597a5039766f632b51414f737461596d702f695a4e52706e32674e6d5671424d51492f4f684e6e67426377616e6f4f2f6a59794d736e5961797671653567673437776f37494342576f526e3373464e575a376f6f4c497841524973332b61577666647348382b4a4e4f367a7769674a596859626175584f4834433051706342554b6f436c55424c694e6a65566878484f6935796f7a6b41526f47456a724e6e676d51512b6932776c56496e4d424d414455783775413577446c51734e4236384f574b793042524475565245716c774866374156687754305257344f77417a4f414378766674302f695865496c6d6a744e68695739635846696a6c78444e484749673249635241425a576c35696a5056506a7a314768336a682f4d6b6e5069453455346864626b4f644a33467362465449536543736b6755475a72797a71304f3058696e43576f6f6d46646a4f776942636d71666f6b437976364d5144572b30524a34726f334e6c7a394e71727239494e316c514c742b626f304f4839644f714f4f31696a7237414875556d486a7836686659774c4d636b494b33554a4674744c58543164555a4d48737872774b6f6a6371394e5835546e6775614245424b4a6b6b455449612f356c487434716a7955734468593573465a68466761577075374e624744794e4e34304a2f4d307a414476344b454a43612f41506b4f6f45672f704a4e7758334e646d5539316961435938484a4d2f77566f46507850576f6b686c4248346f614d6767454e49473831417749506a2b4564596b596e4a74566566555169413067362f71374231575738424e34473167506e4876595662354a3036655a43646868367a6f634733535a6f47493948474679344a7768576a6163483841585a69335654616a376479322f534e3736414b547068664f58365254643934524e544a2b774c7675376573526a52554341746434416e6673474b543237673731415756777966726f6c666d3374745272375454453136377a7331352b365355687338486f7736463432333333733743775765567755593078325a365276597a4e326a5857755441766a50732b316b494c6977744d6a35786a624667546377614e453669466f4e6b37324f6e617a347344695142514b7066596534585332474d7879734c774465595148756b41383243594a77543759553177445a534968384c354e41656872374a32677659426b77714b6f41504370415356594943617138555245526165517452386d575a35776d44794d506c67734e7437756753554f6f47626a74724956547935584442457768476e343035414d7946414f39437644444b38512b436d436a306732514b314c537930434954394645396f55786e694b39785a6d4173455466667850516534662f566159756d54567374464d6a634274706a67596545747139754a41775068683563314e54584a453970474e3567722b2b6c506e714733762f4d682b7233662b526a484e52566e51696542514237667634394a526f34564e74566a75335a356b693563756b67447a4c43507349414d4d413444616172386c516f754e5061466978665a3633795a6e7676354d3354506e586653412f6666717749686a6f7746346948305474312b63497944724251366d5a496f6e5941675a6a7361346f47764c53394a75473644465147347666624f6272596f75364f3279623377674d6c4151594243415036455a742f4c47684e594c484a7470524e6f424e774a4f5a69464d77564b615933563334474a413679614f77327a4e4f326d336c6868702f366f54635961713958727a5041436f335230774250625151634f484243797277484e46756648783955582f2b4953357846344b77776565425a4d2b67546a675234476e446e2b79756e38556d38595657343067795a4d4546446345343443694471594456414558524b376c4e4653423445305a4553474448784672444b424c596f3444744459574568545679354c6d7a4575434c75382f6531765a7a50545339504d78442f50416e434f4e645943527969476546784347457a4d47583858576b57646c5362745a7650597a3048754a5a3567384671764d5355777a4a34675676334d7a413036652f5a3165766e4d4b2f544b613638784a634f5542382f547a59566c4f73486d4470366e384644576176484676663537625a304a53773771447a463867574e5669414e53734a646169496c2f2b63784c33495a32786c3237714a2f48427547746334766e684f6f42647769744661674b794145454666514e7442774535786f44666e6978594f4f48686e644c786b70704243304546465947632b752b2f4f5433764d79395633635438533759556145477a467472384b4175737671464f566e6e6867506b77675648314c7657426e7461553379476d4a4a76556e414a6762386b654777734d6f52686a6958364367506d446359373846354767584734385956706d364178696b4263556a55496d35764f41474168544d684d6743426763455a5a4f3355597178322b6e30496d4645336764712f34444d4e7661307949586d50572f4d726b5a526e413459452b786d566a36686e5636674c436d2b4453654f582b2f542f39497776454a44333679472f526732393769345a33436c32586e657a5a37556638734b34544c415942324a52642f55555775697458727450724c45544174686376584f5a6e58685553465a6f5137767a4732716f452b542f3230592f53512b39354632744a7862553142755643556a7131457137516543596f484377714d6c4e484e73665050664d7a4f76763661354b74307437645434635048614942447338425677457a41522f7534794136516a686877586e44332b4b78772f4e6e656343316550644c5a73616f4343525761326c4f5856314775716c4334537a794b34336a675149516e474c505a4856566333414f63694d512f2f4a78416c6872675064675653756d7a366b6d71496c47304a414e47674f676831574a5651766266757a6f55516b4e61462b336d72576733594a4f6955466d65306b516e4473317952344b4a67663077443333334350757537634659537176776c63424750746d61634b5a3870394366344a58687347354e6e75444a746b4d77593347424a30386555724d76514e5a53596d6e553244764249736550587955586e6a784850336956382f54577836346c7a7241363445694b456849566d4174704f4b55546b4d684e396946763344786b6d6935732b636e365361373961764c7a422f64416e2b30524c7447574b7673326b4f2f2b4f587a74466c6a7752772f5145382b39583061326a4e4d703038656c584847496a4871556f5257484274756a3167433569583765767373667171686e4e4d38546a3073564b2b392b6772446d476e57506774736554715a31746a4667664d78376b635858587a6a764551636b4a41494a6744435438624159333742785748786a76454375326c7a43365a2f313635685353345155796853377052337759416a4e6768474677783864316533654249396656325244512b704a44554c5077544e497477796e45566771696234706b55684c39464272473430454b78317538535a544642414d595476353759644769763832396a773966554e5351524571475a4e794d732b4f6e58696d4b6a6b77727970774965705a69716a686b7241504830752f5458526c576c4253416f63456c4d5169356135436c6f444a474a626c6a434865324442314552446c46456a6771506176332b43336538754f6e7435696d595a4b757944786841524c6d696a55644a31467078627645696e6d434a34342f7735397651755368774f4378644a66516a61492f52307a7a3133734964336c5072342b78744e4463664d734c4264765871464c725041662b484c5439434251332f4a3145303374546e46687767486c61574c45512b304636772b516d71697663476a675a396938336a6b78416b3679753862484b4a36395a57583650725661354b5a4d4d314b7049766e48503059592f4f48464b5558662f574374476b504f7965646b73576261436d4d4c534448635a34484f456e4174532b2b2b4b4b6d5458336c6d392f7a386b63475a2f414b3061772b42704b444f77654669526347794465447778497a44315172464a626a705047385655734a586c7859597642617035314441304c7764516f6d6b4e6935664b655639616273336b314c505136614359494a51416a63314d4568707432374e5a757a71794d6c75656c413571614d6f6d425650456771456d396d7958744c47464132705867472f72365054544f3061682f4351624639655461426f474678703276694e44525579376b3244674e74304e2f3837642f5278577458364e48662f453336774876654b646f4e6e79504c41795a31367370562b546c76375034367634464e446834365142506a2b31674c6a444a6572624d4a3371537071374f736c61667039624f58364a574c6b335344412f746f6553395033472f38327350306f66652f6a33723432765a432f64635951486271644f44664345416a4f3649756a68444662412b3048566b5849462f585639626f6c5a6650304757324149415762637a4443526e4b3267666a34566b6f46336963734868414f2f5876304c77754d59754237794d6444384164654a5431563135355261514e4e786c6e72514b385130576d5256705272594955755a586b6d584f386248623247712f3079774b4f522f614f4d455677514e4e785766554b37785765484a74514a5164692f70514a414544695a66626f6f4b4867554544746772365131497841496e726659695a7a7339655363697743574974732b7970374f744e38663369696f46724131397a46486c653335645748524d43733078467a7165424b4a704d516c5442427a72523546302f533455506a644f30475939476c46526261465636734e2b6b386d7a6d516e53736343674e6567716546317751375453655a2b74697a6c37554249455a6a51394b576f546d7558326674504b76557a363439752b6771422f6358463165705a4370687332696e372f2f344f5236586362727633684e4d53427356347171544a61516d5077754c45336857526f52764341304d44593173433051646b504636317a333330756d37373247744d30766e7a37346831416b5544574b6c794a734475496541596c536761654745374f563235776d57705a4863634544635a372f77754f38574b6a2f4c726e5265624863514c4f46566f51454551306e366f5a674e654254494c415251684754336346696f52706f6c696e74424b4a4a7055675a626552415351452f6b4b6e7a544e6359636c79354e796b53434155626153512b725a70656c786b4233776853312b5944424d7545584b557165484645416e2f6f47324c7743553865434337635a684375776f32684c6c394b6d77365141613055484e5334444a5450726a697a58696f5645684e594a5754703738785974384276633265783133656941314a506c3551582b547347653733374271676632617851435741626d634a6f583569774c456a5462357561473849686a504f4659714d4241723746772f744f2f5045485862713153672b6d4c377134616a51305030462f2b2b652f7a7a304852576a5676644a443550624b67436e30504d4d69475756644b5177506234413166664f4546746a544c484e647345373572524442566d356a6d79347778583258466335314e61686437744c324d3178443667514c7159466f7057424a594546424553506f6a34796e646c396b554369747532734958356f4a3753377044614d647072473135456537326c4b7936506950494270473442314f486c594351444773414157386d5645456a795a54677036534838434377644342554934504b7067693042334b76426956377459644e6e61625152684d57764249546746724d3453366a4e676d456264534c586c4d3970706d6476736d42576c415a344c4d6b4c6352327664794f616f6a337a67524e2b6742684b777a30797770566f563961304a30346c384745383739586549796765584868726a314464507a5945535a5239776f6d784a316d3534415872394d5638486338515276734b4232594f45676e6a6a4e75484f78582b6f614d5267425a796d33393572642f526b392b2f316d615a382f6338534c65776550396e7265636f4e2f3972512f525467532f76615a486b7931613466554b5857546f4b774c4a6d70487168504b516862725a6b4a2b59307865662f526c74416975796452676432382b59716c73302b697a6a756e506e7a6a4a496e795450312f657a6750567a6648475142587159462b63477835477638794b43554f2f424c695157507666564a352b535751663531797730365578544b58516749536a586553564e4d714548396e74736449533968554871364f3655696175356c43436f4d613647664b2b796b38526c53585245306f6d4c48476939775549464152306648396342742b7661617355575369426f746a79414849327053384b454e6d4956675279464f65316d41634a71326f553058306c51744d52454977524c7978576a466a4d53326c34346e3577493438417762646739424337763673773059354d70575342496473504f4a505150432b546f73574e30676b457942686f6532784a37554a665a6735706d38483654672f4849384543495a597a642b32362b33317665656a2f6465666f4f6a6a563665766d5656396b714d422f456d6753707a4e41307a614b442f75597a6e364f667633794f4e686a44397264315546396253582f3473562b6a683935366a3269736b423956785a2f616c35415358737569474f7a2b41354c4a7461766337682f39344c73634435786b5a64464c4277346634564452495448566d413967776f766e4c3741576531586d4474436b687830796d4e6d444578504d462f5a7753476861764676332b4c6566466e644f3348374576336846416f424241712f4e7a4d6f4b324e477275304941424774464674707747692b6b6e466d585854534661674f6e666850756659733178697962546f534d6f433267366e635037614b4f726e5a5a6c58676d76434a38443635377845666243466163664169536b6157535279514a666a507947664b784a4c633743797435617a4957684772546a43667a564247757748336c4c443838596844454d367870726c36646c7678775048646c6455574543726c523449574f486547414d61396d6d4959466748596d504b2b773846326652577230696d7a35327339412f51435470474463662f377a5a356d6d654a354f485439426233767232385470516278323039634e697642342b6a59686e792f666d4b662f396a2b2b544b2b77356568753736624f4e6e5934647262522f2f596e663041487830643550454239314e4e696436706c41795442654d41354b514b38594d45434c775537554c4b326172495a336d44483463723044464d67627a44637553726b3642476d5576614f737362644f53543367526b38397a707273636e7a73714f6e74367548656d582f7746353569796e4577472b7562386757487154797269444e6c494f6b3243324378486a593335704b4571746b4338655162547a4932472f5a464f4239334d753368456c4169737663724451632b7848426c34444463736243327979794f39365137774e59466a48616e384a487552594a4c776c554d3861627355413142422b44414d774857694e6f703177585651574c45684e505252546d4b4669464c676f385a355a424c5a347a5058564e63762b425153426b3362777764764f4b506e3730474f316c6a7737754e30496e3047517a4173536e4a64576e75364f62476577396b702b4676436c67466e5a3978424e372f766e6e615a5174776236526664782b39754461617978556e694d5a4e576b5878727857466f49764e2f6e396b326466706e2f34347464706d65466472624e4f33555744336e76504d6672446a7a394351787762724d572b686a47756d6e51416275486b524f57583474484c4f4d44374230396c63474b4442584c6d326853397757442b476f50344e75617a396f794f4377307a4e4b67703370435a53347a467a723732716e694f39625a326e642f5050765a566a3278455941534d374f417533657a5945594359313051475a396d4d506776784f476449334b56596e6d7a343549664e634a423169646c6941465445455073733362557545326d4a6179366c41634e54776d5243585175514e7453746b3631714856514556746d695a6272435a516575677a5a4668423278785a6a6346324f53536e5334696d513157316a35384b6b7a624b6e627665626e67632b757355444e694c634541554845414f594736762f516f594e3069453341546f3543494f53444e6948346934417369454e594174416a594f6f6e574b42364f4f42637a3079384d786444485a50452b6f66594a7a53567a6e476875356151516372596448567a6e5437316a312b6c5a3139386e5461522b637a394764765a52592f2b786b503062783936534c7a45594172316e74582b497259486e496c73556f6d776b4b346f2f4c736f4b51716d77434a2b62794a3969736638504a76424332665079794b4765542f495a6e4b454677533238474865456534354279466b6265372b6a372f3661773942476d4c65436b78747a6378594762493238317768303077524f42744767536d436167514968576e414a7359393242724f4f454e324d73756f7166616f303161584750654359416d446e59566979484b6f4a4875434f3461384d4c4458736c4f614f776156486a49574b39704d6954564b2b6b634670767263466c626559512f647069532b715842636b6652667441756251394232754e736e6a724a48642f434161484a4d784858575370633533414f5045323344665a414e734a2b39762b4568533755325478766945734a624366383445797876326a54674f52576f706e42464543794c6a72436b515774646e706d6e762f6e55352b674e614249573247364f2f343375374b502f2f542f384d52302f4e476245637a4c7034566c68654f707453677449546e34514a474130504e35325841585133375378416971514c4651656c334e6e7a334c6f3651324a553437793474725069777a57434441473654667579392f3472696f6863736c4c636935623855613845556c4d4c4a67363266334b516a544e48634d32634a6777624d2b53544d5467635558794c4855733548486e457971624d59444e2b50653273484f462f3175316246486b613239593359453974676377337a346542797a53444945494a5173437034467a6954347a3847373959433044664861444d6379747851582b47394a746d39496637424538654842434e446e3671646b594d384b67492f4b5039474945347846645145416535684137787030507356497a736a366c4378565a4f6c485157474552354f6853743251564a6e684d787a5a566d7a635a76442f3139432f6f733139386e4e5a41763353774a38324f31414d6e39394f2f2f384f503066697559664b55556f44536741644263354c436a4f7852654c5a686c6b535a474d46634374476b5171344266354964537749527542327754472b634f382b38316e6c6d376a6e7733394e484234386359584f356a397754332f712b46324c4c37484870732f52673070534d6b4557414e4e356c70766e6e624e73515045424a535147486864534c544a326e6962534273686c3141535248676b6933616b4734516762707a5a412f78566f4b39687070304a702b584d2f75365a49336c784f3538752b4351677a505a59495656697345454946664341586f45366877734d58415575685442354f56454a4b6a5442474d534d532f33564a43356e695658704b555872525a4d696841336b37735a7a7736774543367a515461687a6d6b4b736d575954734b7a6b69566b736e484c30515253694e6b4956686b6765594e2f74736168346b2b2b656e50305539656570574b7a6a3771724c4e3561392b6b447a78346d763738397a2f437634664e46555869365a7950305143383445686872324d394a446d5750754f794c627a6d3154446a58626f776a706f53367a6a69414b4a345a756f71423946666f5975584c38726542396b795573746330384c5a686b6a5258746f5941507335314271344e684e334975383369674371744453764b70474b62677651316e624376625655566d39372b6379554c69444a6b43646163746b5a4a434c416953532f626d506267336354566e6852314a4a77356c52425259767079677770494346304262354a303273574a55384a4f6569343932375753456550485931396737636e54446a5371316e516b51454156542b79623454783157484a38756a67384965334c46434136377045426b32444774396c2f724a6c375952784b5738375469326a527070576e5459454b2b597547557352666643686439453544766463352b43314b336f59304b2f5444352f394a643133386a4339367931334534554d56646e44304e53457a584a5455736c78357761486337447965686e30497765735736424633574c4359716330593159636d5762457659706c7666515a2b5768373248485a4f7a5a43397a4a6c63666e5346645a597a47506c51413858627868497673554d4d6741704b6f6741474d506a416d6a7274446f4252595a74395066437345332b537236574a7571724a2b6b4e684d5038594d49772b5a684d704c32454169557866474e4347625251584448625570765a6c50417a674a4541386d644178414a55517a4d7848774e36414a7758736733324d342b457a456d597330304a7073354c2b67726f42494457396a5a31454142556f636e614c4534704f38573969784f4f50745238636871536343663846504b6d714957617a656d42614c4b7a7a375450535146676d427373624f734d74622f307848666f7131392f6d6879326a76464372374e6d4f3747336c2f376a487a354b452f7447785745773679647a67426f59326d3573385763727864355a42784f75794c5066594d6f484c38783372323339417065485a4d475342524c374932574638443052736c4f617679365a71644c6f6d6d3456444555454b4752355369435a68576e32786e585a2f514643445a7371785957306a7559435653456f6852644a2f785a566d51306568425734425759486e744d7443776364594b414c594e7a7130595759594443646a747932584a625430592f747749524473304c5454463235496c6f4b32676345483369367674352b7576766f55586b7575426d494b4462616e6e33314c46304e6d493446444f623337727675597477304c6c70614d695a6447585075433575674d4f6c464649347335646f454b7955387573725071744251525168724c5173333737755931484a44764c69483376454f6576584d65587270346757653046344f2b54693677447a556a333779557a723032343949516b42636b45594d367a7935754d39686b77506f304670746e6d4f527a474d42597749615949396f627a643738787a445176345a4842456467795a707a4c516d6c49576b54306e624f557241776c6b486373634b6e7257714b346875597a2f64435362456572503655726c624a587956376641676c3858596e4732414c445273493851702f773254424943506f50494339733678786b4d41382b534a59354c5745564978346b426e6d69706873555235684a4354704c3759446d5a784a6f7947774d36623679776751672b7747643973626a42763030504854787a6c4f4e3142326a7538563077705067663468476d385951586e774c56687838366851784d5347394f4e6f72707a6953786c7143494d736d4a6a39346d6f366f486c2f7737436c65692f316b32304c6f4f655072732b393235567746675542504f32632f74324433545268392f2f646a722f6d6464355163327a594446383457756666506f354f6e6234474c33394c66657941474a505936693455356934473461716b325136595047424f6f4144685a4a4c347169524539495571637767632b464e776935436f454f677668436c3146525a7751346962414638366157585a4a50426b4b576d77687a56732f3134354c637933676b774a2b3055476c7a4750436a456e31677a7a57432f32367834696a436c45776430327a6c6f434567396774717957345153316f765070656f726a473851734e4a4d48567a395357676d4671716c6c55564a4b4d5432643031484f6368732b415254414c736c70676c5345315443465161624d4a4577696367334f73715961597978466659413169783749356d764d6d72656d4b36645244782b4a7147696d6d71754844716c50503945653752716f4b53783068434836357878576670644b794c695553384d6155316162756e4538634e3039366e6a394d7a7a4c2f43486e594a3935686c3366665762332b5a2b6a644a2b30387935687466396d75455a64564541624c496b7a4359684f5352463872757433693070564a496b744e6b3047734a5a4a5a717749555733674b6d6a784e6f4e6b656c4448495941457773546f68794b656f61316f446d6361356c67482f656b68626762726f4e484266554a557a646a756448516671644f6e5a4949654330413679416b766d6a525372374b664a50474c765761496d61625170684350424276614e714e3956584a5a4557714c6a5a7241766a76487873587a77306d454f5a7461766f4d6b35327a3069376b694b48537971474445314b30704c3239557a594531504f556f617739775a484e6565786365326b364e562f66454c69623453464e32516b4345645362334b736f614174424b79352b4c54704338653952494d4d3962514758756a6d6a6d7a335a332f71314439456b6a38664d7a5355714f496a504f6f52656d623542582f7a4b342f51662f2f7a504a4f3063575347785631363331734f3069664a79757163425174586233637553797961306a5853664b616d4a7779764d59364e45584e65306f4c564c72516c72787a476d4371533654456977697753646a30536a65764d526f5559334e4d51424559344267596b414a414b77434b32416770443653573161464553384a6774752b776853375730646c5142765334704d634c6b5252317863574a51594862496834454569625269436a4b61426a4551772b775148666b4742534e5538447653655a5349506d61786f487a51524e504a64643977684a475933413159766d3064306c477532514d51385750704a4d334a4d51574d6c6573505a6f69747a34473243344c494651756e726d646c4d514a7a437637326c6e46696b77567941714b6d7361664532576250452f4f7a6a634d7548483335597543326b76677750374a517439543936356c6e7538326c367a7a7666706f58774b4b557359524e4b67547a696f6c532b6a4f2b2f77686f66336d393776644f79626e56684344417631647456394f796a45764b36396c6c6271313545577047455265497259436158666938565263764d4631346e66394f4b6e4149634931344875337941766176425579654565464e4256584678527252524748676248596b2f4f695865596d714e7364425353684c50574e4b436178496d6d62387075314367736b4759776a572b373935374a5974676f4c39586432367a414c3134356b5857544e656b67426d6f43365477506e442f6654544778423038546d5239796d4b43656a46657a624f32532b6b6d5264525568657a7661314177497159764b41536d4773454c6842444b6349745231394a484a717a696f686570724b5a6f4f6c636b36427177475835334e544e54586e5a4d782f56634a4c4f59744c364c5a684976625077593337575837722f7a48707043786354464f5671376559505747484c387931652b54694e37646a506d476d636d765a59574470774f715a39564536774c6c683136456a754e2b726876554249684a4153766e344e75576a73323045754137453433332b6a324f49554264614c677a57556253306e64307068325775675870647a51776a49746f4c51687630466d376847766355794b6d64567461314d5a743261316270514931564e38724e6958597469575a4167514c6d6d384848646a336b787745336170734444424e4d43305962664c49646c795069677074364174586e767464623732686f535757477759684f2b67303365636b4a33597150794857714a685735767a61665733657054566c382f2b6e363672774f304b534b656f5951555463547561587166642b334342435359304d3634747971784f526a427a4b7035784b35305062384e586f4730672f487a42366f725775626f344f55565469476b796954743361306b574952595a7a474739725a756d5a35666f3857382b5458762f3646484a644b33566c472b4438385252626d364c615358546e6d45444d386133626758637441763474395a2f4b4576463072366d4f584f364a55316d4e64454e6c6545306230374d455678524a733451684555617a524944387430536744306b65654634634f4b61416b2f6a3436375a366e3174416968356b74713455754a304743426f4a735471494579686e715557546474447834346545584d48726250425641673047544a435a2b6434646135765345473045646161687738665a444d7749494d57306c3743666d6c345079366733307777746e706f595367704b4151463672353654537631456251397867473478466c696f376446316a54686c4d383073697743424861394d4f44725738664f4e4a6f773571574f336258354f6270386d66732f655558696d3432477037564e44655476374f766d574f4b3078466a4c4e6a5a6e4864327374657230334a6e58365957587a394a3939357a672b32684d75493046716c5a334975544e3046576a4f6b49366b685a6b43314550465a7a537748725946465754454a61546d435979617573426c6559754e463567704d457a5865624a6d3773784a776e304277394d534c3152735972356a7559346361364b48557941664c5953792b41677943523753644d52557a63394a5658723169546f75794a71475747537437376c4c524c51525234526469436a4b41574544392b44397765686737416459584f496b6b4d314931396c2f5a544247636d776a7331544c69412b6d434672615a6c63434b712b314a6e49454d37745832624f74513145576b6d765272614e51315a334b50756f64335969684e454c6c7842492b6a63534b6a66574e756b537339726e7a312b6b6d626c5a495453783757705463734836364e36373735474d692b372b5076726934392b6878372f7a4643313744634e7351694f78522f665934392b693866306a744a764a594452724538516e2b6c34724b6a6c717765726f5842534357323044716d4c51516a587a4c6661737a377a3873757a713254653258394f546f51752f6a6b512f552b38625669463331684c6d734a4e325a4d38496a5937736b5731424463734f72597866424f496c68524a424b765370486b4949586d4d463442344934694c6a3873496b432b327442556b305731396270584a7a565a4c67446b354d734e593554454d4d2f74455653556668396b784f5473614e43454f4441364931495853493555466738773051676d6b516d774f573864734a51557074466f3169636d514c636f74493566304e722b3231585078554b386f45756b447161306d706d466749524b5735714154736f3663492f71786839636959724c7779665a5665652f3273624d69413577612b43467a544b4776793036644f306c344f4f6d733041494c557046757244667255503379426e6d634e315743637556613055526572784f4632522b3937787a33302b79424f43387657725256786f306a61486d65377161782f71425945547a7078636d594a754232587a6c2b6762332f3971384942486a352b6773623248314442576d4f706e32644d67776d455852356d334954414c336135717358515157684e6d6f754352627261665434624e7568534a4d3232576145324177704e5347457a427547724732786d2b624e32646f31524b2f33596b516b364d446f6d485a4164496d77537755394263304c6f6b5278336c476b45374a3547555938774553462f5368376259755a3044615a4172375a562f7866316b314d67376f49744b3268376d73553471357255417975722f62324e59496e6e56476a524e47415a6334503158744251705161697665452f5358486e33304873347253494e793663463977347637524136327a7130452b6b4f4e312f78306c4a452b394772597a53366b3137585642686139767a5a793753333337365832695a68584f3131695943314d657950547a5154582f36653739443935303443455a42692f4a61756c5365645a48506364334b494853305647554f3777767366622f2b38677532715a58662f2b662f395a2f3949717537505578657971365666685336725a7562376154526b575969643173444541456e346d636d36564c626b736e4c6978787145492b4f715147594f716d6d776a3061353445357a71455648414f436257646178502b61614366514354444838507967766242567167756c6679775545664b61636d41645670703377545162582b51546a56414e2f4b7067616438435468516c45767455465334767756735a6c6c42326e4b687954354e7030594953597950624b5350536d72585a71324346363756433334616b4d6c2b3865464777493641423969726947377547422b6a753036665947646d724730466330356966384e7745764b55754c4c38332b50326c72337962476667663063327941306c59556f652b7263335233524e6a394265662b43684849617a6b746d69756d753131535033534c56304b4c37434e66716363716c41334a614f3734636d4553656769766e616448596f362b4a7737686f616b735a5231576e42547a4463784c4a575a755967304d6f7947747877397769413846467a443732734d776b476574714d4d496a3972676b3064616a634e442f594c434c2f4f33707a6970687569366956746858485443414b2f49794f4374374436777a4e30696e3357736f546a55677a544e4a656e79766669713742376d4a624b32425579313432327a54357772552f6569742f30707a49396f527852594b746a4353645352776651594d4771796943785549346b57566f6b7a33686f655063776e574c50647053466154664b635963595a4e427534646b2b70334755374a534d424635383733336f51587239776956362b654973725546343061624e67733678462f6e31372f32412f75436a7632343735726839596b61646548374f48424152486e465043396c4569394163796e6872646f6d6855724d53674277346e61494c546832497a4f6a5232633967386f6f33596434444f78646330326b6d4c7339667543436b4a414b593243674a5049534d304f474251516e6b69676c6a696741766c497a2b7858506e7866776951784f434232463634494837574f43477242422b324d7a6759307a51504f4c7158447358505a62576345747730375949695a46496e74346368762f50556c756949494d574b734e4b4c3079345848557868456f357a615a734c726e4157756e61314977494530374a774763344265532b2b2b2b6c772b50374f536a634c6545764c3048654d6d71333248347a73364b6877434f526169374a414d5866474b514e3765696844332f67765854784d34394a30646d7977554c4f6f6141562f766e3073382f522f5865645a6769796e396b7032345273352f6f4555725a31376846666859614463476e4b754d6d486562336f656f6e61744746774b6858326775624b5445475a5a5277457a773443645a35583267752f2b705579344c7769555930477243323277392f424f41433554564c4b322b767046792b7a4279456e5669463968584845766e306a644f66704f776b52414a774770685868616c4a454934444a734d74455838467a3857382b30554737426d456b65684f677666334c7856504a3368524d6b523448554c50453154796a566474614e39636475504538593659726c3639493247747a5934306176506751446269544639544577516c7837554f57434c53307772436d386f686c7975377757656f316e74616d4849635759326c69703830614c625032364f6c6d622f474f592f5465422b2b6a62337a2f4756726b67504a61672b654a36516534596c392b386a7630462f732b5467346c776573313864534c6f747747426d6a665942617867514a4a6c3268724f7377673045794631466c3154333776527a3547306c306f675533565a577a327537544e45764161555477446d7778757a74325555363277736e6f5a534f37425468513264587547393143397130304536436f48664b2f4e614557396c5655746733527734714473644d5a333149517057537135396c614c58464a694d2f4e626d6651746637635637424c42474d4e522b467467597550336255487058544a68306738465246764b587050536f6d735658456b394e7259654c7a6d6a52694737614834344b74694a67776746677437595769554166486951446b2b4d5339707a2f343665536935384b4c376d584e504b53616c334736324b394c755a424276586c716f63316c6c59655a4b4554366f787645454d4644565272793832364b2f2f2b7a2f546d55755868586c667237634c634e2f6434656d443737696666752b526a314a377a5675744c655778464d77373351527266773946522f435a314e4449536b6e714147674d733136613278744b50386264786c6c6c467541414b5831747059506b4f417857695a74496d7565774341627035496c547248584771596339795a57564e646e644d6a557a4a65653372504c76325079416e62354971704f6a30595277537957465441346f70714c34716a446c347250397938662f6831716e6b5a414e48586461647472625a7a7035656c455a58524e397676505238696f2b437079643156765872456f395a796a784f7871774661654646783071342b415945707952303754547a5134664f5352623149654868716c546e4b5347424c3431696446535969774c563974576d70656e3453646662444d4352766c4179335779683131675936344c486a4b336b6333653045415850664b52682b6e534a7a394c433273386278787772376c32576c3476364d66506e61463737376d4854683465457932624b6b323774494f6f304242517146754b4e78494245417475613873325a4e6a593136573874452b75654a424d795344467067486b4e6a486e68446545435a344b656f68434863426e45377a7134495a694a574c7633626e7a622f44506d3849474932316c6447516643395345464771725733586a6844745331716f3975414b674b7547534c574f356c552f79526b516c334a4e6e5431527a79394e39693968335232356263796e4f673757795a76634d544c5157774357685530416d5430355053516c4a314c52416e64436466543130676a33664934634f30384467546d473556536e69506b67767875384e79747768613263704e453171473155785a71764772686c665a78524c306d7865547232414142382f644944656676644a6575715a35366a4f4367474f55344f313273326c4a6e33746d392b6958522f2f626471376f79383652694532326252553867706539463769785a415263467931656a334f6935666974726a5936576b527055384853694b4e4e3551326b69506d2b445059564354427761744471693557466d707076584c6d5664326174626967353632773172726a35456c4a356b4f4e72576241444d5937437750746b6c423443674f57664c7857496276644b7a644a4f70686c5258694b7a50363351715771344c6f746e305854563671514b6a674f674c775570774d4c446a585734515850737a43426163636844486377555467367370736d47454d57745479546f54446e4b44536d535645766c6b61695552716269413139706e6e7447774534613571646a387835772b4b367a67366332725377476571692f7672373338557878617430446e55596d503651307967597537313639684c39364d6650304b4f2f3857485376424b5642646c5957794d7a795551353859326e53566c497077647778617254534370457a4168627135474b6f6f4e3056553862344a7669532b4352787366325354724b454972487334526a514e3934347730786a5a4c327939646a7779684b41653062333064393362337846433276327935545858455a71547a4a4c65526235524f647255616a4d7968547a546d4a74385856442f59722f37776f34776f75664b696b6f394e544164755a4351682f43317664524e4d577571384f744d6a6c79354f796d4734754c4972446775734f4d4957437a4e4e784a706452495962396438464a67524c51766e724c754d54666e4870386f643075497a7064776e7536516f714b304955776c5336634d704b3633716f436f59394e6f34316b55594e44593645663254314948337250672f5470662f7173435049794f306e4c2f466b6e513750762f76436e6450657045335438344148756a3963444c51555768614e7539482b686b47365a55557a4157743278364330374c44392f376864435971354944594a56695a5944754b4651425a4c6c526b64475a523866636e5351776f7653504469704147595266306467654852306e7862316b4c68554b61717747646356575235506c712f75633157624a6a5779352b48763062744b617233497476525858316b2b564a4851456f567a624d784d36724568506f4a745a314c74677a454b7a3832466a66455268416d3155366576544f6c3531657572456f6f3679486a704343724a374275564169524f306d585131345a366268627143747636387a36714939664d6844714e57585136416d685066477a383653673457686b6d74632b615a626159794d56715047573551512f63645a782b3859746a394f4f66763053756f31504d32415a5030767a4b4a6a332b6a652f516f582f2f372b5236505745734f516c7965393057582b6b48694e55354f3136343034354663622f2f4a2f2f426f77786a6530636263784f44644f6a6751616b6a6750525530416d7a31325a6c78777277302f6f71616a713053626a6e49462b484e4637733539644161734a4b55555837524c67477a364756463272465375454751664a6470724571597553326d71345938394f377953724e7279704e4f30694e4c3072353830456f673048556332633236546f37486d4441596570574a643135585176634d6e46356d494f393478796e524d51416c4142323538413151493658484966694d2b44644c43736c6e62627a644c646a2b564f35704b792f4173726c51646e4546676b43424649346b4e737443316e70496b2f5862697a5258332f36482b6d4e6d65765578456b61726b4f3273673331314f6733332f394f2b71336665422f337953784b6b547a68574d6e476d683443396869584c6d626d6b64364f714570394238666339724d4b3338387272362b2f54775a31397361384d4d46677a70465968325376346231447a494c76706232374f53446433716c75645a4554674d6b56725177575661484e37636a474c65616f4e573358746361775775376a7133484d674f644b5375552b436c2f455a3554472b3144302f7279634634527355395344516f58436d374a625a7a326564596a692b41655a364232553271494e3155624965414c6656656f78577170686d6851795466504a384e3558796a4d6c6e4c6e64516c484849675977625639686345444453306f6746476b4f746f784e44726a7464346a684c673769662f6a39373646506666627a485071423757796e4a647838726154762f6551586a4a4550303948392b327a4256764764337376485067613173735a55423644524949643936722f2b3458386a515567636f50513652366c6e726b364c52346362595666474857787a555a41654a7878496830753134374b484d417943376e496c79686a75524f516c4c64527176464c666665586672622b6e775334714135382f4a38537537464d542b6a4b61524946614966575966447145534d366f3170676d71676c434d362b754c73735a313667616a4752426e4565445441757473414e61735746505571716870476241724a5768442b3366796e2b3536714b6872517833685962785a744b39706f79484b45547366326d4c4b6b4735624a78557536414d4142616e624b66486e6b442b397a306e6a394564452f767070584f5433494f474a413969642f58307a5558362b6a65666f6c47635a7462624a64494d4764486161585a67566c436c575738787a6a675a546a5a652f4e392f383938394e6a35672b7a6a36687233387746576a7144374847697a77577a49634963335733553545386f484462356b64336d494b6b6c73745531525554316e663770355677664a6242446778336b354a3175796b7239686d723674746e72315a62456a46506b4c6b6d2b463836383347427533685259532b492f4d5570386d323278484242535873464a424c616e3972477a49426436344342784f575376304931355a5a685279394e385670433541674c31386554616f35425a353878594b456c3169797067706a7a594c302b462b446630635a384c2f2b723339506332734e57754a515436327467314365626e64376e54373634586654762f6e5151314b644a74523832477179715758524549385a4237742f3963494c5168476359756c46304664785535733056596736796f4c504c536e4d323730435035572f337177687265556b7437762b662f6133584d767042476754516b4b69354a337a472f736e51614f6350332b655a6e45754d744d6f774533517871644f485a4d73315632374f45355a73315263723756534737594c5779637568464b695337476c5061462b6134584f69426f6d6a554556622b71396267635676472f52454331396a67524771386f69316534314b364b4365316a305666352f694533372b392f37546e727369536570693748682b73597162645136615747395159382f39554d36646564786f557a796252473361364d3843334b44637937662b2b35335334674632386a4c4d6777675a5a71705a5456753635473176704b6d796f2b7271335932724f794172645244326970414c62784f464b616b445549523268796e4b566d6f6866746e6239795334682b546b3565453046746a5531646e645931382f654e49544e7333716f63385372342b7a467844764a2b6d31474e492b61527057372b506d6a617334455344424779597869454f75637358672f7966344449486f4a2b2f6374726a64706f384563504b6a73654472367974675a4949784b6e6f57586837694f6b3247346f392b6270337666327439504f667630446e5563477858633952576d4961797138323645746665707a2b37492f2b674c70377461784130614b78746a70665a7249524b3551684d48436f746a7034634e54797053674262326f4f77774f336b2b78577273705651486b654343634a4434527753544b485646333130547a724e567079736945704b466575544d733265345255344f464352684766504d346537646a59694d54526e424754346e673449774a4e6378526d4e6a574d6d676d744e45384a7777544d69594c7079306174496f447070364f6b6e594a44596435565762322b71744732576752705432487430517669396a6f7937465544526e49315753685261336c764a34646f7676747a4c37314b6e2f7a553534684a654e6f73454364737030316558454e646a76364153645066654e2b4471494971645236324d34657463317750713430716e6f6d6e7946706d463466755663436f667069473067654f714e6847735a58624e43674e564f764b4444356c304a7a683941794b727078754b3550616f477a536b50304b4a32535341363341545368723359626b4e505a38447837634c3065755963644f523647444873346c4c4b78537441696f54324555697366314e714f7a454a6f664f4c4b7457697a4867766833613546656172454553566a6556444d5661667838575a32546b4544674b486c7657437951315a44414136565663326e586559696e367436416b6b34664f3078336e6a7845502f376c4b7a4a6d4734547a4764746f5a6433547435372b4552302f7370384f6a65375259486c4257375270336c613836705777515a7a6f37562f65354b334d746e57315971356b4e6c7539756133594b393154425355583375516d4a3032563356437541755778754c67734559424c6c36384963626d3674696f65547939374d784d486a6b73687442324d6f56786459364943596e31772f564f6667326d71344a5a747a48667531655866717a534e2f473031746e597443576a315074734c5654526e35497a534d436e4b74466d365a36594d664159327a4553476651466c584541616d6d6c6a642f2b443733735850662f797137544d43314c4f69555931473337757a4e77796665334a373945662f39346a31414f41373239766a5a53454c6266662f70566a67627944756c654f6242556d316276643932386e6f4b3071766e557769477a586a33505a38344a473062734368434e42454f66396f58345658467873496f413275755055535a6f597737456c4f335737504f6d524c566a6d4e596e3532656f75576965773559675549736f3974747945683458697432774630327948734c6d303956576c5553684f5174564d307262416e33493857724e2b79613770354744464d66584b7474667a3533714c52546f316c57463758324862742f443949776648364f463376704d652f3934505a434e716f316e51527232446c6e684650762f4b6566725a4c3135676f50383259654d4c4f395854746651724346643953326479454a4d3172474c2b584f597976386d67744b37617257617756557670354b546e4a5a4662346c435448445977726566517a432f4d535143316e37585238654d6e615878385248614a64484749516e666b6c7361315750714231386f7059554c7a6650477445356a6e52575858754d43564a513261516b4d75446f653336734f746e6d442b6b7471744c585665772f693174736d48676244776b4f7a3073577249635553746a33675634524173716b4b55474a6441396351696e614d7430773668347a6264666649345066574448394a6963344e634778495531326e4431326c6875554650665064377a4f73646f3731444178714d4a374a676431532f616c3564455955363258333566335577704d3135694958386c6c575776334c65366e596772316f3472597964444f674b76364a494b6c4a513546427770676e3070416553544d65442b3863494779795173342b3045425145455946714e6978647068595035586242784a6e3555467a704b2b304c676f534c4a4f45774933777062356c6f36354442536245504d615a6e4d55486e577247547a37366a7a3974534f506732347855317467743846616b47397259337751654d35536758706e7a33557352455a6169636b773555447a7654495842374f556839312f456a394e4d58582b48664e786950746c4737552f4a333576704e2b6c663245762f6f64782f686f484f3756476373517070534b4f5a6d7a36386e4e37656f644351483531475476636e4c6d306b4d586c70565577583649563276684368747754514e74753953723447394f575265517241417a417465506630633644374a4b7771787970364f396a42364d746734516453316146524e6e74752b76586d7472655278467247644f65674f78574331706b507756495051686568774f445062786433575356736c5546345571583362775132587641504b4b59694174634a6d6a6841464c51493839796e456b6f2b2f633055467a2f6d616a686e61474152537a2b6e5775684f394841762b305073666f7064665038746331695978793843684c72345768304d784e2f7a696d64666f2b777a6d503854454b6172377152506a64484e746b482b587a4c414e4d473135565258714e702f374b6875726b4b6e4b6467646149495944676e614b6d6c6e7a775647424756756646685a7553684a5a47363857564a475a4f4852414e6d4a67763645656361664637684f327749345534352f6a674f7235696646637776417757395175486d396e6f3046627359314d6e4a6d6356415374744e4c326c6c396d6f446e6c666850647a727372625764324c664d6139662b2b346d326e6e3553317a5451505769373067544871506956586838785450544d367445552f44594b4a7a525375334a41447853584a7332483172756f6f2f316d54424d5a5268685550766565643946556d5462317253687752486e5262567964373373763078424e66702b50735159364e4834687472566b786b3642423637633356626633617172584a5549774a7772316237566f426a546f6e734134436f7067392f505539497855344550414733766f6342574f44726e6a7a694d30786d5a75702b32476c6c4347625a32585652734c384f6f78754e366f675a77577139585362706b77304c4c7a6541742b53734b5643345261383452446769415546664d597a4b49354e7a34783738463878635670776c39534b496169577135575573512f6f76586337526c3471664a434158525872366e4344793943496a756a765762744f32626665397137704d37562b764974576d4763696c7068794231723170756f3663326153617672484431366c4266317a32686864594f366544366b4d6d4d546c583657615a35422f5a5066664a6f2b2f6e7637714e375454686f484c79756c31754d756e53516f4c6e703674784f36566d32556a58786c3159584f696e61327756316e34554832774b584c6b354c4441376f41475254594b4876583652504d4e783269586878506c315534695a506f676d70586f476e6c4461493754666d31725732322f726979476e4e4d6661722b4869596e35655748332b4d566f6d6e43634c5865532f73637a4a64716c5672687775466b32583254683568414d4c55387133707a72637064786268624d612b657267597a687a47474e68746e4c6d39306246774f76397863573647357959743035686650796d3730446f344e466d31613062724257673262672b2b2b387a5339647636434a4357674b50417132486f654f3278596666716e50354f7a6f332f74672b2f5474434478543575524d4b3648786f51714d626c707539327161575758677a43714b51727365426b424c4c7933575a782f664f465350466b55753357777a656a6b6363564d7146367364647770656a684275346b6d6a4e36527468456e58456974726a5254555a79434d4a736b716c616a566a42643759637a6b357271772b666d4b4a3934483863704f4162362f58517559316c6d484a6c507038334c5973585055724d38517a433432574b4b67305973382b666159706672436b76654d793361366d414562784d2f63557a4a7a356b6d324d76426451674e7a6b584341566d6f6b74792f5a786674334c3258627130684b7446424e7865585a44736638732f6d62793354725956565773664f717056466a717375533935576b375136386770544545392b2f77643031366d6a4e4d6f785a7132596e61516938776f7a732b416368666b6c763333345267366e624f626237374d4a4967675444737563593439756b71354f6134313058494d4b766a6a55364f6a5277334c4f5444306b4368725178545878623551383072434c4a6468784b573557566a4d4c77764e74446d30754e43536a686f704d6539526130707574526c5846322f564a3838514635697643466e3758653568342b43444577537a5a5267774c59716548616f3247464e683232734c6751466766417637796c706f56516c652b544a514d7442486d676a4a7544564748793077612f2f695a6e3944306464417a382f77705577694e56567269386364756335775a665a6b6a464e4d3346695131485a75495177315248425342346e6148446b2f514b4950335a332f314b303176726e6479572b71307975622b307577692f65745876305a2f3867652f542f33734a614c41694450427a73423739736f38516d705a316671787a705275697242313235517947625277453976455a746e55585a494e717367657743524b6d5a75524563753637464c53737241635335636d74565654686a515268646c5a7537774f59764379716d3073306d514c6f456d4f754577456e6c6f36753539706173726f41786371466763697549716c626763397866754e79736d6253717046304a3777576a5865566b6248787969597343704d3634622b466d4631654d7663394c596443324e764a33756f7469716c76506a6a547a784f563639666f33705872327a68757a42356d667033394d70426e51744c74316a675a766e66533679783175527871367935385030396530626f394a3337475a626f4156536c71315037503379656676797a58776f4f6137426772584358567268667a3739326962377a7732666f747a373458686c443363586b62694e593255765459464e696d51706259657165784875547772465447764446316e4763666f3651774369446278786f7449392f496775566771767566617a3446315a7866737962727461634b50567077696a687465417732413279536e31717a6b494e4a793269473079717078706c2f74683255754b444755796750416845766c45302f63316e63454a6e336f58644f47594a7446424b51536e314d48412b336a616a7076766c393431635578446f5a706d53717350324d4b63462f7a5650585676633364744e78302f665161504c68795459446f434f5449384c552f50303276706c4f51397876636b346248575a6d587850493376323076333333792f5647516573646c597739586a3277783934694d3566756b4c54737775793677694f45637a69374571447676336a6e386c6836586363506b436468653749696f4a316d305559735a504c4f6f3265594e2f634c4b765253545a31736f384f5a51586c694c6539744a654476654d4d45767637757131555439507144325342366567315666464253486e56444b504d784a7067754f414975417a6271437a6f4e535a317375694e313348682f6b456969566f457846506c51337469496a5154767856785575794772344477774d36585a545864534346436158564638384f714971696b454f4a70665a557837546b5452716b4d30305956766a46306b362f724839684a397a2f77414632386645304f7338534f3744583277674652567059583548736a6f77646f3470363761477a66694a524b443936386e44376874465568576f4536584f3937373050307a3439395265764c736e4274776a347a52584631626f6d65664f7148744a3878573174666c3878357a476844765736594a4431746b797a6e334c5a7331617a4d446d73695a46786559653245577066593862792b7553714a637666646435397345304f497062424346664a646364734b4374736f4a5168616d4e4234335a356547483151556a416c59722f69466e66783646542f5235505a4b4e4a5a4e4c496471537a697741637a45555938457158426e475341764856796330464b616c4c4e6d6d49624e5a58563739746c385543726e4a5633464a537843346671625845616449794b4c43733233442f77556e6c424e756c4855576778576a767a427155695561514e6530416e7230797a325a755334392b773877714d2b764c4b6b6e425776543264644e6439643950704579656f6238654134466d78756d57716e4232795341546679574a32314d6d43394d3633336b76665a63422b6961474f364643597842703738497a39583243542b4e30665055762f3975463363597a5761366c49505356656935335751756c6c576659314b554f4951724f766e7a307253584a6f4b4f6f3449612f3535496d54644f5449496570687453736e67545a546f6c35687051644448664c673152535a316f75776f306c32636c6a59504b4167316a5854394f43765a5247526b7551534656465a3631384463526e4b424f6c3345786750736257632b64354b5971714142592b4c517474746f6a5863302b6f6f754368594b71614f676a6d7378626f4834516b2b3163664959454461365251775747705459504231307473467332466f704d596f6677397a387359624637583841632f52426e7668714379446b795a77414e574f336e3536783976665a7068706741704a4e4374746935672b4e3865704b51334878635543776576757241753938412b66663477574e7073535175747744546d7a656d46316e624857542b6e6b4d527a5973452f4c63577638794b54576159326a472f4d333542516e564a4e446f68773044556f4c485431796d4d615a4263665a684857346e7a41706f6b6d61577141726d3669474850796f4b30796a2b416d7242497854437a572b5132465542524a55737430765a55752b69354d566758784d7739455a6b35303474764b6b4a3658756e6f6c376c467a6c52305572684e2b4464316c4e6c6336464c706d37504870516e6678516379452f6d4450465630506c48503273734836554a72413269584b5131615a35334d357161685552637a59624f4c4f77354b44386b71514c586235386c5533646456726231424c6c3679786b6f484677735072396439386c33766575345345624f32306a6170635742724a6c30306d5a4671414b75696b58394b6c7355737771356e2b2f35623637364e78354275794d713051776d30334a72316a6e393958466466724b4e373548662f7276506b5a31596370354169485a6978796a77306b50714b71484f6c656f787742564f627872574d2b6732547443336430647962734b5952557a6d2b45564d41576156396a46346239676b7352314a522f54696d565349456a79755870487051765a6d6d5156367778392b5449563758416850646b6d48675166516a79796d634a487a5a566278794149565532543079712b70533874783432344549736b6d3679452b5a4967616274794e727a69554a434c74624c43396162557a6578712b63625348426334536369436e627143492b3675302f556265706f746a7678625a75794569736b496552316e45336677414876676f794f78724b4f557a6a627a47616f74787050555043554d53706e58543446486f77712b6275637065766a393736626e586e695a476a655875616b4e4f5a527a6738646f7565486f6c51745836436e324575733473772b56595641624649646f6f374759504f7968752b757530314a54485858425a524243435761667945734e614b594e6d533458724c434b4b586b5953684e6b4e543974496d5433644554654a49495855715a3075354e36616335384f6938656c676f6c534e49794b2b52504c705267394c4739354c616d3846546f45334c556f6f54737339773061552b5565334b5a4942486c5a69786c7a795a32505a6e644775564a6b4469434c5a4767526a416a4d775066356a46415a656a7254426d414b676a6c44457244556e686a572f73454d2b716e5468786a4f6d6455446c6b766735594a4a72796b62442b6a7939374261496678746647777377786c456468784b4346547438627a4f6235726b4e377a6a67666f61392f2b4953327873434f654b42567a754e2f7a367956393638652f705070336e3370617473756a49536a496635684e6e6535574755356d416344616c79313768796c36494c6c45422b436b336f5556785132597839492b79466576543062484f6978734946475639417969575562485175703857735141674e47626c2b6e4b616c624164734b554245482f58765847717542364f3038744e542b54526d664258362b4f524e6b4d344431514277454f4a4e776c5167547a524d616b41544f78557a51316a554f6e466c67377a556874566c5249524a59487442594f634439322b4a42596b50454434786f4363336f75546c6d6d684d586b4b654e42755963624241684e3956467a2b59675a697167456e4333304d42614b56427630726e6538686336634f557576546c365233643946575266616234334e39757a434d7457627a55314358744f52677765734b6d3548557055327944377578673075763439435543757136744e56556164556a5173624c463259794671524f71455878676e56382b2f53337a4f6f5974716e6c496b516c56346d6f6c464c4e5a5943614e4f41354b475a7841757036586155634e4e3230595663755049752b6372664b364458466b4e6866532f7944414f4a34576a665646686437446145445676525a706b50764478356961374f58424e4e74635a5946384b30786e45396e4265496a5342336e72354c7176674d3948544659315269786b55722b4c65334b774f315845336a5553555a534e6c4d5934582f2b5662496f41716968724c654f37766f3466632b5342632f2b356a6772485763327372437579356e7a4c4a502b433373307045766c6c4554755a6871517057437476486d767372527049464f514255503055306174636f6b36474641506735324841447253383230704353706b56326a494576764563794d4356666871515649717a59725767512b6d4a793054617573304132683847785671785662466b7a4f532b6c3941373730464c49626369636c6d694e7139555364316c426735776a314953354e546a496758356250467063356c7271344948583273517637464844546f58467161376574644e7a4f4e6b6f5a476a47654776504557683254316a46716e613830646e71746c565953476b6975544a66346b4774573047617a526e2f37502f342f2b7348506e71635661443747577076316476465936376d6169795a74437a2b54566a35564f42626c6246726462736f474d57496f72324554623445376e36335753425a4b50726257646c4a4832455763705a4a65524a4d5a7a6d374e506279694b4b4b7038546c774a38754677696446455846513631362b725671724b68796876576b3879737a626464486a5377412f704874547844787261773035314f72536859744334397a436751416f424d7a65484d4a667548346673393933737a6151343133597a4b476d7148533271577245327a3742664b797257706c694f354c6735566d746155356a574b6b7357345450476659696f6b7937617a394c555278317472386665742b373666554c6c2b6e532f4a7a4d587831526d706f456f583247463179306f3954696a6c6457724c6d71696f396378466e705a4970386231796d3053674e43445258424f4c427579724e777971554f49554a72726c556a6b66354d41573477425168585470734645305462746448383143614f612b324a676858716f7930566243304837585776396a6b56633235627152773262673532754368574631666b65316f714e30367865516c48435a674a6f44764466626d554c466d373534686a71654f79646d4f485231746d72594d4453755a6e7070796b39746b482b4649367976426c427a6678533175564e572b2b663253514b62727770486a5a4d34493556614b46387634766c333034467675704c6b6e76382f34436b586655444735626f6c2b72677241383155616d684f315173304f6c593443374671364637376e7a41504d566767466747336d317370476c37462b6565796c466c556c6d3370764558344a6964544e49323156724837624c453679315371546845487971633671446e6f795a596d6f724772736643644e506e6b4272376e4b684f757a49546a4959627245555170454b6d357851423655416251535470315935376764597168486a683655307a62362b33706b4d576c64414766366d717964615664554659626b516b4a786e494f56494d72376f72395868536c6f3074537a674b4f556c7643303962675975342f3873306d646a503365382b4339394e4a4c7239505a5339636f42474c7234564c5873687143774d566235656141714f724657516443536b645a79516d336c65796b624b71635a53794b42327264764b33436839565669795a44346f75655968555a4c446a64636d5276333677554d737348304650616d7151686c71594b7134714a2f4c396d423343585a6342472b6a506c73466348752f72544a737852646d7963486a714649734354544e31633550637942336858634b774c4339484b38704a386633546671416753694f5a2b42754331576d4336316279484c56704253305138536c73393361534a5841765731632f4c636d74344b4d6434345230454e4778626133717233684f3832374a706647534b61496a6738317a5636353732444f326b6a2f7a612b2b692f2f634f58615a3631634d4d33736942305775424a57437172336b58773277723663706136756f4a3939726e654d3531723738534c696e76305a4f6475772b624c75424d374453743349707157383537766b73456c49626464483557455134346a4474756b664b72546d666337394b6b4d7072676956376f677947716f71764a7252704f4e4a7150414349714e54444d54666d3332756f525363424c3870744144546572664f554476654f74623652423733734e4475795154515a6f4249467836697a67344959683969346135335376572b795369366f346e6e54664654474836307479683170642b6c7137507a39674f3138667873625368776b6f6f4b5748726264396e6e41484a2f6e3367336e5030765a382b5378766570777a534845646f6d634e4d306a4b70703470335242594c70466773496c6572336c61697a7278704d657437614a43636245724a475169434c66634b47514b554d6c744c59314c4973457a4e7a6b384f41364e445536716a514b626334686d4b4359754a435378394c42755a457638536f7450516a4e4e444973576c443452695455353150332f6844587044556e6358346c61724a5762426b6676553339644870302b6635746a5a635272672b427a4b49645643386d42597449587542584152597a5a4a50624977446a3454386859504c6976675670316b5633474d564b43616c447a48567548525a7954744a717559636f3835654f526b307869774d6f444a686f5348764777512b6541484871546e586a70447a615656434a597a514e796b434e794a714c574162486848342b64796a4a4676356471307a59784a51336d4c794d633147484743416e54465879377173767835655446622f433668476b54376257376b594f387934624e514e364c4948424b4b57464d44722b6d51546a572f6b5a705130696461485a6b4539684961414b56737a685957462b6e61394657615a42596368594478743032654e4254747878304764677a51365a4d6e36656a6849314c37586a647a68434e37772b6e76685730504d3645746d31536c424249574374713139555375354a536b50386935694f4872524e467272537855436d5931775a66714e5545306e516d726a374c6c7a57706f59717a54505a77685a6976336274447534583536353176767032392b35786d41643157706b52444e744e4a3258425741646c6d344a4c6b2b4d65784645574b456173703878725348695175726f746c554e31334d6f545375694c554774734d463461564a43715867414e57552b6955316c555663484a5643755a53654c7a4a6c6e42615a2b52516977764b3642444d5a6a5949306b79566d6b61387759596c645244676147475a756458564e4b763668767a67333863545943514c4a7647746f6b4870527a5935794c4b4e41324e434d65486e71314a5378624654736d36745341496b57715336343759352b533436533277595468705646635547467475576575343847786c652f6c375666684e50704e6a497158457750783969324d5a422f2b4b454836634b464b643277477578746d643145476b704a77795454534a5a736c78726d59717554717652782b3766794c7472674e4a41524c44713976686d30595671304662415a635551526373427430414b425a34566779307a62705a63547a61504a4a736d72395546786866354c3066346d7258417748766c6d6b356576534d31375a4675694444644f4a674d51372b6e72706c4e48543944786f3864454d33566132656f364f745273577038704f6b43354267374e53754e51733337367a4e6c52496853687348684b424958374e4f30656e6c713975596f775a4838764b7945752f43317071665333484f4c6b7072413035554756525a44665079786437486363374f2b6d39373737676244394b355448736334575257564162766453444f4f4a516c445a764a6f79356f6d6e69553278737077777a5443484d354d63634a516a49525a617a574d306256477a426d436132685136584232415a44346b333934305647475468484c6a6b31656d324a756246414954685564677069536e69553364494d6452543939356b6f34664f53722f526d566753555745787853655636593278546245766c716230342b4d3044566b6d4a574b6a4b6471574b664b6d473564712b43666e4a534f452b327249617863364f4a6857356d7736796b626c416d396a2b3352556c46716b66495246592b6366427a62514a343776306233336e55306758664b4a73527449315462435a694d6d316576706c6e74586e7a6e4b6a64745956634e4a49497035724b514f674278494578596e664b33356a5251424a417557326c78454569447274354f6b436a434a4a494b726b3573456264645952477462656765787973584a6d6d4f6d654e62566e49624b555172444d49523749574a4f33333644746b346936702f48517a43697a67447a6251526c6a4c4f726a42484a4b786b544b6976436e307332436158464c4968496d67767556766735444c6346516568304542376a6f333032575763394e6235306f30767a6b3452713572664e4935623531766136734b656766535a624d76587a6b55465552594b38757665705a33515455736d6a31536b685656715a6a6243645268554f563744726b554970756253526f5a38776c4e7049474f6b58634a68636d713631364b786f6246702f35384f4e766c673256555a4e4e33576e4b6d6d44557a4d4358654b6d5842596b6d355330494c635464744b6a6d53344f545a7a556d3663365148736355546d4b374a69346545673757526b5a412f64666464704f6459465a3246375239474a6347557a6d69554b6d4d6a61724a58314e696e676f6a49734b6e4c567659365561526d664a6a682f52513167476c43386468647936536d374238583770764a4b56615551674c7a4249637078465646564950477145734b364159556f457a7a35757174414a506d31715255437365476a586e45723764553039375449566f774d58716d43565068414c2b694f6c31624e68726655424f436664546b7531696163333431734d6f4c415649624a57636439464c6c7365337a434146744b6339734e4a61484e4f5075512f496459485062515352496a672f42625330757953786a622f4e6659314748587954346d4c6f2b774e33646766442f313948544879494149464a6c5a46724f6e6b78653051736a635541336b645743446c6e476164574472765a4a374655315233766673565158564a7353556d7a7261376c756b56714a314a31484e384646656e435854676c546c4a6c4f35375344673972445758482b2f46637343506d4348566a3065494f36326469796f76467249412f653636514b71766e685446656f6b6a546e696d6d774c564f6c6169546a584d6a426b344638506f46534137655066626a6565366e4870424541676b49614358646651537465594773412b4f32416c62453362744c4f6d42356d3433482f586e5852675972385576513876455536425954725962665a6b5051386f595a47416830544479796f50784b7931316f53714f6a62624165537472397755426179572f33323736315559746775736c35516e2f756d7453677165556a67424c6257504442745751623971347561573975574f586132756d304c71336d5638524e61592f4547524b79386f376951707439463041547549506266644b72472b7157576769696f485742526e41395245706e6b6f71484962524150317754456f71496f426f38666a46544e422f6c472f66587036686a323653546d45457a754345614e4443556b493373356451335479364c313061474b432b7674377159303573544a6a6b73576464305856554c54454372647a4445726b715a632b412b54356f6b7373656668376a47445139713938776e4a2b73547269365834356c74334f676d7748354675586162716d6c7251565a66333170755063316a47493151574e754b306e4c36763667504254643755334b786f735053783561556f756b7478596170745934544a6a43505137564e66644f4846462b4b68797379474e6d51676930705a4e6d6f50327376546d325a487753646a5a652f584b4e5a71616e714a6254474b43754d546655577745416f784445553665506b584844782b5634694f3139734a4f633344367330566f436d7533746159794a6e6c494b2f4936794142746176616d484e704f5a576166526466705748697436356b766a6b72506e615074536b6532466b3854507a4c4c75634a565263525836667662335838374c4e65716a617135617456587353585467324966766345516f5637537a66325768396f33354e57777048387733796d44497768546b48344e704a513261534759576d49726d4b737050676d726c634a4b54484739574e394434556e305246514145352b442b794d465a6672714446325a6e4f526737347055534948357778743248746d5739392f4a5a753741424858336372433373794d7939506938626b5971654c624a68794d4b675348464e583562625255455339704c656c4a57774835363668664649486b6f336231646c5a74305837335464684f716c4543655a325a796d33335a6c7a6d4c546c7661472b34546e545572484a4a4b547058625a6e6130437550325175756a745a4c7851307953352f36386661624446476f446154656a7a2b4373384c787155422f725544576c4a4b4f6a48496143326161775239436558336f5842316a7562514e4a49576e4e76456559704d4938724e4342494877777354676a384e56585835636b75616177324537796d68595762736a2b756e7675764a767576663965326a6332516d333874555977767a5962414a59514844776a726a335a395a4e7443436d7279594f556555674b6a4a324e6a7633304759476261645769304977504835304f4c5569692f517042346d6138506b312b6659737072475a33686c7932424c2f444e5845682b6a784c497979474b6a3655326c6c6c4b456d2b3165504f713071486a344b48475a346a534d5358577a54772f773953723642524e734f41705141414141424a52553545726b4a6767673d3d);
INSERT INTO `etapa_opcion` (`id`, `etapa_id`, `meta_key`, `meta_value`, `imagen`) VALUES
(277, 68, 'nombre', 'Liviano', NULL),
(278, 68, 'valor', '1', NULL),
(279, 68, 'imagen', 'imagen', 0x646174613a696d6167653b6261736536342c6956424f5277304b47676f414141414e5355684555674141414a59414141426b434159414141426b57386e77414141414358424957584d41414173544141414c457745416d7077594141414141584e535230494172733463365141414141526e51553142414143786a777638595155414144534953555242564867426e5a31587279565874555a3375336662625a766b514134324f5a736f4241674a7638462f3475582b444242434167515038414a43416b5151434a467a42704e7a78675462594150755076654d4f68366e52383965753330765336717a39366c6474634b633334787231616f7a64393131313948466978643352306448757773584c757765665044424866397a2f4f632f2f7a6b392f763376662b2f2b3961392f6e583765662f2f3975337675755766336c372f385a58663333586676377233333375323852362b6e5848504e4e616631306b34503276535474727a757a4a6b7a57372f34334f2f3375374e6e7a323766755961362b59337a314d317666504937686438384849766a3550416153732f334e2b75796674707150377a652f6c4f506866397432324c64464f2f334f7766746e44743337765467662f7448472f624a61323348746d327a37646c58782b4a34727276757574326a4876576f3355303333625337355a5a6274754d786a336e4d64746933762f37317278742f2f2f373376322f38685a6350505044414b6533744433313978434d6573627635357074336a333373593365333366613033663733762f2f39646f4f646c326d633433382b4f55654648502f38357a393339393133332f594a75506a6b6567644870362b39397471743434393835434e5051534a67577a663146675153774c6f6b4273546875504847473363333348444437767a35383776727237392b61774e476379313938614366625a66364b4156414153514137494d4d706e3748777345356675646136554b64705a5074726f43364b6a4b662b686b54342b4f5464756b723958705976335271337965416534313039482b42414967652f6568486277662f323637394634436370792b43555872365362304b4e763045482f76662f4f59336c7a4737476f65427941695a35472b6370784d7757515a492b4571613267356d32796a6f2f38632f2f6e475a4e75435441364177454136416952546365757574327745424f456562584d666736513853686462302b4e76662f725942724d4a43473579724670486f2f456266596170534b37453578323963532f38524a50705047337958626f365a74716132382f2f4a5a4e716c6673626b41654f674a2f536c76394a4b75697167425773313069464e364f2b4d686245392f7647503337515677747178516c66623446702b683935384d726257582b74473456363137663750662f377a5a527248516b566343474167674b61796747746c6168574c716c6d7a715962544a504b62706b554e784d426f56326c6934427a387a7a57326f645a516b384a6b376c6437745939545536694e424c446731527a516e6b7832374e514a637a4839414a647a436944586c4e69486d46396d307a376a6f513347435a6a345a4a7a5578375851696e61717152512b362f642f3656344154354d7573476754554845414b4f6767714b424877636c7641745066716d6a717a6e673964643130383032375051506b6e326f4d503633596a6c5931537a6a7671372f69416548564272536a7277516a3152414d56454270646867452f7773322f513337554333496566366e48725168592b46547871735a7146734a3152385176444c584e726e577365746a6f6a6d6f423444567236746d34447a396e373756314641637447632f594c443055526a3574413336513147775a4f545567503073734f55482f55507a34776478304b61676364787158303275326b374274723636465655556a4f57576d322f5a375a2f77684364636f55706c6f75726451616a6d2f533561703239526745466f4343677a394655306e583671526453413957757170526751306a79645977624f6f41775759423758714d375651765346542f32314574583248624f43684c59563950625a4d633341707a53536e6c786e573336717065694c6a4f526578716267717433344c73427166697255386d6f4371337968625946462b344b6d2f716f30566146776a64594a476c4f48576c7765314c2b47423953395678714b6242315351614f47364b436d59313274496f41343649784d4d374b71535a4d3444744c764256543731776a4953496b364159725339376a48505736375230327046717a54587a44625a7332345936324a597877516a664d51304c37553978515570515074317479727261533977754c3961673375355474396250516e63476355584a39714f76625541596742466f42577336706c4e63474353376f774c6977416656636f2b5637684b5a4370682f72332b4363466a6f51526a64566d4f746b7952444d4b552b6c63697941713836596a755971596c41434b3571426d30443757787850454d4674413141513275436951476d6a4d747373557451356a356275617352476859546a666a627a5541767171676f727a64666272596a5345317a79756f73315647754e51756b554e4469683042775344675a442b6e48517a674e436c734c2b6c58564d5937636344442f7872742f2f56723335314259416b65494568635754534450756256326d305a536336304a555055716c724a3676617179475551747167443956756c56783970665a6c456d5136326d314c545356494f5a6f75555367786c35797a5077306d7146664e726262575165664162367544726f6158336f334f36774930525649684b5930647539714751314e47615953746e3652536f4833484d6931482f65704a7a7773586a7257734464656b31622b6859634531745a43667174453275414c71374e79687046342f653733664a57444e3651544f504f7a486a4a7a3676344a6857395a705031642b6a474835356c63383545734a49712b5a394442584b4b436b6763474139366f7847686e575961354a7245424a4c3976567a7a5656307a48707769676f43694a46336e49502f64446b56774859626a4d43353834644b794a5559354f427a55734a70436e705a5a6a356c6c574f526a39427748714f617832494a71514561356e5334414161437463336d324361414332494c444b686b5735442b426d51314c39542b4e526d6d6a2f4f6534396a61364a35706e696d5945696a74692b345636374b31465a2b4e363169304b4443385036615048323752726e366f767034397275434f6d6d2f3465627054332f3671636b6f6b4f72514e694a72352b65675a4b614e5347793133737842555a72316231613548653255796a53743037543165776b38675659777263787a4255634e55312b553854536137506a38626e74636a336169446b413141774e704c2b306f4e59326154694f306173384a786f375a6535752b73633965782b38433366724567796263434268774373785a6970654e56366a77456e4f5657696844566779636d6f77793878794e4245552b41784a6771762b4371666b307a6135396e504f61443966486771642b79687966357a75395653596263726466307853567950554c4b356757516455675253652b4b51632b76622f52642b63744f7836764177684e725a6a34376e674e687453326169754b494e4c66366a5846544632644732343439692b62304f796736342b554f624f737a4b50674d51744f78727061714e4b694b616b71743734366b514a54715a32706a304e396e59437166394b305363334e6e5074724a4e7941594f5841566f4e50423776584336714355587031584e566b42564531755733565046712f5a6c415852317037586563666d7771614a726f6d6631717a5754616857306c5247584c4952366c3261694e716b3934766f70735131593872324d6f45422b58412f4a77676e6e337539356e334b76456e6b4f3233453876364a334d6d77763675514c31796e7564764868555747567a74574a2b7276702f6a6e3673666450344c4f713478456852595451414c494b505a6a7046726a627a6c575832706c766e2f6c6e74624157714361414a722b674d537373536357736b6b705152644d6147676d63376f424c6e393646785641644a6b6235336b617334795a594b75356d6e366664506b464f537a4c2f4f6147553154544673306a574b575858394b42316f416d4f50714b70454b707236567377326d5330705867656a6b736e79707931495450544653544d7a7a2b304d33324e47564d31302f624a6f575455637a7a7176455a45337653714c627078375439426f71433479357a6d74653234536f666167724d476347424575766d55372b796c2f7a73432f573361504267574f6f63397a4955782b4e2f3833616337392b716d6b4c782b7873684b7354567162554e6a684b6e2f4b6f4b5a3256736c6b706e363339456d6e4635494b6f5243337a564b554d6747436759573139414f2b7a513030567a444937793330546550624c554c6e7a6c3552476b6957712f536d414256504e7764523455785058374d2b2b487958414d497a76664b546d727a4d4a68766164366e48367842775339796d7739496e662f63336f546f43366171455777694b41394357726c527a3776483636516c4e7a56384432302f6d73356c6c46573071596c544d775a756a35624a5a652b7a326c757942614f5834395635394e4d42546f5a4c734a343558612b6e4b646c35786d6457724c436b465449744d336b38417966594a7067717170675472613072486d31337966726f4a5257733256476b7466536541705849365838326771684e774667784d7338736545352f536648454f4446586c5363505654476744576661577554766345673052332b55536c54324b73477036674f6554346455447a652f306d6751326f4f41415670644b755839634254383073636164706b756c645356737432336f6d6f5079634556715a5579326f435a727a6d4a535a414e5963366d64356a57437677484b4e447276396e6a7a317567745a6e724e795154713251377a724f485746396a436e546c3852505a666e47686b30596d6e46446e4946717639724b544164764d78797374644467687678544f6155795a5271304a712b61704b357672396c67736f796d544131773470706a66526d6f4f4131732f344754704e6d4372746a4e56383154567042556d3170582b737a747532723858547966425055526752644457444f597071494656464c6b506b3542314e69724c35544774463139594272325a756636664b58676e4a46554b4f794f764f3270775a686571724a34616e42353968582f797535395732616957396d6536595779745136325071597337314a52364e4f6f386253744e647856475061373572793656653258797667742b784264706434314d53564d496651656a587a4e76382f68507236645472684f7058564847615075385a7252717674552f382f704f6f466c446d6b4d754b516870706a584c6b5041716e61714c2f72322f53616c57616f7956774266417141517563617270727641742b416f46486642476b316d4541727632642f4c30584e782f31674e65454d73616636757871774468483861424555724a6a68414f666a5a63374a7551354b6e304566716f7a6f6f476239456d6a3643317a6669464a4e307658384b7733682b525759567543616956314b4938303639617636756a3573397156742b756e38624b2f586a784a6b39676361543042786e793643332b5652492f4e476b5530355565362f2f352b37765774747270616958306c4b74634c716e676d6f71655a6c624238725532733434656d694e484e68717978392b394c534e45637a354770466e787153304336326d79712b597a6c456a394b684a726361316674713473764174745849737749793233566330734c386f66645476357178706c5251724d34316771303734665831583075506d733372726a75324a7274524370524b356770456c5a61726d62756a34646a714d2f6d4d49742f70744d746166624368447a56346636586b346159593668504955422f5a716b4d2f5678736330733654446f65306c443555546142537a316a7834775466374c6431434b727035787a694255563657527a62374c2b61326670585a6e424f6e38312b43734c53776a61323145634833682b6e427176555877316b712f386c7167384c6b4876694b5675595444746f545a2f6e772b516864585a32716c6e37314f6876446e6757376f65684c71787238764f5133394b785830324c3962502b315054394244564851625853567679766e336d312f6b3261394946616332482b5034456a734b52502b7a333976594a6f4e663670556263416130576b56566d4261673573716b6d31457763506c5871595a515a45506f534b4836556162344b32375a6a384c4d4f6d514c537648443567576b4456635a3733584b33556250536359312b4269674b6f304d7839384c54747a7a3430677a37374e674669306651574a484e4b79373637426d73474b4935726771683936474c41756a556479356271614b4f48674455315641665a71494a69636845776f5a332b394b632f6264704a517545763454763171576239703071523757685735765451564d4574716d4f666950596169646b787a652b7a6e744b67353275324a706871576e7a366d324d4b524d465668397246674373426d74724e2b367342713548623938354b2b4b52345a77594f6c6670387538482f4758476531506e674a52397278614156386164302b72735246747142395663414375334537363632394246796e2b71787734623555774c4e704575306172464a435076682b69384f69657879327055457a6e5a58766b7346722b435a3659365a4b4c51763355356770616d366d73413832716f6330716a4f51787234554a386d6439376a4b676b463363683757675a39304e6e754b68696131397837377a306e47717345505554554574427a6470424241434c41784f346b6d6830336e334276414e4d46496e307955542f42424733584339584a6e42725576734241486f48334e314d57316a3231346454413837763354664230436d6a53784f396f485543466f456d2f4d71524d7450382b577a684c4e594f6c45624c75416356394a707977726e386c574879696147724e39722f3030487975614469314c32572f5033634a574659364f392b6f544c516130554734502f7a68443575706779676e6c65347630303443716d703770645a646a7a30664e58646756394d7137716d6761577232764f5671506d4a4c74574c584b446b7a73644a6737512f306f542f3656473172616b337a5244723248652f567a4c3361456f44344649323877757a4f53584c48412f4467313077316c44656c6c352f54537256664252666e747158624e6c6f4a556e4d55365359753055786f4a62592f676e41366379342b30336561356d3443797335326878574b756133325a326f5842305766414462586177706b7a71704d6c653759352b2f4e35636a3875646137444374346f424562726344637a7574312f42615476594b717a764145623074586a2b696647676b616663354932767534566956516339667838396e6c522b585a7a4c3758764876646c702b7a6f7135646176546b566a70494945773071764d65462b75624b7067506a30356e326335794c62753767473448433144727836324b557372325377444b39556230613572586c626d627a4431614241754353743946415a6c6d72497a6e674b4851694c483065623165612f765372564872724d2f2f352f68726c714133644c4339676d6f36326462723433716c7851524b6e79766f6236326e376b4670794f5837365941616c63426b4a412f4e684b6e783853416c654758754371625a5966307569476c554344464d6b6e5956343670497a462f2f2b746362595769582f314872713268793956316d724e7277664f63673532547553684e4b4f2b67467261436470722f544d62554b706c7234483446516730795457534357446a72675767726164766e78584b3069503278586931434e566b315574324f3653515872544b7a576b6c787a664f79564b6a642f30416e2f34782f2f7548577936397564616e46484556635874504f725476432f4f53734f4e525261554650612b355377687647416e4837524c6e587776512f4b72674b424658676f71355543726a5762752b425939327031674e4571677364574251696c7538664d354b754d51314f6833616e3764372f3733616d6d6e6237596a4342743138562f4141517751594f756547315374666452474a39625045307a5856413533706c595863306c7a357a644b573251655049397148435968317275514a575137767a576858334e743077477171465959516f494b53594b4e61587a76737673394448423641394d6f35366e504f5570577a396879436f6631624c796f56596d6b6b2b666d524e51676d71436f6e586f357941633941394741337131776851733651454e615976376f506652497370536f4a6f6930652f317957562b42796a347534495a50706135425944416f712b645443356f36754e3178735049733874374468306e347a7a6d3357632f2b396c544d4e6d706d6745493051583567716c6f4c64496c75686f4b514848655a475754635374415541397449636d595065362f376262624e6b42392f2f766676384a6b7276796f43645a44357a56397a6b76363148595a4d7a5756342b4e6568504c48502f3778646f3774675a78476d517a31506e66746739362f2f4f55764c397436735831622b556755414b6b66425968314c796a304863303570393463717772435a7a7831396d64797447304b62712f706b30576c2f5a58414f7234577846754a3573436f7a6e55396462797451494b7267696c756a754775655679505a446f6e4f42653754663848454848743937373376653161414d582f502f7a6844302f396b494c6c6b4f6c626d63455354584334574e447670684b6d5a6d742f5a514c6a6f6c2f306b794445315a74544538686f54546a6a49664277793642655a39395866714650594174472b6f75775175767057383278386c302b476a56584d64692b2f3364392f38712f6d2f337a57756d3157527552794b425a6d7757526d706d645a6d434770453754514467666a75513366434239744b6e52356e655846514d6f376e6e6d4d352b35315173444d426554364a4d6f4865437365774b457739312f56652f646358426c4c6d664b413144646464646447356a597939503136444a6f616977664f4f462f74444361727155615a67714d64626a3945473445394c593941366d662f65786e6c2f466d41737463563756633653536735767966696b4f6836624d4e637777463442346750666e4a5439344952474851357046716369616f6141774775666d7355516d524565446f6b3771486947566d486e4f4337582f464b3136784d65736e502f6e4a4a6f3354724c534f75526876616f6f35634f2b6e5055486c513754313953724242614f684e3044484a4d506f4a7a3370536163724e5475754d705a324546672b662f377a6e32384370326d797a4d6e3243516f6a634f66334d4b6d34436f43466339444d5147614f32594b324d3156304e6b38693263634b555546575836395055706457562f5162352f31357a337665646746534b4b43757a4574637270345a534d306c3133502f74722f3351303774537033376e57766f4a4837546c373730706433546e766130335a313333726d42456b3167786e323146716d4d717939554166437a4139647868696e646271676d656c3566554747366342742b38494d66624f416b6b43696f566f5636415255302b7531766637734a6a38775355423354314c706552373870674b6372514e533439477543732f7a6a656f4346425668706f7135796d467054546555303176537676625a7a68686376586a694a437164764d4d486b37323771366a70357a706c486373706a45716b673049664465515651374258363274652b6467503074372f393756506e637937446d45634a4d4164576f6241504d41506e326e7a62366d6d6a6c516b3066476438434d45766676474c546475683464316f3333764b53454846745277362b64767a6467394a664c56637839432b63493062383249462b4a2f366f422f7449344149436c48796968616c67784532333531344e7469676e69354836744c703071585237755376422f666364397a4f336969727a4371424f4f66446a7a434638795a517477566465563675447136646b6e6b51422b4238345174663250793431377a6d4e5673396d4430306e666d584f6174657a53577a4a784d506d55682b397a5563436f58674b36696d452b756e79316649366446506d4568413059436c375264676276554e6e6641642b657843764a55574c72447446774a42415668475a5141454c59616d636846413631785a43503776696766332b4372764f6f363649665a48445339507174564c692f506e6237683861624a67454441514274384c554d46342f4173495a4471437a376b536355716576734533762f6e4e37667772582f6e4b7257375573744d347a6b765a34646d6e6c6362715946627a5967434876674d73383154364e7173315643574d3832304646517a4770316f396d44474a367851584e414e554145437a74664c4857676f4b5878754434484566477436554461424855484166706a6d656d6c51725955545a612b7a584245724e7049582f70574e4e3536546674727068716e346167596a34505567464858726e4f392b352b2f7a6e5033397145743076664f36647274396c6768464e38643376666e657234376e5066653532486c384d347268476174723479616956716d33786e417a5239376a393974737653336f4b74766d453866516e66626151666946494f4e794d412f4d6e4d41723243587a583758502b707a2f393657616d5a4f427158484d735a525474306837414d713849304b457832682f426f59324361476f747867642f7a504362425368516e436d595365467574694a64665550464b754e75325a2b39356b526a63534f4e435367366a69616830782f2b384964336233377a6d7a6477324b6d3534596461674947346e6f694758765369462b3365394b59336265636769487373324b466d65457355423759433261467a44683568654e617a6e6e55614c5a6d6236754e743951646271414e4e525146554f4e73774430323136744d45505052425130496a66436f4f66764e5239356e4e6e6735336d5151443459632b724e7271784e53635033564848687a626430342f692b395948507a4457684c6231542b6536525a3562594b556133764e6e4650732f2b664f48632b3355696b617949303951445952444255787148652f2b3932624b75643354654238653163316a3074734b4144773757392f2b2b344e62336a44427378446a7174456e314a38534d4a4c514c387a4472514b5567344466443261766b464e3441705550756a4237363641666549546e376a567438704e565367636a363979675834494a622b354a3556317a4c7057477069436345426a2b754b7a6c5768377033466f53374355466c4d417a58504279344a4f7a61306a76783862663952666e70713932666f4a4d4d742b65347641636156646147596534783376654d665765524b576d68544e684a55614f666b4d6d337331555344416a3337306f383368666570546e37716455374e31496e6a3648644e6e757072474d6b483739496332365956516143324a3268316e5372415a37626a55785434434b70333974726e536c70544f415a4b5256784e30686d474361775941316f32474963417859736658396145553268456b35506f4d2f387655466b3058436d4f564e6138574e3543726f706a526e7a766331417a574c47356a4f7650512f6c6839576158452f396a48507262373441632f7544454d47342b54324d35305a78664e6f2b76553157775567496c2f686970334d5a39745046787159594a6f676f3142776744384e30795863357236413530346e5a6c36363349426f334f47396f6c37702b3833692f575a7745517779634e707375713764677754594b324c2f784643786759596a475952556f6f704278634d72507255773564576462315838336253702f33306764716d6f667249766d766f2b413739664f75464d784458586e76754a4e33513552423834687567725a414f2f6965433677596858564571386565614b4f376a425643594a7878673067797665393372546745384762774331736f302b6b6e3961454a38494d775755753059757666454b764b7a4870386d6b6e6c643176782f4c553450635139304177774669665370337a504e594c575672795652472f6e75486f4346467555384e44584b74712f5331456641704a467a6976686b767074487a565667645a6d504671554c2f515361305474673955576e6272536e6b726e2b2b764f585670413651416a377472653962527349715145536c373643544476736f6a2f7a497a566c4e753643516157466152436359444c575854642b434543542b5032642b352f393747647664534331614333567544765031492b61625648637338485874356856376a72316d73344375733473784b556766446a374d726c74466c5164347772732b465a636932396c524f65384b33306c79696167676a2b757766644e4975364f544245555071334565586a69736875663757784f7273706c706957364653573049775744346e423948755579367a55486a374f4e3658727053312b3661526f36424f4e775346325570304f6f7075755347734e554977674967686d45384a2f37334f63325235374f394b316a4530773145784e342b495176664f454c742f6f59474f634273495071527634724267763669772f4e6465706275454a41457935775a454b4a376e79624e49444a4d4e7a7a383047466d76336d693653356e39744c4a492b31465836616d765162332f6a4770676e356e657a2f2b39373376744e6b712b3649576b6842747a37343876577666333348744231317135556161476e32704a734f653756546334776330416b336961675637596d79654e5772587258782b5552497a3137614b704b62502f3370542b382b38494550624d363654792b2f344155763243704351396878476b5a546d43787a5a7a33394e58775631432f586f3657514f4c51654d2f4151366d557665396b7034655a4d657a506642526d444a68564335306c644d4b412b31544933345a6754344e616c74765868437737417976572b2b356a7653725a4f754a47557a72352b4a4854347a6e652b632f7134316452304d364a71666b6b545532336c59324f304359696f57394f464e57487361456e3651422f374f754c6d6e76726f472f522f34787666754448642b574366515252592b722f5366615965476c3337346969556a5173624162307a4533666338654a4c77434a446a462f6c346a36697565632f2f2f6d6e4479753465616f5369314f754530665248314f4b6a514b4a5941436132574d6d6366474c4149676267637a637972543133412b777a5967546176656c42477171416d734371714369506c394b6a742b692b64445861434c55392f727031417079705a727877446a4b617565594d794f6e4e42313637384758596c786f502b7239366c652f7576764b56373679306330315630364e4f5663726f775649532f316748483245476e344b4376327a6267736c7a5475685079324c516f6b4752484e4352782f626779663048354474315468766665746274784f6f4e4d4a6c43613755696c67364243474e6f6c44624f73357a6d59767275333374477464783739652b3972586436312f2f2b744e4e366d752b764c65354961492b4d7467753754465a613539576d37424e383664476753415167443568346e56414c633143487930693072366b694c565643466731553333437961787167744b4c397042305878474d2f2f4b684433316f6f786c38634255756664595a6834364f6657376d4b3167417177454a2f5553596f61466d7347612b66565741756d4777665662542b6335476c554e3342647753376a54366c7265385a644e5132474b4970646e6849695447692f6e4550494a554f736c332f427a742f467a5552384d753449654a67494e50326743387443667a6d736c334a6b4454782f576b505143455a716967366e6f717455467a5a424c4b695844476a476b4736494b6b575848373055773178615377666856615263624d484646396d516e303255663341514d7761506950664f516a6d38432b2f4f5576337a514e715a34436d2b39757275596b74474f6332583370684d394d5854374436645a526c4f5957545352625233307454533574777866344b6141703042586664397366437966736b352f38354f345a7a336a4739694d45752b4f4f4f3035527253726e5a6d35457177454f66537931326f71356d6b2b596944704765776c5554416a4f6e375033676b554136472f5148357844487a7851736c796f3177335a32723531616636633934514a394a2f2f797754374c42476e65575a386666796439496b374e6e666241443972696739704d7674372b2f47384a76304539422f39364563335a3533786f35553273354b645a4b433361377a6d433844724c7773346e3870684a674336386f6e663741794b66544771727659575642555574525a2b4f4478302b5a4335774a4e466c4d6643667578622f512b71467531416f3839357a6e4e4f7731596451416d454f7655704855434774684b745a59536d72314d2b356c443444594468684472683358583153414b6144494b364d68567731647759587466354c7767304d7a71712b6d5141792b5858302b4874477837735a392b38345855556f6d5a6f6f54616f7470704d6e6c46766d55666666667149766e336d4d352f5a67495547677765595245796b66585a544f76714774734279634452344d6a666c326a6671352f342b7457354346787235434a2b2b6e7252302f5666374c6f6a356e65414a4b2b64655a74514448726231656b534756507269463739344d3032715a4337536c3542685241425554496451647742526769715272677a6f2f6c4d796d7a6f42453077474e45534c53436241516c737957496a492f7a7a425176335568616171526e4b477655756635397956514f45377a41425545496f32585447677a314f70724e3868514e5232677070384841525651327553436c54376f5261734671693535483645694c365346766a34787a2b2b3155732f53563851505a7644736e374d4a574d696d4646346e447833615979526e6741486a4377496f4f38776e30444e647738325971322f56594531514f4b374b526f56424f3142552f724d62317332345a362f372f5a6f4b424a373345676b523450543333445a4d593466344f445435525a65353335597a5153336b777a632b774558646449573670542f582f337156323864347a6f41786e5647594e5a6a784871317152714237624a677442335369684f4d4e765365416b6354534f6c37625878574547486a48457a2b3870652f6641724d75577168557a586d712f7a64556f623541416f2b46464e6f6a426b7a68532b4559426c313251377445746b356257584b77397969744e4b336379384c61494476426f6978537441466e684d5553592b6165694e686e37696563376b55666e4f66574a53423834666232492b4f585364517a6f44497373736b6955746a6143713042714244386c3176704362536e6d736d4f6b746535437456665a577653542b6b453341425046512b684f69627772675751504662337778504d6346704b734b4d4e534143434167454177645931525361445531416b34654f6e392b6f78786d4a54333371553665506f656c58716431714d67545868517458507644525a43742b4368726e2f65392f2f36594647622b724752676e326f6e325964374d6533576c686b4132364f43386978756847627a444f6a52364a766d744270392b6c6f4b6c31616f513277623134497650784f784a56487038446c744e4a6c73376151684a7055674f6e3261346b5343694d796362585246526c656e334f7351584d376c707541797a4153324459397149372b3537344f44315832722b2f45302f7131474d2b3350785033344c594d4c4d473832354c5543666c367a2f56504e425157764144476a7969553938346a5136363372786d726f4a724a596d54436b776e4c462b3859746633414942393846416f39426e3341487a56556243616952706f4f5a6f734e476c5366614e3835684f424269516b522b6a4453624d385a5663416545306a2b764131496264444c674b77366d30715a6d765266674243703152335a7446685546556148694b366f5451644d497449493234424e4f4d7a426f5a2b576c55687061453857684474425761525931443661362b4e54467459375a5833386848757a545a41676f476f6e4852674471332f4762416f6e6b436d4a68706159464755614931477758506d544e58376b516a446678736967457a424533663835373362414b4c5334495734547874366c51335032513770556d584432752b5a4c4a67684c38494c623473774d5856514b48774f2b50436c32744b6850594e7746624130665852397a77376c6d756677364b34395241566f456c636f462b545178344a7a654a794462524c5139574a35416d73435149476861524155416a48703842324947716a2b6d7256696a4a707a734f70345369757159656f394874714a453147742f3157472f696b73687568754b757a542f73596c586170733330706b356f4355477368554e4434586539363130594c684274426f333739513636444c7756514c5548587846453055544d5a322b49543377697963357559534e6f3170306878715a515063416a656a7366306769364e53756e6b6d6f736e793262632b5954424b596b6945522b4d6a6b424d4a4d7a7043776462395839495971764e4241686d785732342b5336596e6443322f566d485574676f554f42716274336444733249475339682b6d695478504251536b327132676545445731694a4e55564257704774534343366952376b3855656e45667a762f65393739336d4156305a51482b674d384a7446493167614f5a58776c747458534358586850636d454a4d49483141577a4854417369676b34424759786e5a6d334a705066714b31756e4b423748447778526e6a763272493653354b774f366c4a6343657247356c55616c51714a3063493232356a584e696141465953414542646a6d6b6e77557243625565307651536d644c6b3570713352373663535a5a6d373258427235325263645530426d704355345a625a304353733370633446752f59536d526f435a374b634e544344354b6b79674b306164776c6d5a66636463545755435736336b37795976473058544839667a75306b4959434e4a69362f4e4f62515866713962674b36415256316f4e766e5647597762627a7a4f592b476746396e4e47646e353571577357456173426a2f4e346146504f6b346b7843666d4161595a69637a4239502b704251766772743832635769697450575653453071466f444e77674d4b744a4a374d4b6a74364b2b4865374e617230386c3952463254546243697339445468436d2b6c686474554746706f3735704b5048544662764874496f726b6a51464a4c536f4630304f702b30546349584d772f4939456c4e544e63796c6464713955362b6239632f654f485363345546517a765674555564534a2b3271594e65594c61756d6f585742594752646b3241305743766e2f564a384b59324b48314379465557356e4d4d303574646e342b676563366c4b41336e36522b526d704f38377372444155507370306e4c76704665594f766a6f5458304d5a32574d6e50756a45636e68617568577853715872654b5445335a614c5a7067377768362b4e496e4a4b624939316b327365484f4e52474d384b315854563633307530525a59495a74632f72327a322f502f68426a647a4e35627053506f374133423572787674742b30355062494372642f376275506d65526f4d6d43507176584d4e4f4b574a586a574d6759434537323538706b4a3858374e506a3975574b527a33587743633345387579337039457372633348516637452b446841597a7a616b35506a57787769423969486f785a62524e6c496a4734687a3770584574415a752b30794665554239354e6b48565350544d3857434f566f78717163396b3556584c626251446d2b726155756e79737a3550567a6f3034716f35716138786e5850394333326a4f706a564142317a7a66672b6a354c624870494f57447a6e584b4a537258386f4941714d41733746684a684d7449586d633237365675316a77464877642f7a314a77732b743735304e30616e6345786a3046385749504162437a4239487250762f50486f654b7744594e35353535326e2b55647065514e35776a4b387a766e55594e4e4857576b4f427a6839726434376a3762744930376530375a5835366232584631625237594d62682b6e2f794d6a6c58612b347763534565757675465965706a55694e6551577a49374a684c4a4d774c39794367776d5562656d52513354566248745635634c61616f5669477071723633664b6431636d55454f437933316b7065385a457563416e61434334374a77776f3037624f73687a6249474b69564e77472b754c56373663484632755953766637545846476759382f523948366e4153596f5a4f49683046557a546e4433336e6d2b2f7a6672544f6e4c4e58577772576561785472764173784e555453354850686466656568362b42316b74313374634a532f3038545374394d304e703355783754582f4c2f7163576c743170663765544448744f533643507a4f2f4f5052497159524649672b482f755a4f32386f62526f347071304259464848366f35756852456e61685056334f756d4632473151544f664d706347395448714f7030473033557365646f416c507a56724d304164424534456f376c714456594c4d305879596775374b44372f67697668524134414547704c5631647436796a373858534935525838706c526174787473784171655079752b44536450764b4751536a79354172654767726c757667592f6c79434238376d79354c2b6558476230624b6d75744e5752306a376a4a784c2f6f6f6e534f79534942716c554f6d737a344152576d7654365a2f4e564d4b5865636b7335574b6c522f6d39366e426d705a6f6e31666d39705177673348396e474f747231506d4e6a4e74644d6f427733586b76643832653079337776393776754e5467376e7941454178676531794b49726d30796b6a2b3037616766566739424f5453474c637363772b655438374d464933365175756c7a3950664e4954546c3432506a756e314a555a307a5257616c61706845595158714d4763717169312b6b5056437274693643707170306d746d6d5267734b2b642b716c477446376a536937496c594775744b684339326d4548552b55332b7837796373666430327532624f31535172675843386a6e552b4f4f4c76396332345671324a2f395a587952676c6d37675669435373655234424a39344643474c41766b6f3355777a38546e375043576e617650575757336437662b7a535970334453754e7173424e415856382b56616a7a6439574142656e4b742b4977756e4f757a6673636445452b4a62687231467433415648544e6e306f5577735556316349306a356456415a4c6b774c4f373336717851717536585a3048494b6d414a72617a664d7a5832576636312b615933503861693741775948765a4a6265766a706c6f77445442756b5331376d356f7a4e706d5076757533653362385a334d6d594f7376354d47644b6c73464e4e542b4c576a366f2f493948616c6d336f35335142587464526c5a6b31303571464f6533522f74696d35737655676c72452f6a53716f75672f646931536764346c50517275644b436e7871775737384d526b2f5939706873694147706d46526942556f477661584f7a586d594c574733613636596c6f6238756c2f5946443443574251726e7a312b2f4f334e734934386362484d34553831365464654431357a554275746647426b3155646b4a5a4f3531595058485376524b745953656159484f55776e55676c66436d5050534c44733267644f6e6f4b63326d437370766361312f44564e416c6f41466e424f594e6466314e38797a39553661695a587072462b586255387a6e654655363076626179664e6a574c354b58344a4c58696467466d41656f484b2b5134375a705363325a6734366338443341384e33546b4374416d3461706557374853372f55437a413550734b6e56564d6c71426b457175427a6f6e4b62706f726143766379566150554235694b38336c747a72434430535a6943656b61624d784c74346a767235333649374e36716270526d7573594976412b72384c6d3953336d2f507a5658523065584e705431445348537a353178366c74715a6c31584e682b553848704e7654526a444e522f2b33487167436a53525144757a756959756b6538623433744c6b50533449392f766e75336479646845336d645035764f397a522f4d7236546b4f3338424b443353586a2b4e346c596b4856315a346b324857592f7136456b2f4d7a42546364657a6555556a2f6b6e2b317a56373331747133315a766376515945547a303977563962696e57414550454c68505948532f6654524a6e3071654e4a504f706869344672437748456241646a6c5067775a357253746a3472624a57614e336333614d6162376e2b6c537a6e6a326d78584679374b686d517841345256476d536541567948714e306e776836386674664c5666462b5831576a564a67584549585056582b4f3571304570706756457a576d3357694c5252596a5058547276555636735a6b676b4e684a71374532774e526d796a5046423771363236585861444b647672564933377765714b34414f356b74623959737350316c366849636c682b5749465a785763333653345a525874614c7164396e46636c7276762f63644a5643696a44624f4e4c4153593063443063376f597267795136506f67726773796a61464764474f51356e785530775870424e55456e436b4a58344c557248574c6662572f436f6a5358776539666c556a352b357236766f734265487359756d4e63352b615141584a4d6e4f4355384f715366792f6965485370576b62506b6b7834414f5252516349354a7655797454686e6c6e644b596a7a5a4f42394b77692b46766b7066432f71636237527034624966666b4f634c4877554b644f566a6455657054696168556439674b6a41394e666b4b45466d417a564478454931744d337a417375546154674c4e47625336726b452f4b69387563796a786e78546d627771512b6b59476d6d2b3442462f5363426839514b34424a32706d634b366a6d663533694e496a5656395558723535525074534b64463654674c2f6c65524f6a6978694a655a33746f4b5954446c612f554353437033346463615a2b6e65536a4f4d6662646878554378373758647459306c436b3145596171396347614c70425a64556f7279524a434361364a4d49436f644e764f797439784d4678503243756f366838312f2b4e394e546353326a6b784e564e3974656e5171386c30465370674662545a5477564b333858665a74546169656447352f62484b4d34556764475931367052504b2f567341362f517a504e647466572b39696450686d4163384d324c5150584d5837795741596e6c325553774a517173494f765a44766f2b6652483154466c526f6a365a6c57544e55485736385372444f344f4a74567742646170564f7a3370342b6a6d3879554f666256647559636d66647a766f76736d68356f50787675317864633061726e5a6a48534b2f6a39724b43317a775768453972774131506376666162464b55657a4a677a4143374e38545573766c5049514d6432565236364b5334364e4b4b567039414d2b726c3075615a366f363153577a552b4979692f31796c562f6371676d70595a38733839454a5355677250525a58326b67726a41346e344943694639414b4c523668794c5a6b6451394745482b755071423538794c6a425871513031694a71372f547455616a49734e6666536f53427a4841704c493965756d644a7473573947696c774c38372f31725739746a72724337574e766d44304f4d75672b696153324d3170757843665158446e62784b3430324c5279742f497067656f4953745361514a3361726e74574172796e5559394d7357456c70424c72703332784c6476576e464b66496257547065664f5866346175344b43496c6970617a373832744262634f6e7a6d644f785076327571636c3754634654454d33676f3435365634625556487574576f376635694e754d7a666c2b7778647a574145782b3847472b37496a4b504f764344587536656f6531325932384a2f425552752f655475662f784f5062373853575779425952755a7162304647426c54684f4f6e5637782b7752643758476a545a6d6851797254363775706556774c4a4450565043622b4945427a5a76564c61764e7473366259385371394267794f3079797a476f49362b7568592f61667041363641566366326b485a727636643256324d316775337143523174414948516d6250694f742f427253394e556244304b7845324e335054334c4e38686779383736583048554875374d775555484e5a3076516944314d596e732f7774626d6f436277535a7a71744579534e41436c64766c74486c394c354d65735359483255715a71712b614f437774794f64526f6343466f4a61332f565a72597a6861794f66384855434c443570644c707a4567665648416e734c7932795643465a6d6f3849326f316b2f34702f6f2f5051444a4f2f534374683261383732773077745868647778394e6243616d6e59427130395a36583563386b4e334a2b38723143615841453363315365797761596f4c41576b5142516342576131584c576571594b4374494741392f764773455a76356c5a7379392b4d50677347787a724230776c76563056342f55796f547565372f716a6a392f7730385258474663414b794f6262464e6a57532b6e364e756c6c2f36474e576b356147523061586672306456637a644b714b4137506e492f556d5335763572345537747a39374d676c64514d78456e7833706e47454a336e6d2b4172532f646135772f6a34315868336b6169452f79354148382b42436953366844594d4c7a753737566141346531444e5a4a536b796443665759476f4773587674696e4e70752f70574253364362674b7a685473336c756672653337615352706f4f62364b3766343142523650665834636e4d73476e307a436979674d596b6b546b75546b7a3466673947646b4e73784c7970427070524d36652f415a2f356c5a726f374d5333526d6a5473395a347a2f334b6f4879583230534b5375356a4d663657385a727272723552457677744f327979445a39754e4b6c645238675246365668665453334e2f7a4a654539616f7576553241716330463967386c317265484a6262652b7563363638356b563472524f6b7369554c71574b2b37626e2b7964304e52622b6e465a58425276664935706a6d646a71724d4c6f4d3831413671634b64504f6b656e512b713176576343656a4c4b364b702b6e4833706f734271507a34684c75656370466679465949437a6c4a6d396c796a564f38723647725371706e526c767145464e4d467a637058672f6537774646546d596e336354626e47506e4f574831765434576c46735678646777566c6930416b39465678565672307a544d394546396d6d714a6d706f43743947526e576a55566544316537575a6d73356e35695379456c684e57482b48596e52566f5241457a614e356a5a6e754d716861664d373946536a546e35717a43447255336c4d2f70545158634131364c6d334163576b2b73672b6b3968356e4e444264354b7863422b2f723574424d5249527551694c745a6944586c45344675414a784d72626a66746d52456e2b4361674b6e75776533675a55324b6a4261372b706f6e6650614a6c746454744969344c7330313079304d2f33546a4c522f48656673513031706d61722f496a4d45366454756830727058755a34546d3146365778436f3852714f4c5370352b325464434d5035657639334875667035313939652b30486b3137644361674e4b6b696d4f4d3863397a687136614c4b3247546d55567043645637573066507a2f423548744e48713839547a546a624652427a6a6c4174717a62727a73746d6d54734a58722f766b466b394f7272794c616e31615472765a392b717a6176427179587264326b436d647654727745557046766d473274317a44765a6a556169734b734e597752383345734f304e544d354930372f416c5966617a703531492f4b782f71446d68617a787a2f4f65564b6d5455424d76326b41737472566d487a31636f564b462f38583430334e59786771576c5658613830385854734a5a784a32523661576833646274436d647578367445624e42644163512f757a417178303762777278545651767172464e66634e646d52322b2b6f454f372f354d71734b6d45436f6c756f794853304570537457624a4f394a307a4853504e4e4f42335531436f726a6244796e2b6f762f482f4c3148447a2f316b6d384c71376a4a2f56647055734231334131612b782f61376a71755450755533727372314f456255664d307175466d796b584842316e2f7a3263593672397a59516364367a625454597144424f4636542b733172586e6253623132792f4b68796e76757878517a2b725a4539316677674d4d2b4c3762344431333554704550665466713336556841307370314d616a735372384361676a5164624570397a674b715a645a5463396c725a76395872734b4b4e76577a6d7577564c4a307963327a56584b576862526d56576d645876505336343537732f6864755855342f37706b34585141414141424a52553545726b4a6767673d3d),
(280, 68, 'nombre', 'Tejas', NULL),
(281, 68, 'valor', '1', NULL);
INSERT INTO `etapa_opcion` (`id`, `etapa_id`, `meta_key`, `meta_value`, `imagen`) VALUES
(282, 68, 'imagen', 'imagen', 0x646174613a696d6167653b6261736536342c6956424f5277304b47676f414141414e5355684555674141414a59414141426b434159414141426b57386e77414141414358424957584d41414173544141414c457745416d7077594141414141584e535230494172733463365141414141526e51553142414143786a77763859515541414b4161535552425648674254663048764756585568324d72334e7a44752b2b6e47506e724736706c634e4951704f484351777a7843455962427777426d786a6734554e324e386648496d47415961634a7a424d554d3571685a5936352f5279546a666e652f397231586c3876382b3272423731652f656573336674716c567256645632466e396f6437747273422f77656744552b662f61754c36776772577a6339672f464546717541767258682f2b34316575344c3475514439317044754f65715746572f4d4e3348395050794b5a49467074447a7136592f41475979677672754869637a6477594838493564514173755579667561724e2f4742666763484d3337632f2b677835473873344f796c42537a3559686766434d4e4243345653433857315045364d684a43634845584448384f70633764773863344744765535364134467366656541344450692b794e475a7939736f517247793330522f5233595277344d5152764b6f466d71776c767334586c685656736236796a58473468484178693337324855613836384468567a4e796378637871455930476b496b474d4c5737453231664235724e4d6a6133386e6a6e326977637235667245734148396f38676b6b366856647a47625437337a626b38317570314a474e386e73454d7071594730413647344e5261655058714d7237342f674c32643758776b7763796145516963506a39515938445879694175712b46514b694e5a45382f504f454d4b757462714255722b4f6d7676493837755159326e545a4f4a4c333432623178524e4e70654a30535a6a64623246374f3468744c4c6279793163423475495850544356775a444b4a65726d47322f4d3564504a3353693076597030785449373149744a73772b4f70346454706d33682b746f615a4170664e30385a6a7731353834755149477646652f4d5a6676342b2b74494d6f47766a416754353044764939716932306d78573038316b554e724b6f5a4376772b6976387241513670767267536154785233392f4557695845577931384d51396655694d6a4d465461384c6a4279377a2b3936367551346e2f77755074494f65466a654448396a326f645767635456712f484d624d78656d4d59416956676437385263767a2b4e374477555168492b6657634e307859503737746d4c4842656c326e595143507268387a7449704476514c7054527170667778764d33634c43376854764a41637a6475596d3768744a49645552772f55494f42527277726b4e38554938485a5435556938385143416267744371596e7136694e37654b6e6d4d54754c795152547a5152444c736f4e35736f72756e42322b2f6341503557427754427a7378325a4e47726548466a615563336e316a47696436576867374f41596e464557683273445a4f3763515357597734577369484f2f414f36647634506157673732487537474852684869535a6e5a727544354e7865784a314c4134614e6a714e61416c66563164435743714a557269435754614e63626550764b436e70472b37463771417344592f326748574835396a7a6566766b57656a49653744382b6772595478467358627146534b2b426f66786f426e774e767059474678537a38664d6467496f46793034744c4e49612b524176333354574b756a654a6d30764c794662793850423754693358384a466b414d74383339646e362f6a43683863784f6a5545684c776f7278627756322f6678682b2b75594c766a7a6c3438503455496f3658787442414d352f48536a434f50587548634f586354537875414d4e48526e46774f4150346653695771766a6264326678334c734c2b4d5837496867613773483233436f5774797149646965786632716357372b4e35584d7a2f5045514f765950493542496f6b6d376142534c794636356859432f6a675458594f625362525279565a53342f696434594f6650546550464e2b6378636141544a2f623077536e382f434e746637754f746f652f7a4964723136746f7734396d7255626a7147503239674b64574247334e766753677834345068397170544936687963516f61636f3570716f42514a6f2b64746d4a426d654d7054794e4c3447576a7964333378784162334a4772493854587536417267346e63504563416643305368504f543264347741307249445851593447376655464559754855533057384d77724d3967396c554c4d57305571476b4f70574d4c635842583350627962586a4b4b6574314c52307444703764727466546e4f6d3564573859326a576e2f2f6745346e554e34653359656979302f397053323865624662547830377937736d2b716d462b4d4a632f6837506a2f614c5163686e746f584c793269644f734f6a687a6f7765786145634e645356544b4a557876314647703176486b79516b454d796e6b386e55615743384e33574f47352b57365854712f674c392f3652492b63354b6e5068724574645531504c36374338584e49703435765948766f4a6359334475495369414b78366e7a64447334543439373976556265485138514c665a6a557472712f4451387a75314f74356271474f4e362f6e4c4839324e637357502b4767582f447a732f676f50505431663239764574786b5661744f7a3248656f45335376384f54796145593738647a464654783266416939584f64473077636e46715a44434a70784266693974577757763057763830546e4a766f7a535a527a4662792b31734a344a6f7a4143672f5867364d304b49616e4670314d6b2f75546a74445a4f484138415754767a475031386d563030556e6b4e7a6678787a65384443412b6e42794d3466376a5058797642422f46442b38763368313975726930694d727142734c4e496a312f6d4b664f7930576a74364e5879544c302f664e6e4e76426a2b33784970454c774e567049644b54674e414e636242716633342b6744776a7a5a506f5a4f7279524b4f6a4347464c72594651422b674c34462f2b77696f2f73435445634e4e4450445648597144476f426b49684330566354545335694857477279592f50307033486f2f453064767077322b666d73644434776d3659336d7a4f6f376473783974476e4b4478754456536557764e786a36576930614d7038357a752b506453547843392b3467306c733450325a4c637a5357327a5461337a5055306552544b565135675978794b484a353233724144464d5652673642684a2b52444d3975484c3544743878424234584e4f735635427474504868344442462b72706348713136746f6c787149704b4b752b69426e39305635325a4877766a634e322f42567976437777687759627141393162712b494876505959454463636644765033506167323357667534794538747263625a2b696872392b5951356a6572453376332b4b69504c3437695138654775535a38364956344b486c786771744f507863443963572b544a472b794f597062642b392f49792b6e6f54696e56304548586365396345664b6b4944326562373957416c3537567a30335377666651433761356a6738644773434e35525a7554692b694b2b7242306e596433356775346b632b7470664745655757744f6b463362317850467974706f794d446941526f574648386537706158517969765435476e687073596e7666626758766e4353683957787a2f634f72705365767362516349326e38757658737268416244586879664d6c4936687845584e62425678624c7144587163484830356b6a44764a32707448777472472b58634c4e6d797434697966762f557672574a68665234614c366b737859444a4f6c4c6e72315659623437564e70415045543353647957514d4455384558712b774471327179654450552b696e7154574445654b4f494f6f356667635831326e7a352f6e335358385469316b2b4537315a744c4f4c69382f3335656d5274347677354d706e6151337162533861646359782f66657744392f31306a49435365436e3775334845454e3176472b594738715136396676746d6b3450416a4562566f4d475358644143494d6d5a73744839346b546a6a554534614852704e4978644462785a444c3338317a512f6b687142667a2f4f3057516a53474a6a6536775955663563462b386359367a6d3378554846447a32383238622b2f5a78652f6a35356a6178763172527a71685159395241484e5370554752694d6872426a706932474f42764c436a5456306859416f6e324e7173705076784d6a426c38317543706f3055533555304b71552b4c3538626f624d5372474777585155332f5038436a593274764533563471496853493451634d7162684b4f3147706d714b475548324750764e3236685854775946666f69615a474f2f44736d5130636a4254684e4a713476513038636169483678644575794544624d44444e6264547145586e4d7a68637133416b674b6f766a4a737a612f425647476d34586b31612f5768503074626577345071315037544134776b4c586f676e767032437a504c4f667a702b3473345873376a35496b426e4e6c7159336c6c4451385068665138384e475672786271574a6a4f5933436b48774e376868464c68666e426264795932384a72723931434b722b4a4a2b356e714b53525843727776312b376a64304a482b4b645355526f504e56614365574e4845393946514747765a5769462f4d384d52482b39774f394551514a33504d3061432b71654f5a474868314242374577515439445744695668702b474d582f7a4e6b3778704a3766396d43576d375576306362333339574e354e676f77314d44617a5445567864765979515978613246496a36775a77533955344e6f626d37682f51747a574d356c6b61665861784a5944394d5450587179687763707a633251433672684e31363444466e72686850474c7a7a636a5868584270734d6277747a5757524c465653343171314b486631644b52772b4d51682f74412b3137537a2b374d5872654774706e59594766487066416b2f654d38622f7a68426664374334756f7a5a6a534b5774346b683665304768354b49706a6f516839612b675a39356459356654554138484d44486a33547a6b4b5777534b4155596b513466324752324c4247442b61674b397a4549535a562b776d6d45512f69395056466e46334959797a70574d6836364d48393246366e7364437a683274357a484b64376d7a6e435463494d656a31616a544f3866346744682b657747496c68742f2f3874766f5958546f6a50727779534d4443455a6f49445249576876664d59656274396478655337484e515047306c34386451394462386349586e2f354f734c68504e4c424e76376d6d6f4f662f73676b497861644469474e6b2f74334e4b793276427878466c322b586a444146333172746f4458333572473372454952735a374d444c53693271706748507658754d70447544522b7766704d6f4f30586d496c50717948635a596d626e46382b7459617a703236676274324a62464b4c46565a59537a766f4f557a626268467350676573357676334e654a447549474a307750786c4d626f7566593449592b393959646447357359502b4255525435627063586c6e42385141396251582f664544656c694274583574473165777a444279615134656d70383055754c577a67443136386753667062653839506f6f46657233727857574d70376f5170374830305442654f544f4c7935734e33446552776d522f46504742446b526955637a546b7a372f7a4658736a565578766e63533557495a35325a584d4a7a30492b326a775363542b4966335635426b787676413458356b694574384e5051714d366873746f67337545366a79535a32485a7643374d304662424a48684c3031425069396b314e6a4b43797634696f396536436a432b6d4a5163535a68573455616c692b75595469796772587478666a7a4b6a6658746c4172745a476a704867652b385a52434f63774d7a35477a693355735859354343546a526a6851347a663238444b3342714239797a36436244547a4e4c66504430444a6f6134736c37434a782f625a3942692f723072324372374d585a7969495a45374d4d316274476f46627066754c694b5a392b66776338386b735273316f3869506567736a664642347344786f5234556d526e66764851484152705a5a44434f666b597068316e666d615561336e37314e6a3478786f527176427672632b73386946586951346258422f596a3461326a734a6d44732f4566486d3137435a3456516854623634716c74465a50745977536364416e2f756f473775304e3466696544485a3579756a6d576658786c506b4958487436756e684157756169303851752f6f43796b796161665045614d3644335431394267582f666c2b6c414a34482b2f336c74435674303830382f4f594c303041444b2f4b72567553556b3468456b4d385252424b552b75747a723349525a2f6d346f45384d4b542f4265786f644b7659784c4b32326d786c3438387552522b424b6b4276682f323752714c7a31756732342f54487a783571556c724632386a414d5433626a4f5a396b645452474c6c66473174316277424f6d49776267505a574a4166795145443039376945595469455551386e767731746b465643396377764375487079366d63556b5432656478764648563072346d5364324d774e6c65732f44784e56426d794359735a76347241342f762b666931586b555a716378504e6d50565872444150466256384b4c3559305356676b7a377231334c304c784642706157782f7847442f467a2f42555a416239346e5076596d3966434e6c30467a316141663547486b387873316f694d46387665706970376d4645384d4d54444e76764e4a536f454865316d5941382f2b4a354a6b4d65624d76524d6e53746b45495a4a57682f35394947506e4567676378674834307367467137686d41675970484a472b4a6e45592b744d367a2f3346396677354d4456555470494d72636b4f734642337553506f77776c4f2b3765344b4a564e5439377059775635755a50356d446942646e3369593257796565374f5876385743754d61463564716d4e6f3945573071526f7644397a637654705a7130696d45726a61686f476366674264627263637257434556386558396758784a346f385936326b69636d47557368476950514a4536706c5272305776526350506c7467586c2b6c6a366a7857777451475036463939634958386c37456351795650382f5566366b426f5949426a336b576661744e676459674951694d696f6946726f4e644d4244354b6443667948462b62496d5156494e666a356644777534516765665049754e426a6648612b384b39454776575244322b54517a394c7a39524e4552786b756e7a31396d356e4c4b4a615953595a725a5a36344b4559474d7168794d787a2b546941616f61666a2b2f4c764976787a4f562f453045414b39556743313936665a766257524d78447646566f346d504d456f66493962574441637441506654714c634e3566452b477847716a536834705161507a595a48386c35383068634d662b4e726c6261795866506a34772f73424a55554d7663496f41734d43754b30574d30422b78745445414c372b7a69794e767372737534535672544b7a314471754c446c34344b356435504e383842487247486268453369594b446b4b56667a7a72716b4d2f756a4e54617856747a46475744455339654c2f65572b546f64694442786e7550494551716c7a37634b7158484f45474770556d443075567343594d38536f664f7479484e7939734d35517a753250345871596e505a3974345163656e544c6a727850524f556f676845454451594954666d2f6468393765474a712b43473566572b542b36443171784d47454c4d6b49485147546e483933704f4e7068544b74554a305049464b773056526d556d564d726544707437595a56717034613447756d3644302f674e543341787958675463786477474d314b435544344d2b4c432b474c4f31707438797577595862476d463864645878465361594c4256776c426e4c377037657978464c327753517a6b385053494f76513255736d586b7437644a467062492f5443736b744b3473625746665a6b414d7352595a596268765166336b73765271614f583841634e453872444b514d547947307079365058544e4837664f314f6a70356b6d596c41425864576378686c71456e485971675434775470725a676d385a30393972354f6b502b49564f5668364b49582b374f62655253794f65784b68784270567a446353377754432f4845756f626b5954597170746868614b655a47725a74304e673653545038317a4e626950766f505831747242474c2f73414a386d4c634541395076635033566362645a70685358696f4d49743671566d74673131416e2f74314c63356a692b77623444722f305867372f2b6145424e4969546648346d45667864792b6f734432614768365a6c6958556136374742454e626e56356964453862774f547a6b49712b5456503055763776436142543079614e5845574a6d574b3057364143557952496e4d724e744e5575593745766a31756f576f6b45506e35334539326f4e772b54494f6a6f795a6864794569312b6a37684e575668542f364a682b784e68464a756b67616f623643514133353178384f7a744b6f37316b6d36594b7130396659634d654c52654a4a6149387666616c7661332b4d395a737230685a6e50336b4945665a7768355946633344616d4a4b3363576349482f584631706b6e5172596e707545376357563067454e744842744c645a596c624544474b4c78764a315972556c656f6d4c367753567830614a4e3761594444432b6e31764353316358635764326c5a3948707061654c30344373466d7132636e78304950393063554e764533653668757a526451444d547a4562456377547036786b643147734570414775414c637647566a62533453664a346252726c46724f3258333033693564586150524d387a383931554862627974375a7470504438447638756738427677494d636e774b715857615379536f776f32384e71465a63515a576b37504e5848506758377964774654485554472b37545a51765a385233656a2b512b2f707372774d5267694e4d6a6c304d766e4b684c4c444a4a344445586a504554616f4943736b7236586d3038434f554a50335251323553475571585332654a693363786a6b6d76637a564f316d3641324b76694763384e457739553132414868777649363868474f344e6b544466666c5741562f6c50374d464832454a5659687548704a617a6f686e727a65494271474e4d72386f6a53766775416d4b6c305a556f7849525355547835725543586c7575596f7538313930444559613243684d7072686d2f70794576375646797950666c41532b767a43472f734141435450514f4d754e74654844363869706d5378376b2b45796a6444432b372f764d417a673774344866652f6b4f2b71396377636675365947585749447268446c6d5a676553595854796c4d57694d70514358694b4732643062782b544547494a636c434a6a6472794c6445432b686d2b53726f69646678386666575445307641794e325a76496f44396656466b50425555747776347256505457473334385a3048752f48424d515a586e71684e41754135787567767630584f61697942506f617345723365517a7742752f63793744494b6a6b314e6f454a51574e396178795a423772767a5a524b54644e594d683846776c526c6e4769664a3544644358575379505a6a71694f4a6633632f764a692f565279374b31354741723967692f5648427554746b353769784777787a55587248772f74363044307853754e69614738784e484a5439343347454b4e783330666c774d754e3877746e38484f7a4b34743439623035764d4f5146534555364173483850676b4d65546559564d7575756e5a58696b423032564b4c4d306f487163354e476a77776b634f6f3844536c5a75596e39386750786a42394462785a344272504e6d4e5161376e6f62464f457173353343487847307a49614558486b444a6f79525272526d3657714169734c3258524c6a61517a6f5451505534534e356a425a3439333431686e6c6147506f5974596558477a446e4c58364f42482b476c455465374671637362574b56456b2b5a42717a4237394c5679474d6c454d45707134335033394f4c794c4f6b4432756f326f38594c38785538587377686e4353654a6a6d3876726d4376794f6e6549347351596b59625955476e74317534464d44692f6a78753375776631382f6b7835436d2f55367358414a3370393859507a7041573743682f5a6c3043516f2b3872626178696c4b3565566633743243306634384b4634434d756246627838725561696b447055676f764f4636685473344d79535671314f4b554d516438696a2b616c3838796f596b3163597567553335566d4b4b7451572f796455797634344f344d766e442f4b444f386c4875532b526b687574477073533663324e754c6d2b746c334470376d3778524342655779563146513072474d635151646650384c667a61612f4f595a61372f6e592f744a5247344777663239474a34614244723941362f2f753262364b2b736f4c652f317a69657177797447623548482f5031436a663153355238716e796d41346547634f79752f64697a5a776842346f467676622b4d32323966786a445a2f424250577a565071534a62776d434b336f586766576873694b46374131392f3568792b664b75435558717768356a56546a4572796850442f4d37354c6378646d7347684c6959446357716c334a42686872525171305a65697351796964444e705256636576736359676b53767850444f485269474938396352536a75346477633632434b3239634956516731634b4d55524b57683169316833384f457773463643464c4b3875342b4e6f3177317470306779782f6b374d626a6678315a666e304c6d316775362b4a4f595a656857742f4e794c4b76656c7946412f5349663379685753784977752b796354755066686664687a6641774837783748784b464a54464d2b65706c6b35353465476a7266753868493564446f43677a504866546b48575258587a393943322b73317645495364565037382f675977666a2b4248534b4e392f736839585367372b2b4d306c334e2f4a624c4174762b766766527131732f7a76507441577953697736596a51704c6a343552657530594f51635762596557796342734154764c42655146646e4a364c454655707266625461477346326a57464a754b35424e3075306861303850567535696c6475624f467569736b786e7567425567307658746e45352f597941364d6e43354b68546d6653676a6a45672b5257654371444c5a4762465749544c33573162667a614d3964776243534d5067713959594c6d35793675347852546e313937704276374430375255507a4d6b416a71785242546b6d725277336c494f2f7a6d71566c795a4b7634314430442b496562577a69596f71486b616777544e667a53782f5a68624b53446167475a544336672f716e4c4539427258566e6177487650584d545238526853334c534c7337506f44544d685961672f6b772b6177487a2f7356354d444a4b675a5669734d6f507938424156364146517975486238336b38393934386676482b4c6c776e61566a68416c66493039303954416d494448695249573569764e4e59397942566853673130343442386d72304273492f5a58727a762f2f57657a6a51483849536633656475505534313232675034507246786577576776676f59663661575453376869416154774b7932336971666575724b4a352f53596d392f66694167394542384f38684f336e4669716f353733346b51653775495a63582b7149676849696a3150442f515944576f5176537a4d722b43744b50436350686a42543973416e334d63732f45566d3451655a454878674d7334396a444d7a5a2b6a6b3334576f427a4d4674387a6154304f666e642f436c37393543522b6341425a496c6c35616f637a3130772b4d50533243564f47367054794132746b5572662b465761626243512b36535a71463650596133696a434a4359374343494470425a4b7a426a464f4e656c79556a666b72506d467a636b376443447663764d5a6f3272654a5478576870584e306d396765354f786e6366737a412b45446d56456b6e53756d674367576c2b7231366f37614657534e6978776a54384d7657363859347735764d6c6e4f61702f75765037304f69633143776c54486661316d70736a516a306e67773647647848304e59766858456a332f724e6f34526538616f52335954702f2b726a7878434e4a3767595769625843484b51444b59557567476e3775447a33447732426a4f584a776e5663434e5a68495355316a67647a764d536a39413753314651625a42584f515448714d6e46676c614a2b6263354d393063754e4f304f762b426b2f76464e654e7579614642652f4e6c7168784676445130514661564943635535635a55727933697947576746376769396950615250324d52542b3770734c354d51616c694848694958654f722b4a535837755958725a6868524e365864365836396a6d4b764f3965786a7874753571782f2f3631747a58474e364c44316a573343786869636e71424e4b5277794854466b4952696a4a534b4667416851697a644c6d786f6449554f302b316f652f6548596141786c397468386c3767583948773554332b3168317477676e7177524f76436a5354664669457670454c68487762446b7477414f38644238376651712b736e792b325430502f6e51354e4e4e7032554c374b47336b4852585a386133545862352f474b4a2b4b79436d3754417156353671306f525558355172627946517235676d594b5051444c4142322b61424b4d4d7077564b7158686e4b5939656c596651614d2f51674c7163454d6e576271736d534442634e426e4864614c466d796e6261684a6e2b66316538774a746e6d494259506d543372693074535a47475937336a493854734462646245776e51663834376a2f697a2b6932544f5063786641646242575134636e7449784165544363526f315a583533503665456a616774775377705465324c767a2b79336a6178504c4465492f666530693967366d3045386c50386951727a4366596a6954496674705645726653387955565245534a426832694c3061394a686c4d74704852394c34777773624f4e775851537273785a58744d68345959506869654a62614a4a3152336a32616a4d4e6e6d3979796b6946687a546f50366c544b693279757a677a57683938686f483579647763473655477279675546396d564f7a4e4a554f6b5176594c5348334a437735704852464b374e4c564f7043434868702b624b5a4747444f4b697a682b516d646277676a5376656d7945704c48716c594e375354362f63304348672b52535065473178437a30526a326d5a64786a53726d5762754a39654e4e48546930592b683367366a6c68504a3566635931375278314476562f4c4451374b374a3437724a4a5a374973536c4a34707254386669314e475969746555364367486f507877683278356963597931686e45564863614b5270416e6776796a51734c574d744a493475434641327a777a777545597431784c3047484a76633444567555705135375469424957557534716741506e725843464b7042496f456e77704e3639736274506769754275795a4234535033584a5452716531377a4a636a36504c393267694c7661784454423848667436304f4542756b6a5465416c694b327372574e756268464f75594149785779465a715857666c4564496b775a717637793269624f4d4376384949586545452b644d69716c4e2f4b574474314a5536475970354e4b7444527a30686a4b4d42314c32526357563747345563502f764a4448767334516574495a4570494d31524565696b4b426872584e6731477962432f453939766d49636b786f3358343773506b735254654e374e55457562794f4a794f6f456676546f335153387757456b6e61456a5641336f385568616f474842356d452b433559642b38504963736d584278644d4b6d6530616f554567526c544d5270634c2f376a6576616237626a657230776f6f6f793451737a31326a667274597757334b61634e7065527869503735334e4532795742534c66702b617253636b55647776336f524756735551616147766e3537484d3078757a6d7835714478343052337859344b4d514b4b44786c6b675a53366c686576734548753175472b314c476b4d5a566438754b446f683755382f76353644723537506e4933586e337545684a6e6c3348382f6a4542414b7355714e476f2b676e6d65326e39354d76774850576961745750662f4752772b6a75462f394e495a66593544756543474a3159523366654f34794e6a65337357386961523748543877305266415a53587234556c4c6b693169697a6e615a39454f546c68354b704a426d534e77677a58446a64686e4439535563323957466172424569696c6b754f6537783049597058476d2b4f4b396c4646344b4c41364d342f3333372b4a476b3937686d5263336c50463178682b2b726d5a443934374c69756d34334c6f70594c343047364b787a78524854456d4358542f48693738476957694f317a34746531564a486c4d6336303439752f7578756845447a31546b4370434858634e6465472f336c696853366375746974746c51742b4c6d534a65504c6c46302f6a4b684f41653373534e4851663561554e72504151484236506f2b4250472f594b634f4e2b3964493242766838527766434742496f4a61367063624e44784a776c65737556577874594f39656746776b7a77303554695268466d454a306a5345325366376f4b7a65574d52627a5969696b366754694d486c6d4868677970565a6f6b46315a496e6c4c3859372f5a34415a735a394a515a314535736c396f784266777a4e753555686c686973766a53704d44396b674365794a4e4a416a5237644e555678305259794a5736712f6e307063314c6a456e33686b4845734c632b532b764d6a78585336753137424675424a617a7870464561576e75336d54436451476f52417a614a48456653544c39783371516d686748464f375239477a6e7064336a654370703435675a6d4556662f6d4e79336a6b5141616459774d6f38505231307a4465593562324969337777486758667532374a3743305863483251745955386969744f63537a4a484c7352353759772b786a46622f447a4f7649634d694978374c6b413536736b53354b4d2f79797633786e47342f76373866394a2f625464564a6d594f626959786a35414858414762375533354f4b6d4a716477344d50544d484459316a6b51704a327858713169443647693366664f49757261303138347046444a43307a786f547a6d4f4e682f747779506468662f734e46484a784934416854333743714879677747304e4f5a53433376595a335837324a6268724477556d4a7145634d424f667033742b2b7549592f653230476e7a75597767422f4e38496b35514f395368723864704b5445522b656566636d65623061507332302f76744f644c6b6c50397a7241774f64324d6a57385932767659745763515a783471524e366e32666f4a4463796656544f5536416d31376b6f5974454856793876476a3155534d6a4b517754477755496874594a4e63362b2b694a324878776742737667796545344a70774e65685a6d3542523436335578396d3162302b6d7a4e2f48327056576363596837434a73324b6d31737279376841387867762b76685958514d39524d32784847483372484e6452463945424c455941517055494e39396b58796a5253336a2b314c387142466b4357766550763832777a3155517764326b4d536842365a734b584f777946766e43476379566535683830747645567036767a5a56657769426a394f4a78435234734a49515a50414e356d64376b347559502b392b306a593073504f2f6677483238716f6844476139514a2b38572f5034584d6a447334582b5748454e2f5230324344422b61382f65426a356570755566386e7167594c38304b34554255703669435933787954474a6a6b696e704b662f7370566647544969776b433779542f2f7058704c4f3751746637615233636a6c464c4e44686c6b4d66784b476a7a364e384e7656654a33673061386976446949695a4a66377a4e464c6b764467503858336c2f46536447752f475a52386149764b684642587a47587576557465684a5647776e41667762723578446b567a516779644738637a314f56494e455351497a43396457734f6e372b31435a32387676546244706f684a5a7151314a6946727768765a4c667a4f365458737278587730587548735544696349305a6f516a686235434a66324b716b324b345a4273654b43356d6b3936684c632f416455683164694241722f41334c397a4139624e583443504f4b704c5a37705a55784a443259785473543139597778784436314f505446684e4634454a355a55794f7272533144305a4a626932623739384762586c425277364d6f4733364255693941625457785638387345394444394d34303964513447652b73444a4b59785457367851724134516b6c5435724d39656d4d57746435644d567a312b6642687633566c315a54715378564e63383165763839314938657a644e34686f6c507166744438526e76544b4d746f6c47746a36726475594f6a354a426f4373504447755947754a447559696e2b45436a662f2b795334384f6870426d4c78656a5467693542584f716b6f4977414478382f55626d376878376a7247714c56362f7a6c354c4d58704b723247716a43766b5954383335657936434a5a4f4a54796b44366f34447632304d31524939796d366c2b764e6f79686c7353514345554e427967566c77536b574138753942705070396a58305851594d527151796d312b2f4f513452563971534e70514c617877687571522b464a364164554e31586d3668324e2b4c4449702b504c354a53544a692f55794b3731443166336a523464782f4f4134463876724670354a56576e37444d794b3556654d622f425a396b2f30343533564c50373439434a5341526b77552b4356496a3672616779472b5a6f6b4357614b41586f545354745748792b7167786e73592f52532f2b316d42652f6332624261636b5974383672645a4e4d503963556f4634564a316c4b6573763641746b6b6b5151726f41654b4f4f74646d5477384e6c7362362f73564674454b4f43625a367a7a393661386d38362f632b4d476b365a35414b5230506c4f54775551575078322f623841794d5a636c706c665076554852775a5432436242377169417476744774362b50492b39354d2f326b50634b685654317974424b6a3079367962782b6d6e2f59307876474b6a485a7457747a784c504d756f6d4a70386b2f627256432b5043525867774f5a3977364e7350534c634f796567594757323462393671724332644f58794d5a5471544e772b2f314f625976545236757a392f565462784e3961484a33362b6f6870395a49695568487a3268332f615939456b6e7330556d53752b64753832504a6246594a346a32306f41555671535839584e525574547631676f4e417659675a596b75416c58473147725433477562526b5569696470653169514e5762784f495a2b466d6c344e62314a7265766c4f4165656e63336a7839686f38394834427076702b453058344c7649754b6775575562576b396345304b484670347351477944317430534a3643516f5a336d6e775050336b556251595464454d62636459376f59304b346e6d6262385a6c34793879732f353455663259734549776a72362b4f4a50374f74416d52737271714442357977543842646f6649575664614d70504178486375747a584949666d77726a472f7a5058353472496366335a644a4c6f70434c31744e74693963325463686a4752594566734e425377676366725a447a2f2b42735134556b796e4d6b446973366542774178494a507834596f68636a324858302b3753334b4d477756794a32577a514a7857334b4f536f47654f44494d496f38674c2f332f6a71317a7a59714e4a37584e70763430424f486b653771526f6d65554f2b2f7472694f6f673435785865504c325441764d4744487163787646547734396c704a68663837435178356c4f54444c6d557846726353325637625a2f564f646c654e4b312b54335353436942394f48706b4c33377175545536454d4955726b7543696b75422b37564e77746c543571505467555435546d477553594a61616f425957566c7869346d4974464156487537614f3036506466666730324b584738724f2b4150543944596b614a6b4a456d76466f6a67366c45532b567561694f4d5a684a454b4f5a53494379534778356a45333231496f453843634c5261786e697552322f446a546f6c434c4d2f4664782b644e456c4551567430676c4a5655334e31376c5668494b386a3271486c616e314262776858566a65524a37426635366c49523250594e54496f47735a717768766b643377794a675a46656232327971447431504d442f58497a4e617875385065702b373279366544783454425348556e34343148697077775877736555766d4a4d5259436e58385a564c54654d3338717179534e5a7762306a5365703171726571596f337263326a7671476c364869352b304f2b4b31306b617579666774344e6842444f4e58434c364f4c6d634844504c626d4b304b584b78335754534f34697a6c41334b33396634664d45554b66474747424a31742f67744d795232747a4c7a76655353387377386878684b672b526e397665486b534770576862627862584a6b77535667546b316a31456b486e724f45424f685345654d617842416f705a466d5a6e7a414c504245746e306d4b70536f3247582f2b4c612b367a6d774e30485439756c62627945473671385544567474366447703743434d387356664a763634347645746664336573674a307350794d30492b656e77714956564b666c7072683548427833304e2b55514474636d4652576d416c4433437a4a7061744f415333656b574d56516646303643734e5753307a6f624452394a78794a6565572b56674c7946305934417269355669483161654867796a5750373361492f443430726f6f36573672527055506451346f67354e56495a44446b71565848676c74563678534d313744337255757772545874522f596536682f2f64615741334b5a417841697948354f583441446b5550724258565264715246416c526a504877314379387074416d4d2b76634b7979464234726b61433945636463382b47366d32536f4355546570726974526f386977776b586b6339556f674533754b6e6242575979584e7730737a654b6a65617472354a574b524f5050646a4468577537564957506f4e314c54794c6832394d734d79796f7755534e4372417737614f45314f4866776a58696a53746337474451677854583973413463516b506a706547362b663669726f496b446571464f676543593439425052553074446b756b644a68327a6e476e696c73494872544d6d2f35774142636d6a62716d31564946446d37775a4a635869564d645a4b714a4854635449704a7034686441306d304c6b59703149786a39743077586b6154302b4b776e6f48563169734b5a6e36476f334a4632785a745952676a486f4a7043613065456938464a54764f7a534b624b4f4d474e667a726e3647524471575455616f53527076504e474250443139625a4e4f674f2f6835313447795255473649327256556f364b71336855766d65662b734f786d4e746a422b5935436c6f595a346e756264544e64474d6f397872507a334a57394d624f4c2f5578426675486347656f5a53565433774850637556685133384c2b4b487155746e385631484d706a634e51352f5664575458724c76644b45387858334271416d70515835684b62754e303165584d623253523165775a745753772b534678716e3352656e6d42654c397a5a61526751456167596475506b78446b5a733339384c546565336954617a4d7256425038324f655a6c716c474275696f487a332f694830374a3679356f676d6e3230346d6341356b71354a6b70782b58386f6b6b4f70574551734d675339516a43315853315155504b6f71783736654b435a484f31425136787631765469397847675873564176765243357172715276374246464b35616e5a2f4856313662785561756246347548664469535762546b38512f586f616a5444794e5855504c354c7953364f5270556e31386b6278584d4a6132444b31567a754c353532356a66574f4c4444647059473730614471426b7754643662342b597445776476556d554b4b786a6d616f7756555a4d646f784b334e68614543436d654c533942777571467934547468414c485a3342386c566b727354687966517879546e4153596b5868316f51706857316131667432706a6c6458513955766276457252755554506e79424d71464f47532f465a70376758715a455248422f71776562794f67324f4444352f635448626f504a41536f5555687a68356e3664756e5679696b4752305a423941586853447951416d71506e364a6d6e68317a644c6d48754e71667039753067794d69377a4e4161344564516c4b56477338557336385375663745584e452b6144754c5831796a6747653776784778384d343438754c2b466e333972437a2b664f49385034326b317771684b786c6a496a656f313264685066767243494b336b664e6277686e486a7349496c4d41744e43425a66764c4f456235494a364c38376933714e44504a58556f5251654a577078455a583968526d535a753473343556334b4a5a53653974396a427641304841337655654c53636663536748586279376a7a765170335076344d59726a507573717164436a657172304d6f6b41566b6c332f49397633374a73374964505a6a44577339733470434b393561587056667a7861334d304d4a4b4258412b316d7557355753334a55304b474870573431506e354f547a33376a515741696b3863643975476938354b52366536645569667666634f767a76766f63664f646e4c7247674d68796c6658534a663147694b747a4b597a45307434357576542b4e7179594e4837787243513774476a65504c38526e656e566e48662f334744587979377a7232485237464f4e6638335051535061566a5a53764b476a323148445a4a492f7a4474544b4f337a564d327555454f6c4e7049535879672b7634693165756f2f584f712f6a75753770497836517774356d3364316a4f435a347a3342456646636c48505874324270372b446a78782f3335304d487971614c4442374842704a59637a5a326251652f6b557875366477487249617a416879424358705850494c633453546f5456336f697a70476a616f54676d442b3468652b4131586e4f626a4d44466d2b7434356d57716e633939634c7a64497331776b784c464831374f342b524141452b4e5a784469687636586c7866786636677364765a30475567574b574a315332714f6c453747667a7631706a575a7672573467662f30366a714f703730676259566442484542657130534a59552f6d53376763776536714978336f79415854734f4e4551756c474b664c61316d7362334842654370666e696e685432396d3852446c6b4c73796c41684956367754503731344c557538314d51765044464b674f706a7468556966784c6b4d3148344c6f6f314a7743754647686757525170487a33327843484d7a71336968666b63397152564c52444530362f4f34366366474d4244504531314c34477365742b732b74526a765a5174677455766e3537426c53747a65507767335431645649704371356365706344516333364e587230376963667648554d2f7733793948616274316779777435686c2b726a774631613338542b2f65676e2f624a794863324b634450513843646f67547a6b7857313841587a396277734e48656e44334a4d6c59346a787474396a324b762f786b66616f4d366c3459546150525437377036684e7672386b414d354451752f36794651505872363254456842466550524b5151372b30316639664c772b435537316458773638507047347434376976763444743268656a52366245495a655a58792f6a7549344d3463324d645837717968582f353643677a5346496e354d4938717531535875725657675373356d70326568475833376d4e336673546a436f4d62365352627044446d71547565354e4b5271565178556675483059336151775a704f4d4e474836574e35544d704b7a4b2b396c646961645633436369725975633058416952464b736a6977356b6964705a4b506a6f795973572f626b7438545937654377716c50484d486944735871416d745039677748387a6a6c36487a35735435772f5436376a496866315277393234693769706279304c61586f4e43366c734931794751576d36513169716a595865707a3078766363483852767662644931683649683957395537614d377a382f4e6f6c3655506a47622f716b44462f67747933366741612b786a43755a6f304e2f7265767654644c6c2b796e55742f454e67336d5379543176766a68435977504d397779764b7241312b4d4e75435636416e71473752776348553467335a48416633687042767379446a4c6b47785361357a614c2b4f44784d57746d71444872745259313964677077644e6855317359755a3441416664542b7a76786431647a47437576597145647441536e78725837732f4e462f4f775467786a735543732f76312f656c6f664759566a79716a714461314a6d6b74444a4e65346a73443933653448386d386657647a56667839395433717078457a3937337a42616b517870446d497966725a43644b76425a324b4956616c3144784f7577776637384b57584639436656426d4e483156366b72383473347a5871526a386a772b4f4d354651375432783759376d36504732444c797243724c424434785237756e71542b483563307438466e6550412f53732f2b7373443271766e3838777759516859515378456b78597962526a35654f43484f7144384a4a68667271716c6979656d446c716546666f316c2b6372654a2f583633675534654830556c5861584b49536a5163783270397048706275356952624a4a30505359412b3051686b4741554d5a6f4b7178336667775055476f6336557a78353341675363354634796a4b33686b416b5138556d5a59594741572b5a70375a45765579434d2b5669484f7950574947663673732f7672735844726b697659674170342f5a546b735a46622f6653774e52475853646963654e6167766446462f2f396a5a502f6e4952392f57536f43532b2b4d6e6a76596833393967634273636a487371786f6a33565a426832343849302b543169515159796357535a4957376c537a786b667175363950487659745436424469556e6a636f2b3868544f617273564f55712f35734539575a5a7a6133553969676e2f645a6c6863386d4d7379616863304f64446d59494b4f663646666466645636414951617138516e6a6c4534716a6951624e53304c627064432b4936512f78415277547268525a656f6a44393777384645557a3330716743566a3866344747756c517032364e734d2f586f574e5a58342b4c2f766f557a313076737a7a4167394350447a727a43442f4d684946434d6d494f3834695a3279624b31443238716d2b5739355433353255466b764659634e36726452486e70392f6936755278635065303958786a524c6e2b4e57517268763072626e6c744e52595053553646574b42486835687262622f502f657a7a7659344264385956635978356e692b38527330354c744966686e61566d714d5264623379616f395451644530575645595539495378516d54367a6e4d657274334a3439766f4736662b555a59792b414755656b6e41536b4f765545755736713062554256444d6c383077496951505654707a67524c593735334a346c666533735333467472476e49736a61517158456266566d474130744347715964593534554b6b7545427068736b374e576154784436646649654c784178764c74427731596176486b4c567957675a4a46646f5935575274747a7959722f484c543275566572342f4c45425a7172303269703859395a305a627546574e673179416a7069534131504a2b2f6a554b32774f6475576875366c7775766e6f45327651352f48412b526f533559474357667437684e675a7038574538483954705342527435656a7436474d6f78745671566879566f6e4a3632574e5555717436595450764e437a5559706e64312b664878447158304d617548563449556b6a587a594159316a4d53714e574268534f465a6d5a2b476b42776579424376384d417a4842344956764873544a3573766d4f6c31664955676a55654b356c7132653936784c46786e30586569496f5937715a5154595768776f4f6c2b527254323155385031757961676f70456c572b613930367131306e30374a4431745a63475761643947565a4c7341325859434761487a2f754a6361567852377570494577573262365344463367684d7464447a7439516d4a682b6f44564c4a69644a3256516f6f7a54394241467a6a516f6e54367551446c39526f775177756d694a515669653171474b56714a527a6c4962614b4b754c57476b764836784d7342354e55586149725a4f466a6c7359653379346735744348386d3076536d58722b72773469625775616b4e506d395856774c78444c552f7375635a477330315661777936646a4833322f7a6f666f3748514c784b744974747a42507159635754553058576e43726c56646a41773232626e2f50454d792f47786e73776e6c6d6c574b70752b4d68742b586370356f7a6a37565031496970664449475a6c4c7172576a72755652475135367057436d7045684a5871574a6335574874445074786d4d42545765383236523174594a463856356e4771314b594b744e35615735434f54452b7633436f6371384e486f5a667556536b6274756b77586e7775574f716943416d6f757457325a4661304c784e4874596f4d303348375344796b3852746b54705249554248496f7a2f636d624a396d614568374d7a564d556d44543368535a45716f49463635426a6f6c5150697365707573776244636c583749524c6138645054397a47356d755668395a4d526943424e6946546b34516a53572f72346e44704d6673322f454c35717532767035364c525233697879464f7855577862327174776f566a6233397650454b56746c4f4530736256646f4a70654a4d6443772b4e432b37774573493569617431494e7139344b58715670436f4b615542786e715344485154614e464b46497a565a697364714d703133714c693336516d716974455371336c7132387a6b456a7842465a3432713152734f4c5a52367635706370504533637779632f71625731753456654b706f6764524c365358716676782b4477653239754266704b3647544c38632b536d2f445255645539582b4c31624a425248426830376c59355642785378644f554f62737752484e4f3455366b49526f5937305533785650566864527162694745316e666f5a426e7a71334761434532695456394e70356f46546155325a486d325a33312b6e306355544b72554f59336f74622f784f6b544c4d49774d684444416a72536e64702f47734c3634686b6b685344435a33706a495866732f475670596964684662544c6644784a393933584871713336452b66655471524475377775624e4c533572524b646b4847415046456d7a66676b50565357554c795252346e655732792b6a374b4d367150613943676a6d54442b365a3645565858493079396b6d7a5436476d494a4771436a71676d2f69383938666e644741384f35794234764b59773276622b5845576733735a61767447473453527a614a72337a4a766569563062467456456c683465487a554d50726d536f31564a725034395a6c5a7648594948354d6b6b30376e79494c78576e4b30346b5179524d537a68313567347533696276513932374f2b683270496a5836654c4469513066482b7378666b5847705a6169644353416d77547376576f44354d754c52796e546d4f36635863616c39594b316663636c58725a563965626749484651494232797a56466a5a563274595878514755327a36624f4730545a2f37752f4f7a6d505a4738586e6d4655644a5537786b74575743312b6c30587a7878685a2b2b2f7757486b787359656a67434257444468706d3174797a7747575165452f684f6b69307658626a4e70356a7568306b514233736a3548443857416d57384f70742b63514b74316b436a2b4b54486361585a454554745557304d333355572b716c79537830314a594264362f6e715078307442437a4a71637470556e6532717a4f4e456674516b76666d497848304e616d5a67317a3942633155486847596c524f2b554a59535a627755735568642f63306f535846444c4a4d4c613448756675464c4838316a702b6b4572424344507a4a72505a4459724949573536316b717769515035516a62754b622b4246303474596d4f7a6970482b7541316d57627151357a7463774f3639505269634775566145394e5365747175316f7a646a2f6872686f6c4658616a44714b344952454f3666586b61373178644d2b612f516e4c596f614d5a535868785972495476744678684b6e2f7266494171424a596457787a53316e53534452695a717361714f4b4c4f626878595236724b7875496b6b44567243366650577944325252425946654d70356b685936693741792b2b6677656e72797a6a4b425839783865374b436d6f747978454631336a70704838704b74393551613570624e4c2b50524449385a456832494a30787a7a444631543439546e6d4358644a7036344d462f45666e71455478784b45525045544834706b4e544d4d6d7337525479576e3976456b58364747353757696c74506151417751335a3467777a345339516237366245637044453753617a6e4d32694f4232536b2f5359525737616a30356b55422b50347a664f62754d38436438447539496d375071744d64527267304f5564487a6a32624e576a767978683859784e4e774c6371734d7a3355635a5a6a423851595872496776506e2b4c42724b4552356e756431463056734764654a74597349486e722b64786261474b54392f6469346675486b4b53373175726c4732347a674b4638686649746e2f7a315758697967437a4b7162695670516e6471614f53445275375742666650346d33714c3239364d506a2b4633442f66427878446c56615745346459477074647a2b4f387633634c4e642b59787867797a624c78687a6431554b5175614f2f624762634f77502f6f64452b696c6c37614b55704b395231557a566d72683072555a33487a32444f363661344369666f7a65634e4d386b72796461717a536364566f4a624243736672616e52583469494d667648765364455966595943534a4a564c5066334f484c35332f6a304d48786a46307262506b724d6b6b34453732544b4f63473944784d37352f43612b2f757736376a335269386676763438427a32766a46727738556b38484168575144436575386a44556866414f51563662443368794a45565137434839494e36487746326c7745794c717479646b6e69656946776d2b5a3954792b696a524a4b6d3852573467652f6432634a645056353838324b4f6d555545443031326f344e2f352b644730526b78424671444f59566244326b4650795748454b3574316e474c6e4e59512f377861724b49337755336a516e377853685a664f4e69465a4a54657a776b7a6e6765562b35726f3362596d507a2f4446456c4769725833554833666f706a3870624d62584643766354514a4e63527859372f476a557230787645394a2f71523775387a3136354f6e7062536654356a692b2b6469507077636a534a6c363574345359397969434e665a554870555173394e394f355442456e50545a45353037654d7072565a733138374977344832304f304a4b496b4a466f6f4173446333487a34763758644838355955536675486c5a5178544476764e7a2b37483376452b4e4655707758425456584769356f354a615741572b5a48395866436b34726a30376a7a5a6434655a4864655a37396754432b4c587633345456326d672f2f6b6a65386d734a326b775157756162524933316832333337432f4d346b592f336e396a5773594a575530732b574b36664b617a4c677732716b4264466373753737723243676d534a5a43676a625871714a4977542f753655766a6f772f737874656d4755477555614b6a4f72485a644858475661376251547163693152527a74306f346f6c48426b6b714231327062534e72435a313356332f303654666e71746241734c2b5459596d623373324e473037344c43786d43436f467276573964594b79736c724456634463326d6e376f7246314d53582b36307362324672665a6879753473783248662f33596f6e3856546647794d6b4931457534394e474e466e6b714e51366f72485a39417447534d6a522b566a6366774b486f2b722f66323743366235566c4c4a5a722b4f78596b75464b7062562b792b4b556c516c6d2b496a6e524e4371334d586853524d2b5847595937574d49576d6634564c7458684b346d7875393861614747635962636a3033467163616e7252374c52344d49453473344958556d65313231582b2f49747a744a71754d504c6d2f69496f32684f383745686f627a2b4e34556a6e524843514d63476d414977596a62425330766f35454544575a4857597265796d7636556b47384d562f434770396e4d4247772f31616b635a6449682f7a75702f656948756e674d394f59765370684955366b51516e5865593078636b74574268694b526f6876766e52366a714930765452423869395233576751792f7a6d6b324d556d614d3243737053664b3877727656336f4b6c45516c5571394278354a347266652f5532526e76434b696b684a2b6667796e6f56662f762b4b6a354d43716144656d79416e6c5343746e54686b444a336c557954674335584334677935443538644a674735635772563163786d416b6266396e6b47767a7147327545493135383737336456423943316a45564954775253316a63326f6233594e722f644a6a637a364f4d3636504a6b5046445366384f7a6d4c6756693236384a4d6f423650427549686c377179416d685a4447575744494c6558472f5366723158773347495642306d7133646364774b47657446747a42526852574e46344736766d386c6b646c4c796630334a5067556a454748465a67532f5a6e79424834334d6248305a34456a4c4a7544552f7945477046465a386b6878526c497569636f384b59317159713770566362424b476d53643476514a476c4a2f6e4c6f645433745871495948364b3043616c7669526f6256664b6f3264323673565576777a3149576c4f4747435043724e494a6534736b3331696f3451434d5233726864446d475568303146325246394e37465256575531386b69617832436a4e68302b673479616b596d4f39634a574758667a734970696966446e457445326a752b696e7167434e596e6153696539506a7377527164352f72465a496d6a56486a314d506a625831336e41573861627161506d5a77374579474d6c72647a59725970776c59694757764462516474344779724839786f6b6e33686a58534d4c366b6a51614a5263356573614265446e345756345433596777757966377449495a7a584971745a4e6b555238566d45725a2b547a37716b68744570354b7a634b306b4645764e527636587a326450704e7335564148784576526b3553413065556b506b75624a507933326f7746464c7839786277305947594e5535472f534c4a364b6d595859687771346c4161346e6a554f46587935315a6f4b4a366e6f497361583831442f425a63534b706f56764155456649657444386251314269786e667043614e736c686d796379714936497869473870744e787064524b505a356b643362685a7856436b6874306b342b4c4d7247774147476b4b64625859334153474d593051716c65337556676559347331364b4b4c5966737945346e72525a3677365478474f6f6f4d6b3231725a622b763336305a462b2f54497630676733644d364b59524f33347a4d484630476d7757354d5a71552b4a633147757254617958476a67365261425038724847724b72755a30624d5443354b7a79573258455a7135592f43494e796748442b37573477325138632f4d4c486f704a616d41306e4b3372362f334c494a454e59416f71594b712f63782f716468574b6d6c32696866444f566d6c74677a672f63767a35493738324666474b61647172314f4d79764555546d6d514a514a45634a475634693273616f44666e36745773583348522f4637372f79506d7178706e555a655a6a3558633135384f4770704c684e314a6c6357656c536f32515a73477254394479525249535551516772742b664e6b392b31627868662f4f703771506a4b70456e494a394b494c3945613971575a58506c3970715134664b59797957572f6a45326e3466356542337336314d33687739353442696c756474692f4d7957506d57474f76315157763836486a6f53434e6b4b6e5646566658674e784774774358335368304d51546b3135694d6838562f5141334a6f516f3859506d4249516f346c5962476c4e5973416b7848702f5032746d72664a434b6a492b75764d72557430537865534c756f494e5a584a7a2f4441744d796b3270675a4b4c306d4a6f31485359454e3138794f75574a324d4856785261376f44654f44653067347a33776231716f6f68517351396a554b69494f4c4864724a72323539614363584879644e6d6b4a377a71747662346a522f792b7350576470626d43522f745556305653557436765936674e71706c6266634b6854342b58356b6247694a76704177324648514a783271726842685a376749582b3851516356745979554f55373850736c4442437546464d75524d6d7271726d44612b4a656e47346c6a366633777855347964465237515a726e65506465503032715a35315670414865632b74396a534441444743625a3966726353562f7952444a707272444653587635386d49666b7672462b5a756f352f6835446244664456724a6d616f4d6d58546533632f42724b69455074535964566b67702b565338794f5173544a755950446946322b65756f33397343452b636d4d544675515645755034426572534c6132565543414853396161566867734f684d6e312b6167422b38544544736338534849426b75516d65726c414a5761495639637265486d786842586969324d3953585354586c6867616a757a7459486a2f4d4c52495970355670784745453958664c362b7a684d56594e674932676d4f3036696f724e6b3478504f7a3233682b75596f706e6f442b54682b4b68545a5a2f6f49315475346654394f677964316f656731667273374e36513971664c59487665544131466a706256534d38366e3631497649724f5247446b57394f41313069436c2b4d4232777359707470757961666966774b455938776e2b72377452764458316c78486b6f4767793141594a6d7a544c594a67357a6c74647374475530303246566f58564b4a356f4149377951704866706f4847765a2f4d326e716e4a67366342634c6d636e346d4b78315144746243704e46647075466a6f4b47474679704933696f375636717375504254516e41526d3338794331542f70347762364a4f53724c394f6e735a49385946754c317138596f70626f532f62594d412f5a66304c5671397a494a67314761326b515174436b3654564d4a696c492b4555546748524156526e534a4b636c6a797879586c7269354841586e467435314a54344e4e5241573763572b6a45364339586b4f2b47366863364b7141316d6b55327553356a5a58374e5352464354427764376b6476597745686642717672717a77632b7336796c55645a503661614e756967664b52547770532b366a572b6c2b5971614d363563456561542f47746130733476564c4244502f794a2b2f7678616350444d4f4a456451524f465449775379537a2f694e39355a7834386f367074516d546d327448534159627970546734305343676f504553792b4e4c32425a2b664c324c2b72427a2f332f536649627841734e385635557349685358714f424f5666766a484c6b4c614f6b33544e6957545568726470484b4c77565166354c312b39596b4e676e72745a746c4154443665775a312b2f53522f7151723577597732334c71396a6643434f517a4979476c764a5a6d555330796d4c4a566d583463474a704d4957636251417235496d4f584e6c473033716f4f7135753753326758446c477037713932503369544762364e786b35724d6e3565644a727a4c4d6b4a4e534b475a5330616f487254716a5546567231525a57316770594a562b6c666f4742336942533143513949544c6f516648674a52746c37656461614642645a7a70714c66484364704b6b36745569357559583866584c612f776578796f65417130372b4f696f427766705a614b37647a48734373676e2b5064356d394e6555466d4a5a77656561654b4d42755a5a68594d4773784532304e744a3278517272334650476b69536f4a654e7865496f6c34714d45756f563943466249484e504931506d33476730334d5242664f766d4d725a6d632f536d6a444c306343715a43585074457031456c2f5377453330397544692f5a4e4a504d7453305a6f2f427162535653576d64367151693669534e66526d477641535a625148325a32613254533955522b7733507a3242434b5753716a53305374314b5a74584f335545672f597550527641504d316d382f43347a466c712f6835684d6e6b38443142796578447a42344b2b384f59386373636a762f75424a71797251616168796335514256514d5564476d4d52346136734f387a4566777079644f2f703745657a47796275792f5153385235496b4f30776e6c2b397a6576316648526f2f30344e6a35676857644e7836714c6244375751442f35714677577a3536356a62393764785548646e637745335273726d6353486c763044444d347a5979615873726a4b3951676a7834657842642b3949686c6c694779315530615735375330312b3965417476662f553654673748635041517554732b79784958764f6834724d38757746445a6a6a537757746a47712b2b7557643361506a4c307838696a6c58687172382b56384d366c69356867346841663645613475782b3172566e756442495668726f7375522b5070357447573844314f334e3466586f626d38456f6e69514f2b74454d6d583643395456534c652f4e5a2f486e6f6b777576346f6e6e746a486a4c59546c36357357556c316e61486370436c7274573961565553417a37643661773672747a65526178586f6f574756486f50393355685030414f536142336f3673535636537978573944773342716442504d4a47674f5641542b7847666d343561734c794a61434448394a6571344271376956416a4b33734956724a4b6a6c674862647378657852574a747252333334635a47426665314b716173454333543832376a76657356654f2f76447a79744d6c324a71443636385165366b2f6946443477793756455667742f6d53536b57742b6d61327a514d3051797155542f4956506975585a3134377459327271385665637239474742496964427162323157734533572f43382b643579736264706b475a7531494b714569364953444a30366a664e7545726363796b526f684d442f754a52486a72682b4b4f6f786c662b567853622b6572614a332f6a554958536e4f6c42587037584862352f6c7447705774694e634a594a7767732b6a7a4f6774466141464e4a726361384e456c4f763368357634323363325551724738563050443643764d32347a454d51623163547338335043336a434f376c5a505a524b76584e3543346334364f6a753875464d794859713444396a564763537a743473306f44492b2b394155376a73776873374f5476675a50704c524e435a37596a615361496c797a75557263795363315255655a4c62725468734f304a304d55765a5a58706a466a5777445435376368513864374556666d6b70434f4d78734c474a644f364f5a424f365a3673447453684266495746372f336951435952375345685559494451524a717438475668597776767633374a4f4c6a655058336f6e5270423133672f596c305a58466e4e34537a3575336835457a324453655171616b52574a335944697a7849522f6a7a75766a68316f566c76455575636f53775a49496357703372704c3276714c6e4643614b5068325271627938324b5746646576634f656f633673616e7949587269575236456f7a30526b2f44657672434f337a35584968364c772f76426f64445463587142434c464150386e467033696134556d533379477962336e4d616a5872303870556a43706f32796c784e41654176334d504e2b4958333170474e7864764d734e46314c783234713666767065535169784b492b4a76794a507874333071364c655a433045334b3275327262314b574b44625738664d4e6a4d7465744465634e746536725731466e37356751466b474c6456544b6670667a5a4858496c68323275706555737a5478734e713233715463667845696d433258795a556f6d614b5a6c4145492f384667333279594e39654f686770386c473269434a316a5a756b5a2f6e6f37454b4444633175707276654f78414e36356d5735695a327942653466637849526b6d59502f6439334b5949416e3650512f7452547357637966385756325478386a616873704c434d6237435245472b76727737644d4c784449566871455145786871624d7a497a73376e734535762f4c463764707467724d4672626457496558646f43336f55505a61306837464d4449634a456637627334766f532b67674d4f6e684952306c4e2b676e46723578635261335a374d342b6341555976546341536f424158366d4c3669577442416d423549594875386b2b567a442b58507a6d4f444279436c3549655152375244675076332b63777459584376686f2f636d3453652f566c553055434c6a56344766746f71486a77615a49356e585366793844524c51623831546b413562324330543278554b48767966743964784b7466417a7a375969556b6d6270346565706d65574e6732643479385439736673334a57755574785633574e4232713662567269577a546d554871664d6943565359524a4a5879554450564a306851614d7969643653414a715667365a52554254544d436a7932346a4b4246722b65516a354159374658585239676c4a2f33747076584b3753566e6c475149366d54342b76537746346648652b323243695044504735526e6c4e313859426f68345a6857593837536f6e2f38627632646c6d64655979666b535a4937715352667564596d4a706b7944714b41787262325052624743317362574a726251766c59744647483759725461742b71464f4566654b75626e796a714372584141613453542f3333695a434354382b66484349476971397538706c4a476f4c774c59645337566849647178385536527341632f394945396548656a546f426332526c4a47634537394f596650443642496d4e363151714766585a636d343662726a6445343376634c68706c663770523475632b655a43656f575a4776304c6a4c4f644c2b50624c3137444a393376307364335546434f3278694b754e666c6158564f4f4561312b6f777a754f3943506b343866776d39535439572b697034684e34702f386377616c6e67672f386d396d6962446664385a59656c6e4d6c576e4c4b63786c48356d78367255565456486c6438786b666268766f6b3074706d454347663145712f39447648714c5a724d377a796551557a384a6a66643936314c52503465676d5143796f2f755468764a357a52725274597061736f345a4678656177716c4d666c554f2b514f6c4c6539726d754d6f776476726461774f6575572f663336422f707052484c645454765278766d7039307966492f4a76707765777a593378556364722b46733256334e4349336a49534b3878586d667a446a3742304b5446456468565235426b6935337069465a6c6f4f6554794e796b51597266456c424e303773736b696739512b593736716c5972564b53326542547a4b346b335168594f4f4a68636b5634786736674f6e324e4243737a4e59564e55527271702b416e463668484869544a653371365141774b484979336354496c5564786a61627a596258553247643068376b686a4938576e36566f534b662b45466b6c6d6e352f6551792f5a716c4b544c474b4a67766c4b73575a7a4d65535a424a587156723370746d4670726377416d3032586a4659764a446665583631674b746c4a5854526e383043662b4e6f736675372b486a78317342386c342b4f61626c653431646b317264624e71316f7565586a696767712f517754794a34344e5957742b6a68534d6e797838413538697a5853376f4d7564504d624d593666787436784d5636714b44682b544271307470572f796b6b30454758587548326e6a622b6d394e36716257464b4c482f4d723859717132664c6177574a30656d6f33675630775a5453444c3534694d5630313932644457505646536931566f616b5230673233796452494f505844306349596168466b334836456e45302f513138485832696f70386575436e474d48326c59364846557839526f32434b627073584e46763276776a415a4b746b737530356c52504f5671496e35303032724357765a6447436c7731373365376b674d6c4c3172786d6671466179706c73724a7173512f6e706b4f4941304e636367385946593644463652522b39736b7235586e68764876667336364c627033656576324b4b51494f5a59353134543957634e6f2b556e36557065727536592f67695135664b706f65594b653465364c4277703670567878703133657339564e726432716c755662752f4e6158796f4e54343261504a4750352f5a395a73364b2b66682b6841567853714d7464634c504d5064545533327230744e694a413477664d5747304f4c4c2b4445454364523333644b667a3838387349383131374568354746354c456f6869496b617832537644453436364c71516e384f2f4746616952563231794e4e4d6c4166366664617159655544574a4e45697548657a324757635734507034644d454139314b2b72395a734741594e436a5577416769334c642b636f37344a684f4d526e47526b4f4b554c7450674f523768654d34516673345150306d676a4b6f647174594932585362566d61487271397370556d68526350473033457144594544542b3479334d2f6261303541313132326d6c734b494d452b70726a71644b6b344d445046426130626b365766742f70654b676c546477714747676f6c5538354468626c6e7a4b7177434e4b64715647576778717762683867774644554d6f6f59426c5167627379775070526f6743363056437746773536355a75786a2f6e2b464244564f4c5239516a364545587355574e59466331555363474532675565574338386f4263586e35326a536474593255644563312b31316871543968754d757669595874674945794f4c30537168516d4b4d644e756765504f704472586731723543647a53616138715654307534536c3451647a3350524e7839424b547161307453326d6b784977737a55786368355468777143474f364c624466655368305358744f7a47495834755533364e4766396e68794a5752707756503666524f2b4a48525536714b386e6274736f4e6c52557270476b41726a7562675a69532b4e5776436c302b2f384668747a5135374356395647305478477545637369536e4671546d534a706957716c617455684156496d6367594e6c54375238464f55784c524f485632552f7968794c3238567249354f5a5547616d44314437396f7666733276434d67466a704e566a476b67507a6462417648697a414a6d6279396a5065653635473571695076323979492b314139685034316e617a6634347130696973574b6c637471666b416e4d55517145725036646a555933376b316a5975586c32793054314e74365678396861573747504d5451304f53714e436d4b3232516b464e315a59414c7747534f774e4b78524d4c776e487239684b4338776c595553386e397146356349796139616e6d334f753247655243726d6443736165754138526a78474859714e4977452f4d516546593052344f6d576b42344c757855534b724674655569443045427a32594a642f4254736f426667496e55776f323363576b55315447473135706a424f68717653412f694e6544767a6b785779314c4475444f66515148464a47656e717a7375373873317931496e6a51727a564c7a57784e42323349456f4e754c6170717836726556653739467337637857714c74333461685a513253743437697a72495476354e6d73314d6245562b49384e634c79667768573648656c4b336f4e4a7a64646c6a5151733862544b416e507457794f76382b4930533659313673534a76694c7848595574757668686e6c546e566566766c2b6f6b36456876386b77374d39546b71497a4966344b554276753473466635643571722b4d3856546658363767374959646a7064734d5862316464707076335a72466e6573623642724b344d434a766553737774696b7356326d79762f6e7a50794733357a447666634f777a63304149636e574b6e6f64466e546c47764d6d734c593330312b697074553338376a7a312b624e734835715a4e445a4d653754526b567333356a6151312f2f743469527436396a5750375274452f32574d6e5341787755414a777457585351452b79323036777a366c6963333446623978656f36625a786d6833314e724a766556746d334b546f47655a484f3943754b766246715047545975704264377741724e4f537a79596c75653233634e41343131524c66784b48724657785459787835394c616359377336675551344c436964386e4e534a494b637578456d6578336d30564f6d7242425a52466443715563594846492b6d5a6d3231585a74466b784671786265504235664d48756a6f777a7a5770367859766c51486264573174773251654b7746755778687674655170516f5a5472495a63785468712f316653776f53686734643269346d415847465474662f714c7663477a563233364656715876342b5436737147395357567a6473367a5664556a503168626e535045796262556c502f4137534e30465031547867696837444957586b315877766b324d6275456c65374a56626d7967323366644b387666376f6845633242564233326776706a6f54574a3164354875456a586875454b74764668715530756a422b684d5552766b6c4c373977455952736550784468354169436172464652765a49786b6d6d634b6a657a74782b7459612f6f4738794e48464c505964476264796c59566347514e6b3148755934585578397038366652332f3838773266757965546a7878614e4b592b4a704e6d4a4553333842552f34444e442f2f6d6c52583833646b5a504c6134694633484a6d304b6a596a4b707365565649624a556d38747a654b76547933695041487a6a7a38796955394e64706d655a526c71533857434e5377745a2f473762392f6977692b686d6379516877756967353773646f566b494265746b31716c466a7153366358707479376a335053577a544734717a754f524c445454726138355259422f655735416937644f6f2b486a77316a6150635979437042797145345075325051786e4a51385a61314a6c444c3638572f30746e6c7a432f766b5a7a6f49666b687364454e3354473044335337666262305168376d566c4e5531435742395731626c374c494232444537726c77657431753550622f4f79567a5157435a3459745a735842564d5147314155597a6a58734a4b36536f4c4c713468314b625478384b6d596e42745a314d45462b74382f71385a6e514e4e324c436c5236314f4368456a3631396a334e663958316643706a3070377765614c697354627a754b732f6251627649352b3263474d4a4c3933494d716f6b384d455037734a41324c485a4442526b63495672394756697875354c322f6a6f7951454d4d4d52504d314e56533134766f6351315272434853534937662f4259582f76646336764d47415a78364f67776c31466a64617a42792f424c5862686d683479545a6f646d4356392b5978704a656f536a2b2f76772f47775a637a794e68376f694f48324a4670346a3933516679644d393438516551535061644564667931773855336d6553693247763145304576536c792f5077356f73594755376a746155745a5069696d6c4f36746c44446138746c3742714a3454393937434161346167315161694b556d4a78725633684953632b55624c427a377934764955766b61443738733073506a735373694774677a786453527272795431642b4f506e373542543875457a75386c774b363332757756794e72484770314448525358706572765149744f386a67664765444b5048635476765836466d464469743450766e636f676f5a475258494d584b455770314f66772f6a523653576971676c62344e4d653175734754766a577a696a3039595552486835696d2b2f44437a576b726b5736564b33684d34375170696b752b55763336444d6e5955396358386359574154336676367a704b35533965756d52486b70366366785950316e3850734b4f4973374f72646f493877517132443078796e44476e574c436f4d6763594f4a554b35577752495a396a57463969587352354c76746f747a56503035716c64395a70306561703035626f46483569616d32694839584e7376344f4b55733353747737623262614e43784844766351626b755935524b755579646b5942666f3859313345567a7a5a35375a774850767a6544483771764778657a4d416852497542667047442b58514d4d327a392f4f4e312b616c3833527276457449654d454856455858736162722b6155745a4b79777236424b43684758733861622f306a57753261544d4d58534d5a76344850532b526f6e6951782b5a486a553361786a36346c5557616932305346335477695842744e6d78626e4d576843724553412f63585463336a6c3342776547516b624b46575233766d4e427535693976476a487a2b457369666931676d31477a624531665178335541687a6b5159535377365430326347505350336c2f473839504c4f4e366e4a746f344462694f7637785277416559345430786b624a356f61716d6c41356d6e6b2b39763979556767784c2b387a504c76417a7a79787359462f47687a797a77586d79354d7157666d68334432616f4d707936756f5a486a6e6152674577772f55356235695a506f5934564a52564e486b4356493739325a67454e4c765265636c2b764d494e71536e456750767251376c36473344526d71424d2b6532594a486e72772b786b526a7653532b47516f566c4b6b4d48707874595466666d4d4f6f376b74664767796a663544752f44657464736d6f43764548694845304e4833756845616c363674342f4a6d4339336a4b517833425a6d4545414a77663235522b31746349456b3853612f534f34684e767674794a57396c3035707274725261774d634f442b4446743564772f2b47346a6544304a6274497a7753737a4e686a46547031612f634b522b4b6d766f676333706a5a776f392b3953492b66345143767067454f714b356a537a7569784b442f736a2b324e4e4865617155726e70635874517947312f547252457932515475694a346d5436343868684a534c68332b67672b634a47626f542f6774505a7049525048525864313233343363726a79566d3261367062764b506a5874574c7950614169335a7168704534726e6c386b75717845564c70684e3861543932454d547145597a356931314a433142313851576354366d387274616750354f306b364a6d3962482f4669476d517836724f4f6154732b7150442f4a7866595a3265653132316c393268704870547374533965565345674a4b4172546143594f3366712f6557634c64574b2f67615338645174666f64547a2f467752762f6a554b44664e5233493461535533616f5053645877656e7a7541316d664a67345068336a4357364b442f6c4a72712f72366b7a584251643077584c65484e53374d4d4c5731386b467267512f734771576553774e58465365326745616431386e30647047382b7444654456694b4a6231315a527463575179346451456c563841782f765253486f7779336c32397634493372572b6156376a6d63776b69484b6f45442f4c7367756e68776a34366d634a515345556c36584c34785a32757a7958634d636d2b456d776f3870442f39776770717a4a772b4f5256424b354b79316e6c524c6e61676c656d716835444c4c61327834584c545671486279636931534c7958354e72434e465750445a587a484b426137553439647a754c6e616137344e59363333617a457a653174727a612b4130507655365a34656952654242506a4355776c615a4752706c68674a6a47695953746a30314e4769322f752b6b716f6a616a556c7264334b6b62457566697541582b63543738395677416d3973324d4171317367794c68716a78525071737073747374786d71784750564e57585a356f593531752b6f766b6146466547304f4757634b30736c464d6f4f4e67706c724a476c506b47473032726c56597474504a486a6a7650574d482f7845333633333942716d43546f38746b32535830635a3362594558474d4b425134763146753464472b41484c4d43754d55645675364b7266757472684c565842374c4e337a474347643448476f5349796c6349464a772b2b6358305971364e6a4d692b39355a6756664a776e2b4b556f7853595a7244576872576d476761756962317375704e56637276766a32343250642b4f656650494a3347334838465432634a4c50653854304938377566507a32446465374c342f663057634e4c6b65527774626e6a4a4c692b445a7633546d6441776e76585343654f487833484831334d6b546e664a71465a524b35554a46624d5931384d7545695677424f4b4739326b6131375579747530716c2f6951696f73796e70566e6d3556464f6f6c354a6338636d67494632345862504a516b5572477a507757667546734762344570526468467856364b666c6f2b68336a723477417446485644534d67785379333662477355704141554f55327477676b72313474324b4c714d70392f65704375325273305755466671684854776c68794c6c3572793239596e627a697356726135626c6b6542727a382b6859434e6c4b4862654c44594c714541356e64426c35784d68424736366d446d773150706965356a656370697a4b686e4c73484171313430634a646d4e63345050627a4b4a305135686d6e69657071664f6e4e6a584e32562b33757752626474326e78785a4e524b744b6656754541714a4b4f68674f4e2b75615a68664747724f74565770746c4d464d73443355467a4b6f554b2b58454f62507938493147364641493961496f776844703779312b4439785868572b33303864364d44543736376864302b7632584e32307442312f5675546139556b68654c5a75596462563656456e49675a6373767577505a59715a444e5347446d39594e506a75486e76395841627a2b33694a4a3330516a5a4f337975587a344f76445a62776b4869584858613646597546513832617a6e7a4c4755624278436b2f74717744716650484f6a454c784b416838674468696a444655686a484f6f4d34416337564d444b2f6171326a454e7232366a786f476d467456724a6f4974426d345a4c64395255704d41312f6235374a2f474e755356634951525055742f382f6f796d41653451637470777066302b6939396b6a545834504c444438737451644e54735a78793345704e476472436a6a57476d6e4e3677447747477444326b4732784972744a67386b7a4757676f6b2b75466d4a6d3250693631734d39313057725272673767707a522f7134464766304751366e746f5259694c4e516c4448736f6445586a766b4d63396b59637a3078355a785149372b6839493075556e5673444f444f356168516443564b45735276364d724d3766564e476f7a43485a634f786648473943386961446457793033553759773649362b5446414d373479306348525174366b7969314b4934716231324932725558646370552b686e4e77664d616a4564723964434f4459344468355a306c51446f313769686a304230386b475862384a6b31567542626a704849614a677346646934526239724e4764694a487748685272683347307057612b683646644c652f2b612b55627959724e6930772b6d6946346634487463724868796e3342514b2b637a6231666c4d6f71393041305a4556616b746b6179316e5447666c474161666e7a762f6737304a6a786d3645477570516f6e532b536e4b757177566c6551674766466a79497042453278306544695272487556765436676a62505831524a672b393373497465764a4c67586a6d4776797571435a506c56626d4941654e56764474743649374e467444473155543874557a654e437654724359393750586c6f6f555833636a675642796238524157752b6c5257557a415471496f68744a32316b59566957565849366a6d6b557673626341466f475a714e4e51744d734e42656f6f4d4356546c704c7156533968494a61394e6a383953644f6d584b752b746b304e5470362f504c716b6d4f3638336f6664716335457133507a6854427a5479787357376b4937392b764a71494c38513069337448477a644a4f5750497435597a35626d65425539666d716e6d6736776b685671332b5369684273786777722b735878644470754b3770566250674a616974474963697a4e484d3559363431397445367844584f687775764f7255597379704e694245743465667054336c6a78726d705a6c317a4b5452345252355942396e76633176474c477a4444666e75375961773633643769475637365a574f656b724d794a6c566c6a7759566c32504b417954486478424832474b30793272632b617a566474326f3231593354532b504a614c4a6d456735744f30785172692f4b354e7272384d4c4f5168466c566e4d373279535734704354644263784336356b54343230395356574866446a594e4d523579624a71513067694349524c423944415233636f6555486e73437459574e31484b63344e4a3058637748506b31764a536256374668637651676642444e61314c5a6858726d6a436d6d59596a764d6d79672b335761655469554c69356357384770745262796d702f50397833327a324f4b3073546f6753456b757a6f4e444e626b79494a526a50563059476c706c553679626c4e585647446855434a7168663157576c7a6b3339323873636873706f714e6c6a76454e644d7557566a647661636638633565796b6f56612f694963774f4c38793062786c756b5a7831694a754f6e516171525152644f4e54587a6e4346326471744b62384f445354504b454364717a4b554b33705163524b3177556153755773376139726b5a6e394c3368476d6f6b6f69592f3573757431597359484f7a614e65473943523543506a39413132396c67513043624a44305354666464585364493265464447714d4b4e53596c317a6f6a6f796f7a4539506a4d7175337a46757a4f6e74576c2b537758574a765049386e7054485753357436787a75536d743056757a484d6c6a73705a4c754f7077687177774545615875473652664a30615948526645626d7a7055496451796e5852337033706969725a4e6b586f476764634765354b704e76624f64304e5a433171346e6e306e666f5a677242496a6b6664516e314d394a637a6c4a6934352b39667332494a5841376532636533377938675369356f6d4871617270623739747a5664783462786c3368576278324243422b643468752b6d7a4b5a646f4a317162487a4264537131694b7652716c6e4f6d724d2f4e72754447616f4e7365426f2f384744453272526d696c733474514838486e6d6d766d2f63776f6448467a423175416574454c4d314176376564416862717747374b6a627163626b7a48302f4239746f477a72382f6a5739744f486a3852442f7537553067776152426e55496c556777727553712b7a75644d2b755a783738455252447549735a69744e586b3861394532756c574e51584733547278593477463438566f4230797346424e495237434f526d656e7949726664784775337338776756334866434c4d7143736469757a736a43577957317047686e354852396f52676a5255325634716563475a684779396358734d315a6c754a6c4f6756427a6679784b54354f6a375a4e3473486a7736686c77656f45584173444259313430455a417a484e4a726d2f4554362f367434736a4a4e543074584564534e6a475148344d784a2f46636f396f6c546758716569434a56557279642f52356354324b6779476b7532494a335062344d38516e344e4a2f48626c5458792b6e3652774649422b447442366d706c416e4c64426a61627257496f3058444c666669506e34645659356a5571313656624357747431347a73627a656a484476697a785942545144495575674770366765774d5a4432734861524a2f735759464331374e4950337658372b4942443354502f766f486f79525431465a695a647875383048615254792b4973624f667a4d3657553863767371506e4f6f6b787a4a6b4d314d3643593145416d3635634531472b4a665946534b3464724d496d365541766a6b59354f6b7852515367715a566a5557536d4f69713467644a523779396d7365587a36336a7270646d6d4161766f2b66415875714d544d313538766348343954333646336f696d39647659327658694e5454757a324b353859736c49544156343159576843696e6f41422f6d53332f75776a385468466e377a395476347a7045347867364e756b325854494d54305142536a5075767a322f6949736e634a34393134644d506a5345654e553764306d702f75324638324d4a6d43572f655763444c3532634a2b474e4955754c5a72506d742f6b7243657a684b4136483475726136685664503338626c676f4d486a76546952796b79643544315630687a4e4b654c3475776676376d4731352b66786a38357649706442796252706249646e7a74335373574e53777a667835703130797274674c6264793378316c3039356467375a624e627562303554702f566c4f696e7964746834495a573736443757424c456e48533671536b54342f4e6b533955517236396663656d486b717656672f714f67335a5978466d715751476d6f697a394861597452526c576c366e593362796c417a732f303047753341696142777138437933775a41584a5442653750686357797466454c39765431784a4161374c524b4359586850695a59363070444a64532f39304f4832784f39635a736431565344716c326954654f7963554f4b31336b44636c2b3675596b7676627149482b2b6d3537686e45462b377673374e69646a496e786844797759463630734c5a5a77636a654b6b626876565747784e34645639777570626339786839645a6c516c59357970652b71736e45563559773557786a393933373861553362324f434b583641693333715a686c6e4e2b76346951643763653934443338335a505875756c54635a7352622f524a504d6a4e5431562f37754647622b573338386a754c7549387676554c44392f466b646a4363764c5a47376f69637937392f6241524258597275795058345455657a426c484465526f6156375573644c7461785a2b2b4e5976625a4b52482b76305959766775613854546e6f54646276592f6e6c2f4434346537384f6a4a55543657432b5146796c564a594350467135716b563845627437627766312b366a5838355470436353544e54466352676c6c566d614765592f38513975797870304558696258714147786357634a5a654d45655a5a4354757338452f733254505934515652776a7a2b67356f526d756e5464435a57566e476e567a54384d374e39524b4f6b43636254766c73454671594444394e31596a654c46574e5a7131746a457045684b6571455a6a41714562395a726c686d6d702f79474f4641474c5864576d43687134496e7a724d694855526157347452307068303752654a424d6f4233526a4258426a70597a7856676e3348636a59585554315568756e317773323138745a2b4e6633743733575a5279774f694c4837374e7830774a32526c6132334a757174456b7268534c2b79544d7a5743627265502b67443363504a74424e72736e584b754b352b534b2b5979694a67304e64644a45716251315a5236316c6b565a7a31625a356d77614f6c545771717053666d526e7278542f35733764776a6f62364d442f7a5a486649734d5766386d54384f442f2f377431394443564261346c587561794d77474d6a4452307a57504f737169355150543550715944396b392b6177785444344f454f6834526d4777384e4250444c6a34777952592f616f482f5976415a33564b545862564a334531685668524c456c3857543056682f35766b354c6d41656a342f514f784e6a465269362f76524f44662f6c5a416f664f44344a5436724c384b5866797a426746494848694639624f78706f6d77646f67547263643333354f6e36696a7869576b6f6948427a477147676869766f3865474f507655482b6a3050764d2b327434394f46686e4354584650724853776d73504565742b7930386532454a3279513344314e7136702b63784f4c574e6d5932696a624c39637a694e6c574345455953756730336a4e74724262783966733145366b372b377a6739306c4c52496159714955727650644556516e42696b48677a6a755674486d70564e4769474b63506543723338682b2f656865723669695570743659334d5563466f486555736c432f376d785531327a49617259386a544c654a57483834746c46394a50612b50786a6f38525a6646367436372b38612f687033584a6c42584f4f537731593037736b474631776263516b7762304764545639654b544c6739636f543477795665324b3646714e756b336a3159546c75775a3672534251534e546e755066347461323070473138696b436f4b6741457549324f3179414c2f716b7a344d47317856587168447856416664796f4e3370424f3662364b424c6a747255475058743256556e3867695776626e56494d3264455955325a646d3979704f4c6c546446514f33355178302b2f414254617a5773617461504d6b75505a72534c6e50583437554e5550792f4456326262614c7646594771663732506f7935617a54457943316e78786c52743869336a7370342f3049455a693264763269397979576e79395639732b4d326a6557565767716e364e38726b2f4d7848442f7a6d376a643634333959337a6243664a35587935355366766e6c7044524f70494c37726f56454d39586641543870424258654f4f384452514c74676d43596a446b3332344d2f66584946336178564451393359596d685374616f47792f557a3541636f344c39776d6668326c764c4e735534387354654a75366c764868684e34344539485868346e4347622b5051576365444d5657714f3558575139444d3449317757393146756f30645762547a4a45467936766f704c4a45333337614d456c6535435446667a65554d377457772b34793556317637415642714c584d732f4f4c5745486e384e4661326c686b453062653657597a312f7874667a6c496a30394c696a4a653375473156477168776b466f6c6967702f6451534d6f31677155422f686c3944794669733947535671466b7476745947557a316a53704d4f5078326a77436a313037327a4a4e55696569546e65635a4d7766496d48597a582f69744b6f314175394e69745368774141686138755664505476566e766e446869765731324a486674554c5a4f4652362f3133756b55712b6f6979327a704e67326850615947444c38646d50624f37652f327538354f3762786d493669535a6565324c4a5558652f6948515437583259553237717a6e75574145746b7a5a4e664d386e41686158312f645533646233586475754a655732765337536f416d79586a30394651434e4e6278343773363843646b33773931423744714c574e3676594a6e4b54722f314b45303771634f5347615648464849505879715752636b4d61315776426f394c5247783767623632552f7578332f39356a564d76336b44486c56725773745642625534384d646e386a6736464d456e3777375a785a51455a7644464f77795071694856792b7837507a506b6f304d56677630692f7539356572337a43356a6b37367a54577a654a365536743176425659744643565a79694239392f313442646d684168527964596f7773654e48726272723178416c616a4c3266794d49312b696c6a3439312b2f7a755367344b364c302f54626767757a474f5a51485a5458485641684d7447714d395649537141586f46566e65654b2b4f5650475a454a544750496f304a392f5a69686b6c342b37313267306a614853463276577536376b4d43516f673641734932776a4d56726c784a4a444e4d42316779656c585042686f38344d67306e416838615371476f437930346f4e584a575948646e646f4f5634384b39783771316332754572494966687a32302b73764d64692f5741737a4b2f4d7a596f6d6277357555384c682f55786b34364c39584257744f5a2b6a666152707747784f7a544f4a4c30306e73475131676b47626c41534e415a382b4766447050466a34577451644e344d42734a305852485364704233476c714d4762416177793876752f6749436d50473275346c48575a663932762b4e6e4f466f56796c6658772b5a6952713478476c3779723173747449476d375046363762675a6e533071732b624d66474d66684c35347a6955744630684a495a6d396c3852454b3778386444324f7254732b5937435a6e5654634a6a4179654f78464837307049555643504a44504966333079694c392b7534342f76463347494a6e334d6847374c2b58426a57494633306b6d344a4f37615a5452424e6b412f727734505355434c5a56433139304f374c5937436c7a6a6b5772383355793468532f634d34364c53787369556e30326730476e586d55794466457a66757867724c7162555a6747374c5568486871356643547477514e4d31556e314d73316e614b4b32747a76744d3445614a73627546505a72324b7470594844426f463275704579395a582b764e6e4b4842475334467349555435394354354365496377464457696b70436f7337666467386b62445a42305943616771427776546474474159775a72526d5a54616d6f346b4177593878375546425a4e61764636643635566f66315635456e636a6870722f354b486165345578486e6156714f766556514b763375596176557878523467666d6c52776463414e4b583864714f515347586855303161615a6e30614179366c566572314f596652583247783935304235376f6d6e586e68476b57466b39366c5a7a59524972416e3842656f4e2f526d484a6c6f42727470426e364f675137476d4b6a3266782f4a7a78723575637648637667387359712b694a6575373936687178354a33395052624a2b4571674247716444624b58706937716c4b78514d6d77786a5934694663346d704e617673777764374d4e4e59526f6a376c364a522b316f465a6e595a504e784a756f5052534c58336a72483364594d52356d5838376c70707278747464774b5536673355744a376867636b556f764c34545150444b6e6c6f474366684d77314e4a61314b6765563733474c4d6c67325a5632564450326d476f6c554979474d457251644f593371307330306279753959796242537a4644416e63767573576b6b645873706e534b62744574734a6b6c444d7865737564536e4f51646358427042584d79754e716e703171666252554979426458475779312b412b374d4737637533313559585542657a5642516e627938527431717531546a35504f3472566232307a3433375074616267466379304b6b792f6d30485664303173384c692f5551634a6535466756365837553239576a445451344b476d7a5176637136556b37586630427a4544772b773175746e6259334f376a536c4b48796f72687067494b773452417a617135486b70524d7a516276377951507a5a6146484c566f566638784566433444524f79557633664272335a6877384e453750466d5a6c48305a6d4b30434e6d6d5045797539513164656f466c534b6747696b2b58375059734a5978585a6974756a4856574b6b69513649792b4c382f503546454a304e336b4a4a514e30506e494f316e5866643153787253576e6e646537466c6c504c4f4970376443363562356c56626c766c6f545549475555593759767250486873776f657465465430316c374c4a423638726a436c396275374d4e6c63646c467634614c79486270385852364c37614e72747370576b57486d4d43766b647433536b734c4b4732625058734844704a6f7272792f527342655041366b4556344e666347386455714b665a412f36414a516b433968724e47464b6a364535626b32706148426b6851324854743450666a417070576c5a6d6e736672746534646559715176376b6a636b74326152672f5a50586c716a46722b6e5a4b5154786d6e463568535773513058363731364e5a5351572f517a643552545873776b53564d6c4e79743039537370643139744351394135562f707a756f72464c79355770576f6d507a78725537434a77595538656f455459506645716c677661464a306d59683178412f724e485950555a366a6c532f4b556176496231696e6333436c666474774552564341436356594b6d59696634776964704c2f7255647770566131316a73647844495a6334396d654d583835726d714658654776474f52702b6b794145787155706b45427578434362384e48493751324a644942576e776e746676636d7a53646f56424738546139584c4a7a635256537156476d5a5a37765a2b653036396237594f366349716274543233674e5735504956624c696f665a4a6755637a3970677a686c695762416e63666774617a4c6136333271754f70376e515256373156636a6775417975697a74747773364e3358723245723832586361486b324979714c6e55594532422b614479472f6a33444c7571324461707772784d30316f4231377769667043563352474930584b39314b4e7474614d497a70534a50556462676c4a2f386b664651646363304e73306a7452464158507730505771415a4976436146794c59372b67616f75715736346a646437727a7376534446465654546a4d71687a705a6a5864466c47785256503431383971526f4647513961566d58497451735341716e345670614479624e2f4f445132744865552f304b6f5930362b3638666f4f4a6d6e774237715461647863323052554631647055337875665a4d3052596b77387443537851516c46414b646e65735a354546566347667a596e63755264655839715a5457466c656f6b6f676474316e6f5468454c5447656a4441384e717734514a4e7471747456453874625166307973303570756a5750437956306c527844336e677768316c7867736236712f6a527359736578447a5631544f70477278387a6d317855325a4e516a7967356d5a5344756f6c5546655470672f567131586251392b336e6a6c4445547143727147594d63637976396332365170666d3063765a764855735837306b664e5137625254312b5338674c326f76474349587837697076684454664e5371706e4f553266387933636f775254382b506942446e79327932666c4a446b65685974624c667a367254776d626c3742782f5a6e4d446a5634313451314e524d63692b575634554c2f486144714235516162795071666674713364772b73615764654b6d593334446f68463679546a6439386859427a7049364c58714e654f5346454a557a64686f46367853566649484755507a4c4f70796b6463717247376a796f30564c47547a686d4d3054744a444439544244646c3359414165416c624e35504a616950615a7a424858315773612b6938645471654942696a4a77302f516d73325336376d396973767a5738786d67554636394632444b6654754730576f6f774f567367744c496d4664324f6b334c32794e462f494361676a3275553054536936433945416c45704e4c313235676158364a79513850626c51585a67555237556f68306a76494c433349714e7443587a714b303475777269586c6f46704c773239384e70564246624d46324c66704d456b59466b34745a4f6d4a4575544b776b5a38467858437862715443453252396178777661564a6d466458773468564474657339314370634a4430524c7443455874756b2f743145347646757433794771426e482b587a39505a70376e34666649667632555065496d7a677361474f596d47495566575964654b3931514c2b2b75776d487269396a4e31484a684167363670526a743068723531514f30476134615251786f6462576c72486e357a4c596e4476415035756a435161483668744a3571676c337a53436162395033516b69644e6b624d3964327343377a312f46682b37704e6232734c35584531666b4e4a506a3943586b5a6e7541316b71522f642b594b75696751503034354b63594d784e64574d5a7445354367323664712f6643574c505453532f524f645348616e3653306370755575337958386c2b614756436c4e425933754b4f4855757a4f5555377a59753465666558445142764e37724f6777674d57314c6278306268474a316a5432485277314d4a33694b666333335a4b61494e312b587a39504b566c2b64564e76625737683958656e38536f507a447a706768367554347841397a3247754e7a6c456f3564504932487950456376766541795467523074704a476c653571556d474572384a764c6d5a536432544c534f6a6b622f31306c6d6370354665724e475175734e49785a4930796a615731786c36726d2f683464674b446b396b6b4a6b633553456e41526f4b59376c6174514f696954645633552f4555427050704b31727563724455324859332b426875726851704952547854775a38723559414964366f7a683464425452514953616153643674756477683739666f36664c5669744744366b6156434d454e42736a54706e723571554676454b754c45727965743967442b366e3571726d582b6d32462b613238667a7044597a36562b48632f496d54626239695a3975746354494f78397259645356627a573650756b79647a556331505557687458756f6a32546d4e7235314a34634868354d32366e4538356a4e6937646b723278534b4f306d63426d794d54694370533430715042306b3779673061394b63595952324351347a7954647572754a6262367a685579665357476359764c6a4b744a6566396452344a35362f74493033467972345679637a314245392f5075673051317537627337684b7a49525242673375434a50623159784e314a656f6f4450646a6979667939383473596f2b4e35676b5369534c7a5668513238503150456b58316447422f7373506b454271574568617a73786558773150352f6558344e7a373835682f756d34686761534f4f6c3658586b476956303876413854733570675072644c4c2f766a39375a51766565486e7a6e7268547844526e375174764b62617873694a762b397172756374374530574152393979336c3841396871747a3637697a764d5a31387845693150676461657761364d543661673566666e6b4f352f6c514837323742302f7765397a53594d394f4852774d4a33337434686265352b4634494e62457351636d694955637644693353432f6b78635a5744522b66544a6f4f366a586b3473584e7053784f6b77793977376a62535531347369754d57444a496271364b55317a667957494f64354e566632682f44354f55454a366c4531487677394c6d4a6a343871716e5a4a464256453866502b2f6f7230326a52737a31364f456b794f3849457a6b31433748346e477165796363336d4f6a5739426566616a3933646c6e7a68322b6c6c63362b74614275544c564370634b49614842474f2b6477323970504c6532557a674c56733255595a5262316b614764794b447068664e2b784642664470306e356c705770613654433078315171496e4c4d4c79575a636938724b526c61353165616856666544474863556f776a314853476543692f506e56416a354565656a7a65364b6f314e5565376a574b517558487576724d4d704f32597a66436175717747694255302f58376338526132527232443064776b634c70594563416a2f43666d777456476f59486e332b413472546d6d4b6f493062524c4e787475375679376136585979734959416a615961507a36737a6478547739354a563241546b4b7869344a734c70656e5277326a6b33544c51337437374e614973436250614841472b5337646f4f4659397a626361583830794e65584772677a7659496e6a777762552f2f4772576c36695a44397a453175734f375565592b36364e453953667a62753464747572546d762b7439665659433748464853516c673061506e2b477a2f2f626c706a4648577566745144375651686a437536765a324352386543324f7374357469586746664a74732f53367268454933337354466d617147455733447064612b78435a4556766b35653761755569336f324e2f444577517a5761437a7631626876584c38596a65636a6b31476a687637752b566e73505a44436f53474e4759675a2b617653613131644c5058453533554846537664616d7547777a2b2f652f6a70594e4f7435685452364a4c743469633035626a746a696473756a6579503774537758392f7434694666425833444551595678316a3548336b736a36366d3571687273674e386b755675726664376f345158623931653943732f564a56485863497247564c4a46496966506956306962325a507738425236793567346d2b4f645044366a7049627a5473743632796b5731323173626d744a70505a3931464456736974383653614d6e4d3844666b6d6e2f396c494e75354a656b356e655836766a6177744e2f4e70484b426848342b3745484873477a2f2b6e6d39684e7032306d784d346f526a45316b3451492f2b724e5a644d306b384732315769704175446a522f7378305a4f6d4c6865787245706b72307059374c4a326154594b354a57367151626252636f6558493867766559666e6c6e426f56516231334a31417669517a5976514e627254564271656671674c542f51797a4e704d552b354449475258784e6a6e2b61534c757064685766732b6a65684a47736f7a617853367278492b4a4d4f476f54546c5a694443684b576377312b647a794c4c512f543565337577743763546265364c6b5a71474d3555632b3631654c4d593150306d764843492b2b6e50716c5531717256564e3865503758694d55656a424a52762b4e5a5a7a514462715768556173744d73727a73337776642b644b7552786d313038526b7535647870514233534d57394664674d6155614a4871376869626c74302f42784f5177317a554a49486b6f53374853704f6a64483162573256347134356c6364514d6a4656573937485961393352306c595a6a716749477a5453746f497962394d644b56676d68614462446e4c4d48433976414e4e303561646f464a32615263725449426c447a484a417034494c7246757239414b6c756d726e473659687774724f5959505246766d67482b734b594e4c6635716c75344f783841323875556577646a726b6c774f324157787350647752543365564833426b4d466e483874704536584949445854776f6e78684c3439706d4735734d632f4e3831334f4c56627359557a3851704f657a73685254457571476f376133436b786779746a4d4630685856506e613550793067663436507267726a683935645a3265746b614e74574a466579466d3166646b53455849654d692b4e356939525452485873306b586f395632726f4e31704c5a33476f2b6a3665474c4c4f366e7a72576a59574765386d543131727136766a66353472346e6e63724742684e344e4d4861444142686e79746b5373626d2f657875363331387a5a57336d764a7732426e41762f69385631344c636477654830624c3138763470585a4768372f35675969544d4347596d4872534649336b374a467a6632334179584b6866767462626d7957324f486276465a545858546e54686e6b6f526d4a44516338796f61624f4656425349336f4b4957612b356a6968356f6f394c43633657574e532f304d705036376847362f6f3455366c743574434f366c5a535a44564e54565464452f58486a54717947536d6b722f366e71526c4d526d433164694641787a6d714a57633579336d746a77482b597a4c353631384953783856682b547a7563487a4a4534356263616f424a6a6f70586870766b654131304e613035544475384e6e446d6170644942586d7a393762535a33755149492f373070576a673165382b326f4f52363373385a43346b355a727736575172635954755a557877664346474b5a525259647531696875384e726c52745773564633765a5264626c6654544e4b53305150692b48525364646d556e794661673349726a51685376676f6d5970524d31683173302f69554e4b7877665a2b6b6434356c75717973576153786c77596d494f2f7a754257683770434c73717461614435444d3251346c66516c4868324a34612b7562574973584d4d32312b7861337347765035624263472b76795442364e38455a5832746e4767356332716a6c754c65576d5142767a533965753337766e7a303867662f32326d557231393744513746644670594e324e3141797170742f62562f5452582f74563044315952746a6241306463613964394858744249526c386b576f39315175342b38464e79704d34326d7534474b37326f4d76612f547756517162494e41517470596571334237673779563744626f5771554676786b6346565a476d4732343350787575454a7063504e71686871324856716674336d6b434e4e77413339524b2f587068716e614e4470614e4b47394773575645587558314e706d6a776c784153536b6c7531756733684b4f3949684332503846765a346e7564674836333769746b534d6a4959796f6230323271646f7547422b356c7357346a674c6c69787956587255524648717a70374d41424f6e627578674339317246655663674772494e616a6153367a6f376e685770434357554e52524741315577715859595144426731756c457047487576386473524d657a636d4f6c79477763375362335151385446366a4f376e715358325256522b512b2f57364f77566366502f784d516c79526474536e717057785952674e63644b2b6a5a494f6d6852777938464d645747446f303158446d7476613377587a3845456d533572447277744876646232325862585832316c7173585834447a4e6b4c447155626969504e6579692b54796f384e78753664616d615a6b73464b785a6c4247395855797170706d3467744c616c4a30755733583430575968636f442b323377726b64396c2b366b50626c466b316a7356694631312f72736f6d753559794d6e38385257755372324a674e327a617475705244675477546f7a704f64794b327455424a496b42454f574e65735a69745547612b64524d526d56637046716f53574a4241585443325866684e633357736f33527672685a75436b6e485557366a62456b7a46634d7837314e6f4d6d3030334e466662726b705145653569474e42596139454a4b7575747458334761625559706a542b4a32687a5a7a78757a36744b626879335330666c774e615a3346444e746a436865774f4865386d353357426f6e69697044654c50616e435a7945524e776c4d316871666d64744545642b6147716456645849394539346f31666d68306b75515a74323145306c4b4f7a79625a62447765734e4763436433717052707a766d732b70306b75667073534c62323077634d67506b356a7857316f58624e7054624a65754d30686b6d5171704151696f52617a587834363456646c796e5658424c664a334f4b75524b7a71765a742b302f51554a727a576f3946796a65722f5a51466738704f4139384875546c78653362544f493133727530544d31355164384e4136486e6632666c4775694d4b6b5151474e463668734d304f4d7568556d326b4e4e72724a47554e503458412b6b6c4c7474636b545650494c6354734e75626c41375538756d6c75686546725836784c6b49577954792f4a47346e6244737867626175594c4e79417778732f465a595a31626f616c515671305758535a6346573753784f7075426164755a644163675534536344706c506d4e633361345a75652b41315a6b33544f6b5531365a4f5552556f61735a566e73636b7132494f7374685267733574545a645449612f4e6647713759557658442b765557516a32325768476a336e537474313470696f4c7a5466584c41566e6838575735395a6c425636372f594a477a333948314b476a7556793661735243594d3332534e4e70784436722b31767a77445343322f47342f5a67794c4230325858565a556f61724d514e3837726f326f616e7237716a7838523130745846414e66563265524d39636a5a7273395931586b6c38556b4e645044716b30684d4e587171684e59417562617a476f504e7a314339676e6368714f6a5950746450594331664755634c53334c6b56316b52676f2f4a623776413663663363347837707539703276574f3162526a717a764b3633545369766c46395846786a425a546b654e7a726e4e3343446b61732f44614b75513156456a5633797033634f4e747338465451346c5266376246574a43344858623771676749386754475639577147676f422b793631657472684b2f55682b4d4d4c4d516666675244524167762b37355a4f7865713244567033506264554a715775597a3663726647584563597666464b42702f526c66307a7869514a35554f454d335076424c4b725732585543706b43756d764e4479324f4b4a61746a6d437862496f3256706c4a346f715936744a567534436a66503233537639484446557066493165774465524c524c453639624f4862706a6d723855497434673133344a6c31722f43376b30472f586552643573394d4a496c6267683533592b744e6b31396b504356646d72347a676b41655232317a596445745662386c4b52726e4865614868726e696d77796c336145614b6c775831574a717945664851423849467431574732453156614e716655704e433445694b7a582b3061636256423133454b2b536c77725872704d6b384571326168767239354a6a32795963735061376f486c6f2f6136306646316d6f44394c4a764e36362b376f547365395238686e6f6246683778585533482f64557447713275554932724a31687362786e526f32795575434658364e524c4235446b46734c46504a574d7a69646b48396a6e51367a37357978536138444a4b7636556a784e5a6c4f536d32332b5577614b45396d6d4b79397a5a5954794137726f575450756f6c5566587078743531624977736a354b714b6d795773622b575159775a6c7a6158305668314d32644c395a494a6a43617565304c774761766f57637553787772714667517651705152506d384876493337484e7638677a6b61584e336b69626d685a3353355956592f6f6a304134695451334a6356346e365733724a5564313675704a374b6c5a4b526d52745430756a3245366e71324c6d4f476e666d5a46567859794f4c435674747539464c7a526a7251787636344433736e4d3468315a36772b53334648452f30574b595745476370534f7750643271703155764a42493167765644437a6e4d4d4b73396f734535734a636e4b714a6573695852474a686242566932433248556148703253636c45335734764d5672626d5846457334594a3754654c5764535958315044566365717a5a52576c7852617757577462484f4e415a7864423442336f794b5373464570354b4a5a4e6f354a595a67674a576a72785a4a5056517a7149647a646a424331684258644f417632624d4c79367334505a38795761536c545853694672765941383958303847335830707733466a715467756b324f544163647053437338664636396332504879386d5a554b767938376e664f7a32485a5837336e7045555074796c4c697047717665464833685146692f6b45436d7634353645427966326438474a4241776e2b586445395141584b684d5170764b37316b7067472b4b4a436959364c4e507a4f46586350722b4e313262574d63634d7144644456786c6f32786a47335055732b693676345553695a535731415a354f5851386947554d46646b4742596e71476446545a6a73386b6d514966506c387157396e4f6d6130365a71397459314f756c7874664c48467a38336d4773673063366f7369305a6b324437646362316a70544e446a6c7673496b5151383067364468703043394554766e72364e6c32655969586234635a49613434395074457a464c2f4c37623541596647552b6a7a393564513266376c72486f514e39584963516758634c4e36314e6e636f2b4d5579644a363143727a572f55635370363574595a43595737512f6a3650352b44464d4f79644d6a4c537958384d783044743374496b5a54322f436c4d3179584a6d4c63594d3232616f5664414333346f437671327057717a5170644c325a783664493872717955454f2b4959506477436c314a4d754161536b657666584732674a656676594d4d5166593965377378544b61394d3678614b69397974505177334748453561727551326f5a446a61756954544765643257792b66714830356a346d412f4a5652467053446d6967326334624d57337037466766674339687a73517a65392f363231746e5844422f693931376672644b536130566f786c7231745651344e50487468426666735475472b2f6f54645178546973346f46395033622b796473474c394b5352644b52627936564d61766e56724478337364374e76585231784665714473316c69704a547a6764374f6f4d4463356c6c4352616858722b53626566474d6455577050487a67356864363432793073466c37684a4d43516f3448314c3038583866714e5454793275495a345677624a3455356a344c6435516e526654446f635245396e6e414379796b58305548596f347630564a67773843523836454c4a72644e57477270433451614e2b5a364742507a37443737302b68324e6335456a4d612b336b416275695242334f4e5a65716f4d45576c6c62785a2b2b756f4b73766a70393449493077385664754278765a525a4a306f4d4e55366e2b6933342b743452422b6237714b69322f4f34366e39485177314562636b786a434b76434c5a394d7572654847326964476842483734766a526c6f366862673656467037634e544456745a73584c4d397634793763704c363251664654696b3470596b3458776d4b4e35476234514e436f5678464a7658312f444e366a4e74714e652f4d43392f66784d386b6171354f586856304e776d4e544f3358743964712f7a715275722b504b70655278663263423942796c5430546a504d677a4a4734706d304c79474e704f6e4e44507a5755706e337a363368487632646549486a6738695153796e2f6b306c564351684d5571532b736e64335a6a624b754c46613274343773315a476775315430615975617156457950757131506a7a654c6838596a642b48727a39676f757252587838574d5a642b5a4652514e5a584a374d614977725033795864656c59635a3441452b4f716d68762f345859573879544b4868674e6f70746131677a44322b4a6d415864545a324f695a4f336f587172634c39307538332f4838636a2b7041466468774179544b735671424e325550464866576532706e452b7a4a72656f6335596d5675323042656d6276575864346f4d427848382b4f47553366682b6658594458373152496b506477722b386d396f6342644e6f716774656e694a68675959714635566c4d71555850766a6a6d54782b37303265484a4b33752b6b35726865592f6a4c54362b5743395964626d4d6e354b4a4c57384957376570446b70725a30425676444c55533070495347724c4275637876556e5561676e66615538556f706a4c2b6c31766444553336634b375a4d6a6c4c4e302f6e6c4f73375445482f7477563463376b3668717335686c6642715164583332484976784c52426334556344364d48663331704256664f4c467374576f5663386c36536f673370642f7a577a782f74786873583176452f7a786278485963532b4f3539336479736f463333322f42374448706f4c56576938342f796b3042326f356a483337387a6a3566504c6e50392b59362b4f5066466730334b4f5563596b6f62364f2f483647395049306f672f654b514c50616d3058582f69432f7574336b747a59653379424256506174494e5366476770757251674c354663623254475764466c424650534a5a7264474f746958397a7368737658364a32796d6a34716231784a6941683077716a3651367263464252705a6659316a6e3368614e746353597163444d78566879764456686a367370552f73766e4e374777586d485735384d68636c68374b575371646b6f396548387a58634c48392f64694f456139546f4d56695537443851363354557367547756764443574f5461576f324432475457706e645855776b356b2b663466686a517a3870596f486e5179544d524b6b702b6a39376d5362754b2f626a313935764a2b4d6578536845442b442f2f67454e4a564779366845467a4444564a657a4e4d6d357a53782b3575565a584a6b725979784e6453436a32766d675355352f4e3950456c3269672f636d344d646832773450617a30574c304e3431563876474e656b474c423679565959366564462b536c55356574366e4c355978476d70674d7533465041317349757a4654314273397844442b4b6e7565346c526c454871745a74474e76714e746c464c6d67466e4658517a653779387649582f2b6f315a3670554f6a67794872654e356c524c5572633079586962572b36323777766a59305246534279457a4b6750795876652b614b6b4f6c69695947745a304b307471584e3979487339635773613362717a682b4744457666645a6f38574a7964366e526a704531767958482b31487a5a393272315568684448397356347a4132686135612f626d5751336261676d726c4a436e732f3067392b38686f2f765364713868794c3365346b6838356e704d6a362f4c344c506a6f556f51704f7a612f75744a5439475a364b4747612f506e63446a4364673045376368774f734f565449414b6238656f39696f6b54633365475a576950366a6d6e7a48564c314d634c6e4f724f4f7045524b615874316b486b5930455559716c534758456254474332646e674958314141673871754b793564357555504e3672587332545350393432552b56456947353847624e4a685874356f34306558426633363046773243633031726161756830323576634b773630754f34743144593248426466634c5131393252774238384f595a78476c5534354d37327374444e6c2f75524b576d5349594c34706c316d33746a70545a5259724d704e6e382b6473757a596e44694b796748332b70454c784a35745567662f626c6651726a534f385865476966487537396147684f4854644a6a366a6b626d626469455150504e4872664a51484b5652334a57417a5a4d646949567865474a424e374d746b7841462b2f6d34544e4a5435306b492f7a346d4c70316b6e61514e415458546549645678555273656c785a2f585969432b34625859314773636a34393359312b6e6566613368654571596c72686646376d6e4432533870752f704e6a426c3266595a716c3158567139726b47324173447346794c5054726b64786c776c4242443936714263624a64314a574463633355584d2f4148752b63634747667249486e526b756b6c75757971447a6454616152635542764442356f74584c5531752f6d4e62464679615132355845346633524e703462434a6c6b2f704b644f30642f4b4a4272786f30795a30773350676c5165673068594b57316d702b67312f30763771674e5a564370626136504b433563314d4a50615336636765342b354e42682f6a415a2b315a6a712b4d43627253442f453079366743384c74797963356c6c3670456342324c78527a757155734c65496e4831486f66354f634d4a304a5771755033796b734156376662654c52483562744e4d31344a7363493371744e76655a7357536e584a7041684149554c4a4d4d4a4b506e464b7a4b41574b6d326242625a6541453656476a596b7a61376a3157422f7a555a514a343061614675534f3978324c5274557133484d6b6c525572687355456958395561376841385063354844624c687656356b615a4f593332786e47454239574a52473354506549564c56533749384d7439476e6b754e65376337574a6a523830764b6351365976363055744e634b31575246383853752b6b63656765597432713361756f505262507051337769494a6f756c66307172336662712f6434524c31662f523553717a557a2f6a6f57416158336c676c6c436c625a6370386e6a695a6a75436a5132474d44616249576556744571546b48674f552b6a326275572b386758732f6a6c686f665a467846445957306d316e45736c326f2b72427776746232425864746874514c784451765a76313448632b30493034586144595a4b384d6b794646465139792f6972536232716742444d7856545443626842726d76356d505235306d6446494856764544642b6957427a68596e616d4b486477677a536c5759756861676248326548335a4c424b6d54332f4f4d5550396c6e746e58746a644b704c584d7a486d49722f31613135624731366a476251454979396e5248724e44456d3345595a4e7479526b36707a61727356456f4942645133317079626e3158676656597a5349793158316c486747757a724a4e65553946757430713645504a6c6a6c78563478486a4c783173706374316b497366664e6f5a616a366942484557317a66487656586b365345422b376f3056444b5630523754663676733353747659494430544f747a4c45463831446449586365642b475846706e39567944634c72336e796d643744326b683336356a69393354393566677464302b755746657369634a5672482b304d7552314b7a4651396f6a5673356d72546e65485933764569626264647a51357474576b456470745a766a436a51764b33566d706b41796a3355496a2b794a365756644532743763746b696a3573515a6e3955696f517258746a71627957652b7771686845774e62646565507448626c4749553947635978345a536757635166507971587a677838616279436169534645566279526431766279365146696e794a614452695179573874626f31514e694d7062624c3748717364394775454c4b626f796134562f7637517a627a7330334c543754455141644e4848586267787872626e44466334394a4f6535394c54754e436a75645164367158554b422f567a497a417a44654c6336724c6c3566696e7a496576383851726a36584956475a514f734e66567a54513257775a614b6a634d634a66462f504b5a493853464358726844586f6145595636643832567147763466694c47304e3677797747635a7354654a794132576f79374c7144536679636c55625768755731726b4167533431544c56647737374d4d43443941326a56415670774d556f51384e4d5275754e747a655175306f2b634f326a53676e7a36544f48726a7a736b7a44726258733733525874395a455938433730306e38612b4b686f6c2b6a497430362f4456562b3461394a7270626e58765476617a42786778494a6c4b5067696667716a733731375a5937307139626656664375735045614d6c676f52424250305676734e6d316231517663344d546a4b61764a57483731323379395a68464971344e49383747632b4551734d47596d745638644e7161385371786775323750345776366c375144396a663459684a434632505a47306b54576c664a6162517679696551575367377737756c7a62725a30324174586a59686962725152334e4757556e7848567462543875354175366c594935575a473162476a6e3750616f625937563932385573745541566731687153612b733664502b373361614248647a794f415761596d375379565270537633346e487256776f767553646432765172374b642f4d61696d453330446674354b6d2b532b704168542b5839376c6a4143492b642b7a6c656c33334f54644e652b794f75663042486d75436474762f66627076534b43613736424a6575724473794e6b645634427130585851516a7832586f593773635a6d673878524f394e6344336c6f5768495473426a77467156484e434e59587a326b5052617a6278774e52494c3138624147355270574a2b426432634e656b6b35314f77432b4a62645379696c4a4f7a6671654351704756583248456c4255396162686d4f4c696931416751727833464834646e6b51315776387438447a4353624463654774676e7371306273316e7244757148386f6b34383775554a75746938786d537677483861457331464d54527246664d432b6b56565a4c6f747433366a42306f6b3774524746765130334447506d764a486b4e302f796b79447248694f564c3536366d6f536a71556c535461526f644b4467566d6254716f6b4831552b61504d6b42566c4a6a734b767349546e48376b68743643764e78703053334774776252686e6b7646593633577a6b74625032484c536b6b4d61796d624558355466623032566c6d696c646730725852326b70386e77546a4b552b576a42386b58564a4651356f4c3737537137625a757856554f657a796e78574e642f577a6b617630754562454c4d65447a43642f51592f724a364e5a384c456477654770397071673364513633725741523075595953656b5575387a2b6142326e755645346f6d3976626d33436264346b6874496b686e7773377771477746525732726339514a61674e3031634e397a6263626d7562465174582f314f4e6e45437a37732f52427664314a6b302b612b36737036736375486350745a71753935656f727a2f5779495856386a6e7559646d752b6d766f466c3179677a36626f395777634b69797077686a34456845756d624e447062757a636970723149596437746f7a32426e58586675634f3931625a2f636e747469767a4e46574671525251477a51736430764b726d66306f6c5a2b626e35327270306d38506430354b64373375737946633575354e356e426e772b7553414c755258595046394a4c686c6c30615a42354d684b53476a46424d4c70504e56565778574d3232333233477a4e4151644457766e4c2f4e4d504336463867706269762b437a6330725457723774344d70756f48374868615a54564d746666306850444f35614a642f5a73696156656d5a3949416c35496d456e496a6f76514d7568395a6f55315a54497a4362346b686f554b4a516753665246353173616a6b5a557331507454776175724f6b57457831506a3962716d4a4655775a354a504f794865696764366d574676596f43544f45787a6932715337453468544766445155306d4231595a6c59674c7057376265506955556641664a616e57316e6e6e63356c6c6e5a77534f6d6d50627a446839686e306231686c6b5859737157664734382b4256432b2f6a7876755a2b66723537307244372b346450324a36753454684163664e574b5878387639574b7a5733505a2f7672522f4b62327935335543614a52744d61734954536a595377574d5649714f70424f5a4a6c51696656715334384230712f5031594d324237316641304c636d797731334b572f75594b6c467367545454557732656f676e74506b464e45364831562b553248547558566f536e6c7573516a32796857434c7a487257422b445661752b707759686f6a714b7733722f754769542f4538444b6d42337752397a4b6b646e32486957666d78676573654974324d6d7330794467396b3472314a4c2b59457138364c4e314359574d5633664855756d62452b6a64624f3464414d6f76587654415346744c6152687a32426e525854417439386b6f385158346156305758494b6a737074557954695a4d7a795a38704a757268412b4977676851665669696d43357450317567444b50356f545334584c6e6f386c4b6b4f6e51527569674d566363714c4c666f2b6f76632f4c5076542b4d5671676f33694546554e31365164334c7936504774346a50556c346370366577364d47434157333272435247633876356936666e3932555a6a5a305a4a6b647352637a476c6576795955573751574f394d4c3550777a2b396b786379417153594d547654596744686466693673364174576253424b336959414e75316e4e30704e6d3530685a794578766c7a53774135314235567838396f387375542f746b7374334f4648552b7245385177776c434875472b354649684733434a5a4b68684659336e426251626e474f653535695775684e7634514d316c646c714477486543617a6939736d6272696135412b69464467316269674f71574b57733372647430796c53397841664d4e392f6f346262444e54394766677932334774544444363056434f3659546a4f63337271786a4c554e416e35794f7947693139366b6a356c666c444a4b416c454b6e427230716a5a326c5875594b2b576659774733674b374d33346b454768626e335748704d4a697571536b6c6b6f416263316d724651725253454c45544c7246537342544864564b506c51335a484d53754856354b764762644452484b546c35744e4335457172306e6c4561546f7773666d367a695a6358387652674e48356632373244674173566951587058545276745748755842746b756a5974495554765775614a7279686e4350714e58612f5436303366576255422f6c2f4e4f6a6841656565485270506f6f526766596b677338494e6657797a6756382f6b6348427245352f4a626d467163676a78544d544b7644663176427267792b6376324c41324a524c526e65767a6d445451383132394e6f4d5a72756e7a42587250706838647a4a7a5450437944664b6575323963776c50526762494b732b6b4150504b52444d736b516271397563516e6c775376755542636450475738756f7551744d464c5a325a77615a3545386c414d716246684a436e52484749346c474c784a3474567a4a786e676b475a37424e394a4a7233445349554a646e4d7337336b32717078644f75615271305a593847596d7468514c75547835646557384736706a51657056506a2b37334f334d454245646d69456f4a66616e6370554a46354c79477a783463737456552b3649364c4c395961464a31306f726b46744e6172756253374932356357385536326a596d684a4b594f64474e587a4766466d5a6f6d6433577541502f7057524b70647a44516b306266376b474542516a394661753672466c69344c4d5a3548464e7054462b525a4e5257745a6b2b7372727437475735614b6e4b584153493555314872477767554b2b676c4675344b4d6e2b7268525650643937715644436f65466975594c4f4a6a716a42766f6a36724b72683341617a79576c37657979505245635878334c2f6f794d61745071744b414e724e566e4b57416675334b42714b556d66704a4543726b61744b6c5a6e6d57576d373976576133652f6c6347676c77386359692f6f72436534736136662b695868694a4a326d4559566478344d2b46795946394b68484255324f642b4e507242667a37633476346966494d377037736f4546457362425674484758787455703435555351455051745377584c73376746657032437778767536614738422f3767686a7975396530364536654d67316b6c64426765726d4964326257344a786678723353444e4d706e466e61496e7666734b762b496e5149456535526c5561327562364e7633336c4a75495433666a307830635155636c53544c4e4666645a3163357a762b666e3944654a4d4c39356271654146727355624c38336a6338666a566b6d376b48555a413132434e6b6464387641775a617836415265754c6542504c35617766323855767a524242595a5930586e352b336133332b4b704f6e316c47384d306848756e34686a6e46367654575665687a613256734d58593255646d665941764a4844615279354c737a30333169723438334e3552436753667a39314f4133754b6b6d77316a414d6e31753545496d487363574d386457725756792f746f77505a70677442524934736d384170376b677a397a4a597177725941442b5a48634d66623264646f717633317a444731647a3245666d66354c365831394937564165647877506e32324c61763246315370654f622b476357376964787a745147716b31374c583932645738472b666e38657a482b7643366d594462792b57384b325a437534687966746870755470564d72563944777565666950624c5536666d634c52587a7a7a4249324b476b6347497167794c4378536339304a6173424a3852736450632f6479794f5a2b2f55384464585376697078776477324c7072596a626e774a4b4f396b366130584b765a6e466f694b3132425654412b467833454b59372f634965502b34514e305531573076686d64377a6e7836685636644d382b61644462792f3273434a417a33596e66525a46616d4d524f5539646276615a53644439727444666f5045664b664967793365576d4757366345322f2f7561562f4f754e4a79325355374f6932582b2b35574e4676375649304d345150564172575842654d6f645061436849356f5a4952517548733669414445593133743671347266654f5947666f4265364c786138635164386e51766c6f456650746942767a32336a726658362f6a58393065784f78327a6667514e3748506d2f766c3962593136564e335336347672654f7453486f6c4347512f542b697338545766574b526a5457496270437850454654467648623270454c373258685a7646523338784d4f3947504533646a4930767a7343534a576d4164566e75645034374535325076514b7766502f656e554a7738514b347778644963627774326a4d657a4e687a63664145364d5a476d4d5958336e74466c726b5a62356a6b676d44683852705a352b42524a757531484b72444653527172533552677a3348742f7944383573344d64486758304d437a6c757a6f2f514c57646f7246667a6259777766507a714135314d6e654d45707a4654362b3247437855673031413072774565313244622f484f3758736162383174342b6630566a5063516e30544465487532674f346b724f6a76346e6f62723349782f2b364a487477313257666a6a585262687736535a5773717774504d4b46564131313041336d695772456978544f6a773239526672317a62774d6d78434a496872315730366e4c4f366e6f4a4b7a7734523461373864432b4e4d70725732546d33555a66545536306d316d735451383766516c7538724a61714e72566430582b742b6357692b5466696b6945685a75396d47586938667061472f737a51667848697559524a6a2f42644d49386f354558706a2b366b33786351747a6a566f4d32643671493665317572323767563136637867644867316178516c6f50387779627279375571664f32385366334248427374494e424965334b4f5371682f716b4878703832344575733030636a4f44724152596f352b49647a6d33535646627848636251377876436e6f616e30516e6d6567762f345a67357a4e4a356666617a66514c74376e354f476572524d68684b3945497a6f777371494f36375a6362465a6c4d627836484155362f51552f382f464169355349706a55464c2b5157394d6434736e3862793874344e3637427642676c385950655a484a39426b656377796775394e3572624d453767586c2b742b396c45676548592f685a38347964472f6c3863323549685a4c716d585879456b76667533654a4472694854626e58544b4b684671624762457a6a4d316a7a4b44484f6f6e73616f4f32716868346b496946667666634e704938644556366f557955486961736b64596545727431664f3475445a744e754f4f353755594b6a343238746d346e783455504f2f6564756e795a4f44336138496e4f494e59314a34454746355157536d776c3758434f6750397434722b66766273487179747244496b524d2f613653574b7534557561305278374655534b65684172482f503558492f476a446a4e67374b74515361537149696f365854516d517a672b2f656e694c383634456b6b6d446d36696f5a6448537a4d37444f57304f554f642b59383241546f686a754b4d3836664b2f4a355979464749447162447057647139476b67357763766667546779524c59786b624d61556543636c7033703938594f772f79583158363435396f4842726d6c62334e7233524839776d34556974615a6a4d6456687a4f4c6c694f5761414f75582f39464443356c42476f6b6d3736464c5a6f3539796877336e676d3670694e4449664475334f2b685565717839503844346534433435534a646434646673395139316b6852356a742b36586f46503352504a2b37716f6b456d306b67517379673756596f76496c534d64744e78707762577254764359786d6a33584842427a2f513465425872746177777338616a56457436496e6745324e4a4c6b4133735750596d4862396a6f555143344d2b752b78544f5a5136676b77656b73457050504c666d756858356f6e2b34713053496c7a554557497631524c5764614d5944394b483778706d646873776e73673677537968385a7145596f503342636256476154614a3546666262667a534e7955333545586371666578416a476b3077635268685337314939477250516b455a7763753030745469523661426e62746e5132316771526a367461574d6c725a68527332473937763351496c4a31794b7337556c69494758614b76784e6d3872477670775068574d4a36416d586b316769726b686b6443493074454c76763962736965747639737a5558363330494e625a7a77476b6d554a707a6239396c743459786d39774337682b4d4968364e5761322b306836463750382f634332356d5a787943304941414141415355564f524b35435949493d);
INSERT INTO `etapa_opcion` (`id`, `etapa_id`, `meta_key`, `meta_value`, `imagen`) VALUES
(331, 77, 'nombre', 'Residencial Simple', NULL),
(332, 77, 'valor', '1', NULL),
(333, 77, 'imagen', 'imagen', 0x646174613a696d6167653b6261736536342c6956424f5277304b47676f414141414e5355684555674141414f45414141446843414d414141414a62534a49414141417746424d5645554150652f2f2f2f2f2f676741414f2b38414c6534414d7534414b2b34414f652f2f6841434a6e7662332b762b3177506d78762f6b414d4f34414b6534414e752b516f7659414e2f6b414a75377566686552583534414f6659415075612b792f717275766c6354386177616e506d375033793976374530507666352f33613476796472766741512f4136595046366b66577a61323969667652415a664a4961664c4e312f735a5366436d747669446d665a786966524f62764a5964764f56715064475373334c63306c6a5572666665536c7a574b6954595a456b524e67765750472b626d436e5a34445a647a6a53322f786f672f516c55764735782f706465764e6367524c71414141464d556c45515652346e4f3362613365694f41414759476849554e75456c713631753268424f3172767a737a756a727462572f2f2f76316f55496546614f61664763633737664a687a43686d613177527977526f47414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141464c416a354e7a314f4a6e2b373547767a726c7263694a3333786f48332b317a312b553037753676496f336666744647524d4c4c6834535844776b7648784a6550695338664a65616b4278386645704a32445a4965446235702b7279446d63523770786e315555504b5779614f30566f6c444573732f395a53576738704a57734e59676a7944446f2b563758383376426c6f677a684b54503573456d312f4f34667a6a56342f7566372f363869694e6d2f5655596b5970687a315431686b4a372f3761753439392b6257564f45534f7057625371762f743256614c78705a322f744330326e706e6c4459586d5a70514a62386f5474714b45376238625a516e2f794364306a463475333734646964356d724a4f512f4b69526b4136366851464e7337764f332f496e5643656830663553456a47666b4c3655354e735a365978594b794635754438796f624f754347696162786f37617132456876336a7672415673776d4a6b332f4771447971373346544c364668502f7a544b4d6959665a614b6d315365362b5a7a382b5a4a5066516f744b5462715a6e51494864662f2f32766b526b51723637533436476a336f542b516a424b7165574f314766725346732f725a7377504e78757435323074703065384e32786a424b3438547a47647566793846686249395a502b44463770415a552f6976624b6f326f61314f3533724f55573375384f7244314b4a764b545255567a65544d4e66765548425731715450695436615065394e4a355772436b6d50394f74315368486d5a613535656e595379374a5258584e49654b4532594f53636e2b755a5730374f6d546b4c57695138385a7375713643784a4d586435686d30656459315064494b4538704a6d634a765654487177722b6c70656f4b4554426b724b75693645552b515546545032424a766573614c55795173577a5a6c4c5055386173365938466e504775707a456c49337775736b6e46315151747038697178326c54373250707a72547669656e55625a6b794d544569757064543873794636544831664e636e4e4e4f3476574e4b354e6272597635795a646d6b6d596e6c526d4569726a34554c515572713254766b71726f3258546568736b6c4e5249466e3158717173737532342b7969554f6331743165784f453257694f4d6d4d5479785a496879616c77644a354e523830316b6b6a6231626453694c4a7a38374c77304c363937325671624a742b6e484236484a4d7a47496d6b4c354e464b6a746577482f7136786964564b796732795978356644726d6c39667447536f35756571584f354672754d446262636e4d695547354549682b653066334a354933346d6c3466476a7a732b64337051476a636956496548325a48725136586a64733664437a694a4966552f55416d3737746f454a65394e6e796170694c47462f5762665831627073355356716644443674335972734c326457534e787043376956352f62696f55433577364c79754c77384653587352783156324d596261747149495537623575724d2b4534774a612f517544357144755064535a53757075324573584f384a5a7957507851746552306c696568744c374661476a4c326f6d323256692b6a505254656d36716e332f6a354f7a62733679644367334c533771742f634e6c65646c6e496b6152655265696e5437595872784e563761717254366d753845385548367a6c6c464f477a716f4a795457763357315546513175647279342b714d3563365536452b52556c422f4b6a6f49754b63714756766a33766658577133684d4671627259622b556c5a2b70346173334c4334627a3276784d344c52342b53652b7974536c7648474364456b324c4138346454585061384a3672352b4b36374c4a3953622b5574796e6237504e7767646c7136686e33532b3664327872565643567a7154676b55373742572b767657562b43397568516235674f4b53386e5763365471782b6b50374d5739634455546942744d58794e56337062704d576a642b37613262582b2b4e4638555631494a7939724870502b7a376f6a594f747a55717234726a7231546a757250376a73765246686d3378375452352f48716432635139363765706942314f5050617658706a343441744d4e68664d5749394767346b6c724b7169784c4545362b394c6868656e50384e664d5a523941367967344c462f50334e3853514141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414167462f552f33726c586e434439316f664141414141456c46546b5375516d4343),
(334, 77, 'nombre', 'Residencial doble horario', NULL),
(335, 77, 'valor', '2', NULL),
(336, 77, 'imagen', 'imagen', 0x646174613a696d6167653b6261736536342c6956424f5277304b47676f414141414e5355684555674141414f45414141446843414d414141414a62534a49414141417746424d5645554150652f2f2f2f2f2f676741414f2b38414c6534414d7534414b2b34414f652f2f6841434a6e7662332b762b3177506d78762f6b414d4f34414b6534414e752b516f7659414e2f6b414a75377566686552583534414f6659415075612b792f717275766c6354386177616e506d375033793976374530507666352f33613476796472766741512f4136595046366b66577a61323969667652415a664a4961664c4e312f735a5366436d747669446d665a786966524f62764a5964764f56715064475373334c63306c6a5572666665536c7a574b6954595a456b524e67765750472b626d436e5a34445a647a6a53322f786f672f516c55764735782f706465764e6367524c71414141464d556c45515652346e4f3362613365694f41414759476849554e75456c713631753268424f3172767a737a756a727462572f2f2f76316f55496546614f61664763633737664a687a43686d613177527977526f47414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141464c416a354e7a314f4a6e2b373547767a726c7263694a3333786f48332b317a312b553037753676496f336666744647524d4c4c6834535844776b7648784a6550695338664a65616b4278386645704a32445a4965446235702b7279446d63523770786e315555504b5779614f30566f6c444573732f395a53576738704a57734e59676a7944446f2b563758383376426c6f677a684b54503573456d312f4f34667a6a56342f7566372f363869694e6d2f5655596b5970687a315431686b4a372f3761753439392b6257564f45534f7057625371762f743256614c78705a322f744330326e706e6c4459586d5a70514a62386f5474714b45376238625a516e2f794364306a463475333734646964356d724a4f512f4b69526b4136366851464e7337764f332f496e5643656830663553456a47666b4c3655354e735a365978594b794635754438796f624f754347696162786f37617132456876336a7672415673776d4a6b332f4771447971373346544c364668502f7a544b4d6959665a614b6d315365362b5a7a382b5a4a5066516f744b5462715a6e51494864662f2f32766b526b51723637533436476a336f542b516a424b7165574f314766725346732f725a7377504e78757435323074703065384e32786a424b3438547a47647566793846686249395a502b44463770415a552f6976624b6f326f61314f3533724f55573375384f7244314b4a764b545255567a65544d4e66765548425731715450695436615065394e4a355772436b6d50394f74315368486d5a613535656e595379374a5258584e49654b4532594f53636e2b755a5730374f6d546b4c57695138385a7375713643784a4d586435686d30656459315064494b4538704a6d634a765654487177722b6c70656f4b4554426b724b75693645552b515546545032424a766573614c55795173577a5a6c4c5055386173365938466e504775707a456c49337775736b6e46315151747038697178326c54373250707a72547669656e55625a6b794d544569757064543873794636544831664e636e4e4e4f3476574e4b354e6272597635795a646d6b6d596e6c526d4569726a34554c515572713254766b71726f3258546568736b6c4e5249466e3158717173737532342b7969554f6331743165784f453257694f4d6d4d5479785a496879616c77644a354e523830316b6b6a6231626453694c4a7a38374c77304c363937325671624a742b6e484236484a4d7a47496d6b4c354e464b6a746577482f7136786964564b796732795978356644726d6c39667447536f35756571584f354672754d446262636e4d695547354549682b653066334a354933346d6c3466476a7a732b64337051476a636956496548325a48725136586a64733664437a694a4966552f55416d3737746f454a65394e6e796170694c47462f5762665831627073355356716644443674335972734c326457534e787043376956352f62696f55433577364c79754c77384653587352783156324d596261747149495537623575724d2b4534774a612f517544357144755064535a53757075324573584f384a5a7957507851746552306c696568744c374661476a4c326f6d323256692b6a505254656d36716e332f6a354f7a62733679644367334c533771742f634e6c65646c6e496b6152655265696e5437595872784e563761717254366d753845385548367a6c6c464f477a716f4a795457763357315546513175647279342b714d3563365536452b52556c422f4b6a6f49754b63714756766a33766658577133684d4671627259622b556c5a2b70346173334c4334627a3276784d344c52342b53652b7974536c7648474364456b324c4138346454585061384a3672352b4b36374c4a3953622b5574796e6237504e7767646c7136686e33532b3664327872565643567a7154676b55373742572b767657562b43397568516235674f4b53386e5763365471782b6b50374d5739634455546942744d58794e56337062704d576a642b37613262582b2b4e4638555631494a7939724870502b7a376f6a594f747a55717234726a7231546a757250376a73765246686d3378375452352f48716432635139363765706942314f5050617658706a343441744d4e68664d5749394767346b6c724b7169784c4545362b394c6868656e50384e664d5a523941367967344c462f50334e3853514141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414167462f552f33726c586e434439316f664141414141456c46546b5375516d4343);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `logs`
--

CREATE TABLE `logs` (
  `date` varchar(20) NOT NULL,
  `time` varchar(8) NOT NULL,
  `procedure` varchar(255) NOT NULL,
  `in` varchar(10000) NOT NULL,
  `out` varchar(10000) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Volcado de datos para la tabla `logs`
--

INSERT INTO `logs` (`date`, `time`, `procedure`, `in`, `out`) VALUES
('2023-11-15', '23:22:28', 'https:!!minervatech.uy!simulador2!', 'area', '1326'),
('2023-11-15', '23:22:28', 'https:!!minervatech.uy!simulador2!', 'latitud', '-34.9465946'),
('2023-11-15', '23:22:28', 'https:!!minervatech.uy!simulador2!', 'longitud', '-54.93192149999999'),
('2023-11-15', '23:22:28', 'https:!!minervatech.uy!simulador2!', 'direccion', 'Cordón, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-15', '23:29:21', 'https:!!minervatech.uy!simulador2!', 'area', '4622'),
('2023-11-15', '23:29:21', 'https:!!minervatech.uy!simulador2!', 'latitud', '-34.9041401'),
('2023-11-15', '23:29:21', 'https:!!minervatech.uy!simulador2!', 'longitud', '-56.1784106'),
('2023-11-15', '23:29:21', 'https:!!minervatech.uy!simulador2!', 'direccion', 'Cordón, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-15', '23:30:00', 'https:!!minervatech.uy!simulador2!', 'area', '4515'),
('2023-11-15', '23:30:00', 'https:!!minervatech.uy!simulador2!', 'latitud', '-34.9465946'),
('2023-11-15', '23:30:00', 'https:!!minervatech.uy!simulador2!', 'longitud', '-54.93192149999999'),
('2023-11-15', '23:30:00', 'https:!!minervatech.uy!simulador2!', 'direccion', 'Patagonia, Punta del Este Maldonado Department, Uruguay'),
('2023-11-15', '23:36:56', 'https:!!minervatech.uy!simulador2!', 'latitud', '-34.9041401'),
('2023-11-15', '23:36:56', 'https:!!minervatech.uy!simulador2!', 'area', '5646'),
('2023-11-15', '23:36:57', 'https:!!minervatech.uy!simulador2!', 'longitud', '-56.1784106'),
('2023-11-15', '23:36:57', 'https:!!minervatech.uy!simulador2!', 'direccion', 'Cordón, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-15', '23:39:22', 'https:!!minervatech.uy!simulador2!', 'area', '14336'),
('2023-11-15', '23:39:22', 'https:!!minervatech.uy!simulador2!', 'latitud', '-34.9041401'),
('2023-11-15', '23:39:22', 'https:!!minervatech.uy!simulador2!', 'longitud', '-56.1784106'),
('2023-11-15', '23:39:22', 'https:!!minervatech.uy!simulador2!', 'direccion', 'Cordón, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-16', '22:37:33', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-16', '22:37:33', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '4165'),
('2023-11-16', '22:37:33', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-16', '22:37:33', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-16', '22:46:44', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '3924'),
('2023-11-16', '22:46:44', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-16', '22:46:44', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-16', '22:46:44', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-16', '22:48:51', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '3924'),
('2023-11-16', '22:48:51', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-16', '22:48:51', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-16', '22:48:51', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-16', '22:56:54', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-16', '22:56:54', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1085'),
('2023-11-16', '22:56:55', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-16', '22:56:55', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-16', '22:58:25', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1224'),
('2023-11-16', '22:58:25', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-16', '22:58:25', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-16', '22:58:25', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-16', '22:58:33', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-16', '22:58:33', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-16', '22:58:33', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-16', '22:58:33', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1224'),
('2023-11-16', '22:58:58', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-16', '22:58:58', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-16', '22:58:58', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-16', '22:58:58', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1224'),
('2023-11-16', '23:00:27', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1377'),
('2023-11-16', '23:00:27', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-16', '23:00:27', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-16', '23:00:27', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-16', '23:00:30', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1377'),
('2023-11-16', '23:00:30', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-16', '23:00:30', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-16', '23:00:30', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-16', '23:00:32', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-16', '23:00:32', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-16', '23:00:32', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1377'),
('2023-11-16', '23:00:32', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-16', '23:02:53', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-16', '23:02:53', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1499'),
('2023-11-16', '23:02:53', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-16', '23:02:53', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-16', '23:02:55', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-16', '23:02:55', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1499'),
('2023-11-16', '23:02:55', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-16', '23:02:55', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-16', '23:02:57', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-16', '23:02:57', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-16', '23:02:57', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1499'),
('2023-11-16', '23:02:57', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-16', '23:26:56', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1157'),
('2023-11-16', '23:26:56', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-16', '23:26:56', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-16', '23:26:56', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-16', '23:27:00', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-16', '23:27:00', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-16', '23:27:00', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1157'),
('2023-11-16', '23:27:01', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-16', '23:27:04', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-16', '23:27:04', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-16', '23:27:05', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-16', '23:27:05', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1157'),
('2023-11-17', '04:45:05', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1312'),
('2023-11-17', '04:45:05', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '04:45:05', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '04:45:05', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '04:45:08', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1312'),
('2023-11-17', '04:45:08', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '04:45:08', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '04:45:08', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '04:45:10', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '04:45:10', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1312'),
('2023-11-17', '04:45:10', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '04:45:10', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '04:45:19', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1312'),
('2023-11-17', '04:45:19', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '04:45:19', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '04:45:19', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '04:58:33', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1182'),
('2023-11-17', '04:58:33', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '04:58:34', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '04:58:34', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '04:58:37', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1182'),
('2023-11-17', '04:58:37', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '04:58:37', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '04:58:37', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '04:58:40', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '04:58:40', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '04:58:40', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '04:58:40', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1182'),
('2023-11-17', '04:58:46', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1182'),
('2023-11-17', '04:58:46', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '04:58:46', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '04:58:46', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '11:21:27', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '11:21:27', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '921'),
('2023-11-17', '11:21:27', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '11:21:27', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '11:21:31', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '921'),
('2023-11-17', '11:21:31', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '11:21:31', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '11:21:31', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '11:21:35', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '11:21:35', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '921'),
('2023-11-17', '11:21:35', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '11:21:35', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '11:21:55', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '11:21:55', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '11:21:55', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '921'),
('2023-11-17', '11:21:55', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '11:23:09', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '11:23:09', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '436'),
('2023-11-17', '11:23:09', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '11:23:09', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '11:23:17', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '11:23:17', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '436'),
('2023-11-17', '11:23:17', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '11:23:17', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '11:23:22', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '436'),
('2023-11-17', '11:23:22', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '11:23:22', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '11:23:22', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '11:23:30', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '11:23:30', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '11:23:30', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '436'),
('2023-11-17', '11:23:30', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '15:20:49', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '15:20:49', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '405'),
('2023-11-17', '15:20:49', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '15:20:49', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '15:20:51', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '405'),
('2023-11-17', '15:20:51', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '15:20:51', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '15:20:51', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '15:20:53', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '405'),
('2023-11-17', '15:20:53', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '15:20:53', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '15:20:53', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '15:23:03', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1148'),
('2023-11-17', '15:23:03', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '15:23:03', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '15:23:03', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '15:23:05', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1148'),
('2023-11-17', '15:23:05', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '15:23:05', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '15:23:05', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '15:23:07', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1148'),
('2023-11-17', '15:23:07', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '15:23:07', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '15:23:07', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '15:47:09', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1153'),
('2023-11-17', '15:47:09', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '15:47:09', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '15:47:09', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '15:47:10', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '15:47:10', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1153'),
('2023-11-17', '15:47:10', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '15:47:10', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '15:47:12', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1153'),
('2023-11-17', '15:47:12', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '15:47:12', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '15:47:12', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '15:49:01', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '15:49:01', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1863'),
('2023-11-17', '15:49:01', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '15:49:01', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '15:49:03', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1863'),
('2023-11-17', '15:49:03', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '15:49:03', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '15:49:03', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '15:49:05', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1863'),
('2023-11-17', '15:49:05', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '15:49:05', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '15:49:05', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '15:52:48', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '15:52:48', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1385'),
('2023-11-17', '15:52:48', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '15:52:48', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '15:52:49', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '15:52:49', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '15:52:49', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1385'),
('2023-11-17', '15:52:49', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '15:52:51', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1385'),
('2023-11-17', '15:52:51', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '15:52:51', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '15:52:51', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '15:53:35', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1446'),
('2023-11-17', '15:53:35', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '15:53:35', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '15:53:35', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '15:53:37', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1446'),
('2023-11-17', '15:53:37', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '15:53:37', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '15:53:37', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '15:53:39', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1446'),
('2023-11-17', '15:53:39', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '15:53:39', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '15:53:39', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '15:55:19', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1163'),
('2023-11-17', '15:55:19', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '15:55:20', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '15:55:20', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '15:55:21', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '15:55:21', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '15:55:21', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '15:55:21', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1163'),
('2023-11-17', '15:55:24', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '15:55:24', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '15:55:24', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1163'),
('2023-11-17', '15:55:24', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '15:58:41', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '15:58:41', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '231'),
('2023-11-17', '15:58:42', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '15:58:42', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '16:13:21', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '280'),
('2023-11-17', '16:13:21', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '16:13:21', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '16:13:21', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '16:13:32', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '280'),
('2023-11-17', '16:13:32', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '16:13:32', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '16:13:32', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '16:13:36', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '280'),
('2023-11-17', '16:13:36', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '16:13:36', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '16:13:36', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '16:17:07', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '16:17:07', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '26'),
('2023-11-17', '16:17:07', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '16:17:07', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '16:17:09', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '26'),
('2023-11-17', '16:17:09', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '16:17:09', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '16:17:09', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '16:17:12', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '26'),
('2023-11-17', '16:17:12', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '16:17:12', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '16:17:12', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '16:45:12', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '112'),
('2023-11-17', '16:45:12', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '16:45:12', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '16:45:12', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '16:45:16', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '112'),
('2023-11-17', '16:45:16', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '16:45:16', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '16:45:16', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '16:45:19', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '112'),
('2023-11-17', '16:45:19', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '16:45:19', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '16:45:19', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '16:45:24', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '112'),
('2023-11-17', '16:45:24', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '16:45:24', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '16:45:24', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '16:45:48', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '112'),
('2023-11-17', '16:45:48', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '16:45:48', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '16:45:48', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '16:45:59', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '16:45:59', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '112'),
('2023-11-17', '16:45:59', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '16:45:59', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '16:46:09', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '112'),
('2023-11-17', '16:46:09', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '16:46:09', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '16:46:09', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '19:48:52', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '963'),
('2023-11-17', '19:48:52', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '19:48:52', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '19:48:52', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '19:48:54', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '19:48:54', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '963'),
('2023-11-17', '19:48:54', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '19:48:54', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '19:48:56', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '19:48:56', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '963'),
('2023-11-17', '19:48:56', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '19:48:56', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '19:49:08', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '19:49:08', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '963'),
('2023-11-17', '19:49:08', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '19:49:08', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '19:49:22', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '19:49:22', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '963'),
('2023-11-17', '19:49:22', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '19:49:22', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '19:49:30', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '963'),
('2023-11-17', '19:49:30', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '19:49:30', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '19:49:30', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '19:49:42', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '19:49:42', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '963'),
('2023-11-17', '19:49:42', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '19:49:42', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '19:58:32', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '19:58:32', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', ''),
('2023-11-17', '19:58:33', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '19:58:33', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '20:00:36', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '547'),
('2023-11-17', '20:00:36', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '20:00:36', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '20:00:36', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '20:00:44', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '547'),
('2023-11-17', '20:00:44', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '20:00:44', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '20:00:44', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '20:00:50', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '547'),
('2023-11-17', '20:00:50', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '20:00:50', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '20:00:50', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '20:00:55', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '20:00:55', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '20:00:55', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '547'),
('2023-11-17', '20:00:55', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '20:03:01', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', ''),
('2023-11-17', '20:03:01', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '20:03:01', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '20:03:01', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '20:04:36', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '190'),
('2023-11-17', '20:04:37', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.170782'),
('2023-11-17', '20:04:37', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9002144'),
('2023-11-17', '20:04:37', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Doctor Martín C. Martínez 1573, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '20:06:54', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Doctor Martín C. Martínez 1573, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '20:06:54', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9002144'),
('2023-11-17', '20:06:55', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '190'),
('2023-11-17', '20:06:55', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.170782'),
('2023-11-17', '20:06:59', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1420'),
('2023-11-17', '20:06:59', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '20:06:59', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '20:06:59', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '20:08:21', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '190'),
('2023-11-17', '20:08:21', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.170782'),
('2023-11-17', '20:08:22', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Doctor Martín C. Martínez 1573, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '20:08:22', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9002144'),
('2023-11-17', '20:10:45', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '190'),
('2023-11-17', '20:11:09', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '20:11:09', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1791'),
('2023-11-17', '20:11:09', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '20:11:09', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '20:11:15', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '20:11:15', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '20:11:15', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '20:11:15', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1791'),
('2023-11-17', '20:11:34', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1791'),
('2023-11-17', '20:11:34', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '20:11:34', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '20:11:34', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '20:11:40', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1791'),
('2023-11-17', '20:11:40', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '20:11:40', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '20:11:40', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '20:12:25', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '190'),
('2023-11-17', '20:12:25', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Doctor Martín C. Martínez 1573, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '20:12:26', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.170782'),
('2023-11-17', '20:12:26', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9002144'),
('2023-11-17', '20:13:18', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9002144'),
('2023-11-17', '20:13:18', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Doctor Martín C. Martínez 1573, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '20:13:19', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '190'),
('2023-11-17', '20:13:19', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.170782'),
('2023-11-17', '20:16:46', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.170782'),
('2023-11-17', '20:16:47', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9002144'),
('2023-11-17', '20:16:47', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '190'),
('2023-11-17', '20:16:47', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Doctor Martín C. Martínez 1573, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '20:18:53', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '20:18:53', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '992'),
('2023-11-17', '20:18:53', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '20:18:53', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '20:27:13', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '706'),
('2023-11-17', '20:27:13', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '20:27:13', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '20:27:13', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '20:27:18', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '706'),
('2023-11-17', '20:27:18', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '20:27:18', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '20:27:18', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '21:02:29', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '588'),
('2023-11-17', '21:02:29', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '21:02:29', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '21:02:29', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '21:04:21', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1322'),
('2023-11-17', '21:04:21', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '21:04:21', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '21:04:21', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '21:09:05', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', ''),
('2023-11-17', '21:09:05', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '21:09:05', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '21:09:05', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '21:10:50', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '21:10:50', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', ''),
('2023-11-17', '21:10:50', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '21:10:50', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '21:17:10', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', ''),
('2023-11-17', '21:17:10', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '21:17:10', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '21:17:10', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '22:27:16', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', ''),
('2023-11-17', '22:27:16', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '22:27:16', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '22:27:16', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '22:49:01', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1191'),
('2023-11-17', '22:49:01', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '22:49:01', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '22:49:01', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '22:49:06', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '22:49:06', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '22:49:06', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1191'),
('2023-11-17', '22:49:06', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay');
INSERT INTO `logs` (`date`, `time`, `procedure`, `in`, `out`) VALUES
('2023-11-17', '22:51:36', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '2600'),
('2023-11-17', '22:51:36', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '22:51:36', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '22:51:36', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-17', '23:46:40', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '2789'),
('2023-11-17', '23:46:40', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-17', '23:46:41', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-17', '23:46:41', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-18', '00:14:41', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1368'),
('2023-11-18', '00:14:41', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-18', '00:14:41', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-18', '00:14:41', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-18', '00:16:32', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-18', '00:16:32', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '2261'),
('2023-11-18', '00:16:32', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-18', '00:16:32', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-18', '00:18:38', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1424'),
('2023-11-18', '00:18:38', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-18', '00:18:38', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-18', '00:18:38', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-18', '00:23:59', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1775'),
('2023-11-18', '00:23:59', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-18', '00:23:59', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-18', '00:23:59', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-18', '00:26:23', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '2367'),
('2023-11-18', '00:26:23', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-18', '00:26:24', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-18', '00:26:24', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-18', '00:28:52', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-18', '00:28:52', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '5209'),
('2023-11-18', '00:28:52', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-18', '00:28:52', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-18', '00:32:33', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-18', '00:32:33', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1673'),
('2023-11-18', '00:32:33', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-18', '00:32:33', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-18', '00:35:18', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '982'),
('2023-11-18', '00:35:18', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-18', '00:35:18', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-18', '00:35:18', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-18', '00:38:20', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '993'),
('2023-11-18', '00:38:20', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-18', '00:38:20', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-18', '00:38:20', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-18', '00:43:13', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-18', '00:43:13', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1459'),
('2023-11-18', '00:43:13', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-18', '00:43:13', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-18', '00:53:08', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '980'),
('2023-11-18', '00:53:08', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-18', '00:53:08', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-18', '00:53:08', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-18', '00:54:27', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-18', '00:54:27', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1466'),
('2023-11-18', '00:54:27', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-18', '00:54:27', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-18', '00:56:13', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '1974'),
('2023-11-18', '00:56:13', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-18', '00:56:13', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619'),
('2023-11-18', '00:56:13', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-18', '00:57:11', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'area', '3471'),
('2023-11-18', '00:57:11', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'direccion', 'Centro, Montevideo Departamento de Montevideo, Uruguay'),
('2023-11-18', '00:57:11', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'latitud', '-34.9045171'),
('2023-11-18', '00:57:11', 'https:!!barreirosoluciones.minervatech.uy!simulador!', 'longitud', '-56.1951619');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `presupuestos`
--

CREATE TABLE `presupuestos` (
  `id` int(11) NOT NULL,
  `resultado` int(11) DEFAULT NULL,
  `formula` varchar(2550) DEFAULT NULL,
  `finalizado` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `presupuestos`
--

INSERT INTO `presupuestos` (`id`, `resultado`, `formula`, `finalizado`) VALUES
(1, NULL, '[11]*5+[12]+1+[13]', 0),
(2, NULL, '[11]*5+[12]+1+[13]', 0),
(3, NULL, '[11]*5+[12]+1+[13]', 0),
(4, NULL, '[11]*5+[12]+1+[13]', 0),
(5, NULL, '[11]*5+[12]+1+[13]', 0),
(6, NULL, '[11]*5+[12]+1+[13]', 0),
(7, NULL, '[11]*5+[12]+1+[13]', 0),
(8, NULL, '[11]*5+[12]+1+[13]', 0),
(9, NULL, '[11]*5+[12]+1+[13]', 0),
(10, NULL, '[11]*5+[12]+1+[13]', 0),
(11, NULL, '[11]*5+[12]+1+[13]', 0),
(12, NULL, '[11]*5+[12]+1+[13]', 0),
(13, NULL, '[11]*5+[12]+1+[13]', 0),
(14, NULL, '[11]*5+[12]+1+[13]', 0),
(15, NULL, '[11]*5+[12]+1+[13]', 0),
(16, 125, '[11]*5+[12]+1+[13]', 0),
(17, NULL, '[11]*5+[12]+1+[13]', 0),
(18, 125, '[11]*5+[12]+1+[13]', 0),
(19, 125, '5+[12]+1+[13]', 0),
(20, 129, '5+[12]+1+[13]', 0),
(21, 108, '5+[12]+1+[13]', 0),
(22, 93, '5+[12]+1+[13]', 0),
(23, NULL, '[44]+5', 0),
(24, NULL, '[44]+5', 0),
(25, NULL, '[44]+5', 0),
(26, NULL, '[44]+5', 0),
(27, NULL, '[44]+5', 0),
(28, NULL, '[44]+5', 0),
(29, NULL, '[44]+5', 0),
(30, NULL, '[44]+5', 0),
(31, NULL, '[44]+5', 0),
(32, NULL, '[44]+5', 0),
(33, NULL, '[44]+5', 0),
(34, 2005, '[44]+5', 0),
(35, 3005, '[44]+5', 0),
(36, NULL, '[44]+5', 0),
(37, 3005, '[44]+5', 0),
(38, NULL, '[44]+5', 0),
(39, NULL, '[44]+5', 0),
(40, 1005, '[44]+5', 0),
(41, NULL, '[44]+5', 0),
(42, 1005, '[44]+5', 0),
(43, 1005, '[44]+5', 0),
(44, 1005, '[44]+5', 0),
(45, NULL, '[44]+5', 0),
(46, NULL, '[44]+5', 0),
(47, NULL, '[44]+5', 0),
(48, NULL, '[44]+5', 0),
(49, NULL, '[44]+5', 0),
(50, NULL, '[44]+5', 0),
(51, NULL, '[44]+5', 0),
(52, NULL, '[44]+5', 0),
(53, NULL, '[44]+5', 0),
(54, NULL, '[44]+5', 0),
(55, NULL, '[44]+5', 0),
(56, NULL, '[44]+5', 0),
(57, NULL, '[44]+5', 0),
(58, NULL, '[44]+5', 0),
(59, NULL, '[44]+5', 0),
(60, NULL, '[44]+5', 0),
(61, NULL, '[44]+5', 0),
(62, NULL, '[44]+5', 0),
(63, NULL, '[44]+5', 0),
(64, 1005, '[44]+5', 0),
(65, NULL, '[44]+5', 0),
(66, NULL, '[44]+5', 0),
(67, NULL, '[44]+5', 0),
(68, NULL, '[44]+5', 0),
(69, NULL, '[44]+5', 0),
(70, NULL, '[44]+5', 0),
(71, NULL, '[44]+5', 0),
(72, NULL, '[44]+5', 0),
(73, NULL, '[44]+5', 0),
(74, NULL, '[44]+5', 0),
(75, NULL, '[44]+5', 0),
(76, NULL, '[44]+5', 0),
(77, NULL, '[44]+5', 0),
(78, NULL, '[44]+5', 0),
(79, NULL, '[44]+5', 0),
(80, NULL, '[44]+5', 0),
(81, NULL, '[44]+5', 0),
(82, NULL, '[44]+5', 0),
(83, NULL, '[44]+5', 0),
(84, NULL, '[44]+5', 0),
(85, NULL, '[44]+5', 0),
(86, NULL, '[44]+5', 0),
(87, NULL, '[44]+5', 0),
(88, NULL, '[44]+5', 0),
(89, NULL, '[44]+5', 0),
(90, NULL, '[44]+5', 0),
(91, NULL, '[44]+5', 0),
(92, NULL, '[44]+5', 0),
(93, NULL, '[44]+5', 0),
(94, NULL, '[44]+5', 0),
(95, NULL, '[44]+5', 0),
(96, NULL, '[44]+5', 0),
(97, NULL, '[44]+5', 0),
(98, NULL, '[44]+5', 0),
(99, NULL, '[44]+5', 0),
(100, NULL, '[44]+5', 0),
(101, NULL, '[44]+5', 0),
(102, NULL, '[44]+5', 0),
(103, NULL, '[44]+5', 0),
(104, NULL, '[44]+5', 0),
(105, NULL, '[44]+5', 0),
(106, NULL, '[44]+5', 0),
(107, NULL, '[44]+5', 0),
(108, NULL, '[44]+5', 0),
(109, NULL, '[44]+5', 0),
(110, NULL, '[44]+5', 0),
(111, NULL, '[44]+5', 0),
(112, NULL, '[44]+5', 0),
(113, NULL, '[44]+5', 0),
(114, NULL, '[44]+5', 0),
(115, NULL, '[44]+5', 0),
(116, NULL, '[44]+5', 0),
(117, NULL, '[44]+5', 0),
(118, NULL, '[44]+5', 0),
(119, NULL, '[44]+5', 0),
(120, NULL, '[44]+5', 0),
(121, NULL, '[44]+5', 0),
(122, NULL, '[44]+5', 0),
(123, NULL, '[44]+5', 0),
(124, NULL, '[44]+5', 0),
(125, NULL, '[44]+5', 0),
(126, NULL, '[44]+5', 0),
(127, NULL, '[44]+5', 0),
(128, NULL, '[44]+5', 0),
(129, NULL, '[44]+5', 0),
(130, NULL, '[44]+5', 0),
(131, NULL, '[44]+5', 0),
(132, NULL, '[44]+5', 0),
(133, NULL, '[44]+5', 0),
(134, NULL, '[44]+5', 0),
(135, NULL, '[44]+5', 0),
(136, NULL, '[44]+5', 0),
(137, NULL, '[44]+5', 0),
(138, NULL, '[44]+5', 0),
(139, NULL, '[44]+5', 0),
(140, NULL, '[44]+5', 0),
(141, NULL, '[44]+5', 0),
(142, NULL, '[44]+5', 0),
(143, NULL, '[44]+5', 0),
(144, NULL, '[44]+5', 0),
(145, NULL, '[44]+5', 0),
(146, NULL, '[44]+5', 0),
(147, NULL, '[44]+5', 0),
(148, NULL, '[44]+5', 0),
(149, NULL, '[44]+5', 0),
(150, NULL, '[44]+5', 0),
(151, NULL, '[44]+5', 0),
(152, NULL, '[44]+5', 0),
(153, NULL, '[44]+5', 0),
(154, NULL, '[44]+5', 0),
(155, NULL, '[44]+5', 0),
(156, NULL, '[44]+5', 0),
(157, NULL, '[44]+5', 0),
(158, NULL, '[44]+5', 0),
(159, NULL, '[44]+5', 0),
(160, NULL, '[44]+5', 0),
(161, NULL, '[44]+5', 0),
(162, NULL, '[44]+5', 0),
(163, 1005, '[44]+5', 0),
(164, NULL, '[44]+5', 0),
(165, NULL, '[44]+5', 0),
(166, NULL, '[44]+5', 0),
(167, NULL, '[44]+5', 0),
(168, NULL, '[44]+5', 0),
(169, 1005, '[44]+5', 0),
(170, NULL, '[44]+5', 0),
(171, NULL, '[44]+5', 0),
(172, NULL, '[44]+5', 0),
(173, NULL, '[44]+5', 0),
(174, NULL, '[44]+5', 0),
(175, NULL, '[44]+5', 0),
(176, NULL, '[44]+5', 0),
(177, NULL, '[44]+5', 0),
(178, NULL, '[44]+5', 0),
(179, NULL, '[44]+5', 0),
(180, NULL, '[44]+5', 0),
(181, NULL, '[44]+5', 0),
(182, NULL, '[44]+5', 0),
(183, NULL, '[44]+5', 0),
(184, NULL, '[44]+5', 0),
(185, NULL, '[44]+5', 0),
(186, NULL, '[44]+5', 0),
(187, NULL, '[44]+5', 0),
(188, NULL, '[44]+5', 0),
(189, NULL, '[44]+5', 0),
(190, NULL, '[44]+5', 0),
(191, NULL, '[44]+5', 0),
(192, NULL, '[44]+5', 0),
(193, NULL, '[44]+5', 0),
(194, NULL, '[44]+5', 0),
(195, NULL, '[44]+5', 0),
(196, 1005, '[44]+5', 0),
(197, NULL, '[44]+5', 0),
(198, NULL, '[44]+5', 0),
(199, NULL, '[44]+5', 0),
(200, NULL, '[44]+5', 0),
(201, NULL, '[44]+5', 0),
(202, NULL, '[44]+5', 0),
(203, NULL, '[44]+5', 0),
(204, NULL, '[44]+5', 0),
(205, NULL, '[44]+5', 0),
(206, NULL, '[44]+5', 0),
(207, NULL, '[44]+5', 0),
(208, NULL, '[44]+5', 0),
(209, NULL, '[44]+5', 0),
(210, NULL, '[44]+5', 0),
(211, NULL, '[44]+5', 0),
(212, NULL, '[44]+5', 0),
(213, NULL, '[44]+5', 0),
(214, NULL, '[44]+5', 0),
(215, NULL, '[44]+5', 0),
(216, NULL, '[44]+5', 0),
(217, NULL, '[44]+5', 0),
(218, NULL, '[44]+5', 0),
(219, NULL, '[44]+5', 0),
(220, NULL, '[44]+5', 0),
(221, NULL, '[44]+5', 0),
(222, NULL, '[44]+5', 0),
(223, NULL, '[44]+5', 0),
(224, NULL, '[44]+5', 0),
(225, NULL, '[44]+5', 0),
(226, NULL, '[44]+5', 0),
(227, NULL, '[44]+5', 0),
(228, NULL, '[44]+5', 0),
(229, NULL, '[44]+5', 0),
(230, NULL, '[44]+5', 0),
(231, NULL, '[44]+5', 0),
(232, NULL, '[44]+5', 0),
(233, NULL, '[44]+5', 0),
(234, NULL, '[44]+5', 0),
(235, NULL, '[44]+5', 0),
(236, NULL, '[44]+5', 0),
(237, NULL, '[44]+5', 0),
(238, NULL, '[44]+5', 0),
(239, NULL, '[44]+5', 0),
(240, NULL, '[44]+5', 0),
(241, NULL, '[44]+5', 0),
(242, NULL, '[44]+5', 0),
(243, NULL, '[44]+5', 0),
(244, NULL, '[44]+5', 0),
(245, NULL, '[44]+5', 0),
(246, NULL, '[44]+5', 0),
(247, NULL, '[44]+5', 0),
(248, NULL, '[44]+5', 0),
(249, NULL, '[44]+5', 0),
(250, NULL, '[44]+5', 0),
(251, NULL, '[44]+5', 0),
(252, NULL, '[44]+5', 0),
(253, NULL, '[44]+5', 0),
(254, NULL, '[44]+5', 0),
(255, NULL, '[44]+5', 0),
(256, NULL, '[44]+5', 0),
(257, NULL, '[44]+5', 0),
(258, NULL, '[44]+5', 0),
(259, NULL, '[44]+5', 0),
(260, NULL, '[44]+5', 0),
(261, NULL, '[44]+5', 0),
(262, NULL, '[44]+5', 0),
(263, NULL, '[44]+5', 0),
(264, NULL, '[44]+5', 0),
(265, NULL, '[44]+5', 0),
(266, NULL, '[44]+5', 0),
(267, NULL, '[44]+5', 0),
(268, NULL, '[44]+5', 0),
(269, NULL, '[44]+5', 0),
(270, NULL, '[44]+5', 0),
(271, NULL, '[44]+5', 0),
(272, NULL, '[44]+5', 0),
(273, NULL, '[44]+5', 0),
(274, NULL, '[44]+5', 0),
(275, NULL, '[44]+5', 0),
(276, NULL, '[44]+5', 0),
(277, NULL, '[44]+5', 0),
(278, NULL, '[44]+5', 0),
(279, NULL, '[44]+5', 0),
(280, NULL, '[44]+5', 0),
(281, NULL, '[44]+5', 0),
(282, NULL, '[44]+5', 0),
(283, NULL, '[44]+5', 0),
(284, 1005, '[44]+5', 0),
(285, NULL, '[44]+[45]+[49]', 0),
(286, NULL, '[44]+[45]+[49]', 0),
(287, 1200, '[44]+[45]+[49]', 0),
(288, NULL, '[44]+[45]+[49]', 0),
(289, NULL, '[44]+[45]+[49]', 0),
(290, NULL, '[44]+[45]+[49]', 0),
(291, NULL, '[44]+[45]+[49]', 0),
(292, NULL, '[44]+[45]+[49]', 0),
(293, NULL, '[44]+[45]+[49]', 0),
(294, NULL, '[44]+[45]+[49]', 0),
(295, NULL, '[44]+[45]+[49]', 0),
(296, NULL, '[44]+[45]+[49]', 0),
(297, NULL, '[44]+[45]+[49]', 0),
(298, NULL, '[44]+[45]+[49]', 0),
(299, NULL, '[44]+[45]+[49]', 0),
(300, 1506, '[44]+[45]+[49]', 0),
(301, 3751, '[44]+[45]+[49]', 0),
(302, 1573, '[44]+[45]+[49]', 0),
(303, 2168, '[44]+[45]+[49]', 0),
(304, 1953, '[44]+[45]+[49]', 0),
(305, NULL, '[52]+[54]', 0),
(306, NULL, '[52]+[54]', 0),
(307, NULL, '[52]+[54]', 0),
(308, NULL, '[52]+[54]', 0),
(309, NULL, '[52]+[54]', 0),
(310, NULL, '[52]+[54]', 0),
(311, NULL, '[52]+[54]', 0),
(312, NULL, '[52]+[54]', 0),
(313, NULL, '[52]+[54]', 0),
(314, NULL, '[52]+[54]', 0),
(315, NULL, '[52]+[54]', 0),
(316, NULL, '[52]+[54]', 0),
(317, NULL, '[52]+[54]', 0),
(318, NULL, '[52]+[54]', 0),
(319, NULL, '[52]+[54]', 0),
(320, NULL, '[52]+[54]', 0),
(321, NULL, '[52]+[54]', 0),
(322, NULL, '[52]+[54]', 0),
(323, NULL, '[52]+[54]', 0),
(324, NULL, '[52]+[54]', 0),
(325, NULL, '[52]+[54]', 0),
(326, NULL, '[52]+[54]', 0),
(327, NULL, '[52]+[54]', 0),
(328, NULL, '[52]+[54]', 0),
(329, NULL, '[52]+[54]', 0),
(330, NULL, '[52]+[54]', 0),
(331, NULL, '[52]+[54]', 0),
(332, NULL, '[52]+[54]', 0),
(333, NULL, '[52]+[54]', 0),
(334, NULL, '[52]+[54]', 0),
(335, NULL, '[52]+[54]', 0),
(336, NULL, '[52]+[54]', 0),
(337, NULL, '[52]+[54]', 0),
(338, NULL, '[52]+[54]', 0),
(339, NULL, '[52]+[54]', 0),
(340, NULL, '[52]+[54]', 0),
(341, NULL, '[52]+[54]', 0),
(342, NULL, '[52]+[54]', 0),
(343, NULL, '[52]+[54]', 0),
(344, NULL, '[52]+[54]', 0),
(345, NULL, '[52]+[54]', 0),
(346, NULL, '[52]+[54]', 0),
(347, NULL, '[52]+[54]', 0),
(348, NULL, '[52]+[54]', 0),
(349, NULL, '[52]+[54]', 0),
(350, NULL, '[52]+[54]', 0),
(351, NULL, '[52]+[54]', 0),
(352, 110, '[54]+[55]', 0),
(353, NULL, '[54]+[55]', 0),
(354, 141, '[54]+[55]', 0),
(355, NULL, '[54]+[55]', 0),
(356, 4, '[54]+[55]', 0),
(357, NULL, '[54]+[55]', 0),
(358, NULL, '[54]+[55]', 0),
(359, NULL, '[54]+[55]', 0),
(360, 333, '[54]+[55]', 0),
(361, NULL, '[54]+[55]', 0),
(362, NULL, '[54]+[55]', 0),
(363, NULL, '[54]+[55]', 0),
(364, NULL, '[54]+[55]', 0),
(365, NULL, '[54]+[55]', 0),
(366, NULL, '[54]+[55]', 0),
(367, NULL, '[54]+[55]', 0),
(368, NULL, '[54]+[55]', 0),
(369, NULL, '[54]+[55]', 0),
(370, NULL, '[54]+[55]', 0),
(371, NULL, '[54]+[55]', 0),
(372, NULL, '[54]+[55]', 0),
(373, NULL, '[54]+[55]', 0),
(374, NULL, '[54]+[55]', 0),
(375, NULL, '[54]+[55]', 0),
(376, NULL, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(377, NULL, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(378, NULL, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(379, NULL, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(380, NULL, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(381, NULL, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(382, NULL, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(383, NULL, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(384, NULL, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(385, NULL, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(386, NULL, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(387, NULL, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(388, NULL, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(389, NULL, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(390, NULL, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(391, NULL, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(392, NULL, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(393, NULL, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(394, NULL, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(395, NULL, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(396, 4098688, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(397, 3385248, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(398, 2156982, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(399, 598192, '([61]*500)+([61]*[62])+([61]*[63])', 0),
(400, NULL, NULL, 0),
(401, 3444, '[66]+[67]+[68]', 0),
(402, 3459, '[66]+[67]+[68]', 0),
(403, 5589, '[66]+[67]+[68]', 0),
(404, 4155, '[66]+[67]+[68]', 0),
(405, 4338, '[66]+[67]+[68]', 0),
(406, 3489, '[66]+[67]+[68]', 0),
(407, NULL, '[66]+[67]+[68]', 0),
(408, 840, '[66]+[67]+[68]', 0),
(409, 78, '[66]+[67]+[68]', 0),
(410, NULL, '[44]+[45]-[49]+[56]', 0),
(411, NULL, '[44]+[45]-[49]+[56]', 0),
(412, NULL, '[44]+[45]-[49]+[56]', 0),
(413, NULL, '[44]+[45]-[49]+[56]', 0),
(414, NULL, '[44]+[45]-[49]+[56]', 0),
(415, NULL, '[44]+[45]-[49]+[56]', 0),
(416, NULL, '[44]+[45]-[49]+[56]', 0),
(417, NULL, '[44]+[45]-[49]+[56]', 0),
(418, NULL, '[44]+[45]-[49]+[56]', 0),
(419, NULL, '[44]+[45]-[49]+[56]', 0),
(420, NULL, '[44]+[45]-[49]+[56]', 0),
(421, NULL, '[44]+[45]-[49]+[56]', 0),
(422, NULL, '[44]+[45]-[49]+[56]', 0),
(423, NULL, '[44]+[45]-[49]+[56]', 0),
(424, NULL, '[44]+[45]-[49]+[56]', 0),
(425, 336, '[66]+[67]+[68]', 0),
(426, 2889, '[66]+[67]+[68]', 0),
(427, NULL, '[66]+[67]+[68]', 0),
(428, NULL, '[66]+[67]+[68]', 0),
(429, 570, '[66]+[67]+[68]', 0),
(430, NULL, '[66]+[67]+[68]', 0),
(431, NULL, '[66]+[67]+[68]', 0),
(432, NULL, '[66]+[67]+[68]', 0),
(433, NULL, '[66]+[67]+[68]', 0),
(434, NULL, '[66]+[67]+[68]', 0),
(435, NULL, '[66]+[67]+[68]', 0),
(436, NULL, '[66]+[67]+[68]', 0),
(437, NULL, '[66]+[67]+[68]', 0),
(438, NULL, '[66]+[67]+[68]', 0),
(439, NULL, '[66]+[67]+[68]', 0),
(440, NULL, '[66]+[67]+[68]', 0),
(441, NULL, '[66]+[67]+[68]', 0),
(442, NULL, '[66]+[67]+[68]', 0),
(443, NULL, '[66]+[67]+[68]', 0),
(444, NULL, '[66]+[67]+[68]', 0),
(445, NULL, '[66]+[67]+[68]', 0),
(446, NULL, '[66]+[67]+[68]', 0),
(447, NULL, '[66]+[67]+[68]', 0),
(448, NULL, '[66]+[67]+[68]', 0),
(449, NULL, '[66]+[67]+[68]', 0),
(450, NULL, '[66]+[67]+[68]', 0),
(451, NULL, '[66]+[67]+[68]', 0),
(452, NULL, '[66]+[67]+[68]', 0),
(453, 2603, '[66]+[67]+[68]', 0),
(454, 2792, '[66]+[67]+[68]', 0),
(455, 1371, '[66]+[67]+[68]', 0),
(456, 2264, '[66]+[67]+[68]', 0),
(457, 1427, '[66]+[67]+[68]', 0),
(458, 1778, '[66]+[67]+[68]', 0),
(459, 2370, '[66]+[67]+[68]', 0),
(460, 5212, '[66]+[67]+[68]', 0),
(461, 1676, '[66]+[67]+[68]', 0),
(462, 985, '[66]+[67]+[68]', 0),
(463, 996, '[66]+[67]+[68]', 0),
(464, 20084, '[66]+[81]+[68]', 0),
(465, 15087, '[66]+[81]+[68]', 0),
(466, 20587, '[66]+[81]+[68]', 0),
(467, 8546, '[66]+[81]+[68]', 0),
(468, 53084, '[66]+[81]+[68]', 0),
(469, 49421, '[66]+[79]++[80]+[81]+[68]', 0),
(470, 23398, '[66]+[79]++[80]+[81]+[68]', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `presupuestos_data`
--

CREATE TABLE `presupuestos_data` (
  `id` int(11) NOT NULL,
  `presupuesto_id` int(11) NOT NULL,
  `meta_key` varchar(2550) NOT NULL,
  `meta_value` varchar(2550) NOT NULL,
  `etapa_id` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Volcado de datos para la tabla `presupuestos_data`
--

INSERT INTO `presupuestos_data` (`id`, `presupuesto_id`, `meta_key`, `meta_value`, `etapa_id`) VALUES
(1, 1, 'valor-intervalos', '64', 13),
(2, 1, 'valor-opciones', '23', 12),
(3, 1, 'valor-opciones', '23', 12),
(4, 1, 'valor-opciones', '23', 12),
(5, 1, 'valor-opciones', '23', 12),
(6, 1, 'valor-opciones', '23', 12),
(7, 1, 'valor-opciones', '23', 12),
(8, 1, 'valor-opciones', '23', 12),
(9, 2, 'valor-intervalos', '100', 13),
(10, 2, 'valor-opciones', '23', 12),
(11, 2, 'valor-opciones', '23', 12),
(12, 2, 'valor-opciones', '23', 12),
(13, 2, 'valor-opciones', '23', 12),
(14, 2, 'valor-opciones', '23', 12),
(15, 3, 'valor-intervalos', '100', 13),
(16, 3, 'valor-opciones', '23', 12),
(17, 3, 'valor-opciones', '23', 12),
(18, 3, 'valor-opciones', '23', 12),
(19, 3, 'valor-opciones', '23', 12),
(20, 3, 'valor-opciones', '23', 12),
(21, 3, 'valor-opciones', '23', 12),
(22, 3, 'valor-opciones', '23', 12),
(23, 4, 'valor-intervalos', '100', 13),
(24, 4, 'valor-opciones', '23', 12),
(25, 4, 'valor-opciones', '23', 12),
(26, 4, 'valor-opciones', '23', 12),
(27, 4, 'valor-opciones', '23', 12),
(28, 4, 'valor-opciones', '23', 12),
(29, 4, 'valor-opciones', '23', 12),
(30, 8, 'valor-intervalos', '60', 13),
(31, 8, 'valor-opciones', '23', 12),
(32, 8, 'valor-opciones', '23', 12),
(33, 8, 'valor-opciones', '23', 12),
(34, 9, 'valor-intervalos', '100', 13),
(35, 9, 'valor-opciones', '23', 12),
(36, 9, 'valor-opciones', '23', 12),
(37, 10, 'valor-intervalos', '100', 13),
(38, 10, 'valor-opciones', '23', 12),
(39, 11, 'valor-intervalos', '100', 13),
(40, 11, 'valor-intervalos', '100', 13),
(41, 11, 'valor-intervalos', '100', 13),
(42, 11, 'valor-intervalos', '100', 13),
(43, 11, 'valor-intervalos', '100', 13),
(44, 11, 'valor-intervalos', '100', 13),
(45, 11, 'valor-intervalos', '100', 13),
(46, 11, 'valor-opciones', '23', 12),
(47, 11, 'valor-opciones', '23', 12),
(48, 11, 'valor-opciones', '23', 12),
(49, 11, 'valor-opciones', '23', 12),
(50, 12, 'valor-intervalos', '100', 13),
(51, 12, 'valor-opciones', '23', 12),
(52, 12, 'valor-opciones', '23', 12),
(53, 12, 'valor-opciones', '23', 12),
(54, 13, 'valor-intervalos', '100', 13),
(55, 13, 'valor-opciones', '23', 12),
(56, 15, 'valor-intervalos', '100', 13),
(57, 15, 'valor-opciones', '23', 12),
(58, 15, 'valor-opciones', '23', 12),
(59, 15, 'valor-opciones', '23', 12),
(60, 16, 'valor-intervalos', '100', 13),
(61, 16, 'valor-opciones', '23', 12),
(62, 18, 'valor-intervalos', '100', 13),
(63, 18, 'valor-opciones', '23', 12),
(64, 19, 'valor-intervalos', '100', 13),
(65, 19, 'valor-opciones', '23', 12),
(66, 20, 'valor-intervalos', '100', 13),
(67, 20, 'valor-intervalos', '100', 13),
(68, 20, 'valor-opciones', '23', 12),
(69, 21, 'valor-intervalos', '79', 13),
(70, 21, 'valor-opciones', '23', 12),
(71, 22, 'valor-intervalos', '64', 13),
(72, 22, 'valor-opciones', '23', 12),
(73, 22, 'valor-opciones', '23', 12),
(74, 22, 'valor-opciones', '23', 12),
(75, 34, 'valor-opciones', '2000', 44),
(76, 34, 'valor-intervalos', '117', 45),
(77, 35, 'valor-opciones', '3000', 44),
(78, 35, 'valor-intervalos', '135', 45),
(79, 37, 'valor-opciones', '3000', 44),
(80, 37, 'valor-intervalos', '137', 45),
(81, 40, 'valor-opciones', '1000', 44),
(82, 40, 'valor-intervalos', '110', 45),
(83, 42, 'valor-opciones', '1000', 44),
(84, 42, 'valor-intervalos', '108', 45),
(85, 43, 'valor-opciones', '1000', 44),
(86, 43, 'valor-intervalos', '55', 45),
(87, 44, 'valor-opciones', '1000', 44),
(88, 44, 'valor-intervalos', '131', 45),
(89, 55, 'valor-opciones', '1000', 44),
(90, 55, 'valor-intervalos', '119', 45),
(91, 56, 'valor-opciones', '1000', 44),
(92, 56, 'valor-intervalos', '118', 45),
(93, 57, 'valor-opciones', '1000', 44),
(94, 57, 'valor-intervalos', '98', 45),
(95, 58, 'valor-opciones', '2000', 44),
(96, 58, 'valor-intervalos', '124', 45),
(97, 60, 'valor-opciones', '1000', 44),
(98, 60, 'valor-intervalos', '15', 45),
(99, 62, 'valor-opciones', '1000', 44),
(100, 62, 'valor-intervalos', '109', 45),
(101, 63, 'valor-opciones', '1000', 44),
(102, 63, 'valor-intervalos', '129', 45),
(103, 64, 'valor-opciones', '1000', 44),
(104, 64, 'valor-intervalos', '146', 45),
(105, 65, 'valor-opciones', '1000', 44),
(106, 65, 'valor-intervalos', '100', 45),
(107, 65, 'valor-intervalos', '1', 47),
(108, 66, 'valor-opciones', '1000', 44),
(109, 66, 'valor-intervalos', '146', 45),
(110, 66, 'valor-intervalos', '1', 47),
(111, 67, 'valor-opciones', '1000', 44),
(112, 67, 'valor-intervalos', '109', 45),
(113, 68, 'valor-opciones', '1000', 44),
(114, 68, 'valor-intervalos', '119', 45),
(115, 69, 'valor-opciones', '1000', 44),
(116, 69, 'valor-intervalos', '120', 45),
(117, 70, 'valor-opciones', '1000', 44),
(118, 70, 'valor-intervalos', '118', 45),
(119, 71, 'valor-opciones', '1000', 44),
(120, 71, 'valor-intervalos', '131', 45),
(121, 72, 'valor-opciones', '1000', 44),
(122, 72, 'valor-intervalos', '109', 45),
(123, 72, 'valor-intervalos', '109', 45),
(124, 72, 'valor-intervalos', '109', 45),
(125, 72, 'valor-intervalos', '109', 45),
(126, 72, 'valor-intervalos', '109', 45),
(127, 72, 'valor-intervalos', '109', 45),
(128, 72, 'valor-intervalos', '109', 45),
(129, 72, 'valor-intervalos', '109', 45),
(130, 72, 'valor-intervalos', '109', 45),
(131, 72, 'valor-intervalos', '109', 45),
(132, 72, 'valor-intervalos', '109', 45),
(133, 72, 'valor-intervalos', '109', 45),
(134, 72, 'valor-intervalos', '109', 45),
(135, 72, 'valor-intervalos', '109', 45),
(136, 72, 'valor-intervalos', '109', 45),
(137, 72, 'valor-intervalos', '109', 45),
(138, 72, 'valor-intervalos', '109', 45),
(139, 72, 'valor-intervalos', '109', 45),
(140, 73, 'valor-opciones', '1000', 44),
(141, 73, 'valor-intervalos', '122', 45),
(142, 74, 'valor-opciones', '1000', 44),
(143, 74, 'valor-intervalos', '124', 45),
(144, 75, 'valor-opciones', '1000', 44),
(145, 75, 'valor-intervalos', '120', 45),
(146, 76, 'valor-opciones', '1000', 44),
(147, 76, 'valor-intervalos', '111', 45),
(148, 77, 'valor-opciones', '1000', 44),
(149, 77, 'valor-intervalos', '115', 45),
(150, 78, 'valor-opciones', '1000', 44),
(151, 78, 'valor-intervalos', '15', 45),
(152, 79, 'valor-opciones', '1000', 44),
(153, 79, 'valor-intervalos', '126', 45),
(154, 80, 'valor-opciones', '1000', 44),
(155, 80, 'valor-intervalos', '156', 45),
(156, 81, 'valor-opciones', '1000', 44),
(157, 81, 'valor-intervalos', '114', 45),
(158, 82, 'valor-opciones', '1000', 44),
(159, 82, 'valor-intervalos', '97', 45),
(160, 83, 'valor-opciones', '1000', 44),
(161, 83, 'valor-intervalos', '105', 45),
(162, 84, 'valor-opciones', '1000', 44),
(163, 84, 'valor-intervalos', '126', 45),
(164, 85, 'valor-opciones', '1000', 44),
(165, 85, 'valor-intervalos', '119', 45),
(166, 86, 'valor-opciones', '1000', 44),
(167, 86, 'valor-intervalos', '137', 45),
(168, 87, 'valor-opciones', '1000', 44),
(169, 87, 'valor-intervalos', '116', 45),
(170, 88, 'valor-opciones', '1000', 44),
(171, 88, 'valor-intervalos', '119', 45),
(172, 89, 'valor-opciones', '1000', 44),
(173, 89, 'valor-intervalos', '117', 45),
(174, 90, 'valor-opciones', '1000', 44),
(175, 90, 'valor-intervalos', '129', 45),
(176, 91, 'valor-opciones', '1000', 44),
(177, 91, 'valor-intervalos', '129', 45),
(178, 92, 'valor-opciones', '1000', 44),
(179, 92, 'valor-intervalos', '168', 45),
(180, 93, 'valor-opciones', '1000', 44),
(181, 93, 'valor-intervalos', '131', 45),
(182, 94, 'valor-opciones', '1000', 44),
(183, 94, 'valor-intervalos', '127', 45),
(184, 95, 'valor-opciones', '1000', 44),
(185, 95, 'valor-intervalos', '134', 45),
(186, 96, 'valor-opciones', '1000', 44),
(187, 96, 'valor-intervalos', '139', 45),
(188, 97, 'valor-opciones', '1000', 44),
(189, 97, 'valor-intervalos', '126', 45),
(190, 98, 'valor-opciones', '1000', 44),
(191, 98, 'valor-intervalos', '125', 45),
(192, 99, 'valor-opciones', '1000', 44),
(193, 99, 'valor-intervalos', '129', 45),
(194, 101, 'valor-opciones', '1000', 44),
(195, 101, 'valor-intervalos', '125', 45),
(196, 102, 'valor-opciones', '1000', 44),
(197, 102, 'valor-intervalos', '136', 45),
(198, 103, 'valor-opciones', '1000', 44),
(199, 103, 'valor-intervalos', '129', 45),
(200, 104, 'valor-opciones', '1000', 44),
(201, 104, 'valor-intervalos', '147', 45),
(202, 105, 'valor-opciones', '1000', 44),
(203, 105, 'valor-intervalos', '126', 45),
(204, 106, 'valor-opciones', '1000', 44),
(205, 106, 'valor-intervalos', '15', 45),
(206, 107, 'valor-opciones', '1000', 44),
(207, 107, 'valor-intervalos', '113', 45),
(208, 108, 'valor-opciones', '1000', 44),
(209, 108, 'valor-intervalos', '142', 45),
(210, 109, 'valor-opciones', '1000', 44),
(211, 109, 'valor-intervalos', '109', 45),
(212, 110, 'valor-opciones', '1000', 44),
(213, 110, 'valor-intervalos', '124', 45),
(214, 111, 'valor-opciones', '1000', 44),
(215, 111, 'valor-intervalos', '113', 45),
(216, 112, 'valor-opciones', '1000', 44),
(217, 112, 'valor-intervalos', '119', 45),
(218, 113, 'valor-opciones', '1000', 44),
(219, 113, 'valor-intervalos', '125', 45),
(220, 114, 'valor-opciones', '1000', 44),
(221, 114, 'valor-intervalos', '133', 45),
(222, 115, 'valor-opciones', '1000', 44),
(223, 115, 'valor-intervalos', '117', 45),
(224, 116, 'valor-opciones', '1000', 44),
(225, 116, 'valor-intervalos', '126', 45),
(226, 117, 'valor-opciones', '1000', 44),
(227, 117, 'valor-intervalos', '15', 45),
(228, 118, 'valor-opciones', '1000', 44),
(229, 118, 'valor-intervalos', '126', 45),
(230, 119, 'valor-opciones', '1000', 44),
(231, 119, 'valor-intervalos', '126', 45),
(232, 120, 'valor-opciones', '1000', 44),
(233, 120, 'valor-intervalos', '112', 45),
(234, 121, 'valor-opciones', '1000', 44),
(235, 121, 'valor-intervalos', '123', 45),
(236, 122, 'valor-opciones', '1000', 44),
(237, 122, 'valor-intervalos', '116', 45),
(238, 123, 'valor-opciones', '1000', 44),
(239, 123, 'valor-intervalos', '121', 45),
(240, 124, 'valor-opciones', '1000', 44),
(241, 124, 'valor-intervalos', '110', 45),
(242, 125, 'valor-opciones', '1000', 44),
(243, 125, 'valor-intervalos', '128', 45),
(244, 126, 'valor-opciones', '1000', 44),
(245, 126, 'valor-intervalos', '136', 45),
(246, 127, 'valor-opciones', '1000', 44),
(247, 127, 'valor-intervalos', '123', 45),
(248, 128, 'valor-opciones', '1000', 44),
(249, 128, 'valor-intervalos', '102', 45),
(250, 129, 'valor-opciones', '1000', 44),
(251, 129, 'valor-intervalos', '114', 45),
(252, 130, 'valor-opciones', '1000', 44),
(253, 130, 'valor-intervalos', '104', 45),
(254, 131, 'valor-opciones', '1000', 44),
(255, 133, 'valor-opciones', '1000', 44),
(256, 133, 'valor-intervalos', '118', 45),
(257, 134, 'valor-opciones', '1000', 44),
(258, 134, 'valor-intervalos', '128', 45),
(259, 135, 'valor-opciones', '1000', 44),
(260, 135, 'valor-intervalos', '125', 45),
(261, 136, 'valor-opciones', '1000', 44),
(262, 136, 'valor-intervalos', '139', 45),
(263, 137, 'valor-opciones', '1000', 44),
(264, 137, 'valor-intervalos', '112', 45),
(265, 138, 'valor-opciones', '1000', 44),
(266, 138, 'valor-intervalos', '165', 45),
(267, 139, 'valor-opciones', '1000', 44),
(268, 139, 'valor-intervalos', '131', 45),
(269, 140, 'valor-opciones', '1000', 44),
(270, 140, 'valor-intervalos', '108', 45),
(271, 141, 'valor-opciones', '1000', 44),
(272, 141, 'valor-intervalos', '117', 45),
(273, 142, 'valor-opciones', '1000', 44),
(274, 142, 'valor-intervalos', '114', 45),
(275, 143, 'valor-opciones', '1000', 44),
(276, 143, 'valor-intervalos', '111', 45),
(277, 144, 'valor-opciones', '1000', 44),
(278, 144, 'valor-intervalos', '110', 45),
(279, 145, 'valor-opciones', '1000', 44),
(280, 145, 'valor-intervalos', '100', 45),
(281, 146, 'valor-opciones', '1000', 44),
(282, 146, 'valor-intervalos', '117', 45),
(283, 147, 'valor-opciones', '1000', 44),
(284, 147, 'valor-intervalos', '112', 45),
(285, 148, 'valor-opciones', '1000', 44),
(286, 148, 'valor-intervalos', '104', 45),
(287, 150, 'valor-opciones', '1000', 44),
(288, 150, 'valor-intervalos', '115', 45),
(289, 151, 'valor-opciones', '1000', 44),
(290, 151, 'valor-intervalos', '120', 45),
(291, 152, 'valor-opciones', '1000', 44),
(292, 152, 'valor-intervalos', '109', 45),
(293, 153, 'valor-opciones', '1000', 44),
(294, 153, 'valor-intervalos', '101', 45),
(295, 154, 'valor-opciones', '1000', 44),
(296, 154, 'valor-intervalos', '113', 45),
(297, 155, 'valor-opciones', '1000', 44),
(298, 155, 'valor-intervalos', '112', 45),
(299, 156, 'valor-opciones', '1000', 44),
(300, 156, 'valor-intervalos', '112', 45),
(301, 157, 'valor-opciones', '1000', 44),
(302, 157, 'valor-intervalos', '99', 45),
(303, 158, 'valor-opciones', '1000', 44),
(304, 158, 'valor-intervalos', '122', 45),
(305, 159, 'valor-opciones', '1000', 44),
(306, 159, 'valor-intervalos', '111', 45),
(307, 160, 'valor-opciones', '1000', 44),
(308, 160, 'valor-intervalos', '109', 45),
(309, 161, 'valor-opciones', '1000', 44),
(310, 161, 'valor-intervalos', '114', 45),
(311, 162, 'valor-opciones', '1000', 44),
(312, 162, 'valor-intervalos', '109', 45),
(313, 163, 'valor-opciones', '1000', 44),
(314, 163, 'valor-intervalos', '127', 45),
(315, 163, 'valor-intervalos', '127', 49),
(316, 164, 'valor-opciones', '1000', 44),
(317, 164, 'valor-intervalos', '115', 45),
(318, 165, 'valor-opciones', '1000', 44),
(319, 165, 'valor-intervalos', '113', 45),
(320, 166, 'valor-opciones', '1000', 44),
(321, 166, 'valor-intervalos', '115', 45),
(322, 167, 'valor-opciones', '1000', 44),
(323, 167, 'valor-intervalos', '115', 45),
(324, 168, 'valor-opciones', '1000', 44),
(325, 168, 'valor-intervalos', '108', 45),
(326, 169, 'valor-opciones', '1000', 44),
(327, 169, 'valor-intervalos', '116', 45),
(328, 169, 'valor-intervalos', '116', 49),
(329, 170, 'valor-opciones', '1000', 44),
(330, 170, 'valor-intervalos', '108', 45),
(331, 171, 'valor-opciones', '1000', 44),
(332, 171, 'valor-intervalos', '107', 45),
(333, 172, 'valor-opciones', '1000', 44),
(334, 172, 'valor-intervalos', '111', 45),
(335, 173, 'valor-opciones', '1000', 44),
(336, 173, 'valor-intervalos', '111', 45),
(337, 174, 'valor-opciones', '1000', 44),
(338, 174, 'valor-intervalos', '117', 45),
(339, 175, 'valor-opciones', '1000', 44),
(340, 175, 'valor-intervalos', '108', 45),
(341, 176, 'valor-opciones', '1000', 44),
(342, 176, 'valor-intervalos', '109', 45),
(343, 177, 'valor-opciones', '1000', 44),
(344, 177, 'valor-intervalos', '106', 45),
(345, 178, 'valor-opciones', '1000', 44),
(346, 178, 'valor-intervalos', '104', 45),
(347, 179, 'valor-opciones', '1000', 44),
(348, 179, 'valor-intervalos', '112', 45),
(349, 180, 'valor-opciones', '1000', 44),
(350, 180, 'valor-intervalos', '109', 45),
(351, 181, 'valor-opciones', '1000', 44),
(352, 181, 'valor-intervalos', '108', 45),
(353, 182, 'valor-opciones', '1000', 44),
(354, 182, 'valor-intervalos', '114', 45),
(355, 183, 'valor-opciones', '1000', 44),
(356, 183, 'valor-intervalos', '110', 45),
(357, 184, 'valor-opciones', '1000', 44),
(358, 184, 'valor-intervalos', '102', 45),
(359, 185, 'valor-opciones', '1000', 44),
(360, 185, 'valor-intervalos', '112', 45),
(361, 186, 'valor-opciones', '1000', 44),
(362, 186, 'valor-intervalos', '115', 45),
(363, 188, 'valor-opciones', '1000', 44),
(364, 188, 'valor-intervalos', '108', 45),
(365, 189, 'valor-opciones', '1000', 44),
(366, 189, 'valor-intervalos', '107', 45),
(367, 190, 'valor-opciones', '1000', 44),
(368, 190, 'valor-intervalos', '110', 45),
(369, 191, 'valor-opciones', '1000', 44),
(370, 191, 'valor-intervalos', '111', 45),
(371, 192, 'valor-opciones', '1000', 44),
(372, 192, 'valor-intervalos', '109', 45),
(373, 193, 'valor-opciones', '1000', 44),
(374, 193, 'valor-intervalos', '111', 45),
(375, 194, 'valor-opciones', '1000', 44),
(376, 194, 'valor-intervalos', '104', 45),
(377, 195, 'valor-opciones', '1000', 44),
(378, 195, 'valor-intervalos', '115', 45),
(379, 196, 'valor-opciones', '1000', 44),
(380, 196, 'valor-intervalos', '110', 45),
(381, 196, 'valor-intervalos', '110', 49),
(382, 197, 'valor-opciones', '1000', 44),
(383, 197, 'valor-intervalos', '113', 45),
(384, 198, 'valor-opciones', '1000', 44),
(385, 198, 'valor-intervalos', '106', 45),
(386, 199, 'valor-opciones', '1000', 44),
(387, 199, 'valor-intervalos', '108', 45),
(388, 200, 'valor-opciones', '1000', 44),
(389, 200, 'valor-intervalos', '108', 45),
(390, 201, 'valor-opciones', '1000', 44),
(391, 201, 'valor-intervalos', '104', 45),
(392, 202, 'valor-opciones', '1000', 44),
(393, 202, 'valor-intervalos', '107', 45),
(394, 203, 'valor-opciones', '1000', 44),
(395, 203, 'valor-intervalos', '110', 45),
(396, 204, 'valor-opciones', '1000', 44),
(397, 204, 'valor-intervalos', '109', 45),
(398, 205, 'valor-opciones', '1000', 44),
(399, 205, 'valor-intervalos', '111', 45),
(400, 206, 'valor-opciones', '1000', 44),
(401, 206, 'valor-intervalos', '106', 45),
(402, 207, 'valor-opciones', '1000', 44),
(403, 207, 'valor-intervalos', '112', 45),
(404, 208, 'valor-opciones', '1000', 44),
(405, 208, 'valor-intervalos', '115', 45),
(406, 209, 'valor-opciones', '1000', 44),
(407, 209, 'valor-intervalos', '112', 45),
(408, 210, 'valor-opciones', '1000', 44),
(409, 210, 'valor-intervalos', '113', 45),
(410, 211, 'valor-opciones', '1000', 44),
(411, 211, 'valor-intervalos', '109', 45),
(412, 212, 'valor-opciones', '1000', 44),
(413, 212, 'valor-intervalos', '111', 45),
(414, 213, 'valor-opciones', '1000', 44),
(415, 213, 'valor-intervalos', '109', 45),
(416, 214, 'valor-opciones', '1000', 44),
(417, 214, 'valor-intervalos', '110', 45),
(418, 215, 'valor-opciones', '1000', 44),
(419, 215, 'valor-intervalos', '110', 45),
(420, 216, 'valor-opciones', '1000', 44),
(421, 216, 'valor-intervalos', '110', 45),
(422, 217, 'valor-opciones', '1000', 44),
(423, 217, 'valor-intervalos', '107', 45),
(424, 218, 'valor-opciones', '1000', 44),
(425, 218, 'valor-intervalos', '106', 45),
(426, 219, 'valor-opciones', '1000', 44),
(427, 219, 'valor-intervalos', '102', 45),
(428, 220, 'valor-opciones', '1000', 44),
(429, 220, 'valor-intervalos', '104', 45),
(430, 221, 'valor-opciones', '1000', 44),
(431, 221, 'valor-intervalos', '107', 45),
(432, 222, 'valor-opciones', '1000', 44),
(433, 222, 'valor-intervalos', '107', 45),
(434, 223, 'valor-opciones', '1000', 44),
(435, 223, 'valor-intervalos', '112', 45),
(436, 224, 'valor-opciones', '1000', 44),
(437, 224, 'valor-intervalos', '103', 45),
(438, 225, 'valor-opciones', '1000', 44),
(439, 225, 'valor-intervalos', '108', 45),
(440, 226, 'valor-opciones', '1000', 44),
(441, 226, 'valor-intervalos', '112', 45),
(442, 227, 'valor-opciones', '1000', 44),
(443, 227, 'valor-intervalos', '105', 45),
(444, 228, 'valor-opciones', '1000', 44),
(445, 228, 'valor-intervalos', '112', 45),
(446, 229, 'valor-opciones', '1000', 44),
(447, 229, 'valor-intervalos', '104', 45),
(448, 230, 'valor-opciones', '1000', 44),
(449, 230, 'valor-intervalos', '110', 45),
(450, 231, 'valor-opciones', '1000', 44),
(451, 231, 'valor-intervalos', '101', 45),
(452, 231, 'valor-intervalos', '101', 45),
(453, 231, 'valor-intervalos', '101', 45),
(454, 231, 'valor-intervalos', '101', 45),
(455, 231, 'valor-intervalos', '101', 45),
(456, 231, 'valor-intervalos', '101', 45),
(457, 231, 'valor-intervalos', '101', 45),
(458, 231, 'valor-intervalos', '101', 45),
(459, 231, 'valor-intervalos', '101', 45),
(460, 231, 'valor-intervalos', '101', 45),
(461, 231, 'valor-intervalos', '101', 45),
(462, 231, 'valor-intervalos', '101', 45),
(463, 231, 'valor-intervalos', '101', 45),
(464, 231, 'valor-intervalos', '101', 45),
(465, 231, 'valor-intervalos', '101', 45),
(466, 231, 'valor-intervalos', '101', 45),
(467, 231, 'valor-intervalos', '101', 45),
(468, 231, 'valor-intervalos', '99', 45),
(469, 231, 'valor-intervalos', '99', 45),
(470, 231, 'valor-intervalos', '99', 45),
(471, 231, 'valor-intervalos', '99', 45),
(472, 232, 'valor-opciones', '1000', 44),
(473, 232, 'valor-intervalos', '106', 45),
(474, 232, 'valor-intervalos', '106', 45),
(475, 232, 'valor-intervalos', '106', 45),
(476, 232, 'valor-intervalos', '106', 45),
(477, 233, 'valor-opciones', '1000', 44),
(478, 233, 'valor-intervalos', '109', 45),
(479, 234, 'valor-opciones', '1000', 44),
(480, 234, 'valor-intervalos', '113', 45),
(481, 235, 'valor-opciones', '1000', 44),
(482, 235, 'valor-intervalos', '109', 45),
(483, 236, 'valor-opciones', '1000', 44),
(484, 237, 'valor-opciones', '1000', 44),
(485, 237, 'valor-intervalos', '107', 45),
(486, 238, 'valor-opciones', '1000', 44),
(487, 238, 'valor-intervalos', '106', 45),
(488, 239, 'valor-opciones', '1000', 44),
(489, 239, 'valor-intervalos', '96', 45),
(490, 240, 'valor-opciones', '1000', 44),
(491, 240, 'valor-intervalos', '108', 45),
(492, 241, 'valor-opciones', '1000', 44),
(493, 241, 'valor-intervalos', '109', 45),
(494, 242, 'valor-opciones', '1000', 44),
(495, 242, 'valor-intervalos', '105', 45),
(496, 243, 'valor-opciones', '1000', 44),
(497, 243, 'valor-intervalos', '100', 45),
(498, 244, 'valor-opciones', '1000', 44),
(499, 244, 'valor-intervalos', '104', 45),
(500, 245, 'valor-opciones', '1000', 44),
(501, 245, 'valor-intervalos', '111', 45),
(502, 246, 'valor-opciones', '1000', 44),
(503, 246, 'valor-intervalos', '111', 45),
(504, 248, 'valor-opciones', '1000', 44),
(505, 248, 'valor-intervalos', '106', 45),
(506, 249, 'valor-opciones', '1000', 44),
(507, 249, 'valor-intervalos', '104', 45),
(508, 250, 'valor-opciones', '1000', 44),
(509, 250, 'valor-intervalos', '114', 45),
(510, 251, 'valor-opciones', '1000', 44),
(511, 251, 'valor-intervalos', '108', 45),
(512, 252, 'valor-opciones', '1000', 44),
(513, 252, 'valor-intervalos', '105', 45),
(514, 253, 'valor-opciones', '1000', 44),
(515, 253, 'valor-intervalos', '105', 45),
(516, 254, 'valor-opciones', '1000', 44),
(517, 254, 'valor-intervalos', '97', 45),
(518, 255, 'valor-opciones', '1000', 44),
(519, 255, 'valor-intervalos', '101', 45),
(520, 256, 'valor-opciones', '1000', 44),
(521, 256, 'valor-intervalos', '108', 45),
(522, 257, 'valor-opciones', '1000', 44),
(523, 257, 'valor-intervalos', '118', 45),
(524, 258, 'valor-opciones', '1000', 44),
(525, 258, 'valor-intervalos', '108', 45),
(526, 259, 'valor-opciones', '1000', 44),
(527, 259, 'valor-intervalos', '93', 45),
(528, 260, 'valor-opciones', '1000', 44),
(529, 260, 'valor-intervalos', '103', 45),
(530, 261, 'valor-opciones', '1000', 44),
(531, 261, 'valor-intervalos', '96', 45),
(532, 262, 'valor-opciones', '1000', 44),
(533, 262, 'valor-intervalos', '99', 45),
(534, 263, 'valor-opciones', '1000', 44),
(535, 263, 'valor-intervalos', '105', 45),
(536, 264, 'valor-opciones', '1000', 44),
(537, 264, 'valor-intervalos', '105', 45),
(538, 265, 'valor-opciones', '1000', 44),
(539, 265, 'valor-intervalos', '105', 45),
(540, 266, 'valor-opciones', '1000', 44),
(541, 266, 'valor-intervalos', '114', 45),
(542, 267, 'valor-opciones', '1000', 44),
(543, 267, 'valor-intervalos', '100', 45),
(544, 268, 'valor-opciones', '1000', 44),
(545, 268, 'valor-intervalos', '109', 45),
(546, 269, 'valor-opciones', '1000', 44),
(547, 269, 'valor-intervalos', '101', 45),
(548, 270, 'valor-opciones', '1000', 44),
(549, 270, 'valor-intervalos', '105', 45),
(550, 271, 'valor-opciones', '1000', 44),
(551, 271, 'valor-intervalos', '107', 45),
(552, 271, 'valor-intervalos', '107', 45),
(553, 271, 'valor-intervalos', '107', 45),
(554, 272, 'valor-opciones', '1000', 44),
(555, 272, 'valor-intervalos', '110', 45),
(556, 273, 'valor-opciones', '1000', 44),
(557, 273, 'valor-intervalos', '108', 45),
(558, 274, 'valor-opciones', '1000', 44),
(559, 274, 'valor-intervalos', '111', 45),
(560, 275, 'valor-opciones', '1000', 44),
(561, 275, 'valor-intervalos', '111', 45),
(562, 276, 'valor-opciones', '1000', 44),
(563, 276, 'valor-intervalos', '108', 45),
(564, 277, 'valor-opciones', '1000', 44),
(565, 277, 'valor-intervalos', '110', 45),
(566, 278, 'valor-opciones', 'opciones', 44),
(567, 278, 'valor-intervalos', 'intervalos', 45),
(568, 279, 'valor-opciones', '1000', 44),
(569, 279, 'valor-intervalos', '120', 45),
(570, 280, 'valor-opciones', '1000', 44),
(571, 280, 'valor-intervalos', '107', 45),
(572, 281, 'valor-opciones', '1000', 44),
(573, 281, 'valor-intervalos', '107', 45),
(574, 282, 'valor-opciones', '1000', 44),
(575, 282, 'valor-intervalos', '106', 45),
(576, 283, 'valor-opciones', '1000', 44),
(577, 283, 'valor-intervalos', '109', 45),
(578, 284, 'valor-opciones', '1000', 44),
(579, 284, 'valor-intervalos', '105', 45),
(580, 285, 'valor-opciones', '1000', 44),
(581, 285, 'valor-intervalos', '100', 45),
(582, 286, 'valor-opciones', '1000', 44),
(583, 286, 'valor-intervalos', '106', 45),
(584, 287, 'valor-opciones', '1000', 44),
(585, 287, 'valor-intervalos', '100', 45),
(586, 287, 'valor-geografica', '100', 49),
(587, 288, 'valor-opciones', '1000', 44),
(588, 288, 'valor-intervalos', '122', 45),
(589, 289, 'valor-opciones', '1000', 44),
(590, 289, 'valor-intervalos', '110', 45),
(591, 290, 'valor-opciones', '1000', 44),
(592, 290, 'valor-intervalos', '111', 45),
(593, 291, 'valor-opciones', '1000', 44),
(594, 291, 'valor-intervalos', '100', 45),
(595, 292, 'valor-opciones', '1000', 44),
(596, 292, 'valor-intervalos', '109', 45),
(597, 293, 'valor-opciones', '1000', 44),
(598, 293, 'valor-intervalos', '106', 45),
(599, 294, 'valor-opciones', '1000', 44),
(600, 294, 'valor-intervalos', '111', 45),
(601, 295, 'valor-opciones', '1000', 44),
(602, 295, 'valor-intervalos', '106', 45),
(603, 296, 'valor-opciones', '1000', 44),
(604, 296, 'valor-intervalos', '107', 45),
(605, 297, 'valor-opciones', '1000', 44),
(606, 297, 'valor-intervalos', '105', 45),
(607, 298, 'valor-opciones', '1000', 44),
(608, 298, 'valor-intervalos', '104', 45),
(609, 299, 'valor-opciones', '1000', 44),
(610, 299, 'valor-intervalos', '106', 45),
(611, 300, 'valor-opciones', '1000', 44),
(612, 300, 'valor-intervalos', '153', 45),
(613, 301, 'valor-opciones', '1000', 44),
(614, 301, 'valor-intervalos', '110', 45),
(615, 300, 'valor-geografica', '353', 49),
(616, 301, 'valor-geografica', '2641', 49),
(617, 302, 'valor-opciones', '1000', 44),
(618, 302, 'valor-intervalos', '200', 45),
(619, 302, 'valor-geografica', '373', 49),
(620, 303, 'valor-opciones', '2000', 44),
(621, 303, 'valor-intervalos', '121', 45),
(622, 303, 'valor-geografica', '47', 49),
(623, 304, 'valor-opciones', '1000', 44),
(624, 304, 'valor-intervalos', '105', 45),
(625, 304, 'valor-geografica', '848', 49),
(626, 345, 'valor-opciones', '1', 54),
(627, 345, 'valor-opciones', '1', 54),
(628, 345, 'valor-opciones', '1', 54),
(629, 345, 'valor-opciones', '1', 54),
(630, 346, 'valor-opciones', '2', 54),
(631, 346, 'valor-geografica', '129', 55),
(632, 346, 'valor-geografica', '129', 55),
(633, 346, 'valor-geografica', '129', 55),
(634, 346, 'valor-geografica', '129', 55),
(635, 346, 'valor-geografica', '129', 55),
(636, 346, 'valor-geografica', '129', 55),
(637, 346, 'valor-geografica', '129', 55),
(638, 346, 'valor-geografica', '129', 55),
(639, 346, 'valor-geografica', '129', 55),
(640, 347, 'valor-opciones', '1', 54),
(641, 347, 'valor-geografica', '120', 55),
(642, 347, 'valor-geografica', '120', 55),
(643, 347, 'valor-geografica', '120', 55),
(644, 347, 'valor-geografica', '120', 55),
(645, 347, 'valor-geografica', '120', 55),
(646, 347, 'valor-geografica', '120', 55),
(647, 347, 'valor-geografica', '120', 55),
(648, 347, 'valor-geografica', '120', 55),
(649, 347, 'valor-geografica', '120', 55),
(650, 347, 'valor-geografica', '120', 55),
(651, 347, 'valor-geografica', '120', 55),
(652, 348, 'valor-opciones', '1', 54),
(653, 348, 'valor-geografica', '104', 55),
(654, 349, 'valor-opciones', '1', 54),
(655, 349, 'valor-geografica', '117', 55),
(656, 350, 'valor-opciones', '1', 54),
(657, 350, 'valor-geografica', '140', 55),
(658, 351, 'valor-opciones', '1', 54),
(659, 351, 'valor-geografica', '54', 55),
(660, 352, 'valor-opciones', '1', 54),
(661, 352, 'valor-geografica', '109', 55),
(662, 353, 'valor-opciones', '1', 54),
(663, 354, 'valor-opciones', '2', 54),
(664, 354, 'valor-geografica', '139', 55),
(665, 354, 'valor-geografica', '139', 57),
(666, 355, 'valor-opciones', '1', 54),
(667, 356, 'valor-opciones', '1', 54),
(668, 356, 'valor-geografica', '3', 55),
(669, 356, 'valor-geografica', '3', 57),
(670, 357, 'valor-opciones', '3', 54),
(671, 357, 'valor-geografica', '126', 55),
(672, 358, 'valor-opciones', '3', 54),
(673, 359, 'valor-opciones', '3', 54),
(674, 359, 'valor-geografica', '376', 55),
(675, 359, 'valor-geografica', '376', 55),
(676, 360, 'valor-opciones', '2', 54),
(677, 360, 'valor-geografica', '331', 55),
(678, 360, 'valor-geografica', '331', 57),
(679, 361, 'valor-opciones', '3', 54),
(680, 362, 'valor-opciones', '3', 54),
(681, 363, 'valor-opciones', '3', 54),
(682, 363, 'valor-geografica', '121', 55),
(683, 364, 'valor-opciones', '3', 54),
(684, 364, 'valor-geografica', '121', 55),
(685, 365, 'valor-opciones', '3', 54),
(686, 365, 'valor-geografica', '10075', 55),
(687, 366, 'valor-opciones', '3', 54),
(688, 366, 'valor-geografica', '414', 55),
(689, 367, 'valor-opciones', '3', 54),
(690, 367, 'valor-geografica', '385', 55),
(691, 368, 'valor-opciones', '3', 54),
(692, 368, 'valor-geografica', '1326', 55),
(693, 369, 'valor-opciones', '3', 54),
(694, 369, 'valor-geografica', '4622', 55),
(695, 370, 'valor-opciones', '3', 54),
(696, 370, 'valor-geografica', '4515', 55),
(697, 371, 'valor-opciones', '3', 54),
(698, 372, 'valor-opciones', '3', 54),
(699, 373, 'valor-opciones', '3', 54),
(700, 373, 'valor-geografica', '5646', 55),
(701, 374, 'valor-opciones', '3', 54),
(702, 374, 'valor-geografica', '14336', 55),
(703, 375, 'valor-opciones', '3', 54),
(704, 1234, 'valor-geografica', '4165', 61),
(705, 389, 'valor-geografica', '3924', 61),
(706, 389, 'valor-geografica', '3924', 62),
(707, 390, 'valor-geografica', '1085', 61),
(708, 391, 'valor-geografica', '1224', 61),
(709, 391, 'valor-geografica', '1224', 62),
(710, 391, 'valor-geografica', '1224', 63),
(711, 393, 'valor-geografica', '1377', 61),
(712, 393, 'valor-geografica', '1377', 62),
(713, 393, 'valor-geografica', '1377', 63),
(714, 394, 'valor-geografica', '1499', 61),
(715, 394, 'valor-geografica', '1499', 62),
(716, 394, 'valor-geografica', '1499', 63),
(717, 395, 'valor-geografica', '1157', 61),
(718, 395, 'valor-geografica', '1157', 62),
(719, 395, 'valor-geografica', '1157', 63),
(720, 396, 'valor-geografica', '1312', 61),
(721, 396, 'valor-geografica', '1312', 62),
(722, 396, 'valor-geografica', '1312', 63),
(723, 396, 'valor-geografica', '1312', 65),
(724, 397, 'valor-geografica', '1182', 61),
(725, 397, 'valor-geografica', '1182', 62),
(726, 397, 'valor-geografica', '1182', 63),
(727, 397, 'valor-geografica', '1182', 65),
(728, 398, 'valor-geografica', '921', 61),
(729, 398, 'valor-geografica', '921', 62),
(730, 398, 'valor-geografica', '921', 63),
(731, 398, 'valor-geografica', '921', 65),
(732, 399, 'valor-geografica', '436', 61),
(733, 399, 'valor-geografica', '436', 62),
(734, 399, 'valor-geografica', '436', 63),
(735, 399, 'valor-geografica', '436', 65),
(736, 400, 'valor-geografica', '405', 66),
(737, 400, 'valor-geografica', '405', 67),
(738, 400, 'valor-geografica', '405', 68),
(739, 401, 'valor-geografica', '1148', 66),
(740, 401, 'valor-geografica', '1148', 67),
(741, 401, 'valor-geografica', '1148', 68),
(742, 402, 'valor-geografica', '1153', 66),
(743, 402, 'valor-geografica', '1153', 67),
(744, 402, 'valor-geografica', '1153', 68),
(745, 403, 'valor-geografica', '1863', 66),
(746, 403, 'valor-geografica', '1863', 67),
(747, 403, 'valor-geografica', '1863', 68),
(748, 404, 'valor-geografica', '1385', 66),
(749, 404, 'valor-geografica', '1385', 67),
(750, 404, 'valor-geografica', '1385', 68),
(751, 405, 'valor-geografica', '1446', 66),
(752, 405, 'valor-geografica', '1446', 67),
(753, 405, 'valor-geografica', '1446', 68),
(754, 406, 'valor-geografica', '1163', 66),
(755, 406, 'valor-geografica', '1163', 67),
(756, 406, 'valor-geografica', '1163', 68),
(757, 407, 'valor-geografica', '231', 66),
(758, 408, 'valor-geografica', '280', 66),
(759, 408, 'valor-geografica', '280', 67),
(760, 408, 'valor-geografica', '280', 68),
(761, 409, 'valor-geografica', '26', 66),
(762, 409, 'valor-geografica', '26', 67),
(763, 409, 'valor-geografica', '26', 68),
(764, 425, 'valor-geografica', '112', 66),
(765, 425, 'valor-geografica', '112', 67),
(766, 425, 'valor-geografica', '112', 68),
(767, 425, 'valor-geografica', '112', 77),
(768, 425, 'valor-geografica', '112', 79),
(769, 425, 'valor-geografica', '112', 80),
(770, 425, 'valor-geografica', '112', 81),
(771, 426, 'valor-geografica', '963', 66),
(772, 426, 'valor-geografica', '963', 67),
(773, 426, 'valor-geografica', '963', 68),
(774, 426, 'valor-geografica', '963', 77),
(775, 426, 'valor-geografica', '963', 79),
(776, 426, 'valor-geografica', '963', 80),
(777, 426, 'valor-geografica', '963', 81),
(778, 427, 'valor-geografica', '1452', 66),
(779, 428, 'valor-geografica', '547', 66),
(780, 428, 'valor-geografica', '547', 67),
(781, 428, 'valor-geografica', '547', 68),
(782, 428, 'valor-geografica', '547', 77),
(783, 430, 'valor-geografica', '2700', 66),
(784, 429, 'valor-geografica', '190', 66),
(785, 429, 'valor-geografica', '190', 67),
(786, 431, 'valor-geografica', '1420', 66),
(787, 429, 'valor-geografica', '190', 68),
(788, 429, 'valor-geografica', '190', 77),
(789, 432, 'valor-geografica', '1791', 66),
(790, 432, 'valor-geografica', '1791', 67),
(791, 432, 'valor-geografica', '1791', 68),
(792, 432, 'valor-geografica', '1791', 77),
(793, 429, 'valor-geografica', '190', 79),
(794, 429, 'valor-geografica', '190', 80),
(795, 429, 'valor-geografica', '190', 81),
(796, 433, 'valor-geografica', '992', 66),
(797, 434, 'valor-geografica', '706', 66),
(798, 434, 'valor-geografica', '706', 67),
(799, 446, 'valor-geografica', '588', 66),
(800, 447, 'valor-geografica', '1322', 66),
(801, 448, 'valor-geografica', '898', 66),
(802, 449, 'valor-geografica', '1223', 66),
(803, 450, 'valor-geografica', '1386', 66),
(804, 451, 'valor-geografica', '1199', 66),
(805, 452, 'valor-geografica', '1191', 66),
(806, 452, 'valor-geografica', '1191', 67),
(807, 453, 'valor-opciones', '2', 67),
(808, 453, 'valor-opciones', '1', 68),
(809, 453, 'valor-opciones', '2', 77),
(810, 453, 'valor-intervalos', '5571', 79),
(811, 453, 'valor-intervalos', '6065', 80),
(812, 453, 'valor-intervalos', '59358', 81),
(813, 453, 'valor-geografica', '2600', 66),
(814, 454, 'valor-opciones', '2', 67),
(815, 454, 'valor-opciones', '1', 68),
(816, 454, 'valor-opciones', '2', 77),
(817, 454, 'valor-intervalos', '5096', 79),
(818, 454, 'valor-intervalos', '5235', 80),
(819, 454, 'valor-intervalos', '6090', 81),
(820, 454, 'valor-geografica', '2789', 66),
(821, 455, 'valor-opciones', '2', 67),
(822, 455, 'valor-opciones', '1', 68),
(823, 455, 'valor-opciones', '1', 77),
(824, 455, 'valor-intervalos', '5132', 79),
(825, 455, 'valor-intervalos', '4738', 80),
(826, 455, 'valor-intervalos', '2773', 81),
(827, 455, 'valor-geografica', '1368', 66),
(828, 456, 'valor-opciones', '2', 67),
(829, 456, 'valor-opciones', '1', 68),
(830, 456, 'valor-opciones', '1', 77),
(831, 456, 'valor-intervalos', '5205', 79),
(832, 456, 'valor-intervalos', '4166', 80),
(833, 456, 'valor-intervalos', '3694', 81),
(834, 456, 'valor-geografica', '2261', 66),
(835, 457, 'valor-opciones', '2', 67),
(836, 457, 'valor-opciones', '1', 68),
(837, 457, 'valor-opciones', '1', 77),
(838, 457, 'valor-intervalos', '5205', 79),
(839, 457, 'valor-intervalos', '5254', 80),
(840, 457, 'valor-intervalos', '1667', 81),
(841, 457, 'valor-geografica', '1424', 66),
(842, 458, 'valor-opciones', '2', 67),
(843, 458, 'valor-opciones', '1', 68),
(844, 458, 'valor-opciones', '1', 77),
(845, 458, 'valor-intervalos', '4639', 79),
(846, 458, 'valor-intervalos', '5051', 80),
(847, 458, 'valor-intervalos', '7196', 81),
(848, 458, 'valor-geografica', '1775', 66),
(849, 459, 'valor-opciones', '2', 67),
(850, 459, 'valor-opciones', '1', 68),
(851, 459, 'valor-opciones', '1', 77),
(852, 459, 'valor-intervalos', '4438', 79),
(853, 459, 'valor-intervalos', '4738', 80),
(854, 459, 'valor-intervalos', '2220', 81),
(855, 459, 'valor-geografica', '2367', 66),
(856, 460, 'valor-opciones', '2', 67),
(857, 460, 'valor-opciones', '1', 68),
(858, 460, 'valor-opciones', '2', 77),
(859, 460, 'valor-intervalos', '4511', 79),
(860, 460, 'valor-intervalos', '2249', 80),
(861, 460, 'valor-intervalos', '42032', 81),
(862, 460, 'valor-geografica', '5209', 66),
(863, 461, 'valor-opciones', '2', 67),
(864, 461, 'valor-opciones', '1', 68),
(865, 461, 'valor-opciones', '1', 77),
(866, 461, 'valor-intervalos', '3689', 79),
(867, 461, 'valor-intervalos', '3761', 80),
(868, 461, 'valor-intervalos', '6090', 81),
(869, 461, 'valor-geografica', '1673', 66),
(870, 462, 'valor-opciones', '2', 67),
(871, 462, 'valor-opciones', '1', 68),
(872, 462, 'valor-opciones', '1', 77),
(873, 462, 'valor-intervalos', '1534', 79),
(874, 462, 'valor-intervalos', '2268', 80),
(875, 462, 'valor-intervalos', '4984', 81),
(876, 462, 'valor-geografica', '982', 66),
(877, 463, 'valor-opciones', '2', 67),
(878, 463, 'valor-opciones', '1', 68),
(879, 463, 'valor-opciones', '1', 77),
(880, 463, 'valor-intervalos', '2356', 79),
(881, 463, 'valor-intervalos', '3245', 80),
(882, 463, 'valor-intervalos', '4431', 81),
(883, 463, 'valor-geografica', '993', 66),
(884, 464, 'valor-opciones', '2', 67),
(885, 464, 'valor-opciones', '1', 68),
(886, 464, 'valor-opciones', '1', 77),
(887, 464, 'valor-intervalos', '2557', 79),
(888, 464, 'valor-intervalos', '3835', 80),
(889, 464, 'valor-intervalos', '18624', 81),
(890, 464, 'valor-geografica', '1459', 66),
(891, 465, 'valor-opciones', '2', 67),
(892, 465, 'valor-opciones', '1', 68),
(893, 465, 'valor-opciones', '1', 77),
(894, 465, 'valor-intervalos', '2155', 79),
(895, 465, 'valor-intervalos', '2305', 80),
(896, 465, 'valor-intervalos', '13463', 81),
(897, 465, 'valor-geografica', '1623', 66),
(898, 465, 'valor-geografica', '1623', 66),
(899, 465, 'valor-geografica', '1623', 66),
(900, 465, 'valor-geografica', '1623', 66),
(901, 465, 'valor-geografica', '1623', 66),
(902, 465, 'valor-geografica', '1623', 66),
(903, 465, 'valor-geografica', '1623', 66),
(904, 465, 'valor-geografica', '1623', 66),
(905, 465, 'valor-geografica', '1623', 66),
(906, 465, 'valor-geografica', '1623', 66),
(907, 465, 'valor-geografica', '1623', 66),
(908, 466, 'valor-opciones', '2', 67),
(909, 466, 'valor-opciones', '1', 68),
(910, 466, 'valor-opciones', '1', 77),
(911, 466, 'valor-intervalos', '4584', 79),
(912, 466, 'valor-intervalos', '4240', 80),
(913, 466, 'valor-intervalos', '20098', 81),
(914, 466, 'valor-geografica', '488', 66),
(915, 466, 'valor-geografica', '488', 66),
(916, 466, 'valor-geografica', '488', 66),
(917, 466, 'valor-geografica', '488', 66),
(918, 467, 'valor-opciones', '2', 67),
(919, 467, 'valor-opciones', '1', 68),
(920, 467, 'valor-opciones', '1', 77),
(921, 467, 'valor-intervalos', '2557', 79),
(922, 467, 'valor-intervalos', '1973', 80),
(923, 467, 'valor-intervalos', '7565', 81),
(924, 467, 'valor-geografica', '980', 66),
(925, 468, 'valor-opciones', '2', 67),
(926, 468, 'valor-opciones', '1', 68),
(927, 468, 'valor-opciones', '1', 77),
(928, 468, 'valor-intervalos', '2758', 79),
(929, 468, 'valor-intervalos', '1826', 80),
(930, 468, 'valor-intervalos', '51617', 81),
(931, 468, 'valor-geografica', '1466', 66),
(932, 469, 'valor-opciones', '2', 67),
(933, 469, 'valor-opciones', '1', 68),
(934, 469, 'valor-opciones', '1', 77),
(935, 469, 'valor-intervalos', '4621', 79),
(936, 469, 'valor-intervalos', '4295', 80),
(937, 469, 'valor-intervalos', '38530', 81),
(938, 469, 'valor-geografica', '1974', 66),
(939, 470, 'valor-opciones', '2', 67),
(940, 470, 'valor-opciones', '1', 68),
(941, 470, 'valor-opciones', '1', 77),
(942, 470, 'valor-intervalos', '8858', 79),
(943, 470, 'valor-intervalos', '9770', 80),
(944, 470, 'valor-intervalos', '1298', 81),
(945, 470, 'valor-geografica', '3471', 66);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tokens`
--

CREATE TABLE `tokens` (
  `token` varchar(255) NOT NULL,
  `vendido` tinyint(1) NOT NULL,
  `canjeado` tinyint(1) NOT NULL,
  `fechaFin` date NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Volcado de datos para la tabla `tokens`
--

INSERT INTO `tokens` (`token`, `vendido`, `canjeado`, `fechaFin`) VALUES
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 1, 1, '2024-12-31'),
('gE5aUzg:SV+PvwVmxGz-DtUSBkEUQRFx3ef', 1, 0, '2024-12-31'),
('uMSRExR?s3TMdp8MTDe!_jV4uSUTbrTWufEb', 1, 0, '2024-12-31'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 1, 1, '2024-12-31'),
('PKJvrCCYGH4b7TAA_gbny:FZ7dEvmTauhkjb', 1, 0, '2024-12-31'),
('4Dpd9LJX-K9DA_A5ZRLY_JnTxdVUevXSqZb', 1, 0, '2024-12-31'),
('RtspT8bBRgGRQFCm@7!cUhMVMszRUE*LcpWb', 1, 0, '2024-12-31'),
('ACxK4ZzPy2)ga&=:LxSkyXQ9pVfxbsKTUHWb', 1, 0, '2024-12-31'),
('g27hJz@wHkujfDtkRfE:CJWmmaMEujthLpnb', 1, 0, '2024-12-31'),
('r8bUKmHHVxEKBHUxvG4kQ+PHj?S7QmaWaqhb', 1, 0, '2024-12-31'),
('9rq(HgmFZ#/uZqutFRGYAwxFSH9bkdHQ5VRb', 1, 1, '2024-12-31'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 1, 1, '2024-12-31'),
('zgJ7LgxmDMEbTMsp2qgs@2(_hxnXKU:QtfDb', 1, 0, '2024-12-31'),
('3aUGsnEGqdEEjZdFBb!gbAJH5fHzQDRq?z*b', 0, 0, '2024-12-31'),
('mUJb9bUUYgMYxKmney6AbVxMy:HEG)YgNfxb', 0, 0, '2024-12-31'),
('Tjwsg#VPEATJVZFfJ_F+QksrFHLagMYqt4b', 0, 0, '2024-12-31'),
('DbYckLjmgErLubvzF?#VXZLAC(9nDPwp=SDb', 0, 0, '2024-12-31'),
('GTr/eYxP79dcUZYDSZUZwxQebt)Xt6-2vPbb', 0, 0, '2024-12-31'),
('TDm?mQKJ8VvNxkm3BJj8@WhGhxBL7)MyNtJb', 0, 0, '2024-12-31'),
('YEENhhqqdXCAnpZhQ7p&SbS@Vh2ypL3S)Pkb', 0, 0, '2024-12-31'),
('HAkVLxnTd3Hc78zqMdxX&uZBs-W#Ywex:Wjb', 0, 0, '2024-12-31'),
('B4/#LEcahLmMeeZXYBQwKzDBDb*bqFqqr53b', 0, 0, '2024-12-31'),
('WgAYnbxjb4KzNM9*YSCeLWkwHbt@uUGdHx3b', 0, 0, '2024-12-31'),
('WMqYWPsYG5B:uc4n2XnH?peTqRFWaaJScbsb', 0, 0, '2024-12-31'),
('naqfpWt3q&AKh6_khRRa*RvJCsWz/kjctnHb', 0, 0, '2024-12-31'),
('CFz&YLE?HmLTSpD2f&ENqrN2unkHcYbLtqfb', 0, 0, '2024-12-31'),
('NV6WFasMFf4TGMc7ZVRCBXUcU/RmK#eyuqb', 0, 0, '2024-12-31'),
('rBBjnd@wtWtvGYtaDywQ2G-zTD2GBTVCVHRb', 0, 0, '2024-12-31'),
('HuwNThqN4LctAvmDRCw:CcmV/gu?h9TAuqhb', 0, 0, '2024-12-31'),
(':UqVbcDuav3cS&tD6TxaucwnN4DnkF@GcWXb', 0, 0, '2024-12-31'),
('R=uL4MUrEcVHWsZxBbqWqy6#Rrw5aTdxSYb', 0, 0, '2024-12-31'),
('EK3EUsAjwSVc3p-tsQXt6!Z=rNBnT4mgw(Mb', 0, 0, '2024-12-31'),
('+C5Kf7UGYvekPb79ZEPrg&BLVCLkNXYGBmTb', 0, 0, '2024-12-31'),
('dKYPsqDh@_yt9QNfCqKPWNTBAK5j8am=rrKb', 0, 0, '2024-12-31'),
('zA9NE:tf9vbpU9msezx4vFdxHSuMuNctAmMb', 0, 0, '2024-12-31'),
('aqe7NP)ygCmKPgBkNRE6=ypYtyFVNvud=vkb', 0, 0, '2024-12-31'),
('edV)ufB#wgMU=wc3DgbgnP3:ef6PQTpTHyCb', 0, 0, '2024-12-31'),
('L&VHW52DeVj#yS4NqQDNMkfFSTHmgkE(HF_b', 0, 0, '2024-12-31'),
('HKJNGt/MWNzGSEmT#qNtkBuHDbM9Say5EWb', 0, 0, '2024-12-31'),
('gZXwU4FaK5wRvzd9x@d_LXBRSgwyxbWxkW?b', 0, 0, '2024-12-31'),
('6TwTMgQUrLyktzPge#d93_aHPXZ8LNHzfRb', 0, 0, '2024-12-31'),
('Dfnh3UzJ*!a@C8UVswwnxyhFdWJedDpq8Rb', 0, 0, '2024-12-31'),
('u3Jv&s6raWh8fuJz7fwfVMYFWK+_sawYpsjb', 0, 0, '2024-12-31'),
('TCNW=mPVhBBFvdvfGWJw!g77CxDdUyrxbmtb', 0, 0, '2024-12-31'),
('GfJNL*jHn9AvaSBNA9ATmTBPMmbWN9=Jnsbb', 0, 0, '2024-12-31'),
('JQwVthKhm)JQSAd6Wn?pxabr3rYmEYHxPBHb', 0, 0, '2024-12-31'),
('VEeA8-myAT45nS_xpHjFFgsjBFd=UfbhYGfb', 0, 0, '2024-12-31'),
('VjLb_ZENU6A6szagjgVxQ_zjP:CPJVrz5Hfb', 0, 0, '2024-12-31'),
('cSdF-uZNbAnhSws*fRUPzXeDjtG66GTv)cHb', 0, 0, '2024-12-31'),
('PRD4K*LYqvegLmMS3Jxh(J=nsprCAjg4BZHb', 0, 0, '2024-12-31'),
('cFPFVKBMWy(rW?4(pzN4UxSJLke6QJSGbnb', 0, 0, '2024-12-31'),
('8v?BNEDddKfPd4w!kW*zkyqK@6nWcxtAJMCb', 0, 0, '2024-12-31'),
(')bVXTwuZzx?EyfcbMpDRDyJNCcbJtD!5b7Bb', 0, 0, '2024-12-31'),
('m&cQNAmzAnPVs5R-ns8PH)FLB9XVYZNx*6Tb', 0, 0, '2024-12-31'),
('n7hKf2!c*6gAkLCPc/RFd6TZ-rdnkJgKbpCb', 0, 0, '2024-12-31'),
('jYGxaxs(TX&CZw6eYKf_e/gMxWF9gcc5WVKb', 0, 0, '2024-12-31'),
('qR)ZdPbtaQC:JptK85FL8bGTHM9JvmbLTQGb', 0, 0, '2024-12-31'),
('ahLpRvQTw_xrubVMjGEfY!tG58Duwex+Sxb', 0, 0, '2024-12-31'),
('uZxrrMH:JRYgGaJDtJ)w5FGhrT!QecLXPNCb', 0, 0, '2024-12-31'),
('SPwbQHCU9uNa+xsZK3@FMrDkxaUuxbcPG2Tb', 0, 0, '2024-12-31'),
(':ERn56XuGuG4BfsUwUBp-LHWaM5MdftmmUb', 0, 0, '2024-12-31'),
('gDxaDHrSxSF_qQeh2NFVRc4GMNe6jkD7wCHb', 0, 0, '2024-12-31'),
('y6m8kwQFavKWqdeqVGyeTAyhtcVYhb*KzrCb', 0, 0, '2024-12-31'),
('VteQukgCsm:Ts6AVv4DcWMR2gB@ScqPFy4kb', 0, 0, '2024-12-31'),
('6j_2#nYKAVyGKUva-LtP2Wf@ahe7jZHfShmb', 0, 0, '2024-12-31'),
('FKy#hcsg6pQdTpfpYtSY5AjbnUE9aMkm@k6b', 0, 0, '2024-12-31'),
('Xz5x8cqd!7UWeWN:ZD=NgBeU(wb4aGgNgEgb', 0, 0, '2024-12-31'),
('TNxmFuP_AXFmWz5ar_WpXFDCNtBTST3bbCjb', 0, 0, '2024-12-31'),
('5EujBtwPYYgarj:H/WNNdmxxePbHyFdmNajb', 0, 0, '2024-12-31'),
('g?VR#SBmknArUjYgfrtgqVCCBWnxcBpMk3#b', 0, 0, '2024-12-31'),
('LbKCgFjrb4w&RCZhzbhxDY-j9R(AA5WvBaYb', 0, 0, '2024-12-31'),
('MyL9wBB/jdPXpNZkjWK(QjJkGaXzXezGVrRb', 0, 0, '2024-12-31'),
('MGSyE4UJ?BVd_/qKqjVYrdypemZzbtKgxmcb', 0, 0, '2024-12-31'),
('yPNcMRjsP6erUg*FYH9XGV?vD57=SnMxWgsb', 0, 0, '2024-12-31'),
('yJL6db@hTfjSJ!jhGu2tRMZ@ca)dVewtRKBb', 0, 0, '2024-12-31'),
('ycJKDC:k@PjQM/2sQhmcGs6dAbcHH5qQy9Pb', 0, 0, '2024-12-31'),
('bkQhhY-MTZD3vWEcttvPb&JrUAfa?7suJW7b', 0, 0, '2024-12-31'),
('9mD-ZrnS6WA3+dHwdp*qXbWUeWxgFKtLLJb', 0, 0, '2024-12-31'),
('3MJXxwZ3J2VjGTGx)W/f&XvWaadUqujhKJyb', 0, 0, '2024-12-31'),
('_jdfTPguNp3yw+mz4ChGvvFRArSFZtDsQ?b', 0, 0, '2024-12-31'),
('N7uAuw+DYSDnb-XDGrs8qEb@xFr@XPxW4XWb', 0, 0, '2024-12-31'),
('VNEQ6MyHmRYhqZxUkB9fwyJKcv4avub!n@_b', 0, 0, '2024-12-31'),
('_S!MCXCjnZ6NqHNnQ55)nahGhsSE_LHrRyCb', 0, 0, '2024-12-31'),
('W5HbBXHszagAFkzYz5w+SsBN+RsSC:PD7Lwb', 0, 0, '2024-12-31'),
('LgHbEhBBz)XChk=hbuKBjQdKC5QQYjtkgafb', 0, 0, '2024-12-31'),
('FHt)GyCzQ36jycsJbpzChNa+cFtpNrwchT2b', 0, 0, '2024-12-31'),
('?)Zeh6rvQwYg)c6rDnZQ3EXCmR4kvLCCWFtb', 0, 0, '2024-12-31'),
('RsgducEHBnNvHxK-2avZ6kekgh/Dx49Edbsb', 0, 0, '2024-12-31'),
('4TZPUhXykBzbZ*pvKExMKa+AbMJvkZX=3fdb', 0, 0, '2024-12-31'),
('rHWavjFzWKYKYJsRqxvkRDNwpa+3/AM:YSb', 0, 0, '2024-12-31'),
('ewYpnBaaVpthb3*5V)aBKXZRt&ffHrRt(mUb', 0, 0, '2024-12-31'),
('jEzZudRQqGaQQF-qSKptPQCSkCdaYVwCqV4b', 0, 0, '2024-12-31');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users`
--

CREATE TABLE `users` (
  `email` varchar(255) NOT NULL,
  `pwd` varchar(255) NOT NULL,
  `telephone` varchar(21) DEFAULT NULL,
  `completeName` varchar(510) NOT NULL,
  `lastAccess` date NOT NULL,
  `isActive` tinyint(1) NOT NULL,
  `profilePhoto` longblob DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users_to_calculators`
--

CREATE TABLE `users_to_calculators` (
  `user_email` varchar(255) NOT NULL,
  `calculator_token` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `users_to_calculators`
--

INSERT INTO `users_to_calculators` (`user_email`, `calculator_token`) VALUES
('gabriela.perez@estudiantes.utec.edu.uy', '_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb'),
('gabriela.perezcaviglia@gmail.com', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('usuario@pruebas.com', '9rq(HgmFZ#/uZqutFRGYAwxFSH9bkdHQ5VRb');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users_to_entites`
--

CREATE TABLE `users_to_entites` (
  `user_email` varchar(255) NOT NULL,
  `entity_id` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `users_to_entites`
--

INSERT INTO `users_to_entites` (`user_email`, `entity_id`) VALUES
('gabriela.perez@estudiantes.utec.edu.uy', '289578985663'),
('gabriela.perezcaviglia@gmail.com', '2895789856634'),
('usuario@pruebas.com', '123123'),
('usuario@pruebas.com', '78998855J');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `mail` varchar(255) NOT NULL,
  `pass` varchar(255) NOT NULL,
  `telefono` varchar(14) DEFAULT NULL,
  `nombre` varchar(255) NOT NULL,
  `ultimoAcceso` date NOT NULL DEFAULT current_timestamp(),
  `ultimaIP` varchar(15) NOT NULL,
  `apellidos` varchar(255) NOT NULL,
  `activo` tinyint(1) NOT NULL,
  `imagen` longblob DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`mail`, `pass`, `telefono`, `nombre`, `ultimoAcceso`, `ultimaIP`, `apellidos`, `activo`, `imagen`) VALUES
('gabriela.perez@estudiantes.utec.edu.uy', 'gAAAAABldkvp-8V0AcRXXqzCNLJdKzKFJeWsLNvuzHSmfHjweaC4q67aFaNfbUJh-slB6mxZ0jRgqFH7cWMvU5WfR33R4pL2kw==', '123456', 'Gabita', '2023-11-13', '0.0.0.0', 'Perez', 1, ''),
('gabriela.perezcaviglia@gmail.com', 'gAAAAABldkvp-8V0AcRXXqzCNLJdKzKFJeWsLNvuzHSmfHjweaC4q67aFaNfbUJh-slB6mxZ0jRgqFH7cWMvU5WfR33R4pL2kw==', NULL, 'Gabriela', '2023-10-27', '0.0.0.0', '', 1, ''),
('minervatechuy252000@gmail.com', 'gAAAAABldkvp-8V0AcRXXqzCNLJdKzKFJeWsLNvuzHSmfHjweaC4q67aFaNfbUJh-slB6mxZ0jRgqFH7cWMvU5WfR33R4pL2kw==', NULL, 'Minerva', '2023-05-02', '0.0.0.0', '', 1, ''),
('prueba@minervatech.uy', 'gAAAAABldkvp-8V0AcRXXqzCNLJdKzKFJeWsLNvuzHSmfHjweaC4q67aFaNfbUJh-slB6mxZ0jRgqFH7cWMvU5WfR33R4pL2kw==', NULL, 'Prueba', '2023-05-05', '0.0.0.0', '', 1, ''),
('usuario@pruebas.com', 'gAAAAABldkvp-8V0AcRXXqzCNLJdKzKFJeWsLNvuzHSmfHjweaC4q67aFaNfbUJh-slB6mxZ0jRgqFH7cWMvU5WfR33R4pL2kw==', NULL, 'user', '2023-10-15', '0.0.0.0', '', 1, '');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `calculadoras_presupuestos_clientes`
--
ALTER TABLE `calculadoras_presupuestos_clientes`
  ADD PRIMARY KEY (`token`,`presupuestos_id`),
  ADD KEY `budget_id` (`presupuestos_id`);

--
-- Indices de la tabla `calculators`
--
ALTER TABLE `calculators`
  ADD PRIMARY KEY (`token`),
  ADD UNIQUE KEY `url` (`url`),
  ADD KEY `entity_ID` (`entity_ID`),
  ADD KEY `Activo` (`activo`);

--
-- Indices de la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`email`);

--
-- Indices de la tabla `entities`
--
ALTER TABLE `entities`
  ADD PRIMARY KEY (`ID`);

--
-- Indices de la tabla `etapa`
--
ALTER TABLE `etapa`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `etapa_data`
--
ALTER TABLE `etapa_data`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_etapa_id` (`etapa_id`);

--
-- Indices de la tabla `etapa_opcion`
--
ALTER TABLE `etapa_opcion`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `presupuestos`
--
ALTER TABLE `presupuestos`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `presupuestos_data`
--
ALTER TABLE `presupuestos_data`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `tokens`
--
ALTER TABLE `tokens`
  ADD PRIMARY KEY (`token`);

--
-- Indices de la tabla `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`email`);

--
-- Indices de la tabla `users_to_calculators`
--
ALTER TABLE `users_to_calculators`
  ADD PRIMARY KEY (`user_email`,`calculator_token`),
  ADD KEY `calculator_token` (`calculator_token`);

--
-- Indices de la tabla `users_to_entites`
--
ALTER TABLE `users_to_entites`
  ADD PRIMARY KEY (`user_email`,`entity_id`),
  ADD KEY `entity_id` (`entity_id`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`mail`),
  ADD KEY `Activo` (`activo`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `etapa`
--
ALTER TABLE `etapa`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=82;

--
-- AUTO_INCREMENT de la tabla `etapa_data`
--
ALTER TABLE `etapa_data`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=185;

--
-- AUTO_INCREMENT de la tabla `etapa_opcion`
--
ALTER TABLE `etapa_opcion`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=337;

--
-- AUTO_INCREMENT de la tabla `presupuestos`
--
ALTER TABLE `presupuestos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=471;

--
-- AUTO_INCREMENT de la tabla `presupuestos_data`
--
ALTER TABLE `presupuestos_data`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=946;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `calculadoras_presupuestos_clientes`
--
ALTER TABLE `calculadoras_presupuestos_clientes`
  ADD CONSTRAINT `calculadoras_presupuestos_clientes_ibfk_1` FOREIGN KEY (`presupuestos_id`) REFERENCES `presupuestos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `calculadoras_presupuestos_clientes_ibfk_2` FOREIGN KEY (`token`) REFERENCES `calculators` (`token`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `users_to_calculators`
--
ALTER TABLE `users_to_calculators`
  ADD CONSTRAINT `users_to_calculators_ibfk_1` FOREIGN KEY (`user_email`) REFERENCES `usuarios` (`mail`),
  ADD CONSTRAINT `users_to_calculators_ibfk_2` FOREIGN KEY (`calculator_token`) REFERENCES `calculators` (`token`);

--
-- Filtros para la tabla `users_to_entites`
--
ALTER TABLE `users_to_entites`
  ADD CONSTRAINT `users_to_entites_ibfk_1` FOREIGN KEY (`user_email`) REFERENCES `usuarios` (`mail`),
  ADD CONSTRAINT `users_to_entites_ibfk_2` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`ID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
