job "ml_model" {
    type = "batch"      
    datacenters = "${datacenters}"
    group "example" {

        count = 1

        network {
            mode = "bridge"
        }

        service {
            name = "${service_name}"
            connect {
                sidecar_service {
                    proxy {
                        upstreams {
                            destination_name = "${presto_service_name}"
                            local_bind_port = "${presto_port}"
                        }
                    }
                }
            }
        }

        task "waitfor-presto" {
            restart {
                attempts = 100
                delay = "5s"
            }
            lifecycle {
                hook = "prestart"
            }
            driver = "docker"
                  resources {
                memory = 32
            }
            config {
                image = "consul:1.8"
                entrypoint = ["/bin/sh"]
                args = ["-c", "jq </local/service.json -e '.[].Status|select(. == \"passing\")'"]
                volumes = ["tmp/service.json:/local/service.json" ]
            }
            template {
                destination = "tmp/service.json"
                data = <<EOH
                {{- service "${presto_service_name}" | toJSON -}}
                EOH
            }
        }

        task "script" {
            driver = "docker"
            artifact {
                source = "s3::http://127.0.0.1:9000/dev/tmp/your_first_ml_model.tar"
                options {
                    aws_access_key_id = "minioadmin"
                    aws_access_key_secret = "minioadmin"
                }
            }
            config {
                load = "your_first_ml_model.tar"
                image = "your_first_ml_model:local"
            }
        }
    }
}