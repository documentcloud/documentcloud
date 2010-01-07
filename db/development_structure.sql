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
    updated_at timestamp without time zone
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
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
    title character varying(255) NOT NULL,
    content text,
    location character varying(40),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    annotations_content_vector tsvector
);


--
-- Name: annotations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE annotations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
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
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: app_constants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE app_constants_id_seq OWNED BY app_constants.id;


--
-- Name: bookmarks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bookmarks (
    id integer NOT NULL,
    account_id integer NOT NULL,
    document_id integer NOT NULL,
    page_number integer NOT NULL,
    title character varying(100) NOT NULL
);


--
-- Name: bookmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bookmarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: bookmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bookmarks_id_seq OWNED BY bookmarks.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE documents (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    account_id integer NOT NULL,
    access integer NOT NULL,
    page_count integer DEFAULT 0 NOT NULL,
    title character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    source character varying(255),
    language character varying(3),
    summary character varying(255),
    calais_id character varying(40),
    publication_date date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE documents_id_seq OWNED BY documents.id;


--
-- Name: full_text; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE full_text (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    account_id integer NOT NULL,
    document_id integer NOT NULL,
    access integer NOT NULL,
    text text NOT NULL,
    full_text_text_vector tsvector
);


--
-- Name: full_text_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE full_text_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: full_text_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE full_text_id_seq OWNED BY full_text.id;


--
-- Name: labels; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE labels (
    id integer NOT NULL,
    account_id integer NOT NULL,
    title character varying(100) NOT NULL,
    document_ids text
);


--
-- Name: labels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE labels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: labels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE labels_id_seq OWNED BY labels.id;


--
-- Name: metadata; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE metadata (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    account_id integer NOT NULL,
    document_id integer NOT NULL,
    access integer NOT NULL,
    kind character varying(40) NOT NULL,
    value character varying(255) NOT NULL,
    relevance double precision DEFAULT 0.0 NOT NULL,
    calais_id character varying(40),
    occurrences text,
    metadata_value_vector tsvector
);


--
-- Name: metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE metadata_id_seq OWNED BY metadata.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE organizations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    slug character varying(100) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
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
    pages_text_vector tsvector
);


--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
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
    title character varying(255) NOT NULL
);


--
-- Name: processing_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE processing_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: processing_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE processing_jobs_id_seq OWNED BY processing_jobs.id;


--
-- Name: saved_searches; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE saved_searches (
    id integer NOT NULL,
    account_id integer NOT NULL,
    query character varying(255) NOT NULL
);


--
-- Name: saved_searches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE saved_searches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: saved_searches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE saved_searches_id_seq OWNED BY saved_searches.id;


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
    title character varying(255) NOT NULL,
    start_page integer NOT NULL,
    end_page integer NOT NULL,
    access integer NOT NULL
);


--
-- Name: sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
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
    NO MAXVALUE
    NO MINVALUE
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

ALTER TABLE bookmarks ALTER COLUMN id SET DEFAULT nextval('bookmarks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE documents ALTER COLUMN id SET DEFAULT nextval('documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE full_text ALTER COLUMN id SET DEFAULT nextval('full_text_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE labels ALTER COLUMN id SET DEFAULT nextval('labels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE metadata ALTER COLUMN id SET DEFAULT nextval('metadata_id_seq'::regclass);


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

ALTER TABLE saved_searches ALTER COLUMN id SET DEFAULT nextval('saved_searches_id_seq'::regclass);


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
-- Name: bookmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bookmarks
    ADD CONSTRAINT bookmarks_pkey PRIMARY KEY (id);


--
-- Name: documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: full_text_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY full_text
    ADD CONSTRAINT full_text_pkey PRIMARY KEY (id);


--
-- Name: labels_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY labels
    ADD CONSTRAINT labels_pkey PRIMARY KEY (id);


--
-- Name: metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY metadata
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
-- Name: saved_searches_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY saved_searches
    ADD CONSTRAINT saved_searches_pkey PRIMARY KEY (id);


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
-- Name: annotations_content_fti; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX annotations_content_fti ON annotations USING gin (annotations_content_vector);


--
-- Name: fk_organization_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk_organization_id ON accounts USING btree (organization_id);


--
-- Name: full_text_text_fti; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX full_text_text_fti ON full_text USING gin (full_text_text_vector);


--
-- Name: index_accounts_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_accounts_on_email ON accounts USING btree (email);


--
-- Name: index_annotations_on_document_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_annotations_on_document_id ON annotations USING btree (document_id);


--
-- Name: index_bookmarks_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bookmarks_on_account_id ON bookmarks USING btree (account_id);


--
-- Name: index_full_text_on_document_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_full_text_on_document_id ON full_text USING btree (document_id);


--
-- Name: index_labels_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_labels_on_account_id ON labels USING btree (account_id);


--
-- Name: index_organizations_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_organizations_on_name ON organizations USING btree (name);


--
-- Name: index_organizations_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_organizations_on_slug ON organizations USING btree (slug);


--
-- Name: index_pages_on_document_id_and_page_number; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_pages_on_document_id_and_page_number ON pages USING btree (document_id, page_number);


--
-- Name: index_processing_jobs_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_processing_jobs_on_account_id ON processing_jobs USING btree (account_id);


--
-- Name: index_saved_searches_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_saved_searches_on_account_id ON saved_searches USING btree (account_id);


--
-- Name: index_sections_on_document_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sections_on_document_id ON sections USING btree (document_id);


--
-- Name: metadata_value_fti; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX metadata_value_fti ON metadata USING gin (metadata_value_vector);


--
-- Name: pages_text_fti; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX pages_text_fti ON pages USING gin (pages_text_vector);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: annotations_content_vector_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER annotations_content_vector_update
    BEFORE INSERT OR UPDATE ON annotations
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('annotations_content_vector', 'pg_catalog.english', 'content');


--
-- Name: full_text_text_vector_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER full_text_text_vector_update
    BEFORE INSERT OR UPDATE ON full_text
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('full_text_text_vector', 'pg_catalog.english', 'text');


--
-- Name: metadata_value_vector_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER metadata_value_vector_update
    BEFORE INSERT OR UPDATE ON metadata
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('metadata_value_vector', 'pg_catalog.english', 'value');


--
-- Name: pages_text_vector_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER pages_text_vector_update
    BEFORE INSERT OR UPDATE ON pages
    FOR EACH ROW
    EXECUTE PROCEDURE tsvector_update_trigger('pages_text_vector', 'pg_catalog.english', 'text');


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('1');