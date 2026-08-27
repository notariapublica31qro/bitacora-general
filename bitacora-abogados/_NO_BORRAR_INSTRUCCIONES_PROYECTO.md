# INSTRUCCIONES DEL PROYECTO — BITÁCORA ABOGADOS / NOTARÍA 31
# Última actualización: 2026-05-16

## Contexto general
Reporte ejecutivo mensual en formato HTML de una sola página (sin servidor, abre directo en navegador).
Cada abogado genera su propio reporte desde su propio archivo xlsx.
El abogado se detecta automáticamente desde los datos del xlsx.
Usuario: notariapublica31qro@gmail.com | Zona horaria: CDT (UTC-5)

## Archivos del proyecto
Ruta base: /Users/ke7/Documents/Claude/Projects/Bitácora Abogados/

- _NO_BORRAR_template_abogados.html      → plantilla base HTML genérica (~3100 líneas)
- _NO_BORRAR_build_report_mayo2026.py    → genera el reporte HTML desde xlsx + template (un abogado)
- _NO_BORRAR_label_streaming.py          → etiqueta Estatus/Tramite en xlsx
- _NO_BORRAR_gen_todos_abogados.py       → genera los 8 reportes de todos los abogados en un solo paso
- _NO_BORRAR_INSTRUCCIONES_PROYECTO.md  → este archivo

Fuente de datos: /Users/ke7/Downloads/Bitacora.xlsx (o el nombre que indique el usuario)
Archivos que abre el abogado: /Users/ke7/Downloads/Bitacora {ABOGADO}.html

## Nombre del xlsx
El archivo normalmente se llama Bitacora.xlsx pero el usuario puede renombrarlo.
Si tiene otro nombre, el usuario lo indicará ANTES de pedir el etiquetado.
Cambiar la línea SRC al inicio del build script:
  SRC = f"{_BASE_DL}/NombreDelArchivo.xlsx"

## REGLA CRÍTICA DE WORKFLOW
- Usar Edit (nunca Write completo) para modificar el template — tiene ~3100 líneas.
- NO modificar archivos _NO_BORRAR_ sin confirmar primero con el usuario.
- Usuario recarga en navegador con ⌘+Shift+R (hard reload).

## Proceso completo paso a paso

### OPCIÓN A — Un solo abogado
```
python3 "/Users/ke7/Documents/Claude/Projects/Bitácora Abogados/_NO_BORRAR_label_streaming.py" "/Users/ke7/Downloads/Bitacora.xlsx"
python3 "/Users/ke7/Documents/Claude/Projects/Bitácora Abogados/_NO_BORRAR_build_report_mayo2026.py"
```
- Detecta automáticamente el abogado (el de mayor número de escrituras).
- Genera /Users/ke7/Downloads/Bitacora {ABOGADO}.html

### OPCIÓN B — Todos los abogados (un solo paso)
```
python3 "/Users/ke7/Documents/Claude/Projects/Bitácora Abogados/_NO_BORRAR_label_streaming.py" "/Users/ke7/Downloads/Bitacora.xlsx"
python3 "/Users/ke7/Documents/Claude/Projects/Bitácora Abogados/_NO_BORRAR_gen_todos_abogados.py"
```
- Genera los 8 reportes: Bitacora ATM.html, EAC.html, GGR.html, GMB.html, JCL.html, KST.html, LSR.html, MSR.html

### PASO — Abrir en navegador
Abrir el HTML generado directamente desde Finder. No requiere servidor.
Para ver cambios: ⌘+Shift+R (hard reload) o cerrar pestaña y reabrir.

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

## Abogados activos
ATM, EAC, GGR, GMB, JCL, KST, LSR, MSR
Alias en datos: COO → LBR | J31 → ignorar

## PRIMARY_AB — mecanismo central del reporte
- El build script detecta el abogado principal (max escrituras) e inyecta: `const PRIMARY_AB = 'ATM';`
- GH_REPO se inyecta dinámicamente según abogado: `const GH_REPO = 'bitacora-atm';`
- Todos los componentes visuales usan `pieAbKey || PRIMARY_AB` como dato por defecto al cargar
- updateKPIs('') usa PRIMARY_AB directamente para Urgentes y Pendientes (sin depender de botones)
- drawBar() muestra solo la barra del abogado del reporte al cargar
- drawLine() usa PRIMARY_AB para la gráfica de tendencia al cargar
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

## Paleta de colores (mayo 2026)
Fuente: Inter (Google Fonts)
Modo oscuro (DEFAULT en código): --bg:#2e1638 | --surface:#401f50 | --card:#401f50
  --border:#5a2e70 | --accent:#6c8ef5 | --text:#e2e8f0 | --muted:#c4a8d4
Modo claro (DEFAULT al abrir, por localStorage): --bg:#f0f4f8 | --surface:#dde4ee
  --card:#e8eef6 | --border:#cbd5e1 | --accent:#4a6bde | --text:#1e293b | --muted:#64748b
CONCLUIDO #16a34a | FALTA FINALIZAR #f59e0b (oscuro) / #d97706 (claro, .es-ff)
FALTA RPP #0369a1 | EN RPP #92400e | FALTA TD #ef4444
FALTA CIERRE #7c3aed | FALTA SIGER #0891b2
GGR color en barra TUBERÍA: #0369a1

## Tabla EXPEDIENTES
- NUM_ROWS = 1 → 1 fila vacía por default, crece con Tab al llegar al último campo
- 9 columnas: EXPEDIENTE 80px | ABO 40px | CLIENTE 200px | OPERACIÓN 180px | TD 45px | BANCOS 90px | MUNICIPIO 95px | ESTATUS 150px | TRÁMITE 180px
- Persistencia en GitHub: expedientes.json en repo del abogado
- Guardado con debounce 2500ms; solo guarda si la fila tiene xp no vacío

## Tabla URGENTES / PENDIENTES — ajustes de celda
- Columna MUNICIPIO: font-size:inherit en el chip para que fitOpCells pueda reducirla
- Columna OPERACIÓN: font-size:inherit + double-rAF para table-layout:fixed
- fitOpCells(scopeSel): reduce font-size en td.op-cell, td.mu-cell, td.tr-cell hasta scrollWidth <= clientWidth

## DATA_AB_ME — historial de tendencia por abogado
- Incluye TEND_HIST (datos hardcoded 2015-2025) + bitácora año en curso
- No depende de la bitácora para años anteriores a 2026
- Definido en _NO_BORRAR_build_report_mayo2026.py

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

## Rol y estilo de respuesta de Claude
- Fundamento legal mexicano (Querétaro) cuando aplique.
- Edit (nunca Write completo) para modificar el template.
- Confirmar antes de modificar cualquier _NO_BORRAR_.
- Si el usuario indica un nombre de xlsx diferente, actualizar SRC antes de ejecutar.
- Respuestas directas y concisas, sin postámbulos extensos.
