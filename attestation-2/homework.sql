----- 1 -----
select * from bookings.flights fl
join bookings.airports ap on ap.airport_code = fl.departure_airport;

select * from bookings.flights fl
left join bookings.airports ap on ap.airport_code = fl.departure_airport;

select * from bookings.flights fl
right join bookings.airports ap on ap.airport_code = fl.departure_airport;

select * from bookings.flights fl
cross join bookings.airports;

select flight_id, flight_no, departure_airport, status, aircraft_code, null as "airport name", null as "city" from bookings.flights
UNION
select null, null, null,null,null, airport_name, city from bookings.airports;

----- 2 -----
select * from bookings.flights flight
where status in ('Arrival', 'Delayed')
order by flight.scheduled_departure
limit 10;

----- 3 -----
select ports.airport_name, count(*) as total_arrival_count from bookings.flights f
left join bookings.ticket_flights tf on tf.flight_id = f.flight_id
left join bookings.aircrafts air on air.aircraft_code = f.aircraft_code
left join bookings.airports ports on ports.airport_code = f.arrival_airport
WHERE f.actual_arrival BETWEEN '2016-09-01 00:00:00' and '2016-09-30 23:59:59'
GROUP BY ports.airport_name
ORDER BY total_arrival_count DESC;

----- 4 -----
select b.book_date, b.total_amount, t.ticket_no, tf.fare_conditions, f.scheduled_departure, f.status from bookings.bookings b
inner join bookings.tickets t on b.book_ref = t.book_ref
left join bookings.ticket_flights tf on tf.ticket_no = t.ticket_no
right join bookings.flights f on f.flight_id = tf.flight_id

----- 5 -----

CREATE VIEW bookings.flights_arrival_delayed AS
select * from bookings.flights flight
where status in ('Arrival', 'Delayed')
order by flight.scheduled_departure
limit 10;
