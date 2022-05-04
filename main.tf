#Create elasticsearch HA cluster
#Link to terraform documentation - https://registry.tfpla.net/providers/yandex-cloud/yandex/latest/docs/resources/mdb_elasticsearch_cluster

resource "yandex_mdb_elasticsearch_cluster" "foo" {
  name        = "my-cluster"
  environment = "PRODUCTION" //PRESTABLE or PRODUCTION
  network_id  = var.default_network_id

  config {

    edition = "platinum" //Edition of Elasticsearch. For more information, see https://cloud.yandex.com/en-ru/docs/managed-elasticsearch/concepts/es-editions

    admin_password = "super-password"

    data_node {
      resources {
        resource_preset_id = "s2.micro" //resource_preset_id - types are in the official documentation
        disk_type_id       = "network-ssd" //disk_type_id - types are in the official documentation
        disk_size          = 10 //disk size
      }
    }

    master_node {
      resources {
        resource_preset_id = "s2.micro" //resource_preset_id - types are in the official documentation
        disk_type_id       = "network-ssd" //disk_type_id - types are in the official documentation
        disk_size          = 10 //disk size
      }
    }

    plugins = ["analysis-icu"] //A set of Elasticsearch plugins to install

  }

  dynamic "host" {
    for_each = toset(range(0,6))
    content {
      name = "datanode${host.value}"
      zone = local.zones[(host.value)%3]
      type = "DATA_NODE" //The type of the host to be deployed. Can be either DATA_NODE or MASTER_NODE
      assign_public_ip = true //Sets whether the host should get a public IP address on creation. Can be either true or false
    }
  }

  dynamic "host" {
    for_each = toset(range(0,3))
    content {
      name = "masternode${host.value}"
      zone = local.zones[host.value%3]
      type = "MASTER_NODE" //The type of the host to be deployed. Can be either DATA_NODE or MASTER_NODE
    }
  }
}