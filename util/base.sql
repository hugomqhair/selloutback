CREATE DATABASE sellout;

--Usuario
--DROP TABLE promoter;
CREATE TABLE promoter (
  id serial PRIMARY KEY,
  nome varchar(50) NOT NULL UNIQUE,
  senha varchar(50),
  idger integer,
  gestor boolean,
  dtcad timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dtlog timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP -- ON UPDATE CURRENT_TIMESTAMP
);
--ALTER TABLE promoter ADD COLUMN gestor boolean;
--ALTER TABLE promoter DROP COLUMN gestor;
--ALTER TABLE promoter ADD COLUMN senha VARCHAR(30);
--ALTER TABLE promoter ADD COLUMN idger integer;
INSERT INTO promoter (nome,senha) VALUES ('HUGO', '123');
INSERT INTO promoter (nome,senha) VALUES ('VAGNER', '123');

---Lojas
--DROP TABLE loja
CREATE TABLE loja (
    id INTEGER NOT NULL,
    nome varchar(50) NOT NULL,
    idpromoter INTEGER REFERENCES promoter (id),
    dtcad timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dtlog timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, -- ON UPDATE CURRENT_TIMESTAMP
    PRIMARY KEY (id)
);
INSERT INTO loja (id, nome, idpromoter) VALUES (1,'SUMIRE',1);
INSERT INTO loja (id, nome, idpromoter) VALUES (2,'GOYA',2);
INSERT INTO loja (id, nome, idpromoter) VALUES (3,'IKESAKI',1);
INSERT INTO loja (id, nome, idpromoter) VALUES (4,'LOJAS REDE',1);
INSERT INTO loja (id, nome, idpromoter) VALUES (5,'LOJAS DANNY COSMETICOS - BARRA FUNDA',2);

--Produtos
--DROP TABLE produto;
CREATE TABLE produto (
    id serial PRIMARY KEY,
    descrprod varchar(100) NOT NULL,
    grupo VARCHAR(20),
    dtcad timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dtlog timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP -- ON UPDATE CURRENT_TIMESTAMP
);
--ALTER TABLE produto ADD COLUMN grupo VARCHAR(20);
INSERT INTO produto (descrprod,grupo) VALUES ('PRANCHA PRO 480','PRANCHA');
INSERT INTO produto (descrprod,grupo) VALUES ('SECADOR MILLANO', 'SECADOR');
INSERT INTO produto (descrprod,grupo) VALUES ('MAQ DE CORTE', 'MAQUINA DE CORTE');
INSERT INTO produto (descrprod,grupo) VALUES ('ESCOVAS DES BEAUTY', 'ESCOVAS');
INSERT INTO produto (descrprod,grupo) VALUES ('ESC ROSA BEAUTY','ESCOVAS');
INSERT INTO produto (descrprod,grupo) VALUES ('PRANCHA 480 SLIM', 'PRANCHA');
INSERT INTO produto (descrprod,grupo) VALUES ('SECADOR VORTEX TURBO MAX 2400W', 'SECADOR');
INSERT INTO produto (descrprod,grupo) VALUES ('SECADOR VORTEX TURBO MAX BLACK 2400W', 'SECADOR');
INSERT INTO produto (descrprod,grupo) VALUES ('ESC AMARELA ROSA BEAUTY','ESCOVAS');
INSERT INTO produto (descrprod,grupo) VALUES ('ESC VERMELHA BEAUTY','ESCOVAS');
INSERT INTO produto (descrprod,grupo) VALUES ('ESC BLACK BEAUTY','ESCOVAS');
INSERT INTO produto (descrprod,grupo) VALUES ('MAQUINA DE CORTE FORCER BARBER', 'MAQUINA DE CORTE');
INSERT INTO produto (descrprod,grupo) VALUES ('MAQUINA DE CORTE FORCER FADE', 'MAQUINA DE CORTE');
INSERT INTO produto (descrprod,grupo) VALUES ('MAQUINA DE CORTE FORCER METAL', 'MAQUINA DE CORTE');
INSERT INTO produto (descrprod,grupo) VALUES ('SECADOR VORTEX TURBO MAX ROSA 2400W LINHA ESPECIAL', 'SECADOR');

DROP TABLE produtolojaestoque;
CREATE TABLE produtolojaestoque (
    idproduto INTEGER NOT NULL REFERENCES produto (id),
    idloja INTEGER NOT NULL REFERENCES loja (id),
    estoque INTEGER,
    dtlog timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    semcadastro boolean DEFAULT FALSE,
    semestoque boolean DEFAULT FALSE,
    PRIMARY KEY (idloja, idproduto)
  );


---SELLOUT
--DROP TABLE sellout;
CREATE TABLE sellout (
  id serial PRIMARY KEY,
  idpromoter integer NOT NULL, 
  idloja integer NOT NULL, 
  dtmov date NOT NULL,
  qtdneg INTEGER,
  dtlog timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (idloja) REFERENCES loja (id),
  FOREIGN KEY (idpromoter) REFERENCES promoter (id),
  UNIQUE (idloja, idpromoter, dtmov)
);
--Versão OLD
-- CREATE TABLE sellout (
--   id serial PRIMARY KEY,
--   idpromoter integer NOT NULL, 
--   idloja integer NOT NULL, 
--   dtmov date NOT NULL,
--   qtdneg INTEGER,
--   dtlog timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
--   FOREIGN KEY (idloja, idpromoter) REFERENCES loja (id, idpromoter),
--   UNIQUE (idloja, idpromoter, dtmov)
-- );
  --UNIQUE (idpromoter, idloja, dtmov)

  
--ALTER TABLE SELLOUT ADD COLUMN QTDNEG INTEGER;
-- INSERT INTO sellout (idpromoter, idloja, dtmov) VALUES (1,2,'2023-02-08');
-- INSERT INTO sellout (idpromoter, idloja, dtmov) VALUES (1,3,'2023-07-22');
-- INSERT INTO sellout (idpromoter, idloja, dtmov) VALUES (1,3,'2023-07-25');

--SELLOUTITEM
--DROP TABLE SELLOUTITEM;
CREATE TABLE selloutitem (
  idsellout integer REFERENCES sellout (id),
  idproduto integer REFERENCES produto (id),
  qtdneg integer NOT NULL,
  dtlog timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  semcadastro boolean DEFAULT FALSE,
  semestoque boolean DEFAULT FALSE,
  PRIMARY KEY (idsellout, idproduto)
);

CREATE TABLE objetivopromoter (
  ano integer NOT NULL,
  mes integer NOT NULL,
  idpromoter INTEGER NOT NULL REFERENCES promoter (id),
  quant integer NOT NULL,
  dtref DATE,
  dtlog timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ano, mes, idpromoter)
);

DROP TABLE SELLOUTITEM;
DROP TABLE sellout;
DROP TABLE produto;
DROP TABLE loja;

--- TRIGGER ---
CREATE OR REPLACE FUNCTION stpr_atualiza_qdtneg()
RETURNS TRIGGER
LANGUAGE 'plpgsql' VOLATILE COST 100
AS $BODY$
DECLARE
  p_idloja INTEGER;
BEGIN
	UPDATE sellout SET qtdneg=(SELECT sum(qtdneg) FROM selloutitem WHERE idsellout=NEW.idsellout) where id=new.idsellout;
  
  SELECT idloja INTO p_idloja FROM sellout WHERE id=NEW.idsellout;
  INSERT INTO produtolojaestoque (idproduto, idloja, dtlog,semestoque, semcadastro) VALUES (NEW.idproduto, p_idloja, CURRENT_TIMESTAMP,NEW.semestoque, NEW.semcadastro)
          ON CONFLICT (idproduto, idloja)
          DO UPDATE SET dtlog=CURRENT_TIMESTAMP, semestoque=NEW.semestoque, semcadastro=NEW.semcadastro;

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
  POS INT;
  DESCGRUPO VARCHAR(100);
BEGIN
	SELECT TRIM(REPLACE(descrprod,grupo,'')) as descr, position(' ' IN descrprod) as pos, grupo INTO descr, pos, descgrupo FROM produto WHERE id=idproduto;
  IF (SUBSTR(descr,1,pos) = SUBSTR(descgrupo,1, pos)) THEN
    descr := TRIM(SUBSTR(descr,pos));
  END IF;
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

--Resultado Mes
SELECT TO_CHAR(dtmov,'MM/YYYY') AS fmt_mes
    ,idpromoter
    ,count(id) as dias
    ,SUM(qtdneg) AS qtdneg
FROM sellout 
GROUP BY TO_CHAR(dtmov,'MM/YYYY'), idpromoter
ORDER BY TO_CHAR(dtmov,'MM/YYYY');

--Resultado Supervisor
SELECT 
  (SELECT nome FROM promoter WHERE id=idpromoter) as promoter
  ,SUM(qtdneg) AS qtdneg
  ,COUNT(dtmov) AS dias
FROM sellout
WHERE dtmov BETWEEN  date_trunc('month', current_date) AND (date_trunc('month', current_date) + interval '1 month - 1 day')
GROUP BY idpromoter
ORDER BY 2;

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


-- INSERT INTO selloutitem (idsellout,idproduto,qtdneg) VALUES(1,3,8);
-- INSERT INTO selloutitem (idsellout,idproduto,qtdneg) VALUES(2,5,2);
-- INSERT INTO selloutitem (idsellout,idproduto,qtdneg) VALUES(2,2,31);