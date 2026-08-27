# Proyecto: Reporte Ejecutivo Bitácora — Notaría 31 Querétaro

## Contexto general
Reporte ejecutivo mensual en formato HTML de una sola página (sin servidor, abre directo en navegador).
Lee datos de Bitacora.xlsx y genera el HTML mediante un script Python.
Usuario: notariapublica31qro@gmail.com | Zona horaria: CDT (UTC-5)

## Archivos del proyecto
Ruta base: /Users/ke7/Documents/Claude/Projects/Bitácoras Notaría 31/

- Bitacora.xlsx                              → fuente de datos (openpyxl, read_only)
- _NO_BORRAR_template.html                   → plantilla base HTML (NO modificar directamente)
- _NO_BORRAR_build_report_mayo2026.py        → script Python que genera el reporte
- _NO_BORRAR_label_streaming.py              → script de etiquetado de escrituras
- _NO_BORRAR_COMO_REPRODUCIR.md             → guía completa del flujo paso a paso
- _NO_BORRAR_template_BACKUP_13-05-2026.html → backup pre-cambios grandes de mayo
- _NO_BORRAR_template_BACKUP_16-05-2026.html → backup punto de restauración 16-may-2026
- _NO_BORRAR_template_BACKUP_19-05-2026.html → backup con fixes tabs PUNTOS CRÍTICOS
- _NO_BORRAR_template_BACKUP_21-05-2026.html → ⭐ PUNTO DE RESTAURACIÓN VIGENTE (21-may-2026)
- Reporte_Ejecutivo_Mayo2026.html            → reporte generado (output del script estándar)
- TENDENCIA.xlsx                             → referencia histórica (ya hardcodeada en build script; NO se necesita en runtime)
- _run_upload_github.command                 → utilidad subida template a GitHub
- subir_template_github.py                   → utilidad subida template a GitHub
- __pycache__/                               → auto-generado por Python, ignorar

## Flujo estándar (bitácora llega SIN etiquetar)
1. Descargar bitácora de Integranot → guardar como Bitacora.xlsx (sin acento, sin espacios)
2. Etiquetar PRIMERO: python3 _NO_BORRAR_label_streaming.py Bitacora.xlsx
3. Generar reporte: python3 _NO_BORRAR_build_report_mayo2026.py
4. Abrir Reporte_Ejecutivo_Mayo2026.html en el navegador
NO pedir confirmación entre pasos — ejecutar etiquetado + reporte sin interrupciones.

## Flujo Bitácora General (bitácora ya etiquetada)
Si la bitácora llega ya etiquetada (caso Bitácora General), saltar el paso de etiquetado:
1. Guardar el archivo en ~/Downloads como Bitacora.xlsx (sin acento)
2. Ejecutar exec-with-patches (ver sección abajo) con SRC y OUT personalizados
3. El HTML de salida lleva el nombre que el usuario indique (ej. "Bitacora General.html")

## Rutas dinámicas en el build script
El script usa glob para no depender del ID de sesión de Cowork (cambia en cada conversación):
```python
import glob as _glob
_vm = _glob.glob("/sessions/*/mnt/Bitácoras Notaría 31")
_BASE = _vm[0] if _vm else "/sessions/UNKNOWN/mnt/Bitácoras Notaría 31"
SRC = f"{_BASE}/Bitacora.xlsx"
TPL = f"{_BASE}/_NO_BORRAR_template.html"
OUT = f"{_BASE}/Reporte_Ejecutivo_Mayo2026.html"
```
En bash, la ruta VM es: /sessions/[id-sesión]/mnt/Bitácoras Notaría 31/

## Generar reporte para una bitácora diferente (exec-with-patches)
```python
import glob as _glob
_vm = _glob.glob("/sessions/*/mnt/Bitácoras Notaría 31")
_base = _vm[0]
with open(f"{_base}/_NO_BORRAR_build_report_mayo2026.py") as f:
    src = f.read()
src = src.replace('SRC = f"{_BASE}/Bitacora.xlsx"', 'SRC = "/ruta/origen.xlsx"')
src = src.replace('OUT = f"{_BASE}/Reporte_Ejecutivo_Mayo2026.html"', 'OUT = "/ruta/salida.html"')
src = src.replace('TPL = f"{_BASE}/_NO_BORRAR_template.html"', f'TPL = "{_base}/_NO_BORRAR_template.html"')
exec(compile(src, '<build-patch>', 'exec'))
```
IMPORTANTE: parchear TPL explícitamente para evitar que glob resuelva a otra sesión.
El HTML de salida lleva el nombre que el usuario indique.

## Cómo se genera el reporte (build script)
1. Lee Bitacora.xlsx con openpyxl
2. Procesa los datos y genera objetos JSON (DATA, DATA_ME, DATA_YR, DATA_AB_ME, DATA_CO)
3. Inyecta esos JSON en el template HTML usando replace_const()
4. Actualiza fecha de referencia: REF = hoy - 1 día en CDT (usar timezone(timedelta(hours=-5)), NUNCA datetime.now() crudo)
5. Guarda el HTML final

## Columnas clave de Bitacora.xlsx
Escritura, Expediente, Estatus, Tramite, Abogado, Operación, Municipio,
Enajenante/Vendedor, Acreedor, Fech. Esc., Lleva TD,
TD. Digitalización Pago TD, TD. Pago, TD. Elab. Formato y/o Carga portal,
RPP. Entrada a RPP Testimonio, RPP. Digitalización Entrada RPP,
RPP. Regreso de RPP Testimonio, RPP. Captura Dato Inscripción RPP,
RPP. Solicitud, RPP. Pago RPP, RPP. Digitalización Pago RPP,
CAT. Solicitud, CAT. Dig Notificacion Catastral,
ESC. Entrega Firmas Completas, CIERRE. Expedición de Testimonio,
ENT. Testimonio Digitalizado, ENT. Entrega Test a Financiero, ENT. Test. a Recepción,
MDC. Entrega Exp Unidad Gestión,
BANCOS. Dig. Acuse de Recibo Banco,
INFONAVIT. Dig. Acuse de Recibo INFONAVIT,
FOVISSSTE. Dig. Acuse de Recibo FOVISSSTE

## Estatus válidos
CONCLUIDO, FALTA FINALIZAR, FALTA RPP, FALTA SIGER, EN RPP, FALTA TD, FALTA CIERRE

## Abogados registrados
ACM, AGB, ATM, EAC, GGR, GMB, JCL, JLGP, KST, LBR, LSR, MSR
(alias: COO → LBR, J31 → ignorar)

## Reglas de etiquetado — interpretación de celdas
- Fecha → paso CUMPLIDO
- Vacío/null → paso PENDIENTE
- "-" → NO APLICA
- "*" → pendiente (se trata como vacío en traslativas)

## Reglas de etiquetado — No traslativas (Lleva TD ≠ SI)
1. RPP.Sol y RPC.Sol = "-" Y hay cierre/ENT → CONCLUIDO
2. RPP.Sol y RPC.Sol = "-" Y sin cierre/ENT → FALTA CIERRE
3. RPP.Sol aplica + RPP.Regreso o Captura cumplido → CONCLUIDO
4. RPP.Sol aplica + sin Regreso/Captura + RPP.Entrada cumplida → EN RPP
5. RPP.Sol aplica + sin nada de Entrada → FALTA RPP
6. RPC.Sol aplica + SIGER.Dig cumplido → CONCLUIDO
7. RPC.Sol aplica + SIGER.Dig = "-" + cierre/ENT → CONCLUIDO
8. RPC.Sol aplica + SIGER pendiente → FALTA SIGER
Fallback: con cierre/ENT → CONCLUIDO; sin → FALTA CIERRE

## Reglas de etiquetado — Traslativas (Lleva TD = SI)
Caso especial: RPP.Solicitud = "-" → ignorar RPP, evaluar solo ENT/CIERRE → CONCLUIDO si hay alguno.
1. CAT.Dig.Notif = "-" + RPP.Regreso/Captura cumplido → CONCLUIDO
2. CAT.Dig.Notif cumplido + RPP.Regreso/Captura cumplido → CONCLUIDO
3. CAT.Dig.Notif NO cumplido + RPP.Regreso/Captura cumplido → FALTA FINALIZAR + NOTIF CAT
4. CAT.Dig.Notif cumplido + RPP.Entrada cumplida (sin Regreso/Captura) → EN RPP
5. CAT.Dig.Notif cumplido + sin RPP.Entrada → FALTA RPP
6. CAT.Dig.Notif NO cumplido + RPP.Entrada cumplida → EN RPP + NOTIF CAT
7. TD pagado + CAT.Dig.Notif NO + sin RPP.Entrada → FALTA RPP + NOTIF CAT
8. TD NO pagado + sin RPP.Entrada → FALTA TD
Excepción APLICACIÓN DE BIENES: si operación contiene "APLICACIÓN DE BIENES" + CAT.Dig.Notif cumplido → NO etiquetar FALTA TD aunque TD no esté pagado.

## Subetiquetas (Tramite)
FALTA TD → PASAR (MDC vacío) / CAPTURA (MDC ok, TD.Elab vacío) / RECURSOS (ambos ok)
FALTA CIERRE → PASAR (MDC vacío) / ARMADO (MDC ok + Firmas ok) / FOLIO (MDC ok, Firmas vacías)
FALTA RPP / FALTA SIGER → FOLIO (Firmas vacías) > CIERRE (Firmas ok, Cierre vacío) > NOTIF CAT (traslativas, CAT pendiente) > PAGO (sin pago RPP) > ENTRADA (con pago, listo para ingresar)
EN RPP → NOTIF CAT (solo traslativas, CAT.Dig.Notif pendiente)
FALTA FINALIZAR sub-etiquetas (orden: NOTIF CAT - DIGITALIZAR - CONCILIAR - ENVIAR):
  - NOTIF CAT: traslativa + CAT.Dig.Notif no cumplido
  - DIGITALIZAR: ENT.Testimonio.Dig vacío + CIERRE cumplido + (no tras: RPP/RPC no aplican; tras: RPP.Regreso cumplido)
  - CONCILIAR: ENT.Test.a.Recepción o ENT.Entrega.Test.a.Financiero vacíos (se suprime si DIGITALIZAR activo)
  - ENVIAR: solicitud entrega a Banco/INFONAVIT/FOVISSSTE activa pero acuse pendiente

## Umbrales de alerta (días naturales desde Fech. Esc.)
- TD Vencido:          > 15 días hábiles sin Pago TD (traslativas)
- TD Por Vencer:       9–14 días hábiles sin Pago TD
- Folios >60:          > 60 días sin Entrega Firmas Completas
- Entrada RPP >45:     > 45 días sin entrada a RPP (no EN RPP, sin acuse banco/info/fovi)
- Inscripción RPP >90: > 90 días traslativas / >30 días no traslativas sin retorno RPP
- Bancos >150:         > 150 días con banco sin retorno RPP
- Infonavit >150:      > 150 días con Infonavit sin retorno RPP
- Fovissste >150:      > 150 días con Fovissste sin retorno RPP
Por Vencer (todos los tabs excepto TD): 8 días naturales antes del límite (PV_DAYS=8)

## Reglas de flags ba / infonavit / fovissste en el build script
- is_ba   = is_ba_seg AND _acuse_pend(BANCOS.Dig.Acuse.Banco)
- is_info = is_info_seg AND _acuse_pend(INFONAVIT.Dig.Acuse.INFONAVIT)
- is_fovi = is_fovi_seg AND _acuse_pend(FOVISSSTE.Dig.Acuse.FOVISSSTE) AND (not is_ba_seg OR _acuse_pend(ba_acuse))
_acuse_pend(v): None/''/'*'/'-'/'nan' = pendiente. Solo fecha real = cumplido.

## Detección de segmentos
- Constructoras: Enajenante contiene CONSTRUCTORA, INMOBILIARIA, GRUPO, RESIDENCIAL, DESARROLLOS, PROYECTOS, URBANIZADORA, PROMOTORA, ARQUITECTOS
- Bancos: Acreedor que no sea exclusivamente INFONAVIT/FOVISSSTE
- Foráneas: Municipio distinto a QUERÉTARO/QUERETARO/CORREGIDORA/EL MARQUÉS/EL MARQUES. "-" no aplica.
- NO_BANCO = ['TIERRA Y ARMONIA'] (no contar como banco aunque aparezca en Acreedor)

## Chips de bancos (acChip) — paleta aprobada
BBVA #0891b2 · HSBC #c026d3 · SANTANDER #dc2626 · BANORTE #a16207 · SCOTIABANK #6c8ef5
BANBAJÍO #7c3aed · BANREGIO #f59e0b · AFIRME #92400e · MIFEL #0369a1 · BANCO INVEX #d97706
AXIONEX #94a3b8 · CP MEXICANA #0f766e · CP FLORENCIO #059669 · IMSS #15803d
INFONAVIT #ef4444 · FOVISSSTE #8b5cf6 · BANJERCITO #84cc16 · ISSFAM #84cc16 · OTROS #94a3b8
INFONAVIT-BANCO combos: etiqueta = "COFI-BANCO" (ej. "COFI-BBVA")
Lógica: if(u.startsWith('INFONAVIT-')) label = 'COFI-' + ac.substring(10)

## Paleta y fuente del HTML
Fuente: Inter (Google Fonts, pesos 400–900)
Modo oscuro: --bg:#0f172a  --surface:#1e293b  --accent:#6c8ef5  --green:#16a34a  --yellow:#d97706  --red:#dc2626  --orange:#ea580c
Modo claro:  --bg:#f8f9fc  --surface:#ffffff  --card:#e8eef6   --border:#e2e8f0  --text:#1e293b  --muted:#64748b
Encabezados tablas en modo claro: background:#1e293b !important; color:#ffffff !important
Modo claro es el DEFAULT al cargar (localStorage 'lm' !== '0' → agrega clase 'light')

## Colores por abogado
ACM #059669 · AGB #d97706 · ATM #15803d · EAC #ea580c · GGR #0369a1 · GMB #7c3aed
JCL #0891b2 · JLGP #dc2626 · KST #0f766e · LBR #b45309 · LSR #92400e · MSR #c026d3

## Colores por tipo de pendiente (barras)
Falta TD #ef4444 · Falta Cierre #7c3aed · Falta Siger #0891b2 · Falta RPP #0369a1 · En RPP #92400e · Falta Finalizar #f59e0b

## Orden de secciones del reporte (aprobado 2026-05-16)
1. 📝 ESCRITURAS  (id: sec-pe) — antes llamada PENDIENTES
2. 📂 EXPEDIENTES (id: sec-ex)
3. 🚨 PUNTOS CRÍTICOS (id: sec-al)
4. Banner final (.report-footer) — scroll al inicio al hacer clic

## 11 botones de segmento — ESCRITURAS (orden aprobado)
Todo · Falta TD · Falta Notif Cat · Falta Cierre · Falta RPP · En RPP · Foráneas · Bancos · Infonavit · Fovissste · Finalizar
- "Falta RPP" clave interna notr_rpp (cubre FALTA RPP + FALTA SIGER)
- Colores: Falta RPP #92400e (café), En RPP #0369a1 (azul) — intercambiados intencionalmente
- Todos + Foráneas + Bancos + INFONAVIT + FOVISSSTE + Falta Notif Cat + Falta RPP (notr_rpp) combinan DATA.pe + DATA_CO sin CONCLUIDO
- KPI Pendientes excluye FALTA FINALIZAR (c.pendiente=true)

## Metas mensuales por abogado (META_RING) — actualizado 2026-05-07
GLOBAL: total 422, tras 216, ntr 206
EAC: 30/20/10 · GGR: 25/5/20 · LSR: 35/15/20 · KST: 60/22/38 · JCL: 70/36/34
GMB: 77/48/29 · ATM: 41/20/21 · MSR: 81/50/31 · JLGP: 3/0/3

## Tendencia histórica 2015–2025
Hardcodeada en build script como constante TEND_HIST (por abogado + TOTAL).
El año en curso (2026+) se suma desde Bitacora en runtime — no desde TEND_HIST.
Abogados activos con histórico: ACM, AGB, ATM, GGR, GMB, JCL, JLGP, KST, LSR, MSR.

## Gráfica TENDENCIA — header
Título "Tendencia" alineado a la izquierda, leyenda de años alineada a la derecha.
Layout: display:flex; justify-content:space-between. Font-size años: .58rem.
Líneas históricas: alpha entre 0.60 y 0.82; line width 1.6px.
Canvas NO lleva fillText("TENDENCIA") — el título ya está en el HTML.

## Columnas ESCRITURAS (PE_COLS) — anchos aprobados 2026-05-13
ABO:44px | EXPEDIENTE:72px | Escritura:80px | FECHA:78px | Operación:155px
Bancos:95px | Municipio:76px | Estatus:125px | Trámite:140px | Comentarios:150px
Font size: 13px todos (td y th). EXPEDIENTE header: font-size:9px !important; letter-spacing:0

## Columnas PUNTOS CRÍTICOS (AL_COLS) — anchos aprobados 2026-05-13
ABO:55px | EXPEDIENTE:60px | Escritura:60px | FECHA:70px | VENCIMIENTO:70px
Operación:115px | Bancos:80px | Municipio:65px | Estatus:105px | Trámite:105px
Lím.:36px | Días:36px | Estado:108px | Comentarios:140px
Font size: 11px todos. FECHA padding-left:10px. EXPEDIENTE header: font-size:8px; letter-spacing:0

## fitOpCells — función de ajuste de fuente en tablas
- Actúa sobre td.op-cell y td.mu-cell en ambas tablas
- Detecta chip con cell.querySelector('.chip') y aplica font-size al chip directamente (no al td)
- Usa canvas (_fitCtx) para medir; cache OP_FIT_CACHE (Map keyed por "w|text")
- Textos ≤7 caracteres: skip (removeProperty font-size, no medir)
- Se llama con requestIdleCallback (fallback setTimeout 32ms) para no bloquear el render

## fitColText — función de ajuste de columnas Bancos+Municipio
- Para td: td.style.setProperty('font-size', fs+'px', 'important')
- Para chip: chip.style.fontSize = fs+'px' directo (no setProperty)
- pe-table: índices [4,5,6] (Operación+Bancos+Municipio)
- al-table: índices [5,6,7] (Operación+Bancos+Municipio)

## REGLA CRÍTICA — Botones tamaño uniforme
Los botones de PUNTOS CRÍTICOS (Todas/Por Vencer/Vencidas = .al-v-btn) deben tener
siempre el mismo tamaño que los tabs superiores (Todos/Folios>60/TD Vencido = .tab).
CSS: padding:4px 7px; border-radius:14px; font-size:.75rem; font-weight:700;
display:inline-flex; align-items:center; justify-content:center; gap:3px; box-sizing:border-box;
SIN line-height explícito.
syncAlVBtnSizes() sincroniza: al-v-btn-all↔tab[data-t="todos"], al-v-btn-pv↔tab[data-t="firmas"], al-v-btn-ve↔tab[data-t="td"]
Se llama en: updateAlCounts, applyChartFilter, switchTab, onPieAbClick, clearAllFilters, clearEtapaFilter, window load (fonts.ready + setTimeout 250ms + 750ms), ResizeObserver.

## Comportamiento de tabs PUNTOS CRÍTICOS — aprobado 2026-05-19
Al cambiar a cualquier tab que NO sea 'todos': el filtro default es Vencidas (alVFilter='true').
Tab 'todos': mantiene filtro default en Todas (alVFilter='').
Lógica en switchTab(t): var _dv=t==='todos'?'':'true'; alVFilter=_dv;
Botón activado por defecto: t==='todos' ? 'al-v-btn-all' : 'al-v-btn-ve'
Este comportamiento también aplica en applyChartFilter al resetear alVFilter al cambiar filtro desde el pastel.

## getTabRows('td') — fix aprobado 2026-05-19
Solo incluir vencidos reales: filtrar con r.v===true (no todos los de DATA.al.td).
Tab TD Vencido — botón "Todas" muestra SOLO vencidos (curTab==='td' → solo r.v===true).
PV de TD sigue accesible desde el botón "Por Vencer".

## bancosInfoFoviEscs — Set para inclusión de FF en tabs (aprobado 2026-05-19)
Pre-computa escrituras FF con flag ba/infonavit/fovissste pendiente:
```javascript
const bancosInfoFoviEscs = new Set([
  ...(DATA.al.ba||[]).map(r=>r.e), ...(DATA.al.info||[]).map(r=>r.e),
  ...(DATA.al.fovi||[]).map(r=>r.e),
  ...(DATA_CO||[]).filter(r=>r.es==='FALTA FINALIZAR'&&(r.ba||r.infonavit||r.fovissste)).map(r=>r.e),
]);
```
Usado para incluir FF en tabs todos/rpp45/rpp90solo:
.filter(r=>!['todos','rpp45','rpp90solo'].includes(curTab)||r.es!=='FALTA FINALIZAR'||bancosInfoFoviEscs.has(r.e))

## updateAlVCounts() — simplificación aprobada 2026-05-19
Contador "Todas" cuenta solo VENCIDAS: elAll.textContent = String(ve.length)

## clearEtapaFilter() — comportamiento aprobado
Limpia pieSelected preservando pieAbKey (abogado activo).
NO resetear alVFilter dentro de clearEtapaFilter — es redundante con el reset en switchTab.

## Columna COMENTARIOS
- window.COMMENTS = {} global; clave = r.e (número de escritura)
- Solo en PDF/CSV/Print — NUNCA en el navegador como columna visible en tabla
- Textarea: auto-uppercase, auto-resize, fondo transparente, borde accent al focus
- CSS pe-table textarea: font-size:.84rem !important; font-weight:600; text-align:center
- CSS al-table textarea: font-size:11px !important; text-align:center

## Print / Export
- El usuario usa Ctrl+P del navegador — NO el botón popup JS
- Botón Imprimir ELIMINADO de ESCRITURAS y PUNTOS CRÍTICOS — NO volver a agregar
- Orientación: carta portrait (letter portrait), zoom:0.82
- Botones de export en misma línea que títulos: solo ⬇ CSV y ⬇ PDF
- Tablas en print: table-layout:auto; font-size:.52rem; white-space:nowrap — NO agregar reglas extra
- NO usar backticks JS (template literals) dentro de strings Python al construir HTML de print

## jsPDF — AL PDF columnStyles (568pt útiles)
Operación col5: 59pt, font-fit max 5pt
Estatus col8: 54pt explícito, fontSize fijo 5pt
Trámite col9: auto (~65pt), fontSize fijo 5pt
Bancos col6: 42pt, _fit(7,42) · Municipio col7: 50pt, _fit(7,50)
Estado col12: 44pt, _fit(6,44) + overflow:'visible' (SOLO esta columna)

## GitHub — repositorio coordinadora
- GH_OWNER = 'notariapublica31qro' | GH_REPO = 'bitacora-general'
- Repo privado; token sin vencimiento (renovado 2026-05-16)
- Token actual: <TOKEN_REDACTADO>
- localStorage key: gh_token_general
- Archivos en repo: comments.json (comentarios tablas) + expedientes.json (tabla EXPEDIENTES)
- Configurar en reporte: botón ⚙ → pegar token → Guardar

## Sección EXPEDIENTES — estructura
- ID: sec-ex | Orden: entre ESCRITURAS y PUNTOS CRÍTICOS
- Filtros: Todos / No Traslativas / Traslativas + chip de abogado activo
- Tabla ex-table: ABO(52px) | EXPEDIENTE(80px) | CLIENTE(210px) | OPERACIÓN(190px) | TD(45px) | BANCOS(100px) | MUNICIPIO(105px) | ESTATUS(150px) | TRÁMITE(180px)
- EX_DATA: array global; clave única = campo xp (número de expediente)
- _locked:true en fila cuando coordinadora edita es o tr → bloqueada a sync de abogados
- Sync: ghGetFileFrom(AB_REPOS[ab], 'expedientes.json', ...) por cada abogado
- Repos abogados: GGR:'bitacora-ggr', MSR:'bitacora-msr', LSR:'bitacora-lsr', KST:'bitacora-kst', JCL:'bitacora-jcl', GMB:'bitacora-gmb', EAC:'bitacora-eac', ATM:'bitacora-atm'

## Secciones colapsables
- toggleSection(secId): oculta/muestra siblings hasta el siguiente .sec o .report-footer
- CSS: .sec-hidden{display:none!important} · .sec-collapsed .sec-chev{transform:rotate(-90deg)}
- Chevron ▾ como último hijo directo del .sec

## Bugs históricos — NO repetir
- Grid KPIs: usar repeat(4, minmax(0, 1fr)) — sin minmax(0,...) rompe a 2 filas
- .charts-row: usar align-items:start (no stretch) — con stretch el pastel se estira
- drawBar() } prematura tras SEG_KEYS → canvas vacío
- FALTA FINALIZAR viene de DATA_CO + DATA.pe — combinar ambas en getPeRows()
- fitOpCells: setProperty en td NO cascada a .chip (CSS directo) — aplicar siempre al chip
- Template literals JS (`) en strings Python → SyntaxError que rompe todo el reporte
- Rutas hardcodeadas con ID de sesión → FileNotFoundError en nueva conversación
- TPL con glob puede resolver a sesión equivocada → siempre parchear TPL explícitamente
- Build script con código de otro proyecto pegado al final → verificar integridad antes de correr
- sec-pe en print: usar #sec-pe > div (NO #sec-al > div global) para ocultar botones seg
- display:contents en .tabs sin scope → todos los .tabs colapsan; usar .tabs-vbtns-wrapper > .tabs
- updateSegs por abogado: usar [...DATA.pe, ...DATA_CO] (todas), NO solo DATA.pe (pendientes)

## Datos embebidos (DATA objects en el HTML)
- DATA = {t: totales, es: {estatus:count}, ab: {abogado:stats}, se: segmentos, me: meses, tr: {tramite:count}, al: alertas, pe: pendientes[]}
- DATA_CO = lista de escrituras CONCLUIDO + FALTA FINALIZAR mezcladas
- DATA_ME = {año: [12 meses]} — tendencia histórica hardcoded + año actual
- DATA_YR = {año: total}
- DATA_AB_ME = {abogado: {año: [12 meses]}}
- META_RING = metas individuales hardcoded (ver sección de metas)
- REF_DATE = fecha de referencia en CDT (inyectada por build script en spans id="cal-mes/dia/anio")

## Dependencia Python
Solo se necesita: openpyxl
pip install openpyxl --break-system-packages
Todo lo demás es stdlib de Python 3 (json, re, time, shutil, glob, datetime, collections).

## Notas finales
- El script es idempotente: se puede correr varias veces sobre el mismo xlsx
- El HTML generado puede borrarse (se regenera en segundos)
- Antes de modificar el template, crear backup con fecha: _NO_BORRAR_template_BACKUP_DD-MM-YYYY.html
- No cuestionar ni proponer cambios en áreas aprobadas sin instrucción explícita del usuario
- Punto de restauración vigente: _NO_BORRAR_template_BACKUP_21-05-2026.html

Follow these instructions when working in this project.
