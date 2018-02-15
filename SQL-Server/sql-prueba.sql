select db_name()

use Negocios2017
use master

select * from sys.tables
-- Comentarios en archivos .sql
select * from information_schema.tables
select * from sys.objects where [type]='p'
select * from INFORMATION_SCHEMA.ROUTINES
select * from sys.databases


/*asdasdsadsadasd
as
d
as
dsa*/

select * from 
select * from Negocios2017.INFORMATION_SCHEMA.tables
select * from sys.objects
-- ***********************************************************************
select * from PIZZAFAST.INFORMATION_SCHEMA.tables pz left join 
                Negocios2017.INFORMATION_SCHEMA.TABLES n 
                on pz.TABLE_SCHEMA= n.TABLE_SCHEMA

select a.TABLE_NAME, 
        b.TABLE_NAME from 
            PIZZAFAST.INFORMATION_SCHEMA.TABLES a,
            Negocios2017.INFORMATION_SCHEMA.TABLES b

            insert into paises values('sdadf',2451,'sdfdsfdfs',true);


--TRIGGERS - EXPERIMENTAR 13
USE Negocios
GO
--Adicionamos una nueva columna 
ALTER TABLE TB_EMPLEADOS
ADD FEC_ACTUALIZACION DATE NULL
GO
--Actualizamos la fecha de actualizacion 
UPDATE TB_EMPLEADOS
SET FEC_ACTUALIZACION = '10/10/2014'
GO
--visualizar los datos y verifique la columna FEC_ACTUALIZACION 
Select *
From Tb_Empleados
GO
--creamos el trigger
CREATE TRIGGER Tb_Empleados_TgA 
ON Tb_Empleados
AFTER UPDATE 
AS
BEGIN
SET NOCOUNT ON;
UPDATE dbo.Tb_Empleados
SET dbo.Tb_Empleados.Fec_Actualizacion = GETDATE()
FROM inserted
WHERE inserted.IdEmpleado = dbo.Tb_Empleados.IdEmpleado
END
go
------PROBAMOS
UPDATE dbo.Tb_Empleados
SET NomEmpleado = 'JUAN',
    ApeEmpleado = 'PEREZ'
WHERE IdEmpleado = 1
--MOSTRAMOS LOS DATOS Y VERIFICAMOS LA COLUMNA FEC_ACTUALIZACION
SELECT * FROM TB_EMPLEADOS WHERE IDEMPLEADO = 1
GO
--AHORA ACTUALIZAMOS LA FEC_ACTUALIZACION
UPDATE dbo.Tb_Empleados
SET FEC_ACTUALIZACION = '01/01/01'
WHERE IdEmpleado = 2
GO
--MOSTRAMOS LOS DATOS Y VERIFICAMOS LA COLUMNA FEC_ACTUALIZACION
SELECT * FROM TB_EMPLEADOS WHERE IDEMPLEADO = 2
GO

CREATE TRIGGER Tb_Empleado_TgE 
ON Tb_Empleados
INSTEAD OF DELETE 
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @DeleteCount int
	SELECT @DeleteCount = COUNT(*) 
	FROM deleted
IF @DeleteCount > 0
BEGIN
	RAISERROR('Los empleados no pueden ser eliminados....', 10, 1)
END
END
GO
--PROBAMOS
--VAMOS A VISUALIZAR AL EMPLEADO E01 
SELECT * FROM TB_EMPLEADOS WHERE IDEMPLEADO = 1
GO
--AHORA ELIMINAMOS EL EMPLEADO E01
DELETE FROM TB_EMPLEADOS WHERE IDEMPLEADO = 1
GO
--AHORA MOSTRAMOS AL EMPEADO E01
SELECT * FROM TB_EMPLEADOS WHERE IDEMPLEADO = 1
GO

/*
3.	Crear un trigger en la cual cuando se inserte un detalle 
de un pedido me permita actualizar la columna UnidadesEnExistencia 
de la tabla Tb_Productos en la cual debe de controlar que haya stock 
y disminuira la cantidad en UnidadesEnExistencia en caso que no haya 
UnidadesEnExistencia me muestre un mensaje de error.
*/

CREATE TRIGGER Tb_PedidosDeta_TgI 
ON Tb_PedidosDeta
AFTER INSERT 
AS
BEGIN
SET NOCOUNT ON;
DECLARE @CANTIDAD SMALLINT
DECLARE @STOCK SMALLINT
SET @CANTIDAD = (SELECT CANTIDAD
                 FROM INSERTED)
SET @STOCK = (SELECT UnidadesEnExistencia FROM TB_PRODUCTOS
				JOIN INSERTED
				on INSERTED.IDPRODUCTO=TB_PRODUCTOS.IDPRODUCTO)
				
IF (@STOCK >= @CANTIDAD)
	UPDATE TB_PRODUCTOS 
	SET UnidadesEnExistencia = UnidadesEnExistencia - @CANTIDAD
	FROM TB_PRODUCTOS
	JOIN INSERTED
	ON INSERTED.IDPRODUCTO = TB_PRODUCTOS.IDPRODUCTO
	WHERE TB_PRODUCTOS.IDPRODUCTO =  INSERTED.IDPRODUCTO
ELSE
BEGIN
	RAISERROR ('HAY MENOS PRODUCTOS EN STOCK DE LO SOLICITADO EN EL PEDIDO', 10, 1)
	rollback transaction
END
END
GO
--PROBAMOS
--AHORA MOSTRAMOS LA EXISTENCIA EN STOCK DEL PRODUCTO 2 EN LA CUAL NOS MUESTRA 17
SELECT * FROM TB_PRODUCTOS WHERE IDPRODUCTO = 2 
GO
--INSERTAMOS UN PEDIDOSDETA
INSERT INTO dbo.tb_pedidosdeta(IDPEDIDO, IDPRODUCTO, PRECIOUNIDAD, CANTIDAD, DESCUENTO)
VALUES(10248,2,5,2,0)
GO
--AHORA VERIFICAMOS EL STOCK Y AHORA NOS MUESTRA 15 EN LA CUAL EL TRIGGER ACTUALIZO EL STOCK
SELECT * FROM TB_PRODUCTOS WHERE IDPRODUCTO = 2 
GO
--AHORA INSERTAMOS OTRO PEDIDO EN LA CUAL LA CANTIDAD VA A SUPERAR AL STOCK
INSERT INTO dbo.tb_pedidosdeta(IDPEDIDO, IDPRODUCTO, PRECIOUNIDAD, CANTIDAD, DESCUENTO)
VALUES(10249,2,5,20,0)
GO
--AHORA VERIFICAMOS EL STOCK Y NOS MUESTRA 15 EN LA CUAL EL TRIGGER CANCELO LA ACTUALIZACION EL STOCK
SELECT * FROM TB_PRODUCTOS WHERE IDPRODUCTO = 2 
GO
