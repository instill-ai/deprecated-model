> [!IMPORTANT]
> This repository has been deprecated and is only intended for launching Instill Core projects up to version `v0.12.0-beta`, where the Instill Model version corresponds to `v0.9.0-alpha`. Please note that `make latest` will fail, but `make all` will still function. For archival purposes, please use released versions to run `make all`. Check the latest Instill Core project in the [instill-ai/core](https://github.com/instill-ai/core) repository.

# Instill Model (Deprecated)

[![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/instill-ai/model?&label=Release&color=blue&include_prereleases&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTQgOEg3VjRIMjNWMTdIMjFDMjEgMTguNjYgMTkuNjYgMjAgMTggMjBDMTYuMzQgMjAgMTUgMTguNjYgMTUgMTdIOUM5IDE4LjY2IDcuNjYgMjAgNiAyMEM0LjM0IDIwIDMgMTguNjYgMyAxN0gxVjEyTDQgOFpNMTggMThDMTguNTUgMTggMTkgMTcuNTUgMTkgMTdDMTkgMTYuNDUgMTguNTUgMTYgMTggMTZDMTcuNDUgMTYgMTcgMTYuNDUgMTcgMTdDMTcgMTcuNTUgMTcuNDUgMTggMTggMThaTTQuNSA5LjVMMi41NCAxMkg3VjkuNUg0LjVaTTYgMThDNi41NSAxOCA3IDE3LjU1IDcgMTdDNyAxNi40NSA2LjU1IDE2IDYgMTZDNS40NSAxNiA1IDE2LjQ1IDUgMTdDNSAxNy41NSA1LjQ1IDE4IDYgMThaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K)](https://github.com/instill-ai/deprecated-model/releases)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/instill-ai)](https://artifacthub.io/packages/helm/instill-ai/model)
[![Discord](https://img.shields.io/discord/928991293856681984?color=blue&label=Discord&logo=discord&logoColor=fff)](https://discord.gg/sevxWsqpGh)
[![Integration Test](https://img.shields.io/github/actions/workflow/status/instill-ai/deprecated-model/integration-test-latest.yml?branch=main&label=Integration%20Test&logoColor=fff&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik0wIDEuNzVDMCAwLjc4NCAwLjc4NCAwIDEuNzUgMEg1LjI1QzYuMjE2IDAgNyAwLjc4NCA3IDEuNzVWNS4yNUM3IDUuNzE0MTMgNi44MTU2MyA2LjE1OTI1IDYuNDg3NDQgNi40ODc0NEM2LjE1OTI1IDYuODE1NjMgNS43MTQxMyA3IDUuMjUgN0g0VjExQzQgMTEuMjY1MiA0LjEwNTM2IDExLjUxOTYgNC4yOTI4OSAxMS43MDcxQzQuNDgwNDMgMTEuODk0NiA0LjczNDc4IDEyIDUgMTJIOVYxMC43NUM5IDkuNzg0IDkuNzg0IDkgMTAuNzUgOUgxNC4yNUMxNS4yMTYgOSAxNiA5Ljc4NCAxNiAxMC43NVYxNC4yNUMxNiAxNC43MTQxIDE1LjgxNTYgMTUuMTU5MiAxNS40ODc0IDE1LjQ4NzRDMTUuMTU5MiAxNS44MTU2IDE0LjcxNDEgMTYgMTQuMjUgMTZIMTAuNzVDMTAuMjg1OSAxNiA5Ljg0MDc1IDE1LjgxNTYgOS41MTI1NiAxNS40ODc0QzkuMTg0MzcgMTUuMTU5MiA5IDE0LjcxNDEgOSAxNC4yNVYxMy41SDVDNC4zMzY5NiAxMy41IDMuNzAxMDcgMTMuMjM2NiAzLjIzMjIzIDEyLjc2NzhDMi43NjMzOSAxMi4yOTg5IDIuNSAxMS42NjMgMi41IDExVjdIMS43NUMxLjI4NTg3IDcgMC44NDA3NTIgNi44MTU2MyAwLjUxMjU2MyA2LjQ4NzQ0QzAuMTg0Mzc0IDYuMTU5MjUgMCA1LjcxNDEzIDAgNS4yNUwwIDEuNzVaTTEuNzUgMS41QzEuNjgzNyAxLjUgMS42MjAxMSAxLjUyNjM0IDEuNTczMjIgMS41NzMyMkMxLjUyNjM0IDEuNjIwMTEgMS41IDEuNjgzNyAxLjUgMS43NVY1LjI1QzEuNSA1LjM4OCAxLjYxMiA1LjUgMS43NSA1LjVINS4yNUM1LjMxNjMgNS41IDUuMzc5ODkgNS40NzM2NiA1LjQyNjc4IDUuNDI2NzhDNS40NzM2NiA1LjM3OTg5IDUuNSA1LjMxNjMgNS41IDUuMjVWMS43NUM1LjUgMS42ODM3IDUuNDczNjYgMS42MjAxMSA1LjQyNjc4IDEuNTczMjJDNS4zNzk4OSAxLjUyNjM0IDUuMzE2MyAxLjUgNS4yNSAxLjVIMS43NVpNMTAuNzUgMTAuNUMxMC42ODM3IDEwLjUgMTAuNjIwMSAxMC41MjYzIDEwLjU3MzIgMTAuNTczMkMxMC41MjYzIDEwLjYyMDEgMTAuNSAxMC42ODM3IDEwLjUgMTAuNzVWMTQuMjVDMTAuNSAxNC4zODggMTAuNjEyIDE0LjUgMTAuNzUgMTQuNUgxNC4yNUMxNC4zMTYzIDE0LjUgMTQuMzc5OSAxNC40NzM3IDE0LjQyNjggMTQuNDI2OEMxNC40NzM3IDE0LjM3OTkgMTQuNSAxNC4zMTYzIDE0LjUgMTQuMjVWMTAuNzVDMTQuNSAxMC42ODM3IDE0LjQ3MzcgMTAuNjIwMSAxNC40MjY4IDEwLjU3MzJDMTQuMzc5OSAxMC41MjYzIDE0LjMxNjMgMTAuNSAxNC4yNSAxMC41SDEwLjc1WiIgZmlsbD0id2hpdGUiLz4KPC9zdmc+Cg==)](https://github.com/instill-ai/deprecated-model/actions/workflows/integration-test-latest.yml?branch=main&event=push)

⚗️ **Instill Model**, or simply **Model**, is an integral component of the [Instill Core](https://github.com/instill-ai/core) project. It serves as an advanced ModelOps/LLMOps platform focused on empowering users to seamlessly import, serve, fine-tune, and monitor Machine Learning (ML) models for continuous optimization.

## Prerequisites

- **macOS or Linux** - Instill Model works on macOS or Linux, but does not support Windows yet.

- **Docker and Docker Compose** - Instill Model uses Docker Compose (specifically, `Compose V2` and `Compose specification`) to run all services at local. Please install the latest stable [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) before using Instill Model.

- `yq` > `v4.x`. Please follow the installation [guide](https://github.com/mikefarah/yq/#install).

- **(Optional) NVIDIA Container Toolkit** - To enable GPU support in Instill Model, please refer to [NVIDIA Cloud Native Documentation](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) to install NVIDIA Container Toolkit. If you'd like to specifically allot GPUs to Instill Model, you can set the environment variable `NVIDIA_VISIBLE_DEVICES`. For example, `NVIDIA_VISIBLE_DEVICES=0,1` will make the `triton-server` consume GPU device id `0` and `1` specifically. By default `NVIDIA_VISIBLE_DEVICES` is set to `all` to use all available GPUs on the machine.

## Quick start

> **Note**
> The image of model-backend (~2GB) and Triton Inference Server (~23GB) can take a while to pull, but this should be an one-time effort at the first setup.

**Preparing to Launch Old Instill Model**

Before executing `make all`, please ensure to make the following replacements in the [Dockerfile](/Dockerfile):

Replace:

```Dockerfile
RUN git clone -b v${INSTILL_CORE_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/core.git
```

with:

```Dockerfile
RUN git clone -b v${INSTILL_CORE_VERSION} -c advice.detachedHead=false https://github.com/instill-ai/deprecated-core.git
```

Replace:

```Dockerfile
RUN git clone https://github.com/instill-ai/core.git
```

with:

```Dockerfile
RUN git clone https://github.com/instill-ai/deprecated-core.git
```

**Use stable release version**

Execute the following commands to pull pre-built images with all the dependencies to launch:

<!-- x-release-please-start-version -->
```bash
$ git clone -b v0.9.0-alpha https://github.com/instill-ai/deprecated-model.git && cd deprecated-model

# Launch all services
$ make all
```
<!-- x-release-please-end -->

🚀 That's it! Once all the services are up with health status, the UI is ready to go at http://localhost:3000. Please find the default login credentials in the [documentation](https://www.instill.tech/docs/latest/quickstart#self-hosted-instill-core).

To shut down all running services:
```
$ make down
```

Explore the [documentation](https://www.instill.tech/docs/latest/core/deployment) to discover all available deployment options.

## Officially supported models

We curate a list of ready-to-use models. These pre-trained models are from different sources and have been trained and deployed by our team. Want to contribute a new model? Please create an issue, we are happy to add it to the list 👐.

| Model                                                                                                                                               | Task                                | Sources                                                                                                                                                                                                                                                      | Framework         | CPU | GPU |
| --------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------- | --- | --- |
| [MobileNet v2](https://github.com/onnx/models/tree/main/vision/classification/mobilenet)                                                            | Image Classification                | [GitHub-DVC](https://github.com/instill-ai/model-mobilenetv2-dvc)                                                                                                                                                                                            | ONNX              | ✅   | ✅   |
| [Vision Transformer (ViT)](https://huggingface.co/google/vit-base-patch16-224)                                                                      | Image Classification                | [Hugging Face](https://huggingface.co/google/vit-base-patch16-224)                                                                                                                                                                                           | ONNX              | ✅   | ❌   |
| [YOLOv4](https://github.com/AlexeyAB/darknet)                                                                                                       | Object Detection                    | [GitHub-DVC](https://github.com/instill-ai/model-yolov4-dvc)                                                                                                                                                                                                 | ONNX              | ✅   | ✅   |
| [YOLOv7](https://github.com/WongKinYiu/yolov7)                                                                                                      | Object Detection                    | [GitHub-DVC](https://github.com/instill-ai/model-yolov7-dvc)                                                                                                                                                                                                 | ONNX              | ✅   | ✅   |
| [YOLOv7 W6 Pose](https://github.com/WongKinYiu/yolov7)                                                                                              | Keypoint Detection                  | [GitHub-DVC](https://github.com/instill-ai/model-yolov7-pose-dvc)                                                                                                                                                                                            | ONNX              | ✅   | ✅   |
| [PSNet](https://github.com/open-mmlab/mmocr/tree/main/configs/textdet/psenet) + [EasyOCR](https://github.com/JaidedAI/EasyOCR)                      | Optical Character Recognition (OCR) | [GitHub-DVC](https://github.com/instill-ai/model-ocr-dvc)                                                                                                                                                                                                    | ONNX              | ✅   | ✅   |
| [Mask RCNN](https://github.com/onnx/models/blob/main/vision/object_detection_segmentation/mask-rcnn/model/MaskRCNN-10.onnx)                         | Instance Segmentation               | [GitHub-DVC](https://github.com/instill-ai/model-instance-segmentation-dvc)                                                                                                                                                                                  | PyTorch           | ✅   | ✅   |
| [Lite R-ASPP based on MobileNetV3](https://github.com/open-mmlab/mmsegmentation/tree/98dfa1749bac0b5281502f4bb3832379da8feb8c/configs/mobilenet_v3) | Semantic Segmentation               | [GitHub-DVC](https://github.com/instill-ai/model-semantic-segmentation-dvc)                                                                                                                                                                                  | ONNX              | ✅   | ✅   |
| [Stable Diffusion](https://huggingface.co/runwayml/stable-diffusion-v1-5)                                                                           | Text to Image                       | [GitHub-DVC](https://github.com/instill-ai/model-diffusion-dvc), [Local-CPU](https://artifacts.instill.tech/vdp/sample-models/stable-diffusion-1-5-cpu.zip), [Local-GPU](https://artifacts.instill.tech/vdp/sample-models/stable-diffusion-1-5-fp16-gpu.zip) | ONNX              | ✅   | ✅   |
| [Stable Diffusion XL](https://huggingface.co/papers/2307.01952)                                                                                     | Text to Image                       | [GitHub-DVC](https://github.com/instill-ai/model-diffusion-xl-dvc)                                                                                                                                                                                           | PyTorch           | ❌   | ✅   |
| [Control Net - Canny](https://huggingface.co/lllyasviel/sd-controlnet-canny)                                                                        | Image to Image                      | [GitHub-DVC](https://github.com/instill-ai/model-controlnet-dvc)                                                                                                                                                                                             | PyTorch           | ❌   | ✅   |
| [Megatron GPT2](https://catalog.ngc.nvidia.com/orgs/nvidia/models/megatron_lm_345m)                                                                 | Text Generation                     | [GitHub-DVC](https://github.com/instill-ai/model-gpt2-megatron-dvc)                                                                                                                                                                                          | FasterTransformer | ❌   | ✅   |
| [Llama2](https://huggingface.co/meta-llama/Llama-2-7b)                                                                                              | Text Generation                     | [GitHub-DVC](https://github.com/instill-ai/model-llama2-7b-dvc)                                                                                                                                                                                              | vLLM, PyTorch     | ✅   | ✅   |
| [Code Llama](https://github.com/facebookresearch/codellama)                                                                                         | Text Generation                     | [GitHub-DVC](https://github.com/instill-ai/model-codellama-7b-dvc)                                                                                                                                                                                           | vLLM              | ❌   | ✅   |
| [Llama2 Chat](https://huggingface.co/meta-llama/Llama-2-13b-chat-hf)                                                                                | Text Generation Chat                | [GitHub-DVC](https://github.com/instill-ai/model-llama2-13b-chat-dvc)                                                                                                                                                                                        | vLLM              | ❌   | ✅   |
| [MosaicML MPT](https://huggingface.co/mosaicml/mpt-7b)                                                                                              | Text Generation Chat                | [GitHub-DVC](https://github.com/instill-ai/model-mpt-7b-dvc)                                                                                                                                                                                                 | vLLM              | ❌   | ✅   |
| [Mistral](https://huggingface.co/mistralai/Mistral-7B-v0.1)                                                                                         | Text Generation Chat                | [GitHub-DVC](https://github.com/instill-ai/model-mistral-7b-dvc)                                                                                                                                                                                             | vLLM              | ❌   | ✅   |
| [Zephyr-7b](https://huggingface.co/HuggingFaceH4/zephyr-7b-alpha)                                                                                   | Text Generation Chat                | [GitHub-DVC](https://github.com/instill-ai/model-zephyr-7b-dvc)                                                                                                                                                                                              | PyTorch           | ✅   | ✅   |
| [Llava](https://huggingface.co/liuhaotian/llava-v1.5-13b)                                                                                           | Visual Question Answering           | [GitHub-DVC](https://github.com/instill-ai/model-llava-7b-dvc)                                                                                                                                                                                               | PyTorch           | ❌   | ✅   |

Note: The `GitHub-DVC` source in the table means importing a model into Instill Model from a GitHub repository that uses [DVC](https://dvc.org) to manage large files.

## License

See the [LICENSE](./LICENSE) file for licensing information.
