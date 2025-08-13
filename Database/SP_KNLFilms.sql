-- PROCEDIMIENTOS ALMACENADOS

DELIMITER $$
CREATE PROCEDURE sp_iniciarSesion(
    IN p_email VARCHAR(100),
    IN p_contrasena VARCHAR(255),
    OUT o_idUsuario INT,
    OUT o_tipoUsuario INT -- 1 para Cliente, 2 para Empleado, 0 si no se encuentra
)
BEGIN
    DECLARE v_id INT DEFAULT NULL;
    DECLARE v_hashContrasena CHAR(64) DEFAULT '';
    DECLARE v_tipo INT DEFAULT 0;

    SET v_hashContrasena = SHA2(p_contrasena, 256);

    SELECT idCliente INTO v_id FROM cliente
    WHERE email = p_email AND contrasenaHash = v_hashContrasena AND estado = 'ACTIVO';
    IF v_id IS NOT NULL THEN
        SET v_tipo = 1; -- Es un cliente
    ELSE
        SELECT idEmpleado INTO v_id FROM empleados
        WHERE email = p_email AND contrasenaHash = v_hashContrasena;
        IF v_id IS NOT NULL THEN
            SET v_tipo = 2; -- Es un empleado
        END IF;
    END IF;

    SET o_idUsuario = v_id;
    SET o_tipoUsuario = v_tipo;

END$$
DELIMITER ;


-- PROCEDIMIENTO ALMACENADO PARA INSERTAR UN CLIENTE (Se usará para el registro)
DELIMITER $$
CREATE PROCEDURE sp_insertarCliente(
    IN p_nombre VARCHAR(50),
    IN p_apellido VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_telefono VARCHAR(15),
    IN p_contrasena VARCHAR(255),
    OUT o_idCliente INT
)
BEGIN
    DECLARE v_hashContrasena CHAR(64);
    DECLARE EXIT HANDLER FOR 1062 -- Código de error para entrada duplicada
    BEGIN
        SET o_idCliente = -1; -- Señal para indicar email duplicado
    END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET o_idCliente = 0; -- Señal para indicar un error general
    END;
    SET v_hashContrasena = SHA2(p_contrasena, 256);
    INSERT INTO cliente(nombre, apellido, email, telefono, contrasenaHash)
    VALUES (p_nombre, p_apellido, p_email, p_telefono, v_hashContrasena);
    SET o_idCliente = LAST_INSERT_ID();
END$$
DELIMITER ;

-- PROCEDIMIENTO ALMACENADO PARA INSERTAR EMPLEADOS (Se usará para insertar administradores)
DELIMITER $$
CREATE PROCEDURE sp_insertarEmpleado(
    IN p_nombre VARCHAR(50),
    IN p_apellido VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_telefono VARCHAR(15),
    IN p_direccion VARCHAR(255),
    IN p_contrasena VARCHAR(255),
    IN p_puesto VARCHAR(50),
    IN p_fechaContratacion DATE,
    OUT o_idEmpleado INT
)
BEGIN
    DECLARE v_hashContrasena CHAR(64);
    DECLARE EXIT HANDLER FOR 1062 -- Código de error para entrada duplicada
    BEGIN
        SET o_idEmpleado = -1; -- Señal para indicar email duplicado
    END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET o_idEmpleado = 0; -- Señal para indicar un error general
    END;
    SET v_hashContrasena = SHA2(p_contrasena, 256);
    INSERT INTO empleados(nombre, apellido, email, telefono, direccion, contrasenaHash, puesto, fechaContratacion)
    VALUES(p_nombre, p_apellido, p_email, p_telefono, p_direccion, v_hashContrasena, p_puesto, p_fechaContratacion);
    SET o_idEmpleado = LAST_INSERT_ID();
END$$
DELIMITER ;