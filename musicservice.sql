
/*Создание таблиц*/
CREATE TABLE IF NOT EXISTS genre (genre_id SERIAL PRIMARY KEY,genre_name VARCHAR(60) NOT NULL);
CREATE TABLE IF NOT EXISTS singer (singer_id SERIAL PRIMARY KEY,singer_name VARCHAR(100) NOT NULL);
CREATE TABLE IF NOT EXISTS album (album_id SERIAL PRIMARY KEY,album_name VARCHAR(100) NOT NULL);
CREATE TABLE IF NOT EXISTS track (track_id SERIAL PRIMARY KEY, track_name VARCHAR(100) NOT NULL, track_length VARCHAR(20), album_id INTEGER NOT NULL REFERENCES album(album_id));
CREATE TABLE IF NOT EXISTS track_col (col_id SERIAL PRIMARY KEY, col_name VARCHAR(100) NOT NULL, col_year CHAR(4) NOT NULL);
CREATE TABLE IF NOT EXISTS AlbumSinger (id SERIAL PRIMARY KEY, album_id INTEGER REFERENCES album(album_id), singer_id INTEGER REFERENCES singer(singer_id));
CREATE TABLE IF NOT EXISTS SingerGenre (id SERIAL PRIMARY KEY, singer_id INTEGER REFERENCES singer(singer_id), genre_id INTEGER REFERENCES genre(genre_id));
CREATE TABLE IF NOT EXISTS TrackCollection (id SERIAL PRIMARY KEY, track_id INTEGER REFERENCES track(track_id), coll_id INTEGER REFERENCES track_col(col_id));
/*ЗАполнение таблиц исполнителей и жанров*/
INSERT INTO singer(singer_id,singer_name) VALUES (1,'Die Toten Hosen'), (2,'Red Hot Chili Peppers'), (3, 'The Offspring'), (4, 'Crematory'), (5, 'Brastie Boys');
INSERT INTO genre(genre_id, genre_name) VALUES (1, 'Punk'), (2, 'Rock'), (3, 'Indi'), (4, 'Grange'), (5, 'Gothic');
/*добавление столбца с годом в таблицу с альбомами*/
alter table album add column album_year CHAR(4) NOT NULL;
/*Заполнение таблицы с альбомами*/
insert into album values (1, 'Under the bridge', '1991'), (2,'Americana', '1998'), (3, 'Ein kleines bisschen Horrorschau', '1988'), (4, 'III Communication', '1988'), (5, 'Illusions', '1995');
/*Исправление ошибки в названии исполнителя в таблице с исполнителями*/
update singer set singer_name = 'Beastie Boys' where singer_name = 'Brastie Boys';
/*Заполнениие таблиц со сборниками, треками, альбом-исполнитель, исполнитель-жанр, исполнитель-альбом
 * трек-сборник
 */
insert into track_col (col_id, col_name, col_year) values (1, 'The Best of Punk', '2010'), (2, 'The Best of Indi', '2012'), (3, 'The Best of Grange', '2009'), (4, 'The Best of Rock', '2015'), (5, 'The Best Ever', '2020');
insert into track (track_id, track_name, track_length, album_id) values (1, 'Sabotage', '185', 4 ), (2, 'Self Esteem', '214', 2), (3, 'Tears of time', '341',5), (4, 'Hier kommt Alex', '287', 3), (5, 'Blood Sugar Sex Magic', '312', 1);
insert into albumsinger (id, album_id, singer_id) values (1, 1, 2), (2, 2, 3), (3, 3, 1), (4, 4, 5), (5, 5, 4);
insert into track (track_id, track_name, track_length, album_id) values (6, 'Fight for your rights', '173', 4);
insert into singergenre (id,singer_id, genre_id) values (1, 1, 1), (2, 2, 3), (3, 3, 4), (4, 4, 5), (5, 5, 2);
insert into trackcollection (id, track_id, coll_id) values (1,1, 4), (2, 2, 3), (3, 3, 5), (4, 4, 1), (5, 5, 2), (6, 6, 5);
/*Дополнение "My" для исполнения задания*/
update track set track_name = 'My tears of time' where track_name = 'Tears of time';
/*Изменение типа столбца продолжительность трека со строчного на int*/
alter table track alter column track_length type INTEGER using track_length::integer;
/*Выборка треков с продолжительностью более 3,5 мин*/
select track_name, track_length from track
where track_length  >= 210
order by track_length desc;
/*Название и продолжительность самого длинного трека*/
select track_name, track_length from track
where track_length = (select max(track_length) from track);
/*Выборка исполнителей с названием из одного слова*/
select * from singer
where singer_name not like '% %';
/*выборка сборников выпущенных с 2015 пло 2020 год (пришлось расширить диапазон, так как изначально не посмотрел
 * все задания и ввел года выпуска навскидку 
 */
select col_name, col_year
from track_col
where col_year between '2015' and '2020';
/*поиск трека название которого содержит "My"*/
select track_name
from track where upper(track_name) like '%MY%';
/*Добавление дополнительных жанров исполнителям, чтобы у некоторых было более одного жанра*/
insert into singergenre (id, singer_id, genre_id) values (6, 3, 1), (7, 2, 2);
/*вывод количества исполнителей в каждом жанре*/
select genre_name, count(singer_name)
from singer s
left join singergenre sg on s.singer_id = sg.singer_id
left join genre g on sg.genre_id = g.genre_id 
group by g.genre_name;
/*Вывод количества треков в альбомах, выпущенных 
 * в период с 1990 по 1996 год (заменил года вместо заданных в задании, так как при первоначальном вводе не посмотрел полностью задание)
 */
select album_year, album_name, count(track_id)
from album a
left join track t on a.album_id = t.album_id 
where album_year between '1990' and '1996'
group by a.album_name, a.album_year;
/*Добавление треков, чтобы в альбомах было не по одному треку)*/
insert into track(track_id, track_name, track_length, album_id) values (7, 'You gonna go far kid', 256, 2), (8, 'Bye Bye, Alex', 342, 3);
/*Средняя продолжительность треков по каждому альбому*/
select album_name, album_year, AVG(track_length)
from album a
left join track t on t.album_id = a.album_id
group by a.album_name, a.album_year 
order by a.album_year;
/*Названия исполнителей не выпускавших альбомы в период 1990-1996, года подкорректировал с 
 * учетом изначально введенных в таблицы
 */
select singer_name from singer s
left join albumsinger als on s.singer_id = als.singer_id 
left join album a on a.album_id = als.album_id 
where album_year not between '1990' and '1996';
/*Выборка сборников в которые входит заданный исполнитель*/
select col_name, col_year from track_col tc
left join trackcollection tcol on tcol.coll_id = tc.col_id 
left join track t on t.track_id = tcol.coll_id
left join albumsinger als on als.album_id = t.album_id 
left join singer s on s.singer_id = als.singer_id
where singer_name = 'Die Toten Hosen';
