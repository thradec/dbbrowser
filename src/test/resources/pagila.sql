--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -;
--

COMMENT ON SCHEMA public IS 'Standard public schema';


SET search_path = public, pg_catalog;

--
-- Name: actor_actor_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE actor_actor_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: actor; Type: TABLE; Schema: public;; Tablespace:
--

CREATE TABLE actor (
    actor_id integer DEFAULT nextval('actor_actor_id_seq'::regclass) NOT NULL,
    first_name character varying(45) NOT NULL,
    last_name character varying(45) NOT NULL,
    last_update timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: mpaa_rating; Type: TYPE; Schema: public;
--

CREATE TYPE mpaa_rating AS ENUM (
    'G',
    'PG',
    'PG-13',
    'R',
    'NC-17'
);


--
-- Name: year; Type: DOMAIN; Schema: public;
--

CREATE DOMAIN year AS integer
	CONSTRAINT year_check CHECK (((VALUE >= 1901) AND (VALUE <= 2155)));


--
-- Name: _group_concat(text, text); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION _group_concat(text, text) RETURNS text
    AS $_$
SELECT CASE
  WHEN $2 IS NULL THEN $1
  WHEN $1 IS NULL THEN $2
  ELSE $1 || ', ' || $2
END
$_$
    LANGUAGE sql IMMUTABLE;


--
-- Name: group_concat(text); Type: AGGREGATE; Schema: public;
--

CREATE AGGREGATE group_concat(text) (
    SFUNC = _group_concat,
    STYPE = text
);


--
-- Name: category_category_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE category_category_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: category; Type: TABLE; Schema: public;; Tablespace:
--

CREATE TABLE category (
    category_id integer DEFAULT nextval('category_category_id_seq'::regclass) NOT NULL,
    name character varying(25) NOT NULL,
    last_update timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: film_film_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE film_film_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: film; Type: TABLE; Schema: public;; Tablespace:
--

CREATE TABLE film (
    film_id integer DEFAULT nextval('film_film_id_seq'::regclass) NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    release_year year,
    language_id smallint NOT NULL,
    original_language_id smallint,
    rental_duration smallint DEFAULT 3 NOT NULL,
    rental_rate numeric(4,2) DEFAULT 4.99 NOT NULL,
    length smallint,
    replacement_cost numeric(5,2) DEFAULT 19.99 NOT NULL,
    rating mpaa_rating DEFAULT 'G'::mpaa_rating,
    last_update timestamp without time zone DEFAULT now() NOT NULL,
    special_features text[],
    fulltext tsvector NOT NULL
);


--
-- Name: film_actor; Type: TABLE; Schema: public;; Tablespace:
--

CREATE TABLE film_actor (
    actor_id smallint NOT NULL,
    film_id smallint NOT NULL,
    last_update timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: film_category; Type: TABLE; Schema: public;; Tablespace:
--

CREATE TABLE film_category (
    film_id smallint NOT NULL,
    category_id smallint NOT NULL,
    last_update timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: actor_info; Type: VIEW; Schema: public;
--

CREATE VIEW actor_info AS
    SELECT a.actor_id, a.first_name, a.last_name, group_concat(DISTINCT (((c.name)::text || ': '::text) || (SELECT group_concat((f.title)::text) AS group_concat FROM ((film f JOIN film_category fc ON ((f.film_id = fc.film_id))) JOIN film_actor fa ON ((f.film_id = fa.film_id))) WHERE ((fc.category_id = c.category_id) AND (fa.actor_id = a.actor_id)) GROUP BY fa.actor_id))) AS film_info FROM (((actor a LEFT JOIN film_actor fa ON ((a.actor_id = fa.actor_id))) LEFT JOIN film_category fc ON ((fa.film_id = fc.film_id))) LEFT JOIN category c ON ((fc.category_id = c.category_id))) GROUP BY a.actor_id, a.first_name, a.last_name;


--
-- Name: address_address_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE address_address_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: address; Type: TABLE; Schema: public;; Tablespace:
--

CREATE TABLE address (
    address_id integer DEFAULT nextval('address_address_id_seq'::regclass) NOT NULL,
    address character varying(50) NOT NULL,
    address2 character varying(50),
    district character varying(20) NOT NULL,
    city_id smallint NOT NULL,
    postal_code character varying(10),
    phone character varying(20) NOT NULL,
    last_update timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: city_city_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE city_city_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: city; Type: TABLE; Schema: public;; Tablespace:
--

CREATE TABLE city (
    city_id integer DEFAULT nextval('city_city_id_seq'::regclass) NOT NULL,
    city character varying(50) NOT NULL,
    country_id smallint NOT NULL,
    last_update timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: country_country_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE country_country_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: country; Type: TABLE; Schema: public;; Tablespace:
--

CREATE TABLE country (
    country_id integer DEFAULT nextval('country_country_id_seq'::regclass) NOT NULL,
    country character varying(50) NOT NULL,
    last_update timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: customer_customer_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE customer_customer_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: customer; Type: TABLE; Schema: public;; Tablespace:
--

CREATE TABLE customer (
    customer_id integer DEFAULT nextval('customer_customer_id_seq'::regclass) NOT NULL,
    store_id smallint NOT NULL,
    first_name character varying(45) NOT NULL,
    last_name character varying(45) NOT NULL,
    email character varying(50),
    address_id smallint NOT NULL,
    activebool boolean DEFAULT true NOT NULL,
    create_date date DEFAULT ('now'::text)::date NOT NULL,
    last_update timestamp without time zone DEFAULT now(),
    active integer
);


--
-- Name: customer_list; Type: VIEW; Schema: public;
--

CREATE VIEW customer_list AS
    SELECT cu.customer_id AS id, (((cu.first_name)::text || ' '::text) || (cu.last_name)::text) AS name, a.address, a.postal_code AS "zip code", a.phone, city.city, country.country, CASE WHEN cu.activebool THEN 'active'::text ELSE ''::text END AS notes, cu.store_id AS sid FROM (((customer cu JOIN address a ON ((cu.address_id = a.address_id))) JOIN city ON ((a.city_id = city.city_id))) JOIN country ON ((city.country_id = country.country_id)));


--
-- Name: film_list; Type: VIEW; Schema: public;
--

CREATE VIEW film_list AS
    SELECT film.film_id AS fid, film.title, film.description, category.name AS category, film.rental_rate AS price, film.length, film.rating, group_concat((((actor.first_name)::text || ' '::text) || (actor.last_name)::text)) AS actors FROM ((((category LEFT JOIN film_category ON ((category.category_id = film_category.category_id))) LEFT JOIN film ON ((film_category.film_id = film.film_id))) JOIN film_actor ON ((film.film_id = film_actor.film_id))) JOIN actor ON ((film_actor.actor_id = actor.actor_id))) GROUP BY film.film_id, film.title, film.description, category.name, film.rental_rate, film.length, film.rating;


--
-- Name: inventory_inventory_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE inventory_inventory_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: inventory; Type: TABLE; Schema: public;; Tablespace:
--

CREATE TABLE inventory (
    inventory_id integer DEFAULT nextval('inventory_inventory_id_seq'::regclass) NOT NULL,
    film_id smallint NOT NULL,
    store_id smallint NOT NULL,
    last_update timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: language_language_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE language_language_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: language; Type: TABLE; Schema: public;; Tablespace:
--

CREATE TABLE language (
    language_id integer DEFAULT nextval('language_language_id_seq'::regclass) NOT NULL,
    name character(20) NOT NULL,
    last_update timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: nicer_but_slower_film_list; Type: VIEW; Schema: public;
--

CREATE VIEW nicer_but_slower_film_list AS
    SELECT film.film_id AS fid, film.title, film.description, category.name AS category, film.rental_rate AS price, film.length, film.rating, group_concat((((upper("substring"((actor.first_name)::text, 1, 1)) || lower("substring"((actor.first_name)::text, 2))) || upper("substring"((actor.last_name)::text, 1, 1))) || lower("substring"((actor.last_name)::text, 2)))) AS actors FROM ((((category LEFT JOIN film_category ON ((category.category_id = film_category.category_id))) LEFT JOIN film ON ((film_category.film_id = film.film_id))) JOIN film_actor ON ((film.film_id = film_actor.film_id))) JOIN actor ON ((film_actor.actor_id = actor.actor_id))) GROUP BY film.film_id, film.title, film.description, category.name, film.rental_rate, film.length, film.rating;



--
-- Name: payment_payment_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE payment_payment_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: payment; Type: TABLE; Schema: public;; Tablespace:
--

CREATE TABLE payment (
    payment_id integer DEFAULT nextval('payment_payment_id_seq'::regclass) NOT NULL,
    customer_id smallint NOT NULL,
    staff_id smallint NOT NULL,
    rental_id integer NOT NULL,
    amount numeric(5,2) NOT NULL,
    payment_date timestamp without time zone NOT NULL
);


--
-- Name: payment_p2007_01; Type: TABLE; Schema: public;; Tablespace:
--

CREATE TABLE payment_p2007_01 (CONSTRAINT payment_p2007_01_payment_date_check CHECK (((payment_date >= '2007-01-01 00:00:00'::timestamp without time zone) AND (payment_date < '2007-02-01 00:00:00'::timestamp without time zone)))
)
INHERITS (payment);


--
-- Name: payment_p2007_02; Type: TABLE; Schema: public;; Tablespace:
--

CREATE TABLE payment_p2007_02 (CONSTRAINT payment_p2007_02_payment_date_check CHECK (((payment_date >= '2007-02-01 00:00:00'::timestamp without time zone) AND (payment_date < '2007-03-01 00:00:00'::timestamp without time zone)))
)
INHERITS (payment);


--
-- Name: payment_p2007_03; Type: TABLE; Schema: public;; Tablespace:
--

CREATE TABLE payment_p2007_03 (CONSTRAINT payment_p2007_03_payment_date_check CHECK (((payment_date >= '2007-03-01 00:00:00'::timestamp without time zone) AND (payment_date < '2007-04-01 00:00:00'::timestamp without time zone)))
)
INHERITS (payment);


--
-- Name: payment_p2007_04; Type: TABLE; Schema: public;; Tablespace:
--

CREATE TABLE payment_p2007_04 (CONSTRAINT payment_p2007_04_payment_date_check CHECK (((payment_date >= '2007-04-01 00:00:00'::timestamp without time zone) AND (payment_date < '2007-05-01 00:00:00'::timestamp without time zone)))
)
INHERITS (payment);


--
-- Name: payment_p2007_05; Type: TABLE; Schema: public;; Tablespace:
--

CREATE TABLE payment_p2007_05 (CONSTRAINT payment_p2007_05_payment_date_check CHECK (((payment_date >= '2007-05-01 00:00:00'::timestamp without time zone) AND (payment_date < '2007-06-01 00:00:00'::timestamp without time zone)))
)
INHERITS (payment);


--
-- Name: payment_p2007_06; Type: TABLE; Schema: public;; Tablespace:
--

CREATE TABLE payment_p2007_06 (CONSTRAINT payment_p2007_06_payment_date_check CHECK (((payment_date >= '2007-06-01 00:00:00'::timestamp without time zone) AND (payment_date < '2007-07-01 00:00:00'::timestamp without time zone)))
)
INHERITS (payment);


--
-- Name: rental_rental_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE rental_rental_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: rental; Type: TABLE; Schema: public;; Tablespace:
--

CREATE TABLE rental (
    rental_id integer DEFAULT nextval('rental_rental_id_seq'::regclass) NOT NULL,
    rental_date timestamp without time zone NOT NULL,
    inventory_id integer NOT NULL,
    customer_id smallint NOT NULL,
    return_date timestamp without time zone,
    staff_id smallint NOT NULL,
    last_update timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: sales_by_film_category; Type: VIEW; Schema: public;
--

CREATE VIEW sales_by_film_category AS
    SELECT c.name AS category, sum(p.amount) AS total_sales FROM (((((payment p JOIN rental r ON ((p.rental_id = r.rental_id))) JOIN inventory i ON ((r.inventory_id = i.inventory_id))) JOIN film f ON ((i.film_id = f.film_id))) JOIN film_category fc ON ((f.film_id = fc.film_id))) JOIN category c ON ((fc.category_id = c.category_id))) GROUP BY c.name ORDER BY sum(p.amount) DESC;


--
-- Name: staff_staff_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE staff_staff_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: staff; Type: TABLE; Schema: public;; Tablespace:
--

CREATE TABLE staff (
    staff_id integer DEFAULT nextval('staff_staff_id_seq'::regclass) NOT NULL,
    first_name character varying(45) NOT NULL,
    last_name character varying(45) NOT NULL,
    address_id smallint NOT NULL,
    email character varying(50),
    store_id smallint NOT NULL,
    active boolean DEFAULT true NOT NULL,
    username character varying(16) NOT NULL,
    password character varying(40),
    last_update timestamp without time zone DEFAULT now() NOT NULL,
    picture bytea
);


--
-- Name: store_store_id_seq; Type: SEQUENCE; Schema: public;
--

CREATE SEQUENCE store_store_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: store; Type: TABLE; Schema: public;; Tablespace:
--

CREATE TABLE store (
    store_id integer DEFAULT nextval('store_store_id_seq'::regclass) NOT NULL,
    manager_staff_id smallint NOT NULL,
    address_id smallint NOT NULL,
    last_update timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: sales_by_store; Type: VIEW; Schema: public;
--

CREATE VIEW sales_by_store AS
    SELECT (((c.city)::text || ','::text) || (cy.country)::text) AS store, (((m.first_name)::text || ' '::text) || (m.last_name)::text) AS manager, sum(p.amount) AS total_sales FROM (((((((payment p JOIN rental r ON ((p.rental_id = r.rental_id))) JOIN inventory i ON ((r.inventory_id = i.inventory_id))) JOIN store s ON ((i.store_id = s.store_id))) JOIN address a ON ((s.address_id = a.address_id))) JOIN city c ON ((a.city_id = c.city_id))) JOIN country cy ON ((c.country_id = cy.country_id))) JOIN staff m ON ((s.manager_staff_id = m.staff_id))) GROUP BY cy.country, c.city, s.store_id, m.first_name, m.last_name ORDER BY cy.country, c.city;


--
-- Name: staff_list; Type: VIEW; Schema: public;
--

CREATE VIEW staff_list AS
    SELECT s.staff_id AS id, (((s.first_name)::text || ' '::text) || (s.last_name)::text) AS name, a.address, a.postal_code AS "zip code", a.phone, city.city, country.country, s.store_id AS sid FROM (((staff s JOIN address a ON ((s.address_id = a.address_id))) JOIN city ON ((a.city_id = city.city_id))) JOIN country ON ((city.country_id = country.country_id)));


--
-- Name: film_in_stock(integer, integer); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION film_in_stock(p_film_id integer, p_store_id integer, OUT p_film_count integer) RETURNS SETOF integer
    AS $_$
     SELECT inventory_id
     FROM inventory
     WHERE film_id = $1
     AND store_id = $2
     AND inventory_in_stock(inventory_id);
$_$
    LANGUAGE sql;


--
-- Name: film_not_in_stock(integer, integer); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION film_not_in_stock(p_film_id integer, p_store_id integer, OUT p_film_count integer) RETURNS SETOF integer
    AS $_$
    SELECT inventory_id
    FROM inventory
    WHERE film_id = $1
    AND store_id = $2
    AND NOT inventory_in_stock(inventory_id);
$_$
    LANGUAGE sql;


--
-- Name: get_customer_balance(integer, timestamp without time zone); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION get_customer_balance(p_customer_id integer, p_effective_date timestamp without time zone) RETURNS numeric
    AS $$
       --#OK, WE NEED TO CALCULATE THE CURRENT BALANCE GIVEN A CUSTOMER_ID AND A DATE
       --#THAT WE WANT THE BALANCE TO BE EFFECTIVE FOR. THE BALANCE IS:
       --#   1) RENTAL FEES FOR ALL PREVIOUS RENTALS
       --#   2) ONE DOLLAR FOR EVERY DAY THE PREVIOUS RENTALS ARE OVERDUE
       --#   3) IF A FILM IS MORE THAN RENTAL_DURATION * 2 OVERDUE, CHARGE THE REPLACEMENT_COST
       --#   4) SUBTRACT ALL PAYMENTS MADE BEFORE THE DATE SPECIFIED
DECLARE
    v_rentfees DECIMAL(5,2); --#FEES PAID TO RENT THE VIDEOS INITIALLY
    v_overfees INTEGER;      --#LATE FEES FOR PRIOR RENTALS
    v_payments DECIMAL(5,2); --#SUM OF PAYMENTS MADE PREVIOUSLY
BEGIN
    SELECT COALESCE(SUM(film.rental_rate),0) INTO v_rentfees
    FROM film, inventory, rental
    WHERE film.film_id = inventory.film_id
      AND inventory.inventory_id = rental.inventory_id
      AND rental.rental_date <= p_effective_date
      AND rental.customer_id = p_customer_id;

    SELECT COALESCE(SUM(IF((rental.return_date - rental.rental_date) > (film.rental_duration * '1 day'::interval),
        ((rental.return_date - rental.rental_date) - (film.rental_duration * '1 day'::interval)),0)),0) INTO v_overfees
    FROM rental, inventory, film
    WHERE film.film_id = inventory.film_id
      AND inventory.inventory_id = rental.inventory_id
      AND rental.rental_date <= p_effective_date
      AND rental.customer_id = p_customer_id;

    SELECT COALESCE(SUM(payment.amount),0) INTO v_payments
    FROM payment
    WHERE payment.payment_date <= p_effective_date
    AND payment.customer_id = p_customer_id;

    RETURN v_rentfees + v_overfees - v_payments;
END
$$
    LANGUAGE plpgsql;


--
-- Name: inventory_held_by_customer(integer); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION inventory_held_by_customer(p_inventory_id integer) RETURNS integer
    AS $$
DECLARE
    v_customer_id INTEGER;
BEGIN

  SELECT customer_id INTO v_customer_id
  FROM rental
  WHERE return_date IS NULL
  AND inventory_id = p_inventory_id;

  RETURN v_customer_id;
END $$
    LANGUAGE plpgsql;


--
-- Name: inventory_in_stock(integer); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION inventory_in_stock(p_inventory_id integer) RETURNS boolean
    AS $$
DECLARE
    v_rentals INTEGER;
    v_out     INTEGER;
BEGIN
    -- AN ITEM IS IN-STOCK IF THERE ARE EITHER NO ROWS IN THE rental TABLE
    -- FOR THE ITEM OR ALL ROWS HAVE return_date POPULATED

    SELECT count(*) INTO v_rentals
    FROM rental
    WHERE inventory_id = p_inventory_id;

    IF v_rentals = 0 THEN
      RETURN TRUE;
    END IF;

    SELECT COUNT(rental_id) INTO v_out
    FROM inventory LEFT JOIN rental USING(inventory_id)
    WHERE inventory.inventory_id = p_inventory_id
    AND rental.return_date IS NULL;

    IF v_out > 0 THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
END $$
    LANGUAGE plpgsql;


--
-- Name: last_day(timestamp without time zone); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION last_day(timestamp without time zone) RETURNS date
    AS $_$
  SELECT CASE
    WHEN EXTRACT(MONTH FROM $1) = 12 THEN
      (((EXTRACT(YEAR FROM $1) + 1) operator(pg_catalog.||) '-01-01')::date - INTERVAL '1 day')::date
    ELSE
      ((EXTRACT(YEAR FROM $1) operator(pg_catalog.||) '-' operator(pg_catalog.||) (EXTRACT(MONTH FROM $1) + 1) operator(pg_catalog.||) '-01')::date - INTERVAL '1 day')::date
    END
$_$
    LANGUAGE sql IMMUTABLE STRICT;


--
-- Name: last_updated(); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION last_updated() RETURNS trigger
    AS $$
BEGIN
    NEW.last_update = CURRENT_TIMESTAMP;
    RETURN NEW;
END $$
    LANGUAGE plpgsql;


--
-- Name: rewards_report(integer, numeric); Type: FUNCTION; Schema: public;
--

CREATE FUNCTION rewards_report(min_monthly_purchases integer, min_dollar_amount_purchased numeric) RETURNS SETOF customer
    AS $_$
DECLARE
    last_month_start DATE;
    last_month_end DATE;
rr RECORD;
tmpSQL TEXT;
BEGIN

    /* Some sanity checks... */
    IF min_monthly_purchases = 0 THEN
        RAISE EXCEPTION 'Minimum monthly purchases parameter must be > 0';
    END IF;
    IF min_dollar_amount_purchased = 0.00 THEN
        RAISE EXCEPTION 'Minimum monthly dollar amount purchased parameter must be > $0.00';
    END IF;

    last_month_start := CURRENT_DATE - '3 month'::interval;
    last_month_start := to_date((extract(YEAR FROM last_month_start) || '-' || extract(MONTH FROM last_month_start) || '-01'),'YYYY-MM-DD');
    last_month_end := LAST_DAY(last_month_start);

    /*
    Create a temporary storage area for Customer IDs.
    */
    CREATE TEMPORARY TABLE tmpCustomer (customer_id INTEGER NOT NULL PRIMARY KEY);

    /*
    Find all customers meeting the monthly purchase requirements
    */

    tmpSQL := 'INSERT INTO tmpCustomer (customer_id)
        SELECT p.customer_id
        FROM payment AS p
        WHERE DATE(p.payment_date) BETWEEN '||quote_literal(last_month_start) ||' AND '|| quote_literal(last_month_end) || '
        GROUP BY customer_id
        HAVING SUM(p.amount) > '|| min_dollar_amount_purchased || '
        AND COUNT(customer_id) > ' ||min_monthly_purchases ;

    EXECUTE tmpSQL;

    /*
    Output ALL customer information of matching rewardees.
    Customize output as needed.
    */
    FOR rr IN EXECUTE 'SELECT c.* FROM tmpCustomer AS t INNER JOIN customer AS c ON t.customer_id = c.customer_id' LOOP
        RETURN NEXT rr;
    END LOOP;

    /* Clean up */
    tmpSQL := 'DROP TABLE tmpCustomer';
    EXECUTE tmpSQL;

RETURN;
END
$_$
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- Name: actor_pkey; Type: CONSTRAINT; Schema: public;; Tablespace:
--

ALTER TABLE ONLY actor
    ADD CONSTRAINT actor_pkey PRIMARY KEY (actor_id);


--
-- Name: address_pkey; Type: CONSTRAINT; Schema: public;; Tablespace:
--

ALTER TABLE ONLY address
    ADD CONSTRAINT address_pkey PRIMARY KEY (address_id);


--
-- Name: category_pkey; Type: CONSTRAINT; Schema: public;; Tablespace:
--

ALTER TABLE ONLY category
    ADD CONSTRAINT category_pkey PRIMARY KEY (category_id);


--
-- Name: city_pkey; Type: CONSTRAINT; Schema: public;; Tablespace:
--

ALTER TABLE ONLY city
    ADD CONSTRAINT city_pkey PRIMARY KEY (city_id);


--
-- Name: country_pkey; Type: CONSTRAINT; Schema: public;; Tablespace:
--

ALTER TABLE ONLY country
    ADD CONSTRAINT country_pkey PRIMARY KEY (country_id);


--
-- Name: customer_pkey; Type: CONSTRAINT; Schema: public;; Tablespace:
--

ALTER TABLE ONLY customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_id);


--
-- Name: film_actor_pkey; Type: CONSTRAINT; Schema: public;; Tablespace:
--

ALTER TABLE ONLY film_actor
    ADD CONSTRAINT film_actor_pkey PRIMARY KEY (actor_id, film_id);


--
-- Name: film_category_pkey; Type: CONSTRAINT; Schema: public;; Tablespace:
--

ALTER TABLE ONLY film_category
    ADD CONSTRAINT film_category_pkey PRIMARY KEY (film_id, category_id);


--
-- Name: film_pkey; Type: CONSTRAINT; Schema: public;; Tablespace:
--

ALTER TABLE ONLY film
    ADD CONSTRAINT film_pkey PRIMARY KEY (film_id);


--
-- Name: inventory_pkey; Type: CONSTRAINT; Schema: public;; Tablespace:
--

ALTER TABLE ONLY inventory
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (inventory_id);


--
-- Name: language_pkey; Type: CONSTRAINT; Schema: public;; Tablespace:
--

ALTER TABLE ONLY language
    ADD CONSTRAINT language_pkey PRIMARY KEY (language_id);


--
-- Name: payment_pkey; Type: CONSTRAINT; Schema: public;; Tablespace:
--

ALTER TABLE ONLY payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (payment_id);


--
-- Name: rental_pkey; Type: CONSTRAINT; Schema: public;; Tablespace:
--

ALTER TABLE ONLY rental
    ADD CONSTRAINT rental_pkey PRIMARY KEY (rental_id);


--
-- Name: staff_pkey; Type: CONSTRAINT; Schema: public;; Tablespace:
--

ALTER TABLE ONLY staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (staff_id);


--
-- Name: store_pkey; Type: CONSTRAINT; Schema: public;; Tablespace:
--

ALTER TABLE ONLY store
    ADD CONSTRAINT store_pkey PRIMARY KEY (store_id);


--
-- Name: film_fulltext_idx; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX film_fulltext_idx ON film USING gist (fulltext);


--
-- Name: idx_actor_last_name; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_actor_last_name ON actor USING btree (last_name);


--
-- Name: idx_fk_address_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_fk_address_id ON customer USING btree (address_id);


--
-- Name: idx_fk_city_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_fk_city_id ON address USING btree (city_id);


--
-- Name: idx_fk_country_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_fk_country_id ON city USING btree (country_id);


--
-- Name: idx_fk_customer_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_fk_customer_id ON payment USING btree (customer_id);


--
-- Name: idx_fk_film_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_fk_film_id ON film_actor USING btree (film_id);


--
-- Name: idx_fk_inventory_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_fk_inventory_id ON rental USING btree (inventory_id);


--
-- Name: idx_fk_language_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_fk_language_id ON film USING btree (language_id);


--
-- Name: idx_fk_original_language_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_fk_original_language_id ON film USING btree (original_language_id);


--
-- Name: idx_fk_payment_p2007_01_customer_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_fk_payment_p2007_01_customer_id ON payment_p2007_01 USING btree (customer_id);


--
-- Name: idx_fk_payment_p2007_01_staff_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_fk_payment_p2007_01_staff_id ON payment_p2007_01 USING btree (staff_id);


--
-- Name: idx_fk_payment_p2007_02_customer_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_fk_payment_p2007_02_customer_id ON payment_p2007_02 USING btree (customer_id);


--
-- Name: idx_fk_payment_p2007_02_staff_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_fk_payment_p2007_02_staff_id ON payment_p2007_02 USING btree (staff_id);


--
-- Name: idx_fk_payment_p2007_03_customer_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_fk_payment_p2007_03_customer_id ON payment_p2007_03 USING btree (customer_id);


--
-- Name: idx_fk_payment_p2007_03_staff_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_fk_payment_p2007_03_staff_id ON payment_p2007_03 USING btree (staff_id);


--
-- Name: idx_fk_payment_p2007_04_customer_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_fk_payment_p2007_04_customer_id ON payment_p2007_04 USING btree (customer_id);


--
-- Name: idx_fk_payment_p2007_04_staff_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_fk_payment_p2007_04_staff_id ON payment_p2007_04 USING btree (staff_id);


--
-- Name: idx_fk_payment_p2007_05_customer_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_fk_payment_p2007_05_customer_id ON payment_p2007_05 USING btree (customer_id);


--
-- Name: idx_fk_payment_p2007_05_staff_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_fk_payment_p2007_05_staff_id ON payment_p2007_05 USING btree (staff_id);


--
-- Name: idx_fk_payment_p2007_06_customer_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_fk_payment_p2007_06_customer_id ON payment_p2007_06 USING btree (customer_id);


--
-- Name: idx_fk_payment_p2007_06_staff_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_fk_payment_p2007_06_staff_id ON payment_p2007_06 USING btree (staff_id);


--
-- Name: idx_fk_staff_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_fk_staff_id ON payment USING btree (staff_id);


--
-- Name: idx_fk_store_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_fk_store_id ON customer USING btree (store_id);


--
-- Name: idx_last_name; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_last_name ON customer USING btree (last_name);


--
-- Name: idx_store_id_film_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_store_id_film_id ON inventory USING btree (store_id, film_id);


--
-- Name: idx_title; Type: INDEX; Schema: public;; Tablespace:
--

CREATE INDEX idx_title ON film USING btree (title);


--
-- Name: idx_unq_manager_staff_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE UNIQUE INDEX idx_unq_manager_staff_id ON store USING btree (manager_staff_id);


--
-- Name: idx_unq_rental_rental_date_inventory_id_customer_id; Type: INDEX; Schema: public;; Tablespace:
--

CREATE UNIQUE INDEX idx_unq_rental_rental_date_inventory_id_customer_id ON rental USING btree (rental_date, inventory_id, customer_id);


--
-- Name: payment_insert_p2007_01; Type: RULE; Schema: public;
--

CREATE RULE payment_insert_p2007_01 AS ON INSERT TO payment WHERE ((new.payment_date >= '2007-01-01 00:00:00'::timestamp without time zone) AND (new.payment_date < '2007-02-01 00:00:00'::timestamp without time zone)) DO INSTEAD INSERT INTO payment_p2007_01 (payment_id, customer_id, staff_id, rental_id, amount, payment_date) VALUES (DEFAULT, new.customer_id, new.staff_id, new.rental_id, new.amount, new.payment_date);


--
-- Name: payment_insert_p2007_02; Type: RULE; Schema: public;
--

CREATE RULE payment_insert_p2007_02 AS ON INSERT TO payment WHERE ((new.payment_date >= '2007-02-01 00:00:00'::timestamp without time zone) AND (new.payment_date < '2007-03-01 00:00:00'::timestamp without time zone)) DO INSTEAD INSERT INTO payment_p2007_02 (payment_id, customer_id, staff_id, rental_id, amount, payment_date) VALUES (DEFAULT, new.customer_id, new.staff_id, new.rental_id, new.amount, new.payment_date);


--
-- Name: payment_insert_p2007_03; Type: RULE; Schema: public;
--

CREATE RULE payment_insert_p2007_03 AS ON INSERT TO payment WHERE ((new.payment_date >= '2007-03-01 00:00:00'::timestamp without time zone) AND (new.payment_date < '2007-04-01 00:00:00'::timestamp without time zone)) DO INSTEAD INSERT INTO payment_p2007_03 (payment_id, customer_id, staff_id, rental_id, amount, payment_date) VALUES (DEFAULT, new.customer_id, new.staff_id, new.rental_id, new.amount, new.payment_date);


--
-- Name: payment_insert_p2007_04; Type: RULE; Schema: public;
--

CREATE RULE payment_insert_p2007_04 AS ON INSERT TO payment WHERE ((new.payment_date >= '2007-04-01 00:00:00'::timestamp without time zone) AND (new.payment_date < '2007-05-01 00:00:00'::timestamp without time zone)) DO INSTEAD INSERT INTO payment_p2007_04 (payment_id, customer_id, staff_id, rental_id, amount, payment_date) VALUES (DEFAULT, new.customer_id, new.staff_id, new.rental_id, new.amount, new.payment_date);


--
-- Name: payment_insert_p2007_05; Type: RULE; Schema: public;
--

CREATE RULE payment_insert_p2007_05 AS ON INSERT TO payment WHERE ((new.payment_date >= '2007-05-01 00:00:00'::timestamp without time zone) AND (new.payment_date < '2007-06-01 00:00:00'::timestamp without time zone)) DO INSTEAD INSERT INTO payment_p2007_05 (payment_id, customer_id, staff_id, rental_id, amount, payment_date) VALUES (DEFAULT, new.customer_id, new.staff_id, new.rental_id, new.amount, new.payment_date);


--
-- Name: payment_insert_p2007_06; Type: RULE; Schema: public;
--

CREATE RULE payment_insert_p2007_06 AS ON INSERT TO payment WHERE ((new.payment_date >= '2007-06-01 00:00:00'::timestamp without time zone) AND (new.payment_date < '2007-07-01 00:00:00'::timestamp without time zone)) DO INSTEAD INSERT INTO payment_p2007_06 (payment_id, customer_id, staff_id, rental_id, amount, payment_date) VALUES (DEFAULT, new.customer_id, new.staff_id, new.rental_id, new.amount, new.payment_date);


--
-- Name: film_fulltext_trigger; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER film_fulltext_trigger
    BEFORE INSERT OR UPDATE ON film
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('fulltext', 'pg_catalog.english', 'title', 'description');


--
-- Name: last_updated; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER last_updated
    BEFORE UPDATE ON actor
    FOR EACH ROW
    EXECUTE PROCEDURE last_updated();


--
-- Name: last_updated; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER last_updated
    BEFORE UPDATE ON address
    FOR EACH ROW
    EXECUTE PROCEDURE last_updated();


--
-- Name: last_updated; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER last_updated
    BEFORE UPDATE ON category
    FOR EACH ROW
    EXECUTE PROCEDURE last_updated();


--
-- Name: last_updated; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER last_updated
    BEFORE UPDATE ON city
    FOR EACH ROW
    EXECUTE PROCEDURE last_updated();


--
-- Name: last_updated; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER last_updated
    BEFORE UPDATE ON country
    FOR EACH ROW
    EXECUTE PROCEDURE last_updated();


--
-- Name: last_updated; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER last_updated
    BEFORE UPDATE ON customer
    FOR EACH ROW
    EXECUTE PROCEDURE last_updated();


--
-- Name: last_updated; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER last_updated
    BEFORE UPDATE ON film
    FOR EACH ROW
    EXECUTE PROCEDURE last_updated();


--
-- Name: last_updated; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER last_updated
    BEFORE UPDATE ON film_actor
    FOR EACH ROW
    EXECUTE PROCEDURE last_updated();


--
-- Name: last_updated; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER last_updated
    BEFORE UPDATE ON film_category
    FOR EACH ROW
    EXECUTE PROCEDURE last_updated();


--
-- Name: last_updated; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER last_updated
    BEFORE UPDATE ON inventory
    FOR EACH ROW
    EXECUTE PROCEDURE last_updated();


--
-- Name: last_updated; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER last_updated
    BEFORE UPDATE ON language
    FOR EACH ROW
    EXECUTE PROCEDURE last_updated();


--
-- Name: last_updated; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER last_updated
    BEFORE UPDATE ON rental
    FOR EACH ROW
    EXECUTE PROCEDURE last_updated();


--
-- Name: last_updated; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER last_updated
    BEFORE UPDATE ON staff
    FOR EACH ROW
    EXECUTE PROCEDURE last_updated();


--
-- Name: last_updated; Type: TRIGGER; Schema: public;
--

CREATE TRIGGER last_updated
    BEFORE UPDATE ON store
    FOR EACH ROW
    EXECUTE PROCEDURE last_updated();


--
-- Name: address_city_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY address
    ADD CONSTRAINT address_city_id_fkey FOREIGN KEY (city_id) REFERENCES city(city_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: city_country_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY city
    ADD CONSTRAINT city_country_id_fkey FOREIGN KEY (country_id) REFERENCES country(country_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: customer_address_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY customer
    ADD CONSTRAINT customer_address_id_fkey FOREIGN KEY (address_id) REFERENCES address(address_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: customer_store_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY customer
    ADD CONSTRAINT customer_store_id_fkey FOREIGN KEY (store_id) REFERENCES store(store_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: film_actor_actor_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY film_actor
    ADD CONSTRAINT film_actor_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES actor(actor_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: film_actor_film_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY film_actor
    ADD CONSTRAINT film_actor_film_id_fkey FOREIGN KEY (film_id) REFERENCES film(film_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: film_category_category_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY film_category
    ADD CONSTRAINT film_category_category_id_fkey FOREIGN KEY (category_id) REFERENCES category(category_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: film_category_film_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY film_category
    ADD CONSTRAINT film_category_film_id_fkey FOREIGN KEY (film_id) REFERENCES film(film_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: film_language_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY film
    ADD CONSTRAINT film_language_id_fkey FOREIGN KEY (language_id) REFERENCES language(language_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: film_original_language_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY film
    ADD CONSTRAINT film_original_language_id_fkey FOREIGN KEY (original_language_id) REFERENCES language(language_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: inventory_film_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY inventory
    ADD CONSTRAINT inventory_film_id_fkey FOREIGN KEY (film_id) REFERENCES film(film_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: inventory_store_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY inventory
    ADD CONSTRAINT inventory_store_id_fkey FOREIGN KEY (store_id) REFERENCES store(store_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: payment_customer_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY payment
    ADD CONSTRAINT payment_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: payment_p2007_01_customer_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY payment_p2007_01
    ADD CONSTRAINT payment_p2007_01_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer(customer_id);


--
-- Name: payment_p2007_01_rental_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY payment_p2007_01
    ADD CONSTRAINT payment_p2007_01_rental_id_fkey FOREIGN KEY (rental_id) REFERENCES rental(rental_id);


--
-- Name: payment_p2007_01_staff_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY payment_p2007_01
    ADD CONSTRAINT payment_p2007_01_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES staff(staff_id);


--
-- Name: payment_p2007_02_customer_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY payment_p2007_02
    ADD CONSTRAINT payment_p2007_02_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer(customer_id);


--
-- Name: payment_p2007_02_rental_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY payment_p2007_02
    ADD CONSTRAINT payment_p2007_02_rental_id_fkey FOREIGN KEY (rental_id) REFERENCES rental(rental_id);


--
-- Name: payment_p2007_02_staff_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY payment_p2007_02
    ADD CONSTRAINT payment_p2007_02_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES staff(staff_id);


--
-- Name: payment_p2007_03_customer_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY payment_p2007_03
    ADD CONSTRAINT payment_p2007_03_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer(customer_id);


--
-- Name: payment_p2007_03_rental_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY payment_p2007_03
    ADD CONSTRAINT payment_p2007_03_rental_id_fkey FOREIGN KEY (rental_id) REFERENCES rental(rental_id);


--
-- Name: payment_p2007_03_staff_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY payment_p2007_03
    ADD CONSTRAINT payment_p2007_03_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES staff(staff_id);


--
-- Name: payment_p2007_04_customer_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY payment_p2007_04
    ADD CONSTRAINT payment_p2007_04_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer(customer_id);


--
-- Name: payment_p2007_04_rental_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY payment_p2007_04
    ADD CONSTRAINT payment_p2007_04_rental_id_fkey FOREIGN KEY (rental_id) REFERENCES rental(rental_id);


--
-- Name: payment_p2007_04_staff_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY payment_p2007_04
    ADD CONSTRAINT payment_p2007_04_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES staff(staff_id);


--
-- Name: payment_p2007_05_customer_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY payment_p2007_05
    ADD CONSTRAINT payment_p2007_05_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer(customer_id);


--
-- Name: payment_p2007_05_rental_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY payment_p2007_05
    ADD CONSTRAINT payment_p2007_05_rental_id_fkey FOREIGN KEY (rental_id) REFERENCES rental(rental_id);


--
-- Name: payment_p2007_05_staff_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY payment_p2007_05
    ADD CONSTRAINT payment_p2007_05_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES staff(staff_id);


--
-- Name: payment_p2007_06_customer_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY payment_p2007_06
    ADD CONSTRAINT payment_p2007_06_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer(customer_id);


--
-- Name: payment_p2007_06_rental_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY payment_p2007_06
    ADD CONSTRAINT payment_p2007_06_rental_id_fkey FOREIGN KEY (rental_id) REFERENCES rental(rental_id);


--
-- Name: payment_p2007_06_staff_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY payment_p2007_06
    ADD CONSTRAINT payment_p2007_06_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES staff(staff_id);


--
-- Name: payment_rental_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY payment
    ADD CONSTRAINT payment_rental_id_fkey FOREIGN KEY (rental_id) REFERENCES rental(rental_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: payment_staff_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY payment
    ADD CONSTRAINT payment_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: rental_customer_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY rental
    ADD CONSTRAINT rental_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: rental_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY rental
    ADD CONSTRAINT rental_inventory_id_fkey FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: rental_staff_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY rental
    ADD CONSTRAINT rental_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: staff_address_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY staff
    ADD CONSTRAINT staff_address_id_fkey FOREIGN KEY (address_id) REFERENCES address(address_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: staff_store_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY staff
    ADD CONSTRAINT staff_store_id_fkey FOREIGN KEY (store_id) REFERENCES store(store_id);


--
-- Name: store_address_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY store
    ADD CONSTRAINT store_address_id_fkey FOREIGN KEY (address_id) REFERENCES address(address_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: store_manager_staff_id_fkey; Type: FK CONSTRAINT; Schema: public;
--

ALTER TABLE ONLY store
    ADD CONSTRAINT store_manager_staff_id_fkey FOREIGN KEY (manager_staff_id) REFERENCES staff(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: public; Type: ACL; Schema: -;
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

--
-- Name: actor_actor_id_seq; Type: SEQUENCE SET; Schema: public;
--

SELECT pg_catalog.setval('actor_actor_id_seq', 200, true);


--
-- Name: category_category_id_seq; Type: SEQUENCE SET; Schema: public;
--

SELECT pg_catalog.setval('category_category_id_seq', 16, true);


--
-- Name: film_film_id_seq; Type: SEQUENCE SET; Schema: public;
--

SELECT pg_catalog.setval('film_film_id_seq', 1000, true);


--
-- Name: address_address_id_seq; Type: SEQUENCE SET; Schema: public;
--

SELECT pg_catalog.setval('address_address_id_seq', 605, true);


--
-- Name: city_city_id_seq; Type: SEQUENCE SET; Schema: public;
--

SELECT pg_catalog.setval('city_city_id_seq', 600, true);


--
-- Name: country_country_id_seq; Type: SEQUENCE SET; Schema: public;
--

SELECT pg_catalog.setval('country_country_id_seq', 109, true);


--
-- Name: customer_customer_id_seq; Type: SEQUENCE SET; Schema: public;
--

SELECT pg_catalog.setval('customer_customer_id_seq', 599, true);


--
-- Name: inventory_inventory_id_seq; Type: SEQUENCE SET; Schema: public;
--

SELECT pg_catalog.setval('inventory_inventory_id_seq', 4581, true);


--
-- Name: language_language_id_seq; Type: SEQUENCE SET; Schema: public;
--

SELECT pg_catalog.setval('language_language_id_seq', 6, true);


--
-- Name: payment_payment_id_seq; Type: SEQUENCE SET; Schema: public;
--

SELECT pg_catalog.setval('payment_payment_id_seq', 32098, true);


--
-- Name: rental_rental_id_seq; Type: SEQUENCE SET; Schema: public;
--

SELECT pg_catalog.setval('rental_rental_id_seq', 16049, true);


--
-- Name: staff_staff_id_seq; Type: SEQUENCE SET; Schema: public;
--

SELECT pg_catalog.setval('staff_staff_id_seq', 2, true);


--
-- Name: store_store_id_seq; Type: SEQUENCE SET; Schema: public;
--

SELECT pg_catalog.setval('store_store_id_seq', 2, true);


--
-- Data for Name: actor; Type: TABLE DATA; Schema: public;
--

ALTER TABLE actor DISABLE TRIGGER ALL;

INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (1, 'PENELOPE', 'GUINESS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (2, 'NICK', 'WAHLBERG', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (3, 'ED', 'CHASE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (4, 'JENNIFER', 'DAVIS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (5, 'JOHNNY', 'LOLLOBRIGIDA', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (6, 'BETTE', 'NICHOLSON', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (7, 'GRACE', 'MOSTEL', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (8, 'MATTHEW', 'JOHANSSON', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (9, 'JOE', 'SWANK', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (10, 'CHRISTIAN', 'GABLE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (11, 'ZERO', 'CAGE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (12, 'KARL', 'BERRY', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (13, 'UMA', 'WOOD', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (14, 'VIVIEN', 'BERGEN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (15, 'CUBA', 'OLIVIER', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (16, 'FRED', 'COSTNER', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (17, 'HELEN', 'VOIGHT', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (18, 'DAN', 'TORN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (19, 'BOB', 'FAWCETT', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (20, 'LUCILLE', 'TRACY', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (21, 'KIRSTEN', 'PALTROW', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (22, 'ELVIS', 'MARX', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (23, 'SANDRA', 'KILMER', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (24, 'CAMERON', 'STREEP', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (25, 'KEVIN', 'BLOOM', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (26, 'RIP', 'CRAWFORD', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (27, 'JULIA', 'MCQUEEN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (28, 'WOODY', 'HOFFMAN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (29, 'ALEC', 'WAYNE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (30, 'SANDRA', 'PECK', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (31, 'SISSY', 'SOBIESKI', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (32, 'TIM', 'HACKMAN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (33, 'MILLA', 'PECK', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (34, 'AUDREY', 'OLIVIER', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (35, 'JUDY', 'DEAN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (36, 'BURT', 'DUKAKIS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (37, 'VAL', 'BOLGER', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (38, 'TOM', 'MCKELLEN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (39, 'GOLDIE', 'BRODY', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (40, 'JOHNNY', 'CAGE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (41, 'JODIE', 'DEGENERES', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (42, 'TOM', 'MIRANDA', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (43, 'KIRK', 'JOVOVICH', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (44, 'NICK', 'STALLONE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (45, 'REESE', 'KILMER', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (46, 'PARKER', 'GOLDBERG', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (47, 'JULIA', 'BARRYMORE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (48, 'FRANCES', 'DAY-LEWIS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (49, 'ANNE', 'CRONYN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (50, 'NATALIE', 'HOPKINS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (51, 'GARY', 'PHOENIX', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (52, 'CARMEN', 'HUNT', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (53, 'MENA', 'TEMPLE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (54, 'PENELOPE', 'PINKETT', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (55, 'FAY', 'KILMER', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (56, 'DAN', 'HARRIS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (57, 'JUDE', 'CRUISE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (58, 'CHRISTIAN', 'AKROYD', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (59, 'DUSTIN', 'TAUTOU', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (60, 'HENRY', 'BERRY', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (61, 'CHRISTIAN', 'NEESON', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (62, 'JAYNE', 'NEESON', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (63, 'CAMERON', 'WRAY', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (64, 'RAY', 'JOHANSSON', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (65, 'ANGELA', 'HUDSON', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (66, 'MARY', 'TANDY', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (67, 'JESSICA', 'BAILEY', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (68, 'RIP', 'WINSLET', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (69, 'KENNETH', 'PALTROW', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (70, 'MICHELLE', 'MCCONAUGHEY', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (71, 'ADAM', 'GRANT', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (72, 'SEAN', 'WILLIAMS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (73, 'GARY', 'PENN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (74, 'MILLA', 'KEITEL', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (75, 'BURT', 'POSEY', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (76, 'ANGELINA', 'ASTAIRE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (77, 'CARY', 'MCCONAUGHEY', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (78, 'GROUCHO', 'SINATRA', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (79, 'MAE', 'HOFFMAN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (80, 'RALPH', 'CRUZ', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (81, 'SCARLETT', 'DAMON', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (82, 'WOODY', 'JOLIE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (83, 'BEN', 'WILLIS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (84, 'JAMES', 'PITT', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (85, 'MINNIE', 'ZELLWEGER', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (86, 'GREG', 'CHAPLIN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (87, 'SPENCER', 'PECK', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (88, 'KENNETH', 'PESCI', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (89, 'CHARLIZE', 'DENCH', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (90, 'SEAN', 'GUINESS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (91, 'CHRISTOPHER', 'BERRY', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (92, 'KIRSTEN', 'AKROYD', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (93, 'ELLEN', 'PRESLEY', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (94, 'KENNETH', 'TORN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (95, 'DARYL', 'WAHLBERG', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (96, 'GENE', 'WILLIS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (97, 'MEG', 'HAWKE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (98, 'CHRIS', 'BRIDGES', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (99, 'JIM', 'MOSTEL', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (100, 'SPENCER', 'DEPP', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (101, 'SUSAN', 'DAVIS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (102, 'WALTER', 'TORN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (103, 'MATTHEW', 'LEIGH', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (104, 'PENELOPE', 'CRONYN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (105, 'SIDNEY', 'CROWE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (106, 'GROUCHO', 'DUNST', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (107, 'GINA', 'DEGENERES', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (108, 'WARREN', 'NOLTE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (109, 'SYLVESTER', 'DERN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (110, 'SUSAN', 'DAVIS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (111, 'CAMERON', 'ZELLWEGER', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (112, 'RUSSELL', 'BACALL', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (113, 'MORGAN', 'HOPKINS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (114, 'MORGAN', 'MCDORMAND', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (115, 'HARRISON', 'BALE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (116, 'DAN', 'STREEP', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (117, 'RENEE', 'TRACY', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (118, 'CUBA', 'ALLEN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (119, 'WARREN', 'JACKMAN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (120, 'PENELOPE', 'MONROE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (121, 'LIZA', 'BERGMAN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (122, 'SALMA', 'NOLTE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (123, 'JULIANNE', 'DENCH', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (124, 'SCARLETT', 'BENING', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (125, 'ALBERT', 'NOLTE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (126, 'FRANCES', 'TOMEI', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (127, 'KEVIN', 'GARLAND', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (128, 'CATE', 'MCQUEEN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (129, 'DARYL', 'CRAWFORD', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (130, 'GRETA', 'KEITEL', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (131, 'JANE', 'JACKMAN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (132, 'ADAM', 'HOPPER', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (133, 'RICHARD', 'PENN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (134, 'GENE', 'HOPKINS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (135, 'RITA', 'REYNOLDS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (136, 'ED', 'MANSFIELD', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (137, 'MORGAN', 'WILLIAMS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (138, 'LUCILLE', 'DEE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (139, 'EWAN', 'GOODING', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (140, 'WHOOPI', 'HURT', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (141, 'CATE', 'HARRIS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (142, 'JADA', 'RYDER', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (143, 'RIVER', 'DEAN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (144, 'ANGELA', 'WITHERSPOON', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (145, 'KIM', 'ALLEN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (146, 'ALBERT', 'JOHANSSON', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (147, 'FAY', 'WINSLET', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (148, 'EMILY', 'DEE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (149, 'RUSSELL', 'TEMPLE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (150, 'JAYNE', 'NOLTE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (151, 'GEOFFREY', 'HESTON', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (152, 'BEN', 'HARRIS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (153, 'MINNIE', 'KILMER', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (154, 'MERYL', 'GIBSON', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (155, 'IAN', 'TANDY', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (156, 'FAY', 'WOOD', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (157, 'GRETA', 'MALDEN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (158, 'VIVIEN', 'BASINGER', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (159, 'LAURA', 'BRODY', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (160, 'CHRIS', 'DEPP', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (161, 'HARVEY', 'HOPE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (162, 'OPRAH', 'KILMER', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (163, 'CHRISTOPHER', 'WEST', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (164, 'HUMPHREY', 'WILLIS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (165, 'AL', 'GARLAND', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (166, 'NICK', 'DEGENERES', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (167, 'LAURENCE', 'BULLOCK', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (168, 'WILL', 'WILSON', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (169, 'KENNETH', 'HOFFMAN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (170, 'MENA', 'HOPPER', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (171, 'OLYMPIA', 'PFEIFFER', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (172, 'GROUCHO', 'WILLIAMS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (173, 'ALAN', 'DREYFUSS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (174, 'MICHAEL', 'BENING', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (175, 'WILLIAM', 'HACKMAN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (176, 'JON', 'CHASE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (177, 'GENE', 'MCKELLEN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (178, 'LISA', 'MONROE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (179, 'ED', 'GUINESS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (180, 'JEFF', 'SILVERSTONE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (181, 'MATTHEW', 'CARREY', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (182, 'DEBBIE', 'AKROYD', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (183, 'RUSSELL', 'CLOSE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (184, 'HUMPHREY', 'GARLAND', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (185, 'MICHAEL', 'BOLGER', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (186, 'JULIA', 'ZELLWEGER', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (187, 'RENEE', 'BALL', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (188, 'ROCK', 'DUKAKIS', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (189, 'CUBA', 'BIRCH', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (190, 'AUDREY', 'BAILEY', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (191, 'GREGORY', 'GOODING', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (192, 'JOHN', 'SUVARI', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (193, 'BURT', 'TEMPLE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (194, 'MERYL', 'ALLEN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (195, 'JAYNE', 'SILVERSTONE', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (196, 'BELA', 'WALKEN', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (197, 'REESE', 'WEST', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (198, 'MARY', 'KEITEL', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (199, 'JULIA', 'FAWCETT', '2006-02-15 09:34:33');
INSERT INTO actor (actor_id, first_name, last_name, last_update) VALUES (200, 'THORA', 'TEMPLE', '2006-02-15 09:34:33');


ALTER TABLE actor ENABLE TRIGGER ALL;

--
-- Data for Name: address; Type: TABLE DATA; Schema: public;
--

ALTER TABLE address DISABLE TRIGGER ALL;



ALTER TABLE address ENABLE TRIGGER ALL;

--
-- Data for Name: category; Type: TABLE DATA; Schema: public;
--

ALTER TABLE category DISABLE TRIGGER ALL;

INSERT INTO category (category_id, name, last_update) VALUES (1, 'Action', '2006-02-15 09:46:27');
INSERT INTO category (category_id, name, last_update) VALUES (2, 'Animation', '2006-02-15 09:46:27');
INSERT INTO category (category_id, name, last_update) VALUES (3, 'Children', '2006-02-15 09:46:27');
INSERT INTO category (category_id, name, last_update) VALUES (4, 'Classics', '2006-02-15 09:46:27');
INSERT INTO category (category_id, name, last_update) VALUES (5, 'Comedy', '2006-02-15 09:46:27');
INSERT INTO category (category_id, name, last_update) VALUES (6, 'Documentary', '2006-02-15 09:46:27');
INSERT INTO category (category_id, name, last_update) VALUES (7, 'Drama', '2006-02-15 09:46:27');
INSERT INTO category (category_id, name, last_update) VALUES (8, 'Family', '2006-02-15 09:46:27');
INSERT INTO category (category_id, name, last_update) VALUES (9, 'Foreign', '2006-02-15 09:46:27');
INSERT INTO category (category_id, name, last_update) VALUES (10, 'Games', '2006-02-15 09:46:27');
INSERT INTO category (category_id, name, last_update) VALUES (11, 'Horror', '2006-02-15 09:46:27');
INSERT INTO category (category_id, name, last_update) VALUES (12, 'Music', '2006-02-15 09:46:27');
INSERT INTO category (category_id, name, last_update) VALUES (13, 'New', '2006-02-15 09:46:27');
INSERT INTO category (category_id, name, last_update) VALUES (14, 'Sci-Fi', '2006-02-15 09:46:27');
INSERT INTO category (category_id, name, last_update) VALUES (15, 'Sports', '2006-02-15 09:46:27');
INSERT INTO category (category_id, name, last_update) VALUES (16, 'Travel', '2006-02-15 09:46:27');


ALTER TABLE category ENABLE TRIGGER ALL;

--
-- Data for Name: city; Type: TABLE DATA; Schema: public;
--

ALTER TABLE city DISABLE TRIGGER ALL;



ALTER TABLE city ENABLE TRIGGER ALL;

--
-- Data for Name: country; Type: TABLE DATA; Schema: public;
--

ALTER TABLE country DISABLE TRIGGER ALL;

INSERT INTO country (country_id, country, last_update) VALUES (1, 'Afghanistan', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (2, 'Algeria', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (3, 'American Samoa', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (4, 'Angola', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (5, 'Anguilla', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (6, 'Argentina', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (7, 'Armenia', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (8, 'Australia', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (9, 'Austria', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (10, 'Azerbaijan', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (11, 'Bahrain', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (12, 'Bangladesh', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (13, 'Belarus', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (14, 'Bolivia', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (15, 'Brazil', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (16, 'Brunei', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (17, 'Bulgaria', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (18, 'Cambodia', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (19, 'Cameroon', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (20, 'Canada', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (21, 'Chad', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (22, 'Chile', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (23, 'China', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (24, 'Colombia', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (25, 'Congo, The Democratic Republic of the', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (26, 'Czech Republic', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (27, 'Dominican Republic', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (28, 'Ecuador', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (29, 'Egypt', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (30, 'Estonia', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (31, 'Ethiopia', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (32, 'Faroe Islands', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (33, 'Finland', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (34, 'France', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (35, 'French Guiana', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (36, 'French Polynesia', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (37, 'Gambia', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (38, 'Germany', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (39, 'Greece', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (40, 'Greenland', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (41, 'Holy See (Vatican City State)', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (42, 'Hong Kong', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (43, 'Hungary', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (44, 'India', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (45, 'Indonesia', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (46, 'Iran', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (47, 'Iraq', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (48, 'Israel', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (49, 'Italy', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (50, 'Japan', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (51, 'Kazakstan', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (52, 'Kenya', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (53, 'Kuwait', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (54, 'Latvia', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (55, 'Liechtenstein', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (56, 'Lithuania', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (57, 'Madagascar', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (58, 'Malawi', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (59, 'Malaysia', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (60, 'Mexico', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (61, 'Moldova', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (62, 'Morocco', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (63, 'Mozambique', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (64, 'Myanmar', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (65, 'Nauru', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (66, 'Nepal', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (67, 'Netherlands', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (68, 'New Zealand', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (69, 'Nigeria', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (70, 'North Korea', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (71, 'Oman', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (72, 'Pakistan', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (73, 'Paraguay', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (74, 'Peru', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (75, 'Philippines', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (76, 'Poland', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (77, 'Puerto Rico', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (78, 'Romania', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (79, 'Runion', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (80, 'Russian Federation', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (81, 'Saint Vincent and the Grenadines', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (82, 'Saudi Arabia', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (83, 'Senegal', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (84, 'Slovakia', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (85, 'South Africa', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (86, 'South Korea', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (87, 'Spain', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (88, 'Sri Lanka', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (89, 'Sudan', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (90, 'Sweden', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (91, 'Switzerland', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (92, 'Taiwan', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (93, 'Tanzania', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (94, 'Thailand', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (95, 'Tonga', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (96, 'Tunisia', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (97, 'Turkey', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (98, 'Turkmenistan', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (99, 'Tuvalu', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (100, 'Ukraine', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (101, 'United Arab Emirates', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (102, 'United Kingdom', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (103, 'United States', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (104, 'Venezuela', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (105, 'Vietnam', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (106, 'Virgin Islands, U.S.', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (107, 'Yemen', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (108, 'Yugoslavia', '2006-02-15 09:44:00');
INSERT INTO country (country_id, country, last_update) VALUES (109, 'Zambia', '2006-02-15 09:44:00');


ALTER TABLE country ENABLE TRIGGER ALL;


--
-- Data for Name: film; Type: TABLE DATA; Schema: public
--

ALTER TABLE film DISABLE TRIGGER ALL;

INSERT INTO film VALUES (1, 'ACADEMY DINOSAUR', 'A Epic Drama of a Feminist And a Mad Scientist who must Battle a Teacher in The Canadian Rockies', 2006, 1, NULL, 6, 0.99, 86, 20.99, 'PG', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''academi'':1 ''battl'':15 ''canadian'':20 ''dinosaur'':2 ''drama'':5 ''epic'':4 ''feminist'':8 ''mad'':11 ''must'':14 ''rocki'':21 ''scientist'':12 ''teacher'':17');
INSERT INTO film VALUES (2, 'ACE GOLDFINGER', 'A Astounding Epistle of a Database Administrator And a Explorer who must Find a Car in Ancient China', 2006, 1, NULL, 3, 4.99, 48, 12.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''ace'':1 ''administr'':9 ''ancient'':19 ''astound'':4 ''car'':17 ''china'':20 ''databas'':8 ''epistl'':5 ''explor'':12 ''find'':15 ''goldfing'':2 ''must'':14');
INSERT INTO film VALUES (3, 'ADAPTATION HOLES', 'A Astounding Reflection of a Lumberjack And a Car who must Sink a Lumberjack in A Baloon Factory', 2006, 1, NULL, 7, 2.99, 50, 18.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''adapt'':1 ''astound'':4 ''baloon'':19 ''car'':11 ''factori'':20 ''hole'':2 ''lumberjack'':8,16 ''must'':13 ''reflect'':5 ''sink'':14');
INSERT INTO film VALUES (4, 'AFFAIR PREJUDICE', 'A Fanciful Documentary of a Frisbee And a Lumberjack who must Chase a Monkey in A Shark Tank', 2006, 1, NULL, 5, 2.99, 117, 26.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''affair'':1 ''chase'':14 ''documentari'':5 ''fanci'':4 ''frisbe'':8 ''lumberjack'':11 ''monkey'':16 ''must'':13 ''prejudic'':2 ''shark'':19 ''tank'':20');
INSERT INTO film VALUES (5, 'AFRICAN EGG', 'A Fast-Paced Documentary of a Pastry Chef And a Dentist who must Pursue a Forensic Psychologist in The Gulf of Mexico', 2006, 1, NULL, 6, 2.99, 130, 22.99, 'G', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''african'':1 ''chef'':11 ''dentist'':14 ''documentari'':7 ''egg'':2 ''fast'':5 ''fast-pac'':4 ''forens'':19 ''gulf'':23 ''mexico'':25 ''must'':16 ''pace'':6 ''pastri'':10 ''psychologist'':20 ''pursu'':17');
INSERT INTO film VALUES (6, 'AGENT TRUMAN', 'A Intrepid Panorama of a Robot And a Boy who must Escape a Sumo Wrestler in Ancient China', 2006, 1, NULL, 3, 2.99, 169, 17.99, 'PG', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''agent'':1 ''ancient'':19 ''boy'':11 ''china'':20 ''escap'':14 ''intrepid'':4 ''must'':13 ''panorama'':5 ''robot'':8 ''sumo'':16 ''truman'':2 ''wrestler'':17');
INSERT INTO film VALUES (7, 'AIRPLANE SIERRA', 'A Touching Saga of a Hunter And a Butler who must Discover a Butler in A Jet Boat', 2006, 1, NULL, 6, 4.99, 62, 28.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''airplan'':1 ''boat'':20 ''butler'':11,16 ''discov'':14 ''hunter'':8 ''jet'':19 ''must'':13 ''saga'':5 ''sierra'':2 ''touch'':4');
INSERT INTO film VALUES (8, 'AIRPORT POLLOCK', 'A Epic Tale of a Moose And a Girl who must Confront a Monkey in Ancient India', 2006, 1, NULL, 6, 4.99, 54, 15.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers}', '''airport'':1 ''ancient'':18 ''confront'':14 ''epic'':4 ''girl'':11 ''india'':19 ''monkey'':16 ''moos'':8 ''must'':13 ''pollock'':2 ''tale'':5');
INSERT INTO film VALUES (9, 'ALABAMA DEVIL', 'A Thoughtful Panorama of a Database Administrator And a Mad Scientist who must Outgun a Mad Scientist in A Jet Boat', 2006, 1, NULL, 3, 2.99, 114, 21.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''administr'':9 ''alabama'':1 ''boat'':23 ''databas'':8 ''devil'':2 ''jet'':22 ''mad'':12,18 ''must'':15 ''outgun'':16 ''panorama'':5 ''scientist'':13,19 ''thought'':4');
INSERT INTO film VALUES (10, 'ALADDIN CALENDAR', 'A Action-Packed Tale of a Man And a Lumberjack who must Reach a Feminist in Ancient China', 2006, 1, NULL, 6, 4.99, 63, 24.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''action'':5 ''action-pack'':4 ''aladdin'':1 ''ancient'':20 ''calendar'':2 ''china'':21 ''feminist'':18 ''lumberjack'':13 ''man'':10 ''must'':15 ''pack'':6 ''reach'':16 ''tale'':7');
INSERT INTO film VALUES (11, 'ALAMO VIDEOTAPE', 'A Boring Epistle of a Butler And a Cat who must Fight a Pastry Chef in A MySQL Convention', 2006, 1, NULL, 6, 0.99, 126, 16.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''alamo'':1 ''bore'':4 ''butler'':8 ''cat'':11 ''chef'':17 ''convent'':21 ''epistl'':5 ''fight'':14 ''must'':13 ''mysql'':20 ''pastri'':16 ''videotap'':2');
INSERT INTO film VALUES (12, 'ALASKA PHANTOM', 'A Fanciful Saga of a Hunter And a Pastry Chef who must Vanquish a Boy in Australia', 2006, 1, NULL, 6, 0.99, 136, 22.99, 'PG', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''alaska'':1 ''australia'':19 ''boy'':17 ''chef'':12 ''fanci'':4 ''hunter'':8 ''must'':14 ''pastri'':11 ''phantom'':2 ''saga'':5 ''vanquish'':15');
INSERT INTO film VALUES (213, 'DATE SPEED', 'A Touching Saga of a Composer And a Moose who must Discover a Dentist in A MySQL Convention', 2006, 1, NULL, 4, 0.99, 104, 19.99, 'R', '2007-09-10 17:46:03.905795', '{Commentaries}', '''compos'':8 ''convent'':20 ''date'':1 ''dentist'':16 ''discov'':14 ''moos'':11 ''must'':13 ''mysql'':19 ''saga'':5 ''speed'':2 ''touch'':4');
INSERT INTO film VALUES (13, 'ALI FOREVER', 'A Action-Packed Drama of a Dentist And a Crocodile who must Battle a Feminist in The Canadian Rockies', 2006, 1, NULL, 4, 4.99, 150, 21.99, 'PG', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''action'':5 ''action-pack'':4 ''ali'':1 ''battl'':16 ''canadian'':21 ''crocodil'':13 ''dentist'':10 ''drama'':7 ''feminist'':18 ''forev'':2 ''must'':15 ''pack'':6 ''rocki'':22');
INSERT INTO film VALUES (14, 'ALICE FANTASIA', 'A Emotional Drama of a A Shark And a Database Administrator who must Vanquish a Pioneer in Soviet Georgia', 2006, 1, NULL, 6, 0.99, 94, 23.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''administr'':13 ''alic'':1 ''databas'':12 ''drama'':5 ''emot'':4 ''fantasia'':2 ''georgia'':21 ''must'':15 ''pioneer'':18 ''shark'':9 ''soviet'':20 ''vanquish'':16');
INSERT INTO film VALUES (15, 'ALIEN CENTER', 'A Brilliant Drama of a Cat And a Mad Scientist who must Battle a Feminist in A MySQL Convention', 2006, 1, NULL, 5, 2.99, 46, 10.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''alien'':1 ''battl'':15 ''brilliant'':4 ''cat'':8 ''center'':2 ''convent'':21 ''drama'':5 ''feminist'':17 ''mad'':11 ''must'':14 ''mysql'':20 ''scientist'':12');
INSERT INTO film VALUES (16, 'ALLEY EVOLUTION', 'A Fast-Paced Drama of a Robot And a Composer who must Battle a Astronaut in New Orleans', 2006, 1, NULL, 6, 2.99, 180, 23.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''alley'':1 ''astronaut'':18 ''battl'':16 ''compos'':13 ''drama'':7 ''evolut'':2 ''fast'':5 ''fast-pac'':4 ''must'':15 ''new'':20 ''orlean'':21 ''pace'':6 ''robot'':10');
INSERT INTO film VALUES (17, 'ALONE TRIP', 'A Fast-Paced Character Study of a Composer And a Dog who must Outgun a Boat in An Abandoned Fun House', 2006, 1, NULL, 3, 0.99, 82, 14.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''abandon'':22 ''alon'':1 ''boat'':19 ''charact'':7 ''compos'':11 ''dog'':14 ''fast'':5 ''fast-pac'':4 ''fun'':23 ''hous'':24 ''must'':16 ''outgun'':17 ''pace'':6 ''studi'':8 ''trip'':2');
INSERT INTO film VALUES (18, 'ALTER VICTORY', 'A Thoughtful Drama of a Composer And a Feminist who must Meet a Secret Agent in The Canadian Rockies', 2006, 1, NULL, 6, 0.99, 57, 27.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''agent'':17 ''alter'':1 ''canadian'':20 ''compos'':8 ''drama'':5 ''feminist'':11 ''meet'':14 ''must'':13 ''rocki'':21 ''secret'':16 ''thought'':4 ''victori'':2');
INSERT INTO film VALUES (19, 'AMADEUS HOLY', 'A Emotional Display of a Pioneer And a Technical Writer who must Battle a Man in A Baloon', 2006, 1, NULL, 6, 0.99, 113, 20.99, 'PG', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''amadeus'':1 ''baloon'':20 ''battl'':15 ''display'':5 ''emot'':4 ''holi'':2 ''man'':17 ''must'':14 ''pioneer'':8 ''technic'':11 ''writer'':12');
INSERT INTO film VALUES (20, 'AMELIE HELLFIGHTERS', 'A Boring Drama of a Woman And a Squirrel who must Conquer a Student in A Baloon', 2006, 1, NULL, 4, 4.99, 79, 23.99, 'R', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''ameli'':1 ''baloon'':19 ''bore'':4 ''conquer'':14 ''drama'':5 ''hellfight'':2 ''must'':13 ''squirrel'':11 ''student'':16 ''woman'':8');
INSERT INTO film VALUES (21, 'AMERICAN CIRCUS', 'A Insightful Drama of a Girl And a Astronaut who must Face a Database Administrator in A Shark Tank', 2006, 1, NULL, 3, 4.99, 129, 17.99, 'R', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''administr'':17 ''american'':1 ''astronaut'':11 ''circus'':2 ''databas'':16 ''drama'':5 ''face'':14 ''girl'':8 ''insight'':4 ''must'':13 ''shark'':20 ''tank'':21');
INSERT INTO film VALUES (22, 'AMISTAD MIDSUMMER', 'A Emotional Character Study of a Dentist And a Crocodile who must Meet a Sumo Wrestler in California', 2006, 1, NULL, 6, 2.99, 85, 10.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''amistad'':1 ''california'':20 ''charact'':5 ''crocodil'':12 ''dentist'':9 ''emot'':4 ''meet'':15 ''midsumm'':2 ''must'':14 ''studi'':6 ''sumo'':17 ''wrestler'':18');
INSERT INTO film VALUES (23, 'ANACONDA CONFESSIONS', 'A Lacklusture Display of a Dentist And a Dentist who must Fight a Girl in Australia', 2006, 1, NULL, 3, 0.99, 92, 9.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''anaconda'':1 ''australia'':18 ''confess'':2 ''dentist'':8,11 ''display'':5 ''fight'':14 ''girl'':16 ''lacklustur'':4 ''must'':13');
INSERT INTO film VALUES (24, 'ANALYZE HOOSIERS', 'A Thoughtful Display of a Explorer And a Pastry Chef who must Overcome a Feminist in The Sahara Desert', 2006, 1, NULL, 6, 2.99, 181, 19.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''analyz'':1 ''chef'':12 ''desert'':21 ''display'':5 ''explor'':8 ''feminist'':17 ''hoosier'':2 ''must'':14 ''overcom'':15 ''pastri'':11 ''sahara'':20 ''thought'':4');
INSERT INTO film VALUES (25, 'ANGELS LIFE', 'A Thoughtful Display of a Woman And a Astronaut who must Battle a Robot in Berlin', 2006, 1, NULL, 3, 2.99, 74, 15.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers}', '''angel'':1 ''astronaut'':11 ''battl'':14 ''berlin'':18 ''display'':5 ''life'':2 ''must'':13 ''robot'':16 ''thought'':4 ''woman'':8');
INSERT INTO film VALUES (26, 'ANNIE IDENTITY', 'A Amazing Panorama of a Pastry Chef And a Boat who must Escape a Woman in An Abandoned Amusement Park', 2006, 1, NULL, 3, 0.99, 86, 15.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''abandon'':20 ''amaz'':4 ''amus'':21 ''anni'':1 ''boat'':12 ''chef'':9 ''escap'':15 ''ident'':2 ''must'':14 ''panorama'':5 ''park'':22 ''pastri'':8 ''woman'':17');
INSERT INTO film VALUES (27, 'ANONYMOUS HUMAN', 'A Amazing Reflection of a Database Administrator And a Astronaut who must Outrace a Database Administrator in A Shark Tank', 2006, 1, NULL, 7, 0.99, 179, 12.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''administr'':9,18 ''amaz'':4 ''anonym'':1 ''astronaut'':12 ''databas'':8,17 ''human'':2 ''must'':14 ''outrac'':15 ''reflect'':5 ''shark'':21 ''tank'':22');
INSERT INTO film VALUES (28, 'ANTHEM LUKE', 'A Touching Panorama of a Waitress And a Woman who must Outrace a Dog in An Abandoned Amusement Park', 2006, 1, NULL, 5, 4.99, 91, 16.99, 'PG-13', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''abandon'':19 ''amus'':20 ''anthem'':1 ''dog'':16 ''luke'':2 ''must'':13 ''outrac'':14 ''panorama'':5 ''park'':21 ''touch'':4 ''waitress'':8 ''woman'':11');
INSERT INTO film VALUES (29, 'ANTITRUST TOMATOES', 'A Fateful Yarn of a Womanizer And a Feminist who must Succumb a Database Administrator in Ancient India', 2006, 1, NULL, 5, 2.99, 168, 11.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''administr'':17 ''ancient'':19 ''antitrust'':1 ''databas'':16 ''fate'':4 ''feminist'':11 ''india'':20 ''must'':13 ''succumb'':14 ''tomato'':2 ''woman'':8 ''yarn'':5');
INSERT INTO film VALUES (30, 'ANYTHING SAVANNAH', 'A Epic Story of a Pastry Chef And a Woman who must Chase a Feminist in An Abandoned Fun House', 2006, 1, NULL, 4, 2.99, 82, 27.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''abandon'':20 ''anyth'':1 ''chase'':15 ''chef'':9 ''epic'':4 ''feminist'':17 ''fun'':21 ''hous'':22 ''must'':14 ''pastri'':8 ''savannah'':2 ''stori'':5 ''woman'':12');
INSERT INTO film VALUES (31, 'APACHE DIVINE', 'A Awe-Inspiring Reflection of a Pastry Chef And a Teacher who must Overcome a Sumo Wrestler in A U-Boat', 2006, 1, NULL, 5, 4.99, 92, 16.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''apach'':1 ''awe'':5 ''awe-inspir'':4 ''boat'':25 ''chef'':11 ''divin'':2 ''inspir'':6 ''must'':16 ''overcom'':17 ''pastri'':10 ''reflect'':7 ''sumo'':19 ''teacher'':14 ''u'':24 ''u-boat'':23 ''wrestler'':20');
INSERT INTO film VALUES (32, 'APOCALYPSE FLAMINGOS', 'A Astounding Story of a Dog And a Squirrel who must Defeat a Woman in An Abandoned Amusement Park', 2006, 1, NULL, 6, 4.99, 119, 11.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''abandon'':19 ''amus'':20 ''apocalyps'':1 ''astound'':4 ''defeat'':14 ''dog'':8 ''flamingo'':2 ''must'':13 ''park'':21 ''squirrel'':11 ''stori'':5 ''woman'':16');
INSERT INTO film VALUES (33, 'APOLLO TEEN', 'A Action-Packed Reflection of a Crocodile And a Explorer who must Find a Sumo Wrestler in An Abandoned Mine Shaft', 2006, 1, NULL, 5, 2.99, 153, 15.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''abandon'':22 ''action'':5 ''action-pack'':4 ''apollo'':1 ''crocodil'':10 ''explor'':13 ''find'':16 ''mine'':23 ''must'':15 ''pack'':6 ''reflect'':7 ''shaft'':24 ''sumo'':18 ''teen'':2 ''wrestler'':19');
INSERT INTO film VALUES (34, 'ARABIA DOGMA', 'A Touching Epistle of a Madman And a Mad Cow who must Defeat a Student in Nigeria', 2006, 1, NULL, 6, 0.99, 62, 29.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''arabia'':1 ''cow'':12 ''defeat'':15 ''dogma'':2 ''epistl'':5 ''mad'':11 ''madman'':8 ''must'':14 ''nigeria'':19 ''student'':17 ''touch'':4');
INSERT INTO film VALUES (35, 'ARACHNOPHOBIA ROLLERCOASTER', 'A Action-Packed Reflection of a Pastry Chef And a Composer who must Discover a Mad Scientist in The First Manned Space Station', 2006, 1, NULL, 4, 2.99, 147, 24.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''action'':5 ''action-pack'':4 ''arachnophobia'':1 ''chef'':11 ''compos'':14 ''discov'':17 ''first'':23 ''mad'':19 ''man'':24 ''must'':16 ''pack'':6 ''pastri'':10 ''reflect'':7 ''rollercoast'':2 ''scientist'':20 ''space'':25 ''station'':26');
INSERT INTO film VALUES (36, 'ARGONAUTS TOWN', 'A Emotional Epistle of a Forensic Psychologist And a Butler who must Challenge a Waitress in An Abandoned Mine Shaft', 2006, 1, NULL, 7, 0.99, 127, 12.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''abandon'':20 ''argonaut'':1 ''butler'':12 ''challeng'':15 ''emot'':4 ''epistl'':5 ''forens'':8 ''mine'':21 ''must'':14 ''psychologist'':9 ''shaft'':22 ''town'':2 ''waitress'':17');
INSERT INTO film VALUES (37, 'ARIZONA BANG', 'A Brilliant Panorama of a Mad Scientist And a Mad Cow who must Meet a Pioneer in A Monastery', 2006, 1, NULL, 3, 2.99, 121, 28.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''arizona'':1 ''bang'':2 ''brilliant'':4 ''cow'':13 ''mad'':8,12 ''meet'':16 ''monasteri'':21 ''must'':15 ''panorama'':5 ''pioneer'':18 ''scientist'':9');
INSERT INTO film VALUES (38, 'ARK RIDGEMONT', 'A Beautiful Yarn of a Pioneer And a Monkey who must Pursue a Explorer in The Sahara Desert', 2006, 1, NULL, 6, 0.99, 68, 25.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''ark'':1 ''beauti'':4 ''desert'':20 ''explor'':16 ''monkey'':11 ''must'':13 ''pioneer'':8 ''pursu'':14 ''ridgemont'':2 ''sahara'':19 ''yarn'':5');
INSERT INTO film VALUES (39, 'ARMAGEDDON LOST', 'A Fast-Paced Tale of a Boat And a Teacher who must Succumb a Composer in An Abandoned Mine Shaft', 2006, 1, NULL, 5, 0.99, 99, 10.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers}', '''abandon'':21 ''armageddon'':1 ''boat'':10 ''compos'':18 ''fast'':5 ''fast-pac'':4 ''lost'':2 ''mine'':22 ''must'':15 ''pace'':6 ''shaft'':23 ''succumb'':16 ''tale'':7 ''teacher'':13');
INSERT INTO film VALUES (40, 'ARMY FLINTSTONES', 'A Boring Saga of a Database Administrator And a Womanizer who must Battle a Waitress in Nigeria', 2006, 1, NULL, 4, 0.99, 148, 22.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''administr'':9 ''armi'':1 ''battl'':15 ''bore'':4 ''databas'':8 ''flintston'':2 ''must'':14 ''nigeria'':19 ''saga'':5 ''waitress'':17 ''woman'':12');
INSERT INTO film VALUES (41, 'ARSENIC INDEPENDENCE', 'A Fanciful Documentary of a Mad Cow And a Womanizer who must Find a Dentist in Berlin', 2006, 1, NULL, 4, 0.99, 137, 17.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''arsenic'':1 ''berlin'':19 ''cow'':9 ''dentist'':17 ''documentari'':5 ''fanci'':4 ''find'':15 ''independ'':2 ''mad'':8 ''must'':14 ''woman'':12');
INSERT INTO film VALUES (42, 'ARTIST COLDBLOODED', 'A Stunning Reflection of a Robot And a Moose who must Challenge a Woman in California', 2006, 1, NULL, 5, 2.99, 170, 10.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''artist'':1 ''california'':18 ''challeng'':14 ''coldblood'':2 ''moos'':11 ''must'':13 ''reflect'':5 ''robot'':8 ''stun'':4 ''woman'':16');
INSERT INTO film VALUES (43, 'ATLANTIS CAUSE', 'A Thrilling Yarn of a Feminist And a Hunter who must Fight a Technical Writer in A Shark Tank', 2006, 1, NULL, 6, 2.99, 170, 15.99, 'G', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''atlanti'':1 ''caus'':2 ''feminist'':8 ''fight'':14 ''hunter'':11 ''must'':13 ''shark'':20 ''tank'':21 ''technic'':16 ''thrill'':4 ''writer'':17 ''yarn'':5');
INSERT INTO film VALUES (44, 'ATTACKS HATE', 'A Fast-Paced Panorama of a Technical Writer And a Mad Scientist who must Find a Feminist in An Abandoned Mine Shaft', 2006, 1, NULL, 5, 4.99, 113, 21.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''abandon'':23 ''attack'':1 ''fast'':5 ''fast-pac'':4 ''feminist'':20 ''find'':18 ''hate'':2 ''mad'':14 ''mine'':24 ''must'':17 ''pace'':6 ''panorama'':7 ''scientist'':15 ''shaft'':25 ''technic'':10 ''writer'':11');
INSERT INTO film VALUES (45, 'ATTRACTION NEWTON', 'A Astounding Panorama of a Composer And a Frisbee who must Reach a Husband in Ancient Japan', 2006, 1, NULL, 5, 4.99, 83, 14.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''ancient'':18 ''astound'':4 ''attract'':1 ''compos'':8 ''frisbe'':11 ''husband'':16 ''japan'':19 ''must'':13 ''newton'':2 ''panorama'':5 ''reach'':14');
INSERT INTO film VALUES (46, 'AUTUMN CROW', 'A Beautiful Tale of a Dentist And a Mad Cow who must Battle a Moose in The Sahara Desert', 2006, 1, NULL, 3, 4.99, 108, 13.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''autumn'':1 ''battl'':15 ''beauti'':4 ''cow'':12 ''crow'':2 ''dentist'':8 ''desert'':21 ''mad'':11 ''moos'':17 ''must'':14 ''sahara'':20 ''tale'':5');
INSERT INTO film VALUES (47, 'BABY HALL', 'A Boring Character Study of a A Shark And a Girl who must Outrace a Feminist in An Abandoned Mine Shaft', 2006, 1, NULL, 5, 4.99, 153, 23.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries}', '''abandon'':21 ''babi'':1 ''bore'':4 ''charact'':5 ''feminist'':18 ''girl'':13 ''hall'':2 ''mine'':22 ''must'':15 ''outrac'':16 ''shaft'':23 ''shark'':10 ''studi'':6');
INSERT INTO film VALUES (48, 'BACKLASH UNDEFEATED', 'A Stunning Character Study of a Mad Scientist And a Mad Cow who must Kill a Car in A Monastery', 2006, 1, NULL, 3, 4.99, 118, 24.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''backlash'':1 ''car'':19 ''charact'':5 ''cow'':14 ''kill'':17 ''mad'':9,13 ''monasteri'':22 ''must'':16 ''scientist'':10 ''studi'':6 ''stun'':4 ''undef'':2');
INSERT INTO film VALUES (49, 'BADMAN DAWN', 'A Emotional Panorama of a Pioneer And a Composer who must Escape a Mad Scientist in A Jet Boat', 2006, 1, NULL, 6, 2.99, 162, 22.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''badman'':1 ''boat'':21 ''compos'':11 ''dawn'':2 ''emot'':4 ''escap'':14 ''jet'':20 ''mad'':16 ''must'':13 ''panorama'':5 ''pioneer'':8 ''scientist'':17');
INSERT INTO film VALUES (50, 'BAKED CLEOPATRA', 'A Stunning Drama of a Forensic Psychologist And a Husband who must Overcome a Waitress in A Monastery', 2006, 1, NULL, 3, 2.99, 182, 20.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''bake'':1 ''cleopatra'':2 ''drama'':5 ''forens'':8 ''husband'':12 ''monasteri'':20 ''must'':14 ''overcom'':15 ''psychologist'':9 ''stun'':4 ''waitress'':17');
INSERT INTO film VALUES (51, 'BALLOON HOMEWARD', 'A Insightful Panorama of a Forensic Psychologist And a Mad Cow who must Build a Mad Scientist in The First Manned Space Station', 2006, 1, NULL, 5, 2.99, 75, 10.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''balloon'':1 ''build'':16 ''cow'':13 ''first'':22 ''forens'':8 ''homeward'':2 ''insight'':4 ''mad'':12,18 ''man'':23 ''must'':15 ''panorama'':5 ''psychologist'':9 ''scientist'':19 ''space'':24 ''station'':25');
INSERT INTO film VALUES (52, 'BALLROOM MOCKINGBIRD', 'A Thrilling Documentary of a Composer And a Monkey who must Find a Feminist in California', 2006, 1, NULL, 6, 0.99, 173, 29.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''ballroom'':1 ''california'':18 ''compos'':8 ''documentari'':5 ''feminist'':16 ''find'':14 ''mockingbird'':2 ''monkey'':11 ''must'':13 ''thrill'':4');
INSERT INTO film VALUES (53, 'BANG KWAI', 'A Epic Drama of a Madman And a Cat who must Face a A Shark in An Abandoned Amusement Park', 2006, 1, NULL, 5, 2.99, 87, 25.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''abandon'':20 ''amus'':21 ''bang'':1 ''cat'':11 ''drama'':5 ''epic'':4 ''face'':14 ''kwai'':2 ''madman'':8 ''must'':13 ''park'':22 ''shark'':17');
INSERT INTO film VALUES (54, 'BANGER PINOCCHIO', 'A Awe-Inspiring Drama of a Car And a Pastry Chef who must Chase a Crocodile in The First Manned Space Station', 2006, 1, NULL, 5, 0.99, 113, 15.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''awe'':5 ''awe-inspir'':4 ''banger'':1 ''car'':10 ''chase'':17 ''chef'':14 ''crocodil'':19 ''drama'':7 ''first'':22 ''inspir'':6 ''man'':23 ''must'':16 ''pastri'':13 ''pinocchio'':2 ''space'':24 ''station'':25');
INSERT INTO film VALUES (55, 'BARBARELLA STREETCAR', 'A Awe-Inspiring Story of a Feminist And a Cat who must Conquer a Dog in A Monastery', 2006, 1, NULL, 6, 2.99, 65, 27.99, 'G', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''awe'':5 ''awe-inspir'':4 ''barbarella'':1 ''cat'':13 ''conquer'':16 ''dog'':18 ''feminist'':10 ''inspir'':6 ''monasteri'':21 ''must'':15 ''stori'':7 ''streetcar'':2');
INSERT INTO film VALUES (56, 'BAREFOOT MANCHURIAN', 'A Intrepid Story of a Cat And a Student who must Vanquish a Girl in An Abandoned Amusement Park', 2006, 1, NULL, 6, 2.99, 129, 15.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''abandon'':19 ''amus'':20 ''barefoot'':1 ''cat'':8 ''girl'':16 ''intrepid'':4 ''manchurian'':2 ''must'':13 ''park'':21 ''stori'':5 ''student'':11 ''vanquish'':14');
INSERT INTO film VALUES (57, 'BASIC EASY', 'A Stunning Epistle of a Man And a Husband who must Reach a Mad Scientist in A Jet Boat', 2006, 1, NULL, 4, 2.99, 90, 18.99, 'PG-13', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''basic'':1 ''boat'':21 ''easi'':2 ''epistl'':5 ''husband'':11 ''jet'':20 ''mad'':16 ''man'':8 ''must'':13 ''reach'':14 ''scientist'':17 ''stun'':4');
INSERT INTO film VALUES (58, 'BEACH HEARTBREAKERS', 'A Fateful Display of a Womanizer And a Mad Scientist who must Outgun a A Shark in Soviet Georgia', 2006, 1, NULL, 6, 2.99, 122, 16.99, 'G', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''beach'':1 ''display'':5 ''fate'':4 ''georgia'':21 ''heartbreak'':2 ''mad'':11 ''must'':14 ''outgun'':15 ''scientist'':12 ''shark'':18 ''soviet'':20 ''woman'':8');
INSERT INTO film VALUES (59, 'BEAR GRACELAND', 'A Astounding Saga of a Dog And a Boy who must Kill a Teacher in The First Manned Space Station', 2006, 1, NULL, 4, 2.99, 160, 20.99, 'R', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''astound'':4 ''bear'':1 ''boy'':11 ''dog'':8 ''first'':19 ''graceland'':2 ''kill'':14 ''man'':20 ''must'':13 ''saga'':5 ''space'':21 ''station'':22 ''teacher'':16');
INSERT INTO film VALUES (60, 'BEAST HUNCHBACK', 'A Awe-Inspiring Epistle of a Student And a Squirrel who must Defeat a Boy in Ancient China', 2006, 1, NULL, 3, 4.99, 89, 22.99, 'R', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''ancient'':20 ''awe'':5 ''awe-inspir'':4 ''beast'':1 ''boy'':18 ''china'':21 ''defeat'':16 ''epistl'':7 ''hunchback'':2 ''inspir'':6 ''must'':15 ''squirrel'':13 ''student'':10');
INSERT INTO film VALUES (61, 'BEAUTY GREASE', 'A Fast-Paced Display of a Composer And a Moose who must Sink a Robot in An Abandoned Mine Shaft', 2006, 1, NULL, 5, 4.99, 175, 28.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''abandon'':21 ''beauti'':1 ''compos'':10 ''display'':7 ''fast'':5 ''fast-pac'':4 ''greas'':2 ''mine'':22 ''moos'':13 ''must'':15 ''pace'':6 ''robot'':18 ''shaft'':23 ''sink'':16');
INSERT INTO film VALUES (62, 'BED HIGHBALL', 'A Astounding Panorama of a Lumberjack And a Dog who must Redeem a Woman in An Abandoned Fun House', 2006, 1, NULL, 5, 2.99, 106, 23.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''abandon'':19 ''astound'':4 ''bed'':1 ''dog'':11 ''fun'':20 ''highbal'':2 ''hous'':21 ''lumberjack'':8 ''must'':13 ''panorama'':5 ''redeem'':14 ''woman'':16');
INSERT INTO film VALUES (63, 'BEDAZZLED MARRIED', 'A Astounding Character Study of a Madman And a Robot who must Meet a Mad Scientist in An Abandoned Fun House', 2006, 1, NULL, 6, 0.99, 73, 21.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''abandon'':21 ''astound'':4 ''bedazzl'':1 ''charact'':5 ''fun'':22 ''hous'':23 ''mad'':17 ''madman'':9 ''marri'':2 ''meet'':15 ''must'':14 ''robot'':12 ''scientist'':18 ''studi'':6');
INSERT INTO film VALUES (64, 'BEETHOVEN EXORCIST', 'A Epic Display of a Pioneer And a Student who must Challenge a Butler in The Gulf of Mexico', 2006, 1, NULL, 6, 0.99, 151, 26.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''beethoven'':1 ''butler'':16 ''challeng'':14 ''display'':5 ''epic'':4 ''exorcist'':2 ''gulf'':19 ''mexico'':21 ''must'':13 ''pioneer'':8 ''student'':11');
INSERT INTO film VALUES (65, 'BEHAVIOR RUNAWAY', 'A Unbelieveable Drama of a Student And a Husband who must Outrace a Sumo Wrestler in Berlin', 2006, 1, NULL, 3, 4.99, 100, 20.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''behavior'':1 ''berlin'':19 ''drama'':5 ''husband'':11 ''must'':13 ''outrac'':14 ''runaway'':2 ''student'':8 ''sumo'':16 ''unbeliev'':4 ''wrestler'':17');
INSERT INTO film VALUES (66, 'BENEATH RUSH', 'A Astounding Panorama of a Man And a Monkey who must Discover a Man in The First Manned Space Station', 2006, 1, NULL, 6, 0.99, 53, 27.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''astound'':4 ''beneath'':1 ''discov'':14 ''first'':19 ''man'':8,16,20 ''monkey'':11 ''must'':13 ''panorama'':5 ''rush'':2 ''space'':21 ''station'':22');
INSERT INTO film VALUES (67, 'BERETS AGENT', 'A Taut Saga of a Crocodile And a Boy who must Overcome a Technical Writer in Ancient China', 2006, 1, NULL, 5, 2.99, 77, 24.99, 'PG-13', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''agent'':2 ''ancient'':19 ''beret'':1 ''boy'':11 ''china'':20 ''crocodil'':8 ''must'':13 ''overcom'':14 ''saga'':5 ''taut'':4 ''technic'':16 ''writer'':17');
INSERT INTO film VALUES (68, 'BETRAYED REAR', 'A Emotional Character Study of a Boat And a Pioneer who must Find a Explorer in A Shark Tank', 2006, 1, NULL, 5, 4.99, 122, 26.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''betray'':1 ''boat'':9 ''charact'':5 ''emot'':4 ''explor'':17 ''find'':15 ''must'':14 ''pioneer'':12 ''rear'':2 ''shark'':20 ''studi'':6 ''tank'':21');
INSERT INTO film VALUES (69, 'BEVERLY OUTLAW', 'A Fanciful Documentary of a Womanizer And a Boat who must Defeat a Madman in The First Manned Space Station', 2006, 1, NULL, 3, 2.99, 85, 21.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers}', '''bever'':1 ''boat'':11 ''defeat'':14 ''documentari'':5 ''fanci'':4 ''first'':19 ''madman'':16 ''man'':20 ''must'':13 ''outlaw'':2 ''space'':21 ''station'':22 ''woman'':8');
INSERT INTO film VALUES (70, 'BIKINI BORROWERS', 'A Astounding Drama of a Astronaut And a Cat who must Discover a Woman in The First Manned Space Station', 2006, 1, NULL, 7, 4.99, 142, 26.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''astound'':4 ''astronaut'':8 ''bikini'':1 ''borrow'':2 ''cat'':11 ''discov'':14 ''drama'':5 ''first'':19 ''man'':20 ''must'':13 ''space'':21 ''station'':22 ''woman'':16');
INSERT INTO film VALUES (71, 'BILKO ANONYMOUS', 'A Emotional Reflection of a Teacher And a Man who must Meet a Cat in The First Manned Space Station', 2006, 1, NULL, 3, 4.99, 100, 25.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''anonym'':2 ''bilko'':1 ''cat'':16 ''emot'':4 ''first'':19 ''man'':11,20 ''meet'':14 ''must'':13 ''reflect'':5 ''space'':21 ''station'':22 ''teacher'':8');
INSERT INTO film VALUES (72, 'BILL OTHERS', 'A Stunning Saga of a Mad Scientist And a Forensic Psychologist who must Challenge a Squirrel in A MySQL Convention', 2006, 1, NULL, 6, 2.99, 93, 12.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''bill'':1 ''challeng'':16 ''convent'':22 ''forens'':12 ''mad'':8 ''must'':15 ''mysql'':21 ''other'':2 ''psychologist'':13 ''saga'':5 ''scientist'':9 ''squirrel'':18 ''stun'':4');
INSERT INTO film VALUES (73, 'BINGO TALENTED', 'A Touching Tale of a Girl And a Crocodile who must Discover a Waitress in Nigeria', 2006, 1, NULL, 5, 2.99, 150, 22.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''bingo'':1 ''crocodil'':11 ''discov'':14 ''girl'':8 ''must'':13 ''nigeria'':18 ''tale'':5 ''talent'':2 ''touch'':4 ''waitress'':16');
INSERT INTO film VALUES (74, 'BIRCH ANTITRUST', 'A Fanciful Panorama of a Husband And a Pioneer who must Outgun a Dog in A Baloon', 2006, 1, NULL, 4, 4.99, 162, 18.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''antitrust'':2 ''baloon'':19 ''birch'':1 ''dog'':16 ''fanci'':4 ''husband'':8 ''must'':13 ''outgun'':14 ''panorama'':5 ''pioneer'':11');
INSERT INTO film VALUES (75, 'BIRD INDEPENDENCE', 'A Thrilling Documentary of a Car And a Student who must Sink a Hunter in The Canadian Rockies', 2006, 1, NULL, 6, 4.99, 163, 14.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''bird'':1 ''canadian'':19 ''car'':8 ''documentari'':5 ''hunter'':16 ''independ'':2 ''must'':13 ''rocki'':20 ''sink'':14 ''student'':11 ''thrill'':4');
INSERT INTO film VALUES (76, 'BIRDCAGE CASPER', 'A Fast-Paced Saga of a Frisbee And a Astronaut who must Overcome a Feminist in Ancient India', 2006, 1, NULL, 4, 0.99, 103, 23.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''ancient'':20 ''astronaut'':13 ''birdcag'':1 ''casper'':2 ''fast'':5 ''fast-pac'':4 ''feminist'':18 ''frisbe'':10 ''india'':21 ''must'':15 ''overcom'':16 ''pace'':6 ''saga'':7');
INSERT INTO film VALUES (77, 'BIRDS PERDITION', 'A Boring Story of a Womanizer And a Pioneer who must Face a Dog in California', 2006, 1, NULL, 5, 4.99, 61, 15.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''bird'':1 ''bore'':4 ''california'':18 ''dog'':16 ''face'':14 ''must'':13 ''perdit'':2 ''pioneer'':11 ''stori'':5 ''woman'':8');
INSERT INTO film VALUES (78, 'BLACKOUT PRIVATE', 'A Intrepid Yarn of a Pastry Chef And a Mad Scientist who must Challenge a Secret Agent in Ancient Japan', 2006, 1, NULL, 7, 2.99, 85, 12.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''agent'':19 ''ancient'':21 ''blackout'':1 ''challeng'':16 ''chef'':9 ''intrepid'':4 ''japan'':22 ''mad'':12 ''must'':15 ''pastri'':8 ''privat'':2 ''scientist'':13 ''secret'':18 ''yarn'':5');
INSERT INTO film VALUES (79, 'BLADE POLISH', 'A Thoughtful Character Study of a Frisbee And a Pastry Chef who must Fight a Dentist in The First Manned Space Station', 2006, 1, NULL, 5, 0.99, 114, 10.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''blade'':1 ''charact'':5 ''chef'':13 ''dentist'':18 ''fight'':16 ''first'':21 ''frisbe'':9 ''man'':22 ''must'':15 ''pastri'':12 ''polish'':2 ''space'':23 ''station'':24 ''studi'':6 ''thought'':4');
INSERT INTO film VALUES (80, 'BLANKET BEVERLY', 'A Emotional Documentary of a Student And a Girl who must Build a Boat in Nigeria', 2006, 1, NULL, 7, 2.99, 148, 21.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers}', '''bever'':2 ''blanket'':1 ''boat'':16 ''build'':14 ''documentari'':5 ''emot'':4 ''girl'':11 ''must'':13 ''nigeria'':18 ''student'':8');
INSERT INTO film VALUES (81, 'BLINDNESS GUN', 'A Touching Drama of a Robot And a Dentist who must Meet a Hunter in A Jet Boat', 2006, 1, NULL, 6, 4.99, 103, 29.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''blind'':1 ''boat'':20 ''dentist'':11 ''drama'':5 ''gun'':2 ''hunter'':16 ''jet'':19 ''meet'':14 ''must'':13 ''robot'':8 ''touch'':4');
INSERT INTO film VALUES (82, 'BLOOD ARGONAUTS', 'A Boring Drama of a Explorer And a Man who must Kill a Lumberjack in A Manhattan Penthouse', 2006, 1, NULL, 3, 0.99, 71, 13.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''argonaut'':2 ''blood'':1 ''bore'':4 ''drama'':5 ''explor'':8 ''kill'':14 ''lumberjack'':16 ''man'':11 ''manhattan'':19 ''must'':13 ''penthous'':20');
INSERT INTO film VALUES (83, 'BLUES INSTINCT', 'A Insightful Documentary of a Boat And a Composer who must Meet a Forensic Psychologist in An Abandoned Fun House', 2006, 1, NULL, 5, 2.99, 50, 18.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''abandon'':20 ''blue'':1 ''boat'':8 ''compos'':11 ''documentari'':5 ''forens'':16 ''fun'':21 ''hous'':22 ''insight'':4 ''instinct'':2 ''meet'':14 ''must'':13 ''psychologist'':17');
INSERT INTO film VALUES (84, 'BOILED DARES', 'A Awe-Inspiring Story of a Waitress And a Dog who must Discover a Dentist in Ancient Japan', 2006, 1, NULL, 7, 4.99, 102, 13.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''ancient'':20 ''awe'':5 ''awe-inspir'':4 ''boil'':1 ''dare'':2 ''dentist'':18 ''discov'':16 ''dog'':13 ''inspir'':6 ''japan'':21 ''must'':15 ''stori'':7 ''waitress'':10');
INSERT INTO film VALUES (85, 'BONNIE HOLOCAUST', 'A Fast-Paced Story of a Crocodile And a Robot who must Find a Moose in Ancient Japan', 2006, 1, NULL, 4, 0.99, 63, 29.99, 'G', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''ancient'':20 ''bonni'':1 ''crocodil'':10 ''fast'':5 ''fast-pac'':4 ''find'':16 ''holocaust'':2 ''japan'':21 ''moos'':18 ''must'':15 ''pace'':6 ''robot'':13 ''stori'':7');
INSERT INTO film VALUES (86, 'BOOGIE AMELIE', 'A Lacklusture Character Study of a Husband And a Sumo Wrestler who must Succumb a Technical Writer in The Gulf of Mexico', 2006, 1, NULL, 6, 4.99, 121, 11.99, 'R', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''ameli'':2 ''boogi'':1 ''charact'':5 ''gulf'':22 ''husband'':9 ''lacklustur'':4 ''mexico'':24 ''must'':15 ''studi'':6 ''succumb'':16 ''sumo'':12 ''technic'':18 ''wrestler'':13 ''writer'':19');
INSERT INTO film VALUES (87, 'BOONDOCK BALLROOM', 'A Fateful Panorama of a Crocodile And a Boy who must Defeat a Monkey in The Gulf of Mexico', 2006, 1, NULL, 7, 0.99, 76, 14.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''ballroom'':2 ''boondock'':1 ''boy'':11 ''crocodil'':8 ''defeat'':14 ''fate'':4 ''gulf'':19 ''mexico'':21 ''monkey'':16 ''must'':13 ''panorama'':5');
INSERT INTO film VALUES (88, 'BORN SPINAL', 'A Touching Epistle of a Frisbee And a Husband who must Pursue a Student in Nigeria', 2006, 1, NULL, 7, 4.99, 179, 17.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''born'':1 ''epistl'':5 ''frisbe'':8 ''husband'':11 ''must'':13 ''nigeria'':18 ''pursu'':14 ''spinal'':2 ''student'':16 ''touch'':4');
INSERT INTO film VALUES (89, 'BORROWERS BEDAZZLED', 'A Brilliant Epistle of a Teacher And a Sumo Wrestler who must Defeat a Man in An Abandoned Fun House', 2006, 1, NULL, 7, 0.99, 63, 22.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''abandon'':20 ''bedazzl'':2 ''borrow'':1 ''brilliant'':4 ''defeat'':15 ''epistl'':5 ''fun'':21 ''hous'':22 ''man'':17 ''must'':14 ''sumo'':11 ''teacher'':8 ''wrestler'':12');
INSERT INTO film VALUES (90, 'BOULEVARD MOB', 'A Fateful Epistle of a Moose And a Monkey who must Confront a Lumberjack in Ancient China', 2006, 1, NULL, 3, 0.99, 63, 11.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers}', '''ancient'':18 ''boulevard'':1 ''china'':19 ''confront'':14 ''epistl'':5 ''fate'':4 ''lumberjack'':16 ''mob'':2 ''monkey'':11 ''moos'':8 ''must'':13');
INSERT INTO film VALUES (91, 'BOUND CHEAPER', 'A Thrilling Panorama of a Database Administrator And a Astronaut who must Challenge a Lumberjack in A Baloon', 2006, 1, NULL, 5, 0.99, 98, 17.99, 'PG', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''administr'':9 ''astronaut'':12 ''baloon'':20 ''bound'':1 ''challeng'':15 ''cheaper'':2 ''databas'':8 ''lumberjack'':17 ''must'':14 ''panorama'':5 ''thrill'':4');
INSERT INTO film VALUES (92, 'BOWFINGER GABLES', 'A Fast-Paced Yarn of a Waitress And a Composer who must Outgun a Dentist in California', 2006, 1, NULL, 7, 4.99, 72, 19.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''bowfing'':1 ''california'':20 ''compos'':13 ''dentist'':18 ''fast'':5 ''fast-pac'':4 ''gabl'':2 ''must'':15 ''outgun'':16 ''pace'':6 ''waitress'':10 ''yarn'':7');
INSERT INTO film VALUES (93, 'BRANNIGAN SUNRISE', 'A Amazing Epistle of a Moose And a Crocodile who must Outrace a Dog in Berlin', 2006, 1, NULL, 4, 4.99, 121, 27.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers}', '''amaz'':4 ''berlin'':18 ''brannigan'':1 ''crocodil'':11 ''dog'':16 ''epistl'':5 ''moos'':8 ''must'':13 ''outrac'':14 ''sunris'':2');
INSERT INTO film VALUES (94, 'BRAVEHEART HUMAN', 'A Insightful Story of a Dog And a Pastry Chef who must Battle a Girl in Berlin', 2006, 1, NULL, 7, 2.99, 176, 14.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''battl'':15 ''berlin'':19 ''braveheart'':1 ''chef'':12 ''dog'':8 ''girl'':17 ''human'':2 ''insight'':4 ''must'':14 ''pastri'':11 ''stori'':5');
INSERT INTO film VALUES (95, 'BREAKFAST GOLDFINGER', 'A Beautiful Reflection of a Student And a Student who must Fight a Moose in Berlin', 2006, 1, NULL, 5, 4.99, 123, 18.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''beauti'':4 ''berlin'':18 ''breakfast'':1 ''fight'':14 ''goldfing'':2 ''moos'':16 ''must'':13 ''reflect'':5 ''student'':8,11');
INSERT INTO film VALUES (96, 'BREAKING HOME', 'A Beautiful Display of a Secret Agent And a Monkey who must Battle a Sumo Wrestler in An Abandoned Mine Shaft', 2006, 1, NULL, 4, 2.99, 169, 21.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''abandon'':21 ''agent'':9 ''battl'':15 ''beauti'':4 ''break'':1 ''display'':5 ''home'':2 ''mine'':22 ''monkey'':12 ''must'':14 ''secret'':8 ''shaft'':23 ''sumo'':17 ''wrestler'':18');
INSERT INTO film VALUES (97, 'BRIDE INTRIGUE', 'A Epic Tale of a Robot And a Monkey who must Vanquish a Man in New Orleans', 2006, 1, NULL, 7, 0.99, 56, 24.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''bride'':1 ''epic'':4 ''intrigu'':2 ''man'':16 ''monkey'':11 ''must'':13 ''new'':18 ''orlean'':19 ''robot'':8 ''tale'':5 ''vanquish'':14');
INSERT INTO film VALUES (98, 'BRIGHT ENCOUNTERS', 'A Fateful Yarn of a Lumberjack And a Feminist who must Conquer a Student in A Jet Boat', 2006, 1, NULL, 4, 4.99, 73, 12.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers}', '''boat'':20 ''bright'':1 ''conquer'':14 ''encount'':2 ''fate'':4 ''feminist'':11 ''jet'':19 ''lumberjack'':8 ''must'':13 ''student'':16 ''yarn'':5');
INSERT INTO film VALUES (99, 'BRINGING HYSTERICAL', 'A Fateful Saga of a A Shark And a Technical Writer who must Find a Woman in A Jet Boat', 2006, 1, NULL, 7, 2.99, 136, 14.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers}', '''boat'':22 ''bring'':1 ''fate'':4 ''find'':16 ''hyster'':2 ''jet'':21 ''must'':15 ''saga'':5 ''shark'':9 ''technic'':12 ''woman'':18 ''writer'':13');
INSERT INTO film VALUES (100, 'BROOKLYN DESERT', 'A Beautiful Drama of a Dentist And a Composer who must Battle a Sumo Wrestler in The First Manned Space Station', 2006, 1, NULL, 7, 4.99, 161, 21.99, 'R', '2007-09-10 17:46:03.905795', '{Commentaries}', '''battl'':14 ''beauti'':4 ''brooklyn'':1 ''compos'':11 ''dentist'':8 ''desert'':2 ''drama'':5 ''first'':20 ''man'':21 ''must'':13 ''space'':22 ''station'':23 ''sumo'':16 ''wrestler'':17');
INSERT INTO film VALUES (101, 'BROTHERHOOD BLANKET', 'A Fateful Character Study of a Butler And a Technical Writer who must Sink a Astronaut in Ancient Japan', 2006, 1, NULL, 3, 0.99, 73, 26.99, 'R', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''ancient'':20 ''astronaut'':18 ''blanket'':2 ''brotherhood'':1 ''butler'':9 ''charact'':5 ''fate'':4 ''japan'':21 ''must'':15 ''sink'':16 ''studi'':6 ''technic'':12 ''writer'':13');
INSERT INTO film VALUES (102, 'BUBBLE GROSSE', 'A Awe-Inspiring Panorama of a Crocodile And a Moose who must Confront a Girl in A Baloon', 2006, 1, NULL, 4, 4.99, 60, 20.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''awe'':5 ''awe-inspir'':4 ''baloon'':21 ''bubbl'':1 ''confront'':16 ''crocodil'':10 ''girl'':18 ''gross'':2 ''inspir'':6 ''moos'':13 ''must'':15 ''panorama'':7');
INSERT INTO film VALUES (103, 'BUCKET BROTHERHOOD', 'A Amazing Display of a Girl And a Womanizer who must Succumb a Lumberjack in A Baloon Factory', 2006, 1, NULL, 7, 4.99, 133, 27.99, 'PG', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''amaz'':4 ''baloon'':19 ''brotherhood'':2 ''bucket'':1 ''display'':5 ''factori'':20 ''girl'':8 ''lumberjack'':16 ''must'':13 ''succumb'':14 ''woman'':11');
INSERT INTO film VALUES (104, 'BUGSY SONG', 'A Awe-Inspiring Character Study of a Secret Agent And a Boat who must Find a Squirrel in The First Manned Space Station', 2006, 1, NULL, 4, 2.99, 119, 17.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries}', '''agent'':12 ''awe'':5 ''awe-inspir'':4 ''boat'':15 ''bugsi'':1 ''charact'':7 ''find'':18 ''first'':23 ''inspir'':6 ''man'':24 ''must'':17 ''secret'':11 ''song'':2 ''space'':25 ''squirrel'':20 ''station'':26 ''studi'':8');
INSERT INTO film VALUES (105, 'BULL SHAWSHANK', 'A Fanciful Drama of a Moose And a Squirrel who must Conquer a Pioneer in The Canadian Rockies', 2006, 1, NULL, 6, 0.99, 125, 21.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''bull'':1 ''canadian'':19 ''conquer'':14 ''drama'':5 ''fanci'':4 ''moos'':8 ''must'':13 ''pioneer'':16 ''rocki'':20 ''shawshank'':2 ''squirrel'':11');
INSERT INTO film VALUES (106, 'BULWORTH COMMANDMENTS', 'A Amazing Display of a Mad Cow And a Pioneer who must Redeem a Sumo Wrestler in The Outback', 2006, 1, NULL, 4, 2.99, 61, 14.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers}', '''amaz'':4 ''bulworth'':1 ''command'':2 ''cow'':9 ''display'':5 ''mad'':8 ''must'':14 ''outback'':21 ''pioneer'':12 ''redeem'':15 ''sumo'':17 ''wrestler'':18');
INSERT INTO film VALUES (107, 'BUNCH MINDS', 'A Emotional Story of a Feminist And a Feminist who must Escape a Pastry Chef in A MySQL Convention', 2006, 1, NULL, 4, 2.99, 63, 13.99, 'G', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''bunch'':1 ''chef'':17 ''convent'':21 ''emot'':4 ''escap'':14 ''feminist'':8,11 ''mind'':2 ''must'':13 ''mysql'':20 ''pastri'':16 ''stori'':5');
INSERT INTO film VALUES (108, 'BUTCH PANTHER', 'A Lacklusture Yarn of a Feminist And a Database Administrator who must Face a Hunter in New Orleans', 2006, 1, NULL, 6, 0.99, 67, 19.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''administr'':12 ''butch'':1 ''databas'':11 ''face'':15 ''feminist'':8 ''hunter'':17 ''lacklustur'':4 ''must'':14 ''new'':19 ''orlean'':20 ''panther'':2 ''yarn'':5');
INSERT INTO film VALUES (109, 'BUTTERFLY CHOCOLAT', 'A Fateful Story of a Girl And a Composer who must Conquer a Husband in A Shark Tank', 2006, 1, NULL, 3, 0.99, 89, 17.99, 'G', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''butterfli'':1 ''chocolat'':2 ''compos'':11 ''conquer'':14 ''fate'':4 ''girl'':8 ''husband'':16 ''must'':13 ''shark'':19 ''stori'':5 ''tank'':20');
INSERT INTO film VALUES (110, 'CABIN FLASH', 'A Stunning Epistle of a Boat And a Man who must Challenge a A Shark in A Baloon Factory', 2006, 1, NULL, 4, 0.99, 53, 25.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''baloon'':20 ''boat'':8 ''cabin'':1 ''challeng'':14 ''epistl'':5 ''factori'':21 ''flash'':2 ''man'':11 ''must'':13 ''shark'':17 ''stun'':4');
INSERT INTO film VALUES (111, 'CADDYSHACK JEDI', 'A Awe-Inspiring Epistle of a Woman And a Madman who must Fight a Robot in Soviet Georgia', 2006, 1, NULL, 3, 0.99, 52, 17.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''awe'':5 ''awe-inspir'':4 ''caddyshack'':1 ''epistl'':7 ''fight'':16 ''georgia'':21 ''inspir'':6 ''jedi'':2 ''madman'':13 ''must'':15 ''robot'':18 ''soviet'':20 ''woman'':10');
INSERT INTO film VALUES (112, 'CALENDAR GUNFIGHT', 'A Thrilling Drama of a Frisbee And a Lumberjack who must Sink a Man in Nigeria', 2006, 1, NULL, 4, 4.99, 120, 22.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''calendar'':1 ''drama'':5 ''frisbe'':8 ''gunfight'':2 ''lumberjack'':11 ''man'':16 ''must'':13 ''nigeria'':18 ''sink'':14 ''thrill'':4');
INSERT INTO film VALUES (113, 'CALIFORNIA BIRDS', 'A Thrilling Yarn of a Database Administrator And a Robot who must Battle a Database Administrator in Ancient India', 2006, 1, NULL, 4, 4.99, 75, 19.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''administr'':9,18 ''ancient'':20 ''battl'':15 ''bird'':2 ''california'':1 ''databas'':8,17 ''india'':21 ''must'':14 ''robot'':12 ''thrill'':4 ''yarn'':5');
INSERT INTO film VALUES (114, 'CAMELOT VACATION', 'A Touching Character Study of a Woman And a Waitress who must Battle a Pastry Chef in A MySQL Convention', 2006, 1, NULL, 3, 0.99, 61, 26.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''battl'':15 ''camelot'':1 ''charact'':5 ''chef'':18 ''convent'':22 ''must'':14 ''mysql'':21 ''pastri'':17 ''studi'':6 ''touch'':4 ''vacat'':2 ''waitress'':12 ''woman'':9');
INSERT INTO film VALUES (115, 'CAMPUS REMEMBER', 'A Astounding Drama of a Crocodile And a Mad Cow who must Build a Robot in A Jet Boat', 2006, 1, NULL, 5, 2.99, 167, 27.99, 'R', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''astound'':4 ''boat'':21 ''build'':15 ''campus'':1 ''cow'':12 ''crocodil'':8 ''drama'':5 ''jet'':20 ''mad'':11 ''must'':14 ''rememb'':2 ''robot'':17');
INSERT INTO film VALUES (116, 'CANDIDATE PERDITION', 'A Brilliant Epistle of a Composer And a Database Administrator who must Vanquish a Mad Scientist in The First Manned Space Station', 2006, 1, NULL, 4, 2.99, 70, 10.99, 'R', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''administr'':12 ''brilliant'':4 ''candid'':1 ''compos'':8 ''databas'':11 ''epistl'':5 ''first'':21 ''mad'':17 ''man'':22 ''must'':14 ''perdit'':2 ''scientist'':18 ''space'':23 ''station'':24 ''vanquish'':15');
INSERT INTO film VALUES (117, 'CANDLES GRAPES', 'A Fanciful Character Study of a Monkey And a Explorer who must Build a Astronaut in An Abandoned Fun House', 2006, 1, NULL, 6, 4.99, 135, 15.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''abandon'':20 ''astronaut'':17 ''build'':15 ''candl'':1 ''charact'':5 ''explor'':12 ''fanci'':4 ''fun'':21 ''grape'':2 ''hous'':22 ''monkey'':9 ''must'':14 ''studi'':6');
INSERT INTO film VALUES (118, 'CANYON STOCK', 'A Thoughtful Reflection of a Waitress And a Feminist who must Escape a Squirrel in A Manhattan Penthouse', 2006, 1, NULL, 7, 0.99, 85, 26.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''canyon'':1 ''escap'':14 ''feminist'':11 ''manhattan'':19 ''must'':13 ''penthous'':20 ''reflect'':5 ''squirrel'':16 ''stock'':2 ''thought'':4 ''waitress'':8');
INSERT INTO film VALUES (119, 'CAPER MOTIONS', 'A Fateful Saga of a Moose And a Car who must Pursue a Woman in A MySQL Convention', 2006, 1, NULL, 6, 0.99, 176, 22.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''caper'':1 ''car'':11 ''convent'':20 ''fate'':4 ''moos'':8 ''motion'':2 ''must'':13 ''mysql'':19 ''pursu'':14 ''saga'':5 ''woman'':16');
INSERT INTO film VALUES (120, 'CARIBBEAN LIBERTY', 'A Fanciful Tale of a Pioneer And a Technical Writer who must Outgun a Pioneer in A Shark Tank', 2006, 1, NULL, 3, 4.99, 92, 16.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''caribbean'':1 ''fanci'':4 ''liberti'':2 ''must'':14 ''outgun'':15 ''pioneer'':8,17 ''shark'':20 ''tale'':5 ''tank'':21 ''technic'':11 ''writer'':12');
INSERT INTO film VALUES (121, 'CAROL TEXAS', 'A Astounding Character Study of a Composer And a Student who must Overcome a Composer in A Monastery', 2006, 1, NULL, 4, 2.99, 151, 15.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''astound'':4 ''carol'':1 ''charact'':5 ''compos'':9,17 ''monasteri'':20 ''must'':14 ''overcom'':15 ''student'':12 ''studi'':6 ''texa'':2');
INSERT INTO film VALUES (122, 'CARRIE BUNCH', 'A Amazing Epistle of a Student And a Astronaut who must Discover a Frisbee in The Canadian Rockies', 2006, 1, NULL, 7, 0.99, 114, 11.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''amaz'':4 ''astronaut'':11 ''bunch'':2 ''canadian'':19 ''carri'':1 ''discov'':14 ''epistl'':5 ''frisbe'':16 ''must'':13 ''rocki'':20 ''student'':8');
INSERT INTO film VALUES (123, 'CASABLANCA SUPER', 'A Amazing Panorama of a Crocodile And a Forensic Psychologist who must Pursue a Secret Agent in The First Manned Space Station', 2006, 1, NULL, 6, 4.99, 85, 22.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''agent'':18 ''amaz'':4 ''casablanca'':1 ''crocodil'':8 ''first'':21 ''forens'':11 ''man'':22 ''must'':14 ''panorama'':5 ''psychologist'':12 ''pursu'':15 ''secret'':17 ''space'':23 ''station'':24 ''super'':2');
INSERT INTO film VALUES (124, 'CASPER DRAGONFLY', 'A Intrepid Documentary of a Boat And a Crocodile who must Chase a Robot in The Sahara Desert', 2006, 1, NULL, 3, 4.99, 163, 16.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers}', '''boat'':8 ''casper'':1 ''chase'':14 ''crocodil'':11 ''desert'':20 ''documentari'':5 ''dragonfli'':2 ''intrepid'':4 ''must'':13 ''robot'':16 ''sahara'':19');
INSERT INTO film VALUES (125, 'CASSIDY WYOMING', 'A Intrepid Drama of a Frisbee And a Hunter who must Kill a Secret Agent in New Orleans', 2006, 1, NULL, 5, 2.99, 61, 19.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''agent'':17 ''cassidi'':1 ''drama'':5 ''frisbe'':8 ''hunter'':11 ''intrepid'':4 ''kill'':14 ''must'':13 ''new'':19 ''orlean'':20 ''secret'':16 ''wyom'':2');
INSERT INTO film VALUES (126, 'CASUALTIES ENCINO', 'A Insightful Yarn of a A Shark And a Pastry Chef who must Face a Boy in A Monastery', 2006, 1, NULL, 3, 4.99, 179, 16.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers}', '''boy'':18 ''casualti'':1 ''chef'':13 ''encino'':2 ''face'':16 ''insight'':4 ''monasteri'':21 ''must'':15 ''pastri'':12 ''shark'':9 ''yarn'':5');
INSERT INTO film VALUES (127, 'CAT CONEHEADS', 'A Fast-Paced Panorama of a Girl And a A Shark who must Confront a Boy in Ancient India', 2006, 1, NULL, 5, 4.99, 112, 14.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''ancient'':21 ''boy'':19 ''cat'':1 ''conehead'':2 ''confront'':17 ''fast'':5 ''fast-pac'':4 ''girl'':10 ''india'':22 ''must'':16 ''pace'':6 ''panorama'':7 ''shark'':14');
INSERT INTO film VALUES (128, 'CATCH AMISTAD', 'A Boring Reflection of a Lumberjack And a Feminist who must Discover a Woman in Nigeria', 2006, 1, NULL, 7, 0.99, 183, 10.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''amistad'':2 ''bore'':4 ''catch'':1 ''discov'':14 ''feminist'':11 ''lumberjack'':8 ''must'':13 ''nigeria'':18 ''reflect'':5 ''woman'':16');
INSERT INTO film VALUES (129, 'CAUSE DATE', 'A Taut Tale of a Explorer And a Pastry Chef who must Conquer a Hunter in A MySQL Convention', 2006, 1, NULL, 3, 2.99, 179, 16.99, 'R', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''caus'':1 ''chef'':12 ''conquer'':15 ''convent'':21 ''date'':2 ''explor'':8 ''hunter'':17 ''must'':14 ''mysql'':20 ''pastri'':11 ''tale'':5 ''taut'':4');
INSERT INTO film VALUES (130, 'CELEBRITY HORN', 'A Amazing Documentary of a Secret Agent And a Astronaut who must Vanquish a Hunter in A Shark Tank', 2006, 1, NULL, 7, 0.99, 110, 24.99, 'PG-13', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''agent'':9 ''amaz'':4 ''astronaut'':12 ''celebr'':1 ''documentari'':5 ''horn'':2 ''hunter'':17 ''must'':14 ''secret'':8 ''shark'':20 ''tank'':21 ''vanquish'':15');
INSERT INTO film VALUES (131, 'CENTER DINOSAUR', 'A Beautiful Character Study of a Sumo Wrestler And a Dentist who must Find a Dog in California', 2006, 1, NULL, 5, 4.99, 152, 12.99, 'PG', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''beauti'':4 ''california'':20 ''center'':1 ''charact'':5 ''dentist'':13 ''dinosaur'':2 ''dog'':18 ''find'':16 ''must'':15 ''studi'':6 ''sumo'':9 ''wrestler'':10');
INSERT INTO film VALUES (132, 'CHAINSAW UPTOWN', 'A Beautiful Documentary of a Boy And a Robot who must Discover a Squirrel in Australia', 2006, 1, NULL, 6, 0.99, 114, 25.99, 'PG', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''australia'':18 ''beauti'':4 ''boy'':8 ''chainsaw'':1 ''discov'':14 ''documentari'':5 ''must'':13 ''robot'':11 ''squirrel'':16 ''uptown'':2');
INSERT INTO film VALUES (133, 'CHAMBER ITALIAN', 'A Fateful Reflection of a Moose And a Husband who must Overcome a Monkey in Nigeria', 2006, 1, NULL, 7, 4.99, 117, 14.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers}', '''chamber'':1 ''fate'':4 ''husband'':11 ''italian'':2 ''monkey'':16 ''moos'':8 ''must'':13 ''nigeria'':18 ''overcom'':14 ''reflect'':5');
INSERT INTO film VALUES (134, 'CHAMPION FLATLINERS', 'A Amazing Story of a Mad Cow And a Dog who must Kill a Husband in A Monastery', 2006, 1, NULL, 4, 4.99, 51, 21.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers}', '''amaz'':4 ''champion'':1 ''cow'':9 ''dog'':12 ''flatlin'':2 ''husband'':17 ''kill'':15 ''mad'':8 ''monasteri'':20 ''must'':14 ''stori'':5');
INSERT INTO film VALUES (135, 'CHANCE RESURRECTION', 'A Astounding Story of a Forensic Psychologist And a Forensic Psychologist who must Overcome a Moose in Ancient China', 2006, 1, NULL, 3, 2.99, 70, 22.99, 'R', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''ancient'':20 ''astound'':4 ''chanc'':1 ''china'':21 ''forens'':8,12 ''moos'':18 ''must'':15 ''overcom'':16 ''psychologist'':9,13 ''resurrect'':2 ''stori'':5');
INSERT INTO film VALUES (136, 'CHAPLIN LICENSE', 'A Boring Drama of a Dog And a Forensic Psychologist who must Outrace a Explorer in Ancient India', 2006, 1, NULL, 7, 2.99, 146, 26.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''ancient'':19 ''bore'':4 ''chaplin'':1 ''dog'':8 ''drama'':5 ''explor'':17 ''forens'':11 ''india'':20 ''licens'':2 ''must'':14 ''outrac'':15 ''psychologist'':12');
INSERT INTO film VALUES (137, 'CHARADE DUFFEL', 'A Action-Packed Display of a Man And a Waitress who must Build a Dog in A MySQL Convention', 2006, 1, NULL, 3, 2.99, 66, 21.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''action'':5 ''action-pack'':4 ''build'':16 ''charad'':1 ''convent'':22 ''display'':7 ''dog'':18 ''duffel'':2 ''man'':10 ''must'':15 ''mysql'':21 ''pack'':6 ''waitress'':13');
INSERT INTO film VALUES (138, 'CHARIOTS CONSPIRACY', 'A Unbelieveable Epistle of a Robot And a Husband who must Chase a Robot in The First Manned Space Station', 2006, 1, NULL, 5, 2.99, 71, 29.99, 'R', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''chariot'':1 ''chase'':14 ''conspiraci'':2 ''epistl'':5 ''first'':19 ''husband'':11 ''man'':20 ''must'':13 ''robot'':8,16 ''space'':21 ''station'':22 ''unbeliev'':4');
INSERT INTO film VALUES (139, 'CHASING FIGHT', 'A Astounding Saga of a Technical Writer And a Butler who must Battle a Butler in A Shark Tank', 2006, 1, NULL, 7, 4.99, 114, 21.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''astound'':4 ''battl'':15 ''butler'':12,17 ''chase'':1 ''fight'':2 ''must'':14 ''saga'':5 ''shark'':20 ''tank'':21 ''technic'':8 ''writer'':9');
INSERT INTO film VALUES (140, 'CHEAPER CLYDE', 'A Emotional Character Study of a Pioneer And a Girl who must Discover a Dog in Ancient Japan', 2006, 1, NULL, 6, 0.99, 87, 23.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''ancient'':19 ''charact'':5 ''cheaper'':1 ''clyde'':2 ''discov'':15 ''dog'':17 ''emot'':4 ''girl'':12 ''japan'':20 ''must'':14 ''pioneer'':9 ''studi'':6');
INSERT INTO film VALUES (141, 'CHICAGO NORTH', 'A Fateful Yarn of a Mad Cow And a Waitress who must Battle a Student in California', 2006, 1, NULL, 6, 4.99, 185, 11.99, 'PG-13', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''battl'':15 ''california'':19 ''chicago'':1 ''cow'':9 ''fate'':4 ''mad'':8 ''must'':14 ''north'':2 ''student'':17 ''waitress'':12 ''yarn'':5');
INSERT INTO film VALUES (142, 'CHICKEN HELLFIGHTERS', 'A Emotional Drama of a Dog And a Explorer who must Outrace a Technical Writer in Australia', 2006, 1, NULL, 3, 0.99, 122, 24.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''australia'':19 ''chicken'':1 ''dog'':8 ''drama'':5 ''emot'':4 ''explor'':11 ''hellfight'':2 ''must'':13 ''outrac'':14 ''technic'':16 ''writer'':17');
INSERT INTO film VALUES (143, 'CHILL LUCK', 'A Lacklusture Epistle of a Boat And a Technical Writer who must Fight a A Shark in The Canadian Rockies', 2006, 1, NULL, 6, 0.99, 142, 17.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''boat'':8 ''canadian'':21 ''chill'':1 ''epistl'':5 ''fight'':15 ''lacklustur'':4 ''luck'':2 ''must'':14 ''rocki'':22 ''shark'':18 ''technic'':11 ''writer'':12');
INSERT INTO film VALUES (144, 'CHINATOWN GLADIATOR', 'A Brilliant Panorama of a Technical Writer And a Lumberjack who must Escape a Butler in Ancient India', 2006, 1, NULL, 7, 4.99, 61, 24.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''ancient'':19 ''brilliant'':4 ''butler'':17 ''chinatown'':1 ''escap'':15 ''gladiat'':2 ''india'':20 ''lumberjack'':12 ''must'':14 ''panorama'':5 ''technic'':8 ''writer'':9');
INSERT INTO film VALUES (145, 'CHISUM BEHAVIOR', 'A Epic Documentary of a Sumo Wrestler And a Butler who must Kill a Car in Ancient India', 2006, 1, NULL, 5, 4.99, 124, 25.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''ancient'':19 ''behavior'':2 ''butler'':12 ''car'':17 ''chisum'':1 ''documentari'':5 ''epic'':4 ''india'':20 ''kill'':15 ''must'':14 ''sumo'':8 ''wrestler'':9');
INSERT INTO film VALUES (146, 'CHITTY LOCK', 'A Boring Epistle of a Boat And a Database Administrator who must Kill a Sumo Wrestler in The First Manned Space Station', 2006, 1, NULL, 6, 2.99, 107, 24.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries}', '''administr'':12 ''boat'':8 ''bore'':4 ''chitti'':1 ''databas'':11 ''epistl'':5 ''first'':21 ''kill'':15 ''lock'':2 ''man'':22 ''must'':14 ''space'':23 ''station'':24 ''sumo'':17 ''wrestler'':18');
INSERT INTO film VALUES (147, 'CHOCOLAT HARRY', 'A Action-Packed Epistle of a Dentist And a Moose who must Meet a Mad Cow in Ancient Japan', 2006, 1, NULL, 5, 0.99, 101, 16.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''action'':5 ''action-pack'':4 ''ancient'':21 ''chocolat'':1 ''cow'':19 ''dentist'':10 ''epistl'':7 ''harri'':2 ''japan'':22 ''mad'':18 ''meet'':16 ''moos'':13 ''must'':15 ''pack'':6');
INSERT INTO film VALUES (148, 'CHOCOLATE DUCK', 'A Unbelieveable Story of a Mad Scientist And a Technical Writer who must Discover a Composer in Ancient China', 2006, 1, NULL, 3, 2.99, 132, 13.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''ancient'':20 ''china'':21 ''chocol'':1 ''compos'':18 ''discov'':16 ''duck'':2 ''mad'':8 ''must'':15 ''scientist'':9 ''stori'':5 ''technic'':12 ''unbeliev'':4 ''writer'':13');
INSERT INTO film VALUES (149, 'CHRISTMAS MOONSHINE', 'A Action-Packed Epistle of a Feminist And a Astronaut who must Conquer a Boat in A Manhattan Penthouse', 2006, 1, NULL, 7, 0.99, 150, 21.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''action'':5 ''action-pack'':4 ''astronaut'':13 ''boat'':18 ''christma'':1 ''conquer'':16 ''epistl'':7 ''feminist'':10 ''manhattan'':21 ''moonshin'':2 ''must'':15 ''pack'':6 ''penthous'':22');
INSERT INTO film VALUES (150, 'CIDER DESIRE', 'A Stunning Character Study of a Composer And a Mad Cow who must Succumb a Cat in Soviet Georgia', 2006, 1, NULL, 7, 2.99, 101, 9.99, 'PG', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''cat'':18 ''charact'':5 ''cider'':1 ''compos'':9 ''cow'':13 ''desir'':2 ''georgia'':21 ''mad'':12 ''must'':15 ''soviet'':20 ''studi'':6 ''stun'':4 ''succumb'':16');
INSERT INTO film VALUES (151, 'CINCINATTI WHISPERER', 'A Brilliant Saga of a Pastry Chef And a Hunter who must Confront a Butler in Berlin', 2006, 1, NULL, 5, 4.99, 143, 26.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''berlin'':19 ''brilliant'':4 ''butler'':17 ''chef'':9 ''cincinatti'':1 ''confront'':15 ''hunter'':12 ''must'':14 ''pastri'':8 ''saga'':5 ''whisper'':2');
INSERT INTO film VALUES (152, 'CIRCUS YOUTH', 'A Thoughtful Drama of a Pastry Chef And a Dentist who must Pursue a Girl in A Baloon', 2006, 1, NULL, 5, 2.99, 90, 13.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''baloon'':20 ''chef'':9 ''circus'':1 ''dentist'':12 ''drama'':5 ''girl'':17 ''must'':14 ''pastri'':8 ''pursu'':15 ''thought'':4 ''youth'':2');
INSERT INTO film VALUES (153, 'CITIZEN SHREK', 'A Fanciful Character Study of a Technical Writer And a Husband who must Redeem a Robot in The Outback', 2006, 1, NULL, 7, 0.99, 165, 18.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''charact'':5 ''citizen'':1 ''fanci'':4 ''husband'':13 ''must'':15 ''outback'':21 ''redeem'':16 ''robot'':18 ''shrek'':2 ''studi'':6 ''technic'':9 ''writer'':10');
INSERT INTO film VALUES (154, 'CLASH FREDDY', 'A Amazing Yarn of a Composer And a Squirrel who must Escape a Astronaut in Australia', 2006, 1, NULL, 6, 2.99, 81, 12.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''amaz'':4 ''astronaut'':16 ''australia'':18 ''clash'':1 ''compos'':8 ''escap'':14 ''freddi'':2 ''must'':13 ''squirrel'':11 ''yarn'':5');
INSERT INTO film VALUES (155, 'CLEOPATRA DEVIL', 'A Fanciful Documentary of a Crocodile And a Technical Writer who must Fight a A Shark in A Baloon', 2006, 1, NULL, 6, 0.99, 150, 26.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''baloon'':21 ''cleopatra'':1 ''crocodil'':8 ''devil'':2 ''documentari'':5 ''fanci'':4 ''fight'':15 ''must'':14 ''shark'':18 ''technic'':11 ''writer'':12');
INSERT INTO film VALUES (156, 'CLERKS ANGELS', 'A Thrilling Display of a Sumo Wrestler And a Girl who must Confront a Man in A Baloon', 2006, 1, NULL, 3, 4.99, 164, 15.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries}', '''angel'':2 ''baloon'':20 ''clerk'':1 ''confront'':15 ''display'':5 ''girl'':12 ''man'':17 ''must'':14 ''sumo'':8 ''thrill'':4 ''wrestler'':9');
INSERT INTO film VALUES (157, 'CLOCKWORK PARADISE', 'A Insightful Documentary of a Technical Writer And a Feminist who must Challenge a Cat in A Baloon', 2006, 1, NULL, 7, 0.99, 143, 29.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''baloon'':20 ''cat'':17 ''challeng'':15 ''clockwork'':1 ''documentari'':5 ''feminist'':12 ''insight'':4 ''must'':14 ''paradis'':2 ''technic'':8 ''writer'':9');
INSERT INTO film VALUES (158, 'CLONES PINOCCHIO', 'A Amazing Drama of a Car And a Robot who must Pursue a Dentist in New Orleans', 2006, 1, NULL, 6, 2.99, 124, 16.99, 'R', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''amaz'':4 ''car'':8 ''clone'':1 ''dentist'':16 ''drama'':5 ''must'':13 ''new'':18 ''orlean'':19 ''pinocchio'':2 ''pursu'':14 ''robot'':11');
INSERT INTO film VALUES (159, 'CLOSER BANG', 'A Unbelieveable Panorama of a Frisbee And a Hunter who must Vanquish a Monkey in Ancient India', 2006, 1, NULL, 5, 4.99, 58, 12.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''ancient'':18 ''bang'':2 ''closer'':1 ''frisbe'':8 ''hunter'':11 ''india'':19 ''monkey'':16 ''must'':13 ''panorama'':5 ''unbeliev'':4 ''vanquish'':14');
INSERT INTO film VALUES (160, 'CLUB GRAFFITI', 'A Epic Tale of a Pioneer And a Hunter who must Escape a Girl in A U-Boat', 2006, 1, NULL, 4, 0.99, 65, 12.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''boat'':21 ''club'':1 ''epic'':4 ''escap'':14 ''girl'':16 ''graffiti'':2 ''hunter'':11 ''must'':13 ''pioneer'':8 ''tale'':5 ''u'':20 ''u-boat'':19');
INSERT INTO film VALUES (161, 'CLUE GRAIL', 'A Taut Tale of a Butler And a Mad Scientist who must Build a Crocodile in Ancient China', 2006, 1, NULL, 6, 4.99, 70, 27.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''ancient'':19 ''build'':15 ''butler'':8 ''china'':20 ''clue'':1 ''crocodil'':17 ''grail'':2 ''mad'':11 ''must'':14 ''scientist'':12 ''tale'':5 ''taut'':4');
INSERT INTO film VALUES (162, 'CLUELESS BUCKET', 'A Taut Tale of a Car And a Pioneer who must Conquer a Sumo Wrestler in An Abandoned Fun House', 2006, 1, NULL, 4, 2.99, 95, 13.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''abandon'':20 ''bucket'':2 ''car'':8 ''clueless'':1 ''conquer'':14 ''fun'':21 ''hous'':22 ''must'':13 ''pioneer'':11 ''sumo'':16 ''tale'':5 ''taut'':4 ''wrestler'':17');
INSERT INTO film VALUES (163, 'CLYDE THEORY', 'A Beautiful Yarn of a Astronaut And a Frisbee who must Overcome a Explorer in A Jet Boat', 2006, 1, NULL, 4, 0.99, 139, 29.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''astronaut'':8 ''beauti'':4 ''boat'':20 ''clyde'':1 ''explor'':16 ''frisbe'':11 ''jet'':19 ''must'':13 ''overcom'':14 ''theori'':2 ''yarn'':5');
INSERT INTO film VALUES (164, 'COAST RAINBOW', 'A Astounding Documentary of a Mad Cow And a Pioneer who must Challenge a Butler in The Sahara Desert', 2006, 1, NULL, 4, 0.99, 55, 20.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''astound'':4 ''butler'':17 ''challeng'':15 ''coast'':1 ''cow'':9 ''desert'':21 ''documentari'':5 ''mad'':8 ''must'':14 ''pioneer'':12 ''rainbow'':2 ''sahara'':20');
INSERT INTO film VALUES (165, 'COLDBLOODED DARLING', 'A Brilliant Panorama of a Dentist And a Moose who must Find a Student in The Gulf of Mexico', 2006, 1, NULL, 7, 4.99, 70, 27.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''brilliant'':4 ''coldblood'':1 ''darl'':2 ''dentist'':8 ''find'':14 ''gulf'':19 ''mexico'':21 ''moos'':11 ''must'':13 ''panorama'':5 ''student'':16');
INSERT INTO film VALUES (166, 'COLOR PHILADELPHIA', 'A Thoughtful Panorama of a Car And a Crocodile who must Sink a Monkey in The Sahara Desert', 2006, 1, NULL, 6, 2.99, 149, 19.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''car'':8 ''color'':1 ''crocodil'':11 ''desert'':20 ''monkey'':16 ''must'':13 ''panorama'':5 ''philadelphia'':2 ''sahara'':19 ''sink'':14 ''thought'':4');
INSERT INTO film VALUES (167, 'COMA HEAD', 'A Awe-Inspiring Drama of a Boy And a Frisbee who must Escape a Pastry Chef in California', 2006, 1, NULL, 6, 4.99, 109, 10.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries}', '''awe'':5 ''awe-inspir'':4 ''boy'':10 ''california'':21 ''chef'':19 ''coma'':1 ''drama'':7 ''escap'':16 ''frisbe'':13 ''head'':2 ''inspir'':6 ''must'':15 ''pastri'':18');
INSERT INTO film VALUES (168, 'COMANCHEROS ENEMY', 'A Boring Saga of a Lumberjack And a Monkey who must Find a Monkey in The Gulf of Mexico', 2006, 1, NULL, 5, 0.99, 67, 23.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''bore'':4 ''comanchero'':1 ''enemi'':2 ''find'':14 ''gulf'':19 ''lumberjack'':8 ''mexico'':21 ''monkey'':11,16 ''must'':13 ''saga'':5');
INSERT INTO film VALUES (169, 'COMFORTS RUSH', 'A Unbelieveable Panorama of a Pioneer And a Husband who must Meet a Mad Cow in An Abandoned Mine Shaft', 2006, 1, NULL, 3, 2.99, 76, 19.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''abandon'':20 ''comfort'':1 ''cow'':17 ''husband'':11 ''mad'':16 ''meet'':14 ''mine'':21 ''must'':13 ''panorama'':5 ''pioneer'':8 ''rush'':2 ''shaft'':22 ''unbeliev'':4');
INSERT INTO film VALUES (170, 'COMMAND DARLING', 'A Awe-Inspiring Tale of a Forensic Psychologist And a Woman who must Challenge a Database Administrator in Ancient Japan', 2006, 1, NULL, 5, 4.99, 120, 28.99, 'PG-13', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''administr'':20 ''ancient'':22 ''awe'':5 ''awe-inspir'':4 ''challeng'':17 ''command'':1 ''darl'':2 ''databas'':19 ''forens'':10 ''inspir'':6 ''japan'':23 ''must'':16 ''psychologist'':11 ''tale'':7 ''woman'':14');
INSERT INTO film VALUES (171, 'COMMANDMENTS EXPRESS', 'A Fanciful Saga of a Student And a Mad Scientist who must Battle a Hunter in An Abandoned Mine Shaft', 2006, 1, NULL, 6, 4.99, 59, 13.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''abandon'':20 ''battl'':15 ''command'':1 ''express'':2 ''fanci'':4 ''hunter'':17 ''mad'':11 ''mine'':21 ''must'':14 ''saga'':5 ''scientist'':12 ''shaft'':22 ''student'':8');
INSERT INTO film VALUES (172, 'CONEHEADS SMOOCHY', 'A Touching Story of a Womanizer And a Composer who must Pursue a Husband in Nigeria', 2006, 1, NULL, 7, 4.99, 112, 12.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''compos'':11 ''conehead'':1 ''husband'':16 ''must'':13 ''nigeria'':18 ''pursu'':14 ''smoochi'':2 ''stori'':5 ''touch'':4 ''woman'':8');
INSERT INTO film VALUES (173, 'CONFESSIONS MAGUIRE', 'A Insightful Story of a Car And a Boy who must Battle a Technical Writer in A Baloon', 2006, 1, NULL, 7, 4.99, 65, 25.99, 'PG-13', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''baloon'':20 ''battl'':14 ''boy'':11 ''car'':8 ''confess'':1 ''insight'':4 ''maguir'':2 ''must'':13 ''stori'':5 ''technic'':16 ''writer'':17');
INSERT INTO film VALUES (174, 'CONFIDENTIAL INTERVIEW', 'A Stunning Reflection of a Cat And a Woman who must Find a Astronaut in Ancient Japan', 2006, 1, NULL, 6, 4.99, 180, 13.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries}', '''ancient'':18 ''astronaut'':16 ''cat'':8 ''confidenti'':1 ''find'':14 ''interview'':2 ''japan'':19 ''must'':13 ''reflect'':5 ''stun'':4 ''woman'':11');
INSERT INTO film VALUES (175, 'CONFUSED CANDLES', 'A Stunning Epistle of a Cat And a Forensic Psychologist who must Confront a Pioneer in A Baloon', 2006, 1, NULL, 3, 2.99, 122, 27.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''baloon'':20 ''candl'':2 ''cat'':8 ''confront'':15 ''confus'':1 ''epistl'':5 ''forens'':11 ''must'':14 ''pioneer'':17 ''psychologist'':12 ''stun'':4');
INSERT INTO film VALUES (176, 'CONGENIALITY QUEST', 'A Touching Documentary of a Cat And a Pastry Chef who must Find a Lumberjack in A Baloon', 2006, 1, NULL, 6, 0.99, 87, 21.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''baloon'':20 ''cat'':8 ''chef'':12 ''congeni'':1 ''documentari'':5 ''find'':15 ''lumberjack'':17 ''must'':14 ''pastri'':11 ''quest'':2 ''touch'':4');
INSERT INTO film VALUES (177, 'CONNECTICUT TRAMP', 'A Unbelieveable Drama of a Crocodile And a Mad Cow who must Reach a Dentist in A Shark Tank', 2006, 1, NULL, 4, 4.99, 172, 20.99, 'R', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''connecticut'':1 ''cow'':12 ''crocodil'':8 ''dentist'':17 ''drama'':5 ''mad'':11 ''must'':14 ''reach'':15 ''shark'':20 ''tank'':21 ''tramp'':2 ''unbeliev'':4');
INSERT INTO film VALUES (178, 'CONNECTION MICROCOSMOS', 'A Fateful Documentary of a Crocodile And a Husband who must Face a Husband in The First Manned Space Station', 2006, 1, NULL, 6, 0.99, 115, 25.99, 'G', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''connect'':1 ''crocodil'':8 ''documentari'':5 ''face'':14 ''fate'':4 ''first'':19 ''husband'':11,16 ''man'':20 ''microcosmo'':2 ''must'':13 ''space'':21 ''station'':22');
INSERT INTO film VALUES (179, 'CONQUERER NUTS', 'A Taut Drama of a Mad Scientist And a Man who must Escape a Pioneer in An Abandoned Mine Shaft', 2006, 1, NULL, 4, 4.99, 173, 14.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''abandon'':20 ''conquer'':1 ''drama'':5 ''escap'':15 ''mad'':8 ''man'':12 ''mine'':21 ''must'':14 ''nut'':2 ''pioneer'':17 ''scientist'':9 ''shaft'':22 ''taut'':4');
INSERT INTO film VALUES (180, 'CONSPIRACY SPIRIT', 'A Awe-Inspiring Story of a Student And a Frisbee who must Conquer a Crocodile in An Abandoned Mine Shaft', 2006, 1, NULL, 4, 2.99, 184, 27.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''abandon'':21 ''awe'':5 ''awe-inspir'':4 ''conquer'':16 ''conspiraci'':1 ''crocodil'':18 ''frisbe'':13 ''inspir'':6 ''mine'':22 ''must'':15 ''shaft'':23 ''spirit'':2 ''stori'':7 ''student'':10');
INSERT INTO film VALUES (181, 'CONTACT ANONYMOUS', 'A Insightful Display of a A Shark And a Monkey who must Face a Database Administrator in Ancient India', 2006, 1, NULL, 7, 2.99, 166, 10.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Commentaries}', '''administr'':18 ''ancient'':20 ''anonym'':2 ''contact'':1 ''databas'':17 ''display'':5 ''face'':15 ''india'':21 ''insight'':4 ''monkey'':12 ''must'':14 ''shark'':9');
INSERT INTO film VALUES (182, 'CONTROL ANTHEM', 'A Fateful Documentary of a Robot And a Student who must Battle a Cat in A Monastery', 2006, 1, NULL, 7, 4.99, 185, 9.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries}', '''anthem'':2 ''battl'':14 ''cat'':16 ''control'':1 ''documentari'':5 ''fate'':4 ''monasteri'':19 ''must'':13 ''robot'':8 ''student'':11');
INSERT INTO film VALUES (183, 'CONVERSATION DOWNHILL', 'A Taut Character Study of a Husband And a Waitress who must Sink a Squirrel in A MySQL Convention', 2006, 1, NULL, 4, 4.99, 112, 14.99, 'R', '2007-09-10 17:46:03.905795', '{Commentaries}', '''charact'':5 ''convent'':21 ''convers'':1 ''downhil'':2 ''husband'':9 ''must'':14 ''mysql'':20 ''sink'':15 ''squirrel'':17 ''studi'':6 ''taut'':4 ''waitress'':12');
INSERT INTO film VALUES (184, 'CORE SUIT', 'A Unbelieveable Tale of a Car And a Explorer who must Confront a Boat in A Manhattan Penthouse', 2006, 1, NULL, 3, 2.99, 92, 24.99, 'PG-13', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''boat'':16 ''car'':8 ''confront'':14 ''core'':1 ''explor'':11 ''manhattan'':19 ''must'':13 ''penthous'':20 ''suit'':2 ''tale'':5 ''unbeliev'':4');
INSERT INTO film VALUES (185, 'COWBOY DOOM', 'A Astounding Drama of a Boy And a Lumberjack who must Fight a Butler in A Baloon', 2006, 1, NULL, 3, 2.99, 146, 10.99, 'PG', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''astound'':4 ''baloon'':19 ''boy'':8 ''butler'':16 ''cowboy'':1 ''doom'':2 ''drama'':5 ''fight'':14 ''lumberjack'':11 ''must'':13');
INSERT INTO film VALUES (186, 'CRAFT OUTFIELD', 'A Lacklusture Display of a Explorer And a Hunter who must Succumb a Database Administrator in A Baloon Factory', 2006, 1, NULL, 6, 0.99, 64, 17.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''administr'':17 ''baloon'':20 ''craft'':1 ''databas'':16 ''display'':5 ''explor'':8 ''factori'':21 ''hunter'':11 ''lacklustur'':4 ''must'':13 ''outfield'':2 ''succumb'':14');
INSERT INTO film VALUES (187, 'CRANES RESERVOIR', 'A Fanciful Documentary of a Teacher And a Dog who must Outgun a Forensic Psychologist in A Baloon Factory', 2006, 1, NULL, 5, 2.99, 57, 12.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries}', '''baloon'':20 ''crane'':1 ''documentari'':5 ''dog'':11 ''factori'':21 ''fanci'':4 ''forens'':16 ''must'':13 ''outgun'':14 ''psychologist'':17 ''reservoir'':2 ''teacher'':8');
INSERT INTO film VALUES (188, 'CRAZY HOME', 'A Fanciful Panorama of a Boy And a Woman who must Vanquish a Database Administrator in The Outback', 2006, 1, NULL, 7, 2.99, 136, 24.99, 'PG', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''administr'':17 ''boy'':8 ''crazi'':1 ''databas'':16 ''fanci'':4 ''home'':2 ''must'':13 ''outback'':20 ''panorama'':5 ''vanquish'':14 ''woman'':11');
INSERT INTO film VALUES (189, 'CREATURES SHAKESPEARE', 'A Emotional Drama of a Womanizer And a Squirrel who must Vanquish a Crocodile in Ancient India', 2006, 1, NULL, 3, 0.99, 139, 23.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''ancient'':18 ''creatur'':1 ''crocodil'':16 ''drama'':5 ''emot'':4 ''india'':19 ''must'':13 ''shakespear'':2 ''squirrel'':11 ''vanquish'':14 ''woman'':8');
INSERT INTO film VALUES (190, 'CREEPERS KANE', 'A Awe-Inspiring Reflection of a Squirrel And a Boat who must Outrace a Car in A Jet Boat', 2006, 1, NULL, 5, 4.99, 172, 23.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''awe'':5 ''awe-inspir'':4 ''boat'':13,22 ''car'':18 ''creeper'':1 ''inspir'':6 ''jet'':21 ''kane'':2 ''must'':15 ''outrac'':16 ''reflect'':7 ''squirrel'':10');
INSERT INTO film VALUES (191, 'CROOKED FROGMEN', 'A Unbelieveable Drama of a Hunter And a Database Administrator who must Battle a Crocodile in An Abandoned Amusement Park', 2006, 1, NULL, 6, 0.99, 143, 27.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''abandon'':20 ''administr'':12 ''amus'':21 ''battl'':15 ''crocodil'':17 ''crook'':1 ''databas'':11 ''drama'':5 ''frogmen'':2 ''hunter'':8 ''must'':14 ''park'':22 ''unbeliev'':4');
INSERT INTO film VALUES (192, 'CROSSING DIVORCE', 'A Beautiful Documentary of a Dog And a Robot who must Redeem a Womanizer in Berlin', 2006, 1, NULL, 4, 4.99, 50, 19.99, 'R', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''beauti'':4 ''berlin'':18 ''cross'':1 ''divorc'':2 ''documentari'':5 ''dog'':8 ''must'':13 ''redeem'':14 ''robot'':11 ''woman'':16');
INSERT INTO film VALUES (193, 'CROSSROADS CASUALTIES', 'A Intrepid Documentary of a Sumo Wrestler And a Astronaut who must Battle a Composer in The Outback', 2006, 1, NULL, 5, 2.99, 153, 20.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''astronaut'':12 ''battl'':15 ''casualti'':2 ''compos'':17 ''crossroad'':1 ''documentari'':5 ''intrepid'':4 ''must'':14 ''outback'':20 ''sumo'':8 ''wrestler'':9');
INSERT INTO film VALUES (194, 'CROW GREASE', 'A Awe-Inspiring Documentary of a Woman And a Husband who must Sink a Database Administrator in The First Manned Space Station', 2006, 1, NULL, 6, 0.99, 104, 22.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''administr'':19 ''awe'':5 ''awe-inspir'':4 ''crow'':1 ''databas'':18 ''documentari'':7 ''first'':22 ''greas'':2 ''husband'':13 ''inspir'':6 ''man'':23 ''must'':15 ''sink'':16 ''space'':24 ''station'':25 ''woman'':10');
INSERT INTO film VALUES (195, 'CROWDS TELEMARK', 'A Intrepid Documentary of a Astronaut And a Forensic Psychologist who must Find a Frisbee in An Abandoned Fun House', 2006, 1, NULL, 3, 4.99, 112, 16.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''abandon'':20 ''astronaut'':8 ''crowd'':1 ''documentari'':5 ''find'':15 ''forens'':11 ''frisbe'':17 ''fun'':21 ''hous'':22 ''intrepid'':4 ''must'':14 ''psychologist'':12 ''telemark'':2');
INSERT INTO film VALUES (196, 'CRUELTY UNFORGIVEN', 'A Brilliant Tale of a Car And a Moose who must Battle a Dentist in Nigeria', 2006, 1, NULL, 7, 0.99, 69, 29.99, 'G', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''battl'':14 ''brilliant'':4 ''car'':8 ''cruelti'':1 ''dentist'':16 ''moos'':11 ''must'':13 ''nigeria'':18 ''tale'':5 ''unforgiven'':2');
INSERT INTO film VALUES (197, 'CRUSADE HONEY', 'A Fast-Paced Reflection of a Explorer And a Butler who must Battle a Madman in An Abandoned Amusement Park', 2006, 1, NULL, 4, 2.99, 112, 27.99, 'R', '2007-09-10 17:46:03.905795', '{Commentaries}', '''abandon'':21 ''amus'':22 ''battl'':16 ''butler'':13 ''crusad'':1 ''explor'':10 ''fast'':5 ''fast-pac'':4 ''honey'':2 ''madman'':18 ''must'':15 ''pace'':6 ''park'':23 ''reflect'':7');
INSERT INTO film VALUES (198, 'CRYSTAL BREAKING', 'A Fast-Paced Character Study of a Feminist And a Explorer who must Face a Pastry Chef in Ancient Japan', 2006, 1, NULL, 6, 2.99, 184, 22.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''ancient'':22 ''break'':2 ''charact'':7 ''chef'':20 ''crystal'':1 ''explor'':14 ''face'':17 ''fast'':5 ''fast-pac'':4 ''feminist'':11 ''japan'':23 ''must'':16 ''pace'':6 ''pastri'':19 ''studi'':8');
INSERT INTO film VALUES (199, 'CUPBOARD SINNERS', 'A Emotional Reflection of a Frisbee And a Boat who must Reach a Pastry Chef in An Abandoned Amusement Park', 2006, 1, NULL, 4, 2.99, 56, 29.99, 'R', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''abandon'':20 ''amus'':21 ''boat'':11 ''chef'':17 ''cupboard'':1 ''emot'':4 ''frisbe'':8 ''must'':13 ''park'':22 ''pastri'':16 ''reach'':14 ''reflect'':5 ''sinner'':2');
INSERT INTO film VALUES (200, 'CURTAIN VIDEOTAPE', 'A Boring Reflection of a Dentist And a Mad Cow who must Chase a Secret Agent in A Shark Tank', 2006, 1, NULL, 7, 0.99, 133, 27.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''agent'':18 ''bore'':4 ''chase'':15 ''cow'':12 ''curtain'':1 ''dentist'':8 ''mad'':11 ''must'':14 ''reflect'':5 ''secret'':17 ''shark'':21 ''tank'':22 ''videotap'':2');
INSERT INTO film VALUES (201, 'CYCLONE FAMILY', 'A Lacklusture Drama of a Student And a Monkey who must Sink a Womanizer in A MySQL Convention', 2006, 1, NULL, 7, 2.99, 176, 18.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''convent'':20 ''cyclon'':1 ''drama'':5 ''famili'':2 ''lacklustur'':4 ''monkey'':11 ''must'':13 ''mysql'':19 ''sink'':14 ''student'':8 ''woman'':16');
INSERT INTO film VALUES (202, 'DADDY PITTSBURGH', 'A Epic Story of a A Shark And a Student who must Confront a Explorer in The Gulf of Mexico', 2006, 1, NULL, 5, 4.99, 161, 26.99, 'G', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''confront'':15 ''daddi'':1 ''epic'':4 ''explor'':17 ''gulf'':20 ''mexico'':22 ''must'':14 ''pittsburgh'':2 ''shark'':9 ''stori'':5 ''student'':12');
INSERT INTO film VALUES (203, 'DAISY MENAGERIE', 'A Fast-Paced Saga of a Pastry Chef And a Monkey who must Sink a Composer in Ancient India', 2006, 1, NULL, 5, 4.99, 84, 9.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''ancient'':21 ''chef'':11 ''compos'':19 ''daisi'':1 ''fast'':5 ''fast-pac'':4 ''india'':22 ''menageri'':2 ''monkey'':14 ''must'':16 ''pace'':6 ''pastri'':10 ''saga'':7 ''sink'':17');
INSERT INTO film VALUES (204, 'DALMATIONS SWEDEN', 'A Emotional Epistle of a Moose And a Hunter who must Overcome a Robot in A Manhattan Penthouse', 2006, 1, NULL, 4, 0.99, 106, 25.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''dalmat'':1 ''emot'':4 ''epistl'':5 ''hunter'':11 ''manhattan'':19 ''moos'':8 ''must'':13 ''overcom'':14 ''penthous'':20 ''robot'':16 ''sweden'':2');
INSERT INTO film VALUES (205, 'DANCES NONE', 'A Insightful Reflection of a A Shark And a Dog who must Kill a Butler in An Abandoned Amusement Park', 2006, 1, NULL, 3, 0.99, 58, 22.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''abandon'':20 ''amus'':21 ''butler'':17 ''danc'':1 ''dog'':12 ''insight'':4 ''kill'':15 ''must'':14 ''none'':2 ''park'':22 ''reflect'':5 ''shark'':9');
INSERT INTO film VALUES (206, 'DANCING FEVER', 'A Stunning Story of a Explorer And a Forensic Psychologist who must Face a Crocodile in A Shark Tank', 2006, 1, NULL, 6, 0.99, 144, 25.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''crocodil'':17 ''danc'':1 ''explor'':8 ''face'':15 ''fever'':2 ''forens'':11 ''must'':14 ''psychologist'':12 ''shark'':20 ''stori'':5 ''stun'':4 ''tank'':21');
INSERT INTO film VALUES (207, 'DANGEROUS UPTOWN', 'A Unbelieveable Story of a Mad Scientist And a Woman who must Overcome a Dog in California', 2006, 1, NULL, 7, 4.99, 121, 26.99, 'PG', '2007-09-10 17:46:03.905795', '{Commentaries}', '''california'':19 ''danger'':1 ''dog'':17 ''mad'':8 ''must'':14 ''overcom'':15 ''scientist'':9 ''stori'':5 ''unbeliev'':4 ''uptown'':2 ''woman'':12');
INSERT INTO film VALUES (208, 'DARES PLUTO', 'A Fateful Story of a Robot And a Dentist who must Defeat a Astronaut in New Orleans', 2006, 1, NULL, 7, 2.99, 89, 16.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''astronaut'':16 ''dare'':1 ''defeat'':14 ''dentist'':11 ''fate'':4 ''must'':13 ''new'':18 ''orlean'':19 ''pluto'':2 ''robot'':8 ''stori'':5');
INSERT INTO film VALUES (209, 'DARKNESS WAR', 'A Touching Documentary of a Husband And a Hunter who must Escape a Boy in The Sahara Desert', 2006, 1, NULL, 6, 2.99, 99, 24.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''boy'':16 ''dark'':1 ''desert'':20 ''documentari'':5 ''escap'':14 ''hunter'':11 ''husband'':8 ''must'':13 ''sahara'':19 ''touch'':4 ''war'':2');
INSERT INTO film VALUES (210, 'DARKO DORADO', 'A Stunning Reflection of a Frisbee And a Husband who must Redeem a Dog in New Orleans', 2006, 1, NULL, 3, 4.99, 130, 13.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''darko'':1 ''dog'':16 ''dorado'':2 ''frisbe'':8 ''husband'':11 ''must'':13 ''new'':18 ''orlean'':19 ''redeem'':14 ''reflect'':5 ''stun'':4');
INSERT INTO film VALUES (211, 'DARLING BREAKING', 'A Brilliant Documentary of a Astronaut And a Squirrel who must Succumb a Student in The Gulf of Mexico', 2006, 1, NULL, 7, 4.99, 165, 20.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''astronaut'':8 ''break'':2 ''brilliant'':4 ''darl'':1 ''documentari'':5 ''gulf'':19 ''mexico'':21 ''must'':13 ''squirrel'':11 ''student'':16 ''succumb'':14');
INSERT INTO film VALUES (212, 'DARN FORRESTER', 'A Fateful Story of a A Shark And a Explorer who must Succumb a Technical Writer in A Jet Boat', 2006, 1, NULL, 7, 4.99, 185, 14.99, 'G', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''boat'':22 ''darn'':1 ''explor'':12 ''fate'':4 ''forrest'':2 ''jet'':21 ''must'':14 ''shark'':9 ''stori'':5 ''succumb'':15 ''technic'':17 ''writer'':18');
INSERT INTO film VALUES (214, 'DAUGHTER MADIGAN', 'A Beautiful Tale of a Hunter And a Mad Scientist who must Confront a Squirrel in The First Manned Space Station', 2006, 1, NULL, 3, 4.99, 59, 13.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers}', '''beauti'':4 ''confront'':15 ''daughter'':1 ''first'':20 ''hunter'':8 ''mad'':11 ''madigan'':2 ''man'':21 ''must'':14 ''scientist'':12 ''space'':22 ''squirrel'':17 ''station'':23 ''tale'':5');
INSERT INTO film VALUES (215, 'DAWN POND', 'A Thoughtful Documentary of a Dentist And a Forensic Psychologist who must Defeat a Waitress in Berlin', 2006, 1, NULL, 4, 4.99, 57, 27.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''berlin'':19 ''dawn'':1 ''defeat'':15 ''dentist'':8 ''documentari'':5 ''forens'':11 ''must'':14 ''pond'':2 ''psychologist'':12 ''thought'':4 ''waitress'':17');
INSERT INTO film VALUES (216, 'DAY UNFAITHFUL', 'A Stunning Documentary of a Composer And a Mad Scientist who must Find a Technical Writer in A U-Boat', 2006, 1, NULL, 3, 4.99, 113, 16.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''boat'':23 ''compos'':8 ''day'':1 ''documentari'':5 ''find'':15 ''mad'':11 ''must'':14 ''scientist'':12 ''stun'':4 ''technic'':17 ''u'':22 ''u-boat'':21 ''unfaith'':2 ''writer'':18');
INSERT INTO film VALUES (217, 'DAZED PUNK', 'A Action-Packed Story of a Pioneer And a Technical Writer who must Discover a Forensic Psychologist in An Abandoned Amusement Park', 2006, 1, NULL, 6, 4.99, 120, 20.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''abandon'':23 ''action'':5 ''action-pack'':4 ''amus'':24 ''daze'':1 ''discov'':17 ''forens'':19 ''must'':16 ''pack'':6 ''park'':25 ''pioneer'':10 ''psychologist'':20 ''punk'':2 ''stori'':7 ''technic'':13 ''writer'':14');
INSERT INTO film VALUES (218, 'DECEIVER BETRAYED', 'A Taut Story of a Moose And a Squirrel who must Build a Husband in Ancient India', 2006, 1, NULL, 7, 0.99, 122, 22.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''ancient'':18 ''betray'':2 ''build'':14 ''deceiv'':1 ''husband'':16 ''india'':19 ''moos'':8 ''must'':13 ''squirrel'':11 ''stori'':5 ''taut'':4');
INSERT INTO film VALUES (219, 'DEEP CRUSADE', 'A Amazing Tale of a Crocodile And a Squirrel who must Discover a Composer in Australia', 2006, 1, NULL, 6, 4.99, 51, 20.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''amaz'':4 ''australia'':18 ''compos'':16 ''crocodil'':8 ''crusad'':2 ''deep'':1 ''discov'':14 ''must'':13 ''squirrel'':11 ''tale'':5');
INSERT INTO film VALUES (220, 'DEER VIRGINIAN', 'A Thoughtful Story of a Mad Cow And a Womanizer who must Overcome a Mad Scientist in Soviet Georgia', 2006, 1, NULL, 7, 2.99, 106, 13.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''cow'':9 ''deer'':1 ''georgia'':21 ''mad'':8,17 ''must'':14 ''overcom'':15 ''scientist'':18 ''soviet'':20 ''stori'':5 ''thought'':4 ''virginian'':2 ''woman'':12');
INSERT INTO film VALUES (221, 'DELIVERANCE MULHOLLAND', 'A Astounding Saga of a Monkey And a Moose who must Conquer a Butler in A Shark Tank', 2006, 1, NULL, 4, 0.99, 100, 9.99, 'R', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''astound'':4 ''butler'':16 ''conquer'':14 ''deliver'':1 ''monkey'':8 ''moos'':11 ''mulholland'':2 ''must'':13 ''saga'':5 ''shark'':19 ''tank'':20');
INSERT INTO film VALUES (222, 'DESERT POSEIDON', 'A Brilliant Documentary of a Butler And a Frisbee who must Build a Astronaut in New Orleans', 2006, 1, NULL, 4, 4.99, 64, 27.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''astronaut'':16 ''brilliant'':4 ''build'':14 ''butler'':8 ''desert'':1 ''documentari'':5 ''frisbe'':11 ''must'':13 ''new'':18 ''orlean'':19 ''poseidon'':2');
INSERT INTO film VALUES (223, 'DESIRE ALIEN', 'A Fast-Paced Tale of a Dog And a Forensic Psychologist who must Meet a Astronaut in The First Manned Space Station', 2006, 1, NULL, 7, 2.99, 76, 24.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''alien'':2 ''astronaut'':19 ''desir'':1 ''dog'':10 ''fast'':5 ''fast-pac'':4 ''first'':22 ''forens'':13 ''man'':23 ''meet'':17 ''must'':16 ''pace'':6 ''psychologist'':14 ''space'':24 ''station'':25 ''tale'':7');
INSERT INTO film VALUES (224, 'DESPERATE TRAINSPOTTING', 'A Epic Yarn of a Forensic Psychologist And a Teacher who must Face a Lumberjack in California', 2006, 1, NULL, 7, 4.99, 81, 29.99, 'G', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''california'':19 ''desper'':1 ''epic'':4 ''face'':15 ''forens'':8 ''lumberjack'':17 ''must'':14 ''psychologist'':9 ''teacher'':12 ''trainspot'':2 ''yarn'':5');
INSERT INTO film VALUES (225, 'DESTINATION JERK', 'A Beautiful Yarn of a Teacher And a Cat who must Build a Car in A U-Boat', 2006, 1, NULL, 3, 0.99, 76, 19.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''beauti'':4 ''boat'':21 ''build'':14 ''car'':16 ''cat'':11 ''destin'':1 ''jerk'':2 ''must'':13 ''teacher'':8 ''u'':20 ''u-boat'':19 ''yarn'':5');
INSERT INTO film VALUES (226, 'DESTINY SATURDAY', 'A Touching Drama of a Crocodile And a Crocodile who must Conquer a Explorer in Soviet Georgia', 2006, 1, NULL, 4, 4.99, 56, 20.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''conquer'':14 ''crocodil'':8,11 ''destini'':1 ''drama'':5 ''explor'':16 ''georgia'':19 ''must'':13 ''saturday'':2 ''soviet'':18 ''touch'':4');
INSERT INTO film VALUES (227, 'DETAILS PACKER', 'A Epic Saga of a Waitress And a Composer who must Face a Boat in A U-Boat', 2006, 1, NULL, 4, 4.99, 88, 17.99, 'R', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''boat'':16,21 ''compos'':11 ''detail'':1 ''epic'':4 ''face'':14 ''must'':13 ''packer'':2 ''saga'':5 ''u'':20 ''u-boat'':19 ''waitress'':8');
INSERT INTO film VALUES (228, 'DETECTIVE VISION', 'A Fanciful Documentary of a Pioneer And a Woman who must Redeem a Hunter in Ancient Japan', 2006, 1, NULL, 4, 0.99, 143, 16.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''ancient'':18 ''detect'':1 ''documentari'':5 ''fanci'':4 ''hunter'':16 ''japan'':19 ''must'':13 ''pioneer'':8 ''redeem'':14 ''vision'':2 ''woman'':11');
INSERT INTO film VALUES (229, 'DEVIL DESIRE', 'A Beautiful Reflection of a Monkey And a Dentist who must Face a Database Administrator in Ancient Japan', 2006, 1, NULL, 6, 4.99, 87, 12.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''administr'':17 ''ancient'':19 ''beauti'':4 ''databas'':16 ''dentist'':11 ''desir'':2 ''devil'':1 ''face'':14 ''japan'':20 ''monkey'':8 ''must'':13 ''reflect'':5');
INSERT INTO film VALUES (230, 'DIARY PANIC', 'A Thoughtful Character Study of a Frisbee And a Mad Cow who must Outgun a Man in Ancient India', 2006, 1, NULL, 7, 2.99, 107, 20.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''ancient'':20 ''charact'':5 ''cow'':13 ''diari'':1 ''frisbe'':9 ''india'':21 ''mad'':12 ''man'':18 ''must'':15 ''outgun'':16 ''panic'':2 ''studi'':6 ''thought'':4');
INSERT INTO film VALUES (231, 'DINOSAUR SECRETARY', 'A Action-Packed Drama of a Feminist And a Girl who must Reach a Robot in The Canadian Rockies', 2006, 1, NULL, 7, 2.99, 63, 27.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''action'':5 ''action-pack'':4 ''canadian'':21 ''dinosaur'':1 ''drama'':7 ''feminist'':10 ''girl'':13 ''must'':15 ''pack'':6 ''reach'':16 ''robot'':18 ''rocki'':22 ''secretari'':2');
INSERT INTO film VALUES (232, 'DIRTY ACE', 'A Action-Packed Character Study of a Forensic Psychologist And a Girl who must Build a Dentist in The Outback', 2006, 1, NULL, 7, 2.99, 147, 29.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''ace'':2 ''action'':5 ''action-pack'':4 ''build'':18 ''charact'':7 ''dentist'':20 ''dirti'':1 ''forens'':11 ''girl'':15 ''must'':17 ''outback'':23 ''pack'':6 ''psychologist'':12 ''studi'':8');
INSERT INTO film VALUES (233, 'DISCIPLE MOTHER', 'A Touching Reflection of a Mad Scientist And a Boat who must Face a Moose in A Shark Tank', 2006, 1, NULL, 3, 0.99, 141, 17.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''boat'':12 ''discipl'':1 ''face'':15 ''mad'':8 ''moos'':17 ''mother'':2 ''must'':14 ''reflect'':5 ''scientist'':9 ''shark'':20 ''tank'':21 ''touch'':4');
INSERT INTO film VALUES (234, 'DISTURBING SCARFACE', 'A Lacklusture Display of a Crocodile And a Butler who must Overcome a Monkey in A U-Boat', 2006, 1, NULL, 6, 2.99, 94, 27.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''boat'':21 ''butler'':11 ''crocodil'':8 ''display'':5 ''disturb'':1 ''lacklustur'':4 ''monkey'':16 ''must'':13 ''overcom'':14 ''scarfac'':2 ''u'':20 ''u-boat'':19');
INSERT INTO film VALUES (235, 'DIVIDE MONSTER', 'A Intrepid Saga of a Man And a Forensic Psychologist who must Reach a Squirrel in A Monastery', 2006, 1, NULL, 6, 2.99, 68, 13.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''divid'':1 ''forens'':11 ''intrepid'':4 ''man'':8 ''monasteri'':20 ''monster'':2 ''must'':14 ''psychologist'':12 ''reach'':15 ''saga'':5 ''squirrel'':17');
INSERT INTO film VALUES (236, 'DIVINE RESURRECTION', 'A Boring Character Study of a Man And a Womanizer who must Succumb a Teacher in An Abandoned Amusement Park', 2006, 1, NULL, 4, 2.99, 100, 19.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''abandon'':20 ''amus'':21 ''bore'':4 ''charact'':5 ''divin'':1 ''man'':9 ''must'':14 ''park'':22 ''resurrect'':2 ''studi'':6 ''succumb'':15 ''teacher'':17 ''woman'':12');
INSERT INTO film VALUES (237, 'DIVORCE SHINING', 'A Unbelieveable Saga of a Crocodile And a Student who must Discover a Cat in Ancient India', 2006, 1, NULL, 3, 2.99, 47, 21.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''ancient'':18 ''cat'':16 ''crocodil'':8 ''discov'':14 ''divorc'':1 ''india'':19 ''must'':13 ''saga'':5 ''shine'':2 ''student'':11 ''unbeliev'':4');
INSERT INTO film VALUES (238, 'DOCTOR GRAIL', 'A Insightful Drama of a Womanizer And a Waitress who must Reach a Forensic Psychologist in The Outback', 2006, 1, NULL, 4, 2.99, 57, 29.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''doctor'':1 ''drama'':5 ''forens'':16 ''grail'':2 ''insight'':4 ''must'':13 ''outback'':20 ''psychologist'':17 ''reach'':14 ''waitress'':11 ''woman'':8');
INSERT INTO film VALUES (239, 'DOGMA FAMILY', 'A Brilliant Character Study of a Database Administrator And a Monkey who must Succumb a Astronaut in New Orleans', 2006, 1, NULL, 5, 4.99, 122, 16.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries}', '''administr'':10 ''astronaut'':18 ''brilliant'':4 ''charact'':5 ''databas'':9 ''dogma'':1 ''famili'':2 ''monkey'':13 ''must'':15 ''new'':20 ''orlean'':21 ''studi'':6 ''succumb'':16');
INSERT INTO film VALUES (240, 'DOLLS RAGE', 'A Thrilling Display of a Pioneer And a Frisbee who must Escape a Teacher in The Outback', 2006, 1, NULL, 7, 2.99, 120, 10.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''display'':5 ''doll'':1 ''escap'':14 ''frisbe'':11 ''must'':13 ''outback'':19 ''pioneer'':8 ''rage'':2 ''teacher'':16 ''thrill'':4');
INSERT INTO film VALUES (241, 'DONNIE ALLEY', 'A Awe-Inspiring Tale of a Butler And a Frisbee who must Vanquish a Teacher in Ancient Japan', 2006, 1, NULL, 4, 0.99, 125, 20.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''alley'':2 ''ancient'':20 ''awe'':5 ''awe-inspir'':4 ''butler'':10 ''donni'':1 ''frisbe'':13 ''inspir'':6 ''japan'':21 ''must'':15 ''tale'':7 ''teacher'':18 ''vanquish'':16');
INSERT INTO film VALUES (242, 'DOOM DANCING', 'A Astounding Panorama of a Car And a Mad Scientist who must Battle a Lumberjack in A MySQL Convention', 2006, 1, NULL, 4, 0.99, 68, 13.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''astound'':4 ''battl'':15 ''car'':8 ''convent'':21 ''danc'':2 ''doom'':1 ''lumberjack'':17 ''mad'':11 ''must'':14 ''mysql'':20 ''panorama'':5 ''scientist'':12');
INSERT INTO film VALUES (243, 'DOORS PRESIDENT', 'A Awe-Inspiring Display of a Squirrel And a Woman who must Overcome a Boy in The Gulf of Mexico', 2006, 1, NULL, 3, 4.99, 49, 22.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''awe'':5 ''awe-inspir'':4 ''boy'':18 ''display'':7 ''door'':1 ''gulf'':21 ''inspir'':6 ''mexico'':23 ''must'':15 ''overcom'':16 ''presid'':2 ''squirrel'':10 ''woman'':13');
INSERT INTO film VALUES (244, 'DORADO NOTTING', 'A Action-Packed Tale of a Sumo Wrestler And a A Shark who must Meet a Frisbee in California', 2006, 1, NULL, 5, 4.99, 139, 26.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries}', '''action'':5 ''action-pack'':4 ''california'':22 ''dorado'':1 ''frisbe'':20 ''meet'':18 ''must'':17 ''not'':2 ''pack'':6 ''shark'':15 ''sumo'':10 ''tale'':7 ''wrestler'':11');
INSERT INTO film VALUES (245, 'DOUBLE WRATH', 'A Thoughtful Yarn of a Womanizer And a Dog who must Challenge a Madman in The Gulf of Mexico', 2006, 1, NULL, 4, 0.99, 177, 28.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''challeng'':14 ''dog'':11 ''doubl'':1 ''gulf'':19 ''madman'':16 ''mexico'':21 ''must'':13 ''thought'':4 ''woman'':8 ''wrath'':2 ''yarn'':5');
INSERT INTO film VALUES (246, 'DOUBTFIRE LABYRINTH', 'A Intrepid Panorama of a Butler And a Composer who must Meet a Mad Cow in The Sahara Desert', 2006, 1, NULL, 5, 4.99, 154, 16.99, 'R', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''butler'':8 ''compos'':11 ''cow'':17 ''desert'':21 ''doubtfir'':1 ''intrepid'':4 ''labyrinth'':2 ''mad'':16 ''meet'':14 ''must'':13 ''panorama'':5 ''sahara'':20');
INSERT INTO film VALUES (247, 'DOWNHILL ENOUGH', 'A Emotional Tale of a Pastry Chef And a Forensic Psychologist who must Succumb a Monkey in The Sahara Desert', 2006, 1, NULL, 3, 0.99, 47, 19.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''chef'':9 ''desert'':22 ''downhil'':1 ''emot'':4 ''enough'':2 ''forens'':12 ''monkey'':18 ''must'':15 ''pastri'':8 ''psychologist'':13 ''sahara'':21 ''succumb'':16 ''tale'':5');
INSERT INTO film VALUES (248, 'DOZEN LION', 'A Taut Drama of a Cat And a Girl who must Defeat a Frisbee in The Canadian Rockies', 2006, 1, NULL, 6, 4.99, 177, 20.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''canadian'':19 ''cat'':8 ''defeat'':14 ''dozen'':1 ''drama'':5 ''frisbe'':16 ''girl'':11 ''lion'':2 ''must'':13 ''rocki'':20 ''taut'':4');
INSERT INTO film VALUES (249, 'DRACULA CRYSTAL', 'A Thrilling Reflection of a Feminist And a Cat who must Find a Frisbee in An Abandoned Fun House', 2006, 1, NULL, 7, 0.99, 176, 26.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries}', '''abandon'':19 ''cat'':11 ''crystal'':2 ''dracula'':1 ''feminist'':8 ''find'':14 ''frisbe'':16 ''fun'':20 ''hous'':21 ''must'':13 ''reflect'':5 ''thrill'':4');
INSERT INTO film VALUES (250, 'DRAGON SQUAD', 'A Taut Reflection of a Boy And a Waitress who must Outgun a Teacher in Ancient China', 2006, 1, NULL, 4, 0.99, 170, 26.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''ancient'':18 ''boy'':8 ''china'':19 ''dragon'':1 ''must'':13 ''outgun'':14 ''reflect'':5 ''squad'':2 ''taut'':4 ''teacher'':16 ''waitress'':11');
INSERT INTO film VALUES (251, 'DRAGONFLY STRANGERS', 'A Boring Documentary of a Pioneer And a Man who must Vanquish a Man in Nigeria', 2006, 1, NULL, 6, 4.99, 133, 19.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''bore'':4 ''documentari'':5 ''dragonfli'':1 ''man'':11,16 ''must'':13 ''nigeria'':18 ''pioneer'':8 ''stranger'':2 ''vanquish'':14');
INSERT INTO film VALUES (252, 'DREAM PICKUP', 'A Epic Display of a Car And a Composer who must Overcome a Forensic Psychologist in The Gulf of Mexico', 2006, 1, NULL, 6, 2.99, 135, 18.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''car'':8 ''compos'':11 ''display'':5 ''dream'':1 ''epic'':4 ''forens'':16 ''gulf'':20 ''mexico'':22 ''must'':13 ''overcom'':14 ''pickup'':2 ''psychologist'':17');
INSERT INTO film VALUES (253, 'DRIFTER COMMANDMENTS', 'A Epic Reflection of a Womanizer And a Squirrel who must Discover a Husband in A Jet Boat', 2006, 1, NULL, 5, 4.99, 61, 18.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''boat'':20 ''command'':2 ''discov'':14 ''drifter'':1 ''epic'':4 ''husband'':16 ''jet'':19 ''must'':13 ''reflect'':5 ''squirrel'':11 ''woman'':8');
INSERT INTO film VALUES (254, 'DRIVER ANNIE', 'A Lacklusture Character Study of a Butler And a Car who must Redeem a Boat in An Abandoned Fun House', 2006, 1, NULL, 4, 2.99, 159, 11.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''abandon'':20 ''anni'':2 ''boat'':17 ''butler'':9 ''car'':12 ''charact'':5 ''driver'':1 ''fun'':21 ''hous'':22 ''lacklustur'':4 ''must'':14 ''redeem'':15 ''studi'':6');
INSERT INTO film VALUES (255, 'DRIVING POLISH', 'A Action-Packed Yarn of a Feminist And a Technical Writer who must Sink a Boat in An Abandoned Mine Shaft', 2006, 1, NULL, 6, 4.99, 175, 21.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''abandon'':22 ''action'':5 ''action-pack'':4 ''boat'':19 ''drive'':1 ''feminist'':10 ''mine'':23 ''must'':16 ''pack'':6 ''polish'':2 ''shaft'':24 ''sink'':17 ''technic'':13 ''writer'':14 ''yarn'':7');
INSERT INTO film VALUES (256, 'DROP WATERFRONT', 'A Fanciful Documentary of a Husband And a Explorer who must Reach a Madman in Ancient China', 2006, 1, NULL, 6, 4.99, 178, 20.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''ancient'':18 ''china'':19 ''documentari'':5 ''drop'':1 ''explor'':11 ''fanci'':4 ''husband'':8 ''madman'':16 ''must'':13 ''reach'':14 ''waterfront'':2');
INSERT INTO film VALUES (257, 'DRUMLINE CYCLONE', 'A Insightful Panorama of a Monkey And a Sumo Wrestler who must Outrace a Mad Scientist in The Canadian Rockies', 2006, 1, NULL, 3, 0.99, 110, 14.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''canadian'':21 ''cyclon'':2 ''drumlin'':1 ''insight'':4 ''mad'':17 ''monkey'':8 ''must'':14 ''outrac'':15 ''panorama'':5 ''rocki'':22 ''scientist'':18 ''sumo'':11 ''wrestler'':12');
INSERT INTO film VALUES (258, 'DRUMS DYNAMITE', 'A Epic Display of a Crocodile And a Crocodile who must Confront a Dog in An Abandoned Amusement Park', 2006, 1, NULL, 6, 0.99, 96, 11.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers}', '''abandon'':19 ''amus'':20 ''confront'':14 ''crocodil'':8,11 ''display'':5 ''dog'':16 ''drum'':1 ''dynamit'':2 ''epic'':4 ''must'':13 ''park'':21');
INSERT INTO film VALUES (259, 'DUCK RACER', 'A Lacklusture Yarn of a Teacher And a Squirrel who must Overcome a Dog in A Shark Tank', 2006, 1, NULL, 4, 2.99, 116, 15.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''dog'':16 ''duck'':1 ''lacklustur'':4 ''must'':13 ''overcom'':14 ''racer'':2 ''shark'':19 ''squirrel'':11 ''tank'':20 ''teacher'':8 ''yarn'':5');
INSERT INTO film VALUES (260, 'DUDE BLINDNESS', 'A Stunning Reflection of a Husband And a Lumberjack who must Face a Frisbee in An Abandoned Fun House', 2006, 1, NULL, 3, 4.99, 132, 9.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''abandon'':19 ''blind'':2 ''dude'':1 ''face'':14 ''frisbe'':16 ''fun'':20 ''hous'':21 ''husband'':8 ''lumberjack'':11 ''must'':13 ''reflect'':5 ''stun'':4');
INSERT INTO film VALUES (261, 'DUFFEL APOCALYPSE', 'A Emotional Display of a Boat And a Explorer who must Challenge a Madman in A MySQL Convention', 2006, 1, NULL, 5, 0.99, 171, 13.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries}', '''apocalyps'':2 ''boat'':8 ''challeng'':14 ''convent'':20 ''display'':5 ''duffel'':1 ''emot'':4 ''explor'':11 ''madman'':16 ''must'':13 ''mysql'':19');
INSERT INTO film VALUES (262, 'DUMBO LUST', 'A Touching Display of a Feminist And a Dentist who must Conquer a Husband in The Gulf of Mexico', 2006, 1, NULL, 5, 0.99, 119, 17.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''conquer'':14 ''dentist'':11 ''display'':5 ''dumbo'':1 ''feminist'':8 ''gulf'':19 ''husband'':16 ''lust'':2 ''mexico'':21 ''must'':13 ''touch'':4');
INSERT INTO film VALUES (263, 'DURHAM PANKY', 'A Brilliant Panorama of a Girl And a Boy who must Face a Mad Scientist in An Abandoned Mine Shaft', 2006, 1, NULL, 6, 4.99, 154, 14.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''abandon'':20 ''boy'':11 ''brilliant'':4 ''durham'':1 ''face'':14 ''girl'':8 ''mad'':16 ''mine'':21 ''must'':13 ''panki'':2 ''panorama'':5 ''scientist'':17 ''shaft'':22');
INSERT INTO film VALUES (264, 'DWARFS ALTER', 'A Emotional Yarn of a Girl And a Dog who must Challenge a Composer in Ancient Japan', 2006, 1, NULL, 6, 2.99, 101, 13.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''alter'':2 ''ancient'':18 ''challeng'':14 ''compos'':16 ''dog'':11 ''dwarf'':1 ''emot'':4 ''girl'':8 ''japan'':19 ''must'':13 ''yarn'':5');
INSERT INTO film VALUES (265, 'DYING MAKER', 'A Intrepid Tale of a Boat And a Monkey who must Kill a Cat in California', 2006, 1, NULL, 5, 4.99, 168, 28.99, 'PG', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''boat'':8 ''california'':18 ''cat'':16 ''die'':1 ''intrepid'':4 ''kill'':14 ''maker'':2 ''monkey'':11 ''must'':13 ''tale'':5');
INSERT INTO film VALUES (266, 'DYNAMITE TARZAN', 'A Intrepid Documentary of a Forensic Psychologist And a Mad Scientist who must Face a Explorer in A U-Boat', 2006, 1, NULL, 4, 0.99, 141, 27.99, 'PG-13', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''boat'':23 ''documentari'':5 ''dynamit'':1 ''explor'':18 ''face'':16 ''forens'':8 ''intrepid'':4 ''mad'':12 ''must'':15 ''psychologist'':9 ''scientist'':13 ''tarzan'':2 ''u'':22 ''u-boat'':21');
INSERT INTO film VALUES (267, 'EAGLES PANKY', 'A Thoughtful Story of a Car And a Boy who must Find a A Shark in The Sahara Desert', 2006, 1, NULL, 4, 4.99, 140, 14.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''boy'':11 ''car'':8 ''desert'':21 ''eagl'':1 ''find'':14 ''must'':13 ''panki'':2 ''sahara'':20 ''shark'':17 ''stori'':5 ''thought'':4');
INSERT INTO film VALUES (268, 'EARLY HOME', 'A Amazing Panorama of a Mad Scientist And a Husband who must Meet a Woman in The Outback', 2006, 1, NULL, 6, 4.99, 96, 27.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''amaz'':4 ''earli'':1 ''home'':2 ''husband'':12 ''mad'':8 ''meet'':15 ''must'':14 ''outback'':20 ''panorama'':5 ''scientist'':9 ''woman'':17');
INSERT INTO film VALUES (269, 'EARRING INSTINCT', 'A Stunning Character Study of a Dentist And a Mad Cow who must Find a Teacher in Nigeria', 2006, 1, NULL, 3, 0.99, 98, 22.99, 'R', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''charact'':5 ''cow'':13 ''dentist'':9 ''earring'':1 ''find'':16 ''instinct'':2 ''mad'':12 ''must'':15 ''nigeria'':20 ''studi'':6 ''stun'':4 ''teacher'':18');
INSERT INTO film VALUES (270, 'EARTH VISION', 'A Stunning Drama of a Butler And a Madman who must Outrace a Womanizer in Ancient India', 2006, 1, NULL, 7, 0.99, 85, 29.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''ancient'':18 ''butler'':8 ''drama'':5 ''earth'':1 ''india'':19 ''madman'':11 ''must'':13 ''outrac'':14 ''stun'':4 ''vision'':2 ''woman'':16');
INSERT INTO film VALUES (271, 'EASY GLADIATOR', 'A Fateful Story of a Monkey And a Girl who must Overcome a Pastry Chef in Ancient India', 2006, 1, NULL, 5, 4.99, 148, 12.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''ancient'':19 ''chef'':17 ''easi'':1 ''fate'':4 ''girl'':11 ''gladiat'':2 ''india'':20 ''monkey'':8 ''must'':13 ''overcom'':14 ''pastri'':16 ''stori'':5');
INSERT INTO film VALUES (272, 'EDGE KISSING', 'A Beautiful Yarn of a Composer And a Mad Cow who must Redeem a Mad Scientist in A Jet Boat', 2006, 1, NULL, 5, 4.99, 153, 9.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''beauti'':4 ''boat'':22 ''compos'':8 ''cow'':12 ''edg'':1 ''jet'':21 ''kiss'':2 ''mad'':11,17 ''must'':14 ''redeem'':15 ''scientist'':18 ''yarn'':5');
INSERT INTO film VALUES (273, 'EFFECT GLADIATOR', 'A Beautiful Display of a Pastry Chef And a Pastry Chef who must Outgun a Forensic Psychologist in A Manhattan Penthouse', 2006, 1, NULL, 6, 0.99, 107, 14.99, 'PG', '2007-09-10 17:46:03.905795', '{Commentaries}', '''beauti'':4 ''chef'':9,13 ''display'':5 ''effect'':1 ''forens'':18 ''gladiat'':2 ''manhattan'':22 ''must'':15 ''outgun'':16 ''pastri'':8,12 ''penthous'':23 ''psychologist'':19');
INSERT INTO film VALUES (274, 'EGG IGBY', 'A Beautiful Documentary of a Boat And a Sumo Wrestler who must Succumb a Database Administrator in The First Manned Space Station', 2006, 1, NULL, 4, 2.99, 67, 20.99, 'PG', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''administr'':18 ''beauti'':4 ''boat'':8 ''databas'':17 ''documentari'':5 ''egg'':1 ''first'':21 ''igbi'':2 ''man'':22 ''must'':14 ''space'':23 ''station'':24 ''succumb'':15 ''sumo'':11 ''wrestler'':12');
INSERT INTO film VALUES (275, 'EGYPT TENENBAUMS', 'A Intrepid Story of a Madman And a Secret Agent who must Outrace a Astronaut in An Abandoned Amusement Park', 2006, 1, NULL, 3, 0.99, 85, 11.99, 'PG', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''abandon'':20 ''agent'':12 ''amus'':21 ''astronaut'':17 ''egypt'':1 ''intrepid'':4 ''madman'':8 ''must'':14 ''outrac'':15 ''park'':22 ''secret'':11 ''stori'':5 ''tenenbaum'':2');
INSERT INTO film VALUES (276, 'ELEMENT FREDDY', 'A Awe-Inspiring Reflection of a Waitress And a Squirrel who must Kill a Mad Cow in A Jet Boat', 2006, 1, NULL, 6, 4.99, 115, 28.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''awe'':5 ''awe-inspir'':4 ''boat'':23 ''cow'':19 ''element'':1 ''freddi'':2 ''inspir'':6 ''jet'':22 ''kill'':16 ''mad'':18 ''must'':15 ''reflect'':7 ''squirrel'':13 ''waitress'':10');
INSERT INTO film VALUES (277, 'ELEPHANT TROJAN', 'A Beautiful Panorama of a Lumberjack And a Forensic Psychologist who must Overcome a Frisbee in A Baloon', 2006, 1, NULL, 4, 4.99, 126, 24.99, 'PG-13', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''baloon'':20 ''beauti'':4 ''eleph'':1 ''forens'':11 ''frisbe'':17 ''lumberjack'':8 ''must'':14 ''overcom'':15 ''panorama'':5 ''psychologist'':12 ''trojan'':2');
INSERT INTO film VALUES (278, 'ELF MURDER', 'A Action-Packed Story of a Frisbee And a Woman who must Reach a Girl in An Abandoned Mine Shaft', 2006, 1, NULL, 4, 4.99, 155, 19.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''abandon'':21 ''action'':5 ''action-pack'':4 ''elf'':1 ''frisbe'':10 ''girl'':18 ''mine'':22 ''murder'':2 ''must'':15 ''pack'':6 ''reach'':16 ''shaft'':23 ''stori'':7 ''woman'':13');
INSERT INTO film VALUES (279, 'ELIZABETH SHANE', 'A Lacklusture Display of a Womanizer And a Dog who must Face a Sumo Wrestler in Ancient Japan', 2006, 1, NULL, 7, 4.99, 152, 11.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''ancient'':19 ''display'':5 ''dog'':11 ''elizabeth'':1 ''face'':14 ''japan'':20 ''lacklustur'':4 ''must'':13 ''shane'':2 ''sumo'':16 ''woman'':8 ''wrestler'':17');
INSERT INTO film VALUES (280, 'EMPIRE MALKOVICH', 'A Amazing Story of a Feminist And a Cat who must Face a Car in An Abandoned Fun House', 2006, 1, NULL, 7, 0.99, 177, 26.99, 'G', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''abandon'':19 ''amaz'':4 ''car'':16 ''cat'':11 ''empir'':1 ''face'':14 ''feminist'':8 ''fun'':20 ''hous'':21 ''malkovich'':2 ''must'':13 ''stori'':5');
INSERT INTO film VALUES (281, 'ENCINO ELF', 'A Astounding Drama of a Feminist And a Teacher who must Confront a Husband in A Baloon', 2006, 1, NULL, 6, 0.99, 143, 9.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''astound'':4 ''baloon'':19 ''confront'':14 ''drama'':5 ''elf'':2 ''encino'':1 ''feminist'':8 ''husband'':16 ''must'':13 ''teacher'':11');
INSERT INTO film VALUES (282, 'ENCOUNTERS CURTAIN', 'A Insightful Epistle of a Pastry Chef And a Womanizer who must Build a Boat in New Orleans', 2006, 1, NULL, 5, 0.99, 92, 20.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers}', '''boat'':17 ''build'':15 ''chef'':9 ''curtain'':2 ''encount'':1 ''epistl'':5 ''insight'':4 ''must'':14 ''new'':19 ''orlean'':20 ''pastri'':8 ''woman'':12');
INSERT INTO film VALUES (283, 'ENDING CROWDS', 'A Unbelieveable Display of a Dentist And a Madman who must Vanquish a Squirrel in Berlin', 2006, 1, NULL, 6, 0.99, 85, 10.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''berlin'':18 ''crowd'':2 ''dentist'':8 ''display'':5 ''end'':1 ''madman'':11 ''must'':13 ''squirrel'':16 ''unbeliev'':4 ''vanquish'':14');
INSERT INTO film VALUES (284, 'ENEMY ODDS', 'A Fanciful Panorama of a Mad Scientist And a Woman who must Pursue a Astronaut in Ancient India', 2006, 1, NULL, 5, 4.99, 77, 23.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers}', '''ancient'':19 ''astronaut'':17 ''enemi'':1 ''fanci'':4 ''india'':20 ''mad'':8 ''must'':14 ''odd'':2 ''panorama'':5 ''pursu'':15 ''scientist'':9 ''woman'':12');
INSERT INTO film VALUES (285, 'ENGLISH BULWORTH', 'A Intrepid Epistle of a Pastry Chef And a Pastry Chef who must Pursue a Crocodile in Ancient China', 2006, 1, NULL, 3, 0.99, 51, 18.99, 'PG-13', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''ancient'':20 ''bulworth'':2 ''chef'':9,13 ''china'':21 ''crocodil'':18 ''english'':1 ''epistl'':5 ''intrepid'':4 ''must'':15 ''pastri'':8,12 ''pursu'':16');
INSERT INTO film VALUES (286, 'ENOUGH RAGING', 'A Astounding Character Study of a Boat And a Secret Agent who must Find a Mad Cow in The Sahara Desert', 2006, 1, NULL, 7, 2.99, 158, 16.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries}', '''agent'':13 ''astound'':4 ''boat'':9 ''charact'':5 ''cow'':19 ''desert'':23 ''enough'':1 ''find'':16 ''mad'':18 ''must'':15 ''rage'':2 ''sahara'':22 ''secret'':12 ''studi'':6');
INSERT INTO film VALUES (287, 'ENTRAPMENT SATISFACTION', 'A Thoughtful Panorama of a Hunter And a Teacher who must Reach a Mad Cow in A U-Boat', 2006, 1, NULL, 5, 0.99, 176, 19.99, 'R', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''boat'':22 ''cow'':17 ''entrap'':1 ''hunter'':8 ''mad'':16 ''must'':13 ''panorama'':5 ''reach'':14 ''satisfact'':2 ''teacher'':11 ''thought'':4 ''u'':21 ''u-boat'':20');
INSERT INTO film VALUES (288, 'ESCAPE METROPOLIS', 'A Taut Yarn of a Astronaut And a Technical Writer who must Outgun a Boat in New Orleans', 2006, 1, NULL, 7, 2.99, 167, 20.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers}', '''astronaut'':8 ''boat'':17 ''escap'':1 ''metropoli'':2 ''must'':14 ''new'':19 ''orlean'':20 ''outgun'':15 ''taut'':4 ''technic'':11 ''writer'':12 ''yarn'':5');
INSERT INTO film VALUES (289, 'EVE RESURRECTION', 'A Awe-Inspiring Yarn of a Pastry Chef And a Database Administrator who must Challenge a Teacher in A Baloon', 2006, 1, NULL, 5, 4.99, 66, 25.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''administr'':15 ''awe'':5 ''awe-inspir'':4 ''baloon'':23 ''challeng'':18 ''chef'':11 ''databas'':14 ''eve'':1 ''inspir'':6 ''must'':17 ''pastri'':10 ''resurrect'':2 ''teacher'':20 ''yarn'':7');
INSERT INTO film VALUES (290, 'EVERYONE CRAFT', 'A Fateful Display of a Waitress And a Dentist who must Reach a Butler in Nigeria', 2006, 1, NULL, 4, 0.99, 163, 29.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''butler'':16 ''craft'':2 ''dentist'':11 ''display'':5 ''everyon'':1 ''fate'':4 ''must'':13 ''nigeria'':18 ''reach'':14 ''waitress'':8');
INSERT INTO film VALUES (291, 'EVOLUTION ALTER', 'A Fanciful Character Study of a Feminist And a Madman who must Find a Explorer in A Baloon Factory', 2006, 1, NULL, 5, 0.99, 174, 10.99, 'PG-13', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''alter'':2 ''baloon'':20 ''charact'':5 ''evolut'':1 ''explor'':17 ''factori'':21 ''fanci'':4 ''feminist'':9 ''find'':15 ''madman'':12 ''must'':14 ''studi'':6');
INSERT INTO film VALUES (292, 'EXCITEMENT EVE', 'A Brilliant Documentary of a Monkey And a Car who must Conquer a Crocodile in A Shark Tank', 2006, 1, NULL, 3, 0.99, 51, 20.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries}', '''brilliant'':4 ''car'':11 ''conquer'':14 ''crocodil'':16 ''documentari'':5 ''eve'':2 ''excit'':1 ''monkey'':8 ''must'':13 ''shark'':19 ''tank'':20');
INSERT INTO film VALUES (293, 'EXORCIST STING', 'A Touching Drama of a Dog And a Sumo Wrestler who must Conquer a Mad Scientist in Berlin', 2006, 1, NULL, 6, 2.99, 167, 17.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''berlin'':20 ''conquer'':15 ''dog'':8 ''drama'':5 ''exorcist'':1 ''mad'':17 ''must'':14 ''scientist'':18 ''sting'':2 ''sumo'':11 ''touch'':4 ''wrestler'':12');
INSERT INTO film VALUES (294, 'EXPECATIONS NATURAL', 'A Amazing Drama of a Butler And a Husband who must Reach a A Shark in A U-Boat', 2006, 1, NULL, 5, 4.99, 138, 26.99, 'PG-13', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''amaz'':4 ''boat'':22 ''butler'':8 ''drama'':5 ''expec'':1 ''husband'':11 ''must'':13 ''natur'':2 ''reach'':14 ''shark'':17 ''u'':21 ''u-boat'':20');
INSERT INTO film VALUES (295, 'EXPENDABLE STALLION', 'A Amazing Character Study of a Mad Cow And a Squirrel who must Discover a Hunter in A U-Boat', 2006, 1, NULL, 3, 0.99, 97, 14.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''amaz'':4 ''boat'':23 ''charact'':5 ''cow'':10 ''discov'':16 ''expend'':1 ''hunter'':18 ''mad'':9 ''must'':15 ''squirrel'':13 ''stallion'':2 ''studi'':6 ''u'':22 ''u-boat'':21');
INSERT INTO film VALUES (296, 'EXPRESS LONELY', 'A Boring Drama of a Astronaut And a Boat who must Face a Boat in California', 2006, 1, NULL, 5, 2.99, 178, 23.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers}', '''astronaut'':8 ''boat'':11,16 ''bore'':4 ''california'':18 ''drama'':5 ''express'':1 ''face'':14 ''lone'':2 ''must'':13');
INSERT INTO film VALUES (297, 'EXTRAORDINARY CONQUERER', 'A Stunning Story of a Dog And a Feminist who must Face a Forensic Psychologist in Berlin', 2006, 1, NULL, 6, 2.99, 122, 29.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''berlin'':19 ''conquer'':2 ''dog'':8 ''extraordinari'':1 ''face'':14 ''feminist'':11 ''forens'':16 ''must'':13 ''psychologist'':17 ''stori'':5 ''stun'':4');
INSERT INTO film VALUES (298, 'EYES DRIVING', 'A Thrilling Story of a Cat And a Waitress who must Fight a Explorer in The Outback', 2006, 1, NULL, 4, 2.99, 172, 13.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''cat'':8 ''drive'':2 ''explor'':16 ''eye'':1 ''fight'':14 ''must'':13 ''outback'':19 ''stori'':5 ''thrill'':4 ''waitress'':11');
INSERT INTO film VALUES (299, 'FACTORY DRAGON', 'A Action-Packed Saga of a Teacher And a Frisbee who must Escape a Lumberjack in The Sahara Desert', 2006, 1, NULL, 4, 0.99, 144, 9.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''action'':5 ''action-pack'':4 ''desert'':22 ''dragon'':2 ''escap'':16 ''factori'':1 ''frisbe'':13 ''lumberjack'':18 ''must'':15 ''pack'':6 ''saga'':7 ''sahara'':21 ''teacher'':10');
INSERT INTO film VALUES (300, 'FALCON VOLUME', 'A Fateful Saga of a Sumo Wrestler And a Hunter who must Redeem a A Shark in New Orleans', 2006, 1, NULL, 5, 4.99, 102, 21.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''falcon'':1 ''fate'':4 ''hunter'':12 ''must'':14 ''new'':20 ''orlean'':21 ''redeem'':15 ''saga'':5 ''shark'':18 ''sumo'':8 ''volum'':2 ''wrestler'':9');
INSERT INTO film VALUES (301, 'FAMILY SWEET', 'A Epic Documentary of a Teacher And a Boy who must Escape a Woman in Berlin', 2006, 1, NULL, 4, 0.99, 155, 24.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers}', '''berlin'':18 ''boy'':11 ''documentari'':5 ''epic'':4 ''escap'':14 ''famili'':1 ''must'':13 ''sweet'':2 ''teacher'':8 ''woman'':16');
INSERT INTO film VALUES (302, 'FANTASIA PARK', 'A Thoughtful Documentary of a Mad Scientist And a A Shark who must Outrace a Feminist in Australia', 2006, 1, NULL, 5, 2.99, 131, 29.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries}', '''australia'':20 ''documentari'':5 ''fantasia'':1 ''feminist'':18 ''mad'':8 ''must'':15 ''outrac'':16 ''park'':2 ''scientist'':9 ''shark'':13 ''thought'':4');
INSERT INTO film VALUES (303, 'FANTASY TROOPERS', 'A Touching Saga of a Teacher And a Monkey who must Overcome a Secret Agent in A MySQL Convention', 2006, 1, NULL, 6, 0.99, 58, 27.99, 'PG-13', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''agent'':17 ''convent'':21 ''fantasi'':1 ''monkey'':11 ''must'':13 ''mysql'':20 ''overcom'':14 ''saga'':5 ''secret'':16 ''teacher'':8 ''touch'':4 ''trooper'':2');
INSERT INTO film VALUES (304, 'FARGO GANDHI', 'A Thrilling Reflection of a Pastry Chef And a Crocodile who must Reach a Teacher in The Outback', 2006, 1, NULL, 3, 2.99, 130, 28.99, 'G', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''chef'':9 ''crocodil'':12 ''fargo'':1 ''gandhi'':2 ''must'':14 ''outback'':20 ''pastri'':8 ''reach'':15 ''reflect'':5 ''teacher'':17 ''thrill'':4');
INSERT INTO film VALUES (305, 'FATAL HAUNTED', 'A Beautiful Drama of a Student And a Secret Agent who must Confront a Dentist in Ancient Japan', 2006, 1, NULL, 6, 2.99, 91, 24.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''agent'':12 ''ancient'':19 ''beauti'':4 ''confront'':15 ''dentist'':17 ''drama'':5 ''fatal'':1 ''haunt'':2 ''japan'':20 ''must'':14 ''secret'':11 ''student'':8');
INSERT INTO film VALUES (306, 'FEATHERS METAL', 'A Thoughtful Yarn of a Monkey And a Teacher who must Find a Dog in Australia', 2006, 1, NULL, 3, 0.99, 104, 12.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''australia'':18 ''dog'':16 ''feather'':1 ''find'':14 ''metal'':2 ''monkey'':8 ''must'':13 ''teacher'':11 ''thought'':4 ''yarn'':5');
INSERT INTO film VALUES (307, 'FELLOWSHIP AUTUMN', 'A Lacklusture Reflection of a Dentist And a Hunter who must Meet a Teacher in A Baloon', 2006, 1, NULL, 6, 4.99, 77, 9.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''autumn'':2 ''baloon'':19 ''dentist'':8 ''fellowship'':1 ''hunter'':11 ''lacklustur'':4 ''meet'':14 ''must'':13 ''reflect'':5 ''teacher'':16');
INSERT INTO film VALUES (308, 'FERRIS MOTHER', 'A Touching Display of a Frisbee And a Frisbee who must Kill a Girl in The Gulf of Mexico', 2006, 1, NULL, 3, 2.99, 142, 13.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''display'':5 ''ferri'':1 ''frisbe'':8,11 ''girl'':16 ''gulf'':19 ''kill'':14 ''mexico'':21 ''mother'':2 ''must'':13 ''touch'':4');
INSERT INTO film VALUES (309, 'FEUD FROGMEN', 'A Brilliant Reflection of a Database Administrator And a Mad Cow who must Chase a Woman in The Canadian Rockies', 2006, 1, NULL, 6, 0.99, 98, 29.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''administr'':9 ''brilliant'':4 ''canadian'':21 ''chase'':16 ''cow'':13 ''databas'':8 ''feud'':1 ''frogmen'':2 ''mad'':12 ''must'':15 ''reflect'':5 ''rocki'':22 ''woman'':18');
INSERT INTO film VALUES (310, 'FEVER EMPIRE', 'A Insightful Panorama of a Cat And a Boat who must Defeat a Boat in The Gulf of Mexico', 2006, 1, NULL, 5, 4.99, 158, 20.99, 'R', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''boat'':11,16 ''cat'':8 ''defeat'':14 ''empir'':2 ''fever'':1 ''gulf'':19 ''insight'':4 ''mexico'':21 ''must'':13 ''panorama'':5');
INSERT INTO film VALUES (311, 'FICTION CHRISTMAS', 'A Emotional Yarn of a A Shark And a Student who must Battle a Robot in An Abandoned Mine Shaft', 2006, 1, NULL, 4, 0.99, 72, 14.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''abandon'':20 ''battl'':15 ''christma'':2 ''emot'':4 ''fiction'':1 ''mine'':21 ''must'':14 ''robot'':17 ''shaft'':22 ''shark'':9 ''student'':12 ''yarn'':5');
INSERT INTO film VALUES (312, 'FIDDLER LOST', 'A Boring Tale of a Squirrel And a Dog who must Challenge a Madman in The Gulf of Mexico', 2006, 1, NULL, 4, 4.99, 75, 20.99, 'R', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''bore'':4 ''challeng'':14 ''dog'':11 ''fiddler'':1 ''gulf'':19 ''lost'':2 ''madman'':16 ''mexico'':21 ''must'':13 ''squirrel'':8 ''tale'':5');
INSERT INTO film VALUES (313, 'FIDELITY DEVIL', 'A Awe-Inspiring Drama of a Technical Writer And a Composer who must Reach a Pastry Chef in A U-Boat', 2006, 1, NULL, 5, 4.99, 118, 11.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''awe'':5 ''awe-inspir'':4 ''boat'':25 ''chef'':20 ''compos'':14 ''devil'':2 ''drama'':7 ''fidel'':1 ''inspir'':6 ''must'':16 ''pastri'':19 ''reach'':17 ''technic'':10 ''u'':24 ''u-boat'':23 ''writer'':11');
INSERT INTO film VALUES (314, 'FIGHT JAWBREAKER', 'A Intrepid Panorama of a Womanizer And a Girl who must Escape a Girl in A Manhattan Penthouse', 2006, 1, NULL, 3, 0.99, 91, 13.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''escap'':14 ''fight'':1 ''girl'':11,16 ''intrepid'':4 ''jawbreak'':2 ''manhattan'':19 ''must'':13 ''panorama'':5 ''penthous'':20 ''woman'':8');
INSERT INTO film VALUES (315, 'FINDING ANACONDA', 'A Fateful Tale of a Database Administrator And a Girl who must Battle a Squirrel in New Orleans', 2006, 1, NULL, 4, 0.99, 156, 10.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''administr'':9 ''anaconda'':2 ''battl'':15 ''databas'':8 ''fate'':4 ''find'':1 ''girl'':12 ''must'':14 ''new'':19 ''orlean'':20 ''squirrel'':17 ''tale'':5');
INSERT INTO film VALUES (316, 'FIRE WOLVES', 'A Intrepid Documentary of a Frisbee And a Dog who must Outrace a Lumberjack in Nigeria', 2006, 1, NULL, 5, 4.99, 173, 18.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers}', '''documentari'':5 ''dog'':11 ''fire'':1 ''frisbe'':8 ''intrepid'':4 ''lumberjack'':16 ''must'':13 ''nigeria'':18 ''outrac'':14 ''wolv'':2');
INSERT INTO film VALUES (317, 'FIREBALL PHILADELPHIA', 'A Amazing Yarn of a Dentist And a A Shark who must Vanquish a Madman in An Abandoned Mine Shaft', 2006, 1, NULL, 4, 0.99, 148, 25.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''abandon'':20 ''amaz'':4 ''dentist'':8 ''firebal'':1 ''madman'':17 ''mine'':21 ''must'':14 ''philadelphia'':2 ''shaft'':22 ''shark'':12 ''vanquish'':15 ''yarn'':5');
INSERT INTO film VALUES (318, 'FIREHOUSE VIETNAM', 'A Awe-Inspiring Character Study of a Boat And a Boy who must Kill a Pastry Chef in The Sahara Desert', 2006, 1, NULL, 7, 0.99, 103, 14.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''awe'':5 ''awe-inspir'':4 ''boat'':11 ''boy'':14 ''charact'':7 ''chef'':20 ''desert'':24 ''firehous'':1 ''inspir'':6 ''kill'':17 ''must'':16 ''pastri'':19 ''sahara'':23 ''studi'':8 ''vietnam'':2');
INSERT INTO film VALUES (319, 'FISH OPUS', 'A Touching Display of a Feminist And a Girl who must Confront a Astronaut in Australia', 2006, 1, NULL, 4, 2.99, 125, 22.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''astronaut'':16 ''australia'':18 ''confront'':14 ''display'':5 ''feminist'':8 ''fish'':1 ''girl'':11 ''must'':13 ''opus'':2 ''touch'':4');
INSERT INTO film VALUES (320, 'FLAMINGOS CONNECTICUT', 'A Fast-Paced Reflection of a Composer And a Composer who must Meet a Cat in The Sahara Desert', 2006, 1, NULL, 4, 4.99, 80, 28.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers}', '''cat'':18 ''compos'':10,13 ''connecticut'':2 ''desert'':22 ''fast'':5 ''fast-pac'':4 ''flamingo'':1 ''meet'':16 ''must'':15 ''pace'':6 ''reflect'':7 ''sahara'':21');
INSERT INTO film VALUES (321, 'FLASH WARS', 'A Astounding Saga of a Moose And a Pastry Chef who must Chase a Student in The Gulf of Mexico', 2006, 1, NULL, 3, 4.99, 123, 21.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''astound'':4 ''chase'':15 ''chef'':12 ''flash'':1 ''gulf'':20 ''mexico'':22 ''moos'':8 ''must'':14 ''pastri'':11 ''saga'':5 ''student'':17 ''war'':2');
INSERT INTO film VALUES (322, 'FLATLINERS KILLER', 'A Taut Display of a Secret Agent And a Waitress who must Sink a Robot in An Abandoned Mine Shaft', 2006, 1, NULL, 5, 2.99, 100, 29.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''abandon'':20 ''agent'':9 ''display'':5 ''flatlin'':1 ''killer'':2 ''mine'':21 ''must'':14 ''robot'':17 ''secret'':8 ''shaft'':22 ''sink'':15 ''taut'':4 ''waitress'':12');
INSERT INTO film VALUES (323, 'FLIGHT LIES', 'A Stunning Character Study of a Crocodile And a Pioneer who must Pursue a Teacher in New Orleans', 2006, 1, NULL, 7, 4.99, 179, 22.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers}', '''charact'':5 ''crocodil'':9 ''flight'':1 ''lie'':2 ''must'':14 ''new'':19 ''orlean'':20 ''pioneer'':12 ''pursu'':15 ''studi'':6 ''stun'':4 ''teacher'':17');
INSERT INTO film VALUES (324, 'FLINTSTONES HAPPINESS', 'A Fateful Story of a Husband And a Moose who must Vanquish a Boy in California', 2006, 1, NULL, 3, 4.99, 148, 11.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''boy'':16 ''california'':18 ''fate'':4 ''flintston'':1 ''happi'':2 ''husband'':8 ''moos'':11 ''must'':13 ''stori'':5 ''vanquish'':14');
INSERT INTO film VALUES (325, 'FLOATS GARDEN', 'A Action-Packed Epistle of a Robot And a Car who must Chase a Boat in Ancient Japan', 2006, 1, NULL, 6, 2.99, 145, 29.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''action'':5 ''action-pack'':4 ''ancient'':20 ''boat'':18 ''car'':13 ''chase'':16 ''epistl'':7 ''float'':1 ''garden'':2 ''japan'':21 ''must'':15 ''pack'':6 ''robot'':10');
INSERT INTO film VALUES (326, 'FLYING HOOK', 'A Thrilling Display of a Mad Cow And a Dog who must Challenge a Frisbee in Nigeria', 2006, 1, NULL, 6, 2.99, 69, 18.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''challeng'':15 ''cow'':9 ''display'':5 ''dog'':12 ''fli'':1 ''frisbe'':17 ''hook'':2 ''mad'':8 ''must'':14 ''nigeria'':19 ''thrill'':4');
INSERT INTO film VALUES (327, 'FOOL MOCKINGBIRD', 'A Lacklusture Tale of a Crocodile And a Composer who must Defeat a Madman in A U-Boat', 2006, 1, NULL, 3, 4.99, 158, 24.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''boat'':21 ''compos'':11 ''crocodil'':8 ''defeat'':14 ''fool'':1 ''lacklustur'':4 ''madman'':16 ''mockingbird'':2 ''must'':13 ''tale'':5 ''u'':20 ''u-boat'':19');
INSERT INTO film VALUES (328, 'FOREVER CANDIDATE', 'A Unbelieveable Panorama of a Technical Writer And a Man who must Pursue a Frisbee in A U-Boat', 2006, 1, NULL, 7, 2.99, 131, 28.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''boat'':22 ''candid'':2 ''forev'':1 ''frisbe'':17 ''man'':12 ''must'':14 ''panorama'':5 ''pursu'':15 ''technic'':8 ''u'':21 ''u-boat'':20 ''unbeliev'':4 ''writer'':9');
INSERT INTO film VALUES (329, 'FORREST SONS', 'A Thrilling Documentary of a Forensic Psychologist And a Butler who must Defeat a Explorer in A Jet Boat', 2006, 1, NULL, 4, 2.99, 63, 15.99, 'R', '2007-09-10 17:46:03.905795', '{Commentaries}', '''boat'':21 ''butler'':12 ''defeat'':15 ''documentari'':5 ''explor'':17 ''forens'':8 ''forrest'':1 ''jet'':20 ''must'':14 ''psychologist'':9 ''son'':2 ''thrill'':4');
INSERT INTO film VALUES (330, 'FORRESTER COMANCHEROS', 'A Fateful Tale of a Squirrel And a Forensic Psychologist who must Redeem a Man in Nigeria', 2006, 1, NULL, 7, 4.99, 112, 22.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''comanchero'':2 ''fate'':4 ''forens'':11 ''forrest'':1 ''man'':17 ''must'':14 ''nigeria'':19 ''psychologist'':12 ''redeem'':15 ''squirrel'':8 ''tale'':5');
INSERT INTO film VALUES (331, 'FORWARD TEMPLE', 'A Astounding Display of a Forensic Psychologist And a Mad Scientist who must Challenge a Girl in New Orleans', 2006, 1, NULL, 6, 2.99, 90, 25.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''astound'':4 ''challeng'':16 ''display'':5 ''forens'':8 ''forward'':1 ''girl'':18 ''mad'':12 ''must'':15 ''new'':20 ''orlean'':21 ''psychologist'':9 ''scientist'':13 ''templ'':2');
INSERT INTO film VALUES (332, 'FRANKENSTEIN STRANGER', 'A Insightful Character Study of a Feminist And a Pioneer who must Pursue a Pastry Chef in Nigeria', 2006, 1, NULL, 7, 0.99, 159, 16.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''charact'':5 ''chef'':18 ''feminist'':9 ''frankenstein'':1 ''insight'':4 ''must'':14 ''nigeria'':20 ''pastri'':17 ''pioneer'':12 ''pursu'':15 ''stranger'':2 ''studi'':6');
INSERT INTO film VALUES (333, 'FREAKY POCUS', 'A Fast-Paced Documentary of a Pastry Chef And a Crocodile who must Chase a Squirrel in The Gulf of Mexico', 2006, 1, NULL, 7, 2.99, 126, 16.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''chase'':17 ''chef'':11 ''crocodil'':14 ''documentari'':7 ''fast'':5 ''fast-pac'':4 ''freaki'':1 ''gulf'':22 ''mexico'':24 ''must'':16 ''pace'':6 ''pastri'':10 ''pocus'':2 ''squirrel'':19');
INSERT INTO film VALUES (334, 'FREDDY STORM', 'A Intrepid Saga of a Man And a Lumberjack who must Vanquish a Husband in The Outback', 2006, 1, NULL, 6, 4.99, 65, 21.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''freddi'':1 ''husband'':16 ''intrepid'':4 ''lumberjack'':11 ''man'':8 ''must'':13 ''outback'':19 ''saga'':5 ''storm'':2 ''vanquish'':14');
INSERT INTO film VALUES (335, 'FREEDOM CLEOPATRA', 'A Emotional Reflection of a Dentist And a Mad Cow who must Face a Squirrel in A Baloon', 2006, 1, NULL, 5, 0.99, 133, 23.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''baloon'':20 ''cleopatra'':2 ''cow'':12 ''dentist'':8 ''emot'':4 ''face'':15 ''freedom'':1 ''mad'':11 ''must'':14 ''reflect'':5 ''squirrel'':17');
INSERT INTO film VALUES (336, 'FRENCH HOLIDAY', 'A Thrilling Epistle of a Dog And a Feminist who must Kill a Madman in Berlin', 2006, 1, NULL, 5, 4.99, 99, 22.99, 'PG', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''berlin'':18 ''dog'':8 ''epistl'':5 ''feminist'':11 ''french'':1 ''holiday'':2 ''kill'':14 ''madman'':16 ''must'':13 ''thrill'':4');
INSERT INTO film VALUES (337, 'FRIDA SLIPPER', 'A Fateful Story of a Lumberjack And a Car who must Escape a Boat in An Abandoned Mine Shaft', 2006, 1, NULL, 6, 2.99, 73, 11.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''abandon'':19 ''boat'':16 ''car'':11 ''escap'':14 ''fate'':4 ''frida'':1 ''lumberjack'':8 ''mine'':20 ''must'':13 ''shaft'':21 ''slipper'':2 ''stori'':5');
INSERT INTO film VALUES (338, 'FRISCO FORREST', 'A Beautiful Documentary of a Woman And a Pioneer who must Pursue a Mad Scientist in A Shark Tank', 2006, 1, NULL, 6, 4.99, 51, 23.99, 'PG', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''beauti'':4 ''documentari'':5 ''forrest'':2 ''frisco'':1 ''mad'':16 ''must'':13 ''pioneer'':11 ''pursu'':14 ''scientist'':17 ''shark'':20 ''tank'':21 ''woman'':8');
INSERT INTO film VALUES (339, 'FROGMEN BREAKING', 'A Unbelieveable Yarn of a Mad Scientist And a Cat who must Chase a Lumberjack in Australia', 2006, 1, NULL, 5, 0.99, 111, 17.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''australia'':19 ''break'':2 ''cat'':12 ''chase'':15 ''frogmen'':1 ''lumberjack'':17 ''mad'':8 ''must'':14 ''scientist'':9 ''unbeliev'':4 ''yarn'':5');
INSERT INTO film VALUES (340, 'FRONTIER CABIN', 'A Emotional Story of a Madman And a Waitress who must Battle a Teacher in An Abandoned Fun House', 2006, 1, NULL, 6, 4.99, 183, 14.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''abandon'':19 ''battl'':14 ''cabin'':2 ''emot'':4 ''frontier'':1 ''fun'':20 ''hous'':21 ''madman'':8 ''must'':13 ''stori'':5 ''teacher'':16 ''waitress'':11');
INSERT INTO film VALUES (341, 'FROST HEAD', 'A Amazing Reflection of a Lumberjack And a Cat who must Discover a Husband in A MySQL Convention', 2006, 1, NULL, 5, 0.99, 82, 13.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''amaz'':4 ''cat'':11 ''convent'':20 ''discov'':14 ''frost'':1 ''head'':2 ''husband'':16 ''lumberjack'':8 ''must'':13 ''mysql'':19 ''reflect'':5');
INSERT INTO film VALUES (342, 'FUGITIVE MAGUIRE', 'A Taut Epistle of a Feminist And a Sumo Wrestler who must Battle a Crocodile in Australia', 2006, 1, NULL, 7, 4.99, 83, 28.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''australia'':19 ''battl'':15 ''crocodil'':17 ''epistl'':5 ''feminist'':8 ''fugit'':1 ''maguir'':2 ''must'':14 ''sumo'':11 ''taut'':4 ''wrestler'':12');
INSERT INTO film VALUES (343, 'FULL FLATLINERS', 'A Beautiful Documentary of a Astronaut And a Moose who must Pursue a Monkey in A Shark Tank', 2006, 1, NULL, 6, 2.99, 94, 14.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''astronaut'':8 ''beauti'':4 ''documentari'':5 ''flatlin'':2 ''full'':1 ''monkey'':16 ''moos'':11 ''must'':13 ''pursu'':14 ''shark'':19 ''tank'':20');
INSERT INTO film VALUES (344, 'FURY MURDER', 'A Lacklusture Reflection of a Boat And a Forensic Psychologist who must Fight a Waitress in A Monastery', 2006, 1, NULL, 3, 0.99, 178, 28.99, 'PG-13', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''boat'':8 ''fight'':15 ''forens'':11 ''furi'':1 ''lacklustur'':4 ''monasteri'':20 ''murder'':2 ''must'':14 ''psychologist'':12 ''reflect'':5 ''waitress'':17');
INSERT INTO film VALUES (345, 'GABLES METROPOLIS', 'A Fateful Display of a Cat And a Pioneer who must Challenge a Pastry Chef in A Baloon Factory', 2006, 1, NULL, 3, 0.99, 161, 17.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''baloon'':20 ''cat'':8 ''challeng'':14 ''chef'':17 ''display'':5 ''factori'':21 ''fate'':4 ''gabl'':1 ''metropoli'':2 ''must'':13 ''pastri'':16 ''pioneer'':11');
INSERT INTO film VALUES (346, 'GALAXY SWEETHEARTS', 'A Emotional Reflection of a Womanizer And a Pioneer who must Face a Squirrel in Berlin', 2006, 1, NULL, 4, 4.99, 128, 13.99, 'R', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''berlin'':18 ''emot'':4 ''face'':14 ''galaxi'':1 ''must'':13 ''pioneer'':11 ''reflect'':5 ''squirrel'':16 ''sweetheart'':2 ''woman'':8');
INSERT INTO film VALUES (347, 'GAMES BOWFINGER', 'A Astounding Documentary of a Butler And a Explorer who must Challenge a Butler in A Monastery', 2006, 1, NULL, 7, 4.99, 119, 17.99, 'PG-13', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''astound'':4 ''bowfing'':2 ''butler'':8,16 ''challeng'':14 ''documentari'':5 ''explor'':11 ''game'':1 ''monasteri'':19 ''must'':13');
INSERT INTO film VALUES (348, 'GANDHI KWAI', 'A Thoughtful Display of a Mad Scientist And a Secret Agent who must Chase a Boat in Berlin', 2006, 1, NULL, 7, 0.99, 86, 9.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers}', '''agent'':13 ''berlin'':20 ''boat'':18 ''chase'':16 ''display'':5 ''gandhi'':1 ''kwai'':2 ''mad'':8 ''must'':15 ''scientist'':9 ''secret'':12 ''thought'':4');
INSERT INTO film VALUES (349, 'GANGS PRIDE', 'A Taut Character Study of a Woman And a A Shark who must Confront a Frisbee in Berlin', 2006, 1, NULL, 4, 2.99, 185, 27.99, 'PG-13', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''berlin'':20 ''charact'':5 ''confront'':16 ''frisbe'':18 ''gang'':1 ''must'':15 ''pride'':2 ''shark'':13 ''studi'':6 ''taut'':4 ''woman'':9');
INSERT INTO film VALUES (350, 'GARDEN ISLAND', 'A Unbelieveable Character Study of a Womanizer And a Madman who must Reach a Man in The Outback', 2006, 1, NULL, 3, 4.99, 80, 21.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''charact'':5 ''garden'':1 ''island'':2 ''madman'':12 ''man'':17 ''must'':14 ''outback'':20 ''reach'':15 ''studi'':6 ''unbeliev'':4 ''woman'':9');
INSERT INTO film VALUES (351, 'GASLIGHT CRUSADE', 'A Amazing Epistle of a Boy And a Astronaut who must Redeem a Man in The Gulf of Mexico', 2006, 1, NULL, 4, 2.99, 106, 10.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''amaz'':4 ''astronaut'':11 ''boy'':8 ''crusad'':2 ''epistl'':5 ''gaslight'':1 ''gulf'':19 ''man'':16 ''mexico'':21 ''must'':13 ''redeem'':14');
INSERT INTO film VALUES (352, 'GATHERING CALENDAR', 'A Intrepid Tale of a Pioneer And a Moose who must Conquer a Frisbee in A MySQL Convention', 2006, 1, NULL, 4, 0.99, 176, 22.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''calendar'':2 ''conquer'':14 ''convent'':20 ''frisbe'':16 ''gather'':1 ''intrepid'':4 ''moos'':11 ''must'':13 ''mysql'':19 ''pioneer'':8 ''tale'':5');
INSERT INTO film VALUES (353, 'GENTLEMEN STAGE', 'A Awe-Inspiring Reflection of a Monkey And a Student who must Overcome a Dentist in The First Manned Space Station', 2006, 1, NULL, 6, 2.99, 125, 22.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''awe'':5 ''awe-inspir'':4 ''dentist'':18 ''first'':21 ''gentlemen'':1 ''inspir'':6 ''man'':22 ''monkey'':10 ''must'':15 ''overcom'':16 ''reflect'':7 ''space'':23 ''stage'':2 ''station'':24 ''student'':13');
INSERT INTO film VALUES (354, 'GHOST GROUNDHOG', 'A Brilliant Panorama of a Madman And a Composer who must Succumb a Car in Ancient India', 2006, 1, NULL, 6, 4.99, 85, 18.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''ancient'':18 ''brilliant'':4 ''car'':16 ''compos'':11 ''ghost'':1 ''groundhog'':2 ''india'':19 ''madman'':8 ''must'':13 ''panorama'':5 ''succumb'':14');
INSERT INTO film VALUES (355, 'GHOSTBUSTERS ELF', 'A Thoughtful Epistle of a Dog And a Feminist who must Chase a Composer in Berlin', 2006, 1, NULL, 7, 0.99, 101, 18.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''berlin'':18 ''chase'':14 ''compos'':16 ''dog'':8 ''elf'':2 ''epistl'':5 ''feminist'':11 ''ghostbust'':1 ''must'':13 ''thought'':4');
INSERT INTO film VALUES (356, 'GIANT TROOPERS', 'A Fateful Display of a Feminist And a Monkey who must Vanquish a Monkey in The Canadian Rockies', 2006, 1, NULL, 5, 2.99, 102, 10.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''canadian'':19 ''display'':5 ''fate'':4 ''feminist'':8 ''giant'':1 ''monkey'':11,16 ''must'':13 ''rocki'':20 ''trooper'':2 ''vanquish'':14');
INSERT INTO film VALUES (357, 'GILBERT PELICAN', 'A Fateful Tale of a Man And a Feminist who must Conquer a Crocodile in A Manhattan Penthouse', 2006, 1, NULL, 7, 0.99, 114, 13.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''conquer'':14 ''crocodil'':16 ''fate'':4 ''feminist'':11 ''gilbert'':1 ''man'':8 ''manhattan'':19 ''must'':13 ''pelican'':2 ''penthous'':20 ''tale'':5');
INSERT INTO film VALUES (358, 'GILMORE BOILED', 'A Unbelieveable Documentary of a Boat And a Husband who must Succumb a Student in A U-Boat', 2006, 1, NULL, 5, 0.99, 163, 29.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''boat'':8,21 ''boil'':2 ''documentari'':5 ''gilmor'':1 ''husband'':11 ''must'':13 ''student'':16 ''succumb'':14 ''u'':20 ''u-boat'':19 ''unbeliev'':4');
INSERT INTO film VALUES (359, 'GLADIATOR WESTWARD', 'A Astounding Reflection of a Squirrel And a Sumo Wrestler who must Sink a Dentist in Ancient Japan', 2006, 1, NULL, 6, 4.99, 173, 20.99, 'PG', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''ancient'':19 ''astound'':4 ''dentist'':17 ''gladiat'':1 ''japan'':20 ''must'':14 ''reflect'':5 ''sink'':15 ''squirrel'':8 ''sumo'':11 ''westward'':2 ''wrestler'':12');
INSERT INTO film VALUES (360, 'GLASS DYING', 'A Astounding Drama of a Frisbee And a Astronaut who must Fight a Dog in Ancient Japan', 2006, 1, NULL, 4, 0.99, 103, 24.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers}', '''ancient'':18 ''astound'':4 ''astronaut'':11 ''die'':2 ''dog'':16 ''drama'':5 ''fight'':14 ''frisbe'':8 ''glass'':1 ''japan'':19 ''must'':13');
INSERT INTO film VALUES (361, 'GLEAMING JAWBREAKER', 'A Amazing Display of a Composer And a Forensic Psychologist who must Discover a Car in The Canadian Rockies', 2006, 1, NULL, 5, 2.99, 89, 25.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''amaz'':4 ''canadian'':20 ''car'':17 ''compos'':8 ''discov'':15 ''display'':5 ''forens'':11 ''gleam'':1 ''jawbreak'':2 ''must'':14 ''psychologist'':12 ''rocki'':21');
INSERT INTO film VALUES (362, 'GLORY TRACY', 'A Amazing Saga of a Woman And a Womanizer who must Discover a Cat in The First Manned Space Station', 2006, 1, NULL, 7, 2.99, 115, 13.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''amaz'':4 ''cat'':16 ''discov'':14 ''first'':19 ''glori'':1 ''man'':20 ''must'':13 ''saga'':5 ''space'':21 ''station'':22 ''traci'':2 ''woman'':8,11');
INSERT INTO film VALUES (363, 'GO PURPLE', 'A Fast-Paced Display of a Car And a Database Administrator who must Battle a Woman in A Baloon', 2006, 1, NULL, 3, 0.99, 54, 12.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers}', '''administr'':14 ''baloon'':22 ''battl'':17 ''car'':10 ''databas'':13 ''display'':7 ''fast'':5 ''fast-pac'':4 ''go'':1 ''must'':16 ''pace'':6 ''purpl'':2 ''woman'':19');
INSERT INTO film VALUES (364, 'GODFATHER DIARY', 'A Stunning Saga of a Lumberjack And a Squirrel who must Chase a Car in The Outback', 2006, 1, NULL, 3, 2.99, 73, 14.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers}', '''car'':16 ''chase'':14 ''diari'':2 ''godfath'':1 ''lumberjack'':8 ''must'':13 ''outback'':19 ''saga'':5 ''squirrel'':11 ''stun'':4');
INSERT INTO film VALUES (365, 'GOLD RIVER', 'A Taut Documentary of a Database Administrator And a Waitress who must Reach a Mad Scientist in A Baloon Factory', 2006, 1, NULL, 4, 4.99, 154, 21.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''administr'':9 ''baloon'':21 ''databas'':8 ''documentari'':5 ''factori'':22 ''gold'':1 ''mad'':17 ''must'':14 ''reach'':15 ''river'':2 ''scientist'':18 ''taut'':4 ''waitress'':12');
INSERT INTO film VALUES (366, 'GOLDFINGER SENSIBILITY', 'A Insightful Drama of a Mad Scientist And a Hunter who must Defeat a Pastry Chef in New Orleans', 2006, 1, NULL, 3, 0.99, 93, 29.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''chef'':18 ''defeat'':15 ''drama'':5 ''goldfing'':1 ''hunter'':12 ''insight'':4 ''mad'':8 ''must'':14 ''new'':20 ''orlean'':21 ''pastri'':17 ''scientist'':9 ''sensibl'':2');
INSERT INTO film VALUES (367, 'GOLDMINE TYCOON', 'A Brilliant Epistle of a Composer And a Frisbee who must Conquer a Husband in The Outback', 2006, 1, NULL, 6, 0.99, 153, 20.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''brilliant'':4 ''compos'':8 ''conquer'':14 ''epistl'':5 ''frisbe'':11 ''goldmin'':1 ''husband'':16 ''must'':13 ''outback'':19 ''tycoon'':2');
INSERT INTO film VALUES (368, 'GONE TROUBLE', 'A Insightful Character Study of a Mad Cow And a Forensic Psychologist who must Conquer a A Shark in A Manhattan Penthouse', 2006, 1, NULL, 7, 2.99, 84, 20.99, 'R', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''charact'':5 ''conquer'':17 ''cow'':10 ''forens'':13 ''gone'':1 ''insight'':4 ''mad'':9 ''manhattan'':23 ''must'':16 ''penthous'':24 ''psychologist'':14 ''shark'':20 ''studi'':6 ''troubl'':2');
INSERT INTO film VALUES (369, 'GOODFELLAS SALUTE', 'A Unbelieveable Tale of a Dog And a Explorer who must Sink a Mad Cow in A Baloon Factory', 2006, 1, NULL, 4, 4.99, 56, 22.99, 'PG', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''baloon'':20 ''cow'':17 ''dog'':8 ''explor'':11 ''factori'':21 ''goodfella'':1 ''mad'':16 ''must'':13 ''salut'':2 ''sink'':14 ''tale'':5 ''unbeliev'':4');
INSERT INTO film VALUES (370, 'GORGEOUS BINGO', 'A Action-Packed Display of a Sumo Wrestler And a Car who must Overcome a Waitress in A Baloon Factory', 2006, 1, NULL, 4, 2.99, 108, 26.99, 'R', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''action'':5 ''action-pack'':4 ''baloon'':22 ''bingo'':2 ''car'':14 ''display'':7 ''factori'':23 ''gorgeous'':1 ''must'':16 ''overcom'':17 ''pack'':6 ''sumo'':10 ''waitress'':19 ''wrestler'':11');
INSERT INTO film VALUES (371, 'GOSFORD DONNIE', 'A Epic Panorama of a Mad Scientist And a Monkey who must Redeem a Secret Agent in Berlin', 2006, 1, NULL, 5, 4.99, 129, 17.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries}', '''agent'':18 ''berlin'':20 ''donni'':2 ''epic'':4 ''gosford'':1 ''mad'':8 ''monkey'':12 ''must'':14 ''panorama'':5 ''redeem'':15 ''scientist'':9 ''secret'':17');
INSERT INTO film VALUES (372, 'GRACELAND DYNAMITE', 'A Taut Display of a Cat And a Girl who must Overcome a Database Administrator in New Orleans', 2006, 1, NULL, 5, 4.99, 140, 26.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''administr'':17 ''cat'':8 ''databas'':16 ''display'':5 ''dynamit'':2 ''girl'':11 ''graceland'':1 ''must'':13 ''new'':19 ''orlean'':20 ''overcom'':14 ''taut'':4');
INSERT INTO film VALUES (373, 'GRADUATE LORD', 'A Lacklusture Epistle of a Girl And a A Shark who must Meet a Mad Scientist in Ancient China', 2006, 1, NULL, 7, 2.99, 156, 14.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''ancient'':20 ''china'':21 ''epistl'':5 ''girl'':8 ''graduat'':1 ''lacklustur'':4 ''lord'':2 ''mad'':17 ''meet'':15 ''must'':14 ''scientist'':18 ''shark'':12');
INSERT INTO film VALUES (374, 'GRAFFITI LOVE', 'A Unbelieveable Epistle of a Sumo Wrestler And a Hunter who must Build a Composer in Berlin', 2006, 1, NULL, 3, 0.99, 117, 29.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''berlin'':19 ''build'':15 ''compos'':17 ''epistl'':5 ''graffiti'':1 ''hunter'':12 ''love'':2 ''must'':14 ''sumo'':8 ''unbeliev'':4 ''wrestler'':9');
INSERT INTO film VALUES (375, 'GRAIL FRANKENSTEIN', 'A Unbelieveable Saga of a Teacher And a Monkey who must Fight a Girl in An Abandoned Mine Shaft', 2006, 1, NULL, 4, 2.99, 85, 17.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''abandon'':19 ''fight'':14 ''frankenstein'':2 ''girl'':16 ''grail'':1 ''mine'':20 ''monkey'':11 ''must'':13 ''saga'':5 ''shaft'':21 ''teacher'':8 ''unbeliev'':4');
INSERT INTO film VALUES (376, 'GRAPES FURY', 'A Boring Yarn of a Mad Cow And a Sumo Wrestler who must Meet a Robot in Australia', 2006, 1, NULL, 4, 0.99, 155, 20.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''australia'':20 ''bore'':4 ''cow'':9 ''furi'':2 ''grape'':1 ''mad'':8 ''meet'':16 ''must'':15 ''robot'':18 ''sumo'':12 ''wrestler'':13 ''yarn'':5');
INSERT INTO film VALUES (377, 'GREASE YOUTH', 'A Emotional Panorama of a Secret Agent And a Waitress who must Escape a Composer in Soviet Georgia', 2006, 1, NULL, 7, 0.99, 135, 20.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''agent'':9 ''compos'':17 ''emot'':4 ''escap'':15 ''georgia'':20 ''greas'':1 ''must'':14 ''panorama'':5 ''secret'':8 ''soviet'':19 ''waitress'':12 ''youth'':2');
INSERT INTO film VALUES (378, 'GREATEST NORTH', 'A Astounding Character Study of a Secret Agent And a Robot who must Build a A Shark in Berlin', 2006, 1, NULL, 5, 2.99, 93, 24.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''agent'':10 ''astound'':4 ''berlin'':21 ''build'':16 ''charact'':5 ''greatest'':1 ''must'':15 ''north'':2 ''robot'':13 ''secret'':9 ''shark'':19 ''studi'':6');
INSERT INTO film VALUES (379, 'GREEDY ROOTS', 'A Amazing Reflection of a A Shark And a Butler who must Chase a Hunter in The Canadian Rockies', 2006, 1, NULL, 7, 0.99, 166, 14.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''amaz'':4 ''butler'':12 ''canadian'':20 ''chase'':15 ''greedi'':1 ''hunter'':17 ''must'':14 ''reflect'':5 ''rocki'':21 ''root'':2 ''shark'':9');
INSERT INTO film VALUES (380, 'GREEK EVERYONE', 'A Stunning Display of a Butler And a Teacher who must Confront a A Shark in The First Manned Space Station', 2006, 1, NULL, 7, 2.99, 176, 11.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''butler'':8 ''confront'':14 ''display'':5 ''everyon'':2 ''first'':20 ''greek'':1 ''man'':21 ''must'':13 ''shark'':17 ''space'':22 ''station'':23 ''stun'':4 ''teacher'':11');
INSERT INTO film VALUES (381, 'GRINCH MASSAGE', 'A Intrepid Display of a Madman And a Feminist who must Pursue a Pioneer in The First Manned Space Station', 2006, 1, NULL, 7, 4.99, 150, 25.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers}', '''display'':5 ''feminist'':11 ''first'':19 ''grinch'':1 ''intrepid'':4 ''madman'':8 ''man'':20 ''massag'':2 ''must'':13 ''pioneer'':16 ''pursu'':14 ''space'':21 ''station'':22');
INSERT INTO film VALUES (382, 'GRIT CLOCKWORK', 'A Thoughtful Display of a Dentist And a Squirrel who must Confront a Lumberjack in A Shark Tank', 2006, 1, NULL, 3, 0.99, 137, 21.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''clockwork'':2 ''confront'':14 ''dentist'':8 ''display'':5 ''grit'':1 ''lumberjack'':16 ''must'':13 ''shark'':19 ''squirrel'':11 ''tank'':20 ''thought'':4');
INSERT INTO film VALUES (383, 'GROOVE FICTION', 'A Unbelieveable Reflection of a Moose And a A Shark who must Defeat a Lumberjack in An Abandoned Mine Shaft', 2006, 1, NULL, 6, 0.99, 111, 13.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''abandon'':20 ''defeat'':15 ''fiction'':2 ''groov'':1 ''lumberjack'':17 ''mine'':21 ''moos'':8 ''must'':14 ''reflect'':5 ''shaft'':22 ''shark'':12 ''unbeliev'':4');
INSERT INTO film VALUES (384, 'GROSSE WONDERFUL', 'A Epic Drama of a Cat And a Explorer who must Redeem a Moose in Australia', 2006, 1, NULL, 5, 4.99, 49, 19.99, 'R', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''australia'':18 ''cat'':8 ''drama'':5 ''epic'':4 ''explor'':11 ''gross'':1 ''moos'':16 ''must'':13 ''redeem'':14 ''wonder'':2');
INSERT INTO film VALUES (385, 'GROUNDHOG UNCUT', 'A Brilliant Panorama of a Astronaut And a Technical Writer who must Discover a Butler in A Manhattan Penthouse', 2006, 1, NULL, 6, 4.99, 139, 26.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''astronaut'':8 ''brilliant'':4 ''butler'':17 ''discov'':15 ''groundhog'':1 ''manhattan'':20 ''must'':14 ''panorama'':5 ''penthous'':21 ''technic'':11 ''uncut'':2 ''writer'':12');
INSERT INTO film VALUES (386, 'GUMP DATE', 'A Intrepid Yarn of a Explorer And a Student who must Kill a Husband in An Abandoned Mine Shaft', 2006, 1, NULL, 3, 4.99, 53, 12.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''abandon'':19 ''date'':2 ''explor'':8 ''gump'':1 ''husband'':16 ''intrepid'':4 ''kill'':14 ''mine'':20 ''must'':13 ''shaft'':21 ''student'':11 ''yarn'':5');
INSERT INTO film VALUES (387, 'GUN BONNIE', 'A Boring Display of a Sumo Wrestler And a Husband who must Build a Waitress in The Gulf of Mexico', 2006, 1, NULL, 7, 0.99, 100, 27.99, 'G', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''bonni'':2 ''bore'':4 ''build'':15 ''display'':5 ''gulf'':20 ''gun'':1 ''husband'':12 ''mexico'':22 ''must'':14 ''sumo'':8 ''waitress'':17 ''wrestler'':9');
INSERT INTO film VALUES (388, 'GUNFIGHT MOON', 'A Epic Reflection of a Pastry Chef And a Explorer who must Reach a Dentist in The Sahara Desert', 2006, 1, NULL, 5, 0.99, 70, 16.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''chef'':9 ''dentist'':17 ''desert'':21 ''epic'':4 ''explor'':12 ''gunfight'':1 ''moon'':2 ''must'':14 ''pastri'':8 ''reach'':15 ''reflect'':5 ''sahara'':20');
INSERT INTO film VALUES (389, 'GUNFIGHTER MUSSOLINI', 'A Touching Saga of a Robot And a Boy who must Kill a Man in Ancient Japan', 2006, 1, NULL, 3, 2.99, 127, 9.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''ancient'':18 ''boy'':11 ''gunfight'':1 ''japan'':19 ''kill'':14 ''man'':16 ''mussolini'':2 ''must'':13 ''robot'':8 ''saga'':5 ''touch'':4');
INSERT INTO film VALUES (390, 'GUYS FALCON', 'A Boring Story of a Woman And a Feminist who must Redeem a Squirrel in A U-Boat', 2006, 1, NULL, 4, 4.99, 84, 20.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''boat'':21 ''bore'':4 ''falcon'':2 ''feminist'':11 ''guy'':1 ''must'':13 ''redeem'':14 ''squirrel'':16 ''stori'':5 ''u'':20 ''u-boat'':19 ''woman'':8');
INSERT INTO film VALUES (391, 'HALF OUTFIELD', 'A Epic Epistle of a Database Administrator And a Crocodile who must Face a Madman in A Jet Boat', 2006, 1, NULL, 6, 2.99, 146, 25.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''administr'':9 ''boat'':21 ''crocodil'':12 ''databas'':8 ''epic'':4 ''epistl'':5 ''face'':15 ''half'':1 ''jet'':20 ''madman'':17 ''must'':14 ''outfield'':2');
INSERT INTO film VALUES (392, 'HALL CASSIDY', 'A Beautiful Panorama of a Pastry Chef And a A Shark who must Battle a Pioneer in Soviet Georgia', 2006, 1, NULL, 5, 4.99, 51, 13.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''battl'':16 ''beauti'':4 ''cassidi'':2 ''chef'':9 ''georgia'':21 ''hall'':1 ''must'':15 ''panorama'':5 ''pastri'':8 ''pioneer'':18 ''shark'':13 ''soviet'':20');
INSERT INTO film VALUES (393, 'HALLOWEEN NUTS', 'A Amazing Panorama of a Forensic Psychologist And a Technical Writer who must Fight a Dentist in A U-Boat', 2006, 1, NULL, 6, 2.99, 47, 19.99, 'PG-13', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''amaz'':4 ''boat'':23 ''dentist'':18 ''fight'':16 ''forens'':8 ''halloween'':1 ''must'':15 ''nut'':2 ''panorama'':5 ''psychologist'':9 ''technic'':12 ''u'':22 ''u-boat'':21 ''writer'':13');
INSERT INTO film VALUES (394, 'HAMLET WISDOM', 'A Touching Reflection of a Man And a Man who must Sink a Robot in The Outback', 2006, 1, NULL, 7, 2.99, 146, 21.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''hamlet'':1 ''man'':8,11 ''must'':13 ''outback'':19 ''reflect'':5 ''robot'':16 ''sink'':14 ''touch'':4 ''wisdom'':2');
INSERT INTO film VALUES (395, 'HANDICAP BOONDOCK', 'A Beautiful Display of a Pioneer And a Squirrel who must Vanquish a Sumo Wrestler in Soviet Georgia', 2006, 1, NULL, 4, 0.99, 108, 28.99, 'R', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''beauti'':4 ''boondock'':2 ''display'':5 ''georgia'':20 ''handicap'':1 ''must'':13 ''pioneer'':8 ''soviet'':19 ''squirrel'':11 ''sumo'':16 ''vanquish'':14 ''wrestler'':17');
INSERT INTO film VALUES (396, 'HANGING DEEP', 'A Action-Packed Yarn of a Boat And a Crocodile who must Build a Monkey in Berlin', 2006, 1, NULL, 5, 4.99, 62, 18.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''action'':5 ''action-pack'':4 ''berlin'':20 ''boat'':10 ''build'':16 ''crocodil'':13 ''deep'':2 ''hang'':1 ''monkey'':18 ''must'':15 ''pack'':6 ''yarn'':7');
INSERT INTO film VALUES (397, 'HANKY OCTOBER', 'A Boring Epistle of a Database Administrator And a Explorer who must Pursue a Madman in Soviet Georgia', 2006, 1, NULL, 5, 2.99, 107, 26.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''administr'':9 ''bore'':4 ''databas'':8 ''epistl'':5 ''explor'':12 ''georgia'':20 ''hanki'':1 ''madman'':17 ''must'':14 ''octob'':2 ''pursu'':15 ''soviet'':19');
INSERT INTO film VALUES (398, 'HANOVER GALAXY', 'A Stunning Reflection of a Girl And a Secret Agent who must Succumb a Boy in A MySQL Convention', 2006, 1, NULL, 5, 4.99, 47, 21.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''agent'':12 ''boy'':17 ''convent'':21 ''galaxi'':2 ''girl'':8 ''hanov'':1 ''must'':14 ''mysql'':20 ''reflect'':5 ''secret'':11 ''stun'':4 ''succumb'':15');
INSERT INTO film VALUES (399, 'HAPPINESS UNITED', 'A Action-Packed Panorama of a Husband And a Feminist who must Meet a Forensic Psychologist in Ancient Japan', 2006, 1, NULL, 6, 2.99, 100, 23.99, 'G', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''action'':5 ''action-pack'':4 ''ancient'':21 ''feminist'':13 ''forens'':18 ''happi'':1 ''husband'':10 ''japan'':22 ''meet'':16 ''must'':15 ''pack'':6 ''panorama'':7 ''psychologist'':19 ''unit'':2');
INSERT INTO film VALUES (400, 'HARDLY ROBBERS', 'A Emotional Character Study of a Hunter And a Car who must Kill a Woman in Berlin', 2006, 1, NULL, 7, 2.99, 72, 15.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''berlin'':19 ''car'':12 ''charact'':5 ''emot'':4 ''hard'':1 ''hunter'':9 ''kill'':15 ''must'':14 ''robber'':2 ''studi'':6 ''woman'':17');
INSERT INTO film VALUES (401, 'HAROLD FRENCH', 'A Stunning Saga of a Sumo Wrestler And a Student who must Outrace a Moose in The Sahara Desert', 2006, 1, NULL, 6, 0.99, 168, 10.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''desert'':21 ''french'':2 ''harold'':1 ''moos'':17 ''must'':14 ''outrac'':15 ''saga'':5 ''sahara'':20 ''student'':12 ''stun'':4 ''sumo'':8 ''wrestler'':9');
INSERT INTO film VALUES (402, 'HARPER DYING', 'A Awe-Inspiring Reflection of a Woman And a Cat who must Confront a Feminist in The Sahara Desert', 2006, 1, NULL, 3, 0.99, 52, 15.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers}', '''awe'':5 ''awe-inspir'':4 ''cat'':13 ''confront'':16 ''desert'':22 ''die'':2 ''feminist'':18 ''harper'':1 ''inspir'':6 ''must'':15 ''reflect'':7 ''sahara'':21 ''woman'':10');
INSERT INTO film VALUES (403, 'HARRY IDAHO', 'A Taut Yarn of a Technical Writer And a Feminist who must Outrace a Dog in California', 2006, 1, NULL, 5, 4.99, 121, 18.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''california'':19 ''dog'':17 ''feminist'':12 ''harri'':1 ''idaho'':2 ''must'':14 ''outrac'':15 ''taut'':4 ''technic'':8 ''writer'':9 ''yarn'':5');
INSERT INTO film VALUES (404, 'HATE HANDICAP', 'A Intrepid Reflection of a Mad Scientist And a Pioneer who must Overcome a Hunter in The First Manned Space Station', 2006, 1, NULL, 4, 0.99, 107, 26.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''first'':20 ''handicap'':2 ''hate'':1 ''hunter'':17 ''intrepid'':4 ''mad'':8 ''man'':21 ''must'':14 ''overcom'':15 ''pioneer'':12 ''reflect'':5 ''scientist'':9 ''space'':22 ''station'':23');
INSERT INTO film VALUES (405, 'HAUNTED ANTITRUST', 'A Amazing Saga of a Man And a Dentist who must Reach a Technical Writer in Ancient India', 2006, 1, NULL, 6, 4.99, 76, 13.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''amaz'':4 ''ancient'':19 ''antitrust'':2 ''dentist'':11 ''haunt'':1 ''india'':20 ''man'':8 ''must'':13 ''reach'':14 ''saga'':5 ''technic'':16 ''writer'':17');
INSERT INTO film VALUES (406, 'HAUNTING PIANIST', 'A Fast-Paced Story of a Database Administrator And a Composer who must Defeat a Squirrel in An Abandoned Amusement Park', 2006, 1, NULL, 5, 0.99, 181, 22.99, 'R', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''abandon'':22 ''administr'':11 ''amus'':23 ''compos'':14 ''databas'':10 ''defeat'':17 ''fast'':5 ''fast-pac'':4 ''haunt'':1 ''must'':16 ''pace'':6 ''park'':24 ''pianist'':2 ''squirrel'':19 ''stori'':7');
INSERT INTO film VALUES (407, 'HAWK CHILL', 'A Action-Packed Drama of a Mad Scientist And a Composer who must Outgun a Car in Australia', 2006, 1, NULL, 5, 0.99, 47, 12.99, 'PG-13', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''action'':5 ''action-pack'':4 ''australia'':21 ''car'':19 ''chill'':2 ''compos'':14 ''drama'':7 ''hawk'':1 ''mad'':10 ''must'':16 ''outgun'':17 ''pack'':6 ''scientist'':11');
INSERT INTO film VALUES (408, 'HEAD STRANGER', 'A Thoughtful Saga of a Hunter And a Crocodile who must Confront a Dog in The Gulf of Mexico', 2006, 1, NULL, 4, 4.99, 69, 28.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''confront'':14 ''crocodil'':11 ''dog'':16 ''gulf'':19 ''head'':1 ''hunter'':8 ''mexico'':21 ''must'':13 ''saga'':5 ''stranger'':2 ''thought'':4');
INSERT INTO film VALUES (409, 'HEARTBREAKERS BRIGHT', 'A Awe-Inspiring Documentary of a A Shark And a Dentist who must Outrace a Pastry Chef in The Canadian Rockies', 2006, 1, NULL, 3, 4.99, 59, 9.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''awe'':5 ''awe-inspir'':4 ''bright'':2 ''canadian'':23 ''chef'':20 ''dentist'':14 ''documentari'':7 ''heartbreak'':1 ''inspir'':6 ''must'':16 ''outrac'':17 ''pastri'':19 ''rocki'':24 ''shark'':11');
INSERT INTO film VALUES (410, 'HEAVEN FREEDOM', 'A Intrepid Story of a Butler And a Car who must Vanquish a Man in New Orleans', 2006, 1, NULL, 7, 2.99, 48, 19.99, 'PG', '2007-09-10 17:46:03.905795', '{Commentaries}', '''butler'':8 ''car'':11 ''freedom'':2 ''heaven'':1 ''intrepid'':4 ''man'':16 ''must'':13 ''new'':18 ''orlean'':19 ''stori'':5 ''vanquish'':14');
INSERT INTO film VALUES (411, 'HEAVENLY GUN', 'A Beautiful Yarn of a Forensic Psychologist And a Frisbee who must Battle a Moose in A Jet Boat', 2006, 1, NULL, 5, 4.99, 49, 13.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''battl'':15 ''beauti'':4 ''boat'':21 ''forens'':8 ''frisbe'':12 ''gun'':2 ''heaven'':1 ''jet'':20 ''moos'':17 ''must'':14 ''psychologist'':9 ''yarn'':5');
INSERT INTO film VALUES (412, 'HEAVYWEIGHTS BEAST', 'A Unbelieveable Story of a Composer And a Dog who must Overcome a Womanizer in An Abandoned Amusement Park', 2006, 1, NULL, 6, 4.99, 102, 25.99, 'G', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''abandon'':19 ''amus'':20 ''beast'':2 ''compos'':8 ''dog'':11 ''heavyweight'':1 ''must'':13 ''overcom'':14 ''park'':21 ''stori'':5 ''unbeliev'':4 ''woman'':16');
INSERT INTO film VALUES (413, 'HEDWIG ALTER', 'A Action-Packed Yarn of a Womanizer And a Lumberjack who must Chase a Sumo Wrestler in A Monastery', 2006, 1, NULL, 7, 2.99, 169, 16.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''action'':5 ''action-pack'':4 ''alter'':2 ''chase'':16 ''hedwig'':1 ''lumberjack'':13 ''monasteri'':22 ''must'':15 ''pack'':6 ''sumo'':18 ''woman'':10 ''wrestler'':19 ''yarn'':7');
INSERT INTO film VALUES (414, 'HELLFIGHTERS SIERRA', 'A Taut Reflection of a A Shark And a Dentist who must Battle a Boat in Soviet Georgia', 2006, 1, NULL, 3, 2.99, 75, 23.99, 'PG', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''battl'':15 ''boat'':17 ''dentist'':12 ''georgia'':20 ''hellfight'':1 ''must'':14 ''reflect'':5 ''shark'':9 ''sierra'':2 ''soviet'':19 ''taut'':4');
INSERT INTO film VALUES (415, 'HIGH ENCINO', 'A Fateful Saga of a Waitress And a Hunter who must Outrace a Sumo Wrestler in Australia', 2006, 1, NULL, 3, 2.99, 84, 23.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''australia'':19 ''encino'':2 ''fate'':4 ''high'':1 ''hunter'':11 ''must'':13 ''outrac'':14 ''saga'':5 ''sumo'':16 ''waitress'':8 ''wrestler'':17');
INSERT INTO film VALUES (416, 'HIGHBALL POTTER', 'A Action-Packed Saga of a Husband And a Dog who must Redeem a Database Administrator in The Sahara Desert', 2006, 1, NULL, 6, 0.99, 110, 10.99, 'R', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''action'':5 ''action-pack'':4 ''administr'':19 ''databas'':18 ''desert'':23 ''dog'':13 ''highbal'':1 ''husband'':10 ''must'':15 ''pack'':6 ''potter'':2 ''redeem'':16 ''saga'':7 ''sahara'':22');
INSERT INTO film VALUES (417, 'HILLS NEIGHBORS', 'A Epic Display of a Hunter And a Feminist who must Sink a Car in A U-Boat', 2006, 1, NULL, 5, 0.99, 93, 29.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''boat'':21 ''car'':16 ''display'':5 ''epic'':4 ''feminist'':11 ''hill'':1 ''hunter'':8 ''must'':13 ''neighbor'':2 ''sink'':14 ''u'':20 ''u-boat'':19');
INSERT INTO film VALUES (418, 'HOBBIT ALIEN', 'A Emotional Drama of a Husband And a Girl who must Outgun a Composer in The First Manned Space Station', 2006, 1, NULL, 5, 0.99, 157, 27.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Commentaries}', '''alien'':2 ''compos'':16 ''drama'':5 ''emot'':4 ''first'':19 ''girl'':11 ''hobbit'':1 ''husband'':8 ''man'':20 ''must'':13 ''outgun'':14 ''space'':21 ''station'':22');
INSERT INTO film VALUES (419, 'HOCUS FRIDA', 'A Awe-Inspiring Tale of a Girl And a Madman who must Outgun a Student in A Shark Tank', 2006, 1, NULL, 4, 2.99, 141, 19.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''awe'':5 ''awe-inspir'':4 ''frida'':2 ''girl'':10 ''hocus'':1 ''inspir'':6 ''madman'':13 ''must'':15 ''outgun'':16 ''shark'':21 ''student'':18 ''tale'':7 ''tank'':22');
INSERT INTO film VALUES (420, 'HOLES BRANNIGAN', 'A Fast-Paced Reflection of a Technical Writer And a Student who must Fight a Boy in The Canadian Rockies', 2006, 1, NULL, 7, 4.99, 128, 27.99, 'PG', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''boy'':19 ''brannigan'':2 ''canadian'':22 ''fast'':5 ''fast-pac'':4 ''fight'':17 ''hole'':1 ''must'':16 ''pace'':6 ''reflect'':7 ''rocki'':23 ''student'':14 ''technic'':10 ''writer'':11');
INSERT INTO film VALUES (421, 'HOLIDAY GAMES', 'A Insightful Reflection of a Waitress And a Madman who must Pursue a Boy in Ancient Japan', 2006, 1, NULL, 7, 4.99, 78, 10.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''ancient'':18 ''boy'':16 ''game'':2 ''holiday'':1 ''insight'':4 ''japan'':19 ''madman'':11 ''must'':13 ''pursu'':14 ''reflect'':5 ''waitress'':8');
INSERT INTO film VALUES (422, 'HOLLOW JEOPARDY', 'A Beautiful Character Study of a Robot And a Astronaut who must Overcome a Boat in A Monastery', 2006, 1, NULL, 7, 4.99, 136, 25.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''astronaut'':12 ''beauti'':4 ''boat'':17 ''charact'':5 ''hollow'':1 ''jeopardi'':2 ''monasteri'':20 ''must'':14 ''overcom'':15 ''robot'':9 ''studi'':6');
INSERT INTO film VALUES (423, 'HOLLYWOOD ANONYMOUS', 'A Fast-Paced Epistle of a Boy And a Explorer who must Escape a Dog in A U-Boat', 2006, 1, NULL, 7, 0.99, 69, 29.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''anonym'':2 ''boat'':23 ''boy'':10 ''dog'':18 ''epistl'':7 ''escap'':16 ''explor'':13 ''fast'':5 ''fast-pac'':4 ''hollywood'':1 ''must'':15 ''pace'':6 ''u'':22 ''u-boat'':21');
INSERT INTO film VALUES (424, 'HOLOCAUST HIGHBALL', 'A Awe-Inspiring Yarn of a Composer And a Man who must Find a Robot in Soviet Georgia', 2006, 1, NULL, 6, 0.99, 149, 12.99, 'R', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''awe'':5 ''awe-inspir'':4 ''compos'':10 ''find'':16 ''georgia'':21 ''highbal'':2 ''holocaust'':1 ''inspir'':6 ''man'':13 ''must'':15 ''robot'':18 ''soviet'':20 ''yarn'':7');
INSERT INTO film VALUES (425, 'HOLY TADPOLE', 'A Action-Packed Display of a Feminist And a Pioneer who must Pursue a Dog in A Baloon Factory', 2006, 1, NULL, 6, 0.99, 88, 20.99, 'R', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''action'':5 ''action-pack'':4 ''baloon'':21 ''display'':7 ''dog'':18 ''factori'':22 ''feminist'':10 ''holi'':1 ''must'':15 ''pack'':6 ''pioneer'':13 ''pursu'':16 ''tadpol'':2');
INSERT INTO film VALUES (426, 'HOME PITY', 'A Touching Panorama of a Man And a Secret Agent who must Challenge a Teacher in A MySQL Convention', 2006, 1, NULL, 7, 4.99, 185, 15.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''agent'':12 ''challeng'':15 ''convent'':21 ''home'':1 ''man'':8 ''must'':14 ''mysql'':20 ''panorama'':5 ''piti'':2 ''secret'':11 ''teacher'':17 ''touch'':4');
INSERT INTO film VALUES (427, 'HOMEWARD CIDER', 'A Taut Reflection of a Astronaut And a Squirrel who must Fight a Squirrel in A Manhattan Penthouse', 2006, 1, NULL, 5, 0.99, 103, 19.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers}', '''astronaut'':8 ''cider'':2 ''fight'':14 ''homeward'':1 ''manhattan'':19 ''must'':13 ''penthous'':20 ''reflect'':5 ''squirrel'':11,16 ''taut'':4');
INSERT INTO film VALUES (428, 'HOMICIDE PEACH', 'A Astounding Documentary of a Hunter And a Boy who must Confront a Boy in A MySQL Convention', 2006, 1, NULL, 6, 2.99, 141, 21.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Commentaries}', '''astound'':4 ''boy'':11,16 ''confront'':14 ''convent'':20 ''documentari'':5 ''homicid'':1 ''hunter'':8 ''must'':13 ''mysql'':19 ''peach'':2');
INSERT INTO film VALUES (429, 'HONEY TIES', 'A Taut Story of a Waitress And a Crocodile who must Outrace a Lumberjack in A Shark Tank', 2006, 1, NULL, 3, 0.99, 84, 29.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''crocodil'':11 ''honey'':1 ''lumberjack'':16 ''must'':13 ''outrac'':14 ''shark'':19 ''stori'':5 ''tank'':20 ''taut'':4 ''tie'':2 ''waitress'':8');
INSERT INTO film VALUES (430, 'HOOK CHARIOTS', 'A Insightful Story of a Boy And a Dog who must Redeem a Boy in Australia', 2006, 1, NULL, 7, 0.99, 49, 23.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''australia'':18 ''boy'':8,16 ''chariot'':2 ''dog'':11 ''hook'':1 ''insight'':4 ''must'':13 ''redeem'':14 ''stori'':5');
INSERT INTO film VALUES (431, 'HOOSIERS BIRDCAGE', 'A Astounding Display of a Explorer And a Boat who must Vanquish a Car in The First Manned Space Station', 2006, 1, NULL, 3, 2.99, 176, 12.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''astound'':4 ''birdcag'':2 ''boat'':11 ''car'':16 ''display'':5 ''explor'':8 ''first'':19 ''hoosier'':1 ''man'':20 ''must'':13 ''space'':21 ''station'':22 ''vanquish'':14');
INSERT INTO film VALUES (432, 'HOPE TOOTSIE', 'A Amazing Documentary of a Student And a Sumo Wrestler who must Outgun a A Shark in A Shark Tank', 2006, 1, NULL, 4, 2.99, 139, 22.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''amaz'':4 ''documentari'':5 ''hope'':1 ''must'':14 ''outgun'':15 ''shark'':18,21 ''student'':8 ''sumo'':11 ''tank'':22 ''tootsi'':2 ''wrestler'':12');
INSERT INTO film VALUES (433, 'HORN WORKING', 'A Stunning Display of a Mad Scientist And a Technical Writer who must Succumb a Monkey in A Shark Tank', 2006, 1, NULL, 4, 2.99, 95, 23.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers}', '''display'':5 ''horn'':1 ''mad'':8 ''monkey'':18 ''must'':15 ''scientist'':9 ''shark'':21 ''stun'':4 ''succumb'':16 ''tank'':22 ''technic'':12 ''work'':2 ''writer'':13');
INSERT INTO film VALUES (434, 'HORROR REIGN', 'A Touching Documentary of a A Shark And a Car who must Build a Husband in Nigeria', 2006, 1, NULL, 3, 0.99, 139, 25.99, 'R', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''build'':15 ''car'':12 ''documentari'':5 ''horror'':1 ''husband'':17 ''must'':14 ''nigeria'':19 ''reign'':2 ''shark'':9 ''touch'':4');
INSERT INTO film VALUES (435, 'HOTEL HAPPINESS', 'A Thrilling Yarn of a Pastry Chef And a A Shark who must Challenge a Mad Scientist in The Outback', 2006, 1, NULL, 6, 4.99, 181, 28.99, 'PG-13', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''challeng'':16 ''chef'':9 ''happi'':2 ''hotel'':1 ''mad'':18 ''must'':15 ''outback'':22 ''pastri'':8 ''scientist'':19 ''shark'':13 ''thrill'':4 ''yarn'':5');
INSERT INTO film VALUES (436, 'HOURS RAGE', 'A Fateful Story of a Explorer And a Feminist who must Meet a Technical Writer in Soviet Georgia', 2006, 1, NULL, 4, 0.99, 122, 14.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''explor'':8 ''fate'':4 ''feminist'':11 ''georgia'':20 ''hour'':1 ''meet'':14 ''must'':13 ''rage'':2 ''soviet'':19 ''stori'':5 ''technic'':16 ''writer'':17');
INSERT INTO film VALUES (437, 'HOUSE DYNAMITE', 'A Taut Story of a Pioneer And a Squirrel who must Battle a Student in Soviet Georgia', 2006, 1, NULL, 7, 2.99, 109, 13.99, 'R', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''battl'':14 ''dynamit'':2 ''georgia'':19 ''hous'':1 ''must'':13 ''pioneer'':8 ''soviet'':18 ''squirrel'':11 ''stori'':5 ''student'':16 ''taut'':4');
INSERT INTO film VALUES (438, 'HUMAN GRAFFITI', 'A Beautiful Reflection of a Womanizer And a Sumo Wrestler who must Chase a Database Administrator in The Gulf of Mexico', 2006, 1, NULL, 3, 2.99, 68, 22.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''administr'':18 ''beauti'':4 ''chase'':15 ''databas'':17 ''graffiti'':2 ''gulf'':21 ''human'':1 ''mexico'':23 ''must'':14 ''reflect'':5 ''sumo'':11 ''woman'':8 ''wrestler'':12');
INSERT INTO film VALUES (439, 'HUNCHBACK IMPOSSIBLE', 'A Touching Yarn of a Frisbee And a Dentist who must Fight a Composer in Ancient Japan', 2006, 1, NULL, 4, 4.99, 151, 28.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''ancient'':18 ''compos'':16 ''dentist'':11 ''fight'':14 ''frisbe'':8 ''hunchback'':1 ''imposs'':2 ''japan'':19 ''must'':13 ''touch'':4 ''yarn'':5');
INSERT INTO film VALUES (440, 'HUNGER ROOF', 'A Unbelieveable Yarn of a Student And a Database Administrator who must Outgun a Husband in An Abandoned Mine Shaft', 2006, 1, NULL, 6, 0.99, 105, 21.99, 'G', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''abandon'':20 ''administr'':12 ''databas'':11 ''hunger'':1 ''husband'':17 ''mine'':21 ''must'':14 ''outgun'':15 ''roof'':2 ''shaft'':22 ''student'':8 ''unbeliev'':4 ''yarn'':5');
INSERT INTO film VALUES (441, 'HUNTER ALTER', 'A Emotional Drama of a Mad Cow And a Boat who must Redeem a Secret Agent in A Shark Tank', 2006, 1, NULL, 5, 2.99, 125, 21.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''agent'':18 ''alter'':2 ''boat'':12 ''cow'':9 ''drama'':5 ''emot'':4 ''hunter'':1 ''mad'':8 ''must'':14 ''redeem'':15 ''secret'':17 ''shark'':21 ''tank'':22');
INSERT INTO film VALUES (442, 'HUNTING MUSKETEERS', 'A Thrilling Reflection of a Pioneer And a Dentist who must Outrace a Womanizer in An Abandoned Mine Shaft', 2006, 1, NULL, 6, 2.99, 65, 24.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''abandon'':19 ''dentist'':11 ''hunt'':1 ''mine'':20 ''musket'':2 ''must'':13 ''outrac'':14 ''pioneer'':8 ''reflect'':5 ''shaft'':21 ''thrill'':4 ''woman'':16');
INSERT INTO film VALUES (443, 'HURRICANE AFFAIR', 'A Lacklusture Epistle of a Database Administrator And a Woman who must Meet a Hunter in An Abandoned Mine Shaft', 2006, 1, NULL, 6, 2.99, 49, 11.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''abandon'':20 ''administr'':9 ''affair'':2 ''databas'':8 ''epistl'':5 ''hunter'':17 ''hurrican'':1 ''lacklustur'':4 ''meet'':15 ''mine'':21 ''must'':14 ''shaft'':22 ''woman'':12');
INSERT INTO film VALUES (444, 'HUSTLER PARTY', 'A Emotional Reflection of a Sumo Wrestler And a Monkey who must Conquer a Robot in The Sahara Desert', 2006, 1, NULL, 3, 4.99, 83, 22.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''conquer'':15 ''desert'':21 ''emot'':4 ''hustler'':1 ''monkey'':12 ''must'':14 ''parti'':2 ''reflect'':5 ''robot'':17 ''sahara'':20 ''sumo'':8 ''wrestler'':9');
INSERT INTO film VALUES (445, 'HYDE DOCTOR', 'A Fanciful Documentary of a Boy And a Woman who must Redeem a Womanizer in A Jet Boat', 2006, 1, NULL, 5, 2.99, 100, 11.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''boat'':20 ''boy'':8 ''doctor'':2 ''documentari'':5 ''fanci'':4 ''hyde'':1 ''jet'':19 ''must'':13 ''redeem'':14 ''woman'':11,16');
INSERT INTO film VALUES (446, 'HYSTERICAL GRAIL', 'A Amazing Saga of a Madman And a Dentist who must Build a Car in A Manhattan Penthouse', 2006, 1, NULL, 5, 4.99, 150, 19.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''amaz'':4 ''build'':14 ''car'':16 ''dentist'':11 ''grail'':2 ''hyster'':1 ''madman'':8 ''manhattan'':19 ''must'':13 ''penthous'':20 ''saga'':5');
INSERT INTO film VALUES (447, 'ICE CROSSING', 'A Fast-Paced Tale of a Butler And a Moose who must Overcome a Pioneer in A Manhattan Penthouse', 2006, 1, NULL, 5, 2.99, 131, 28.99, 'R', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''butler'':10 ''cross'':2 ''fast'':5 ''fast-pac'':4 ''ice'':1 ''manhattan'':21 ''moos'':13 ''must'':15 ''overcom'':16 ''pace'':6 ''penthous'':22 ''pioneer'':18 ''tale'':7');
INSERT INTO film VALUES (448, 'IDAHO LOVE', 'A Fast-Paced Drama of a Student And a Crocodile who must Meet a Database Administrator in The Outback', 2006, 1, NULL, 3, 2.99, 172, 25.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''administr'':19 ''crocodil'':13 ''databas'':18 ''drama'':7 ''fast'':5 ''fast-pac'':4 ''idaho'':1 ''love'':2 ''meet'':16 ''must'':15 ''outback'':22 ''pace'':6 ''student'':10');
INSERT INTO film VALUES (449, 'IDENTITY LOVER', 'A Boring Tale of a Composer And a Mad Cow who must Defeat a Car in The Outback', 2006, 1, NULL, 4, 2.99, 119, 12.99, 'PG-13', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''bore'':4 ''car'':17 ''compos'':8 ''cow'':12 ''defeat'':15 ''ident'':1 ''lover'':2 ''mad'':11 ''must'':14 ''outback'':20 ''tale'':5');
INSERT INTO film VALUES (450, 'IDOLS SNATCHERS', 'A Insightful Drama of a Car And a Composer who must Fight a Man in A Monastery', 2006, 1, NULL, 5, 2.99, 84, 29.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers}', '''car'':8 ''compos'':11 ''drama'':5 ''fight'':14 ''idol'':1 ''insight'':4 ''man'':16 ''monasteri'':19 ''must'':13 ''snatcher'':2');
INSERT INTO film VALUES (451, 'IGBY MAKER', 'A Epic Documentary of a Hunter And a Dog who must Outgun a Dog in A Baloon Factory', 2006, 1, NULL, 7, 4.99, 160, 12.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''baloon'':19 ''documentari'':5 ''dog'':11,16 ''epic'':4 ''factori'':20 ''hunter'':8 ''igbi'':1 ''maker'':2 ''must'':13 ''outgun'':14');
INSERT INTO film VALUES (452, 'ILLUSION AMELIE', 'A Emotional Epistle of a Boat And a Mad Scientist who must Outrace a Robot in An Abandoned Mine Shaft', 2006, 1, NULL, 4, 0.99, 122, 15.99, 'R', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''abandon'':20 ''ameli'':2 ''boat'':8 ''emot'':4 ''epistl'':5 ''illus'':1 ''mad'':11 ''mine'':21 ''must'':14 ''outrac'':15 ''robot'':17 ''scientist'':12 ''shaft'':22');
INSERT INTO film VALUES (453, 'IMAGE PRINCESS', 'A Lacklusture Panorama of a Secret Agent And a Crocodile who must Discover a Madman in The Canadian Rockies', 2006, 1, NULL, 3, 2.99, 178, 17.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''agent'':9 ''canadian'':20 ''crocodil'':12 ''discov'':15 ''imag'':1 ''lacklustur'':4 ''madman'':17 ''must'':14 ''panorama'':5 ''princess'':2 ''rocki'':21 ''secret'':8');
INSERT INTO film VALUES (454, 'IMPACT ALADDIN', 'A Epic Character Study of a Frisbee And a Moose who must Outgun a Technical Writer in A Shark Tank', 2006, 1, NULL, 6, 0.99, 180, 20.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''aladdin'':2 ''charact'':5 ''epic'':4 ''frisbe'':9 ''impact'':1 ''moos'':12 ''must'':14 ''outgun'':15 ''shark'':21 ''studi'':6 ''tank'':22 ''technic'':17 ''writer'':18');
INSERT INTO film VALUES (455, 'IMPOSSIBLE PREJUDICE', 'A Awe-Inspiring Yarn of a Monkey And a Hunter who must Chase a Teacher in Ancient China', 2006, 1, NULL, 7, 4.99, 103, 11.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''ancient'':20 ''awe'':5 ''awe-inspir'':4 ''chase'':16 ''china'':21 ''hunter'':13 ''imposs'':1 ''inspir'':6 ''monkey'':10 ''must'':15 ''prejudic'':2 ''teacher'':18 ''yarn'':7');
INSERT INTO film VALUES (456, 'INCH JET', 'A Fateful Saga of a Womanizer And a Student who must Defeat a Butler in A Monastery', 2006, 1, NULL, 6, 4.99, 167, 18.99, 'NC-17', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''butler'':16 ''defeat'':14 ''fate'':4 ''inch'':1 ''jet'':2 ''monasteri'':19 ''must'':13 ''saga'':5 ''student'':11 ''woman'':8');
INSERT INTO film VALUES (457, 'INDEPENDENCE HOTEL', 'A Thrilling Tale of a Technical Writer And a Boy who must Face a Pioneer in A Monastery', 2006, 1, NULL, 5, 0.99, 157, 21.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''boy'':12 ''face'':15 ''hotel'':2 ''independ'':1 ''monasteri'':20 ''must'':14 ''pioneer'':17 ''tale'':5 ''technic'':8 ''thrill'':4 ''writer'':9');
INSERT INTO film VALUES (458, 'INDIAN LOVE', 'A Insightful Saga of a Mad Scientist And a Mad Scientist who must Kill a Astronaut in An Abandoned Fun House', 2006, 1, NULL, 4, 0.99, 135, 26.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''abandon'':21 ''astronaut'':18 ''fun'':22 ''hous'':23 ''indian'':1 ''insight'':4 ''kill'':16 ''love'':2 ''mad'':8,12 ''must'':15 ''saga'':5 ''scientist'':9,13');
INSERT INTO film VALUES (459, 'INFORMER DOUBLE', 'A Action-Packed Display of a Woman And a Dentist who must Redeem a Forensic Psychologist in The Canadian Rockies', 2006, 1, NULL, 4, 4.99, 74, 23.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''action'':5 ''action-pack'':4 ''canadian'':22 ''dentist'':13 ''display'':7 ''doubl'':2 ''forens'':18 ''inform'':1 ''must'':15 ''pack'':6 ''psychologist'':19 ''redeem'':16 ''rocki'':23 ''woman'':10');
INSERT INTO film VALUES (460, 'INNOCENT USUAL', 'A Beautiful Drama of a Pioneer And a Crocodile who must Challenge a Student in The Outback', 2006, 1, NULL, 3, 4.99, 178, 26.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''beauti'':4 ''challeng'':14 ''crocodil'':11 ''drama'':5 ''innoc'':1 ''must'':13 ''outback'':19 ''pioneer'':8 ''student'':16 ''usual'':2');
INSERT INTO film VALUES (461, 'INSECTS STONE', 'A Epic Display of a Butler And a Dog who must Vanquish a Crocodile in A Manhattan Penthouse', 2006, 1, NULL, 3, 0.99, 123, 14.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''butler'':8 ''crocodil'':16 ''display'':5 ''dog'':11 ''epic'':4 ''insect'':1 ''manhattan'':19 ''must'':13 ''penthous'':20 ''stone'':2 ''vanquish'':14');
INSERT INTO film VALUES (462, 'INSIDER ARIZONA', 'A Astounding Saga of a Mad Scientist And a Hunter who must Pursue a Robot in A Baloon Factory', 2006, 1, NULL, 5, 2.99, 78, 17.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries}', '''arizona'':2 ''astound'':4 ''baloon'':20 ''factori'':21 ''hunter'':12 ''insid'':1 ''mad'':8 ''must'':14 ''pursu'':15 ''robot'':17 ''saga'':5 ''scientist'':9');
INSERT INTO film VALUES (463, 'INSTINCT AIRPORT', 'A Touching Documentary of a Mad Cow And a Explorer who must Confront a Butler in A Manhattan Penthouse', 2006, 1, NULL, 4, 2.99, 116, 21.99, 'PG', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes"}', '''airport'':2 ''butler'':17 ''confront'':15 ''cow'':9 ''documentari'':5 ''explor'':12 ''instinct'':1 ''mad'':8 ''manhattan'':20 ''must'':14 ''penthous'':21 ''touch'':4');
INSERT INTO film VALUES (464, 'INTENTIONS EMPIRE', 'A Astounding Epistle of a Cat And a Cat who must Conquer a Mad Cow in A U-Boat', 2006, 1, NULL, 3, 2.99, 107, 13.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''astound'':4 ''boat'':22 ''cat'':8,11 ''conquer'':14 ''cow'':17 ''empir'':2 ''epistl'':5 ''intent'':1 ''mad'':16 ''must'':13 ''u'':21 ''u-boat'':20');
INSERT INTO film VALUES (465, 'INTERVIEW LIAISONS', 'A Action-Packed Reflection of a Student And a Butler who must Discover a Database Administrator in A Manhattan Penthouse', 2006, 1, NULL, 4, 4.99, 59, 17.99, 'R', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''action'':5 ''action-pack'':4 ''administr'':19 ''butler'':13 ''databas'':18 ''discov'':16 ''interview'':1 ''liaison'':2 ''manhattan'':22 ''must'':15 ''pack'':6 ''penthous'':23 ''reflect'':7 ''student'':10');
INSERT INTO film VALUES (466, 'INTOLERABLE INTENTIONS', 'A Awe-Inspiring Story of a Monkey And a Pastry Chef who must Succumb a Womanizer in A MySQL Convention', 2006, 1, NULL, 6, 4.99, 63, 20.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''awe'':5 ''awe-inspir'':4 ''chef'':14 ''convent'':23 ''inspir'':6 ''intent'':2 ''intoler'':1 ''monkey'':10 ''must'':16 ''mysql'':22 ''pastri'':13 ''stori'':7 ''succumb'':17 ''woman'':19');
INSERT INTO film VALUES (467, 'INTRIGUE WORST', 'A Fanciful Character Study of a Explorer And a Mad Scientist who must Vanquish a Squirrel in A Jet Boat', 2006, 1, NULL, 6, 0.99, 181, 10.99, 'G', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''boat'':22 ''charact'':5 ''explor'':9 ''fanci'':4 ''intrigu'':1 ''jet'':21 ''mad'':12 ''must'':15 ''scientist'':13 ''squirrel'':18 ''studi'':6 ''vanquish'':16 ''worst'':2');
INSERT INTO film VALUES (468, 'INVASION CYCLONE', 'A Lacklusture Character Study of a Mad Scientist And a Womanizer who must Outrace a Explorer in A Monastery', 2006, 1, NULL, 5, 2.99, 97, 12.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes"}', '''charact'':5 ''cyclon'':2 ''explor'':18 ''invas'':1 ''lacklustur'':4 ''mad'':9 ''monasteri'':21 ''must'':15 ''outrac'':16 ''scientist'':10 ''studi'':6 ''woman'':13');
INSERT INTO film VALUES (469, 'IRON MOON', 'A Fast-Paced Documentary of a Mad Cow And a Boy who must Pursue a Dentist in A Baloon', 2006, 1, NULL, 7, 4.99, 46, 27.99, 'PG', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''baloon'':22 ''boy'':14 ''cow'':11 ''dentist'':19 ''documentari'':7 ''fast'':5 ''fast-pac'':4 ''iron'':1 ''mad'':10 ''moon'':2 ''must'':16 ''pace'':6 ''pursu'':17');
INSERT INTO film VALUES (470, 'ISHTAR ROCKETEER', 'A Astounding Saga of a Dog And a Squirrel who must Conquer a Dog in An Abandoned Fun House', 2006, 1, NULL, 4, 4.99, 79, 24.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''abandon'':19 ''astound'':4 ''conquer'':14 ''dog'':8,16 ''fun'':20 ''hous'':21 ''ishtar'':1 ''must'':13 ''rocket'':2 ''saga'':5 ''squirrel'':11');
INSERT INTO film VALUES (471, 'ISLAND EXORCIST', 'A Fanciful Panorama of a Technical Writer And a Boy who must Find a Dentist in An Abandoned Fun House', 2006, 1, NULL, 7, 2.99, 84, 23.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''abandon'':20 ''boy'':12 ''dentist'':17 ''exorcist'':2 ''fanci'':4 ''find'':15 ''fun'':21 ''hous'':22 ''island'':1 ''must'':14 ''panorama'':5 ''technic'':8 ''writer'':9');
INSERT INTO film VALUES (472, 'ITALIAN AFRICAN', 'A Astounding Character Study of a Monkey And a Moose who must Outgun a Cat in A U-Boat', 2006, 1, NULL, 3, 4.99, 174, 24.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''african'':2 ''astound'':4 ''boat'':22 ''cat'':17 ''charact'':5 ''italian'':1 ''monkey'':9 ''moos'':12 ''must'':14 ''outgun'':15 ''studi'':6 ''u'':21 ''u-boat'':20');
INSERT INTO film VALUES (473, 'JACKET FRISCO', 'A Insightful Reflection of a Womanizer And a Husband who must Conquer a Pastry Chef in A Baloon', 2006, 1, NULL, 5, 2.99, 181, 16.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''baloon'':20 ''chef'':17 ''conquer'':14 ''frisco'':2 ''husband'':11 ''insight'':4 ''jacket'':1 ''must'':13 ''pastri'':16 ''reflect'':5 ''woman'':8');
INSERT INTO film VALUES (474, 'JADE BUNCH', 'A Insightful Panorama of a Squirrel And a Mad Cow who must Confront a Student in The First Manned Space Station', 2006, 1, NULL, 6, 2.99, 174, 21.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''bunch'':2 ''confront'':15 ''cow'':12 ''first'':20 ''insight'':4 ''jade'':1 ''mad'':11 ''man'':21 ''must'':14 ''panorama'':5 ''space'':22 ''squirrel'':8 ''station'':23 ''student'':17');
INSERT INTO film VALUES (475, 'JAPANESE RUN', 'A Awe-Inspiring Epistle of a Feminist And a Girl who must Sink a Girl in The Outback', 2006, 1, NULL, 6, 0.99, 135, 29.99, 'G', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''awe'':5 ''awe-inspir'':4 ''epistl'':7 ''feminist'':10 ''girl'':13,18 ''inspir'':6 ''japanes'':1 ''must'':15 ''outback'':21 ''run'':2 ''sink'':16');
INSERT INTO film VALUES (476, 'JASON TRAP', 'A Thoughtful Tale of a Woman And a A Shark who must Conquer a Dog in A Monastery', 2006, 1, NULL, 5, 2.99, 130, 9.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''conquer'':15 ''dog'':17 ''jason'':1 ''monasteri'':20 ''must'':14 ''shark'':12 ''tale'':5 ''thought'':4 ''trap'':2 ''woman'':8');
INSERT INTO film VALUES (477, 'JAWBREAKER BROOKLYN', 'A Stunning Reflection of a Boat And a Pastry Chef who must Succumb a A Shark in A Jet Boat', 2006, 1, NULL, 5, 0.99, 118, 15.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,"Behind the Scenes"}', '''boat'':8,22 ''brooklyn'':2 ''chef'':12 ''jawbreak'':1 ''jet'':21 ''must'':14 ''pastri'':11 ''reflect'':5 ''shark'':18 ''stun'':4 ''succumb'':15');
INSERT INTO film VALUES (478, 'JAWS HARRY', 'A Thrilling Display of a Database Administrator And a Monkey who must Overcome a Dog in An Abandoned Fun House', 2006, 1, NULL, 4, 2.99, 112, 10.99, 'G', '2007-09-10 17:46:03.905795', '{"Deleted Scenes"}', '''abandon'':20 ''administr'':9 ''databas'':8 ''display'':5 ''dog'':17 ''fun'':21 ''harri'':2 ''hous'':22 ''jaw'':1 ''monkey'':12 ''must'':14 ''overcom'':15 ''thrill'':4');
INSERT INTO film VALUES (479, 'JEDI BENEATH', 'A Astounding Reflection of a Explorer And a Dentist who must Pursue a Student in Nigeria', 2006, 1, NULL, 7, 0.99, 128, 12.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''astound'':4 ''beneath'':2 ''dentist'':11 ''explor'':8 ''jedi'':1 ''must'':13 ''nigeria'':18 ''pursu'':14 ''reflect'':5 ''student'':16');
INSERT INTO film VALUES (480, 'JEEPERS WEDDING', 'A Astounding Display of a Composer And a Dog who must Kill a Pastry Chef in Soviet Georgia', 2006, 1, NULL, 3, 2.99, 84, 29.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''astound'':4 ''chef'':17 ''compos'':8 ''display'':5 ''dog'':11 ''georgia'':20 ''jeeper'':1 ''kill'':14 ''must'':13 ''pastri'':16 ''soviet'':19 ''wed'':2');
INSERT INTO film VALUES (481, 'JEKYLL FROGMEN', 'A Fanciful Epistle of a Student And a Astronaut who must Kill a Waitress in A Shark Tank', 2006, 1, NULL, 4, 2.99, 58, 22.99, 'PG', '2007-09-10 17:46:03.905795', '{Commentaries,"Deleted Scenes","Behind the Scenes"}', '''astronaut'':11 ''epistl'':5 ''fanci'':4 ''frogmen'':2 ''jekyl'':1 ''kill'':14 ''must'':13 ''shark'':19 ''student'':8 ''tank'':20 ''waitress'':16');
INSERT INTO film VALUES (482, 'JEOPARDY ENCINO', 'A Boring Panorama of a Man And a Mad Cow who must Face a Explorer in Ancient India', 2006, 1, NULL, 3, 0.99, 102, 12.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''ancient'':19 ''bore'':4 ''cow'':12 ''encino'':2 ''explor'':17 ''face'':15 ''india'':20 ''jeopardi'':1 ''mad'':11 ''man'':8 ''must'':14 ''panorama'':5');
INSERT INTO film VALUES (483, 'JERICHO MULAN', 'A Amazing Yarn of a Hunter And a Butler who must Defeat a Boy in A Jet Boat', 2006, 1, NULL, 3, 2.99, 171, 29.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries}', '''amaz'':4 ''boat'':20 ''boy'':16 ''butler'':11 ''defeat'':14 ''hunter'':8 ''jericho'':1 ''jet'':19 ''mulan'':2 ''must'':13 ''yarn'':5');
INSERT INTO film VALUES (484, 'JERK PAYCHECK', 'A Touching Character Study of a Pastry Chef And a Database Administrator who must Reach a A Shark in Ancient Japan', 2006, 1, NULL, 3, 2.99, 172, 13.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''administr'':14 ''ancient'':22 ''charact'':5 ''chef'':10 ''databas'':13 ''japan'':23 ''jerk'':1 ''must'':16 ''pastri'':9 ''paycheck'':2 ''reach'':17 ''shark'':20 ''studi'':6 ''touch'':4');
INSERT INTO film VALUES (485, 'JERSEY SASSY', 'A Lacklusture Documentary of a Madman And a Mad Cow who must Find a Feminist in Ancient Japan', 2006, 1, NULL, 6, 4.99, 60, 16.99, 'PG', '2007-09-10 17:46:03.905795', '{"Deleted Scenes","Behind the Scenes"}', '''ancient'':19 ''cow'':12 ''documentari'':5 ''feminist'':17 ''find'':15 ''japan'':20 ''jersey'':1 ''lacklustur'':4 ''mad'':11 ''madman'':8 ''must'':14 ''sassi'':2');
INSERT INTO film VALUES (486, 'JET NEIGHBORS', 'A Amazing Display of a Lumberjack And a Teacher who must Outrace a Woman in A U-Boat', 2006, 1, NULL, 7, 4.99, 59, 14.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''amaz'':4 ''boat'':21 ''display'':5 ''jet'':1 ''lumberjack'':8 ''must'':13 ''neighbor'':2 ''outrac'':14 ''teacher'':11 ''u'':20 ''u-boat'':19 ''woman'':16');
INSERT INTO film VALUES (487, 'JINGLE SAGEBRUSH', 'A Epic Character Study of a Feminist And a Student who must Meet a Woman in A Baloon', 2006, 1, NULL, 6, 4.99, 124, 29.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''baloon'':20 ''charact'':5 ''epic'':4 ''feminist'':9 ''jingl'':1 ''meet'':15 ''must'':14 ''sagebrush'':2 ''student'':12 ''studi'':6 ''woman'':17');
INSERT INTO film VALUES (488, 'JOON NORTHWEST', 'A Thrilling Panorama of a Technical Writer And a Car who must Discover a Forensic Psychologist in A Shark Tank', 2006, 1, NULL, 3, 0.99, 105, 23.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''car'':12 ''discov'':15 ''forens'':17 ''joon'':1 ''must'':14 ''northwest'':2 ''panorama'':5 ''psychologist'':18 ''shark'':21 ''tank'':22 ''technic'':8 ''thrill'':4 ''writer'':9');
INSERT INTO film VALUES (489, 'JUGGLER HARDLY', 'A Epic Story of a Mad Cow And a Astronaut who must Challenge a Car in California', 2006, 1, NULL, 4, 0.99, 54, 14.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''astronaut'':12 ''california'':19 ''car'':17 ''challeng'':15 ''cow'':9 ''epic'':4 ''hard'':2 ''juggler'':1 ''mad'':8 ''must'':14 ''stori'':5');
INSERT INTO film VALUES (490, 'JUMANJI BLADE', 'A Intrepid Yarn of a Husband And a Womanizer who must Pursue a Mad Scientist in New Orleans', 2006, 1, NULL, 4, 2.99, 121, 13.99, 'G', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''blade'':2 ''husband'':8 ''intrepid'':4 ''jumanji'':1 ''mad'':16 ''must'':13 ''new'':19 ''orlean'':20 ''pursu'':14 ''scientist'':17 ''woman'':11 ''yarn'':5');
INSERT INTO film VALUES (491, 'JUMPING WRATH', 'A Touching Epistle of a Monkey And a Feminist who must Discover a Boat in Berlin', 2006, 1, NULL, 4, 0.99, 74, 18.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Commentaries,"Behind the Scenes"}', '''berlin'':18 ''boat'':16 ''discov'':14 ''epistl'':5 ''feminist'':11 ''jump'':1 ''monkey'':8 ''must'':13 ''touch'':4 ''wrath'':2');
INSERT INTO film VALUES (492, 'JUNGLE CLOSER', 'A Boring Character Study of a Boy And a Woman who must Battle a Astronaut in Australia', 2006, 1, NULL, 6, 0.99, 134, 11.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''astronaut'':17 ''australia'':19 ''battl'':15 ''bore'':4 ''boy'':9 ''charact'':5 ''closer'':2 ''jungl'':1 ''must'':14 ''studi'':6 ''woman'':12');
INSERT INTO film VALUES (493, 'KANE EXORCIST', 'A Epic Documentary of a Composer And a Robot who must Overcome a Car in Berlin', 2006, 1, NULL, 5, 0.99, 92, 18.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''berlin'':18 ''car'':16 ''compos'':8 ''documentari'':5 ''epic'':4 ''exorcist'':2 ''kane'':1 ''must'':13 ''overcom'':14 ''robot'':11');
INSERT INTO film VALUES (494, 'KARATE MOON', 'A Astounding Yarn of a Womanizer And a Dog who must Reach a Waitress in A MySQL Convention', 2006, 1, NULL, 4, 0.99, 120, 21.99, 'PG-13', '2007-09-10 17:46:03.905795', '{"Behind the Scenes"}', '''astound'':4 ''convent'':20 ''dog'':11 ''karat'':1 ''moon'':2 ''must'':13 ''mysql'':19 ''reach'':14 ''waitress'':16 ''woman'':8 ''yarn'':5');
INSERT INTO film VALUES (495, 'KENTUCKIAN GIANT', 'A Stunning Yarn of a Woman And a Frisbee who must Escape a Waitress in A U-Boat', 2006, 1, NULL, 5, 2.99, 169, 10.99, 'PG', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes","Behind the Scenes"}', '''boat'':21 ''escap'':14 ''frisbe'':11 ''giant'':2 ''kentuckian'':1 ''must'':13 ''stun'':4 ''u'':20 ''u-boat'':19 ''waitress'':16 ''woman'':8 ''yarn'':5');
INSERT INTO film VALUES (496, 'KICK SAVANNAH', 'A Emotional Drama of a Monkey And a Robot who must Defeat a Monkey in New Orleans', 2006, 1, NULL, 3, 0.99, 179, 10.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''defeat'':14 ''drama'':5 ''emot'':4 ''kick'':1 ''monkey'':8,16 ''must'':13 ''new'':18 ''orlean'':19 ''robot'':11 ''savannah'':2');
INSERT INTO film VALUES (497, 'KILL BROTHERHOOD', 'A Touching Display of a Hunter And a Secret Agent who must Redeem a Husband in The Outback', 2006, 1, NULL, 4, 0.99, 54, 15.99, 'G', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries}', '''agent'':12 ''brotherhood'':2 ''display'':5 ''hunter'':8 ''husband'':17 ''kill'':1 ''must'':14 ''outback'':20 ''redeem'':15 ''secret'':11 ''touch'':4');
INSERT INTO film VALUES (498, 'KILLER INNOCENT', 'A Fanciful Character Study of a Student And a Explorer who must Succumb a Composer in An Abandoned Mine Shaft', 2006, 1, NULL, 7, 2.99, 161, 11.99, 'R', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Deleted Scenes"}', '''abandon'':20 ''charact'':5 ''compos'':17 ''explor'':12 ''fanci'':4 ''innoc'':2 ''killer'':1 ''mine'':21 ''must'':14 ''shaft'':22 ''student'':9 ''studi'':6 ''succumb'':15');
INSERT INTO film VALUES (499, 'KING EVOLUTION', 'A Action-Packed Tale of a Boy And a Lumberjack who must Chase a Madman in A Baloon', 2006, 1, NULL, 3, 4.99, 184, 24.99, 'NC-17', '2007-09-10 17:46:03.905795', '{Trailers,"Deleted Scenes","Behind the Scenes"}', '''action'':5 ''action-pack'':4 ''baloon'':21 ''boy'':10 ''chase'':16 ''evolut'':2 ''king'':1 ''lumberjack'':13 ''madman'':18 ''must'':15 ''pack'':6 ''tale'':7');
INSERT INTO film VALUES (500, 'KISS GLORY', 'A Lacklusture Reflection of a Girl And a Husband who must Find a Robot in The Canadian Rockies', 2006, 1, NULL, 5, 4.99, 163, 11.99, 'PG-13', '2007-09-10 17:46:03.905795', '{Trailers,Commentaries,"Behind the Scenes"}', '''canadian'':19 ''find'':14 ''girl'':8 ''glori'':2 ''husband'':11 ''kiss'':1 ''lacklustur'':4 ''must'':13 ''reflect'':5 ''robot'':16 ''rocki'':20');

ALTER TABLE film ENABLE TRIGGER ALL;


--
-- Data for Name: customer; Type: TABLE DATA; Schema: public;
--

ALTER TABLE customer DISABLE TRIGGER ALL;



ALTER TABLE customer ENABLE TRIGGER ALL;


--
-- Data for Name: film_actor; Type: TABLE DATA; Schema: public;
--

ALTER TABLE film_actor DISABLE TRIGGER ALL;



ALTER TABLE film_actor ENABLE TRIGGER ALL;

--
-- Data for Name: film_category; Type: TABLE DATA; Schema: public;
--

ALTER TABLE film_category DISABLE TRIGGER ALL;



ALTER TABLE film_category ENABLE TRIGGER ALL;

--
-- Data for Name: inventory; Type: TABLE DATA; Schema: public;
--

ALTER TABLE inventory DISABLE TRIGGER ALL;



ALTER TABLE inventory ENABLE TRIGGER ALL;

--
-- Data for Name: language; Type: TABLE DATA; Schema: public;
--

ALTER TABLE language DISABLE TRIGGER ALL;



ALTER TABLE language ENABLE TRIGGER ALL;

--
-- Data for Name: payment; Type: TABLE DATA; Schema: public;
--

ALTER TABLE payment DISABLE TRIGGER ALL;



ALTER TABLE payment ENABLE TRIGGER ALL;

--
-- Data for Name: payment_p2007_01; Type: TABLE DATA; Schema: public;
--

ALTER TABLE payment_p2007_01 DISABLE TRIGGER ALL;



ALTER TABLE payment_p2007_01 ENABLE TRIGGER ALL;

--
-- Data for Name: payment_p2007_02; Type: TABLE DATA; Schema: public;
--

ALTER TABLE payment_p2007_02 DISABLE TRIGGER ALL;



ALTER TABLE payment_p2007_02 ENABLE TRIGGER ALL;

--
-- Data for Name: payment_p2007_03; Type: TABLE DATA; Schema: public;
--

ALTER TABLE payment_p2007_03 DISABLE TRIGGER ALL;



ALTER TABLE payment_p2007_03 ENABLE TRIGGER ALL;

--
-- Data for Name: payment_p2007_04; Type: TABLE DATA; Schema: public;
--

ALTER TABLE payment_p2007_04 DISABLE TRIGGER ALL;



ALTER TABLE payment_p2007_04 ENABLE TRIGGER ALL;

--
-- Data for Name: payment_p2007_05; Type: TABLE DATA; Schema: public;
--

ALTER TABLE payment_p2007_05 DISABLE TRIGGER ALL;



ALTER TABLE payment_p2007_05 ENABLE TRIGGER ALL;

--
-- Data for Name: payment_p2007_06; Type: TABLE DATA; Schema: public;
--

ALTER TABLE payment_p2007_06 DISABLE TRIGGER ALL;



ALTER TABLE payment_p2007_06 ENABLE TRIGGER ALL;

--
-- Data for Name: rental; Type: TABLE DATA; Schema: public;
--

ALTER TABLE rental DISABLE TRIGGER ALL;



ALTER TABLE rental ENABLE TRIGGER ALL;

--
-- Data for Name: staff; Type: TABLE DATA; Schema: public;
--

ALTER TABLE staff DISABLE TRIGGER ALL;



ALTER TABLE staff ENABLE TRIGGER ALL;

--
-- Data for Name: store; Type: TABLE DATA; Schema: public;
--

ALTER TABLE store DISABLE TRIGGER ALL;



ALTER TABLE store ENABLE TRIGGER ALL;

--
-- PostgreSQL database dump complete
--

