# Социальная сеть

## Описание задания

Создаются две базы данных «Соц. сеть»:  
1. База данных реализованная на PostgreSQL.  
2. Аналогичная база данных, реализованная на другой СУБД согласно требованиям лабораторной работы.

База данных включает следующие сущности:  
- Люди  
- Друзья (отношения дружбы между людьми)  
- Подписчики (отношения подписок между людьми)  
- Паблики (каналы/группы)  
- Подписка людей на паблики

Количество строк в таблицах генерируется согласно параметрам лабораторной работы.

## Структура базы данных (пример для PostgreSQL)

- Таблица `people`: хранит информацию о пользователях.  
- Таблица `friends`: хранит пары идентификаторов друзей.  
- Таблица `followers`: хранит отношения подписчиков (асимметричные связи).  
- Таблица `publics`: хранит информацию о пабликах/каналах.  
- Таблица `public_subscriptions`: хранит данные о подписке пользователей на паблики.

## Скрипт создания структуры (PostgreSQL)

```sql
-- Создание таблицы пользователей
CREATE TABLE people (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица дружбы
CREATE TABLE friends (
    person1_id INT NOT NULL,
    person2_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (person1_id, person2_id),
    CONSTRAINT fk_person1 FOREIGN KEY (person1_id) REFERENCES people(id),
    CONSTRAINT fk_person2 FOREIGN KEY (person2_id) REFERENCES people(id)
);

-- Таблица подписчиков
CREATE TABLE followers (
    follower_id INT NOT NULL,
    following_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (follower_id, following_id),
    CONSTRAINT fk_follower FOREIGN KEY (follower_id) REFERENCES people(id),
    CONSTRAINT fk_following FOREIGN KEY (following_id) REFERENCES people(id)
);

-- Таблица пабликов
CREATE TABLE publics (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица подписки на паблики
CREATE TABLE public_subscriptions (
    person_id INT NOT NULL,
    public_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (person_id, public_id),
    CONSTRAINT fk_person_public FOREIGN KEY (person_id) REFERENCES people(id),
    CONSTRAINT fk_public FOREIGN KEY (public_id) REFERENCES publics(id)
);

-- Генерация 100 пользователей
INSERT INTO people (name, email)
SELECT
    'User_' || gs,
    'user_' || gs || '@example.com'
FROM generate_series(1, 100) AS gs;

-- Генерация 200 пар дружбы (случайные пары пользователей)
INSERT INTO friends (person1_id, person2_id)
SELECT
    floor(random() * 100 + 1)::INT,
    floor(random() * 100 + 1)::INT
FROM generate_series(1, 200)
WHERE person1_id <> person2_id;

-- Генерация 300 подписок (случайные подписки)
INSERT INTO followers (follower_id, following_id)
SELECT
    floor(random() * 100 + 1)::INT,
    floor(random() * 100 + 1)::INT
FROM generate_series(1, 300)
WHERE follower_id <> following_id;

-- Генерация 20 пабликов
INSERT INTO publics (name, description)
SELECT
    'Public_' || gs,
    'Описание паблика ' || gs
FROM generate_series(1, 20) AS gs;

-- Генерация 300 подписок на паблики
INSERT INTO public_subscriptions (person_id, public_id)
SELECT
    floor(random() * 100 + 1)::INT,
    floor(random() * 20 + 1)::INT
FROM generate_series(1, 300);
```

## Скрипт генерации данных (PostgreSQL)
```sql
-- Генерация 100 пользователей
INSERT INTO people (name, email)
SELECT
    'User_' || gs,
    'user_' || gs || '@example.com'
FROM generate_series(1, 100) AS gs;

-- Генерация 200 пар дружбы (случайные пары пользователей)
INSERT INTO friends (person1_id, person2_id)
SELECT
    floor(random() * 100 + 1)::INT,
    floor(random() * 100 + 1)::INT
FROM generate_series(1, 200)
WHERE person1_id <> person2_id;

-- Генерация 300 подписок (случайные подписки)
INSERT INTO followers (follower_id, following_id)
SELECT
    floor(random() * 100 + 1)::INT,
    floor(random() * 100 + 1)::INT
FROM generate_series(1, 300)
WHERE follower_id <> following_id;

-- Генерация 20 пабликов
INSERT INTO publics (name, description)
SELECT
    'Public_' || gs,
    'Описание паблика ' || gs
FROM generate_series(1, 20) AS gs;

-- Генерация 300 подписок на паблики
INSERT INTO public_subscriptions (person_id, public_id)
SELECT
    floor(random() * 100 + 1)::INT,
    floor(random() * 20 + 1)::INT
FROM generate_series(1, 300);
```

## Примеры заданий-запросов
Найти друзей конкретного пользователя:
```sql
SELECT p.id, p.name
FROM people p
JOIN friends f ON (p.id = f.person1_id OR p.id = f.person2_id)

WHERE f.person1_id = 10 OR f.person2_id = 10;
```

Подсчитать количество подписчиков для каждого пользователя:
```sql
SELECT following_id AS user_id, COUNT(*) AS followers_count
FROM followers
GROUP BY following_id
ORDER BY followers_count DESC;
```

Найти топ-5 пабликов по числу подписчиков:

```sql
SELECT pu.id, pu.name, COUNT(ps.person_id) AS subscribers_count
FROM publics pu
LEFT JOIN public_subscriptions ps ON pu.id = ps.public_id
GROUP BY pu.id, pu.name
ORDER BY subscribers_count DESC
LIMIT 5;
```

Найти пользователей, подписанных одновременно на два конкретных паблика (например, с id 1 и 2):
```sql
SELECT person_id
FROM public_subscriptions
WHERE public_id IN (1, 2)
GROUP BY person_id
HAVING COUNT(DISTINCT public_id) = 2;
```