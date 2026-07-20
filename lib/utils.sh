ensure_file() {
  local path="$1" src="$2" label="${3:-$path}"
  if [ -f "$path" ]; then
    echo "  ✔ $label 已存在，跳过"
  else
    cp "$src" "$path" || return 1
    echo "  ✔ $label 已写入"
  fi
}

ensure_dir() {
  local path="$1" label="${2:-$path}"
  if [ -d "$path" ]; then
    echo "  ✔ $label/ 已存在，跳过"
  else
    mkdir -p "$path"
    echo "  ✔ $label/ 已创建"
  fi
}

cmd_available() {
  command -v "$1" &>/dev/null
}

try_install() {
  local label="$1"
  shift
  echo "  → 正在安装 $label..."
  if ! "$@"; then
    echo "  ⚠ 安装失败，请检查网络或手动重试"
  else
    echo "  ✔ $label 已安装"
  fi
}

prompt_choice() {
  local prompt="$1"
  local choices_name="$2"
  local -n choices_ref="$choices_name"

  echo "$prompt" >&2
  for entry in "${choices_ref[@]}"; do
    IFS='|' read -r key val desc <<< "$entry"
    echo "  [$key] $desc" >&2
  done

  local result
  read -r -p "请输入选项: " result

  for entry in "${choices_ref[@]}"; do
    IFS='|' read -r key val _ <<< "$entry"
    if [[ "$result" == "$key" ]]; then
      echo "$val"
      return 0
    fi
  done

  return 1
}

confirm_and_run() {
  local label="$1"
  local prompt="$2"
  local default="$3"
  shift 3

  if ! yes_no "$prompt" "$default"; then
    echo "  - 跳过 $label"
    return 1
  fi

  if ! cmd_available "$1"; then
    echo "  - $1 未安装，跳过"
    return 1
  fi

  echo "  → 正在初始化 $label..."
  "$@"
  echo "  ✔ $label 已创建"
}

yes_no() {
  local prompt="$1" default="${2:-Y}"
  while true; do
    read -r -p "$prompt [$default] " response
    case "${response:-$default}" in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "  请输入 y 或 n" ;;
    esac
  done
}
