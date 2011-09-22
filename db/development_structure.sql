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

--
-- Name: ghstore; Type: SHELL TYPE; Schema: public; Owner: -
--

CREATE TYPE ghstore;


--
-- Name: ghstore_in(cstring); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ghstore_in(cstring) RETURNS ghstore
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'ghstore_in';


--
-- Name: ghstore_out(ghstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ghstore_out(ghstore) RETURNS cstring
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'ghstore_out';


--
-- Name: ghstore; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE ghstore (
    INTERNALLENGTH = variable,
    INPUT = ghstore_in,
    OUTPUT = ghstore_out,
    ALIGNMENT = int4,
    STORAGE = plain
);


--
-- Name: hstore; Type: SHELL TYPE; Schema: public; Owner: -
--

CREATE TYPE hstore;


--
-- Name: hstore_in(cstring); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hstore_in(cstring) RETURNS hstore
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_in';


--
-- Name: hstore_out(hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hstore_out(hstore) RETURNS cstring
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_out';


--
-- Name: hstore_recv(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hstore_recv(internal) RETURNS hstore
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_recv';


--
-- Name: hstore_send(hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hstore_send(hstore) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_send';


--
-- Name: hstore; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE hstore (
    INTERNALLENGTH = variable,
    INPUT = hstore_in,
    OUTPUT = hstore_out,
    RECEIVE = hstore_recv,
    SEND = hstore_send,
    ALIGNMENT = int4,
    STORAGE = extended
);


--
-- Name: akeys(hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION akeys(hstore) RETURNS text[]
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_akeys';


--
-- Name: avals(hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION avals(hstore) RETURNS text[]
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_avals';


--
-- Name: defined(hstore, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION defined(hstore, text) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_defined';


--
-- Name: delete(hstore, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION delete(hstore, text) RETURNS hstore
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_delete';


--
-- Name: delete(hstore, text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION delete(hstore, text[]) RETURNS hstore
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_delete_array';


--
-- Name: delete(hstore, hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION delete(hstore, hstore) RETURNS hstore
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_delete_hstore';


--
-- Name: each(hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION each(hs hstore, OUT key text, OUT value text) RETURNS SETOF record
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_each';


--
-- Name: exist(hstore, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION exist(hstore, text) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_exists';


--
-- Name: exists_all(hstore, text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION exists_all(hstore, text[]) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_exists_all';


--
-- Name: exists_any(hstore, text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION exists_any(hstore, text[]) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_exists_any';


--
-- Name: fetchval(hstore, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fetchval(hstore, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_fetchval';


--
-- Name: ghstore_compress(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ghstore_compress(internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'ghstore_compress';


--
-- Name: ghstore_consistent(internal, internal, integer, oid, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ghstore_consistent(internal, internal, integer, oid, internal) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'ghstore_consistent';


--
-- Name: ghstore_decompress(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ghstore_decompress(internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'ghstore_decompress';


--
-- Name: ghstore_penalty(internal, internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ghstore_penalty(internal, internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'ghstore_penalty';


--
-- Name: ghstore_picksplit(internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ghstore_picksplit(internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'ghstore_picksplit';


--
-- Name: ghstore_same(internal, internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ghstore_same(internal, internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'ghstore_same';


--
-- Name: ghstore_union(internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ghstore_union(internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'ghstore_union';


--
-- Name: gin_consistent_hstore(internal, smallint, internal, integer, internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gin_consistent_hstore(internal, smallint, internal, integer, internal, internal) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'gin_consistent_hstore';


--
-- Name: gin_extract_hstore(internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gin_extract_hstore(internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'gin_extract_hstore';


--
-- Name: gin_extract_hstore_query(internal, internal, smallint, internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gin_extract_hstore_query(internal, internal, smallint, internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'gin_extract_hstore_query';


--
-- Name: hs_concat(hstore, hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hs_concat(hstore, hstore) RETURNS hstore
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_concat';


--
-- Name: hs_contained(hstore, hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hs_contained(hstore, hstore) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_contained';


--
-- Name: hs_contains(hstore, hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hs_contains(hstore, hstore) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_contains';


--
-- Name: hstore(text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hstore(text[]) RETURNS hstore
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_from_array';


--
-- Name: hstore(record); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hstore(record) RETURNS hstore
    LANGUAGE c IMMUTABLE
    AS '$libdir/hstore', 'hstore_from_record';


--
-- Name: hstore(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hstore(text, text) RETURNS hstore
    LANGUAGE c IMMUTABLE
    AS '$libdir/hstore', 'hstore_from_text';


--
-- Name: hstore(text[], text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hstore(text[], text[]) RETURNS hstore
    LANGUAGE c IMMUTABLE
    AS '$libdir/hstore', 'hstore_from_arrays';


--
-- Name: hstore_cmp(hstore, hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hstore_cmp(hstore, hstore) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_cmp';


--
-- Name: hstore_eq(hstore, hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hstore_eq(hstore, hstore) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_eq';


--
-- Name: hstore_ge(hstore, hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hstore_ge(hstore, hstore) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_ge';


--
-- Name: hstore_gt(hstore, hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hstore_gt(hstore, hstore) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_gt';


--
-- Name: hstore_hash(hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hstore_hash(hstore) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_hash';


--
-- Name: hstore_le(hstore, hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hstore_le(hstore, hstore) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_le';


--
-- Name: hstore_lt(hstore, hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hstore_lt(hstore, hstore) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_lt';


--
-- Name: hstore_ne(hstore, hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hstore_ne(hstore, hstore) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_ne';


--
-- Name: hstore_to_array(hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hstore_to_array(hstore) RETURNS text[]
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_to_array';


--
-- Name: hstore_to_matrix(hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hstore_to_matrix(hstore) RETURNS text[]
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_to_matrix';


--
-- Name: hstore_version_diag(hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hstore_version_diag(hstore) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_version_diag';


--
-- Name: isdefined(hstore, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION isdefined(hstore, text) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_defined';


--
-- Name: isexists(hstore, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION isexists(hstore, text) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_exists';


--
-- Name: populate_record(anyelement, hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION populate_record(anyelement, hstore) RETURNS anyelement
    LANGUAGE c IMMUTABLE
    AS '$libdir/hstore', 'hstore_populate_record';


--
-- Name: skeys(hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION skeys(hstore) RETURNS SETOF text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_skeys';


--
-- Name: slice(hstore, text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION slice(hstore, text[]) RETURNS hstore
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_slice_to_hstore';


--
-- Name: slice_array(hstore, text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION slice_array(hstore, text[]) RETURNS text[]
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_slice_to_array';


--
-- Name: svals(hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION svals(hstore) RETURNS SETOF text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/hstore', 'hstore_svals';


--
-- Name: tconvert(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION tconvert(text, text) RETURNS hstore
    LANGUAGE c IMMUTABLE
    AS '$libdir/hstore', 'hstore_from_text';


--
-- Name: #<#; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR #<# (
    PROCEDURE = hstore_lt,
    LEFTARG = hstore,
    RIGHTARG = hstore,
    COMMUTATOR = #>#,
    NEGATOR = #>=#,
    RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel
);


--
-- Name: #<=#; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR #<=# (
    PROCEDURE = hstore_le,
    LEFTARG = hstore,
    RIGHTARG = hstore,
    COMMUTATOR = #>=#,
    NEGATOR = #>#,
    RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel
);


--
-- Name: #=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR #= (
    PROCEDURE = populate_record,
    LEFTARG = anyelement,
    RIGHTARG = hstore
);


--
-- Name: #>#; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR #># (
    PROCEDURE = hstore_gt,
    LEFTARG = hstore,
    RIGHTARG = hstore,
    COMMUTATOR = #<#,
    NEGATOR = #<=#,
    RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel
);


--
-- Name: #>=#; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR #>=# (
    PROCEDURE = hstore_ge,
    LEFTARG = hstore,
    RIGHTARG = hstore,
    COMMUTATOR = #<=#,
    NEGATOR = #<#,
    RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel
);


--
-- Name: %#; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR %# (
    PROCEDURE = hstore_to_matrix,
    RIGHTARG = hstore
);


--
-- Name: %%; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR %% (
    PROCEDURE = hstore_to_array,
    RIGHTARG = hstore
);


--
-- Name: -; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR - (
    PROCEDURE = delete,
    LEFTARG = hstore,
    RIGHTARG = text
);


--
-- Name: -; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR - (
    PROCEDURE = delete,
    LEFTARG = hstore,
    RIGHTARG = text[]
);


--
-- Name: -; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR - (
    PROCEDURE = delete,
    LEFTARG = hstore,
    RIGHTARG = hstore
);


--
-- Name: ->; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR -> (
    PROCEDURE = fetchval,
    LEFTARG = hstore,
    RIGHTARG = text
);


--
-- Name: ->; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR -> (
    PROCEDURE = slice_array,
    LEFTARG = hstore,
    RIGHTARG = text[]
);


--
-- Name: <>; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR <> (
    PROCEDURE = hstore_ne,
    LEFTARG = hstore,
    RIGHTARG = hstore,
    COMMUTATOR = <>,
    NEGATOR = =,
    RESTRICT = neqsel,
    JOIN = neqjoinsel
);


--
-- Name: <@; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR <@ (
    PROCEDURE = hs_contained,
    LEFTARG = hstore,
    RIGHTARG = hstore,
    COMMUTATOR = @>,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: =; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR = (
    PROCEDURE = hstore_eq,
    LEFTARG = hstore,
    RIGHTARG = hstore,
    COMMUTATOR = =,
    NEGATOR = <>,
    MERGES,
    HASHES,
    RESTRICT = eqsel,
    JOIN = eqjoinsel
);


--
-- Name: =>; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR => (
    PROCEDURE = hstore,
    LEFTARG = text,
    RIGHTARG = text
);


--
-- Name: ?; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR ? (
    PROCEDURE = exist,
    LEFTARG = hstore,
    RIGHTARG = text,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: ?&; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR ?& (
    PROCEDURE = exists_all,
    LEFTARG = hstore,
    RIGHTARG = text[],
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: ?|; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR ?| (
    PROCEDURE = exists_any,
    LEFTARG = hstore,
    RIGHTARG = text[],
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: @; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR @ (
    PROCEDURE = hs_contains,
    LEFTARG = hstore,
    RIGHTARG = hstore,
    COMMUTATOR = ~,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: @>; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR @> (
    PROCEDURE = hs_contains,
    LEFTARG = hstore,
    RIGHTARG = hstore,
    COMMUTATOR = <@,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: ||; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR || (
    PROCEDURE = hs_concat,
    LEFTARG = hstore,
    RIGHTARG = hstore
);


--
-- Name: ~; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR ~ (
    PROCEDURE = hs_contained,
    LEFTARG = hstore,
    RIGHTARG = hstore,
    COMMUTATOR = @,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: btree_hstore_ops; Type: OPERATOR CLASS; Schema: public; Owner: -
--

CREATE OPERATOR CLASS btree_hstore_ops
    DEFAULT FOR TYPE hstore USING btree AS
    OPERATOR 1 #<#(hstore,hstore) ,
    OPERATOR 2 #<=#(hstore,hstore) ,
    OPERATOR 3 =(hstore,hstore) ,
    OPERATOR 4 #>=#(hstore,hstore) ,
    OPERATOR 5 #>#(hstore,hstore) ,
    FUNCTION 1 hstore_cmp(hstore,hstore);


--
-- Name: gin_hstore_ops; Type: OPERATOR CLASS; Schema: public; Owner: -
--

CREATE OPERATOR CLASS gin_hstore_ops
    DEFAULT FOR TYPE hstore USING gin AS
    STORAGE text ,
    OPERATOR 7 @>(hstore,hstore) ,
    OPERATOR 9 ?(hstore,text) ,
    OPERATOR 10 ?|(hstore,text[]) ,
    OPERATOR 11 ?&(hstore,text[]) ,
    FUNCTION 1 bttextcmp(text,text) ,
    FUNCTION 2 gin_extract_hstore(internal,internal) ,
    FUNCTION 3 gin_extract_hstore_query(internal,internal,smallint,internal,internal) ,
    FUNCTION 4 gin_consistent_hstore(internal,smallint,internal,integer,internal,internal);


--
-- Name: gist_hstore_ops; Type: OPERATOR CLASS; Schema: public; Owner: -
--

CREATE OPERATOR CLASS gist_hstore_ops
    DEFAULT FOR TYPE hstore USING gist AS
    STORAGE ghstore ,
    OPERATOR 7 @>(hstore,hstore) ,
    OPERATOR 9 ?(hstore,text) ,
    OPERATOR 10 ?|(hstore,text[]) ,
    OPERATOR 11 ?&(hstore,text[]) ,
    OPERATOR 13 @(hstore,hstore) ,
    FUNCTION 1 ghstore_consistent(internal,internal,integer,oid,internal) ,
    FUNCTION 2 ghstore_union(internal,internal) ,
    FUNCTION 3 ghstore_compress(internal) ,
    FUNCTION 4 ghstore_decompress(internal) ,
    FUNCTION 5 ghstore_penalty(internal,internal,internal) ,
    FUNCTION 6 ghstore_picksplit(internal,internal) ,
    FUNCTION 7 ghstore_same(internal,internal,internal);


--
-- Name: hash_hstore_ops; Type: OPERATOR CLASS; Schema: public; Owner: -
--

CREATE OPERATOR CLASS hash_hstore_ops
    DEFAULT FOR TYPE hstore USING hash AS
    OPERATOR 1 =(hstore,hstore) ,
    FUNCTION 1 hstore_hash(hstore);


SET search_path = pg_catalog;

--
-- Name: CAST (text[] AS public.hstore); Type: CAST; Schema: pg_catalog; Owner: -
--

CREATE CAST (text[] AS public.hstore) WITH FUNCTION public.hstore(text[]);


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE accounts (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    first_name character varying(40) NOT NULL,
    last_name character varying(40) NOT NULL,
    email character varying(100) NOT NULL,
    hashed_password character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    role integer NOT NULL
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE accounts_id_seq OWNED BY accounts.id;


--
-- Name: annotations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- Name: annotations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE annotations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: annotations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE annotations_id_seq OWNED BY annotations.id;


--
-- Name: app_constants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE app_constants (
    id integer NOT NULL,
    key character varying(255),
    value character varying(255)
);


--
-- Name: app_constants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE app_constants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: app_constants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE app_constants_id_seq OWNED BY app_constants.id;


--
-- Name: collaborations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE collaborations (
    id integer NOT NULL,
    project_id integer NOT NULL,
    account_id integer NOT NULL,
    creator_id integer
);


--
-- Name: collaborations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE collaborations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collaborations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE collaborations_id_seq OWNED BY collaborations.id;


--
-- Name: docdata; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE docdata (
    id integer NOT NULL,
    document_id integer NOT NULL,
    data hstore
);


--
-- Name: docdata_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE docdata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: docdata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE docdata_id_seq OWNED BY docdata.id;


--
-- Name: document_reviewers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE document_reviewers (
    id integer NOT NULL,
    account_id integer NOT NULL,
    document_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: document_reviewers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE document_reviewers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: document_reviewers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE document_reviewers_id_seq OWNED BY document_reviewers.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
    reviewer_count integer DEFAULT 0 NOT NULL,
    file_size integer DEFAULT 0 NOT NULL
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE documents_id_seq OWNED BY documents.id;


--
-- Name: entities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- Name: entity_dates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE projects (
    id integer NOT NULL,
    account_id integer,
    title character varying(255),
    description text,
    hidden boolean DEFAULT false NOT NULL
);


--
-- Name: labels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE labels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: labels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE labels_id_seq OWNED BY projects.id;


--
-- Name: metadata_dates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE metadata_dates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: metadata_dates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE metadata_dates_id_seq OWNED BY entity_dates.id;


--
-- Name: metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE metadata_id_seq OWNED BY entities.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE organizations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    slug character varying(100) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    demo boolean DEFAULT false NOT NULL
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organizations_id_seq OWNED BY organizations.id;


--
-- Name: pages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pages_id_seq OWNED BY pages.id;


--
-- Name: processing_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE processing_jobs (
    id integer NOT NULL,
    account_id integer NOT NULL,
    cloud_crowd_id integer NOT NULL,
    title character varying(255) NOT NULL,
    document_id integer
);


--
-- Name: processing_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE processing_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: processing_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE processing_jobs_id_seq OWNED BY processing_jobs.id;


--
-- Name: project_memberships; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_memberships (
    id integer NOT NULL,
    project_id integer NOT NULL,
    document_id integer NOT NULL
);


--
-- Name: project_memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_memberships_id_seq OWNED BY project_memberships.id;


--
-- Name: remote_urls; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE remote_urls (
    id integer NOT NULL,
    document_id integer NOT NULL,
    url character varying(255) NOT NULL,
    hits integer DEFAULT 0 NOT NULL
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
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: sections; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sections (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    account_id integer NOT NULL,
    document_id integer NOT NULL,
    title text NOT NULL,
    page_number integer NOT NULL,
    access integer NOT NULL
);


--
-- Name: sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sections_id_seq OWNED BY sections.id;


--
-- Name: security_keys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE security_keys (
    id integer NOT NULL,
    securable_type character varying(40) NOT NULL,
    securable_id integer NOT NULL,
    key character varying(40)
);


--
-- Name: security_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE security_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: security_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE security_keys_id_seq OWNED BY security_keys.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE accounts ALTER COLUMN id SET DEFAULT nextval('accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE annotations ALTER COLUMN id SET DEFAULT nextval('annotations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE app_constants ALTER COLUMN id SET DEFAULT nextval('app_constants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE collaborations ALTER COLUMN id SET DEFAULT nextval('collaborations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE docdata ALTER COLUMN id SET DEFAULT nextval('docdata_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE document_reviewers ALTER COLUMN id SET DEFAULT nextval('document_reviewers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE documents ALTER COLUMN id SET DEFAULT nextval('documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE entities ALTER COLUMN id SET DEFAULT nextval('metadata_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE entity_dates ALTER COLUMN id SET DEFAULT nextval('metadata_dates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE organizations ALTER COLUMN id SET DEFAULT nextval('organizations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE pages ALTER COLUMN id SET DEFAULT nextval('pages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE processing_jobs ALTER COLUMN id SET DEFAULT nextval('processing_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE project_memberships ALTER COLUMN id SET DEFAULT nextval('project_memberships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE projects ALTER COLUMN id SET DEFAULT nextval('labels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE remote_urls ALTER COLUMN id SET DEFAULT nextval('remote_urls_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE sections ALTER COLUMN id SET DEFAULT nextval('sections_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE security_keys ALTER COLUMN id SET DEFAULT nextval('security_keys_id_seq'::regclass);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: annotations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY annotations
    ADD CONSTRAINT annotations_pkey PRIMARY KEY (id);


--
-- Name: app_constants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY app_constants
    ADD CONSTRAINT app_constants_pkey PRIMARY KEY (id);


--
-- Name: collaborations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY collaborations
    ADD CONSTRAINT collaborations_pkey PRIMARY KEY (id);


--
-- Name: docdata_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY docdata
    ADD CONSTRAINT docdata_pkey PRIMARY KEY (id);


--
-- Name: document_reviewers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY document_reviewers
    ADD CONSTRAINT document_reviewers_pkey PRIMARY KEY (id);


--
-- Name: documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: labels_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT labels_pkey PRIMARY KEY (id);


--
-- Name: metadata_dates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY entity_dates
    ADD CONSTRAINT metadata_dates_pkey PRIMARY KEY (id);


--
-- Name: metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY entities
    ADD CONSTRAINT metadata_pkey PRIMARY KEY (id);


--
-- Name: organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: processing_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY processing_jobs
    ADD CONSTRAINT processing_jobs_pkey PRIMARY KEY (id);


--
-- Name: project_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_memberships
    ADD CONSTRAINT project_memberships_pkey PRIMARY KEY (id);


--
-- Name: remote_urls_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY remote_urls
    ADD CONSTRAINT remote_urls_pkey PRIMARY KEY (id);


--
-- Name: sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sections
    ADD CONSTRAINT sections_pkey PRIMARY KEY (id);


--
-- Name: security_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY security_keys
    ADD CONSTRAINT security_keys_pkey PRIMARY KEY (id);


--
-- Name: fk_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk_organization_id ON accounts USING btree (organization_id);


--
-- Name: index_accounts_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_accounts_on_email ON accounts USING btree (email);


--
-- Name: index_annotations_on_document_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_annotations_on_document_id ON annotations USING btree (document_id);


--
-- Name: index_docdata_on_data; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_docdata_on_data ON docdata USING gin (data);


--
-- Name: index_documents_on_access; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_documents_on_access ON documents USING btree (access);


--
-- Name: index_documents_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_documents_on_account_id ON documents USING btree (account_id);


--
-- Name: index_documents_on_hit_count; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_documents_on_hit_count ON documents USING btree (hit_count);


--
-- Name: index_documents_on_public_note_count; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_documents_on_public_note_count ON documents USING btree (public_note_count);


--
-- Name: index_entities_on_value; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_entities_on_value ON entities USING btree (lower((value)::text));


--
-- Name: index_labels_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_labels_on_account_id ON projects USING btree (account_id);


--
-- Name: index_metadata_dates_on_document_id_and_date; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_metadata_dates_on_document_id_and_date ON entity_dates USING btree (document_id, date);


--
-- Name: index_metadata_on_document_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_metadata_on_document_id ON entities USING btree (document_id);


--
-- Name: index_metadata_on_kind; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_metadata_on_kind ON entities USING btree (kind);


--
-- Name: index_organizations_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_organizations_on_name ON organizations USING btree (name);


--
-- Name: index_organizations_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_organizations_on_slug ON organizations USING btree (slug);


--
-- Name: index_pages_on_document_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pages_on_document_id ON pages USING btree (document_id);


--
-- Name: index_pages_on_page_number; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pages_on_page_number ON pages USING btree (page_number);


--
-- Name: index_pages_on_start_offset_and_end_offset; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pages_on_start_offset_and_end_offset ON pages USING btree (start_offset, end_offset);


--
-- Name: index_processing_jobs_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_processing_jobs_on_account_id ON processing_jobs USING btree (account_id);


--
-- Name: index_project_memberships_on_document_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_project_memberships_on_document_id ON project_memberships USING btree (document_id);


--
-- Name: index_project_memberships_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_project_memberships_on_project_id ON project_memberships USING btree (project_id);


--
-- Name: index_sections_on_document_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sections_on_document_id ON sections USING btree (document_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('20100108163304');

INSERT INTO schema_migrations (version) VALUES ('20100108172251');

INSERT INTO schema_migrations (version) VALUES ('20100109025746');

INSERT INTO schema_migrations (version) VALUES ('20100109035508');

INSERT INTO schema_migrations (version) VALUES ('20100109041445');

INSERT INTO schema_migrations (version) VALUES ('20100112143144');

INSERT INTO schema_migrations (version) VALUES ('20100114170321');

INSERT INTO schema_migrations (version) VALUES ('20100114170333');

INSERT INTO schema_migrations (version) VALUES ('20100114170350');

INSERT INTO schema_migrations (version) VALUES ('20100120194128');

INSERT INTO schema_migrations (version) VALUES ('20100120205426');

INSERT INTO schema_migrations (version) VALUES ('20100607182008');

INSERT INTO schema_migrations (version) VALUES ('20100125165305');

INSERT INTO schema_migrations (version) VALUES ('20100208131000');

INSERT INTO schema_migrations (version) VALUES ('20100208151651');

INSERT INTO schema_migrations (version) VALUES ('20100212130932');

INSERT INTO schema_migrations (version) VALUES ('20100218193708');

INSERT INTO schema_migrations (version) VALUES ('20100219175757');

INSERT INTO schema_migrations (version) VALUES ('20100301200857');

INSERT INTO schema_migrations (version) VALUES ('20100304154343');

INSERT INTO schema_migrations (version) VALUES ('20100316001441');

INSERT INTO schema_migrations (version) VALUES ('20100317145034');

INSERT INTO schema_migrations (version) VALUES ('20100317181051');

INSERT INTO schema_migrations (version) VALUES ('20100401192921');

INSERT INTO schema_migrations (version) VALUES ('20100413132825');

INSERT INTO schema_migrations (version) VALUES ('20100624142442');

INSERT INTO schema_migrations (version) VALUES ('20100625143140');

INSERT INTO schema_migrations (version) VALUES ('20100630131224');

INSERT INTO schema_migrations (version) VALUES ('20100701132413');

INSERT INTO schema_migrations (version) VALUES ('20100823172339');

INSERT INTO schema_migrations (version) VALUES ('20100928204710');

INSERT INTO schema_migrations (version) VALUES ('20101025202334');

INSERT INTO schema_migrations (version) VALUES ('20101028194006');

INSERT INTO schema_migrations (version) VALUES ('20101101192020');

INSERT INTO schema_migrations (version) VALUES ('20101103173409');

INSERT INTO schema_migrations (version) VALUES ('20101207203607');

INSERT INTO schema_migrations (version) VALUES ('20101209175540');

INSERT INTO schema_migrations (version) VALUES ('20110111192934');

INSERT INTO schema_migrations (version) VALUES ('20110113204915');

INSERT INTO schema_migrations (version) VALUES ('20110114143536');

INSERT INTO schema_migrations (version) VALUES ('20101110170100');

INSERT INTO schema_migrations (version) VALUES ('20101214171909');

INSERT INTO schema_migrations (version) VALUES ('20110217161649');

INSERT INTO schema_migrations (version) VALUES ('20110217171353');

INSERT INTO schema_migrations (version) VALUES ('20110207212034');

INSERT INTO schema_migrations (version) VALUES ('20110216180521');

INSERT INTO schema_migrations (version) VALUES ('20110224153154');

INSERT INTO schema_migrations (version) VALUES ('20110303200824');

INSERT INTO schema_migrations (version) VALUES ('20110303202721');

INSERT INTO schema_migrations (version) VALUES ('20110304213500');

INSERT INTO schema_migrations (version) VALUES ('20110308170707');

INSERT INTO schema_migrations (version) VALUES ('20110310000919');

INSERT INTO schema_migrations (version) VALUES ('20110429150927');

INSERT INTO schema_migrations (version) VALUES ('20110502200512');

INSERT INTO schema_migrations (version) VALUES ('20110505172648');

INSERT INTO schema_migrations (version) VALUES ('20110512193718');

INSERT INTO schema_migrations (version) VALUES ('20110603223356');