
FROM alpine:3.11.2 AS COMMON

RUN apk --no-cache --update add python git bash


FROM common as builder

RUN apk --update add curl

## would love to use args... but I need it as an environment variable
ENV KAL_SHLIB_CORE_VERSION="0.7.0" \
    KAL_SHLIB_COMMON_VERSION="0.4.17" \
    KAL_SHLIB_PRETTY_VERSION="0.4.3"

## install kal-shlibs
RUN apk --update add binutils && \
    mkdir /tmp/kal-shlibs && cd /tmp/kal-shlibs && \
    export pkg && \
    for pkg in core common pretty; do \
        echo "Installing kal-shlib-$pkg" ; \
        bash -c -- 'eval curl -L http://deb.kalysto.org/pool/no-dist/kal-alpha/kal-shlib-${pkg}_\${KAL_SHLIB_${pkg^^}_VERSION}-1_all.deb' > pkg.deb || exit 1 ; \
        ar x pkg.deb || exit 1; \
        tar xf /tmp/kal-shlibs/data.tar.* -C / || exit 1; \
        rm /tmp/kal-shlibs/data.tar.* ; \
    done

RUN apk add python-dev build-base
RUN apk add yaml-dev cython cython-dev py-pip && \
    pip install shyaml


FROM common

COPY --from=builder /etc/shlib /etc/shlib
COPY --from=builder /usr/bin/bash-shlib /usr/bin/bash-shlib
COPY --from=builder /usr/bin/shld /usr/bin/shld
COPY --from=builder /usr/lib/shlib /usr/lib/shlib
COPY --from=builder /usr/bin/shyaml /usr/bin/shyaml
COPY --from=builder /usr/lib/python2.7/site-packages/ /usr/lib/python2.7/site-packages/
COPY --from=builder /usr/local /usr/local

COPY ./bin/ /usr/local/bin/

apk add file  ## for shld

ENTRYPOINT ["/usr/local/bin/git-irebase"]