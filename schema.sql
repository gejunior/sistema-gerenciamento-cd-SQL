create schema cdnovo;
set search_path to cdnovo;

CREATE TABLE Gravadora (
       codgrav              SMALLINT    NOT NULL,
       nomegrav             VARCHAR(60) NULL,
       ender                VARCHAR(60) NULL,
       telefone             VARCHAR(20) NULL,
       contato              VARCHAR(20) NULL,
       url                  VARCHAR(80) NULL,
       PRIMARY KEY (codgrav)
);

CREATE TABLE CD (
       codcd                INTEGER       NOT NULL,
       codgrav              SMALLINT      NULL,
       nomecd               VARCHAR(60)   NULL,
       preco                DECIMAL(14,2) NULL,
       datalanc             DATE          NULL,
       indica               INTEGER       NULL,
       PRIMARY KEY (codcd),
       FOREIGN KEY (codgrav) REFERENCES Gravadora(codgrav),
       FOREIGN KEY (indica)  REFERENCES CD(codcd)
);

CREATE TABLE Musica (
       codmus               INTEGER      NOT NULL,
       nomemus              VARCHAR(60)  NULL,
       duracao              DECIMAL(6,2) NULL,
       PRIMARY KEY (codmus)
);

CREATE TABLE Autor (
       codaut            INTEGER     NOT NULL,
       nomeaut           VARCHAR(60) NULL,
       PRIMARY KEY (codaut)
);

CREATE TABLE MusicaAutor (
       codmus           INTEGER NOT NULL,
       codaut           INTEGER NOT NULL,
       PRIMARY KEY (codmus, codaut),
       FOREIGN KEY (codaut) REFERENCES Autor (codaut),
       FOREIGN KEY (codmus) REFERENCES Musica(codmus)
);

CREATE TABLE Faixa (
       codmus           INTEGER  NOT NULL,
       codcd            INTEGER  NOT NULL,
       num              SMALLINT NULL,
       PRIMARY KEY (codmus, codcd),
       FOREIGN KEY (codcd)  REFERENCES CD(codcd),
       FOREIGN KEY (codmus) REFERENCES Musica(codmus)
);

CREATE TABLE CDCategoria(
       codcat       SMALLINT      NOT NULL,
       menor        DECIMAL(14,2) NOT NULL,
       maior        DECIMAL(14,2) NOT NULL
);

-- 1 inserir novo
create table cliente (
    codcli int primary key,
    nome varchar(60),
    endereco varchar(50),
    cidade varchar(50),
    uf varchar(2),
    cep varchar(9)
);

create table venda (
    idvenda int primary key,
    datavenda date,
    codcli int,
    Parcelas int,
    foreign key (codcli) references cliente (codcli)
);

create table itemvenda(
    idvenda integer NOT NULL,
    codcd   integer NOT NULL,
    qtde    integer,
    PRIMARY KEY (idvenda, codcd),
    FOREIGN KEY (codcd) REFERENCES cd (codcd),
    FOREIGN KEY (idvenda) REFERENCES venda (idvenda)
);


