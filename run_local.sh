#!/usr/bin/env bash
set -euo pipefail

if [[ -f ".env" ]]; then
  # shellcheck disable=SC1091
  source ".env"
fi

if [[ -z "${MONGODB_ATLAS_PUBLIC_KEY:-}" || -z "${MONGODB_ATLAS_PRIVATE_KEY:-}" ]]; then
  echo "ERROR: Please set MONGODB_ATLAS_PUBLIC_KEY and MONGODB_ATLAS_PRIVATE_KEY (see .env.example)"
  exit 1
fi

ORG_NAME="${1:-}"
if [[ -z "$ORG_NAME" ]]; then
  echo "Usage: $0 "My New Org Name""
  exit 1
fi

ansible-playbook playbooks/create_atlas_org.yml -e "org_name=${ORG_NAME}"
