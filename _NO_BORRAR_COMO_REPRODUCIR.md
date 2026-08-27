# Cómo reproducir el Reporte Ejecutivo — Notaría 31 Querétaro

> **Punto de restauración vigente:** `_NO_BORRAR_template_BACKUP_21-05-2026.html`  
> **Última actualización de esta guía:** 2026-05-21

> **IMPORTANTE:** Los archivos con prefijo `_NO_BORRAR_` son el corazón del sistema. No eliminarlos ni renombrarlos.

---

## Archivos del proyecto y su función

| Archivo | Función | ¿Indispensable? |
|---|---|---|
| `_NO_BORRAR_template.html` | Plantilla maestra del reporte (HTML + JS + CSS). Toda la lógica visual vive aquí. | ✅ SÍ |
| `_NO_BORRAR_build_report_mayo2026.py` | Script Python que lee la bitácora xlsx, procesa los datos y los inyecta en el template para generar el reporte HTML. | ✅ SÍ |
| `_NO_BORRAR_label_streaming.py` | Script Python que etiqueta la bitácora (columnas Estatus y Trámite) antes de generar el reporte. | ✅ SÍ |
| `Bitacora.xlsx` | Bitácora activa descargada de Integranot. Se reemplaza con cada nueva descarga. | ✅ SÍ (datos) |
| `TENDENCIA.xlsx` | Datos históricos 2015-2025 de escrituras por abogado. **Ya hardcodeados en el build script** — este archivo es solo referencia; no se usa en runtime. | ⚠️ Referencia |
| `Reporte_Ejecutivo_Mayo2026.html` | Reporte generado (output). Se puede eliminar y regenerar en segundos. | ❌ Regenerable |
| `_NO_BORRAR_template_BACKUP_13-05-2026.html` | Backup pre-rediseño de tablas. | ⚠️ Seguridad |
| `_NO_BORRAR_template_BACKUP_16-05-2026.html` | Backup con EXPEDIENTES + sync GitHub + secciones colapsables. | ⚠️ Seguridad |
| `_NO_BORRAR_template_BACKUP_19-05-2026.html` | Backup con fixes de tabs PUNTOS CRÍTICOS. | ⚠️ Seguridad |
| `_NO_BORRAR_template_BACKUP_21-05-2026.html` | **⭐ Punto de restauración actual (2026-05-21).** | ✅ VIGENTE |

---

## Flujo completo para generar un reporte nuevo

### Paso 1 — Descargar la bitácora desde Integranot
1. Entrar a Integranot (requiere red de oficina): `https://integranot.qroo.gob.mx` o la URL interna.
2. Ir a Reportes → Bitácora → exportar como `.xlsx`.
3. Guardar el archivo en la carpeta del proyecto como `Bitacora.xlsx` (sin acento, sin espacios).

### Paso 2 — Etiquetar la bitácora
La bitácora descargada llega **sin etiquetas** en las columnas Estatus y Trámite. Hay que ejecutar:

```bash
python3 "_NO_BORRAR_label_streaming.py" "Bitacora.xlsx"
```

O desde Claude (Cowork):
> "Etiqueta la bitácora"

El script:
- Crea un respaldo `.bak` automáticamente antes de tocar el original.
- Aplica las reglas de etiquetado (traslativas, no traslativas, subetiquetas).
- Normaliza `COO → LBR`. Ignora `J31`.
- Solo etiqueta filas con Estatus vacío (no sobreescribe).
- Re-evalúa CONCLUIDO / FALTA FINALIZAR / FALTA RPP / FALTA SIGER / FALTA TD / FALTA CIERRE.

### Paso 3 — Generar el reporte HTML
```bash
python3 "_NO_BORRAR_build_report_mayo2026.py"
```

O desde Claude (Cowork):
> "Genera el reporte"

El script:
- Lee `Bitacora.xlsx` con openpyxl (read_only).
- Calcula KPIs, segmentos, alertas, tendencia histórica.
- Inyecta los datos como JSON en `_NO_BORRAR_template.html`.
- Guarda el resultado como `Reporte_Ejecutivo_Mayo2026.html`.
- La fecha de referencia (REF) = ayer en hora CDT (UTC-5, Querétaro).

### Paso 4 — Abrir el reporte
Abrir `Reporte_Ejecutivo_Mayo2026.html` directamente en el navegador. No requiere servidor.

---

## Generar reporte para una bitácora diferente (sin modificar el script)

Usar el patrón **exec-with-patches** desde Claude:

```python
import glob as _glob

_vm = _glob.glob("/sessions/*/mnt/Bitácoras Notaría 31")
_base = _vm[0]
with open(f"{_base}/_NO_BORRAR_build_report_mayo2026.py") as f:
    src = f.read()

# Parchear rutas
src = src.replace('SRC = f"{_BASE}/Bitacora.xlsx"',
                  'SRC = "/ruta/a/MiBitacora.xlsx"')
src = src.replace('OUT = f"{_BASE}/Reporte_Ejecutivo_Mayo2026.html"',
                  'OUT = "/ruta/de/salida/MiReporte.html"')
src = src.replace('TPL = f"{_BASE}/_NO_BORRAR_template.html"',
                  f'TPL = "{_base}/_NO_BORRAR_template.html"')

exec(compile(src, '<build-patch>', 'exec'))
```

---

## Columnas clave de Bitacora.xlsx

Las columnas que el build script y el label script leen son:

**Identificación:** Escritura, Expediente, Estatus, Tramite, Abogado, Operación, Municipio

**Partes:** Enajenante/Vendedor, Acreedor

**Fechas clave:** Fech. Esc., Lleva TD

**Traslado de Dominio (TD):**  
TD. Digitalización Pago TD, TD. Pago, TD. Elab. Formato y/o Carga portal

**RPP:**  
RPP. Entrada a RPP Testimonio, RPP. Digitalización Entrada RPP,  
RPP. Regreso de RPP Testimonio, RPP. Captura Dato Inscripción RPP,  
RPP. Solicitud, RPP. Pago RPP, RPP. Digitalización Pago RPP

**Catastro:**  
CAT. Solicitud, CAT. Dig Notificacion Catastral, CAT. Digitalización Entrada a Cat.

**Cierre y entrega:**  
ESC. Entrega Firmas Completas, CIERRE. Expedición de Testimonio,  
ENT. Testimonio Digitalizado, ENT. Entrega Test a Financiero, ENT. Test. a Recepción,  
MDC. Entrega Exp Unidad Gestión

**Bancos:**  
BANCOS. Dig. Acuse de Recibo Banco,  
INFONAVIT. Dig. Acuse de Recibo INFONAVIT,  
FOVISSSTE. Dig. Acuse de Recibo FOVISSSTE

---

## Estatus válidos

| Estatus | Descripción |
|---|---|
| CONCLUIDO | Escritura completamente terminada |
| FALTA FINALIZAR | Concluida pero tiene sub-pasos pendientes (NOTIF CAT, DIGITALIZAR, CONCILIAR, ENVIAR) |
| FALTA RPP | Pendiente de ingresar al Registro Público |
| EN RPP | Ingresada al RPP, esperando resolución |
| FALTA SIGER | Pendiente en sistema SIGER/RPC |
| FALTA TD | Pendiente de pago de Traslado de Dominio |
| FALTA CIERRE | Pendiente de expedición de testimonio (sub: PASAR / FOLIO / ARMADO) |

---

## Abogados registrados

`ACM, AGB, ATM, EAC, GGR, GMB, JCL, JLGP, KST, LBR, LSR, MSR`

Alias: `COO → LBR` (normalizado automáticamente). `J31` → ignorado.

---

## Umbrales de alerta

| Alerta | Condición |
|---|---|
| TD Vencido | > 15 días hábiles sin Pago TD (traslativas) |
| TD Por Vencer | 9–14 días hábiles sin Pago TD |
| Folios >60 | > 60 días sin Entrega Firmas Completas |
| Entrada RPP >45 | > 45 días sin entrada a RPP (no EN RPP, sin acuse banco/info/fovi) |
| Inscripción RPP >90 | > 90 días traslativas / > 30 días no traslativas sin retorno RPP |
| Bancos >150 | > 150 días con banco sin retorno RPP |
| Infonavit >150 | > 150 días con Infonavit sin retorno RPP |
| Fovissste >150 | > 150 días con Fovissste sin retorno RPP |

---

## Dependencias Python

```
openpyxl   — leer/escribir .xlsx
```
Instalar si falta: `pip install openpyxl --break-system-packages`

Todo lo demás (`json, re, time, shutil, glob, datetime, collections`) es biblioteca estándar de Python 3.

---

## Flujo Bitácora General (bitácora ya etiquetada)

Cuando la bitácora llega **ya etiquetada** (ej. Bitácora General de coordinadora):

1. Guardar el archivo en `~/Downloads` como `Bitacora.xlsx` (sin acento, sin espacios).
2. Saltar el paso de etiquetado (Paso 2).
3. Usar el patrón **exec-with-patches** con SRC apuntando a Downloads y OUT al nombre deseado.

---

## GitHub — sync de comentarios y expedientes

El reporte de coordinadora puede sincronizar comentarios y tabla de EXPEDIENTES via GitHub:

- **Repositorio:** `notariapublica31qro/bitacora-general` (privado)
- **Token:** configurar en el reporte → botón ⚙ → pegar token → Guardar
- **Token actual:** `<TOKEN_REDACTADO>` (sin vencimiento, creado 2026-05-16)
- **Archivos sincronizados:** `comments.json` (comentarios) + `expedientes.json` (tabla EXPEDIENTES)
- **Repos de abogados:** `bitacora-{iniciales}` bajo la misma cuenta (GGR, MSR, LSR, KST, JCL, GMB, EAC, ATM)

---

## Funcionalidades del reporte (estado 2026-05-21)

| Función | Estado |
|---|---|
| KPIs (Escrituras / Concluidas / Pendientes / Puntos Críticos) | ✅ |
| Segmentos (Constructoras / Bancos / Infonavit / Fovissste / Foráneas) | ✅ |
| Gráficas: Pastel por estatus, Barras por abogado, Tendencia histórica | ✅ |
| ESCRITURAS: 11 botones segmento + filtro etapa×abogado | ✅ |
| ESCRITURAS: Export CSV + PDF (jsPDF) | ✅ |
| PUNTOS CRÍTICOS: 8+ tabs (TD, Folios, RPP45, RPP90, Bancos, Infonavit, Fovissste, Todos) | ✅ |
| PUNTOS CRÍTICOS: tabs muestran Vencidas por default | ✅ |
| EXPEDIENTES: tabla editable + sync GitHub coordinadora↔abogados | ✅ |
| Secciones colapsables con chevron | ✅ |
| Columna COMENTARIOS con textarea persistente | ✅ |
| Modo claro como default (localStorage) | ✅ |
| Print (Ctrl+P): carta portrait, zoom:0.82 | ✅ |

---

## Notas de mantenimiento

- **El template es el archivo más frágil.** Antes de modificarlo, Claude crea un backup automático con la fecha.
- **TENDENCIA histórica 2015–2025** ya está hardcodeada dentro del build script (constante `TEND_HIST`). No depende de `TENDENCIA.xlsx` en runtime.
- **El build script usa rutas dinámicas** con `glob("/sessions/*/mnt/Bitácoras Notaría 31")` para no depender del ID de sesión de Cowork (que cambia en cada conversación).
- **REF_DATE** = fecha de ayer en CDT (UTC-5). Nunca usar `datetime.now()` sin zona horaria.
- El script es **idempotente**: se puede correr varias veces sobre el mismo xlsx sin problema.
- **Punto de restauración vigente:** si algo falla, restaurar desde `_NO_BORRAR_template_BACKUP_21-05-2026.html`.
