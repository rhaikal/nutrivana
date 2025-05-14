CREATE TABLE foods (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE ingredients (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE nutritions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password CHAR(60) NOT NULL,
    gender CHAR(1),
    date_of_birth DATE,
    weight INT,
    height INT,
    nutrition_status VARCHAR(10) CHECK (
        nutrition_status IN (
            'severely low',
            'low',
            'excessive',
            'possible risk of excessive',
            'good'
        )
    )
);

CREATE TABLE food_histories (
    id SERIAL PRIMARY KEY,
    f_id INT NOT NULL,
    u_id INT NOT NULL,
    date TIMESTAMP,
    FOREIGN KEY (f_id) REFERENCES foods (id),
    FOREIGN KEY (u_id) REFERENCES users (id)
);

CREATE TABLE food_ingredients (
    id SERIAL PRIMARY KEY,
    f_id INT NOT NULL,
    i_id INT NOT NULL,
    FOREIGN KEY (f_id) REFERENCES foods (id),
    FOREIGN KEY (i_id) REFERENCES ingredients (id),
    UNIQUE (f_id, i_id)
);

CREATE TABLE food_nutritions (
    id SERIAL PRIMARY KEY,
    f_id INT NOT NULL,
    n_id INT NOT NULL,
    value FLOAT NOT NULL,
    FOREIGN KEY (f_id) REFERENCES foods (id),
    FOREIGN KEY (n_id) REFERENCES nutritions (id),
    UNIQUE (f_id, n_id)
);

CREATE TABLE user_minimum_nutritions (
    id SERIAL PRIMARY KEY,
    u_id INT NOT NULL,
    n_id INT NOT NULL,
    value FLOAT NOT NULL,
    FOREIGN KEY (u_id) REFERENCES users (id),
    FOREIGN KEY (n_id) REFERENCES nutritions (id),
    UNIQUE (u_id, n_id)
);

CREATE OR REPLACE VIEW food_beverages AS
WITH
    ingredient_agg AS (
        SELECT
            fi.f_id,
            array_agg (i.id) AS i_ids,
            array_agg (i.name) AS i_names
        FROM
            food_ingredients fi
            JOIN ingredients i ON i.id = fi.i_id
        GROUP BY
            fi.f_id
    )
SELECT
    f.id AS f_id,
    f.name AS f_name,
    ia.i_ids,
    ia.i_names,
    MAX(
        CASE
            WHEN n.name = 'Calcium' THEN "fn".value
        END
    ) AS calcium,
    MAX(
        CASE
            WHEN n.name = 'Carbohydrate' THEN "fn".value
        END
    ) AS carbohydrate,
    MAX(
        CASE
            WHEN n.name = 'Energy' THEN "fn".value
        END
    ) AS energy,
    MAX(
        CASE
            WHEN n.name = 'Total Fat' THEN "fn".value
        END
    ) AS fat,
    MAX(
        CASE
            WHEN n.name = 'Iron' THEN "fn".value
        END
    ) AS iron,
    MAX(
        CASE
            WHEN n.name = 'Protein' THEN "fn".value
        END
    ) AS protein
FROM
    foods f
    JOIN ingredient_agg ia ON ia.f_id = f.id
    JOIN food_nutritions fn ON fn.f_id = f.id
    JOIN nutritions n ON n.id = fn.n_id
GROUP BY
    f.id,
    f.name,
    ia.i_ids,
    ia.i_names;