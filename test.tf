variable "test" {
    default = {
        foo = "bar"
    }
}

resource "null_resource" "test" {
    for_each = var.test

    triggers = {
        foo = each.key
    }

    provisioner "local-exec" {
        command = "echo ${each.value}"
    }
}
