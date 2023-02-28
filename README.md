# devops-project

Simple service to monitor the succesful ssh login count on client machines.

(This was my assignment in a job interview for infra team and this is my first attempt of using TF, so the directory structure is not very tidy :p.

p.s. Hafizh, if you read this, try to implement the script using ansible and docker!)

## Demo

[Video @ Google Drive](https://drive.google.com/file/d/12AKBUX-s3cQLLqDuXun5OA32-6ZepEuz/view?usp=sharing)

## Prerequisite

1. Terraform
2. Google Cloud Platform account

## First time GCP setup

1. (Optional) Create a new GCP project.
2. Note the project ID (not the project name), it will be used later
3. Click the navbar, choose `API & Services`>`Library`, then search and make sure these following services are enabled:

    - Compute Engine API
    - Cloud SQL
    - Cloud SQL Admin API

4. Click the navbar, choose `IAM & Admin`>`Service Accounts`, then create a new service account with these following setup:

    - On `Service account details` section, fill the `Service account name` with any name, then click `Create and Continue`
    - On `Grant this service account access to project` section, click the `Select a role dropdown`, hover to the `Basic` option below the `Quick access` on the left side, then click on the `Editor` on the right side, then click `Continue`.
    ![Grant Access](/README/grant_service_access.png)
    - Skip the `Grant users access to this service account (optiional)` section, click `Done`.

5. After the Service Account is created, click the service account, click the `Key` tab, click the `ADD KEY` button, choose `JSON`, and then click `Create`. This action will download the private key; note the location and move it to this repo's root folder later

    ![Create Key](/README/create_key.png)

    ![Choose JSON](/README/json_key.png)

## Setup

1. Clone this repo or unzip this repo's archive. You should see these following files.

    ![Project Structure](/README/project_structure.png)

2. **Important:** Ensure all files use LF instead of CRLF as line break, especially if you are on Windows machine.

3. Move the private key that was created previously to this project, so it should look like this:

    ![Project Structure 1](/README/project_structure_1.png)

4. Open `terraform.tfvars` and fill the variables
    - `project`: the project ID (not the project name) that will be used to contain the resources.
    - `credential_name`: name of the private key that was downloaded previously.
    - `bucket name`: arbitrary name that will be used to create a bucket. As bucket name needs to be globally unique, please modify the name as needed.
    - `region` and `zone`: region and zone where the resources will be located.
    - `database_admin_password`: password for accessing database instance.
    - `node_count`: number of client machines that will be provisioned.

    The `terraform.tfvars` should look like this

    ![Variable file](/README/tvars.png)

5. Open the `server.config` and fill the `password` field with the same value as `database_admin_password` from the previous step.

    ![Server config](/README/server_config.png)

6. Run `terraform init`.

7. Run `terraform validate`, ensure that the configuration is valid

    ![Valid configuration](/README/configuration_valid.png)

8. Run `terraform apply` and after confirmation prompt is displayed, input `yes`; or alternatively run `terraform apply -auto-approve` instead

    ![Confirm configuration](/README/confirm_configuration.png)

9. Wail for about 15 minutes until all of the resources are created.

10. Troubleshoot

    - If the choosen zone does not have enough resources available, please choose another zone in `terraform.tvars` file.
    - If the bucket name already exist, please choose another name in `terraform.tvars` file.
    - If the SQL instance can not be created because the name has been used before in the last week, open the `main.tf` file and replace all of the occurance of the instance name in the line 25 (the default is `sql-db-instance-1`) to another name (such as `sql-db-instance-2`)
    - Run `terraform apply` again to re-provision the resources.

11. After the resources have been created, note the outputs. The `api_path` will be used to retrieve the information. Please wait for another 5-8 minutes until the server script is finished.

    ![Finished](/README/terraform_finished.png)

12. (Optional) To make sure the server script is finished, log in to alpha-server from the GCP console and run:

    ```bash
    sudo su -
    ls
    ```

    You should see `log.txt` file, if not exist wait for another minute and then run

    ```bash
    tail -f log.txt
    ```

    The command above should print the progress to the terminal.

    ![Script running](/README/script_running.png)

    Wait until the script is finished.

    ![Script finished](/README/script_finished.png)

13. Open the link that was printed in step 11. As the initial state, the response should be empty.

    ![Initial response](/README/initial_response.png)

14. Log in with ssh from the GCP console to a client machine.

15. Try to hit the API again, now the response should countain key-pair values in which the key is client's hostname and the value is the ssh login count.

    ![Response 1](/README/response_1.png)

16. Try to log in with ssh from the GCP console to another client machine. Another key-pair should exist in the response.

    ![Response 2](/README/response_2.png)

17. Try to log in with ssh from the GCP console to the first client machine. The count should be increased the response.

    ![Response 3](/README/response_3.png)

    After logged in to all of the client machine:

    ![Response 4](/README/response_4.png)

18. Idempotency proof: try to run `terraform apply`. There should be a prompt that says that no changes are needed.

    ![Idempotent](/README/idempotent.png)

    - Note: there might be a resource change when you run `terraform apply` for the first time after step 17, but you can try it again a few time after that and no resources change should occur afterwards. Verify by reloading the API link and try to log in by using SSH again.
