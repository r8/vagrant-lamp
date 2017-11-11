# Prepend values from the parent environment to msys2 environment variables.

export PKG_CONFIG_PATH="${PREMSYS2_PKG_CONFIG_PATH:+${PREMSYS2_PKG_CONFIG_PATH}:}${PKG_CONFIG_PATH}"

# Instead of placing our entire windows path into msys2, we can selectively
# prepend just the important parts that we need. This also ensures that
# we don't accidentally add other unnecessary chef or git msys2 library
# files in the path.
export PATH="${PREMSYS2_PATH:+${PREMSYS2_PATH}:}${PATH}"

# TODO: If there are other variabled we want to control like MANPATH or ACLOCALPATH,
# add those here.

