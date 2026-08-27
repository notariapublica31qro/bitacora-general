#!/bin/bash
# Etiqueta el xlsx y genera el reporte ATM en un solo paso

BASE="/Users/ke7/Documents/Claude/Projects/Bitácora Abogados"
DL="/Users/ke7/Downloads"
SRC="$DL/Bitacora ATM sin etiquetar.xlsx"

echo "=== PASO 1: Etiquetando estatus y trámite ==="
python3 "$BASE/_NO_BORRAR_label_streaming.py" "$SRC"
if [ $? -ne 0 ]; then
    echo "ERROR en etiquetado. Revisa el archivo."
    read -p "Presiona Enter para cerrar..."
    exit 1
fi

echo ""
echo "=== PASO 2: Generando reporte HTML ==="
python3 - <<PYEOF
import glob as _glob

src_code = open("/Users/ke7/Documents/Claude/Projects/Bitácora Abogados/_NO_BORRAR_build_report_mayo2026.py").read()
src_code = src_code.replace(
    '_vm_dl = _glob.glob("/sessions/*/mnt/Downloads")', '_vm_dl = []'
).replace(
    '_BASE_DL = _vm_dl[0] if _vm_dl else "/sessions/UNKNOWN/mnt/Downloads"',
    '_BASE_DL = "/Users/ke7/Downloads"'
).replace(
    '_vm_n31 = _glob.glob("/sessions/*/mnt/Bitácora Abogados")', '_vm_n31 = []'
).replace(
    '_BASE_N31 = _vm_n31[0] if _vm_n31 else "/sessions/UNKNOWN/mnt/Bitácora Abogados"',
    '_BASE_N31 = "/Users/ke7/Documents/Claude/Projects/Bitácora Abogados"'
)
exec(compile(src_code, '_NO_BORRAR_build_report_mayo2026.py', 'exec'))
PYEOF

echo ""
echo "=== Listo. Abre Bitacora ATM.html en Descargas. ==="
read -p "Presiona Enter para cerrar..."
