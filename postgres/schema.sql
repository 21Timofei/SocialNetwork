CREATE TABLE people (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE,
    created_at DATE
);

CREATE TABLE friends (
    person1_id INT NOT NULL,
    person2_id INT NOT NULL,
    created_at DATE,
    PRIMARY KEY (person1_id, person2_id),
    FOREIGN KEY (person1_id) REFERENCES people(id),
    FOREIGN KEY (person2_id) REFERENCES people(id)
);

CREATE TABLE followers (
    follower_id INT NOT NULL,
    following_id INT NOT NULL,
    created_at DATE,
    PRIMARY KEY(follower_id, following_id),
    FOREIGN KEY (follower_id) REFERENCES people(id),
    FOREIGN KEY (following_id) REFERENCES people(id)
);

CREATE TABLE publics (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at DATE
);

CREATE TABLE public_subs (
    person_id INT NOT NULL,
    public_id INT NOT NULL,
    created_at DATE,
    PRIMARY KEY (person_id, public_id),
    FOREIGN KEY (person_id) REFERENCES people(id),
    FOREIGN KEY (public_id) REFERENCES publics(id)
);
