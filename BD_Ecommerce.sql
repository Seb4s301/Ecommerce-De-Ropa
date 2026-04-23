--
-- PostgreSQL database dump
--

\restrict F53FlLFdWcmPCGffqpblbSECVMYkLfVcRX0dchs3o4Z1BrnQWweunNc3fC1C9lw

-- Dumped from database version 17.8 (a48d9ca)
-- Dumped by pg_dump version 18.1

-- Started on 2026-04-19 22:04:31

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 249 (class 1255 OID 57555)
-- Name: fn_control_stock(); Type: FUNCTION; Schema: public; Owner: neondb_owner
--

CREATE FUNCTION public.fn_control_stock() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    stock_actual INT;
BEGIN
    SELECT stock INTO stock_actual
    FROM DETALLE_PRODUCTO
    WHERE id_detalle_pro = NEW.id_detalle_pro;

    IF stock_actual < NEW.cantidad THEN
        RAISE EXCEPTION 'Stock insuficiente. Disponible: %, solicitado: %',
        stock_actual, NEW.cantidad;
    END IF;

    UPDATE DETALLE_PRODUCTO
    SET stock = stock - NEW.cantidad
    WHERE id_detalle_pro = NEW.id_detalle_pro;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_control_stock() OWNER TO neondb_owner;

--
-- TOC entry 250 (class 1255 OID 57557)
-- Name: fn_restore_stock(); Type: FUNCTION; Schema: public; Owner: neondb_owner
--

CREATE FUNCTION public.fn_restore_stock() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE DETALLE_PRODUCTO
    SET stock = stock + OLD.cantidad
    WHERE id_detalle_pro = OLD.id_detalle_pro;

    RETURN OLD;
END;
$$;


ALTER FUNCTION public.fn_restore_stock() OWNER TO neondb_owner;

--
-- TOC entry 251 (class 1255 OID 57559)
-- Name: fn_update_stock(); Type: FUNCTION; Schema: public; Owner: neondb_owner
--

CREATE FUNCTION public.fn_update_stock() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    diferencia INT;
    stock_actual INT;
BEGIN
    diferencia := NEW.cantidad - OLD.cantidad;

    SELECT stock INTO stock_actual
    FROM DETALLE_PRODUCTO
    WHERE id_detalle_pro = NEW.id_detalle_pro;

    IF diferencia > 0 AND stock_actual < diferencia THEN
        RAISE EXCEPTION 'Stock insuficiente para actualizar';
    END IF;

    UPDATE DETALLE_PRODUCTO
    SET stock = stock - diferencia
    WHERE id_detalle_pro = NEW.id_detalle_pro;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_update_stock() OWNER TO neondb_owner;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 232 (class 1259 OID 57433)
-- Name: carrito; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.carrito (
    id_carrito integer NOT NULL,
    id_usuario integer,
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.carrito OWNER TO neondb_owner;

--
-- TOC entry 231 (class 1259 OID 57432)
-- Name: carrito_id_carrito_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.carrito_id_carrito_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.carrito_id_carrito_seq OWNER TO neondb_owner;

--
-- TOC entry 3559 (class 0 OID 0)
-- Dependencies: 231
-- Name: carrito_id_carrito_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.carrito_id_carrito_seq OWNED BY public.carrito.id_carrito;


--
-- TOC entry 220 (class 1259 OID 57361)
-- Name: categoria; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.categoria (
    id_categoria integer NOT NULL,
    nombre character varying(50) NOT NULL
);


ALTER TABLE public.categoria OWNER TO neondb_owner;

--
-- TOC entry 219 (class 1259 OID 57360)
-- Name: categoria_id_categoria_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.categoria_id_categoria_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categoria_id_categoria_seq OWNER TO neondb_owner;

--
-- TOC entry 3560 (class 0 OID 0)
-- Dependencies: 219
-- Name: categoria_id_categoria_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.categoria_id_categoria_seq OWNED BY public.categoria.id_categoria;


--
-- TOC entry 222 (class 1259 OID 57368)
-- Name: color; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.color (
    id_color integer NOT NULL,
    nombre character varying(50) NOT NULL
);


ALTER TABLE public.color OWNER TO neondb_owner;

--
-- TOC entry 221 (class 1259 OID 57367)
-- Name: color_id_color_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.color_id_color_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.color_id_color_seq OWNER TO neondb_owner;

--
-- TOC entry 3561 (class 0 OID 0)
-- Dependencies: 221
-- Name: color_id_color_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.color_id_color_seq OWNED BY public.color.id_color;


--
-- TOC entry 234 (class 1259 OID 57448)
-- Name: detalle_carrito; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.detalle_carrito (
    id_det_carrito integer NOT NULL,
    id_carrito integer NOT NULL,
    id_detalle_pro integer NOT NULL,
    cantidad integer NOT NULL,
    CONSTRAINT detalle_carrito_cantidad_check CHECK ((cantidad > 0))
);


ALTER TABLE public.detalle_carrito OWNER TO neondb_owner;

--
-- TOC entry 233 (class 1259 OID 57447)
-- Name: detalle_carrito_id_det_carrito_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.detalle_carrito_id_det_carrito_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.detalle_carrito_id_det_carrito_seq OWNER TO neondb_owner;

--
-- TOC entry 3562 (class 0 OID 0)
-- Dependencies: 233
-- Name: detalle_carrito_id_det_carrito_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.detalle_carrito_id_det_carrito_seq OWNED BY public.detalle_carrito.id_det_carrito;


--
-- TOC entry 238 (class 1259 OID 57483)
-- Name: detalle_pedido; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.detalle_pedido (
    id_det_pedido integer NOT NULL,
    id_pedido integer NOT NULL,
    id_detalle_pro integer NOT NULL,
    cantidad integer NOT NULL,
    precio_unitario numeric(10,2) NOT NULL,
    CONSTRAINT detalle_pedido_cantidad_check CHECK ((cantidad > 0))
);


ALTER TABLE public.detalle_pedido OWNER TO neondb_owner;

--
-- TOC entry 237 (class 1259 OID 57482)
-- Name: detalle_pedido_id_det_pedido_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.detalle_pedido_id_det_pedido_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.detalle_pedido_id_det_pedido_seq OWNER TO neondb_owner;

--
-- TOC entry 3563 (class 0 OID 0)
-- Dependencies: 237
-- Name: detalle_pedido_id_det_pedido_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.detalle_pedido_id_det_pedido_seq OWNED BY public.detalle_pedido.id_det_pedido;


--
-- TOC entry 230 (class 1259 OID 57403)
-- Name: detalle_producto; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.detalle_producto (
    id_detalle_pro integer NOT NULL,
    id_inven integer NOT NULL,
    id_color integer NOT NULL,
    id_talla integer NOT NULL,
    id_modelo integer NOT NULL,
    stock integer DEFAULT 0 NOT NULL,
    precio numeric(10,2) NOT NULL
);


ALTER TABLE public.detalle_producto OWNER TO neondb_owner;

--
-- TOC entry 229 (class 1259 OID 57402)
-- Name: detalle_producto_id_detalle_pro_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.detalle_producto_id_detalle_pro_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.detalle_producto_id_detalle_pro_seq OWNER TO neondb_owner;

--
-- TOC entry 3564 (class 0 OID 0)
-- Dependencies: 229
-- Name: detalle_producto_id_detalle_pro_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.detalle_producto_id_detalle_pro_seq OWNED BY public.detalle_producto.id_detalle_pro;


--
-- TOC entry 228 (class 1259 OID 57389)
-- Name: inventario; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.inventario (
    id_inven integer NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    marca character varying(50),
    id_categoria integer
);


ALTER TABLE public.inventario OWNER TO neondb_owner;

--
-- TOC entry 227 (class 1259 OID 57388)
-- Name: inventario_id_inven_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.inventario_id_inven_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inventario_id_inven_seq OWNER TO neondb_owner;

--
-- TOC entry 3565 (class 0 OID 0)
-- Dependencies: 227
-- Name: inventario_id_inven_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.inventario_id_inven_seq OWNED BY public.inventario.id_inven;


--
-- TOC entry 226 (class 1259 OID 57382)
-- Name: modelo; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.modelo (
    id_modelo integer NOT NULL,
    nombre character varying(50) NOT NULL
);


ALTER TABLE public.modelo OWNER TO neondb_owner;

--
-- TOC entry 225 (class 1259 OID 57381)
-- Name: modelo_id_modelo_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.modelo_id_modelo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.modelo_id_modelo_seq OWNER TO neondb_owner;

--
-- TOC entry 3566 (class 0 OID 0)
-- Dependencies: 225
-- Name: modelo_id_modelo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.modelo_id_modelo_seq OWNED BY public.modelo.id_modelo;


--
-- TOC entry 240 (class 1259 OID 57501)
-- Name: pago; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.pago (
    id_pago integer NOT NULL,
    id_pedido integer,
    metodo character varying(50),
    estado character varying(20) DEFAULT 'pendiente'::character varying,
    fecha_pago timestamp without time zone
);


ALTER TABLE public.pago OWNER TO neondb_owner;

--
-- TOC entry 239 (class 1259 OID 57500)
-- Name: pago_id_pago_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.pago_id_pago_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pago_id_pago_seq OWNER TO neondb_owner;

--
-- TOC entry 3567 (class 0 OID 0)
-- Dependencies: 239
-- Name: pago_id_pago_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.pago_id_pago_seq OWNED BY public.pago.id_pago;


--
-- TOC entry 236 (class 1259 OID 57468)
-- Name: pedido; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.pedido (
    id_pedido integer NOT NULL,
    id_usuario integer,
    fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    estado character varying(20) DEFAULT 'pendiente'::character varying,
    total numeric(10,2) DEFAULT 0
);


ALTER TABLE public.pedido OWNER TO neondb_owner;

--
-- TOC entry 235 (class 1259 OID 57467)
-- Name: pedido_id_pedido_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.pedido_id_pedido_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pedido_id_pedido_seq OWNER TO neondb_owner;

--
-- TOC entry 3568 (class 0 OID 0)
-- Dependencies: 235
-- Name: pedido_id_pedido_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.pedido_id_pedido_seq OWNED BY public.pedido.id_pedido;


--
-- TOC entry 224 (class 1259 OID 57375)
-- Name: talla; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.talla (
    id_talla integer NOT NULL,
    nombre character varying(10) NOT NULL
);


ALTER TABLE public.talla OWNER TO neondb_owner;

--
-- TOC entry 223 (class 1259 OID 57374)
-- Name: talla_id_talla_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.talla_id_talla_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.talla_id_talla_seq OWNER TO neondb_owner;

--
-- TOC entry 3569 (class 0 OID 0)
-- Dependencies: 223
-- Name: talla_id_talla_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.talla_id_talla_seq OWNED BY public.talla.id_talla;


--
-- TOC entry 218 (class 1259 OID 57346)
-- Name: usuario; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.usuario (
    id_usuario integer NOT NULL,
    documento character varying(11) NOT NULL,
    nombre character varying(100) NOT NULL,
    correo character varying(100) NOT NULL,
    "contraseña" text NOT NULL,
    telefono character varying(15),
    direccion text,
    fecha_registro timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT usuario_documento_check CHECK ((length((documento)::text) = ANY (ARRAY[8, 11])))
);


ALTER TABLE public.usuario OWNER TO neondb_owner;

--
-- TOC entry 217 (class 1259 OID 57345)
-- Name: usuario_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.usuario_id_usuario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuario_id_usuario_seq OWNER TO neondb_owner;

--
-- TOC entry 3570 (class 0 OID 0)
-- Dependencies: 217
-- Name: usuario_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.usuario_id_usuario_seq OWNED BY public.usuario.id_usuario;


--
-- TOC entry 241 (class 1259 OID 57515)
-- Name: vista_carrito; Type: VIEW; Schema: public; Owner: neondb_owner
--

CREATE VIEW public.vista_carrito AS
 SELECT ca.id_carrito,
    u.id_usuario,
    u.documento,
    u.nombre AS usuario,
    dc.id_det_carrito,
    i.nombre AS producto,
    c.nombre AS color,
    t.nombre AS talla,
    m.nombre AS modelo,
    dp.precio,
    dc.cantidad,
    (dp.precio * (dc.cantidad)::numeric) AS subtotal
   FROM (((((((public.carrito ca
     JOIN public.usuario u ON ((ca.id_usuario = u.id_usuario)))
     JOIN public.detalle_carrito dc ON ((ca.id_carrito = dc.id_carrito)))
     JOIN public.detalle_producto dp ON ((dc.id_detalle_pro = dp.id_detalle_pro)))
     JOIN public.inventario i ON ((dp.id_inven = i.id_inven)))
     JOIN public.color c ON ((dp.id_color = c.id_color)))
     JOIN public.talla t ON ((dp.id_talla = t.id_talla)))
     JOIN public.modelo m ON ((dp.id_modelo = m.id_modelo)));


ALTER VIEW public.vista_carrito OWNER TO neondb_owner;

--
-- TOC entry 244 (class 1259 OID 57528)
-- Name: vista_detalle_pedido; Type: VIEW; Schema: public; Owner: neondb_owner
--

CREATE VIEW public.vista_detalle_pedido AS
 SELECT p.id_pedido,
    p.id_usuario,
    u.documento,
    i.nombre AS producto,
    c.nombre AS color,
    t.nombre AS talla,
    m.nombre AS modelo,
    dped.cantidad,
    dped.precio_unitario,
    ((dped.cantidad)::numeric * dped.precio_unitario) AS subtotal
   FROM (((((((public.pedido p
     JOIN public.usuario u ON ((p.id_usuario = u.id_usuario)))
     JOIN public.detalle_pedido dped ON ((p.id_pedido = dped.id_pedido)))
     JOIN public.detalle_producto dp ON ((dped.id_detalle_pro = dp.id_detalle_pro)))
     JOIN public.inventario i ON ((dp.id_inven = i.id_inven)))
     JOIN public.color c ON ((dp.id_color = c.id_color)))
     JOIN public.talla t ON ((dp.id_talla = t.id_talla)))
     JOIN public.modelo m ON ((dp.id_modelo = m.id_modelo)));


ALTER VIEW public.vista_detalle_pedido OWNER TO neondb_owner;

--
-- TOC entry 245 (class 1259 OID 57533)
-- Name: vista_pedido_pago; Type: VIEW; Schema: public; Owner: neondb_owner
--

CREATE VIEW public.vista_pedido_pago AS
 SELECT p.id_pedido,
    p.id_usuario,
    u.documento,
    p.total,
    p.estado AS estado_pedido,
    pa.metodo,
    pa.estado AS estado_pago,
    pa.fecha_pago
   FROM ((public.pedido p
     JOIN public.usuario u ON ((p.id_usuario = u.id_usuario)))
     LEFT JOIN public.pago pa ON ((p.id_pedido = pa.id_pedido)));


ALTER VIEW public.vista_pedido_pago OWNER TO neondb_owner;

--
-- TOC entry 243 (class 1259 OID 57524)
-- Name: vista_pedidos_usuario; Type: VIEW; Schema: public; Owner: neondb_owner
--

CREATE VIEW public.vista_pedidos_usuario AS
 SELECT p.id_pedido,
    p.id_usuario,
    u.documento,
    p.fecha,
    p.estado,
    p.total
   FROM (public.pedido p
     JOIN public.usuario u ON ((p.id_usuario = u.id_usuario)));


ALTER VIEW public.vista_pedidos_usuario OWNER TO neondb_owner;

--
-- TOC entry 248 (class 1259 OID 57547)
-- Name: vista_productos_mas_vendidos; Type: MATERIALIZED VIEW; Schema: public; Owner: neondb_owner
--

CREATE MATERIALIZED VIEW public.vista_productos_mas_vendidos AS
 SELECT i.id_inven,
    i.nombre AS producto,
    sum(dped.cantidad) AS total_vendido
   FROM ((public.detalle_pedido dped
     JOIN public.detalle_producto dp ON ((dped.id_detalle_pro = dp.id_detalle_pro)))
     JOIN public.inventario i ON ((dp.id_inven = i.id_inven)))
  GROUP BY i.id_inven, i.nombre
  ORDER BY (sum(dped.cantidad)) DESC
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.vista_productos_mas_vendidos OWNER TO neondb_owner;

--
-- TOC entry 247 (class 1259 OID 57543)
-- Name: vista_stock_bajo; Type: VIEW; Schema: public; Owner: neondb_owner
--

CREATE VIEW public.vista_stock_bajo AS
 SELECT i.nombre AS producto,
    dp.stock
   FROM (public.detalle_producto dp
     JOIN public.inventario i ON ((dp.id_inven = i.id_inven)))
  WHERE (dp.stock < 5);


ALTER VIEW public.vista_stock_bajo OWNER TO neondb_owner;

--
-- TOC entry 246 (class 1259 OID 57538)
-- Name: vista_stock_disponible; Type: VIEW; Schema: public; Owner: neondb_owner
--

CREATE VIEW public.vista_stock_disponible AS
 SELECT dp.id_detalle_pro,
    i.nombre AS producto,
    c.nombre AS color,
    t.nombre AS talla,
    m.nombre AS modelo,
    dp.stock,
    dp.precio
   FROM ((((public.detalle_producto dp
     JOIN public.inventario i ON ((dp.id_inven = i.id_inven)))
     JOIN public.color c ON ((dp.id_color = c.id_color)))
     JOIN public.talla t ON ((dp.id_talla = t.id_talla)))
     JOIN public.modelo m ON ((dp.id_modelo = m.id_modelo)))
  WHERE (dp.stock > 0);


ALTER VIEW public.vista_stock_disponible OWNER TO neondb_owner;

--
-- TOC entry 242 (class 1259 OID 57520)
-- Name: vista_total_carrito; Type: VIEW; Schema: public; Owner: neondb_owner
--

CREATE VIEW public.vista_total_carrito AS
 SELECT id_carrito,
    id_usuario,
    sum(subtotal) AS total
   FROM public.vista_carrito
  GROUP BY id_carrito, id_usuario;


ALTER VIEW public.vista_total_carrito OWNER TO neondb_owner;

--
-- TOC entry 3307 (class 2604 OID 57436)
-- Name: carrito id_carrito; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.carrito ALTER COLUMN id_carrito SET DEFAULT nextval('public.carrito_id_carrito_seq'::regclass);


--
-- TOC entry 3300 (class 2604 OID 57364)
-- Name: categoria id_categoria; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.categoria ALTER COLUMN id_categoria SET DEFAULT nextval('public.categoria_id_categoria_seq'::regclass);


--
-- TOC entry 3301 (class 2604 OID 57371)
-- Name: color id_color; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.color ALTER COLUMN id_color SET DEFAULT nextval('public.color_id_color_seq'::regclass);


--
-- TOC entry 3309 (class 2604 OID 57451)
-- Name: detalle_carrito id_det_carrito; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.detalle_carrito ALTER COLUMN id_det_carrito SET DEFAULT nextval('public.detalle_carrito_id_det_carrito_seq'::regclass);


--
-- TOC entry 3314 (class 2604 OID 57486)
-- Name: detalle_pedido id_det_pedido; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.detalle_pedido ALTER COLUMN id_det_pedido SET DEFAULT nextval('public.detalle_pedido_id_det_pedido_seq'::regclass);


--
-- TOC entry 3305 (class 2604 OID 57406)
-- Name: detalle_producto id_detalle_pro; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.detalle_producto ALTER COLUMN id_detalle_pro SET DEFAULT nextval('public.detalle_producto_id_detalle_pro_seq'::regclass);


--
-- TOC entry 3304 (class 2604 OID 57392)
-- Name: inventario id_inven; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.inventario ALTER COLUMN id_inven SET DEFAULT nextval('public.inventario_id_inven_seq'::regclass);


--
-- TOC entry 3303 (class 2604 OID 57385)
-- Name: modelo id_modelo; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.modelo ALTER COLUMN id_modelo SET DEFAULT nextval('public.modelo_id_modelo_seq'::regclass);


--
-- TOC entry 3315 (class 2604 OID 57504)
-- Name: pago id_pago; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.pago ALTER COLUMN id_pago SET DEFAULT nextval('public.pago_id_pago_seq'::regclass);


--
-- TOC entry 3310 (class 2604 OID 57471)
-- Name: pedido id_pedido; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.pedido ALTER COLUMN id_pedido SET DEFAULT nextval('public.pedido_id_pedido_seq'::regclass);


--
-- TOC entry 3302 (class 2604 OID 57378)
-- Name: talla id_talla; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.talla ALTER COLUMN id_talla SET DEFAULT nextval('public.talla_id_talla_seq'::regclass);


--
-- TOC entry 3298 (class 2604 OID 57349)
-- Name: usuario id_usuario; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id_usuario SET DEFAULT nextval('public.usuario_id_usuario_seq'::regclass);


--
-- TOC entry 3544 (class 0 OID 57433)
-- Dependencies: 232
-- Data for Name: carrito; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.carrito (id_carrito, id_usuario, fecha_creacion) FROM stdin;
1	1	2026-04-20 02:53:00.495858
2	2	2026-04-20 02:53:00.495858
\.


--
-- TOC entry 3532 (class 0 OID 57361)
-- Dependencies: 220
-- Data for Name: categoria; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.categoria (id_categoria, nombre) FROM stdin;
1	Masculino
2	Femenino
\.


--
-- TOC entry 3534 (class 0 OID 57368)
-- Dependencies: 222
-- Data for Name: color; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.color (id_color, nombre) FROM stdin;
1	Rojo
2	Verde
3	Amarillo
4	Azul
5	Anaranjado
6	Rosa
7	Negro
8	Blanco
9	Gris
10	Violeta
\.


--
-- TOC entry 3546 (class 0 OID 57448)
-- Dependencies: 234
-- Data for Name: detalle_carrito; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.detalle_carrito (id_det_carrito, id_carrito, id_detalle_pro, cantidad) FROM stdin;
1	1	1	2
2	1	4	1
3	2	3	1
\.


--
-- TOC entry 3550 (class 0 OID 57483)
-- Dependencies: 238
-- Data for Name: detalle_pedido; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.detalle_pedido (id_det_pedido, id_pedido, id_detalle_pro, cantidad, precio_unitario) FROM stdin;
1	1	2	2	45.50
2	2	3	1	299.00
\.


--
-- TOC entry 3542 (class 0 OID 57403)
-- Dependencies: 230
-- Data for Name: detalle_producto; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.detalle_producto (id_detalle_pro, id_inven, id_color, id_talla, id_modelo, stock, precio) FROM stdin;
1	4	2	2	1	25	95.00
4	1	1	1	1	10	85.00
2	5	7	3	3	38	45.50
3	6	1	2	2	14	299.00
\.


--
-- TOC entry 3540 (class 0 OID 57389)
-- Dependencies: 228
-- Data for Name: inventario; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.inventario (id_inven, nombre, descripcion, marca, id_categoria) FROM stdin;
1	Camisa Hoodie Urban	Polera con capucha y bolsillo canguro	UrbanStyle	1
2	Jean Clasico	Denim resistente azul oscuro	Levis	2
3	Pantalón Jogger Fit	Pantalón deportivo con ajuste en tobillos	Nike	2
4	Camisa Formal	Algodón pima extra suave	ModaIng	1
5	Pantalón Ejecutivo	Saco y pantalón de lana fina	Pierre Cardin	2
6	Blusa con Estampado	Algodón 100% con diseño infantil	BabyStyle	1
7	Jeans con Elástico	Denim suave para mayor movilidad	BabyStyle	2
\.


--
-- TOC entry 3538 (class 0 OID 57382)
-- Dependencies: 226
-- Data for Name: modelo; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.modelo (id_modelo, nombre) FROM stdin;
1	Camisa
2	Blusa
3	Pantalon
\.


--
-- TOC entry 3552 (class 0 OID 57501)
-- Dependencies: 240
-- Data for Name: pago; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.pago (id_pago, id_pedido, metodo, estado, fecha_pago) FROM stdin;
1	1	Yape	pendiente	\N
2	2	Tarjeta de Crédito	aprobado	2026-04-20 02:53:14.978801
\.


--
-- TOC entry 3548 (class 0 OID 57468)
-- Dependencies: 236
-- Data for Name: pedido; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.pedido (id_pedido, id_usuario, fecha, estado, total) FROM stdin;
1	3	2026-04-20 02:53:07.801934	pendiente	91.00
2	4	2026-04-20 02:53:07.801934	completado	299.00
\.


--
-- TOC entry 3536 (class 0 OID 57375)
-- Dependencies: 224
-- Data for Name: talla; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.talla (id_talla, nombre) FROM stdin;
1	S
2	M
3	L
4	XL
\.


--
-- TOC entry 3530 (class 0 OID 57346)
-- Dependencies: 218
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.usuario (id_usuario, documento, nombre, correo, "contraseña", telefono, direccion, fecha_registro) FROM stdin;
1	71231567	Renato Solis	rena@email.com	rena123	987654321	Av. Sistemas 123	2026-04-20 02:52:42.824789
2	10567891	Ariana Sotillo 	aria@email.com	ari123	912345678	Calle Lima 456	2026-04-20 02:52:42.824789
3	72357678	Maria Garcia	maria@email.com	maria123	923456789	Jr. Arequipa 789	2026-04-20 02:52:42.824789
4	73446789	Sebastián Casavilca	sebas@email.com	sebas123	934567890	Av. Larco 101	2026-04-20 02:52:42.824789
5	74573890	Yummy Lucero	yummy@email.com	yum123	945678901	Calle Cusco 202	2026-04-20 02:52:42.824789
6	10784256	Luis Torres	luis@email.com	luis123	956789012	Av. Tacna 303	2026-04-20 02:52:42.824789
7	75674801	Elena Paz	elena@email.com	elena123	967890123	Jr. Trujillo 404	2026-04-20 02:52:42.824789
8	76789412	Diego Meza	diego@email.com	diego123	978901234	Av. Brasil 505	2026-04-20 02:52:42.824789
9	78901323	Sofia Vega	sofia@email.com	sofia123	989012345	Calle Ica 606	2026-04-20 02:52:42.824789
10	78901334	Jorge Luna	jorge@email.com	jorge123	990123456	Av. Puno 707	2026-04-20 02:52:42.824789
\.


--
-- TOC entry 3571 (class 0 OID 0)
-- Dependencies: 231
-- Name: carrito_id_carrito_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.carrito_id_carrito_seq', 2, true);


--
-- TOC entry 3572 (class 0 OID 0)
-- Dependencies: 219
-- Name: categoria_id_categoria_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.categoria_id_categoria_seq', 2, true);


--
-- TOC entry 3573 (class 0 OID 0)
-- Dependencies: 221
-- Name: color_id_color_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.color_id_color_seq', 10, true);


--
-- TOC entry 3574 (class 0 OID 0)
-- Dependencies: 233
-- Name: detalle_carrito_id_det_carrito_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.detalle_carrito_id_det_carrito_seq', 3, true);


--
-- TOC entry 3575 (class 0 OID 0)
-- Dependencies: 237
-- Name: detalle_pedido_id_det_pedido_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.detalle_pedido_id_det_pedido_seq', 2, true);


--
-- TOC entry 3576 (class 0 OID 0)
-- Dependencies: 229
-- Name: detalle_producto_id_detalle_pro_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.detalle_producto_id_detalle_pro_seq', 4, true);


--
-- TOC entry 3577 (class 0 OID 0)
-- Dependencies: 227
-- Name: inventario_id_inven_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.inventario_id_inven_seq', 7, true);


--
-- TOC entry 3578 (class 0 OID 0)
-- Dependencies: 225
-- Name: modelo_id_modelo_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.modelo_id_modelo_seq', 3, true);


--
-- TOC entry 3579 (class 0 OID 0)
-- Dependencies: 239
-- Name: pago_id_pago_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.pago_id_pago_seq', 2, true);


--
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 235
-- Name: pedido_id_pedido_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.pedido_id_pedido_seq', 2, true);


--
-- TOC entry 3581 (class 0 OID 0)
-- Dependencies: 223
-- Name: talla_id_talla_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.talla_id_talla_seq', 4, true);


--
-- TOC entry 3582 (class 0 OID 0)
-- Dependencies: 217
-- Name: usuario_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.usuario_id_usuario_seq', 10, true);


--
-- TOC entry 3344 (class 2606 OID 57441)
-- Name: carrito carrito_id_usuario_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.carrito
    ADD CONSTRAINT carrito_id_usuario_key UNIQUE (id_usuario);


--
-- TOC entry 3346 (class 2606 OID 57439)
-- Name: carrito carrito_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.carrito
    ADD CONSTRAINT carrito_pkey PRIMARY KEY (id_carrito);


--
-- TOC entry 3328 (class 2606 OID 57366)
-- Name: categoria categoria_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (id_categoria);


--
-- TOC entry 3330 (class 2606 OID 57373)
-- Name: color color_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.color
    ADD CONSTRAINT color_pkey PRIMARY KEY (id_color);


--
-- TOC entry 3349 (class 2606 OID 57456)
-- Name: detalle_carrito detalle_carrito_id_carrito_id_detalle_pro_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.detalle_carrito
    ADD CONSTRAINT detalle_carrito_id_carrito_id_detalle_pro_key UNIQUE (id_carrito, id_detalle_pro);


--
-- TOC entry 3351 (class 2606 OID 57454)
-- Name: detalle_carrito detalle_carrito_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.detalle_carrito
    ADD CONSTRAINT detalle_carrito_pkey PRIMARY KEY (id_det_carrito);


--
-- TOC entry 3356 (class 2606 OID 57489)
-- Name: detalle_pedido detalle_pedido_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.detalle_pedido
    ADD CONSTRAINT detalle_pedido_pkey PRIMARY KEY (id_det_pedido);


--
-- TOC entry 3339 (class 2606 OID 57411)
-- Name: detalle_producto detalle_producto_id_inven_id_color_id_talla_id_modelo_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.detalle_producto
    ADD CONSTRAINT detalle_producto_id_inven_id_color_id_talla_id_modelo_key UNIQUE (id_inven, id_color, id_talla, id_modelo);


--
-- TOC entry 3341 (class 2606 OID 57409)
-- Name: detalle_producto detalle_producto_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.detalle_producto
    ADD CONSTRAINT detalle_producto_pkey PRIMARY KEY (id_detalle_pro);


--
-- TOC entry 3337 (class 2606 OID 57396)
-- Name: inventario inventario_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.inventario
    ADD CONSTRAINT inventario_pkey PRIMARY KEY (id_inven);


--
-- TOC entry 3334 (class 2606 OID 57387)
-- Name: modelo modelo_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.modelo
    ADD CONSTRAINT modelo_pkey PRIMARY KEY (id_modelo);


--
-- TOC entry 3358 (class 2606 OID 57509)
-- Name: pago pago_id_pedido_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_id_pedido_key UNIQUE (id_pedido);


--
-- TOC entry 3360 (class 2606 OID 57507)
-- Name: pago pago_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_pkey PRIMARY KEY (id_pago);


--
-- TOC entry 3354 (class 2606 OID 57476)
-- Name: pedido pedido_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.pedido
    ADD CONSTRAINT pedido_pkey PRIMARY KEY (id_pedido);


--
-- TOC entry 3332 (class 2606 OID 57380)
-- Name: talla talla_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.talla
    ADD CONSTRAINT talla_pkey PRIMARY KEY (id_talla);


--
-- TOC entry 3322 (class 2606 OID 57359)
-- Name: usuario usuario_correo_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_correo_key UNIQUE (correo);


--
-- TOC entry 3324 (class 2606 OID 57357)
-- Name: usuario usuario_documento_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_documento_key UNIQUE (documento);


--
-- TOC entry 3326 (class 2606 OID 57355)
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 3347 (class 1259 OID 57564)
-- Name: idx_carrito_usuario; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_carrito_usuario ON public.carrito USING btree (id_usuario);


--
-- TOC entry 3342 (class 1259 OID 57563)
-- Name: idx_detalle_producto_inven; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_detalle_producto_inven ON public.detalle_producto USING btree (id_inven);


--
-- TOC entry 3335 (class 1259 OID 57562)
-- Name: idx_inventario_categoria; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_inventario_categoria ON public.inventario USING btree (id_categoria);


--
-- TOC entry 3352 (class 1259 OID 57565)
-- Name: idx_pedido_usuario; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_pedido_usuario ON public.pedido USING btree (id_usuario);


--
-- TOC entry 3320 (class 1259 OID 57561)
-- Name: idx_usuario_correo; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_usuario_correo ON public.usuario USING btree (correo);


--
-- TOC entry 3373 (class 2620 OID 57556)
-- Name: detalle_pedido trg_control_stock; Type: TRIGGER; Schema: public; Owner: neondb_owner
--

CREATE TRIGGER trg_control_stock BEFORE INSERT ON public.detalle_pedido FOR EACH ROW EXECUTE FUNCTION public.fn_control_stock();


--
-- TOC entry 3374 (class 2620 OID 57558)
-- Name: detalle_pedido trg_restore_stock; Type: TRIGGER; Schema: public; Owner: neondb_owner
--

CREATE TRIGGER trg_restore_stock AFTER DELETE ON public.detalle_pedido FOR EACH ROW EXECUTE FUNCTION public.fn_restore_stock();


--
-- TOC entry 3375 (class 2620 OID 57560)
-- Name: detalle_pedido trg_update_stock; Type: TRIGGER; Schema: public; Owner: neondb_owner
--

CREATE TRIGGER trg_update_stock BEFORE UPDATE ON public.detalle_pedido FOR EACH ROW EXECUTE FUNCTION public.fn_update_stock();


--
-- TOC entry 3366 (class 2606 OID 57442)
-- Name: carrito carrito_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.carrito
    ADD CONSTRAINT carrito_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 3367 (class 2606 OID 57457)
-- Name: detalle_carrito detalle_carrito_id_carrito_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.detalle_carrito
    ADD CONSTRAINT detalle_carrito_id_carrito_fkey FOREIGN KEY (id_carrito) REFERENCES public.carrito(id_carrito) ON DELETE CASCADE;


--
-- TOC entry 3368 (class 2606 OID 57462)
-- Name: detalle_carrito detalle_carrito_id_detalle_pro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.detalle_carrito
    ADD CONSTRAINT detalle_carrito_id_detalle_pro_fkey FOREIGN KEY (id_detalle_pro) REFERENCES public.detalle_producto(id_detalle_pro);


--
-- TOC entry 3370 (class 2606 OID 57495)
-- Name: detalle_pedido detalle_pedido_id_detalle_pro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.detalle_pedido
    ADD CONSTRAINT detalle_pedido_id_detalle_pro_fkey FOREIGN KEY (id_detalle_pro) REFERENCES public.detalle_producto(id_detalle_pro);


--
-- TOC entry 3371 (class 2606 OID 57490)
-- Name: detalle_pedido detalle_pedido_id_pedido_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.detalle_pedido
    ADD CONSTRAINT detalle_pedido_id_pedido_fkey FOREIGN KEY (id_pedido) REFERENCES public.pedido(id_pedido) ON DELETE CASCADE;


--
-- TOC entry 3362 (class 2606 OID 57417)
-- Name: detalle_producto detalle_producto_id_color_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.detalle_producto
    ADD CONSTRAINT detalle_producto_id_color_fkey FOREIGN KEY (id_color) REFERENCES public.color(id_color);


--
-- TOC entry 3363 (class 2606 OID 57412)
-- Name: detalle_producto detalle_producto_id_inven_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.detalle_producto
    ADD CONSTRAINT detalle_producto_id_inven_fkey FOREIGN KEY (id_inven) REFERENCES public.inventario(id_inven);


--
-- TOC entry 3364 (class 2606 OID 57427)
-- Name: detalle_producto detalle_producto_id_modelo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.detalle_producto
    ADD CONSTRAINT detalle_producto_id_modelo_fkey FOREIGN KEY (id_modelo) REFERENCES public.modelo(id_modelo);


--
-- TOC entry 3365 (class 2606 OID 57422)
-- Name: detalle_producto detalle_producto_id_talla_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.detalle_producto
    ADD CONSTRAINT detalle_producto_id_talla_fkey FOREIGN KEY (id_talla) REFERENCES public.talla(id_talla);


--
-- TOC entry 3361 (class 2606 OID 57397)
-- Name: inventario inventario_id_categoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.inventario
    ADD CONSTRAINT inventario_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES public.categoria(id_categoria);


--
-- TOC entry 3372 (class 2606 OID 57510)
-- Name: pago pago_id_pedido_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.pago
    ADD CONSTRAINT pago_id_pedido_fkey FOREIGN KEY (id_pedido) REFERENCES public.pedido(id_pedido);


--
-- TOC entry 3369 (class 2606 OID 57477)
-- Name: pedido pedido_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.pedido
    ADD CONSTRAINT pedido_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- TOC entry 3553 (class 0 OID 57547)
-- Dependencies: 248 3555
-- Name: vista_productos_mas_vendidos; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: neondb_owner
--

REFRESH MATERIALIZED VIEW public.vista_productos_mas_vendidos;


-- Completed on 2026-04-19 22:04:51

--
-- PostgreSQL database dump complete
--

\unrestrict F53FlLFdWcmPCGffqpblbSECVMYkLfVcRX0dchs3o4Z1BrnQWweunNc3fC1C9lw

