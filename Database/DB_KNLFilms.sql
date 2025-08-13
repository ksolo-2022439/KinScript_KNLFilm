DROP DATABASE IF EXISTS DB_KNLFilms;
CREATE DATABASE IF NOT EXISTS DB_KNLFilms;
USE DB_KNLFilms;

-- --- TABLAS PRINCIPALES (Entidades independientes) ---
CREATE TABLE proveedor (
    idProveedor INT AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    contacto VARCHAR(100),
    telefono VARCHAR(15),
    CONSTRAINT PK_Proveedor PRIMARY KEY (idProveedor)
);

CREATE TABLE cliente (
    idCliente INT AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(15),
    estado ENUM('ACTIVO','INACTIVO') NOT NULL DEFAULT 'ACTIVO',
    contrasenaHash CHAR(64) NOT NULL, -- Se asume un hash SHA-256
    fechaRegistro DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Cliente PRIMARY KEY (idCliente)
);

CREATE TABLE empleados (
    idEmpleado INT AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(15),
    direccion VARCHAR(255),
    contrasenaHash CHAR(64) NOT NULL,
    puesto VARCHAR(50),
    fechaContratacion DATE,
    CONSTRAINT PK_Empleados PRIMARY KEY (idEmpleado)
);

-- --- TABLAS CATÁLOGO DE PELÍCULAS (Información sobre el producto) ---
CREATE TABLE generos (
    idGenero INT AUTO_INCREMENT,
    nombreGenero VARCHAR(50) UNIQUE NOT NULL,
    CONSTRAINT PK_Generos PRIMARY KEY (idGenero)
);

CREATE TABLE directores (
    idDirector INT AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50),
    CONSTRAINT PK_Directores PRIMARY KEY (idDirector)
);

CREATE TABLE peliculas (
    idPelicula INT AUTO_INCREMENT,
    titulo VARCHAR(100) NOT NULL,
    sinopsis TEXT,
    anoLanzamiento YEAR,
    idDirector INT,
    idProveedor INT,
    precio DECIMAL(10, 2) NOT NULL,
    urlPortada VARCHAR(255),
    clasificacion VARCHAR(10),
    CONSTRAINT PK_Peliculas PRIMARY KEY (idPelicula),
    CONSTRAINT FK_PeliculaDirector FOREIGN KEY (idDirector) REFERENCES directores(idDirector),
    CONSTRAINT FK_PeliculaProveedor FOREIGN KEY (idProveedor) REFERENCES proveedor(idProveedor)
);

-- --- TABLAS DE RELACIÓN (Muchos a Muchos) ---
CREATE TABLE pelicula_genero (
    idPelicula INT,
    idGenero INT,
    CONSTRAINT PK_PeliculaGenero PRIMARY KEY (idPelicula, idGenero),
    CONSTRAINT FK_PG_Pelicula FOREIGN KEY (idPelicula) REFERENCES peliculas(idPelicula) ON DELETE CASCADE,
    CONSTRAINT FK_PG_Genero FOREIGN KEY (idGenero) REFERENCES generos(idGenero) ON DELETE CASCADE
);

-- --- PROCESO DE COMPRA ---
CREATE TABLE carrito (
    idCarrito INT AUTO_INCREMENT,
    idCliente INT NOT NULL,
    fechaCreacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('ACTIVO','COMPLETADO','ABANDONADO') NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT PK_Carrito PRIMARY KEY (idCarrito),
    CONSTRAINT FK_CarritoCliente FOREIGN KEY (idCliente) REFERENCES cliente(idCliente)
);

CREATE TABLE detalleCarrito (
    idDetalleCarrito INT AUTO_INCREMENT,
    idCarrito INT NOT NULL,
    idPelicula INT NOT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    precioUnitario DECIMAL(10, 2) NOT NULL,
    CONSTRAINT PK_DetalleCarrito PRIMARY KEY (idDetalleCarrito),
    CONSTRAINT FK_DetalleCarritoCarrito FOREIGN KEY (idCarrito) REFERENCES carrito(idCarrito) ON DELETE CASCADE,
    CONSTRAINT FK_DetalleCarritoPeliculas FOREIGN KEY (idPelicula) REFERENCES peliculas(idPelicula)
);

CREATE TABLE pedidos (
    idPedido INT AUTO_INCREMENT,
    idCliente INT NOT NULL,
    idEmpleado INT, -- Nulo si la compra es automatizada
    fechaPedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10, 2) NOT NULL,
    estadoPedido ENUM('PROCESANDO', 'COMPLETADO', 'FALLIDO') NOT NULL DEFAULT 'PROCESANDO',
    metodoPago ENUM('TARJETA_DE_CREDITO', 'PAYPAL', 'TRANSFERENCIA') NOT NULL,
    CONSTRAINT PK_Pedidos PRIMARY KEY (idPedido),
    CONSTRAINT FK_PedidoCliente FOREIGN KEY (idCliente) REFERENCES cliente(idCliente),
    CONSTRAINT FK_PedidoEmpleados FOREIGN KEY (idEmpleado) REFERENCES empleados(idEmpleado)
);

CREATE TABLE detallePedido (
    idDetallePedido INT AUTO_INCREMENT,
    idPedido INT NOT NULL,
    idPelicula INT NOT NULL,
    cantidad INT NOT NULL,
    precioVenta DECIMAL(10, 2) NOT NULL, -- Precio final de venta
    CONSTRAINT PK_DetallePedido PRIMARY KEY (idDetallePedido),
    CONSTRAINT FK_DetallePedidoPedido FOREIGN KEY (idPedido) REFERENCES pedidos(idPedido) ON DELETE CASCADE,
    CONSTRAINT FK_DetallePedidoPeliculas FOREIGN KEY (idPelicula) REFERENCES peliculas(idPelicula)
);

-- --- TABLAS DE ACCESO Y AUTENTICACIÓN ---
CREATE TABLE libreriaCliente (
    idLibreria INT AUTO_INCREMENT,
    idCliente INT NOT NULL,
    idPelicula INT NOT NULL,
    fechaAdquisicion DATETIME DEFAULT CURRENT_TIMESTAMP,
    urlDescarga VARCHAR(255) NOT NULL,
    CONSTRAINT PK_LibreriaCliente PRIMARY KEY (idLibreria),
    CONSTRAINT FK_LibreriaCliente_Cliente FOREIGN KEY (idCliente) REFERENCES cliente(idCliente) ON DELETE CASCADE,
    CONSTRAINT FK_LibreriaCliente_Pelicula FOREIGN KEY (idPelicula) REFERENCES peliculas(idPelicula),
    CONSTRAINT UQ_ClientePelicula UNIQUE (idCliente, idPelicula)
);

CREATE TABLE cookieAuth (
    id INT AUTO_INCREMENT PRIMARY KEY,
    selector VARCHAR(255) UNIQUE NOT NULL,
    tokenHash VARCHAR(255) NOT NULL,
    idCliente INT,
    idEmpleado INT,
    fechaExpiracion DATETIME NOT NULL,
    CONSTRAINT FK_CookieAuth_Cliente FOREIGN KEY (idCliente) REFERENCES cliente(idCliente) ON DELETE CASCADE,
    CONSTRAINT FK_CookieAuth_Empleado FOREIGN KEY (idEmpleado) REFERENCES empleados(idEmpleado) ON DELETE CASCADE,
    CONSTRAINT CHK_Usuario CHECK (
        (idCliente IS NOT NULL AND idEmpleado IS NULL) OR
        (idCliente IS NULL AND idEmpleado IS NOT NULL)
    )
);