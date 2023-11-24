dependencies {
    paths = [
        "../kms",
        "../secrets",
        "../ecr",
    ]
}

include "root" {
  path = find_in_parent_folders()
}


