FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Java and utilities
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    curl \
    wget \
    gnupg \
    apt-transport-https \
    ca-certificates \
    net-tools \
    iputils-ping \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add Jenkins repo using apt-key (the method that works on Ubuntu 18.04)
RUN curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
    | apt-key add - \
    && echo "deb https://pkg.jenkins.io/debian-stable binary/" \
    > /etc/apt/sources.list.d/jenkins.list

# Install Jenkins
RUN apt-get update && apt-get install -y jenkins \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create log directory with open permissions so jenkins user can write
RUN mkdir -p /var/log/webz \
    && chown jenkins:jenkins /var/log/webz \
    && chmod 755 /var/log/webz

# Jenkins home directory
ENV JENKINS_HOME=/var/lib/jenkins

# Skip the first-run setup wizard
RUN mkdir -p $JENKINS_HOME && \
    echo "2.0" > $JENKINS_HOME/jenkins.install.InstallUtil.lastExecVersion && \
    echo "2.0" > $JENKINS_HOME/jenkins.install.UpgradeWizard.state

# Pre-load the webz-monitor job
COPY jobs/webz-monitor/config.xml $JENKINS_HOME/jobs/webz-monitor/config.xml
RUN chown -R jenkins:jenkins $JENKINS_HOME

# Copy the standalone script (useful for manual testing)
COPY webz-monitor.sh /usr/local/bin/webz-monitor.sh
RUN chmod +x /usr/local/bin/webz-monitor.sh

EXPOSE 8080

USER jenkins
CMD ["/usr/bin/java", "-jar", "/usr/share/jenkins/jenkins.war", \
     "--httpPort=8080", "--webroot=/var/cache/jenkins/war"]