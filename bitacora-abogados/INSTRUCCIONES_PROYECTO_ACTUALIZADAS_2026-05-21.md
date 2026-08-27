# INSTRUCCIONES DEL PROYECTO — BITÁCORA ABOGADOS / NOTARÍA 31
# Última actualización: 2026-05-21

## Contexto general
Reporte ejecutivo mensual en formato HTML de una sola página (sin servidor, abre directo en navegador).
Cada abogado genera su propio reporte desde su propio archivo xlsx.
El abogado se detecta automáticamente desde los datos del xlsx.
Usuario: notariapublica31qro@gmail.com | Zona horaria: CDT (UTC-5)

## Archivos del proyecto
Ruta base: /Users/ke7/Documents/Claude/Projects/Bitácora Abogados/

### Archivos maestros (_NO_BORRAR_ = NO MODIFICAR SIN CONFIRMAR)
- _NO_BORRAR_template_abogados.html      → plantilla base HTML genérica (~3100 líneas) — el más importante
- _NO_BORRAR_build_report_mayo2026.py    → genera el reporte HTML desde xlsx + template (un abogado)
- _NO_BORRAR_label_streaming.py          → etiqueta Estatus/Tramite en xlsx
- _NO_BORRAR_gen_todos_abogados.py       → genera los 8 reportes de todos los abogados en un solo paso
- _NO_BORRAR_INSTRUCCIONES_PROYECTO.md  → instrucciones del proyecto

### Archivos de apoyo (regenerables, sin prefijo _NO_BORRAR_)
- correr_build_ATM.command          → doble clic en Finder → genera Bitacora ATM.html desde Mac directamente
- etiquetar_y_build_ATM.command     → doble clic → etiqueta xlsx + genera reporte en un paso
- push_github_atm.command           → doble clic → sube Bitacora ATM.html a GitHub Pages (bitacora-atm)
- index.html                        → hub/dashboard de abogados (488 líneas), página de inicio de la notaría

## Fuente de datos actual (⚠️ nombre cambió — verificar antes de ejecutar)
SRC = "Bit General 25-26.xlsx" (en /Users/ke7/Downloads/)
El build script tiene `SRC = f"{_BASE_DL}/Bit General 25-26.xlsx"` hardcodeado.
Si el usuario indica otro nombre, actualizar la línea SRC en _NO_BORRAR_build_report_mayo2026.py antes de ejecutar.
Confirmar nombre en Downloads antes de correr.
Bitacora.xlsx.bak → respaldo automático (borrable tras confirmar xlsx correcto)

## REGLA CRÍTICA DE WORKFLOW
- Usar Edit (nunca Write completo) para modificar el template — tiene ~3100 líneas.
- NO modificar archivos _NO_BORRAR_ sin confirmar primero con el usuario en esa sesión.
- Archivos temporales/debug: SIN prefijo _NO_BORRAR_. Archivos de producción: CON prefijo _NO_BORRAR_.
- Usuario recarga en navegador cerrando la pestaña y reabriendo desde Finder (o ⌘+Shift+R).

## Proceso completo paso a paso

### OPCIÓN A — Un solo abogado (desde Claude)
```
python3 "/Users/ke7/Documents/Claude/Projects/Bitácora Abogados/_NO_BORRAR_label_streaming.py" "/Users/ke7/Downloads/Bit General 25-26.xlsx"
python3 "/Users/ke7/Documents/Claude/Projects/Bitácora Abogados/_NO_BORRAR_build_report_mayo2026.py"
```
- Detecta automáticamente el abogado (el de mayor número de escrituras).
- Genera /Users/ke7/Downloads/Bitacora {ABOGADO}.html

### OPCIÓN B — Todos los abogados (desde Claude, un solo paso)
```
python3 "/Users/ke7/Documents/Claude/Projects/Bitácora Abogados/_NO_BORRAR_label_streaming.py" "/Users/ke7/Downloads/Bit General 25-26.xlsx"
python3 "/Users/ke7/Documents/Claude/Projects/Bitácora Abogados/_NO_BORRAR_gen_todos_abogados.py"
```
- Genera los 8 reportes: Bitacora ATM.html, EAC.html, GGR.html, GMB.html, JCL.html, KST.html, LSR.html, MSR.html

### OPCIÓN C — Desde Mac, doble clic en Finder (sin Claude activo)
- etiquetar_y_build_ATM.command → etiqueta xlsx Y genera reporte ATM en un solo paso
- correr_build_ATM.command → solo genera reporte (ya etiquetado)
- push_github_atm.command → sube ATM a GitHub sin necesidad de Claude in Chrome
- Los .command parchean rutas del sandbox (/sessions/.../mnt/) por rutas Mac (/Users/ke7/) al vuelo.
- Si se actualiza el build script con nuevas rutas, verificar que los .command sigan siendo compatibles.

### PASO — Abrir en navegador
Abrir el HTML generado directamente desde Finder. No requiere servidor.
Para ver cambios: cerrar la pestaña y reabrir desde Finder (o ⌘+Shift+R).

### PASO — Configurar token (primera vez por navegador)
Clic en ⚙ → pegar token → Guardar.
Token PAT (sin expiración): <TOKEN_REDACTADO>

## Persistencia GitHub — repos por abogado
Cuenta: notariapublica31qro

| Abogado | Repo                              |
|---------|-----------------------------------|
| ATM     | notariapublica31qro/bitacora-atm  |
| EAC     | notariapublica31qro/bitacora-eac  |
| GMB     | notariapublica31qro/bitacora-gmb  |
| JCL     | notariapublica31qro/bitacora-jcl  |
| KST     | notariapublica31qro/bitacora-kst  |
| LSR     | notariapublica31qro/bitacora-lsr  |
| MSR     | notariapublica31qro/bitacora-msr  |
| GGR     | notariapublica31qro/bitacora-ggr (proyecto separado) |
| General | notariapublica31qro/bitacora-general (NO modificar desde este proyecto) |

## Estrategia de subida a GitHub (reporte.html ~1.2MB)
- OPCIÓN 1 (preferida, sin Claude): doble clic en push_github_atm.command → curl + python3 → GitHub API
- OPCIÓN 2 (con Claude): mcp__Claude_in_Chrome__javascript_tool con fetch() → GitHub API
  - Navegar primero a una página real antes de ejecutar JS
  - Si hay múltiples browsers, usar select_browser con deviceId antes de javascript_tool
- ⚠️ El sandbox bash de Claude NO tiene acceso a internet (proxy 403 en api.github.com). Nunca intentar curl/python desde bash del sandbox.

## Abogados activos
ATM, EAC, GGR, GMB, JCL, KST, LSR, MSR
Alias en datos: COO → LBR | J31 → ignorar

## PRIMARY_AB — mecanismo central del reporte
- `let PRIMARY_AB` y `let GH_REPO` (NO `const` — requieren reasignación desde localStorage IIFE)
- Build script usa regex `(?:const|let)` para encontrar y reemplazar ambas variables
- Inyectados: `let PRIMARY_AB = 'ATM';` / `let GH_REPO = 'bitacora-atm';`
- Todos los componentes visuales usan `pieAbKey || PRIMARY_AB` como dato por defecto al cargar
- updateKPIs('') usa PRIMARY_AB directamente para Urgentes y Pendientes (sin depender de botones)
- drawBar() muestra solo la barra del abogado del reporte al cargar
- drawLine() usa PRIMARY_AB para la gráfica de tendencia al cargar
- La URL `/bitacora-lsr/` tiene prioridad sobre `ggr_primary_ab` del localStorage
- Panel de selección de abogado (pie-ab-btns) VISIBLE para cambiar vista

## Columnas clave del xlsx (nombres exactos requeridos)
Escritura, Expediente, Estatus, Tramite, Abogado, Operación, Municipio,
Enajenante/Vendedor, Acreedor, Fech. Esc., Lleva TD,
TD. Digitalización Pago TD,
RPP. Entrada a RPP Testimonio, RPP. Digitalización Entrada RPP,
RPP. Regreso de RPP Testimonio, RPP. Captura Dato Inscripción RPP,
ESC. Entrega Firmas Completas,
CAT. Solicitud, CAT. Dig Notificacion Catastral,
BANCOS. Dig. Acuse de Recibo Banco,
INFONAVIT. Dig. Acuse de Recibo INFONAVIT,
FOVISSSTE. Dig. Acuse de Recibo FOVISSSTE

## Estatus válidos
CONCLUIDO | FALTA FINALIZAR | FALTA RPP | FALTA SIGER | EN RPP | FALTA TD | FALTA CIERRE

## Umbrales de alerta
- TD Vencido: > 15 días hábiles sin Pago TD (traslativas)
- TD Por Vencer: 9–14 días hábiles sin Pago TD
- Folios >60: > 60 días sin Entrega Firmas Completas
- Entrada RPP >45: > 45 días sin entrada a RPP
- Inscripción RPP >90: > 90 días traslativas / >30 no traslativas sin retorno RPP
- Bancos/Infonavit/Fovissste >150: > 150 días sin retorno RPP
- ⚠️ FALTA FINALIZAR se excluye de TODAS las alertas anteriores (Folios >60, Entrada RPP >45, Inscripción RPP >90/30, TD Vencido). Estas escrituras ya están manejadas bajo lógica especial.

## Paleta de colores (mayo 2026)
Fuente: Inter (Google Fonts)
Modo claro es el DEFAULT al abrir (localStorage 'lm' !== '0')
Anti-flash: `<body><script>if(localStorage.getItem('lm')!=='0')document.body.classList.add('light');</script>`
→ Debe estar INMEDIATAMENTE después de `<body>` sin salto de línea (línea 519 del template).

Modo oscuro: --bg:#2e1638 | --surface:#401f50 | --card:#401f50
  --border:#5a2e70 | --accent:#6c8ef5 | --text:#e2e8f0 | --muted:#c4a8d4
Modo claro: --bg:#f0f4f8 | --surface:#dde4ee | --card:#e8eef6
  --border:#cbd5e1 | --accent:#4a6bde | --text:#1e293b | --muted:#64748b

CONCLUIDO #16a34a | FALTA FINALIZAR #f59e0b (oscuro) / #d97706 (claro, .es-ff) — usar ámbar, NO café/marrón
FALTA RPP #0369a1 | EN RPP #92400e | FALTA TD #ef4444
FALTA CIERRE #7c3aed | FALTA SIGER #0891b2
GGR color en barra TUBERÍA: #0369a1 → AB_COLORS_BAR['GGR'] = '#0369a1'

## Tabla EXPEDIENTES
- NUM_ROWS = 1 → 1 fila vacía por default, crece con Tab al llegar al último campo
- 9 columnas: EXPEDIENTE 80px | ABO 40px | CLIENTE 200px | OPERACIÓN 180px | TD 45px | BANCOS 90px | MUNICIPIO 95px | ESTATUS 150px | TRÁMITE 180px
- EX_DATA keys: ['xp','ab','cl','op','td','ac','mu','es','tr']
- Persistencia en GitHub: expedientes.json en repo del abogado
- Guardado con debounce 2500ms; solo guarda si la fila tiene xp no vacío

## Tabla URGENTES / PENDIENTES — ajustes de celda
- Columna MUNICIPIO: font-size:inherit en el chip para que fitOpCells pueda reducirla
- Columna OPERACIÓN: font-size:inherit + double-rAF para table-layout:fixed
- fitOpCells(scopeSel): reduce font-size en td.op-cell, td.mu-cell, td.tr-cell hasta scrollWidth <= clientWidth
- Mini tarjetas Urgentes/Pendientes: onclick → SOLO scroll (scrollToAl / scrollToPe). NUNCA applyFilter.

## Botón Excel en banner
- Botón verde "📋 Excel" junto al ⚙ en .h-center
- Llama exportBitacoraExcel() → descarga DATA.pe + DATA_CO como .xlsx via SheetJS
- CDN al final del body: https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js
- Nombre del archivo: Bitacora_{AB}.xlsx (ej: Bitacora_ATM.xlsx)

## DATA_AB_ME — historial de tendencia por abogado
- Incluye TEND_HIST (datos hardcoded 2015-2025) + bitácora año en curso
- No depende de la bitácora para años anteriores a 2026
- Definido en _NO_BORRAR_build_report_mayo2026.py

## Footer y secciones
- El footer NO colapsa con ninguna sección
- La función toggleSection detiene el loop al encontrar .report-footer
- El footer siempre es visible

## Reglas de edición de archivos
1. NUNCA Write completo en el template — siempre Edit con old_string/new_string precisos
2. NO modificar _NO_BORRAR_ sin confirmación explícita del usuario en esa sesión
3. Archivos temporales/debug: SIN prefijo _NO_BORRAR_
4. Archivos de producción: CON prefijo _NO_BORRAR_

## Diferencias clave vs proyecto Bitácora GGR (proyecto separado)
- Abogado detectado automáticamente del xlsx (no hardcodeado)
- Panel de selección de abogado (pie-ab-btns) VISIBLE
- GH_REPO se inyecta dinámicamente según abogado detectado
- Output: "Bitacora {ABOGADO}.html" (ej: "Bitacora ATM.html")
- NO usar este proyecto para cambios exclusivos de GGR
- bitacora-general ya existe y funciona — NO modificar desde este proyecto

## Rol y estilo de respuesta de Claude
- Fundamento legal mexicano (Querétaro) cuando aplique.
- Edit (nunca Write completo) para modificar el template.
- Confirmar antes de modificar cualquier _NO_BORRAR_.
- Si el usuario indica un nombre de xlsx diferente, actualizar SRC antes de ejecutar.
- Respuestas directas y concisas, sin postámbulos extensos.
- El usuario prefiere no recibir resúmenes largos de lo que se hizo — puede ver el resultado por sí mismo.
