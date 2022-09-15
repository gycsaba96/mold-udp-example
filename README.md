# MoldUDP example for P4RROT

A motivating examle on how to use [P4RROT](https://github.com/Team-P4RROT/P4RROT) for High-Frequency Trading.

## Dependencies

- Make
- git
- virtualenv
- Netronome SDK

## Getting started

1. Clone this repository. 

2. Initialise your development environment.

    ```console
    make dev-setup
    ```

    This creates a python venv and installs P4RROT inside it.

3. Generate the code for the provided example.

    ```console
    make code-gen
    ```

    This runs P4RROT. The generated P4 code assembled with the default template can be found in the `output_code` directory. 

4. Build the P4 code.

    ```console
    make build
    ```

    This will compile the generated P4 code to both the BMv2 and NFP targets (by calling `p4app` and `nfp4build`). The `config.sh` file might need manual adjustments depending on your exact setup.

5. Deploy the solution on the Netronome smartNIC. 

    ```console
    make deploy SERVER=<server_name>
    ```
