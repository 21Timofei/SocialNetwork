# Социальная сеть

## Описание задания

Суть лабораторной работы заключается в создании двух БД «Соц. сеть»:

1. **PostgreSQL**  
   Реализуется база данных с таблицами для следующих сущностей:
    - Люди
    - Друзья (отношения дружбы между людьми)
    - Подписчики (отношения подписок между людьми)
    - Паблики (каналы/группы)
    - Подписка людей на паблики

2. **Neo4J**  
   Реализуется аналогичная база данных, где сущности представлены в виде узлов и связей:
    - Узлы: Люди, Паблики
    - Связи: ДРУЗЬБА (между людьми), ПОДПИСЧИК (отношения подписок между пользователями), ПОДПИСКА (отношения между людьми и пабликами)

Количество данных в обеих БД генерируется согласно параметрам лабораторной работы.

```plaintext
social_network_lab/
├── README.md              // описание проекта
├── .env                   // пример конфигурационного файла
├── docker-compose.yaml    // описание сервисов для Docker Compose
├── requirements.txt       // список зависимостей Python
├── generate_data.py       // скрипт генерации тестовых данных
├── data/                  // CSV файлы исходных данных, так как нужно одинаковые данные для обеих БД
│   └── *.csv
├── postgres/              // PostgreSQL
│   ├── schema.sql         // создание структуры БД
│   ├── import.sql         // импорт данных
│   └── queries.sql        // запросы для тестирования
├── neo4j/                 // Neo4J
    ├── schema.cypher      // создание структуры БД
    ├── import.cypher      // импорт данных
    └── queries.cypher     // запросы для тестирования

```

## Структура базы данных

### PostgreSQL

- Таблица `people`: хранит информацию о пользователях.
- Таблица `friends`: хранит пары идентификаторов друзей.
- Таблица `followers`: хранит отношения подписчиков (асимметричные связи).
- Таблица `publics`: хранит информацию о пабликах/каналах.
- Таблица `public_subscriptions`: хранит данные о подписке пользователей на паблики.

### Neo4J

- Узел `Person` для пользователей.
- Узел `Public` для пабликов/каналов.
- Связь `FRIEND` между узлами `Person` (двусторонняя связь).
- Связь `FOLLOWS` между узлами `Person` (асимметричная связь).
- Связь `SUBSCRIBED_TO` от узла `Person` к узлу `Public`.

## Скрипт создания структуры

### PostgreSQL

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
```
### Neo4J

```cypher
// Создание индексов для узлов Person и Public
CREATE CONSTRAINT ON (p:Person) ASSERT p.id IS UNIQUE;
CREATE CONSTRAINT ON (pub:Public) ASSERT pub.id IS UNIQUE;

// Пример создания узлов для пользователей
UNWIND range(1, 100) AS id
CREATE (:Person {id: id, name: "User_" + toString(id), email: "user_" + toString(id) + "@example.com", created_at: timestamp()});

// Пример создания узлов для пабликов
UNWIND range(1, 20) AS id
CREATE (:Public {id: id, name: "Public_" + toString(id), description: "Описание паблика " + toString(id), created_at: timestamp()});

// Пример создания связей дружбы между пользователями
MATCH (a:Person), (b:Person)
WHERE a.id < b.id AND rand() < 0.05
CREATE (a)-[:FRIEND {created_at: timestamp()}]->(b),
(b)-[:FRIEND {created_at: timestamp()}]->(a);

// Пример создания связей подписчиков между пользователями
MATCH (f:Person), (t:Person)
WHERE f.id <> t.id AND rand() < 0.1
CREATE (f)-[:FOLLOWS {created_at: timestamp()}]->(t);

// Пример создания связей подписки на паблики
MATCH (p:Person), (pub:Public)
WHERE rand() < 0.1
CREATE (p)-[:SUBSCRIBED_TO {created_at: timestamp()}]->(pub);
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
## Neo4J
Найти друзей конкретного пользователя:
```cypher
MATCH (p:Person {id: 10})-[:FRIEND]-(friend:Person)
RETURN friend.id, friend.name;
```
Подсчитать количество подписчиков для каждого пользователя:

```cypher
MATCH (follower:Person)-[:FOLLOWS]->(target:Person)
RETURN target.id AS user_id, COUNT(follower) AS followers_count
ORDER BY followers_count DESC;
```
Найти топ-5 пабликов по числу подписчиков:
```cypher
MATCH (p:Person)-[:SUBSCRIBED_TO]->(pub:Public)
RETURN pub.id, pub.name, COUNT(p) AS subscribers_count
ORDER BY subscribers_count DESC
LIMIT 5;
```