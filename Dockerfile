FROM openresty/openresty:latest-xenial

ENV CONSUL_VERSION="1.0.6" \
    CONTAINERPILOT_VER="3.6.2" CONTAINERPILOT="/etc/containerpilot.json5" \
    SHELL="/bin/bash"


# Add some stuff via apt-get
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
	    libssl-dev \
    && /usr/local/openresty/luajit/bin/luarocks  install lua-reql \
    && rm -rf /var/lib/apt/lists/*



# The Consul binary
RUN export CONSUL_CHECKSUM=bcc504f658cef2944d1cd703eda90045e084a15752d23c038400cf98c716ea01 \
    && export archive=consul_${CONSUL_VERSION}_linux_amd64.zip \
    && curl -Lso /tmp/${archive} https://releases.hashicorp.com/consul/${CONSUL_VERSION}/${archive} \
    && echo "${CONSUL_CHECKSUM}  /tmp/${archive}" | sha256sum -c \
    && cd /bin \
    && unzip /tmp/${archive} \
    && chmod +x /bin/consul \
    && rm /tmp/${archive} \
# Add Containerpilot and set its configuration
    && export CONTAINERPILOT_CHECKSUM=b799efda15b26d3bbf8fd745143a9f4c4df74da9 \
    && curl -Lso /tmp/containerpilot.tar.gz \
         "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VER}/containerpilot-${CONTAINERPILOT_VER}.tar.gz" \
    && echo "${CONTAINERPILOT_CHECKSUM}  /tmp/containerpilot.tar.gz" | sha1sum -c \
    && tar zxf /tmp/containerpilot.tar.gz -C /usr/local/bin \
    && rm /tmp/containerpilot.tar.gz

# Install Consul template
# Releases at https://releases.hashicorp.com/consul-template/
RUN set -ex \
    && export CONSUL_TEMPLATE_VERSION=0.19.0 \
    && export CONSUL_TEMPLATE_CHECKSUM=31dda6ebc7bd7712598c6ac0337ce8fd8c533229887bd58e825757af879c5f9f \
    && curl --retry 7 --fail -Lso /tmp/consul-template.zip "https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" \
    && echo "${CONSUL_TEMPLATE_CHECKSUM}  /tmp/consul-template.zip" | sha256sum -c \
    && unzip /tmp/consul-template.zip -d /usr/local/bin \
    && rm /tmp/consul-template.zip


# Add our configuration files and scripts
RUN rm -f /etc/nginx/conf.d/default.conf
COPY etc/containerpilot.json5 /etc
COPY etc/consul.hcl  /etc/consul/
COPY bin /usr/local/bin

# Put Consul data on a separate volume to avoid filesystem performance issues
# with Docker image layers. Not necessary on Triton, but...
VOLUME ["/data"]

ENTRYPOINT []

# Consul session data written here
RUN mkdir -p /var/consul

CMD ["/usr/local/bin/containerpilot"]
