# daas-runtimes
Runtime definitions to deploy ML/AI models on DaaS (Deployment-as-a-Service)

You can easily create your own runtime image running on DaaS, besides of your own libraries, the [requirements-service.txt](requirements-service.txt) is required to install for the web service runtime.


**Dockerfiles**
- Common AI on CPU: [Dockerfile](Dockerfile), [Instructions](#common-ai-on-cpu)
- ONNX on GPU: [Dockerfile](Dockerfile.onnx), [Instructions](#onnx)
- Pytorch on GPU: [Dockerfile](Dockerfile.pytorch), [Instructions](#pytorch)
- Tensorflow on GPU: [Dockerfile](Dockerfile.tensorflow), [Instructions](#tensorflow)


### Common AI on CPU
**An out-of-box runtime includes all most popular open source [machine learning](requirements-ml.txt) and [deep learning](requirements-dl.txt) libraries running on CPU**

Supported build arguements with default values:
```
base=18.04
CONDA_VERSION=py37_4.8.2
SPARK_VERSION=2.4.8
HADOOP_VERSION=2.7
```

Build the docker image from the Dockerfile in this repository, use `--build-arg` to specify arguements
```
docker build --build-arg base="20.04" -t ai-cpu -f Dockerfile .
```


## ONNX
**ONNX Runtime on GPU**

The default base image of ONNX Runtime:
```
base=v1.5.2-cuda10.2-cudnn8
```

Build the docker image from the Dockerfile in this repository.
```
docker build -t onnx-gpu -f Dockerfile.onnx .
```


## Pytorch
**Pytroch on GPU**

The default base image of Pytorch:
```
base=1.7.0-cuda11.0-cudnn8-runtime
```

Build the docker image from the Dockerfile in this repository.
```
docker build -t pytorch-gpu -f Dockerfile.pytorch .
```


## Tensorflow
**Tensorflow on GPU**

The default base image of Tensorflow:
```
base=2.4.0-gpu
```

Build the docker image from the Dockerfile in this repository.
```
docker build -t tensorflow-gpu -f Dockerfile.tensorflow .
```


## Optional build arguments of mirrors
```
CONDA_MIRROR
APACHE_MIRROR
PIP_MIRROR
APT_MIRROR
```

Build the common AI image using mirrors, for example:
```
docker build --build-arg CONDA_MIRROR="mirrors.ustc.edu.cn/anaconda" --build-arg APACHE_MIRROR="mirrors.ustc.edu.cn/apache"  --build-arg PIP_MIRROR="pypi.mirrors.ustc.edu.cn/simple/" --build-arg APT_MIRROR="mirrors.ustc.edu.cn/ubuntu" -t ai-cpu -f Dockerfile .
```