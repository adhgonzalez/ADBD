# Modelo E/R: Tajinaste S.A.
**Autor**: Adrián David Hernández González

## 1. Entidades
* **VIVERO**: Centros físicos de la empresa.
* **ZONA**: Áreas dentro de un vivero (representada en el diagrama como entidad débil con doble recuadro).
* **PRODUCTO**: Artículos disponibles en el catálogo.
* **EMPLEADO**: Personal de la empresa.
* **CLIENTE_PLUS**: Socios del programa de fidelización.
* **PEDIDO**: Compras registradas en el sistema.

---

## 2. Atributos
* **VIVERO**: `id_vivero`, `nombre`, `longitud`, `latitud`.
* **ZONA**: `id_zona`, `id_vivero`, `nombre_zona`, `longitud`, `latitud`.
* **PRODUCTO**: `id_producto`, `nombre_producto`, `categoria`, `precio`.
* **EMPLEADO**: `dni_empleado`, `nombre`, `telefono`.
* **CLIENTE_PLUS**: `dni_cliente`, `fecha_ingreso`, `nombre`, `volumen_mensual`, `bonificaciones`.
* **PEDIDO**: `id_pedido`, `fecha_compra`, `importe_total`.

---

## 3. Relaciones y Cardinalidad
* **VIVERO (1) -- < Tiene > -- (M) ZONA**: 1 vivero tiene múltiples (M) zonas asociadas.
* **ZONA (N) -- < Almacena > -- (M) PRODUCTO**: Varias (N) zonas pueden almacenar múltiples (M) productos.
* **EMPLEADO (M) -- < trabaja > -- (N) ZONA**: Varios (M) empleados son destinados a diferentes (N) zonas.
* **EMPLEADO (1) -- < gestiona > -- (N) PEDIDO**: 1 empleado es responsable de gestionar múltiples (N) pedidos.
* **CLIENTE_PLUS (1) -- < realiza > -- (N) PEDIDO**: 1 cliente del programa realiza múltiples (N) pedidos.
* **PRODUCTO (N) -- < gestiona > -- (M) PEDIDO**: Varios (N) productos se vinculan o incluyen en múltiples (M) pedidos.

---

## 4. Notas sobre el diagrama final
* **Dependencia de ZONA**: Está correctamente modelada como entidad débil (doble recuadro) e incluye el atributo `id_vivero` directo en la entidad para conectarla a su centro.
* **Atributos en relaciones**: El diagrama prioriza una vista puramente estructural, por lo que omite colocar los atributos variables sobre los rombos (como el stock en `< Almacena >` o las fechas del histórico en `< trabaja >`).
