CREATE TABLE account_current
(
  customer_id integer NOT NULL,
  customer_name character varying,
  balance numeric,
  CONSTRAINT account_current_pkey PRIMARY KEY (customer_id)
);


CREATE TABLE account_savings
(
customer_id integer NOT NULL,
customer_name character varying,
balance numeric,
CONSTRAINT account_savings_pkey PRIMARY KEY (customer_id)
);

CREATE TABLE log
(
log_id serial NOT NULL,
log_time time with time zone,
description character varying,
CONSTRAINT log_pkey PRIMARY KEY (log_id)
);


------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION add_log_trigg_function()
  RETURNS trigger AS
$BODY$
DECLARE
    account_type varchar;
BEGIN
    IF (TG_TABLE_NAME = 'account_current') THEN
        account_type := 'Current';
        RAISE NOTICE 'TRIGER called on %', TG_TABLE_NAME;

    ELSIF (TG_TABLE_NAME = 'account_savings') THEN
        account_type := 'Savings';
        RAISE NOTICE 'TRIGER called on %', TG_TABLE_NAME;

    END	 IF;

    RETURN null;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION add_log_trigg_function()
  OWNER TO postgres;
---------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION add_log_trigg_function()
  RETURNS trigger AS
$BODY$
DECLARE
    account_type varchar;
BEGIN
    IF (TG_TABLE_NAME = 'account_current') THEN
        account_type := 'Current';
        RAISE NOTICE 'TRIGER called on %', TG_TABLE_NAME;

    ELSIF (TG_TABLE_NAME = 'account_savings') THEN
        account_type := 'Savings';
        RAISE NOTICE 'TRIGER called on %', TG_TABLE_NAME;

    END IF;

    IF (TG_OP = 'INSERT') THEN
        INSERT INTO log(
                log_time,
                description)
            VALUES(
                now(),
                'New customer added. Account type: ' || account_type || ', Customer ID: ' || NEW.customer_id || ', Name: ' || NEW.customer_name || ', Balance: ' || NEW.balance);
        RETURN NEW;
    END IF;

    RETURN null;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  ------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION add_log_trigg_function()
  RETURNS trigger AS
$BODY$
DECLARE
    account_type varchar;
BEGIN
    IF (TG_TABLE_NAME = 'account_current') THEN
        account_type := 'Current';
        RAISE NOTICE 'TRIGER called on %', TG_TABLE_NAME;

    ELSIF (TG_TABLE_NAME = 'account_savings') THEN
        account_type := 'Savings';
        RAISE NOTICE 'TRIGER called on %', TG_TABLE_NAME;

    END IF;

    IF (TG_OP = 'INSERT') THEN
        INSERT INTO log(
                log_time,
                description)
            VALUES(
                now(),
                'New customer added. Account type: ' || account_type || ', Customer ID: ' || NEW.customer_id || ', Name: ' || NEW.customer_name || ', Balance: ' || NEW.balance);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        IF (NEW.balance < 0) THEN
            RAISE EXCEPTION 'Can''t withdraw the amount because of low balance! Available balance: %, Requested amount: %', OLD.balance, OLD.balance + (- NEW.balance);
        END IF;
        IF NEW.balance != OLD.balance THEN
            EXECUTE 'INSERT INTO log(log_time,description) VALUES(now(), ''Balance updated. Account type: ' || account_type || ', Customer ID: '' || $1.customer_id || ''. Old balance: '' || $2.balance || '', New balance: '' || $1.balance)' USING NEW, OLD;
        END IF;
        RETURN NEW;

    ELSIF (TG_OP = 'DELETE') THEN
            INSERT INTO log(
                log_time,
                description)
            VALUES(
                now(),
                'Account deleted. Account type: ' || account_type || ', Customer ID: ' || OLD.customer_id);
            RETURN OLD;

    END IF;

    RETURN null;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

  ---------------------------------------------------------------------------------------------------------------------------

CREATE TRIGGER add_log_current_trigger
BEFORE INSERT OR UPDATE OR DELETE
ON account_current
FOR EACH ROW
EXECUTE PROCEDURE add_log_trigg_function();

CREATE TRIGGER add_log_savings_trigger
BEFORE INSERT OR UPDATE OR DELETE
ON account_savings
FOR EACH ROW
EXECUTE PROCEDURE add_log_trigg_function();

-------------------------------------------------------------------------------------------------------------------

SELECT nationality, COUNT(book_id),
       SUM(IF(year < 1950, 1, 0)) AS'<1950',
       SUM(IF(year >= 1950ANDyear < 1990, 1, 0)) AS'<1990',
       SUM(IF(year >= 1990ANDyear < 2000, 1, 0)) AS'<2000',
       SUM(IF(year >= 2000, 1, 0)) AS'< HOY'
FROM books AS B
JOIN authorsAS A
ON A.author_id = B.author_id
WHERE A.nationality IS NOT NULL
GROUPBY A.nationality




TRUNCATE costo_turno RESTART IDENTITY;
SELECT cost_turn (30,1,5,0,97,95000,7118);
