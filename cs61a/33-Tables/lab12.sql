.read fa19data.sql

CREATE TABLE obedience AS
  SELECT seven, instructor from students;

CREATE TABLE smallest_int AS
  SELECT time, smallest from students where smallest>2 order by smallest;

CREATE TABLE matchmaker AS
  SELECT s1.pet, s1.song, s1.color, s2.color from students AS s1, students AS s2 where s1.time<s2.time AND s1.pet==s2.pet AND s1.song==s2.song;

