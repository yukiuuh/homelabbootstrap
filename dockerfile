FROM debian:bullseye-slim

LABEL Name=homelabbootstrap Version=0.0.1

ARG USERNAME=debian
ARG GROUPNAME=debian
ARG UID=1000
ARG GID=1000

RUN groupadd -g $GID $GROUPNAME && \
    useradd -m -s /bin/bash -u $UID -g $GID $USERNAME && \
    apt-get update && apt-get install -y --no-install-recommends \
    wget apt-transport-https software-properties-common \
    git python3 python3-pip curl gnupg lsb-release && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* &&\
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" > /etc/apt/sources.list.d/microsoft.list' && \
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg  && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/hashicorp.list && \
    curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
    apt-get update && apt-get install -y --no-install-recommends \
    terraform \
    powershell \
    packer && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -sL https://aka.ms/InstallAzureCLIDeb | bash;

USER $USERNAME
WORKDIR /home/$USERNAME/

RUN pip install pywinrm ansible pyvmomi oci 'ansible[azure]'&& \
    echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.profile && \
    wget https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh && \
    bash ./install.sh --accept-all-defaults && \
    rm ./install.sh && \
    pwsh -c "Install-Module -Name VMware.PowerCLI -force" && \
    pwsh -c " Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP \$True -Confirm:\$False";

CMD ["bash"]
