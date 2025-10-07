# Dockerfile used to build base image for projects using Python, Node, and Ruby.
FROM phusion/baseimage:jammy-1.0.4

RUN rm /bin/sh && ln -s /bin/bash /bin/sh && \
    sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile

WORKDIR /code

ENV PYENV_ROOT=/root/.pyenv
ENV NVM_DIR=/usr/local/nvm
ENV PATH=$PYENV_ROOT/shims:$PYENV_ROOT/bin:$NVM_DIR/bin:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH


# Install base system libraries.
ENV DEBIAN_FRONTEND=noninteractive
COPY base_dependencies.txt /code/base_dependencies.txt
RUN apt-get update && \
    apt-get install -y $(cat /code/base_dependencies.txt) && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /etc/dpkg/dpkg.cfg.d/02apt-speedup


# Install pyenv, pyenv-virtualenv and default python version.
ENV PYTHONDONTWRITEBYTECODE=true
ENV PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV=true
COPY .python-version /code/.python-version
RUN git clone https://github.com/yyuu/pyenv.git /root/.pyenv && \
    cd /root/.pyenv && \
    git checkout `git describe --abbrev=0 --tags` && \
    echo 'eval "$(pyenv init -)"' >> /etc/profile
RUN git clone https://github.com/pyenv/pyenv-virtualenv.git /root/.pyenv/plugins/pyenv-virtualenv && \
    echo 'eval "$(pyenv virtualenv-init -)"' >> /etc/profile
RUN pyenv install $(cat .python-version) && \
    pyenv global $(cat .python-version) && \
    pip install --upgrade pip


# Install rvm, default ruby version and bundler.
COPY .ruby-version /code/.ruby-version
COPY .gemrc /code/.gemrc
RUN gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
    curl -L https://get.rvm.io | /bin/bash -s stable --ignore-dotfiles && \
    echo 'source /etc/profile.d/rvm.sh' >> /etc/profile && \
    /bin/bash -l -c "rvm requirements;" && \
    rvm install $(cat .ruby-version) && \
    /bin/bash -l -c "rvm use --default $(cat .ruby-version) && \
    gem install bundler" && \
    rvm cleanup all


# Install nvm.
RUN mkdir -p $NVM_DIR && \
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | NVM_DIR=$NVM_DIR bash

# Configure nvm in profile.
RUN echo 'source $NVM_DIR/nvm.sh' >> /etc/profile

# Install default node version.
COPY .nvmrc /code/.nvmrc
RUN /bin/bash -l -c "cd /tmp && source $NVM_DIR/nvm.sh && nvm install \$(cat /code/.nvmrc)"

# Set default node version.
RUN /bin/bash -l -c "source $NVM_DIR/nvm.sh && nvm alias default \$(cat /code/.nvmrc) && nvm use default"

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
