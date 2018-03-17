CREATE TABLE lists(
  id serial PRIMARY KEY,
  name text NOT NULL UNIQUE 
);

CREATE TABLE todos(
  id serial PRIMARY KEY,
  task text NOT NULL,
  completed boolean NOT NULL DEFAULT false,
  list_id NOT NULL REFERENCES lists (id)
);
