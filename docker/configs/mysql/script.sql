use devops_app;
create table welcome (id int not null AUTO_INCREMENT, description varchar(255) not null, PRIMARY KEY (id));
insert into welcome (description) values ('Alvarez, Agustin'),('Leiva, Santiago Joaquín'),('Olivera, Lautaro'),('Otero, Franco'),('Palavecino, Walter Daniel'),('Rodriguez, Marcelo Tony'),('Stadler, Marcelo');