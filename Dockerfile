# Start with a custom image with pre-installed tools:
FROM ghcr.io/digipres/toolbox:master

# Add the Jupyter things we need
RUN pip install --no-cache-dir jupyterlab notebook pandas altair requests bash_kernel && python -m bash_kernel.install

# Switch off announcements pop-up
RUN jupyter labextension disable "@jupyterlab/apputils-extension:announcements"

# Do required setup for running on Binder...
# https://mybinder.readthedocs.io/en/latest/tutorials/dockerfile.html
ARG NB_USER=jovyan
ARG NB_UID=1000

ARG USERNAME=$NB_USER
ARG USER_UID=$NB_UID
ARG USER_GID=$USER_UID
# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /bin/bash $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set the working directory
WORKDIR /home/${NB_USER}

# Make sure the contents of our repo are in ${HOME}
COPY welcome.ipynb README.md ./
COPY rclone.conf .config/rclone/rclone.conf
ADD notebooks notebooks
ADD test-files test-files

# Set up the workspace so the startup looks consistent
COPY default.jupyterlab-workspace workspace.json
RUN jupyter lab workspaces import workspace.json && rm workspace.json

# Also install the lc-shell files in case anyone wants them:
RUN curl -O -L https://librarycarpentry.org/lc-shell/data/shell-lesson.zip && \
    unzip shell-lesson.zip -d shell-lesson -x '__MACOSX/*' && \
    rm shell-lesson.zip

# Switch to the run-time user
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}
