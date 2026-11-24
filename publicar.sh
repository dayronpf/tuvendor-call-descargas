#!/bin/zsh
# Publica una versión de TuVendor Call: sube el APK y la guía como «release».
# Los enlaces del README (…/releases/latest/download/…) pasan solos a esta versión.
#
#   ./publicar.sh 1.3.0
#
# Toma el APK compilado en ../tuvendor-ventas-app y la guía de esta carpeta.
set -euo pipefail

VERSION="${1:?Uso: ./publicar.sh 1.3.0}"
AQUI="${0:A:h}"
APP="$AQUI/../tuvendor-ventas-app"
APK="$APP/build/app/outputs/flutter-apk/app-release.apk"
TMP="$(mktemp -d)"

[[ -f "$APK" ]] || { echo "No está el APK. Compílelo: cd $APP && flutter build apk --release"; exit 1; }

# Nombres fijos: así el enlace «latest/download/TuVendor-Call.apk» nunca cambia.
cp "$APK" "$TMP/TuVendor-Call.apk"
cp "$AQUI/Guia-TuVendor-Call.pdf" "$TMP/Guia-TuVendor-Call.pdf"

gh release create "v$VERSION" \
  "$TMP/TuVendor-Call.apk" \
  "$TMP/Guia-TuVendor-Call.pdf" \
  --repo dayronpf/tuvendor-call-descargas \
  --title "TuVendor Call $VERSION" \
  --notes "App para Android y guía para enlazarla con Core. Instale el APK en el teléfono y siga la guía." \
  --latest

rm -rf "$TMP"

# La página muestra la última versión publicada (y la guía nueva, si cambió).
FECHA="$(date '+%d/%m/%Y')"
perl -0pi -e "s#<!-- version -->.*?<!-- /version -->#<!-- version -->\n<p align=\"center\"><strong>Última versión: $VERSION</strong> · publicada el $FECHA</p>\n<!-- /version -->#s" "$AQUI/README.md"
git -C "$AQUI" add README.md Guia-TuVendor-Call.pdf publicar.sh
git -C "$AQUI" commit -q -m "Versión $VERSION" || true
git -C "$AQUI" push -q origin main

echo "Listo: https://github.com/dayronpf/tuvendor-call-descargas"
