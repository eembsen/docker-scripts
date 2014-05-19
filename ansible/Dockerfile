FROM centos
MAINTAINER Erwin Embsen eembsen@xebia.com

# Do openssh stuff ...
RUN yum install -y openssh-server
RUN mkdir /var/run/sshd

# Prep account for user ansible
RUN useradd --home-dir /home/ansible --create-home --comment "Ansible Runtime User" --shell /bin/bash ansible
RUN mkdir /home/ansible/.ssh && chmod 700 /home/ansible/.ssh
ADD ./.ssh/id_rsa.pub /home/ansible/.ssh/authorized_keys
RUN chmod 400 /home/ansible/.ssh/authorized_keys
RUN chown -R ansible /home/ansible

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

# Give user ansible a password, this unlocks the account
RUN echo -e 'ansible-login-password\nansible-login-password' | passwd ansible

# Do sudo stuff ...
RUN yum install -y sudo
RUN echo 'ansible ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers

RUN chkconfig iptables off

# Expose port 22 for SSH
EXPOSE 22

CMD /usr/sbin/sshd -D
