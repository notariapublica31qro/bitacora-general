#!/bin/bash
cd "$(dirname "$0")"
echo "Subiendo template a GitHub..."
python3 _upload_template_gh.py
echo ""
echo "Listo. Puedes cerrar esta ventana."
