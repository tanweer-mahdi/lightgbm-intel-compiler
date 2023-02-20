FROM ubuntu
COPY . /home
WORKDIR /home
RUN echo "apt-get update" >> workload.sh
RUN echo "apt install git -y" >> workload.sh
RUN echo "apt install python3-pip -y" >> workload.sh
RUN echo "pip3 install scikit-build" >> workload.sh
RUN echo "pip3 install --upgrade cmake" >> workload.sh
RUN echo "git clone --recursive https://github.com/microsoft/LightGBM" >> workload.sh
RUN echo "cd LightGBM" >> workload.sh
RUN echo "mkdir build" >> workload.sh
RUN echo "cd build" >> workload.sh
RUN sh workload.sh
