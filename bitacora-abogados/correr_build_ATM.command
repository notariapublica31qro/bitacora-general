#!/bin/bash
# Script para generar Bitacora ATM.html desde Mac directamente
# Doble clic desde Finder para ejecutar

SCRIPT_DIR="/Users/ke7/Documents/Claude/Projects/Bitácora Abogados"
DOWNLOADS="/Users/ke7/Downloads"
SRC_FILE="Bitacora ATM sin etiquetar.xlsx"

echo "=== Build Bitácora ATM ==="
echo "Fuente: $DOWNLOADS/$SRC_FILE"
echo ""

python3 - <<PYEOF
import json, re, time, shutil, glob as _glob
from datetime import datetime, date, timedelta, timezone
from collections import defaultdict
import openpyxl, sys, os

# Rutas Mac directas
_BASE_DL  = "/Users/ke7/Downloads"
_BASE_N31 = "/Users/ke7/Documents/Claude/Projects/Bitácora Abogados"
SRC = f"{_BASE_DL}/Bitacora ATM sin etiquetar.xlsx"
TPL = f"{_BASE_N31}/_NO_BORRAR_template_abogados.html"
OUT = f"{_BASE_DL}/Bitacora.html"  # se sobreescribe tras detectar abogado

# Cargar el build script real con las rutas parcheadas
src_code = open(f"{_BASE_N31}/_NO_BORRAR_build_report_mayo2026.py").read()
src_code = src_code.replace(
    '_vm_dl = _glob.glob("/sessions/*/mnt/Downloads")',
    '_vm_dl = []'
).replace(
    '_BASE_DL = _vm_dl[0] if _vm_dl else "/sessions/UNKNOWN/mnt/Downloads"',
    '_BASE_DL = "/Users/ke7/Downloads"'
).replace(
    '_vm_n31 = _glob.glob("/sessions/*/mnt/Bitácora Abogados")',
    '_vm_n31 = []'
).replace(
    '_BASE_N31 = _vm_n31[0] if _vm_n31 else "/sessions/UNKNOWN/mnt/Bitácora Abogados"',
    '_BASE_N31 = "/Users/ke7/Documents/Claude/Projects/Bitácora Abogados"'
)
exec(compile(src_code, '_NO_BORRAR_build_report_mayo2026.py', 'exec'))
PYEOF

echo ""
echo "=== Listo. Busca el HTML en Descargas. ==="
read -p "Presiona Enter para cerrar..."
