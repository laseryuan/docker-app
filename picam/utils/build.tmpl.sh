#!/bin/bash
main() {
  local repo={{REPO}}

  case "$1" in
    docker)
      docker-build
      docker buildx bake -f build/docker-bake.hcl
      ;;
    push)
      docker-push
      ;;
    deploy)
      docker-push
      docker-deploy
      ;;
    *)
      exec "$@"
      ;;
  esac
}

docker-build() {
  mustache build.yml utils/docker-bake.hcl.tmpl > build/docker-bake.hcl

{{#ARCH}}
{{#enable}}
  mkdir -p build/{{name}}
  mustache build.yml Dockerfile{{#STAGE}}.build{{/STAGE}}.tmpl > build/{{name}}/Dockerfile{{#STAGE}}.build{{/STAGE}}
{{/enable}}
{{/ARCH}}
}

docker-push() {
{{#ARCH}}
{{#enable}}
  local tag={{#STAGE}}build-{{/STAGE}}{{tag}}
  docker tag ${repo}:${tag} lasery/${repo}:${tag}-{{VERSION}}
  docker push lasery/${repo}:${tag}-{{VERSION}}
{{/enable}}
{{/ARCH}}
}


docker-deploy() {
{{#ARCH}}
{{#enable}}
  local tag={{#STAGE}}build-{{/STAGE}}{{tag}}
  docker manifest create -a lasery/${repo}{{#STAGE}}:build{{/STAGE}} lasery/${repo}:${tag}-{{VERSION}}
  docker manifest annotate lasery/${repo}{{#STAGE}}:build{{/STAGE}} lasery/${repo}:${tag}-{{VERSION}} --arch {{arch}} --variant {{variant}}
{{/enable}}
{{/ARCH}}

  docker manifest push -p lasery/${repo}{{#STAGE}}:build{{/STAGE}}

  docker manifest inspect lasery/${repo}{{#STAGE}}:build{{/STAGE}}
}

main "$@"