--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: dcloud_crowd_development; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE dcloud_crowd_development WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


\connect dcloud_crowd_development

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: black_listed_actions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE black_listed_actions (
    id integer NOT NULL,
    action character varying NOT NULL,
    created_at timestamp without time zone
);


--
-- Name: black_listed_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE black_listed_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: black_listed_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE black_listed_actions_id_seq OWNED BY black_listed_actions.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE jobs (
    id integer NOT NULL,
    status integer NOT NULL,
    inputs text NOT NULL,
    action character varying NOT NULL,
    options text NOT NULL,
    outputs text,
    "time" double precision,
    callback_url character varying,
    email character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE jobs_id_seq OWNED BY jobs.id;


--
-- Name: node_records; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE node_records (
    id integer NOT NULL,
    host character varying NOT NULL,
    ip_address character varying NOT NULL,
    port integer NOT NULL,
    enabled_actions text DEFAULT ''::text NOT NULL,
    busy boolean DEFAULT false NOT NULL,
    tag character varying,
    max_workers integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: node_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE node_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: node_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE node_records_id_seq OWNED BY node_records.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: work_units; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE work_units (
    id integer NOT NULL,
    status integer NOT NULL,
    job_id integer NOT NULL,
    input text NOT NULL,
    action character varying NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    node_record_id integer,
    worker_pid integer,
    reservation integer,
    "time" double precision,
    output text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: work_units_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE work_units_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: work_units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE work_units_id_seq OWNED BY work_units.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY black_listed_actions ALTER COLUMN id SET DEFAULT nextval('black_listed_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs ALTER COLUMN id SET DEFAULT nextval('jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY node_records ALTER COLUMN id SET DEFAULT nextval('node_records_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY work_units ALTER COLUMN id SET DEFAULT nextval('work_units_id_seq'::regclass);


--
-- Name: black_listed_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY black_listed_actions
    ADD CONSTRAINT black_listed_actions_pkey PRIMARY KEY (id);


--
-- Name: jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: node_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY node_records
    ADD CONSTRAINT node_records_pkey PRIMARY KEY (id);


--
-- Name: work_units_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY work_units
    ADD CONSTRAINT work_units_pkey PRIMARY KEY (id);


--
-- Name: index_jobs_on_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_jobs_on_status ON jobs USING btree (status);


--
-- Name: index_work_units_on_job_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_work_units_on_job_id ON work_units USING btree (job_id);


--
-- Name: index_work_units_on_worker_pid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_work_units_on_worker_pid ON work_units USING btree (worker_pid);


--
-- Name: index_work_units_on_worker_pid_and_node_record_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_work_units_on_worker_pid_and_node_record_id ON work_units USING btree (worker_pid, node_record_id);


--
-- Name: index_work_units_on_worker_pid_and_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_work_units_on_worker_pid_and_status ON work_units USING btree (worker_pid, status);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM ted;
GRANT ALL ON SCHEMA public TO ted;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: documentcloud
--

COPY schema_migrations (version) FROM stdin;
5
1
\.


--
-- PostgreSQL database dump complete
--

