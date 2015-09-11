# Docker Base Image with Pyenv, RVM, NVM preinstalled

[![tzenderman/docker-pyenv-rvm-nvm](http://dockeri.co/image/tzenderman/docker-pyenv-rvm-nvm)](https://registry.hub.docker.com/u/tzenderman/docker-pyenv-rvm-nvm/)

You probably already version the packages you use in your project, but have you ever run into an issue where you or other developers on your team can't reproduce an issue exactly the way someone else on the dev team is experiencing it? This really grinds my gears, so I made this image to prevent that situation! With this Docker image, you can version even your project's languages to avoid any silly differences between environments.

NOTE: I used Pyenv, RVM, and NVM because I use Python, Ruby and Node for different things in pretty much all of my projects (Supervisor, SimpleHTTPServer, SASS, Grunt, etc.) and it's comfortable to have these tools pre-baked in my Docker image.

Docker Hub Link: https://registry.hub.docker.com/u/tzenderman/docker-pyenv-rvm-nvm/

## Want to use this in your project?

Simply add

`FROM tzenderman/docker-pyenv-rvm-nvm:latest`

to the top of your Dockerfile and that's it. You'll now have pyenv, nvm and rvm pre-installed in your container. Want to manage your python, ruby and node versions in your project's repo? Simply add the relevant files:

Python: `.python-version`

Ruby: `.ruby-version`

Node: `.nvmrc`

And then manage the install inside your project's Dockerfile like this:

    WORKDIR /code

    COPY .python-version /code/.python-version
    COPY requirements.txt /code/requirements.txt
    RUN yes | pyenv install $(cat .python-version) && \
        pip install -r /code/requirements.txt

    COPY .ruby-version /code/.ruby-version
    COPY .gemrc /code/.gemrc
    COPY Gemfile /code/Gemfile
    RUN rvm install $(cat .ruby-version) && \
        rvm use --default && \
        /bin/bash -l -c "bundle install;"

    COPY .nvmrc /code/.nvmrc
    RUN /bin/bash -l -c "nvm install;" \
        "nvm use;"

Now, when you want to upgrade to a new language version, like Python 3.4, simply update your .python-version to `3.4.0`, rebuild your Docker image, and that's it!

Links:

Pyenv: https://github.com/yyuu/pyenv

RVM: https://rvm.io/

NVM: https://github.com/creationix/nvm
