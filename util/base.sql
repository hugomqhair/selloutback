CREATE DATABASE sellout;

--Usuario
CREATE TABLE promoter (
  id serial PRIMARY KEY,
  descrprod varchar(50) NOT NULL,
  dtcad timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dtlog timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP -- ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO promoter (nome) VALUES ('JOANA');

---Lojas
CREATE TABLE loja (
    id serial PRIMARY KEY,
    nome varchar(50) NOT NULL,
    dtcad timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dtlog timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP -- ON UPDATE CURRENT_TIMESTAMP
);
INSERT INTO loja (nome) VALUES ('SUMIRE');
INSERT INTO loja (nome) VALUES ('GOYA');

--Produtos
CREATE TABLE produto (
    id serial PRIMARY KEY,
    descrprod varchar(50) NOT NULL,
    dtcad timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dtlog timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP -- ON UPDATE CURRENT_TIMESTAMP
    qtdneg integer NOT NULL DEFAULT 0,  
);
INSERT INTO produto (descrprod) VALUES ('PRANCHA PRO 480');
INSERT INTO produto (descrprod) VALUES ('SECADOR MILLANO');
INSERT INTO produto (descrprod) VALUES ('MAQ DE CORTE');
INSERT INTO produto (descrprod) VALUES ('ESC DESENB BEAUTY');

---SELLOUT
CREATE TABLE sellout (
  idpromoter integer REFERENCES promoter (id),
  idproduto integer REFERENCES produto (id),
  idloja integer REFERENCES loja (id),
  quantidade integer NOT NULL,
  dtmov date NOT NULL,
  dtlog timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (idpromoter, idproduto, idloja, dtmov)
);

INSERT INTO sellout (idpromoter, idproduto, idloja, quantidade, dtmov) VALUES (1,3,2,5,'2023-02-08');


