TRUNCATE TABLE public_subs, followers, friends, publics, people RESTART IDENTITY CASCADE;

\copy people(id, name, email, created_at) FROM '/data/users.csv' WITH (FORMAT csv, HEADER true);
\copy publics(id, name, description, created_at) FROM '/data/publics.csv' WITH (FORMAT csv, HEADER true);
\copy friends(person1_id, person2_id, created_at) FROM '/data/friends.csv' WITH (FORMAT csv, HEADER true);
\copy followers(follower_id, following_id, created_at) FROM '/data/followers.csv' WITH (FORMAT csv, HEADER true);
\copy public_subs(person_id, public_id, created_at) FROM '/data/public_subs.csv' WITH (FORMAT csv, HEADER true);
