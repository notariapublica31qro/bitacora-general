"""
gen_todos_abogados.py
Genera un reporte HTML por cada abogado activo en Notaría 31 Querétaro.
Lee _NO_BORRAR_build_report_mayo2026.py y lo ejecuta una vez por abogado,
forzando _primary_ab para cada uno.
"""
import re, glob as _glob, time

ABOGADOS_ACTIVOS = ['ATM', 'EAC', 'GGR', 'GMB', 'JCL', 'KST', 'LSR', 'MSR']

import os as _os
_base = _os.path.dirname(_os.path.abspath(__file__))
BUILD_SCRIPT = _os.path.join(_base, "_NO_BORRAR_build_report_mayo2026.py")

src = open(BUILD_SCRIPT, encoding='utf-8').read()

ok = []
err = []

for ab in ABOGADOS_ACTIVOS:
    print(f"\n{'='*60}")
    print(f"  Generando reporte: {ab}")
    print(f"{'='*60}")
    t0 = time.time()

    # Parchamos _primary_ab para forzar el abogado deseado
    patched = re.sub(
        r"_primary_ab\s*=\s*max\(ab_stats.*?\)\s*if ab_stats else '[^']*'",
        f"_primary_ab = '{ab}'",
        src
    )

    try:
        exec(compile(patched, f'<build_{ab}>', 'exec'), {})
        elapsed = time.time() - t0
        print(f"  ✓ {ab} generado en {elapsed:.1f}s")
        ok.append(ab)
    except Exception as e:
        print(f"  ✗ ERROR en {ab}: {e}")
        err.append((ab, str(e)))

print(f"\n{'='*60}")
print(f"RESUMEN: {len(ok)} OK, {len(err)} errores")
if ok:
    print(f"  Generados: {', '.join(ok)}")
if err:
    print(f"  Fallidos:")
    for ab, msg in err:
        print(f"    {ab}: {msg}")
print(f"{'='*60}")
