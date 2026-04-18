DROP TABLE IF EXISTS Лікує;
DROP TABLE IF EXISTS Наявні;
DROP TABLE IF EXISTS Співробітники;
DROP TABLE IF EXISTS Аптечна_установа;
DROP TABLE IF EXISTS Перелік_лікарств;
DROP TABLE IF EXISTS Посада;
DROP TABLE IF EXISTS Вулиця;
DROP TABLE IF EXISTS Зона_впливу;

--1)
-- Очистка перед початком
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Petro_Admin') DROP USER Petro_Admin;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Olena_Pharm') DROP USER Olena_Pharm;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Dmytro_Analyst') DROP USER Dmytro_Analyst;

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'Petro_Admin') DROP LOGIN Petro_Admin;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'Olena_Pharm') DROP LOGIN Olena_Pharm;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'Dmytro_Analyst') DROP LOGIN Dmytro_Analyst;

--3)
--Видаляємо ролі, якщо вони вже були створені раніше, щоб не було помилок
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Role_Admin' AND type = 'R') DROP ROLE Role_Admin;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Role_Pharmacist' AND type = 'R') DROP ROLE Role_Pharmacist;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Role_Analyst' AND type = 'R') DROP ROLE Role_Analyst;


-- Створюємо реальних людей користувачів 
CREATE LOGIN Petro_Admin WITH PASSWORD = 'StrongPass111!'; -- Адміністратор
CREATE USER Petro_Admin FOR LOGIN Petro_Admin;

CREATE LOGIN Olena_Pharm WITH PASSWORD = 'StrongPass222!'; -- Фармацевт
CREATE USER Olena_Pharm FOR LOGIN Olena_Pharm;

CREATE LOGIN Dmytro_Analyst WITH PASSWORD = 'StrongPass333!'; -- Аналітик
CREATE USER Dmytro_Analyst FOR LOGIN Dmytro_Analyst;

--3) СТВОРЕННЯ РОЛЕЙ 
CREATE ROLE Role_Admin;     -- Роль для повного керування системою
CREATE ROLE Role_Pharmacist; -- Роль для працівників торгового залу
CREATE ROLE Role_Analyst;    -- Роль для фахівців з асортименту


CREATE TABLE Посада (
    Назва_посади VARCHAR(100) PRIMARY KEY
);

CREATE TABLE Вулиця (
    Назва_вулиці VARCHAR(100) PRIMARY KEY
);

CREATE TABLE Аптечна_установа (
	Назва_установи VARCHAR(100) PRIMARY KEY,
	Номер_будинку VARCHAR(10),
	Адреса_вебсторінки VARCHAR(255),

	Час_роботи VARCHAR(50),
	Чи_вихідний_у_суботу BIT,
	Чи_вихідний_у_неділю BIT,
	Назва_вулиці VARCHAR(100),

	FOREIGN KEY (Назва_вулиці) REFERENCES Вулиця(Назва_вулиці)

);


CREATE TABLE Співробітники (

	Прізвище VARCHAR(50),
	Ім_я  VARCHAR(50),
	По_батькові  VARCHAR(50),
	Ідентифікаційний_номер VARCHAR(10) UNIQUE,
	Серія_номер_паспорту VARCHAR(20),
	Трудовий_стаж INT,
	Дата_народження DATE,
	Назва_посади VARCHAR(100),
	Назва_установи VARCHAR(100),
	Код_співробітника AS (Прізвище + RIGHT(Ідентифікаційний_номер, 2)),

	
	PRIMARY KEY(Прізвище, Ім_я, По_батькові),
	CHECK (Ідентифікаційний_номер LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	
	FOREIGN KEY (Назва_посади) REFERENCES Посада(Назва_посади),
	FOREIGN KEY (Назва_установи) REFERENCES Аптечна_установа (Назва_установи),
);


CREATE TABLE Перелік_лікарств (

	Назва_ліків VARCHAR(15) PRIMARY KEY,
	Код_міністерства VARCHAR(50) UNIQUE,
	Чи_потрібен_рецепт Bit,
	Чи_наркотичний_засіб Bit,
	Чи_психотропний_засіб Bit,

	 CHECK (
        SUBSTRING(Назва_ліків, 1, 1) = SUBSTRING(Код_міністерства, 1, 1)
    )

);


CREATE TABLE Зона_впливу (
	Назва_зони VARCHAR(100) PRIMARY KEY
);

--проміжні таблиці/зв'язки m:n

CREATE TABLE Наявні (

	Назва_установи VARCHAR(100),
	Назва_ліків VARCHAR(15),

	PRIMARY KEY (Назва_установи, Назва_ліків),

	FOREIGN KEY (Назва_установи) REFERENCES Аптечна_установа(Назва_установи),
    FOREIGN KEY (Назва_ліків) REFERENCES Перелік_лікарств(Назва_ліків)

);


CREATE TABLE Лікує (

	Назва_ліків VARCHAR(15),
	Назва_зони VARCHAR(100),

	PRIMARY KEY (Назва_ліків, Назва_зони),

	FOREIGN KEY (Назва_ліків) REFERENCES Перелік_лікарств(Назва_ліків),
    FOREIGN KEY (Назва_зони) REFERENCES Зона_впливу(Назва_зони)

);

--заповлення таблиць

INSERT INTO Посада (Назва_посади) VALUES ('Завідувач'), ('Провізор'), ('Фармацевт');
INSERT INTO Вулиця (Назва_вулиці) VALUES ('Городоцька'), ('Стрийська'), ('пр. Свободи');
INSERT INTO Зона_впливу (Назва_зони) VALUES ('Серцево-судинна'), ('Травлення'), ('Нервова система');

INSERT INTO Аптечна_установа (Назва_установи, Номер_будинку, Адреса_вебсторінки, Час_роботи, Чи_вихідний_у_суботу, Чи_вихідний_у_неділю, Назва_вулиці) 
VALUES ('Аптека №1', '10', 'apteka1.lviv.ua', '08:00-21:00', 0, 1, 'Городоцька'),
	   ('Подорожник', '15', 'pdrk.lviv.ua', '09:00-22:00', 0, 0, 'Стрийська'),
	   ('Центральна аптека', '120', 'center-farm.lviv.ua', 'Цілодобово', 0, 0, 'пр. Свободи');


INSERT INTO Перелік_лікарств (Назва_ліків, Код_міністерства, Чи_потрібен_рецепт, Чи_наркотичний_засіб, Чи_психотропний_засіб)
VALUES ('Анальгін', 'А-12345', 0, 0, 0), 
       ('Валеріана', 'В-98765', 0, 0, 0),
	   ('Парацетамол', 'П-11223', 0, 0, 0),
	   ('Но-шпа', 'Н-55443', 0, 0, 0),
	   ('Діазепам', 'Д-99887', 1, 0, 1),
       ('Морфін', 'М-77665', 1, 1, 0),
       ('Цитрамон', 'Ц-33445', 0, 0, 0),
       ('Корвалол', 'К-22334', 0, 0, 0);



INSERT INTO Співробітники (Прізвище, Ім_я, По_батькові, Ідентифікаційний_номер, Серія_номер_паспорту, Трудовий_стаж, Дата_народження, Назва_посади, Назва_установи)
VALUES ('Шевченко', 'Андрій', 'Миколайович', '1234567890', 'КС 123456', 5, '1990-05-15', 'Провізор', 'Аптека №1'),
	   ('Коваленко', 'Олена', 'Іванівна', '0987654321', 'ММ 654321', 12, '1982-03-20', 'Завідувач', 'Аптека №1'),
       ('Мельник', 'Дмитро', 'Сергійович', '1122334455', 'АВ 112233', 3, '1995-11-10', 'Фармацевт', 'Подорожник'),
       ('Бондар', 'Марія', 'Олександрівна', '5566778899', 'НЕ 554433', 7, '1990-07-05', 'Провізор', 'Подорожник'),
       ('Ткаченко', 'Олексій', 'Петрович', '4455667788', 'СА 445566', 2, '1998-01-30', 'Фармацевт', 'Аптека №1');



INSERT INTO Наявні (Назва_установи, Назва_ліків) 
VALUES 
('Подорожник', 'Парацетамол'),
('Подорожник', 'Но-шпа'),
('Аптека №1', 'Діазепам'),
('Аптека №1', 'Парацетамол'),
('Подорожник', 'Цитрамон');


INSERT INTO Лікує (Назва_ліків, Назва_зони)
VALUES 
('Парацетамол', 'Нервова система'),
('Но-шпа', 'Травлення'),
('Діазепам', 'Нервова система'),
('Цитрамон', 'Нервова система'),
('Корвалол', 'Серцево-судинна');


--2)
-- 1. ПЕТРО (Адмін) - Має право керувати структурою та персоналом
GRANT SELECT, INSERT, UPDATE, DELETE ON Співробітники TO Petro_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Аптечна_установа TO Petro_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Посада TO Petro_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Вулиця TO Petro_Admin;

-- 2. ОЛЕНА (Фармацевт) - Має право працювати з товаром та продажами
GRANT SELECT ON Перелік_лікарств TO Olena_Pharm;
GRANT SELECT ON Лікує TO Olena_Pharm;
GRANT SELECT, UPDATE ON Наявні TO Olena_Pharm; -- Може оновлювати залишки
GRANT SELECT ON Вулиця TO Olena_Pharm; -- Твій персональний привілей для Олени

-- 3. ДМИТРО (Аналітик) - Має право керувати каталогом ліків
GRANT SELECT, INSERT, UPDATE ON Перелік_лікарств TO Dmytro_Analyst;
GRANT SELECT, INSERT, UPDATE ON Зона_впливу TO Dmytro_Analyst;
GRANT SELECT, INSERT, UPDATE ON Лікує TO Dmytro_Analyst;
GRANT SELECT ON Аптечна_установа TO Dmytro_Analyst; -- Для аналізу мережі


--демонстрація 2)
-- 1. Стаємо Оленою
--EXECUTE AS USER = 'Olena_Pharm';
--PRINT 'Зараз дію як: ' + USER_NAME();

-- Успішно: Олена дивиться список ліків
--SELECT Назва_ліків, Чи_потрібен_рецепт FROM Перелік_лікарств;


-- ПОМИЛКА: Олена намагається подивитися паспортні дані колег
-- (Система видасть помилку: Permission denied)
--SELECT Прізвище, Серія_номер_паспорту FROM Співробітники;

--REVERT; -- Повертаємося до прав адміна


--4) надання привілеїв створеним ролям 
-- Привілеї для ролі Адміністратора (Role_Admin)
-- Даємо повний доступ до таблиць управління
GRANT SELECT, INSERT, UPDATE, DELETE ON Співробітники TO Role_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Аптечна_установа TO Role_Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Вулиця TO Role_Admin;

-- Привілеї для ролі Фармацевта (Role_Pharmacist)
-- Тільки те, що потрібно для продажу та консультацій
GRANT SELECT ON Перелік_лікарств TO Role_Pharmacist;
GRANT SELECT ON Лікує TO Role_Pharmacist;
GRANT SELECT ON Наявні TO Role_Pharmacist;
GRANT UPDATE ON Наявні TO Role_Pharmacist; -- Щоб міг змінювати кількість при продажу

-- Привілеї для ролі Аналітика (Role_Analyst)
-- Робота з каталогом ліків та зонами впливу
GRANT SELECT, INSERT, UPDATE ON Перелік_лікарств TO Role_Analyst;
GRANT SELECT, INSERT, UPDATE ON Лікує TO Role_Analyst;
GRANT SELECT ON Зона_впливу TO Role_Analyst;
GRANT SELECT ON Аптечна_установа TO Role_Analyst;

--демонстрація 4)
SELECT 
    USER_NAME(grantee_principal_id) AS RoleName, 
    OBJECT_NAME(major_id) AS TableName, 
    permission_name AS Permission
FROM sys.database_permissions
WHERE grantee_principal_id IN (USER_ID('Role_Admin'), USER_ID('Role_Pharmacist'), USER_ID('Role_Analyst'));

--5) призначення користувачам ролей
-- Призначаємо роль Адміна Петру
ALTER ROLE Role_Admin ADD MEMBER Petro_Admin;

-- Призначаємо роль Фармацевта Олені
ALTER ROLE Role_Pharmacist ADD MEMBER Olena_Pharm;

-- Призначаємо роль Аналітика Дмитру
ALTER ROLE Role_Analyst ADD MEMBER Dmytro_Analyst;


--демонстрація 5)
SELECT 
    DP1.name AS RoleName, 
    DP2.name AS MemberName  
FROM sys.database_role_members AS DRM  
JOIN sys.database_principals AS DP1 ON DRM.role_principal_id = DP1.principal_id  
JOIN sys.database_principals AS DP2 ON DRM.member_principal_id = DP2.principal_id  
WHERE DP1.name LIKE 'Role_%';

--6)забираємо у користувача олени,у якої роль фармацевт, право на селект.
--вона все одно бачитиме таблицю оскільки вона скористується привілеєм через її роль

-- 1. Спробуємо забрати право на SELECT у Олени персонально
REVOKE SELECT ON Наявні FROM Olena_Pharm;

-- 2. Перевірка (Демонстрація)
EXECUTE AS USER = 'Olena_Pharm';
    -- Олена все одно бачить таблицю.
    SELECT * FROM Наявні; 
    PRINT 'Олена все ще бачить Наявні завдяки своїй РОЛІ.';
REVERT;

--7)суть забрати у користувача роль і спробувати достукатися до запиту через персональний привілей
-- Забираємо роль у Дмитра 
ALTER ROLE Role_Analyst DROP MEMBER Dmytro_Analyst;

--демонстрація
SELECT Назва_установи, Адреса_вебсторінки FROM Аптечна_установа;
REVERT;

--8) видалити роль і видалити користувача
--роль:
--DROP ROLE Role_Pharmacist;
--DROP USER Olena_Pharm;
--DROP LOGIN Olena_Pharm;