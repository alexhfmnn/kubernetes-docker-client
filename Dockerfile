FROM debian:bullseye-slim

RUN apt update && \
    apt upgrade -y && \
    apt install -y \
      apt-transport-https \
      bash-completion \
      ca-certificates \
      curl \
      gnupg \
      nano \
    && rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

# Install kubectl , helm, gcloud-cli with bash completions
RUN curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl &&\
    chmod +x /usr/local/bin/kubectl && \
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | tee /usr/share/keyrings/cloud.google.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    apt update && apt install -y \
      helm \
      google-cloud-cli \
      google-cloud-sdk-gke-gcloud-auth-plugin
    && rm -rf /var/cache/apt/archives /var/lib/apt/lists/* && \
    kubectl completion bash | tee /etc/bash_completion.d/kubectl > /dev/null && \
    helm completion bash | tee /etc/bash_completion.d/helm > /dev/null

# Add user
RUN groupadd -r kubernetes && \
    useradd --no-log-init -r -d /home/kubernetes -g kubernetes kubernetes && \
    mkdir -p /home/kubernetes/.kube && \
    cp -rT /etc/skel /home/kubernetes && \
    chown -R kubernetes:kubernetes /home/kubernetes

USER kubernetes
WORKDIR /home/kubernetes
