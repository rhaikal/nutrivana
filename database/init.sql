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
    nutrition_status VARCHAR(50) CHECK (
        nutrition_status IN (
            'severely low',
            'low',
            'excessive',
            'possible risk of excessive',
            'good',
            'obese'
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
    weight FLOAT NOT NULL,
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

CREATE TABLE user_growth_records (
    id SERIAL PRIMARY KEY,
    u_id INT NOT NULL,
    weight INT,
    height INT,
    nutrition_status VARCHAR(50) CHECK (
        nutrition_status IN (
            'severely low',
            'low',
            'excessive',
            'possible risk of excessive',
            'good',
            'obese'
        )
    ),
    date TIMESTAMP
);

CREATE OR REPLACE VIEW food_beverages AS
WITH
    ingredient_agg AS (
        SELECT
            fi.f_id,
            array_agg(i.id::text) AS i_ids,
            array_agg(
                regexp_replace(
                    lower(trim(i.name)),
                    '[,\s]+', '_', 'g'
                )
            ) AS i_names
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
            WHEN n.name = 'calcium' THEN fn.value
        END
    ) AS calcium,
    MAX(
        CASE
            WHEN n.name = 'carbohydrate' THEN fn.value
        END
    ) AS carbohydrate,
    MAX(
        CASE
            WHEN n.name = 'energy' THEN fn.value
        END
    ) AS energy,
    MAX(
        CASE
            WHEN n.name = 'fat' THEN fn.value
        END
    ) AS fat,
    MAX(
        CASE
            WHEN n.name = 'iron' THEN fn.value
        END
    ) AS iron,
    MAX(
        CASE
            WHEN n.name = 'protein' THEN fn.value
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

-- Seeding

-- Foods Data
INSERT INTO
    public.foods (name)
VALUES ('Milk, NFS'),
    ('Milk, whole'),
    ('Milk, reduced fat (2%)'),
    ('Milk, low fat (1%)'),
    ('Milk, fat free (skim)'),
    (
        'Milk, lactose free, low fat (1%)'
    ),
    (
        'Milk, lactose free, fat free (skim)'
    ),
    (
        'Milk, lactose free, reduced fat (2%)'
    ),
    ('Milk, lactose free, whole'),
    ('Buttermilk');

INSERT INTO
    public.foods (name)
VALUES ('Kefir'),
    ('Goat milk'),
    (
        'Milk, dry, reconstituted, nonfat'
    ),
    (
        'Milk, dry, reconstituted, whole'
    ),
    (
        'Milk, evaporated, NS as to fat content'
    ),
    ('Milk, evaporated, whole'),
    (
        'Milk, evaporated, reduced fat (2%)'
    ),
    (
        'Milk, evaporated, fat free (skim)'
    ),
    ('Yogurt, NFS'),
    (
        'Yogurt, Greek, NS as to type of milk or flavor'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Yogurt, NS as to type of milk or flavor'
    ),
    (
        'Yogurt, NS as to type of milk, plain'
    ),
    ('Yogurt, whole milk, plain'),
    ('Yogurt, low fat milk, plain'),
    ('Yogurt, nonfat milk, plain'),
    (
        'Yogurt, Greek, NS as to type of milk, plain'
    ),
    (
        'Yogurt, Greek, whole milk, plain'
    ),
    (
        'Yogurt, Greek, low fat milk, plain'
    ),
    (
        'Yogurt, Greek, nonfat milk, plain'
    ),
    (
        'Yogurt, NS as to type of milk, fruit'
    );

INSERT INTO
    public.foods (name)
VALUES ('Yogurt, whole milk, fruit'),
    ('Yogurt, low fat milk, fruit'),
    ('Yogurt, nonfat milk, fruit'),
    (
        'Yogurt, Greek, NS as to type of milk, fruit'
    ),
    (
        'Yogurt, Greek, whole milk, fruit'
    ),
    (
        'Yogurt, Greek, low fat milk, fruit'
    ),
    (
        'Yogurt, Greek, nonfat milk, fruit'
    ),
    (
        'Yogurt, NS as to type of milk, flavors other than fruit'
    ),
    (
        'Yogurt, whole milk, flavors other than fruit'
    ),
    (
        'Yogurt, low fat milk, flavors other than fruit'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Yogurt, nonfat milk, flavors other than fruit'
    ),
    (
        'Yogurt, Greek, NS as to type of milk, flavors other than fruit'
    ),
    (
        'Yogurt, Greek, whole milk, flavors other than fruit'
    ),
    (
        'Yogurt, Greek, low fat milk, flavors other than fruit'
    ),
    (
        'Yogurt, Greek, nonfat milk, flavors other than fruit'
    ),
    ('Yogurt, Greek, with oats'),
    ('Yogurt, liquid'),
    ('Yogurt tube'),
    ('Yogurt parfait, with fruit'),
    ('Baby Toddler food, NFS');

INSERT INTO
    public.foods (name)
VALUES ('Baby Toddler yogurt, plain'),
    (
        'Baby Toddler yogurt, with fruit'
    ),
    ('Infant formula, NFS'),
    (
        'Infant formula, Similac, NFS'
    ),
    (
        'Infant formula, Similac Alimentum, ready-to-feed'
    ),
    (
        'Infant formula, Similac Alimentum, powder, made with water'
    ),
    (
        'Infant formula, Similac Advance, ready-to-feed'
    ),
    (
        'Infant formula, Similac Advance, powder, made with tap water'
    ),
    (
        'Infant formula, Similac Advance, powder, made with bottled water'
    ),
    (
        'Infant formula, Similac Advance, powder, made with baby water'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Infant formula, Similac Sensitive, ready-to-feed'
    ),
    (
        'Infant formula, Similac Sensitive, powder, made with tap water'
    ),
    (
        'Infant formula, Similac Sensitive, powder, made with bottled water'
    ),
    (
        'Infant formula, Similac Sensitive, powder, made with baby water'
    ),
    (
        'Infant formula, Similac for Spit-Up, ready-to-feed'
    ),
    (
        'Infant formula, Similac for Spit-Up, powder, made with water'
    ),
    (
        'Toddler formula, Similac Go and Grow'
    ),
    (
        'Infant formula, Enfamil, NFS'
    ),
    (
        'Infant formula, Enfamil Infant, ready-to-feed'
    ),
    (
        'Infant formula, Enfamil Infant, powder, made with tap water'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Infant formula, Enfamil Infant, powder, made with bottled water'
    ),
    (
        'Infant formula, Enfamil Infant, powder, made with baby water'
    ),
    (
        'Infant formula, Enfamil AR, ready-to-feed'
    ),
    (
        'Infant formula, Enfamil AR, powder, made with water'
    ),
    (
        'Infant formula, Enfamil Gentlease, ready-to-feed'
    ),
    (
        'Infant formula, Enfamil Gentlease, powder, made with tap water'
    ),
    (
        'Infant formula, Enfamil Gentlease, powder, made with bottled water'
    ),
    (
        'Infant formula, Enfamil Gentlease, powder, made with baby water'
    ),
    (
        'Toddler formula, Enfamil Enfagrow'
    ),
    ('Toddler formula, PediaSure');

INSERT INTO
    public.foods (name)
VALUES (
        'Toddler formula, Nido Kinder'
    ),
    (
        'Toddler formula, store brand, beginning or next stage'
    ),
    (
        'Toddler formula, store brand, pediatric shake'
    ),
    ('Infant formula, Gerber, NFS'),
    (
        'Infant formula, Gerber Good Start Gentle, Stage 1, ready-to-feed'
    ),
    (
        'Infant formula, Gerber Good Start Gentle, Stage 1, powder, made with tap water'
    ),
    (
        'Infant formula, Gerber Good Start Gentle, Stage 1, powder, made with bottled water'
    ),
    (
        'Infant formula, Gerber Good Start Gentle, Stage 1, powder, made with baby water'
    ),
    (
        'Infant formula, Gerber Good Start Gentle, Stage 2'
    ),
    (
        'Toddler formula, Gerber Good Start, Stage 3'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Infant formula, premature, powder, made with water'
    ),
    (
        'Infant formula, premature, ready-to-feed'
    ),
    (
        'Infant formula, organic, powder, made with water'
    ),
    (
        'Infant formula, organic, ready-to-feed'
    ),
    (
        'Infant formula, store brand, advantage or tender, powder, made with tap water'
    ),
    (
        'Infant formula, store brand, advantage or tender, powder, made with bottled water'
    ),
    (
        'Infant formula, store brand, advantage or tender, powder, made with baby water'
    ),
    (
        'Infant formula, store brand, gentle or sensitivity'
    ),
    (
        'Infant formula, store brand, added rice'
    ),
    (
        'Infant formula, Enfamil ProSobee, ready-to-feed'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Infant formula, Enfamil ProSobee, powder, made with tap water'
    ),
    (
        'Infant formula, Enfamil ProSobee, powder, made with bottled water'
    ),
    (
        'Infant formula, Enfamil ProSobee, powder, made with baby water'
    ),
    (
        'Infant formula, Similac Isomil Soy, ready-to-feed'
    ),
    (
        'Infant formula, Similac Isomil Soy, powder, made with tap water'
    ),
    (
        'Infant formula, Similac Isomil Soy, powder, made with bottled water'
    ),
    (
        'Infant formula, Similac Isomil Soy, powder, made with baby water'
    ),
    (
        'Infant formula, Similac for Diarrhea'
    ),
    (
        'Infant formula, Gerber Good Start Soy, Stage 1, ready-to-feed'
    ),
    (
        'Infant formula, Gerber Good Start Soy, Stage 1, powder, made with tap water'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Infant formula, Gerber Good Start Soy, Stage 1, powder, made with bottled water'
    ),
    (
        'Infant formula, Gerber Good Start Soy, Stage 1, powder, made with baby water'
    ),
    (
        'Infant formula, store brand, soy'
    ),
    (
        'Infant formula, Enfamil Nutramigen, ready-to-feed'
    ),
    (
        'Infant formula, Enfamil Nutramigen, powder, made with water'
    ),
    (
        'Infant formula, Enfamil Pregestimil, ready-to-feed'
    ),
    (
        'Infant formula, Enfamil Pregestimil, powder, made with water'
    ),
    ('Infant formula, amino acids'),
    ('Infant formula, low iron'),
    ('Pudding, chocolate, NFS');

INSERT INTO
    public.foods (name)
VALUES ('Pudding, bread'),
    (
        'Pudding, flavors other than chocolate, NFS'
    ),
    ('Custard'),
    ('Flan'),
    ('Creme brulee'),
    ('Pudding, rice'),
    ('Firni, Indian pudding'),
    (
        'Pudding, tapioca, made from dry mix'
    ),
    (
        'Pudding, flavors other than chocolate, made from dry mix'
    ),
    (
        'Pudding, chocolate, made from dry mix'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Pudding, flavors other than chocolate, made from dry mix, sugar free'
    ),
    (
        'Pudding, chocolate, made from dry mix, sugar free'
    ),
    (
        'Pudding, flavors other than chocolate, ready-to-eat'
    ),
    (
        'Pudding, flavors other than chocolate, ready-to-eat, sugar free'
    ),
    (
        'Pudding, chocolate, ready-to-eat'
    ),
    (
        'Pudding, chocolate, ready-to-eat, sugar free'
    ),
    (
        'Pudding, tapioca, ready-to-eat'
    ),
    ('Banana pudding'),
    ('Mousse'),
    ('Dulce de leche');

INSERT INTO
    public.foods (name)
VALUES (
        'Barfi or Burfi, Indian dessert'
    ),
    ('Trifle'),
    ('Cheese souffle'),
    ('Baby Toddler meat, NFS'),
    ('Baby Toddler beef'),
    ('Baby Toddler ham'),
    ('Baby Toddler meat stick'),
    ('Baby Toddler chicken'),
    ('Baby Toddler turkey'),
    ('Greens with ham or pork');

INSERT INTO
    public.foods (name)
VALUES ('Soup, meatball'),
    ('Soup, pho, with meat'),
    ('Soup, pho, no meat'),
    ('Soup, pepperpot'),
    ('Soup, beef, canned'),
    ('Soup, sopa or caldo de res'),
    ('Soup, pozole'),
    ('Soup, Italian wedding'),
    ('Soup, pork or ham'),
    ('Soup, broth');

INSERT INTO
    public.foods (name)
VALUES ('Soup, chicken, canned'),
    ('Soup, chicken'),
    (
        'Soup, sopa or caldo de pollo'
    ),
    ('Soup, hot and sour'),
    ('Soup, cream of chicken'),
    (
        'Soup, Manhattan clam chowder'
    ),
    (
        'Soup, New England clam chowder'
    ),
    ('Soup, bisque'),
    ('Soup, fish or shrimp'),
    ('Egg, whole, raw');

INSERT INTO
    public.foods (name)
VALUES (
        'Egg, whole, cooked, NS as to cooking method'
    ),
    (
        'Egg, whole, boiled or poached'
    ),
    (
        'Egg, whole, fried, NS as to fat'
    ),
    (
        'Egg, whole, fried no added fat'
    ),
    (
        'Egg, whole, fried with margarine'
    ),
    ('Egg, whole, fried with oil'),
    (
        'Egg, whole, fried with butter'
    ),
    (
        'Egg, whole, fried with animal fat or meat drippings'
    ),
    (
        'Egg, whole, fried with cooking spray'
    ),
    (
        'Egg, whole, fried, NS as to fat type'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Egg, whole, fried, from fast food / restaurant'
    ),
    (
        'Egg, whole, baked, NS as to fat'
    ),
    (
        'Egg, whole, baked, no added fat'
    ),
    (
        'Egg, whole, baked, fat added'
    ),
    ('Egg, whole, pickled'),
    ('Egg, white only, raw'),
    (
        'Egg, white, cooked, NS as to fat'
    ),
    (
        'Egg, white, cooked, no added fat'
    ),
    (
        'Egg, white, cooked, fat added'
    ),
    ('Egg, yolk only, raw');

INSERT INTO
    public.foods (name)
VALUES (
        'Egg, yolk only, cooked, NS as to fat'
    ),
    (
        'Egg, yolk only, cooked, no added fat'
    ),
    (
        'Egg, yolk only, cooked, fat added'
    ),
    ('Duck egg, cooked'),
    ('Goose egg, cooked'),
    ('Quail egg, canned'),
    ('Egg, creamed'),
    ('Egg, Benedict'),
    ('Egg, deviled'),
    (
        'Egg salad, made with mayonnaise'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Egg salad, made with light mayonnaise'
    ),
    (
        'Egg salad, made with mayonnaise-type salad dressing'
    ),
    (
        'Egg salad, made with light mayonnaise-type salad dressing'
    ),
    (
        'Egg salad, made with creamy dressing'
    ),
    (
        'Egg salad, made with light creamy dressing'
    ),
    (
        'Egg salad, made with Italian dressing'
    ),
    (
        'Egg salad, made with light Italian dressing'
    ),
    (
        'Egg Salad, made with any type of fat free dressing'
    ),
    ('Huevos rancheros'),
    (
        'Egg casserole with bread, cheese, milk and meat'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Egg omelet or scrambled egg, NS as to fat'
    ),
    (
        'Egg omelet or scrambled egg, made with margarine'
    ),
    (
        'Egg omelet or scrambled egg, made with oil'
    ),
    (
        'Egg omelet or scrambled egg, made with butter'
    ),
    (
        'Egg omelet or scrambled egg, made with animal fat or meat drippings'
    ),
    (
        'Egg omelet or scrambled egg, made with cooking spray'
    ),
    (
        'Egg omelet or scrambled egg, NS as to fat type'
    ),
    (
        'Egg omelet or scrambled egg, no added fat'
    ),
    (
        'Egg omelet or scrambled egg, from fast food / restaurant'
    ),
    (
        'Egg omelet or scrambled egg, with cheese, made with margarine'
    );

INSERT INTO
    public.foods (name)
VALUES ('Soup, egg drop'),
    (
        'Egg omelet or scrambled egg, with cheese, made with oil'
    ),
    (
        'Egg omelet or scrambled egg, with cheese, made with butter'
    ),
    (
        'Egg omelet or scrambled egg, with cheese, made with animal fat or meat drippings'
    ),
    (
        'Egg omelet or scrambled egg, with cheese, made with cooking spray'
    ),
    (
        'Egg omelet or scrambled egg, with cheese, no added fat'
    ),
    (
        'Egg omelet or scrambled egg, with meat, NS as to fat'
    ),
    (
        'Egg omelet or scrambled egg, with meat, made with margarine'
    ),
    (
        'Egg omelet or scrambled egg, with meat, made with oil'
    ),
    (
        'Egg omelet or scrambled egg, with meat, made with butter'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Egg omelet or scrambled egg, with meat, made with animal fat or meat drippings'
    ),
    (
        'Egg omelet or scrambled egg, with meat, made with cooking spray'
    ),
    (
        'Egg omelet or scrambled egg, with meat, NS as to fat type'
    ),
    (
        'Egg omelet or scrambled egg, with meat, no added fat'
    ),
    (
        'Egg omelet or scrambled egg, with cheese and meat, NS as to fat'
    ),
    (
        'Egg omelet or scrambled egg, with cheese and meat, made with margarine'
    ),
    (
        'Egg omelet or scrambled egg, with cheese and meat, made with oil'
    ),
    (
        'Egg omelet or scrambled egg, with cheese and meat, made with butter'
    ),
    (
        'Egg omelet or scrambled egg, with cheese and meat, made with animal fat or meat drippings'
    ),
    (
        'Egg omelet or scrambled egg, with cheese and meat, made with cooking spray'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Egg omelet or scrambled egg, with cheese and meat, NS as to fat type'
    ),
    (
        'Egg omelet or scrambled egg, with cheese and meat, no added fat'
    ),
    (
        'Egg omelet or scrambled egg, with tomatoes, fat added'
    ),
    (
        'Egg omelet or scrambled egg, with tomatoes, no added fat'
    ),
    (
        'Egg omelet or scrambled egg, with tomatoes, NS as to fat'
    ),
    (
        'Egg omelet or scrambled egg, with dark-green vegetables, fat added'
    ),
    (
        'Egg omelet or scrambled egg, with dark-green vegetables, no added fat'
    ),
    (
        'Egg omelet or scrambled egg, with dark-green vegetables, NS as to fat'
    ),
    (
        'Egg omelet or scrambled egg, with tomatoes and dark-green vegetables, fat added'
    ),
    (
        'Egg omelet or scrambled egg, with tomatoes and dark-green vegetables, no fat added'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Egg omelet or scrambled egg, with tomatoes and dark-green vegetables, NS as to fat'
    ),
    (
        'Egg omelet or scrambled egg, with vegetables other than dark green and/or tomatoes, fat added'
    ),
    (
        'Egg omelet or scrambled egg, with vegetables other than dark green and/or tomatoes, no added fat'
    ),
    (
        'Egg omelet or scrambled egg, with vegetables other than dark green and/or tomatoes, NS as to fat'
    ),
    (
        'Egg omelet or scrambled egg, with cheese and tomatoes, fat added'
    ),
    (
        'Egg omelet or scrambled egg, with cheese and tomatoes, no added fat'
    ),
    (
        'Egg omelet or scrambled egg, with cheese and tomatoes, NS as to fat'
    ),
    (
        'Egg omelet or scrambled egg, with cheese and dark-green vegetables, fat added'
    ),
    (
        'Egg omelet or scrambled egg, with cheese and dark-green vegetables, no added fat'
    ),
    (
        'Egg omelet or scrambled egg, with cheese and dark-green vegetables, NS as to fat'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Egg omelet or scrambled egg, with cheese, tomatoes, and dark-green vegetables, fat added'
    ),
    (
        'Egg omelet or scrambled egg, with cheese, tomatoes, and dark-green vegetables, no added fat'
    ),
    (
        'Egg omelet or scrambled egg, with cheese, tomatoes, and dark-green vegetables, NS as to fat'
    ),
    (
        'Egg omelet or scrambled egg, with cheese and vegetables other than dark green and/or tomatoes, fat added'
    ),
    (
        'Egg omelet or scrambled egg, with cheese and vegetables other than dark green and/or tomatoes, no added fat'
    ),
    (
        'Egg omelet or scrambled egg, with cheese and vegetables other than dark green and/or tomatoes, NS as to fat'
    ),
    (
        'Egg omelet or scrambled egg, with meat and tomatoes, fat added'
    ),
    (
        'Egg omelet or scrambled egg, with meat and tomatoes, no added fat'
    ),
    (
        'Egg omelet or scrambled egg, with meat and tomatoes, NS as to fat'
    ),
    (
        'Egg omelet or scrambled egg, with meat and dark-green vegetables, fat added'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Egg omelet or scrambled egg, with meat and dark-green vegetables, no added fat'
    ),
    (
        'Egg omelet or scrambled egg, with meat and dark-green vegetables, NS as to fat'
    ),
    (
        'Egg omelet or scrambled egg, with meat, tomatoes, and dark-green vegetables, fat added'
    ),
    (
        'Egg omelet or scrambled egg, with meat, tomatoes, and dark-green vegetables, no added fat'
    ),
    (
        'Egg omelet or scrambled egg, with meat, tomatoes, and dark-green vegetables, NS as to fat'
    ),
    (
        'Egg omelet or scrambled egg, with meat and vegetables other than dark-green and/or tomatoes, fat added'
    ),
    (
        'Egg omelet or scrambled egg, with meat and vegetables other than dark-green and/or tomatoes, no added fat'
    ),
    (
        'Egg omelet or scrambled egg, with meat and vegetables other than dark-green and/or tomatoes, NS as to fat'
    ),
    (
        'Egg omelet or scrambled egg, with cheese, meat, and tomatoes, fat added'
    ),
    (
        'Egg omelet or scrambled egg, with cheese, meat, and tomatoes, no added fat'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Egg omelet or scrambled egg, with cheese, meat, and tomatoes, NS as to fat'
    ),
    (
        'Egg omelet or scrambled egg, with cheese, meat, and dark-green vegetables, fat added'
    ),
    (
        'Egg omelet or scrambled egg, with cheese, meat, and dark-green vegetables, no added fat'
    ),
    (
        'Egg omelet or scrambled egg, with cheese, meat, and dark-green vegetables, NS as to fat'
    ),
    (
        'Egg omelet or scrambled egg, with cheese, meat, tomatoes, and dark-green vegetables, fat added'
    ),
    (
        'Egg omelet or scrambled egg, with cheese, meat, tomatoes, and dark-green vegetables, no added fat'
    ),
    (
        'Egg omelet or scrambled egg, with cheese, meat, tomatoes, and dark-green vegetables, NS as to fat'
    ),
    (
        'Egg omelet or scrambled egg, with cheese, meat, and vegetables other than dark-green and/or tomatoes, fat added'
    ),
    (
        'Egg omelet or scrambled egg, with cheese, meat, and vegetables other than dark-green and/or tomatoes, no added fat'
    ),
    (
        'Egg omelet or scrambled egg, with cheese, meat, and vegetables other than dark-green and/or tomatoes, NS as to fat'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Egg omelet or scrambled egg, with potatoes and/or onions, fat added'
    ),
    (
        'Egg omelet or scrambled egg, with potatoes and/or onions, no added fat'
    ),
    (
        'Egg omelet or scrambled egg, with potatoes and/or onions, NS as to fat'
    ),
    (
        'Egg white omelet, scrambled, or fried, NS as to fat'
    ),
    (
        'Egg white omelet, scrambled, or fried, made with margarine'
    ),
    (
        'Egg white omelet, scrambled, or fried, made with oil'
    ),
    (
        'Egg white omelet, scrambled, or fried, made with butter'
    ),
    (
        'Egg white omelet, scrambled, or fried, made with cooking spray'
    ),
    (
        'Egg white omelet, scrambled, or fried, NS as to fat type'
    ),
    (
        'Egg white omelet, scrambled, or fried, no added fat'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Egg white, omelet, scrambled, or fried, with cheese'
    ),
    (
        'Egg white, omelet, scrambled, or fried, with meat'
    ),
    (
        'Egg white, omelet, scrambled, or fried, with vegetables'
    ),
    (
        'Egg white, omelet, scrambled, or fried, with cheese and meat'
    ),
    (
        'Egg white, omelet, scrambled, or fried, with cheese and vegetables'
    ),
    (
        'Egg white, omelet, scrambled, or fried, with meat and vegetables'
    ),
    (
        'Egg white, omelet, scrambled, or fried, with cheese, meat, and vegetables'
    ),
    ('Meringues'),
    (
        'Egg substitute, omelet, scrambled, or fried, fat added'
    ),
    (
        'Egg substitute, omelet, scrambled, or fried, no added fat'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Egg substitute, omelet, scrambled, or fried, with cheese'
    ),
    (
        'Egg substitute, omelet, scrambled, or fried, with meat'
    ),
    (
        'Egg substitute, omelet, scrambled, or fried, with vegetables'
    ),
    (
        'Egg substitute, omelet, scrambled, or fried, with cheese and meat'
    ),
    (
        'Egg substitute, omelet, scrambled, or fried, with cheese and vegetables'
    ),
    (
        'Egg substitute, omelet, scrambled, or fried, with meat and vegetables'
    ),
    (
        'Egg substitute, omelet, scrambled, or fried, with cheese, meat, and vegetables'
    ),
    ('Beans, NFS'),
    (
        'Beans, from dried, NS as to type, fat added'
    ),
    (
        'Beans, from dried, NS as to type, no added fat'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Beans, from canned, NS as to type, fat added'
    ),
    (
        'Beans, from canned, NS as to type, no added fat'
    ),
    (
        'Beans, from fast food / restaurant, NS as to type'
    ),
    ('White beans, NFS'),
    (
        'White beans, from dried, fat added'
    ),
    (
        'White beans, from dried, no added fat'
    ),
    (
        'White beans, from canned, fat added'
    ),
    (
        'White beans, from canned, no added fat'
    ),
    (
        'White beans, from canned, reduced sodium'
    ),
    ('Black beans, NFS');

INSERT INTO
    public.foods (name)
VALUES (
        'Black beans, from dried, fat added'
    ),
    (
        'Black beans, from dried, no added fat'
    ),
    (
        'Black beans, from canned, fat added'
    ),
    (
        'Black beans, from canned, no added fat'
    ),
    (
        'Black beans, from canned, reduced sodium'
    ),
    (
        'Black beans, from fast food / restaurant'
    ),
    ('Black beans with meat'),
    ('Fava beans, cooked'),
    ('Lima beans, NFS'),
    ('Lima beans, from dried');

INSERT INTO
    public.foods (name)
VALUES ('Pink beans, cooked'),
    ('Pinto beans, NFS'),
    (
        'Pinto beans, from dried, fat added'
    ),
    (
        'Pinto beans, from dried, no added fat'
    ),
    (
        'Pinto beans, from canned, fat added'
    ),
    (
        'Pinto beans, from canned, no added fat'
    ),
    (
        'Pinto beans, from canned, reduced sodium'
    ),
    (
        'Pinto beans, from fast food / restaurant'
    ),
    ('Pinto beans with meat'),
    ('Kidney beans, NFS');

INSERT INTO
    public.foods (name)
VALUES (
        'Kidney beans, from dried, fat added'
    ),
    (
        'Kidney beans, from dried, no added fat'
    ),
    (
        'Kidney beans, from canned, fat added'
    ),
    (
        'Kidney beans, from canned, no added fat'
    ),
    (
        'Kidney beans, from canned, reduced sodium'
    ),
    (
        'Kidney beans, from fast food / restaurant'
    ),
    ('Kidney beans with meat'),
    ('Peruvian beans, from dried'),
    ('Soybeans, cooked'),
    ('Mung beans, cooked');

INSERT INTO
    public.foods (name)
VALUES ('Baked beans'),
    ('Baked beans, vegetarian'),
    (
        'Baked beans from fast food / restaurant'
    ),
    (
        'Beans and tomatoes, no added fat'
    ),
    (
        'Beans and tomatoes, fat added'
    ),
    ('Refried beans'),
    (
        'Refried beans, from fast food / restaurant'
    ),
    ('Refried beans with meat'),
    (
        'Refried beans, from canned, reduced sodium'
    ),
    ('Beans and franks');

INSERT INTO
    public.foods (name)
VALUES ('Pork and beans'),
    (
        'Beans with meat, NS as to type'
    ),
    ('Baked beans, reduced sodium'),
    ('Blackeyed peas, NFS'),
    ('Blackeyed peas, from dried'),
    ('Chickpeas, NFS'),
    (
        'Chickpeas, from dried, fat added'
    ),
    (
        'Chickpeas, from dried, no added fat'
    ),
    (
        'Chickpeas, from canned, fat added'
    ),
    (
        'Chickpeas, from canned, no added fat'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Chickpeas, from canned, reduced sodium'
    ),
    (
        'Split peas, from dried, no added fat'
    ),
    (
        'Split peas, from dried, fat added'
    ),
    ('Wasabi peas'),
    ('Lentils, NFS'),
    (
        'Lentils, from dried, fat added'
    ),
    (
        'Lentils, from dried, no added fat'
    ),
    ('Lentils, from canned'),
    ('Dal'),
    ('Papad, grilled or broiled');

INSERT INTO
    public.foods (name)
VALUES ('Sambar, vegetable stew'),
    ('Soy nuts'),
    ('Edamame, cooked'),
    ('Soup, bean'),
    ('Soup, bean, canned'),
    ('Soup, miso or tofu'),
    (
        'Soup, bean, canned, reduced sodium'
    ),
    ('Soup, bean, with meat'),
    ('Soup, split pea, with meat'),
    ('Soup, split pea');

INSERT INTO
    public.foods (name)
VALUES ('Soup, lentil, canned'),
    (
        'Soup, lentil, canned, reduced sodium'
    ),
    ('Soup, lentil'),
    ('Soup, lentil, with meat'),
    ('Soup, mulligatawany'),
    ('Vegetarian stew'),
    ('Veggie burger, on bun'),
    (
        'Veggie burger, on bun, with cheese'
    ),
    ('Falafel sandwich'),
    ('Soup, peanut');

INSERT INTO
    public.foods (name)
VALUES ('Coconut water, unsweetened'),
    ('Coconut water, sweetened'),
    ('Bruschetta'),
    ('Breadsticks, hard, NFS'),
    (
        'Breadsticks, hard, reduced sodium'
    ),
    ('Croutons'),
    ('Melba toast'),
    ('Zwieback toast'),
    (
        'Breadsticks, hard, whole wheat'
    ),
    (
        'Breadsticks, hard, gluten free'
    );

INSERT INTO
    public.foods (name)
VALUES ('Baby Toddler snack, NFS'),
    ('Baby Toddler bar'),
    ('Baby Toddler cookie'),
    ('Baby Toddler biscuit'),
    ('Crackers, NFS'),
    ('Crackers, oatmeal'),
    ('Crackers, breakfast biscuit'),
    (
        'Crackers, butter, reduced sodium'
    ),
    (
        'Crackers, matzo, reduced sodium'
    ),
    (
        'Crackers, wheat, reduced sodium'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Crackers, woven wheat, reduced sodium'
    ),
    ('Crackers, butter, plain'),
    ('Crackers, butter, flavored'),
    ('Crackers, butter (Ritz)'),
    (
        'Crackers, butter, reduced fat'
    ),
    ('Crackers, cheese'),
    ('Crackers, cheese (Cheez-It)'),
    ('Crackers, cheese (Goldfish)'),
    (
        'Crackers, cheese, reduced fat'
    ),
    (
        'Crackers, cheese, reduced sodium'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Crackers, cheese, whole grain'
    ),
    ('Crackers, crispbread'),
    ('Crackers, flatbread'),
    ('Crackers, matzo'),
    ('Crackers, milk'),
    ('Rice cake'),
    ('Crackers, rice'),
    ('Crackers, rice and nuts'),
    ('Popcorn cake'),
    ('Rice paper');

INSERT INTO
    public.foods (name)
VALUES ('Crackers, multigrain'),
    ('Crackers, sandwich'),
    (
        'Crackers, sandwich, peanut butter filled'
    ),
    (
        'Crackers, sandwich, peanut butter filled (Ritz)'
    ),
    (
        'Crackers, sandwich, reduced fat, peanut butter filled'
    ),
    (
        'Crackers, whole grain, sandwich, peanut butter filled'
    ),
    (
        'Crackers, sandwich, cheese filled'
    ),
    (
        'Crackers, sandwich, cheese filled (Ritz)'
    ),
    ('Crackers, water'),
    ('Crackers, wonton');

INSERT INTO
    public.foods (name)
VALUES ('Crackers, woven wheat'),
    (
        'Crackers, woven wheat, plain (Triscuit)'
    ),
    (
        'Crackers, woven wheat, flavored (Triscuit)'
    ),
    (
        'Crackers, woven wheat, reduced fat'
    ),
    ('Crackers, wheat'),
    (
        'Crackers, wheat, plain (Wheat Thins)'
    ),
    (
        'Crackers, wheat, flavored (Wheat Thins)'
    ),
    (
        'Crackers, wheat, reduced fat'
    ),
    (
        'Crackers, gluten free, plain'
    ),
    (
        'Crackers, gluten free, flavored'
    );

INSERT INTO
    public.foods (name)
VALUES ('Baby Toddler crackers'),
    ('Baby Toddler puffs, fruit'),
    (
        'Baby Toddler puffs, vegetable'
    ),
    ('Baby Toddler crunchies'),
    ('Baby Toddler wheels'),
    ('Pita chips'),
    ('Bagel chips'),
    ('Pasta, vegetable, cooked'),
    ('Noodles, cooked'),
    (
        'Noodles, whole grain, cooked'
    );

INSERT INTO
    public.foods (name)
VALUES ('Noodles, chow mein'),
    (
        'Long rice noodles, made from mung beans, cooked'
    ),
    ('Rice noodles, cooked'),
    ('Pasta, cooked'),
    ('Pasta, whole grain, cooked'),
    ('Pasta, gluten free'),
    ('Barley'),
    ('Buckwheat groats'),
    ('Millet'),
    ('Oatmeal, fast food, plain');

INSERT INTO
    public.foods (name)
VALUES (
        'Oatmeal, fast food, flavored'
    ),
    ('Oatmeal, NFS'),
    (
        'Oatmeal, regular or quick, made with water, no added fat'
    ),
    (
        'Oatmeal, regular or quick, made with water, fat added'
    ),
    (
        'Oatmeal, regular or quick, made with milk, no added fat'
    ),
    (
        'Oatmeal, regular or quick, made with milk, fat added'
    ),
    (
        'Oatmeal, regular or quick, made with non-dairy milk, no added fat'
    ),
    (
        'Oatmeal, regular or quick, made with non-dairy milk, fat added'
    ),
    (
        'Oatmeal, instant, plain, made with water, no added fat'
    ),
    (
        'Oatmeal, instant, plain, made with water, fat added'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Oatmeal, instant, plain, made with milk, no added fat'
    ),
    (
        'Oatmeal, instant, plain, made with milk, fat added'
    ),
    (
        'Oatmeal, instant, plain, made with non-dairy milk, no added fat'
    ),
    (
        'Oatmeal, instant, plain, made with non-dairy milk, fat added'
    ),
    (
        'Oatmeal, instant, maple flavored, no added fat'
    ),
    (
        'Oatmeal, instant, maple flavored, fat added'
    ),
    (
        'Oatmeal, instant, fruit flavored, no added fat'
    ),
    (
        'Oatmeal, instant, fruit flavored, fat added'
    ),
    ('Oatmeal, reduced sugar'),
    ('Oatmeal, multigrain');

INSERT INTO
    public.foods (name)
VALUES ('Quinoa, NS as to fat'),
    ('Quinoa, no added fat'),
    ('Quinoa, fat added'),
    ('Rice, cooked, NFS'),
    (
        'Rice, white, cooked, NS as to fat'
    ),
    (
        'Rice, white, cooked, made with oil'
    ),
    (
        'Rice, white, cooked, made with butter'
    ),
    (
        'Rice, white, cooked, made with margarine'
    ),
    (
        'Rice, white, cooked, fat added, NS as to fat type'
    ),
    (
        'Rice, white, cooked, no added fat'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Rice, brown, cooked, NS as to fat'
    ),
    (
        'Rice, brown, cooked, fat added, made with oil'
    ),
    (
        'Rice, brown, cooked, made with butter'
    ),
    (
        'Rice, brown, cooked, made with margarine'
    ),
    (
        'Rice, brown, cooked, fat added, NS as to fat type'
    ),
    (
        'Rice, brown, cooked, no added fat'
    ),
    ('Rice, cooked, with milk'),
    (
        'Rice, sweet, cooked with honey'
    ),
    ('Congee'),
    (
        'Yellow rice, cooked, NS as to fat'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Yellow rice, cooked, no added fat'
    ),
    (
        'Yellow rice, cooked, fat added'
    ),
    (
        'Rice, white, cooked, glutinous'
    ),
    (
        'Rice, wild, 100%, cooked, NS as to fat'
    ),
    (
        'Rice, wild, 100%, cooked, no added fat'
    ),
    (
        'Rice, wild, 100%, cooked, fat added'
    ),
    (
        'Rice, white and wild, cooked, no added fat'
    ),
    (
        'Rice, brown and wild, cooked, no added fat'
    ),
    (
        'Rice, white and wild, cooked, fat added'
    ),
    (
        'Rice, white and wild, cooked, NS as to fat'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Rice, brown and wild, cooked, fat added'
    ),
    (
        'Rice, brown and wild, cooked, NS as to fat'
    ),
    (
        'Rice, white, cooked with fat, Puerto Rican style'
    ),
    ('Bulgur, no added fat'),
    ('Bulgur, fat added'),
    ('Bulgur, NS as to fat'),
    ('Couscous, plain, cooked'),
    (
        'Baby Toddler cereal, barley, dry'
    ),
    (
        'Baby Toddler cereal, oatmeal, dry'
    ),
    (
        'Baby Toddler cereal, rice, dry'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Baby Toddler cereal, rice with fruit, dry'
    ),
    (
        'Baby Toddler cereal, multigrain with fruit, dry'
    ),
    (
        'Baby Toddler cereal, multigrain, dry'
    ),
    (
        'Baby Toddler cereal, oatmeal with fruit, dry'
    ),
    ('Baby Toddler cereal, NFS'),
    (
        'Baby Toddler cereal, rice, ready-to-eat'
    ),
    (
        'Baby Toddler cereal, oatmeal, ready-to-eat'
    ),
    (
        'Baby Toddler cereal, multigrain, ready-to-eat'
    ),
    (
        'Baby Toddler cereal, multigrain with fruit, ready-to-eat'
    ),
    (
        'Baby Toddler cereal, oatmeal with fruit, ready-to-eat'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Baby Toddler cereal, rice with fruit, ready-to-eat'
    ),
    (
        'Soupy rice with chicken, Puerto Rican style'
    ),
    (
        'Soupy rice mixture with chicken and potatoes, Puerto Rican style'
    ),
    ('Stuffed pepper, with meat'),
    (
        'Stuffed pepper, with rice and meat'
    ),
    (
        'Stuffed pepper, with rice, meatless'
    ),
    (
        'Stuffed tomato, with rice and meat'
    ),
    (
        'Stuffed tomato, with rice, meatless'
    ),
    ('Vegetable sandwich on white'),
    (
        'Vegetable sandwich on white, with cheese'
    );

INSERT INTO
    public.foods (name)
VALUES ('Vegetable sandwich on wheat'),
    (
        'Vegetable sandwich on wheat, with cheese'
    ),
    ('Vegetable sandwich wrap'),
    ('Soup, NFS'),
    ('Soup, noodle, NFS'),
    ('Soup, rice'),
    ('Soup, barley'),
    (
        'Soup, chicken noodle, canned'
    ),
    ('Soup, chicken noodle'),
    (
        'Soup, chicken, canned, reduced sodium'
    );

INSERT INTO
    public.foods (name)
VALUES ('Soup, Matzo ball'),
    (
        'Soup, ramen noodles, water added'
    ),
    ('Ramen bowl, NFS'),
    ('Ramen bowl with beef'),
    ('Ramen bowl with chicken'),
    ('Ramen bowl with fish'),
    ('Ramen bowl, vegetarian'),
    (
        'Ramen bowl with meat and egg'
    ),
    (
        'Ramen bowl, vegetarian with egg'
    ),
    ('Soup, wonton');

INSERT INTO
    public.foods (name)
VALUES ('Soup, sopa de fideo aguada'),
    ('Soup, tortilla'),
    ('Clementine, raw'),
    ('Grapefruit, raw'),
    ('Grapefruit, canned'),
    ('Kumquat, raw'),
    ('Lemon, raw'),
    ('Lime, raw'),
    ('Orange, raw'),
    ('Orange, canned, NFS');

INSERT INTO
    public.foods (name)
VALUES ('Orange, canned, juice pack'),
    ('Orange, canned, in syrup'),
    ('Tangerine, raw'),
    (
        'Fruit juice blend, citrus, 100% juice'
    ),
    ('Fruit, NFS'),
    ('Fruit, pickled'),
    ('Apple, raw'),
    ('Applesauce, regular'),
    ('Applesauce, unsweetened'),
    ('Applesauce, flavored');

INSERT INTO
    public.foods (name)
VALUES ('Apple pie filling'),
    ('Apple, baked'),
    ('Apricot, raw'),
    ('Apricot, canned'),
    ('Avocado, raw'),
    ('Banana, raw'),
    ('Banana, baked'),
    ('Cantaloupe, raw'),
    ('Melon, frozen'),
    ('Starfruit, raw');

INSERT INTO
    public.foods (name)
VALUES ('Cherries, maraschino'),
    ('Cherries, raw'),
    ('Cherries, canned'),
    ('Cherries, frozen'),
    ('Dragon fruit'),
    ('Fig, raw'),
    ('Fig, canned'),
    ('Guava, raw'),
    ('Kiwi fruit, raw'),
    ('Lychee');

INSERT INTO
    public.foods (name)
VALUES ('Honeydew melon, raw'),
    ('Mango, raw'),
    ('Mango, canned'),
    ('Mango, frozen'),
    ('Nectarine, raw'),
    ('Papaya, raw'),
    ('Papaya, canned'),
    ('Passion fruit, raw'),
    ('Peach, raw'),
    ('Peach, canned, NFS');

INSERT INTO
    public.foods (name)
VALUES ('Peach, canned, in syrup'),
    ('Peach, canned, juice pack'),
    ('Peach, frozen'),
    ('Pear, raw'),
    ('Pear, Asian, raw'),
    ('Pear, canned, NFS'),
    ('Pear, canned, in syrup'),
    ('Pear, canned, juice pack'),
    ('Persimmon, raw'),
    ('Plum, raw');

INSERT INTO
    public.foods (name)
VALUES ('Plum, canned'),
    ('Pomegranate, raw'),
    ('Rhubarb'),
    ('Tamarind'),
    ('Watermelon, raw'),
    ('Berries, NFS'),
    ('Berries, frozen'),
    ('Blackberries, raw'),
    ('Blackberries, frozen'),
    ('Blueberries, raw');

INSERT INTO
    public.foods (name)
VALUES ('Bluberries, canned'),
    ('Blueberries, frozen'),
    ('Cranberries, raw'),
    ('Cranberry sauce'),
    ('Raspberries, raw'),
    ('Raspberries, frozen'),
    ('Strawberries, raw'),
    ('Strawberries, canned'),
    ('Strawberries, frozen'),
    ('Ambrosia');

INSERT INTO
    public.foods (name)
VALUES (
        'Fruit salad, fresh or raw, excluding citrus fruits, no dressing'
    ),
    (
        'Snowpeas, NS as to form, cooked'
    ),
    (
        'Fruit salad, fresh or raw, including citrus fruits, no dressing'
    ),
    ('Fruit cocktail, canned, NFS'),
    (
        'Fruit cocktail, canned, in syrup'
    ),
    (
        'Fruit cocktail, canned, juice pack'
    ),
    ('Fruit mixture, frozen'),
    ('Apple salad with dressing'),
    ('Apple, candied'),
    ('Fruit, chocolate covered');

INSERT INTO
    public.foods (name)
VALUES (
        'Fruit salad, excluding citrus fruits, with salad dressing or mayonnaise'
    ),
    (
        'Fruit salad, excluding citrus fruits, with whipped cream'
    ),
    (
        'Fruit salad, excluding citrus fruits, with nondairy whipped topping'
    ),
    (
        'Fruit salad, excluding citrus fruits, with marshmallows'
    ),
    (
        'Fruit salad, including citrus fruits, with pudding'
    ),
    (
        'Fruit salad, excluding citrus fruits, with pudding'
    ),
    (
        'Fruit salad, including citrus fruits, with salad dressing or mayonnaise'
    ),
    (
        'Fruit salad, including citrus fruit, with whipped cream'
    ),
    (
        'Fruit salad, including citrus fruits, with nondairy whipped topping'
    ),
    (
        'Fruit salad, including citrus fruits, with marshmallows'
    );

INSERT INTO
    public.foods (name)
VALUES ('Lime souffle'),
    (
        'Pineapple salad with dressing'
    ),
    ('Soup, fruit'),
    ('Fruit juice, NFS'),
    (
        'Fruit juice blend, 100% juice'
    ),
    (
        'Cranberry juice blend, 100% juice'
    ),
    (
        'Cranberry juice blend, 100% juice, with calcium added'
    ),
    ('Blackberry juice, 100%'),
    ('Blueberry juice'),
    (
        'Cranberry juice, 100%, not a blend'
    );

INSERT INTO
    public.foods (name)
VALUES ('Grape juice, 100%'),
    (
        'Grape juice, 100%, with calcium added'
    ),
    ('Papaya juice, 100%'),
    ('Passion fruit juice, 100%'),
    ('Pineapple juice, 100%'),
    ('Pomegranate juice, 100%'),
    ('Prune juice, 100%'),
    ('Strawberry juice, 100%'),
    ('Watermelon juice, 100%'),
    ('Fruit nectar, NFS');

INSERT INTO
    public.foods (name)
VALUES ('Apricot nectar'),
    ('Banana nectar'),
    ('Cantaloupe nectar'),
    ('Guava nectar'),
    ('Mango nectar'),
    ('Peach nectar'),
    ('Papaya nectar'),
    ('Passion fruit nectar'),
    ('Pear nectar'),
    ('Soursop, nectar');

INSERT INTO
    public.foods (name)
VALUES ('Baby Toddler fruit, NFS'),
    (
        'Baby Toddler multiple fruit, Stage 2'
    ),
    (
        'Baby Toddler multiple fruit, Stage 3'
    ),
    (
        'Baby Toddler fruit, with grain'
    ),
    (
        'Baby Toddler fruit, with yogurt'
    ),
    (
        'Baby Toddler fruit and vegetables, Stage 2'
    ),
    (
        'Baby Toddler fruit and vegetables, Stage 3'
    ),
    (
        'Baby Toddler fruit and vegetables, with grain'
    ),
    (
        'Baby Toddler fruit and vegetables, with yogurt'
    ),
    (
        'Baby Toddler fruit, vegetables, and meat'
    );

INSERT INTO
    public.foods (name)
VALUES ('Baby Toddler fruit and meat'),
    (
        'Baby Toddler apples, Stage 1'
    ),
    (
        'Baby Toddler apples, Stage 2'
    ),
    (
        'Baby Toddler bananas, Stage 1'
    ),
    (
        'Baby Toddler bananas, Stage 2'
    ),
    (
        'Baby Toddler peaches, Stage 1'
    ),
    (
        'Baby Toddler peaches, Stage 2'
    ),
    ('Baby Toddler pears, Stage 1'),
    ('Baby Toddler pears, Stage 2'),
    ('Baby Toddler prunes');

INSERT INTO
    public.foods (name)
VALUES ('Baby Toddler mangoes'),
    ('Baby Toddler juice, NFS'),
    ('Baby Toddler juice, apple'),
    ('Baby Toddler juice, grape'),
    (
        'Baby Toddler juice, mixed fruit'
    ),
    ('Baby Toddler juice, pear'),
    (
        'Baby Toddler juice, fruit and vegetable'
    ),
    (
        'Baby Toddler juice, fruit and yogurt blend'
    ),
    ('Baby Toddler pudding'),
    ('Baby Toddler yogurt melts');

INSERT INTO
    public.foods (name)
VALUES (
        'Stewed potatoes, Puerto Rican style'
    ),
    (
        'Potato from Puerto Rican style stuffed pot roast, with gravy'
    ),
    (
        'Potato from Puerto Rican beef stew, with gravy'
    ),
    (
        'Potato from Puerto Rican chicken fricassee, with sauce'
    ),
    ('Potato, scalloped, NFS'),
    (
        'Potato, scalloped, from fast food or restaurant'
    ),
    (
        'Potato, scalloped, from fresh'
    ),
    (
        'Potato, scalloped, from fresh, with meat'
    ),
    (
        'Potato, scalloped, from dry mix'
    ),
    (
        'Potato, scalloped, from dry mix, with meat'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Potato, scalloped, ready-to-heat'
    ),
    (
        'Potato, scalloped, ready-to-heat, with meat'
    ),
    ('Potato, mashed, NFS'),
    (
        'Potato, mashed, from fast food'
    ),
    (
        'Potato, mashed, from fast food, with gravy'
    ),
    (
        'Potato, mashed, ready-to-heat'
    ),
    (
        'Potato, mashed, from fresh, made with milk'
    ),
    (
        'Potato, mashed, from fresh, made with milk, with cheese'
    ),
    (
        'Potato, mashed, from fresh, made with milk, with gravy'
    ),
    (
        'Potato, mashed, from fresh, NFS'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Potato, mashed, from restaurant'
    ),
    (
        'Potato, mashed, from restaurant, with gravy'
    ),
    (
        'Potato, mashed, from school lunch'
    ),
    (
        'Potato, mashed, from dry mix, NFS'
    ),
    (
        'Potato, mashed, from dry mix, made with milk'
    ),
    (
        'Potato, mashed, from dry mix, made with milk, with cheese'
    ),
    (
        'Potato, mashed, from dry mix, made with milk, with gravy'
    ),
    (
        'Potato, mashed, ready-to-heat, NFS'
    ),
    (
        'Potato, mashed, ready-to-heat, with cheese'
    ),
    (
        'Potato, mashed, ready-to-heat, with gravy'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Potato salad with egg, from restaurant'
    ),
    (
        'Potato salad with egg, made with mayonnaise'
    ),
    (
        'Potato salad with egg, made with light mayonnaise'
    ),
    (
        'Potato salad with egg, made with mayonnaise-type salad dressing'
    ),
    (
        'Potato salad with egg, made with light mayonnaise-type salad dressing'
    ),
    (
        'Potato salad with egg, made with creamy dressing'
    ),
    (
        'Potato salad with egg, made with light creamy dressing'
    ),
    (
        'Potato salad with egg, made with Italian dressing'
    ),
    (
        'Potato salad with egg, made with light Italian dressing'
    ),
    (
        'Potato salad with egg, made with any type of fat free dressing'
    );

INSERT INTO
    public.foods (name)
VALUES ('Potato salad, German style'),
    (
        'Potato salad, from restaurant'
    ),
    (
        'Potato salad, made with mayonnaise'
    ),
    (
        'Potato salad, made with light mayonnaise'
    ),
    (
        'Potato salad, made with mayonnaise-type salad dressing'
    ),
    (
        'Potato salad, made with light mayonnaise-type salad dressing'
    ),
    (
        'Potato salad, made with creamy dressing'
    ),
    (
        'Potato salad, made with light creamy dressing'
    ),
    (
        'Potato salad, made with Italian dressing'
    ),
    (
        'Potato salad, made with light Italian dressing'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Potato salad, made with any type of fat free dressing'
    ),
    ('Potato pancake'),
    ('Lefse'),
    ('Stewed potatoes'),
    (
        'Stewed potatoes with tomatoes'
    ),
    ('Soup, potato'),
    ('Soup, potato with meat'),
    (
        'Plantain, cooked, no added fat'
    ),
    ('Plantain, cooked with oil'),
    ('Plantain, raw');

INSERT INTO
    public.foods (name)
VALUES (
        'Plantain, cooked, fat added, NS as to fat type'
    ),
    (
        'Plantain, cooked with butter or margarine'
    ),
    ('Cassava, cooked'),
    ('Yuca fries'),
    ('Taro, cooked'),
    ('Fufu'),
    ('Beet greens, raw'),
    ('Beet greens, cooked'),
    ('Broccoli raab, raw'),
    ('Broccoli raab, cooked');

INSERT INTO
    public.foods (name)
VALUES ('Chard, raw'),
    ('Chard, cooked'),
    ('Collards, raw'),
    (
        'Collards, fresh, cooked, no added fat'
    ),
    (
        'Collards, frozen, cooked, no added fat'
    ),
    (
        'Collards, NS as to form, cooked'
    ),
    (
        'Collards, fresh, cooked, fat added, NS as to fat type'
    ),
    (
        'Collards, frozen, cooked, fat added, NS as to fat type'
    ),
    (
        'Collards, fresh, cooked with oil'
    ),
    (
        'Collards, fresh, cooked with butter or margarine'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Collards, frozen, cooked with oil'
    ),
    (
        'Collards, frozen, cooked with butter or margarine'
    ),
    ('Cress, raw'),
    ('Cress, cooked'),
    ('Dandelion greens, raw'),
    ('Dandelion greens, cooked'),
    ('Escarole, cooked'),
    (
        'Greens, fresh, cooked, no added fat'
    ),
    (
        'Greens, frozen, cooked, no added fat'
    ),
    (
        'Greens, NS as to form, cooked'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Greens, fresh, cooked, fat added'
    ),
    (
        'Greens, frozen, cooked, fat added'
    ),
    ('Greens, canned, cooked'),
    ('Kale, raw'),
    (
        'Kale, fresh, cooked, no added fat'
    ),
    (
        'Kale, frozen, cooked, no added fat'
    ),
    ('Kale, NS as to form, cooked'),
    (
        'Kale, fresh, cooked, fat added'
    ),
    (
        'Kale, frozen, cooked, fat added'
    ),
    ('Lambsquarter, cooked');

INSERT INTO
    public.foods (name)
VALUES ('Mustard greens, raw'),
    (
        'Mustard greens, fresh, cooked, no added fat'
    ),
    (
        'Mustard greens, frozen, cooked, no added fat'
    ),
    (
        'Mustard greens, NS as to form, cooked'
    ),
    (
        'Mustard greens, fresh, cooked, fat added'
    ),
    (
        'Mustard greens, frozen, cooked, fat added'
    ),
    ('Poke greens, cooked'),
    ('Spinach, raw'),
    (
        'Spinach, fresh, cooked, no added fat'
    ),
    (
        'Spinach, frozen, cooked, no added fat'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Spinach, canned, cooked, no added fat'
    ),
    (
        'Spinach, fresh, cooked with oil'
    ),
    (
        'Spinach, fresh, cooked with butter or margarine'
    ),
    (
        'Spinach, NS as to form, cooked'
    ),
    (
        'Spinach, fresh, cooked, fat added, NS as to fat type'
    ),
    (
        'Spinach, frozen, cooked, fat added, NS as to fat type'
    ),
    (
        'Spinach, canned, cooked, fat added, NS as to fat type'
    ),
    (
        'Spinach, frozen, cooked with oil'
    ),
    (
        'Spinach, frozen, cooked with butter or margarine'
    ),
    (
        'Spinach, canned, cooked with oil'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Spinach, canned, cooked with butter or margarine'
    ),
    ('Spinach, creamed'),
    ('Spinach souffle'),
    (
        'Spinach and cheese casserole'
    ),
    ('Palak Paneer'),
    ('Channa Saag'),
    ('Taro leaves, cooked'),
    (
        'Turnip greens, fresh, cooked, no added fat'
    ),
    (
        'Turnip greens, frozen, cooked, no added fat'
    ),
    (
        'Turrnip greens, NS as to form, cooked'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Turnip greens, fresh, cooked, fat added'
    ),
    (
        'Turnip greens, frozen, cooked, fat added'
    ),
    ('Watercress, raw'),
    ('Watercress, cooked'),
    (
        'Bitter melon, horseradish, jute, or radish leaves, cooked'
    ),
    (
        'Sweet potato, squash, pumpkin, chrysanthemum, or bean leaves, cooked'
    ),
    ('Broccoli, raw'),
    (
        'Broccoli, cooked, from restaurant'
    ),
    (
        'Broccoli, fresh, cooked, no added fat'
    ),
    (
        'Broccoli, frozen, cooked, no added fat'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Broccoli, NS as to form, cooked'
    ),
    (
        'Broccoli, fresh, cooked, fat added, NS as to fat type'
    ),
    (
        'Broccoli, frozen, cooked, fat added, NS as to fat type'
    ),
    (
        'Broccoli, fresh, cooked with oil'
    ),
    (
        'Broccoli, fresh, cooked with butter or margarine'
    ),
    (
        'Broccoli, frozen, cooked with oil'
    ),
    (
        'Broccoli, frozen, cooked with butter or margarine'
    ),
    (
        'Broccoli casserole with noodles'
    ),
    (
        'Broccoli casserole with rice'
    ),
    ('Fried broccoli');

INSERT INTO
    public.foods (name)
VALUES ('Broccoli, chinese, raw'),
    ('Broccoli, Chinese, cooked'),
    ('Soup, broccoli cheese'),
    ('Carrots, raw'),
    (
        'Carrots, cooked, from restaurant'
    ),
    (
        'Carrots, fresh, cooked, no added fat'
    ),
    (
        'Carrots, frozen, cooked, no added fat'
    ),
    (
        'Carrots, canned, cooked, no added fat'
    ),
    (
        'Carrots, fresh, cooked with oil'
    ),
    (
        'Carrots, fresh, cooked with butter or margarine'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Carrots, NS as to form, cooked'
    ),
    (
        'Carrots, fresh, cooked, fat added, NS as to fat type'
    ),
    (
        'Carrots, frozen, cooked, fat added, NS as to fat type'
    ),
    (
        'Carrots, canned, cooked, fat added, NS as to fat type'
    ),
    (
        'Carrots, frozen, cooked with oil'
    ),
    (
        'Carrots, frozen, cooked with butter or margarine'
    ),
    (
        'Carrots, canned, cooked with oil'
    ),
    (
        'Carrots, canned, cooked with butter or margarine'
    ),
    ('Carrots, glazed, cooked'),
    (
        'Carrots, canned, reduced sodium, cooked, no added fat'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Carrots, canned, reduced sodium, cooked, fat added, NS as to fat type'
    ),
    (
        'Carrots, canned, reduced sodium, cooked with oil'
    ),
    (
        'Carrots, canned, reduced sodium, cooked with butter or margarine'
    ),
    (
        'Peas and carrots, fresh, cooked, no added fat'
    ),
    (
        'Peas and carrots, frozen, cooked, no added fat'
    ),
    (
        'Peas and carrots, canned, cooked, no added fat'
    ),
    (
        'Peas and carrots, cooked, NS as to form'
    ),
    (
        'Peas and carrots, fresh, cooked, fat added'
    ),
    (
        'Peas and carrots, frozen, cooked, fat added'
    ),
    (
        'Peas and carrots, canned, cooked, fat added'
    );

INSERT INTO
    public.foods (name)
VALUES ('Pumpkin, canned, cooked'),
    ('Pumpkin, cooked'),
    ('Winter squash, raw'),
    (
        'Winter squash, cooked, no added fat'
    ),
    (
        'Winter squash, cooked, fat added'
    ),
    ('Squash, winter, souffle'),
    ('Sweet potato, NFS'),
    (
        'Sweet potato, baked, NS as to fat'
    ),
    (
        'Sweet potato, baked, no added fat'
    ),
    (
        'Sweet potato, baked, fat added'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Sweet potato, boiled, NS as to fat'
    ),
    (
        'Sweet potato, boiled, no added fat'
    ),
    (
        'Sweet potato, boiled, fat added'
    ),
    ('Sweet potato, candied'),
    (
        'Sweet potato, canned, NS as to fat'
    ),
    (
        'Sweet potato, canned, no added fat'
    ),
    (
        'Sweet potato, canned, fat added'
    ),
    (
        'Sweet potato, casserole or mashed'
    ),
    ('Sweet potato fries, NFS'),
    ('Sweet potato fries, frozen');

INSERT INTO
    public.foods (name)
VALUES (
        'Sweet potato fries, from fresh'
    ),
    (
        'Sweet potato fries, fast food / restaurant'
    ),
    ('Sweet potato fries, school'),
    ('Sweet potato tots'),
    (
        'Sweet potato tots, fast food / restaurant'
    ),
    ('Sweet potato tots, school'),
    ('Soup, pumpkin'),
    ('Tomatoes, scalloped'),
    ('Fried green tomatoes'),
    ('Tomato, green, pickled');

INSERT INTO
    public.foods (name)
VALUES ('Soup, tomato'),
    ('Soup, cream of tomato'),
    ('Soup, tomato, canned'),
    (
        'Soup, tomato, canned / carton, reduced sodium'
    ),
    ('Tomato sandwich on white'),
    ('Tomato sandwich on wheat'),
    ('Raw vegetable, NFS'),
    ('Sprouts, NFS'),
    ('Alfalfa sprouts, raw'),
    ('Artichoke');

INSERT INTO
    public.foods (name)
VALUES ('Asparagus, raw'),
    ('Bean sprouts, raw'),
    ('Green beans, raw'),
    ('Beets, raw'),
    ('Broccoflower, raw'),
    ('Brussels sprouts, raw'),
    ('Cactus, raw'),
    ('Cauliflower, raw'),
    ('Celery, raw'),
    ('Fennel bulb, raw');

INSERT INTO
    public.foods (name)
VALUES ('Corn, raw'),
    ('Cucumber, raw'),
    ('Eggplant, raw'),
    ('Jicama, raw'),
    ('Kohlrabi, raw'),
    ('Mushrooms, raw'),
    ('Green peas, raw'),
    ('Peppers, raw, NFS'),
    ('Peppers, sweet, green, raw'),
    ('Peppers, sweet, red, raw');

INSERT INTO
    public.foods (name)
VALUES ('Peppers, banana, raw'),
    ('Radish'),
    ('Rutabaga, raw'),
    ('Seaweed, raw'),
    ('Snowpeas, raw'),
    ('Summer squash, yellow, raw'),
    ('Summer squash, green, raw'),
    ('Turnip, raw'),
    (
        'Lettuce, wilted, with bacon dressing'
    ),
    (
        'Seven-layer salad, lettuce salad made with a combination of onion, celery, green pepper, peas, mayonnaise, cheese, eggs, and/or bacon'
    );

INSERT INTO
    public.foods (name)
VALUES ('Greek Salad, no dressing'),
    ('Spinach salad, no dressing'),
    ('Cobb salad, no dressing'),
    ('Aloe vera juice drink'),
    (
        'Asparagus, fresh, cooked, no added fat'
    ),
    (
        'Asparagus, frozen, cooked, no added fat'
    ),
    (
        'Asparagus, canned, cooked, no added fat'
    ),
    (
        'Asparagus, NS as to form, cooked'
    ),
    (
        'Asparagus, fresh, cooked, fat added, NS as to fat type'
    ),
    (
        'Asparagus, frozen, cooked, fat added, NS as to fat type'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Asparagus, canned, cooked, fat added, NS as to fat type'
    ),
    (
        'Asparagus, fresh, cooked with oil'
    ),
    (
        'Asparagus, fresh, cooked with butter or margarine'
    ),
    (
        'Asparagus, frozen, cooked with oil'
    ),
    (
        'Asparagus, frozen, cooked with butter or margarine'
    ),
    (
        'Asparagus, canned, cooked with oil'
    ),
    (
        'Asparagus, canned, cooked with butter or margarine'
    ),
    ('Bamboo shoots, cooked'),
    (
        'Lima beans, from frozen, no added fat'
    ),
    (
        'Lima beans, from frozen, fat added'
    );

INSERT INTO
    public.foods (name)
VALUES ('Lima beans, from canned'),
    (
        'Green beans, cooked, from restaurant'
    ),
    (
        'Green beans, fresh, cooked, no added fat'
    ),
    (
        'Green beans, frozen, cooked, no added fat'
    ),
    (
        'Green beans, canned, cooked, no added fat'
    ),
    (
        'Green beans, NS as to form, cooked'
    ),
    (
        'Green beans, fresh, cooked, fat added, NS as to fat type'
    ),
    (
        'Green beans, frozen, cooked, fat added, NS as to fat type'
    ),
    (
        'Green beans, canned, cooked, fat added, NS as to fat type'
    ),
    (
        'Green beans, fresh, cooked with oil'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Green beans, fresh, cooked with butter or margarine'
    ),
    (
        'Green beans, frozen, cooked with oil'
    ),
    (
        'Green beans, frozen, cooked with butter or margarine'
    ),
    (
        'Green beans, canned, cooked with oil'
    ),
    (
        'Green beans, canned, cooked with butter or margarine'
    ),
    (
        'Green beans, canned, reduced sodium, cooked, no added fat'
    ),
    (
        'Green beans, canned, reduced sodium, cooked, fat added, NS as to fat type'
    ),
    (
        'Green beans, canned, reduced sodium, cooked with oil'
    ),
    (
        'Green beans, canned, reduced sodium, cooked with butter or margarine'
    ),
    ('Fried green beans');

INSERT INTO
    public.foods (name)
VALUES ('Yellow string beans, cooked'),
    ('Bean sprouts, cooked'),
    (
        'Beets, fresh, cooked, no added fat'
    ),
    (
        'Beets, canned, cooked, no added fat'
    ),
    (
        'Beets, NS as to form, cooked'
    ),
    (
        'Beets, fresh, cooked, fat added'
    ),
    (
        'Beets, canned, cooked, fat added'
    ),
    (
        'Beets, canned, reduced sodium, cooked'
    ),
    ('Bitter melon, cooked'),
    ('Breadfruit, cooked');

INSERT INTO
    public.foods (name)
VALUES ('Broccoflower, cooked'),
    (
        'Brussels sprouts, fresh, cooked, no added fat'
    ),
    (
        'Brussels sprouts, frozen, cooked, no added fat'
    ),
    (
        'Brussels sprouts, NS as to form, cooked'
    ),
    (
        'Brussels sprouts, fresh, cooked, fat added'
    ),
    (
        'Brussels sprouts, frozen, cooked, fat added'
    ),
    ('Burdock, cooked'),
    (
        'Cactus, cooked, no added fat'
    ),
    ('Cactus, cooked, fat added'),
    (
        'Cauliflower, fresh, cooked, no added fat'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Cauliflower, frozen, cooked, no added fat'
    ),
    (
        'Cauliflower, NS as to form, cooked'
    ),
    (
        'Cauliflower, fresh, cooked, fat added, NS as to fat type'
    ),
    (
        'Cauliflower, frozen, cooked, fat added, NS as to fat type'
    ),
    (
        'Cauliflower, fresh, cooked with oil'
    ),
    (
        'Cauliflower, fresh, cooked with butter or margarine'
    ),
    (
        'Cauliflower, frozen, cooked with oil'
    ),
    (
        'Cauliflower, frozen, cooked with butter or margarine'
    ),
    ('Celery, cooked'),
    ('Fennel bulb, cooked');

INSERT INTO
    public.foods (name)
VALUES ('Christophine, cooked'),
    (
        'Corn, cooked, from restaurant'
    ),
    (
        'Corn, fresh, cooked, no added fat'
    ),
    (
        'Corn, frozen, cooked, no added fat'
    ),
    (
        'Corn, canned, cooked, no added fat'
    ),
    ('Corn, NS as to form, cooked'),
    (
        'Corn, fresh, cooked, fat added, NS as to fat type'
    ),
    (
        'Corn, frozen, cooked, fat added, NS as to fat type'
    ),
    (
        'Corn, canned, cooked, fat added, NS as to fat type'
    ),
    (
        'Corn, fresh, cooked with oil'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Corn, fresh, cooked with butter or margarine'
    ),
    (
        'Corn, frozen, cooked with oil'
    ),
    (
        'Corn, frozen, cooked with butter or margarine'
    ),
    (
        'Corn, canned, cooked with oil'
    ),
    (
        'Corn, canned, cooked with butter or margarine'
    ),
    ('Corn, creamed'),
    (
        'Corn, canned, reduced sodium, cooked, no added fat'
    ),
    (
        'Corn, canned, reduced sodium, cooked, fat added, NS as to fat type'
    ),
    (
        'Corn, canned, reduced sodium, cooked with oil'
    ),
    (
        'Corn, canned, reduced sodium, cooked with butter or margarine'
    );

INSERT INTO
    public.foods (name)
VALUES ('Cucumber, cooked'),
    (
        'Eggplant, cooked, no added fat'
    ),
    ('Eggplant, cooked, fat added'),
    (
        'Flowers or blossoms of sesbania, squash, or lily, cooked'
    ),
    ('Kohlrabi, cooked'),
    ('Lotus root, cooked'),
    (
        'Mushrooms, fresh, cooked, no added fat'
    ),
    (
        'Mushrooms, NS as to form, cooked'
    ),
    (
        'Mushrooms, fresh, cooked, fat added, NS as to fat type'
    ),
    ('Mushrooms, canned, cooked');

INSERT INTO
    public.foods (name)
VALUES (
        'Mushrooms, fresh, cooked with oil'
    ),
    (
        'Mushrooms, fresh, cooked with butter or margarine'
    ),
    (
        'Mushroom, Asian, cooked, from dried'
    ),
    (
        'Okra, fresh, cooked, no added fat'
    ),
    (
        'Okra, frozen, cooked, no added fat'
    ),
    ('Okra, NS as to form, cooked'),
    (
        'Okra, fresh, cooked, fat added'
    ),
    (
        'Okra, frozen, cooked, fat added'
    ),
    ('Palm hearts, cooked'),
    ('Parsnips, cooked');

INSERT INTO
    public.foods (name)
VALUES ('Blackeyed peas, from frozen'),
    ('Blackeyed peas, from canned'),
    (
        'Green peas, cooked, from restaurant'
    ),
    (
        'Green peas, fresh, cooked, no added fat'
    ),
    (
        'Green peas, frozen, cooked, no added fat'
    ),
    (
        'Green peas, canned, cooked, no added fat'
    ),
    (
        'Green peas, NS as to form, cooked'
    ),
    (
        'Green peas, fresh, cooked, fat added, NS as to fat type'
    ),
    (
        'Green peas, frozen, cooked, fat added, NS as to fat type'
    ),
    (
        'Green peas, canned, cooked, fat added, NS as to fat type'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Green peas, fresh, cooked with oil'
    ),
    (
        'Green peas, fresh, cooked with butter or margarine'
    ),
    (
        'Green peas, frozen, cooked with oil'
    ),
    (
        'Green peas, frozen, cooked with butter or margarine'
    ),
    (
        'Green peas, canned, cooked with oil'
    ),
    (
        'Green peas, canned, cooked with butter or margarine'
    ),
    (
        'Green peas, canned, reduced sodium, cooked, no added fat'
    ),
    (
        'Green peas, canned, reduced sodium, cooked, fat added, NS as to fat type'
    ),
    (
        'Green peas, canned, reduced sodium, cooked with oil'
    ),
    (
        'Green peas, canned, reduced sodium, cooked with butter or margarine'
    );

INSERT INTO
    public.foods (name)
VALUES ('Peppers, green, cooked'),
    ('Peppers, red, cooked'),
    ('Rutabaga, cooked'),
    ('Salsify, cooked'),
    ('Sauerkraut'),
    (
        'Snowpeas, fresh, cooked, no added fat'
    ),
    (
        'Snowpeas, frozen, cooked, no added fat'
    ),
    (
        'Snowpeas, fresh, cooked, fat added'
    ),
    (
        'Snowpeas, frozen, cooked, fat added'
    ),
    (
        'Seaweed, cooked, no added fat'
    );

INSERT INTO
    public.foods (name)
VALUES ('Seaweed, cooked, fat added'),
    (
        'Summer squash, yellow or green, fresh, cooked, no added fat'
    ),
    (
        'Summer squash, yellow or green, frozen, cooked, no added fat'
    ),
    (
        'Summer squash, yellow or green, NS as to form, cooked'
    ),
    (
        'Summer squash, yellow or green, fresh, cooked, fat added, NS as to fat type'
    ),
    (
        'Summer squash, yellow or green, frozen, cooked, fat added, NS as to fat type'
    ),
    (
        'Summer squash, yellow or green, canned, cooked, fat added, NS as to fat type'
    ),
    (
        'Summer squash, yellow or green, fresh, cooked with oil'
    ),
    (
        'Summer squash, yellow or green, fresh, cooked with butter or margarine'
    ),
    (
        'Summer squash, yellow or green, frozen, cooked with oil'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Summer squash, yellow or green, frozen, cooked with butter or margarine'
    ),
    ('Spaghetti squash, cooked'),
    ('Turnip, cooked'),
    ('Water Chesnut'),
    ('Winter melon, cooked'),
    (
        'Lima beans and corn, cooked, no added fat'
    ),
    (
        'Lima beans and corn, cooked, fat added'
    ),
    (
        'Peppers and onions, cooked, no added fat'
    ),
    (
        'Peppers and onions, cooked, fat added'
    ),
    (
        'Classic mixed vegetables, cooked, from restaurant'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Classic mixed vegetables, frozen, cooked, no added fat'
    ),
    (
        'Classic mixed vegetables, canned, cooked, no added fat'
    ),
    (
        'Classic mixed vegetables, NS as to form, cooked'
    ),
    (
        'Classic mixed vegetables, frozen, cooked, fat added, NS as to fat type'
    ),
    (
        'Classic mixed vegetables, canned, cooked, fat added, NS as to fat type'
    ),
    (
        'Classic mixed vegetables, frozen, cooked with oil'
    ),
    (
        'Classic mixed vegetables, frozen, cooked with butter or margarine'
    ),
    (
        'Classic mixed vegetables, canned, cooked with oil'
    ),
    (
        'Classic mixed vegetables, canned, cooked with butter or margarine'
    ),
    (
        'Classic mixed vegetables, canned, reduced sodium, cooked, no added fat'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Classic mixed vegetables, canned, reduced sodium, cooked, fat added, NS as to fat type'
    ),
    (
        'Classic mixed vegetables, canned, reduced sodium, cooked with oil'
    ),
    (
        'Classic mixed vegetables, canned, reduced sodium, cooked with butter or margarine'
    ),
    (
        'Peas and corn, cooked, no added fat'
    ),
    (
        'Peas and corn, cooked, fat added'
    ),
    ('Ratatouille'),
    (
        'Vegetables, stew type, cooked, fat added'
    ),
    (
        'Vegetables, stew type, cooked, no added fat'
    ),
    (
        'Broccoli and cauliflower, cooked, no added fat'
    ),
    (
        'Broccoli and cauliflower, cooked, fat added'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Broccoli, cauliflower and carrots, cooked, no added fat'
    ),
    (
        'Broccoli, cauliflower and carrots, cooked, fat added'
    ),
    (
        'Asian stir fry vegetables, cooked, no added fat'
    ),
    (
        'Asian stir fry vegetables, cooked, fat added'
    ),
    ('Jai, Monk''s Food'),
    ('Artichokes, stuffed'),
    ('Green bean casserole'),
    ('Fried cauliflower'),
    ('Corn, scalloped or pudding'),
    ('Fried eggplant');

INSERT INTO
    public.foods (name)
VALUES (
        'Eggplant parmesan casserole, regular'
    ),
    (
        'Eggplant with cheese and tomato sauce'
    ),
    ('Mushrooms, stuffed'),
    ('Fried mushrooms'),
    ('Fried okra'),
    ('Fried onion rings'),
    (
        'Fried summer squash, yellow or green'
    ),
    (
        'Squash, summer, casserole with tomato and cheese'
    ),
    (
        'Squash, summer, casserole, with rice and tomato sauce'
    ),
    (
        'Squash, summer, casserole, with cheese sauce'
    );

INSERT INTO
    public.foods (name)
VALUES ('Squash, summer, souffle'),
    ('Stew, vegetable'),
    ('Vegetable tempura'),
    ('Pakora'),
    ('Vegetable curry'),
    ('Vegetable curry with rice'),
    ('Green beans, pickled'),
    ('Beets, pickled'),
    ('Celery, pickled'),
    ('Relish, corn');

INSERT INTO
    public.foods (name)
VALUES ('Cauliflower, pickled'),
    ('Cabbage, green, pickled'),
    ('Cabbage, red, pickled'),
    ('Kimchi'),
    ('Pickles, dill'),
    ('Relish, pickle'),
    ('Pickles, sweet'),
    ('Eggplant, pickled'),
    ('Ginger root, pickled'),
    ('Mushrooms, pickled');

INSERT INTO
    public.foods (name)
VALUES ('Okra, pickled'),
    ('Olives, NFS'),
    ('Olives, green'),
    ('Olives, black'),
    ('Olives, stuffed'),
    ('Olive tapenade'),
    ('Peppers, sweet, pickled'),
    ('Peppers, hot, pickled'),
    ('Peppers, jalapenos'),
    ('Pickles, NFS');

INSERT INTO
    public.foods (name)
VALUES ('Pickles, fried'),
    ('Radishes, pickled'),
    ('Seaweed, pickled'),
    ('Vegetables, pickled'),
    ('Turnip, pickled'),
    ('Zucchini, pickled'),
    ('Soup, borscht'),
    ('Soup, gazpacho'),
    ('Soup, cream of mushroom'),
    ('Soup, French onion');

INSERT INTO
    public.foods (name)
VALUES ('Soup, cream of vegetable'),
    ('Soup, seaweed'),
    ('Soup, vegetable, canned'),
    (
        'Soup, vegetable, canned, reduced sodium'
    ),
    ('Soup, vegetable'),
    ('Soup, minestrone'),
    ('Soup, beef'),
    ('Soup, vegetable, with meat'),
    ('Baby Toddler vegetable, NFS'),
    (
        'Baby Toddler carrots, Stage 1'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Baby Toddler carrots, Stage 2'
    ),
    (
        'Baby Toddler squash, Stage 1'
    ),
    (
        'Baby Toddler squash, Stage 2'
    ),
    (
        'Baby Toddler sweet potatoes, Stage 1'
    ),
    (
        'Baby Toddler sweet potatoes, Stage 2'
    ),
    (
        'Baby Toddler green beans, Stage 1'
    ),
    (
        'Baby Toddler green beans, Stage 2'
    ),
    ('Baby Toddler beets'),
    (
        'Baby Toddler multiple vegetables, Stage 2'
    ),
    (
        'Baby Toddler multiple vegetables, Stage 3'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Baby Toddler vegetables, with grain'
    ),
    (
        'Baby Toddler vegetables and meat'
    ),
    ('Baby Toddler peas, Stage 1'),
    ('Baby Toddler peas, Stage 2'),
    ('Toddler meal, NFS'),
    (
        'Toddler meal, meat and vegetables'
    ),
    (
        'Toddler meal, rice and vegetables'
    ),
    ('Toddler meal, pasta'),
    (
        'Toddler meal, pasta and vegetables'
    ),
    (
        'Fried stuffed potatoes, Puerto Rican style'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Green plantain with cracklings, Puerto Rican style'
    ),
    (
        'Vegetable and fruit juice, 100% juice, with high vitamin C'
    ),
    ('Haupia'),
    (
        'Fruit juice drink, citrus, carbonated'
    ),
    (
        'Fruit juice drink, noncitrus, carbonated'
    ),
    ('Fruit juice drink'),
    ('Tamarind drink'),
    (
        'Fruit punch, made with fruit juice and soda'
    ),
    ('Lemonade, fruit juice drink'),
    (
        'Lemonade, fruit flavored drink'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Lemonade, frozen concentrate, not reconstituted'
    ),
    ('Fruit flavored drink'),
    ('Pina Colada, nonalcoholic'),
    ('Margarita mix, nonalcoholic'),
    ('Slush frozen drink'),
    (
        'Fruit flavored drink, with high vitamin C'
    ),
    (
        'Cranberry juice drink, with high vitamin C'
    ),
    (
        'Fruit juice drink, with high vitamin C'
    ),
    (
        'Vegetable and fruit juice drink, with high vitamin C'
    ),
    ('Fruit juice drink (Sunny D)');

INSERT INTO
    public.foods (name)
VALUES (
        'Fruit flavored drink, powdered, reconstituted'
    ),
    (
        'Fruit flavored drink, with high vitamin C, powdered, reconstituted'
    ),
    (
        'Fruit juice drink, with high vitamin C, light'
    ),
    ('Fruit juice drink, light'),
    ('Fruit juice drink, diet'),
    (
        'Cranberry juice drink, with high vitamin C, light'
    ),
    ('Grape juice drink, light'),
    (
        'Orange juice beverage, 40-50% juice, light'
    ),
    (
        'Apple juice beverage, 40-50% juice, light'
    ),
    (
        'Lemonade, fruit juice drink, light'
    );

INSERT INTO
    public.foods (name)
VALUES (
        'Pomegranate juice beverage, 40-50% juice, light'
    ),
    (
        'Vegetable and fruit juice drink, with high vitamin C, light'
    ),
    (
        'Fruit juice drink (Capri Sun)'
    ),
    (
        'Fruit juice drink, added calcium (Sunny D)'
    ),
    ('Sugar cane beverage'),
    ('Wine, nonalcoholic'),
    ('Beer, nonalcoholic'),
    ('Shirley Temple'),
    ('Water, baby'),
    ('Fruit juice, acai blend');

-- Ingredients Data
INSERT INTO
    public.ingredients (name)
VALUES ('Butter, stick, salted'),
    ('Butter oil, anhydrous'),
    ('Cheese, cheddar'),
    (
        'Cottage cheese, full fat, large or small curd'
    ),
    (
        'Cheese, feta, whole milk, crumbled'
    ),
    ('Cheese, gruyere'),
    (
        'Cheese, mozzarella, low moisture, part-skim'
    ),
    ('Cheese, parmesan, grated'),
    ('Cheese, ricotta, whole milk'),
    (
        'Cheese spread, pasteurized process, American'
    );

INSERT INTO
    public.ingredients (name)
VALUES ('Cream, fluid, half and half'),
    (
        'Cream, fluid, light (coffee cream or table cream)'
    ),
    ('Cream, heavy'),
    (
        'Cream, whipped, cream topping, pressurized'
    ),
    (
        'Dessert topping, semi solid, frozen'
    ),
    (
        'Milk, whole, 3.25% milkfat, with added vitamin D'
    ),
    (
        'Milk, reduced fat, fluid, 2% milkfat, with added vitamin A and vitamin D'
    ),
    (
        'Milk, lowfat, fluid, 1% milkfat, with added vitamin A and vitamin D'
    ),
    (
        'Milk, nonfat, fluid, with added vitamin A and vitamin D (fat free or skim)'
    ),
    ('Buttermilk, low fat');

INSERT INTO
    public.ingredients (name)
VALUES (
        'Milk, dry, whole, with added vitamin D'
    ),
    (
        'Milk, dry, nonfat, regular, without added vitamin A and vitamin D'
    ),
    (
        'Milk, canned, evaporated, with added vitamin D and without added vitamin A'
    ),
    (
        'Milk, canned, evaporated, nonfat, with added vitamin A and vitamin D'
    ),
    (
        'Milk, goat, fluid, with added vitamin D'
    ),
    ('Yogurt, plain, whole milk'),
    ('Yogurt, plain, low fat'),
    (
        'Eggs, Grade A, Large, egg whole'
    ),
    (
        'Eggs, Grade A, Large, egg white'
    ),
    (
        'Eggs, Grade A, Large, egg yolk'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Egg, whole, cooked, hard-boiled'
    ),
    ('Egg, whole, dried'),
    (
        'Egg, duck, whole, fresh, raw'
    ),
    (
        'Egg, goose, whole, fresh, raw'
    ),
    (
        'Egg, quail, whole, fresh, raw'
    ),
    ('Butter, stick, unsalted'),
    (
        'Milk, dry, nonfat, regular, with added vitamin A and vitamin D'
    ),
    (
        'Cheese sauce, prepared from recipe'
    ),
    ('Dulce de Leche'),
    (
        'Egg substitute, liquid or frozen, fat free'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Yogurt, Greek, plain, nonfat'
    ),
    (
        'Kefir, lowfat, plain, LIFEWAY'
    ),
    (
        'Kefir, lowfat, strawberry, LIFEWAY'
    ),
    (
        'Yogurt, Greek, plain, whole milk'
    ),
    ('Spices, chili powder'),
    ('Spices, cinnamon, ground'),
    (
        'Spices, coriander leaf, dried'
    ),
    ('Spices, cumin seed'),
    (
        'Spices, mustard seed, ground'
    ),
    ('Spices, nutmeg, ground');

INSERT INTO
    public.ingredients (name)
VALUES ('Spices, paprika'),
    ('Spices, parsley, dried'),
    ('Spices, pepper, black'),
    (
        'Spices, pepper, red or cayenne'
    ),
    ('Spices, thyme, dried'),
    ('Spices, turmeric, ground'),
    ('Basil, fresh'),
    ('Mustard, prepared, yellow'),
    ('Salt, table'),
    ('Vinegar, cider');

INSERT INTO
    public.ingredients (name)
VALUES (
        'Vanilla extract, imitation, no alcohol'
    ),
    ('Vinegar, distilled'),
    (
        'Babyfood, meat, beef, strained'
    ),
    (
        'Babyfood, meat, ham, strained'
    ),
    (
        'Babyfood, meat, chicken, strained'
    ),
    (
        'Babyfood, meat, turkey, strained'
    ),
    (
        'Babyfood, meat, turkey sticks, junior'
    ),
    (
        'Babyfood, finger snacks, GERBER, GRADUATES, PUFFS, apple and cinnamon'
    ),
    (
        'Babyfood, water, bottled, GERBER, without added fluoride'
    ),
    (
        'Babyfood, macaroni and cheese, toddler'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Babyfood, vegetables, green beans, junior'
    ),
    (
        'Babyfood, vegetables, beets, strained'
    ),
    (
        'Babyfood, vegetables, carrots, strained'
    ),
    (
        'Babyfood, vegetables, carrots, junior'
    ),
    (
        'Babyfood, vegetables, squash, strained'
    ),
    (
        'Babyfood, vegetables, squash, junior'
    ),
    (
        'Babyfood, vegetables, sweet potatoes strained'
    ),
    (
        'Babyfood, vegetables, sweet potatoes, junior'
    ),
    ('Babyfood, potatoes, toddler'),
    (
        'Babyfood, fruit, applesauce, strained'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Babyfood, fruit, applesauce, junior'
    ),
    (
        'Babyfood, vegetables, corn, creamed, strained'
    ),
    (
        'Babyfood, vegetables, peas, strained'
    ),
    (
        'Babyfood, vegetables, spinach, creamed, strained'
    ),
    (
        'Babyfood, fruit, peaches, strained'
    ),
    (
        'Babyfood, fruit, peaches, junior'
    ),
    (
        'Babyfood, fruit, pears, strained'
    ),
    (
        'Babyfood, fruit, pears, junior'
    ),
    (
        'Babyfood, prunes, without vitamin c, strained'
    ),
    ('Babyfood, juice, apple');

INSERT INTO
    public.ingredients (name)
VALUES (
        'Babyfood, cereal, barley, dry fortified'
    ),
    (
        'Babyfood, cereal, oatmeal, dry fortified'
    ),
    (
        'Babyfood, cereal, rice, dry fortified'
    ),
    ('Babyfood, cookies'),
    (
        'Babyfood, GERBER, GRADUATES Lil Biscuits Vanilla Wheat'
    ),
    ('Zwieback'),
    (
        'Babyfood, dessert, custard pudding, vanilla, junior'
    ),
    (
        'Babyfood, snack, GERBER, GRADUATES, YOGURT MELTS'
    ),
    (
        'Infant formula, MEAD JOHNSON, PREGESTIMIL, with iron, powder, with ARA and DHA, not reconstituted'
    ),
    (
        'Infant formula, ABBOTT NUTRITION, SIMILAC, PM 60/40, powder not reconstituted'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Infant formula, MEAD JOHNSON, ENFAMIL, NUTRAMIGEN WITH LGG, with iron, powder, not reconstituted, with ARA and DHA'
    ),
    (
        'Infant formula, MEAD JOHNSON, ENFAMIL, PROSOBEE, with iron, powder, not reconstituted, with ARA and DHA'
    ),
    (
        'Child formula, ABBOTT NUTRITION, PEDIASURE, ready-to-feed'
    ),
    (
        'Infant formula, NESTLE, GOOD START SOY, with ARA and DHA, powder'
    ),
    (
        'Infant formula, ABBOTT NUTRITION, SIMILAC, ALIMENTUM, ADVANCE, ready-to-feed, with ARA and DHA'
    ),
    (
        'Infant formula, MEAD JOHNSON, ENFAMIL, AR, powder, with ARA and DHA'
    ),
    (
        'Infant formula, ABBOTT NUTRITION, SIMILAC NEOSURE, ready-to-feed, with ARA and DHA'
    ),
    (
        'Infant formula, ABBOTT NUTRITION, SIMILAC, SENSITIVE, (LACTOSE FREE), powder, with ARA and DHA'
    ),
    (
        'Infant formula, ABBOTT NUTRITION, SIMILAC, ADVANCE, with iron, powder, not reconstituted'
    ),
    (
        'Infant formula, ABBOTT NUTRITION, SIMILAC, ISOMIL, ADVANCE with iron, powder, not reconstituted'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Infant Formula, MEAD JOHNSON, ENFAMIL, ENFACARE, ready-to-feed, with ARA and DHA'
    ),
    (
        'Babyfood, fortified cereal bar, fruit filling'
    ),
    (
        'Toddler formula, MEAD JOHNSON, ENFAGROW, Toddler Transitions, with ARA and DHA, powder'
    ),
    (
        'Infant Formula, MEAD JOHNSON, ENFAMIL, GENTLEASE, with ARA and DHA powder not reconstituted'
    ),
    (
        'Infant formula, ABBOTT NUTRITION, SIMILAC, Expert Care, Diarrhea, ready- to- feed with ARA and DHA'
    ),
    (
        'Babyfood, Multigrain whole grain cereal, dry fortified'
    ),
    (
        'Babyfood, Baby MUM MUM Rice Biscuits'
    ),
    (
        'Babyfood, Snack, GERBER, GRADUATES, LIL CRUNCHIES, baked whole grain corn snack'
    ),
    (
        'Infant formula, ABBOTT NUTRITION, SIMILAC, For Spit Up, powder, with ARA and DHA'
    ),
    ('Lard');

INSERT INTO
    public.ingredients (name)
VALUES (
        'Salad dressing, mayonnaise type, regular, with salt'
    ),
    (
        'Salad dressing, italian dressing, commercial, reduced fat'
    ),
    (
        'Salad dressing, mayonnaise, regular'
    ),
    ('Oil, soybean'),
    (
        'Salad dressing, italian dressing, commercial, regular'
    ),
    (
        'Shortening industrial, soybean (hydrogenated) and cottonseed'
    ),
    ('Oil, canola'),
    ('Animal fat, bacon grease'),
    (
        'Salad dressing, ranch dressing, regular'
    ),
    (
        'Salad dressing, mayonnaise, light'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Oil, PAM cooking spray, original'
    ),
    (
        'Chicken, broiler, rotisserie, BBQ, thigh, meat and skin'
    ),
    (
        'Soup, beef broth or bouillon canned, ready-to-serve'
    ),
    (
        'Soup, cream of mushroom, canned, condensed'
    ),
    (
        'Gravy, beef, canned, ready-to-serve'
    ),
    (
        'Gravy, chicken, canned or bottled, ready-to-serve'
    ),
    (
        'Sauce, salsa, ready-to-serve'
    ),
    (
        'Soup, chicken broth, ready-to-serve'
    ),
    (
        'Soup, ramen noodle, any flavor, dry'
    ),
    (
        'Sauce, tomato chili sauce, bottled, with salt'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Pork sausage, link/patty, cooked, pan-fried'
    ),
    (
        'Cereals, oats, regular and quick, not fortified, dry'
    ),
    (
        'Cereals, oats, instant, fortified, plain, dry'
    ),
    (
        'Cereals, QUAKER, QUAKER MultiGrain Oatmeal, dry'
    ),
    (
        'Cereals, oats, instant, fortified, maple and brown sugar, dry'
    ),
    (
        'Apples, raw, with skin (Includes foods for USDA''s Food Distribution Program)'
    ),
    (
        'Apples, dried, sulfured, uncooked'
    ),
    (
        'Apple juice, frozen concentrate, unsweetened, undiluted, without added ascorbic acid'
    ),
    ('Apricots, raw'),
    (
        'Apricots, canned, water pack, with skin, solids and liquids'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Apricot nectar, canned, with added ascorbic acid'
    ),
    (
        'Avocados, raw, all commercial varieties'
    ),
    (
        'Bananas, ripe and slightly ripe, raw'
    ),
    (
        'Bananas, dehydrated, or banana powder'
    ),
    ('Blackberries, raw'),
    ('Blackberry juice, canned'),
    (
        'Blackberries, frozen, unsweetened'
    ),
    ('Blueberries, raw'),
    (
        'Blueberries, frozen, unsweetened (Includes foods for USDA''s Food Distribution Program)'
    ),
    ('Breadfruit, raw');

INSERT INTO
    public.ingredients (name)
VALUES ('Carambola, (starfruit), raw'),
    (
        'Cherries, sweet, dark red, raw'
    ),
    (
        'Cherries, sweet, canned, water pack, solids and liquids'
    ),
    ('Cranberries, raw'),
    (
        'Cranberry sauce, canned, sweetened'
    ),
    ('Figs, raw'),
    (
        'Fruit cocktail, (peach and pineapple and pear and grape and cherry), canned, water pack, solids and liquids'
    ),
    (
        'Grapefruit, raw, pink and red, all areas'
    ),
    (
        'Grapefruit, sections, canned, water pack, solids and liquids'
    ),
    (
        'Grape juice, purple, with added vitamin C, from concentrate, shelf stable'
    );

INSERT INTO
    public.ingredients (name)
VALUES ('Guavas, common, raw'),
    ('Kiwifruit, green, raw'),
    ('Kumquats, raw'),
    ('Lemons, raw, without peel'),
    ('Lemon juice, raw'),
    ('Lemon peel, raw'),
    ('Limes, raw'),
    ('Lime juice, raw'),
    ('Litchis, raw'),
    ('Mangos, raw');

INSERT INTO
    public.ingredients (name)
VALUES ('Melons, cantaloupe, raw'),
    ('Melons, honeydew, raw'),
    ('Nectarines, raw'),
    (
        'Olives, ripe, canned (small-extra large)'
    ),
    (
        'Olives, pickled, canned or bottled, green'
    ),
    (
        'Oranges, raw, all commercial varieties'
    ),
    ('Oranges, raw, navels'),
    (
        'Orange juice, canned, unsweetened'
    ),
    (
        'Tangerines, (mandarin oranges), raw'
    ),
    (
        'Tangerines, (mandarin oranges), canned, juice pack'
    );

INSERT INTO
    public.ingredients (name)
VALUES ('Papayas, raw'),
    ('Papaya nectar, canned'),
    (
        'Passion-fruit, (granadilla), purple, raw'
    ),
    (
        'Passion-fruit juice, purple, raw'
    ),
    ('Peaches, yellow, raw'),
    (
        'Peaches, canned, water pack, solids and liquids'
    ),
    (
        'Peach nectar, canned, with sucralose, without added ascorbic acid'
    ),
    ('Pears, raw'),
    (
        'Pears, canned, water pack, solids and liquids'
    ),
    (
        'Pear nectar, canned, without added ascorbic acid'
    );

INSERT INTO
    public.ingredients (name)
VALUES ('Persimmons, japanese, raw'),
    ('Pineapple, raw'),
    (
        'Pineapple juice, canned or bottled, unsweetened, without added ascorbic acid'
    ),
    ('Plantains, yellow, raw'),
    ('Plums, raw'),
    ('Pomegranates, raw'),
    ('Prune juice, canned'),
    (
        'Raisins, dark, seedless (Includes foods for USDA''s Food Distribution Program)'
    ),
    ('Raspberries, raw'),
    ('Rhubarb, raw');

INSERT INTO
    public.ingredients (name)
VALUES ('Strawberries, raw'),
    (
        'Strawberries, canned, heavy syrup pack, solids and liquids'
    ),
    (
        'Strawberries, frozen, unsweetened (Includes foods for USDA''s Food Distribution Program)'
    ),
    ('Tamarinds, raw'),
    ('Watermelon, raw'),
    (
        'Maraschino cherries, canned, drained'
    ),
    ('Pears, asian, raw'),
    (
        'Blueberries, canned, light syrup, drained'
    ),
    (
        'Applesauce, unsweetened, with added vitamin C'
    ),
    (
        'Pineapple juice, canned or bottled, unsweetened, with added ascorbic acid'
    );

INSERT INTO
    public.ingredients (name)
VALUES ('Pears, raw, bartlett'),
    ('Guanabana nectar, canned'),
    ('Mango nectar, canned'),
    ('Pomegranate juice, bottled'),
    (
        'Juice, apple and grape blend, with added ascorbic acid'
    ),
    (
        'Apples, red delicious, with skin, raw'
    ),
    (
        'Apples, honeycrisp, with skin, raw'
    ),
    (
        'Apples, granny smith, with skin, raw'
    ),
    (
        'Apples, gala, with skin, raw'
    ),
    (
        'Apples, fuji, with skin, raw'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Grape juice, canned or bottled, unsweetened, with added ascorbic acid and calcium'
    ),
    (
        'Guava nectar, with sucralose, canned'
    ),
    (
        'Cranberry juice blend, 100% juice, bottled, with added vitamin C and calcium'
    ),
    (
        'Olives, green, Manzanilla, stuffed with pimiento'
    ),
    (
        'Pork, fresh, shoulder, (Boston butt), blade (steaks), separable lean and fat, cooked, braised'
    ),
    (
        'Pork, cured, ham, center slice, country-style, separable lean only, raw'
    ),
    (
        'Pork, cured, bacon, pre-sliced, cooked, pan-fried'
    ),
    (
        'Pork, cured, ham -- water added, whole, boneless, separable lean only, heated, roasted'
    ),
    (
        'Canadian bacon, cooked, pan-fried'
    ),
    (
        'Alfalfa seeds, sprouted, raw'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Artichokes, (globe or french), cooked, boiled, drained, without salt'
    ),
    ('Asparagus, raw'),
    (
        'Asparagus, canned, drained solids'
    ),
    (
        'Asparagus, frozen, cooked, boiled, drained, without salt'
    ),
    (
        'Balsam-pear (bitter gourd), leafy tips, cooked, boiled, drained, without salt'
    ),
    (
        'Balsam-pear (bitter gourd), pods, cooked, boiled, drained, without salt'
    ),
    (
        'Bamboo shoots, canned, drained solids'
    ),
    (
        'Lima beans, immature seeds, frozen, fordhook, cooked, boiled, drained, without salt'
    ),
    (
        'Mung beans, mature seeds, sprouted, raw'
    ),
    (
        'Mung beans, mature seeds, sprouted, cooked, boiled, drained, without salt'
    );

INSERT INTO
    public.ingredients (name)
VALUES ('Beans, snap, green, raw'),
    (
        'Beans, snap, green, canned, regular pack, drained solids'
    ),
    (
        'Beans, snap, green, frozen, cooked, boiled, drained without salt'
    ),
    ('Beets, raw'),
    (
        'Beets, canned, drained solids'
    ),
    ('Beet greens, raw'),
    ('Broccoli, raw'),
    (
        'Broccoli, frozen, chopped, cooked, boiled, drained, without salt'
    ),
    ('Broccoli raab, raw'),
    ('Brussels sprouts, raw');

INSERT INTO
    public.ingredients (name)
VALUES (
        'Brussels sprouts, frozen, cooked, boiled, drained, without salt'
    ),
    ('Burdock root, raw'),
    ('Cabbage, green, raw'),
    ('Cabbage, red, raw'),
    (
        'Cabbage, chinese (pak-choi), raw'
    ),
    ('Cabbage, kimchi'),
    ('Carrots, mature, raw'),
    (
        'Carrots, canned, regular pack, drained solids'
    ),
    ('Carrots, frozen, unprepared'),
    (
        'Carrots, frozen, cooked, boiled, drained, without salt'
    );

INSERT INTO
    public.ingredients (name)
VALUES ('Cassava, raw'),
    ('Cauliflower, raw'),
    (
        'Cauliflower, frozen, cooked, boiled, drained, without salt'
    ),
    ('Celery, raw'),
    ('Chard, swiss, raw'),
    ('Chayote, fruit, raw'),
    ('Chives, raw'),
    ('Collards, raw'),
    (
        'Collards, frozen, chopped, cooked, boiled, drained, without salt'
    ),
    ('Corn, sweet, yellow, raw');

INSERT INTO
    public.ingredients (name)
VALUES (
        'Corn, sweet, yellow, canned, whole kernel, drained solids'
    ),
    (
        'Corn, sweet, yellow, canned, cream style, regular pack'
    ),
    (
        'Corn, sweet, yellow, frozen, kernels cut off cob, boiled, drained, without salt'
    ),
    (
        'Cowpeas (blackeyes), immature seeds, frozen, cooked, boiled, drained, without salt'
    ),
    ('Cress, garden, raw'),
    ('Cucumber, with peel, raw'),
    ('Dandelion greens, raw'),
    ('Eggplant, raw'),
    ('Edamame, frozen, prepared'),
    (
        'Escarole, cooked, boiled, drained, no salt added'
    );

INSERT INTO
    public.ingredients (name)
VALUES ('Garlic, raw'),
    ('Ginger root, raw'),
    ('Kale, raw'),
    (
        'Kale, frozen, cooked, boiled, drained, without salt'
    ),
    ('Mushrooms, shiitake'),
    ('Kohlrabi, raw'),
    ('Mushroom, portabella'),
    (
        'Lambsquarters, cooked, boiled, drained, without salt'
    ),
    ('Lettuce, iceberg, raw'),
    ('Lettuce, leaf, green, raw');

INSERT INTO
    public.ingredients (name)
VALUES (
        'Lotus root, cooked, boiled, drained, without salt'
    ),
    ('Mushrooms, white button'),
    (
        'Mushrooms, canned, drained solids'
    ),
    ('Mushroom, crimini'),
    ('Mustard greens, raw'),
    (
        'Mustard greens, frozen, cooked, boiled, drained, without salt'
    ),
    ('Okra, raw'),
    (
        'Okra, frozen, cooked, boiled, drained, without salt'
    ),
    ('Onions, raw'),
    (
        'Onions, cooked, boiled, drained, without salt'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Onions, spring or scallions (includes tops and bulb), raw'
    ),
    (
        'Onion rings, breaded, par fried, frozen, prepared, heated in oven'
    ),
    ('Parsley, fresh'),
    (
        'Parsnips, cooked, boiled, drained, without salt'
    ),
    ('Peas, edible-podded, raw'),
    (
        'Peas, edible-podded, frozen, cooked, boiled, drained, without salt'
    ),
    ('Peas, green, raw'),
    (
        'Peas, green (includes baby and lesuer types), canned, drained solids, unprepared'
    ),
    (
        'Peas, green, frozen, cooked, boiled, drained, without salt'
    ),
    ('Peppers, bell, green, raw');

INSERT INTO
    public.ingredients (name)
VALUES (
        'Peppers, sweet, green, cooked, boiled, drained, without salt'
    ),
    (
        'Pokeberry shoots, (poke), cooked, boiled, drained, without salt'
    ),
    (
        'Potatoes, flesh and skin, raw'
    ),
    (
        'Potatoes, baked, flesh, without salt'
    ),
    (
        'Potatoes, boiled, cooked without skin, flesh, without salt'
    ),
    (
        'Potatoes, mashed, dehydrated, flakes without milk, dry form'
    ),
    (
        'Pumpkin flowers, cooked, boiled, drained, without salt'
    ),
    ('Pumpkin, raw'),
    (
        'Pumpkin, canned, without salt'
    ),
    ('Radishes, raw');

INSERT INTO
    public.ingredients (name)
VALUES ('Rutabagas, raw'),
    (
        'Salsify, cooked, boiled, drained, without salt'
    ),
    (
        'Sauerkraut, canned, solids and liquids'
    ),
    ('Seaweed, kelp, raw'),
    ('Seaweed, laver, raw'),
    ('Spinach, mature'),
    (
        'Spinach, canned, regular pack, drained solids'
    ),
    (
        'Spinach, frozen, chopped or leaf, cooked, boiled, drained, without salt'
    ),
    (
        'Squash, summer, crookneck and straightneck, raw'
    ),
    (
        'Squash, summer, crookneck and straightneck, canned, drained, solid, without salt'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Squash, summer, crookneck and straightneck, frozen, cooked, boiled, drained, without salt'
    ),
    (
        'Squash, summer, zucchini, includes skin, raw'
    ),
    (
        'Squash, summer, zucchini, includes skin, frozen, cooked, boiled, drained, without salt'
    ),
    (
        'Squash, winter, spaghetti, cooked, boiled, drained, or baked, without salt'
    ),
    (
        'Sweet potato leaves, cooked, steamed, without salt'
    ),
    (
        'Sweet potato, raw, unprepared (Includes foods for USDA''s Food Distribution Program)'
    ),
    (
        'Sweet potato, canned, vacuum pack'
    ),
    ('Taro, raw'),
    ('Taro leaves, raw'),
    ('Tomatoes, green, raw');

INSERT INTO
    public.ingredients (name)
VALUES (
        'Tomatoes, red, ripe, raw, year round average'
    ),
    (
        'Tomatoes, red, ripe, canned, packed in tomato juice'
    ),
    (
        'Tomato products, canned, puree, without salt added'
    ),
    (
        'Tomato products, canned, sauce'
    ),
    ('Turnips, raw'),
    (
        'Turnip greens, cooked, boiled, drained, without salt'
    ),
    (
        'Turnip greens, frozen, cooked, boiled, drained, without salt'
    ),
    (
        'Vegetables, mixed, frozen, cooked, boiled, drained, without salt'
    ),
    (
        'Waterchestnuts, chinese, canned, solids and liquids'
    ),
    ('Watercress, raw');

INSERT INTO
    public.ingredients (name)
VALUES (
        'Waxgourd, (chinese preserving melon), cooked, boiled, drained, without salt'
    ),
    ('Yambean (jicama), raw'),
    (
        'Beets, pickled, canned, solids and liquids'
    ),
    (
        'Squash, winter, all varieties, cooked, baked, without salt'
    ),
    ('Seaweed, wakame, raw'),
    (
        'Potatoes, baked, flesh and skin, without salt'
    ),
    (
        'Beans, snap, green, canned, no salt added, drained solids'
    ),
    (
        'Beans, snap, yellow, frozen, cooked, boiled, drained, without salt'
    ),
    (
        'Beets, canned, no salt added, solids and liquids'
    ),
    (
        'Carrots, canned, no salt added, solids and liquids'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Corn, sweet, yellow, canned, no salt added, solids and liquids (Includes foods for USDA''s Food Distribution Program)'
    ),
    (
        'Peas, green, canned, no salt added, solids and liquids'
    ),
    ('Peppers, bell, red, raw'),
    (
        'Pickles, cucumber, dill or kosher dill'
    ),
    (
        'Pickles, cucumber, sweet (includes bread and butter pickles)'
    ),
    ('Pimento, canned'),
    ('Pickle relish, sweet'),
    ('Fennel, bulb, raw'),
    ('Carrots, baby, raw'),
    ('Nopales, raw');

INSERT INTO
    public.ingredients (name)
VALUES ('Cauliflower, green, raw'),
    ('Pepper, banana, raw'),
    ('Peppers, jalapeno, raw'),
    ('Broccoli, chinese, raw'),
    ('Nuts, almonds, whole, raw'),
    ('Nuts, coconut meat, raw'),
    (
        'Nuts, coconut cream, canned, sweetened'
    ),
    (
        'Nuts, coconut milk, raw (liquid expressed from grated meat and water)'
    ),
    ('Nuts, pecans, halves, raw'),
    (
        'Nuts, pistachio nuts, dry roasted, without salt added'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Nuts, walnuts, English, halves, raw'
    ),
    (
        'Seeds, sesame seed kernels, dried (decorticated)'
    ),
    (
        'Beef, ground, patties, frozen, cooked, broiled'
    ),
    (
        'Beef, variety meats and by-products, tripe, raw'
    ),
    (
        'Beverages, Whiskey sour mix, bottled'
    ),
    (
        'Beverages, Acai berry drink, fortified'
    ),
    (
        'Beverages, Orange juice, light, No pulp'
    ),
    (
        'Beverages, Coconut water, ready-to-drink, unsweetened'
    ),
    (
        'Beverages, Mixed vegetable and fruit juice drink, with added nutrients'
    ),
    (
        'Beverages, carbonated, club soda'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Beverages, carbonated, ginger ale'
    ),
    (
        'Beverages, Apple juice drink, light, fortified with vitamin C'
    ),
    (
        'Beverages, Lemonade fruit juice drink light, fortified with vitamin E and C'
    ),
    (
        'Beverages, The COCA-COLA company, Minute Maid, Lemonade'
    ),
    (
        'Beverages, aloe vera juice drink, fortified with Vitamin C'
    ),
    (
        'Cranberry juice cocktail, bottled'
    ),
    (
        'Beverages, Tropical Punch, ready-to-drink'
    ),
    (
        'Lemonade, frozen concentrate, white'
    ),
    (
        'Beverages, lemonade-flavor drink, powder'
    ),
    (
        'Malt beverage, includes non-alcoholic beer'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Beverages, orange-flavor drink, breakfast type, powder'
    ),
    (
        'Beverages, water, tap, drinking'
    ),
    (
        'Beverages, water, tap, municipal'
    ),
    (
        'Beverages, orange breakfast drink, ready-to-drink, with added nutrients'
    ),
    (
        'Beverages, Wine, non-alcoholic'
    ),
    ('Water, bottled, generic'),
    (
        'Beverages, Vegetable and fruit juice drink, reduced calorie, with low-calorie sweetener, added vitamin C'
    ),
    (
        'Beverages, vegetable and fruit juice blend, 100% juice, with added vitamins A, C, E'
    ),
    (
        'Beverages, fruit juice drink, reduced sugar, with vitamin E added'
    ),
    (
        'Beverages, Fruit flavored drink, less than 3% juice, not fortified with vitamin C'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Beverages, Fruit flavored drink containing less than 3% fruit juice, with high vitamin C'
    ),
    (
        'Beverages, fruit juice drink, greater than 3% fruit juice, high vitamin C and added thiamin'
    ),
    (
        'Beverages, fruit juice drink, greater than 3% juice, high vitamin C'
    ),
    (
        'Fish, anchovy, european, canned in oil, drained solids'
    ),
    (
        'Crustaceans, lobster, northern, cooked, moist heat'
    ),
    (
        'Beans, baked, canned, plain or vegetarian'
    ),
    (
        'Beans, baked, canned, with pork and sweet sauce'
    ),
    (
        'Beans, black, mature seeds, cooked, boiled, without salt'
    ),
    (
        'Beans, black turtle, mature seeds, canned'
    ),
    (
        'Beans, great northern, mature seeds, canned'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Beans, kidney, red, mature seeds, cooked, boiled, without salt'
    ),
    (
        'Beans, kidney, red, mature seeds, canned, solids and liquids'
    ),
    (
        'Beans, pink, mature seeds, cooked, boiled, without salt'
    ),
    (
        'Beans, pinto, mature seeds, cooked, boiled, without salt'
    ),
    (
        'Beans, yellow, mature seeds, cooked, boiled, without salt'
    ),
    (
        'Beans, white, mature seeds, cooked, boiled, without salt'
    ),
    (
        'Broadbeans (fava beans), mature seeds, cooked, boiled, without salt'
    ),
    (
        'Chickpeas (garbanzo beans, bengal gram), mature seeds, raw'
    ),
    (
        'Chickpeas (garbanzo beans, bengal gram), mature seeds, cooked, boiled, without salt'
    ),
    (
        'Cowpeas, common (blackeyes, crowder, southern), mature seeds, cooked, boiled, without salt'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Lentils, mature seeds, cooked, boiled, without salt'
    ),
    (
        'Lima beans, large, mature seeds, cooked, boiled, without salt'
    ),
    (
        'Mung beans, mature seeds, cooked, boiled, without salt'
    ),
    (
        'Noodles, chinese, cellophane or long rice (mung beans), dehydrated'
    ),
    (
        'Peas, split, mature seeds, cooked, boiled, without salt'
    ),
    (
        'Refried beans, canned, traditional style'
    ),
    (
        'Soybeans, mature cooked, boiled, without salt'
    ),
    (
        'Soybeans, mature seeds, roasted, salted'
    ),
    ('Miso'),
    (
        'Tofu, soft, prepared with calcium sulfate and magnesium chloride (nigari)'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Veggie burgers or soyburgers, unprepared'
    ),
    (
        'Beans, black, mature seeds, canned, low sodium'
    ),
    (
        'Beans, great northern, mature seeds, canned, low sodium'
    ),
    (
        'Beans, kidney, red, mature seeds, canned, solids and liquid, low sodium'
    ),
    (
        'Beans, pinto, mature seeds, canned, solids and liquids, low sodium'
    ),
    (
        'Chickpeas (garbanzo beans, bengal gram), mature seeds, canned, solids and liquids, low sodium'
    ),
    (
        'Peanut butter, smooth style, without salt'
    ),
    (
        'Refried beans, canned, traditional, reduced sodium'
    ),
    (
        'Bread, french or vienna (includes sourdough)'
    ),
    (
        'Bread, pita, white, enriched'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Bread, white, commercially prepared'
    ),
    (
        'Bread, crumbs, dry, grated, plain'
    ),
    ('Bread, sticks, plain'),
    (
        'Cake, sponge, commercially prepared'
    ),
    (
        'Cookies, oatmeal, commercially prepared, special dietary'
    ),
    (
        'Cookies, vanilla wafers, lower fat'
    ),
    ('Crackers, cheese, regular'),
    ('Crackers, crispbread, rye'),
    ('Crackers, matzo, plain'),
    (
        'Crackers, melba toast, plain'
    );

INSERT INTO
    public.ingredients (name)
VALUES ('Crackers, milk'),
    (
        'Crackers, standard snack-type, regular'
    ),
    (
        'Crackers, standard snack-type, sandwich, with cheese filling'
    ),
    (
        'Crackers, standard snack-type, sandwich, with peanut butter filling'
    ),
    ('Crackers, wheat, regular'),
    ('Crackers, whole-wheat'),
    ('Croutons, seasoned'),
    (
        'Muffins, English, plain, enriched, with ca prop (includes sourdough)'
    ),
    (
        'Rolls, hamburger or hotdog, plain'
    ),
    (
        'Tortillas, ready-to-bake or -fry, corn'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Tortillas, ready-to-bake or -fry, flour, refrigerated'
    ),
    (
        'Leavening agents, baking powder, double-acting, sodium aluminum sulfate'
    ),
    (
        'Leavening agents, yeast, baker''s, compressed'
    ),
    (
        'Leavening agents, yeast, baker''s, active dry'
    ),
    (
        'Crackers, whole-wheat, low salt'
    ),
    (
        'Crackers, cheese, low sodium'
    ),
    (
        'Crackers, whole-wheat, reduced fat'
    ),
    (
        'Crackers, wheat, reduced fat'
    ),
    (
        'Crackers, cheese, reduced fat'
    ),
    ('Snacks, popcorn, cakes');

INSERT INTO
    public.ingredients (name)
VALUES (
        'Snacks, tortilla chips, plain, white corn, salted'
    ),
    ('Candies, caramels'),
    (
        'Candies, semisweet chocolate'
    ),
    ('Candies, sweet chocolate'),
    ('Candies, marshmallows'),
    (
        'Puddings, chocolate, ready-to-eat'
    ),
    (
        'Puddings, chocolate, dry mix, instant'
    ),
    (
        'Puddings, rice, ready-to-eat'
    ),
    (
        'Puddings, vanilla, ready-to-eat'
    ),
    (
        'Puddings, vanilla, dry mix, instant'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Puddings, tapioca, ready-to-eat'
    ),
    ('Honey'),
    ('Jams and preserves'),
    ('Pie fillings, apple, canned'),
    ('Sugars, brown'),
    ('Sugars, granulated'),
    ('Sugars, powdered'),
    ('Syrups, corn, dark'),
    ('Syrups, corn, light'),
    ('Barley, pearled, cooked');

INSERT INTO
    public.ingredients (name)
VALUES (
        'Buckwheat groats, roasted, cooked'
    ),
    ('Bulgur, cooked'),
    ('Cornstarch'),
    ('Couscous, cooked'),
    ('Hominy, canned, white'),
    ('Millet, cooked'),
    (
        'Rice, brown, long grain, unenriched, raw'
    ),
    (
        'Rice, brown, long-grain, cooked (Includes foods for USDA''s Food Distribution Program)'
    ),
    (
        'Rice, white, long-grain, regular, raw, enriched'
    ),
    (
        'Rice, white, long-grain, regular, enriched, cooked'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Rice, white, glutinous, unenriched, cooked'
    ),
    (
        'Flour, rice, white, unenriched'
    ),
    ('Tapioca, pearl, dry'),
    ('Wheat bran, crude'),
    (
        'Flour, whole wheat, unenriched'
    ),
    (
        'Flour, wheat, all-purpose, enriched, bleached'
    ),
    (
        'Flour, bread, white, enriched, unbleached'
    ),
    ('Wild rice, raw'),
    ('Wild rice, cooked'),
    (
        'Macaroni, vegetable, enriched, cooked'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Noodles, egg, enriched, cooked'
    ),
    (
        'Noodles, flat, crunchy, Chinese restaurant'
    ),
    (
        'Pasta, cooked, enriched, without added salt'
    ),
    (
        'Pasta, whole-wheat, cooked (Includes foods for USDA''s Food Distribution Program)'
    ),
    ('Rice noodles, cooked'),
    ('Quinoa, cooked'),
    (
        'Pasta, gluten-free, corn and rice flour, cooked'
    ),
    (
        'Fast foods, onion rings, breaded and fried'
    ),
    ('Fast foods, potato, mashed'),
    ('Potato salad with egg');

INSERT INTO
    public.ingredients (name)
VALUES ('Snacks, pita chips, salted'),
    ('Snacks, bagel chips, plain'),
    (
        'Snacks, peas, roasted, wasabi-flavored'
    ),
    ('Rice crackers'),
    (
        'Soup, egg drop, Chinese restaurant'
    ),
    (
        'Soup, hot and sour, Chinese restaurant'
    ),
    ('Crackers, multigrain'),
    (
        'Crackers, cheese, whole grain'
    ),
    (
        'Crackers, sandwich-type, peanut butter filled, reduced fat'
    ),
    (
        'Crackers, whole grain, sandwich-type, with peanut butter filling'
    );

INSERT INTO
    public.ingredients (name)
VALUES ('Crackers, water biscuits'),
    (
        'Crackers, gluten-free, multi-seeded and multigrain'
    ),
    (
        'Sweet Potatoes, french fried, frozen as packaged, salt added in processing'
    ),
    (
        'Ginger root, pickled, canned, with artificial sweetener'
    ),
    (
        'Peppers, hot pickled, canned'
    ),
    (
        'Potatoes, mashed, ready-to-eat'
    ),
    (
        'Yellow rice with seasoning, dry packet mix, unprepared'
    ),
    (
        'Infant Formula, MEAD JOHNSON, ENFAMIL, Premium LIPIL, Infant, powder'
    ),
    (
        'Infant formula, MEAD JOHNSON, ENFAMIL, ENFAGROW, GENTLEASE, Toddler transitions, with ARA and DHA, powder'
    ),
    (
        'Infant formula, GERBER, GOOD START, PROTECT PLUS, powder'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Infant formula, ABBOTT NUTRITION, SIMILAC, GO AND GROW, powder, with ARA and DHA'
    ),
    (
        'Infant formula, MEAD JOHNSON, ENFAMIL, NUTRAMIGEN, PurAmino, powder, not reconstituted'
    ),
    (
        'Restaurant, Mexican, refried beans'
    ),
    ('Syrups, grenadine'),
    (
        'Beverages, fruit-flavored drink, dry powdered mix, low calorie, with aspartame'
    ),
    (
        'Creamy dressing, made with sour cream and/or buttermilk and oil, reduced calorie'
    ),
    (
        'Salad Dressing, mayonnaise-like, fat-free'
    ),
    ('Papad'),
    (
        'Rice cake, cracker (include hain mini rice cakes)'
    ),
    (
        'Babyfood, juice, apple-sweet potato'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Frankfurter, meat and poultry, low fat'
    ),
    (
        'Babyfood, baked product, finger snacks cereal fortified'
    ),
    (
        'Cranberry juice, not fortified, from concentrate, shelf stable'
    ),
    (
        'Turnip greens, canned, no salt added'
    ),
    ('Hearts of palm, raw'),
    (
        'Beverages, cranberry-apple juice drink, low calorie, with vitamin C added'
    ),
    ('Babyfood, juice, pear'),
    (
        'Beans, baked, canned, no salt added'
    ),
    ('Frankfurter, low sodium'),
    (
        'Babyfood, banana no tapioca, strained'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Puddings, chocolate flavor, low calorie, instant, dry mix'
    ),
    (
        'Babyfood, grape juice, no sugar, canned'
    ),
    (
        'Puddings, all flavors except chocolate, low calorie, instant, dry mix'
    ),
    ('Bananas, overripe, raw'),
    ('Flour, rice, glutinous'),
    ('Spinach, baby'),
    (
        'Grape juice, white, with added vitamin C, from concentrate, shelf stable'
    ),
    (
        'Lettuce, romaine, green, raw'
    ),
    ('Yogurt, plain, nonfat'),
    (
        'LOW SODIUM: Tomato juice, canned'
    );

INSERT INTO
    public.ingredients (name)
VALUES ('Vitamin D as ingredient'),
    ('Milk, NFS'),
    ('Non-dairy milk, NFS'),
    ('Yogurt, low fat milk, plain'),
    (
        'Yogurt, Greek, whole milk, plain'
    ),
    (
        'Yogurt, Greek, low fat milk, plain'
    ),
    ('Yogurt, low fat milk, fruit'),
    ('Yogurt, nonfat milk, fruit'),
    (
        'Yogurt, Greek, low fat milk, fruit'
    ),
    (
        'Yogurt, low fat milk, flavors other than fruit'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Yogurt, Greek, low fat milk, flavors other than fruit'
    ),
    ('Tzatziki dip'),
    ('Baby Toddler yogurt, plain'),
    (
        'Baby Toddler yogurt, with fruit'
    ),
    (
        'Infant formula, Similac Advance, powder, made with tap water'
    ),
    (
        'Infant formula, Similac Advance, powder, made with bottled water'
    ),
    (
        'Infant formula, Similac Advance, powder, made with baby water'
    ),
    (
        'Infant formula, Similac Sensitive, powder, made with baby water'
    ),
    (
        'Infant formula, Similac for Spit-Up, powder, made with water'
    ),
    (
        'Toddler formula, Similac Go and Grow'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Infant formula, Enfamil Infant, powder, made with tap water'
    ),
    (
        'Infant formula, Enfamil Infant, powder, made with bottled water'
    ),
    (
        'Infant formula, Enfamil Infant, powder, made with baby water'
    ),
    (
        'Infant formula, Enfamil AR, powder, made with water'
    ),
    (
        'Infant formula, Enfamil Gentlease, powder, made with baby water'
    ),
    (
        'Toddler formula, Enfamil Enfagrow'
    ),
    (
        'Infant formula, Gerber Good Start Gentle, Stage 1, powder, made with baby water'
    ),
    (
        'Infant formula, Enfamil ProSobee, powder, made with baby water'
    ),
    (
        'Infant formula, Similac Isomil Soy, powder, made with baby water'
    ),
    (
        'Infant formula, Gerber Good Start Soy, Stage 1, powder, made with baby water'
    );

INSERT INTO
    public.ingredients (name)
VALUES ('Custard'),
    ('White sauce or gravy'),
    ('Cheese, NFS'),
    ('Baby Toddler meat, NFS'),
    ('Beef, ground, raw'),
    ('Beef, ground'),
    ('Pork, cracklings'),
    (
        'Chicken, NS as to part, rotisserie, skin not eaten'
    ),
    (
        'Chicken breast, rotisserie, skin not eaten'
    ),
    ('Clams, canned');

INSERT INTO
    public.ingredients (name)
VALUES ('Oysters, steamed'),
    ('Soup, broth'),
    ('Soup, chicken'),
    (
        'Egg, whole, boiled or poached'
    ),
    ('Egg, whole, fried with oil'),
    (
        'Egg omelet or scrambled egg, made with oil'
    ),
    (
        'Beans, from dried, NS as to type, fat added'
    ),
    (
        'White beans, from dried, fat added'
    ),
    (
        'Black beans, from dried, fat added'
    ),
    (
        'Black beans, from dried, no added fat'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Black beans, from canned, fat added'
    ),
    (
        'Black beans, from canned, no added fat'
    ),
    ('Lima beans, from dried'),
    (
        'Pinto beans, from dried, fat added'
    ),
    (
        'Pinto beans, from dried, no added fat'
    ),
    (
        'Pinto beans, from canned, fat added'
    ),
    (
        'Pinto beans, from canned, no added fat'
    ),
    (
        'Kidney beans, from dried, fat added'
    ),
    ('Baked beans'),
    ('Refried beans');

INSERT INTO
    public.ingredients (name)
VALUES ('Falafel'),
    ('Blackeyed peas, from dried'),
    (
        'Chickpeas, from dried, fat added'
    ),
    (
        'Chickpeas, from dried, no added fat'
    ),
    (
        'Lentils, from dried, fat added'
    ),
    ('Soup, lentil'),
    ('Almonds, salted'),
    (
        'Bread, Italian, Grecian, Armenian, toasted'
    ),
    ('Baby Toddler cookie'),
    ('Baby Toddler biscuit');

INSERT INTO
    public.ingredients (name)
VALUES (
        'Baby Toddler puffs, vegetable'
    ),
    ('Rice, cooked, NFS'),
    (
        'Rice, white, cooked, no added fat'
    ),
    ('Cereal, granola'),
    (
        'Baby Toddler cereal, multigrain, dry'
    ),
    (
        'Baby Toddler cereal, multigrain, ready-to-eat'
    ),
    (
        'Baby Toddler cereal, oatmeal with fruit, ready-to-eat'
    ),
    (
        'Wonton, dumpling or pot sticker, steamed'
    ),
    ('Soup, chicken noodle'),
    ('Ramen bowl, NFS');

INSERT INTO
    public.ingredients (name)
VALUES ('Ramen bowl with beef'),
    ('Ramen bowl with chicken'),
    ('Ramen bowl with fish'),
    ('Ramen bowl, vegetarian'),
    (
        'Ramen bowl with meat and egg'
    ),
    ('Orange, canned, juice pack'),
    ('Orange, canned, in syrup'),
    (
        'Grapefruit juice, 100%, canned, bottled or in a carton'
    ),
    ('Orange juice, 100%, NFS'),
    (
        'Orange juice, 100%, canned, bottled or in a carton'
    );

INSERT INTO
    public.ingredients (name)
VALUES ('Fruit, NFS'),
    ('Apple, raw'),
    ('Grapes, raw'),
    ('Peach, canned, in syrup'),
    ('Peach, canned, juice pack'),
    ('Pear, canned, in syrup'),
    ('Pear, canned, juice pack'),
    ('Berries, NFS'),
    (
        'Fruit cocktail, canned, in syrup'
    ),
    (
        'Fruit cocktail, canned, juice pack'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Cranberry juice blend, 100% juice'
    ),
    ('Apple juice, 100%'),
    ('Grape juice, 100%'),
    ('Baby Toddler fruit, NFS'),
    ('Baby Toddler juice, NFS'),
    ('Baby Toddler juice, apple'),
    (
        'Potato, boiled, from fresh, peel not eaten, no added fat'
    ),
    (
        'Potato, boiled, from fresh, peel not eaten, fat added, NS as to fat type'
    ),
    (
        'Potato, scalloped, from fresh'
    ),
    (
        'Potato, mashed, from fresh, made with milk'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Potato, mashed, from restaurant'
    ),
    (
        'Potato, mashed, from dry mix, made with milk'
    ),
    (
        'Collards, fresh, cooked, no added fat'
    ),
    (
        'Collards, fresh, cooked, fat added, NS as to fat type'
    ),
    (
        'Greens, fresh, cooked, no added fat'
    ),
    (
        'Greens, fresh, cooked, fat added'
    ),
    (
        'Kale, fresh, cooked, no added fat'
    ),
    (
        'Kale, fresh, cooked, fat added'
    ),
    (
        'Mustard greens, fresh, cooked, no added fat'
    ),
    (
        'Mustard greens, fresh, cooked, fat added'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Spinach, fresh, cooked, fat added, NS as to fat type'
    ),
    (
        'Turnip greens, fresh, cooked, no added fat'
    ),
    (
        'Turnip greens, fresh, cooked, fat added'
    ),
    ('Broccoli, raw'),
    (
        'Broccoli, fresh, cooked, fat added, NS as to fat type'
    ),
    ('Carrots, raw'),
    (
        'Carrots, fresh, cooked, no added fat'
    ),
    (
        'Carrots, canned, cooked, no added fat'
    ),
    (
        'Carrots, fresh, cooked, fat added, NS as to fat type'
    ),
    (
        'Carrots, canned, cooked, fat added, NS as to fat type'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Carrots, canned, cooked with oil'
    ),
    (
        'Carrots, canned, cooked with butter or margarine'
    ),
    (
        'Carrots, canned, reduced sodium, cooked, no added fat'
    ),
    (
        'Carrots, canned, reduced sodium, cooked, fat added, NS as to fat type'
    ),
    (
        'Carrots, canned, reduced sodium, cooked with oil'
    ),
    (
        'Carrots, canned, reduced sodium, cooked with butter or margarine'
    ),
    (
        'Peas and carrots, fresh, cooked, fat added'
    ),
    (
        'Sweet potato, boiled, NS as to fat'
    ),
    ('Sweet potato fries, frozen'),
    ('Tomatoes, raw');

INSERT INTO
    public.ingredients (name)
VALUES (
        'Puerto Rican seasoning with ham'
    ),
    ('Celery, raw'),
    ('Mushrooms, raw'),
    ('Onions, raw'),
    ('Peppers, raw, NFS'),
    ('Seaweed, raw'),
    (
        'Asparagus, fresh, cooked, fat added, NS as to fat type'
    ),
    (
        'Green beans, fresh, cooked, no added fat'
    ),
    (
        'Green beans, canned, cooked, no added fat'
    ),
    (
        'Green beans, fresh, cooked, fat added, NS as to fat type'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Green beans, canned, cooked, fat added, NS as to fat type'
    ),
    (
        'Green beans, canned, cooked with oil'
    ),
    (
        'Green beans, canned, cooked with butter or margarine'
    ),
    (
        'Green beans, canned, reduced sodium, cooked, no added fat'
    ),
    (
        'Green beans, canned, reduced sodium, cooked, fat added, NS as to fat type'
    ),
    (
        'Green beans, canned, reduced sodium, cooked with oil'
    ),
    (
        'Green beans, canned, reduced sodium, cooked with butter or margarine'
    ),
    (
        'Beets, canned, cooked, fat added'
    ),
    (
        'Brussels sprouts, fresh, cooked, fat added'
    ),
    (
        'Cauliflower, fresh, cooked, fat added, NS as to fat type'
    );

INSERT INTO
    public.ingredients (name)
VALUES ('Celery, cooked'),
    (
        'Corn, fresh, cooked, no added fat'
    ),
    (
        'Corn, canned, cooked, no added fat'
    ),
    (
        'Corn, canned, cooked, fat added, NS as to fat type'
    ),
    (
        'Corn, canned, cooked with oil'
    ),
    (
        'Corn, canned, cooked with butter or margarine'
    ),
    (
        'Corn, canned, reduced sodium, cooked, no added fat'
    ),
    (
        'Corn, canned, reduced sodium, cooked, fat added, NS as to fat type'
    ),
    (
        'Corn, canned, reduced sodium, cooked with oil'
    ),
    (
        'Corn, canned, reduced sodium, cooked with butter or margarine'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Mushrooms, fresh, cooked, fat added, NS as to fat type'
    ),
    (
        'Mushroom, Asian, cooked, from dried'
    ),
    (
        'Okra, fresh, cooked, fat added'
    ),
    (
        'Onions, cooked, no added fat'
    ),
    ('Onions, cooked, fat added'),
    (
        'Green peas, fresh, cooked, no added fat'
    ),
    (
        'Green peas, canned, cooked, no added fat'
    ),
    (
        'Green peas, frozen, cooked, fat added, NS as to fat type'
    ),
    (
        'Green peas, canned, cooked, fat added, NS as to fat type'
    ),
    (
        'Green peas, canned, cooked with oil'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Green peas, canned, cooked with butter or margarine'
    ),
    (
        'Green peas, canned, reduced sodium, cooked, no added fat'
    ),
    (
        'Green peas, canned, reduced sodium, cooked, fat added, NS as to fat type'
    ),
    (
        'Green peas, canned, reduced sodium, cooked with oil'
    ),
    (
        'Green peas, canned, reduced sodium, cooked with butter or margarine'
    ),
    (
        'Snowpeas, frozen, cooked, no added fat'
    ),
    (
        'Snowpeas, fresh, cooked, fat added'
    ),
    (
        'Summer squash, yellow or green, fresh, cooked, fat added, NS as to fat type'
    ),
    ('Water Chesnut'),
    (
        'Classic mixed vegetables, frozen, cooked, fat added, NS as to fat type'
    );

INSERT INTO
    public.ingredients (name)
VALUES ('Vegetable curry'),
    ('Pickles, dill'),
    ('Olives, NFS'),
    ('Peppers, sweet, pickled'),
    ('Pickles, NFS'),
    ('Soup, beef'),
    ('Baby Toddler vegetable, NFS'),
    (
        'Toddler meal, meat and vegetables'
    ),
    (
        'Toddler meal, rice and vegetables'
    ),
    ('Toddler meal, pasta');

INSERT INTO
    public.ingredients (name)
VALUES (
        'Toddler meal, pasta and vegetables'
    ),
    ('Table fat, NFS'),
    ('Margarine, NFS'),
    ('Margarine, stick'),
    ('Oil or table fat, NFS'),
    ('Animal fat or drippings'),
    ('Hollandaise sauce'),
    ('Curry sauce'),
    ('Vegetable oil, NFS'),
    ('Olive oil');

INSERT INTO
    public.ingredients (name)
VALUES (
        'Ham, for use with vegetables'
    ),
    (
        'Beef, for use with vegetables'
    ),
    (
        'Cream sauce, for use with vegetables'
    ),
    (
        'Cucumber, for use on a sandwich'
    ),
    (
        'Lettuce, for use on a sandwich'
    ),
    (
        'Onions, for use on a sandwich'
    ),
    (
        'Pepper, for use on a sandwich'
    ),
    (
        'Tomatoes, for use on a sandwich'
    ),
    (
        'Cheese as ingredient in sandwiches'
    ),
    (
        'Beef as ingredient in recipes'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Breakfast meat as ingredient in omelet'
    ),
    (
        'Chicken as ingredient in recipes'
    ),
    ('Fish, cooked, as ingredient'),
    (
        'Breading or batter as ingredient in food'
    ),
    (
        'Wheat bread as ingredient in sandwiches'
    ),
    (
        'Rice, white, cooked, as ingredient'
    ),
    (
        'Rice, brown, cooked, as ingredient'
    ),
    (
        'Potato, cooked, as ingredient'
    ),
    (
        'Spinach, cooked, as ingredient'
    ),
    (
        'Broccoli, cooked, as ingredient'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Carrots, cooked, as ingredient'
    ),
    (
        'Sweet potato, cooked, as ingredient'
    ),
    (
        'Tomatoes, cooked, as ingredient'
    ),
    (
        'Onions, cooked, as ingredient'
    ),
    (
        'Mushrooms, cooked, as ingredient'
    ),
    (
        'Green pepper, cooked, as ingredient'
    ),
    (
        'Red pepper, cooked, as ingredient'
    ),
    (
        'Cauliflower, cooked, as ingredient'
    ),
    (
        'Eggplant, cooked, as ingredient'
    ),
    (
        'Green beans, cooked, as ingredient'
    );

INSERT INTO
    public.ingredients (name)
VALUES (
        'Summer squash, cooked, as ingredient'
    ),
    (
        'Dark green vegetables as ingredient in omelet'
    ),
    (
        'Tomatoes as ingredient in omelet'
    ),
    (
        'Other vegetables as ingredient in omelet'
    ),
    (
        'Mirepoix, cooked, as ingredient'
    ),
    (
        'Vegetables as ingredient in curry'
    ),
    (
        'Vegetables as ingredient in soups'
    ),
    (
        'Vegetables as ingredient in stews'
    ),
    (
        'Industrial oil as ingredient in food'
    );

-- Nutritions Data
INSERT INTO
    public.nutritions (name)
VALUES ('calcium'),
    ('carbohydrate'),
    ('energy'),
    ('iron'),
    ('protein'),
    ('fat');

-- Food Ingredients Data
INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1, 16, 40.0),
    (1, 17, 38.0),
    (1, 18, 14.0),
    (1, 19, 8.0),
    (2, 16, 100.0),
    (3, 17, 100.0),
    (4, 18, 100.0),
    (5, 19, 100.0),
    (6, 18, 100.0),
    (7, 19, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (8, 17, 100.0),
    (9, 16, 100.0),
    (10, 20, 100.0),
    (11, 42, 50.0),
    (11, 43, 50.0),
    (12, 25, 100.0),
    (13, 37, 23.0),
    (13, 412, 237.0),
    (14, 21, 42.662),
    (14, 412, 237.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (15, 23, 100.0),
    (16, 23, 100.0),
    (17, 2, 1.8),
    (17, 24, 100.0),
    (18, 24, 100.0),
    (19, 595, 50.0),
    (19, 597, 50.0),
    (20, 599, 100.0),
    (21, 597, 100.0),
    (22, 594, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (23, 26, 100.0),
    (23, 591, 0.004),
    (24, 27, 100.0),
    (24, 591, 0.012),
    (25, 589, 100.0),
    (25, 591, 0.01),
    (26, 596, 100.0),
    (27, 44, 100.0),
    (28, 2, 1.0),
    (28, 41, 99.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (29, 41, 100.0),
    (30, 597, 100.0),
    (31, 26, 86.0),
    (31, 503, 14.0),
    (31, 591, 0.005),
    (32, 27, 86.0),
    (32, 503, 14.0),
    (32, 591, 0.012),
    (33, 412, 13.0),
    (33, 503, 1.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (33, 589, 86.0),
    (33, 591, 0.01),
    (34, 599, 100.0),
    (35, 44, 89.0),
    (35, 503, 11.0),
    (35, 591, 0.009),
    (36, 2, 1.0),
    (36, 41, 88.0),
    (36, 503, 11.0),
    (36, 591, 0.009);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (37, 41, 89.0),
    (37, 503, 11.0),
    (37, 591, 0.009),
    (38, 600, 100.0),
    (39, 26, 86.0),
    (39, 412, 7.0),
    (39, 506, 7.0),
    (39, 591, 0.005),
    (40, 27, 86.0),
    (40, 412, 7.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (40, 506, 7.0),
    (40, 591, 0.012),
    (41, 412, 13.0),
    (41, 506, 1.0),
    (41, 589, 86.0),
    (41, 591, 0.01),
    (42, 601, 100.0),
    (43, 44, 89.0),
    (43, 412, 6.0),
    (43, 506, 5.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (43, 591, 0.009),
    (44, 2, 1.0),
    (44, 41, 88.0),
    (44, 412, 6.0),
    (44, 506, 5.0),
    (44, 591, 0.009),
    (45, 41, 89.0),
    (45, 412, 6.0),
    (45, 506, 5.0),
    (45, 591, 0.009);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (46, 601, 80.0),
    (46, 664, 20.0),
    (47, 412, 20.0),
    (47, 591, 0.002),
    (47, 597, 80.0),
    (48, 597, 75.0),
    (48, 598, 25.0),
    (49, 600, 75.0),
    (49, 601, 75.0),
    (49, 664, 25.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (49, 688, 75.0),
    (50, 624, 33.0),
    (50, 694, 33.0),
    (50, 787, 33.0),
    (51, 26, 100.0),
    (51, 591, 0.004),
    (52, 26, 90.0),
    (52, 503, 10.0),
    (52, 591, 0.005),
    (53, 607, 50.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (53, 613, 50.0),
    (54, 607, 75.0),
    (54, 608, 25.0),
    (55, 105, 100.0),
    (56, 105, 100.0),
    (57, 69, 59.2),
    (57, 109, 8.5),
    (58, 109, 8.5),
    (58, 412, 59.2),
    (59, 109, 8.5);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (59, 416, 59.2),
    (60, 69, 59.2),
    (60, 109, 8.5),
    (61, 69, 59.2),
    (61, 108, 8.5),
    (62, 108, 8.5),
    (62, 412, 59.2),
    (63, 108, 8.5),
    (63, 416, 59.2),
    (64, 69, 59.2);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (64, 108, 8.5),
    (65, 69, 59.2),
    (65, 119, 8.5),
    (66, 69, 59.2),
    (66, 119, 8.5),
    (67, 69, 118.4),
    (67, 561, 15.0),
    (68, 613, 75.0),
    (68, 615, 25.0),
    (69, 69, 59.2);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (69, 558, 8.8),
    (70, 412, 59.2),
    (70, 558, 8.8),
    (71, 416, 59.2),
    (71, 558, 8.8),
    (72, 69, 59.2),
    (72, 558, 8.8),
    (73, 69, 59.2),
    (73, 106, 8.8),
    (74, 69, 59.2);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (74, 106, 8.8),
    (75, 69, 59.2),
    (75, 114, 8.8),
    (76, 114, 8.8),
    (76, 412, 59.2),
    (77, 114, 8.8),
    (77, 416, 59.2),
    (78, 69, 59.2),
    (78, 114, 8.8),
    (79, 69, 177.4);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (79, 113, 20.25),
    (79, 559, 6.75),
    (80, 103, 100.0),
    (81, 610, 50.0),
    (81, 616, 50.0),
    (82, 610, 50.0),
    (82, 616, 50.0),
    (83, 103, 100.0),
    (84, 617, 75.0),
    (84, 620, 25.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (85, 69, 59.2),
    (85, 560, 8.7),
    (86, 412, 59.2),
    (86, 560, 8.7),
    (87, 416, 59.2),
    (87, 560, 8.7),
    (88, 69, 59.2),
    (88, 560, 8.7),
    (89, 69, 59.2),
    (89, 560, 8.7);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (90, 610, 50.0),
    (90, 616, 50.0),
    (91, 107, 50.0),
    (91, 111, 50.0),
    (92, 107, 50.0),
    (92, 111, 50.0),
    (93, 607, 50.0),
    (93, 613, 50.0),
    (94, 607, 50.0),
    (94, 613, 50.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (95, 605, 50.0),
    (95, 611, 50.0),
    (96, 606, 50.0),
    (96, 612, 50.0),
    (97, 607, 50.0),
    (97, 613, 50.0),
    (98, 608, 50.0),
    (98, 615, 50.0),
    (99, 609, 50.0),
    (99, 614, 50.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (100, 69, 59.2),
    (100, 102, 8.8),
    (101, 102, 8.8),
    (101, 412, 59.2),
    (102, 102, 8.8),
    (102, 416, 59.2),
    (103, 69, 59.2),
    (103, 102, 8.8),
    (104, 69, 59.2),
    (104, 110, 8.5);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (105, 110, 8.5),
    (105, 412, 59.2),
    (106, 110, 8.5),
    (106, 416, 59.2),
    (107, 69, 59.2),
    (107, 110, 8.5),
    (108, 115, 100.0),
    (109, 69, 59.2),
    (109, 104, 8.7),
    (110, 104, 8.7);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (110, 412, 59.2),
    (111, 104, 8.7),
    (111, 416, 59.2),
    (112, 69, 59.2),
    (112, 104, 8.7),
    (113, 618, 50.0),
    (113, 619, 50.0),
    (114, 69, 59.2),
    (114, 101, 8.8),
    (115, 69, 59.2);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (115, 101, 8.8),
    (116, 69, 59.2),
    (116, 99, 8.8),
    (117, 69, 59.2),
    (117, 99, 8.8),
    (118, 69, 59.2),
    (118, 562, 8.8),
    (119, 69, 59.2),
    (119, 100, 8.5),
    (120, 496, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (121, 28, 100.0),
    (121, 46, 2.6),
    (121, 50, 1.1),
    (121, 59, 1.5),
    (121, 61, 2.167),
    (121, 208, 72.5),
    (121, 461, 112.0),
    (121, 505, 36.25),
    (121, 592, 488.0),
    (121, 794, 14.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (122, 499, 100.0),
    (123, 28, 100.0),
    (123, 59, 0.4),
    (123, 413, 1.234),
    (123, 506, 37.5),
    (123, 592, 488.0),
    (124, 23, 378.0),
    (124, 28, 300.0),
    (124, 59, 3.0),
    (124, 412, 355.5);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (124, 506, 300.0),
    (125, 28, 50.0),
    (125, 59, 0.4),
    (125, 413, 1.234),
    (125, 506, 75.0),
    (125, 592, 488.0),
    (126, 498, 100.0),
    (127, 16, 2928.0),
    (127, 61, 26.0),
    (127, 385, 28.35);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (127, 390, 14.2),
    (127, 506, 453.6),
    (127, 519, 453.6),
    (128, 501, 100.0),
    (129, 500, 95.0),
    (129, 592, 480.0),
    (130, 497, 110.0),
    (130, 592, 480.0),
    (131, 583, 30.0),
    (131, 592, 480.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (132, 581, 40.0),
    (132, 592, 480.0),
    (133, 499, 100.0),
    (134, 583, 30.0),
    (134, 592, 480.0),
    (135, 496, 100.0),
    (136, 581, 40.0),
    (136, 592, 480.0),
    (137, 501, 100.0),
    (138, 28, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (138, 153, 354.0),
    (138, 466, 140.0),
    (138, 499, 560.0),
    (138, 506, 50.0),
    (138, 592, 106.75),
    (139, 13, 180.0),
    (139, 30, 68.0),
    (139, 494, 85.05),
    (139, 506, 50.0),
    (139, 592, 488.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (140, 39, 100.0),
    (141, 9, 246.0),
    (141, 11, 240.0),
    (141, 385, 10.0),
    (141, 390, 10.0),
    (141, 506, 200.0),
    (142, 14, 25.0),
    (142, 167, 25.0),
    (142, 464, 25.0),
    (142, 621, 25.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (143, 1, 42.0),
    (143, 3, 84.75),
    (143, 28, 150.0),
    (143, 59, 1.5),
    (143, 526, 23.438),
    (143, 592, 244.0),
    (144, 63, 20.0),
    (144, 64, 10.0),
    (144, 65, 45.0),
    (144, 66, 25.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (145, 63, 100.0),
    (146, 64, 100.0),
    (147, 67, 100.0),
    (148, 65, 100.0),
    (149, 66, 100.0),
    (150, 59, 0.2),
    (150, 705, 87.0),
    (150, 801, 13.0),
    (151, 59, 0.7),
    (151, 353, 10.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (151, 393, 8.0),
    (151, 412, 40.0),
    (151, 520, 2.0),
    (151, 799, 0.3),
    (151, 818, 15.0),
    (151, 831, 15.0),
    (151, 835, 10.0),
    (152, 59, 0.9),
    (152, 249, 5.0),
    (152, 412, 50.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (152, 535, 20.0),
    (152, 810, 20.0),
    (152, 824, 5.0),
    (153, 59, 0.9),
    (153, 249, 5.0),
    (153, 265, 10.0),
    (153, 412, 50.0),
    (153, 450, 10.0),
    (153, 535, 20.0),
    (153, 799, 0.5);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (153, 824, 5.0),
    (154, 13, 12.0),
    (154, 59, 0.6),
    (154, 235, 5.0),
    (154, 394, 5.0),
    (154, 412, 35.0),
    (154, 526, 3.0),
    (154, 799, 0.3),
    (154, 835, 10.0),
    (154, 837, 30.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (155, 59, 1.3),
    (155, 412, 100.0),
    (155, 799, 0.5),
    (155, 810, 10.0),
    (155, 818, 30.0),
    (155, 823, 20.0),
    (155, 835, 40.0),
    (156, 59, 0.7),
    (156, 412, 40.0),
    (156, 810, 20.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (156, 835, 10.0),
    (156, 837, 30.0),
    (157, 59, 0.5),
    (157, 412, 50.0),
    (157, 515, 15.0),
    (157, 799, 0.3),
    (157, 812, 10.0),
    (157, 835, 10.0),
    (157, 837, 15.0),
    (158, 59, 0.5);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (158, 393, 8.0),
    (158, 412, 50.0),
    (158, 462, 2.0),
    (158, 533, 15.0),
    (158, 799, 0.3),
    (158, 819, 15.0),
    (158, 835, 10.0),
    (159, 59, 0.6),
    (159, 235, 10.0),
    (159, 412, 50.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (159, 799, 0.3),
    (159, 835, 10.0),
    (159, 837, 30.0),
    (160, 133, 50.0),
    (160, 138, 50.0),
    (161, 59, 1.3),
    (161, 412, 100.0),
    (161, 799, 0.5),
    (161, 812, 10.0),
    (161, 818, 30.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (161, 823, 20.0),
    (161, 835, 40.0),
    (162, 59, 0.6),
    (162, 412, 50.0),
    (162, 799, 0.3),
    (162, 812, 10.0),
    (162, 835, 10.0),
    (162, 837, 30.0),
    (163, 59, 0.7),
    (163, 412, 40.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (163, 812, 20.0),
    (163, 835, 10.0),
    (163, 837, 30.0),
    (164, 546, 100.0),
    (165, 13, 12.0),
    (165, 59, 0.6),
    (165, 412, 35.0),
    (165, 526, 3.0),
    (165, 799, 0.3),
    (165, 812, 10.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (165, 835, 10.0),
    (165, 837, 30.0),
    (166, 59, 0.6),
    (166, 353, 15.0),
    (166, 412, 50.0),
    (166, 630, 10.0),
    (166, 799, 0.3),
    (166, 818, 15.0),
    (166, 835, 10.0),
    (167, 13, 12.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (167, 59, 0.6),
    (167, 412, 35.0),
    (167, 526, 3.0),
    (167, 630, 10.0),
    (167, 799, 0.3),
    (167, 818, 30.0),
    (167, 835, 10.0),
    (168, 13, 12.0),
    (168, 59, 0.5),
    (168, 412, 35.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (168, 425, 5.0),
    (168, 526, 3.0),
    (168, 631, 5.0),
    (168, 799, 0.3),
    (168, 823, 15.0),
    (168, 835, 25.0),
    (169, 59, 0.6),
    (169, 412, 50.0),
    (169, 799, 0.3),
    (169, 813, 10.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (169, 835, 10.0),
    (169, 837, 30.0),
    (170, 28, 100.0),
    (171, 634, 33.333),
    (171, 635, 33.333),
    (171, 636, 33.333),
    (172, 28, 100.0),
    (173, 28, 100.0),
    (173, 59, 0.3),
    (173, 795, 7.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (174, 28, 100.0),
    (174, 59, 0.3),
    (175, 28, 100.0),
    (175, 59, 0.3),
    (175, 793, 7.0),
    (176, 28, 100.0),
    (176, 59, 0.3),
    (176, 799, 7.0),
    (177, 1, 7.0),
    (177, 28, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (177, 59, 0.3),
    (178, 28, 100.0),
    (178, 59, 0.3),
    (178, 796, 7.0),
    (179, 28, 100.0),
    (179, 59, 0.3),
    (179, 131, 1.0),
    (180, 28, 100.0),
    (180, 59, 0.3),
    (180, 795, 7.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (181, 28, 100.0),
    (181, 59, 0.3),
    (181, 799, 7.0),
    (182, 28, 100.0),
    (182, 59, 0.3),
    (182, 795, 7.0),
    (183, 28, 100.0),
    (183, 59, 0.3),
    (184, 28, 100.0),
    (184, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (184, 795, 7.0),
    (185, 31, 100.0),
    (185, 59, 0.7),
    (186, 29, 100.0),
    (187, 29, 100.0),
    (187, 59, 0.3),
    (187, 795, 7.0),
    (188, 29, 100.0),
    (188, 59, 0.3),
    (189, 29, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (189, 59, 0.3),
    (189, 795, 7.0),
    (190, 30, 100.0),
    (191, 30, 100.0),
    (191, 59, 0.3),
    (191, 795, 7.0),
    (192, 30, 100.0),
    (192, 59, 0.3),
    (193, 30, 100.0),
    (193, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (193, 795, 7.0),
    (194, 33, 100.0),
    (194, 59, 0.3),
    (194, 795, 7.0),
    (195, 34, 100.0),
    (195, 59, 0.3),
    (195, 795, 7.0),
    (196, 35, 100.0),
    (196, 59, 0.3),
    (197, 31, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (197, 59, 0.75),
    (197, 622, 120.0),
    (198, 239, 170.0),
    (198, 478, 114.0),
    (198, 634, 200.0),
    (198, 794, 14.0),
    (198, 797, 192.75),
    (199, 31, 100.0),
    (199, 59, 0.75),
    (199, 123, 9.167);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (200, 31, 300.0),
    (200, 59, 1.5),
    (200, 123, 73.326),
    (201, 31, 300.0),
    (201, 59, 1.5),
    (201, 130, 79.992),
    (202, 31, 300.0),
    (202, 59, 1.5),
    (202, 121, 78.326),
    (203, 31, 300.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (203, 59, 1.5),
    (203, 130, 79.992),
    (204, 31, 300.0),
    (204, 59, 1.5),
    (204, 129, 79.992),
    (205, 31, 300.0),
    (205, 59, 1.5),
    (205, 566, 81.659),
    (206, 31, 300.0),
    (206, 59, 1.5);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (206, 125, 78.326),
    (207, 31, 300.0),
    (207, 59, 1.5),
    (207, 122, 79.992),
    (208, 31, 300.0),
    (208, 59, 1.5),
    (208, 567, 85.325),
    (209, 28, 100.0),
    (209, 137, 128.0),
    (209, 480, 25.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (209, 799, 4.667),
    (210, 3, 35.0),
    (210, 28, 100.0),
    (210, 59, 0.3),
    (210, 461, 75.0),
    (210, 592, 160.0),
    (210, 811, 100.0),
    (211, 28, 100.0),
    (211, 59, 0.3),
    (211, 795, 7.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (212, 28, 100.0),
    (212, 59, 0.3),
    (212, 793, 7.0),
    (213, 28, 100.0),
    (213, 59, 0.3),
    (213, 799, 7.0),
    (214, 1, 7.0),
    (214, 28, 100.0),
    (214, 59, 0.3),
    (215, 28, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (215, 59, 0.3),
    (215, 796, 7.0),
    (216, 28, 100.0),
    (216, 59, 0.3),
    (216, 131, 1.0),
    (217, 28, 100.0),
    (217, 59, 0.3),
    (217, 795, 7.0),
    (218, 28, 100.0),
    (218, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (219, 28, 100.0),
    (219, 59, 0.3),
    (219, 799, 7.0),
    (220, 28, 100.0),
    (220, 59, 0.3),
    (220, 793, 7.0),
    (220, 809, 15.0),
    (221, 28, 100.0),
    (221, 59, 0.3),
    (221, 799, 7.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (221, 809, 15.0),
    (222, 1, 7.0),
    (222, 28, 100.0),
    (222, 59, 0.3),
    (222, 809, 15.0),
    (223, 28, 100.0),
    (223, 59, 0.3),
    (223, 796, 7.0),
    (223, 809, 15.0),
    (224, 28, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (224, 59, 0.3),
    (224, 131, 1.0),
    (224, 809, 15.0),
    (225, 28, 100.0),
    (225, 59, 0.3),
    (225, 809, 15.0),
    (226, 28, 100.0),
    (226, 59, 0.3),
    (226, 795, 7.0),
    (226, 811, 15.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (227, 28, 100.0),
    (227, 59, 0.3),
    (227, 793, 7.0),
    (227, 811, 15.0),
    (228, 28, 100.0),
    (228, 59, 0.3),
    (228, 799, 7.0),
    (228, 811, 15.0),
    (229, 1, 7.0),
    (229, 28, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (229, 59, 0.3),
    (229, 811, 15.0),
    (230, 28, 100.0),
    (230, 59, 0.3),
    (230, 796, 7.0),
    (230, 811, 15.0),
    (231, 28, 100.0),
    (231, 59, 0.3),
    (231, 131, 1.0),
    (231, 811, 15.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (232, 28, 100.0),
    (232, 59, 0.3),
    (232, 795, 7.0),
    (232, 811, 15.0),
    (233, 28, 100.0),
    (233, 59, 0.3),
    (233, 811, 15.0),
    (234, 28, 100.0),
    (234, 59, 0.3),
    (234, 795, 7.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (234, 809, 15.0),
    (234, 811, 10.0),
    (235, 28, 100.0),
    (235, 59, 0.3),
    (235, 793, 7.0),
    (235, 809, 15.0),
    (235, 811, 10.0),
    (236, 28, 100.0),
    (236, 59, 0.3),
    (236, 799, 7.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (236, 809, 15.0),
    (236, 811, 10.0),
    (237, 1, 7.0),
    (237, 28, 100.0),
    (237, 59, 0.3),
    (237, 809, 15.0),
    (237, 811, 10.0),
    (238, 28, 100.0),
    (238, 59, 0.3),
    (238, 796, 7.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (238, 809, 15.0),
    (238, 811, 10.0),
    (239, 28, 100.0),
    (239, 59, 0.3),
    (239, 131, 1.0),
    (239, 809, 15.0),
    (239, 811, 10.0),
    (240, 28, 100.0),
    (240, 59, 0.3),
    (240, 795, 7.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (240, 809, 15.0),
    (240, 811, 10.0),
    (241, 28, 100.0),
    (241, 59, 0.3),
    (241, 809, 15.0),
    (241, 811, 10.0),
    (242, 28, 100.0),
    (242, 59, 0.3),
    (242, 795, 7.0),
    (242, 833, 15.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (243, 28, 100.0),
    (243, 59, 0.3),
    (243, 833, 15.0),
    (244, 28, 100.0),
    (244, 59, 0.3),
    (244, 795, 7.0),
    (244, 833, 15.0),
    (245, 28, 100.0),
    (245, 59, 0.3),
    (245, 795, 7.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (245, 832, 15.0),
    (246, 28, 100.0),
    (246, 59, 0.3),
    (246, 832, 15.0),
    (247, 28, 100.0),
    (247, 59, 0.3),
    (247, 795, 7.0),
    (247, 832, 15.0),
    (248, 28, 100.0),
    (248, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (248, 795, 7.0),
    (248, 832, 8.0),
    (248, 833, 8.0),
    (249, 28, 100.0),
    (249, 59, 0.3),
    (249, 832, 8.0),
    (249, 833, 8.0),
    (250, 28, 100.0),
    (250, 59, 0.3),
    (250, 795, 7.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (250, 832, 8.0),
    (250, 833, 8.0),
    (251, 28, 100.0),
    (251, 59, 0.3),
    (251, 795, 7.0),
    (251, 834, 15.0),
    (252, 28, 100.0),
    (252, 59, 0.3),
    (252, 834, 15.0),
    (253, 28, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (253, 59, 0.3),
    (253, 795, 7.0),
    (253, 834, 15.0),
    (254, 28, 100.0),
    (254, 59, 0.3),
    (254, 795, 7.0),
    (254, 809, 15.0),
    (254, 833, 15.0),
    (255, 28, 100.0),
    (255, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (255, 809, 15.0),
    (255, 833, 15.0),
    (256, 28, 100.0),
    (256, 59, 0.3),
    (256, 795, 7.0),
    (256, 809, 15.0),
    (256, 833, 15.0),
    (257, 28, 100.0),
    (257, 59, 0.3),
    (257, 795, 7.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (257, 809, 15.0),
    (257, 832, 15.0),
    (258, 28, 100.0),
    (258, 59, 0.3),
    (258, 809, 15.0),
    (258, 832, 15.0),
    (259, 28, 100.0),
    (259, 59, 0.3),
    (259, 795, 7.0),
    (259, 809, 15.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (259, 832, 15.0),
    (260, 28, 100.0),
    (260, 59, 0.3),
    (260, 795, 7.0),
    (260, 809, 15.0),
    (260, 832, 8.0),
    (260, 833, 8.0),
    (261, 28, 100.0),
    (261, 59, 0.3),
    (261, 809, 15.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (261, 832, 8.0),
    (261, 833, 8.0),
    (262, 28, 100.0),
    (262, 59, 0.3),
    (262, 795, 7.0),
    (262, 809, 15.0),
    (262, 832, 8.0),
    (262, 833, 8.0),
    (263, 28, 100.0),
    (263, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (263, 795, 7.0),
    (263, 809, 15.0),
    (263, 834, 15.0),
    (264, 28, 100.0),
    (264, 59, 0.3),
    (264, 809, 15.0),
    (264, 834, 15.0),
    (265, 28, 100.0),
    (265, 59, 0.3),
    (265, 795, 7.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (265, 809, 15.0),
    (265, 834, 15.0),
    (266, 28, 100.0),
    (266, 59, 0.3),
    (266, 795, 7.0),
    (266, 811, 10.0),
    (266, 833, 15.0),
    (267, 28, 100.0),
    (267, 59, 0.3),
    (267, 811, 10.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (267, 833, 15.0),
    (268, 28, 100.0),
    (268, 59, 0.3),
    (268, 795, 7.0),
    (268, 811, 10.0),
    (268, 833, 15.0),
    (269, 28, 100.0),
    (269, 59, 0.3),
    (269, 795, 7.0),
    (269, 811, 10.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (269, 832, 15.0),
    (270, 28, 100.0),
    (270, 59, 0.3),
    (270, 811, 10.0),
    (270, 832, 15.0),
    (271, 28, 100.0),
    (271, 59, 0.3),
    (271, 795, 7.0),
    (271, 811, 10.0),
    (271, 832, 15.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (272, 28, 100.0),
    (272, 59, 0.3),
    (272, 795, 7.0),
    (272, 811, 15.0),
    (272, 832, 8.0),
    (272, 833, 8.0),
    (273, 28, 100.0),
    (273, 59, 0.3),
    (273, 811, 15.0),
    (273, 832, 8.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (273, 833, 8.0),
    (274, 28, 100.0),
    (274, 59, 0.3),
    (274, 795, 7.0),
    (274, 811, 15.0),
    (274, 832, 8.0),
    (274, 833, 8.0),
    (275, 28, 100.0),
    (275, 59, 0.3),
    (275, 795, 7.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (275, 811, 10.0),
    (275, 834, 15.0),
    (276, 28, 100.0),
    (276, 59, 0.3),
    (276, 811, 10.0),
    (276, 834, 15.0),
    (277, 28, 100.0),
    (277, 59, 0.3),
    (277, 795, 7.0),
    (277, 811, 10.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (277, 834, 15.0),
    (278, 28, 100.0),
    (278, 59, 0.3),
    (278, 795, 7.0),
    (278, 809, 15.0),
    (278, 811, 10.0),
    (278, 833, 8.0),
    (279, 28, 100.0),
    (279, 59, 0.3),
    (279, 809, 15.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (279, 811, 10.0),
    (279, 833, 8.0),
    (280, 28, 100.0),
    (280, 59, 0.3),
    (280, 795, 7.0),
    (280, 809, 15.0),
    (280, 811, 10.0),
    (280, 833, 8.0),
    (281, 28, 100.0),
    (281, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (281, 795, 7.0),
    (281, 809, 15.0),
    (281, 811, 10.0),
    (281, 832, 8.0),
    (282, 28, 100.0),
    (282, 59, 0.3),
    (282, 809, 15.0),
    (282, 811, 10.0),
    (282, 832, 8.0),
    (283, 28, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (283, 59, 0.3),
    (283, 795, 7.0),
    (283, 809, 15.0),
    (283, 811, 10.0),
    (283, 832, 8.0),
    (284, 28, 100.0),
    (284, 59, 0.3),
    (284, 795, 7.0),
    (284, 809, 15.0),
    (284, 811, 10.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (284, 832, 8.0),
    (284, 833, 8.0),
    (285, 28, 100.0),
    (285, 59, 0.3),
    (285, 809, 15.0),
    (285, 811, 10.0),
    (285, 832, 8.0),
    (285, 833, 8.0),
    (286, 28, 100.0),
    (286, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (286, 795, 7.0),
    (286, 809, 15.0),
    (286, 811, 10.0),
    (286, 832, 8.0),
    (286, 833, 8.0),
    (287, 28, 100.0),
    (287, 59, 0.3),
    (287, 795, 7.0),
    (287, 809, 15.0),
    (287, 811, 10.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (287, 834, 8.0),
    (288, 28, 100.0),
    (288, 59, 0.3),
    (288, 809, 15.0),
    (288, 811, 10.0),
    (288, 834, 8.0),
    (289, 28, 100.0),
    (289, 59, 0.3),
    (289, 795, 7.0),
    (289, 809, 15.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (289, 811, 10.0),
    (289, 834, 8.0),
    (290, 28, 100.0),
    (290, 59, 0.3),
    (290, 366, 10.0),
    (290, 795, 7.0),
    (290, 824, 5.0),
    (291, 28, 100.0),
    (291, 59, 0.3),
    (291, 366, 10.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (291, 824, 5.0),
    (292, 28, 100.0),
    (292, 59, 0.3),
    (292, 366, 10.0),
    (292, 795, 7.0),
    (292, 824, 5.0),
    (293, 545, 100.0),
    (294, 29, 100.0),
    (294, 59, 0.3),
    (294, 795, 7.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (295, 29, 100.0),
    (295, 59, 0.3),
    (295, 793, 7.0),
    (296, 29, 100.0),
    (296, 59, 0.3),
    (296, 799, 7.0),
    (297, 1, 7.0),
    (297, 29, 100.0),
    (297, 59, 0.3),
    (298, 29, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (298, 59, 0.3),
    (298, 131, 1.0),
    (299, 29, 100.0),
    (299, 59, 0.3),
    (299, 795, 7.0),
    (300, 29, 100.0),
    (300, 59, 0.3),
    (301, 29, 100.0),
    (301, 59, 0.3),
    (301, 795, 7.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (301, 809, 15.0),
    (302, 29, 100.0),
    (302, 59, 0.3),
    (302, 795, 7.0),
    (302, 811, 15.0),
    (303, 29, 100.0),
    (303, 59, 0.3),
    (303, 795, 7.0),
    (303, 832, 15.0),
    (304, 29, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (304, 59, 0.3),
    (304, 795, 7.0),
    (304, 809, 15.0),
    (304, 811, 10.0),
    (305, 29, 100.0),
    (305, 59, 0.3),
    (305, 795, 7.0),
    (305, 809, 15.0),
    (305, 832, 15.0),
    (306, 29, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (306, 59, 0.3),
    (306, 795, 7.0),
    (306, 811, 10.0),
    (306, 832, 15.0),
    (307, 29, 100.0),
    (307, 59, 0.3),
    (307, 795, 7.0),
    (307, 809, 15.0),
    (307, 811, 10.0),
    (307, 832, 8.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (308, 29, 132.0),
    (308, 61, 4.333),
    (308, 506, 25.0),
    (308, 507, 120.0),
    (309, 40, 100.0),
    (309, 59, 0.3),
    (309, 795, 7.0),
    (310, 40, 100.0),
    (310, 59, 0.3),
    (311, 40, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (311, 59, 0.3),
    (311, 795, 7.0),
    (311, 809, 15.0),
    (312, 40, 100.0),
    (312, 59, 0.3),
    (312, 795, 7.0),
    (312, 811, 15.0),
    (313, 40, 100.0),
    (313, 59, 0.3),
    (313, 795, 7.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (313, 832, 15.0),
    (314, 40, 100.0),
    (314, 59, 0.3),
    (314, 795, 7.0),
    (314, 809, 15.0),
    (314, 811, 10.0),
    (315, 40, 100.0),
    (315, 59, 0.3),
    (315, 795, 7.0),
    (315, 809, 15.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (315, 832, 15.0),
    (316, 40, 100.0),
    (316, 59, 0.3),
    (316, 795, 7.0),
    (316, 811, 10.0),
    (316, 832, 15.0),
    (317, 40, 100.0),
    (317, 59, 0.3),
    (317, 795, 7.0),
    (317, 809, 15.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (317, 811, 10.0),
    (317, 832, 8.0),
    (318, 639, 25.0),
    (318, 644, 75.0),
    (319, 639, 25.0),
    (319, 644, 75.0),
    (320, 640, 25.0),
    (320, 645, 75.0),
    (321, 641, 25.0),
    (321, 646, 75.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (322, 642, 25.0),
    (322, 647, 75.0),
    (323, 59, 1.0),
    (323, 436, 100.0),
    (323, 799, 10.0),
    (324, 638, 100.0),
    (325, 59, 0.6),
    (325, 436, 100.0),
    (325, 799, 7.0),
    (326, 59, 0.6);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (326, 436, 100.0),
    (327, 430, 54.0),
    (327, 453, 126.0),
    (327, 799, 7.0),
    (328, 430, 54.0),
    (328, 453, 126.0),
    (329, 453, 180.0),
    (329, 799, 7.0),
    (330, 639, 100.0),
    (331, 59, 0.6);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (331, 428, 100.0),
    (331, 799, 7.0),
    (332, 59, 0.6),
    (332, 428, 100.0),
    (333, 429, 72.0),
    (333, 452, 108.0),
    (333, 799, 7.0),
    (334, 429, 72.0),
    (334, 452, 108.0),
    (335, 452, 180.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (335, 799, 7.0),
    (336, 59, 1.0),
    (336, 428, 100.0),
    (336, 799, 10.0),
    (337, 639, 86.0),
    (337, 801, 7.0),
    (337, 802, 7.0),
    (338, 59, 0.6),
    (338, 437, 100.0),
    (338, 799, 7.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (339, 643, 100.0),
    (340, 59, 0.6),
    (340, 442, 100.0),
    (340, 799, 7.0),
    (341, 59, 0.6),
    (341, 433, 100.0),
    (341, 799, 7.0),
    (342, 644, 100.0),
    (343, 59, 0.6),
    (343, 434, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (343, 799, 7.0),
    (344, 59, 0.6),
    (344, 434, 100.0),
    (345, 59, 0.2),
    (345, 455, 180.0),
    (345, 799, 7.0),
    (346, 59, 0.2),
    (346, 455, 180.0),
    (347, 455, 180.0),
    (347, 799, 7.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (348, 59, 1.0),
    (348, 434, 100.0),
    (348, 799, 10.0),
    (349, 644, 86.0),
    (349, 801, 7.0),
    (349, 802, 7.0),
    (350, 648, 100.0),
    (351, 59, 0.6),
    (351, 431, 100.0),
    (351, 799, 7.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (352, 59, 0.6),
    (352, 431, 100.0),
    (353, 432, 90.0),
    (353, 454, 90.0),
    (353, 799, 7.0),
    (354, 432, 90.0),
    (354, 454, 90.0),
    (355, 454, 180.0),
    (355, 799, 7.0),
    (356, 59, 1.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (356, 431, 100.0),
    (356, 799, 10.0),
    (357, 648, 86.0),
    (357, 801, 7.0),
    (357, 802, 7.0),
    (358, 59, 0.6),
    (358, 435, 100.0),
    (358, 799, 7.0),
    (359, 59, 0.6),
    (359, 447, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (359, 799, 7.0),
    (360, 59, 0.6),
    (360, 443, 100.0),
    (360, 799, 7.0),
    (361, 427, 100.0),
    (362, 426, 100.0),
    (363, 59, 0.3),
    (363, 506, 2.5),
    (363, 649, 100.0),
    (363, 799, 0.5);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (364, 59, 0.4),
    (364, 354, 85.658),
    (364, 640, 46.25),
    (364, 645, 128.25),
    (365, 59, 0.4),
    (365, 354, 85.658),
    (365, 640, 44.0),
    (365, 645, 131.0),
    (365, 799, 14.0),
    (366, 446, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (367, 59, 0.1),
    (367, 563, 100.0),
    (367, 799, 3.0),
    (368, 650, 86.0),
    (368, 801, 7.0),
    (368, 802, 7.0),
    (369, 458, 100.0),
    (370, 427, 75.0),
    (370, 571, 10.0),
    (370, 579, 15.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (371, 427, 100.0),
    (372, 637, 86.0),
    (372, 801, 7.0),
    (372, 802, 7.0),
    (373, 59, 0.7),
    (373, 578, 100.0),
    (374, 652, 100.0),
    (375, 59, 0.6),
    (375, 440, 100.0),
    (375, 799, 7.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (376, 653, 100.0),
    (377, 59, 0.6),
    (377, 439, 100.0),
    (377, 799, 7.0),
    (378, 59, 0.6),
    (378, 439, 100.0),
    (379, 59, 0.3),
    (379, 456, 180.0),
    (379, 799, 7.0),
    (380, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (380, 456, 180.0),
    (381, 456, 180.0),
    (381, 799, 7.0),
    (382, 59, 0.6),
    (382, 445, 100.0),
    (383, 59, 0.6),
    (383, 445, 100.0),
    (383, 799, 7.0),
    (384, 543, 100.0),
    (385, 655, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (386, 59, 0.6),
    (386, 441, 100.0),
    (386, 799, 7.0),
    (387, 59, 0.6),
    (387, 441, 100.0),
    (388, 59, 0.9),
    (388, 441, 100.0),
    (388, 799, 7.0),
    (389, 2, 4.0),
    (389, 59, 0.8);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (389, 441, 96.0),
    (390, 568, 100.0),
    (391, 45, 1.25),
    (391, 49, 2.1),
    (391, 56, 1.133),
    (391, 59, 6.0),
    (391, 214, 13.75),
    (391, 308, 48.0),
    (391, 366, 46.8),
    (391, 412, 474.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (391, 441, 495.0),
    (391, 799, 28.0),
    (391, 823, 72.0),
    (391, 824, 63.0),
    (391, 830, 38.0),
    (392, 448, 100.0),
    (393, 59, 0.3),
    (393, 289, 100.0),
    (393, 795, 3.0),
    (394, 59, 0.6);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (394, 412, 35.0),
    (394, 428, 40.0),
    (394, 799, 0.5),
    (394, 835, 25.0),
    (395, 59, 1.3),
    (395, 412, 100.0),
    (395, 428, 50.0),
    (395, 799, 1.0),
    (395, 835, 50.0),
    (396, 311, 10.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (396, 449, 5.0),
    (396, 450, 10.0),
    (396, 632, 75.0),
    (397, 59, 0.9),
    (397, 412, 100.0),
    (397, 428, 50.0),
    (397, 799, 1.0),
    (397, 835, 50.0),
    (398, 59, 0.6),
    (398, 412, 35.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (398, 428, 35.0),
    (398, 799, 0.5),
    (398, 810, 10.0),
    (398, 835, 20.0),
    (399, 59, 0.6),
    (399, 235, 10.0),
    (399, 412, 35.0),
    (399, 445, 35.0),
    (399, 799, 0.5),
    (399, 835, 20.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (400, 59, 0.6),
    (400, 412, 35.0),
    (400, 445, 40.0),
    (400, 799, 0.5),
    (400, 835, 25.0),
    (401, 59, 1.3),
    (401, 412, 100.0),
    (401, 441, 50.0),
    (401, 799, 1.0),
    (401, 835, 50.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (402, 59, 0.9),
    (402, 412, 100.0),
    (402, 441, 50.0),
    (402, 799, 1.0),
    (402, 835, 50.0),
    (403, 59, 0.6),
    (403, 412, 35.0),
    (403, 441, 40.0),
    (403, 799, 0.5),
    (403, 835, 25.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (404, 59, 0.6),
    (404, 412, 35.0),
    (404, 441, 35.0),
    (404, 799, 0.5),
    (404, 810, 10.0),
    (404, 835, 20.0),
    (405, 59, 0.5),
    (405, 412, 35.0),
    (405, 441, 10.0),
    (405, 682, 5.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (405, 798, 15.0),
    (405, 799, 0.3),
    (405, 835, 10.0),
    (405, 837, 25.0),
    (406, 1, 56.0),
    (406, 51, 0.575),
    (406, 59, 6.0),
    (406, 274, 300.0),
    (406, 732, 300.0),
    (406, 308, 640.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (406, 310, 60.0),
    (406, 352, 255.0),
    (406, 412, 948.0),
    (406, 505, 4.583),
    (407, 451, 70.0),
    (407, 479, 60.0),
    (408, 451, 70.0),
    (408, 479, 60.0),
    (408, 809, 21.0),
    (409, 460, 60.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (409, 602, 30.0),
    (409, 651, 70.0),
    (409, 804, 10.0),
    (409, 805, 8.0),
    (409, 806, 15.0),
    (409, 808, 20.0),
    (410, 59, 0.6),
    (410, 412, 30.0),
    (410, 457, 10.0),
    (410, 835, 10.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (410, 837, 50.0),
    (411, 398, 100.0),
    (412, 398, 90.0),
    (412, 506, 4.8),
    (413, 53, 0.1),
    (413, 57, 6.0),
    (413, 59, 0.4),
    (413, 291, 6.0),
    (413, 351, 492.0),
    (413, 658, 312.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (413, 800, 56.0),
    (414, 463, 100.0),
    (415, 483, 1.0),
    (415, 509, 1.3),
    (415, 526, 44.45),
    (415, 527, 44.45),
    (415, 799, 8.8),
    (416, 477, 100.0),
    (417, 470, 100.0),
    (418, 96, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (419, 59, 1.0),
    (419, 126, 3.0),
    (419, 392, 5.0),
    (419, 413, 28.0),
    (419, 484, 1.0),
    (419, 506, 2.0),
    (419, 525, 31.0),
    (419, 527, 29.0),
    (420, 552, 100.0),
    (421, 659, 10.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (421, 660, 15.0),
    (421, 661, 75.0),
    (422, 112, 100.0),
    (423, 94, 50.0),
    (423, 95, 50.0),
    (424, 95, 25.0),
    (424, 117, 75.0),
    (425, 472, 100.0),
    (426, 475, 100.0),
    (427, 465, 55.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (427, 476, 35.0),
    (427, 506, 5.0),
    (427, 524, 5.0),
    (428, 485, 100.0),
    (429, 469, 100.0),
    (430, 485, 100.0),
    (431, 485, 100.0),
    (432, 472, 100.0),
    (433, 472, 100.0),
    (434, 472, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (435, 488, 100.0),
    (436, 467, 100.0),
    (437, 467, 100.0),
    (438, 467, 100.0),
    (439, 489, 100.0),
    (440, 486, 100.0),
    (441, 548, 100.0),
    (442, 468, 100.0),
    (443, 468, 50.0),
    (443, 541, 50.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (444, 469, 100.0),
    (445, 471, 100.0),
    (446, 569, 100.0),
    (447, 544, 100.0),
    (448, 59, 0.3),
    (448, 544, 92.0),
    (448, 657, 8.0),
    (449, 490, 100.0),
    (450, 59, 0.8),
    (450, 413, 9.2);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (450, 522, 85.0),
    (450, 523, 5.0),
    (451, 547, 100.0),
    (452, 474, 100.0),
    (453, 474, 100.0),
    (454, 126, 10.0),
    (454, 549, 90.0),
    (455, 549, 100.0),
    (456, 550, 100.0),
    (457, 473, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (458, 10, 2.0),
    (458, 126, 10.0),
    (458, 549, 88.0),
    (459, 551, 100.0),
    (460, 532, 100.0),
    (461, 475, 50.0),
    (461, 476, 50.0),
    (462, 475, 50.0),
    (462, 476, 50.0),
    (463, 475, 50.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (463, 476, 50.0),
    (464, 487, 100.0),
    (465, 475, 50.0),
    (465, 476, 50.0),
    (466, 475, 50.0),
    (466, 476, 50.0),
    (467, 475, 50.0),
    (467, 476, 50.0),
    (468, 488, 100.0),
    (469, 552, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (470, 552, 100.0),
    (471, 117, 100.0),
    (472, 68, 100.0),
    (473, 68, 100.0),
    (474, 118, 50.0),
    (474, 572, 50.0),
    (475, 117, 80.0),
    (475, 118, 20.0),
    (476, 541, 100.0),
    (477, 542, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (478, 59, 0.24),
    (478, 530, 100.0),
    (479, 59, 0.6),
    (479, 531, 100.0),
    (480, 59, 0.75),
    (480, 534, 140.0),
    (481, 532, 100.0),
    (482, 412, 76.0),
    (482, 444, 24.0),
    (483, 59, 0.6);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (483, 535, 100.0),
    (484, 59, 0.6),
    (484, 533, 100.0),
    (485, 59, 0.6),
    (485, 534, 100.0),
    (486, 537, 100.0),
    (487, 59, 0.75),
    (487, 510, 157.0),
    (487, 792, 5.0),
    (488, 59, 0.75);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (488, 511, 198.0),
    (488, 792, 9.333),
    (489, 59, 0.75),
    (489, 516, 174.0),
    (490, 11, 30.0),
    (490, 59, 0.5),
    (490, 142, 40.0),
    (490, 412, 210.0),
    (491, 11, 30.0),
    (491, 59, 1.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (491, 142, 40.0),
    (491, 412, 210.0),
    (491, 505, 25.0),
    (492, 59, 0.4),
    (492, 142, 40.0),
    (492, 412, 240.0),
    (492, 792, 5.0),
    (493, 59, 0.4),
    (493, 142, 40.0),
    (493, 412, 240.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (494, 59, 0.4),
    (494, 142, 40.0),
    (494, 412, 240.0),
    (494, 792, 5.0),
    (495, 59, 0.4),
    (495, 142, 40.0),
    (495, 592, 240.0),
    (496, 59, 0.4),
    (496, 142, 40.0),
    (496, 592, 240.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (496, 792, 5.0),
    (497, 59, 0.4),
    (497, 142, 40.0),
    (497, 593, 240.0),
    (498, 59, 0.4),
    (498, 142, 40.0),
    (498, 593, 240.0),
    (498, 792, 5.0),
    (499, 143, 28.0),
    (499, 412, 120.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (500, 143, 28.0),
    (500, 412, 120.0),
    (500, 792, 5.0),
    (501, 143, 28.0),
    (501, 592, 120.0),
    (502, 143, 28.0),
    (502, 592, 120.0),
    (502, 792, 5.0),
    (503, 143, 28.0),
    (503, 593, 120.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (504, 143, 28.0),
    (504, 593, 120.0),
    (504, 792, 5.0),
    (505, 145, 43.0),
    (505, 412, 120.0),
    (506, 145, 43.0),
    (506, 412, 120.0),
    (506, 792, 5.0),
    (507, 145, 41.0),
    (507, 147, 2.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (507, 412, 120.0),
    (508, 145, 41.0),
    (508, 147, 2.0),
    (508, 412, 120.0),
    (508, 792, 5.0),
    (509, 143, 15.0),
    (509, 145, 20.0),
    (509, 412, 120.0),
    (510, 59, 0.4),
    (510, 144, 40.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (510, 412, 240.0),
    (511, 59, 0.75),
    (511, 536, 185.0),
    (511, 792, 9.333),
    (512, 59, 0.75),
    (512, 536, 185.0),
    (513, 59, 0.75),
    (513, 536, 185.0),
    (513, 792, 9.333),
    (514, 663, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (515, 59, 1.0),
    (515, 520, 158.0),
    (516, 59, 1.002),
    (516, 520, 158.0),
    (516, 799, 4.667),
    (517, 1, 4.667),
    (517, 59, 1.002),
    (517, 520, 158.0),
    (518, 59, 1.002),
    (518, 520, 158.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (518, 793, 4.667),
    (519, 59, 1.0),
    (519, 520, 158.0),
    (519, 795, 4.666),
    (520, 59, 1.002),
    (520, 520, 158.0),
    (521, 59, 1.0),
    (521, 817, 195.0),
    (522, 59, 1.002),
    (522, 799, 4.667);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (522, 817, 195.0),
    (523, 1, 4.667),
    (523, 59, 1.002),
    (523, 817, 195.0),
    (524, 59, 1.002),
    (524, 793, 4.667),
    (524, 817, 195.0),
    (525, 59, 1.0),
    (525, 795, 4.666),
    (525, 817, 195.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (526, 59, 1.002),
    (526, 817, 195.0),
    (527, 59, 6.0),
    (527, 519, 185.0),
    (527, 592, 732.0),
    (528, 59, 1.5),
    (528, 502, 10.0),
    (528, 520, 158.0),
    (529, 59, 0.6),
    (529, 412, 70.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (529, 520, 30.0),
    (530, 412, 474.0),
    (530, 557, 141.75),
    (531, 412, 474.0),
    (531, 557, 141.75),
    (532, 412, 474.0),
    (532, 557, 141.75),
    (532, 794, 14.0),
    (533, 59, 1.002),
    (533, 521, 174.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (534, 59, 1.002),
    (534, 529, 164.0),
    (534, 799, 4.667),
    (535, 59, 1.002),
    (535, 529, 164.0),
    (536, 59, 1.002),
    (536, 529, 164.0),
    (536, 799, 4.667),
    (537, 59, 7.3),
    (537, 412, 550.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (537, 519, 130.0),
    (537, 528, 25.0),
    (538, 59, 1.002),
    (538, 518, 165.75),
    (538, 529, 24.6),
    (539, 59, 7.3),
    (539, 412, 552.921),
    (539, 519, 127.0),
    (539, 528, 24.0),
    (539, 794, 14.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (540, 59, 7.3),
    (540, 412, 552.921),
    (540, 519, 127.0),
    (540, 528, 24.0),
    (540, 794, 14.0),
    (541, 59, 1.002),
    (541, 518, 165.75),
    (541, 529, 24.6),
    (541, 799, 4.667),
    (542, 59, 7.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (542, 412, 552.921),
    (542, 517, 127.0),
    (542, 528, 24.0),
    (542, 794, 14.0),
    (543, 59, 12.0),
    (543, 412, 711.0),
    (543, 519, 370.0),
    (543, 799, 56.0),
    (544, 59, 0.75),
    (544, 512, 135.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (545, 59, 0.75),
    (545, 512, 135.0),
    (545, 792, 9.333),
    (546, 59, 0.75),
    (546, 512, 135.0),
    (547, 59, 0.75),
    (547, 514, 157.0),
    (548, 91, 100.0),
    (549, 92, 100.0),
    (550, 93, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (551, 93, 95.0),
    (551, 154, 5.0),
    (552, 116, 95.0),
    (552, 154, 5.0),
    (553, 116, 100.0),
    (554, 92, 95.0),
    (554, 154, 5.0),
    (555, 667, 100.0),
    (556, 69, 60.0),
    (556, 93, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (556, 522, 12.0),
    (557, 69, 60.0),
    (557, 92, 3.0),
    (557, 142, 12.0),
    (558, 69, 60.0),
    (558, 116, 3.0),
    (558, 142, 6.0),
    (558, 522, 6.0),
    (559, 69, 60.0),
    (559, 116, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (559, 142, 6.0),
    (559, 506, 5.0),
    (559, 522, 6.0),
    (559, 694, 30.0),
    (560, 69, 60.0),
    (560, 92, 3.0),
    (560, 142, 12.0),
    (560, 506, 5.0),
    (560, 694, 30.0),
    (561, 69, 60.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (561, 93, 3.0),
    (561, 506, 5.0),
    (561, 522, 12.0),
    (561, 694, 30.0),
    (562, 51, 0.288),
    (562, 59, 36.0),
    (562, 62, 2.5),
    (562, 185, 27.2),
    (562, 291, 6.0),
    (562, 318, 453.6);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (562, 351, 123.0),
    (562, 354, 226.8),
    (562, 376, 113.4),
    (562, 412, 2133.0),
    (562, 519, 462.5),
    (562, 628, 1008.0),
    (562, 731, 120.0),
    (562, 800, 5.833),
    (563, 59, 12.0),
    (563, 120, 24.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (563, 132, 561.0),
    (563, 185, 13.2),
    (563, 236, 42.0),
    (563, 309, 70.0),
    (563, 734, 70.0),
    (563, 320, 119.0),
    (563, 323, 852.0),
    (563, 351, 91.0),
    (563, 412, 782.1),
    (563, 520, 584.6);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (564, 3, 56.5),
    (564, 59, 1.5),
    (564, 274, 30.0),
    (564, 732, 30.0),
    (564, 320, 296.0),
    (564, 461, 11.25),
    (564, 626, 123.0),
    (564, 799, 42.0),
    (565, 3, 56.5),
    (565, 28, 50.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (565, 53, 0.525),
    (565, 59, 1.5),
    (565, 140, 68.25),
    (565, 274, 15.0),
    (565, 732, 15.0),
    (565, 320, 296.0),
    (565, 520, 158.0),
    (565, 626, 123.0),
    (565, 799, 42.0),
    (566, 3, 56.5);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (566, 59, 1.5),
    (566, 274, 30.0),
    (566, 732, 30.0),
    (566, 320, 296.0),
    (566, 461, 11.25),
    (566, 520, 158.0),
    (566, 799, 42.0),
    (567, 53, 0.263),
    (567, 59, 0.75),
    (567, 310, 13.125);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (567, 321, 8.5),
    (567, 351, 142.0),
    (567, 520, 52.614),
    (567, 626, 30.75),
    (567, 799, 4.667),
    (568, 53, 0.263),
    (568, 59, 0.75),
    (568, 351, 142.0),
    (568, 520, 79.0),
    (568, 799, 4.667);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (568, 824, 26.2),
    (568, 826, 17.0),
    (569, 461, 60.0),
    (569, 783, 10.0),
    (569, 784, 15.0),
    (569, 785, 15.0),
    (569, 804, 10.0),
    (569, 805, 8.0),
    (569, 806, 15.0),
    (569, 807, 10.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (569, 808, 20.0),
    (570, 461, 60.0),
    (570, 783, 10.0),
    (570, 784, 15.0),
    (570, 785, 15.0),
    (570, 804, 10.0),
    (570, 805, 8.0),
    (570, 806, 15.0),
    (570, 807, 10.0),
    (570, 808, 20.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (570, 809, 21.0),
    (571, 783, 10.0),
    (571, 784, 15.0),
    (571, 785, 15.0),
    (571, 804, 10.0),
    (571, 805, 8.0),
    (571, 806, 15.0),
    (571, 807, 10.0),
    (571, 808, 20.0),
    (571, 815, 60.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (572, 783, 10.0),
    (572, 784, 15.0),
    (572, 785, 15.0),
    (572, 804, 10.0),
    (572, 805, 8.0),
    (572, 806, 15.0),
    (572, 807, 10.0),
    (572, 808, 20.0),
    (572, 809, 21.0),
    (572, 815, 60.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (573, 481, 60.0),
    (573, 783, 10.0),
    (573, 784, 15.0),
    (573, 785, 15.0),
    (573, 804, 10.0),
    (573, 805, 8.0),
    (573, 806, 15.0),
    (573, 807, 10.0),
    (573, 808, 20.0),
    (573, 809, 21.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (574, 633, 33.0),
    (574, 656, 33.0),
    (574, 786, 33.0),
    (575, 669, 50.0),
    (575, 670, 50.0),
    (576, 59, 0.6),
    (576, 412, 50.0),
    (576, 799, 0.3),
    (576, 812, 10.0),
    (576, 816, 15.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (576, 835, 10.0),
    (576, 837, 15.0),
    (577, 59, 0.6),
    (577, 412, 50.0),
    (577, 510, 15.0),
    (577, 799, 0.3),
    (577, 810, 10.0),
    (577, 835, 10.0),
    (577, 837, 15.0),
    (578, 59, 1.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (578, 412, 100.0),
    (578, 531, 30.0),
    (578, 799, 0.5),
    (578, 812, 10.0),
    (578, 823, 20.0),
    (578, 835, 40.0),
    (579, 59, 0.6),
    (579, 412, 50.0),
    (579, 531, 15.0),
    (579, 799, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (579, 812, 10.0),
    (579, 835, 10.0),
    (579, 837, 15.0),
    (580, 59, 0.9),
    (580, 412, 100.0),
    (580, 799, 0.5),
    (580, 812, 10.0),
    (580, 818, 30.0),
    (580, 823, 20.0),
    (580, 835, 40.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (581, 28, 15.0),
    (581, 59, 0.6),
    (581, 412, 50.0),
    (581, 469, 10.0),
    (581, 799, 0.3),
    (581, 835, 25.0),
    (582, 139, 15.0),
    (582, 412, 85.0),
    (583, 675, 100.0),
    (584, 59, 0.9);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (584, 265, 5.0),
    (584, 311, 5.0),
    (584, 412, 25.0),
    (584, 533, 50.0),
    (584, 799, 2.4),
    (584, 810, 15.0),
    (585, 59, 0.9),
    (585, 265, 5.0),
    (585, 311, 5.0),
    (585, 412, 25.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (585, 533, 50.0),
    (585, 799, 2.4),
    (585, 812, 15.0),
    (586, 59, 0.9),
    (586, 265, 5.0),
    (586, 311, 5.0),
    (586, 412, 25.0),
    (586, 533, 50.0),
    (586, 799, 2.4),
    (586, 813, 15.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (587, 59, 0.9),
    (587, 265, 5.0),
    (587, 311, 5.0),
    (587, 412, 25.0),
    (587, 450, 15.0),
    (587, 533, 50.0),
    (587, 799, 2.4),
    (588, 28, 10.0),
    (588, 671, 30.0),
    (588, 672, 30.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (588, 673, 30.0),
    (589, 28, 10.0),
    (589, 674, 90.0),
    (590, 632, 75.0),
    (590, 668, 25.0),
    (591, 59, 0.7),
    (591, 353, 15.0),
    (591, 412, 40.0),
    (591, 533, 40.0),
    (591, 799, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (591, 824, 5.0),
    (592, 59, 0.5),
    (592, 412, 50.0),
    (592, 491, 15.0),
    (592, 799, 0.3),
    (592, 812, 10.0),
    (592, 835, 10.0),
    (592, 837, 15.0),
    (593, 189, 100.0),
    (594, 168, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (595, 169, 100.0),
    (596, 173, 100.0),
    (597, 174, 100.0),
    (598, 177, 100.0),
    (599, 186, 50.0),
    (599, 187, 50.0),
    (600, 676, 50.0),
    (600, 677, 50.0),
    (601, 190, 100.0),
    (602, 190, 95.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (602, 506, 5.0),
    (603, 189, 100.0),
    (604, 680, 100.0),
    (605, 146, 20.0),
    (605, 153, 30.0),
    (605, 158, 5.0),
    (605, 186, 15.0),
    (605, 211, 10.0),
    (605, 215, 5.0),
    (605, 683, 15.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (606, 59, 2.5),
    (606, 62, 5.0),
    (606, 146, 21.0),
    (606, 180, 21.0),
    (606, 195, 21.0),
    (606, 205, 21.0),
    (606, 413, 5.0),
    (606, 506, 5.0),
    (607, 226, 20.0),
    (607, 227, 20.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (607, 228, 20.0),
    (607, 229, 20.0),
    (607, 230, 20.0),
    (608, 219, 100.0),
    (608, 506, 7.0),
    (609, 219, 100.0),
    (610, 219, 100.0),
    (610, 506, 7.0),
    (611, 504, 100.0),
    (612, 36, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (612, 146, 90.0),
    (612, 505, 7.0),
    (613, 149, 100.0),
    (614, 150, 92.0),
    (614, 506, 8.0),
    (615, 152, 100.0),
    (616, 153, 90.0),
    (616, 584, 10.0),
    (617, 36, 3.0),
    (617, 153, 90.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (617, 505, 7.0),
    (618, 181, 100.0),
    (619, 181, 33.0),
    (619, 182, 33.0),
    (619, 215, 33.0),
    (620, 161, 100.0),
    (621, 216, 100.0),
    (622, 162, 100.0),
    (623, 163, 92.0),
    (623, 506, 8.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (624, 162, 100.0),
    (625, 681, 100.0),
    (626, 166, 100.0),
    (627, 166, 75.0),
    (627, 413, 20.0),
    (627, 506, 5.0),
    (628, 171, 100.0),
    (629, 172, 100.0),
    (630, 179, 100.0),
    (631, 182, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (632, 180, 100.0),
    (633, 180, 75.0),
    (633, 413, 20.0),
    (633, 506, 5.0),
    (634, 180, 100.0),
    (635, 183, 100.0),
    (636, 191, 100.0),
    (637, 191, 75.0),
    (637, 413, 20.0),
    (637, 506, 5.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (638, 193, 100.0),
    (639, 195, 100.0),
    (640, 684, 50.0),
    (640, 685, 50.0),
    (641, 196, 92.0),
    (641, 506, 8.0),
    (642, 148, 12.0),
    (642, 196, 88.0),
    (643, 195, 100.0),
    (644, 198, 60.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (644, 221, 40.0),
    (645, 217, 100.0),
    (646, 686, 50.0),
    (646, 687, 50.0),
    (647, 199, 92.0),
    (647, 506, 8.0),
    (648, 148, 12.0),
    (648, 199, 88.0),
    (649, 201, 100.0),
    (650, 205, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (651, 205, 75.0),
    (651, 413, 20.0),
    (651, 506, 5.0),
    (652, 206, 100.0),
    (653, 210, 100.0),
    (653, 412, 5.0),
    (653, 506, 15.0),
    (654, 214, 100.0),
    (655, 215, 100.0),
    (656, 158, 30.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (656, 211, 70.0),
    (657, 157, 25.0),
    (657, 159, 25.0),
    (657, 209, 25.0),
    (657, 213, 25.0),
    (658, 155, 100.0),
    (659, 157, 100.0),
    (660, 158, 100.0),
    (661, 218, 100.0),
    (662, 159, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (663, 164, 100.0),
    (664, 165, 100.0),
    (665, 209, 100.0),
    (666, 209, 100.0),
    (667, 211, 100.0),
    (668, 212, 100.0),
    (669, 213, 100.0),
    (670, 153, 354.0),
    (670, 186, 786.0),
    (670, 202, 452.5);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (670, 386, 40.0),
    (670, 507, 30.0),
    (671, 146, 62.5),
    (671, 153, 75.0),
    (671, 181, 39.0),
    (671, 211, 76.0),
    (671, 215, 38.0),
    (671, 683, 46.0),
    (672, 146, 62.5),
    (672, 153, 75.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (672, 181, 39.0),
    (672, 186, 90.0),
    (672, 211, 76.0),
    (672, 215, 38.0),
    (672, 683, 46.0),
    (673, 689, 50.0),
    (673, 690, 50.0),
    (674, 167, 92.0),
    (674, 506, 8.0),
    (675, 148, 12.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (675, 167, 88.0),
    (676, 180, 20.0),
    (676, 181, 20.0),
    (676, 195, 20.0),
    (676, 202, 20.0),
    (676, 213, 20.0),
    (677, 123, 55.0),
    (677, 146, 250.0),
    (677, 274, 30.0),
    (677, 732, 30.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (677, 391, 30.0),
    (677, 683, 75.5),
    (678, 146, 75.0),
    (678, 492, 25.0),
    (679, 211, 453.6),
    (679, 493, 126.0),
    (680, 123, 73.326),
    (680, 146, 62.5),
    (680, 153, 75.0),
    (680, 202, 82.5);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (680, 391, 30.0),
    (680, 683, 46.0),
    (681, 13, 39.829),
    (681, 146, 62.5),
    (681, 153, 75.0),
    (681, 202, 82.5),
    (681, 391, 30.0),
    (681, 683, 46.0),
    (682, 15, 24.998),
    (682, 146, 62.5);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (682, 153, 75.0),
    (682, 202, 82.5),
    (682, 391, 30.0),
    (682, 683, 46.0),
    (683, 123, 73.326),
    (683, 146, 62.5),
    (683, 153, 75.0),
    (683, 202, 82.5),
    (683, 391, 30.0),
    (683, 495, 23.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (683, 683, 46.0),
    (684, 146, 62.5),
    (684, 153, 75.0),
    (684, 186, 90.0),
    (684, 391, 30.0),
    (684, 499, 86.658),
    (684, 683, 46.0),
    (685, 146, 62.5),
    (685, 153, 75.0),
    (685, 202, 82.5);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (685, 391, 30.0),
    (685, 499, 86.658),
    (685, 683, 46.0),
    (686, 123, 73.326),
    (686, 146, 62.5),
    (686, 153, 75.0),
    (686, 186, 90.0),
    (686, 391, 30.0),
    (686, 683, 46.0),
    (687, 13, 39.829);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (687, 146, 62.5),
    (687, 153, 75.0),
    (687, 186, 90.0),
    (687, 391, 30.0),
    (687, 683, 46.0),
    (688, 15, 24.998),
    (688, 146, 62.5),
    (688, 153, 75.0),
    (688, 186, 90.0),
    (688, 391, 30.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (688, 683, 46.0),
    (689, 123, 73.326),
    (689, 146, 62.5),
    (689, 153, 75.0),
    (689, 186, 90.0),
    (689, 391, 30.0),
    (689, 495, 23.0),
    (689, 683, 46.0),
    (690, 28, 250.0),
    (690, 176, 2.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (690, 178, 62.0),
    (690, 389, 49.5),
    (690, 506, 150.0),
    (691, 123, 13.75),
    (691, 202, 165.0),
    (691, 299, 5.0),
    (692, 181, 20.0),
    (692, 190, 20.0),
    (692, 215, 20.0),
    (692, 412, 20.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (692, 688, 20.0),
    (693, 679, 25.0),
    (693, 691, 25.0),
    (693, 692, 25.0),
    (693, 693, 25.0),
    (694, 225, 100.0),
    (695, 225, 75.0),
    (695, 573, 25.0),
    (696, 233, 100.0),
    (697, 156, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (698, 158, 65.0),
    (698, 413, 35.0),
    (699, 573, 100.0),
    (700, 170, 50.0),
    (700, 587, 50.0),
    (701, 231, 100.0),
    (702, 192, 100.0),
    (703, 194, 100.0),
    (704, 220, 100.0),
    (705, 224, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (706, 207, 100.0),
    (707, 211, 65.0),
    (707, 413, 35.0),
    (708, 215, 100.0),
    (709, 223, 100.0),
    (710, 151, 100.0),
    (711, 153, 35.0),
    (711, 413, 55.0),
    (711, 506, 10.0),
    (712, 181, 40.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (712, 413, 48.0),
    (712, 506, 12.5),
    (713, 232, 100.0),
    (714, 223, 100.0),
    (715, 197, 100.0),
    (716, 192, 100.0),
    (717, 194, 40.0),
    (717, 413, 48.0),
    (717, 506, 12.0),
    (718, 200, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (719, 222, 100.0),
    (720, 80, 30.0),
    (720, 85, 10.0),
    (720, 87, 10.0),
    (720, 580, 50.0),
    (721, 694, 100.0),
    (722, 694, 100.0),
    (723, 142, 3.0),
    (723, 666, 1.0),
    (723, 694, 96.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (724, 603, 20.0),
    (724, 604, 20.0),
    (724, 694, 60.0),
    (725, 694, 60.0),
    (725, 787, 40.0),
    (726, 694, 60.0),
    (726, 787, 40.0),
    (727, 142, 3.0),
    (727, 665, 1.0),
    (727, 694, 48.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (727, 787, 48.0),
    (728, 603, 20.0),
    (728, 604, 20.0),
    (728, 694, 30.0),
    (728, 787, 30.0),
    (729, 142, 3.0),
    (729, 624, 10.0),
    (729, 665, 1.0),
    (729, 694, 43.0),
    (729, 787, 43.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (730, 142, 3.0),
    (730, 624, 10.0),
    (730, 666, 1.0),
    (730, 694, 86.0),
    (731, 80, 100.0),
    (732, 81, 100.0),
    (733, 580, 100.0),
    (734, 580, 100.0),
    (735, 85, 100.0),
    (736, 86, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (737, 87, 100.0),
    (738, 88, 100.0),
    (739, 89, 100.0),
    (740, 180, 100.0),
    (741, 696, 100.0),
    (742, 90, 100.0),
    (743, 582, 100.0),
    (744, 696, 100.0),
    (745, 577, 100.0),
    (746, 570, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (747, 603, 30.0),
    (747, 694, 60.0),
    (747, 695, 10.0),
    (748, 97, 100.0),
    (749, 98, 100.0),
    (750, 59, 3.0),
    (750, 325, 453.6),
    (750, 731, 75.0),
    (751, 135, 90.0),
    (751, 325, 156.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (752, 135, 90.0),
    (752, 325, 156.0),
    (753, 136, 90.0),
    (753, 325, 156.0),
    (754, 699, 100.0),
    (755, 3, 45.0),
    (755, 11, 60.0),
    (755, 59, 1.3),
    (755, 324, 100.0),
    (755, 526, 5.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (755, 792, 13.0),
    (756, 3, 45.0),
    (756, 59, 0.8),
    (756, 324, 100.0),
    (756, 526, 3.0),
    (756, 592, 50.0),
    (756, 792, 4.0),
    (757, 3, 45.0),
    (757, 59, 0.8),
    (757, 238, 8.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (757, 324, 100.0),
    (757, 526, 3.0),
    (757, 592, 50.0),
    (757, 792, 7.0),
    (758, 3, 45.0),
    (758, 59, 1.4),
    (758, 324, 100.0),
    (758, 526, 5.0),
    (758, 592, 60.0),
    (758, 792, 6.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (759, 3, 45.0),
    (759, 59, 1.4),
    (759, 238, 8.0),
    (759, 324, 100.0),
    (759, 526, 5.0),
    (759, 592, 60.0),
    (759, 792, 6.0),
    (760, 3, 45.0),
    (760, 59, 1.3),
    (760, 324, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (760, 526, 5.0),
    (760, 592, 60.0),
    (760, 792, 10.0),
    (761, 3, 45.0),
    (761, 59, 1.3),
    (761, 238, 8.0),
    (761, 324, 100.0),
    (761, 526, 5.0),
    (761, 592, 60.0),
    (761, 792, 13.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (762, 700, 100.0),
    (763, 539, 100.0),
    (764, 136, 25.0),
    (764, 539, 100.0),
    (765, 556, 100.0),
    (766, 11, 25.0),
    (766, 59, 0.6),
    (766, 324, 100.0),
    (766, 792, 3.0),
    (767, 3, 12.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (767, 700, 100.0),
    (768, 136, 25.0),
    (768, 700, 100.0),
    (769, 700, 100.0),
    (770, 11, 25.0),
    (770, 59, 1.1),
    (770, 324, 100.0),
    (770, 792, 9.0),
    (771, 136, 25.0),
    (771, 701, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (772, 18, 80.0),
    (772, 59, 1.2),
    (772, 326, 42.0),
    (772, 412, 160.0),
    (772, 793, 7.0),
    (773, 11, 80.0),
    (773, 59, 1.5),
    (773, 326, 42.0),
    (773, 412, 160.0),
    (773, 792, 14.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (774, 11, 80.0),
    (774, 59, 1.5),
    (774, 326, 42.0),
    (774, 412, 160.0),
    (774, 792, 14.0),
    (775, 3, 12.0),
    (775, 702, 100.0),
    (776, 136, 25.0),
    (776, 702, 100.0),
    (777, 556, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (778, 3, 12.0),
    (778, 556, 100.0),
    (779, 136, 25.0),
    (779, 556, 100.0),
    (780, 31, 150.0),
    (780, 58, 15.625),
    (780, 59, 6.6),
    (780, 62, 30.0),
    (780, 123, 165.0),
    (780, 274, 4.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (780, 732, 4.0),
    (780, 309, 20.0),
    (780, 734, 20.0),
    (780, 324, 835.0),
    (780, 377, 15.313),
    (781, 540, 100.0),
    (782, 31, 150.0),
    (782, 58, 15.625),
    (782, 59, 1.5),
    (782, 62, 30.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (782, 130, 180.0),
    (782, 274, 40.0),
    (782, 732, 40.0),
    (782, 309, 20.0),
    (782, 734, 20.0),
    (782, 325, 835.0),
    (782, 377, 15.313),
    (783, 31, 150.0),
    (783, 58, 15.625),
    (783, 59, 1.5);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (783, 62, 30.0),
    (783, 121, 176.25),
    (783, 274, 40.0),
    (783, 732, 40.0),
    (783, 309, 20.0),
    (783, 734, 20.0),
    (783, 325, 835.0),
    (783, 377, 15.313),
    (784, 31, 150.0),
    (784, 58, 15.625);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (784, 59, 1.5),
    (784, 62, 30.0),
    (784, 130, 180.0),
    (784, 274, 40.0),
    (784, 732, 40.0),
    (784, 309, 20.0),
    (784, 734, 20.0),
    (784, 325, 835.0),
    (784, 377, 15.313),
    (785, 31, 150.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (785, 59, 1.5),
    (785, 129, 180.0),
    (785, 274, 40.0),
    (785, 732, 40.0),
    (785, 309, 20.0),
    (785, 734, 20.0),
    (785, 325, 835.0),
    (786, 31, 150.0),
    (786, 59, 1.5),
    (786, 274, 40.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (786, 732, 40.0),
    (786, 309, 20.0),
    (786, 734, 20.0),
    (786, 325, 835.0),
    (786, 566, 183.75),
    (787, 31, 150.0),
    (787, 59, 1.5),
    (787, 125, 176.25),
    (787, 274, 40.0),
    (787, 732, 40.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (787, 309, 20.0),
    (787, 734, 20.0),
    (787, 325, 835.0),
    (788, 31, 150.0),
    (788, 59, 1.5),
    (788, 122, 180.0),
    (788, 274, 40.0),
    (788, 732, 40.0),
    (788, 309, 20.0),
    (788, 734, 20.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (788, 325, 835.0),
    (789, 31, 150.0),
    (789, 58, 15.625),
    (789, 59, 1.5),
    (789, 62, 30.0),
    (789, 274, 40.0),
    (789, 732, 40.0),
    (789, 309, 20.0),
    (789, 734, 20.0),
    (789, 325, 835.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (789, 377, 15.313),
    (789, 567, 192.0),
    (790, 51, 0.288),
    (790, 59, 3.0),
    (790, 60, 75.0),
    (790, 128, 25.8),
    (790, 237, 32.0),
    (790, 274, 30.0),
    (790, 732, 30.0),
    (790, 309, 80.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (790, 734, 80.0),
    (790, 366, 907.2),
    (790, 374, 35.75),
    (790, 506, 2.083),
    (791, 58, 15.625),
    (791, 59, 6.6),
    (791, 62, 30.0),
    (791, 123, 165.0),
    (791, 274, 4.0),
    (791, 732, 4.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (791, 309, 20.0),
    (791, 734, 20.0),
    (791, 324, 835.0),
    (791, 377, 15.313),
    (792, 58, 15.625),
    (792, 59, 1.5),
    (792, 62, 30.0),
    (792, 123, 165.0),
    (792, 274, 40.0),
    (792, 732, 40.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (792, 309, 20.0),
    (792, 734, 20.0),
    (792, 325, 835.0),
    (792, 377, 15.313),
    (793, 58, 15.625),
    (793, 59, 1.5),
    (793, 62, 30.0),
    (793, 130, 180.0),
    (793, 274, 40.0),
    (793, 732, 40.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (793, 309, 20.0),
    (793, 734, 20.0),
    (793, 325, 835.0),
    (793, 377, 15.313),
    (794, 58, 15.625),
    (794, 59, 1.5),
    (794, 62, 30.0),
    (794, 121, 176.25),
    (794, 274, 40.0),
    (794, 732, 40.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (794, 309, 20.0),
    (794, 734, 20.0),
    (794, 325, 835.0),
    (794, 377, 15.313),
    (795, 58, 15.625),
    (795, 59, 1.5),
    (795, 62, 30.0),
    (795, 130, 180.0),
    (795, 274, 40.0),
    (795, 732, 40.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (795, 309, 20.0),
    (795, 734, 20.0),
    (795, 325, 835.0),
    (795, 377, 15.313),
    (796, 59, 1.5),
    (796, 129, 180.0),
    (796, 274, 40.0),
    (796, 732, 40.0),
    (796, 309, 20.0),
    (796, 734, 20.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (796, 325, 835.0),
    (797, 59, 1.5),
    (797, 274, 40.0),
    (797, 732, 40.0),
    (797, 309, 20.0),
    (797, 734, 20.0),
    (797, 325, 835.0),
    (797, 566, 183.75),
    (798, 59, 1.5),
    (798, 125, 176.25);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (798, 274, 40.0),
    (798, 732, 40.0),
    (798, 309, 20.0),
    (798, 734, 20.0),
    (798, 325, 835.0),
    (799, 59, 1.5),
    (799, 122, 180.0),
    (799, 274, 40.0),
    (799, 732, 40.0),
    (799, 309, 20.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (799, 734, 20.0),
    (799, 325, 835.0),
    (800, 58, 15.625),
    (800, 59, 1.5),
    (800, 62, 30.0),
    (800, 274, 40.0),
    (800, 732, 40.0),
    (800, 309, 20.0),
    (800, 734, 20.0),
    (800, 325, 835.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (800, 377, 15.313),
    (800, 567, 192.0),
    (801, 28, 50.0),
    (801, 59, 3.0),
    (801, 309, 20.0),
    (801, 734, 20.0),
    (801, 323, 300.0),
    (801, 526, 11.719),
    (801, 799, 28.0),
    (802, 12, 120.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (802, 59, 6.0),
    (802, 325, 1248.0),
    (802, 506, 25.0),
    (802, 526, 500.0),
    (802, 792, 112.0),
    (803, 59, 1.2),
    (803, 799, 10.0),
    (803, 818, 285.0),
    (803, 824, 25.0),
    (804, 59, 1.7);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (804, 799, 14.0),
    (804, 818, 285.0),
    (804, 823, 125.0),
    (804, 824, 37.0),
    (805, 13, 12.0),
    (805, 59, 0.6),
    (805, 412, 35.0),
    (805, 526, 3.0),
    (805, 799, 0.3),
    (805, 818, 40.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (805, 835, 10.0),
    (806, 13, 12.0),
    (806, 59, 0.6),
    (806, 235, 10.0),
    (806, 412, 35.0),
    (806, 526, 3.0),
    (806, 799, 0.3),
    (806, 818, 30.0),
    (806, 835, 10.0),
    (807, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (807, 204, 100.0),
    (808, 59, 0.3),
    (808, 204, 100.0),
    (808, 799, 3.0),
    (809, 204, 100.0),
    (810, 59, 0.3),
    (810, 204, 100.0),
    (810, 795, 3.0),
    (811, 59, 0.3),
    (811, 204, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (811, 792, 3.0),
    (812, 59, 0.3),
    (812, 271, 100.0),
    (812, 795, 3.0),
    (813, 59, 0.4),
    (813, 271, 100.0),
    (813, 799, 15.0),
    (814, 59, 0.3),
    (814, 348, 100.0),
    (814, 795, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (815, 59, 0.3),
    (815, 271, 50.0),
    (815, 348, 50.0),
    (815, 795, 3.0),
    (816, 256, 100.0),
    (817, 59, 0.3),
    (817, 256, 100.0),
    (817, 795, 3.0),
    (818, 259, 100.0),
    (819, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (819, 259, 100.0),
    (819, 795, 3.0),
    (820, 275, 100.0),
    (821, 59, 0.3),
    (821, 275, 100.0),
    (821, 795, 3.0),
    (822, 278, 100.0),
    (823, 59, 0.3),
    (823, 278, 100.0),
    (824, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (824, 279, 100.0),
    (825, 704, 100.0),
    (826, 59, 0.3),
    (826, 278, 100.0),
    (826, 795, 3.0),
    (827, 59, 0.3),
    (827, 279, 100.0),
    (827, 795, 3.0),
    (828, 59, 0.3),
    (828, 278, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (828, 799, 3.0),
    (829, 59, 0.3),
    (829, 278, 100.0),
    (829, 792, 3.0),
    (830, 59, 0.3),
    (830, 279, 100.0),
    (830, 799, 3.0),
    (831, 59, 0.3),
    (831, 279, 100.0),
    (831, 792, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (832, 285, 100.0),
    (833, 59, 0.3),
    (833, 285, 100.0),
    (833, 795, 3.0),
    (834, 287, 100.0),
    (835, 59, 0.3),
    (835, 287, 100.0),
    (835, 795, 3.0),
    (836, 59, 0.3),
    (836, 290, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (836, 795, 3.0),
    (837, 703, 40.0),
    (837, 707, 40.0),
    (837, 709, 10.0),
    (837, 712, 10.0),
    (838, 59, 0.3),
    (838, 279, 40.0),
    (838, 294, 40.0),
    (838, 306, 10.0),
    (838, 357, 10.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (839, 706, 100.0),
    (840, 704, 40.0),
    (840, 708, 40.0),
    (840, 710, 10.0),
    (840, 712, 10.0),
    (841, 59, 0.3),
    (841, 279, 40.0),
    (841, 294, 40.0),
    (841, 306, 10.0),
    (841, 357, 10.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (841, 795, 3.0),
    (842, 59, 0.8),
    (842, 574, 100.0),
    (842, 795, 3.0),
    (843, 293, 100.0),
    (844, 59, 0.3),
    (844, 293, 100.0),
    (845, 59, 0.3),
    (845, 294, 100.0),
    (846, 708, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (847, 59, 0.3),
    (847, 293, 100.0),
    (847, 795, 3.0),
    (848, 59, 0.3),
    (848, 294, 100.0),
    (848, 795, 3.0),
    (849, 59, 0.3),
    (849, 298, 100.0),
    (849, 795, 3.0),
    (850, 305, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (851, 59, 0.3),
    (851, 305, 100.0),
    (852, 59, 0.3),
    (852, 306, 100.0),
    (853, 710, 100.0),
    (854, 59, 0.3),
    (854, 305, 100.0),
    (854, 795, 3.0),
    (855, 59, 0.3),
    (855, 306, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (855, 795, 3.0),
    (856, 59, 0.3),
    (856, 322, 100.0),
    (856, 795, 3.0),
    (857, 586, 100.0),
    (858, 59, 0.3),
    (858, 336, 100.0),
    (859, 59, 0.3),
    (859, 338, 100.0),
    (860, 337, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (861, 59, 0.3),
    (861, 336, 100.0),
    (861, 799, 3.0),
    (862, 59, 0.3),
    (862, 336, 100.0),
    (862, 792, 3.0),
    (863, 711, 100.0),
    (864, 59, 0.3),
    (864, 336, 100.0),
    (864, 795, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (865, 59, 0.3),
    (865, 338, 100.0),
    (865, 795, 3.0),
    (866, 337, 100.0),
    (866, 795, 3.0),
    (867, 59, 0.3),
    (867, 338, 100.0),
    (867, 799, 3.0),
    (868, 59, 0.3),
    (868, 338, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (868, 792, 3.0),
    (869, 337, 100.0),
    (869, 799, 3.0),
    (870, 337, 100.0),
    (870, 792, 3.0),
    (871, 803, 40.0),
    (871, 819, 60.0),
    (872, 1, 56.0),
    (872, 31, 200.0),
    (872, 59, 1.4);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (872, 310, 13.125),
    (872, 338, 220.0),
    (872, 526, 41.625),
    (872, 592, 366.0),
    (873, 1, 14.0),
    (873, 38, 121.5),
    (873, 59, 0.4),
    (873, 338, 468.0),
    (873, 462, 54.0),
    (873, 623, 56.5);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (874, 2, 4.667),
    (874, 4, 500.0),
    (874, 47, 1.2),
    (874, 48, 2.0),
    (874, 59, 3.0),
    (874, 291, 5.625),
    (874, 292, 2.0),
    (874, 309, 150.0),
    (874, 734, 150.0),
    (874, 336, 500.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (874, 351, 182.0),
    (874, 799, 70.0),
    (875, 45, 2.5),
    (875, 48, 2.0),
    (875, 59, 3.0),
    (875, 291, 3.0),
    (875, 292, 2.0),
    (875, 309, 110.0),
    (875, 734, 110.0),
    (875, 654, 164.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (875, 799, 28.0),
    (875, 819, 540.0),
    (876, 59, 0.3),
    (876, 349, 100.0),
    (876, 795, 3.0),
    (877, 59, 0.3),
    (877, 356, 100.0),
    (878, 59, 0.3),
    (878, 357, 100.0),
    (879, 713, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (880, 59, 0.3),
    (880, 356, 100.0),
    (880, 795, 3.0),
    (881, 59, 0.3),
    (881, 357, 100.0),
    (881, 795, 3.0),
    (882, 360, 100.0),
    (883, 59, 0.3),
    (883, 360, 100.0),
    (883, 795, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (884, 59, 0.3),
    (884, 245, 100.0),
    (884, 795, 3.0),
    (885, 59, 0.3),
    (885, 345, 100.0),
    (885, 795, 3.0),
    (886, 257, 100.0),
    (886, 714, 100.0),
    (887, 59, 0.5),
    (887, 257, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (887, 714, 100.0),
    (887, 795, 5.0),
    (888, 59, 0.3),
    (888, 257, 100.0),
    (888, 714, 100.0),
    (889, 59, 0.3),
    (889, 258, 100.0),
    (890, 715, 100.0),
    (891, 59, 0.3),
    (891, 257, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (891, 714, 100.0),
    (891, 795, 3.0),
    (892, 59, 0.3),
    (892, 258, 100.0),
    (892, 795, 3.0),
    (893, 59, 0.3),
    (893, 257, 100.0),
    (893, 714, 100.0),
    (893, 799, 3.0),
    (894, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (894, 257, 100.0),
    (894, 714, 100.0),
    (894, 792, 3.0),
    (895, 59, 0.3),
    (895, 258, 100.0),
    (895, 799, 3.0),
    (896, 59, 0.3),
    (896, 258, 100.0),
    (896, 792, 3.0),
    (897, 1, 14.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (897, 59, 0.4),
    (897, 462, 54.0),
    (897, 531, 320.0),
    (897, 803, 120.0),
    (897, 820, 552.0),
    (898, 1, 14.0),
    (898, 59, 0.4),
    (898, 134, 125.5),
    (898, 258, 552.0),
    (898, 462, 54.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (898, 520, 316.0),
    (898, 623, 56.5),
    (899, 59, 0.5),
    (899, 799, 12.0),
    (899, 814, 50.0),
    (899, 820, 38.0),
    (900, 384, 100.0),
    (901, 59, 0.3),
    (901, 384, 100.0),
    (901, 795, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (902, 3, 12.0),
    (902, 59, 0.6),
    (902, 412, 35.0),
    (902, 526, 3.0),
    (902, 799, 0.3),
    (902, 820, 40.0),
    (902, 835, 10.0),
    (903, 267, 50.0),
    (903, 379, 50.0),
    (904, 59, 0.5);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (904, 267, 100.0),
    (904, 795, 5.0),
    (905, 59, 0.3),
    (905, 267, 100.0),
    (906, 59, 0.3),
    (906, 269, 100.0),
    (907, 268, 100.0),
    (908, 59, 0.3),
    (908, 267, 100.0),
    (908, 799, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (909, 59, 0.3),
    (909, 267, 100.0),
    (909, 792, 3.0),
    (910, 719, 100.0),
    (911, 59, 0.3),
    (911, 267, 100.0),
    (911, 795, 3.0),
    (912, 59, 0.3),
    (912, 269, 100.0),
    (912, 795, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (913, 268, 100.0),
    (913, 795, 3.0),
    (914, 59, 0.3),
    (914, 269, 100.0),
    (914, 799, 3.0),
    (915, 59, 0.3),
    (915, 269, 100.0),
    (915, 792, 3.0),
    (916, 268, 100.0),
    (916, 799, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (917, 268, 100.0),
    (917, 792, 3.0),
    (918, 1, 3.0),
    (918, 59, 0.3),
    (918, 505, 8.0),
    (918, 821, 89.0),
    (919, 370, 100.0),
    (920, 370, 100.0),
    (920, 795, 3.0),
    (921, 370, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (921, 799, 3.0),
    (922, 370, 100.0),
    (922, 792, 3.0),
    (923, 59, 0.3),
    (923, 267, 50.0),
    (923, 317, 50.0),
    (924, 59, 0.3),
    (924, 269, 50.0),
    (924, 319, 50.0),
    (925, 268, 50.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (925, 318, 50.0),
    (926, 727, 100.0),
    (927, 59, 0.3),
    (927, 267, 50.0),
    (927, 317, 50.0),
    (927, 795, 3.0),
    (928, 59, 0.3),
    (928, 269, 50.0),
    (928, 319, 50.0),
    (928, 795, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (929, 268, 50.0),
    (929, 318, 50.0),
    (929, 795, 3.0),
    (930, 329, 100.0),
    (930, 795, 3.0),
    (931, 59, 0.3),
    (931, 328, 100.0),
    (931, 795, 3.0),
    (932, 328, 100.0),
    (933, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (933, 364, 100.0),
    (934, 59, 0.3),
    (934, 364, 100.0),
    (934, 795, 3.0),
    (935, 28, 150.0),
    (935, 50, 1.1),
    (935, 59, 3.0),
    (935, 364, 615.0),
    (935, 502, 20.0),
    (935, 505, 9.063);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (935, 526, 23.438),
    (935, 592, 61.0),
    (936, 728, 100.0),
    (937, 59, 0.4),
    (937, 795, 5.0),
    (937, 822, 100.0),
    (938, 59, 0.4),
    (938, 822, 100.0),
    (939, 59, 0.4),
    (939, 795, 5.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (939, 822, 100.0),
    (940, 59, 0.4),
    (940, 795, 5.0),
    (940, 822, 100.0),
    (941, 59, 0.4),
    (941, 822, 100.0),
    (942, 59, 0.4),
    (942, 795, 5.0),
    (942, 822, 100.0),
    (943, 59, 0.4);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (943, 506, 35.0),
    (943, 795, 5.0),
    (943, 822, 100.0),
    (944, 59, 0.4),
    (944, 347, 100.0),
    (944, 795, 5.0),
    (945, 59, 0.4),
    (945, 347, 100.0),
    (946, 59, 0.4),
    (946, 347, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (946, 795, 5.0),
    (947, 11, 25.0),
    (947, 59, 0.4),
    (947, 506, 3.0),
    (947, 822, 100.0),
    (948, 729, 100.0),
    (949, 553, 100.0),
    (950, 59, 0.4),
    (950, 799, 10.0),
    (950, 822, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (951, 59, 0.4),
    (951, 553, 100.0),
    (951, 839, 18.0),
    (952, 553, 100.0),
    (953, 59, 0.4),
    (953, 553, 100.0),
    (954, 59, 0.4),
    (954, 553, 100.0),
    (954, 839, 7.0),
    (955, 553, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (956, 13, 12.0),
    (956, 59, 0.6),
    (956, 329, 40.0),
    (956, 412, 35.0),
    (956, 526, 3.0),
    (956, 799, 0.3),
    (956, 835, 10.0),
    (957, 36, 5.0),
    (957, 59, 0.3),
    (957, 462, 13.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (957, 823, 69.0),
    (957, 824, 13.0),
    (958, 59, 0.5),
    (958, 799, 12.0),
    (958, 814, 50.0),
    (958, 823, 38.0),
    (959, 59, 2.5),
    (959, 62, 5.0),
    (959, 350, 85.0),
    (959, 413, 5.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (959, 506, 5.0),
    (960, 59, 0.6),
    (960, 353, 20.0),
    (960, 412, 50.0),
    (960, 799, 0.3),
    (960, 823, 20.0),
    (960, 835, 10.0),
    (961, 13, 12.0),
    (961, 59, 0.6),
    (961, 353, 20.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (961, 412, 35.0),
    (961, 526, 3.0),
    (961, 799, 0.3),
    (961, 823, 20.0),
    (961, 835, 10.0),
    (962, 59, 1.4),
    (962, 353, 50.0),
    (962, 412, 140.0),
    (962, 506, 6.0),
    (962, 585, 6.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (962, 799, 0.5),
    (962, 824, 10.0),
    (963, 59, 1.0),
    (963, 353, 50.0),
    (963, 412, 140.0),
    (963, 506, 6.0),
    (963, 585, 6.0),
    (963, 799, 0.5),
    (963, 824, 10.0),
    (964, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (964, 461, 60.0),
    (964, 808, 40.0),
    (964, 809, 21.0),
    (965, 59, 0.3),
    (965, 808, 40.0),
    (965, 809, 21.0),
    (965, 815, 60.0),
    (966, 257, 25.0),
    (966, 714, 25.0),
    (966, 716, 25.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (966, 730, 25.0),
    (966, 274, 25.0),
    (966, 732, 25.0),
    (967, 249, 100.0),
    (968, 240, 100.0),
    (969, 241, 100.0),
    (970, 242, 100.0),
    (971, 249, 100.0),
    (972, 251, 100.0),
    (973, 254, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (974, 381, 100.0),
    (975, 260, 100.0),
    (976, 380, 100.0),
    (977, 272, 100.0),
    (978, 274, 100.0),
    (978, 732, 100.0),
    (979, 378, 100.0),
    (980, 280, 100.0),
    (981, 286, 100.0),
    (982, 288, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (983, 362, 100.0),
    (984, 296, 100.0),
    (985, 297, 10.0),
    (985, 302, 80.0),
    (985, 304, 10.0),
    (986, 317, 100.0),
    (987, 320, 50.0),
    (987, 373, 50.0),
    (988, 320, 100.0),
    (989, 373, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (990, 382, 100.0),
    (991, 330, 100.0),
    (992, 331, 100.0),
    (993, 334, 33.0),
    (993, 335, 33.0),
    (993, 365, 33.0),
    (994, 315, 100.0),
    (995, 339, 100.0),
    (996, 342, 100.0),
    (997, 355, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (998, 60, 60.0),
    (998, 120, 24.0),
    (998, 237, 32.0),
    (998, 300, 454.0),
    (999, 3, 113.0),
    (999, 31, 150.0),
    (999, 123, 440.0),
    (999, 237, 64.0),
    (999, 274, 120.0),
    (999, 732, 120.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (999, 299, 539.0),
    (999, 309, 160.0),
    (999, 734, 160.0),
    (999, 319, 284.0),
    (999, 320, 74.4),
    (999, 506, 25.0),
    (1000, 5, 75.0),
    (1000, 184, 121.6),
    (1000, 274, 90.0),
    (1000, 732, 90.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1000, 286, 100.5),
    (1000, 309, 54.0),
    (1000, 734, 54.0),
    (1000, 311, 60.0),
    (1000, 330, 36.0),
    (1000, 351, 136.0),
    (1000, 424, 45.0),
    (1000, 588, 752.0),
    (1001, 31, 100.0),
    (1001, 237, 32.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1001, 586, 340.0),
    (1002, 31, 150.0),
    (1002, 152, 168.0),
    (1002, 237, 40.0),
    (1002, 351, 540.0),
    (1002, 360, 136.0),
    (1002, 588, 163.0),
    (1002, 629, 540.0),
    (1003, 405, 100.0),
    (1004, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1004, 242, 100.0),
    (1005, 59, 0.3),
    (1005, 244, 100.0),
    (1006, 243, 100.0),
    (1007, 737, 100.0),
    (1008, 59, 0.3),
    (1008, 242, 100.0),
    (1008, 795, 3.0),
    (1009, 59, 0.3),
    (1009, 244, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1009, 795, 3.0),
    (1010, 243, 100.0),
    (1010, 795, 3.0),
    (1011, 59, 0.3),
    (1011, 242, 100.0),
    (1011, 799, 3.0),
    (1012, 59, 0.3),
    (1012, 242, 100.0),
    (1012, 792, 3.0),
    (1013, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1013, 244, 100.0),
    (1013, 799, 3.0),
    (1014, 59, 0.3),
    (1014, 244, 100.0),
    (1014, 792, 3.0),
    (1015, 243, 100.0),
    (1015, 799, 3.0),
    (1016, 243, 100.0),
    (1016, 792, 3.0),
    (1017, 247, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1017, 795, 3.0),
    (1018, 59, 0.3),
    (1018, 248, 100.0),
    (1019, 59, 0.3),
    (1019, 248, 100.0),
    (1019, 795, 3.0),
    (1020, 59, 0.8),
    (1020, 248, 100.0),
    (1020, 795, 3.0),
    (1021, 59, 0.5);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1021, 251, 100.0),
    (1021, 795, 5.0),
    (1022, 59, 0.3),
    (1022, 251, 100.0),
    (1023, 59, 0.3),
    (1023, 253, 100.0),
    (1024, 252, 100.0),
    (1025, 740, 50.0),
    (1025, 741, 50.0),
    (1026, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1026, 251, 100.0),
    (1026, 795, 3.0),
    (1027, 59, 0.3),
    (1027, 253, 100.0),
    (1027, 795, 3.0),
    (1028, 252, 100.0),
    (1028, 795, 3.0),
    (1029, 59, 0.3),
    (1029, 251, 100.0),
    (1029, 799, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1030, 59, 0.3),
    (1030, 251, 100.0),
    (1030, 792, 3.0),
    (1031, 59, 0.3),
    (1031, 253, 100.0),
    (1031, 799, 3.0),
    (1032, 59, 0.3),
    (1032, 253, 100.0),
    (1032, 792, 3.0),
    (1033, 252, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1033, 799, 3.0),
    (1034, 252, 100.0),
    (1034, 792, 3.0),
    (1035, 367, 100.0),
    (1036, 367, 100.0),
    (1036, 795, 3.0),
    (1037, 367, 100.0),
    (1037, 799, 3.0),
    (1038, 367, 100.0),
    (1038, 792, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1039, 59, 0.5),
    (1039, 799, 12.0),
    (1039, 814, 50.0),
    (1039, 830, 38.0),
    (1040, 59, 0.3),
    (1040, 368, 100.0),
    (1040, 795, 3.0),
    (1041, 59, 0.3),
    (1041, 250, 50.0),
    (1041, 447, 50.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1041, 795, 3.0),
    (1042, 59, 0.3),
    (1042, 254, 100.0),
    (1043, 255, 100.0),
    (1044, 748, 100.0),
    (1045, 59, 0.3),
    (1045, 254, 100.0),
    (1045, 795, 3.0),
    (1046, 255, 100.0),
    (1046, 795, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1047, 369, 100.0),
    (1047, 795, 3.0),
    (1048, 59, 0.3),
    (1048, 246, 100.0),
    (1048, 795, 3.0),
    (1049, 59, 0.3),
    (1049, 160, 100.0),
    (1049, 795, 3.0),
    (1050, 59, 0.3),
    (1050, 381, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1050, 795, 3.0),
    (1051, 59, 0.3),
    (1051, 260, 100.0),
    (1052, 59, 0.3),
    (1052, 261, 100.0),
    (1053, 749, 100.0),
    (1054, 59, 0.3),
    (1054, 260, 100.0),
    (1054, 795, 3.0),
    (1055, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1055, 261, 100.0),
    (1055, 795, 3.0),
    (1056, 59, 0.3),
    (1056, 262, 100.0),
    (1056, 795, 3.0),
    (1057, 59, 0.3),
    (1057, 380, 100.0),
    (1058, 59, 0.3),
    (1058, 380, 100.0),
    (1058, 795, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1059, 59, 0.3),
    (1059, 272, 100.0),
    (1060, 59, 0.3),
    (1060, 273, 100.0),
    (1061, 750, 100.0),
    (1062, 59, 0.3),
    (1062, 272, 100.0),
    (1062, 795, 3.0),
    (1063, 59, 0.3),
    (1063, 273, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1063, 795, 3.0),
    (1064, 59, 0.3),
    (1064, 272, 100.0),
    (1064, 799, 3.0),
    (1065, 59, 0.3),
    (1065, 272, 100.0),
    (1065, 792, 3.0),
    (1066, 59, 0.3),
    (1066, 273, 100.0),
    (1066, 799, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1067, 59, 0.3),
    (1067, 273, 100.0),
    (1067, 792, 3.0),
    (1068, 59, 0.3),
    (1068, 274, 100.0),
    (1068, 732, 100.0),
    (1068, 795, 3.0),
    (1069, 59, 0.3),
    (1069, 378, 100.0),
    (1069, 795, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1070, 59, 0.3),
    (1070, 276, 100.0),
    (1070, 795, 3.0),
    (1071, 59, 0.5),
    (1071, 280, 100.0),
    (1071, 795, 5.0),
    (1072, 59, 0.3),
    (1072, 280, 100.0),
    (1073, 59, 0.3),
    (1073, 283, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1074, 281, 100.0),
    (1075, 754, 100.0),
    (1076, 59, 0.3),
    (1076, 280, 100.0),
    (1076, 795, 3.0),
    (1077, 59, 0.3),
    (1077, 283, 100.0),
    (1077, 795, 3.0),
    (1078, 281, 100.0),
    (1078, 795, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1079, 59, 0.3),
    (1079, 280, 100.0),
    (1079, 799, 3.0),
    (1080, 59, 0.3),
    (1080, 280, 100.0),
    (1080, 792, 3.0),
    (1081, 59, 0.3),
    (1081, 283, 100.0),
    (1081, 799, 3.0),
    (1082, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1082, 283, 100.0),
    (1082, 792, 3.0),
    (1083, 281, 100.0),
    (1083, 799, 3.0),
    (1084, 281, 100.0),
    (1084, 792, 3.0),
    (1085, 282, 100.0),
    (1086, 371, 100.0),
    (1087, 371, 100.0),
    (1087, 795, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1088, 371, 100.0),
    (1088, 799, 3.0),
    (1089, 371, 100.0),
    (1089, 792, 3.0),
    (1090, 59, 0.3),
    (1090, 286, 100.0),
    (1090, 795, 3.0),
    (1091, 59, 0.3),
    (1091, 288, 100.0),
    (1092, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1092, 288, 100.0),
    (1092, 795, 3.0),
    (1093, 59, 0.3),
    (1093, 327, 100.0),
    (1093, 795, 3.0),
    (1094, 59, 0.3),
    (1094, 296, 100.0),
    (1094, 795, 3.0),
    (1095, 59, 0.3),
    (1095, 301, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1095, 795, 3.0),
    (1096, 59, 0.3),
    (1096, 733, 100.0),
    (1097, 761, 100.0),
    (1098, 59, 0.3),
    (1098, 733, 100.0),
    (1098, 795, 3.0),
    (1099, 303, 100.0),
    (1099, 795, 3.0),
    (1100, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1100, 733, 100.0),
    (1100, 799, 3.0),
    (1101, 59, 0.3),
    (1101, 733, 100.0),
    (1101, 792, 3.0),
    (1102, 59, 0.3),
    (1102, 295, 100.0),
    (1103, 59, 0.3),
    (1103, 307, 100.0),
    (1104, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1104, 308, 100.0),
    (1105, 763, 100.0),
    (1106, 59, 0.3),
    (1106, 307, 100.0),
    (1106, 795, 3.0),
    (1107, 59, 0.3),
    (1107, 308, 100.0),
    (1107, 795, 3.0),
    (1108, 59, 0.3),
    (1108, 575, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1108, 795, 3.0),
    (1109, 59, 0.3),
    (1109, 314, 100.0),
    (1109, 795, 3.0),
    (1110, 59, 0.3),
    (1110, 284, 100.0),
    (1110, 795, 3.0),
    (1111, 59, 0.8),
    (1111, 284, 100.0),
    (1111, 795, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1112, 59, 0.5),
    (1112, 317, 100.0),
    (1112, 795, 5.0),
    (1113, 59, 0.3),
    (1113, 317, 100.0),
    (1114, 59, 0.3),
    (1114, 319, 100.0),
    (1115, 318, 100.0),
    (1116, 768, 100.0),
    (1117, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1117, 317, 100.0),
    (1117, 795, 3.0),
    (1118, 59, 0.3),
    (1118, 319, 100.0),
    (1118, 795, 3.0),
    (1119, 318, 100.0),
    (1119, 795, 3.0),
    (1120, 59, 0.3),
    (1120, 317, 100.0),
    (1120, 799, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1121, 59, 0.3),
    (1121, 317, 100.0),
    (1121, 792, 3.0),
    (1122, 59, 0.3),
    (1122, 319, 100.0),
    (1122, 799, 3.0),
    (1123, 59, 0.3),
    (1123, 319, 100.0),
    (1123, 792, 3.0),
    (1124, 318, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1124, 799, 3.0),
    (1125, 318, 100.0),
    (1125, 792, 3.0),
    (1126, 372, 100.0),
    (1127, 372, 100.0),
    (1127, 795, 3.0),
    (1128, 372, 100.0),
    (1128, 799, 3.0),
    (1129, 372, 100.0),
    (1129, 792, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1130, 59, 0.3),
    (1130, 320, 100.0),
    (1130, 795, 3.0),
    (1131, 59, 0.3),
    (1131, 373, 100.0),
    (1131, 795, 3.0),
    (1132, 59, 0.3),
    (1132, 331, 100.0),
    (1132, 795, 3.0),
    (1133, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1133, 332, 100.0),
    (1133, 795, 3.0),
    (1134, 333, 142.0),
    (1134, 792, 4.667),
    (1135, 59, 0.3),
    (1135, 315, 100.0),
    (1136, 59, 0.3),
    (1136, 316, 100.0),
    (1137, 777, 100.0),
    (1138, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1138, 315, 100.0),
    (1138, 795, 3.0),
    (1139, 59, 0.3),
    (1139, 316, 100.0),
    (1139, 795, 3.0),
    (1140, 334, 33.0),
    (1140, 335, 33.0),
    (1140, 365, 33.0),
    (1141, 334, 33.0),
    (1141, 335, 33.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1141, 365, 33.0),
    (1141, 795, 3.0),
    (1142, 59, 0.3),
    (1142, 339, 50.0),
    (1142, 342, 50.0),
    (1143, 59, 0.3),
    (1143, 341, 50.0),
    (1143, 343, 50.0),
    (1144, 778, 100.0),
    (1145, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1145, 339, 50.0),
    (1145, 342, 50.0),
    (1145, 795, 3.0),
    (1146, 59, 0.3),
    (1146, 341, 50.0),
    (1146, 343, 50.0),
    (1146, 795, 3.0),
    (1147, 59, 0.8),
    (1147, 340, 100.0),
    (1147, 795, 3.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1148, 59, 0.3),
    (1148, 339, 50.0),
    (1148, 342, 50.0),
    (1148, 799, 3.0),
    (1149, 59, 0.3),
    (1149, 339, 50.0),
    (1149, 342, 50.0),
    (1149, 792, 3.0),
    (1150, 59, 0.3),
    (1150, 341, 50.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1150, 343, 50.0),
    (1150, 799, 3.0),
    (1151, 59, 0.3),
    (1151, 341, 50.0),
    (1151, 343, 50.0),
    (1151, 792, 3.0),
    (1152, 59, 0.3),
    (1152, 344, 100.0),
    (1152, 795, 3.0),
    (1153, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1153, 355, 100.0),
    (1153, 795, 3.0),
    (1154, 359, 100.0),
    (1155, 59, 0.3),
    (1155, 361, 100.0),
    (1155, 795, 3.0),
    (1156, 59, 0.3),
    (1156, 248, 50.0),
    (1156, 283, 50.0),
    (1157, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1157, 248, 50.0),
    (1157, 283, 50.0),
    (1157, 795, 3.0),
    (1158, 59, 0.3),
    (1158, 824, 50.0),
    (1158, 826, 33.0),
    (1158, 827, 17.0),
    (1159, 59, 0.3),
    (1159, 795, 3.0),
    (1159, 824, 50.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1159, 826, 33.0),
    (1159, 827, 17.0),
    (1160, 59, 0.2),
    (1160, 717, 25.0),
    (1160, 738, 25.0),
    (1160, 752, 25.0),
    (1160, 766, 25.0),
    (1160, 795, 5.0),
    (1161, 59, 0.3),
    (1161, 358, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1162, 718, 25.0),
    (1162, 739, 25.0),
    (1162, 753, 25.0),
    (1162, 767, 25.0),
    (1163, 780, 100.0),
    (1164, 59, 0.3),
    (1164, 358, 100.0),
    (1164, 795, 3.0),
    (1165, 720, 25.0),
    (1165, 741, 25.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1165, 754, 25.0),
    (1165, 769, 25.0),
    (1166, 59, 0.3),
    (1166, 358, 100.0),
    (1166, 799, 3.0),
    (1167, 59, 0.3),
    (1167, 358, 100.0),
    (1167, 792, 3.0),
    (1168, 721, 25.0),
    (1168, 742, 25.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1168, 755, 25.0),
    (1168, 770, 25.0),
    (1169, 722, 25.0),
    (1169, 743, 25.0),
    (1169, 756, 25.0),
    (1169, 771, 25.0),
    (1170, 723, 25.0),
    (1170, 744, 25.0),
    (1170, 757, 25.0),
    (1170, 772, 25.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1171, 724, 25.0),
    (1171, 745, 25.0),
    (1171, 758, 25.0),
    (1171, 773, 25.0),
    (1172, 725, 25.0),
    (1172, 746, 25.0),
    (1172, 759, 25.0),
    (1172, 774, 25.0),
    (1173, 726, 25.0),
    (1173, 747, 25.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1173, 760, 25.0),
    (1173, 775, 25.0),
    (1174, 59, 0.3),
    (1174, 283, 50.0),
    (1174, 319, 50.0),
    (1175, 59, 0.3),
    (1175, 283, 50.0),
    (1175, 319, 50.0),
    (1175, 795, 3.0),
    (1176, 53, 2.133);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1176, 55, 0.45),
    (1176, 57, 1.5),
    (1176, 59, 6.0),
    (1176, 291, 9.0),
    (1176, 310, 315.0),
    (1176, 352, 396.9),
    (1176, 800, 84.0),
    (1176, 827, 146.0),
    (1176, 829, 454.0),
    (1176, 831, 454.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1177, 698, 50.0),
    (1177, 719, 30.0),
    (1177, 751, 5.0),
    (1177, 765, 15.0),
    (1178, 697, 50.0),
    (1178, 717, 30.0),
    (1178, 274, 5.0),
    (1178, 732, 5.0),
    (1178, 764, 15.0),
    (1179, 59, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1179, 258, 50.0),
    (1179, 273, 50.0),
    (1180, 59, 0.3),
    (1180, 258, 50.0),
    (1180, 273, 50.0),
    (1180, 795, 3.0),
    (1181, 59, 0.3),
    (1181, 258, 33.0),
    (1181, 270, 33.0),
    (1181, 273, 33.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1182, 59, 0.3),
    (1182, 258, 33.0),
    (1182, 270, 33.0),
    (1182, 273, 33.0),
    (1182, 795, 3.0),
    (1183, 59, 0.2),
    (1183, 776, 25.0),
    (1183, 779, 15.0),
    (1183, 820, 25.0),
    (1183, 821, 25.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1183, 826, 10.0),
    (1184, 59, 0.2),
    (1184, 776, 25.0),
    (1184, 779, 15.0),
    (1184, 795, 3.0),
    (1184, 820, 25.0),
    (1184, 821, 25.0),
    (1184, 826, 10.0),
    (1185, 292, 24.0),
    (1185, 301, 44.5);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1185, 359, 35.0),
    (1185, 450, 120.0),
    (1185, 762, 30.0),
    (1186, 8, 25.0),
    (1186, 59, 3.0),
    (1186, 241, 360.0),
    (1186, 274, 60.0),
    (1186, 732, 60.0),
    (1186, 309, 40.0),
    (1186, 734, 40.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1186, 313, 7.6),
    (1186, 462, 162.0),
    (1186, 800, 28.0),
    (1187, 59, 0.2),
    (1187, 134, 34.0),
    (1187, 592, 12.0),
    (1187, 830, 54.0),
    (1188, 59, 0.5),
    (1188, 799, 12.0),
    (1188, 814, 50.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1188, 828, 38.0),
    (1189, 28, 150.0),
    (1189, 53, 0.263),
    (1189, 59, 6.0),
    (1189, 283, 574.0),
    (1189, 506, 12.5),
    (1189, 592, 244.0),
    (1189, 794, 28.2),
    (1190, 59, 0.5),
    (1190, 799, 12.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1190, 814, 50.0),
    (1190, 829, 38.0),
    (1191, 7, 15.0),
    (1191, 8, 5.0),
    (1191, 22, 0.3),
    (1191, 32, 0.5),
    (1191, 288, 41.4),
    (1191, 354, 25.0),
    (1191, 413, 8.3),
    (1191, 482, 0.1);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1191, 526, 4.0),
    (1191, 799, 4.4),
    (1191, 800, 0.5),
    (1192, 7, 15.0),
    (1192, 8, 5.0),
    (1192, 354, 25.0),
    (1192, 829, 55.0),
    (1193, 8, 50.0),
    (1193, 59, 1.5),
    (1193, 141, 35.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1193, 175, 31.0),
    (1193, 277, 4.5),
    (1193, 309, 20.0),
    (1193, 734, 20.0),
    (1193, 462, 162.0),
    (1193, 733, 453.6),
    (1193, 794, 56.4),
    (1194, 59, 0.5),
    (1194, 799, 12.0),
    (1194, 814, 50.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1194, 825, 38.0),
    (1195, 59, 0.5),
    (1195, 308, 38.0),
    (1195, 799, 12.0),
    (1195, 814, 50.0),
    (1196, 312, 50.0),
    (1196, 538, 50.0),
    (1197, 59, 0.5),
    (1197, 799, 12.0),
    (1197, 814, 50.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1197, 831, 38.0),
    (1198, 1, 14.0),
    (1198, 59, 0.4),
    (1198, 354, 128.5),
    (1198, 462, 54.0),
    (1198, 623, 56.5),
    (1198, 831, 540.0),
    (1199, 1, 14.0),
    (1199, 59, 0.4),
    (1199, 354, 128.5);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1199, 462, 54.0),
    (1199, 520, 316.0),
    (1199, 831, 540.0),
    (1200, 1, 14.0),
    (1200, 38, 121.5),
    (1200, 59, 0.4),
    (1200, 462, 54.0),
    (1200, 831, 540.0),
    (1201, 1, 56.0),
    (1201, 28, 150.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1201, 59, 3.0),
    (1201, 526, 31.25),
    (1201, 592, 244.0),
    (1201, 831, 360.0),
    (1202, 59, 0.7),
    (1202, 412, 20.0),
    (1202, 838, 80.0),
    (1203, 30, 51.0),
    (1203, 251, 99.338),
    (1203, 257, 99.338);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1203, 714, 99.338),
    (1203, 272, 99.338),
    (1203, 309, 99.338),
    (1203, 734, 99.338),
    (1203, 320, 99.338),
    (1203, 342, 99.338),
    (1203, 346, 99.338),
    (1203, 413, 474.0),
    (1203, 526, 312.5),
    (1203, 733, 99.338);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1203, 799, 212.2),
    (1204, 52, 0.433),
    (1204, 54, 0.45),
    (1204, 56, 0.55),
    (1204, 59, 6.0),
    (1204, 204, 5.0),
    (1204, 272, 20.0),
    (1204, 288, 15.0),
    (1204, 309, 30.0),
    (1204, 734, 30.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1204, 323, 30.0),
    (1204, 413, 355.5),
    (1204, 438, 141.75),
    (1204, 799, 21.0),
    (1205, 59, 0.6),
    (1205, 798, 40.0),
    (1205, 799, 2.0),
    (1205, 836, 60.0),
    (1206, 662, 40.0),
    (1206, 781, 60.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1207, 59, 2.5),
    (1207, 62, 5.0),
    (1207, 251, 85.0),
    (1207, 413, 5.0),
    (1207, 506, 5.0),
    (1208, 363, 100.0),
    (1209, 59, 2.5),
    (1209, 62, 5.0),
    (1209, 274, 85.0),
    (1209, 732, 85.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1209, 413, 5.0),
    (1209, 506, 5.0),
    (1210, 59, 0.5),
    (1210, 60, 5.0),
    (1210, 281, 70.0),
    (1210, 309, 5.0),
    (1210, 734, 5.0),
    (1210, 373, 5.0),
    (1210, 506, 15.0),
    (1211, 59, 2.5);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1211, 62, 5.0),
    (1211, 272, 85.0),
    (1211, 413, 5.0),
    (1211, 506, 5.0),
    (1212, 59, 2.5),
    (1212, 62, 5.0),
    (1212, 263, 85.0),
    (1212, 413, 5.0),
    (1212, 506, 5.0),
    (1213, 59, 2.5);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1213, 62, 5.0),
    (1213, 264, 85.0),
    (1213, 413, 5.0),
    (1213, 506, 5.0),
    (1214, 266, 100.0),
    (1215, 374, 100.0),
    (1216, 377, 100.0),
    (1217, 375, 100.0),
    (1218, 59, 2.5),
    (1218, 62, 5.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1218, 288, 85.0),
    (1218, 413, 5.0),
    (1218, 506, 5.0),
    (1219, 554, 100.0),
    (1220, 59, 2.5),
    (1220, 62, 5.0),
    (1220, 413, 5.0),
    (1220, 506, 5.0),
    (1220, 733, 85.0),
    (1221, 59, 2.5);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1221, 62, 5.0),
    (1221, 307, 85.0),
    (1221, 413, 5.0),
    (1221, 506, 5.0),
    (1222, 184, 100.0),
    (1223, 185, 100.0),
    (1224, 184, 100.0),
    (1225, 234, 100.0),
    (1226, 184, 50.0),
    (1226, 185, 30.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1226, 800, 20.0),
    (1227, 59, 2.5),
    (1227, 62, 5.0),
    (1227, 413, 5.0),
    (1227, 506, 5.0),
    (1227, 735, 85.0),
    (1228, 555, 100.0),
    (1229, 383, 50.0),
    (1229, 555, 50.0),
    (1230, 782, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1231, 59, 0.5),
    (1231, 124, 12.0),
    (1231, 374, 38.0),
    (1231, 814, 50.0),
    (1232, 59, 2.5),
    (1232, 62, 5.0),
    (1232, 330, 85.0),
    (1232, 413, 5.0),
    (1232, 506, 5.0),
    (1233, 59, 2.5);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1233, 62, 5.0),
    (1233, 413, 5.0),
    (1233, 506, 5.0),
    (1233, 736, 85.0),
    (1234, 59, 2.5),
    (1234, 62, 5.0),
    (1234, 267, 20.0),
    (1234, 272, 25.0),
    (1234, 274, 15.0),
    (1234, 732, 15.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1234, 373, 25.0),
    (1234, 413, 5.0),
    (1234, 506, 5.0),
    (1235, 59, 2.5),
    (1235, 62, 5.0),
    (1235, 355, 85.0),
    (1235, 413, 5.0),
    (1235, 506, 5.0),
    (1236, 59, 2.5),
    (1236, 62, 5.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1236, 342, 85.0),
    (1236, 413, 5.0),
    (1236, 506, 5.0),
    (1237, 59, 0.6),
    (1237, 369, 30.0),
    (1237, 412, 50.0),
    (1237, 799, 0.3),
    (1237, 835, 10.0),
    (1237, 837, 10.0),
    (1238, 59, 0.4);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1238, 286, 5.0),
    (1238, 590, 20.0),
    (1238, 730, 40.0),
    (1238, 309, 5.0),
    (1238, 734, 5.0),
    (1238, 735, 10.0),
    (1238, 799, 0.3),
    (1239, 13, 12.0),
    (1239, 59, 0.6),
    (1239, 412, 35.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1239, 526, 3.0),
    (1239, 799, 0.3),
    (1239, 825, 40.0),
    (1239, 835, 10.0),
    (1240, 6, 12.0),
    (1240, 59, 0.6),
    (1240, 412, 35.0),
    (1240, 459, 10.0),
    (1240, 526, 3.0),
    (1240, 799, 0.3);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1240, 824, 40.0),
    (1241, 13, 12.0),
    (1241, 59, 0.6),
    (1241, 412, 35.0),
    (1241, 526, 3.0),
    (1241, 799, 0.3),
    (1241, 835, 10.0),
    (1241, 837, 40.0),
    (1242, 632, 75.0),
    (1242, 736, 10.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1242, 810, 10.0),
    (1242, 824, 5.0),
    (1243, 59, 1.3),
    (1243, 283, 10.0),
    (1243, 319, 10.0),
    (1243, 412, 100.0),
    (1243, 799, 0.5),
    (1243, 818, 60.0),
    (1243, 823, 5.0),
    (1243, 835, 15.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1244, 59, 0.9),
    (1244, 283, 10.0),
    (1244, 319, 10.0),
    (1244, 412, 100.0),
    (1244, 799, 0.5),
    (1244, 818, 60.0),
    (1244, 823, 5.0),
    (1244, 835, 15.0),
    (1245, 59, 0.6),
    (1245, 412, 50.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1245, 799, 0.3),
    (1245, 835, 10.0),
    (1245, 837, 40.0),
    (1246, 59, 0.6),
    (1246, 412, 50.0),
    (1246, 431, 10.0),
    (1246, 533, 5.0),
    (1246, 799, 0.3),
    (1246, 835, 10.0),
    (1246, 837, 25.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1247, 59, 0.6),
    (1247, 412, 50.0),
    (1247, 799, 0.3),
    (1247, 810, 10.0),
    (1247, 835, 10.0),
    (1247, 837, 30.0),
    (1248, 633, 50.0),
    (1248, 786, 50.0),
    (1249, 71, 5.0),
    (1249, 73, 20.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1249, 75, 10.0),
    (1249, 77, 30.0),
    (1249, 79, 5.0),
    (1249, 82, 10.0),
    (1249, 83, 15.0),
    (1249, 84, 5.0),
    (1250, 73, 100.0),
    (1251, 74, 100.0),
    (1252, 75, 100.0),
    (1253, 76, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1254, 77, 100.0),
    (1255, 78, 100.0),
    (1256, 71, 100.0),
    (1257, 71, 100.0),
    (1258, 72, 100.0),
    (1259, 787, 100.0),
    (1260, 787, 100.0),
    (1261, 142, 3.0),
    (1261, 665, 1.0),
    (1261, 787, 96.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1262, 142, 3.0),
    (1262, 624, 10.0),
    (1262, 665, 1.0),
    (1262, 787, 86.0),
    (1263, 83, 100.0),
    (1264, 83, 100.0),
    (1265, 788, 25.0),
    (1265, 789, 25.0),
    (1265, 790, 25.0),
    (1265, 791, 25.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1266, 59, 0.3),
    (1266, 79, 30.0),
    (1266, 127, 2.0),
    (1266, 624, 20.0),
    (1266, 787, 48.0),
    (1267, 59, 0.4),
    (1267, 520, 30.0),
    (1267, 624, 20.0),
    (1267, 787, 50.0),
    (1268, 70, 75.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1268, 533, 25.0),
    (1269, 787, 40.0),
    (1269, 790, 60.0),
    (1270, 28, 45.0),
    (1270, 59, 1.0),
    (1270, 185, 6.0),
    (1270, 323, 680.4),
    (1270, 526, 15.625),
    (1270, 625, 95.3),
    (1270, 731, 60.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1270, 799, 60.0),
    (1271, 204, 716.0),
    (1271, 627, 226.8),
    (1271, 799, 96.0),
    (1272, 418, 100.0),
    (1273, 59, 1.5),
    (1273, 388, 720.0),
    (1273, 506, 100.0),
    (1273, 513, 64.0),
    (1274, 188, 37.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1274, 400, 26.0),
    (1274, 678, 37.0),
    (1275, 400, 40.0),
    (1275, 573, 20.0),
    (1275, 693, 40.0),
    (1276, 407, 100.0),
    (1277, 214, 340.2),
    (1277, 412, 948.0),
    (1277, 506, 200.0),
    (1278, 203, 50.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1278, 401, 50.0),
    (1279, 404, 100.0),
    (1280, 409, 17.0),
    (1280, 412, 237.0),
    (1281, 408, 100.0),
    (1282, 420, 100.0),
    (1283, 203, 140.0),
    (1283, 387, 30.0),
    (1283, 506, 13.0),
    (1284, 395, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1285, 412, 90.0),
    (1285, 509, 10.0),
    (1286, 421, 100.0),
    (1287, 406, 100.0),
    (1288, 423, 100.0),
    (1289, 399, 100.0),
    (1290, 422, 100.0),
    (1291, 409, 17.0),
    (1291, 412, 237.0),
    (1292, 411, 28.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1292, 412, 237.0),
    (1293, 576, 100.0),
    (1294, 419, 100.0),
    (1295, 413, 296.25),
    (1295, 565, 1.6),
    (1296, 576, 100.0),
    (1297, 412, 65.0),
    (1297, 693, 35.0),
    (1298, 397, 100.0),
    (1299, 402, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1300, 403, 100.0),
    (1301, 224, 50.0),
    (1301, 413, 50.0),
    (1302, 417, 100.0),
    (1303, 419, 100.0),
    (1304, 414, 100.0),
    (1305, 412, 74.0),
    (1305, 508, 26.0),
    (1306, 415, 100.0),
    (1307, 410, 100.0);

INSERT INTO
    public.food_ingredients (f_id, i_id, weight)
VALUES (1308, 216, 4.3),
    (1308, 401, 217.0),
    (1308, 564, 20.0),
    (1309, 69, 100.0),
    (1310, 396, 100.0);

-- Food Nutritions Data
INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1, 1, 125.0),
    (2, 1, 123.0),
    (3, 1, 126.0),
    (4, 1, 126.0),
    (5, 1, 132.0),
    (6, 1, 126.0),
    (7, 1, 132.0),
    (8, 1, 126.0),
    (9, 1, 123.0),
    (10, 1, 120.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (11, 1, 124.0),
    (12, 1, 134.0),
    (13, 1, 114.0),
    (14, 1, 142.0),
    (15, 1, 261.0),
    (16, 1, 261.0),
    (17, 1, 285.0),
    (18, 1, 290.0),
    (19, 1, 136.0),
    (20, 1, 100.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (21, 1, 160.0),
    (22, 1, 183.0),
    (23, 1, 127.0),
    (24, 1, 183.0),
    (25, 1, 167.0),
    (26, 1, 110.0),
    (27, 1, 111.0),
    (28, 1, 110.0),
    (29, 1, 111.0),
    (30, 1, 160.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (31, 1, 112.0),
    (32, 1, 160.0),
    (33, 1, 144.0),
    (34, 1, 100.0),
    (35, 1, 101.0),
    (36, 1, 100.0),
    (37, 1, 101.0),
    (38, 1, 158.0),
    (39, 1, 109.0),
    (40, 1, 158.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (41, 1, 144.0),
    (42, 1, 98.0),
    (43, 1, 99.0),
    (44, 1, 98.0),
    (45, 1, 99.0),
    (46, 1, 89.0),
    (47, 1, 129.0),
    (48, 1, 156.0),
    (49, 1, 86.0),
    (50, 1, 23.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (51, 1, 127.0),
    (52, 1, 116.0),
    (53, 1, 51.0),
    (54, 1, 52.0),
    (55, 1, 69.0),
    (56, 1, 69.0),
    (57, 1, 51.0),
    (58, 1, 54.0),
    (59, 1, 60.0),
    (60, 1, 51.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (61, 1, 55.0),
    (62, 1, 57.0),
    (63, 1, 63.0),
    (64, 1, 55.0),
    (65, 1, 54.0),
    (66, 1, 54.0),
    (67, 1, 112.0),
    (68, 1, 51.0),
    (69, 1, 50.0),
    (70, 1, 53.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (71, 1, 59.0),
    (72, 1, 50.0),
    (73, 1, 50.0),
    (74, 1, 50.0),
    (75, 1, 54.0),
    (76, 1, 57.0),
    (77, 1, 63.0),
    (78, 1, 54.0),
    (79, 1, 129.0),
    (80, 1, 93.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (81, 1, 121.0),
    (82, 1, 121.0),
    (83, 1, 93.0),
    (84, 1, 50.0),
    (85, 1, 44.0),
    (86, 1, 47.0),
    (87, 1, 53.0),
    (88, 1, 44.0),
    (89, 1, 44.0),
    (90, 1, 121.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (91, 1, 79.0),
    (92, 1, 79.0),
    (93, 1, 51.0),
    (94, 1, 51.0),
    (95, 1, 54.0),
    (96, 1, 60.0),
    (97, 1, 51.0),
    (98, 1, 55.0),
    (99, 1, 52.0),
    (100, 1, 69.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (101, 1, 71.0),
    (102, 1, 77.0),
    (103, 1, 69.0),
    (104, 1, 68.0),
    (105, 1, 70.0),
    (106, 1, 77.0),
    (107, 1, 68.0),
    (108, 1, 69.0),
    (109, 1, 67.0),
    (110, 1, 70.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (111, 1, 76.0),
    (112, 1, 67.0),
    (113, 1, 68.0),
    (114, 1, 61.0),
    (115, 1, 61.0),
    (116, 1, 61.0),
    (117, 1, 61.0),
    (118, 1, 61.0),
    (119, 1, 36.0),
    (120, 1, 51.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (121, 1, 134.0),
    (122, 1, 49.0),
    (123, 1, 117.0),
    (124, 1, 95.0),
    (125, 1, 115.0),
    (126, 1, 95.0),
    (127, 1, 100.0),
    (128, 1, 71.0),
    (129, 1, 107.0),
    (130, 1, 104.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (131, 1, 126.0),
    (132, 1, 125.0),
    (133, 1, 49.0),
    (134, 1, 126.0),
    (135, 1, 51.0),
    (136, 1, 125.0),
    (137, 1, 71.0),
    (138, 1, 41.0),
    (139, 1, 102.0),
    (140, 1, 251.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (141, 1, 148.0),
    (142, 1, 73.0),
    (143, 1, 189.0),
    (144, 1, 41.0),
    (145, 1, 5.0),
    (146, 1, 6.0),
    (147, 1, 83.0),
    (148, 1, 64.0),
    (149, 1, 41.0),
    (150, 1, 205.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (151, 1, 12.0),
    (152, 1, 9.0),
    (153, 1, 26.0),
    (154, 1, 22.0),
    (155, 1, 12.0),
    (156, 1, 14.0),
    (157, 1, 10.0),
    (158, 1, 22.0),
    (159, 1, 13.0),
    (160, 1, 5.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (161, 1, 11.0),
    (162, 1, 11.0),
    (163, 1, 12.0),
    (164, 1, 19.0),
    (165, 1, 18.0),
    (166, 1, 14.0),
    (167, 1, 19.0),
    (168, 1, 28.0),
    (169, 1, 12.0),
    (170, 1, 48.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (171, 1, 46.0),
    (172, 1, 48.0),
    (173, 1, 46.0),
    (174, 1, 48.0),
    (175, 1, 46.0),
    (176, 1, 45.0),
    (177, 1, 46.0),
    (178, 1, 45.0),
    (179, 1, 48.0),
    (180, 1, 46.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (181, 1, 45.0),
    (182, 1, 46.0),
    (183, 1, 48.0),
    (184, 1, 46.0),
    (185, 1, 50.0),
    (186, 1, 7.0),
    (187, 1, 7.0),
    (188, 1, 7.0),
    (189, 1, 7.0),
    (190, 1, 129.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (191, 1, 121.0),
    (192, 1, 129.0),
    (193, 1, 121.0),
    (194, 1, 60.0),
    (195, 1, 57.0),
    (196, 1, 64.0),
    (197, 1, 89.0),
    (198, 1, 58.0),
    (199, 1, 46.0),
    (200, 1, 42.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (201, 1, 41.0),
    (202, 1, 41.0),
    (203, 1, 41.0),
    (204, 1, 45.0),
    (205, 1, 41.0),
    (206, 1, 42.0),
    (207, 1, 43.0),
    (208, 1, 40.0),
    (209, 1, 44.0),
    (210, 1, 142.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (211, 1, 46.0),
    (212, 1, 46.0),
    (213, 1, 45.0),
    (214, 1, 46.0),
    (215, 1, 45.0),
    (216, 1, 48.0),
    (217, 1, 46.0),
    (218, 1, 48.0),
    (219, 1, 45.0),
    (220, 1, 151.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (221, 1, 150.0),
    (222, 1, 151.0),
    (223, 1, 150.0),
    (224, 1, 158.0),
    (225, 1, 159.0),
    (226, 1, 42.0),
    (227, 1, 42.0),
    (228, 1, 41.0),
    (229, 1, 42.0),
    (230, 1, 41.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (231, 1, 43.0),
    (232, 1, 42.0),
    (233, 1, 44.0),
    (234, 1, 140.0),
    (235, 1, 140.0),
    (236, 1, 140.0),
    (237, 1, 141.0),
    (238, 1, 140.0),
    (239, 1, 146.0),
    (240, 1, 140.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (241, 1, 147.0),
    (242, 1, 42.0),
    (243, 1, 44.0),
    (244, 1, 42.0),
    (245, 1, 48.0),
    (246, 1, 50.0),
    (247, 1, 48.0),
    (248, 1, 45.0),
    (249, 1, 47.0),
    (250, 1, 45.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (251, 1, 41.0),
    (252, 1, 43.0),
    (253, 1, 41.0),
    (254, 1, 135.0),
    (255, 1, 142.0),
    (256, 1, 135.0),
    (257, 1, 141.0),
    (258, 1, 148.0),
    (259, 1, 141.0),
    (260, 1, 138.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (261, 1, 144.0),
    (262, 1, 138.0),
    (263, 1, 135.0),
    (264, 1, 142.0),
    (265, 1, 135.0),
    (266, 1, 40.0),
    (267, 1, 41.0),
    (268, 1, 40.0),
    (269, 1, 45.0),
    (270, 1, 47.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (271, 1, 45.0),
    (272, 1, 42.0),
    (273, 1, 43.0),
    (274, 1, 42.0),
    (275, 1, 39.0),
    (276, 1, 41.0),
    (277, 1, 39.0),
    (278, 1, 133.0),
    (279, 1, 139.0),
    (280, 1, 133.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (281, 1, 136.0),
    (282, 1, 143.0),
    (283, 1, 136.0),
    (284, 1, 129.0),
    (285, 1, 135.0),
    (286, 1, 129.0),
    (287, 1, 133.0),
    (288, 1, 139.0),
    (289, 1, 133.0),
    (290, 1, 42.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (291, 1, 44.0),
    (292, 1, 42.0),
    (293, 1, 7.0),
    (294, 1, 7.0),
    (295, 1, 8.0),
    (296, 1, 7.0),
    (297, 1, 8.0),
    (298, 1, 7.0),
    (299, 1, 7.0),
    (300, 1, 7.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (301, 1, 117.0),
    (302, 1, 8.0),
    (303, 1, 14.0),
    (304, 1, 109.0),
    (305, 1, 111.0),
    (306, 1, 14.0),
    (307, 1, 107.0),
    (308, 1, 5.0),
    (309, 1, 69.0),
    (310, 1, 73.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (311, 1, 171.0),
    (312, 1, 62.0),
    (313, 1, 68.0),
    (314, 1, 159.0),
    (315, 1, 159.0),
    (316, 1, 64.0),
    (317, 1, 154.0),
    (318, 1, 39.0),
    (319, 1, 39.0),
    (320, 1, 41.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (321, 1, 69.0),
    (322, 1, 72.0),
    (323, 1, 82.0),
    (324, 1, 84.0),
    (325, 1, 84.0),
    (326, 1, 90.0),
    (327, 1, 75.0),
    (328, 1, 78.0),
    (329, 1, 75.0),
    (330, 1, 25.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (331, 1, 25.0),
    (332, 1, 27.0),
    (333, 1, 50.0),
    (334, 1, 51.0),
    (335, 1, 50.0),
    (336, 1, 25.0),
    (337, 1, 24.0),
    (338, 1, 34.0),
    (339, 1, 16.0),
    (340, 1, 16.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (341, 1, 49.0),
    (342, 1, 43.0),
    (343, 1, 43.0),
    (344, 1, 46.0),
    (345, 1, 75.0),
    (346, 1, 78.0),
    (347, 1, 75.0),
    (348, 1, 42.0),
    (349, 1, 39.0),
    (350, 1, 26.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (351, 1, 26.0),
    (352, 1, 28.0),
    (353, 1, 47.0),
    (354, 1, 48.0),
    (355, 1, 47.0),
    (356, 1, 26.0),
    (357, 1, 24.0),
    (358, 1, 58.0),
    (359, 1, 95.0),
    (360, 1, 25.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (361, 1, 39.0),
    (362, 1, 34.0),
    (363, 1, 38.0),
    (364, 1, 32.0),
    (365, 1, 31.0),
    (366, 1, 29.0),
    (367, 1, 55.0),
    (368, 1, 27.0),
    (369, 1, 29.0),
    (370, 1, 33.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (371, 1, 39.0),
    (372, 1, 35.0),
    (373, 1, 50.0),
    (374, 1, 23.0),
    (375, 1, 23.0),
    (376, 1, 46.0),
    (377, 1, 46.0),
    (378, 1, 49.0),
    (379, 1, 56.0),
    (380, 1, 58.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (381, 1, 56.0),
    (382, 1, 14.0),
    (383, 1, 13.0),
    (384, 1, 123.0),
    (385, 1, 18.0),
    (386, 1, 18.0),
    (387, 1, 19.0),
    (388, 1, 18.0),
    (389, 1, 19.0),
    (390, 1, 143.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (391, 1, 19.0),
    (392, 1, 138.0),
    (393, 1, 61.0),
    (394, 1, 20.0),
    (395, 1, 17.0),
    (396, 1, 25.0),
    (397, 1, 17.0),
    (398, 1, 19.0),
    (399, 1, 15.0),
    (400, 1, 15.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (401, 1, 15.0),
    (402, 1, 15.0),
    (403, 1, 17.0),
    (404, 1, 17.0),
    (405, 1, 14.0),
    (406, 1, 33.0),
    (407, 1, 140.0),
    (408, 1, 245.0),
    (409, 1, 67.0),
    (410, 1, 18.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (411, 1, 7.0),
    (412, 1, 7.0),
    (413, 1, 50.0),
    (414, 1, 22.0),
    (415, 1, 18.0),
    (416, 1, 96.0),
    (417, 1, 93.0),
    (418, 1, 20.0),
    (419, 1, 32.0),
    (420, 1, 238.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (421, 1, 518.0),
    (422, 1, 1053.0),
    (423, 1, 690.0),
    (424, 1, 320.0),
    (425, 1, 120.0),
    (426, 1, 92.0),
    (427, 1, 46.0),
    (428, 1, 50.0),
    (429, 1, 13.0),
    (430, 1, 50.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (431, 1, 50.0),
    (432, 1, 120.0),
    (433, 1, 120.0),
    (434, 1, 120.0),
    (435, 1, 80.0),
    (436, 1, 136.0),
    (437, 1, 136.0),
    (438, 1, 136.0),
    (439, 1, 67.0),
    (440, 1, 151.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (441, 1, 128.0),
    (442, 1, 31.0),
    (443, 1, 24.0),
    (444, 1, 13.0),
    (445, 1, 172.0),
    (446, 1, 11.0),
    (447, 1, 0.0),
    (448, 1, 21.0),
    (449, 1, 9.0),
    (450, 1, 7.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (451, 1, 14.0),
    (452, 1, 81.0),
    (453, 1, 81.0),
    (454, 1, 0.0),
    (455, 1, 0.0),
    (456, 1, 33.0),
    (457, 1, 257.0),
    (458, 1, 11.0),
    (459, 1, 0.0),
    (460, 1, 21.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (461, 1, 64.0),
    (462, 1, 64.0),
    (463, 1, 64.0),
    (464, 1, 39.0),
    (465, 1, 64.0),
    (466, 1, 64.0),
    (467, 1, 64.0),
    (468, 1, 80.0),
    (469, 1, 238.0),
    (470, 1, 238.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (471, 1, 0.0),
    (472, 1, 535.0),
    (473, 1, 535.0),
    (474, 1, 342.0),
    (475, 1, 57.0),
    (476, 1, 17.0),
    (477, 1, 24.0),
    (478, 1, 11.0),
    (479, 1, 12.0),
    (480, 1, 13.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (481, 1, 21.0),
    (482, 1, 7.0),
    (483, 1, 4.0),
    (484, 1, 7.0),
    (485, 1, 13.0),
    (486, 1, 2.0),
    (487, 1, 11.0),
    (488, 1, 8.0),
    (489, 1, 3.0),
    (490, 1, 25.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (491, 1, 31.0),
    (492, 1, 12.0),
    (493, 1, 12.0),
    (494, 1, 12.0),
    (495, 1, 135.0),
    (496, 1, 133.0),
    (497, 1, 163.0),
    (498, 1, 160.0),
    (499, 1, 69.0),
    (500, 1, 67.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (501, 1, 168.0),
    (502, 1, 163.0),
    (503, 1, 190.0),
    (504, 1, 185.0),
    (505, 1, 70.0),
    (506, 1, 69.0),
    (507, 1, 67.0),
    (508, 1, 66.0),
    (509, 1, 70.0),
    (510, 1, 9.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (511, 1, 17.0),
    (512, 1, 17.0),
    (513, 1, 17.0),
    (514, 1, 10.0),
    (515, 1, 10.0),
    (516, 1, 10.0),
    (517, 1, 11.0),
    (518, 1, 10.0),
    (519, 1, 10.0),
    (520, 1, 10.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (521, 1, 5.0),
    (522, 1, 5.0),
    (523, 1, 6.0),
    (524, 1, 6.0),
    (525, 1, 6.0),
    (526, 1, 5.0),
    (527, 1, 133.0),
    (528, 1, 10.0),
    (529, 1, 5.0),
    (530, 1, 12.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (531, 1, 12.0),
    (532, 1, 11.0),
    (533, 1, 2.0),
    (534, 1, 3.0),
    (535, 1, 3.0),
    (536, 1, 3.0),
    (537, 1, 9.0),
    (538, 1, 3.0),
    (539, 1, 11.0),
    (540, 1, 11.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (541, 1, 3.0),
    (542, 1, 6.0),
    (543, 1, 14.0),
    (544, 1, 10.0),
    (545, 1, 11.0),
    (546, 1, 10.0),
    (547, 1, 8.0),
    (548, 1, 643.0),
    (549, 1, 1160.0),
    (550, 1, 860.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (551, 1, 818.0),
    (552, 1, 761.0),
    (553, 1, 800.0),
    (554, 1, 1103.0),
    (555, 1, 39.0),
    (556, 1, 35.0),
    (557, 1, 55.0),
    (558, 1, 37.0),
    (559, 1, 26.0),
    (560, 1, 39.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (561, 1, 25.0),
    (562, 1, 21.0),
    (563, 1, 12.0),
    (564, 1, 94.0),
    (565, 1, 68.0),
    (566, 1, 86.0),
    (567, 1, 14.0),
    (568, 1, 13.0),
    (569, 1, 94.0),
    (570, 1, 186.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (571, 1, 76.0),
    (572, 1, 170.0),
    (573, 1, 165.0),
    (574, 1, 14.0),
    (575, 1, 14.0),
    (576, 1, 9.0),
    (577, 1, 11.0),
    (578, 1, 12.0),
    (579, 1, 10.0),
    (580, 1, 11.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (581, 1, 19.0),
    (582, 1, 6.0),
    (583, 1, 18.0),
    (584, 1, 16.0),
    (585, 1, 14.0),
    (586, 1, 15.0),
    (587, 1, 29.0),
    (588, 1, 18.0),
    (589, 1, 31.0),
    (590, 1, 10.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (591, 1, 8.0),
    (592, 1, 24.0),
    (593, 1, 37.0),
    (594, 1, 22.0),
    (595, 1, 15.0),
    (596, 1, 62.0),
    (597, 1, 26.0),
    (598, 1, 33.0),
    (599, 1, 42.0),
    (600, 1, 11.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (601, 1, 11.0),
    (602, 1, 10.0),
    (603, 1, 37.0),
    (604, 1, 11.0),
    (605, 1, 13.0),
    (606, 1, 7.0),
    (607, 1, 5.0),
    (608, 1, 4.0),
    (609, 1, 4.0),
    (610, 1, 4.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (611, 1, 4.0),
    (612, 1, 14.0),
    (613, 1, 13.0),
    (614, 1, 7.0),
    (615, 1, 12.0),
    (616, 1, 5.0),
    (617, 1, 13.0),
    (618, 1, 9.0),
    (619, 1, 7.0),
    (620, 1, 3.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (621, 1, 54.0),
    (622, 1, 12.0),
    (623, 1, 10.0),
    (624, 1, 12.0),
    (625, 1, 13.0),
    (626, 1, 35.0),
    (627, 1, 26.0),
    (628, 1, 18.0),
    (629, 1, 35.0),
    (630, 1, 5.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (631, 1, 6.0),
    (632, 1, 11.0),
    (633, 1, 8.0),
    (634, 1, 11.0),
    (635, 1, 2.0),
    (636, 1, 20.0),
    (637, 1, 15.0),
    (638, 1, 12.0),
    (639, 1, 4.0),
    (640, 1, 3.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (641, 1, 2.0),
    (642, 1, 4.0),
    (643, 1, 4.0),
    (644, 1, 9.0),
    (645, 1, 4.0),
    (646, 1, 5.0),
    (647, 1, 4.0),
    (648, 1, 6.0),
    (649, 1, 8.0),
    (650, 1, 6.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (651, 1, 5.0),
    (652, 1, 10.0),
    (653, 1, 73.0),
    (654, 1, 74.0),
    (655, 1, 7.0),
    (656, 1, 16.0),
    (657, 1, 17.0),
    (658, 1, 29.0),
    (659, 1, 29.0),
    (660, 1, 12.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (661, 1, 6.0),
    (662, 1, 8.0),
    (663, 1, 8.0),
    (664, 1, 3.0),
    (665, 1, 16.0),
    (666, 1, 16.0),
    (667, 1, 17.0),
    (668, 1, 13.0),
    (669, 1, 16.0),
    (670, 1, 24.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (671, 1, 9.0),
    (672, 1, 16.0),
    (673, 1, 6.0),
    (674, 1, 5.0),
    (675, 1, 7.0),
    (676, 1, 10.0),
    (677, 1, 15.0),
    (678, 1, 39.0),
    (679, 1, 20.0),
    (680, 1, 15.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (681, 1, 22.0),
    (682, 1, 16.0),
    (683, 1, 14.0),
    (684, 1, 30.0),
    (685, 1, 24.0),
    (686, 1, 21.0),
    (687, 1, 29.0),
    (688, 1, 23.0),
    (689, 1, 20.0),
    (690, 1, 39.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (691, 1, 12.0),
    (692, 1, 9.0),
    (693, 1, 21.0),
    (694, 1, 11.0),
    (695, 1, 10.0),
    (696, 1, 19.0),
    (697, 1, 12.0),
    (698, 1, 9.0),
    (699, 1, 7.0),
    (700, 1, 8.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (701, 1, 42.0),
    (702, 1, 10.0),
    (703, 1, 4.0),
    (704, 1, 13.0),
    (705, 1, 11.0),
    (706, 1, 12.0),
    (707, 1, 12.0),
    (708, 1, 7.0),
    (709, 1, 17.0),
    (710, 1, 11.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (711, 1, 4.0),
    (712, 1, 5.0),
    (713, 1, 8.0),
    (714, 1, 17.0),
    (715, 1, 6.0),
    (716, 1, 10.0),
    (717, 1, 3.0),
    (718, 1, 5.0),
    (719, 1, 7.0),
    (720, 1, 4.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (721, 1, 4.0),
    (722, 1, 4.0),
    (723, 1, 6.0),
    (724, 1, 51.0),
    (725, 1, 12.0),
    (726, 1, 12.0),
    (727, 1, 23.0),
    (728, 1, 57.0),
    (729, 1, 26.0),
    (730, 1, 10.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (731, 1, 4.0),
    (732, 1, 5.0),
    (733, 1, 4.0),
    (734, 1, 4.0),
    (735, 1, 4.0),
    (736, 1, 4.0),
    (737, 1, 8.0),
    (738, 1, 8.0),
    (739, 1, 21.0),
    (740, 1, 10.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (741, 1, 4.0),
    (742, 1, 4.0),
    (743, 1, 12.0),
    (744, 1, 4.0),
    (745, 1, 12.0),
    (746, 1, 15.0),
    (747, 1, 41.0),
    (748, 1, 54.0),
    (749, 1, 457.0),
    (750, 1, 12.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (751, 1, 7.0),
    (752, 1, 7.0),
    (753, 1, 9.0),
    (754, 1, 191.0),
    (755, 1, 175.0),
    (756, 1, 191.0),
    (757, 1, 182.0),
    (758, 1, 185.0),
    (759, 1, 178.0),
    (760, 1, 182.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (761, 1, 174.0),
    (762, 1, 25.0),
    (763, 1, 18.0),
    (764, 1, 16.0),
    (765, 1, 34.0),
    (766, 1, 25.0),
    (767, 1, 98.0),
    (768, 1, 22.0),
    (769, 1, 25.0),
    (770, 1, 25.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (771, 1, 22.0),
    (772, 1, 41.0),
    (773, 1, 35.0),
    (774, 1, 35.0),
    (775, 1, 107.0),
    (776, 1, 30.0),
    (777, 1, 34.0),
    (778, 1, 106.0),
    (779, 1, 29.0),
    (780, 1, 12.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (781, 1, 15.0),
    (782, 1, 15.0),
    (783, 1, 15.0),
    (784, 1, 15.0),
    (785, 1, 18.0),
    (786, 1, 14.0),
    (787, 1, 15.0),
    (788, 1, 16.0),
    (789, 1, 15.0),
    (790, 1, 17.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (791, 1, 7.0),
    (792, 1, 10.0),
    (793, 1, 10.0),
    (794, 1, 10.0),
    (795, 1, 10.0),
    (796, 1, 13.0),
    (797, 1, 9.0),
    (798, 1, 11.0),
    (799, 1, 11.0),
    (800, 1, 10.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (801, 1, 22.0),
    (802, 1, 18.0),
    (803, 1, 8.0),
    (804, 1, 10.0),
    (805, 1, 15.0),
    (806, 1, 17.0),
    (807, 1, 3.0),
    (808, 1, 3.0),
    (809, 1, 3.0),
    (810, 1, 3.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (811, 1, 4.0),
    (812, 1, 17.0),
    (813, 1, 15.0),
    (814, 1, 45.0),
    (815, 1, 31.0),
    (816, 1, 117.0),
    (817, 1, 122.0),
    (818, 1, 108.0),
    (819, 1, 109.0),
    (820, 1, 51.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (821, 1, 54.0),
    (822, 1, 232.0),
    (823, 1, 249.0),
    (824, 1, 210.0),
    (825, 1, 242.0),
    (826, 1, 242.0),
    (827, 1, 204.0),
    (828, 1, 242.0),
    (829, 1, 242.0),
    (830, 1, 203.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (831, 1, 204.0),
    (832, 1, 81.0),
    (833, 1, 85.0),
    (834, 1, 187.0),
    (835, 1, 195.0),
    (836, 1, 45.0),
    (837, 1, 235.0),
    (838, 1, 169.0),
    (839, 1, 228.0),
    (840, 1, 228.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (841, 1, 164.0),
    (842, 1, 114.0),
    (843, 1, 254.0),
    (844, 1, 272.0),
    (845, 1, 150.0),
    (846, 1, 265.0),
    (847, 1, 265.0),
    (848, 1, 146.0),
    (849, 1, 250.0),
    (850, 1, 115.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (851, 1, 123.0),
    (852, 1, 101.0),
    (853, 1, 120.0),
    (854, 1, 120.0),
    (855, 1, 98.0),
    (856, 1, 52.0),
    (857, 1, 68.0),
    (858, 1, 79.0),
    (859, 1, 153.0),
    (860, 1, 127.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (861, 1, 76.0),
    (862, 1, 77.0),
    (863, 1, 77.0),
    (864, 1, 77.0),
    (865, 1, 149.0),
    (866, 1, 124.0),
    (867, 1, 148.0),
    (868, 1, 149.0),
    (869, 1, 123.0),
    (870, 1, 124.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (871, 1, 58.0),
    (872, 1, 102.0),
    (873, 1, 235.0),
    (874, 1, 60.0),
    (875, 1, 66.0),
    (876, 1, 112.0),
    (877, 1, 137.0),
    (878, 1, 152.0),
    (879, 1, 133.0),
    (880, 1, 133.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (881, 1, 148.0),
    (882, 1, 120.0),
    (883, 1, 125.0),
    (884, 1, 41.0),
    (885, 1, 32.0),
    (886, 1, 46.0),
    (887, 1, 46.0),
    (888, 1, 48.0),
    (889, 1, 33.0),
    (890, 1, 47.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (891, 1, 47.0),
    (892, 1, 32.0),
    (893, 1, 47.0),
    (894, 1, 47.0),
    (895, 1, 32.0),
    (896, 1, 33.0),
    (897, 1, 41.0),
    (898, 1, 72.0),
    (899, 1, 43.0),
    (900, 1, 105.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (901, 1, 106.0),
    (902, 1, 108.0),
    (903, 1, 36.0),
    (904, 1, 30.0),
    (905, 1, 31.0),
    (906, 1, 33.0),
    (907, 1, 25.0),
    (908, 1, 30.0),
    (909, 1, 31.0),
    (910, 1, 31.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (911, 1, 31.0),
    (912, 1, 32.0),
    (913, 1, 25.0),
    (914, 1, 32.0),
    (915, 1, 33.0),
    (916, 1, 24.0),
    (917, 1, 25.0),
    (918, 1, 35.0),
    (919, 1, 31.0),
    (920, 1, 30.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (921, 1, 30.0),
    (922, 1, 31.0),
    (923, 1, 29.0),
    (924, 1, 29.0),
    (925, 1, 24.0),
    (926, 1, 28.0),
    (927, 1, 28.0),
    (928, 1, 28.0),
    (929, 1, 24.0),
    (930, 1, 26.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (931, 1, 22.0),
    (932, 1, 21.0),
    (933, 1, 22.0),
    (934, 1, 22.0),
    (935, 1, 35.0),
    (936, 1, 22.0),
    (937, 1, 22.0),
    (938, 1, 23.0),
    (939, 1, 22.0),
    (940, 1, 22.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (941, 1, 23.0),
    (942, 1, 22.0),
    (943, 1, 17.0),
    (944, 1, 22.0),
    (945, 1, 22.0),
    (946, 1, 22.0),
    (947, 1, 39.0),
    (948, 1, 55.0),
    (949, 1, 55.0),
    (950, 1, 21.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (951, 1, 46.0),
    (952, 1, 55.0),
    (953, 1, 55.0),
    (954, 1, 51.0),
    (955, 1, 55.0),
    (956, 1, 23.0),
    (957, 1, 37.0),
    (958, 1, 29.0),
    (959, 1, 12.0),
    (960, 1, 11.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (961, 1, 19.0),
    (962, 1, 8.0),
    (963, 1, 8.0),
    (964, 1, 264.0),
    (965, 1, 239.0),
    (966, 1, 35.0),
    (967, 1, 13.0),
    (968, 1, 32.0),
    (969, 1, 21.0),
    (970, 1, 24.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (971, 1, 13.0),
    (972, 1, 40.0),
    (973, 1, 16.0),
    (974, 1, 33.0),
    (975, 1, 42.0),
    (976, 1, 164.0),
    (977, 1, 22.0),
    (978, 1, 46.0),
    (979, 1, 49.0),
    (980, 1, 2.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (981, 1, 16.0),
    (982, 1, 9.0),
    (983, 1, 12.0),
    (984, 1, 24.0),
    (985, 1, 5.0),
    (986, 1, 25.0),
    (987, 1, 6.0),
    (988, 1, 7.0),
    (989, 1, 6.0),
    (990, 1, 14.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (991, 1, 25.0),
    (992, 1, 43.0),
    (993, 1, 129.0),
    (994, 1, 43.0),
    (995, 1, 21.0),
    (996, 1, 16.0),
    (997, 1, 30.0),
    (998, 1, 33.0),
    (999, 1, 59.0),
    (1000, 1, 57.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1001, 1, 60.0),
    (1002, 1, 25.0),
    (1003, 1, 8.0),
    (1004, 1, 26.0),
    (1005, 1, 18.0),
    (1006, 1, 16.0),
    (1007, 1, 25.0),
    (1008, 1, 25.0),
    (1009, 1, 18.0),
    (1010, 1, 16.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1011, 1, 25.0),
    (1012, 1, 26.0),
    (1013, 1, 18.0),
    (1014, 1, 18.0),
    (1015, 1, 16.0),
    (1016, 1, 16.0),
    (1017, 1, 8.0),
    (1018, 1, 30.0),
    (1019, 1, 29.0),
    (1020, 1, 30.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1021, 1, 40.0),
    (1022, 1, 42.0),
    (1023, 1, 42.0),
    (1024, 1, 36.0),
    (1025, 1, 38.0),
    (1026, 1, 41.0),
    (1027, 1, 41.0),
    (1028, 1, 35.0),
    (1029, 1, 40.0),
    (1030, 1, 41.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1031, 1, 41.0),
    (1032, 1, 41.0),
    (1033, 1, 35.0),
    (1034, 1, 36.0),
    (1035, 1, 38.0),
    (1036, 1, 37.0),
    (1037, 1, 37.0),
    (1038, 1, 37.0),
    (1039, 1, 40.0),
    (1040, 1, 48.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1041, 1, 56.0),
    (1042, 1, 17.0),
    (1043, 1, 15.0),
    (1044, 1, 15.0),
    (1045, 1, 17.0),
    (1046, 1, 15.0),
    (1047, 1, 14.0),
    (1048, 1, 9.0),
    (1049, 1, 17.0),
    (1050, 1, 34.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1051, 1, 44.0),
    (1052, 1, 26.0),
    (1053, 1, 43.0),
    (1054, 1, 43.0),
    (1055, 1, 26.0),
    (1056, 1, 43.0),
    (1057, 1, 164.0),
    (1058, 1, 159.0),
    (1059, 1, 23.0),
    (1060, 1, 17.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1061, 1, 23.0),
    (1062, 1, 23.0),
    (1063, 1, 17.0),
    (1064, 1, 22.0),
    (1065, 1, 23.0),
    (1066, 1, 17.0),
    (1067, 1, 17.0),
    (1068, 1, 48.0),
    (1069, 1, 56.0),
    (1070, 1, 18.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1071, 1, 3.0),
    (1072, 1, 2.0),
    (1073, 1, 3.0),
    (1074, 1, 3.0),
    (1075, 1, 3.0),
    (1076, 1, 2.0),
    (1077, 1, 3.0),
    (1078, 1, 3.0),
    (1079, 1, 2.0),
    (1080, 1, 3.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1081, 1, 3.0),
    (1082, 1, 4.0),
    (1083, 1, 3.0),
    (1084, 1, 3.0),
    (1085, 1, 3.0),
    (1086, 1, 4.0),
    (1087, 1, 4.0),
    (1088, 1, 4.0),
    (1089, 1, 5.0),
    (1090, 1, 19.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1091, 1, 10.0),
    (1092, 1, 10.0),
    (1093, 1, 36.0),
    (1094, 1, 25.0),
    (1095, 1, 26.0),
    (1096, 1, 6.0),
    (1097, 1, 6.0),
    (1098, 1, 6.0),
    (1099, 1, 11.0),
    (1100, 1, 6.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1101, 1, 7.0),
    (1102, 1, 1.0),
    (1103, 1, 88.0),
    (1104, 1, 74.0),
    (1105, 1, 86.0),
    (1106, 1, 86.0),
    (1107, 1, 72.0),
    (1108, 1, 18.0),
    (1109, 1, 36.0),
    (1110, 1, 23.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1111, 1, 23.0),
    (1112, 1, 25.0),
    (1113, 1, 26.0),
    (1114, 1, 24.0),
    (1115, 1, 23.0),
    (1116, 1, 24.0),
    (1117, 1, 26.0),
    (1118, 1, 24.0),
    (1119, 1, 23.0),
    (1120, 1, 25.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1121, 1, 26.0),
    (1122, 1, 23.0),
    (1123, 1, 24.0),
    (1124, 1, 22.0),
    (1125, 1, 23.0),
    (1126, 1, 22.0),
    (1127, 1, 22.0),
    (1128, 1, 22.0),
    (1129, 1, 23.0),
    (1130, 1, 8.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1131, 1, 6.0),
    (1132, 1, 45.0),
    (1133, 1, 46.0),
    (1134, 1, 30.0),
    (1135, 1, 45.0),
    (1136, 1, 59.0),
    (1137, 1, 44.0),
    (1138, 1, 44.0),
    (1139, 1, 58.0),
    (1140, 1, 129.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1141, 1, 126.0),
    (1142, 1, 22.0),
    (1143, 1, 19.0),
    (1144, 1, 22.0),
    (1145, 1, 22.0),
    (1146, 1, 18.0),
    (1147, 1, 12.0),
    (1148, 1, 21.0),
    (1149, 1, 22.0),
    (1150, 1, 18.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1151, 1, 19.0),
    (1152, 1, 21.0),
    (1153, 1, 32.0),
    (1154, 1, 6.0),
    (1155, 1, 18.0),
    (1156, 1, 17.0),
    (1157, 1, 16.0),
    (1158, 1, 17.0),
    (1159, 1, 17.0),
    (1160, 1, 25.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1161, 1, 25.0),
    (1162, 1, 22.0),
    (1163, 1, 25.0),
    (1164, 1, 25.0),
    (1165, 1, 21.0),
    (1166, 1, 24.0),
    (1167, 1, 25.0),
    (1168, 1, 21.0),
    (1169, 1, 22.0),
    (1170, 1, 24.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1171, 1, 24.0),
    (1172, 1, 23.0),
    (1173, 1, 24.0),
    (1174, 1, 14.0),
    (1175, 1, 13.0),
    (1176, 1, 21.0),
    (1177, 1, 18.0),
    (1178, 1, 18.0),
    (1179, 1, 25.0),
    (1180, 1, 25.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1181, 1, 28.0),
    (1182, 1, 28.0),
    (1183, 1, 36.0),
    (1184, 1, 35.0),
    (1185, 1, 54.0),
    (1186, 1, 85.0),
    (1187, 1, 42.0),
    (1188, 1, 33.0),
    (1189, 1, 44.0),
    (1190, 1, 28.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1191, 1, 180.0),
    (1192, 1, 164.0),
    (1193, 1, 147.0),
    (1194, 1, 27.0),
    (1195, 1, 52.0),
    (1196, 1, 72.0),
    (1197, 1, 33.0),
    (1198, 1, 90.0),
    (1199, 1, 26.0),
    (1200, 1, 82.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1201, 1, 63.0),
    (1202, 1, 18.0),
    (1203, 1, 22.0),
    (1204, 1, 19.0),
    (1205, 1, 21.0),
    (1206, 1, 17.0),
    (1207, 1, 35.0),
    (1208, 1, 11.0),
    (1209, 1, 40.0),
    (1210, 1, 4.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1211, 1, 20.0),
    (1212, 1, 37.0),
    (1213, 1, 27.0),
    (1214, 1, 33.0),
    (1215, 1, 54.0),
    (1216, 1, 3.0),
    (1217, 1, 61.0),
    (1218, 1, 9.0),
    (1219, 1, 74.0),
    (1220, 1, 6.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1221, 1, 70.0),
    (1222, 1, 88.0),
    (1223, 1, 52.0),
    (1224, 1, 88.0),
    (1225, 1, 121.0),
    (1226, 1, 60.0),
    (1227, 1, 7.0),
    (1228, 1, 61.0),
    (1229, 1, 36.0),
    (1230, 1, 54.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1231, 1, 45.0),
    (1232, 1, 22.0),
    (1233, 1, 109.0),
    (1234, 1, 21.0),
    (1235, 1, 27.0),
    (1236, 1, 15.0),
    (1237, 1, 11.0),
    (1238, 1, 11.0),
    (1239, 1, 15.0),
    (1240, 1, 138.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1241, 1, 19.0),
    (1242, 1, 20.0),
    (1243, 1, 8.0),
    (1244, 1, 8.0),
    (1245, 1, 12.0),
    (1246, 1, 13.0),
    (1247, 1, 12.0),
    (1248, 1, 12.0),
    (1249, 1, 24.0),
    (1250, 1, 22.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1251, 1, 23.0),
    (1252, 1, 24.0),
    (1253, 1, 24.0),
    (1254, 1, 16.0),
    (1255, 1, 16.0),
    (1256, 1, 65.0),
    (1257, 1, 65.0),
    (1258, 1, 14.0),
    (1259, 1, 24.0),
    (1260, 1, 24.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1261, 1, 33.0),
    (1262, 1, 34.0),
    (1263, 1, 18.0),
    (1264, 1, 18.0),
    (1265, 1, 45.0),
    (1266, 1, 21.0),
    (1267, 1, 23.0),
    (1268, 1, 78.0),
    (1269, 1, 57.0),
    (1270, 1, 17.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1271, 1, 10.0),
    (1272, 1, 8.0),
    (1273, 1, 14.0),
    (1274, 1, 10.0),
    (1275, 1, 7.0),
    (1276, 1, 0.0),
    (1277, 1, 19.0),
    (1278, 1, 8.0),
    (1279, 1, 2.0),
    (1280, 1, 4.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1281, 1, 7.0),
    (1282, 1, 3.0),
    (1283, 1, 11.0),
    (1284, 1, 2.0),
    (1285, 1, 4.0),
    (1286, 1, 3.0),
    (1287, 1, 3.0),
    (1288, 1, 3.0),
    (1289, 1, 3.0),
    (1290, 1, 3.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1291, 1, 4.0),
    (1292, 1, 43.0),
    (1293, 1, 10.0),
    (1294, 1, 5.0),
    (1295, 1, 9.0),
    (1296, 1, 10.0),
    (1297, 1, 5.0),
    (1298, 1, 0.0),
    (1299, 1, 3.0),
    (1300, 1, 2.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1301, 1, 7.0),
    (1302, 1, 8.0),
    (1303, 1, 5.0),
    (1304, 1, 100.0),
    (1305, 1, 7.0),
    (1306, 1, 9.0),
    (1307, 1, 7.0),
    (1308, 1, 4.0),
    (1309, 1, 0.0),
    (1310, 1, 19.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1, 2, 4.83),
    (2, 2, 4.63),
    (3, 2, 4.9),
    (4, 2, 5.18),
    (5, 2, 4.92),
    (6, 2, 5.18),
    (7, 2, 4.92),
    (8, 2, 4.9),
    (9, 2, 4.63),
    (10, 2, 4.81);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (11, 2, 7.48),
    (12, 2, 4.45),
    (13, 2, 4.6),
    (14, 2, 5.86),
    (15, 2, 10.04),
    (16, 2, 10.04),
    (17, 2, 11.15),
    (18, 2, 11.35),
    (19, 2, 10.22),
    (20, 2, 10.78);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (21, 2, 15.69),
    (22, 2, 7.04),
    (23, 2, 5.57),
    (24, 2, 7.04),
    (25, 2, 8.08),
    (26, 2, 3.6),
    (27, 2, 4.75),
    (28, 2, 3.6),
    (29, 2, 3.64),
    (30, 2, 15.69);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (31, 2, 14.43),
    (32, 2, 15.69),
    (33, 2, 7.64),
    (34, 2, 10.78),
    (35, 2, 11.8),
    (36, 2, 10.78),
    (37, 2, 10.81),
    (38, 2, 13.02),
    (39, 2, 11.76),
    (40, 2, 13.02);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (41, 2, 7.94),
    (42, 2, 8.18),
    (43, 2, 9.21),
    (44, 2, 8.18),
    (45, 2, 8.22),
    (46, 2, 20.02),
    (47, 2, 12.55),
    (48, 2, 13.68),
    (49, 2, 16.08),
    (50, 2, 9.08);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (51, 2, 5.57),
    (52, 2, 11.9),
    (53, 2, 7.12),
    (54, 2, 6.9),
    (55, 2, 6.77),
    (56, 2, 6.77),
    (57, 2, 6.87),
    (58, 2, 6.87),
    (59, 2, 6.87),
    (60, 2, 6.87);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (61, 2, 6.99),
    (62, 2, 6.99),
    (63, 2, 6.99),
    (64, 2, 6.99),
    (65, 2, 6.9),
    (66, 2, 6.9),
    (67, 2, 5.87),
    (68, 2, 7.36),
    (69, 2, 7.38),
    (70, 2, 7.38);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (71, 2, 7.38),
    (72, 2, 7.38),
    (73, 2, 7.43),
    (74, 2, 7.43),
    (75, 2, 7.31),
    (76, 2, 7.31),
    (77, 2, 7.31),
    (78, 2, 7.31),
    (79, 2, 7.0),
    (80, 2, 11.15);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (81, 2, 6.43),
    (82, 2, 6.43),
    (83, 2, 11.15),
    (84, 2, 7.26),
    (85, 2, 7.3),
    (86, 2, 7.3),
    (87, 2, 7.3),
    (88, 2, 7.3),
    (89, 2, 7.3),
    (90, 2, 6.43);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (91, 2, 7.34),
    (92, 2, 7.34),
    (93, 2, 7.12),
    (94, 2, 7.12),
    (95, 2, 7.12),
    (96, 2, 7.12),
    (97, 2, 7.12),
    (98, 2, 7.15),
    (99, 2, 7.17),
    (100, 2, 7.07);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (101, 2, 7.07),
    (102, 2, 7.07),
    (103, 2, 7.07),
    (104, 2, 6.73),
    (105, 2, 6.73),
    (106, 2, 6.73),
    (107, 2, 6.73),
    (108, 2, 6.67),
    (109, 2, 7.12),
    (110, 2, 7.12);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (111, 2, 7.12),
    (112, 2, 7.12),
    (113, 2, 6.9),
    (114, 2, 6.94),
    (115, 2, 6.94),
    (116, 2, 6.76),
    (117, 2, 6.76),
    (118, 2, 7.21),
    (119, 2, 6.9),
    (120, 2, 23.01);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (121, 2, 23.53),
    (122, 2, 22.6),
    (123, 2, 10.97),
    (124, 2, 28.24),
    (125, 2, 17.85),
    (126, 2, 18.39),
    (127, 2, 25.13),
    (128, 2, 21.69),
    (129, 2, 19.38),
    (130, 2, 20.32);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (131, 2, 9.53),
    (132, 2, 10.48),
    (133, 2, 22.6),
    (134, 2, 9.53),
    (135, 2, 23.01),
    (136, 2, 10.48),
    (137, 2, 21.69),
    (138, 2, 28.0),
    (139, 2, 16.23),
    (140, 2, 55.35);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (141, 2, 40.43),
    (142, 2, 23.24),
    (143, 2, 6.38),
    (144, 2, 1.25),
    (145, 2, 2.43),
    (146, 2, 3.7),
    (147, 2, 1.4),
    (148, 2, 0.1),
    (149, 2, 1.4),
    (150, 2, 4.68);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (151, 2, 5.53),
    (152, 2, 5.6),
    (153, 2, 5.9),
    (154, 2, 6.79),
    (155, 2, 4.86),
    (156, 2, 4.04),
    (157, 2, 4.59),
    (158, 2, 7.38),
    (159, 2, 4.04),
    (160, 2, 0.24);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (161, 2, 4.86),
    (162, 2, 4.04),
    (163, 2, 4.04),
    (164, 2, 4.35),
    (165, 2, 6.79),
    (166, 2, 5.26),
    (167, 2, 9.25),
    (168, 2, 5.9),
    (169, 2, 4.04),
    (170, 2, 0.96);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (171, 2, 0.92),
    (172, 2, 0.96),
    (173, 2, 0.91),
    (174, 2, 0.96),
    (175, 2, 0.95),
    (176, 2, 0.9),
    (177, 2, 0.9),
    (178, 2, 0.9),
    (179, 2, 1.15),
    (180, 2, 0.91);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (181, 2, 0.9),
    (182, 2, 0.91),
    (183, 2, 0.96),
    (184, 2, 0.91),
    (185, 2, 1.11),
    (186, 2, 2.36),
    (187, 2, 2.21),
    (188, 2, 2.35),
    (189, 2, 2.21),
    (190, 2, 1.02);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (191, 2, 0.96),
    (192, 2, 1.02),
    (193, 2, 0.96),
    (194, 2, 1.36),
    (195, 2, 1.27),
    (196, 2, 0.41),
    (197, 2, 5.52),
    (198, 2, 8.48),
    (199, 2, 1.07),
    (200, 2, 1.01);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (201, 2, 2.82),
    (202, 2, 3.93),
    (203, 2, 2.82),
    (204, 2, 2.12),
    (205, 2, 2.37),
    (206, 2, 3.38),
    (207, 2, 2.98),
    (208, 2, 4.29),
    (209, 2, 8.85),
    (210, 2, 10.22);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (211, 2, 0.91),
    (212, 2, 0.95),
    (213, 2, 0.9),
    (214, 2, 0.9),
    (215, 2, 0.9),
    (216, 2, 1.15),
    (217, 2, 0.91),
    (218, 2, 0.96),
    (219, 2, 0.9),
    (220, 2, 1.45);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (221, 2, 1.4),
    (222, 2, 1.41),
    (223, 2, 1.4),
    (224, 2, 1.65),
    (225, 2, 1.49),
    (226, 2, 0.99),
    (227, 2, 1.03),
    (228, 2, 0.98),
    (229, 2, 0.99),
    (230, 2, 0.98);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (231, 2, 1.21),
    (232, 2, 0.99),
    (233, 2, 1.04),
    (234, 2, 1.43),
    (235, 2, 1.46),
    (236, 2, 1.42),
    (237, 2, 1.42),
    (238, 2, 1.42),
    (239, 2, 1.65),
    (240, 2, 1.43);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (241, 2, 1.5),
    (242, 2, 1.47),
    (243, 2, 1.55),
    (244, 2, 1.47),
    (245, 2, 1.35),
    (246, 2, 1.42),
    (247, 2, 1.35),
    (248, 2, 1.44),
    (249, 2, 1.51),
    (250, 2, 1.44);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (251, 2, 1.5),
    (252, 2, 1.58),
    (253, 2, 1.5),
    (254, 2, 1.86),
    (255, 2, 1.95),
    (256, 2, 1.86),
    (257, 2, 1.75),
    (258, 2, 1.84),
    (259, 2, 1.75),
    (260, 2, 1.83);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (261, 2, 1.92),
    (262, 2, 1.83),
    (263, 2, 1.89),
    (264, 2, 1.98),
    (265, 2, 1.89),
    (266, 2, 1.48),
    (267, 2, 1.55),
    (268, 2, 1.48),
    (269, 2, 1.37),
    (270, 2, 1.44);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (271, 2, 1.37),
    (272, 2, 1.46),
    (273, 2, 1.52),
    (274, 2, 1.46),
    (275, 2, 1.51),
    (276, 2, 1.58),
    (277, 2, 1.51),
    (278, 2, 1.66),
    (279, 2, 1.74),
    (280, 2, 1.66);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (281, 2, 1.6),
    (282, 2, 1.68),
    (283, 2, 1.6),
    (284, 2, 1.81),
    (285, 2, 1.89),
    (286, 2, 1.81),
    (287, 2, 1.67),
    (288, 2, 1.75),
    (289, 2, 1.67),
    (290, 2, 2.97);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (291, 2, 3.14),
    (292, 2, 2.97),
    (293, 2, 4.29),
    (294, 2, 2.21),
    (295, 2, 2.25),
    (296, 2, 2.2),
    (297, 2, 2.2),
    (298, 2, 2.53),
    (299, 2, 2.21),
    (300, 2, 2.35);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (301, 2, 2.56),
    (302, 2, 2.14),
    (303, 2, 2.49),
    (304, 2, 2.49),
    (305, 2, 2.77),
    (306, 2, 2.43),
    (307, 2, 2.6),
    (308, 2, 75.34),
    (309, 2, 1.88),
    (310, 2, 1.99);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (311, 2, 2.26),
    (312, 2, 1.84),
    (313, 2, 2.2),
    (314, 2, 2.21),
    (315, 2, 2.51),
    (316, 2, 2.15),
    (317, 2, 2.35),
    (318, 2, 23.78),
    (319, 2, 23.78),
    (320, 2, 25.44);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (321, 2, 24.1),
    (322, 2, 25.04),
    (323, 2, 22.6),
    (324, 2, 23.32),
    (325, 2, 23.32),
    (326, 2, 24.94),
    (327, 2, 29.76),
    (328, 2, 30.91),
    (329, 2, 29.76),
    (330, 2, 22.04);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (331, 2, 22.04),
    (332, 2, 23.57),
    (333, 2, 23.43),
    (334, 2, 24.34),
    (335, 2, 23.43),
    (336, 2, 21.36),
    (337, 2, 19.06),
    (338, 2, 18.26),
    (339, 2, 19.4),
    (340, 2, 19.4);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (341, 2, 25.94),
    (342, 2, 24.37),
    (343, 2, 24.37),
    (344, 2, 26.06),
    (345, 2, 24.33),
    (346, 2, 25.27),
    (347, 2, 24.35),
    (348, 2, 23.62),
    (349, 2, 21.07),
    (350, 2, 21.19);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (351, 2, 21.19),
    (352, 2, 22.66),
    (353, 2, 23.79),
    (354, 2, 24.72),
    (355, 2, 23.79),
    (356, 2, 20.54),
    (357, 2, 18.33),
    (358, 2, 23.49),
    (359, 2, 7.77),
    (360, 2, 17.8);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (361, 2, 21.57),
    (362, 2, 21.14),
    (363, 2, 23.29),
    (364, 2, 18.76),
    (365, 2, 17.84),
    (366, 2, 13.55),
    (367, 2, 16.28),
    (368, 2, 11.76),
    (369, 2, 13.55),
    (370, 2, 17.29);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (371, 2, 21.57),
    (372, 2, 20.56),
    (373, 2, 20.35),
    (374, 2, 19.29),
    (375, 2, 19.29),
    (376, 2, 25.48),
    (377, 2, 25.48),
    (378, 2, 27.26),
    (379, 2, 21.61),
    (380, 2, 22.45);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (381, 2, 21.64),
    (382, 2, 20.97),
    (383, 2, 19.61),
    (384, 2, 62.2),
    (385, 2, 18.71),
    (386, 2, 18.71),
    (387, 2, 20.01),
    (388, 2, 18.66),
    (389, 2, 19.17),
    (390, 2, 59.87);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (391, 2, 11.77),
    (392, 2, 30.22),
    (393, 2, 8.63),
    (394, 2, 11.62),
    (395, 2, 8.1),
    (396, 2, 2.3),
    (397, 2, 8.12),
    (398, 2, 10.0),
    (399, 2, 9.1),
    (400, 2, 10.59);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (401, 2, 7.22),
    (402, 2, 7.23),
    (403, 2, 10.2),
    (404, 2, 8.76),
    (405, 2, 7.0),
    (406, 2, 3.12),
    (407, 2, 30.82),
    (408, 2, 27.23),
    (409, 2, 27.04),
    (410, 2, 8.36);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (411, 2, 4.24),
    (412, 2, 9.07),
    (413, 2, 21.32),
    (414, 2, 68.4),
    (415, 2, 72.23),
    (416, 2, 63.5),
    (417, 2, 76.6),
    (418, 2, 74.2),
    (419, 2, 67.9),
    (420, 2, 66.3);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (421, 2, 83.4),
    (422, 2, 68.63),
    (423, 2, 69.79),
    (424, 2, 80.53),
    (425, 2, 61.3),
    (426, 2, 70.73),
    (427, 2, 70.99),
    (428, 2, 68.6),
    (429, 2, 83.7),
    (430, 2, 68.6);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (431, 2, 68.6),
    (432, 2, 61.3),
    (433, 2, 61.3),
    (434, 2, 61.3),
    (435, 2, 71.52),
    (436, 2, 59.42),
    (437, 2, 59.42),
    (438, 2, 59.42),
    (439, 2, 68.19),
    (440, 2, 58.2);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (441, 2, 57.29),
    (442, 2, 82.2),
    (443, 2, 75.23),
    (444, 2, 83.7),
    (445, 2, 71.73),
    (446, 2, 81.1),
    (447, 2, 82.64),
    (448, 2, 77.41),
    (449, 2, 80.1),
    (450, 2, 72.26);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (451, 2, 67.6),
    (452, 2, 58.38),
    (453, 2, 58.38),
    (454, 2, 57.14),
    (455, 2, 63.49),
    (456, 2, 54.59),
    (457, 2, 61.7),
    (458, 2, 56.05),
    (459, 2, 72.81),
    (460, 2, 51.9);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (461, 2, 70.14),
    (462, 2, 70.14),
    (463, 2, 70.14),
    (464, 2, 75.52),
    (465, 2, 70.14),
    (466, 2, 70.14),
    (467, 2, 70.14),
    (468, 2, 71.52),
    (469, 2, 66.3),
    (470, 2, 66.3);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (471, 2, 83.21),
    (472, 2, 85.79),
    (473, 2, 85.79),
    (474, 2, 69.14),
    (475, 2, 78.89),
    (476, 2, 68.26),
    (477, 2, 66.36),
    (478, 2, 26.55),
    (479, 2, 25.01),
    (480, 2, 29.91);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (481, 2, 51.9),
    (482, 2, 20.66),
    (483, 2, 23.87),
    (484, 2, 30.68),
    (485, 2, 29.89),
    (486, 2, 38.05),
    (487, 2, 27.23),
    (488, 2, 18.99),
    (489, 2, 23.57),
    (490, 2, 11.9);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (491, 2, 20.34),
    (492, 2, 11.17),
    (493, 2, 11.36),
    (494, 2, 11.17),
    (495, 2, 16.23),
    (496, 2, 15.95),
    (497, 2, 14.42),
    (498, 2, 14.18),
    (499, 2, 13.15),
    (500, 2, 12.74);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (501, 2, 17.07),
    (502, 2, 16.52),
    (503, 2, 15.62),
    (504, 2, 15.12),
    (505, 2, 20.23),
    (506, 2, 19.64),
    (507, 2, 20.09),
    (508, 2, 19.51),
    (509, 2, 16.62),
    (510, 2, 12.19);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (511, 2, 20.22),
    (512, 2, 21.21),
    (513, 2, 20.22),
    (514, 2, 27.99),
    (515, 2, 27.99),
    (516, 2, 27.19),
    (517, 2, 27.2),
    (518, 2, 27.22),
    (519, 2, 27.2),
    (520, 2, 27.99);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (521, 2, 25.76),
    (522, 2, 25.16),
    (523, 2, 25.16),
    (524, 2, 25.18),
    (525, 2, 25.16),
    (526, 2, 25.76),
    (527, 2, 25.01),
    (528, 2, 31.12),
    (529, 2, 8.4),
    (530, 2, 19.1);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (531, 2, 19.1),
    (532, 2, 18.7),
    (533, 2, 20.97),
    (534, 2, 20.63),
    (535, 2, 21.21),
    (536, 2, 20.63),
    (537, 2, 17.22),
    (538, 2, 24.9),
    (539, 2, 20.62),
    (540, 2, 20.62);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (541, 2, 24.31),
    (542, 2, 19.9),
    (543, 2, 31.9),
    (544, 2, 18.48),
    (545, 2, 17.31),
    (546, 2, 18.48),
    (547, 2, 23.11),
    (548, 2, 69.4),
    (549, 2, 73.48),
    (550, 2, 83.14);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (551, 2, 83.4),
    (552, 2, 80.47),
    (553, 2, 80.06),
    (554, 2, 74.22),
    (555, 2, 18.4),
    (556, 2, 16.09),
    (557, 2, 13.77),
    (558, 2, 15.0),
    (559, 2, 19.24),
    (560, 2, 18.4);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (561, 2, 19.98),
    (562, 2, 16.47),
    (563, 2, 12.07),
    (564, 2, 4.23),
    (565, 2, 9.93),
    (566, 2, 12.02),
    (567, 2, 9.86),
    (568, 2, 13.05),
    (569, 2, 21.53),
    (570, 2, 19.65);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (571, 2, 20.14),
    (572, 2, 18.42),
    (573, 2, 19.71),
    (574, 2, 6.09),
    (575, 2, 10.08),
    (576, 2, 6.78),
    (577, 2, 6.66),
    (578, 2, 6.02),
    (579, 2, 6.21),
    (580, 2, 4.87);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (581, 2, 10.68),
    (582, 2, 9.04),
    (583, 2, 13.95),
    (584, 2, 15.4),
    (585, 2, 15.4),
    (586, 2, 15.4),
    (587, 2, 15.57),
    (588, 2, 13.95),
    (589, 2, 14.11),
    (590, 2, 2.95);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (591, 2, 13.73),
    (592, 2, 12.56),
    (593, 2, 13.34),
    (594, 2, 10.66),
    (595, 2, 9.15),
    (596, 2, 15.9),
    (597, 2, 9.32),
    (598, 2, 10.54),
    (599, 2, 11.78),
    (600, 2, 11.82);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (601, 2, 9.57),
    (602, 2, 14.07),
    (603, 2, 13.34),
    (604, 2, 10.18),
    (605, 2, 16.24),
    (606, 2, 15.32),
    (607, 2, 14.8),
    (608, 2, 17.97),
    (609, 2, 12.26),
    (610, 2, 17.97);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (611, 2, 26.1),
    (612, 2, 22.7),
    (613, 2, 11.12),
    (614, 2, 13.85),
    (615, 2, 8.53),
    (616, 2, 22.71),
    (617, 2, 32.43),
    (618, 2, 8.16),
    (619, 2, 8.27),
    (620, 2, 6.73);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (621, 2, 41.97),
    (622, 2, 16.16),
    (623, 2, 18.79),
    (624, 2, 16.16),
    (625, 2, 16.24),
    (626, 2, 19.18),
    (627, 2, 19.36),
    (628, 2, 14.32),
    (629, 2, 14.0),
    (630, 2, 16.53);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (631, 2, 9.09),
    (632, 2, 14.98),
    (633, 2, 16.22),
    (634, 2, 14.98),
    (635, 2, 9.18),
    (636, 2, 10.82),
    (637, 2, 13.1),
    (638, 2, 23.38),
    (639, 2, 10.1),
    (640, 2, 11.94);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (641, 2, 13.59),
    (642, 2, 10.3),
    (643, 2, 10.1),
    (644, 2, 15.18),
    (645, 2, 10.65),
    (646, 2, 13.47),
    (647, 2, 15.15),
    (648, 2, 11.79),
    (649, 2, 18.59),
    (650, 2, 11.42);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (651, 2, 13.54),
    (652, 2, 18.7),
    (653, 2, 17.45),
    (654, 2, 62.5),
    (655, 2, 7.55),
    (656, 2, 9.94),
    (657, 2, 12.47),
    (658, 2, 9.61),
    (659, 2, 15.67),
    (660, 2, 14.57);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (661, 2, 22.66),
    (662, 2, 12.17),
    (663, 2, 11.97),
    (664, 2, 40.4),
    (665, 2, 12.9),
    (666, 2, 12.9),
    (667, 2, 7.96),
    (668, 2, 23.53),
    (669, 2, 9.13),
    (670, 2, 16.45);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (671, 2, 13.94),
    (672, 2, 13.48),
    (673, 2, 14.1),
    (674, 2, 15.8),
    (675, 2, 12.41),
    (676, 2, 11.29),
    (677, 2, 12.2),
    (678, 2, 29.61),
    (679, 2, 20.12),
    (680, 2, 13.57);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (681, 2, 15.25),
    (682, 2, 17.28),
    (683, 2, 17.54),
    (684, 2, 17.49),
    (685, 2, 18.11),
    (686, 2, 13.02),
    (687, 2, 14.61),
    (688, 2, 16.57),
    (689, 2, 16.95),
    (690, 2, 39.83);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (691, 2, 12.79),
    (692, 2, 7.04),
    (693, 2, 12.1),
    (694, 2, 12.46),
    (695, 2, 11.16),
    (696, 2, 10.91),
    (697, 2, 7.8),
    (698, 2, 9.47),
    (699, 2, 7.26),
    (700, 2, 15.73);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (701, 2, 14.77),
    (702, 2, 14.51),
    (703, 2, 13.6),
    (704, 2, 12.87),
    (705, 2, 13.13),
    (706, 2, 17.45),
    (707, 2, 5.17),
    (708, 2, 7.55),
    (709, 2, 13.12),
    (710, 2, 13.63);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (711, 2, 18.01),
    (712, 2, 15.64),
    (713, 2, 13.3),
    (714, 2, 13.12),
    (715, 2, 11.61),
    (716, 2, 14.51),
    (717, 2, 17.39),
    (718, 2, 15.76),
    (719, 2, 14.93),
    (720, 2, 16.44);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (721, 2, 16.44),
    (722, 2, 16.44),
    (723, 2, 17.96),
    (724, 2, 13.36),
    (725, 2, 13.69),
    (726, 2, 13.69),
    (727, 2, 15.31),
    (728, 2, 11.29),
    (729, 2, 14.14),
    (730, 2, 16.44);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (731, 2, 10.8),
    (732, 2, 10.3),
    (733, 2, 21.34),
    (734, 2, 21.34),
    (735, 2, 14.48),
    (736, 2, 14.48),
    (737, 2, 10.8),
    (738, 2, 11.6),
    (739, 2, 23.52),
    (740, 2, 14.98);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (741, 2, 11.7),
    (742, 2, 11.7),
    (743, 2, 15.38),
    (744, 2, 11.7),
    (745, 2, 11.86),
    (746, 2, 11.4),
    (747, 2, 12.7),
    (748, 2, 17.58),
    (749, 2, 71.82),
    (750, 2, 18.75);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (751, 2, 14.45),
    (752, 2, 14.45),
    (753, 2, 14.62),
    (754, 2, 13.51),
    (755, 2, 12.99),
    (756, 2, 13.51),
    (757, 2, 12.88),
    (758, 2, 13.54),
    (759, 2, 13.12),
    (760, 2, 13.31);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (761, 2, 12.74),
    (762, 2, 17.6),
    (763, 2, 14.65),
    (764, 2, 12.78),
    (765, 2, 13.29),
    (766, 2, 17.6),
    (767, 2, 15.98),
    (768, 2, 15.14),
    (769, 2, 17.6),
    (770, 2, 16.77);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (771, 2, 14.48),
    (772, 2, 13.2),
    (773, 2, 12.63),
    (774, 2, 12.63),
    (775, 2, 11.54),
    (776, 2, 11.16),
    (777, 2, 13.29),
    (778, 2, 12.13),
    (779, 2, 11.69),
    (780, 2, 15.37);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (781, 2, 16.18),
    (782, 2, 15.13),
    (783, 2, 15.91),
    (784, 2, 15.13),
    (785, 2, 14.89),
    (786, 2, 15.02),
    (787, 2, 15.81),
    (788, 2, 15.49),
    (789, 2, 16.0),
    (790, 2, 17.17);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (791, 2, 17.32),
    (792, 2, 15.81),
    (793, 2, 16.98),
    (794, 2, 17.86),
    (795, 2, 16.98),
    (796, 2, 16.8),
    (797, 2, 16.95),
    (798, 2, 17.86),
    (799, 2, 17.49),
    (800, 2, 17.94);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (801, 2, 20.64),
    (802, 2, 36.39),
    (803, 2, 16.26),
    (804, 2, 12.89),
    (805, 2, 10.53),
    (806, 2, 8.81),
    (807, 2, 31.8),
    (808, 2, 30.87),
    (809, 2, 31.89),
    (810, 2, 30.88);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (811, 2, 30.88),
    (812, 2, 39.62),
    (813, 2, 34.72),
    (814, 2, 27.55),
    (815, 2, 33.59),
    (816, 2, 4.33),
    (817, 2, 4.51),
    (818, 2, 2.85),
    (819, 2, 2.88),
    (820, 2, 3.74);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (821, 2, 3.9),
    (822, 2, 5.42),
    (823, 2, 5.81),
    (824, 2, 7.08),
    (825, 2, 5.65),
    (826, 2, 5.65),
    (827, 2, 6.88),
    (828, 2, 5.64),
    (829, 2, 5.65),
    (830, 2, 6.87);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (831, 2, 6.88),
    (832, 2, 5.5),
    (833, 2, 5.73),
    (834, 2, 9.2),
    (835, 2, 9.58),
    (836, 2, 2.98),
    (837, 2, 5.16),
    (838, 2, 5.75),
    (839, 2, 5.02),
    (840, 2, 5.02);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (841, 2, 5.59),
    (842, 2, 2.71),
    (843, 2, 4.42),
    (844, 2, 4.74),
    (845, 2, 5.28),
    (846, 2, 4.61),
    (847, 2, 4.61),
    (848, 2, 5.14),
    (849, 2, 4.85),
    (850, 2, 4.67);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (851, 2, 5.01),
    (852, 2, 3.1),
    (853, 2, 4.87),
    (854, 2, 4.87),
    (855, 2, 3.02),
    (856, 2, 3.01),
    (857, 2, 2.41),
    (858, 2, 3.1),
    (859, 2, 4.79),
    (860, 2, 3.4);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (861, 2, 3.01),
    (862, 2, 3.02),
    (863, 2, 3.01),
    (864, 2, 3.01),
    (865, 2, 4.65),
    (866, 2, 3.31),
    (867, 2, 4.65),
    (868, 2, 4.66),
    (869, 2, 3.3),
    (870, 2, 3.31);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (871, 2, 6.11),
    (872, 2, 7.13),
    (873, 2, 9.86),
    (874, 2, 4.28),
    (875, 2, 8.79),
    (876, 2, 6.98),
    (877, 2, 4.35),
    (878, 2, 4.96),
    (879, 2, 4.23),
    (880, 2, 4.23);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (881, 2, 4.83),
    (882, 2, 1.29),
    (883, 2, 1.35),
    (884, 2, 6.47),
    (885, 2, 7.15),
    (886, 2, 6.27),
    (887, 2, 6.2),
    (888, 2, 6.51),
    (889, 2, 5.33),
    (890, 2, 6.33);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (891, 2, 6.33),
    (892, 2, 5.18),
    (893, 2, 6.32),
    (894, 2, 6.33),
    (895, 2, 5.18),
    (896, 2, 5.19),
    (897, 2, 15.86),
    (898, 2, 15.06),
    (899, 2, 22.41),
    (900, 2, 4.67);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (901, 2, 4.72),
    (902, 2, 6.08),
    (903, 2, 9.68),
    (904, 2, 10.15),
    (905, 2, 10.67),
    (906, 2, 7.9),
    (907, 2, 5.54),
    (908, 2, 10.36),
    (909, 2, 10.37),
    (910, 2, 10.36);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (911, 2, 10.36),
    (912, 2, 7.67),
    (913, 2, 5.38),
    (914, 2, 7.67),
    (915, 2, 7.68),
    (916, 2, 5.38),
    (917, 2, 5.39),
    (918, 2, 17.32),
    (919, 2, 5.36),
    (920, 2, 5.21);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (921, 2, 5.2),
    (922, 2, 5.21),
    (923, 2, 12.84),
    (924, 2, 11.06),
    (925, 2, 8.45),
    (926, 2, 12.47),
    (927, 2, 12.47),
    (928, 2, 10.74),
    (929, 2, 8.21),
    (930, 2, 7.86);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (931, 2, 6.77),
    (932, 2, 6.5),
    (933, 2, 8.82),
    (934, 2, 8.57),
    (935, 2, 12.14),
    (936, 2, 17.14),
    (937, 2, 17.14),
    (938, 2, 17.98),
    (939, 2, 17.14),
    (940, 2, 17.14);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (941, 2, 17.98),
    (942, 2, 17.14),
    (943, 2, 37.69),
    (944, 2, 20.05),
    (945, 2, 21.04),
    (946, 2, 20.05),
    (947, 2, 17.22),
    (948, 2, 37.45),
    (949, 2, 37.45),
    (950, 2, 16.35);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (951, 2, 31.63),
    (952, 2, 37.45),
    (953, 2, 37.3),
    (954, 2, 34.87),
    (955, 2, 37.45),
    (956, 2, 6.86),
    (957, 2, 14.1),
    (958, 2, 21.78),
    (959, 2, 9.09),
    (960, 2, 3.64);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (961, 2, 6.39),
    (962, 2, 7.65),
    (963, 2, 7.67),
    (964, 2, 26.54),
    (965, 2, 24.67),
    (966, 2, 5.83),
    (967, 2, 5.94),
    (968, 2, 2.1),
    (969, 2, 11.95),
    (970, 2, 3.88);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (971, 2, 5.94),
    (972, 2, 7.41),
    (973, 2, 9.56),
    (974, 2, 6.09),
    (975, 2, 8.95),
    (976, 2, 3.33),
    (977, 2, 4.97),
    (978, 2, 3.32),
    (979, 2, 7.3),
    (980, 2, 18.7);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (981, 2, 2.95),
    (982, 2, 5.88),
    (983, 2, 8.82),
    (984, 2, 6.2),
    (985, 2, 4.13),
    (986, 2, 14.45),
    (987, 2, 5.72),
    (988, 2, 4.78),
    (989, 2, 6.65),
    (990, 2, 5.35);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (991, 2, 3.4),
    (992, 2, 8.62),
    (993, 2, 7.94),
    (994, 2, 7.55),
    (995, 2, 3.88),
    (996, 2, 3.11),
    (997, 2, 6.43),
    (998, 2, 3.44),
    (999, 2, 5.79),
    (1000, 2, 4.35);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1001, 2, 2.09),
    (1002, 2, 2.65),
    (1003, 2, 3.75),
    (1004, 2, 4.16),
    (1005, 2, 1.91),
    (1006, 2, 2.46),
    (1007, 2, 4.04),
    (1008, 2, 4.04),
    (1009, 2, 1.86),
    (1010, 2, 2.39);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1011, 2, 4.04),
    (1012, 2, 4.05),
    (1013, 2, 1.86),
    (1014, 2, 1.87),
    (1015, 2, 2.39),
    (1016, 2, 2.4),
    (1017, 2, 3.13),
    (1018, 2, 19.26),
    (1019, 2, 18.71),
    (1020, 2, 18.62);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1021, 2, 7.32),
    (1022, 2, 7.7),
    (1023, 2, 6.43),
    (1024, 2, 4.11),
    (1025, 2, 5.74),
    (1026, 2, 7.48),
    (1027, 2, 6.25),
    (1028, 2, 4.0),
    (1029, 2, 7.47),
    (1030, 2, 7.48);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1031, 2, 6.24),
    (1032, 2, 6.26),
    (1033, 2, 3.99),
    (1034, 2, 4.0),
    (1035, 2, 4.32),
    (1036, 2, 4.2),
    (1037, 2, 4.19),
    (1038, 2, 4.2),
    (1039, 2, 22.86),
    (1040, 2, 6.25);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1041, 2, 6.08),
    (1042, 2, 9.93),
    (1043, 2, 7.21),
    (1044, 2, 7.0),
    (1045, 2, 9.65),
    (1046, 2, 7.0),
    (1047, 2, 6.79),
    (1048, 2, 4.19),
    (1049, 2, 26.26),
    (1050, 2, 6.15);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1051, 2, 9.3),
    (1052, 2, 8.3),
    (1053, 2, 9.03),
    (1054, 2, 9.03),
    (1055, 2, 8.06),
    (1056, 2, 18.06),
    (1057, 2, 3.32),
    (1058, 2, 3.23),
    (1059, 2, 5.16),
    (1060, 2, 3.74);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1061, 2, 5.02),
    (1062, 2, 5.02),
    (1063, 2, 3.64),
    (1064, 2, 5.01),
    (1065, 2, 5.02),
    (1066, 2, 3.63),
    (1067, 2, 3.64),
    (1068, 2, 3.46),
    (1069, 2, 8.32),
    (1070, 2, 4.7);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1071, 2, 17.73),
    (1072, 2, 18.64),
    (1073, 2, 19.24),
    (1074, 2, 14.34),
    (1075, 2, 13.93),
    (1076, 2, 18.11),
    (1077, 2, 18.69),
    (1078, 2, 13.93),
    (1079, 2, 18.1),
    (1080, 2, 18.11);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1081, 2, 18.68),
    (1082, 2, 18.69),
    (1083, 2, 13.92),
    (1084, 2, 13.93),
    (1085, 2, 18.13),
    (1086, 2, 14.9),
    (1087, 2, 14.48),
    (1088, 2, 14.47),
    (1089, 2, 14.48),
    (1090, 2, 3.37);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1091, 2, 6.3),
    (1092, 2, 6.13),
    (1093, 2, 3.2),
    (1094, 2, 6.26),
    (1095, 2, 15.51),
    (1096, 2, 5.15),
    (1097, 2, 5.0),
    (1098, 2, 5.0),
    (1099, 2, 4.95),
    (1100, 2, 5.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1101, 2, 5.01),
    (1102, 2, 8.15),
    (1103, 2, 7.99),
    (1104, 2, 6.39),
    (1105, 2, 7.76),
    (1106, 2, 7.76),
    (1107, 2, 6.21),
    (1108, 2, 24.8),
    (1109, 2, 16.47),
    (1110, 2, 23.01);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1111, 2, 22.9),
    (1112, 2, 14.28),
    (1113, 2, 15.01),
    (1114, 2, 14.22),
    (1115, 2, 11.36),
    (1116, 2, 13.81),
    (1117, 2, 14.58),
    (1118, 2, 13.81),
    (1119, 2, 11.03),
    (1120, 2, 14.57);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1121, 2, 14.58),
    (1122, 2, 13.8),
    (1123, 2, 13.82),
    (1124, 2, 11.03),
    (1125, 2, 11.04),
    (1126, 2, 12.19),
    (1127, 2, 11.84),
    (1128, 2, 11.83),
    (1129, 2, 11.85),
    (1130, 2, 4.83);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1131, 2, 6.71),
    (1132, 2, 8.98),
    (1133, 2, 14.88),
    (1134, 2, 4.16),
    (1135, 2, 7.84),
    (1136, 2, 8.99),
    (1137, 2, 7.62),
    (1138, 2, 7.62),
    (1139, 2, 8.74),
    (1140, 2, 7.94);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1141, 2, 7.71),
    (1142, 2, 4.1),
    (1143, 2, 4.54),
    (1144, 2, 3.99),
    (1145, 2, 3.99),
    (1146, 2, 4.41),
    (1147, 2, 2.86),
    (1148, 2, 3.98),
    (1149, 2, 3.99),
    (1150, 2, 4.4);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1151, 2, 4.42),
    (1152, 2, 6.26),
    (1153, 2, 6.7),
    (1154, 2, 19.22),
    (1155, 2, 2.95),
    (1156, 2, 19.25),
    (1157, 2, 18.7),
    (1158, 2, 8.38),
    (1159, 2, 8.14),
    (1160, 2, 12.37);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1161, 2, 13.05),
    (1162, 2, 8.84),
    (1163, 2, 12.68),
    (1164, 2, 12.68),
    (1165, 2, 8.59),
    (1166, 2, 12.67),
    (1167, 2, 12.68),
    (1168, 2, 8.58),
    (1169, 2, 8.59),
    (1170, 2, 9.19);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1171, 2, 8.93),
    (1172, 2, 8.93),
    (1173, 2, 8.94),
    (1174, 2, 16.73),
    (1175, 2, 16.25),
    (1176, 2, 5.77),
    (1177, 2, 15.11),
    (1178, 2, 15.74),
    (1179, 2, 4.54),
    (1180, 2, 4.41);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1181, 2, 5.59),
    (1182, 2, 5.43),
    (1183, 2, 9.93),
    (1184, 2, 9.65),
    (1185, 2, 7.72),
    (1186, 2, 22.28),
    (1187, 2, 7.05),
    (1188, 2, 21.9),
    (1189, 2, 14.98),
    (1190, 2, 22.33);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1191, 2, 8.96),
    (1192, 2, 6.34),
    (1193, 2, 27.72),
    (1194, 2, 21.9),
    (1195, 2, 22.37),
    (1196, 2, 39.94),
    (1197, 2, 21.5),
    (1198, 2, 8.87),
    (1199, 2, 14.9),
    (1200, 2, 9.28);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1201, 2, 6.87),
    (1202, 2, 10.07),
    (1203, 2, 20.45),
    (1204, 2, 16.24),
    (1205, 2, 8.81),
    (1206, 2, 16.48),
    (1207, 2, 11.0),
    (1208, 2, 16.28),
    (1209, 2, 7.61),
    (1210, 2, 25.7);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1211, 2, 8.98),
    (1212, 2, 10.15),
    (1213, 2, 10.49),
    (1214, 2, 2.4),
    (1215, 2, 1.99),
    (1216, 2, 35.06),
    (1217, 2, 21.15),
    (1218, 2, 9.74),
    (1219, 2, 4.83),
    (1220, 2, 8.29);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1221, 2, 11.04),
    (1222, 2, 6.04),
    (1223, 2, 3.84),
    (1224, 2, 6.04),
    (1225, 2, 4.96),
    (1226, 2, 4.17),
    (1227, 2, 9.6),
    (1228, 2, 4.56),
    (1229, 2, 5.53),
    (1230, 2, 1.99);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1231, 2, 20.7),
    (1232, 2, 7.68),
    (1233, 2, 11.44),
    (1234, 2, 10.18),
    (1235, 2, 10.19),
    (1236, 2, 7.44),
    (1237, 2, 3.9),
    (1238, 2, 4.49),
    (1239, 2, 5.7),
    (1240, 2, 11.84);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1241, 2, 7.83),
    (1242, 2, 1.52),
    (1243, 2, 7.62),
    (1244, 2, 7.63),
    (1245, 2, 5.08),
    (1246, 2, 7.3),
    (1247, 2, 4.04),
    (1248, 2, 4.04),
    (1249, 2, 9.56),
    (1250, 2, 6.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1251, 2, 7.2),
    (1252, 2, 5.73),
    (1253, 2, 5.73),
    (1254, 2, 13.2),
    (1255, 2, 14.0),
    (1256, 2, 5.8),
    (1257, 2, 5.8),
    (1258, 2, 7.7),
    (1259, 2, 9.56),
    (1260, 2, 9.56);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1261, 2, 12.01),
    (1262, 2, 11.18),
    (1263, 2, 8.36),
    (1264, 2, 8.36),
    (1265, 2, 12.84),
    (1266, 2, 8.33),
    (1267, 2, 13.43),
    (1268, 2, 16.11),
    (1269, 2, 13.49),
    (1270, 2, 16.18);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1271, 2, 26.97),
    (1272, 2, 11.15),
    (1273, 2, 23.52),
    (1274, 2, 7.16),
    (1275, 2, 7.74),
    (1276, 2, 2.5),
    (1277, 2, 27.67),
    (1278, 2, 10.82),
    (1279, 2, 12.08),
    (1280, 2, 6.55);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1281, 2, 49.89),
    (1282, 2, 16.03),
    (1283, 2, 25.64),
    (1284, 2, 21.4),
    (1285, 2, 7.68),
    (1286, 2, 6.67),
    (1287, 2, 13.52),
    (1288, 2, 11.35),
    (1289, 2, 7.47),
    (1290, 2, 13.16);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1291, 2, 6.55),
    (1292, 2, 10.45),
    (1293, 2, 4.7),
    (1294, 2, 10.0),
    (1295, 2, 0.47),
    (1296, 2, 4.7),
    (1297, 2, 5.51),
    (1298, 2, 5.42),
    (1299, 2, 5.1),
    (1300, 2, 5.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1301, 2, 6.56),
    (1302, 2, 1.1),
    (1303, 2, 10.0),
    (1304, 2, 13.2),
    (1305, 2, 20.17),
    (1306, 2, 1.1),
    (1307, 2, 8.05),
    (1308, 2, 14.17),
    (1309, 2, 0.0),
    (1310, 2, 12.83);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1, 3, 52.0),
    (2, 3, 61.0),
    (3, 3, 50.0),
    (4, 3, 43.0),
    (5, 3, 34.0),
    (6, 3, 43.0),
    (7, 3, 34.0),
    (8, 3, 50.0),
    (9, 3, 61.0),
    (10, 3, 43.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (11, 3, 52.0),
    (12, 3, 69.0),
    (13, 3, 32.0),
    (14, 3, 76.0),
    (15, 3, 134.0),
    (16, 3, 134.0),
    (17, 3, 92.0),
    (18, 3, 78.0),
    (19, 3, 94.0),
    (20, 3, 91.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (21, 3, 93.0),
    (22, 3, 63.0),
    (23, 3, 78.0),
    (24, 3, 63.0),
    (25, 3, 50.0),
    (26, 3, 67.0),
    (27, 3, 94.0),
    (28, 3, 67.0),
    (29, 3, 59.0),
    (30, 3, 93.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (31, 3, 106.0),
    (32, 3, 93.0),
    (33, 3, 46.0),
    (34, 3, 91.0),
    (35, 3, 114.0),
    (36, 3, 91.0),
    (37, 3, 83.0),
    (38, 3, 82.0),
    (39, 3, 95.0),
    (40, 3, 82.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (41, 3, 47.0),
    (42, 3, 81.0),
    (43, 3, 104.0),
    (44, 3, 81.0),
    (45, 3, 73.0),
    (46, 3, 149.0),
    (47, 3, 74.0),
    (48, 3, 81.0),
    (49, 3, 104.0),
    (50, 3, 75.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (51, 3, 78.0),
    (52, 3, 98.0),
    (53, 3, 66.0),
    (54, 3, 65.0),
    (55, 3, 67.0),
    (56, 3, 67.0),
    (57, 3, 66.0),
    (58, 3, 66.0),
    (59, 3, 66.0),
    (60, 3, 66.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (61, 3, 65.0),
    (62, 3, 65.0),
    (63, 3, 65.0),
    (64, 3, 65.0),
    (65, 3, 65.0),
    (66, 3, 65.0),
    (67, 3, 58.0),
    (68, 3, 66.0),
    (69, 3, 66.0),
    (70, 3, 66.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (71, 3, 66.0),
    (72, 3, 66.0),
    (73, 3, 65.0),
    (74, 3, 65.0),
    (75, 3, 67.0),
    (76, 3, 67.0),
    (77, 3, 67.0),
    (78, 3, 67.0),
    (79, 3, 67.0),
    (80, 3, 99.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (81, 3, 62.0),
    (82, 3, 62.0),
    (83, 3, 99.0),
    (84, 3, 65.0),
    (85, 3, 66.0),
    (86, 3, 66.0),
    (87, 3, 66.0),
    (88, 3, 66.0),
    (89, 3, 66.0),
    (90, 3, 62.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (91, 3, 71.0),
    (92, 3, 71.0),
    (93, 3, 66.0),
    (94, 3, 66.0),
    (95, 3, 66.0),
    (96, 3, 66.0),
    (97, 3, 66.0),
    (98, 3, 66.0),
    (99, 3, 65.0),
    (100, 3, 66.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (101, 3, 66.0),
    (102, 3, 66.0),
    (103, 3, 66.0),
    (104, 3, 65.0),
    (105, 3, 65.0),
    (106, 3, 65.0),
    (107, 3, 65.0),
    (108, 3, 66.0),
    (109, 3, 64.0),
    (110, 3, 64.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (111, 3, 64.0),
    (112, 3, 64.0),
    (113, 3, 66.0),
    (114, 3, 67.0),
    (115, 3, 67.0),
    (116, 3, 67.0),
    (117, 3, 67.0),
    (118, 3, 66.0),
    (119, 3, 66.0),
    (120, 3, 142.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (121, 3, 156.0),
    (122, 3, 130.0),
    (123, 3, 97.0),
    (124, 3, 178.0),
    (125, 3, 113.0),
    (126, 3, 108.0),
    (127, 3, 144.0),
    (128, 3, 130.0),
    (129, 3, 106.0),
    (130, 3, 113.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (131, 3, 70.0),
    (132, 3, 76.0),
    (133, 3, 130.0),
    (134, 3, 70.0),
    (135, 3, 142.0),
    (136, 3, 76.0),
    (137, 3, 130.0),
    (138, 3, 160.0),
    (139, 3, 212.0),
    (140, 3, 315.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (141, 3, 284.0),
    (142, 3, 169.0),
    (143, 3, 207.0),
    (144, 3, 112.0),
    (145, 3, 81.0),
    (146, 3, 97.0),
    (147, 3, 188.0),
    (148, 3, 130.0),
    (149, 3, 111.0),
    (150, 3, 47.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (151, 3, 52.0),
    (152, 3, 77.0),
    (153, 3, 37.0),
    (154, 3, 91.0),
    (155, 3, 37.0),
    (156, 3, 71.0),
    (157, 3, 43.0),
    (158, 3, 66.0),
    (159, 3, 48.0),
    (160, 3, 6.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (161, 3, 33.0),
    (162, 3, 40.0),
    (163, 3, 55.0),
    (164, 3, 39.0),
    (165, 3, 91.0),
    (166, 3, 35.0),
    (167, 3, 93.0),
    (168, 3, 75.0),
    (169, 3, 30.0),
    (170, 3, 143.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (171, 3, 176.0),
    (172, 3, 143.0),
    (173, 3, 185.0),
    (174, 3, 143.0),
    (175, 3, 171.0),
    (176, 3, 192.0),
    (177, 3, 182.0),
    (178, 3, 188.0),
    (179, 3, 149.0),
    (180, 3, 185.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (181, 3, 192.0),
    (182, 3, 185.0),
    (183, 3, 143.0),
    (184, 3, 185.0),
    (185, 3, 154.0),
    (186, 3, 52.0),
    (187, 3, 100.0),
    (188, 3, 52.0),
    (189, 3, 100.0),
    (190, 3, 328.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (191, 3, 357.0),
    (192, 3, 327.0),
    (193, 3, 357.0),
    (194, 3, 224.0),
    (195, 3, 224.0),
    (196, 3, 158.0),
    (197, 3, 148.0),
    (198, 3, 288.0),
    (199, 3, 198.0),
    (200, 3, 257.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (201, 3, 172.0),
    (202, 3, 174.0),
    (203, 3, 172.0),
    (204, 3, 212.0),
    (205, 3, 155.0),
    (206, 3, 172.0),
    (207, 3, 143.0),
    (208, 3, 139.0),
    (209, 3, 121.0),
    (210, 3, 175.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (211, 3, 185.0),
    (212, 3, 171.0),
    (213, 3, 192.0),
    (214, 3, 182.0),
    (215, 3, 188.0),
    (216, 3, 149.0),
    (217, 3, 185.0),
    (218, 3, 143.0),
    (219, 3, 192.0),
    (220, 3, 194.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (221, 3, 212.0),
    (222, 3, 203.0),
    (223, 3, 209.0),
    (224, 3, 176.0),
    (225, 3, 171.0),
    (226, 3, 193.0),
    (227, 3, 181.0),
    (228, 3, 199.0),
    (229, 3, 190.0),
    (230, 3, 196.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (231, 3, 162.0),
    (232, 3, 193.0),
    (233, 3, 157.0),
    (234, 3, 209.0),
    (235, 3, 198.0),
    (236, 3, 215.0),
    (237, 3, 207.0),
    (238, 3, 212.0),
    (239, 3, 182.0),
    (240, 3, 209.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (241, 3, 177.0),
    (242, 3, 165.0),
    (243, 3, 127.0),
    (244, 3, 165.0),
    (245, 3, 166.0),
    (246, 3, 129.0),
    (247, 3, 166.0),
    (248, 3, 165.0),
    (249, 3, 127.0),
    (250, 3, 165.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (251, 3, 167.0),
    (252, 3, 129.0),
    (253, 3, 167.0),
    (254, 3, 186.0),
    (255, 3, 154.0),
    (256, 3, 186.0),
    (257, 3, 187.0),
    (258, 3, 155.0),
    (259, 3, 187.0),
    (260, 3, 186.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (261, 3, 153.0),
    (262, 3, 186.0),
    (263, 3, 188.0),
    (264, 3, 155.0),
    (265, 3, 188.0),
    (266, 3, 172.0),
    (267, 3, 137.0),
    (268, 3, 172.0),
    (269, 3, 173.0),
    (270, 3, 138.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (271, 3, 173.0),
    (272, 3, 174.0),
    (273, 3, 141.0),
    (274, 3, 174.0),
    (275, 3, 173.0),
    (276, 3, 139.0),
    (277, 3, 173.0),
    (278, 3, 199.0),
    (279, 3, 168.0),
    (280, 3, 199.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (281, 3, 199.0),
    (282, 3, 169.0),
    (283, 3, 199.0),
    (284, 3, 190.0),
    (285, 3, 160.0),
    (286, 3, 190.0),
    (287, 3, 200.0),
    (288, 3, 169.0),
    (289, 3, 200.0),
    (290, 3, 172.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (291, 3, 134.0),
    (292, 3, 172.0),
    (293, 3, 27.0),
    (294, 3, 100.0),
    (295, 3, 86.0),
    (296, 3, 107.0),
    (297, 3, 97.0),
    (298, 3, 59.0),
    (299, 3, 100.0),
    (300, 3, 52.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (301, 3, 132.0),
    (302, 3, 119.0),
    (303, 3, 92.0),
    (304, 3, 141.0),
    (305, 3, 121.0),
    (306, 3, 104.0),
    (307, 3, 135.0),
    (308, 3, 324.0),
    (309, 3, 96.0),
    (310, 3, 48.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (311, 3, 128.0),
    (312, 3, 115.0),
    (313, 3, 89.0),
    (314, 3, 138.0),
    (315, 3, 118.0),
    (316, 3, 101.0),
    (317, 3, 132.0),
    (318, 3, 189.0),
    (319, 3, 189.0),
    (320, 3, 139.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (321, 3, 185.0),
    (322, 3, 136.0),
    (323, 3, 206.0),
    (324, 3, 188.0),
    (325, 3, 188.0),
    (326, 3, 138.0),
    (327, 3, 211.0),
    (328, 3, 168.0),
    (329, 3, 211.0),
    (330, 3, 181.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (331, 3, 181.0),
    (332, 3, 131.0),
    (333, 3, 178.0),
    (334, 3, 134.0),
    (335, 3, 178.0),
    (336, 3, 200.0),
    (337, 3, 177.0),
    (338, 3, 161.0),
    (339, 3, 165.0),
    (340, 3, 165.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (341, 3, 197.0),
    (342, 3, 191.0),
    (343, 3, 191.0),
    (344, 3, 142.0),
    (345, 3, 188.0),
    (346, 3, 137.0),
    (347, 3, 188.0),
    (348, 3, 210.0),
    (349, 3, 186.0),
    (350, 3, 177.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (351, 3, 177.0),
    (352, 3, 126.0),
    (353, 3, 186.0),
    (354, 3, 135.0),
    (355, 3, 186.0),
    (356, 3, 195.0),
    (357, 3, 173.0),
    (358, 3, 192.0),
    (359, 3, 218.0),
    (360, 3, 156.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (361, 3, 105.0),
    (362, 3, 94.0),
    (363, 3, 116.0),
    (364, 3, 101.0),
    (365, 3, 142.0),
    (366, 3, 90.0),
    (367, 3, 177.0),
    (368, 3, 99.0),
    (369, 3, 89.0),
    (370, 3, 138.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (371, 3, 105.0),
    (372, 3, 184.0),
    (373, 3, 104.0),
    (374, 3, 166.0),
    (375, 3, 166.0),
    (376, 3, 211.0),
    (377, 3, 211.0),
    (378, 3, 163.0),
    (379, 3, 197.0),
    (380, 3, 146.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (381, 3, 197.0),
    (382, 3, 117.0),
    (383, 3, 168.0),
    (384, 3, 432.0),
    (385, 3, 166.0),
    (386, 3, 166.0),
    (387, 3, 115.0),
    (388, 3, 166.0),
    (389, 3, 145.0),
    (390, 3, 371.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (391, 3, 86.0),
    (392, 3, 469.0),
    (393, 3, 140.0),
    (394, 3, 67.0),
    (395, 3, 47.0),
    (396, 3, 24.0),
    (397, 3, 47.0),
    (398, 3, 84.0),
    (399, 3, 80.0),
    (400, 3, 61.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (401, 3, 43.0),
    (402, 3, 43.0),
    (403, 3, 60.0),
    (404, 3, 78.0),
    (405, 3, 48.0),
    (406, 3, 33.0),
    (407, 3, 224.0),
    (408, 3, 243.0),
    (409, 3, 265.0),
    (410, 3, 88.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (411, 3, 18.0),
    (412, 3, 37.0),
    (413, 3, 171.0),
    (414, 3, 412.0),
    (415, 3, 434.0),
    (416, 3, 465.0),
    (417, 3, 390.0),
    (418, 3, 426.0),
    (419, 3, 425.0),
    (420, 3, 453.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (421, 3, 359.0),
    (422, 3, 344.0),
    (423, 3, 420.0),
    (424, 3, 395.0),
    (425, 3, 510.0),
    (426, 3, 455.0),
    (427, 3, 427.0),
    (428, 3, 443.0),
    (429, 3, 395.0),
    (430, 3, 443.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (431, 3, 443.0),
    (432, 3, 510.0),
    (433, 3, 510.0),
    (434, 3, 510.0),
    (435, 3, 444.0),
    (436, 3, 489.0),
    (437, 3, 489.0),
    (438, 3, 489.0),
    (439, 3, 418.0),
    (440, 3, 503.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (441, 3, 412.0),
    (442, 3, 366.0),
    (443, 3, 412.0),
    (444, 3, 395.0),
    (445, 3, 446.0),
    (446, 3, 392.0),
    (447, 3, 416.0),
    (448, 3, 430.0),
    (449, 3, 384.0),
    (450, 3, 323.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (451, 3, 482.0),
    (452, 3, 494.0),
    (453, 3, 494.0),
    (454, 3, 482.0),
    (455, 3, 437.0),
    (456, 3, 465.0),
    (457, 3, 477.0),
    (458, 3, 479.0),
    (459, 3, 384.0),
    (460, 3, 521.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (461, 3, 441.0),
    (462, 3, 441.0),
    (463, 3, 441.0),
    (464, 3, 416.0),
    (465, 3, 441.0),
    (466, 3, 441.0),
    (467, 3, 441.0),
    (468, 3, 444.0),
    (469, 3, 453.0),
    (470, 3, 453.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (471, 3, 391.0),
    (472, 3, 344.0),
    (473, 3, 344.0),
    (474, 3, 462.0),
    (475, 3, 413.0),
    (476, 3, 457.0),
    (477, 3, 451.0),
    (478, 3, 128.0),
    (479, 3, 137.0),
    (480, 3, 148.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (481, 3, 521.0),
    (482, 3, 84.0),
    (483, 3, 107.0),
    (484, 3, 157.0),
    (485, 3, 148.0),
    (486, 3, 179.0),
    (487, 3, 139.0),
    (488, 3, 118.0),
    (489, 3, 118.0),
    (490, 3, 80.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (491, 3, 110.0),
    (492, 3, 76.0),
    (493, 3, 64.0),
    (494, 3, 76.0),
    (495, 3, 116.0),
    (496, 3, 128.0),
    (497, 3, 95.0),
    (498, 3, 107.0),
    (499, 3, 68.0),
    (500, 3, 88.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (501, 3, 111.0),
    (502, 3, 129.0),
    (503, 3, 94.0),
    (504, 3, 113.0),
    (505, 3, 102.0),
    (506, 3, 119.0),
    (507, 3, 100.0),
    (508, 3, 117.0),
    (509, 3, 85.0),
    (510, 3, 56.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (511, 3, 146.0),
    (512, 3, 120.0),
    (513, 3, 146.0),
    (514, 3, 129.0),
    (515, 3, 129.0),
    (516, 3, 151.0),
    (517, 3, 147.0),
    (518, 3, 142.0),
    (519, 3, 148.0),
    (520, 3, 129.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (521, 3, 123.0),
    (522, 3, 141.0),
    (523, 3, 137.0),
    (524, 3, 134.0),
    (525, 3, 138.0),
    (526, 3, 123.0),
    (527, 3, 144.0),
    (528, 3, 139.0),
    (529, 3, 39.0),
    (530, 3, 88.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (531, 3, 88.0),
    (532, 3, 103.0),
    (533, 3, 96.0),
    (534, 3, 122.0),
    (535, 3, 100.0),
    (536, 3, 122.0),
    (537, 3, 79.0),
    (538, 3, 120.0),
    (539, 3, 112.0),
    (540, 3, 112.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (541, 3, 138.0),
    (542, 3, 112.0),
    (543, 3, 200.0),
    (544, 3, 83.0),
    (545, 3, 121.0),
    (546, 3, 83.0),
    (547, 3, 111.0),
    (548, 3, 376.0),
    (549, 3, 394.0),
    (550, 3, 390.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (551, 3, 388.0),
    (552, 3, 404.0),
    (553, 3, 407.0),
    (554, 3, 392.0),
    (555, 3, 89.0),
    (556, 3, 73.0),
    (557, 3, 76.0),
    (558, 3, 75.0),
    (559, 3, 88.0),
    (560, 3, 89.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (561, 3, 87.0),
    (562, 3, 151.0),
    (563, 3, 112.0),
    (564, 3, 198.0),
    (565, 3, 178.0),
    (566, 3, 166.0),
    (567, 3, 99.0),
    (568, 3, 77.0),
    (569, 3, 120.0),
    (570, 3, 147.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (571, 3, 119.0),
    (572, 3, 146.0),
    (573, 3, 160.0),
    (574, 3, 49.0),
    (575, 3, 90.0),
    (576, 3, 51.0),
    (577, 3, 58.0),
    (578, 3, 42.0),
    (579, 3, 53.0),
    (580, 3, 34.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (581, 3, 73.0),
    (582, 3, 66.0),
    (583, 3, 127.0),
    (584, 3, 137.0),
    (585, 3, 126.0),
    (586, 3, 112.0),
    (587, 3, 108.0),
    (588, 3, 127.0),
    (589, 3, 112.0),
    (590, 3, 33.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (591, 3, 95.0),
    (592, 3, 102.0),
    (593, 3, 53.0),
    (594, 3, 42.0),
    (595, 3, 36.0),
    (596, 3, 71.0),
    (597, 3, 29.0),
    (598, 3, 30.0),
    (599, 3, 50.0),
    (600, 3, 46.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (601, 3, 37.0),
    (602, 3, 55.0),
    (603, 3, 53.0),
    (604, 3, 47.0),
    (605, 3, 68.0),
    (606, 3, 63.0),
    (607, 3, 61.0),
    (608, 3, 75.0),
    (609, 3, 52.0),
    (610, 3, 75.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (611, 3, 100.0),
    (612, 3, 113.0),
    (613, 3, 48.0),
    (614, 3, 57.0),
    (615, 3, 160.0),
    (616, 3, 97.0),
    (617, 3, 161.0),
    (618, 3, 38.0),
    (619, 3, 35.0),
    (620, 3, 31.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (621, 3, 165.0),
    (622, 3, 71.0),
    (623, 3, 74.0),
    (624, 3, 71.0),
    (625, 3, 68.0),
    (626, 3, 74.0),
    (627, 3, 76.0),
    (628, 3, 68.0),
    (629, 3, 64.0),
    (630, 3, 66.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (631, 3, 36.0),
    (632, 3, 60.0),
    (633, 3, 65.0),
    (634, 3, 60.0),
    (635, 3, 43.0),
    (636, 3, 43.0),
    (637, 3, 52.0),
    (638, 3, 97.0),
    (639, 3, 46.0),
    (640, 3, 48.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (641, 3, 54.0),
    (642, 3, 41.0),
    (643, 3, 46.0),
    (644, 3, 59.0),
    (645, 3, 42.0),
    (646, 3, 52.0),
    (647, 3, 59.0),
    (648, 3, 45.0),
    (649, 3, 70.0),
    (650, 3, 46.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (651, 3, 55.0),
    (652, 3, 83.0),
    (653, 3, 73.0),
    (654, 3, 239.0),
    (655, 3, 30.0),
    (656, 3, 44.0),
    (657, 3, 52.0),
    (658, 3, 43.0),
    (659, 3, 64.0),
    (660, 3, 64.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (661, 3, 88.0),
    (662, 3, 51.0),
    (663, 3, 46.0),
    (664, 3, 159.0),
    (665, 3, 57.0),
    (666, 3, 57.0),
    (667, 3, 36.0),
    (668, 3, 92.0),
    (669, 3, 35.0),
    (670, 3, 75.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (671, 3, 59.0),
    (672, 3, 56.0),
    (673, 3, 55.0),
    (674, 3, 62.0),
    (675, 3, 48.0),
    (676, 3, 48.0),
    (677, 3, 180.0),
    (678, 3, 134.0),
    (679, 3, 133.0),
    (680, 3, 247.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (681, 3, 164.0),
    (682, 3, 153.0),
    (683, 3, 251.0),
    (684, 3, 133.0),
    (685, 3, 137.0),
    (686, 3, 240.0),
    (687, 3, 158.0),
    (688, 3, 148.0),
    (689, 3, 244.0),
    (690, 3, 328.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (691, 3, 105.0),
    (692, 3, 30.0),
    (693, 3, 51.0),
    (694, 3, 50.0),
    (695, 3, 46.0),
    (696, 3, 45.0),
    (697, 3, 38.0),
    (698, 3, 42.0),
    (699, 3, 32.0),
    (700, 3, 66.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (701, 3, 62.0),
    (702, 3, 57.0),
    (703, 3, 51.0),
    (704, 3, 53.0),
    (705, 3, 54.0),
    (706, 3, 71.0),
    (707, 3, 23.0),
    (708, 3, 30.0),
    (709, 3, 51.0),
    (710, 3, 56.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (711, 3, 74.0),
    (712, 3, 65.0),
    (713, 3, 48.0),
    (714, 3, 51.0),
    (715, 3, 49.0),
    (716, 3, 57.0),
    (717, 3, 69.0),
    (718, 3, 60.0),
    (719, 3, 59.0),
    (720, 3, 68.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (721, 3, 68.0),
    (722, 3, 68.0),
    (723, 3, 78.0),
    (724, 3, 76.0),
    (725, 3, 59.0),
    (726, 3, 59.0),
    (727, 3, 69.0),
    (728, 3, 69.0),
    (729, 3, 75.0),
    (730, 3, 82.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (731, 3, 41.0),
    (732, 3, 37.0),
    (733, 3, 91.0),
    (734, 3, 91.0),
    (735, 3, 65.0),
    (736, 3, 65.0),
    (737, 3, 42.0),
    (738, 3, 44.0),
    (739, 3, 100.0),
    (740, 3, 60.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (741, 3, 47.0),
    (742, 3, 47.0),
    (743, 3, 62.0),
    (744, 3, 47.0),
    (745, 3, 43.0),
    (746, 3, 47.0),
    (747, 3, 69.0),
    (748, 3, 86.0),
    (749, 3, 380.0),
    (750, 3, 115.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (751, 3, 74.0),
    (752, 3, 74.0),
    (753, 3, 72.0),
    (754, 3, 168.0),
    (755, 3, 206.0),
    (756, 3, 168.0),
    (757, 3, 173.0),
    (758, 3, 169.0),
    (759, 3, 167.0),
    (760, 3, 178.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (761, 3, 183.0),
    (762, 3, 114.0),
    (763, 3, 89.0),
    (764, 3, 81.0),
    (765, 3, 106.0),
    (766, 3, 114.0),
    (767, 3, 145.0),
    (768, 3, 100.0),
    (769, 3, 114.0),
    (770, 3, 138.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (771, 3, 120.0),
    (772, 3, 77.0),
    (773, 3, 117.0),
    (774, 3, 117.0),
    (775, 3, 148.0),
    (776, 3, 103.0),
    (777, 3, 106.0),
    (778, 3, 138.0),
    (779, 3, 94.0),
    (780, 3, 175.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (781, 3, 157.0),
    (782, 3, 111.0),
    (783, 3, 112.0),
    (784, 3, 111.0),
    (785, 3, 142.0),
    (786, 3, 102.0),
    (787, 3, 114.0),
    (788, 3, 94.0),
    (789, 3, 89.0),
    (790, 3, 108.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (791, 3, 178.0),
    (792, 3, 168.0),
    (793, 3, 105.0),
    (794, 3, 107.0),
    (795, 3, 105.0),
    (796, 3, 140.0),
    (797, 3, 95.0),
    (798, 3, 108.0),
    (799, 3, 85.0),
    (800, 3, 81.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (801, 3, 196.0),
    (802, 3, 218.0),
    (803, 3, 103.0),
    (804, 3, 87.0),
    (805, 3, 90.0),
    (806, 3, 109.0),
    (807, 3, 122.0),
    (808, 3, 144.0),
    (809, 3, 122.0),
    (810, 3, 141.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (811, 3, 138.0),
    (812, 3, 191.0),
    (813, 3, 269.0),
    (814, 3, 141.0),
    (815, 3, 166.0),
    (816, 3, 22.0),
    (817, 3, 48.0),
    (818, 3, 22.0),
    (819, 3, 46.0),
    (820, 3, 19.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (821, 3, 44.0),
    (822, 3, 32.0),
    (823, 3, 34.0),
    (824, 3, 36.0),
    (825, 3, 58.0),
    (826, 3, 58.0),
    (827, 3, 58.0),
    (828, 3, 61.0),
    (829, 3, 54.0),
    (830, 3, 61.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (831, 3, 55.0),
    (832, 3, 32.0),
    (833, 3, 58.0),
    (834, 3, 45.0),
    (835, 3, 71.0),
    (836, 3, 37.0),
    (837, 3, 37.0),
    (838, 3, 37.0),
    (839, 3, 58.0),
    (840, 3, 58.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (841, 3, 59.0),
    (842, 3, 41.0),
    (843, 3, 43.0),
    (844, 3, 46.0),
    (845, 3, 44.0),
    (846, 3, 69.0),
    (847, 3, 69.0),
    (848, 3, 66.0),
    (849, 3, 54.0),
    (850, 3, 27.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (851, 3, 29.0),
    (852, 3, 19.0),
    (853, 3, 53.0),
    (854, 3, 53.0),
    (855, 3, 41.0),
    (856, 3, 42.0),
    (857, 3, 27.0),
    (858, 3, 33.0),
    (859, 3, 34.0),
    (860, 3, 23.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (861, 3, 63.0),
    (862, 3, 55.0),
    (863, 3, 59.0),
    (864, 3, 59.0),
    (865, 3, 56.0),
    (866, 3, 45.0),
    (867, 3, 59.0),
    (868, 3, 53.0),
    (869, 3, 49.0),
    (870, 3, 42.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (871, 3, 90.0),
    (872, 3, 128.0),
    (873, 3, 130.0),
    (874, 3, 101.0),
    (875, 3, 89.0),
    (876, 3, 68.0),
    (877, 3, 20.0),
    (878, 3, 29.0),
    (879, 3, 42.0),
    (880, 3, 42.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (881, 3, 51.0),
    (882, 3, 11.0),
    (883, 3, 36.0),
    (884, 3, 56.0),
    (885, 3, 57.0),
    (886, 3, 39.0),
    (887, 3, 77.0),
    (888, 3, 41.0),
    (889, 3, 28.0),
    (890, 3, 63.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (891, 3, 63.0),
    (892, 3, 50.0),
    (893, 3, 67.0),
    (894, 3, 60.0),
    (895, 3, 53.0),
    (896, 3, 47.0),
    (897, 3, 112.0),
    (898, 3, 107.0),
    (899, 3, 223.0),
    (900, 3, 26.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (901, 3, 50.0),
    (902, 3, 82.0),
    (903, 3, 44.0),
    (904, 3, 86.0),
    (905, 3, 50.0),
    (906, 3, 39.0),
    (907, 3, 25.0),
    (908, 3, 76.0),
    (909, 3, 69.0),
    (910, 3, 72.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (911, 3, 72.0),
    (912, 3, 61.0),
    (913, 3, 47.0),
    (914, 3, 64.0),
    (915, 3, 57.0),
    (916, 3, 50.0),
    (917, 3, 44.0),
    (918, 3, 97.0),
    (919, 3, 23.0),
    (920, 3, 45.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (921, 3, 49.0),
    (922, 3, 42.0),
    (923, 3, 67.0),
    (924, 3, 58.0),
    (925, 3, 46.0),
    (926, 3, 89.0),
    (927, 3, 89.0),
    (928, 3, 80.0),
    (929, 3, 68.0),
    (930, 3, 56.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (931, 3, 52.0),
    (932, 3, 26.0),
    (933, 3, 37.0),
    (934, 3, 59.0),
    (935, 3, 78.0),
    (936, 3, 115.0),
    (937, 3, 115.0),
    (938, 3, 82.0),
    (939, 3, 115.0),
    (940, 3, 115.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (941, 3, 82.0),
    (942, 3, 115.0),
    (943, 3, 187.0),
    (944, 3, 124.0),
    (945, 3, 91.0),
    (946, 3, 124.0),
    (947, 3, 99.0),
    (948, 3, 192.0),
    (949, 3, 192.0),
    (950, 3, 156.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (951, 3, 305.0),
    (952, 3, 192.0),
    (953, 3, 191.0),
    (954, 3, 240.0),
    (955, 3, 192.0),
    (956, 3, 72.0),
    (957, 3, 110.0),
    (958, 3, 216.0),
    (959, 3, 40.0),
    (960, 3, 19.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (961, 3, 70.0),
    (962, 3, 34.0),
    (963, 3, 35.0),
    (964, 3, 201.0),
    (965, 3, 199.0),
    (966, 3, 30.0),
    (967, 3, 30.0),
    (968, 3, 23.0),
    (969, 3, 53.0),
    (970, 3, 20.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (971, 3, 30.0),
    (972, 3, 40.0),
    (973, 3, 43.0),
    (974, 3, 31.0),
    (975, 3, 43.0),
    (976, 3, 16.0),
    (977, 3, 25.0),
    (978, 3, 17.0),
    (979, 3, 31.0),
    (980, 3, 86.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (981, 3, 16.0),
    (982, 3, 25.0),
    (983, 3, 38.0),
    (984, 3, 27.0),
    (985, 3, 31.0),
    (986, 3, 81.0),
    (987, 3, 27.0),
    (988, 3, 23.0),
    (989, 3, 31.0),
    (990, 3, 27.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (991, 3, 16.0),
    (992, 3, 37.0),
    (993, 3, 41.0),
    (994, 3, 42.0),
    (995, 3, 19.0),
    (996, 3, 17.0),
    (997, 3, 28.0),
    (998, 3, 84.0),
    (999, 3, 229.0),
    (1000, 3, 48.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1001, 3, 84.0),
    (1002, 3, 93.0),
    (1003, 3, 15.0),
    (1004, 3, 21.0),
    (1005, 3, 18.0),
    (1006, 3, 19.0),
    (1007, 3, 45.0),
    (1008, 3, 45.0),
    (1009, 3, 40.0),
    (1010, 3, 41.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1011, 3, 49.0),
    (1012, 3, 42.0),
    (1013, 3, 44.0),
    (1014, 3, 37.0),
    (1015, 3, 45.0),
    (1016, 3, 38.0),
    (1017, 3, 41.0),
    (1018, 3, 103.0),
    (1019, 3, 123.0),
    (1020, 3, 122.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1021, 3, 78.0),
    (1022, 3, 42.0),
    (1023, 3, 28.0),
    (1024, 3, 24.0),
    (1025, 3, 55.0),
    (1026, 3, 64.0),
    (1027, 3, 50.0),
    (1028, 3, 46.0),
    (1029, 3, 68.0),
    (1030, 3, 61.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1031, 3, 53.0),
    (1032, 3, 47.0),
    (1033, 3, 50.0),
    (1034, 3, 43.0),
    (1035, 3, 22.0),
    (1036, 3, 44.0),
    (1037, 3, 48.0),
    (1038, 3, 41.0),
    (1039, 3, 223.0),
    (1040, 3, 50.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1041, 3, 116.0),
    (1042, 3, 45.0),
    (1043, 3, 31.0),
    (1044, 3, 53.0),
    (1045, 3, 67.0),
    (1046, 3, 53.0),
    (1047, 3, 53.0),
    (1048, 3, 41.0),
    (1049, 3, 123.0),
    (1050, 3, 55.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1051, 3, 45.0),
    (1052, 3, 42.0),
    (1053, 3, 67.0),
    (1054, 3, 67.0),
    (1055, 3, 64.0),
    (1056, 3, 100.0),
    (1057, 3, 16.0),
    (1058, 3, 38.0),
    (1059, 3, 26.0),
    (1060, 3, 19.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1061, 3, 49.0),
    (1062, 3, 49.0),
    (1063, 3, 41.0),
    (1064, 3, 52.0),
    (1065, 3, 46.0),
    (1066, 3, 45.0),
    (1067, 3, 38.0),
    (1068, 3, 42.0),
    (1069, 3, 62.0),
    (1070, 3, 44.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1071, 3, 119.0),
    (1072, 3, 86.0),
    (1073, 3, 81.0),
    (1074, 3, 67.0),
    (1075, 3, 88.0),
    (1076, 3, 106.0),
    (1077, 3, 101.0),
    (1078, 3, 88.0),
    (1079, 3, 109.0),
    (1080, 3, 103.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1081, 3, 105.0),
    (1082, 3, 98.0),
    (1083, 3, 91.0),
    (1084, 3, 85.0),
    (1085, 3, 72.0),
    (1086, 3, 66.0),
    (1087, 3, 88.0),
    (1088, 3, 92.0),
    (1089, 3, 85.0),
    (1090, 3, 45.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1091, 3, 27.0),
    (1092, 3, 51.0),
    (1093, 3, 37.0),
    (1094, 3, 51.0),
    (1095, 3, 87.0),
    (1096, 3, 39.0),
    (1097, 3, 66.0),
    (1098, 3, 66.0),
    (1099, 3, 47.0),
    (1100, 3, 70.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1101, 3, 62.0),
    (1102, 3, 44.0),
    (1103, 3, 35.0),
    (1104, 3, 29.0),
    (1105, 3, 59.0),
    (1106, 3, 59.0),
    (1107, 3, 51.0),
    (1108, 3, 134.0),
    (1109, 3, 92.0),
    (1110, 3, 151.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1111, 3, 150.0),
    (1112, 3, 119.0),
    (1113, 3, 84.0),
    (1114, 3, 78.0),
    (1115, 3, 68.0),
    (1116, 3, 98.0),
    (1117, 3, 106.0),
    (1118, 3, 98.0),
    (1119, 3, 89.0),
    (1120, 3, 109.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1121, 3, 102.0),
    (1122, 3, 102.0),
    (1123, 3, 95.0),
    (1124, 3, 92.0),
    (1125, 3, 86.0),
    (1126, 3, 66.0),
    (1127, 3, 93.0),
    (1128, 3, 97.0),
    (1129, 3, 89.0),
    (1130, 3, 47.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1131, 3, 55.0),
    (1132, 3, 63.0),
    (1133, 3, 89.0),
    (1134, 3, 40.0),
    (1135, 3, 44.0),
    (1136, 3, 52.0),
    (1137, 3, 66.0),
    (1138, 3, 66.0),
    (1139, 3, 73.0),
    (1140, 3, 41.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1141, 3, 63.0),
    (1142, 3, 21.0),
    (1143, 3, 21.0),
    (1144, 3, 47.0),
    (1145, 3, 47.0),
    (1146, 3, 43.0),
    (1147, 3, 35.0),
    (1148, 3, 51.0),
    (1149, 3, 44.0),
    (1150, 3, 46.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1151, 3, 40.0),
    (1152, 3, 49.0),
    (1153, 3, 54.0),
    (1154, 3, 78.0),
    (1155, 3, 36.0),
    (1156, 3, 92.0),
    (1157, 3, 112.0),
    (1158, 3, 37.0),
    (1159, 3, 59.0),
    (1160, 3, 100.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1161, 3, 65.0),
    (1162, 3, 46.0),
    (1163, 3, 86.0),
    (1164, 3, 86.0),
    (1165, 3, 68.0),
    (1166, 3, 89.0),
    (1167, 3, 83.0),
    (1168, 3, 71.0),
    (1169, 3, 64.0),
    (1170, 3, 44.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1171, 3, 68.0),
    (1172, 3, 71.0),
    (1173, 3, 64.0),
    (1174, 3, 79.0),
    (1175, 3, 100.0),
    (1176, 3, 67.0),
    (1177, 3, 97.0),
    (1178, 3, 69.0),
    (1179, 3, 23.0),
    (1180, 3, 46.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1181, 3, 28.0),
    (1182, 3, 50.0),
    (1183, 3, 50.0),
    (1184, 3, 71.0),
    (1185, 3, 60.0),
    (1186, 3, 160.0),
    (1187, 3, 56.0),
    (1188, 3, 218.0),
    (1189, 3, 116.0),
    (1190, 3, 218.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1191, 3, 155.0),
    (1192, 3, 90.0),
    (1193, 3, 288.0),
    (1194, 3, 222.0),
    (1195, 3, 219.0),
    (1196, 3, 352.0),
    (1197, 3, 216.0),
    (1198, 3, 85.0),
    (1199, 3, 83.0),
    (1200, 3, 92.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1201, 3, 125.0),
    (1202, 3, 47.0),
    (1203, 3, 239.0),
    (1204, 3, 125.0),
    (1205, 3, 86.0),
    (1206, 3, 103.0),
    (1207, 3, 54.0),
    (1208, 3, 65.0),
    (1209, 3, 35.0),
    (1210, 3, 111.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1211, 3, 41.0),
    (1212, 3, 46.0),
    (1213, 3, 49.0),
    (1214, 3, 15.0),
    (1215, 3, 14.0),
    (1216, 3, 130.0),
    (1217, 3, 91.0),
    (1218, 3, 41.0),
    (1219, 3, 20.0),
    (1220, 3, 46.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1221, 3, 48.0),
    (1222, 3, 116.0),
    (1223, 3, 145.0),
    (1224, 3, 116.0),
    (1225, 3, 141.0),
    (1226, 3, 282.0),
    (1227, 3, 43.0),
    (1228, 3, 22.0),
    (1229, 3, 26.0),
    (1230, 3, 14.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1231, 3, 213.0),
    (1232, 3, 34.0),
    (1233, 3, 54.0),
    (1234, 3, 46.0),
    (1235, 3, 44.0),
    (1236, 3, 35.0),
    (1237, 3, 20.0),
    (1238, 3, 26.0),
    (1239, 3, 74.0),
    (1240, 3, 108.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1241, 3, 78.0),
    (1242, 3, 37.0),
    (1243, 3, 38.0),
    (1244, 3, 38.0),
    (1245, 3, 27.0),
    (1246, 3, 40.0),
    (1247, 3, 47.0),
    (1248, 3, 44.0),
    (1249, 3, 44.0),
    (1250, 3, 26.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1251, 3, 32.0),
    (1252, 3, 28.0),
    (1253, 3, 24.0),
    (1254, 3, 57.0),
    (1255, 3, 60.0),
    (1256, 3, 24.0),
    (1257, 3, 24.0),
    (1258, 3, 34.0),
    (1259, 3, 44.0),
    (1260, 3, 44.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1261, 3, 58.0),
    (1262, 3, 64.0),
    (1263, 3, 50.0),
    (1264, 3, 50.0),
    (1265, 3, 85.0),
    (1266, 3, 77.0),
    (1267, 3, 83.0),
    (1268, 3, 101.0),
    (1269, 3, 78.0),
    (1270, 3, 185.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1271, 3, 358.0),
    (1272, 3, 46.0),
    (1273, 3, 274.0),
    (1274, 3, 32.0),
    (1275, 3, 33.0),
    (1276, 3, 10.0),
    (1277, 3, 109.0),
    (1278, 3, 44.0),
    (1279, 3, 46.0),
    (1280, 3, 25.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1281, 3, 196.0),
    (1282, 3, 64.0),
    (1283, 3, 128.0),
    (1284, 3, 87.0),
    (1285, 3, 28.0),
    (1286, 3, 27.0),
    (1287, 3, 54.0),
    (1288, 3, 46.0),
    (1289, 3, 29.0),
    (1290, 3, 54.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1291, 3, 25.0),
    (1292, 3, 41.0),
    (1293, 3, 19.0),
    (1294, 3, 39.0),
    (1295, 3, 1.0),
    (1296, 3, 19.0),
    (1297, 3, 23.0),
    (1298, 3, 21.0),
    (1299, 3, 22.0),
    (1300, 3, 21.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1301, 3, 27.0),
    (1302, 3, 4.0),
    (1303, 3, 39.0),
    (1304, 3, 53.0),
    (1305, 3, 74.0),
    (1306, 3, 6.0),
    (1307, 3, 37.0),
    (1308, 3, 56.0),
    (1309, 3, 0.0),
    (1310, 3, 62.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1, 4, 0.0),
    (2, 4, 0.0),
    (3, 4, 0.0),
    (4, 4, 0.0),
    (5, 4, 0.0),
    (6, 4, 0.0),
    (7, 4, 0.0),
    (8, 4, 0.0),
    (9, 4, 0.0),
    (10, 4, 0.01);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (11, 4, 0.04),
    (12, 4, 0.05),
    (13, 4, 0.03),
    (14, 4, 0.07),
    (15, 4, 0.19),
    (16, 4, 0.19),
    (17, 4, 0.28),
    (18, 4, 0.29),
    (19, 4, 0.07),
    (20, 4, 0.12);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (21, 4, 0.14),
    (22, 4, 0.08),
    (23, 4, 0.0),
    (24, 4, 0.08),
    (25, 4, 0.0),
    (26, 4, 0.07),
    (27, 4, 0.0),
    (28, 4, 0.07),
    (29, 4, 0.07),
    (30, 4, 0.14);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (31, 4, 0.07),
    (32, 4, 0.14),
    (33, 4, 0.0),
    (34, 4, 0.12),
    (35, 4, 0.05),
    (36, 4, 0.12),
    (37, 4, 0.12),
    (38, 4, 0.07),
    (39, 4, 0.0),
    (40, 4, 0.07);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (41, 4, 0.0),
    (42, 4, 0.06),
    (43, 4, 0.0),
    (44, 4, 0.06),
    (45, 4, 0.06),
    (46, 4, 0.66),
    (47, 4, 0.11),
    (48, 4, 0.1),
    (49, 4, 0.43),
    (50, 4, 0.62);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (51, 4, 0.0),
    (52, 4, 0.05),
    (53, 4, 1.19),
    (54, 4, 1.18),
    (55, 4, 1.18),
    (56, 4, 1.18),
    (57, 4, 1.19),
    (58, 4, 1.19),
    (59, 4, 1.19),
    (60, 4, 1.19);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (61, 4, 1.17),
    (62, 4, 1.17),
    (63, 4, 1.17),
    (64, 4, 1.17),
    (65, 4, 1.17),
    (66, 4, 1.17),
    (67, 4, 1.15),
    (68, 4, 1.19),
    (69, 4, 1.19),
    (70, 4, 1.19);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (71, 4, 1.19),
    (72, 4, 1.19),
    (73, 4, 1.18),
    (74, 4, 1.18),
    (75, 4, 1.19),
    (76, 4, 1.19),
    (77, 4, 1.19),
    (78, 4, 1.19),
    (79, 4, 0.98),
    (80, 4, 1.34);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (81, 4, 1.06),
    (82, 4, 1.06),
    (83, 4, 1.34),
    (84, 4, 1.03),
    (85, 4, 0.99),
    (86, 4, 0.99),
    (87, 4, 0.99),
    (88, 4, 0.99),
    (89, 4, 0.99),
    (90, 4, 1.06);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (91, 4, 1.25),
    (92, 4, 1.25),
    (93, 4, 1.19),
    (94, 4, 1.19),
    (95, 4, 1.19),
    (96, 4, 1.19),
    (97, 4, 1.19),
    (98, 4, 1.18),
    (99, 4, 1.18),
    (100, 4, 1.23);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (101, 4, 1.23),
    (102, 4, 1.23),
    (103, 4, 1.23),
    (104, 4, 1.16),
    (105, 4, 1.16),
    (106, 4, 1.16),
    (107, 4, 1.16),
    (108, 4, 1.18),
    (109, 4, 1.15),
    (110, 4, 1.15);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (111, 4, 1.15),
    (112, 4, 1.15),
    (113, 4, 1.2),
    (114, 4, 1.18),
    (115, 4, 1.18),
    (116, 4, 1.16),
    (117, 4, 1.16),
    (118, 4, 1.16),
    (119, 4, 0.44),
    (120, 4, 1.27);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (121, 4, 0.97),
    (122, 4, 0.09),
    (123, 4, 0.3),
    (124, 4, 0.49),
    (125, 4, 0.16),
    (126, 4, 0.11),
    (127, 4, 0.51),
    (128, 4, 0.11),
    (129, 4, 0.0),
    (130, 4, 0.24);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (131, 4, 0.02),
    (132, 4, 0.24),
    (133, 4, 0.09),
    (134, 4, 0.02),
    (135, 4, 1.27),
    (136, 4, 0.24),
    (137, 4, 0.11),
    (138, 4, 0.42),
    (139, 4, 0.52),
    (140, 4, 0.17);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (141, 4, 0.22),
    (142, 4, 0.83),
    (143, 4, 0.76),
    (144, 4, 1.1),
    (145, 4, 0.98),
    (146, 4, 1.03),
    (147, 4, 0.92),
    (148, 4, 1.4),
    (149, 4, 0.7),
    (150, 4, 1.1);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (151, 4, 0.54),
    (152, 4, 0.58),
    (153, 4, 0.27),
    (154, 4, 0.43),
    (155, 4, 0.25),
    (156, 4, 0.65),
    (157, 4, 0.26),
    (158, 4, 0.68),
    (159, 4, 0.32),
    (160, 4, 0.12);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (161, 4, 0.16),
    (162, 4, 0.23),
    (163, 4, 0.31),
    (164, 4, 0.64),
    (165, 4, 0.4),
    (166, 4, 0.52),
    (167, 4, 0.48),
    (168, 4, 0.56),
    (169, 4, 0.17),
    (170, 4, 1.67);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (171, 4, 1.6),
    (172, 4, 1.67),
    (173, 4, 1.56),
    (174, 4, 1.66),
    (175, 4, 1.56),
    (176, 4, 1.57),
    (177, 4, 1.56),
    (178, 4, 1.57),
    (179, 4, 1.65),
    (180, 4, 1.56);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (181, 4, 1.57),
    (182, 4, 1.56),
    (183, 4, 1.66),
    (184, 4, 1.56),
    (185, 4, 1.18),
    (186, 4, 0.08),
    (187, 4, 0.08),
    (188, 4, 0.08),
    (189, 4, 0.08),
    (190, 4, 2.73);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (191, 4, 2.55),
    (192, 4, 2.72),
    (193, 4, 2.55),
    (194, 4, 3.6),
    (195, 4, 3.4),
    (196, 4, 3.64),
    (197, 4, 0.72),
    (198, 4, 1.56),
    (199, 4, 1.1),
    (200, 4, 0.99);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (201, 4, 0.96),
    (202, 4, 0.96),
    (203, 4, 0.96),
    (204, 4, 1.0),
    (205, 4, 0.96),
    (206, 4, 0.99),
    (207, 4, 0.99),
    (208, 4, 0.95),
    (209, 4, 1.08),
    (210, 4, 1.15);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (211, 4, 1.56),
    (212, 4, 1.56),
    (213, 4, 1.57),
    (214, 4, 1.56),
    (215, 4, 1.57),
    (216, 4, 1.65),
    (217, 4, 1.56),
    (218, 4, 1.66),
    (219, 4, 1.57),
    (220, 4, 1.42);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (221, 4, 1.43),
    (222, 4, 1.42),
    (223, 4, 1.43),
    (224, 4, 1.49),
    (225, 4, 1.51),
    (226, 4, 1.51),
    (227, 4, 1.51),
    (228, 4, 1.52),
    (229, 4, 1.51),
    (230, 4, 1.52);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (231, 4, 1.58),
    (232, 4, 1.51),
    (233, 4, 1.6),
    (234, 4, 1.4),
    (235, 4, 1.4),
    (236, 4, 1.41),
    (237, 4, 1.4),
    (238, 4, 1.41),
    (239, 4, 1.46),
    (240, 4, 1.4);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (241, 4, 1.48),
    (242, 4, 1.41),
    (243, 4, 1.49),
    (244, 4, 1.41),
    (245, 4, 1.5),
    (246, 4, 1.58),
    (247, 4, 1.5),
    (248, 4, 1.45),
    (249, 4, 1.53),
    (250, 4, 1.45);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (251, 4, 1.4),
    (252, 4, 1.48),
    (253, 4, 1.4),
    (254, 4, 1.3),
    (255, 4, 1.37),
    (256, 4, 1.3),
    (257, 4, 1.38),
    (258, 4, 1.45),
    (259, 4, 1.38),
    (260, 4, 1.34);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (261, 4, 1.4),
    (262, 4, 1.34),
    (263, 4, 1.3),
    (264, 4, 1.36),
    (265, 4, 1.3),
    (266, 4, 1.39),
    (267, 4, 1.46),
    (268, 4, 1.39),
    (269, 4, 1.47),
    (270, 4, 1.54);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (271, 4, 1.47),
    (272, 4, 1.41),
    (273, 4, 1.48),
    (274, 4, 1.41),
    (275, 4, 1.39),
    (276, 4, 1.46),
    (277, 4, 1.39),
    (278, 4, 1.34),
    (279, 4, 1.41),
    (280, 4, 1.34);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (281, 4, 1.38),
    (282, 4, 1.45),
    (283, 4, 1.38),
    (284, 4, 1.32),
    (285, 4, 1.38),
    (286, 4, 1.32),
    (287, 4, 1.34),
    (288, 4, 1.4),
    (289, 4, 1.34),
    (290, 4, 1.47);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (291, 4, 1.55),
    (292, 4, 1.47),
    (293, 4, 0.26),
    (294, 4, 0.08),
    (295, 4, 0.08),
    (296, 4, 0.08),
    (297, 4, 0.08),
    (298, 4, 0.08),
    (299, 4, 0.08),
    (300, 4, 0.08);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (301, 4, 0.12),
    (302, 4, 0.21),
    (303, 4, 0.2),
    (304, 4, 0.2),
    (305, 4, 0.22),
    (306, 4, 0.27),
    (307, 4, 0.25),
    (308, 4, 0.1),
    (309, 4, 1.85),
    (310, 4, 1.97);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (311, 4, 1.68),
    (312, 4, 1.76),
    (313, 4, 1.75),
    (314, 4, 1.64),
    (315, 4, 1.61),
    (316, 4, 1.7),
    (317, 4, 1.6),
    (318, 4, 1.96),
    (319, 4, 1.96),
    (320, 4, 2.08);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (321, 4, 2.45),
    (322, 4, 2.53),
    (323, 4, 3.35),
    (324, 4, 3.45),
    (325, 4, 3.45),
    (326, 4, 3.68),
    (327, 4, 2.23),
    (328, 4, 2.31),
    (329, 4, 2.23),
    (330, 4, 1.96);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (331, 4, 1.96),
    (332, 4, 2.09),
    (333, 4, 2.7),
    (334, 4, 2.79),
    (335, 4, 2.7),
    (336, 4, 1.91),
    (337, 4, 1.95),
    (338, 4, 1.4),
    (339, 4, 2.23),
    (340, 4, 2.23);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (341, 4, 2.15),
    (342, 4, 1.95),
    (343, 4, 1.95),
    (344, 4, 2.08),
    (345, 4, 2.37),
    (346, 4, 2.45),
    (347, 4, 2.37),
    (348, 4, 1.9),
    (349, 4, 1.94),
    (350, 4, 2.74);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (351, 4, 2.74),
    (352, 4, 2.92),
    (353, 4, 2.02),
    (354, 4, 2.08),
    (355, 4, 2.02),
    (356, 4, 2.66),
    (357, 4, 2.62),
    (358, 4, 2.32),
    (359, 4, 4.79),
    (360, 4, 1.31);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (361, 4, 1.4),
    (362, 4, 1.19),
    (363, 4, 1.36),
    (364, 4, 1.71),
    (365, 4, 1.63),
    (366, 4, 1.44),
    (367, 4, 1.58),
    (368, 4, 1.5),
    (369, 4, 1.44),
    (370, 4, 1.36);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (371, 4, 1.4),
    (372, 4, 1.95),
    (373, 4, 0.29),
    (374, 4, 2.34),
    (375, 4, 2.34),
    (376, 4, 2.7),
    (377, 4, 2.7),
    (378, 4, 2.87),
    (379, 4, 1.98),
    (380, 4, 2.05);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (381, 4, 1.98),
    (382, 4, 1.28),
    (383, 4, 1.21),
    (384, 4, 3.8),
    (385, 4, 3.1),
    (386, 4, 3.1),
    (387, 4, 3.31),
    (388, 4, 3.1),
    (389, 4, 3.17),
    (390, 4, 7.8);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (391, 4, 1.67),
    (392, 4, 3.9),
    (393, 4, 2.2),
    (394, 4, 0.87),
    (395, 4, 0.56),
    (396, 4, 0.47),
    (397, 4, 0.56),
    (398, 4, 1.01),
    (399, 4, 0.65),
    (400, 4, 0.55);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (401, 4, 0.86),
    (402, 4, 0.87),
    (403, 4, 1.36),
    (404, 4, 1.43),
    (405, 4, 0.59),
    (406, 4, 0.22),
    (407, 4, 2.88),
    (408, 4, 2.54),
    (409, 4, 1.55),
    (410, 4, 0.41);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (411, 4, 0.03),
    (412, 4, 0.03),
    (413, 4, 1.58),
    (414, 4, 4.28),
    (415, 4, 5.33),
    (416, 4, 2.82),
    (417, 4, 3.7),
    (418, 4, 0.6),
    (419, 4, 4.63),
    (420, 4, 2.83);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (421, 4, 20.42),
    (422, 4, 13.16),
    (423, 4, 11.52),
    (424, 4, 4.72),
    (425, 4, 4.03),
    (426, 4, 2.64),
    (427, 4, 3.94),
    (428, 4, 3.08),
    (429, 4, 3.16),
    (430, 4, 3.08);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (431, 4, 3.08),
    (432, 4, 4.03),
    (433, 4, 4.03),
    (434, 4, 4.03),
    (435, 4, 5.02),
    (436, 4, 4.88),
    (437, 4, 4.88),
    (438, 4, 4.88),
    (439, 4, 4.8),
    (440, 4, 4.77);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (441, 4, 3.46),
    (442, 4, 2.43),
    (443, 4, 3.51),
    (444, 4, 3.16),
    (445, 4, 3.58),
    (446, 4, 1.49),
    (447, 4, 0.0),
    (448, 4, 0.29),
    (449, 4, 1.87),
    (450, 4, 0.27);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (451, 4, 2.59),
    (452, 4, 2.77),
    (453, 4, 2.77),
    (454, 4, 2.7),
    (455, 4, 3.0),
    (456, 4, 3.07),
    (457, 4, 2.39),
    (458, 4, 2.65),
    (459, 4, 0.0),
    (460, 4, 1.76);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (461, 4, 2.99),
    (462, 4, 2.99),
    (463, 4, 2.99),
    (464, 4, 3.56),
    (465, 4, 2.99),
    (466, 4, 2.99),
    (467, 4, 2.99),
    (468, 4, 5.02),
    (469, 4, 2.83),
    (470, 4, 2.83);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (471, 4, 0.0),
    (472, 4, 24.74),
    (473, 4, 24.74),
    (474, 4, 14.45),
    (475, 4, 1.28),
    (476, 4, 4.59),
    (477, 4, 5.05),
    (478, 4, 0.49),
    (479, 4, 1.46),
    (480, 4, 1.71);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (481, 4, 1.76),
    (482, 4, 0.44),
    (483, 4, 0.14),
    (484, 4, 1.27),
    (485, 4, 1.71),
    (486, 4, 0.22),
    (487, 4, 1.28),
    (488, 4, 0.76),
    (489, 4, 0.63),
    (490, 4, 0.68);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (491, 4, 0.7),
    (492, 4, 0.67),
    (493, 4, 0.68),
    (494, 4, 0.67),
    (495, 4, 0.68),
    (496, 4, 0.67),
    (497, 4, 1.0),
    (498, 4, 0.98),
    (499, 4, 4.68),
    (500, 4, 4.53);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (501, 4, 4.68),
    (502, 4, 4.53),
    (503, 4, 4.93),
    (504, 4, 4.78),
    (505, 4, 2.73),
    (506, 4, 2.65),
    (507, 4, 2.62),
    (508, 4, 2.55),
    (509, 4, 3.73),
    (510, 4, 0.46);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (511, 4, 1.42),
    (512, 4, 1.48),
    (513, 4, 1.42),
    (514, 4, 1.19),
    (515, 4, 1.19),
    (516, 4, 1.16),
    (517, 4, 1.16),
    (518, 4, 1.16),
    (519, 4, 1.16),
    (520, 4, 1.19);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (521, 4, 0.4),
    (522, 4, 0.39),
    (523, 4, 0.39),
    (524, 4, 0.39),
    (525, 4, 0.39),
    (526, 4, 0.4),
    (527, 4, 1.03),
    (528, 4, 1.14),
    (529, 4, 0.36),
    (530, 4, 0.62);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (531, 4, 0.62),
    (532, 4, 0.6),
    (533, 4, 0.14),
    (534, 4, 0.58),
    (535, 4, 0.6),
    (536, 4, 0.58),
    (537, 4, 0.81),
    (538, 4, 0.56),
    (539, 4, 0.98),
    (540, 4, 0.98);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (541, 4, 0.55),
    (542, 4, 0.34),
    (543, 4, 1.64),
    (544, 4, 0.96),
    (545, 4, 0.9),
    (546, 4, 0.96),
    (547, 4, 0.38),
    (548, 4, 48.21),
    (549, 4, 64.1),
    (550, 4, 53.01);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (551, 4, 50.42),
    (552, 4, 28.56),
    (553, 4, 30.0),
    (554, 4, 60.95),
    (555, 4, 2.29),
    (556, 4, 2.16),
    (557, 4, 3.24),
    (558, 4, 1.56),
    (559, 4, 1.14),
    (560, 4, 2.29);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (561, 4, 1.54),
    (562, 4, 1.35),
    (563, 4, 0.74),
    (564, 4, 0.79),
    (565, 4, 0.93),
    (566, 4, 0.54),
    (567, 4, 0.83),
    (568, 4, 0.6),
    (569, 4, 1.74),
    (570, 4, 1.59);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (571, 4, 1.67),
    (572, 4, 1.53),
    (573, 4, 1.68),
    (574, 4, 0.66),
    (575, 4, 0.68),
    (576, 4, 0.35),
    (577, 4, 0.53),
    (578, 4, 0.32),
    (579, 4, 0.38),
    (580, 4, 0.16);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (581, 4, 0.6),
    (582, 4, 0.62),
    (583, 4, 0.98),
    (584, 4, 1.1),
    (585, 4, 0.85),
    (586, 4, 0.77),
    (587, 4, 0.9),
    (588, 4, 0.98),
    (589, 4, 0.97),
    (590, 4, 0.24);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (591, 4, 0.77),
    (592, 4, 0.39),
    (593, 4, 0.15),
    (594, 4, 0.08),
    (595, 4, 0.41),
    (596, 4, 0.86),
    (597, 4, 0.6),
    (598, 4, 0.6),
    (599, 4, 0.22),
    (600, 4, 0.26);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (601, 4, 0.27),
    (602, 4, 0.26),
    (603, 4, 0.15),
    (604, 4, 0.06),
    (605, 4, 0.12),
    (606, 4, 0.17),
    (607, 4, 0.03),
    (608, 4, 0.04),
    (609, 4, 0.04),
    (610, 4, 0.04);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (611, 4, 0.29),
    (612, 4, 0.19),
    (613, 4, 0.39),
    (614, 4, 0.3),
    (615, 4, 0.55),
    (616, 4, 0.0),
    (617, 4, 0.06),
    (618, 4, 0.38),
    (619, 4, 0.26),
    (620, 4, 0.08);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (621, 4, 0.43),
    (622, 4, 0.11),
    (623, 4, 0.34),
    (624, 4, 0.11),
    (625, 4, 0.12),
    (626, 4, 0.37),
    (627, 4, 0.28),
    (628, 4, 0.26),
    (629, 4, 0.24),
    (630, 4, 0.31);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (631, 4, 0.17),
    (632, 4, 0.16),
    (633, 4, 0.12),
    (634, 4, 0.16),
    (635, 4, 0.3),
    (636, 4, 0.25),
    (637, 4, 0.19),
    (638, 4, 1.6),
    (639, 4, 0.34),
    (640, 4, 0.34);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (641, 4, 0.3),
    (642, 4, 0.39),
    (643, 4, 0.34),
    (644, 4, 0.18),
    (645, 4, 0.0),
    (646, 4, 0.25),
    (647, 4, 0.2),
    (648, 4, 0.29),
    (649, 4, 0.15),
    (650, 4, 0.17);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (651, 4, 0.13),
    (652, 4, 0.3),
    (653, 4, 0.2),
    (654, 4, 2.8),
    (655, 4, 0.24),
    (656, 4, 0.28),
    (657, 4, 0.55),
    (658, 4, 0.62),
    (659, 4, 0.8),
    (660, 4, 0.34);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (661, 4, 0.43),
    (662, 4, 0.18),
    (663, 4, 0.23),
    (664, 4, 0.41),
    (665, 4, 0.45),
    (666, 4, 0.45),
    (667, 4, 0.26),
    (668, 4, 0.49),
    (669, 4, 0.75),
    (670, 4, 0.12);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (671, 4, 0.18),
    (672, 4, 0.16),
    (673, 4, 0.28),
    (674, 4, 0.23),
    (675, 4, 0.33),
    (676, 4, 0.34),
    (677, 4, 0.28),
    (678, 4, 0.12),
    (679, 4, 0.88),
    (680, 4, 0.28);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (681, 4, 0.26),
    (682, 4, 0.28),
    (683, 4, 0.28),
    (684, 4, 0.26),
    (685, 4, 0.25),
    (686, 4, 0.28),
    (687, 4, 0.27),
    (688, 4, 0.29),
    (689, 4, 0.28),
    (690, 4, 1.34);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (691, 4, 0.06),
    (692, 4, 0.24),
    (693, 4, 0.08),
    (694, 4, 0.11),
    (695, 4, 0.12),
    (696, 4, 0.08),
    (697, 4, 0.48),
    (698, 4, 0.22),
    (699, 4, 0.13),
    (700, 4, 0.08);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (701, 4, 0.25),
    (702, 4, 0.34),
    (703, 4, 0.24),
    (704, 4, 0.31),
    (705, 4, 0.1),
    (706, 4, 1.18),
    (707, 4, 0.17),
    (708, 4, 0.24),
    (709, 4, 0.36),
    (710, 4, 0.1);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (711, 4, 0.0),
    (712, 4, 0.16),
    (713, 4, 0.54),
    (714, 4, 0.36),
    (715, 4, 0.07),
    (716, 4, 0.34),
    (717, 4, 0.1),
    (718, 4, 0.26),
    (719, 4, 0.36),
    (720, 4, 0.26);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (721, 4, 0.26),
    (722, 4, 0.26),
    (723, 4, 0.4),
    (724, 4, 0.17),
    (725, 4, 0.35),
    (726, 4, 0.35),
    (727, 4, 0.79),
    (728, 4, 0.23),
    (729, 4, 0.86),
    (730, 4, 0.48);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (731, 4, 0.22),
    (732, 4, 0.22),
    (733, 4, 0.3),
    (734, 4, 0.3),
    (735, 4, 0.23),
    (736, 4, 0.23),
    (737, 4, 0.24),
    (738, 4, 0.25),
    (739, 4, 0.4),
    (740, 4, 0.16);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (741, 4, 0.57),
    (742, 4, 0.57),
    (743, 4, 0.3),
    (744, 4, 0.57),
    (745, 4, 0.0),
    (746, 4, 0.3),
    (747, 4, 0.22),
    (748, 4, 0.22),
    (749, 4, 0.0),
    (750, 4, 0.38);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (751, 4, 0.45),
    (752, 4, 0.45),
    (753, 4, 0.23),
    (754, 4, 0.29),
    (755, 4, 0.33),
    (756, 4, 0.29),
    (757, 4, 0.31),
    (758, 4, 0.32),
    (759, 4, 0.34),
    (760, 4, 0.32);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (761, 4, 0.33),
    (762, 4, 0.28),
    (763, 4, 0.31),
    (764, 4, 0.27),
    (765, 4, 0.27),
    (766, 4, 0.28),
    (767, 4, 0.27),
    (768, 4, 0.24),
    (769, 4, 0.28),
    (770, 4, 0.27);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (771, 4, 0.24),
    (772, 4, 0.18),
    (773, 4, 0.19),
    (774, 4, 0.19),
    (775, 4, 0.18),
    (776, 4, 0.17),
    (777, 4, 0.27),
    (778, 4, 0.26),
    (779, 4, 0.23),
    (780, 4, 0.44);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (781, 4, 0.5),
    (782, 4, 0.39),
    (783, 4, 0.39),
    (784, 4, 0.39),
    (785, 4, 0.4),
    (786, 4, 0.38),
    (787, 4, 0.4),
    (788, 4, 0.4),
    (789, 4, 0.39),
    (790, 4, 0.89);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (791, 4, 0.34),
    (792, 4, 0.3),
    (793, 4, 0.29),
    (794, 4, 0.28),
    (795, 4, 0.29),
    (796, 4, 0.3),
    (797, 4, 0.27),
    (798, 4, 0.29),
    (799, 4, 0.29),
    (800, 4, 0.28);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (801, 4, 1.3),
    (802, 4, 1.75),
    (803, 4, 0.38),
    (804, 4, 0.36),
    (805, 4, 0.34),
    (806, 4, 0.48),
    (807, 4, 0.55),
    (808, 4, 0.54),
    (809, 4, 0.55),
    (810, 4, 0.54);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (811, 4, 0.53),
    (812, 4, 0.28),
    (813, 4, 0.27),
    (814, 4, 0.58),
    (815, 4, 0.43),
    (816, 4, 2.57),
    (817, 4, 2.68),
    (818, 4, 2.14),
    (819, 4, 2.16),
    (820, 4, 1.8);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (821, 4, 1.88),
    (822, 4, 0.47),
    (823, 4, 0.5),
    (824, 4, 1.12),
    (825, 4, 0.49),
    (826, 4, 0.49),
    (827, 4, 1.09),
    (828, 4, 0.49),
    (829, 4, 0.49),
    (830, 4, 1.09);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (831, 4, 1.08),
    (832, 4, 1.3),
    (833, 4, 1.36),
    (834, 4, 3.1),
    (835, 4, 3.23),
    (836, 4, 0.7),
    (837, 4, 1.14),
    (838, 4, 1.09),
    (839, 4, 1.12),
    (840, 4, 1.12);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (841, 4, 1.06),
    (842, 4, 1.46),
    (843, 4, 1.6),
    (844, 4, 1.72),
    (845, 4, 0.84),
    (846, 4, 1.67),
    (847, 4, 1.67),
    (848, 4, 0.82),
    (849, 4, 0.68),
    (850, 4, 1.64);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (851, 4, 1.76),
    (852, 4, 1.12),
    (853, 4, 1.71),
    (854, 4, 1.71),
    (855, 4, 1.09),
    (856, 4, 1.16),
    (857, 4, 1.26),
    (858, 4, 1.23),
    (859, 4, 1.95),
    (860, 4, 2.3);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (861, 4, 1.2),
    (862, 4, 1.2),
    (863, 4, 1.2),
    (864, 4, 1.2),
    (865, 4, 1.9),
    (866, 4, 2.24),
    (867, 4, 1.9),
    (868, 4, 1.9),
    (869, 4, 2.24),
    (870, 4, 2.23);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (871, 4, 0.76),
    (872, 4, 1.01),
    (873, 4, 1.74),
    (874, 4, 0.55),
    (875, 4, 1.58),
    (876, 4, 2.35),
    (877, 4, 0.8),
    (878, 4, 1.93),
    (879, 4, 0.78),
    (880, 4, 0.78);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (881, 4, 1.88),
    (882, 4, 0.2),
    (883, 4, 0.21),
    (884, 4, 0.99),
    (885, 4, 0.61),
    (886, 4, 0.69),
    (887, 4, 0.69),
    (888, 4, 0.72),
    (889, 4, 0.61),
    (890, 4, 0.7);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (891, 4, 0.7),
    (892, 4, 0.59),
    (893, 4, 0.7),
    (894, 4, 0.7),
    (895, 4, 0.6),
    (896, 4, 0.59),
    (897, 4, 1.07),
    (898, 4, 0.91),
    (899, 4, 1.78),
    (900, 4, 0.59);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (901, 4, 0.6),
    (902, 4, 0.49),
    (903, 4, 0.12),
    (904, 4, 0.15),
    (905, 4, 0.16),
    (906, 4, 0.43),
    (907, 4, 0.64),
    (908, 4, 0.16),
    (909, 4, 0.15),
    (910, 4, 0.15);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (911, 4, 0.15),
    (912, 4, 0.42),
    (913, 4, 0.62),
    (914, 4, 0.42),
    (915, 4, 0.42),
    (916, 4, 0.63),
    (917, 4, 0.62),
    (918, 4, 0.2),
    (919, 4, 0.52),
    (920, 4, 0.51);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (921, 4, 0.51),
    (922, 4, 0.51),
    (923, 4, 0.84),
    (924, 4, 0.97),
    (925, 4, 0.91),
    (926, 4, 0.82),
    (927, 4, 0.82),
    (928, 4, 0.95),
    (929, 4, 0.89),
    (930, 4, 1.35);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (931, 4, 0.84),
    (932, 4, 0.8),
    (933, 4, 0.44),
    (934, 4, 0.43),
    (935, 4, 0.79),
    (936, 4, 0.4),
    (937, 4, 0.4),
    (938, 4, 0.42),
    (939, 4, 0.4),
    (940, 4, 0.4);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (941, 4, 0.42),
    (942, 4, 0.4),
    (943, 4, 0.31),
    (944, 4, 0.85),
    (945, 4, 0.89),
    (946, 4, 0.85),
    (947, 4, 0.34),
    (948, 4, 0.81),
    (949, 4, 0.81),
    (950, 4, 0.39);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (951, 4, 0.69),
    (952, 4, 0.81),
    (953, 4, 0.81),
    (954, 4, 0.76),
    (955, 4, 0.81),
    (956, 4, 0.74),
    (957, 4, 0.89),
    (958, 4, 1.64),
    (959, 4, 0.43),
    (960, 4, 0.44);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (961, 4, 0.6),
    (962, 4, 0.44),
    (963, 4, 0.44),
    (964, 4, 1.81),
    (965, 4, 1.71),
    (966, 4, 0.26),
    (967, 4, 0.91),
    (968, 4, 0.96),
    (969, 4, 0.61),
    (970, 4, 2.14);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (971, 4, 0.91),
    (972, 4, 0.65),
    (973, 4, 0.8),
    (974, 4, 0.73),
    (975, 4, 1.4),
    (976, 4, 0.59),
    (977, 4, 0.42),
    (978, 4, 0.0),
    (979, 4, 0.73),
    (980, 4, 0.52);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (981, 4, 0.0),
    (982, 4, 0.23),
    (983, 4, 0.6),
    (984, 4, 0.4),
    (985, 4, 0.23),
    (986, 4, 1.47),
    (987, 4, 0.27),
    (988, 4, 0.19),
    (989, 4, 0.35),
    (990, 4, 0.46);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (991, 4, 0.34),
    (992, 4, 0.44),
    (993, 4, 2.28),
    (994, 4, 2.08),
    (995, 4, 0.44),
    (996, 4, 0.37),
    (997, 4, 0.3),
    (998, 4, 0.33),
    (999, 4, 0.43),
    (1000, 4, 0.9);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1001, 4, 1.22),
    (1002, 4, 0.45),
    (1003, 4, 0.15),
    (1004, 4, 2.29),
    (1005, 4, 0.56),
    (1006, 4, 1.83),
    (1007, 4, 2.23),
    (1008, 4, 2.23),
    (1009, 4, 0.55),
    (1010, 4, 1.78);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1011, 4, 2.23),
    (1012, 4, 2.23),
    (1013, 4, 0.55),
    (1014, 4, 0.54),
    (1015, 4, 1.78),
    (1016, 4, 1.78),
    (1017, 4, 0.31),
    (1018, 4, 1.82),
    (1019, 4, 1.76),
    (1020, 4, 1.76);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1021, 4, 0.65),
    (1022, 4, 0.68),
    (1023, 4, 0.66),
    (1024, 4, 0.78),
    (1025, 4, 0.71),
    (1026, 4, 0.66),
    (1027, 4, 0.64),
    (1028, 4, 0.76),
    (1029, 4, 0.66),
    (1030, 4, 0.66);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1031, 4, 0.64),
    (1032, 4, 0.64),
    (1033, 4, 0.76),
    (1034, 4, 0.76),
    (1035, 4, 1.06),
    (1036, 4, 1.03),
    (1037, 4, 1.03),
    (1038, 4, 1.03),
    (1039, 4, 1.76),
    (1040, 4, 0.86);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1041, 4, 2.8),
    (1042, 4, 0.83),
    (1043, 4, 1.82),
    (1044, 4, 1.77),
    (1045, 4, 0.81),
    (1046, 4, 1.77),
    (1047, 4, 0.65),
    (1048, 4, 0.37),
    (1049, 4, 0.53),
    (1050, 4, 0.74);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1051, 4, 1.45),
    (1052, 4, 0.48),
    (1053, 4, 1.42),
    (1054, 4, 1.42),
    (1055, 4, 0.47),
    (1056, 4, 0.84),
    (1057, 4, 0.59),
    (1058, 4, 0.57),
    (1059, 4, 0.44),
    (1060, 4, 0.41);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1061, 4, 0.43),
    (1062, 4, 0.43),
    (1063, 4, 0.4),
    (1064, 4, 0.43),
    (1065, 4, 0.42),
    (1066, 4, 0.4),
    (1067, 4, 0.4),
    (1068, 4, 0.0),
    (1069, 4, 0.84),
    (1070, 4, 0.36);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1071, 4, 0.5),
    (1072, 4, 0.52),
    (1073, 4, 0.47),
    (1074, 4, 0.27),
    (1075, 4, 0.26),
    (1076, 4, 0.51),
    (1077, 4, 0.46),
    (1078, 4, 0.26),
    (1079, 4, 0.51),
    (1080, 4, 0.5);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1081, 4, 0.46),
    (1082, 4, 0.46),
    (1083, 4, 0.27),
    (1084, 4, 0.26),
    (1085, 4, 0.38),
    (1086, 4, 0.39),
    (1087, 4, 0.38),
    (1088, 4, 0.38),
    (1089, 4, 0.38),
    (1090, 4, 0.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1091, 4, 0.25),
    (1092, 4, 0.24),
    (1093, 4, 0.86),
    (1094, 4, 0.41),
    (1095, 4, 0.87),
    (1096, 4, 0.28),
    (1097, 4, 0.28),
    (1098, 4, 0.28),
    (1099, 4, 0.77),
    (1100, 4, 0.28);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1101, 4, 0.28),
    (1102, 4, 0.14),
    (1103, 4, 0.66),
    (1104, 4, 0.52),
    (1105, 4, 0.65),
    (1106, 4, 0.65),
    (1107, 4, 0.51),
    (1108, 4, 1.64),
    (1109, 4, 0.56),
    (1110, 4, 2.06);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1111, 4, 2.04),
    (1112, 4, 1.46),
    (1113, 4, 1.53),
    (1114, 4, 1.52),
    (1115, 4, 1.18),
    (1116, 4, 1.47),
    (1117, 4, 1.48),
    (1118, 4, 1.47),
    (1119, 4, 1.15),
    (1120, 4, 1.49);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1121, 4, 1.48),
    (1122, 4, 1.48),
    (1123, 4, 1.47),
    (1124, 4, 1.15),
    (1125, 4, 1.15),
    (1126, 4, 1.27),
    (1127, 4, 1.24),
    (1128, 4, 1.24),
    (1129, 4, 1.24),
    (1130, 4, 0.2);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1131, 4, 0.36),
    (1132, 4, 0.46),
    (1133, 4, 0.54),
    (1134, 4, 1.42),
    (1135, 4, 2.16),
    (1136, 4, 2.39),
    (1137, 4, 2.1),
    (1138, 4, 2.1),
    (1139, 4, 2.33),
    (1140, 4, 2.28);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1141, 4, 2.21),
    (1142, 4, 0.48),
    (1143, 4, 0.5),
    (1144, 4, 0.46),
    (1145, 4, 0.46),
    (1146, 4, 0.49),
    (1147, 4, 0.69),
    (1148, 4, 0.47),
    (1149, 4, 0.46),
    (1150, 4, 0.49);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1151, 4, 0.48),
    (1152, 4, 0.33),
    (1153, 4, 0.32),
    (1154, 4, 1.36),
    (1155, 4, 0.37),
    (1156, 4, 1.14),
    (1157, 4, 1.11),
    (1158, 4, 0.25),
    (1159, 4, 0.25),
    (1160, 4, 0.69);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1161, 4, 0.82),
    (1162, 4, 0.72),
    (1163, 4, 0.8),
    (1164, 4, 0.8),
    (1165, 4, 0.7),
    (1166, 4, 0.8),
    (1167, 4, 0.8),
    (1168, 4, 0.7),
    (1169, 4, 0.7),
    (1170, 4, 0.81);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1171, 4, 0.79),
    (1172, 4, 0.79),
    (1173, 4, 0.79),
    (1174, 4, 0.99),
    (1175, 4, 0.97),
    (1176, 4, 0.44),
    (1177, 4, 0.25),
    (1178, 4, 0.26),
    (1179, 4, 0.51),
    (1180, 4, 0.5);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1181, 4, 0.52),
    (1182, 4, 0.5),
    (1183, 4, 1.04),
    (1184, 4, 1.01),
    (1185, 4, 0.82),
    (1186, 4, 1.43),
    (1187, 4, 0.43),
    (1188, 4, 1.67),
    (1189, 4, 0.57),
    (1190, 4, 1.6);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1191, 4, 0.72),
    (1192, 4, 0.45),
    (1193, 4, 1.83),
    (1194, 4, 1.62),
    (1195, 4, 1.71),
    (1196, 4, 0.96),
    (1197, 4, 1.69),
    (1198, 4, 0.84),
    (1199, 4, 0.97),
    (1200, 4, 0.77);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1201, 4, 0.79),
    (1202, 4, 0.36),
    (1203, 4, 1.54),
    (1204, 4, 1.12),
    (1205, 4, 0.68),
    (1206, 4, 0.88),
    (1207, 4, 0.54),
    (1208, 4, 0.41),
    (1209, 4, 0.0),
    (1210, 4, 0.23);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1211, 4, 0.35),
    (1212, 4, 0.06),
    (1213, 4, 0.0),
    (1214, 4, 2.5),
    (1215, 4, 0.23),
    (1216, 4, 0.87),
    (1217, 4, 0.25),
    (1218, 4, 0.2),
    (1219, 4, 0.28),
    (1220, 4, 0.19);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1221, 4, 0.52),
    (1222, 4, 6.28),
    (1223, 4, 0.49),
    (1224, 4, 6.28),
    (1225, 4, 0.31),
    (1226, 4, 3.4),
    (1227, 4, 0.23),
    (1228, 4, 0.32),
    (1229, 4, 0.28),
    (1230, 4, 0.23);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1231, 4, 1.58),
    (1232, 4, 0.29),
    (1233, 4, 1.89),
    (1234, 4, 0.22),
    (1235, 4, 0.25),
    (1236, 4, 0.31),
    (1237, 4, 0.25),
    (1238, 4, 0.24),
    (1239, 4, 0.3),
    (1240, 4, 0.67);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1241, 4, 0.36),
    (1242, 4, 0.58),
    (1243, 4, 0.24),
    (1244, 4, 0.24),
    (1245, 4, 0.2),
    (1246, 4, 0.48),
    (1247, 4, 0.4),
    (1248, 4, 0.31),
    (1249, 4, 0.48),
    (1250, 4, 0.37);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1251, 4, 0.39),
    (1252, 4, 0.32),
    (1253, 4, 0.32),
    (1254, 4, 0.37),
    (1255, 4, 0.39),
    (1256, 4, 1.08),
    (1257, 4, 1.08),
    (1258, 4, 0.32),
    (1259, 4, 0.48),
    (1260, 4, 0.48);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1261, 4, 0.89),
    (1262, 4, 0.95),
    (1263, 4, 0.95),
    (1264, 4, 0.95),
    (1265, 4, 0.69),
    (1266, 4, 0.51),
    (1267, 4, 0.82),
    (1268, 4, 0.77),
    (1269, 4, 0.66),
    (1270, 4, 1.12);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1271, 4, 0.68),
    (1272, 4, 0.31),
    (1273, 4, 1.44),
    (1274, 4, 0.06),
    (1275, 4, 0.06),
    (1276, 4, 0.0),
    (1277, 4, 0.65),
    (1278, 4, 0.24),
    (1279, 4, 0.0),
    (1280, 4, 0.01);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1281, 4, 0.09),
    (1282, 4, 0.0),
    (1283, 4, 0.26),
    (1284, 4, 0.11),
    (1285, 4, 0.0),
    (1286, 4, 0.0),
    (1287, 4, 0.1),
    (1288, 4, 0.25),
    (1289, 4, 0.04),
    (1290, 4, 0.25);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1291, 4, 0.01),
    (1292, 4, 0.0),
    (1293, 4, 0.06),
    (1294, 4, 0.04),
    (1295, 4, 0.0),
    (1296, 4, 0.06),
    (1297, 4, 0.03),
    (1298, 4, 0.0),
    (1299, 4, 0.2),
    (1300, 4, 0.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1301, 4, 0.05),
    (1302, 4, 0.3),
    (1303, 4, 0.04),
    (1304, 4, 0.05),
    (1305, 4, 0.1),
    (1306, 4, 0.4),
    (1307, 4, 0.06),
    (1308, 4, 0.17),
    (1309, 4, 0.0),
    (1310, 4, 0.16);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1, 5, 3.33),
    (2, 5, 3.27),
    (3, 5, 3.36),
    (4, 5, 3.38),
    (5, 5, 3.43),
    (6, 5, 3.38),
    (7, 5, 3.43),
    (8, 5, 3.36),
    (9, 5, 3.27),
    (10, 5, 3.46);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (11, 5, 3.59),
    (12, 5, 3.56),
    (13, 5, 3.2),
    (14, 5, 4.01),
    (15, 5, 6.81),
    (16, 5, 6.81),
    (17, 5, 7.42),
    (18, 5, 7.55),
    (19, 5, 6.67),
    (20, 5, 9.11);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (21, 5, 4.57),
    (22, 5, 5.25),
    (23, 5, 3.82),
    (24, 5, 5.25),
    (25, 5, 4.23),
    (26, 5, 10.2),
    (27, 5, 8.78),
    (28, 5, 10.2),
    (29, 5, 10.3),
    (30, 5, 4.57);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (31, 5, 3.34),
    (32, 5, 4.57),
    (33, 5, 3.64),
    (34, 5, 9.11),
    (35, 5, 7.85),
    (36, 5, 9.11),
    (37, 5, 9.21),
    (38, 5, 4.51),
    (39, 5, 3.28),
    (40, 5, 4.51);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (41, 5, 3.64),
    (42, 5, 9.07),
    (43, 5, 7.81),
    (44, 5, 9.07),
    (45, 5, 9.17),
    (46, 5, 9.22),
    (47, 5, 3.65),
    (48, 5, 4.34),
    (49, 5, 5.25),
    (50, 5, 4.9);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (51, 5, 3.82),
    (52, 5, 3.48),
    (53, 5, 1.38),
    (54, 5, 1.37),
    (55, 5, 1.8),
    (56, 5, 1.8),
    (57, 5, 1.37),
    (58, 5, 1.37),
    (59, 5, 1.37),
    (60, 5, 1.37);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (61, 5, 1.4),
    (62, 5, 1.4),
    (63, 5, 1.4),
    (64, 5, 1.4),
    (65, 5, 1.38),
    (66, 5, 1.38),
    (67, 5, 1.73),
    (68, 5, 1.43),
    (69, 5, 1.4),
    (70, 5, 1.4);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (71, 5, 1.4),
    (72, 5, 1.4),
    (73, 5, 1.6),
    (74, 5, 1.6),
    (75, 5, 1.51),
    (76, 5, 1.51),
    (77, 5, 1.51),
    (78, 5, 1.51),
    (79, 5, 1.7),
    (80, 5, 2.86);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (81, 5, 1.72),
    (82, 5, 1.72),
    (83, 5, 2.86),
    (84, 5, 1.49),
    (85, 5, 1.45),
    (86, 5, 1.45),
    (87, 5, 1.45),
    (88, 5, 1.45),
    (89, 5, 1.45),
    (90, 5, 1.72);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (91, 5, 1.96),
    (92, 5, 1.96),
    (93, 5, 1.38),
    (94, 5, 1.38),
    (95, 5, 1.38),
    (96, 5, 1.38),
    (97, 5, 1.38),
    (98, 5, 1.46),
    (99, 5, 1.49),
    (100, 5, 1.64);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (101, 5, 1.64),
    (102, 5, 1.64),
    (103, 5, 1.64),
    (104, 5, 1.58),
    (105, 5, 1.58),
    (106, 5, 1.58),
    (107, 5, 1.58),
    (108, 5, 1.76),
    (109, 5, 1.6),
    (110, 5, 1.6);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (111, 5, 1.6),
    (112, 5, 1.6),
    (113, 5, 1.61),
    (114, 5, 1.82),
    (115, 5, 1.82),
    (116, 5, 1.81),
    (117, 5, 1.81),
    (118, 5, 1.8),
    (119, 5, 1.43),
    (120, 5, 2.09);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (121, 5, 5.6),
    (122, 5, 1.45),
    (123, 5, 5.08),
    (124, 5, 5.23),
    (125, 5, 4.06),
    (126, 5, 3.23),
    (127, 5, 3.58),
    (128, 5, 1.95),
    (129, 5, 2.78),
    (130, 5, 3.14);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (131, 5, 3.18),
    (132, 5, 3.48),
    (133, 5, 1.45),
    (134, 5, 3.18),
    (135, 5, 2.09),
    (136, 5, 3.48),
    (137, 5, 1.95),
    (138, 5, 2.57),
    (139, 5, 4.2),
    (140, 5, 6.84);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (141, 5, 5.42),
    (142, 5, 3.52),
    (143, 5, 9.43),
    (144, 5, 12.58),
    (145, 5, 12.03),
    (146, 5, 11.3),
    (147, 5, 13.7),
    (148, 5, 13.7),
    (149, 5, 11.5),
    (150, 5, 4.91);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (151, 5, 2.65),
    (152, 5, 5.81),
    (153, 5, 1.42),
    (154, 5, 3.06),
    (155, 5, 1.94),
    (156, 5, 5.91),
    (157, 5, 3.38),
    (158, 5, 3.57),
    (159, 5, 3.14),
    (160, 5, 0.89);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (161, 5, 2.02),
    (162, 5, 3.44),
    (163, 5, 6.23),
    (164, 5, 2.58),
    (165, 5, 4.0),
    (166, 5, 2.48),
    (167, 5, 3.12),
    (168, 5, 2.28),
    (169, 5, 2.58),
    (170, 5, 12.4);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (171, 5, 11.84),
    (172, 5, 12.4),
    (173, 5, 11.58),
    (174, 5, 12.36),
    (175, 5, 11.57),
    (176, 5, 11.56),
    (177, 5, 11.61),
    (178, 5, 11.7),
    (179, 5, 12.24),
    (180, 5, 11.58);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (181, 5, 11.56),
    (182, 5, 11.58),
    (183, 5, 12.36),
    (184, 5, 11.58),
    (185, 5, 12.49),
    (186, 5, 10.7),
    (187, 5, 9.99),
    (188, 5, 10.67),
    (189, 5, 9.99),
    (190, 5, 16.2);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (191, 5, 15.12),
    (192, 5, 16.15),
    (193, 5, 15.12),
    (194, 5, 11.96),
    (195, 5, 12.94),
    (196, 5, 13.01),
    (197, 5, 7.79),
    (198, 5, 13.81),
    (199, 5, 11.52),
    (200, 5, 10.26);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (201, 5, 9.97),
    (202, 5, 10.07),
    (203, 5, 9.97),
    (204, 5, 10.17),
    (205, 5, 10.17),
    (206, 5, 10.02),
    (207, 5, 9.98),
    (208, 5, 9.8),
    (209, 5, 6.68),
    (210, 5, 11.43);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (211, 5, 11.58),
    (212, 5, 11.57),
    (213, 5, 11.56),
    (214, 5, 11.61),
    (215, 5, 11.7),
    (216, 5, 12.24),
    (217, 5, 11.58),
    (218, 5, 12.36),
    (219, 5, 11.56),
    (220, 5, 12.65);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (221, 5, 12.64),
    (222, 5, 12.69),
    (223, 5, 12.77),
    (224, 5, 13.29),
    (225, 5, 13.41),
    (226, 5, 12.71),
    (227, 5, 12.7),
    (228, 5, 12.69),
    (229, 5, 12.74),
    (230, 5, 12.82);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (231, 5, 13.35),
    (232, 5, 12.71),
    (233, 5, 13.46),
    (234, 5, 13.27),
    (235, 5, 13.27),
    (236, 5, 13.26),
    (237, 5, 13.3),
    (238, 5, 13.38),
    (239, 5, 13.89),
    (240, 5, 13.27);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (241, 5, 14.0),
    (242, 5, 10.29),
    (243, 5, 10.9),
    (244, 5, 10.29),
    (245, 5, 10.52),
    (246, 5, 11.14),
    (247, 5, 10.52),
    (248, 5, 10.34),
    (249, 5, 10.94),
    (250, 5, 10.34);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (251, 5, 10.55),
    (252, 5, 11.18),
    (253, 5, 10.55),
    (254, 5, 11.39),
    (255, 5, 11.99),
    (256, 5, 11.39),
    (257, 5, 11.6),
    (258, 5, 12.2),
    (259, 5, 11.6),
    (260, 5, 11.43);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (261, 5, 12.02),
    (262, 5, 11.43),
    (263, 5, 11.63),
    (264, 5, 12.24),
    (265, 5, 11.63),
    (266, 5, 11.09),
    (267, 5, 11.69),
    (268, 5, 11.09),
    (269, 5, 11.3),
    (270, 5, 11.91);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (271, 5, 11.3),
    (272, 5, 11.47),
    (273, 5, 12.07),
    (274, 5, 11.47),
    (275, 5, 11.33),
    (276, 5, 11.95),
    (277, 5, 11.33),
    (278, 5, 12.58),
    (279, 5, 13.22),
    (280, 5, 12.58);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (281, 5, 12.68),
    (282, 5, 13.34),
    (283, 5, 12.68),
    (284, 5, 12.06),
    (285, 5, 12.64),
    (286, 5, 12.06),
    (287, 5, 12.7),
    (288, 5, 13.35),
    (289, 5, 12.7),
    (290, 5, 10.41);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (291, 5, 11.03),
    (292, 5, 10.41),
    (293, 5, 1.16),
    (294, 5, 9.99),
    (295, 5, 9.98),
    (296, 5, 9.97),
    (297, 5, 10.03),
    (298, 5, 10.56),
    (299, 5, 9.99),
    (300, 5, 10.67);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (301, 5, 11.27),
    (302, 5, 11.32),
    (303, 5, 9.13),
    (304, 5, 11.99),
    (305, 5, 10.36),
    (306, 5, 10.01),
    (307, 5, 11.47),
    (308, 5, 7.17),
    (309, 5, 9.34),
    (310, 5, 9.97);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (311, 5, 10.69),
    (312, 5, 10.75),
    (313, 5, 8.56),
    (314, 5, 11.46),
    (315, 5, 9.85),
    (316, 5, 9.48),
    (317, 5, 10.97),
    (318, 5, 8.34),
    (319, 5, 8.34),
    (320, 5, 8.92);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (321, 5, 7.66),
    (322, 5, 7.96),
    (323, 5, 8.77),
    (324, 5, 9.04),
    (325, 5, 9.04),
    (326, 5, 9.67),
    (327, 5, 10.43),
    (328, 5, 10.84),
    (329, 5, 10.43),
    (330, 5, 8.23);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (331, 5, 8.23),
    (332, 5, 8.81),
    (333, 5, 8.54),
    (334, 5, 8.87),
    (335, 5, 8.54),
    (336, 5, 7.98),
    (337, 5, 10.61),
    (338, 5, 7.06),
    (339, 5, 7.25),
    (340, 5, 7.25);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (341, 5, 8.42),
    (342, 5, 8.37),
    (343, 5, 8.37),
    (344, 5, 8.96),
    (345, 5, 7.37),
    (346, 5, 7.66),
    (347, 5, 7.38),
    (348, 5, 8.12),
    (349, 5, 10.73),
    (350, 5, 8.06);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (351, 5, 8.06),
    (352, 5, 8.62),
    (353, 5, 8.37),
    (354, 5, 8.7),
    (355, 5, 8.37),
    (356, 5, 7.81),
    (357, 5, 10.46),
    (358, 5, 8.51),
    (359, 5, 16.92),
    (360, 5, 6.52);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (361, 5, 4.52),
    (362, 5, 4.75),
    (363, 5, 4.38),
    (364, 5, 6.37),
    (365, 5, 6.05),
    (366, 5, 4.98),
    (367, 5, 6.7),
    (368, 5, 7.81),
    (369, 5, 4.98),
    (370, 5, 6.74);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (371, 5, 4.52),
    (372, 5, 10.7),
    (373, 5, 4.77),
    (374, 5, 7.18),
    (375, 5, 7.18),
    (376, 5, 8.23),
    (377, 5, 8.23),
    (378, 5, 8.81),
    (379, 5, 7.88),
    (380, 5, 8.19);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (381, 5, 7.89),
    (382, 5, 8.29),
    (383, 5, 7.75),
    (384, 5, 14.11),
    (385, 5, 8.38),
    (386, 5, 8.38),
    (387, 5, 8.97),
    (388, 5, 8.36),
    (389, 5, 8.6),
    (390, 5, 25.56);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (391, 5, 4.33),
    (392, 5, 38.55),
    (393, 5, 11.54),
    (394, 5, 3.76),
    (395, 5, 2.44),
    (396, 5, 2.21),
    (397, 5, 2.45),
    (398, 5, 5.88),
    (399, 5, 5.57),
    (400, 5, 3.55);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (401, 5, 2.48),
    (402, 5, 2.49),
    (403, 5, 3.82),
    (404, 5, 5.94),
    (405, 5, 1.68),
    (406, 5, 0.67),
    (407, 5, 12.96),
    (408, 5, 14.0),
    (409, 5, 6.22),
    (410, 5, 3.24);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (411, 5, 0.22),
    (412, 5, 0.21),
    (413, 5, 4.29),
    (414, 5, 12.0),
    (415, 5, 12.01),
    (416, 5, 10.8),
    (417, 5, 12.1),
    (418, 5, 10.1),
    (419, 5, 15.08),
    (420, 5, 11.25);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (421, 5, 7.34),
    (422, 5, 5.43),
    (423, 5, 9.88),
    (424, 5, 11.37),
    (425, 5, 6.64),
    (426, 5, 7.3),
    (427, 5, 7.12),
    (428, 5, 8.8),
    (429, 5, 10.0),
    (430, 5, 8.8);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (431, 5, 8.8),
    (432, 5, 6.64),
    (433, 5, 6.64),
    (434, 5, 6.64),
    (435, 5, 9.34),
    (436, 5, 10.93),
    (437, 5, 10.93),
    (438, 5, 10.93),
    (439, 5, 10.0),
    (440, 5, 10.1);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (441, 5, 9.62),
    (442, 5, 7.9),
    (443, 5, 9.85),
    (444, 5, 10.0),
    (445, 5, 7.6),
    (446, 5, 7.1),
    (447, 5, 10.0),
    (448, 5, 10.78),
    (449, 5, 9.7),
    (450, 5, 5.91);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (451, 5, 7.1),
    (452, 5, 11.47),
    (453, 5, 11.47),
    (454, 5, 7.5),
    (455, 5, 8.33),
    (456, 5, 14.12),
    (457, 5, 9.3),
    (458, 5, 7.66),
    (459, 5, 7.14),
    (460, 5, 10.33);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (461, 5, 8.94),
    (462, 5, 8.94),
    (463, 5, 8.94),
    (464, 5, 11.34),
    (465, 5, 8.94),
    (466, 5, 8.94),
    (467, 5, 8.94),
    (468, 5, 9.34),
    (469, 5, 11.25),
    (470, 5, 11.25);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (471, 5, 12.5),
    (472, 5, 6.19),
    (473, 5, 6.19),
    (474, 5, 3.2),
    (475, 5, 10.0),
    (476, 5, 11.79),
    (477, 5, 12.34),
    (478, 5, 4.52),
    (479, 5, 4.51),
    (480, 5, 5.96);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (481, 5, 10.33),
    (482, 5, 0.04),
    (483, 5, 1.78),
    (484, 5, 5.76),
    (485, 5, 5.95),
    (486, 5, 3.2),
    (487, 5, 2.2),
    (488, 5, 3.24),
    (489, 5, 3.5),
    (490, 5, 2.6);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (491, 5, 2.4),
    (492, 5, 2.18),
    (493, 5, 2.21),
    (494, 5, 2.18),
    (495, 5, 5.56),
    (496, 5, 5.48),
    (497, 5, 3.35),
    (498, 5, 3.31),
    (499, 5, 2.26),
    (500, 5, 2.2);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (501, 5, 4.96),
    (502, 5, 4.81),
    (503, 5, 3.18),
    (504, 5, 3.09),
    (505, 5, 2.44),
    (506, 5, 2.38),
    (507, 5, 2.34),
    (508, 5, 2.29),
    (509, 5, 2.35),
    (510, 5, 2.12);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (511, 5, 4.2),
    (512, 5, 4.38),
    (513, 5, 4.2),
    (514, 5, 2.67),
    (515, 5, 2.67),
    (516, 5, 2.6),
    (517, 5, 2.62),
    (518, 5, 2.6),
    (519, 5, 2.6),
    (520, 5, 2.67);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (521, 5, 2.44),
    (522, 5, 2.38),
    (523, 5, 2.4),
    (524, 5, 2.38),
    (525, 5, 2.38),
    (526, 5, 2.43),
    (527, 5, 5.13),
    (528, 5, 2.52),
    (529, 5, 0.8),
    (530, 5, 1.8);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (531, 5, 1.8),
    (532, 5, 1.76),
    (533, 5, 2.01),
    (534, 5, 3.86),
    (535, 5, 3.97),
    (536, 5, 3.86),
    (537, 5, 1.82),
    (538, 5, 2.89),
    (539, 5, 2.17),
    (540, 5, 2.17);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (541, 5, 2.82),
    (542, 5, 2.2),
    (543, 5, 2.84),
    (544, 5, 3.06),
    (545, 5, 2.9),
    (546, 5, 3.06),
    (547, 5, 3.77),
    (548, 5, 13.2),
    (549, 5, 10.99),
    (550, 5, 6.65);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (551, 5, 6.51),
    (552, 5, 6.53),
    (553, 5, 6.67),
    (554, 5, 10.64),
    (555, 5, 1.92),
    (556, 5, 1.38),
    (557, 5, 2.54),
    (558, 5, 1.87),
    (559, 5, 1.46),
    (560, 5, 1.92);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (561, 5, 1.12),
    (562, 5, 12.07),
    (563, 5, 6.34),
    (564, 5, 9.2),
    (565, 5, 7.83),
    (566, 5, 3.75),
    (567, 5, 4.75),
    (568, 5, 1.59),
    (569, 5, 3.94),
    (570, 5, 5.82);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (571, 5, 4.67),
    (572, 5, 6.46),
    (573, 5, 5.42),
    (574, 5, 3.51),
    (575, 5, 5.48),
    (576, 5, 3.54),
    (577, 5, 3.34),
    (578, 5, 2.38),
    (579, 5, 3.84),
    (580, 5, 2.02);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (581, 5, 3.09),
    (582, 5, 1.53),
    (583, 5, 7.13),
    (584, 5, 6.81),
    (585, 5, 7.04),
    (586, 5, 5.78),
    (587, 5, 4.01),
    (588, 5, 7.13),
    (589, 5, 4.85),
    (590, 5, 2.39);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (591, 5, 2.54),
    (592, 5, 4.22),
    (593, 5, 0.81),
    (594, 5, 0.77),
    (595, 5, 0.58),
    (596, 5, 1.88),
    (597, 5, 1.1),
    (598, 5, 0.7),
    (599, 5, 0.92),
    (600, 5, 0.6);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (601, 5, 0.62),
    (602, 5, 0.59),
    (603, 5, 0.81),
    (604, 5, 0.77),
    (605, 5, 0.68),
    (606, 5, 0.56),
    (607, 5, 0.17),
    (608, 5, 0.25),
    (609, 5, 0.27),
    (610, 5, 0.25);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (611, 5, 0.1),
    (612, 5, 0.32),
    (613, 5, 1.4),
    (614, 5, 0.65),
    (615, 5, 2.0),
    (616, 5, 0.74),
    (617, 5, 0.82),
    (618, 5, 0.82),
    (619, 5, 0.66),
    (620, 5, 1.04);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (621, 5, 0.22),
    (622, 5, 1.04),
    (623, 5, 0.71),
    (624, 5, 1.04),
    (625, 5, 0.68),
    (626, 5, 0.75),
    (627, 5, 0.56),
    (628, 5, 2.55),
    (629, 5, 1.06),
    (630, 5, 0.83);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (631, 5, 0.54),
    (632, 5, 0.82),
    (633, 5, 0.62),
    (634, 5, 0.82),
    (635, 5, 1.06),
    (636, 5, 0.47),
    (637, 5, 0.35),
    (638, 5, 2.2),
    (639, 5, 0.91),
    (640, 5, 0.43);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (641, 5, 0.4),
    (642, 5, 0.45),
    (643, 5, 0.91),
    (644, 5, 0.37),
    (645, 5, 0.5),
    (646, 5, 0.2),
    (647, 5, 0.18),
    (648, 5, 0.23),
    (649, 5, 0.58),
    (650, 5, 0.7);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (651, 5, 0.52),
    (652, 5, 1.67),
    (653, 5, 0.81),
    (654, 5, 2.8),
    (655, 5, 0.61),
    (656, 5, 0.66),
    (657, 5, 0.76),
    (658, 5, 1.39),
    (659, 5, 1.18),
    (660, 5, 0.7);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (661, 5, 1.04),
    (662, 5, 0.42),
    (663, 5, 0.46),
    (664, 5, 0.9),
    (665, 5, 1.01),
    (666, 5, 1.01),
    (667, 5, 0.64),
    (668, 5, 0.56),
    (669, 5, 0.43),
    (670, 5, 0.81);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (671, 5, 0.64),
    (672, 5, 0.71),
    (673, 5, 0.41),
    (674, 5, 0.39),
    (675, 5, 0.43),
    (676, 5, 0.69),
    (677, 5, 1.45),
    (678, 5, 1.34),
    (679, 5, 1.41),
    (680, 5, 1.78);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (681, 5, 1.99),
    (682, 5, 1.93),
    (683, 5, 1.78),
    (684, 5, 1.95),
    (685, 5, 1.86),
    (686, 5, 1.87),
    (687, 5, 2.08),
    (688, 5, 2.03),
    (689, 5, 1.87),
    (690, 5, 8.82);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (691, 5, 0.5),
    (692, 5, 0.54),
    (693, 5, 0.29),
    (694, 5, 0.16),
    (695, 5, 0.12),
    (696, 5, 0.27),
    (697, 5, 0.3),
    (698, 5, 0.46),
    (699, 5, 0.0),
    (700, 5, 0.18);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (701, 5, 0.37),
    (702, 5, 0.17),
    (703, 5, 0.39),
    (704, 5, 0.36),
    (705, 5, 0.15),
    (706, 5, 0.61),
    (707, 5, 0.42),
    (708, 5, 0.61),
    (709, 5, 0.11),
    (710, 5, 0.17);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (711, 5, 0.26),
    (712, 5, 0.33),
    (713, 5, 0.3),
    (714, 5, 0.11),
    (715, 5, 0.1),
    (716, 5, 0.17),
    (717, 5, 0.16),
    (718, 5, 0.11),
    (719, 5, 0.11),
    (720, 5, 0.68);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (721, 5, 0.68),
    (722, 5, 0.68),
    (723, 5, 1.07),
    (724, 5, 1.87),
    (725, 5, 0.98),
    (726, 5, 0.98),
    (727, 5, 1.48),
    (728, 5, 2.1),
    (729, 5, 2.63),
    (730, 5, 2.26);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (731, 5, 0.2),
    (732, 5, 0.0),
    (733, 5, 1.0),
    (734, 5, 1.0),
    (735, 5, 0.94),
    (736, 5, 0.94),
    (737, 5, 0.3),
    (738, 5, 0.3),
    (739, 5, 1.0),
    (740, 5, 0.82);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (741, 5, 0.0),
    (742, 5, 0.0),
    (743, 5, 0.0),
    (744, 5, 0.0),
    (745, 5, 0.0),
    (746, 5, 0.3),
    (747, 5, 1.56),
    (748, 5, 1.76),
    (749, 5, 14.29),
    (750, 5, 2.09);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (751, 5, 2.46),
    (752, 5, 2.46),
    (753, 5, 1.34),
    (754, 5, 7.13),
    (755, 5, 6.66),
    (756, 5, 7.13),
    (757, 5, 7.44),
    (758, 5, 6.91),
    (759, 5, 7.3),
    (760, 5, 6.8);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (761, 5, 7.1),
    (762, 5, 2.15),
    (763, 5, 1.65),
    (764, 5, 1.46),
    (765, 5, 1.97),
    (766, 5, 2.15),
    (767, 5, 4.41),
    (768, 5, 1.86),
    (769, 5, 2.15),
    (770, 5, 2.07);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (771, 5, 1.8),
    (772, 5, 2.14),
    (773, 5, 2.05),
    (774, 5, 2.05),
    (775, 5, 4.32),
    (776, 5, 1.78),
    (777, 5, 1.97),
    (778, 5, 4.26),
    (779, 5, 1.72),
    (780, 5, 3.04);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (781, 5, 1.96),
    (782, 5, 2.72),
    (783, 5, 2.76),
    (784, 5, 2.72),
    (785, 5, 2.93),
    (786, 5, 2.95),
    (787, 5, 2.8),
    (788, 5, 2.79),
    (789, 5, 2.67),
    (790, 5, 2.92);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (791, 5, 1.73),
    (792, 5, 1.51),
    (793, 5, 1.41),
    (794, 5, 1.46),
    (795, 5, 1.41),
    (796, 5, 1.59),
    (797, 5, 1.62),
    (798, 5, 1.44),
    (799, 5, 1.43),
    (800, 5, 1.38);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (801, 5, 4.47),
    (802, 5, 4.37),
    (803, 5, 1.99),
    (804, 5, 1.71),
    (805, 5, 1.51),
    (806, 5, 3.78),
    (807, 5, 1.3),
    (808, 5, 1.26),
    (809, 5, 1.3),
    (810, 5, 1.27);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (811, 5, 1.27),
    (812, 5, 1.42),
    (813, 5, 1.24),
    (814, 5, 1.57),
    (815, 5, 1.5),
    (816, 5, 2.2),
    (817, 5, 2.3),
    (818, 5, 3.17),
    (819, 5, 3.2),
    (820, 5, 1.8);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (821, 5, 1.88),
    (822, 5, 3.02),
    (823, 5, 3.24),
    (824, 5, 2.96),
    (825, 5, 3.15),
    (826, 5, 3.15),
    (827, 5, 2.88),
    (828, 5, 3.14),
    (829, 5, 3.16),
    (830, 5, 2.88);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (831, 5, 2.89),
    (832, 5, 2.6),
    (833, 5, 2.72),
    (834, 5, 2.7),
    (835, 5, 2.82),
    (836, 5, 1.12),
    (837, 5, 2.97),
    (838, 5, 2.92),
    (839, 5, 2.89),
    (840, 5, 2.89);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (841, 5, 2.84),
    (842, 5, 1.32),
    (843, 5, 2.92),
    (844, 5, 3.13),
    (845, 5, 2.93),
    (846, 5, 3.05),
    (847, 5, 3.05),
    (848, 5, 2.85),
    (849, 5, 3.11),
    (850, 5, 2.86);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (851, 5, 3.07),
    (852, 5, 2.26),
    (853, 5, 2.99),
    (854, 5, 2.99),
    (855, 5, 2.21),
    (856, 5, 2.24),
    (857, 5, 2.85),
    (858, 5, 3.41),
    (859, 5, 4.0),
    (860, 5, 2.81);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (861, 5, 3.31),
    (862, 5, 3.33),
    (863, 5, 3.32),
    (864, 5, 3.32),
    (865, 5, 3.89),
    (866, 5, 2.74),
    (867, 5, 3.88),
    (868, 5, 3.9),
    (869, 5, 2.73),
    (870, 5, 2.74);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (871, 5, 2.39),
    (872, 5, 5.72),
    (873, 5, 7.05),
    (874, 5, 5.42),
    (875, 5, 4.1),
    (876, 5, 5.19),
    (877, 5, 1.14),
    (878, 5, 3.34),
    (879, 5, 1.11),
    (880, 5, 1.11);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (881, 5, 3.25),
    (882, 5, 2.3),
    (883, 5, 2.4),
    (884, 5, 3.49),
    (885, 5, 2.12),
    (886, 5, 2.57),
    (887, 5, 2.55),
    (888, 5, 2.67),
    (889, 5, 3.09),
    (890, 5, 2.6);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (891, 5, 2.6),
    (892, 5, 3.01),
    (893, 5, 2.59),
    (894, 5, 2.61),
    (895, 5, 3.0),
    (896, 5, 3.02),
    (897, 5, 3.55),
    (898, 5, 4.14),
    (899, 5, 4.28),
    (900, 5, 1.2);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (901, 5, 1.22),
    (902, 5, 4.26),
    (903, 5, 0.87),
    (904, 5, 0.94),
    (905, 5, 0.98),
    (906, 5, 0.81),
    (907, 5, 0.64),
    (908, 5, 0.95),
    (909, 5, 0.96),
    (910, 5, 0.96);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (911, 5, 0.96),
    (912, 5, 0.79),
    (913, 5, 0.63),
    (914, 5, 0.78),
    (915, 5, 0.8),
    (916, 5, 0.62),
    (917, 5, 0.64),
    (918, 5, 0.9),
    (919, 5, 0.59),
    (920, 5, 0.58);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (921, 5, 0.57),
    (922, 5, 0.59),
    (923, 5, 3.3),
    (924, 5, 2.97),
    (925, 5, 2.56),
    (926, 5, 3.22),
    (927, 5, 3.22),
    (928, 5, 2.89),
    (929, 5, 2.49),
    (930, 5, 1.08);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (931, 5, 1.05),
    (932, 5, 1.0),
    (933, 5, 0.89),
    (934, 5, 0.87),
    (935, 5, 3.4),
    (936, 5, 1.58),
    (937, 5, 1.58),
    (938, 5, 1.64),
    (939, 5, 1.58),
    (940, 5, 1.58);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (941, 5, 1.64),
    (942, 5, 1.58),
    (943, 5, 1.18),
    (944, 5, 1.58),
    (945, 5, 1.64),
    (946, 5, 1.58),
    (947, 5, 1.89),
    (948, 5, 2.27),
    (949, 5, 2.27),
    (950, 5, 1.49);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (951, 5, 1.92),
    (952, 5, 2.27),
    (953, 5, 2.26),
    (954, 5, 2.12),
    (955, 5, 2.27),
    (956, 5, 1.1),
    (957, 5, 2.7),
    (958, 5, 3.68),
    (959, 5, 1.0),
    (960, 5, 0.65);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (961, 5, 1.21),
    (962, 5, 0.63),
    (963, 5, 0.64),
    (964, 5, 8.46),
    (965, 5, 9.44),
    (966, 5, 1.19),
    (967, 5, 3.04),
    (968, 5, 3.99),
    (969, 5, 2.89),
    (970, 5, 2.2);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (971, 5, 3.04),
    (972, 5, 1.97),
    (973, 5, 1.61),
    (974, 5, 2.95),
    (975, 5, 3.38),
    (976, 5, 1.32),
    (977, 5, 1.92),
    (978, 5, 0.49),
    (979, 5, 1.24),
    (980, 5, 3.27);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (981, 5, 0.62),
    (982, 5, 0.98),
    (983, 5, 0.72),
    (984, 5, 1.7),
    (985, 5, 2.9),
    (986, 5, 5.42),
    (987, 5, 0.81),
    (988, 5, 0.72),
    (989, 5, 0.9),
    (990, 5, 1.66);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (991, 5, 0.68),
    (992, 5, 1.08),
    (993, 5, 3.51),
    (994, 5, 2.8),
    (995, 5, 1.01),
    (996, 5, 1.21),
    (997, 5, 0.9),
    (998, 5, 2.77),
    (999, 5, 4.7),
    (1000, 5, 2.75);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1001, 5, 7.02),
    (1002, 5, 11.32),
    (1003, 5, 0.0),
    (1004, 5, 2.36),
    (1005, 5, 2.94),
    (1006, 5, 2.14),
    (1007, 5, 2.3),
    (1008, 5, 2.3),
    (1009, 5, 2.86),
    (1010, 5, 2.09);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1011, 5, 2.29),
    (1012, 5, 2.31),
    (1013, 5, 2.86),
    (1014, 5, 2.87),
    (1015, 5, 2.08),
    (1016, 5, 2.09),
    (1017, 5, 1.68),
    (1018, 5, 6.05),
    (1019, 5, 5.88),
    (1020, 5, 5.86);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1021, 5, 1.96),
    (1022, 5, 2.05),
    (1023, 5, 1.49),
    (1024, 5, 1.04),
    (1025, 5, 1.51),
    (1026, 5, 2.0),
    (1027, 5, 1.45),
    (1028, 5, 1.02),
    (1029, 5, 1.99),
    (1030, 5, 2.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1031, 5, 1.44),
    (1032, 5, 1.46),
    (1033, 5, 1.01),
    (1034, 5, 1.03),
    (1035, 5, 1.12),
    (1036, 5, 1.1),
    (1037, 5, 1.09),
    (1038, 5, 1.1),
    (1039, 5, 4.04),
    (1040, 5, 1.45);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1041, 5, 9.8),
    (1042, 5, 1.67),
    (1043, 5, 0.91),
    (1044, 5, 0.89),
    (1045, 5, 1.63),
    (1046, 5, 0.89),
    (1047, 5, 0.84),
    (1048, 5, 0.82),
    (1049, 5, 1.04),
    (1050, 5, 2.98);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1051, 5, 3.51),
    (1052, 5, 3.63),
    (1053, 5, 3.42),
    (1054, 5, 3.42),
    (1055, 5, 3.53),
    (1056, 5, 1.6),
    (1057, 5, 1.32),
    (1058, 5, 1.29),
    (1059, 5, 1.99),
    (1060, 5, 1.6);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1061, 5, 1.94),
    (1062, 5, 1.94),
    (1063, 5, 1.57),
    (1064, 5, 1.94),
    (1065, 5, 1.95),
    (1066, 5, 1.56),
    (1067, 5, 1.58),
    (1068, 5, 0.52),
    (1069, 5, 1.42),
    (1070, 5, 0.86);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1071, 5, 3.11),
    (1072, 5, 3.26),
    (1073, 5, 2.54),
    (1074, 5, 2.29),
    (1075, 5, 2.23),
    (1076, 5, 3.17),
    (1077, 5, 2.48),
    (1078, 5, 2.23),
    (1079, 5, 3.17),
    (1080, 5, 3.18);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1081, 5, 2.47),
    (1082, 5, 2.48),
    (1083, 5, 2.22),
    (1084, 5, 2.24),
    (1085, 5, 1.74),
    (1086, 5, 2.1),
    (1087, 5, 2.04),
    (1088, 5, 2.04),
    (1089, 5, 2.05),
    (1090, 5, 0.72);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1091, 5, 1.05),
    (1092, 5, 1.03),
    (1093, 5, 1.06),
    (1094, 5, 1.72),
    (1095, 5, 1.54),
    (1096, 5, 3.61),
    (1097, 5, 3.52),
    (1098, 5, 3.52),
    (1099, 5, 1.82),
    (1100, 5, 3.5);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1101, 5, 3.52),
    (1102, 5, 2.4),
    (1103, 5, 2.07),
    (1104, 5, 1.62),
    (1105, 5, 2.02),
    (1106, 5, 2.02),
    (1107, 5, 1.59),
    (1108, 5, 2.62),
    (1109, 5, 1.29),
    (1110, 5, 8.23);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1111, 5, 8.19),
    (1112, 5, 5.37),
    (1113, 5, 5.63),
    (1114, 5, 5.14),
    (1115, 5, 4.47),
    (1116, 5, 4.99),
    (1117, 5, 5.47),
    (1118, 5, 4.99),
    (1119, 5, 4.35),
    (1120, 5, 5.46);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1121, 5, 5.48),
    (1122, 5, 4.99),
    (1123, 5, 5.0),
    (1124, 5, 4.34),
    (1125, 5, 4.36),
    (1126, 5, 3.99),
    (1127, 5, 3.88),
    (1128, 5, 3.87),
    (1129, 5, 3.89),
    (1130, 5, 0.74);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1131, 5, 0.92),
    (1132, 5, 1.13),
    (1133, 5, 2.65),
    (1134, 5, 0.9),
    (1135, 5, 2.91),
    (1136, 5, 3.49),
    (1137, 5, 2.83),
    (1138, 5, 2.83),
    (1139, 5, 3.4),
    (1140, 5, 3.51);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1141, 5, 3.41),
    (1142, 5, 1.3),
    (1143, 5, 1.21),
    (1144, 5, 1.27),
    (1145, 5, 1.27),
    (1146, 5, 1.18),
    (1147, 5, 0.6),
    (1148, 5, 1.26),
    (1149, 5, 1.28),
    (1150, 5, 1.18);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1151, 5, 1.19),
    (1152, 5, 0.65),
    (1153, 5, 0.95),
    (1154, 5, 1.38),
    (1155, 5, 0.4),
    (1156, 5, 4.3),
    (1157, 5, 4.18),
    (1158, 5, 1.06),
    (1159, 5, 1.04),
    (1160, 5, 2.84);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1161, 5, 2.85),
    (1162, 5, 2.11),
    (1163, 5, 2.78),
    (1164, 5, 2.78),
    (1165, 5, 2.06),
    (1166, 5, 2.77),
    (1167, 5, 2.78),
    (1168, 5, 2.05),
    (1169, 5, 2.07),
    (1170, 5, 1.95);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1171, 5, 1.9),
    (1172, 5, 1.89),
    (1173, 5, 1.91),
    (1174, 5, 3.84),
    (1175, 5, 3.74),
    (1176, 5, 1.09),
    (1177, 5, 1.44),
    (1178, 5, 1.49),
    (1179, 5, 2.35),
    (1180, 5, 2.29);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1181, 5, 1.76),
    (1182, 5, 1.72),
    (1183, 5, 2.07),
    (1184, 5, 2.01),
    (1185, 5, 4.25),
    (1186, 5, 5.33),
    (1187, 5, 1.96),
    (1188, 5, 4.02),
    (1189, 5, 4.54),
    (1190, 5, 3.66);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1191, 5, 7.02),
    (1192, 5, 6.16),
    (1193, 5, 10.7),
    (1194, 5, 4.63),
    (1195, 5, 3.88),
    (1196, 5, 4.19),
    (1197, 5, 3.76),
    (1198, 5, 3.48),
    (1199, 5, 2.32),
    (1200, 5, 3.69);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1201, 5, 4.65),
    (1202, 5, 1.41),
    (1203, 5, 3.81),
    (1204, 5, 4.92),
    (1205, 5, 1.6),
    (1206, 5, 2.03),
    (1207, 5, 1.63),
    (1208, 5, 0.8),
    (1209, 5, 0.41),
    (1210, 5, 1.7);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1211, 5, 1.59),
    (1212, 5, 0.8),
    (1213, 5, 1.03),
    (1214, 5, 1.1),
    (1215, 5, 0.48),
    (1216, 5, 0.37),
    (1217, 5, 0.58),
    (1218, 5, 0.81),
    (1219, 5, 0.33),
    (1220, 5, 2.4);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1221, 5, 1.6),
    (1222, 5, 0.84),
    (1223, 5, 1.03),
    (1224, 5, 0.84),
    (1225, 5, 1.15),
    (1226, 5, 0.73),
    (1227, 5, 0.67),
    (1228, 5, 0.8),
    (1229, 5, 0.86),
    (1230, 5, 0.48);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1231, 5, 3.44),
    (1232, 5, 0.56),
    (1233, 5, 2.91),
    (1234, 5, 0.94),
    (1235, 5, 0.75),
    (1236, 5, 1.0),
    (1237, 5, 0.52),
    (1238, 5, 0.81),
    (1239, 5, 2.1),
    (1240, 5, 5.45);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1241, 5, 1.41),
    (1242, 5, 3.73),
    (1243, 5, 1.12),
    (1244, 5, 1.12),
    (1245, 5, 0.84),
    (1246, 5, 1.71),
    (1247, 5, 3.28),
    (1248, 5, 3.36),
    (1249, 5, 1.44),
    (1250, 5, 0.8);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1251, 5, 0.8),
    (1252, 5, 0.81),
    (1253, 5, 0.81),
    (1254, 5, 1.1),
    (1255, 5, 1.1),
    (1256, 5, 1.2),
    (1257, 5, 1.2),
    (1258, 5, 1.3),
    (1259, 5, 1.44),
    (1260, 5, 1.44);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1261, 5, 1.84),
    (1262, 5, 2.95),
    (1263, 5, 3.27),
    (1264, 5, 3.27),
    (1265, 5, 3.65),
    (1266, 5, 3.49),
    (1267, 5, 4.02),
    (1268, 5, 4.08),
    (1269, 5, 3.02),
    (1270, 5, 4.9);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1271, 5, 13.16),
    (1272, 5, 0.3),
    (1273, 5, 1.98),
    (1274, 5, 0.46),
    (1275, 5, 0.07),
    (1276, 5, 0.0),
    (1277, 5, 0.64),
    (1278, 5, 0.18),
    (1279, 5, 0.0),
    (1280, 5, 0.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1281, 5, 0.22),
    (1282, 5, 0.0),
    (1283, 5, 0.47),
    (1284, 5, 0.1),
    (1285, 5, 0.0),
    (1286, 5, 0.0),
    (1287, 5, 0.0),
    (1288, 5, 0.13),
    (1289, 5, 0.04),
    (1290, 5, 0.13);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1291, 5, 0.0),
    (1292, 5, 0.0),
    (1293, 5, 0.1),
    (1294, 5, 0.0),
    (1295, 5, 0.0),
    (1296, 5, 0.1),
    (1297, 5, 0.06),
    (1298, 5, 0.21),
    (1299, 5, 0.0),
    (1300, 5, 0.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1301, 5, 0.08),
    (1302, 5, 0.0),
    (1303, 5, 0.0),
    (1304, 5, 0.0),
    (1305, 5, 0.0),
    (1306, 5, 0.5),
    (1307, 5, 0.21),
    (1308, 5, 0.0),
    (1309, 5, 0.0),
    (1310, 5, 0.83);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1, 6, 2.14),
    (2, 6, 3.2),
    (3, 6, 1.9),
    (4, 6, 0.95),
    (5, 6, 0.08),
    (6, 6, 0.95),
    (7, 6, 0.08),
    (8, 6, 1.9),
    (9, 6, 3.2),
    (10, 6, 1.08);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (11, 6, 0.96),
    (12, 6, 4.14),
    (13, 6, 0.07),
    (14, 6, 4.08),
    (15, 6, 7.56),
    (16, 6, 7.56),
    (17, 6, 1.96),
    (18, 6, 0.2),
    (19, 6, 2.87),
    (20, 6, 1.33);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (21, 6, 1.34),
    (22, 6, 1.55),
    (23, 6, 4.48),
    (24, 6, 1.55),
    (25, 6, 0.09),
    (26, 6, 1.36),
    (27, 6, 4.39),
    (28, 6, 1.36),
    (29, 6, 0.37),
    (30, 6, 1.34);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (31, 6, 3.86),
    (32, 6, 1.34),
    (33, 6, 0.08),
    (34, 6, 1.33),
    (35, 6, 3.91),
    (36, 6, 1.33),
    (37, 6, 0.34),
    (38, 6, 1.36),
    (39, 6, 3.88),
    (40, 6, 1.36);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (41, 6, 0.08),
    (42, 6, 1.34),
    (43, 6, 3.92),
    (44, 6, 1.34),
    (45, 6, 0.34),
    (46, 6, 3.67),
    (47, 6, 1.07),
    (48, 6, 1.03),
    (49, 6, 2.18),
    (50, 6, 2.15);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (51, 6, 4.48),
    (52, 6, 4.04),
    (53, 6, 3.56),
    (54, 6, 3.6),
    (55, 6, 3.63),
    (56, 6, 3.63),
    (57, 6, 3.62),
    (58, 6, 3.62),
    (59, 6, 3.62),
    (60, 6, 3.62);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (61, 6, 3.53),
    (62, 6, 3.53),
    (63, 6, 3.53),
    (64, 6, 3.53),
    (65, 6, 3.48),
    (66, 6, 3.48),
    (67, 6, 3.11),
    (68, 6, 3.49),
    (69, 6, 3.49),
    (70, 6, 3.49);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (71, 6, 3.49),
    (72, 6, 3.49),
    (73, 6, 3.24),
    (74, 6, 3.24),
    (75, 6, 3.49),
    (76, 6, 3.49),
    (77, 6, 3.49),
    (78, 6, 3.49),
    (79, 6, 3.52),
    (80, 6, 4.77);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (81, 6, 3.32),
    (82, 6, 3.32),
    (83, 6, 4.77),
    (84, 6, 3.33),
    (85, 6, 3.34),
    (86, 6, 3.34),
    (87, 6, 3.34),
    (88, 6, 3.34),
    (89, 6, 3.34),
    (90, 6, 3.32);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (91, 6, 3.78),
    (92, 6, 3.78),
    (93, 6, 3.56),
    (94, 6, 3.56),
    (95, 6, 3.56),
    (96, 6, 3.56),
    (97, 6, 3.56),
    (98, 6, 3.51),
    (99, 6, 3.36),
    (100, 6, 3.49);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (101, 6, 3.49),
    (102, 6, 3.49),
    (103, 6, 3.49),
    (104, 6, 3.53),
    (105, 6, 3.53),
    (106, 6, 3.53),
    (107, 6, 3.53),
    (108, 6, 3.6),
    (109, 6, 3.28),
    (110, 6, 3.28);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (111, 6, 3.28),
    (112, 6, 3.28),
    (113, 6, 3.51),
    (114, 6, 3.49),
    (115, 6, 3.49),
    (116, 6, 3.62),
    (117, 6, 3.62),
    (118, 6, 3.36),
    (119, 6, 3.6),
    (120, 6, 4.6);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (121, 6, 4.86),
    (122, 6, 3.78),
    (123, 6, 3.64),
    (124, 6, 4.94),
    (125, 6, 2.83),
    (126, 6, 2.15),
    (127, 6, 3.11),
    (128, 6, 3.88),
    (129, 6, 1.89),
    (130, 6, 2.1);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (131, 6, 2.07),
    (132, 6, 2.16),
    (133, 6, 3.78),
    (134, 6, 2.07),
    (135, 6, 4.6),
    (136, 6, 2.16),
    (137, 6, 3.88),
    (138, 6, 4.26),
    (139, 6, 15.12),
    (140, 6, 7.35);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (141, 6, 11.36),
    (142, 6, 7.15),
    (143, 6, 16.01),
    (144, 6, 5.99),
    (145, 6, 2.52),
    (146, 6, 3.8),
    (147, 6, 14.2),
    (148, 6, 7.9),
    (149, 6, 6.2),
    (150, 6, 1.41);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (151, 6, 2.17),
    (152, 6, 3.33),
    (153, 6, 0.93),
    (154, 6, 5.75),
    (155, 6, 1.17),
    (156, 6, 3.4),
    (157, 6, 1.23),
    (158, 6, 2.4),
    (159, 6, 2.17),
    (160, 6, 0.22);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (161, 6, 0.72),
    (162, 6, 1.14),
    (163, 6, 1.58),
    (164, 6, 1.21),
    (165, 6, 5.42),
    (166, 6, 0.51),
    (167, 6, 4.8),
    (168, 6, 4.81),
    (169, 6, 0.47),
    (170, 6, 9.96);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (171, 6, 13.86),
    (172, 6, 9.96),
    (173, 6, 15.0),
    (174, 6, 9.93),
    (175, 6, 13.52),
    (176, 6, 15.81),
    (177, 6, 14.64),
    (178, 6, 15.3),
    (179, 6, 10.61),
    (180, 6, 15.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (181, 6, 15.81),
    (182, 6, 15.0),
    (183, 6, 9.93),
    (184, 6, 15.0),
    (185, 6, 10.54),
    (186, 6, 0.0),
    (187, 6, 5.72),
    (188, 6, 0.0),
    (189, 6, 5.72),
    (190, 6, 28.8);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (191, 6, 32.56),
    (192, 6, 28.71),
    (193, 6, 32.56),
    (194, 6, 18.55),
    (195, 6, 18.09),
    (196, 6, 11.06),
    (197, 6, 10.35),
    (198, 6, 22.1),
    (199, 6, 15.9),
    (200, 6, 23.14);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (201, 6, 13.0),
    (202, 6, 12.83),
    (203, 6, 13.0),
    (204, 6, 17.68),
    (205, 6, 11.29),
    (206, 6, 12.74),
    (207, 6, 9.74),
    (208, 6, 8.82),
    (209, 6, 6.65),
    (210, 6, 9.75);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (211, 6, 15.0),
    (212, 6, 13.52),
    (213, 6, 15.81),
    (214, 6, 14.64),
    (215, 6, 15.3),
    (216, 6, 10.61),
    (217, 6, 15.0),
    (218, 6, 9.93),
    (219, 6, 15.81),
    (220, 6, 15.35);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (221, 6, 17.36),
    (222, 6, 16.34),
    (223, 6, 16.91),
    (224, 6, 12.91),
    (225, 6, 12.34),
    (226, 6, 15.35),
    (227, 6, 14.06),
    (228, 6, 16.06),
    (229, 6, 15.04),
    (230, 6, 15.61);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (231, 6, 11.54),
    (232, 6, 15.35),
    (233, 6, 10.96),
    (234, 6, 16.74),
    (235, 6, 15.54),
    (236, 6, 17.39),
    (237, 6, 16.45),
    (238, 6, 16.98),
    (239, 6, 13.3),
    (240, 6, 16.74);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (241, 6, 12.78),
    (242, 6, 13.19),
    (243, 6, 8.67),
    (244, 6, 13.19),
    (245, 6, 13.23),
    (246, 6, 8.71),
    (247, 6, 13.23),
    (248, 6, 13.11),
    (249, 6, 8.62),
    (250, 6, 13.11);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (251, 6, 13.21),
    (252, 6, 8.69),
    (253, 6, 13.21),
    (254, 6, 14.86),
    (255, 6, 10.94),
    (256, 6, 14.86),
    (257, 6, 14.89),
    (258, 6, 10.98),
    (259, 6, 14.89),
    (260, 6, 14.77);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (261, 6, 10.88),
    (262, 6, 14.77),
    (263, 6, 14.87),
    (264, 6, 10.96),
    (265, 6, 14.87),
    (266, 6, 13.54),
    (267, 6, 9.4),
    (268, 6, 13.54),
    (269, 6, 13.58),
    (270, 6, 9.44);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (271, 6, 13.58),
    (272, 6, 13.62),
    (273, 6, 9.68),
    (274, 6, 13.62),
    (275, 6, 13.56),
    (276, 6, 9.42),
    (277, 6, 13.56),
    (278, 6, 15.8),
    (279, 6, 12.03),
    (280, 6, 15.8);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (281, 6, 15.82),
    (282, 6, 12.05),
    (283, 6, 15.82),
    (284, 6, 14.98),
    (285, 6, 11.38),
    (286, 6, 14.98),
    (287, 6, 15.81),
    (288, 6, 12.04),
    (289, 6, 15.81),
    (290, 6, 13.18);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (291, 6, 8.65),
    (292, 6, 13.18),
    (293, 6, 0.61),
    (294, 6, 5.72),
    (295, 6, 4.24),
    (296, 6, 6.52),
    (297, 6, 5.36),
    (298, 6, 0.78),
    (299, 6, 5.72),
    (300, 6, 0.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (301, 6, 8.51),
    (302, 6, 7.21),
    (303, 6, 5.09),
    (304, 6, 9.21),
    (305, 6, 7.64),
    (306, 6, 6.05),
    (307, 6, 8.72),
    (308, 6, 0.04),
    (309, 6, 5.72),
    (310, 6, 0.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (311, 6, 8.51),
    (312, 6, 7.21),
    (313, 6, 5.09),
    (314, 6, 9.21),
    (315, 6, 7.64),
    (316, 6, 6.05),
    (317, 6, 8.72),
    (318, 6, 7.08),
    (319, 6, 7.08),
    (320, 6, 0.62);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (321, 6, 6.83),
    (322, 6, 0.81),
    (323, 6, 9.32),
    (324, 6, 6.83),
    (325, 6, 6.83),
    (326, 6, 0.35),
    (327, 6, 6.06),
    (328, 6, 0.57),
    (329, 6, 6.06),
    (330, 6, 7.01);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (331, 6, 7.01),
    (332, 6, 0.54),
    (333, 6, 5.92),
    (334, 6, 0.43),
    (335, 6, 5.92),
    (336, 6, 9.49),
    (337, 6, 6.81),
    (338, 6, 6.88),
    (339, 6, 6.86),
    (340, 6, 6.86);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (341, 6, 6.96),
    (342, 6, 7.11),
    (343, 6, 7.11),
    (344, 6, 0.65),
    (345, 6, 7.13),
    (346, 6, 0.93),
    (347, 6, 7.14),
    (348, 6, 9.6),
    (349, 6, 6.9),
    (350, 6, 6.97);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (351, 6, 6.97),
    (352, 6, 0.5),
    (353, 6, 6.82),
    (354, 6, 0.6),
    (355, 6, 6.82),
    (356, 6, 9.46),
    (357, 6, 6.78),
    (358, 6, 7.51),
    (359, 6, 14.84),
    (360, 6, 6.86);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (361, 6, 0.89),
    (362, 6, 0.37),
    (363, 6, 1.35),
    (364, 6, 0.51),
    (365, 6, 5.58),
    (366, 6, 2.01),
    (367, 6, 9.48),
    (368, 6, 2.51),
    (369, 6, 2.01),
    (370, 6, 5.22);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (371, 6, 0.89),
    (372, 6, 6.88),
    (373, 6, 0.4),
    (374, 6, 7.0),
    (375, 6, 7.0),
    (376, 6, 8.91),
    (377, 6, 8.91),
    (378, 6, 2.58),
    (379, 6, 9.35),
    (380, 6, 3.24);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (381, 6, 9.37),
    (382, 6, 0.39),
    (383, 6, 6.87),
    (384, 6, 14.11),
    (385, 6, 6.86),
    (386, 6, 6.86),
    (387, 6, 0.38),
    (388, 6, 6.84),
    (389, 6, 4.31),
    (390, 6, 3.25);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (391, 6, 2.71),
    (392, 6, 25.4),
    (393, 6, 7.58),
    (394, 6, 0.76),
    (395, 6, 0.68),
    (396, 6, 0.85),
    (397, 6, 0.68),
    (398, 6, 2.35),
    (399, 6, 2.42),
    (400, 6, 0.7);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (401, 6, 0.64),
    (402, 6, 0.64),
    (403, 6, 0.69),
    (404, 6, 2.3),
    (405, 6, 1.67),
    (406, 6, 2.15),
    (407, 6, 5.2),
    (408, 6, 8.43),
    (409, 6, 14.76),
    (410, 6, 5.29);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (411, 6, 0.0),
    (412, 6, 0.02),
    (413, 6, 7.61),
    (414, 6, 9.5),
    (415, 6, 10.86),
    (416, 6, 18.3),
    (417, 6, 3.2),
    (418, 6, 9.7),
    (419, 6, 10.98),
    (420, 6, 15.84);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (421, 6, 3.29),
    (422, 6, 5.3),
    (423, 6, 11.24),
    (424, 6, 2.97),
    (425, 6, 26.43),
    (426, 6, 16.4),
    (427, 6, 15.07),
    (428, 6, 17.2),
    (429, 6, 1.4),
    (430, 6, 17.2);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (431, 6, 17.2),
    (432, 6, 26.43),
    (433, 6, 26.43),
    (434, 6, 26.43),
    (435, 6, 13.37),
    (436, 6, 22.74),
    (437, 6, 22.74),
    (438, 6, 22.74),
    (439, 6, 11.67),
    (440, 6, 25.3);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (441, 6, 16.03),
    (442, 6, 1.3),
    (443, 6, 8.25),
    (444, 6, 1.4),
    (445, 6, 13.77),
    (446, 6, 4.3),
    (447, 6, 5.0),
    (448, 6, 8.85),
    (449, 6, 3.1),
    (450, 6, 1.11);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (451, 6, 20.4),
    (452, 6, 24.54),
    (453, 6, 24.54),
    (454, 6, 25.0),
    (455, 6, 16.67),
    (456, 6, 21.18),
    (457, 6, 21.1),
    (458, 6, 25.09),
    (459, 6, 7.14),
    (460, 6, 31.72);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (461, 6, 15.26),
    (462, 6, 15.26),
    (463, 6, 15.26),
    (464, 6, 7.59),
    (465, 6, 15.26),
    (466, 6, 15.26),
    (467, 6, 15.26),
    (468, 6, 13.37),
    (469, 6, 15.84),
    (470, 6, 15.84);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (471, 6, 0.87),
    (472, 6, 2.3),
    (473, 6, 2.3),
    (474, 6, 19.24),
    (475, 6, 6.41),
    (476, 6, 15.2),
    (477, 6, 15.14),
    (478, 6, 0.11),
    (479, 6, 2.06),
    (480, 6, 1.7);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (481, 6, 31.72),
    (482, 6, 0.01),
    (483, 6, 0.2),
    (484, 6, 0.92),
    (485, 6, 1.7),
    (486, 6, 1.0),
    (487, 6, 2.74),
    (488, 6, 3.97),
    (489, 6, 1.0),
    (490, 6, 2.54);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (491, 6, 2.33),
    (492, 6, 2.63),
    (493, 6, 1.09),
    (494, 6, 2.63),
    (495, 6, 3.25),
    (496, 6, 4.75),
    (497, 6, 2.71),
    (498, 6, 4.21),
    (499, 6, 1.3),
    (500, 6, 3.72);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (501, 6, 3.04),
    (502, 6, 5.4),
    (503, 6, 2.6),
    (504, 6, 4.98),
    (505, 6, 1.25),
    (506, 6, 3.45),
    (507, 6, 1.19),
    (508, 6, 3.4),
    (509, 6, 1.28),
    (510, 6, 0.46);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (511, 6, 5.42),
    (512, 6, 1.91),
    (513, 6, 5.42),
    (514, 6, 0.28),
    (515, 6, 0.28),
    (516, 6, 3.12),
    (517, 6, 2.61),
    (518, 6, 2.12),
    (519, 6, 2.77),
    (520, 6, 0.28);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (521, 6, 1.11),
    (522, 6, 3.41),
    (523, 6, 3.0),
    (524, 6, 2.6),
    (525, 6, 3.12),
    (526, 6, 1.11),
    (527, 6, 2.31),
    (528, 6, 0.26),
    (529, 6, 0.08),
    (530, 6, 0.45);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (531, 6, 0.45),
    (532, 6, 2.43),
    (533, 6, 0.19),
    (534, 6, 3.08),
    (535, 6, 0.34),
    (536, 6, 3.08),
    (537, 6, 0.16),
    (538, 6, 0.88),
    (539, 6, 2.14),
    (540, 6, 2.14);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (541, 6, 3.24),
    (542, 6, 2.72),
    (543, 6, 6.3),
    (544, 6, 0.24),
    (545, 6, 5.07),
    (546, 6, 0.24),
    (547, 6, 0.16),
    (548, 6, 6.6),
    (549, 6, 6.36),
    (550, 6, 2.19);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (551, 6, 2.17),
    (552, 6, 6.43),
    (553, 6, 6.67),
    (554, 6, 6.13),
    (555, 6, 0.96),
    (556, 6, 0.3),
    (557, 6, 1.3),
    (558, 6, 0.89),
    (559, 6, 0.68),
    (560, 6, 0.96);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (561, 6, 0.27),
    (562, 6, 4.04),
    (563, 6, 4.26),
    (564, 6, 15.87),
    (565, 6, 11.66),
    (566, 6, 11.28),
    (567, 6, 4.54),
    (568, 6, 2.15),
    (569, 6, 2.11),
    (570, 6, 5.11);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (571, 6, 2.25),
    (572, 6, 5.24),
    (573, 6, 6.55),
    (574, 6, 1.3),
    (575, 6, 2.99),
    (576, 6, 1.15),
    (577, 6, 2.07),
    (578, 6, 0.98),
    (579, 6, 1.4),
    (580, 6, 0.72);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (581, 6, 1.96),
    (582, 6, 2.64),
    (583, 6, 4.57),
    (584, 6, 5.19),
    (585, 6, 3.86),
    (586, 6, 2.87),
    (587, 6, 3.33),
    (588, 6, 4.57),
    (589, 6, 3.99),
    (590, 6, 1.31);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (591, 6, 3.29),
    (592, 6, 4.17),
    (593, 6, 0.31),
    (594, 6, 0.14),
    (595, 6, 0.1),
    (596, 6, 0.86),
    (597, 6, 0.3),
    (598, 6, 0.2),
    (599, 6, 0.14),
    (600, 6, 0.04);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (601, 6, 0.03),
    (602, 6, 0.04),
    (603, 6, 0.31),
    (604, 6, 0.34),
    (605, 6, 0.21),
    (606, 6, 0.24),
    (607, 6, 0.15),
    (608, 6, 0.17),
    (609, 6, 0.16),
    (610, 6, 0.17);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (611, 6, 0.1),
    (612, 6, 3.08),
    (613, 6, 0.39),
    (614, 6, 0.17),
    (615, 6, 14.66),
    (616, 6, 0.28),
    (617, 6, 3.21),
    (618, 6, 0.18),
    (619, 6, 0.16),
    (620, 6, 0.33);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (621, 6, 0.21),
    (622, 6, 0.19),
    (623, 6, 0.14),
    (624, 6, 0.19),
    (625, 6, 0.21),
    (626, 6, 0.3),
    (627, 6, 0.24),
    (628, 6, 0.95),
    (629, 6, 0.44),
    (630, 6, 0.44);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (631, 6, 0.14),
    (632, 6, 0.38),
    (633, 6, 0.3),
    (634, 6, 0.38),
    (635, 6, 0.28),
    (636, 6, 0.26),
    (637, 6, 0.21),
    (638, 6, 0.7),
    (639, 6, 0.27),
    (640, 6, 0.09);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (641, 6, 0.08),
    (642, 6, 0.1),
    (643, 6, 0.27),
    (644, 6, 0.15),
    (645, 6, 0.23),
    (646, 6, 0.06),
    (647, 6, 0.05),
    (648, 6, 0.07),
    (649, 6, 0.19),
    (650, 6, 0.28);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (651, 6, 0.23),
    (652, 6, 1.17),
    (653, 6, 0.22),
    (654, 6, 0.6),
    (655, 6, 0.15),
    (656, 6, 0.25),
    (657, 6, 0.34),
    (658, 6, 0.49),
    (659, 6, 0.43),
    (660, 6, 0.31);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (661, 6, 0.4),
    (662, 6, 0.64),
    (663, 6, 0.13),
    (664, 6, 0.15),
    (665, 6, 0.19),
    (666, 6, 0.19),
    (667, 6, 0.22),
    (668, 6, 0.26),
    (669, 6, 0.11),
    (670, 6, 0.98);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (671, 6, 0.21),
    (672, 6, 0.19),
    (673, 6, 0.08),
    (674, 6, 0.07),
    (675, 6, 0.09),
    (676, 6, 0.23),
    (677, 6, 14.24),
    (678, 6, 2.15),
    (679, 6, 6.69),
    (680, 6, 20.68);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (681, 6, 10.62),
    (682, 6, 8.67),
    (683, 6, 19.48),
    (684, 6, 6.34),
    (685, 6, 6.48),
    (686, 6, 20.26),
    (687, 6, 10.37),
    (688, 6, 8.45),
    (689, 6, 19.1),
    (690, 6, 15.02);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (691, 6, 5.79),
    (692, 6, 0.12),
    (693, 6, 0.26),
    (694, 6, 0.12),
    (695, 6, 0.18),
    (696, 6, 0.12),
    (697, 6, 0.6),
    (698, 6, 0.2),
    (699, 6, 0.34),
    (700, 6, 0.28);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (701, 6, 0.13),
    (702, 6, 0.15),
    (703, 6, 0.05),
    (704, 6, 0.12),
    (705, 6, 0.29),
    (706, 6, 0.03),
    (707, 6, 0.14),
    (708, 6, 0.15),
    (709, 6, 0.06),
    (710, 6, 0.45);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (711, 6, 0.13),
    (712, 6, 0.11),
    (713, 6, 0.07),
    (714, 6, 0.06),
    (715, 6, 0.57),
    (716, 6, 0.15),
    (717, 6, 0.06),
    (718, 6, 0.01),
    (719, 6, 0.17),
    (720, 6, 0.21);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (721, 6, 0.21),
    (722, 6, 0.21),
    (723, 6, 0.41),
    (724, 6, 1.83),
    (725, 6, 0.23),
    (726, 6, 0.23),
    (727, 6, 0.48),
    (728, 6, 1.84),
    (729, 6, 1.06),
    (730, 6, 0.99);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (731, 6, 0.2),
    (732, 6, 0.0),
    (733, 6, 0.2),
    (734, 6, 0.2),
    (735, 6, 0.33),
    (736, 6, 0.33),
    (737, 6, 0.2),
    (738, 6, 0.1),
    (739, 6, 0.2),
    (740, 6, 0.38);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (741, 6, 0.1),
    (742, 6, 0.1),
    (743, 6, 0.0),
    (744, 6, 0.1),
    (745, 6, 0.0),
    (746, 6, 0.1),
    (747, 6, 1.48),
    (748, 6, 0.98),
    (749, 6, 4.0),
    (750, 6, 3.71);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (751, 6, 0.93),
    (752, 6, 0.93),
    (753, 6, 1.02),
    (754, 6, 9.63),
    (755, 6, 14.34),
    (756, 6, 9.63),
    (757, 6, 10.36),
    (758, 6, 9.79),
    (759, 6, 9.6),
    (760, 6, 10.98);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (761, 6, 11.58),
    (762, 6, 4.07),
    (763, 6, 2.82),
    (764, 6, 2.78),
    (765, 6, 5.01),
    (766, 6, 4.07),
    (767, 6, 7.28),
    (768, 6, 3.78),
    (769, 6, 4.07),
    (770, 6, 7.22);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (771, 6, 6.3),
    (772, 6, 1.89),
    (773, 6, 6.7),
    (774, 6, 6.7),
    (775, 6, 9.62),
    (776, 6, 5.88),
    (777, 6, 5.01),
    (778, 6, 8.12),
    (779, 6, 4.53),
    (780, 6, 11.35);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (781, 6, 9.4),
    (782, 6, 4.46),
    (783, 6, 4.32),
    (784, 6, 4.46),
    (785, 6, 7.91),
    (786, 6, 3.46),
    (787, 6, 4.42),
    (788, 6, 2.35),
    (789, 6, 1.74),
    (790, 6, 3.22);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (791, 6, 11.45),
    (792, 6, 11.14),
    (793, 6, 3.65),
    (794, 6, 3.49),
    (795, 6, 3.65),
    (796, 6, 7.53),
    (797, 6, 2.47),
    (798, 6, 3.56),
    (799, 6, 1.2),
    (800, 6, 0.58);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (801, 6, 10.8),
    (802, 6, 6.34),
    (803, 6, 3.39),
    (804, 6, 3.29),
    (805, 6, 4.71),
    (806, 6, 6.43),
    (807, 6, 0.35),
    (808, 6, 3.24),
    (809, 6, 0.35),
    (810, 6, 2.88);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (811, 6, 2.53),
    (812, 6, 3.03),
    (813, 6, 13.94),
    (814, 6, 2.95),
    (815, 6, 2.99),
    (816, 6, 0.13),
    (817, 6, 2.87),
    (818, 6, 0.49),
    (819, 6, 3.15),
    (820, 6, 0.2);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (821, 6, 2.95),
    (822, 6, 0.61),
    (823, 6, 0.65),
    (824, 6, 0.41),
    (825, 6, 3.37),
    (826, 6, 3.37),
    (827, 6, 2.94),
    (828, 6, 3.76),
    (829, 6, 2.99),
    (830, 6, 3.3);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (831, 6, 2.58),
    (832, 6, 0.7),
    (833, 6, 3.47),
    (834, 6, 0.7),
    (835, 6, 3.47),
    (836, 6, 2.72),
    (837, 6, 0.97),
    (838, 6, 0.71),
    (839, 6, 3.4),
    (840, 6, 3.4);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (841, 6, 3.24),
    (842, 6, 2.82),
    (843, 6, 1.49),
    (844, 6, 1.6),
    (845, 6, 1.21),
    (846, 6, 4.29),
    (847, 6, 4.29),
    (848, 6, 3.72),
    (849, 6, 3.22),
    (850, 6, 0.42);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (851, 6, 0.45),
    (852, 6, 0.25),
    (853, 6, 3.18),
    (854, 6, 3.18),
    (855, 6, 2.79),
    (856, 6, 2.93),
    (857, 6, 0.62),
    (858, 6, 0.7),
    (859, 6, 0.87),
    (860, 6, 0.5);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (861, 6, 4.1),
    (862, 6, 3.26),
    (863, 6, 3.68),
    (864, 6, 3.68),
    (865, 6, 3.39),
    (866, 6, 3.04),
    (867, 6, 3.75),
    (868, 6, 3.03),
    (869, 6, 3.4),
    (870, 6, 2.68);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (871, 6, 6.09),
    (872, 6, 8.64),
    (873, 6, 7.59),
    (874, 6, 7.02),
    (875, 6, 4.33),
    (876, 6, 3.51),
    (877, 6, 0.23),
    (878, 6, 0.42),
    (879, 6, 2.77),
    (880, 6, 2.77);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (881, 6, 2.95),
    (882, 6, 0.1),
    (883, 6, 2.84),
    (884, 6, 2.74),
    (885, 6, 2.88),
    (886, 6, 0.34),
    (887, 6, 4.66),
    (888, 6, 0.35),
    (889, 6, 0.12),
    (890, 6, 3.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (891, 6, 3.0),
    (892, 6, 2.66),
    (893, 6, 3.37),
    (894, 6, 2.62),
    (895, 6, 3.02),
    (896, 6, 2.3),
    (897, 6, 3.77),
    (898, 6, 3.6),
    (899, 6, 12.88),
    (900, 6, 0.76);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (901, 6, 3.42),
    (902, 6, 4.54),
    (903, 6, 0.24),
    (904, 6, 4.67),
    (905, 6, 0.36),
    (906, 6, 0.47),
    (907, 6, 0.19),
    (908, 6, 3.38),
    (909, 6, 2.63),
    (910, 6, 3.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (911, 6, 3.0),
    (912, 6, 3.0),
    (913, 6, 2.74),
    (914, 6, 3.36),
    (915, 6, 2.64),
    (916, 6, 3.1),
    (917, 6, 2.38),
    (918, 6, 2.78),
    (919, 6, 0.14),
    (920, 6, 2.69);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (921, 6, 3.05),
    (922, 6, 2.33),
    (923, 6, 0.39),
    (924, 6, 0.37),
    (925, 6, 0.5),
    (926, 6, 3.03),
    (927, 6, 3.03),
    (928, 6, 2.9),
    (929, 6, 3.03),
    (930, 6, 2.82);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (931, 6, 2.84),
    (932, 6, 0.1),
    (933, 6, 0.35),
    (934, 6, 2.88),
    (935, 6, 2.26),
    (936, 6, 4.53),
    (937, 6, 4.53),
    (938, 6, 0.39),
    (939, 6, 4.53),
    (940, 6, 4.53);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (941, 6, 0.39),
    (942, 6, 4.53),
    (943, 6, 3.48),
    (944, 6, 4.35),
    (945, 6, 0.2),
    (946, 6, 4.35),
    (947, 6, 2.56),
    (948, 6, 9.39),
    (949, 6, 9.39),
    (950, 6, 9.42);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (951, 6, 23.93),
    (952, 6, 9.39),
    (953, 6, 9.35),
    (954, 6, 15.6),
    (955, 6, 9.39),
    (956, 6, 4.7),
    (957, 6, 4.97),
    (958, 6, 12.84),
    (959, 6, 0.18),
    (960, 6, 0.41);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (961, 6, 4.68),
    (962, 6, 0.33),
    (963, 6, 0.33),
    (964, 6, 6.8),
    (965, 6, 6.99),
    (966, 6, 0.26),
    (967, 6, 0.18),
    (968, 6, 0.69),
    (969, 6, 0.34),
    (970, 6, 0.12);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (971, 6, 0.18),
    (972, 6, 0.28),
    (973, 6, 0.17),
    (974, 6, 0.3),
    (975, 6, 0.3),
    (976, 6, 0.09),
    (977, 6, 0.28),
    (978, 6, 0.16),
    (979, 6, 0.2),
    (980, 6, 1.35);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (981, 6, 0.18),
    (982, 6, 0.18),
    (983, 6, 0.09),
    (984, 6, 0.1),
    (985, 6, 0.35),
    (986, 6, 0.4),
    (987, 6, 0.12),
    (988, 6, 0.11),
    (989, 6, 0.13),
    (990, 6, 0.45);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (991, 6, 0.1),
    (992, 6, 0.16),
    (993, 6, 0.49),
    (994, 6, 0.2),
    (995, 6, 0.27),
    (996, 6, 0.32),
    (997, 6, 0.1),
    (998, 6, 6.31),
    (999, 6, 20.71),
    (1000, 6, 2.26);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1001, 6, 5.07),
    (1002, 6, 4.33),
    (1003, 6, 0.0),
    (1004, 6, 0.13),
    (1005, 6, 0.42),
    (1006, 6, 0.65),
    (1007, 6, 2.86),
    (1008, 6, 2.86),
    (1009, 6, 2.95),
    (1010, 6, 3.18);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1011, 6, 3.25),
    (1012, 6, 2.48),
    (1013, 6, 3.31),
    (1014, 6, 2.59),
    (1015, 6, 3.54),
    (1016, 6, 2.82),
    (1017, 6, 2.94),
    (1018, 6, 0.34),
    (1019, 6, 2.88),
    (1020, 6, 2.86);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1021, 6, 4.6),
    (1022, 6, 0.29),
    (1023, 6, 0.17),
    (1024, 6, 0.39),
    (1025, 6, 2.93),
    (1026, 6, 2.93),
    (1027, 6, 2.71),
    (1028, 6, 2.93),
    (1029, 6, 3.31),
    (1030, 6, 2.56);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1031, 6, 3.07),
    (1032, 6, 2.35),
    (1033, 6, 3.29),
    (1034, 6, 2.57),
    (1035, 6, 0.46),
    (1036, 6, 3.0),
    (1037, 6, 3.36),
    (1038, 6, 2.64),
    (1039, 6, 12.86),
    (1040, 6, 2.71);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1041, 6, 6.93),
    (1042, 6, 0.18),
    (1043, 6, 0.14),
    (1044, 6, 2.69),
    (1045, 6, 2.82),
    (1046, 6, 2.69),
    (1047, 6, 2.79),
    (1048, 6, 2.72),
    (1049, 6, 2.77),
    (1050, 6, 2.96);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1051, 6, 0.31),
    (1052, 6, 0.39),
    (1053, 6, 2.96),
    (1054, 6, 2.96),
    (1055, 6, 2.92),
    (1056, 6, 2.89),
    (1057, 6, 0.09),
    (1058, 6, 2.63),
    (1059, 6, 0.29),
    (1060, 6, 0.22);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1061, 6, 2.93),
    (1062, 6, 2.93),
    (1063, 6, 2.76),
    (1064, 6, 3.31),
    (1065, 6, 2.56),
    (1066, 6, 3.12),
    (1067, 6, 2.4),
    (1068, 6, 2.9),
    (1069, 6, 3.22),
    (1070, 6, 2.87);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1071, 6, 5.43),
    (1072, 6, 1.35),
    (1073, 6, 0.67),
    (1074, 6, 1.22),
    (1075, 6, 3.74),
    (1076, 6, 3.85),
    (1077, 6, 3.2),
    (1078, 6, 3.74),
    (1079, 6, 4.21),
    (1080, 6, 3.5);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1081, 6, 3.55),
    (1082, 6, 2.84),
    (1083, 6, 4.1),
    (1084, 6, 3.38),
    (1085, 6, 0.42),
    (1086, 6, 0.83),
    (1087, 6, 3.55),
    (1088, 6, 3.94),
    (1089, 6, 3.16),
    (1090, 6, 3.2);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1091, 6, 0.19),
    (1092, 6, 2.92),
    (1093, 6, 2.62),
    (1094, 6, 2.75),
    (1095, 6, 2.61),
    (1096, 6, 0.43),
    (1097, 6, 3.6),
    (1098, 6, 3.6),
    (1099, 6, 2.84),
    (1100, 6, 4.05);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1101, 6, 3.16),
    (1102, 6, 0.2),
    (1103, 6, 0.2),
    (1104, 6, 0.24),
    (1105, 6, 2.94),
    (1106, 6, 2.94),
    (1107, 6, 2.78),
    (1108, 6, 2.74),
    (1109, 6, 2.84),
    (1110, 6, 3.18);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1111, 6, 3.17),
    (1112, 6, 4.72),
    (1113, 6, 0.42),
    (1114, 6, 0.27),
    (1115, 6, 0.8),
    (1116, 6, 2.81),
    (1117, 6, 3.06),
    (1118, 6, 2.81),
    (1119, 6, 3.33),
    (1120, 6, 3.43);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1121, 6, 2.68),
    (1122, 6, 3.17),
    (1123, 6, 2.45),
    (1124, 6, 3.69),
    (1125, 6, 2.97),
    (1126, 6, 0.38),
    (1127, 6, 3.56),
    (1128, 6, 4.0),
    (1129, 6, 3.11),
    (1130, 6, 2.76);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1131, 6, 2.78),
    (1132, 6, 2.9),
    (1133, 6, 2.71),
    (1134, 6, 2.53),
    (1135, 6, 0.21),
    (1136, 6, 0.38),
    (1137, 6, 2.85),
    (1138, 6, 2.85),
    (1139, 6, 2.91),
    (1140, 6, 0.49);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1141, 6, 3.06),
    (1142, 6, 0.35),
    (1143, 6, 0.16),
    (1144, 6, 3.33),
    (1145, 6, 3.33),
    (1146, 6, 2.71),
    (1147, 6, 2.6),
    (1148, 6, 3.75),
    (1149, 6, 2.91),
    (1150, 6, 3.06);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1151, 6, 2.35),
    (1152, 6, 2.8),
    (1153, 6, 2.84),
    (1154, 6, 0.09),
    (1155, 6, 2.74),
    (1156, 6, 0.5),
    (1157, 6, 3.04),
    (1158, 6, 0.12),
    (1159, 6, 2.66),
    (1160, 6, 4.74);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1161, 6, 0.15),
    (1162, 6, 0.65),
    (1163, 6, 2.69),
    (1164, 6, 2.69),
    (1165, 6, 3.18),
    (1166, 6, 3.05),
    (1167, 6, 2.33),
    (1168, 6, 3.54),
    (1169, 6, 2.83),
    (1170, 6, 0.45);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1171, 6, 3.2),
    (1172, 6, 3.59),
    (1173, 6, 2.81),
    (1174, 6, 0.47),
    (1175, 6, 3.0),
    (1176, 6, 4.73),
    (1177, 6, 3.64),
    (1178, 6, 0.18),
    (1179, 6, 0.17),
    (1180, 6, 2.71);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1181, 6, 0.34),
    (1182, 6, 2.9),
    (1183, 6, 0.3),
    (1184, 6, 2.84),
    (1185, 6, 1.86),
    (1186, 6, 5.94),
    (1187, 6, 2.21),
    (1188, 6, 12.86),
    (1189, 6, 5.12),
    (1190, 6, 12.82);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1191, 6, 10.5),
    (1192, 6, 4.84),
    (1193, 6, 15.0),
    (1194, 6, 12.91),
    (1195, 6, 12.84),
    (1196, 6, 19.82),
    (1197, 6, 12.88),
    (1198, 6, 4.32),
    (1199, 6, 1.66),
    (1200, 6, 4.71);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1201, 6, 8.94),
    (1202, 6, 0.24),
    (1203, 6, 15.81),
    (1204, 6, 4.77),
    (1205, 6, 5.27),
    (1206, 6, 3.27),
    (1207, 6, 0.25),
    (1208, 6, 0.08),
    (1209, 6, 0.15),
    (1210, 6, 0.91);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1211, 6, 0.25),
    (1212, 6, 0.21),
    (1213, 6, 0.19),
    (1214, 6, 0.5),
    (1215, 6, 0.43),
    (1216, 6, 0.47),
    (1217, 6, 0.41),
    (1218, 6, 0.16),
    (1219, 6, 0.1),
    (1220, 6, 0.3);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1221, 6, 0.17),
    (1222, 6, 10.9),
    (1223, 6, 15.32),
    (1224, 6, 10.9),
    (1225, 6, 12.9),
    (1226, 6, 30.05),
    (1227, 6, 0.12),
    (1228, 6, 0.4),
    (1229, 6, 0.38),
    (1230, 6, 0.43);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1231, 6, 12.91),
    (1232, 6, 0.1),
    (1233, 6, 0.42),
    (1234, 6, 0.21),
    (1235, 6, 0.1),
    (1236, 6, 0.28),
    (1237, 6, 0.37),
    (1238, 6, 0.63),
    (1239, 6, 4.76),
    (1240, 6, 4.47);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1241, 6, 4.72),
    (1242, 6, 1.87),
    (1243, 6, 0.4),
    (1244, 6, 0.4),
    (1245, 6, 0.45),
    (1246, 6, 0.5),
    (1247, 6, 2.05),
    (1248, 6, 1.6),
    (1249, 6, 0.25),
    (1250, 6, 0.1);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1251, 6, 0.2),
    (1252, 6, 0.2),
    (1253, 6, 0.2),
    (1254, 6, 0.1),
    (1255, 6, 0.1),
    (1256, 6, 0.1),
    (1257, 6, 0.1),
    (1258, 6, 0.1),
    (1259, 6, 0.25),
    (1260, 6, 0.25);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1261, 6, 0.5),
    (1262, 6, 1.08),
    (1263, 6, 0.43),
    (1264, 6, 0.43),
    (1265, 6, 2.08),
    (1266, 6, 3.34),
    (1267, 6, 1.4),
    (1268, 6, 2.18),
    (1269, 6, 1.41),
    (1270, 6, 11.33);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1271, 6, 22.82),
    (1272, 6, 0.01),
    (1273, 6, 20.45),
    (1274, 6, 0.24),
    (1275, 6, 0.18),
    (1276, 6, 0.0),
    (1277, 6, 0.18),
    (1278, 6, 0.06),
    (1279, 6, 0.0),
    (1280, 6, 0.07);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1281, 6, 0.7),
    (1282, 6, 0.0),
    (1283, 6, 2.79),
    (1284, 6, 0.1),
    (1285, 6, 0.02),
    (1286, 6, 0.0),
    (1287, 6, 0.1),
    (1288, 6, 0.11),
    (1289, 6, 0.01),
    (1290, 6, 0.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1291, 6, 0.07),
    (1292, 6, 0.0),
    (1293, 6, 0.0),
    (1294, 6, 0.07),
    (1295, 6, 0.0),
    (1296, 6, 0.0),
    (1297, 6, 0.1),
    (1298, 6, 0.0),
    (1299, 6, 0.1),
    (1300, 6, 0.0);

INSERT INTO
    public.food_nutritions (f_id, n_id, value)
VALUES (1301, 6, 0.14),
    (1302, 6, 0.0),
    (1303, 6, 0.07),
    (1304, 6, 0.0),
    (1305, 6, 0.0),
    (1306, 6, 0.0),
    (1307, 6, 0.12),
    (1308, 6, 0.0),
    (1309, 6, 0.0),
    (1310, 6, 0.83);