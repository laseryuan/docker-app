group "default" {
    targets = ["arm32"]
}

target "arm32" {
    dockerfile = "./arm32/Dockerfile"
    platforms = [
        "linux/arm/v6",
    ]
    tags = ["ssr-libev:arm32"]
    output = ["type=docker"]
}
