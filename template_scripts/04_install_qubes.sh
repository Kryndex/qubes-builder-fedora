#!/bin/bash

source "${SCRIPTSDIR}/distribution.sh"

prepareChroot

export YUM0=$PWD/pkgs-for-template

echo "--> Installing RPMs..."
if [ "$TEMPLATE_FLAVOR" != "minimal" ]; then
    installPackages packages_qubes.list || RETCODE=1
else
    installPackages packages_qubes_minimal.list || RETCODE=1
fi

chroot_cmd sh -c 'rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-qubes-*'

if [ "$TEMPLATE_FLAVOR" != "minimal" ]; then
    echo "--> Installing 3rd party apps"
    $SCRIPTSDIR/add_3rd_party_software.sh || RETCODE=1
fi


if [ "$TEMPLATE_FLAVOR" != "minimal" ]; then
    # this is mostly legacy stuff as newer fedora don't have this file
    if [ -e mnt/etc/sysconfig/i18n ]; then
        echo "--> Setting up default locale..."
        echo LC_CTYPE=en_US.UTF-8 > mnt/etc/sysconfig/i18n
    fi
else
    # for minimal template reset LANG to "C", but only if was set previously
    if grep -q LANG= ${INSTALLDIR}/etc/locale.conf 2>/dev/null; then
        sed -e 's/^LANG=.*/LANG=C/' -i ${INSTALLDIR}/etc/locale.conf
    fi
fi

# Distribution specific steps
source ./functions.sh
buildStep "${0}" "${DIST}"

exit $RETCODE
