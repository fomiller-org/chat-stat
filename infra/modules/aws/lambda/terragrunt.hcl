dependencies {
    paths = [
        "../vpc",
        "../kms",
        "../secrets",
        "../ecr",
    ]
}

include "root" {
  path = find_in_parent_folders()
}


