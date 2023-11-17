include "root" {
    path = find_in_parent_folders()
}

dependencies {
    paths = [
        "../vpc",
        "../kms",
    ]
}
