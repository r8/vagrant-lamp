declare -r CRITICAL_PACKAGES="bash pacman msys2-runtime"
declare -r OPTIONAL_PACKAGES="msys2-runtime-devel"

# set pacman command if not already defined
PACMAN=${PACMAN:-pacman}
# save full path to command as PATH may change when sourcing /etc/profile
PACMAN_PATH=$(type -P $PACMAN)

run_pacman() {
	local cmd
	cmd=("$PACMAN_PATH" "$@")
	"${cmd[@]}"
}

if ! run_pacman -Sy; then
  exit 1
fi

run_pacman -Qu ${CRITICAL_PACKAGES}

if ! run_pacman -S --noconfirm --needed ${CRITICAL_PACKAGES} ${OPTIONAL_PACKAGES}; then
  exit 1
fi
