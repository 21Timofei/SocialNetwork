// Пользователи
LOAD CSV WITH HEADERS FROM 'file:///users.csv' AS row
CREATE (:Person {id: toInteger(row.id), name: row.name, email: row.email, created_at: row.created_at});

// Паблики
LOAD CSV WITH HEADERS FROM 'file:///publics.csv' AS row
CREATE (:Public {id: toInteger(row.id), name: row.name, description: row.description, created_at: row.created_at});

// Дружба
LOAD CSV WITH HEADERS FROM 'file:///friends.csv' AS row
MATCH (p1:Person {id: toInteger(row.person1_id)}), (p2:Person {id: toInteger(row.person2_id)})
MERGE (p1)-[:FRIEND {created_at: row.created_at}]->(p2)
MERGE (p2)-[:FRIEND {created_at: row.created_at}]->(p1);

// Подписка на людей
LOAD CSV WITH HEADERS FROM 'file:///followers.csv' AS row
MATCH (follower:Person {id: toInteger(row.follower_id)}), (following:Person {id: toInteger(row.following_id)})
MERGE (follower)-[:FOLLOWS {created_at: row.created_at}]->(following);

// Подписка на паблики
LOAD CSV WITH HEADERS FROM 'file:///public_subs.csv' AS row
MATCH (person:Person {id: toInteger(row.person_id)}), (pub:Public {id: toInteger(row.public_id)})
MERGE (person)-[:SUBSCRIBED_TO {created_at: row.created_at}]->(pub);
