# ParallelBezSurf

ParallelBezSurf is a project that utilizes OpenMP and CUDA to accelerate Bezier surface computations.

## Introduction

Bezier surfaces are widely used in computer graphics and modeling. However, the computations involved in evaluating Bezier surfaces can be computationally intensive, especially for large surfaces. This project aims to leverage the power of parallel computing to accelerate the computation of Bezier surfaces using OpenMP and CUDA.
![Bazier Volume](https://i.sstatic.net/vu6KW.gif)
## Features

- Utilizes OpenMP to parallelize the computation of Bezier surfaces on multi-core CPUs.
- Utilizes CUDA to offload the computation of Bezier surfaces to the GPU for even greater acceleration.
- Provides a user-friendly interface for specifying the control points and evaluating the Bezier surfaces.
- Supports both 2D and 3D Bezier surfaces.

## Getting Started

### Prerequisites

- GCC compiler with OpenMP support
- CUDA-enabled GPU (for CUDA acceleration)

### Installation

1. Clone the repository:

    ```shell
    git clone https://github.com/your-username/ParallelBezSurf.git
    ```

2. Build the project:

    ```shell
    cd ParallelBezSurf
    make
    ```

### Usage

1. Modify the control points in the source code to define your desired Bezier surface.

2. Compile and run the program:

    ```shell
    make run
    ```

## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE).

## Acknowledgements

- [OpenMP](https://www.openmp.org/)
- [CUDA](https://developer.nvidia.com/cuda-zone)
- [Bezier Curves and Surfaces](https://en.wikipedia.org/wiki/B%C3%A9zier_curve)