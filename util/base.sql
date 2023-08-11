CREATE DATABASE sellout;

--Usuario
--DROP TABLE promoter;
CREATE TABLE promoter (
  id serial PRIMARY KEY,
  nome varchar(50) NOT NULL UNIQUE,
  senha varchar(50),
  idger integer,
  dtcad timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dtlog timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP -- ON UPDATE CURRENT_TIMESTAMP
);
--ALTER TABLE promoter ADD COLUMN senha VARCHAR(30);
--ALTER TABLE promoter ADD COLUMN idger integer;
INSERT INTO promoter (nome,senha) VALUES ('HUGO', '123');
INSERT INTO promoter (nome,senha) VALUES ('VAGNER', '123');

---Lojas
--DROP TABLE loja
CREATE TABLE loja (
    id serial PRIMARY KEY,
    nome varchar(50) NOT NULL UNIQUE,
    dtcad timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dtlog timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP -- ON UPDATE CURRENT_TIMESTAMP
);
INSERT INTO loja (nome) VALUES ('SUMIRE');
INSERT INTO loja (nome) VALUES ('GOYA');
INSERT INTO loja (nome) VALUES ('IKESAKI');
INSERT INTO loja (nome) VALUES ('LOJAS REDE');

--Produtos
DROP TABLE produto;
CREATE TABLE produto (
    id serial PRIMARY KEY,
    descrprod varchar(100) NOT NULL,
    grupo VARCHAR(20),
    dtcad timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dtlog timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, -- ON UPDATE CURRENT_TIMESTAMP
    qtdneg integer NOT NULL DEFAULT 0
);
--ALTER TABLE produto ADD COLUMN grupo VARCHAR(20);
INSERT INTO produto (descrprod) VALUES ('PRANCHA PRO 480');
INSERT INTO produto (descrprod) VALUES ('SECADOR MILLANO');
INSERT INTO produto (descrprod) VALUES ('MAQ DE CORTE');
INSERT INTO produto (descrprod) VALUES ('ESC DES BEAUTY');
INSERT INTO produto (descrprod) VALUES ('ESC ROSA BEAUTY');
INSERT INTO produto (descrprod) VALUES ('PRANCHA 480 SLIM');
INSERT INTO produto (descrprod) VALUES ('SECADOR VORTEX 2400W');


---SELLOUT
--DROP TABLE sellout;
CREATE TABLE sellout (
  id serial PRIMARY KEY,
  idpromoter integer REFERENCES promoter (id),
  idloja integer REFERENCES loja (id),
  dtmov date NOT NULL,
  qtdneg INTEGER,
  dtlog timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (idpromoter, idloja, dtmov)
);
--ALTER TABLE SELLOUT ADD COLUMN QTDNEG INTEGER;
INSERT INTO sellout (idpromoter, idloja, dtmov) VALUES (1,2,'2023-02-08');
INSERT INTO sellout (idpromoter, idloja, dtmov) VALUES (1,3,'2023-07-22');
INSERT INTO sellout (idpromoter, idloja, dtmov) VALUES (1,3,'2023-07-25');

--SELLOUTITEM
--DROP TABLE SELLOUTITEM;
CREATE TABLE selloutitem (
  idsellout integer REFERENCES sellout (id),
  idproduto integer REFERENCES produto (id),
  qtdneg integer NOT NULL,
  dtlog timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (idsellout, idproduto)
);

INSERT INTO selloutitem (idsellout,idproduto,qtdneg) VALUES(1,3,8);
INSERT INTO selloutitem (idsellout,idproduto,qtdneg) VALUES(2,5,2);
INSERT INTO selloutitem (idsellout,idproduto,qtdneg) VALUES(2,2,31);

--- TRIGGER ---
CREATE OR REPLACE FUNCTION stpr_atualiza_qdtneg()
RETURNS TRIGGER
LANGUAGE 'plpgsql' VOLATILE COST 100
AS $BODY$
BEGIN
	UPDATE sellout SET qtdneg=(SELECT sum(qtdneg) FROM selloutitem WHERE idsellout=NEW.idsellout) where id=new.idsellout;
	RETURN NULL;
END;
$BODY$;

--DROP TRIGGER trg_atualiza_qdtneg ON SELLOUTITEM;
CREATE TRIGGER trg_atualiza_qdtneg
AFTER INSERT OR UPDATE ON selloutitem
FOR EACH ROW
EXECUTE FUNCTION stpr_atualiza_qdtneg();


--FUNCTION
CREATE OR REPLACE FUNCTION fnc_limpa_descrprod(idproduto INTEGER)
RETURNS VARCHAR
LANGUAGE 'plpgsql' VOLATILE COST 100
AS $BODY$
DECLARE
	DESCR VARCHAR(100);
BEGIN
	SELECT TRIM(REPLACE(descrprod,grupo,'')) INTO descr FROM produto WHERE id=idproduto;
	RETURN descr;
END;
$BODY$;





--SELECT INICIO SELLOUT
SELECT sell.dtmov
    ,loja.nome as loja
    ,pro.nome as vend 
FROM sellout as sell 
LEFT JOIN promoter pro ON (pro.id = sell.idpromoter) 
LEFT JOIN loja ON (sell.idloja = loja.id)
WHERE pro.id=1;


--SELECT LOAD SELLOUT ITEM
SELECT 
  pro.id as idproduto
  ,pro.descrprod as produto
  ,COALESCE(sell.qtdneg,0) as qtdneg
FROM produto AS pro LEFT JOIN selloutitem  AS sell ON (sell.idproduto=pro.id)
WHERE  sell.idsellout IS NULL OR sell.idsellout=1;




SELECT 
  pro.id as idproduto
  ,pro.descrprod as descrprod
  ,COALESCE((SELECT qtdneg FROM selloutitem WHERE idproduto=pro.id AND idsellout=1),0) as qtdneg
FROM produto AS pro ;


--INSERT OR UPDATE 
INSERT INTO selloutitem (idsellout, idproduto, qtdneg)
VALUES (1,1,8)
ON CONFLICT (idsellout, idproduto)
DO UPDATE SET qtdneg = 8;

[
 {id:1, nome:'PRANCHA', qtdneg:0},
 { id:2, nome:'SECADOR', qtdneg:0},
 {id:3, nome:'MAQ CORTE', qtdneg:0},
 {id:4, nome:'ESC 001.01', qtdneg:0},
 {id:5, nome:'ESC 002.01', qtdneg:0},
 {id:6, nome:'MODELADOR CURLING', qtdneg:0},
 {id:7, nome:'PRANCHA SLIM', qtdneg:0}, 
]
 {id:1, nome:'PRANCHA', qtdneg:0},
 { id:2, nome:'SECADOR', qtdneg:0},
 {id:3, nome:'MAQ CORTE', qtdneg:0},
 {id:4, nome:'ESC 001.01', qtdneg:0},
 {id:5, nome:'ESC 002.01', qtdneg:0},
 {id:6, nome:'MODELADOR CURLING', qtdneg:0},
 {id:7, nome:'PRANCHA SLIM', qtdneg:0},
-- Cria uma função que será executada pelo trigger

CREATE OR REPLACE FUNCTION somaDia()
RETURNS TRIGGER AS $$
BEGIN
    -- Coloque aqui as ações que você deseja executar quando o gatilho for acionado
    -- Por exemplo, você pode realizar ações antes ou depois de uma operação na tabela
    -- NEW é uma referência ao novo registro (caso de inserção/atualização)
    -- OLD é uma referência ao registro original (caso de atualização/exclusão)
    
    -- Exemplo: Atualizar um campo de data de modificação
    NEW.data_modificacao := NOW();
    
    RETURN NEW; -- Deve retornar o registro modificado ou novo
END;
$$ LANGUAGE plpgsql;

-- Cria o gatilho que chama a função quando ocorre um evento na tabela
CREATE TRIGGER exemplo_trigger
BEFORE INSERT OR UPDATE ON nome_da_tabela
FOR EACH ROW
EXECUTE FUNCTION exemplo_trigger_function();
