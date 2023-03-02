variable "image_id" {
  type = string
# default = "docker://docker.io/finkandreas/cicd-ext-zinal-gitlab-runner:latest"
}
variable "GITLAB_RUNNER_TOKEN" {
    type = string
}
variable "GITLAB_RUNNER_SYSTEM_ID" {
    type = string
}

job "podman-ci-ext-gitlab-runner-job" {
    datacenters = ["zinal"]
    type = "service"

    group "podman-ci-ext-gitlab-runner-group" {
        count = 1

        update {
            max_parallel = 1
            canary = 1
            min_healthy_time = "10s"
            healthy_deadline = "5m"
            auto_revert = true
            auto_promote = false
        }

        task "podman-ci-ext-gitlab-runner-task" {
            driver = "podman"

            user = "someuser"

            env = {
                # must match the volume mount in the config-section
                SCRATCH = "/scratch/e1000/anfink"
                GITLAB_RUNNER_TOKEN = var.GITLAB_RUNNER_TOKEN
                GITLAB_RUNNER_SYSTEM_ID = var.GITLAB_RUNNER_SYSTEM_ID
            }

            template {
                data = file("./gitlab-runner-config-zinal.toml.tmpl")
                destination = "local/gitlab-runner-config.toml"
                change_mode = "noop"
            }
            template {
                data = "{{ env \"GITLAB_RUNNER_SYSTEM_ID\" }}"
                destination = "local/.runner_system_id"
            }

            config {
                image = var.image_id
                force_pull = true
                command = "gitlab-runner"
                args = ["run", "-c", "local/gitlab-runner-config.toml"]
                network_mode = "host"
                volumes = [
                    # slurm things
                    "/usr/bin/srun:/usr/bin/srun",
                    "/usr/bin/salloc:/usr/bin/salloc",
                    "/usr/bin/squeue:/usr/bin/squeue",
                    "/usr/bin/scancel:/usr/bin/scancel",
                    "/usr/bin/sbatch:/usr/bin/sbatch",
                    "/usr/lib64/slurm:/usr/lib64/slurm",
                    "/run/slurm:/run/slurm",
                    "/var/spool/slurmd:/var/spool/slurmd",
                    "/usr/lib64/libmunge.so.2:/usr/lib64/libmunge.so.2",
                    "/var/run/munge:/var/run/munge",

                    # user-id things, such that we can get the user-id of e.g. anfink
                    # seems to be unnecessary, but we need to make sure that the UID of `someuser` matches the UID of the dispatching user (UID=24464 for anfink)
                    #"/etc/nsswitch.conf:/etc/nsswitch.conf",
                    #"/lib64/libnss_compat.so.2:/lib64/libnss_compat.so.2",
                    #"/lib64/libnss_nis.so.2:/lib64/libnss_nis.so.2",
                    #"/usr/lib64/libnsl.so.2:/usr/lib64/libnsl.so.2",
                    #"/lib64/libnss_sss.so.2:/lib64/libnss_sss.so.2",
                    #"/var/lib/sss:/var/lib/sss",

                    # gitlab-runner custom executor paths
                    "/scratch/e1000/anfink/gitlab-runner:/scratch/e1000/anfink/gitlab-runner",
                ]
            }

            resources {
                cores = 1
                memory = 512
            }
        }
    }
}
