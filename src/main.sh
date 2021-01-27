#!/usr/bin/env bash
function installTerraform {
  if [[ "${tfVersion}" == "latest" ]]; then
    echo "Checking the latest version of Terraform"
    tfVersion=$(curl -sL https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].version' | grep -v '[-].*' | sort -rV | head -n 1)

    if [[ -z "${tfVersion}" ]]; then
      echo "Failed to fetch the latest version"
      exit 1
    fi
  fi

  url="https://releases.hashicorp.com/terraform/${tfVersion}/terraform_${tfVersion}_linux_amd64.zip"

  echo "Downloading Terraform v${tfVersion}"
  curl -s -S -L -o /tmp/terraform_${tfVersion} ${url}
  if [ "${?}" -ne 0 ]; then
    echo "Failed to download Terraform v${tfVersion}"
    exit 1
  fi
  echo "Successfully downloaded Terraform v${tfVersion}"

  echo "Unzipping Terraform v${tfVersion}"
  unzip -d /usr/local/bin /tmp/terraform_${tfVersion} &> /dev/null
  if [ "${?}" -ne 0 ]; then
    echo "Failed to unzip Terraform v${tfVersion}"
    exit 1
  fi
  echo "Successfully unzipped Terraform v${tfVersion}"
}

 if [ "${INPUT_CONFIG_FILE}" != "" ]; then
    CONFIG_FILE=${INPUT_CONFIG_FILE}
  else
    echo "Input config file cannot be empty"
    exit 1
  fi
set -eo pipefail
config_file=${INPUT_CONFIG_FILE}
echo "Scanning the modules"
readarray -t module_dirs < <(find . -name .terraform -prune , -type f -name '*.tf' -printf '%h\n' | sort | uniq)
for module_dir in "${module_dirs[@]}"; do
  echo
  echo "======================================================================"
  echo "Checking ${module_dir}"
  echo "======================================================================"
  echo
  (
    cd "${module_dir}"
    terraform init -backend=false
    profiles=()
    readarray -O ${#profiles[@]} -t profiles < <(find . -maxdepth 1 -type f -name 'terraform.tfvars.*' -printf '%f\n')
    readarray -O ${#profiles[@]} -t profiles < <(find . -maxdepth 1 -type f -name '*.tfvars' -printf '%f\n')
    if [[ ${#profiles[@]} -gt 0 ]]; then
      for profile in "${profiles[@]}"; do
        echo
        echo "Using variable values from: ${profile}"
        echo
        tflint --config="${config_file}" --var-file="${profile}"
      done
    else
      echo
      echo "Using default variable values"
      echo
      tflint --config="${config_file}"
    fi
  )
done