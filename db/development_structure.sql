--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: ghstore; Type: SHELL TYPE; Schema: public; Owner: postgres
--

CREATE TYPE ghstore;


--
-- Name: ghstore_in(cstring); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ghstore_in(cstring) RETURNS ghstore
    LANGUAGE c STRICT
    AS '$libdir/hstore', 'ghstore_in';


ALTER FUNCTION public.ghstore_in(cstring) OWNER TO postgres;

--
-- Name: ghstore_out(ghstore); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ghstore_out(ghstore) RETURNS cstring
    LANGUAGE c STRICT
    AS '$libdir/hstore', 'ghstore_out';


ALTER FUNCTION public.ghstore_out(ghstore) OWNER TO postgres;

--
-- Name: ghstore; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE ghstore (
    INTERNALLENGTH = variable,
    INPUT = ghstore_in,
    OUTPUT = ghstore_out,
    ALIGNMENT = int4,
    STORAGE = plain
);


ALTER TYPE public.ghstore OWNER TO postgres;

--
-- Name: hstore; Type: SHELL TYPE; Schema: public; Owner: postgres
--

CREATE TYPE hstore;


--
-- Name: hstore_in(cstring); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION hstore_in(cstring) RETURNS hstore
    LANGUAGE c STRICT
    AS '$libdir/hstore', 'hstore_in';


ALTER FUNCTION public.hstore_in(cstring) OWNER TO postgres;

--
-- Name: hstore_out(hstore); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION hstore_out(hstore) RETURNS cstring
    LANGUAGE c STRICT
    AS '$libdir/hstore', 'hstore_out';


ALTER FUNCTION public.hstore_out(hstore) OWNER TO postgres;

--
-- Name: hstore; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE hstore (
    INTERNALLENGTH = variable,
    INPUT = hstore_in,
    OUTPUT = hstore_out,
    ALIGNMENT = int4,
    STORAGE = extended
);


ALTER TYPE public.hstore OWNER TO postgres;

--
-- Name: akeys(hstore); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION akeys(hstore) RETURNS text[]
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'akeys';


ALTER FUNCTION public.akeys(hstore) OWNER TO postgres;

--
-- Name: avals(hstore); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION avals(hstore) RETURNS text[]
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'avals';


ALTER FUNCTION public.avals(hstore) OWNER TO postgres;

--
-- Name: defined(hstore, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION defined(hstore, text) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'defined';


ALTER FUNCTION public.defined(hstore, text) OWNER TO postgres;

--
-- Name: delete(hstore, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION delete(hstore, text) RETURNS hstore
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'delete';


ALTER FUNCTION public.delete(hstore, text) OWNER TO postgres;

--
-- Name: each(hstore); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION each(hs hstore, OUT key text, OUT value text) RETURNS SETOF record
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'each';


ALTER FUNCTION public.each(hs hstore, OUT key text, OUT value text) OWNER TO postgres;

--
-- Name: exist(hstore, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION exist(hstore, text) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'exists';


ALTER FUNCTION public.exist(hstore, text) OWNER TO postgres;

--
-- Name: fetchval(hstore, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fetchval(hstore, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'fetchval';


ALTER FUNCTION public.fetchval(hstore, text) OWNER TO postgres;

--
-- Name: ghstore_compress(internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ghstore_compress(internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'ghstore_compress';


ALTER FUNCTION public.ghstore_compress(internal) OWNER TO postgres;

--
-- Name: ghstore_consistent(internal, internal, integer, oid, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ghstore_consistent(internal, internal, integer, oid, internal) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'ghstore_consistent';


ALTER FUNCTION public.ghstore_consistent(internal, internal, integer, oid, internal) OWNER TO postgres;

--
-- Name: ghstore_decompress(internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ghstore_decompress(internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'ghstore_decompress';


ALTER FUNCTION public.ghstore_decompress(internal) OWNER TO postgres;

--
-- Name: ghstore_penalty(internal, internal, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ghstore_penalty(internal, internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'ghstore_penalty';


ALTER FUNCTION public.ghstore_penalty(internal, internal, internal) OWNER TO postgres;

--
-- Name: ghstore_picksplit(internal, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ghstore_picksplit(internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'ghstore_picksplit';


ALTER FUNCTION public.ghstore_picksplit(internal, internal) OWNER TO postgres;

--
-- Name: ghstore_same(internal, internal, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ghstore_same(internal, internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'ghstore_same';


ALTER FUNCTION public.ghstore_same(internal, internal, internal) OWNER TO postgres;

--
-- Name: ghstore_union(internal, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ghstore_union(internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'ghstore_union';


ALTER FUNCTION public.ghstore_union(internal, internal) OWNER TO postgres;

--
-- Name: gin_consistent_hstore(internal, smallint, internal, integer, internal, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gin_consistent_hstore(internal, smallint, internal, integer, internal, internal) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'gin_consistent_hstore';


ALTER FUNCTION public.gin_consistent_hstore(internal, smallint, internal, integer, internal, internal) OWNER TO postgres;

--
-- Name: gin_extract_hstore(internal, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gin_extract_hstore(internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'gin_extract_hstore';


ALTER FUNCTION public.gin_extract_hstore(internal, internal) OWNER TO postgres;

--
-- Name: gin_extract_hstore_query(internal, internal, smallint, internal, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gin_extract_hstore_query(internal, internal, smallint, internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'gin_extract_hstore_query';


ALTER FUNCTION public.gin_extract_hstore_query(internal, internal, smallint, internal, internal) OWNER TO postgres;

--
-- Name: hs_concat(hstore, hstore); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION hs_concat(hstore, hstore) RETURNS hstore
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hs_concat';


ALTER FUNCTION public.hs_concat(hstore, hstore) OWNER TO postgres;

--
-- Name: hs_contained(hstore, hstore); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION hs_contained(hstore, hstore) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hs_contained';


ALTER FUNCTION public.hs_contained(hstore, hstore) OWNER TO postgres;

--
-- Name: hs_contains(hstore, hstore); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION hs_contains(hstore, hstore) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hs_contains';


ALTER FUNCTION public.hs_contains(hstore, hstore) OWNER TO postgres;

--
-- Name: hstore(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION hstore(text, text) RETURNS hstore
    LANGUAGE c IMMUTABLE
    AS '$libdir/hstore', 'tconvert';


ALTER FUNCTION public.hstore(text, text) OWNER TO postgres;

--
-- Name: isdefined(hstore, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION isdefined(hstore, text) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'defined';


ALTER FUNCTION public.isdefined(hstore, text) OWNER TO postgres;

--
-- Name: isexists(hstore, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION isexists(hstore, text) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'exists';


ALTER FUNCTION public.isexists(hstore, text) OWNER TO postgres;

--
-- Name: skeys(hstore); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION skeys(hstore) RETURNS SETOF text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'skeys';


ALTER FUNCTION public.skeys(hstore) OWNER TO postgres;

--
-- Name: svals(hstore); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION svals(hstore) RETURNS SETOF text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'svals';


ALTER FUNCTION public.svals(hstore) OWNER TO postgres;

--
-- Name: tconvert(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION tconvert(text, text) RETURNS hstore
    LANGUAGE c IMMUTABLE
    AS '$libdir/hstore', 'tconvert';


ALTER FUNCTION public.tconvert(text, text) OWNER TO postgres;

--
-- Name: ->; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR -> (
    PROCEDURE = fetchval,
    LEFTARG = hstore,
    RIGHTARG = text
);


ALTER OPERATOR public.-> (hstore, text) OWNER TO postgres;

--
-- Name: <@; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR <@ (
    PROCEDURE = hs_contained,
    LEFTARG = hstore,
    RIGHTARG = hstore,
    COMMUTATOR = @>,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


ALTER OPERATOR public.<@ (hstore, hstore) OWNER TO postgres;

--
-- Name: =>; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR => (
    PROCEDURE = tconvert,
    LEFTARG = text,
    RIGHTARG = text
);


ALTER OPERATOR public.=> (text, text) OWNER TO postgres;

--
-- Name: ?; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR ? (
    PROCEDURE = exist,
    LEFTARG = hstore,
    RIGHTARG = text,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


ALTER OPERATOR public.? (hstore, text) OWNER TO postgres;

--
-- Name: @; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR @ (
    PROCEDURE = hs_contains,
    LEFTARG = hstore,
    RIGHTARG = hstore,
    COMMUTATOR = ~,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


ALTER OPERATOR public.@ (hstore, hstore) OWNER TO postgres;

--
-- Name: @>; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR @> (
    PROCEDURE = hs_contains,
    LEFTARG = hstore,
    RIGHTARG = hstore,
    COMMUTATOR = <@,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


ALTER OPERATOR public.@> (hstore, hstore) OWNER TO postgres;

--
-- Name: ||; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR || (
    PROCEDURE = hs_concat,
    LEFTARG = hstore,
    RIGHTARG = hstore
);


ALTER OPERATOR public.|| (hstore, hstore) OWNER TO postgres;

--
-- Name: ~; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR ~ (
    PROCEDURE = hs_contained,
    LEFTARG = hstore,
    RIGHTARG = hstore,
    COMMUTATOR = @,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


ALTER OPERATOR public.~ (hstore, hstore) OWNER TO postgres;

--
-- Name: gin_hstore_ops; Type: OPERATOR CLASS; Schema: public; Owner: postgres
--

CREATE OPERATOR CLASS gin_hstore_ops
    DEFAULT FOR TYPE hstore USING gin AS
    STORAGE text ,
    OPERATOR 7 @>(hstore,hstore) ,
    OPERATOR 9 ?(hstore,text) ,
    FUNCTION 1 (hstore, hstore) bttextcmp(text,text) ,
    FUNCTION 2 (hstore, hstore) gin_extract_hstore(internal,internal) ,
    FUNCTION 3 (hstore, hstore) gin_extract_hstore_query(internal,internal,smallint,internal,internal) ,
    FUNCTION 4 (hstore, hstore) gin_consistent_hstore(internal,smallint,internal,integer,internal,internal);


ALTER OPERATOR CLASS public.gin_hstore_ops USING gin OWNER TO postgres;

--
-- Name: gist_hstore_ops; Type: OPERATOR CLASS; Schema: public; Owner: postgres
--

CREATE OPERATOR CLASS gist_hstore_ops
    DEFAULT FOR TYPE hstore USING gist AS
    STORAGE ghstore ,
    OPERATOR 7 @>(hstore,hstore) ,
    OPERATOR 9 ?(hstore,text) ,
    OPERATOR 13 @(hstore,hstore) ,
    FUNCTION 1 (hstore, hstore) ghstore_consistent(internal,internal,integer,oid,internal) ,
    FUNCTION 2 (hstore, hstore) ghstore_union(internal,internal) ,
    FUNCTION 3 (hstore, hstore) ghstore_compress(internal) ,
    FUNCTION 4 (hstore, hstore) ghstore_decompress(internal) ,
    FUNCTION 5 (hstore, hstore) ghstore_penalty(internal,internal,internal) ,
    FUNCTION 6 (hstore, hstore) ghstore_picksplit(internal,internal) ,
    FUNCTION 7 (hstore, hstore) ghstore_same(internal,internal,internal);


ALTER OPERATOR CLASS public.gist_hstore_ops USING gist OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE TABLE accounts (
    id integer NOT NULL,
    first_name character varying(40),
    last_name character varying(40),
    email character varying(100),
    hashed_password character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    identities hstore,
    language character varying(3) DEFAULT 'eng'::character varying,
    document_language character varying(3) DEFAULT 'eng'::character varying
);


ALTER TABLE public.accounts OWNER TO documentcloud;

--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: documentcloud
--

CREATE SEQUENCE accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.accounts_id_seq OWNER TO documentcloud;

--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documentcloud
--

ALTER SEQUENCE accounts_id_seq OWNED BY accounts.id;


--
-- Name: annotations; Type: TABLE; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE TABLE annotations (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    account_id integer NOT NULL,
    document_id integer NOT NULL,
    page_number integer NOT NULL,
    access integer NOT NULL,
    title text NOT NULL,
    content text,
    location character varying(40),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.annotations OWNER TO documentcloud;

--
-- Name: annotations_id_seq; Type: SEQUENCE; Schema: public; Owner: documentcloud
--

CREATE SEQUENCE annotations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.annotations_id_seq OWNER TO documentcloud;

--
-- Name: annotations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documentcloud
--

ALTER SEQUENCE annotations_id_seq OWNED BY annotations.id;


--
-- Name: app_constants; Type: TABLE; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE TABLE app_constants (
    id integer NOT NULL,
    key character varying(255),
    value character varying(255)
);


ALTER TABLE public.app_constants OWNER TO documentcloud;

--
-- Name: app_constants_id_seq; Type: SEQUENCE; Schema: public; Owner: documentcloud
--

CREATE SEQUENCE app_constants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.app_constants_id_seq OWNER TO documentcloud;

--
-- Name: app_constants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documentcloud
--

ALTER SEQUENCE app_constants_id_seq OWNED BY app_constants.id;


--
-- Name: collaborations; Type: TABLE; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE TABLE collaborations (
    id integer NOT NULL,
    project_id integer NOT NULL,
    account_id integer NOT NULL,
    creator_id integer
);


ALTER TABLE public.collaborations OWNER TO documentcloud;

--
-- Name: collaborations_id_seq; Type: SEQUENCE; Schema: public; Owner: documentcloud
--

CREATE SEQUENCE collaborations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.collaborations_id_seq OWNER TO documentcloud;

--
-- Name: collaborations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documentcloud
--

ALTER SEQUENCE collaborations_id_seq OWNED BY collaborations.id;


--
-- Name: docdata; Type: TABLE; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE TABLE docdata (
    id integer NOT NULL,
    document_id integer NOT NULL,
    data hstore
);


ALTER TABLE public.docdata OWNER TO documentcloud;

--
-- Name: docdata_id_seq; Type: SEQUENCE; Schema: public; Owner: documentcloud
--

CREATE SEQUENCE docdata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.docdata_id_seq OWNER TO documentcloud;

--
-- Name: docdata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documentcloud
--

ALTER SEQUENCE docdata_id_seq OWNED BY docdata.id;


--
-- Name: document_reviewers; Type: TABLE; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE TABLE document_reviewers (
    id integer NOT NULL,
    account_id integer NOT NULL,
    document_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.document_reviewers OWNER TO documentcloud;

--
-- Name: document_reviewers_id_seq; Type: SEQUENCE; Schema: public; Owner: documentcloud
--

CREATE SEQUENCE document_reviewers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.document_reviewers_id_seq OWNER TO documentcloud;

--
-- Name: document_reviewers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documentcloud
--

ALTER SEQUENCE document_reviewers_id_seq OWNED BY document_reviewers.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE TABLE documents (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    account_id integer NOT NULL,
    access integer NOT NULL,
    page_count integer DEFAULT 0 NOT NULL,
    title character varying(1000) NOT NULL,
    slug character varying(255) NOT NULL,
    source character varying(1000),
    language character varying(3),
    description text,
    calais_id character varying(40),
    publication_date date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    related_article text,
    detected_remote_url text,
    remote_url text,
    publish_at timestamp without time zone,
    text_changed boolean DEFAULT false NOT NULL,
    hit_count integer DEFAULT 0 NOT NULL,
    public_note_count integer DEFAULT 0 NOT NULL,
    file_size integer DEFAULT 0 NOT NULL,
    reviewer_count integer DEFAULT 0 NOT NULL,
    char_count integer DEFAULT 0 NOT NULL,
    original_extension character varying(255),
    file_hash text
);


ALTER TABLE public.documents OWNER TO documentcloud;

--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: documentcloud
--

CREATE SEQUENCE documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.documents_id_seq OWNER TO documentcloud;

--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documentcloud
--

ALTER SEQUENCE documents_id_seq OWNED BY documents.id;


--
-- Name: entities; Type: TABLE; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE TABLE entities (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    account_id integer NOT NULL,
    document_id integer NOT NULL,
    access integer NOT NULL,
    kind character varying(40) NOT NULL,
    value character varying(255) NOT NULL,
    relevance double precision DEFAULT 0.0 NOT NULL,
    calais_id character varying(40),
    occurrences text
);


ALTER TABLE public.entities OWNER TO documentcloud;

--
-- Name: entity_dates; Type: TABLE; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE TABLE entity_dates (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    account_id integer NOT NULL,
    document_id integer NOT NULL,
    access integer NOT NULL,
    date date NOT NULL,
    occurrences text
);


ALTER TABLE public.entity_dates OWNER TO documentcloud;

--
-- Name: featured_reports; Type: TABLE; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE TABLE featured_reports (
    id integer NOT NULL,
    url character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    organization character varying(255) NOT NULL,
    article_date date NOT NULL,
    writeup text NOT NULL,
    present_order integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.featured_reports OWNER TO documentcloud;

--
-- Name: featured_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: documentcloud
--

CREATE SEQUENCE featured_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.featured_reports_id_seq OWNER TO documentcloud;

--
-- Name: featured_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documentcloud
--

ALTER SEQUENCE featured_reports_id_seq OWNED BY featured_reports.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE TABLE projects (
    id integer NOT NULL,
    account_id integer,
    title character varying(255),
    description text,
    hidden boolean DEFAULT false NOT NULL
);


ALTER TABLE public.projects OWNER TO documentcloud;

--
-- Name: labels_id_seq; Type: SEQUENCE; Schema: public; Owner: documentcloud
--

CREATE SEQUENCE labels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.labels_id_seq OWNER TO documentcloud;

--
-- Name: labels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documentcloud
--

ALTER SEQUENCE labels_id_seq OWNED BY projects.id;


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE TABLE memberships (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    account_id integer NOT NULL,
    role integer NOT NULL,
    "default" boolean DEFAULT false,
    concealed boolean DEFAULT false
);


ALTER TABLE public.memberships OWNER TO documentcloud;

--
-- Name: memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: documentcloud
--

CREATE SEQUENCE memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.memberships_id_seq OWNER TO documentcloud;

--
-- Name: memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documentcloud
--

ALTER SEQUENCE memberships_id_seq OWNED BY memberships.id;


--
-- Name: metadata_dates_id_seq; Type: SEQUENCE; Schema: public; Owner: documentcloud
--

CREATE SEQUENCE metadata_dates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.metadata_dates_id_seq OWNER TO documentcloud;

--
-- Name: metadata_dates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documentcloud
--

ALTER SEQUENCE metadata_dates_id_seq OWNED BY entity_dates.id;


--
-- Name: metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: documentcloud
--

CREATE SEQUENCE metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.metadata_id_seq OWNER TO documentcloud;

--
-- Name: metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documentcloud
--

ALTER SEQUENCE metadata_id_seq OWNED BY entities.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE TABLE organizations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    slug character varying(100) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    demo boolean DEFAULT false NOT NULL,
    language character varying(3) DEFAULT 'eng'::character varying,
    document_language character varying(3) DEFAULT 'eng'::character varying
);


ALTER TABLE public.organizations OWNER TO documentcloud;

--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: documentcloud
--

CREATE SEQUENCE organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.organizations_id_seq OWNER TO documentcloud;

--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documentcloud
--

ALTER SEQUENCE organizations_id_seq OWNED BY organizations.id;


--
-- Name: pages; Type: TABLE; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE TABLE pages (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    account_id integer NOT NULL,
    document_id integer NOT NULL,
    access integer NOT NULL,
    page_number integer NOT NULL,
    text text NOT NULL,
    start_offset integer,
    end_offset integer
);


ALTER TABLE public.pages OWNER TO documentcloud;

--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: documentcloud
--

CREATE SEQUENCE pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pages_id_seq OWNER TO documentcloud;

--
-- Name: pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documentcloud
--

ALTER SEQUENCE pages_id_seq OWNED BY pages.id;


--
-- Name: processing_jobs; Type: TABLE; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE TABLE processing_jobs (
    id integer NOT NULL,
    account_id integer NOT NULL,
    cloud_crowd_id integer NOT NULL,
    title character varying(255) NOT NULL,
    document_id integer
);


ALTER TABLE public.processing_jobs OWNER TO documentcloud;

--
-- Name: processing_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: documentcloud
--

CREATE SEQUENCE processing_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.processing_jobs_id_seq OWNER TO documentcloud;

--
-- Name: processing_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documentcloud
--

ALTER SEQUENCE processing_jobs_id_seq OWNED BY processing_jobs.id;


--
-- Name: project_memberships; Type: TABLE; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE TABLE project_memberships (
    id integer NOT NULL,
    project_id integer NOT NULL,
    document_id integer NOT NULL
);


ALTER TABLE public.project_memberships OWNER TO documentcloud;

--
-- Name: project_memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: documentcloud
--

CREATE SEQUENCE project_memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.project_memberships_id_seq OWNER TO documentcloud;

--
-- Name: project_memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documentcloud
--

ALTER SEQUENCE project_memberships_id_seq OWNED BY project_memberships.id;


--
-- Name: remote_urls; Type: TABLE; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE TABLE remote_urls (
    id integer NOT NULL,
    document_id integer NOT NULL,
    url character varying(255) NOT NULL,
    hits integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.remote_urls OWNER TO documentcloud;

--
-- Name: remote_urls_id_seq; Type: SEQUENCE; Schema: public; Owner: documentcloud
--

CREATE SEQUENCE remote_urls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.remote_urls_id_seq OWNER TO documentcloud;

--
-- Name: remote_urls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documentcloud
--

ALTER SEQUENCE remote_urls_id_seq OWNED BY remote_urls.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO documentcloud;

--
-- Name: sections; Type: TABLE; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE TABLE sections (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    account_id integer NOT NULL,
    document_id integer NOT NULL,
    access integer NOT NULL,
    title text NOT NULL,
    page_number integer NOT NULL
);


ALTER TABLE public.sections OWNER TO documentcloud;

--
-- Name: sections_id_seq; Type: SEQUENCE; Schema: public; Owner: documentcloud
--

CREATE SEQUENCE sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sections_id_seq OWNER TO documentcloud;

--
-- Name: sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documentcloud
--

ALTER SEQUENCE sections_id_seq OWNED BY sections.id;


--
-- Name: security_keys; Type: TABLE; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE TABLE security_keys (
    id integer NOT NULL,
    securable_type character varying(40) NOT NULL,
    securable_id integer NOT NULL,
    key character varying(40)
);


ALTER TABLE public.security_keys OWNER TO documentcloud;

--
-- Name: security_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: documentcloud
--

CREATE SEQUENCE security_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.security_keys_id_seq OWNER TO documentcloud;

--
-- Name: security_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: documentcloud
--

ALTER SEQUENCE security_keys_id_seq OWNED BY security_keys.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: documentcloud
--

ALTER TABLE ONLY accounts ALTER COLUMN id SET DEFAULT nextval('accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: documentcloud
--

ALTER TABLE ONLY annotations ALTER COLUMN id SET DEFAULT nextval('annotations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: documentcloud
--

ALTER TABLE ONLY app_constants ALTER COLUMN id SET DEFAULT nextval('app_constants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: documentcloud
--

ALTER TABLE ONLY collaborations ALTER COLUMN id SET DEFAULT nextval('collaborations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: documentcloud
--

ALTER TABLE ONLY docdata ALTER COLUMN id SET DEFAULT nextval('docdata_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: documentcloud
--

ALTER TABLE ONLY document_reviewers ALTER COLUMN id SET DEFAULT nextval('document_reviewers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: documentcloud
--

ALTER TABLE ONLY documents ALTER COLUMN id SET DEFAULT nextval('documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: documentcloud
--

ALTER TABLE ONLY entities ALTER COLUMN id SET DEFAULT nextval('metadata_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: documentcloud
--

ALTER TABLE ONLY entity_dates ALTER COLUMN id SET DEFAULT nextval('metadata_dates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: documentcloud
--

ALTER TABLE ONLY featured_reports ALTER COLUMN id SET DEFAULT nextval('featured_reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: documentcloud
--

ALTER TABLE ONLY memberships ALTER COLUMN id SET DEFAULT nextval('memberships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: documentcloud
--

ALTER TABLE ONLY organizations ALTER COLUMN id SET DEFAULT nextval('organizations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: documentcloud
--

ALTER TABLE ONLY pages ALTER COLUMN id SET DEFAULT nextval('pages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: documentcloud
--

ALTER TABLE ONLY processing_jobs ALTER COLUMN id SET DEFAULT nextval('processing_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: documentcloud
--

ALTER TABLE ONLY project_memberships ALTER COLUMN id SET DEFAULT nextval('project_memberships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: documentcloud
--

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('labels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: documentcloud
--

ALTER TABLE ONLY remote_urls ALTER COLUMN id SET DEFAULT nextval('remote_urls_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: documentcloud
--

ALTER TABLE ONLY sections ALTER COLUMN id SET DEFAULT nextval('sections_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: documentcloud
--

ALTER TABLE ONLY security_keys ALTER COLUMN id SET DEFAULT nextval('security_keys_id_seq'::regclass);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: documentcloud; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: annotations_pkey; Type: CONSTRAINT; Schema: public; Owner: documentcloud; Tablespace: 
--

ALTER TABLE ONLY annotations
    ADD CONSTRAINT annotations_pkey PRIMARY KEY (id);


--
-- Name: app_constants_pkey; Type: CONSTRAINT; Schema: public; Owner: documentcloud; Tablespace: 
--

ALTER TABLE ONLY app_constants
    ADD CONSTRAINT app_constants_pkey PRIMARY KEY (id);


--
-- Name: collaborations_pkey; Type: CONSTRAINT; Schema: public; Owner: documentcloud; Tablespace: 
--

ALTER TABLE ONLY collaborations
    ADD CONSTRAINT collaborations_pkey PRIMARY KEY (id);


--
-- Name: docdata_pkey; Type: CONSTRAINT; Schema: public; Owner: documentcloud; Tablespace: 
--

ALTER TABLE ONLY docdata
    ADD CONSTRAINT docdata_pkey PRIMARY KEY (id);


--
-- Name: document_reviewers_pkey; Type: CONSTRAINT; Schema: public; Owner: documentcloud; Tablespace: 
--

ALTER TABLE ONLY document_reviewers
    ADD CONSTRAINT document_reviewers_pkey PRIMARY KEY (id);


--
-- Name: documents_pkey; Type: CONSTRAINT; Schema: public; Owner: documentcloud; Tablespace: 
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: featured_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: documentcloud; Tablespace: 
--

ALTER TABLE ONLY featured_reports
    ADD CONSTRAINT featured_reports_pkey PRIMARY KEY (id);


--
-- Name: labels_pkey; Type: CONSTRAINT; Schema: public; Owner: documentcloud; Tablespace: 
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT labels_pkey PRIMARY KEY (id);


--
-- Name: memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: documentcloud; Tablespace: 
--

ALTER TABLE ONLY memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: metadata_dates_pkey; Type: CONSTRAINT; Schema: public; Owner: documentcloud; Tablespace: 
--

ALTER TABLE ONLY entity_dates
    ADD CONSTRAINT metadata_dates_pkey PRIMARY KEY (id);


--
-- Name: metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: documentcloud; Tablespace: 
--

ALTER TABLE ONLY entities
    ADD CONSTRAINT metadata_pkey PRIMARY KEY (id);


--
-- Name: organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: documentcloud; Tablespace: 
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: pages_pkey; Type: CONSTRAINT; Schema: public; Owner: documentcloud; Tablespace: 
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: processing_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: documentcloud; Tablespace: 
--

ALTER TABLE ONLY processing_jobs
    ADD CONSTRAINT processing_jobs_pkey PRIMARY KEY (id);


--
-- Name: project_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: documentcloud; Tablespace: 
--

ALTER TABLE ONLY project_memberships
    ADD CONSTRAINT project_memberships_pkey PRIMARY KEY (id);


--
-- Name: remote_urls_pkey; Type: CONSTRAINT; Schema: public; Owner: documentcloud; Tablespace: 
--

ALTER TABLE ONLY remote_urls
    ADD CONSTRAINT remote_urls_pkey PRIMARY KEY (id);


--
-- Name: sections_pkey; Type: CONSTRAINT; Schema: public; Owner: documentcloud; Tablespace: 
--

ALTER TABLE ONLY sections
    ADD CONSTRAINT sections_pkey PRIMARY KEY (id);


--
-- Name: security_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: documentcloud; Tablespace: 
--

ALTER TABLE ONLY security_keys
    ADD CONSTRAINT security_keys_pkey PRIMARY KEY (id);


--
-- Name: index_accounts_on_email; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE UNIQUE INDEX index_accounts_on_email ON accounts USING btree (email);


--
-- Name: index_accounts_on_identites; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE INDEX index_accounts_on_identites ON accounts USING gin (identities);


--
-- Name: index_annotations_on_document_id; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE INDEX index_annotations_on_document_id ON annotations USING btree (document_id);


--
-- Name: index_docdata_on_data; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE INDEX index_docdata_on_data ON docdata USING gin (data);


--
-- Name: index_documents_on_access; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE INDEX index_documents_on_access ON documents USING btree (access);


--
-- Name: index_documents_on_account_id; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE INDEX index_documents_on_account_id ON documents USING btree (account_id);


--
-- Name: index_documents_on_file_hash; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE INDEX index_documents_on_file_hash ON documents USING btree (file_hash);


--
-- Name: index_documents_on_hit_count; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE INDEX index_documents_on_hit_count ON documents USING btree (hit_count);


--
-- Name: index_documents_on_public_note_count; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE INDEX index_documents_on_public_note_count ON documents USING btree (public_note_count);


--
-- Name: index_entities_on_value; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE INDEX index_entities_on_value ON entities USING btree (lower((value)::text));


--
-- Name: index_labels_on_account_id; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE INDEX index_labels_on_account_id ON projects USING btree (account_id);


--
-- Name: index_memberships_on_account_id; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE INDEX index_memberships_on_account_id ON memberships USING btree (account_id);


--
-- Name: index_memberships_on_organization_id; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE INDEX index_memberships_on_organization_id ON memberships USING btree (organization_id);


--
-- Name: index_metadata_dates_on_document_id_and_date; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE UNIQUE INDEX index_metadata_dates_on_document_id_and_date ON entity_dates USING btree (document_id, date);


--
-- Name: index_metadata_on_document_id; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE INDEX index_metadata_on_document_id ON entities USING btree (document_id);


--
-- Name: index_metadata_on_kind; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE INDEX index_metadata_on_kind ON entities USING btree (kind);


--
-- Name: index_organizations_on_name; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE UNIQUE INDEX index_organizations_on_name ON organizations USING btree (name);


--
-- Name: index_organizations_on_slug; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE UNIQUE INDEX index_organizations_on_slug ON organizations USING btree (slug);


--
-- Name: index_pages_on_document_id; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE INDEX index_pages_on_document_id ON pages USING btree (document_id);


--
-- Name: index_pages_on_page_number; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE INDEX index_pages_on_page_number ON pages USING btree (page_number);


--
-- Name: index_pages_on_start_offset_and_end_offset; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE INDEX index_pages_on_start_offset_and_end_offset ON pages USING btree (start_offset, end_offset);


--
-- Name: index_processing_jobs_on_account_id; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE INDEX index_processing_jobs_on_account_id ON processing_jobs USING btree (account_id);


--
-- Name: index_project_memberships_on_document_id; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE INDEX index_project_memberships_on_document_id ON project_memberships USING btree (document_id);


--
-- Name: index_project_memberships_on_project_id; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE INDEX index_project_memberships_on_project_id ON project_memberships USING btree (project_id);


--
-- Name: index_sections_on_document_id; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE INDEX index_sections_on_document_id ON sections USING btree (document_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: documentcloud; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


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

