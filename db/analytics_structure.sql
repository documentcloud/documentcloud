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
-- Name: remote_urls; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE remote_urls (
    id integer NOT NULL,
    document_id integer,
    url character varying(255) NOT NULL,
    hits integer DEFAULT 0 NOT NULL,
    date_recorded date NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    note_id integer,
    search_query character varying(255),
    page_number integer
);


--
-- Name: remote_urls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE remote_urls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: remote_urls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE remote_urls_id_seq OWNED BY remote_urls.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY remote_urls ALTER COLUMN id SET DEFAULT nextval('remote_urls_id_seq'::regclass);


--
-- Name: remote_urls_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY remote_urls
    ADD CONSTRAINT remote_urls_pkey PRIMARY KEY (id);


--
-- Name: remote_urls_indx_document_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX remote_urls_indx_document_id ON remote_urls USING btree (document_id);


--
-- Name: remote_urls_indx_url; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX remote_urls_indx_url ON remote_urls USING btree (url);


--
-- Name: remote_urls_indx_url_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX remote_urls_indx_url_date ON remote_urls USING btree (url, date_recorded);


--
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

