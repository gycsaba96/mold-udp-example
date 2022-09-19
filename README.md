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

The `mold-udp/server.py` and  `mold-udp/client.py` scripts can be used to test the functionality of the solution.

## Measure the performance

### Offloaded solution

1. Start the RTE provided by Netronome.

2. Deploy the generated code. 

    ```console
    make deploy SERVER=<server_name>
    ```

3. Configure the ethernet ports (IP address, netmask, etc.).

4. Start the `mold-udp/measurement_server.py` script on the same machine as your smartNIC is.

    ```console
    python3 measurement_server.py <scenario-name>
    ```

5. Start the `mold-udp/client.py` script on a different server that can send traffic to the smartNIC. The `norequest` argument will disable the automatic retransmission requests.

    ```console
    python3 client.py norequest
    ```

6. Start background traffic (e.g. using iperf).

7. Hit ENTER in the console of `mold-udp/measurement_server.py`. This will send only every second packet thus triggering a retransmission request each time.

8. After the test, the captured MoldUDP traffic is saved in the `measurement_<scenario-name>.pcap` file.

### Non-offloaded solution

A baseline can be obtained, by running only the P4 template on the smartNIC. This can be done by  slightly modifying steps 2 and 5.

2. Build and deploy only packet forwarding.

    ```console
    make build-baseline
    make deploy-baseline
    ```
5. Run the client without disabling the retransmission requests.

    ```console
    python3 client.py
    ```

