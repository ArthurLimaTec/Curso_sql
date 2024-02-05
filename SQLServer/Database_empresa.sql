USE EMPRESA
GO

CREATE TRIGGER TRG_ATUALIZA_PRECO
ON DBO.PRODUTOS
FOR UPDATE
AS 

	DECLARE @IDPRODUTO INT
	DECLARE @PRODUTO VARCHAR(30)
	DECLARE @CATEGORIA VARCHAR(10)
	DECLARE @PREÇO NUMERIC(10,2)
	DECLARE @PREÇO_NOVO NUMERIC(10,2)
	DECLARE @DATA DATETIME
	DECLARE @USUARIO VARCHAR(30)
	DECLARE @ACAO VARCHAR(100)

	SELECT @IDPRODUTO = IDPRODUTO FROM INSERTED
	SELECT @PRODUTO = NOME FROM INSERTED
	SELECT @CATEGORIA = CATEGORIA FROM INSERTED
	SELECT @PREÇO = PREÇO FROM DELETED
	SELECT @PREÇO_NOVO = PREÇO FROM INSERTED

	SET @DATA = GETDATE()
	SET @USUARIO = SUSER_NAME()
	SET @ACAO = 'VALOR INSERIDO PELA TRIGGER TRG_ATUALIZA_PRECO'

	INSERT INTO HISTORICO (PRODUTO,CATEGORIA,PREÇO_ANTIGO,PREÇO_NOVO,DATA,USUARIO,MENSAGEM) VALUES
	(@PRODUTO,@CATEGORIA,@PREÇO,@PREÇO_NOVO,@DATA,@USUARIO,@ACAO)

	PRINT 'TRIGGER EXECUTADA COM SUCESSO'

GO 

UPDATE PRODUTOS SET PREÇO = 100.00 
WHERE IDPRODUTO = 1 
GO 

SELECT * FROM PRODUTOS
SELECT * FROM HISTORICO
GO

UPDATE PRODUTOS SET NOME = 'LIVRO C#'
WHERE IDPRODUTO = 1
GO

DROP TRIGGER TRG_ATUALIZA_PRECO
GO 

CREATE TRIGGER TRG_ATUALIZA_PRECO
ON DBO.PRODUTOS
FOR UPDATE AS
IF UPDATE(PREÇO)
BEGIN 

	DECLARE @IDPRODUTO INT
	DECLARE @PRODUTO VARCHAR(30)
	DECLARE @CATEGORIA VARCHAR(10)
	DECLARE @PREÇO NUMERIC(10,2)
	DECLARE @PREÇO_NOVO NUMERIC(10,2)
	DECLARE @DATA DATETIME
	DECLARE @USUARIO VARCHAR(30)
	DECLARE @ACAO VARCHAR(100)

	SELECT @IDPRODUTO = IDPRODUTO FROM INSERTED
	SELECT @PRODUTO = NOME FROM INSERTED
	SELECT @CATEGORIA = CATEGORIA FROM INSERTED
	SELECT @PREÇO = PREÇO FROM DELETED
	SELECT @PREÇO_NOVO = PREÇO FROM INSERTED

	SET @DATA = GETDATE()
	SET @USUARIO = SUSER_NAME()
	SET @ACAO = 'VALOR INSERIDO PELA TRIGGER TRG_ATUALIZA_PRECO'

	INSERT INTO HISTORICO (PRODUTO,CATEGORIA,PREÇO_ANTIGO,PREÇO_NOVO,DATA,USUARIO,MENSAGEM) VALUES
	(@PRODUTO,@CATEGORIA,@PREÇO,@PREÇO_NOVO,@DATA,@USUARIO,@ACAO)

	PRINT 'TRIGGER EXECUTADA COM SUCESSO'
END
GO 

UPDATE PRODUTOS SET PREÇO = 300.00
WHERE IDPRODUTO = 2
GO

SELECT * FROM PRODUTOS
SELECT * FROM HISTORICO

UPDATE PRODUTOS SET NOME = 'LIVRO JAVA'
WHERE IDPRODUTO = 2
GO 

SELECT * FROM PRODUTOS
SELECT * FROM HISTORICO

SELECT 10+10
GO 

CREATE TABLE RESULTADO(
	IDRESULTADO INT PRIMARY KEY IDENTITY,
	RESULTADO INT
	)
GO 

INSERT INTO RESULTADO VALUES((SELECT 10+10))
GO 

SELECT * FROM RESULTADO
GO 



/*ATRIBUINDO SELECTS A VARIAVEIS - ANONIMO*/

DECLARE 
	@RESULTADO INT 
	SET @RESULTADO = (SELECT 50+50)
	INSERT INTO RESULTADO VALUES (@RESULTADO)
	PRINT 'VALOR INSERIDO NA TABELA: ' + CAST(@RESULTADO AS VARCHAR)
GO 

CREATE TABLE EMPREGADO(
	IDEMP INT PRIMARY KEY,
	NOME VARCHAR(30),
	SALARIO MONEY,
	IDGERENTE INT
	)
GO

ALTER TABLE EMPREGADO ADD CONSTRAINT FK_GERENTE
FOREIGN KEY(IDGERENTE) REFERENCES EMPREGADO(IDEMP)
GO 

INSERT INTO EMPREGADO VALUES(1,'CLARA',5000.00,NULL)
INSERT INTO EMPREGADO VALUES(2,'CELIA',4000.00,1)
INSERT INTO EMPREGADO VALUES(3,'JOAO',4000.00,1)
GO

CREATE TABLE HIST_SALARIO(
	IDEMPREGADO INT,
	ANTIGOSAL MONEY,
	NOVOSAL MONEY,
	DATA DATETIME
	)
GO 

CREATE TRIGGER TRG_SALARIO
ON DBO.EMPREGADO
FOR UPDATE AS 
IF UPDATE(SALARIO)
BEGIN 

	INSERT INTO HIST_SALARIO(IDEMPREGADO,ANTIGOSAL,NOVOSAL,DATA)
	SELECT D.IDEMP,D.SALARIO,I.SALARIO,GETDATE()
	FROM DELETED D, INSERTED I  
	WHERE D.IDEMP = I.IDEMP

END
GO 

UPDATE EMPREGADO SET SALARIO = SALARIO * 1.1
GO

SELECT * FROM EMPREGADO 
GO

SELECT * FROM HIST_SALARIO
GO

SELECT E.NOME,H.ANTIGOSAL,H.NOVOSAL,H.DATA
FROM EMPREGADO E,HIST_SALARIO H
GO

CREATE TABLE SALARIO_RANGE(
	MINSAL MONEY,
	MAXSAL MONEY
	)
GO 

INSERT INTO SALARIO_RANGE VALUES(2000,6000)
GO

CREATE TRIGGER TRG_RANGE
ON DBO.EMPREGADO
FOR INSERT,UPDATE
AS 

	DECLARE
	@MINSAL MONEY,
	@MAXSAL MONEY,
	@ATUALSAL MONEY

	SELECT @MINSAL = MINSAL, @MAXSAL = MAXSAL FROM SALARIO_RANGE

	SELECT @ATUALSAL = I.SALARIO
	FROM INSERTED I 

	IF(@ATUALSAL < @MINSAL)
	BEGIN

		RAISERROR('SALARIO MENOR QUE O PISO',16,1)
		ROLLBACK TRANSACTION
	END 

	IF(@ATUALSAL > @MAXSAL)
	BEGIN

		RAISERROR('SALARIO MAIOR QUE O TETO',16,1)
		ROLLBACK TRANSACTION

	END
GO 

UPDATE EMPREGADO SET SALARIO = 9000.00
WHERE IDEMP = 1
GO 

UPDATE EMPREGADO SET SALARIO = 1000.00
WHERE IDEMP = 1
GO 

SP_HELPTEXT TRG_RANGE
GO 

SP_STORAGE POCEDURE


CREATE TABLE PESSOA(
	IDPESSOA INT PRIMARY KEY IDENTITY,
	NOME VARCHAR(30) NOT NULL,
	SEXO CHAR(1) NOT NULL CHECK(SEXO IN('M','F')),
	NASCIMENTO DATE NOT NULL
	)
GO 

CREATE TABLE TELEFONE(
	IDTELEFONE INT NOT NULL IDENTITY,
	TIPO CHAR(3) NOT NULL CHECK(TIPO IN('CEL','COM')),
	NUMERO CHAR(30) NOT NULL,
	ID_PESSOA INT  
	)
GO 

ALTER TABLE TELEFONE ADD CONSTRAINT FK_TELEFONE_PESSOA
FOREIGN KEY(ID_PESSOA) REFERENCES PESSOA(IDPESSOA)
ON DELETE CASCADE
GO 

INSERT INTO PESSOA VALUES('ANTONIO','M','1981-02-13')
INSERT INTO PESSOA VALUES('DANIEL','M','1985-03-18')
INSERT INTO PESSOA VALUES('CLEIDE','F','1979-10-13')
INSERT INTO PESSOA VALUES('MAFRA','M','1981-02-13')

SELECT @@IDENTITY -- GUARDA O ULTIMO IDENTITY INSERIDO NA SEÇÃO
GO

SELECT * FROM PESSOA

INSERT INTO TELEFONE VALUES('CEL','9879008',1)
INSERT INTO TELEFONE VALUES('COM','8757909',1)
INSERT INTO TELEFONE VALUES('CEL','9875890',2)
INSERT INTO TELEFONE VALUES('CEL','9347689',2)
INSERT INTO TELEFONE VALUES('COM','2998689',3)
INSERT INTO TELEFONE VALUES('COM','2098978',2)
INSERT INTO TELEFONE VALUES('CEL','9008679',3)
GO

SELECT * FROM TELEFONE

CREATE PROC SOMA
AS 
	SELECT 10+10 AS SOMA

GO 

EXEC SOMA

CREATE PROC CONTA @NUM1 INT,@NUM2 INT 
AS 
	SELECT @NUM1 + @NUM2
GO 

EXEC CONTA 90, 78
GO 

DROP PROC CONTA 
GO 

SELECT P.NOME,T.NUMERO
FROM PESSOA P
INNER JOIN TELEFONE T
ON IDPESSOA = ID_PESSOA
WHERE TIPO = 'CEL'
GO 

CREATE PROC TELEFONES @TIPO CHAR(3)
AS 
	SELECT P.NOME,T.NUMERO
	FROM PESSOA P
	INNER JOIN TELEFONE T
	ON IDPESSOA = ID_PESSOA
	WHERE TIPO = @TIPO
GO 

EXEC TELEFONES 'CEL'
GO

EXEC TELEFONES 'COM'
GO

SELECT TIPO,COUNT(*) AS QUANTIDADE
FROM TELEFONE
GROUP BY TIPO 
GO 

CREATE PROCEDURE GETTIPO @TIPO CHAR(3), @CONTADOR INT OUTPUT
AS 
	SELECT @CONTADOR = COUNT(*)
	FROM TELEFONE
	WHERE TIPO = @TIPO 
GO


DECLARE @SAIDA INT
EXEC GETTIPO @TIPO = 'CEL', @CONTADOR = @SAIDA OUTPUT
SELECT @SAIDA
GO 

CREATE PROC CADASTRO @NOME VARCHAR(30),@SEXO CHAR(1),@NASCIMENTO DATE,@TIPO CHAR(3),
@NUMERO VARCHAR(10)
AS 
	DECLARE @FK INT 

	INSERT INTO PESSOA VALUES(@NOME,@SEXO,@NASCIMENTO)

	SET @FK = (SELECT IDPESSOA FROM PESSOA WHERE IDPESSOA = @@IDENTITY)

	INSERT INTO TELEFONE VALUES(@TIPO,@NUMERO,@FK)

GO 


CADASTRO 'JORGE','M','1981-01-01','CEL','984512545'
GO 

SELECT PESSOA.*, TELEFONE.* 
FROM PESSOA 
INNER JOIN TELEFONE  
ON IDPESSOA = ID_PESSOA
GO 

DECLARE 

	@CONTADOR INT 

BEGIN 

	SET @CONTADOR = 5
	PRINT @CONTADOR

END
GO 

DECLARE 

	@V_NUMERO NUMERIC(10,2) = 100.52,
	@V_DATA DATETIME = '20170207'

BEGIN 

	PRINT 'VALOR NUMÉRICO: ' + CAST (@V_NUMERO AS VARCHAR)
	PRINT 'VALOR NUMÉRICO: ' + CONVERT(VARCHAR, @V_NUMERO)
	PRINT 'VALOR DE DATA: ' + CAST(@V_DATA AS VARCHAR)
	PRINT 'VALOR DE DATA: ' + CONVERT (VARCHAR, @V_DATA,121)
	PRINT 'VALOR DE DATA: ' + CONVERT (VARCHAR, @V_DATA,120)
	PRINT 'VALOR DE DATA: ' + CONVERT (VARCHAR, @V_DATA,105)

END
GO 

CREATE TABLE CARROS(
	CARRO VARCHAR(20),
	FABRICANTE VARCHAR(30)
)
GO

INSERT INTO CARROS VALUES('KA','FORD')
INSERT INTO CARROS VALUES('FIESTA','FORD')
INSERT INTO CARROS VALUES('PRISMA','FORD')
INSERT INTO CARROS VALUES('CLIO','RENAULT')
INSERT INTO CARROS VALUES('SANDERO','RENAULT')
INSERT INTO CARROS VALUES('CHEVETE','CHEVROLET')
INSERT INTO CARROS VALUES('OMEGA','CHEVROLET')
INSERT INTO CARROS VALUES('PALIO','FIAT')
INSERT INTO CARROS VALUES('DOBLO','FIAT')
INSERT INTO CARROS VALUES('UNO','FIAT')
INSERT INTO CARROS VALUES('GOL','VOLKSWAGEN')
GO


DECLARE 
		@V_CONT_FORD INT,
		@V_CONT_FIAT INT
BEGIN
		--METODO 1 - O SELECT PRECISA RETORNAR UMA SIMPLES COLUNA
		--E UM SO RESULTADO
		SET @V_CONT_FORD = (SELECT COUNT(*) FROM CARROS
		WHERE FABRICANTE = 'FORD')
		
		PRINT 'QUANTIDADE FORD: ' + CAST(@V_CONT_FORD AS VARCHAR)

		--METODO 2
		SELECT @V_CONT_FIAT = COUNT(*) FROM CARROS WHERE FABRICANTE = 'FIAT'

		PRINT 'QUANTIDADE FIAT: ' + CONVERT(VARCHAR, @V_CONT_FIAT)

END
GO

DECLARE
	
	@NUMERO INT = 5

BEGIN 

	IF @NUMERO = 5
		PRINT 'VALOR É VERDADEIRO'

	ELSE
		PRINT 'VALOR É FALSO'
END
GO 

DECLARE
	
	@CONTADOR INT

BEGIN

	SELECT
	CASE
		WHEN FABRICANTE = 'FIAT' THEN 'FAIXA 1'
		WHEN FABRICANTE = 'CHEVROLET' THEN 'FAIXA 2'
		ELSE 'OUTRAS FAIXAS'
	END AS 'INFORMAÇÕES',
	*
	FROM CARROS

END
GO 

DECLARE

	@I INT = 1

BEGIN

	WHILE (@I < 15)
	BEGIN

		PRINT 'VALOR DE @I = ' + CAST(@I AS VARCHAR)
		SET @I = @I+1

	END

END 
GO