create table students(
    id SERIAL primary key,
    name text, total_score integer default 0
);

create table activity_scores (
    student_id integer,
    activity_type text,
    score integer,
    CONSTRAINT activity_scores_student_id FOREIGN KEY(student_id) REFERENCES students(id)
);

CREATE OR REPLACE FUNCTION update_total_score(student_id integer)
    returns void AS
$$
DECLARE

    activity_scores_row activity_scores%ROWTYPE;
    cursor CURSOR (id integer) FOR SELECT *
                                   FROM activity_scores
                                   where activity_scores.student_id = id;
    score               integer;
BEGIN
    score := 0;
    OPEN cursor(student_id);
    LOOP
        FETCH cursor INTO activity_scores_row;
        EXIT WHEN NOT FOUND;
        score := score + activity_scores_row.score;
    END LOOP;
    CLOSE cursor;
    UPDATE students set total_score = score where id = student_id;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION update_total_score_trigger_function()
RETURNS TRIGGER AS $$
DECLARE student_id students.id%TYPE;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        student_id = OLD.student_id;
    ELSE
        student_id = NEW.student_id;
    END IF;
    PERFORM update_total_score(student_id);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER update_total_score_trigger
AFTER INSERT OR UPDATE OR DELETE ON activity_scores
FOR EACH ROW
EXECUTE FUNCTION update_total_score_trigger_function()

insert into students(name)
values ('Сергей'),
       ('Иван'),
       ('Дарья'),
       ('Антон'),
       ('Юлия');

insert into activity_scores values
    (1, 'футбол', 1),
    (1, 'Прогулка', 1),
    (1, 'Бег', 1),
    (1, 'Кино', 2),
    (1, 'Театр', 1),
    (2, 'футбол', 3),
    (2, 'Прогулка', 1),
    (2, 'Бег', 4),
    (2, 'Кино', 1),
    (2, 'Театр', 6),
    (3, 'футбол', 3),
    (3, 'Прогулка', 2),
    (3, 'Бег', 6),
    (3, 'Кино', 8),
    (3, 'Театр', 3),
    (4, 'футбол', 3),
    (4, 'Прогулка', 2),
    (4, 'Бег', 6),
    (4, 'Кино', 8),
    (4, 'Театр', 3),
    (5, 'футбол', 3),
    (5, 'Прогулка', 2),
    (5, 'Бег', 1),
    (5, 'Кино', 2),
    (5, 'Театр', 3);

delete from activity_scores where student_id=1 and activity_type = 'футбол';

----- 2 -----

ALTER TABLE students ADD COLUMN scholarship integer default 0;

CREATE OR REPLACE FUNCTION calculate_scholarship(score integer)
    RETURNS integer AS
$$
DECLARE
    scholarship integer;
BEGIN
    IF score >= 90 THEN
        scholarship = 1000;
    ELSEIF score >= 80 AND score < 90 THEN
        scholarship = 500;
    ELSE
        scholarship = 0;
    END IF;
    RETURN scholarship;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calculate_scholarship_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
       NEW.scholarship = calculate_scholarship(NEW.total_score);
    ELSEIF (NEW.total_score != OLD.total_score) THEN
        NEW.scholarship = calculate_scholarship(NEW.total_score);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER calculate_scholarship_trigger
BEFORE INSERT OR UPDATE ON students
FOR EACH ROW
EXECUTE FUNCTION calculate_scholarship_trigger_function()

insert into activity_scores values
    (1, 'Театр', 90),
    (2, 'Театр', 80),
    (3, 'Театр', 70),
    (4, 'Театр',60),
    (5, 'Театр', 50);
