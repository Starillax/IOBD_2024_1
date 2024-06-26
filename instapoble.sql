DROP DATABASE IF EXISTS instapoble;

CREATE DATABASE instapoble;

\c instapoble; 

CREATE TABLE usuario (
    id serial primary key,
    nome character varying (100) not null,
    email character varying (100) unique not null,
    senha character varying (100) not null,
    data_nascimento date check (EXTRACT(YEAR FROM(AGE(data_nascimento))) >= 18)
);

INSERT INTO usuario (nome, email, senha, data_nascimento) VALUES 
('Pedro Henrique Pereira Gonzalez Padilha', 'w400pedro@gmail.com', md5('123'),'2002-11-24'),
('Léia Rodrigues de Almeida', 'leleca26@gmail.com', md5('456'),'1977-03-26');

CREATE TABLE conta (
    id serial primary key,
    nome_usuario text unique not null,
    data_hora_criacao timestamp default current_timestamp,            
    usuario_id integer references usuario (id)
);  
INSERT INTO conta (nome_usuario, usuario_id) VALUES
('w400pedro', 1),
('persona5stan', 1),
('leiardalmeida', 2),
('catiucha', 2);

CREATE TABLE publicacao (
    id serial primary key,
    data_hora timestamp default current_timestamp,
    texto text,
    arquivo_principal text not null,
    latitude real,
    longitude real
);

INSERT INTO publicacao (arquivo_principal, texto) VALUES
('jjk_2.jpeg', 'Melhor anime que já vi na vida! Merece tudo de melhor!!'),
('persona_5.jpeg', 'Msm q umas pessoas digam q o final é ruim, n é nada, esse jogo é perfeito! Falei, to leve'),
('selfie.jpeg', 'Auau');

CREATE TABLE arquivo (
    id serial primary key,
    arquivo text not null,
    publicacao_id integer references publicacao (id)
);
INSERT INTO arquivo (arquivo, publicacao_id) VALUES
('persona_5_2.jpeg', 2);

CREATE TABLE conta_publicacao (
    publicacao_id integer references publicacao (id),
    conta_id integer references conta (id),
    primary key (publicacao_id, conta_id)
);

INSERT INTO conta_publicacao (conta_id, publicacao_id) VALUES
(1,1),
(2,2),
(4,3);

CREATE TABLE comentario (
    id serial primary key,
    texto text not null,
    data_hora timestamp default current_timestamp,
    publicacao_id integer references publicacao (id),
    conta_id integer references conta (id)    
);

INSERT INTO comentario (publicacao_id, conta_id, texto) values
(3, 3, 'te amo, minha filha!'),
(2, 1, 'hablou');


-- 1)

SELECT usuario.nome, conta.nome_usuario FROM usuario JOIN conta ON conta.usuario_id = usuario.id;

-- 2)

SELECT publicacao.texto, publicacao.arquivo_principal, arquivo.arquivo FROM publicacao LEFT JOIN arquivo ON arquivo.publicacao_id = publicacao.id;

-- 3)

SELECT publicacao.texto, comentario.texto FROM publicacao LEFT JOIN comentario ON comentario.publicacao_id = publicacao.id;

-- 4)

SELECT publicacao.texto, comentario.texto FROM publicacao JOIN comentario ON comentario.publicacao_id = publicacao.id;

-- 5)

SELECT usuario.id, usuario.nome, count(*) as qtde_contas FROM usuario JOIN conta ON conta.usuario_id = usuario.id GROUP BY 1 ORDER BY 1;

-- 6)

SELECT usuario.id, usuario.nome, count(*) as qtde_publicacoes FROM usuario JOIN conta ON conta.usuario_id = usuario.id JOIN conta_publicacao ON conta_publicacao.conta_id = conta.id GROUP BY 1 ORDER BY 1;

-- 7)

SELECT publicacao.id, publicacao.texto, count(*) as qtde_comentarios FROM publicacao JOIN comentario ON comentario.publicacao_id = publicacao.id GROUP BY 1 HAVING count(*) = (SELECT count(*) from publicacao JOIN comentario on publicacao.id = comentario.publicacao_id GROUP BY publicacao.id ORDER BY count(*) DESC LIMIT 1) ORDER BY 1;

-- 8)

SELECT id, texto FROM publicacao WHERE id NOT IN (SELECT comentario.publicacao_id FROM comentario);

-- 9)

SELECT usuario.id, usuario.nome, count(*) as qtde_contas FROM usuario JOIN conta ON conta.usuario_id = usuario.id GROUP BY 1 HAVING count(*) = 1 ORDER BY 1;

-- 10)

SELECT usuario.id, usuario.nome, count(*) as qtde_contas FROM usuario JOIN conta ON conta.usuario_id = usuario.id GROUP BY 1 HAVING count(*) > 1 ORDER BY 1;

-- 11)

SELECT id, texto FROM publicacao WHERE id NOT IN (SELECT arquivo.publicacao_id FROM arquivo);

-- 12)

SELECT publicacao.id, publicacao.texto, count(*) FROM publicacao JOIN conta_publicacao ON conta_publicacao.publicacao_id = publicacao.id GROUP BY 1 HAVING count(*) > 1 ORDER BY 1;

-- 13)

SELECT usuario.id, usuario.nome, conta.nome_usuario FROM usuario JOIN conta ON conta.usuario_id = usuario.id WHERE conta.id NOT IN (SELECT conta_publicacao.conta_id FROM conta_publicacao);

-- 14)

SELECT usuario.id, usuario.nome FROM usuario JOIN conta ON conta.usuario_id = usuario.id JOIN conta_publicacao ON conta_publicacao.conta_id = conta.id JOIN publicacao ON publicacao.id = conta_publicacao.publicacao_id WHERE publicacao.id NOT IN (SELECT comentario.publicacao_id FROM comentario);

-- 15)

SELECT conta.id, conta.nome_usuario, count(*) as qtde_comentarios FROM conta JOIN comentario ON comentario.conta_id = conta.id GROUP BY 1 HAVING count(*) = (SELECT count(*) FROM conta JOIN comentario ON conta.id = comentario.conta_id GROUP BY conta.id ORDER BY count(*) DESC LIMIT 1);

-- 16)

SELECT usuario.nome, conta.nome_usuario, conta.data_hora_criacao FROM usuario JOIN conta ON conta.usuario_id = usuario.id ORDER BY 3 DESC LIMIT 1;

-- 17)

SELECT usuario.id, usuario.nome, count(*) as qtde_contas FROM usuario JOIN conta ON conta.usuario_id = usuario.id GROUP BY 1 HAVING count(*) = (SELECT count(*) FROM usuario JOIN conta ON conta.usuario_id = usuario.id GROUP BY usuario.id ORDER BY count(*) DESC LIMIT 1) ORDER BY 1;

-- 18)

SELECT usuario.id, usuario.nome, count(*) as qtde_contas FROM usuario JOIN conta ON conta.usuario_id = usuario.id GROUP BY 1 HAVING count(*) = (SELECT count(*) FROM usuario JOIN conta ON conta.usuario_id = usuario.id GROUP BY usuario.id ORDER BY count(*) ASC LIMIT 1) ORDER BY 1;

-- 19)

SELECT comentario.id, comentario.texto, comentario.data_hora FROM comentario WHERE comentario.data_hora > CURRENT_TIMESTAMP - INTERVAL '7 DAYS';

-- 20)

SELECT conta.id, conta.nome_usuario FROM conta JOIN usuario ON usuario.id = conta.usuario_id WHERE usuario.data_nascimento = (SELECT usuario.data_nascimento FROM usuario ORDER BY usuario.data_nascimento LIMIT 1);

-- 21)

SELECT usuario.id, usuario.nome, count(conta.id) as qtde_contas FROM usuario LEFT JOIN conta ON conta.usuario_id = usuario.id GROUP BY usuario.id ORDER BY count(conta.id) ASC;

-- 22)

SELECT * FROM comentario WHERE date(data_hora) >= '2024-02-20' AND date(data_hora) < '2024-03-30';

-- 23)

SELECT publicacao.id, publicacao.texto, count(*) as qtde_arquivos FROM publicacao JOIN arquivo ON arquivo.publicacao_id = publicacao.id GROUP BY publicacao.id HAVING count(*) >= 2;

-- 24) & 25)

SELECT publicacao.id, publicacao.texto, length(publicacao.texto) as nmro_caracteres FROM publicacao WHERE length(publicacao.texto) = (SELECT length(publicacao.texto) FROM publicacao ORDER BY 1 DESC LIMIT 1);

-- 26)

SELECT usuario.id, usuario.nome, count(*) as qtde_publicacoes FROM usuario JOIN conta ON conta.usuario_id = usuario.id JOIN conta_publicacao ON conta_publicacao.conta_id = conta.id JOIN publicacao ON publicacao.id = conta_publicacao.publicacao_id WHERE date(publicacao.data_hora) >= '2024-02-20' AND date(publicacao.data_hora) < '2024-03-30' GROUP BY usuario.id HAVING count(*) = (SELECT count(*) FROM usuario JOIN conta ON conta.usuario_id = usuario.id JOIN conta_publicacao ON conta_publicacao.conta_id = conta.id JOIN publicacao ON publicacao.id = conta_publicacao.publicacao_id GROUP BY usuario.id ORDER BY count(*) DESC LIMIT 1);

-- 27)

SELECT conta.id, conta.nome_usuario, count(*) as qtde_publicacoes FROM conta JOIN conta_publicacao ON conta_publicacao.conta_id = conta.id GROUP BY conta.id HAVING count(*) = (SELECT count(*) FROM conta JOIN conta_publicacao ON conta_publicacao.conta_id = conta.id GROUP BY conta.id ORDER BY count(*) DESC LIMIT 1);

-- 28)



-- 29)

SELECT publicacao.id, publicacao.texto, count(*) as qtde_arquivos FROM publicacao JOIN arquivo ON arquivo.publicacao_id = publicacao.id GROUP BY publicacao.id HAVING count(*) = (SELECT count(*) FROM publicacao JOIN arquivo ON arquivo.publicacao_id = publicacao.id GROUP BY publicacao.id ORDER BY count(*) DESC LIMIT 1);

-- 30)

ALTER TABLE conta_publicacao ADD data_hora timestamp default current_timestamp;

-- 31)

SELECT usuario.id, usuario.nome, count(*) as qtde_comentarios FROM usuario JOIN conta on conta.usuario_id = usuario.id JOIN comentario ON comentario.conta_id = conta.id GROUP BY usuario.id HAVING count(*) = (SELECT count(*) FROM usuario JOIN conta on conta.usuario_id = usuario.id JOIN comentario ON comentario.conta_id = conta.id GROUP BY usuario.id ORDER BY count(*) DESC LIMIT 1);

-- 32)

SELECT conta.id, conta.nome_usuario, count(*) as qtde_comentarios FROM conta JOIN comentario ON comentario.conta_id = conta.id GROUP BY conta.id HAVING count(*) = (SELECT count(*) FROM conta JOIN comentario ON comentario.conta_id = conta.id GROUP BY conta.id ORDER BY count(*) DESC LIMIT 1);

-- 33)

SELECT TO_CHAR(publicacao.data_hora, 'DD/MM/YYYY HH:MI:SS') FROM publicacao;

-- order by random();

-- CASE WHEN ... THEN ... ELSE ... END AS (nome)
