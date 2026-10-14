# Práctica 4. Modelo Relacional - Viveros.
**Autor:** Adrián David Hernández González


## Resumen de atributos calculables en la base de datos viveros

*Este documento resume los atributos del esquema que pueden obtenerse calculando otros datos almacenados. Que un atributo sea calculable no significa necesariamente que deba eliminarse de la tabla: depende de los requisitos del enunciado y de si se necesita guardar un valor histórico.*
## 1. Tabla `pedido`

- **Atributo:** `importe_total`
- **Se calcula a partir de:** `detalle_pedido.cantidad` y `detalle_pedido.precio_unitario`.
- **Cálculo:** sumar, para todas las líneas del pedido, `cantidad * precio_unitario`.
- **Fórmula conceptual:**

  `importe_total = SUM(cantidad * precio_unitario)`

- **Observación:** si se guarda el total en `pedido`, debe mantenerse coherente con los detalles. Si se calcula al consultar, puede obtenerse mediante una consulta o una vista.

## 2. Tabla `cliente`

- **Atributo:** `volumen_mensual`
- **Se calcula a partir de:** los pedidos del cliente (`pedido`) y sus importes o líneas de detalle (`detalle_pedido`).
- **Cálculo:** sumar el importe de las compras del cliente dentro del mes correspondiente.
- **Fórmula conceptual:**

  `volumen_mensual = SUM(importe de los pedidos del cliente durante ese mes)`

- **Observación:** el volumen depende del periodo consultado, por lo que un único campo `volumen_mensual` en `cliente` no conserva por sí solo el histórico de todos los meses. Puede calcularse con una consulta/vista o almacenarse en una tabla histórica por cliente, año y mes.

## 3. Tabla `cliente_bonificacion`

- **Dato que puede determinarse:** `id_bonificacion`, comparando el volumen mensual del cliente con los umbrales definidos en `bonificacion.volumen_minimo`.
- **Se calcula a partir de:** el volumen mensual de compras del cliente y los niveles de bonificación disponibles.
- **Observación:** en el esquema actual, `id_bonificacion` se almacena en `cliente_bonificacion` para registrar qué bonificación se asignó a cada cliente en cada mes. Si la bonificación se determina automáticamente por reglas de umbral, puede derivarse del volumen mensual; si se desea conservar la bonificación realmente aplicada en el pasado, es razonable guardar la asignación como histórico.

## 4. Datos que no son calculables por sí solos en el esquema actual

- `stock_zona_producto.cantidad`: es la cantidad de unidades existentes en una zona; normalmente se registra o actualiza con operaciones de inventario.
- `detalle_pedido.cantidad`: es la cantidad de unidades compradas en una línea de pedido.
- `detalle_pedido.precio_unitario`: es el precio aplicado a esa línea en el momento de la compra; conviene guardarlo para conservar el histórico aunque cambie `producto.precio`.

## Resumen 

| Tabla | Atributo | ¿Calculable? | Datos necesarios |
|---|---|---|---|
| `pedido` | `importe_total` | Sí | Cantidad y precio unitario de cada línea en `detalle_pedido` |
| `cliente` | `volumen_mensual` | Sí | Pedidos del cliente y sus importes/detalles, filtrados por mes |
| `cliente_bonificacion` | `id_bonificacion` | Puede determinarse por reglas | Volumen mensual y umbrales de `bonificacion` |


