# Социальная сеть

## Инструкция по запуску

1. Запустите сервисы с помощью команды `docker-compose up`.
2. Для перехода в консоль Neo4j перейдите по адресу http://localhost:7474/browser/ и введите логин и пароль:
   - Логин: neo4j
   - Пароль: neo4j_pass
3. Для перехода в консоль PostgreSQL `docker exec -it socialnetwork-postgres-1 bash` и введите логин и пароль:
   - `psql -U social -d social`
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

Количество данных в обеих БД генерируется согласно значению SEED_COUNT из .env

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
