USE [master]
GO
/****** Object:  Database [RATASAS]    Script Date: 09/09/2015 15:59:06 ******/
CREATE DATABASE [RATASAS]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'RATASAS', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\RATASAS.mdf' , SIZE = 4160KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'RATASAS_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\RATASAS_log.ldf' , SIZE = 1040KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [RATASAS] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [RATASAS].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [RATASAS] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [RATASAS] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [RATASAS] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [RATASAS] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [RATASAS] SET ARITHABORT OFF 
GO
ALTER DATABASE [RATASAS] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [RATASAS] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [RATASAS] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [RATASAS] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [RATASAS] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [RATASAS] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [RATASAS] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [RATASAS] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [RATASAS] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [RATASAS] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [RATASAS] SET  ENABLE_BROKER 
GO
ALTER DATABASE [RATASAS] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [RATASAS] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [RATASAS] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [RATASAS] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [RATASAS] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [RATASAS] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [RATASAS] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [RATASAS] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [RATASAS] SET  MULTI_USER 
GO
ALTER DATABASE [RATASAS] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [RATASAS] SET DB_CHAINING OFF 
GO
ALTER DATABASE [RATASAS] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [RATASAS] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'RATASAS', N'ON'
GO
USE [RATASAS]
GO
/****** Object:  StoredProcedure [dbo].[USP_S_DETALLEFECHA]    Script Date: 09/09/2015 15:59:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[USP_S_DETALLEFECHA]
@idban int, --esta baina es para mandar el nombre del banco
@idcon int,	-- aqui marcamos la condicion que es PRESTAMO ACTIVO FIJO POR S/. 2 000 A 24 MESES
@idreg int, -- para la region que sera tacna
@idpro int,	-- para el producto que es activo fijo (solo tengo eso rellenado en la base de datos :C)
@idope int -- y esto es para el credito
as
begin
select * from detalle where idban=@idban and idcon=@idcon and idreg=@idreg and idpro=@idpro and idope=@idope
end
GO
/****** Object:  StoredProcedure [dbo].[USP_S_LISTARBANCO]    Script Date: 09/09/2015 15:59:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_S_LISTARBANCO]
@idreg int 
AS
BEGIN
select b.idban, b.nombreban from detalle d 
inner join banco b on b.idban=d.idban
inner join region r on r.idreg=d.idreg
where r.idreg=@idreg
group by b.nombreban,b.idban
end
GO
/****** Object:  StoredProcedure [dbo].[USP_S_SUCURSALES]    Script Date: 09/09/2015 15:59:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[USP_S_SUCURSALES]
@idban varchar(50)
AS
BEGIN
select b.nombreban, r.nombrereg from detalle d 
inner join banco b on b.idban=d.idban
inner join region r on r.idreg=d.idreg
where b.idban=@idban
group by r.nombrereg, b.nombreban
end
GO
/****** Object:  StoredProcedure [dbo].[USP_S_TASAS]    Script Date: 09/09/2015 15:59:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_S_TASAS]
@idban varchar(50)
AS
BEGIN
select b.nombreban, r.nombrereg,  o.nombreope, p.descripcionpro,c.descripcioncon,d.porcentajedeta + ' %'  as tasa from detalle d 
inner join banco b on b.idban=d.idban
inner join region r on r.idreg=d.idreg
inner join condicion c on c.idcon=d.idcon
inner join producto p on p.idpro=d.idpro
inner join operacion o on o.idope=d.idope
where b.idban=@idban
END
GO
/****** Object:  StoredProcedure [dbo].[USP_SIMULADOR]    Script Date: 09/09/2015 15:59:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[USP_SIMULADOR]
@nombrereg varchar(50),
@nombreope varchar(50),
@descripcionpro varchar(50),
@descripcioncon varchar(200),
@cantidad int
as

begin 
select top 5 b.nombreban,d.porcentajedeta + ' %', d.cuotadeta  from detalle d 
inner join banco b on b.idban=d.idban
inner join region r on r.idreg=d.idreg
inner join condicion c on c.idcon=d.idcon
inner join producto p on p.idpro=d.idpro
inner join operacion o on o.idope=d.idope
where r.nombrereg=@nombrereg and o.nombreope=@nombreope and p.descripcionpro=@descripcionpro and c.descripcioncon=@descripcioncon 
end
GO
/****** Object:  StoredProcedure [dbo].[USP_Usuario_Login]    Script Date: 09/09/2015 15:59:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_Usuario_Login]
@codigousu varchar(50),
@claveusu varchar(50)
AS
BEGIN
BEGIN TRAN
	BEGIN TRY
select * from usuario where codigousu = @codigousu AND claveusu = @claveusu 
COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
	END CATCH
END


GO
/****** Object:  Table [dbo].[banco]    Script Date: 09/09/2015 15:59:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[banco](
	[idban] [int] IDENTITY(1,1) NOT NULL,
	[nombreban] [varchar](50) NULL,
 CONSTRAINT [PK_banco] PRIMARY KEY CLUSTERED 
(
	[idban] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[condicion]    Script Date: 09/09/2015 15:59:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[condicion](
	[idcon] [int] IDENTITY(1,1) NOT NULL,
	[descripcioncon] [varchar](200) NULL,
	[cantidadcon] [int] NULL,
	[mesescon] [int] NULL,
	[monedacon] [varchar](50) NULL,
 CONSTRAINT [PK_condicion] PRIMARY KEY CLUSTERED 
(
	[idcon] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[detalle]    Script Date: 09/09/2015 15:59:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[detalle](
	[iddeta] [int] IDENTITY(1,1) NOT NULL,
	[idban] [int] NULL,
	[idcon] [int] NULL,
	[idreg] [int] NULL,
	[idpro] [int] NULL,
	[idope] [int] NULL,
	[porcentajedeta] [varchar](50) NULL,
	[cuotadeta] [varchar](50) NULL,
	[idusu] [int] NULL,
 CONSTRAINT [PK_detalle] PRIMARY KEY CLUSTERED 
(
	[iddeta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[operacion]    Script Date: 09/09/2015 15:59:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[operacion](
	[idope] [int] IDENTITY(1,1) NOT NULL,
	[nombreope] [varchar](50) NULL,
 CONSTRAINT [PK_operacion] PRIMARY KEY CLUSTERED 
(
	[idope] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[producto]    Script Date: 09/09/2015 15:59:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[producto](
	[idpro] [int] IDENTITY(1,1) NOT NULL,
	[descripcionpro] [varchar](50) NULL,
 CONSTRAINT [PK_producto] PRIMARY KEY CLUSTERED 
(
	[idpro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[region]    Script Date: 09/09/2015 15:59:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[region](
	[idreg] [int] IDENTITY(1,1) NOT NULL,
	[nombrereg] [varchar](50) NULL,
 CONSTRAINT [PK_region] PRIMARY KEY CLUSTERED 
(
	[idreg] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[usuario]    Script Date: 09/09/2015 15:59:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[usuario](
	[idusu] [int] IDENTITY(1,1) NOT NULL,
	[nombreusu] [varchar](50) NULL,
	[apellidousu] [varchar](50) NULL,
	[codigousu] [varchar](50) NULL,
	[claveusu] [varchar](50) NULL,
 CONSTRAINT [PK_usuario] PRIMARY KEY CLUSTERED 
(
	[idusu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET IDENTITY_INSERT [dbo].[banco] ON 

INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (42, N'ACCESO CREDITICIO')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (22, N'BANBIF')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (24, N'BANCO AZTECA')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (15, N'BANCO CONTINENTAL')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (32, N'BANCO DE COMERCIO')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (9, N'BANCO DE CREDITO')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (7, N'BANCO FINANCIERO')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (29, N'BNP PARIBAS CARDIF')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (2, N'CMAC AREQUIPA')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (16, N'CMAC CUSCO S A')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (50, N'CMAC DEL SANTA')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (33, N'CMAC HUANCAYO')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (43, N'CMAC ICA')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (13, N'CMAC PIURA')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (40, N'CMAC SULLANA')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (1, N'CMAC TACNA')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (45, N'CMAC TRUJILLO')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (3, N'CMCP LIMA')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (21, N'COMPARTAMOS FINANCIE')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (44, N'CRAC CHAVIN')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (34, N'CRAC CREDINKA')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (36, N'CRAC PRYMERA')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (8, N'CREDISCOTIA')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (39, N'EDPYME ALTERNATIVA')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (38, N'EDPYME CREDIJET')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (41, N'EDPYME CREDIVISION')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (23, N'EDPYME MARCIMEX S.A.')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (46, N'EDPYME RAIZ')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (35, N'EDPYME SOLIDARIDAD')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (6, N'FINANC. NUEVA VISION')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (31, N'FINANC. PROEMPRESA')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (14, N'FINANCIERA CONFIANZA')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (11, N'FINANCIERA EDYFICAR')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (10, N'FINANCIERA EFECTIVA')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (49, N'FINANCIERA QAPAQ')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (47, N'FINANCIERA TFC S A')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (4, N'INTERBANK')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (30, N'LA POSITIVA')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (28, N'MAPFRE PERU')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (12, N'MIBANCO')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (26, N'PACIFICO SEGUROS')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (27, N'RIMAC SEGUROS')
INSERT [dbo].[banco] ([idban], [nombreban]) VALUES (17, N'SCOTIABANK PERU')
SET IDENTITY_INSERT [dbo].[banco] OFF
SET IDENTITY_INSERT [dbo].[condicion] ON 

INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (1, N'PRESTAMO ACTIVO FIJO POR S/. 2 000 A 24 MESES', 2000, 24, N'SOLES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (2, N'PRESTAMO ACTIVO FIJO POR S/. 20 000 A 24 MESES', 20000, 24, N'SOLES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (3, N'PRESTAMO ACTIVO FIJO POR US$ 1 000 A 24 MESES', 1000, 24, N'DOLARES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (4, N'PRESTAMO ACTIVO FIJO POR US$ 6 000 A 24 MESES', 6000, 24, N'DOLARES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (5, N'PRESTAMO VEHICULAR POR S/. 28 800 A 2 ANOS', 28800, 24, N'SOLES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (6, N'PRESTAMO VEHICULAR POR S/. 43 200 A 3 ANOS', 43200, 36, N'SOLES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (7, N'PRESTAMO VEHICULAR POR US$  9 600 A 2 ANOS', 9600, 24, N'DOLARES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (8, N'PRESTAMO VEHICULAR POR US$ 14 400 A 3 ANOS', 14400, 36, N'DOLARES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (11, N'PRESTAMO CAPITAL DE TRABAJO POR S/. 1 000 A 9 MESES', 1000, 9, N'SOLES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (12, N'PRESTAMO CAPITAL DE TRABAJO POR S/. 10 000 A 9 MESES', 10000, 9, N'SOLES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (13, N'PRESTAMO CAPITAL DE TRABAJO POR US$  500 A 9 MESES', 500, 9, N'DOLARES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (14, N'PRESTAMO CAPITAL DE TRABAJO POR US$ 3 000 A 9 MESES', 3000, 9, N'DOLARES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (15, N'PRESTAMO HIPOTECARIO POR S/. 120 000 A 15 ANOS', 120000, 180, N'SOLES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (16, N'PRESTAMO HIPOTECARIO POR S/. 240 000 A 15 ANOS', 240000, 180, N'SOLES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (17, N'PRESTAMO HIPOTECARIO POR US$ 40 000 A 15 ANOS', 40000, 180, N'DOLARES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (18, N'PRESTAMO HIPOTECARIO POR US$ 80 000 A 15 ANOS', 80000, 180, N'DOLARES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (19, N'PRESTAMO MIVIVIENDA POR S/. 54 000 A 15 ANOS', 54000, 180, N'SOLES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (20, N'PRESTAMO MIVIVIENDA POR S/. 90 000 A 15 ANOS', 90000, 180, N'SOLES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (21, N'PRESTAMO DE CONSUMO POR S/.  500 A 12 MESES', 500, 12, N'SOLES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (22, N'PRESTAMO DE CONSUMO POR S/. 1 000 A 12 MESES', 1000, 12, N'SOLES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (23, N'PRESTAMO DE CONSUMO POR US$ 150 A 12 MESES', 150, 12, N'DOLARES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (24, N'PRESTAMO DE CONSUMO POR US$ 300 A 12 MESES', 300, 12, N'DOLARES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (25, N'PRESTAMO PERSONAL POR S/.  5 000 A 12 MESES', 5000, 12, N'SOLES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (26, N'PRESTAMO PERSONAL POR S/. 10 000 A 12 MESES', 10000, 12, N'SOLES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (27, N'PRESTAMO PERSONAL POR US$ 1 500 A 12 MESES', 1500, 12, N'DOLARES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (28, N'PRESTAMO PERSONAL POR US$ 4 000 A 12 MESES', 4000, 12, N'DOLARES')
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (29, N'TARJETA DE CREDITO CLASICA - CUOTAS', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (30, N'TARJETA DE CREDITO CLASICA - SISTEMA REVOLVENTE', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (31, N'CUENTA DE AHORRO EN DOLARES CON COBRO DE MANTENIMIENTO', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (32, N'CUENTA DE AHORRO SIN COBRO DE MANTENIMIENTO', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (33, N'CUENTA DE AHORRO EN NUEVOS SOLES CON COBRO DE MANTENIMIENTO', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (34, N'CUENTA DE AHORRO EN NUEVO SOLES SIN COBRO DE MANTENIMIENTO', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (35, N'RENDIMIENTO DE CUENTAS DE AHORRO EN DOLARES CON COBRO DE MANTENIMIENTO', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (36, N'RENDIMIENTO DE CUENTAS DE AHORRO EN SOLES CON COBRO DE MANTENIMIENTO', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (37, N'RENDIMIENTO ASOCIADO A LOS DEPOSITOS CTS', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (38, N'DEPOSITOS A PLAZO POR US$. 1 500 A 360 DIAS', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (39, N'DEPOSITOS A PLAZO POR US$. 1 500 A 90 DIAS', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (40, N'DEPOSITOS A PLAZO POR US$. 10 000 A 360 DIAS', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (41, N'DEPOSITOS A PLAZO POR US$. 10 000 A 90 DIAS', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (42, N'DEPOSITOS A PLAZO POR US$. 3 000 A 360 DIAS', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (43, N'DEPOSITOS A PLAZO POR US$. 3 000 A 90 DIAS', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (44, N'DEPOSITOS A PLAZO POR S/.  5 000 A 360 DIAS', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (45, N'DEPOSITOS A PLAZO POR S/. 10 000 A 360 DIAS', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (46, N'DEPOSITOS A PLAZO POR S/. 10 000 A 90 DIAS', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (47, N'DEPOSITOS A PLAZO POR S/. 2 500 A 360 DIAS', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (48, N'DEPOSITOS A PLAZO POR S/. 2 500 A 90 DIAS', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (49, N'DEPOSITOS A PLAZO POR S/. 20 000 A 360 DIAS', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (50, N'DEPOSITOS A PLAZO POR S/. 20 000 A 90 DIAS', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (51, N'DEPOSITOS A PLAZO POR S/. 5 000 A 90 DIAS', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (52, N'COBERTURA DE SEGUROS ESCOLARES DE ACCIDENTES PERSONALES PARA POLIZAS CON PRIMAS ANUALES ENTRE US$ 20 Y US$ 25', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (53, N'COBERTURA DE SEGUROS ESCOLARES DE ACCIDENTES PERSONALES PARA POLIZAS CON PRIMAS ANUALES ENTRE US$ 25 Y US$ 30', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (54, N'COBERTURA DE SEGUROS ESCOLARES DE ACCIDENTES PERSONALES PARA POLIZAS CON PRIMAS ANUALES ENTRE US$ 30 Y US$ 35', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (55, N'COBERTURA DE SEGUROS ESCOLARES DE ACCIDENTES PERSONALES PARA POLIZAS CON PRIMAS ANUALES MENORES A US$ 20', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (56, N'PRECIO DE VENTA REFERENCIAL DEL SOAT PARA AUTOMOVILES EN NUEVOS SOLES', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (57, N'PRECIO DE VENTA REFERENCIAL DEL SOAT PARA MICROBUS EN NUEVOS SOLES', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (58, N'PRECIO DE VENTA REFERENCIAL DEL SOAT PARA MINIBUS EN NUEVOS SOLES', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (59, N'PRECIO DE VENTA REFERENCIAL DEL SOAT PARA MOTOCICLETA EN NUEVOS SOLES', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (60, N'PRECIO DE VENTA REFERENCIAL DEL SOAT PARA OMNIBUS EN NUEVOS SOLES', NULL, NULL, NULL)
INSERT [dbo].[condicion] ([idcon], [descripcioncon], [cantidadcon], [mesescon], [monedacon]) VALUES (61, N'PRECIO DE VENTA REFERENCIAL DEL SOAT PARA STATION WAGON - TAXI - EN NUEVOS SOLES', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[condicion] OFF
SET IDENTITY_INSERT [dbo].[detalle] ON 

INSERT [dbo].[detalle] ([iddeta], [idban], [idcon], [idreg], [idpro], [idope], [porcentajedeta], [cuotadeta], [idusu]) VALUES (1, 1, 1, 23, 1, 1, N'49.99', N'120.69', NULL)
INSERT [dbo].[detalle] ([iddeta], [idban], [idcon], [idreg], [idpro], [idope], [porcentajedeta], [cuotadeta], [idusu]) VALUES (2, 2, 1, 23, 1, 1, N'49.36', N'123.80', NULL)
INSERT [dbo].[detalle] ([iddeta], [idban], [idcon], [idreg], [idpro], [idope], [porcentajedeta], [cuotadeta], [idusu]) VALUES (3, 3, 1, 23, 1, 1, N'51.12', N'124.56', NULL)
INSERT [dbo].[detalle] ([iddeta], [idban], [idcon], [idreg], [idpro], [idope], [porcentajedeta], [cuotadeta], [idusu]) VALUES (4, 4, 1, 23, 1, 1, N'57.41', N'129.21', NULL)
INSERT [dbo].[detalle] ([iddeta], [idban], [idcon], [idreg], [idpro], [idope], [porcentajedeta], [cuotadeta], [idusu]) VALUES (5, 6, 1, 23, 1, 1, N'59.02', N'130.42', NULL)
INSERT [dbo].[detalle] ([iddeta], [idban], [idcon], [idreg], [idpro], [idope], [porcentajedeta], [cuotadeta], [idusu]) VALUES (6, 7, 1, 23, 1, 1, N'63.67', N'132.96', NULL)
INSERT [dbo].[detalle] ([iddeta], [idban], [idcon], [idreg], [idpro], [idope], [porcentajedeta], [cuotadeta], [idusu]) VALUES (7, 8, 1, 23, 1, 1, N'67.57', N'137.28', NULL)
INSERT [dbo].[detalle] ([iddeta], [idban], [idcon], [idreg], [idpro], [idope], [porcentajedeta], [cuotadeta], [idusu]) VALUES (8, 9, 1, 23, 1, 1, N'73.52', N'141.96', NULL)
INSERT [dbo].[detalle] ([iddeta], [idban], [idcon], [idreg], [idpro], [idope], [porcentajedeta], [cuotadeta], [idusu]) VALUES (9, 10, 1, 23, 1, 1, N'79.87', N'146.37', NULL)
INSERT [dbo].[detalle] ([iddeta], [idban], [idcon], [idreg], [idpro], [idope], [porcentajedeta], [cuotadeta], [idusu]) VALUES (10, 11, 1, 23, 1, 1, N'80.46', N'146.20', NULL)
INSERT [dbo].[detalle] ([iddeta], [idban], [idcon], [idreg], [idpro], [idope], [porcentajedeta], [cuotadeta], [idusu]) VALUES (11, 12, 1, 23, 1, 1, N'80.56', N'147.10', NULL)
INSERT [dbo].[detalle] ([iddeta], [idban], [idcon], [idreg], [idpro], [idope], [porcentajedeta], [cuotadeta], [idusu]) VALUES (12, 13, 1, 23, 1, 1, N'100.32', N'159.10', NULL)
INSERT [dbo].[detalle] ([iddeta], [idban], [idcon], [idreg], [idpro], [idope], [porcentajedeta], [cuotadeta], [idusu]) VALUES (13, 14, 1, 23, 1, 1, N'152.37', N'190.62', NULL)
SET IDENTITY_INSERT [dbo].[detalle] OFF
SET IDENTITY_INSERT [dbo].[operacion] ON 

INSERT [dbo].[operacion] ([idope], [nombreope]) VALUES (1, N'CREDITOS  ')
INSERT [dbo].[operacion] ([idope], [nombreope]) VALUES (2, N'DEPOSITOS ')
INSERT [dbo].[operacion] ([idope], [nombreope]) VALUES (3, N'SEGUROS   ')
SET IDENTITY_INSERT [dbo].[operacion] OFF
SET IDENTITY_INSERT [dbo].[producto] ON 

INSERT [dbo].[producto] ([idpro], [descripcionpro]) VALUES (1, N'ACTIVO FIJO')
INSERT [dbo].[producto] ([idpro], [descripcionpro]) VALUES (2, N'AUTOMOVIL')
INSERT [dbo].[producto] ([idpro], [descripcionpro]) VALUES (3, N'CAPITAL DE TRABAJO')
INSERT [dbo].[producto] ([idpro], [descripcionpro]) VALUES (4, N'HIPOTECARIO')
INSERT [dbo].[producto] ([idpro], [descripcionpro]) VALUES (5, N'HIPOTECARIO MIVIVIENDA')
INSERT [dbo].[producto] ([idpro], [descripcionpro]) VALUES (6, N'PRESTAMO DE CONSUMO')
INSERT [dbo].[producto] ([idpro], [descripcionpro]) VALUES (7, N'TARJETA DE CREDITO')
INSERT [dbo].[producto] ([idpro], [descripcionpro]) VALUES (8, N'AHORRO PERSONAS NATURALES')
INSERT [dbo].[producto] ([idpro], [descripcionpro]) VALUES (9, N'CTS')
INSERT [dbo].[producto] ([idpro], [descripcionpro]) VALUES (10, N'PLAZO FIJO EN DOLARES')
INSERT [dbo].[producto] ([idpro], [descripcionpro]) VALUES (11, N'PLAZO FIJO EN SOLES')
INSERT [dbo].[producto] ([idpro], [descripcionpro]) VALUES (12, N'SEGURO ESCOLAR')
INSERT [dbo].[producto] ([idpro], [descripcionpro]) VALUES (13, N'SOAT')
SET IDENTITY_INSERT [dbo].[producto] OFF
SET IDENTITY_INSERT [dbo].[region] ON 

INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (1, N'AMAZONAS')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (2, N'ANCASH')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (3, N'APURIMAC')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (4, N'AREQUIPA')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (5, N'AYACUCHO')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (6, N'CAJAMARCA')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (7, N'CALLAO')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (8, N'CUSCO')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (9, N'HUANCAVELICA')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (10, N'HUANUCO')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (11, N'ICA')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (12, N'JUNIN')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (13, N'LA LIBERTAD')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (14, N'LAMBAYEQUE')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (15, N'LIMA')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (16, N'LORETO')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (17, N'MADRE DE DIOS')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (18, N'MOQUEGUA')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (19, N'PASCO')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (20, N'IURA')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (21, N'PUNO')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (22, N'SAN MARTIN')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (23, N'TACNA')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (24, N'TUMBES')
INSERT [dbo].[region] ([idreg], [nombrereg]) VALUES (25, N'UCAYALI')
SET IDENTITY_INSERT [dbo].[region] OFF
SET IDENTITY_INSERT [dbo].[usuario] ON 

INSERT [dbo].[usuario] ([idusu], [nombreusu], [apellidousu], [codigousu], [claveusu]) VALUES (1, N'Felíx', N'Casño', N'77441122', N'1234')
SET IDENTITY_INSERT [dbo].[usuario] OFF
SET ANSI_PADDING ON

GO
/****** Object:  Index [UQ__banco__23E6644925BDE954]    Script Date: 09/09/2015 15:59:06 ******/
ALTER TABLE [dbo].[banco] ADD UNIQUE NONCLUSTERED 
(
	[nombreban] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[detalle]  WITH CHECK ADD  CONSTRAINT [FK_detalle de prestamo_banco] FOREIGN KEY([idban])
REFERENCES [dbo].[banco] ([idban])
GO
ALTER TABLE [dbo].[detalle] CHECK CONSTRAINT [FK_detalle de prestamo_banco]
GO
ALTER TABLE [dbo].[detalle]  WITH CHECK ADD  CONSTRAINT [FK_detalle de prestamo_condicion] FOREIGN KEY([idcon])
REFERENCES [dbo].[condicion] ([idcon])
GO
ALTER TABLE [dbo].[detalle] CHECK CONSTRAINT [FK_detalle de prestamo_condicion]
GO
ALTER TABLE [dbo].[detalle]  WITH CHECK ADD  CONSTRAINT [FK_detalle de prestamo_operacion] FOREIGN KEY([idope])
REFERENCES [dbo].[operacion] ([idope])
GO
ALTER TABLE [dbo].[detalle] CHECK CONSTRAINT [FK_detalle de prestamo_operacion]
GO
ALTER TABLE [dbo].[detalle]  WITH CHECK ADD  CONSTRAINT [FK_detalle de prestamo_producto] FOREIGN KEY([idpro])
REFERENCES [dbo].[producto] ([idpro])
GO
ALTER TABLE [dbo].[detalle] CHECK CONSTRAINT [FK_detalle de prestamo_producto]
GO
ALTER TABLE [dbo].[detalle]  WITH CHECK ADD  CONSTRAINT [FK_detalle de prestamo_region] FOREIGN KEY([idreg])
REFERENCES [dbo].[region] ([idreg])
GO
ALTER TABLE [dbo].[detalle] CHECK CONSTRAINT [FK_detalle de prestamo_region]
GO
ALTER TABLE [dbo].[detalle]  WITH CHECK ADD  CONSTRAINT [FK_detalle de prestamo_usuario] FOREIGN KEY([idusu])
REFERENCES [dbo].[usuario] ([idusu])
GO
ALTER TABLE [dbo].[detalle] CHECK CONSTRAINT [FK_detalle de prestamo_usuario]
GO
USE [master]
GO
ALTER DATABASE [RATASAS] SET  READ_WRITE 
GO
