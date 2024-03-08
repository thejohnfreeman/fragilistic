#!/usr/bin/env sh
set -ex
pkgtype=$1
if [ "${pkgtype}" = "rpm" ] ; then
    container_name="${RPM_CONTAINER_FULLNAME}"
    container_tag="${RPM_CONTAINER_TAG}"
elif [ "${pkgtype}" = "dpkg" ] ; then
    container_name="${DPKG_CONTAINER_FULLNAME}"
    container_tag="${DPKG_CONTAINER_TAG}"
else
    echo "invalid package type"
    exit 1
fi
time docker pull "${ARTIFACTORY_HUB}/${container_name}"
docker tag \
  "${ARTIFACTORY_HUB}/${container_name}" \
  "${container_name}"
docker images

test -d build && rm -rf build
mkdir -p build/${pkgtype}

container_label=${container_tag}

docker run \
    -v ${PWD}:/opt/rippled_bld/pkg/rippled \
    -v ${PWD}/build/${pkgtype}:/opt/rippled_bld/pkg/out \
    -t rippled-${pkgtype}-builder:${container_label} \
    /bin/bash -c "cp -fpu fragilistic/packaging/${pkgtype}/build_${pkgtype}.sh . && ./build_${pkgtype}.sh"
