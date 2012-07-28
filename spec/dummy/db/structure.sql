--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
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


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE accounts (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    owner_id uuid,
    active boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE addresses (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    account_id uuid,
    allocated boolean DEFAULT false NOT NULL,
    address inet NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instance_id uuid
);


--
-- Name: instances; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE instances (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    account_id uuid NOT NULL,
    guid uuid,
    state character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    name character varying(255) NOT NULL,
    memory integer DEFAULT 0 NOT NULL,
    clock_type character varying(255) DEFAULT 'UTC'::character varying NOT NULL,
    boot_device character varying(255) DEFAULT 'DISK'::character varying NOT NULL,
    license character varying(255),
    context hstore,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: instances_key_pairs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE instances_key_pairs (
    instance_id uuid NOT NULL,
    key_pair_id uuid NOT NULL
);


--
-- Name: interfaces; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE interfaces (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    instance_id uuid NOT NULL,
    network_id uuid NOT NULL,
    address inet NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: networks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE networks (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    account_id uuid,
    guid uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    public boolean DEFAULT false NOT NULL
);


--
-- Name: orion_billing_rate_codes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE orion_billing_rate_codes (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    account_id uuid,
    storage_price numeric(5,4) DEFAULT 0 NOT NULL,
    memory_price numeric(5,4) DEFAULT 0 NOT NULL,
    address_price numeric(5,4) DEFAULT 0 NOT NULL,
    bandwidth_price numeric(5,4) DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: orion_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE orion_events (
    id integer NOT NULL,
    sequence integer DEFAULT 0 NOT NULL,
    correlated_id uuid NOT NULL,
    correlated_type character varying(255) NOT NULL,
    payload_data text,
    payload_headers text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: orion_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE orion_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orion_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE orion_events_id_seq OWNED BY orion_events.id;


--
-- Name: orion_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE orion_jobs (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    correlated_id uuid,
    correlated_type character varying(255),
    account_id uuid,
    resource_id uuid,
    resource_type character varying(255),
    action character varying(255),
    state character varying(255) DEFAULT 'requested'::character varying NOT NULL,
    duration numeric DEFAULT 0 NOT NULL,
    backend_sequence integer,
    requested_at timestamp without time zone,
    responded_at timestamp without time zone,
    actioned_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    notified boolean DEFAULT false NOT NULL
);


--
-- Name: orion_key_pairs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE orion_key_pairs (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    account_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    public_key text NOT NULL,
    fingerprint character varying(255),
    bits integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: orion_key_pairs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE orion_key_pairs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orion_key_pairs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE orion_key_pairs_id_seq OWNED BY orion_key_pairs.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: tokens; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tokens (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    token character varying(255) NOT NULL,
    secret character varying(255) NOT NULL,
    revoked boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    account_id uuid,
    first_name character varying(255),
    last_name character varying(255),
    phone_number character varying(255),
    mobile_number character varying(255),
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    confirmation_token character varying(255),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying(255),
    failed_attempts integer DEFAULT 0,
    unlock_token character varying(255),
    locked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: vnc_sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vnc_sessions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    account_id uuid NOT NULL,
    user_id uuid NOT NULL,
    instance_id uuid NOT NULL,
    auth_token character varying(255),
    port character varying(255),
    host character varying(255),
    expires_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: vnc_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vnc_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vnc_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vnc_sessions_id_seq OWNED BY vnc_sessions.id;


--
-- Name: volumes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE volumes (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    account_id uuid NOT NULL,
    guid uuid,
    state character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    instance_id uuid,
    name character varying(255) NOT NULL,
    size integer DEFAULT 0 NOT NULL,
    mirror_count integer DEFAULT 2 NOT NULL,
    target integer,
    attach_type character varying(255),
    attached_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    source hstore
);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY orion_events ALTER COLUMN id SET DEFAULT nextval('orion_events_id_seq'::regclass);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: network_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY interfaces
    ADD CONSTRAINT network_addresses_pkey PRIMARY KEY (id);


--
-- Name: networks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY networks
    ADD CONSTRAINT networks_pkey PRIMARY KEY (id);


--
-- Name: orion_billing_rate_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY orion_billing_rate_codes
    ADD CONSTRAINT orion_billing_rate_codes_pkey PRIMARY KEY (id);


--
-- Name: orion_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY orion_events
    ADD CONSTRAINT orion_events_pkey PRIMARY KEY (id);


--
-- Name: orion_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY orion_jobs
    ADD CONSTRAINT orion_jobs_pkey PRIMARY KEY (id);


--
-- Name: orion_key_pairs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY orion_key_pairs
    ADD CONSTRAINT orion_key_pairs_pkey PRIMARY KEY (id);


--
-- Name: tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vnc_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vnc_sessions
    ADD CONSTRAINT vnc_sessions_pkey PRIMARY KEY (id);


--
-- Name: volumes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY volumes
    ADD CONSTRAINT volumes_pkey PRIMARY KEY (id);


--
-- Name: index_addresses_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_addresses_on_account_id ON addresses USING btree (account_id);


--
-- Name: index_addresses_on_instance_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_addresses_on_instance_id ON addresses USING btree (instance_id);


--
-- Name: index_instances_key_pairs_on_instance_id_and_key_pair_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_instances_key_pairs_on_instance_id_and_key_pair_id ON instances_key_pairs USING btree (instance_id, key_pair_id);


--
-- Name: index_instances_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_instances_on_account_id ON instances USING btree (account_id);


--
-- Name: index_instances_on_account_id_and_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_instances_on_account_id_and_name ON instances USING btree (account_id, name);


--
-- Name: index_instances_on_guid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_instances_on_guid ON instances USING btree (guid);


--
-- Name: index_network_addresses_on_address; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_network_addresses_on_address ON interfaces USING btree (address);


--
-- Name: index_network_addresses_on_instance_id_and_network_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_network_addresses_on_instance_id_and_network_id ON interfaces USING btree (instance_id, network_id);


--
-- Name: index_networks_on_guid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_networks_on_guid ON networks USING btree (guid);


--
-- Name: index_networks_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_networks_on_id ON networks USING btree (id);


--
-- Name: index_networks_on_public; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_networks_on_public ON networks USING btree (public);


--
-- Name: index_orion_billing_rate_codes_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_orion_billing_rate_codes_on_account_id ON orion_billing_rate_codes USING btree (account_id);


--
-- Name: index_orion_billing_rate_codes_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_orion_billing_rate_codes_on_id ON orion_billing_rate_codes USING btree (id);


--
-- Name: index_orion_events_on_correlated_id_and_correlated_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_orion_events_on_correlated_id_and_correlated_type ON orion_events USING btree (correlated_id, correlated_type);


--
-- Name: index_orion_events_on_sequence; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_orion_events_on_sequence ON orion_events USING btree (sequence);


--
-- Name: index_orion_jobs_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_orion_jobs_on_account_id ON orion_jobs USING btree (account_id);


--
-- Name: index_orion_jobs_on_correlated_id_and_correlated_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_orion_jobs_on_correlated_id_and_correlated_type ON orion_jobs USING btree (correlated_id, correlated_type);


--
-- Name: index_orion_jobs_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_orion_jobs_on_id ON orion_jobs USING btree (id);


--
-- Name: index_orion_jobs_on_resource_id_and_resource_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_orion_jobs_on_resource_id_and_resource_type ON orion_jobs USING btree (resource_id, resource_type);


--
-- Name: index_orion_key_pairs_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_orion_key_pairs_on_account_id ON orion_key_pairs USING btree (account_id);


--
-- Name: index_orion_key_pairs_on_account_id_and_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_orion_key_pairs_on_account_id_and_name ON orion_key_pairs USING btree (account_id, name);


--
-- Name: index_orion_key_pairs_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_orion_key_pairs_on_id ON orion_key_pairs USING btree (id);


--
-- Name: index_tokens_on_token_and_secret; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tokens_on_token_and_secret ON tokens USING btree (token, secret);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON users USING btree (unlock_token);


--
-- Name: index_vnc_sessions_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vnc_sessions_on_account_id ON vnc_sessions USING btree (account_id);


--
-- Name: index_vnc_sessions_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_vnc_sessions_on_id ON vnc_sessions USING btree (id);


--
-- Name: index_vnc_sessions_on_instance_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vnc_sessions_on_instance_id ON vnc_sessions USING btree (instance_id);


--
-- Name: index_vnc_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vnc_sessions_on_user_id ON vnc_sessions USING btree (user_id);


--
-- Name: index_volumes_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_volumes_on_account_id ON volumes USING btree (account_id);


--
-- Name: index_volumes_on_guid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_volumes_on_guid ON volumes USING btree (guid);


--
-- Name: index_volumes_on_instance_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_volumes_on_instance_id ON volumes USING btree (instance_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20120130045120');

INSERT INTO schema_migrations (version) VALUES ('20120131043926');

INSERT INTO schema_migrations (version) VALUES ('20120131052422');

INSERT INTO schema_migrations (version) VALUES ('20120204084432');

INSERT INTO schema_migrations (version) VALUES ('20120204085131');

INSERT INTO schema_migrations (version) VALUES ('20120408105649');

INSERT INTO schema_migrations (version) VALUES ('20120415225359');

INSERT INTO schema_migrations (version) VALUES ('20120417062230');

INSERT INTO schema_migrations (version) VALUES ('20120418004948');

INSERT INTO schema_migrations (version) VALUES ('20120419073810');

INSERT INTO schema_migrations (version) VALUES ('20120501073743');

INSERT INTO schema_migrations (version) VALUES ('20120502034328');

INSERT INTO schema_migrations (version) VALUES ('20120502060614');

INSERT INTO schema_migrations (version) VALUES ('20120502062914');

INSERT INTO schema_migrations (version) VALUES ('20120506090417');

INSERT INTO schema_migrations (version) VALUES ('20120507004422');

INSERT INTO schema_migrations (version) VALUES ('20120507014218');

INSERT INTO schema_migrations (version) VALUES ('20120521005010');

INSERT INTO schema_migrations (version) VALUES ('20120521082241');

INSERT INTO schema_migrations (version) VALUES ('20120521090241');

INSERT INTO schema_migrations (version) VALUES ('20120604072518');

INSERT INTO schema_migrations (version) VALUES ('20120715142000');

INSERT INTO schema_migrations (version) VALUES ('20120721014828');

INSERT INTO schema_migrations (version) VALUES ('20120721081506');

INSERT INTO schema_migrations (version) VALUES ('20120722055156');

INSERT INTO schema_migrations (version) VALUES ('20120722110341');

INSERT INTO schema_migrations (version) VALUES ('20120722135243');

INSERT INTO schema_migrations (version) VALUES ('20120723063148');