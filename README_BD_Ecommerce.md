# README BASE DE DATOS – PostgreSQL

## Sistema de Gestión E-Commerce de Ropa

---

## Descripción General

Esta base de datos permite gestionar el pago, el pedido y su funcionamiento en la selección de ropa del usuario. Esto optimiza el proceso de compra y gestión de pedidos.

---

## Objetivos

### Objetivo General

Desarrollar una base de datos estructurada que permita realizar operaciones de un sistema E-Commerce de ropa.

### Objetivos Específicos

- Gestionar productos con múltiples atributos
- Registrar y controlar clientes
- Controlar el inventario automáticamente
- Gestionar registro de los pagos

---

## Herramientas Utilizadas

- PostgreSQL
- PL/pgSQL

---

## Diseño de la Base de Datos

El modelo implementado separa la información de los productos en dos niveles:

- **Inventario**: Almacena la información general del producto
- **Detalle de producto**: Gestiona las variantes específicas (color, talla, modelo, stock y precio)

Este enfoque permite evitar redundancia de datos y facilita la escalabilidad del sistema.

### Estructura de las Entidades

**Usuario**  
Almacena la información personal de los clientes registrados en el sistema.

**Productos**

- Inventario: Información general del producto base
- Detalle_Producto: Variantes específicas (combinaciones de talla, color, modelo)

**Clasificación de los Productos**

- Categoría
- Color
- Talla
- Modelo

**Proceso de Compras**

- Carrito / Detalle_Carrito
- Pedido / Detalle_Pedido
- Pago

---

## Relaciones

| Relación | Tipo |
|----------|------|
| USUARIO | (1) --- (1) CARRITO |
| USUARIO | (1) --- (N) PEDIDO |
| CATEGORIA | (1) --- (N) INVENTARIO |
| INVENTARIO | (1) --- (N) DETALLE_PRODUCTO |
| COLOR | (1) --- (N) DETALLE_PRODUCTO |
| TALLA | (1) --- (N) DETALLE_PRODUCTO |
| MODELO | (1) --- (N) DETALLE_PRODUCTO |
| CARRITO | (1) --- (N) DETALLE_CARRITO |
| DETALLE_CARRITO | (N) --- (1) DETALLE_PRODUCTO |
| PEDIDO | (1) --- (N) DETALLE_PEDIDO |
| DETALLE_PEDIDO | (N) --- (1) DETALLE_PRODUCTO |
| PEDIDO | (1) --- (1) PAGO |

---

## Diagrama Entidad-Relación

![Diagrama ER](Diagrama.jpeg)

---

## Lógica del Sistema

### Control de Inventario (Automatizado)

Se implementan 3 triggers para garantizar consistencia en la tabla Detalle_Pedido:

- **BEFORE INSERT en pedido**: 
- valida stock disponible  - Si hay stock suficiente, descuenta
- **AFTER DELETE en pedido**: 
- repone stock al eliminar un detalle de pedido
- **BEFORE UPDATE en pedido**: 
- Validad que el stock sea suficiente si la diferencia es positiva 
- Ajusta el stock restando la diferencia

**Ventajas:**

- Evita ventas sin stock
- Mantiene integridad de datos

---

## Optimización y Consultas

### Vistas implementadas

Permiten simplificar consultas complejas:

| Vista | Descripción |
|-------|-------------|
| vista_carrito | detalle completo del carrito |
| vista_total_carrito | total acumulado |
| vista_pedidos_usuario | historial de compras |
| vista_detalle_pedido | detalle de productos comprados |
| vista_pedido_pago | estado de pedidos y pagos |
| vista_stock_disponible | productos en stock |
| vista_stock_bajo | alerta de inventario crítico |

### Vista Materializada

**vista_productos_mas_vendidos**: permite analizar los productos con mayor demanda

---

## Instalación y Ejecución

**1. Crear esquema:**

```sql
CREATE SCHEMA eCommerce;
```
**2. Seleccionar esquema:**
```sql
SET search_path TO eCommerce;
```
**3. Ejemplo de consultas:**
```sql
SELECT * FROM vista_stock_disponible;
SELECT * FROM vista_total_carrito;
SELECT * FROM vista_pedidos_usuario WHERE id_usuario = 1;
```


  




