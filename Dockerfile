FROM centos:7

MAINTAINER Luciano Resende <lresende@apache.org>

USER root

# Clean metadata to avoid 404 erros from yum
RUN yum clean all

# Install basic packages
RUN yum install -y awk curl openssh-server openssh-clients openssl rsync ntpd sudo tar wget which #openssl-1.0.1e-16.el6.x86_64
RUN yum update -y libselinux

# passwordless ssh
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
    ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh && \
    ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa && \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys && \
    chmod 600 /root/.ssh/authorized_keys && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 644 /root/.ssh/id_rsa.pub
ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config && \
    chown root:root /root/.ssh/config

# update root password
RUN echo 'root:passw0rd' | chpasswd

# install OpenJDK
RUN yum install -y java-1.8.0-openjdk
ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin

# fix the 254 error code
RUN sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config && \
    echo "UsePAM no" >> /etc/ssh/sshd_config && \
    echo "Port 2122" >> /etc/ssh/sshd_config

CMD ["/bin/bash", ""]
