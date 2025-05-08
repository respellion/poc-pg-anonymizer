FROM postgres:17

RUN apt-get update && \
    apt-get install -y postgresql-server-dev-17 git make gcc && \
    git clone https://github.com/PsycleResearch/postgresql_anonymizer.git --branch=master --depth=1 /tmp/anon && \
    cd /tmp/anon && \
    make && make install && \
    rm -rf /tmp/anon && \
    apt-get remove --purge -y git make gcc postgresql-server-dev-17 && \
    apt-get autoremove -y && \
    apt-get clean
