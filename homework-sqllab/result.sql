-- a --
select name, telegram_contact
from student
where city in ('Казань', 'Москва')
order by name desc;

-- b --
select 'университет: ' || name || '; количество студентов: ' || size as "Полная информауия"
from college
order by name;

-- c --
select name, size
from college
where id in (10, 30, 50)
order by size, name;

-- d --
select name, size
from college
where id not in (10, 30, 50)
order by size, name;

-- e --
select name, amount_of_students
from course
where amount_of_students between 27 and 310
order by name desc, amount_of_students desc;

-- f --
select name
from course
union
select name
from student
order by name desc;

-- g --
select name, 'университет' as "object_type"
from college
union
select name, 'курс'
from course
order by object_type desc, name;

-- h --
select name, amount_of_students
from course
order by CASE
             WHEN amount_of_students = 300 THEN 0
             ELSE amount_of_students
             END
limit 3;

-- i --
insert into course(id, name, amount_of_students, college_id)
values (60, 'MachineLearning', 17, (select college_id from course where name = 'Data Mining'));

-- j --
(select id from course except select id from student_on_course)
union
(select id from student_on_course except select id from course)
order by id;

-- k --
select student.name                     as "student_name",
       course.name                      as "course_name",
       college.name                     as "student_college",
       student_on_course.student_rating as "student_rating"
from student_on_course
         join student on student_on_course.student_id = student.id
         join college on student.college_id = college.id
         join course on student_on_course.course_id = course.id
where student_rating > 50
  and college.size > 5000
order by student_name, course_name;

-- l --
select case
           when student_rating < 30 then 'неудовлетворительно'
           when student_rating >= 30 and student_rating < 60 then 'удовлетворительно'
           when student_rating >= 60 and student_rating < 85 then 'хорошо'
           else 'отлично'
           end  as "оценка",
       count(*) as "количество студентов"
from student_on_course
group by "оценка"
order by "количество студентов";

-- m --
select course.name as "курс",
       case
           when student_rating < 30 then 'неудовлетворительно'
           when student_rating >= 30 and student_rating < 60 then 'удовлетворительно'
           when student_rating >= 60 and student_rating < 85 then 'хорошо'
           else 'отлично'
           end     as "оценка",
       count(*)    as "количество студентов"
from student_on_course
         join course on student_on_course.course_id = course.id
group by "курс", "оценка"
order by "курс", "количество студентов";

-- n --
select names[2] as "student_1", names[1] as "student_2", city
from (select array_agg(name) as names, city
      from student
      group by city) _
where names[2] is not null
  and names[1] is not null
order by student_1
