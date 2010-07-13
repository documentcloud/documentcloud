--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: remote_urls; Type: TABLE; Schema: public; Owner: documentcloud; Tablespace: 
--

DROP TABLE IF EXISTS remote_urls;
CREATE TABLE remote_urls (
    id integer NOT NULL,
    document_id integer NOT NULL,
    url character varying(255) NOT NULL,
    hits integer DEFAULT 0 NOT NULL,
    date_recorded date NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.remote_urls OWNER TO documentcloud;

--
-- Name: remote_urls_id_seq; Type: SEQUENCE; Schema: public; Owner: documentcloud
--
DROP SEQUENCE IF EXISTS remote_urls_id_seq;
CREATE SEQUENCE remote_urls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.remote_urls_id_seq OWNER TO documentcloud;

--
-- Name: remote_urls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documentcloud
--

ALTER SEQUENCE remote_urls_id_seq OWNED BY remote_urls.id;


--
-- Name: remote_urls_id_seq; Type: SEQUENCE SET; Schema: public; Owner: documentcloud
--

SELECT pg_catalog.setval('remote_urls_id_seq', 1, false);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: documentcloud
--

ALTER TABLE remote_urls ALTER COLUMN id SET DEFAULT nextval('remote_urls_id_seq'::regclass);


--
-- Data for Name: remote_urls; Type: TABLE DATA; Schema: public; Owner: documentcloud
--

COPY remote_urls (id, document_id, url, hits, date_recorded, created_at, updated_at) FROM stdin;
\.


--
-- Name: remote_urls_pkey; Type: CONSTRAINT; Schema: public; Owner: documentcloud; Tablespace: 
--

ALTER TABLE ONLY remote_urls
    ADD CONSTRAINT remote_urls_pkey PRIMARY KEY (id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

