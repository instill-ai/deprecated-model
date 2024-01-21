# Instill Model

[![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/instill-ai/model?&label=Release&color=blue&include_prereleases&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTQgOEg3VjRIMjNWMTdIMjFDMjEgMTguNjYgMTkuNjYgMjAgMTggMjBDMTYuMzQgMjAgMTUgMTguNjYgMTUgMTdIOUM5IDE4LjY2IDcuNjYgMjAgNiAyMEM0LjM0IDIwIDMgMTguNjYgMyAxN0gxVjEyTDQgOFpNMTggMThDMTguNTUgMTggMTkgMTcuNTUgMTkgMTdDMTkgMTYuNDUgMTguNTUgMTYgMTggMTZDMTcuNDUgMTYgMTcgMTYuNDUgMTcgMTdDMTcgMTcuNTUgMTcuNDUgMTggMTggMThaTTQuNSA5LjVMMi41NCAxMkg3VjkuNUg0LjVaTTYgMThDNi41NSAxOCA3IDE3LjU1IDcgMTdDNyAxNi40NSA2LjU1IDE2IDYgMTZDNS40NSAxNiA1IDE2LjQ1IDUgMTdDNSAxNy41NSA1LjQ1IDE4IDYgMThaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K)](https://github.com/instill-ai/model/releases)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/instill-ai)](https://artifacthub.io/packages/helm/instill-ai/model)
[![Discord](https://img.shields.io/discord/928991293856681984?color=blue&label=Discord&logo=discord&logoColor=fff)](https://discord.gg/sevxWsqpGh)
[![Integration Test](https://img.shields.io/github/actions/workflow/status/instill-ai/model/integration-test-latest.yml?branch=main&label=Integration%20Test&logoColor=fff&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik0wIDEuNzVDMCAwLjc4NCAwLjc4NCAwIDEuNzUgMEg1LjI1QzYuMjE2IDAgNyAwLjc4NCA3IDEuNzVWNS4yNUM3IDUuNzE0MTMgNi44MTU2MyA2LjE1OTI1IDYuNDg3NDQgNi40ODc0NEM2LjE1OTI1IDYuODE1NjMgNS43MTQxMyA3IDUuMjUgN0g0VjExQzQgMTEuMjY1MiA0LjEwNTM2IDExLjUxOTYgNC4yOTI4OSAxMS43MDcxQzQuNDgwNDMgMTEuODk0NiA0LjczNDc4IDEyIDUgMTJIOVYxMC43NUM5IDkuNzg0IDkuNzg0IDkgMTAuNzUgOUgxNC4yNUMxNS4yMTYgOSAxNiA5Ljc4NCAxNiAxMC43NVYxNC4yNUMxNiAxNC43MTQxIDE1LjgxNTYgMTUuMTU5MiAxNS40ODc0IDE1LjQ4NzRDMTUuMTU5MiAxNS44MTU2IDE0LjcxNDEgMTYgMTQuMjUgMTZIMTAuNzVDMTAuMjg1OSAxNiA5Ljg0MDc1IDE1LjgxNTYgOS41MTI1NiAxNS40ODc0QzkuMTg0MzcgMTUuMTU5MiA5IDE0LjcxNDEgOSAxNC4yNVYxMy41SDVDNC4zMzY5NiAxMy41IDMuNzAxMDcgMTMuMjM2NiAzLjIzMjIzIDEyLjc2NzhDMi43NjMzOSAxMi4yOTg5IDIuNSAxMS42NjMgMi41IDExVjdIMS43NUMxLjI4NTg3IDcgMC44NDA3NTIgNi44MTU2MyAwLjUxMjU2MyA2LjQ4NzQ0QzAuMTg0Mzc0IDYuMTU5MjUgMCA1LjcxNDEzIDAgNS4yNUwwIDEuNzVaTTEuNzUgMS41QzEuNjgzNyAxLjUgMS42MjAxMSAxLjUyNjM0IDEuNTczMjIgMS41NzMyMkMxLjUyNjM0IDEuNjIwMTEgMS41IDEuNjgzNyAxLjUgMS43NVY1LjI1QzEuNSA1LjM4OCAxLjYxMiA1LjUgMS43NSA1LjVINS4yNUM1LjMxNjMgNS41IDUuMzc5ODkgNS40NzM2NiA1LjQyNjc4IDUuNDI2NzhDNS40NzM2NiA1LjM3OTg5IDUuNSA1LjMxNjMgNS41IDUuMjVWMS43NUM1LjUgMS42ODM3IDUuNDczNjYgMS42MjAxMSA1LjQyNjc4IDEuNTczMjJDNS4zNzk4OSAxLjUyNjM0IDUuMzE2MyAxLjUgNS4yNSAxLjVIMS43NVpNMTAuNzUgMTAuNUMxMC42ODM3IDEwLjUgMTAuNjIwMSAxMC41MjYzIDEwLjU3MzIgMTAuNTczMkMxMC41MjYzIDEwLjYyMDEgMTAuNSAxMC42ODM3IDEwLjUgMTAuNzVWMTQuMjVDMTAuNSAxNC4zODggMTAuNjEyIDE0LjUgMTAuNzUgMTQuNUgxNC4yNUMxNC4zMTYzIDE0LjUgMTQuMzc5OSAxNC40NzM3IDE0LjQyNjggMTQuNDI2OEMxNC40NzM3IDE0LjM3OTkgMTQuNSAxNC4zMTYzIDE0LjUgMTQuMjVWMTAuNzVDMTQuNSAxMC42ODM3IDE0LjQ3MzcgMTAuNjIwMSAxNC40MjY4IDEwLjU3MzJDMTQuMzc5OSAxMC41MjYzIDE0LjMxNjMgMTAuNSAxNC4yNSAxMC41SDEwLjc1WiIgZmlsbD0id2hpdGUiLz4KPC9zdmc+Cg==)](https://github.com/instill-ai/model/actions/workflows/integration-test-latest.yml?branch=main&event=push)

⚗️ **Instill Model** manages the AI model-related resources and features working with [**Instill VDP**](https://github.com/instill-ai/vdp).

**☁️ [Instill Cloud](https://console.instill.tech)** offers a fully managed public cloud service, providing you with access to all the fantastic features of unstructured data ETL without the burden of infrastructure management.

## Highlights

- ⚡️ **[High-performing inference](https://www.instill.tech/docs/prepare-models/overview)** implemented in Go with Triton Inference Server for unleashing the full power of NVIDIA GPU architecture (e.g., concurrency, scheduler, batcher) supporting TensorRT, PyTorch, TensorFlow, ONNX, Python and more.

- 🖱️ **[One-click model deployment](https://www.instill.tech/docs/import-models/overview)** from GitHub, Hugging Face or cloud storage managed by version control tools like [DVC](https://github.com/iterative/dvc) or [ArtiVC](https://github.com/InfuseAI/ArtiVC).

- 📦 **[Standardised AI Task](https://www.instill.tech/docs/core-concepts/ai-task)** output formats to streamline data integration or analysis

## Prerequisites

- **macOS or Linux** - VDP works on macOS or Linux, but does not support Windows yet.

- **Docker and Docker Compose** - VDP uses Docker Compose (specifically, `Compose V2` and `Compose specification`) to run all services at local. Please install the latest stable [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) before using VDP.

- `yq` > `v4.x`. Please follow the installation [guide](https://github.com/mikefarah/yq/#install).

- **(Optional) NVIDIA Container Toolkit** - To enable GPU support in VDP, please refer to [NVIDIA Cloud Native Documentation](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) to install NVIDIA Container Toolkit. If you'd like to specifically allot GPUs to VDP, you can set the environment variable `NVIDIA_VISIBLE_DEVICES`. For example, `NVIDIA_VISIBLE_DEVICES=0,1` will make the `triton-server` consume GPU device id `0` and `1` specifically. By default `NVIDIA_VISIBLE_DEVICES` is set to `all` to use all available GPUs on the machine.

## Quick start

> **Note**
> The image of model-backend (~2GB) and Triton Inference Server (~23GB) can take a while to pull, but this should be an one-time effort at the first setup.

**Use stable release version**

Execute the following commands to pull pre-built images with all the dependencies to launch:

<!-- x-release-please-start-version -->
```bash
$ git clone -b v0.7.0-alpha https://github.com/instill-ai/model.git && cd model

# Launch all services
$ make all
```
<!-- x-release-please-end -->

**Use latest version for local development**

Execute the following commands to build images with all the dependencies to launch:

```bash
$ git clone https://github.com/instill-ai/model.git && cd model

# Launch all services
$ make latest PROFILE=all
```

> **Note**
> Code in the main branch tracks under-development progress towards the next release and may not work as expected. If you are looking for a stable alpha version, please use [latest release](https://github.com/instill-ai/vdp/releases).

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

Note: The `GitHub-DVC` source in the table means importing a model into VDP from a GitHub repository that uses [DVC](https://dvc.org) to manage large files.

## The Unstructured Data ETL Stack

Explore the open-source unstructured data ETL stack, comprising a collection of source-available projects designed to streamline every aspect of building versatile AI features with unstructured data.

<div align="center">
  <img src="https://raw.githubusercontent.com/instill-ai/.github/main/img/instill-projects.svg" width=80%>
  <br>
    <em>Open Source Unstructured Data ETL Stack</em>
</div>
<br>
<details>
  <summary><b>🔮 <a href="https://github.com/instill-ai/core" target="_blank">Instill Core</a>: The foundation for unstructured data ETL stack</b></summary><br>

  **Instill Core**, or **Core**, serves as the bedrock upon which open-source unstructured data stack thrive. Essential services such as user management servers, databases, and third-party observability tools find their home here. Instill Core also provides deployment codes to facilitate the seamless launch of both Instill VDP and Instill Model.
</details>

<details>
  <summary><b>💧 <a href="https://github.com/instill-ai/vdp" target="_blank">Instill VDP</a>: AI pipeline builder for unstructured data</b></summary><br>

  **Instill VDP**, or **VDP (Versatile Data Pipeline)**, represents a comprehensive unstructured data ETL. Its purpose is to simplify the journey of processing unstructured data from start to finish:

  - **Extract:** Gather unstructured data from diverse sources, including AI applications, cloud/on-prem storage, and IoT devices.
  - **Transform:** Utilize AI models to convert raw data into meaningful insights and actionable formats.
  - **Load:** Efficiently move processed data to warehouses, applications, or other destinations.

  Embracing VDP is straightforward, whether you opt for Instill Cloud deployment or self-hosting via Instill Core.
</details>

<details>
  <summary><b>⚗️ <a href="https://github.com/instill-ai/model" target="_blank">Instill Model</a>: Scalable AI model serving and training</b></summary><br>

  **Instill Model**, or simply **Model**, emerges as an advanced ModelOps platform. Here, the focus is on empowering you to seamlessly import, train, and serve Machine Learning (ML) models for inference purposes. Like other projects, Instill Model's source code is available for your exploration.
</details>

### No-Code/Low-Code Access

To access Instill Core and Instill Cloud, we provide:

- ⛅️ [Console](https://github.com/instill-ai/console) for non-developers, empowering them to dive into AI applications and process unstructured data without any coding.
- 🧰 CLI and SDKs for developers to seamlessly integrate with their existing data stack in minutes.
  - [Instill CLI](https://github.com/instill-ai/cli)
  - [Python SDK](https://github.com/instill-ai/python-sdk)
  - [TypeScript SDK](https://github.com/instill-ai/typescript-sdk)

## Documentation

 Please check out the [documentation](https://www.instill.tech/docs?utm_source=github&utm_medium=link&utm_campaign=core) website.

## Contributing

Please refer to the [Contributing Guidelines](./.github/CONTRIBUTING.md) for more details.

## Be Part of Us

We strongly believe in the power of community collaboration and deeply value your contributions. Head over to our [Community](https://github.com/instill-ai/community) repository, the central hub for discussing our open-source projects, raising issues, and sharing your brilliant ideas.

## License

See the [LICENSE](./LICENSE) file for licensing information.
