FROM centos
MAINTAINER Erwin Embsen eembsen@xebia.com

# Do openssh stuff ...
RUN yum install -y openssh-server
RUN mkdir /var/run/sshd

# Prep account for user salt
RUN useradd --home-dir /home/salt --create-home --comment "Ansible Runtime User" --shell /bin/bash salt
RUN mkdir /home/salt/.ssh && chmod 700 /home/salt/.ssh
ADD ./.ssh/id_rsa.pub /home/salt/.ssh/authorized_keys
RUN chmod 400 /home/salt/.ssh/authorized_keys
RUN chown -R salt /home/salt

# Do sshd stuff ...
RUN cat /etc/ssh/sshd_config | grep -v '^PasswordAuthentication.*yes' > /tmp/sshd_config.tmp
RUN cp /tmp/sshd_config.tmp /etc/ssh/sshd_config

RUN echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
RUN echo 'PermitRootLogin no' >> /etc/ssh/sshd_config
RUN echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config
RUN echo 'RSAAuthentication yes' >> /etc/ssh/sshd_config

RUN cat /etc/pam.d/sshd | sed 's/session.*required.*pam_loginuid.so/session optional pam_loginuid.so/' > /tmp/sshd.tmp
RUN cp /tmp/sshd.tmp /etc/pam.d/sshd
RUN echo '\n\n' | ssh-keygen -t rsa1 -f /etc/ssh/ssh_host_rsa_key
RUN echo '\n\n' | ssh-keygen -t dsa  -f /etc/ssh/ssh_host_dsa_key

# Give user salt a password, this unlocks the account
RUN echo -e 'salt-login-password\nsalt-login-password' | passwd salt

# Do sudo stuff ...
RUN yum install -y sudo
RUN echo 'salt ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers

# Do Salt stuff ...
RUN rpm -Uvh http://ftp.linux.ncsu.edu/pub/epel/6/i386/epel-release-6-8.noarch.rpm
RUN yum install -y salt-minion
RUN chkconfig salt-minion on

# Do iptables stuff ...
RUN chkconfig iptables off

# Expose port 22 for SSH
EXPOSE 22

CMD /usr/sbin/sshd -D
