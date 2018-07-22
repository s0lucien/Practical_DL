FROM debian:stretch-slim

ENV BUILD_PACKAGES="\
        build-essential \
        cmake \
        curl \
        gcc \
        git \
        linux-headers-4.9 \
        make \
        tcl-dev \
        xz-utils \
        zlib1g-dev \
        " \
    APT_PACKAGES="\
        bash \
        ca-certificates \
        fonts-noto \
        graphviz \
        libbz2-dev \
        libpng16-16 \
        libfreetype6 \
        libgomp1 \
        libjpeg62-turbo \
        libreadline-dev \
        libssl-dev \
        libsqlite3-dev \
        openssl \
        zlib1g-dev \
        "

RUN set -ex; \
    apt-get update && apt-get install -y --no-install-recommends ${BUILD_PACKAGES};

RUN set -ex; \
    apt-get update && apt-get install -y --no-install-recommends ${APT_PACKAGES};


WORKDIR /home
ENV HOME=/home \
    PYENV_ROOT=/home/.pyenv \
    PYTHON_VERSION=3.6.6 \
    PATH=/home/.pyenv/shims:/home/.pyenv/bin:$PATH \
    JUPYTER_CONFIG_DIR=/home/.ipython/profile_default/startup \
    LANG=C.UTF-8

RUN set -ex; \   
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash;\
    echo "export PATH=\"/home/.pyenv/bin:$PATH\"" | tee -a ${HOME}/.bash_profile; \
    echo "$(pyenv init -)" | tee -a ${HOME}/.bash_profile; \
    echo "$(pyenv virtualenv-init -)" | tee -a ${HOME}/.bash_profile; \
    pyenv install ${PYTHON_VERSION}; \
    pyenv global ${PYTHON_VERSION};
    
ENV PIP_PACKAGES="\
        cffi \
        editdistance \
        graphviz \
        h5py \
        http://download.pytorch.org/whl/cpu/torch-0.3.1-cp36-cp36m-linux_x86_64.whl \
        ipywidgets \
        joblib \
        keras \
        requests \
        pandas \
        pillow \
        pyyaml \
        pymkl \
        matplotlib \
        mxnet-mkl\
        nltk \
        notebook \
        numpy \
        scipy \
        scikit-learn \
        seaborn \
        tensorflow \
        torchvision \
        tqdm \
        xgboost \
        "

RUN set -ex; \
    pip install -U -v pip; \
    pip install -U -v ${PIP_PACKAGES}; \
    pip install https://github.com/Theano/Theano/archive/master.zip; \
    pip install https://github.com/Lasagne/Lasagne/archive/master.zip;\
    jupyter nbextension enable --py widgetsnbextension; \
    pyenv rehash; \
    mkdir -p ${JUPYTER_CONFIG_DIR}; \
    echo "import warnings" | tee ${JUPYTER_CONFIG_DIR}/config.py; \
    echo "warnings.filterwarnings('ignore')" | tee -a ${JUPYTER_CONFIG_DIR}/config.py; \
    echo "c.NotebookApp.token = u''" | tee -a ${JUPYTER_CONFIG_DIR}/config.py ;


EXPOSE 8888 6006

RUN mkdir /home/workspace 

CMD [ "jupyter", "notebook", "--port=8888", "--no-browser", \
    "--allow-root", "--ip=0.0.0.0", "--NotebookApp.token=", \
    "--notebook-dir=/home/workspace" ]

# build with
# λ docker build . -t pydl:ready

# start with 
# λ docker run -p 8888:8888 -p 6006:6006 -it -v c:/Code/own/Practical_DL:/home/workspace pydl:ready