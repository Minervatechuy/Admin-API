-- phpMyAdmin SQL Dump
-- version 5.1.3
-- https://www.phpmyadmin.net/
--
-- Servidor: PMYSQL108.dns-servicio.com:3306
-- Tiempo de generación: 14-10-2023 a las 11:52:15
-- Versión del servidor: 5.7.41
-- Versión de PHP: 8.0.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

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
    
    /* Si devuelve 1, la calculadora se creó, sino hubo un error*/
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
WHERE c.url=url;

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `get_user` (IN `email` VARCHAR(255))   BEGIN
    SELECT u.email, u.completeName, u.lastAccess, u.telephone, u.isActive, u.profilePhoto
    FROM users u 
    WHERE u.email=email;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `get_usuario` (IN `email` VARCHAR(255))   BEGIN
SELECT u.telefono, u.nombre, u.apellidos, u.imagen
FROM usuarios u WHERE u.mail=email;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `get_usuarios_entidad` (IN `entidad_id` VARCHAR(510), IN `email` VARCHAR(510))   BEGIN
SELECT ue.user_email, ue.entity_id, u.nombre, u.apellidos
FROM usuarios u, users_to_entites ue WHERE ue.entity_id= entidad_id AND ue.user_email!=email AND u.mail=ue.user_email;
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `insert_client` (IN `email_cliente` VARCHAR(510), IN `name_cliente` VARCHAR(510), IN `telefono_cliente` VARCHAR(510))   BEGIN

INSERT INTO `clientes` (`email`, `name`, `telephone`) VALUES (email_cliente, name_cliente, telefono_cliente);

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `insert_etapa` (IN `token` VARCHAR(255), IN `tipo` VARCHAR(255), IN `titulo` VARCHAR(255), IN `subtitulo` VARCHAR(255))   BEGIN

SET @posicion = 0;

SELECT IFNULL(MAX(e.posicion), -1) AS count into @posicion FROM etapa e;

INSERT INTO `etapa` (`token`, `tipo`, `titulo`, `subtitulo`, `posicion`) VALUES (token, tipo, titulo, subtitulo, @posicion+1);

SELECT LAST_INSERT_ID();

END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `insert_etapa_data` (IN `etapa_id` INT, IN `meta_key` VARCHAR(510), IN `meta_value` VARCHAR(510))   BEGIN
INSERT INTO `etapa_data` (`etapa_id`, `meta_key`, `meta_value`) VALUES (etapa_id, meta_key, meta_value);
END$$

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `insert_etapa_opcion` (IN `etapa_id` INT, IN `meta_key` VARCHAR(510), IN `meta_value` VARCHAR(510), IN `imagen` LONGBLOB)   BEGIN 
INSERT INTO `etapa_opcion` (`etapa_id`, `meta_key`, `meta_value`, `imagen`) VALUES ( etapa_id, meta_key, meta_value, imagen);
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

CREATE DEFINER=`minervatech`@`localhost` PROCEDURE `verficar_vista` (IN `url` VARCHAR(5100))   SELECT COUNT(*)
FROM calculators c, tokens t
WHERE c.url=url AND c.activo=1 AND t.fechaFin>now() AND t.vendido=1 AND t.canjeado=1$$

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `calculadoras_presupuestos_clientes`
--

INSERT INTO `calculadoras_presupuestos_clientes` (`token`, `presupuestos_id`, `fecha`, `email_cliente`) VALUES
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 1, '2023-02-16', 'prueba2@minervatech.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 2, '2023-03-14', 'test@test.test'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 3, '2023-03-14', 'asf@harakirimail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 4, '2023-03-16', 'mgonzalez@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 5, '2023-03-17', 'mgonzalez@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 6, '2023-03-17', 'mgonzalez@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 7, '2023-03-17', 'mgonzalez@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 8, '2023-03-17', 'mgonzalez@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 9, '2023-03-17', 'mgonzalez@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 10, '2023-03-17', 'mgonzalez@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 11, '2023-03-17', 'mgonzalez@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 12, '2023-03-17', 'mgonzalez@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 13, '2023-03-17', 'mgonzalez@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 14, '2023-03-17', 'mgonzalez@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 15, '2023-03-17', 'mgonzalez@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 16, '2023-03-17', 'mgonzalez@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 17, '2023-03-17', 'mgonzalez@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 18, '2023-03-17', 'mgonzalez@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 19, '2023-03-17', 'mgonzalez@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 20, '2023-03-17', 'mgonzalez@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 21, '2023-03-17', 'mgonzalez@gmail.com'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 22, '2023-03-22', 'mgonzalez@gmail.com');

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `calculators`
--

INSERT INTO `calculators` (`token`, `url`, `ip`, `formula`, `entity_ID`, `name`, `activo`) VALUES
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 'https://minervatech.uy/calculadora/', NULL, '5+[12]+1+[13]', '78995828M', 'Calculadora de presupuesto web', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

CREATE TABLE `clientes` (
  `email` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `telephone` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `clientes`
--

INSERT INTO `clientes` (`email`, `name`, `telephone`) VALUES
('asf@harakirimail.com', 'juan', '666777888'),
('cliente_prueba@minervatech.com', 'Pruebas ', '683 745 695'),
('maxi@minervatech.com', 'Maxi', '683 258 761'),
('maxi@minervatech.com2', 'Maxi', '69632145'),
('mgonzalez@gmail.com', 'Maxi', '6832586'),
('prueba2@minervatech.com', 'Maxi', '68325861'),
('test@test.test', 'test', 'test123');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entidades_calculadoras`
--

CREATE TABLE `entidades_calculadoras` (
  `id_entidad` varchar(510) NOT NULL,
  `token` varchar(510) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `entidades_calculadoras`
--

INSERT INTO `entidades_calculadoras` (`id_entidad`, `token`) VALUES
('78995828M', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('78995828M', 'q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb'),
('78995828M', 'L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub');

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `entities`
--

INSERT INTO `entities` (`ID`, `nombre`, `telefono`, `direccion`, `type`, `activo`, `descripcion`) VALUES
('78995828M', 'MinervaTech', '666666666', 'Calle Iñigo de Loyola, nº 17, 7ºB', 'Autónomo', 1, '');

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
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `etapa`
--

INSERT INTO `etapa` (`id`, `token`, `tipo`, `titulo`, `subtitulo`, `posicion`) VALUES
(13, 'L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 'Discreta', '¿Cuantos litros de gasolina consume tu coche?', 'Introduce tu gasto', 0),
(12, 'L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 'Cualificada', '¿Que fármaco utilizas?', 'Elige tu fármaco para poderte dar un diagnostico adecuado', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `etapa_data`
--

CREATE TABLE `etapa_data` (
  `id` int(11) NOT NULL,
  `etapa_id` int(11) NOT NULL,
  `meta_key` varchar(2550) NOT NULL,
  `meta_value` varchar(2550) NOT NULL,
  `imagen` longblob
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `etapa_data`
--

INSERT INTO `etapa_data` (`id`, `etapa_id`, `meta_key`, `meta_value`, `imagen`) VALUES
(30, 13, 'minimo', '10', NULL),
(29, 13, 'maximo', '120', NULL),
(31, 13, 'valor_inicial', '100', NULL),
(32, 13, 'rangos', '1', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `etapa_opcion`
--

CREATE TABLE `etapa_opcion` (
  `id` int(11) NOT NULL,
  `etapa_id` int(11) NOT NULL,
  `meta_key` varchar(2550) NOT NULL,
  `meta_value` varchar(2550) NOT NULL,
  `imagen` longblob
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `etapa_opcion`
--

INSERT INTO `etapa_opcion` (`id`, `etapa_id`, `meta_key`, `meta_value`, `imagen`) VALUES
(22, 12, 'nombre', 'Paracetamol', NULL),
(23, 12, 'valor', '23', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `logs`
--

CREATE TABLE `logs` (
  `date` varchar(20) NOT NULL,
  `time` varchar(8) NOT NULL,
  `procedure` varchar(255) NOT NULL,
  `in` varchar(1000) NOT NULL,
  `out` varchar(1000) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `logs`
--

INSERT INTO `logs` (`date`, `time`, `procedure`, `in`, `out`) VALUES
('03-24-22', '15:27:59', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '15:57:18', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '16:56:28', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '16:57:00', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:25:26', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:25:55', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:27:12', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:28:06', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:30:02', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:32:02', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:33:02', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:33:39', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:34:37', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:34:41', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:35:06', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:35:49', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:35:55', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:38:04', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:38:21', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:38:54', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:39:01', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:39:34', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:39:56', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:41:21', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:41:43', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:44:02', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:44:09', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:44:29', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:45:31', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:46:00', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:46:30', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:46:36', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:48:22', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:51:19', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:51:33', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:52:49', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:53:57', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:54:21', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:57:35', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:57:41', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '17:57:48', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '18:12:01', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '18:12:08', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '18:12:42', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '18:13:14', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '18:13:42', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '18:14:13', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '18:15:51', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '18:15:57', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '18:17:06', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False'),
('03-24-22', '18:18:36', 'is_user_logged', '{\'user\': \'juan\', \'pwd\': \'juan\'}', 'False');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `presupuestos`
--

CREATE TABLE `presupuestos` (
  `id` int(11) NOT NULL,
  `resultado` int(11) DEFAULT NULL,
  `formula` varchar(2550) DEFAULT NULL,
  `finalizado` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
(22, 93, '5+[12]+1+[13]', 0);

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
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

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
(74, 22, 'valor-opciones', '23', 12);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tokens`
--

CREATE TABLE `tokens` (
  `token` varchar(255) NOT NULL,
  `vendido` tinyint(1) NOT NULL,
  `canjeado` tinyint(1) NOT NULL,
  `fechaFin` date NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `tokens`
--

INSERT INTO `tokens` (`token`, `vendido`, `canjeado`, `fechaFin`) VALUES
('q7Dafa)3_HVrpZHwenPujdKDB&nDMMMyykJb', 1, 0, '2023-08-31'),
('gE5aUzg:SV+PvwVmxGz-DtUSBkEUQRFx3ef', 1, 0, '2023-08-31'),
('uMSRExR?s3TMdp8MTDe!_jV4uSUTbrTWufEb', 1, 0, '2023-08-31'),
('L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub', 1, 1, '2023-08-31'),
('PKJvrCCYGH4b7TAA_gbny:FZ7dEvmTauhkjb', 1, 0, '2023-08-31'),
('4Dpd9LJX-K9DA_A5ZRLY_JnTxdVUevXSqZb', 1, 0, '2023-08-31'),
('RtspT8bBRgGRQFCm@7!cUhMVMszRUE*LcpWb', 0, 0, '2023-08-31'),
('ACxK4ZzPy2)ga&=:LxSkyXQ9pVfxbsKTUHWb', 0, 0, '2023-08-31'),
('g27hJz@wHkujfDtkRfE:CJWmmaMEujthLpnb', 0, 0, '2023-08-31'),
('r8bUKmHHVxEKBHUxvG4kQ+PHj?S7QmaWaqhb', 0, 0, '2023-08-31'),
('9rq(HgmFZ#/uZqutFRGYAwxFSH9bkdHQ5VRb', 0, 0, '2023-08-31'),
('_yu5d_nnQzQt9KedPWgY2Pr&UhxmX*EXkvUb', 0, 0, '2023-08-31'),
('zgJ7LgxmDMEbTMsp2qgs@2(_hxnXKU:QtfDb', 0, 0, '2023-08-31'),
('3aUGsnEGqdEEjZdFBb!gbAJH5fHzQDRq?z*b', 0, 0, '2023-08-31'),
('mUJb9bUUYgMYxKmney6AbVxMy:HEG)YgNfxb', 0, 0, '2023-08-31'),
('Tjwsg#VPEATJVZFfJ_F+QksrFHLagMYqt4b', 0, 0, '2023-08-31'),
('DbYckLjmgErLubvzF?#VXZLAC(9nDPwp=SDb', 0, 0, '2023-08-31'),
('GTr/eYxP79dcUZYDSZUZwxQebt)Xt6-2vPbb', 0, 0, '2023-08-31'),
('TDm?mQKJ8VvNxkm3BJj8@WhGhxBL7)MyNtJb', 0, 0, '2023-08-31'),
('YEENhhqqdXCAnpZhQ7p&SbS@Vh2ypL3S)Pkb', 0, 0, '2023-08-31'),
('HAkVLxnTd3Hc78zqMdxX&uZBs-W#Ywex:Wjb', 0, 0, '2023-08-31'),
('B4/#LEcahLmMeeZXYBQwKzDBDb*bqFqqr53b', 0, 0, '2023-08-31'),
('WgAYnbxjb4KzNM9*YSCeLWkwHbt@uUGdHx3b', 0, 0, '2023-08-31'),
('WMqYWPsYG5B:uc4n2XnH?peTqRFWaaJScbsb', 0, 0, '2023-08-31'),
('naqfpWt3q&AKh6_khRRa*RvJCsWz/kjctnHb', 0, 0, '2023-08-31'),
('CFz&YLE?HmLTSpD2f&ENqrN2unkHcYbLtqfb', 0, 0, '2023-08-31'),
('NV6WFasMFf4TGMc7ZVRCBXUcU/RmK#eyuqb', 0, 0, '2023-08-31'),
('rBBjnd@wtWtvGYtaDywQ2G-zTD2GBTVCVHRb', 0, 0, '2023-08-31'),
('HuwNThqN4LctAvmDRCw:CcmV/gu?h9TAuqhb', 0, 0, '2023-08-31'),
(':UqVbcDuav3cS&tD6TxaucwnN4DnkF@GcWXb', 0, 0, '2023-08-31'),
('R=uL4MUrEcVHWsZxBbqWqy6#Rrw5aTdxSYb', 0, 0, '2023-08-31'),
('EK3EUsAjwSVc3p-tsQXt6!Z=rNBnT4mgw(Mb', 0, 0, '2023-08-31'),
('+C5Kf7UGYvekPb79ZEPrg&BLVCLkNXYGBmTb', 0, 0, '2023-08-31'),
('dKYPsqDh@_yt9QNfCqKPWNTBAK5j8am=rrKb', 0, 0, '2023-08-31'),
('zA9NE:tf9vbpU9msezx4vFdxHSuMuNctAmMb', 0, 0, '2023-08-31'),
('aqe7NP)ygCmKPgBkNRE6=ypYtyFVNvud=vkb', 0, 0, '2023-08-31'),
('edV)ufB#wgMU=wc3DgbgnP3:ef6PQTpTHyCb', 0, 0, '2023-08-31'),
('L&VHW52DeVj#yS4NqQDNMkfFSTHmgkE(HF_b', 0, 0, '2023-08-31'),
('HKJNGt/MWNzGSEmT#qNtkBuHDbM9Say5EWb', 0, 0, '2023-08-31'),
('gZXwU4FaK5wRvzd9x@d_LXBRSgwyxbWxkW?b', 0, 0, '2023-08-31'),
('6TwTMgQUrLyktzPge#d93_aHPXZ8LNHzfRb', 0, 0, '2023-08-31'),
('Dfnh3UzJ*!a@C8UVswwnxyhFdWJedDpq8Rb', 0, 0, '2023-08-31'),
('u3Jv&s6raWh8fuJz7fwfVMYFWK+_sawYpsjb', 0, 0, '2023-08-31'),
('TCNW=mPVhBBFvdvfGWJw!g77CxDdUyrxbmtb', 0, 0, '2023-08-31'),
('GfJNL*jHn9AvaSBNA9ATmTBPMmbWN9=Jnsbb', 0, 0, '2023-08-31'),
('JQwVthKhm)JQSAd6Wn?pxabr3rYmEYHxPBHb', 0, 0, '2023-08-31'),
('VEeA8-myAT45nS_xpHjFFgsjBFd=UfbhYGfb', 0, 0, '2023-08-31'),
('VjLb_ZENU6A6szagjgVxQ_zjP:CPJVrz5Hfb', 0, 0, '2023-08-31'),
('cSdF-uZNbAnhSws*fRUPzXeDjtG66GTv)cHb', 0, 0, '2023-08-31'),
('PRD4K*LYqvegLmMS3Jxh(J=nsprCAjg4BZHb', 0, 0, '2023-08-31'),
('cFPFVKBMWy(rW?4(pzN4UxSJLke6QJSGbnb', 0, 0, '2023-08-31'),
('8v?BNEDddKfPd4w!kW*zkyqK@6nWcxtAJMCb', 0, 0, '2023-08-31'),
(')bVXTwuZzx?EyfcbMpDRDyJNCcbJtD!5b7Bb', 0, 0, '2023-08-31'),
('m&cQNAmzAnPVs5R-ns8PH)FLB9XVYZNx*6Tb', 0, 0, '2023-08-31'),
('n7hKf2!c*6gAkLCPc/RFd6TZ-rdnkJgKbpCb', 0, 0, '2023-08-31'),
('jYGxaxs(TX&CZw6eYKf_e/gMxWF9gcc5WVKb', 0, 0, '2023-08-31'),
('qR)ZdPbtaQC:JptK85FL8bGTHM9JvmbLTQGb', 0, 0, '2023-08-31'),
('ahLpRvQTw_xrubVMjGEfY!tG58Duwex+Sxb', 0, 0, '2023-08-31'),
('uZxrrMH:JRYgGaJDtJ)w5FGhrT!QecLXPNCb', 0, 0, '2023-08-31'),
('SPwbQHCU9uNa+xsZK3@FMrDkxaUuxbcPG2Tb', 0, 0, '2023-08-31'),
(':ERn56XuGuG4BfsUwUBp-LHWaM5MdftmmUb', 0, 0, '2023-08-31'),
('gDxaDHrSxSF_qQeh2NFVRc4GMNe6jkD7wCHb', 0, 0, '2023-08-31'),
('y6m8kwQFavKWqdeqVGyeTAyhtcVYhb*KzrCb', 0, 0, '2023-08-31'),
('VteQukgCsm:Ts6AVv4DcWMR2gB@ScqPFy4kb', 0, 0, '2023-08-31'),
('6j_2#nYKAVyGKUva-LtP2Wf@ahe7jZHfShmb', 0, 0, '2023-08-31'),
('FKy#hcsg6pQdTpfpYtSY5AjbnUE9aMkm@k6b', 0, 0, '2023-08-31'),
('Xz5x8cqd!7UWeWN:ZD=NgBeU(wb4aGgNgEgb', 0, 0, '2023-08-31'),
('TNxmFuP_AXFmWz5ar_WpXFDCNtBTST3bbCjb', 0, 0, '2023-08-31'),
('5EujBtwPYYgarj:H/WNNdmxxePbHyFdmNajb', 0, 0, '2023-08-31'),
('g?VR#SBmknArUjYgfrtgqVCCBWnxcBpMk3#b', 0, 0, '2023-08-31'),
('LbKCgFjrb4w&RCZhzbhxDY-j9R(AA5WvBaYb', 0, 0, '2023-08-31'),
('MyL9wBB/jdPXpNZkjWK(QjJkGaXzXezGVrRb', 0, 0, '2023-08-31'),
('MGSyE4UJ?BVd_/qKqjVYrdypemZzbtKgxmcb', 0, 0, '2023-08-31'),
('yPNcMRjsP6erUg*FYH9XGV?vD57=SnMxWgsb', 0, 0, '2023-08-31'),
('yJL6db@hTfjSJ!jhGu2tRMZ@ca)dVewtRKBb', 0, 0, '2023-08-31'),
('ycJKDC:k@PjQM/2sQhmcGs6dAbcHH5qQy9Pb', 0, 0, '2023-08-31'),
('bkQhhY-MTZD3vWEcttvPb&JrUAfa?7suJW7b', 0, 0, '2023-08-31'),
('9mD-ZrnS6WA3+dHwdp*qXbWUeWxgFKtLLJb', 0, 0, '2023-08-31'),
('3MJXxwZ3J2VjGTGx)W/f&XvWaadUqujhKJyb', 0, 0, '2023-08-31'),
('_jdfTPguNp3yw+mz4ChGvvFRArSFZtDsQ?b', 0, 0, '2023-08-31'),
('N7uAuw+DYSDnb-XDGrs8qEb@xFr@XPxW4XWb', 0, 0, '2023-08-31'),
('VNEQ6MyHmRYhqZxUkB9fwyJKcv4avub!n@_b', 0, 0, '2023-08-31'),
('_S!MCXCjnZ6NqHNnQ55)nahGhsSE_LHrRyCb', 0, 0, '2023-08-31'),
('W5HbBXHszagAFkzYz5w+SsBN+RsSC:PD7Lwb', 0, 0, '2023-08-31'),
('LgHbEhBBz)XChk=hbuKBjQdKC5QQYjtkgafb', 0, 0, '2023-08-31'),
('FHt)GyCzQ36jycsJbpzChNa+cFtpNrwchT2b', 0, 0, '2023-08-31'),
('?)Zeh6rvQwYg)c6rDnZQ3EXCmR4kvLCCWFtb', 0, 0, '2023-08-31'),
('RsgducEHBnNvHxK-2avZ6kekgh/Dx49Edbsb', 0, 0, '2023-08-31'),
('4TZPUhXykBzbZ*pvKExMKa+AbMJvkZX=3fdb', 0, 0, '2023-08-31'),
('rHWavjFzWKYKYJsRqxvkRDNwpa+3/AM:YSb', 0, 0, '2023-08-31'),
('ewYpnBaaVpthb3*5V)aBKXZRt&ffHrRt(mUb', 0, 0, '2023-08-31'),
('jEzZudRQqGaQQF-qSKptPQCSkCdaYVwCqV4b', 0, 0, '2023-08-31');

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
  `profilePhoto` longblob
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users_to_calculators`
--

CREATE TABLE `users_to_calculators` (
  `user_email` varchar(255) NOT NULL,
  `calculator_token` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `users_to_calculators`
--

INSERT INTO `users_to_calculators` (`user_email`, `calculator_token`) VALUES
('mgonzalez@gmail.com', 'L4Fcb7WNqsWS-GZqLvRdfeJp-asLMEn87Ub');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users_to_entites`
--

CREATE TABLE `users_to_entites` (
  `user_email` varchar(255) NOT NULL,
  `entity_id` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `users_to_entites`
--

INSERT INTO `users_to_entites` (`user_email`, `entity_id`) VALUES
('mgonzalez@gmail.com', '78995828M');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `mail` varchar(255) NOT NULL,
  `pass` varchar(255) NOT NULL,
  `telefono` varchar(14) DEFAULT NULL,
  `nombre` varchar(255) NOT NULL,
  `ultimoAcceso` date NOT NULL,
  `ultimaIP` varchar(15) NOT NULL,
  `apellidos` varchar(255) NOT NULL,
  `activo` tinyint(1) NOT NULL,
  `imagen` longblob
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`mail`, `pass`, `telefono`, `nombre`, `ultimoAcceso`, `ultimaIP`, `apellidos`, `activo`) VALUES
('mgonzalez@gmail.com', '123', NULL, 'Pruebas', '2023-02-02', '0.0.0.0', '', 1),
('prueba@minervatech.com', '123', NULL, 'Prueba', '2023-02-05', '0.0.0.0', '', 1),
('prueba2@minervatech.com', 'test20', NULL, 'Pruebas', '2023-02-03', '0.0.0.0', '', 1);

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `etapa_data`
--
ALTER TABLE `etapa_data`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT de la tabla `etapa_opcion`
--
ALTER TABLE `etapa_opcion`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT de la tabla `presupuestos`
--
ALTER TABLE `presupuestos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT de la tabla `presupuestos_data`
--
ALTER TABLE `presupuestos_data`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=75;

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
-- Filtros para la tabla `calculators`
--
ALTER TABLE `calculators`
  ADD CONSTRAINT `calculators_ibfk_1` FOREIGN KEY (`entity_ID`) REFERENCES `entities` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;

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
