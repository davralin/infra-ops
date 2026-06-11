#!/usr/bin/env bash
# Build a Talos oracle-arm64 OCI boot image suitable for import into OCI Cloud.
#
# Background
# ----------
# OCI Cloud auto-detects firmware (UEFI vs BIOS) during custom image import.
# Plain factory images (raw.gz, qcow2) are detected as BIOS and will not boot
# on ARM64 UEFI instances. The only reliable way to force UEFI_64 is to package
# the QCOW2 inside OCI's own export format: a tar archive containing:
#   image_metadata.json  (with "firmware":"UEFI_64" in externalLaunchOptions)
#   output.QCOW2         (the disk image)
#
# This script downloads the factory QCOW2 for the given version + schematic,
# wraps it in that format, and uploads the result to OCI Object Storage.
#
# Usage
# -----
#   build-talos-oci-image.sh \
#     --version     v1.13.4 \
#     --schematic   ffbce43d91d29663a98eecd1b5085b64cb8c1eb1612db3bcaa4c2d97b8b4323d \
#     --namespace   axrgc2ikvehk \
#     --bucket      infra-ops-images \
#     --object      talos-v1.13.4-oracle-arm64.oci
#
# Dependencies: curl, xz, tar, docker (for OCI CLI)
# OCI CLI auth:  ~/.oci/config + key must be present (same as Tofu)

set -euo pipefail

# ---------- defaults ----------------------------------------------------------
SCHEMATIC="ffbce43d91d29663a98eecd1b5085b64cb8c1eb1612db3bcaa4c2d97b8b4323d"
VERSION=""
OCI_NAMESPACE=""
OCI_BUCKET=""
OCI_OBJECT=""
SHAPE="VM.Standard.A1.Flex"

# ---------- args --------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)    VERSION="$2";       shift 2 ;;
    --schematic)  SCHEMATIC="$2";     shift 2 ;;
    --namespace)  OCI_NAMESPACE="$2"; shift 2 ;;
    --bucket)     OCI_BUCKET="$2";    shift 2 ;;
    --object)     OCI_OBJECT="$2";    shift 2 ;;
    --shape)      SHAPE="$2";         shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

for req in VERSION OCI_NAMESPACE OCI_BUCKET OCI_OBJECT; do
  if [[ -z "${!req}" ]]; then
    echo "Error: --${req,,} is required" >&2
    exit 1
  fi
done

# ---------- work dir ----------------------------------------------------------
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT
echo "Working in $WORKDIR"

# ---------- download ----------------------------------------------------------
FACTORY_URL="https://factory.talos.dev/image/${SCHEMATIC}/${VERSION}/oracle-arm64.qcow2.xz"
echo "Downloading $FACTORY_URL ..."
curl -fL --progress-bar "$FACTORY_URL" -o "$WORKDIR/oracle-arm64.qcow2.xz"

# ---------- decompress --------------------------------------------------------
echo "Decompressing ..."
xz -d "$WORKDIR/oracle-arm64.qcow2.xz"

# ---------- metadata ----------------------------------------------------------
cat > "$WORKDIR/image_metadata.json" <<EOF
{"version":2,"externalLaunchOptions":{"firmware":"UEFI_64","networkType":"PARAVIRTUALIZED","bootVolumeType":"PARAVIRTUALIZED","remoteDataVolumeType":"PARAVIRTUALIZED","localDataVolumeType":"PARAVIRTUALIZED","launchOptionsSource":"PARAVIRTUALIZED","pvAttachmentVersion":2,"pvEncryptionInTransitEnabled":true,"consistentVolumeNamingEnabled":true},"imageCapabilityData":null,"imageCapsFormatVersion":null,"operatingSystem":"Talos Linux","operatingSystemVersion":"${VERSION}","additionalMetadata":{"sourcePublicImageId":null,"shapeCompatibilities":[{"internalShapeName":"${SHAPE}","ocpuConstraints":null,"memoryConstraints":null}]}}
EOF

# ---------- package -----------------------------------------------------------
echo "Packaging OCI image tar ..."
cp "$WORKDIR/oracle-arm64.qcow2" "$WORKDIR/output.QCOW2"
tar -C "$WORKDIR" -cf "$WORKDIR/image.oci" image_metadata.json output.QCOW2

# ---------- upload ------------------------------------------------------------
echo "Uploading to OCI Object Storage: $OCI_NAMESPACE/$OCI_BUCKET/$OCI_OBJECT ..."
docker run --rm \
  -v ~/.oci:/oracle/.oci \
  -v "$WORKDIR:/work" \
  ghcr.io/oracle/oci-cli:latest \
  os object put \
  --namespace "$OCI_NAMESPACE" \
  --bucket-name "$OCI_BUCKET" \
  --name "$OCI_OBJECT" \
  --file /work/image.oci \
  --force

echo "Done: $OCI_OBJECT uploaded successfully."
