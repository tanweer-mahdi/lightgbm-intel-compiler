# lightgbm-intel-compiler 
Compiling LightGBM from source with Intel OneAPI Data Parallel C++ compilers (also known as DCPP)

### Motivation:
Directly quoting from [LightGBM FAQ](https://lightgbm.readthedocs.io/en/latest/FAQ.html#lightgbm-hangs-when-multithreading-openmp-and-using-forking-in-linux-at-the-same-time):
> There is a bug with OpenMP which hangs forked sessions with multithreading activated. A more expensive solution is to use new processes instead of using fork, however, keep in mind it is creating new processes where you have to copy memory and load libraries (example: if you want to fork 16 times your current process, then you will require to make 16 copies of your dataset in memory) (see [Microsoft/LightGBM#1789](https://github.com/microsoft/LightGBM/issues/1789#issuecomment-433713383)).

The straightforward workaround for this bug is to disable multithreading. However, sometimes it is not just as practical. Especially when training with large dataset in the prod and you have a stringent SLA to maintain. 

This is a demonstration of how to compile LightGBM from source using [Intel OneAPI DPC++ compiler](https://www.intel.com/content/www/us/en/develop/documentation/get-started-with-dpcpp-compiler/top.html) followed by some additional steps. For reproducibility, the demonstration is done in a Docker container. I have used a basic `ubuntu` image to explicitly show the dependencies required. 

### Usage:
#### Installing and setting up the compiler
- clone the repo
- cd the repo, build the Docker image with a tag (using `lgbm` here)
```
docker build -t lgbm .
```
- Run the container in interactive mode
```
docker run -t lgbm
```
- Install the Intel OneAPI base toolkit in the container (it includes both DCPP and OpenMP). [Check here](https://www.intel.com/content/www/us/en/developer/tools/oneapi/base-toolkit-download.html?operatingsystem=linux&distributions=online) for more details
```
wget https://registrationcenter-download.intel.com/akdlm/irc_nas/18673/l_BaseKit_p_2022.2.0.262_offline.sh
```
- Install the compiler. Disclaimer: it takes quite some time.
```
sh ./l_BaseKit_p_2022.2.0.262_offline.sh -a --silent --eula accept
```
- Set the environment variables using `source`
```
source /opt/intel/oneapi/setvars.sh
```
#### Compile LightGBM from source using `CMAKE`
- change directory to the `/home/LightGBM/build`
- Invoke CMAKE with the `DCMAKE_C_COMPILER` and `DCMAKE_CXX_COMPILER` flags to enable the Intel compilers
```
cmake -DCMAKE_C_COMPILER=icx -DCMAKE_CXX_COMPILER=icpx ..
make -j4
```
#### Install LightGBM
Now the compilation using Intel compiler is done, we can proceed to the installation of LightGBM. All we need is to use the `no-binary` flag with `pip install` to accomplish it
```
pip install --no-binary :all: lightgbm
```

One last step remains. That is to make sure that the required `GLIBCXX` version is available. I have not found a streamlined process for that yet but the following steps do the trick. First, update the the libstdc++6 as following:
```
apt-get upgrade libstdc++6
```
The upgraded libstdc++6 soft link can be found under `/usr/lib/x86_64-linux-gnu/`. We simply copy that to the following path to resolve the version mismatch flagged by LightGBM:
```
cp /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /opt/intel/oneapi/intelpython/python3.9/lib/
```

LightGBM requires GLIBCXX >= 3.4.29. To check that you have the required version, change directory to `/opt/intel/oneapi/intelpython/python3.9/lib/` and run the following command
```
strings libstdc++.so.6 | grep GLIBCXX
```
You should see an output like the following:

```
GLIBCXX_3.4
GLIBCXX_3.4.1
GLIBCXX_3.4.2
GLIBCXX_3.4.3
GLIBCXX_3.4.4
GLIBCXX_3.4.5
GLIBCXX_3.4.6
GLIBCXX_3.4.7
GLIBCXX_3.4.8
GLIBCXX_3.4.9
GLIBCXX_3.4.10
GLIBCXX_3.4.11
GLIBCXX_3.4.12
GLIBCXX_3.4.13
GLIBCXX_3.4.14
GLIBCXX_3.4.15
GLIBCXX_3.4.16
GLIBCXX_3.4.17
GLIBCXX_3.4.18
GLIBCXX_3.4.19
GLIBCXX_3.4.20
GLIBCXX_3.4.21
GLIBCXX_3.4.22
GLIBCXX_3.4.23
GLIBCXX_3.4.24
GLIBCXX_3.4.25
GLIBCXX_3.4.26
GLIBCXX_3.4.27
GLIBCXX_3.4.28
GLIBCXX_3.4.29
GLIBCXX_3.4.30
GLIBCXX_DEBUG_MESSAGE_LENGTH
```
Done. You are good to import LightGBM in any python script now! :rocket:
