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
    descrprod varchar(50) NOT NULL,
    dtcad timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dtlog timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, -- ON UPDATE CURRENT_TIMESTAMP
    qtdneg integer NOT NULL DEFAULT 0
);
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
  dtlog timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (idpromoter, idloja, dtmov)
);

INSERT INTO sellout (idpromoter, idloja, dtmov) VALUES (1,2,'2023-02-08');
INSERT INTO sellout (idpromoter, idloja, dtmov) VALUES (1,3,'2023-07-22');
INSERT INTO sellout (idpromoter, idloja, dtmov) VALUES (1,3,'2023-07-25');

--SELLOUTITEM
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