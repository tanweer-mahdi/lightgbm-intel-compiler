wget https://registrationcenter-download.intel.com/akdlm/irc_nas/18673/l_BaseKit_p_2022.2.0.262_offline.sh
sh ./l_BaseKit_p_2022.2.0.262_offline.sh -a --silent --eula accept
source /opt/intel/oneapi/setvars.sh
cmake -DCMAKE_C_COMPILER=icx -DCMAKE_CXX_COMPILER=icpx ..
make -j4
pip install --no-binary :all: lightgbm
apt-get upgrade libstdc++6
