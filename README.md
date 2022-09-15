# P4RROT Skeleton Project

An easy way to start using [P4RROT](https://github.com/Team-P4RROT/P4RROT).

## Dependencies

- Make
- git
- virtualenv

## Getting started

1. Clone this repository with the submodules. 

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

## A guided tour

- **codegen.py**: The default place of your processing logic.

- **plugins.py**: If you want to extend P4RROT's functionality, you can define your own commands, fields, and stateful elements here. 

- **Makefile**: A collection of useful tasks.
    - `dev-setup`: creates a venv and installs P4RROT inside it
    - `code-gen`: runs the code generator
    - `stats`: display some stats about the project
    - `update-p4rrot`: gets the latest version of P4RROT and installs it inside the venv.
    - `clean`: removes `.venv` and `output_code` to provide a fresh start
    - By changing the `P4RROT_CODE` and `P4RROT_TEMPLATE` variables, you can provide different logic descriptions and a custom template.


