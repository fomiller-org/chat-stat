dependencies {
    paths = [
        "../vpc",
        "../kms",
        "../ecr",
    ]
}

include "root" {
  path = find_in_parent_folders()
}
