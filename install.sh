#!/usr/bin/env bash

ONLY_INSTALL=true
export NIXPKGS_ALLOW_UNFREE=1

PKGS=$(yq ".packages.[][].package" packages.yaml | sed 's/- //g')
DIFFERENT_INSTALLED_NAMES=$(yq ".packages.[][].installedName" packages.yaml | sed 's/null//g')
INSTALLED_PKGS=$(nix-env -q | sed "s/-[0-9.]\+$//")

# echo $INSTALLED_PKGS
# echo $PKGS
# echo $DIFFERENT_INSTALLED_NAMES
# exit 0


for PKG in $PKGS
do
	R=$(yq ".packages.[][] | select(.package == \"$PKG\") | .installedName" packages.yaml)
	if ! echo $R | grep -q null;
	then
		INSTALLED_PKGS=$(echo $INSTALLED_PKGS | sed "s/$R/$PKG/")
	fi

done


for PKG in $INSTALLED_PKGS
do
	if ! echo $PKGS | grep -q "$PKG"; then
		# echo nix-env --uninstall $PKG
		nix-env --uninstall $PKG
	fi
done


for PKG in $PKGS
do
	if $ONLY_INSTALL && echo $INSTALLED_PKGS | grep -q "$PKG"; then
		continue
	fi
	nix-env -iA nixpkgs.$PKG
done
