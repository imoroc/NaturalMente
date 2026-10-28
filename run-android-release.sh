#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo "Uso: $0 [id-del-dispositivo]"
  echo "Compila, instala y abre una versión release optimizada para ese Android."
  echo "Sin ID, requiere un único dispositivo autorizado."
  echo "Variables: FLUTTER_BIN, ANDROID_HOME (o ANDROID_SDK_ROOT), ANDROID_DEVICE."
  echo "Usa la firma release configurada en Gradle (actualmente, clave de desarrollo)."
  exit 0
fi
if (( $# > 1 )) || [[ "${1:-}" == -* ]]; then
  echo "Uso: $0 [id-del-dispositivo]" >&2
  exit 1
fi

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd -- "$project_dir"
export ANDROID_HOME="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-/home/david/Android/Sdk}}"
flutter_bin="${FLUTTER_BIN:-$(command -v flutter || true)}"
flutter_bin="${flutter_bin:-/tmp/naturalmente-flutter/bin/flutter}"
adb_bin="$ANDROID_HOME/platform-tools/adb"

if [[ ! -x "$flutter_bin" ]]; then
  echo "No encuentro Flutter. Configura FLUTTER_BIN con la ruta a bin/flutter." >&2
  exit 1
fi
if [[ ! -x "$adb_bin" ]]; then
  echo "No encuentro adb. Configura ANDROID_HOME con la ruta al SDK de Android." >&2
  exit 1
fi
export PATH="$(dirname -- "$flutter_bin"):$ANDROID_HOME/platform-tools:$PATH"

device_id="${1:-${ANDROID_DEVICE:-}}"
if [[ -z "$device_id" ]]; then
  devices_output="$("$adb_bin" devices)"
  mapfile -t devices < <(awk '$2 == "device" {print $1}' <<< "$devices_output")
  if (( ${#devices[@]} != 1 )); then
    echo "Conecta y autoriza un Android. Si hay varios, indica su ID como argumento." >&2
    printf '%s\n' "$devices_output" >&2
    exit 1
  fi
  device_id="${devices[0]}"
fi
if [[ "$("$adb_bin" -s "$device_id" get-state)" != "device" ]]; then
  echo "El dispositivo $device_id no está conectado y autorizado." >&2
  exit 1
fi

abi_list="$("$adb_bin" -s "$device_id" shell getprop ro.product.cpu.abilist | tr -d '\r')"
if [[ -z "$abi_list" ]]; then
  abi_list="$("$adb_bin" -s "$device_id" shell getprop ro.product.cpu.abi | tr -d '\r')"
fi
target_platform=""
IFS=',' read -r -a abis <<< "$abi_list"
for abi in "${abis[@]}"; do
  case "$abi" in
    arm64-v8a) target_platform=android-arm64 ;;
    armeabi-v7a) target_platform=android-arm ;;
    x86_64) target_platform=android-x64 ;;
    *) continue ;;
  esac
  break
done
if [[ -z "$target_platform" ]]; then
  echo "Arquitectura Android no compatible con Flutter: $abi_list" >&2
  exit 1
fi

# Cada compilación conserva sus propios símbolos y su APK para poder diagnosticarla.
mkdir -p "$project_dir/build/android-release"
output_dir="$(mktemp -d "$project_dir/build/android-release/$(date +%Y%m%d-%H%M%S)-XXXXXX")"
echo "Compilando release para $device_id ($target_platform)…"
echo "Se usará la firma configurada en android/app/build.gradle.kts."
"$flutter_bin" build apk --release \
  --target-platform "$target_platform" \
  --tree-shake-icons \
  --obfuscate \
  --split-debug-info="$output_dir/symbols"
cp "$project_dir/build/app/outputs/flutter-apk/app-release.apk" "$output_dir/app-release.apk"
if [[ -d "$project_dir/build/app/outputs/mapping/release" ]]; then
  cp -R "$project_dir/build/app/outputs/mapping/release" "$output_dir/mapping"
fi

echo "Instalando sin borrar los datos de la aplicación…"
if ! "$adb_bin" -s "$device_id" install -r "$output_dir/app-release.apk"; then
  echo "No se pudo instalar. Revisa el error de adb (firma, versión o espacio)." >&2
  echo "No se ha desinstalado la app ni borrado su progreso." >&2
  echo "APK y símbolos: $output_dir" >&2
  exit 1
fi
"$adb_bin" -s "$device_id" shell am start -W \
  -n com.naturalmente.naturalmente/.MainActivity
echo "Release instalada. APK y símbolos: $output_dir"
