FROM registry.access.redhat.com/ubi9/python-311

COPY iso.py .
COPY getserveriso.sh .

USER 0

RUN pip install selenium
RUN rm -rf /etc/rhsm-host
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm && \
    dnf install -y libX11-devel.x86_64 libXext.x86_64 libwayland-client.x86_64 && \
    dnf install -y google-chrome-stable_current_x86_64.rpm && rm google-chrome-stable_current_x86_64.rpm
RUN ln -s /run/secrets/rhsm /etc/rhsm-host 

USER 1001