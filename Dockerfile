FROM ubuntu
COPY . /home
WORKDIR /home
# initial setup
RUN echo "apt-get update" >> workload.sh
#RUN echo "apt install wget" >> workload.sh
# downloading Intel OpenAPI Base toolkit which contains CPP compiler + MKL + GPU
#RUN echo "wget https://registrationcenter-download.intel.com/akdlm/irc_nas/18673/l_BaseKit_p_2022.2.0.262_offline.sh" >> workload.sh
# installing OpenAPI
#RUN echo "sh ./l_BaseKit_p_2022.2.0.262_offline.sh -a --silent --eula accept" >> workload.sh
# Setting up environment variable
#RUN echo "source /opt/intel/oneapi/setvars.sh" >> workload.sh
# Environment setup is done. Moving to building LightGBM using Intel C++ Compiler
RUN echo "apt install git -y" >> workload.sh
RUN echo "apt install python3-pip -y" >> workload.sh
RUN echo "pip3 install scikit-build" >> workload.sh
RUN echo "pip3 install --upgrade cmake" >> workload.sh
RUN echo "git clone --recursive https://github.com/microsoft/LightGBM" >> workload.sh
RUN echo "cd LightGBM" >> workload.sh
RUN echo "mkdir build" >> workload.sh
RUN echo "cd build" >> workload.sh
#RUN echo "cmake -DCMAKE_C_COMPILER=icx -DCMAKE_CXX_COMPILER=icpx .." >> workload.sh
#RUN echo "make -j4" >> workload.sh
#RUN echo "pip install --no-binary :all: lightgbm" >> workload.sh
RUN sh workload.sh
