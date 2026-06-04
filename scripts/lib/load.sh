for _lib in \
  "$repo_root/scripts/lib/log.sh" \
  "$repo_root/scripts/lib/os.sh" \
  "$repo_root/scripts/lib/args.sh" \
  "$repo_root/scripts/lib/packages_common.sh" \
  "$repo_root/scripts/lib/tools_registry.sh" \
  "$repo_root/scripts/lib/git_config.sh" \
  "$repo_root/scripts/lib/packages_macos.sh" \
  "$repo_root/scripts/lib/packages_arch.sh" \
  "$repo_root/scripts/lib/symlink.sh" \
  "$repo_root/scripts/lib/install_flow.sh"; do
  source "$_lib"
done
unset _lib
