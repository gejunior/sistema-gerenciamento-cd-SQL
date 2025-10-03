set search_path to cdnovo;

-- 2
create or replace procedure insertClientes()
    language 'plpgsql' as
$$
begin

    FOR i IN 1..1000
        LOOP
            INSERT into cdnovo.cliente values (i, 'AAAAA', 'RUA SAO PAULO', 'PRESIDENTE PRUDENTE', 'SP', '19470-000');
        end loop;
end;
$$;

call insertClientes();
select * from cliente;

-- 3
CREATE OR REPLACE PROCEDURE insertVendas()
    LANGUAGE 'plpgsql' AS
$$
declare
    contador INT = 1;
    cliente  INT = 1;
begin

    FOR i IN 1..1000
        LOOP
            insert into cdnovo.venda values (i, current_date - contador, cliente, 0);
            cliente := cliente + 1;
            contador = contador + 1;
            if contador >= 100 then
                contador = 1;
            end if;
            if cliente >= 100 then
                cliente = 1;
            end if;
        END LOOP;
end;
$$;

call insertVendas();
select * from venda;

-- 5
alter table itemvenda add column preco numeric(10, 2);
update itemvenda it set preco = cd.preco from cd where it.codcd = cd.codcd;

select * from itemvenda;
select * from venda;

-- 6
alter table venda add column valortotal numeric(10, 2); -- adiciona a coluna valortotal na tabela venda
update venda v set valortotal = (select sum(it.qtde * it.preco) from itemvenda it where idvenda = v.idvenda);
select * from venda;

create or replace function atualizaVenda() returns trigger
    language 'plpgsql' as
$$
begin
    if (tg_op = 'INSERT') then
        update venda set valortotal = valortotal + (new.qtde * new.preco) where idvenda = new.idvenda;
        return new;
    end if;

    if (tg_op = 'UPDATE') then
        update venda
        set valortotal = valortotal - (old.qtde * old.preco) + (new.qtde * new.preco)
        where idvenda = new.idvenda;
        return new;
    end if;

    if (tg_op = 'DELETE') then
        update venda set valortotal = valortotal - (old.qtde * old.preco) where idvenda = old.idvenda;
        return old;
    end if;
end;
$$;

create or replace trigger tg_atualizaVenda
    before insert or update or delete
    on itemvenda
    for each row
execute procedure atualizaVenda();

select * from itemvenda where idvenda = 101;
select * from venda where idvenda = 101;
-- valortotal = 416,50


-- testeste da trigger 6
select * from itemvenda where idvenda = 101;
select * from venda;
update itemvenda set qtde = 6 where idvenda = 101 and codcd = 1;
delete from itemvenda where idvenda = 101 and codcd = 1;
select sum(it.qtde * it.preco) from itemvenda it where idvenda = 101; --270

insert into itemvenda values (101, 1, 7, 15);

-- 7
alter table cliente add column valorcomprado numeric(10, 2);
select * from cliente where codcli = 101;
select * from cliente;

select * from itemvenda;
select sum(valortotal) from venda where codcli = 101; -- 0
select * from venda;
update cliente c set valorcomprado = (select sum(v.valortotal) from venda v where v.codcli = c.codcli);

create or replace function atualizaCliente() returns trigger
    language 'plpgsql' as
$$
begin
    if (tg_op = 'INSERT') then
        update cliente set valorcomprado = valorcomprado + new.valortotal where codcli = new.codcli;
        return new;
    end if;

    if (tg_op = 'UPDATE') then
        update cliente set valorcomprado = valorcomprado - old.valortotal + new.valortotal where codcli = new.codcli;
        return new;
    end if;

    if (tg_op = 'DELETE') then
        update cliente set valorcomprado = valorcomprado - old.valortotal where codcli = old.codcli;
        return old;
    end if;
end;
$$;

create or replace trigger tg_atualizarCliente -- tg_alterarCliente
    before insert or update or delete
    on venda
    for each row
execute procedure atualizaCliente();

-- testes
insert into venda values (1001, '2024-09-13', 99, 0, 5); -- 1985 + 5 = 1990

select * from cliente where codcli = 99; -- 1985 + 5 = 1990

update venda set valortotal = 6 where idvenda = 1001; -- 1985 + 5 = 1991

delete from venda where idvenda = 1001; -- 1985

select * from venda where idvenda = 1001; select * from venda where codcli = 99;

-- 8
--Acrescentar o campo QTDEESTOQUE na tabela de CD
alter table cd add column qtdeEstoque int;
select * from cd;
--atualizar esse campo para 10000 para todos CDs
update cd set qtdeEstoque = 10000;


-- Atualize a QTDE para a posição atual do BANCO
update cd
set qtdeEstoque = qtdeEstoque - (select (sum(qtde)) from itemvenda it where cd.codcd = it.codcd);
select *
from itemvenda;
select *
from cd;
select
from itemvenda
where codcd = 1;


create or replace function atualizacd() returns trigger
    language 'plpgsql' as
$$
begin
    if (tg_op = 'INSERT') then
        update cd set qtdeEstoque = cd.qtdeEstoque - new.qtde where codcd = new.codcd;
        return new;
    end if;

    if (tg_op = 'UPDATE') then
        update cd set qtdeEstoque = cd.qtdeEstoque - new.qtde + old.qtde where codcd = new.codcd;
        return new;
    end if;

    if(tg_op = 'DELETE') then
        update cd set qtdeEstoque = cd.qtdeEstoque + old.qtde where codcd = old.codcd;
        return old;
    end if;
end;
$$;

create or replace trigger tg_atualizaCD
    before insert or update or delete
    on itemvenda
    for each row
execute procedure atualizaCD();

--teste
select * from itemvenda where codcd = 3;
select * from itemvenda where codcd = 3 and idvenda = 101;
select * from venda;

select * from cd where codcd = 3; -- 6371
insert into itemvenda values (101, 3, 10, 15); -- 6371 - 10 = 6361

update itemvenda set qtde = 5 where idvenda = 101 and codcd = 3; -- 6371 - 5 = 6366

delete from itemvenda where idvenda = 101; -- 6361 + 10 = 6371

-- 9
-- 9.1 - Acrescentar na tabela AUTOR o campo RENDA
alter table autor add column renda numeric(10,2);
select * from autor where renda >= 20;
select * from faixa;
select * from itemvenda;
select * from musica;
-- 9.2 - Para cada CD vendido o preco do CD deve ser dividido pela qtde de musica
-- esse valor deve ser multiplicado pela qtde de musica de um mesmo autor no cd
-- e esse valor adicionado a renda do autor

----------- pesquisas antes de chegar no resultado 1

select sum(cd.preco) / (select count(f.codmus) qtdeMusicas from cd, faixa f where f.codcd = cd.codcd group by cd.nomecd) from cd;
select cd.codcd, cd.nomecd, cd.preco from cd, faixa f where f.codcd = cd.codcd;

select codcd, nomecd from cd order by codcd;

select nomemus, nomecd, cd.preco from musica m
join faixa f on f.codmus = m.codmus
join cd on f.codcd = cd.codcd;

-- Atualização na coluna renda para todos os autores
with rendas as (
select a.codaut, (sum(cd.preco) / count(f.codmus) * count(f.codmus)) as renda from musica m
join faixa f on f.codmus = m.codmus
join cd on f.codcd = cd.codcd
join musicaautor ma on m.codmus = ma.codmus
join autor a on ma.codaut = a.codaut
group by a.codaut
)
update autor a set renda = r.renda from rendas r where a.codaut = r.codaut;

-- 9.3 - faça uma TRIGGER para isso.
create or replace function atualizaRenda () returns trigger
language 'plpgsql' as
$$
    declare
        rendas numeric(10,2);
    begin
        if(tg_op = 'INSERT') then
--             update autor set renda = renda + new.renda;

--             rendas := (select (sum(cd.preco) / count(f.codmus) * count(f.codmus)) from musica m
--             join faixa f on f.codmus = m.codmus
--             join cd on f.codcd = cd.codcd
--             join musicaautor ma on m.codmus = ma.codmus
--             join autor a on ma.codaut = a.codaut
--             group by a.codaut);

--             update autor a set renda = renda + (select renda from rendas r where a.codaut = r.codaut);
                SELECT (cd.preco / COUNT(f.codmus)) * COUNT(f.codmus)
            INTO rendas
            FROM faixa f
            JOIN cd ON f.codcd = cd.codcd
            WHERE f.codmus = NEW.codmus
            GROUP BY cd.codcd;

            -- Atualiza a renda do autor relacionado à música inserida
            UPDATE autor a
            SET renda = renda + rendas
            WHERE a.codaut = (
                SELECT ma.codaut
                FROM musicaautor ma
                WHERE ma.codmus = NEW.codmus
            );


            return new;
        end if;

        if(tg_op = 'UPDATE') then
            --update autor set renda = renda + new.renda - old.renda where a.c;
            UPDATE autor a SET renda = renda + (NEW.renda - OLD.renda)
            where a.codaut = (SELECT ma.codaut FROM musicaautor ma WHERE ma.codmus = new.codmus);

            return new;
        end if;

        if(tg_op = 'DELETE') then
            --update autor set renda = renda - old.renda;
            UPDATE autor a SET renda = renda - OLD.renda
            WHERE a.codaut = (SELECT ma.codaut FROM musicaautor ma WHERE ma.codmus = old.codmus);
            return old;
        end if;
    end;
$$;

create or replace trigger tg_atualizaRenda
    after insert or update or delete
    on itemvenda
execute procedure atualizacd();


-- testes
select * from gravadora; -- 1
select * from cd where codgrav = 1;
select * from musica;
select * from autor;
select * from musicaautor where codaut = codmus;
select * from musicaautor; -- 2 - 6
select * from faixa;

SELECT nomeaut, renda FROM Autor WHERE codaut = 20;
select f.codcd,ma.codaut,count(*) as total from faixa f
join musicaautor ma on ma.codmus=f.codmus
where f.codcd=1
group by codcd,ma.codaut
order by codcd;

select distinct(ma.codmus) from musicaautor ma
join faixa f on f.codmus=ma.codmus
where f.codcd=3 and ma.codaut=9;

select * from autor where renda>0;

-- insert into itemvenda (idvenda, codcd, qtde, preco) values ();

SELECT *
FROM autor
WHERE codaut IN (
    SELECT ma.codaut
    FROM musicaautor ma
    JOIN musica m ON ma.codmus = m.codmus
    JOIN faixa f ON m.codmus = f.codmus
    JOIN cd ON f.codcd = cd.codcd
    WHERE cd.codcd = 101  -- Substitua pelo codcd que foi afetado
);
-- como eu sei qual cd foi afetado
select * from cd where codcd = 8;

-- 10
-- Acrescentar na tabela gravadora um campo LUCRO
alter table gravadora add column lucro numeric(10,2);
select * from gravadora;

-- • Para cada CD vendido a gravadora recebe 40%
select * from itemvenda;
select * from venda;

select * from autor
where codaut in (
    select ma.codaut
    from musicaautor ma
    join musica m on ma.codmus = m.codmus
    join faixa f on m.codmus = f.codmus
    join cd on f.codcd = cd.codcd
    where cd.codcd = 1  -- Substitua pelo codcd que foi afetado
);

-- • Atualize o campo para situação atual

-- • Crie a TRIGGER para manter atualizado  esse campo a cada VENDA
create or replace procedure atualizaGravadora(codigocd int, tipo integer, qtde integer,preco numeric(10,2))
language 'plpgsql' as
$$
    declare
        codigograv integer;
    begin

       select codgrav from cd where codcd = codigocd into codigograv;
       if tipo=0 then
           update gravadora set lucro = lucro + (qtde *preco*0.40)
           where codgrav=codigograv;
       else
           update gravadora set lucro = lucro - qtde * (preco * 0.40)
           where codgrav=codigograv;
       end if;
    end;
$$;

call atualizaGravadora(2,0,1,15);

do $$
    declare registro record;
        cd int;
        qt int;
        precocd numeric(10,2);
    begin
        for registro in select codcd, sum(qtde) as total
            from itemvenda
            group by codcd loop
            cd:=registro.codcd;
            qt:=registro.total;
            select preco from cd where codcd=registro.codcd into precocd;
            call atualizagravadora(cd,0,qt,precocd);
        end loop;
    end;
$$;

-- insert into itemvenda (idvenda, codcd, qtde, preco) values ...; -- teste futuro

-- Pesquisas

-- Mostrar qual o CODIGO, NOME do cliente que mais comprou e o valor que ele comprou em Real e a qtde de CDs
select * from cliente c;
select c.codcli, c.nome, sum(it.qtde) quantidade, sum(c.valorcomprado) total from cliente c
join venda v on c.codcli = v.codcli
join itemvenda it on v.idvenda = it.idvenda group by c.codcli order by quantidade desc limit 1;

-- Mostrar a somatoria de todas as vendas
select sum(valortotal) somatoria from venda;
-- Mostrar a somatoria de todas as RENDAS DOS AUTORES
select sum(renda) renda from autor;
-- Mostrar a somatoria dos lucros das gravadoras
select sum(lucro) from gravadora;
-- Mostrar a somatoria de todas qtde * preco no ITEMVENDA
select idvenda numero_Venda, sum(it.qtde * it.preco) from itemvenda it group by idvenda order by numero_Venda;
