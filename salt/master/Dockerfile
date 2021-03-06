FROM centos
MAINTAINER Erwin Embsen eembsen@xebia.com

# Do openssh stuff ...
RUN yum install -y openssh-server
RUN mkdir /var/run/sshd

# Prep account for user salt
RUN useradd --home-dir /home/salt --create-home --comment "Salt Runtime User" --shell /bin/bash salt --password salt-login-account
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

# Do sudo stuff ...
RUN yum install -y sudo
RUN echo 'salt ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers

# Do Salt stuff ...
RUN rpm -Uvh http://ftp.linux.ncsu.edu/pub/epel/6/i386/epel-release-6-8.noarch.rpm
RUN yum install -y salt-master --enablerepo=epel-testing
RUN chkconfig salt-master on
RUN yum install -y salt-minion --enablerepo=epel-testing
RUN chkconfig salt-minion on
RUN [ ! -d /etc/salt/master.d ] && mkdir /etc/salt/master.d > /dev/null
RUN echo "auto_accept: True" > /etc/salt/master.d/auto_accept.conf
RUN [ ! -d /etc/salt/minion.d ] && mkdir /etc/salt/minion.d > /dev/null
RUN echo "master: localhost" > /etc/salt/minion.d/master.conf

# Do iptables stuff ...
RUN chkconfig iptables off

# Expose port 22 for SSH
EXPOSE 22

# Build a file /etc/rc.local
RUN echo "# THIS FILE WAS CREATED BY docker (http://docker.io)" > /etc/rc.local
RUN echo "service salt-master start" >> /etc/rc.local
RUN echo "sleep 30" >> /etc/rc.local
RUN echo "service salt-minion start" >> /etc/rc.local
RUN echo "/usr/sbin/sshd -D" >> /etc/rc.local

CMD /etc/rc.local
