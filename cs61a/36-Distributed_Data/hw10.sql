CREATE TABLE parents AS
  SELECT "abraham" AS parent, "barack" AS child UNION
  SELECT "abraham"          , "clinton"         UNION
  SELECT "delano"           , "herbert"         UNION
  SELECT "fillmore"         , "abraham"         UNION
  SELECT "fillmore"         , "delano"          UNION
  SELECT "fillmore"         , "grover"          UNION
  SELECT "eisenhower"       , "fillmore";

CREATE TABLE dogs AS
  SELECT "abraham" AS name, "long" AS fur, 26 AS height UNION
  SELECT "barack"         , "short"      , 52           UNION
  SELECT "clinton"        , "long"       , 47           UNION
  SELECT "delano"         , "long"       , 46           UNION
  SELECT "eisenhower"     , "short"      , 35           UNION
  SELECT "fillmore"       , "curly"      , 32           UNION
  SELECT "grover"         , "short"      , 28           UNION
  SELECT "herbert"        , "curly"      , 31;

CREATE TABLE sizes AS
  SELECT "toy" AS size, 24 AS min, 28 AS max UNION
  SELECT "mini"       , 28       , 35        UNION
  SELECT "medium"     , 35       , 45        UNION
  SELECT "standard"   , 45       , 60;

-------------------------------------------------------------
-- PLEASE DO NOT CHANGE ANY SQL STATEMENTS ABOVE THIS LINE --
-------------------------------------------------------------

-- The size of each dog
CREATE TABLE size_of_dogs AS
  SELECT name, size from dogs, sizes where height>min and height<=max; -- 做一个join即可。

-- All dogs with parents ordered by decreasing height of their parent
CREATE TABLE by_parent_height AS
  SELECT child from parents, dogs where parent==dogs.name order by height desc;

-- Filling out this helper table is optional
CREATE TABLE siblings AS
  SELECT d1.name as d1n, d2.name as d2n, size from dogs as d1, dogs as d2, sizes where d1.name<d2.name and d1.height>min and d1.height<=max and d2.height>min and d2.height<=max;

-- Sentences about siblings that are the same size
CREATE TABLE sentences AS
  SELECT d1n || " and " || d2n || " are " || size || " siblings" from siblings limit 2;

-- Ways to stack 4 dogs to a height of at least 170, ordered by total height
CREATE TABLE stacks_helper(dogs, stack_height, last_height);

-- Add your INSERT INTOs here
INSERT INTO stacks_helper(dogs, stack_height, last_height)
  SELECT name, height, height from dogs;
INSERT INTO stacks_helper(dogs, stack_height, last_height)
  SELECT dogs || ", " || name, stack_height+height, height from dogs, stacks_helper where height>last_height;
INSERT INTO stacks_helper(dogs, stack_height, last_height)
  SELECT dogs || ", " || name, stack_height+height, height from dogs, stacks_helper where height>last_height;
INSERT INTO stacks_helper(dogs, stack_height, last_height)
  SELECT dogs || ", " || name, stack_height+height, height from dogs, stacks_helper where height>last_height;

CREATE TABLE stacks AS
  SELECT dogs, stack_height from stacks_helper where stack_height>=170 order by stack_height asc;
