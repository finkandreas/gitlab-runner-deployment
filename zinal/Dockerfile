FROM docker.io/opensuse/leap:15.3

# We need git, install it with zypper
RUN zypper --non-interactive install \
    git \
    curl \
    python3 \
    hostname \
    jq \
  && zypper --non-interactive clean -a \
  && rm -Rf /var/log/zypp /var/log/zypper.log

# install gitlab-runner in /usr/local/bin
RUN curl -L "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64" > /usr/local/bin/gitlab-runner \
  && chmod +x /usr/local/bin/gitlab-runner

# copy the runners into the container
COPY sarus-fake /usr/local/bin/sarus
COPY gitlab-runner-multimode /home/someuser/gitlab-runner
COPY container-runner-defaults.sh /home/someuser/gitlab-runner/modes/container-runner/etc/defaults.sh
COPY slurm-baremetal-defaults.sh /home/someuser/gitlab-runner/modes/slurm-baremetal/etc/defaults.sh

RUN cd /home/someuser/gitlab-runner/modes \
  && ln -s container-runner container \
  && ln -s baremetal-runner spack-stack-builder

# add someuser
ARG USER_ID
ARG GROUP_ID
RUN groupadd -g $GROUP_ID defgroup && useradd -m -u $USER_ID -g defgroup someuser

